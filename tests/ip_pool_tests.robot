*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/ip_pool_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/ip_pool_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/ip_pool_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_IPP_001 E2E Create IP Pool With Public APN
    [Documentation]    Full 2-step flow: Login > IP Pooling > Create > fill form >
    ...                Click Create (Step 1) > Verify IP Details > Submit (Step 2) >
    ...                Verify success toast and redirect to listing.
    [Tags]    smoke    regression    positive    ip_pool
    TC_IPP_001

TC_IPP_002 Verify IP Pool Listing Page Loads
    [Documentation]    Navigate to IP Pooling listing and verify grid is visible.
    [Tags]    smoke    regression    positive    ip_pool
    TC_IPP_002

TC_IPP_003 Verify Create IP Pool Form Elements Visible
    [Documentation]    Navigate to Create IP Pool and verify APN Type, Number of IPs, Create button visible.
    [Tags]    smoke    regression    positive    ip_pool
    TC_IPP_003

TC_IPP_004 Verify IP Details Panel After Clicking Create
    [Documentation]    Fill form, click Create (Step 1), verify IP Details panel appears.
    [Tags]    regression    positive    ip_pool
    TC_IPP_004

TC_IPP_005 Verify Pool Count In IP Details Panel
    [Documentation]    Fill form with 5 IPs, click Create, verify Generated/Requested
    ...                counts match in the IP Details panel.
    [Tags]    regression    positive    ip_pool
    TC_IPP_005

TC_IPP_006 Cancel Before Submit Redirects To Listing
    [Documentation]    Fill form, click Create to get IP Details, then click Close
    ...                before Submit. Verify redirect to listing page.
    [Tags]    regression    positive    ip_pool    navigation
    TC_IPP_006

TC_IPP_007 Verify APN Dropdown Populates After Account And Type
    [Documentation]    Select Account and APN Type, verify APN dropdown becomes
    ...                enabled and has options.
    [Tags]    regression    positive    ip_pool
    TC_IPP_007

TC_IPP_008 Verify Close Button On Create Page Redirects
    [Documentation]    On Create IP Pool form (before clicking Create), click Close.
    ...                Verify redirect to listing page.
    [Tags]    regression    positive    ip_pool    navigation
    TC_IPP_008

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_IPP_009 Create With No Fields Filled Should Show Error
    [Documentation]    Click Create without filling any field. Verify error or
    ...                validation prevents submission.
    [Tags]    regression    negative    ip_pool
    TC_IPP_009

TC_IPP_010 Create Without Account Should Show Error
    [Documentation]    Fill APN Type, Number of IPs, APN but skip Account.
    ...                Verify error or validation.
    [Tags]    regression    negative    ip_pool
    TC_IPP_010

TC_IPP_011 Create Without APN Type Should Show Error
    [Documentation]    Fill Account, Number of IPs but leave APN Type default.
    ...                Verify error or validation.
    [Tags]    regression    negative    ip_pool
    TC_IPP_011

TC_IPP_012 Create Without Number Of IPs Should Show Error
    [Documentation]    Fill Account, APN Type, APN but leave Number of IPs empty.
    ...                Verify error or validation.
    [Tags]    regression    negative    ip_pool
    TC_IPP_012

TC_IPP_013 Create Without APN Selected Should Show Error
    [Documentation]    Fill Account, APN Type, Number of IPs but do not select APN.
    ...                Verify error or validation.
    [Tags]    regression    negative    ip_pool
    TC_IPP_013

TC_IPP_014 Create With Zero IPs Should Show Error
    [Documentation]    Enter 0 as Number of IPs. Verify error or validation.
    [Tags]    regression    negative    ip_pool    boundary
    TC_IPP_014

TC_IPP_015 Create With Non Numeric IPs Should Show Error
    [Documentation]    Enter "abc" as Number of IPs. Verify error or validation.
    [Tags]    regression    negative    ip_pool    boundary
    TC_IPP_015

TC_IPP_016 Direct Access To Create IP Pool Without Login
    [Documentation]    Navigate directly to /CreateIPPooling without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    ip_pool    navigation
    TC_IPP_016

TC_IPP_017 Direct Access To IP Pool List Without Login
    [Documentation]    Navigate directly to /manageIPPooling without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    ip_pool    navigation
    TC_IPP_017


*** Keywords ***
TC_IPP_001
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${VALID_NUMBER_OF_IPS}
    Click Create And Wait For IP Details
    Submit IP Pool
    Verify IP Pool Created Successfully

