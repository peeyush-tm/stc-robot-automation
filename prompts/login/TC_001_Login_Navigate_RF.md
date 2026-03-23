# Automation Test Specification – Login & Navigate

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary
**Date:** 2026-03-10
**Owner:** STC QA / Automation Team
**Application:** STC CMP Web Application

---

## 1. Objective

This test specification documents the **Login & Navigate** test suite for the STC CMP web application. The automation covers:

1. **Positive flows:** Valid login, logout, navigation to Manage Devices, and verification of Manage Devices page elements
2. **Negative flows — credentials:** Invalid username, invalid password, empty fields, all fields empty
3. **Negative flows — captcha:** Empty captcha, incorrect captcha
4. **Negative flows — security:** SQL injection, special characters, whitespace-only username
5. **Negative flows — unauthorized access:** Direct access to ManageDevices without login

The suite validates authentication, session management, and navigation to the Manage Devices page. Captcha is fetched from MySQL database at runtime.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874/` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **Application Type** | React SPA (Single Page Application) |
| **Valid Username** | `ksa_opco` |
| **Valid Password** | `Admin@123` |
| **Captcha Source** | MySQL DB — host: `192.168.1.122`, db: `stc_s5_p1`, query: `SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1` |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- MySQL database is reachable at `192.168.1.122` for captcha fetch
- **Python 3.8+**, **Robot Framework**, **robotframework-seleniumlibrary**, and **robotframework-databaselibrary** are installed
- ChromeDriver is installed and version-matched to the installed Chrome browser
- Valid credentials (`ksa_opco` / `Admin@123`) exist in the system

---

## 4. Environment Setup

### 4.1 Installation

```bash
pip install robotframework
pip install robotframework-seleniumlibrary
pip install robotframework-databaselibrary
pip install PyMySQL
```

### 4.2 Run Command

**ALWAYS use `run_tests.py` — never use `python -m robot` directly.**

```bash
# Run ALL suites (reads tasks.csv for ordering)
python run_tests.py

# Run Login suite only
python run_tests.py tests/login_tests.robot

# Run by module name (from tasks.csv)
python run_tests.py --suite Login

# Run a single test case by name
python run_tests.py tests/login_tests.robot --test "TC_LOGIN_001*"

# Run by tag
python run_tests.py --include smoke
python run_tests.py --include login

# Environment and browser overrides
python run_tests.py --env staging --browser firefox
```

### 4.3 Project Structure

```
d:\stc-automation\
├── config\
│   └── env_config.py              # Environment variables (BASE_URL, DB_*, VALID_USERNAME, etc.)
├── variables\
│   └── login_variables.py         # Test data (INVALID_*, ERROR_*, MANAGE_DEVICES_*)
├── resources\
│   ├── locators\
│   │   └── login_locators.resource
│   └── keywords\
│       ├── login_keywords.resource
│       └── browser_keywords.resource
├── tests\
│   └── login_tests.robot
├── run_tests.py
├── tasks.csv
└── reports\
    └── <timestamp>\
        ├── output.xml
        ├── log.html
        └── report.html
```

---

## 5. Test Data

| Variable | Value | Notes |
|---|---|---|
| **INVALID_USERNAME** | `WRONG_USER_<random>` | Random 8-char suffix |
| **INVALID_PASSWORD** | `wrongpass_<random>` | Random 8-char suffix |
| **SQL_INJECTION_INPUT** | `' OR '1'='1' --` | SQL injection payload |
| **SPECIAL_CHARS_INPUT** | `!@#$%^&*()_+{}|:<>?` | Special characters |
| **WHITESPACE_INPUT** | `   ` | Spaces only |
| **INCORRECT_CAPTCHA** | `ZZZZZZ` | Deliberately wrong captcha |
| **EMPTY_STRING** | `` | Empty string |
| **ERROR_AUTH_FAILURE** | `Authorization Failure` | Inline error text |
| **ERROR_INVALID_CAPTCHA** | `Invalid Captcha` | Inline error text |
| **ERROR_PLEASE_ENTER_CAPTCHA** | `Please Enter Captcha` | Toast error text |
| **ERROR_USERNAME_REQUIRED** | `Username is required` | Field validation text |
| **ERROR_PASSWORD_REQUIRED** | `Password Required` | Field validation text |

