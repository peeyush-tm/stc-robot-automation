# Automation Test Specification – Create Cost Center

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 14)*
**Date:** 2026-03-10
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md · TC_003_Create_SIM_Order_RF.md · TC_004_Create_SIM_Range_RF.md · TC_005_Create_CSR_Journey_RF.md · TC_006_Create_SIM_Product_Type_RF.md · TC_007_Create_APN_RF.md · TC_008_Create_IP_Pool_RF.md · TC_009_Create_Label_RF.md · TC_010_Create_IP_Whitelisting_RF.md · TC_011_Create_Rule_RF.md · TC_012_Create_SIM_Range_MSISDN_RF.md

---

## 1. Objective

This test validates the end-to-end **Create Cost Center** workflow on the CMP web application. The automation begins from the **Manage Devices** page (post-login) and covers:

1. Navigating to the **ManageAccount** module via the left-side navigation panel (Admin accordion)
2. Locating the **Create Cost Center** button on the ManageAccount listing page (visible only with RW permission and role-based `RoleWisePermissionOfCostCenter()` flag)
3. Clicking the button to navigate to `/CreateCostCenter`
4. Completing all mandatory fields: **Parent Account** (TreeView hierarchy dropdown) and **Account Name** (free-text, max 100 chars)
5. Optionally entering a **Comment** (free-text, max 50 chars)
6. Clicking the **Submit** button and verifying the **success toast notification** and redirect back to `/ManageAccount`
7. Verifying the newly created Cost Center appears in the **CostCenter tab** (`tab9`) when expanding a Billing Account row in the ManageAccount grid

This test ensures the Cost Center creation workflow is functional, all mandatory fields are validated, the hierarchy account picker works correctly, and the system correctly stores and acknowledges the submitted Cost Center.

> **UI Location of CostCenter Tab:** The `CostCenter` tab (id=`tab9`) is rendered as the 9th tab inside the detail/expand row of a **Billing Account** entry in the ManageAccount Kendo Grid (`id=ManageAccountGrid`). The tab label is "Cost Center" and renders the `CostCenterAccount` component (`id=CostCenterAccount`) — a nested Kendo Grid listing all cost centers under that Billing Account.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **ManageAccount URL** | `https://192.168.1.26:7874/ManageAccount` |
| **Create Cost Center URL** | `https://192.168.1.26:7874/CreateCostCenter` |
| **Post-Submit Redirect URL** | `https://192.168.1.26:7874/ManageAccount` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |
| **Cost Center Location in UI** | **Admin module → ManageAccount** (left-side navigation; ManageAccount is a sub-item under the Admin accordion/menu group) |
| **Create Cost Center Button** | Rendered on the ManageAccount page — visible only when `readWritePermission === "RW"` AND `RoleWisePermissionOfCostCenter() === true` |
| **ManageAccount Listing Grid ID** | `ManageAccountGrid` |
| **CostCenter Nested Grid ID** | `CostCenterAccount` (inside expanded Billing Account row → tab9) |
| **Source Files** | `CreateCostCenter.js`, `CostCenterAccount.js`, `BillingAccount.js`, `ManageAccountSTC.js` |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` and has landed on the **Manage Devices** page
  - *(Use `Login To Application` and `Navigate To Manage Devices` keywords from `TC_001_Login_Navigate_RF.md`)*
- The `ksa_opco` user has **RW (Read-Write)** permission to access the **ManageAccount** module
- `RoleWisePermissionOfCostCenter()` returns `true` for the logged-in user — this controls visibility of the **Create Cost Center** button and the Edit/Delete icons on the grid
- At least one valid **Parent Account** (Billing Account or suitable hierarchy account) exists in the system for selection
- The account name used in the test does not already exist as a Cost Center under the selected parent account
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
robot --outputdir results tests/TC_013_Create_Cost_Center.robot
```

### 4.3 Project Structure (aligned to TC_001 through TC_012)

```
cmp-automation/
├── resources/
│   ├── common_keywords.robot            # Open/Close browser, Login, Navigate keywords
│   ├── cost_center_keywords.robot       # Cost Center-specific keywords
│   └── variables.robot                  # All locator and data variables
├── tests/
│   ├── TC_001_Login_Navigate.robot
│   ├── TC_002_State_Change.robot
│   ├── TC_003_Create_SIM_Order.robot
│   ├── TC_004_Create_SIM_Range.robot
│   ├── TC_005_Create_CSR_Journey.robot
│   ├── TC_006_Create_SIM_Product_Type.robot
│   ├── TC_007_Create_APN.robot
│   ├── TC_008_Create_IP_Pool.robot
│   ├── TC_009_Create_Label.robot
│   ├── TC_010_Create_IP_Whitelisting.robot
│   ├── TC_011_Create_Rule.robot
│   ├── TC_012_Create_SIM_Range_MSISDN.robot
│   └── TC_013_Create_Cost_Center.robot
└── results/
    └── (output.xml, log.html, report.html)
```

---

## 5. Test Data

| Field | Sample Value | Notes |
|---|---|---|
| **Username** | `ksa_opco` | Same credentials as all prior TCs |
| **Password** | `Admin@123` | Same credentials as all prior TCs |
| **Parent Account** | *(First available Billing Account)* | Selected via TreeView hierarchy dropdown; populated via `getAccountHierarchy()` API |
| **Account Name** | `Test Cost Center Automation` | Max 100 characters; special chars removed; semicolons stripped |
| **Comment** | `Automation test cost center` | Optional; max 50 characters |
| **Expected Post-Submit URL** | `/ManageAccount` | Redirected back to ManageAccount list page |
| **Expected Success Toast** | Server-returned success message (`t("t_API_errorMessage.t_Created_Cost_Centre_Account")`) | Displayed via `toast.success()` when `errorCode === 200` |

> Parameterise all test data values via a Robot Framework variable file (`variables.robot` or `--variablefile`) to support multiple environments without modifying test files.
>
> **Important:** The Account Name field strips semicolons (`;`) and special characters via `removeSpecialChar()` on every `onChange` event. Avoid including these in test data.

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
${BASE_URL}                    https://192.168.1.26:7874
${MANAGE_URL}                  https://192.168.1.26:7874/ManageDevices
${MANAGE_ACCOUNT_URL}          https://192.168.1.26:7874/ManageAccount
${CREATE_COST_CENTER_URL}      https://192.168.1.26:7874/CreateCostCenter
${BROWSER}                     chrome
${TIMEOUT}                     30s
${RETRY_COUNT}                 3x
${RETRY_INTERVAL}              5s

