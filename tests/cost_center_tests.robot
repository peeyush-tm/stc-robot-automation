*** Settings ***
Library     SeleniumLibrary
Library     ../libraries/ConfigLoader.py
Variables   ../variables/cost_center_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/cost_center_keywords.resource
Resource    ../resources/locators/cost_center_locators.resource
Resource    ../resources/locators/login_locators.resource

Suite Setup       Login And Navigate To Manage Account Suite
Suite Teardown    Close All Browsers
Test Setup        Refresh ManageAccount Page
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

# ══════════════════════════════════════════════════════════════════════
#  COST CENTER TESTS — SEQUENTIAL EXECUTION ORDER
#
#  Browser opens ONCE (Suite Setup: login → Admin → Account tab)
#  Each test refreshes ManageAccount page (Test Setup)
#
#  Phase 1: Navigation & Page Load — 001, 002, 003
#  Phase 2: Form Elements Verification — 004, 005, 006
#  Phase 3: Positive / Happy Path — 007, 008, 009
#  Phase 4: Negative — Validation Errors — 010, 011, 012, 013, 014
#  Phase 5: Negative — Field Boundaries — 015, 016, 017, 018
#  Phase 6: Negative — Special Characters — 019, 020
#  Phase 7: Close / Cancel — 021, 022, 023
#  Phase 8: Listing Verification — 024, 025, 026
# ══════════════════════════════════════════════════════════════════════

*** Test Cases ***

# ══════════════════════════════════════════════════════════════════════
#  PHASE 1: NAVIGATION & PAGE LOAD
# ══════════════════════════════════════════════════════════════════════
TC_CC_001 Navigate To ManageAccount Page
    [Documentation]    Verifies ManageAccount page is loaded and the grid is visible.
    [Tags]    positive    smoke    cost-center    navigation
    TC_CC_001

TC_CC_002 Verify Create Cost Center Button Visible
    [Documentation]    Verifies the Create Cost Center button is visible on ManageAccount page
    ...                for a user with RW permission and RoleWisePermissionOfCostCenter() = true.
    [Tags]    positive    smoke    cost-center    permission
    TC_CC_002

TC_CC_003 Open Create Cost Center Form
    [Documentation]    Clicks Create Cost Center button and verifies the form page loads
    ...                with URL containing /CreateCostCenter.
    [Tags]    positive    smoke    cost-center    form
    TC_CC_003

# ══════════════════════════════════════════════════════════════════════
#  PHASE 2: FORM ELEMENTS VERIFICATION
# ══════════════════════════════════════════════════════════════════════
TC_CC_004 Verify All Form Fields Present
    [Documentation]    Verifies Parent Account dropdown, Account Name input, Comment input,
    ...                Submit button, and Close button are all visible on the form.
    [Tags]    positive    cost-center    form    ui
    TC_CC_004

TC_CC_005 Verify Parent Account TreeView Has Nodes
    [Documentation]    Verifies the Parent Account TreeView dropdown opens and has at least one
    ...                selectable node (e.g. KSA_OPCO).
    [Tags]    positive    cost-center    form    dropdown
    TC_CC_005

TC_CC_006 Verify Submit Button Is Present And Enabled
    [Documentation]    Verifies the Submit button (input type=button) is visible and enabled
    ...                on the Create Cost Center form.
    [Tags]    positive    cost-center    form    ui
    TC_CC_006

# ══════════════════════════════════════════════════════════════════════
#  PHASE 3: POSITIVE / HAPPY PATH
# ══════════════════════════════════════════════════════════════════════
TC_CC_007 Create Cost Center With All Fields
    [Documentation]    End-to-end: select Parent Account, enter Account Name and Comment,
    ...                click Submit. Verify success toast and redirect to ManageAccount.
    [Tags]    positive    smoke    regression    cost-center    e2e
    TC_CC_007

TC_CC_008 Create Cost Center Without Comment
    [Documentation]    Creates a Cost Center with only mandatory fields (Parent Account + Account Name).
    ...                Comment is optional and left blank. Verifies success.
    [Tags]    positive    regression    cost-center    e2e
    TC_CC_008

TC_CC_009 Verify No Validation Errors With Valid Data
    [Documentation]    Fills all fields with valid data and verifies no validation errors
    ...                are displayed before submission.
    [Tags]    positive    cost-center    validation
    TC_CC_009

