# Automation Test Specification – Create APN

**Document Version:** 1.0
**Status:** Ready for Automation
**Framework:** Robot Framework + SeleniumLibrary *(Playwright / Selenium / Cypress also supported — see Section 14)*
**Date:** 2026-03-06
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application
**Aligned To:** TC_001_Login_Navigate_RF.md · TC_002_Device_State_Change_RF.md · TC_003_Create_SIM_Order_RF.md · TC_004_Create_SIM_Range_RF.md · TC_005_Create_CSR_Journey_RF.md · TC_006_Create_SIM_Product_Type_RF.md

---

## 1. Objective

This test validates the end-to-end **Create APN** workflow on the CMP web application. The Create APN page is accessed via the **Service** icon (sidebar) and **APN** tab (top navigation). The automation begins from the **Manage Devices** page (post-login) and covers:

1. Navigating to the **APN** module via the **Service** icon (sidebar) and **APN** tab (top navigation)
2. Clicking the **Create APN** button on the `/ManageAPN` listing page to navigate to `/CreateAPN`
3. Filling all **mandatory fields** in the **Primary Details** accordion section:
   - APN Type (Public / Private)
   - Account (via TreeView dropdown or Dropdown depending on client config)
   - APN ID
   - APN Name
   - Description
   - IP Address Type
   - IP Allocation Type (static / dynamic) — shown when IP Address Type is selected
4. Optionally expanding and filling **Radius Configuration**, **Subnet Mask**, **Secondary Details**, and **QoS** accordion sections
5. Clicking the **Submit** button (rendered as an `<a>` tag — not a `<button>`) and verifying the **success toast notification**
6. Verifying the automatic redirect back to `/ManageAPN` and confirming the new APN record appears in the listing grid

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **Manage APN (Listing) URL** | `https://192.168.1.26:7874/ManageAPN` |
| **Create APN URL** | `https://192.168.1.26:7874/CreateAPN` |
| **Root Container XPath** | `xpath=//div[@id='root']` |
| **Application Type** | React SPA (Single Page Application) |
| **APN Location in UI** | **Service icon** (sidebar) → **APN tab** (top navigation under pageHeading) |

---

## 3. Preconditions

- The application server is reachable at `https://192.168.1.26:7874`
- SSL/TLS certificate warnings are handled — self-signed certificate accepted via `ChromeOptions` at browser launch
- The user is **already authenticated** as `ksa_opco` and has landed on the **Manage Devices** page
  - *(Use `Login With Credentials` and `Verify Login Success` from `login_keywords.resource`; or `Login And Navigate To Create APN` from `apn_keywords.resource` for full flow)*
- The `ksa_opco` user has **RW (Read-Write)** permission to access the **APN** module
- The **Service** icon (sidebar) and **APN** tab (top navigation) are visible after login
- At least one valid **Account** exists in the system to assign to the new APN
- **CAPTCHA** value is available in the database (login uses `Fetch Captcha Value` from `login_keywords.resource`; DB config in `env_config.py`)
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
# Run full APN suite (uses run_tests.py — reads tasks.csv for ordering)
python run_tests.py tests/apn_tests.robot

# Run by module name
python run_tests.py --suite APN

# Run a single test case
python run_tests.py tests/apn_tests.robot --test "TC_APN_001*"

# Run by tag
python run_tests.py --include apn
python run_tests.py --include smoke

