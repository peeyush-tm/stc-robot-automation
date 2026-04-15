# STC Automation Framework

Robot Framework + Python test automation for the STC (Telecommunications) CMP web application.

## Project Structure

```
stc-automation/
├── config/                    # Environment configs (dev/qe/staging/prod)
├── libraries/                 # Custom Python libraries (14 files)
├── resources/
│   ├── keywords/              # Robot Framework keyword files (24 files, per module)
│   └── locators/              # XPath/CSS locator definitions (19 files, per module)
├── variables/                 # Python variable modules (25 files, per module)
│   ├── _config_defaults.py    # Reads config/<env>.json for Python modules
│   └── _shared_seed.py        # Cross-suite variable sharing via .run_seed.json
├── tests/                     # Robot Framework test suites (25 files)
├── templates/                 # SOAP/API payload templates
├── prompts/                   # Reference specs and module prompts
├── documentation/             # Setup guides and project docs
├── reports/                   # Generated reports (gitignored)
├── bugs/                      # Generated bug reports (gitignored)
├── run_tests.py               # Central test runner
├── bug_reporter.py            # Auto bug report generator from test failures
├── send_report.py             # HTML email report sender
├── jira_bug_logger.py         # Push bug reports to Jira
└── tasks.csv                  # Global test ordering across all modules
```

## Running Tests

```bash
# All suites (tasks.csv order)
python run_tests.py --env qe

# Single suite
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Login" --env qe
python run_tests.py --suite "Label" --env qe

# E2E flows
python run_tests.py --e2e --env qe
python run_tests.py --e2e-with-usage --env qe
python run_tests.py --e2e --with-crud --env qe

# PAYG usage tests
python run_tests.py tests/payg_data_usage_tests.robot --env qe

# Sanity suite
python run_tests.py --sanity --env qe
python run_tests.py --sanity --env qe --parallel 4

# Filter by tag or test name
python run_tests.py --suite "Rule Engine" --env qe --include smoke
python run_tests.py tests/payg_data_usage_tests.robot --env qe --test "TC_PAYG_POOL_*"

# Re-run failures
python run_tests.py --suite "Rule Engine" --rerunfailed reports/2026-04-13_04-29-56

# Skip suites or tests
python run_tests.py --env qe --skip-suite "Label"
python run_tests.py --suite "APN" --env qe --skip-test "TC_APN_022*"

# With email report
python run_tests.py --suite "Login" --env qe --email

# Headless
python run_tests.py --e2e --env qe --browser headlesschrome
```

## Bug Reports & Email

```bash
# Bug reports auto-generate on failures after every run

# Email report (via run_tests.py)
python run_tests.py --suite "Login" --env qe --email

# Standalone email for past run
python send_report.py reports/2026-04-15_10-30-00

# Standalone bug report
python bug_reporter.py reports/2026-04-15_10-30-00

# Jira bug logger
python jira_bug_logger.py              # Interactive
python jira_bug_logger.py --all        # Push all unlogged
python jira_bug_logger.py --list       # List status
```

Configuration: copy `.env.example` to `.env` and fill SMTP + Jira credentials.

## Environment Config

All environment-specific values live in `config/<env>.json`. Key entries:
- `BASE_URL` — application URL
- `VALID_USERNAME` / `VALID_PASSWORD` — login credentials
- `DEFAULT_EC_ACCOUNT` / `DEFAULT_BU_ACCOUNT` — default test accounts
- `DB_*` / `SSH_*` — database and server connection details
- `USAGE_*` — usage injection API settings
- `INVOICE_*` — invoice API and SSH settings
- Module-specific URLs (`RE_RULE_ENGINE_URL`, `CSR_JOURNEY_URL`, etc.)

Variable resolution order: seed file > environment variable > config JSON > hardcoded fallback.

## Test Modules (25 suites, 500+ test cases)

