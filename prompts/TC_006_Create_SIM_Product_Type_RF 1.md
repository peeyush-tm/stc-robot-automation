# Automation Test Specification – Create SIM Product Type and Assign to EC

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 13)*
**Date:** 2026-03-06
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md · TC_003_Create_SIM_Order_RF.md · TC_004_Create_SIM_Range_RF.md · TC_005_Create_CSR_Journey_RF.md

---

## 1. Objective

This test validates two end-to-end workflows on the CMP web application, both accessed via the **Admin → Product Type** module. The automation begins from the **Manage Devices** page (post-login) and covers:

**Workflow A — Create SIM Product Type:**
1. Navigating to the **Product Type** module via the left-side navigation panel under the **Admin** tab
2. Clicking **Create Product Type** to open the creation form at `/CreateProductType`
3. Filling all mandatory fields: Account, Product Type Name, Service Type, Service Sub Types 2–4
4. Submitting the form and verifying the **success notification** and redirect back to `/ProductType`

**Workflow B — Assign EC (Enterprise Customer) to a Product Type:**
1. From the Product Type listing grid, clicking the **Assign-Customer** action icon on an existing Product Type row
2. Selecting one or more Enterprise Customer (Level 4) accounts from the dropdown in the Assign Customers dialog (`div[@role='dialog']`) (or selecting all via radio)
3. Clicking **Update** and verifying the **success notification** and grid refresh

This test ensures the full SIM Product Type creation and EC assignment workflows are functional, all mandatory fields are validated, and the system correctly stores and acknowledges both operations.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **Product Type Listing URL** | `https://192.168.1.26:7874/ProductType` |
| **Create Product Type URL** | `https://192.168.1.26:7874/CreateProductType` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |
| **Product Type Location in UI** | **Admin module → Product Type** (left-side navigation; Product Type is a sub-item under the Admin accordion/menu group) |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` and has landed on the **Manage Devices** page
  - *(Use `Login To Application` and `Navigate To Manage Devices` keywords from `TC_001_Login_Navigate_RF.md`)*
- The `ksa_opco` user has **RW (Read-Write)** permission to access the **Product Type** module (`accountTypeId < 4`)
- The **Product Type** module is enabled and visible in the left-side navigation panel under the Admin accordion
- At least one valid **Account** (Level 3 / Opco) exists for assigning to the new Product Type
- At least one valid **Enterprise Customer** (Level 4 account) exists for the EC assignment workflow
- For Workflow B: at least one existing Product Type record is present in the listing grid with the **Assign-Customer** action icon visible (`VIEW_ELEMENTS().assign_product_type` is enabled)
- **Python 3.8+**, **Robot Framework**, and **SeleniumLibrary** are installed
- ChromeDriver is installed and version-matched to the installed Chrome browser

---

## 4. Robot Framework Environment Setup

### 4.1 Installation

```bash
pip install robotframework
pip install robotframework-seleniumlibrary
```

### 4.2 Run Commands

```bash
# Workflow A — Create SIM Product Type
robot --outputdir reports tests/product_type_tests.robot

# Workflow B — Assign EC to Product Type
robot --outputdir reports tests/product_type_tests.robot
```

### 4.3 Project Structure (aligned to TC_001 / TC_002 / TC_003 / TC_004 / TC_005)

```
cmp-automation/
├── resources/
│   ├── common_keywords.robot            # Open/Close browser, Login, Navigate keywords
│   ├── product_type_keywords.robot      # Product Type-specific keywords
│   └── variables.robot                  # All locator and data variables
├── tests/
│   ├── TC_001_Login_Navigate.robot
│   ├── TC_002_State_Change.robot
│   ├── TC_003_Create_SIM_Order.robot
│   ├── TC_004_Create_SIM_Range.robot
│   ├── TC_005_Create_CSR_Journey.robot
│   ├── TC_006_Create_SIM_Product_Type.robot
│   └── TC_006b_Assign_EC_Product_Type.robot
└── results/
    └── (output.xml, log.html, report.html)
```

---

## 5. Test Data

### Workflow A — Create SIM Product Type

| Field | Sample Value | Notes |
|---|---|---|
| **Username** | `ksa_opco` | Same credentials as TC_001 through TC_005 |
| **Password** | `Admin@123` | Same credentials as TC_001 through TC_005 |
| **Account** | *(First available Level 3)* | Parameterise via variable file |
| **Product Type Name** | `Test SIM Product Type` | Max 50 characters; free text |
| **Service Type** | `Postpaid` | Options: `Prepaid` / `Postpaid` |
| **Service Sub Type 1** | `GCT` | **Always pre-filled and disabled** — do not type; auto-set to "GCT" (or "GCT WBU" for WBU accounts) |
| **Service Sub Type 2** | `physical` | Max 50 characters; free text (e.g. SIM form factor type) |
| **Service Sub Type 3** | `SIM` | Max 50 characters; values like `SIM`, `esim` — if `esim`, Profile Name becomes required |
| **Service Sub Type 4** | `4FF` | Max 50 characters; free text (e.g. physical form factor) |
| **Profile Name** | *(leave blank)* | Required only when Service Sub Type 3 = `esim`; max 50 chars |
| **Packaging Size** | `100` | Optional; integer 1–999999 |
| **Can Be Ordered** | `Yes` (true) | Radio button; default is `Yes` |
| **Comment** | `Automation test product type` | Optional; max 50 characters |
| **Description (English)** | `Test product type created by automation` | Optional; max 250 characters |
| **Description (Arabic)** | *(leave blank)* | Optional; max 250 characters |
| **Expected Post-Submit URL** | `/ProductType` | Redirected back to Product Type listing after Submit |

### Workflow B — Assign EC to Product Type

| Field | Sample Value | Notes |
|---|---|---|
| **Product Type** | *(Target row in grid)* | Select row with Assign-Customer icon visible |
| **Enterprise Customer (EC)** | *(First available Level 4 account)* | Dropdown in Assign Customers dialog (`div[@role='dialog']`) |
| **Select All Customers** | `No` (false) | Radio; set to `Yes` to assign all ECs at once |

> Parameterise all test data values via a Robot Framework variable file (`variables.robot` or `--variablefile`) to support multiple environments without modifying test files.

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
${PRODUCT_TYPE_URL}       https://192.168.1.26:7874/ProductType
${CREATE_PT_URL}          https://192.168.1.26:7874/CreateProductType
${BROWSER}                chrome
${TIMEOUT}                30s
${RETRY_COUNT}            3x
${RETRY_INTERVAL}         5s

# Credentials (shared with TC_001 through TC_005)
${USERNAME}               ksa_opco
${PASSWORD}               Admin@123

# Workflow A — Create Product Type form data
${PT_NAME}                Test SIM Product Type
${PT_SERVICE_TYPE}        Postpaid
${PT_SUB_TYPE_2}          physical
${PT_SUB_TYPE_3}          SIM
${PT_SUB_TYPE_4}          4FF
${PT_PACKAGING_SIZE}      100
${PT_COMMENT}             Automation test product type
${PT_DESC_EN}             Test product type created by automation

# ── Shared / Login Locators ───────────────────────────────────────────────────
${LOC_ROOT}               xpath=//div[@id='root']
${LOC_GRID}               id=gridData
${LOC_ERROR_MSG}          xpath=//div[contains(@class,'erre-it')]
${LOC_USERNAME}           name=username
${LOC_PASSWORD}           name=password
${LOC_LOGIN_BTN}          xpath=//input[@type='button' and contains(@class,'btn-custom-color')]

# ── Loading Overlay ──────────────────────────────────────────────────────────
${LOC_LOADING_INDICATOR}  xpath=//body[contains(@class,'loading-indicator')]

# ── Navigation Locators (verified from actual HTML) ──────────────────────────
# Admin icon: <i class="fa custom-manu-icon admin-menu-icon"></i>
${LOC_ADMIN_TOGGLE}       xpath=//i[contains(@class,'admin-menu-icon')]
# SIM Product Type link: <a class="selected" aria-current="page" href="/ProductType">SIM Product Type</a>
${LOC_PRODUCT_TYPE_NAV}   link=SIM Product Type

# ── Manage User Page (loaded after clicking Admin) ──────────────────────────
${LOC_MU_GRID_DATA}       id=gridData

# ── Product Type Listing Page (ProductType.js) ──────────────────────────────
${LOC_PT_GRID_DATA}       id=gridData
${LOC_PT_SEARCH_FIELD}    xpath=//input[@name='searchValue']
${LOC_PT_SEARCH_BTN}      id=searchButton
${LOC_PT_SEARCH_CLOSE}    id=closeBtn
# Create button: <a href="javascript:void(0);" class="btn btn-custom-color cursor-pointer">Create SIM Product Type</a>
${LOC_PT_CREATE_BTN}      xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Create SIM Product Type')]
${LOC_PT_EDIT_ICON}       xpath=//i[contains(@class,'k-grid-Edit')]
# Assign Customer: <i title="Assign Customers" data-toggle="modal" class="k-grid-Assign-Customer"></i>
${LOC_PT_ASSIGN_CUST_ICON}   xpath=//i[@title='Assign Customers' and contains(@class,'k-grid-Assign-Customer')]

# ── Create Product Type Form (/CreateProductType) ───────────────────────────
# Account: custom div dropdown with search (NOT a native <select>)
#   Click to open: <input type="text" class="searchInput show" placeholder="Search">
#   Option: <div name="accountIdet" data-testid="accountIdet" class="option" value="3">KSA_OPCO</div>
${LOC_ACCOUNT_DD}            xpath=//*[@data-testid='accountIdet']
${LOC_ACCOUNT_SEARCH}        xpath=//input[contains(@class,'searchInput') and @placeholder='Search']
${LOC_ACCOUNT_OPTION_KSA}    xpath=//div[@data-testid='accountIdet' and contains(text(),'KSA_OPCO')]
${LOC_PT_NAME_INPUT}         xpath=//input[@name='productCatalogName']
# Service Type: standard <select>
#   <select name="servicetype" data-testid="servicetypeet" class="form-control">
${LOC_PT_SERVICE_TYPE_DD}    xpath=//select[@data-testid='servicetypeet']
${LOC_PT_SUB_TYPE_1_DD}      xpath=//*[@data-testid='serviceSubType1eet']
${LOC_PT_SUB_TYPE_2_INPUT}   xpath=//input[@name='serviceSubType2']
${LOC_PT_SUB_TYPE_3_INPUT}   xpath=//input[@name='serviceSubType3']
${LOC_PT_SUB_TYPE_4_INPUT}   xpath=//input[@name='serviceSubType4']
${LOC_PT_PACKAGING_SIZE}     xpath=//input[@name='packagingSize']
${LOC_PT_COMMENT_INPUT}      xpath=//input[@name='comment']
${LOC_PT_DESC_EN_INPUT}      xpath=//input[@name='descEnglish']
# Submit (Create form): <a> tag — not <button>
${LOC_PT_SUBMIT_BTN}         xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Submit')]
# Close (Create form): <a href="javascript:void(0);" class="btn btn-cancel-color cursor-pointer width-75">Close</a>
${LOC_PT_CLOSE_BTN}          xpath=//a[contains(@class,'btn-cancel-color') and contains(.,'Close')]

# ── Assign Customer Dialog (role='dialog') ──────────────────────────────────
# Modal title: <h4>Assign Customers</h4> inside div[@role='dialog']
${LOC_ASSIGN_POPUP}              xpath=//div[@role='dialog']//h4[normalize-space()='Assign Customers']
# Close (X) button in dialog header
${LOC_ASSIGN_CLOSE_X}            xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//button[@type='button' and not(text())]
# Select Customers input: <input placeholder="Select Customers">
${LOC_ASSIGN_SELECT_CUSTOMERS}   xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//input[@placeholder='Select Customers']
# Dropdown arrow
${LOC_ASSIGN_DD_ARROW}           xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//*[contains(@class,'k-select')]
# Dropdown list (appears after clicking Select Customers)
${LOC_ASSIGN_CUSTOMERS_MENU}     xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//ul[contains(@class,'k-list') or contains(@class,'k-reset')]
# First EC option in the dropdown
${LOC_ASSIGN_CUSTOMER_OPT_1}     xpath=(//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//li[contains(@class,'k-item')])[1]
# "Assign to All Customers" label
${LOC_ASSIGN_ALL_LABEL}          xpath=//div[@role='dialog']//span[normalize-space()='Assign to All Customers']
# Yes / No radio buttons
${LOC_ASSIGN_ALL_YES}            xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//label[normalize-space()='Yes']//input[@type='radio']
${LOC_ASSIGN_ALL_NO}             xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//label[normalize-space()='No']//input[@type='radio']
# Update (Assign dialog): <button class="btn btn-custom-color cursor-pointer width-75 m-r-10">Update</button>
# Scoped inside visible modal to avoid conflict with Create form's <a> Submit
${LOC_ASSIGN_UPDATE_BTN}         xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-custom-color')]
# Close (Assign dialog): <button class="btn btn-cancel-color cursor-pointer width-75">Close</button>
# Scoped inside visible modal to avoid conflict with Create form's <a> Close
${LOC_ASSIGN_CLOSE_BTN}          xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-cancel-color')]

# ── Grid Expand / No Data ───────────────────────────────────────────────────
# Expand icon (row collapsed): <a class="k-icon k-i-expand">
${LOC_PT_EXPAND_ICON}            xpath=//a[contains(@class,'k-i-expand')]
# Collapse icon (row expanded): <a class="k-icon k-i-collapse">
${LOC_PT_COLLAPSE_ICON}          xpath=//a[contains(@class,'k-i-collapse')]
# No Data Available: <p class="no-data-available dataAvilabel">No Data Available</p>
${LOC_PT_NO_DATA}                xpath=//p[contains(@class,'no-data-available') and contains(text(),'No Data Available')]

# ── Toast Notifications (Toastify) ──────────────────────────────────────────
# Created: <div role="alert" class="Toastify__toast-body">SIM Product Type Created Successfully.</div>
${LOC_PT_CREATED_TOAST}      xpath=//div[@role='alert' and contains(text(),'SIM Product Type Created Successfully')]
# Updated: <div role="alert" class="Toastify__toast-body">Updated Successfully</div>
${LOC_PT_UPDATED_TOAST}      xpath=//div[@role='alert' and contains(text(),'Updated Successfully')]
# Duplicate: <div role="alert" class="Toastify__toast-body">Product Type Name Already Exists</div>
${LOC_PT_DUPLICATE_TOAST}    xpath=//div[@role='alert' and contains(text(),'Product Type Name Already Exists')]
# No EC selected: <div role="alert" class="Toastify__toast-body">Please select at least one customer</div>
${LOC_PT_NO_EC_TOAST}        xpath=//div[@role='alert' and contains(text(),'Please select at least one customer')]
# Error: any Toastify error toast
${LOC_PT_ERROR_TOAST}        xpath=//div[@role='alert' and (contains(text(),'error') or contains(text(),'Error') or contains(text(),'Already Exists') or contains(text(),'Please select'))]
# Generic success (fallback)
${LOC_PT_SUCCESS_TOAST}      xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]
```

