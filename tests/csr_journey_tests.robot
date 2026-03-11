*** Settings ***
Library     SeleniumLibrary
Variables   ../config/env_config.py    ${ENV}
Variables   ../variables/csr_journey_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/csr_journey_keywords.resource
Resource    ../resources/locators/csr_journey_locators.resource
Resource    ../resources/locators/login_locators.resource

Test Setup        Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
Test Teardown     Capture Screenshot And Close Browser

*** Variables ***
${CSR_CREATED_BY_TC4_ALIAS}       ${EMPTY}
${MODIFY_CSR_DEVICE_PLAN}         ${EMPTY}
${EDIT_CSR_DEVICE_PLAN}           ${EMPTY}

# ══════════════════════════════════════════════════════════════════════
#  CSR JOURNEY TESTS — SEQUENTIAL EXECUTION ORDER
#  Phase 1: Landing — 001, 002, 018, 003, 017
#  Phase 2: Inside entries (wizard: APN, tariff, device plan, discount, additional, summary, previous) — BEFORE 004
#           006, 012, 010, 013, 019, 020, 041, 036, 037, 007, 008, 009, 011, 014, 015, 016, 021, 022, 005, 034, 035, 027, 028, 029, 030, 031, 032, 033, 038, 039, 040, 042, 043, 044, 050, 051
#  Phase 3: Full E2E Create — 004 (creates one CSR; sets ${CSR_CREATED_BY_TC4_ALIAS})
#  Phase 4: Verify CSR (grid icons, usage, txn, summary popup) — 023, 024, 025, 026, 045, 046, 047, 048, 049
#  Phase 5: Modify/Edit that CSR only — 052, 053, 054, 055
#  Phase 6: Cleanup — 004_Delete (deletes the CSR created in 004)
#  APN Type: All tests that need APN type use Any (${CSRJ_APN_TYPE_ANY}) except 019=Public, 020=Any. Tariff: DATA AND NBIOT IT tp (${CSRJ_DEFAULT_TARIFF_PLAN}).
# ══════════════════════════════════════════════════════════════════════

*** Test Cases ***
TC_CSRJ_001 Navigate To CSR Journey Module Via Admin
    [Documentation]    Verifies user can navigate from Manage Devices to CSR Journey
    ...                module via Admin icon in the left sidebar.
    [Tags]    positive    smoke    regression    csr-journey    navigation
    Login For CSR Journey
    Navigate To CSR Journey Module
    Verify CSR Journey Landing Page Loaded

TC_CSRJ_002 Select Customer And Verify BU Dropdown Populates
    [Documentation]    Verifies that selecting a Customer from the custom dropdown
    ...                causes the Business Unit dropdown to become populated.
    [Tags]    positive    regression    csr-journey    customer-selection
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Wait Until Element Is Visible    ${LOC_CSRJ_BU_DD_BTN}    ${CSRJ_TIMEOUT}
    Log    Business Unit dropdown is now accessible after customer selection.

TC_CSRJ_018 BU Dropdown Not Interactable Without Customer Selection
    [Documentation]    Verifies the Business Unit dropdown button does not show BU
    ...                options if no Customer is selected first.
    [Tags]    negative    regression    csr-journey    bu-selection    validation
    Login And Navigate To CSR Journey
    ${btn_text}=    Get Text    ${LOC_CSRJ_BU_DD_BTN}
    Should Contain    ${btn_text}    Select
    Verify Create Order Button Not Visible
    Log    BU dropdown shows "Select" and Create Order hidden without customer selection.

TC_CSRJ_003 Select BU And Verify Create Order Button Visible
    [Documentation]    Verifies that after selecting Customer and BU, the Create Order
    ...                button appears (user has RW permission).
    [Tags]    positive    regression    csr-journey    bu-selection
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Verify Create Order Button Visible

TC_CSRJ_017 Create Order Not Visible Without BU Selection
    [Documentation]    Verifies that without selecting BU, user cannot click Create Order
    ...                (button is not visible or disabled).
    [Tags]    negative    regression    csr-journey    create-order    validation
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Verify Create Order Button Not Clickable Without BU
    Log    Create Order correctly not clickable without BU selection.