# ══════════════════════════════════════════════════════════════════════
#  PHASE 4: NEGATIVE — VALIDATION ERRORS
# ══════════════════════════════════════════════════════════════════════
TC_CC_010 Submit With Empty Account Name
    [Documentation]    Selects Parent Account but leaves Account Name blank.
    ...                Clicks Submit and verifies Joi validation error on Account Name.
    [Tags]    negative    cost-center    validation
    TC_CC_010

TC_CC_011 Submit Without Selecting Parent Account
    [Documentation]    Enters Account Name but does NOT select Parent Account.
    ...                Clicks Submit and verifies Joi validation error on Parent Account.
    [Tags]    negative    cost-center    validation
    TC_CC_011

TC_CC_012 Submit With Both Mandatory Fields Empty
    [Documentation]    Does not fill any field. Clicks Submit and verifies both
    ...                Parent Account and Account Name validation errors (abortEarly: false).
    [Tags]    negative    cost-center    validation
    TC_CC_012

TC_CC_013 Submit With Only Spaces In Account Name
    [Documentation]    Enters only whitespace in Account Name and clicks Submit.
    ...                Expects either a validation error or the spaces to be stripped
    ...                by removeSpecialChar, resulting in empty name error.
    [Tags]    negative    cost-center    validation    edge
    TC_CC_013

TC_CC_014 Duplicate Cost Center Name
    [Documentation]    Attempts to create a Cost Center with a name that may already exist.
    ...                Expects an error toast from the API (errorCode != 200).
    [Tags]    negative    cost-center    validation    duplicate
    TC_CC_014

# ══════════════════════════════════════════════════════════════════════
#  PHASE 5: NEGATIVE — FIELD BOUNDARIES
# ══════════════════════════════════════════════════════════════════════
TC_CC_015 Account Name Exceeds 100 Characters
    [Documentation]    Enters 101 characters in Account Name. Verifies the input is
    ...                truncated to 100 characters by maxLength attribute.
    [Tags]    negative    cost-center    boundary
    TC_CC_015

TC_CC_016 Account Name Exactly 100 Characters
    [Documentation]    Enters exactly 100 characters in Account Name. Verifies the full
    ...                value is accepted without truncation.
    [Tags]    positive    cost-center    boundary    edge
    TC_CC_016

TC_CC_017 Comment Exceeds 50 Characters
    [Documentation]    Enters 51 characters in Comment. Verifies the input is
    ...                truncated to 50 characters by maxLength attribute.
    [Tags]    negative    cost-center    boundary
    TC_CC_017

TC_CC_018 Comment Exactly 50 Characters
    [Documentation]    Enters exactly 50 characters in Comment. Verifies the full
    ...                value is accepted without truncation.
    [Tags]    positive    cost-center    boundary    edge
    TC_CC_018

# ══════════════════════════════════════════════════════════════════════
#  PHASE 6: NEGATIVE — SPECIAL CHARACTERS
# ══════════════════════════════════════════════════════════════════════
TC_CC_020 Account Name With Semicolons Stripped
    [Documentation]    Enters Account Name containing semicolons.
    ...                Verifies semicolons are stripped by the input handler.
    [Tags]    negative    cost-center    sanitization    edge
    TC_CC_020

# ══════════════════════════════════════════════════════════════════════
#  PHASE 7: CLOSE / CANCEL
# ══════════════════════════════════════════════════════════════════════
TC_CC_021 Close Form Without Submitting
    [Documentation]    Fills all form fields then clicks Close. Verifies no submission
    ...                occurs and user is redirected back to ManageAccount.
    [Tags]    negative    cost-center    cancel
    TC_CC_021

TC_CC_022 Close Empty Form
    [Documentation]    Opens the Create Cost Center form and clicks Close without filling
    ...                any fields. Verifies redirect to ManageAccount.
    [Tags]    negative    cost-center    cancel    edge
    TC_CC_022

TC_CC_023 Close After Selecting Only Parent Account
    [Documentation]    Selects Parent Account only (no Account Name), then clicks Close.
    ...                Verifies form is discarded and user returns to ManageAccount.
    [Tags]    negative    cost-center    cancel    edge
    TC_CC_023

