# Automation Test Specification – Create CSR Journey

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 13)*
**Date:** 2026-03-06
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md · TC_003_Create_SIM_Order_RF.md · TC_004_Create_SIM_Range_RF.md

---

## 1. Objective

This test validates the end-to-end **Create CSR Journey** workflow on the CMP web application. The automation begins from the **Manage Devices** page (post-login) and covers:

1. Navigating to the **CSR Journey** module via the left-side navigation panel under the **Admin** tab
2. Selecting a **Customer** and a **Business Unit** from the CSR Journey landing page
3. Clicking the **Create Order** button to initiate a new CSR Journey
4. Completing **Standard Services** — selecting a Tariff Plan, APN Type, adding APNs, and fetching Device Plans
5. Proceeding to **Additional Services** and navigating through the wizard
6. Reviewing the **Summary** screen and submitting via **Save and Exit**
7. Verifying the **success notification** and redirect back to the CSR Journey landing page

This test ensures the full Create CSR Journey wizard is functional across all three screens (Standard Services → Additional Services → Summary), all mandatory fields are validated, and the system correctly stores and acknowledges the submitted journey.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **CSR Journey Landing URL** | `https://192.168.1.26:7874/CSRJourney` |
| **Create CSR Journey URL** | `https://192.168.1.26:7874/CreateCSRJourney?id=<enc>&account=<enc>&customer=<enc>&apnType=<enc>` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |
| **CSR Journey Location in UI** | **Admin module → CSR Journey** (left-side navigation; CSR Journey is a sub-item under the Admin accordion/menu group) |

> **Note:** The Create CSR Journey URL contains **encrypted query parameters** (`id`, `account`, `customer`, `apnType`). The application navigates to this URL automatically when the **Create Order** button is clicked from the CSR Journey landing page — the automation does not need to construct the URL manually.

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` and has landed on the **Manage Devices** page
  - *(Use `Login To Application` and `Navigate To Manage Devices` keywords from `TC_001_Login_Navigate_RF.md`)*
- The `ksa_opco` user has **RW (Read-Write)** permission to access the **CSR Journey** module
- The **CSR Journey** module is enabled and visible in the left-side navigation panel under the Admin accordion
- At least one valid **Customer** exists in the system
- At least one valid **Business Unit** exists under the selected customer
- At least one valid **Tariff Plan** is available for selection
- At least one **APN** is available for the selected Tariff Plan and APN Type combination
- The selected Customer / Business Unit / Tariff Plan / APN Type combination does **not** already have an existing CSR Journey (to test create flow, not update)
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

```bash
robot --outputdir reports tests/csr_journey_tests.robot
```

### 4.3 Project Structure (aligned to TC_001 / TC_002 / TC_003 / TC_004)

```
cmp-automation/
├── resources/
│   ├── common_keywords.robot        # Open/Close browser, Login, Navigate keywords
│   ├── csr_journey_keywords.robot   # CSR Journey-specific keywords
│   └── variables.robot              # All locator and data variables
├── tests/
│   ├── TC_001_Login_Navigate.robot
│   ├── TC_002_State_Change.robot
│   ├── TC_003_Create_SIM_Order.robot
│   ├── TC_004_Create_SIM_Range.robot
│   └── TC_005_Create_CSR_Journey.robot
└── results/
    └── (output.xml, log.html, report.html)
```

---

## 5. Test Data

| Field | Sample Value | Notes |
|---|---|---|
| **Username** | `ksa_opco` | Same credentials as TC_001 / TC_002 / TC_003 / TC_004 |
| **Password** | `Admin@123` | Same credentials as TC_001 / TC_002 / TC_003 / TC_004 |
| **Customer** | *(First available)* | Parameterise via variable file; excludes `stc_opco_static` |
| **Business Unit** | *(First available under Customer)* | Dynamically populated after Customer is selected |
| **Tariff Plan** | *(First available)* | Fetched from STC Tariff Plan API on page load |
| **APN Type** | `private` | Options: `private`, `public`, `any` |
| **APN** | *(First available)* | Multi-select (react-select); at least one APN must be selected |
| **Expected Post-Submit URL** | `/CSRJourney` | Redirected back to the CSR Journey landing page after Save and Exit |

> Parameterise all test data values via a Robot Framework variable file (`variables.robot` or `--variablefile`) to support multiple environments without modifying test files.
>
> **Important:** The Create CSR Journey page is reached via the **Create Order** button on the CSR Journey landing page — which passes encrypted account/customer/APN params in the URL automatically. Do **not** navigate to `/CreateCSRJourney` directly in automation.

---

## 6. Robot Framework Settings and Variables

```robot
*** Settings ***
Library           SeleniumLibrary    timeout=30s    implicit_wait=0s
Resource          resources/common_keywords.robot
Suite Setup       Open CMP Browser
Suite Teardown    Close Browser
Test Setup        Run Keywords
...               Delete All Cookies    AND
...               Login To Application    ${USERNAME}    ${PASSWORD}    AND
...               Navigate To Manage Devices
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
# Application
${BASE_URL}               https://192.168.1.26:7874
${MANAGE_URL}             https://192.168.1.26:7874/ManageDevices
${CSR_JOURNEY_URL}        https://192.168.1.26:7874/CSRJourney
${BROWSER}                chrome
${TIMEOUT}                30s
${RETRY_COUNT}            3x
${RETRY_INTERVAL}         5s

# Credentials (shared with TC_001 / TC_002 / TC_003 / TC_004)
${USERNAME}               ksa_opco
${PASSWORD}               Admin@123

# ── Shared / Login Locators ───────────────────────────────────────────────────
${LOC_ROOT}               xpath=//div[@id='root']
${LOC_GRID}               id=gridData
${LOC_ERROR_MSG}          xpath=//div[contains(@class,'erre-it')]
${LOC_USERNAME}           name=username
${LOC_PASSWORD}           name=password
${LOC_LOGIN_BTN}          xpath=//input[@type='button' and contains(@class,'btn-custom-color')]

# ── Navigation Locators ───────────────────────────────────────────────────────
# CSR Journey is a sub-item inside the Admin module (accordion group in left nav)
${LOC_NAV_PANEL}          xpath=//div[contains(@class,'sidebar') or contains(@class,'left-nav')]
${LOC_ADMIN_TOGGLE}       xpath=//span[contains(text(),'Admin')]/parent::a
${LOC_CSR_JOURNEY_NAV}    xpath=//ul[contains(@class,'nav-second-level') or contains(@class,'sub-menu')]//a[contains(@href,'CSRJourney') and not(contains(@href,'Create')) and not(contains(@href,'WholeSale'))]

# ── CSR Journey Landing Page ─────────────────────────────────────────────────
# NOTE: Confirmed from CSRJourney.js source
${LOC_CUSTOMER_DD}        xpath=//select[@name='customerId']
${LOC_BUSINESS_UNIT_DD}   xpath=//select[@name='bussinessUnit']
${LOC_CREATE_ORDER_BTN}   xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Create Order')]
${LOC_CSR_TABLE}          xpath=//div[contains(@class,'csrjourneydev')]//table
${LOC_TXN_GRID}           id=CSRJourneyTransaction
${LOC_JOURNEY_POPUP}      id=journeyPopup

# ── Create CSR Journey — Wizard Step Indicators ───────────────────────────────
# NOTE: Confirmed from CreateCSRJourney.js — wizard uses text/image-based step indicators
${LOC_STEP_STANDARD}      xpath=//p[contains(.,'Standard Services')]
${LOC_STEP_ADDITIONAL}    xpath=//p[contains(.,'Additional Services')]
${LOC_STEP_SUMMARY}       xpath=//p[contains(.,'Summary') or contains(.,'Order Summary')]

# ── Standard Services Screen ──────────────────────────────────────────────────
# NOTE: Confirmed from StandardServices/index.js
${LOC_TARIFF_PLAN_DD}     xpath=//select[@name='tariffplan']
${LOC_APN_TYPE_DD}        xpath=//select[@name='apnCategory']
${LOC_ADD_APN_BTN}        xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Add') and contains(.,'APN')]
${LOC_FETCH_DP_BTN}       xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Fetch') and contains(.,'Device')]
# APN multi-select is a react-select component
${LOC_APN_MULTISELECT}    xpath=//div[contains(@class,'react-select') or contains(@class,'css-')]
# Account VAS Charges accordion
${LOC_ACC_VAS_TOGGLE}     xpath=//a[@href='#accountlevelvasCharges']
${LOC_ACC_VAS_PANEL}      id=accountlevelvasCharges
${LOC_ADD_ACC_VAS_BTN}    xpath=//button[contains(@class,'add_button') and ancestor::div[@id='accountlevelvasCharges']]
# Device VAS Charges accordion
${LOC_DEV_VAS_TOGGLE}     xpath=//a[@href='#devicelevelvasCharges']
${LOC_DEV_VAS_PANEL}      id=devicelevelvasCharges
${LOC_ADD_DEV_VAS_BTN}    xpath=//button[contains(@class,'add_button') and ancestor::div[@id='devicelevelvasCharges']]
# Navigation buttons — Standard Services screen
${LOC_STD_CLOSE_BTN}      xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]
${LOC_STD_NEXT_BTN}       xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Next')]

# ── Additional Services Screen ────────────────────────────────────────────────
# NOTE: Confirmed from AdditionalServices/index.js
# Navigation buttons — Additional Services screen
${LOC_ADD_CLOSE_BTN}      xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]
${LOC_ADD_PREV_BTN}       xpath=//button[contains(@class,'btn-custom-color-black') and contains(.,'Previous')]
${LOC_ADD_NEXT_BTN}       xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Next')]

# ── Summary Screen ────────────────────────────────────────────────────────────
# NOTE: Confirmed from SummaryServices/index.js
# Navigation buttons — Summary screen
${LOC_SUM_CLOSE_BTN}      xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]
${LOC_SUM_PREV_BTN}       xpath=//button[contains(@class,'btn-custom-color-black') and contains(.,'Previous')]
${LOC_SUM_SAVE_EXIT_BTN}  xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Save') and contains(.,'Exit')]
${LOC_SUM_SAVE_CONT_BTN}  xpath=//button[contains(@class,'btn-custom-color') and (contains(.,'Save') and contains(.,'Continue'))]

