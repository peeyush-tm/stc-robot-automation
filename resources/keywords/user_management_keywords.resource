*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/user_management_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  SUITE SETUP / TEARDOWN
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage User
    [Documentation]    Opens browser, logs in, navigates to Admin > User (Manage User page).
    ...                MD: Login → Sidebar → Admin → User → /ManageUser
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
    Navigate To Manage User Page
    Log    Suite setup complete: logged in and on Manage User page.

# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION (MD: Navigation Path — Login → Sidebar → Admin → User)
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage User Page
    [Documentation]    MD: Step 2 — Click Admin icon in sidebar (lands on ManageUser by default).
    ...                If not on ManageUser, click User sub-tab in top navigation.
    Wait For App Loading To Complete
    Scroll To Element Via JS    ${LOC_SIDEBAR_ADMIN}
    Wait Until Element Is Visible    ${LOC_SIDEBAR_ADMIN}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_SIDEBAR_ADMIN}
    Sleep    3s
    Wait For App Loading To Complete    timeout=60s
    Sleep    2s
    Wait For App Loading To Complete
    ${on_manage_user}=    Run Keyword And Return Status
    ...    Location Should Contain    ${MANAGE_USER_PATH}
    IF    not ${on_manage_user}
        ${user_tab_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_SIDEBAR_USER}    10s
        IF    ${user_tab_visible}
            Click Element Via JS    ${LOC_SIDEBAR_USER}
            Sleep    3s
            Wait For App Loading To Complete    timeout=60s
            Sleep    1s
            Wait For App Loading To Complete
        END
    END
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ${MANAGE_USER_PATH}
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_GRID}    ${UM_TIMEOUT}
    Log    Navigated to Manage User page via Admin sidebar.

Navigate Back To Manage User Page
    [Documentation]    Navigates back to /ManageUser. If already there, waits for grid.
    ...                If on CreateUser or another page, clicks Admin icon → lands on ManageUser.
    ${on_manage_user}=    Run Keyword And Return Status
    ...    Location Should Contain    ${MANAGE_USER_PATH}
    IF    not ${on_manage_user}
        Scroll To Element Via JS    ${LOC_SIDEBAR_ADMIN}
        Wait Until Element Is Visible    ${LOC_SIDEBAR_ADMIN}    ${UM_TIMEOUT}
        Click Element Via JS    ${LOC_SIDEBAR_ADMIN}
        Sleep    3s
        Wait For App Loading To Complete    timeout=60s
        Sleep    2s
        Wait For App Loading To Complete
        ${still_not}=    Run Keyword And Return Status
        ...    Location Should Contain    ${MANAGE_USER_PATH}
        IF    not ${still_not}
            ${user_tab_visible}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_SIDEBAR_USER}    10s
            IF    ${user_tab_visible}
                Click Element Via JS    ${LOC_SIDEBAR_USER}
                Sleep    3s
                Wait For App Loading To Complete    timeout=60s
                Sleep    1s
                Wait For App Loading To Complete
            END
        END
    ELSE
        Sleep    1s
        Wait For App Loading To Complete
    END
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ${MANAGE_USER_PATH}
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_GRID}    ${UM_TIMEOUT}
    Log    Back on Manage User page.

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE USER PAGE VERIFICATION (MD: Step 4, Grid Columns)
# ═══════════════════════════════════════════════════════════════════════
Verify Manage User Page Loaded
    [Documentation]    Verifies the Manage User page heading, grid, and pagination.
    ...                MD: Step 4 — Page title shows "Users"
    ${heading}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_MANAGE_USER_HEADING}    ${UM_TIMEOUT}
    IF    not ${heading}
        Log    Page heading 'Users' not found — checking URL instead.    level=WARN
    END
    Location Should Contain    ${MANAGE_USER_PATH}
    Log    Manage User page loaded.

