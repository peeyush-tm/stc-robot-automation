*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/ip_whitelist_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
Navigate To IP Whitelisting Via Service
    [Documentation]    From Manage Devices, click Service icon, then IP Whitelisting tab.
    Wait For Loading Overlay To Disappear
    ${service_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_MENU_SERVICE}    timeout=10s
    IF    ${service_visible}
        Scroll To Element Via JS    ${LOC_WL_MENU_SERVICE}
        Click Element Via JS    ${LOC_WL_MENU_SERVICE}
        Sleep    1s
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_TAB_IP_WHITELISTING}    timeout=30s
    Click Element Via JS    ${LOC_TAB_IP_WHITELISTING}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_WHITELIST_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s

Click Create Policy Button
    [Documentation]    Clicks Create Policy on the listing page.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s
    Click Element Via JS    ${LOC_WL_CREATE_POLICY_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${CREATE_IP_WHITELIST_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    Sleep    1s

Login And Navigate To Create IP Whitelisting
    [Documentation]    Ensures session is active, then navigates to Create IP Whitelisting via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_IP_WHITELIST_URL}
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s

Login And Navigate To IP Whitelisting List
    [Documentation]    Ensures session is active, then navigates to the IP Whitelisting listing.
    Ensure Session Is Active
    Navigate To Module Page    ${MANAGE_IP_WHITELIST_URL}
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s

Select Customer From Dropdown
    [Documentation]    Selects customer from the dropdown (native select or React Select).
    [Arguments]    ${customer_index}=1
    # Try native <select> by common names (customerId, customer, account)
    FOR    ${loc}    IN    css:select[name="customerId"]    css:select#customerId    xpath=//select[contains(@name,'customer') or contains(@id,'customer')]
        ${found}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${loc}    timeout=3s
        IF    ${found}
            Select From List By Index    ${loc}    ${customer_index}
            Sleep    1s
            Wait For Loading Overlay To Disappear
            RETURN
        END
    END
    # React Select: open via inner control (JS click), focus search input + SPACE so options/async list load, then option click
    ${container}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_WL_CUSTOMER_SELECT}    timeout=10s
    IF    ${container}
        Wait Until Element Is Visible    ${LOC_WL_CUSTOMER_REACT_CONTROL}    timeout=20s
        Scroll To Element Via JS    ${LOC_WL_CUSTOMER_REACT_CONTROL}
        Click Element Via JS    ${LOC_WL_CUSTOMER_REACT_CONTROL}
    ELSE
        Wait Until Element Is Visible    ${LOC_WL_CUSTOMER_FALLBACK_CONTROL}    timeout=15s
        Scroll To Element Via JS    ${LOC_WL_CUSTOMER_FALLBACK_CONTROL}
        Click Element Via JS    ${LOC_WL_CUSTOMER_FALLBACK_CONTROL}
    END
    Sleep    0.5s
    ${inp}=    Set Variable    ${FALSE}
    IF    ${container}
        ${inp}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_WL_CUSTOMER_REACT_INPUT}    timeout=6s
    END
    IF    ${inp}
        Click Element    ${LOC_WL_CUSTOMER_REACT_INPUT}
        Run Keyword And Ignore Error    Press Keys    ${LOC_WL_CUSTOMER_REACT_INPUT}    SPACE
        Sleep    0.8s
    END
    ${opt_xpath}=    Set Variable    xpath=(//div[contains(@class,'react-select__menu') or contains(@class,'select__menu')]//div[(contains(@class,'react-select__option') or contains(@class,'select__option')) and not(contains(@class,'react-select__option--is-disabled')) and not(contains(@class,'select__option--is-disabled'))])[${customer_index}]
    ${picked}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${opt_xpath}    timeout=22s
    IF    not ${picked}
        Run Keyword And Ignore Error    Execute Javascript    document.body.dispatchEvent(new KeyboardEvent('keydown', {key:'Escape', keyCode:27, bubbles:true}));
        Sleep    0.5s
        IF    ${container}
            Click Element Via JS    ${LOC_WL_CUSTOMER_REACT_CONTROL}
        ELSE
            Click Element Via JS    ${LOC_WL_CUSTOMER_FALLBACK_CONTROL}
        END
        Sleep    0.5s
        IF    ${inp}
            Click Element    ${LOC_WL_CUSTOMER_REACT_INPUT}
            Run Keyword And Ignore Error    Press Keys    ${LOC_WL_CUSTOMER_REACT_INPUT}    SPACE
            Sleep    0.8s
        END
        Wait Until Element Is Visible    ${opt_xpath}    timeout=22s
    END
    Click Element Via JS    ${opt_xpath}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Select Business Unit From Dropdown
    [Documentation]    Selects the first BU from the dropdown after Customer is selected.
    [Arguments]    ${bu_index}=1
    Wait Until Element Is Visible    ${LOC_WL_BU_SELECT}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_WL_BU_SELECT}    timeout=30s
    Sleep    1s
    ${option_count}=    Get Element Count    xpath=//select[@name='businessUnit']/option[not(@value='') and not(@value='0')]
    Should Be True    ${option_count} > 0    BU dropdown must have at least one option.
    Select From List By Index    ${LOC_WL_BU_SELECT}    ${bu_index}
    Sleep    1s

