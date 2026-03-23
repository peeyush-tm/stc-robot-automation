# Automation Test Specification – Device State Change

**Document Version:** 2.0 (Implemented)
**Status:** Automated
**Framework:** Robot Framework + SeleniumLibrary
**Date:** 2026-03-03
**Owner:** CMP QA / Automation Team
**Application:** CMP Web Application

---

## 1. Objective

Validate all allowed **SIM state transitions** on the Manage Devices page. Each positive test:
1. Filters the grid by the initial SIM state using the Kendo filter panel UI
2. Captures the device ICCID from the filtered grid
3. Verifies the initial state column matches the expected state
4. Selects the device, chooses "Change State" action, selects the target state, and clicks Submit
5. Fills the popup (plans + reason or reason-only) and clicks Proceed
6. Searches for the ICCID after the change and verifies the SIM State column reflects the new state

The suite uses **suite-level browser session** (single login per suite run, not per test).

---

## 2. Application Details

| Field | Value |
|---|---|
| **Base URL** | `https://192.168.1.26:7874` |
| **Manage Devices URL** | `https://192.168.1.26:7874/ManageDevices` |
| **Navigation** | Post-login landing page |
| **Application Type** | React SPA with Kendo Grid |

---

## 3. Project File Mapping

| Artefact | File Path |
|---|---|
| **Test Suite** | `tests/device_state_tests.robot` |
| **Keywords** | `resources/keywords/device_state_keywords.resource` |
| **Locators** | `resources/locators/device_state_locators.resource` |
| **Variables** | `variables/device_state_variables.py` |
| **Config** | `config/env_config.py` |
| **Shared Keywords** | `resources/keywords/browser_keywords.resource`, `resources/keywords/login_keywords.resource` |
| **Prompt Doc** | `prompts/device_state/TC_002_Device_State_Change_RF.md` (this file) |

---

## 4. State Transition Matrix

| From State | Filter Label | Grid Value | Allowed Target States |
|---|---|---|---|
| **TestActive** | `TestActive` | `TestActive` | Activated, Suspended |
| **Activated** | `Activated` | `Activated` | Suspended, Terminate |
| **Suspended** | `Suspended` | `Suspended` | Activated, Terminate |
| **Warm** | `Warm` | `Warm` | Activated, TestActive |
| **InActive** | `InActive` | `TestReady` | Activated, TestActive |

Transitions FROM TestReady/TestActive TO Activated/TestActive require **Service Plan + Device Plan + Reason**.
All other transitions require only **Reason**.

---

## 5. Locator Reference

### 5.1 Grid

| Element | Variable | Locator |
|---|---|---|
| Grid container | `${LOC_DSC_GRID}` | `id=gridData` |
| Grid tbody | `${LOC_DSC_GRID_TBODY}` | `xpath=//div[@id='gridData']//tbody[@role='rowgroup']` |
| Grid rows | `${LOC_DSC_GRID_ROWS}` | `xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]` |
| First row | `${LOC_DSC_FIRST_ROW}` | `xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]` |
| First row checkbox | `${LOC_DSC_FIRST_ROW_CB}` | `xpath=(...)[1]//input[contains(@class,'sel')]` |
| Grid headers | `${LOC_DSC_GRID_HEADERS}` | `xpath=//div[@id='gridData']//thead//th` |

### 5.2 Search / Filter

| Element | Variable | Locator |
|---|---|---|
| Search input | `${LOC_DSC_SEARCH_INPUT}` | `id=searchinput` |
| Search close | `${LOC_DSC_SEARCH_CLOSE}` | `id=closeBtn` |
| Normal search trigger | `${LOC_DSC_NORMAL_SEARCH}` | `id=normal-search-trigger` |
| Filter search trigger | `${LOC_DSC_FILTER_SEARCH}` | `id=filter-search-trigger` |
| Filter area | `${LOC_DSC_FILTER_AREA}` | `id=filterArea` |
| Reset all filter | `${LOC_DSC_RESET_ALL_FILTER}` | `id=resetAllFilter` |
| Filter popup modal | `${LOC_DSC_FILTER_POPUP}` | `id=filterPopup` |
| SIM State filter text | `${LOC_DSC_SIM_STATE_FILTER}` | `xpath=//div[@id='filterArea']//*[contains(...,'SIM STATE')]` |

