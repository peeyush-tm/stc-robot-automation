"""
Test Runner — reads tasks.csv and runs all Robot Framework suites.

Output folder rules:
  - Sanity suite (tests/sanity_tests.robot):
        STC_Sanity_Automation/<timestamp>/
        Contains: log.html, output.xml, report.html, sanity_report.csv, screenshots
  - All other suites:
        reports/<date_timestamp>/
        Contains: log.html, output.xml, report.html, screenshots

Usage:
    python run_tests.py                          # run ALL suites from tasks.csv
    python run_tests.py --module Login           # run only Login module
    python run_tests.py --module CSRJourney CostCenter  # run multiple modules
    python run_tests.py --suite tests/sanity_tests.robot  # run sanity suite
    python run_tests.py --tags smoke             # run only tests tagged 'smoke'
    python run_tests.py --dry-run                # list what would run without executing
"""

import csv
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from collections import OrderedDict

PROJECT_ROOT     = Path(__file__).resolve().parent
TASKS_CSV        = PROJECT_ROOT / "tasks.csv"
REPORTS_DIR      = PROJECT_ROOT / "reports"
SANITY_SUITE     = "tests/sanity_tests.robot"
SANITY_BASE_DIR  = PROJECT_ROOT / "STC_Sanity_Automation"