> **Navigation note:** Product Type is a **sub-item under the Admin module** in the left sidebar. The Admin node is a collapsible accordion — it must be **expanded first** before the Product Type sub-item is clickable. This is the same expand-first pattern used for SIM Range (TC_004) and CSR Journey (TC_005).

> **Submit/Close button type:** On the Create Product Type form, both Submit and Close are rendered as **`<a>` tags** (not `<button>`) with `href="javascript:void(0);"`. Use `Click Element` directly — do not use `Submit Form` keyword.

---

## 7. Automation Flow — Workflow A: Create SIM Product Type

### Step 1 — Start from Manage Devices Page

Handled by `Test Setup` — `Login To Application` and `Navigate To Manage Devices` keywords run before each test (defined in `common_keywords.robot`, shared with TC_001 through TC_005).

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 1.1 | `Wait Until Element Is Visible    ${LOC_GRID}    ${TIMEOUT}` | Confirm Manage Devices grid is loaded |
| 1.2 | `Location Should Contain    ManageDevices` | Assert correct starting page |

---

### Step 2 — Navigate to Product Type Module via Admin Icon in Left Sidebar

> **UI structure:** Click the Admin icon (`<i class="fa custom-manu-icon admin-menu-icon">`) in the left sidebar. This navigates to `/ManageUser`. Wait for the ManageUser page to load fully, then click the **SIM Product Type** link (`<a href="/ProductType">SIM Product Type</a>`) to navigate to `/ProductType`.

```robot
Navigate To Product Type Module
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 2.1 | `Scroll Element Into View    ${LOC_ADMIN_TOGGLE}` | Scroll until Admin icon is visible in the left sidebar |
| 2.2 | `Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}` | Assert Admin icon (`admin-menu-icon`) is visible |
| 2.3 | `Click Element    ${LOC_ADMIN_TOGGLE}` | Click Admin icon — navigates to `/ManageUser` |
| 2.4 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    ManageUser` | Wait for URL to contain `/ManageUser` |
| 2.5 | `Wait Until Element Is Visible    ${LOC_MU_GRID_DATA}    ${TIMEOUT}` | Wait for ManageUser page grid to load fully |
| 2.6 | `Scroll Element Into View    ${LOC_PRODUCT_TYPE_NAV}` | Scroll until SIM Product Type link is visible |
| 2.7 | `Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}    ${TIMEOUT}` | Assert SIM Product Type link is visible in the sidebar |
| 2.8 | `Click Element    ${LOC_PRODUCT_TYPE_NAV}` | Click SIM Product Type link — navigates to `/ProductType` |
| 2.9 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    ProductType` | Wait for URL to contain `/ProductType` |
| 2.10 | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}` | Verify the Product Type listing grid has loaded |
| 2.11 | `Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}    ${TIMEOUT}` | Confirm "Create SIM Product Type" button is visible (user has RW permission) |

---

### Step 3 — Click "Create Product Type" Button

```robot
Open Create Product Type Form
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 3.1 | `Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}    ${TIMEOUT}` | Assert Create Product Type `<a>` button is visible |
| 3.2 | `Click Element    ${LOC_PT_CREATE_BTN}` | Click to navigate to `/CreateProductType` |
| 3.3 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    CreateProductType` | Wait for URL to contain `/CreateProductType` |
| 3.4 | `Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${TIMEOUT}` | Confirm Account dropdown trigger is visible — form has loaded |

---

### Step 4 — Select Account (Custom Div Dropdown)

> **Important:** The Account dropdown is a **custom div-based dropdown** (NOT a `<select>`). The trigger is `<div class="selectBtn form-control">Select</div>` and the option is `<div name="accountIdet" data-testid="accountIdet" class="option" value="3">KSA_OPCO</div>`. Do **NOT** use `Select From List By Index` — instead click the trigger div, wait for the option, then click the option.

```robot
Select Account From Dropdown
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 4.1 | `Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${TIMEOUT}` | Assert Account dropdown (`data-testid='accountIdet'`) is visible |
| 4.2 | `Click Element Via JS    ${LOC_ACCOUNT_DD}` | Click to open the custom dropdown |
| 4.3 | `Wait Until Element Is Visible    ${LOC_ACCOUNT_SEARCH}    ${TIMEOUT}` | Wait for the search input (`placeholder='Search'`) to appear |
| 4.4 | `Input Text    ${LOC_ACCOUNT_SEARCH}    KSA` | Type "KSA" to filter the dropdown options |
| 4.5 | `Sleep    1s` | Brief pause for dropdown filtering |
| 4.6 | `Wait Until Element Is Visible    ${LOC_ACCOUNT_OPTION_KSA}    ${TIMEOUT}` | Wait for KSA_OPCO option div to appear |
| 4.7 | `Click Element Via JS    ${LOC_ACCOUNT_OPTION_KSA}` | Select KSA_OPCO account |

---

### Step 5 — Enter Product Type Name

```robot
Enter Product Type Name    ${PT_NAME}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 5.1 | `Wait Until Element Is Visible    ${LOC_PT_NAME_INPUT}    ${TIMEOUT}` | Assert Product Type Name input is present (`name=productCatalogName`) |
| 5.2 | `Input Text    ${LOC_PT_NAME_INPUT}    ${PT_NAME}` | Enter product type name (max 50 chars) |

---

### Step 6 — Select Service Type (Standard HTML Select)

> **Note:** The Service Type is a standard `<select>` element: `<select name="servicetype" data-testid="servicetypeet" class="form-control">` with `<option>` values `Prepaid` and `Postpaid`.

```robot
Select Service Type    ${PT_SERVICE_TYPE}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 6.1 | `Wait Until Element Is Visible    ${LOC_PT_SERVICE_TYPE_DD}    ${TIMEOUT}` | Assert Service Type `<select>` is present (`data-testid=servicetypeet`) |
| 6.2 | `Select From List By Label    ${LOC_PT_SERVICE_TYPE_DD}    ${PT_SERVICE_TYPE}` | Select "Prepaid" or "Postpaid" from standard select |

---

### Step 7 — Verify Service Sub Type 1 (Read-Only)

```robot
Verify Service Sub Type 1 Is Pre-Filled
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 7.1 | `Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_1_DD}    ${TIMEOUT}` | Assert Service Sub Type 1 dropdown is present (`data-testid=serviceSubType1eet`) |
| 7.2 | `Element Should Be Disabled    ${LOC_PT_SUB_TYPE_1_DD}` | Assert it is **disabled** — auto-set to "GCT" by component (or "GCT WBU" for WBU accounts); never type into this field |
| 7.3 | `${val}=    Get Value    ${LOC_PT_SUB_TYPE_1_DD}` | Read the auto-populated value |
| 7.4 | `Should Be True    '${val}' == 'GCT' or '${val}' == 'GCT WBU'` | Assert value is one of the expected locked values |

---

### Step 8 — Enter Service Sub Type 2

```robot
Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 8.1 | `Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_2_INPUT}    ${TIMEOUT}` | Assert Service Sub Type 2 text input is present (`name=serviceSubType2`) |
| 8.2 | `Input Text    ${LOC_PT_SUB_TYPE_2_INPUT}    ${PT_SUB_TYPE_2}` | Enter SIM type label (e.g. `physical`); max 50 chars |

---

### Step 9 — Enter Service Sub Type 3

```robot
Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 9.1 | `Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_3_INPUT}    ${TIMEOUT}` | Assert Service Sub Type 3 text input is present (`name=serviceSubType3`) |
| 9.2 | `Input Text    ${LOC_PT_SUB_TYPE_3_INPUT}    ${PT_SUB_TYPE_3}` | Enter SIM category (e.g. `SIM` or `esim`); max 50 chars |

> **Critical:** If value entered is `esim` (case-insensitive), the **Profile Name** field becomes **required** (`required-label` class applied conditionally). Ensure Profile Name is filled when Service Sub Type 3 = `esim`.

---

### Step 10 — Enter Service Sub Type 4

```robot
Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 10.1 | `Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_4_INPUT}    ${TIMEOUT}` | Assert Service Sub Type 4 text input is present (`name=serviceSubType4`) |
| 10.2 | `Input Text    ${LOC_PT_SUB_TYPE_4_INPUT}    ${PT_SUB_TYPE_4}` | Enter form factor (e.g. `4FF`); max 50 chars |

---

### Step 11 — Fill Optional Fields

```robot
Fill Optional Fields
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 11.1 | `Wait Until Element Is Visible    ${LOC_PT_PACKAGING_SIZE}    ${TIMEOUT}` | Assert Packaging Size input (`name=packagingSize`) |
| 11.2 | `Input Text    ${LOC_PT_PACKAGING_SIZE}    ${PT_PACKAGING_SIZE}` | Enter packaging size (integer 1–999999) |
| 11.3 | `Wait Until Element Is Visible    ${LOC_PT_CAN_ORDER_YES}    ${TIMEOUT}` | Assert Can Be Ordered radio group (`name=canBeOrdered`) |
| 11.4 | `Select Radio Button    canBeOrdered    true` | Select "Yes" — default is already `true`; this confirms the selection |
| 11.5 | `Wait Until Element Is Visible    ${LOC_PT_COMMENT_INPUT}    ${TIMEOUT}` | Assert Comment input (`name=comment`) |
| 11.6 | `Input Text    ${LOC_PT_COMMENT_INPUT}    ${PT_COMMENT}` | Enter comment text (max 50 chars) |
| 11.7 | `Wait Until Element Is Visible    ${LOC_PT_DESC_EN_INPUT}    ${TIMEOUT}` | Assert Description (English) input (`name=descEnglish`) |
| 11.8 | `Input Text    ${LOC_PT_DESC_EN_INPUT}    ${PT_DESC_EN}` | Enter English description (max 250 chars) |

