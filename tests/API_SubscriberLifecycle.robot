*** Settings ***
Library     RequestsLibrary
Library     Collections
Library     ../libraries/csv_reader.py
Resource    ../resources/keywords/api_keywords.resource
Variables   ../config/api_config.py

Suite Setup       Delete All Sessions
Suite Teardown    Delete All Sessions

*** Test Cases ***
TC_API_PLACEHOLDER  API test placeholder
    Log    Add API lifecycle tests from API module MD
