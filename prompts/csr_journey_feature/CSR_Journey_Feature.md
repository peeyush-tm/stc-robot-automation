# CSR Journey Feature Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `CSR_Journey_Feature` |
| **Suite File** | `tests/csr_journey_feature_tests.robot` |
| **Variables File** | `variables/csr_journey_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/CustomerCSRJourney`, `<BASE_URL>/CreateCSRJourney` |
| **Total TCs** | 213 |
| **Tags** | `feature`, `regression`, `csrj`, `navigation`, plus group-specific tags |

## Run Commands

```bash
python run_tests.py --suite CSR_Journey_Feature
python run_tests.py tests/csr_journey_feature_tests.robot
python run_tests.py tests/csr_journey_feature_tests.robot --include smoke
python run_tests.py tests/csr_journey_feature_tests.robot --test "TC_CSRJ_10*"
```

## Module Description

Deep UI coverage for the CSR Journey wizard (`csr_journey_tests.robot` covers end-to-end flows; this suite exercises every field, dropdown, validation, and transition in the multi-tab wizard). Complements — does not replace — the core `csr_journey_tests.robot` suite.

**Navigation:** Login → Admin → CSR Journey → Select Customer + BU → Create Order → multi-tab wizard (Tariff, APN, Bundle/Plan, Review).

## Test Group Layout

| Group | TCs | Focus |
|-------|-----|-------|
| A — Login & Navigation | TC_CSRJ_100 – 101 | Access, Customer + BU selection, Create Order |
| B — Tariff Plan | TC_CSRJ_102 – … | Tariff dropdown, validation, switching |
| C — APN Tab | | APN type, name, validation |
| D — Bundle / Device Plan | | Plan dropdown, alias, proration |
| E — Review & Save | | Summary, save, exit, grid reflection |
| Others | | Error paths, cancel, re-entry, back-forward |

Every TC follows the `TC_CSRJ_<NNN>` naming scheme (TC_CSRJ_100 – TC_CSRJ_300s range).

## Prerequisites

- Valid OpCo login credentials in `config/<env>.json`
- Test customer + BU that can host a new CSR (the Suite Setup cleans up existing CSRs first)
- CSR module accessible from Admin menu

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/csr_journey_feature_tests.robot` | Test cases (213) |
| `resources/keywords/csr_journey_keywords.resource` | Shared CSR wizard keywords |
| `resources/locators/csr_journey_locators.resource` | Page locators |
| `variables/csr_journey_variables.py` | Test data, dropdown defaults |

## Related Modules

- `prompts/csr_journey/CSR_Journey.md` — the core CSR Journey suite (end-to-end flows)
- `prompts/csr_journey/CSRJ_Testcases_Table.md` — running TC table

## Notes

- Suite Setup applies flexible Add-APN locator patching and cleans up pre-existing CSRs from the landing grid before running.
- Tests are designed to be rerun safely — each creates and tears down its CSR when needed.