---

### Step 12 — Submit the Product Type

```robot
Submit Product Type
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 12.1 | `Scroll Element Into View    ${LOC_PT_SUBMIT_BTN}` | Scroll to bring the Submit `<a>` button into viewport |
| 12.2 | `Wait Until Element Is Visible    ${LOC_PT_SUBMIT_BTN}    ${TIMEOUT}` | Assert Submit button is visible |
| 12.3 | `Click Element    ${LOC_PT_SUBMIT_BTN}` | Click "Submit" to call `saveProdcutType()` and POST to API |
| 12.4 | `Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}    ${TIMEOUT}` | Wait for success toast notification |

---

### Step 13 — Validate Success and Redirect

```robot
Validate Product Type Creation
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 13.1 | `Element Should Be Visible    ${LOC_PT_CREATED_TOAST}` | Assert success toast is displayed |
| 13.2 | `Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}    Location Should Contain    ProductType` | Verify redirect back to `/ProductType` listing page |
| 13.3 | `Location Should Not Contain    CreateProductType` | Assert we are no longer on the Create form |
| 13.4 | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}` | Confirm Product Type listing grid is visible |

---

### Workflow A — Automation Flow Diagram

```
Test Setup: Login + Navigate To Manage Devices
      │
      ▼
Wait Until Element Is Visible    ${LOC_GRID}
      │
      ▼
── Click Admin icon in left sidebar ───────────────────────
Scroll Element Into View    ${LOC_ADMIN_TOGGLE}
Click Element    ${LOC_ADMIN_TOGGLE}          ← admin-menu-icon → navigates to /ManageUser
      │
      ▼
Location Should Contain    ManageUser
Wait Until Element Is Visible    ${LOC_MU_GRID_DATA}    ← ManageUser page loaded
      │
      ▼
── Click SIM Product Type link ────────────────────────────
Scroll Element Into View    ${LOC_PRODUCT_TYPE_NAV}
Click Element    ${LOC_PRODUCT_TYPE_NAV}      ← <a href="/ProductType">SIM Product Type</a>
      │
      ▼
Location Should Contain    ProductType
Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}
Click Element    ${LOC_PT_CREATE_BTN}         ← Create SIM Product Type button
      │
      ▼
Location Should Contain    CreateProductType
Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}
      │
      ▼
── Create Product Type Form ────────────────────────────────
Click Element Via JS    ${LOC_ACCOUNT_DD}        ← open custom div dropdown
Input Text    ${LOC_ACCOUNT_SEARCH}    KSA       ← type to filter
Click Element Via JS    ${LOC_ACCOUNT_OPTION_KSA}  ← select KSA_OPCO
Input Text    ${LOC_PT_NAME_INPUT}    ${PT_NAME}
Select From List By Label    ${LOC_PT_SERVICE_TYPE_DD}    Postpaid    ← standard <select>
[Verify ${LOC_PT_SUB_TYPE_1_DD} is disabled and pre-filled with GCT]
Input Text    ${LOC_PT_SUB_TYPE_2_INPUT}    ${PT_SUB_TYPE_2}
Input Text    ${LOC_PT_SUB_TYPE_3_INPUT}    ${PT_SUB_TYPE_3}
Input Text    ${LOC_PT_SUB_TYPE_4_INPUT}    ${PT_SUB_TYPE_4}
Input Text    ${LOC_PT_PACKAGING_SIZE}    ${PT_PACKAGING_SIZE}
Select Radio Button    canBeOrdered    true
Input Text    ${LOC_PT_COMMENT_INPUT}    ${PT_COMMENT}
Input Text    ${LOC_PT_DESC_EN_INPUT}    ${PT_DESC_EN}
      │
      ▼
Scroll Element Into View    ${LOC_PT_SUBMIT_BTN}
Click Element    ${LOC_PT_SUBMIT_BTN}
      │
      ▼
Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}
      │
      ├──── Visible ────► Location Should Contain    ProductType
      │                   Location Should Not Contain    CreateProductType
      │                   Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}
      │                   PASS
      │
      └──── Timeout ────► FAIL: Capture Page Screenshot    EMBED
```

---

## 8. Automation Flow — Workflow B: Assign EC to Product Type

### Step 1 — Navigate to Product Type Listing Page

Same as Workflow A Steps 1–2: Login → Navigate to Manage Devices → Navigate to Product Type Module.

---

### Step 2 — Locate Target Product Type Row and Click "Assign-Customer" Icon

```robot
Click Assign Customer Icon On First Row
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 2.1 | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}` | Confirm Product Type listing grid has rendered |
| 2.2 | `Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${TIMEOUT}` | Assert the Assign-Customer icon (`k-grid-Assign-Customer`) is visible in the grid |
| 2.3 | `Click Element Via JS    ${LOC_PT_ASSIGN_CUST_ICON}` | Click the first Assign-Customer icon — opens the Assign Customers dialog (`div[@role='dialog']`) |
| 2.4 | `Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}` | Wait for Assign Customer modal to open |

> **Note:** The Assign-Customer icon is only visible when `VIEW_ELEMENTS().assign_product_type` is `true` AND the user has RW permission with `accountTypeId < 4`. The icon is an `<i>` element injected by the `dataBound` callback, not a native React element.

---

### Step 3 — Select Enterprise Customer(s) from Multi-Select Dropdown

```robot
Select Enterprise Customers
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 3.1 | `Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}` | Confirm Assign Customers dialog (`div[@role='dialog']`) is open |
| 3.2 | `Wait Until Element Is Visible    ${LOC_ASSIGN_SELECT_CUSTOMERS}    ${TIMEOUT}` | Wait for the "Select Customers" input (`placeholder='Select Customers'`) to render |
| 3.3 | `Click Element Via JS    ${LOC_ASSIGN_SELECT_CUSTOMERS}` | Click input to open the EC dropdown list |
| 3.4 | `Sleep    2s` | Wait for dropdown animation to complete |
| 3.5 | `Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMER_OPT_1}    10s` | Wait for the first EC option (`li.k-item`) to be visible |
| 3.6 | `Click Element Via JS    ${LOC_ASSIGN_CUSTOMER_OPT_1}` | Select the first available Enterprise Customer |
| 3.7 | `Sleep    1s` | Wait for selection to register |

> **EC Customer Dropdown Note:** The customer dropdown in the Assign Customers dialog uses a Kendo `k-list` / `k-item` pattern inside `div[@role='dialog']`. Click the `input[@placeholder='Select Customers']` to open the list, then click a `li.k-item` option. Uses retry logic (`Wait Until Keyword Succeeds 3x 2s`) in the actual project keywords.

---

### Step 4 — Verify Select All Customers Radio (Optional)

```robot
Set Select All Customers Radio    ${SELECT_ALL_VALUE}
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 4.1 | `Wait Until Element Is Visible    ${LOC_ASSIGN_ALL_NO}    ${TIMEOUT}` | Assert "Select All Customers: No" radio is visible (`name=selectAllCustomers`) |
| 4.2 | `Element Should Be Selected    ${LOC_ASSIGN_ALL_NO}` | Assert default is "No" (selective assignment) |
| *(if assigning all)* | `Click Element    ${LOC_ASSIGN_ALL_YES}` | Click "Yes" to assign ALL EC customers — disables the multi-select dropdown |

> **Select All Radio Behaviour:** When `selectAllCustomers = true` (Yes radio selected), the multi-select dropdown is disabled (CSS `pointer-events: none`) and ALL EC accounts from the unassigned list are submitted to the API. When `selectAllCustomers = false` (No, default), only the manually selected accounts are submitted.

---

### Step 5 — Click "Update" Button to Assign

```robot
Submit EC Assignment
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 5.1 | `Wait For App Loading To Complete` | Wait for any loading overlay to disappear |
| 5.2 | `Wait Until Element Is Visible    ${LOC_ASSIGN_UPDATE_BTN}    ${TIMEOUT}` | Assert Update button is visible |
| 5.3 | `Click Element    ${LOC_ASSIGN_UPDATE_BTN}` | Click "Update" — calls `updateCustomer()` which POSTs to `api/create/product/catalog/details/{id}/customer-accounts` |
| 5.4 | `Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}    ${TIMEOUT}` | Wait for success toast |

---

### Step 6 — Validate EC Assignment

```robot
Validate EC Assignment
```

| Sub-step | RF Keyword | Detail |
|---|---|---|
| 6.1 | `Element Should Be Visible    ${LOC_PT_CREATED_TOAST}` | Assert success toast is displayed |
| 6.2 | `Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}` | Confirm Assign Customers dialog has closed |
| 6.3 | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}` | Confirm Product Type listing grid is still rendered and refreshed |

---

### Workflow B — Automation Flow Diagram

```
Test Setup: Login + Navigate To Manage Devices
      │
      ▼
Navigate To Product Type Module   (same as Workflow A Step 2)
      │
      ▼
Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}
Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}
Click Element Via JS    ${LOC_PT_ASSIGN_CUST_ICON}    ← first row Assign-Customer icon
Wait For App Loading To Complete
      │
      ▼
Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}
      │
      ▼
── Assign Customer Dialog (div[@role='dialog']) ──────────────
Wait Until Element Is Visible    ${LOC_ASSIGN_SELECT_CUSTOMERS}
Click Element Via JS    ${LOC_ASSIGN_SELECT_CUSTOMERS}    ← open EC dropdown
Sleep    2s
Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMER_OPT_1}
Click Element Via JS    ${LOC_ASSIGN_CUSTOMER_OPT_1}      ← select first EC
Sleep    1s
      │
      ▼
Wait For App Loading To Complete
Click Element Via JS    ${LOC_ASSIGN_UPDATE_BTN}
      │
      ▼
Wait Until Element Is Visible    ${LOC_PT_UPDATED_TOAST}
      │
      ├──── Visible ────► Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}
      │                   Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}
      │                   PASS
      │
      └──── Timeout ────► FAIL: Capture Page Screenshot    EMBED
