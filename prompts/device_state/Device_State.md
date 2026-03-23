# Device State Change Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Device_State` |
| **Suite File** | `tests/device_state_tests.robot` |
| **Variables File** | `variables/device_state_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageDevices` |
| **Total TCs** | 16 |
| **Tags** | `device_state`, `testactive`, `activated`, `suspended`, `inactive`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite Device_State
python run_tests.py tests/device_state_tests.robot
python run_tests.py --suite Device_State --include smoke
python run_tests.py --suite Device_State --include device_state
python run_tests.py --suite Device_State --include activated
python run_tests.py --suite Device_State --test "TC_DSC_002*"
```

## Module Description

The **Device State Change** module manages SIM lifecycle transitions from the Manage Devices grid. Users select one or more SIMs, click the State Change action button, choose a target state, select a reason, and confirm. Not all state transitions are allowed — the application enforces a valid state machine.

**Navigation:** Login → Manage Devices grid → select SIM row(s) → State Change button → popup → choose state + reason → Submit

## Valid State Transitions

| From State | Allowed Transitions |
|-----------|-------------------|
| InActive | TestActive, Activated |
| TestActive | Activated, Suspended |
| Activated | Suspended, Terminate |
| Suspended | Terminate |

## Blocked Transitions (enforced by UI)
- Activated → TestActive ❌
- Activated → TestReady ❌
- Suspended → TestActive ❌

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_DSC_001 | Verify Manage Devices Grid And Action Bar | Positive | smoke, regression, device_state |
| TC_DSC_002 | TestActive To Activated | Positive | smoke, regression, device_state, testactive |
| TC_DSC_003 | TestActive To Suspended | Positive | regression, device_state, testactive |
| TC_DSC_004 | Activated To Suspended | Positive | regression, device_state, activated |
| TC_DSC_005 | Activated To Terminate | Positive | regression, device_state, activated |
| TC_DSC_006 | Suspended To Terminate | Positive | regression, device_state, suspended |
| TC_DSC_007 | InActive To Activated | Positive | regression, device_state, inactive |
| TC_DSC_008 | InActive To TestActive | Positive | regression, device_state, inactive |
| TC_DSC_009 | Verify State Change Popup Opens | Positive | regression, device_state |
| TC_DSC_010 | Close Popup Without Submitting Should Not Change State | Positive | regression, device_state |
| TC_DSC_011 | Activated To TestActive Should Be Blocked | Negative | regression, device_state, activated |
| TC_DSC_012 | Activated To TestReady Should Be Blocked | Negative | regression, device_state, activated |
| TC_DSC_013 | Suspended To TestActive Should Be Blocked | Negative | regression, device_state, suspended |
| TC_DSC_014 | No Device Selected Should Not Allow Action | Negative | regression, device_state |
| TC_DSC_015 | Proceed Without Selecting Reason Should Be Blocked | Negative | regression, device_state |
| TC_DSC_016 | Direct Access To ManageDevices Without Login | Negative | regression, security, device_state, navigation |

## Test Case Categories

### Positive — UI Verification (2 TCs)
- **TC_DSC_001** — Manage Devices grid loads with data; action bar buttons (State Change, Change Plan, etc.) are visible.
- **TC_DSC_009** — Selecting a SIM and clicking State Change opens the state transition popup.
- **TC_DSC_010** — Closing the popup without submitting leaves the SIM state unchanged.

### Positive — State Transitions (7 TCs)
- **TC_DSC_002** — TestActive → Activated: selects SIM in TestActive, changes to Activated, verifies updated state in grid.
- **TC_DSC_003** — TestActive → Suspended.
- **TC_DSC_004** — Activated → Suspended.
- **TC_DSC_005** — Activated → Terminate.
- **TC_DSC_006** — Suspended → Terminate.
- **TC_DSC_007** — InActive → Activated.
- **TC_DSC_008** — InActive → TestActive.

### Negative — Blocked Transitions (3 TCs)
- **TC_DSC_011** — Activated → TestActive: option should not appear or button should be disabled.
- **TC_DSC_012** — Activated → TestReady: option should not appear or button should be disabled.
- **TC_DSC_013** — Suspended → TestActive: option should not appear or button should be disabled.

### Negative — Precondition Validation (2 TCs)
- **TC_DSC_014** — No device checkbox selected → State Change button is disabled / not clickable.
- **TC_DSC_015** — State change popup open, no Reason selected → Proceed button disabled.

### Negative — Auth (1 TC)
- **TC_DSC_016** — Direct `/ManageDevices` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/device_state_tests.robot` | Test suite |
| `resources/keywords/device_state_keywords.resource` | State change popup keywords |
| `resources/locators/device_state_locators.resource` | XPath locators (grid + popup) |
| `variables/device_state_variables.py` | ICCID/IMSI identifiers for SIMs in known states |
| `prompts/device_state/TC_002_Device_State_Change_RF.md` | Detailed specification |

## Automation Notes

- SIM states are **pre-seeded** in the test database. Each test finds a SIM already in the required source state.
- State change popup uses radio buttons for state selection and a dropdown for Reason.
- After submission, grid row must be re-queried to verify the updated state column value.
- Blocked transition options: the UI may hide the option from the radio list or show it as disabled — keywords verify the appropriate outcome.
- The Manage Devices grid is a Kendo UI component; filtering by ICCID/IMSI is performed via the grid search/filter before selecting the row.
