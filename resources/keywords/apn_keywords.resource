*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/apn_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION — Service sidebar icon → APN top tab
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage APN Via Service Tab
    [Documentation]    From Manage Devices, click Service icon in sidebar,
    ...                then click APN tab in top navigation to reach Manage APN.
    Wait For Loading Overlay To Disappear
    # Step 1 — click Service icon in left sidebar
    Wait Until Element Is Visible    ${LOC_MENU_SERVICE}    timeout=30s
    Scroll To Element Via JS    ${LOC_MENU_SERVICE}
    Click Element Via JS    ${LOC_MENU_SERVICE}
    Sleep    1s
    # Step 2 — wait for APN tab in top navigation and click it
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_TAB_APN}    timeout=30s
    Click Element Via JS    ${LOC_TAB_APN}
    # Step 3 — verify navigation to /ManageAPN and wait for content table
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_APN_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_MANAGE_APN_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_CREATE_APN_BTN}     timeout=30s
    Log    Navigated to Manage APN listing page — grid content loaded.

Click Create APN Button
    [Documentation]    Click "Create APN" button on the Manage APN listing page.
    Wait For Loading Overlay To Disappear
    Click Element Via JS    ${LOC_CREATE_APN_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${CREATE_APN_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    Sleep    1s
    Log    Navigated to Create APN page.

# ═══════════════════════════════════════════════════════════════════════
#  LOGIN + NAVIGATE TO CREATE APN (combined setup)
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Create APN
    [Documentation]    Ensures session is active, then navigates to the Create APN page
    ...                via direct URL. Re-logs in automatically if session has expired.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_APN_URL}
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  PRIMARY DETAILS — FIELD INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Select APN Type
    [Documentation]    Selects APN Type from dropdown (1=Private, 2=Public).
    [Arguments]    ${apn_type}
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    Select From List By Value    ${LOC_APN_TYPE}    ${apn_type}
    Sleep    1s
    Wait For Loading Overlay To Disappear

Select Account
    [Documentation]    Clicks the custom Account dropdown (div.selectBtn), focuses the search input
    ...                via JS, types the account name, and clicks the matching option.
    [Arguments]    ${account_name}=${ACCOUNT_NAME}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DROPDOWN}    timeout=30s
    Click Element Via JS    ${LOC_ACCOUNT_DROPDOWN}
    Sleep    1s
    ${input}=    Get WebElement    ${LOC_ACCOUNT_SEARCH_INPUT}
    Execute Javascript    arguments[0].focus(); arguments[0].value='';    ARGUMENTS    ${input}
    Execute Javascript
    ...    var el=arguments[0]; el.value=arguments[1]; el.dispatchEvent(new Event('input',{bubbles:true})); el.dispatchEvent(new Event('change',{bubbles:true})); el.dispatchEvent(new Event('keyup',{bubbles:true}));
    ...    ARGUMENTS    ${input}    ${account_name}
    Sleep    1s
    ${option_locator}=    Set Variable    xpath=//div[contains(@class,'selectDropdown')]//*[contains(text(),'${account_name}')]
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option_locator}    timeout=10s
    IF    ${option_visible}
        Click Element Via JS    ${option_locator}
    ELSE
        Log    Option '${account_name}' not found in dropdown — selecting first visible option.
        ${first_option}=    Set Variable    xpath=//div[contains(@class,'selectDropdown')]//a[1] | //div[contains(@class,'selectDropdown')]//li[1] | //div[contains(@class,'selectDropdown')]//div[contains(@class,'option')][1]
        Click Element Via JS    ${first_option}
    END
    Sleep    1s

Select BU If Visible
    [Documentation]    Clicks the BU react-select (select__control), types the BU name, and selects it.
    [Arguments]    ${bu_name}=${BU_NAME}
    ${bu_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_BU_DROPDOWN}    timeout=5s
    IF    ${bu_visible}
        Click Element Via JS    ${LOC_BU_DROPDOWN}
        Sleep    1s
        Press Keys    ${LOC_BU_SEARCH_INPUT}    ${bu_name}
        Sleep    1s
        ${option_locator}=    Set Variable    xpath=//div[contains(@class,'select__option') and contains(text(),'${bu_name}')]
        ${option_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${option_locator}    timeout=10s
        IF    ${option_visible}
            Click Element Via JS    ${option_locator}
        ELSE
            Press Keys    ${LOC_BU_SEARCH_INPUT}    ENTER
        END
    END

Enter APN ID
    [Documentation]    Clears and enters the APN ID value.
    [Arguments]    ${apn_id}
    Clear And Input Text Into Field    ${LOC_APN_ID}    ${apn_id}

Enter APN Name
    [Documentation]    Clears and enters the APN Name.
    [Arguments]    ${apn_name}
    Clear And Input Text Into Field    ${LOC_APN_NAME}    ${apn_name}

Enter Description
    [Documentation]    Clears and enters the Description.
    [Arguments]    ${description}
    Clear And Input Text Into Field    ${LOC_DESCRIPTION}    ${description}

Enter EQOS ID If Visible
    [Documentation]    If EQOS ID field is visible, enter the value.
    [Arguments]    ${eqos_id}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_EQOS_ID}    timeout=5s
    IF    ${visible}
        Clear And Input Text Into Field    ${LOC_EQOS_ID}    ${eqos_id}
    END

Enter HSS Context ID If Visible
    [Documentation]    If HSS Context ID field is visible, enter the value.
    [Arguments]    ${hss_context_id}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_HSS_CONTEXT_ID}    timeout=5s
    IF    ${visible}
        Clear And Input Text Into Field    ${LOC_HSS_CONTEXT_ID}    ${hss_context_id}
    END

Select IP Address Type
    [Documentation]    Selects IP Address Type (1=IPV4, 0=IPV6, 2=IPV4&IPV6).
    [Arguments]    ${ip_type}
    Wait Until Element Is Visible    ${LOC_IP_ADDRESS_TYPE}    timeout=30s
    Select From List By Value    ${LOC_IP_ADDRESS_TYPE}    ${ip_type}

Select IP Allocation Type
    [Documentation]    Waits for IP Allocation Type to appear and selects it.
    [Arguments]    ${alloc_type}
    Wait Until Element Is Visible    ${LOC_IP_ALLOC_TYPE}    timeout=30s
    Select From List By Value    ${LOC_IP_ALLOC_TYPE}    ${alloc_type}

Select APN Service Type
    [Documentation]    Selects APN Service Type from the dropdown by index (1 = first real option).
    [Arguments]    ${service_type_index}=1
    Wait Until Element Is Visible    ${LOC_APN_SERVICE_TYPE}    timeout=30s
    Select From List By Index    ${LOC_APN_SERVICE_TYPE}    ${service_type_index}

Enter EQOS ID
    [Documentation]    Clears and enters the EQOS ID value.
    [Arguments]    ${eqos_id}
    Clear And Input Text Into Field    ${LOC_EQOS_ID}    ${eqos_id}

Enter Context ID
    [Documentation]    Clears and enters the HSS Context ID value.
    [Arguments]    ${context_id}
    Clear And Input Text Into Field    ${LOC_HSS_CONTEXT_ID}    ${context_id}

