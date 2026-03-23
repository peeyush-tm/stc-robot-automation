# Automation Test Specification – Create IP Pool

**Document Version:** 1.0 (Project-Aligned)
**Status:** Automated
**Framework:** Robot Framework + SeleniumLibrary
**Date:** 2026-03-10
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application

---

## 1. Objective

Validate the end-to-end **Create IP Pool** workflow on the CMP web application. The IP Pooling module lives under the **Service** tab. The form follows a **two-step flow**: Step 1 fills the form and clicks Create (fetches available IP ranges); Step 2 reviews IP details and clicks Submit to persist the pool.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage IP Pooling URL** | `https://192.168.1.26:7874/manageIPPooling` |
| **Create IP Pool URL** | `https://192.168.1.26:7874/CreateIPPooling` |
| **Navigation** | Service sidebar icon → IP Pooling tab |
| **Application Type** | React SPA |

---

## 3. Project File Mapping

| Artefact | File Path |
|---|---|
| **Test Suite** | `tests/ip_pool_tests.robot` |
| **Keywords** | `resources/keywords/ip_pool_keywords.resource` |
| **Locators** | `resources/locators/ip_pool_locators.resource` |
| **Variables** | `variables/ip_pool_variables.py` |
| **Config** | `config/env_config.py` |
| **Shared** | `resources/keywords/browser_keywords.resource`, `resources/keywords/login_keywords.resource` |
| **Prompt Doc** | `prompts/ip_pool/TC_008_Create_IP_Pool_RF.md` (this file) |

---

## 4. Locator Reference

### 4.1 Navigation

| Element | Variable | Locator |
|---|---|---|
| Service sidebar icon | `${LOC_IP_MENU_SERVICE}` | `xpath=//*[@id="service-menu-icon"]` |
| IP Pooling tab | `${LOC_TAB_IP_POOLING}` | `xpath=//*[@id="pageHeading"]//a[contains(@href,'/manageIPPooling') or contains(text(),'IP Pooling')]` |
| Create IP Pool button | `${LOC_IP_CREATE_BTN}` | `xpath=//a[contains(@href,'/CreateIPPooling')]` |
| Listing grid | `${LOC_IP_GRID}` | `xpath=//div[contains(@class,'k-grid')]` |

### 4.2 Create IP Pool Form

| Element | Variable | Locator |
|---|---|---|
| Account TreeView | `${LOC_IP_ACCOUNT_TREE}` | `xpath=//div[@for='accountId']` |
| First account node | `${LOC_IP_ACCOUNT_TREE_FIRST}` | `xpath=//ul[contains(@class,'treeview')]//li[1]//span[contains(@class,'item')]` |
| APN Type | `${LOC_IP_APN_TYPE}` | `name=apnCategory` |
| Number of IPs | `${LOC_IP_NUMBER_OF_IPS}` | `name=numberOfIps` |
| APN dropdown | `${LOC_IP_APN_SELECT}` | `css:[data-testid='APNPrfiln']` |

### 4.3 Action Buttons

| Element | Variable | Locator |
|---|---|---|
| Create (Step 1) | `${LOC_IP_CREATE_STEP_BTN}` | `xpath=//input[@type='button' and contains(@class,'btn-custom-color') and @value='Create']` |
| Submit (Step 2) | `${LOC_IP_SUBMIT_BTN}` | `xpath=//input[@type='button' and @value='Submit']` |
| Close / Cancel | `${LOC_IP_CLOSE_BTN}` | `xpath=//input[@type='button' and contains(@class,'btn-cancel-color')]` |

### 4.4 IP Details Panel

| Element | Variable | Locator |
|---|---|---|
| Generated IPs | `${LOC_IP_GENERATED_IPS}` | `xpath=//label[contains(@class,'gc-label') and contains(.,'Generated')]/following-sibling::span` |
| Requested IPs | `${LOC_IP_REQUESTED_IPS}` | `xpath=//label[contains(@class,'gc-label') and contains(.,'Requested')]/following-sibling::span` |
| APN Name label | `${LOC_IP_APN_NAME_LABEL}` | `xpath=//label[contains(@class,'gc-label') and contains(.,'APN Name')]/following-sibling::span` |
| Account Name label | `${LOC_IP_ACCOUNT_NAME_LABEL}` | `xpath=//label[contains(@class,'gc-label') and contains(.,'Account Name')]/following-sibling::span` |
| IPv4 table | `${LOC_IP_IPV4_TABLE}` | `xpath=//td[text()='IPV4']/ancestor::table` |
| IPv6 table | `${LOC_IP_IPV6_TABLE}` | `xpath=//td[text()='IPV6']/ancestor::table` |
| Next Available IPV4 | `${LOC_IP_NEXT_IPV4}` | `xpath=//label[contains(.,'Next Available IPV4')]/following-sibling::span` |
| Next Available IPV6 | `${LOC_IP_NEXT_IPV6}` | `xpath=//label[contains(.,'Next Available IPV6')]/following-sibling::span` |

### 4.5 Validation

| Element | Variable | Locator |
|---|---|---|
| Success toast | `${LOC_IP_TOAST_SUCCESS}` | `xpath=//div[contains(@class,'Toastify__toast--success')]` |
| Error toast | `${LOC_IP_TOAST_ERROR}` | `xpath=//div[contains(@class,'Toastify__toast--error')]` |
| Alert danger | `${LOC_IP_ALERT_DANGER}` | `xpath=//div[contains(@class,'alert-danger')]` |

---

## 5. Variables Reference

