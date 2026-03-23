# Automation Test Specification – Create IP Whitelisting

**Document Version:** 1.0 (Project-Aligned)
**Status:** Automated
**Framework:** Robot Framework + SeleniumLibrary
**Date:** 2026-03-10
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application

---

## 1. Objective

Validate the end-to-end **Create IP Whitelisting** policy workflow on the CMP web application. The IP Whitelisting module lives under the **Service** tab. The form uses a **two-phase workflow**: Phase 1 fills Customer + Business Unit and adds rules via a dialog; Phase 2 clicks Create to submit the policy.

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage IP Whitelisting URL** | `https://192.168.1.26:7874/IPWhitelisting` |
| **Create IP Whitelisting URL** | `https://192.168.1.26:7874/CreateIPWhitelisting` |
| **Navigation** | Service sidebar icon → IP Whitelisting tab |
| **Application Type** | React SPA |

---

## 3. Project File Mapping

| Artefact | File Path |
|---|---|
| **Test Suite** | `tests/ip_whitelist_tests.robot` |
| **Keywords** | `resources/keywords/ip_whitelist_keywords.resource` |
| **Locators** | `resources/locators/ip_whitelist_locators.resource` |
| **Variables** | `variables/ip_whitelist_variables.py` |
| **Config** | `config/env_config.py` |
| **Shared** | `resources/keywords/browser_keywords.resource`, `resources/keywords/login_keywords.resource` |
| **Prompt Doc** | `prompts/ip_whitelist/TC_010_Create_IP_Whitelisting_RF.md` (this file) |

---

## 4. Locator Reference

### 4.1 Navigation

| Element | Variable | Locator |
|---|---|---|
| Service sidebar icon | `${LOC_WL_MENU_SERVICE}` | `xpath=//*[@id="service-menu-icon"]` |
| IP Whitelisting tab | `${LOC_TAB_IP_WHITELISTING}` | `xpath=//*[@id="pageHeading"]//a[contains(@href,'/IPWhitelisting') or contains(text(),'IP Whitelisting')]` |
| Create Policy button | `${LOC_WL_CREATE_POLICY_BTN}` | `xpath=//a[contains(@href,'/CreateIPWhitelisting')]` |
| Listing grid | `${LOC_WL_GRID}` | `id=IPWhitelistingGrid` |

### 4.2 Header Form

| Element | Variable | Locator |
|---|---|---|
| Customer dropdown | `${LOC_WL_CUSTOMER_SELECT}` | `css:[data-testid="customerId"]` |
| Business Unit dropdown | `${LOC_WL_BU_SELECT}` | `name=businessUnit` |
| Add Rule button | `${LOC_WL_ADD_RULE_BTN}` | `xpath=//input[@type='button' and contains(@class,'add_rule_text')]` |
| Rules grid | `${LOC_WL_RULES_GRID}` | `id=gridDataUsageReport` |
| Rules grid rows | `${LOC_WL_RULES_GRID_ROW}` | `xpath=//div[@id='gridDataUsageReport']//tr[contains(@class,'k-master-row')]` |

### 4.3 Rule Dialog (`#add-service-item-dialog`)

| Element | Variable | Locator |
|---|---|---|
| Dialog container | `${LOC_WL_RULE_DIALOG}` | `id=add-service-item-dialog` |
| Source Subnet (react-select) | `${LOC_WL_SOURCE_SUBNET_CONTROL}` | `xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'react-select__control')]` |
| Source Subnet option | `${LOC_WL_SOURCE_SUBNET_OPTION}` | `xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'react-select__option')]` |
| Source IP input (ReactTags) | `${LOC_WL_SOURCE_IP_INPUT}` | `xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'ReactTags__tagInput')]//input` |
| Source IP tag | `${LOC_WL_SOURCE_IP_TAG}` | `xpath=//div[@id='add-service-item-dialog']//span[contains(@class,'ReactTags__tag')]` |
| Destination Address | `${LOC_WL_DESTINATION_ADDR}` | `id=destinationAddress` |
| Port dropdown | `${LOC_WL_PORT_SELECT}` | `xpath=//div[@id='add-service-item-dialog']//select[@name='port']` |
| Port Value input | `${LOC_WL_PORT_VALUE_INPUT}` | `xpath=//div[@id='add-service-item-dialog']//input[@name='portValue']` |
| Protocol dropdown | `${LOC_WL_PROTOCOL_SELECT}` | `xpath=//div[@id='add-service-item-dialog']//select[@name='protocol']` |
| Rule Submit button | `${LOC_WL_RULE_DIALOG_SUBMIT}` | `xpath=//div[@id='add-service-item-dialog']//button[contains(@class,'btn-custom-color')]` |
| Rule Close button | `${LOC_WL_RULE_DIALOG_CLOSE}` | `xpath=//div[@id='add-service-item-dialog']//button[contains(@class,'btn-cancel-color')]` |