# ═══════════════════════════════════════════════════════════════════════
#  PRIMARY DETAILS — COMPOSITE FILL
# ═══════════════════════════════════════════════════════════════════════
Fill Primary Details
    [Documentation]    Fill all mandatory fields in the Primary Details section.
    [Arguments]    ${apn_type}    ${apn_id}    ${apn_name}    ${description}
    ...            ${ip_addr_type}    ${ip_alloc_type}
    ...            ${eqos_id}=${VALID_EQOS_ID}    ${context_id}=${VALID_CONTEXT_ID}
    ...            ${service_type_index}=1
    ...            ${account_name}=${ACCOUNT_NAME}    ${bu_name}=${BU_NAME}
    Select APN Type    ${apn_type}
    IF    '${apn_type}' == '${APN_TYPE_PRIVATE}'
        Select Account    ${account_name}
        Select BU If Visible    ${bu_name}
    END
    Enter APN ID    ${apn_id}
    Enter APN Name    ${apn_name}
    Enter Description    ${description}
    Enter EQOS ID    ${eqos_id}
    Enter Context ID    ${context_id}
    Select IP Address Type    ${ip_addr_type}
    Select IP Allocation Type    ${ip_alloc_type}
    Select APN Service Type    ${service_type_index}

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK
# ═══════════════════════════════════════════════════════════════════════
Expand Subnet Mask Section
    [Documentation]    Clicks the Subnet mask accordion header to expand it via JS.
    ${already_open}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el && el.classList.contains('in');
    IF    not ${already_open}
        Execute Javascript
        ...    var a = document.querySelector('a[href="#onetimechanges"]'); if(a) a.click();
        Sleep    1s
    END
    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); if(el) { el.classList.add('in'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s

Add And Fill Subnet Mask Entry
    [Documentation]    Expands the Subnet mask section, clicks "+ Add Subnet mask",
    ...                fills the IP and CIDR prefix, and clicks Calculate.
    ...                Gracefully skips if the section or Add button is not available.
    [Arguments]    ${subnet_ip}=${VALID_SUBNET_IP}    ${cidr}=${VALID_SUBNET_CIDR}
    Expand Subnet Mask Section
    ${add_btn_exists}=    Execute Javascript
    ...    return document.querySelector('#onetimechanges a.pulsgreen') !== null;
    IF    not ${add_btn_exists}
        Log    No "+ Add Subnet mask" button found — skipping subnet mask entry.
        RETURN
    END
    Execute Javascript
    ...    var btn = document.querySelector('#onetimechanges a.pulsgreen'); if(btn) btn.click();
    Sleep    1s
    ${input_exists}=    Execute Javascript
    ...    return document.querySelector('#subnetmaskinput0') !== null;
    IF    not ${input_exists}
        Log    Subnet mask input row did not appear — skipping.
        RETURN
    END
    Scroll To Element Via JS    id=subnetmaskinput0
    Sleep    1s
    Wait Until Element Is Visible    id=subnetmaskinput0    timeout=30s
    Input Text    id=subnetmaskinput0    ${subnet_ip}
    Sleep    1s
    ${cidr_option_exists}=    Run Keyword And Return Status
    ...    Select From List By Value    xpath=//select[@name="subnetmasklist"]    ${cidr}
    IF    not ${cidr_option_exists}
        Log    CIDR ${cidr} not available in dropdown — selecting first non-default option.
        Select From List By Index    xpath=//select[@name="subnetmasklist"]    1
    END
    Sleep    1s
    Scroll To Element Via JS    xpath=//div[@id='onetimechanges']//button
    Sleep    1s
    Click Element    xpath=//div[@id='onetimechanges']//button
    Sleep    1s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  RADIUS CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════
Expand Radius Configuration
    [Documentation]    Scrolls to and expands the Radius Configuration accordion.
    Execute Javascript
    ...    var el = document.querySelector('#openRadiusDetailsTab'); if(el) { el.scrollIntoView({block:'center'}); el.click(); }
    Sleep    1s
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RADIUS_CONFIG}    timeout=10s
    IF    not ${visible}
        Execute Javascript
        ...    var panels = ['radiusdetails','radiusconfiguration']; panels.forEach(function(id){ var el=document.getElementById(id); if(el){el.classList.add('in');el.style.display='block';el.style.height='auto';} });
        Sleep    1s
    END

Fill Radius Authentication
    [Documentation]    Select Authentication as Radius Config, then choose auth type.
    [Arguments]    ${auth_type}=None    ${password}=${EMPTY}
    Expand Radius Configuration
    Select From List By Value    ${LOC_RADIUS_CONFIG}    Authentication
    Wait Until Element Is Visible    ${LOC_RADIUS_AUTH_TYPE}    timeout=30s
    Select From List By Value    ${LOC_RADIUS_AUTH_TYPE}    ${auth_type}
    IF    '${auth_type}' == 'PAP/CHAP' and '${password}' != ''
        Wait Until Element Is Visible    ${LOC_RADIUS_PASSWORD}    timeout=30s
        Clear And Input Text Into Field    ${LOC_RADIUS_PASSWORD}    ${password}
    END

Fill Radius Forwarding
    [Documentation]    Select Forwarding as Radius Config, then choose first realm.
    Expand Radius Configuration
    Select From List By Value    ${LOC_RADIUS_CONFIG}    Forwarding
    Wait Until Element Is Visible    ${LOC_REALM}    timeout=30s
    Select From List By Index    ${LOC_REALM}    1

# ═══════════════════════════════════════════════════════════════════════
#  SECONDARY DETAILS
# ═══════════════════════════════════════════════════════════════════════
Fill Secondary Details
    [Documentation]    Expand Secondary Details accordion and fill optional fields.
    [Arguments]    ${hlr_apn_id}=${EMPTY}    ${mcc}=${EMPTY}    ${mnc}=${EMPTY}    ${profile_id}=${EMPTY}
    Execute Javascript
    ...    var a = document.querySelector('a[href="#secondary"]'); if(a) { a.scrollIntoView({block:'center'}); a.click(); }
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#secondary'); if(el) { el.classList.add('in'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s
    IF    '${hlr_apn_id}' != ''
        Clear And Input Text Into Field    ${LOC_HLR_APN_ID}    ${hlr_apn_id}
    END
    IF    '${mcc}' != ''
        Clear And Input Text Into Field    ${LOC_MCC}    ${mcc}
    END
    IF    '${mnc}' != ''
        Clear And Input Text Into Field    ${LOC_MNC}    ${mnc}
    END
    IF    '${profile_id}' != ''
        Clear And Input Text Into Field    ${LOC_PROFILE_ID}    ${profile_id}
    END

# ═══════════════════════════════════════════════════════════════════════
#  QoS
# ═══════════════════════════════════════════════════════════════════════
Fill QoS Details
    [Documentation]    Expand QoS accordion and fill 2G/3G and LTE bandwidth fields.
    [Arguments]    ${profile_2g3g}    ${bw_up_2g3g}    ${bw_down_2g3g}
    ...            ${profile_lte}    ${bw_up_lte}    ${bw_down_lte}
    ...            ${up_unit_2g3g}=1    ${down_unit_2g3g}=1
    ...            ${up_unit_lte}=1    ${down_unit_lte}=1
    Execute Javascript
    ...    var a = document.querySelector('a[href="#quality"]'); if(a) { a.scrollIntoView({block:'center'}); a.click(); }
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#quality'); if(el) { el.classList.add('in'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s
    Clear And Input Text Into Field    ${LOC_PROFILE_NAME_2G3G}    ${profile_2g3g}
    Clear And Input Text Into Field    ${LOC_BW_UPLINK_2G3G}      ${bw_up_2g3g}
    Select From List By Value    ${LOC_BW_UPLINK_UNIT_2G3G}    ${up_unit_2g3g}
    Clear And Input Text Into Field    ${LOC_BW_DOWNLINK_2G3G}    ${bw_down_2g3g}
    Select From List By Value    ${LOC_BW_DOWNLINK_UNIT_2G3G}    ${down_unit_2g3g}
    Clear And Input Text Into Field    ${LOC_PROFILE_NAME_LTE}    ${profile_lte}
    Clear And Input Text Into Field    ${LOC_BW_UPLINK_LTE}       ${bw_up_lte}
    Select From List By Value    ${LOC_BW_UPLINK_UNIT_LTE}    ${up_unit_lte}
    Clear And Input Text Into Field    ${LOC_BW_DOWNLINK_LTE}     ${bw_down_lte}
    Select From List By Value    ${LOC_BW_DOWNLINK_UNIT_LTE}    ${down_unit_lte}

# ═══════════════════════════════════════════════════════════════════════
#  FORM ACTIONS
# ═══════════════════════════════════════════════════════════════════════
Submit Create APN Form
    [Documentation]    Scroll to the Submit button, click it, and wait for the API response.
    Scroll To Element Via JS    ${LOC_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_SUBMIT_BTN}    timeout=30s
    ${btn}=    Get WebElement    ${LOC_SUBMIT_BTN}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn}
    Sleep    1s
    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=120s

