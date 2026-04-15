"""
Jira Bug Logger — Push bug reports from the local /bugs folder to Jira.

Usage:
    python jira_bug_logger.py                          # Interactive — lists bugs and lets you pick
    python jira_bug_logger.py Bug_1_15Apr26_103000     # Push a specific bug by folder name
    python jira_bug_logger.py --all                    # Push ALL unlogged bugs to Jira
    python jira_bug_logger.py --list                   # List all bugs and their Jira status

Setup:
    1. Generate an API token: https://id.atlassian.com/manage-profile/security/api-tokens
    2. Update JIRA_CONFIG below OR set values in .env file
    3. Run the script

Configuration (via .env file):
    JIRA_BASE_URL=https://airlinq-global.atlassian.net
    JIRA_EMAIL=your-email@airlinq.com
    JIRA_API_TOKEN=your-api-token
    JIRA_PROJECT_KEY=STC
    JIRA_ISSUE_TYPE=Bug

Requirements:
    pip install requests
"""

import os
import re
import json
import sys
import base64
import requests

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
BUGS_DIR = os.path.join(ROOT_DIR, "bugs")
JIRA_LOG_FILE = os.path.join(BUGS_DIR, ".jira_logged.json")


def _load_env():
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


def _get_jira_config():
    """Build Jira config from .env or fallback defaults."""
    _load_env()
    return {
        "base_url": os.environ.get("JIRA_BASE_URL", "https://airlinq-global.atlassian.net"),
        "email": os.environ.get("JIRA_EMAIL", "your-email@airlinq.com"),
        "api_token": os.environ.get("JIRA_API_TOKEN", "your-api-token-here"),
        "project_key": os.environ.get("JIRA_PROJECT_KEY", "STC"),
        "issue_type": os.environ.get("JIRA_ISSUE_TYPE", "Bug"),
    }


SEVERITY_TO_PRIORITY = {
    "critical": "Highest",
    "high": "High",
    "medium": "Medium",
    "low": "Low",
}


def load_jira_log():
    if os.path.exists(JIRA_LOG_FILE):
        with open(JIRA_LOG_FILE, "r") as f:
            return json.load(f)
    return {}


def save_jira_log(log):
    os.makedirs(os.path.dirname(JIRA_LOG_FILE), exist_ok=True)
    with open(JIRA_LOG_FILE, "w") as f:
        json.dump(log, f, indent=2)


def parse_bug_report(bug_dir):
    """Parse a bug report .txt file and extract structured fields."""
    txt_files = [f for f in os.listdir(bug_dir) if f.endswith(".txt")]
    if not txt_files:
        return None

    filepath = os.path.join(bug_dir, txt_files[0])
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    report = {"raw": content, "screenshots": []}

    title_match = re.search(r"Bug Title:\s*\n?\s*(.+)", content)
    if title_match:
        report["title"] = title_match.group(1).strip()

    severity_match = re.search(r"Severity:\s*(\w+)", content, re.IGNORECASE)
    if severity_match:
        report["severity"] = severity_match.group(1).strip().lower()

    priority_match = re.search(r"Priority:\s*(\w+)", content, re.IGNORECASE)
    if priority_match:
        report["priority"] = priority_match.group(1).strip()

    desc_match = re.search(
        r"Bug Description:\s*\n(.*?)(?=\n\d+\.\s|\n={3,})",
        content, re.DOTALL
    )
    if desc_match:
        report["description"] = desc_match.group(1).strip()

    steps_match = re.search(
        r"Steps to Reproduce:\s*\n(.*?)(?=\n\d+\.\s(?:Expected|Actual)|\n={3,})",
        content, re.DOTALL
    )
    if steps_match:
        report["steps"] = steps_match.group(1).strip()

    expected_match = re.search(
        r"Expected Result:\s*\n(.*?)(?=\n\d+\.\s|\n={3,})",
        content, re.DOTALL
    )
    if expected_match:
        report["expected"] = expected_match.group(1).strip()

    actual_match = re.search(
        r"Actual Result:\s*\n(.*?)(?=\n\d+\.\s|\n={3,})",
        content, re.DOTALL
    )
    if actual_match:
        report["actual"] = actual_match.group(1).strip()

    env_match = re.search(
        r"Environment / Configuration:\s*\n(.*?)(?=\n\d+\.\s)",
        content, re.DOTALL
    )
    if env_match:
        report["environment"] = env_match.group(1).strip()

    screenshot_dir = os.path.join(bug_dir, "screenshot")
    if os.path.exists(screenshot_dir):
        for img in os.listdir(screenshot_dir):
            if img.lower().endswith((".png", ".jpg", ".jpeg", ".gif")):
                report["screenshots"].append(os.path.join(screenshot_dir, img))

    return report