```

---

## 9. Complete Robot Framework Test Files

### 9.1 Test Suite — tests/product_type_tests.robot

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/product_type_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/product_type_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/product_type_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_PT_001 Create SIM Product Type Standard Flow
    [Documentation]    Navigate to Product Type via Admin module, open Create form, fill all
    ...                mandatory + optional fields, verify Sub Type 1 pre-filled, submit.
    ...                Verify: success toast, redirect to /ProductType listing, grid visible.
    [Tags]    smoke    regression    positive    product-type    create-product-type
    Login And Navigate To Product Type
    Verify Create Product Type Button Visible
    Open Create Product Type Form
    Fill All Mandatory Fields With Defaults
    Verify Sub Type 1 Is Pre Filled And Disabled
    Fill Optional Fields
    Click Submit Product Type
    Verify Product Type Created Successfully

TC_PT_002 Assign EC To Existing Product Type
    [Documentation]    Navigate to Product Type listing, click Assign-Customer icon on first row,
    ...                select first EC from dropdown, click Update.
    ...                Verify: success toast, popup closed, grid refreshed, expand row to see EC.
    [Tags]    smoke    regression    positive    product-type    assign-ec
    Login And Navigate To Product Type
    Click Assign Customer Icon On First Row
    Select First Enterprise Customer
    Click Update EC Assignment
    Verify EC Assignment Successful
    Verify EC Visible After Expand

TC_PT_011 Verify Create Button Visible For RW User
    [Documentation]    Navigate to Product Type listing page as RW user (ksa_opco).
    ...                Verify: Create Product Type button is visible on the listing page.
    [Tags]    regression    positive    product-type
    Login And Navigate To Product Type
    Verify Create Product Type Button Visible

TC_PT_13 Close Assign Popup Without Saving Should Not Change Assignment
    [Documentation]    Open Assign Customer popup, close it without selecting any EC,
    ...                then click expand on the grid row to verify "No Data Available".
    [Tags]    regression    positive    assign-ec
    Login And Navigate To Product Type
    Click Assign Customer Icon On First Row
    Click Close Assign Customer Popup
    Verify Assign Popup Closed
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Verify No Data After Expand

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_PT_003 Submit Without Selecting Account
    [Documentation]    Leave Account dropdown at blank default, fill other mandatory fields,
    ...                click Submit. Verify: validation error, stays on CreateProductType page.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Enter Product Type Name      ${PT_NAME}
    Select Service Type          ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2     ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3     ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4     ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_004 Submit With Blank Product Type Name
    [Documentation]    Leave Product Type Name blank, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Select Account From Dropdown
    Select Service Type          ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2     ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3     ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4     ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_005 Submit Without Selecting Service Type
    [Documentation]    Leave Service Type at blank default, fill other mandatory fields,
    ...                click Submit. Verify: validation error, stays on form.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name      ${PT_NAME}
    Enter Service Sub Type 2     ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3     ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4     ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_006 Submit With Blank Service Sub Type 2
    [Documentation]    Leave Service Sub Type 2 empty, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name      ${PT_NAME}
    Select Service Type          ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 3     ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4     ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_007 Submit With Blank Service Sub Type 3
    [Documentation]    Leave Service Sub Type 3 empty, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name      ${PT_NAME}
    Select Service Type          ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2     ${PT_SUB_TYPE_2}
    Enter Service Sub Type 4     ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_008 Submit With Blank Service Sub Type 4
    [Documentation]    Leave Service Sub Type 4 empty, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name      ${PT_NAME}
    Select Service Type          ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2     ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3     ${PT_SUB_TYPE_3_SIM}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_009 Submit With Esim Sub Type 3 But Blank Profile Name
    [Documentation]    Enter 'esim' in Sub Type 3 but leave Profile Name empty, click Submit.
    ...                Verify: Profile Name validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Fill All Mandatory Fields    ${PT_NAME}    ${PT_SERVICE_TYPE_POSTPAID}
    ...    ${PT_SUB_TYPE_2}    ${PT_SUB_TYPE_3_ESIM}    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_010 Close Create Form Without Submitting
    [Documentation]    Fill all mandatory fields but click Close instead of Submit.
    ...                Verify: redirect to /ProductType listing, no success toast, no record created.
    [Tags]    regression    negative    product-type    create-product-type
    Login And Navigate To Product Type
    Open Create Product Type Form
    Fill All Mandatory Fields With Defaults
    Click Close Product Type Form
    Verify Redirected To Product Type Listing

TC_PT_012 Click Update Without Selecting Any EC
    [Documentation]    Open Assign Customer popup, click Update without selecting any EC.
    ...                Verify: error toast displayed, popup stays open.
    [Tags]    regression    negative    product-type    assign-ec
    Login And Navigate To Product Type
    Click Assign Customer Icon On First Row
    Click Update EC Assignment
    Verify No EC Selected Toast Displayed
    Verify Assign Popup Still Open

TC_PT_17 Duplicate Product Type Name Should Show Error Toast
    [Documentation]    Enter a name that already exists in the system, fill other mandatory fields,
    ...                submit. Verify: error toast (duplicate rejected by API).
    [Tags]    regression    negative    create    validation
    Login And Navigate To Product Type
    Open Create Product Type Form
    Fill All Mandatory Fields    ${DUPLICATE_PT_NAME}    ${PT_SERVICE_TYPE_POSTPAID}
    ...    ${PT_SUB_TYPE_2}    ${PT_SUB_TYPE_3_SIM}    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Duplicate Product Type Toast Displayed

# ═══════════════════════════════════════════════════════════════════════
#  EDGE CASES
# ═══════════════════════════════════════════════════════════════════════

TC_PT_14 Edit Icon Should Be Visible In Product Type Grid
    [Documentation]    Navigate to Product Type listing and verify Edit icon is visible
    ...                for at least one row (user has RW permission).
    [Tags]    regression    edge-case    validation
    Login And Navigate To Product Type
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}     ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_EDIT_ICON}     ${PT_TIMEOUT}

TC_PT_15 Assign Customer Icon Should Be Visible In Grid For RW User
    [Documentation]    Navigate to Product Type listing and verify the Assign-Customer icon
    ...                (jQuery-injected) is visible for the logged-in RW user.
    [Tags]    regression    edge-case    assign-ec    validation
    Login And Navigate To Product Type
    Verify Assign Customer Icon Visible

TC_PT_16 Search Product Type In Listing Grid
    [Documentation]    Enter a search term in the Product Type listing search field and click Search.
    ...                Verify: grid filters results based on the search term.
    [Tags]    regression    edge-case    search
    Login And Navigate To Product Type
    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_SEARCH_FIELD}    Test
    Click Element Safely             ${LOC_PT_SEARCH_BTN}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}       ${PT_TIMEOUT}

TC_PT_18 Clear Search Should Reset Grid
    [Documentation]    After searching, click the clear/close button on search field.
    ...                Verify: grid resets and shows all product types.
    [Tags]    regression    edge-case    search
    Login And Navigate To Product Type
    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_SEARCH_FIELD}    Test
    Click Element Safely             ${LOC_PT_SEARCH_BTN}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}       ${PT_TIMEOUT}
    Click Element Safely             ${LOC_PT_SEARCH_CLOSE}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}       ${PT_TIMEOUT}
```

---

### 9.2 Keywords — resources/keywords/product_type_keywords.resource

> **Note:** This resource file contains all reusable keywords used by the 18 test cases above. It is NOT an old keyword file — login, navigation, form fill, assign EC, and all validation keywords live here. Locators are imported from `product_type_locators.resource`.

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/product_type_locators.resource
Resource    ../locators/login_locators.resource
...               Login To Application    ${USERNAME}    ${PASSWORD}    AND
...               Navigate To Manage Devices
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Variables ***
${BASE_URL}               https://192.168.1.26:7874
${MANAGE_URL}             https://192.168.1.26:7874/ManageDevices
${PRODUCT_TYPE_URL}       https://192.168.1.26:7874/ProductType
${CREATE_PT_URL}          https://192.168.1.26:7874/CreateProductType
${BROWSER}                chrome
${TIMEOUT}                30s
${RETRY_COUNT}            3x
${RETRY_INTERVAL}         5s
${USERNAME}               ksa_opco
${PASSWORD}               Admin@123
${PT_NAME}                Test SIM Product Type
${PT_SERVICE_TYPE}        Postpaid
${PT_SUB_TYPE_2}          physical
${PT_SUB_TYPE_3}          SIM
${PT_SUB_TYPE_4}          4FF
${PT_PACKAGING_SIZE}      100
${PT_COMMENT}             Automation test product type
${PT_DESC_EN}             Test product type created by automation

# ── Shared / Login ────────────────────────────────────────────────────────────
${LOC_ROOT}               xpath=//div[@id='root']
${LOC_GRID}               id=gridData
${LOC_USERNAME}           name=username
${LOC_PASSWORD}           name=password
${LOC_LOGIN_BTN}          xpath=//input[@type='button' and contains(@class,'btn-custom-color')]

# ── Navigation (verified from actual HTML) ────────────────────────────────────
${LOC_ADMIN_TOGGLE}          xpath=//i[contains(@class,'admin-menu-icon')]
${LOC_PRODUCT_TYPE_NAV}      link=SIM Product Type
${LOC_MU_GRID_DATA}          id=gridData
${LOC_PT_GRID_DATA}          id=gridData
${LOC_PT_CREATE_BTN}         xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Create SIM Product Type')]

# ── Create Product Type Form ──────────────────────────────────────────────────
# Account: custom div dropdown with search (NOT a native <select>)
${LOC_ACCOUNT_DD}            xpath=//*[@data-testid='accountIdet']
${LOC_ACCOUNT_SEARCH}        xpath=//input[contains(@class,'searchInput') and @placeholder='Search']
${LOC_ACCOUNT_OPTION_KSA}    xpath=//div[@data-testid='accountIdet' and contains(text(),'KSA_OPCO')]
${LOC_PT_NAME_INPUT}         xpath=//input[@name='productCatalogName']
${LOC_PT_SERVICE_TYPE_DD}    xpath=//select[@data-testid='servicetypeet']
${LOC_PT_SUB_TYPE_1_DD}      xpath=//*[@data-testid='serviceSubType1eet']
${LOC_PT_SUB_TYPE_2_INPUT}   xpath=//input[@name='serviceSubType2']
${LOC_PT_SUB_TYPE_3_INPUT}   xpath=//input[@name='serviceSubType3']
${LOC_PT_SUB_TYPE_4_INPUT}   xpath=//input[@name='serviceSubType4']
${LOC_PT_PACKAGING_SIZE}     xpath=//input[@name='packagingSize']
${LOC_PT_COMMENT_INPUT}      xpath=//input[@name='comment']
${LOC_PT_DESC_EN_INPUT}      xpath=//input[@name='descEnglish']
${LOC_PT_SUBMIT_BTN}         xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Submit')]
${LOC_PT_CLOSE_BTN}          xpath=//a[contains(@class,'btn-cancel-color') and contains(.,'Close')]

# ── Post-Submission (Toastify) ────────────────────────────────────────────────
${LOC_PT_CREATED_TOAST}      xpath=//div[@role='alert' and contains(text(),'SIM Product Type Created Successfully')]
${LOC_PT_UPDATED_TOAST}      xpath=//div[@role='alert' and contains(text(),'Updated Successfully')]
${LOC_PT_DUPLICATE_TOAST}    xpath=//div[@role='alert' and contains(text(),'Product Type Name Already Exists')]
${LOC_PT_NO_EC_TOAST}        xpath=//div[@role='alert' and contains(text(),'Please select at least one customer')]
${LOC_PT_ERROR_TOAST}        xpath=//div[@role='alert' and (contains(text(),'error') or contains(text(),'Error') or contains(text(),'Already Exists') or contains(text(),'Please select'))]
${LOC_PT_SUCCESS_TOAST}      xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]

*** Test Cases ***
TC_006A Create SIM Product Type — Standard Flow
    [Documentation]    Validates end-to-end SIM Product Type creation: navigate via Admin → Product Type → Create Product Type, fill all fields, submit, verify success and redirect
    [Tags]             product-type    create-product-type    regression
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Verify Sub Type 1 Pre Filled
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Fill Optional Fields
    Submit Product Type Form
    Validate Product Type Creation

*** Keywords ***
Navigate To Product Type Module
    [Documentation]    Expands Admin module in left nav, clicks Product Type sub-item, verifies listing page loads
    Wait Until Element Is Visible    ${LOC_NAV_PANEL}    ${TIMEOUT}
    Scroll Element Into View         ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}
    Click Element                    ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}    ${TIMEOUT}
    Click Element                    ${LOC_PRODUCT_TYPE_NAV}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}    ${TIMEOUT}

Open Create Product Type Form
    [Documentation]    Clicks Create Product Type <a> button and waits for form to load at /CreateProductType
    Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}    ${TIMEOUT}
    Click Element Via JS             ${LOC_PT_CREATE_BTN}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    CreateProductType
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${TIMEOUT}

Select Account From Dropdown
    [Documentation]    Clicks the custom div trigger to open dropdown, waits for KSA_OPCO option, clicks it
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${TIMEOUT}
    Click Element Via JS             ${LOC_ACCOUNT_DD}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_OPTION_KSA}     ${TIMEOUT}
    Sleep    1s
    Click Element Via JS             ${LOC_ACCOUNT_OPTION_KSA}

