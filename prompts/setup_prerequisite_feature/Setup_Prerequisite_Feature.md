# Setup Prerequisite Feature Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Setup_Prerequisite_Feature` |
| **Suite File** | `tests/setup_prerequisite_feature_tests.robot` |
| **Type** | UI (pre-flight) |
| **URLs** | Multiple: SIM Product Type, SIM Order, Manage Devices, IP Pool |
| **Total TCs** | 4 |
| **Tags** | `feature`, `regression`, `setup`, `prerequisite` |

## Run Commands

```bash
python run_tests.py --suite Setup_Prerequisite_Feature
python run_tests.py tests/setup_prerequisite_feature_tests.robot
```

## Module Description

Pre-flight / prerequisite checks that confirm the environment has the baseline data needed by other feature suites. Each TC verifies a single setup step works end-to-end from a fresh baseline.

## Test Cases

| TC ID | Test Case | What It Verifies |
|-------|-----------|-----------------|
| TC_SETUP_001 | Verify Create SIM Product Type And Assign To Customer | Admin → SIM Product Type → Create → Assign |
| TC_SETUP_002 | Verify SIM Order Created Successfully | Admin → SIM Order → Create with product type from TC_SETUP_001 |
| TC_SETUP_003 | Verify SIM State Changed From Warm To Inactive | Manage Devices → select warm SIM → change state → Inactive |
| TC_SETUP_004 | … (IP Pool / related setup check) | |

## When To Run This Suite

- Before running a long-running feature suite (e.g. Manage Devices Feature, Device APN Feature) to confirm the environment is healthy.
- After a fresh deployment or reset, to verify the admin modules still work.
- As part of smoke / sanity pipelines.

## Prerequisites

- Valid OpCo login with admin permissions
- Clean test customer (or one where creating a new product type / SIM order won't clash with existing data)

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/setup_prerequisite_feature_tests.robot` | 4 test cases |
| `resources/keywords/product_type_keywords.resource` | Product Type CRUD |
| `resources/keywords/sim_order_keywords.resource` | SIM Order create |
| `resources/keywords/device_state_keywords.resource` | State change |
| `resources/keywords/ip_pool_keywords.resource` | IP Pool (if covered) |

## Related Modules

- `prompts/sim_product_type/TC_006_Create_SIM_Product_Type_RF 1.md` — full product type suite
- `prompts/sim_order/` — full SIM Order suite
- `prompts/device_state/TC_002_Device_State_Change_RF.md` — full state change suite
