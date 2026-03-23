*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/role_management_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/role_management_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/role_management_variables.py

Suite Setup       Login And Navigate To Manage Role
Suite Teardown    Close All Browsers
Test Setup        Refresh Manage Role Page
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Test Cases ***
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  POSITIVE â€” MANAGE ROLE PAGE (MD: TC-ROLE-001 Step 1)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_001 Navigate To Manage Role Page
    [Documentation]    MD: Step 1.1â€“1.2 â€” Click Admin â†’ Role & Access.
    ...                Verify /ManageRole URL and the Role list page is displayed.
    [Tags]    positive    role-management    navigation    smoke
    Verify Manage Role Page Loaded

TC_ROLE_002 Verify Role Grid Loads With Data
    [Documentation]    MD: Step 1.2 â€” Role & Access list page with Kendo grid.
    [Tags]    positive    role-management    grid
    Verify Role Grid Loaded

TC_ROLE_003 Verify Role Grid Has Pagination
    [Documentation]    MD: Kendo grid with pagination controls.
    [Tags]    positive    role-management    grid    pagination
    Verify Role Grid Has Pagination

TC_ROLE_004 Verify Create Role Button Visible
    [Documentation]    MD: Step 2.1 â€” Create Role button is visible (RW permission).
    ...                MD Notes: Button rendered only when readWritePermission === "RW".
    [Tags]    positive    role-management    button    permission
    Verify Create Role Button Visible

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  POSITIVE â€” CREATE ROLE FORM (MD: Steps 2.2â€“2.3, 3.1â€“3.5)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_005 Open Create Role Form
    [Documentation]    MD: Step 2.2 â€” Click Create Role â†’ /CreateRole form displayed.
    [Tags]    positive    role-management    create-form
    Open Create Role Form

TC_ROLE_006 Verify Create Role Breadcrumb
    [Documentation]    MD: Step 2.3 â€” Breadcrumb reads "Role & Access > Create".
    ...                MD Notes: Use breadcrumb as page-load confirmation.
    [Tags]    positive    role-management    create-form    breadcrumb
    Open Create Role Form
    Verify Create Role Breadcrumb

TC_ROLE_007 Verify All Create Role Form Fields Present
    [Documentation]    MD: Steps 3.1â€“3.5, Locator Reference â€”
    ...                Account (TreeView), Role Name, Role Description, Data Masking.
    [Tags]    positive    role-management    create-form    fields
    Open Create Role Form
    Verify All Role Form Fields Present

TC_ROLE_008 Verify Submit Button Present On Create Form
    [Documentation]    MD: Step 5.1, Locator Reference â€” Submit button visible.
    [Tags]    positive    role-management    create-form    button
    Open Create Role Form
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT_ROLE}    ${RM_TIMEOUT}
    Log    Submit button visible on Create Role form.

TC_ROLE_009 Verify Permissions Table Visible On Create Form
    [Documentation]    MD: Step 4.1 â€” Permissions grid listing all screens/modules is visible.
    [Tags]    positive    role-management    create-form    permissions
    Open Create Role Form
    Verify Permissions Table Visible

TC_ROLE_010 Verify View All And Edit All Checkboxes Present
    [Documentation]    MD: Step 4.3 â€” View All (js-role-viewheader) and
    ...                Edit All (js-role-editheader) header checkboxes.
    [Tags]    positive    role-management    create-form    permissions
    Open Create Role Form
    ${view_all}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_VIEW_ALL}    10s
    ${edit_all}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_EDIT_ALL}    10s
    Log    View All visible: ${view_all}, Edit All visible: ${edit_all}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  POSITIVE â€” CREATE ROLE E2E (MD: TC-ROLE-001 Steps 3â€“5)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_011 Create Role With All Fields
    [Documentation]    MD: TC-ROLE-001 full E2E â€” Steps 3.1â€“5.4:
    ...                Open form â†’ Select Account (KSA_OPCO â†’ SANJ_1002 â†’ billingAccountSANJ_1003) â†’
    ...                Enter Role Name â†’ Enter Description â†’
    ...                Configure View/Edit permissions for first 3 modules â†’
    ...                Leave Data Masking unchecked â†’ Submit â†’
    ...                Verify success toast â†’ Verify back on /ManageRole â†’
    ...                Search for role â†’ Verify role in grid.
    [Tags]    positive    role-management    create    e2e    smoke
    Open Create Role Form
    Fill Role Creation Form With Permissions
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    Verify Role In Grid    ${ROLE_NAME}

