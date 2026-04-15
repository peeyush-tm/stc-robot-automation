# STC CMP Automation

Automated UI and API test suite for the **STC CMP (Connectivity Management Platform)** built with **Robot Framework** and **SeleniumLibrary**, covering end-to-end order lifecycles, CRUD operations on all CMP modules, and API-level subscriber onboarding.

- **Total Test Cases:** 459+ (ordered in `tasks.csv`)
- **Application:** STC CMP Web Application (React SPA)
- **Framework:** Robot Framework + SeleniumLibrary + DatabaseLibrary + SSHLibrary + RequestsLibrary
- **Language:** Python 3.9+
- **Browsers:** Chrome (default), Headless Chrome, Firefox
- **Environments:** `dev` (default), `staging`, `prod`, `qe`
- **Captcha:** Auto-fetched from MySQL database during login

---

## Project Structure

```
stc-automation/
├── bin/
│   ├── STCFramework.robot             # CSV-driven framework entry point (dynamic suite loader)
│   ├── run.bat                        # Windows runner (wraps run_tests.py; supports FRAMEWORK mode)
│   ├── run.sh                         # Linux/Mac runner
│   ├── setall.bat                     # Sets PYTHONPATH + activates venv (Windows)
│   └── setall.sh                      # Sets PYTHONPATH + activates venv (Linux/Mac)
│
├── config/
│   ├── dev.json                       # Dev environment config (BROWSER: chrome)
│   ├── staging.json                   # Staging environment config (BROWSER: headlesschrome)
│   ├── prod.json                      # Prod environment config (BROWSER: headlesschrome)
│   └── qe.json                        # QE environment config (BROWSER: headlesschrome)
│
├── data/
│   ├── dev/                           # Test data files for dev (TESTDATA_PATH)
│   ├── staging/                       # Test data files for staging
│   └── prod/                          # Test data files for prod
│
├── documentation/
│   └── SETUP_AND_RUN_GUIDE.md         # Full installation and run guide for new team members
│
├── libraries/
│   ├── ConfigLoader.py                # Loads config/<env>.json → Robot suite variables
│   ├── DynamicTestCases.py            # Adds test cases at runtime (used by STCFramework)
│   └── FrameworkCSV.py                # CSV reader utility for framework mode
│
├── prompts/
│   ├── login/Login.md                 # AI prompt for Login module
│   ├── apn/APN.md                     # AI prompt for APN module
│   ├── sim_range/SIM_Range.md         # AI prompt for SIM Range module
│   ├── sim_range_msisdn/SIM_Range_MSISDN.md
│   ├── sim_order/SIM_Order.md
│   ├── sim_movement/SIM_Movement.md
│   ├── ip_pool/IP_Pool.md
│   ├── ip_whitelist/IP_Whitelist.md
│   ├── device_state/Device_State.md
│   ├── device_plan/Device_Plan.md
│   ├── account_onboard/Account_Onboard.md
│   ├── cost_center/Cost_Center.md
│   ├── csr_journey/CSR_Journey.md
│   ├── sim_product_type/SIM_Product_Type.md
│   ├── e2e_flow/E2E_Flow.md
│   ├── e2e_flow_with_usage/E2E_Flow_With_Usage.md
│   ├── rule_engine/Rule_Engine.md
│   ├── role_management/Role_Management.md
│   └── user_management/User_Management.md
│
├── resources/
│   ├── keywords/
│   │   ├── browser_keywords.resource          # Reusable browser actions (open, SSL bypass)
│   │   ├── login_keywords.resource            # Login / captcha / logout
│   │   ├── apn_keywords.resource              # APN CRUD keywords
│   │   ├── sim_range_keywords.resource        # SIM Range (ICCID/IMSI) keywords
│   │   ├── sim_order_keywords.resource        # SIM Order (Live Order) keywords
│   │   ├── ip_pool_keywords.resource          # IP Pool keywords
│   │   ├── ip_whitelist_keywords.resource     # IP Whitelisting keywords
│   │   ├── device_state_keywords.resource     # Device state transition keywords
│   │   ├── device_plan_keywords.resource      # Change device plan keywords
│   │   ├── api_keywords.resource              # SOAP/REST API call keywords
│   │   ├── cost_center_keywords.resource      # Cost Center keywords
│   │   ├── csr_journey_keywords.resource      # CSR Journey wizard keywords
│   │   ├── product_type_keywords.resource     # SIM Product Type keywords
│   │   ├── e2e_keywords.resource              # End-to-end flow orchestration
│   │   ├── usage_keywords.resource            # OCS usage injection (Flow B)
│   │   ├── order_processing_keywords.resource # SIM order lifecycle keywords
│   │   ├── sanity_keywords.resource           # Portal page sanity check keywords
│   │   ├── rule_engine_keywords.resource      # Rule Engine keywords
│   │   ├── role_management_keywords.resource  # Role Management keywords
│   │   ├── user_management_keywords.resource  # User Management keywords
│   │   └── report_keywords.resource           # Reports module keywords
│   └── locators/
│       ├── login_locators.resource
│       ├── apn_locators.resource
│       ├── sim_range_locators.resource
│       ├── sim_order_locators.resource
│       ├── ip_pool_locators.resource
│       ├── ip_whitelist_locators.resource
│       ├── device_state_locators.resource
│       ├── device_plan_locators.resource
│       ├── cost_center_locators.resource
│       ├── csr_journey_locators.resource
│       ├── product_type_locators.resource
│       ├── rule_engine_locators.resource
│       └── report_locators.resource
│
├── suites/
│   ├── suites.csv                     # Master suite registry (order, id, name, active, file overrides)
│   ├── Login/Login.csv                # Test case definitions for Login suite
│   ├── APN/APN.csv
│   ├── SIM_Range/SIM_Range.csv
│   ├── SIM_Order/SIM_Order.csv
│   ├── SIM_Range_MSISDN/SIM_Range_MSISDN.csv
│   ├── IP_Pool/IP_Pool.csv
│   ├── IP_Whitelist/IP_Whitelist.csv
│   ├── Device_State/Device_State.csv
│   ├── Device_Plan/Device_Plan.csv
│   ├── Account_Onboard/Account_Onboard.csv
│   ├── Cost_Center/Cost_Center.csv
│   ├── CSR_Journey/CSR_Journey.csv
│   ├── SIM_Product_Type/SIM_Product_Type.csv
│   ├── E2E_Flow/E2E_Flow.csv
│   ├── E2E_Flow_With_Usage/E2E_Flow_With_Usage.csv
│   ├── Rule_Engine/Rule_Engine.csv
│   ├── Role_Management/Role_Management.csv
│   └── User_Management/User_Management.csv
│
├── tasks/
│   ├── Login/Login.csv                # Task definitions (taskid, keyword, params, expected)
│   ├── APN/APN.csv
│   └── ...                            # One folder per suite, mirrors suites/ structure
│
├── templates/
│   ├── api/                           # SOAP XML request templates
│   └── order_processing/              # Order processing XML templates
│
├── tests/
│   ├── login_tests.robot              # Login (16 TCs)
│   ├── apn_tests.robot                # Create APN (22 TCs)
│   ├── sim_range_tests.robot          # SIM Range ICCID/IMSI (21 TCs)
│   ├── sim_range_msisdn_tests.robot   # SIM Range MSISDN (26 TCs)
│   ├── sim_order_tests.robot          # SIM Order / Live Order (21 TCs)
│   ├── ip_pool_tests.robot            # IP Pool (17 TCs)
│   ├── ip_whitelist_tests.robot       # IP Whitelisting (20 TCs)
│   ├── device_state_tests.robot       # Device State Change (16 TCs)
│   ├── device_plan_tests.robot        # Change Device Plan (11 TCs)
│   ├── onboard_customer_api_tests.robot # Account Onboard SOAP API (38 TCs)
│   ├── cost_center_tests.robot        # Cost Center (25 TCs)
│   ├── csr_journey_tests.robot        # CSR Journey (56 TCs)
│   ├── product_type_tests.robot       # SIM Product Type (18 TCs)
│   ├── rule_engine_tests.robot        # Rule Engine (37 TCs)
│   ├── role_management_tests.robot    # Role Management (32 TCs)
│   ├── user_management_tests.robot    # User Management (45 TCs)
│   ├── report_tests.robot             # Reports module
│   ├── e2e_flow.robot                 # E2E Flow A — 17 steps (no usage)
│   ├── e2e_flow_with_usage.robot      # E2E Flow B — 20 steps (with usage)
│   ├── sim_movement_tests.robot       # SIM Movement (14 TCs)
│   └── sanity_tests.robot             # Sanity / smoke checks
│
├── variables/
│   ├── _shared_seed.py                # Cross-suite random seed for consistent test data
│   ├── login_variables.py
│   ├── apn_variables.py
│   ├── sim_range_variables.py
│   ├── sim_range_msisdn_variables.py
│   ├── sim_order_variables.py
│   ├── ip_pool_variables.py
│   ├── ip_whitelist_variables.py
│   ├── device_state_variables.py
│   ├── device_plan_variables.py
│   ├── onboard_customer_variables.py
│   ├── cost_center_variables.py
│   ├── csr_journey_variables.py
│   ├── product_type_variables.py
│   ├── order_processing_variables.py  # E2E variables (EC, BU, order IDs, invoice)
│   ├── usage_variables.py
│   ├── sim_movement_variables.py      # SIM Movement (EC/BU names, ICCID, batch job names)
│   ├── rule_engine_variables.py
│   ├── role_management_variables.py
│   ├── user_management_variables.py
│   └── report_variables.py
│
├── billing/                           # Local folder for E2E Step 17 invoice CSV downloads
│                                      # (files are written to reports/<run>/billing/ at runtime)
├── reports/                           # Auto-generated timestamped run folders (git-ignored)
├── run_tests.py                       # Central test runner — all modes, merged reports
├── tasks.csv                          # Execution order for suite runner mode
├── requirements.txt                   # Python dependencies
└── .gitignore
```

