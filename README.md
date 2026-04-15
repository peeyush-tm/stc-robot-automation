# STC CMP Automation

Automated UI and API test suite for the **STC CMP (Connectivity Management Platform)** built with **Robot Framework** and **SeleniumLibrary**, covering end-to-end order lifecycles, CRUD operations on all CMP modules, and API-level subscriber onboarding.

- **Total Test Cases:** 500+ (ordered in `tasks.csv`)
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
├── config/                        # Environment configs (dev/qe/staging/prod)
│   ├── dev.json
│   ├── staging.json
│   ├── prod.json
│   └── qe.json
│
├── libraries/                     # Custom Python libraries
│   ├── ConfigLoader.py            # Loads config/<env>.json as Robot suite variables
│   ├── STCReportListener.py       # RF Listener v2 — screenshot renaming, module subfolders
│   ├── STCPDFReport.py            # PDF report generator from combined_output.xml
│   ├── RuleEngineTab2.py          # Rule Engine custom dropdown handling
│   ├── ReTriggerDebug.py          # Rule Engine trigger form fill + debug logging
│   ├── SeedWriter.py              # Cross-suite seed writer (.run_seed.json)
│   ├── SkipTestsByName.py         # Pre-run modifier to skip tests by name pattern
│   ├── CsrLandingGridFinder.py    # CSR Journey landing grid resolver
│   ├── GridOOM.py                 # Grid out-of-memory handler
│   ├── IpPoolDomProbe.py          # IP Pool DOM probing helper
│   ├── PaygRangeIds.py            # PAYG range ID generator
│   ├── DynamicTestCases.py        # Adds test cases at runtime
│   ├── FrameworkCSV.py            # CSV reader utility
│   └── csv_reader.py              # Generic CSV reader
│
├── resources/
│   ├── keywords/                  # Robot Framework keyword files (24 files)
│   └── locators/                  # XPath/CSS locator definitions (19 files)
│
├── variables/                     # Python variable modules (25 files)
│   ├── _config_defaults.py        # Reads config/<env>.json for Python modules
│   └── _shared_seed.py            # Cross-suite variable sharing via .run_seed.json
│
├── tests/                         # Robot Framework test suites (25 files)
│   ├── login_tests.robot
│   ├── sanity_tests.robot         # 48 page-load sanity checks
│   ├── e2e_flow.robot             # E2E Flow A (17 steps)
│   ├── e2e_flow_with_usage.robot  # E2E Flow B (20 steps + usage)
│   ├── payg_data_usage_tests.robot # PAYG multi-scenario usage tests
│   └── ... (20 more module suites)
│
├── templates/                     # SOAP/API payload templates
│   ├── api/                       # CustomerOnboardOperation.xml, SimOrderUpdateStatus.xml
│   └── order_processing/          # dsprsp, ordrsp, pcsrsp templates
│
├── prompts/                       # Module specs and reference prompts
│   ├── ALL_MODULES_AND_TESTCASES.md
│   └── <module>/Module.md         # Per-module documentation
│
├── documentation/
│   └── SETUP_AND_RUN_GUIDE.md     # Full setup, install, and run guide
│
├── reports/                       # Generated reports (gitignored)
├── bugs/                          # Generated bug reports (gitignored)
│
├── run_tests.py                   # Central test runner
├── bug_reporter.py                # Auto bug report generator from test failures
├── send_report.py                 # HTML email report sender
├── jira_bug_logger.py             # Push bug reports to Jira
├── tasks.csv                      # Global test ordering across all modules
├── requirements.txt               # Python dependencies
├── .env.example                   # Template for email/Jira configuration
└── CLAUDE.md                      # AI assistant instructions
```

---

## Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/peeyush-tm/stc-robot-automation.git
cd stc-robot-automation
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r requirements.txt

# 2. Run tests
python run_tests.py --suite "Login" --env qe
python run_tests.py --e2e --env qe
python run_tests.py --sanity --env qe

# 3. Run with email report
python run_tests.py --suite "Login" --env qe --email
```

---

## Running Tests

### All Suites (tasks.csv order)
```bash
python run_tests.py --env qe
```

### Single Suite
```bash
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Login" --env qe
python run_tests.py --suite "Label" --env qe
```

### E2E Flows
```bash
python run_tests.py --e2e --env qe                    # Flow A: 17 steps
python run_tests.py --e2e-with-usage --env qe          # Flow B: 20 steps + usage
python run_tests.py --e2e --with-crud --env qe          # E2E + Role/User CRUD
```

