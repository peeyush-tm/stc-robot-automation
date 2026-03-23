# Automation Test Specification – Create SIM Order

**Document Version:** 1.2
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 13)*
**Date:** 2026-03-05
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md

---

## 1. Objective

This test validates the end-to-end **Create SIM Order** workflow using the **Live Order** path on the CMP web application. The automation begins from the **Manage Devices** page (post-login) and covers:

1. Navigating to the **Orders / Live Order** module via the left-side navigation panel
2. Launching the **Create SIM Order** wizard
3. Completing the **Live Order** tab form across two pages of mandatory fields
4. Reviewing the **Preview** page and submitting the order
5. Confirming the **success notification**, capturing the **Order ID**, and verifying the redirect back to the Live Order list

This test ensures the full order creation workflow is functional, all mandatory fields are validated, and the system correctly processes and acknowledges a submitted SIM order.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **Live Order Page URL** | `https://192.168.1.26:7874/LiveOrder` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` (credentials from `env_config.py`)
  - *(Tests use `Login And Navigate To Live Order` or `Login And Navigate To Create SIM Order` from `sim_order_keywords.resource`)*
- The `ksa_opco` user has permission to access the **Orders** module and create SIM orders
- The **Orders / Live Order** module is enabled and visible in the left-side navigation panel
- At least one valid **Device Plan**, **Country**, and **Customer Account** exists in the system for order creation
- **Python 3.8+**, **Robot Framework**, and **SeleniumLibrary** are installed
- ChromeDriver is installed and version-matched to the installed Chrome browser

---

## 4. Robot Framework Environment Setup

### 4.1 Installation

```bash
pip install robotframework
pip install robotframework-seleniumlibrary
```

### 4.2 Run Command

**Always use `run_tests.py`** (never `robot` directly):

```bash
# Run all SIM Order tests
python run_tests.py tests/sim_order_tests.robot

# Run by suite name (from tasks.csv)
python run_tests.py --suite "SIM Order"

# Run a single test case
python run_tests.py tests/sim_order_tests.robot --test "TC_SO_001*"

# Run by tag
python run_tests.py --include sim_order
python run_tests.py --include smoke
```

### 4.3 Project Structure

```
d:\stc-automation\
├── config\
│   └── env_config.py              # Environment config (BASE_URL, VALID_USERNAME, BROWSER, etc.)
├── variables\
│   ├── login_variables.py         # Login test data
│   └── sim_order_variables.py     # SIM Order test data (URLs, form values, negative inputs)
├── resources\
│   ├── locators\
│   │   ├── login_locators.resource
│   │   └── sim_order_locators.resource
│   └── keywords\
│       ├── browser_keywords.resource   # Open/Close browser, Wait For Page Load, Click Element Via JS
│       ├── login_keywords.resource    # Login With Credentials, Verify Redirected To Login Page
│       └── sim_order_keywords.resource
├── tests\
│   └── sim_order_tests.robot
├── run_tests.py
├── tasks.csv
└── reports\<timestamp>\
    └── (output.xml, log.html, report.html)
```

---

## 5. Test Data

Test data is defined in `variables/sim_order_variables.py` and `config/env_config.py`:

| Variable | Sample Value | Notes |
|---|---|---|
| **Credentials** (from `env_config.py`) | | |
| `${VALID_USERNAME}` | `ksa_opco` | From env_config |
| `${VALID_PASSWORD}` | `Admin@123` | From env_config |
| **URLs** | | |
| `${LIVE_ORDER_URL}` | `https://192.168.1.26:7874/LiveOrder` | |
| `${CREATE_SIM_ORDER_URL}` | `https://192.168.1.26:7874/CreateSIMOrder` | |
| **Valid Form Data — Step 1** | | |
| `${VALID_ACCOUNT_NAME}` | `KSA_OPCO` | |
| `${VALID_SIM_TYPE_VALUE}` | `6` | |
| `${VALID_QUANTITY}` | `5` | |
| `${VALID_ACTIVATION_TYPE}` | `autoActivation` | |
| `${VALID_SIM_STATE_VALUE}` | `1` | |
| **Valid Form Data — Step 2** | | |
| `${VALID_ADDRESS_LINE1}` | `123 Test Street` | |
| `${VALID_AREA}` | `Riyadh Region` | |
| `${VALID_CITY}` | `Riyadh` | |
| `${VALID_POSTAL_CODE}` | `12345` | |
| **Cancel Order** | | |
| `${VALID_CANCEL_REASON}` | `Automated test cancel` | |
| `${VALID_CANCEL_REMARKS}` | *(timestamped)* | |
| **Negative Test Data** | | |
| `${QUANTITY_ZERO}` | `0` | |
| `${QUANTITY_NEGATIVE}` | `-1` | |
| `${QUANTITY_NON_NUMERIC}` | `abc` | |
| `${SPECIAL_CHARS_ADDRESS}` | `!@#$%^&*()_+{}|:<>?` | |
| `${SQL_INJECTION_QUANTITY}` | `5; DROP TABLE orders;--` | |

### 5.1 Test Case List (from `tests/sim_order_tests.robot`)

| ID | Test Case Name | Tags |
|---|---|---|
| TC_SO_001 | E2E Create SIM Order Successfully | smoke, regression, positive, sim_order |
| TC_SO_002 | Verify Live Order Grid Loads After Login | smoke, regression, positive, sim_order |
| TC_SO_003 | Verify Create SIM Order Wizard Elements Visible | smoke, regression, positive, sim_order |
| TC_SO_004 | Verify Wizard Previous Button Navigates Back | regression, positive, sim_order, navigation |
| TC_SO_005 | Verify Preview Page Shows Order And Shipping Summary | regression, positive, sim_order |
| TC_SO_006 | Verify Close Button On Preview Redirects To Live Order | regression, positive, sim_order, navigation |
| TC_SO_007 | Verify Search Functionality On Live Order Grid | regression, positive, sim_order |
| TC_SO_008 | Cancel Order With Valid Reason And Remarks | regression, positive, sim_order, cancel |
| TC_SO_009 | Close Cancel Modal Without Proceeding | regression, positive, sim_order, cancel |
| TC_SO_010 | Next Blocked When Account Not Selected | regression, negative, sim_order |
| TC_SO_011 | Next Blocked When SIM Type Not Selected | regression, negative, sim_order |
| TC_SO_012 | Quantity Zero Should Show Error Or Block Next | regression, negative, sim_order, boundary |
| TC_SO_013 | Quantity Negative Should Show Error Or Block Next | regression, negative, sim_order, boundary |
| TC_SO_014 | Quantity Non Numeric Should Show Error Or Block Next | regression, negative, sim_order, boundary |
| TC_SO_015 | Next Blocked On Step 2 When Address Line 1 Empty | regression, negative, sim_order |
| TC_SO_016 | Submit Without Accepting Terms Should Be Blocked | regression, negative, sim_order |
| TC_SO_017 | SQL Injection In Quantity Field | regression, negative, security, sim_order |
| TC_SO_018 | Special Characters In Address Fields | regression, negative, security, sim_order |
| TC_SO_019 | Cancel Order With Empty Reason Should Be Blocked | regression, negative, sim_order, cancel |
| TC_SO_020 | Direct Access To Create SIM Order Without Login Should Redirect | regression, negative, security, sim_order, navigation |
| TC_SO_021 | Direct Access To Live Order Without Login Should Redirect | regression, negative, security, sim_order, navigation |

