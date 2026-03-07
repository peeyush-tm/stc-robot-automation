"""
Central test runner: reads tasks.csv, runs Robot suites in order, merges reports.
Supports --env, --browser, --test, --include, --exclude, --suite, --tasks, --api, --ui, --variable.
"""
import argparse
import csv
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent
REPORTS_DIR = PROJECT_ROOT / "reports"
TASKS_CSV = PROJECT_ROOT / "tasks.csv"
SEED_FILE = PROJECT_ROOT / "variables" / ".run_seed.json"


def clear_seed_file():
    if SEED_FILE.exists():
        SEED_FILE.unlink()


def ensure_reports_dir():
    REPORTS_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    run_dir = REPORTS_DIR / timestamp
    run_dir.mkdir(parents=True, exist_ok=True)
    return run_dir


def read_tasks():
    if not TASKS_CSV.exists():
        return []
    rows = []
    with open(TASKS_CSV, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows


def get_suite_path(suite_file):
    path = PROJECT_ROOT / suite_file
    if path.exists():
        return str(path)
    path = PROJECT_ROOT / "tests" / Path(suite_file).name
    return str(path) if path.exists() else suite_file


def is_api_suite(suite_file):
    name = Path(suite_file).stem
    return name.startswith("API_")


def build_robot_args(args, run_dir, is_api=False):
    robot_args = [
        sys.executable, "-m", "robot",
        "--outputdir", str(run_dir),
        "--variable", f"ENV:{args.env}",
    ]
    if not is_api:
        if args.browser:
            robot_args.extend(["--variable", f"BROWSER:{args.browser}"])
    if args.test:
        robot_args.extend(["--test", args.test])
    if args.include:
        robot_args.extend(["--include", args.include])
    if args.exclude:
        robot_args.extend(["--exclude", args.exclude])
    for var in args.variable or []:
        robot_args.extend(["--variable", var])
    return robot_args


def main():
    parser = argparse.ArgumentParser(description="Run MarketLinq automation tests")
    parser.add_argument("paths", nargs="*", help="Suite file path(s), e.g. tests/login_tests.robot")
    parser.add_argument("--env", default="dev", help="Environment: dev, staging, prod")
    parser.add_argument("--browser", help="Browser: chrome, firefox, edge, headlesschrome")
    parser.add_argument("--test", help="Filter by test name pattern")
    parser.add_argument("--include", help="Include tag")
    parser.add_argument("--exclude", help="Exclude tag")
    parser.add_argument("--suite", help="Run by suite name from tasks.csv")
    parser.add_argument("--tasks", action="store_true", help="Run all from tasks.csv in order")
    parser.add_argument("--api", action="store_true", help="Run only API suites from tasks.csv")
    parser.add_argument("--ui", action="store_true", help="Run only UI suites from tasks.csv")
    parser.add_argument("--variable", action="append", help="Override variable (KEY:value)")
    args = parser.parse_args()

    clear_seed_file()
    run_dir = ensure_reports_dir()

    suites_to_run = []

    if args.suite:
        tasks = read_tasks()
        for row in tasks:
            if row.get("suite_file") and Path(row["suite_file"]).stem == args.suite:
                suites_to_run.append(get_suite_path(row["suite_file"]))
                break
        if not suites_to_run:
            seen = set()
            for row in tasks:
                sf = row.get("suite_file", "")
                if sf and sf not in seen:
                    seen.add(sf)
                    path = get_suite_path(sf)
                    if Path(path).stem == args.suite:
                        suites_to_run.append(path)
                        break

    if args.tasks or args.api or args.ui:
        tasks = read_tasks()
        seen = set()
        for row in tasks:
            sf = row.get("suite_file", "")
            if not sf or sf in seen:
                continue
            is_api = is_api_suite(sf)
            if args.api and not is_api:
                continue
            if args.ui and is_api:
                continue
            seen.add(sf)
            suites_to_run.append(get_suite_path(sf))

    if args.paths:
        suites_to_run = [get_suite_path(p) for p in args.paths]

    if not suites_to_run:
        if args.tasks or args.api or args.ui or args.suite:
            print("No suites found in tasks.csv for the given options.")
        else:
            print("Usage: python run_tests.py <suite_path(s)> or --tasks | --api | --ui | --suite NAME")
        sys.exit(1)

    output_xmls = []
    for i, suite_path in enumerate(suites_to_run):
        if not os.path.exists(suite_path):
            print(f"Skip (not found): {suite_path}")
            continue
        is_api = is_api_suite(suite_path)
        robot_args = build_robot_args(args, run_dir, is_api=is_api)
        robot_args.append(suite_path)
        print(f"Running: {suite_path}")
        subprocess.call(robot_args, cwd=str(PROJECT_ROOT))
        base = Path(suite_path).stem
        out_xml = run_dir / f"output_{i + 1}_{base}.xml"
        if (run_dir / "output.xml").exists():
            if len(suites_to_run) > 1:
                (run_dir / "output.xml").rename(out_xml)
                output_xmls.append(str(out_xml))
            else:
                output_xmls.append(str(run_dir / "output.xml"))

    if len(output_xmls) > 1:
        merge_args = [
            sys.executable, "-m", "robot.rebot",
            "--outputdir", str(run_dir),
            "--output", "output.xml",
            "--log", "log.html",
            "--report", "report.html",
        ] + output_xmls
        subprocess.call(merge_args, cwd=str(PROJECT_ROOT))

    print(f"Reports: {run_dir}")
    sys.exit(0)


if __name__ == "__main__":
    main()