### 5.3 Action Bar

| Element | Variable | Locator |
|---|---|---|
| Action form | `${LOC_DSC_ACTION_FORM}` | `xpath=//form[@id='actionForm']` |
| Action dropdown | `${LOC_DSC_ACTION_DROP}` | `name=actionDrop` |
| Change State section | `${LOC_DSC_CHANGE_STATE_SEC}` | `id=changeState` |
| State dropdown | `${LOC_DSC_STATE_DROP}` | `name=changeSelectedValue` |
| State Submit button | `${LOC_DSC_STATE_SUBMIT_BTN}` | `id=submitActionBtn` |

### 5.4 State Change Popup (`#savePopup`)

| Element | Variable | Locator |
|---|---|---|
| Popup container | `${LOC_DSC_POPUP}` | `id=savePopup` |
| Popup title | `${LOC_DSC_POPUP_TITLE}` | `xpath=//div[@id='savePopup']//h4[contains(@class,'modal-title')]` |
| Service Plan | `${LOC_DSC_SVC_PLAN_DROP}` | `xpath=//*[@data-testid='simStatwReason']` |
| Device Plan | `${LOC_DSC_DEV_PLAN_DROP}` | `xpath=//*[@data-testid='simStatwReasons']` |
| Reason | `${LOC_DSC_REASON_DROP}` | `xpath=//*[@data-testid='simStatwReasonsd']` |
| Comment | `${LOC_DSC_COMMENT_BOX}` | `id=actionChangeComment` |
| Proceed button | `${LOC_DSC_PROCEED_BTN}` | `id=prceedBtn` |
| Close button | `${LOC_DSC_POPUP_CLOSE_BTN}` | `xpath=//div[@id='savePopup']//button[contains(@class,'btn-cancel-color')]` |
| X button | `${LOC_DSC_POPUP_X_BTN}` | `xpath=//div[@id='savePopup']//button[contains(@class,'close')]` |

### 5.5 Validation

| Element | Variable | Locator |
|---|---|---|
| Success toast | `${LOC_DSC_TOAST_SUCCESS}` | `xpath=//div[contains(@class,'Toastify__toast--success')]` |
| Error toast | `${LOC_DSC_TOAST_ERROR}` | `xpath=//div[contains(@class,'Toastify__toast--error')]` |
| Alert danger | `${LOC_DSC_ALERT_DANGER}` | `xpath=//div[contains(@class,'alert-danger')]` |

---

## 6. Variables Reference

### State Values (grid column text)

| Variable | Value |
|---|---|
| `STATE_ACTIVATED` | `Activated` |
| `STATE_SUSPENDED` | `Suspended` |
| `STATE_TERMINATE` | `Terminate` |
| `STATE_TEST_READY` | `TestReady` |
| `STATE_TEST_ACTIVE` | `TestActive` |
| `STATE_DEACTIVATED` | `Deactivated` |
| `STATE_WARM` | `Warm` |
| `STATE_INACTIVE` | `InActive` |
| `STATE_RETIRED` | `Retired` |

### Filter Panel Labels

| Variable | Value | Maps to Grid State |
|---|---|---|
| `FILTER_LABEL_ACTIVATED` | `Activated` | Activated |
| `FILTER_LABEL_SUSPENDED` | `Suspended` | Suspended |
| `FILTER_LABEL_TEST_ACTIVE` | `TestActive` | TestActive |
| `FILTER_LABEL_INACTIVE` | `InActive` | TestReady |
| `FILTER_LABEL_TERMINATE` | `Terminate` | Terminate |
| `FILTER_LABEL_WARM` | `Warm` | Warm |
| `FILTER_LABEL_RETIRED` | `Retired` | Retired |

### Other

| Variable | Value |
|---|---|
| `STATE_COLUMN_HEADER` | `SIM State` |
| `ICCID_COLUMN_HEADER` | `ICCID` |
| `MANAGE_DEVICES_URL` | `https://192.168.1.26:7874/ManageDevices` |

---

## 7. Keywords Reference

### Navigation

