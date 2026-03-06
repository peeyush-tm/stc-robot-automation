#!/usr/bin/env python3
"""
STC Automation – Central Test Runner
=====================================
Reads tasks.csv for suite ordering, runs Robot Framework suites sequentially,
then merges reports with rebot.

Usage:
    python run_tests.py                                  # all tasks.csv suites
    python run_tests.py tests/login_tests.robot          # specific suite
    python run_tests.py --suite Login                     # by suite name
    python run_tests.py --include smoke                   # by tag
    python run_tests.py --env staging --browser firefox   # overrides
"""

import argparse
import csv
import os
import shutil
import subprocess
import sys
from datetime import datetime

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
TASKS_CSV = os.path.join(ROOT_DIR, "tasks.csv")
REPORTS_DIR = os.path.join(ROOT_DIR, "reports")
SEED_FILE = os.path.join(ROOT_DIR, "variables", ".run_seed.json")


def clear_seed():
    if os.path.exists(SEED_FILE):
        os.remove(SEED_FILE)


def create_report_folder():
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    folder = os.path.join(REPORTS_DIR, timestamp)
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
            cmd += ["--variable", f"BROWSER:{args.browser}"]

    if args.include:
        cmd += ["--include", args.include]
    if args.exclude:
        cmd += ["--exclude", args.exclude]
    if args.test:
        cmd += ["--test", args.test]

    for var in args.variable or []:
        cmd += ["--variable", var]

    cmd.append(os.path.join(ROOT_DIR, suite_path))
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

        result = subprocess.run(cmd, cwd=ROOT_DIR)
        output_name = f"output_{idx}_{os.path.splitext(os.path.basename(suite_path))[0]}.xml"
        output_path = os.path.join(report_folder, output_name)
        if os.path.exists(output_path):
            outputs.append(output_path)

        if result.returncode not in (0, 1):
            print(f"  WARNING: Suite exited with code {result.returncode}")

    return outputs


def merge_reports(outputs, report_folder):
    if not outputs:
        print("\nNo outputs to merge.")
        return
    if len(outputs) == 1:
        src = outputs[0]
        dst_output = os.path.join(report_folder, "output.xml")
        shutil.copy2(src, dst_output)
    else:
        dst_output = os.path.join(report_folder, "output.xml")
        cmd = [
            sys.executable, "-m", "robot.rebot",
            "--merge" if len(outputs) == 1 else "--merge",
            "--output", dst_output,
            "--log", os.path.join(report_folder, "log.html"),
            "--report", os.path.join(report_folder, "report.html"),
        ] + outputs
        subprocess.run(cmd, cwd=ROOT_DIR)
        return

    rebot_cmd = [
        sys.executable, "-m", "robot.rebot",
        "--output", dst_output,
        "--log", os.path.join(report_folder, "log.html"),
        "--report", os.path.join(report_folder, "report.html"),
        dst_output,
    ]
    subprocess.run(rebot_cmd, cwd=ROOT_DIR)


def main():
    parser = argparse.ArgumentParser(description="STC Automation Test Runner")
    parser.add_argument("suites", nargs="*", help="Suite file path(s)")
    parser.add_argument("--env", default="dev", help="Environment (dev/staging/prod)")
    parser.add_argument("--browser", default=None, help="Browser override")
    parser.add_argument("--test", default=None, help="Test name filter")
    parser.add_argument("--include", default=None, help="Include tag")
    parser.add_argument("--exclude", default=None, help="Exclude tag")
    parser.add_argument("--suite", default=None, help="Suite name (resolved from tasks.csv)")
    parser.add_argument("--tasks", action="store_true", help="Run all from tasks.csv")
    parser.add_argument("--api", action="store_true", help="Run only API suites")
    parser.add_argument("--ui", action="store_true", help="Run only UI suites")
    parser.add_argument("--variable", action="append", help="Override Robot variable (KEY:VALUE)")
    args = parser.parse_args()

    clear_seed()
    report_folder = create_report_folder()

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

    print(f"\nSTC Automation — Test Runner")
    print(f"Environment : {args.env}")
    print(f"Browser     : {args.browser or '(from config)'}")
    print(f"Report Dir  : {report_folder}")
    print(f"Suites ({len(suites)}):")
    for s in suites:
        print(f"  - {s}")

    outputs = run_suites(suites, report_folder, args)
    merge_reports(outputs, report_folder)

    print(f"\n{'='*60}")
    print(f"  Reports saved to: {report_folder}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
