#!/usr/bin/env python3
"""
STC Automation – Central Test Runner
=====================================
Reads tasks.csv for suite ordering, runs Robot Framework suites sequentially,
then merges reports with rebot.  All XML, HTML, and screenshot artifacts are
collected into a single timestamped folder under reports/.

Usage:
    python run_tests.py                                            # all tasks.csv suites
    python run_tests.py --e2e                                      # Flow A: E2E without usage (17 steps)
    python run_tests.py --e2e-with-usage                           # Flow B: E2E with usage (20 steps)
    python run_tests.py --e2e --browser headlesschrome             # E2E headless
    python run_tests.py --e2e-with-usage --browser headlesschrome  # Flow B headless
    python run_tests.py --e2e --exitonfailure                      # stop on first fail
    python run_tests.py tests/login_tests.robot                    # specific suite
    python run_tests.py --suite Login                               # by suite name
    python run_tests.py --include smoke                             # by tag
    python run_tests.py --env staging --browser firefox             # overrides

Re-run only tests that FAILED in a previous run (Robot --rerunfailed):
    python run_tests.py tests/rule_engine_tests.robot --rerunfailed reports/2026-03-25_13-33-19/output_1_rule_engine_tests.xml
    python run_tests.py --suite "Rule Engine" --rerunfailed reports/2026-03-25_13-33-19
    # Directory: uses output_<n>_<suite_stem>.xml per suite, or combined_output.xml if present.

E2E partial runs (skip earlier steps by passing variables):
    python run_tests.py --e2e --test "Step 16*" --test "Step 17*" ^
        --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 ^
        --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 ^
        --variable E2E_ORDER_ID:101076 ^
        --variable E2E_EC_ID:29421 ^
        --variable E2E_BU_ID:29422

    python run_tests.py --e2e-with-usage --test "Step 16a*" --test "Step 17*" ^
        --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 ^
        --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 ^
        --variable E2E_ORDER_ID:101076 ^
        --variable E2E_EC_ID:29421 ^
        --variable E2E_BU_ID:29422

Variables needed when skipping steps:
    E2E_EC_NAME    - EC account name       (from Step 1)
    E2E_BU_NAME    - BU account name       (from Step 1)
    E2E_ORDER_ID   - Order ID              (from Step 7)
    E2E_EC_ID      - EC account DB ID      (from Step 8)
    E2E_BU_ID      - BU account DB ID      (from Step 8)
    E2E_IMSI_DATA  - list of {imsi,msisdn} (from Step 16, needed for 16a)
"""

import argparse
import csv
import fnmatch
import glob
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime

from bug_reporter import generate_bug_reports
from send_report import parse_output_xml, send_email

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
TASKS_CSV = os.path.join(ROOT_DIR, "tasks.csv")
REPORTS_DIR = os.path.join(ROOT_DIR, "reports")
# RuleEngineTab2 / ReTriggerDebug append NDJSON here when set (so logs live with output.xml).
DEBUG_SESSION_LOG_ENV = "STC_DEBUG_SESSION_LOG"
DEBUG_SESSION_LOG_NAME = "debug-7a554c.log"
# STCReportListener reads this env-var to locate the timestamped report folder.
STC_REPORT_FOLDER_ENV = "STC_REPORT_FOLDER"
# Path to the RF listener (registered via --listener on every robot/pabot call).
LISTENER_PATH = os.path.join(ROOT_DIR, "libraries", "STCReportListener.py")


def _child_env(report_folder, suite_path=""):
    env = os.environ.copy()
    # Only set debug log for Rule Engine suites — not needed for others
    if "rule_engine" in os.path.basename(suite_path).lower():
        debug_dir = os.path.join(report_folder, "Rule_Engine")
        os.makedirs(debug_dir, exist_ok=True)
        env[DEBUG_SESSION_LOG_ENV] = os.path.join(debug_dir, DEBUG_SESSION_LOG_NAME)
    # Expose report folder so STCReportListener can find it inside the subprocess.
    env[STC_REPORT_FOLDER_ENV] = report_folder
    return env
SEED_FILE       = os.path.join(ROOT_DIR, "variables", ".run_seed.json")
E2E_SUITE       = os.path.join(ROOT_DIR, "tests", "e2e_flow.robot")
E2E_USAGE_SUITE = os.path.join(ROOT_DIR, "tests", "e2e_flow_with_usage.robot")
CRUD_SUITE      = os.path.join(ROOT_DIR, "tests", "role_user_crud_tests.robot")
SANITY_SUITE    = os.path.join(ROOT_DIR, "tests", "sanity_tests.robot")


