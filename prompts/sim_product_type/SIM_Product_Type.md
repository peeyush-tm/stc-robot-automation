# SIM Product Type Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `SIM_Product_Type` |
| **Suite File** | `tests/product_type_tests.robot` |
| **Variables File** | `variables/product_type_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/SIMProductType` (list), `<BASE_URL>/CreateSIMProductType` (create) |
| **Total TCs** | 18 |
| **Tags** | `product-type`, `create-product-type`, `assign-ec`, `boundary`, `search`, `validation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite SIM_Product_Type
python run_tests.py tests/product_type_tests.robot
python run_tests.py --suite SIM_Product_Type --include smoke
python run_tests.py --suite SIM_Product_Type --include product-type
python run_tests.py --suite SIM_Product_Type --include assign-ec
python run_tests.py --suite SIM_Product_Type --test "TC_PT_001*"
```

## Module Description

The **SIM Product Type** module defines how SIM cards are categorised by Service Type and sub-types. After creating a Product Type, it can be **assigned to Enterprise Customers (EC)**. The create form requires Account, Product Type Name, and Service Type selection. Sub-types (2, 3, 4) become visible based on the Service Type selected. If eSIM is selected with Sub Type 3, a Profile Name is also required.

**Navigation:** Login → Admin sidebar → SIM Product Type → `/SIMProductType`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_PT_001 | Create SIM Product Type Standard Flow | Positive | smoke, regression, product-type, create-product-type |
| TC_PT_002 | Assign EC To Existing Product Type | Positive | smoke, regression, product-type, assign-ec |
| TC_PT_011 | Verify Create Button Visible For RW User | Positive | regression, product-type |
| TC_PT_13 | Close Assign Popup Without Saving Should Not Change Assignment | Positive | regression, assign-ec |
| TC_PT_003 | Submit Without Selecting Account | Negative | regression, product-type, create-product-type |
| TC_PT_004 | Submit With Blank Product Type Name | Negative | regression, product-type, create-product-type |
| TC_PT_005 | Submit Without Selecting Service Type | Negative | regression, product-type, create-product-type |
| TC_PT_006 | Submit With Blank Service Sub Type 2 | Negative | regression, product-type, create-product-type |
| TC_PT_007 | Submit With Blank Service Sub Type 3 | Negative | regression, product-type, create-product-type |
| TC_PT_008 | Submit With Blank Service Sub Type 4 | Negative | regression, product-type, create-product-type |
| TC_PT_009 | Submit With Esim Sub Type 3 But Blank Profile Name | Negative | regression, product-type, create-product-type |
| TC_PT_010 | Close Create Form Without Submitting | Negative | regression, product-type, create-product-type |
| TC_PT_012 | Click Update Without Selecting Any EC | Negative | regression, product-type, assign-ec |
| TC_PT_17 | Duplicate Product Type Name Should Show Error Toast | Negative | regression, create, validation |
| TC_PT_14 | Edit Icon Should Be Visible In Product Type Grid | Edge Case | regression, validation |
| TC_PT_15 | Assign Customer Icon Should Be Visible In Grid For RW User | Edge Case | regression, assign-ec, validation |
| TC_PT_16 | Search Product Type In Listing Grid | Edge Case | regression, search |
| TC_PT_18 | Clear Search Should Reset Grid | Edge Case | regression, search |

## Test Case Categories

### Positive — Happy Path (2 TCs)
- **TC_PT_001** — Full create flow: select Account, enter Product Type Name, select Service Type (and sub-types), submit. Verifies success and appearance in grid.
- **TC_PT_002** — Assign an EC to an existing Product Type: click Assign Customer icon in grid, select EC, click Update. Verifies assignment saved.

### Positive — UI Verification (2 TCs)
- **TC_PT_011** — Create button is visible for users with Read-Write permission.
- **TC_PT_13** — Closing the Assign EC popup without clicking Update does not change the assignment.

### Negative — Mandatory Field Validation (7 TCs)
- **TC_PT_003** — Account not selected → submit blocked.
- **TC_PT_004** — Product Type Name blank → submit blocked / error.
- **TC_PT_005** — Service Type not selected → submit blocked.
- **TC_PT_006** — Service Sub Type 2 blank (when required) → error.
- **TC_PT_007** — Service Sub Type 3 blank (when required) → error.
- **TC_PT_008** — Service Sub Type 4 blank (when required) → error.
- **TC_PT_009** — eSIM selected for Sub Type 3 but Profile Name blank → error.

### Negative — Form / Business Rules (3 TCs)
- **TC_PT_010** — Close the Create form without submitting; product type not created.
- **TC_PT_012** — Click Update in Assign EC popup without selecting any EC → error or button disabled.
- **TC_PT_17** — Duplicate Product Type Name → error toast.

### Edge Cases (4 TCs)
- **TC_PT_14** — Edit icon is visible in each grid row.
- **TC_PT_15** — Assign Customer icon is visible in grid rows for RW users.
- **TC_PT_16** — Search by Product Type Name in listing grid; matching rows shown.
- **TC_PT_18** — Clearing search input resets grid to full listing.

## Service Type / Sub-Type Dependency

| Service Type | Sub Type 2 Required | Sub Type 3 Required | Sub Type 4 Required | Profile Name |
|-------------|--------------------|--------------------|--------------------|----|
| Standard | ✅ | Optional | Optional | — |
| eSIM | ✅ | ✅ | Optional | Required if Sub Type 3 = eSIM |
| Others | ✅ | Optional | Optional | — |

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/product_type_tests.robot` | Test suite |
| `resources/keywords/product_type_keywords.resource` | Create and Assign EC keywords |
| `resources/locators/product_type_locators.resource` | XPath locators |
| `variables/product_type_variables.py` | Product type names, service types, sub-types, EC names |
| `prompts/sim_product_type/TC_006_Create_SIM_Product_Type RF 1.md` | Detailed specification |

## Automation Notes

- Product Type Name is randomly generated per run to avoid duplicate conflicts.
- Service Sub-Types are conditional — keywords check whether sub-type fields are visible before interacting.
- The Assign EC popup is a modal (Kendo Window); keywords wait for it to appear before selecting ECs.
- Search in listing uses the grid's search input (Kendo Grid filter row).
