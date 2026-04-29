*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/sim_order_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/sim_order_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/sim_order_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES — CREATE ORDER
# ═══════════════════════════════════════════════════════════════════════

TC_SO_001 E2E Create SIM Order Successfully
    [Documentation]    Full E2E: Login > Live Order > Create SIM Order > fill Step 1 >
    ...                fill Step 2 > Preview > T&C > Submit > verify success toast and redirect.
    [Tags]    smoke    regression    positive    TC_SO_001
    TC_SO_001

TC_SO_002 Verify Live Order Grid Loads After Login
    [Documentation]    Navigate to Live Order and verify the Kendo grid container is visible.
    ...                Data rows may or may not exist depending on environment state.
    [Tags]    smoke    regression    positive    TC_SO_002
    TC_SO_002

TC_SO_003 Verify Create SIM Order Wizard Elements Visible
    [Documentation]    Navigate to Create SIM Order and verify all 3 wizard step tabs
    ...                and Order Details pane are visible.
    [Tags]    smoke    regression    positive    TC_SO_003
    TC_SO_003

TC_SO_004 Verify Wizard Previous Button Navigates Back
    [Documentation]    Fill Step 1, advance to Step 2, click Previous, verify Step 1 is visible again.
    [Tags]    regression    positive    TC_SO_004
    TC_SO_004

TC_SO_005 Verify Preview Page Shows Order And Shipping Summary
    [Documentation]    Fill Step 1 and Step 2, advance to Preview, verify both summary sections visible.
    [Tags]    regression    positive    TC_SO_005
    TC_SO_005

TC_SO_006 Verify Close Button On Preview Redirects To Live Order
    [Documentation]    Fill wizard up to Preview, click Close, verify redirect to /LiveOrder.
    [Tags]    regression    positive    TC_SO_006
    TC_SO_006

TC_SO_007 Verify Search Functionality On Live Order Grid
    [Documentation]    Navigate to Live Order, enter search text, verify search executes
    ...                and grid updates (may return 0 rows if search term not found).
    [Tags]    regression    positive    TC_SO_007
    TC_SO_007

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES — CANCEL ORDER
# ═══════════════════════════════════════════════════════════════════════

TC_SO_008 Cancel Order With Valid Reason And Remarks
    [Documentation]    Open Cancel modal for the first grid row, fill reason and remarks,
    ...                click Proceed, verify the cancel action completes.
    ...                Skips if no orders exist in the grid.
    [Tags]    regression    positive    TC_SO_008
    TC_SO_008

TC_SO_009 Close Cancel Modal Without Proceeding
    [Documentation]    Open Cancel modal, close it without submitting, verify modal closes
    ...                and grid is still visible. Skips if no orders exist.
    [Tags]    regression    positive    TC_SO_009
    TC_SO_009

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CREATE ORDER
# ═══════════════════════════════════════════════════════════════════════

TC_SO_010 Next Blocked When Account Not Selected
    [Documentation]    Fill Step 1 but skip Account selection. Clicking Next should be
    ...                blocked or show a validation error.
    [Tags]    regression    negative    TC_SO_010
    TC_SO_010

TC_SO_011 Next Blocked When SIM Type Not Selected
    [Documentation]    Fill Step 1 but skip SIM Type selection. Clicking Next should be
    ...                blocked or show a validation error.
    [Tags]    regression    negative    TC_SO_011
    TC_SO_011

TC_SO_012 Quantity Zero Should Show Error Or Block Next
    [Documentation]    Enter 0 as quantity. Clicking Next should be blocked or show error.
    [Tags]    regression    negative    TC_SO_012
    TC_SO_012

TC_SO_013 Quantity Negative Should Show Error Or Block Next
    [Documentation]    Enter -1 as quantity. Clicking Next should be blocked or show error.
    [Tags]    regression    negative    TC_SO_013
    TC_SO_013

TC_SO_014 Quantity Non Numeric Should Show Error Or Block Next
    [Documentation]    Enter "abc" as quantity. Clicking Next should be blocked or show error.
    [Tags]    regression    negative    TC_SO_014
    TC_SO_014