# ── CSR Overwrite Modal ───────────────────────────────────────────────────────
# NOTE: Confirmed from CreateCSRJourney.js line 1258
${LOC_OVERWRITE_MODAL}    id=csrOverWriteModal

# ── Post-Submission ───────────────────────────────────────────────────────────
${LOC_SUCCESS_TOAST}      xpath=//div[contains(@class,'toast-success')]
${LOC_ERROR_TOAST}        xpath=//div[contains(@class,'toast-error')]
```

> **Navigation note:** CSR Journey is a **sub-item under the Admin module** in the left sidebar. The Admin node is a collapsible accordion — it must be **expanded first** before the CSR Journey sub-item is clickable. This mirrors the same pattern used for SIM Range in TC_004.

---

## 7. Automation Flow

### Step 1 — Start from Manage Devices Page

Handled by `Test Setup` — `Login To Application` and `Navigate To Manage Devices` keywords run before each test (defined in `common_keywords.robot`, shared with TC_001 / TC_002 / TC_003 / TC_004).

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 1.1 | `Wait Until Element Is Visible    ${LOC_GRID}    ${TIMEOUT}` | Confirm Manage Devices grid is loaded |
| 1.2 | `Location Should Contain    ManageDevices` | Assert correct starting page |

---

### Step 2 — Navigate to CSR Journey Module via Admin Module in Left Navigation Panel

> **UI structure:** CSR Journey is a **sub-item under the Admin module** in the left sidebar. The Admin module is an accordion/collapse group — it must be expanded first before CSR Journey becomes clickable. This is the same expand-first pattern used for SIM Range in TC_004.

```robot
Navigate To CSR Journey Module
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 2.1 | `Wait Until Element Is Visible    ${LOC_NAV_PANEL}    ${TIMEOUT}` | Wait for left-side navigation to render |
| 2.2 | `Scroll Element Into View    ${LOC_ADMIN_TOGGLE}` | Scroll nav panel until the Admin module toggle link is visible |
| 2.3 | `Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}` | Assert Admin module link is visible in the sidebar |
| 2.4 | `Click Element    ${LOC_ADMIN_TOGGLE}` | Expand the Admin module accordion (reveals its sub-menu items) |
| 2.5 | `Wait Until Element Is Visible    ${LOC_CSR_JOURNEY_NAV}    ${TIMEOUT}` | Wait for CSR Journey sub-item to appear within the expanded Admin menu |
| 2.6 | `Click Element    ${LOC_CSR_JOURNEY_NAV}` | Click the CSR Journey sub-item under Admin |
| 2.7 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    CSRJourney` | Wait for URL to contain `/CSRJourney` |
| 2.8 | `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}` | Verify the CSR Journey landing page has rendered (Customer dropdown visible) |

---

### Step 3 — Select Customer from Dropdown

```robot
Select Customer From Dropdown
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 3.1 | `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}` | Assert Customer dropdown is present (`name=customerId`) |
| 3.2 | `Select From List By Index    ${LOC_CUSTOMER_DD}    1` | Select first available customer (index 1 skips blank option); this triggers Business Unit population |
| 3.3 | `Wait Until Element Is Visible    ${LOC_BUSINESS_UNIT_DD}    ${TIMEOUT}` | Wait for Business Unit dropdown to become populated |

> **Behaviour:** Selecting a Customer triggers `fetchBusinessUnitList()` via `componentDidUpdate`, which populates the Business Unit dropdown. Always wait for Business Unit to be populated before interacting with it.

---

### Step 4 — Select Business Unit from Dropdown

```robot
Select Business Unit From Dropdown
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 4.1 | `Wait Until Element Is Visible    ${LOC_BUSINESS_UNIT_DD}    ${TIMEOUT}` | Assert Business Unit dropdown is present and populated (`name=bussinessUnit`) |
| 4.2 | `Select From List By Index    ${LOC_BUSINESS_UNIT_DD}    1` | Select first available business unit (index 1 skips blank option); triggers `fetchCSR()` |
| 4.3 | `Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}    ${TIMEOUT}` | Wait for "Create Order" button to appear (visible only when `enableWritePlan` is `true`) |

> **Behaviour:** Selecting a Business Unit triggers `fetchCSR()` which checks whether the user has write permissions (`enableWritePlan`). The **Create Order** button only appears after `enableWritePlan` evaluates to `true`. If the button does not appear, the `ksa_opco` user may lack write permission for the selected BU.

---

### Step 5 — Click "Create Order" Button

```robot
Open Create CSR Journey
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 5.1 | `Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}    ${TIMEOUT}` | Assert Create Order button is visible |
| 5.2 | `Click Element    ${LOC_CREATE_ORDER_BTN}` | Click to navigate to the Create CSR Journey wizard |
| 5.3 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    CreateCSRJourney` | Wait for URL to contain `/CreateCSRJourney` |
| 5.4 | `Wait Until Element Is Visible    ${LOC_STEP_STANDARD}    ${TIMEOUT}` | Confirm Standard Services step indicator is visible — wizard has loaded |
| 5.5 | `Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}    ${TIMEOUT}` | Confirm Tariff Plan dropdown is rendered on Standard Services screen |

> **Note:** The Create Order button navigates to `/CreateCSRJourney?id=<enc>&account=<enc>&customer=<enc>` — the encrypted params are constructed automatically by the application. The automation does not need to set these manually.

---

### Step 6 — Select Tariff Plan (Standard Services Screen)

```robot
Select Tariff Plan
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 6.1 | `Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}    ${TIMEOUT}` | Assert Tariff Plan dropdown is present (`name=tariffplan`) |
| 6.2 | `Select From List By Index    ${LOC_TARIFF_PLAN_DD}    1` | Select first available tariff plan (index 1 skips blank/default option) |

> **Behaviour:** The Tariff Plan dropdown is **disabled** when in `editMode` (i.e., an existing CSR for this BU exists). In create mode, it is always enabled.

---

### Step 7 — Select APN Type (Standard Services Screen)

```robot
Select APN Type
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 7.1 | `Wait Until Element Is Visible    ${LOC_APN_TYPE_DD}    ${TIMEOUT}` | Assert APN Type dropdown is present (`name=apnCategory`) |
| 7.2 | `Wait Until Element Is Enabled    ${LOC_APN_TYPE_DD}    ${TIMEOUT}` | APN Type dropdown is **disabled** until a Tariff Plan is selected; wait for it to enable |
| 7.3 | `Select From List By Label    ${LOC_APN_TYPE_DD}    private` | Select `private` APN type (or `public` / `any` as required by test data) |
| 7.4 | `Wait Until Element Is Enabled    ${LOC_ADD_APN_BTN}    ${TIMEOUT}` | Wait for "Add APNs" button to become enabled after APN Type is selected |

> **Behaviour:** The APN Type dropdown is disabled (`disabled={!selectedTariffPlan?.id}`) until a valid Tariff Plan is selected. Always select Tariff Plan first, then APN Type.

---

### Step 8 — Add APNs (Standard Services Screen)

```robot
Add APNs
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 8.1 | `Wait Until Element Is Enabled    ${LOC_ADD_APN_BTN}    ${TIMEOUT}` | Assert Add APNs button is enabled (`disabled={!apnCategory or errors?.apnTypeExists}`) |
| 8.2 | `Click Element    ${LOC_ADD_APN_BTN}` | Open the APN selection panel/popup |
| 8.3 | `Wait Until Element Is Visible    ${LOC_APN_MULTISELECT}    ${TIMEOUT}` | Wait for the react-select APN multi-select control to appear |
| 8.4 | `Click Element    ${LOC_APN_MULTISELECT}` | Click to open the react-select dropdown |
| 8.5 | `Click Element    xpath=//div[contains(@class,'option') or contains(@class,'react-select__option')][1]` | Select the first available APN from the dropdown options |
| 8.6 | `Wait Until Element Is Not Visible    xpath=//div[contains(@class,'react-select__menu')]    ${TIMEOUT}` | Confirm dropdown closes after selection |

> **APN Multi-select Note:** The APN selector is a **react-select** component (`Select` from `react-select`). It does not render as a native `<select>` tag. Interact with it by clicking the container, then clicking an option within the `__menu` dropdown. Use `xpath=//div[contains(@class,'react-select__option')]` to target individual options. Always wait for at least one option to appear before clicking.

---

### Step 9 — Fetch Device Plans (Standard Services Screen)

```robot
Fetch Device Plans
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 9.1 | `Wait Until Element Is Visible    ${LOC_FETCH_DP_BTN}    ${TIMEOUT}` | Assert "Fetch Device Plan" button is present |
| 9.2 | `Wait Until Element Is Enabled    ${LOC_FETCH_DP_BTN}    ${TIMEOUT}` | Button is disabled when `isTariffAPNExists` is true; ensure no conflict exists |
| 9.3 | `Click Element    ${LOC_FETCH_DP_BTN}` | Click to fetch available device plans for the selected Tariff Plan and APN Type |
| 9.4 | `Wait Until Page Contains Element    xpath=//div[contains(@class,'devicePlan') or contains(@class,'device-plan')]    ${TIMEOUT}` | Wait for device plan section to be populated |

---

### Step 10 — Click "Next" to Proceed to Additional Services

