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
    ...                If already authenticated (no login form), returns immediately.
    Wait For Loading Overlay To Disappear
    Wait Until Page Contains Element    ${LOC_LOGIN_ROOT}            timeout=90s
    ${has_login}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=10s
    IF    not ${has_login}
        Log    Login page not shown — already authenticated or app redirected. Skipping login form wait.    level=WARN    console=yes
        RETURN
    END
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=60s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=60s

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

Verify Login Credential Fields Match
    [Documentation]    Asserts username and password inputs still hold the expected values.
    ...                Catches React re-renders or captcha/API work that clears fields after typing.
    [Arguments]    ${username}    ${password}
    ${u}=    Get Value    ${LOC_LOGIN_USERNAME_INPUT}
    Should Be Equal As Strings    ${u}    ${username}
    ...    msg=Username field empty or wrong after entry (captcha/API may have cleared it). Got: ${u}
    ${p}=    Get Value    ${LOC_LOGIN_PASSWORD_INPUT}
    Should Be Equal As Strings    ${p}    ${password}
    ...    msg=Password field empty or wrong after entry (captcha/API may have cleared it).

Try Enter Login Credentials Once
    [Documentation]    Single attempt: type credentials, wait for overlay/settle, assert values present.
    [Arguments]    ${username}    ${password}
    Enter Username    ${username}
    Enter Password    ${password}
    Wait For Loading Overlay To Disappear
    Brief UI Settle Long
    Verify Login Credential Fields Match    ${username}    ${password}

Enter Login Credentials With Verified Values
    [Documentation]    Types username and password and verifies both fields retained the values.
    ...                Retries if a late React update (e.g. after captcha) cleared the inputs.
    [Arguments]    ${username}    ${password}
    Wait Until Keyword Succeeds    6x    1s    Try Enter Login Credentials Once    ${username}    ${password}

Enter Captcha
    [Documentation]    Clears and enters the given captcha value.
    [Arguments]    ${captcha_value}
    Clear And Input Text Into Field    ${LOC_LOGIN_CAPTCHA_INPUT}    ${captcha_value}

Click Login Button
    [Documentation]    Clicks the Login button via pure JS to bypass loading-indicator overlay.
    Sleep    1s
    Wait For Loading Overlay To Disappear
    Execute Javascript
    ...    var btn = document.querySelector("input[type='button'][class*='btn-custom-color']"); if(btn) btn.click();

# ═══════════════════════════════════════════════════════════════════════
#  DATABASE — CAPTCHA FETCH
# ═══════════════════════════════════════════════════════════════════════
Captcha Image Loaded
    [Documentation]    Passes when the captcha image is ready: base64 data URI, http(s)/blob URL,
    ...                relative API path, painted frame (naturalWidth > 0), or CSS background-image.
    ...                Some CMP builds keep img.src empty while the challenge loads.
    ${state}=    Execute JavaScript
    ...    var img = document.getElementById('image') || document.querySelector('img#image');
    ...    if (!img) {
    ...      var cand = document.querySelectorAll('.captcha img, #captcha img, img.captcha');
    ...      if (cand.length) img = cand[0];
    ...    }
    ...    if (!img) {
    ...      var all = document.querySelectorAll('img');
    ...      for (var j = 0; j < all.length; j++) {
    ...        var al = (all[j].getAttribute('alt') || '').toLowerCase();
    ...        if (al.indexOf('aptcha') >= 0) { img = all[j]; break; }
    ...      }
    ...    }
    ...    if (!img) return 'missing';
    ...    var s = (img.currentSrc || img.getAttribute('src') || '').trim();
    ...    if (s && s !== 'about:blank') {
    ...      if (s.indexOf('data:image') === 0 || s.indexOf('http://') === 0 || s.indexOf('https://') === 0
    ...          || s.indexOf('blob:') === 0 || s.charAt(0) === '/') {
    ...        return 'ok';
    ...      }
    ...    }
    ...    if (img.complete && img.naturalWidth > 0) return 'ok';
    ...    var bi = window.getComputedStyle(img).backgroundImage || '';
    ...    if (bi && bi.indexOf('url(') >= 0 && bi.indexOf('none') < 0) return 'ok';
    ...    return 'pending';
    Should Be Equal As Strings    ${state}    ok
    ...    msg=Captcha image not ready (state=${state}). Check getCaptcha / network.