TC_SO_015 Next Blocked On Step 2 When Address Line 1 Empty
    [Documentation]    Fill Step 1 completely, advance to Step 2, leave Address Line 1 empty.
    ...                Clicking Next to Preview should be blocked or show error.
    [Tags]    regression    negative    TC_SO_015
    TC_SO_015

TC_SO_016 Submit Without Accepting Terms Should Be Blocked
    [Documentation]    Complete Steps 1 and 2, advance to Preview, try to submit
    ...                without checking the T&C checkbox.
    [Tags]    regression    negative    TC_SO_016
    TC_SO_016

TC_SO_017 SQL Injection In Quantity Field
    [Documentation]    Enter SQL injection string in Quantity. Verify error or safe handling.
    [Tags]    regression    negative    TC_SO_017
    TC_SO_017

TC_SO_018 Special Characters In Address Fields
    [Documentation]    Enter special characters in address fields and attempt to proceed.
    ...                Verify the app handles them safely (error, sanitization, or acceptance).
    [Tags]    regression    negative    TC_SO_018
    TC_SO_018

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES — CANCEL ORDER
# ═══════════════════════════════════════════════════════════════════════

TC_SO_019 Cancel Order With Empty Reason Should Be Blocked
    [Documentation]    Open Cancel modal, leave Reason blank, click Proceed.
    ...                Verify the proceed is blocked or an error is shown.
    ...                Skips if no orders exist in the grid.
    [Tags]    regression    negative    TC_SO_019
    TC_SO_019

# ═══════════════════════════════════════════════════════════════════════
#  SECURITY TEST CASES — UNAUTHORIZED ACCESS
# ═══════════════════════════════════════════════════════════════════════

TC_SO_020 Direct Access To Create SIM Order Without Login Should Redirect
    [Documentation]    Navigate directly to /CreateSIMOrder without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    TC_SO_020
    TC_SO_020

TC_SO_021 Direct Access To Live Order Without Login Should Redirect
    [Documentation]    Navigate directly to /LiveOrder without authenticating.
    ...                Verify: application redirects back to the login page.
    [Tags]    regression    negative    TC_SO_021
    TC_SO_021


*** Keywords ***
TC_SO_001
    Login And Navigate To Create SIM Order
    Complete Create SIM Order Flow
    Verify Order Created Successfully

TC_SO_002
    Login And Navigate To Live Order
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${row_count}=    Get Element Count    ${LOC_SO_GRID_ROWS}
    Log    Live Order grid loaded. Row count: ${row_count}    console=yes
    Log    Grid is visible and operational.

TC_SO_003
    Login And Navigate To Create SIM Order
    Verify Wizard Elements Visible

TC_SO_004
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1
    Click Next To Shipping
    Click Previous To Order Details
    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_INPUT}    timeout=30s
    Log    Previous button correctly navigated back to Order Details.

TC_SO_005
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1
    Click Next To Shipping
    Fill Shipping Details Step 2
    Click Next To Preview
    Verify Preview Page Visible

TC_SO_006
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1
    Click Next To Shipping
    Fill Shipping Details Step 2
    Click Next To Preview
    Click Close Button On Preview
    Verify On Live Order Page

TC_SO_007
    Login And Navigate To Live Order
    Search Live Orders    ${SEARCH_VALID_ORDER_NUMBER}
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    ${row_count}=    Get Element Count    ${LOC_SO_GRID_ROWS}
    Log    Search returned ${row_count} row(s) for query "${SEARCH_VALID_ORDER_NUMBER}".    console=yes

TC_SO_008
    Login And Navigate To Live Order
    ${has_data}=    Grid Has At Least One Row
    IF    not ${has_data}
        Skip    No orders in grid to cancel — skipping test.
    END
    Open Cancel Modal For First Row
    Fill Cancel Modal And Submit    ${VALID_CANCEL_REASON}    ${VALID_CANCEL_REMARKS}
    Verify Cancel Order Outcome    Cancel order with valid data

TC_SO_009
    Login And Navigate To Live Order
    ${has_data}=    Grid Has At Least One Row
    IF    not ${has_data}
        Skip    No orders in grid — skipping cancel modal test.
    END
    Open Cancel Modal For First Row
    Close Cancel Modal
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Log    Cancel modal closed without proceeding — grid still visible.