---

## Quick Start

### One-Time Setup

```bash
# 1. Install Python 3.9+ from https://www.python.org/downloads/
#    IMPORTANT: Check "Add Python to PATH" during installation

# 2. Create and activate virtual environment
python -m venv venv

# Windows (CMD)
venv\Scripts\activate

# Windows (PowerShell) — fix execution policy if needed
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
venv\Scripts\Activate.ps1

# Linux / Mac
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt
```

### First Run

```bash
# Activate venv first, then run all suites (dev environment, visible Chrome)
python run_tests.py

# Or use the shell scripts — they activate venv automatically via setall.bat / setall.sh
bin\run.bat          # Windows
./bin/run.sh         # Linux / Mac
```

> For a detailed setup guide including troubleshooting, see [documentation/SETUP_AND_RUN_GUIDE.md](documentation/SETUP_AND_RUN_GUIDE.md).

---

## Execution Modes

There are **three execution modes**, all routed through `run_tests.py` for consistent report generation.

| Mode | Command | What it does |
|------|---------|--------------|
| **Suite Runner** | `python run_tests.py` | Runs `.robot` files directly from `tests/` (ordered by `tasks.csv`) |
| **Framework Mode** | `python run_tests.py --framework` | Runs `bin/STCFramework.robot` — dynamically loads suites from `suites/*.csv` and tasks from `tasks/*.csv` |
| **Shell Scripts** | `bin\run.bat` / `bin/run.sh` | Wrappers that translate env vars (`PROFILE`, `BROWSER`, `TESTPLAN`, etc.) into `run_tests.py` arguments |