```robot
Proceed To Additional Services
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 10.1 | `Scroll Element Into View    ${LOC_STD_NEXT_BTN}` | Scroll to bring the Next button into viewport |
| 10.2 | `Wait Until Element Is Visible    ${LOC_STD_NEXT_BTN}    ${TIMEOUT}` | Assert Next button is visible on Standard Services screen |
| 10.3 | `Click Element    ${LOC_STD_NEXT_BTN}` | Click "Next" to transition to Additional Services screen |
| 10.4 | `Wait Until Element Is Visible    ${LOC_STEP_ADDITIONAL}    ${TIMEOUT}` | Wait for Additional Services step indicator to become active |
| 10.5 | `Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}    ${TIMEOUT}` | Confirm Additional Services screen is fully rendered (Next button visible) |

> **Behaviour:** Clicking "Next" on Standard Services calls `changeCurrentScreen(Constants.ADDITIONAL)` — this is an in-page state change, not a page navigation. The URL does **not** change. Assert on visible UI elements (step indicator / buttons) rather than URL.

---

### Step 11 — Review Additional Services and Proceed to Summary

```robot
Proceed To Summary Screen
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 11.1 | `Wait Until Element Is Visible    ${LOC_STEP_ADDITIONAL}    ${TIMEOUT}` | Confirm we are on the Additional Services screen |
| 11.2 | `Scroll Element Into View    ${LOC_ADD_NEXT_BTN}` | Scroll to Next button |
| 11.3 | `Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}    ${TIMEOUT}` | Assert Next button is visible on Additional Services screen |
| 11.4 | `Click Element    ${LOC_ADD_NEXT_BTN}` | Click "Next" to transition to Summary screen |
| 11.5 | `Wait Until Element Is Visible    ${LOC_STEP_SUMMARY}    ${TIMEOUT}` | Wait for Summary step indicator to become active |
| 11.6 | `Wait Until Element Is Visible    ${LOC_SUM_SAVE_EXIT_BTN}    ${TIMEOUT}` | Confirm Summary screen is fully rendered |

> **Behaviour:** Like Standard → Additional, this is an in-page state transition (`changeCurrentScreen(Constants.SUMMARY)`). No URL change occurs.

---

### Step 12 — Submit via "Save and Exit" from Summary Screen

```robot
Save And Exit CSR Journey
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 12.1 | `Scroll Element Into View    ${LOC_SUM_SAVE_EXIT_BTN}` | Scroll to bring the Save and Exit button into viewport |
| 12.2 | `Wait Until Element Is Visible    ${LOC_SUM_SAVE_EXIT_BTN}    ${TIMEOUT}` | Assert "Save and Exit" button is visible on Summary screen |
| 12.3 | `Click Element    ${LOC_SUM_SAVE_EXIT_BTN}` | Click to save the CSR Journey and navigate back to `/CSRJourney` |
| 12.4 | `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}    ${TIMEOUT}` | Wait for success toast notification |

---

### Step 13 — Validate Success and Redirect

```robot
Validate CSR Journey Creation
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 13.1 | `Element Should Be Visible    ${LOC_SUCCESS_TOAST}` | Assert success toast is displayed |
| 13.2 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    CSRJourney` | Verify redirect back to `/CSRJourney` landing page |
| 13.3 | `Location Should Not Contain    CreateCSRJourney` | Assert we are no longer on the Create page |
| 13.4 | `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}` | Confirm CSR Journey landing page is rendered (Customer dropdown visible) |

---

### Automation Flow Diagram

```
Test Setup: Login + Navigate To Manage Devices
      │
      ▼
Wait Until Element Is Visible    ${LOC_GRID}
      │
      ▼
── Admin module (must expand first) ────────────────────────
Scroll Element Into View    ${LOC_ADMIN_TOGGLE}
Click Element    ${LOC_ADMIN_TOGGLE}          ← expand Admin accordion
Wait Until Element Is Visible    ${LOC_CSR_JOURNEY_NAV}
Click Element    ${LOC_CSR_JOURNEY_NAV}       ← CSR Journey sub-item under Admin
      │
      ▼
Location Should Contain    CSRJourney
Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}
      │
      ▼
Select From List By Index    ${LOC_CUSTOMER_DD}    1
Wait Until Element Is Visible    ${LOC_BUSINESS_UNIT_DD}
Select From List By Index    ${LOC_BUSINESS_UNIT_DD}    1
      │
      ▼
Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}
Click Element    ${LOC_CREATE_ORDER_BTN}
      │
      ▼
Location Should Contain    CreateCSRJourney
Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}
      │
      ▼
── Standard Services Screen ────────────────────────────────
Select From List By Index    ${LOC_TARIFF_PLAN_DD}    1
Wait Until Element Is Enabled    ${LOC_APN_TYPE_DD}
Select From List By Label    ${LOC_APN_TYPE_DD}    private
Click Element    ${LOC_ADD_APN_BTN}
[Select at least one APN from react-select]
Click Element    ${LOC_FETCH_DP_BTN}
[Wait for device plans to load]
Click Element    ${LOC_STD_NEXT_BTN}
      │
      ▼
── Additional Services Screen ──────────────────────────────
Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}
Click Element    ${LOC_ADD_NEXT_BTN}
      │
      ▼
── Summary Screen ──────────────────────────────────────────
Wait Until Element Is Visible    ${LOC_SUM_SAVE_EXIT_BTN}
Scroll Element Into View    ${LOC_SUM_SAVE_EXIT_BTN}
Click Element    ${LOC_SUM_SAVE_EXIT_BTN}
      │
      ▼
Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}
      │
      ├──── Visible ────► Location Should Contain    CSRJourney
      │                   Location Should Not Contain    CreateCSRJourney
      │                   Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}
      │                   PASS
      │
      └──── Timeout ────► FAIL: Capture Page Screenshot    EMBED
```

---

## 8. Complete Robot Framework Test File

```robot
*** Settings ***
Library           SeleniumLibrary    timeout=30s    implicit_wait=0s
Resource          resources/common_keywords.robot
Suite Setup       Open CMP Browser
Suite Teardown    Close Browser
Test Setup        Run Keywords
...               Delete All Cookies    AND
...               Login To Application    ${USERNAME}    ${PASSWORD}    AND
...               Navigate To Manage Devices
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
${BASE_URL}               https://192.168.1.26:7874
${MANAGE_URL}             https://192.168.1.26:7874/ManageDevices
${CSR_JOURNEY_URL}        https://192.168.1.26:7874/CSRJourney
${BROWSER}                chrome
${TIMEOUT}                30s
${RETRY_COUNT}            3x
${RETRY_INTERVAL}         5s
${USERNAME}               ksa_opco
${PASSWORD}               Admin@123

# ── Shared / Login ────────────────────────────────────────────────────────────
${LOC_ROOT}               xpath=//div[@id='root']
${LOC_GRID}               id=gridData
${LOC_ERROR_MSG}          xpath=//div[contains(@class,'erre-it')]
${LOC_USERNAME}           name=username
${LOC_PASSWORD}           name=password
${LOC_LOGIN_BTN}          xpath=//input[@type='button' and contains(@class,'btn-custom-color')]

# ── Navigation ────────────────────────────────────────────────────────────────
# CSR Journey is a sub-item inside the Admin module (accordion group in left nav)
${LOC_NAV_PANEL}          xpath=//div[contains(@class,'sidebar') or contains(@class,'left-nav')]
${LOC_ADMIN_TOGGLE}       xpath=//span[contains(text(),'Admin')]/parent::a
${LOC_CSR_JOURNEY_NAV}    xpath=//ul[contains(@class,'nav-second-level') or contains(@class,'sub-menu')]//a[contains(@href,'CSRJourney') and not(contains(@href,'Create')) and not(contains(@href,'WholeSale'))]

# ── CSR Journey Landing Page ──────────────────────────────────────────────────
${LOC_CUSTOMER_DD}        xpath=//select[@name='customerId']
${LOC_BUSINESS_UNIT_DD}   xpath=//select[@name='bussinessUnit']
${LOC_CREATE_ORDER_BTN}   xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Create Order')]
${LOC_CSR_TABLE}          xpath=//div[contains(@class,'csrjourneydev')]//table
${LOC_TXN_GRID}           id=CSRJourneyTransaction
${LOC_JOURNEY_POPUP}      id=journeyPopup

# ── Wizard Step Indicators ────────────────────────────────────────────────────
${LOC_STEP_STANDARD}      xpath=//p[contains(.,'Standard Services')]
${LOC_STEP_ADDITIONAL}    xpath=//p[contains(.,'Additional Services')]
${LOC_STEP_SUMMARY}       xpath=//p[contains(.,'Summary') or contains(.,'Order Summary')]

# ── Standard Services ─────────────────────────────────────────────────────────
${LOC_TARIFF_PLAN_DD}     xpath=//select[@name='tariffplan']
${LOC_APN_TYPE_DD}        xpath=//select[@name='apnCategory']
${LOC_ADD_APN_BTN}        xpath=//button[contains(@class,'btn-custom-color') and contains(.,'APN')]
${LOC_FETCH_DP_BTN}       xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Fetch')]
${LOC_APN_MULTISELECT}    xpath=//div[contains(@class,'react-select__control')]
${LOC_APN_OPTION_FIRST}   xpath=(//div[contains(@class,'react-select__option')])[1]
${LOC_APN_MENU}           xpath=//div[contains(@class,'react-select__menu')]
${LOC_ACC_VAS_TOGGLE}     xpath=//a[@href='#accountlevelvasCharges']
${LOC_ACC_VAS_PANEL}      id=accountlevelvasCharges
${LOC_DEV_VAS_TOGGLE}     xpath=//a[@href='#devicelevelvasCharges']
${LOC_DEV_VAS_PANEL}      id=devicelevelvasCharges
${LOC_STD_CLOSE_BTN}      xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]
${LOC_STD_NEXT_BTN}       xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Next')]

# ── Additional Services ───────────────────────────────────────────────────────
${LOC_ADD_CLOSE_BTN}      xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]
${LOC_ADD_PREV_BTN}       xpath=//button[contains(@class,'btn-custom-color-black') and contains(.,'Previous')]
${LOC_ADD_NEXT_BTN}       xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Next')]

