# Automation Test Specification – Create SIM Range (MSISDN)

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 14)*
**Date:** 2026-03-09
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md · TC_003_Create_SIM_Order_RF.md · TC_004_Create_SIM_Range_RF.md · TC_005_Create_SIM_Pool_RF.md · TC_006_Create_Device_Plan_RF.md · TC_007_Create_APN_RF.md · TC_008_Create_IP_Pool_RF.md · TC_009_Create_Label_RF.md · TC_010_Create_IP_Whitelisting_RF.md · TC_011_Create_Rule_RF.md

---

## 1. Objective

This test validates the end-to-end **Create SIM Range (MSISDN)** workflow on the CMP web application. The automation begins from the **Manage Devices** page (post-login) and covers:

1. Navigating to the **SIM Range** module via the left-side navigation panel
2. Selecting the **MSISDN** tab on the SIM Range listing page (`currentTab=1`)
3. Clicking the **Create SIM Range** button, which navigates to `/CreateSIMRange?currentTab=1`
4. Completing all mandatory header fields: **Pool Name**, **Account**, **Description**, and **SIM Category** (MSISDN-specific)
5. Verifying that the **Assets Type** dropdown is pre-set and hidden (MSISDN is auto-selected from the URL parameter `currentTab=1`)
6. Opening the **Add MSISDN Range** popup and entering a valid **MSISDN From/To** numeric range (both ≥ 10 digits, ≤ 15 digits)
7. Submitting the popup and confirming the **Pool Count** is auto-calculated
8. Clicking the final **Submit** button and verifying the **success toast notification** and redirect back to `/SIMRange`

This test ensures the MSISDN-specific SIM Range creation workflow is functional, all mandatory fields are validated, MSISDN range conflict detection works correctly, and the system correctly stores and acknowledges the submitted SIM Range.

> **Relationship to TC_004:** `TC_004_Create_SIM_Range_RF.md` covers the **ICCID/IMSI** asset type flow (Tab 0). This document (`TC_012`) exclusively covers the **MSISDN** asset type flow (Tab 1), which has a distinct set of fields, a different popup, and separate validation rules.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **SIM Range List URL (MSISDN tab)** | `https://192.168.1.26:7874/SIMRange?currentTab=1` |
| **Create SIM Range URL (MSISDN)** | `https://192.168.1.26:7874/CreateSIMRange?currentTab=1` |
| **Post-Submit Redirect URL** | `https://192.168.1.26:7874/SIMRange` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |
| **SIM Range Location in UI** | **Admin module → SIM Range** (left-side navigation; SIM Range is a sub-item under the Admin accordion/menu group) |
| **MSISDN Tab Index** | Tab 1 (`value="1"` on the `<li>` element within `<ul id="tabHeading">`) |
| **Listing Grid ID** | `ManageSIMRangeGrid` (within `div#gridData`) |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` and has landed on the **Manage Devices** page
  - *(Use `Login To Application` and `Navigate To Manage Devices` keywords from `TC_001_Login_Navigate_RF.md`)*
- The `ksa_opco` user has **RW (Read-Write)** permission to access the **SIM Range** module
- The **SIM Range** module is enabled and visible in the left-side navigation panel
- The **MSISDN** tab (`currentTab=1`) is visible on the SIM Range listing page
- At least one valid **Account** exists in the system for SIM Range creation
- The MSISDN range values used in the test are **not already registered** in the system (no overlap with existing MSISDN ranges)
- **SIM Category** options (830, 831, 05X) are configured and available *(only appears when `SIM_CATEGORY_PERMISSION()` returns `false`)*
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
# Run all SIM Range MSISDN tests
python run_tests.py tests/sim_range_msisdn_tests.robot

# Run by module name
python run_tests.py --suite "SIM Range MSISDN"

# Run a single test
python run_tests.py tests/sim_range_msisdn_tests.robot --test "TC_SRM_001*"
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
├── tests\sim_range_msisdn_tests.robot
├── run_tests.py
└── tasks.csv
```

---

## 5. Test Data

| Field | Sample Value | Notes |
|---|---|---|
| **Username** | `ksa_opco` | Same credentials as all prior TCs |
| **Password** | `Admin@123` | Same credentials as all prior TCs |
| **Pool Name** | `Test MSISDN SIM Pool` | Max 50 characters; free text |
| **Account** | *(First available)* | Populated via API; parameterise via variable file |
| **Description** | `Automation test MSISDN SIM range` | Max 500 characters; free text |
| **SIM Category** | `830` | Options: `830` (id=1), `831` (id=2), `05X` (id=3); only shown when `SIM_CATEGORY_PERMISSION()` is false |
| **Assets Type** | `MSISDN` (id=2) | Pre-selected and hidden when navigating via `currentTab=1` |
| **MSISDN From** | `966500000001` | 10–15 digits; numeric only; must be less than MSISDN To |
| **MSISDN To** | `966500000010` | 10–15 digits; numeric only; must be ≥ From value |
| **Expected Pool Count** | `10` | Auto-calculated: `(To − From + 1)`, displayed in read-only Pool Count field |
| **Expected Post-Submit URL** | `/SIMRange` | Redirected back to the SIM Range list page |
| **Expected Success Toast** | Server-returned success message (`response.errorMessage` when `errorCode === 0`) | |

> Parameterise all test data values via a Robot Framework variable file (`variables.robot` or `--variablefile`) to support multiple environments without modifying test files.
>
> **Important:** Unlike the ICCID/IMSI flow, MSISDN ranges do not require matching ICCID and IMSI counts. The Pool Count is determined solely by the MSISDN ranges entered. Multiple MSISDN ranges can be added (up to 20 rows) and their counts are summed automatically.

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

