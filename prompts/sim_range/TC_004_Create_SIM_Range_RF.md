# Automation Test Specification – Create SIM Range

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 13)*
**Date:** 2026-03-06
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md · TC_003_Create_SIM_Order_RF.md

---

## 1. Objective

This test validates the end-to-end **Create SIM Range** workflow on the CMP web application. The automation begins from the **Manage Devices** page (post-login) and covers:

1. Navigating to the **SIM Range** module via the left-side navigation panel
2. Selecting the correct asset-type tab (**ICCID/IMSI** or **MSISDN**)
3. Launching the **Create SIM Range** form
4. Completing all mandatory fields: Pool Name, Account, Description, and Assets Type
5. Adding at least one **ICCID range** and one **IMSI range** (for ICCID/IMSI flow) via their respective popups
6. Confirming the **Pool Count** is auto-calculated
7. Submitting the form and verifying the **success notification** and redirect back to the SIM Range list

This test ensures the full SIM Range creation workflow is functional, all mandatory fields are validated, range conflict detection works correctly, and the system correctly stores and acknowledges the submitted SIM Range.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **SIM Range Page URL** | `https://192.168.1.26:7874/SIMRange` |
| **Create SIM Range URL** | `https://192.168.1.26:7874/CreateSIMRange?currentTab=0` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |
| **SIM Range Location in UI** | **Admin module → SIM Range** (left-side navigation; SIM Range is a sub-item under the Admin accordion/menu group) |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` and has landed on the **Manage Devices** page
  - *(Use `Login To Application` and `Navigate To Manage Devices` keywords from `TC_001_Login_Navigate_RF.md`)*
- The `ksa_opco` user has **RW (Read-Write)** permission to access the **SIM Range** module
- The **SIM Range** module is enabled and visible in the left-side navigation panel
- At least one valid **Account** exists in the system for SIM Range creation
- The ICCID/IMSI range values used in the test are **not already registered** in the system (no overlap with existing ranges)
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
# Run all SIM Range (ICCID/IMSI) tests
python run_tests.py tests/sim_range_tests.robot

# Run by module name
python run_tests.py --suite "SIM Range"

# Run a single test
python run_tests.py tests/sim_range_tests.robot --test "TC_SR_001*"
```

### 4.3 Project Structure (actual stc-automation layout)

```
d:\stc-automation\
├── config\env_config.py
├── variables\sim_range_variables.py
├── variables\login_variables.py
├── resources\locators\sim_range_locators.resource
├── resources\locators\login_locators.resource
├── resources\keywords\sim_range_keywords.resource
├── resources\keywords\browser_keywords.resource
├── resources\keywords\login_keywords.resource
├── tests\sim_range_tests.robot
├── run_tests.py
└── tasks.csv
```

---

## 5. Test Data

| Field | Sample Value | Notes |
|---|---|---|
| **Username** | `ksa_opco` | Same credentials as TC_001 / TC_002 / TC_003 |
| **Password** | `Admin@123` | Same credentials as TC_001 / TC_002 / TC_003 |
| **Pool Name** | `Test SIM Pool` | Max 50 characters; free text |
| **Account** | *(First available)* | Parameterise via variable file |
| **Description** | `Automation test SIM range` | Max 500 characters; free text |
| **Assets Type** | `ICCID/IMSI` | Options: `ICCID/IMSI` (id=1) or `MSISDN` (id=2) |
| **ICCID From** | `89100000000000001` | 17–20 digits; must start with non-zero digit |
| **ICCID To** | `89100000000000010` | Must be ≥ From value; same digit-length rules |
| **IMSI From** | `424010000000001` | 15 digits; must be within valid IMSI range |
| **IMSI To** | `424010000000010` | Must be ≥ From value |
| **Expected Pool Count** | `10` | Auto-calculated from range entries (To - From + 1) |
| **Expected Post-Submit URL** | `/SIMRange` | Redirected back to the SIM Range list page |

> Parameterise all test data values via a Robot Framework variable file (`variables.robot` or `--variablefile`) to support multiple environments without modifying test files.
>
> **Important:** ICCID and IMSI pool counts **must match exactly** across all added ranges before the final Submit button is enabled. The system validates that the total count of ICCID ranges equals the total count of IMSI ranges.

---

## 6. Robot Framework Settings and Variables

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/sim_range_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/sim_range_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/sim_range_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser
```

**Variables** (from `sim_range_variables.py`): `VALID_POOL_NAME`, `VALID_SR_DESCRIPTION`, `VALID_ICCID_FROM`, `VALID_ICCID_TO`, `VALID_IMSI_FROM`, `VALID_IMSI_TO`, `EXPECTED_POOL_COUNT`, `CREATE_SIM_RANGE_URL`, `SIM_RANGE_URL`, `SQL_INJECTION_POOL_NAME`, `SPECIAL_CHARS_POOL_NAME`, `POOL_NAME_EXCEEDS_MAX`, `ICCID_FROM_GREATER_THAN_TO_FROM`, `ICCID_FROM_GREATER_THAN_TO_TO`, `ICCID_TOO_SHORT`, `IMSI_FROM_GREATER_THAN_TO_FROM`, `IMSI_FROM_GREATER_THAN_TO_TO`, `IMSI_TOO_SHORT`, `MISMATCHED_IMSI_FROM`, `MISMATCHED_IMSI_TO`, `DESCRIPTION_EXCEEDS_MAX`.

**Locators** (from `sim_range_locators.resource`): `LOC_ADMIN_MENU`, `LOC_TAB_SIM_RANGE`, `LOC_TAB_ICCID_IMSI`, `LOC_TAB_CONTROL`, `LOC_SR_CREATE_BTN`, `LOC_SR_GRID`, `LOC_SR_POOL_NAME`, `LOC_SR_ACCOUNT_DD`, `LOC_SR_DESCRIPTION`, `LOC_SR_POOL_COUNT`, `LOC_SR_ASSETS_TYPE_DD`, `LOC_SR_SIM_CATEGORY_DD`, `LOC_ICCID_PANEL`, `LOC_IMSI_PANEL`, `LOC_ADD_ICCID_BTN`, `LOC_ADD_IMSI_BTN`, `LOC_ICCID_POPUP`, `LOC_ICCID_FROM`, `LOC_ICCID_TO`, `LOC_ICCID_POPUP_SUBMIT`, `LOC_IMSI_POPUP`, `LOC_IMSI_FROM`, `LOC_IMSI_TO`, `LOC_IMSI_POPUP_SUBMIT`, `LOC_ICCID_GRID`, `LOC_IMSI_GRID`, `LOC_SR_SUBMIT_BTN`, `LOC_SR_CLOSE_BTN`, `LOC_SR_TOAST_SUCCESS`, `LOC_SR_TOAST_ERROR`, `LOC_SR_ALERT_DANGER`.

**Keywords** (from `sim_range_keywords.resource`): `Login And Navigate To Create SIM Range`, `Fill SIM Range Form`, `Fill SIM Range With ICCID And IMSI`, `Add ICCID Range`, `Add IMSI Range`, `Verify Pool Count`, `Submit SIM Range Form`, `Verify SIM Range Created Successfully`, `Select ICCID IMSI Tab`, `Login And Navigate To SIM Range List`, `Verify Cancel Redirects To SIM Range List`, `Verify Submit Button Is Disabled`, `Verify ICCID Popup Submit Is Disabled`, `Verify IMSI Popup Submit Is Disabled`, `Open ICCID Popup And Enter Range`, `Open IMSI Popup And Enter Range`, `Verify Error Toast Or Popup Still Open`, `Verify Negative SIM Range Outcome`, `Enter Pool Name`, `Select Account From Dropdown`, `Enter SIM Range Description`, `Verify Pool Count Is Zero Or Empty`, `Expand IMSI Panel`.

> **Critical locator note:** `id=prceedBtn` appears **three times** in `CreateSIMRange.js` — once inside `#addRangePopup`, once inside `#addImsiRangePopup`, and once inside `#addMsisdnRangePopup`, AND once as the final page-level Submit button. Always use **scoped XPath** (prefixed with the parent modal/container id) to avoid targeting the wrong button. The variable names above already encode the correct scope.

