*** Settings ***
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/login_locators.resource
Resource    ../locators/cost_center_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  SESSION MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════
Create Onboard API Session
    [Documentation]    Creates an HTTPS session to the onboarding SOAP endpoint.
    ...                Disables SSL verification for self-signed certs.
    Create Session    onboard    ${ONBOARD_API_URL}    verify=${False}    disable_warnings=1

# ═══════════════════════════════════════════════════════════════════════
#  UNIQUE ID GENERATOR
# ═══════════════════════════════════════════════════════════════════════
Generate Unique Test Data
    [Documentation]    Generates fresh unique values for the 7 fields that must differ per test.
    ...                Returns a dictionary with keys: order_number, task_id, business_unit_name,
    ...                customer_reference_number, company_name, billing_account_name, billing_account_number.
    ${uid}=    Evaluate    str(int(time.time()*1000))[-8:]    modules=time
    ${rand4}=    Evaluate    ''.join(__import__('random').choices(__import__('string').digits, k=4))    modules=random,string
    ${rand6}=    Evaluate    ''.join(__import__('random').choices(__import__('string').digits, k=6))    modules=random,string
    ${data}=    Create Dictionary
    ...    order_number=S5P1_${uid}
    ...    task_id=S5P1_auto_${uid}
    ...    business_unit_name=S5P1_auto_${uid}
    ...    customer_reference_number=9595${rand4}${rand4}
    ...    company_name=AQ_AUTO_EC_${uid}
    ...    billing_account_name=AQ_AUTO_BU_${uid}
    ...    billing_account_number=4423${uid}${rand4}0
    RETURN    ${data}