# Environment and browser overrides
python run_tests.py tests/apn_tests.robot --env staging --browser firefox
```

Reports are saved to `reports/<timestamp>/` with merged output.

### 4.3 Project Structure

```
d:\stc-automation\
├── config\
│   └── env_config.py              # BASE_URL, BROWSER, VALID_USERNAME, VALID_PASSWORD, etc.
├── variables\
│   ├── apn_variables.py           # APN test data (APN_TYPE_PRIVATE, VALID_APN_ID, etc.)
│   └── login_variables.py         # Login test data
├── resources\
│   ├── locators\
│   │   ├── apn_locators.resource  # APN page locators (LOC_APN_TYPE, LOC_SUBMIT_BTN, etc.)
│   │   └── login_locators.resource
│   └── keywords\
│       ├── apn_keywords.resource  # APN workflow keywords
│       ├── browser_keywords.resource
│       └── login_keywords.resource
├── tests\
│   └── apn_tests.robot            # APN test cases (TC_APN_001–TC_APN_022)
├── run_tests.py                   # Central test runner (use this, not robot directly)
├── tasks.csv                      # Suite ordering and test metadata
└── reports\<timestamp>\           # output.xml, log.html, report.html
```

### 4.4 Test Case List (from tests/apn_tests.robot)

| ID | Test Case Name | Tags |
|----|----------------|------|
| TC_APN_001 | Create Private APN With Static IPV4 Successfully | smoke, regression, positive, apn |
| TC_APN_002 | Create Public APN With Dynamic IPV4 Successfully | regression, positive, apn |
| TC_APN_003 | Create Private APN With IPV6 Successfully | regression, positive, apn |
| TC_APN_004 | Create APN With IPV4 And IPV6 Dual Stack Successfully | regression, positive, apn |
| TC_APN_005 | Create APN With Secondary Details | regression, positive, apn |
| TC_APN_006 | Create APN With QoS Details | regression, positive, apn, qos |
| TC_APN_007 | Verify Create APN Page Elements Are Visible | smoke, regression, positive, apn |
| TC_APN_008 | Verify IP Allocation Type Appears After IP Address Type Selection | regression, positive, apn |
| TC_APN_009 | Verify Cancel Button Redirects To Manage APN | regression, positive, apn, navigation |
| TC_APN_010 | Submit With No Fields Filled Should Show Error | regression, negative, apn |
| TC_APN_011 | Missing APN Name Should Show Error | regression, negative, apn |
| TC_APN_012 | Missing APN ID Should Show Error | regression, negative, apn |
| TC_APN_013 | Missing APN Type Should Show Error | regression, negative, apn |
| TC_APN_014 | Missing IP Address Type Should Show Error | regression, negative, apn |
| TC_APN_015 | Missing IP Allocation Type Should Show Error | regression, negative, apn |
| TC_APN_016 | APN ID Exceeding 19 Digits Should Show Error | regression, negative, apn, boundary |
| TC_APN_017 | Duplicate APN Name Should Show Error | regression, negative, apn |
| TC_APN_018 | SQL Injection In APN Name Should Be Rejected | regression, negative, security, apn |
| TC_APN_019 | Special Characters In APN Name Should Be Rejected | regression, negative, security, apn |
| TC_APN_020 | HLR APN ID Exceeding 19 Digits Should Show Error | regression, negative, apn, boundary |
| TC_APN_021 | Direct Access To Create APN Without Login Should Redirect | regression, negative, security, apn, navigation |
| TC_APN_022 | Direct Access To Manage APN Without Login Should Redirect | regression, negative, security, apn, navigation |

---

## 5. Test Data

| Field | Sample Value | Notes |
|---|---|---|
| **Username** | `ksa_opco` | Shared across all TCs |
| **Password** | `Admin@123` | Shared across all TCs |
| **APN Type** | `Private` | Select option value `1`; use `Public` (value `2`) for public APN test |
| **Account** | *(select from dropdown)* | First available account in the dropdown |
| **BU** | *(select from react-select)* | Required only for Private APNs when not Private-Shared; react-select component |
| **APN ID** | `1001` | Numeric; max 19 digits; must be unique |
| **APN Name** | `test-apn-automation` | Text; max 50 characters; must be unique |
| **Description** | `APN created via automation` | Text; max 500 characters |
| **EQOS ID** | `100` | Numeric; max 19 digits; conditionally required per client config |
| **HSS Context ID** | `200` | Numeric; conditionally required per client config |
| **IP Address Type** | `IPV4` | Select option value `1`; triggers IP Allocation Type dropdown |
| **IP Allocation Type** | `static` | Select option `static` or `dynamic` |
| **Radius Configuration** | `Authentication` | Optionally expand Radius Configuration accordion |
| **Radius Auth Type** | `None` | Select option `None` or `PAP/CHAP` |
| **Expected Success Toast** | `APN Created Successfully` | Varies per translation config |
| **Post-submit redirect** | `/ManageAPN` | SPA navigation, no full page reload |

---

## 6. RF Settings and Variables

### 6.1 Settings (from tests/apn_tests.robot)

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/apn_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/apn_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/apn_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser
```

### 6.2 Variables (from config/env_config.py and variables/apn_variables.py)