---

## Run Commands — All Possible Ways

### Direct (`python run_tests.py`)

```bash
# ── All suites ────────────────────────────────────────────────────────────────
python run_tests.py                               # all suites (tasks.csv order, dev env)
python run_tests.py --env dev                     # explicit dev (default)
python run_tests.py --env staging
python run_tests.py --env qe
python run_tests.py --env prod

# ── Specific suite by name ───────────────────────────────────────────────────
python run_tests.py --suite Login
python run_tests.py --suite APN
python run_tests.py --suite "SIM Range"
python run_tests.py --suite "SIM Order"
python run_tests.py --suite "Device Plan"
python run_tests.py --suite "Device State"
python run_tests.py --suite "IP Pool"
python run_tests.py --suite "IP Whitelist"
python run_tests.py --suite "Cost Center"
python run_tests.py --suite "CSR Journey"
python run_tests.py --suite "SIM Product Type"
python run_tests.py --suite "Rule Engine"
python run_tests.py --suite "Role Management"
python run_tests.py --suite "User Management"
python run_tests.py --suite "Account Onboard"
python run_tests.py --suite "SIM Movement"
python run_tests.py --suite Report

# ── Specific suite file ──────────────────────────────────────────────────────
python run_tests.py tests/login_tests.robot
python run_tests.py tests/apn_tests.robot
python run_tests.py tests/device_plan_tests.robot
python run_tests.py tests/role_management_tests.robot

# ── Specific test case ───────────────────────────────────────────────────────
python run_tests.py tests/apn_tests.robot --test "TC_APN_001*"
python run_tests.py tests/login_tests.robot --test "TC_LOGIN_001*"
python run_tests.py --suite "Role Management" --test "TC_ROLE_CREATE_001*"

# ── By tag ───────────────────────────────────────────────────────────────────
python run_tests.py --include smoke
python run_tests.py --include regression
python run_tests.py --include negative
python run_tests.py --include security
python run_tests.py --exclude Inactive

# ── API or UI suites only ────────────────────────────────────────────────────
python run_tests.py --api
python run_tests.py --ui

# ── E2E flows ────────────────────────────────────────────────────────────────
python run_tests.py --e2e                         # Flow A (17 steps, no usage)
python run_tests.py --e2e-with-usage              # Flow B (20 steps, with usage)
python run_tests.py --e2e --with-crud             # Flow A + CRUD suite appended
python run_tests.py --e2e --exitonfailure
python run_tests.py --e2e --env staging --browser headlesschrome

# ── Sanity suite ─────────────────────────────────────────────────────────────
python run_tests.py --sanity                      # sequential
python run_tests.py --sanity --parallel 4         # parallel via pabot (4 processes)

# ── Framework mode (CSV-driven via STCFramework.robot) ───────────────────────
python run_tests.py --framework                   # all active suites from suites.csv
python run_tests.py --framework --suite Login
python run_tests.py --framework --suite APN --env qe

# ── Browser ──────────────────────────────────────────────────────────────────
python run_tests.py --browser chrome              # visible (default for dev)
python run_tests.py --browser headlesschrome      # headless Chrome
python run_tests.py --browser firefox
python run_tests.py --env qe --browser chrome     # override qe.json default

# ── Stop on first failure ────────────────────────────────────────────────────
python run_tests.py --exitonfailure
python run_tests.py --suite Login --exitonfailure

# ── Override any Robot variable ──────────────────────────────────────────────
python run_tests.py --variable BASE_URL:https://myserver:7874/
python run_tests.py --variable VALID_USERNAME:admin --variable VALID_PASSWORD:pass

# ── Combinations ─────────────────────────────────────────────────────────────
python run_tests.py --env staging --browser headlesschrome --suite Login
python run_tests.py --env qe --sanity --parallel 4
python run_tests.py --env prod --e2e --exitonfailure
```

