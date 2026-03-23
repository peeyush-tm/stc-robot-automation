# Account Onboard Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `Account_Onboard` |
| **Suite File** | `tests/onboard_customer_api_tests.robot` |
| **Variables File** | `variables/onboard_customer_variables.py` |
| **Type** | **API** (SOAP/XML) |
| **Endpoint** | `<BASE_URL>/api/CustomerOnboardOperation` (SOAP) |
| **Total TCs** | 39 |
| **Tags** | `onboard`, `e2e`, `api`, `validation`, `optional-fields`, `mandatory-only`, `header`, `invalid`, `duplicate`, `malformed`, `boundary`, `special-chars`, `edge-case` |

## Run Commands

```bash
python run_tests.py --suite Account_Onboard
python run_tests.py tests/onboard_customer_api_tests.robot
python run_tests.py --suite Account_Onboard --include smoke
python run_tests.py --suite Account_Onboard --include api
python run_tests.py --suite Account_Onboard --include onboard
python run_tests.py --suite Account_Onboard --include negative
python run_tests.py --suite Account_Onboard --test "TC_ONBOARD_001*"
```

## Module Description

The **Account Onboard** suite tests the **Customer Onboarding SOAP API** (`CustomerOnboardOperation`). It sends XML requests to create Customers (EC accounts) and their Billing Accounts. Tests cover full payloads, optional field omissions, mandatory field validations, invalid value handling, edge cases, and SOAP envelope structure.

**Template:** `templates/api/CustomerOnboardOperation.xml`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_ONBOARD_001 | Create Customer And Billing Account With All Fields | Positive | smoke, e2e, api |
| TC_ONBOARD_002 | Create Customer Without Optional UnifiedID | Positive | optional-fields, api |
| TC_ONBOARD_003 | Create Customer Without Optional Address Lines 2 To 5 | Positive | optional-fields, api |
| TC_ONBOARD_004 | Create Customer Without Optional AlternateName | Positive | optional-fields, api |
| TC_ONBOARD_005 | Create Customer Without Optional TechContactPersonMobile | Positive | optional-fields, api |
| TC_ONBOARD_006 | Create Customer Without Optional TechContactPersonEmail | Positive | optional-fields, api |
| TC_ONBOARD_007 | Create Customer Without Optional LeadPersonOrAccManagerID | Positive | optional-fields, api |
| TC_ONBOARD_008 | Create Customer Without Optional Billing Address Lines 2 To 5 | Positive | optional-fields, api |
| TC_ONBOARD_009 | Create Customer With Only Mandatory Fields | Positive | mandatory-only, api |
| TC_ONBOARD_010 | Missing CustomerReferenceNumber Should Return Error | Negative | validation, api |
| TC_ONBOARD_011 | Missing CompanyName Should Return Error | Negative | validation, api |
| TC_ONBOARD_012 | Missing FirstName Should Return Error | Negative | validation, api |
| TC_ONBOARD_013 | Missing LastName Should Return Error | Negative | validation, api |
| TC_ONBOARD_014 | Missing IdentityNumber Should Return Error | Negative | validation, api |
| TC_ONBOARD_015 | Missing CustomerSegmentCode Should Return Error | Negative | validation, api |
| TC_ONBOARD_016 | Missing BusinessUnitName Should Return Error | Negative | validation, api |
| TC_ONBOARD_017 | Missing BillingAccountName Should Return Error | Negative | validation, api |
| TC_ONBOARD_018 | Missing BillingAccountNumber Should Return Error | Negative | validation, api |
| TC_ONBOARD_019 | Missing CustomerAddressLine1 Should Return Error | Negative | validation, api |
| TC_ONBOARD_020 | Missing CustomerCountry Should Return Error | Negative | validation, api |
| TC_ONBOARD_021 | Missing OrderNumber In Header Should Return Error | Negative | header, api |
| TC_ONBOARD_022 | Missing TaskID In Header Should Return Error | Negative | header, api |
| TC_ONBOARD_023 | Invalid CustomerSegmentCode Should Return Error | Negative | invalid, api |
| TC_ONBOARD_024 | Invalid CustomerType Should Return Error | Negative | invalid, api |
| TC_ONBOARD_025 | Invalid BillHierarchyFlag Should Return Error | Negative | invalid, api |
| TC_ONBOARD_026 | Invalid BillingAccountStatus Should Return Error | Negative | invalid, api |
| TC_ONBOARD_027 | Invalid MaxNumberIMSIs Non Numeric Should Return Error | Negative | invalid, api |
| TC_ONBOARD_028 | Invalid CustomerGenre Should Return Error | Negative | invalid, api |
| TC_ONBOARD_029 | Invalid Category Should Return Error | Negative | invalid, api |
| TC_ONBOARD_030 | Invalid Email Format Should Return Error | Negative | invalid, api |
| TC_ONBOARD_033 | Duplicate CustomerReferenceNumber Should Return Error | Edge Case | duplicate, api |
| TC_ONBOARD_034 | Malformed XML Body Should Return Error | Edge Case | malformed, api |
| TC_ONBOARD_035 | Empty SOAP Body Should Return Error | Edge Case | empty-body, api |
| TC_ONBOARD_036 | Wrong SOAPAction Header Should Return Error | Edge Case | header, api |
| TC_ONBOARD_037 | MaxNumberIMSIs Zero Should Return Error Or Accept | Edge Case | boundary, api |
| TC_ONBOARD_038 | MaxSIMNumber Zero Should Return Error Or Accept | Edge Case | boundary, api |
| TC_ONBOARD_039 | Negative MaxNumberIMSIs Should Return Error | Edge Case | boundary, api |
| TC_ONBOARD_040 | Special Characters In CompanyName | Edge Case | special-chars, api |