---

## 6. Robot Framework Settings and Variables

### 6.1 Test Suite Settings (from `login_tests.robot`)

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/locators/login_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser
```

### 6.2 Variables (from `config/env_config.py` and `variables/login_variables.py`)

| Variable | Source | Value |
|---|---|---|
| `${BASE_URL}` | env_config | `https://192.168.1.26:7874/` |
| `${VALID_USERNAME}` | env_config | `ksa_opco` |
| `${VALID_PASSWORD}` | env_config | `Admin@123` |
| `${BROWSER}` | env_config | `chrome` |
| `${DB_HOST}` | env_config | `192.168.1.122` |
| `${DB_PORT}` | env_config | `3306` |
| `${DB_NAME}` | env_config | `stc_s5_p1` |
| `${DB_USER}` | env_config | `java_dev` |
| `${DB_PASS}` | env_config | `Java@123` |
| `${CAPTCHA_QUERY}` | env_config | `SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1` |
| `${MANAGE_DEVICES_URL}` | login_variables | `https://192.168.1.26:7874/ManageDevices` |
| `${MANAGE_DEVICES_PATH}` | login_variables | `/ManageDevices` |

---

## 7. Automation Flow

### Step 1 — Wait For Login Page Ready

| Sub-step | RF Keyword | Locator / Detail |
|---|---|---|
| 1.1 | `Wait For Loading Overlay To Disappear` | — |
| 1.2 | `Wait Until Element Is Visible` | `${LOC_LOGIN_ROOT}` timeout=30s |
| 1.3 | `Wait Until Element Is Visible` | `${LOC_LOGIN_USERNAME_INPUT}` timeout=30s |
| 1.4 | `Wait Until Element Is Visible` | `${LOC_LOGIN_PASSWORD_INPUT}` timeout=30s |
| 1.5 | `Wait Until Element Is Visible` | `${LOC_LOGIN_CAPTCHA_IMAGE}` timeout=30s |
| 1.6 | `Wait Until Element Is Visible` | `${LOC_LOGIN_CAPTCHA_INPUT}` timeout=30s |
| 1.7 | `Wait Until Element Is Visible` | `${LOC_LOGIN_BUTTON}` timeout=30s |

### Step 2 — Enter Credentials and Captcha

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 2.1 | `Enter Username` | `${username}` |
| 2.2 | `Enter Password` | `${password}` |
| 2.3 | `Fetch Captcha Value` | Connect → Query → Disconnect; returns captcha |
| 2.4 | `Enter Captcha` | `${captcha_value}` |

### Step 3 — Click Login Button

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 3.1 | `Sleep` | 2s |
| 3.2 | `Wait For Loading Overlay To Disappear` | — |
| 3.3 | `Execute Javascript` | Click `input[type='button'][class*='btn-custom-color']` (JS click to bypass overlay) |

### Step 4 — Verify Login Success

| Sub-step | RF Keyword | Locator / Detail |
|---|---|---|
| 4.1 | `Wait Until Element Is Not Visible` | `${LOC_LOGIN_BUTTON}` timeout=30s |
| 4.2 | `Wait Until Element Is Visible` | `${LOC_MD_GRID_DATA}` timeout=30s |
| 4.3 | `Wait Until Element Is Visible` | `${LOC_MD_GRID_TBODY}` timeout=30s |
| 4.4 | `Wait Until Element Is Visible` | `${LOC_POST_LOGIN_LANDMARK}` timeout=30s |
| 4.5 | `Page Should Not Contain Element` | `${LOC_LOGIN_ERROR_MESSAGE}` |
| 4.6 | `Get Element Count` | `${LOC_MD_DEVICE_ROWS}` → row_count > 0 |

### Step 5 — Logout Flow

| Sub-step | RF Keyword | Locator / Detail |
|---|---|---|
| 5.1 | `Click Element Via JS` | `${LOC_USER_PROFILE_MENU}` |
| 5.2 | `Wait Until Element Is Visible` | `${LOC_LOGOUT_BUTTON}` timeout=30s |
| 5.3 | `Click Element Via JS` | `${LOC_LOGOUT_BUTTON}` |
| 5.4 | `Wait Until Element Is Visible` | `${LOC_LOGIN_ROOT}`, `${LOC_LOGIN_USERNAME_INPUT}`, `${LOC_LOGIN_BUTTON}` |

