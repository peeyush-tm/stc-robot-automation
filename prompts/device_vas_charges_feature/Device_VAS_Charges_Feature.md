# Device VAS Charges Feature Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Device_VAS_Charges_Feature` |
| **Suite File** | `tests/device_vas_charges_feature_tests.robot` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageDevices` → Device Detail → Device Level VAS Charges section |
| **Total TCs** | 6 |
| **Tags** | `feature`, `regression`, `vas` |

## Run Commands

```bash
python run_tests.py --suite Device_VAS_Charges_Feature
python run_tests.py tests/device_vas_charges_feature_tests.robot
python run_tests.py tests/device_vas_charges_feature_tests.robot --test "TC_VAS_00*"
```

## Module Description

Tests the **Edit Device Level VAS Charges** popup on the Device Detail page: pre-fills, editability, validation, save, and delete.

**Navigation:** Login → Device Detail → Device Level VAS Charges section → click edit (pencil) icon on a VAS row → popup.

## Test Cases

| TC ID | Test Case | Focus |
|-------|-----------|-------|
| TC_VAS_001 | Verify Edit Device Level VAS Charges Popup Opens | Popup renders with all fields |
| TC_VAS_002 | Verify Device Plan Dropdown Is Pre-Filled In Edit VAS Popup | Dropdown default value |
| TC_VAS_003 | Verify Amount Field Is Editable For Override | Edit + save of override amount |
| TC_VAS_004 | … (other VAS edit scenarios) | |
| TC_VAS_005 | … | |
| TC_VAS_006 | … | |

## Popup Fields

| Field | Type | Behaviour |
|-------|------|-----------|
| Device Plan | Dropdown | Pre-filled, editable |
| VAS Charge | Dropdown | Pre-filled |
| End Date | Calendar | Empty by default |
| Amount | Text (number) | Pre-filled, editable for override |

## Prerequisites

- Valid OpCo login
- Target device must already have at least one **Device Level VAS Charge** assigned (otherwise the edit icon will not be present)

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/device_vas_charges_feature_tests.robot` | 6 test cases |
| `resources/keywords/device_vas_charges_keywords.resource` | VAS popup interactions |
| `resources/keywords/device_plan_keywords.resource` | Device Plan dropdown helpers (shared) |
| `resources/locators/device_plan_locators.resource` | Locators (shared with Device Plan) |
| `variables/device_plan_variables.py` | Test data |

## Related Modules

- `prompts/device_plan/Device_Plan.md` — Device Plan change suite