| Keyword | Description |
|---|---|
| `Login And Navigate To Manage Devices DSC` | Ensures session is active, navigates to `/ManageDevices`, waits for grid |

### Grid Column Helpers (JS-based)

| Keyword | Description |
|---|---|
| `Get Column Index By Header Text` | Returns 0-based column index by header text |
| `Get Cell Value By Row And Column` | Reads cell text (1-based row, 0-based col) |
| `Get First Device ICCID` | Reads ICCID from first visible row |
| `Get First Device SIM State` | Reads SIM State from first visible row |

### Filter / Search

| Keyword | Description |
|---|---|
| `Filter Grid By SIM State` | Opens filter panel → clicks SIM State → clicks target option → returns row index |
| `Apply SIM State Column Filter` | Interacts with Kendo PanelBar filter modal (`#filterPopup`) to select a SIM State |
| `Find Row By State Column` | JS scan of grid rows to find first match by state column |
| `Reset Grid To Default View` | Resets all filters and clears search |
| `Search Device By ICCID` | JS-based search input interaction for ICCID lookup |
| `Clear Grid Search` | Alias for `Reset Grid To Default View` |

### Device Selection

| Keyword | Description |
|---|---|
| `Select Device By Row Index` | Clicks checkbox at given 0-based row index |
| `Select First Device From Grid` | Clicks first row checkbox |

### Action Bar

| Keyword | Description |
|---|---|
| `Select Change State Action` | Selects "Change State" from action dropdown + dispatches change event |
| `Select Target State And Submit` | Selects target state + dispatches change event + clicks Submit button (`submitActionBtn`) |

### State Change Popup

| Keyword | Description |
|---|---|
| `Wait For Popup To Open` | Waits for `#savePopup` to be visible |
| `Select Service Plan In Popup` | Selects first service plan option |
| `Select Device Plan In Popup` | Selects first device plan option |
| `Select Reason In Popup` | Selects first reason option |
| `Click Proceed Button` | Clicks `id=prceedBtn` inside popup |
| `Close Popup Without Submitting` | Clicks close/cancel button inside popup |

### Composite Flows

| Keyword | Description |
|---|---|
| `Fill Popup And Submit` | Fills popup fields (plans if needed + reason) and clicks Proceed |
| `Perform Full State Change` | End-to-end: filter → ICCID → verify initial → select → change → submit |
| `Verify State Change Success` | Asserts success toast + popup dismissed |
| `Verify Device State After Change` | Resets grid → searches ICCID → asserts new state |
| `Attempt Invalid Transition And Verify Blocked` | Verifies invalid state not in dropdown or error toast appears |

---

## 8. Test Cases (23 Total: 14 Positive, 9 Negative)

### Positive — UI Verification (2)

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_DSC_001 | Verify Manage Devices Grid And Action Bar | smoke, regression, positive, device_state |
| TC_DSC_002 | Verify Initial State Matches Filter | smoke, regression, positive, device_state, testactive |

### Positive — State Transitions (10)

| TC ID | Test Case Name | From → To | Filter Label | Tags |
|---|---|---|---|---|
| TC_DSC_003 | TestActive To Activated | TestActive → Activated | TestActive | smoke, regression, positive, device_state, testactive |
| TC_DSC_004 | TestActive To Suspended | TestActive → Suspended | TestActive | regression, positive, device_state, testactive |
| TC_DSC_005 | Activated To Suspended | Activated → Suspended | Activated | regression, positive, device_state, activated |
| TC_DSC_006 | Activated To Terminate | Activated → Terminate | Activated | regression, positive, device_state, activated |
| TC_DSC_007 | Suspended To Activated | Suspended → Activated | Suspended | regression, positive, device_state, suspended |
| TC_DSC_008 | Suspended To Terminate | Suspended → Terminate | Suspended | regression, positive, device_state, suspended |
| TC_DSC_009 | Warm To Activated | Warm → Activated | Warm | regression, positive, device_state, warm |
| TC_DSC_010 | Warm To TestActive | Warm → TestActive | Warm | regression, positive, device_state, warm |
| TC_DSC_011 | InActive To Activated | TestReady → Activated | InActive | regression, positive, device_state, inactive |
| TC_DSC_012 | InActive To TestActive | TestReady → TestActive | InActive | regression, positive, device_state, inactive |

