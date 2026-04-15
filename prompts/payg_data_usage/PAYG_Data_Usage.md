# PAYG Data Usage Module

## Overview
The PAYG Data Usage module tests the complete Pay-As-You-Go lifecycle across multiple device plan scenarios (SIM Plan, Pool Plan, Shared Plan). Each scenario runs a full E2E flow: onboard account, create APN/CSR/SIM ranges, create orders, process through server pipeline, activate SIMs, inject usage via API until PAYG quota is reached, then validate usage on UI.

## CMP Pages
- **Manage Account:** `/ManageAccount` — Verify onboarded accounts
- **Manage APN:** `/ManageAPN`, `/CreateAPN` — APN creation
- **CSR Journey:** `/CSRJourney`, `/CreateCSRJourney` — CSR journey with device plans
- **SIM Range:** `/SIMRange`, `/CreateSIMRange` — Range creation
- **Product Type:** `/ProductType`, `/CreateProductType` — Product type assignment
- **Create SIM Order:** `/CreateSIMOrder` — Order creation
- **Live Order:** `/LiveOrder` — Order tracking
- **Manage Devices:** `/ManageDevices` — SIM activation and usage verification

## Test Suite
- **File:** `tests/payg_data_usage_tests.robot`
- **Keywords:** `resources/keywords/usage_keywords.resource`, `resources/keywords/e2e_keywords.resource`
- **Variables:** `variables/payg_usage_variables.py`
- **Total Test Cases:** 40+ (across 3 scenarios)

## Scenarios

### Scenario 1 — SIM Plan (TC_PAYG_SIM_01 to TC_PAYG_SIM_20)
| TC ID | Name | Tags |
|-------|------|------|
| TC_PAYG_SIM_01 | Onboard Account | payg, sim-plan, onboard, api |
| TC_PAYG_SIM_02 | Verify Onboarded Account On UI | payg, sim-plan, validation |
| TC_PAYG_SIM_03 | Create APN | payg, sim-plan, apn |
| TC_PAYG_SIM_04 | Create CSR Journey With SIM Plan | payg, sim-plan, csr-journey |
| TC_PAYG_SIM_05 | Create SIM Range | payg, sim-plan, sim-range |
| TC_PAYG_SIM_06 | Create And Assign Product Type | payg, sim-plan, product-type |
| TC_PAYG_SIM_07 | Create SIM Order | payg, sim-plan, sim-order |
| TC_PAYG_SIM_08 | Capture Order ID | payg, sim-plan, capture |
| TC_PAYG_SIM_09 | Fetch Account IDs From Database | payg, sim-plan, database |
| TC_PAYG_SIM_10 | Run Create Order Script | payg, sim-plan, ssh |
| TC_PAYG_SIM_11 | Validate Order In Progress | payg, sim-plan, validation |
| TC_PAYG_SIM_12 | Upload Response Files | payg, sim-plan, files |
| TC_PAYG_SIM_13 | Run Read Order Script | payg, sim-plan, ssh |
| TC_PAYG_SIM_14 | Validate Order Completed | payg, sim-plan, validation |
| TC_PAYG_SIM_15 | Validate SIMs In Warm State | payg, sim-plan, manage-devices |
| TC_PAYG_SIM_16 | Approve Order Via SOAP | payg, sim-plan, api, soap |
| TC_PAYG_SIM_17 | Activate SIMs And Capture Data | payg, sim-plan, activation |
| TC_PAYG_SIM_18 | Iterative Usage Until PAYG Quota | payg, sim-plan, usage, api |
| TC_PAYG_SIM_19 | Perform PAYG Data Usage | payg, sim-plan, payg-data |
| TC_PAYG_SIM_20 | Validate PAYG Usage In UI | payg, sim-plan, validation, ui |

### Scenario 2 — Pool Plan (TC_PAYG_POOL_01 to TC_PAYG_POOL_20)
Same 20-step flow using Pool device plan (`PAYG_POOL_PLAN_DP`).

### Scenario 3 — Shared Plan (TC_PAYG_SHARED_01 to TC_PAYG_SHARED_20)
Same 20-step flow using Shared device plan (`PAYG_SHARED_PLAN_DP`).

## Key Variables
- `PAYG_TARIFF_PLAN` — Tariff plan name (from config)
- `PAYG_SIM_PLAN_DP` / `PAYG_POOL_PLAN_DP` / `PAYG_SHARED_PLAN_DP` — Device plans per scenario
- `PAYG_MAX_USAGE_ITERATIONS` — Max API calls to reach PAYG quota (default 50)
- `PAYG_EXPECTED_QUOTA_TYPE` — `payg`
- `PAYG_ORDER_QUANTITY` — `1`

## Usage API Integration
- **Base URL:** `USAGE_API_BASE_URL` from config (e.g., `http://10.223.72.208:7082/backend/st/json`)
- **Steps:** UserRequest > CDR injection > Check quotaType > Repeat until `payg`
- **Config keys:** `USAGE_OCS_TOKEN`, `USAGE_ORIGIN`, `USAGE_NETWORK`, `USAGE_RAT_TYPE`, etc.

## Run Commands
```bash
python run_tests.py tests/payg_data_usage_tests.robot --env qe
python run_tests.py tests/payg_data_usage_tests.robot --env qe --test "TC_PAYG_SIM_*"
python run_tests.py tests/payg_data_usage_tests.robot --env qe --test "TC_PAYG_POOL_*"
python run_tests.py tests/payg_data_usage_tests.robot --env qe --test "TC_PAYG_SHARED_*"
```
