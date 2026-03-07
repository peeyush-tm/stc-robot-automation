*** Settings ***
# Login flow timing (for future use): (1) After visiting login page → wait 15s for page load.
# (2) After entering username and password → wait 10s for CAPTCHA to appear, then enter captcha and click Login.
# CAPTCHA input has dynamic id (UUID); locator uses name=captcha.
Library    SeleniumLibrary
Library    DatabaseLibrary

*** Keywords ***
# ---- Page readiness ----
Wait For Login Page To Reload
    [Documentation]    After visiting login URL, wait 15s for page to load, then verify all login elements are visible.
    Sleep    ${PAGE_RELOAD_WAIT}s
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}        timeout=20s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME}    timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD}    timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA}     timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}      timeout=10s

# ---- CAPTCHA from DB ----
Connect To CAPTCHA Database
    [Documentation]    Establish connection to MySQL for CAPTCHA fetch.
    DatabaseLibrary.Connect To Database Using Custom Params    pymysql    host='${DB_HOST}', port=${DB_PORT}, database='${DB_NAME}', user='${DB_USER}', passwd='${DB_PASS}'

Fetch CAPTCHA From Database
    [Documentation]    Return latest captcha_text from captcha table.
    ${result}=    DatabaseLibrary.Query    SELECT captcha_text FROM captcha ORDER BY id DESC LIMIT 1
    ${captcha_value}=    Set Variable    ${result[0][0]}
    [Return]    ${captcha_value}

Disconnect From CAPTCHA Database
    [Documentation]    Close DB connection after CAPTCHA fetch.
    DatabaseLibrary.Disconnect From Database

# ---- Form fill and submit ----
Enter Username
    [Arguments]    ${username}
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME}    timeout=10s
    Input Text    ${LOC_LOGIN_USERNAME}    ${username}

Enter Password
    [Arguments]    ${password}
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD}    timeout=10s
    Input Text    ${LOC_LOGIN_PASSWORD}    ${password}

Wait For Captcha To Appear
    [Documentation]    Wait 10s for CAPTCHA to appear after entering credentials. Then confirm the CAPTCHA image is visible before proceeding.
    Sleep    ${POST_CREDENTIALS_WAIT}s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_IMG}    timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA}    timeout=10s

Enter Captcha
    [Arguments]    ${captcha_value}
    [Documentation]    Clear any existing value in captcha field, then type the fetched value.
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA}    timeout=10s
    Clear Element Text    ${LOC_LOGIN_CAPTCHA}
    Input Text    ${LOC_LOGIN_CAPTCHA}    ${captcha_value}
    Log    Entered CAPTCHA value: ${captcha_value}

Click Login Button
    Wait Until Element Is Visible    ${LOC_LOGIN_BUTTON}    timeout=10s
    Click Element    ${LOC_LOGIN_BUTTON}

# ---- Full login flow (valid: fetch CAPTCHA from DB) ----
Login To Application
    [Documentation]    Flow: (1) Wait 15s for page load + verify all elements visible. (2) Enter user/pass. (3) Wait 10s for CAPTCHA to appear + confirm image visible. (4) Fetch CAPTCHA from DB (now it's the latest). (5) Enter CAPTCHA. (6) Click Login.
    Wait For Login Page To Reload
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Wait For Captcha To Appear
    Connect To CAPTCHA Database
    ${captcha_value}=    Fetch CAPTCHA From Database
    Log    Fetched CAPTCHA from DB: ${captcha_value}
    Disconnect From CAPTCHA Database
    Enter Captcha    ${captcha_value}
    Click Login Button

# ---- Login with given credentials + DB CAPTCHA (for negative credential tests) ----
Login With Credentials And DB Captcha
    [Arguments]    ${username}    ${password}
    [Documentation]    Wait 15s + verify all elements visible, enter user/pass, wait 10s for CAPTCHA image, fetch CAPTCHA from DB, enter it, click Login.
    Wait For Login Page To Reload
    Enter Username    ${username}
    Enter Password    ${password}
    Wait For Captcha To Appear
    Connect To CAPTCHA Database
    ${captcha_value}=    Fetch CAPTCHA From Database
    Log    Fetched CAPTCHA from DB: ${captcha_value}
    Disconnect From CAPTCHA Database
    Enter Captcha    ${captcha_value}
    Click Login Button

# ---- Login with given credentials + explicit CAPTCHA value (for wrong/empty CAPTCHA tests) ----
Login With Credentials And Captcha
    [Arguments]    ${username}    ${password}    ${captcha_value}
    [Documentation]    Wait 15s + verify all elements visible, enter user/pass, wait 10s for CAPTCHA image, enter given CAPTCHA value, click Login.
    Wait For Login Page To Reload
    Enter Username    ${username}
    Enter Password    ${password}
    Wait For Captcha To Appear
    Enter Captcha    ${captcha_value}
    Click Login Button

# ---- Assertions ----
Verify Login Success
    [Documentation]    After login: wait 15s for Manage Devices page, then verify gridData is visible.
    Sleep    15s
    Wait Until Element Is Visible    ${LOC_MANAGEDEVICES_GRID}    timeout=30s
    Element Should Be Visible    ${LOC_MANAGEDEVICES_GRID}

Verify Login Success And Manage Devices
    [Documentation]    After login + navigate to ManageDevices, ensure grid and URL.
    Wait Until Element Is Not Visible    ${LOC_LOGIN_ERROR}    timeout=15s
    Wait Until Location Contains    ManageDevices    timeout=20s
    Element Should Be Visible    ${LOC_MANAGEDEVICES_GRID}

Current URL Should Not Be Login Page
    ${url}=    Get Location
    Should Not Be Equal As Strings    ${url}    ${LOGIN_URL}

Verify Login Error Visible
    [Documentation]    Error message div is displayed.
    Wait Until Element Is Visible    ${LOC_LOGIN_ERROR}    timeout=10s

Verify Login Page Visible
    [Documentation]    Login form is present (root, username field).
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}    timeout=15s
    Element Should Be Visible    ${LOC_LOGIN_USERNAME}

# ---- Manage Devices ----
Navigate To Manage Devices
    Go To    ${TARGET_URL}

Verify Manage Devices Page Loaded
    Wait Until Element Is Visible    ${LOC_MANAGEDEVICES_GRID}    timeout=20s
    ${url}=    Get Location
    Should Contain    ${url}    /ManageDevices
    Element Should Be Visible    ${LOC_MANAGEDEVICES_ACTION_FORM}

# ---- Direct URL access (unauthenticated) ----
Navigate To Manage Devices Without Login
    [Documentation]    Go to ManageDevices without logging in; expect redirect to login.
    Go To    ${TARGET_URL}
