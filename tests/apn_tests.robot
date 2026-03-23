*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/apn_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/apn_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/apn_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_APN_001 Create Private APN With Static IPV4 Successfully
    [Documentation]    Navigate Service > APN, create a Private APN with Static IPV4.
    ...                Verify: success toast, redirect to /ManageAPN, grid visible.
    [Tags]    smoke    regression    positive    apn
    TC_APN_001

TC_APN_002 Create Public APN With Dynamic IPV4 Successfully
    [Documentation]    Create a Public APN with Dynamic IPV4 allocation.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_002

TC_APN_003 Create Private APN With IPV6 Successfully
    [Documentation]    Create a Private APN with IPV6 addressing and Dynamic allocation.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_003

TC_APN_004 Create APN With IPV4 And IPV6 Dual Stack Successfully
    [Documentation]    Create a Private APN with IPV4 & IPV6 dual-stack.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_004

TC_APN_005 Create APN With Secondary Details
    [Documentation]    Create Private APN with Secondary Details (HLR APN ID, MCC, MNC, Profile ID).
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn
    TC_APN_005

TC_APN_006 Create APN With QoS Details
    [Documentation]    Create Private APN with QoS 2G/3G and LTE bandwidth details.
    ...                Verify: success toast, redirect to /ManageAPN.
    [Tags]    regression    positive    apn    qos
    TC_APN_006

TC_APN_007 Verify Create APN Page Elements Are Visible
    [Documentation]    Navigate to Create APN page and verify all Primary Details fields are present.
    [Tags]    smoke    regression    positive    apn
    TC_APN_007

TC_APN_008 Verify IP Allocation Type Appears After IP Address Type Selection
    [Documentation]    Verify IP Allocation Type dropdown only appears after selecting IP Address Type.
    [Tags]    regression    positive    apn
    TC_APN_008

TC_APN_009 Verify Cancel Button Redirects To Manage APN
    [Documentation]    Click Cancel on Create APN page.
    ...                Verify: redirected to /ManageAPN listing.
    [Tags]    regression    positive    apn    navigation
    TC_APN_009

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — MISSING MANDATORY FIELDS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_010 Submit With No Fields Filled Should Show Error
    [Documentation]    Click Submit without filling any field.
    ...                Verify: validation error displayed, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_010

TC_APN_011 Missing APN Name Should Show Error
    [Documentation]    Fill all mandatory fields except APN Name, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_011

TC_APN_012 Missing APN ID Should Show Error
    [Documentation]    Fill all mandatory fields except APN ID, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_012

TC_APN_013 Missing APN Type Should Show Error
    [Documentation]    Leave APN Type as default (-Select-), fill other fields, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    Login And Navigate To Create APN
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_014 Missing IP Address Type Should Show Error
    [Documentation]    Fill all mandatory fields except IP Address Type, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_014

TC_APN_015 Missing IP Allocation Type Should Show Error
    [Documentation]    Select IP Address Type but leave IP Allocation as default, click Submit.
    ...                Verify: validation error, still on Create APN page.
    [Tags]    regression    negative    apn
    TC_APN_015

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — BOUNDARY / INVALID DATA
# ═══════════════════════════════════════════════════════════════════════

TC_APN_016 APN ID Exceeding 19 Digits Should Show Error
    [Documentation]    Enter a 20-digit APN ID value.
    ...                Verify: validation error for max length, still on Create APN page.
    [Tags]    regression    negative    apn    boundary
    TC_APN_016

TC_APN_017 Duplicate APN Name Should Show Error
    [Documentation]    Submit with an APN Name that already exists.
    ...                Verify: error toast (409 conflict) or validation error.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    apn
    TC_APN_017