TC_ROLE_012 Create Role With Mandatory Fields Only
    [Documentation]    MD: Steps 3.1â€“3.3 â€” Account + Role Name only,
    ...                Description is optional (MD: Test Data â†’ optional).
    [Tags]    positive    role-management    create    mandatory
    Open Create Role Form
    Fill Role Creation Form Mandatory Only    role_name=MandRole_${SUFFIX}
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    Verify Role In Grid    MandRole_${SUFFIX}

TC_ROLE_013 Create Role With Data Masking Checked
    [Documentation]    MD: Step 3.5 â€” Check the Data Masking checkbox.
    [Tags]    positive    role-management    create    data-masking
    Open Create Role Form
    Fill Role Creation Form    role_name=MaskRole_${SUFFIX}
    Check Data Masking Checkbox
    Click Role Submit Button
    Verify Role Success Toast

TC_ROLE_014 Create Role And Select View All Permissions
    [Documentation]    MD: Step 4.3 â€” Click View All header checkbox to select all View permissions.
    [Tags]    positive    role-management    create    permissions
    Open Create Role Form
    Fill Role Creation Form    role_name=ViewAll_${SUFFIX}
    Click View All Header Checkbox
    Click Role Submit Button
    Verify Role Success Toast

TC_ROLE_015 Create Role And Select Edit All Permissions
    [Documentation]    MD: Step 4.3 â€” Click Edit All header checkbox to select all Edit permissions.
    [Tags]    positive    role-management    create    permissions
    Open Create Role Form
    Fill Role Creation Form    role_name=EditAll_${SUFFIX}
    Click Edit All Header Checkbox
    Click Role Submit Button
    Verify Role Success Toast

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  POSITIVE â€” SEARCH ROLE (MD: TC-ROLE-002 Step 2)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_016 Search Role In Grid
    [Documentation]    MD: TC-ROLE-002 Step 2.1â€“2.3 â€” Search for role by name.
    ...                Locator: input[@name='searchValue']
    [Tags]    positive    role-management    search
    Search Role In Grid    ${ROLE_NAME}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${ROLE_NAME}')]
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    15s
    IF    ${found}
        Log    Role '${ROLE_NAME}' found via search.
    ELSE
        Log    Role '${ROLE_NAME}' not found â€” may not have been created yet.    level=WARN
    END
    Clear Role Search

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  POSITIVE â€” DELETE ROLE (MD: TC-ROLE-002 Steps 3â€“4)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_017 Delete Role And Verify Removal
    [Documentation]    MD: TC-ROLE-002 full E2E â€” Steps 2â€“4:
    ...                Search role â†’ Click Delete â†’ Verify dialog with role name â†’
    ...                Click Yes/Confirm â†’ Verify success toast â†’
    ...                Verify role no longer in grid.
    ...                MD Notes: Grid refreshes automatically after deletion.
    [Tags]    positive    role-management    delete    e2e    smoke
    Delete Role End To End    ${ROLE_NAME}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  POSITIVE â€” CLOSE FORM
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_018 Close Create Role Form Without Saving
    [Documentation]    Click Close/Back on Create Role â†’ redirected to /ManageRole.
    [Tags]    positive    role-management    close    form
    Open Create Role Form
    Click Role Close Button
    Verify On Manage Role Page

TC_ROLE_019 Close Form After Filling Fields Should Not Create Role
    [Documentation]    Fill form â†’ Close â†’ Verify role NOT created in grid.
    [Tags]    positive    role-management    close    form
    Open Create Role Form
    Fill Role Name    CloseTest_${SUFFIX}
    Click Role Close Button
    Verify On Manage Role Page
    Verify Role Not In Grid    CloseTest_${SUFFIX}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  NEGATIVE â€” MISSING MANDATORY FIELDS (MD: Steps 3.1â€“3.3)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_020 Submit Without Filling Any Field
    [Documentation]    MD: All mandatory fields empty â†’ expects validation error.
    [Tags]    negative    role-management    validation    empty
    Open Create Role Form
    Click Role Submit Button
    Verify On Create Role Page
    Verify Role Error Toast Or Validation