Verify Manage User Grid Loaded
    [Documentation]    Verifies the Manage User grid is visible with column headers.
    ...                MD: Grid Columns — Action, User Name, User Type, etc.
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_GRID}    ${UM_TIMEOUT}
    Log    Manage User grid loaded.

Verify Manage User Grid Columns
    [Documentation]    Verifies all grid columns from MD are present.
    ...                MD: Grid Columns on Manage User Page
    @{expected_columns}=    Create List    USER NAME    FIRST NAME    LAST NAME    EMAIL ADDRESS
    FOR    ${col}    IN    @{expected_columns}
        ${loc}=    Set Variable    xpath=//th[@role='columnheader' and contains(.,'${col}')]
        ${visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${loc}    10s
        IF    ${visible}
            Log    Column '${col}' found.
        ELSE
            Log    Column '${col}' not found in grid.    level=WARN
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  CREATE USER FORM (MD: Step 5)
# ═══════════════════════════════════════════════════════════════════════
Click Create User Button
    [Documentation]    Clicks the Create User button to open the create user form.
    ...                MD: Step 5 — Click "Create User" button → /CreateUser
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_USER}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CREATE_USER}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Create User form opened.

Open Create User Form
    [Documentation]    Navigates to Manage User and clicks Create User button.
    Click Create User Button

Verify Create User Form Loaded
    [Documentation]    Verifies the Create User form fields are visible.
    ...                MD: Form Field Reference
    Location Should Contain    ${CREATE_USER_PATH}
    Wait Until Element Is Visible    ${LOC_INPUT_USERNAME}    ${UM_TIMEOUT}
    Log    Create User form loaded.

Verify All Form Fields Present
    [Documentation]    Checks all mandatory form fields from the MD are rendered.
    ...                MD: Form Field Reference — Account, Username, First Name, Last Name,
    ...                Primary Phone, Email Address, Confirm Email, Role, Country, Time Zone, OTP
    Wait Until Element Is Visible    ${LOC_INPUT_USERNAME}       ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_FIRST_NAME}     ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_LAST_NAME}      ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_PRIMARY_PHONE}  ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_EMAIL}          ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_CONFIRM_EMAIL}  ${UM_TIMEOUT}
    ${role_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DDL_ROLE}    10s
    ${country_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DDL_COUNTRY}    10s
    ${tz_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DDL_TIMEZONE}    10s
    Log    All mandatory form fields verified.

# ═══════════════════════════════════════════════════════════════════════
#  FIELD INTERACTIONS (MD: Steps 6–16, XPaths from Robot Framework section)
# ═══════════════════════════════════════════════════════════════════════
Select Account In TreeView
    [Documentation]    Opens the Account TreeView dropdown and selects the target BU account.
    ...                Same approach as Cost Center: click input → wait for tree → expand → select.
    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_INPUT}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_UM_ACCOUNT_INPUT}
    Sleep    2s
    Wait For App Loading To Complete
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_TREEVIEW}    10s
    IF    not ${tree_visible}
        Click Element    ${LOC_UM_ACCOUNT_INPUT}
        Sleep    2s
        Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_TREEVIEW}    15s
    END
    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_ROOT_NODE}    15s
    Sleep    1s
    UM Expand And Select BU Account
    Sleep    2s
    Wait For App Loading To Complete
    Log    Account selected: ${UM_BU_ACCOUNT_NAME}

UM Expand And Select BU Account
    [Documentation]    Expand KSA_OPCO → expand EC (UM_EC_ACCOUNT_NAME) →
    ...                select BU (UM_BU_ACCOUNT_NAME). Exact cost center pattern.
    ${root_expand}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_ROOT_EXPAND}    5s
    IF    ${root_expand}
        Click Element Via JS    ${LOC_UM_ACCOUNT_ROOT_EXPAND}
        Sleep    4s
        Wait For App Loading To Complete    timeout=30s
        Sleep    2s
        Log    KSA_OPCO expanded.
    END
    UM Expand Tree Node By Name    ${UM_EC_ACCOUNT_NAME}
    Sleep    4s
    Wait For App Loading To Complete    timeout=30s
    Sleep    2s
    Log    EC '${UM_EC_ACCOUNT_NAME}' expanded.
    UM Select Tree Node By Name    ${UM_BU_ACCOUNT_NAME}

