*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/plan_keywords.resource
Resource    ../resources/locators/plan_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/plan_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_PLAN_PLACEHOLDER  Plan test placeholder
    Log    Add plan tests from plans module MD
