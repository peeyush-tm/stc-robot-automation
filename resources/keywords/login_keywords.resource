*** Settings ***
Library     SeleniumLibrary
Library     DatabaseLibrary
Resource    browser_keywords.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  PAGE READINESS
# ═══════════════════════════════════════════════════════════════════════
Wait For Login Page Ready
    [Documentation]    Waits for the React SPA root to mount, the login form to render,
    ...                and the captcha image + input to fully load before any interaction.
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_IMAGE}   timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}   timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=10s

# ═══════════════════════════════════════════════════════════════════════
#  FIELD INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Enter Username
    [Documentation]    Clears and enters the given username.
    [Arguments]    ${username}
    Clear And Input Text Into Field    ${LOC_LOGIN_USERNAME_INPUT}    ${username}

Enter Password
    [Documentation]    Clears and enters the given password.
    [Arguments]    ${password}
    Clear And Input Text Into Field    ${LOC_LOGIN_PASSWORD_INPUT}    ${password}

Enter Captcha
    [Documentation]    Clears and enters the given captcha value.
    [Arguments]    ${captcha_value}
    Clear And Input Text Into Field    ${LOC_LOGIN_CAPTCHA_INPUT}    ${captcha_value}

Click Login Button
    [Documentation]    Clicks the Login button (input.btn-custom-color).
    Click Element Safely    ${LOC_LOGIN_BUTTON}

# ═══════════════════════════════════════════════════════════════════════
#  DATABASE — CAPTCHA FETCH
# ═══════════════════════════════════════════════════════════════════════
Connect To Captcha Database
    [Documentation]    Opens a MySQL connection to the CAPTCHA database.
    Connect To Database    pymysql
    ...    db_host=${DB_HOST}
    ...    db_port=${DB_PORT}
    ...    db_name=${DB_NAME}
    ...    db_user=${DB_USER}
    ...    db_password=${DB_PASS}

Fetch Captcha From Database
    [Documentation]    Queries the captcha table and returns the latest captcha_text value.
    ${result}=    Query    ${CAPTCHA_QUERY}
    Should Not Be Empty    ${result}    No CAPTCHA record found in the captcha table.
    ${captcha_value}=    Set Variable    ${result[0][0]}
    Log    Fetched CAPTCHA from DB: ${captcha_value}
    RETURN    ${captcha_value}

Disconnect From Captcha Database
    [Documentation]    Closes the database connection.
    Disconnect From Database

Fetch Captcha Value
    [Documentation]    Connect to DB, fetch captcha_text, disconnect. Returns the captcha value.
    Connect To Captcha Database
    ${captcha_value}=    Fetch Captcha From Database
    Disconnect From Captcha Database
    RETURN    ${captcha_value}

# ═══════════════════════════════════════════════════════════════════════
#  LOGIN FLOWS
# ═══════════════════════════════════════════════════════════════════════
Login With Credentials
    [Documentation]    Full login flow: wait for page, enter username & password,
    ...                fetch captcha from DB, enter captcha, click Login.
    [Arguments]    ${username}    ${password}
    Wait For Login Page Ready
    Enter Username    ${username}
    Enter Password    ${password}
    ${captcha_value}=    Fetch Captcha Value
    Enter Captcha    ${captcha_value}
    Click Login Button

Login With Credentials And Empty Captcha
    [Documentation]    Enters credentials but intentionally leaves captcha empty, then clicks Login.
    [Arguments]    ${username}    ${password}
    Wait For Login Page Ready
    Enter Username    ${username}
    Enter Password    ${password}
    Clear Element Text    ${LOC_LOGIN_CAPTCHA_INPUT}
    Click Login Button

Login With Credentials And Wrong Captcha
    [Documentation]    Enters credentials with an intentionally incorrect captcha value.
    [Arguments]    ${username}    ${password}    ${wrong_captcha}
    Wait For Login Page Ready
    Enter Username    ${username}
    Enter Password    ${password}
    Enter Captcha    ${wrong_captcha}
    Click Login Button

# ═══════════════════════════════════════════════════════════════════════
#  LOGIN VALIDATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify Login Success
    [Documentation]    Confirms login succeeded by asserting the Manage Devices grid content table
    ...                is visible with data rows and the error message container is absent.
    Wait Until Element Is Not Visible    ${LOC_LOGIN_BUTTON}    timeout=15s
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}       timeout=20s
    Wait Until Element Is Visible    ${LOC_MD_GRID_TBODY}      timeout=15s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}    timeout=15s
    Page Should Not Contain Element    ${LOC_LOGIN_ERROR_MESSAGE}
    ${row_count}=    Get Element Count    ${LOC_MD_DEVICE_ROWS}
    Should Be True    ${row_count} > 0    Grid loaded but no device rows found.
    Log    Login successful — Manage Devices grid visible with ${row_count} row(s).

Verify Login Error Displayed
    [Documentation]    Asserts the error container (div.erre-it) is visible with text.
    Wait Until Element Is Visible    ${LOC_LOGIN_ERROR_MESSAGE}    timeout=10s
    ${error_text}=    Get Text    ${LOC_LOGIN_ERROR_MESSAGE}
    Should Not Be Empty    ${error_text}
    Log    Login error displayed: ${error_text}

Verify Still On Login Page
    [Documentation]    Confirms the user has not left the login page (login button still visible).
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}    timeout=5s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=5s

# ═══════════════════════════════════════════════════════════════════════
#  LOGOUT
# ═══════════════════════════════════════════════════════════════════════
Perform Logout
    [Documentation]    Opens the user dropdown in the top-right header via JS click,
    ...                waits for the dropdown to expand, then clicks the Log Out link.
    Click Element Via JS    ${LOC_USER_PROFILE_MENU}
    Wait Until Element Is Visible    ${LOC_LOGOUT_BUTTON}    timeout=5s
    Click Element Via JS    ${LOC_LOGOUT_BUTTON}

Verify Logout Success
    [Documentation]    Confirms the login page is displayed again after logout.
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=10s
    Log    Logout successful — login page is displayed.

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE DEVICES NAVIGATION & VALIDATION
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage Devices
    [Documentation]    Navigates to the Manage Devices page.
    Go To    ${MANAGE_DEVICES_URL}
    Wait For Page Load

Verify Manage Devices Page Loaded
    [Documentation]    Validates the Manage Devices page URL and key UI elements.
    Location Should Contain    ${MANAGE_DEVICES_PATH}
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}      timeout=15s
    Wait Until Element Is Visible    ${LOC_MD_SEARCH_INPUT}   timeout=10s
    Wait Until Element Is Visible    ${LOC_MD_ACTION_FORM}    timeout=10s
    Log    Manage Devices page loaded — grid, search input, and action form are visible.

Verify Manage Devices Grid Has Data
    [Documentation]    Confirms the Kendo grid tbody is visible and contains at least one k-master-row.
    Wait Until Element Is Visible    ${LOC_MD_GRID_TBODY}          timeout=15s
    Wait Until Element Is Visible    ${LOC_MD_FIRST_DEVICE_ROW}    timeout=10s
    ${row_count}=    Get Element Count    ${LOC_MD_DEVICE_ROWS}
    Should Be True    ${row_count} > 0    Manage Devices grid has no data rows.
    Log    Manage Devices grid loaded with ${row_count} device row(s).

Verify Redirected To Login Page
    [Documentation]    Confirms that an unauthenticated user is redirected back to the login page.
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=10s
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    ${MANAGE_DEVICES_PATH}
    Log    Unauthenticated access redirected to login page.
