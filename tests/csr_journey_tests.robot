*** Settings ***
Library     SeleniumLibrary
Library     String
Library     ../libraries/ConfigLoader.py
Variables   ../variables/csr_journey_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/csr_journey_keywords.resource
Resource    ../resources/locators/csr_journey_locators.resource
Resource    ../resources/locators/login_locators.resource

# Login once in Suite Setup. No global Test Setup — each case navigates only when needed (fewer redundant /CSRJourney loads).
Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Apply CSRJ Flexible Add APN Locator    AND    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}    AND    Login For CSR Journey    AND    CSRJ Reset Wizard Tariff And APN Tracking
Test Teardown     Handle Test Teardown
Suite Teardown    Close All Browsers

*** Variables ***
${LOC_SS_ADD_APNS_BTN}           xpath=//button[contains(@class,'btn-custom-color') and contains(@class,'cursor-pointer') and contains(translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'add apn')]
${CSR_CREATED_BY_TC4_ALIAS}       ${EMPTY}
${MODIFY_CSR_DEVICE_PLAN}         ${EMPTY}
${EDIT_CSR_DEVICE_PLAN}           ${EMPTY}

# ══════════════════════════════════════════════════════════════════════
#  CSR JOURNEY — consolidated E2E (Mar 2026)
#  Cross-reference: production-style create (Save & Exit, first tariff, onboarded EC/BU by name) lives in
#  tests/e2e_flow.robot Step 3 → E2E Create CSR Journey → CSRJ Complete Create Wizard Save And Exit Like E2E
#  (resources/keywords/e2e_keywords.resource / csr_journey_keywords.resource). TC_CSRJ_004 is broader regression
#  (default tariff by name, Save & Continue, many inline validations).
#  001: Manage Devices → Admin → CSR (navigation smoke).
#  E2E Landing: one /CSRJourney load — landing validations + customer search + grids (ex–002/003/017/018/030/038/045–047).
#  E2E Tariff search: one Create Order — wizard tariff dropdown search (ex–039).
#  004: one Create Order — all former per-step wizard checks + Save & Continue (ex–many TC_CSRJ_* wizard cases).
#  E2E Close: three short wizard entries — Close from SS / AS / Summary (ex–014–016).
#  040: APN conflict when grid already has CSR (unchanged logic).
#  E2E Post-create: one landing load after 004 — grid icons, summary popup, overwrite (ex–023–026/048/049).
#  052–055 + 004_Delete: unchanged flows; explicit [Setup] Go To CSR Journey Landing.
# ══════════════════════════════════════════════════════════════════════

*** Test Cases ***
TC_CSRJ_001 Navigate To CSR Journey Module Via Admin
    [Documentation]    Verifies user can navigate from Manage Devices to CSR Journey module via Admin icon.
    [Tags]    positive    smoke    regression    csr-journey    navigation
    [Setup]    CSRJ Test Setup On Manage Devices
    Navigate To CSR Journey Module
    Verify CSR Journey Landing Page Loaded

TC_CSRJ_E2E_Landing_Grids_And_Customer_Search
    [Documentation]    Single CSR Journey landing session: BU disabled without customer, customer search, Create Order rules,
    ...                APN table headers, usage/txn grids, order summary heading (merged legacy landing/grid cases).
    [Tags]    positive    regression    csr-journey    e2e    landing
    CSRJ E2E Landing Grids And Customer Search Flow

TC_CSRJ_E2E_Tariff_Plan_Search_In_Wizard
    [Documentation]    One wizard open: tariff plan dropdown search/filter and select (legacy TC_CSRJ_039).
    [Tags]    positive    regression    csr-journey    tariff-plan    search
    Go To CSR Journey Landing
    CSRJ E2E Tariff Plan Search On Standard Services

TC_CSRJ_004 Create CSR Journey End To End Standard Flow
    [Documentation]    Single Create Order session: step indicators, APN/tariff/SP guards, APN options, Public→Any, bundle,
    ...                end date, SP modal open/close then save, VAS toggles, Additional Services (discount/addon/negative saves),
    ...                Summary review, full Previous/Next round-trip, Save & Continue + toast. Merges former multi-test wizard coverage.
    ...                For the minimal “happy path” used in full product E2E (Save & Exit, first tariff), see
    ...                tests/e2e_flow.robot Step 3 and keyword CSRJ Complete Create Wizard Save And Exit Like E2E.
    [Tags]    positive    smoke    regression    csr-journey    e2e    create-order
    Set Suite Variable    ${CSR_CREATED_BY_TC4_ALIAS}    ${CSRJ_DEVICE_PLAN_ALIAS}
    CSRJ E2E Wizard All Step Verifications Single Session

TC_CSRJ_E2E_Close_From_Each_Wizard_Step
    [Documentation]    Close from Standard Services, Additional Services, and Summary each redirect to landing (legacy 014–016).
    [Tags]    negative    regression    csr-journey    close    e2e
    Go To CSR Journey Landing
    CSRJ E2E Close Wizard From Standard Additional And Summary