# Credentials (shared with TC_001 through TC_012)
${USERNAME}                    ksa_opco
${PASSWORD}                    Admin@123

# Create Cost Center Form Test Data
${ACCOUNT_NAME}                Test Cost Center Automation
${COMMENT}                     Automation test cost center

# Locators — Navigation
${NAV_MANAGE_ACCOUNT}          xpath=//a[contains(@href,'/ManageAccount') and not(contains(@href,'Create')) and not(contains(@href,'STC'))]
${BTN_CREATE_COST_CENTER}      xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]

# Locators — Create Cost Center Form
${DDL_PARENT_ACCOUNT}          xpath=//div[@data-for='parentAccount']
${TREEVIEW_INPUT}              xpath=//div[@data-for='parentAccount']//input
${INPUT_ACCOUNT_NAME}          xpath=//input[@name='accountName']
${INPUT_COMMENT}               xpath=//input[@name='comment']
${ERROR_PARENT_ACCOUNT}        xpath=//div[@data-for='parentAccount']/following-sibling::*[contains(@class,'error')]
${ERROR_ACCOUNT_NAME}          xpath=//input[@name='accountName']/following-sibling::*[contains(@class,'error')]

# Locators — Form Footer Buttons
${BTN_SUBMIT}                  xpath=//input[@type='button' and contains(@class,'btn-custom-color')]
${BTN_CLOSE}                   xpath=//a[contains(@class,'btn-cancel-color') and contains(@class,'cursor-pointer')]

# Locators — ManageAccount Grid & CostCenter Tab
${GRID_MANAGE_ACCOUNT}         id=ManageAccountGrid
${GRID_COST_CENTER}            id=CostCenterAccount
${TAB_COST_CENTER}             xpath=//li[@data-name='tab9']
```

---

## 7. Automation Flow – Step-by-Step

### Phase 1: Navigate to ManageAccount and Open Create Cost Center Form

#### Step 1 – Navigate to ManageAccount Module

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 1.1 | Click ManageAccount link in left navigation | `xpath=//a[contains(@href,'/ManageAccount') and not(contains(@href,'Create')) and not(contains(@href,'STC'))]` | May need to expand Admin accordion first |
| 1.2 | Wait for ManageAccount page to load | `Wait Until Location Contains    /ManageAccount` | |
| 1.3 | Wait for Manage Account grid to render | `Wait Until Element Is Visible    id=ManageAccountGrid` | Kendo Grid renders asynchronously |

#### Step 2 – Click the Create Cost Center Button

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 2.1 | Verify Create Cost Center button is visible | `Wait Until Element Is Visible    xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]` | Only visible when `readWritePermission === "RW"` AND `RoleWisePermissionOfCostCenter() === true` |
| 2.2 | Click **Create Cost Center** button | `Click Element    xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]` | React `<Link to="/CreateCostCenter">` — renders as `<a>` tag |
| 2.3 | Wait for Create Cost Center page to load | `Wait Until Location Contains    /CreateCostCenter` | |
| 2.4 | Wait for Account Name input to be visible | `Wait Until Element Is Visible    xpath=//input[@name='accountName']` | Confirms form is rendered |

---

### Phase 2: Fill the Create Cost Center Form

#### Step 3 – Select Parent Account (TreeView Dropdown)

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 3.1 | Wait for the TreeViewDropdown to be present | `Wait Until Element Is Visible    xpath=//div[@data-for='parentAccount']` | `TreeViewDropdown` component; populated via `getAccountHierarchy()` API |
| 3.2 | Click the TreeViewDropdown to open | `Click Element    xpath=//div[@data-for='parentAccount']` | Opens the account hierarchy tree |
| 3.3 | Wait for tree nodes to render | `Wait Until Element Is Visible    xpath=//div[@data-for='parentAccount']//li[1]` | Tree loads account hierarchy from API |
| 3.4 | Click the first account node in the tree | `Click Element    xpath=//div[@data-for='parentAccount']//li[1]` | Select the first available parent account |
| 3.5 | Verify parent account is selected | `Wait Until Element Is Not Visible    xpath=//div[@data-for='parentAccount']//li[1]` | Tree closes after selection; selected account name appears in display area |
| 3.6 | Verify no validation error on parentAccount | `Element Should Not Be Visible    xpath=//div[@data-for='parentAccount']/following-sibling::*[contains(@class,'error')]` | Joi validation: `parentAccount` must be a number ≥ 1 |

> **TreeViewDropdown behaviour:** This is a custom `TreeViewDropdown` component (not a native `<select>`). It uses `isAccountLevelValidationOnPlansAndOrder={true}` which restricts selectable accounts to those at or above the appropriate level. The `onSelectionChange` callback calls `setAccount(parentAccount)` which extracts `parentAccount.id` as a number. If no account is selected, the Joi validation error fires: `t("common:t_errorMessage.t_account")`.

#### Step 4 – Enter Account Name

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 4.1 | Wait for Account Name input | `Wait Until Element Is Visible    xpath=//input[@name='accountName']` | |
| 4.2 | Click and clear Account Name field | `Click Element    xpath=//input[@name='accountName']` | |
| 4.3 | Type Account Name | `Input Text    xpath=//input[@name='accountName']    Test Cost Center Automation` | Max 100 chars; `removeSpecialChar()` applied; semicolons stripped |
| 4.4 | Verify no validation error | `Wait Until Element Is Not Visible    xpath=//input[@name='accountName']/following-sibling::*[contains(@class,'error')]` | Joi: must be a non-empty string, max 100 chars |

> **Input sanitisation on `accountName`:** The `handleChange` function applies `removeSpecialChar(event.nativeEvent.target.value)` and additionally strips the semicolon character (`;`). Use plain alphanumeric text with spaces to avoid unintended truncation.