---

## 6. Robot Framework Settings and Variables

### 6.1 Settings (from `tests/sim_order_tests.robot`)

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/sim_order_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/sim_order_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/sim_order_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser
```

### 6.2 Locators (from `resources/locators/sim_order_locators.resource`)

Locators use the `LOC_SO_*` prefix. Key locators:

| Locator | Description |
|---|---|
| `${LOC_SO_GRID}` | Live Order Kendo grid container |
| `${LOC_SO_GRID_ROWS}` | Grid data rows |
| `${LOC_SO_CREATE_ORDER_BTN}` | Create SIM Order button |
| `${LOC_SO_WIZARD_CONTAINER}` | Wizard section (`#process-tab`) |
| `${LOC_SO_STEP1_PANE}` / `${LOC_SO_STEP2_PANE}` / `${LOC_SO_STEP3_PANE}` | Order Details, Shipping, Preview panes |
| `${LOC_SO_ACCOUNT_INPUT}` | Account TreeView input |
| `${LOC_SO_SIM_CATEGORY_BTN}` | SIM Category dropdown trigger |
| `${LOC_SO_SIM_TYPE_SELECT}` | SIM Type native select |
| `${LOC_SO_SIM_PRODUCT_BTN}` | Product Catalog dropdown |
| `${LOC_SO_QUANTITY_INPUT}` | Quantity input |
| `${LOC_SO_SIM_STATE_BTN}` | SIM State dropdown |
| `${LOC_SO_BTN_STEP1_NEXT}` | Next → Shipping button |
| `${LOC_SO_ADDRESS_LINE1}` | Address Line 1 |
| `${LOC_SO_AREA_INPUT}` | Area/State input |
| `${LOC_SO_CITY_INPUT}` | City input |
| `${LOC_SO_POSTAL_CODE_INPUT}` | Postal code input |
| `${LOC_SO_COUNTRY_BTN}` | Country dropdown |
| `${LOC_SO_BTN_STEP2_NEXT}` | Next → Preview button |
| `${LOC_SO_BTN_STEP2_PREV}` | Previous → Order Details button |
| `${LOC_SO_TC_CHECKBOX}` | Terms & Conditions checkbox |
| `${LOC_SO_BTN_SUBMIT}` | Submit button |
| `${LOC_SO_BTN_CLOSE}` | Close button |
| `${LOC_SO_TC_MODAL}` | T&C modal popup |
| `${LOC_SO_TC_MODAL_CONTINUE}` | T&C modal Continue button |
| `${LOC_SO_TOAST_SUCCESS}` / `${LOC_SO_TOAST_ERROR}` | Success/error toasts |
| `${LOC_SO_CANCEL_MODAL}` | Cancel Order modal |
| `${LOC_SO_CANCEL_REASON_INPUT}` | Cancel reason input |
| `${LOC_SO_CANCEL_REMARKS_TEXTAREA}` | Cancel remarks textarea |
| `${LOC_SO_CANCEL_PROCEED_BTN}` | Cancel modal Proceed button |
| `${LOC_SO_SEARCH_INPUT}` / `${LOC_SO_SEARCH_BTN}` | Search input and button |

### 6.3 Variables (from `variables/sim_order_variables.py` and `config/env_config.py`)

Environment variables (`BASE_URL`, `VALID_USERNAME`, `VALID_PASSWORD`, `BROWSER`) come from `env_config.py`. SIM Order–specific variables are in `sim_order_variables.py` (see Section 5).

### 6.4 Keywords (from `resources/keywords/sim_order_keywords.resource`)

| Keyword | Description |
|---|---|
| `Login And Navigate To Live Order` | Login, verify, navigate to Live Order |
| `Login And Navigate To Create SIM Order` | Login, navigate to Live Order, open Create SIM Order wizard |
| `Set SIM Replacement Order` | Set SIM Replacement radio (Yes/No) |
| `Select Account From TreeView` | Select account in Kendo TreeView |
| `Select SIM Category` | Select first SIM Category from dropdown |
| `Select SIM Type` | Select SIM Type from native select |
| `Select SIM Product Type` | Select first SIM Product Type |
| `Enter Quantity` | Enter quantity (default: `${VALID_QUANTITY}`) |
| `Set Activation Type` | Set Auto/Manual activation |
| `Select SIM State` | Select SIM State from dropdown |
| `Fill Order Details Step 1` | Fill all Step 1 mandatory fields |
| `Click Next To Shipping` | Advance to Step 2 |
| `Fill Address Fields` | Fill address section on Step 2 |
| `Select Country` | Select country from dropdown |
| `Fill Contact Details` | Fill billing/contact fields |
| `Fill Shipping Details Step 2` | Fill all Step 2 fields |
| `Click Next To Preview` | Advance to Step 3 |
| `Click Previous To Order Details` | Go back from Step 2 to Step 1 |
| `Accept Terms And Submit Order` | Check T&C, submit, handle modal |
| `Click Submit Without TC` | Click Submit without accepting T&C |
| `Click Close Button On Preview` | Close wizard, return to Live Order |
| `Complete Create SIM Order Flow` | Full flow: Step 1 → Step 2 → Preview → Submit |
| `Verify Order Created Successfully` | Verify success toast / redirect |
| `Verify Preview Page Visible` | Assert Preview pane and summaries visible |
| `Verify Wizard Elements Visible` | Assert wizard tabs and Step 1 pane visible |
| `Verify On Live Order Page` | Assert URL contains LiveOrder, grid visible |
| `Grid Has At Least One Row` | Returns True/False if grid has data |
| `Open Cancel Modal For First Row` | Open Cancel modal for first grid row |
| `Fill Cancel Modal And Submit` | Fill reason/remarks, click Proceed |
| `Close Cancel Modal` | Close Cancel modal without proceeding |
| `Search Live Orders` | Enter search text, click search |
| `Verify Next Button Blocked Or Error Shown` | Assert Next blocked or error visible |
| `Verify Negative SIM Order Outcome` | Check for error/success after invalid submit |
| `Verify Cancel Order Outcome` | Check outcome after cancel |
| `Verify Cancel Blocked With Empty Reason` | Assert cancel blocked with empty reason |

Helper keywords from `browser_keywords.resource`: `Open Browser And Navigate`, `Capture Screenshot And Close Browser`, `Wait For Page Load`, `Wait For Loading Overlay To Disappear`, `Click Element Via JS`, `Clear And Input Text Into Field`, `Scroll To Element Via JS`.