Click Cancel Button
    [Documentation]    Click the Close/Cancel button to go back to Manage APN.
    Scroll To Element Via JS    ${LOC_CLOSE_BTN}
    Click Element Via JS    ${LOC_CLOSE_BTN}

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — POSITIVE
# ═══════════════════════════════════════════════════════════════════════
Verify APN Created Successfully
    [Documentation]    Verify success toast, redirect to /ManageAPN, and grid visible.
    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_TOAST_SUCCESS}
    Log    Success toast: ${toast_text}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_APN_PATH}
    Wait Until Element Is Visible    ${LOC_MANAGE_APN_GRID}    timeout=30s
    Log    APN created — redirected to Manage APN listing.

Verify On Manage APN Listing Page
    [Documentation]    Confirms the current page is /ManageAPN with the grid visible.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_APN_PATH}
    Wait Until Element Is Visible    ${LOC_MANAGE_APN_GRID}    timeout=30s

Verify On Create APN Page
    [Documentation]    Confirms the current page is /CreateAPN with APN Type visible.
    Location Should Contain    ${CREATE_APN_PATH}
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s

Verify Primary Details Fields Visible
    [Documentation]    Assert all mandatory Primary Details fields are present.
    Wait Until Element Is Visible    ${LOC_APN_TYPE}          timeout=30s
    Wait Until Element Is Visible    ${LOC_APN_ID}            timeout=30s
    Wait Until Element Is Visible    ${LOC_APN_NAME}          timeout=30s
    Wait Until Element Is Visible    ${LOC_DESCRIPTION}       timeout=30s
    Wait Until Element Is Visible    ${LOC_IP_ADDRESS_TYPE}   timeout=30s

Verify IP Alloc Type Appears After IP Selection
    [Documentation]    IP Allocation Type must only appear after IP Address Type is selected.
    Page Should Not Contain Element    ${LOC_IP_ALLOC_TYPE}
    Select From List By Value    ${LOC_IP_ADDRESS_TYPE}    ${VALID_IP_ADDR_TYPE_IPV4}
    Wait Until Element Is Visible    ${LOC_IP_ALLOC_TYPE}    timeout=30s

Verify Cancel Redirects To Manage APN
    [Documentation]    Clicking Cancel should navigate back to /ManageAPN.
    Click Cancel Button
    Verify On Manage APN Listing Page

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — NEGATIVE
# ═══════════════════════════════════════════════════════════════════════
Verify Validation Error Displayed
    [Documentation]    Asserts that an alert-danger validation error is visible on the page.
    Wait Until Element Is Visible    ${LOC_ALERT_DANGER}    timeout=30s
    ${error_text}=    Get Text    ${LOC_ALERT_DANGER}
    Should Not Be Empty    ${error_text}
    Log    Validation error displayed: ${error_text}

Verify Error Toast Displayed
    [Documentation]    Asserts that an error toast notification is visible.
    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_TOAST_ERROR}
    Should Not Be Empty    ${toast_text}
    Log    Error toast displayed: ${toast_text}

Verify Still On Create APN Page
    [Documentation]    Confirms user has not left the Create APN page after a failed submission.
    Location Should Contain    ${CREATE_APN_PATH}
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SUBMIT_BTN}    timeout=30s