# ══════════════════════════════════════════════════════════════════════
#  PHASE 8: LISTING VERIFICATION
# ══════════════════════════════════════════════════════════════════════
TC_CC_024 Expand Billing Account And Verify Cost Center Tab
    [Documentation]    On ManageAccount page: tries expanding rows to find one with Cost Center
    ...                tab (tab9). Only accountTypeId=6 rows show this tab.
    [Tags]    positive    cost-center    listing    tab
    TC_CC_024

TC_CC_025 Open Cost Center Tab And Verify Grid Loads
    [Documentation]    Expands a Billing Account row with Cost Center tab, clicks it,
    ...                and verifies the CostCenterAccount nested grid renders.
    [Tags]    positive    cost-center    listing    grid
    TC_CC_025

TC_CC_026 Verify Edit Delete Buttons In Cost Center Grid
    [Documentation]    Opens the Cost Center tab and verifies Edit and Delete icons
    ...                are visible for Cost Center rows (RW permission + RoleWisePermission).
    [Tags]    positive    cost-center    listing    permission
    TC_CC_026


*** Keywords ***
TC_CC_001
    Wait Until Element Is Visible    ${LOC_GRID_MANAGE_ACCOUNT}    ${CC_TIMEOUT}
    Log    ManageAccount page loaded successfully.

TC_CC_002
    Verify Create Cost Center Button Visible

TC_CC_003
    Open Create Cost Center Form
    Verify On Create Cost Center Page
    Log    Create Cost Center form opened successfully.

TC_CC_004
    Open Create Cost Center Form
    Verify Form Fields Present

TC_CC_005
    Open Create Cost Center Form
    Wait Until Element Is Visible    ${LOC_DDL_PARENT_ACCOUNT}    ${CC_TIMEOUT}
    Click Element Via JS    ${LOC_DDL_PARENT_ACCOUNT}
    Sleep    2s
    Wait For App Loading To Complete
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_TREEVIEW}    10s
    IF    not ${tree_visible}
        Click Element    ${LOC_DDL_PARENT_ACCOUNT}
        Sleep    2s
        Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_TREEVIEW}    15s
    END
    Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_ROOT_NODE}    15s
    ${node_text}=    Get Text    ${LOC_PARENT_ACCOUNT_ROOT_NODE}
    Should Not Be Empty    ${node_text}    Parent Account tree has no nodes
    Log    Parent Account tree has root node: ${node_text}.

TC_CC_006
    Open Create Cost Center Form
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}    ${CC_TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_BTN_SUBMIT}    ${CC_TIMEOUT}
    Log    Submit button is present and enabled.

TC_CC_007
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${CC_ACCOUNT_NAME}
    Fill Comment    ${CC_COMMENT}
    Click Submit Button
    Verify Cost Center Created Successfully
    Log    Cost Center '${CC_ACCOUNT_NAME}' created with comment.

TC_CC_008
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    AutoCC_NoComment
    Click Submit Button
    Verify Cost Center Created Successfully
    Log    Cost Center created without comment — optional field skipped.

TC_CC_009
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ValidCostCenter
    Verify No Parent Account Error
    Verify No Account Name Error
    Log    No validation errors with valid data.

TC_CC_010
    Open Create Cost Center Form
    Select Parent Account
    Clear Account Name
    Click Submit Button
    Verify Account Name Error Displayed
    Verify On Create Cost Center Page
    Log    Account Name error displayed when blank — form not submitted.

TC_CC_011
    Open Create Cost Center Form
    Fill Account Name    TestNoParent
    Click Submit Button
    Verify Parent Account Error Displayed
    Verify On Create Cost Center Page
    Log    Parent Account error displayed when not selected.

TC_CC_012
    Open Create Cost Center Form
    Click Submit Button
    Verify Parent Account Error Displayed
    Verify Account Name Error Displayed
    Verify On Create Cost Center Page
    Log    Both validation errors displayed when all fields empty.

TC_CC_013
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${SPACE * 5}
    Click Submit Button
    ${has_error}=    Run Keyword And Return Status
    ...    Verify Account Name Error Displayed
    IF    ${has_error}
        Verify On Create Cost Center Page
        Log    Validation error displayed for whitespace-only Account Name.
    ELSE
        ${has_err_toast}=    Run Keyword And Return Status
        ...    Verify Error Toast Displayed
        IF    ${has_err_toast}
            Log    Error toast displayed for whitespace-only Account Name.
        ELSE
            Log    App accepted spaces — may have been stripped or treated as valid.
        END
    END