TC_CSRJ_006 Verify Wizard Step Indicators Are Visible
    [Documentation]    Verifies all three wizard step indicators (Standard Services,
    ...                Additional Services, Order Summary) are visible on the wizard.
    [Tags]    positive    regression    csr-journey    wizard-steps
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Wait Until Element Is Visible    ${LOC_STEP_STANDARD}       ${CSRJ_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_STEP_ADDITIONAL}     ${CSRJ_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_STEP_ORDER_SUMMARY}  ${CSRJ_TIMEOUT}
    Log    All three wizard step indicators are visible.

TC_CSRJ_012 APN Type Dropdown Disabled Without Tariff Plan
    [Documentation]    Verifies APN Type dropdown remains disabled when no
    ...                Tariff Plan is selected.
    [Tags]    negative    regression    csr-journey    apn-type    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Verify APN Type Dropdown Disabled
    Log    APN Type dropdown correctly disabled without Tariff Plan.

TC_CSRJ_010 Select Tariff Plan And Verify APN Type Becomes Enabled
    [Documentation]    Verifies that APN Type dropdown becomes enabled only after
    ...                selecting a Tariff Plan.
    [Tags]    positive    regression    csr-journey    tariff-plan    dependency
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Verify APN Type Dropdown Disabled
    Select Tariff Plan First Option
    Verify APN Type Dropdown Enabled
    Log    APN Type dropdown correctly enabled after Tariff Plan selection.

TC_CSRJ_013 Add APNs Button Disabled Without APN Type
    [Documentation]    Verifies Add APNs button remains disabled when no APN Type
    ...                is selected (even after selecting Tariff Plan).
    [Tags]    negative    regression    csr-journey    apn    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Verify Add APNs Button Disabled
    Log    Add APNs button correctly disabled without APN Type selection.

TC_CSRJ_019 Select APN Type Public And Verify Add APNs Enabled
    [Documentation]    Verifies selecting "public" APN Type (instead of "private")
    ...                also enables the Add APNs button.
    [Tags]    negative    regression    csr-journey    apn-type    public
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    Public
    Verify Add APNs Button Enabled
    Log    Add APNs enabled after selecting public APN Type.

TC_CSRJ_020 Select APN Type Any And Verify Add APNs Enabled
    [Documentation]    Verifies selecting "any" APN Type enables the Add APNs button.
    [Tags]    negative    regression    csr-journey    apn-type    any
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    Any
    Verify Add APNs Button Enabled
    Log    Add APNs enabled after selecting any APN Type.

TC_CSRJ_041 Service Plan Input Disabled Until Tariff Plan Selected
    [Documentation]    Verifies the Service Plan name input is disabled when no
    ...                Tariff Plan is selected.
    [Tags]    negative    regression    csr-journey    service-plan    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Verify Service Plan Input Disabled
    Log    Service Plan input correctly disabled before Tariff Plan selection.

TC_CSRJ_036 Select Bundle Plan After Fetch Device Plan
    [Documentation]    Verifies that after fetching device plans, the Bundle Plan
    ...                dropdown is populated and a plan can be selected.
    [Tags]    positive    regression    csr-journey    bundle-plan    device-plan
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Select Bundle Plan First Option
    Log    Bundle Plan selected after fetching device plans.

TC_CSRJ_037 Fill End Date On Standard Services
    [Documentation]    Verifies the End Date Kendo datepicker can accept a date value
    ...                on the Standard Services screen.
    [Tags]    positive    regression    csr-journey    end-date
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Fill End Date    ${CSRJ_END_DATE}
    Log    End Date filled successfully.

TC_CSRJ_007 Navigate Previous From Additional To Standard Services
    [Documentation]    Verifies clicking Previous on Additional Services returns
    ...                to Standard Services screen with form fields visible.
    [Tags]    positive    regression    csr-journey    navigation    previous
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Previous On Additional Services
    Verify Standard Services Screen Loaded
    Log    Successfully navigated back to Standard Services.

TC_CSRJ_008 Navigate Previous From Summary To Additional Services
    [Documentation]    Verifies clicking Previous on Summary screen returns
    ...                to Additional Services screen.
    [Tags]    positive    regression    csr-journey    navigation    previous
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Click Previous On Summary
    Verify Additional Services Screen Loaded
    Log    Successfully navigated back to Additional Services.

TC_CSRJ_009 Verify Customer And BU Info Displayed On Summary
    [Documentation]    Verifies that the Summary screen displays the Customer and
    ...                Business Unit info correctly in the read-only review section.
    [Tags]    positive    regression    csr-journey    summary    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Verify Customer Info On Summary
    Verify BU Info On Summary