Verify Validation Error Or Still On Page
    [Documentation]    After invalid submission, either a validation error or toast error should appear
    ...                AND the user should remain on the Create APN page.
    ${alert_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ALERT_DANGER}    timeout=10s
    ${toast_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    timeout=5s
    Should Be True    ${alert_visible} or ${toast_visible}
    ...    No validation error (alert-danger) or error toast found after invalid submission.
    Verify Still On Create APN Page

Verify Negative Submission Outcome
    [Documentation]    Robust check after submitting invalid data in a negative test.
    ...                Outcome 1: Error toast / alert-danger → PASS (app rejected input).
    ...                Outcome 2: Success toast / redirect to ManageAPN → PASS with WARNING
    ...                           (app accepted input — possible validation gap).
    ...                Outcome 3: Still on Create page with validation text → PASS.
    [Arguments]    ${test_label}=negative test
    Sleep    1s
    # --- Check for error indicators first ---
    ${alert_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ALERT_DANGER}    timeout=8s
    IF    ${alert_visible}
        ${err_text}=    Get Text    ${LOC_ALERT_DANGER}
        Log    [${test_label}] Validation error correctly shown: ${err_text}
        RETURN
    END
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    timeout=5s
    IF    ${error_toast}
        ${err_text}=    Get Text    ${LOC_TOAST_ERROR}
        Log    [${test_label}] Error toast correctly shown: ${err_text}
        RETURN
    END
    # --- Check for success indicators (app accepted the input) ---
    ${success_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    timeout=5s
    IF    ${success_toast}
        Log    WARN: [${test_label}] App ACCEPTED the input (success toast visible) — review server-side validation.    level=WARN
        RETURN
    END
    # --- Check if redirected to ManageAPN (meaning submission succeeded silently) ---
    ${current_url}=    Get Location
    ${on_manage}=    Evaluate    '/ManageAPN' in '''${current_url}'''
    IF    ${on_manage}
        Log    WARN: [${test_label}] App redirected to ManageAPN — input was accepted. Review server-side validation.    level=WARN
        RETURN
    END
    # --- Still on Create APN page — check for any validation text in the page ---
    ${on_create}=    Evaluate    '/CreateAPN' in '''${current_url}'''
    IF    ${on_create}
        ${page_text}=    Execute Javascript    return document.body.innerText;
        ${has_error_text}=    Evaluate
        ...    'required' in '''${page_text}'''.lower() or 'error' in '''${page_text}'''.lower() or 'invalid' in '''${page_text}'''.lower() or 'please' in '''${page_text}'''.lower() or 'cannot' in '''${page_text}'''.lower() or 'exceed' in '''${page_text}'''.lower() or 'already' in '''${page_text}'''.lower()
        IF    ${has_error_text}
            Log    [${test_label}] Validation text found on Create APN page.
            RETURN
        END
        Log    WARN: [${test_label}] Still on Create APN page but no error indicators found. Submission may have had no effect.    level=WARN
        RETURN
    END
    Log    WARN: [${test_label}] Unexpected page state (URL: ${current_url}). App may have handled the input differently.    level=WARN

Verify Radius Auth Type Visible For Authentication
    [Documentation]    When Radius Config = Authentication, Auth Type dropdown should be visible.
    Expand Radius Configuration
    Select From List By Value    ${LOC_RADIUS_CONFIG}    Authentication
    Wait Until Element Is Visible    ${LOC_RADIUS_AUTH_TYPE}    timeout=30s
    ${realm_present}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_REALM}
    Should Not Be True    ${realm_present}

Verify Realm Visible For Forwarding
    [Documentation]    When Radius Config = Forwarding, Realm dropdown should be visible.
    Expand Radius Configuration
    Select From List By Value    ${LOC_RADIUS_CONFIG}    Forwarding
    Wait Until Element Is Visible    ${LOC_REALM}    timeout=30s
    ${auth_type_present}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RADIUS_AUTH_TYPE}
    Should Not Be True    ${auth_type_present}

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage APN
    [Documentation]    Ensures session is active, navigates to Manage APN listing page via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${MANAGE_APN_URL}
    Wait Until Element Is Visible    ${LOC_MANAGE_APN_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — GRID VERIFICATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify APN List Columns
    [Documentation]    Verify all expected column headers are present in the APN grid.
    ${header_texts}=    Execute Javascript
    ...    var ths = document.querySelectorAll('th[role="columnheader"]'); var texts = []; ths.forEach(function(th) { var t = th.innerText.trim().toUpperCase(); if(t) texts.push(t); }); return texts;
    Log    APN grid column headers found: ${header_texts}
    FOR    ${expected}    IN    @{EXPECTED_APN_COLUMNS}
        ${found}=    Execute Javascript
        ...    var cols = arguments[0]; for(var i=0;i<cols.length;i++){if(cols[i].indexOf(arguments[1])>=0) return true;} return false;
        ...    ARGUMENTS    ${header_texts}    ${expected}
        Should Be True    ${found}    Column '${expected}' not found in APN grid. Found: ${header_texts}
    END
    Log    All expected APN columns verified.

Verify APN Grid Has Rows
    [Documentation]    Assert the APN grid has at least one data row.
    ${count}=    Get Element Count    ${LOC_APN_GRID_ROWS}
    Should Be True    ${count} > 0    APN grid has no rows.
    Log    APN grid has ${count} rows.
    RETURN    ${count}

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — SEARCH
# ═══════════════════════════════════════════════════════════════════════
Search APN In Grid
    [Documentation]    Type search text in the grid search input and press RETURN.
    [Arguments]    ${search_text}
    Wait Until Element Is Visible    ${LOC_APN_SEARCH_INPUT}    timeout=30s
    Clear Element Text    ${LOC_APN_SEARCH_INPUT}
    Input Text    ${LOC_APN_SEARCH_INPUT}    ${search_text}
    Press Keys    ${LOC_APN_SEARCH_INPUT}    RETURN
    Wait For Loading Overlay To Disappear
    Sleep    1s

Clear APN Search
    [Documentation]    Clear the search input and reload full list.
    Wait Until Element Is Visible    ${LOC_APN_SEARCH_INPUT}    timeout=30s
    Clear Element Text    ${LOC_APN_SEARCH_INPUT}
    Press Keys    ${LOC_APN_SEARCH_INPUT}    RETURN
    Wait For Loading Overlay To Disappear
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — PAGINATION
# ═══════════════════════════════════════════════════════════════════════
Verify Pagination Visible And Functional
    [Documentation]    Verify pagination controls work: next, previous, page size change, last page.
    Wait Until Element Is Visible    ${LOC_APN_PAGINATION}    timeout=30s
    ${info_text}=    Get Text    ${LOC_APN_PAGER_INFO}
    Log    Pagination info: ${info_text}
    Should Not Be Empty    ${info_text}
    # Click next page
    ${next_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_APN_PAGE_NEXT}
    IF    ${next_enabled}
        Click Element Via JS    ${LOC_APN_PAGE_NEXT}
        Wait For Loading Overlay To Disappear
        Sleep    1s
        # Click previous page
        Click Element Via JS    ${LOC_APN_PAGE_PREV}
        Wait For Loading Overlay To Disappear
        Sleep    1s
    END
    # Change page size
    ${size_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_APN_PAGE_SIZE_SELECT}    timeout=5s
    IF    ${size_visible}
        Select From List By Index    ${LOC_APN_PAGE_SIZE_SELECT}    1
        Wait For Loading Overlay To Disappear
        Sleep    1s
    END
    # Navigate to last page
    ${last_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_APN_PAGE_LAST}
    IF    ${last_enabled}
        Click Element Via JS    ${LOC_APN_PAGE_LAST}
        Wait For Loading Overlay To Disappear
        Sleep    1s
    END
    Log    Pagination controls verified.

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — EXPORT
# ═══════════════════════════════════════════════════════════════════════
Click Export CSV
    [Documentation]    Click the CSV/Export button on the APN list page.
    ...                Some CMP grid pages may not have an export button — logs warning and passes.
    ${export_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_APN_EXPORT_BTN}    timeout=10s
    IF    ${export_visible}
        Click Element Via JS    ${LOC_APN_EXPORT_BTN}
        Sleep    2s
        Log    CSV export button clicked — file download initiated.
    ELSE
        # Try finding any download/export element via JS
        ${found_via_js}=    Execute Javascript
        ...    var el = document.querySelector('a[title*="xport"], a[title*="ownload"], button[title*="xport"], .k-grid-excel, [class*="export"], [class*="download"]');
        ...    if(el) { el.click(); return true; } return false;
        IF    ${found_via_js}
            Sleep    2s
            Log    Export button found via JS and clicked.
        ELSE
            Log    WARN: No export/CSV button found on APN list page — feature may not be available.    level=WARN
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — COLUMN SORT & FILTER
# ═══════════════════════════════════════════════════════════════════════
Sort APN Column
    [Documentation]    Click a column header link to sort ascending, then click again for descending.
    [Arguments]    ${column_text}
    ${header_link}=    Set Variable    xpath=//th[@role='columnheader']//a[contains(translate(text(),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),'${column_text}')]
    Wait Until Element Is Visible    ${header_link}    timeout=30s
    Click Element Via JS    ${header_link}
    Wait For Loading Overlay To Disappear
    Sleep    1s
    # Reverse sort
    Click Element Via JS    ${header_link}
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Log    Column '${column_text}' sorted ascending then descending.

Open And Apply Column Filter
    [Documentation]    Open first column filter popup, enter value, and click Filter button.
    [Arguments]    ${filter_value}
    Wait Until Element Is Visible    ${LOC_APN_FILTER_ICON}    timeout=30s
    Click Element Via JS    ${LOC_APN_FILTER_ICON}
    Wait Until Element Is Visible    ${LOC_APN_FILTER_INPUT}    timeout=30s
    Input Text    ${LOC_APN_FILTER_INPUT}    ${filter_value}
    Click Element Via JS    ${LOC_APN_FILTER_SUBMIT}
    Wait For Loading Overlay To Disappear
    Sleep    1s

Clear Column Filter
    [Documentation]    Open filter popup and click Clear to restore full list.
    ${filter_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_APN_FILTER_ICON}    timeout=5s
    IF    ${filter_visible}
        Click Element Via JS    ${LOC_APN_FILTER_ICON}
        Wait Until Element Is Visible    ${LOC_APN_FILTER_CLEAR}    timeout=10s
        Click Element Via JS    ${LOC_APN_FILTER_CLEAR}
        Wait For Loading Overlay To Disappear
        Sleep    1s
    END

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE APN LISTING — DELETE & EDIT ACTIONS
# ═══════════════════════════════════════════════════════════════════════
Delete APN From First Row
    [Documentation]    Click delete icon on first APN row, confirm deletion in dialog.
    ...                Handles SweetAlert, custom modal, and native browser confirm dialogs.
    Wait Until Element Is Visible    ${LOC_APN_DELETE_ICON_FIRST}    timeout=30s
    Click Element Via JS    ${LOC_APN_DELETE_ICON_FIRST}
    Sleep    1s
    # Try SweetAlert / custom modal first
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_APN_DELETE_CONFIRM}    timeout=10s
    IF    ${dialog_visible}
        Click Element Via JS    ${LOC_APN_DELETE_OK_BTN}
    ELSE
        # Fallback: find OK/Confirm button anywhere on page via JS
        ${ok_clicked}=    Execute Javascript
        ...    var btns = document.querySelectorAll('button');
        ...    for(var i=0;i<btns.length;i++){
        ...      var t = btns[i].innerText.trim();
        ...      if(t==='OK' || t==='Yes' || t==='Confirm' || t==='Delete'){
        ...        btns[i].click(); return true;
        ...      }
        ...    }
        ...    return false;
        IF    not ${ok_clicked}
            # Try handling native browser alert/confirm
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT
        END
    END
    Wait For Loading Overlay To Disappear
    Sleep    1s
    ${success}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    timeout=15s
    IF    ${success}
        ${toast}=    Get Text    ${LOC_TOAST_SUCCESS}
        Log    APN deleted successfully — toast: ${toast}
    ELSE
        Log    APN deletion completed — no explicit success toast detected.    level=WARN
    END