### PAYG Data Usage
```bash
python run_tests.py tests/payg_data_usage_tests.robot --env qe
python run_tests.py tests/payg_data_usage_tests.robot --env qe --test "TC_PAYG_POOL_*"
```

### Sanity Suite
```bash
python run_tests.py --sanity --env qe                   # Sequential
python run_tests.py --sanity --env qe --parallel 4       # Parallel (4 processes)
```

### By Tag / Test Name
```bash
python run_tests.py --suite "Rule Engine" --env qe --include smoke
python run_tests.py --suite "APN" --env qe --test "TC_APN_001*"
```

### Headless / Browser Override
```bash
python run_tests.py --e2e --env qe --browser headlesschrome
python run_tests.py --suite "Login" --env qe --browser firefox
```

### Re-run Failures
```bash
python run_tests.py --suite "Rule Engine" --rerunfailed reports/2026-04-13_04-29-56
```

### Skip Suites / Tests
```bash
python run_tests.py --env qe --skip-suite "Label" --skip-suite "Report"
python run_tests.py --suite "APN" --env qe --skip-test "TC_APN_022*"
```

### With Email Report
```bash
python run_tests.py --suite "Login" --env qe --email
python run_tests.py --e2e --env qe --email
```

---

## Test Modules

| # | Module | Suite File | Test Cases | Tags |
|---|--------|-----------|------------|------|
| 1 | Login | login_tests.robot | 12 | login, security |
| 2 | Sanity | sanity_tests.robot | 48 | sanity, smoke |
| 3 | Onboard Customer API | onboard_customer_api_tests.robot | 40 | api, soap, onboard |
| 4 | APN | apn_tests.robot | 22 | apn, service |
| 5 | SIM Range | sim_range_tests.robot | 21 | sim-range |
| 6 | SIM Range MSISDN | sim_range_msisdn_tests.robot | 26 | sim-range-msisdn |
| 7 | SIM Order | sim_order_tests.robot | 21 | sim-order |
| 8 | IP Pool | ip_pool_tests.robot | 17 | ip-pool |
| 9 | IP Whitelist | ip_whitelist_tests.robot | 20 | ip-whitelist |
| 10 | Device State | device_state_tests.robot | 16 | device-state |
| 11 | Device Plan | device_plan_tests.robot | 11 | device-plan |
| 12 | Cost Center | cost_center_tests.robot | 26 | cost-center |
| 13 | CSR Journey | csr_journey_tests.robot | 56 | csr-journey |
| 14 | Product Type | product_type_tests.robot | 18 | product-type |
| 15 | Rule Engine | rule_engine_tests.robot | 28 | rule-engine |
| 16 | Role Management | role_management_tests.robot | 33 | role-management |
| 17 | User Management | user_management_tests.robot | 45 | user-management |
| 18 | Label | label_tests.robot | 28 | label |
| 19 | Report | report_tests.robot | 14 | report |
| 20 | SIM Movement | sim_movement_tests.robot | 6 | sim-movement |
| 21 | SIM Replacement | sim_replacement_tests.robot | 8 | sim-replacement |
| 22 | PAYG Data Usage | payg_data_usage_tests.robot | 40+ | payg, usage |
| 23 | E2E Flow A | e2e_flow.robot | 17 | e2e |
| 24 | E2E Flow B | e2e_flow_with_usage.robot | 20 | e2e, usage |
| 25 | Role/User CRUD | role_user_crud_tests.robot | 4 | crud |

---

## Bug Reports & Email Notifications

### Automatic Bug Reports
Bug reports are automatically generated after every test run when failures are detected. Each bug gets its own folder under `bugs/` with a structured `.txt` report and screenshots.

```bash
# Standalone bug report generation
python bug_reporter.py reports/2026-04-15_10-30-00
```

### Email Reports
Send professional HTML email reports with pass/fail stats, donut chart, and failed test details.

```bash
# Via run_tests.py
python run_tests.py --suite "Login" --env qe --email

# Standalone for a past run
python send_report.py reports/2026-04-15_10-30-00
```

### Jira Bug Logger
Push generated bug reports to Jira with screenshots attached.

```bash
python jira_bug_logger.py              # Interactive mode
python jira_bug_logger.py --all        # Push all unlogged bugs
python jira_bug_logger.py --list       # List bugs and Jira status
python jira_bug_logger.py Bug_1_15Apr26_134003  # Push specific bug
```