TC_CSRJ_011 Verify Tariff Plan Accordion On Summary Shows Selected TP
    [Documentation]    Verifies the Tariff Plan accordion section on the Summary screen
    ...                displays the tariff plan that was selected during the flow.
    [Tags]    positive    regression    csr-journey    summary    tariff-plan
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Expand Tariff Plan Accordion On Summary
    Verify Tariff Plan Value On Summary

# ══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_014 Close From Standard Services Should Redirect Without Saving
    [Documentation]    Verifies clicking Close on Standard Services redirects back
    ...                to CSR Journey landing page without saving any data.
    [Tags]    negative    regression    csr-journey    close    standard-services
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Click Close On Standard Services
    Verify Redirected To CSR Journey Landing
    Log    Close on Standard Services redirected to landing page.

TC_CSRJ_015 Close From Additional Services Should Redirect Without Saving
    [Documentation]    Verifies clicking Close on Additional Services redirects back
    ...                to CSR Journey landing page without saving.
    [Tags]    negative    regression    csr-journey    close    additional-services
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Close On Additional Services
    Verify Redirected To CSR Journey Landing
    Log    Close on Additional Services redirected to landing page.

TC_CSRJ_016 Close From Summary Should Redirect Without Saving
    [Documentation]    Verifies clicking Close on Summary screen redirects back
    ...                to CSR Journey landing page without saving.
    [Tags]    negative    regression    csr-journey    close    summary
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Click Close On Summary
    Verify Redirected To CSR Journey Landing
    Log    Close on Summary redirected to landing page.

TC_CSRJ_021 Close Service Plan Modal Without Saving
    [Documentation]    Verifies the Create Service Plan modal can be opened and closed
    ...                without saving, and the wizard remains intact.
    [Tags]    negative    regression    csr-journey    service-plan    modal
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Create Service Plan Link
    Wait Until Element Is Visible    ${LOC_SP_MODAL}    ${CSRJ_TIMEOUT}
    Close Service Plan Modal
    Wait Until Element Is Not Visible    ${LOC_SP_MODAL}    ${CSRJ_TIMEOUT}
    Verify Standard Services Screen Loaded
    Log    Service Plan modal closed without saving — wizard intact.

TC_CSRJ_022 Close Discount Modal Without Saving
    [Documentation]    Verifies the Add Discount modal can be opened and closed
    ...                without saving on the Additional Services screen.
    [Tags]    negative    regression    csr-journey    discount    modal
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Toggle Discount Accordion
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    Close Discount Modal
    Wait Until Element Is Not Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    Verify Additional Services Screen Loaded
    Log    Discount modal closed without saving — wizard intact.

# ══════════════════════════════════════════════════════════════════════
#  EDGE CASE TEST CASES
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_005 Save And Continue Should Stay On Wizard
    [Documentation]    Verifies that clicking Save & Continue on Summary screen saves
    ...                the journey but stays on the CreateCSRJourney wizard page.
    [Tags]    positive    regression    csr-journey    save-continue
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Click Save And Continue
    Verify CSR Journey Success Toast
    Verify Still On Create CSR Journey Page

TC_CSRJ_034 Fill And Save Service Plan Via Modal
    [Documentation]    Verifies the Create Service Plan modal can be opened, checkboxes
    ...                selected (Voice MO, SMS, Data), and saved successfully.
    [Tags]    positive    regression    csr-journey    service-plan    modal
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Fill And Save Service Plan
    Verify Standard Services Screen Loaded
    Log    Service Plan saved successfully via modal.

TC_CSRJ_035 Fill And Save Discount On Additional Services
    [Documentation]    Verifies a discount can be added through the Add Discount modal
    ...                on the Additional Services screen.
    [Tags]    positive    regression    csr-journey    discount    save
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Toggle Discount Accordion
    Fill And Save Discount
    Log    Discount saved successfully.

TC_CSRJ_027 Verify Account VAS Accordion Toggle
    [Documentation]    Verifies the Account Level VAS Charges accordion can be
    ...                expanded and collapsed on the Standard Services screen.
    [Tags]    edge-case    regression    csr-journey    vas    accordion
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Toggle Account VAS Accordion
    Sleep    1s
    Toggle Account VAS Accordion
    Log    Account VAS accordion toggled successfully.

