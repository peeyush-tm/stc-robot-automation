*** Settings ***
Library     SeleniumLibrary
Library     ../../libraries/IpPoolDomProbe.py
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/ip_pool_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
Navigate To IP Pooling Via Service
    [Documentation]    From Manage Devices, click Service icon, then IP Pooling tab.
    Wait For Loading Overlay To Disappear
    ${service_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IP_MENU_SERVICE}    timeout=10s
    IF    ${service_visible}
        Scroll To Element Via JS    ${LOC_IP_MENU_SERVICE}
        Click Element Via JS    ${LOC_IP_MENU_SERVICE}
        Sleep    1s
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_TAB_IP_POOLING}    timeout=30s
    Click Element Via JS    ${LOC_TAB_IP_POOLING}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_POOL_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_IP_CREATE_BTN}    timeout=30s

Click Create IP Pool Button
    [Documentation]    Clicks Create IP Pool on the listing page.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_IP_CREATE_BTN}    timeout=30s
    Click Element Via JS    ${LOC_IP_CREATE_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${CREATE_IP_POOL_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_IP_APN_TYPE}    timeout=30s
    Sleep    1s

Login And Navigate To Create IP Pool
    [Documentation]    Ensures session is active, then navigates to Create IP Pool via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_IP_POOL_URL}
    Wait Until Element Is Visible    ${LOC_IP_APN_TYPE}    timeout=30s

Login And Navigate To IP Pool List
    [Documentation]    Ensures session is active, then navigates to the IP Pooling listing.
    Ensure Session Is Active
    Navigate To Module Page    ${MANAGE_IP_POOL_URL}
    Wait Until Element Is Visible    ${LOC_IP_CREATE_BTN}    timeout=30s

Select Account From TreeView IP Pool
    [Documentation]    Selects a BU-level account from the Kendo TreeView dropdown.
    ...                Opens dropdown → expands OPCO root → locates EC by text and expands it
    ...                → locates BU by text and clicks to select.
    ${ec_name}=    Evaluate    __import__('variables._config_defaults',fromlist=['config_scalar']).config_scalar('DEFAULT_EC_ACCOUNT','')
    ${bu_name}=    Evaluate    __import__('variables._config_defaults',fromlist=['config_scalar']).config_scalar('DEFAULT_BU_ACCOUNT','')
    Log    IP Pool — target EC: ${ec_name} | BU: ${bu_name}    console=yes
    ${display_input}=    Set Variable    xpath=//div[contains(@class,'treeview-dropdown-gcontrol')]//input
    Wait Until Element Is Visible    ${display_input}    timeout=10s
    Click Element    ${display_input}
    Sleep    2s
    # Expand KSA_OPCO root (first expand icon in the tree)
    IP Pool Expand Next TreeView Node
    # Locate the EC node by exact text, scroll into view and expand it.
    # QE renders treeview nodes lazily after the OPCO expand — retry for
    # up to 45 s (every 5 s) until the k-in span appears in the DOM.
    Wait Until Keyword Succeeds    45s    5s    IP Pool Expand Node By Text    ${ec_name}
    # Locate the BU node by exact text and select it (checkbox + click)
    IP Pool Click Tree Node    ${bu_name}

IP Pool Expand Next TreeView Node
    [Documentation]    Clicks the first k-i-expand arrow in the treeview and waits for children to load.
    ${expand_ok}=    Run Keyword And Return Status    Wait Until Page Contains Element
    ...    xpath=//span[contains(@class,'k-icon') and contains(@class,'k-i-expand')]    timeout=8s
    IF    ${expand_ok}
        Click Element Via JS    xpath=//span[contains(@class,'k-icon') and contains(@class,'k-i-expand')]
        IP Pool Wait For Tree Loading
    ELSE
        Log    No k-i-expand icon found in treeview.    console=yes
    END

