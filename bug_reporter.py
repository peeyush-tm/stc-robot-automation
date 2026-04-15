"""
Automatic Bug Report Generator for STC Automation.

Parses Robot Framework output.xml for failed tests and generates
structured bug report folders with text files and screenshots.

Bug folder format:  Bug_<count>_<DDMonYY>_<HHMMSS>/
Inside each folder: Bug_<...>.txt + screenshot/ subfolder

Usage (standalone):
    python bug_reporter.py reports/2026-04-15_10-30-00

Called automatically by run_tests.py after any suite with failures.
"""

import os
import re
import glob
import shutil
import xml.etree.ElementTree as ET
from datetime import datetime

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


def generate_bug_reports(output_dir, bugs_dir=None, env_url=""):
    """
    Parse Robot Framework output.xml for failures and generate bug reports.

    Args:
        output_dir:   Path to the timestamped report folder containing output.xml
        bugs_dir:     Path to the bugs/ folder (defaults to <project>/bugs/)
        env_url:      Environment URL for the bug report
    Returns:
        Number of bug reports generated.
    """
    if bugs_dir is None:
        bugs_dir = os.path.join(ROOT_DIR, "bugs")

    # Look for combined_output.xml first, then output.xml, then output_*.xml
    xml_files = []
    combined = os.path.join(output_dir, "combined_output.xml")
    single = os.path.join(output_dir, "output.xml")

    if os.path.exists(combined):
        xml_files = [combined]
    elif os.path.exists(single):
        xml_files = [single]
    else:
        xml_files = sorted(glob.glob(os.path.join(output_dir, "output_*.xml")))

    if not xml_files:
        print("\nNo output.xml found — skipping bug report generation.")
        return 0

    failed_tests = []
    for xf in xml_files:
        failed_tests.extend(_parse_failures(xf))

    if not failed_tests:
        print("\nAll tests passed — no bug reports to generate.")
        return 0

    os.makedirs(bugs_dir, exist_ok=True)
    existing_count = _count_existing_bugs(bugs_dir)

    print(f"\n{'=' * 60}")
    print(f"GENERATING BUG REPORTS — {len(failed_tests)} failure(s) detected")
    print(f"{'=' * 60}")

    for i, failure in enumerate(failed_tests, 1):
        bug_number = existing_count + i
        now = datetime.now()

        date_str = f"{now.day}{now.strftime('%b')}{now.strftime('%y')}"
        time_str = now.strftime("%H%M%S")
        bug_name = f"Bug_{bug_number}_{date_str}_{time_str}"

        bug_folder = os.path.join(bugs_dir, bug_name)
        screenshot_folder = os.path.join(bug_folder, "screenshot")
        os.makedirs(screenshot_folder, exist_ok=True)

        report = _build_report(failure, bug_name, env_url)
        report_file = os.path.join(bug_folder, f"{bug_name}.txt")
        with open(report_file, "w", encoding="utf-8") as f:
            f.write(report)

        copied = _copy_screenshots(output_dir, failure["name"], screenshot_folder)

        print(f"  [{i}/{len(failed_tests)}] {bug_name}  ({copied} screenshot(s) attached)")

    print(f"\nBug reports saved to: {bugs_dir}")
    print(f"{'=' * 60}")
    return len(failed_tests)


# ─── XML Parsing ────────────────────────────────────────────────


def _parse_failures(xml_path):
    """Parse a Robot Framework output.xml and return details for each failed test."""
    failures = []
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except ET.ParseError:
        print(f"  Warning: Could not parse {xml_path}")
        return failures

    for test in root.iter("test"):
        status_elem = test.find("status")
        if status_elem is None or status_elem.get("status") != "FAIL":
            continue

        doc_elem = test.find("doc")
        doc_text = doc_elem.text.strip() if doc_elem is not None and doc_elem.text else ""

        keywords = []
        for child in test:
            if child.tag == "kw" and child.get("type", "") not in ("teardown", "setup"):
                kw_name = child.get("name", "")
                if kw_name:
                    keywords.append(kw_name)

        suite_name = _find_parent_suite(root, test.get("id", ""))

        failures.append({
            "name": test.get("name", "Unknown Test"),
            "message": status_elem.text or "Test execution failed.",
            "starttime": status_elem.get("starttime", ""),
            "doc": doc_text,
            "keywords": keywords,
            "suite": suite_name,
        })

    return failures


def _find_parent_suite(root, test_id):
    """Walk the XML tree to find the immediate parent suite name for a test."""
    for suite in root.iter("suite"):
        for t in suite.findall("test"):
            if t.get("id") == test_id:
                return suite.get("name", "")
    return ""


def _count_existing_bugs(bugs_dir):
    """Count Bug_* folders already present in the bugs directory."""
    if not os.path.exists(bugs_dir):
        return 0
    return len([
        d for d in os.listdir(bugs_dir)
        if os.path.isdir(os.path.join(bugs_dir, d)) and d.startswith("Bug_")
    ])


# ─── Report Builder ─────────────────────────────────────────────


