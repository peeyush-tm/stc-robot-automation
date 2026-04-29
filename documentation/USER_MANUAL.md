# STC Automation — User Manual

> **Framework:** Robot Framework 7 + SeleniumLibrary + Python 3.11  
> **Runner:** `run_tests.py` — always use this, never call `robot` directly  
> **Total coverage:** 662 test cases across 23 test suites  
> **Supported environments:** QE · SIT  
> **Last updated:** 2026-04-29

---

## Table of Contents

1. [What This Framework Does](#1-what-this-framework-does)
2. [System Prerequisites](#2-system-prerequisites)
3. [Installation — Step by Step](#3-installation--step-by-step)
4. [Configuration Reference](#4-configuration-reference)
5. [Running Tests](#5-running-tests)
6. [All Test Modules](#6-all-test-modules)
7. [Email Reports](#7-email-reports)
8. [Bug Reports & Jira](#8-bug-reports--jira)
9. [Report Artifacts](#9-report-artifacts)
10. [Updating the Code](#10-updating-the-code)
11. [Troubleshooting](#11-troubleshooting)
12. [Quick Reference Card](#12-quick-reference-card)

---

## 1. What This Framework Does

| | |
|---|---|
| **Application under test** | STC CMP (Connectivity Management Platform) — React web portal |
| **Automation framework** | Robot Framework 7.0.1 + SeleniumLibrary 6.3 |
| **Language** | Python 3.11 |
| **Test runner** | `run_tests.py` (central wrapper) |
| **Total test cases** | **662 across 23 suites** |
| **Supported environments** | QE (`--env qe`) · SIT (`--env sit`) |
| **Supported browsers** | Headless Chrome (server) · Chrome · Firefox |
| **Report formats** | HTML dashboard · detailed log · PDF executive summary · HTML email |

The framework covers the full STC CMP feature set — login, SIM lifecycle, CSR journey, rule engine, label management, reporting, role/user management, PAYG usage, and complete E2E flows — all driven from a single `tasks.csv` registry.

---

## 2. System Prerequisites

### 2.1 Supported Operating Systems

| OS | Status |
|----|--------|
| Windows 10 / 11 | ✅ Full support (visible + headless Chrome) |
| Ubuntu 20.04 / 22.04 | ✅ Full support (headless Chrome only) |
| RHEL / CentOS 7+ | ✅ Full support (headless Chrome only) |

### 2.2 Required Software

#### Windows

| Software | Minimum | Install |
|----------|---------|---------|
| Python | 3.9+ (3.11 recommended) | python.org → tick **"Add Python to PATH"** |
| Git | Any | git-scm.com |
| Google Chrome | Latest stable | chrome.com |

> ChromeDriver is **auto-managed by Selenium Manager** (built into SeleniumLibrary 6.1+). You do not need to download it manually.

#### Linux (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3.11-dev git
```

#### Linux (RHEL / CentOS)

```bash
sudo yum install -y python3 python3-venv python3-devel git
```

> **Linux servers use a bundled headless Chrome binary** included in the repo at `config/browser/headless-shell/`. No system Chrome install is needed on the server. See [Section 3.4](#34-linux-server--set-up-headless-chrome).

### 2.3 Network Access

| Target | Purpose |
|--------|---------|
| CMP application URL (per env) | Browser under test |
| MySQL server port 3306 | Captcha lookup + E2E account IDs |
| SSH port 22 (order server) | E2E order processing scripts |
| `smtp.gmail.com:587` | Email reports (optional) |
| `airlinq-global.atlassian.net` | Jira bug logger (optional) |

---

## 3. Installation — Step by Step

### 3.1 Clone the Repository

```bash
git clone <your-git-repo-url> stc-automation
cd stc-automation
git checkout feature-branch
```

### 3.2 Create a Virtual Environment

**Windows (PowerShell):**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**Linux / Mac:**
```bash
python3.11 -m venv venv
source venv/bin/activate
```

Your prompt will show `(venv)` — **every command from this point must be run with the venv active.**

### 3.3 Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Packages installed:

| Package | Version | Purpose |
|---------|---------|---------|
| `robotframework` | 7.0.1 | Core test framework |
| `robotframework-seleniumlibrary` | 6.3.0 | Browser automation |
| `selenium` | 4.18.1 | WebDriver bindings |
| `robotframework-requests` | 0.9.7 | REST/SOAP API testing |
| `requests` | 2.31.0 | HTTP client |
| `robotframework-sshlibrary` | 3.8.0 | SSH commands (E2E) |
| `robotframework-databaselibrary` | 1.4.4 | MySQL queries |
| `PyMySQL` | 1.1.0 | MySQL driver |
| `reportlab` | 4.1.0 | PDF report generation |
| `robotframework-datadriver` | 1.11.2 | Data-driven CSV tests |

**Verify:**
```bash
python -m robot --version
# Robot Framework 7.0.1 (Python 3.11.x ...)
```

### 3.4 Linux Server — Set Up Headless Chrome

The server has no display. The bundled headless-shell binary in the repo is used automatically by `run_tests.py` on Linux.

```bash
# Make binary executable (one-time, after clone)
chmod +x config/browser/headless-shell/headless_shell

# Verify chromedriver is on PATH and version matches
/opt/Automation/STC/config/browser/headless-shell/headless_shell --version
chromedriver --version
# Both must show the same major version number
```

If chromedriver is missing:
```bash
# Example for Chrome 114 — replace with your actual version
wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
```

### 3.5 Create the `.env` File

The `.env` file holds SMTP and Jira credentials. It is git-ignored and must be created manually.

```bash
cp .env.example .env
# Then edit .env with your actual values (see Section 4.2)
```

### 3.6 Create Reports Folder

```bash
mkdir -p reports
```

### 3.7 Verify Installation

```bash
# Check Robot Framework
python -m robot --version

# Check runner
python run_tests.py --help

# Quick smoke test (Login suite, ~3 min)
python run_tests.py --suite "Login" --env qe
```

---

## 4. Configuration Reference

### 4.1 Environment Config Files

All environment-specific values live in `config/<env>.json`.

| File | Environment | Browser default |
|------|------------|-----------------|
| `config/qe.json` | QE environment | `headlesschrome` |
| `config/sit.json` | SIT environment | `headlesschrome` |
| `config/dev.json` | Local dev | `chrome` (visible) |

Key fields to verify/fill before running:

| Key | What It Controls |
|-----|-----------------|
| `BASE_URL` | CMP application URL (e.g. `https://10.23.48.35:8443/`) |
| `VALID_USERNAME` | Login username |
| `VALID_PASSWORD` | Login password |
| `BROWSER` | Must be `headlesschrome` on Linux server |
| `DEFAULT_EC_ACCOUNT` | Fallback EC account for module tests |
| `DEFAULT_BU_ACCOUNT` | Fallback BU account for module tests |
| `DB_HOST` / `DB_PORT` | MySQL server for captcha + account ID lookup |
| `DB_NAME` / `DB_USER` / `DB_PASS` | MySQL credentials |
| `SSH_HOST` / `SSH_USERNAME` / `SSH_PASSWORD` | Order processing server (E2E only) |
| `USAGE_API_BASE_URL` | Usage injection endpoint (PAYG / E2E) |
| `INVOICE_API_URL` / `INVOICE_SSH_HOST` | Invoice generation (E2E only) |

### 4.2 Email and Jira Credentials (`.env`)

```ini
# ── Email (SMTP) ─────────────────────────────────────────────────────────────
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
EMAIL_FROM=your-email@gmail.com
EMAIL_TO=recipient1@airlinq.com,recipient2@airlinq.com

# ── Email metadata ────────────────────────────────────────────────────────────
CLIENT=STC
ENV=QE

# ── Jira ─────────────────────────────────────────────────────────────────────
JIRA_BASE_URL=https://airlinq-global.atlassian.net
JIRA_EMAIL=your-email@airlinq.com
JIRA_API_TOKEN=your-jira-api-token
JIRA_PROJECT_KEY=STC
JIRA_ISSUE_TYPE=Bug
```

> **Gmail App Password:** Go to myaccount.google.com → Security → 2-Step Verification → App Passwords. Generate a password for "Mail" and use it as `SMTP_PASS`.

> Email and Jira are **optional**. Tests run fine without `.env` — only `--email` flag and `jira_bug_logger.py` need it.

---

## 5. Running Tests

### 5.1 The Golden Rule

**Always use `run_tests.py`. Never call `python -m robot` directly.**  
The runner handles config injection, output merging, report generation, and bug report creation automatically.

### 5.2 Core Commands

```bash
# ── By environment ────────────────────────────────────────────────────────────
python run_tests.py --env qe          # QE environment
python run_tests.py --env sit         # SIT environment

# ── Sanity suite (48 page-load checks, ~10 min) ───────────────────────────────
python run_tests.py --sanity --env qe
python run_tests.py --sanity --env sit
python run_tests.py --sanity --env qe --parallel 4   # parallel, ~4 min

# ── Specific module ───────────────────────────────────────────────────────────
python run_tests.py --suite "Login" --env qe
python run_tests.py --suite "APN" --env qe
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Label" --env qe
python run_tests.py --suite "CSR Journey" --env qe
python run_tests.py --suite "User Management" --env qe
python run_tests.py --suite "Role Management" --env qe
python run_tests.py --suite "SIM Range" --env qe
python run_tests.py --suite "Cost Center" --env qe
python run_tests.py --suite "IP Pool" --env qe
python run_tests.py --suite "IP Whitelist" --env qe
python run_tests.py --suite "Device Plan" --env qe
python run_tests.py --suite "Device State" --env qe
python run_tests.py --suite "SIM Order" --env qe
python run_tests.py --suite "SIM Movement" --env qe
python run_tests.py --suite "SIM Replacement" --env qe
python run_tests.py --suite "Account Onboard" --env qe
python run_tests.py --suite "Report" --env qe

# ── E2E flows ─────────────────────────────────────────────────────────────────
python run_tests.py --e2e --env qe                   # E2E Flow A (no usage)
python run_tests.py --e2e-with-usage --env qe        # E2E Flow B (with usage)

# ── All tests (662 TCs, several hours) ────────────────────────────────────────
python run_tests.py --env qe

# ── With email report ─────────────────────────────────────────────────────────
python run_tests.py --suite "Login" --env qe --email
python run_tests.py --sanity --env qe --email
```

### 5.3 Filtering Options

```bash
# Run only smoke-tagged tests
python run_tests.py --suite "Login" --env qe --include smoke

# Run a single test by ID
python run_tests.py tests/login_tests.robot --env qe --test "TC_LOGIN_001*"
python run_tests.py tests/apn_tests.robot --env qe --test "TC_APN_005*"

# Skip specific tests
python run_tests.py --suite "APN" --env qe --skip-test "TC_APN_022*"

# Skip an entire suite from a full run
python run_tests.py --env qe --skip-suite "Label"
python run_tests.py --env qe --skip-suite "Rule Engine"
```

### 5.4 Re-running Failures

```bash
# Re-run only the tests that failed in a previous run
python run_tests.py --suite "Rule Engine" --env qe --rerunfailed reports/2026-04-28_10-30-00
```

### 5.5 Browser Options

| Value | When to Use |
|-------|------------|
| `headlesschrome` | Linux server (no display) — set in config or `--browser` |
| `chrome` | Windows / Mac local runs |
| `firefox` | Alternative browser |

```bash
# Force headless regardless of config
python run_tests.py --suite "Login" --env qe --browser headlesschrome

# Force visible chrome even if config says headless
python run_tests.py --suite "Login" --env qe --browser chrome
```

---

## 6. All Test Modules

| # | Module | Suite File | Test Cases | Description |
|---|--------|-----------|-----------|-------------|
| 1 | Rule Engine | `rule_engine_tests.robot` | 155 | 4-tab rule creation wizard |
| 2 | APN | `apn_tests.robot` | 65 | Create / Edit / Delete APN configs |
| 3 | Sanity | `sanity_tests.robot` | 48 | Page-load checks across all CMP pages |
| 4 | User Management | `user_management_tests.robot` | 45 | User CRUD + status management |
| 5 | Account Onboard | `onboard_customer_api_tests.robot` | 38 | SOAP API customer onboarding |
| 6 | Role Management | `role_management_tests.robot` | 33 | Role + permission management |
| 7 | Label | `label_tests.robot` | 28 | Label CRUD + SIM tag assignment |
| 8 | SIM Range MSISDN | `sim_range_msisdn_tests.robot` | 26 | MSISDN range management |
| 9 | Cost Center | `cost_center_tests.robot` | 25 | Cost center management |
| 10 | E2E Flow With Usage | `e2e_flow_with_usage.robot` | 23 | Full SIM lifecycle + usage injection |
| 11 | SIM Range | `sim_range_tests.robot` | 21 | ICCID/IMSI range management |
| 12 | SIM Order | `sim_order_tests.robot` | 21 | SIM order creation + validation |
| 13 | E2E Flow | `e2e_flow.robot` | 21 | Full SIM lifecycle (no usage) |
| 14 | IP Whitelist | `ip_whitelist_tests.robot` | 20 | IP whitelist management |
| 15 | SIM Product Type | `product_type_tests.robot` | 18 | SIM product type management |
| 16 | IP Pool | `ip_pool_tests.robot` | 17 | IP pool management |
| 17 | Report | `report_tests.robot` | 14 | Report creation + download |
| 18 | Login | `login_tests.robot` | 12 | Login/logout, captcha, security |
| 19 | CSR Journey | `csr_journey_tests.robot` | 12 | CSR journey wizard |
| 20 | SIM Movement | `sim_movement_tests.robot` | 6 | SIM movement between BU accounts |
| 21 | SIM Replacement | `sim_replacement_tests.robot` | 6 | SIM replacement end-to-end |
| 22 | Role/User CRUD | `role_user_crud_tests.robot` | 4 | Quick CRUD positive tests |
| 23 | E2E Usage Plans | `e2e_flow_with_usage_plans.robot` | 4 | Plan-duration matrix (Yearly/HalfYearly/Quarterly/Monthly) |
| | **TOTAL** | | **662** | |

### Test ID Naming Convention

```
TC_<MODULE>_<NNN>
```

Examples: `TC_RE_001`, `TC_LBL_025`, `TC_APN_022`, `TC_LOGIN_001`

---

## 7. Email Reports

When `--email` is passed, after the run completes an HTML email is sent to all addresses in `EMAIL_TO`.

**Email contents:**

| Section | Content |
|---------|---------|
| Subject | `[STC][QE] Test Run — 2026-04-29 — 660/662 PASSED` |
| Header | Client, environment, timestamp |
| Donut chart | Pass / Fail / Skip percentages |
| Summary table | Per-suite counts + duration |
| Failed tests | TC ID, error message, first screenshot |
| Attachments | `combined_log.html`, `combined_report.html`, PDF summary |

```bash
# Send email from a past run (no re-run needed)
python send_report.py reports/2026-04-29_10-30-00
```

---

## 8. Bug Reports & Jira

### Auto Bug Reports

Bug reports are generated **automatically after every run** when failures are detected. No extra flag needed.

```
bugs/
└── Bug_1_29Apr26_103000/
    ├── bug_report.txt       ← structured bug: title, env, steps, expected/actual
    └── screenshots/         ← failure screenshots from that test
```

```bash
# Generate for a past run manually
python bug_reporter.py reports/2026-04-29_10-30-00
```

### Push to Jira

```bash
python jira_bug_logger.py              # interactive — pick which bugs to push
python jira_bug_logger.py --all        # push ALL unlogged bugs
python jira_bug_logger.py --list       # list all bugs + Jira status
python jira_bug_logger.py Bug_1_29Apr26_103000  # push one specific bug
```

Requires `JIRA_*` values in `.env`.

---

## 9. Report Artifacts

Every run creates a timestamped folder under `reports/`:

```
reports/2026-04-29_14-03-08/
├── combined_report.html      ← start here — top-level pass/fail dashboard
├── combined_log.html         ← drill-down per test, with screenshots inline
├── combined_output.xml       ← merged Robot XML
├── execution_report.pdf      ← PDF executive summary
├── stc_test_data.json        ← machine-readable run metadata
├── output_1_login_tests.xml  ← per-suite raw XML
├── output_2_apn_tests.xml
└── Label/                    ← per-module screenshot subfolder
    ├── TC_LBL_001_step_01_PASS.png
    └── TC_LBL_025_step_03_FAIL.png
```

The `reports/` folder is git-ignored. Open `combined_report.html` in a browser to see results.

---

## 10. Updating the Code

When new commits are pushed to the branch, pull on the server:

```bash
cd /opt/Automation/STC
source venv/bin/activate

git stash                        # stash any local debug edits
git pull origin feature-branch   # pull latest

# If requirements.txt changed:
pip install -r requirements.txt

# Verify
python run_tests.py --help
```

> **Never edit files directly on the server.** All changes go through Git: commit locally → push → pull on server.

---

## 11. Troubleshooting

| Problem | Fix |
|---------|-----|
| `ModuleNotFoundError: No module named 'robot'` | Virtual environment not active. Run `source venv/bin/activate` (Linux) or `.\venv\Scripts\Activate.ps1` (Windows) |
| `python: command not found` | On Linux, use `python3` or check venv activation |
| Chrome fails to start on Linux | Run `chmod +x config/browser/headless-shell/headless_shell`. If still failing: `sudo apt install -y libnss3 libatk1.0-0 libgbm1` |
| `ChromeDriver version mismatch` | Check `headless_shell --version` and `chromedriver --version` — both must match. Download matching chromedriver |
| `BROWSER` must be `headlesschrome` on server | Edit `config/qe.json` — set `"BROWSER": "headlesschrome"`. Visible Chrome crashes with no display |
| `DatabaseError: Can't connect to MySQL` | Check `DB_HOST` in config is correct and server is reachable (`ping DB_HOST`) |
| `Authentication failed` (email) | Regenerate Gmail App Password. Use App Password, not your Google account password |
| `git pull` blocked by local changes | Run `git stash` first, then `git pull origin feature-branch` |
| Reports folder missing | `mkdir -p reports` |
| Empty toast text in Label tests | Known intermittent UI timing issue — already handled with retry logic in `label_keywords.resource` |
| Test still uses old code after pull | Confirm with `git log --oneline -3` that the correct commit is on the server |

For any failure, open `combined_log.html` and navigate to the first red keyword — the error message there pinpoints the root cause.

---

## 12. Quick Reference Card

```bash
# ── One-time setup (server) ──────────────────────────────────────────────────
cd /opt/Automation/STC
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
chmod +x config/browser/headless-shell/headless_shell
cp .env.example .env && vi .env

# ── Every session (activate venv first) ─────────────────────────────────────
cd /opt/Automation/STC && source venv/bin/activate

# ── Sanity ────────────────────────────────────────────────────────────────────
python run_tests.py --sanity --env qe
python run_tests.py --sanity --env sit
python run_tests.py --sanity --env qe --parallel 4 --email

# ── Module suites ─────────────────────────────────────────────────────────────
python run_tests.py --suite "Login" --env qe
python run_tests.py --suite "APN" --env qe
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Label" --env qe
python run_tests.py --suite "User Management" --env qe
python run_tests.py --suite "CSR Journey" --env qe

# ── E2E flows ─────────────────────────────────────────────────────────────────
python run_tests.py --e2e --env qe
python run_tests.py --e2e-with-usage --env qe

# ── All 662 tests ─────────────────────────────────────────────────────────────
python run_tests.py --env qe
python run_tests.py --env sit

# ── Re-run failures ───────────────────────────────────────────────────────────
python run_tests.py --suite "Label" --env qe --rerunfailed reports/2026-04-29_10-00-00

# ── Update code ───────────────────────────────────────────────────────────────
git stash && git pull origin feature-branch
pip install -r requirements.txt   # only if requirements changed
```

---

**Maintained by:** STC Automation Team — Airlinq  
**Automation Server:** 10.221.86.73 · Path: `/opt/Automation/STC`  
**Last updated:** 2026-04-29
