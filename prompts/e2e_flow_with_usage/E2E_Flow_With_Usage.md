# E2E Flow With Usage Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `E2E_Flow_With_Usage` |
| **Suite File** | `tests/e2e_flow_with_usage.robot` |
| **Variables File** | `variables/usage_variables.py` |
| **Type** | E2E (UI + API + SSH + Usage) |
| **Total TCs** | 23 |
| **Tags** | `e2e`, `api`, `onboard`, `apn`, `csr-journey`, `sim-range`, `product-type`, `sim-order`, `order-processing`, `manage-devices`, `device-state-change`, `usage`, `invoice`, `billing`, `capture`, `database`, `ssh`, `soap`, `validation` |

## Run Commands

```bash
python run_tests.py --suite E2E_Flow_With_Usage
python run_tests.py tests/e2e_flow_with_usage.robot
python run_tests.py --suite E2E_Flow_With_Usage --env staging
python run_tests.py --suite E2E_Flow_With_Usage --test "TC_E2EU_001*"
```

## Flow Description

The **E2E Flow With Usage** suite extends the base [E2E Flow](../e2e_flow/E2E_Flow.md) by adding **Usage Generation and Validation** steps (TC_E2EU_019 and TC_E2EU_020) between SIM activation and invoice generation. After activating 5 SIMs, the suite simulates data usage for each SIM via an API call, then validates the reported usage in the UI before generating the invoice.

## Flow Steps

| TC ID | Name | Type | Differs from E2E_Flow? |
|-------|------|------|----------------------|
| TC_E2EU_001 | Onboard EC And BU Account Via API | API (SOAP) | Same |
| TC_E2EU_002 | Verify Onboarded Account On UI | UI | Same |
| TC_E2EU_003 | Create APN For Onboarded Account | UI | Same |
| TC_E2EU_004 | Create CSR Journey For Onboarded Account | UI | Same |
| TC_E2EU_005 | Create SIM Range With 10 ICCID IMSI | UI | Same |
| TC_E2EU_006 | Create And Assign SIM Product Type | UI | Same |
| TC_E2EU_007 | Expand EC And BU SIM Limits | UI | Same |
| TC_E2EU_008 | Create SIM Order | UI | Same |
| TC_E2EU_009 | Capture Order ID From Live Order Grid | UI | Same |
| TC_E2EU_010 | Fetch EC And BU Account IDs From Database | DB (MySQL) | Same |
| TC_E2EU_011 | Run Create Order Script On Server | SSH | Same |
| TC_E2EU_012 | Validate Order Status New To In Progress | UI | Same |
| TC_E2EU_013 | Generate And Upload Response Files To Server | SSH/File | Same |
| TC_E2EU_014 | Run Read Order Script On Server | SSH | Same |
| TC_E2EU_015 | Validate Order Status In Progress To Completed | UI | Same |
| TC_E2EU_016 | Validate SIMs In Warm State On Manage Devices | UI | Same |
| TC_E2EU_017 | Update Order Status To Approved Via SOAP API | API (SOAP) | Same |
| TC_E2EU_018 | Activate 5 SIMs And Capture IMSIs And MSISDNs | UI | **Extended** — also captures MSISDNs |
| TC_E2EU_019 | Perform Usage For All Activated IMSIs | API | **New** |
| TC_E2EU_020 | Validate Usage In UI For All IMSIs | UI | **New** |
| TC_E2EU_021 | Generate Invoice And Download CSV | UI | Same |
| TC_E2EU_022 | Create Second CSR Journey With Different Plan | UI | Same |
| TC_E2EU_023 | Perform Device Plan Change On One Activated SIM And Validate | UI | Same |

## New / Extended Step Details

### TC_E2EU_018 — Activate 5 SIMs And Capture IMSIs And MSISDNs *(Extended)*
- Same as TC_E2E_018 in E2E_Flow but additionally captures **MSISDN** values for each SIM.
- Stores both `IMSI_LIST` and `MSISDN_LIST` as suite variables.

### TC_E2EU_019 — Perform Usage For All Activated IMSIs *(New)*
- For each IMSI in `IMSI_LIST`, sends a **Usage API** request (REST/SOAP) simulating data consumption.
- Parameters: IMSI, MSISDN, Usage Amount (MB), Timestamp.
- Verifies API returns HTTP 200 / success status for each IMSI.
- Stores `USAGE_RECORDS` per IMSI for later validation.

### TC_E2EU_020 — Validate Usage In UI For All IMSIs *(New)*
- Navigates to the Usage section / Manage Devices usage view in the portal.
- For each IMSI in `IMSI_LIST`, filters usage records and verifies:
  - Usage amount matches the value sent in STEP_16A.
  - Timestamp is within an acceptable range.
  - MSISDN is correctly associated.
- Captures screenshots for each validated IMSI.

## Suite Variable Flow

```
TC_E2EU_001  → EC_ACCOUNT_NAME, CUSTOMER_REF_NUMBER
TC_E2EU_009  → ORDER_ID
TC_E2EU_010  → EC_ID, BU_ID
TC_E2EU_018  → IMSI_LIST, MSISDN_LIST
TC_E2EU_019  → USAGE_RECORDS (dict of IMSI → usage_amount)
TC_E2EU_020  → Validation screenshots per IMSI
TC_E2EU_021  → Invoice CSV downloaded
```

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/e2e_flow_with_usage.robot` | E2E With Usage test suite |
| `resources/keywords/e2e_keywords.resource` | Shared E2E keywords |
| `resources/keywords/usage_keywords.resource` | Usage API call and UI validation keywords |
| `variables/usage_variables.py` | Usage amounts, API endpoints, MSISDN patterns |
| `templates/api/CustomerOnboardOperation.xml` | SOAP template for STEP_01 |
| `templates/api/SimOrderUpdateStatus.xml` | SOAP template for STEP_15 |
| `config/<env>.json` | `BASE_URL`, `USAGE_API_URL`, `DB_*`, `SSH_*` |

## Differences from E2E_Flow

| Aspect | E2E_Flow | E2E_Flow_With_Usage |
|--------|----------|-------------------|
| TC_E2EU_018 captures | IMSI only | IMSI + MSISDN |
| Usage generation | — | TC_E2EU_019 (API calls per IMSI) |
| Usage validation | — | TC_E2EU_020 (UI verification per IMSI) |
| Variables file | `order_processing_variables.py` | `usage_variables.py` |
| Duration | ~20–30 min | ~35–50 min (usage wait time) |

## Automation Notes

- Usage API may require a **propagation wait** (polling) before the data appears in the UI.
- STEP_16B uses `Wait Until Keyword Succeeds` with a retry loop to handle async usage reporting.
- Screenshots are captured for each IMSI validation in STEP_16B for audit purposes.
- `IMSI_LIST` and `MSISDN_LIST` are Python lists stored as Robot suite variables; keywords iterate with `FOR` loops.
- This suite does **not** have negative test cases — it is a pure happy-path E2E validation.
