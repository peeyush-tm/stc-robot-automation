*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/product_keywords.resource
Resource    ../resources/locators/product_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/product_variables.py

Suite Setup       Open Test Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close Test Browser
Test Setup        Navigate To URL      ${BASE_URL}

*** Test Cases ***
TC_PRODUCT_PLACEHOLDER  Product test placeholder
    Log    Add product tests from products module MD
