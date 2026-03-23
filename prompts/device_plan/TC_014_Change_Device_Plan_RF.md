# TC_014 — Change Device Plan
## Robot Framework Test Specification (Implemented)

**Version:** 2.0 (Implemented)
**Date:** 2026-03-10
**Module:** Change Device Plan
**Framework:** Robot Framework + SeleniumLibrary

---

## 1. Objective

Validate that an authenticated user can change the **Device Plan** on a selected SIM from the **Manage Devices** page. Tests cover:

- Filtering by account (`billingAccountDONTUSE_005`) and SIM state using Kendo filter panel
- Reading the initial Device Plan (DP1) from the grid
- Selecting a different Device Plan (DP2) from the action bar dropdown
- Filling the popup (Reason only — `showDevicePlanAndServicePlan=false` for this action)
- Waiting 5 minutes for async processing
- Verifying the Device Plan column in the grid shows DP2 by searching the same IMSI

---

## 2. Project File Mapping

| File | Purpose |
|------|---------|
| `tests/device_plan_tests.robot` | All test cases |
| `resources/keywords/device_plan_keywords.resource` | Module-specific keywords |
| `resources/locators/device_plan_locators.resource` | All locators |
| `variables/device_plan_variables.py` | Variables and test data |
| `prompts/device_plan/TC_014_Change_Device_Plan_RF.md` | This specification |

---

## 3. SIM State Eligibility

| SIM State | Change Device Plan Allowed? |
|-----------|---------------------------|
| Activated | Yes |
| TestActive | Yes |
| Suspended | Yes |
| Terminate | No — blocked |

---

## 4. Locator Reference

| Variable | Selector |
|----------|----------|
| `LOC_DP_GRID` | `id=gridData` |
| `LOC_DP_GRID_ROWS` | `xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]` |
| `LOC_DP_SEARCH_INPUT` | `id=searchinput` |
| `LOC_DP_FILTER_SEARCH` | `id=filter-search-trigger` |
| `LOC_DP_FILTER_POPUP` | `id=filterPopup` |
| `LOC_DP_ACCOUNT_INPUT` | `id=accountInput` |
| `LOC_DP_ACTION_DROP` | `name=actionDrop` |
| `LOC_DP_CHANGE_STATE_SEC` | `id=changeState` |
| `LOC_DP_PLAN_DROP` | `name=changeSelectedValue` |
| `LOC_DP_POPUP` | `id=savePopup` |
| `LOC_DP_REASON_DROP` | `xpath=//*[@data-testid='simStatwReasonsd']` |
| `LOC_DP_PROCEED_BTN` | `id=prceedBtn` |
| `LOC_DP_TOAST_SUCCESS` | `xpath=//div[contains(@class,'Toastify__toast--success')]` |

---

## 5. Variables Reference

| Variable | Value | Purpose |
|----------|-------|---------|
| `DP_ACCOUNT_NAME` | `billingAccountDONTUSE_005` | Account filter |
| `DP_ACTION_LABEL` | `Change Device Plan` | Action dropdown text |
| `DP_STATE_COLUMN` | `SIM State` | Grid column header |
| `DP_DEVICE_PLAN_COLUMN` | `Device Plan` | Grid column header for verification |
| `DP_IMSI_COLUMN` | `IMSI` | Grid column header |

---

## 6. Keywords Reference

| Keyword | Purpose |
|---------|---------|
| `Login And Navigate To Manage Devices DP` | Session check + navigate to ManageDevices |
| `Filter DP Grid By Account And State` | Apply account + SIM state filter, return row index |
| `Apply DP Account Filter` | Type account name + Enter → click exact match |
| `Apply DP SIM State Filter` | Expand SIM State panel → click target |
| `Select Change Device Plan Action` | Select "Change Device Plan" from action dropdown |
| `Select Target Device Plan And Get Names` | Read DP1, select DP2, return both names |
| `Fill DP Popup And Submit` | Select Reason + click Proceed |
| `Perform Full Device Plan Change` | End-to-end: filter, validate, capture IMSI/DP1, change to DP2 |
| `Verify DP Change Success And Wait` | Check toast + wait 5 min |
| `Verify Device Plan After Change` | Search IMSI, verify Device Plan column = DP2 |
| `Verify Device Plan Unchanged` | Search IMSI, verify Device Plan column unchanged |

---

## 7. Test Cases (11 total: 6 positive, 5 negative)

### Positive (6)

| ID | Name | Description |
|----|------|-------------|
| TC_CDP_001 | Verify Grid And Action Bar | Grid visible with rows, search, action bar |
| TC_CDP_002 | Change Device Plan On Activated SIM | Filter Activated → validate DP1 → change to DP2 → verify |
| TC_CDP_003 | Change Device Plan On TestActive SIM | Filter TestActive → validate DP1 → change to DP2 → verify |
| TC_CDP_004 | Change Device Plan On Suspended SIM | Filter Suspended → validate DP1 → change to DP2 → verify |
| TC_CDP_005 | Verify Popup Opens | Select plan → popup appears with Reason dropdown |
| TC_CDP_006 | Close Popup Without Submitting | Cancel popup → plan unchanged |

### Negative (5)

| ID | Name | Description |
|----|------|-------------|
| TC_CDP_007 | Terminate SIM Should Be Blocked | Action not available or error toast |
| TC_CDP_008 | No Device Selected Should Not Allow Action | Dropdown disabled or error |
| TC_CDP_009 | Proceed Without Reason Should Be Blocked | Proceed button disabled |
| TC_CDP_010 | No Plan Selected Should Not Open Popup | Popup stays closed |
| TC_CDP_011 | Direct Access Without Login | Redirects to login page |

---

## 8. Automation Flow

```
Suite Setup: Login
    │
    ▼
Navigate to /ManageDevices
    │
    ▼
Open Filter Popup → Apply Account Filter (Enter key) → Apply SIM State Filter → Close Popup
    │
    ▼
Validate initial state in grid → Read IMSI + Device Plan (DP1) from grid
    │
    ▼
Select device checkbox → Select "Change Device Plan" from action dropdown
    │
    ▼
Wait for changeState section → Read plan options → Select DP2 (different from DP1)
    │
    ▼
Wait for savePopup → Select Reason (only Reason rendered) → Click Proceed (id=prceedBtn)
    │
    ▼
Wait for success toast → Wait 5 minutes for async processing
    │
    ▼
Reset grid → Search by IMSI → Verify Device Plan column = DP2
```

---

## 9. Key Implementation Details

- **Suite-level session**: Browser opened once, login once, reused across all tests
- **Account filter**: Type name → press Enter → click exact match in `ul#accountFilter`
- **Popup difference**: For Change Device Plan, `showDevicePlanAndServicePlan=false` — only Reason + Comment rendered
- **Plan selection**: `name=changeSelectedValue` is a native `<select>` — use `Select From List By Index`
- **DP1 vs DP2**: First option is current plan (DP1), second option is target (DP2)
- **5-minute async wait**: State changes are asynchronous; wait before verification
- **IMSI verification**: Search by IMSI after change, check Device Plan column
- **Typos in app**: `id=prceedBtn` (not proceedBtn), `data-testid='simStatwReasonsd'`