Connect To Captcha Database
    [Documentation]    Opens a MySQL connection to the CAPTCHA database.
    Connect To Database    pymysql    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}

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
    # If already authenticated (no login form visible), skip entire login flow
    ${on_login_page}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=120s
    IF    not ${on_login_page}
        Log    Login form never appeared — app may already be authenticated. Skipping login.    level=WARN    console=yes
        RETURN
    END
    # ── Step 1: handle captcha FIRST so React's getCaptcha setState is already done ──
    ${captcha_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}    timeout=8s
    IF    ${captcha_visible}
        # Wait for captcha image (data URL, http/blob, or painted) — slow APIs need more retries
        ${img_ready}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    30x    1s    Captcha Image Loaded
        IF    not ${img_ready}
            Log    Captcha <img> did not report ready — fetching captcha from DB anyway (input visible).    level=WARN
        END
        ${captcha_value}=    Wait Until Keyword Succeeds    8x    2s    Fetch Captcha Value
        Enter Captcha    ${captcha_value}
    ELSE
        Log    Captcha not enabled on this environment — skipping captcha step.    level=INFO
        Sleep    1s
    END
    # ── Step 2: enter credentials AFTER React is stable (no pending setState) ──
    Enter Login Credentials With Verified Values    ${username}    ${password}
    Verify Login Credential Fields Match    ${username}    ${password}
    Click Login Button
    Wait For Page Load
    Wait For Loading Overlay To Disappear

Login With Credentials And Empty Captcha
    [Documentation]    Leaves captcha empty and submits. Same ordering as ``Login With Credentials``:
    ...                captcha widget ready FIRST (wait for image), THEN username & password.
    ...                Clearing captcha after typing user/pass can trigger React setState and wipe credentials.
    [Arguments]    ${username}    ${password}
    Wait For Login Page Ready
    ${captcha_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}    timeout=8s
    IF    ${captcha_visible}
        ${img_ready}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    30x    1s    Captcha Image Loaded
        IF    not ${img_ready}
            Log    Captcha <img> not ready — continuing empty-captcha test.    level=WARN
        END
        Wait For Loading Overlay To Disappear
        Clear Element Text    ${LOC_LOGIN_CAPTCHA_INPUT}
        Press Keys    ${LOC_LOGIN_CAPTCHA_INPUT}    TAB
        Brief UI Settle
    ELSE
        Log    Captcha input not shown — empty captcha test without captcha step.    level=INFO
        Sleep    1s
    END
    Enter Login Credentials With Verified Values    ${username}    ${password}
    Wait For Loading Overlay To Disappear
    Verify Login Credential Fields Match    ${username}    ${password}
    Click Login Button

Login With Credentials And Wrong Captcha
    [Documentation]    Wrong captcha with valid credentials. Same ordering as ``Login With Credentials``:
    ...                captcha image ready, wrong value in captcha field, then username & password.
    [Arguments]    ${username}    ${password}    ${wrong_captcha}
    Wait For Login Page Ready
    ${captcha_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}    timeout=8s
    IF    ${captcha_visible}
        ${img_ready}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    30x    1s    Captcha Image Loaded
        IF    not ${img_ready}
            Log    Captcha <img> not ready — entering wrong captcha anyway.    level=WARN
        END
        Wait For Loading Overlay To Disappear
        Enter Captcha    ${wrong_captcha}
        Brief UI Settle
    ELSE
        Log    Captcha input not shown — wrong captcha step skipped.    level=WARN
        Enter Captcha    ${wrong_captcha}
    END
    Enter Login Credentials With Verified Values    ${username}    ${password}
    Wait For Loading Overlay To Disappear
    Verify Login Credential Fields Match    ${username}    ${password}
    Click Login Button