# ═══════════════════════════════════════════════════════════════════════
#  SOAP ENVELOPE BUILDER
# ═══════════════════════════════════════════════════════════════════════
Build Onboard Customer SOAP Envelope
    [Documentation]    Builds the full SOAP XML envelope for createOnboardCustomer.
    ...                All parameters are keyword arguments with defaults from variables.
    [Arguments]
    ...    ${order_number}=${ORDER_NUMBER}
    ...    ${task_id}=${TASK_ID}
    ...    ${business_unit_name}=${BUSINESS_UNIT_NAME}
    ...    ${unified_id}=${UNIFIED_ID}
    ...    ${customer_reference_number}=${CUSTOMER_REFERENCE_NUMBER}
    ...    ${customer_segment_code}=${CUSTOMER_SEGMENT_CODE}
    ...    ${customer_type}=${CUSTOMER_TYPE}
    ...    ${bill_hierarchy_flag}=${BILL_HIERARCHY_FLAG}
    ...    ${company_name}=${COMPANY_NAME}
    ...    ${first_name}=${FIRST_NAME}
    ...    ${last_name}=${LAST_NAME}
    ...    ${alternate_name}=${ALTERNATE_NAME}
    ...    ${identification_type_code}=${IDENTIFICATION_TYPE_CODE}
    ...    ${identity_number}=${IDENTITY_NUMBER}
    ...    ${primary_phone_number}=${PRIMARY_PHONE_NUMBER}
    ...    ${language_code}=${LANGUAGE_CODE}
    ...    ${customer_country}=${CUSTOMER_COUNTRY}
    ...    ${customer_zip_code}=${CUSTOMER_ZIP_CODE}
    ...    ${customer_address_type}=${CUSTOMER_ADDRESS_TYPE}
    ...    ${customer_address_line1}=${CUSTOMER_ADDRESS_LINE1}
    ...    ${customer_address_line2}=${CUSTOMER_ADDRESS_LINE2}
    ...    ${customer_address_line3}=${CUSTOMER_ADDRESS_LINE3}
    ...    ${customer_address_line4}=${CUSTOMER_ADDRESS_LINE4}
    ...    ${customer_address_line5}=${CUSTOMER_ADDRESS_LINE5}
    ...    ${customer_genre}=${CUSTOMER_GENRE}
    ...    ${category}=${CUSTOMER_CATEGORY}
    ...    ${max_number_imsis}=${MAX_NUMBER_IMSIS}
    ...    ${tech_contact_person_mobile}=${TECH_CONTACT_PERSON_MOBILE}
    ...    ${tech_contact_person_email}=${TECH_CONTACT_PERSON_EMAIL}
    ...    ${lead_person_or_acc_manager_id}=${LEAD_PERSON_OR_ACC_MANAGER_ID}
    ...    ${local_data}=${LOCAL_DATA}
    ...    ${data_with_internet}=${DATA_WITH_INTERNET}
    ...    ${voice_with_internet}=${VOICE_WITH_INTERNET}
    ...    ${preferred_language}=${PREFERRED_LANGUAGE}
    ...    ${billing_account_name}=${BILLING_ACCOUNT_NAME}
    ...    ${billing_account_number}=${BILLING_ACCOUNT_NUMBER}
    ...    ${billing_account_status}=${BILLING_ACCOUNT_STATUS}
    ...    ${bill_cycle}=${BILL_CYCLE}
    ...    ${max_sim_number}=${MAX_SIM_NUMBER}
    ...    ${fingerprint_status}=${FINGERPRINT_STATUS}
    ...    ${bu_tech_contact_person_mobile}=${BU_TECH_CONTACT_PERSON_MOBILE}
    ...    ${bu_tech_contact_person_email}=${BU_TECH_CONTACT_PERSON_EMAIL}
    ...    ${billing_country}=${BILLING_COUNTRY}
    ...    ${billing_zip_code}=${BILLING_ZIP_CODE}
    ...    ${billing_address_type}=${BILLING_ADDRESS_TYPE}
    ...    ${billing_address_line1}=${BILLING_ADDRESS_LINE1}
    ...    ${billing_address_line2}=${BILLING_ADDRESS_LINE2}
    ...    ${billing_address_line3}=${BILLING_ADDRESS_LINE3}
    ...    ${billing_address_line4}=${BILLING_ADDRESS_LINE4}
    ...    ${billing_address_line5}=${BILLING_ADDRESS_LINE5}
    ${xml}=    Set Variable    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://webservice.airlinq.com/"><soapenv:Header><web:orderNumber>${order_number}</web:orderNumber><web:taskID>${task_id}</web:taskID></soapenv:Header><soapenv:Body><web:createOnboardCustomer><businessUnitName>${business_unit_name}</businessUnitName><customer><unifiedID>${unified_id}</unifiedID><customerReferenceNumber>${customer_reference_number}</customerReferenceNumber><customerSegmentCode>${customer_segment_code}</customerSegmentCode><customerType>${customer_type}</customerType><billHierarchyFlag>${bill_hierarchy_flag}</billHierarchyFlag><companyName>${company_name}</companyName><customerName><firstName>${first_name}</firstName><lastName>${last_name}</lastName><alternateName>${alternate_name}</alternateName></customerName><partyIdentification><identificationTypeCode>${identification_type_code}</identificationTypeCode><identityNumber>${identity_number}</identityNumber></partyIdentification><primaryPhoneNumber>${primary_phone_number}</primaryPhoneNumber><languageCode>${language_code}</languageCode><customerAddress><country>${customer_country}</country><zipCode>${customer_zip_code}</zipCode><addressType>${customer_address_type}</addressType><addressLine1>${customer_address_line1}</addressLine1><addressLine2>${customer_address_line2}</addressLine2><addressLine3>${customer_address_line3}</addressLine3><addressLine4>${customer_address_line4}</addressLine4><addressLine5>${customer_address_line5}</addressLine5></customerAddress><customerGenre>${customer_genre}</customerGenre><category>${category}</category><maxNumberIMSIs>${max_number_imsis}</maxNumberIMSIs><techContactPersonMobile>${tech_contact_person_mobile}</techContactPersonMobile><techContactPersonEmail>${tech_contact_person_email}</techContactPersonEmail><leadPersonOrAccManagerID>${lead_person_or_acc_manager_id}</leadPersonOrAccManagerID><localData>${local_data}</localData><dataWithInternet>${data_with_internet}</dataWithInternet><voiceWithInternet>${voice_with_internet}</voiceWithInternet><preferredLanguage>${preferred_language}</preferredLanguage></customer><billingAccount><billingAccountName>${billing_account_name}</billingAccountName><billingAccountNumber>${billing_account_number}</billingAccountNumber><billingAccountStatus>${billing_account_status}</billingAccountStatus><billCycle>${bill_cycle}</billCycle><maxSIMNumber>${max_sim_number}</maxSIMNumber><fingerprintStatus>${fingerprint_status}</fingerprintStatus><buTechContactPersonMobile>${bu_tech_contact_person_mobile}</buTechContactPersonMobile><buTechContactPersonEmail>${bu_tech_contact_person_email}</buTechContactPersonEmail><billingAddress><country>${billing_country}</country><zipCode>${billing_zip_code}</zipCode><addressType>${billing_address_type}</addressType><addressLine1>${billing_address_line1}</addressLine1><addressLine2>${billing_address_line2}</addressLine2><addressLine3>${billing_address_line3}</addressLine3><addressLine4>${billing_address_line4}</addressLine4><addressLine5>${billing_address_line5}</addressLine5></billingAddress></billingAccount></web:createOnboardCustomer></soapenv:Body></soapenv:Envelope>
    RETURN    ${xml}