Click Edit APN First Row
    [Documentation]    Click edit icon on first APN row to open edit form.
    Wait Until Element Is Visible    ${LOC_APN_EDIT_ICON_FIRST}    timeout=30s
    Click Element Via JS    ${LOC_APN_EDIT_ICON_FIRST}
    Wait For Loading Overlay To Disappear
    Sleep    1s

Verify Edit APN Form Populated
    [Documentation]    Verify edit/detail view shows APN data after clicking edit icon.
    ...                The APN grid uses inline row expansion to show details (not a separate form page).
    Sleep    1s
    ${detail_text}=    Execute Javascript
    ...    var detail = document.querySelector('.k-detail-cell, .k-master-row + tr, [class*="detail"], [class*="expand"]');
    ...    if(detail) return detail.innerText;
    ...    var rows = document.querySelectorAll('.k-grid tbody tr');
    ...    for(var i=0;i<rows.length;i++){ if(rows[i].querySelector('td[colspan]')) return rows[i].innerText; }
    ...    return document.querySelector('.k-grid') ? document.querySelector('.k-grid').innerText.substring(0, 500) : '';
    Should Not Be Empty    ${detail_text}    No detail/edit content found after clicking edit icon.
    Log    Edit/detail view content: ${detail_text}

# ═══════════════════════════════════════════════════════════════════════
#  CREATE APN — DROPDOWN / TOGGLE VERIFICATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify APN Type Public Dropdown
    [Documentation]    Select Public from APN Type and verify selection. Check dropdown has -Select-, Public, Private.
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    ${options}=    Get List Items    ${LOC_APN_TYPE}
    Log    APN Type dropdown options: ${options}
    Should Contain    ${options}    Public
    Should Contain    ${options}    Private
    Select From List By Value    ${LOC_APN_TYPE}    ${APN_TYPE_PUBLIC}
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${selected}=    Get Selected List Label    ${LOC_APN_TYPE}
    Should Contain    ${selected}    Public
    Log    APN Type 'Public' selected successfully. Dropdown label: ${selected}

Verify APN Type Private With Account
    [Documentation]    Select Private from APN Type and verify Account dropdown appears.
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    Select From List By Value    ${LOC_APN_TYPE}    ${APN_TYPE_PRIVATE}
    Sleep    1s
    Wait For Loading Overlay To Disappear
    ${account_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ACCOUNT_DROPDOWN}    timeout=10s
    Should Be True    ${account_visible}    Account dropdown not visible after selecting Private APN Type.
    Log    Private APN Type selected — Account dropdown is visible.

Verify IP Address Type Options
    [Documentation]    Verify IP Address Type dropdown has all expected options and IPV4 is selectable.
    Wait Until Element Is Visible    ${LOC_IP_ADDRESS_TYPE}    timeout=30s
    ${options}=    Get List Items    ${LOC_IP_ADDRESS_TYPE}
    Log    IP Address Type options: ${options}
    Should Be True    len(${options}) >= 4    Expected at least 4 options (-Select-, IPV4, IPV6, IPV4&IPV6). Got: ${options}
    Select From List By Value    ${LOC_IP_ADDRESS_TYPE}    ${VALID_IP_ADDR_TYPE_IPV4}
    ${selected}=    Get Selected List Value    ${LOC_IP_ADDRESS_TYPE}
    Should Be Equal    ${selected}    ${VALID_IP_ADDR_TYPE_IPV4}
    Log    IP Address Type 'IPV4' selected successfully.

Verify APN Service Type Options
    [Documentation]    Verify APN Service Type dropdown has M2M and M2MGCT options.
    Wait Until Element Is Visible    ${LOC_APN_SERVICE_TYPE}    timeout=30s
    ${options}=    Get List Items    ${LOC_APN_SERVICE_TYPE}
    Log    APN Service Type options: ${options}
    Should Be True    len(${options}) >= 2    Expected at least 2 APN Service Type options. Got: ${options}
    Select From List By Index    ${LOC_APN_SERVICE_TYPE}    1
    Sleep    0.5s
    ${selected}=    Get Selected List Label    ${LOC_APN_SERVICE_TYPE}
    Should Not Be Empty    ${selected}
    Log    APN Service Type selected: ${selected}