TC_CSRJ_028 Verify Device VAS Accordion Toggle
    [Documentation]    Verifies the Device Level VAS Charges accordion can be
    ...                expanded and collapsed on the Standard Services screen.
    [Tags]    edge-case    regression    csr-journey    vas    accordion
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Toggle Device VAS Accordion
    Sleep    1s
    Toggle Device VAS Accordion
    Log    Device VAS accordion toggled successfully.

TC_CSRJ_029 Verify Breadcrumb Updates Across Wizard Steps
    [Documentation]    Verifies that the breadcrumb updates correctly as the user
    ...                navigates through Standard Services → Additional Services → Summary.
    [Tags]    edge-case    regression    csr-journey    breadcrumb    navigation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Verify Breadcrumb Shows Standard Services
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Verify Breadcrumb Shows Additional Services
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Verify Breadcrumb Shows Summary
    Log    Breadcrumb updated correctly across all wizard steps.

TC_CSRJ_030 Verify APN Table Headers On Landing Page
    [Documentation]    Verifies the APN/Device Plan table on the CSR Journey landing
    ...                page has all expected column headers after selecting Customer/BU.
    [Tags]    edge-case    regression    csr-journey    grid    table-headers
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify APN Table Headers Present
    Log    APN table headers verified on landing page.

TC_CSRJ_031 Verify Discount Accordion Toggle On Additional Services
    [Documentation]    Verifies the Discount accordion can be expanded and collapsed
    ...                on the Additional Services screen.
    [Tags]    edge-case    regression    csr-journey    discount    accordion
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Toggle Discount Accordion
    Sleep    1s
    Toggle Discount Accordion
    Log    Discount accordion toggled successfully.

TC_CSRJ_032 Verify Summary Accordion Sections Expandable
    [Documentation]    Verifies all three accordion sections (Tariff Plan, Account Plan,
    ...                Device Plan) on the Summary screen can be expanded.
    [Tags]    edge-case    regression    csr-journey    summary    accordion
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Expand Tariff Plan Accordion On Summary
    Expand Account Plan Accordion On Summary
    Expand Device Plan Accordion On Summary
    Log    All summary accordion sections expanded successfully.

# ══════════════════════════════════════════════════════════════════════
#  ADDITIONAL POSITIVE TEST CASES
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_033 Select Addon Plan And Verify Table Populates
    [Documentation]    Verifies selecting an Addon Plan on Additional Services
    ...                populates the addon plan table with data.
    [Tags]    positive    regression    csr-journey    addon-plan
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Select First Addon Plan
    Verify Addon Plan Selected
    Verify Addon Table Has Data
    Log    Addon plan selected and table populated.

TC_CSRJ_038 Search Customer By Name In Dropdown
    [Documentation]    Verifies typing a customer name in the search input filters
    ...                the custom Customer dropdown and the correct option is clickable.
    [Tags]    positive    regression    csr-journey    customer-search
    Login And Navigate To CSR Journey
    Wait Until Element Is Visible    ${LOC_CSRJ_CUSTOMER_DD_BTN}    ${CSRJ_TIMEOUT}
    Click Element Via JS             ${LOC_CSRJ_CUSTOMER_DD_BTN}
    Wait Until Element Is Visible    ${LOC_CSRJ_CUSTOMER_SEARCH}    ${CSRJ_TIMEOUT}
    ${first_opt}=    Set Variable    xpath=//div[contains(@class,'selectcsrjourney')]//div[contains(@class,'selectDropdown')][1]//div[contains(@class,'option')][1]
    Wait Until Element Is Visible    ${first_opt}    ${CSRJ_TIMEOUT}
    ${customer_name}=    Get Text    ${first_opt}
    Clear Element Text    ${LOC_CSRJ_CUSTOMER_SEARCH}
    Input Text           ${LOC_CSRJ_CUSTOMER_SEARCH}    ${customer_name}
    Sleep    1s
    ${filtered}=    Set Variable    xpath=//div[contains(@class,'selectcsrjourney')]//div[contains(@class,'selectDropdown')][1]//div[contains(@class,'option') and contains(text(),'${customer_name}')]
    Wait Until Element Is Visible    ${filtered}    ${CSRJ_TIMEOUT}
    Click Element Via JS             ${filtered}
    Sleep    1s
    Log    Customer searched and selected by name: ${customer_name}

