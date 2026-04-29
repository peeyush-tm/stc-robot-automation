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

TC_SRM_001 Create MSISDN SIM Range Happy Path
    [Documentation]    Full E2E: Login > Admin > SIM Range > MSISDN tab > Create >
    ...                fill header > add MSISDN range > verify Pool Count > Submit >
    ...                verify success toast and redirect.
    [Tags]    smoke    regression    positive    TC_SRM_001
    TC_SRM_001

TC_SRM_002 Verify MSISDN Tab Selection Shows Grid
    [Documentation]    Navigate to SIM Range and verify the MSISDN tab loads the grid.
    [Tags]    smoke    regression    positive    TC_SRM_002
    TC_SRM_002

TC_SRM_003 Verify Create MSISDN SIM Range Page Elements Visible
    [Documentation]    Navigate to Create SIM Range (MSISDN) and verify all primary fields are present.
    [Tags]    smoke    regression    positive    TC_SRM_003
    TC_SRM_003

TC_SRM_004 Verify Assets Type Is Hidden For MSISDN Flow
    [Documentation]    When navigating via ?currentTab=1, Assets Type dropdown should be hidden.
    [Tags]    regression    positive    TC_SRM_004
    TC_SRM_004

TC_SRM_005 Verify Pool Count Auto Calculated After Adding MSISDN Range
    [Documentation]    Add a MSISDN range and verify Pool Count auto-calculates.
    [Tags]    regression    positive    TC_SRM_005
    TC_SRM_005

TC_SRM_006 Verify Pool Count Is Zero Before Adding MSISDN Range
    [Documentation]    On the Create form, Pool Count should be 0 before any range is added.
    [Tags]    regression    positive    TC_SRM_006
    TC_SRM_006

TC_SRM_007 Verify Pool Count Field Is Disabled
    [Documentation]    Pool Count should always be read-only (disabled).
    [Tags]    regression    positive    TC_SRM_007
    TC_SRM_007

TC_SRM_008 Verify MSISDN Range Grid Shows Entry After Adding
    [Documentation]    Add a MSISDN range and verify the grid shows at least one row.
    [Tags]    regression    positive    TC_SRM_008
    TC_SRM_008

TC_SRM_009 Verify Cancel Button Redirects To SIM Range List
    [Documentation]    Click Close on Create MSISDN SIM Range page and verify redirect to /SIMRange.
    [Tags]    regression    positive    TC_SRM_009
    TC_SRM_009

TC_SRM_010 Verify SIM Category Selection For MSISDN
    [Documentation]    If SIM Category dropdown is visible, verify it accepts a selection.
    [Tags]    regression    positive    TC_SRM_010
    TC_SRM_010

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — MISSING MANDATORY FIELDS
# ═══════════════════════════════════════════════════════════════════════

TC_SRM_011 Submit Disabled When Pool Name Empty
    [Documentation]    Leave Pool Name blank, fill all other fields and add range.
    ...                Submit should be disabled.
    [Tags]    regression    negative    TC_SRM_011
    TC_SRM_011

TC_SRM_012 Submit Disabled When Account Not Selected
    [Documentation]    Fill form but skip Account selection. Submit should be disabled.
    [Tags]    regression    negative    TC_SRM_012
    TC_SRM_012

TC_SRM_013 Submit Disabled When Description Empty
    [Documentation]    Fill form but leave Description blank. Submit should be disabled.
    [Tags]    regression    negative    TC_SRM_013
    TC_SRM_013

TC_SRM_014 Submit Disabled When No MSISDN Range Added
    [Documentation]    Fill all header fields but do not add any MSISDN range.
    ...                Pool Count stays "0" and Submit should be disabled.
    [Tags]    regression    negative    TC_SRM_014
    TC_SRM_014

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — INVALID RANGE DATA
# ═══════════════════════════════════════════════════════════════════════

TC_SRM_015 MSISDN From Greater Than To Should Show Error
    [Documentation]    Enter MSISDN From > MSISDN To. Popup Submit should trigger error toast.
    [Tags]    regression    negative    TC_SRM_015
    TC_SRM_015

TC_SRM_016 MSISDN From Below 10 Digits Keeps Popup Submit Disabled
    [Documentation]    Enter MSISDN From with fewer than 10 digits. Popup Submit should stay disabled.
    [Tags]    regression    negative    TC_SRM_016
    TC_SRM_016

TC_SRM_017 MSISDN To Below 10 Digits Keeps Popup Submit Disabled
    [Documentation]    Enter MSISDN To with fewer than 10 digits. Popup Submit should stay disabled.
    [Tags]    regression    negative    TC_SRM_017
    TC_SRM_017

TC_SRM_018 Overlapping MSISDN Range Should Show Error
    [Documentation]    Add a valid MSISDN range, then attempt to add an overlapping range.
    ...                Expect error toast.
    [Tags]    regression    negative    TC_SRM_018
    TC_SRM_018

