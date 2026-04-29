"""
Email notification for STC CMP Automation test results.

Parses Robot Framework output.xml and sends a professional summary email using
the HTML template at email-template/test_report_template.html, with:
  - Pass/fail/skip counts with percentages + trend vs previous run
  - Execution distribution bar
  - Execution time with smart classification
  - Risk assessment section for failures
  - Table of failed tests (top 5)
  - combined_report.html or report.html attached

Usage (standalone):
    python send_report.py reports/2026-04-15_10-30-00

Called automatically by run_tests.py when --email flag is used.

Configuration:
    Edit .env file in the project root to set SMTP and recipient settings.
    To add/remove recipients, just edit EMAIL_TO in .env (comma-separated).
"""

import os
import sys
import json
import smtplib
import xml.etree.ElementTree as ET
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime, timedelta

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# Server runs in UTC; reports show IST (UTC+5:30)
IST_OFFSET = timedelta(hours=5, minutes=30)


def _utc_to_ist(dt_obj):
    ist = dt_obj + IST_OFFSET
    return ist.strftime("%I:%M %p, %b %d, %Y") + " IST"


def _get_start_from_run_info(output_dir):
    info_file = os.path.join(output_dir, "run_info.json")
    if not os.path.exists(info_file):
        return ""
    try:
        with open(info_file, encoding="utf-8") as f:
            info = json.load(f)
        ts = info.get("timestamp", "")
        if ts and "_" in ts:
            dt = datetime.strptime(ts, "%Y-%m-%d_%H-%M-%S")
            return _utc_to_ist(dt)
    except Exception:
        pass
    return ""


# ─── .env loader ──────────────────────────────────────────────