---

## 7. Automation Flow

### Step 1 — Start from Manage Devices Page

Handled by `Test Setup` — `Login To Application` and `Navigate To Manage Devices` keywords run before each test (defined in `common_keywords.robot`, shared with TC_001 / TC_002 / TC_003).

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 1.1 | `Wait Until Element Is Visible    ${LOC_GRID}    ${TIMEOUT}` | Confirm Manage Devices grid is loaded |
| 1.2 | `Location Should Contain    ManageDevices` | Assert correct starting page |

---

### Step 2 — Navigate to SIM Range Module via Admin Module in Left Navigation Panel

> **UI structure:** SIM Range is a **sub-item under the Admin module** in the left sidebar. The Admin module is an accordion/collapse group — it must be expanded first before SIM Range becomes clickable.

```robot
Navigate To SIM Range Module
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 2.1 | `Wait Until Element Is Visible    ${LOC_NAV_PANEL}    ${TIMEOUT}` | Wait for left-side navigation to render |
| 2.2 | `Scroll Element Into View    ${LOC_ADMIN_TOGGLE}` | Scroll nav panel until the Admin module toggle link is visible |
| 2.3 | `Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}` | Assert Admin module link is visible in the sidebar |
| 2.4 | `Click Element    ${LOC_ADMIN_TOGGLE}` | Expand the Admin module accordion (reveals its sub-menu items) |
| 2.5 | `Wait Until Element Is Visible    ${LOC_SIM_RANGE_NAV}    ${TIMEOUT}` | Wait for SIM Range sub-item to appear within the expanded Admin menu |
| 2.6 | `Click Element    ${LOC_SIM_RANGE_NAV}` | Click the SIM Range sub-item under Admin |
| 2.7 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    SIMRange` | Wait for URL to contain `/SIMRange` |
| 2.8 | `Wait Until Element Is Visible    ${LOC_SIM_RANGE_HDR}    ${TIMEOUT}` | Verify the SIM Range tab control container has rendered |

---

### Step 3 — Select ICCID/IMSI Tab on SIM Range List Page

```robot
Select ICCID IMSI Tab
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 3.1 | `Wait Until Element Is Visible    ${LOC_ICCID_IMSI_TAB}    ${TIMEOUT}` | Wait for the ICCID/IMSI tab to be present |
| 3.2 | `Click Element    ${LOC_ICCID_IMSI_TAB}` | Click the ICCID/IMSI tab |
| 3.3 | `Wait Until Element Is Visible    ${LOC_CREATE_RANGE_BTN}    ${TIMEOUT}` | Wait for "Create SIM Range" button to appear after tab load |

---

### Step 4 — Click "Create SIM Range" Button

```robot
Open Create SIM Range Form
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 4.1 | `Wait Until Element Is Visible    ${LOC_CREATE_RANGE_BTN}    ${TIMEOUT}` | Locate the Create SIM Range `<a>` button |
| 4.2 | `Click Element    ${LOC_CREATE_RANGE_BTN}` | Click to navigate to the Create SIM Range form |
| 4.3 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    CreateSIMRange` | Wait for URL to contain `/CreateSIMRange` |
| 4.4 | `Wait Until Element Is Visible    ${LOC_POOL_NAME}    ${TIMEOUT}` | Confirm Pool Name input is visible — form has loaded |

---

### Step 5 — Fill Pool Name

```robot
Fill Pool Name    ${POOL_NAME}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 5.1 | `Wait Until Element Is Visible    ${LOC_POOL_NAME}    ${TIMEOUT}` | Assert Pool Name input is present |
| 5.2 | `Input Text    ${LOC_POOL_NAME}    ${POOL_NAME}` | Enter the pool name (max 50 chars, `name=poolName`) |

---

### Step 6 — Select Account from Dropdown

```robot
Select Account From Dropdown
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 6.1 | `Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${TIMEOUT}` | Assert Account dropdown is present (`data-testid=AectAccoor`) |
| 6.2 | `Select From List By Index    ${LOC_ACCOUNT_DD}    1` | Select first available account (index 1 skips blank option) |

---

### Step 7 — Fill Description

```robot
Fill Description    ${DESCRIPTION}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 7.1 | `Wait Until Element Is Visible    ${LOC_DESCRIPTION}    ${TIMEOUT}` | Assert Description input is present |
| 7.2 | `Input Text    ${LOC_DESCRIPTION}    ${DESCRIPTION}` | Enter description text (max 500 chars, `name=description`) |

---

### Step 8 — Select Assets Type (if dropdown is visible)

> The Assets Type dropdown (`data-testid=tassetsTypes`) is **hidden when navigating via the tab-based URL** (`/CreateSIMRange?currentTab=0`). When accessed this way, `assetsTypes` is pre-set to `"1"` (ICCID/IMSI) by the component's `componentDidMount` logic. Only select from the dropdown if no `currentTab` query param was used.

