*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/ip_whitelist_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/ip_whitelist_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/ip_whitelist_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_WL_001 E2E Create IP Whitelisting Policy TCP Any Port
    [Documentation]    Full E2E: Login > Service > IP Whitelisting > Create >
    ...                Fill Customer + BU > Add Rule (TCP, any port) > Submit > verify success.
    [Tags]    smoke    regression    positive    ip_whitelist
    TC_WL_001

TC_WL_002 Verify IP Whitelisting Listing Page Loads
    [Documentation]    Navigate to IP Whitelisting and verify the grid and Create Policy button are visible.
    [Tags]    smoke    regression    positive    ip_whitelist
    TC_WL_002

TC_WL_003 Verify Create IP Whitelisting Form Elements Visible
    [Documentation]    Navigate to Create IP Whitelisting and verify form is loaded (Add Rule and BU field visible).
    [Tags]    smoke    regression    positive    ip_whitelist
    TC_WL_003

TC_WL_004 Verify BU Dropdown Populates After Customer Selection
    [Documentation]    Select Customer, verify BU dropdown becomes enabled and has options.
    [Tags]    regression    positive    ip_whitelist
    TC_WL_004

TC_WL_005 Verify Rule Dialog Opens After Customer And BU Selected
    [Documentation]    Fill Customer + BU, click Add Rule, verify Rule dialog opens.
    [Tags]    regression    positive    ip_whitelist
    TC_WL_005

TC_WL_006 Verify Rule Appears In Grid After Submitting
    [Documentation]    Add a valid rule, verify it appears in the rules grid.
    [Tags]    regression    positive    ip_whitelist
    TC_WL_006

TC_WL_007 Verify Create Button Enabled After Adding Rule
    [Documentation]    Add a rule, verify Create button becomes enabled.
    [Tags]    regression    positive    ip_whitelist
    TC_WL_007

TC_WL_008 Create Policy With EnterPort And Specific Port Value
    [Documentation]    Create policy with Port=EnterPort and port value 8080.
    [Tags]    regression    positive    ip_whitelist
    TC_WL_008

TC_WL_009 Verify Cancel Button Redirects To Listing
    [Documentation]    Fill header and add rule, click Close, verify redirect to listing.
    [Tags]    regression    positive    ip_whitelist    navigation
    TC_WL_009

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_WL_010 Add Rule Without Customer Should Not Open Dialog
    [Documentation]    On Create page with no Customer selected, Add Rule should not open dialog.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_010

TC_WL_011 Add Rule Without BU Should Not Open Dialog
    [Documentation]    Select Customer but not BU, Add Rule should not open dialog.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_011

TC_WL_012 Create Button Disabled With No Rules
    [Documentation]    Fill Customer + BU but add no rules, Create button should be disabled.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_012

TC_WL_013 Submit Rule With No Fields Should Show Error
    [Documentation]    Open Rule dialog, submit without filling any fields, verify error.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_013

TC_WL_014 Submit Rule Without Destination Should Show Error
    [Documentation]    Open Rule dialog, fill source only, leave destination empty, submit, verify error.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_014

TC_WL_015 Submit Rule With Invalid Destination Address
    [Documentation]    Submit rule with invalid destination (999.999.999.999), verify error.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_015

TC_WL_016 Port Value Exceeding 65535 Should Show Error
    [Documentation]    Enter port value 99999 (exceeds max 65535), verify error.
    [Tags]    regression    negative    ip_whitelist    boundary
    TC_WL_016

TC_WL_017 Close Rule Dialog Without Submitting
    [Documentation]    Open Rule dialog, fill some fields, click Close without submitting.
    [Tags]    regression    negative    ip_whitelist
    TC_WL_017

TC_WL_018 Close Create Page Before Submitting
    [Documentation]    Fill header, add rule, click Close instead of Create.
    [Tags]    regression    negative    ip_whitelist    navigation
    TC_WL_018

TC_WL_019 Direct Access To Create IP Whitelisting Without Login
    [Documentation]    Navigate directly to /CreateIPWhitelisting without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    ip_whitelist    navigation
    TC_WL_019

TC_WL_020 Direct Access To IP Whitelisting List Without Login
    [Documentation]    Navigate directly to /IPWhitelisting without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    ip_whitelist    navigation
    TC_WL_020


*** Keywords ***
TC_WL_001
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Fill And Submit Rule    port=${VALID_PORT}    protocol=${VALID_PROTOCOL_TCP}
    Verify Rule Added To Grid
    Submit IP Whitelisting Policy
    Verify IP Whitelisting Created Successfully