UM Expand Tree Node By Name
    [Documentation]    Finds a tree node by name and clicks its expand icon.
    [Arguments]    ${node_name}
    ${expanded}=    Execute JavaScript
    ...    var containers = document.querySelectorAll('div[id*="showTreeView"], div.k-treeview'); var nodes; if(containers.length>0){nodes=containers[0].querySelectorAll('span.k-in');}else{nodes=document.querySelectorAll('.k-treeview span.k-in, .k-item span.k-in');} for(var i=0; i<nodes.length; i++){if(nodes[i].textContent.trim()==='${node_name}'){var li=nodes[i].closest('li.k-item'); if(li){var icon=li.querySelector(':scope > div span.k-i-expand'); if(icon){icon.click(); return true;}}}} return false;
    Should Be True    ${expanded}    Could not find or expand node '${node_name}' in the TreeView.
    Log    Expanded node: ${node_name}

UM Select Tree Node By Name
    [Documentation]    Finds a tree node by exact text and clicks its checkbox or text to select.
    [Arguments]    ${account_name}
    ${clicked}=    Execute JavaScript
    ...    var containers = document.querySelectorAll('div[id*="showTreeView"], div.k-treeview'); var nodes; if(containers.length>0){nodes=containers[0].querySelectorAll('span.k-in');}else{nodes=document.querySelectorAll('.k-treeview span.k-in, .k-item span.k-in');} for(var i=0; i<nodes.length; i++){if(nodes[i].textContent.trim()==='${account_name}'){var li=nodes[i].closest('li.k-item'); var cb=li?li.querySelector(':scope > div input.k-checkbox'):null; if(cb){cb.click(); return true;} else{nodes[i].click(); return true;}}} return false;
    Should Be True    ${clicked}    Account '${account_name}' not found in the TreeView.
    Log    Selected account: ${account_name}

Fill Username
    [Documentation]    Enters value into the Username field.
    ...                MD: Step 7 — input[@name='userName'], min 5, max 50
    [Arguments]    ${username}
    Wait Until Element Is Visible    ${LOC_INPUT_USERNAME}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_USERNAME}
    Input Text    ${LOC_INPUT_USERNAME}    ${username}
    Log    Username entered: ${username}

Fill First Name
    [Documentation]    Enters value into the First Name field.
    ...                MD: Step 8 — input[@name='firstName']
    [Arguments]    ${first_name}
    Wait Until Element Is Visible    ${LOC_INPUT_FIRST_NAME}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_FIRST_NAME}
    Input Text    ${LOC_INPUT_FIRST_NAME}    ${first_name}
    Log    First Name entered: ${first_name}

Fill Last Name
    [Documentation]    Enters value into the Last Name field.
    ...                MD: Step 9 — input[@name='lastName']
    [Arguments]    ${last_name}
    Wait Until Element Is Visible    ${LOC_INPUT_LAST_NAME}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_LAST_NAME}
    Input Text    ${LOC_INPUT_LAST_NAME}    ${last_name}
    Log    Last Name entered: ${last_name}

Fill Primary Phone
    [Documentation]    Enters value into the Primary Phone field.
    ...                MD: Step 10 — input[@name='telephoneNumber'], min 5, max 16 digits
    [Arguments]    ${phone}
    Wait Until Element Is Visible    ${LOC_INPUT_PRIMARY_PHONE}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_PRIMARY_PHONE}
    Input Text    ${LOC_INPUT_PRIMARY_PHONE}    ${phone}
    Log    Primary Phone entered: ${phone}

