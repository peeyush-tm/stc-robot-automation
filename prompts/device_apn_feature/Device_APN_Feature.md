# Device APN Feature Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Device_APN_Feature` |
| **Suite File** | `tests/device_apn_feature_tests.robot` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageDevices` → Device Detail → APN tab |
| **Total TCs** | 35 |
| **Tags** | `feature`, `regression`, `device-apn` |

## Run Commands

```bash
python run_tests.py --suite Device_APN_Feature
python run_tests.py tests/device_apn_feature_tests.robot
python run_tests.py tests/device_apn_feature_tests.robot --test "TC_DAPN_00*"
```

## Module Description

Exercises the **APN tab** on the Device Detail page: tab access, field display, IPv6 address rendering, APN assignment view, persistence across tab switches, and validation.

**Navigation:** Login → Manage Devices → click a device row → Device Detail page → APN tab.

## Test Group Layout

| Group | TCs | Focus |
|-------|-----|-------|
| A — APN Tab Access & Header | TC_DAPN_001 – 003 | Tab opens without error, header fields shown, tab state retained |
| B — APN List / Assignment | | APN table rows, assigned APNs per device |
| C — IPv6 & Static IP | | Static IPv6 display, masking, edit controls |
| D — Navigation / State | | Back from APN tab, reload, cross-tab consistency |
| E — Validation | | Invalid APN, unauthorized role, disabled state |

## Default Test Data (in suite)

```
DEVICE_ICCID      8992431100167856978
DEVICE_IMSI       420023067856978
DEVICE_MSISDN     96650100382
DEVICE_BU         IPV6_BU_MJ35_BU2
DEVICE_STATE      Activated
PRIVATE_APN       IPV6_APN_PvtSta
EXPECTED_IPV6     abcd:1200:1200:1201:0:0:0:1
```

Override via `--variable DEVICE_ICCID:<value>` etc. if the default device is not available in your environment.

## Prerequisites

- Valid OpCo login
- A device matching `DEVICE_ICCID` in Activated state with a Private APN assigned (or override via --variable)

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/device_apn_feature_tests.robot` | 35 test cases |
| `resources/keywords/device_apn_view_keywords.resource` | APN tab interactions |
| `resources/keywords/manage_devices_keywords.resource` | Grid navigation (shared) |
| `resources/keywords/apn_keywords.resource` | APN create/edit keywords (shared) |
| `resources/locators/apn_locators.resource` | Locators |
| `variables/apn_variables.py` | APN test data |

## Related Modules

- `prompts/apn/APN.md` — APN create/edit/delete admin suite
- `prompts/manage_devices_feature/Manage_Devices_Feature.md` — full grid feature suite
