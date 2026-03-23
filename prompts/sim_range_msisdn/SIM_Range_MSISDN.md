# SIM Range MSISDN Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `SIM_Range_MSISDN` |
| **Suite File** | `tests/sim_range_msisdn_tests.robot` |
| **Variables File** | `variables/sim_range_variables.py` (shared with SIM_Range) |
| **Type** | UI |
| **URLs** | `<BASE_URL>/SIMRange?currentTab=1` (list, MSISDN tab), `<BASE_URL>/CreateSIMRange?currentTab=1` (create) |
| **Total TCs** | 26 |
| **Tags** | `sim_range`, `msisdn`, `boundary`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite SIM_Range_MSISDN
python run_tests.py tests/sim_range_msisdn_tests.robot
python run_tests.py --suite SIM_Range_MSISDN --include smoke
python run_tests.py --suite SIM_Range_MSISDN --include msisdn
python run_tests.py --suite SIM_Range_MSISDN --test "TC_SRM_001*"
```

## Module Description

The **SIM Range MSISDN** module allows administrators to create MSISDN (Mobile Subscriber ISDN) number pools. Unlike the ICCID/IMSI flow, this tab handles mobile numbers only. The form does not show the Assets Type field. Pool Count is auto-calculated from MSISDN ranges.

**Navigation:** Login → Admin sidebar → SIM Range tab → MSISDN tab → Create button → `/CreateSIMRange?currentTab=1`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_SRM_001 | Create MSISDN SIM Range Happy Path | Positive | smoke, regression, sim_range, msisdn |
| TC_SRM_002 | Verify MSISDN Tab Selection Shows Grid | Positive | smoke, regression, sim_range, msisdn |
| TC_SRM_003 | Verify Create MSISDN SIM Range Page Elements Visible | Positive | smoke, regression, sim_range, msisdn |
| TC_SRM_004 | Verify Assets Type Is Hidden For MSISDN Flow | Positive | regression, sim_range, msisdn |
| TC_SRM_005 | Verify Pool Count Auto Calculated After Adding MSISDN Range | Positive | regression, sim_range, msisdn |
| TC_SRM_006 | Verify Pool Count Is Zero Before Adding MSISDN Range | Positive | regression, sim_range, msisdn |
| TC_SRM_007 | Verify Pool Count Field Is Disabled | Positive | regression, sim_range, msisdn |
| TC_SRM_008 | Verify MSISDN Range Grid Shows Entry After Adding | Positive | regression, sim_range, msisdn |
| TC_SRM_009 | Verify Cancel Button Redirects To SIM Range List | Positive | regression, sim_range, msisdn, navigation |
| TC_SRM_010 | Verify SIM Category Selection For MSISDN | Positive | regression, sim_range, msisdn |
| TC_SRM_011 | Submit Disabled When Pool Name Empty | Negative | regression, sim_range, msisdn |
| TC_SRM_012 | Submit Disabled When Account Not Selected | Negative | regression, sim_range, msisdn |
| TC_SRM_013 | Submit Disabled When Description Empty | Negative | regression, sim_range, msisdn |
| TC_SRM_014 | Submit Disabled When No MSISDN Range Added | Negative | regression, sim_range, msisdn |
| TC_SRM_015 | MSISDN From Greater Than To Should Show Error | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_016 | MSISDN From Below 10 Digits Keeps Popup Submit Disabled | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_017 | MSISDN To Below 10 Digits Keeps Popup Submit Disabled | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_018 | Overlapping MSISDN Range Should Show Error | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_019 | MSISDN Input Exceeding 15 Digits Gets Truncated | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_020 | Close MSISDN Popup Without Submitting Clears Fields | Negative | regression, sim_range, msisdn |
| TC_SRM_021 | SQL Injection In Pool Name Should Be Rejected | Negative | regression, security, sim_range, msisdn |
| TC_SRM_022 | Special Characters In Pool Name Should Be Rejected | Negative | regression, security, sim_range, msisdn |
| TC_SRM_023 | Pool Name Exceeding Max Length Should Be Rejected | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_024 | Description Exceeding Max Length Should Be Rejected | Negative | regression, sim_range, msisdn, boundary |
| TC_SRM_025 | Direct Access To Create MSISDN SIM Range Without Login | Negative | regression, security, sim_range, msisdn, navigation |
| TC_SRM_026 | Direct Access To SIM Range MSISDN Tab Without Login | Negative | regression, security, sim_range, msisdn, navigation |

## Test Case Categories

### Positive — Happy Path (1 TC)
- **TC_SRM_001** — Full MSISDN range creation: Pool Name, Account, Description, SIM Category, add MSISDN range, submit. Verifies success.

### Positive — UI Verification (9 TCs)
- **TC_SRM_002** — Clicking MSISDN tab shows the MSISDN grid.
- **TC_SRM_003** — All form elements are visible on the Create MSISDN SIM Range page.
- **TC_SRM_004** — Assets Type field is **hidden** in MSISDN flow (only shown in ICCID/IMSI flow).
- **TC_SRM_005** — Pool Count auto-calculates after adding a MSISDN range.
- **TC_SRM_006** — Pool Count is 0 before any range is added.
- **TC_SRM_007** — Pool Count field is read-only (disabled input).
- **TC_SRM_008** — Added MSISDN range appears in the ranges grid.
- **TC_SRM_009** — Cancel returns to `/SIMRange?currentTab=1`.
- **TC_SRM_010** — SIM Category dropdown is selectable.

### Negative — Submit Disabled (4 TCs)
- **TC_SRM_011–014** — Submit disabled when Pool Name empty, Account not selected, Description empty, no MSISDN range added.

### Negative — Range Popup Validation (5 TCs)
- **TC_SRM_015** — MSISDN From > MSISDN To → error in popup.
- **TC_SRM_016** — MSISDN From < 10 digits → Popup Submit disabled.
- **TC_SRM_017** — MSISDN To < 10 digits → Popup Submit disabled.
- **TC_SRM_018** — Overlapping range with existing entry → error.
- **TC_SRM_019** — Input > 15 digits → truncated to 15 digits automatically.

### Negative — Popup / UX (1 TC)
- **TC_SRM_020** — Closing the MSISDN popup without submitting clears the entered values (no partial save).

### Negative — Security / Boundary (4 TCs)
- **TC_SRM_021** — SQL injection in Pool Name.
- **TC_SRM_022** — Special characters in Pool Name.
- **TC_SRM_023** — Pool Name > max length.
- **TC_SRM_024** — Description > max length.

### Negative — Auth / Navigation (2 TCs)
- **TC_SRM_025** — Direct `/CreateSIMRange?currentTab=1` without session → login redirect.
- **TC_SRM_026** — Direct `/SIMRange?currentTab=1` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/sim_range_msisdn_tests.robot` | Test suite |
| `resources/keywords/sim_range_keywords.resource` | Shared MSISDN keywords |
| `resources/locators/sim_range_locators.resource` | XPath locators (MSISDN tab specific) |
| `variables/sim_range_variables.py` | Shared with ICCID/IMSI; includes MSISDN range data |
| `prompts/sim_range/TC_012_Create_SIM_Range_MSISDN_RF.md` | Detailed specification |

## Automation Notes

- MSISDN numbers must be 10–15 digits. Input longer than 15 digits is auto-truncated by the application.
- The MSISDN range popup is separate from the ICCID/IMSI popup — different locators apply.
- Variables file is **shared** with the SIM_Range suite; MSISDN-specific values use separate variable names.
- Pool Count is calculated from `(MSISDN To - MSISDN From + 1)` per range entry.
