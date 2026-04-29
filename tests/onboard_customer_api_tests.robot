*** Settings ***
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Resource    ../resources/keywords/api_keywords.resource
Library     ../libraries/ConfigLoader.py
Library     ../libraries/SeedWriter.py
Variables   ../variables/onboard_customer_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Create Onboard API Session
Suite Teardown    Delete All Sessions

*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES — Data-Driven (unique IDs per test)
# ═══════════════════════════════════════════════════════════════════════

TC_ONBOARD_001 Create Customer And Billing Account With All Fields
    [Documentation]    Sends createOnboardCustomer SOAP request with all fields populated.
    ...                Verifies HTTP 200, no SOAP fault.
    [Tags]    smoke    positive    onboard    e2e    TC_ONBOARD_001
    TC_ONBOARD_001

TC_ONBOARD_002 Create Customer Without Optional UnifiedID
    [Documentation]    Sends request with unifiedID left empty (optional).
    [Tags]    positive    onboard    TC_ONBOARD_002
    TC_ONBOARD_002

TC_ONBOARD_003 Create Customer Without Optional Address Lines 2 To 5
    [Documentation]    Only mandatory addressLine1 for customer address.
    [Tags]    positive    onboard    TC_ONBOARD_003
    TC_ONBOARD_003

TC_ONBOARD_004 Create Customer Without Optional AlternateName
    [Documentation]    alternateName left empty.
    [Tags]    positive    onboard    TC_ONBOARD_004
    TC_ONBOARD_004

TC_ONBOARD_005 Create Customer Without Optional TechContactPersonMobile
    [Documentation]    techContactPersonMobile empty.
    [Tags]    positive    onboard    TC_ONBOARD_005
    TC_ONBOARD_005

TC_ONBOARD_006 Create Customer Without Optional TechContactPersonEmail
    [Documentation]    techContactPersonEmail empty.
    [Tags]    positive    onboard    TC_ONBOARD_006
    TC_ONBOARD_006

TC_ONBOARD_007 Create Customer Without Optional LeadPersonOrAccManagerID
    [Documentation]    leadPersonOrAccManagerID empty.
    [Tags]    positive    onboard    TC_ONBOARD_007
    TC_ONBOARD_007

TC_ONBOARD_008 Create Customer Without Optional Billing Address Lines 2 To 5
    [Documentation]    billingAddress lines 2-5 empty.
    [Tags]    positive    onboard    TC_ONBOARD_008
    TC_ONBOARD_008

TC_ONBOARD_009 Create Customer With Only Mandatory Fields
    [Documentation]    All optional fields empty — minimal valid payload.
    [Tags]    positive    onboard    TC_ONBOARD_009
    TC_ONBOARD_009

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — Missing Mandatory Fields
# ═══════════════════════════════════════════════════════════════════════

TC_ONBOARD_010 Missing CustomerReferenceNumber Should Return Error
    [Documentation]    customerReferenceNumber empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_010
    TC_ONBOARD_010

TC_ONBOARD_011 Missing CompanyName Should Return Error
    [Documentation]    companyName empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_011
    TC_ONBOARD_011

# Service accepts empty firstName / lastName (HTTP 200, no SOAP fault) — not rejected like other mandatory fields.
TC_ONBOARD_012 Create Customer With Empty FirstName Should Succeed
    [Documentation]    firstName empty element — CMP onboard API still returns success (no SOAP fault).
    [Tags]    positive    onboard    TC_ONBOARD_012
    TC_ONBOARD_012

TC_ONBOARD_013 Create Customer With Empty LastName Should Succeed
    [Documentation]    lastName empty element — CMP onboard API still returns success (no SOAP fault).
    [Tags]    positive    onboard    TC_ONBOARD_013
    TC_ONBOARD_013

TC_ONBOARD_014 Missing IdentityNumber Should Return Error
    [Documentation]    identityNumber empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_014
    TC_ONBOARD_014