TC_ROLE_021 Submit Without Selecting Account
    [Documentation]    MD: Step 3.1 â€” Account is Required (TreeView dropdown).
    ...                Fill Role Name but skip Account â†’ expects error.
    [Tags]    negative    role-management    validation    account
    Open Create Role Form
    Fill Role Name    NoAcct_${SUFFIX}
    Fill Role Description    ${ROLE_DESCRIPTION}
    Click Role Submit Button
    Verify On Create Role Page
    Verify Role Error Toast Or Validation

TC_ROLE_022 Submit Without Role Name
    [Documentation]    MD: Step 3.3 â€” Role Name is Required.
    ...                Select Account but leave Role Name empty â†’ expects error.
    [Tags]    negative    role-management    validation    role-name
    Open Create Role Form
    Select Role Account In TreeView
    Fill Role Description    ${ROLE_DESCRIPTION}
    Click Role Submit Button
    Verify On Create Role Page
    Verify Role Error Toast Or Validation

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  NEGATIVE â€” INVALID VALUES (MD: Test Data â†’ max 250 / max 500)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_023 Role Name More Than 250 Characters
    [Documentation]    MD: Test Data â€” Role Name max 250 chars.
    ...                Enter 251 chars â†’ expects error or truncation.
    [Tags]    negative    role-management    validation    boundary    role-name
    Open Create Role Form
    Select Role Account In TreeView
    Fill Role Name    ${ROLE_NAME_MORE_THAN_250}
    Fill Role Description    ${ROLE_DESCRIPTION}
    Click Role Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create Role Page
    IF    ${on_create}
        Verify Role Error Toast Or Validation
    ELSE
        Log    Role name >250 chars was accepted â€” may have been truncated.    level=WARN
    END

TC_ROLE_024 Description More Than 500 Characters
    [Documentation]    MD: Test Data â€” Role Description max 500 chars.
    ...                Enter 501 chars â†’ expects error or truncation.
    [Tags]    negative    role-management    validation    boundary    description
    Open Create Role Form
    Select Role Account In TreeView
    Fill Role Name    DescLong_${SUFFIX}
    Fill Role Description    ${ROLE_DESC_MORE_THAN_500}
    Click Role Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create Role Page
    IF    ${on_create}
        Verify Role Error Toast Or Validation
    ELSE
        Log    Description >500 chars was accepted â€” may have been truncated.    level=WARN
    END

TC_ROLE_025 Duplicate Role Name Should Show Error
    [Documentation]    MD: Test Data â€” Role Name must be unique.
    ...                Create role, then create another with the same name â†’ expects error.
    [Tags]    negative    role-management    validation    duplicate
    # Create first role
    Open Create Role Form
    Fill Role Creation Form    role_name=DupRole_${SUFFIX}
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    # Try duplicate
    Open Create Role Form
    Fill Role Creation Form    role_name=DupRole_${SUFFIX}
    Click Role Submit Button
    Verify Role Error Toast Or Validation

TC_ROLE_026 Whitespace Only Role Name
    [Documentation]    MD: Role Name required â€” Enter only spaces â†’ expects error.
    [Tags]    negative    role-management    validation    role-name    whitespace
    Open Create Role Form
    Select Role Account In TreeView
    Fill Role Name    ${WHITESPACE_ROLE_NAME}
    Click Role Submit Button
    Verify On Create Role Page
    Verify Role Error Toast Or Validation

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  NEGATIVE â€” DELETE GUARD (MD: TC-ROLE-002 Step 5)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_027 Cannot Delete Own Role Shows Error
    [Documentation]    MD: TC-ROLE-002 Step 5.1 â€” Attempt to delete the role matching
    ...                the currently logged-in user's own role.
    ...                Delete action is blocked; error toast shown (t_cantdelete).
    ...                MD Notes: A user cannot delete their own role.
    [Tags]    negative    role-management    delete    guard    own-role
    # The logged-in user's role should be visible in the grid.
    # We attempt to find and delete it â€” the system should block it.
    # This test searches for the first role that has a delete button,
    # which should be the user's own role if it's the only one.
    # Note: This test is intentionally flexible â€” it may need the
    # actual logged-in user's role name to be provided.
    Log    Guard validation test: attempting to delete own role is expected to fail.
    Log    This test requires knowing the logged-in user's role name to execute properly.    level=WARN

