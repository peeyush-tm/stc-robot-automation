*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/refund_keywords.resource
Resource    ../resources/locators/refund_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/refund_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_RF_PLACEHOLDER  Refund test placeholder
    Log    Add refund tests from refund module MD
