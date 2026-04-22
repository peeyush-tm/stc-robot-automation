# STC Automation — Setup & Run Guide

> **Framework**: Robot Framework + SeleniumLibrary  
> **Runner**: `run_tests.py` (central entry point for all execution modes)  
> **Reports**: All artifacts land in `reports/<timestamp>/`

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Project Structure](#2-project-structure)
3. [Installation](#3-installation)
4. [Configuration](#4-configuration)
5. [Running Tests](#5-running-tests)
   - [5.1 Quick Reference](#51-quick-reference)
   - [5.2 Run All Suites](#52-run-all-suites)
   - [5.3 Run a Specific Suite](#53-run-a-specific-suite)
   - [5.4 Run by Tag](#54-run-by-tag)
   - [5.5 E2E Flow A — Without Usage](#55-e2e-flow-a--without-usage)
   - [5.6 E2E Flow B — With Usage](#56-e2e-flow-b--with-usage)
   - [5.7 Sanity Suite](#57-sanity-suite)
   - [5.8 Framework Mode (CSV-Driven)](#58-framework-mode-csv-driven)
   - [5.9 API-Only / UI-Only Runs](#59-api-only--ui-only-runs)
   - [5.10 Partial E2E Runs (Skip Earlier Steps)](#510-partial-e2e-runs-skip-earlier-steps)
6. [Running via Shell Scripts (run.bat / run.sh)](#6-running-via-shell-scripts-runbat--runsh)
7. [Environment & Browser Overrides](#7-environment--browser-overrides)
8. [Reports & Artifacts](#8-reports--artifacts)
9. [Adding a New Test Suite](#9-adding-a-new-test-suite)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Prerequisites

| Requirement | Minimum Version | Notes |
|---|---|---|
| Python | 3.9+ | Must be on `PATH` |
| Google Chrome | Latest | For default `chrome` browser |
| ChromeDriver | Matching Chrome version | Must be on `PATH` or managed by SeleniumLibrary |
| Firefox + GeckoDriver | Latest | Only needed if using `--browser firefox` |
| Git | Any | For cloning the repository |

> **Windows users**: ChromeDriver must be available in `PATH` or placed in the `bin/` folder.

---

## 2. Project Structure

```
stc-automation/
├── run_tests.py                  ← Central test runner (always use this)
├── tasks.csv                     ← Master list of all suites & test cases
├── requirements.txt              ← Python dependencies
│
├── bin/
│   ├── STCFramework.robot        ← CSV-driven framework entry point
│   ├── run.bat                   ← Windows wrapper for run_tests.py
│   ├── run.sh                    ← Linux/Mac wrapper for run_tests.py
│   ├── setall.bat                ← Sets PYTHONPATH & activates venv (Windows)
│   └── setall.sh                 ← Sets PYTHONPATH & activates venv (Linux/Mac)
│
├── tests/                        ← All Robot Framework test suites (31 files)
│   ├── Core Modules (25)
│   │   ├── login_tests.robot
│   │   ├── apn_tests.robot
│   │   ├── sim_range_tests.robot
│   │   ├── sim_range_msisdn_tests.robot
│   │   ├── sim_order_tests.robot
│   │   ├── sim_movement_tests.robot
│   │   ├── sim_replacement_tests.robot
│   │   ├── device_plan_tests.robot
│   │   ├── device_state_tests.robot
│   │   ├── ip_pool_tests.robot
│   │   ├── ip_whitelist_tests.robot
│   │   ├── cost_center_tests.robot
│   │   ├── csr_journey_tests.robot
│   │   ├── product_type_tests.robot
│   │   ├── rule_engine_tests.robot
│   │   ├── role_management_tests.robot
│   │   ├── user_management_tests.robot
│   │   ├── role_user_crud_tests.robot
│   │   ├── label_tests.robot
│   │   ├── report_tests.robot
│   │   ├── payg_data_usage_tests.robot
│   │   ├── onboard_customer_api_tests.robot
│   │   ├── sanity_tests.robot
│   │   ├── e2e_flow.robot                   ← E2E Flow A (17 steps)
│   │   └── e2e_flow_with_usage.robot        ← E2E Flow B (20 steps + usage)
│   ├── Feature Suites (5 — deep per-page UI coverage)
│   │   ├── csr_journey_feature_tests.robot       (213 TCs)
│   │   ├── manage_devices_feature_tests.robot    (43 TCs)
│   │   ├── device_apn_feature_tests.robot        (35 TCs)
│   │   ├── device_vas_charges_feature_tests.robot (6 TCs)
│   │   └── setup_prerequisite_feature_tests.robot (4 TCs)
│   └── Diagnostic Utility (not part of regression)
│       └── diagnose_qe_locators.robot            ← logs DOM state on QE locator failures
│
├── config/
│   ├── dev.json                  ← dev environment config (default)
│   ├── staging.json              ← staging environment config
│   ├── prod.json                 ← production environment config
│   └── qe.json                  ← QE environment config
│
├── variables/                    ← Robot variable files (per suite)
├── resources/
│   ├── keywords/                 ← Shared Robot keyword resources
│   └── locators/                 ← Page locator resources
├── libraries/
│   ├── ConfigLoader.py           ← Loads JSON config into Robot variables
│   ├── DynamicTestCases.py       ← Reads CSVs and generates test cases
│   └── FrameworkCSV.py           ← CSV parsing for STCFramework.robot
│
├── suites/                       ← Suite registry for Framework Mode
│   └── suites.csv
├── data/                         ← Test data per environment
├── billing/                      ← Local folder for invoice CSV downloads
│                                   (E2E Step 17 — files land in reports/<run>/billing/)
└── reports/                      ← All run artifacts (auto-created, git-ignored)
    └── <timestamp>/
        ├── combined_report.html
        ├── combined_log.html
        ├── combined_output.xml
        ├── output_1_<suite>.xml
        └── billing/              ← Invoice CSVs downloaded during E2E
```

---

## 3. Installation

### Step 1 — Clone the repository

```bash
git clone <repo-url>
cd stc-automation
```

### Step 2 — Create a virtual environment (recommended)

**Windows:**
```cmd
python -m venv venv
venv\Scripts\activate
```

**Linux / Mac:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### Step 3 — Install Python dependencies

```bash
pip install -r requirements.txt
```

This installs:

| Package | Purpose |
|---|---|
| `robotframework` | Core test framework |
| `robotframework-seleniumlibrary` | Browser automation |
| `robotframework-requests` | REST API testing |
| `robotframework-databaselibrary` | MySQL test data queries |
| `robotframework-sshlibrary` | SSH commands for E2E flows |
| `pymysql` | MySQL driver for DatabaseLibrary |
| `reportlab` | PDF report generation (optional utility) |
| `python-docx` | Word document report generation (optional utility) |

### Step 4 — Verify installation

```bash
python -m robot --version
python run_tests.py --help
```

---

## 4. Configuration

All environment settings are stored in `config/<env>.json`. The runner loads the matching file based on the `--env` argument (default: `dev`).

### Available environments

| Flag | Config file | Default browser |
|---|---|---|
| `--env dev` *(default)* | `config/dev.json` | `chrome` (visible) |
| `--env staging` | `config/staging.json` | `chrome` (visible) |
| `--env prod` | `config/prod.json` | `chrome` (visible) |
| `--env qe` | `config/qe.json` | `headlesschrome` |

### Key config fields (`config/dev.json`)

```json
{
  "BASE_URL":        "https://192.168.1.26:7874/",
  "VALID_USERNAME":  "ksa_opco",
  "VALID_PASSWORD":  "Admin@123",
  "BROWSER":         "chrome",
  "IMPLICIT_WAIT":   "3",
  "DB_HOST":         "192.168.1.122",
  "DB_PORT":         "3306",
  "DB_NAME":         "stc_s5_p1",
  "SSH_HOST":        "10.121.77.94",
  "INVOICE_API_URL": "http://10.121.77.114:8083/invoice-processor/...",
  "USAGE_API_BASE_URL": "http://10.121.77.112:8080/backend/st/json"
}
```

> To override the browser at runtime without editing the file, use the `--browser` flag (see [Section 7](#7-environment--browser-overrides)).

---

## 5. Running Tests

> **Rule**: Always use `run_tests.py`. Never call `python -m robot` directly.

### 5.1 Quick Reference

```bash
# All suites (reads tasks.csv)
python run_tests.py

# Specific suite file
python run_tests.py tests/login_tests.robot

# Suite by name
python run_tests.py --suite Login
python run_tests.py --suite APN
python run_tests.py --suite "Device Plan"

# E2E flows
python run_tests.py --e2e
python run_tests.py --e2e-with-usage

# Sanity suite
python run_tests.py --sanity

# Framework mode
python run_tests.py --framework

# Tag filter
python run_tests.py --include smoke
python run_tests.py --exclude wip

# Environment / browser override
python run_tests.py --env staging --browser headlesschrome
```

---

### 5.2 Run All Suites

Reads `tasks.csv` and executes every active suite in order.

```bash
python run_tests.py
```

---

### 5.3 Run a Specific Suite

**By file path:**
```bash
python run_tests.py tests/login_tests.robot
python run_tests.py tests/apn_tests.robot
python run_tests.py tests/device_plan_tests.robot
```

**By module name (resolved from `tasks.csv`):**
```bash
python run_tests.py --suite Login
python run_tests.py --suite APN
python run_tests.py --suite "SIM Range"
python run_tests.py --suite "Device Plan"
python run_tests.py --suite "Role Management"
python run_tests.py --suite "User Management"
python run_tests.py --suite "Account Onboard"
python run_tests.py --suite "E2E Flow"
```

**Run a feature suite (deep per-page UI coverage):**
```bash
# Run by file path — feature suites are not in tasks.csv
python run_tests.py tests/csr_journey_feature_tests.robot       # 213 TCs
python run_tests.py tests/manage_devices_feature_tests.robot     # 43 TCs
python run_tests.py tests/device_apn_feature_tests.robot         # 35 TCs
python run_tests.py tests/device_vas_charges_feature_tests.robot # 6 TCs
python run_tests.py tests/setup_prerequisite_feature_tests.robot # 4 TCs
```

**Run a single test case by name:**
```bash
python run_tests.py tests/apn_tests.robot --test "TC_APN_001*"
python run_tests.py tests/login_tests.robot --test "TC_LOGIN_001*"
python run_tests.py tests/csr_journey_feature_tests.robot --test "TC_CSRJ_10*"
```

**Diagnostic utility** (logs DOM state, no assertions — use when a locator fails only on QE):
```bash
python run_tests.py tests/diagnose_qe_locators.robot --env qe
```

---

### 5.4 Run by Tag

```bash
python run_tests.py --include smoke
python run_tests.py --include regression
python run_tests.py --include sim_range
python run_tests.py --exclude wip
```

---

### 5.5 E2E Flow A — Without Usage

Runs `tests/e2e_flow.robot` — 17-step end-to-end order lifecycle.

```bash
# Visible Chrome (default)
python run_tests.py --e2e

# Headless Chrome
python run_tests.py --e2e --browser headlesschrome

# Stop on first failure
python run_tests.py --e2e --exitonfailure

# With CRUD tests appended after E2E
python run_tests.py --e2e --with-crud

# Specific environment
python run_tests.py --e2e --env staging
```

---

### 5.6 E2E Flow B — With Usage

Runs `tests/e2e_flow_with_usage.robot` — 20-step flow including usage injection.

```bash
# Visible Chrome (default)
python run_tests.py --e2e-with-usage

# Headless Chrome
python run_tests.py --e2e-with-usage --browser headlesschrome

# Stop on first failure
python run_tests.py --e2e-with-usage --exitonfailure
```

---

### 5.7 Sanity Suite

Runs `tests/sanity_tests.robot` — smoke check across all portal pages.

```bash
# Sequential (default)
python run_tests.py --sanity

# Parallel with pabot (4 processes)
python run_tests.py --sanity --parallel 4

# Headless
python run_tests.py --sanity --browser headlesschrome
```

> Screenshots for each page are saved to `reports/<timestamp>_sanity/`.

---

### 5.8 Framework Mode (CSV-Driven)

Runs `bin/STCFramework.robot` which dynamically discovers test files and variable files based on `suites/suites.csv` and convention-based naming.

```bash
# Run all active suites in suites.csv
python run_tests.py --framework

# Filter to a specific suite
python run_tests.py --framework --suite Login
python run_tests.py --framework --suite APN

# Headless + specific environment
python run_tests.py --framework --env staging --browser headlesschrome
```

---

### 5.9 API-Only / UI-Only Runs

```bash
# Only API test suites
python run_tests.py --api

# Only UI test suites
python run_tests.py --ui
```

---

### 5.10 Partial E2E Runs (Skip Earlier Steps)

When an E2E run has already completed earlier steps and you want to resume from a later step, pass the previously captured variables to skip re-running the setup steps.

**Flow A — Resume from Step 16 onwards:**

```bash
# Windows (cmd / PowerShell)
python run_tests.py --e2e `
  --test "Step 16*" --test "Step 17*" `
  --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 `
  --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 `
  --variable E2E_ORDER_ID:101076 `
  --variable E2E_EC_ID:29421 `
  --variable E2E_BU_ID:29422
```

**Flow B — Resume from Step 16a onwards:**

```bash
python run_tests.py --e2e-with-usage `
  --test "Step 16a*" --test "Step 17*" `
  --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 `
  --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 `
  --variable E2E_ORDER_ID:101076 `
  --variable E2E_EC_ID:29421 `
  --variable E2E_BU_ID:29422
```

**Variables required when skipping steps:**

| Variable | Source step | Description |
|---|---|---|
| `E2E_EC_NAME` | Step 1 | EC account name created during onboarding |
| `E2E_BU_NAME` | Step 1 | BU account name created during onboarding |
| `E2E_ORDER_ID` | Step 7 | SIM order ID |
| `E2E_EC_ID` | Step 8 | EC account database ID |
| `E2E_BU_ID` | Step 8 | BU account database ID |
| `E2E_IMSI_DATA` | Step 16 | List of `{imsi, msisdn}` pairs (needed for Step 16a) |

---

## 6. Running via Shell Scripts (run.bat / run.sh)

The shell scripts are thin wrappers around `run_tests.py`. They read environment variables and translate them into `run_tests.py` arguments.

### Windows — `bin/run.bat`

**Setup (once per terminal session):**
```cmd
cd d:\stc-automation
call bin\setall.bat
```

**Run examples:**
```cmd
REM Run all suites, dev environment
bin\run.bat

REM Run specific suite via TESTPLAN
set TESTPLAN=Login
bin\run.bat

REM Run with staging environment, headless
set PROFILE=staging
set BROWSER=headlesschrome
bin\run.bat

REM Run with a custom run name (creates reports\MyRun_<timestamp>\)
set RUNNAME=MyRun
bin\run.bat

REM Framework mode
set FRAMEWORK=1
bin\run.bat
```

### Linux / Mac — `bin/run.sh`

**Setup (once per terminal session):**
```bash
cd /path/to/stc-automation
source bin/setall.sh
```

**Run examples:**
```bash
# Run all suites
bin/run.sh

# Staging + headless
PROFILE=staging BROWSER=headlesschrome bin/run.sh

# Custom run name
RUNNAME=MyRun bin/run.sh

# Framework mode
FRAMEWORK=1 bin/run.sh
```

### Environment variables supported by the shell scripts

| Variable | Equivalent `run_tests.py` arg | Example |
|---|---|---|
| `PROFILE` | `--env` | `PROFILE=staging` |
| `BROWSER` | `--browser` | `BROWSER=headlesschrome` |
| `TESTPLAN` | `--suite` | `TESTPLAN=Login` |
| `TAGS` | `--include` | `TAGS=smoke` |
| `RUNNAME` | `--outputdir reports/<RUNNAME>_<timestamp>` | `RUNNAME=Sprint42` |
| `FRAMEWORK` | `--framework` | `FRAMEWORK=1` |

---

## 7. Environment & Browser Overrides

### Browser options

| Value | Description |
|---|---|
| `chrome` | Visible Chrome window (default for `dev`) |
| `headlesschrome` | Headless Chrome, no visible window |
| `firefox` | Visible Firefox window |

The `--browser` flag always wins over whatever is set in the JSON config file.

```bash
# Force headless regardless of config
python run_tests.py --browser headlesschrome

# Force visible chrome even on qe (which defaults to headless)
python run_tests.py --env qe --browser chrome
```

### Variable overrides

Any Robot Framework variable can be overridden at the command line:

```bash
python run_tests.py --variable BASE_URL:https://my-custom-host:7874/
python run_tests.py --variable IMPLICIT_WAIT:10
```

---

## 8. Reports & Artifacts

All artifacts are written to a single timestamped folder under `reports/`.

```
reports/
└── 2026-03-20_14-30-00/          ← plain run (tasks.csv)
└── 2026-03-20_14-35-00_e2e/      ← E2E Flow A
└── 2026-03-20_14-40-00_e2e_usage/ ← E2E Flow B
└── 2026-03-20_14-45-00_sanity/   ← sanity suite
└── 2026-03-20_14-50-00_framework/ ← framework mode
```

### Files generated per run

| File | Description |
|---|---|
| `combined_report.html` | High-level pass/fail HTML report |
| `combined_log.html` | Detailed execution log with screenshots |
| `combined_output.xml` | Merged XML for further processing |
| `output_1_<suite>.xml` | Per-suite raw XML output |
| `*.png` | Screenshots captured during test steps |
| `billing/*.csv` | Invoice CSV files downloaded in E2E Step 17 |

> The `reports/` folder is **git-ignored**. Only `reports/.gitkeep` is tracked to preserve the folder in version control.

---

## 9. Adding a New Test Suite

1. **Create the robot file** in `tests/`:
   ```
   tests/my_feature_tests.robot
   ```

2. **Create a variables file** in `variables/`:
   ```
   variables/my_feature_variables.py
   ```

3. **Register in `tasks.csv`** — add rows with:
   ```
   module,suite_file,test_id,test_name,...
   My Feature,tests/my_feature_tests.robot,TC_MF_001,My first test,...
   ```

4. **(Framework Mode only)** Register in `suites/suites.csv`:
   ```csv
   order,suite_id,suite_name,active
   20,My_Feature,My Feature,true
   ```
   - If the naming convention matches (`tests/my_feature_tests.robot`, `variables/my_feature_variables.py`), discovery is automatic.
   - To use custom paths, add `test_file` and `variables_file` columns.

5. **Run it:**
   ```bash
   python run_tests.py --suite "My Feature"
   ```

---

## 10. Troubleshooting

### ChromeDriver version mismatch

```
SessionNotCreatedException: ChromeDriver only supports Chrome version X
```

**Fix:** Download the matching ChromeDriver from https://chromedriver.chromium.org/downloads and place it on `PATH`.

---

### `ModuleNotFoundError` for libraries

```
ModuleNotFoundError: No module named 'robot'
```

**Fix:** Activate your virtual environment before running:
```cmd
venv\Scripts\activate      # Windows
source venv/bin/activate   # Linux/Mac
```
Then re-run `pip install -r requirements.txt`.

---

### Tests use wrong environment / browser

The JSON config browser is overridden by `--browser`. If you're not seeing the expected browser:
- Confirm you're passing `--browser chrome` (not relying on config defaults).
- Check `config/<env>.json` to see what `BROWSER` is set to for your environment.

---

### Reports not appearing in `reports/`

- Ensure the `reports/` folder exists (it is created automatically on first run but may be missing if git-ignored `.gitkeep` was deleted).
- Manually create it: `mkdir reports`

---

### SSH / DB connection errors in E2E

E2E tests connect to internal infrastructure (SSH, MySQL, SOAP services). These only work from within the **STC internal network**.

Verify connectivity:
```bash
ping 10.121.77.94       # SSH order server
ping 192.168.1.122      # DB host
ping 10.121.77.114      # Invoice server
```

---

### `pabot` not found (parallel sanity run)

```
'pabot' is not recognized as an internal or external command
```

**Fix:**
```bash
pip install robotframework-pabot
```

---

## 11. Bug Reports, Email Notifications & Jira Integration

### Automatic Bug Reports

Bug reports are automatically generated after every test run when failures are detected. Each failed test gets its own folder under `bugs/` containing:
- A structured `.txt` bug report with title, environment, description, steps, expected/actual results
- A `screenshot/` subfolder with relevant screenshots

```bash
# Bug reports generate automatically after every run — no extra flag needed
python run_tests.py --suite "Login" --env qe

# Standalone generation for a past run
python bug_reporter.py reports/2026-04-15_10-30-00
```

Bug folder format: `bugs/Bug_<N>_<DDMonYY>_<HHMMSS>/`

### Email Reports

Send professional HTML email reports with:
- Circular progress indicator (donut chart)
- Pass/fail/skip counts with percentages
- Execution metadata (start time, duration, environment)
- Table of failed tests with error messages
- Attached `combined_report.html` and PDF report

```bash
# Via run_tests.py (add --email flag)
python run_tests.py --suite "Login" --env qe --email
python run_tests.py --e2e --env qe --email

# Standalone for a past run
python send_report.py reports/2026-04-15_10-30-00
```

### Jira Bug Logger

Push generated bug reports to Jira with structured descriptions and screenshots attached.

```bash
python jira_bug_logger.py              # Interactive — pick which bugs to log
python jira_bug_logger.py --all        # Push ALL unlogged bugs
python jira_bug_logger.py --list       # List all bugs and their Jira status
python jira_bug_logger.py Bug_1_15Apr26_134003  # Push specific bug
```

### Email & Jira Configuration

1. Copy `.env.example` to `.env` in the project root
2. Fill in your values:

```ini
# ── Email (Gmail SMTP) ──────────────────────────
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
EMAIL_FROM=your-email@gmail.com
EMAIL_TO=recipient1@airlinq.com,recipient2@airlinq.com

# ── Display Settings ────────────────────────────
CLIENT=STC
ENV=QE

# ── Jira ────────────────────────────────────────
JIRA_BASE_URL=https://airlinq-global.atlassian.net
JIRA_EMAIL=your-email@airlinq.com
JIRA_API_TOKEN=your-jira-api-token
JIRA_PROJECT_KEY=STC
JIRA_ISSUE_TYPE=Bug
```

**Gmail App Password:** Go to myaccount.google.com > Security > 2-Step Verification > App Passwords. Create a new app password and use it as `SMTP_PASS`.

**Jira API Token:** Go to https://id.atlassian.com/manage-profile/security/api-tokens and create a new token.