### Windows (`bin\run.bat`)

The script reads environment variables and forwards them to `run_tests.py`:

| Env Variable | Maps to | Example |
|---|---|---|
| `PROFILE` | `--env` | `set PROFILE=staging` |
| `BROWSER` | `--browser` | `set BROWSER=headlesschrome` |
| `TESTPLAN` | `--suite` | `set TESTPLAN=Login` |
| `TAGS` | `--include` | `set TAGS=smoke` |
| `RUNNAME` | `--outputdir reports/<name>_<timestamp>` | `set RUNNAME=nightly` |
| `FRAMEWORK=1` | `--framework` | `set FRAMEWORK=1` |

```bat
REM Default run (dev env, Chrome)
bin\run.bat

REM Environment
set PROFILE=staging & bin\run.bat
set PROFILE=qe      & bin\run.bat

REM Browser override
set BROWSER=headlesschrome & bin\run.bat

REM Specific suite
set TESTPLAN=Login & bin\run.bat
set TESTPLAN=APN   & set PROFILE=staging & bin\run.bat

REM Tags
set TAGS=smoke      & bin\run.bat
set TAGS=regression & bin\run.bat

REM Named output folder
set RUNNAME=nightly & bin\run.bat

REM Framework mode (STCFramework.robot / CSV-driven)
set FRAMEWORK=1 & bin\run.bat
set FRAMEWORK=1 & set TESTPLAN=Login & set PROFILE=qe & bin\run.bat
bin\run.bat --framework

REM Nightly CI — all suites, qe env, headless, named folder
set FRAMEWORK=1 & set PROFILE=qe & set BROWSER=headlesschrome & set RUNNAME=nightly & bin\run.bat

REM Pass run_tests.py flags directly after the script name
bin\run.bat --e2e
bin\run.bat --e2e-with-usage
bin\run.bat --sanity
bin\run.bat --sanity --parallel 4
bin\run.bat --e2e --exitonfailure
set PROFILE=staging & bin\run.bat tests/login_tests.robot --test "TC_LOGIN_001*"
```

### Linux / Mac (`bin/run.sh`)

```bash
# Default run
./bin/run.sh

# Environment + browser
PROFILE=staging ./bin/run.sh
PROFILE=qe BROWSER=headlesschrome ./bin/run.sh

# Specific suite
TESTPLAN=Login ./bin/run.sh
TESTPLAN=APN PROFILE=staging ./bin/run.sh

# Tags
TAGS=smoke ./bin/run.sh

# Named output folder
RUNNAME=nightly ./bin/run.sh

# Framework mode
FRAMEWORK=1 ./bin/run.sh
FRAMEWORK=1 TESTPLAN=Login PROFILE=qe ./bin/run.sh
./bin/run.sh --framework

# Nightly CI
FRAMEWORK=1 PROFILE=qe BROWSER=headlesschrome RUNNAME=nightly ./bin/run.sh

# Pass flags directly
./bin/run.sh --e2e
./bin/run.sh --sanity --parallel 4
PROFILE=qe ./bin/run.sh --e2e --exitonfailure
```

### Quick Reference

| Goal | Command |
|------|---------|
| Run everything, default env | `python run_tests.py` |
| Run one suite, visible browser | `python run_tests.py --suite Login` |
| Run one suite, headless | `python run_tests.py --suite Login --browser headlesschrome` |
| Run on QE env | `python run_tests.py --env qe` |
| Run one test case | `python run_tests.py tests/apn_tests.robot --test "TC_APN_001*"` |
| Run by tag | `python run_tests.py --include smoke` |
| Run E2E Flow A | `python run_tests.py --e2e` |
| Run E2E Flow B | `python run_tests.py --e2e-with-usage` |
| Run sanity, parallel | `python run_tests.py --sanity --parallel 4` |
| Run CSV framework mode | `python run_tests.py --framework` |
| Windows CI nightly | `set FRAMEWORK=1 & set PROFILE=qe & set RUNNAME=nightly & bin\run.bat` |
| Linux CI nightly | `FRAMEWORK=1 PROFILE=qe RUNNAME=nightly ./bin/run.sh` |