# ── Summary Screen ────────────────────────────────────────────────────────────
${LOC_SUM_CLOSE_BTN}      xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]
${LOC_SUM_PREV_BTN}       xpath=//button[contains(@class,'btn-custom-color-black') and contains(.,'Previous')]
${LOC_SUM_SAVE_EXIT_BTN}  xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Save') and contains(.,'Exit')]
${LOC_SUM_SAVE_CONT_BTN}  xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Save') and contains(.,'Continue')]

# ── Post-Submission ───────────────────────────────────────────────────────────
${LOC_SUCCESS_TOAST}      xpath=//div[contains(@class,'toast-success')]
${LOC_ERROR_TOAST}        xpath=//div[contains(@class,'toast-error')]

*** Test Cases ***
TC_005 Create CSR Journey — Standard Services to Save and Exit
    [Documentation]    Validates end-to-end CSR Journey creation from Customer/BU selection through Standard Services, Additional Services, and Summary with Save and Exit
    [Tags]             csr-journey    create-csr-journey    regression
    Navigate To CSR Journey Module
    Select Customer From Dropdown
    Select Business Unit From Dropdown
    Open Create CSR Journey
    Select Tariff Plan
    Select APN Type    private
    Add APNs
    Fetch Device Plans
    Proceed To Additional Services
    Proceed To Summary Screen
    Save And Exit CSR Journey
    Validate CSR Journey Creation

*** Keywords ***
Navigate To CSR Journey Module
    [Documentation]    Expands Admin module in left nav, clicks CSR Journey sub-item, verifies CSR Journey landing page loads
    # CSR Journey is a sub-item under Admin — Admin accordion must be expanded first
    Wait Until Element Is Visible    ${LOC_NAV_PANEL}    ${TIMEOUT}
    Scroll Element Into View         ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}
    Click Element                    ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_CSR_JOURNEY_NAV}    ${TIMEOUT}
    Click Element                    ${LOC_CSR_JOURNEY_NAV}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    CSRJourney
    Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}

Select Customer From Dropdown
    [Documentation]    Selects the first available customer from the Customer dropdown (name=customerId)
    Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}
    Select From List By Index        ${LOC_CUSTOMER_DD}    1
    Wait Until Element Is Visible    ${LOC_BUSINESS_UNIT_DD}    ${TIMEOUT}

Select Business Unit From Dropdown
    [Documentation]    Selects the first available business unit (name=bussinessUnit); waits for Create Order button to appear
    Wait Until Element Is Visible    ${LOC_BUSINESS_UNIT_DD}    ${TIMEOUT}
    Select From List By Index        ${LOC_BUSINESS_UNIT_DD}    1
    Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}    ${TIMEOUT}

Open Create CSR Journey
    [Documentation]    Clicks the Create Order button and waits for the Create CSR Journey wizard to load
    Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_CREATE_ORDER_BTN}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    CreateCSRJourney
    Wait Until Element Is Visible    ${LOC_STEP_STANDARD}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}    ${TIMEOUT}

Select Tariff Plan
    [Documentation]    Selects the first available tariff plan from the Tariff Plan dropdown (name=tariffplan)
    Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}    ${TIMEOUT}
    Select From List By Index        ${LOC_TARIFF_PLAN_DD}    1

Select APN Type
    [Arguments]    ${apn_type}
    [Documentation]    Waits for APN Type dropdown to be enabled (requires Tariff Plan selected first), then selects the given APN type label
    Wait Until Element Is Visible    ${LOC_APN_TYPE_DD}    ${TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_APN_TYPE_DD}    ${TIMEOUT}
    Select From List By Label        ${LOC_APN_TYPE_DD}    ${apn_type}
    Wait Until Element Is Enabled    ${LOC_ADD_APN_BTN}    ${TIMEOUT}

Add APNs
    [Documentation]    Opens the APN react-select dropdown and selects the first available APN option
    Wait Until Element Is Enabled    ${LOC_ADD_APN_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_ADD_APN_BTN}
    Wait Until Element Is Visible    ${LOC_APN_MULTISELECT}    ${TIMEOUT}
    Click Element                    ${LOC_APN_MULTISELECT}
    Wait Until Element Is Visible    ${LOC_APN_MENU}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_APN_OPTION_FIRST}    ${TIMEOUT}
    Click Element                    ${LOC_APN_OPTION_FIRST}
    Wait Until Element Is Not Visible    ${LOC_APN_MENU}    ${TIMEOUT}

Fetch Device Plans
    [Documentation]    Clicks Fetch Device Plan button and waits for device plans to load
    Wait Until Element Is Visible    ${LOC_FETCH_DP_BTN}    ${TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_FETCH_DP_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_FETCH_DP_BTN}
    Sleep    2s    # Wait for async device plan fetch to complete

Proceed To Additional Services
    [Documentation]    Clicks Next on Standard Services to transition to Additional Services screen
    Scroll Element Into View         ${LOC_STD_NEXT_BTN}
    Wait Until Element Is Visible    ${LOC_STD_NEXT_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_STD_NEXT_BTN}
    Wait Until Element Is Visible    ${LOC_STEP_ADDITIONAL}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}    ${TIMEOUT}

Proceed To Summary Screen
    [Documentation]    Clicks Next on Additional Services to transition to Summary screen
    Scroll Element Into View         ${LOC_ADD_NEXT_BTN}
    Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_ADD_NEXT_BTN}
    Wait Until Element Is Visible    ${LOC_STEP_SUMMARY}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_SUM_SAVE_EXIT_BTN}    ${TIMEOUT}

Save And Exit CSR Journey
    [Documentation]    Clicks Save and Exit on Summary screen; waits for success toast
    Scroll Element Into View         ${LOC_SUM_SAVE_EXIT_BTN}
    Wait Until Element Is Visible    ${LOC_SUM_SAVE_EXIT_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_SUM_SAVE_EXIT_BTN}
    Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}    ${TIMEOUT}

Validate CSR Journey Creation
    [Documentation]    Confirms success notification, validates redirect back to CSR Journey landing page
    Element Should Be Visible        ${LOC_SUCCESS_TOAST}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    CSRJourney
    Location Should Not Contain      CreateCSRJourney
    Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}
    Element Should Be Visible        ${LOC_CUSTOMER_DD}
    Log    CSR Journey created and validated successfully    INFO
```

---

## 9. UI Elements and Locator Strategy

All locators have been **confirmed from the application source code** (`CSRJourney.js`, `CreateCSRJourney.js`, `StandardServices/index.js`, `AdditionalServices/index.js`, `SummaryServices/index.js`). The **RF Locator String** column shows the exact value to use inside Robot Framework keywords.

> **Key notes from source inspection:**
> - The **Customer** and **Business Unit** dropdowns use a custom `Dropdownlist` component with `name=customerId` and `name=bussinessUnit` respectively — they render as standard HTML `<select>` elements.
> - The **APN selector** is a **react-select** multi-select component — it does **not** render as a native `<select>` tag. Interact via `.react-select__control` and `.react-select__option`.
> - The **Create Order** button is only rendered when `enableWritePlan === true` — this is set by the API after the Business Unit is selected and the user has write permission.
> - The three wizard screens (Standard / Additional / Summary) are **in-page state changes** (`this.setState({ currentScreen })`) — the URL stays at `/CreateCSRJourney?...` throughout. Assert on visible elements, not URL changes.
> - The **Save and Exit** button (`onClickSaveAndExit`) navigates to `/CSRJourney` after calling `handleSave()`.
> - The **Save & Continue** button (`onClickSaveAndContinue`) saves and stays on `/CreateCSRJourney?...` (re-renders the wizard) — use Save and Exit for a clean end-to-end validation.
> - The **CSR Overwrite modal** (`id=csrOverWriteModal`) appears only in `editMode` — not expected in a fresh create flow.

### 9.1 Navigation

> **CSR Journey is accessed via Admin → CSR Journey in the left sidebar.** The Admin node is a collapsible accordion group. It must be clicked/expanded before the CSR Journey sub-item is interactive. This is identical to the SIM Range pattern in TC_004.

| Element | Description | RF Locator String | Source |
|---|---|---|---|
| Left nav panel | Sidebar navigation container | `xpath=//div[contains(@class,'sidebar') or contains(@class,'left-nav')]` | — |
| **Admin module toggle** | Top-level Admin accordion link in left nav; click to expand | `xpath=//span[contains(text(),'Admin')]/parent::a` | Navigation |
| **CSR Journey sub-item** | CSR Journey link inside expanded Admin sub-menu | `xpath=//ul[contains(@class,'nav-second-level') or contains(@class,'sub-menu')]//a[contains(@href,'CSRJourney') and not(contains(@href,'Create')) and not(contains(@href,'WholeSale'))]` | Navigation |

### 9.2 CSR Journey Landing Page (confirmed from `CSRJourney.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| **Customer dropdown** | Required — selects customer; populates BU dropdown on change | `xpath=//select[@name='customerId']` | CSRJourney.js ~444 |
| **Business Unit dropdown** | Required — selects BU; triggers CSR fetch and shows Create Order button | `xpath=//select[@name='bussinessUnit']` | CSRJourney.js ~468 |
| **Create Order button** | Visible only when user has RW permission (`enableWritePlan`); opens Create CSR Journey wizard | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Create Order')]` | CSRJourney.js ~488 |
| CSR Journey table | Displays existing CSR entries for the BU (APN Type, APNs, Device Plan, Tariff Plan) | `xpath=//div[contains(@class,'csrjourneydev')]//table` | CSRJourney.js ~505 |
| View Journey icon | Opens Journey Summary popup for a row | `xpath=//i[contains(@class,'k-grid-csrSummary')]` | CSRJourney.js ~545 |
| Edit icon | Opens edit flow for a row | `xpath=//i[contains(@class,'k-grid-editNodeKendoPopup')]` | CSRJourney.js ~546 |
| Delete icon | Deletes the CSR entry for a row | `xpath=//i[contains(@class,'k-grid-deleteNodeKendoPopup')]` | CSRJourney.js ~549 |
| Change Tariff Plan icon | Opens change tariff plan flow | `xpath=//i[contains(@class,'k-grid-changeTPNodeKendoPopup')]` | CSRJourney.js ~550 |
| Transaction History Grid | Kendo grid showing order transaction history for the BU | `id=CSRJourneyTransaction` | CSRJourney.js — `gridID` |
| View Journey popup | Bootstrap modal showing CSR Summary for the selected row | `id=journeyPopup` | CSRJourney.js ~603 |

