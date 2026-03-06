*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/locators/login_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_001 Valid Credentials Should Login Successfully
    [Documentation]    Enter valid username and password, fetch captcha from DB and enter it,
    ...                click Login. Verify: error message absent, post-login landmark visible.
    [Tags]    smoke    regression    positive    login
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success

TC_LOGIN_002 Logout Should Redirect To Login Page
    [Documentation]    Login with valid credentials, then logout.
    ...                Verify: login page elements (username, password, login button) reappear.
    [Tags]    smoke    regression    positive    login
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Perform Logout
    Verify Logout Success

TC_LOGIN_003 Navigate To Manage Devices After Login
    [Documentation]    Login successfully, then navigate to /ManageDevices.
    ...                Verify: URL contains /ManageDevices, grid data container is visible.
    [Tags]    smoke    regression    positive    login    navigation
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Navigate To Manage Devices
    Verify Manage Devices Page Loaded

TC_LOGIN_004 Verify Manage Devices Page Elements
    [Documentation]    Login and navigate to Manage Devices.
    ...                Verify: gridData, searchinput, actionForm are present; grid has at least one row.
    [Tags]    regression    positive    login    navigation
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Navigate To Manage Devices
    Verify Manage Devices Page Loaded
    Verify Manage Devices Grid Has Data

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CREDENTIALS
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_005 Invalid Username Should Show Error
    [Documentation]    Enter an invalid username with a valid password.
    ...                Verify: error message displayed in div.erre-it.
    [Tags]    regression    negative    login
    Login With Credentials    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_006 Invalid Password Should Show Error
    [Documentation]    Enter the valid username with an invalid password.
    ...                Verify: error message displayed in div.erre-it.
    [Tags]    regression    negative    login
    Login With Credentials    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_007 Both Invalid Username And Password Should Show Error
    [Documentation]    Enter both invalid username and invalid password.
    ...                Verify: error message displayed in div.erre-it.
    [Tags]    regression    negative    login
    Login With Credentials    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_008 Empty Username Field Should Show Error
    [Documentation]    Leave username empty, enter a valid password.
    ...                Verify: validation error or login prevented.
    [Tags]    regression    negative    login
    Login With Credentials    ${EMPTY_STRING}    ${VALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_009 Empty Password Field Should Show Error
    [Documentation]    Enter valid username, leave password empty.
    ...                Verify: validation error or login prevented.
    [Tags]    regression    negative    login
    Login With Credentials    ${VALID_USERNAME}    ${EMPTY_STRING}
    Verify Login Error Displayed

TC_LOGIN_010 All Fields Empty Should Show Error
    [Documentation]    Leave username, password, and captcha fields all empty.
    ...                Verify: login button disabled or validation error displayed.
    [Tags]    regression    negative    login
    Login With Credentials And Empty Captcha    ${EMPTY_STRING}    ${EMPTY_STRING}
    Verify Login Error Displayed

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CAPTCHA
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_011 Empty Captcha Should Show Error
    [Documentation]    Enter valid credentials but leave captcha field empty.
    ...                Verify: validation error for missing captcha.
    [Tags]    regression    negative    login    captcha
    Login With Credentials And Empty Captcha    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_012 Incorrect Captcha Should Show Error
    [Documentation]    Enter valid credentials with a deliberately wrong captcha value.
    ...                Verify: error message indicating incorrect captcha.
    [Tags]    regression    negative    login    captcha
    Login With Credentials And Wrong Captcha    ${VALID_USERNAME}    ${VALID_PASSWORD}    ${INCORRECT_CAPTCHA}
    Verify Login Error Displayed

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — SECURITY / INJECTION
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_013 SQL Injection In Username Should Be Rejected
    [Documentation]    Enter a SQL injection payload as the username.
    ...                Verify: authentication is NOT bypassed; error message displayed.
    [Tags]    regression    negative    security    login
    Login With Credentials    ${SQL_INJECTION_INPUT}    ${VALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_014 Special Characters In Username Should Show Error
    [Documentation]    Enter special characters as the username.
    ...                Verify: error message displayed; no unhandled exception.
    [Tags]    regression    negative    security    login
    Login With Credentials    ${SPECIAL_CHARS_INPUT}    ${VALID_PASSWORD}
    Verify Login Error Displayed

TC_LOGIN_015 Whitespace Only Username Should Show Error
    [Documentation]    Enter whitespace-only input in the username field.
    ...                Verify: treated as invalid; error displayed.
    [Tags]    regression    negative    login
    Login With Credentials    ${WHITESPACE_INPUT}    ${VALID_PASSWORD}
    Verify Login Error Displayed

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_016 Direct Access To ManageDevices Without Login Should Redirect
    [Documentation]    Navigate directly to /ManageDevices without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    login    navigation
    Navigate To Manage Devices
    Verify Redirected To Login Page
