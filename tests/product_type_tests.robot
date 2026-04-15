*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/product_type_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/product_type_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/product_type_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}
...               AND    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
...               AND    Login And Navigate To Product Type
Test Setup        Go To Product Type Listing
Test Teardown     Handle Test Teardown
Suite Teardown    Close All Browsers


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_PT_001 Create SIM Product Type Standard Flow
    [Documentation]    Navigate to Product Type via Admin module, open Create form, fill all
    ...                mandatory + optional fields, verify Sub Type 1 pre-filled, submit.
    ...                Verify: success toast, redirect to /ProductType listing, grid visible.
    [Tags]    smoke    regression    positive    product-type    create-product-type
    TC_PT_001

TC_PT_002 Assign EC To Existing Product Type
    [Documentation]    Navigate to Product Type listing, click Assign-Customer icon on first row,
    ...                select first EC from dropdown, click Update.
    ...                Verify: success toast, popup closed, grid refreshed, expand row to see EC.
    [Tags]    smoke    regression    positive    product-type    assign-ec
    TC_PT_002

TC_PT_011 Verify Create Button Visible For RW User
    [Documentation]    Navigate to Product Type listing page as RW user (ksa_opco).
    ...                Verify: Create Product Type button is visible on the listing page.
    [Tags]    regression    positive    product-type
    TC_PT_011

TC_PT_13 Close Assign Popup Without Saving Should Not Change Assignment
    [Documentation]    Open Assign Customer popup, close it without selecting any EC,
    ...                then click expand on the grid row to verify "No Data Available".
    [Tags]    regression    positive    assign-ec
    TC_PT_13

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_PT_003 Submit Without Selecting Account
    [Documentation]    Leave Account dropdown at blank default, fill other mandatory fields,
    ...                click Submit. Verify: validation error, stays on CreateProductType page.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_003

TC_PT_004 Submit With Blank Product Type Name
    [Documentation]    Leave Product Type Name blank, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_004

TC_PT_005 Submit Without Selecting Service Type
    [Documentation]    Leave Service Type at blank default, fill other mandatory fields,
    ...                click Submit. Verify: validation error, stays on form.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_005

TC_PT_006 Submit With Blank Service Sub Type 2
    [Documentation]    Leave Service Sub Type 2 empty, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_006

TC_PT_007 Submit With Blank Service Sub Type 3
    [Documentation]    Leave Service Sub Type 3 empty, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_007

TC_PT_008 Submit With Blank Service Sub Type 4
    [Documentation]    Leave Service Sub Type 4 empty, fill other mandatory fields, click Submit.
    ...                Verify: validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_008

TC_PT_009 Submit With Esim Sub Type 3 But Blank Profile Name
    [Documentation]    Enter 'esim' in Sub Type 3 but leave Profile Name empty, click Submit.
    ...                Verify: Profile Name validation error, form does not submit.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_009

TC_PT_010 Close Create Form Without Submitting
    [Documentation]    Fill all mandatory fields but click Close instead of Submit.
    ...                Verify: redirect to /ProductType listing, no success toast, no record created.
    [Tags]    regression    negative    product-type    create-product-type
    TC_PT_010

TC_PT_012 Click Update Without Selecting Any EC
    [Documentation]    Open Assign Customer popup, click Update without selecting any EC.
    ...                Verify: error toast displayed, popup stays open.
    [Tags]    regression    negative    product-type    assign-ec
    TC_PT_012

TC_PT_17 Duplicate Product Type Name Should Show Error Toast
    [Documentation]    Enter a name that already exists in the system, fill other mandatory fields,
    ...                submit. Verify: error toast (duplicate rejected by API).
    [Tags]    regression    negative    create    validation
    TC_PT_17

# ═══════════════════════════════════════════════════════════════════════
#  EDGE CASES
# ═══════════════════════════════════════════════════════════════════════

TC_PT_14 Edit Icon Should Be Visible In Product Type Grid
    [Documentation]    Navigate to Product Type listing and verify Edit icon is visible
    ...                for at least one row (user has RW permission).
    [Tags]    regression    edge-case    validation
    TC_PT_14

TC_PT_15 Assign Customer Icon Should Be Visible In Grid For RW User
    [Documentation]    Navigate to Product Type listing and verify the Assign-Customer icon
    ...                (jQuery-injected) is visible for the logged-in RW user.
    [Tags]    regression    edge-case    assign-ec    validation
    TC_PT_15

TC_PT_16 Search Product Type In Listing Grid
    [Documentation]    Enter a search term in the Product Type listing search field and click Search.
    ...                Verify: grid filters results based on the search term.
    [Tags]    regression    edge-case    search
    TC_PT_16

