# STC Automation — User Manual

> **One-stop guide** for setting up, configuring, and running the STC CMP test automation framework on the **QE environment**.
> Covers every step from a clean machine to receiving the HTML email report.

---

## Table of Contents

1. [What This Framework Does](#1-what-this-framework-does)
2. [System Pre-requisites](#2-system-pre-requisites)
3. [Install — Step-by-Step](#3-install--step-by-step)
4. [Configuration Reference](#4-configuration-reference)
5. [Running the Sanity Suite on QE](#5-running-the-sanity-suite-on-qe)
6. [Running the E2E Flow With Usage on QE](#6-running-the-e2e-flow-with-usage-on-qe)
7. [Email Reports](#7-email-reports)
8. [Where to Find Your Results](#8-where-to-find-your-results)
9. [Troubleshooting Quick Reference](#9-troubleshooting-quick-reference)

---

## 1. What This Framework Does

| | |
|---|---|
| **Application under test** | STC CMP (Connectivity Management Platform) — React web app on https://10.121.77.45:8089 (QE) |
| **Automation framework** | Robot Framework 6.x + SeleniumLibrary + RequestsLibrary |
| **Language** | Python 3.9+ |
| **Test runner** | `run_tests.py` (central wrapper — always use this, not raw `robot`) |
| **Total coverage** | **1,042 test cases across 30 test suites + 1 diagnostic utility** |
| **Supported browsers** | Chrome, Headless Chrome, Firefox, Edge |
| **Report formats** | HTML (Robot), combined log/report, PDF executive summary, HTML email |

---

## 2. System Pre-requisites

Before you install, make sure your machine has the following. The framework is tested on Windows 10/11 and Linux (RHEL 7+/Ubuntu 20+).

### 2.1 Operating System Packages

#### Windows

| Item | How to Install |
|---|---|
| **Python 3.9+** | https://python.org/downloads → tick **"Add Python to PATH"** during install |
| **Google Chrome** | Latest stable from https://chrome.com |
| **Git** | https://git-scm.com/download/win |

#### Linux (RHEL / CentOS) — via RPM

```bash
sudo yum install -y python39 python39-pip python39-devel git
sudo yum install -y gcc openssl-devel libffi-devel bzip2-devel   # Python build deps
sudo yum install -y google-chrome-stable                          # from Chrome repo
sudo yum install -y wget unzip xorg-x11-server-Xvfb                # headless support
```

#### Linux (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y python3.9 python3.9-venv python3-pip git
sudo apt install -y libxss1 libnss3 libgbm1                        # Chrome runtime deps
# Chrome from Google's APT repo:
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
sudo apt update && sudo apt install -y google-chrome-stable
```

### 2.2 ChromeDriver

ChromeDriver is **auto-resolved at runtime** by Selenium Manager (built into SeleniumLibrary 6.1+). You do **not** need to download or place chromedriver manually. If you see a `SessionNotCreatedException`, check that your local Chrome version is recent (the framework is tested up to Chrome 147).

### 2.3 Network Access

The machine running tests must reach:

| Target | Purpose |
|---|---|
| `https://10.121.77.45:8089` | STC CMP QE application |
| `stc-db-qe.internal` (MySQL port 3306) | Captcha + account ID lookups |
| Order processing server (SSH port 22) | E2E Step 9 / 12 run server scripts |
| `smtp.gmail.com:587` | Sending email reports (if `--email` used) |
| `airlinq-global.atlassian.net` | Jira bug logger (optional) |

If you are on a restricted corporate network, confirm VPN + firewall rules before running.

---

## 3. Install — Step-by-Step

### 3.1 Clone the Repository

```bash
git clone https://github.com/peeyush-tm/stc-robot-automation.git
cd stc-robot-automation
```

Switch to the latest branch (if your tree lead hasn't merged it to `master` yet):
```bash
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
python3 -m venv venv
source venv/bin/activate
```

Your prompt should now show `(venv)` — every subsequent command must be run with the venv activated.

### 3.3 Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

This installs:

| Package | Purpose |
|---|---|
| `robotframework` | Core test framework |
| `robotframework-seleniumlibrary` | Browser automation |
| `robotframework-requests` | REST/SOAP API calls |
| `robotframework-databaselibrary` + `pymysql` | MySQL captcha/account queries |
| `robotframework-sshlibrary` | SSH to order processing server (E2E) |
| `pabot` | Parallel execution for `--parallel N` |
| `reportlab`, `pandas`, `openpyxl` | PDF + invoice report generation |
| `jira` | Jira bug logger |

### 3.4 Create Your `.env` File

Copy the template and fill in your credentials:

```bash
cp .env.example .env
```

Open `.env` in any editor and update the values — see [Section 4.2](#42-email-and-jira-credentials-env).

### 3.5 Verify Install

Run a quick self-test:

```bash
python run_tests.py --suite "Login" --env qe --test "TC_LOGIN_001*"
```

Expected: a Chrome window opens, the framework logs in, and the test passes in ~30 seconds. If this works, the install is good.

---

## 4. Configuration Reference

The framework reads configuration from **two** sources:

| File | Purpose | Committed to git? |
|---|---|---|
| `config/<env>.json` | Environment URLs, test accounts, DB/SSH hosts | Yes |
| `.env` | SMTP credentials, Jira API token | **No** (gitignored) |

### 4.1 Environment Config (`config/qe.json`)

Key entries you may need to customise:

| Key | Example | What it controls |
|---|---|---|
| `BASE_URL` | `https://10.121.77.45:8089` | Main CMP URL |
| `VALID_USERNAME` | `qe.user@stc.local` | Login user |
| `VALID_PASSWORD` | `***` | Login password |
| `DEFAULT_EC_ACCOUNT` | `AQ_AUTO_EC_…` | Fallback EC account for non-E2E tests |
| `DEFAULT_BU_ACCOUNT` | `AQ_AUTO_BU_…` | Fallback BU account |
| `DB_HOST` / `DB_PORT` / `DB_NAME` | `stc-db-qe.internal` / `3306` / `stc_cmp` | MySQL for captcha + account lookup |
| `DB_USER` / `DB_PASS` | `qe_reader` / `***` | MySQL credentials |
| `SSH_HOST` / `SSH_USER` / `SSH_PASS` | Order processing server details | E2E Steps 9 / 12 |
| `USAGE_API_URL` | Usage injection endpoint | E2E Step 16a |
| `INVOICE_API_URL` + `INVOICE_SSH_*` | Invoice generation API + CSV download | E2E Step 17 |
| `SIM_RANGE_ICCID_FROM/TO` | `8992431100267457033` / `…042` | Deterministic SIM Range values |
| `SIM_RANGE_IMSI_FROM/TO` | `420023027457473` / `…482` | Deterministic IMSI values |
| `SIM_RANGE_MSISDN_FROM/TO` | `96650200022` / `…031` | Deterministic MSISDN values |

### 4.2 Email and Jira Credentials (`.env`)

Open `.env` (copied from `.env.example` in Step 3.4) and fill in:

```ini
# ── Email (Gmail SMTP recommended — use App Password, not account password) ──
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-16-char-gmail-app-password
EMAIL_FROM=your-email@gmail.com
EMAIL_TO=recipient1@airlinq.com,recipient2@airlinq.com

# ── Metadata shown in email subject / header ──
CLIENT=STC
ENV=QE

# ── Jira (only needed if you run jira_bug_logger.py) ──
JIRA_BASE_URL=https://airlinq-global.atlassian.net
JIRA_EMAIL=your-email@airlinq.com
JIRA_API_TOKEN=your-api-token
JIRA_PROJECT_KEY=STC
JIRA_ISSUE_TYPE=Bug
```

> **Gmail App Password:** For `SMTP_PASS` with Gmail, you must use a [Google App Password](https://myaccount.google.com/apppasswords), not your regular Gmail password. Enable 2FA first, then generate an App Password for "Mail".

> **Multiple recipients:** `EMAIL_TO` accepts comma-separated addresses — no spaces around the commas.

---

## 5. Running the Sanity Suite on QE

The **Sanity suite** validates that 48 key pages in the CMP app load without JS errors, network failures, or missing grids. Runs in ~15 min sequential, ~5 min with `--parallel 4`.

### 5.1 Quickstart — Sanity on QE

```bash
python run_tests.py --sanity --env qe
```

### 5.2 Recommended — Parallel + Email

```bash
python run_tests.py --sanity --env qe --parallel 4 --email
```

| Flag | What it does |
|---|---|
| `--sanity` | Runs `tests/sanity_tests.robot` (48 page-load checks) |
| `--env qe` | Loads `config/qe.json` |
| `--parallel 4` | Runs 4 browsers in parallel via `pabot` (~3× faster) |
| `--email` | Sends HTML report to `EMAIL_TO` on completion |

### 5.3 Sanity Variations

```bash
# Only pages tagged 'smoke' (a curated subset)
python run_tests.py --sanity --env qe --include smoke

# Skip Device Plan and Rule Engine page checks
python run_tests.py --sanity --env qe --skip-test "*Device Plan*" --skip-test "*Rule Engine*"

# Headless (no visible browser — good for CI)
python run_tests.py --sanity --env qe --browser headlesschrome

# Re-run only failures from a previous run
python run_tests.py --sanity --env qe --rerunfailed reports/2026-04-22_13-00-00
```

**→ See [SANITY_TESTS_GUIDE.md](SANITY_TESTS_GUIDE.md) for a detailed breakdown of all 48 sanity test cases, grouped by CMP module.**

---

## 6. Running the E2E Flow With Usage on QE

The **E2E Flow With Usage** exercises the **full SIM lifecycle end-to-end** — from customer onboarding through usage injection and invoicing. 22 sequential steps, ~1.5 hour runtime.

### 6.1 Quickstart — E2E With Usage on QE

```bash
python run_tests.py --e2e-with-usage --env qe
```

### 6.2 Recommended — With Email and Chrome Override

```bash
python run_tests.py --e2e-with-usage --env qe --email
```

> The E2E flow must run **headed Chrome** on QE (some popups behave differently headless). Do not add `--browser headlesschrome` unless you have tested on your environment.

### 6.3 E2E Variations

```bash
# Skip a specific step (for example, skip invoice step if invoice server is down)
python run_tests.py --e2e-with-usage --env qe --skip-test "Step 17*"

# Resume from a middle step — pass required state from a prior run
python run_tests.py tests/e2e_flow_with_usage.robot --env qe --test "Step 16a*" --test "Step 16b*" \
    --variable E2E_EC_NAME:AQ_AUTO_EC_20260422140426 \
    --variable E2E_BU_NAME:AQ_AUTO_BU_20260422140426

# Just re-run failed steps from a specific run
python run_tests.py --e2e-with-usage --env qe --rerunfailed reports/2026-04-22_14-03-08
```

**→ See [E2E_FLOW_WITH_USAGE_GUIDE.md](E2E_FLOW_WITH_USAGE_GUIDE.md) for a step-by-step walkthrough of all 22 E2E steps, including what each step does, its dependencies, and typical runtime.**

---

## 7. Email Reports

When `--email` is passed, after the run completes the framework sends an HTML email with:

| Section | Content |
|---|---|
| **Subject** | `[STC][QE] Test Run Summary — 2026-04-22 — 45/48 PASSED` |
| **Header** | Client, Env, run timestamp |
| **Donut chart** | Pass / Fail / Skip percentages |
| **Summary table** | Per-suite counts, duration, status |
| **Failed Tests** | Each failure with error snippet + first screenshot |
| **Attachments** | `combined_log.html` (full Robot log), `combined_report.html`, `execution_report.pdf` |

### 7.1 Testing Email Config Without Running Tests

```bash
python send_report.py reports/2026-04-22_13-00-00
```

(Points at any past run folder and sends the email without re-running tests — useful to verify SMTP credentials.)

### 7.2 Common Email Issues

| Symptom | Fix |
|---|---|
| "Authentication failed" | Regenerate Gmail App Password; ensure `SMTP_PASS` has no spaces |
| "Could not connect to SMTP" | Firewall blocking port 587 — try `SMTP_PORT=465` with TLS |
| Email not received | Check spam folder; verify `EMAIL_TO` is correct (no typos) |

---

## 8. Where to Find Your Results

Every run creates `reports/<YYYY-MM-DD_HH-MM-SS>/` with:

```
reports/2026-04-22_14-03-08/
├── combined_report.html       ← open this first — top-level pass/fail dashboard
├── combined_log.html          ← drill-down per test case, with screenshots
├── combined_output.xml        ← Robot XML (for custom tools)
├── execution_report.pdf       ← PDF exec summary
├── stc_test_data.json         ← machine-readable data (for email report)
└── E2E_Flow_With_Usage/       ← per-suite subfolders with screenshots
    ├── Step_1b_Verify_Onboa_step_01_PASS.png
    ├── Step_5b_Expand_EC_An_step_02_sm_add_imsi_confirmed.png
    └── ...
```

Bug reports (auto-generated from failures) go to `bugs/Bug_<N>_<timestamp>/`.

---

## 9. Troubleshooting Quick Reference

| Problem | First Thing to Try |
|---|---|
| `python: command not found` | On Linux, use `python3` or add `alias python=python3` |
| `ModuleNotFoundError: robotframework` | You forgot to activate venv. Run `.\venv\Scripts\Activate.ps1` (Win) or `source venv/bin/activate` (Linux) |
| Chrome version / chromedriver mismatch | Update Chrome to latest stable; Selenium Manager handles the driver |
| "Element not visible after 30 seconds" | Browser started at 800×600 → viewport fix already in `browser_keywords.resource`. If still failing, set `STC_CHROME_HEADED_WINDOW_SIZE=1920,1080` |
| Captcha DB connection refused | Check VPN is connected; verify `DB_HOST` in `config/qe.json` |
| E2E Step 9 / 12 SSH timeout | Verify `SSH_HOST` reachable from your machine; try `ssh user@host` manually |
| Email sent but no attachment | Gmail attachment limit 25 MB — very large runs split the log. Open `combined_log.html` in the report folder instead |
| `WebDriverException: failed to change window state` | Already fixed in latest `browser_keywords.resource` (see commit 41a9458) — pull latest |

For issues not covered here, open the Robot log (`combined_log.html`) and scroll to the first red (failed) keyword. The keyword name + error message usually pinpoints the root cause.

---

## Related Documents

| Document | What It Covers |
|---|---|
| [README.md](../README.md) | Top-level project overview + module table |
| [SETUP_AND_RUN_GUIDE.md](SETUP_AND_RUN_GUIDE.md) | The original detailed setup + run reference (longer, more CLI flag options) |
| [SANITY_TESTS_GUIDE.md](SANITY_TESTS_GUIDE.md) | All 48 sanity test cases catalogued |
| [E2E_FLOW_WITH_USAGE_GUIDE.md](E2E_FLOW_WITH_USAGE_GUIDE.md) | All 22 E2E steps explained |
| [../CLAUDE.md](../CLAUDE.md) | AI assistant framework instructions (also the canonical module list) |
| [../prompts/ALL_MODULES_AND_TESTCASES.md](../prompts/ALL_MODULES_AND_TESTCASES.md) | Every module's TC ID ranges + run commands |

---

**Maintained by:** STC Automation Team — Airlinq
**Last updated:** 2026-04-22