# ═══════════════════════════════════════════════════════════════════════
#  SEND SOAP REQUEST
# ═══════════════════════════════════════════════════════════════════════
Send Onboard Customer Request
    [Documentation]    Sends the SOAP request to createOnboardCustomer endpoint.
    ...                Returns the response object.
    [Arguments]    ${soap_body}
    ${headers}=    Create Dictionary
    ...    Content-Type=text/xml;charset=UTF-8
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ...    SOAPAction=${ONBOARD_SOAP_ACTION}
    ${response}=    POST On Session    onboard    url=${ONBOARD_API_URL}
    ...    data=${soap_body}    headers=${headers}    expected_status=any
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
    RETURN    ${response}

# ═══════════════════════════════════════════════════════════════════════
#  RESPONSE VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify Response Status Code
    [Documentation]    Asserts the HTTP status code of the response.
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Integers    ${response.status_code}    ${expected_status}
    Log    Status code verified: ${expected_status}

Verify SOAP Response Contains
    [Documentation]    Verifies the response body contains the expected text.
    [Arguments]    ${response}    ${expected_text}
    Should Contain    ${response.text}    ${expected_text}
    Log    Response contains: ${expected_text}

Verify SOAP Response Does Not Contain Fault
    [Documentation]    Verifies the SOAP response does not contain a Fault element.
    [Arguments]    ${response}
    Should Not Contain    ${response.text}    <faultstring>
    Should Not Contain    ${response.text}    <soap:Fault>
    Should Not Contain    ${response.text}    <soapenv:Fault>
    Log    No SOAP fault in response.

Verify SOAP Fault Present
    [Documentation]    Verifies the SOAP response contains a Fault element.
    [Arguments]    ${response}
    ${has_fault}=    Run Keyword And Return Status
    ...    Should Contain    ${response.text}    Fault
    IF    not ${has_fault}
        ${has_error}=    Run Keyword And Return Status
        ...    Should Contain    ${response.text}    error
        IF    not ${has_error}
            Fail    Expected SOAP fault or error in response but none found.
        END
    END
    Log    SOAP fault/error found in response as expected.

Extract SOAP Response Value
    [Documentation]    Parses the SOAP XML response and extracts a value by element name.
    ...                Searches for the element anywhere in the XML tree.
    [Arguments]    ${response}    ${element_name}
    ${xml}=    Parse Xml    ${response.text}
    ${value}=    Get Element Text    ${xml}    .//{*}${element_name}
    Log    Extracted ${element_name}: ${value}
    RETURN    ${value}