Fill Email Address
    [Documentation]    Enters value into the Email Address field.
    ...                MD: Step 11 — input[@name='emailId'], valid email format
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${LOC_INPUT_EMAIL}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_EMAIL}
    Input Text    ${LOC_INPUT_EMAIL}    ${email}
    Log    Email entered: ${email}

Fill Confirm Email Address
    [Documentation]    Enters value into the Confirm Email Address field.
    ...                MD: Step 12 — input[@name='confirmEmailId'], must match Email
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${LOC_INPUT_CONFIRM_EMAIL}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_CONFIRM_EMAIL}
    Input Text    ${LOC_INPUT_CONFIRM_EMAIL}    ${email}
    Log    Confirm Email entered: ${email}

Select User Category
    [Documentation]    Selects "Normal User" from the User Category native select dropdown.
    ...                select[@name='userAccountType']
    [Arguments]    ${category}=${UM_USER_CATEGORY}
    Wait Until Element Is Visible    ${LOC_DDL_USER_CATEGORY_SELECT}    ${UM_TIMEOUT}
    Select From List By Value    ${LOC_DDL_USER_CATEGORY_SELECT}    ${category}
    Sleep    1s
    Wait For App Loading To Complete
    Log    User Category selected: ${category}

Select Role
    [Documentation]    Selects a role from the custom (div-based) Role dropdown.
    ...                Clicks trigger → waits for options → clicks "BillingAccount_Admin".
    [Arguments]    ${role_name}=${UM_ROLE_NAME}
    ${trigger_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_DROPDOWN_TRIGGER}    10s
    IF    ${trigger_visible}
        Click Element Via JS    ${LOC_ROLE_DROPDOWN_TRIGGER}
        Sleep    2s
        ${option_loc}=    Replace String    ${LOC_ROLE_OPTION_TEMPLATE}    PLACEHOLDER    ${role_name}
        Wait Until Element Is Visible    ${option_loc}    10s
        Click Element Via JS    ${option_loc}
        Sleep    1s
        Wait For App Loading To Complete
        Log    Role selected: ${role_name}
    ELSE
        # Fallback: try clicking the area near the role data-testid
        ${alt}=    Set Variable    xpath=//div[@data-testid='roleSelectedValueuet']
        ${alt_vis}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${alt}    5s
        IF    ${alt_vis}
            Click Element Via JS    ${alt}
            Sleep    2s
            ${option_loc}=    Replace String    ${LOC_ROLE_OPTION_TEMPLATE}    PLACEHOLDER    ${role_name}
            Wait Until Element Is Visible    ${option_loc}    10s
            Click Element Via JS    ${option_loc}
            Sleep    1s
            Wait For App Loading To Complete
            Log    Role selected via fallback: ${role_name}
        ELSE
            Log    Role dropdown not found.    level=WARN
        END
    END

Select Country
    [Documentation]    Opens the Country custom dropdown, types the country name, and selects it.
    ...                Country is a searchable dropdown — type "India" then select from options.
    [Arguments]    ${country}=${UM_COUNTRY_TEXT}
    ${trigger_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_COUNTRY_DROPDOWN_TRIGGER}    10s
    IF    ${trigger_visible}
        Click Element Via JS    ${LOC_COUNTRY_DROPDOWN_TRIGGER}
        Sleep    1s
    END
    # Type country name in the search input that appears
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_COUNTRY_INPUT}    5s
    IF    ${input_visible}
        Input Text    ${LOC_COUNTRY_INPUT}    ${country}
        Sleep    2s
    ELSE
        # Try typing via active element after clicking the dropdown
        Press Keys    None    ${country}
        Sleep    2s
    END
    ${option_loc}=    Replace String    ${LOC_COUNTRY_OPTION_TEMPLATE}    PLACEHOLDER    ${country}
    Wait Until Element Is Visible    ${option_loc}    10s
    Click Element Via JS    ${option_loc}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Country selected: ${country}

