# SIM Order Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `SIM_Order` |
| **Suite File** | `tests/sim_order_tests.robot` |
| **Variables File** | `variables/sim_order_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/LiveOrder` (list), `<BASE_URL>/CreateSIMOrder` (wizard) |
| **Total TCs** | 21 |
| **Tags** | `sim_order`, `cancel`, `boundary`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite SIM_Order
python run_tests.py tests/sim_order_tests.robot
python run_tests.py --suite SIM_Order --include smoke
python run_tests.py --suite SIM_Order --include sim_order
python run_tests.py --suite SIM_Order --include cancel
python run_tests.py --suite SIM_Order --test "TC_SO_001*"
```

## Module Description

The **SIM Order** module enables users to create SIM card orders through a 3-step wizard (Account & SIM Type → Shipping Details → Preview & Submit). Orders appear in the Live Order grid. Submitted orders can also be cancelled with a reason.

**Navigation:** Login → Orders sidebar → Live Order → Create SIM Order button → `/CreateSIMOrder`

## Wizard Steps

| Step | Fields |
|------|--------|
| Step 1 | Account selection, SIM Type, Quantity |
| Step 2 | Address Line 1 (mandatory), Address Lines 2–5 (optional), City, Country |
| Step 3 | Preview (Order Summary + Shipping Summary), Terms & Conditions checkbox, Submit |

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_SO_001 | E2E Create SIM Order Successfully | Positive | smoke, regression, sim_order |
| TC_SO_002 | Verify Live Order Grid Loads After Login | Positive | smoke, regression, sim_order |
| TC_SO_003 | Verify Create SIM Order Wizard Elements Visible | Positive | smoke, regression, sim_order |
| TC_SO_004 | Verify Wizard Previous Button Navigates Back | Positive | regression, sim_order, navigation |
| TC_SO_005 | Verify Preview Page Shows Order And Shipping Summary | Positive | regression, sim_order |
| TC_SO_006 | Verify Close Button On Preview Redirects To Live Order | Positive | regression, sim_order, navigation |
| TC_SO_007 | Verify Search Functionality On Live Order Grid | Positive | regression, sim_order |
| TC_SO_008 | Cancel Order With Valid Reason And Remarks | Positive | regression, sim_order, cancel |
| TC_SO_009 | Close Cancel Modal Without Proceeding | Positive | regression, sim_order, cancel |
| TC_SO_010 | Next Blocked When Account Not Selected | Negative | regression, sim_order |
| TC_SO_011 | Next Blocked When SIM Type Not Selected | Negative | regression, sim_order |
| TC_SO_012 | Quantity Zero Should Show Error Or Block Next | Negative | regression, sim_order, boundary |
| TC_SO_013 | Quantity Negative Should Show Error Or Block Next | Negative | regression, sim_order, boundary |
| TC_SO_014 | Quantity Non Numeric Should Show Error Or Block Next | Negative | regression, sim_order, boundary |
| TC_SO_015 | Next Blocked On Step 2 When Address Line 1 Empty | Negative | regression, sim_order |
| TC_SO_016 | Submit Without Accepting Terms Should Be Blocked | Negative | regression, sim_order |
| TC_SO_017 | SQL Injection In Quantity Field | Negative | regression, security, sim_order |
| TC_SO_018 | Special Characters In Address Fields | Negative | regression, security, sim_order |
| TC_SO_019 | Cancel Order With Empty Reason Should Be Blocked | Negative | regression, sim_order, cancel |
| TC_SO_020 | Direct Access To Create SIM Order Without Login Should Redirect | Negative | regression, security, sim_order, navigation |
| TC_SO_021 | Direct Access To Live Order Without Login Should Redirect | Negative | regression, security, sim_order, navigation |

## Test Case Categories

### Positive — Happy Path (1 TC)
- **TC_SO_001** — Full 3-step wizard: select Account + SIM Type + Quantity, fill Shipping Address, check T&C, submit. Verifies order appears in Live Order grid.

### Positive — UI / Navigation (8 TCs)
- **TC_SO_002** — Live Order grid loads and shows columns after login.
- **TC_SO_003** — Create SIM Order wizard shows all fields in Step 1.
- **TC_SO_004** — Previous button on Step 2 returns to Step 1; Previous on Step 3 returns to Step 2.
- **TC_SO_005** — Step 3 Preview correctly displays Order Summary and Shipping Summary.
- **TC_SO_006** — Close button on Preview redirects to `/LiveOrder` without submitting.
- **TC_SO_007** — Search bar on Live Order grid filters rows by order number.
- **TC_SO_008** — Cancel an existing order by selecting cancel reason + remarks; verifies cancellation.
- **TC_SO_009** — Opening the cancel modal then clicking Close keeps the order unchanged.

### Negative — Step 1 Validation (4 TCs)
- **TC_SO_010** — Account not selected → Next button blocked.
- **TC_SO_011** — SIM Type not selected → Next button blocked.
- **TC_SO_012** — Quantity = 0 → error or Next blocked.
- **TC_SO_013** — Quantity = negative → error or Next blocked.
- **TC_SO_014** — Non-numeric Quantity → error or Next blocked.

### Negative — Step 2 / Step 3 Validation (2 TCs)
- **TC_SO_015** — Address Line 1 empty → Next blocked on Step 2.
- **TC_SO_016** — Terms & Conditions unchecked → Submit blocked on Step 3.

### Negative — Security (2 TCs)
- **TC_SO_017** — SQL injection in Quantity field.
- **TC_SO_018** — Special characters in Address fields.

### Negative — Cancel Validation (1 TC)
- **TC_SO_019** — Cancel order with empty Reason field → Cancel button disabled.

### Negative — Auth / Navigation (2 TCs)
- **TC_SO_020** — Direct `/CreateSIMOrder` without session → login redirect.
- **TC_SO_021** — Direct `/LiveOrder` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/sim_order_tests.robot` | Test suite |
| `resources/keywords/sim_order_keywords.resource` | Order wizard and grid keywords |
| `resources/locators/sim_order_locators.resource` | XPath locators |
| `variables/sim_order_variables.py` | Account names, SIM types, quantities, addresses |
| `prompts/sim_order/TC_003_Create_SIM_Order_RF.md` | Detailed specification |
| `prompts/sim_order/SIM_Order_XPaths.txt` | Full XPath reference |

## Automation Notes

- The wizard is a multi-step form; each `Next` click triggers a loading overlay which must be waited on.
- The `Cancel Order` flow opens a modal dialog requiring a cancellation reason before confirming.
- Order IDs are captured from the Live Order grid for use in downstream validation.
- The Live Order grid is a Kendo UI component; row filtering uses the grid's search input.
