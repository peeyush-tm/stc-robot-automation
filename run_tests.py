"""
Test Runner — reads tasks.csv and runs all Robot Framework suites.

Reports are generated in reports/<timestamp>/ with all output files
(output.xml, log.html, report.html, screenshots) contained inside.

Usage:
    python run_tests.py                          # run ALL suites from tasks.csv
    python run_tests.py --module Login           # run only Login module
    python run_tests.py --module CSRJourney CostCenter  # run multiple modules
    python run_tests.py --suite tests/login_tests.robot # run a specific suite file
    python run_tests.py --tags smoke             # run only tests tagged 'smoke'
    python run_tests.py --dry-run                # list what would run without executing
"""

import csv
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from collections import OrderedDict

PROJECT_ROOT = Path(__file__).resolve().parent
TASKS_CSV = PROJECT_ROOT / "tasks.csv"
REPORTS_DIR = PROJECT_ROOT / "reports"


def read_tasks(csv_path: Path):
    with open(csv_path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def get_suites_in_order(tasks, module_filter=None, suite_filter=None):
    """Return an ordered dict of suite_file -> list of test_case_ids, preserving CSV order."""
    suites = OrderedDict()
    for row in tasks:
        suite = row["suite_file"].strip()
        tc_id = row["test_case_id"].strip()
        module = row["module"].strip()

        if module_filter and module not in module_filter:
            continue
        if suite_filter and suite not in suite_filter:
            continue

        suites.setdefault(suite, []).append(tc_id)
    return suites


def create_report_dir():
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    report_dir = REPORTS_DIR / timestamp
    report_dir.mkdir(parents=True, exist_ok=True)
    return report_dir


def run_suite(suite_file, test_ids, report_dir, suite_index, tag_filter=None):
    """Run a single suite file, directing all output into report_dir."""
    suite_path = PROJECT_ROOT / suite_file
    if not suite_path.exists():
        print(f"  [SKIP] Suite file not found: {suite_file}")
        return None

    suite_name = Path(suite_file).stem
    output_xml = report_dir / f"output_{suite_index}_{suite_name}.xml"

    cmd = [
        "robot",
        "--outputdir", str(report_dir),
        "--output", str(output_xml),
        "--log", "NONE",
        "--report", "NONE",
        "--loglevel", "DEBUG",
    ]

    if tag_filter:
        cmd.extend(["--include", tag_filter])

    cmd.append(str(suite_path))

    print(f"\n{'='*70}")
    print(f"  Running: {suite_file} ({len(test_ids)} tests)")
    print(f"  Output:  {output_xml.name}")
    print(f"{'='*70}")

    result = subprocess.run(cmd, cwd=str(PROJECT_ROOT))
    return output_xml if output_xml.exists() else None


def merge_reports(output_files, report_dir):
    """Merge all individual output XMLs into a single combined report."""
    if not output_files:
        print("\nNo output files to merge.")
        return

    cmd = [
        "rebot",
        "--outputdir", str(report_dir),
        "--output", "output.xml",
        "--log", "log.html",
        "--report", "report.html",
        "--loglevel", "DEBUG",
    ]
    cmd.extend([str(f) for f in output_files])

    print(f"\n{'='*70}")
    print("  Merging reports...")
    print(f"{'='*70}")

    subprocess.run(cmd, cwd=str(PROJECT_ROOT))

    print(f"\n  Combined report: {report_dir / 'report.html'}")
    print(f"  Combined log:    {report_dir / 'log.html'}")
    print(f"  Combined output: {report_dir / 'output.xml'}")


def print_summary(tasks, suites):
    total_tests = sum(len(ids) for ids in suites.values())
    print(f"\n{'='*70}")
    print(f"  STC Automation — Test Runner")
    print(f"  Total suites: {len(suites)}")
    print(f"  Total tests:  {total_tests}")
    print(f"{'='*70}")
    for i, (suite, ids) in enumerate(suites.items(), 1):
        print(f"  {i}. {suite} ({len(ids)} tests)")


def main():
    import argparse
    parser = argparse.ArgumentParser(description="STC Automation Test Runner")
    parser.add_argument("--module", nargs="+", help="Run only specific module(s)")
    parser.add_argument("--suite", nargs="+", help="Run only specific suite file(s)")
    parser.add_argument("--tags", help="Run only tests with this tag")
    parser.add_argument("--dry-run", action="store_true", help="Show what would run")
    args = parser.parse_args()

    if not TASKS_CSV.exists():
        print(f"ERROR: {TASKS_CSV} not found.")
        sys.exit(1)

    tasks = read_tasks(TASKS_CSV)
    suites = get_suites_in_order(tasks, args.module, args.suite)

    if not suites:
        print("No matching suites found in tasks.csv.")
        sys.exit(1)

    print_summary(tasks, suites)

    if args.dry_run:
        print("\n  [DRY RUN] No tests executed.")
        sys.exit(0)

    report_dir = create_report_dir()
    print(f"\n  Reports directory: {report_dir}")

    output_files = []
    for i, (suite, ids) in enumerate(suites.items(), 1):
        result = run_suite(suite, ids, report_dir, i, args.tags)
        if result:
            output_files.append(result)

    merge_reports(output_files, report_dir)

    print(f"\n{'='*70}")
    print(f"  DONE — All reports in: {report_dir}")
    print(f"{'='*70}\n")


if __name__ == "__main__":
    main()