### 4.4 Main Page Actions

| Element | Variable | Locator |
|---|---|---|
| Create button | `${LOC_WL_CREATE_BTN}` | `xpath=//input[@type='button' and contains(@class,'btn-custom-color') and not(contains(@class,'add_rule_text'))]` |
| Close button | `${LOC_WL_CLOSE_BTN}` | `xpath=//input[@type='button' and contains(@class,'btn-cancel-color')]` |

### 4.5 Validation

| Element | Variable | Locator |
|---|---|---|
| Success toast | `${LOC_WL_TOAST_SUCCESS}` | `xpath=//div[contains(@class,'Toastify__toast--success')]` |
| Error toast | `${LOC_WL_TOAST_ERROR}` | `xpath=//div[contains(@class,'Toastify__toast--error')]` |
| Alert danger | `${LOC_WL_ALERT_DANGER}` | `xpath=//div[contains(@class,'alert-danger')]` |

---

## 5. Variables Reference

| Variable | Value | Notes |
|---|---|---|
| `MANAGE_IP_WHITELIST_URL` | `https://192.168.1.26:7874/IPWhitelisting` | |
| `CREATE_IP_WHITELIST_URL` | `https://192.168.1.26:7874/CreateIPWhitelisting` | |
| `VALID_SOURCE_IP` | `10.10.10.1` | IPv4 address |
| `VALID_DESTINATION_ADDR` | `192.168.0.1` | Single IPv4 |
| `VALID_PORT` | `any` | Broadest coverage |
| `VALID_PORT_ENTER` | `EnterPort` | Shows port value field |
| `VALID_PORT_VALUE` | `8080` | Specific port |
| `VALID_PROTOCOL_TCP` | `TCP` | |
| `VALID_PROTOCOL_UDP` | `UDP` | |
| `VALID_PROTOCOL_ANY` | `any` | |
| `INVALID_SOURCE_IP` | `abc123` | Negative test |
| `INVALID_DESTINATION_ADDR` | `999.999.999.999` | Negative test |
| `PORT_VALUE_EXCEEDS_MAX` | `99999` | > 65535, negative test |

---

## 6. Keywords Reference

| Keyword | Description |
|---|---|
| `Navigate To IP Whitelisting Via Service` | Service icon → IP Whitelisting tab → listing |
| `Click Create Policy Button` | Listing → create form page |
| `Login And Navigate To Create IP Whitelisting` | Full login + navigate to create form |
| `Login And Navigate To IP Whitelisting List` | Full login + navigate to listing |
| `Select Customer From Dropdown` | Select first customer |
| `Select Business Unit From Dropdown` | Wait for BU API → select first BU |
| `Fill IP Whitelisting Header` | Customer + BU |
| `Open Rule Dialog` | Clicks Add Rule (validates header first) |
| `Select Source Address Subnet` | react-select → first option |
| `Add Source Address IP Tag` | ReactTags input + Enter → API validates |
| `Enter Destination Address` | textarea input |
| `Select Port` | Dropdown: any / EnterPort |
| `Enter Port Value` | Conditional field (EnterPort only) |
| `Select Protocol` | TCP / UDP / any |
| `Submit Rule Dialog` | Submit + wait for dialog close |
| `Submit Rule Dialog Expecting Error` | Submit without waiting for close |
| `Close Rule Dialog Without Submitting` | Close dialog |
| `Fill And Submit Rule` | Full dialog fill + submit |
| `Verify Rule Added To Grid` | Grid row count >= 1 |
| `Submit IP Whitelisting Policy` | Main Create button |
| `Click Close Button IP Whitelisting` | Cancel/close |
| `Verify IP Whitelisting Created Successfully` | Toast + redirect + grid |
| `Verify Create Button Is Disabled` | Button disabled state |
| `Verify On IP Whitelisting Listing Page` | URL + grid |
| `Verify Rule Dialog Did Not Open` | Dialog NOT visible |
| `Verify Rule Validation Error` | Toast/alert/dialog stays open |

---

## 7. Test Cases (20 Total: 9 Positive, 11 Negative)