### 9.3 Create CSR Journey Wizard — Step Indicators (confirmed from `CreateCSRJourney.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| Standard Services indicator | Step 1 label — `<p>` containing "Standard Services" | `xpath=//p[contains(.,'Standard Services')]` | CreateCSRJourney.js ~1081 |
| Additional Services indicator | Step 2 label — `<p>` containing "Additional Services" | `xpath=//p[contains(.,'Additional Services')]` | CreateCSRJourney.js ~1090 |
| Summary/Order Summary indicator | Step 3 label — `<p>` containing "Summary" | `xpath=//p[contains(.,'Summary') or contains(.,'Order Summary')]` | CreateCSRJourney.js ~1102 |
| Breadcrumb | Shows current path: TP Selection / Standard Services / Additional Services / Summary | `xpath=//li[contains(.,'TP Selection')]` | CreateCSRJourney.js ~1109 |
| Customer Name tab | Displays current customer name in breadcrumb area | `xpath=//p[contains(@class,'tab')][1]` | CreateCSRJourney.js ~1138 |
| Account Name tab | Displays current account/BU name in breadcrumb area | `xpath=//p[contains(@class,'tab')][2]` | CreateCSRJourney.js ~1140 |

### 9.4 Standard Services Screen (confirmed from `StandardServices/index.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| **Tariff Plan dropdown** | Required; disabled in edit mode | `xpath=//select[@name='tariffplan']` | StandardServices/index.js ~514 |
| **APN Type dropdown** | Required; disabled until Tariff Plan is selected | `xpath=//select[@name='apnCategory']` | StandardServices/index.js ~536 |
| **Add APNs button** | Enabled when APN Type is selected and no conflict; opens APN multi-select | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'APN')]` | StandardServices/index.js ~553 |
| **Fetch Device Plan button** | Disabled when `isTariffAPNExists` is true | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Fetch')]` | StandardServices/index.js ~559 |
| APN multi-select control | react-select control — click to open dropdown | `xpath=//div[contains(@class,'react-select__control')]` | StandardServices/index.js — Select component |
| APN dropdown menu | react-select menu — visible when control is clicked | `xpath=//div[contains(@class,'react-select__menu')]` | react-select |
| First APN option | First option in the react-select APN dropdown | `xpath=(//div[contains(@class,'react-select__option')])[1]` | react-select |
| Account VAS accordion toggle | Expands/collapses Account Level VAS Charges section | `xpath=//a[@href='#accountlevelvasCharges']` | StandardServices/index.js ~602 |
| Account VAS panel | Collapsible Account Level VAS Charges panel | `id=accountlevelvasCharges` | StandardServices/index.js ~608 |
| Device VAS accordion toggle | Expands/collapses Device Level VAS Charges section | `xpath=//a[@href='#devicelevelvasCharges']` | StandardServices/index.js ~721 |
| Device VAS panel | Collapsible Device Level VAS Charges panel | `id=devicelevelvasCharges` | StandardServices/index.js ~728 |
| Add Account VAS button | Adds a new Account VAS charge | `xpath=//button[contains(@class,'add_button') and ancestor::div[@id='accountlevelvasCharges']]` | StandardServices/index.js ~611 |
| Add Device VAS button | Adds a new Device VAS charge | `xpath=//button[contains(@class,'add_button') and ancestor::div[@id='devicelevelvasCharges']]` | StandardServices/index.js ~731 |
| **Close button** | Navigates back to `/CSRJourney` without saving | `xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]` | StandardServices/index.js ~873 |
| **Next button** | Transitions to Additional Services screen | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Next')]` | StandardServices/index.js ~879 |

### 9.5 Additional Services Screen (confirmed from `AdditionalServices/index.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| **Close button** | Navigates back to `/CSRJourney` without saving | `xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]` | AdditionalServices/index.js ~852 |
| **Previous button** | Returns to Standard Services screen | `xpath=//button[contains(@class,'btn-custom-color-black') and contains(.,'Previous')]` | AdditionalServices/index.js ~858 |
| **Next button** | Transitions to Summary screen | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Next')]` | AdditionalServices/index.js ~865 |

### 9.6 Summary Screen (confirmed from `SummaryServices/index.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| **Close button** | Navigates back to `/CSRJourney` without saving | `xpath=//button[contains(@class,'btn-cancel-color') and contains(.,'Close')]` | SummaryServices/index.js ~88 |
| **Previous button** | Returns to Additional Services screen | `xpath=//button[contains(@class,'btn-custom-color-black') and contains(.,'Previous')]` | SummaryServices/index.js ~93 |
| **Save and Exit button** | Saves the CSR Journey and redirects to `/CSRJourney` | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Save') and contains(.,'Exit')]` | SummaryServices/index.js ~101 |
| **Save & Continue button** | Saves and re-renders the Create CSR Journey wizard | `xpath=//button[contains(@class,'btn-custom-color') and contains(.,'Save') and contains(.,'Continue')]` | SummaryServices/index.js ~107 |

### 9.7 Modals and Notifications

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| CSR Overwrite modal | Bootstrap modal shown in edit mode when overwriting an existing CSR | `id=csrOverWriteModal` | CreateCSRJourney.js ~1258 |
| Success toast | Toast notification on successful save | `xpath=//div[contains(@class,'toast-success')]` | react-toastify |
| Error toast | Toast notification on API failure | `xpath=//div[contains(@class,'toast-error')]` | react-toastify |
| APN Type conflict error | Inline error when selected Tariff Plan + APN Type combination already exists | `xpath=//div[contains(@class,'apnError')]` | StandardServices/index.js ~550 |

---

## 10. Expected Results

| Step | RF Keyword Used | Expected Outcome |
|---|---|---|
| Manage Devices loaded | `Wait Until Element Is Visible    ${LOC_GRID}` | Device grid visible; starting point confirmed |
| Admin module expanded | `Click Element    ${LOC_ADMIN_TOGGLE}` | Admin sub-menu expands; CSR Journey sub-item becomes visible |
| CSR Journey sub-item clicked | `Click Element    ${LOC_CSR_JOURNEY_NAV}` | Page navigates to `/CSRJourney` |
| Landing page loaded | `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}` | Customer dropdown rendered |
| Customer selected | `Select From List By Index    ${LOC_CUSTOMER_DD}    1` | Business Unit dropdown populates |
| Business Unit selected | `Select From List By Index    ${LOC_BUSINESS_UNIT_DD}    1` | CSR fetch completes; Create Order button appears |
| Create Order clicked | `Click Element    ${LOC_CREATE_ORDER_BTN}` | URL changes to `/CreateCSRJourney?...`; wizard loads |
| Standard Services visible | `Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}` | Tariff Plan dropdown rendered; Standard Services screen active |
| Tariff Plan selected | `Select From List By Index    ${LOC_TARIFF_PLAN_DD}    1` | APN Type dropdown becomes enabled |
| APN Type selected | `Select From List By Label    ${LOC_APN_TYPE_DD}    private` | Add APNs button becomes enabled |
| APN added | `Click Element    ${LOC_APN_OPTION_FIRST}` | At least one APN tag appears in the react-select control |
| Device plans fetched | `Click Element    ${LOC_FETCH_DP_BTN}` | Device plan section populated |
| Next clicked (Standard) | `Click Element    ${LOC_STD_NEXT_BTN}` | Additional Services screen renders |
| Next clicked (Additional) | `Click Element    ${LOC_ADD_NEXT_BTN}` | Summary screen renders |
| Save and Exit clicked | `Click Element    ${LOC_SUM_SAVE_EXIT_BTN}` | API call made; success toast displayed |
| Redirect confirmed | `Location Should Contain    CSRJourney` | URL returns to `/CSRJourney` |
| Landing page re-rendered | `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}` | Customer dropdown visible again |

---

## 11. Negative Test Scenarios

| Scenario ID | Scenario Description | Action Taken | RF Assertion |
|---|---|---|---|
| NEG-01 | Customer not selected | Leave Customer at default blank; attempt Business Unit selection | `Element Should Be Disabled    ${LOC_BUSINESS_UNIT_DD}` or BU dropdown remains empty |
| NEG-02 | Business Unit not selected | Select Customer; leave BU at default; look for Create Order button | `Element Should Not Be Visible    ${LOC_CREATE_ORDER_BTN}` |
| NEG-03 | User lacks write permission | Select Customer and BU for a read-only BU | Create Order button does not appear; `Element Should Not Be Visible    ${LOC_CREATE_ORDER_BTN}` |
| NEG-04 | No Tariff Plan selected | Leave Tariff Plan blank; check APN Type state | APN Type dropdown remains disabled; `Element Should Be Disabled    ${LOC_APN_TYPE_DD}` |
| NEG-05 | No APN Type selected | Select Tariff Plan; leave APN Type blank | Add APNs button remains disabled; `Element Should Be Disabled    ${LOC_ADD_APN_BTN}` |
| NEG-06 | Tariff Plan + APN Type combination already exists | Select a combination that already has a CSR Journey | Inline error `apnError` is shown; Fetch Device Plan button disabled; `Element Should Be Visible    xpath=//div[contains(@class,'apnError')]` |
| NEG-07 | No APN selected (empty multi-select) | Click Add APNs; close dropdown without selecting | Validation error displayed; `Page Should Contain    xpath=//div[contains(@class,'apnError')]` |
| NEG-08 | Tariff Plan dropdown rendered with no plans | API returns empty list; select blank | Next button should remain disabled or error shown |
| NEG-09 | Click "Next" without mandatory fields | Attempt Next without Tariff Plan + APN Type + APN | Error messages displayed; screen does not advance |
| NEG-10 | Session expires during wizard fill | Leave wizard idle until session times out | `Location Should Contain    192.168.1.26:7874/` — redirected to login root |
| NEG-11 | CSR Overwrite in edit mode | Navigate via Update Order; existing CSR exists | `Wait Until Element Is Visible    ${LOC_OVERWRITE_MODAL}` — overwrite modal appears |
| NEG-12 | API failure during Save | Simulate API error on Save and Exit | `Wait Until Element Is Visible    ${LOC_ERROR_TOAST}` — error toast displayed; no redirect |
| NEG-13 | Navigate back via Previous from Additional | Click Previous on Additional Services | Standard Services screen renders (`Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}`) |
| NEG-14 | Navigate back via Previous from Summary | Click Previous on Summary | Additional Services screen renders (`Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}`) |
| NEG-15 | Close from Standard Services screen | Click Close without saving | Redirect to `/CSRJourney`; `Location Should Contain    CSRJourney` and `Location Should Not Contain    CreateCSRJourney` |