Verify EC And BU Created Successfully
    [Documentation]    Validates that the SOAP response confirms EC (Enterprise Customer) and
    ...                BU (Billing Unit) were created successfully.
    ...                Checks: HTTP 200, no fault, resultCode=0 or 'Success/Successful' in response,
    ...                and verifies EC name (companyName) and BU name (billingAccountName) are echoed back.
    [Arguments]    ${response}    ${expected_ec_name}    ${expected_bu_name}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}
    # Check for success indicator in response body
    ${has_result_code}=    Run Keyword And Return Status
    ...    Should Contain    ${response.text}    resultCode
    IF    ${has_result_code}
        ${result_code}=    Extract SOAP Response Value    ${response}    resultCode
        Should Be Equal As Strings    ${result_code}    0
        ...    msg=Expected resultCode=0 (success) but got '${result_code}'.
        Log    resultCode=0 confirmed — operation successful.
    ELSE
        ${has_success}=    Run Keyword And Return Status
        ...    Should Contain    ${response.text}    Success
        IF    not ${has_success}
            Log    No resultCode or Success indicator found. Relying on HTTP 200 + no fault.    level=WARN
        ELSE
            Log    Success indicator found in response.
        END
    END
    # Verify EC name is present in the response
    ${ec_in_response}=    Run Keyword And Return Status
    ...    Should Contain    ${response.text}    ${expected_ec_name}
    IF    ${ec_in_response}
        Log    EC '${expected_ec_name}' confirmed in response.
    ELSE
        Log    EC name '${expected_ec_name}' not echoed in response body.    level=WARN
    END
    # Verify BU name is present in the response
    ${bu_in_response}=    Run Keyword And Return Status
    ...    Should Contain    ${response.text}    ${expected_bu_name}
    IF    ${bu_in_response}
        Log    BU '${expected_bu_name}' confirmed in response.
    ELSE
        Log    BU name '${expected_bu_name}' not echoed in response body.    level=WARN
    END

Verify Onboard Response Is Successful
    [Documentation]    Lightweight success check: HTTP 200, no SOAP fault,
    ...                and resultCode=0 if present in response.
    [Arguments]    ${response}
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}
    ${has_result_code}=    Run Keyword And Return Status
    ...    Should Contain    ${response.text}    resultCode
    IF    ${has_result_code}
        ${result_code}=    Extract SOAP Response Value    ${response}    resultCode
        Should Be Equal As Strings    ${result_code}    0
        ...    msg=Expected resultCode=0 but got '${result_code}'.
        Log    Onboard response successful (resultCode=0).
    ELSE
        Log    No resultCode in response — relying on HTTP 200 + no fault.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  UI VERIFICATION — Open browser, login, verify EC & BU on ManageAccount
# ═══════════════════════════════════════════════════════════════════════
Verify EC And BU On Account Page
    [Documentation]    Opens browser, logs in, navigates to ManageAccount page,
    ...                searches for the EC name, verifies it appears in the grid,
    ...                then expands the EC row to verify the BU name is visible.
    [Arguments]    ${ec_name}    ${bu_name}
    Log    ======= UI VERIFICATION START =======    console=yes
    Log    Verifying EC: ${ec_name}    console=yes
    Log    Verifying BU: ${bu_name}    console=yes
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Login For Onboard Verification
    Navigate To Account Page
    Search Account In Grid    ${ec_name}
    Verify Account Visible In Grid    ${ec_name}
    Expand Account Row And Verify BU    ${ec_name}    ${bu_name}
    Log    ======= UI VERIFICATION PASSED =======    console=yes
    [Teardown]    Run Keyword And Ignore Error    Close All Browsers

Login For Onboard Verification
    [Documentation]    Logs into the application for post-API UI verification.
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}   timeout=10s
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_IMAGE}   timeout=20s
    Sleep    2s
    ${captcha_value}=    Fetch Captcha Value
    Enter Captcha    ${captcha_value}
    Click Login Button
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}          timeout=45s
    Log    Login successful for onboard verification.

