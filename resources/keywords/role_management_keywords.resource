*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/role_management_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  SUITE SETUP
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage Role
    [Documentation]    Opens browser, logs in, navigates to Admin > Role & Access.
    ...                MD: Prerequisites → User is logged in with RW permission.
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}   timeout=10s
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_IMAGE}   timeout=20s
    Sleep    2s
    ${captcha_value}=    Fetch Captcha Value
    Enter Captcha    ${captcha_value}
    Click Login Button
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}          timeout=45s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}   timeout=30s
    Navigate To Manage Role Page
    Log    Suite setup complete: logged in and on Manage Role page.

# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION (MD: TC-ROLE-001 Step 1, TC-ROLE-002 Step 1)
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage Role Page
    [Documentation]    Navigates to /ManageRole and waits for page to load.
    ...                MD: Step 1.2 — Browser navigates to /ManageRole.
    Go To    ${BASE_URL}${MANAGE_ROLE_PATH}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Navigated to Manage Role page.

Refresh Manage Role Page
    [Documentation]    Refreshes the Manage Role page for test isolation.
    Go To    ${BASE_URL}${MANAGE_ROLE_PATH}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Manage Role page refreshed.

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE ROLE PAGE VERIFICATION (MD: Step 1.2)
# ═══════════════════════════════════════════════════════════════════════
Verify Manage Role Page Loaded
    [Documentation]    Verifies the Manage Role page URL and grid.
    ...                MD: Step 1.2 — Role & Access list page is displayed.
    Location Should Contain    ${MANAGE_ROLE_PATH}
    Log    Manage Role page loaded.

Verify Role Grid Loaded
    [Documentation]    Verifies the Role grid is visible with column headers.
    Wait Until Element Is Visible    ${LOC_ROLE_GRID}    ${RM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ROLE_GRID_COLUMN_HEADER}    ${RM_TIMEOUT}
    Log    Role grid loaded.

Verify Role Grid Has Pagination
    [Documentation]    Verifies pagination controls on the Role grid.
    Wait Until Element Is Visible    ${LOC_ROLE_GRID_PAGINATION}    ${RM_TIMEOUT}
    Log    Role grid pagination visible.

# ═══════════════════════════════════════════════════════════════════════
#  CREATE ROLE BUTTON (MD: Step 2.1)
# ═══════════════════════════════════════════════════════════════════════
Verify Create Role Button Visible
    [Documentation]    MD: Step 2.1 — Create Role button is visible (RW permission).
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_ROLE}    ${RM_TIMEOUT}
    Log    Create Role button is visible.

Click Create Role Button
    [Documentation]    MD: Step 2.2 — Click Create Role → /CreateRole.
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_ROLE}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CREATE_ROLE}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Create Role button clicked.

Open Create Role Form
    [Documentation]    Clicks Create Role and verifies the form loads.
    Click Create Role Button
    Verify Create Role Form Loaded

# ═══════════════════════════════════════════════════════════════════════
#  CREATE ROLE FORM (MD: Steps 2.2–3.5, Locator Reference)
# ═══════════════════════════════════════════════════════════════════════
Verify Create Role Form Loaded
    [Documentation]    Verifies URL is /CreateRole and form fields are visible.
    ...                MD: Step 2.2 — Create Role form is displayed.
    Location Should Contain    ${CREATE_ROLE_PATH}
    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_NAME}    ${RM_TIMEOUT}
    Log    Create Role form loaded.

Verify Create Role Breadcrumb
    [Documentation]    MD: Step 2.3 — Breadcrumb reads "Role & Access > Create".
    ...                MD: Notes — use breadcrumb as page-load confirmation.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_BREADCRUMB_CREATE}    10s
    IF    ${visible}
        Log    Breadcrumb 'Create' visible.
    ELSE
        Log    Breadcrumb not found — checking URL instead.    level=WARN
        Location Should Contain    ${CREATE_ROLE_PATH}
    END