**Variables** (from `sim_range_variables.py`): `MSISDN_POOL_NAME`, `MSISDN_DESCRIPTION`, `VALID_MSISDN_FROM`, `VALID_MSISDN_TO`, `EXPECTED_MSISDN_POOL_COUNT`, `SIM_CATEGORY_VALUE`, `CREATE_SIM_RANGE_MSISDN_URL`, `SIM_RANGE_MSISDN_URL`, `MSISDN_TOO_SHORT`, `MSISDN_FROM_GREATER_THAN_TO_FROM`, `MSISDN_FROM_GREATER_THAN_TO_TO`, `OVERLAPPING_MSISDN_FROM`, `OVERLAPPING_MSISDN_TO`, `MSISDN_EXCEEDS_MAX_LENGTH`, `SQL_INJECTION_POOL_NAME`, `SPECIAL_CHARS_POOL_NAME`, `POOL_NAME_EXCEEDS_MAX`, `DESCRIPTION_EXCEEDS_MAX`.

**Locators** (from `sim_range_locators.resource`): `LOC_SR_POOL_NAME`, `LOC_SR_ACCOUNT_DD`, `LOC_SR_DESCRIPTION`, `LOC_SR_POOL_COUNT`, `LOC_SR_SIM_CATEGORY_DD`, `LOC_MSISDN_PANEL`, `LOC_ADD_MSISDN_BTN`, `LOC_MSISDN_POPUP`, `LOC_MSISDN_FROM`, `LOC_MSISDN_TO`, `LOC_MSISDN_POPUP_SUBMIT`, `LOC_MSISDN_POPUP_CLOSE`, `LOC_MSISDN_GRID`, `LOC_MSISDN_GRID_ROW`, `LOC_SR_GRID`, `LOC_SR_CREATE_BTN`, `LOC_SR_SUBMIT_BTN`, `LOC_SR_TOAST_SUCCESS`, `LOC_SR_TOAST_ERROR`, `LOC_SR_ALERT_DANGER`, `LOC_TAB_MSISDN`, `LOC_SR_ASSETS_TYPE_DD`.

**Keywords** (from `sim_range_keywords.resource`): `Login And Navigate To Create SIM Range MSISDN`, `Login And Navigate To SIM Range MSISDN List`, `Fill MSISDN SIM Range Header`, `Fill MSISDN SIM Range With Ranges`, `Add MSISDN Range`, `Open MSISDN Popup`, `Open MSISDN Popup And Enter Range`, `Close MSISDN Popup Without Submitting`, `Verify Pool Count`, `Verify Pool Count Is Zero Or Empty`, `Submit SIM Range Form`, `Verify SIM Range Created Successfully`, `Verify Cancel Redirects To SIM Range List`, `Verify MSISDN Grid Has Rows`, `Verify MSISDN Popup Submit Is Disabled`, `Verify MSISDN Popup Is Closed`, `Verify Assets Type Is Hidden`, `Select SIM Category If Visible`, `Verify Submit Button Is Disabled`, `Verify Error Toast Or Popup Still Open`, `Verify Negative SIM Range Outcome`, `Enter Pool Name`, `Select Account From Dropdown`, `Enter SIM Range Description`.

---

## 7. Automation Flow – Step-by-Step

### Phase 1: Navigate to SIM Range MSISDN Listing

#### Step 1 – Navigate to SIM Range Module

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 1.1 | Click SIM Range link in left navigation | `xpath=//a[contains(@href,'/SIMRange') and not(contains(@href,'Create')) and not(contains(@href,'Log')) and not(contains(@href,'Audit'))]` | May need to expand Admin accordion first |
| 1.2 | Wait for SIM Range page to load | `Wait Until Location Contains    /SIMRange` | |
| 1.3 | Wait for tab heading to render | `Wait Until Element Is Visible    xpath=//ul[@id='tabHeading']` | Tab component renders asynchronously |

#### Step 2 – Select MSISDN Tab

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 2.1 | Click the MSISDN tab | `xpath=//ul[@id='tabHeading']//li[@value='1']` | Switches active component to `SIMRangeMSISDN`; URL updates to `?currentTab=1` |
| 2.2 | Wait for MSISDN grid to appear | `Wait Until Element Is Visible    id=ManageSIMRangeGrid` | `SIMRangeMSISDN` renders the grid on mount |
| 2.3 | Verify URL contains MSISDN tab | `Wait Until Location Contains    currentTab=1` | Confirms tab routing is correct |

#### Step 3 – Open Create SIM Range Form

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 3.1 | Click **Create SIM Range** button | `xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Create')]` | Rendered by `createSIMRangeBtn()`; only visible with RW permission |
| 3.2 | Wait for Create page to load | `Wait Until Location Contains    /CreateSIMRange?currentTab=1` | |
| 3.3 | Wait for Pool Name input | `Wait Until Element Is Visible    xpath=//input[@name='poolName']` | Confirms form is rendered |

---

### Phase 2: Fill Mandatory Header Fields

#### Step 4 – Enter Pool Name

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 4.1 | Wait for Pool Name input | `Wait Until Element Is Visible    xpath=//input[@name='poolName']` | |
| 4.2 | Click and clear Pool Name | `Click Element    xpath=//input[@name='poolName']` | |
| 4.3 | Type Pool Name | `Input Text    xpath=//input[@name='poolName']    Test MSISDN SIM Pool` | Max 50 chars; `removeSpecialChar` applied on change |

#### Step 5 – Select Account

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 5.1 | Wait for Account dropdown to be populated | `Wait Until Element Is Visible    xpath=//select[@name='accountId']` | Account list loaded via `getAccountList(3)` API call on mount |
| 5.2 | Wait for options to appear | `Wait Until Page Contains Element    xpath=//select[@name='accountId']/option[2]` | Option [1] is the default placeholder; [2] is the first real account |
| 5.3 | Select first available Account | `Select From List By Index    xpath=//select[@name='accountId']    1` | Index 1 = first account option after placeholder |
| 5.4 | Verify account selected | `Wait Until Element Is Enabled    xpath=//input[@name='poolName']` | No field lock occurs; just a state update on `accountId` |