IP Pool Expand Node By Text
    [Documentation]    Finds a treeview node by its visible text, scrolls to it and clicks its expand arrow.
    [Arguments]    ${node_text}
    ${result}=    Execute Javascript
    ...    var spans=document.querySelectorAll('span.k-in');
    ...    for(var i=0;i<spans.length;i++){
    ...      if(spans[i].textContent.trim()==='${node_text}'){
    ...        spans[i].scrollIntoView({block:'center'});
    ...        var mid=spans[i].closest('.k-mid')||spans[i].parentElement;
    ...        if(mid){var exp=mid.querySelector('.k-i-expand');
    ...          if(exp){exp.click(); return 'expanded';}
    ...          var col=mid.querySelector('.k-i-collapse');
    ...          if(col) return 'already_expanded';}
    ...        return 'no_icon';}}
    ...    return 'not_found';
    Log    Expand node '${node_text}': ${result}    console=yes
    IF    '${result}' == 'expanded'
        IP Pool Wait For Tree Loading
    ELSE IF    '${result}' == 'not_found'
        Fail    TreeView node '${node_text}' not found in the account tree. Check DEFAULT_EC_ACCOUNT in config.
    END

IP Pool Wait For Tree Loading
    [Documentation]    Waits for the k-i-loading spinner to disappear in the treeview.
    Wait Until Keyword Succeeds    30s    2s    Page Should Not Contain Element
    ...    xpath=//span[contains(@class,'k-i-loading')]
    Sleep    1s
    Wait For Loading Overlay To Disappear

IP Pool Click Tree Node
    [Documentation]    Clicks a treeview node by its text — checks checkbox and clicks label.
    ...                Waits for the node to appear, scrolls into view, then clicks.
    [Arguments]    ${node_text}
    Wait Until Keyword Succeeds    15s    2s    Page Should Contain Element
    ...    xpath=//span[contains(@class,'k-in') and normalize-space()='${node_text}']
    ${result}=    Execute Javascript
    ...    var spans=document.querySelectorAll('span.k-in');
    ...    for(var i=0;i<spans.length;i++){
    ...      if(spans[i].textContent.trim()==='${node_text}'){
    ...        spans[i].scrollIntoView({block:'center'});
    ...        var mid=spans[i].closest('.k-mid')||spans[i].parentElement;
    ...        if(mid){var cb=mid.querySelector('.k-checkbox');
    ...          if(cb && !cb.checked) cb.click();}
    ...        spans[i].click(); return 'selected';}}
    ...    return 'not_found';
    Log    Click tree node '${node_text}': ${result}    console=yes
    IF    '${result}' == 'not_found'
        Fail    TreeView node '${node_text}' not found. Check DEFAULT_BU_ACCOUNT in config.
    END
    Sleep    3s
    Wait For Loading Overlay To Disappear

Select APN Type
    [Documentation]    Selects APN Type (Public=2, Private=1).
    ...                Waits for the loading overlay to clear after selection so the
    ...                subsequent APN dropdown API call has time to initiate in QE.
    [Arguments]    ${apn_type}=${APN_TYPE_PUBLIC}
    Wait Until Element Is Visible    ${LOC_IP_APN_TYPE}    timeout=30s
    Select From List By Value    ${LOC_IP_APN_TYPE}    ${apn_type}
    Sleep    2s
    Wait For Loading Overlay To Disappear

Enter Number Of IPs
    [Documentation]    Clears and enters the Number of IPs value.
    [Arguments]    ${number_of_ips}=${VALID_NUMBER_OF_IPS}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_IP_NUMBER_OF_IPS}    timeout=30s
    Click Element Via JS    ${LOC_IP_NUMBER_OF_IPS}
    Clear Element Text    ${LOC_IP_NUMBER_OF_IPS}
    Input Text    ${LOC_IP_NUMBER_OF_IPS}    ${number_of_ips}

