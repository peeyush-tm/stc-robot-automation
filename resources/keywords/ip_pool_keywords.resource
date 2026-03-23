*** Settings ***
Library     SeleniumLibrary
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
        Sleep    2s
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
    Sleep    2s

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
    [Documentation]    Selects the first account from the TreeView/dropdown (tries multiple locators).
    FOR    ${loc}    IN    ${LOC_IP_ACCOUNT_TREE}    ${LOC_IP_ACCOUNT_TREE_ALT}    xpath=//div[@for='accountId']    xpath=//*[@data-testid='accountId']    xpath=//div[contains(@class,'treeview') or contains(@class,'k-treeview')][1]
        ${visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${loc}    timeout=5s
        IF    ${visible}
            Click Element Via JS    ${loc}
            Sleep    2s
            ${first_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_IP_ACCOUNT_TREE_FIRST}    timeout=10s
            IF    ${first_visible}
                Click Element Via JS    ${LOC_IP_ACCOUNT_TREE_FIRST}
            ELSE
                Click Element Via JS    xpath=//div[contains(@class,'select__option')][1]
            END
            Sleep    2s
            Wait For Loading Overlay To Disappear
            RETURN
        END
    END
    Fail    Account tree/dropdown not found on Create IP Pool form. Tried: accountId, treeview.

Select APN Type
    [Documentation]    Selects APN Type (Public=2, Private=1).
    [Arguments]    ${apn_type}=${APN_TYPE_PUBLIC}
    Wait Until Element Is Visible    ${LOC_IP_APN_TYPE}    timeout=30s
    Select From List By Value    ${LOC_IP_APN_TYPE}    ${apn_type}
    Sleep    1s

Enter Number Of IPs
    [Documentation]    Clears and enters the Number of IPs value.
    [Arguments]    ${number_of_ips}=${VALID_NUMBER_OF_IPS}
    Wait Until Element Is Visible    ${LOC_IP_NUMBER_OF_IPS}    timeout=30s
    Click Element    ${LOC_IP_NUMBER_OF_IPS}
    Clear Element Text    ${LOC_IP_NUMBER_OF_IPS}
    Input Text    ${LOC_IP_NUMBER_OF_IPS}    ${number_of_ips}

Select APN From Dropdown
    [Documentation]    Selects the first available APN after Account + APN Type are selected.
    [Arguments]    ${apn_index}=${VALID_APN_INDEX}
    Wait Until Element Is Visible    ${LOC_IP_APN_SELECT}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_IP_APN_SELECT}    timeout=30s
    Sleep    2s
    Select From List By Index    ${LOC_IP_APN_SELECT}    ${apn_index}
    Sleep    1s

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
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_IP_GENERATED_IPS}    timeout=30s

Submit IP Pool
    [Documentation]    Clicks the Submit button (Step 2) to create the IP pool.
    Wait Until Element Is Visible    ${LOC_IP_SUBMIT_BTN}    timeout=30s
    Click Element Via JS    ${LOC_IP_SUBMIT_BTN}
    Sleep    3s
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