def load_env():
    env_path = os.path.join(ROOT_DIR, ".env")
    if not os.path.exists(env_path):
        return
    with open(env_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            k, v = key.strip(), value.strip()
            if v:
                os.environ[k] = v


# ─── run_info helpers ─────────────────────────────────────────

def _read_run_info(output_dir):
    info_file = os.path.join(output_dir, "run_info.json")
    defaults = {"client": "STC", "env": "qe", "tag": "", "module": ""}
    if os.path.exists(info_file):
        try:
            with open(info_file, encoding="utf-8") as f:
                info = json.load(f)
            defaults.update(info)
        except (json.JSONDecodeError, IOError):
            pass
    # Fallback to .env values
    load_env()
    if defaults["client"] == "STC":
        defaults["client"] = os.environ.get("CLIENT", "STC")
    if defaults["env"] == "qe":
        defaults["env"] = os.environ.get("ENV", "QE")
    return defaults


def _resolve_test_type(tag):
    if not tag:
        return "Regression Test Cases"
    tag_lower = tag.strip().lower()
    tag_map = {
        "smoke":      "Smoke Test Cases",
        "sanity":     "Sanity Test Cases",
        "critical":   "Critical Test Cases",
        "regression": "Regression Test Cases",
        "e2e":        "E2E Test Cases",
        "positive":   "Positive Test Cases",
        "negative":   "Negative Test Cases",
        "security":   "Security Test Cases",
        "feature":    "Feature Test Cases",
    }
    return tag_map.get(tag_lower, f"{tag.title()} Test Cases")


def _resolve_env_label(client, env):
    return f"{client.upper()} - {env.upper()} Environment"


# ─── Trend / comparison ───────────────────────────────────────

def _find_previous_run(current_output_dir):
    reports_dir = os.path.dirname(current_output_dir)
    if not os.path.isdir(reports_dir):
        return None
    current_tag = ""
    current_info = os.path.join(current_output_dir, "run_info.json")
    if os.path.exists(current_info):
        try:
            with open(current_info, encoding="utf-8") as f:
                current_tag = json.load(f).get("tag", "").lower()
        except Exception:
            pass
    current_name = os.path.basename(current_output_dir)
    cur_xml = os.path.join(current_output_dir, "output.xml")
    current_mtime = os.path.getmtime(cur_xml) if os.path.exists(cur_xml) else 0
    candidates = []
    for d in os.listdir(reports_dir):
        full = os.path.join(reports_dir, d)
        if not os.path.isdir(full) or d == current_name:
            continue
        prev_xml = os.path.join(full, "output.xml")
        if not os.path.exists(prev_xml):
            prev_xml = os.path.join(full, "combined_output.xml")
        if not os.path.exists(prev_xml):
            continue
        mtime = os.path.getmtime(prev_xml)
        if abs(mtime - current_mtime) < 1:
            continue
        tag_match = False
        info_file = os.path.join(full, "run_info.json")
        if os.path.exists(info_file) and current_tag:
            try:
                with open(info_file, encoding="utf-8") as f:
                    prev_tag = json.load(f).get("tag", "").lower()
                tag_match = prev_tag == current_tag
            except Exception:
                pass
        candidates.append((mtime, full, tag_match))
    if not candidates:
        return None
    tag_matches = [(m, p) for m, p, t in candidates if t]
    if tag_matches:
        tag_matches.sort(key=lambda x: x[0], reverse=True)
        return tag_matches[0][1]
    candidates.sort(key=lambda x: x[0], reverse=True)
    return candidates[0][1]


def _compute_trend(current_summary, prev_dir):
    if not prev_dir:
        return "", "First run", 0
    try:
        for xml_name in ("combined_output.xml", "output.xml"):
            candidate = os.path.join(prev_dir, xml_name)
            if os.path.exists(candidate):
                break
        else:
            return "", "No previous data", 0
        tree = ET.parse(candidate)
        root = tree.getroot()
        prev_pass = prev_fail = 0
        for stat in root.iter("stat"):
            text = (stat.text or "").strip()
            if text in ("All Tests", "All"):
                prev_pass = int(stat.get("pass", 0))
                prev_fail = int(stat.get("fail", 0))
                break
        if prev_pass == 0 and prev_fail == 0:
            return "", "No previous data", 0
        prev_total = prev_pass + prev_fail
        prev_pct = int(prev_pass / prev_total * 100) if prev_total > 0 else 0
        curr_pct = int(current_summary["passed"] / current_summary["total"] * 100) if current_summary["total"] > 0 else 0
        diff = curr_pct - prev_pct
        if diff > 0:
            return "&#x2191;", f"+{diff}% from last run", prev_pct
        elif diff < 0:
            return "&#x2193;", f"{diff}% from last run", prev_pct
        else:
            return "&#x2192;", "Same as last run", prev_pct
    except Exception:
        return "", "No previous data", 0


# ─── Duration helpers ─────────────────────────────────────────

def _parse_duration_seconds(duration_str):
    if not duration_str or duration_str == "00:00:00":
        return 0
    try:
        parts = duration_str.split(":")
        h, m, s = int(parts[0]), int(parts[1]), int(parts[2])
        return h * 3600 + m * 60 + s
    except (ValueError, IndexError):
        return 0


def _format_duration_smart(total_secs):
    if total_secs <= 0:
        return "0s"
    h = total_secs // 3600
    m = (total_secs % 3600) // 60
    s = total_secs % 60
    if h > 0:
        return f"{h}h {m}m" if m > 0 else f"{h}h"
    elif m > 0:
        return f"{m}m {s}s" if s > 0 else f"{m}m"
    else:
        return f"{s}s"


def _classify_duration(total_secs):
    if total_secs < 60:
        return "Fast Run", "#16a34a"
    elif total_secs < 600:
        return "Optimal", "#16a34a"
    elif total_secs < 1800:
        return "Acceptable", "#d97706"
    else:
        return "Slow Execution", "#dc2626"


def _get_prev_duration_seconds(prev_dir):
    if not prev_dir:
        return 0
    try:
        for xml_name in ("combined_output.xml", "output.xml"):
            candidate = os.path.join(prev_dir, xml_name)
            if os.path.exists(candidate):
                break
        else:
            return 0
        tree = ET.parse(candidate)
        suite = tree.getroot().find("suite")
        if suite is None:
            return 0
        status = suite.find("status")
        if status is None:
            return 0
        start = status.get("starttime", status.get("start", ""))
        end = status.get("endtime", status.get("end", ""))
        if not start or not end:
            return 0
        fmt = "%Y-%m-%dT%H:%M:%S" if "T" in start else "%Y%m%d %H:%M:%S"
        st = datetime.strptime(start[:19], fmt)
        et = datetime.strptime(end[:19], fmt)
        return max(0, int((et - st).total_seconds()))
    except Exception:
        return 0


def _build_duration_html(duration_str, total_tests, prev_dir):
    curr_secs = _parse_duration_seconds(duration_str)
    smart_fmt = _format_duration_smart(curr_secs)
    label, label_color = _classify_duration(curr_secs)
    avg_secs = curr_secs / total_tests if total_tests > 0 else 0
    avg_fmt = _format_duration_smart(int(avg_secs))
    prev_secs = _get_prev_duration_seconds(prev_dir)
    if prev_secs > 0 and curr_secs > 0:
        diff = curr_secs - prev_secs
        if diff > 0:
            compare_html = f'<span style="color:#dc2626;">&#x2191; +{_format_duration_smart(abs(diff))} from last run</span>'
        elif diff < 0:
            compare_html = f'<span style="color:#16a34a;">&#x2193; {_format_duration_smart(abs(diff))} faster</span>'
        else:
            compare_html = '<span style="color:#6b7280;">Same as last run</span>'
    else:
        compare_html = ""
    return {
        "smart":       smart_fmt,
        "label":       label,
        "label_color": label_color,
        "avg_per_test": avg_fmt,
        "compare_html": compare_html,
        "raw_hms":     duration_str or "00:00:00",
    }


# ─── Risk assessment ──────────────────────────────────────────

def _generate_risk_html(failed_tests):
    if not failed_tests:
        return ""
    critical_kw = ["e2e", "login", "onboard", "billing", "invoice", "activate", "order"]
    high_kw = ["apn", "sim", "device", "plan", "csr", "journey", "role", "user"]
    critical_failures, high_failures, medium_failures = [], [], []
    for ft in failed_tests:
        n = ft["name"].lower()
        if any(k in n for k in critical_kw):
            critical_failures.append(ft["name"])
        elif any(k in n for k in high_kw):
            high_failures.append(ft["name"])
        else:
            medium_failures.append(ft["name"])
    if critical_failures:
        level, color, bg = "CRITICAL", "#dc2626", "#fef2f2"
    elif high_failures:
        level, color, bg = "HIGH", "#ea580c", "#fff7ed"
    else:
        level, color, bg = "MEDIUM", "#d97706", "#fffbeb"
    html = (
        f'<div style="margin-top:20px;border-radius:8px;overflow:hidden;">'
        f'<div style="background:{color};color:white;padding:10px 16px;font-size:13px;font-weight:700;">'
        f'RISK ASSESSMENT &mdash; {level}</div>'
        f'<div style="background:{bg};padding:14px 16px;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 8px 8px;">'
    )
    for name_list, label_text, lc in [
        (critical_failures, "critical-path", "#dc2626"),
        (high_failures,     "high-priority", "#ea580c"),
    ]:
        if name_list:
            html += f'<div style="font-size:12px;color:{lc};font-weight:600;margin-bottom:4px;">&#x26A0; {len(name_list)} {label_text} test(s) failing:</div>'
            for name in name_list[:3]:
                html += f'<div style="font-size:11px;color:#374151;padding-left:12px;">- {name}</div>'
            if len(name_list) > 3:
                html += f'<div style="font-size:11px;color:#6b7280;padding-left:12px;">...and {len(name_list)-3} more</div>'
            html += '<div style="height:8px;"></div>'
    if medium_failures:
        html += f'<div style="font-size:12px;color:#d97706;font-weight:600;">&#x25CF; {len(medium_failures)} other test(s) failing</div>'
    html += '</div></div>'
    return html


# ─── Failed tests table ───────────────────────────────────────

def _build_failed_tests_html(failed_tests, max_show=5):
    if not failed_tests:
        return ""
    shown = failed_tests[:max_show]
    remaining = len(failed_tests) - max_show
    rows = []
    for i, ft in enumerate(shown, 1):
        name = ft["name"].replace("<", "&lt;").replace(">", "&gt;")
        msg = ft["message"].replace("<", "&lt;").replace(">", "&gt;")
        rows.append(
            f'<tr><td style="padding:8px 12px;font-size:12px;border-bottom:1px solid #f3f4f6;color:#374151;">{i}</td>'
            f'<td style="padding:8px 12px;font-size:12px;border-bottom:1px solid #f3f4f6;color:#374151;"><strong>{name}</strong></td>'
            f'<td style="padding:8px 12px;font-size:12px;border-bottom:1px solid #f3f4f6;color:#991b1b;">{msg}</td></tr>'
        )
    html = (
        '<div style="margin-top:20px;">'
        '<div style="background:#e74c3c;color:white;padding:10px 16px;font-size:13px;font-weight:700;border-radius:6px 6px 0 0;letter-spacing:0.5px;">'
        f'FAILED TEST CASES ({len(failed_tests)})</div>'
        '<table style="width:100%;border-collapse:collapse;">'
        '<tr style="background:#fdf0ef;color:#b91c1c;">'
        '<th style="padding:8px 12px;text-align:left;font-size:11px;width:30px;">#</th>'
        '<th style="padding:8px 12px;text-align:left;font-size:11px;">Test Name</th>'
        '<th style="padding:8px 12px;text-align:left;font-size:11px;">Error</th></tr>'
        + "".join(rows)
        + '</table>'
    )
    if remaining > 0:
        html += (
            f'<div style="background:#fef2f2;padding:10px 16px;font-size:12px;color:#6b7280;'
            f'border:1px solid #fecaca;border-top:none;border-radius:0 0 6px 6px;">'
            f'+ {remaining} more failure(s) &mdash; download the attached report.html for full details.</div>'
        )
    else:
        html += '</div>'
    return html


# ─── Template loader ──────────────────────────────────────────

def _load_template(template_name="test_report_template.html"):
    template_path = os.path.join(ROOT_DIR, "email-template", template_name)
    if os.path.exists(template_path):
        with open(template_path, encoding="utf-8") as f:
            return f.read()
    return None


# ─── XML Parsing ──────────────────────────────────────────────

def parse_output_xml(output_dir):
    """Parse output.xml (or combined_output.xml) and return a summary dict."""
    import glob as _glob
    output_xml = os.path.join(output_dir, "combined_output.xml")
    if not os.path.exists(output_xml):
        output_xml = os.path.join(output_dir, "output.xml")
    if not os.path.exists(output_xml):
        individual = sorted(_glob.glob(os.path.join(output_dir, "output_*.xml")))
        if not individual:
            return None
        return _parse_multiple_xmls(individual, output_dir)
    try:
        tree = ET.parse(output_xml)
    except ET.ParseError as exc:
        print(f"ERROR: Could not parse {output_xml}: {exc}")
        return None
    root = tree.getroot()
    suite = root.find("suite")
    suite_name = suite.get("name", "STC Tests") if suite is not None else "STC Tests"

    start_time = end_time = elapsed = ""
    root_status = suite.find("status") if suite is not None else None
    if root_status is not None:
        start_time = root_status.get("starttime", root_status.get("start", ""))
        end_time   = root_status.get("endtime",   root_status.get("end",   ""))
        elapsed    = root_status.get("elapsed", "")

    start_display = ""
    duration = ""
    if start_time:
        try:
            fmt = "%Y-%m-%dT%H:%M:%S" if "T" in start_time else "%Y%m%d %H:%M:%S"
            st = datetime.strptime(start_time[:19], fmt)
            start_display = _utc_to_ist(st)
            if elapsed:
                total_secs = int(float(elapsed))
            elif end_time:
                et_fmt = "%Y-%m-%dT%H:%M:%S" if "T" in end_time else "%Y%m%d %H:%M:%S"
                et = datetime.strptime(end_time[:19], et_fmt)
                total_secs = max(0, int((et - st).total_seconds()))
            else:
                total_secs = 0
            h, m, s = total_secs // 3600, (total_secs % 3600) // 60, total_secs % 60
            duration = f"{h:02d}:{m:02d}:{s:02d}"
        except (ValueError, TypeError):
            start_display = start_time

    # Fallback: sum test elapsed (RF7)
    if not duration or duration == "00:00:00":
        try:
            total_elapsed = 0
            earliest_start = None
            for test in root.iter("test"):
                ts = test.find("status")
                if ts is None:
                    continue
                el = ts.get("elapsed", "")
                if el:
                    total_elapsed += float(el)
                s = ts.get("starttime", ts.get("start", ""))
                if s and (earliest_start is None or s < earliest_start):
                    earliest_start = s
            if total_elapsed > 0:
                total_secs = int(total_elapsed)
                h, m, s = total_secs // 3600, (total_secs % 3600) // 60, total_secs % 60
                duration = f"{h:02d}:{m:02d}:{s:02d}"
        except Exception:
            pass

    total = passed = failed = 0
    for stat in root.iter("stat"):
        text = (stat.text or "").strip()
        if text in ("All Tests", "All"):
            total  = int(stat.get("pass", 0)) + int(stat.get("fail", 0)) + int(stat.get("skip", 0))
            passed = int(stat.get("pass", 0))
            failed = int(stat.get("fail", 0))
            break
    if total == 0:
        for test in root.iter("test"):
            se = test.find("status")
            if se is None:
                continue
            total += 1
            if se.get("status") == "PASS":
                passed += 1
            else:
                failed += 1

    skipped = total - passed - failed
    failed_tests = []
    for test in root.iter("test"):
        se = test.find("status")
        if se is not None and se.get("status") == "FAIL":
            failed_tests.append({
                "name": test.get("name", "Unknown"),
                "message": (se.text or "").strip()[:200],
            })

    overall_status = "FAILED" if failed > 0 else ("NO TESTS" if total == 0 else "PASSED")

    return {
        "total": total, "passed": passed, "failed": failed, "skipped": skipped,
        "failed_tests": failed_tests, "output_dir": output_dir,
        "suite_name": suite_name,
        "start_time": _get_start_from_run_info(output_dir) or start_display or _utc_to_ist(datetime.utcnow()),
        "duration": duration or "00:00:00",
        "overall_status": overall_status,
    }


def _parse_multiple_xmls(xml_files, output_dir):
    total = passed = failed = 0
    failed_tests = []
    suite_names = []
    for xf in xml_files:
        try:
            tree = ET.parse(xf)
        except ET.ParseError:
            continue
        root = tree.getroot()
        suite = root.find("suite")
        if suite is not None:
            suite_names.append(suite.get("name", ""))
        for test in root.iter("test"):
            se = test.find("status")
            if se is None:
                continue
            total += 1
            if se.get("status") == "PASS":
                passed += 1
            else:
                failed += 1
                failed_tests.append({
                    "name": test.get("name", "Unknown"),
                    "message": (se.text or "").strip()[:200],
                })
    if total == 0:
        return None
    skipped = total - passed - failed
    overall_status = "FAILED" if failed > 0 else "PASSED"
    suite_name = ", ".join(s for s in suite_names[:3] if s)
    if len(suite_names) > 3:
        suite_name += f" + {len(suite_names) - 3} more"
    return {
        "total": total, "passed": passed, "failed": failed, "skipped": skipped,
        "failed_tests": failed_tests, "output_dir": output_dir,
        "suite_name": suite_name or "STC Tests",
        "start_time": _get_start_from_run_info(output_dir) or _utc_to_ist(datetime.utcnow()),
        "duration": "00:00:00",
        "overall_status": overall_status,
    }


# ─── Email body builder ───────────────────────────────────────

def build_email_body(summary):
    run_info = _read_run_info(summary["output_dir"])
    tag = run_info.get("tag", "").lower().strip()

    tag_template_map = {
        "smoke":      "smoke-email-template.html",
        "sanity":     "smoke-email-template.html",
        "critical":   "critical-email-template.html",
        "regression": "regression-email-template.html",
    }
    template_file = tag_template_map.get(tag, "test_report_template.html")
    external = _load_template(template_file) or _load_template("test_report_template.html")
    if external:
        return _render_external_template(external, summary)
    return _build_inline_email_body(summary)


def _render_external_template(template, summary):
    total   = summary["total"]
    passed  = summary["passed"]
    failed  = summary["failed"]
    skipped = summary["skipped"]
    pass_pct = int(passed / total * 100) if total > 0 else 0
    fail_pct = int(failed / total * 100) if total > 0 else 0
    skip_pct = 100 - pass_pct - fail_pct

    run_info = _read_run_info(summary["output_dir"])
    client   = run_info["client"]
    env      = run_info["env"]
    tag      = run_info.get("tag", "")

    prev_dir = _find_previous_run(summary["output_dir"])
    trend_arrow, trend_text, _ = _compute_trend(summary, prev_dir)
    failed_table = _build_failed_tests_html(summary["failed_tests"])
    risk_html    = _generate_risk_html(summary["failed_tests"])

    triggered_by = run_info.get("triggered_by", "")
    if not triggered_by:
        triggered_by = "Cron Job" if "cron" in summary.get("output_dir", "").lower() else "Manual (Server)"

    dur_info = _build_duration_html(summary["duration"], total, prev_dir)
    skipped_display     = f"{skipped}" if skipped > 0 else ""
    skipped_pct_display = f"{skip_pct}%" if skipped > 0 else ""

    return template.format(
        TOTAL=total, PASSED=passed, FAILED=failed, SKIPPED=skipped,
        SKIPPED_DISPLAY=skipped_display,
        SKIPPED_PCT_DISPLAY=skipped_pct_display,
        PASS_PCT=pass_pct, FAIL_PCT=fail_pct, SKIP_PCT=skip_pct,
        STATUS=summary["overall_status"],
        STATUS_COLOR="#dc2626" if failed > 0 else "#16a34a",
        STATUS_BG="#fef2f2"   if failed > 0 else "#f0fdf4",
        CLIENT=client.upper(),
        ENV=env.upper(),
        TEST_TYPE=_resolve_test_type(tag),
        ENV_LABEL=_resolve_env_label(client, env),
        SUITE_NAME=summary["suite_name"],
        START_TIME=summary["start_time"],
        DURATION=summary["duration"],
        DURATION_SMART=dur_info["smart"],
        DURATION_LABEL=dur_info["label"],
        DURATION_LABEL_COLOR=dur_info["label_color"],
        DURATION_AVG=dur_info["avg_per_test"],
        DURATION_COMPARE=dur_info["compare_html"],
        OUTPUT_DIR=summary["output_dir"],
        TREND_ARROW=trend_arrow,
        TREND_TEXT=trend_text,
        TRIGGERED_BY=triggered_by,
        FAILED_TESTS_TABLE=failed_table,
        RISK_SECTION=risk_html,
    )


def _build_inline_email_body(summary):
    """Fallback inline template (no external file needed)."""
    total   = summary["total"]
    passed  = summary["passed"]
    failed  = summary["failed"]
    skipped = summary["skipped"]
    pass_pct = int(passed / total * 100) if total > 0 else 0
    fail_pct = int(failed / total * 100) if total > 0 else 0
    skip_pct = 100 - pass_pct - fail_pct

    run_info  = _read_run_info(summary["output_dir"])
    client    = run_info["client"]
    env       = run_info["env"]
    tag       = run_info.get("tag", "")
    test_type = _resolve_test_type(tag)
    env_label = _resolve_env_label(client, env)
    status    = summary["overall_status"]
    sc = "#dc2626" if failed > 0 else "#16a34a"
    sb = "#fef2f2" if failed > 0 else "#f0fdf4"

    prev_dir = _find_previous_run(summary["output_dir"])
    trend_arrow, trend_text, _ = _compute_trend(summary, prev_dir)
    dur_info = _build_duration_html(summary["duration"], total, prev_dir)
    failed_table = _build_failed_tests_html(summary["failed_tests"])
    risk_html    = _generate_risk_html(summary["failed_tests"])

    triggered_by = run_info.get("triggered_by", "Manual (Server)")
    skipped_display     = f"{skipped}" if skipped > 0 else "0"
    skipped_pct_display = f"{skip_pct}%" if skipped > 0 else "0%"

    return f"""\
<html><head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;font-family:'Segoe UI',Arial,sans-serif;background:#f5f6fa;">
<table align="center" width="680" cellpadding="0" cellspacing="0" border="0" style="background:#fff;width:680px;min-width:680px;max-width:680px;">
  <tr><td style="padding:24px;background:#1a237e;">
    <div style="color:#fff;font-size:20px;font-weight:700;">Test Execution Report</div>
    <div style="color:#fff;font-size:16px;font-weight:700;margin-top:6px;">Project: STC CMP Automation Suite</div>
    <div style="color:#fff;font-size:14px;font-weight:700;margin-top:6px;">Client: {client.upper()}</div>
  </td></tr>
  <tr><td style="padding:14px 24px;background:#f8f9fc;border-bottom:1px solid #e8eaf0;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
      <td><div style="font-size:16px;font-weight:700;color:#1a237e;">{test_type}</div>
        <div style="font-size:12px;color:#6b7280;margin-top:4px;">Started: <strong>{summary['start_time']}</strong> | Triggered: <strong>{triggered_by}</strong></div>
      </td>
      <td width="80" align="right"><div style="padding:3px 10px;border-radius:4px;font-size:11px;font-weight:800;background:{sb};color:{sc};border:1px solid {sc};">{status}</div></td>
    </tr></table>
  </td></tr>
  <tr><td style="padding:20px 24px;">
    <table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
      <td width="379" valign="middle">
        <table cellpadding="0" cellspacing="0" border="0"><tr>
          <td align="center" style="padding-right:16px;"><div style="font-size:42px;font-weight:700;color:#1a237e;line-height:1;">{total}</div><div style="font-size:9px;color:#6b7280;text-transform:uppercase;letter-spacing:1px;">TOTAL</div></td>
          <td valign="middle">
            <div style="margin-bottom:8px;"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:#27ae60;vertical-align:middle;"></span> <strong style="font-size:13px;color:#374151;">PASSED</strong> <span style="font-size:14px;font-weight:700;color:#27ae60;margin-left:8px;">{passed}</span> <span style="font-size:12px;color:#6b7280;">({pass_pct}%)</span></div>
            <div style="margin-bottom:8px;"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:#e74c3c;vertical-align:middle;"></span> <strong style="font-size:13px;color:#374151;">FAILED</strong> <span style="font-size:14px;font-weight:700;color:#e74c3c;margin-left:8px;">{failed}</span> <span style="font-size:12px;color:#6b7280;">({fail_pct}%)</span></div>
            <div><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:#f39c12;vertical-align:middle;"></span> <strong style="font-size:13px;color:#374151;">SKIPPED</strong> <span style="font-size:14px;font-weight:700;color:#f39c12;margin-left:8px;">{skipped_display}</span> <span style="font-size:12px;color:#6b7280;">({skipped_pct_display})</span></div>
          </td>
        </tr></table>
      </td>
      <td width="253" align="center" valign="middle">
        <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:16px;text-align:center;">
          <div style="font-size:32px;font-weight:800;color:#16a34a;line-height:1;">{pass_pct}%</div>
          <div style="font-size:9px;color:#6b7280;text-transform:uppercase;letter-spacing:1px;margin-top:5px;">Pass Rate</div>
          <div style="font-size:10px;color:#16a34a;margin-top:6px;font-weight:600;">{trend_arrow} {trend_text}</div>
        </div>
        <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:6px;padding:8px;margin-top:8px;text-align:center;">
          <div style="font-size:10px;color:#1a237e;text-transform:uppercase;letter-spacing:0.5px;font-weight:700;">{env_label}</div>
        </div>
      </td>
    </tr></table>
    <div style="margin-top:16px;border:1px solid #e8eaf0;border-radius:6px;padding:10px 12px;">
      <div style="font-size:9px;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;margin-bottom:6px;">Execution Distribution</div>
      <div style="width:100%;height:10px;background:#e5e7eb;border-radius:5px;overflow:hidden;">
        <div style="height:100%;width:{pass_pct}%;background:#27ae60;float:left;"></div>
        <div style="height:100%;width:{fail_pct}%;background:#e74c3c;float:left;"></div>
        <div style="height:100%;width:{skip_pct}%;background:#f39c12;float:left;"></div>
      </div>
      <div style="font-size:10px;color:#6b7280;margin-top:4px;">
        <span style="display:inline-block;width:6px;height:6px;border-radius:50%;background:#27ae60;vertical-align:middle;"></span> Passed ({pass_pct}%) &nbsp;
        <span style="display:inline-block;width:6px;height:6px;border-radius:50%;background:#e74c3c;vertical-align:middle;"></span> Failed ({fail_pct}%) &nbsp;
        <span style="display:inline-block;width:6px;height:6px;border-radius:50%;background:#f39c12;vertical-align:middle;"></span> Skipped ({skip_pct}%)
      </div>
    </div>
    <div style="margin-top:12px;border:1px solid #e8eaf0;border-radius:6px;padding:10px 12px;">
      <div style="font-size:9px;color:#6b7280;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;margin-bottom:4px;">Execution Time</div>
      <span style="font-size:18px;font-weight:800;color:#1a237e;">{dur_info['smart']}</span>
      <span style="font-size:12px;font-weight:700;color:{dur_info['label_color']};margin-left:8px;">({dur_info['label']})</span>
      <div style="font-size:11px;color:#6b7280;margin-top:3px;">Avg/Test: <strong>{dur_info['avg_per_test']}</strong> <span style="margin-left:12px;">{dur_info['compare_html']}</span></div>
    </div>
    <table cellpadding="0" cellspacing="0" border="0" style="margin-top:16px;border-top:1px solid #e8eaf0;padding-top:10px;width:100%;">
      <tr><td style="padding:4px 0;width:140px;color:#6b7280;text-transform:uppercase;font-size:10px;letter-spacing:0.5px;font-weight:600;">App Environment</td><td style="padding:4px 0;font-size:12px;color:#1f2937;font-weight:500;">{env_label}</td></tr>
      <tr><td style="padding:4px 0;color:#6b7280;text-transform:uppercase;font-size:10px;letter-spacing:0.5px;font-weight:600;">Test Type</td><td style="padding:4px 0;font-size:12px;color:#1f2937;font-weight:500;">{test_type}</td></tr>
      <tr><td style="padding:4px 0;color:#6b7280;text-transform:uppercase;font-size:10px;letter-spacing:0.5px;font-weight:600;">Browser</td><td style="padding:4px 0;font-size:12px;color:#1f2937;font-weight:500;">Linux, Headless Chrome 108</td></tr>
    </table>
    {risk_html}
    {failed_table}
    <p style="font-size:11px;color:#6b7280;margin:16px 0 0 0;font-style:italic;">For the complete report with screenshots, download the attached <strong>report.html</strong>.</p>
  </td></tr>
  <tr><td style="padding:16px 24px;text-align:center;background:#f8f9fc;border-top:1px solid #e8eaf0;">
    <div style="font-size:10px;color:#9ca3af;">This report was auto-generated by <strong>STC CMP Automation Suite</strong>. You were added as a recipient by the <strong>Airlinq QA</strong> team. To unsubscribe, contact the QA team lead.</div>
    <div style="margin-top:10px;font-size:9px;color:#9ca3af;text-transform:uppercase;letter-spacing:1px;">POWERED BY</div>
    <div style="font-size:14px;font-weight:700;color:#4facfe;margin-top:4px;letter-spacing:1px;"><strong>AIRLINQ AUTOMATION</strong></div>
  </td></tr>
</table>
</body></html>"""


# ─── Email sender ─────────────────────────────────────────────

def send_email(summary):
    load_env()
    smtp_host  = os.environ.get("SMTP_HOST", "")
    smtp_port  = int(os.environ.get("SMTP_PORT", "25"))
    smtp_tls   = os.environ.get("SMTP_TLS", "False").strip().lower() not in ("false", "0", "no")
    smtp_user  = os.environ.get("SMTP_USER", "")
    smtp_pass  = os.environ.get("SMTP_PASS", "")
    email_from = os.environ.get("EMAIL_FROM", smtp_user)
    email_to   = os.environ.get("EMAIL_TO", "")
    if not email_to:
        print("EMAIL_TO not set in .env — skipping email.")
        return False

    recipients = [r.strip() for r in email_to.split(",") if r.strip()]
    run_info   = _read_run_info(summary["output_dir"])
    env_label  = _resolve_env_label(run_info["client"], run_info["env"])
    test_type  = _resolve_test_type(run_info.get("tag", ""))
    status     = summary["overall_status"]

    subject = (
        f"{run_info['client'].upper()} Automation: {status} "
        f"({summary['passed']}/{summary['total']} passed) | "
        f"{test_type} | {env_label}"
    )

    msg = MIMEMultipart("mixed")
    msg["Subject"] = subject
    msg["From"]    = email_from
    msg["To"]      = ", ".join(recipients)
    msg.attach(MIMEText(build_email_body(summary), "html"))

    # Attach report (combined first, then single, skip >20 MB)
    MAX_MB = 20
    for report_name in ("combined_report.html", "report.html"):
        report_html = os.path.join(summary["output_dir"], report_name)
        if os.path.exists(report_html):
            size_mb = os.path.getsize(report_html) / (1024 * 1024)
            if size_mb <= MAX_MB:
                with open(report_html, "rb") as fh:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(fh.read())
                    encoders.encode_base64(part)
                    part.add_header("Content-Disposition", "attachment", filename=report_name)
                    msg.attach(part)
                print(f"  Attached: {report_name} ({size_mb:.1f} MB)")
            else:
                print(f"  Skipped {report_name} ({size_mb:.1f} MB > {MAX_MB} MB limit)")
            break

    # Try configured SMTP
    if smtp_host:
        try:
            with smtplib.SMTP(smtp_host, smtp_port, timeout=10) as server:
                server.ehlo()
                if smtp_tls:
                    server.starttls()
                    server.ehlo()
                    if smtp_user and smtp_pass:
                        server.login(smtp_user, smtp_pass)
                server.sendmail(email_from, recipients, msg.as_string())
            print(f"Email sent via {smtp_host} to: {', '.join(recipients)}")
            return True
        except Exception as exc:
            print(f"SMTP send failed ({smtp_host}): {exc}")

    # Fallback: localhost:25
    try:
        with smtplib.SMTP("localhost", 25, timeout=10) as server:
            server.sendmail(email_from, recipients, msg.as_string())
        print(f"Email sent via localhost to: {', '.join(recipients)}")
        return True
    except Exception as exc:
        print(f"Local SMTP also failed: {exc}")
        return False


# ─── CLI ──────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print("Usage: python send_report.py <report_directory>")
        sys.exit(1)
    output_dir = sys.argv[1]
    if not os.path.isdir(output_dir):
        print(f"ERROR: Directory not found: {output_dir}")
        sys.exit(1)
    summary = parse_output_xml(output_dir)
    if summary is None:
        print(f"No output.xml found in {output_dir}")
        sys.exit(1)
    print(f"Test Results: {summary['passed']}/{summary['total']} passed, {summary['failed']} failed")
    send_email(summary)


if __name__ == "__main__":
    main()