From `login_keywords.resource`: `Login With Credentials`, `Verify Login Success`, `Verify Redirected To Login Page`.

---

## 7. Automation Flow

### Step 1 — Start from Manage Devices Page

Handled by `Test Setup` — `Login To Application` and `Navigate To Manage Devices` keywords run before each test (defined in `common_keywords.robot`, shared with TC_001 / TC_002).

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 1.1 | `Wait Until Element Is Visible    ${LOC_GRID}    ${TIMEOUT}` | Confirm Manage Devices grid is loaded |
| 1.2 | `Location Should Contain    ManageDevices` | Assert correct starting page |

---

### Step 2 — Navigate to Orders Module via Left Navigation Panel

```robot
Navigate To Orders Module
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 2.1 | `Wait Until Element Is Visible    ${LOC_NAV_PANEL}    ${TIMEOUT}` | Wait for left-side navigation to render |
| 2.2 | `Scroll Element Into View    ${LOC_ORDERS_MODULE}` | Scroll the nav panel until Orders module is visible |
| 2.3 | `Wait Until Element Is Visible    ${LOC_ORDERS_MODULE}    ${TIMEOUT}` | Assert Orders module link/item is visible |
| 2.4 | `Click Element    ${LOC_ORDERS_MODULE}` | Click the Orders module |
| 2.5 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    LiveOrder` | Wait for URL to contain `/LiveOrder` |
| 2.6 | `Wait Until Element Is Visible    ${LOC_LIVE_ORDER_HDR}    ${TIMEOUT}` | Verify Live Order page header is visible |

---

### Step 3 — Click "Create SIM Order" Button

```robot
Open Create SIM Order Wizard
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 3.1 | `Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}    ${TIMEOUT}` | Locate Create SIM Order button (top-right) |
| 3.2 | `Click Element    ${LOC_CREATE_ORDER_BTN}` | Click to open the wizard |
| 3.3 | `Wait Until Element Is Visible    ${LOC_TAB_LIVE_ORDER}    ${TIMEOUT}` | Verify "Live Order" tab is visible |
| 3.4 | `Element Should Be Visible    ${LOC_TAB_BLANK_ORDER}` | Verify "Blank Order" tab is also visible |

---

### Step 4 — Select "Live Order" Tab

```robot
Select Live Order Tab
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 4.1 | `Click Element    ${LOC_TAB_LIVE_ORDER}` | Click the Live Order tab |
| 4.2 | `Wait Until Element Is Visible    ${LOC_CUSTOMER_NAME}    ${TIMEOUT}` | Wait for the form to render |

---

### Step 5 — Fill Live Order Form — Page 1

```robot
Fill Live Order Form Page 1    ${CUSTOMER_NAME}    ${ACCOUNT_ID}    ${SIM_QUANTITY}    ${COUNTRY}    ${ACTIVATION_DATE}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 5.1 | `Input Text    ${LOC_CUSTOMER_NAME}    ${CUSTOMER_NAME}` | Enter Customer Name |
| 5.2 | `Input Text    ${LOC_ACCOUNT_ID}    ${ACCOUNT_ID}` | Enter Account ID |
| 5.3 | `Input Text    ${LOC_SIM_QUANTITY}    ${SIM_QUANTITY}` | Enter SIM Quantity |
| 5.4 | `Select From List By Label    ${LOC_COUNTRY}    ${COUNTRY}` | Select Country from dropdown |
| 5.5 | `Input Text    ${LOC_ACTIVATION_DATE}    ${ACTIVATION_DATE}` | Enter Activation Date |
| 5.6 | `Select Checkbox    ${LOC_MANUAL_ACT_CB}` | Check the Manual Activation checkbox |
| 5.7 | `Checkbox Should Be Selected    ${LOC_MANUAL_ACT_CB}` | Assert checkbox is checked |

---

### Step 6 — Click "Next" to Proceed to Page 2

```robot
Click Next Button
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 6.1 | `Click Element    ${LOC_NEXT_BTN}` | Click Next |
| 6.2 | `Wait Until Element Is Visible    ${LOC_DEVICE_PLAN}    ${TIMEOUT}` | Wait for Page 2 to render |

---

### Step 7 — Fill Live Order Form — Page 2

```robot
Fill Live Order Form Page 2    ${DEVICE_PLAN}    ${ADDRESS_LINE1}    ${CITY}    ${STATE}    ${POSTAL_CODE}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 7.1 | `Select From List By Index    ${LOC_DEVICE_PLAN}    1` | Select first available Device Plan |
| 7.2 | `Input Text    ${LOC_ADDRESS_LINE1}    ${ADDRESS_LINE1}` | Enter Address Line 1 |
| 7.3 | `Input Text    ${LOC_CITY}    ${CITY}` | Enter City |
| 7.4 | `Input Text    ${LOC_STATE}    ${STATE}` | Enter State / Region |
| 7.5 | `Input Text    ${LOC_POSTAL_CODE}    ${POSTAL_CODE}` | Enter Postal Code |

---

### Step 8 — Click "Next" to Proceed to Preview Page

```robot
Click Next Button
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 8.1 | `Click Element    ${LOC_NEXT_BTN}` | Click Next |
| 8.2 | `Wait Until Element Is Visible    ${LOC_PREVIEW_SECTION}    ${TIMEOUT}` | Wait for Preview page to render |

---

### Step 9 — Validate Preview Page

```robot
Validate Order Preview Page
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 9.1 | `Element Should Be Visible    ${LOC_PREVIEW_SECTION}` | Assert preview section is rendered |
| 9.2 | `Page Should Contain    ${CUSTOMER_NAME}` | Assert Customer Name is shown in summary |
| 9.3 | `Page Should Contain    ${SIM_QUANTITY}` | Assert SIM Quantity is shown in summary |
| 9.4 | `Page Should Contain    Manual Activation` | Assert Activation Type is shown in summary |
| 9.5 | `Element Should Be Visible    ${LOC_SUBMIT_BTN}` | Assert Submit button is visible |

---

### Step 10 — Scroll to Submit Button and Submit Order

```robot
Submit SIM Order
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 10.1 | `Scroll Element Into View    ${LOC_SUBMIT_BTN}` | Scroll to bring Submit button into viewport |
| 10.2 | `Wait Until Element Is Enabled    ${LOC_SUBMIT_BTN}    ${TIMEOUT}` | Assert button is clickable |
| 10.3 | `Click Element    ${LOC_SUBMIT_BTN}` | Click Submit to confirm order |
| 10.4 | `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}    ${TIMEOUT}` | Wait for success notification |

---

### Step 11 — Validate Success, Capture Order ID, Verify Redirect