#### Step 5 – Enter Comment (Optional)

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 5.1 | Wait for Comment input | `Wait Until Element Is Visible    xpath=//input[@name='comment']` | Optional field — Joi schema: `Joi.optional()` |
| 5.2 | Type Comment | `Input Text    xpath=//input[@name='comment']    Automation test cost center` | Max 50 chars; `removeSpecialChar()` applied |

> **Comment is optional.** Leaving this field blank will not prevent form submission. The field is included in the `account` state object but not required by the Joi schema.

---

### Phase 3: Submit the Form

#### Step 6 – Verify Submit Button is Enabled and Click

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 6.1 | Verify Submit button is present | `Wait Until Element Is Visible    xpath=//input[@type='button' and contains(@class,'btn-custom-color')]` | `<input type="button" value="Submit">` — rendered as `t("common:t_buttons.t_submit")` |
| 6.2 | Click **Submit** button | `Click Element    xpath=//input[@type='button' and contains(@class,'btn-custom-color')]` | Triggers `submit()` → `validateForm()` → `API_Account.createCostCentre(account)` |
| 6.3 | Wait for success toast | `Wait Until Page Contains Element    xpath=//div[contains(@class,'Toastify__toast--success')]` | `errorCode === 200` triggers `toast.success(t("t_API_errorMessage.t_Created_Cost_Centre_Account"))` |
| 6.4 | Verify redirect to ManageAccount | `Wait Until Location Contains    /ManageAccount` | `props.history.push("/ManageAccount")` called on success |
| 6.5 | Verify ManageAccount grid is displayed | `Wait Until Element Is Visible    id=ManageAccountGrid` | Confirms successful redirect to listing page |

> **Submit button type is `<input type="button">` — not `<button>` and not `<a>`.** Unlike several other modules (SIM Order, APN, etc.) where the Submit is an `<a>` tag, the Create Cost Center Submit is an `<input type="button">`. Use the locator `xpath=//input[@type='button' and contains(@class,'btn-custom-color')]` to avoid ambiguity with the Close `<a>` button.

---

### Phase 4: Verify Cost Center in Listing (Optional Verification)

#### Step 7 – Expand a Billing Account Row and Navigate to CostCenter Tab

| # | Action | Locator / Value | Notes |
|---|---|---|---|
| 7.1 | Wait for ManageAccount grid to load | `Wait Until Element Is Visible    id=ManageAccountGrid` | |
| 7.2 | Click the expand icon on the Billing Account row | `Click Element    xpath=//tr[@data-uid][1]//td[contains(@class,'k-hierarchy-cell')]/a` | Bootstrap/Kendo expand arrow; opens the detail row |
| 7.3 | Wait for the tab list to appear | `Wait Until Element Is Visible    xpath=//li[@data-name='tab9']` | CostCenter tab (`tab9`) is rendered inside the expanded detail row |
| 7.4 | Click the **Cost Center** tab | `Click Element    xpath=//li[@data-name='tab9']` | Renders `CostCenterAccount` component inside the detail cell |
| 7.5 | Wait for CostCenter grid to render | `Wait Until Element Is Visible    id=CostCenterAccount` | Nested Kendo Grid with `gridId="CostCenterAccount"` |
| 7.6 | Verify the newly created Cost Center row | `Wait Until Page Contains    Test Cost Center Automation` | Confirms the new Cost Center appears in the grid |

---

## 8. Complete Robot Framework Test File

