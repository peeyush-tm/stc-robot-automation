"""
Email notification for STC Automation test results.

Parses Robot Framework output.xml and sends a professional summary email with:
  - Circular progress indicator
  - Pass/fail/skip counts with percentages
  - Execution metadata (start time, duration, environment, browser)
  - Table of failed tests with error messages
  - combined_report.html attached

Usage (standalone):
    python send_report.py reports/2026-04-15_10-30-00

Called automatically by run_tests.py when --email flag is used.

Configuration:
    Edit .env file in the project root to set SMTP and recipient settings.
    To add/remove recipients, just edit EMAIL_TO in .env (comma-separated).
"""

import os
import sys
import smtplib
import xml.etree.ElementTree as ET
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


def load_env():
    """Load .env file into os.environ."""
    env_path = os.path.join(ROOT_DIR, ".env")
    if not os.path.exists(env_path):
        return
    with open(env_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            os.environ.setdefault(key.strip(), value.strip())


# ─── XML Parsing ───────────────────────────────────────────────


def parse_output_xml(output_dir):
    """Parse output.xml and return a test summary dict, or None on failure.
    Falls back to merging individual output_*.xml files if combined is missing."""
    import glob as _glob
    # Try combined_output.xml first (multi-suite runs), then output.xml
    output_xml = os.path.join(output_dir, "combined_output.xml")
    if not os.path.exists(output_xml):
        output_xml = os.path.join(output_dir, "output.xml")

    # Fallback: parse all individual output_*.xml files and aggregate totals
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

    # Extract execution metadata from root <suite>
    suite = root.find("suite")
    suite_name = suite.get("name", "STC Tests") if suite is not None else "STC Tests"

    # Get start/end times from root suite status
    start_time = ""
    end_time = ""
    duration = ""
    root_status = suite.find("status") if suite is not None else None
    if root_status is not None:
        start_time = root_status.get("starttime", root_status.get("start", ""))
        end_time = root_status.get("endtime", root_status.get("end", ""))

    # Parse times and compute duration
    start_display = ""
    if start_time:
        try:
            if "T" in start_time:
                st = datetime.strptime(start_time[:19], "%Y-%m-%dT%H:%M:%S")
            else:
                st = datetime.strptime(start_time[:17], "%Y%m%d %H:%M:%S")
            start_display = st.strftime("%I:%M %p, %b %d, %Y")
            if end_time:
                if "T" in end_time:
                    et = datetime.strptime(end_time[:19], "%Y-%m-%dT%H:%M:%S")
                else:
                    et = datetime.strptime(end_time[:17], "%Y%m%d %H:%M:%S")
                delta = et - st
                total_secs = int(delta.total_seconds())
                hours = total_secs // 3600
                minutes = (total_secs % 3600) // 60
                seconds = total_secs % 60
                duration = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        except (ValueError, TypeError):
            start_display = start_time
            duration = ""

    # Collect totals from <statistics>
    total = passed = failed = 0
    for stat in root.iter("stat"):
        text = (stat.text or "").strip()
        if text in ("All Tests", "All"):
            total = int(stat.get("pass", 0)) + int(stat.get("fail", 0)) + int(stat.get("skip", 0))
            passed = int(stat.get("pass", 0))
            failed = int(stat.get("fail", 0))
            break

    # Fallback: count <test> elements directly
    if total == 0:
        for test in root.iter("test"):
            status_elem = test.find("status")
            if status_elem is None:
                continue
            total += 1
            if status_elem.get("status") == "PASS":
                passed += 1
            else:
                failed += 1

    skipped = total - passed - failed

    # Collect details of failed tests
    failed_tests = []
    for test in root.iter("test"):
        status_elem = test.find("status")
        if status_elem is not None and status_elem.get("status") == "FAIL":
            failed_tests.append({
                "name": test.get("name", "Unknown"),
                "message": (status_elem.text or "").strip()[:200],
            })

    # Determine overall status
    if failed > 0:
        overall_status = "FAILED"
    elif total == 0:
        overall_status = "NO TESTS"
    else:
        overall_status = "PASSED"

    return {
        "total": total,
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "failed_tests": failed_tests,
        "output_dir": output_dir,
        "suite_name": suite_name,
        "start_time": start_display or datetime.now().strftime("%I:%M %p, %b %d, %Y"),
        "duration": duration or "00:00:00",
        "overall_status": overall_status,
    }


def _parse_multiple_xmls(xml_files, output_dir):
    """Aggregate results from individual output_*.xml files when combined is missing."""
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
            status_elem = test.find("status")
            if status_elem is None:
                continue
            total += 1
            if status_elem.get("status") == "PASS":
                passed += 1
            else:
                failed += 1
                failed_tests.append({
                    "name": test.get("name", "Unknown"),
                    "message": (status_elem.text or "").strip()[:200],
                })

    if total == 0:
        return None

    skipped = total - passed - failed
    overall_status = "FAILED" if failed > 0 else "PASSED"
    suite_name = ", ".join(s for s in suite_names[:3] if s)
    if len(suite_names) > 3:
        suite_name += f" + {len(suite_names) - 3} more"

    return {
        "total": total,
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "failed_tests": failed_tests,
        "output_dir": output_dir,
        "suite_name": suite_name or "STC Tests",
        "start_time": datetime.now().strftime("%I:%M %p, %b %d, %Y"),
        "duration": "00:00:00",
        "overall_status": overall_status,
    }


# ─── Email Body ────────────────────────────────────────────────


def build_email_body(summary):
    """Build a professional HTML email body with circular progress indicator."""
    total = summary["total"]
    passed = summary["passed"]
    failed = summary["failed"]
    skipped = summary["skipped"]
    pass_pct = int(passed / total * 100) if total > 0 else 0
    fail_pct = int(failed / total * 100) if total > 0 else 0
    skip_pct = 100 - pass_pct - fail_pct

    is_green = failed == 0
    status_label = summary["overall_status"]

    if is_green:
        status_color = "#27ae60"
        status_bg = "#e8f8f0"
        status_border = "#27ae60"
    else:
        status_color = "#e74c3c"
        status_bg = "#fdf0ef"
        status_border = "#e74c3c"

    # Build CSS conic-gradient for the ring
    if total > 0:
        gradient_parts = []
        pos = 0
        if passed > 0:
            end = pos + pass_pct
            gradient_parts.append(f"#27ae60 {pos}% {end}%")
            pos = end
        if failed > 0:
            end = pos + fail_pct
            gradient_parts.append(f"#e74c3c {pos}% {end}%")
            pos = end
        if skipped > 0 or pos < 100:
            gradient_parts.append(f"#f39c12 {pos}% 100%")
        gradient = ", ".join(gradient_parts)
    else:
        gradient = "#ddd 0% 100%"

    # Client/env from .env
    client = os.environ.get("CLIENT", "STC")
    env = os.environ.get("ENV", "QE")

    html = f"""\
<html>
<head>
<style>
    body {{ margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; background: #f5f6fa; }}
    .container {{ max-width: 680px; margin: 0 auto; background: #ffffff; }}
    .exec-bar {{ background: #f8f9fc; padding: 16px 32px; border-bottom: 1px solid #e8eaf0; }}
    .exec-title {{ font-size: 18px; font-weight: 600; color: #1a237e; margin: 0; }}
    .exec-meta {{ font-size: 12px; color: #6b7280; margin-top: 6px; }}
    .exec-meta span {{ margin-right: 16px; }}
    .status-badge {{ display: inline-block; padding: 2px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; letter-spacing: 0.5px; }}
    .content {{ padding: 24px 32px; }}
    .stats-row {{ display: table; width: 100%; }}
    .stats-left {{ display: table-cell; width: 140px; vertical-align: middle; text-align: center; }}
    .stats-right {{ display: table-cell; vertical-align: middle; padding-left: 32px; }}
    .ring {{ width: 110px; height: 110px; border-radius: 50%; background: conic-gradient({gradient}); display: inline-flex; align-items: center; justify-content: center; }}
    .ring-inner {{ width: 80px; height: 80px; border-radius: 50%; background: #fff; display: flex; align-items: center; justify-content: center; flex-direction: column; }}
    .ring-count {{ font-size: 28px; font-weight: 700; color: #1a237e; line-height: 1; }}
    .ring-label {{ font-size: 10px; color: #6b7280; text-transform: uppercase; letter-spacing: 1px; }}
    .stat-row {{ margin-bottom: 10px; display: table; width: 100%; }}
    .stat-dot {{ display: table-cell; width: 12px; vertical-align: middle; }}
    .stat-dot-inner {{ width: 10px; height: 10px; border-radius: 50%; display: inline-block; }}
    .stat-label {{ display: table-cell; padding-left: 8px; font-size: 14px; font-weight: 600; color: #374151; vertical-align: middle; width: 80px; }}
    .stat-count {{ display: table-cell; font-size: 14px; font-weight: 700; color: #1f2937; vertical-align: middle; width: 40px; text-align: center; }}
    .stat-pct {{ display: table-cell; font-size: 13px; color: #6b7280; vertical-align: middle; }}
    .meta-table {{ margin-top: 16px; border-top: 1px solid #e8eaf0; padding-top: 16px; }}
    .meta-table td {{ padding: 4px 0; font-size: 13px; }}
    .meta-key {{ color: #6b7280; width: 160px; text-transform: uppercase; font-size: 11px; letter-spacing: 0.5px; font-weight: 600; }}
    .meta-val {{ color: #1f2937; font-weight: 500; }}
    .failed-section {{ margin-top: 20px; }}
    .failed-header {{ background: #e74c3c; color: white; padding: 10px 16px; font-size: 14px; font-weight: 600; border-radius: 6px 6px 0 0; }}
    .failed-table {{ width: 100%; border-collapse: collapse; }}
    .failed-table th {{ background: #fdf0ef; color: #b91c1c; font-size: 12px; padding: 8px 12px; text-align: left; border-bottom: 1px solid #fecaca; }}
    .failed-table td {{ padding: 8px 12px; font-size: 12px; border-bottom: 1px solid #f3f4f6; color: #374151; }}
    .failed-table tr:nth-child(even) {{ background: #fdf9f9; }}
</style>
</head>
<body>
<div class="container">

    <!-- Header (table-based for Outlook compatibility) -->
    <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color: #1a237e;">
        <tr>
            <td style="padding: 28px 32px;">
                <div style="color: #ffffff; font-size: 22px; font-weight: 700; font-family: Segoe UI, Arial, sans-serif; letter-spacing: 0.5px;">Test Execution Report</div>
                <div style="color: #ffffff; font-size: 18px; font-weight: 700; font-family: Segoe UI, Arial, sans-serif; margin-top: 8px;">Project: STC CMP Automation Suite</div>
                <table cellpadding="0" cellspacing="0" border="0" style="margin-top: 8px;">
                    <tr>
                        <td style="background-color: #283593; padding: 5px 16px; border-radius: 4px;">
                            <span style="color: #ffffff; font-size: 15px; font-weight: 700; font-family: Segoe UI, Arial, sans-serif; letter-spacing: 0.5px;">Client: {client.title()}</span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <!-- Execution Bar -->
    <div class="exec-bar">
        <div class="exec-title">{summary['suite_name']}</div>
        <div class="exec-meta">
            <span>Started: {summary['start_time']}</span>
            <span>Duration: {summary['duration']} (hh:mm:ss)</span>
            <span class="status-badge" style="background: {status_bg}; color: {status_color}; border: 1px solid {status_border};">{status_label}</span>
        </div>
    </div>

    <!-- Content -->
    <div class="content">

        <!-- Stats Row -->
        <div class="stats-row">
            <div class="stats-left">
                <div class="ring">
                    <div class="ring-inner">
                        <div class="ring-count">{total}</div>
                        <div class="ring-label">TOTAL</div>
                    </div>
                </div>
            </div>
            <div class="stats-right">
                <div class="stat-row">
                    <div class="stat-dot"><span class="stat-dot-inner" style="background: #27ae60;"></span></div>
                    <div class="stat-label">PASSED</div>
                    <div class="stat-count">{passed}</div>
                    <div class="stat-pct">{pass_pct}%</div>
                </div>
                <div class="stat-row">
                    <div class="stat-dot"><span class="stat-dot-inner" style="background: #e74c3c;"></span></div>
                    <div class="stat-label">FAILED</div>
                    <div class="stat-count">{failed}</div>
                    <div class="stat-pct">{fail_pct}%</div>
                </div>
                <div class="stat-row">
                    <div class="stat-dot"><span class="stat-dot-inner" style="background: #f39c12;"></span></div>
                    <div class="stat-label">SKIPPED</div>
                    <div class="stat-count">{skipped}</div>
                    <div class="stat-pct">{skip_pct}%</div>
                </div>
            </div>
        </div>

        <!-- Metadata -->
        <table class="meta-table" cellspacing="0" cellpadding="0">
            <tr>
                <td class="meta-key">App Environment</td>
                <td class="meta-val">{client.title()} - {env.upper()} Environment</td>
            </tr>
            <tr>
                <td class="meta-key">Browser Testing</td>
                <td class="meta-val">Linux, Headless Chrome 108</td>
            </tr>
            <tr>
                <td class="meta-key">Report Path</td>
                <td class="meta-val">{summary['output_dir']}</td>
            </tr>
        </table>
        <p style="font-size: 12px; color: #6b7280; margin-top: 8px; font-style: italic;">For detailed report, please download the HTML report attached in this email.</p>
"""

    # Failed tests table
    if summary["failed_tests"]:
        html += """\
        <div class="failed-section">
            <div class="failed-header">Failed Test Cases</div>
            <table class="failed-table">
                <tr>
                    <th style="width: 30px;">#</th>
                    <th>Test Name</th>
                    <th>Error</th>
                </tr>
"""
        for i, ft in enumerate(summary["failed_tests"], 1):
            name = ft["name"].replace("<", "&lt;").replace(">", "&gt;")
            msg = ft["message"].replace("<", "&lt;").replace(">", "&gt;")
            html += f"""\
                <tr>
                    <td>{i}</td>
                    <td><strong>{name}</strong></td>
                    <td style="color: #991b1b;">{msg}</td>
                </tr>
"""
        html += """\
            </table>
        </div>
"""

    html += """\
    </div>

    <!-- Footer (table-based for Outlook compatibility) -->
    <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color: #f8f9fc; border-top: 1px solid #e8eaf0;">
        <tr>
            <td style="padding: 20px 32px; text-align: center;">
                <div style="font-size: 11px; color: #9ca3af; font-family: Segoe UI, Arial, sans-serif;">This e-mail (including any attachments) was auto-generated by <strong>STC CMP Automation Suite</strong>. The <strong>Airlinq Automation</strong> team in your organization added you as a recipient for test results notifications.</div>
                <div style="margin-top: 14px; font-size: 11px; color: #9ca3af; text-transform: uppercase; letter-spacing: 1px;">POWERED BY</div>
                <div style="font-size: 16px; font-weight: 700; color: #4facfe; margin-top: 8px; letter-spacing: 1px; font-family: Segoe UI, Arial, sans-serif;"><strong>AIRLINQ AUTOMATION</strong></div>
            </td>
        </tr>
    </table>

</div>
</body>
</html>
"""
    return html


# ─── Email Sender ──────────────────────────────────────────────


def send_email(summary):
    """Send the HTML report email. Tries configured SMTP first, falls back to local Postfix."""
    load_env()

    smtp_host = os.environ.get("SMTP_HOST", "smtp.gmail.com")
    smtp_port = int(os.environ.get("SMTP_PORT", "587"))
    smtp_user = os.environ.get("SMTP_USER", "")
    smtp_pass = os.environ.get("SMTP_PASS", "")
    email_from = os.environ.get("EMAIL_FROM", smtp_user)
    email_to = os.environ.get("EMAIL_TO", "")

    if not email_to:
        print("EMAIL_TO not set in .env — skipping email.")
        return False

    recipients = [r.strip() for r in email_to.split(",") if r.strip()]
    status_label = summary["overall_status"]
    subject = (
        f"STC Automation: {status_label} "
        f"({summary['passed']}/{summary['total']} passed) "
        f"- {summary['suite_name']}"
    )

    msg = MIMEMultipart("mixed")
    msg["Subject"] = subject
    msg["From"] = email_from
    msg["To"] = ", ".join(recipients)

    msg.attach(MIMEText(build_email_body(summary), "html"))

    # Attach combined_report.html or report.html (skip if > 20MB)
    MAX_ATTACH_MB = 20
    for report_name in ("combined_report.html", "report.html"):
        report_html = os.path.join(summary["output_dir"], report_name)
        if os.path.exists(report_html):
            size_mb = os.path.getsize(report_html) / (1024 * 1024)
            if size_mb <= MAX_ATTACH_MB:
                with open(report_html, "rb") as fh:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(fh.read())
                    encoders.encode_base64(part)
                    part.add_header(
                        "Content-Disposition", "attachment", filename=report_name
                    )
                    msg.attach(part)
                print(f"  Attached: {report_name} ({size_mb:.1f} MB)")
            else:
                print(f"  Skipped {report_name} ({size_mb:.1f} MB > {MAX_ATTACH_MB} MB limit)")
            break

    # Attach PDF report if available (skip if > 20MB)
    for pdf_name in os.listdir(summary["output_dir"]):
        if pdf_name.endswith(".pdf"):
            pdf_path = os.path.join(summary["output_dir"], pdf_name)
            size_mb = os.path.getsize(pdf_path) / (1024 * 1024)
            if size_mb <= MAX_ATTACH_MB:
                with open(pdf_path, "rb") as fh:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(fh.read())
                    encoders.encode_base64(part)
                    part.add_header(
                        "Content-Disposition", "attachment", filename=pdf_name
                    )
                    msg.attach(part)
                print(f"  Attached: {pdf_name} ({size_mb:.1f} MB)")
            else:
                print(f"  Skipped {pdf_name} ({size_mb:.1f} MB > {MAX_ATTACH_MB} MB limit)")
            break

    # Try configured SMTP first
    if smtp_user and smtp_pass:
        try:
            with smtplib.SMTP(smtp_host, smtp_port, timeout=10) as server:
                server.ehlo()
                server.starttls()
                server.ehlo()
                server.login(smtp_user, smtp_pass)
                server.sendmail(email_from, recipients, msg.as_string())
            print(f"Email sent via {smtp_host} to: {', '.join(recipients)}")
            return True
        except Exception as exc:
            print(f"SMTP send failed ({smtp_host}): {exc}")
            print("Trying local Postfix fallback...")

    # Fallback: local Postfix (localhost:25)
    try:
        with smtplib.SMTP("localhost", 25, timeout=10) as server:
            server.sendmail(email_from, recipients, msg.as_string())
        print(f"Email sent via Postfix to: {', '.join(recipients)}")
        return True
    except Exception as exc:
        print(f"Local Postfix also failed: {exc}")
        return False


# ─── CLI ───────────────────────────────────────────────────────


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

    print(f"Test Results: {summary['passed']}/{summary['total']} passed, "
          f"{summary['failed']} failed")
    send_email(summary)


if __name__ == "__main__":
    main()
