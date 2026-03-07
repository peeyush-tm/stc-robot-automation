*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/taxrule_keywords.resource
Resource    ../resources/locators/taxrule_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/taxrule_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_TRL_PLACEHOLDER  Tax rule test placeholder
    Log    Add tax rule tests from taxrule module MD