## Test Case Categories

### Positive — Happy Path (1 TC)
- **TC_ONBOARD_001** — Full payload with all fields (mandatory + optional). Expects HTTP 200 and success response code.

### Positive — Optional Fields (8 TCs)
- **TC_ONBOARD_002–009** — Each test omits a different optional field (or all optional fields) and verifies the API still returns success. Confirms optional fields do not cause failures when absent.

### Negative — Missing Mandatory Fields (11 TCs)
- **TC_ONBOARD_010–020** — Each removes one mandatory field from the request. Expects an error response indicating the missing field.

### Negative — Invalid Header Values (2 TCs)
- **TC_ONBOARD_021** — Missing `OrderNumber` in SOAP header → error.
- **TC_ONBOARD_022** — Missing `TaskID` in SOAP header → error.

### Negative — Invalid Field Values (8 TCs)
- **TC_ONBOARD_023–030** — Sends known-invalid enum/format values (e.g. invalid segment code, wrong email format, non-numeric IMSI count). Expects validation error response.

### Edge Cases (9 TCs)
- **TC_ONBOARD_033** — Duplicate `CustomerReferenceNumber` in a second request → duplicate error.
- **TC_ONBOARD_034** — Malformed XML (broken tags) → SOAP fault or HTTP error.
- **TC_ONBOARD_035** — Empty SOAP Body → fault.
- **TC_ONBOARD_036** — Wrong `SOAPAction` header value → fault or error.
- **TC_ONBOARD_037** — `MaxNumberIMSIs=0` → accepts or returns specific boundary error.
- **TC_ONBOARD_038** — `MaxSIMNumber=0` → accepts or returns boundary error.
- **TC_ONBOARD_039** — Negative `MaxNumberIMSIs` → error.
- **TC_ONBOARD_040** — Special characters in `CompanyName` → validates handling.

## SOAP Request Structure

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ...>
  <soapenv:Header>
    <wsse:Security>...</wsse:Security>
    <tns:OrderNumber>{{ORDER_NUMBER}}</tns:OrderNumber>
    <tns:TaskID>{{TASK_ID}}</tns:TaskID>
  </soapenv:Header>
  <soapenv:Body>
    <tns:CustomerOnboardOperationRequest>
      <tns:CustomerReferenceNumber>...</tns:CustomerReferenceNumber>
      <tns:CompanyName>...</tns:CompanyName>
      <!-- ... all customer and billing fields ... -->
    </tns:CustomerOnboardOperationRequest>
  </soapenv:Body>
</soapenv:Envelope>
```

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/onboard_customer_api_tests.robot` | Test suite |
| `resources/keywords/api_keywords.resource` | SOAP request / response assertion keywords |
| `variables/onboard_customer_variables.py` | Customer reference numbers, names, addresses, billing data |
| `templates/api/CustomerOnboardOperation.xml` | Base SOAP XML template |
| `config/<env>.json` | `BASE_URL`, API auth headers |

## Automation Notes

- All test data values (CustomerReferenceNumber, CompanyName) are **randomly generated** per run to avoid duplicate key errors across runs.
- The `BuiltIn` `Evaluate` keyword generates unique references using timestamps: `uuid.uuid4()` or `int(time.time())`.
- HTTP POST with `Content-Type: text/xml; charset=utf-8` and `SOAPAction` header.
- Response validation checks HTTP status code and XML response body for success/error codes.
- No browser is launched; tests use Robot Framework's `RequestsLibrary`.