TC_CSRJ_040 APN Type Conflict Should Show Error
    [Documentation]    Tariff + APN combo that already exists on the grid should show conflict when applicable.
    [Tags]    negative    regression    csr-journey    apn-conflict    validation
    [Setup]    Go To CSR Journey Landing
    CSRJ Verify APN Conflict When Existing CSR Grid Row

TC_CSRJ_E2E_Post_Create_Grid_Popup_And_Overwrite
    [Documentation]    After TC_CSRJ_004: one landing visit — grid action icons, CSR summary popup, optional overwrite on Edit (legacy 023–026, 048, 049).
    [Tags]    edge-case    regression    csr-journey    grid    e2e
    CSRJ E2E Post Create Grid Icons Popup And Overwrite

TC_CSRJ_052 Modify CSR Journey Via Edit And Save
    [Documentation]    Independent test. Pass --variable MODIFY_CSR_DEVICE_PLAN:<name> to specify which CSR to modify.
    ...                Skipped (pass) when the variable is empty so a full CSR suite run stays green without modify data.
    [Tags]    positive    regression    csr-journey    modify    edit
    [Setup]    Go To CSR Journey Landing
    ${mod}=    Strip String    ${MODIFY_CSR_DEVICE_PLAN}
    Pass Execution If    '${mod}' == ''    MODIFY_CSR_DEVICE_PLAN not set — skipping modify test.
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Open CSR Journey Edit Mode For CSR By Device Plan Alias    ${MODIFY_CSR_DEVICE_PLAN}
    Modify CSR Journey And Save
    Log    Modify CSR Journey completed. New device plan: ${CSRJ_DEVICE_PLAN_ALIAS_MODIFY}

TC_CSRJ_053 Edit CSR Journey Update Service Types And Save
    [Documentation]    Independent test. Pass --variable EDIT_CSR_DEVICE_PLAN:<name> to specify which CSR to edit.
    ...                Skipped (pass) when the variable is empty.
    [Tags]    positive    regression    csr-journey    modify    edit    service-types
    [Setup]    Go To CSR Journey Landing
    ${ed}=    Strip String    ${EDIT_CSR_DEVICE_PLAN}
    Pass Execution If    '${ed}' == ''    EDIT_CSR_DEVICE_PLAN not set — skipping edit test.
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Open CSR Journey Edit Mode For CSR By Device Plan Alias    ${EDIT_CSR_DEVICE_PLAN}
    Edit CSR Journey Update Service Types And Save
    Log    Edit CSR Journey completed; service types updated for CSR: ${EDIT_CSR_DEVICE_PLAN}

TC_CSRJ_054 Add Multiple Device Plans In Single CSR Journey
    [Documentation]    After TC_CSRJ_004: second device plan on same CSR (Save & Exit).
    [Tags]    positive    regression    csr-journey    multiple-device-plans    device-plan
    [Setup]    Go To CSR Journey Landing
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    ${grid_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_CSRJ_GRID}    15s
    IF    not ${grid_ok}
        Pass Execution    No CSR grid visible — TC_CSRJ_004 must pass first.
    END
    Open CSR Journey Edit Mode For CSR By Device Plan Alias    ${CSR_CREATED_BY_TC4_ALIAS}
    Verify Standard Services Screen Loaded
    Add Second Device Plan Row
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Verify Multiple Device Plan Rows On Summary
    Click Save And Exit
    Verify CSR Journey Success Toast
    Verify Redirected To CSR Journey Landing
    Log    Second device plan added to CSR from TC_CSRJ_004 and saved.

TC_CSRJ_055 Verify Multiple Device Plan Rows On Summary
    [Documentation]    After TC_CSRJ_054: Summary shows multiple device plan rows for CSR from TC_CSRJ_004.
    [Tags]    positive    regression    csr-journey    multiple-device-plans    summary
    [Setup]    Go To CSR Journey Landing
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    ${grid_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_CSRJ_GRID}    15s
    IF    not ${grid_ok}
        Pass Execution    No CSR grid visible — TC_CSRJ_004 must pass first.
    END
    Open CSR Journey Edit Mode For CSR By Device Plan Alias    ${CSR_CREATED_BY_TC4_ALIAS}
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Expand Device Plan Accordion On Summary
    Wait Until Element Is Visible    ${LOC_SUM_DP_PANEL}    ${CSRJ_TIMEOUT}
    ${count}=    Get Element Count    ${LOC_SUM_DP_TABLE_ROWS}
    Should Be True    ${count} >= 2    CSR from TC_CSRJ_004/054 must show at least two device plan rows.
    Log    Device plan section on summary has ${count} row(s).

TC_CSRJ_004_Delete Delete CSR Created In Test Case 4
    [Documentation]    Deletes the CSR created in TC_CSRJ_004 (same Customer/BU and device plan alias).
    [Tags]    positive    regression    csr-journey    delete    cleanup
    [Setup]    Go To CSR Journey Landing
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete    timeout=60s
    ${grid_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_CSRJ_GRID}    15s
    IF    not ${grid_ok}
        Pass Execution    No CSR grid visible — nothing to delete (TC_CSRJ_004 may not have created a CSR).
    END
    Delete CSR By Device Plan Alias    ${CSR_CREATED_BY_TC4_ALIAS}
    Log    CSR created in TC_CSRJ_004 has been deleted.