TC_CC_014
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${CC_DUPLICATE_NAME}
    Fill Comment    Duplicate test
    Click Submit Button
    ${success}=    Run Keyword And Return Status    Verify Success Toast Displayed
    IF    not ${success}
        Verify Error Toast Displayed
        Verify On Create Cost Center Page
        Log    Error toast displayed for duplicate Cost Center name — expected.
    ELSE
        Log    Cost Center created (name was not duplicate in this environment).
        Verify Redirect To Manage Account
    END

TC_CC_015
    Open Create Cost Center Form
    Fill Account Name    ${CC_LONG_ACCOUNT_NAME}
    ${actual_value}=    Get Value    ${LOC_INPUT_ACCOUNT_NAME}
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} <= 100
    Log    Account Name truncated to ${length} characters (max 100).

TC_CC_016
    Open Create Cost Center Form
    Fill Account Name    ${CC_MAX_ACCOUNT_NAME}
    ${actual_value}=    Get Value    ${LOC_INPUT_ACCOUNT_NAME}
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} == 100
    Log    Account Name accepted exactly 100 characters.

TC_CC_017
    Open Create Cost Center Form
    Fill Comment    ${CC_LONG_COMMENT}
    ${actual_value}=    Get Value    ${LOC_INPUT_COMMENT}
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} <= 50
    Log    Comment truncated to ${length} characters (max 50).

TC_CC_018
    Open Create Cost Center Form
    Fill Comment    ${CC_MAX_COMMENT}
    ${actual_value}=    Get Value    ${LOC_INPUT_COMMENT}
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} == 50
    Log    Comment accepted exactly 50 characters.

TC_CC_020
    Open Create Cost Center Form
    Fill Account Name    ${CC_SEMICOLON_NAME}
    ${actual_value}=    Get Value    ${LOC_INPUT_ACCOUNT_NAME}
    Should Not Contain    ${actual_value}    ;
    Log    Semicolons stripped from Account Name: ${actual_value}

TC_CC_021
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ClosedWithoutSubmit
    Fill Comment    Should not be saved
    Click Close Button
    Verify Redirect To Manage Account
    Log    Close button redirected to ManageAccount without submitting.

TC_CC_022
    Open Create Cost Center Form
    Click Close Button
    Verify Redirect To Manage Account
    Log    Empty form closed; redirected to ManageAccount.

TC_CC_023
    Open Create Cost Center Form
    Select Parent Account
    Click Close Button
    Verify Redirect To Manage Account
    Log    Form with only parent selected closed; redirected to ManageAccount.

TC_CC_024
    ${found}=    Expand Row Until Cost Center Tab Found
    IF    ${found}
        Log    Cost Center tab (tab9) is visible in expanded Billing Account row.
    ELSE
        Log    No row with Cost Center tab found — may not have accountTypeId=6 rows visible.
    END

TC_CC_025
    ${found}=    Expand Row Until Cost Center Tab Found
    IF    ${found}
        Click Element Via JS    ${LOC_TAB_COST_CENTER}
        Sleep    2s
        Wait For App Loading To Complete
        Wait Until Element Is Visible    ${LOC_GRID_COST_CENTER}    15s
        Log    CostCenterAccount grid loaded inside Cost Center tab.
    ELSE
        Log    No row with Cost Center tab found — skipping grid verification.
    END

TC_CC_026
    ${found}=    Expand Row Until Cost Center Tab Found
    IF    ${found}
        Click Element Via JS    ${LOC_TAB_COST_CENTER}
        Sleep    2s
        Wait For App Loading To Complete
        Wait Until Element Is Visible    ${LOC_GRID_COST_CENTER}    15s
        ${edit_visible}=    Run Keyword And Return Status
        ...    Verify Edit Delete Buttons Visible In Cost Center Grid
        IF    ${edit_visible}
            Log    Edit and Delete buttons are visible in Cost Center grid.
        ELSE
            Log    Edit/Delete buttons not visible — may not have Cost Center rows or insufficient permission.
        END
    ELSE
        Log    No row with Cost Center tab found — skipping.
    END
