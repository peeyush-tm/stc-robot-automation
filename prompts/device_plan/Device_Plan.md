# Device Plan Change Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Device_Plan` |
| **Suite File** | `tests/device_plan_tests.robot` |
| **Variables File** | `variables/device_plan_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageDevices` |
| **Total TCs** | 11 |
| **Tags** | `device_plan`, `activated`, `testactive`, `suspended`, `terminate`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite Device_Plan
python run_tests.py tests/device_plan_tests.robot
python run_tests.py --suite Device_Plan --include smoke
python run_tests.py --suite Device_Plan --include device_plan
python run_tests.py --suite Device_Plan --include activated
python run_tests.py --suite Device_Plan --test "TC_CDP_002*"
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
| TC_CDP_001 | Verify Manage Devices Grid And Action Bar | Positive | smoke, regression, device_plan |
| TC_CDP_002 | Change Device Plan On Activated SIM | Positive | smoke, regression, device_plan, activated |
| TC_CDP_003 | Change Device Plan On TestActive SIM | Positive | regression, device_plan, testactive |
| TC_CDP_004 | Change Device Plan On Suspended SIM | Positive | regression, device_plan, suspended |
| TC_CDP_005 | Verify Change Device Plan Popup Opens | Positive | regression, device_plan, activated |
| TC_CDP_006 | Close Popup Without Submitting Should Not Change Plan | Positive | regression, device_plan |
| TC_CDP_007 | Change Device Plan On Terminate SIM Should Be Blocked | Negative | regression, device_plan, terminate |
| TC_CDP_008 | No Device Selected Should Not Allow Action | Negative | regression, device_plan |
| TC_CDP_009 | Proceed Without Selecting Reason Should Be Blocked | Negative | regression, device_plan |
| TC_CDP_010 | No Plan Selected Should Not Open Popup | Negative | regression, device_plan |
| TC_CDP_011 | Direct Access To ManageDevices Without Login | Negative | regression, security, device_plan, navigation |

## Test Case Categories

### Positive — UI Verification (2 TCs)
- **TC_CDP_001** — Manage Devices grid loads; Change Device Plan button is visible in the action bar.
- **TC_CDP_005** — Select an Activated SIM → Change Device Plan opens the plan selection popup.
- **TC_CDP_006** — Closing the popup without selecting a plan leaves the SIM plan unchanged.

### Positive — Plan Changes (3 TCs)
- **TC_CDP_002** — Change plan on Activated SIM: select SIM, click Change Plan, choose new plan, provide reason, submit. Verifies new plan in grid.
- **TC_CDP_003** — Same flow for TestActive SIM.
- **TC_CDP_004** — Same flow for Suspended SIM.

### Negative — Blocked Scenarios (4 TCs)
- **TC_CDP_007** — Terminated SIM selected → Change Device Plan button is disabled or shows an error when clicked.
- **TC_CDP_008** — No SIM checkbox selected → Change Device Plan button is disabled.
- **TC_CDP_009** — Popup open, Reason dropdown not selected → Proceed/Submit button is disabled.
- **TC_CDP_010** — No plan selected from the plan list → dialog/popup does not open or shows validation.

### Negative — Auth (1 TC)
- **TC_CDP_011** — Direct `/ManageDevices` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/device_plan_tests.robot` | Test suite |
| `resources/keywords/device_plan_keywords.resource` | Plan change popup keywords |
| `resources/locators/device_plan_locators.resource` | XPath locators (grid + popup) |
| `variables/device_plan_variables.py` | ICCID/IMSI identifiers for SIMs in known states, plan names |
| `prompts/device_plan/TC_014_Change_Device_Plan_RF.md` | Detailed specification |

## Automation Notes

- SIM states are **pre-seeded** in the test database. Each test selects a SIM already in the required source state.
- The Change Device Plan popup lists available plans as radio buttons or a dropdown; keyword selects by plan name.
- Reason field is a dropdown; must be selected before Submit becomes enabled.
- After plan change, the Manage Devices grid row is re-filtered to confirm the updated plan column.
- Plan changes for Terminated SIMs: the action button is disabled in the UI when a Terminated SIM is selected.