```robot
Validate SIM Order Submission
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 11.1 | `Element Should Be Visible    ${LOC_SUCCESS_TOAST}` | Assert success toast notification is displayed |
| 11.2 | `Page Should Contain    Order submitted successfully` | Assert success message text |
| 11.3 | `Wait Until Element Is Visible    ${LOC_ORDER_ID}    ${TIMEOUT}` | Wait for Order ID element to appear |
| 11.4 | `${ORDER_ID}=    Get Text    ${LOC_ORDER_ID}` | Capture the generated Order ID |
| 11.5 | `Log    Generated Order ID: ${ORDER_ID}    INFO` | Log Order ID for traceability |
| 11.6 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    LiveOrder` | Verify redirect back to Live Order page |
| 11.7 | `Wait Until Element Is Visible    ${LOC_ORDER_TABLE}    ${TIMEOUT}` | Verify order list table is visible |

---

### Automation Flow Diagram

```
Test Setup: Login + Navigate To Manage Devices
      │
      ▼
Wait Until Element Is Visible    ${LOC_GRID}
      │
      ▼
Scroll Element Into View    ${LOC_ORDERS_MODULE}
Click Element    ${LOC_ORDERS_MODULE}
      │
      ▼
Wait Until Element Is Visible    ${LOC_LIVE_ORDER_HDR}
Location Should Contain    LiveOrder
      │
      ▼
Click Element    ${LOC_CREATE_ORDER_BTN}
      │
      ▼
Element Should Be Visible    ${LOC_TAB_LIVE_ORDER}
Element Should Be Visible    ${LOC_TAB_BLANK_ORDER}
Click Element    ${LOC_TAB_LIVE_ORDER}
      │
      ▼
Fill Live Order Form Page 1 (Customer Name, Account ID, SIM Qty, Country, Date)
Select Checkbox    ${LOC_MANUAL_ACT_CB}
Click Element    ${LOC_NEXT_BTN}
      │
      ▼
Fill Live Order Form Page 2 (Device Plan, Address, City, State, Postal Code)
Click Element    ${LOC_NEXT_BTN}
      │
      ▼
Wait Until Element Is Visible    ${LOC_PREVIEW_SECTION}
Validate order summary fields visible
      │
      ▼
Scroll Element Into View    ${LOC_SUBMIT_BTN}
Click Element    ${LOC_SUBMIT_BTN}
      │
      ▼
Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}
      │
      ├──── Visible ────► Capture Order ID
      │                   Location Should Contain    LiveOrder
      │                   Wait Until Element Is Visible    ${LOC_ORDER_TABLE}
      │                   PASS
      │
      └──── Timeout ────► FAIL: Capture Page Screenshot    EMBED
```

---

## 8. Sample Test Cases (from `tests/sim_order_tests.robot`)

The full test file uses the Settings from Section 6.1. Below are representative test cases.

### TC_SO_001 — E2E Create SIM Order Successfully

```robot
TC_SO_001 E2E Create SIM Order Successfully
    [Documentation]    Full E2E: Login > Live Order > Create SIM Order > fill Step 1 >
    ...                fill Step 2 > Preview > T&C > Submit > verify success toast and redirect.
    [Tags]    smoke    regression    positive    sim_order
    Login And Navigate To Create SIM Order
    Complete Create SIM Order Flow
    Verify Order Created Successfully
```

### TC_SO_002 — Verify Live Order Grid Loads After Login

```robot
TC_SO_002 Verify Live Order Grid Loads After Login
    [Documentation]    Navigate to Live Order and verify the Kendo grid container is visible.
    [Tags]    smoke    regression    positive    sim_order
    Login And Navigate To Live Order
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${row_count}=    Get Element Count    ${LOC_SO_GRID_ROWS}
    Log    Live Order grid loaded. Row count: ${row_count}    console=yes
```

### TC_SO_010 — Next Blocked When Account Not Selected (Negative)

```robot
TC_SO_010 Next Blocked When Account Not Selected
    [Documentation]    Fill Step 1 but skip Account selection. Clicking Next should be blocked.
    [Tags]    regression    negative    sim_order
    Login And Navigate To Create SIM Order
    Set SIM Replacement Order    false
    Select SIM Category
    Select SIM Type
    Select SIM Product Type
    Enter Quantity
    Set Activation Type
    Select SIM State
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}
```

### TC_SO_020 — Direct Access Without Login (Security)

```robot
TC_SO_020 Direct Access To Create SIM Order Without Login Should Redirect
    [Documentation]    Navigate directly to /CreateSIMOrder without authenticating.
    [Tags]    regression    negative    security    sim_order    navigation
    Go To    ${CREATE_SIM_ORDER_URL}
    Wait For Page Load
    Verify Redirected To Login Page
```

---

## 9. UI Elements and Locator Strategy (Legacy Reference)

The project uses `resources/locators/sim_order_locators.resource` with `LOC_SO_*` variables (see Section 6.2). The following maps legacy names to current locators:

| Legacy / Generic | Current Locator Variable |
|---|---|
| Create SIM Order button | `${LOC_SO_CREATE_ORDER_BTN}` |
| Wizard section | `${LOC_SO_WIZARD_CONTAINER}` |
| Tab 1/2/3 panes | `${LOC_SO_STEP1_PANE}`, `${LOC_SO_STEP2_PANE}`, `${LOC_SO_STEP3_PANE}` |
| Order Details form | `${LOC_SO_ACCOUNT_INPUT}`, `${LOC_SO_QUANTITY_INPUT}`, etc. |
| Shipping form | `${LOC_SO_ADDRESS_LINE1}`, `${LOC_SO_COUNTRY_BTN}`, etc. |
| Preview / Submit | `${LOC_SO_BTN_SUBMIT}`, `${LOC_SO_TC_CHECKBOX}` |
| Success toast | `${LOC_SO_TOAST_SUCCESS}` |

The project uses `Login And Navigate To Live Order` and `Login And Navigate To Create SIM Order` (which navigate via direct URL) instead of sidebar navigation. See Section 6.4 for keyword details.

---

## 9. UI Elements and Locator Strategy

All locators are defined in `resources/locators/sim_order_locators.resource` with the `LOC_SO_*` prefix. The **RF Locator String** column shows the XPath/ID value; use the variable name in tests.

> **Important corrections from source inspection:**
> - There is **no** `customerName`, `accountId`, `activationDate`, or `manualActivation` field in the form.
> - The **Next** and **Submit** elements are `<a>` tags — not `<button>` elements.
> - SIM Quantity field `name` is `quantity` (not `simQuantity`).
> - Postal Code field `name` is `pinCode` (not `postalCode`).
> - Device Plan field `name` is `dataPlan` (not `devicePlan`).
> - Country is a custom `Dropdownlist` with `data-testid="countryname"` (on Shipping tab).

### 9.1 Navigation

| Element | Locator Variable | RF Locator String |
|---|---|---|
| Orders menu | `${LOC_SO_ORDERS_MENU}` | `xpath=//a[@id='orders']` |
| Create SIM Order button | `${LOC_SO_CREATE_ORDER_BTN}` | `xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Create SIM Order']` |

