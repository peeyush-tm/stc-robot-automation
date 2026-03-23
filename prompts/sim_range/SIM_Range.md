# SIM Range (ICCID/IMSI) Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `SIM_Range` |
| **Suite File** | `tests/sim_range_tests.robot` |
| **Variables File** | `variables/sim_range_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/SIMRange` (list, ICCID/IMSI tab), `<BASE_URL>/CreateSIMRange?currentTab=0` (create) |
| **Total TCs** | 21 |
| **Tags** | `sim_range`, `boundary`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite SIM_Range
python run_tests.py tests/sim_range_tests.robot
python run_tests.py --suite SIM_Range --include smoke
python run_tests.py --suite SIM_Range --include sim_range
python run_tests.py --suite SIM_Range --test "TC_SR_001*"
```

## Module Description

The **SIM Range (ICCID/IMSI)** module allows administrators to create SIM card pools by defining ICCID and IMSI number ranges. The form requires a Pool Name, Account, Description, and at least one matching ICCID/IMSI range pair. Pool Count is auto-calculated from the defined ranges.

**Navigation:** Login → Admin sidebar → SIM Range tab → ICCID/IMSI tab → Create button → `/CreateSIMRange?currentTab=0`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_SR_001 | Create SIM Range Via ICCID IMSI Successfully | Positive | smoke, regression, sim_range |
| TC_SR_002 | Verify Create SIM Range Page Elements Visible | Positive | smoke, regression, sim_range |
| TC_SR_003 | Verify Pool Count Auto Calculated After Adding Ranges | Positive | regression, sim_range |
| TC_SR_004 | Verify Cancel Button Redirects To SIM Range List | Positive | regression, sim_range, navigation |
| TC_SR_005 | Verify ICCID IMSI Tab Selection Shows Grid | Positive | regression, sim_range |
| TC_SR_006 | Verify ICCID Range Grid Shows Entry After Adding | Positive | regression, sim_range |
| TC_SR_007 | Verify IMSI Range Grid Shows Entry After Adding | Positive | regression, sim_range |
| TC_SR_008 | Submit Button Disabled When Pool Name Empty | Negative | regression, sim_range |
| TC_SR_009 | Submit Button Disabled When Account Not Selected | Negative | regression, sim_range |
| TC_SR_010 | Submit Button Disabled When Description Empty | Negative | regression, sim_range |
| TC_SR_011 | Submit Button Disabled When No ICCID Range Added | Negative | regression, sim_range |
| TC_SR_012 | Submit Button Disabled When ICCID And IMSI Counts Mismatch | Negative | regression, sim_range |
| TC_SR_013 | ICCID From Greater Than To Should Show Error | Negative | regression, sim_range, boundary |
| TC_SR_014 | ICCID Too Short Should Keep Popup Submit Disabled | Negative | regression, sim_range, boundary |
| TC_SR_015 | IMSI From Greater Than To Should Show Error | Negative | regression, sim_range, boundary |
| TC_SR_016 | IMSI Too Short Should Keep Popup Submit Disabled | Negative | regression, sim_range, boundary |
| TC_SR_017 | SQL Injection In Pool Name Should Be Rejected | Negative | regression, security, sim_range |
| TC_SR_018 | Special Characters In Pool Name Should Be Rejected | Negative | regression, security, sim_range |
| TC_SR_019 | Pool Name Exceeding Max Length Should Be Rejected | Negative | regression, sim_range, boundary |
| TC_SR_020 | Direct Access To Create SIM Range Without Login Should Redirect | Negative | regression, security, sim_range, navigation |
| TC_SR_021 | Direct Access To SIM Range Without Login Should Redirect | Negative | regression, security, sim_range, navigation |

## Test Case Categories

### Positive — Happy Path (1 TC)
- **TC_SR_001** — Full creation flow: Pool Name, Account selection, Description, add ICCID range, add matching IMSI range, submit. Verifies success toast.

### Positive — UI Verification (6 TCs)
- **TC_SR_002** — Verifies all form elements (Pool Name, Account, Description, Add ICCID/IMSI buttons) are visible.
- **TC_SR_003** — Verifies Pool Count field auto-calculates when ICCID/IMSI ranges are added.
- **TC_SR_004** — Cancel button returns to `/SIMRange` without saving.
- **TC_SR_005** — ICCID/IMSI tab is selected by default and grid is visible.
- **TC_SR_006** — Added ICCID range appears as a row in the ICCID ranges grid.
- **TC_SR_007** — Added IMSI range appears as a row in the IMSI ranges grid.

### Negative — Submit Button Disabled (5 TCs)
- **TC_SR_008** — Pool Name empty → Submit disabled.
- **TC_SR_009** — Account not selected → Submit disabled.
- **TC_SR_010** — Description empty → Submit disabled.
- **TC_SR_011** — No ICCID range added → Submit disabled.
- **TC_SR_012** — ICCID count ≠ IMSI count → Submit disabled.

### Negative — Boundary / Range Popup Validation (4 TCs)
- **TC_SR_013** — ICCID From > ICCID To in the popup → error message shown.
- **TC_SR_014** — ICCID too short (< 19 digits) → Popup Submit button stays disabled.
- **TC_SR_015** — IMSI From > IMSI To → error message shown.
- **TC_SR_016** — IMSI too short (< 15 digits) → Popup Submit stays disabled.

### Negative — Security / Boundary (3 TCs)
- **TC_SR_017** — SQL injection in Pool Name → rejected.
- **TC_SR_018** — Special characters in Pool Name → rejected.
- **TC_SR_019** — Pool Name > max length → rejected.

### Negative — Auth / Navigation (2 TCs)
- **TC_SR_020** — Direct `/CreateSIMRange?currentTab=0` without session → login redirect.
- **TC_SR_021** — Direct `/SIMRange` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/sim_range_tests.robot` | Test suite |
| `resources/keywords/sim_range_keywords.resource` | SIM Range CRUD keywords |
| `resources/locators/sim_range_locators.resource` | XPath locators |
| `variables/sim_range_variables.py` | Pool names, ICCID/IMSI ranges (random per run) |
| `prompts/sim_range/TC_004_Create_SIM_Range_RF.md` | Detailed specification |
| `prompts/sim_range/SIM_Range_XPaths.txt` | Full XPath reference |

## Automation Notes

- Pool Name is randomly generated per run to avoid duplicate errors.
- ICCID/IMSI range popup is a modal dialog; keywords interact with it before submitting to the main form.
- ICCID ranges must be exactly 19 digits; IMSI ranges must be 15 digits — the popup validates this.
- ICCID count and IMSI count must match before the main Submit button becomes enabled.
- Pool Count field is read-only (auto-calculated from ranges).