### Step 6 — Navigate To Manage Devices

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 6.1 | `Go To` | `${MANAGE_DEVICES_URL}` |
| 6.2 | `Wait For Page Load` | — |

### Step 7 — Verify Manage Devices Page Loaded

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 7.1 | `Location Should Contain` | `${MANAGE_DEVICES_PATH}` |
| 7.2 | `Wait Until Element Is Visible` | `${LOC_MD_GRID_DATA}`, `${LOC_MD_SEARCH_INPUT}`, `${LOC_MD_ACTION_FORM}` |

### Step 8 — Verify Manage Devices Grid Has Data

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 8.1 | `Wait Until Element Is Visible` | `${LOC_MD_GRID_TBODY}`, `${LOC_MD_FIRST_DEVICE_ROW}` |
| 8.2 | `Get Element Count` | `${LOC_MD_DEVICE_ROWS}` → row_count > 0 |

---

## 8. Complete Test File

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/locators/login_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_001 Valid Credentials Should Login Successfully
    [Documentation]    Enter valid username and password, fetch captcha from DB and enter it,
    ...                click Login. Verify: error message absent, post-login landmark visible.
    [Tags]    smoke    regression    positive    login
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success

TC_LOGIN_002 Logout Should Redirect To Login Page
    [Documentation]    Login with valid credentials, then logout.
    ...                Verify: login page elements (username, password, login button) reappear.
    [Tags]    smoke    regression    positive    login
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Perform Logout
    Verify Logout Success

TC_LOGIN_003 Navigate To Manage Devices After Login
    [Documentation]    Login successfully, then navigate to /ManageDevices.
    ...                Verify: URL contains /ManageDevices, grid data container is visible.
    [Tags]    smoke    regression    positive    login    navigation
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Navigate To Manage Devices
    Verify Manage Devices Page Loaded

TC_LOGIN_004 Verify Manage Devices Page Elements
    [Documentation]    Login and navigate to Manage Devices.
    ...                Verify: gridData, searchinput, actionForm are present; grid has at least one row.
    [Tags]    regression    positive    login    navigation
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Navigate To Manage Devices
    Verify Manage Devices Page Loaded
    Verify Manage Devices Grid Has Data

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CREDENTIALS
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_005 Invalid Username Should Show Error
    [Documentation]    Enter an invalid username with a valid password.
    ...                Verify: "Authorization Failure" error displayed.
    [Tags]    regression    negative    login
    Login With Credentials    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_006 Invalid Password Should Show Error
    [Documentation]    Enter the valid username with an invalid password.
    ...                Verify: "Authorization Failure" error displayed.
    [Tags]    regression    negative    login
    Login With Credentials    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_007 Both Invalid Username And Password Should Show Error
    [Documentation]    Enter both invalid username and invalid password.
    ...                Verify: "Authorization Failure" error displayed.
    [Tags]    regression    negative    login
    Login With Credentials    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_008 Empty Username Field Should Show Error
    [Documentation]    Leave username empty, enter a valid password.
    ...                Verify: "Username is required" inline field validation displayed.
    [Tags]    regression    negative    login
    Login With Credentials    ${EMPTY_STRING}    ${VALID_PASSWORD}
    Verify Username Required Error

TC_LOGIN_009 Empty Password Field Should Show Error
    [Documentation]    Enter valid username, leave password empty.
    ...                Verify: "Password Required" field validation displayed.
    [Tags]    regression    negative    login
    Login With Credentials    ${VALID_USERNAME}    ${EMPTY_STRING}
    Verify Password Required Error

TC_LOGIN_010 All Fields Empty Should Show Error
    [Documentation]    Leave username, password, and captcha fields all empty.
    ...                Verify: both "Username is required" and "Password Required" displayed.
    [Tags]    regression    negative    login
    Login With Credentials And Empty Captcha    ${EMPTY_STRING}    ${EMPTY_STRING}
    Verify All Fields Empty Error

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CAPTCHA
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_011 Empty Captcha Should Show Error
    [Documentation]    Enter valid credentials but leave captcha field empty.
    ...                Verify: "Please Enter Captcha" toast error displayed.
    [Tags]    regression    negative    login    captcha
    Login With Credentials And Empty Captcha    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Please Enter Captcha Toast

