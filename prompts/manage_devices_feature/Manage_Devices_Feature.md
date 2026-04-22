# Manage Devices Feature Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Manage_Devices_Feature` |
| **Suite File** | `tests/manage_devices_feature_tests.robot` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageDevices` |
| **Total TCs** | 43 |
| **Tags** | `feature`, `regression`, `manage-devices`, group-specific tags |

## Run Commands

```bash
python run_tests.py --suite Manage_Devices_Feature
python run_tests.py tests/manage_devices_feature_tests.robot
python run_tests.py tests/manage_devices_feature_tests.robot --test "TC_MD_00*"
```

## Module Description

Deep UI coverage for the **Manage Devices** grid: columns, pagination, filters, bulk actions, SIM-state indicators, search, and action-bar availability by selection.

**Navigation:** Login → Devices → Manage Devices tab.

## Test Group Layout

| Group | TCs | Focus |
|-------|-----|-------|
| A — Page Load / Display | TC_MD_001 – … | Grid loads, columns present, rows populated, pagination |
| B — Column Behaviour | | SIM STATE colour coding, sorting, filtering |
| C — Search & Filter | | Search by ICCID/IMSI/MSISDN, state filter, account filter |
| D — Action Bar | | Button enabled/disabled by selection + state |
| E — Bulk Actions | | Multi-select and bulk state change / assign |
| F — Pagination | | Page size, navigation buttons, end-of-list |

## Expected Columns

REF ID, LABEL, ICCID, IMSI, MSISDN, BUSINESS UNIT NAME, COST CENTER NAME, SIM STATE, VIN DETAILS, IMEI

## Prerequisites

- Valid OpCo login credentials
- Environment with at least some devices in the grid (ideally multiple states for colour-code tests)

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/manage_devices_feature_tests.robot` | 43 test cases |
| `resources/keywords/manage_devices_keywords.resource` | Grid interaction keywords |
| `resources/keywords/device_state_keywords.resource` | State-change keywords (shared) |
| `resources/locators/device_state_locators.resource` | Locators |

## Related Modules

- `prompts/device_state/TC_002_Device_State_Change_RF.md` — core state-change suite
- `prompts/device_plan/Device_Plan.md` — plan changes from the same grid