```robot
*** Settings ***
Library           SeleniumLibrary    timeout=30s    implicit_wait=0s
Resource          resources/common_keywords.robot
Resource          resources/cost_center_keywords.robot
Suite Setup       Open CMP Browser
Suite Teardown    Close Browser
Test Setup        Run Keywords
...               Delete All Cookies    AND
...               Login To Application    ${USERNAME}    ${PASSWORD}    AND
...               Navigate To Manage Devices
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
${BASE_URL}                    https://192.168.1.26:7874
${MANAGE_URL}                  https://192.168.1.26:7874/ManageDevices
${MANAGE_ACCOUNT_URL}          https://192.168.1.26:7874/ManageAccount
${CREATE_COST_CENTER_URL}      https://192.168.1.26:7874/CreateCostCenter
${BROWSER}                     chrome
${TIMEOUT}                     30s
${USERNAME}                    ksa_opco
${PASSWORD}                    Admin@123
${ACCOUNT_NAME}                Test Cost Center Automation
${COMMENT}                     Automation test cost center
${NAV_MANAGE_ACCOUNT}          xpath=//a[contains(@href,'/ManageAccount') and not(contains(@href,'Create')) and not(contains(@href,'STC'))]
${BTN_CREATE_COST_CENTER}      xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]
${DDL_PARENT_ACCOUNT}          xpath=//div[@data-for='parentAccount']
${TREEVIEW_FIRST_NODE}         xpath=//div[@data-for='parentAccount']//li[1]
${INPUT_ACCOUNT_NAME}          xpath=//input[@name='accountName']
${INPUT_COMMENT}               xpath=//input[@name='comment']
${BTN_SUBMIT}                  xpath=//input[@type='button' and contains(@class,'btn-custom-color')]
${BTN_CLOSE}                   xpath=//a[contains(@class,'btn-cancel-color') and contains(@class,'cursor-pointer')]
${GRID_MANAGE_ACCOUNT}         id=ManageAccountGrid
${GRID_COST_CENTER}            id=CostCenterAccount
${TAB_COST_CENTER}             xpath=//li[@data-name='tab9']

*** Test Cases ***
TC_013_Create_Cost_Center_Happy_Path
    [Documentation]    Creates a Cost Center via Admin → ManageAccount → Create Cost Center
    [Tags]    CostCenter    ManageAccount    Create    Regression
    Navigate To Manage Account
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${ACCOUNT_NAME}
    Fill Comment    ${COMMENT}
    Submit Cost Center Form
    Verify Cost Center Created Successfully

TC_013_NEG_01_Empty_Account_Name
    [Documentation]    Verifies Submit fails with Joi error when Account Name is blank
    [Tags]    CostCenter    ManageAccount    Negative
    Navigate To Manage Account
    Open Create Cost Center Form
    Select Parent Account
    Clear Element Text    ${INPUT_ACCOUNT_NAME}
    Click Element    ${BTN_SUBMIT}
    Wait Until Element Is Visible    xpath=//input[@name='accountName']/following-sibling::*[contains(@class,'error')]

TC_013_NEG_02_No_Parent_Account
    [Documentation]    Verifies Submit fails with Joi error when Parent Account is not selected
    [Tags]    CostCenter    ManageAccount    Negative
    Navigate To Manage Account
    Open Create Cost Center Form
    Input Text    ${INPUT_ACCOUNT_NAME}    Test Cost Center Automation
    Click Element    ${BTN_SUBMIT}
    Wait Until Element Is Visible    xpath=//div[@data-for='parentAccount']/following-sibling::*[contains(@class,'error')]

TC_013_NEG_03_Account_Name_Exceeds_Max_Length
    [Documentation]    Verifies Account Name is truncated at 100 characters by maxLength
    [Tags]    CostCenter    ManageAccount    Negative
    Navigate To Manage Account
    Open Create Cost Center Form
    Select Parent Account
    ${long_name}=    Set Variable    ${'A' * 101}
    Input Text    ${INPUT_ACCOUNT_NAME}    ${long_name}
    ${actual_value}=    Get Value    ${INPUT_ACCOUNT_NAME}
    Should Be True    len('${actual_value}') <= 100

TC_013_NEG_04_Comment_Exceeds_Max_Length
    [Documentation]    Verifies Comment field is truncated at 50 characters by maxLength
    [Tags]    CostCenter    ManageAccount    Negative
    Navigate To Manage Account
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${ACCOUNT_NAME}
    ${long_comment}=    Set Variable    ${'C' * 51}
    Input Text    ${INPUT_COMMENT}    ${long_comment}
    ${actual_value}=    Get Value    ${INPUT_COMMENT}
    Should Be True    len('${actual_value}') <= 50

TC_013_NEG_05_Close_Without_Submit
    [Documentation]    Verifies Close button discards changes and redirects to ManageAccount
    [Tags]    CostCenter    ManageAccount    Negative
    Navigate To Manage Account
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${ACCOUNT_NAME}
    Fill Comment    ${COMMENT}
    Click Element    ${BTN_CLOSE}
    Wait Until Location Contains    /ManageAccount

*** Keywords ***
Open CMP Browser
    [Documentation]    Opens Chrome browser with SSL bypass options
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --ignore-certificate-errors
    Call Method    ${options}    add_argument    --disable-web-security
    Call Method    ${options}    add_argument    --allow-running-insecure-content
    Create Webdriver    Chrome    options=${options}
    Maximize Browser Window
    Set Selenium Implicit Wait    0s
    Set Selenium Timeout    30s

Navigate To Manage Account
    [Documentation]    Navigates from Manage Devices to the ManageAccount module
    Wait Until Element Is Visible    ${NAV_MANAGE_ACCOUNT}    timeout=30s
    Click Element    ${NAV_MANAGE_ACCOUNT}
    Wait Until Location Contains    /ManageAccount
    Wait Until Element Is Visible    ${GRID_MANAGE_ACCOUNT}    timeout=30s

Open Create Cost Center Form
    [Documentation]    Clicks the Create Cost Center button and waits for the form to load
    Wait Until Element Is Visible    ${BTN_CREATE_COST_CENTER}    timeout=30s
    Click Element    ${BTN_CREATE_COST_CENTER}
    Wait Until Location Contains    /CreateCostCenter
    Wait Until Element Is Visible    ${INPUT_ACCOUNT_NAME}    timeout=30s

Select Parent Account
    [Documentation]    Opens the TreeViewDropdown and selects the first available account node
    Wait Until Element Is Visible    ${DDL_PARENT_ACCOUNT}    timeout=30s
    Click Element    ${DDL_PARENT_ACCOUNT}
    Wait Until Element Is Visible    ${TREEVIEW_FIRST_NODE}    timeout=15s
    Click Element    ${TREEVIEW_FIRST_NODE}
    Sleep    0.5s
    Wait Until Element Is Not Visible    ${TREEVIEW_FIRST_NODE}    timeout=10s

Fill Account Name
    [Documentation]    Clears and types into the Account Name field
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${INPUT_ACCOUNT_NAME}
    Clear Element Text    ${INPUT_ACCOUNT_NAME}
    Input Text    ${INPUT_ACCOUNT_NAME}    ${name}

Fill Comment
    [Documentation]    Types into the optional Comment field
    [Arguments]    ${comment}
    Wait Until Element Is Visible    ${INPUT_COMMENT}
    Input Text    ${INPUT_COMMENT}    ${comment}

Submit Cost Center Form
    [Documentation]    Clicks the Submit button (input type=button)
    Wait Until Element Is Visible    ${BTN_SUBMIT}    timeout=15s
    Click Element    ${BTN_SUBMIT}

Verify Cost Center Created Successfully
    [Documentation]    Verifies success toast and redirect to ManageAccount
    Wait Until Page Contains Element    xpath=//div[contains(@class,'Toastify__toast--success')]    timeout=15s
    Wait Until Location Contains    /ManageAccount    timeout=15s
    Wait Until Element Is Visible    ${GRID_MANAGE_ACCOUNT}    timeout=15s
```

---

## 9. UI Elements and Locator Strategy

### 9.1 Locator Priority (consistent with TC_001 through TC_012)

```
id=        (highest priority — e.g., id=ManageAccountGrid, id=CostCenterAccount)
name=      (e.g., name=accountName, name=comment)
xpath=     (fallback — e.g., TreeViewDropdown, input type=button, tab9)
data-for=  (used by TreeViewDropdown wrapper — xpath=//div[@data-for='parentAccount'])
```

### 9.2 Complete Element Locator Table

