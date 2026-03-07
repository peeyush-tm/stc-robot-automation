*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/tc_keywords.resource
Resource    ../resources/locators/tc_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/tc_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_TC_PLACEHOLDER  T&C test placeholder
    Log    Add T&C tests from tc module MD