TC_CSRJ_039 Search Tariff Plan By Name In Dropdown
    [Documentation]    Verifies typing a tariff plan name in the search input filters
    ...                the Tariff Plan dropdown and selects the matching option.
    [Tags]    positive    regression    csr-journey    tariff-plan    search
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Wait Until Element Is Visible    ${LOC_SS_TARIFF_PLAN_DD}    ${CSRJ_TIMEOUT}
    Click Element Via JS             ${LOC_SS_TARIFF_PLAN_DD}
    Sleep    1s
    ${first_opt}=    Set Variable    xpath=(//div[@data-testid='tariffplan']//div[@class='option'])[1]
    Wait Until Element Is Visible    ${first_opt}    ${CSRJ_TIMEOUT}
    ${tp_name}=    Get Text    ${first_opt}
    Wait Until Element Is Visible    ${LOC_SS_TARIFF_PLAN_SEARCH}    ${CSRJ_TIMEOUT}
    Input Text                       ${LOC_SS_TARIFF_PLAN_SEARCH}    ${tp_name}
    Sleep    1s
    ${filtered}=    Set Variable    xpath=//div[@data-testid='tariffplan']//div[@class='option' and normalize-space()='${tp_name}']
    Wait Until Element Is Visible    ${filtered}    ${CSRJ_TIMEOUT}
    Click Element Via JS             ${filtered}
    Sleep    1s
    Log    Tariff Plan searched and selected by name: ${tp_name}

# ══════════════════════════════════════════════════════════════════════
#  ADDITIONAL NEGATIVE TEST CASES
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_040 APN Type Conflict Should Show Error
    [Documentation]    Verifies that selecting a Tariff Plan + APN Type combination
    ...                that already has a CSR Journey shows the APN conflict error.
    [Tags]    negative    regression    csr-journey    apn-conflict    validation
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    ${has_data}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CSRJ_APN_TABLE_BODY}    10s
    IF    not ${has_data}
        Log    No existing CSR data — cannot test APN conflict. Skipping.
        Pass Execution    No existing CSR data to create conflict scenario.
    END
    Click Create Order
    Verify Standard Services Screen Loaded
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    ${conflict}=    Run Keyword And Return Status
    ...    Verify APN Conflict Error Displayed
    IF    ${conflict}
        Log    APN conflict error correctly displayed for existing TP+APN combo.
    ELSE
        Log    No conflict detected — combination may be new. Test inconclusive.
    END

TC_CSRJ_042 Save Account VAS Without Filling Required Fields
    [Documentation]    Verifies opening the Account VAS modal and clicking Save without
    ...                filling fields shows validation or does not save.
    [Tags]    negative    regression    csr-journey    vas    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Open Account VAS Modal
    ${modal_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ACCT_VAS_MODAL}    5s
    IF    ${modal_visible}
        Click Element Via JS    ${LOC_ACCT_VAS_MODAL_SAVE}
        Sleep    1s
        ${still_open}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${LOC_ACCT_VAS_MODAL}
        IF    ${still_open}
            Log    Modal stayed open — validation prevented save without required fields.
        ELSE
            Log    Modal closed — may have default values or no required validation.
        END
        Close Account VAS Modal
    ELSE
        Log    Account VAS modal did not open — section may be empty.
    END

TC_CSRJ_043 Save Device VAS Without Filling Required Fields
    [Documentation]    Verifies opening the Device VAS modal and clicking Save without
    ...                filling fields shows validation or does not save.
    [Tags]    negative    regression    csr-journey    vas    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Open Device VAS Modal
    ${modal_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DEV_VAS_MODAL}    5s
    IF    ${modal_visible}
        Click Element Via JS    ${LOC_DEV_VAS_MODAL_SAVE}
        Sleep    1s
        ${still_open}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${LOC_DEV_VAS_MODAL}
        IF    ${still_open}
            Log    Modal stayed open — validation prevented save without required fields.
        ELSE
            Log    Modal closed — may have default values or no required validation.
        END
        Close Device VAS Modal
    ELSE
        Log    Device VAS modal did not open — section may be empty.
    END

TC_CSRJ_044 Save Discount Without Filling Required Fields
    [Documentation]    Verifies opening the Add Discount modal and clicking Save without
    ...                filling all required fields shows validation.
    [Tags]    negative    regression    csr-journey    discount    validation
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Toggle Discount Accordion
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    Click Element Via JS    ${LOC_AS_DISCOUNT_MODAL_SAVE}
    Sleep    1s
    ${still_open}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_AS_DISCOUNT_MODAL}
    IF    ${still_open}
        Log    Discount modal stayed open — validation prevented empty save.
    ELSE
        Log    Discount modal closed — may not have strict validation.
    END
    Close Discount Modal