def build_jira_description(report):
    """Build a Jira-formatted description from the parsed bug report."""
    parts = []

    if report.get("environment"):
        parts.append(f"h3. Environment / Configuration\n{report['environment']}")

    if report.get("description"):
        parts.append(f"h3. Bug Description\n{report['description']}")

    if report.get("steps"):
        parts.append(f"h3. Steps to Reproduce\n{report['steps']}")

    if report.get("expected"):
        parts.append(f"h3. Expected Result\n{report['expected']}")

    if report.get("actual"):
        parts.append(f"h3. Actual Result\n{report['actual']}")

    if not parts:
        parts.append(report.get("raw", "See attached bug report."))

    return "\n\n".join(parts)


def create_jira_issue(report, config):
    """Create a Jira issue and return the issue key."""
    url = f"{config['base_url']}/rest/api/2/issue"

    auth_str = f"{config['email']}:{config['api_token']}"
    auth_header = base64.b64encode(auth_str.encode()).decode()

    headers = {
        "Authorization": f"Basic {auth_header}",
        "Content-Type": "application/json",
    }

    priority = SEVERITY_TO_PRIORITY.get(
        report.get("severity", "medium"), "Medium"
    )

    payload = {
        "fields": {
            "project": {"key": config["project_key"]},
            "summary": report.get("title", "Bug from Automated Testing"),
            "description": build_jira_description(report),
            "issuetype": {"name": config["issue_type"]},
            "priority": {"name": priority},
            "labels": ["automation", "stc-cmp"],
        }
    }

    response = requests.post(url, headers=headers, json=payload)

    if response.status_code == 201:
        issue_data = response.json()
        issue_key = issue_data["key"]
        print(f"  [OK] Issue created: {issue_key}")
        print(f"       URL: {config['base_url']}/browse/{issue_key}")
        return issue_key
    else:
        print(f"  [FAILED] Status: {response.status_code}")
        print(f"  Response: {response.text}")
        return None


def attach_screenshots(issue_key, screenshots, config):
    """Attach screenshot files to a Jira issue."""
    if not screenshots:
        return

    url = f"{config['base_url']}/rest/api/2/issue/{issue_key}/attachments"

    auth_str = f"{config['email']}:{config['api_token']}"
    auth_header = base64.b64encode(auth_str.encode()).decode()

    headers = {
        "Authorization": f"Basic {auth_header}",
        "X-Atlassian-Token": "no-check",
    }

    for ss_path in screenshots:
        filename = os.path.basename(ss_path)
        with open(ss_path, "rb") as f:
            files = {"file": (filename, f, "image/png")}
            response = requests.post(url, headers=headers, files=files)
            if response.status_code == 200:
                print(f"  [OK] Attached: {filename}")
            else:
                print(f"  [FAILED] Attaching {filename}: {response.status_code}")


def log_bug_to_jira(bug_folder_name, config):
    """Parse a bug folder and push it to Jira."""
    bug_dir = os.path.join(BUGS_DIR, bug_folder_name)
    if not os.path.isdir(bug_dir):
        print(f"  [ERROR] Bug folder not found: {bug_folder_name}")
        return None

    jira_log = load_jira_log()
    if bug_folder_name in jira_log:
        issue_key = jira_log[bug_folder_name]
        print(f"  [SKIP] Already logged as {issue_key}")
        return issue_key

    report = parse_bug_report(bug_dir)
    if not report:
        print(f"  [ERROR] No .txt bug report found in {bug_folder_name}")
        return None

    print(f"\n{'='*60}")
    print(f"Logging: {bug_folder_name}")
    print(f"Title  : {report.get('title', 'N/A')}")
    print(f"{'='*60}")

    issue_key = create_jira_issue(report, config)
    if issue_key:
        attach_screenshots(issue_key, report["screenshots"], config)
        jira_log[bug_folder_name] = issue_key
        save_jira_log(jira_log)

    return issue_key