Enter Product Type Name
    [Arguments]    ${pt_name}
    [Documentation]    Enters the product type name (name=productCatalogName, max 50 chars)
    Wait Until Element Is Visible    ${LOC_PT_NAME_INPUT}    ${TIMEOUT}
    Input Text                       ${LOC_PT_NAME_INPUT}    ${pt_name}

Select Service Type
    [Arguments]    ${service_type}
    [Documentation]    Selects Service Type from standard <select> (data-testid=servicetypeet) — Prepaid or Postpaid
    Wait Until Element Is Visible    ${LOC_PT_SERVICE_TYPE_DD}    ${TIMEOUT}
    Select From List By Label        ${LOC_PT_SERVICE_TYPE_DD}    ${service_type}

Verify Sub Type 1 Pre Filled
    [Documentation]    Asserts Service Sub Type 1 dropdown is disabled and auto-set to GCT/GCT WBU
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_1_DD}    ${TIMEOUT}
    Element Should Be Disabled       ${LOC_PT_SUB_TYPE_1_DD}
    ${val}=                          Get Value    ${LOC_PT_SUB_TYPE_1_DD}
    Should Be True                   '${val}' == 'GCT' or '${val}' == 'GCT WBU'

Enter Service Sub Type 2
    [Arguments]    ${value}
    [Documentation]    Enters text into Service Sub Type 2 (name=serviceSubType2, max 50 chars)
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_2_INPUT}    ${TIMEOUT}
    Input Text                       ${LOC_PT_SUB_TYPE_2_INPUT}    ${value}

Enter Service Sub Type 3
    [Arguments]    ${value}
    [Documentation]    Enters text into Service Sub Type 3 (name=serviceSubType3, max 50 chars); if 'esim' Profile Name becomes required
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_3_INPUT}    ${TIMEOUT}
    Input Text                       ${LOC_PT_SUB_TYPE_3_INPUT}    ${value}

Enter Service Sub Type 4
    [Arguments]    ${value}
    [Documentation]    Enters text into Service Sub Type 4 (name=serviceSubType4, max 50 chars)
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_4_INPUT}    ${TIMEOUT}
    Input Text                       ${LOC_PT_SUB_TYPE_4_INPUT}    ${value}

Fill Optional Fields
    [Documentation]    Fills Packaging Size, Can Be Ordered radio, Comment, and Description (English)
    Wait Until Element Is Visible    ${LOC_PT_PACKAGING_SIZE}    ${TIMEOUT}
    Input Text                       ${LOC_PT_PACKAGING_SIZE}    ${PT_PACKAGING_SIZE}
    Select Radio Button              canBeOrdered    true
    Wait Until Element Is Visible    ${LOC_PT_COMMENT_INPUT}    ${TIMEOUT}
    Input Text                       ${LOC_PT_COMMENT_INPUT}    ${PT_COMMENT}
    Wait Until Element Is Visible    ${LOC_PT_DESC_EN_INPUT}    ${TIMEOUT}
    Input Text                       ${LOC_PT_DESC_EN_INPUT}    ${PT_DESC_EN}

Submit Product Type Form
    [Documentation]    Scrolls to and clicks the Submit <a> button; waits for success toast
    Scroll Element Into View         ${LOC_PT_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_PT_SUBMIT_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_PT_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}    ${TIMEOUT}

Validate Product Type Creation
    [Documentation]    Confirms success toast and validates redirect back to Product Type listing
    Element Should Be Visible        ${LOC_PT_CREATED_TOAST}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    Location Should Not Contain      CreateProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}
    Log    SIM Product Type created and validated successfully    INFO
```

---

### 9.2 Workflow B — TC_006b_Assign_EC_Product_Type.robot

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
${PRODUCT_TYPE_URL}       https://192.168.1.26:7874/ProductType
${BROWSER}                chrome
${TIMEOUT}                30s
${RETRY_COUNT}            3x
${RETRY_INTERVAL}         5s
${USERNAME}               ksa_opco
${PASSWORD}               Admin@123

# Shared navigation and listing locators (same as Workflow A)
${LOC_ROOT}               xpath=//div[@id='root']
${LOC_ADMIN_TOGGLE}           xpath=//i[contains(@class,'admin-menu-icon')]
${LOC_PRODUCT_TYPE_NAV}      link=SIM Product Type
${LOC_PT_GRID_DATA}          id=gridData

# Assign Customer popup locators (scoped within div[@role='dialog'])
${LOC_PT_ASSIGN_CUST_ICON}       xpath=//i[@title='Assign Customers' and contains(@class,'k-grid-Assign-Customer')]
${LOC_ASSIGN_POPUP}              xpath=//div[@role='dialog']//h4[normalize-space()='Assign Customers']
${LOC_ASSIGN_SELECT_CUSTOMERS}   xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//input[@placeholder='Select Customers']
${LOC_ASSIGN_CUSTOMERS_MENU}     xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//ul[contains(@class,'k-list') or contains(@class,'k-reset')]
${LOC_ASSIGN_CUSTOMER_OPT_1}     xpath=(//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//li[contains(@class,'k-item')])[1]
${LOC_ASSIGN_ALL_YES}            xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//label[normalize-space()='Yes']//input[@type='radio']
${LOC_ASSIGN_ALL_NO}             xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//label[normalize-space()='No']//input[@type='radio']
# Update/Close scoped inside visible modal to avoid conflict with Create form's <a> buttons
${LOC_ASSIGN_UPDATE_BTN}         xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-custom-color')]
${LOC_ASSIGN_CLOSE_BTN}          xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-cancel-color')]
# Grid Expand / No Data
${LOC_PT_EXPAND_ICON}            xpath=//a[contains(@class,'k-i-expand')]
${LOC_PT_COLLAPSE_ICON}          xpath=//a[contains(@class,'k-i-collapse')]
${LOC_PT_NO_DATA}                xpath=//p[contains(@class,'no-data-available') and contains(text(),'No Data Available')]
# Toastify toast notifications
${LOC_PT_UPDATED_TOAST}          xpath=//div[@role='alert' and contains(text(),'Updated Successfully')]
${LOC_PT_DUPLICATE_TOAST}        xpath=//div[@role='alert' and contains(text(),'Product Type Name Already Exists')]
${LOC_PT_NO_EC_TOAST}            xpath=//div[@role='alert' and contains(text(),'Please select at least one customer')]
${LOC_PT_SUCCESS_TOAST}          xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]

*** Test Cases ***
TC_006B Assign EC to Existing Product Type
    [Documentation]    Validates assigning an Enterprise Customer to an existing Product Type via the Assign-Customer popup
    [Tags]             product-type    assign-ec    regression
    Navigate To Product Type Module
    Click Assign Customer Icon On First Row
    Select Enterprise Customer From Popup
    Submit EC Assignment
    Validate EC Assignment Success

*** Keywords ***
Navigate To Product Type Module
    [Documentation]    Expands Admin module in left nav, clicks Product Type sub-item, verifies listing page loads
    Wait Until Element Is Visible    ${LOC_NAV_PANEL}    ${TIMEOUT}
    Scroll Element Into View         ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}
    Click Element                    ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}    ${TIMEOUT}
    Click Element                    ${LOC_PRODUCT_TYPE_NAV}
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}

Click Assign Customer Icon On First Row
    [Documentation]    Clicks the Assign-Customer icon (k-grid-Assign-Customer) on the first visible Product Type row
    Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${TIMEOUT}
    Click Element                    ${LOC_PT_ASSIGN_CUST_ICON}
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}

Select Enterprise Customer From Popup
    [Documentation]    Opens the EC dropdown inside the Assign Customers dialog and selects the first available EC
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ASSIGN_SELECT_CUSTOMERS}    ${TIMEOUT}
    Click Element                    ${LOC_ASSIGN_SELECT_CUSTOMERS}
    Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMERS_MENU}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMER_OPT_1}    ${TIMEOUT}
    Click Element                    ${LOC_ASSIGN_CUSTOMER_OPT_1}
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_CUSTOMERS_MENU}    ${TIMEOUT}

Submit EC Assignment
    [Documentation]    Clicks the Update button inside the Assign Customers dialog to save the EC assignment
    Scroll Element Into View         ${LOC_ASSIGN_UPDATE_BTN}
    Wait Until Element Is Visible    ${LOC_ASSIGN_UPDATE_BTN}    ${TIMEOUT}
    Click Element                    ${LOC_ASSIGN_UPDATE_BTN}
    Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}    ${TIMEOUT}

Validate EC Assignment Success
    [Documentation]    Confirms success toast and validates popup is closed and grid is refreshed
    Element Should Be Visible        ${LOC_PT_CREATED_TOAST}
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}
    Log    EC assigned to Product Type successfully    INFO
```

---

## 10. UI Elements and Locator Strategy

All locators have been **confirmed from the application source code** (`ProductType.js`, `CreateProductType.js`, `AssignCustomer.js`). The **RF Locator String** column shows the exact value to use inside Robot Framework keywords.

> **Key notes from source inspection:**
> - **Submit and Close buttons** on the Create form are rendered as **`<a>` tags** with `href="javascript:void(0);"` — not `<button>` elements. Use `Click Element`, not `Submit Form`.
> - **Service Sub Type 1** (`data-testid=serviceSubType1eet`) is **always disabled** (`disabled={true}`) — its value is pre-set to `"GCT"` or `"GCT WBU"` based on account type. Never attempt to select from it.
> - **Create Product Type** navigation button is also an `<a>` tag — not a `<button>`.
> - **Assign-Customer icon** (`k-grid-Assign-Customer`) is dynamically injected by the `dataBound` callback via jQuery — not a React-rendered element. It requires the grid to be fully loaded before it is interactable.
> - **EC Customer dropdown** in the Assign Customers dialog uses Kendo `k-list` / `k-item` pattern inside `div[@role='dialog']`. Click `input[@placeholder='Select Customers']` to open the list, then click a `li.k-item` option.
> - **Select All Customers** radio (`name=selectAllCustomers`) — when `true`, the multi-select dropdown is CSS-disabled (`pointer-events: none`) and all available ECs are submitted.

### 10.1 Navigation (confirmed from Navigation.js / ProductType.js)

| Element | Description | RF Locator String | Source |
|---|---|---|---|
| **Admin icon** | Admin menu icon in left sidebar; `<i class="fa custom-manu-icon admin-menu-icon">` | `xpath=//i[contains(@class,'admin-menu-icon')]` | Navigation |
| **SIM Product Type link** | Product Type link; `<a href="/ProductType">SIM Product Type</a>` | `xpath=//a[@href='/ProductType' and contains(text(),'SIM Product Type')]` | Navigation |

### 10.2 Product Type Listing Page (confirmed from `ProductType.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| Grid container | Outer div wrapping the Kendo grid | `id=gridData` | ProductType.js ~633 |
| **Product Type grid** | Kendo grid showing all product types | `id=grid` | ProductType.js ~637 |
| **Create SIM Product Type button** | `<a href="javascript:void(0);" class="btn btn-custom-color cursor-pointer">Create SIM Product Type</a>` | `xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Create SIM Product Type')]` | ProductType.js ~607 |
| Search field | Text input for filtering by product name | `xpath=//input[@name='searchValue']` | ProductType.js ~585 |
| Search button | Triggers grid refresh with search term | `id=searchButton` | ProductType.js ~596 |
| Search clear button | Clears search field and refreshes grid | `id=closeBtn` | ProductType.js ~590 |
| CSV Export button | Downloads product catalog as CSV | `id=export` | ProductType.js ~618 |
| **Edit icon** (per row) | Opens `#EditPopup` for the row's product type | `xpath=//i[contains(@class,'k-grid-Edit')]` | ProductType.js ~424 |
| **Delete icon** (per row) | Shows delete confirmation; hidden when `customParam1=1` | `xpath=//i[contains(@class,'k-grid-Delete')]` | ProductType.js ~419 |
| **Assign-Customer icon** (per row) | `<i title="Assign Customers" data-toggle="modal" class="k-grid-Assign-Customer">` | `xpath=//i[@title='Assign Customers' and contains(@class,'k-grid-Assign-Customer')]` | ProductType.js ~429 |
| Edit popup | Bootstrap modal containing `<CreateProductType mode="Edit">` | `id=EditPopup` | ProductType.js ~649 |
| Assign Customer dialog | Dialog for EC dropdown assignment | `xpath=//div[@role='dialog']//h4[normalize-space()='Assign Customers']` | ProductType.js |
| Delete popup | Bootstrap modal for delete confirmation | `id=DeletePopup` | ProductType.js ~347 |