### Configuration
Copy `.env.example` to `.env` and configure:

```ini
# Email (Gmail SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=your-email@gmail.com
EMAIL_TO=recipient1@airlinq.com,recipient2@airlinq.com

# Jira
JIRA_BASE_URL=https://airlinq-global.atlassian.net
JIRA_EMAIL=your-email@airlinq.com
JIRA_API_TOKEN=your-api-token
JIRA_PROJECT_KEY=STC
```

---

## Environment Config

All environment-specific values live in `config/<env>.json`. Key entries:

| Key | Purpose |
|-----|---------|
| `BASE_URL` | Application URL |
| `VALID_USERNAME` / `VALID_PASSWORD` | Login credentials |
| `DEFAULT_EC_ACCOUNT` / `DEFAULT_BU_ACCOUNT` | Default test accounts |
| `DB_*` | Database connection (host, port, name, user, pass) |
| `SSH_*` | SSH server connection for order processing |
| `SOAP_*` | SOAP API endpoints for order status updates |
| `USAGE_*` | Usage injection API settings |
| `INVOICE_*` | Invoice API and SSH settings |
| Module-specific URLs | `RE_RULE_ENGINE_URL`, `CSR_JOURNEY_URL`, etc. |

Variable resolution order: seed file > environment variable > config JSON > hardcoded fallback.

---

## Conventions

### Naming
- Test IDs: `TC_<MODULE>_<NNN>` (e.g., `TC_RE_001`, `TC_IPP_003`)
- Keywords: Title Case with spaces (e.g., `Fill Primary Details Tab`)
- Variables: `UPPER_SNAKE_CASE` for constants, `lower_snake` for locals
- Locators: `LOC_<MODULE>_<ELEMENT>` (e.g., `LOC_RE_RULE_NAME`)

### Test Structure
- Each test calls a keyword with matching TC ID
- Suite Setup: load config + login
- Test Setup: `Ensure Session Is Active` (recovers crashed browsers)
- Test Teardown: `Handle Test Teardown` (captures screenshots on PASS and FAIL)

### Waits
- Use `Wait For Loading Overlay To Disappear` after navigation/clicks
- Use `Wait Until Element Is Visible` with explicit timeout
- Avoid `Sleep` — use smart waits. Only use Sleep when async options load lazily

### Test Isolation
- Each create-test must delete its created resource afterward
- Suite Setup should clean up leftover data from previous runs
- Tests must not depend on other tests' side effects (except E2E ordered steps)

---

## Key Libraries

| Library | Purpose |
|---|---|
| `STCReportListener.py` | RF Listener v2 — screenshot renaming, module subfolders, JSON metadata |
| `STCPDFReport.py` | PDF report generator from combined_output.xml + stc_test_data.json |
| `RuleEngineTab2.py` | Rule Engine custom dropdown handling (portal-aware JS) |
| `ReTriggerDebug.py` | Rule Engine trigger form fill (multi-layout, smart values, NDJSON debug) |
| `ConfigLoader.py` | Loads config/<env>.json as Robot suite variables |
| `SeedWriter.py` | Writes cross-suite seed values to .run_seed.json |
| `SkipTestsByName.py` | Pre-run modifier to skip tests by glob pattern |
| `CsrLandingGridFinder.py` | CSR Journey landing grid resolver |
| `PaygRangeIds.py` | PAYG range ID generator |

---

## Reports & Artifacts

Each test run creates a timestamped folder under `reports/`:

```
reports/2026-04-15_10-30-00/
├── combined_output.xml          # Merged Robot output
├── combined_log.html            # Merged Robot log
├── combined_report.html         # Merged Robot report
├── execution_report.pdf         # PDF summary report
├── stc_test_data.json           # Test metadata (from STCReportListener)
├── output_1_login_tests.xml     # Per-suite Robot output
├── output_2_apn_tests.xml
├── TC_LOGIN_001_step_01_*.png   # Screenshots (renamed by listener)
└── debug-7a554c.log             # Debug NDJSON log
```

---

## Adding a New Module

1. Create `tests/<module>_tests.robot` with test cases
2. Create `resources/keywords/<module>_keywords.resource` with keywords
3. Create `resources/locators/<module>_locators.resource` with XPath locators
4. Create `variables/<module>_variables.py` with test data (use `config_scalar()` for accounts)
5. Add entries to `tasks.csv` for global ordering
6. Add module URLs to all `config/<env>.json` files
7. Create `prompts/<module>/Module.md` with module documentation
