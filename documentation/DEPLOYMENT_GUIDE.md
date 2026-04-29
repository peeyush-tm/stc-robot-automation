# STC Automation — First-Time Server Deployment Guide

> **Target OS:** Linux (Ubuntu 20.04 / 22.04 or RHEL/CentOS 7+)  
> **Automation Server:** 10.221.86.73 (never touch any other server)  
> **Deploy path:** `/opt/Automation/STC`  
> **User:** `aqadmin`

---

## Table of Contents

1. [Prerequisites Checklist](#1-prerequisites-checklist)
2. [Step 1 — Install Python 3.11](#step-1--install-python-311)
3. [Step 2 — Install Git](#step-2--install-git)
4. [Step 3 — Clone the Repository](#step-3--clone-the-repository)
5. [Step 4 — Create Virtual Environment](#step-4--create-virtual-environment)
6. [Step 5 — Install Python Dependencies](#step-5--install-python-dependencies)
7. [Step 6 — Set Up Headless Chrome](#step-6--set-up-headless-chrome)
8. [Step 7 — Configure the Environment](#step-7--configure-the-environment)
9. [Step 8 — Create .env File](#step-8--create-env-file)
10. [Step 9 — Verify the Installation](#step-9--verify-the-installation)
11. [Step 10 — Run Your First Test](#step-10--run-your-first-test)
12. [Updating the Code (Subsequent Deployments)](#updating-the-code-subsequent-deployments)
13. [Troubleshooting](#troubleshooting)

---

## 1. Prerequisites Checklist

Before starting, confirm the following on the server:

| Item | Required | Notes |
|------|----------|-------|
| Python 3.9+ | ✅ Required | 3.11 recommended |
| Git | ✅ Required | For cloning and updates |
| pip | ✅ Required | Comes with Python |
| Internet access (or PyPI mirror) | ✅ Required | For pip install |
| MySQL / MariaDB connectivity | Optional | Only needed for Login captcha tests |
| SSH connectivity to order/invoice servers | Optional | Only needed for E2E flow tests |
| Display / Xvfb | ❌ Not needed | Headless Chrome is used on server |

---

## Step 1 — Install Python 3.11

**Ubuntu / Debian:**
```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3.11-dev
```

**RHEL / CentOS:**
```bash
sudo yum install -y python3 python3-venv python3-devel
```

**Verify:**
```bash
python3.11 --version
# Expected: Python 3.11.x
```

---

## Step 2 — Install Git

**Ubuntu / Debian:**
```bash
sudo apt install -y git
```

**RHEL / CentOS:**
```bash
sudo yum install -y git
```

**Verify:**
```bash
git --version
```

---

## Step 3 — Clone the Repository

```bash
sudo mkdir -p /opt/Automation
sudo chown aqadmin:aqadmin /opt/Automation

cd /opt/Automation
git clone <your-git-repo-url> STC
cd STC
```

> Replace `<your-git-repo-url>` with the actual Git remote URL.  
> If the repo is private, set up SSH keys or use a personal access token.

**Verify:**
```bash
ls /opt/Automation/STC
# Should show: run_tests.py  tasks.csv  requirements.txt  config/  tests/  ...
```

---

## Step 4 — Create Virtual Environment

Always use a virtual environment — never install into system Python.

```bash
cd /opt/Automation/STC
python3.11 -m venv venv
source venv/bin/activate
```

**Verify activation:**
```bash
which python
# Expected: /opt/Automation/STC/venv/bin/python

python --version
# Expected: Python 3.11.x
```

> **Important:** You must run `source venv/bin/activate` every time you open a new terminal session before running tests.

---

## Step 5 — Install Python Dependencies

```bash
cd /opt/Automation/STC
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

This installs:

| Package | Version | Purpose |
|---------|---------|---------|
| `robotframework` | 7.0.1 | Core test framework |
| `robotframework-seleniumlibrary` | 6.3.0 | Browser automation |
| `selenium` | 4.18.1 | WebDriver bindings |
| `robotframework-requests` | 0.9.7 | REST API testing |
| `requests` | 2.31.0 | HTTP client |
| `robotframework-sshlibrary` | 3.8.0 | SSH commands for E2E flows |
| `robotframework-databaselibrary` | 1.4.4 | MySQL connectivity |
| `PyMySQL` | 1.1.0 | MySQL driver (no C extension needed) |
| `reportlab` | 4.1.0 | PDF report generation |
| `robotframework-datadriver` | 1.11.2 | Data-driven CSV test generation |

**Verify:**
```bash
python -m robot --version
# Expected: Robot Framework 7.0.1 (Python 3.11.x ...)
```

---

## Step 6 — Set Up Headless Chrome

The server has no display. The framework uses a bundled headless-shell binary and companion libs already committed in `config/browser/`.

### 6a — Verify bundled files exist

```bash
ls /opt/Automation/STC/config/browser/
# Expected: headless-shell/   libs/flat/

ls /opt/Automation/STC/config/browser/headless-shell/
# Expected: headless_shell  (the binary)

ls /opt/Automation/STC/config/browser/libs/flat/ | head -5
# Expected: libatk-1.0.so.0  libnss3.so  libgbm.so.1  ... (shared libs)
```

### 6b — Make the binary executable

```bash
chmod +x /opt/Automation/STC/config/browser/headless-shell/headless_shell
```

### 6c — The runner auto-configures Chrome on Linux

`run_tests.py` automatically sets `STC_CHROME_BINARY` and `LD_LIBRARY_PATH` on Linux using the bundled files. No manual export needed.

However, if you ever need to test manually:
```bash
export STC_CHROME_BINARY=/opt/Automation/STC/config/browser/headless-shell/headless_shell
export LD_LIBRARY_PATH=/opt/Automation/STC/config/browser/libs/flat
```

### 6d — Also install ChromeDriver (must match Chrome version)

SeleniumLibrary needs `chromedriver` on `PATH`. Check the headless-shell version and download the matching chromedriver:

```bash
/opt/Automation/STC/config/browser/headless-shell/headless_shell --version
# Note the version number, e.g. "114.0.5735.90"
```

Download the matching chromedriver:
```bash
# Example for Chrome 114 on Linux x64
wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
chromedriver --version
```

> If you are on a restricted network, download from a reachable mirror or copy the binary from another machine.

---

## Step 7 — Configure the Environment

All environment-specific values are in `config/<env>.json`. The `qe.json` and `sit.json` configs are pre-populated.

### 7a — Check the config you'll use

```bash
# For QE environment
cat /opt/Automation/STC/config/qe.json

# For SIT environment
cat /opt/Automation/STC/config/sit.json
```

### 7b — Key fields to verify/fill

Open the relevant config in any editor:
```bash
vi /opt/Automation/STC/config/qe.json
```

| Field | Description | Example |
|-------|-------------|---------|
| `BASE_URL` | CMP application URL | `"https://10.23.48.35:8443/"` |
| `VALID_USERNAME` | Login username | `"KSA_OPCO"` |
| `VALID_PASSWORD` | Login password | `"Aqadmin@123"` |
| `BROWSER` | Must be `headlesschrome` on server | `"headlesschrome"` |
| `DB_HOST` | MySQL server IP for captcha DB | `"10.23.48.35"` |
| `DB_NAME` | Database name | `"aircontrol"` |
| `DB_USER` | DB username | `"aqadmin"` |
| `DB_PASS` | DB password | `"Aqadmin@123"` |
| `SSH_HOST` | Order processing server IP | `"10.23.x.x"` |
| `DEFAULT_EC_ACCOUNT` | Default EC account for module tests | `"AQ_EC_xxxx"` |
| `DEFAULT_BU_ACCOUNT` | Default BU account for module tests | `"AQ_BU_xxxx"` |

> **BROWSER must be `headlesschrome`** on Linux server. The server has no display — visible Chrome will crash.

### 7c — Ensure reports folder exists

```bash
mkdir -p /opt/Automation/STC/reports
```

---

## Step 8 — Create .env File

The `.env` file holds credentials for email reports and Jira integration. It is git-ignored and must be created manually on each server.

```bash
cd /opt/Automation/STC
cp .env.example .env
vi .env
```

Fill in the values:

```ini
# ── Email (SMTP for send_report.py) ─────────────────────────────────────────
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
EMAIL_FROM=your-email@gmail.com
EMAIL_TO=recipient1@airlinq.com,recipient2@airlinq.com

# ── Display label in email subject / body ────────────────────────────────────
CLIENT=STC
ENV=QE

# ── Jira (for jira_bug_logger.py) ────────────────────────────────────────────
JIRA_BASE_URL=https://airlinq-global.atlassian.net
JIRA_EMAIL=your-email@airlinq.com
JIRA_API_TOKEN=your-jira-api-token
JIRA_PROJECT_KEY=STC
JIRA_ISSUE_TYPE=Bug
```

> Email and Jira are **optional**. If you skip this step, test execution still works — only `--email` flag and `jira_bug_logger.py` will fail.

---

## Step 9 — Verify the Installation

Run these checks in order. All must pass before running real tests.

```bash
cd /opt/Automation/STC
source venv/bin/activate

# 1. Robot Framework version
python -m robot --version

# 2. Selenium library
python -c "from SeleniumLibrary import SeleniumLibrary; print('SeleniumLibrary OK')"

# 3. Requests library
python -c "from RequestsLibrary import RequestsLibrary; print('RequestsLibrary OK')"

# 4. Database library
python -c "from DatabaseLibrary import DatabaseLibrary; print('DatabaseLibrary OK')"

# 5. SSH library
python -c "from SSHLibrary import SSHLibrary; print('SSHLibrary OK')"

# 6. PDF library
python -c "from reportlab.pdfgen import canvas; print('reportlab OK')"

# 7. run_tests.py help
python run_tests.py --help
```

All commands should complete without errors.

---

## Step 10 — Run Your First Test

Start with a quick sanity check — Login suite (12 test cases, ~3 minutes):

```bash
cd /opt/Automation/STC
source venv/bin/activate
python run_tests.py --suite "Login" --env qe
```

**Expected output:**
```
[INFO] Running suite: tests/login_tests.robot
...
12 tests, 12 passed, 0 failed
Output:  reports/2026-xx-xx_xx-xx-xx/output_1_login_tests.xml
Report:  reports/2026-xx-xx_xx-xx-xx/combined_report.html
```

### Then run Sanity (48 tests, ~10 minutes):

```bash
python run_tests.py --sanity --env qe
```

### Other common first-run commands:

```bash
# Full regression (all 662 tests) — takes several hours
python run_tests.py --env qe

# Specific module
python run_tests.py --suite "APN" --env qe
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Label" --env qe

# SIT environment
python run_tests.py --sanity --env sit
python run_tests.py --suite "Login" --env sit

# With email report
python run_tests.py --suite "Login" --env qe --email
```

---

## Updating the Code (Subsequent Deployments)

When new code is pushed to the branch, pull it on the server:

```bash
cd /opt/Automation/STC
source venv/bin/activate

# If you have any uncommitted local changes (e.g. debug edits), stash them first
git stash

# Pull latest from the feature branch
git pull origin feature-branch

# If requirements changed (check requirements.txt for updates)
pip install -r requirements.txt

# Verify
python run_tests.py --help
```

> **Never edit files directly on the server.** All changes must go through Git (commit on local → push → pull on server).

---

## Troubleshooting

### `source venv/bin/activate` must be run every session

The virtual environment is not persistent across SSH sessions. Add it to your workflow:
```bash
cd /opt/Automation/STC && source venv/bin/activate
```

Or add to `~/.bashrc` (auto-activate on login):
```bash
echo "cd /opt/Automation/STC && source venv/bin/activate" >> ~/.bashrc
```

---

### `ModuleNotFoundError: No module named 'robot'`

You're running Python without the venv activated.
```bash
source /opt/Automation/STC/venv/bin/activate
python -m robot --version
```

---

### Chrome fails to start — missing shared libraries

```
[ERROR] Chrome failed to start: exited abnormally
libatk-1.0.so.0: cannot open shared object file
```

The bundled libs in `config/browser/libs/flat/` should fix this automatically via `run_tests.py`. If it persists, install system deps:
```bash
sudo apt install -y libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 libgbm1
```

---

### `ChromeDriver version mismatch`

```
SessionNotCreatedException: ChromeDriver only supports Chrome version X
```

The chromedriver version must match the headless-shell version exactly.
```bash
/opt/Automation/STC/config/browser/headless-shell/headless_shell --version
chromedriver --version
```
Both must show the same major version. Download a matching chromedriver if they differ.

---

### Database connection errors (Login captcha tests)

```
DatabaseError: Can't connect to MySQL server on '...'
```

Check that `DB_HOST` in `config/qe.json` is correct and the server is reachable:
```bash
ping <DB_HOST>
mysql -h <DB_HOST> -u aqadmin -p aircontrol
```

---

### `git pull` blocked by local modifications

```
error: Your local changes to the following files would be overwritten by merge
```

Stash the local changes first:
```bash
git stash
git pull origin feature-branch
git stash pop   # only if you want the local changes back (usually skip this)
```

---

### Port / SSL errors accessing the CMP application

```
ssl.SSLCertVerificationError: certificate verify failed
```

The CMP uses self-signed certificates. SeleniumLibrary ignores SSL errors automatically. If you see this in Python `requests` calls, ensure `verify=False` is set in the relevant keyword or API call.

---

### Reports not generated

```
No reports folder found
```

Create it manually:
```bash
mkdir -p /opt/Automation/STC/reports
```

---

## Quick Reference Card

```bash
# One-time setup
cd /opt/Automation/STC
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
chmod +x config/browser/headless-shell/headless_shell
cp .env.example .env && vi .env   # fill credentials

# Every session (start here)
cd /opt/Automation/STC && source venv/bin/activate

# Common run commands
python run_tests.py --suite "Login" --env qe
python run_tests.py --suite "Login" --env sit
python run_tests.py --sanity --env qe
python run_tests.py --sanity --env sit
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Label" --env qe
python run_tests.py --env qe                          # all 662 tests
python run_tests.py --env qe --email                  # with email report
python run_tests.py --e2e --env qe                    # E2E Flow A
python run_tests.py --e2e-with-usage --env qe         # E2E Flow B

# Update code
git stash && git pull origin feature-branch
```