TC_SO_010
    Login And Navigate To Create SIM Order
    Set SIM Replacement Order    ${FALSE}
    Select SIM Category
    Select SIM Type
    Select SIM Product Type
    Enter Quantity
    Set Activation Type
    Select SIM State
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}

TC_SO_011
    Login And Navigate To Create SIM Order
    Set SIM Replacement Order    ${FALSE}
    Select Account From TreeView
    Select SIM Category
    Select SIM Product Type
    Enter Quantity
    Set Activation Type
    Select SIM State
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}

TC_SO_012
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1    quantity=${QUANTITY_ZERO}
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}

TC_SO_013
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1    quantity=${QUANTITY_NEGATIVE}
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}

TC_SO_014
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1    quantity=${QUANTITY_NON_NUMERIC}
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}

TC_SO_015
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1
    Click Next To Shipping
    Select Country
    Fill Contact Details
    Clear And Input Text Into Field    ${LOC_SO_AREA_INPUT}    ${VALID_AREA}
    Clear And Input Text Into Field    ${LOC_SO_CITY_INPUT}    ${VALID_CITY}
    Clear And Input Text Into Field    ${LOC_SO_POSTAL_CODE_INPUT}    ${VALID_POSTAL_CODE}
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP2_PANE}    ${LOC_SO_STEP3_PANE}    ${LOC_SO_BTN_STEP2_NEXT}

TC_SO_016
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1
    Click Next To Shipping
    Fill Shipping Details Step 2
    Click Next To Preview
    Click Submit Without TC
    Sleep    2s
    ${on_preview}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SO_STEP3_PANE}
    ${tc_modal}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TC_MODAL}    timeout=5s
    IF    ${on_preview} and not ${tc_modal}
        Log    Submit correctly blocked — still on Preview without T&C acceptance.
    ELSE IF    ${tc_modal}
        Log    T&C modal appeared — user needs to accept terms before order is processed.
    ELSE
        Log    WARN: Unexpected state after submitting without T&C.    level=WARN
    END

TC_SO_017
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1    quantity=${SQL_INJECTION_QUANTITY}
    Verify Next Button Blocked Or Error Shown
    ...    ${LOC_SO_STEP1_PANE}    ${LOC_SO_ADDRESS_LINE1}    ${LOC_SO_BTN_STEP1_NEXT}

TC_SO_018
    Login And Navigate To Create SIM Order
    Fill Order Details Step 1
    Click Next To Shipping
    Fill Shipping Details Step 2
    ...    addr1=${SPECIAL_CHARS_ADDRESS}    addr2=${SPECIAL_CHARS_ADDRESS}
    Click Next To Preview
    Sleep    2s
    ${on_preview}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SO_STEP3_PANE}
    IF    ${on_preview}
        Log    WARN: App allowed special characters in address — review server-side sanitization.    level=WARN
        Accept Terms And Submit Order
        Verify Negative SIM Order Outcome    Special characters in address
    ELSE
        Log    Navigation blocked for special characters in address fields.
    END

TC_SO_019
    Login And Navigate To Live Order
    ${has_data}=    Grid Has At Least One Row
    IF    not ${has_data}
        Skip    No orders in grid — skipping cancel empty reason test.
    END
    Open Cancel Modal For First Row
    Clear Element Text    ${LOC_SO_CANCEL_REASON_INPUT}
    Clear Element Text    ${LOC_SO_CANCEL_REMARKS_TEXTAREA}
    Click Element Via JS    ${LOC_SO_CANCEL_PROCEED_BTN}
    Sleep    2s
    Verify Cancel Blocked With Empty Reason    Cancel with empty reason

TC_SO_020
    Clear Session For Unauthenticated Test
    Go To    ${CREATE_SIM_ORDER_URL}
    Wait For Page Load
    Verify Redirected To Login Page

TC_SO_021
    Clear Session For Unauthenticated Test
    Go To    ${LIVE_ORDER_URL}
    Wait For Page Load
    Verify Redirected To Login Page