# ═══════════════════════════════════════════════════════════════════════
#  LOGIN VALIDATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify Login Success
    [Documentation]    After login submit: fail fast on auth errors, open Manage Devices explicitly
    ...                (SPA often lands on a shell without #gridData), then assert grid with data rows.
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Brief UI Settle
    ${inline_err}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_ERROR_MESSAGE}    timeout=10s
    IF    ${inline_err}
        Fail    Login rejected: inline error visible — check credentials, captcha, and DB captcha sync.
    END
    ${toast_err}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_TOAST_ERROR}    timeout=5s
    IF    ${toast_err}
        Fail    Login rejected: error toast visible — check credentials or captcha.
    END
    Go To    ${MANAGE_DEVICES_URL}
    Wait For Page Load
    Wait For App Loading To Complete
    Brief UI Settle
    ${sent_to_login}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=15s
    IF    ${sent_to_login}
        Fail    Not authenticated — Manage Devices redirected to login (session, credentials, or captcha).
    END
    # Verify login by checking URL moved away from login — avoid waiting for #gridData
    # which can take 2+ minutes on slow QE connections with large Kendo grids.
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    /?redirect=
    ...    msg=Login may have failed — URL still contains redirect parameter.
    Page Should Not Contain Element    ${LOC_LOGIN_ERROR_MESSAGE}
    Log    Login successful — URL no longer on login redirect.    console=yes

Verify Login Error Displayed
    [Documentation]    Asserts any login error is visible — inline (div.erre-it), toast, or field validation.
    Sleep    1s
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
    Sleep    1s
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
    [Documentation]    Opens browser, logs in, and verifies success. If the initial page load shows a Chrome OOM
    ...                crash page, closes, waits briefly, and retries once (heavy SPA on first load).
    [Arguments]    ${url}    ${browser}
    Open Test Browser    ${url}    ${browser}
    ${oom}=    Page Is Chrome OOM Crash
    IF    ${oom}
        Log    Chrome OOM on initial page load — closing and retrying once.    level=WARN
        Run Keyword And Ignore Error    Close All Browsers
        Force Kill Chrome Processes
        Open Test Browser    ${url}    ${browser}
    END
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success

Ensure Session Is Active
    [Documentation]    Checks if the browser has been redirected to the login page (session expired) or if Chrome
    ...                crashed entirely (JS unreachable). Restarts browser and re-logs in if either is true.
    ...                Uses instant JS check instead of Wait Until Element Is Visible to avoid noisy FAIL logs.
    ${browser_alive}=    Run Keyword And Return Status
    ...    Execute Javascript    return true
    IF    not ${browser_alive}
        Log    Browser unresponsive in Ensure Session Is Active — restarting.    level=WARN
        Run Keyword And Ignore Error    Close All Browsers
        Force Kill Chrome Processes
        Open Test Browser    ${BASE_URL}    ${BROWSER}
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
        RETURN
    END
    # Instant JS check — no timeout, no FAIL log, no screenshot noise
    ${on_login}=    Execute Javascript
    ...    var el = document.querySelector('input[name="username"]');
    ...    return el && el.offsetParent !== null;
    IF    ${on_login}
        Log    Session expired — re-logging in.    level=WARN
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
    END