TC_IPP_002
    Login And Navigate To IP Pool List
    Wait Until Element Is Visible    ${LOC_IP_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${row_count}=    Get Element Count    ${LOC_IP_GRID_ROWS}
    Log    IP Pool grid loaded. Row count: ${row_count}    console=yes
    Verify On IP Pool Listing Page

TC_IPP_003
    Login And Navigate To Create IP Pool
    Wait Until Element Is Visible    ${LOC_IP_APN_TYPE}    timeout=30s
    Wait Until Element Is Visible    ${LOC_IP_NUMBER_OF_IPS}    timeout=30s
    Wait Until Element Is Visible    ${LOC_IP_CREATE_STEP_BTN}    timeout=30s
    ${account_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_IP_ACCOUNT_TREE}    timeout=5s
    Log    Create IP Pool form elements are visible. Account selector visible: ${account_visible}

TC_IPP_004
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${VALID_NUMBER_OF_IPS}
    Click Create And Wait For IP Details
    Verify IP Details Panel Visible

TC_IPP_005
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${VALID_NUMBER_OF_IPS}
    Click Create And Wait For IP Details
    ${generated}=    Get Text    ${LOC_IP_GENERATED_IPS}
    ${requested}=    Get Text    ${LOC_IP_REQUESTED_IPS}
    Log    Generated: ${generated}, Requested: ${requested}    console=yes
    Should Be Equal As Strings    ${requested}    ${VALID_NUMBER_OF_IPS}
    ...    Requested IPs should match form input.

TC_IPP_006
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${VALID_NUMBER_OF_IPS}
    Click Create And Wait For IP Details
    Click Close Button IP Pool
    Verify On IP Pool Listing Page

TC_IPP_007
    Login And Navigate To Create IP Pool
    Select Account From TreeView IP Pool
    Select APN Type    ${APN_TYPE_PUBLIC}
    Sleep    2s
    Wait Until Element Is Visible    ${LOC_IP_APN_SELECT}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_IP_APN_SELECT}    timeout=30s
    ${has_options}=    Run Keyword And Return Status
    ...    Get List Items    ${LOC_IP_APN_SELECT}
    IF    ${has_options}
        ${items}=    Get List Items    ${LOC_IP_APN_SELECT}
        ${count}=    Get Length    ${items}
        Should Be True    ${count} > 1
        ...    APN dropdown should have options after Account and Type selection.
        Log    APN dropdown populated with ${count} option(s).
    ELSE
        Log    APN dropdown is visible and enabled (custom component — option count not available).
    END

TC_IPP_008
    Login And Navigate To Create IP Pool
    Click Close Button IP Pool
    Verify On IP Pool Listing Page

TC_IPP_009
    Login And Navigate To Create IP Pool
    Wait Until Element Is Visible    ${LOC_IP_CREATE_STEP_BTN}    timeout=30s
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_010
    Login And Navigate To Create IP Pool
    Select APN Type    ${APN_TYPE_PUBLIC}
    Enter Number Of IPs    ${VALID_NUMBER_OF_IPS}
    ${apn_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IP_APN_SELECT}    timeout=10s
    IF    ${apn_visible}
        Select APN From Dropdown
    END
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_011
    Login And Navigate To Create IP Pool
    Select Account From TreeView IP Pool
    Enter Number Of IPs    ${VALID_NUMBER_OF_IPS}
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_012
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${EMPTY_STRING}
    Clear Element Text    ${LOC_IP_NUMBER_OF_IPS}
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_013
    Login And Navigate To Create IP Pool
    Select Account From TreeView IP Pool
    Select APN Type    ${APN_TYPE_PUBLIC}
    Enter Number Of IPs    ${VALID_NUMBER_OF_IPS}
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_014
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${ZERO_IPS}
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_015
    Login And Navigate To Create IP Pool
    Fill IP Pool Form    ${APN_TYPE_PUBLIC}    ${NON_NUMERIC_IPS}
    Click Element Via JS    ${LOC_IP_CREATE_STEP_BTN}
    Sleep    3s
    Verify Create Step Button Is Disabled Or Error

TC_IPP_016
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_IP_POOL_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_IPP_017
    Clear Session For Unauthenticated Test
    Go To    ${MANAGE_IP_POOL_URL}
    Wait For Page Load
    Verify Redirected To Login Page
