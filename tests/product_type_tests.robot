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

Suite Setup       Load Environment Config From Json    ${ENV}
Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser


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
    Login And Navigate To Product Type
    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_SEARCH_FIELD}    Test
    Click Element Safely             ${LOC_PT_SEARCH_BTN}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}       ${PT_TIMEOUT}
    Click Element Safely             ${LOC_PT_SEARCH_CLOSE}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}       ${PT_TIMEOUT}