| UI Element | HTML Type | Locator | Notes |
|---|---|---|---|
| **ManageAccount Nav Link** | `<a>` | `xpath=//a[contains(@href,'/ManageAccount') and not(contains(@href,'Create')) and not(contains(@href,'STC'))]` | Left sidebar nav under Admin accordion |
| **ManageAccount Listing Grid** | `<div id="ManageAccountGrid">` | `id=ManageAccountGrid` | Main Kendo Grid on ManageAccount page |
| **Create Cost Center Button** | `<a class="btn btn-custom-color">` | `xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]` | React Router `<Link>` rendered as `<a>`; visible only with RW permission AND `RoleWisePermissionOfCostCenter()` |
| **Parent Account (TreeView)** | `<div data-for="parentAccount">` | `xpath=//div[@data-for='parentAccount']` | `TreeViewDropdown` custom component; populated via `getAccountHierarchy()` API |
| **TreeView First Node** | `<li>` inside tree | `xpath=//div[@data-for='parentAccount']//li[1]` | First account node in the hierarchy |
| **TreeView Error Message** | `<span class="error">` | `xpath=//div[@data-for='parentAccount']/following-sibling::*[contains(@class,'error')]` | Joi error: `t("common:t_errorMessage.t_account")` |
| **Account Name Input** | `<input name="accountName" type="text">` | `xpath=//input[@name='accountName']` | `maxLength={100}`; `removeSpecialChar()` applied; semicolons stripped |
| **Account Name Error** | error message | `xpath=//input[@name='accountName']/following-sibling::*[contains(@class,'error')]` | Joi error: `t("t_accountPage.t_errorMessage.t_requiredAccountName")` |
| **Comment Input** | `<input name="comment" type="text">` | `xpath=//input[@name='comment']` | Optional; `maxLength={50}`; `removeSpecialChar()` applied |
| **Submit Button** | `<input type="button" class="btn btn-custom-color width-75">` | `xpath=//input[@type='button' and contains(@class,'btn-custom-color')]` | Value = "Submit" (create mode) / "Update" (edit mode); triggers `submit()` |
| **Close Button** | `<a class="btn btn-cancel-color cursor-pointer width-75">` | `xpath=//a[contains(@class,'btn-cancel-color') and contains(@class,'cursor-pointer')]` | Redirects to `/ManageAccount` in create mode; calls `props.onClose()` in edit mode |
| **Billing Account Expand Icon** | `<a>` in Kendo hierarchy cell | `xpath=//tr[@data-uid][1]//td[contains(@class,'k-hierarchy-cell')]/a` | Expands the detail row for a Billing Account entry |
| **Cost Center Tab (tab9)** | `<li data-name="tab9">` | `xpath=//li[@data-name='tab9']` | Tab inside the expanded detail row; label = `t("t_accountPage.t_CostCenter")` |
| **CostCenter Nested Grid** | `<div id="CostCenterAccount">` | `id=CostCenterAccount` | Kendo Grid rendered inside the expanded detail row when tab9 is active |
| **Edit Button (CostCenter Grid)** | `<a class="k-grid-Edit">` | `xpath=//tr[@data-uid][1]//a[contains(@class,'k-grid-Edit')]` | Scoped to Cost Center grid row; shown only if `accountType === "Cost Center"` AND RW AND `RoleWisePermissionOfCostCenter()` |
| **Delete Button (CostCenter Grid)** | `<a class="k-grid-Delete">` | `xpath=//tr[@data-uid][1]//a[contains(@class,'k-grid-Delete')]` | Shows a Bootstrap `ConfirmBox` modal before deleting |
| **Success Toast** | `<div class="Toastify__toast--success">` | `xpath=//div[contains(@class,'Toastify__toast--success')]` | Displayed when `errorCode === 200` |
| **Error Toast** | `<div class="Toastify__toast--error">` | `xpath=//div[contains(@class,'Toastify__toast--error')]` | Displayed when API returns an error message |

### 9.3 Key Locator Disambiguation Notes

- **Submit button is `<input type="button">`, NOT `<a>` and NOT `<button>`.** Unlike many other CMP create forms (APN, SIM Order, etc.) where Submit is an `<a>` tag, `CreateCostCenter.js` uses `<input type="button" onClick={submit}>`. Always use `xpath=//input[@type='button' and contains(@class,'btn-custom-color')]`.
- **Close button is `<a>` (not a button).** The Close link uses `href="javascript:void(0);"` and the CSS classes `btn-cancel-color cursor-pointer`.
- **`TreeViewDropdown` is not a native `<select>`.** It is a custom React component and cannot be interacted with via `Select From List` keywords. Use `Click Element` to open the tree, wait for nodes to appear, then click the desired node.
- **`tab9` data-name attribute** — The CostCenter tab is identified by `data-name='tab9'` on the `<li>` element rendered by `TabComponent`. The tabs are only visible inside the expanded row of a **Billing Account** (accountTypeId=6 rows show only CostCenterTab + simDetailsSTC; other account types hide the CostCenter tab entirely).
- **Edit/Delete buttons in CostCenterAccount grid** — Both `.k-grid-Edit` and `.k-grid-Delete` are rendered via jQuery in `DataBound`, converting Kendo command buttons to icon-only `<i>` elements. They are only shown when `accountType === "Cost Center"`.

---

## 10. Expected Results

| Step | Expected Outcome |
|---|---|
| Navigate to `/ManageAccount` | ManageAccount listing page loaded; `ManageAccountGrid` visible |
| Create Cost Center button visible | Button visible when user has RW permission AND `RoleWisePermissionOfCostCenter()` returns true |
| Click Create Cost Center | Navigates to `/CreateCostCenter`; form renders with Primary Details accordion panel |
| Open TreeViewDropdown | Account hierarchy tree loads and expands from API |
| Select Parent Account | Tree collapses; selected account name displayed; Joi validation error cleared |
| Type Account Name | Input value updates; `removeSpecialChar()` applied; Joi validation fires; error cleared on valid input |
| Type Comment | Input value updates; optional field — no validation error shown |
| Click Submit | `validateForm()` runs; if valid → `API_Account.createCostCentre(account)` called |
| API returns `errorCode === 200` | Success toast shown with localised message; `history.push("/ManageAccount")` executed |
| Redirect to `/ManageAccount` | ManageAccount listing page loaded; `ManageAccountGrid` visible |
| Expand Billing Account row | Detail row opens with tab list |
| Click Cost Center tab (tab9) | `CostCenterAccount` nested Kendo Grid rendered (`id=CostCenterAccount`) |
| Cost Center grid populated | New Cost Center entry visible in the grid with Account, Account State, Account Status, Parent Account, Billing Flag columns |