Fill IP Whitelisting Header
    [Documentation]    Selects Customer then Business Unit.
    [Arguments]    ${customer_index}=1    ${bu_index}=1
    Select Customer From Dropdown    ${customer_index}
    Select Business Unit From Dropdown    ${bu_index}

Open Rule Dialog
    [Documentation]    Clicks Add Rule (validates Customer + BU first).
    Wait Until Element Is Enabled    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    Click Element Via JS    ${LOC_WL_ADD_RULE_BTN}
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG}    timeout=15s
    Sleep    1s

Select Source Address Subnet
    [Documentation]    Interacts with react-select for Source Address Subnet.
    Wait Until Element Is Visible    ${LOC_WL_SOURCE_SUBNET_CONTROL}    timeout=15s
    Click Element    ${LOC_WL_SOURCE_SUBNET_CONTROL}
    Wait Until Element Is Visible    ${LOC_WL_SOURCE_SUBNET_OPTION}    timeout=15s
    Click Element    xpath=//div[@id='add-service-item-dialog']//div[contains(@class,'react-select__option')][1]
    Sleep    1s

Add Source Address IP Tag
    [Documentation]    Types an IP and presses Enter to add it as a tag.
    [Arguments]    ${ip_address}=${VALID_SOURCE_IP}
    Wait Until Element Is Visible    ${LOC_WL_SOURCE_IP_INPUT}    timeout=15s
    Click Element    ${LOC_WL_SOURCE_IP_INPUT}
    Input Text    ${LOC_WL_SOURCE_IP_INPUT}    ${ip_address}
    Press Keys    ${LOC_WL_SOURCE_IP_INPUT}    RETURN
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Enter Destination Address
    [Documentation]    Enters the destination address(es).
    [Arguments]    ${destination}=${VALID_DESTINATION_ADDR}
    Wait Until Element Is Visible    ${LOC_WL_DESTINATION_ADDR}    timeout=15s
    Input Text    ${LOC_WL_DESTINATION_ADDR}    ${destination}

Select Port
    [Documentation]    Selects the Port value.
    [Arguments]    ${port}=${VALID_PORT}
    Wait Until Element Is Visible    ${LOC_WL_PORT_SELECT}    timeout=15s
    Select From List By Value    ${LOC_WL_PORT_SELECT}    ${port}
    Sleep    1s

Enter Port Value
    [Documentation]    Enters port value when Port = EnterPort.
    [Arguments]    ${port_value}=${VALID_PORT_VALUE}
    Wait Until Element Is Visible    ${LOC_WL_PORT_VALUE_INPUT}    timeout=15s
    Input Text    ${LOC_WL_PORT_VALUE_INPUT}    ${port_value}

Select Protocol
    [Documentation]    Selects the Protocol value.
    [Arguments]    ${protocol}=${VALID_PROTOCOL_TCP}
    Wait Until Element Is Visible    ${LOC_WL_PROTOCOL_SELECT}    timeout=15s
    Select From List By Value    ${LOC_WL_PROTOCOL_SELECT}    ${protocol}

Submit Rule Dialog
    [Documentation]    Clicks Submit in the Rule dialog.
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_SUBMIT}    timeout=15s
    Click Element Via JS    ${LOC_WL_RULE_DIALOG_SUBMIT}
    Sleep    1s
    Wait Until Element Is Not Visible    ${LOC_WL_RULE_DIALOG}    timeout=15s

