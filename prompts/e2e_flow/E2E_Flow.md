# E2E Flow Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `E2E_Flow` |
| **Suite File** | `tests/e2e_flow.robot` |
| **Variables File** | `variables/order_processing_variables.py` |
| **Type** | E2E (UI + API + SSH) |
| **Total TCs** | 21 |
| **Tags** | `e2e`, `api`, `onboard`, `apn`, `csr-journey`, `sim-range`, `product-type`, `sim-order`, `order-processing`, `manage-devices`, `device-state-change`, `invoice`, `billing`, `capture`, `database`, `ssh`, `soap`, `validation` |

## Run Commands

```bash
python run_tests.py --suite E2E_Flow
python run_tests.py tests/e2e_flow.robot
python run_tests.py --suite E2E_Flow --env staging
python run_tests.py --suite E2E_Flow --test "TC_E2E_001*"
```

## Flow Description

The **E2E Flow** suite validates the complete SIM lifecycle from customer onboarding to SIM activation and invoice generation. It combines SOAP API calls, UI interactions, SSH commands, database queries, and file generation/upload into a single ordered flow.

Each test case runs in sequence. They share state via suite-level variables (order ID, account IDs, ICCID/IMSI lists).

## Flow Steps

| TC ID | Name | Type |
|-------|------|------|
| TC_E2E_001 | Onboard EC And BU Account Via API | API (SOAP) |
| TC_E2E_002 | Verify Onboarded Account On UI | UI |
| TC_E2E_003 | Create APN For Onboarded Account | UI |
| TC_E2E_004 | Create CSR Journey For Onboarded Account | UI |
| TC_E2E_005 | Create SIM Range With 10 ICCID IMSI | UI |
| TC_E2E_006 | Create And Assign SIM Product Type | UI |
| TC_E2E_007 | Expand EC And BU SIM Limits | UI |
| TC_E2E_008 | Create SIM Order | UI |
| TC_E2E_009 | Capture Order ID From Live Order Grid | UI |
| TC_E2E_010 | Fetch EC And BU Account IDs From Database | DB (MySQL) |
| TC_E2E_011 | Run Create Order Script On Server | SSH |
| TC_E2E_012 | Validate Order Status New To In Progress | UI |
| TC_E2E_013 | Generate And Upload Response Files To Server | SSH/File |
| TC_E2E_014 | Run Read Order Script On Server | SSH |
| TC_E2E_015 | Validate Order Status In Progress To Completed | UI |
| TC_E2E_016 | Validate SIMs In Warm State On Manage Devices | UI |
| TC_E2E_017 | Update Order Status To Approved Via SOAP API | API (SOAP) |
| TC_E2E_018 | Activate 5 SIMs And Capture IMSIs | UI |
| TC_E2E_019 | Generate Invoice And Download CSV | UI |
| TC_E2E_020 | Create Second CSR Journey With Different Plan | UI |
| TC_E2E_021 | Perform Device Plan Change On One Activated SIM And Validate | UI |

## Step Details

### TC_E2E_001 — Onboard EC And BU Account Via API
- Sends `CustomerOnboardOperation` SOAP request to create EC and Billing Account.
- Generates unique `CustomerReferenceNumber` per run.
- Stores `EC_ACCOUNT_NAME` in suite variable.

### TC_E2E_002 — Verify Onboarded Account On UI
- Logs in to the portal.
- Navigates to Manage Account and searches for the EC created in STEP_01.
- Verifies the account row is visible in the grid.

### TC_E2E_003 — Create APN For Onboarded Account
- Creates an APN linked to the EC from STEP_01.
- Uses Private APN Type with Static IPv4.

### TC_E2E_004 — Create CSR Journey For Onboarded Account
- Creates a CSR Journey for the EC → BU.
- Selects Tariff Plan, APN, Device Plan.

