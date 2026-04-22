*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/locators/login_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Setup        Prepare Login Page
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_001 Valid Credentials Should Login Successfully
    [Documentation]    Enter valid username and password, fetch captcha from DB and enter it,
    ...                click Login. Verify: error message absent, post-login landmark visible.
    [Tags]    smoke    regression    positive    login
    TC_LOGIN_001

TC_LOGIN_002 Logout Should Redirect To Login Page
    [Documentation]    Login with valid credentials, then logout.
    ...                Verify: login page elements (username, password, login button) reappear.
    [Tags]    smoke    regression    positive    login
    TC_LOGIN_002

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CREDENTIALS
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_005 Invalid Username Should Show Error
    [Documentation]    Enter an invalid username with a valid password.
    ...                Verify: "Authorization Failure" error displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_005

TC_LOGIN_006 Invalid Password Should Show Error
    [Documentation]    Enter the valid username with an invalid password.
    ...                Verify: "Authorization Failure" error displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_006

TC_LOGIN_007 Both Invalid Username And Password Should Show Error
    [Documentation]    Enter both invalid username and invalid password.
    ...                Verify: "Authorization Failure" error displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_007

TC_LOGIN_008 Empty Username Field Should Show Error
    [Documentation]    Leave username empty, enter a valid password.
    ...                Verify: "Username is required" inline field validation displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_008

TC_LOGIN_009 Empty Password Field Should Show Error
    [Documentation]    Enter valid username, leave password empty.
    ...                Verify: "Password Required" field validation displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_009

TC_LOGIN_010 All Fields Empty Should Show Error
    [Documentation]    Leave username, password, and captcha fields all empty.
    ...                Verify: both "Username is required" and "Password Required" displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_010

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CAPTCHA
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_011 Empty Captcha Should Show Error
    [Documentation]    Enter valid credentials but leave captcha field empty.
    ...                Verify: "Please Enter Captcha" toast error displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_011

TC_LOGIN_012 Incorrect Captcha Should Show Error
    [Documentation]    Enter valid credentials with a deliberately wrong captcha value.
    ...                Verify: "Invalid Captcha" error displayed.
    [Tags]    regression    negative    login
    TC_LOGIN_012

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — SECURITY / INJECTION
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_015 Whitespace Only Username Should Show Error
    [Documentation]    Enter whitespace-only input in the username field.
    ...                Verify: error displayed — "Authorization Failure" or "Username is required".
    [Tags]    regression    negative    login
    TC_LOGIN_015

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_LOGIN_016 Direct Access To ManageDevices Without Login Should Redirect
    [Documentation]    Navigate directly to /ManageDevices without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    security    login    navigation
    TC_LOGIN_016

*** Keywords ***
TC_LOGIN_001
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success

TC_LOGIN_002
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Perform Logout
    Verify Logout Success

TC_LOGIN_005
    Login With Credentials    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_006
    Login With Credentials    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_007
    Login With Credentials    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Verify Authorization Failure Error

TC_LOGIN_008
    Login With Credentials    ${EMPTY_STRING}    ${VALID_PASSWORD}
    Verify Username Required Error

TC_LOGIN_009
    Login With Credentials    ${VALID_USERNAME}    ${EMPTY_STRING}
    Verify Password Required Error

TC_LOGIN_010
    Login With Credentials And Empty Captcha    ${EMPTY_STRING}    ${EMPTY_STRING}
    Verify All Fields Empty Error

TC_LOGIN_011
    Login With Credentials And Empty Captcha    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Please Enter Captcha Toast

TC_LOGIN_012
    Login With Credentials And Wrong Captcha    ${VALID_USERNAME}    ${VALID_PASSWORD}    ${INCORRECT_CAPTCHA}
    Verify Invalid Captcha Error

TC_LOGIN_015
    Login With Credentials    ${WHITESPACE_INPUT}    ${VALID_PASSWORD}
    Verify Login Error Displayed
    Verify Still On Login Page

TC_LOGIN_016
    Navigate To Manage Devices
    Verify Redirected To Login Page
