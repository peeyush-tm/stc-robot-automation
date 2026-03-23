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
import glob
import os
import shutil
import subprocess
import sys
from datetime import datetime

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
TASKS_CSV = os.path.join(ROOT_DIR, "tasks.csv")
REPORTS_DIR = os.path.join(ROOT_DIR, "reports")
SEED_FILE       = os.path.join(ROOT_DIR, "variables", ".run_seed.json")
E2E_SUITE       = os.path.join(ROOT_DIR, "tests", "e2e_flow.robot")
E2E_USAGE_SUITE = os.path.join(ROOT_DIR, "tests", "e2e_flow_with_usage.robot")
CRUD_SUITE      = os.path.join(ROOT_DIR, "tests", "role_user_crud_tests.robot")
SANITY_SUITE    = os.path.join(ROOT_DIR, "tests", "sanity_tests.robot")
FRAMEWORK_SUITE = os.path.join(ROOT_DIR, "bin", "STCFramework.robot")


def clear_seed():
    if os.path.exists(SEED_FILE):
        os.remove(SEED_FILE)


def create_report_folder(label=""):
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    folder_name = f"{timestamp}_{label}" if label else timestamp
    folder = os.path.join(REPORTS_DIR, folder_name)
    os.makedirs(folder, exist_ok=True)
    return folder