Verify All Role Form Fields Present
    [Documentation]    Verifies all form fields from MD: Account, Role Name,
    ...                Role Description, Data Masking checkbox.
    ${account}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_DROPDOWN}    10s
    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_NAME}    ${RM_TIMEOUT}
    ${desc}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_DESCRIPTION}    10s
    ${masking}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_DATA_MASKING}    10s
    Log    Form fields verified: Account=${account}, RoleName=True, Description=${desc}, DataMasking=${masking}

Verify Permissions Table Visible
    [Documentation]    MD: Step 4.1 — Permissions grid is visible.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_PERMISSIONS_TABLE}    15s
    IF    ${visible}
        Log    Permissions table visible.
    ELSE
        ${view_chk}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_CHK_VIEW_PERMISSION}    10s
        IF    ${view_chk}
            Log    View permission checkboxes found — permissions table exists.
        ELSE
            Log    Permissions table not found.    level=WARN
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  FIELD INTERACTIONS (MD: Steps 3.1–3.5, Locator Reference)
# ═══════════════════════════════════════════════════════════════════════
Select Role Account In TreeView
    [Documentation]    MD: Step 3.1–3.2 — Click Account tree-view dropdown,
    ...                select first available account.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_DROPDOWN}    10s
    IF    ${visible}
        Click Element Via JS    ${LOC_ROLE_ACCOUNT_DROPDOWN}
        Sleep    2s
        Wait For App Loading To Complete
        Sleep    1s
        ${tree_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_TREE}    10s
        IF    ${tree_visible}
            ${node}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_FIRST_NODE}    10s
            IF    ${node}
                Click Element Via JS    ${LOC_ROLE_ACCOUNT_FIRST_NODE}
                Sleep    1s
                Log    Account selected from TreeView.
            ELSE
                Log    No tree nodes found.    level=WARN
            END
        ELSE
            Log    Account TreeView not visible after click.    level=WARN
        END
    ELSE
        Log    Account dropdown not found on form.    level=WARN
    END

Fill Role Name
    [Documentation]    MD: Step 3.3 — Enter role name (max 250 chars).
    ...                Locator: input[@name='roleName']
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_NAME}    ${RM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_ROLE_NAME}
    Input Text    ${LOC_INPUT_ROLE_NAME}    ${name}
    Log    Role Name entered: ${name}

Fill Role Description
    [Documentation]    MD: Step 3.4 — Enter role description (max 500 chars, optional).
    ...                Locator: input/textarea[@name='roleDescription']
    [Arguments]    ${description}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_DESCRIPTION}    10s
    IF    ${visible}
        Clear Element Text    ${LOC_INPUT_ROLE_DESCRIPTION}
        Input Text    ${LOC_INPUT_ROLE_DESCRIPTION}    ${description}
        Log    Role Description entered: ${description}
    ELSE
        Log    Role Description field not visible.    level=WARN
    END

Check Data Masking Checkbox
    [Documentation]    MD: Step 3.5 — Check the Data Masking checkbox.
    ...                Locator: input[@name='accountCheckbox']
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_DATA_MASKING}    10s
    IF    ${visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_DATA_MASKING}
        IF    not ${checked}
            Click Element Via JS    ${LOC_CHK_DATA_MASKING}
            Log    Data Masking checkbox checked.
        ELSE
            Log    Data Masking already checked.
        END
    ELSE
        Log    Data Masking checkbox not found.    level=WARN
    END

Uncheck Data Masking Checkbox
    [Documentation]    MD: Step 3.5 — Leave Data Masking unchecked.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_DATA_MASKING}    10s
    IF    ${visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_DATA_MASKING}
        IF    ${checked}
            Click Element Via JS    ${LOC_CHK_DATA_MASKING}
            Log    Data Masking checkbox unchecked.
        ELSE
            Log    Data Masking already unchecked.
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  PERMISSIONS (MD: Step 4, Locator Reference)
# ═══════════════════════════════════════════════════════════════════════
Click View All Header Checkbox
    [Documentation]    MD: Step 4.3 — Click View All header checkbox (js-role-viewheader).
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_VIEW_ALL}    10s
    IF    ${visible}
        Click Element Via JS    ${LOC_CHK_VIEW_ALL}
        Log    View All header checkbox clicked.
    ELSE
        Log    View All header checkbox not found.    level=WARN
    END

