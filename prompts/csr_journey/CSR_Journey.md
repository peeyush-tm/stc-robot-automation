# CSR Journey Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `CSR_Journey` |
| **Suite File** | `tests/csr_journey_tests.robot` |
| **Variables File** | `variables/csr_journey_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/CSRJourney` (landing/list), wizard pages (Standard Services → Additional Services → Summary) |
| **Total TCs** | 56 |
| **Tags** | `csr-journey`, `navigation`, `wizard-steps`, `tariff-plan`, `apn-type`, `apn`, `service-plan`, `bundle-plan`, `addon-plan`, `discount`, `vas`, `summary`, `breadcrumb`, `grid`, `modal`, `e2e`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite CSR_Journey
python run_tests.py tests/csr_journey_tests.robot
python run_tests.py --suite CSR_Journey --include smoke
python run_tests.py --suite CSR_Journey --include csr-journey
python run_tests.py --suite CSR_Journey --include e2e
python run_tests.py --suite CSR_Journey --test "TC_CSRJ_004*"
```

## Module Description

The **CSR Journey** (Customer Service Representative Journey) is a wizard-based order configuration flow. CSR reps select a Customer and BU, then configure:
1. **Standard Services** — Tariff Plan, APN Type, Add APNs, Device Plans (with Bundle/Service Plans), End Date
2. **Additional Services** — Addon Plans, VAS (Account VAS + Device VAS), Discounts
3. **Summary** — Review all selections before saving

Created orders appear in the CSR Journey landing page grid and can be edited, deleted, or have their Tariff Plan changed.

**Navigation:** Login → Admin sidebar → CSR Journey → select Customer → select BU → Create Order → wizard

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_CSRJ_001 | Navigate To CSR Journey Module Via Admin | Positive | smoke, regression, navigation |
| TC_CSRJ_002 | Select Customer And Verify BU Dropdown Populates | Positive | regression, customer-selection |
| TC_CSRJ_003 | Select BU And Verify Create Order Button Visible | Positive | regression, bu-selection |
| TC_CSRJ_004 | Create CSR Journey End To End Standard Flow | Positive | smoke, regression, e2e, create-order |
| TC_CSRJ_005 | Save And Continue Should Stay On Wizard | Positive | regression, save-continue |
| TC_CSRJ_006 | Verify Wizard Step Indicators Are Visible | Positive | regression, wizard-steps |
| TC_CSRJ_007 | Navigate Previous From Additional To Standard Services | Positive | regression, navigation, previous |
| TC_CSRJ_008 | Navigate Previous From Summary To Additional Services | Positive | regression, navigation, previous |
| TC_CSRJ_009 | Verify Customer And BU Info Displayed On Summary | Positive | regression, summary, validation |
| TC_CSRJ_010 | Select Tariff Plan And Verify APN Type Becomes Enabled | Positive | regression, tariff-plan, dependency |
| TC_CSRJ_011 | Verify Tariff Plan Accordion On Summary Shows Selected TP | Positive | regression, summary, tariff-plan |
| TC_CSRJ_017 | Create Order Not Visible Without BU Selection | Negative | regression, create-order, validation |
| TC_CSRJ_018 | BU Dropdown Not Interactable Without Customer Selection | Negative | regression, bu-selection, validation |
| TC_CSRJ_012 | APN Type Dropdown Disabled Without Tariff Plan | Negative | regression, apn-type, validation |
| TC_CSRJ_013 | Add APNs Button Disabled Without APN Type | Negative | regression, apn, validation |
| TC_CSRJ_014 | Close From Standard Services Should Redirect Without Saving | Negative | regression, close, standard-services |
| TC_CSRJ_015 | Close From Additional Services Should Redirect Without Saving | Negative | regression, close, additional-services |
| TC_CSRJ_016 | Close From Summary Should Redirect Without Saving | Negative | regression, close, summary |
| TC_CSRJ_019 | Select APN Type Public And Verify Add APNs Enabled | Negative | regression, apn-type, public |
| TC_CSRJ_020 | Select APN Type Any And Verify Add APNs Enabled | Negative | regression, apn-type, any |
| TC_CSRJ_021 | Close Service Plan Modal Without Saving | Negative | regression, service-plan, modal |
| TC_CSRJ_022 | Close Discount Modal Without Saving | Negative | regression, discount, modal |
| TC_CSRJ_023 | Verify CSR Summary Icon Visible In Grid | Edge Case | regression, grid, icons |
| TC_CSRJ_024 | Verify Edit Icon Visible In CSR Journey Grid | Edge Case | regression, grid, icons |
| TC_CSRJ_025 | Verify Delete Icon Visible In CSR Journey Grid | Edge Case | regression, grid, icons |
| TC_CSRJ_026 | Verify Change Tariff Plan Icon Visible In Grid | Edge Case | regression, grid, icons |
| TC_CSRJ_027 | Verify Account VAS Accordion Toggle | Edge Case | regression, vas, accordion |
| TC_CSRJ_028 | Verify Device VAS Accordion Toggle | Edge Case | regression, vas, accordion |
| TC_CSRJ_029 | Verify Breadcrumb Updates Across Wizard Steps | Edge Case | regression, breadcrumb, navigation |
| TC_CSRJ_030 | Verify APN Table Headers On Landing Page | Edge Case | regression, grid, table-headers |
| TC_CSRJ_031 | Verify Discount Accordion Toggle On Additional Services | Edge Case | regression, discount, accordion |
| TC_CSRJ_032 | Verify Summary Accordion Sections Expandable | Edge Case | regression, summary, accordion |
| TC_CSRJ_033 | Select Addon Plan And Verify Table Populates | Positive | regression, addon-plan |
| TC_CSRJ_034 | Fill And Save Service Plan Via Modal | Positive | regression, service-plan, modal |
| TC_CSRJ_035 | Fill And Save Discount On Additional Services | Positive | regression, discount, save |
| TC_CSRJ_036 | Select Bundle Plan After Fetch Device Plan | Positive | regression, bundle-plan, device-plan |
| TC_CSRJ_037 | Fill End Date On Standard Services | Positive | regression, end-date |
| TC_CSRJ_038 | Search Customer By Name In Dropdown | Positive | regression, customer-search |
| TC_CSRJ_039 | Search Tariff Plan By Name In Dropdown | Positive | regression, tariff-plan, search |
| TC_CSRJ_040 | APN Type Conflict Should Show Error | Negative | regression, apn-conflict, validation |
| TC_CSRJ_041 | Service Plan Input Disabled Until Tariff Plan Selected | Negative | regression, service-plan, validation |
| TC_CSRJ_042 | Save Account VAS Without Filling Required Fields | Negative | regression, vas, validation |
| TC_CSRJ_043 | Save Device VAS Without Filling Required Fields | Negative | regression, vas, validation |
| TC_CSRJ_044 | Save Discount Without Filling Required Fields | Negative | regression, discount, validation |
| TC_CSRJ_045 | Verify Usage Based Charges Grid On Landing Page | Edge Case | regression, grid, usage-charges |
| TC_CSRJ_046 | Verify Transaction History Grid On Landing Page | Edge Case | regression, grid, txn-history |
| TC_CSRJ_047 | Verify Order Summary Heading On Landing Page | Edge Case | regression, order-summary, landing |
| TC_CSRJ_048 | View CSR Summary Popup Via Eye Icon | Edge Case | regression, grid, popup |
| TC_CSRJ_049 | CSR Overwrite Modal In Edit Mode | Edge Case | regression, overwrite, modal |
| TC_CSRJ_050 | Navigate Full Wizard Forward And Backward | Edge Case | regression, navigation, full-cycle |
| TC_CSRJ_051 | Verify All APN Type Options Available | Edge Case | regression, apn-type, options |
| TC_CSRJ_052 | Modify CSR Journey Via Edit And Save | Positive | regression, modify, edit |
| TC_CSRJ_053 | Edit CSR Journey Update Service Types And Save | Positive | regression, modify, edit, service-types |
| TC_CSRJ_054 | Add Multiple Device Plans In Single CSR Journey | Positive | regression, multiple-device-plans, device-plan |
| TC_CSRJ_055 | Verify Multiple Device Plan Rows On Summary | Positive | regression, multiple-device-plans, summary |
| TC_CSRJ_004_Delete | Delete CSR Created In Test Case 4 | Positive | regression, delete, cleanup |

## Test Case Categories

### Positive — E2E (1 TC)
- **TC_CSRJ_004** — Full wizard: Customer → BU → Create Order → Standard Services (Tariff Plan, APN Type, Add APN, Device Plan) → Additional Services → Summary → Save.

### Positive — Navigation & Landing Page (7 TCs)
- **TC_CSRJ_001–003** — Navigate to module, verify Customer/BU dependencies and Create Order button.
- **TC_CSRJ_007–008** — Previous buttons navigate backward through wizard steps.
- **TC_CSRJ_005** — Save & Continue keeps the wizard open (does not redirect).

### Positive — Wizard Form Interactions (10 TCs)
- **TC_CSRJ_010** — Tariff Plan selected → APN Type dropdown becomes enabled.
- **TC_CSRJ_033** — Addon Plan selected → Addon table populates with plan rows.
- **TC_CSRJ_034** — Service Plan modal opens, fields filled, modal saved.
- **TC_CSRJ_035** — Discount added on Additional Services page.
- **TC_CSRJ_036** — Bundle Plan selected after Device Plan fetch.
- **TC_CSRJ_037** — End Date field filled on Standard Services.
- **TC_CSRJ_038–039** — Search filters work in Customer and Tariff Plan dropdowns.
- **TC_CSRJ_054–055** — Multiple Device Plans added in one journey; Summary shows all rows.

### Positive — Summary Validation (2 TCs)
- **TC_CSRJ_009** — Summary shows correct Customer and BU info.
- **TC_CSRJ_011** — Tariff Plan accordion on Summary shows selected plan name.

### Positive — Edit & Delete (3 TCs)
- **TC_CSRJ_052** — Edit an existing CSR Journey, modify fields, save.
- **TC_CSRJ_053** — Edit and update Service Types.
- **TC_CSRJ_004_Delete** — Delete the CSR Journey created in TC_CSRJ_004 (cleanup).

### Negative — Wizard Prerequisites (4 TCs)
- **TC_CSRJ_017** — Create Order button not visible without BU.
- **TC_CSRJ_018** — BU dropdown not interactable without Customer.
- **TC_CSRJ_012** — APN Type disabled without Tariff Plan.
- **TC_CSRJ_013** — Add APNs disabled without APN Type.

### Negative — Close / Cancel (5 TCs)
- **TC_CSRJ_014–016** — Closing the wizard from Standard Services, Additional Services, or Summary discards data.
- **TC_CSRJ_021** — Closing Service Plan modal without saving = no change.
- **TC_CSRJ_022** — Closing Discount modal without saving = no change.

### Negative — Validation Errors (5 TCs)
- **TC_CSRJ_040** — Conflicting APN types → validation error.
- **TC_CSRJ_041** — Service Plan input disabled before Tariff Plan selected.
- **TC_CSRJ_042–044** — Save VAS/Discount modal with missing fields → field errors shown.

### Edge Cases — Grid & UI (15 TCs)
- **TC_CSRJ_023–026** — Action icons (Summary, Edit, Delete, Change TP) visible in grid rows.
- **TC_CSRJ_027–028** — Account VAS and Device VAS accordions toggle open/close.
- **TC_CSRJ_029** — Breadcrumb updates as wizard steps change.
- **TC_CSRJ_030** — APN table headers correct on landing page.
- **TC_CSRJ_031–032** — Discount and Summary accordions expandable.
- **TC_CSRJ_045–048** — Usage Based Charges grid, Transaction History grid, Order Summary heading, and eye-icon popup visible on landing.
- **TC_CSRJ_049** — Edit mode shows CSR Overwrite confirmation modal.
- **TC_CSRJ_050–051** — Full forward/backward navigation; all APN type options available.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/csr_journey_tests.robot` | Test suite |
| `resources/keywords/csr_journey_keywords.resource` | Wizard step keywords |
| `resources/locators/csr_journey_locators.resource` | XPath locators (3-step wizard + grid) |
| `variables/csr_journey_variables.py` | Customer names, BU names, plan names, APN types |
| `prompts/csr_journey/TC_005_Create_CSR_Journey_RF 1.md` | Detailed specification |

## Automation Notes

- Wizard has 3 pages; React state tracks which page is active via URL or step indicator class.
- APN Type, Device Plan, and Service Plan fields are **cascading dependents** — each only becomes active after its parent is selected.
- Modal dialogs (Service Plan, Discount, VAS) require waiting for `k-window` to appear before interacting.
- Landing page has multiple Kendo UI grids (Orders, Usage Based Charges, Transaction History) — keyword targets the correct grid container.
- CSR Overwrite modal appears in Edit mode if a concurrent edit is detected.