> **Note:** If `SIMRange.opcoSelectedByDefault` is true and `accountTypeId == 3`, the account is pre-selected and the dropdown is disabled. In that case, skip Step 5.2–5.3.

#### Step 6 – Enter Description

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 6.1 | Wait for Description input | `Wait Until Element Is Visible    xpath=//input[@name='description']` | |
| 6.2 | Click and type Description | `Input Text    xpath=//input[@name='description']    Automation test MSISDN SIM range` | Max 500 chars |

#### Step 7 – Verify Pool Count is Initialised to "0" (Read-Only)

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 7.1 | Check Pool Count value | `${pool_count}=    Get Value    xpath=//input[@name='poolCount']` | Should be `"0"` until MSISDN ranges are added |
| 7.2 | Verify Pool Count is disabled | `Element Should Be Disabled    xpath=//input[@name='poolCount']` | `disabled={!isPoolEnable}` — always disabled (isPoolEnable is never set to true in code) |

> **Note:** The Pool Count field is controlled by `isPoolEnable` state (defaults to `false` and is only set `false` after popup submit). The field remains **read-only throughout**; its value updates automatically as MSISDN ranges are added.

#### Step 8 – Select SIM Category *(MSISDN-specific; skip if field is hidden)*

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 8.1 | Check SIM Category visibility | `Run Keyword And Return Status    Element Is Visible    xpath=//select[@name='SIMCategory']` | Only visible when `assetsTypes === "2"` AND `SIM_CATEGORY_PERMISSION() === false` |
| 8.2 | If visible — wait for it to be present | `Wait Until Element Is Visible    xpath=//select[@name='SIMCategory']` | `data-testid=tSIMCacoor` |
| 8.3 | Select SIM Category "830" | `Select From List By Value    xpath=//select[@name='SIMCategory']    1` | id=1 → "830"; id=2 → "831"; id=3 → "05X" |

> **Important:** SIM Category is mandatory for MSISDN flow when it is visible. The `isFinalSubmit()` check requires `SIMCategory !== ""`. If the field is hidden (permission-based), it remains at the default value set during Assets Type selection.

---

### Phase 3: Add MSISDN Range via Popup

#### Step 9 – Open MSISDN Range Accordion Panel

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 9.1 | Verify MSISDN accordion panel is visible | `Wait Until Element Is Visible    xpath=//div[@id='headingThree']` | Panel is visible when `assetsTypes !== ""` and `assetsTypes !== "selectAssetsTypes"` |
| 9.2 | Click to expand MSISDN accordion | `Click Element    xpath=//div[@id='headingThree']//a[@role='button']` | Targets the `<a>` with `href="#collapseThree"`; Bootstrap collapse toggle |
| 9.3 | Wait for collapse content | `Wait Until Element Is Visible    xpath=//div[@id='collapseThree']` | Panel content becomes visible after toggle |
| 9.4 | Verify Add MSISDN Range button is enabled | `Wait Until Element Is Enabled    xpath=//div[@id='collapseThree']//button[contains(@class,'add-action-button')]` | `disabled={!isAddMsisdnEnable}` — starts enabled; max 20 rows |

#### Step 10 – Click Add MSISDN Range Button

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 10.1 | Click **+Add** button in MSISDN Range panel | `Click Element    xpath=//div[@id='collapseThree']//button[contains(@class,'add-action-button')]` | Triggers `addMSISDNRange()` → opens Bootstrap modal `#addMsisdnRangePopup` |
| 10.2 | Wait for MSISDN popup to appear | `Wait Until Element Is Visible    id=addMsisdnRangePopup` | Modal uses Bootstrap with `backdrop="static"` |
| 10.3 | Verify From field is present | `Wait Until Element Is Visible    xpath=//div[@id='addMsisdnRangePopup']//input[@name='fromInputMsisdn']` | |

#### Step 11 – Enter MSISDN From and To Values

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 11.1 | Enter MSISDN From value | `Input Text    xpath=//div[@id='addMsisdnRangePopup']//input[@name='fromInputMsisdn']    966500000001` | Numeric only; 10–15 digits; `maxLength=15` |
| 11.2 | Trigger `oninput` max-length check | `Press Keys    xpath=//div[@id='addMsisdnRangePopup']//input[@name='fromInputMsisdn']    RETURN` | Needed to trigger `inputHandlerMsisdn` which also fires on change |
| 11.3 | Enter MSISDN To value | `Input Text    xpath=//div[@id='addMsisdnRangePopup']//input[@name='toInputMsisdn']    966500000010` | Must be ≥ From; `maxLength=15` |
| 11.4 | Trigger `oninput` max-length check | `Press Keys    xpath=//div[@id='addMsisdnRangePopup']//input[@name='toInputMsisdn']    RETURN` | |
| 11.5 | Verify popup Submit button is enabled | `Wait Until Element Is Enabled    xpath=//div[@id='addMsisdnRangePopup']//button[@id='prceedBtn']` | Enabled when both `fromInputMsisdn.length >= 10` AND `toInputMsisdn.length >= 10` |

> **Validation Rule for Popup Submit enablement (`inputHandlerMsisdn`):**
> ```
> isPopupSubmitMsisdn = false  (Submit ENABLED)  ←→  fromInputMsisdn.length >= 10 AND toInputMsisdn.length >= 10
> isPopupSubmitMsisdn = true   (Submit DISABLED) ←→  either field has fewer than 10 digits
> ```

#### Step 12 – Submit MSISDN Range Popup

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 12.1 | Click **Submit** in MSISDN popup | `Click Element    xpath=//div[@id='addMsisdnRangePopup']//button[@id='prceedBtn']` | Triggers `msisdnSubmit()` |
| 12.2 | Wait for popup to close | `Wait Until Element Is Not Visible    id=addMsisdnRangePopup` | `msisdnSubmit` calls `$("#addMsisdnRangePopup").modal("hide")` on success |
| 12.3 | Wait for MSISDN range table to appear | `Wait Until Element Is Visible    id=msisdnRangeTable` | `isMsisdnTable` state becomes `true` after first entry |
| 12.4 | Verify one row in MSISDN table | `Wait Until Page Contains Element    xpath=//div[@id='msisdnRangeTable']//tr[@data-uid]` | Kendo Grid row present in MSISDN range table |