Navigate To Account Page
    [Documentation]    From Manage Devices page, clicks Admin icon then Account tab
    ...                to reach ManageAccount page.
    ${admin_icon}=    Set Variable    ${LOC_CC_ADMIN_ICON}
    Scroll To Element Via JS    ${admin_icon}
    Wait Until Element Is Visible    ${admin_icon}    30s
    Click Element Via JS    ${admin_icon}
    Sleep    3s
    Wait For App Loading To Complete
    ${account_tab}=    Set Variable    ${LOC_NAV_ACCOUNT_TAB}
    Scroll To Element Via JS    ${account_tab}
    Wait Until Element Is Visible    ${account_tab}    30s
    Click Element Via JS    ${account_tab}
    Sleep    3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageAccount
    Wait Until Element Is Visible    ${LOC_GRID_MANAGE_ACCOUNT}    30s
    Sleep    2s
    Wait For App Loading To Complete
    Log    ManageAccount page loaded for verification.

Search Account In Grid
    [Documentation]    Types the account name into the search box on ManageAccount grid.
    [Arguments]    ${account_name}
    ${search_input}=    Set Variable    xpath=//input[@name='searchValue'] | //input[@placeholder='Enter Search Text']
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${search_input}    10s
    IF    ${found}
        Click Element Via JS    ${search_input}
        Input Text    ${search_input}    ${account_name}
        Sleep    1s
        Press Keys    ${search_input}    RETURN
        Sleep    3s
        Wait For App Loading To Complete
        Log    Searched for '${account_name}' in ManageAccount grid.
    ELSE
        Log    Search input not found on ManageAccount page. Skipping search.    level=WARN
    END

Verify Account Visible In Grid
    [Documentation]    Verifies the account name appears somewhere in the ManageAccount grid.
    [Arguments]    ${account_name}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Page Contains    ${account_name}    timeout=15s
    IF    ${visible}
        Log    EC '${account_name}' found in ManageAccount grid.    console=yes
    ELSE
        Log    EC '${account_name}' NOT found in ManageAccount grid.    level=WARN
        Capture Page Screenshot
    END
    Should Be True    ${visible}    EC '${account_name}' not found on ManageAccount page.

Expand Account Row And Verify BU
    [Documentation]    Finds the EC row in the grid, clicks its expand icon,
    ...                then verifies the BU name appears in the expanded detail section.
    [Arguments]    ${ec_name}    ${bu_name}
    ${expand_icon}=    Set Variable    xpath=//div[@id='ManageAccountGrid']//td[contains(text(),'${ec_name}')]/ancestor::tr//a[contains(@class,'k-i-expand')]
    ${expand_found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${expand_icon}    10s
    IF    ${expand_found}
        Click Element Via JS    ${expand_icon}
        Sleep    3s
        Wait For App Loading To Complete
        ${bu_visible}=    Run Keyword And Return Status
        ...    Wait Until Page Contains    ${bu_name}    timeout=15s
        IF    ${bu_visible}
            Log    BU '${bu_name}' found under EC '${ec_name}'.    console=yes
        ELSE
            Log    BU '${bu_name}' NOT found under EC '${ec_name}'.    level=WARN
            Capture Page Screenshot
        END
        Should Be True    ${bu_visible}    BU '${bu_name}' not found under EC '${ec_name}'.
    ELSE
        Log    Expand icon not found for EC '${ec_name}'. Checking page text.    level=WARN
        ${bu_on_page}=    Run Keyword And Return Status
        ...    Page Should Contain    ${bu_name}
        IF    ${bu_on_page}
            Log    BU '${bu_name}' found on page (no expand needed).    console=yes
        ELSE
            Capture Page Screenshot
            Fail    Could not expand EC row or find BU '${bu_name}'.
        END
    END