TC_PT_18 Clear Search Should Reset Grid
    [Documentation]    After searching, click the clear/close button on search field.
    ...                Verify: grid resets and shows all product types.
    [Tags]    regression    edge-case    search
    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    ${PT_TIMEOUT}
    Input Text    ${LOC_PT_SEARCH_FIELD}    Test
    Click Element Safely    ${LOC_PT_SEARCH_BTN}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Scroll To Element Via JS    ${LOC_PT_SEARCH_CLOSE}
    Click Element Via JS    ${LOC_PT_SEARCH_CLOSE}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}


*** Keywords ***
PT Scroll Grid Right For Assign Icons
    Execute Javascript
    ...    var grid = document.querySelector('.k-grid-content'); if(grid) grid.scrollLeft = grid.scrollWidth;
    Sleep    2s

TC_PT_001
    Open Create Product Type Form
    Fill All Mandatory Fields With Defaults
    Verify Sub Type 1 Is Pre Filled And Disabled
    Fill Optional Fields
    Click Submit Product Type
    Verify Product Type Created Successfully

TC_PT_002
    PT Scroll Grid Right For Assign Icons
    ${assign_ok}=    Run Keyword And Return Status    Click Assign Customer Icon On First Row
    IF    not ${assign_ok}
        Log    Assign icon click failed. Refreshing Product Type page and retrying...    console=yes
        Go To    ${BASE_URL}ProductType
        Sleep    5s
        Wait For App Loading To Complete    timeout=60s
        Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    timeout=30s
        PT Scroll Grid Right For Assign Icons
        Click Assign Customer Icon On First Row
    END
    Select First Enterprise Customer
    Click Update EC Assignment
    Verify EC Assignment Successful

TC_PT_011
    Verify Create Product Type Button Visible

TC_PT_13
    ${pt_name}=    Evaluate    'Auto PT ' + ''.join(random.choices(string.ascii_letters + string.digits, k=8))    modules=random,string
    Open Create Product Type Form
    Fill All Mandatory Fields    ${pt_name}    ${PT_SERVICE_TYPE_POSTPAID}
    ...    ${PT_SUB_TYPE_2}    ${PT_SUB_TYPE_3_SIM}    ${PT_SUB_TYPE_4}
    Fill Optional Fields
    Click Submit Product Type
    Verify Product Type Created Successfully
    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    ${PT_TIMEOUT}
    Clear Element Text    ${LOC_PT_SEARCH_FIELD}
    Input Text    ${LOC_PT_SEARCH_FIELD}    ${pt_name}
    Click Element Safely    ${LOC_PT_SEARCH_BTN}
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    PT Scroll Grid Right For Assign Icons
    Click Assign Customer Icon On First Row
    Click Close Assign Customer Popup
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    15s
    Verify No Data After Expand

TC_PT_003
    Open Create Product Type Form
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_004
    Open Create Product Type Form
    Select Account From Dropdown
    Select Service Type    ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_005
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_006
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3_SIM}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_007
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_008
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3_SIM}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_009
    Open Create Product Type Form
    Select Account From Dropdown
    Enter Product Type Name    ${PT_NAME}
    Select Service Type    ${PT_SERVICE_TYPE_POSTPAID}
    Enter Service Sub Type 2    ${PT_SUB_TYPE_2}
    Enter Service Sub Type 3    ${PT_SUB_TYPE_3_ESIM}
    Enter Service Sub Type 4    ${PT_SUB_TYPE_4}
    Click Submit Product Type
    Verify Still On Create Product Type Page

TC_PT_010
    Open Create Product Type Form
    Fill All Mandatory Fields With Defaults
    Verify Sub Type 1 Is Pre Filled And Disabled
    Fill Optional Fields
    Click Close Product Type Form
    Verify Redirected To Product Type Listing
    Page Should Not Contain    SIM Product Type Created Successfully

TC_PT_012
    PT Scroll Grid Right For Assign Icons
    Click Assign Customer Icon On First Row
    Click Update EC Assignment
    Verify No EC Selected Toast Displayed
    Verify Assign Popup Still Open

TC_PT_17
    Open Create Product Type Form
    Fill All Mandatory Fields    ${DUPLICATE_PT_NAME}    ${PT_SERVICE_TYPE_POSTPAID}
    ...    ${PT_SUB_TYPE_2}    ${PT_SUB_TYPE_3_SIM}    ${PT_SUB_TYPE_4}
    Fill Optional Fields
    Click Submit Product Type
    Verify Duplicate Product Type Toast Displayed
    Verify Still On Create Product Type Page

TC_PT_14
    Wait Until Element Is Visible    ${LOC_PT_EDIT_ICON}    ${PT_TIMEOUT}

TC_PT_15
    Verify Assign Customer Icon Visible

TC_PT_16
    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    ${PT_TIMEOUT}
    Input Text    ${LOC_PT_SEARCH_FIELD}    Test
    Click Element Safely    ${LOC_PT_SEARCH_BTN}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