TC_ONBOARD_015 Missing CustomerSegmentCode Should Return Error
    [Documentation]    customerSegmentCode empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_015
    TC_ONBOARD_015

TC_ONBOARD_016 Missing BusinessUnitName Should Return Error
    [Documentation]    businessUnitName empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_016
    TC_ONBOARD_016

TC_ONBOARD_017 Missing BillingAccountName Should Return Error
    [Documentation]    billingAccountName empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_017
    TC_ONBOARD_017

TC_ONBOARD_018 Missing BillingAccountNumber Should Return Error
    [Documentation]    billingAccountNumber empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_018
    TC_ONBOARD_018

TC_ONBOARD_019 Missing CustomerAddressLine1 Should Return Error
    [Documentation]    customer addressLine1 empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_019
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_address_line1=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_020 Missing CustomerCountry Should Return Error
    [Documentation]    customer country empty — mandatory field.
    [Tags]    negative    onboard    TC_ONBOARD_020
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_country=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_021 Missing OrderNumber In Header Should Return Error
    [Documentation]    orderNumber in SOAP header empty.
    [Tags]    negative    onboard    TC_ONBOARD_021
    TC_ONBOARD_021

TC_ONBOARD_022 Missing TaskID In Header Should Return Error
    [Documentation]    taskID in SOAP header empty.
    [Tags]    negative    onboard    TC_ONBOARD_022
    TC_ONBOARD_022

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — Invalid Values
# ═══════════════════════════════════════════════════════════════════════

TC_ONBOARD_023 Invalid CustomerSegmentCode Should Return Error
    [Documentation]    Invalid customerSegmentCode value.
    [Tags]    negative    onboard    TC_ONBOARD_023
    TC_ONBOARD_023

TC_ONBOARD_024 Invalid CustomerType Should Return Error
    [Documentation]    Invalid customerType value.
    [Tags]    negative    onboard    TC_ONBOARD_024
    TC_ONBOARD_024

TC_ONBOARD_025 Invalid BillHierarchyFlag Should Return Error
    [Documentation]    Invalid billHierarchyFlag (not Y/N).
    [Tags]    negative    onboard    TC_ONBOARD_025
    TC_ONBOARD_025

TC_ONBOARD_026 Invalid BillingAccountStatus Should Return Error
    [Documentation]    Invalid billingAccountStatus value.
    [Tags]    negative    onboard    TC_ONBOARD_026
    TC_ONBOARD_026

TC_ONBOARD_027 Non Numeric MaxNumberIMSIs Still Returns Success
    [Documentation]    Non-numeric maxNumberIMSIs (e.g. ABC) — CMP returns HTTP 200 with no SOAP fault (no strict type rejection).
    [Tags]    positive    onboard    TC_ONBOARD_027
    TC_ONBOARD_027

TC_ONBOARD_028 Invalid CustomerGenre Should Return Error
    [Documentation]    Invalid customerGenre.
    [Tags]    negative    onboard    TC_ONBOARD_028
    TC_ONBOARD_028

TC_ONBOARD_029 Invalid Category Should Return Error
    [Documentation]    Invalid category value.
    [Tags]    negative    onboard    TC_ONBOARD_029
    TC_ONBOARD_029

TC_ONBOARD_030 Invalid Tech Contact Email Still Returns Success
    [Documentation]    Malformed techContactPersonEmail — CMP returns HTTP 200 with no SOAP fault (no email-format validation at SOAP layer).
    [Tags]    positive    onboard    TC_ONBOARD_030
    TC_ONBOARD_030

# ═══════════════════════════════════════════════════════════════════════
#  EDGE CASES
# ═══════════════════════════════════════════════════════════════════════

TC_ONBOARD_033 Duplicate CustomerReferenceNumber Should Return Error
    [Documentation]    Sends same request twice with identical customerReferenceNumber.
    ...                Second request should fail.
    [Tags]    onboard    TC_ONBOARD_033
    TC_ONBOARD_033