TC_WL_002
    Login And Navigate To IP Whitelisting List
    Wait Until Element Is Visible    ${LOC_WL_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s
    Log    IP Whitelisting listing page loaded successfully.    console=yes

TC_WL_003
    Login And Navigate To Create IP Whitelisting
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    Wait Until Element Is Visible    ${LOC_WL_BU_SELECT}    timeout=15s
    Log    Create IP Whitelisting form elements are visible.    console=yes

TC_WL_004
    Login And Navigate To Create IP Whitelisting
    Select Customer From Dropdown    1
    Wait Until Element Is Enabled    ${LOC_WL_BU_SELECT}    timeout=30s
    ${option_count}=    Get Element Count    xpath=//select[@name='businessUnit']/option[not(@value='') and not(@value='0')]
    Should Be True    ${option_count} > 0    BU dropdown must have options after Customer selection.
    Log    BU dropdown populated with ${option_count} option(s).    console=yes

TC_WL_005
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Open Rule Dialog
    Wait Until Element Is Visible    ${LOC_WL_SOURCE_SUBNET_CONTROL}    timeout=15s
    Wait Until Element Is Visible    ${LOC_WL_DESTINATION_ADDR}    timeout=15s
    Close Rule Dialog Without Submitting
    Log    Rule dialog opened and closed successfully.    console=yes

TC_WL_006
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Fill And Submit Rule
    Verify Rule Added To Grid
    Log    Rule successfully added to grid.    console=yes

TC_WL_007
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Fill And Submit Rule
    Verify Rule Added To Grid
    Wait Until Element Is Enabled    ${LOC_WL_CREATE_BTN}    timeout=15s
    Log    Create button enabled after adding rule.    console=yes

TC_WL_008
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Fill And Submit Rule    port=${VALID_PORT_ENTER}    port_value=${VALID_PORT_VALUE}
    Verify Rule Added To Grid
    Submit IP Whitelisting Policy
    Verify IP Whitelisting Created Successfully

TC_WL_009
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Fill And Submit Rule
    Verify Rule Added To Grid
    Click Close Button IP Whitelisting
    Verify On IP Whitelisting Listing Page

TC_WL_010
    Login And Navigate To Create IP Whitelisting
    ${clicked}=    Run Keyword And Return Status
    ...    Click Element Via JS    ${LOC_WL_ADD_RULE_BTN}
    Sleep    2s
    Verify Rule Dialog Did Not Open

TC_WL_011
    Login And Navigate To Create IP Whitelisting
    Select Customer From Dropdown    1
    Sleep    2s
    ${clicked}=    Run Keyword And Return Status
    ...    Click Element Via JS    ${LOC_WL_ADD_RULE_BTN}
    Sleep    2s
    Verify Rule Dialog Did Not Open

TC_WL_012
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Verify Create Button Is Disabled

TC_WL_013
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Open Rule Dialog
    Submit Rule Dialog Expecting Error
    Verify Rule Validation Error

TC_WL_014
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Open Rule Dialog
    Select Source Address Subnet
    Add Source Address IP Tag
    Submit Rule Dialog Expecting Error
    Verify Rule Validation Error

TC_WL_015
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Open Rule Dialog
    Select Source Address Subnet
    Add Source Address IP Tag
    Enter Destination Address    ${INVALID_DESTINATION_ADDR}
    Select Port    ${VALID_PORT}
    Select Protocol    ${VALID_PROTOCOL_TCP}
    Submit Rule Dialog Expecting Error
    Verify Rule Validation Error

TC_WL_016
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Open Rule Dialog
    Select Source Address Subnet
    Add Source Address IP Tag
    Enter Destination Address
    Select Port    ${VALID_PORT_ENTER}
    Enter Port Value    ${PORT_VALUE_EXCEEDS_MAX}
    Select Protocol    ${VALID_PROTOCOL_TCP}
    Submit Rule Dialog Expecting Error
    Verify Rule Validation Error

TC_WL_017
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Open Rule Dialog
    Select Source Address Subnet
    Add Source Address IP Tag
    Close Rule Dialog Without Submitting
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=15s
    Log    Rule dialog closed without submitting — form still visible.    console=yes

TC_WL_018
    Login And Navigate To Create IP Whitelisting
    Fill IP Whitelisting Header
    Fill And Submit Rule
    Verify Rule Added To Grid
    Click Close Button IP Whitelisting
    Verify On IP Whitelisting Listing Page
    Log    Create page closed before submitting — redirected to listing.    console=yes

TC_WL_019
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_IP_WHITELIST_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_WL_020
    Clear Session For Unauthenticated Test
    Go To    ${MANAGE_IP_WHITELIST_URL}
    Wait For Page Load
    Verify Redirected To Login Page