### 9.2 Wizard Tab Navigation

| Element | Locator Variable |
|---|---|
| Wizard wrapper section | `${LOC_SO_WIZARD_CONTAINER}` |
| Tab 1 — Order Details link | `${LOC_SO_STEP1_LINK}` |
| Tab 2 — Shipping Details link | `${LOC_SO_STEP2_LINK}` |
| Tab 3 — Preview link | `${LOC_SO_STEP3_LINK}` |
| Tab 1 pane (Order Details) | `${LOC_SO_STEP1_PANE}` |
| Tab 2 pane (Shipping) | `${LOC_SO_STEP2_PANE}` |
| Tab 3 pane (Preview) | `${LOC_SO_STEP3_PANE}` |

### 9.3 Order Details Form — Page 1 (Tab: `#discover`)

| Element | Locator Variable |
|---|---|
| SIM Replacement — No (radio) | `${LOC_SO_SIM_REPLACEMENT_NO}` |
| SIM Replacement — Yes (radio) | `${LOC_SO_SIM_REPLACEMENT_YES}` |
| Account input (TreeView) | `${LOC_SO_ACCOUNT_INPUT}` |
| SIM Category dropdown | `${LOC_SO_SIM_CATEGORY_BTN}` |
| SIM Type select | `${LOC_SO_SIM_TYPE_SELECT}` |
| Product Catalog dropdown | `${LOC_SO_SIM_PRODUCT_BTN}` |
| SIM Quantity input | `${LOC_SO_QUANTITY_INPUT}` |
| Order ID input | `${LOC_SO_ORDER_ID_INPUT}` |
| Delivery Date | `${LOC_SO_DELIVERY_DATE_INPUT}` |
| Auto Activation (radio) | `${LOC_SO_ACTIVATION_AUTO}` |
| Manual Activation (radio) | `${LOC_SO_ACTIVATION_MANUAL}` |
| SIM State dropdown | `${LOC_SO_SIM_STATE_BTN}` |
| Device Plan | `${LOC_SO_DEVICE_PLAN_SELECT}` |
| Next → Shipping button | `${LOC_SO_BTN_STEP1_NEXT}` |

### 9.4 Shipping Details Form — Page 2 (Tab: `#strategy`)

| Element | Locator Variable |
|---|---|
| Address Line 1 | `${LOC_SO_ADDRESS_LINE1}` |
| Address Line 2 | `${LOC_SO_ADDRESS_LINE2}` |
| Country dropdown | `${LOC_SO_COUNTRY_BTN}` |
| Area / State input | `${LOC_SO_AREA_INPUT}` |
| City input | `${LOC_SO_CITY_INPUT}` |
| Postal Code input | `${LOC_SO_POSTAL_CODE_INPUT}` |
| Billing Contact Name | `${LOC_SO_BILLING_NAME_INPUT}` |
| Email Address | `${LOC_SO_EMAIL_INPUT}` |
| Primary Phone | `${LOC_SO_PRIMARY_PHONE_INPUT}` |
| Secondary Phone | `${LOC_SO_SECONDARY_PHONE_INPUT}` |
| Previous → Order Details | `${LOC_SO_BTN_STEP2_PREV}` |
| Next → Preview | `${LOC_SO_BTN_STEP2_NEXT}` |

### 9.5 Preview Page — Page 3 (Tab: `#optimization`)

| Element | Locator Variable |
|---|---|
| Preview tab pane | `${LOC_SO_STEP3_PANE}` |
| Shipping details summary | `${LOC_SO_PREVIEW_SHIPPING}` |
| Order details summary | `${LOC_SO_PREVIEW_ORDER}` |
| T&C checkbox | `${LOC_SO_TC_CHECKBOX}` |
| Previous → Shipping | `${LOC_SO_BTN_STEP3_PREV}` |
| Submit button | `${LOC_SO_BTN_SUBMIT}` |
| Close button | `${LOC_SO_BTN_CLOSE}` |

### 9.6 Terms & Conditions Modal

| Element | Locator Variable |
|---|---|
| T&C modal | `${LOC_SO_TC_MODAL}` |
| T&C checkbox (in modal) | `xpath=//div[@id='termsConditionsPopup']//input[@id='termsAndConditions']` |
| Continue button | `${LOC_SO_TC_MODAL_CONTINUE}` |
| Cancel button | `${LOC_SO_TC_MODAL_CANCEL}` |

### 9.7 Post-Submission / Live Order Grid

| Element | Locator Variable |
|---|---|
| Success toast | `${LOC_SO_TOAST_SUCCESS}` |
| Error toast | `${LOC_SO_TOAST_ERROR}` |
| Alert danger | `${LOC_SO_ALERT_DANGER}` |
| Live Order grid | `${LOC_SO_GRID}` |
| Grid rows | `${LOC_SO_GRID_ROWS}` |

### 9.8 Cancel Order Modal

| Element | Locator Variable |
|---|---|
| Cancel modal | `${LOC_SO_CANCEL_MODAL}` |
| Cancel reason input | `${LOC_SO_CANCEL_REASON_INPUT}` |
| Cancel remarks textarea | `${LOC_SO_CANCEL_REMARKS_TEXTAREA}` |
| Proceed button | `${LOC_SO_CANCEL_PROCEED_BTN}` |
| Close button | `${LOC_SO_CANCEL_CLOSE_BTN}` |

---

## 10. Expected Results

| Step | RF Keyword / Locator | Expected Outcome |
|---|---|---|
| Login and navigate | `Login And Navigate To Create SIM Order` | Live Order page loaded, then Create SIM Order wizard opened |
| Live Order grid visible | `Wait Until Element Is Visible    ${LOC_SO_GRID}` | Kendo grid container visible |
| Wizard elements visible | `Verify Wizard Elements Visible` | Step 1/2/3 links and Step 1 pane visible |
| Step 1 filled | `Fill Order Details Step 1` | Account, SIM Category, Type, Product Type, Quantity, Activation, SIM State populated |
| Step 2 filled | `Fill Shipping Details Step 2` | Address, Country, Area, City, Postal Code, contact details populated |
| Preview visible | `Verify Preview Page Visible` | `${LOC_SO_STEP3_PANE}`, `${LOC_SO_PREVIEW_SHIPPING}`, `${LOC_SO_PREVIEW_ORDER}` visible |
| Submit clicked | `Accept Terms And Submit Order` | T&C accepted, Submit clicked, modal handled if shown |
| Success toast visible | `Wait Until Element Is Visible    ${LOC_SO_TOAST_SUCCESS}` | Toast notification displayed |
| Redirected to Live Order | `Location Should Contain    ${LIVE_ORDER_PATH}` | URL returns to `/LiveOrder` |
| Grid visible after submit | `Wait Until Element Is Visible    ${LOC_SO_GRID}` | Live Order grid rendered |

---