---

## 12. Validation Checks

After `Save And Exit CSR Journey` completes, the automation must confirm:

```robot
Validate CSR Journey Creation
    # 1. Success notification is visible
    Element Should Be Visible        ${LOC_SUCCESS_TOAST}

    # 2. No error elements on page
    Page Should Not Contain Element
    ...    xpath=//div[contains(@class,'toast-error')]

    # 3. Redirected back to CSR Journey landing page
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    CSRJourney
    Location Should Not Contain      CreateCSRJourney

    # 4. CSR Journey landing page is rendered (Customer dropdown visible)
    Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}    ${TIMEOUT}
    Element Should Be Visible        ${LOC_CUSTOMER_DD}

    Log    CSR Journey created and validated successfully    INFO
```

---

## 13. Automation Considerations

### Explicit Waits Only
Never use `Sleep` except when waiting for fire-and-forget async operations (e.g., device plan fetch). Use SeleniumLibrary wait keywords for all dynamic content:
```robot
Wait Until Element Is Visible      locator    ${TIMEOUT}
Wait Until Element Is Enabled      locator    ${TIMEOUT}
Wait Until Element Is Not Visible  locator    ${TIMEOUT}
Wait Until Page Contains           text       ${TIMEOUT}
```

### In-Page Screen Transitions (No URL Change)
The three wizard screens (Standard Services → Additional Services → Summary) are controlled by React state (`this.setState({ currentScreen })`). The URL stays at `/CreateCSRJourney?...` throughout. **Never use `Location Should Contain` or `Wait Until Keyword Succeeds    Location Should Contain` to assert screen transitions.** Instead, assert on the appearance/disappearance of screen-specific elements:
```robot
# Correct: assert on visible wizard elements
Wait Until Element Is Visible    ${LOC_STEP_ADDITIONAL}    ${TIMEOUT}
Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}    ${TIMEOUT}

# Incorrect: URL does not change between wizard steps
# Location Should Contain    AdditionalServices    ← WILL FAIL
```

### react-select APN Multi-Select Interaction
The APN selector is a `react-select` component and does **not** use a native `<select>` tag. Do not use `Select From List By Label` or `Select From List By Index` on it. Use the following pattern:
```robot
# Open the dropdown
Click Element    xpath=//div[contains(@class,'react-select__control')]
# Wait for options to appear
Wait Until Element Is Visible    xpath=//div[contains(@class,'react-select__menu')]    ${TIMEOUT}
# Click the first option
Click Element    xpath=(//div[contains(@class,'react-select__option')])[1]
# Confirm dropdown closed
Wait Until Element Is Not Visible    xpath=//div[contains(@class,'react-select__menu')]    ${TIMEOUT}
```

### APN Type Dropdown Enable Dependency
The APN Type dropdown is disabled (`disabled={!selectedTariffPlan?.id}`) until a valid Tariff Plan is chosen. Always use `Wait Until Element Is Enabled` before attempting to select from it:
```robot
Select From List By Index    ${LOC_TARIFF_PLAN_DD}    1
Wait Until Element Is Enabled    ${LOC_APN_TYPE_DD}    ${TIMEOUT}
Select From List By Label    ${LOC_APN_TYPE_DD}    private
```

### Create Order Button Visibility
The Create Order button is conditionally rendered based on `enableWritePlan` (set from API response after BU selection). It will not appear for accounts with read-only access. Use `Wait Until Element Is Visible` with `${TIMEOUT}` to handle API response latency:
```robot
Select From List By Index    ${LOC_BUSINESS_UNIT_DD}    1
Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}    ${TIMEOUT}
```

### CSR Journey Nav Link — Avoid WholeSale and Create Links
The left sidebar may contain multiple links that include `CSRJourney` in their `href` (e.g. `/WholeSaleCSRJourney`, `/CreateCSRJourney`). Scope the locator to exclude those:
```robot
${LOC_CSR_JOURNEY_NAV}    xpath=//ul[contains(@class,'nav-second-level')]//a[contains(@href,'CSRJourney') and not(contains(@href,'Create')) and not(contains(@href,'WholeSale'))]
```

### Admin Accordion Already Expanded
If the Admin accordion is already expanded from a previous test (nav state is persisted between tests), clicking `${LOC_ADMIN_TOGGLE}` again will **collapse** the menu. Use `Run Keyword And Return Status` to check if the CSR Journey sub-item is already visible before clicking the toggle:
```robot
${is_visible}=    Run Keyword And Return Status
...    Element Should Be Visible    ${LOC_CSR_JOURNEY_NAV}
Run Keyword If    not ${is_visible}    Click Element    ${LOC_ADMIN_TOGGLE}
Wait Until Element Is Visible    ${LOC_CSR_JOURNEY_NAV}    ${TIMEOUT}
```

### Navigating to CSR Journey (Admin Module Sub-Item)
CSR Journey is **not** a top-level navigation item. It is nested inside the **Admin** module accordion in the left sidebar. The Admin item must be **expanded first** before the CSR Journey link is interactable:
```robot
# Step 1: Expand Admin accordion
Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}
Click Element                    ${LOC_ADMIN_TOGGLE}
# Step 2: Click CSR Journey sub-item (only visible after Admin is expanded)
Wait Until Element Is Visible    ${LOC_CSR_JOURNEY_NAV}    ${TIMEOUT}
Click Element                    ${LOC_CSR_JOURNEY_NAV}
```

### Page Load Retry
Wrap page transition waits with `Wait Until Keyword Succeeds` to handle transient network delays:
```robot
Wait Until Keyword Succeeds    3x    5s
...    Location Should Contain    CSRJourney
```

### Scroll Before Bottom Buttons
The Next / Save buttons are at the bottom of each wizard screen. Always scroll before interacting:
```robot
Scroll Element Into View    ${LOC_STD_NEXT_BTN}
Wait Until Element Is Visible    ${LOC_STD_NEXT_BTN}    ${TIMEOUT}
Click Element    ${LOC_STD_NEXT_BTN}
```

### SSL Certificate Bypass
```robot
${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
Call Method    ${options}    add_argument    --ignore-certificate-errors
Open Browser    ${BASE_URL}    chrome    options=${options}
```

### Shared Login and Navigation
This test reuses the `Login To Application` and `Navigate To Manage Devices` keywords from `common_keywords.robot` (established in TC_001). Do not duplicate login logic.

### Screenshot on Failure
```robot
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot    EMBED
```
`EMBED` writes screenshots directly into `log.html` for immediate visibility.

### Session Cleanup
```robot
Test Setup    Run Keywords    Delete All Cookies    AND    ...
```

---

## 14. Framework Recommendation

This specification is written for **Robot Framework + SeleniumLibrary** to align with TC_001, TC_002, TC_003, and TC_004. The table below describes how the same test can be implemented in other frameworks if needed.

| Framework | Language | Approach | SSL Handling | Notes |
|---|---|---|---|---|
| **Robot Framework + SeleniumLibrary** | Python (keyword DSL) | `Select From List By Index`, `Click Element`, `Wait Until Element Is Enabled` | `ChromeOptions` via `Evaluate` | **Recommended** — consistent with TC_001 / TC_002 / TC_003 / TC_004 |
| **Playwright (Python)** | Python | `page.locator()`, `page.select_option()`, `expect(locator).to_be_enabled()` | `ignore_https_errors=True` in browser context | Best for modern React SPAs; built-in auto-wait; handles react-select cleanly via `page.click()` + `page.locator('.react-select__option')` |
| **Selenium (Python)** | Python | `WebDriverWait`, `Select` class, `find_element` | `ChromeOptions` with `--ignore-certificate-errors` | Widely adopted; requires explicit wait management |
| **Cypress** | JavaScript | `cy.get()`, `cy.select()`, `cy.contains()` | `chromeWebSecurity: false` in `cypress.config.js` | `cy.contains()` works well for react-select options; `cy.within()` for scoped queries |

---

## 15. Example Playwright Script