### TC_E2E_005 — Create SIM Range With 10 ICCID IMSI
- Creates a SIM Range pool with 10 ICCID+IMSI pairs (sequential ranges).
- Stores pool name in suite variable.

### TC_E2E_006 — Create And Assign SIM Product Type
- Creates a SIM Product Type and assigns the EC from STEP_01 to it.

### TC_E2E_008 — Create SIM Order
- Initiates a SIM order for the EC account, quantity = 5.
- Steps through the 3-step wizard and submits.

### TC_E2E_009 — Capture Order ID From Live Order Grid
- After order creation, finds the latest order row in Live Order grid.
- Captures and stores the Order ID (`ORDER_ID`) as a suite variable.

### TC_E2E_010 — Fetch EC And BU Account IDs From Database
- Connects to MySQL and queries for the EC and BU account IDs.
- Stores `EC_ID` and `BU_ID` suite variables for use in scripts.

### TC_E2E_011 — Run Create Order Script On Server
- SSH to the app server.
- Executes the `create_order.sh` script passing `ORDER_ID`, `EC_ID`, `BU_ID`.
- Triggers the backend order processing pipeline.

### TC_E2E_012 — Validate Order Status New → In Progress
- Navigates to Live Order grid, filters by `ORDER_ID`.
- Asserts order status changes from `New` to `In Progress`.

### TC_E2E_013 — Generate And Upload Response Files To Server
- Locally generates the required response XML/CSV files for order fulfillment.
- Uploads them to the server via SFTP/SSH.

### TC_E2E_014 — Run Read Order Script On Server
- SSH to the server.
- Executes the `read_order.sh` script to process the uploaded response files.

### TC_E2E_015 — Validate Order Status In Progress → Completed
- Navigates to Order History grid (or Live Order), filters by `ORDER_ID`.
- Asserts order status is `Completed`.

### TC_E2E_016 — Validate SIMs In Warm State On Manage Devices
- Navigates to Manage Devices, filters by order/account.
- Verifies the 5 SIMs are in `Warm` state.

### TC_E2E_017 — Update Order Status To Approved Via SOAP API
- Sends `SimOrderUpdateStatus` SOAP request with `APPROVED` status.
- Uses `ORDER_ID` captured in STEP_07.

### TC_E2E_018 — Activate 5 SIMs And Capture IMSIs
- Navigates to Manage Devices.
- Selects all 5 SIMs (in Warm state).
- Changes state from Warm → Activated.
- Captures IMSI values for each activated SIM.

### TC_E2E_019 — Generate Invoice And Download CSV
- Navigates to Invoice section.
- Generates an invoice for the billing period.
- Downloads the invoice CSV and verifies it contains the expected data.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/e2e_flow.robot` | E2E test suite |
| `resources/keywords/e2e_keywords.resource` | Cross-step shared keywords |
| `variables/order_processing_variables.py` | Order configs, file paths, server SSH details |
| `templates/api/CustomerOnboardOperation.xml` | SOAP template for STEP_01 |
| `templates/api/SimOrderUpdateStatus.xml` | SOAP template for STEP_15 |
| `config/<env>.json` | `BASE_URL`, `DB_*`, `SSH_HOST`, `SSH_USER` |

## Suite Variable Flow

```
TC_E2E_001  → EC_ACCOUNT_NAME, CUSTOMER_REF_NUMBER
TC_E2E_009  → ORDER_ID
TC_E2E_010  → EC_ID, BU_ID
TC_E2E_018  → IMSI_LIST (list of activated IMSIs)
```

## Automation Notes

- Steps run **in order**; failure of an early step typically causes downstream steps to fail.
- `Set Suite Variable` is used to pass data between steps.
- SSH connections use Robot Framework's `SSHLibrary`.
- MySQL queries use `DatabaseLibrary` or custom Python keywords.
- SOAP calls use `RequestsLibrary` with XML template rendering via Python `str.format()`.
- This suite does **not** have negative test cases — it is a pure happy-path E2E validation.