TC_LOGIN_012 Incorrect Captcha Should Show Error
    [Documentation]    Enter valid credentials with a deliberately wrong captcha value.
    ...                Verify: "Invalid Captcha" error displayed.
    [Tags]    regression    negative    login    captcha
    Login With Credentials And Wrong Captcha    ${VALID_USERNAME}    ${VALID_PASSWORD}    ${INCORRECT_CAPTCHA}
    Verify Invalid Captcha Error

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — SECURITY / INJECTION
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_013 SQL Injection In Username Should Be Rejected
    [Documentation]    Enter a SQL injection payload as the username.
    ...                Verify: "Authorization Failure" error displayed; auth NOT bypassed.
    [Tags]    regression    negative    security    login
    Login With Credentials    ${SQL_INJECTION_INPUT}    ${VALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_014 Special Characters In Username Should Show Error
    [Documentation]    Enter special characters as the username.
    ...                Verify: "Authorization Failure" error displayed; no unhandled exception.
    [Tags]    regression    negative    security    login
    Login With Credentials    ${SPECIAL_CHARS_INPUT}    ${VALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_015 Whitespace Only Username Should Show Error
    [Documentation]    Enter whitespace-only input in the username field.
    ...                Verify: error displayed — "Authorization Failure" or "Username is required".
    [Tags]    regression    negative    login
    Login With Credentials    ${WHITESPACE_INPUT}    ${VALID_PASSWORD}
    Verify Login Error Displayed
    Verify Still On Login Page

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_016 Direct Access To ManageDevices Without Login Should Redirect
    [Documentation]    Navigate directly to /ManageDevices without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    login    navigation
    Navigate To Manage Devices
    Verify Redirected To Login Page
```

---

## 9. UI Elements and Locator Table

All locators are defined in `d:\stc-automation\resources\locators\login_locators.resource`.

### 9.1 Login Page

| Variable | Description | RF Locator String |
|---|---|---|
| `${LOC_LOGIN_ROOT}` | React root container | `xpath=//div[@id='root']` |
| `${LOC_LOGIN_USERNAME_INPUT}` | Username input | `xpath=//input[@name='username']` |
| `${LOC_LOGIN_PASSWORD_INPUT}` | Password input | `xpath=//input[@name='password']` |
| `${LOC_LOGIN_CAPTCHA_INPUT}` | Captcha input | `xpath=//input[@name='captcha']` |
| `${LOC_LOGIN_CAPTCHA_IMAGE}` | Captcha image | `xpath=//img[@id='image']` |
| `${LOC_LOGIN_BUTTON}` | Login button | `xpath=//input[@type='button' and contains(@class,'btn-custom-color')]` |
| `${LOC_LOGIN_ERROR_MESSAGE}` | Inline error (div.erre-it) | `xpath=//div[contains(@class,'erre-it')]` |
| `${LOC_LOGIN_TOAST_ERROR}` | Toast error | `xpath=//div[contains(@class,'Toastify__toast--error')] \| //div[contains(@class,'Toastify')]//div[contains(@class,'toast--error')]` |
| `${LOC_LOGIN_FIELD_VALIDATION}` | Field validation text | `xpath=//*[contains(text(),'is required') or contains(text(),'Required')]` |
| `${LOC_USERNAME_VALIDATION}` | Username required | `xpath=//*[contains(text(),'Username is required')]` |
| `${LOC_PASSWORD_VALIDATION}` | Password required | `xpath=//*[contains(text(),'Password Required')]` |

### 9.2 Post-Login / Navigation

| Variable | Description | RF Locator String |
|---|---|---|
| `${LOC_POST_LOGIN_LANDMARK}` | Post-login grid rows | `xpath=//div[@id='gridData']//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')]` |
| `${LOC_USER_PROFILE_MENU}` | User profile dropdown | `xpath=//li[@id='userSetting']//a` |
| `${LOC_LOGOUT_BUTTON}` | Logout link | `xpath=//a[.//i[contains(@class,'user-log-out')]]` |

### 9.3 Manage Devices Page

| Variable | Description | RF Locator String |
|---|---|---|
| `${LOC_MD_GRID_DATA}` | Grid container | `xpath=//div[@id='gridData']` |
| `${LOC_MD_SEARCH_INPUT}` | Search input | `xpath=//input[@id='searchinput']` |
| `${LOC_MD_ACTION_FORM}` | Action form | `xpath=//form[@id='actionForm']` |
| `${LOC_MD_GRID_TBODY}` | Grid tbody | `xpath=//div[@id='gridData']//tbody[@role='rowgroup']` |
| `${LOC_MD_FIRST_DEVICE_ROW}` | First device row | `xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]` |
| `${LOC_MD_DEVICE_ROWS}` | All device rows | `xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]` |

---

## 10. Expected Results

| Test Case | Expected Outcome |
|---|---|
| TC_LOGIN_001 | Login button disappears; grid visible; no error; row_count > 0 |
| TC_LOGIN_002 | After logout: login root, username input, login button visible |
| TC_LOGIN_003 | URL contains `/ManageDevices`; gridData, searchinput, actionForm visible |
| TC_LOGIN_004 | Same as TC_LOGIN_003 + at least one device row in grid |
| TC_LOGIN_005–007 | Inline error "Authorization Failure"; still on login page |
| TC_LOGIN_008 | Field validation "Username is required"; still on login page |
| TC_LOGIN_009 | Field validation "Password Required" or any login error; still on login page |
| TC_LOGIN_010 | Both "Username is required" and "Password Required" visible |
| TC_LOGIN_011 | Toast "Please Enter Captcha"; still on login page |
| TC_LOGIN_012 | Inline error "Invalid Captcha"; still on login page |
| TC_LOGIN_013–014 | Inline error "Authorization Failure"; still on login page |
| TC_LOGIN_015 | Any login error (inline/toast/field); still on login page |
| TC_LOGIN_016 | Login page visible; URL does not contain `/ManageDevices` |

---

## 11. Negative Test Scenarios

| Scenario ID | Description | Action | Verification Keyword |
|---|---|---|---|
| NEG-01 | Invalid username | `Login With Credentials` with `${INVALID_USERNAME}` | `Verify Authorization Failure Error` |
| NEG-02 | Invalid password | `Login With Credentials` with `${INVALID_PASSWORD}` | `Verify Authorization Failure Error` |
| NEG-03 | Both invalid | `Login With Credentials` with both invalid | `Verify Authorization Failure Error` |
| NEG-04 | Empty username | `Login With Credentials` with `${EMPTY_STRING}` | `Verify Username Required Error` |
| NEG-05 | Empty password | `Login With Credentials` with `${EMPTY_STRING}` | `Verify Password Required Error` |
| NEG-06 | All fields empty | `Login With Credentials And Empty Captcha` with empty | `Verify All Fields Empty Error` |
| NEG-07 | Empty captcha | `Login With Credentials And Empty Captcha` with valid creds | `Verify Please Enter Captcha Toast` |
| NEG-08 | Wrong captcha | `Login With Credentials And Wrong Captcha` | `Verify Invalid Captcha Error` |
| NEG-09 | SQL injection | `Login With Credentials` with `${SQL_INJECTION_INPUT}` | `Verify Authorization Failure Error` |
| NEG-10 | Special chars | `Login With Credentials` with `${SPECIAL_CHARS_INPUT}` | `Verify Authorization Failure Error` |
| NEG-11 | Whitespace only | `Login With Credentials` with `${WHITESPACE_INPUT}` | `Verify Login Error Displayed` + `Verify Still On Login Page` |
| NEG-12 | Direct ManageDevices | `Navigate To Manage Devices` without login | `Verify Redirected To Login Page` |

---

## 12. Validation Keywords

Key validation keywords from `d:\stc-automation\resources\keywords\login_keywords.resource`:

```robot
Verify Login Success
    Wait Until Element Is Not Visible    ${LOC_LOGIN_BUTTON}    timeout=30s
    Wait Until Element Is Visible        ${LOC_MD_GRID_DATA}       timeout=30s
    Wait Until Element Is Visible        ${LOC_MD_GRID_TBODY}      timeout=30s
    Wait Until Element Is Visible        ${LOC_POST_LOGIN_LANDMARK}    timeout=30s
    Page Should Not Contain Element      ${LOC_LOGIN_ERROR_MESSAGE}
    ${row_count}=    Get Element Count   ${LOC_MD_DEVICE_ROWS}
    Should Be True   ${row_count} > 0

Verify Authorization Failure Error
    Verify Inline Error Message Is       ${ERROR_AUTH_FAILURE}
    Verify Still On Login Page

Verify Invalid Captcha Error
    Verify Inline Error Message Is       ${ERROR_INVALID_CAPTCHA}
    Verify Still On Login Page

Verify Please Enter Captcha Toast
    Verify Toast Error Message Is        ${ERROR_PLEASE_ENTER_CAPTCHA}
    Verify Still On Login Page

Verify Username Required Error
    Verify Field Validation Message      ${ERROR_USERNAME_REQUIRED}
    Verify Still On Login Page

Verify Password Required Error
    # Checks field validation, or any login error
    Verify Still On Login Page

Verify All Fields Empty Error
    Verify Field Validation Message      ${ERROR_USERNAME_REQUIRED}
    Verify Field Validation Message      ${ERROR_PASSWORD_REQUIRED}
    Verify Still On Login Page

Verify Still On Login Page
    Wait Until Element Is Visible        ${LOC_LOGIN_BUTTON}    timeout=30s
    Wait Until Element Is Visible        ${LOC_LOGIN_USERNAME_INPUT}    timeout=30s

Verify Redirected To Login Page
    Wait Until Element Is Visible        ${LOC_LOGIN_ROOT}            timeout=30s
    Wait Until Element Is Visible        ${LOC_LOGIN_USERNAME_INPUT}  timeout=30s
    Wait Until Element Is Visible        ${LOC_LOGIN_BUTTON}          timeout=30s
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    ${MANAGE_DEVICES_PATH}
```

---

## 13. Automation Considerations

### Captcha Fetch
- Captcha is fetched from MySQL via `DatabaseLibrary` (Connect → Query → Disconnect)
- Query: `SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1`
- DB connection uses `${DB_HOST}`, `${DB_PORT}`, `${DB_NAME}`, `${DB_USER}`, `${DB_PASS}` from `env_config.py`

### Login Button Click
- Use **JS click** (`Execute Javascript` or `Click Element Via JS`) to bypass loading-indicator overlay
- Direct `Click Element` may fail if overlay is present

### Loading Overlay
- App adds `loading-indicator` class to `<body>` during API calls
- `Wait For Loading Overlay To Disappear` waits for `!document.body.classList.contains('loading-indicator')`
- If stuck > 60s, overlay is force-removed via JS

### SSL Certificate Bypass
- `ChromeOptions` with `--ignore-certificate-errors` and `acceptInsecureCerts=True` in `browser_keywords.resource`

### Test Isolation
- Each test gets a fresh browser via `Test Setup: Open Browser And Navigate`
- `Test Teardown: Capture Screenshot And Close Browser` — screenshot on failure, then close

### Suite Registration
- Login suite is registered in `tasks.csv` (order 1–16)
- New test cases must be added to `tasks.csv` for `run_tests.py` ordering

---

## 14. Success Validation Checklist

- [ ] `run_tests.py` used for execution (not `python -m robot` directly)
- [ ] `Login With Credentials` fetches captcha from DB and completes login
- [ ] `Verify Login Success` passes — grid visible, no error, rows > 0
- [ ] `Perform Logout` + `Verify Logout Success` — login page visible
- [ ] `Navigate To Manage Devices` + `Verify Manage Devices Page Loaded` — URL and elements correct
- [ ] `Verify Manage Devices Grid Has Data` — at least one device row
- [ ] All 16 test cases execute without framework errors
- [ ] Negative tests correctly assert error messages (Authorization Failure, Invalid Captcha, Please Enter Captcha, Username is required, Password Required)
- [ ] TC_LOGIN_016 redirects to login when accessing ManageDevices without auth
- [ ] Reports generated in `reports/<timestamp>/` (output.xml, log.html, report.html)

---

## 15. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-10 | STC QA Team | Initial specification for TC_001 Login & Navigate; aligned to project structure, locators, variables, and keywords in `d:\stc-automation` |