---

## Environment Configuration

Each environment has its own JSON config file in `config/`. `ConfigLoader.py` loads the matching file at suite setup and injects all keys as Robot Framework suite variables automatically.

| File | `--env` value | Default Browser |
|------|--------------|----------------|
| `config/dev.json` | `dev` *(default)* | `chrome` (visible) |
| `config/staging.json` | `staging` | `headlesschrome` |
| `config/prod.json` | `prod` | `headlesschrome` |
| `config/qe.json` | `qe` | `headlesschrome` |

### Browser Priority (highest wins)

1. `--browser` CLI flag / `BROWSER` env var in shell scripts → passed as `BROWSER_OVERRIDE`
2. `BROWSER` key in the environment's JSON file

```bash
python run_tests.py --env dev                          # chrome  (from dev.json)
python run_tests.py --env dev --browser headlesschrome # headlesschrome (CLI wins)
python run_tests.py --env qe                           # headlesschrome (from qe.json)
python run_tests.py --env qe --browser chrome          # chrome (CLI wins over qe.json)
```

### Key Config Fields

| Field | Description |
|-------|-------------|
| `BASE_URL` | Application base URL |
| `VALID_USERNAME` / `VALID_PASSWORD` | Login credentials |
| `BROWSER` | Default browser for this environment |
| `IMPLICIT_WAIT` | Selenium implicit wait (seconds) |
| `PAGE_LOAD_TIMEOUT` | Page load timeout (seconds) |
| `DB_HOST` / `DB_PORT` / `DB_NAME` | MySQL connection for captcha fetch |
| `CAPTCHA_QUERY` | SQL to fetch latest captcha text |
| `SSH_HOST` / `SSH_USERNAME` / `SSH_PASSWORD` | SSH for SIM order operations |
| `SOAP_ORDER_STATUS_URL` | SOAP endpoint for order status updates |
| `INVOICE_API_URL` | Invoice processor API URL |
| `USAGE_API_BASE_URL` | OCS usage injection API URL |

---

## Framework Mode (CSV-Driven)

The `--framework` flag runs tests through `bin/STCFramework.robot` — a data-driven engine that reads test definitions from CSV files rather than `.robot` files.

### Architecture

```
suites/suites.csv              → which suites to run (order + active flag)
suites/<Suite>/<Suite>.csv     → test case definitions (TC ID, name, task list, tags)
tasks/<Suite>/<Suite>.csv      → task definitions (task ID, keyword, params, expected)
variables/<suite>_variables.py → test data (auto-discovered by convention)
tests/<suite>_tests.robot      → Robot keyword implementations (auto-discovered)
```

### Dynamic File Discovery

`STCFramework.robot` resolves test and variable files **automatically by naming convention**:

| What | Convention | Example |
|------|-----------|---------|
| Test file | `tests/<suite_id_lower>_tests.robot` | `Login` → `tests/login_tests.robot` |
| Variables file | `variables/<suite_id_lower>_variables.py` | `APN` → `variables/apn_variables.py` |
| Fallback (no `_tests` suffix) | `tests/<suite_id_lower>.robot` | `E2E_Flow` → `tests/e2e_flow.robot` |

Suites that don't follow the convention declare their exact paths in the optional `test_file` and `variables_file` columns of `suites/suites.csv`. No code changes needed.

### `suites/suites.csv` Format

```csv
order,suite_id,suite_name,active,test_file,variables_file
1,Login,Login,true,,
2,APN,APN,true,,
10,Account_Onboard,Account Onboard,true,tests/onboard_customer_api_tests.robot,variables/onboard_customer_variables.py
14,E2E_Flow,E2E Flow,true,tests/e2e_flow.robot,variables/order_processing_variables.py
```

- Leave `test_file` / `variables_file` blank → auto-discovered by convention
- Fill them in → use that exact path
- Set `active=false` → suite is skipped without removing it from the registry

### `suites/<Suite>/<Suite>.csv` Format

```csv
testcaseid,testcasename,taglist,tasklist,variables,isdatadriven,datafile,isactive
TC_LOGIN_001,Valid Credentials Should Login Successfully,smoke|regression|positive,TC_LOGIN_001,,false,,true
```

### `tasks/<Suite>/<Suite>.csv` Format

```csv
taskid,tasktype,taskparams,expectations,isactive
TC_LOGIN_001,TC_LOGIN_001,,status->PASS,true
```

### Adding a New Module

1. Create `tests/<new_module>_tests.robot`
2. Create `variables/<new_module>_variables.py`
3. Create `suites/<New_Module>/<New_Module>.csv` (test case definitions)
4. Create `tasks/<New_Module>/<New_Module>.csv` (task definitions)
5. Add one row to `suites/suites.csv` — leave `test_file` and `variables_file` blank

**Zero code changes** required anywhere else. The framework auto-discovers the new files.

---

## Test Runner Reference (`run_tests.py`)

