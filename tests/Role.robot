*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/role_keywords.resource
Resource    ../resources/locators/role_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/role_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_ROLE_PLACEHOLDER  Role test placeholder
    Log    Add role tests from roles module MD