## 11. Negative Test Scenarios (mapped to actual test cases)

| Test ID | Scenario Description | Keyword / Assertion |
|---|---|---|
| TC_SO_010 | Account not selected | `Verify Next Button Blocked Or Error Shown` with `${LOC_SO_STEP1_PANE}`, `${LOC_SO_ADDRESS_LINE1}`, `${LOC_SO_BTN_STEP1_NEXT}` |
| TC_SO_011 | SIM Type not selected | Same as TC_SO_010 |
| TC_SO_012 | Quantity zero | `Fill Order Details Step 1    quantity=${QUANTITY_ZERO}` then `Verify Next Button Blocked Or Error Shown` |
| TC_SO_013 | Quantity negative | `Fill Order Details Step 1    quantity=${QUANTITY_NEGATIVE}` |
| TC_SO_014 | Quantity non-numeric | `Fill Order Details Step 1    quantity=${QUANTITY_NON_NUMERIC}` |
| TC_SO_015 | Address Line 1 empty on Step 2 | Fill Step 1, advance to Step 2, leave Address Line 1 empty, `Verify Next Button Blocked Or Error Shown` |
| TC_SO_016 | Submit without T&C | `Click Submit Without TC`, assert still on Preview or T&C modal shown |
| TC_SO_017 | SQL injection in quantity | `Fill Order Details Step 1    quantity=${SQL_INJECTION_QUANTITY}` |
| TC_SO_018 | Special characters in address | `Fill Shipping Details Step 2    addr1=${SPECIAL_CHARS_ADDRESS}    addr2=${SPECIAL_CHARS_ADDRESS}` |
| TC_SO_019 | Cancel with empty reason | `Verify Cancel Blocked With Empty Reason` |
| TC_SO_020 | Direct access to Create SIM Order without login | `Go To    ${CREATE_SIM_ORDER_URL}`, `Verify Redirected To Login Page` |
| TC_SO_021 | Direct access to Live Order without login | `Go To    ${LIVE_ORDER_URL}`, `Verify Redirected To Login Page` |

---

## 12. Validation Checks

After `Accept Terms And Submit Order` completes, the `Verify Order Created Successfully` keyword confirms:

1. **Success toast** — `${LOC_SO_TOAST_SUCCESS}` visible (or error toast `${LOC_SO_TOAST_ERROR}` logged)
2. **Redirect** — `Location Should Contain    ${LIVE_ORDER_PATH}` (retries 5×5s)
3. **Live Order grid** — `Wait Until Element Is Visible    ${LOC_SO_GRID}`

The keyword handles async processing: it waits for loading overlay, checks for success/error toasts, and verifies redirect to `/LiveOrder`.

---

## 13. Automation Considerations

### Explicit Waits Only
Never use `Sleep`. Use SeleniumLibrary wait keywords for all dynamic content:
```robot
Wait Until Element Is Visible      locator    ${TIMEOUT}
Wait Until Element Is Enabled      locator    ${TIMEOUT}
Wait Until Element Is Not Visible  locator    ${TIMEOUT}
Wait Until Page Contains           text       ${TIMEOUT}
```

### Scroll Before Clicking Submit
The Submit button is at the bottom of the Preview page. Always scroll it into view before interacting:
```robot
Scroll Element Into View    ${LOC_SUBMIT_BTN}
Wait Until Element Is Enabled    ${LOC_SUBMIT_BTN}    ${TIMEOUT}
Click Element    ${LOC_SUBMIT_BTN}
```

### Page Load Retry
Wrap page transition waits with `Wait Until Keyword Succeeds` to handle transient network delays:
```robot
Wait Until Keyword Succeeds    3x    5s
...    Location Should Contain    LiveOrder
```

### Multi-Page Wizard Navigation
The `Next` button locator (`xpath=//button[contains(text(),'Next')]`) is the same on both Page 1 and Page 2. After each click, wait for a unique element on the next page to confirm transition:
- After Page 1 Next → wait for `${LOC_DEVICE_PLAN}`
- After Page 2 Next → wait for `${LOC_PREVIEW_SECTION}`

### Capturing the Order ID
```robot
${ORDER_ID}=    Get Text    ${LOC_ORDER_ID}
Should Not Be Empty    ${ORDER_ID}
Log    Generated Order ID: ${ORDER_ID}    INFO
```
Store the Order ID in a suite-level variable (`Set Suite Variable    ${CREATED_ORDER_ID}    ${ORDER_ID}`) for use in downstream test cases (e.g., order cancellation or status verification tests).

### SSL Certificate Bypass
```robot
${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
Call Method    ${options}    add_argument    --ignore-certificate-errors
Open Browser    ${BASE_URL}    chrome    options=${options}
```

### Shared Login and Navigation
This test reuses the `Login To Application` and `Navigate To Manage Devices` keywords from `common_keywords.robot` (established in TC_001). Do not duplicate login logic in this test file.

### Screenshot on Failure
```robot
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot    EMBED
```
`EMBED` writes screenshots directly into `log.html` for immediate visibility.

### Session Cleanup
```robot
Test Setup    Run Keywords    Delete All Cookies    AND    ...
```
Clears cookies before each test run to prevent session bleed.

### Date Input Handling
Some date picker components do not accept `Input Text` directly. If the Activation Date field uses a custom date picker, use:
```robot
Press Keys    ${LOC_ACTIVATION_DATE}    ${ACTIVATION_DATE}
```
or interact via JavaScript execution if the React component intercepts direct input.

---

## 14. Framework Recommendation

This specification is written for **Robot Framework + SeleniumLibrary** to align with TC_001 and TC_002. The table below describes how the same test can be implemented in other frameworks if needed.

| Framework | Language | Approach | SSL Handling | Notes |
|---|---|---|---|---|
| **Robot Framework + SeleniumLibrary** | Python (keyword DSL) | `Select From List By Label`, `Click Element`, `Wait Until Element Is Visible` | `ChromeOptions` via `Evaluate` | **Recommended** — consistent with TC_001 / TC_002 |
| **Playwright (Python)** | Python | `page.locator()`, `page.select_option()`, `expect(locator).to_be_visible()` | `ignore_https_errors=True` in browser context | Best for modern React SPAs; built-in auto-wait |
| **Selenium (Python)** | Python | `WebDriverWait`, `Select` class, `find_element` | `ChromeOptions` with `--ignore-certificate-errors` | Widely adopted; requires explicit wait management |
| **Cypress** | JavaScript | `cy.get()`, `cy.select()`, `cy.contains()` | `chromeWebSecurity: false` in `cypress.config.js` | Front-end focused; best for same-origin apps |

---

## 15. Example Playwright Script

The following Python + Playwright script implements the same workflow as the Robot Framework test above. It is provided as a reference for teams using Playwright independently.

