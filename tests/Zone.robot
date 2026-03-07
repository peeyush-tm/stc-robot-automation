*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/zone_keywords.resource
Resource    ../resources/locators/zone_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/zone_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_ZONE_PLACEHOLDER  Zone test placeholder
    Log    Add zone tests from zone module MD