```robot
Select Assets Type If Visible    ICCID/IMSI
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 8.1 | `${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_ASSETS_TYPE_DD}` | Check if Assets Type dropdown is rendered |
| 8.2 | `Run Keyword If    ${visible}    Select From List By Label    ${LOC_ASSETS_TYPE_DD}    ICCID/IMSI` | Select "ICCID/IMSI" (value=1) only when the dropdown is visible |

---

### Step 9 — Add ICCID Range via Popup

```robot
Add ICCID Range    ${ICCID_FROM}    ${ICCID_TO}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 9.1 | `Wait Until Element Is Visible    ${LOC_ICCID_PANEL}    ${TIMEOUT}` | Wait for the ICCID Range accordion panel to be visible (`id=definecondition`) |
| 9.2 | `Wait Until Element Is Visible    ${LOC_ADD_ICCID_BTN}    ${TIMEOUT}` | Wait for the "+ Add" ICCID button to be enabled |
| 9.3 | `Click Element    ${LOC_ADD_ICCID_BTN}` | Open the Add ICCID Range popup (`id=addRangePopup`) |
| 9.4 | `Wait Until Element Is Visible    ${LOC_ICCID_POPUP}    ${TIMEOUT}` | Confirm popup is visible |
| 9.5 | `Input Text    ${LOC_ICCID_FROM}    ${ICCID_FROM}` | Enter ICCID From value (17–20 digits, scoped to `#addRangePopup`) |
| 9.6 | `Input Text    ${LOC_ICCID_TO}    ${ICCID_TO}` | Enter ICCID To value (scoped to `#addRangePopup`) |
| 9.7 | `Wait Until Element Is Enabled    ${LOC_ICCID_POPUP_SUBMIT}    ${TIMEOUT}` | Wait for popup Submit to become enabled (enabled when both fields have correct length) |
| 9.8 | `Click Element    ${LOC_ICCID_POPUP_SUBMIT}` | Submit the ICCID range (scoped button inside `#addRangePopup`) |
| 9.9 | `Wait Until Element Is Not Visible    ${LOC_ICCID_POPUP}    ${TIMEOUT}` | Confirm popup is dismissed |
| 9.10 | `Wait Until Element Is Visible    ${LOC_ICCID_GRID}    ${TIMEOUT}` | Confirm ICCID range table (`id=iccidRangeTable`) is now visible with the added entry |

---

### Step 10 — Expand IMSI Panel and Add IMSI Range via Popup

```robot
Add IMSI Range    ${IMSI_FROM}    ${IMSI_TO}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 10.1 | `Click Element    xpath=//a[@href='#collapseTwo']` | Expand the IMSI Range accordion panel |
| 10.2 | `Wait Until Element Is Visible    ${LOC_IMSI_PANEL}    ${TIMEOUT}` | Wait for IMSI panel (`id=collapseTwo`) to expand |
| 10.3 | `Wait Until Element Is Visible    ${LOC_ADD_IMSI_BTN}    ${TIMEOUT}` | Wait for the "+ Add" IMSI button to be visible |
| 10.4 | `Click Element    ${LOC_ADD_IMSI_BTN}` | Open the Add IMSI Range popup (`id=addImsiRangePopup`) |
| 10.5 | `Wait Until Element Is Visible    ${LOC_IMSI_POPUP}    ${TIMEOUT}` | Confirm popup is visible |
| 10.6 | `Input Text    ${LOC_IMSI_FROM}    ${IMSI_FROM}` | Enter IMSI From value (15 digits, scoped to `#addImsiRangePopup`) |
| 10.7 | `Input Text    ${LOC_IMSI_TO}    ${IMSI_TO}` | Enter IMSI To value (scoped to `#addImsiRangePopup`) |
| 10.8 | `Wait Until Element Is Enabled    ${LOC_IMSI_POPUP_SUBMIT}    ${TIMEOUT}` | Wait for popup Submit to become enabled |
| 10.9 | `Click Element    ${LOC_IMSI_POPUP_SUBMIT}` | Submit the IMSI range |
| 10.10 | `Wait Until Element Is Not Visible    ${LOC_IMSI_POPUP}    ${TIMEOUT}` | Confirm popup is dismissed |
| 10.11 | `Wait Until Element Is Visible    ${LOC_IMSI_GRID}    ${TIMEOUT}` | Confirm IMSI range table (`id=imsiRangeTable`) is visible with the added entry |

---

### Step 11 — Verify Pool Count is Auto-Calculated

```robot
Verify Pool Count Auto Calculated    ${EXPECTED_POOL_COUNT}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 11.1 | `Wait Until Element Is Visible    ${LOC_POOL_COUNT}    ${TIMEOUT}` | Pool Count field (`name=poolCount`) is read-only and auto-populated |
| 11.2 | `${pool_count}=    Get Value    ${LOC_POOL_COUNT}` | Read the current pool count value |
| 11.3 | `Should Not Be Equal    ${pool_count}    0` | Assert pool count is not zero |
| 11.4 | `Should Be Equal As Strings    ${pool_count}    ${EXPECTED_POOL_COUNT}` | Assert auto-calculated count matches expected value |

---

### Step 12 — Submit the SIM Range

```robot
Submit SIM Range
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 12.1 | `Scroll Element Into View    ${LOC_FINAL_SUBMIT_BTN}` | Scroll to bring the final Submit button into viewport |
| 12.2 | `Wait Until Element Is Enabled    ${LOC_FINAL_SUBMIT_BTN}    ${TIMEOUT}` | Assert final Submit is enabled (requires: poolName, accountId, description, assetsTypes, poolCount > 0, SIMCategory all valid) |
| 12.3 | `Click Element    ${LOC_FINAL_SUBMIT_BTN}` | Click the page-level Submit button to create the SIM Range |
| 12.4 | `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}    ${TIMEOUT}` | Wait for success toast notification |

---

### Step 13 — Validate Success and Redirect

```robot
Validate SIM Range Creation
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 13.1 | `Element Should Be Visible    ${LOC_SUCCESS_TOAST}` | Assert success toast is displayed |
| 13.2 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    SIMRange` | Verify redirect back to `/SIMRange` list page |
| 13.3 | `Wait Until Element Is Visible    ${LOC_RANGE_LIST_TABLE}    ${TIMEOUT}` | Confirm SIM Range list grid is visible |
| 13.4 | `Location Should Not Contain    CreateSIMRange` | Assert we are no longer on the Create page |

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
Wait Until Element Is Visible    ${LOC_SIM_RANGE_NAV}
Click Element    ${LOC_SIM_RANGE_NAV}         ← SIM Range sub-item under Admin
      │
      ▼
Location Should Contain    SIMRange
Click Element    ${LOC_ICCID_IMSI_TAB}
      │
      ▼
Click Element    ${LOC_CREATE_RANGE_BTN}
Location Should Contain    CreateSIMRange
      │
      ▼
Input Text    ${LOC_POOL_NAME}    ${POOL_NAME}
Select From List By Index    ${LOC_ACCOUNT_DD}    1
Input Text    ${LOC_DESCRIPTION}    ${DESCRIPTION}
[Select Assets Type if visible]
      │
      ▼
── ICCID Panel ─────────────────────────────────────────────
Click Element    ${LOC_ADD_ICCID_BTN}
Wait Until Element Is Visible    ${LOC_ICCID_POPUP}
Input Text    ${LOC_ICCID_FROM}    ${ICCID_FROM}
Input Text    ${LOC_ICCID_TO}    ${ICCID_TO}
Click Element    ${LOC_ICCID_POPUP_SUBMIT}
Wait Until Element Is Not Visible    ${LOC_ICCID_POPUP}
      │
      ▼
── IMSI Panel ──────────────────────────────────────────────
Click Element    xpath=//a[@href='#collapseTwo']   [expand accordion]
Click Element    ${LOC_ADD_IMSI_BTN}
Wait Until Element Is Visible    ${LOC_IMSI_POPUP}
Input Text    ${LOC_IMSI_FROM}    ${IMSI_FROM}
Input Text    ${LOC_IMSI_TO}    ${IMSI_TO}
Click Element    ${LOC_IMSI_POPUP_SUBMIT}
Wait Until Element Is Not Visible    ${LOC_IMSI_POPUP}
      │
      ▼
