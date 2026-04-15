# SIM Replacement Module

## Overview
The SIM Replacement module tests the end-to-end flow of replacing a SIM card — from creating blank SIM ranges and orders, through the server-side order pipeline, to performing the actual replacement and verifying Notes, Blank SIM, and Lost SIM entries.

## CMP Pages
- **Manage Devices:** `/ManageDevices` — Device identity capture, replacement action
- **Blank SIMs:** `/BlankSims` — Verify new blank SIM availability and "In Use" state
- **Lost SIMs:** `/LostSims` — Verify old SIM appears after replacement
- **SIM Range:** `/SIMRange` — Create ICCID/IMSI ranges for blank SIMs
- **Create SIM Order:** `/CreateSIMOrder` — Submit blank SIM order

## Test Suite
- **File:** `tests/sim_replacement_tests.robot`
- **Keywords:** `resources/keywords/sim_replacement_keywords.resource`
- **Locators:** `resources/locators/sim_replacement_locators.resource`
- **Variables:** `variables/sim_replacement_variables.py`
- **Total Test Cases:** 8

## Test Cases

### Phase 1 — Blank Order Preparation
| TC ID | Name | Tags |
|-------|------|------|
| TC_SIMRPL_01 | SIM Replacement Blank Order Creation And Preparation | sim-replacement, smoke |

### Phase 2 — Replacement Execution & Verification
| TC ID | Name | Tags |
|-------|------|------|
| TC_SIMRPL_03 | Perform SIM Replacement And Verify | sim-replacement, smoke |
| TC_SIMRPL_04 | Verify Notes After Replacement | notes-verify, regression |
| TC_SIMRPL_05 | Verify New SIM On Blank SIM Tab | blank-sim-verify, regression |
| TC_SIMRPL_06 | Verify Old SIM On Lost SIM Module | lost-sim, regression |

### Negative
| TC ID | Name | Tags |
|-------|------|------|
| TC_SIMRPL_07 | Negative No IMSI Options Submit Disabled | sim-replacement, negative |

## Key Variables
- `SIMR_EC_ACCOUNT_NAME` / `SIMR_BU_ACCOUNT_NAME` — Test accounts
- `SIMR_MSISDN` — MSISDN used for replacement
- `SIMR_OLD_ICCID` / `SIMR_OLD_IMSI` — Original SIM identifiers
- `SIMR_NEW_ICCID` / `SIMR_NEW_IMSI` — New blank SIM identifiers
- `SIMR_PROPAGATION_WAIT_MINUTES` — Wait time for backend propagation (default 5 min)

## Run Commands
```bash
python run_tests.py tests/sim_replacement_tests.robot --env qe
python run_tests.py tests/sim_replacement_tests.robot --env qe --include smoke
```