| Argument | Description | Example |
|----------|-------------|---------|
| *(positional)* | Suite file path(s) | `tests/login_tests.robot` |
| `--env` | Environment name (default: `dev`) | `--env qe` |
| `--browser` | Browser override | `--browser headlesschrome` |
| `--suite` | Suite name from tasks.csv / suites.csv | `--suite Login` |
| `--test` | Test name filter, repeatable | `--test "TC_APN_001*"` |
| `--include` | Include by tag | `--include smoke` |
| `--exclude` | Exclude by tag | `--exclude Inactive` |
| `--tasks` | Run all suites from tasks.csv | `--tasks` |
| `--api` | Run only API suites | `--api` |
| `--ui` | Run only UI suites | `--ui` |
| `--e2e` | Run E2E Flow A (no usage) | `--e2e` |
| `--e2e-with-usage` | Run E2E Flow B (with usage) | `--e2e-with-usage` |
| `--with-crud` | Run CRUD suite after E2E | `--with-crud` |
| `--framework` | Run via STCFramework.robot (CSV mode) | `--framework` |
| `--sanity` | Run sanity suite | `--sanity` |
| `--parallel N` | Sanity in parallel via pabot | `--parallel 4` |
| `--exitonfailure` | Stop on first test failure | `--exitonfailure` |
| `--variable` | Override any Robot variable | `--variable BASE_URL:https://...` |
| `--outputdir` | Override output folder path | `--outputdir reports/myrun` |

---

## Reports

Every test run (all modes) saves a timestamped folder under `reports/`:

```
reports/
├── 2026-03-20_14-25-02/                  # plain run (tasks.csv)
├── 2026-03-20_14-30-00_e2e/              # E2E Flow A
├── 2026-03-20_14-35-00_e2e_usage/        # E2E Flow B
├── 2026-03-20_14-40-00_sanity/           # sanity suite
└── 2026-03-20_14-45-00_framework/        # framework mode
```

Each run folder contains:

| File | Description |
|------|-------------|
| `combined_report.html` | Pass/fail summary — open in browser |
| `combined_log.html` | Step-by-step execution log with embedded screenshots |
| `combined_output.xml` | Merged Robot XML for CI/CD dashboards or `rebot` |
| `output_1_<suite>.xml` | Per-suite raw XML output |
| `*.png` | Screenshots captured at each test step |
| `billing/*.csv` | Invoice CSV files downloaded during E2E Step 17 |

When multiple suites run in sequence, all XML outputs are automatically merged using `rebot`.

> The `reports/` folder is **git-ignored**. Only `reports/.gitkeep` is tracked to preserve the folder in version control.

---

## Architecture & Design

### Layer Architecture

```
Tests (.robot)          → Scenario definitions — one file per module
        ↓
Keywords (.resource)    → Business-level reusable actions
        ↓
Locators (.resource)    → Page element XPaths — never hardcoded in keywords
        ↓
Variables (.py)         → Dynamic test data (random per run, shared seed)
        ↓
Config (<env>.json)     → Environment-specific URLs, credentials, DB settings
        ↓
ConfigLoader.py         → Loads JSON → Robot suite variables at test start
```

### Shared Seed System

`variables/_shared_seed.py` generates and caches random values in `.run_seed.json`. This keeps test data consistent across sequentially-run suites within a single execution — for example, the E2E flow reuses the same EC/BU account name created in Step 1 through all 17 subsequent steps. The seed file is automatically cleared at the start of each `run_tests.py` invocation.

### Test Isolation

Each test suite shares one browser session for efficiency:

- **Suite Setup:** `Suite Login Setup` — opens browser with SSL bypass, logs in once
- **Suite Teardown:** `Close All Browsers`
- **Test Teardown:** `Handle Test Teardown` — screenshot on failure, browser stays open

### Login Flow & CAPTCHA

The CMP application requires Username + Password + CAPTCHA. The automation handles this in a specific order to avoid React re-render issues:

1. Open `https://<BASE_URL>/` and wait for the React SPA to render
2. Wait for the captcha `<img>` `src` to become a base64 data URI (confirms `getCaptcha()` API + `setState` is complete)
3. Fetch captcha text from MySQL: `SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1`
4. Enter captcha **first** — before username/password — so React's async state update doesn't clear credential fields
5. Enter username and password after React state is stable
6. Click Login and wait for `div#gridData` to confirm Manage Devices loaded

### React Component Handling

Several CMP UI components require special handling:

- **Account dropdowns:** React state manipulation via fiber tree traversal
- **Input fields:** Native `HTMLInputElement.prototype.value` setter + dispatched `input`/`change` events
- **Loading overlay:** `Wait For Loading Overlay To Disappear` is called after every action; JS fallback removes stuck `body.loading-indicator` after 60 seconds
- **Kendo UI Grids:** Column index aware (hierarchy cell at `td[1]`; action icons at `td[2]`)

---

## Test Modules