Verify Pool Count auto-calculated (poolCount > 0 and ICCID count = IMSI count)
      │
      ▼
Scroll Element Into View    ${LOC_FINAL_SUBMIT_BTN}
Wait Until Element Is Enabled    ${LOC_FINAL_SUBMIT_BTN}
Click Element    ${LOC_FINAL_SUBMIT_BTN}
      │
      ▼
Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}
      │
      ├──── Visible ────► Location Should Contain    SIMRange
      │                   Wait Until Element Is Visible    ${LOC_RANGE_LIST_TABLE}
      │                   PASS
      │
      └──── Timeout ────► FAIL: Capture Page Screenshot    EMBED
```

---

## 8. Test Case List (from `sim_range_tests.robot`)

| Test ID | Test Name | Tags |
|---------|-----------|------|
| TC_SR_001 | Create SIM Range Via ICCID IMSI Successfully | smoke, regression, positive, sim_range |
| TC_SR_002 | Verify Create SIM Range Page Elements Visible | smoke, regression, positive, sim_range |
| TC_SR_003 | Verify Pool Count Auto Calculated After Adding Ranges | regression, positive, sim_range |
| TC_SR_004 | Verify Cancel Button Redirects To SIM Range List | regression, positive, sim_range, navigation |
| TC_SR_005 | Verify ICCID IMSI Tab Selection Shows Grid | regression, positive, sim_range |
| TC_SR_006 | Verify ICCID Range Grid Shows Entry After Adding | regression, positive, sim_range |
| TC_SR_007 | Verify IMSI Range Grid Shows Entry After Adding | regression, positive, sim_range |
| TC_SR_008 | Submit Button Disabled When Pool Name Empty | regression, negative, sim_range |
| TC_SR_009 | Submit Button Disabled When Account Not Selected | regression, negative, sim_range |
| TC_SR_010 | Submit Button Disabled When Description Empty | regression, negative, sim_range |
| TC_SR_011 | Submit Button Disabled When No ICCID Range Added | regression, negative, sim_range |
| TC_SR_012 | Submit Button Disabled When ICCID And IMSI Counts Mismatch | regression, negative, sim_range |
| TC_SR_013 | ICCID From Greater Than To Should Show Error | regression, negative, sim_range, boundary |
| TC_SR_014 | ICCID Too Short Should Keep Popup Submit Disabled | regression, negative, sim_range, boundary |
| TC_SR_015 | IMSI From Greater Than To Should Show Error | regression, negative, sim_range, boundary |
| TC_SR_016 | IMSI Too Short Should Keep Popup Submit Disabled | regression, negative, sim_range, boundary |
| TC_SR_017 | SQL Injection In Pool Name Should Be Rejected | regression, negative, security, sim_range |
| TC_SR_018 | Special Characters In Pool Name Should Be Rejected | regression, negative, security, sim_range |
| TC_SR_019 | Pool Name Exceeding Max Length Should Be Rejected | regression, negative, sim_range, boundary |
| TC_SR_020 | Direct Access To Create SIM Range Without Login Should Redirect | regression, negative, security, sim_range, navigation |
| TC_SR_021 | Direct Access To SIM Range Without Login Should Redirect | regression, negative, security, sim_range, navigation |

### Sample Test Case (TC_SR_001)

```robot
TC_SR_001 Create SIM Range Via ICCID IMSI Successfully
    [Documentation]    Full E2E: Login > Admin > SIM Range > Create > fill form > add ICCID range >
    ...                add IMSI range > verify Pool Count > Submit > verify success toast and redirect.
    [Tags]    smoke    regression    positive    sim_range
    Login And Navigate To Create SIM Range
    Fill SIM Range With ICCID And IMSI
    Verify Pool Count    ${EXPECTED_POOL_COUNT}
    Submit SIM Range Form
    Verify SIM Range Created Successfully