### Positive

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_WL_001 | E2E Create IP Whitelisting Policy TCP Any Port | smoke, regression, positive, ip_whitelist |
| TC_WL_002 | Verify IP Whitelisting Listing Page Loads | smoke, regression, positive, ip_whitelist |
| TC_WL_003 | Verify Create IP Whitelisting Form Elements Visible | smoke, regression, positive, ip_whitelist |
| TC_WL_004 | Verify BU Dropdown Populates After Customer Selection | regression, positive, ip_whitelist |
| TC_WL_005 | Verify Rule Dialog Opens After Customer And BU Selected | regression, positive, ip_whitelist |
| TC_WL_006 | Verify Rule Appears In Grid After Submitting | regression, positive, ip_whitelist |
| TC_WL_007 | Verify Create Button Enabled After Adding Rule | regression, positive, ip_whitelist |
| TC_WL_008 | Create Policy With EnterPort And Specific Port Value | regression, positive, ip_whitelist |
| TC_WL_009 | Verify Cancel Button Redirects To Listing | regression, positive, ip_whitelist, navigation |

### Negative

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_WL_010 | Add Rule Without Customer Should Not Open Dialog | regression, negative, ip_whitelist |
| TC_WL_011 | Add Rule Without BU Should Not Open Dialog | regression, negative, ip_whitelist |
| TC_WL_012 | Create Button Disabled With No Rules | regression, negative, ip_whitelist |
| TC_WL_013 | Submit Rule With No Fields Should Show Error | regression, negative, ip_whitelist |
| TC_WL_014 | Submit Rule Without Destination Should Show Error | regression, negative, ip_whitelist |
| TC_WL_015 | Submit Rule With Invalid Destination Address | regression, negative, ip_whitelist |
| TC_WL_016 | Port Value Exceeding 65535 Should Show Error | regression, negative, ip_whitelist, boundary |
| TC_WL_017 | Close Rule Dialog Without Submitting | regression, negative, ip_whitelist |
| TC_WL_018 | Close Create Page Before Submitting | regression, negative, ip_whitelist, navigation |
| TC_WL_019 | Direct Access To Create IP Whitelisting Without Login | regression, negative, security, ip_whitelist, navigation |
| TC_WL_020 | Direct Access To IP Whitelisting List Without Login | regression, negative, security, ip_whitelist, navigation |

---

## 8. Automation Flow

```
Login → Manage Devices → Service Icon → IP Whitelisting Tab → /IPWhitelisting
    → Click Create Policy → /CreateIPWhitelisting
    → Fill: Customer → Business Unit
    → Click Add Rule → Rule Dialog (#add-service-item-dialog)
        → Source Subnet (react-select) → Source IP (ReactTags + Enter)
        → Destination (textarea) → Port → Protocol → Submit
    → Rule appears in grid → Create button becomes enabled
    → Click Create → API → Success Toast → /IPWhitelisting
```

---

## 9. Automation Considerations

1. **Customer → BU Order Dependency:** BU dropdown populates only after Customer is selected via `getAccountHierarchy` API.
2. **Add Rule Silent Validation:** `toggleRuleDialog()` calls `validateForm()` — if Customer or BU is missing, dialog silently refuses to open.
3. **Create Button Disabled Until Rules Exist:** `disabled` when `addRuleGridData.length < 1`.
4. **ReactTags Source IP:** Type IP + press Enter/Tab → API validates → tag appears (or rejected).
5. **react-select Source Subnet:** Click-based interaction, not native `<select>`.
6. **Destination Address is `<textarea>`:** Not `<input>`.
7. **Port Value Conditional:** Only visible when Port = `EnterPort`.
8. **Rule Dialog uses `<button>`; Main page uses `<input type="button">`:** Different HTML elements.
9. **Loading Overlay:** All keywords call `Wait For Loading Overlay To Disappear`.
10. **Test Isolation:** Fresh browser per test case.

---

## 10. Negative Test Scenarios

| ID | Scenario | Expected Result |
|---|---|---|
| NEG-01 | Add Rule without Customer | Dialog does NOT open |
| NEG-02 | Add Rule without BU | Dialog does NOT open |
| NEG-03 | Rule dialog submit empty | Validation error |
| NEG-04 | Missing Destination | Validation error |
| NEG-05 | Invalid Destination (999.999.999.999) | Toast warning |
| NEG-06 | Port Value > 65535 | Toast warning |
| NEG-07 | Close dialog without submit | No rule added |
| NEG-08 | Close create page | No policy created, redirect |
| NEG-09 | Create with zero rules | Button disabled |
| NEG-10 | Direct URL without login | Redirect to login |

---

## 11. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-10 | CMP QA / Automation Team | Initial — project-aligned spec with actual file paths, locator variables, and test case IDs |