| # | Module | Suite File | TCs | Tags |
|---|--------|-----------|-----|------|
| 1 | Login & Navigate | `login_tests.robot` | 16 | login, captcha, security, navigation |
| 2 | Create APN | `apn_tests.robot` | 22 | apn, qos, boundary, security |
| 3 | SIM Range (ICCID/IMSI) | `sim_range_tests.robot` | 21 | sim_range, boundary, security |
| 4 | SIM Order | `sim_order_tests.robot` | 21 | sim_order, cancel, boundary |
| 5 | SIM Range (MSISDN) | `sim_range_msisdn_tests.robot` | 26 | sim_range, msisdn, boundary |
| 6 | IP Pool | `ip_pool_tests.robot` | 17 | ip_pool, boundary, security |
| 7 | IP Whitelisting | `ip_whitelist_tests.robot` | 20 | ip_whitelist, boundary, security |
| 8 | Device State Change | `device_state_tests.robot` | 16 | device_state, activated, suspended |
| 9 | Change Device Plan | `device_plan_tests.robot` | 11 | device_plan, activated, testactive |
| 10 | Account Onboard (API) | `onboard_customer_api_tests.robot` | 38 | onboard, api, boundary, edge |
| 11 | Cost Center | `cost_center_tests.robot` | 25 | cost-center, validation, security |
| 12 | CSR Journey | `csr_journey_tests.robot` | 56 | csr-journey, wizard, tariff, e2e |
| 13 | SIM Product Type | `product_type_tests.robot` | 18 | product-type, create, validation |
| 14 | E2E Flow A | `e2e_flow.robot` | 17 | e2e, steps 1–17 |
| 15 | E2E Flow B (With Usage) | `e2e_flow_with_usage.robot` | 20 | e2e, usage |
| 16 | Rule Engine | `rule_engine_tests.robot` | 37 | rule-engine, fraud-prevention |
| 17 | Role Management | `role_management_tests.robot` | 32 | role-management, permissions |
| 18 | User Management | `user_management_tests.robot` | 45 | user-management, validation |
| 19 | Reports | `report_tests.robot` | — | reports, download, create |
| 20 | SIM Movement | `sim_movement_tests.robot` | 14 | sim-movement, smoke, regression, batch-job, notes, audit-trail |
| 21 | Reports | `report_tests.robot` | — | reports, download, create |
| 22 | Sanity | `sanity_tests.robot` | — | sanity, smoke |
| | **Total** | | **459+** | |

---

## E2E Integration Flows

### Flow A — Without Usage (`--e2e`)

17 interdependent steps. Step 1 creates a new EC + BU account via SOAP API; all subsequent steps use those accounts in the UI.

| Step | Module | What it does |
|------|--------|-------------|
| 1 | Account Onboard (API) | Creates EC + BU via SOAP API (unique random names via shared seed) |
| 2 | APN | Creates Private APN linked to the new EC/BU |
| 3 | CSR Journey | Creates CSR order through the wizard |
| 4 | SIM Range | Creates 10 ICCID/IMSI entries |
| 5 | SIM Product Type | Creates and assigns product type to EC |
| 6 | SIM Order | Creates a SIM order for EC/BU |
| 7–15 | Order Processing | Approves order via SOAP, tracks Live Order, validates Order History |
| 16 | Device State | Activates all SIMs in the order |
| 17 | Invoice | Generates invoice via API and downloads CSV to `reports/<run>/billing/` |

```bash
python run_tests.py --e2e
python run_tests.py --e2e --exitonfailure
python run_tests.py --e2e --env staging --browser headlesschrome
python run_tests.py --e2e --with-crud    # append Role + User CRUD tests after E2E
```

### Flow B — With Usage (`--e2e-with-usage`)

20 steps — same as Flow A plus Steps 16a and 16b which inject usage via the OCS API and validate CDR records in the UI.

```bash
python run_tests.py --e2e-with-usage
python run_tests.py --e2e-with-usage --exitonfailure
python run_tests.py --e2e-with-usage --env staging --browser headlesschrome
```

### Partial E2E Run (Skip Earlier Steps)

When earlier steps have already run successfully, pass the captured variable values to resume from a later step.

```bash
# Windows
python run_tests.py --e2e --test "Step 16*" --test "Step 17*" ^
    --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 ^
    --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 ^
    --variable E2E_ORDER_ID:101076 ^
    --variable E2E_EC_ID:29421 ^
    --variable E2E_BU_ID:29422

# Linux / Mac
python run_tests.py --e2e --test "Step 16*" --test "Step 17*" \
    --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 \
    --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 \
    --variable E2E_ORDER_ID:101076 \
    --variable E2E_EC_ID:29421 \
    --variable E2E_BU_ID:29422
```