```

### Keyword Reference (from `sim_range_keywords.resource`)

Key ICCID/IMSI keywords: `Login And Navigate To Create SIM Range`, `Navigate To SIM Range Via Admin`, `Select ICCID IMSI Tab`, `Click Create SIM Range Button`, `Fill SIM Range Form`, `Fill SIM Range With ICCID And IMSI`, `Enter Pool Name`, `Select Account From Dropdown`, `Enter SIM Range Description`, `Select Assets Type If Visible`, `Add ICCID Range`, `Add IMSI Range`, `Expand IMSI Panel`, `Open ICCID Popup And Enter Range`, `Open IMSI Popup And Enter Range`, `Verify Pool Count`, `Verify Pool Count Is Zero Or Empty`, `Submit SIM Range Form`, `Verify SIM Range Created Successfully`, `Verify Cancel Redirects To SIM Range List`, `Verify Submit Button Is Disabled`, `Verify ICCID Popup Submit Is Disabled`, `Verify IMSI Popup Submit Is Disabled`, `Verify Error Toast Or Popup Still Open`, `Verify Negative SIM Range Outcome`.

---

## 9. UI Elements and Locator Strategy

All locators have been **confirmed from the application source code** (`CreateSIMRange.js` and `ManageSIMRange.js`). The **RF Locator String** column shows the exact value to use inside Robot Framework keywords.

> **Key warnings from source inspection:**
> - `id=prceedBtn` is **reused** on all three range popups and on the final page-level Submit button. Always scope it using the parent container XPath.
> - The **Pool Count** field (`name=poolCount`) is **read-only** and **auto-calculated** — never try to type into it directly.
> - The **Assets Type dropdown** (`data-testid=tassetsTypes`) is **conditionally hidden** when the form is opened via a URL with `currentTab` param.
> - The **SIM Category dropdown** (`data-testid=tSIMCacoor`) only appears when `assetsTypes === "2"` (MSISDN).
> - The **ICCID total count must exactly equal the IMSI total count** for the final Submit to succeed in ICCID/IMSI mode.
> - The **Create SIM Range** navigation button is an `<a>` tag — not a `<button>`.

### 9.1 Navigation

> **SIM Range is accessed via Admin → SIM Range in the left sidebar.** The Admin node is a collapsible accordion group. It must be clicked/expanded before the SIM Range sub-item is interactive.

| Element | Description | Locator Variable | Source |
|---|---|---|---|
| Admin menu | Top-level Admin accordion link in left nav | `${LOC_ADMIN_MENU}` | sim_range_locators.resource |
| SIM Range tab | Top nav tab for SIM Range page | `${LOC_TAB_SIM_RANGE}` | sim_range_locators.resource |
| Tab control | Host for tab content on SIM Range list page | `${LOC_TAB_CONTROL}` | sim_range_locators.resource |
| ICCID/IMSI tab | Tab button for ICCID/IMSI on list page | `${LOC_TAB_ICCID_IMSI}` | sim_range_locators.resource |
| Create SIM Range button | `<a>` tag that navigates to create form | `${LOC_SR_CREATE_BTN}` | sim_range_locators.resource |

### 9.2 Create SIM Range Form — Main Fields

| Element | Description | Locator Variable |
|---|---|---|
| **Pool Name** | Required text input (`name=poolName`, max 50 chars) | `${LOC_SR_POOL_NAME}` |
| **Account dropdown** | Required — selects opco/customer account | `${LOC_SR_ACCOUNT_DD}` |
| **Description** | Required text input (`name=description`, max 500 chars) | `${LOC_SR_DESCRIPTION}` |
| **Pool Count** | Read-only; auto-calculated from range entries | `${LOC_SR_POOL_COUNT}` |
| Assets Type dropdown | Required — visible only when no `currentTab` URL param | `${LOC_SR_ASSETS_TYPE_DD}` |
| SIM Category dropdown | Required for MSISDN mode only | `${LOC_SR_SIM_CATEGORY_DD}` |

### 9.3 Accordion Range Panels

| Element | Description | Locator Variable |
|---|---|---|
| ICCID Range panel | Collapsible section for ICCID ranges | `${LOC_ICCID_PANEL}` |
| IMSI Range panel | Collapsible section for IMSI ranges | `${LOC_IMSI_PANEL}` |
| Add ICCID button | Opens addRangePopup modal | `${LOC_ADD_ICCID_BTN}` |
| Add IMSI button | Opens addImsiRangePopup modal | `${LOC_ADD_IMSI_BTN}` |
| ICCID grid table | Kendo grid showing added ICCID ranges | `${LOC_ICCID_GRID}` |
| IMSI grid table | Kendo grid showing added IMSI ranges | `${LOC_IMSI_GRID}` |

### 9.4 Add ICCID Range Popup (`id=addRangePopup`)

| Element | Description | Locator Variable |
|---|---|---|
| ICCID popup modal | Bootstrap modal for adding ICCID range | `${LOC_ICCID_POPUP}` |
| From input (ICCID) | ICCID start value (17–20 digits) | `${LOC_ICCID_FROM}` |
| To input (ICCID) | ICCID end value (17–20 digits) | `${LOC_ICCID_TO}` |
| Submit (popup) | Enabled when both fields have required digit length | `${LOC_ICCID_POPUP_SUBMIT}` |
| Close (popup) | Clears and dismisses modal | `${LOC_ICCID_POPUP_CLOSE}` |

### 9.5 Add IMSI Range Popup (`id=addImsiRangePopup`)

| Element | Description | Locator Variable |
|---|---|---|
| IMSI popup modal | Bootstrap modal for adding IMSI range | `${LOC_IMSI_POPUP}` |
| From input (IMSI) | IMSI start value (15 digits) | `${LOC_IMSI_FROM}` |
| To input (IMSI) | IMSI end value (15 digits) | `${LOC_IMSI_TO}` |
| Submit (popup) | Enabled when both fields have 15-digit length | `${LOC_IMSI_POPUP_SUBMIT}` |
| Close (popup) | Clears and dismisses modal | `${LOC_IMSI_POPUP_CLOSE}` |

### 9.6 Final Submit and Close (Page-Level)

| Element | Description | Locator Variable |
|---|---|---|
| **Final Submit button** | Enabled when all mandatory fields valid and poolCount > 0 | `${LOC_SR_SUBMIT_BTN}` |
| Final Close button | Navigates back to `/SIMRange` without submitting | `${LOC_SR_CLOSE_BTN}` |

### 9.7 Post-Submission

| Element | Description | Locator Variable |
|---|---|---|
| Success toast | Success notification on creation | `${LOC_SR_TOAST_SUCCESS}` |
| Error toast | Error notification | `${LOC_SR_TOAST_ERROR}` |
| Alert danger | Inline validation error | `${LOC_SR_ALERT_DANGER}` |
| SIM Range list grid | Grid on the `/SIMRange` page post-redirect | `${LOC_SR_GRID}` |

> **Locator priority:** Use `id=` first, then `xpath=//*[@data-testid='...']` for custom React dropdowns, then `xpath=//input[@name='...']` for text inputs. For **scoped popup elements**, always prefix with `//div[@id='<popup-id>']//` to avoid id=prceedBtn ambiguity.

---

## 10. Expected Results

| Step | RF Keyword Used | Expected Outcome |
|---|---|---|
| Manage Devices loaded | `Wait Until Element Is Visible    ${LOC_GRID}` | Device grid visible; starting point confirmed |
| Admin module expanded | `Click Element    ${LOC_ADMIN_TOGGLE}` | Admin sub-menu expands; SIM Range sub-item becomes visible |
| SIM Range sub-item clicked | `Click Element    ${LOC_SIM_RANGE_NAV}` | Page navigates to `/SIMRange` (SIM Range is under Admin module) |
| SIM Range page loaded | `Wait Until Element Is Visible    ${LOC_SIM_RANGE_HDR}` | Tab control container rendered |
| ICCID/IMSI tab selected | `Click Element    ${LOC_ICCID_IMSI_TAB}` | Create SIM Range button appears |
| Create form opened | `Click Element    ${LOC_CREATE_RANGE_BTN}` | URL contains `/CreateSIMRange`; Pool Name input visible |
| Pool Name filled | `Input Text    ${LOC_POOL_NAME}` | Field populated without error |
| Account selected | `Select From List By Index    ${LOC_ACCOUNT_DD}    1` | First account selected in dropdown |
| Description filled | `Input Text    ${LOC_DESCRIPTION}` | Field populated without error |
| Assets Type selected | `Select From List By Label    ${LOC_ASSETS_TYPE_DD}    ICCID/IMSI` | ICCID/IMSI panels become visible |
| ICCID popup opened | `Click Element    ${LOC_ADD_ICCID_BTN}` | `id=addRangePopup` modal visible |
| ICCID range submitted | `Click Element    ${LOC_ICCID_POPUP_SUBMIT}` | Popup dismissed; ICCID grid shows 1 row |
| IMSI popup opened | `Click Element    ${LOC_ADD_IMSI_BTN}` | `id=addImsiRangePopup` modal visible |
| IMSI range submitted | `Click Element    ${LOC_IMSI_POPUP_SUBMIT}` | Popup dismissed; IMSI grid shows 1 row |
| Pool count verified | `Get Value    ${LOC_POOL_COUNT}` | Returns `10` (ICCID and IMSI counts are equal) |
| Final Submit clicked | `Click Element    ${LOC_FINAL_SUBMIT_BTN}` | Form submitted; no client-side error |
| Success toast visible | `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}` | Toast notification displayed |
| Redirected to SIM Range | `Location Should Contain    SIMRange` | URL returns to `/SIMRange` |
| List grid visible | `Wait Until Element Is Visible    ${LOC_RANGE_LIST_TABLE}` | SIM Range list grid rendered |

---

## 11. Negative Test Scenarios