```python
import pytest
from playwright.sync_api import Page, expect

# ── Configuration ──────────────────────────────────────────────────────────────
BASE_URL    = "https://192.168.1.26:7874"
USERNAME    = "ksa_opco"
PASSWORD    = "Admin@123"

# ── Confirmed Locators (from source code) ─────────────────────────────────────
# Navigation
LOC_ADMIN_TOGGLE      = "//span[contains(text(),'Admin')]/parent::a"
LOC_CSR_JOURNEY_NAV   = "//ul[contains(@class,'nav-second-level')]//a[contains(@href,'CSRJourney') and not(contains(@href,'Create')) and not(contains(@href,'WholeSale'))]"

# Landing page (CSRJourney.js)
LOC_CUSTOMER_DD       = "select[name='customerId']"                   # CSRJourney.js ~444
LOC_BUSINESS_UNIT_DD  = "select[name='bussinessUnit']"                # CSRJourney.js ~468
LOC_CREATE_ORDER_BTN  = "button.btn-custom-color:has-text('Create Order')"  # CSRJourney.js ~488

# Standard Services (StandardServices/index.js)
LOC_TARIFF_PLAN_DD    = "select[name='tariffplan']"                   # ~514
LOC_APN_TYPE_DD       = "select[name='apnCategory']"                  # ~536
LOC_ADD_APN_BTN       = "button.btn-custom-color:has-text('APN')"     # ~553
LOC_FETCH_DP_BTN      = "button.btn-custom-color:has-text('Fetch')"   # ~559
LOC_APN_CONTROL       = ".react-select__control"
LOC_APN_MENU          = ".react-select__menu"
LOC_APN_FIRST_OPTION  = ".react-select__option:first-of-type"
LOC_STD_NEXT_BTN      = "button.btn-custom-color:has-text('Next')"    # ~879

# Additional Services (AdditionalServices/index.js)
LOC_ADD_NEXT_BTN      = "button.btn-custom-color:has-text('Next')"    # ~865

# Summary (SummaryServices/index.js)
LOC_SAVE_EXIT_BTN     = "button.btn-custom-color:has-text('Save and Exit')"  # ~101


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
    page.locator("input.btn-custom-color[type='button']").click()
    page.locator("#gridData").wait_for(state="visible")
    expect(page.locator(".erre-it")).not_to_be_visible()


def test_create_csr_journey(page: Page) -> None:
    # ── Step 1: Login and confirm Manage Devices starting point ────────────────
    login(page)
    page.locator("#gridData").wait_for(state="visible")

    # ── Step 2: Navigate to CSR Journey via Admin module in left nav ───────────
    nav_panel = page.locator("//div[contains(@class,'sidebar')]")
    nav_panel.wait_for(state="visible")
    admin_toggle = page.locator(LOC_ADMIN_TOGGLE)
    admin_toggle.scroll_into_view_if_needed()
    admin_toggle.click()
    csr_nav = page.locator(LOC_CSR_JOURNEY_NAV)
    csr_nav.wait_for(state="visible")
    csr_nav.click()
    page.wait_for_url("**CSRJourney**")
    page.locator(LOC_CUSTOMER_DD).wait_for(state="visible")

    # ── Step 3: Select Customer ────────────────────────────────────────────────
    page.locator(LOC_CUSTOMER_DD).select_option(index=1)
    page.locator(LOC_BUSINESS_UNIT_DD).wait_for(state="visible")

    # ── Step 4: Select Business Unit ──────────────────────────────────────────
    page.locator(LOC_BUSINESS_UNIT_DD).select_option(index=1)
    page.locator(LOC_CREATE_ORDER_BTN).wait_for(state="visible")

    # ── Step 5: Click Create Order ────────────────────────────────────────────
    page.locator(LOC_CREATE_ORDER_BTN).click()
    page.wait_for_url("**CreateCSRJourney**")
    page.locator(LOC_TARIFF_PLAN_DD).wait_for(state="visible")

    # ── Step 6: Select Tariff Plan ────────────────────────────────────────────
    page.locator(LOC_TARIFF_PLAN_DD).select_option(index=1)

    # ── Step 7: Select APN Type ───────────────────────────────────────────────
    expect(page.locator(LOC_APN_TYPE_DD)).to_be_enabled()
    page.locator(LOC_APN_TYPE_DD).select_option(label="private")
    expect(page.locator(LOC_ADD_APN_BTN)).to_be_enabled()

    # ── Step 8: Add APN ───────────────────────────────────────────────────────
    page.locator(LOC_ADD_APN_BTN).click()
    page.locator(LOC_APN_CONTROL).click()
    page.locator(LOC_APN_MENU).wait_for(state="visible")
    page.locator(LOC_APN_FIRST_OPTION).click()
    page.locator(LOC_APN_MENU).wait_for(state="hidden")

    # ── Step 9: Fetch Device Plans ────────────────────────────────────────────
    expect(page.locator(LOC_FETCH_DP_BTN)).to_be_enabled()
    page.locator(LOC_FETCH_DP_BTN).click()
    page.wait_for_timeout(2000)  # Allow async fetch to complete

    # ── Step 10: Proceed to Additional Services ───────────────────────────────
    next_btn = page.locator(LOC_STD_NEXT_BTN)
    next_btn.scroll_into_view_if_needed()
    next_btn.click()
    page.locator("p:has-text('Additional Services')").wait_for(state="visible")

    # ── Step 11: Proceed to Summary ───────────────────────────────────────────
    add_next = page.locator(LOC_ADD_NEXT_BTN)
    add_next.scroll_into_view_if_needed()
    add_next.click()
    page.locator("p:has-text('Summary')").wait_for(state="visible")
    page.locator(LOC_SAVE_EXIT_BTN).wait_for(state="visible")

    # ── Step 12: Save and Exit ────────────────────────────────────────────────
    save_exit = page.locator(LOC_SAVE_EXIT_BTN)
    save_exit.scroll_into_view_if_needed()
    save_exit.click()

    # ── Step 13: Validate success and redirect ────────────────────────────────
    expect(page.locator(".toast-success")).to_be_visible()
    page.wait_for_url("**CSRJourney**")
    assert "CreateCSRJourney" not in page.url, "Should have redirected away from Create page"
    page.locator(LOC_CUSTOMER_DD).wait_for(state="visible")
    print("CSR Journey created successfully")
```

> **Run command for Playwright:**
> ```bash
> pytest tests/test_create_csr_journey.py --headed
> ```

---

## 16. Success Validation Checklist

- [ ] `Wait Until Element Is Visible    ${LOC_GRID}` passes — Manage Devices starting point confirmed
- [ ] `Scroll Element Into View    ${LOC_ADMIN_TOGGLE}` executes without error
- [ ] `Click Element    ${LOC_ADMIN_TOGGLE}` expands Admin module — CSR Journey sub-item becomes visible
- [ ] `Wait Until Element Is Visible    ${LOC_CSR_JOURNEY_NAV}` passes — CSR Journey sub-item rendered under Admin
- [ ] `Click Element    ${LOC_CSR_JOURNEY_NAV}` executes without error
- [ ] `Location Should Contain    CSRJourney` passes after CSR Journey sub-item click
- [ ] `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}` passes — landing page rendered
- [ ] `Select From List By Index    ${LOC_CUSTOMER_DD}    1` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_BUSINESS_UNIT_DD}` passes — BU dropdown populated
- [ ] `Select From List By Index    ${LOC_BUSINESS_UNIT_DD}    1` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_CREATE_ORDER_BTN}` passes — user has write permission
- [ ] `Click Element    ${LOC_CREATE_ORDER_BTN}` executes without error
- [ ] `Location Should Contain    CreateCSRJourney` passes — wizard navigated to
- [ ] `Wait Until Element Is Visible    ${LOC_TARIFF_PLAN_DD}` passes — Standard Services screen loaded
- [ ] `Select From List By Index    ${LOC_TARIFF_PLAN_DD}    1` executes without error
- [ ] `Wait Until Element Is Enabled    ${LOC_APN_TYPE_DD}` passes — APN Type enabled after Tariff Plan selected
- [ ] `Select From List By Label    ${LOC_APN_TYPE_DD}    private` executes without error
- [ ] `Wait Until Element Is Enabled    ${LOC_ADD_APN_BTN}` passes
- [ ] `Click Element    ${LOC_ADD_APN_BTN}` opens APN selection
- [ ] `Click Element    ${LOC_APN_MULTISELECT}` opens react-select dropdown
- [ ] `Wait Until Element Is Visible    ${LOC_APN_MENU}` passes — APN options visible
- [ ] `Click Element    ${LOC_APN_OPTION_FIRST}` selects first APN
- [ ] `Wait Until Element Is Not Visible    ${LOC_APN_MENU}` passes — dropdown closed
- [ ] `Click Element    ${LOC_FETCH_DP_BTN}` executes without error
- [ ] `Scroll Element Into View    ${LOC_STD_NEXT_BTN}` executes without error
- [ ] `Click Element    ${LOC_STD_NEXT_BTN}` transitions to Additional Services
- [ ] `Wait Until Element Is Visible    ${LOC_STEP_ADDITIONAL}` passes
- [ ] `Wait Until Element Is Visible    ${LOC_ADD_NEXT_BTN}` passes
- [ ] `Click Element    ${LOC_ADD_NEXT_BTN}` transitions to Summary screen
- [ ] `Wait Until Element Is Visible    ${LOC_STEP_SUMMARY}` passes
- [ ] `Wait Until Element Is Visible    ${LOC_SUM_SAVE_EXIT_BTN}` passes
- [ ] `Scroll Element Into View    ${LOC_SUM_SAVE_EXIT_BTN}` executes without error
- [ ] `Click Element    ${LOC_SUM_SAVE_EXIT_BTN}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}` passes within `${TIMEOUT}`
- [ ] `Location Should Contain    CSRJourney` passes (redirect confirmed)
- [ ] `Location Should Not Contain    CreateCSRJourney` passes
- [ ] `Wait Until Element Is Visible    ${LOC_CUSTOMER_DD}` passes — landing page confirmed
- [ ] No `FAIL` entries in `output.xml`
- [ ] `log.html` and `report.html` generated in `results/` directory

---

## 17. Current Project Implementation (Aligned with Codebase)

This section documents the **actual implementation** in the project: flow order, HTML elements, and where they are used (`tests/csr_journey_tests.robot`, `resources/keywords/csr_journey_keywords.resource`, `resources/locators/csr_journey_locators.resource`, `variables/csr_journey_variables.py`). Use this when updating automation or the spec.

### 17.1 Page Load and Landing

- **CSR Journey page:** Wait until `https://192.168.1.26:7874/CSRJourney` loads (URL contains `CSRJourney`), then wait for loading overlay to complete and Customer dropdown visible. Keyword: `Wait For CSR Journey Page Loaded`. Use after navigating to CSR Journey or when starting any flow on the landing page.

### 17.2 Customer and Business Unit Selection