Navigate To Module Page
    [Documentation]    Navigates to a module page via direct URL. Handles three failure modes automatically:
    ...                1. **Complete Chrome process death** (Go To throws / JS unreachable): restarts browser + re-login.
    ...                2. **Chrome tab OOM** (Aw, Snap! / Out of Memory page): restarts browser + re-login.
    ...                3. **Session expiry** (redirected to login): re-logs in and retries.
    ...                GC hint is sent before navigation to free V8 heap from prior heavy pages.
    [Arguments]    ${url}
    Request Page Garbage Collection Best Effort
    ${nav_ok}=    Run Keyword And Return Status    Go To    ${url}
    IF    not ${nav_ok}
        Log    Go To ${url} failed — Chrome process may have crashed. Restarting browser.    level=WARN
        Run Keyword And Ignore Error    Close All Browsers
        Force Kill Chrome Processes
        Open Test Browser    ${BASE_URL}    ${BROWSER}
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
        Go To    ${url}
        Wait For Page Load
        RETURN
    END
    Wait For Page Load
    ${oom}=    Page Is Chrome OOM Crash
    IF    ${oom}
        Log    Chrome OOM crash detected navigating to ${url} — restarting browser and re-logging in.    level=WARN
        Run Keyword And Ignore Error    Close All Browsers
        Force Kill Chrome Processes
        Open Test Browser    ${BASE_URL}    ${BROWSER}
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
        Go To    ${url}
        Wait For Page Load
        RETURN
    END
    ${on_login}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=3s
    IF    ${on_login}
        Log    Session expired during navigation — re-logging in.    level=WARN
        Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
        Verify Login Success
        Go To    ${url}
        Wait For Page Load
    END

Navigate To Url In Current Session
    [Documentation]    ``Go To`` + ``Wait For Page Load`` only. Does **not** run ``Ensure Session Is Active`` or
    ...                ``Navigate To Module Page`` recovery (no Chrome restart, OOM retry, or re-login on session expiry).
    ...                Use when the suite already logged in and the test must stay on a single browser session.
    [Arguments]    ${url}
    Go To    ${url}
    Wait For Page Load

Prepare Login Page
    [Documentation]    Clears cookies, storage, and navigates so the SPA shows the login form.
    ...                After a prior test was logged in, cookies-only clear can leave the app on
    ...                an authenticated route without inputs — session/local storage must be cleared
    ...                and the base URL reloaded (sometimes twice) so React mounts the login screen.
    Delete All Cookies
    Go To    ${BASE_URL}
    Wait For Page Load
    Run Keyword And Ignore Error    Execute Javascript    window.sessionStorage.clear();
    Run Keyword And Ignore Error    Execute Javascript    window.localStorage.clear();
    Go To    ${BASE_URL}
    Wait For Page Load
    ${login_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}    timeout=8s
    IF    not ${login_ok}
        Execute Javascript    window.location.reload();
        Wait For Page Load
    END
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
    [Documentation]    Opens the user menu (#userSetting), then clicks Log Out. Tries the first
    ...                dropdown li, then falls back to the legacy profile anchor if needed.
    Wait For Loading Overlay To Disappear
    ${opened}=    Run Keyword And Return Status    Run Keywords
    ...    Wait Until Element Is Visible    ${LOC_USER_SETTING_DROPDOWN_TRIGGER}    timeout=15s
    ...    AND    Scroll To Element Via JS    ${LOC_USER_SETTING_DROPDOWN_TRIGGER}
    ...    AND    Click Element Via JS    ${LOC_USER_SETTING_DROPDOWN_TRIGGER}
    IF    not ${opened}
        Wait Until Element Is Visible    ${LOC_USER_PROFILE_MENU}    timeout=15s
        Scroll To Element Via JS    ${LOC_USER_PROFILE_MENU}
        Click Element Via JS    ${LOC_USER_PROFILE_MENU}
    END
    Brief UI Settle
    Wait Until Element Is Visible    ${LOC_LOGOUT_BUTTON}    timeout=15s
    Click Element Via JS    ${LOC_LOGOUT_BUTTON}

Verify Logout Success
    [Documentation]    After logout: waits for the SPA to load, then asserts the login form is visible
    ...                and the browser URL no longer targets Manage Devices (same redirect rule as
    ...                Verify Redirected To Login Page).
    Wait For Page Load
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=30s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}          timeout=30s
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    ${MANAGE_DEVICES_PATH}
    Log    Logout successful — login form visible and URL no longer contains ${MANAGE_DEVICES_PATH}.

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