| Scenario ID | Scenario Description | Action Taken | RF Assertion |
|---|---|---|---|
| NEG-01 | Pool Name left blank | Leave `poolName` empty; click Submit | `Element Should Be Disabled    ${LOC_FINAL_SUBMIT_BTN}` or inline error visible |
| NEG-02 | Account not selected | Leave account at default blank; click Submit | `Element Should Be Disabled    ${LOC_FINAL_SUBMIT_BTN}` |
| NEG-03 | Description left blank | Leave `description` empty; click Submit | `Element Should Be Disabled    ${LOC_FINAL_SUBMIT_BTN}` |
| NEG-04 | Assets Type not selected | Leave dropdown at default; click Submit | Submit button remains disabled; panels do not render |
| NEG-05 | No ICCID range added | Skip Add ICCID; attempt Submit | Submit button remains disabled (poolCount stays 0) |
| NEG-06 | ICCID From > ICCID To | Enter From > To in popup; click Submit | `Page Should Contain    From Value` or toast error visible; popup remains open |
| NEG-07 | ICCID count ≠ IMSI count | Add 10-count ICCID, 5-count IMSI | Final Submit stays disabled OR toast error: ICCID/IMSI counts must match |
| NEG-08 | Overlapping ICCID range | Add range 89100…001–010; add 89100…005–015 | Toast error: ICCID Range already exists; duplicate entry rejected |
| NEG-09 | ICCID From has invalid format | Enter `0012345` (starts with 0) or `abc` | Toast error: Invalid ICCID From; popup Submit blocked |
| NEG-10 | ICCID value shorter than 17 digits | Enter 16-digit value in From or To | Popup Submit stays disabled (length validation not met) |
| NEG-11 | IMSI From > IMSI To | Enter From > To in IMSI popup; click Submit | Toast error visible; popup remains open |
| NEG-12 | Overlapping IMSI range | Add overlapping IMSI ranges | Toast error: IMSI Range already exists |
| NEG-13 | Max row count exceeded (20 rows) | Add 21 ICCID ranges | Add button becomes disabled after 20 entries |
| NEG-14 | Submit fails due to network error | Simulate API failure | Toast error displayed; user remains on Create form; no redirect |
| NEG-15 | Session expires during form fill | Leave form idle until session times out | `Location Should Contain    192.168.1.26:7874/` — redirected to login root |

---

## 12. Validation Checks

After `Submit SIM Range` completes, the automation must confirm:

```robot
Validate SIM Range Creation
    # 1. Success notification is visible
    Element Should Be Visible        ${LOC_SUCCESS_TOAST}

    # 2. No error elements on page
    Page Should Not Contain Element
    ...    xpath=//div[contains(@class,'error') or contains(@class,'alert-danger')]

    # 3. Redirected back to SIM Range list (not on Create page)
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    SIMRange
    Location Should Not Contain      CreateSIMRange

    # 4. SIM Range list grid is visible
    Wait Until Element Is Visible    ${LOC_RANGE_LIST_TABLE}    ${TIMEOUT}
    Element Should Be Visible        ${LOC_RANGE_LIST_TABLE}

    Log    SIM Range created and validated successfully    INFO
```

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

### Scoped Locators for Shared `id=prceedBtn`
`id=prceedBtn` appears on **all three range popups** and on the **final page Submit button**. Always use the parent modal ID to scope the selector:
```robot
# ICCID popup submit (correct)
xpath=//div[@id='addRangePopup']//button[contains(@class,'btn-custom-color')]

# Final page submit (correct)
xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[@id='prceedBtn']

# NEVER use bare id=prceedBtn — it will match the wrong element
```

### Pool Count Equals Constraint (ICCID/IMSI Mode)
The application enforces that **ICCID total count = IMSI total count** before allowing the final Submit. Always add matching ranges:
```
ICCID: from=89100000000000001 to=89100000000000010 → count=10
IMSI:  from=424010000000001   to=424010000000010   → count=10
Pool Count auto-set to 10 ✓
```

### Accordion Panels Must Be Expanded Before Interaction
The IMSI and MSISDN panels start collapsed. Click the accordion toggle link before attempting to interact with Add buttons:
```robot
# Expand IMSI panel
Click Element    xpath=//a[@href='#collapseTwo']
Wait Until Element Is Visible    ${LOC_IMSI_PANEL}    ${TIMEOUT}

# Expand MSISDN panel
Click Element    xpath=//a[@href='#collapseThree']
Wait Until Element Is Visible    ${LOC_MSISDN_PANEL}    ${TIMEOUT}
```

### Popup Submit Enable Condition
The popup Submit button (`btn-custom-color` inside each popup) is **conditionally enabled** based on field length:
- ICCID popup: enabled when both `fromInput` and `toInput` reach the required length (18 digits minus any prefix/suffix)
- IMSI popup: enabled when both `fromInputImsi` and `toInputImsi` are exactly 15 digits
- MSISDN popup: enabled when both `fromInputMsisdn` and `toInputMsisdn` have ≥ 10 digits

Always use `Wait Until Element Is Enabled` before clicking the popup submit.

### Navigating to SIM Range (Admin Module Sub-Item)
SIM Range is **not** a top-level navigation item. It is nested inside the **Admin** module accordion in the left sidebar. The Admin item must be **expanded first** before the SIM Range link is interactable:
```robot
# Step 1: Expand Admin accordion
Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}
Click Element                    ${LOC_ADMIN_TOGGLE}
# Step 2: Click SIM Range sub-item (only visible after Admin is expanded)
Wait Until Element Is Visible    ${LOC_SIM_RANGE_NAV}    ${TIMEOUT}
Click Element                    ${LOC_SIM_RANGE_NAV}
```
If Admin is **already expanded** (e.g. on a second test run where the nav state is persisted), clicking the toggle again will collapse it. Use `Run Keyword And Return Status    Element Should Be Visible    ${LOC_SIM_RANGE_NAV}` to check if the sub-menu is already visible before clicking the toggle.

### Assets Type Dropdown Visibility
When navigating to `/CreateSIMRange?currentTab=0`, the Assets Type dropdown is hidden and `assetsTypes` is pre-set to `"1"` (ICCID/IMSI) automatically. Use `Run Keyword And Return Status` to check visibility before attempting selection — this avoids failures caused by a hidden element.

### Page Load Retry
Wrap page transition waits with `Wait Until Keyword Succeeds` to handle transient network delays:
```robot
Wait Until Keyword Succeeds    3x    5s
...    Location Should Contain    SIMRange
```

### Scroll Before Final Submit
The Submit button is at the bottom of the form. Always scroll before interacting:
```robot
Scroll Element Into View    ${LOC_FINAL_SUBMIT_BTN}
Wait Until Element Is Enabled    ${LOC_FINAL_SUBMIT_BTN}    ${TIMEOUT}
Click Element    ${LOC_FINAL_SUBMIT_BTN}
```