TC_APN_018 SQL Injection In APN Name Should Be Rejected
    [Documentation]    Enter SQL injection payload in APN Name field.
    ...                Verify: validation error or error toast.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    security    apn
    Login And Navigate To Create APN
    ${sql_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 800)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${sql_apn_id}    ${SQL_INJECTION_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    SQL Injection in APN Name

TC_APN_019 Special Characters In APN Name Should Be Rejected
    [Documentation]    Enter special characters in APN Name field.
    ...                Verify: validation error or error toast.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    security    apn
    TC_APN_019

TC_APN_020 HLR APN ID Exceeding 19 Digits Should Show Error
    [Documentation]    Enter a 20-digit HLR APN ID in Secondary Details.
    ...                Verify: validation error for max length.
    ...                If the app accepts it, a warning is logged (server-side validation gap).
    [Tags]    regression    negative    apn    boundary
    TC_APN_020

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_APN_021 Direct Access To Create APN Without Login Should Redirect
    [Documentation]    Navigate directly to /CreateAPN without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    apn    navigation
    TC_APN_021

TC_APN_022 Direct Access To Manage APN Without Login Should Redirect
    [Documentation]    Navigate directly to /ManageAPN without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    apn    navigation
    TC_APN_022

*** Keywords ***
TC_APN_001
    Login And Navigate To Create APN
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${VALID_APN_ID}    ${VALID_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_002
    Login And Navigate To Create APN
    Fill Primary Details    ${APN_TYPE_PUBLIC}    ${PUBLIC_APN_ID}    ${PUBLIC_APN_NAME}
    ...    ${PUBLIC_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_003
    Login And Navigate To Create APN
    ${ipv6_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 100)
    ${ipv6_apn_name}=    Set Variable    auto-ipv6-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${ipv6_apn_id}    ${ipv6_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV6}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_004
    Login And Navigate To Create APN
    ${dual_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 200)
    ${dual_apn_name}=    Set Variable    auto-dual-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${dual_apn_id}    ${dual_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_BOTH}    ${VALID_IP_ALLOC_DYNAMIC}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_005
    Login And Navigate To Create APN
    ${sec_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 600)
    ${sec_apn_name}=    Set Variable    auto-sec-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${sec_apn_id}    ${sec_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Fill Secondary Details    ${VALID_HLR_APN_ID}    ${VALID_MCC}    ${VALID_MNC}    ${VALID_PROFILE_ID}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_006
    Login And Navigate To Create APN
    ${qos_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 700)
    ${qos_apn_name}=    Set Variable    auto-qos-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${qos_apn_id}    ${qos_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Fill QoS Details    ${VALID_QOS_PROFILE_2G3G}    ${VALID_QOS_BW_UPLINK_2G3G}    ${VALID_QOS_BW_DOWNLINK_2G3G}
    ...    ${VALID_QOS_PROFILE_LTE}    ${VALID_QOS_BW_UPLINK_LTE}    ${VALID_QOS_BW_DOWNLINK_LTE}
    Submit Create APN Form
    Verify APN Created Successfully

TC_APN_007
    Login And Navigate To Create APN
    Verify Primary Details Fields Visible

TC_APN_008
    Login And Navigate To Create APN
    Verify IP Alloc Type Appears After IP Selection

TC_APN_009
    Login And Navigate To Create APN
    Verify Cancel Redirects To Manage APN

TC_APN_010
    Login And Navigate To Create APN
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_011
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${VALID_APN_ID}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_012
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_013
    Login And Navigate To Create APN
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_014
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_015
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${VALID_APN_ID}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_016
    Login And Navigate To Create APN
    Select APN Type    ${APN_TYPE_PRIVATE}
    Select Account
    Enter APN ID    ${APN_ID_EXCEEDS_MAX}
    Enter APN Name    ${VALID_APN_NAME}
    Enter Description    ${VALID_DESCRIPTION}
    Select IP Address Type    ${VALID_IP_ADDR_TYPE_IPV4}
    Select IP Allocation Type    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Validation Error Or Still On Page

TC_APN_017
    Login And Navigate To Create APN
    ${dup_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 999)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${dup_apn_id}    ${DUPLICATE_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    Duplicate APN Name

TC_APN_018
    Login And Navigate To Create APN
    ${sql_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 800)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${sql_apn_id}    ${SQL_INJECTION_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    SQL Injection in APN Name

TC_APN_019
    Login And Navigate To Create APN
    ${spec_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 850)
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${spec_apn_id}    ${SPECIAL_CHARS_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify Negative Submission Outcome    Special Characters in APN Name

TC_APN_020
    Login And Navigate To Create APN
    ${hlr_apn_id}=    Evaluate    str(int("${VALID_APN_ID}") + 900)
    ${hlr_apn_name}=    Set Variable    auto-hlr-err-${VALID_APN_NAME}
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${hlr_apn_id}    ${hlr_apn_name}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    Add And Fill Subnet Mask Entry
    Fill Secondary Details    hlr_apn_id=${HLR_APN_ID_EXCEEDS_MAX}
    Submit Create APN Form
    Verify Negative Submission Outcome    HLR APN ID exceeding 19 digits

TC_APN_021
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_APN_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_APN_022
    Clear Session For Unauthenticated Test
    Go To    ${MANAGE_APN_URL}
    Wait For Page Load
    Verify Redirected To Login Page