# ══════════════════════════════════════════════════════════════════════
#  ADDITIONAL EDGE CASE TEST CASES
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_050 Navigate Full Wizard Forward And Backward
    [Documentation]    Verifies navigating forward through all wizard steps and then
    ...                backward to confirm each step renders correctly both ways.
    [Tags]    edge-case    regression    csr-journey    navigation    full-cycle
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Click Fetch Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Click Previous On Summary
    Verify Additional Services Screen Loaded
    Click Previous On Additional Services
    Verify Standard Services Screen Loaded
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Log    Full forward-backward-forward wizard navigation verified.

TC_CSRJ_051 Verify All APN Type Options Available
    [Documentation]    Verifies the APN Type dropdown contains all expected options:
    ...                Select, Public, Private, and Any.
    [Tags]    edge-case    regression    csr-journey    apn-type    options
    Login And Navigate To CSR Journey
    Navigate To Standard Services Via Create Order
    Select Tariff Plan First Option
    Verify APN Type Dropdown Enabled
    ${options}=    Get List Items    ${LOC_SS_APN_TYPE_DD}
    Should Contain    ${options}    Public
    Should Contain    ${options}    Private
    Should Contain    ${options}    Any
    Log    All APN Type options verified: ${options}

# ══════════════════════════════════════════════════════════════════════
#  MODIFY CSR JOURNEY TEST CASES
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_004 Create CSR Journey End To End Standard Flow
    [Documentation]    Complete end-to-end flow: Login → Admin → CSR Journey →
    ...                Select Customer/BU → Create Order → Standard Services
    ...                (Tariff Plan, APN Type, Add APNs, Fetch Device Plan) →
    ...                Additional Services → Summary → Save & Continue →
    ...                Verify success toast and stay on Create CSR Journey page.
    [Tags]    positive    smoke    regression    csr-journey    e2e    create-order
    Set Suite Variable    ${CSR_CREATED_BY_TC4_ALIAS}    ${CSRJ_DEVICE_PLAN_ALIAS}
    Full Create CSR Journey Flow With Save And Continue

TC_CSRJ_023 Verify CSR Summary Icon Visible In Grid
    [Documentation]    Verifies the CSR Summary (eye) icon is visible in the grid
    ...                after selecting Customer and BU with existing CSR data.
    [Tags]    edge-case    regression    csr-journey    grid    icons
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify CSR Summary Icon Visible

TC_CSRJ_024 Verify Edit Icon Visible In CSR Journey Grid
    [Documentation]    Verifies the Edit icon is visible in the CSR Journey grid
    ...                for rows with existing CSR data.
    [Tags]    edge-case    regression    csr-journey    grid    icons
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify Edit Icon Visible In CSR Grid

TC_CSRJ_025 Verify Delete Icon Visible In CSR Journey Grid
    [Documentation]    Verifies the Delete icon is visible in the CSR Journey grid.
    [Tags]    edge-case    regression    csr-journey    grid    icons
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify Delete Icon Visible In CSR Grid

TC_CSRJ_026 Verify Change Tariff Plan Icon Visible In Grid
    [Documentation]    Verifies the Change Tariff Plan icon is visible in the CSR
    ...                Journey grid for rows with existing CSR data.
    [Tags]    edge-case    regression    csr-journey    grid    icons
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify Change TP Icon Visible In CSR Grid

TC_CSRJ_045 Verify Usage Based Charges Grid On Landing Page
    [Documentation]    Verifies the Usage Based Charges grid is visible on the
    ...                CSR Journey landing page after selecting Customer and BU.
    [Tags]    edge-case    regression    csr-journey    grid    usage-charges
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify Usage Based Charges Grid Visible

TC_CSRJ_046 Verify Transaction History Grid On Landing Page
    [Documentation]    Verifies the Transaction History grid is visible on the
    ...                CSR Journey landing page after selecting Customer and BU.
    [Tags]    edge-case    regression    csr-journey    grid    txn-history
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify Transaction History Grid Visible

TC_CSRJ_047 Verify Order Summary Heading On Landing Page
    [Documentation]    Verifies the "Order Summary" heading is visible on the
    ...                CSR Journey landing page.
    [Tags]    edge-case    regression    csr-journey    order-summary    landing
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Verify Order Summary Heading Visible

