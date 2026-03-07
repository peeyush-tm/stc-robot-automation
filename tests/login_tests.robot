*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/locators/login_locators.resource
Variables   ../config/env_config.py
Variables   ../config/db_config.py
Variables   ../variables/login_variables.py

Suite Setup       Set Selenium Implicit Wait    10
Test Setup        Open Test Browser And Go To Login    ${LOGIN_URL}    ${BROWSER}
Test Teardown     Run Keywords    Run Keyword If Test Failed    Run Keyword And Ignore Error    Capture Page Screenshot    AND    Run Keyword And Ignore Error    Close Test Browser

*** Test Cases ***
TC_LOGIN_001 Valid Credentials Should Login Successfully
    [Documentation]    Login with valid credentials and DB CAPTCHA; after login wait 15s for Manage Devices grid to appear and verify it is visible.
    [Tags]    smoke    regression    positive    login
    Login To Application
    Verify Login Success