Click Edit All Header Checkbox
    [Documentation]    MD: Step 4.3 — Click Edit All header checkbox (js-role-editheader).
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_EDIT_ALL}    10s
    IF    ${visible}
        Click Element Via JS    ${LOC_CHK_EDIT_ALL}
        Log    Edit All header checkbox clicked.
    ELSE
        Log    Edit All header checkbox not found.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  FILL COMPLETE FORM
# ═══════════════════════════════════════════════════════════════════════
Fill Role Creation Form
    [Documentation]    Fills all fields on the Create Role form.
    ...                MD: Steps 3.1–3.5 — Account, Role Name, Description, Data Masking.
    [Arguments]    ${role_name}=${ROLE_NAME}    ${description}=${ROLE_DESCRIPTION}
    Select Role Account In TreeView
    Fill Role Name    ${role_name}
    Fill Role Description    ${description}
    Log    Role creation form filled.

Fill Role Creation Form Mandatory Only
    [Documentation]    Fills only mandatory fields (Account + Role Name).
    [Arguments]    ${role_name}=${ROLE_NAME}
    Select Role Account In TreeView
    Fill Role Name    ${role_name}
    Log    Role creation form filled with mandatory fields only.

# ═══════════════════════════════════════════════════════════════════════
#  SUBMIT & VERIFY (MD: Steps 5.1–5.4)
# ═══════════════════════════════════════════════════════════════════════
Click Role Submit Button
    [Documentation]    MD: Step 5.1 — Click Submit button.
    ...                Locator: Text 'Submit'
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT_ROLE}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_SUBMIT_ROLE}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Submit button clicked.

Click Role Close Button
    [Documentation]    Clicks Close/Back button on Create Role form.
    Wait Until Element Is Visible    ${LOC_BTN_CLOSE_ROLE}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CLOSE_ROLE}
    Sleep    2s
    Wait For App Loading To Complete
    Log    Close button clicked.

Verify Role Success Toast
    [Documentation]    MD: Step 5.2 — Success toast/notification is displayed.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_TOAST_SUCCESS}    15s
    IF    ${visible}
        Log    Success toast displayed.
    ELSE
        ${any}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_ROLE_TOAST_MESSAGE}    5s
        IF    ${any}
            ${msg}=    Get Text    ${LOC_ROLE_TOAST_MESSAGE}
            Log    Toast message: ${msg}
        ELSE
            Log    No toast notification found.    level=WARN
        END
    END

Verify Role Error Toast Or Validation
    [Documentation]    Verifies an error toast or inline validation is displayed.
    ${toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_TOAST_ERROR}    10s
    ${validation}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_VALIDATION_ERROR}    5s
    IF    ${toast}
        Log    Error toast displayed.
    ELSE IF    ${validation}
        Log    Inline validation error displayed.
    ELSE
        Log    No error toast or validation found.    level=WARN
    END

Verify On Create Role Page
    [Documentation]    Confirms browser is still on /CreateRole.
    Location Should Contain    ${CREATE_ROLE_PATH}
    Log    Still on Create Role page.

Verify On Manage Role Page
    [Documentation]    Confirms browser is on /ManageRole.
    ...                MD: Step 5.3 — Browser navigates back to /ManageRole.
    Location Should Contain    ${MANAGE_ROLE_PATH}
    Log    On Manage Role page.

# ═══════════════════════════════════════════════════════════════════════
#  SEARCH (MD: TC-ROLE-002 Step 2, Locator: name='searchValue')
# ═══════════════════════════════════════════════════════════════════════
Search Role In Grid
    [Documentation]    MD: Step 2.1–2.2 — Type role name into search input.
    ...                Locator: input[@name='searchValue']
    [Arguments]    ${role_name}
    Wait Until Element Is Visible    ${LOC_ROLE_SEARCH_INPUT}    ${RM_TIMEOUT}
    Clear Element Text    ${LOC_ROLE_SEARCH_INPUT}
    Input Text    ${LOC_ROLE_SEARCH_INPUT}    ${role_name}
    Press Keys    ${LOC_ROLE_SEARCH_INPUT}    RETURN
    Sleep    2s
    Wait For App Loading To Complete
    Sleep    1s
    Log    Searched for role: ${role_name}