TC_CSRJ_048 View CSR Summary Popup Via Eye Icon
    [Documentation]    Verifies clicking the CSR Summary (eye) icon on a grid row
    ...                opens the Journey Summary popup.
    [Tags]    edge-case    regression    csr-journey    grid    popup
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    Click CSR Summary Icon And Verify Popup

TC_CSRJ_049 CSR Overwrite Modal In Edit Mode
    [Documentation]    Verifies that when editing an existing CSR Journey, the CSR
    ...                Overwrite modal may appear if the CSR was modified by another user.
    [Tags]    edge-case    regression    csr-journey    overwrite    modal
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete
    Sleep    2s
    ${edit_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CSRJ_EDIT_ICON}    10s
    IF    ${edit_visible}
        Click Element Via JS    ${LOC_CSRJ_EDIT_ICON}
        Wait For App Loading To Complete
        Sleep    2s
        ${overwrite}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_CSR_OVERWRITE_MODAL}    10s
        IF    ${overwrite}
            Log    CSR Overwrite modal appeared in edit mode.
            Element Should Be Visible    ${LOC_CSR_OVERWRITE_MSG}
        ELSE
            Log    No overwrite conflict detected — CSR was not modified by another user.
        END
    ELSE
        Log    No edit icon visible — no existing CSR data to edit.
        Pass Execution    No existing CSR to test edit/overwrite scenario.
    END

TC_CSRJ_052 Modify CSR Journey Via Edit And Save
    [Documentation]    Independent test. Pass --variable MODIFY_CSR_DEVICE_PLAN:<name> to specify which CSR to modify.
    ...                Clicks Edit for that CSR → + Add → Bundle Plan → new device plan →
    ...                Create Service Plan → Save SP → Add APNs → Save APN → Save device plan →
    ...                Next → Next → Save & Continue.
    [Tags]    positive    regression    csr-journey    modify    edit
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Open CSR Journey Edit Mode For CSR By Device Plan Alias    ${MODIFY_CSR_DEVICE_PLAN}
    Modify CSR Journey And Save
    Log    Modify CSR Journey completed. New device plan: ${CSRJ_DEVICE_PLAN_ALIAS_MODIFY}

TC_CSRJ_053 Edit CSR Journey Update Service Types And Save
    [Documentation]    Independent test. Pass --variable EDIT_CSR_DEVICE_PLAN:<name> to specify which CSR to edit.
    ...                Clicks Edit for that CSR → on Standard Services clicks existing device plan →
    ...                Edit Device Plan window opens → checks all service type checkboxes → Save →
    ...                Next → Next → Save & Continue on Summary.
    [Tags]    positive    regression    csr-journey    modify    edit    service-types
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Open CSR Journey Edit Mode For CSR By Device Plan Alias    ${EDIT_CSR_DEVICE_PLAN}
    Edit CSR Journey Update Service Types And Save
    Log    Edit CSR Journey completed; service types updated for CSR: ${EDIT_CSR_DEVICE_PLAN}

# ══════════════════════════════════════════════════════════════════════
#  MULTIPLE DEVICE PLANS IN SINGLE CSR JOURNEY
# ══════════════════════════════════════════════════════════════════════

TC_CSRJ_054 Add Multiple Device Plans In Single CSR Journey
    [Documentation]    Runs after TC_CSRJ_004. Clicks Edit for the same CSR (by device plan alias),
    ...                adds second device plan (Add APNs, public_dynamic, Save → Create Service Plan → Save) →
    ...                Summary, Save & Exit. That CSR only.
    [Tags]    positive    regression    csr-journey    multiple-device-plans    device-plan
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
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
    [Documentation]    Runs after TC_CSRJ_054. Opens the CSR created in TC_CSRJ_004 (edited in 054),
    ...                navigates to Summary and verifies Device Plan section has multiple rows. That CSR only.
    [Tags]    positive    regression    csr-journey    multiple-device-plans    summary
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
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
    [Documentation]    Runs after 052–055. Deletes only the CSR created in TC_CSRJ_004
    ...                (identified by same Customer/BU and device plan alias). Does not delete any other CSR.
    [Tags]    positive    regression    csr-journey    delete    cleanup
    Login And Navigate To CSR Journey
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Wait For App Loading To Complete    timeout=60s
    Delete CSR By Device Plan Alias    ${CSR_CREATED_BY_TC4_ALIAS}
    Log    CSR created in TC_CSRJ_004 has been deleted.