- **Customer option (to select):** `<div name="customerId" data-testid="customerId" class="option select" value="29299">SANJ_1002</div>` — Default: `CSRJ_DEFAULT_CUSTOMER_NAME = "SANJ_1002"`. Select by clicking Customer dropdown, then the option with text SANJ_1002.
- **Business Unit (account):** Click the BU dropdown trigger (second `selectBtn form-control` on page). Then select: `<div name="bussinessUnit" data-testid="bussinessUnit" class="option select" value="29300">billingAccountSANJ_1003</div>` — Default: `CSRJ_DEFAULT_BU_NAME = "billingAccountSANJ_1003"`.
- **Create Order button:** `<button type="button" class="btn btn-custom-color pull-right width-75">Create Order</button>`

### 17.3 Standard Services (After Create Order)

1. **Tariff plan:** Option `<div name="tariffplan" data-testid="tariffplan" class="option" value="29955">DATA AND NBIOT IT tp</div>` — Variable: `CSRJ_DEFAULT_TARIFF_PLAN = "DATA AND NBIOT IT tp"`.
2. **APN Type:** `<select name="apnCategory" data-testid="apnCategory" class="form-control">` — Select **Any**. Variable: `CSRJ_APN_TYPE_ANY = "Any"`.
3. **Add APNs:** `<button class="btn btn-custom-color cursor-pointer">Add APN's</button>` — Click. Then immediately run step 4 (no separate wait step).
4. **In APN modal (`#apnSelectionModal`):** Wait for modal and Save button, select APN **public_dynamic**, set IP preference if present, click **Save** (Add APN Save only: `<button class="btn btn-custom-color m-l-15 width-75">Save</button>`). Then click Fetch Device Plan.
5. **Fetch Device Plan:** `<button class="btn btn-custom-color cursor-pointer">Fetch Device Plan</button>` — Click, then **wait for page to load** (e.g. Bundle Plan dropdown visible) before next step.
6. **Bundle plan:** `<select name="bundleName" data-testid="bundleName" class="form-control">` — Select **DATA AND NBIOT IT DP**. Variable: `CSRJ_DEFAULT_BUNDLE_PLAN`.
7. **Device plan:** Enter **random** device plan alias into `dpAliasName` input. Variable: `CSRJ_DEVICE_PLAN_ALIAS`.
8. **Create Service Plan:** `<div class="text-right cursor-pointer p-5 createServicePlan">Create Service Plan</div>` — Click; dialog opens.
9. **Save in Create Service Plan dialog:** `<button class="btn btn-custom-color m-l-15 width-75 ml-2 cursor-pointer" type="submit">Save</button>` (different from Add APN Save—this one has ml-2, cursor-pointer, type=submit).
10. **Next (Standard):** `<button class="btn btn-custom-color ml-2 width-75">Next</button>` — Then **Next** (Additional): `<button class="btn btn-custom-color width-75">Next</button>`. On **Summary** click **Save & Continue:** `<button class="btn btn-custom-color  mr-2 m-r-10">Save & Continue</button>` or **Save & Exit** for full flow.

### 17.4 Flow Order (Summary)

After selecting APN → click **Save** → click **Fetch Device Plan** → wait for page load → select **Bundle Plan** → enter **device plan** → click **Create Service Plan** → click **Save** (in modal) → **Next** → **Next** → **Save & Exit** (or Save & Continue).

### 17.5 Project Files

| Content | Location |
|--------|----------|
| Test cases (55 tests) | `tests/csr_journey_tests.robot` |
| Keywords | `resources/keywords/csr_journey_keywords.resource` |
| Locators | `resources/locators/csr_journey_locators.resource` |
| Variables / Test data | `variables/csr_journey_variables.py` |
| Browser setup | `resources/keywords/browser_keywords.resource` |
| Login keywords | `resources/keywords/login_keywords.resource` |
| Full create flow | Keyword `Full Create CSR Journey Flow` |

### Run Command

```bash
robot --outputdir reports tests/csr_journey_tests.robot
```

### 17.6 Test Case List (55 tests)

| ID | Name | Type |
|----|------|------|
| TC_CSRJ_001 | Navigate To CSR Journey Module Via Admin | positive |
| TC_CSRJ_002 | Select Customer And Verify BU Dropdown Populates | positive |
| TC_CSRJ_003 | Select BU And Verify Create Order Button Visible | positive |
| TC_CSRJ_004 | Create CSR Journey End To End Standard Flow | positive |
| TC_CSRJ_004_Delete | Delete CSR Created In Test Case 4 | positive |
| TC_CSRJ_005 | Save And Continue Should Stay On Wizard | positive |
| TC_CSRJ_006 | Verify Wizard Step Indicators Are Visible | positive |
| TC_CSRJ_007 | Navigate Previous From Additional To Standard Services | positive |
| TC_CSRJ_008 | Navigate Previous From Summary To Additional Services | positive |
| TC_CSRJ_009 | Verify Customer And BU Info Displayed On Summary | positive |
| TC_CSRJ_010 | Select Tariff Plan And Verify APN Type Becomes Enabled | positive |
| TC_CSRJ_011 | Verify Tariff Plan Accordion On Summary Shows Selected TP | positive |
| TC_CSRJ_012 | APN Type Dropdown Disabled Without Tariff Plan | negative |
| TC_CSRJ_013 | Add APNs Button Disabled Without APN Type | negative |
| TC_CSRJ_014 | Close From Standard Services Should Redirect Without Saving | negative |
| TC_CSRJ_015 | Close From Additional Services Should Redirect Without Saving | negative |
| TC_CSRJ_016 | Close From Summary Should Redirect Without Saving | negative |
| TC_CSRJ_017 | Create Order Not Visible Without BU Selection | negative |
| TC_CSRJ_018 | BU Dropdown Not Interactable Without Customer Selection | negative |
| TC_CSRJ_019 | Select APN Type Public And Verify Add APNs Enabled | positive |
| TC_CSRJ_020 | Select APN Type Any And Verify Add APNs Enabled | positive |
| TC_CSRJ_021 | Close Service Plan Modal Without Saving | negative |
| TC_CSRJ_022 | Close Discount Modal Without Saving | negative |
| TC_CSRJ_023 | Verify CSR Summary Icon Visible In Grid | positive |
| TC_CSRJ_024 | Verify Edit Icon Visible In CSR Journey Grid | positive |
| TC_CSRJ_025 | Verify Delete Icon Visible In CSR Journey Grid | positive |
| TC_CSRJ_026 | Verify Change Tariff Plan Icon Visible In Grid | positive |
| TC_CSRJ_027 | Verify Account VAS Accordion Toggle | positive |
| TC_CSRJ_028 | Verify Device VAS Accordion Toggle | positive |
| TC_CSRJ_029 | Verify Breadcrumb Updates Across Wizard Steps | positive |
| TC_CSRJ_030 | Verify APN Table Headers On Landing Page | positive |
| TC_CSRJ_031 | Verify Discount Accordion Toggle On Additional Services | positive |
| TC_CSRJ_032 | Verify Summary Accordion Sections Expandable | positive |
| TC_CSRJ_033 | Select Addon Plan And Verify Table Populates | positive |
| TC_CSRJ_034 | Fill And Save Service Plan Via Modal | positive |
| TC_CSRJ_035 | Fill And Save Discount On Additional Services | positive |
| TC_CSRJ_036 | Select Bundle Plan After Fetch Device Plan | positive |
| TC_CSRJ_037 | Fill End Date On Standard Services | positive |
| TC_CSRJ_038 | Search Customer By Name In Dropdown | positive |
| TC_CSRJ_039 | Search Tariff Plan By Name In Dropdown | positive |
| TC_CSRJ_040 | APN Type Conflict Should Show Error | negative |
| TC_CSRJ_041 | Service Plan Input Disabled Until Tariff Plan Selected | negative |
| TC_CSRJ_042 | Save Account VAS Without Filling Required Fields | negative |
| TC_CSRJ_043 | Save Device VAS Without Filling Required Fields | negative |
| TC_CSRJ_044 | Save Discount Without Filling Required Fields | negative |
| TC_CSRJ_045 | Verify Usage Based Charges Grid On Landing Page | positive |
| TC_CSRJ_046 | Verify Transaction History Grid On Landing Page | positive |
| TC_CSRJ_047 | Verify Order Summary Heading On Landing Page | positive |
| TC_CSRJ_048 | View CSR Summary Popup Via Eye Icon | positive |
| TC_CSRJ_049 | CSR Overwrite Modal In Edit Mode | positive |
| TC_CSRJ_050 | Navigate Full Wizard Forward And Backward | positive |
| TC_CSRJ_051 | Verify All APN Type Options Available | positive |
| TC_CSRJ_052 | Modify CSR Journey Via Edit And Save | positive |
| TC_CSRJ_053 | Edit CSR Journey Update Service Types And Save | positive |
| TC_CSRJ_054 | Add Multiple Device Plans In Single CSR Journey | positive |
| TC_CSRJ_055 | Verify Multiple Device Plan Rows On Summary | positive |

---

## 18. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-06 | CMP QA Team | Initial Robot Framework specification for TC_005 Create CSR Journey; aligned to TC_001, TC_002, TC_003, and TC_004 in structure, credential format, keyword style, variable naming, locator strategy, and retry/screenshot patterns; all locators confirmed against `CSRJourney.js`, `CreateCSRJourney.js`, `StandardServices/index.js`, `AdditionalServices/index.js`, and `SummaryServices/index.js` source; includes Admin accordion expand guidance (same pattern as TC_004), react-select APN interaction notes, in-page screen transition assertions (no URL change between wizard steps), conditional Create Order button visibility, APN Type enable dependency, complete `.robot` file, Playwright reference script, and full negative/validation coverage |
| 1.1 | 2026-03-09 | — | Added Section 17: Current Project Implementation — flow order, HTML for Customer/BU, Create Order, Tariff plan, APN Type Any, Add APNs, APN modal Save, Fetch Device Plan, wait for load, Bundle Plan, device plan, Create Service Plan, Save, Next, Save & Continue/Exit; project file references |