def read_tasks():
    if not os.path.exists(TASKS_CSV):
        return []
    with open(TASKS_CSV, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return [row for row in reader]


def resolve_suites_from_tasks(tasks, suite_filter=None, api_only=False, ui_only=False):
    seen = set()
    suites = []
    for row in tasks:
        suite_file = row.get("suite_file", "").strip()
        module = row.get("module", "").strip()
        if not suite_file:
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

    if args.exitonfailure:
        cmd += ["--exitonfailure"]

    for var in args.variable or []:
        cmd += ["--variable", var]

    cmd.append(os.path.join(ROOT_DIR, suite_path))
    return cmd


def build_e2e_command(report_folder, args, suite_path=None):
    cmd = [sys.executable, "-m", "robot"]
    cmd += ["--outputdir", report_folder]
    cmd += ["--output", "output.xml"]
    cmd += ["--log", "NONE"]
    cmd += ["--report", "NONE"]
    cmd += ["--variable", f"ENV:{args.env}"]

    if args.browser:
        cmd += ["--variable", f"BROWSER_OVERRIDE:{args.browser}"]

    if args.exitonfailure:
        cmd += ["--exitonfailure"]

    for t in args.test or []:
        cmd += ["--test", t]

    for var in args.variable or []:
        cmd += ["--variable", var]

    cmd.append(suite_path or E2E_SUITE)
    return cmd


def build_framework_command(report_folder, args):
    """Build the robot command to run STCFramework.robot (CSV-driven framework mode)."""
    cmd = [sys.executable, "-m", "robot"]
    cmd += ["--outputdir", report_folder]
    cmd += ["--output", "output_framework.xml"]
    cmd += ["--log", "NONE"]
    cmd += ["--report", "NONE"]

    cmd += ["--variable", f"ENV:{args.env}"]
    if args.browser:
        cmd += ["--variable", f"BROWSER_OVERRIDE:{args.browser}"]
    # --suite maps to SUITE_FILTER inside STCFramework.robot
    if args.suite:
        cmd += ["--variable", f"SUITE_FILTER:{args.suite}"]

    if args.include:
        cmd += ["--include", args.include]
    if args.exclude:
        cmd += ["--exclude", args.exclude]

    for t in args.test or []:
        cmd += ["--test", t]

    if args.exitonfailure:
        cmd += ["--exitonfailure"]

    for var in args.variable or []:
        cmd += ["--variable", var]

    cmd.append(FRAMEWORK_SUITE)
    return cmd


def run_framework(report_folder, args):
    """Run STCFramework.robot (CSV-driven) and return list of XML output paths."""
    cmd = build_framework_command(report_folder, args)
    suite_filter = f" [suite={args.suite}]" if args.suite else ""

    print(f"\n{'='*60}")
    print(f"  Running STCFramework.robot{suite_filter}")
    print(f"{'='*60}")
    print(f"  Command: {' '.join(cmd)}\n")

    result = subprocess.run(cmd, cwd=ROOT_DIR)
    output_path = os.path.join(report_folder, "output_framework.xml")
    outputs = [output_path] if os.path.exists(output_path) else []

    if result.returncode not in (0, 1):
        print(f"  WARNING: STCFramework exited with code {result.returncode}")
    return outputs


def run_suites(suites, report_folder, args):
    outputs = []
    for idx, suite_path in enumerate(suites, start=1):
        is_api = "API_" in os.path.basename(suite_path)
        cmd = build_robot_command(suite_path, report_folder, idx, args, is_api)

        print(f"\n{'='*60}")
        print(f"  Running [{idx}/{len(suites)}]: {suite_path}")
        print(f"{'='*60}")
        print(f"  Command: {' '.join(cmd)}\n")

        result = subprocess.run(cmd, cwd=ROOT_DIR)
        output_name = f"output_{idx}_{os.path.splitext(os.path.basename(suite_path))[0]}.xml"
        output_path = os.path.join(report_folder, output_name)
        if os.path.exists(output_path):
            outputs.append(output_path)

        if result.returncode not in (0, 1):
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

    result = subprocess.run(cmd, cwd=ROOT_DIR)
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


def merge_reports(outputs, report_folder):
    if not outputs:
        print("\nNo outputs to merge.")
        return

    dst_output = os.path.join(report_folder, "combined_output.xml")
    dst_log = os.path.join(report_folder, "combined_log.html")
    dst_report = os.path.join(report_folder, "combined_report.html")

    cmd = [
        sys.executable, "-m", "robot.rebot",
        "--output", dst_output,
        "--log", dst_log,
        "--report", dst_report,
    ] + outputs

    print(f"\n  Generating combined report from {len(outputs)} output(s)...")
    result = subprocess.run(cmd, cwd=ROOT_DIR)
    if result.returncode not in (0, 1):
        print(f"  WARNING: rebot exited with code {result.returncode}")
    else:
        print(f"  Combined report generated successfully.")


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
        for v in base_vars:
            cmd += ["--variable", v]
        if args.test:
            for t in args.test:
                cmd += ["--test", t]
        cmd.append(SANITY_SUITE)
        print(f"  Command: {' '.join(cmd)}\n")
        result = subprocess.run(cmd, cwd=ROOT_DIR)
    else:
        # ── Sequential run via robot ───────────────────────────────────
        cmd = [sys.executable, "-m", "robot"]
        cmd += ["--outputdir", report_folder]
        cmd += ["--output", "output_sanity.xml"]
        cmd += ["--log", "NONE"]
        cmd += ["--report", "NONE"]
        for v in base_vars:
            cmd += ["--variable", v]
        if args.test:
            for t in args.test:
                cmd += ["--test", t]
        if args.include:
            cmd += ["--include", args.include]
        if args.exitonfailure:
            cmd += ["--exitonfailure"]
        cmd.append(SANITY_SUITE)
        print(f"  Command: {' '.join(cmd)}\n")
        result = subprocess.run(cmd, cwd=ROOT_DIR)

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
    parser.add_argument("--suite", default=None, help="Suite name (resolved from tasks.csv)")
    parser.add_argument("--tasks", action="store_true", help="Run all from tasks.csv")
    parser.add_argument("--api", action="store_true", help="Run only API suites")
    parser.add_argument("--ui", action="store_true", help="Run only UI suites")
    parser.add_argument("--e2e", action="store_true", help="Run E2E Flow A without usage (tests/e2e_flow.robot)")
    parser.add_argument("--e2e-with-usage", action="store_true", dest="e2e_with_usage",
                        help="Run E2E Flow B with usage (tests/e2e_flow_with_usage.robot)")
    parser.add_argument("--with-crud", action="store_true", dest="with_crud",
                        help="After E2E, also run Role+User CRUD positive tests (tests/role_user_crud_tests.robot)")
    parser.add_argument("--framework", action="store_true",
                        help="Run via STCFramework.robot (CSV-driven framework mode)")
    parser.add_argument("--sanity", action="store_true",
                        help="Run Sanity suite (tests/sanity_tests.robot)")
    parser.add_argument("--parallel", type=int, default=1, metavar="N",
                        help="Run sanity tests in parallel using pabot (N processes, default 1 = sequential)")
    parser.add_argument("--exitonfailure", action="store_true", help="Stop on first test failure")
    parser.add_argument("--variable", action="append", help="Override Robot variable (KEY:VALUE)")
    parser.add_argument("--outputdir", default=None, help="Override report output directory (e.g. reports/RUNNAME_timestamp)")
    args = parser.parse_args()

    clear_seed()

    # ── Determine run mode and report folder ─────────────────────────
    if args.outputdir:
        report_folder = os.path.abspath(args.outputdir)
        os.makedirs(report_folder, exist_ok=True)
    else:
        is_e2e = args.e2e or args.e2e_with_usage
        if args.framework:
            label = f"framework_{args.suite}" if args.suite else "framework"
            report_folder = create_report_folder(label)
        elif is_e2e:
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

    if getattr(args, "framework", False):
        suite_label = f" [{args.suite}]" if args.suite else " [all active suites]"
        print(f"  Mode        : STCFramework (CSV-driven){suite_label}")
        print(f"{'='*60}")
        outputs = run_framework(report_folder, args)
    elif getattr(args, "sanity", False):
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
            crud_result = subprocess.run(crud_cmd, cwd=ROOT_DIR)
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
            )
        else:
            tasks = read_tasks()
            if tasks:
                suites = resolve_suites_from_tasks(tasks)
            else:
                print("No tasks.csv found and no suites specified. Nothing to run.")
                sys.exit(1)

        if not suites:
            print("No suites matched the given criteria.")
            sys.exit(1)

        print(f"  Mode        : Suite Runner")
        print(f"  Suites ({len(suites)}):")
        for s in suites:
            print(f"    - {s}")
        print(f"{'='*60}")

        outputs = run_suites(suites, report_folder, args)

    # ── Post-run: collect stray artifacts & generate combined report ─
    collect_stray_artifacts(report_folder)
    merge_reports(outputs, report_folder)
    collect_stray_artifacts(report_folder)  # catch anything rebot may have created
    print_summary(report_folder)


if __name__ == "__main__":
    main()