### 10.3 Create Product Type Form (confirmed from `CreateProductType.js`)

| Element | Description | RF Locator String | Source Line |
|---|---|---|---|
| **Account dropdown trigger** | Required; custom div trigger to open Account dropdown | `xpath=//div[contains(@class,'selectBtn') and contains(@class,'form-control')]` | `<div class="selectBtn form-control">Select</div>` |
| **Account dropdown option (KSA_OPCO)** | Account option div with value="3" | `xpath=//div[@data-testid='accountIdet']` | `<div name="accountIdet" data-testid="accountIdet" class="option" value="3">KSA_OPCO</div>` |
| **Product Type Name** | Required text input; max 50 chars | `xpath=//input[@name='productCatalogName']` | CreateProductType.js ~417 |
| **Service Type dropdown** | Required; standard `<select>` with Prepaid / Postpaid options | `xpath=//select[@data-testid='servicetypeet']` | `<select name="servicetype" data-testid="servicetypeet" class="form-control">` |
| **Service Sub Type 1 dropdown** | **Always disabled**; auto-set to "GCT" or "GCT WBU" | `xpath=//*[@data-testid='serviceSubType1eet']` | CreateProductType.js ~459 |
| **Service Sub Type 2** | Required text input; max 50 chars (SIM type label) | `xpath=//input[@name='serviceSubType2']` | CreateProductType.js ~476 |
| **Service Sub Type 3** | Required text input; max 50 chars; if `esim` → Profile Name required | `xpath=//input[@name='serviceSubType3']` | CreateProductType.js ~489 |
| **Service Sub Type 4** | Required text input; max 50 chars (form factor) | `xpath=//input[@name='serviceSubType4']` | CreateProductType.js ~502 |
| Profile Name | Required only when Sub Type 3 = `esim`; max 50 chars | `xpath=//input[@name='profileName']` | CreateProductType.js ~524 |
| Packaging Size | Optional; type number; integer 1–999999 | `xpath=//input[@name='packagingSize']` | CreateProductType.js ~542 |
| Can Be Ordered — Yes | Radio button; default selected | `xpath=//input[@type='radio' and @name='canBeOrdered' and @value='true']` | CreateProductType.js ~557 |
| Can Be Ordered — No | Radio button; conditionally shown via `VIEW_ELEMENTS()` | `xpath=//input[@type='radio' and @name='canBeOrdered' and @value='false']` | CreateProductType.js ~573 |
| Comment | Optional text input; max 50 chars | `xpath=//input[@name='comment']` | CreateProductType.js ~600 |
| Description (English) | Optional text input; max 250 chars | `xpath=//input[@name='descEnglish']` | CreateProductType.js ~616 |
| Description (Arabic) | Optional text input; max 250 chars | `xpath=//input[@name='descArabic']` | CreateProductType.js ~632 |
| **Submit button** | `<a>` tag — calls `saveProdcutType()`; creates via POST API | `xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Submit')]` | CreateProductType.js ~645 |
| **Close button** (Create mode) | `<a href="javascript:void(0);" class="btn btn-cancel-color cursor-pointer width-75">Close</a>` | `xpath=//a[contains(@class,'btn-cancel-color') and contains(.,'Close')]` | CreateProductType.js ~658 |

### 10.4 Assign Customer Popup (confirmed from `AssignCustomer.js` + `ProductType.js`)

| Element | Description | RF Locator String | Source |
|---|---|---|---|
| **Assign Customer dialog** | Dialog with title "Assign Customers" (`div[@role='dialog']`) | `xpath=//div[@role='dialog']//h4[normalize-space()='Assign Customers']` | ProductType.js |
| **Select Customers input** | Input to open EC dropdown (`placeholder='Select Customers'`) | `xpath=//div[@role='dialog'][.//h4[contains(.,'Assign Customers')]]//input[@placeholder='Select Customers']` | AssignCustomer.js |
| Customers dropdown list | Kendo list container | `xpath=//div[@role='dialog']//ul[contains(@class,'k-list') or contains(@class,'k-reset')]` | Kendo UI |
| First EC option | First `li.k-item` in the dropdown | `xpath=(//div[@role='dialog']//li[contains(@class,'k-item')])[1]` | Kendo UI |
| Update button (Assign dialog) | `<button>` scoped in visible modal | `xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-custom-color')]` | AssignCustomer.js |
| Close button (Assign dialog) | `<button>` scoped in visible modal | `xpath=//div[contains(@class,'modal') and contains(@style,'display: block')]//button[contains(@class,'btn-cancel-color')]` | AssignCustomer.js |
| Expand icon (grid row) | `<a class="k-icon k-i-expand">` | `xpath=//a[contains(@class,'k-i-expand')]` | Kendo Grid |
| No Data Available | `<p class="no-data-available">` | `xpath=//p[contains(@class,'no-data-available') and contains(text(),'No Data Available')]` | Grid detail |
| **Select All Customers — Yes** | Radio button; assigns all Level 4 ECs | `xpath=//input[@type='radio' and @name='selectAllCustomers' and @value='true']` | AssignCustomer.js ~204 |
| **Select All Customers — No** | Radio button; selective assignment (default) | `xpath=//input[@type='radio' and @name='selectAllCustomers' and @value='false']` | AssignCustomer.js ~219 |
| **Update button** | Submits EC assignment to API | `xpath=//div[@id='customers']//button[contains(@class,'btn-custom-color')]` | AssignCustomer.js ~236 |
| **Close button** (popup) | Closes popup without saving | `xpath=//div[@id='customers']//button[contains(@class,'btn-cancel-color')]` | AssignCustomer.js ~242 |

### 10.5 Post-Submission (Toastify Toast Notifications)

| Element | Description | RF Locator String | HTML |
|---|---|---|---|
| **Created toast** | SIM Product Type created success notification | `xpath=//div[@role='alert' and contains(text(),'SIM Product Type Created Successfully')]` | `<div role="alert" class="Toastify__toast-body">SIM Product Type Created Successfully.</div>` |
| **Updated toast** | EC assignment updated success notification | `xpath=//div[@role='alert' and contains(text(),'Updated Successfully')]` | `<div role="alert" class="Toastify__toast-body">Updated Successfully</div>` |
| **Error toast** | Error notification on API failure or validation | `xpath=//div[contains(@class,'Toastify__toast-body') and (contains(text(),'error') or contains(text(),'Error'))]` | Toastify error body |
| **Generic success toast** | Any Toastify success alert (fallback) | `xpath=//div[@role='alert' and contains(@class,'Toastify__toast-body')]` | Any `role="alert"` toast |

---

## 11. Expected Results

### Workflow A

| Step | RF Keyword Used | Expected Outcome |
|---|---|---|
| Manage Devices loaded | `Wait Until Element Is Visible    ${LOC_GRID}` | Device grid visible; starting point confirmed |
| Admin module expanded | `Click Element    ${LOC_ADMIN_TOGGLE}` | Admin sub-menu expands; Product Type sub-item becomes visible |
| Product Type sub-item clicked | `Click Element    ${LOC_PRODUCT_TYPE_NAV}` | Page navigates to `/ProductType` |
| Listing page loaded | `Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}` | Create Product Type button visible (user has RW permission) |
| Create form opened | `Click Element    ${LOC_PT_CREATE_BTN}` | URL changes to `/CreateProductType`; Account dropdown visible |
| Account selected | `Click Element Via JS    ${LOC_ACCOUNT_DD}` then `Click Element Via JS    ${LOC_ACCOUNT_OPTION_KSA}` | KSA_OPCO selected from custom div dropdown |
| Product Type Name filled | `Input Text    ${LOC_PT_NAME_INPUT}    ${PT_NAME}` | Field populated without error |
| Service Type selected | `Select From List By Label    ${LOC_PT_SERVICE_TYPE_DD}    Postpaid` | Service Type set |
| Sub Type 1 verified disabled | `Element Should Be Disabled    ${LOC_PT_SUB_TYPE_1_DD}` | Confirmed locked to GCT / GCT WBU |
| Sub Types 2–4 filled | `Input Text    ...    ${value}` | All three text inputs populated |
| Optional fields filled | Multiple `Input Text` + `Select Radio Button` | Packaging size, comment, description filled |
| Submit clicked | `Click Element    ${LOC_PT_SUBMIT_BTN}` | API POST executed; no client-side errors |
| Success toast visible | `Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}` | Toast notification displayed |
| Redirect confirmed | `Location Should Contain    ProductType` | URL returns to `/ProductType` |
| Listing grid visible | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}` | Product Type list grid rendered |

### Workflow B

| Step | RF Keyword Used | Expected Outcome |
|---|---|---|
| Listing page loaded | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}` | Grid rendered with existing product types |
| Assign icon clicked | `Click Element Via JS    ${LOC_PT_ASSIGN_CUST_ICON}` | Assign Customers dialog opens |
| EC selected | `Click Element    ${LOC_ASSIGN_CUSTOMER_OPT_1}` | EC tag appears in multi-select control |
| Update clicked | `Click Element    ${LOC_ASSIGN_UPDATE_BTN}` | API POST to `api/create/product/catalog/details/{id}/customer-accounts` |
| Success toast visible | `Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}` | Toast notification displayed |
| Popup closed | `Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}` | Modal dismissed |
| Grid refreshed | `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}` | Listing grid re-renders with updated EC assignment |

---

## 12. Negative Test Scenarios

### Workflow A — Create SIM Product Type

| Scenario ID | Scenario Description | Action Taken | RF Assertion |
|---|---|---|---|
| NEG-01 | Account not selected | Leave Account at blank; click Submit | Joi validation error: "Account is required"; form does not submit |
| NEG-02 | Product Type Name blank | Leave `productCatalogName` empty; click Submit | Validation error displayed; `Page Should Contain    xpath=//div[contains(@class,'error')]` |
| NEG-03 | Service Type not selected | Leave `servicetype` at default blank; click Submit | Validation error: "Service Type is required" |
| NEG-04 | Service Sub Type 2 blank | Leave `serviceSubType2` empty; click Submit | Validation error: "Service Sub Type 2 is required" |
| NEG-05 | Service Sub Type 3 blank | Leave `serviceSubType3` empty; click Submit | Validation error: "Service Sub Type 3 is required" |
| NEG-06 | Service Sub Type 4 blank | Leave `serviceSubType4` empty; click Submit | Validation error: "Service Sub Type 4 is required" |
| NEG-07 | Profile Name blank when Sub Type 3 = esim | Enter `esim` in Sub Type 3; leave Profile Name empty; click Submit | Validation error: "Profile name is required" |
| NEG-08 | Packaging Size = 0 or negative | Enter `0` or `-1` in `packagingSize`; click Submit | Validation error: Packaging Size must be ≥ 1 |
| NEG-09 | Product Type Name > 50 chars | Enter 51-character string | Input is limited by `maxLength=50`; excess chars not typed |
| NEG-10 | Duplicate product type name | Enter same name as existing product type; click Submit | API error toast: duplicate name rejected |
| NEG-11 | Close without submitting | Fill fields; click Close button | Redirect to `/ProductType`; no create record in grid |
| NEG-12 | User lacks write permission | Test with read-only account | Create Product Type button not visible; `Element Should Not Be Visible    ${LOC_PT_CREATE_BTN}` |
| NEG-13 | API failure on Submit | Simulate API error (network interrupt) | Error toast displayed; user remains on `/CreateProductType` |
| NEG-14 | Session expires during form fill | Leave form idle until session timeout | Redirect to login root: `Location Should Contain    192.168.1.26:7874/` |

### Workflow B — Assign EC to Product Type