#### Step 13 – Verify Pool Count Auto-Calculation

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 13.1 | Read Pool Count value | `${pool_count}=    Get Value    xpath=//input[@name='poolCount']` | `calculatePoolCount()` is called after popup submit |
| 13.2 | Verify Pool Count equals expected value | `Should Be Equal As Strings    ${pool_count}    10` | `(966500000010 − 966500000001 + 1) = 10` |

---

### Phase 4: Final Submission

#### Step 14 – Verify Main Submit Button is Enabled

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 14.1 | Wait for main Submit button to become enabled | `Wait Until Element Is Enabled    xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[@id='prceedBtn']` | `isFinalSubmitEnable` = true when: `description`, `SIMCategory`, `assetsTypes`, `poolName` all non-empty; `poolCount !== "0"`; `accountId` is set |

> **`isFinalSubmit()` Conditions (all must be met):**
> - `poolName !== ""`
> - `description !== ""`
> - `SIMCategory !== ""` and `SIMCategory !== "selectSIMCategory"`
> - `assetsTypes !== ""` and `assetsTypes !== "selectAssetsTypes"`
> - `poolCount !== "0"` ← at least one MSISDN range must be added
> - `accountId` is set and non-zero

#### Step 15 – Submit the Form

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 15.1 | Click main **Submit** button | `Click Element    xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[@id='prceedBtn']` | Triggers `submitSimRange()` |
| 15.2 | Wait for success toast | `Wait Until Page Contains Element    xpath=//div[contains(@class,'Toastify__toast--success')]` | API response `errorCode === 0` triggers `toast.success(response.errorMessage)` |
| 15.3 | Verify toast message (optional) | `Element Should Contain    xpath=//div[contains(@class,'Toastify__toast--success')]    ${EXPECTED_SUCCESS_MESSAGE}` | Success message text comes from server response |
| 15.4 | Wait for redirect to SIM Range list | `Wait Until Location Contains    /SIMRange` | `history.push("/SIMRange")` called on success |
| 15.5 | Verify MSISDN grid is displayed | `Wait Until Element Is Visible    id=ManageSIMRangeGrid` | Confirms redirect to listing page |

---

## 8. Test Case List (from `sim_range_msisdn_tests.robot`)

| Test ID | Test Name | Tags |
|---------|-----------|------|
| TC_SRM_001 | Create MSISDN SIM Range Happy Path | smoke, regression, positive, sim_range, msisdn |
| TC_SRM_002 | Verify MSISDN Tab Selection Shows Grid | smoke, regression, positive, sim_range, msisdn |
| TC_SRM_003 | Verify Create MSISDN SIM Range Page Elements Visible | smoke, regression, positive, sim_range, msisdn |
| TC_SRM_004 | Verify Assets Type Is Hidden For MSISDN Flow | regression, positive, sim_range, msisdn |
| TC_SRM_005 | Verify Pool Count Auto Calculated After Adding MSISDN Range | regression, positive, sim_range, msisdn |
| TC_SRM_006 | Verify Pool Count Is Zero Before Adding MSISDN Range | regression, positive, sim_range, msisdn |
| TC_SRM_007 | Verify Pool Count Field Is Disabled | regression, positive, sim_range, msisdn |
| TC_SRM_008 | Verify MSISDN Range Grid Shows Entry After Adding | regression, positive, sim_range, msisdn |
| TC_SRM_009 | Verify Cancel Button Redirects To SIM Range List | regression, positive, sim_range, msisdn, navigation |
| TC_SRM_010 | Verify SIM Category Selection For MSISDN | regression, positive, sim_range, msisdn |
| TC_SRM_011 | Submit Disabled When Pool Name Empty | regression, negative, sim_range, msisdn |
| TC_SRM_012 | Submit Disabled When Account Not Selected | regression, negative, sim_range, msisdn |
| TC_SRM_013 | Submit Disabled When Description Empty | regression, negative, sim_range, msisdn |
| TC_SRM_014 | Submit Disabled When No MSISDN Range Added | regression, negative, sim_range, msisdn |
| TC_SRM_015 | MSISDN From Greater Than To Should Show Error | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_016 | MSISDN From Below 10 Digits Keeps Popup Submit Disabled | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_017 | MSISDN To Below 10 Digits Keeps Popup Submit Disabled | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_018 | Overlapping MSISDN Range Should Show Error | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_019 | MSISDN Input Exceeding 15 Digits Gets Truncated | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_020 | Close MSISDN Popup Without Submitting Clears Fields | regression, negative, sim_range, msisdn |
| TC_SRM_021 | SQL Injection In Pool Name Should Be Rejected | regression, negative, security, sim_range, msisdn |
| TC_SRM_022 | Special Characters In Pool Name Should Be Rejected | regression, negative, security, sim_range, msisdn |
| TC_SRM_023 | Pool Name Exceeding Max Length Should Be Rejected | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_024 | Description Exceeding Max Length Should Be Rejected | regression, negative, sim_range, msisdn, boundary |
| TC_SRM_025 | Direct Access To Create MSISDN SIM Range Without Login | regression, negative, security, sim_range, msisdn, navigation |
| TC_SRM_026 | Direct Access To SIM Range MSISDN Tab Without Login | regression, negative, security, sim_range, msisdn, navigation |

### Sample Test Case (TC_SRM_001)