def _build_report(failure, bug_name, env_url):
    """Assemble the full bug report text."""
    test_name = failure["name"]
    message = failure["message"]
    doc = failure["doc"]
    keywords = failure["keywords"]

    title = _generate_title(test_name)
    description = _generate_description(test_name, message, doc)
    steps = _generate_steps(test_name, keywords, env_url)
    expected = _generate_expected(test_name, doc)
    actual = _generate_actual(message)

    report = (
        f"{'=' * 70}\n"
        f"BUG REPORT: {bug_name}\n"
        f"{'=' * 70}\n"
        f"\n"
        f"1. Bug Title:\n"
        f"   STC CMP | {title}\n"
        f"\n"
        f"2. Environment / Configuration:\n"
        f"   - Browser & OS version: Chrome Driver / Windows\n"
        f"   - Test environment: QE Environment\n"
        f"   - Environment URL: {env_url}\n"
        f"\n"
        f"3. Bug Description:\n"
        f"   {description}\n"
        f"\n"
        f"4. Steps to Reproduce:\n"
        f"{steps}\n"
        f"\n"
        f"5. Expected Result:\n"
        f"   {expected}\n"
        f"\n"
        f"6. Actual Result:\n"
        f"   {actual}\n"
        f"\n"
        f"7. Artifacts:\n"
        f"   Relevant Screenshots/logs are attached below for reference\n"
        f"\n"
        f"{'=' * 70}\n"
    )
    return report


# ─── Content Generators ─────────────────────────────────────────


def _clean_tc_name(test_name):
    """Strip TC ID prefixes like 'TC_RE_001 - ' or 'TC_IPP_003 - '."""
    return re.sub(r"^[A-Z_]+\d+\s*[-\u2013]\s*", "", test_name).strip()


def _generate_title(test_name):
    """Generate a precise 10-15 word bug title."""
    clean = _clean_tc_name(test_name)
    words = clean.split()
    if len(words) <= 6:
        return f"{clean} Validation Failed During Automated Regression Test Execution"
    if len(words) <= 10:
        return f"{clean} — Automated Test Validation Failed"
    return " ".join(words[:10]) + " — Test Validation Failed"


def _generate_description(test_name, message, doc):
    """Generate a 20-50 word professional bug description."""
    clean = _clean_tc_name(test_name)

    clean_msg = message.strip().replace("\n", " ")
    if len(clean_msg) > 120:
        clean_msg = clean_msg[:120].rsplit(" ", 1)[0] + "..."

    if doc:
        desc = (
            f"During automated testing, the '{clean}' test case failed. "
            f"{doc} The system reported: \"{clean_msg}\""
        )
    else:
        desc = (
            f"During automated testing of the STC CMP application, "
            f"the '{clean}' test case failed. The automation framework "
            f"reported the following error: \"{clean_msg}\"."
        )

    words = desc.split()
    if len(words) > 50:
        desc = " ".join(words[:48]) + "."
    elif len(words) < 20:
        desc += " Further investigation is needed to identify the root cause."

    return desc


def _generate_steps(test_name, keywords, env_url):
    """Generate 5-6 numbered steps to reproduce."""
    steps = [
        f"   4.1 - Open the URL {env_url}",
        f"   4.2 - Enter the correct valid details for login",
    ]

    added = set()
    step_num = 3
    for kw in keywords:
        if step_num > 6:
            break
        skip_names = {
            "capture test screenshot", "capture step screenshot",
            "sleep", "set suite variable", "set test variable",
            "log", "run keywords",
        }
        if kw.lower() in skip_names or kw in added:
            continue
        readable = kw.replace("_", " ").strip()
        steps.append(f"   4.{step_num} - {readable}")
        added.add(kw)
        step_num += 1

    if step_num <= 6:
        steps.append(
            f"   4.{step_num} - Observe the result and verify the expected behavior"
        )

    return "\n".join(steps)


def _generate_expected(test_name, doc):
    """Generate the expected result in 10-30 words."""
    clean = _clean_tc_name(test_name)
    if doc:
        words = doc.split()
        if len(words) > 30:
            return " ".join(words[:28]) + "."
        return doc
    return (
        f"The '{clean}' test case should complete successfully "
        f"without any errors or unexpected behavior."
    )


def _generate_actual(message):
    """Generate the actual result in 10-30 words."""
    clean_msg = message.strip().replace("\n", " ")
    words = clean_msg.split()
    if len(words) > 25:
        clean_msg = " ".join(words[:23]) + "..."
    return f"The test case failed with error: {clean_msg}"


# ─── Screenshot Copier ──────────────────────────────────────────


def _copy_screenshots(output_dir, test_name, screenshot_folder):
    """Copy all PNG screenshots matching the test name into the bug's screenshot folder."""
    safe_name = test_name.replace(" ", "_")
    copied = 0

    # Search in the output_dir and any module subfolders
    search_dirs = [output_dir]
    for entry in os.listdir(output_dir):
        sub = os.path.join(output_dir, entry)
        if os.path.isdir(sub):
            search_dirs.append(sub)

    for search_dir in search_dirs:
        for png_file in glob.glob(os.path.join(search_dir, "*.png")):
            filename = os.path.basename(png_file)
            if safe_name in filename or test_name.replace(" ", "_") in filename:
                shutil.copy2(png_file, screenshot_folder)
                copied += 1

    return copied


# ─── CLI ────────────────────────────────────────────────────────


def main():
    import sys
    if len(sys.argv) < 2:
        print("Usage: python bug_reporter.py <report_directory> [--env-url URL]")
        sys.exit(1)

    output_dir = sys.argv[1]
    env_url = ""
    if "--env-url" in sys.argv:
        idx = sys.argv.index("--env-url")
        if idx + 1 < len(sys.argv):
            env_url = sys.argv[idx + 1]

    if not os.path.isdir(output_dir):
        print(f"ERROR: Directory not found: {output_dir}")
        sys.exit(1)

    count = generate_bug_reports(output_dir, env_url=env_url)
    sys.exit(0 if count == 0 else 1)


if __name__ == "__main__":
    main()