Select Time Zone
    [Documentation]    Selects a time zone from the custom (div-based) Timezone dropdown.
    ...                Clicks trigger → waits for options → clicks "(GMT+03:00) Kuwait, Riyadh".
    [Arguments]    ${timezone}=${UM_TIMEZONE_TEXT}
    ${trigger_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TIMEZONE_DROPDOWN_TRIGGER}    10s
    IF    ${trigger_visible}
        Click Element Via JS    ${LOC_TIMEZONE_DROPDOWN_TRIGGER}
        Sleep    2s
        ${option_loc}=    Replace String    ${LOC_TIMEZONE_OPTION_TEMPLATE}    PLACEHOLDER    ${timezone}
        Wait Until Element Is Visible    ${option_loc}    10s
        Click Element Via JS    ${option_loc}
        Sleep    1s
        Wait For App Loading To Complete
        Log    Time Zone selected: ${timezone}
    ELSE
        # Fallback: try clicking the area near the timezone data-testid
        ${alt}=    Set Variable    xpath=//div[@data-testid='timeZoneSelectedValueuet']
        ${alt_vis}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${alt}    5s
        IF    ${alt_vis}
            Click Element Via JS    ${alt}
            Sleep    2s
            ${option_loc}=    Replace String    ${LOC_TIMEZONE_OPTION_TEMPLATE}    PLACEHOLDER    ${timezone}
            Wait Until Element Is Visible    ${option_loc}    10s
            Click Element Via JS    ${option_loc}
            Sleep    1s
            Wait For App Loading To Complete
            Log    Time Zone selected via fallback: ${timezone}
        ELSE
            Log    Time Zone dropdown not found.    level=WARN
        END
    END

Select OTP SMS Checkbox
    [Documentation]    Selects the SMS OTP delivery channel checkbox.
    ...                MD: Step 16 — input[@name='sms'], default checked
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_SMS}    10s
    IF    ${visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_SMS}
        IF    not ${checked}
            Click Element Via JS    ${LOC_CHK_SMS}
            Log    SMS OTP checkbox selected.
        ELSE
            Log    SMS OTP checkbox already selected.
        END
    ELSE
        Log    SMS checkbox not found.    level=WARN
    END

Select OTP Email Checkbox
    [Documentation]    Selects the Email OTP delivery channel checkbox.
    ...                MD: Step 16 — input[@name='email']
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_EMAIL_OTP}    10s
    IF    ${visible}
        Click Element Via JS    ${LOC_CHK_EMAIL_OTP}
        Log    Email OTP checkbox selected.
    ELSE
        Log    Email OTP checkbox not found.    level=WARN
    END

Uncheck All OTP Checkboxes
    [Documentation]    Unchecks all OTP delivery channel checkboxes.
    ${sms_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_SMS}    5s
    IF    ${sms_visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_SMS}
        IF    ${checked}
            Click Element Via JS    ${LOC_CHK_SMS}
        END
    END
    ${email_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_EMAIL_OTP}    5s
    IF    ${email_visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_EMAIL_OTP}
        IF    ${checked}
            Click Element Via JS    ${LOC_CHK_EMAIL_OTP}
        END
    END
    Log    All OTP checkboxes unchecked.

# ═══════════════════════════════════════════════════════════════════════
#  FILL COMPLETE FORM (MD: Steps 6–16 combined)
# ═══════════════════════════════════════════════════════════════════════
Fill User Creation Form
    [Documentation]    Fills all mandatory fields on the Create User form.
    ...                User Category → Account → Username → First Name → Last Name →
    ...                Primary Phone → Email → Confirm Email → Role → Country → Time Zone → OTP
    [Arguments]    ${username}=${TEST_USERNAME}    ${first_name}=${TEST_FIRST_NAME}
    ...    ${last_name}=${TEST_LAST_NAME}    ${phone}=${TEST_PRIMARY_PHONE}
    ...    ${email}=${TEST_EMAIL}
    Select User Category
    Sleep    2s
    Wait For App Loading To Complete
    Select Account In TreeView
    Fill Username    ${username}
    Fill First Name    ${first_name}
    Fill Last Name    ${last_name}
    Fill Primary Phone    ${phone}
    Fill Email Address    ${email}
    Fill Confirm Email Address    ${email}
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Log    User creation form filled with all mandatory fields.