TC_SRM_019 MSISDN Input Exceeding 15 Digits Gets Truncated
    [Documentation]    Enter a 16-digit number in MSISDN From. Verify it is truncated to 15 digits.
    [Tags]    regression    negative    TC_SRM_019
    TC_SRM_019

TC_SRM_020 Close MSISDN Popup Without Submitting Clears Fields
    [Documentation]    Open MSISDN popup, enter values, click Close. Popup should close and
    ...                no range row should be added.
    [Tags]    regression    negative    TC_SRM_020
    TC_SRM_020

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — BOUNDARY / SECURITY
# ═══════════════════════════════════════════════════════════════════════

TC_SRM_021 SQL Injection In Pool Name Should Be Rejected
    [Documentation]    Enter SQL injection in Pool Name. Verify error or app handles safely.
    [Tags]    regression    negative    TC_SRM_021
    TC_SRM_021

TC_SRM_022 Special Characters In Pool Name Should Be Rejected
    [Documentation]    Enter special characters in Pool Name. Verify error or app handles safely.
    [Tags]    regression    negative    TC_SRM_022
    TC_SRM_022

TC_SRM_023 Pool Name Exceeding Max Length Should Be Rejected
    [Documentation]    Enter 51-character Pool Name (max is 50). Verify truncation or error.
    [Tags]    regression    negative    TC_SRM_023
    TC_SRM_023

TC_SRM_024 Description Exceeding Max Length Should Be Rejected
    [Documentation]    Enter 501-character Description (max is 500). Verify truncation or error.
    [Tags]    regression    negative    TC_SRM_024
    TC_SRM_024

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_SRM_025 Direct Access To Create MSISDN SIM Range Without Login
    [Documentation]    Navigate directly to /CreateSIMRange?currentTab=1 without login.
    ...                Verify redirect to login page.
    [Tags]    regression    negative    TC_SRM_025
    TC_SRM_025

TC_SRM_026 Direct Access To SIM Range MSISDN Tab Without Login
    [Documentation]    Navigate directly to /SIMRange?currentTab=1 without login.
    ...                Verify redirect to login page.
    [Tags]    regression    negative    TC_SRM_026
    TC_SRM_026


*** Keywords ***
TC_SRM_001
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range With Ranges
    Verify Pool Count    ${EXPECTED_MSISDN_POOL_COUNT}
    Submit SIM Range Form
    Verify SIM Range Created Successfully

TC_SRM_002
    Login And Navigate To SIM Range MSISDN List
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_CREATE_BTN}    timeout=30s
    Log    MSISDN tab loaded with grid and Create button visible.

TC_SRM_003
    Login And Navigate To Create SIM Range MSISDN
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}       timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_ACCOUNT_DD}      timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_DESCRIPTION}     timeout=30s
    Wait Until Element Is Visible    ${LOC_SR_POOL_COUNT}      timeout=30s
    Wait Until Element Is Visible    ${LOC_MSISDN_PANEL}       timeout=30s
    Log    All Create MSISDN SIM Range form elements are visible.

TC_SRM_004
    Login And Navigate To Create SIM Range MSISDN
    Verify Assets Type Is Hidden

TC_SRM_005
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify Pool Count    ${EXPECTED_MSISDN_POOL_COUNT}

TC_SRM_006
    Login And Navigate To Create SIM Range MSISDN
    Verify Pool Count Is Zero Or Empty

TC_SRM_007
    Login And Navigate To Create SIM Range MSISDN
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_POOL_COUNT}
    Should Not Be True    ${enabled}    Pool Count should be disabled (read-only).

TC_SRM_008
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify MSISDN Grid Has Rows

TC_SRM_009
    Login And Navigate To Create SIM Range MSISDN
    Verify Cancel Redirects To SIM Range List

TC_SRM_010
    Login And Navigate To Create SIM Range MSISDN
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_SIM_CATEGORY_DD}    timeout=5s
    IF    ${visible}
        Select From List By Value    ${LOC_SR_SIM_CATEGORY_DD}    1
        ${selected}=    Get Value    ${LOC_SR_SIM_CATEGORY_DD}
        Should Be Equal As Strings    ${selected}    1
        Log    SIM Category "830" selected successfully.
    ELSE
        Log    SIM Category dropdown not visible (permission-based). Skipping.
    END

TC_SRM_011
    Login And Navigate To Create SIM Range MSISDN
    Select Account From Dropdown
    Enter SIM Range Description    ${MSISDN_DESCRIPTION}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify Submit Button Is Disabled

TC_SRM_012
    Login And Navigate To Create SIM Range MSISDN
    Enter Pool Name    ${MSISDN_POOL_NAME}
    Enter SIM Range Description    ${MSISDN_DESCRIPTION}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify Submit Button Is Disabled