Select APN From Dropdown
    [Documentation]    Selects the first available APN after Account + APN Type are selected.
    ...                Waits up to 60 s for APN options to load (QE API responds slower than dev).
    ...                If Public APN options never appear, automatically switches to Private APN
    ...                type and retries — handles QE environments where the auto-created BU account
    ...                has only Private APNs assigned.  Logs a WARN when the fallback is used.
    [Arguments]    ${apn_index}=${VALID_APN_INDEX}
    Wait Until Element Is Visible    ${LOC_IP_APN_SELECT}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_IP_APN_SELECT}    timeout=30s
    Wait For Loading Overlay To Disappear
    # ── Primary wait: up to 60 s for the APN options to populate ────────
    ${apn_loaded}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    60s    5s    IP Pool APN Dropdown Has Options
    # ── Fallback: switch to Private APN type if Public has no options ───
    IF    not ${apn_loaded}
        Log    Public APN options did not load in 60 s — switching to Private APN type as fallback.
        ...    level=WARN
        Select From List By Value    ${LOC_IP_APN_TYPE}    1
        Sleep    3s
        Wait For Loading Overlay To Disappear
        Wait Until Keyword Succeeds    30s    5s    IP Pool APN Dropdown Has Options
    END
    ${items}=    Get List Items    ${LOC_IP_APN_SELECT}
    Log    APN dropdown items: ${items}    console=yes
    Select From List By Index    ${LOC_IP_APN_SELECT}    ${apn_index}
    Sleep    1s

IP Pool APN Dropdown Has Options
    [Documentation]    Checks the APN dropdown has more than 1 item (the placeholder).
    ${items}=    Get List Items    ${LOC_IP_APN_SELECT}
    ${count}=    Get Length    ${items}
    Should Be True    ${count} > 1
    ...    APN dropdown has no selectable options (only ${count} item). Account may not have APNs.

Fill IP Pool Form
    [Documentation]    Fills Account, APN Type, Number of IPs, and APN.
    [Arguments]    ${apn_type}=${APN_TYPE_PUBLIC}    ${number_of_ips}=${VALID_NUMBER_OF_IPS}
    Select Account From TreeView IP Pool
    Select APN Type    ${apn_type}
    Enter Number Of IPs    ${number_of_ips}
    Select APN From Dropdown

Click Create And Wait For IP Details
    [Documentation]    Clicks the Create button (Step 1) and waits for IP Details panel.
    Wait Until Element Is Visible    ${LOC_IP_CREATE_STEP_BTN}    timeout=30s
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_IP_GENERATED_IPS}    timeout=30s

Submit IP Pool
    [Documentation]    Clicks the Submit button (Step 2) to create the IP pool.
    Wait Until Element Is Visible    ${LOC_IP_SUBMIT_BTN}    timeout=30s
    Click Element Via JS    ${LOC_IP_SUBMIT_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Click Close Button IP Pool
    [Documentation]    Clicks Close/Cancel on the Create IP Pool page.
    Scroll To Element Via JS    ${LOC_IP_CLOSE_BTN}
    Click Element Via JS    ${LOC_IP_CLOSE_BTN}

Verify IP Pool Created Successfully
    [Documentation]    Verify success toast and redirect to /manageIPPooling.
    Wait Until Element Is Visible    ${LOC_IP_TOAST_SUCCESS}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_IP_TOAST_SUCCESS}
    Log    Success toast: ${toast_text}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_POOL_PATH}
    Wait Until Element Is Visible    ${LOC_IP_GRID}    timeout=30s

Verify IP Details Panel Visible
    [Documentation]    Asserts the IP Details panel is visible after clicking Create.
    Wait Until Element Is Visible    ${LOC_IP_GENERATED_IPS}    timeout=30s
    Wait Until Element Is Visible    ${LOC_IP_SUBMIT_BTN}    timeout=30s
    ${has_ipv4}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_IP_IPV4_TABLE}
    ${has_ipv6}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_IP_IPV6_TABLE}
    Should Be True    ${has_ipv4} or ${has_ipv6}
    ...    IP Details panel must contain at least one subnet table.

Verify Create Step Button Is Disabled Or Error
    [Documentation]    After clicking Create with invalid data, verifies error shown or button inactive.
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IP_TOAST_ERROR}    timeout=10s
    ${alert_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IP_ALERT_DANGER}    timeout=5s
    ${current_url}=    Get Location
    ${still_on_create}=    Evaluate    '/CreateIPPooling' in '''${current_url}'''
    Should Be True    ${error_visible} or ${alert_visible} or ${still_on_create}
    ...    Expected error toast/alert or still on Create page after invalid submission.

Verify On IP Pool Listing Page
    [Documentation]    Confirms the current page is /manageIPPooling.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_POOL_PATH}
    Wait Until Element Is Visible    ${LOC_IP_GRID}    timeout=30s