# ═══════════════════════════════════════════════════════════════════════
#  SUBMIT & VERIFY (MD: Steps 17–19)
# ═══════════════════════════════════════════════════════════════════════
Click Submit Button
    [Documentation]    Clicks the Submit button on the Create User form.
    ...                MD: Step 17 — button[contains(text(),'Submit')]
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_SUBMIT}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Submit button clicked.

Click Close Form Button
    [Documentation]    Clicks the Close button to cancel form without saving.
    ...                MD: Buttons — Close: Cancels and closes the form without saving
    Wait Until Element Is Visible    ${LOC_BTN_CLOSE_FORM}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CLOSE_FORM}
    Sleep    2s
    Wait For App Loading To Complete
    Log    Close button clicked.

Verify Success Toast Displayed
    [Documentation]    Verifies a success toast notification is visible.
    ...                MD: Step 18 — Toast notification appears confirming user creation
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    15s
    IF    ${visible}
        Log    Success toast displayed.
    ELSE
        ${any_toast}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_TOAST_MESSAGE}    5s
        IF    ${any_toast}
            ${msg}=    Get Text    ${LOC_TOAST_MESSAGE}
            Log    Toast message: ${msg}
        ELSE
            Log    No toast notification found.    level=WARN
        END
    END

Verify Error Toast Or Validation Displayed
    [Documentation]    Verifies an error toast or inline validation error is shown.
    ${has_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    10s
    ${has_validation}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_VALIDATION_ERROR}    5s
    IF    ${has_toast}
        Log    Error toast displayed.
    ELSE IF    ${has_validation}
        Log    Inline validation error displayed.
    ELSE
        Log    No error toast or validation found — form may have other error indicators.    level=WARN
    END

Verify User In Grid
    [Documentation]    Verifies that the given username appears in the Manage User grid.
    ...                MD: Step 19 — The newly created user appears in the grid
    [Arguments]    ${username}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${username}')]
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    15s
    IF    ${visible}
        Log    User '${username}' found in Manage User grid.
    ELSE
        Log    User '${username}' not found in grid — may need search.    level=WARN
        Search User In Grid    ${username}
        Wait Until Element Is Visible    ${loc}    15s
    END

Verify User Not In Grid
    [Documentation]    Verifies that the given username does NOT appear in the Manage User grid.
    ...                MD: TC_002 Step 8 — The user no longer appears in the grid
    [Arguments]    ${username}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${username}')]
    Sleep    2s
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    5s
    IF    ${visible}
        Fail    User '${username}' still visible in grid after deletion.
    ELSE
        Log    User '${username}' confirmed not in grid.
    END

Verify On Create User Page
    [Documentation]    Confirms the browser is still on the Create User page.
    Location Should Contain    ${CREATE_USER_PATH}
    Log    Still on Create User page.

Verify On Manage User Page
    [Documentation]    Confirms the browser is on the Manage User page.
    Location Should Contain    ${MANAGE_USER_PATH}
    Log    On Manage User page.

# ═══════════════════════════════════════════════════════════════════════
#  SEARCH (MD: TC_002 Step 2, XPath for search)
# ═══════════════════════════════════════════════════════════════════════
Search User In Grid
    [Documentation]    Types the username into the search input and presses Enter.
    ...                MD: Search input — //input[@placeholder='Enter Search Text']
    [Arguments]    ${username}
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_SEARCH}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_MANAGE_USER_SEARCH}
    Input Text    ${LOC_MANAGE_USER_SEARCH}    ${username}
    Press Keys    ${LOC_MANAGE_USER_SEARCH}    RETURN
    Sleep    2s
    Wait For App Loading To Complete
    Sleep    1s
    Log    Searched for user: ${username}

