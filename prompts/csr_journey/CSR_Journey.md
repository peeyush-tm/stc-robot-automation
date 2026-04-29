# CSR Journey Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `CSR_Journey` |
| **Suite File** | `tests/csr_journey_tests.robot` |
| **Variables File** | `variables/csr_journey_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/CSRJourney` (landing/list), wizard pages (Standard Services → Additional Services → Summary) |
| **Total TCs** | 12 |
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
| TC_CSRJ_004 | Create CSR Journey End To End Standard Flow | Positive | smoke, regression, e2e, create-order |
| TC_CSRJ_040 | APN Type Conflict Should Show Error | Negative | regression, apn-conflict, validation |
| TC_CSRJ_052 | Modify CSR Journey Via Edit And Save | Positive | regression, modify, edit |
| TC_CSRJ_053 | Edit CSR Journey Update Service Types And Save | Positive | regression, modify, edit, service-types |
| TC_CSRJ_054 | Add Multiple Device Plans In Single CSR Journey | Positive | regression, multiple-device-plans, device-plan |
| TC_CSRJ_055 | Verify Multiple Device Plan Rows On Summary | Positive | regression, multiple-device-plans, summary |
| TC_CSRJ_056 | E2E Landing Grids And Customer Search | Positive | regression, e2e, grid |
| TC_CSRJ_057 | E2E Tariff Plan Search In Wizard | Positive | regression, e2e, tariff-plan |
| TC_CSRJ_058 | E2E Close From Each Wizard Step | Negative | regression, e2e, close |
| TC_CSRJ_059 | E2E Post Create Grid Popup And Overwrite | Positive | regression, e2e, grid, popup |
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
