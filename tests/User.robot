*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/user_keywords.resource
Resource    ../resources/locators/user_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/user_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_USER_PLACEHOLDER  User test placeholder
    Log    Add user tests from users module MD