def list_all_bugs():
    """List all bugs and show their Jira status."""
    if not os.path.isdir(BUGS_DIR):
        print("No bugs/ directory found.")
        return

    jira_log = load_jira_log()
    bug_folders = sorted([
        d for d in os.listdir(BUGS_DIR)
        if os.path.isdir(os.path.join(BUGS_DIR, d)) and d.startswith("Bug_")
    ])

    if not bug_folders:
        print("No bug reports found.")
        return

    print(f"\n{'='*80}")
    print(f"{'Bug Folder':<50} {'Jira Status':<30}")
    print(f"{'='*80}")

    logged = 0
    unlogged = 0
    for bf in bug_folders:
        if bf in jira_log:
            print(f"{bf:<50} {jira_log[bf]:<30}")
            logged += 1
        else:
            print(f"{bf:<50} {'NOT LOGGED':<30}")
            unlogged += 1

    print(f"{'='*80}")
    print(f"Total: {len(bug_folders)} | Logged: {logged} | Not Logged: {unlogged}")


def interactive_mode(config):
    """Interactive mode — list recent bugs and let user pick which to log."""
    if not os.path.isdir(BUGS_DIR):
        print("No bugs/ directory found. Run tests first to generate bug reports.")
        return

    jira_log = load_jira_log()
    bug_folders = sorted([
        d for d in os.listdir(BUGS_DIR)
        if os.path.isdir(os.path.join(BUGS_DIR, d))
        and d.startswith("Bug_")
        and d not in jira_log
    ])

    if not bug_folders:
        print("All bugs have already been logged to Jira!")
        return

    print(f"\n{'='*60}")
    print(f"Unlogged Bugs ({len(bug_folders)} total)")
    print(f"{'='*60}")
    for idx, bf in enumerate(bug_folders, 1):
        report = parse_bug_report(os.path.join(BUGS_DIR, bf))
        title = report.get("title", "N/A") if report else "N/A"
        print(f"  {idx}. {bf}")
        print(f"     {title}\n")

    print(f"{'='*60}")
    choice = input("Enter bug number(s) to log (e.g., 1,2,3 or 'all'): ").strip()

    if choice.lower() == "all":
        for bf in bug_folders:
            log_bug_to_jira(bf, config)
    else:
        for num in choice.split(","):
            try:
                idx = int(num.strip()) - 1
                if 0 <= idx < len(bug_folders):
                    log_bug_to_jira(bug_folders[idx], config)
                else:
                    print(f"  [ERROR] Invalid number: {num}")
            except ValueError:
                print(f"  [ERROR] Invalid input: {num}")


def main():
    config = _get_jira_config()

    if config["api_token"] == "your-api-token-here":
        print("=" * 60)
        print("JIRA NOT CONFIGURED!")
        print("=" * 60)
        print()
        print("Set the following in your .env file:")
        print()
        print('  JIRA_BASE_URL=https://airlinq-global.atlassian.net')
        print('  JIRA_EMAIL=your-email@airlinq.com')
        print('  JIRA_API_TOKEN=your-api-token')
        print('  JIRA_PROJECT_KEY=STC')
        print()
        print("To generate an API token, visit:")
        print("  https://id.atlassian.com/manage-profile/security/api-tokens")
        print("=" * 60)
        sys.exit(1)

    args = sys.argv[1:]

    if not args:
        interactive_mode(config)
    elif args[0] == "--list":
        list_all_bugs()
    elif args[0] == "--all":
        if not os.path.isdir(BUGS_DIR):
            print("No bugs/ directory found.")
            return
        bug_folders = sorted([
            d for d in os.listdir(BUGS_DIR)
            if os.path.isdir(os.path.join(BUGS_DIR, d)) and d.startswith("Bug_")
        ])
        for bf in bug_folders:
            log_bug_to_jira(bf, config)
    else:
        for bug_name in args:
            log_bug_to_jira(bug_name, config)


if __name__ == "__main__":
    main()