---

## 11. Negative Test Scenarios

| # | Scenario | Trigger | Expected Result |
|---|---|---|---|
| NEG-01 | Empty Account Name | Leave Account Name blank; select Parent Account; click Submit | Joi validation error displayed on Account Name field: `t("t_accountPage.t_errorMessage.t_requiredAccountName")`; API not called |
| NEG-02 | No Parent Account selected | Leave TreeViewDropdown empty; enter Account Name; click Submit | Joi validation error displayed on Parent Account field: `t("common:t_errorMessage.t_account")` (requires number ≥ 1) |
| NEG-03 | Both mandatory fields empty | Click Submit without filling any field | Joi validates both fields (`abortEarly: false`); both error messages displayed simultaneously |
| NEG-04 | Account Name exceeds 100 chars | Enter 101+ character Account Name | `maxLength={100}` on the input truncates to 100 chars; Joi validation passes (if within 100 chars) |
| NEG-05 | Comment exceeds 50 chars | Enter 51+ character Comment | `maxLength={50}` on the input truncates to 50 chars |
| NEG-06 | Account Name contains special characters | Enter Account Name with `@`, `#`, `!` etc. | `removeSpecialChar()` strips special characters in real-time on `onChange` |
| NEG-07 | Account Name contains semicolon | Enter `Test;CostCenter` | Semicolon is stripped by `accounts["accountName"] = value.replace(";", "")` |
| NEG-08 | Close without submitting | Fill form fields then click Close | Form discards changes; `closePopup()` calls `history.push("/ManageAccount")`; no API call made |
| NEG-09 | Duplicate Cost Center name | Enter an Account Name already registered under the same parent | API returns `errorCode !== 200`; `toast.error(response?.errorMessage)` displayed; no redirect |
| NEG-10 | Insufficient permissions | Log in as a user without RW or `RoleWisePermissionOfCostCenter() === false` | Create Cost Center button not visible on ManageAccount page; navigating directly to `/CreateCostCenter` may show a permission error |

---

## 12. Validation Keywords

```robot
*** Keywords ***
Verify Parent Account Error Displayed
    Wait Until Element Is Visible    xpath=//div[@data-for='parentAccount']/following-sibling::*[contains(@class,'error')]    timeout=10s

Verify Account Name Error Displayed
    Wait Until Element Is Visible    xpath=//input[@name='accountName']/following-sibling::*[contains(@class,'error')]    timeout=10s

Verify No Account Name Error
    Element Should Not Be Visible    xpath=//input[@name='accountName']/following-sibling::*[contains(@class,'error')]

Verify Create Cost Center Button Visible
    Wait Until Element Is Visible    xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]    timeout=30s

Verify Create Cost Center Button Not Visible
    Element Should Not Be Visible    xpath=//a[contains(@class,'btn-custom-color') and contains(@href,'/CreateCostCenter')]

Verify Success Toast Displayed
    Wait Until Page Contains Element    xpath=//div[contains(@class,'Toastify__toast--success')]    timeout=15s

Verify Error Toast Displayed
    Wait Until Page Contains Element    xpath=//div[contains(@class,'Toastify__toast--error')]    timeout=10s

Verify Redirect To Manage Account
    Wait Until Location Contains    /ManageAccount    timeout=15s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=15s

Open Cost Center Tab In Billing Account
    [Documentation]    Expands the first Billing Account row and clicks the Cost Center tab
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Click Element    xpath=//tr[@data-uid][1]//td[contains(@class,'k-hierarchy-cell')]/a
    Wait Until Element Is Visible    xpath=//li[@data-name='tab9']    timeout=15s
    Click Element    xpath=//li[@data-name='tab9']
    Wait Until Element Is Visible    id=CostCenterAccount    timeout=15s

Verify Cost Center In Grid
    [Arguments]    ${account_name}
    Wait Until Page Contains    ${account_name}    timeout=15s

Verify Edit Delete Buttons Visible In Cost Center Grid
    Wait Until Element Is Visible    xpath=//div[@id='CostCenterAccount']//a[contains(@class,'k-grid-Edit')]    timeout=10s
    Wait Until Element Is Visible    xpath=//div[@id='CostCenterAccount']//a[contains(@class,'k-grid-Delete')]    timeout=10s

Verify Edit Delete Buttons Hidden In Cost Center Grid
    Element Should Not Be Visible    xpath=//div[@id='CostCenterAccount']//a[contains(@class,'k-grid-Edit')]
    Element Should Not Be Visible    xpath=//div[@id='CostCenterAccount']//a[contains(@class,'k-grid-Delete')]
```

---

## 13. Automation Considerations

### 13.1 TreeViewDropdown is Not a Native Select (Critical)

The **Parent Account** field uses a custom `TreeViewDropdown` React component — not a native HTML `<select>`. It renders an account hierarchy tree fetched from `API_Account.getAccountHierarchy()`. Standard Robot Framework keywords like `Select From List By Index` will not work.

Use the following pattern:

```robot
Click Element    xpath=//div[@data-for='parentAccount']
Wait Until Element Is Visible    xpath=//div[@data-for='parentAccount']//li[1]    timeout=15s
Click Element    xpath=//div[@data-for='parentAccount']//li[1]
Sleep    0.5s    # Allow React state to settle after selection
```

If the tree requires expanding nodes (multiple levels), click the expand arrow (`>` icon) on parent nodes before clicking a leaf node.

### 13.2 Submit Button is `<input type="button">` — Not `<a>` or `<button>`

Unlike many other CMP forms (e.g., Create APN, Create SIM Order) where the Submit element is an `<a>` tag, the `CreateCostCenter` form uses:

```html
<input type="button" class="btn btn-custom-color width-75" value="Submit" />
```

Always target it with: `xpath=//input[@type='button' and contains(@class,'btn-custom-color')]`

The **Close** button, in contrast, is an `<a>` tag: `xpath=//a[contains(@class,'btn-cancel-color') and contains(@class,'cursor-pointer')]`

### 13.3 Permission-Gated Create Button

The **Create Cost Center** `<Link>` button is rendered inside a conditional block in `ManageAccountSTC.js`:

```javascript
{this.state.readWritePermission === "RW" && RoleWisePermissionOfCostCenter() &&
    <Link to="/CreateCostCenter" className="btn btn-custom-color cursor-pointer">
        {t("t_accountPage.t_CreateCostCenter")}
    </Link>
}
```

If either condition is `false`, the button is completely absent from the DOM (not hidden — not rendered). Include a check before attempting to click:

```robot
${visible}=    Run Keyword And Return Status    Element Is Visible    ${BTN_CREATE_COST_CENTER}
Run Keyword Unless    ${visible}    Fail    Create Cost Center button not visible — check RW permission and RoleWisePermissionOfCostCenter
```

### 13.4 CostCenter Tab Only Visible for accountTypeId=6

The CostCenter tab (`tab9`) is filtered by `getTabsToShow()` in `ManageAccountSTC.js`:

```javascript
if (accountTypeId === 6) {
    tabList = tabList.filter(tab => ["CostCenterTab", "simDetailsSTC"].includes(tab.id));
} else {
    tabList = tabList.filter(tab => tab.id !== "CostCenterTab");
}
```

This means:
- **Expanding an `accountTypeId=6` row** → shows **only** the CostCenter tab and SIM Details tab
- **Expanding any other account type** → hides the CostCenter tab entirely

Ensure the Billing Account row expanded during verification is of `accountTypeId=6`. Look for a row where the Account Type column displays "Cost Center" or the account type is visually identifiable.

### 13.5 Edit/Delete Buttons Rendered via jQuery DataBound

In `CostCenterAccount.js`, the `DataBound` callback uses jQuery to dynamically replace Kendo command button text with `<i>` icon elements. The buttons are only shown when all three conditions are met:

```javascript
if (this.state.readWritePermission === "RW") {
    if (gridData[i].accountType === "Cost Center") {
        editButton.show();
        DeleteButton.show();
        if (RoleWisePermissionOfCostCenter() === false) {
            editButton.hide();
            DeleteButton.hide();
        }
    }
}
```

Automation should wait for the `DataBound` event to fire and the grid to fully render before asserting icon visibility.

### 13.6 Delete Confirmation Dialog

The `deleteCostCenter` function uses `ConfirmBox()` — a custom SweetAlert-style dialog — before making the delete API call:

```javascript
ConfirmBox(
    t("t_confirmBox.t_deleteCostCenter.t_heading"),
    t("t_confirmBox.t_deleteCostCenter.t_body", { name: dataItem.name }),
    ...
)
```

For delete test scenarios, handle the confirmation dialog with `Alert Should Be Present` or SweetAlert-specific XPath locators before asserting the successful deletion.

### 13.7 Joi Validation Fires on Submit (Not On Blur)

Unlike some fields in other modules that validate `onBlur`, `CreateCostCenter.js` validates on `submit()` via `validateForm()` (full schema validation, `abortEarly: false`). Individual field errors are also shown `onChange` via `validateProperty()`. Automation should trigger `onChange` by typing into fields and then check for errors on Submit click.

### 13.8 Account Name Input Sanitisation

The `handleChange` function applies two layers of sanitisation on every keystroke:

1. `removeSpecialChar(event.nativeEvent.target.value)` — removes special/non-printable characters
2. `accounts["accountName"] = value.replace(";", "")` — removes semicolons

Input Text in Robot Framework directly sets the value but may not trigger `onChange` in all React versions. If the field appears empty after `Input Text`, use:

```robot
Input Text    ${INPUT_ACCOUNT_NAME}    ${ACCOUNT_NAME}
Press Keys    ${INPUT_ACCOUNT_NAME}    SPACE    BACK_SPACE
```

This triggers React's synthetic event system to register the value.

### 13.9 Admin Accordion Must Be Expanded First

The **ManageAccount** link in the left-side navigation panel is nested under the **Admin** accordion group. If the Admin accordion is collapsed, the ManageAccount link will not be visible. Expand the Admin menu first:

```robot
${admin_expanded}=    Run Keyword And Return Status    Element Is Visible    ${NAV_MANAGE_ACCOUNT}
Run Keyword Unless    ${admin_expanded}    Click Element    xpath=//a[contains(@href,'#admin') or contains(@class,'admin-accordion')]
Wait Until Element Is Visible    ${NAV_MANAGE_ACCOUNT}    timeout=10s
```

### 13.10 SSL Certificate Bypass

The CMP application uses self-signed SSL certificates. Always launch Chrome with:

```python
--ignore-certificate-errors
--disable-web-security
--allow-running-insecure-content
```

---

## 14. Framework Recommendation

| Framework | Suitability | Notes |
|---|---|---|
| **Robot Framework + SeleniumLibrary** | ✅ Recommended | Matches existing TC_001–TC_012 suite; best for team-wide keyword sharing |
| **Playwright (Python/JS)** | ✅ Excellent | Better handling of React `onChange` events; `page.fill()` triggers synthetic events reliably |
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
ACCOUNT_NAME = "Test Cost Center Automation"
COMMENT = "Automation test cost center"

def test_create_cost_center():
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

        # Navigate to ManageAccount via left navigation
        page.click("a[href*='/ManageAccount']:not([href*='Create']):not([href*='STC'])")
        page.wait_for_url(re.compile(r"/ManageAccount"))
        page.wait_for_selector("#ManageAccountGrid")

        # Click Create Cost Center button
        page.wait_for_selector("a.btn-custom-color[href*='/CreateCostCenter']")
        page.click("a.btn-custom-color[href*='/CreateCostCenter']")
        page.wait_for_url(re.compile(r"/CreateCostCenter"))
        page.wait_for_selector("input[name='accountName']")

        # Select Parent Account from TreeViewDropdown
        page.click("div[data-for='parentAccount']")
        page.wait_for_selector("div[data-for='parentAccount'] li:first-child")
        page.click("div[data-for='parentAccount'] li:first-child")
        page.wait_for_selector("div[data-for='parentAccount'] li:first-child", state="hidden")

        # Fill Account Name
        page.fill("input[name='accountName']", ACCOUNT_NAME)

        # Fill Comment (optional)
        page.fill("input[name='comment']", COMMENT)

        # Verify no validation errors before submit
        assert not page.is_visible("input[name='accountName'] ~ .error"), "Account Name should have no error"

        # Click Submit button (input type=button — not <a> or <button>)
        page.click("input[type='button'].btn-custom-color")

        # Verify success toast
        page.wait_for_selector("div.Toastify__toast--success", timeout=15000)

        # Verify redirect to ManageAccount
        page.wait_for_url(re.compile(r"/ManageAccount"), timeout=15000)
        page.wait_for_selector("#ManageAccountGrid")

        # Optional: Expand a Billing Account row and check the Cost Center tab
        page.click("tr[data-uid]:first-child td.k-hierarchy-cell a")
        page.wait_for_selector("li[data-name='tab9']")
        page.click("li[data-name='tab9']")
        page.wait_for_selector("#CostCenterAccount")
        assert ACCOUNT_NAME in page.content(), f"Cost Center '{ACCOUNT_NAME}' should appear in the grid"

        print("TC_013 PASSED: Cost Center created successfully")
        browser.close()