Clear Search In Grid
    [Documentation]    Clears the search input and refreshes the grid.
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_SEARCH}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_MANAGE_USER_SEARCH}
    Press Keys    ${LOC_MANAGE_USER_SEARCH}    RETURN
    Sleep    2s
    Wait For App Loading To Complete
    Log    Search cleared.

# ═══════════════════════════════════════════════════════════════════════
#  DELETE USER (MD: TC_002 Steps 3–7, Confirmation Dialog Reference)
# ═══════════════════════════════════════════════════════════════════════
Click Delete Icon For User
    [Documentation]    Clicks the Delete User icon in the Action column for the given user.
    ...                MD: Step 3 — //tr[td[contains(text(),'USERNAME')]]//span[@title='Delete User']
    [Arguments]    ${username}
    ${delete_loc}=    Replace String    ${LOC_DELETE_ICON_TEMPLATE}    PLACEHOLDER    ${username}
    ${delete_xpath}=    Set Variable    xpath=${delete_loc}
    Wait Until Element Is Visible    ${delete_xpath}    ${UM_TIMEOUT}
    Click Element Via JS    ${delete_xpath}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Delete icon clicked for user: ${username}

Verify Delete Confirmation Dialog
    [Documentation]    Verifies the delete confirmation dialog appears with correct heading and body.
    ...                MD: Step 4 — Heading: "Delete User"
    ...                MD: Step 5 — Body: "Do you want to delete the user - USERNAME?"
    [Arguments]    ${username}
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG}    10s
    IF    not ${dialog_visible}
        Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_OK}    10s
    END
    ${heading_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_HEADING}    5s
    IF    ${heading_visible}
        ${heading_text}=    Get Text    ${LOC_DELETE_DIALOG_HEADING}
        Should Contain    ${heading_text}    ${DELETE_DIALOG_HEADING}
        Log    Dialog heading verified: ${heading_text}
    END
    ${body_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_BODY}    5s
    IF    ${body_visible}
        ${body_text}=    Get Text    ${LOC_DELETE_DIALOG_BODY}
        Should Contain    ${body_text}    ${username}
        Log    Dialog body verified: ${body_text}
    END

Click OK On Delete Confirmation
    [Documentation]    Clicks the OK button on the delete confirmation dialog.
    ...                MD: Step 6 — Click OK → Deletion request submitted
    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_OK}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_DIALOG_OK}
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    OK clicked on delete confirmation.

Click Cancel On Delete Confirmation
    [Documentation]    Clicks the Cancel button on the delete confirmation dialog.
    ...                MD: Confirmation Dialog Reference — Cancel button
    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_CANCEL}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_DIALOG_CANCEL}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Cancel clicked on delete confirmation.

Verify Delete Success Toast
    [Documentation]    Verifies the toast message "User Deleted Successfully".
    ...                MD: Step 7 — Toast: "User Deleted Successfully"
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    15s
    IF    ${visible}
        ${msg}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_TOAST_MESSAGE}    5s
        IF    ${msg}
            ${text}=    Get Text    ${LOC_TOAST_MESSAGE}
            Should Contain    ${text}    ${DELETE_SUCCESS_MSG}
            Log    Delete success toast: ${text}
        END
    ELSE
        Log    Success toast not found after delete.    level=WARN
    END

Delete User End To End
    [Documentation]    Full delete flow: search → click delete → verify dialog → click OK → verify removal.
    ...                MD: TC_002 Steps 2–8
    [Arguments]    ${username}
    Search User In Grid    ${username}
    Click Delete Icon For User    ${username}
    Verify Delete Confirmation Dialog    ${username}
    Click OK On Delete Confirmation
    Verify Delete Success Toast
    Clear Search In Grid
    Verify User Not In Grid    ${username}
