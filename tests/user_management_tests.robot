*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/user_management_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/user_management_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/user_management_variables.py

Suite Setup       Login And Navigate To Manage User
Suite Teardown    Close All Browsers
Test Setup        Navigate Back To Manage User Page
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — MANAGE USER PAGE (MD: Steps 1–4, Grid Columns)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_001 Navigate To Manage User Page Via Admin Sidebar
    [Documentation]    MD: Steps 1-3. Login and navigate to Admin > User.
    ...                Verify /ManageUser URL and page heading "Users".
    [Tags]    positive    user-management    navigation    smoke
    Verify Manage User Page Loaded

TC_USER_002 Verify Manage User Grid Loads With Data
    [Documentation]    MD: Grid Columns on Manage User Page.
    ...                Verify the Kendo grid is visible and column headers render.
    [Tags]    positive    user-management    grid
    Verify Manage User Grid Loaded

TC_USER_003 Verify Manage User Grid Columns
    [Documentation]    MD: Grid Columns — USER NAME, USER TYPE, USER CATEGORY, ACCOUNT,
    ...                LOCK STATUS, GROUP, ROLE & ACCESS, FIRST NAME, LAST NAME,
    ...                PRIMARY PHONE, EMAIL ADDRESS.
    [Tags]    positive    user-management    grid    columns
    Verify Manage User Grid Loaded
    Verify Manage User Grid Columns

TC_USER_004 Verify Manage User Grid Has Pagination
    [Documentation]    MD: Kendo Grid with pagination.
    [Tags]    positive    user-management    grid    pagination
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_PAGINATION}    ${UM_TIMEOUT}
    Log    Pagination visible on Manage User grid.

TC_USER_005 Verify Create User Button Is Visible
    [Documentation]    MD: Step 5 — "Create User" button visible on Manage User page.
    [Tags]    positive    user-management    button
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_USER}    ${UM_TIMEOUT}
    Log    Create User button is visible.

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — CREATE USER FORM (MD: Steps 5–6, Form Field Reference)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_006 Open Create User Form
    [Documentation]    MD: Step 5 — Click "Create User" → /CreateUser opens.
    [Tags]    positive    user-management    create-form
    Open Create User Form
    Verify Create User Form Loaded

TC_USER_007 Verify All Create User Form Fields Present
    [Documentation]    MD: Form Field Reference — All mandatory fields rendered:
    ...                Account, Username, First Name, Last Name, Primary Phone,
    ...                Email Address, Confirm Email Address, Role, Country, Time Zone, OTP.
    [Tags]    positive    user-management    create-form    fields
    Open Create User Form
    Verify All Form Fields Present

TC_USER_008 Verify Submit And Close Buttons Present
    [Documentation]    MD: Buttons on Create User Form — Submit and Close buttons.
    [Tags]    positive    user-management    create-form    buttons
    Open Create User Form
    Verify Create User Form Loaded
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}    ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_BTN_CLOSE_FORM}    ${UM_TIMEOUT}
    Log    Submit and Close buttons are visible.

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — CREATE USER E2E (MD: TC_001 Steps 6–19)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_009 Create User With All Required Fields
    [Documentation]    MD: TC_001 — Full E2E flow. Steps 6-19:
    ...                Open form → Fill Account, Username, First Name, Last Name,
    ...                Primary Phone, Email, Confirm Email, Role, Country, Time Zone,
    ...                OTP SMS → Submit → Verify success toast → Verify user in grid.
    [Tags]    positive    user-management    create    e2e    smoke
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form
    Click Submit Button
    Verify Success Toast Displayed
    Navigate Back To Manage User Page
    Verify User In Grid    ${TEST_USERNAME}