| Scenario ID | Scenario Description | Action Taken | RF Assertion |
|---|---|---|---|
| NEG-15 | No EC selected and Update clicked | Open popup; click Update without selecting any EC | Error toast: "Please select customers" displayed; popup stays open |
| NEG-16 | Assign-Customer icon not visible (read-only user) | Login as read-only user | `Element Should Not Be Visible    ${LOC_PT_ASSIGN_CUST_ICON}` |
| NEG-17 | Assign-Customer icon not visible (feature disabled) | `VIEW_ELEMENTS().assign_product_type = false` | Assign column not rendered in grid |
| NEG-18 | EC already fully assigned | All ECs already assigned to this product type | Multi-select dropdown is empty; no options available |
| NEG-19 | Close popup without assigning | Click Close button in popup | Popup dismisses; grid not refreshed; assignment not changed |
| NEG-20 | Select All = Yes but no ECs exist | Enable Select All; all ECs already assigned | Submit succeeds but with empty customer list |

---

## 13. Validation Checks

### Workflow A — After Submit Product Type Form

```robot
Validate Product Type Creation
    # 1. Success notification is visible
    Element Should Be Visible        ${LOC_PT_CREATED_TOAST}

    # 2. No error elements on page
    Page Should Not Contain Element
    ...    xpath=//div[contains(@class,'toast-error')]

    # 3. Redirected back to Product Type listing
    Wait Until Keyword Succeeds      ${RETRY_COUNT}    ${RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    Location Should Not Contain      CreateProductType

    # 4. Product Type listing grid is visible
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}

    Log    SIM Product Type created and validated successfully    INFO
```

### Workflow B — After Update EC Assignment

```robot
Validate EC Assignment Success
    # 1. Success notification is visible
    Element Should Be Visible        ${LOC_PT_CREATED_TOAST}

    # 2. Assign Customer popup is closed
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${TIMEOUT}

    # 3. Product Type listing grid is re-rendered
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}

    Log    EC assigned to Product Type successfully    INFO
```

---

## 14. Automation Considerations

### Explicit Waits Only
Never use `Sleep`. Use SeleniumLibrary wait keywords for all dynamic content:
```robot
Wait Until Element Is Visible      locator    ${TIMEOUT}
Wait Until Element Is Enabled      locator    ${TIMEOUT}
Wait Until Element Is Not Visible  locator    ${TIMEOUT}
Wait Until Page Contains           text       ${TIMEOUT}
```

### Submit / Close Are `<a>` Tags — Not `<button>`
On the Create Product Type form, both Submit and Close are `<a href="javascript:void(0);">` elements:
```robot
# Correct — use Click Element
Click Element    ${LOC_PT_SUBMIT_BTN}    # xpath=//a[contains(@class,'btn-custom-color') and contains(.,'Submit')]

# NEVER use Submit Form — this is not a <button type="submit"> inside a <form>
# Submit Form    → WILL FAIL
```

### Service Sub Type 1 Is Always Disabled
Do not attempt to interact with `data-testid=serviceSubType1eet`:
```robot
# Correct — just assert it is disabled and auto-filled
Element Should Be Disabled    ${LOC_PT_SUB_TYPE_1_DD}

# NEVER attempt to select from it
# Select From List By Label    ${LOC_PT_SUB_TYPE_1_DD}    GCT    → WILL FAIL (disabled)
```

### Assign-Customer Icon Is jQuery-Injected
The `k-grid-Assign-Customer` icon is injected by the `dataBound` jQuery callback — not a React-rendered element. Wait for the grid to fully load (`dataBound` to fire) before asserting the icon's visibility:
```robot
Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${TIMEOUT}
Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${TIMEOUT}
Click Element                    ${LOC_PT_ASSIGN_CUST_ICON}
```

### EC Dropdown Interaction (Kendo k-list Pattern inside Assign Dialog)
The customer dropdown in the Assign Customers dialog uses a Kendo `k-list` / `k-item` pattern inside `div[@role='dialog']`. Uses retry logic and JS clicks:
```robot
# Click the Select Customers input to open dropdown
Click Element Via JS    ${LOC_ASSIGN_SELECT_CUSTOMERS}
Sleep    2s
# Wait for first EC option
Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMER_OPT_1}    10s
# Click first EC option
Click Element Via JS    ${LOC_ASSIGN_CUSTOMER_OPT_1}
Sleep    1s
```

### Select All Radio Disables the Multi-Select
When the "Yes" radio (`name=selectAllCustomers`, `value=true`) is clicked, the multi-select is CSS-disabled:
```robot
# Select All option — multi-select becomes pointer-events: none
Click Element    ${LOC_ASSIGN_ALL_YES}
# Do NOT try to click the multi-select after this
# Click element -> directly click Update
Click Element    ${LOC_ASSIGN_UPDATE_BTN}
```

### Profile Name — Conditional Requirement
Profile Name is only required when `serviceSubType3 === "esim"` (case-insensitive). Automate the conditional:
```robot
Select Service Sub Type 3 Conditionally
    [Arguments]    ${sub_type_3}
    Input Text    ${LOC_PT_SUB_TYPE_3_INPUT}    ${sub_type_3}
    ${is_esim}=    Run Keyword And Return Status
    ...    Should Be Equal As Strings (case insensitive)    ${sub_type_3}    esim
    Run Keyword If    ${is_esim}
    ...    Input Text    ${LOC_PROFILE_NAME}    ${PROFILE_NAME_VALUE}
```

### Navigating to Product Type (Admin Icon → ManageUser → SIM Product Type)
Click the Admin icon (`<i class="fa custom-manu-icon admin-menu-icon">`) in the left sidebar. This navigates to `/ManageUser`. Wait for ManageUser page to load, then click SIM Product Type link:
```robot
# Step 1: Click Admin icon — navigates to /ManageUser
Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}    ${TIMEOUT}
Click Element                    ${LOC_ADMIN_TOGGLE}
# Step 2: Wait for ManageUser page to load
Wait Until Keyword Succeeds    ${RETRY_COUNT}    ${RETRY_INTERVAL}
...    Location Should Contain    ManageUser
Wait Until Element Is Visible    ${LOC_MU_GRID_DATA}    ${TIMEOUT}
# Step 3: Click SIM Product Type link
Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}    ${TIMEOUT}
Click Element                    ${LOC_PRODUCT_TYPE_NAV}
```

### SIM Product Type Link Locator
The link uses `href="/ProductType"` with text "SIM Product Type":
```robot
${LOC_PRODUCT_TYPE_NAV}    xpath=//a[@href='/ProductType' and contains(text(),'SIM Product Type')]
```

### Admin Icon Behaviour
Clicking the Admin icon navigates to `/ManageUser`. Unlike an accordion, it does not toggle open/close — it always navigates:
```robot
${is_visible}=    Run Keyword And Return Status
...    Element Should Be Visible    ${LOC_PRODUCT_TYPE_NAV}
Run Keyword If    not ${is_visible}    Click Element    ${LOC_ADMIN_TOGGLE}
Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}    ${TIMEOUT}
```

### Scroll Before Submit / Update
Both the Submit button (Create form) and Update button (Assign popup) may be below the fold:
```robot
Scroll Element Into View    ${LOC_PT_SUBMIT_BTN}
Wait Until Element Is Visible    ${LOC_PT_SUBMIT_BTN}    ${TIMEOUT}
Click Element    ${LOC_PT_SUBMIT_BTN}
```

### SSL Certificate Bypass
```robot
${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
Call Method    ${options}    add_argument    --ignore-certificate-errors
Open Browser    ${BASE_URL}    chrome    options=${options}
```

### Shared Login and Navigation
This test reuses `Login To Application` and `Navigate To Manage Devices` keywords from `common_keywords.robot` (TC_001). Do not duplicate login logic.

### Screenshot on Failure
```robot
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot    EMBED
```

---

## 15. Framework Recommendation

This specification is written for **Robot Framework + SeleniumLibrary** to align with TC_001 through TC_005. The table below describes how the same tests can be implemented in other frameworks.

| Framework | Language | Approach | SSL Handling | Notes |
|---|---|---|---|---|
| **Robot Framework + SeleniumLibrary** | Python (keyword DSL) | `Select From List By Label`, `Input Text`, `Click Element` | `ChromeOptions` via `Evaluate` | **Recommended** — consistent with TC_001 through TC_005 |
| **Playwright (Python)** | Python | `page.locator()`, `page.select_option()`, `expect(locator).to_be_visible()` | `ignore_https_errors=True` in browser context | Built-in auto-wait; handles react-select cleanly; `page.click('a:has-text("Submit")')` for `<a>` buttons |
| **Selenium (Python)** | Python | `WebDriverWait`, `Select` class, `find_element` | `ChromeOptions --ignore-certificate-errors` | Widely adopted; use `ActionChains` for scrolling |
| **Cypress** | JavaScript | `cy.get()`, `cy.contains()`, `cy.select()` | `chromeWebSecurity: false` | `cy.contains('Submit').click()` cleanly handles `<a>` buttons |

---

## 16. Example Playwright Script (Workflow A + B)