```

---

## 16. Success Validation Checklist

```
□ Navigate to ManageAccount module via Admin left sidebar
□ ManageAccountGrid renders with account listing
□ Create Cost Center button is visible (RW permission + RoleWisePermissionOfCostCenter() = true)
□ Clicking Create Cost Center navigates to /CreateCostCenter
□ Primary Details accordion panel is rendered on the form page
□ TreeViewDropdown (parentAccount) opens on click and loads account hierarchy
□ First account node is selectable; tree closes after selection
□ Joi validation error on parentAccount is cleared after valid selection
□ Account Name input accepts text (max 100 chars)
□ removeSpecialChar() and semicolon stripping active on every keystroke
□ Joi validation error on accountName is cleared after valid entry
□ Comment input accepts text (max 50 chars); field is optional
□ Submit button (input type=button, value="Submit") is visible and clickable
□ validateForm() fires on Submit click; all Joi errors shown when fields invalid
□ API_Account.createCostCentre(account) called with { parentAccount, accountName, comment }
□ API returns errorCode === 200
□ Success toast displayed with localised message (t_Created_Cost_Centre_Account)
□ Redirect to /ManageAccount after success
□ ManageAccountGrid is visible on listing page
□ Expanding a Billing Account row (accountTypeId=6) shows CostCenter tab (tab9)
□ Clicking tab9 renders CostCenterAccount nested Kendo Grid (id=CostCenterAccount)
□ New Cost Center appears in the CostCenterAccount grid with correct Account Name, Account State, Account Type = "Cost Center", Parent Account, Billing Flag columns
□ Edit and Delete buttons visible in grid for "Cost Center" account type rows (when RW and RoleWisePermissionOfCostCenter())
□ Close button on Create form redirects to /ManageAccount without submitting
```

---

## 17. Current Project Implementation

This section documents the **actual implementation** in the project, mapping back to the Robot Framework files.

### Project Files

| Content | Location |
|---------|----------|
| Test cases (25 tests) | `tests/cost_center_tests.robot` |
| Keywords | `resources/keywords/cost_center_keywords.resource` |
| Locators | `resources/locators/cost_center_locators.resource` |
| Variables / Test data | `variables/cost_center_variables.py` |
| Browser setup | `resources/keywords/browser_keywords.resource` |
| Login keywords | `resources/keywords/login_keywords.resource` |

### Run Command

```bash
robot --outputdir reports tests/cost_center_tests.robot
```

### Test Case List (25 tests)

| ID | Name | Type |
|----|------|------|
| TC_CC_001 | Navigate To ManageAccount Page | positive |
| TC_CC_002 | Verify Create Cost Center Button Visible | positive |
| TC_CC_003 | Open Create Cost Center Form | positive |
| TC_CC_004 | Verify All Form Fields Present | positive |
| TC_CC_005 | Verify Parent Account TreeView Has Nodes | positive |
| TC_CC_006 | Verify Submit Button Is Present And Enabled | positive |
| TC_CC_007 | Create Cost Center With All Fields | positive |
| TC_CC_008 | Create Cost Center Without Comment | positive |
| TC_CC_009 | Verify No Validation Errors With Valid Data | positive |
| TC_CC_010 | Submit With Empty Account Name | negative |
| TC_CC_011 | Submit Without Selecting Parent Account | negative |
| TC_CC_012 | Submit With Both Mandatory Fields Empty | negative |
| TC_CC_013 | Submit With Only Spaces In Account Name | negative |
| TC_CC_014 | Duplicate Cost Center Name | negative |
| TC_CC_015 | Account Name Exceeds 100 Characters | negative |
| TC_CC_016 | Account Name Exactly 100 Characters | edge |
| TC_CC_017 | Comment Exceeds 50 Characters | negative |
| TC_CC_018 | Comment Exactly 50 Characters | edge |
| TC_CC_020 | Account Name With Semicolons Stripped | edge |
| TC_CC_021 | Close Form Without Submitting | negative |
| TC_CC_022 | Close Empty Form | negative |
| TC_CC_023 | Close After Selecting Only Parent Account | negative |
| TC_CC_024 | Expand Billing Account And Verify Cost Center Tab | positive |
| TC_CC_025 | Open Cost Center Tab And Verify Grid Loads | positive |
| TC_CC_026 | Verify Edit Delete Buttons In Cost Center Grid | positive |

> **Note:** TC_CC_019 was deleted (special characters test removed due to account name sanitization issues).

### Key Implementation Details

- **Browser Session:** Suite-level login (login once); test-level refresh of ManageAccount page
- **Parent Account TreeView:** Hierarchical expansion KSA_OPCO → SANJ_1002 → billingAccountSANJ_1003 using JavaScript-based TreeView expansion
- **Cost Center Tab:** Located dynamically by searching for "Cost Center" text within tab list (not hardcoded to tab9)
- **Submit Button:** `<input type="button">` — not `<a>` or `<button>`
- **Page Load Waits:** Uses `Wait For App Loading To Complete` keyword after navigation and form submission

---

## 18. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-10 | CMP QA / Automation Team | Initial document — Create Cost Center workflow; sourced from `CreateCostCenter.js`, `CostCenterAccount.js`, `BillingAccount.js`, `ManageAccountSTC.js` |
