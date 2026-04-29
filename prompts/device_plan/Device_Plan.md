# Device Plan Change Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Device_Plan` |
| **Suite File** | `tests/device_plan_tests.robot` |
| **Variables File** | `variables/device_plan_variables.py` |
| **Locators File** | `resources/locators/device_plan_locators.resource` |
| **Keywords File** | `resources/keywords/device_plan_keywords.resource` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageDevices` |
| **Total TCs** | 9 |
| **Tags** | `regression`, `smoke`, `negative`, `positive`, `TC_DP_NNN` |

## Run Commands

```bash
python run_tests.py --suite Device_Plan --env qe
python run_tests.py tests/device_plan_tests.robot --env qe
python run_tests.py --suite Device_Plan --env qe --include smoke
python run_tests.py --suite Device_Plan --env qe --test "TC_DP_002*"
```

## Module Description

The **Change Device Plan** module allows users to reassign a SIM card's service plan from the Manage Devices grid. The user selects a SIM, clicks Change Device Plan, selects a new plan in the popup, provides a reason, and confirms. Plan changes are permitted for Active, TestActive, and Suspended SIMs but blocked for Terminated SIMs.

**Navigation:** Login → Manage Devices grid → select SIM row → Change Device Plan button → popup → select plan + reason → Submit

## Allowed Plan Change by State

| SIM State | Plan Change Allowed |
|-----------|-------------------|
| Activated | ✅ Yes |
| TestActive | ✅ Yes |
| Suspended | ✅ Yes |
| Terminate | ❌ Blocked |

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_DP_002 | Change Device Plan On Activated SIM | Positive | smoke, regression, positive, TC_DP_002 |
| TC_DP_003 | Change Device Plan On TestActive SIM | Positive | regression, positive, TC_DP_003 |
| TC_DP_004 | Change Device Plan On Suspended SIM | Positive | regression, positive, TC_DP_004 |
| TC_DP_005 | Verify Change Device Plan Popup Opens | Positive | regression, positive, TC_DP_005 |
| TC_DP_006 | Close Popup Without Submitting Should Not Change Plan | Positive | regression, positive, TC_DP_006 |
| TC_DP_007 | Change Device Plan On Terminate SIM Should Be Blocked | Negative | regression, negative, TC_DP_007 |
| TC_DP_008 | No Device Selected Should Not Allow Action | Negative | regression, negative, TC_DP_008 |
| TC_DP_009 | Proceed Without Selecting Reason Should Be Blocked | Negative | regression, negative, TC_DP_009 |
| TC_DP_010 | No Plan Selected Should Not Open Popup | Negative | regression, negative, TC_DP_010 |

## Test Case Categories

### Positive — Plan Changes (5 TCs)
- **TC_DP_002** — Change plan on Activated SIM: select SIM, click Change Plan, choose new plan, provide reason, submit. Verifies new plan in grid.
- **TC_DP_003** — Same flow for TestActive SIM.
- **TC_DP_004** — Same flow for Suspended SIM.
- **TC_DP_005** — Select an Activated SIM → Change Device Plan opens the plan selection popup.
- **TC_DP_006** — Closing the popup without selecting a plan leaves the SIM plan unchanged.

### Negative — Blocked Scenarios (4 TCs)
- **TC_DP_007** — Terminated SIM selected → Change Device Plan button is disabled or shows an error when clicked.
- **TC_DP_008** — No SIM checkbox selected → Change Device Plan button is disabled.
- **TC_DP_009** — Popup open, Reason dropdown not selected → Proceed/Submit button is disabled.
- **TC_DP_010** — No plan selected from the plan list → dialog/popup does not open or shows validation.

---

## Locators

All locators are defined in `resources/locators/device_plan_locators.resource`.

### Grid / Table

| Variable | Locator | Description |
|----------|---------|-------------|
| `${LOC_DP_GRID}` | `id=gridData` | Main Manage Devices grid container |
| `${LOC_DP_GRID_ROWS}` | `xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]` | All SIM rows in the grid |
| `${LOC_DP_FIRST_ROW}` | `xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]` | First SIM row |
| `${LOC_DP_FIRST_ROW_CB}` | `xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]//input[contains(@class,'sel')]` | Checkbox of first SIM row |
| `${LOC_DP_GRID_HEADERS}` | `xpath=//div[@id='gridData']//thead//th` | Grid column headers |