```python
import pytest
from playwright.sync_api import Page, expect

# ── Configuration ──────────────────────────────────────────────────────────────
BASE_URL      = "https://192.168.1.26:7874"
USERNAME      = "ksa_opco"
PASSWORD      = "Admin@123"

# ── Test data ──────────────────────────────────────────────────────────────────
SIM_QUANTITY    = "5"
COUNTRY         = "Saudi Arabia"
ADDRESS_LINE1   = "123 Test Street"
CITY            = "Riyadh"
STATE           = "Riyadh Region"
POSTAL_CODE     = "12345"
BILLING_NAME    = "Test Contact"
EMAIL           = "test@example.com"
PRIMARY_PHONE   = "1234567890"

# ── Confirmed Locators (from CreateSIMOrder.js source) ────────────────────────
# Page 1 — Order Details (#discover)
LOC_QUANTITY        = "input[name='quantity']"           # line 1751
LOC_NON_AUTO_ACT    = "input[name='activationOption'][value='nonAutoActivation']"  # line 1883
LOC_AUTO_ACT        = "input[name='activationOption'][value='autoActivation']"     # line 1866
LOC_DEVICE_PLAN     = "[data-testid='selectPlacnpdert']"  # line 1434 (name=dataPlan)
LOC_SIM_TYPE        = "[data-testid='simType']"           # line 1681
LOC_SIM_STATE       = "[data-testid='simState']"          # line 1925
LOC_SERVICE_PLAN    = "[data-testid='servicePlan']"       # line 1952
LOC_NEXT_P1         = "a[href='#strategy'].btn-custom-color"   # line 1969 — <a> tag!

# Page 2 — Shipping Details (#strategy)
LOC_ADDR1           = "input[name='addressLine1']"        # line 1999
LOC_ADDR2           = "input[name='addressLine2']"        # line 2015
LOC_COUNTRY         = "[data-testid='countryname']"       # line 2039
LOC_STATE_FIELD     = "input[name='state']"               # line 2053
LOC_CITY_FIELD      = "input[name='city']"                # line 2071
LOC_PIN_CODE        = "input[name='pinCode']"             # line 2089 — NOT postalCode!
LOC_BILLING_NAME    = "input[name='billingContactName']"  # line 2162
LOC_EMAIL           = "input[name='emailAddress']"        # line 2178
LOC_PRIMARY_PHONE   = "input[name='primaryPhone']"        # line 2194
LOC_NEXT_P2         = "a[href='#optimization'].btn-custom-color"  # line 2240 — <a> tag!

# Page 3 — Preview (#optimization)
LOC_PREVIEW         = "#optimization"                     # line 2257
LOC_PREVIEW_SHIP    = ".shippingdetailsdiv"               # line 2264
LOC_PREVIEW_ORDER   = ".shippingdetailsdivoderdtilas"     # line 2314
# IMPORTANT: Submit is an <a> tag — NOT a <button>
LOC_SUBMIT          = "a.btn-custom-color.cursor-pointer[href='javascript:void(0);']"  # line 2482

# Terms & Conditions popup (shown in some configurations)
LOC_TC_MODAL        = "#termsConditionsPopup"             # line 2432
LOC_TC_CHECKBOX     = "#termsAndConditions"               # line 2447
LOC_TC_PROCEED      = "#prceedBtnGeneralAPN"              # line 2455


@pytest.fixture(scope="session")
def browser_context_args(browser_context_args):
    """Bypass self-signed SSL certificate."""
    return {**browser_context_args, "ignore_https_errors": True}


def login(page: Page) -> None:
    """Login using confirmed Login.js locators."""
    page.goto(BASE_URL)
    page.locator("#root").wait_for(state="visible")
    page.locator("input[name='username']").fill(USERNAME)
    page.locator("input[name='password']").fill(PASSWORD)
    # Uncomment if CAPTCHA is active:
    # page.locator("input[name='captcha']").fill(CAPTCHA_VALUE)
    # Login button is <input type="button">, NOT <button> (Login.js line 874)
    page.locator("input.btn-custom-color[type='button']").click()
    page.locator("#gridData").wait_for(state="visible")
    expect(page.locator(".erre-it")).not_to_be_visible()


def test_create_sim_order(page: Page) -> None:
    # ── Step 1: Login and confirm Manage Devices starting point ────────────────
    login(page)
    page.locator("#gridData").wait_for(state="visible")

    # ── Step 2: Navigate to Orders module via left nav ─────────────────────────
    nav_panel = page.locator("//div[contains(@class,'sidebar')]")
    nav_panel.wait_for(state="visible")
    orders_link = page.locator("//div[contains(@class,'sidebar')]//span[contains(text(),'Orders')]")
    orders_link.scroll_into_view_if_needed()
    orders_link.click()
    expect(page).to_have_url(f"{BASE_URL}/LiveOrder")
    expect(page.locator("//h1[contains(text(),'Live Order')]")).to_be_visible()

    # ── Step 3: Open Create SIM Order wizard ───────────────────────────────────
    page.locator("//button[contains(text(),'Create SIM Order')]").click()
    # Confirm wizard section is present (id=process-tab, line 1503)
    page.locator("#process-tab").wait_for(state="visible")
    expect(page.locator("#orderDetails")).to_be_visible()
    expect(page.locator("#shippingDetails")).to_be_visible()
    expect(page.locator("#previewDetails")).to_be_visible()

    # ── Step 4: Click Order Details tab — navigate to Tab 1 pane (#discover) ──
    page.locator("#orderDetails").click()
    page.locator("#discover").wait_for(state="visible")

    # ── Step 5: Fill Order Details form (Page 1) ───────────────────────────────
    # Select Non-Auto Activation (radio — name=activationOption, line 1883)
    page.locator(LOC_NON_AUTO_ACT).check()
    expect(page.locator(LOC_NON_AUTO_ACT)).to_be_checked()

    # Enter SIM Quantity (name=quantity, line 1751)
    page.locator(LOC_QUANTITY).fill(SIM_QUANTITY)

    # Select SIM Type (data-testid=simType, line 1681)
    page.locator(LOC_SIM_TYPE).wait_for(state="visible")
    page.locator(LOC_SIM_TYPE).select_option(index=1)

    # Select Device Plan (data-testid=selectPlacnpdert / name=dataPlan, line 1434)
    page.locator(LOC_DEVICE_PLAN).wait_for(state="visible")
    page.locator(LOC_DEVICE_PLAN).select_option(index=1)

    # ── Step 6: Click Next → Shipping (line 1969 — <a href='#strategy'>) ───────
    next_btn_p1 = page.locator(LOC_NEXT_P1)
    next_btn_p1.scroll_into_view_if_needed()
    next_btn_p1.click()
    page.locator("#strategy").wait_for(state="visible")
    page.locator(LOC_ADDR1).wait_for(state="visible")

    # ── Step 7: Fill Shipping Details form (Page 2) ────────────────────────────
    # Country dropdown (data-testid=countryname / name=country, line 2039)
    page.locator(LOC_COUNTRY).wait_for(state="visible")
    page.locator(LOC_COUNTRY).select_option(label=COUNTRY)

    # Address fields
    page.locator(LOC_ADDR1).fill(ADDRESS_LINE1)
    page.locator(LOC_STATE_FIELD).fill(STATE)             # name=state, line 2053
    page.locator(LOC_CITY_FIELD).fill(CITY)               # name=city, line 2071
    page.locator(LOC_PIN_CODE).fill(POSTAL_CODE)          # name=pinCode, line 2089

    # Contact details
    page.locator(LOC_BILLING_NAME).fill(BILLING_NAME)
    page.locator(LOC_EMAIL).fill(EMAIL)
    page.locator(LOC_PRIMARY_PHONE).fill(PRIMARY_PHONE)

    # ── Step 8: Click Next → Preview (line 2240 — <a href='#optimization'>) ───
    next_btn_p2 = page.locator(LOC_NEXT_P2)
    next_btn_p2.scroll_into_view_if_needed()
    next_btn_p2.click()
    page.locator(LOC_PREVIEW).wait_for(state="visible")

    # ── Step 9: Validate Preview page ─────────────────────────────────────────
    expect(page.locator(LOC_PREVIEW)).to_be_visible()
    expect(page.locator(LOC_PREVIEW_SHIP)).to_be_visible()
    expect(page.locator(LOC_PREVIEW_ORDER)).to_be_visible()
    expect(page.get_by_text(SIM_QUANTITY)).to_be_visible()

    # ── Step 10: Scroll to Submit and submit order ─────────────────────────────
    # IMPORTANT: Submit is an <a> tag — NOT a <button> (line 2482)
    submit_btn = page.locator(LOC_SUBMIT)
    submit_btn.scroll_into_view_if_needed()
    expect(submit_btn).to_be_visible()
    submit_btn.click()

    # ── Handle Terms & Conditions popup if shown (line 2432) ──────────────────
    tc_modal = page.locator(LOC_TC_MODAL)
    if tc_modal.is_visible():
        page.locator(LOC_TC_CHECKBOX).check()
        expect(page.locator(LOC_TC_CHECKBOX)).to_be_checked()
        page.locator(LOC_TC_PROCEED).wait_for(state="enabled")
        page.locator(LOC_TC_PROCEED).click()

    # ── Step 11: Validate success, capture Order ID, verify redirect ───────────
    success_toast = page.locator("//div[contains(@class,'toast-success')]")
    expect(success_toast).to_be_visible()

    order_id_el = page.locator("//span[contains(@class,'order-id')]")
    order_id_el.wait_for(state="visible")
    order_id = order_id_el.text_content()
    assert order_id, "Order ID was not generated"
    print(f"Generated Order ID: {order_id}")

    expect(page).to_have_url(f"{BASE_URL}/LiveOrder")
    expect(page.locator("//table[contains(@class,'order-table')]")).to_be_visible()
```