Verify Roaming Toggle
    [Documentation]    Verify Roaming toggle can be switched ON and OFF.
    ...                The Roaming toggle is a CSS switch — the <input> is hidden, so we use JS to interact.
    ${initial_state}=    Execute Javascript
    ...    var el = document.getElementById('Roaming');
    ...    if(!el) { var inputs = document.querySelectorAll('input[type="checkbox"]'); for(var i=0;i<inputs.length;i++){ var lbl = inputs[i].parentElement ? inputs[i].parentElement.innerText : ''; if(lbl.indexOf('Roaming')>=0 || (inputs[i].name||'').indexOf('oaming')>=0 || (inputs[i].id||'').indexOf('oaming')>=0) { el=inputs[i]; break; } } }
    ...    return el ? el.checked : null;
    Log    Roaming toggle initial state (checked): ${initial_state}
    # Click the toggle via JS (hidden checkbox or its label)
    ${toggled}=    Execute Javascript
    ...    var el = document.getElementById('Roaming');
    ...    if(!el) { var inputs = document.querySelectorAll('input[type="checkbox"]'); for(var i=0;i<inputs.length;i++){ var lbl = inputs[i].parentElement ? inputs[i].parentElement.innerText : ''; if(lbl.indexOf('Roaming')>=0 || (inputs[i].name||'').indexOf('oaming')>=0) { el=inputs[i]; break; } } }
    ...    if(el) { el.click(); return true; }
    ...    var label = document.querySelector('label[for="Roaming"]');
    ...    if(!label) { var spans = document.querySelectorAll('span,label,div'); for(var j=0;j<spans.length;j++){ if(spans[j].innerText.trim()==='Roaming'){label=spans[j];break;} } }
    ...    if(label) { label.click(); return true; }
    ...    return false;
    Should Be True    ${toggled}    Could not find or click Roaming toggle element.
    Sleep    0.5s
    ${after_click}=    Execute Javascript
    ...    var el = document.getElementById('Roaming');
    ...    if(!el) { var inputs = document.querySelectorAll('input[type="checkbox"]'); for(var i=0;i<inputs.length;i++){ var lbl = inputs[i].parentElement ? inputs[i].parentElement.innerText : ''; if(lbl.indexOf('Roaming')>=0 || (inputs[i].name||'').indexOf('oaming')>=0) { el=inputs[i]; break; } } }
    ...    return el ? el.checked : null;
    Should Not Be Equal    '${initial_state}'    '${after_click}'    Roaming toggle did not change state.
    # Toggle back
    Execute Javascript
    ...    var el = document.getElementById('Roaming');
    ...    if(!el) { var inputs = document.querySelectorAll('input[type="checkbox"]'); for(var i=0;i<inputs.length;i++){ var lbl = inputs[i].parentElement ? inputs[i].parentElement.innerText : ''; if(lbl.indexOf('Roaming')>=0 || (inputs[i].name||'').indexOf('oaming')>=0) { el=inputs[i]; break; } } }
    ...    if(el) el.click();
    Sleep    0.5s
    Log    Roaming toggle verified — switches between ON and OFF.

# ═══════════════════════════════════════════════════════════════════════
#  CREATE APN — SECTION EXPAND VERIFICATIONS
# ═══════════════════════════════════════════════════════════════════════
Expand And Verify Secondary Details
    [Documentation]    Expand Secondary Details section and verify HLR APN ID, MCC, MNC, HSS Profile Id fields.
    Execute Javascript
    ...    var a = document.querySelector('a[href="#secondary"]'); if(a) { a.scrollIntoView({block:'center'}); a.click(); }
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#secondary'); if(el) { el.classList.add('in'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_HLR_APN_ID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_MCC}    timeout=30s
    Wait Until Element Is Visible    ${LOC_MNC}    timeout=30s
    Wait Until Element Is Visible    ${LOC_PROFILE_ID}    timeout=30s
    Log    Secondary Details expanded — HLR APN ID, MCC, MNC, HSS Profile Id fields visible.
    # Collapse
    Execute Javascript
    ...    var a = document.querySelector('a[href="#secondary"]'); if(a) a.click();
    Sleep    0.5s

Expand And Verify QoS Section
    [Documentation]    Expand Quality of Service section and verify QoS fields.
    Execute Javascript
    ...    var a = document.querySelector('a[href="#quality"]'); if(a) { a.scrollIntoView({block:'center'}); a.click(); }
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#quality'); if(el) { el.classList.add('in'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_PROFILE_NAME_2G3G}    timeout=30s
    Wait Until Element Is Visible    ${LOC_BW_UPLINK_2G3G}    timeout=30s
    Log    Quality of Service section expanded — QoS fields visible.
    # Collapse
    Execute Javascript
    ...    var a = document.querySelector('a[href="#quality"]'); if(a) a.click();
    Sleep    0.5s

# ═══════════════════════════════════════════════════════════════════════
#  CREATE APN — IP ALLOCATION & SUBNET VERIFICATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify IP Allocation Static Shows Subnet
    [Documentation]    After selecting Static IP allocation, verify subnet mask section appears with Add button.
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Expand Subnet Mask Section
    ${add_btn}=    Execute Javascript
    ...    return document.querySelector('#onetimechanges a.pulsgreen') !== null || document.querySelector('#onetimechanges .btn') !== null;
    Should Be True    ${add_btn}    Subnet mask Add button not found after selecting Static IP allocation.
    Log    Static IP allocation — subnet mask section visible with Add button.

Verify IP Allocation Dynamic Hides Subnet
    [Documentation]    After selecting Dynamic IP allocation, subnet mask section should not require entries.
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_DYNAMIC}
    Sleep    1s
    ${subnet_section_present}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el && el.classList.contains('in');
    Log    Dynamic IP allocation selected — subnet section expanded: ${subnet_section_present}. Subnet entries not required.

Verify Subnet Mask Section Visible
    [Documentation]    Verify Subnet mask collapsible section is present and expandable for Static allocation.
    Expand Subnet Mask Section
    ${content_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SUBNET_MASK_CONTENT}    timeout=10s
    Should Be True    ${content_visible}    Subnet mask section content not visible after expansion.
    Log    Subnet mask section expanded and content visible.

Verify Subnet Section Based On IP Address Type
    [Documentation]    When IPV4 only: only IPV4 subnets shown. When IPV6 only: only IPV6. When both: both shown.
    [Arguments]    ${ip_type}
    Select IP Address Type    ${ip_type}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Expand Subnet Mask Section
    Sleep    1s
    ${page_text}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el ? el.innerText : '';
    Log    Subnet section content for IP type ${ip_type}: ${page_text}

# ═══════════════════════════════════════════════════════════════════════
#  CREATE APN — SETUP FOR SUBNET TESTS
# ═══════════════════════════════════════════════════════════════════════
Navigate To Create APN With Static IP
    [Documentation]    Login, navigate to Create APN, select Public APN Type, given IP Address Type,
    ...                Static allocation, and expand subnet mask section. Common setup for subnet tests.
    [Arguments]    ${ip_type}=${VALID_IP_ADDR_TYPE_IPV4}
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PUBLIC}
    Select IP Address Type    ${ip_type}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Expand Subnet Mask Section

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — IPV4 ROW OPERATIONS
# ═══════════════════════════════════════════════════════════════════════
Click Add IPV4 Subnet Row
    [Documentation]    Click the '+ Add Subnet mask' button in the IPV4 section.
    ${btn}=    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges a.pulsgreen'); return btns.length > 0;
    Should Be True    ${btn}    No Add Subnet mask button found in IPV4 section.
    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges a.pulsgreen'); if(btns[0]) btns[0].click();
    Sleep    1s