```robot
TC_SRM_001 Create MSISDN SIM Range Happy Path
    [Documentation]    Full E2E: Login > Admin > SIM Range > MSISDN tab > Create >
    ...                fill header > add MSISDN range > verify Pool Count > Submit >
    ...                verify success toast and redirect.
    [Tags]    smoke    regression    positive    sim_range    msisdn
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range With Ranges
    Verify Pool Count    ${EXPECTED_MSISDN_POOL_COUNT}
    Submit SIM Range Form
    Verify SIM Range Created Successfully
```

### Sample Negative Test (TC_SRM_011)

```robot
TC_SRM_011 Submit Disabled When Pool Name Empty
    [Documentation]    Leave Pool Name blank, fill all other fields and add range.
    ...                Submit should be disabled.
    [Tags]    regression    negative    sim_range    msisdn
    Login And Navigate To Create SIM Range MSISDN
    Select Account From Dropdown
    Enter SIM Range Description    ${MSISDN_DESCRIPTION}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify Submit Button Is Disabled
```

### Keyword Reference (from `sim_range_keywords.resource`)

Key MSISDN keywords: `Login And Navigate To Create SIM Range MSISDN`, `Login And Navigate To SIM Range MSISDN List`, `Select MSISDN Tab`, `Click Create SIM Range Button MSISDN`, `Fill MSISDN SIM Range Header`, `Fill MSISDN SIM Range With Ranges`, `Add MSISDN Range`, `Open MSISDN Popup`, `Open MSISDN Popup And Enter Range`, `Close MSISDN Popup Without Submitting`, `Verify MSISDN Popup Submit Is Disabled`, `Verify MSISDN Popup Is Closed`, `Verify MSISDN Grid Has Rows`, `Verify Assets Type Is Hidden`, `Select SIM Category If Visible`, `Verify Pool Count`, `Verify Pool Count Is Zero Or Empty`, `Submit SIM Range Form`, `Verify SIM Range Created Successfully`, `Verify Cancel Redirects To SIM Range List`, `Verify Submit Button Is Disabled`, `Verify Error Toast Or Popup Still Open`, `Verify Negative SIM Range Outcome`, `Expand MSISDN Panel`.

---

## 9. UI Elements and Locator Strategy

### 9.1 Locator Priority (consistent with TC_001 through TC_011)

```
id=        (highest priority — e.g., id=addMsisdnRangePopup, id=msisdnRangeTable)
data-testid=   (e.g., data-testid=tSIMCacoor for SIM Category; data-testid=AectAccoor for Account)
name=      (e.g., name=poolName, name=accountId, name=description, name=fromInputMsisdn, name=toInputMsisdn)
xpath=     (fallback — e.g., scoped popup buttons, accordion toggles)
```

### 9.2 Complete Element Locator Table (from `sim_range_locators.resource`)

| UI Element | Locator Variable | Notes |
|---|---|---|
| **MSISDN Tab** | `${LOC_TAB_MSISDN}` | Tab index 1; renders MSISDN content |
| **SIM Range Grid** | `${LOC_SR_GRID}` | Kendo Grid for SIM Range listing |
| **Create SIM Range Button** | `${LOC_SR_CREATE_BTN}` | Only visible with RW permission |
| **Pool Name Input** | `${LOC_SR_POOL_NAME}` | Max 50 chars |
| **Account Dropdown** | `${LOC_SR_ACCOUNT_DD}` | Populated via API |
| **Description Input** | `${LOC_SR_DESCRIPTION}` | Max 500 chars |
| **Pool Count Input** | `${LOC_SR_POOL_COUNT}` | Always read-only |
| **SIM Category Dropdown** | `${LOC_SR_SIM_CATEGORY_DD}` | Shown for MSISDN when permission allows |
| **Assets Type Dropdown** | `${LOC_SR_ASSETS_TYPE_DD}` | Hidden for MSISDN flow (pre-set from URL) |
| **MSISDN Accordion Panel** | `${LOC_MSISDN_PANEL}` | Panel header `id=headingThree` |
| **MSISDN Panel Toggle** | `${LOC_MSISDN_PANEL_TOGGLE}` | Toggles `#collapseThree` |
| **Add MSISDN Range Button** | `${LOC_ADD_MSISDN_BTN}` | Max 20 rows |
| **MSISDN Range Table** | `${LOC_MSISDN_GRID}` | `id=msisdnRangeTable` |
| **MSISDN Grid Row** | `${LOC_MSISDN_GRID_ROW}` | Kendo Grid data row |
| **MSISDN Popup Modal** | `${LOC_MSISDN_POPUP}` | `id=addMsisdnRangePopup` |
| **MSISDN From Input (Popup)** | `${LOC_MSISDN_FROM}` | 10–15 digits |
| **MSISDN To Input (Popup)** | `${LOC_MSISDN_TO}` | Must be ≥ From |
| **MSISDN Popup Submit** | `${LOC_MSISDN_POPUP_SUBMIT}` | Enabled when both inputs ≥ 10 digits |
| **MSISDN Popup Close** | `${LOC_MSISDN_POPUP_CLOSE}` | Clears and dismisses popup |
| **Main Submit Button** | `${LOC_SR_SUBMIT_BTN}` | Page-level submit |
| **Main Close Button** | `${LOC_SR_CLOSE_BTN}` | Redirects to `/SIMRange` |
| **Success Toast** | `${LOC_SR_TOAST_SUCCESS}` | Success notification |
| **Error Toast** | `${LOC_SR_TOAST_ERROR}` | Validation/error notification |

### 9.3 Key Locator Disambiguation Notes

- **Two `id=prceedBtn` buttons exist on the page simultaneously** (one in the MSISDN popup, one in the main form footer). Always scope popup interactions to `xpath=//div[@id='addMsisdnRangePopup']//button[@id='prceedBtn']` and main form interactions to `xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[@id='prceedBtn']`.
- **MSISDN tab is Tab index `1`** (not `0`). The `<li value="1">` element triggers `selectedTabValue=1` in state and updates the URL to `?currentTab=1`.
- **Assets Type dropdown is hidden** when the URL contains `currentTab=1` (`!currentAssetType` is `false`). Do not attempt to interact with it.
- **SIM Category dropdown** uses `data-testid=tSIMCacoor` — conditionally rendered; check visibility before interacting.

