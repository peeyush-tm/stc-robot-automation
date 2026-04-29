*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/sim_range_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/sim_range_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/sim_range_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_SR_001 Create SIM Range Via ICCID IMSI Successfully
    [Documentation]    Full E2E: Login > Admin > SIM Range > Create > fill form > add ICCID range >
    ...                add IMSI range > verify Pool Count > Submit > verify success toast, redirect,
    ...                and validate ICCID/IMSI columns and pool name in the listing grid.
    [Tags]    smoke    regression    positive    TC_SR_001
    TC_SR_001

TC_SR_002 Verify Create SIM Range Page Elements Visible
    [Documentation]    Navigate to Create SIM Range and verify all primary fields are present.
    [Tags]    smoke    regression    positive    TC_SR_002
    TC_SR_002

TC_SR_003 Verify Pool Count Auto Calculated After Adding Ranges
    [Documentation]    Add ICCID and IMSI ranges, verify Pool Count auto-calculates to 10.
    [Tags]    regression    positive    TC_SR_003
    TC_SR_003

TC_SR_004 Verify Cancel Button Redirects To SIM Range List
    [Documentation]    Click Close on Create SIM Range page.
    ...                Verify: redirected to /SIMRange listing.
    [Tags]    regression    positive    TC_SR_004
    TC_SR_004

TC_SR_005 Verify ICCID IMSI Tab Selection Shows Grid
    [Documentation]    Navigate to SIM Range list and verify ICCID/IMSI tab loads the grid.
    [Tags]    regression    positive    TC_SR_005
    TC_SR_005

TC_SR_006 Verify ICCID Range Grid Shows Entry After Adding
    [Documentation]    Add an ICCID range and verify the grid shows at least one row.
    [Tags]    regression    positive    TC_SR_006
    TC_SR_006

TC_SR_007 Verify IMSI Range Grid Shows Entry After Adding
    [Documentation]    Add an IMSI range and verify the grid shows at least one row.
    [Tags]    regression    positive    TC_SR_007
    TC_SR_007

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — MISSING MANDATORY FIELDS
# ═══════════════════════════════════════════════════════════════════════

TC_SR_008 Submit Button Disabled When Pool Name Empty
    [Documentation]    Leave Pool Name blank, fill other fields. Submit should be disabled.
    [Tags]    regression    negative    TC_SR_008
    TC_SR_008

TC_SR_009 Submit Button Disabled When Account Not Selected
    [Documentation]    Fill form; clear Account to placeholder (app may pre-select default).
    ...                Submit should be disabled without a real account.
    [Tags]    regression    negative    TC_SR_009
    TC_SR_009

TC_SR_010 Submit Button Disabled When Description Empty
    [Documentation]    Fill form but leave Description blank. Submit should be disabled.
    [Tags]    regression    negative    TC_SR_010
    TC_SR_010

TC_SR_011 Submit Button Disabled When No ICCID Range Added
    [Documentation]    Fill form fields but skip adding ICCID range. Submit should be disabled.
    [Tags]    regression    negative    TC_SR_011
    TC_SR_011

TC_SR_012 Submit Button Disabled When ICCID And IMSI Counts Mismatch
    [Documentation]    Add 10-count ICCID but 5-count IMSI. Submit should be disabled or show error.
    [Tags]    regression    negative    TC_SR_012
    TC_SR_012

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — INVALID RANGE DATA
# ═══════════════════════════════════════════════════════════════════════

TC_SR_013 ICCID From Greater Than To Should Show Error
    [Documentation]    Enter ICCID From > ICCID To in popup. Submit should be blocked or error shown.
    [Tags]    regression    negative    TC_SR_013
    TC_SR_013

TC_SR_014 ICCID Too Short Should Keep Popup Submit Disabled
    [Documentation]    Enter ICCID value shorter than 17 digits. Popup Submit should stay disabled.
    [Tags]    regression    negative    TC_SR_014
    TC_SR_014

TC_SR_015 IMSI From Greater Than To Should Show Error
    [Documentation]    Enter IMSI From > IMSI To in popup. Submit should be blocked or error shown.
    [Tags]    regression    negative    TC_SR_015
    TC_SR_015

TC_SR_016 IMSI Too Short Should Keep Popup Submit Disabled
    [Documentation]    Enter IMSI value shorter than 15 digits. Popup Submit should stay disabled.
    [Tags]    regression    negative    TC_SR_016
    TC_SR_016

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — BOUNDARY / INVALID DATA
# ═══════════════════════════════════════════════════════════════════════

TC_SR_017 SQL Injection In Pool Name Should Be Rejected
    [Documentation]    Enter SQL injection in Pool Name. Verify error or app handles safely.
    [Tags]    regression    negative    TC_SR_017
    TC_SR_017

TC_SR_018 Special Characters In Pool Name Should Be Rejected
    [Documentation]    Enter special characters in Pool Name. Verify error or app handles safely.
    [Tags]    regression    negative    TC_SR_018
    TC_SR_018

TC_SR_019 Pool Name Exceeding Max Length Should Be Rejected
    [Documentation]    Enter 51-character Pool Name (max is 50). Verify truncation or error.
    [Tags]    regression    negative    TC_SR_019
    TC_SR_019

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_SR_020 Direct Access To Create SIM Range Without Login Should Redirect
    [Documentation]    Navigate directly to /CreateSIMRange without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    TC_SR_020
    TC_SR_020

TC_SR_021 Direct Access To SIM Range Without Login Should Redirect
    [Documentation]    Navigate directly to /SIMRange without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    TC_SR_021
    TC_SR_021