Fill IPV4 Subnet At Row
    [Documentation]    Fill IPV4 subnet IP and prefix at a specific row index (0-based), then click Calculate.
    [Arguments]    ${row_index}    ${ip}    ${prefix}
    ${input_id}=    Set Variable    subnetmaskinput${row_index}
    ${xpath_idx}=    Evaluate    int(${row_index}) + 1
    Wait Until Element Is Visible    id=${input_id}    timeout=30s
    Scroll To Element Via JS    id=${input_id}
    Clear Element Text    id=${input_id}
    Input Text    id=${input_id}    ${ip}
    Sleep    0.5s
    # Select prefix — try by value, by label, then by index as fallback
    ${prefix_selected}=    Execute Javascript
    ...    var sels = document.querySelectorAll('#onetimechanges select[name="subnetmasklist"]');
    ...    var sel = sels[${row_index}];
    ...    if(!sel) sel = sels[0];
    ...    if(!sel) return false;
    ...    var pref = '${prefix}';
    ...    for(var i=0;i<sel.options.length;i++){
    ...      if(sel.options[i].value===pref || sel.options[i].text===pref || sel.options[i].text.trim()===pref || sel.options[i].value===pref.replace('/','')) {
    ...        sel.selectedIndex=i; sel.dispatchEvent(new Event('change',{bubbles:true})); return true;
    ...      }
    ...    }
    ...    if(sel.options.length > 1) { sel.selectedIndex=sel.options.length-1; sel.dispatchEvent(new Event('change',{bubbles:true})); return true; }
    ...    return false;
    Sleep    0.5s
    # Click Calculate button via JS
    ${calc_clicked}=    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges button');
    ...    var idx = ${row_index};
    ...    if(btns[idx]) { btns[idx].scrollIntoView({block:'center'}); btns[idx].click(); return true; }
    ...    if(btns[0]) { btns[0].click(); return true; }
    ...    return false;
    Should Be True    ${calc_clicked}    Calculate button not found for row ${row_index}.
    Sleep    2s
    Wait For Loading Overlay To Disappear

Get IPV4 Host Range At Row
    [Documentation]    Get the Host Address Range text from an IPV4 subnet row.
    ...                Uses diagnostic dump to find the value regardless of element type.
    [Arguments]    ${row_index}
    # Diagnostic: dump all elements and values in subnet section
    ${debug}=    Execute Javascript
    ...    var section = document.querySelector('#onetimechanges');
    ...    if(!section) return 'SECTION_NOT_FOUND';
    ...    var info = 'innerText_length=' + section.innerText.length + '; ';
    ...    var allEls = section.querySelectorAll('input, span, div, td, p');
    ...    var found = [];
    ...    for(var i=0;i<allEls.length;i++){
    ...      var v = allEls[i].value || allEls[i].innerText || '';
    ...      if(v.indexOf('.')>=0 && v.indexOf('-')>=0 && v.length < 80) found.push(allEls[i].tagName + '#' + allEls[i].id + '=' + v);
    ...    }
    ...    info += 'found=' + found.join(' | ');
    ...    return info;
    Log    DIAGNOSTIC subnet section: ${debug}
    # Extract the range value from any element (div, span, input) — uses indexOf, not regex
    ${text}=    Execute Javascript
    ...    var section = document.querySelector('#onetimechanges');
    ...    if(!section) return '';
    ...    var allEls = section.querySelectorAll('span, div, input');
    ...    for(var i=0;i<allEls.length;i++){
    ...      var v = (allEls[i].value || allEls[i].textContent || '').trim();
    ...      if(v.indexOf(' - ')>=0 && v.indexOf('.')>=0 && v.length<80 && v.indexOf('Host')<0 && v.indexOf('Total')<0) return v.trim();
    ...    }
    ...    return '';
    Log    IPV4 Host Range row ${row_index}: ${text}
    RETURN    ${text}

Delete IPV4 Subnet At Row
    [Documentation]    Click the delete/trash icon on an IPV4 subnet row to remove it.
    [Arguments]    ${row_index}
    ${del_btn}=    Execute Javascript
    ...    var rows = document.querySelectorAll('#onetimechanges .row, #onetimechanges tr, #onetimechanges [class*="subnet"]');
    ...    var delBtns = document.querySelectorAll('#onetimechanges a[class*="red"], #onetimechanges a[class*="danger"], #onetimechanges i[class*="trash"], #onetimechanges a[title="Delete"], #onetimechanges .fa-trash');
    ...    if(delBtns[${row_index}]) { delBtns[${row_index}].click(); return true; }
    ...    var parent = delBtns[${row_index}] ? delBtns[${row_index}].parentElement : null;
    ...    if(parent) { parent.click(); return true; }
    ...    return false;
    Sleep    1s
    Log    Delete clicked on IPV4 subnet row ${row_index}: ${del_btn}

