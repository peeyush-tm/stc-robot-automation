# Order Processing Module

## Overview
Order Processing is not a standalone test suite but a shared set of keywords used by E2E flows, PAYG tests, and SIM Replacement tests. It handles the server-side SIM order pipeline: capturing order IDs, fetching account IDs from the database, running SSH scripts on the order processing server, uploading response files, and validating order status transitions.

## Pipeline Steps
1. **Capture Order ID** — Read Order Number from Live Order grid after SIM Order creation
2. **Fetch Account IDs** — Query MySQL database for EC and BU account IDs
3. **Run Create Order Script** — SSH to server, execute `start_createorder.sh`
4. **Validate Order In Progress** — Verify order status changed from New to In Progress
5. **Upload Response Files** — Generate and SCP response files (dsprsp, ordrsp, pcsrsp) to server
6. **Run Read Order Script** — SSH to server, execute `start_readorder.sh`
7. **Validate Order Completed** — Verify order status changed to Completed

## Files
- **Keywords:** `resources/keywords/order_processing_keywords.resource`
- **Variables:** `variables/order_processing_variables.py`
- **Templates:** `templates/order_processing/dsprsp.template`, `ordrsp.template`, `pcsrsp.template`
- **SOAP Template:** `templates/api/SimOrderUpdateStatus.xml`

## Key Keywords
- `Capture Order Number From Grid` — Waits for grid, filters by account column, reads first row
- `Filter Grid By Account Column` — Applies Kendo grid column filter
- `Fetch EC And BU Account IDs From Database` — MySQL query for account IDs
- `Run Create Order Script Via SSH` — SSH command execution
- `Upload Response Files To Server` — SCP file transfer
- `Validate Order Status` — Grid status cell verification

## Config Dependencies
- `SSH_HOST` / `SSH_USERNAME` / `SSH_PASSWORD` — Order processing server
- `SSH_ORDER_DIR` / `SSH_ORDER_INPUT_DIR` — Server directory paths
- `DB_HOST` / `DB_PORT` / `DB_NAME` / `DB_USER` / `DB_PASS` — MySQL database
- `SOAP_ORDER_STATUS_URL` / `SOAP_ORDER_STATUS_ACTION` — SOAP API for status updates
- `LIVE_ORDER_URL` — Live Order page URL

## Used By
- `tests/e2e_flow.robot` — Steps 8-14
- `tests/e2e_flow_with_usage.robot` — Steps 8-14
- `tests/payg_data_usage_tests.robot` — Steps 8-14 per scenario
- `tests/sim_replacement_tests.robot` — Blank order pipeline