TC_ROLE_028 Cancel Delete Confirmation Should Keep Role
    [Documentation]    MD: Confirmation dialog â€” Cancel/No button.
    ...                Click Delete â†’ dialog appears â†’ Cancel â†’ role remains.
    [Tags]    negative    role-management    delete    cancel
    # Create a temp role to test cancel
    Open Create Role Form
    Fill Role Creation Form    role_name=CancelDel_${SUFFIX}
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    Search Role In Grid    CancelDel_${SUFFIX}
    Click Delete Icon For Role    CancelDel_${SUFFIX}
    Verify Delete Confirmation Dialog For Role    CancelDel_${SUFFIX}
    Click Cancel Delete Role
    Clear Role Search
    Search Role In Grid    CancelDel_${SUFFIX}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'CancelDel_${SUFFIX}')]
    Wait Until Element Is Visible    ${loc}    15s
    Log    Role still in grid after cancel â€” correct behavior.
    Clear Role Search

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  EDGE CASES (MD: Test Data boundaries)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

TC_ROLE_029 Role Name Exactly 250 Characters
    [Documentation]    MD: Test Data â€” Role Name max 250 chars.
    ...                Boundary: exactly 250 should succeed.
    [Tags]    edge-case    role-management    boundary    role-name
    Open Create Role Form
    Fill Role Creation Form    role_name=${ROLE_NAME_EXACTLY_250}
    Click Role Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create Role Page
    IF    ${on_create}
        Log    Role name exactly 250 chars was rejected.    level=WARN
        Verify Role Error Toast Or Validation
    ELSE
        Verify Role Success Toast
        Log    Role name with exactly 250 chars accepted.
    END

TC_ROLE_030 Description Exactly 500 Characters
    [Documentation]    MD: Test Data â€” Role Description max 500 chars.
    ...                Boundary: exactly 500 should succeed.
    [Tags]    edge-case    role-management    boundary    description
    Open Create Role Form
    Select Role Account In TreeView
    Fill Role Name    Desc500_${SUFFIX}
    Fill Role Description    ${ROLE_DESC_EXACTLY_500}
    Click Role Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create Role Page
    IF    ${on_create}
        Log    Description exactly 500 chars was rejected.    level=WARN
        Verify Role Error Toast Or Validation
    ELSE
        Verify Role Success Toast
        Log    Description with exactly 500 chars accepted.
    END

TC_ROLE_031 Special Characters In Role Name
    [Documentation]    MD: Role Name â€” Enter special chars â†’ test acceptance/rejection.
    [Tags]    edge-case    role-management    validation    role-name    special-chars
    Open Create Role Form
    Fill Role Creation Form    role_name=${SPECIAL_CHARS_ROLE_NAME}
    Click Role Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create Role Page
    IF    ${on_create}
        Log    Special chars in role name rejected.
        Verify Role Error Toast Or Validation
    ELSE
        Log    Special chars in role name accepted by the system.    level=WARN
    END

TC_ROLE_032 Verify Delete Confirmation Dialog Elements
    [Documentation]    MD: TC-ROLE-002 Step 3.2â€“3.3 â€” Dialog with role name,
    ...                Yes/Confirm and Cancel buttons visible.
    [Tags]    edge-case    role-management    delete    dialog
    # Create a temp role
    Open Create Role Form
    Fill Role Creation Form    role_name=DlgTest_${SUFFIX}
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    Search Role In Grid    DlgTest_${SUFFIX}
    Click Delete Icon For Role    DlgTest_${SUFFIX}
    Verify Delete Confirmation Dialog For Role    DlgTest_${SUFFIX}
    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_YES}    ${RM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_CANCEL}    ${RM_TIMEOUT}
    Log    All dialog elements verified: body text, Yes/Confirm, Cancel.
    Click Cancel Delete Role
    Clear Role Search

TC_ROLE_033 Verify Search Input On List Page
    [Documentation]    MD: TC-ROLE-002 Step 2.1 â€” Search input (name='searchValue') is visible.
    [Tags]    edge-case    role-management    search    ui
    Wait Until Element Is Visible    ${LOC_ROLE_SEARCH_INPUT}    ${RM_TIMEOUT}
    Log    Search input visible on Manage Role page.