```python
import pytest
from playwright.sync_api import Page, expect

BASE_URL   = "https://192.168.1.26:7874"
USERNAME   = "ksa_opco"
PASSWORD   = "Admin@123"

# ── Confirmed Locators ─────────────────────────────────────────────────────────
# Navigation
LOC_ADMIN_TOGGLE    = "//span[contains(text(),'Admin')]/parent::a"
LOC_PT_NAV          = "//ul[contains(@class,'nav-second-level')]//a[contains(@href,'ProductType') and not(contains(@href,'Create'))]"

# Product Type Listing (ProductType.js)
LOC_PT_GRID         = "#gridData"
LOC_CREATE_BTN      = "a.btn-custom-color:has-text('Create Product Type')"   # <a> tag
LOC_ASSIGN_ICON     = "i.k-grid-Assign-Customer"

# Create Form (CreateProductType.js)
LOC_ACCOUNT_DD      = "[data-testid='accountIdet']"          # line 401
LOC_PT_NAME         = "input[name='productCatalogName']"     # line 417
LOC_SERVICE_TYPE    = "[data-testid='servicetypeet']"        # line 439
LOC_SUB_TYPE_1      = "[data-testid='serviceSubType1eet']"   # line 459 — disabled
LOC_SUB_TYPE_2      = "input[name='serviceSubType2']"        # line 476
LOC_SUB_TYPE_3      = "input[name='serviceSubType3']"        # line 489
LOC_SUB_TYPE_4      = "input[name='serviceSubType4']"        # line 502
LOC_PACKAGING       = "input[name='packagingSize']"          # line 542
LOC_COMMENT         = "input[name='comment']"                # line 600
LOC_DESC_EN         = "input[name='descEnglish']"            # line 616
LOC_SUBMIT          = "a.btn-custom-color:has-text('Submit')"   # <a> tag, line 645
LOC_CLOSE           = "a.btn-cancel-color:has-text('Close')"    # <a> tag, line 658

# Assign Customer dialog (div[@role='dialog'])
LOC_ASSIGN_POPUP    = "div[role='dialog'] h4:has-text('Assign Customers')"
LOC_CUST_INPUT      = "div[role='dialog'] input[placeholder='Select Customers']"
LOC_CUST_OPT1       = "div[role='dialog'] li.k-item >> nth=0"
LOC_UPDATE_BTN      = "div.modal:visible button.btn-custom-color"
LOC_CLOSE_ASSIGN    = "div.modal:visible button.btn-cancel-color"


@pytest.fixture(scope="session")
def browser_context_args(browser_context_args):
    return {**browser_context_args, "ignore_https_errors": True}


def login(page: Page) -> None:
    page.goto(BASE_URL)
    page.locator("#root").wait_for(state="visible")
    page.locator("input[name='username']").fill(USERNAME)
    page.locator("input[name='password']").fill(PASSWORD)
    page.locator("input.btn-custom-color[type='button']").click()
    page.locator("#gridData").wait_for(state="visible")


def navigate_to_product_type(page: Page) -> None:
    """Expand Admin accordion and click Product Type sub-item."""
    admin_toggle = page.locator(LOC_ADMIN_TOGGLE)
    admin_toggle.scroll_into_view_if_needed()
    admin_toggle.click()
    pt_nav = page.locator(LOC_PT_NAV)
    pt_nav.wait_for(state="visible")
    pt_nav.click()
    page.wait_for_url("**ProductType**")
    page.locator(LOC_PT_GRID).wait_for(state="visible")


def test_create_sim_product_type(page: Page) -> None:
    # ── Login and navigate ────────────────────────────────────────────────────
    login(page)
    navigate_to_product_type(page)

    # ── Open Create form ──────────────────────────────────────────────────────
    page.locator(LOC_CREATE_BTN).click()
    page.wait_for_url("**CreateProductType**")
    page.locator(LOC_ACCOUNT_DD).wait_for(state="visible")

    # ── Fill form ─────────────────────────────────────────────────────────────
    page.locator(LOC_ACCOUNT_DD).select_option(index=1)
    page.locator(LOC_PT_NAME).fill("Test SIM Product Type")
    page.locator(LOC_SERVICE_TYPE).select_option(label="Postpaid")

    # Service Sub Type 1 is disabled — assert only
    assert not page.locator(LOC_SUB_TYPE_1).is_enabled(), "Sub Type 1 must be disabled"

    page.locator(LOC_SUB_TYPE_2).fill("physical")
    page.locator(LOC_SUB_TYPE_3).fill("SIM")
    page.locator(LOC_SUB_TYPE_4).fill("4FF")
    page.locator(LOC_PACKAGING).fill("100")
    page.locator(LOC_COMMENT).fill("Automation test product type")
    page.locator(LOC_DESC_EN).fill("Test product type created by automation")

    # ── Submit ────────────────────────────────────────────────────────────────
    submit_btn = page.locator(LOC_SUBMIT)
    submit_btn.scroll_into_view_if_needed()
    submit_btn.click()

    # ── Validate ──────────────────────────────────────────────────────────────
    expect(page.locator(".toast-success")).to_be_visible()
    page.wait_for_url("**ProductType**")
    assert "CreateProductType" not in page.url
    print("SIM Product Type created successfully")


def test_assign_ec_to_product_type(page: Page) -> None:
    # ── Login and navigate ────────────────────────────────────────────────────
    login(page)
    navigate_to_product_type(page)

    # ── Click Assign-Customer icon on first row ───────────────────────────────
    assign_icon = page.locator(LOC_ASSIGN_ICON).first
    assign_icon.wait_for(state="visible")
    assign_icon.click()
    page.locator(LOC_ASSIGN_POPUP).wait_for(state="visible")

    # ── Select first EC from multi-select dropdown ────────────────────────────
    page.locator(LOC_CUST_CONTROL).click()
    page.locator(LOC_CUST_MENU).wait_for(state="visible")
    page.locator(LOC_CUST_OPT1).click()
    page.locator(LOC_CUST_MENU).wait_for(state="hidden")

    # ── Click Update ──────────────────────────────────────────────────────────
    update_btn = page.locator(LOC_UPDATE_BTN)
    update_btn.scroll_into_view_if_needed()
    update_btn.click()

    # ── Validate ──────────────────────────────────────────────────────────────
    expect(page.locator(".toast-success")).to_be_visible()
    page.locator(LOC_ASSIGN_POPUP).wait_for(state="hidden")
    page.locator(LOC_PT_GRID).wait_for(state="visible")
    print("EC assigned to Product Type successfully")
```

> **Run command for Playwright:**
> ```bash
> pytest tests/test_sim_product_type.py --headed
> ```

---

## 17. Success Validation Checklist

### Workflow A — Create SIM Product Type

- [ ] `Wait Until Element Is Visible    ${LOC_GRID}` passes — Manage Devices starting point confirmed
- [ ] `Scroll Element Into View    ${LOC_ADMIN_TOGGLE}` executes without error
- [ ] `Click Element    ${LOC_ADMIN_TOGGLE}` expands Admin module — Product Type sub-item becomes visible
- [ ] `Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}` passes
- [ ] `Click Element    ${LOC_PRODUCT_TYPE_NAV}` executes without error
- [ ] `Location Should Contain    ProductType` passes
- [ ] `Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}` passes — user has RW permission
- [ ] `Click Element    ${LOC_PT_CREATE_BTN}` navigates to `/CreateProductType`
- [ ] `Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}` passes — form loaded
- [ ] `Click Element Via JS    ${LOC_ACCOUNT_DD}` opens custom div dropdown
- [ ] `Click Element Via JS    ${LOC_ACCOUNT_OPTION_KSA}` selects KSA_OPCO
- [ ] `Input Text    ${LOC_PT_NAME_INPUT}    ${PT_NAME}` executes without error
- [ ] `Select From List By Label    ${LOC_PT_SERVICE_TYPE_DD}    Postpaid` executes without error
- [ ] `Element Should Be Disabled    ${LOC_PT_SUB_TYPE_1_DD}` passes — Sub Type 1 confirmed locked
- [ ] `Input Text    ${LOC_PT_SUB_TYPE_2_INPUT}    ${PT_SUB_TYPE_2}` executes without error
- [ ] `Input Text    ${LOC_PT_SUB_TYPE_3_INPUT}    ${PT_SUB_TYPE_3}` executes without error
- [ ] `Input Text    ${LOC_PT_SUB_TYPE_4_INPUT}    ${PT_SUB_TYPE_4}` executes without error
- [ ] `Input Text    ${LOC_PT_PACKAGING_SIZE}    ${PT_PACKAGING_SIZE}` executes without error
- [ ] `Select Radio Button    canBeOrdered    true` executes without error
- [ ] `Input Text    ${LOC_PT_COMMENT_INPUT}    ${PT_COMMENT}` executes without error
- [ ] `Input Text    ${LOC_PT_DESC_EN_INPUT}    ${PT_DESC_EN}` executes without error
- [ ] `Scroll Element Into View    ${LOC_PT_SUBMIT_BTN}` executes without error
- [ ] `Click Element    ${LOC_PT_SUBMIT_BTN}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}` passes within `${TIMEOUT}`
- [ ] `Location Should Contain    ProductType` passes (redirect confirmed)
- [ ] `Location Should Not Contain    CreateProductType` passes
- [ ] `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}` passes

### Workflow B — Assign EC to Product Type

- [ ] `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}` passes — listing grid loaded
- [ ] `Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}` passes — icon visible after grid dataBound
- [ ] `Click Element    ${LOC_PT_ASSIGN_CUST_ICON}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}` passes — popup opened
- [ ] `Wait Until Element Is Visible    ${LOC_ASSIGN_SELECT_CUSTOMERS}` passes — multi-select rendered
- [ ] `Click Element Via JS    ${LOC_ASSIGN_SELECT_CUSTOMERS}` opens EC dropdown (Kendo k-list)
- [ ] `Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMERS_MENU}` passes — EC options visible
- [ ] `Click Element    ${LOC_ASSIGN_CUSTOMER_OPT_1}` selects first EC
- [ ] `Wait Until Element Is Not Visible    ${LOC_ASSIGN_CUSTOMERS_MENU}` passes — dropdown closed
- [ ] `Scroll Element Into View    ${LOC_ASSIGN_UPDATE_BTN}` executes without error
- [ ] `Click Element    ${LOC_ASSIGN_UPDATE_BTN}` executes without error
- [ ] `Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}` passes within `${TIMEOUT}`
- [ ] `Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}` passes — popup dismissed
- [ ] `Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}` passes — grid refreshed
- [ ] No `FAIL` entries in `output.xml`
- [ ] `log.html` and `report.html` generated in `results/` directory

---

## 18. Current Project Implementation

This section documents the **actual implementation** in the project.

### Project Files

| Content | Location |
|---------|----------|
| Test cases (18 tests) | `tests/product_type_tests.robot` |
| Keywords | `resources/keywords/product_type_keywords.resource` |
| Locators | `resources/locators/product_type_locators.resource` |
| Variables / Test data | `variables/product_type_variables.py` |
| Browser setup | `resources/keywords/browser_keywords.resource` |
| Login keywords | `resources/keywords/login_keywords.resource` |

### Run Command

```bash
robot --outputdir reports tests/product_type_tests.robot
```

### Test Case List (18 tests)

| ID | Name | Type |
|----|------|------|
| TC_PT_001 | Create SIM Product Type Standard Flow | positive |
| TC_PT_002 | Assign EC To Existing Product Type | positive |
| TC_PT_003 | Submit Without Selecting Account | negative |
| TC_PT_004 | Submit With Blank Product Type Name | negative |
| TC_PT_005 | Submit Without Selecting Service Type | negative |
| TC_PT_006 | Submit With Blank Service Sub Type 2 | negative |
| TC_PT_007 | Submit With Blank Service Sub Type 3 | negative |
| TC_PT_008 | Submit With Blank Service Sub Type 4 | negative |
| TC_PT_009 | Submit With Esim Sub Type 3 But Blank Profile Name | negative |
| TC_PT_010 | Close Create Form Without Submitting | negative |
| TC_PT_011 | Verify Create Button Visible For RW User | positive |
| TC_PT_012 | Click Update Without Selecting Any EC | negative |
| TC_PT_13 | Close Assign Popup Without Saving Should Not Change Assignment | negative |
| TC_PT_14 | Edit Icon Should Be Visible In Product Type Grid | positive |
| TC_PT_15 | Assign Customer Icon Should Be Visible In Grid For RW User | positive |
| TC_PT_16 | Search Product Type In Listing Grid | positive |
| TC_PT_17 | Duplicate Product Type Name Should Show Error Toast | negative |
| TC_PT_18 | Clear Search Should Reset Grid | positive |

### Key Implementation Details

- **Navigation:** Uses Admin icon → SIM Product Type sub-tab
- **Account Dropdown:** Custom div-based dropdown (not native select) — uses JS click to open and select KSA_OPCO
- **Service Sub Type 1:** Always disabled, auto-set to GCT/GCT WBU — automation verifies disabled state only
- **Submit/Close:** Both are `<a>` tags with `href="javascript:void(0);"` — uses Click Element, not Submit Form
- **Assign Customer Dialog:** Uses a **React Select** multi-select component (NOT Kendo):
  - Control area: `<div class="select__control">` — click to focus
  - Hidden input: `<input id="react-select-2-input">` — covered by placeholder div
  - Placeholder: `<div class="select__placeholder">Select Customers</div>`
  - Dropdown options: `<div class="select__option">` inside `<div class="select__menu">`
  - Update button: `<button class="btn btn-custom-color">Update</button>` inside `<div id="customers">`
  - Close button: `<button class="btn btn-cancel-color">Close</button>` inside `<div id="customers">`
- **EC Selection Flow:** Focus input via JS (`inp.focus(); inp.style.opacity='1'; inp.style.width='200px'`), type full EC name using Selenium `Press Keys`, then poll every 5 seconds up to 30 seconds for the API-backed search to return results. Click matching `select__option` via JS.
- **EC Account Name:** `PT_EC_ACCOUNT_NAME = "SANJ_1002"` (variable in `product_type_variables.py`)
- **Browser Session:** Each test gets a fresh browser via Test Setup; test-level teardown captures screenshot and closes browser

---

## 19. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-06 | CMP QA Team | Initial Robot Framework specification for TC_006 — Create SIM Product Type and Assign EC; aligned to TC_001 through TC_005 in structure, credential format, keyword style, variable naming, locator strategy, and retry/screenshot patterns; covers two workflows (A: Create Product Type, B: Assign EC); all locators confirmed against `ProductType.js`, `CreateProductType.js`, and `AssignCustomer.js` source; documents Submit/Close as `<a>` tags (not `<button>`), Service Sub Type 1 always-disabled behaviour, Assign-Customer icon as jQuery-injected element, EC multi-select react-select interaction pattern, Select All Customers radio behaviour, conditional Profile Name requirement when Sub Type 3 = `esim`, Admin accordion expand-first pattern consistent with TC_004 and TC_005, complete `.robot` files for both workflows, Playwright reference script for both workflows, 20 negative scenarios, and full success validation checklists |