---

## 10. Expected Results

| Step | Expected Outcome |
|---|---|
| Navigate to `/SIMRange` | SIM Range listing page loaded; `ManageSIMRangeGrid` visible |
| Click MSISDN tab | MSISDN tab becomes active; URL updates to `?currentTab=1`; `ManageSIMRangeGrid` re-renders with MSISDN data |
| Click Create SIM Range | Navigates to `/CreateSIMRange?currentTab=1`; form renders with Assets Type pre-set to MSISDN |
| Type Pool Name | Input value updates; Joi validation fires; error cleared on valid input |
| Select Account | `accountId` state updates; no cascading dependency (no BU/CC) for SIM Range |
| Type Description | Input value updates; Joi validation fires |
| Select SIM Category | `SIMCategory` state updates; validation error cleared |
| Pool Count field | Displays `"0"` initially; always read-only (disabled) |
| MSISDN accordion | Panel header visible; clicking toggle expands `#collapseThree` |
| Click +Add in MSISDN panel | `#addMsisdnRangePopup` modal opens with static backdrop |
| Enter From/To (each ≥ 10 digits) | `inputHandlerMsisdn` fires; popup Submit button becomes **enabled** |
| Click popup Submit | `msisdnSubmit()` validates ranges; adds to `msisdnRange` state; closes modal; row appears in `#msisdnRangeTable` |
| Pool Count auto-updates | `calculatePoolCount()` called; Pool Count = `(To − From + 1)` = `10` |
| Main Submit button | Becomes **enabled** after all required fields are valid and `poolCount !== "0"` |
| Click main Submit | `submitSimRange()` calls `API_SimInventory.CreateSIMRange()`; success toast shown |
| Success toast | Contains server-returned success message (`response.errorMessage`) |
| Redirect | URL changes to `/SIMRange`; `ManageSIMRangeGrid` visible on listing page |

---

## 11. Negative Test Scenarios

| # | Scenario | Trigger | Expected Result |
|---|---|---|---|
| NEG-01 | Empty Pool Name | Leave Pool Name blank; fill all other fields; add MSISDN range | Main Submit disabled; Joi validation error shown on Pool Name field |
| NEG-02 | No Account selected | Leave Account at default placeholder; fill all other fields | Main Submit disabled; `accountId === 0` condition prevents enablement |
| NEG-03 | Empty Description | Leave Description blank; fill all other fields | Main Submit disabled; Joi validation error on Description field |
| NEG-04 | No MSISDN Range added | Fill all header fields but do not open popup | `poolCount === "0"`; Main Submit remains disabled |
| NEG-05 | MSISDN From > To | Enter From = `966500000010`, To = `966500000001` | Error toast: "From value must be less than To value" (`t_From_Value_less`) |
| NEG-06 | Overlapping MSISDN range | Add first range `966500000001–966500000010`; try adding overlapping `966500000005–966500000015` | Error toast: MSISDN range already exists (`t_msisdnRange` + `t_alreadyExist`) |
| NEG-07 | MSISDN From contains a range already in table | From = `966500000003` (within existing range) | `isNumbersRangesMsisdn` check fires; error toast shown |
| NEG-08 | Range spans over existing range | From < existing From, To > existing To | `isBetweenRangesMsisdn` check fires; error toast shown |
| NEG-09 | Popup Submit disabled for short inputs | Enter From = `12345` (9 digits), To = `966500000010` | Popup Submit remains disabled (`isPopupSubmitMsisdn = true`) |
| NEG-10 | Pool Name exceeds 50 chars | Enter 51-character Pool Name | Input truncated at 50 chars (maxLength enforcement) |
| NEG-11 | Description exceeds 500 chars | Enter 501-character Description | Input truncated at 500 chars (maxLength enforcement) |
| NEG-12 | MSISDN input exceeds 15 digits | Enter 16-digit number in From or To | `maxLengthCheck` (onInput) truncates to 15 digits |
| NEG-13 | Close popup without submitting | Open MSISDN popup; enter values; click popup Close | Popup closes; `fromInputMsisdn`/`toInputMsisdn` cleared (`closeMsisdnPopup()`); no row added to table |
| NEG-14 | Max row count reached (20 rows) | Add 20 MSISDN ranges | Add MSISDN button becomes disabled (`isAddMsisdnEnableForRow = false`, CSS class `sim-range-disabled`) |

---

## 12. Validation Keywords (from `sim_range_keywords.resource`)

| Keyword | Purpose |
|---------|---------|
| `Verify Pool Count` | Asserts auto-calculated Pool Count matches expected |
| `Verify Pool Count Is Zero Or Empty` | Asserts Pool Count is 0 or empty |
| `Verify MSISDN Popup Submit Is Disabled` | Asserts MSISDN popup Submit is disabled |
| `Verify Submit Button Is Disabled` | Asserts page-level Submit is disabled |
| `Verify MSISDN Popup Is Closed` | Asserts MSISDN popup is not visible |
| `Verify MSISDN Grid Has Rows` | Asserts MSISDN range table has at least N rows |
| `Verify Assets Type Is Hidden` | Asserts Assets Type dropdown not visible (MSISDN flow) |
| `Close MSISDN Popup Without Submitting` | Clicks popup Close without submitting |
| `Verify Error Toast Or Popup Still Open` | Checks for error toast or popup after invalid submission |
| `Verify Negative SIM Range Outcome` | Robust check after submitting invalid data |

---

## 13. Automation Considerations

### 13.1 URL-Driven Pre-Selection (Critical)