### Positive — Popup UI Verification (2)

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_DSC_013 | Verify State Change Popup Opens | regression, positive, device_state, testactive |
| TC_DSC_014 | Close Popup Without Submitting Should Not Change State | regression, positive, device_state |

### Negative — Invalid Transitions (6)

| TC ID | Test Case Name | Attempted Transition | Tags |
|---|---|---|---|
| TC_DSC_015 | TestActive To Terminate Should Be Blocked | TestActive → Terminate | regression, negative, device_state, testactive |
| TC_DSC_016 | Activated To TestActive Should Be Blocked | Activated → TestActive | regression, negative, device_state, activated |
| TC_DSC_017 | Activated To TestReady Should Be Blocked | Activated → TestReady | regression, negative, device_state, activated |
| TC_DSC_018 | Warm To Suspended Should Be Blocked | Warm → Suspended | regression, negative, device_state, warm |
| TC_DSC_019 | Warm To Terminate Should Be Blocked | Warm → Terminate | regression, negative, device_state, warm |
| TC_DSC_020 | Suspended To TestActive Should Be Blocked | Suspended → TestActive | regression, negative, device_state, suspended |

### Negative — UI Validation (2)

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_DSC_021 | No Device Selected Should Not Allow Action | regression, negative, device_state |
| TC_DSC_022 | Proceed Without Selecting Reason Should Be Blocked | regression, negative, device_state, testactive |

### Negative — Security (1)

| TC ID | Test Case Name | Tags |
|---|---|---|
| TC_DSC_023 | Direct Access To ManageDevices Without Login | regression, negative, security, device_state, navigation |

---

## 9. Automation Flow

```
Suite Setup: Open browser → Login once → Persist session
    ↓
Each Test:
    Navigate to /ManageDevices → Grid visible
        → Click filter-search-trigger → Filter popup (#filterPopup) opens
        → Click "SIM State" panel header → Expand state options
        → Click target state option (e.g., "TestActive") → Grid filters
        → JS scan grid rows for matching state → Get ICCID + verify initial state
        → Click device checkbox → Action dropdown: "Change State" (+ dispatchEvent)
        → State dropdown: Select target state (+ dispatchEvent) → Click Submit (id=submitActionBtn)
        → Popup (#savePopup) opens
            → [If needs plans]: Select Service Plan → Select Device Plan
            → Select Reason → Click Proceed (id=prceedBtn)
        → Success toast → Popup closes
        → Reset grid → Search by ICCID → Verify state column = target state
    ↓
Suite Teardown: Close All Browsers
```

---

## 10. Key Implementation Details

1. **Suite-level session:** Browser opens once in Suite Setup. Login happens once. Tests share the session.
2. **Filter panel UI:** Uses Kendo PanelBar inside `#filterPopup` modal. Click `filter-search-trigger` → expand "SIM State" → click the specific `<li>` option.
3. **Filter label ≠ Grid value:** The filter panel label "InActive" maps to grid value "TestReady". Use `FILTER_LABEL_*` variables for filter interaction, `STATE_*` variables for grid verification.
4. **Event dispatch required:** After `Select From List By Label` on dropdowns, a `dispatchEvent(new Event('change', {bubbles: true}))` is needed to trigger React state updates.
5. **Submit button after state selection:** After selecting the target state, click `id=submitActionBtn` to trigger the popup. The popup does NOT auto-open on dropdown change.
6. **Typo-aware IDs:** `id=prceedBtn` (not proceedBtn) — matches the actual app source.
7. **JS-based grid interaction:** Column indices and cell values are read via JavaScript for reliability with Kendo grid.
8. **Test teardown:** `Handle Test Teardown` captures screenshot on failure without closing the browser.

---

## 11. Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-10 | CMP QA Team | Initial spec with 10 valid + 6 invalid transitions, 7 UI/validation tests |
| 2.0 | 2026-03-03 | CMP QA Team | Restructured: TestActive-first ordering, Warm/InActive transitions added, filter panel UI, suite-level session, Submit button flow, event dispatch |
