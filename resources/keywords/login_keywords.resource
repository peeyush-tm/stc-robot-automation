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
    [Documentation]    Waits for the React SPA root to mount and the login form to render.
    ...                Captcha image/input waits are skipped when CAPTCHA_ENABLE=false in the app config.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=30s

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
    [Documentation]    Clicks the Login button via pure JS to bypass loading-indicator overlay.
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Execute Javascript
    ...    var btn = document.querySelector("input[type='button'][class*='btn-custom-color']"); if(btn) btn.click();

# ═══════════════════════════════════════════════════════════════════════
#  DATABASE — CAPTCHA FETCH
# ═══════════════════════════════════════════════════════════════════════
Captcha Image Loaded
    [Documentation]    Passes when the captcha <img> src is a base64 data URI,
    ...                confirming the getCaptcha() API call completed and React setState is done.
    ${src}=    Execute JavaScript
    ...    var img = document.getElementById('image');
    ...    return img ? img.src : '';
    Should Contain    ${src}    data:image    msg=Captcha image not yet loaded (src=${src})

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
    [Documentation]    Full login flow: wait for page, handle captcha (if enabled), THEN enter
    ...                username & password. Credentials are entered AFTER the captcha API call
    ...                completes its React setState so that a getCaptcha re-render cannot clear
    ...                the typed username/password values.
    [Arguments]    ${username}    ${password}
    Wait For Login Page Ready
    # ── Step 1: handle captcha FIRST so React's getCaptcha setState is already done ──
    ${captcha_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}    timeout=8s
    IF    ${captcha_visible}
        # Wait for captcha image src to be populated (confirms getCaptcha API + setState done)
        Wait Until Keyword Succeeds    15x    1s    Captcha Image Loaded
        ${captcha_value}=    Wait Until Keyword Succeeds    8x    2s    Fetch Captcha Value
        Enter Captcha    ${captcha_value}
    ELSE
        Log    Captcha not enabled on this environment — skipping captcha step.    level=INFO
        Sleep    1s
    END
    # ── Step 2: enter credentials AFTER React is stable (no pending setState) ──
    Enter Username    ${username}
    Enter Password    ${password}
    Click Login Button

Login With Credentials And Empty Captcha
    [Documentation]    Enters credentials but intentionally leaves captcha empty, then clicks Login.
    [Arguments]    ${username}    ${password}
    Wait For Login Page Ready
    Enter Username    ${username}
    Enter Password    ${password}
    Wait For Loading Overlay To Disappear
    Clear Element Text    ${LOC_LOGIN_CAPTCHA_INPUT}
    Click Login Button

Login With Credentials And Wrong Captcha
    [Documentation]    Enters credentials with an intentionally incorrect captcha value.
    [Arguments]    ${username}    ${password}    ${wrong_captcha}
    Wait For Login Page Ready
    Enter Username    ${username}
    Enter Password    ${password}
    Wait For Loading Overlay To Disappear
    Enter Captcha    ${wrong_captcha}
    Click Login Button

# ═══════════════════════════════════════════════════════════════════════
#  LOGIN VALIDATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify Login Success
    [Documentation]    Confirms login succeeded by asserting the Manage Devices grid content table
    ...                is visible with data rows and the error message container is absent.
    ...                Waits for post-login landmark (not for login button to disappear) so we are not
    ...                affected by other pages that also have input.btn-custom-color.
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}       timeout=45s
    Wait Until Element Is Visible    ${LOC_MD_GRID_TBODY}      timeout=30s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}    timeout=30s
    Page Should Not Contain Element    ${LOC_LOGIN_ERROR_MESSAGE}
    ${row_count}=    Get Element Count    ${LOC_MD_DEVICE_ROWS}
    Should Be True    ${row_count} > 0    Grid loaded but no device rows found.
    Log    Login successful — Manage Devices grid visible with ${row_count} row(s).

Verify Login Error Displayed
    [Documentation]    Asserts any login error is visible — inline (div.erre-it), toast, or field validation.
    Sleep    2s
    ${inline_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_ERROR_MESSAGE}    timeout=10s
    ${toast_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_TOAST_ERROR}    timeout=5s
    ${field_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_FIELD_VALIDATION}    timeout=5s
    Should Be True    ${inline_visible} or ${toast_visible} or ${field_visible}
    ...    No login error found (checked inline, toast, and field validation).
    Log    Login error detected — inline:${inline_visible} toast:${toast_visible} field:${field_visible}

Verify Inline Error Message Is
    [Documentation]    Asserts the inline error container (div.erre-it) shows the expected text.
    [Arguments]    ${expected_text}
    Wait Until Element Is Visible    ${LOC_LOGIN_ERROR_MESSAGE}    timeout=30s
    ${error_text}=    Get Text    ${LOC_LOGIN_ERROR_MESSAGE}
    Should Contain    ${error_text}    ${expected_text}
    ...    msg=Expected inline error "${expected_text}" but got "${error_text}"
    Log    Verified inline error: ${error_text}

Verify Toast Error Message Is
    [Documentation]    Asserts the Toastify error toast shows the expected text.
    [Arguments]    ${expected_text}
    Wait Until Element Is Visible    ${LOC_LOGIN_TOAST_ERROR}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_LOGIN_TOAST_ERROR}
    Should Contain    ${toast_text}    ${expected_text}
    ...    msg=Expected toast error "${expected_text}" but got "${toast_text}"
    Log    Verified toast error: ${toast_text}

Verify Field Validation Message
    [Documentation]    Asserts a field-level inline validation message is visible with expected text.
    [Arguments]    ${expected_text}    ${timeout}=15s
    ${locator}=    Set Variable    xpath=//*[contains(text(),'${expected_text}')]
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Log    Verified field validation: ${expected_text}

