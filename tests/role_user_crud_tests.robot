*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/role_management_keywords.resource
Resource    ../resources/keywords/user_management_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/role_management_locators.resource
Resource    ../resources/locators/user_management_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/role_management_variables.py
Variables   ../variables/user_management_variables.py

Suite Setup       CRUD Suite Setup
Suite Teardown    Close All Browsers
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Variables ***
${CRUD_ROLE_NAME}     ${EMPTY}
${CRUD_USERNAME}      ${EMPTY}
${CRUD_USER_EMAIL}    ${EMPTY}

*** Keywords ***
CRUD Suite Setup
    [Documentation]    Login once, generate unique test data, navigate to Manage Role page.
    Load Environment Config From Json    ${ENV}
    ${suffix}=          Generate Random String    6    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    Set Suite Variable  ${CRUD_ROLE_NAME}    CRUDRole_${suffix}
    Set Suite Variable  ${CRUD_USERNAME}     cruduser${suffix}
    Set Suite Variable  ${CRUD_USER_EMAIL}   cruduser${suffix}@mailinator.com
    Login And Navigate To Manage Role
    Log    CRUD Suite ready — Role: ${CRUD_ROLE_NAME} | User: ${CRUD_USERNAME}    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  ROLE — CREATE & DELETE (Positive E2E)
# ═══════════════════════════════════════════════════════════════════════

*** Test Cases ***
TC_CRUD_001 Create Role
    [Documentation]    Create a new role with account, name, description and permissions.
    ...                Verify success toast and role visible in the grid.
    [Tags]    positive    crud    role-management    create    smoke
    [Setup]    Navigate To Manage Role Page
    Open Create Role Form
    Fill Role Creation Form With Permissions    role_name=${CRUD_ROLE_NAME}
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    Verify Role In Grid    ${CRUD_ROLE_NAME}
    Capture Page Screenshot    crud_role_created_verified.png
    Log    TC_CRUD_001 PASS: Role '${CRUD_ROLE_NAME}' created and verified in grid.    console=yes

TC_CRUD_002 Delete Created Role
    [Documentation]    Search for the role created in TC_CRUD_001, delete it and verify removal.
    ...                Verify success toast and role no longer in grid.
    [Tags]    positive    crud    role-management    delete    smoke
    [Setup]    Navigate To Manage Role Page
    Delete Role End To End    ${CRUD_ROLE_NAME}
    Log    TC_CRUD_002 PASS: Role '${CRUD_ROLE_NAME}' deleted and confirmed removed.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  USER — CREATE & DELETE (Positive E2E)
# ═══════════════════════════════════════════════════════════════════════

TC_CRUD_003 Create User
    [Documentation]    Create a new user with all required fields (account, username, name,
    ...                phone, email, role, country, timezone, OTP SMS).
    ...                Verify success toast and user visible in grid.
    [Tags]    positive    crud    user-management    create    smoke
    [Setup]    Navigate To Manage User Page
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form
    ...    username=${CRUD_USERNAME}
    ...    email=${CRUD_USER_EMAIL}
    Click Submit Button
    Verify Success Toast Displayed
    Navigate Back To Manage User Page
    Verify User In Grid    ${CRUD_USERNAME}
    Capture Page Screenshot    crud_user_created_verified.png
    Log    TC_CRUD_003 PASS: User '${CRUD_USERNAME}' created and verified in grid.    console=yes

TC_CRUD_004 Delete Created User
    [Documentation]    Search for the user created in TC_CRUD_003, delete it and verify removal.
    ...                Verify delete success toast and user no longer in grid.
    [Tags]    positive    crud    user-management    delete    smoke
    [Setup]    Navigate To Manage User Page
    Delete User End To End    ${CRUD_USERNAME}
    Log    TC_CRUD_004 PASS: User '${CRUD_USERNAME}' deleted and confirmed removed.    console=yes