| Variable | Source | Example Value |
|----------|--------|---------------|
| `${BASE_URL}` | env_config.py | `https://192.168.1.26:7874/` |
| `${BROWSER}` | env_config.py | `chrome` |
| `${VALID_USERNAME}` | env_config.py | `ksa_opco` |
| `${VALID_PASSWORD}` | env_config.py | `Admin@123` |
| `${APN_TYPE_PRIVATE}` | apn_variables.py | `1` |
| `${APN_TYPE_PUBLIC}` | apn_variables.py | `2` |
| `${VALID_APN_ID}` | apn_variables.py | `10{timestamp}` (dynamic) |
| `${VALID_APN_NAME}` | apn_variables.py | `auto-apn-{random}` |
| `${VALID_DESCRIPTION}` | apn_variables.py | `APN created via automation` |
| `${VALID_IP_ADDR_TYPE_IPV4}` | apn_variables.py | `1` |
| `${VALID_IP_ADDR_TYPE_IPV6}` | apn_variables.py | `0` |
| `${VALID_IP_ADDR_TYPE_BOTH}` | apn_variables.py | `2` |
| `${VALID_IP_ALLOC_STATIC}` | apn_variables.py | `static` |
| `${VALID_IP_ALLOC_DYNAMIC}` | apn_variables.py | `dynamic` |
| `${CREATE_APN_URL}` | apn_variables.py | `https://192.168.1.26:7874/CreateAPN` |
| `${MANAGE_APN_URL}` | apn_variables.py | `https://192.168.1.26:7874/ManageAPN` |
| `${MANAGE_APN_PATH}` | apn_variables.py | `/ManageAPN` |
| `${CREATE_APN_PATH}` | apn_variables.py | `/CreateAPN` |
| `${APN_ID_EXCEEDS_MAX}` | apn_variables.py | `12345678901234567890` |
| `${HLR_APN_ID_EXCEEDS_MAX}` | apn_variables.py | `12345678901234567890` |
| `${SQL_INJECTION_APN_NAME}` | apn_variables.py | `' OR '1'='1' --` |
| `${SPECIAL_CHARS_APN_NAME}` | apn_variables.py | `!@#$%^&*()_+{}|:<>?` |
| `${DUPLICATE_APN_NAME}` | apn_variables.py | `test-apn-automation` |

### 6.3 Locators (from resources/locators/apn_locators.resource)

| Locator Variable | XPath / Selector |
|------------------|-----------------|
| `${LOC_MENU_SERVICE}` | `xpath=//*[@id="service-menu-icon"]` |
| `${LOC_TAB_APN}` | `xpath=//*[@id="pageHeading"]/li[3]/a[1]` |
| `${LOC_CREATE_APN_BTN}` | `xpath=//a[contains(@href,'/CreateAPN')]` |
| `${LOC_MANAGE_APN_GRID}` | `xpath=//div[contains(@class,'k-grid')]` |
| `${LOC_APN_TYPE}` | `xpath=//select[@name="apnCategory"]` |
| `${LOC_ACCOUNT_DROPDOWN}` | `xpath=//div[contains(@class,'selectBtn') and contains(@class,'form-control')]` |
| `${LOC_ACCOUNT_SEARCH_INPUT}` | `xpath=//div[@id='primarydetails']//input[@placeholder='Search']` |
| `${LOC_BU_DROPDOWN}` | `xpath=//div[contains(@class,'basic-multi-select')]//div[contains(@class,'select__control')]` |
| `${LOC_APN_ID}` | `xpath=//input[@name="apnIDID"]` |
| `${LOC_APN_NAME}` | `xpath=//input[@name="roleName"]` |
| `${LOC_DESCRIPTION}` | `xpath=//input[@name="roleDescription"]` |
| `${LOC_IP_ADDRESS_TYPE}` | `xpath=//*[@id="ipAddressType"]` |
| `${LOC_IP_ALLOC_TYPE}` | `xpath=//select[@name="modificationType"]` |
| `${LOC_SUBMIT_BTN}` | `xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit']` |
| `${LOC_CLOSE_BTN}` | `xpath=//a[contains(@class,'btn-cancel-color') and normalize-space()='Close']` |
| `${LOC_TOAST_SUCCESS}` | `xpath=//div[contains(@class,'Toastify__toast--success')]` |
| `${LOC_TOAST_ERROR}` | `xpath=//div[contains(@class,'Toastify__toast--error')]` |
| `${LOC_ALERT_DANGER}` | `xpath=//div[contains(@class,'alert-danger')]` |

### 6.4 Keywords (from resources/keywords/apn_keywords.resource)

| Keyword | Description |
|---------|-------------|
| `Login And Navigate To Create APN` | Full login, verify Manage Devices, navigate Service > APN, click Create APN |
| `Navigate To Manage APN Via Service Tab` | Click Service icon in sidebar, then APN tab in top navigation |
| `Click Create APN Button` | Click "Create APN" on Manage APN listing page |
| `Select APN Type` | Select APN Type (1=Private, 2=Public) |
| `Select Account` | Select account from custom dropdown |
| `Enter APN ID` | Clear and enter APN ID |
| `Enter APN Name` | Clear and enter APN Name |
| `Enter Description` | Clear and enter Description |
| `Select IP Address Type` | Select IP Address Type (1=IPV4, 0=IPV6, 2=IPV4&IPV6) |
| `Select IP Allocation Type` | Select IP Allocation Type (static/dynamic) |
| `Fill Primary Details` | Fill all mandatory Primary Details fields |
| `Add And Fill Subnet Mask Entry` | Expand Subnet mask, add entry, fill IP and CIDR |
| `Fill Secondary Details` | Expand Secondary Details, fill HLR APN ID, MCC, MNC, Profile ID |
| `Fill QoS Details` | Expand QoS accordion, fill 2G/3G and LTE bandwidth fields |
| `Submit Create APN Form` | Click Submit button (via JS) |
| `Click Cancel Button` | Click Close/Cancel to return to Manage APN |
| `Verify APN Created Successfully` | Verify success toast, redirect to /ManageAPN, grid visible |
| `Verify Primary Details Fields Visible` | Assert all mandatory Primary Details fields present |
| `Verify IP Alloc Type Appears After IP Selection` | IP Allocation Type appears only after IP Address Type selected |
| `Verify Cancel Redirects To Manage APN` | Cancel navigates back to /ManageAPN |
| `Verify Validation Error Or Still On Page` | After invalid submit: validation error or toast, still on Create APN |
| `Verify Negative Submission Outcome` | Robust check for error toast, alert-danger, or validation text |