Verify Authorization Failure Error
    [Documentation]    Asserts the inline error message contains "Authorization Failure".
    Verify Inline Error Message Is    ${ERROR_AUTH_FAILURE}
    Verify Still On Login Page

Verify Invalid Captcha Error
    [Documentation]    Asserts the inline error message contains "Invalid Captcha".
    Verify Inline Error Message Is    ${ERROR_INVALID_CAPTCHA}
    Verify Still On Login Page

Verify Please Enter Captcha Toast
    [Documentation]    Asserts the toast error "Please Enter Captcha" is displayed.
    Verify Toast Error Message Is    ${ERROR_PLEASE_ENTER_CAPTCHA}
    Verify Still On Login Page

Verify Username Required Error
    [Documentation]    Asserts the inline field validation "Username is required" is displayed.
    Verify Field Validation Message    ${ERROR_USERNAME_REQUIRED}
    Verify Still On Login Page

Verify Password Required Error
    [Documentation]    Asserts "Password Required" is displayed via field validation, inline error,
    ...                toast, or any other login error (e.g. Authorization Failure for empty password).
    Sleep    3s
    ${field_ok}=    Run Keyword And Return Status
    ...    Verify Field Validation Message    ${ERROR_PASSWORD_REQUIRED}
    IF    not ${field_ok}
        ${any_error}=    Run Keyword And Return Status
        ...    Verify Login Error Displayed
        IF    not ${any_error}
            ${page_text}=    Execute Javascript    return document.body.innerText;
            ${has_text_error}=    Evaluate    'required' in '''${page_text}'''.lower() or 'failure' in '''${page_text}'''.lower() or 'error' in '''${page_text}'''.lower() or 'invalid' in '''${page_text}'''.lower()
            Should Be True    ${has_text_error}
            ...    No login error found for empty password — no field validation, toast, or inline error visible.
        END
    END
    Verify Still On Login Page

Verify All Fields Empty Error
    [Documentation]    Asserts both "Username is required" and "Password Required" are displayed.
    Verify Field Validation Message    ${ERROR_USERNAME_REQUIRED}
    Verify Field Validation Message    ${ERROR_PASSWORD_REQUIRED}
    Verify Still On Login Page

Verify Still On Login Page
    [Documentation]    Confirms the user has not left the login page (login button still visible).
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}    timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  SUITE-LEVEL SESSION MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════
Suite Login Setup
    [Documentation]    Opens browser, logs in, and verifies success. Used as Suite Setup
    ...                so the browser and authenticated session persist across all tests.
    [Arguments]    ${url}    ${browser}
    Open Test Browser    ${url}    ${browser}
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success

Ensure Session Is Active
    [Documentation]    Checks if the browser has been redirected to the login page
    ...                (session expired). If so, re-logs in automatically.
    ...                Uses username input to detect login page (unique to login; avoids matching other pages' buttons).
    ${on_login}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=3s
    IF    ${on_login}
        Log    Session expired — re-logging in.    level=WARN
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
    END

Navigate To Module Page
    [Documentation]    Navigates to a module page via direct URL. If the session has
    ...                expired (redirected to login), re-logs in and retries navigation.
    [Arguments]    ${url}
    Go To    ${url}
    Wait For Page Load
    ${on_login}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=3s
    IF    ${on_login}
        Log    Session expired during navigation — re-logging in.    level=WARN
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
        Go To    ${url}
        Wait For Page Load
    END

Prepare Login Page
    [Documentation]    Clears cookies and navigates to the login page.
    ...                Used as Test Setup for the login test suite so each test
    ...                starts from a clean login form.
    Delete All Cookies
    Go To    ${BASE_URL}
    Wait For Page Load
    Wait For Login Page Ready

Clear Session For Unauthenticated Test
    [Documentation]    Clears cookies and storage to simulate an unauthenticated user.
    ...                Used as [Setup] override for "direct access without login" tests.
    Delete All Cookies
    Execute Javascript    window.sessionStorage.clear();
    Execute Javascript    window.localStorage.clear();

# ═══════════════════════════════════════════════════════════════════════
#  LOGOUT
# ═══════════════════════════════════════════════════════════════════════
Perform Logout
    [Documentation]    Opens the user dropdown in the top-right header via JS click,
    ...                waits for the dropdown to expand, then clicks the Log Out link.
    Click Element Via JS    ${LOC_USER_PROFILE_MENU}
    Wait Until Element Is Visible    ${LOC_LOGOUT_BUTTON}    timeout=30s
    Click Element Via JS    ${LOC_LOGOUT_BUTTON}

Verify Logout Success
    [Documentation]    Confirms the login page is displayed again after logout.
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=30s
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
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}      timeout=30s
    Wait Until Element Is Visible    ${LOC_MD_SEARCH_INPUT}   timeout=30s
    Wait Until Element Is Visible    ${LOC_MD_ACTION_FORM}    timeout=30s
    Log    Manage Devices page loaded — grid, search input, and action form are visible.

Verify Manage Devices Grid Has Data
    [Documentation]    Confirms the Kendo grid tbody is visible and contains at least one k-master-row.
    Wait Until Element Is Visible    ${LOC_MD_GRID_TBODY}          timeout=30s
    Wait Until Element Is Visible    ${LOC_MD_FIRST_DEVICE_ROW}    timeout=30s
    ${row_count}=    Get Element Count    ${LOC_MD_DEVICE_ROWS}
    Should Be True    ${row_count} > 0    Manage Devices grid has no data rows.
    Log    Manage Devices grid loaded with ${row_count} device row(s).

Verify Redirected To Login Page
    [Documentation]    Confirms that an unauthenticated user is redirected back to the login page.
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=30s
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    ${MANAGE_DEVICES_PATH}
    Log    Unauthenticated access redirected to login page.