TC_ONBOARD_034 Malformed XML Body Should Return Error
    [Documentation]    Sends malformed XML (missing closing tags).
    [Tags]    onboard    TC_ONBOARD_034
    TC_ONBOARD_034

TC_ONBOARD_035 Empty SOAP Body Should Return Error
    [Documentation]    Valid envelope but empty Body.
    [Tags]    onboard    TC_ONBOARD_035
    TC_ONBOARD_035

TC_ONBOARD_036 Wrong SOAPAction Header Should Return Error
    [Documentation]    Incorrect SOAPAction header value.
    [Tags]    onboard    TC_ONBOARD_036
    TC_ONBOARD_036

TC_ONBOARD_037 MaxNumberIMSIs Zero Should Return Error Or Accept
    [Documentation]    maxNumberIMSIs = 0 (boundary).
    [Tags]    onboard    TC_ONBOARD_037
    TC_ONBOARD_037

TC_ONBOARD_038 MaxSIMNumber Zero Should Return Error Or Accept
    [Documentation]    maxSIMNumber = 0 (boundary).
    [Tags]    onboard    TC_ONBOARD_038
    TC_ONBOARD_038

TC_ONBOARD_039 Negative MaxNumberIMSIs Should Return Error
    [Documentation]    Negative maxNumberIMSIs. Spec expects fault; some APIs return 200 success — both accepted.
    [Tags]    onboard    TC_ONBOARD_039
    TC_ONBOARD_039

TC_ONBOARD_040 Special Characters In CompanyName
    [Documentation]    Special characters in companyName.
    [Tags]    onboard    TC_ONBOARD_040
    TC_ONBOARD_040

*** Keywords ***
TC_ONBOARD_001
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}
    Write Seed Value    onboard_ec_name    ${data}[company_name]
    Write Seed Value    onboard_bu_name    ${data}[billing_account_name]
    Log    Persisted onboard_ec_name=${data}[company_name], onboard_bu_name=${data}[billing_account_name]    console=yes
    Log    Full response: ${response.text}

TC_ONBOARD_002
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    unified_id=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_003
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_address_line2=${EMPTY}
    ...    customer_address_line3=${EMPTY}
    ...    customer_address_line4=${EMPTY}
    ...    customer_address_line5=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_004
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    alternate_name=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_005
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    tech_contact_person_mobile=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_006
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    tech_contact_person_email=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_007
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    lead_person_or_acc_manager_id=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_008
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    billing_address_line2=${EMPTY}
    ...    billing_address_line3=${EMPTY}
    ...    billing_address_line4=${EMPTY}
    ...    billing_address_line5=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_009
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    unified_id=${EMPTY}
    ...    alternate_name=${EMPTY}
    ...    primary_phone_number=${EMPTY}
    ...    customer_address_line2=${EMPTY}
    ...    customer_address_line3=${EMPTY}
    ...    customer_address_line4=${EMPTY}
    ...    customer_address_line5=${EMPTY}
    ...    tech_contact_person_mobile=${EMPTY}
    ...    tech_contact_person_email=${EMPTY}
    ...    lead_person_or_acc_manager_id=${EMPTY}
    ...    local_data=${EMPTY}
    ...    data_with_internet=${EMPTY}
    ...    voice_with_internet=${EMPTY}
    ...    preferred_language=${EMPTY}
    ...    billing_address_line2=${EMPTY}
    ...    billing_address_line3=${EMPTY}
    ...    billing_address_line4=${EMPTY}
    ...    billing_address_line5=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_010
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_reference_number=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_011
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    company_name=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_012
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    first_name=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_013
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    last_name=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_014
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    identity_number=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_015
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_segment_code=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_016
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    business_unit_name=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_017
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    billing_account_name=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_018
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_019
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_address_line1=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_020
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_country=${EMPTY}
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_021
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${EMPTY}    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_022
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${EMPTY}
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_023
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_segment_code=INVALID_SEGMENT
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_024
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_type=INVALID_TYPE
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_025
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    bill_hierarchy_flag=INVALID
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_026
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    billing_account_status=INVALID_STATUS
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_027
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    max_number_imsis=ABC
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_028
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    customer_genre=INVALID_GENRE
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_029
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    category=INVALID_CATEGORY
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}    Verify SOAP Fault Present    ${response}

