# SIM Movement Module

## Overview
The SIM Movement module tests moving SIMs between Business Unit (BU) accounts within the same Enterprise Customer (EC). It covers capacity checks, state-aware movement, and batch job verification.

## CMP Pages
- **Manage Devices:** `/ManageDevices` — SIM listing, action dropdown (value `14` = SIM Movement)
- **Manage Account:** `/ManageAccount` — Account capacity management (Max IMSI)
- **Batch Job Log:** `/BatchJobLog` — Verify movement operations

## Test Suite
- **File:** `tests/sim_movement_tests.robot`
- **Keywords:** `resources/keywords/sim_movement_keywords.resource`
- **Locators:** `resources/locators/sim_movement_locators.resource`
- **Variables:** `variables/sim_movement_variables.py`
- **Total Test Cases:** 6

## Prerequisites
- Requires E2E flow with usage to have completed first (provides EC/BU accounts and activated SIMs)
- Or standalone variables configured via environment variables (`STC_SM_*`)
- Uses `.run_seed.json` for cross-suite variable sharing

## Test Cases

### Positive
| TC ID | Name | Tags |
|-------|------|------|
| TC_SM_002 | Capture SIM Row Count And Ensure EC IMSI Capacity | regression, positive, account |
| TC_SM_003 | Ensure Target BU Max SIM Capacity | regression, positive, business-unit |
| TC_SM_005 | Perform State-Aware SIM Movement To Target BU | smoke, regression, positive |
| TC_SM_009 | Verify SIM Movement In Batch Job Log By Request Id | regression, positive, batch-job |

### Negative
| TC ID | Name | Tags |
|-------|------|------|
| TC_SM_012 | SIM Movement Without Selecting Any SIM Should Not Allow Action | regression, negative |
| TC_SM_013 | Close SIM Movement Modal Without Proceeding Should Not Move SIM | regression, negative |

## Key Variables
- `SM_EC_ACCOUNT_NAME` — EC account (from seed or env var)
- `SM_SOURCE_BU_ACCOUNT` — Source BU account
- `SM_TARGET_BU_ACCOUNT` — Target BU account for movement
- `SM_ICCID_TO_MOVE` / `SM_IMSI_TO_MOVE` — SIM identifiers
- `SM_BATCH_REQUEST_ID` — Captured from header bell notification
- `SM_ACTION_VALUE` — `14` (SIM Movement action)

## Run Commands
```bash
python run_tests.py tests/sim_movement_tests.robot --env qe
python run_tests.py tests/sim_movement_tests.robot --env qe --include smoke
```