### Search

| Variable | Locator | Description |
|----------|---------|-------------|
| `${LOC_DP_SEARCH_INPUT}` | `id=searchinput` | Search text input |
| `${LOC_DP_SEARCH_CLOSE}` | `id=closeBtn` | Clear/close search button |
| `${LOC_DP_NORMAL_SEARCH}` | `id=normal-search-trigger` | Normal search trigger button |
| `${LOC_DP_FILTER_SEARCH}` | `id=filter-search-trigger` | Filter search trigger button |

### Filter Area

| Variable | Locator | Description |
|----------|---------|-------------|
| `${LOC_DP_FILTER_AREA}` | `id=filterArea` | Filter area container |
| `${LOC_DP_RESET_ALL_FILTER}` | `id=resetAllFilter` | Reset all filters button |
| `${LOC_DP_FILTER_POPUP}` | `id=filterPopup` | Filter popup container |
| `${LOC_DP_ACCOUNT_INPUT}` | `id=accountInput` | Account filter input |
| `${LOC_DP_ACCOUNT_CLOSE_BTN}` | `id=accountCloseBtn` | Clear account filter button |

### Action Bar

| Variable | Locator | Description |
|----------|---------|-------------|
| `${LOC_DP_ACTION_FORM}` | `xpath=//form[@id='actionForm']` | Action bar form |
| `${LOC_DP_ACTION_DROP}` | `name=actionDrop` | Action dropdown (e.g. Change Device Plan) |
| `${LOC_DP_CHANGE_STATE_SEC}` | `id=changeState` | Change state section |
| `${LOC_DP_PLAN_DROP}` | `name=changeSelectedValue` | Plan selection dropdown |
| `${LOC_DP_SUBMIT_ACTION_BTN}` | `id=submitAction` | Submit action button |

### Change Device Plan Popup

| Variable | Locator | Description |
|----------|---------|-------------|
| `${LOC_DP_POPUP}` | `id=savePopup` | Popup modal container |
| `${LOC_DP_POPUP_TITLE}` | `xpath=//div[@id='savePopup']//h4[contains(@class,'modal-title')]` | Popup title heading |
| `${LOC_DP_POPUP_X_BTN}` | `xpath=//div[@id='savePopup']//button[contains(@class,'close')]` | Popup close (X) button |
| `${LOC_DP_REASON_DROP}` | `xpath=//*[@data-testid='simStatwReasonsd']` | Reason dropdown inside popup |
| `${LOC_DP_COMMENT_BOX}` | `id=actionChangeComment` | Comment text box |
| `${LOC_DP_PROCEED_BTN}` | `id=prceedBtn` | Proceed / confirm button |
| `${LOC_DP_POPUP_CLOSE_BTN}` | `xpath=//div[@id='savePopup']//button[contains(@class,'btn-cancel-color')]` | Cancel button inside popup |

### Validation / Toasts

| Variable | Locator | Description |
|----------|---------|-------------|
| `${LOC_DP_TOAST_SUCCESS}` | `xpath=//div[contains(@class,'Toastify__toast--success')]` | Success toast notification |
| `${LOC_DP_TOAST_ERROR}` | `xpath=//div[contains(@class,'Toastify__toast--error')]` | Error toast notification |
| `${LOC_DP_ALERT_DANGER}` | `xpath=//div[contains(@class,'alert-danger')]` | Inline danger alert |

---

## Automation Notes

- SIM states are **pre-seeded** in the test database. Each test selects a SIM already in the required source state.
- The Change Device Plan popup lists available plans as radio buttons or a dropdown; keyword selects by plan name.
- Reason field (`LOC_DP_REASON_DROP`) is a dropdown; must be selected before Submit (`LOC_DP_PROCEED_BTN`) becomes enabled.
- After plan change, the Manage Devices grid row is re-filtered to confirm the updated plan column.
- Plan changes for Terminated SIMs: the action button is disabled in the UI when a Terminated SIM is selected.
- `showDevicePlanAndServicePlan=false` in the popup — only Reason dropdown and Comment box are rendered (no plan picker inside popup).