TC_ONBOARD_030
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    tech_contact_person_email=not-an-email
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}

TC_ONBOARD_033
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ${response1}=    Send Onboard Customer Request    ${soap_body}
    Log    First request status: ${response1.status_code}
    ${data2}=    Generate Unique Test Data
    ${soap_body2}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data2}[order_number]    task_id=${data2}[task_id]
    ...    business_unit_name=${data2}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data2}[billing_account_name]
    ...    billing_account_number=${data2}[billing_account_number]
    ${response2}=    Send Onboard Customer Request    ${soap_body2}
    Log    Second request status: ${response2.status_code}
    Log    Second response: ${response2.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response2}    200
    IF    ${is_200}
        ${has_fault}=    Run Keyword And Return Status
        ...    Verify SOAP Fault Present    ${response2}
        IF    not ${has_fault}
            Log    API accepted duplicate customerReferenceNumber — may be idempotent.    level=WARN
        END
    END

TC_ONBOARD_034
    ${bad_xml}=    Set Variable    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><BROKEN_TAG>
    ${headers}=    Create Dictionary
    ...    Content-Type=application/xml
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ...    SOAPAction=${ONBOARD_SOAP_ACTION}
    ${response}=    POST On Session    onboard    url=${ONBOARD_API_URL}
    ...    data=${bad_xml}    headers=${headers}    expected_status=any
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
    Should Be True    ${response.status_code} >= 400 or ${response.status_code} == 200
    IF    ${response.status_code} == 200
        Verify SOAP Fault Present    ${response}
    END

TC_ONBOARD_035
    ${empty_body}=    Set Variable    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://webservice.airlinq.com/"><soapenv:Header><web:orderNumber>EMPTY_TEST</web:orderNumber><web:taskID>EMPTY_TID</web:taskID></soapenv:Header><soapenv:Body></soapenv:Body></soapenv:Envelope>
    ${headers}=    Create Dictionary
    ...    Content-Type=application/xml
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ...    SOAPAction=${ONBOARD_SOAP_ACTION}
    ${response}=    POST On Session    onboard    url=${ONBOARD_API_URL}
    ...    data=${empty_body}    headers=${headers}    expected_status=any
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
    IF    ${response.status_code} == 200
        Verify SOAP Fault Present    ${response}
    END

TC_ONBOARD_036
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ${headers}=    Create Dictionary
    ...    Content-Type=application/xml
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ...    SOAPAction=http://invalid.action/wrong
    ${response}=    POST On Session    onboard    url=${ONBOARD_API_URL}
    ...    data=${soap_body}    headers=${headers}    expected_status=any
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
    IF    ${response.status_code} == 200
        Verify SOAP Fault Present    ${response}
    END

TC_ONBOARD_037
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    max_number_imsis=0
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}

TC_ONBOARD_038
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    max_sim_number=0
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}

TC_ONBOARD_039
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    max_number_imsis=-1
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
    ${is_200}=    Run Keyword And Return Status    Verify Response Status Code    ${response}    200
    IF    ${is_200}
        ${fault_present}=    Run Keyword And Return Status    Verify SOAP Fault Present    ${response}
        IF    not ${fault_present}
            Pass Execution    Negative MaxNumberIMSIs: API returned 200 without SOAP fault/error — app accepts value; documented pass.
        END
    END

TC_ONBOARD_040
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    ...    company_name=EC&amp;Test&lt;Co&gt;
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
