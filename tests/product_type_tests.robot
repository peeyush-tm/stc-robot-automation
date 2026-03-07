*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/product_type_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/product_type_locators.resource
Variables   ../config/env_config.py
Variables   ../config/db_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/product_type_variables.py

Suite Setup       Set Selenium Implicit Wait    10
Test Setup        Open Test Browser And Go To Login    ${LOGIN_URL}    ${BROWSER}
Test Teardown     Run Keywords    Run Keyword If Test Failed    Run Keyword And Ignore Error    Capture Page Screenshot    AND    Run Keyword And Ignore Error    Close Test Browser

*** Test Cases ***
# ══════════════════════════════════════════════════════════════════════════════
# WORKFLOW A — Create SIM Product Type (Positive)
# ══════════════════════════════════════════════════════════════════════════════
TC_PT_001 Create SIM Product Type Standard Flow
    [Documentation]    End-to-end: Login → Manage Devices → Admin → Product Type → Create Product Type → fill all fields → Submit → verify success toast and redirect to /ProductType listing.
    [Tags]    smoke    regression    positive    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Verify Sub Type 1 Pre Filled
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Fill Optional Fields    ${PT_PACKAGING_SIZE}    ${PT_COMMENT}    ${PT_DESC_EN}
    Submit Product Type Form
    Validate Product Type Creation

# ══════════════════════════════════════════════════════════════════════════════
# WORKFLOW B — Assign EC to Product Type (Positive)
# ══════════════════════════════════════════════════════════════════════════════
TC_PT_002 Assign EC To Existing Product Type
    [Documentation]    Login → Manage Devices → Admin → Product Type listing → click Assign-Customer icon on first row → select first EC from multi-select → Update → verify success toast and popup closed.
    [Tags]    smoke    regression    positive    product-type    assign-ec
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Click Assign Customer Icon On First Row
    Select Enterprise Customer From Popup
    Submit EC Assignment
    Validate EC Assignment Success

# ══════════════════════════════════════════════════════════════════════════════
# WORKFLOW A — Negative Test Cases
# ══════════════════════════════════════════════════════════════════════════════
TC_PT_003 Submit Without Selecting Account
    [Documentation]    NEG-01: Leave Account at blank, click Submit. Validation should block submission.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_004 Submit With Blank Product Type Name
    [Documentation]    NEG-02: Leave Product Type Name empty, click Submit. Validation error expected.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_005 Submit Without Selecting Service Type
    [Documentation]    NEG-03: Leave Service Type at default blank, click Submit. Validation error expected.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_006 Submit With Blank Service Sub Type 2
    [Documentation]    NEG-04: Leave Service Sub Type 2 empty, click Submit. Validation error expected.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_007 Submit With Blank Service Sub Type 3
    [Documentation]    NEG-05: Leave Service Sub Type 3 empty, click Submit. Validation error expected.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_008 Submit With Blank Service Sub Type 4
    [Documentation]    NEG-06: Leave Service Sub Type 4 empty, click Submit. Validation error expected.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_009 Submit With Esim Sub Type 3 But Blank Profile Name
    [Documentation]    NEG-07: Enter 'esim' in Sub Type 3 but leave Profile Name empty. Validation error expected.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    esim
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Without Waiting For Success
    Verify Still On Create Form

TC_PT_010 Close Create Form Without Submitting
    [Documentation]    NEG-11: Fill fields then click Close. Should redirect to /ProductType without creating a record.
    [Tags]    regression    negative    product-type    create-product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Close Button On Create Form
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ProductType
    ${url}=    Get Location
    Should Not Contain    ${url}    CreateProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    30s

TC_PT_011 Verify Create Button Visible For RW User
    [Documentation]    Positive check: RW user (ksa_opco) can see the Create Product Type button on the listing page.
    [Tags]    regression    positive    product-type
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Wait Until Element Is Visible    ${LOC_CREATE_PT_BTN}    30s

# ══════════════════════════════════════════════════════════════════════════════
# WORKFLOW B — Negative Test Cases
# ══════════════════════════════════════════════════════════════════════════════
TC_PT_012 Click Update Without Selecting Any EC
    [Documentation]    NEG-15: Open Assign popup, click Update without selecting any EC. Error toast expected.
    [Tags]    regression    negative    product-type    assign-ec
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Click Assign Customer Icon On First Row
    Click Update Without Selecting EC
    Verify Error Toast Visible

TC_PT_013 Close Assign Popup Without Assigning
    [Documentation]    NEG-19: Open Assign popup, click Close without assigning. Popup dismisses; no changes made.
    [Tags]    regression    negative    product-type    assign-ec
    Login To Application
    Verify Login Success
    Navigate To Product Type Module
    Click Assign Customer Icon On First Row
    Close Assign Customer Popup
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    30s
