# E2E Flow Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `E2E_Flow` |
| **Suite File** | `tests/e2e_flow.robot` |
| **Variables File** | `variables/order_processing_variables.py` |
| **Type** | E2E (UI + API + SSH) |
| **Total Steps** | 17 |
| **Tags** | `e2e`, `api`, `onboard`, `apn`, `csr-journey`, `sim-range`, `product-type`, `sim-order`, `order-processing`, `manage-devices`, `device-state-change`, `invoice`, `billing`, `capture`, `database`, `ssh`, `soap`, `validation` |

## Run Commands

```bash
python run_tests.py --suite E2E_Flow
python run_tests.py tests/e2e_flow.robot
python run_tests.py --suite E2E_Flow --env staging
python run_tests.py --suite E2E_Flow --test "STEP_01*"
```

## Flow Description

The **E2E Flow** suite validates the complete SIM lifecycle from customer onboarding to SIM activation and invoice generation. It combines SOAP API calls, UI interactions, SSH commands, database queries, and file generation/upload into a single ordered flow.

Each step is a separate Robot Framework test case (prefixed `STEP_NN`) that runs in sequence. Steps share state via suite-level variables (order ID, account IDs, ICCID/IMSI lists).

## Flow Steps

| Step | Name | Type |
|------|------|------|
| STEP_01 | Onboard EC And BU Account Via API | API (SOAP) |
| STEP_01B | Verify Onboarded Account On UI | UI |
| STEP_02 | Create APN For Onboarded Account | UI |
| STEP_03 | Create CSR Journey For Onboarded Account | UI |
| STEP_04 | Create SIM Range With 10 ICCID IMSI | UI |
| STEP_05 | Create And Assign SIM Product Type | UI |
| STEP_06 | Create SIM Order | UI |
| STEP_07 | Capture Order ID From Live Order Grid | UI |
| STEP_08 | Fetch EC And BU Account IDs From Database | DB (MySQL) |
| STEP_09 | Run Create Order Script On Server | SSH |
| STEP_10 | Validate Order Status New To In Progress | UI |
| STEP_11 | Generate And Upload Response Files To Server | SSH/File |
| STEP_12 | Run Read Order Script On Server | SSH |
| STEP_13 | Validate Order Status In Progress To Completed | UI |
| STEP_14 | Validate SIMs In Warm State On Manage Devices | UI |
| STEP_15 | Update Order Status To Approved Via SOAP API | API (SOAP) |
| STEP_16 | Activate 5 SIMs And Capture IMSIs | UI |
| STEP_17 | Generate Invoice And Download CSV | UI |

## Step Details

### STEP_01 — Onboard EC And BU Account Via API
- Sends `CustomerOnboardOperation` SOAP request to create EC and Billing Account.
- Generates unique `CustomerReferenceNumber` per run.
- Stores `EC_ACCOUNT_NAME` in suite variable.

### STEP_01B — Verify Onboarded Account On UI
- Logs in to the portal.
- Navigates to Manage Account and searches for the EC created in STEP_01.
- Verifies the account row is visible in the grid.

### STEP_02 — Create APN For Onboarded Account
- Creates an APN linked to the EC from STEP_01.
- Uses Private APN Type with Static IPv4.

### STEP_03 — Create CSR Journey For Onboarded Account
- Creates a CSR Journey for the EC → BU.
- Selects Tariff Plan, APN, Device Plan.

### STEP_04 — Create SIM Range With 10 ICCID IMSI
- Creates a SIM Range pool with 10 ICCID+IMSI pairs (sequential ranges).
- Stores pool name in suite variable.

### STEP_05 — Create And Assign SIM Product Type
- Creates a SIM Product Type and assigns the EC from STEP_01 to it.

### STEP_06 — Create SIM Order
- Initiates a SIM order for the EC account, quantity = 5.
- Steps through the 3-step wizard and submits.

### STEP_07 — Capture Order ID From Live Order Grid
- After order creation, finds the latest order row in Live Order grid.
- Captures and stores the Order ID (`ORDER_ID`) as a suite variable.

### STEP_08 — Fetch EC And BU Account IDs From Database
- Connects to MySQL and queries for the EC and BU account IDs.
- Stores `EC_ID` and `BU_ID` suite variables for use in scripts.

### STEP_09 — Run Create Order Script On Server
- SSH to the app server.
- Executes the `create_order.sh` script passing `ORDER_ID`, `EC_ID`, `BU_ID`.
- Triggers the backend order processing pipeline.

### STEP_10 — Validate Order Status New → In Progress
- Navigates to Live Order grid, filters by `ORDER_ID`.
- Asserts order status changes from `New` to `In Progress`.

### STEP_11 — Generate And Upload Response Files To Server
- Locally generates the required response XML/CSV files for order fulfillment.
- Uploads them to the server via SFTP/SSH.

### STEP_12 — Run Read Order Script On Server
- SSH to the server.
- Executes the `read_order.sh` script to process the uploaded response files.

### STEP_13 — Validate Order Status In Progress → Completed
- Navigates to Order History grid (or Live Order), filters by `ORDER_ID`.
- Asserts order status is `Completed`.

### STEP_14 — Validate SIMs In Warm State On Manage Devices
- Navigates to Manage Devices, filters by order/account.
- Verifies the 5 SIMs are in `Warm` state.

### STEP_15 — Update Order Status To Approved Via SOAP API
- Sends `SimOrderUpdateStatus` SOAP request with `APPROVED` status.
- Uses `ORDER_ID` captured in STEP_07.

### STEP_16 — Activate 5 SIMs And Capture IMSIs
- Navigates to Manage Devices.
- Selects all 5 SIMs (in Warm state).
- Changes state from Warm → Activated.
- Captures IMSI values for each activated SIM.

### STEP_17 — Generate Invoice And Download CSV
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
STEP_01  → EC_ACCOUNT_NAME, CUSTOMER_REF_NUMBER
STEP_07  → ORDER_ID
STEP_08  → EC_ID, BU_ID
STEP_16  → IMSI_LIST (list of activated IMSIs)
```

## Automation Notes

- Steps run **in order**; failure of an early step typically causes downstream steps to fail.
- `Set Suite Variable` is used to pass data between steps.
- SSH connections use Robot Framework's `SSHLibrary`.
- MySQL queries use `DatabaseLibrary` or custom Python keywords.
- SOAP calls use `RequestsLibrary` with XML template rendering via Python `str.format()`.
- This suite does **not** have negative test cases — it is a pure happy-path E2E validation.
