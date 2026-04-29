# APN Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `APN` |
| **Suite File** | `tests/apn_tests.robot` |
| **Variables File** | `variables/apn_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/ManageAPN` (list), `<BASE_URL>/CreateAPN` (create form) |
| **Total TCs** | 65 |
| **Tags** | `apn`, `qos`, `boundary`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite APN
python run_tests.py tests/apn_tests.robot
python run_tests.py --suite APN --env staging
python run_tests.py --suite APN --include smoke
python run_tests.py --suite APN --include apn
python run_tests.py --suite APN --test "TC_APN_001*"
```

## Module Description

The **Create APN** module allows users to create Access Point Names (APNs) with various IP configurations. The form supports IPv4 (static/dynamic), IPv6, and dual-stack configurations, along with optional secondary APN details and QoS (Quality of Service) parameters.

**Navigation:** Login → Service sidebar → APN tab → Create APN button → `/CreateAPN`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_APN_001 | Create Private APN With Static IPV4 Successfully | Positive | smoke, regression, apn |
| TC_APN_002 | Create Public APN With Dynamic IPV4 Successfully | Positive | regression, apn |
| TC_APN_003 | Create Private APN With IPV6 Successfully | Positive | regression, apn |
| TC_APN_004 | Create APN With IPV4 And IPV6 Dual Stack Successfully | Positive | regression, apn |
| TC_APN_005 | Create APN With Secondary Details | Positive | regression, apn |
| TC_APN_006 | Create APN With QoS Details | Positive | regression, apn, qos |
| TC_APN_007 | Verify Create APN Page Elements Are Visible | Positive | smoke, regression, apn |
| TC_APN_008 | Verify IP Allocation Type Appears After IP Address Type Selection | Positive | regression, apn |
| TC_APN_009 | Verify Cancel Button Redirects To Manage APN | Positive | regression, apn, navigation |
| TC_APN_010 | Submit With No Fields Filled Should Show Error | Negative | regression, apn |
| TC_APN_011 | Missing APN Name Should Show Error | Negative | regression, apn |
| TC_APN_012 | Missing APN ID Should Show Error | Negative | regression, apn |
| TC_APN_013 | Missing APN Type Should Show Error | Negative | regression, apn |
| TC_APN_014 | Missing IP Address Type Should Show Error | Negative | regression, apn |
| TC_APN_015 | Missing IP Allocation Type Should Show Error | Negative | regression, apn |
| TC_APN_016 | APN ID Exceeding 19 Digits Should Show Error | Negative | regression, apn, boundary |
| TC_APN_017 | Duplicate APN Name Should Show Error | Negative | regression, apn |
| TC_APN_018 | SQL Injection In APN Name Should Be Rejected | Negative | regression, security, apn |
| TC_APN_019 | Special Characters In APN Name Should Be Rejected | Negative | regression, security, apn |
| TC_APN_020 | HLR APN ID Exceeding 19 Digits Should Show Error | Negative | regression, apn, boundary |
| TC_APN_021 | Direct Access To Create APN Without Login Should Redirect | Negative | regression, security, apn, navigation |
| TC_APN_022 | Direct Access To Manage APN Without Login Should Redirect | Negative | regression, security, apn, navigation |
| TC_APN_023 | Verify APN List Page Loads With Correct Columns | Positive | regression, apn |
| TC_APN_024 | Verify Search Filters APN Records | Positive | regression, apn |
| TC_APN_025 | Verify Pagination Controls Navigate Correctly | Positive | regression, apn |
| TC_APN_026 | Verify CSV Export Downloads File | Positive | regression, apn |
| TC_APN_027 | Verify Column Sorting Ascending And Descending | Positive | regression, apn |
| TC_APN_028 | Verify Column Filter Applies And Clears Correctly | Positive | regression, apn |
| TC_APN_029 | Verify APN Record Can Be Deleted | Positive | regression, apn |
| TC_APN_030 | Verify Edit Icon Opens Pre-populated APN Form | Positive | regression, apn |
| TC_APN_031 | Verify Create APN Button Navigates To Create Form | Positive | regression, apn |
| TC_APN_032 | Verify APN Type Public Dropdown Options | Positive | regression, apn |
| TC_APN_033 | Verify APN Type Private Dropdown With Account Options | Positive | regression, apn |
| TC_APN_034 | Verify All IP Address Type Options Are Selectable | Positive | regression, apn |
| TC_APN_035 | Verify All APN Service Type Options Are Selectable | Positive | regression, apn |
| TC_APN_036 | Verify Roaming Toggle Can Be Enabled And Disabled | Positive | regression, apn |
| TC_APN_037 | Verify Secondary Details Section Expands With Fields | Positive | regression, apn |
| TC_APN_038 | Verify Quality Of Service Section Expands With Fields | Positive | regression, apn |
| TC_APN_039 | Duplicate APN ID Should Show Error | Negative | regression, apn |
| TC_APN_040 | APN ID With Non-Numeric Characters Should Be Rejected | Negative | regression, apn |
| TC_APN_041 | Verify Auto Created APNs Visible In APN List | Positive | regression, apn |
| TC_APN_042 | Verify IP Allocation Static Shows Subnet Mask Section | Positive | regression, apn |
| TC_APN_043 | Verify Dynamic IP Allocation Hides Subnet Section | Positive | regression, apn |
| TC_APN_044 | Verify Subnet Mask Section Expands For Static Allocation | Positive | regression, apn |
| TC_APN_045 | Create Public APN With Static Dual Stack Subnets E2E | Positive | regression, apn |
| TC_APN_046 | Static IP Without Subnet Mask Should Show Validation Error | Negative | regression, apn |
| TC_APN_047 | Verify Subnet Section Matches Selected IP Address Type | Positive | regression, apn |
| TC_APN_048 | Verify IPV4 Subnet Mask Manual Entry And Calculate | Positive | regression, apn |
| TC_APN_049 | Verify Invalid IPV4 Address Shows Validation Error | Negative | regression, apn |
| TC_APN_050 | Verify IPV4 Prefix Dropdown Contains Valid CIDR Options | Positive | regression, apn |
| TC_APN_051 | Verify Multiple IPV4 Subnet Masks Can Be Added | Positive | regression, apn |
| TC_APN_052 | Verify Delete Icon Removes IPV4 Subnet Mask Row | Positive | regression, apn |
| TC_APN_053 | Verify CSV Upload Imports IPV4 Subnet Entries | Positive | regression, apn |
| TC_APN_054 | Verify Invalid CSV Upload Shows Error For IPV4 Subnets | Negative | regression, apn |
| TC_APN_055 | Verify IPV6 Subnet Mask Entry And Calculate | Positive | regression, apn |
| TC_APN_056 | Verify Invalid IPV6 Address Shows Validation Error | Negative | regression, apn |
| TC_APN_057 | Verify IPV6 Prefix Dropdown Contains Valid CIDR Options | Positive | regression, apn |
| TC_APN_058 | Verify Multiple IPV6 Subnet Masks Can Be Added | Positive | regression, apn |
| TC_APN_059 | Verify Delete Icon Removes IPV6 Subnet Row | Positive | regression, apn |
| TC_APN_060 | Verify CSV Upload Imports IPV6 Subnet Entries | Positive | regression, apn |
| TC_APN_061 | Verify Total Host IPV4 Count Sums Correctly | Positive | regression, apn |
| TC_APN_062 | Verify Total Host IPV6 Count Sums Correctly | Positive | regression, apn |
| TC_APN_063 | Verify Subnet Section Collapse Expand Retains Data | Positive | regression, apn |
| TC_APN_064 | Verify Change Prefix And Recalculate Updates Host Range | Positive | regression, apn |
| TC_APN_065 | Verify Edge CIDR Values For IPV4 Subnet Boundaries | Positive | regression, apn, boundary |

## Test Case Categories

### Positive — Happy Path (6 TCs)
- **TC_APN_001** — Create Private APN with Static IPv4: fills APN Name, APN ID, APN Type=Private, IP=IPv4, Allocation=Static, submits.
- **TC_APN_002** — Create Public APN with Dynamic IPv4: same flow but APN Type=Public, Allocation=Dynamic.
- **TC_APN_003** — Create Private APN with IPv6: IP Address Type=IPv6.
- **TC_APN_004** — Dual-stack: IP Address Type=IPv4 and IPv6.
- **TC_APN_005** — Create APN with Secondary Details section filled (secondary APN name, secondary APN ID).
- **TC_APN_006** — Create APN with QoS Details: fills QoS fields (Max UL/DL, Guaranteed UL/DL bitrates).

### Positive — UI Verification (3 TCs)
- **TC_APN_007** — Verifies all mandatory form fields and buttons are visible on the Create APN page.
- **TC_APN_008** — Verifies IP Allocation Type dropdown appears only after IP Address Type is selected (conditional field).
- **TC_APN_009** — Cancel button navigates back to `/ManageAPN` without saving.

### Negative — Mandatory Field Validation (6 TCs)
- **TC_APN_010** — Submit empty form; all mandatory field errors shown.
- **TC_APN_011–015** — Each test submits with exactly one mandatory field missing (APN Name, APN ID, APN Type, IP Address Type, IP Allocation Type).

### Negative — Boundary / Business Rules (3 TCs)
- **TC_APN_016** — APN ID > 19 digits triggers max-length error.
- **TC_APN_017** — Duplicate APN name (same as existing record) triggers conflict error.
- **TC_APN_020** — HLR APN ID > 19 digits triggers max-length error.

### Negative — Security (2 TCs)
- **TC_APN_018** — SQL injection string in APN Name is rejected.
- **TC_APN_019** — Special characters in APN Name are rejected.

### Negative — Navigation / Auth (2 TCs)
- **TC_APN_021** — Direct URL access to `/CreateAPN` without session → redirected to login.
- **TC_APN_022** — Direct URL access to `/ManageAPN` without session → redirected to login.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/apn_tests.robot` | Test suite |
| `resources/keywords/apn_keywords.resource` | APN CRUD keywords |
| `resources/locators/apn_locators.resource` | XPath locators |
| `variables/apn_variables.py` | APN names, IDs, IP values (random per run) |
| `prompts/apn/TC_007_Create_APN_RF.md` | Detailed specification with locator tables |
| `prompts/apn/APN_XPaths.txt` | Full XPath reference for the APN pages |

## Automation Notes

- APN names are **randomly generated** each run (timestamp-based) to avoid duplicate conflicts.
- IP Allocation Type is a **dependent dropdown** — it only appears after IP Address Type is selected; keyword waits for it to become visible before interacting.
- QoS section is a collapsible accordion; keyword expands it before filling values.
- Loading overlay (`body.loading-indicator`) is waited on after every form submit and navigation.