| Variable | Source step | Description |
|---|---|---|
| `E2E_EC_NAME` | Step 1 | EC account name created during onboarding |
| `E2E_BU_NAME` | Step 1 | BU account name created during onboarding |
| `E2E_ORDER_ID` | Step 7 | SIM order ID |
| `E2E_EC_ID` | Step 8 | EC account database ID |
| `E2E_BU_ID` | Step 8 | BU account database ID |
| `E2E_IMSI_DATA` | Step 16 | List of `{imsi, msisdn}` pairs (required for Step 16a) |

---

## Tags

| Tag | Description |
|-----|-------------|
| `smoke` | Critical path smoke tests |
| `regression` | Full regression suite |
| `positive` | Happy path scenarios |
| `negative` | Error / validation / failure scenarios |
| `security` | SQL injection, special character tests |
| `boundary` | Boundary value / edge case tests |
| `navigation` | Redirect / direct-access-without-login tests |
| `captcha` | CAPTCHA validation tests |
| `login` | Login module |
| `apn` | APN module |
| `sim_range` | SIM Range module |
| `msisdn` | MSISDN-specific tests |
| `sim_order` | SIM Order module |
| `cancel` | Order cancellation tests |
| `ip_pool` | IP Pool module |
| `ip_whitelist` | IP Whitelisting module |
| `device_state` | Device state transition tests |
| `device_plan` | Device plan change tests |
| `onboard` | Account onboarding (API) |
| `e2e` | End-to-end flow tests |
| `usage` | OCS usage injection tests (Flow B) |
| `sim-movement` | SIM Movement module |
| `batch-job` | Batch job (Set Operation Status / Response Handler) tests |
| `notes` | SIM Notes tab verification |
| `audit-trail` | Audit Trail verification tests |
| `business-unit` | Business Unit account tests |
| `role-management` | Role Management module |
| `user-management` | User Management module |
| `sanity` | Sanity / smoke page checks |
| `Inactive` | Test cases marked inactive (excluded by default) |

```bash
python run_tests.py --include smoke
python run_tests.py --include negative
python run_tests.py --include security
python run_tests.py --include sim_range
python run_tests.py --include e2e
python run_tests.py --exclude Inactive
```

---

## Browser Support

| Browser | `--browser` value | Notes |
|---------|------------------|-------|
| Chrome (visible) | `chrome` | Default for `dev`; SSL bypass via `--ignore-certificate-errors` |
| Headless Chrome | `headlesschrome` | Default for `staging`, `qe`, `prod`; window size 1920×1080 |
| Firefox | `firefox` | Requires geckodriver on PATH |

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `robotframework` | Core automation framework |
| `robotframework-seleniumlibrary` | Browser automation via Selenium WebDriver |
| `robotframework-databaselibrary` | MySQL access for captcha fetching |
| `robotframework-sshlibrary` | SSH connections for SIM order and invoice operations |
| `robotframework-requests` | HTTP/REST API calls |
| `pymysql` | MySQL connector for DatabaseLibrary |
| `reportlab` | PDF report generation utility |
| `python-docx` | Word document report generation utility |

```bash
pip install -r requirements.txt
```

---

## Application Under Test

| Field | Value |
|-------|-------|
| **Application** | STC CMP (Connectivity Management Platform) |
| **Type** | React Single Page Application (SPA) |
| **Default Base URL** | `https://192.168.1.26:7874/` |
| **SSL** | Self-signed certificate (bypassed via ChromeOptions) |
| **Authentication** | Username + Password + CAPTCHA (DB-fetched) |
| **Default Credentials** | `ksa_opco` / `Admin@123` |
| **Captcha DB** | MySQL `192.168.1.122:3306/stc_s5_p1` |

### CMP Modules Covered

| Module | URL Path |
|--------|----------|
| Login | `/` |
| Manage Devices | `/ManageDevices` |
| Create APN | `/ManageAPN` → `/CreateAPN` |
| SIM Range (ICCID/IMSI) | `/SIMRange` → `/CreateSIMRange?currentTab=0` |
| SIM Range (MSISDN) | `/SIMRange?currentTab=1` → `/CreateSIMRange?currentTab=1` |
| SIM Order (Live Order) | `/LiveOrder` → `/CreateSIMOrder` |
| Order History | `/OrderHistory` |
| IP Pool | `/manageIPPooling` → `/CreateIPPooling` |
| IP Whitelisting | `/IPWhitelisting` → `/CreateIPWhitelisting` |
| Cost Center | `/ManageAccount` → Create Cost Center |
| CSR Journey | `/CSRJourney` → `/CreateCSRJourney` |
| SIM Product Type | `/ProductType` → `/CreateProductType` |
| Rule Engine | `/RuleEngine` → `/CreateRuleEngine` |
| Role Management | `/RoleAndAccess` |
| User Management | `/ManageUser` |
| SIM Movement | `/ManageDevices` (Select Action → SIM Movement) |
| Audit Trail | `/ManageAudit` |
| Batch Job Log | `/BatchJobLog` |
| Reports | `/Report` → `/CreateReports` |
| Account Onboard | SOAP API (no UI) |