### Capturing Kendo Grid Row Count
To assert a range was added to the Kendo grid:
```robot
Wait Until Element Is Visible    ${LOC_ICCID_GRID}    ${TIMEOUT}
${rows}=    Get Element Count    xpath=//div[@id='iccidRangeTable']//table//tbody/tr
Should Be True    ${rows} >= 1
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

This specification is written for **Robot Framework + SeleniumLibrary** to align with TC_001, TC_002, and TC_003. The table below describes how the same test can be implemented in other frameworks if needed.

| Framework | Language | Approach | SSL Handling | Notes |
|---|---|---|---|---|
| **Robot Framework + SeleniumLibrary** | Python (keyword DSL) | `Select From List By Index`, `Click Element`, `Wait Until Element Is Enabled` | `ChromeOptions` via `Evaluate` | **Recommended** — consistent with TC_001 / TC_002 / TC_003 |
| **Playwright (Python)** | Python | `page.locator()`, `page.select_option()`, `expect(locator).to_be_enabled()` | `ignore_https_errors=True` in browser context | Best for modern React SPAs; built-in auto-wait |
| **Selenium (Python)** | Python | `WebDriverWait`, `Select` class, `find_element` | `ChromeOptions` with `--ignore-certificate-errors` | Widely adopted; requires explicit wait management |
| **Cypress** | JavaScript | `cy.get()`, `cy.select()`, `cy.within()` for scoped popup interactions | `chromeWebSecurity: false` in `cypress.config.js` | Front-end focused; `cy.within()` handles popup scoping cleanly |

---

## 15. Example Playwright Script

```python
import pytest
from playwright.sync_api import Page, expect

# ── Configuration ──────────────────────────────────────────────────────────────
BASE_URL    = "https://192.168.1.26:7874"
USERNAME    = "ksa_opco"
PASSWORD    = "Admin@123"

# ── Test data ──────────────────────────────────────────────────────────────────
POOL_NAME        = "Test SIM Pool"
DESCRIPTION      = "Automation test SIM range"
ICCID_FROM       = "89100000000000001"
ICCID_TO         = "89100000000000010"
IMSI_FROM        = "424010000000001"
IMSI_TO          = "424010000000010"
EXPECTED_COUNT   = "10"

# ── Confirmed Locators (from CreateSIMRange.js source) ────────────────────────
# Main form fields
LOC_POOL_NAME      = "input[name='poolName']"                   # line 1253
LOC_ACCOUNT_DD     = "[data-testid='AectAccoor']"               # line 1275
LOC_DESCRIPTION    = "input[name='description']"               # line 1293
LOC_POOL_COUNT     = "input[name='poolCount']"                  # line 1390
LOC_ASSETS_TYPE    = "[data-testid='tassetsTypes']"             # line 1439
LOC_SIM_CATEGORY   = "[data-testid='tSIMCacoor']"               # line 1414

# ICCID popup (scoped to #addRangePopup — line 1542)
LOC_ICCID_POPUP    = "#addRangePopup"
LOC_ICCID_FROM     = "#addRangePopup input[name='fromInput']"   # line 1571
LOC_ICCID_TO       = "#addRangePopup input[name='toInput']"     # line 1596
LOC_ICCID_SUBMIT   = "#addRangePopup button.btn-custom-color"   # line 1627

# IMSI popup (scoped to #addImsiRangePopup — line 1640)
LOC_IMSI_POPUP     = "#addImsiRangePopup"
LOC_IMSI_FROM      = "#addImsiRangePopup input[name='fromInputImsi']"   # line 1669
LOC_IMSI_TO        = "#addImsiRangePopup input[name='toInputImsi']"     # line 1695
LOC_IMSI_SUBMIT    = "#addImsiRangePopup button.btn-custom-color"       # line 1706

# MSISDN popup (scoped to #addMsisdnRangePopup — line 1719)
LOC_MSISDN_POPUP   = "#addMsisdnRangePopup"
LOC_MSISDN_FROM    = "#addMsisdnRangePopup input[name='fromInputMsisdn']"   # line 1737
LOC_MSISDN_TO      = "#addMsisdnRangePopup input[name='toInputMsisdn']"     # line 1751
LOC_MSISDN_SUBMIT  = "#addMsisdnRangePopup button.btn-custom-color"         # line 1763

# Final page-level submit — scoped to avoid id=prceedBtn collision (line 1522)
LOC_FINAL_SUBMIT   = ".gc-form-buttons-wrapper button#prceedBtn"
LOC_ICCID_GRID     = "#iccidRangeTable"                         # line 1478
LOC_IMSI_GRID      = "#imsiRangeTable"                          # line 1493


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


def test_create_sim_range(page: Page) -> None:
    # ── Step 1: Login and confirm Manage Devices starting point ────────────────
    login(page)
    page.locator("#gridData").wait_for(state="visible")

    # ── Step 2: Navigate to SIM Range via Admin module in left nav ────────────
    # SIM Range is a sub-item under the Admin accordion — expand Admin first
    nav_panel = page.locator("//div[contains(@class,'sidebar')]")
    nav_panel.wait_for(state="visible")
    # Click Admin accordion toggle to expand its sub-menu
    admin_toggle = page.locator("//span[contains(text(),'Admin')]/parent::a")
    admin_toggle.scroll_into_view_if_needed()
    admin_toggle.click()
    # Wait for SIM Range sub-item to appear within the expanded Admin sub-menu
    sim_range_nav = page.locator(
        "//ul[contains(@class,'nav-second-level') or contains(@class,'sub-menu')]//a[contains(@href,'SIMRange')]"
    )
    sim_range_nav.wait_for(state="visible")
    sim_range_nav.click()
    page.wait_for_url("**SIMRange**")
    page.locator(".tabbarControl").wait_for(state="visible")

    # ── Step 3: Select ICCID/IMSI tab ─────────────────────────────────────────
    page.locator("li[value='0']").click()
    create_btn = page.locator("a.btn-custom-color.cursor-pointer", has_text="SIM Range")
    create_btn.wait_for(state="visible")

    # ── Step 4: Open Create SIM Range form ────────────────────────────────────
    create_btn.click()
    page.wait_for_url("**CreateSIMRange**")
    page.locator(LOC_POOL_NAME).wait_for(state="visible")

    # ── Step 5: Fill Pool Name ─────────────────────────────────────────────────
    page.locator(LOC_POOL_NAME).fill(POOL_NAME)

    # ── Step 6: Select Account ────────────────────────────────────────────────
    page.locator(LOC_ACCOUNT_DD).wait_for(state="visible")
    page.locator(LOC_ACCOUNT_DD).select_option(index=1)

    # ── Step 7: Fill Description ──────────────────────────────────────────────
    page.locator(LOC_DESCRIPTION).fill(DESCRIPTION)

    # ── Step 8: Select Assets Type (only if visible) ──────────────────────────
    assets_dd = page.locator(LOC_ASSETS_TYPE)
    if assets_dd.is_visible():
        assets_dd.select_option(label="ICCID/IMSI")

    # ── Step 9: Add ICCID Range ───────────────────────────────────────────────
    iccid_panel = page.locator("#definecondition")
    iccid_panel.wait_for(state="visible")
    # Click the ICCID Add button
    add_iccid_btn = page.locator("button.add-action-button[title*='ICCID']")
    add_iccid_btn.wait_for(state="visible")
    add_iccid_btn.click()
    # Fill popup
    page.locator(LOC_ICCID_POPUP).wait_for(state="visible")
    page.locator(LOC_ICCID_FROM).fill(ICCID_FROM)
    page.locator(LOC_ICCID_TO).fill(ICCID_TO)
    expect(page.locator(LOC_ICCID_SUBMIT)).to_be_enabled()
    page.locator(LOC_ICCID_SUBMIT).click()
    page.locator(LOC_ICCID_POPUP).wait_for(state="hidden")
    page.locator(LOC_ICCID_GRID).wait_for(state="visible")

    # ── Step 10: Add IMSI Range ───────────────────────────────────────────────
    # Expand IMSI accordion
    page.locator("a[href='#collapseTwo']").click()
    imsi_panel = page.locator("#collapseTwo")
    imsi_panel.wait_for(state="visible")
    add_imsi_btn = page.locator("button.add-action-button[title*='IMSI']")
    add_imsi_btn.wait_for(state="visible")
    add_imsi_btn.click()
    # Fill popup
    page.locator(LOC_IMSI_POPUP).wait_for(state="visible")
    page.locator(LOC_IMSI_FROM).fill(IMSI_FROM)
    page.locator(LOC_IMSI_TO).fill(IMSI_TO)
    expect(page.locator(LOC_IMSI_SUBMIT)).to_be_enabled()
    page.locator(LOC_IMSI_SUBMIT).click()
    page.locator(LOC_IMSI_POPUP).wait_for(state="hidden")
    page.locator(LOC_IMSI_GRID).wait_for(state="visible")

    # ── Step 11: Verify Pool Count auto-calculated ────────────────────────────
    pool_count = page.locator(LOC_POOL_COUNT).input_value()
    assert pool_count == EXPECTED_COUNT, f"Expected pool count {EXPECTED_COUNT}, got {pool_count}"

    # ── Step 12: Submit the SIM Range ─────────────────────────────────────────
    final_submit = page.locator(LOC_FINAL_SUBMIT)
    final_submit.scroll_into_view_if_needed()
    expect(final_submit).to_be_enabled()
    final_submit.click()

    # ── Step 13: Validate success and redirect ────────────────────────────────
    expect(page.locator(".toast-success")).to_be_visible()
    page.wait_for_url("**SIMRange**")
    assert "CreateSIMRange" not in page.url, "Should have redirected away from Create page"
    print("SIM Range created successfully")
