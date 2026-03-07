*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/taxrate_keywords.resource
Resource    ../resources/locators/taxrate_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/taxrate_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_TR_PLACEHOLDER  Tax rate test placeholder
    Log    Add tax rate tests from taxrate module MD