When navigating to `/CreateSIMRange?currentTab=1`, `componentDidMount` reads the `currentTab` query parameter and pre-sets:
```javascript
simRange.SIMCategory = "";   // Empty — must be selected manually
simRange.assetsTypes = "2";  // Pre-set to MSISDN
```
The **Assets Type dropdown (`<select name="assetsTypes">`) is hidden** from the DOM when `currentAssetType` is set (non-null). Do not attempt to interact with it.

### 13.2 MSISDN Popup Submit Enablement Logic

The popup Submit button state is driven by `isPopupSubmitMsisdn`:
```javascript
// Enabled (false = Submit enabled) only when BOTH fields have >= 10 characters
isPopupSubmitMsisdn = !(fromInputMsisdn.length >= 10 && toInputMsisdn.length >= 10)
```
- Input only fires on `onChange`, not on `Input Text` via Selenium without a subsequent keyboard event. Always follow `Input Text` with `Press Keys ... TAB` or wait for the React state to settle.
- `maxLength={15}` is enforced via the `onInput={maxLengthCheck}` handler (checks that value contains only digits 0–9; truncates if longer than maxLength).

### 13.3 Accordion Expansion (Bootstrap Collapse)

The MSISDN Range accordion panel uses Bootstrap 3 collapse. If the `#collapseThree` panel is already expanded (e.g., from a previous test run), clicking the toggle will collapse it. Use this check:

```robot
${is_expanded}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//div[@id='collapseThree'][contains(@class,'in')]
Run Keyword If    not ${is_expanded}    Click Element    xpath=//div[@id='headingThree']//a[@role='button']
```

### 13.4 Duplicate `id=prceedBtn` Disambiguation

Both the MSISDN popup and the main form footer contain `<button id="prceedBtn">`. Robot Framework / Selenium will match the **first** one in the DOM if unscoped. Always use:
- Popup: `xpath=//div[@id='addMsisdnRangePopup']//button[@id='prceedBtn']`
- Main form: `xpath=//div[contains(@class,'gc-form-buttons-wrapper')]//button[@id='prceedBtn']`

### 13.5 SIM Category Conditional Rendering

`SIM_CATEGORY_PERMISSION()` returns `true` or `false` based on a client configuration flag. When it returns `true`, the SIM Category dropdown is **not rendered at all** for MSISDN (hidden via CSS class `service-hide`). When it returns `false`, it is required. Write the automation to check visibility dynamically:

```robot
${visible}=    Run Keyword And Return Status    Element Is Visible    xpath=//select[@name='SIMCategory']
Run Keyword If    ${visible}    Select From List By Value    xpath=//select[@name='SIMCategory']    1
```

### 13.6 Pool Count Read-Only Behaviour

Unlike the ICCID/IMSI flow (where `poolCount` is briefly editable in some states), in practice `isPoolEnable` never becomes `true` in the current code (it is set to `false` in every `setState` call after range operations). Pool Count is **always read-only**. Verify its value using `Get Value`, never attempt to edit it.

### 13.7 Multiple MSISDN Ranges

The `msisdnRowCount` starts at 20. Each added range decrements it by 1. When it reaches 0, `isAddMsisdnEnableForRow` becomes `false` and the Add button gets the CSS class `sim-range-disabled`. The button also receives the `disabled` attribute from `isAddMsisdnEnable`. For tests involving multiple ranges, ensure the total count added is less than 20.

### 13.8 MSISDN Tab vs. ICCID/IMSI Tab Isolation

The `ManageSIMRange` uses `ReactDOM.render` (not React Router) to swap the child component on tab click. Avoid relying on `currentTab` URL param alone — always verify that `id=ManageSIMRangeGrid` is visible and re-rendered after tab switching, since both tabs use the same grid ID.

### 13.9 Account Auto-Selection

When `SIMRange.opcoSelectedByDefault` is `true` and `accountTypeId == 3`, the account dropdown is **disabled** and pre-selected with the first account. In automation, detect if the dropdown is disabled before attempting selection:

```robot
${disabled}=    Run Keyword And Return Status    Element Should Be Disabled    xpath=//select[@name='accountId']
Run Keyword Unless    ${disabled}    Select From List By Index    xpath=//select[@name='accountId']    1
```

### 13.10 SSL Certificate Bypass

The CMP application uses self-signed SSL certificates. Always launch Chrome with:
```python
--ignore-certificate-errors
--disable-web-security
--allow-running-insecure-content
```

### 13.11 MSISDN Range Table Rendering Timing

The `#msisdnRangeTable` Kendo Grid is initialised on `componentDidMount` but populated via `grid.dataSource.data(msisdnRange)` after each popup submit. After the popup closes, allow a short settling period or use `Wait Until Page Contains Element` on the row XPath before asserting pool count values.

---

## 14. Framework Recommendation

| Framework | Suitability | Notes |
|---|---|---|
| **Robot Framework + SeleniumLibrary** | ✅ Recommended | Matches existing TC_001–TC_011 suite; best for team-wide keyword sharing |
| **Playwright (Python/JS)** | ✅ Excellent | Superior handling of Bootstrap modal waits; `page.wait_for_selector` more reliable than implicit waits |
| **Cypress** | ⚠ Limited | No multi-origin support; self-signed certificate handling is non-trivial |
| **Selenium (Java/Python)** | ✅ Good | Lower-level than RF but fully capable |

---

## 15. Example Playwright Script