def clear_seed():
    if os.path.exists(SEED_FILE):
        os.remove(SEED_FILE)


def create_report_folder(label=""):
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    folder_name = f"{timestamp}_{label}" if label else timestamp
    folder = os.path.join(REPORTS_DIR, folder_name)
    os.makedirs(folder, exist_ok=True)
    return folder


def resolve_rerunfailed_xml(args, suite_index, suite_rel_path):
    """
    Resolve --rerunfailed to an absolute path for Robot's --rerunfailed.

    - If args.rerunfailed is a file (.xml): use it for every suite (e.g. combined_output.xml).
    - If it is a directory: prefer output_<index>_<stem>.xml, else any output_*_<stem>.xml,
      else combined_output.xml in that folder.
    """
    if not getattr(args, "rerunfailed", None):
        return None
    raw = str(args.rerunfailed).strip()
    if not raw:
        return None
    path = os.path.normpath(raw if os.path.isabs(raw) else os.path.join(ROOT_DIR, raw))
    suite_rel_path = suite_rel_path.replace("\\", "/")
    stem = os.path.splitext(os.path.basename(suite_rel_path))[0]

    if os.path.isfile(path):
        return os.path.abspath(path)

    if os.path.isdir(path):
        exact = os.path.join(path, f"output_{suite_index}_{stem}.xml")
        if os.path.isfile(exact):
            return os.path.abspath(exact)
        candidates = sorted(glob.glob(os.path.join(path, f"output_*_{stem}.xml")))
        if candidates:
            return os.path.abspath(candidates[0])
        combined = os.path.join(path, "combined_output.xml")
        if os.path.isfile(combined):
            return os.path.abspath(combined)

    print(f"  WARNING: --rerunfailed could not resolve for suite {suite_rel_path}: {path}")
    return None


def resolve_rerunfailed_e2e(args):
    """Previous E2E run stores output as output.xml in the report folder."""
    if not getattr(args, "rerunfailed", None):
        return None
    raw = str(args.rerunfailed).strip()
    if not raw:
        return None
    path = os.path.normpath(raw if os.path.isabs(raw) else os.path.join(ROOT_DIR, raw))
    if os.path.isfile(path):
        return os.path.abspath(path)
    if os.path.isdir(path):
        out = os.path.join(path, "output.xml")
        if os.path.isfile(out):
            return os.path.abspath(out)
    print(f"  WARNING: --rerunfailed could not resolve E2E output: {path}")
    return None