| Module | File | TCs | Description |
|--------|------|-----|-------------|
| Login | login_tests.robot | 12 | Login/logout, captcha, security |
| Sanity | sanity_tests.robot | 48 | Page-load checks across all CMP pages |
| Onboard Customer API | onboard_customer_api_tests.robot | 40 | SOAP API customer onboarding |
| APN | apn_tests.robot | 22 | Create/Edit/Delete APN configs |
| SIM Range | sim_range_tests.robot | 21 | ICCID/IMSI range management |
| SIM Range MSISDN | sim_range_msisdn_tests.robot | 26 | MSISDN range management |
| SIM Order | sim_order_tests.robot | 21 | SIM order creation and validation |
| IP Pool | ip_pool_tests.robot | 17 | IP pool management |
| IP Whitelist | ip_whitelist_tests.robot | 20 | IP whitelisting |
| Device State | device_state_tests.robot | 16 | SIM state changes |
| Device Plan | device_plan_tests.robot | 11 | Device plan CRUD |
| Cost Center | cost_center_tests.robot | 26 | Cost center management |
| CSR Journey | csr_journey_tests.robot | 56 | CSR journey wizard |
| Product Type | product_type_tests.robot | 18 | SIM product type management |
| Rule Engine | rule_engine_tests.robot | 28 | 4-tab rule wizard |
| Role Management | role_management_tests.robot | 33 | Role and permission management |
| User Management | user_management_tests.robot | 45 | User CRUD and status management |
| Label | label_tests.robot | 28 | Label management + tag assignment |
| Report | report_tests.robot | 14 | Report creation and download |
| SIM Movement | sim_movement_tests.robot | 6 | SIM movement between BU accounts |
| SIM Replacement | sim_replacement_tests.robot | 8 | SIM replacement end-to-end |
| PAYG Data Usage | payg_data_usage_tests.robot | 40+ | PAYG multi-scenario usage tests |
| E2E Flow A | e2e_flow.robot | 17 | Full SIM lifecycle (no usage) |
| E2E Flow B | e2e_flow_with_usage.robot | 20 | Full SIM lifecycle + usage |
| Role/User CRUD | role_user_crud_tests.robot | 4 | Quick CRUD positive tests |

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
- Test Teardown: `Handle Test Teardown` (captures screenshots)

### Waits
- Use `Wait For Loading Overlay To Disappear` after navigation/clicks
- Use `Wait Until Element Is Visible` with explicit timeout for elements
- Avoid `Sleep` — use smart waits. Only use Sleep when async options load lazily
- No `Wait Until Keyword Succeeds` retries — fix the root cause instead

### Config-Driven Accounts
- All variable files use `config_scalar("DEFAULT_EC_ACCOUNT")` as fallback
- Never hardcode account names — they differ per environment
- Cross-suite sharing via `.run_seed.json` (written by E2E, read by module suites)

### Test Isolation
- Each create-test must delete its created resource afterward
- Suite Setup should clean up leftover data from previous runs
- Tests must not depend on other tests' side effects (except E2E ordered steps)

### Screenshots
- STCReportListener renames screenshots to `{TC_ID}_step_{NN}_{desc}.png`
- Screenshots go into `reports/<timestamp>/<Module>/` subfolder
- Both PASS and FAIL screenshots are captured

## Key Libraries

| Library | Purpose |
|---|---|
| `STCReportListener.py` | RF Listener v2 — screenshot renaming, module subfolders, JSON metadata |
| `STCPDFReport.py` | PDF report generator from combined_output.xml + stc_test_data.json |
| `RuleEngineTab2.py` | Rule Engine custom dropdown handling (portal-aware JS) |
| `ReTriggerDebug.py` | Rule Engine trigger form fill (multi-layout, smart values) |
| `ConfigLoader.py` | Loads config/<env>.json as Robot suite variables |
| `SeedWriter.py` | Writes cross-suite seed values to .run_seed.json |
| `SkipTestsByName.py` | Pre-run modifier to skip tests by glob pattern |
| `bug_reporter.py` | Auto-generates bug report folders from failed tests |
| `send_report.py` | Sends HTML email with pass/fail stats and report attachments |
| `jira_bug_logger.py` | Pushes bug reports to Jira with screenshots |

## Adding a New Module

1. Create `tests/<module>_tests.robot` with test cases
2. Create `resources/keywords/<module>_keywords.resource` with keywords
3. Create `resources/locators/<module>_locators.resource` with XPath locators
4. Create `variables/<module>_variables.py` with test data (use `config_scalar()` for accounts)
5. Add entries to `tasks.csv` for global ordering
6. Add module URLs to all `config/<env>.json` files
7. Create `prompts/<module>/Module.md` with module documentation
