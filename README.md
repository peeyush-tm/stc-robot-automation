# STC Automation — GControl IoT Test Suite

End-to-end test automation for the **GControl IoT** web application using **Robot Framework**, **SeleniumLibrary**, and **RequestsLibrary**.

---

## Project Structure

```
STC Automation latest/
├── config/
│   └── env_config.py               # Environment configuration (dev/staging/prod)
│
├── tests/                          # Robot Framework test suites
│   ├── login_tests.robot           # Login & authentication tests
│   ├── csr_journey_tests.robot     # CSR Journey CRUD tests
│   ├── product_type_tests.robot    # SIM Product Type tests
│   ├── cost_center_tests.robot     # Cost Center tests
│   ├── sanity_tests.robot          # Basic sanity / smoke tests
│   ├── user_management_tests.robot # User creation & deletion tests
│   ├── role_management_tests.robot # Role creation & deletion tests
│   └── onboard_customer_api_tests.robot  # Account Onboarding SOAP API tests
│
├── resources/
│   ├── keywords/                   # Reusable Robot Framework keywords
│   │   ├── browser_keywords.resource
│   │   ├── login_keywords.resource
│   │   ├── csr_journey_keywords.resource
│   │   ├── product_type_keywords.resource
│   │   ├── cost_center_keywords.resource
│   │   ├── sanity_keywords.resource
│   │   ├── user_management_keywords.resource
│   │   ├── role_management_keywords.resource
│   │   └── api_keywords.resource
│   └── locators/                   # Element locators (XPath / CSS)
│       ├── csr_journey_locators.resource
│       ├── product_type_locators.resource
│       ├── cost_center_locators.resource
│       ├── sanity_locators.resource
│       ├── user_management_locators.resource
│       └── role_management_locators.resource
│
├── variables/                      # Python variable files (test data)
│   ├── login_variables.py          # Login credentials (standalone fallback)
│   ├── csr_journey_variables.py
│   ├── product_type_variables.py
│   ├── cost_center_variables.py
│   ├── sanity_variables.py
│   ├── user_management_variables.py
│   ├── role_management_variables.py
│   └── onboard_customer_variables.py
│
├── prompts/                        # Test specification / requirement docs
│   ├── TC_005_Create_CSR_Journey_RF 1.md
│   ├── TC_006_Create_SIM_Product_Type_RF 1.md
│   ├── TC_013_Create_Cost_Center_RF.md
│   ├── TC_Create_And_Delete_User.md
│   ├── role_create_delete.md
│   └── GControl_IoT_Basic_Sanity_Suite.md
│
├── reports/                        # Generated test reports (git-ignored)
│
├── tasks.csv                       # Test case registry (279 tests)
├── run_tests.py                    # Custom test runner script
├── requirements.txt                # Python dependencies
├── .gitignore
└── README.md
```

---

## Prerequisites

- **Python** 3.10+
- **Google Chrome** (latest stable) with matching **ChromeDriver** on PATH
- **pip** (bundled with Python)

---

## Installation

```bash
# Clone the repository
git clone <repo-url> "STC Automation latest"
cd "STC Automation latest"

# Create a virtual environment (recommended)
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS / Linux

# Install dependencies
pip install -r requirements.txt
```

---

## Running Tests

### Run all tests via the custom runner

```bash
python run_tests.py
```

Reports are generated in `reports/<timestamp>/` containing `output.xml`, `log.html`, and `report.html`.

### Filter by module

```bash
python run_tests.py --module Login
python run_tests.py --module CSRJourney CostCenter
```

### Filter by suite file

```bash
python run_tests.py --suite tests/login_tests.robot
```

### Filter by tag

```bash
python run_tests.py --tags smoke
```

### Dry run (list tests without executing)

```bash
python run_tests.py --dry-run
```

### Run a single suite directly with Robot Framework

```bash
robot --outputdir reports tests/login_tests.robot
robot --outputdir reports tests/csr_journey_tests.robot
robot --outputdir reports tests/cost_center_tests.robot
robot --outputdir reports tests/product_type_tests.robot
robot --outputdir reports tests/sanity_tests.robot
robot --outputdir reports tests/user_management_tests.robot
robot --outputdir reports tests/role_management_tests.robot
robot --outputdir reports tests/onboard_customer_api_tests.robot
```