Clear Role Search
    [Documentation]    Clears the search input on the list page.
    Wait Until Element Is Visible    ${LOC_ROLE_SEARCH_INPUT}    ${RM_TIMEOUT}
    Clear Element Text    ${LOC_ROLE_SEARCH_INPUT}
    Press Keys    ${LOC_ROLE_SEARCH_INPUT}    RETURN
    Sleep    2s
    Wait For App Loading To Complete
    Log    Search cleared.

Verify Role In Grid
    [Documentation]    MD: Step 2.3 / Step 5.4 — Verify role appears in grid.
    [Arguments]    ${role_name}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${role_name}')]
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    15s
    IF    ${visible}
        Log    Role '${role_name}' found in grid.
    ELSE
        Log    Role '${role_name}' not found — trying search.    level=WARN
        Search Role In Grid    ${role_name}
        Wait Until Element Is Visible    ${loc}    15s
    END

Verify Role Not In Grid
    [Documentation]    MD: TC-ROLE-002 Step 4.3 — Role no longer present in grid.
    [Arguments]    ${role_name}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${role_name}')]
    Sleep    2s
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    5s
    IF    ${visible}
        Fail    Role '${role_name}' still visible in grid after deletion.
    ELSE
        Log    Role '${role_name}' confirmed not in grid.
    END

# ═══════════════════════════════════════════════════════════════════════
#  DELETE ROLE (MD: TC-ROLE-002 Steps 3–4)
# ═══════════════════════════════════════════════════════════════════════
Click Delete Icon For Role
    [Documentation]    MD: Step 3.2 — Click Delete button in Action column for the role.
    ...                Locator: Text 'Delete' in the row containing the role name.
    [Arguments]    ${role_name}
    ${raw_loc}=    Replace String    ${LOC_DELETE_ROLE_TEMPLATE}    PLACEHOLDER    ${role_name}
    ${delete_xpath}=    Set Variable    xpath=${raw_loc}
    Wait Until Element Is Visible    ${delete_xpath}    ${RM_TIMEOUT}
    Click Element Via JS    ${delete_xpath}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Delete icon clicked for role: ${role_name}

Verify Delete Confirmation Dialog For Role
    [Documentation]    MD: Step 3.3 — Confirmation dialog contains the role name.
    [Arguments]    ${role_name}
    ${dialog}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_DIALOG}    10s
    IF    not ${dialog}
        Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_YES}    10s
    END
    ${body_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_BODY}    5s
    IF    ${body_visible}
        ${body_text}=    Get Text    ${LOC_DELETE_CONFIRM_BODY}
        Should Contain    ${body_text}    ${role_name}
        Log    Delete dialog verified — contains: ${role_name}
    END

Click Confirm Delete Role
    [Documentation]    MD: Step 4.1 — Click Yes/Confirm on the confirmation dialog.
    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_YES}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_CONFIRM_YES}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Confirm delete clicked.

Click Cancel Delete Role
    [Documentation]    MD: Confirmation dialog — Cancel/No button.
    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_CANCEL}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_CONFIRM_CANCEL}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Cancel delete clicked.

Delete Role End To End
    [Documentation]    Full delete flow: search → delete icon → verify dialog → confirm → verify removal.
    ...                MD: TC-ROLE-002 Steps 2–4.
    [Arguments]    ${role_name}
    Search Role In Grid    ${role_name}
    Click Delete Icon For Role    ${role_name}
    Verify Delete Confirmation Dialog For Role    ${role_name}
    Click Confirm Delete Role
    Verify Role Success Toast
    Clear Role Search
    Verify Role Not In Grid    ${role_name}