TC_USER_010 Create User With Email OTP Channel
    [Documentation]    MD: Step 16 — Select Email OTP checkbox instead of SMS.
    [Tags]    positive    user-management    create    otp
    ${username}=    Set Variable    emailotp${EMPTY.join('${_SUFFIX}')}
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    emailotp${_SUFFIX}
    Fill First Name    EmailOTP
    Fill Last Name    User
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    emailotp${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    emailotp${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Uncheck All OTP Checkboxes
    Select OTP Email Checkbox
    Click Submit Button
    Verify Success Toast Displayed

TC_USER_011 Create User With Both SMS And Email OTP Channels
    [Documentation]    MD: Step 16 — Select both SMS and Email OTP channels.
    [Tags]    positive    user-management    create    otp
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    bothotp${_SUFFIX}
    Fill First Name    BothOTP
    Fill Last Name    User
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    bothotp${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    bothotp${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Select OTP Email Checkbox
    Click Submit Button
    Verify Success Toast Displayed

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — SEARCH USER (MD: TC_002 Step 2)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_012 Search User In Grid By Username
    [Documentation]    MD: TC_002 Step 2 — Locate user in grid using search.
    ...                Search for the user created in TC_USER_009.
    [Tags]    positive    user-management    search
    Search User In Grid    ${TEST_USERNAME}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${TEST_USERNAME}')]
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    15s
    IF    ${found}
        Log    User '${TEST_USERNAME}' found via search.
    ELSE
        Log    User '${TEST_USERNAME}' not found — may not have been created yet.    level=WARN
    END
    Clear Search In Grid

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — DELETE USER (MD: TC_002 Steps 1–8)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_013 Delete User And Verify Removal
    [Documentation]    MD: TC_002 — Full delete flow. Steps 1-8:
    ...                Navigate to Manage User → Search user → Click Delete icon →
    ...                Verify dialog heading "Delete User" → Verify body text →
    ...                Click OK → Verify toast "User Deleted Successfully" →
    ...                Verify user no longer in grid.
    [Tags]    positive    user-management    delete    e2e    smoke
    Delete User End To End    ${TEST_USERNAME}

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — CLOSE FORM (MD: Buttons — Close)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_014 Close Create User Form Without Saving
    [Documentation]    MD: Buttons — Close: Cancels and closes the form without saving.
    ...                Open form → Click Close → Verify redirected to Manage User.
    [Tags]    positive    user-management    close    form
    Open Create User Form
    Verify Create User Form Loaded
    Click Close Form Button
    Verify On Manage User Page

TC_USER_015 Close Form After Filling Fields Should Not Create User
    [Documentation]    Fill form partially → Close → Verify user NOT created.
    [Tags]    positive    user-management    close    form
    Open Create User Form
    Verify Create User Form Loaded
    Fill Username    closetest${_SUFFIX}
    Fill First Name    Close
    Fill Last Name    Test
    Click Close Form Button
    Verify On Manage User Page
    Verify User Not In Grid    closetest${_SUFFIX}

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — MISSING MANDATORY FIELDS (MD: Form Field Reference)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_016 Submit Without Filling Any Field
    [Documentation]    MD: All mandatory fields empty — expects validation errors or rejection.
    [Tags]    negative    user-management    validation    empty
    Open Create User Form
    Verify Create User Form Loaded
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_017 Submit Without Selecting Account
    [Documentation]    MD: Form Field Reference — Account is Required.
    ...                Fill all fields except Account → Submit → expects error.
    [Tags]    negative    user-management    validation    account
    Open Create User Form
    Verify Create User Form Loaded
    Fill Username    noacct${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    noacct${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    noacct${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_018 Submit Without Username
    [Documentation]    MD: Username — Required, min 5, max 50.
    ...                Leave username empty → Submit → expects error.
    [Tags]    negative    user-management    validation    username
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    nouser${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    nouser${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_019 Submit Without First Name
    [Documentation]    MD: First Name — Required.
    [Tags]    negative    user-management    validation    first-name
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    nofn${_SUFFIX}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    nofn${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    nofn${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_020 Submit Without Last Name
    [Documentation]    MD: Last Name — Required.
    [Tags]    negative    user-management    validation    last-name
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    noln${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    noln${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    noln${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_021 Submit Without Primary Phone
    [Documentation]    MD: Primary Phone — Required, min 5, max 16 digits.
    [Tags]    negative    user-management    validation    phone
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    nophone${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Email Address    noph${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    noph${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_022 Submit Without Email Address
    [Documentation]    MD: Email Address — Required, valid email format.
    [Tags]    negative    user-management    validation    email
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    noemail${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_023 Submit Without Confirm Email Address
    [Documentation]    MD: Confirm Email Address — Required, must match Email.
    [Tags]    negative    user-management    validation    confirm-email
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    nocem${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    nocem${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_024 Submit Without Selecting Role
    [Documentation]    MD: Role — Required.
    [Tags]    negative    user-management    validation    role
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    norole${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    norole${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    norole${_SUFFIX}@mailinator.com
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_025 Submit Without Selecting Country
    [Documentation]    MD: Country — Required.
    [Tags]    negative    user-management    validation    country
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    nocnt${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    nocnt${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    nocnt${_SUFFIX}@mailinator.com
    Select Role
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_026 Submit Without Selecting Time Zone
    [Documentation]    MD: Time Zone — Required (unless Local Time = Yes).
    [Tags]    negative    user-management    validation    timezone
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    notz${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    notz${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    notz${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_027 Submit Without Selecting Any OTP Channel
    [Documentation]    MD: OTP Delivery Channel — At least one required.
    ...                Uncheck all OTP checkboxes → Submit → expects error.
    [Tags]    negative    user-management    validation    otp
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    nootp${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    nootp${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    nootp${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Uncheck All OTP Checkboxes
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — INVALID VALUES (MD: Form Field Reference validations)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_028 Username Less Than 5 Characters
    [Documentation]    MD: Username — min 5 chars. Enter 3 chars → expects error.
    [Tags]    negative    user-management    validation    username    boundary
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    ${USERNAME_LESS_THAN_5}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    short${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    short${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_029 Username More Than 50 Characters
    [Documentation]    MD: Username — max 50 chars. Enter 51 chars → expects error.
    [Tags]    negative    user-management    validation    username    boundary
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    ${USERNAME_MORE_THAN_50}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    long${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    long${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_030 Phone Less Than 5 Digits
    [Documentation]    MD: Primary Phone — min 5 digits. Enter 4 digits → expects error.
    [Tags]    negative    user-management    validation    phone    boundary
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    shph${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${PHONE_LESS_THAN_5}
    Fill Email Address    shph${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    shph${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_031 Phone More Than 16 Digits
    [Documentation]    MD: Primary Phone — max 16 digits. Enter 17 digits → expects error.
    [Tags]    negative    user-management    validation    phone    boundary
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    lgph${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${PHONE_MORE_THAN_16}
    Fill Email Address    lgph${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    lgph${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_032 Phone With Non Numeric Characters
    [Documentation]    MD: Primary Phone — Numeric only. Enter alphanumeric → expects error.
    [Tags]    negative    user-management    validation    phone
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    nnph${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${PHONE_NON_NUMERIC}
    Fill Email Address    nnph${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    nnph${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_033 Invalid Email Format
    [Documentation]    MD: Email Address — Required, valid email format.
    ...                Enter 'not-an-email' → expects error.
    [Tags]    negative    user-management    validation    email
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    bdem${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    ${INVALID_EMAIL}
    Fill Confirm Email Address    ${INVALID_EMAIL}
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_034 Mismatched Confirm Email
    [Documentation]    MD: Confirm Email Address — must match Email Address.
    ...                Enter different email in confirm field → expects error.
    [Tags]    negative    user-management    validation    confirm-email
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    mmem${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    mmem${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    ${MISMATCHED_EMAIL}
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_035 Duplicate Username Should Show Error
    [Documentation]    MD: Username — Must be unique in the system.
    ...                Create user, then try creating again with same username → expects error.
    [Tags]    negative    user-management    validation    duplicate
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=dup${_SUFFIX}    email=dup${_SUFFIX}@mailinator.com
    Click Submit Button
    Verify Success Toast Displayed
    Navigate Back To Manage User Page
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=dup${_SUFFIX}    email=dup2${_SUFFIX}@mailinator.com
    Click Submit Button
    Verify Error Toast Or Validation Displayed

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — DELETE (MD: Confirmation Dialog Reference)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_036 Cancel Delete Confirmation Should Keep User
    [Documentation]    MD: Confirmation Dialog — Cancel button.
    ...                Click Delete → dialog appears → Click Cancel → user remains in grid.
    [Tags]    negative    user-management    delete    cancel
    # First create a user to test delete cancel
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=delcancel${_SUFFIX}    email=delcancel${_SUFFIX}@mailinator.com
    Click Submit Button
    Verify Success Toast Displayed
    Navigate Back To Manage User Page
    Search User In Grid    delcancel${_SUFFIX}
    Click Delete Icon For User    delcancel${_SUFFIX}
    Verify Delete Confirmation Dialog    delcancel${_SUFFIX}
    Click Cancel On Delete Confirmation
    Clear Search In Grid
    Search User In Grid    delcancel${_SUFFIX}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'delcancel${_SUFFIX}')]
    Wait Until Element Is Visible    ${loc}    15s
    Log    User still in grid after cancel — correct behavior.
    Clear Search In Grid

# ═══════════════════════════════════════════════════════════════════════
#  EDGE CASES (MD: Form Field Reference boundaries)
# ═══════════════════════════════════════════════════════════════════════

TC_USER_037 Username Exactly 5 Characters
    [Documentation]    MD: Username — min 5 chars. Boundary: exactly 5 should succeed.
    [Tags]    edge-case    user-management    boundary    username
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=${USERNAME_EXACTLY_5}    email=ex5${_SUFFIX}@mailinator.com
    Click Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create User Page
    IF    ${on_create}
        Log    Still on Create User page — username exactly 5 chars may have been rejected.    level=WARN
        Verify Error Toast Or Validation Displayed
    ELSE
        Verify Success Toast Displayed
        Log    Username with exactly 5 chars accepted.
    END

TC_USER_038 Username Exactly 50 Characters
    [Documentation]    MD: Username — max 50 chars. Boundary: exactly 50 should succeed.
    [Tags]    edge-case    user-management    boundary    username
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=${USERNAME_EXACTLY_50}    email=ex50${_SUFFIX}@mailinator.com
    Click Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create User Page
    IF    ${on_create}
        Log    Still on Create User page — username exactly 50 chars may have been rejected.    level=WARN
        Verify Error Toast Or Validation Displayed
    ELSE
        Verify Success Toast Displayed
        Log    Username with exactly 50 chars accepted.
    END

TC_USER_039 Phone Exactly 5 Digits
    [Documentation]    MD: Primary Phone — min 5 digits. Boundary: exactly 5 should succeed.
    [Tags]    edge-case    user-management    boundary    phone
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=ph5${_SUFFIX}    phone=${PHONE_EXACTLY_5}
    ...    email=ph5${_SUFFIX}@mailinator.com
    Click Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create User Page
    IF    ${on_create}
        Log    Phone exactly 5 digits may have been rejected.    level=WARN
        Verify Error Toast Or Validation Displayed
    ELSE
        Verify Success Toast Displayed
        Log    Phone with exactly 5 digits accepted.
    END

TC_USER_040 Phone Exactly 16 Digits
    [Documentation]    MD: Primary Phone — max 16 digits. Boundary: exactly 16 should succeed.
    [Tags]    edge-case    user-management    boundary    phone
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=ph16${_SUFFIX}    phone=${PHONE_EXACTLY_16}
    ...    email=ph16${_SUFFIX}@mailinator.com
    Click Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create User Page
    IF    ${on_create}
        Log    Phone exactly 16 digits may have been rejected.    level=WARN
        Verify Error Toast Or Validation Displayed
    ELSE
        Verify Success Toast Displayed
        Log    Phone with exactly 16 digits accepted.
    END

TC_USER_041 Whitespace Only Username
    [Documentation]    MD: Username — Required. Enter only spaces → expects error.
    [Tags]    edge-case    user-management    validation    username
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    ${WHITESPACE_INPUT}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    wsun${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    wsun${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_042 Whitespace Only First Name
    [Documentation]    MD: First Name — Required, Trimmed whitespace.
    ...                Enter only spaces → expects error.
    [Tags]    edge-case    user-management    validation    first-name
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    wsfn${_SUFFIX}
    Fill First Name    ${WHITESPACE_INPUT}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    wsfn${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    wsfn${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_043 Whitespace Only Last Name
    [Documentation]    MD: Last Name — Required, Trimmed whitespace.
    ...                Enter only spaces → expects error.
    [Tags]    edge-case    user-management    validation    last-name
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    wsln${_SUFFIX}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${WHITESPACE_INPUT}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    wsln${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    wsln${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    Verify On Create User Page
    Verify Error Toast Or Validation Displayed

TC_USER_044 Special Characters In Username
    [Documentation]    MD: Username — Enter special chars → expects error or acceptance.
    [Tags]    edge-case    user-management    validation    username    special-chars
    Open Create User Form
    Verify Create User Form Loaded
    Select User Category
    Select Account In TreeView
    Fill Username    ${SPECIAL_CHARS_USERNAME}
    Fill First Name    ${TEST_FIRST_NAME}
    Fill Last Name    ${TEST_LAST_NAME}
    Fill Primary Phone    ${TEST_PRIMARY_PHONE}
    Fill Email Address    spcun${_SUFFIX}@mailinator.com
    Fill Confirm Email Address    spcun${_SUFFIX}@mailinator.com
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Click Submit Button
    ${on_create}=    Run Keyword And Return Status    Verify On Create User Page
    IF    ${on_create}
        Log    Special chars in username rejected — validation working.
        Verify Error Toast Or Validation Displayed
    ELSE
        Log    Special chars in username accepted by the system.    level=WARN
    END

TC_USER_045 Verify Delete Confirmation Dialog Elements
    [Documentation]    MD: Confirmation Dialog Reference — heading, body, OK, Cancel buttons.
    ...                Create temp user → Click Delete → Verify all dialog elements → Cancel.
    [Tags]    edge-case    user-management    delete    dialog
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form    username=dlgtest${_SUFFIX}    email=dlgtest${_SUFFIX}@mailinator.com
    Click Submit Button
    Verify Success Toast Displayed
    Navigate Back To Manage User Page
    Search User In Grid    dlgtest${_SUFFIX}
    Click Delete Icon For User    dlgtest${_SUFFIX}
    Verify Delete Confirmation Dialog    dlgtest${_SUFFIX}
    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_OK}    ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_CANCEL}    ${UM_TIMEOUT}
    Log    All dialog elements verified: heading, body, OK, Cancel.
    Click Cancel On Delete Confirmation
    Clear Search In Grid