---

## 7. Automation Flow

### 7.1 Step-by-Step Flow

| # | Phase | Step | RF Keyword | Locator / Detail |
|---|---|---|---|---|
| 1 | **Setup** | Open browser and navigate | `Open Browser And Navigate` | `${BASE_URL}` `${BROWSER}` (Test Setup) |
| 2 | **Login** | Login and navigate to Create APN | `Login And Navigate To Create APN` | Uses `Login With Credentials`, `Verify Login Success`, `Navigate To Manage APN Via Service Tab`, `Click Create APN Button` |
| 3 | **Form Fill** | Fill Primary Details | `Fill Primary Details` | `${APN_TYPE_PRIVATE}`, `${VALID_APN_ID}`, `${VALID_APN_NAME}`, `${VALID_DESCRIPTION}`, `${VALID_IP_ADDR_TYPE_IPV4}`, `${VALID_IP_ALLOC_STATIC}` |
| 4 | **Form Fill** | Add Subnet Mask (for Static IPV4) | `Add And Fill Subnet Mask Entry` | Optional; required for static IP allocation |
| 5 | **Submit** | Click Submit | `Submit Create APN Form` | `${LOC_SUBMIT_BTN}` — rendered as `<a>` tag |
| 6 | **Validate** | Verify success | `Verify APN Created Successfully` | `${LOC_TOAST_SUCCESS}`, `${MANAGE_APN_PATH}`, `${LOC_MANAGE_APN_GRID}` |
| 7 | **Teardown** | Capture screenshot and close | `Capture Screenshot And Close Browser` | Test Teardown |

### 7.2 Flow Diagram

```
Open Browser And Navigate (Test Setup)
        │
        ▼
  Login With Credentials ──► Verify Login Success
        │
        ▼
  Manage Devices Page
        │
        ▼
  Navigate To Manage APN Via Service Tab
  (Service icon → APN tab → /ManageAPN)
        │
        ▼
  Click Create APN Button ──► /CreateAPN
        │
        ▼
  ┌─────────────────────────────────────────────┐
  │         Primary Details (auto-open)          │
  │   APN Type  ──select Private (value=1)       │
  │   Account   ──select from dropdown           │
  │   APN ID    ──numeric input                  │
  │   APN Name  ──text input                     │
  │   Description──text input                    │
  │   IP Address Type ──select IPV4 (value=1)    │
  │   IP Allocation Type ──select static         │
  └─────────────────────────────────────────────┘
        │
        ▼
  Click Submit (<a> tag, not <button>)
        │
        ▼
  Success Toast ──► Auto-redirect ──► /ManageAPN
        │
        ▼
  Verify new APN record in grid ✓
```

---

## 8. Complete Robot Framework Test File (tests/apn_tests.robot)

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/apn_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/apn_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/apn_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser


*** Test Cases ***
TC_APN_001 Create Private APN With Static IPV4 Successfully
    [Documentation]    Navigate Service > APN, create a Private APN with Static IPV4.
    ...                Verify: success toast, redirect to /ManageAPN, grid visible.
    [Tags]    smoke    regression    positive    apn
    Login And Navigate To Create APN
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${VALID_APN_ID}    ${VALID_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_007 Verify Create APN Page Elements Are Visible
    [Documentation]    Navigate to Create APN page and verify all Primary Details fields are present.
    [Tags]    smoke    regression    positive    apn
    Login And Navigate To Create APN
    Verify Primary Details Fields Visible

TC_APN_010 Submit With No Fields Filled Should Show Error
    [Documentation]    Click Submit without filling any field.
    ...                Verify: validation error displayed, still on Create APN page.
    [Tags]    regression    negative    apn
    Login And Navigate To Create APN
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_021 Direct Access To Create APN Without Login Should Redirect
    [Documentation]    Navigate directly to /CreateAPN without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    apn    navigation
    Go To    ${CREATE_APN_URL}
    Wait For Page Load
    Verify Redirected To Login Page
```

*Keywords are defined in `resources/keywords/apn_keywords.resource`, `browser_keywords.resource`, and `login_keywords.resource`. Locators are in `resources/locators/apn_locators.resource`.*

---

## 9. UI Elements and Locator Strategy

### 9.1 Navigation Locators (apn_locators.resource)

| Element | Locator Variable | XPath / Selector |
|---|---|---|
| Service menu icon (sidebar) | `${LOC_MENU_SERVICE}` | `xpath=//*[@id="service-menu-icon"]` |
| APN tab (top navigation) | `${LOC_TAB_APN}` | `xpath=//*[@id="pageHeading"]/li[3]/a[1]` |
| Create APN button (on listing) | `${LOC_CREATE_APN_BTN}` | `xpath=//a[contains(@href,'/CreateAPN')]` |
| Manage APN grid | `${LOC_MANAGE_APN_GRID}` | `xpath=//div[contains(@class,'k-grid')]` |

### 9.2 Primary Details Locators (apn_locators.resource)

| Element | Locator Variable | XPath / Selector | Notes |
|---|---|---|---|
| APN Type | `${LOC_APN_TYPE}` | `xpath=//select[@name="apnCategory"]` | Select: `2`=Public, `1`=Private |
| Account dropdown | `${LOC_ACCOUNT_DROPDOWN}` | `xpath=//div[contains(@class,'selectBtn') and contains(@class,'form-control')]` | Custom dropdown |
| Account search input | `${LOC_ACCOUNT_SEARCH_INPUT}` | `xpath=//div[@id='primarydetails']//input[@placeholder='Search']` | Type account name to filter |
| BU react-select | `${LOC_BU_DROPDOWN}` | `xpath=//div[contains(@class,'basic-multi-select')]//div[contains(@class,'select__control')]` | Only for Private APN |
| APN ID | `${LOC_APN_ID}` | `xpath=//input[@name="apnIDID"]` | Max 19 digits |
| APN Name | `${LOC_APN_NAME}` | `xpath=//input[@name="roleName"]` | Max 50 chars |
| Description | `${LOC_DESCRIPTION}` | `xpath=//input[@name="roleDescription"]` | Max 500 chars |
| EQOS ID | `${LOC_EQOS_ID}` | `xpath=//input[@name="EQOSID"]` | Client-optional |
| HSS Context ID | `${LOC_HSS_CONTEXT_ID}` | `xpath=//input[@name="hssContextId"]` | Client-optional |
| IP Address Type | `${LOC_IP_ADDRESS_TYPE}` | `xpath=//*[@id="ipAddressType"]` | Select: `1`=IPV4, `0`=IPV6, `2`=IPV4&IPV6 |
| IP Allocation Type | `${LOC_IP_ALLOC_TYPE}` | `xpath=//select[@name="modificationType"]` | Shown after IP Address Type selected |

### 9.3 Radius Configuration Locators (apn_locators.resource)

| Element | Locator Variable | XPath / Selector | Notes |
|---|---|---|---|
| Radius accordion | `${LOC_RADIUS_DETAILS_TAB}` | `id=openRadiusDetailsTab` | Click to expand |
| Radius Configuration | `${LOC_RADIUS_CONFIG}` | `name=apnRediusConfigurationstate` | Note: "Redius" typo in source; options: `Authentication`, `Forwarding` |
| Radius Auth Type | `${LOC_RADIUS_AUTH_TYPE}` | `name=radiusAuthType` | Shown when Config = `Authentication` |
| Radius Password | `${LOC_RADIUS_PASSWORD}` | `name=radiusPassword` | Shown when Auth Type = `PAP/CHAP` |
| Realm dropdown | `${LOC_REALM}` | `name=realmlistdata` | Shown when Config = `Forwarding` |

### 9.4 Secondary Details Locators (apn_locators.resource)

| Element | Locator Variable | XPath / Selector |
|---|---|---|
| Secondary Details accordion | `${LOC_SECONDARY_DETAILS_PANEL}` | `xpath=//a[@href="#secondary"]` |
| HLR APN ID | `${LOC_HLR_APN_ID}` | `xpath=//input[@name="hlrApnId"]` |
| MCC | `${LOC_MCC}` | `xpath=//input[@name="mcc"]` |
| MNC | `${LOC_MNC}` | `xpath=//input[@name="mnc"]` |
| Profile ID | `${LOC_PROFILE_ID}` | `xpath=//input[@name="profileId"]` |

### 9.5 QoS Locators (apn_locators.resource)

| Element | Locator Variable | XPath / Selector |
|---|---|---|
| QoS accordion | `${LOC_QOS_PANEL}` | `xpath=//a[@href="#quality"]` |
| 2G/3G Profile Name | `${LOC_PROFILE_NAME_2G3G}` | `xpath=//input[@name="profileName2g3g"]` |
| 2G/3G BW Uplink | `${LOC_BW_UPLINK_2G3G}` | `xpath=//input[@name="bandwidthUplink2g3g"]` |
| 2G/3G BW Downlink | `${LOC_BW_DOWNLINK_2G3G}` | `xpath=//input[@name="bandwidthDownlink2g3g"]` |
| LTE Profile Name | `${LOC_PROFILE_NAME_LTE}` | `xpath=//input[@name="profileNameLTE"]` |
| LTE BW Uplink | `${LOC_BW_UPLINK_LTE}` | `xpath=//input[@name="bandwidthUplinkLTE"]` |
| LTE BW Downlink | `${LOC_BW_DOWNLINK_LTE}` | `xpath=//input[@name="bandwidthDownlinkLTE"]` |

### 9.6 Form Action Locators (apn_locators.resource)

| Element | Locator Variable | XPath / Selector | Notes |
|---|---|---|---|
| Submit button | `${LOC_SUBMIT_BTN}` | `xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit']` | **`<a>` tag** — NOT `<button>` |
| Close / Cancel | `${LOC_CLOSE_BTN}` | `xpath=//a[contains(@class,'btn-cancel-color') and normalize-space()='Close']` | Returns to Manage APN |
| Success toast | `${LOC_TOAST_SUCCESS}` | `xpath=//div[contains(@class,'Toastify__toast--success')]` | |
| Error toast | `${LOC_TOAST_ERROR}` | `xpath=//div[contains(@class,'Toastify__toast--error')]` | |
| Validation alert | `${LOC_ALERT_DANGER}` | `xpath=//div[contains(@class,'alert-danger')]` | |

---

## 10. Expected Results

| Step | RF Keyword | Expected Outcome |
|---|---|---|
| After login | `Verify Login Success` | Manage Devices grid visible; post-login landmark present |
| After Service > APN | `Navigate To Manage APN Via Service Tab` | `${MANAGE_APN_PATH}` loaded; `${LOC_MANAGE_APN_GRID}` and `${LOC_CREATE_APN_BTN}` visible |
| After clicking Create APN | `Click Create APN Button` | `${CREATE_APN_PATH}` loaded; `${LOC_APN_TYPE}` visible |
| After selecting APN Type | `Fill Primary Details` | Account dropdown re-loads; BU react-select appears for Private APN |
| After selecting IP Address Type | — | `${LOC_IP_ALLOC_TYPE}` dropdown appears |
| After clicking Submit | `Submit Create APN Form` | API call fires; success toast appears within 30s |
| After toast appears | `Verify APN Created Successfully` | Redirect to `/ManageAPN`; `${LOC_MANAGE_APN_GRID}` visible |

---

## 11. Negative Test Scenarios (from apn_tests.robot)

| Test ID | Scenario | Action | RF Assertion |
|---|---|---|---|
| TC_APN_010 | Submit with no fields filled | Click Submit without any input | `Verify Validation Error Or Still On Page` |
| TC_APN_011 | Missing APN Name | Fill all except APN Name; Submit | `Verify Validation Error Or Still On Page` |
| TC_APN_012 | Missing APN ID | Fill all except APN ID; Submit | `Verify Validation Error Or Still On Page` |
| TC_APN_013 | Missing APN Type | Leave APN Type as default; Submit | `Verify Validation Error Or Still On Page` |
| TC_APN_014 | Missing IP Address Type | Fill all except IP Address Type; Submit | `Verify Validation Error Or Still On Page` |
| TC_APN_015 | Missing IP Allocation Type | Select IP Address Type, leave Allocation default; Submit | `Verify Validation Error Or Still On Page` |
| TC_APN_016 | APN ID exceeds 19 digits | Enter `${APN_ID_EXCEEDS_MAX}` | `Verify Validation Error Or Still On Page` |
| TC_APN_017 | Duplicate APN Name | Submit with `${DUPLICATE_APN_NAME}` | `Verify Negative Submission Outcome` |
| TC_APN_018 | SQL Injection in APN Name | Submit with `${SQL_INJECTION_APN_NAME}` | `Verify Negative Submission Outcome` |
| TC_APN_019 | Special chars in APN Name | Submit with `${SPECIAL_CHARS_APN_NAME}` | `Verify Negative Submission Outcome` |
| TC_APN_020 | HLR APN ID exceeds 19 digits | Submit with `${HLR_APN_ID_EXCEEDS_MAX}` | `Verify Negative Submission Outcome` |
| TC_APN_021 | Direct access to Create APN (no login) | `Go To ${CREATE_APN_URL}` | `Verify Redirected To Login Page` |
| TC_APN_022 | Direct access to Manage APN (no login) | `Go To ${MANAGE_APN_URL}` | `Verify Redirected To Login Page` |

---

## 12. Validation Checks (from apn_keywords.resource)

| Keyword | Purpose |
|---------|---------|
| `Verify APN Created Successfully` | Waits for `${LOC_TOAST_SUCCESS}`, `${MANAGE_APN_PATH}`, `${LOC_MANAGE_APN_GRID}` |
| `Verify Primary Details Fields Visible` | Asserts `${LOC_APN_TYPE}`, `${LOC_APN_ID}`, `${LOC_APN_NAME}`, `${LOC_DESCRIPTION}`, `${LOC_IP_ADDRESS_TYPE}` visible |
| `Verify IP Alloc Type Appears After IP Selection` | `${LOC_IP_ALLOC_TYPE}` absent initially; appears after selecting `${VALID_IP_ADDR_TYPE_IPV4}` on `${LOC_IP_ADDRESS_TYPE}` |
| `Verify Cancel Redirects To Manage APN` | Clicks `${LOC_CLOSE_BTN}`; verifies on Manage APN listing |
| `Verify Validation Error Or Still On Page` | Checks `${LOC_ALERT_DANGER}` or `${LOC_TOAST_ERROR}`; asserts still on Create APN page |
| `Verify Negative Submission Outcome` | Robust check for error toast, alert-danger, or validation text; logs WARN if app accepted invalid input |

---

## 13. Automation Considerations

### 13.1 Explicit Waits Only — No `Sleep`

- Set `implicit_wait=0s` globally and **never mix** implicit + explicit waits
- Use `Wait Until Element Is Visible` for all dynamic content
- IP Allocation Type (`name=modificationType`) is rendered conditionally after IP Address Type is selected — always `Wait Until Element Is Visible` before interacting
- Radius Configuration sub-fields (Auth Type, Password, Realm) are conditional — wait before each interaction

### 13.2 SSL Certificate Bypass

```python
options.add_argument('--ignore-certificate-errors')
options.add_argument('--disable-web-security')
```

Mandatory for `https://192.168.1.26:7874` (self-signed cert).

### 13.3 Submit Is an `<a>` Tag — Not a `<button>`

The **Submit** element on the Create APN page is:

```jsx
<a href="javascript:void(0);" onClick={this.insertAPN} className="btn btn-custom-color ...">
    Submit
</a>
```

Use `Click Element` (not `Click Button`) when interacting with it. The locator `xpath=//a[contains(@class,'btn-custom-color') and not(contains(@href,'/CreateAPN'))]` safely targets it without matching the Create APN navigation link.

### 13.4 Source Typo — `apnRediusConfigurationstate`

The Radius Configuration field name in the source code is spelled `apnRediusConfigurationstate` (note: "Redius" not "Radius"). This is an intentional source-code typo. Use exactly:

```
name=apnRediusConfigurationstate
```

### 13.5 Service Tab Navigation

The stc-automation project uses **Service icon** (sidebar) and **APN tab** (top navigation). Pattern:

```robot
Click Element Via JS    ${LOC_MENU_SERVICE}
Sleep    2s
Wait Until Element Is Visible    ${LOC_TAB_APN}    timeout=30s
Click Element Via JS    ${LOC_TAB_APN}
```

Use `Navigate To Manage APN Via Service Tab` from `apn_keywords.resource` for the full flow.

### 13.6 Conditional Fields Based on Client Logic

The following fields are shown/hidden based on `customClientLogic.APN.*` flags which differ per deployment:

| Field | Flag | Default |
|---|---|---|
| EQOS ID (required) | `APN.Required.EQOSID` | Optional in most clients |
| HSS Context ID (required) | `APN.Required.contextId` | Optional in most clients |
| Service Type (M2M/M2MGCT) | `APN.serviceType` | Not always shown |
| APN Category (WL/BL) | `APN.apnCategory` | Shown only when serviceType=M2MGCT |
| Split Billing toggle | `APN.splitBilling` | Hidden for most clients |
| Roaming toggle | `APN.roaming` | Client-specific |
| Private Shared toggle | `APN.allowPrivateShared` | Client-specific |
| Radius Config section | `APN.radiusParamsConfig` | Client-specific |

Use `Run Keyword If Element Is Visible` guards for client-conditional fields.

### 13.7 BU Selection — react-select

The BU (Business Unit) field is a **react-select** component (not a native `<select>`). Interaction requires:

```robot
# Type BU name to filter
Click Element    ${LOC_BU_SELECT}
Input Text    ${LOC_BU_SELECT}    ${bu_name}
# Click first matching option
Click Element    xpath=//div[contains(@class,'react-select__option')][1]
```

This field is only visible when APN Type = Private AND Private-Shared toggle is OFF.

### 13.8 Page Load and Retry Pattern

For network-sensitive steps (post-submit redirect, grid refresh), wrap with retry:

```robot
Wait Until Keyword Succeeds    3x    5s    Wait Until Location Contains    /ManageAPN
```

### 13.9 Screenshot on Failure

Configured in `Test Teardown` (from apn_tests.robot):

```robot
Test Teardown     Capture Screenshot And Close Browser
```

`Capture Screenshot And Close Browser` (browser_keywords.resource) captures a screenshot on failure, then closes the browser.

---

## 14. Framework Recommendation

| Framework | Pros | Cons | Verdict |
|---|---|---|---|
| **Robot Framework + SeleniumLibrary** | Keyword-driven, business-readable, reusable keywords across all TC_xxx files | Slower startup | **Recommended** — consistent with TC_001–006 |
| **Playwright (Python)** | Fast, auto-wait, modern | Separate codebase from RF suite | Good for standalone runs |
| **Selenium (Python)** | Mature, wide support | Verbose boilerplate | Acceptable alternative |
| **Cypress** | Fast for JS-native teams | Cannot reuse RF keywords | Not preferred for this project |

---

## 15. Example Playwright Script

```python
"""
TC_007_Create_APN.py — Playwright Python equivalent
Mirrors the Robot Framework test above for non-RF environments.
"""
import re
from playwright.sync_api import sync_playwright, expect

BASE_URL = "https://192.168.1.26:7874"
USERNAME = "ksa_opco"
PASSWORD = "Admin@123"

def test_create_apn():
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=False,
            args=["--ignore-certificate-errors"]
        )
        context = browser.new_context(ignore_https_errors=True)
        page = context.new_page()

        # Login
        page.goto(BASE_URL)
        page.fill("input[name='username']", USERNAME)
        page.fill("input[name='password']", PASSWORD)
        page.fill("input[name='captcha']", "0")
        page.click("input[type='button'][class*='btn-custom-color']")

        # Wait for Manage Devices
        page.wait_for_selector("#gridData", timeout=20000)

        # Expand Service tab and click APN
        page.click("//a[contains(.,'Service') and not(contains(@href,'/'))]")
        page.wait_for_selector("a[href='/ManageAPN']", timeout=10000)
        page.click("a[href='/ManageAPN']")
        page.wait_for_url(re.compile(r".*/ManageAPN"), timeout=15000)

        # Click Create APN
        page.click("a[href='/CreateAPN']")
        page.wait_for_url(re.compile(r".*/CreateAPN"), timeout=15000)
        page.wait_for_selector("select[name='apnCategory']", timeout=10000)

        # Fill Primary Details
        page.select_option("select[name='apnCategory']", "1")         # Private
        page.select_option("[data-testid='APNPccountId']", index=1)   # First account
        page.fill("input[name='apnIDID']", "1001")
        page.fill("input[name='roleName']", "test-apn-automation")
        page.fill("input[name='roleDescription']", "APN created via automation")
        page.select_option("#ipAddressType", "1")                      # IPV4
        page.wait_for_selector("select[name='modificationType']", timeout=10000)
        page.select_option("select[name='modificationType']", "static")

        # Submit — <a> tag, NOT <button>
        page.click("a.btn-custom-color:not([href='/CreateAPN'])")

        # Validate
        page.wait_for_selector(".Toastify__toast--success", timeout=15000)
        page.wait_for_url(re.compile(r".*/ManageAPN"), timeout=10000)
        page.wait_for_selector(".k-grid", timeout=10000)
        print("✓ APN created successfully")

        context.close()
        browser.close()

if __name__ == "__main__":
    test_create_apn()
```

---

## 16. Success Validation Checklist

- [ ] `Open Browser And Navigate` (Test Setup) — browser opens at `${BASE_URL}` with SSL bypass
- [ ] `Login With Credentials` — authenticated as `${VALID_USERNAME}`; lands on Manage Devices
- [ ] `Verify Login Success` — Manage Devices grid visible
- [ ] `Navigate To Manage APN Via Service Tab` — Service icon clicked; APN tab clicked; `${MANAGE_APN_PATH}` loaded
- [ ] `Click Create APN Button` — navigated to `${CREATE_APN_PATH}`; `${LOC_APN_TYPE}` visible
- [ ] `Fill Primary Details` — all mandatory fields filled without errors
- [ ] `${LOC_IP_ALLOC_TYPE}` appears after selecting IP Address Type
- [ ] `Submit Create APN Form` — Submit `<a>` tag clicked via JS; no JS error
- [ ] `${LOC_TOAST_SUCCESS}` appears within 30 seconds
- [ ] Browser redirected to `/ManageAPN`
- [ ] `${LOC_MANAGE_APN_GRID}` visible and new APN record queryable

---

## 17. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-06 | CMP QA / Automation Team | Initial document — full Create APN workflow |
| 1.1 | 2026-03-10 | — | Updated to reflect stc-automation project structure: run_tests.py, apn_tests.robot, apn_keywords.resource, apn_locators.resource, apn_variables.py; actual test IDs TC_APN_001–TC_APN_022; Settings, locators, variables, keywords |