TC_SRM_013
    Login And Navigate To Create SIM Range MSISDN
    Enter Pool Name    ${MSISDN_POOL_NAME}
    Select Account From Dropdown
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify Submit Button Is Disabled

TC_SRM_014
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Verify Pool Count Is Zero Or Empty
    Verify Submit Button Is Disabled

TC_SRM_015
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Open MSISDN Popup And Enter Range    ${MSISDN_FROM_GREATER_THAN_TO_FROM}    ${MSISDN_FROM_GREATER_THAN_TO_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_MSISDN_POPUP_SUBMIT}
    IF    ${submit_enabled}
        Click Element Via JS    ${LOC_MSISDN_POPUP_SUBMIT}
        Sleep    2s
        Verify Error Toast Or Popup Still Open    ${LOC_MSISDN_POPUP}
    ELSE
        Log    MSISDN popup Submit correctly disabled for From > To.
    END

TC_SRM_016
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Open MSISDN Popup And Enter Range    ${MSISDN_TOO_SHORT}    ${VALID_MSISDN_TO}
    Verify MSISDN Popup Submit Is Disabled

TC_SRM_017
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Open MSISDN Popup And Enter Range    ${VALID_MSISDN_FROM}    ${MSISDN_TOO_SHORT}
    Verify MSISDN Popup Submit Is Disabled

TC_SRM_018
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Open MSISDN Popup And Enter Range    ${OVERLAPPING_MSISDN_FROM}    ${OVERLAPPING_MSISDN_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_MSISDN_POPUP_SUBMIT}
    IF    ${submit_enabled}
        Click Element Via JS    ${LOC_MSISDN_POPUP_SUBMIT}
        Sleep    2s
        Verify Error Toast Or Popup Still Open    ${LOC_MSISDN_POPUP}
    ELSE
        Log    MSISDN popup Submit disabled for overlapping range.
    END

TC_SRM_019
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Open MSISDN Popup
    Wait Until Element Is Visible    ${LOC_MSISDN_FROM}    timeout=30s
    Input Text    ${LOC_MSISDN_FROM}    ${MSISDN_EXCEEDS_MAX_LENGTH}
    Sleep    1s
    ${actual_value}=    Get Value    ${LOC_MSISDN_FROM}
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} <= 15
    ...    MSISDN From should be truncated to max 15 digits but has ${length} digits.

TC_SRM_020
    Login And Navigate To Create SIM Range MSISDN
    Fill MSISDN SIM Range Header
    Open MSISDN Popup And Enter Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Close MSISDN Popup Without Submitting
    Verify MSISDN Popup Is Closed
    ${grid_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_MSISDN_GRID}
    IF    ${grid_visible}
        ${rows}=    Get Element Count    ${LOC_MSISDN_GRID_ROW}
        Should Be Equal As Integers    ${rows}    0
        ...    No MSISDN range rows should exist after closing popup without submit.
    ELSE
        Log    MSISDN grid not visible — no ranges added. Correct behaviour.
    END

TC_SRM_021
    Login And Navigate To Create SIM Range MSISDN
    Enter Pool Name    ${SQL_INJECTION_POOL_NAME}
    Select Account From Dropdown
    Enter SIM Range Description    ${MSISDN_DESCRIPTION}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    SQL Injection in MSISDN Pool Name
    ELSE
        Log    Submit button disabled for SQL injection input — validation working.
    END

TC_SRM_022
    Login And Navigate To Create SIM Range MSISDN
    Enter Pool Name    ${SPECIAL_CHARS_POOL_NAME}
    Select Account From Dropdown
    Enter SIM Range Description    ${MSISDN_DESCRIPTION}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    Special Characters in MSISDN Pool Name
    ELSE
        Log    Submit button disabled for special characters — validation working.
    END

TC_SRM_023
    Login And Navigate To Create SIM Range MSISDN
    Enter Pool Name    ${POOL_NAME_EXCEEDS_MAX}
    Select Account From Dropdown
    Enter SIM Range Description    ${MSISDN_DESCRIPTION}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    Pool Name exceeding max length
    ELSE
        Log    Submit button disabled for overlength Pool Name — validation working.
    END

TC_SRM_024
    Login And Navigate To Create SIM Range MSISDN
    Enter Pool Name    ${MSISDN_POOL_NAME}
    Select Account From Dropdown
    Enter SIM Range Description    ${DESCRIPTION_EXCEEDS_MAX}
    Select SIM Category If Visible
    Add MSISDN Range    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${submit_enabled}
        Submit SIM Range Form
        Verify Negative SIM Range Outcome    Description exceeding max length
    ELSE
        Log    Submit button disabled for overlength Description — validation working.
    END

TC_SRM_025
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_SIM_RANGE_MSISDN_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_SRM_026
    Clear Session For Unauthenticated Test
    Go To    ${SIM_RANGE_MSISDN_URL}
    Wait For Page Load
    Verify Redirected To Login Page