Submit Rule Dialog Expecting Error
    [Documentation]    Clicks Submit in the Rule dialog when validation error is expected.
    ...                Does NOT wait for dialog to close.
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_SUBMIT}    timeout=15s
    Click Element Via JS    ${LOC_WL_RULE_DIALOG_SUBMIT}
    Sleep    1s

Close Rule Dialog Without Submitting
    [Documentation]    Clicks Close in the Rule dialog.
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_CLOSE}    timeout=10s
    Click Element Via JS    ${LOC_WL_RULE_DIALOG_CLOSE}
    Wait Until Element Is Not Visible    ${LOC_WL_RULE_DIALOG}    timeout=15s

Fill And Submit Rule
    [Documentation]    Opens dialog, fills all fields, submits the rule.
    [Arguments]    ${source_ip}=${VALID_SOURCE_IP}    ${destination}=${VALID_DESTINATION_ADDR}
    ...            ${port}=${VALID_PORT}    ${port_value}=${EMPTY_STRING}    ${protocol}=${VALID_PROTOCOL_TCP}
    Open Rule Dialog
    Select Source Address Subnet
    Add Source Address IP Tag    ${source_ip}
    Enter Destination Address    ${destination}
    Select Port    ${port}
    IF    '${port}' == 'EnterPort' and '${port_value}' != ''
        Enter Port Value    ${port_value}
    END
    Select Protocol    ${protocol}
    Submit Rule Dialog

Verify Rule Added To Grid
    [Documentation]    Asserts the rules grid contains at least one row.
    Wait Until Element Is Visible    ${LOC_WL_RULES_GRID}    timeout=15s
    ${row_count}=    Get Element Count    ${LOC_WL_RULES_GRID_ROW}
    Should Be True    ${row_count} >= 1    Rules grid must contain at least one rule.

Submit IP Whitelisting Policy
    [Documentation]    Clicks the Create button (enabled after rules are added).
    Wait Until Element Is Enabled    ${LOC_WL_CREATE_BTN}    timeout=15s
    Click Element Via JS    ${LOC_WL_CREATE_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Click Close Button IP Whitelisting
    [Documentation]    Clicks Close/Cancel on the Create page.
    Scroll To Element Via JS    ${LOC_WL_CLOSE_BTN}
    Click Element Via JS    ${LOC_WL_CLOSE_BTN}

Verify IP Whitelisting Created Successfully
    [Documentation]    Verify success toast and redirect to /IPWhitelisting.
    Wait Until Element Is Visible    ${LOC_WL_TOAST_SUCCESS}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_WL_TOAST_SUCCESS}
    Log    Success toast: ${toast_text}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_WHITELIST_PATH}
    Wait Until Element Is Visible    ${LOC_WL_GRID}    timeout=30s

Verify Create Button Is Disabled
    [Documentation]    Asserts the Create button is disabled (no rules added).
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_WL_CREATE_BTN}
    Should Not Be True    ${enabled}    Create button should be disabled with no rules.

Verify On IP Whitelisting Listing Page
    [Documentation]    Confirms the current page is /IPWhitelisting.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_WHITELIST_PATH}
    Wait Until Element Is Visible    ${LOC_WL_GRID}    timeout=30s

Verify Rule Dialog Did Not Open
    [Documentation]    Asserts the Rule dialog is NOT visible (Customer/BU not filled).
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG}    timeout=5s
    Should Not Be True    ${dialog_visible}    Rule dialog should NOT open when Customer/BU is empty.

Verify Rule Validation Error
    [Documentation]    Asserts error toast, alert-danger, or dialog still visible after invalid rule submit.
    Sleep    1s
    ${toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_TOAST_ERROR}    timeout=5s
    ${alert}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_ALERT_DANGER}    timeout=5s
    ${dialog_stays}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_WL_RULE_DIALOG}
    Should Be True    ${toast} or ${alert} or ${dialog_stays}
    ...    Expected validation error (toast, alert, or dialog) but none found.
    Log    Rule validation error detected — toast:${toast} alert:${alert} dialog_stays:${dialog_stays}