```python
import re
from playwright.sync_api import sync_playwright

BASE_URL = "https://192.168.1.26:7874"
USERNAME = "ksa_opco"
PASSWORD = "Admin@123"
POOL_NAME = "Test MSISDN SIM Pool"
DESCRIPTION = "Automation test MSISDN SIM range"
MSISDN_FROM = "966500000001"
MSISDN_TO = "966500000010"

def test_create_sim_range_msisdn():
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=False,
            args=["--ignore-certificate-errors", "--disable-web-security"]
        )
        context = browser.new_context(ignore_https_errors=True)
        page = context.new_page()

        # Login
        page.goto(f"{BASE_URL}")
        page.fill("input[name='username']", USERNAME)
        page.fill("input[name='password']", PASSWORD)
        page.click("button[type='submit']")
        page.wait_for_url(re.compile(r"/ManageDevices"))

        # Navigate to SIM Range
        page.click("a[href*='/SIMRange']:not([href*='Create']):not([href*='Log']):not([href*='Audit'])")
        page.wait_for_url(re.compile(r"/SIMRange"))
        page.wait_for_selector("ul#tabHeading")

        # Select MSISDN tab (value="1")
        page.click("ul#tabHeading li[value='1']")
        page.wait_for_selector("#ManageSIMRangeGrid")
        page.wait_for_url(re.compile(r"currentTab=1"))

        # Click Create SIM Range
        page.click("a.btn-custom-color:has-text('Create')")
        page.wait_for_url(re.compile(r"/CreateSIMRange\?currentTab=1"))
        page.wait_for_selector("input[name='poolName']")

        # Fill Pool Name
        page.fill("input[name='poolName']", POOL_NAME)

        # Select Account (first available)
        page.wait_for_selector("select[name='accountId'] option:nth-child(2)")
        page.select_option("select[name='accountId']", index=1)

        # Fill Description
        page.fill("input[name='description']", DESCRIPTION)

        # SIM Category (if visible)
        sim_cat = page.query_selector("select[name='SIMCategory']")
        if sim_cat and sim_cat.is_visible():
            page.select_option("select[name='SIMCategory']", value="1")  # 830

        # Verify Assets Type is hidden (pre-set from URL)
        assets_type = page.query_selector("select[name='assetsTypes']")
        assert assets_type is None or not assets_type.is_visible(), "Assets Type should be hidden for MSISDN flow"

        # Expand MSISDN accordion
        page.click("div#headingThree a[role='button']")
        page.wait_for_selector("div#collapseThree.in", state="visible")

        # Click Add MSISDN Range
        page.click("div#collapseThree button.add-action-button")
        page.wait_for_selector("#addMsisdnRangePopup", state="visible")

        # Fill MSISDN From/To (both >= 10 digits required for popup Submit to enable)
        page.fill("div#addMsisdnRangePopup input[name='fromInputMsisdn']", MSISDN_FROM)
        page.fill("div#addMsisdnRangePopup input[name='toInputMsisdn']", MSISDN_TO)

        # Wait for popup Submit to be enabled
        page.wait_for_selector("div#addMsisdnRangePopup button#prceedBtn:not([disabled])")
        page.click("div#addMsisdnRangePopup button#prceedBtn")

        # Wait for popup to close and row to appear
        page.wait_for_selector("#addMsisdnRangePopup", state="hidden")
        page.wait_for_selector("div#msisdnRangeTable tr[data-uid]")

        # Verify Pool Count = 10
        pool_count = page.input_value("input[name='poolCount']")
        assert pool_count == "10", f"Expected pool count 10, got {pool_count}"

        # Verify Assets Type field is hidden
        assert not page.is_visible("select[name='assetsTypes']"), "Assets Type dropdown should be hidden"

        # Wait for main Submit to be enabled and click
        page.wait_for_selector("div.gc-form-buttons-wrapper button#prceedBtn:not([disabled])")
        page.click("div.gc-form-buttons-wrapper button#prceedBtn")

        # Verify success toast
        page.wait_for_selector("div.Toastify__toast--success", timeout=15000)

        # Verify redirect to SIM Range list
        page.wait_for_url(re.compile(r"/SIMRange"), timeout=15000)
        page.wait_for_selector("#ManageSIMRangeGrid")

        print("TC_012 PASSED: MSISDN SIM Range created successfully")
        browser.close()
```

---

## 16. Success Validation Checklist

```
□ Navigate to SIM Range module via left sidebar
□ MSISDN tab selected (value="1"); URL contains currentTab=1
□ ManageSIMRangeGrid renders with MSISDN data columns (Batch Number, Account, Pool Name, MSISDN, Description)
□ Clicking Create SIM Range navigates to /CreateSIMRange?currentTab=1
□ Assets Type dropdown is NOT visible (pre-set from URL; hidden in render when currentAssetType is set)
□ Pool Name input accepts text (max 50 chars)
□ Account dropdown populated from API; selection updates accountId state
□ Description input accepts text (max 500 chars)
□ SIM Category dropdown visible (if SIM_CATEGORY_PERMISSION() === false); 830/831/05X options present
□ Pool Count field is disabled (read-only) and shows "0" initially
□ MSISDN accordion panel (#headingThree) is visible
□ Bootstrap collapse toggles correctly for #collapseThree
□ +Add button enabled (isAddMsisdnEnable = true)
□ Max row count indicator shows 20 initially
□ #addMsisdnRangePopup opens with static backdrop on +Add click
□ fromInputMsisdn accepts numeric input (max 15 digits)
□ toInputMsisdn accepts numeric input (max 15 digits)
□ Popup Submit disabled when either field < 10 digits
□ Popup Submit enabled when both fields >= 10 digits
□ msisdnSubmit() validates: From < To; no overlapping ranges
□ Popup closes after successful submission
□ #msisdnRangeTable shows new row with msisdnFrom, msisdnTo, count columns
□ Pool Count auto-calculated: (966500000010 − 966500000001 + 1) = 10
□ isFinalSubmitEnable = true when all conditions met
□ Main Submit enabled in footer
□ API call succeeds (errorCode === 0)
□ Success toast displayed with server-returned message
□ Redirect to /SIMRange after success
□ ManageSIMRangeGrid on listing page shows existing records including new entry
□ Download CSV button (#export) visible when records exist
```

---

## 17. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-09 | CMP QA / Automation Team | Initial document — MSISDN SIM Range creation flow; sourced from `SIMRangeMSISDN.js`, `CreateSIMRange.js`, `ManageSIMRange.js` |