*** Keywords ***
TC_SR_001
    Login And Navigate To Create SIM Range
    Fill SIM Range With ICCID And IMSI
    Verify Pool Count    ${EXPECTED_POOL_COUNT}
    Submit SIM Range Form
    Verify SIM Range Created Successfully
    Validate SIM Range Grid Row    ${VALID_POOL_NAME}    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    ...    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}    ${EXPECTED_POOL_COUNT}

TC_SR_002
    Login And Navigate To Create SIM Range
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}       timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_ACCOUNT_DD}      timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_DESCRIPTION}     timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_POOL_COUNT}      timeout=30s
    Wait Until Element Is Visible    ${LOC_ICCID_PANEL}        timeout=30s
    Wait Until Element Is Visible    ${LOC_ADD_ICCID_BTN}      timeout=30s
    Log    All Create SIM Range form elements are visible.

TC_SR_003
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    Verify Pool Count    ${EXPECTED_POOL_COUNT}

TC_SR_004
    Login And Navigate To Create SIM Range
    Verify Cancel Redirects To SIM Range List

TC_SR_005
    Login And Navigate To SIM Range List
    Select ICCID IMSI Tab
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_CREATE_BTN}    timeout=30s
    Log    ICCID/IMSI tab loaded with grid and Create button visible.

TC_SR_006
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    ${rows}=    Get Element Count    xpath=//div[@id='iccidRangeTable']//table//tbody/tr
    Should Be True    ${rows} >= 1    ICCID grid should show at least 1 row after adding range.

TC_SR_007
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    ${rows}=    Get Element Count    xpath=//div[@id='imsiRangeTable']//table//tbody/tr
    Should Be True    ${rows} >= 1    IMSI grid should show at least 1 row after adding range.

TC_SR_008
    Login And Navigate To Create SIM Range
    Select Account From Dropdown
    Enter SIM Range Description    ${VALID_SR_DESCRIPTION}
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    Verify Submit Button Is Disabled

TC_SR_009
    Login And Navigate To Create SIM Range
    Enter Pool Name    ${VALID_POOL_NAME}
    Enter SIM Range Description    ${VALID_SR_DESCRIPTION}
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    Clear Account Selection On SIM Range
    Verify Submit Button Is Disabled

TC_SR_010
    Login And Navigate To Create SIM Range
    Enter Pool Name    ${VALID_POOL_NAME}
    Select Account From Dropdown
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    Verify Submit Button Is Disabled

TC_SR_011
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Verify Pool Count Is Zero Or Empty
    Verify Submit Button Is Disabled

TC_SR_012
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${MISMATCHED_IMSI_FROM}    ${MISMATCHED_IMSI_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    ICCID/IMSI count mismatch
    ELSE
        Log    Submit button correctly disabled for mismatched ICCID/IMSI counts.
    END

TC_SR_013
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Open ICCID Popup And Enter Range    ${ICCID_FROM_GREATER_THAN_TO_FROM}    ${ICCID_FROM_GREATER_THAN_TO_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_ICCID_POPUP_SUBMIT}
    IF    ${submit_enabled}
        Click Element Via JS    ${LOC_ICCID_POPUP_SUBMIT}
        Sleep    2s
        Verify Error Toast Or Popup Still Open    ${LOC_ICCID_POPUP}
    ELSE
        Log    ICCID popup Submit correctly disabled for From > To.
    END

TC_SR_014
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Open ICCID Popup And Enter Range    ${ICCID_TOO_SHORT}    ${ICCID_TOO_SHORT}
    Verify ICCID Popup Submit Is Disabled

TC_SR_015
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Open IMSI Popup And Enter Range    ${IMSI_FROM_GREATER_THAN_TO_FROM}    ${IMSI_FROM_GREATER_THAN_TO_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_IMSI_POPUP_SUBMIT}
    IF    ${submit_enabled}
        Click Element Via JS    ${LOC_IMSI_POPUP_SUBMIT}
        Sleep    2s
        Verify Error Toast Or Popup Still Open    ${LOC_IMSI_POPUP}
    ELSE
        Log    IMSI popup Submit correctly disabled for From > To.
    END

TC_SR_016
    Login And Navigate To Create SIM Range
    Fill SIM Range Form
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Open IMSI Popup And Enter Range    ${IMSI_TOO_SHORT}    ${IMSI_TOO_SHORT}
    Verify IMSI Popup Submit Is Disabled

TC_SR_017
    Login And Navigate To Create SIM Range
    Enter Pool Name    ${SQL_INJECTION_POOL_NAME}
    Select Account From Dropdown
    Enter SIM Range Description    ${VALID_SR_DESCRIPTION}
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    SQL Injection in Pool Name
    ELSE
        Log    Submit button disabled for SQL injection input — validation working.
    END

TC_SR_018
    Login And Navigate To Create SIM Range
    Enter Pool Name    ${SPECIAL_CHARS_POOL_NAME}
    Select Account From Dropdown
    Enter SIM Range Description    ${VALID_SR_DESCRIPTION}
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    Special Characters in Pool Name
    ELSE
        Log    Submit button disabled for special characters — validation working.
    END

TC_SR_019
    Login And Navigate To Create SIM Range
    Enter Pool Name    ${POOL_NAME_EXCEEDS_MAX}
    Select Account From Dropdown
    Enter SIM Range Description    ${VALID_SR_DESCRIPTION}
    Add ICCID Range    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    Add IMSI Range    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    Pool Name exceeding max length
    ELSE
        Log    Submit button disabled for overlength Pool Name — validation working.
    END

TC_SR_020
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_SIM_RANGE_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_SR_021
    Clear Session For Unauthenticated Test
    Go To    ${SIM_RANGE_URL}
    Wait For Page Load
    Verify Redirected To Login Page
