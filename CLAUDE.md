# STC Automation Framework

Robot Framework + Python test automation for the STC (Telecommunications) CMP web application.

## Project Structure

```
stc-automation/
├── config/                    # Environment configs (dev/qe/staging/prod)
├── libraries/                 # Custom Python libraries (SeleniumLibrary extensions)
├── resources/
│   ├── keywords/              # Robot Framework keyword files (per module)
│   └── locators/              # XPath/CSS locator definitions (per module)
├── variables/                 # Python variable modules (per module)
│   ├── _config_defaults.py    # Reads config/<env>.json for Python modules
│   └── _shared_seed.py        # Cross-suite variable sharing via .run_seed.json
├── tests/                     # Robot Framework test files
├── templates/                 # SOAP/API payload templates
├── prompts/                   # Reference specs and module prompts
├── documentation/             # Setup guides and project docs
├── reports/                   # Generated reports (gitignored)
├── run_tests.py               # Central test runner
└── tasks.csv                  # Global test ordering across all modules
```

## Running Tests

```bash
# All suites (tasks.csv order)
python run_tests.py --env qe

# Single suite
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Login" --env qe

# E2E flows
python run_tests.py --e2e --env qe
python run_tests.py --e2e-with-usage --env qe

# Specific robot file
python run_tests.py tests/payg_data_usage_tests.robot --env qe

# Filter by tag or test name
python run_tests.py --suite "Rule Engine" --env qe --include smoke
python run_tests.py tests/payg_data_usage_tests.robot --env qe --test "TC_PAYG_POOL_*"

# Re-run failures
python run_tests.py --suite "Rule Engine" --rerunfailed reports/2026-04-13_04-29-56
```

## Environment Config

All environment-specific values live in `config/<env>.json`. Key entries:
- `BASE_URL` — application URL
- `VALID_USERNAME` / `VALID_PASSWORD` — login credentials
- `DEFAULT_EC_ACCOUNT` / `DEFAULT_BU_ACCOUNT` — default test accounts
- `DB_*` / `SSH_*` — database and server connection details
- Module-specific URLs (`RE_RULE_ENGINE_URL`, `CSR_JOURNEY_URL`, etc.)

Variable resolution order: seed file → environment variable → config JSON → hardcoded fallback.

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

## Adding a New Module

1. Create `tests/<module>_tests.robot` with test cases
2. Create `resources/keywords/<module>_keywords.resource` with keywords
3. Create `resources/locators/<module>_locators.resource` with XPath locators
4. Create `variables/<module>_variables.py` with test data (use `config_scalar()` for accounts)
5. Add entries to `tasks.csv` for global ordering
7. Add module URLs to all `config/<env>.json` files