```

> **Run command for Playwright:**
> ```bash
> pytest tests/test_create_sim_range.py --headed
> ```

---

## 16. Success Validation Checklist

- [ ] `Wait Until Element Is Visible    ${LOC_GRID}` passes — Manage Devices starting point confirmed
- [ ] `Scroll Element Into View    ${LOC_ADMIN_TOGGLE}` executes without error
- [ ] `Click Element    ${LOC_ADMIN_TOGGLE}` expands Admin module — SIM Range sub-item becomes visible
- [ ] `Wait Until Element Is Visible    ${LOC_SIM_RANGE_NAV}` passes — SIM Range sub-item rendered under Admin
- [ ] `Click Element    ${LOC_SIM_RANGE_NAV}` executes without error
- [ ] `Location Should Contain    SIMRange` passes after SIM Range sub-item click
- [ ] `Wait Until Element Is Visible    ${LOC_SIM_RANGE_HDR}` passes
- [ ] `Click Element    ${LOC_ICCID_IMSI_TAB}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_CREATE_RANGE_BTN}` passes
- [ ] `Click Element    ${LOC_CREATE_RANGE_BTN}` navigates to `/CreateSIMRange`
- [ ] `Wait Until Element Is Visible    ${LOC_POOL_NAME}` passes — form loaded
- [ ] `Input Text    ${LOC_POOL_NAME}    ${POOL_NAME}` executes without error
- [ ] `Select From List By Index    ${LOC_ACCOUNT_DD}    1` executes without error
- [ ] `Input Text    ${LOC_DESCRIPTION}    ${DESCRIPTION}` executes without error
- [ ] Assets Type selected (if dropdown visible)
- [ ] `Click Element    ${LOC_ADD_ICCID_BTN}` opens ICCID popup
- [ ] `Wait Until Element Is Visible    ${LOC_ICCID_POPUP}` passes
- [ ] `Input Text    ${LOC_ICCID_FROM}    ${ICCID_FROM}` and `${LOC_ICCID_TO}    ${ICCID_TO}` execute
- [ ] `Wait Until Element Is Enabled    ${LOC_ICCID_POPUP_SUBMIT}` passes
- [ ] ICCID popup dismissed and `id=iccidRangeTable` shows 1 row
- [ ] `Click Element    xpath=//a[@href='#collapseTwo']` expands IMSI panel
- [ ] `Click Element    ${LOC_ADD_IMSI_BTN}` opens IMSI popup
- [ ] `Input Text    ${LOC_IMSI_FROM}    ${IMSI_FROM}` and `${LOC_IMSI_TO}    ${IMSI_TO}` execute
- [ ] `Wait Until Element Is Enabled    ${LOC_IMSI_POPUP_SUBMIT}` passes
- [ ] IMSI popup dismissed and `id=imsiRangeTable` shows 1 row
- [ ] `Get Value    ${LOC_POOL_COUNT}` returns `10` (matches `${EXPECTED_POOL_COUNT}`)
- [ ] `Scroll Element Into View    ${LOC_FINAL_SUBMIT_BTN}` executes without error
- [ ] `Wait Until Element Is Enabled    ${LOC_FINAL_SUBMIT_BTN}` passes
- [ ] `Click Element    ${LOC_FINAL_SUBMIT_BTN}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}` passes within `${TIMEOUT}`
- [ ] `Location Should Contain    SIMRange` passes (redirect confirmed)
- [ ] `Location Should Not Contain    CreateSIMRange` passes
- [ ] `Wait Until Element Is Visible    ${LOC_RANGE_LIST_TABLE}` passes
- [ ] No `FAIL` entries in `output.xml`
- [ ] `log.html` and `report.html` generated in `results/` directory

---

## 17. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-06 | CMP QA Team | Initial Robot Framework specification for TC_004 Create SIM Range; aligned to TC_001, TC_002, and TC_003 in structure, credential format, keyword style, variable naming, locator strategy, and retry/screenshot patterns; all locators confirmed against `CreateSIMRange.js` and `ManageSIMRange.js` source; includes scoped locators for shared `id=prceedBtn`, pool count equality constraint documentation, accordion expand handling, conditional Assets Type dropdown logic, Kendo grid interaction notes, complete `.robot` file, Playwright reference script, and full negative/validation coverage |
| 1.1 | 2026-03-06 | CMP QA Team | Corrected navigation flow: SIM Range is a sub-item under the **Admin module** accordion in the left sidebar — not a top-level nav item; added `${LOC_ADMIN_TOGGLE}` locator; updated Step 2, `Navigate To SIM Range Module` keyword, automation flow diagram, Section 9.1 locator table, Expected Results table, Success Validation Checklist, Playwright reference script, and Automation Considerations with Admin accordion expand guidance |