---

## Test Modules

| Module | Suite File | Tests | Description |
|--------|-----------|-------|-------------|
| Login | `tests/login_tests.robot` | 20 | Login, logout, authentication, and security tests |
| CSRJourney | `tests/csr_journey_tests.robot` | 55 | CSR Journey create, modify, edit, and delete flows |
| ProductType | `tests/product_type_tests.robot` | 18 | SIM Product Type creation and validation |
| CostCenter | `tests/cost_center_tests.robot` | 25 | Cost Center creation with hierarchical account selection |
| Sanity | `tests/sanity_tests.robot` | 48 | Basic sanity checks across all application pages |
| UserManagement | `tests/user_management_tests.robot` | 45 | User creation, deletion, and form validation |
| RoleManagement | `tests/role_management_tests.robot` | 33 | Role creation, deletion, and permission assignment |
| AccountOnboardingAPI | `tests/onboard_customer_api_tests.robot` | 38 | SOAP API tests for customer account onboarding |

**Total: 279 test cases** (tracked in `tasks.csv`)

---

## Test Tags

Tests are tagged for flexible execution:

| Tag | Description |
|-----|-------------|
| `smoke` | Critical path tests for quick validation |
| `regression` | Full regression suite |
| `positive` | Valid input / happy-path tests |
| `negative` | Invalid input / error-handling tests |
| `edge` | Boundary and edge-case tests |
| `security` | Security-related tests (SQL injection, XSS) |
| `api` | API-level tests (no browser) |
| `crud` | Create / Read / Update / Delete operations |

---

## Environment Configuration

All environment-specific settings are centralized in `config/env_config.py`. It supports three environments: **dev** (default), **staging**, and **prod**.

### Variables provided by `env_config.py`

| Variable | Example (dev) | Description |
|----------|--------------|-------------|
| `BASE_URL` | `https://192.168.1.26:7874` | Application base URL |
| `LOGIN_URL` | `https://192.168.1.26:7874` | Login page URL |
| `VALID_USERNAME` | `ksa_opco` | Login username |
| `VALID_PASSWORD` | `Admin@123` | Login password |
| `BROWSER` | `chrome` | Browser for Selenium |
| `HEADLESS` | `False` | Run browser in headless mode |
| `DEFAULT_TIMEOUT` | `30s` | Default wait timeout |
| `PAGE_LOAD_TIMEOUT` | `60s` | Page load timeout |
| `ROOT_ACCOUNT_NAME` | `KSA_OPCO` | TreeView root account |
| `EC_ACCOUNT_NAME` | `SANJ_1002` | EC-level account |
| `BU_ACCOUNT_NAME` | `billingAccountSANJ_1003` | BU-level account |

### Switching environments

```bash
# Default (dev)
robot tests/login_tests.robot

# Staging
robot --variable ENV:staging tests/login_tests.robot

# Production
robot --variable ENV:prod tests/login_tests.robot

# Via the test runner
python run_tests.py                          # dev (default)
```

---

## Key Implementation Details

- **Browser Session Management** — UI test suites open the browser once at suite setup and close it at suite teardown. Individual tests navigate or refresh as needed.
- **Dynamic Test Data** — Python variable files generate unique values (timestamps, random digits) per run to avoid data collisions.
- **Custom Dropdown Handling** — Specialized keywords handle Kendo TreeView dropdowns, custom `div`-based dropdowns, and native `<select>` elements.
- **JavaScript Execution** — Used for reliable element clicks, scrolling, and triggering React `onChange` events where standard Selenium interactions are insufficient.
- **Page Load Synchronization** — `Wait For App Loading To Complete` keyword watches for loading indicators to disappear before proceeding.
- **SOAP API Testing** — Uses `RequestsLibrary` with SSL verification disabled, XML payload construction, and comprehensive response validation.

---

## Reports

All test output is generated inside `reports/<timestamp>/`:

```
reports/
└── 2026-03-09_23-14-16/
    ├── output_1_login_tests.xml
    ├── output_2_csr_journey_tests.xml
    ├── ...
    ├── output.xml          # merged output
    ├── log.html            # detailed execution log
    ├── report.html         # summary report
    └── selenium-screenshot-*.png
```

The `reports/` directory is git-ignored.