def read_tasks(csv_path: Path):
    with open(csv_path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def get_suites_in_order(tasks, module_filter=None, suite_filter=None):
    """Return an ordered dict of suite_file -> list of test_case_ids, preserving CSV order."""
    suites = OrderedDict()
    for row in tasks:
        suite  = row["suite_file"].strip()
        tc_id  = row["test_case_id"].strip()
        module = row["module"].strip()

        if module_filter and module not in module_filter:
            continue
        if suite_filter and suite not in suite_filter:
            continue

        suites.setdefault(suite, []).append(tc_id)
    return suites


def create_report_dir():
    """Create a date-stamped folder inside reports/ for non-sanity suites."""
    timestamp  = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    report_dir = REPORTS_DIR / timestamp
    report_dir.mkdir(parents=True, exist_ok=True)
    return report_dir


def create_sanity_dir():
    """Create a timestamped folder inside STC_Sanity_Automation/ for the sanity suite."""
    timestamp  = datetime.now().strftime("%Y%m%d_%H%M%S")
    sanity_dir = SANITY_BASE_DIR / timestamp
    sanity_dir.mkdir(parents=True, exist_ok=True)
    return sanity_dir


def is_sanity_suite(suite_file: str) -> bool:
    return Path(suite_file).as_posix().replace("\\", "/") == SANITY_SUITE


def run_suite(suite_file, test_ids, report_dir, suite_index, tag_filter=None):
    """Run a single suite file, directing all output into report_dir.
    For the sanity suite, SANITY_REPORT_DIR is also passed so screenshots
    land in the same folder as log.html / report.html.
    """
    suite_path = PROJECT_ROOT / suite_file
    if not suite_path.exists():
        print(f"  [SKIP] Suite file not found: {suite_file}")
        return None

    suite_name = Path(suite_file).stem
    output_xml = report_dir / f"output_{suite_index}_{suite_name}.xml"

    cmd = [
        "robot",
        "--outputdir", str(report_dir),
        "--output",    str(output_xml),
        "--log",       "NONE",
        "--report",    "NONE",
        "--loglevel",  "DEBUG",
    ]

    if is_sanity_suite(suite_file):
        # Pass SANITY_REPORT_DIR so Login For Sanity Suite uses this folder
        cmd.extend(["--variable", f"SANITY_REPORT_DIR:{report_dir}"])

    if tag_filter:
        cmd.extend(["--include", tag_filter])

    cmd.append(str(suite_path))

    label = "SANITY" if is_sanity_suite(suite_file) else suite_name
    print(f"\n{'='*70}")
    print(f"  Running [{label}]: {suite_file} ({len(test_ids)} tests)")
    print(f"  Output folder: {report_dir}")
    print(f"{'='*70}")

    subprocess.run(cmd, cwd=str(PROJECT_ROOT))
    return output_xml if output_xml.exists() else None


def merge_reports(output_files, report_dir):
    """Merge all individual output XMLs into a single combined report."""
    if not output_files:
        print("\nNo output files to merge.")
        return

    cmd = [
        "rebot",
        "--outputdir", str(report_dir),
        "--output",    "output.xml",
        "--log",       "log.html",
        "--report",    "report.html",
        "--loglevel",  "DEBUG",
    ]
    cmd.extend([str(f) for f in output_files])

    print(f"\n{'='*70}")
    print("  Merging reports...")
    print(f"{'='*70}")

    subprocess.run(cmd, cwd=str(PROJECT_ROOT))

    print(f"\n  Report : {report_dir / 'report.html'}")
    print(f"  Log    : {report_dir / 'log.html'}")
    print(f"  Output : {report_dir / 'output.xml'}")


def print_summary(suites):
    total_tests = sum(len(ids) for ids in suites.values())
    print(f"\n{'='*70}")
    print(f"  STC Automation — Test Runner")
    print(f"  Total suites : {len(suites)}")
    print(f"  Total tests  : {total_tests}")
    print(f"{'='*70}")
    for i, (suite, ids) in enumerate(suites.items(), 1):
        tag = " [SANITY]" if is_sanity_suite(suite) else ""
        print(f"  {i}. {suite}{tag} ({len(ids)} tests)")


def main():
    import argparse
    parser = argparse.ArgumentParser(description="STC Automation Test Runner")
    parser.add_argument("--module", nargs="+", help="Run only specific module(s)")
    parser.add_argument("--suite",  nargs="+", help="Run only specific suite file(s)")
    parser.add_argument("--tags",              help="Run only tests with this tag")
    parser.add_argument("--dry-run", action="store_true", help="Show what would run")
    args = parser.parse_args()

    if not TASKS_CSV.exists():
        print(f"ERROR: {TASKS_CSV} not found.")
        sys.exit(1)

    tasks  = read_tasks(TASKS_CSV)
    suites = get_suites_in_order(tasks, args.module, args.suite)

    if not suites:
        print("No matching suites found in tasks.csv.")
        sys.exit(1)

    print_summary(suites)

    if args.dry_run:
        print("\n  [DRY RUN] No tests executed.")
        sys.exit(0)

    # Separate sanity suites from regular suites
    sanity_suites  = {s: ids for s, ids in suites.items() if is_sanity_suite(s)}
    regular_suites = {s: ids for s, ids in suites.items() if not is_sanity_suite(s)}

    output_files = []

    # --- Run regular (non-sanity) suites → reports/<date>/ ---
    if regular_suites:
        report_dir = create_report_dir()
        print(f"\n  Regular reports directory : {report_dir}")
        for i, (suite, ids) in enumerate(regular_suites.items(), 1):
            result = run_suite(suite, ids, report_dir, i, args.tags)
            if result:
                output_files.append((result, report_dir))
        if output_files:
            files = [f for f, _ in output_files]
            merge_reports(files, report_dir)

    # --- Run sanity suite → STC_Sanity_Automation/<timestamp>/ ---
    for suite, ids in sanity_suites.items():
        sanity_dir = create_sanity_dir()
        print(f"\n  Sanity output directory   : {sanity_dir}")
        result = run_suite(suite, ids, sanity_dir, 1, args.tags)
        if result:
            merge_reports([result], sanity_dir)
        print(f"\n  Sanity evidence (CSV + screenshots) : {sanity_dir}")
        print(f"  Sanity report.html                  : {sanity_dir / 'report.html'}")

    print(f"\n{'='*70}")
    print(f"  DONE")
    if regular_suites:
        print(f"  Regular reports → reports/<date>/")
    if sanity_suites:
        print(f"  Sanity results  → STC_Sanity_Automation/<timestamp>/")
    print(f"{'='*70}\n")


if __name__ == "__main__":
    main()