def read_tasks():
    if not os.path.exists(TASKS_CSV):
        return []
    with open(TASKS_CSV, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return [row for row in reader]


def suite_has_tag_matching_include(suite_rel_path, include_pattern):
    """True if *suite_rel_path* has at least one ``[Tags]`` cell whose tags match *include_pattern*.

    Uses glob rules like Robot's ``--include`` (case-insensitive). If parsing fails or the file is
    not a local ``.robot`` suite, returns True so we still run (safe default). Skipping empty matches
    avoids Robot exit 252 ("no tests matching tag") for unrelated suites (e.g. ``--include Login``).
    """
    if not include_pattern or not str(include_pattern).strip():
        return True
    pattern = str(include_pattern).strip()
    if pattern == "*":
        return True
    path = os.path.join(ROOT_DIR, suite_rel_path.replace("/", os.sep))
    if not path.endswith(".robot") or not os.path.isfile(path):
        return True
    pat = pattern.lower()

    def tag_matches(tag):
        t = tag.strip().lower()
        if not t:
            return False
        return fnmatch.fnmatch(t, pat)

    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                stripped = line.strip()
                if not stripped.startswith("[Tags]"):
                    continue
                rest = stripped[6:].strip()
                if not rest:
                    continue
                for tag in rest.split():
                    if tag_matches(tag):
                        return True
        return False
    except OSError:
        return True


def resolve_suites_from_tasks(tasks, suite_filter=None, api_only=False, ui_only=False, skip_modules=None):
    skip_set = {s.strip().lower() for s in (skip_modules or [])}
    seen = set()
    suites = []
    for row in tasks:
        suite_file = row.get("suite_file", "").strip()
        module = row.get("module", "").strip()
        if not suite_file:
            continue
        if module.lower() in skip_set:
            continue
        if suite_filter and module.lower() != suite_filter.lower():
            continue
        is_api = suite_file.startswith("tests/API_") or module.lower() == "api"
        if api_only and not is_api:
            continue
        if ui_only and is_api:
            continue
        if suite_file not in seen:
            seen.add(suite_file)
            suites.append(suite_file)
    return suites


def build_robot_command(suite_path, report_folder, index, args, is_api=False):
    cmd = [sys.executable, "-m", "robot"]

    output_name = f"output_{index}_{os.path.splitext(os.path.basename(suite_path))[0]}.xml"
    cmd += ["--outputdir", report_folder]
    cmd += ["--output", output_name]
    cmd += ["--log", "NONE"]
    cmd += ["--report", "NONE"]

    if os.path.isfile(LISTENER_PATH):
        cmd += ["--listener", LISTENER_PATH]

    cmd += ["--variable", f"ENV:{args.env}"]

    if not is_api:
        if args.browser:
            cmd += ["--variable", f"BROWSER_OVERRIDE:{args.browser}"]

    if args.include:
        cmd += ["--include", args.include]
    if args.exclude:
        cmd += ["--exclude", args.exclude]

    for t in args.test or []:
        cmd += ["--test", t]

    for pat in getattr(args, "skip_test", None) or []:
        cmd += ["--prerunmodifier",
                f"{os.path.join(ROOT_DIR, 'libraries', 'SkipTestsByName.py')}:{pat}"]

    if args.exitonfailure:
        cmd += ["--exitonfailure"]

    for var in args.variable or []:
        cmd += ["--variable", var]

    rf = resolve_rerunfailed_xml(args, index, suite_path)
    if rf:
        cmd += ["--rerunfailed", rf]

    cmd.append(os.path.join(ROOT_DIR, suite_path))
    return cmd


def build_e2e_command(report_folder, args, suite_path=None):
    cmd = [sys.executable, "-m", "robot"]
    cmd += ["--outputdir", report_folder]
    cmd += ["--output", "output.xml"]
    cmd += ["--log", "NONE"]
    cmd += ["--report", "NONE"]

    if os.path.isfile(LISTENER_PATH):
        cmd += ["--listener", LISTENER_PATH]

    cmd += ["--variable", f"ENV:{args.env}"]

    if args.browser:
        cmd += ["--variable", f"BROWSER_OVERRIDE:{args.browser}"]

    if args.exitonfailure:
        cmd += ["--exitonfailure"]

    for t in args.test or []:
        cmd += ["--test", t]

    for var in args.variable or []:
        cmd += ["--variable", var]

    rf = resolve_rerunfailed_e2e(args)
    if rf:
        cmd += ["--rerunfailed", rf]

    cmd.append(suite_path or E2E_SUITE)
    return cmd



def run_suites(suites, report_folder, args):
    outputs = []
    for idx, suite_path in enumerate(suites, start=1):
        is_api = "API_" in os.path.basename(suite_path)
        cmd = build_robot_command(suite_path, report_folder, idx, args, is_api)

        print(f"\n{'='*60}")
        print(f"  Running [{idx}/{len(suites)}]: {suite_path}")
        print(f"{'='*60}")
        print(f"  Command: {' '.join(cmd)}\n")

        result = subprocess.run(cmd, cwd=ROOT_DIR, env=_child_env(report_folder, suite_path))
        output_name = f"output_{idx}_{os.path.splitext(os.path.basename(suite_path))[0]}.xml"
        output_path = os.path.join(report_folder, output_name)
        if os.path.exists(output_path):
            outputs.append(output_path)

        if result.returncode == 252:
            if args.include or args.test:
                print("  INFO: No tests matched filters in this suite (Robot exit 252).")
            else:
                print(f"  WARNING: Suite exited with code {result.returncode}")
        elif result.returncode not in (0, 1):
            print(f"  WARNING: Suite exited with code {result.returncode}")

    return outputs


def run_e2e(report_folder, args, suite_path=None):
    suite_path = suite_path or E2E_SUITE
    cmd = build_e2e_command(report_folder, args, suite_path)
    suite_label = os.path.relpath(suite_path, ROOT_DIR)

    print(f"\n{'='*60}")
    print(f"  Running E2E Flow: {suite_label}")
    print(f"{'='*60}")
    print(f"  Command: {' '.join(cmd)}\n")

    result = subprocess.run(cmd, cwd=ROOT_DIR, env=_child_env(report_folder))
    output_path = os.path.join(report_folder, "output.xml")
    outputs = [output_path] if os.path.exists(output_path) else []

    if result.returncode not in (0, 1):
        print(f"  WARNING: E2E exited with code {result.returncode}")

    return outputs


def collect_stray_artifacts(report_folder):
    """Move any stray .png, .xml, .html result files from outside reports/ into
    the timestamped report folder.  Scans the project root and tests/ directory."""
    EXTENSIONS = ("*.png", "*.xml", "*.html")
    SKIP_FILES = {"tasks.csv"}
    scan_dirs = [
        ROOT_DIR,
        os.path.join(ROOT_DIR, "tests"),
    ]

    collected = 0
    for scan_dir in scan_dirs:
        if not os.path.isdir(scan_dir):
            continue
        for pattern in EXTENSIONS:
            for filepath in glob.glob(os.path.join(scan_dir, pattern)):
                basename = os.path.basename(filepath)
                if basename in SKIP_FILES:
                    continue
                # Don't move files already inside the reports directory
                if os.path.commonpath([filepath, REPORTS_DIR]) == REPORTS_DIR:
                    continue
                dest = os.path.join(report_folder, basename)
                # Avoid overwriting — append suffix if name already exists
                if os.path.exists(dest):
                    name, ext = os.path.splitext(basename)
                    counter = 1
                    while os.path.exists(dest):
                        dest = os.path.join(report_folder, f"{name}_{counter}{ext}")
                        counter += 1
                try:
                    shutil.move(filepath, dest)
                    collected += 1
                except Exception as e:
                    print(f"  WARNING: Could not move {filepath}: {e}")
    if collected:
        print(f"  Collected {collected} stray artifact(s) into report folder.")


def organize_report_folder(report_folder):
    """Move stray files at report root into proper subfolders.

    - selenium-screenshot-*.png → _stray_screenshots/
    - debug-*.log → _debug/
    - *_dom_probe_*.json → _debug/
    - sanity_report.csv → Sanity/
    - stc_test_data.json → kept at root (used by PDF generator)
    - billing/ → kept as-is (E2E invoice artifacts)
    """
    if not os.path.isdir(report_folder):
        return

    moved = 0

    # ── Move stray screenshots ───────────────────────────────────────
    stray_pngs = glob.glob(os.path.join(report_folder, "selenium-screenshot-*.png"))
    if stray_pngs:
        stray_dir = os.path.join(report_folder, "_stray_screenshots")
        os.makedirs(stray_dir, exist_ok=True)
        for png in stray_pngs:
            try:
                shutil.move(png, os.path.join(stray_dir, os.path.basename(png)))
                moved += 1
            except Exception:
                pass

    # ── Move any stray debug/probe files still at root (backward compat) ──
    debug_files = glob.glob(os.path.join(report_folder, "debug-*.log"))
    probe_files = glob.glob(os.path.join(report_folder, "*_dom_probe_*.json"))
    for f in debug_files:
        dest_dir = os.path.join(report_folder, "Rule_Engine")
        os.makedirs(dest_dir, exist_ok=True)
        try:
            shutil.move(f, os.path.join(dest_dir, os.path.basename(f)))
            moved += 1
        except Exception:
            pass
    for f in probe_files:
        dest_dir = os.path.join(report_folder, "Ip_Pool")
        os.makedirs(dest_dir, exist_ok=True)
        try:
            shutil.move(f, os.path.join(dest_dir, os.path.basename(f)))
            moved += 1
        except Exception:
            pass

    # ── Move sanity_report.csv into Sanity/ if at root ───────────────
    sanity_csv = os.path.join(report_folder, "sanity_report.csv")
    if os.path.exists(sanity_csv):
        sanity_dir = os.path.join(report_folder, "Sanity")
        os.makedirs(sanity_dir, exist_ok=True)
        try:
            shutil.move(sanity_csv, os.path.join(sanity_dir, "sanity_report.csv"))
            moved += 1
        except Exception:
            pass

    if moved:
        print(f"  Organized {moved} stray file(s) into subfolders.")


def patch_html_screenshot_refs(report_folder):
    """
    Rewrite `selenium-screenshot-N.png` references in log.html / combined_log.html
    to the renamed module-subfolder paths.

    STCReportListener moves each PNG from the report root into the module subfolder
    with a new name (e.g. TC_CSRJ_100_step_01_PASS.png) and records the old→new
    mapping in `.stc_ss_rename_map.json`. Robot's log.html, however, embeds the
    original filename — so after the move the inline images are broken links.
    This post-processing step rewrites those references to the new paths.
    """
    map_path = os.path.join(report_folder, ".stc_ss_rename_map.json")
    if not os.path.isfile(map_path):
        return
    try:
        with open(map_path, "r", encoding="utf-8") as fh:
            rename_map = json.load(fh) or {}
    except (OSError, json.JSONDecodeError):
        return
    if not rename_map:
        return

    candidates = ["log.html", "combined_log.html", "report.html", "combined_report.html"]
    patched_any = False
    for fname in candidates:
        fpath = os.path.join(report_folder, fname)
        if not os.path.isfile(fpath):
            continue
        try:
            with open(fpath, "r", encoding="utf-8") as fh:
                html = fh.read()
        except OSError:
            continue
        changed = False
        for old_name, new_rel in rename_map.items():
            if old_name in html:
                html = html.replace(old_name, new_rel)
                changed = True
        if changed:
            try:
                with open(fpath, "w", encoding="utf-8") as fh:
                    fh.write(html)
                patched_any = True
            except OSError as exc:
                print(f"  WARNING: could not patch {fpath}: {exc}")
    if patched_any:
        print(f"  Patched screenshot refs in log.html / combined_log.html.")


def merge_reports(outputs, report_folder):
    if not outputs:
        print("\nNo outputs to merge.")
        return

    # Validate each XML before merging — skip corrupt/truncated files
    import xml.etree.ElementTree as ET
    valid_outputs = []
    for xml_path in outputs:
        if not os.path.exists(xml_path):
            continue
        try:
            ET.parse(xml_path)
            valid_outputs.append(xml_path)
        except ET.ParseError:
            print(f"  WARNING: Skipping corrupt XML: {os.path.basename(xml_path)}")

    if not valid_outputs:
        print("\nNo valid outputs to merge.")
        return

    dst_output = os.path.join(report_folder, "combined_output.xml")
    dst_log = os.path.join(report_folder, "combined_log.html")
    dst_report = os.path.join(report_folder, "combined_report.html")

    cmd = [
        sys.executable, "-m", "robot.rebot",
        "--output", dst_output,
        "--log", dst_log,
        "--report", dst_report,
    ] + valid_outputs

    skipped = len(outputs) - len(valid_outputs)
    msg = f"\n  Generating combined report from {len(valid_outputs)} output(s)..."
    if skipped:
        msg += f" ({skipped} corrupt XML(s) skipped)"
    print(msg)
    result = subprocess.run(cmd, cwd=ROOT_DIR)
    if result.returncode not in (0, 1):
        print(f"  WARNING: rebot exited with code {result.returncode}")
    else:
        print(f"  Combined report generated successfully.")


def generate_pdf_report(report_folder, args):
    """Generate execution_report.pdf via STCPDFReport after the run completes."""
    try:
        sys.path.insert(0, ROOT_DIR)
        from libraries.STCPDFReport import generate_pdf  # noqa: PLC0415
        env = (getattr(args, "env", None) or "dev").strip()
        print(f"\n  Generating PDF execution report…")
        pdf_path = generate_pdf(report_folder, env=env)
        if pdf_path:
            print(f"  PDF report : {pdf_path}")
        else:
            print("  WARNING: PDF generation returned no output (check STCPDFReport warnings above).")
    except Exception as exc:
        print(f"  WARNING: PDF generation failed: {exc}")


def print_summary(report_folder):
    """Print a summary of all files saved in the report folder."""
    print(f"\n{'='*60}")
    print(f"  REPORT SUMMARY")
    print(f"  Folder: {report_folder}")
    print(f"{'='*60}")

    xml_files = []
    html_files = []
    png_files = []
    other_files = []

    for f in sorted(os.listdir(report_folder)):
        ext = os.path.splitext(f)[1].lower()
        if ext == ".xml":
            xml_files.append(f)
        elif ext == ".html":
            html_files.append(f)
        elif ext == ".png":
            png_files.append(f)
        else:
            other_files.append(f)

    if xml_files:
        print(f"\n  XML outputs ({len(xml_files)}):")
        for f in xml_files:
            print(f"    - {f}")

    if html_files:
        print(f"\n  HTML reports ({len(html_files)}):")
        for f in html_files:
            print(f"    - {f}")

    if png_files:
        print(f"\n  Screenshots ({len(png_files)}):")
        for f in png_files:
            print(f"    - {f}")

    if other_files:
        print(f"\n  Other files ({len(other_files)}):")
        for f in other_files:
            print(f"    - {f}")

    total = len(xml_files) + len(html_files) + len(png_files) + len(other_files)
    print(f"\n  Total: {total} file(s)")
    print(f"{'='*60}\n")


def run_sanity(report_folder, args):
    """Run the sanity suite — sequential (robot) or parallel (pabot)."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    sanity_report_dir = report_folder

    base_vars = [
        f"ENV:{args.env}",
        f"SANITY_REPORT_DIR:{sanity_report_dir}",
    ]
    if args.browser:
        base_vars.append(f"BROWSER_OVERRIDE:{args.browser}")
    for var in args.variable or []:
        base_vars.append(var)

    processes = getattr(args, "parallel", 1)

    if processes > 1:
        # ── Parallel run via pabot ─────────────────────────────────────
        try:
            import pabot  # noqa: F401
        except ImportError:
            print("  ERROR: pabot not installed. Run: pip install robotframework-pabot")
            print("  Falling back to sequential execution.")
            processes = 1

    if processes > 1:
        cmd = [sys.executable, "-m", "pabot.pabot"]
        cmd += ["--processes", str(processes)]
        cmd += ["--outputdir", report_folder]
        cmd += ["--output", "output_sanity.xml"]
        cmd += ["--log", "NONE"]
        cmd += ["--report", "NONE"]
        if os.path.isfile(LISTENER_PATH):
            cmd += ["--listener", LISTENER_PATH]
        for v in base_vars:
            cmd += ["--variable", v]
        if args.test:
            for t in args.test:
                cmd += ["--test", t]
        rf = resolve_rerunfailed_xml(args, 1, "tests/sanity_tests.robot")
        if rf:
            cmd += ["--rerunfailed", rf]
        cmd.append(SANITY_SUITE)
        print(f"  Command: {' '.join(cmd)}\n")
        result = subprocess.run(cmd, cwd=ROOT_DIR, env=_child_env(report_folder))
    else:
        # ── Sequential run via robot ───────────────────────────────────
        cmd = [sys.executable, "-m", "robot"]
        cmd += ["--outputdir", report_folder]
        cmd += ["--output", "output_sanity.xml"]
        cmd += ["--log", "NONE"]
        cmd += ["--report", "NONE"]
        if os.path.isfile(LISTENER_PATH):
            cmd += ["--listener", LISTENER_PATH]
        for v in base_vars:
            cmd += ["--variable", v]
        if args.test:
            for t in args.test:
                cmd += ["--test", t]
        if args.include:
            cmd += ["--include", args.include]
        if args.exitonfailure:
            cmd += ["--exitonfailure"]
        rf = resolve_rerunfailed_xml(args, 1, "tests/sanity_tests.robot")
        if rf:
            cmd += ["--rerunfailed", rf]
        cmd.append(SANITY_SUITE)
        print(f"  Command: {' '.join(cmd)}\n")
        result = subprocess.run(cmd, cwd=ROOT_DIR, env=_child_env(report_folder))

    output_path = os.path.join(report_folder, "output_sanity.xml")
    outputs = [output_path] if os.path.exists(output_path) else []
    if result.returncode not in (0, 1):
        print(f"  WARNING: Sanity suite exited with code {result.returncode}")
    return outputs


def main():
    parser = argparse.ArgumentParser(description="STC Automation Test Runner")
    parser.add_argument("suites", nargs="*", help="Suite file path(s)")
    parser.add_argument("--env", default="dev", help="Environment (dev/staging/prod)")
    parser.add_argument("--browser", default=None, help="Browser override (chrome/headlesschrome/firefox)")
    parser.add_argument("--test", action="append", help="Test name filter (repeatable)")
    parser.add_argument("--include", default=None, help="Include tag")
    parser.add_argument("--exclude", default=None, help="Exclude tag")
    parser.add_argument("--skip-suite", action="append", default=[], dest="skip_suite",
                        help="Module name to skip entirely — no browser launch (repeatable)")
    parser.add_argument("--skip-test", action="append", default=[], dest="skip_test",
                        help="Test name pattern to skip, e.g. TC_LBL_014* (repeatable)")
    parser.add_argument("--suite", default=None, help="Suite name (resolved from tasks.csv)")
    parser.add_argument("--tasks", action="store_true", help="Run all from tasks.csv")
    parser.add_argument("--api", action="store_true", help="Run only API suites")
    parser.add_argument("--ui", action="store_true", help="Run only UI suites")
    parser.add_argument("--e2e", action="store_true", help="Run E2E Flow A without usage (tests/e2e_flow.robot)")
    parser.add_argument("--e2e-with-usage", action="store_true", dest="e2e_with_usage",
                        help="Run E2E Flow B with usage (tests/e2e_flow_with_usage.robot)")
    parser.add_argument("--with-crud", action="store_true", dest="with_crud",
                        help="After E2E, also run Role+User CRUD positive tests (tests/role_user_crud_tests.robot)")
    parser.add_argument("--sanity", action="store_true",
                        help="Run Sanity suite (tests/sanity_tests.robot)")
    parser.add_argument("--parallel", type=int, default=1, metavar="N",
                        help="Run sanity tests in parallel using pabot (N processes, default 1 = sequential)")
    parser.add_argument("--exitonfailure", action="store_true", help="Stop on first test failure")
    parser.add_argument("--variable", action="append", help="Override Robot variable (KEY:VALUE)")
    parser.add_argument("--outputdir", default=None, help="Override report output directory (e.g. reports/RUNNAME_timestamp)")
    parser.add_argument("--keep-seed", action="store_true", dest="keep_seed",
                        help="Do NOT clear .run_seed.json at the start of this run. "
                             "Use this when running a dependent suite (e.g. SIM Movement) "
                             "with data from the last E2E run.")
    parser.add_argument(
        "--rerunfailed",
        metavar="PATH",
        help="Robot --rerunfailed: PATH to a previous output .xml file, or a report folder "
             "(uses output_<n>_<suite>.xml or combined_output.xml). Only failed tests run.",
    )
    parser.add_argument("--email", action="store_true",
                        help="Send email report after test run completes")
    args = parser.parse_args()

    # So ``variables/_config_defaults.py`` matches ``-v ENV:`` when suites import Python variable files.
    os.environ["STC_AUTOMATION_ENV"] = (args.env or "dev").strip().lower()

    if not args.keep_seed:
        clear_seed()

    # ── Determine run mode and report folder ─────────────────────────
    if args.outputdir:
        report_folder = os.path.abspath(args.outputdir)
        os.makedirs(report_folder, exist_ok=True)
    else:
        is_e2e = args.e2e or args.e2e_with_usage
        if is_e2e:
            if args.e2e_with_usage:
                label = "e2e_usage_headless" if args.browser == "headlesschrome" else "e2e_usage"
            else:
                label = "e2e_headless" if args.browser == "headlesschrome" else "e2e"
            report_folder = create_report_folder(label)
        else:
            report_folder = create_report_folder()
    is_e2e = args.e2e or args.e2e_with_usage

    print(f"\n{'='*60}")
    print(f"  STC Automation — Test Runner")
    print(f"{'='*60}")
    print(f"  Environment : {args.env}")
    print(f"  Browser     : {args.browser or '(from config)'}")
    print(f"  Report Dir  : {report_folder}")
    if args.keep_seed:
        seed_exists = os.path.exists(SEED_FILE)
        print(f"  Seed        : PRESERVED{' (.run_seed.json exists)' if seed_exists else ' (WARNING: .run_seed.json not found — E2E must run first)'}")
    if getattr(args, "rerunfailed", None):
        print(f"  Re-run      : FAILED ONLY (--rerunfailed {args.rerunfailed})")

    if getattr(args, "sanity", False):
        print(f"  Mode        : Sanity Suite")
        if getattr(args, "parallel", 1) > 1:
            print(f"  Parallel    : {args.parallel} processes (pabot)")
        print(f"{'='*60}")
        outputs = run_sanity(report_folder, args)
    elif is_e2e:
        if args.e2e_with_usage:
            print(f"  Mode        : E2E Flow B (With Usage)")
            suite_path = E2E_USAGE_SUITE
        else:
            print(f"  Mode        : E2E Flow A (Without Usage)")
            suite_path = E2E_SUITE
        if getattr(args, "with_crud", False):
            print(f"  CRUD        : Role + User CRUD tests will run after E2E")
        if args.exitonfailure:
            print(f"  Options     : --exitonfailure")
        print(f"{'='*60}")
        outputs = run_e2e(report_folder, args, suite_path)

        # ── Run CRUD suite after E2E when --with-crud is specified ────────
        if getattr(args, "with_crud", False):
            print(f"\n{'='*60}")
            print(f"  Running CRUD Suite: tests/role_user_crud_tests.robot")
            print(f"{'='*60}")
            crud_args_copy = argparse.Namespace(**vars(args))
            crud_args_copy.test = []      # don't filter by --test for CRUD suite
            crud_cmd = build_robot_command(
                os.path.relpath(CRUD_SUITE, ROOT_DIR),
                report_folder,
                len(outputs) + 1,
                crud_args_copy,
            )
            print(f"  Command: {' '.join(crud_cmd)}\n")
            crud_result = subprocess.run(
                crud_cmd, cwd=ROOT_DIR, env=_child_env(report_folder)
            )
            crud_output_name = f"output_{len(outputs)+1}_role_user_crud_tests.xml"
            crud_output_path = os.path.join(report_folder, crud_output_name)
            if os.path.exists(crud_output_path):
                outputs.append(crud_output_path)
            if crud_result.returncode not in (0, 1):
                print(f"  WARNING: CRUD suite exited with code {crud_result.returncode}")
    else:
        if args.suites:
            suites = args.suites
        elif args.suite or args.tasks or args.api or args.ui:
            tasks = read_tasks()
            suites = resolve_suites_from_tasks(
                tasks,
                suite_filter=args.suite,
                api_only=args.api,
                ui_only=args.ui,
                skip_modules=args.skip_suite,
            )
        else:
            tasks = read_tasks()
            if tasks:
                suites = resolve_suites_from_tasks(tasks, skip_modules=args.skip_suite)
            else:
                print("No tasks.csv found and no suites specified. Nothing to run.")
                sys.exit(1)

        if not suites:
            print("No suites matched the given criteria.")
            sys.exit(1)

        if args.include:
            before = len(suites)
            suites = [s for s in suites if suite_has_tag_matching_include(s, args.include)]
            skipped = before - len(suites)
            if skipped:
                print(
                    f"  Tag filter: skipping {skipped} suite(s) with no [Tags] matching "
                    f"--include {args.include!r} (avoids Robot exit 252 on those files)."
                )
            if not suites:
                print(
                    f"No remaining suites contain tags matching --include {args.include!r}. Nothing to run."
                )
                sys.exit(1)

        print(f"  Mode        : Suite Runner")
        print(f"  Suites ({len(suites)}):")
        for s in suites:
            print(f"    - {s}")
        print(f"{'='*60}")

        outputs = run_suites(suites, report_folder, args)

    # ── Post-run: each stage is wrapped so one failure doesn't block others ──
    collect_stray_artifacts(report_folder)

    try:
        merge_reports(outputs, report_folder)
    except Exception as exc:
        print(f"  WARNING: Report merge failed: {exc}")

    collect_stray_artifacts(report_folder)  # catch anything rebot may have created
    organize_report_folder(report_folder)

    try:
        patch_html_screenshot_refs(report_folder)
    except Exception as exc:
        print(f"  WARNING: HTML screenshot patch failed: {exc}")

    try:
        generate_pdf_report(report_folder, args)
    except Exception as exc:
        print(f"  WARNING: PDF generation failed: {exc}")

    # ── Bug reports: generate for any failures ────────────────────
    try:
        env_url = _resolve_env_url(args.env)
        bugs_dir = os.path.join(ROOT_DIR, "bugs")
        generate_bug_reports(report_folder, bugs_dir=bugs_dir, env_url=env_url)
    except Exception as exc:
        print(f"  WARNING: Bug report generation failed: {exc}")

    # ── Email report (when --email flag is used) ─────────────────
    if getattr(args, "email", False):
        try:
            summary = parse_output_xml(report_folder)
            if summary:
                print(f"\n  Sending email report...")
                send_email(summary)
            else:
                print("  WARNING: No output.xml found — skipping email notification.")
        except Exception as exc:
            print(f"  WARNING: Email sending failed: {exc}")

    print_summary(report_folder)


def _resolve_env_url(env):
    """Read BASE_URL from the environment config JSON file."""
    config_path = os.path.join(ROOT_DIR, "config", f"{env}.json")
    if not os.path.exists(config_path):
        return ""
    try:
        with open(config_path, encoding="utf-8") as f:
            config = json.load(f)
        return config.get("BASE_URL", "")
    except (json.JSONDecodeError, OSError):
        return ""


if __name__ == "__main__":
    main()