> **Run command for Playwright:**
> ```bash
> pytest tests/test_create_sim_order.py --headed
> ```

---

## 16. Success Validation Checklist

- [ ] `Wait Until Element Is Visible    ${LOC_GRID}` passes — Manage Devices starting point confirmed
- [ ] `Scroll Element Into View    ${LOC_ORDERS_MODULE}` executes without error
- [ ] `Location Should Contain    LiveOrder` passes after Orders module click
- [ ] `Wait Until Element Is Visible    ${LOC_LIVE_ORDER_HDR}` passes
- [ ] `Element Should Be Visible    ${LOC_TAB_LIVE_ORDER}` passes
- [ ] `Element Should Be Visible    ${LOC_TAB_BLANK_ORDER}` passes
- [ ] `Input Text` × 4 on Page 1 execute without error
- [ ] `Select From List By Label    ${LOC_COUNTRY}` executes without error
- [ ] `Checkbox Should Be Selected    ${LOC_MANUAL_ACT_CB}` passes
- [ ] `Wait Until Element Is Visible    ${LOC_DEVICE_PLAN}` passes (Page 2 loaded)
- [ ] `Select From List By Index    ${LOC_DEVICE_PLAN}    1` executes without error
- [ ] `Input Text` × 4 on Page 2 execute without error
- [ ] `Wait Until Element Is Visible    ${LOC_PREVIEW_SECTION}` passes
- [ ] `Page Should Contain    ${CUSTOMER_NAME}` passes
- [ ] `Page Should Contain    Manual Activation` passes
- [ ] `Scroll Element Into View    ${LOC_SUBMIT_BTN}` executes without error
- [ ] `Wait Until Element Is Enabled    ${LOC_SUBMIT_BTN}` passes
- [ ] `Click Element    ${LOC_SUBMIT_BTN}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}` passes within `${TIMEOUT}`
- [ ] `Page Should Contain    Order submitted successfully` passes
- [ ] `Get Text    ${LOC_ORDER_ID}` returns a non-empty Order ID
- [ ] `Location Should Contain    LiveOrder` passes (redirect confirmed)
- [ ] `Wait Until Element Is Visible    ${LOC_ORDER_TABLE}` passes
- [ ] No `FAIL` entries in `output.xml`
- [ ] `log.html` and `report.html` generated in `results/` directory

---

## 17. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-05 | CMP QA Team | Initial Robot Framework specification for TC_003 Create SIM Order; aligned to TC_001 and TC_002 in structure, credential format, keyword style, variable naming, locator strategy, and retry/screenshot patterns; includes complete `.robot` file, Playwright reference script, and full negative / validation coverage |
| 1.1 | 2026-03-05 | CMP QA Team | All locators confirmed against `CreateSIMOrder.js` source. Key corrections: (1) `simQuantity` → `name=quantity`; (2) `postalCode` → `name=pinCode`; (3) `devicePlan` → `data-testid=selectPlacnpdert` / `name=dataPlan`; (4) `country` → `data-testid=countryname`; (5) Next/Submit elements are `<a>` tags (not `<button>`); (6) removed non-existent `customerName`, `accountId`, `activationDate`, `manualActivation` fields; (7) activation type is radio `name=activationOption`; (8) added T&C popup handling (`id=termsConditionsPopup`); (9) added wizard tab nav locators (`id=process-tab`, `id=orderDetails`, etc.); (10) updated Sections 6, 8, 9, and 15 accordingly |
| 1.2 | 2026-03-10 | CMP QA Team | Aligned document to actual project structure at `d:\stc-automation\`: (1) Project structure updated to match `config/`, `variables/`, `resources/locators/`, `resources/keywords/`, `tests/`, `run_tests.py`, `tasks.csv`; (2) Run commands use `run_tests.py`; (3) Settings, locators, variables, keywords reflect `sim_order_tests.robot`, `sim_order_locators.resource`, `sim_order_variables.py`, `sim_order_keywords.resource`; (4) Test case list TC_SO_001–TC_SO_021 with actual IDs, names, tags; (5) All locator references use `LOC_SO_*` variables |