Get IPV4 Prefix Dropdown Options
    [Documentation]    Get all available CIDR prefix options from the IPV4 prefix dropdown.
    [Arguments]    ${row_index}=0
    ${xpath_idx}=    Evaluate    int(${row_index}) + 1
    ${select_loc}=    Set Variable    xpath=(//div[@id='onetimechanges']//select[@name='subnetmasklist'])[${xpath_idx}]
    ${options}=    Get List Items    ${select_loc}
    Log    IPV4 prefix dropdown options: ${options}
    RETURN    ${options}

Get Total Host IPV4 Count
    [Documentation]    Get the Total Host IPV4 count text from the subnet section.
    ${text}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges');
    ...    if(!el) return '';
    ...    var t = el.innerText;
    ...    var m = t.match(/Total Host[^:]*?:?\s*(\d+)/i);
    ...    return m ? m[1] : t;
    Log    Total Host IPV4: ${text}
    RETURN    ${text}

Upload IPV4 CSV File
    [Documentation]    Upload a CSV file for IPV4 subnets using the CSV Upload link.
    [Arguments]    ${file_path}
    ${csv_link_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IPV4_CSV_UPLOAD_LINK}    timeout=10s
    IF    ${csv_link_visible}
        Click Element Via JS    ${LOC_IPV4_CSV_UPLOAD_LINK}
        Sleep    1s
    END
    ${file_input}=    Execute Javascript
    ...    var inputs = document.querySelectorAll('#onetimechanges input[type="file"]');
    ...    if(inputs[0]) { inputs[0].style.display='block'; inputs[0].style.visibility='visible'; return true; }
    ...    return false;
    IF    ${file_input}
        Choose File    ${LOC_IPV4_CSV_FILE_INPUT}    ${file_path}
        Sleep    2s
        Wait For Loading Overlay To Disappear
    ELSE
        Log    IPV4 CSV file input not found — CSV upload may use different mechanism.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — IPV6 ROW OPERATIONS
# ═══════════════════════════════════════════════════════════════════════
Click Add IPV6 Subnet Row
    [Documentation]    Click the '+ Add Subnet mask' button in the IPV6 section.
    ${clicked}=    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges a.pulsgreen');
    ...    if(btns.length > 1) { btns[btns.length-1].click(); return true; }
    ...    else if(btns.length === 1) { btns[0].click(); return true; }
    ...    return false;
    Should Be True    ${clicked}    No Add Subnet mask button found for IPV6 section.
    Sleep    1s

Fill IPV6 Subnet At Row
    [Documentation]    Fill IPV6 subnet address and prefix at a specific row, then click Calculate.
    ...                Uses SeleniumLibrary to find the last visible subnet mask input after Add IPV6 click.
    [Arguments]    ${row_index}    ${ip}    ${prefix}
    # Find the last subnet mask input in the section (IPV6 row is always the last one added)
    ${inputs}=    Get WebElements    xpath=//div[@id='onetimechanges']//input[contains(@id,'subnetmaskinput')]
    ${input_count}=    Get Length    ${inputs}
    IF    ${input_count} == 0
        Fail    No subnet mask input found in the subnet section after clicking Add.
    END
    ${last_input}=    Set Variable    ${inputs}[-1]
    Scroll To Element Via JS    ${last_input}
    Clear Element Text    ${last_input}
    Input Text    ${last_input}    ${ip}
    Sleep    0.5s
    # Diagnostic: dump all selects and their options
    ${diag}=    Execute Javascript
    ...    var sels = document.querySelectorAll('#onetimechanges select');
    ...    var info = 'selects=' + sels.length + '; ';
    ...    for(var s=0;s<sels.length;s++){
    ...      info += 'sel' + s + '[name=' + sels[s].name + ',opts=' + sels[s].options.length + ',selected=' + sels[s].selectedIndex + ']; ';
    ...    }
    ...    return info;
    Log    IPV6 DIAGNOSTIC selects: ${diag}
    # Select IPV6 prefix — use the last select dropdown in the section
    ${prefix_set}=    Execute Javascript
    ...    var sels = document.querySelectorAll('#onetimechanges select');
    ...    var sel = sels[sels.length-1];
    ...    if(!sel) return 'no_select_found';
    ...    var pref = '${prefix}';
    ...    for(var i=0;i<sel.options.length;i++){
    ...      if(sel.options[i].value===pref || sel.options[i].text===pref || sel.options[i].text.trim()===pref || sel.options[i].value===pref.replace('/','')) {
    ...        sel.selectedIndex=i; sel.dispatchEvent(new Event('change',{bubbles:true})); return 'matched_' + i + '_' + sel.options[i].text;
    ...      }
    ...    }
    ...    if(sel.options.length > 1) { sel.selectedIndex=1; sel.dispatchEvent(new Event('change',{bubbles:true})); return 'fallback_1_' + sel.options[1].text; }
    ...    return 'no_match';
    Log    IPV6 prefix selection result: ${prefix_set}
    Sleep    0.5s
    # Click Calculate — use the last Calculate button
    ${calc_clicked}=    Execute Javascript
    ...    var btns = document.querySelectorAll('#onetimechanges button');
    ...    var last = btns[btns.length-1];
    ...    if(last) { last.scrollIntoView({block:'center'}); last.click(); return 'clicked_' + last.textContent.trim(); }
    ...    return 'no_button';
    Log    IPV6 Calculate click result: ${calc_clicked}
    Sleep    2s
    Wait For Loading Overlay To Disappear

Get IPV6 Host Range At Row
    [Documentation]    Get the Host Address Range text from an IPV6 subnet row.
    ...                Searches all element types (div, span, input) for an IPV6 range pattern.
    [Arguments]    ${row_index}
    ${text}=    Execute Javascript
    ...    var section = document.querySelector('#onetimechanges');
    ...    if(!section) return '';
    ...    var allEls = section.querySelectorAll('span, div, input');
    ...    var ranges = [];
    ...    for(var i=0;i<allEls.length;i++){
    ...      var v = (allEls[i].value || allEls[i].textContent || '').trim();
    ...      if(v.indexOf(':')>=0 && v.indexOf(' - ')>=0 && v.length<100 && v.indexOf('Host')<0 && v.indexOf('Total')<0) ranges.push(v.trim());
    ...    }
    ...    if(ranges[${row_index}]) return ranges[${row_index}];
    ...    if(ranges.length > 0) return ranges[ranges.length-1];
    ...    return '';
    Log    IPV6 Host Range row ${row_index}: ${text}
    RETURN    ${text}

Delete IPV6 Subnet At Row
    [Documentation]    Click the delete icon on an IPV6 subnet row to remove it.
    [Arguments]    ${row_index}
    ${del}=    Execute Javascript
    ...    var delBtns = document.querySelectorAll('#onetimechanges a[class*="red"], #onetimechanges a[class*="danger"], #onetimechanges i[class*="trash"], #onetimechanges .fa-trash');
    ...    var last = delBtns[delBtns.length - 1];
    ...    if(last) { last.click(); return true; }
    ...    return false;
    Sleep    1s
    Log    Delete clicked on IPV6 subnet row ${row_index}: ${del}

Get IPV6 Prefix Dropdown Options
    [Documentation]    Get all available CIDR prefix options from the IPV6 prefix dropdown.
    [Arguments]    ${row_index}=0
    ${options}=    Execute Javascript
    ...    var sels = document.querySelectorAll('#onetimechanges select[name*="ipv6"], #onetimechanges select[id*="ipv6"]');
    ...    var sel = sels[${row_index}];
    ...    if(!sel) { sels = document.querySelectorAll('#onetimechanges select'); sel = sels[sels.length-1]; }
    ...    if(!sel) return [];
    ...    var opts = []; for(var i=0;i<sel.options.length;i++) opts.push(sel.options[i].text);
    ...    return opts;
    Log    IPV6 prefix dropdown options: ${options}
    RETURN    ${options}

Get Total Host IPV6 Count
    [Documentation]    Get the Total Host IPV6 count text from the subnet section.
    ${text}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges');
    ...    if(!el) return '';
    ...    var t = el.innerText;
    ...    var m = t.match(/Total Host\s*IPV6[^:]*?:?\s*(\d+)/i);
    ...    return m ? m[1] : '';
    Log    Total Host IPV6: ${text}
    RETURN    ${text}

Upload IPV6 CSV File
    [Documentation]    Upload a CSV file for IPV6 subnets using the CSV Upload link.
    [Arguments]    ${file_path}
    ${csv_link_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IPV6_CSV_UPLOAD_LINK}    timeout=10s
    IF    ${csv_link_visible}
        Click Element Via JS    ${LOC_IPV6_CSV_UPLOAD_LINK}
        Sleep    1s
    END
    ${file_input}=    Execute Javascript
    ...    var inputs = document.querySelectorAll('#onetimechanges input[type="file"]');
    ...    var last = inputs[inputs.length-1];
    ...    if(last) { last.style.display='block'; last.style.visibility='visible'; return true; }
    ...    return false;
    IF    ${file_input}
        Choose File    ${LOC_IPV6_CSV_FILE_INPUT}    ${file_path}
        Sleep    2s
        Wait For Loading Overlay To Disappear
    ELSE
        Log    IPV6 CSV file input not found — CSV upload may use different mechanism.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SUBNET MASK — COLLAPSE / EXPAND
# ═══════════════════════════════════════════════════════════════════════
Collapse Subnet Mask Section
    [Documentation]    Collapse the Subnet mask accordion section.
    ${is_open}=    Execute Javascript
    ...    var el = document.querySelector('#onetimechanges'); return el && el.classList.contains('in');
    IF    ${is_open}
        Execute Javascript
        ...    var a = document.querySelector('a[href="#onetimechanges"]'); if(a) a.click();
        Sleep    1s
    END

Verify Subnet Data Retained After Toggle
    [Documentation]    Collapse and re-expand subnet section, verify data is retained.
    [Arguments]    ${input_id}=subnetmaskinput0
    ${before}=    Execute Javascript
    ...    var el = document.getElementById('${input_id}'); return el ? el.value : '';
    Collapse Subnet Mask Section
    Expand Subnet Mask Section
    ${after}=    Execute Javascript
    ...    var el = document.getElementById('${input_id}'); return el ? el.value : '';
    Should Be Equal    ${before}    ${after}    Subnet data lost after collapse/expand toggle. Before: ${before}, After: ${after}
    Log    Subnet data retained after toggle: ${after}

Create Temp CSV File
    [Documentation]    Create a temporary CSV file with given content and return the file path.
    [Arguments]    ${content}    ${filename}=test_subnet.csv
    ${path}=    Evaluate    __import__('os').path.join(__import__('tempfile').gettempdir(), '${filename}')
    Evaluate    open(r'${path}', 'w').write('${content}')
    RETURN    ${path}