| Variable | Value | Notes |
|---|---|---|
| `MANAGE_IP_POOL_URL` | `https://192.168.1.26:7874/manageIPPooling` | |
| `CREATE_IP_POOL_URL` | `https://192.168.1.26:7874/CreateIPPooling` | |
| `APN_TYPE_PUBLIC` | `2` | Public APN |
| `APN_TYPE_PRIVATE` | `1` | Private APN (if enabled) |
| `VALID_NUMBER_OF_IPS` | `5` | Must be within available count |
| `ZERO_IPS` | `0` | Negative test |
| `NON_NUMERIC_IPS` | `abc` | Negative test |
| `EXCEEDS_AVAILABLE_IPS` | `99999` | Negative test |

---

## 6. Keywords Reference

| Keyword | Description |
|---|---|
| `Navigate To IP Pooling Via Service` | Service icon → IP Pooling tab → listing page |
| `Click Create IP Pool Button` | Listing → Create form page |
| `Login And Navigate To Create IP Pool` | Full login + navigate to create form |
| `Login And Navigate To IP Pool List` | Full login + navigate to listing |
| `Select Account From TreeView IP Pool` | TreeView dropdown → first account |
| `Select APN Type` | Select Public/Private |
| `Enter Number Of IPs` | Clear + enter numeric value |
| `Select APN From Dropdown` | Wait for APN list → select first |
| `Fill IP Pool Form` | Account + APN Type + IPs + APN |
| `Click Create And Wait For IP Details` | Step 1 → fetch IP ranges → panel |
| `Submit IP Pool` | Step 2 → persist pool |
| `Click Close Button IP Pool` | Cancel/close form |
| `Verify IP Pool Created Successfully` | Toast + redirect + grid |
| `Verify IP Details Panel Visible` | Panel with IPv4/IPv6 tables |
| `Verify Create Step Button Is Disabled Or Error` | Error/alert/still on form |
| `Verify On IP Pool Listing Page` | URL + grid visible |

---

## 7. Test Cases (17 Total: 8 Positive, 9 Negative)

### Positive

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_IPP_001 | E2E Create IP Pool With Public APN | smoke, regression, positive, ip_pool |
| TC_IPP_002 | Verify IP Pool Listing Page Loads | smoke, regression, positive, ip_pool |
| TC_IPP_003 | Verify Create IP Pool Form Elements Visible | smoke, regression, positive, ip_pool |
| TC_IPP_004 | Verify IP Details Panel After Clicking Create | regression, positive, ip_pool |
| TC_IPP_005 | Verify Pool Count In IP Details Panel | regression, positive, ip_pool |
| TC_IPP_006 | Cancel Before Submit Redirects To Listing | regression, positive, ip_pool, navigation |
| TC_IPP_007 | Verify APN Dropdown Populates After Account And Type | regression, positive, ip_pool |
| TC_IPP_008 | Verify Close Button On Create Page Redirects | regression, positive, ip_pool, navigation |

### Negative

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_IPP_009 | Create With No Fields Filled Should Show Error | regression, negative, ip_pool |
| TC_IPP_010 | Create Without Account Should Show Error | regression, negative, ip_pool |
| TC_IPP_011 | Create Without APN Type Should Show Error | regression, negative, ip_pool |
| TC_IPP_012 | Create Without Number Of IPs Should Show Error | regression, negative, ip_pool |
| TC_IPP_013 | Create Without APN Selected Should Show Error | regression, negative, ip_pool |
| TC_IPP_014 | Create With Zero IPs Should Show Error | regression, negative, ip_pool, boundary |
| TC_IPP_015 | Create With Non Numeric IPs Should Show Error | regression, negative, ip_pool, boundary |
| TC_IPP_016 | Direct Access To Create IP Pool Without Login | regression, negative, security, ip_pool, navigation |
| TC_IPP_017 | Direct Access To IP Pool List Without Login | regression, negative, security, ip_pool, navigation |

---

## 8. Automation Flow

```
Login → Manage Devices → Service Icon → IP Pooling Tab → /manageIPPooling
    → Click Create → /CreateIPPooling
    → Fill: Account → APN Type → Number of IPs → APN
    → Click Create (Step 1) → API fetch → IP Details Panel
    → Click Submit (Step 2) → API create → Success Toast → /manageIPPooling
```

---

## 9. Automation Considerations

1. **Two-Step Flow:** Submit only appears after Create is clicked and IP Details panel renders.
2. **APN Dropdown Dependency:** Account + APN Type must both be selected before APN dropdown populates.
3. **TreeView Account Selection:** Custom React component — uses Click Element Via JS.
4. **Create/Submit are `<input type="button">`:** Use Click Element, not Click Button.
5. **Loading Overlay:** All keywords call `Wait For Loading Overlay To Disappear`.
6. **Test Isolation:** Fresh browser per test case.

---

## 10. Negative Test Scenarios

| ID | Scenario | Expected Result |
|---|---|---|
| NEG-01 | Create with no fields | Validation error or still on form |
| NEG-02 | Missing Account | Error toast/alert |
| NEG-03 | Missing APN Type | Error toast/alert |
| NEG-04 | Missing Number of IPs | Error toast/alert |
| NEG-05 | Missing APN | Error toast/alert |
| NEG-06 | Number of IPs = 0 | Joi validation rejects |
| NEG-07 | Non-numeric IPs | Validation error |
| NEG-08 | Direct URL without login | Redirect to login page |

---

## 11. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-10 | CMP QA / Automation Team | Initial — project-aligned spec with actual file paths, locator variables, and test case IDs |
