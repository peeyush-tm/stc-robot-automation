*** Settings ***
Library     SeleniumLibrary
Library     String
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/product_type_variables.py
Variables   ../variables/sim_order_variables.py
Variables   ../variables/device_state_variables.py
Variables   ../variables/ip_pool_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/product_type_keywords.resource
Resource    ../resources/keywords/sim_order_keywords.resource
Resource    ../resources/keywords/device_state_keywords.resource
Resource    ../resources/keywords/ip_pool_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/product_type_locators.resource
Resource    ../resources/locators/sim_order_locators.resource
Resource    ../resources/locators/device_state_locators.resource
Resource    ../resources/locators/ip_pool_locators.resource

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}
...               AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  SETUP / PREREQUISITE FEATURE TESTS (Rows 7-10)
# ═══════════════════════════════════════════════════════════════════════

TC_SETUP_001 Verify Create SIM Product Type And Assign To Customer
    [Documentation]    PRE: Access of Admin Module.
    ...                STEPS: 1) Click on SIM Product Type
    ...                        2) Create SIM Product Type
    ...                        3) Assign SIM Product Type
    ...                EXPECTED: 1) Click on SIM Product Type succeeds.
    ...                          2) SIM Product created successfully.
    ...                          3) SIM Product Type assigned successfully.
    [Tags]    feature    regression    setup    TC_SETUP_001
    Navigate To Product Type Module
    Open Create Product Type Form
    Fill All Mandatory Fields With Defaults
    Click Submit Product Type
    Verify Product Type Created Successfully
    Click Assign Customer Icon On First Row
    Select First Enterprise Customer
    Click Update EC Assignment
    Verify EC Assignment Successful

TC_SETUP_002 Verify SIM Order Created Successfully
    [Documentation]    PRE: Access of SIM Order page.
    ...                STEPS: 1) Create SIM Order.
    ...                EXPECTED: SIM Order created successfully.
    [Tags]    feature    regression    setup    TC_SETUP_002
    Navigate To Live Order Via Sidebar
    Click Create SIM Order Button
    Complete Create SIM Order Flow
    Verify Order Created Successfully

TC_SETUP_003 Verify SIM State Changed From Warm To Inactive
    [Documentation]    PRE: Change SIM state from Warm to Test-Ready preceding step.
    ...                STEPS: 1) Change state to Inactive.
    ...                EXPECTED: SIM state changed successfully.
    [Tags]    feature    regression    setup    TC_SETUP_003
    Navigate To Manage Devices
    Perform Full State Change    Warm    Warm    InActive
    Verify State Change Success And Wait

TC_SETUP_004 Verify IP Pool Creation (Static APN Pre-Requisite)
    [Documentation]    PRE: Static APN should be created.
    ...                STEPS: 1) Create IP Pool.
    ...                EXPECTED: IP Pool created successfully.
    [Tags]    feature    regression    setup    TC_SETUP_004
    Navigate To IP Pooling Via Service
    Click Create IP Pool Button
    Fill IP Pool Form
    Click Create And Wait For IP Details
    Submit IP Pool
    Verify IP Pool Created Successfully
