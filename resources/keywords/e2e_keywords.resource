*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    api_keywords.resource
Resource    apn_keywords.resource
Resource    csr_journey_keywords.resource
Resource    sim_range_keywords.resource
Resource    sim_order_keywords.resource
Resource    product_type_keywords.resource
Resource    order_processing_keywords.resource
Resource    usage_keywords.resource
Resource    device_plan_keywords.resource
Resource    ../locators/login_locators.resource
Resource    ../locators/apn_locators.resource
Resource    ../locators/csr_journey_locators.resource
Resource    ../locators/sim_range_locators.resource
Resource    ../locators/sim_order_locators.resource
Resource    ../locators/product_type_locators.resource
Resource    ../locators/device_state_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  E2E SUITE SETUP / TEARDOWN
# ═══════════════════════════════════════════════════════════════════════
E2E Suite Setup
    [Documentation]    Opens browser and logs in once for the entire E2E flow.
    ...                Steps 2-6 (UI) share this session. Step 1 (API) manages its own session.
    Open Test Browser    ${BASE_URL}    ${BROWSER}
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success

# ═══════════════════════════════════════════════════════════════════════
#  STEP 1: ACCOUNT ONBOARD (API)
# ═══════════════════════════════════════════════════════════════════════
E2E Onboard Account
    [Documentation]    Creates a new EC + BU via SOAP API. Returns the EC name (company_name)
    ...                and BU name (billing_account_name) created by the API.
    Create Onboard API Session
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    Log    ===== SOAP REQUEST BODY =====    console=yes
    Log    ${soap_body}    console=yes
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    ===== SOAP RESPONSE (Status: ${response.status_code}) =====    console=yes
    Log    ${response.text}    console=yes
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}
    Log    ===== ONBOARD SUCCESS =====    console=yes
    Log    EC Name : ${data}[company_name]    console=yes
    Log    BU Name : ${data}[billing_account_name]    console=yes
    Delete All Sessions
    RETURN    ${data}[company_name]    ${data}[billing_account_name]

E2E Verify Account On UI
    [Documentation]    Navigates to ManageAccount page, turns OFF the "Show Customer Wise Data" toggle
    ...                (ON by default), then searches and validates both EC and BU account names
    ...                in the grid toolbar search input and ACCOUNTS column.
    [Arguments]    ${ec_name}    ${bu_name}
    Ensure Session Is Active
    Navigate To ManageAccount Page
    Click Show Customer Wise Data Toggle
    Search And Validate Account In Grid    ${ec_name}
    Search And Validate Account In Grid    ${bu_name}

Navigate To ManageAccount Page
    [Documentation]    Navigates from any page to Admin > Account > ManageAccount.
    Navigate To Module Page    ${BASE_URL}ManageDevices
    Wait For App Loading To Complete
    Scroll To Element Via JS    xpath=//i[contains(@class,'admin-menu-icon')]
    Wait Until Element Is Visible    xpath=//i[contains(@class,'admin-menu-icon')]    timeout=30s
    Click Element Via JS    xpath=//i[contains(@class,'admin-menu-icon')]
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageUser
    Wait For App Loading To Complete
    Sleep    1s
    Scroll To Element Via JS    xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]
    Wait Until Element Is Visible    xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]    timeout=30s
    Click Element Via JS    xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]
    Sleep    2s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageAccount
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Sleep    2s
    Wait For App Loading To Complete
    Log    ManageAccount page loaded.    console=yes

Click Show Customer Wise Data Toggle
    [Documentation]    Clicks the "Show Customer Wise Data" toggle switch on the ManageAccount page.
    ...                The toggle is ON by default — clicking it turns it OFF so both EC and BU
    ...                accounts are visible in the grid.
    Sleep    2s
    Wait Until Element Is Visible    xpath=//label[@for='switch']    timeout=10s
    Click Element    xpath=//label[@for='switch']
    Log    "Show Customer Wise Data" toggle clicked (turning OFF).    console=yes
    Sleep    3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Sleep    2s
    Log    Toggle turned OFF. Grid reloaded with all accounts.    console=yes

Search And Validate Account In Grid
    [Documentation]    Types an account name into the ManageAccount grid toolbar search input
    ...                (NOT the global Search Device input), presses ENTER, waits for grid reload,
    ...                and validates the name appears in the ACCOUNTS column.
    [Arguments]    ${account_name}
    # The grid toolbar search is near the "Create Cost Center" button / toggle area,
    # NOT the global "Search Device" input in the dark header nav bar.
    ${search_input}=    Execute Javascript
    ...    var grid = document.getElementById('ManageAccountGrid');
    ...    if(!grid) return null;
    ...    var toolbar = grid.parentElement;
    ...    for(var i=0; i<5; i++){
    ...        var inputs = toolbar.querySelectorAll('input[type="text"], input[type="search"], input:not([type])');
    ...        for(var j=0; j<inputs.length; j++){
    ...            var inp = inputs[j];
    ...            var ph = (inp.placeholder || '').toLowerCase();
    ...            if(ph.indexOf('search device') >= 0) continue;
    ...            if(inp.offsetParent !== null) return inp.id || inp.name || inp.className;
    ...        }
    ...        toolbar = toolbar.parentElement;
    ...        if(!toolbar) break;
    ...    }
    ...    return null;
    Log    Grid search input identifier: ${search_input}    console=yes
    # Use a targeted XPath: input in the same container as ManageAccountGrid, excluding global search
    ${input_loc}=    Set Variable    xpath=//div[@id='ManageAccountGrid']/ancestor::div[contains(@class,'card') or contains(@class,'panel') or contains(@class,'content')]//input[@type='text' or @type='search' or not(@type)][not(contains(@placeholder,'Search Device'))][not(ancestor::nav)][not(ancestor::header)]
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${input_loc}    10s
    IF    not ${input_visible}
        ${input_loc}=    Set Variable    xpath=//input[not(contains(@placeholder,'Search Device'))][not(ancestor::nav)][not(ancestor::*[contains(@class,'navbar')])][@type='text' or @type='search' or not(@type)]
        Wait Until Element Is Visible    ${input_loc}    timeout=10s
    END
    # Clear existing text via X button if visible
    ${clear_btn}=    Set Variable    xpath=//div[@id='ManageAccountGrid']/ancestor::div[contains(@class,'card') or contains(@class,'panel') or contains(@class,'content')]//*[contains(@class,'k-i-close') or contains(@class,'clear') or @aria-label='clear' or contains(@class,'k-clear-value')]
    ${has_clear}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${clear_btn}    3s
    IF    ${has_clear}
        Click Element Via JS    ${clear_btn}
        Sleep    1s
        Wait For App Loading To Complete    timeout=30s
    END
    Clear Element Text    ${input_loc}
    Input Text    ${input_loc}    ${account_name}
    Press Keys    ${input_loc}    ENTER
    Log    Searching for account: "${account_name}" in grid search...    console=yes
    Sleep    3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Sleep    2s
    # Validate account name in ACCOUNTS column via Kendo grid data
    ${found}=    Execute Javascript
    ...    var grid = $('#ManageAccountGrid').data('kendoGrid');
    ...    if(!grid) return false;
    ...    var ds = grid.dataSource.view();
    ...    for(var i=0; i<ds.length; i++){
    ...        var name = ds[i].Name || ds[i].name || ds[i].AccountName || ds[i].accountName || '';
    ...        if(name.indexOf(arguments[0]) >= 0) return true;
    ...    }
    ...    return false;
    ...    ARGUMENTS    ${account_name}
    IF    not ${found}
        ${page_has}=    Run Keyword And Return Status
        ...    Page Should Contain    ${account_name}
        Should Be True    ${page_has}
        ...    Account "${account_name}" not found in ManageAccount grid after search.
    END
    Log    Account "${account_name}" verified in ManageAccount grid.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 2: APN ASSIGNMENT (UI)
# ═══════════════════════════════════════════════════════════════════════
E2E Create APN
    [Documentation]    Navigates to Create APN and creates a Private APN under the given EC/BU.
    [Arguments]    ${ec_name}    ${bu_name}
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_APN_URL}
    Wait Until Element Is Visible    ${LOC_APN_TYPE}    timeout=30s
    Fill Primary Details    ${APN_TYPE_PRIVATE}    ${VALID_APN_ID}    ${VALID_APN_NAME}
    ...    ${VALID_DESCRIPTION}    ${VALID_IP_ADDR_TYPE_IPV4}    ${VALID_IP_ALLOC_STATIC}
    ...    account_name=${ec_name}    bu_name=${bu_name}
    Add And Fill Subnet Mask Entry
    Submit Create APN Form
    Verify APN Created Successfully
    Log    E2E APN created: "${VALID_APN_NAME}" for EC="${ec_name}" BU="${bu_name}"    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 3: CSR JOURNEY (UI)
# ═══════════════════════════════════════════════════════════════════════
E2E Create CSR Journey
    [Documentation]    Creates a CSR Journey using the onboarded EC/BU.
    ...                Navigates to CSR Journey module, selects customer and BU by name,
    ...                creates order, goes through the wizard, and saves.
    [Arguments]    ${ec_name}    ${bu_name}
    Ensure Session Is Active
    Navigate To Module Page    ${BASE_URL}ManageDevices
    Wait For App Loading To Complete
    Navigate To CSR Journey Module
    Select CSR Journey Customer By Name    ${ec_name}
    Select CSR Journey Business Unit By Name    ${bu_name}
    Verify Create Order Button Visible
    Click Create Order
    Verify Standard Services Screen Loaded
    Select Tariff Plan First Option
    csr_journey_keywords.Select APN Type    ${CSRJ_APN_TYPE_ANY}
    Click Add APNs
    Save APN And IP Preference
    Click Fetch Device Plan
    Select Bundle Plan First Option
    # Capture the actual label shown in the bundleName dropdown — this is a device plan alias
    # (e.g. "DP_LFjZV5"), NOT the bundle plan catalog name.  Step 18 uses this to avoid
    # selecting the same device plan alias from the dropdown.
    ${csr1_bundle_actual}=    Get Selected List Label    ${LOC_SS_BUNDLE_PLAN_DD}
    Enter Random Device Plan Alias
    Fill And Save Service Plan
    Click Save On Standard Services Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Click Save And Exit
    Verify CSR Journey Success Toast
    Verify Redirected To CSR Journey Landing
    Set Suite Variable    ${E2E_CSR1_TARIFF_PLAN}    ${CSRJ_DEFAULT_TARIFF_PLAN}
    Set Suite Variable    ${E2E_CSR1_APN_TYPE}        ${CSRJ_APN_TYPE_ANY}
    Set Suite Variable    ${E2E_CSR1_APN_NAME}        ${CSRJ_DEFAULT_APN_NAME}
    Set Suite Variable    ${E2E_CSR1_BUNDLE_PLAN}     ${csr1_bundle_actual}
    Set Suite Variable    ${E2E_CSR1_DP_ALIAS}        ${CSRJ_DEVICE_PLAN_ALIAS}
    Log    E2E CSR Journey created for EC="${ec_name}" BU="${bu_name}"    console=yes
    Log    Stored CSR1 — Tariff: "${CSRJ_DEFAULT_TARIFF_PLAN}", APN type: "${CSRJ_APN_TYPE_ANY}", APN: "${CSRJ_DEFAULT_APN_NAME}", Bundle (actual label): "${csr1_bundle_actual}", DP alias: "${CSRJ_DEVICE_PLAN_ALIAS}"    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 4: SIM RANGE CREATION (UI)
# ═══════════════════════════════════════════════════════════════════════
E2E Create SIM Range
    [Documentation]    Creates (1) ICCID/IMSI SIM range with 10 pool count and (2) MSISDN SIM range
    ...                with 10 pool count, using the default account (KSA_OPCO). Validates both in grid.
    Ensure Session Is Active
    # --- 1. ICCID/IMSI range (10 pool count) ---
    Navigate To Module Page    ${CREATE_SIM_RANGE_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Fill SIM Range With ICCID And IMSI
    Verify Pool Count    ${EXPECTED_POOL_COUNT}
    Submit SIM Range Form
    Verify SIM Range Created Successfully
    Log    E2E SIM Range created: pool="${VALID_POOL_NAME}" ICCID/IMSI count=10 (default account)    console=yes
    E2E Validate SIM Range In Grid    ${VALID_POOL_NAME}    ${VALID_ICCID_FROM}    ${VALID_ICCID_TO}
    ...    ${VALID_IMSI_FROM}    ${VALID_IMSI_TO}
    # --- 2. MSISDN range (10 pool count) ---
    Navigate To Module Page    ${CREATE_SIM_RANGE_MSISDN_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Fill MSISDN SIM Range With Ranges    ${MSISDN_POOL_NAME}    ${MSISDN_DESCRIPTION}
    ...    ${VALID_MSISDN_FROM}    ${VALID_MSISDN_TO}
    Verify MSISDN Grid Has Rows    expected_min=1
    Submit SIM Range Form
    Verify SIM Range Created Successfully
    Log    E2E MSISDN SIM Range created: pool="${MSISDN_POOL_NAME}" count=10 (default account)    console=yes

E2E Validate SIM Range In Grid
    [Documentation]    Delegates to the shared Validate SIM Range Grid Row keyword.
    [Arguments]    ${pool_name}    ${iccid_from}    ${iccid_to}    ${imsi_from}    ${imsi_to}
    Validate SIM Range Grid Row    ${pool_name}    ${iccid_from}    ${iccid_to}    ${imsi_from}    ${imsi_to}    10

# ═══════════════════════════════════════════════════════════════════════
#  STEP 5: SIM PRODUCT TYPE (UI)
# ═══════════════════════════════════════════════════════════════════════
E2E Create Product Type And Assign EC
    [Documentation]    Creates a SIM Product Type using the default account (KSA_OPCO),
    ...                validates STATUS is "Not In Use", assigns the onboarded EC,
    ...                validates STATUS changed to "In Use", expands row and validates EC name.
    [Arguments]    ${ec_name}
    Ensure Session Is Active
    Navigate To Module Page    ${BASE_URL}ManageDevices
    Wait For App Loading To Complete
    Navigate To Product Type Module
    Verify Create Product Type Button Visible
    Open Create Product Type Form
    Fill All Mandatory Fields With Defaults
    Verify Sub Type 1 Is Pre Filled And Disabled
    Fill Optional Fields
    Click Submit Product Type
    Verify Product Type Created Successfully
    Log    E2E Product Type created: "${PT_NAME}" (default account)    console=yes
    # Validate STATUS is "Not In Use" before assigning EC
    Verify Product Type Status In Grid    Not In Use    ${PT_NAME}
    Log    STATUS confirmed "Not In Use" before EC assignment.    console=yes
    # Now assign the onboarded EC to this product type
    Sleep    3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    timeout=30s
    Sleep    2s
    # Scroll grid to the right to expose the assign icon
    Execute Javascript
    ...    var grid = document.querySelector('.k-grid-content'); if(grid) grid.scrollLeft = grid.scrollWidth;
    Sleep    2s
    # Try clicking the assign icon — retry with page refresh if it fails
    ${assign_ok}=    Run Keyword And Return Status
    ...    Click Assign Customer Icon On First Row
    IF    not ${assign_ok}
        Log    Assign icon click failed on first attempt. Refreshing page and retrying...    console=yes
        Go To    ${BASE_URL}ProductType
        Sleep    5s
        Wait For App Loading To Complete    timeout=60s
        Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    timeout=30s
        Sleep    2s
        Execute Javascript
        ...    var grid = document.querySelector('.k-grid-content'); if(grid) grid.scrollLeft = grid.scrollWidth;
        Sleep    2s
        Click Assign Customer Icon On First Row
    END
    Select Enterprise Customer By Name    ${ec_name}
    Click Update EC Assignment
    Verify EC Assignment Successful
    # Validate STATUS changed to "In Use" after assignment
    Verify Product Type Status In Grid    In Use    ${PT_NAME}
    Log    STATUS confirmed "In Use" after EC assignment.    console=yes
    # Expand row and validate EC name under "Assigned Customers"
    Verify Assigned Customer Name After Expand    ${ec_name}
    Log    E2E Product Type "${PT_NAME}" assigned and verified for EC="${ec_name}"    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 6: SIM ORDER (UI)
# ═══════════════════════════════════════════════════════════════════════
E2E Create SIM Order
    [Documentation]    Creates a SIM Order by selecting the onboarded BU account from the
    ...                treeview (KSA_OPCO > EC > BU) with quantity 10.
    [Arguments]    ${ec_name}    ${bu_name}
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_SIM_ORDER_URL}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_WIZARD_CONTAINER}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Set SIM Replacement Order    false
    Select BU Account From TreeView    ${ec_name}    ${bu_name}
    Sleep    5s
    Wait For Loading Overlay To Disappear
    # Wait extra for cascading dropdowns to populate after account selection
    Sleep    5s
    Wait For Loading Overlay To Disappear
    # Dump dropdown states for diagnostic
    ${dd_state}=    Execute Javascript
    ...    var cat = document.querySelector("[data-testid='orderSimCategory'] .selectBtn");
    ...    var type = document.querySelector("select[name='simType']");
    ...    var prod = document.querySelector("[data-testid='productCatalog'] .selectBtn");
    ...    return JSON.stringify({
    ...        simCategory: cat ? cat.textContent.trim() : 'NOT_FOUND',
    ...        simType: type ? {options: type.options.length, value: type.value} : 'NOT_FOUND',
    ...        productType: prod ? prod.textContent.trim() : 'NOT_FOUND'
    ...    });
    Log    Dropdown states after account selection: ${dd_state}    console=yes
    Select SIM Category
    # SIM Type: select "Physical" option by text
    Execute Javascript
    ...    var sel = document.querySelector("select[name='simType']");
    ...    if(!sel) return;
    ...    for(var i=0; i<sel.options.length; i++){
    ...        if(sel.options[i].text.toLowerCase().indexOf('physical') >= 0){
    ...            sel.selectedIndex = i;
    ...            sel.dispatchEvent(new Event('change', {bubbles:true}));
    ...            return;
    ...        }
    ...    }
    ...    if(sel.options.length > 1){ sel.selectedIndex = 1; sel.dispatchEvent(new Event('change', {bubbles:true})); }
    Sleep    2s
    Wait For Loading Overlay To Disappear
    ${sim_type_val}=    Execute Javascript
    ...    var sel = document.querySelector("select[name='simType']");
    ...    return sel ? sel.options[sel.selectedIndex].text + ' (value:' + sel.value + ')' : 'NOT_FOUND';
    Log    SIM Type selected: ${sim_type_val}    console=yes
    # Product Type: select the one created in Step 5 by name
    ${pt_ok}=    Run Keyword And Return Status
    ...    Select Custom Dropdown Option By Name    ${LOC_SO_SIM_PRODUCT_BTN}    productCatalog    ${PT_NAME}
    IF    not ${pt_ok}
        Log    Product Type "${PT_NAME}" not found. Trying first available...    console=yes
        Sleep    5s
        Wait For Loading Overlay To Disappear
        ${pt_ok2}=    Run Keyword And Return Status    Select SIM Product Type
        IF    not ${pt_ok2}
            Log    No Product Type available. Retrying after 10s...    level=WARN    console=yes
            Sleep    10s
            Wait For Loading Overlay To Disappear
            Select SIM Product Type
        END
    ELSE
        Log    Product Type "${PT_NAME}" selected for SIM Order.    console=yes
    END
    Enter Quantity    10
    Set Activation Type    nonAutoActivation
    Sleep    1s
    Wait For Loading Overlay To Disappear
    # Log form state before clicking Next
    ${form_state}=    Execute Javascript
    ...    var acc = document.querySelector("input[name='accountSelected']");
    ...    var qty = document.querySelector("input[name='quantity']");
    ...    var cat = document.querySelector("[data-testid='orderSimCategory'] .selectBtn");
    ...    var prod = document.querySelector("[data-testid='productCatalog'] .selectBtn");
    ...    return JSON.stringify({
    ...        account: acc ? acc.value : '',
    ...        quantity: qty ? qty.value : '',
    ...        simCategory: cat ? cat.textContent.trim() : '',
    ...        productType: prod ? prod.textContent.trim() : ''
    ...    });
    Log    Form state before Next: ${form_state}    console=yes
    # Capture Step 1 state before advancing
    Capture Page Screenshot    e2e_simorder_step1.png
    # Click Next and verify we actually moved to Step 2 by checking active tab
    Scroll To Element Via JS    ${LOC_SO_BTN_STEP1_NEXT}
    Click Element Via JS    ${LOC_SO_BTN_STEP1_NEXT}
    Sleep    3s
    Wait For Loading Overlay To Disappear
    # Verify Step 2 is the active step (not just that address fields exist in DOM)
    ${on_step2}=    Execute Javascript
    ...    var step2 = document.querySelector('#strategy');
    ...    if(step2 && step2.classList.contains('active')) return true;
    ...    if(step2 && step2.offsetParent !== null && step2.offsetHeight > 100) return true;
    ...    var step2li = document.querySelector('#shipping');
    ...    if(step2li && step2li.classList.contains('active')) return true;
    ...    return false;
    Log    Step 2 active: ${on_step2}    console=yes
    IF    not ${on_step2}
        Log    FAILED to advance to Shipping. Capturing screenshot...    console=yes
        Capture Page Screenshot    e2e_simorder_step1_blocked.png
        ${errors}=    Execute Javascript
        ...    var errs = document.querySelectorAll('.text-danger, .error, .field-error, .alert-danger, [class*="error"]');
        ...    var result = [];
        ...    errs.forEach(function(e){ if(e.offsetParent!==null && e.textContent.trim()) result.push(e.textContent.trim()); });
        ...    return JSON.stringify(result);
        Log    Step 1 validation errors: ${errors}    console=yes
        Fail    Could not advance from Order Details to Shipping. Errors: ${errors}
    END
    Fill Address Fields
    Select Custom Dropdown Option By Name    ${LOC_SO_COUNTRY_BTN}    countryname    Saudi Arabia
    Fill Contact Details
    Capture Page Screenshot    e2e_simorder_step2.png
    Click Next To Preview
    Sleep    3s
    Wait For Loading Overlay To Disappear
    # Check if we advanced to Step 3
    ${on_step3}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_STEP3_PANE}    15s
    IF    not ${on_step3}
        Log    FAILED to advance to Preview. Capturing screenshot...    console=yes
        Capture Page Screenshot    e2e_simorder_step2_blocked.png
        ${errors2}=    Execute Javascript
        ...    var errs = document.querySelectorAll('.text-danger, .error, .field-error, .alert-danger, [class*="error"]');
        ...    var result = [];
        ...    errs.forEach(function(e){ if(e.offsetParent!==null) result.push(e.textContent.trim()); });
        ...    return JSON.stringify(result);
        Log    Step 2 validation errors: ${errors2}    console=yes
        Fail    Could not advance from Shipping to Preview. Errors: ${errors2}
    END
    Capture Page Screenshot    e2e_simorder_step3.png
    # Check the T&C checkbox explicitly before submitting
    ${tc_cb}=    Set Variable    xpath=//input[@id='termsAndConditions']
    ${tc_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${tc_cb}    10s
    IF    ${tc_visible}
        Execute Javascript
        ...    var cb = document.getElementById('termsAndConditions');
        ...    if(cb && !cb.checked){ cb.checked=true; cb.dispatchEvent(new Event('change',{bubbles:true})); }
        Log    T&C checkbox checked.    console=yes
        Sleep    1s
    END
    # Click Submit
    ${submit_btn}=    Set Variable    xpath=//div[@id='optimization']//a[normalize-space()='Submit']
    Scroll To Element Via JS    ${submit_btn}
    Click Element Via JS    ${submit_btn}
    Log    Submit button clicked.    console=yes
    Sleep    5s
    # Handle T&C modal if it appears
    ${tc_modal}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//div[@id='termsConditionsPopup']    15s
    IF    ${tc_modal}
        Log    T&C modal appeared. Checking checkbox and clicking Continue...    console=yes
        Execute Javascript
        ...    var cb = document.querySelector('#termsConditionsPopup input#termsAndConditions');
        ...    if(cb && !cb.checked){ cb.checked=true; cb.dispatchEvent(new Event('change',{bubbles:true})); }
        Sleep    1s
        ${continue_btn}=    Set Variable    xpath=//button[@id='prceedBtnGeneralAPN']
        Wait Until Element Is Visible    ${continue_btn}    10s
        Click Element Via JS    ${continue_btn}
        Log    T&C Continue clicked.    console=yes
        Sleep    5s
    END
    Wait For Loading Overlay To Disappear
    # Wait longer for redirect — order processing can be slow
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    12x    10s    Location Should Contain    LiveOrder
    IF    ${redirected}
        ${current_url}=    Get Location
        ${still_create}=    Evaluate    'Create' in '''${current_url}'''
        IF    ${still_create}
            Log    URL contains both LiveOrder and Create — not fully redirected yet.    console=yes
            Sleep    10s
        END
    END
    ${current_url}=    Get Location
    Log    Post-submit URL: ${current_url}    console=yes
    ${on_live}=    Evaluate    'LiveOrder' in '''${current_url}''' and 'Create' not in '''${current_url}'''
    IF    not ${on_live}
        Capture Page Screenshot    e2e_simorder_submit_fail.png
        ${errors3}=    Execute Javascript
        ...    var errs = document.querySelectorAll('.text-danger, .error, .toast-error, .Toastify__toast--error, .alert-danger, [class*="error"]');
        ...    var result = [];
        ...    errs.forEach(function(e){ if(e.offsetParent!==null) result.push(e.textContent.trim()); });
        ...    return JSON.stringify(result);
        Log    Post-submit errors: ${errors3}    console=yes
        # Check if still on preview or on step 2
        ${page_html}=    Execute Javascript
        ...    var opt = document.querySelector('#optimization');
        ...    if(opt && opt.offsetParent) return 'ON_PREVIEW';
        ...    var stg = document.querySelector('#strategy');
        ...    if(stg && stg.offsetParent) return 'ON_SHIPPING';
        ...    var disc = document.querySelector('#discover');
        ...    if(disc && disc.offsetParent) return 'ON_ORDER_DETAILS';
        ...    return 'UNKNOWN';
        Log    Current visible step: ${page_html}    console=yes
        Fail    SIM Order not created — still on ${current_url}. Step: ${page_html}. Errors: ${errors3}
    END
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    ${row_count}=    SeleniumLibrary.Get Element Count    ${LOC_SO_GRID_ROWS}
    Log    LiveOrder grid has ${row_count} order(s). SIM Order created successfully.    console=yes
    Should Be True    ${row_count} > 0
    ...    LiveOrder grid is empty after submitting SIM Order.
    Log    E2E SIM Order created with quantity=10 for BU="${bu_name}" under EC="${ec_name}"    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 7: CAPTURE ORDER ID FROM LIVE ORDER GRID
# ═══════════════════════════════════════════════════════════════════════
E2E Capture Order ID
    [Documentation]    Navigates to Live Order tab, searches for the BU account name,
    ...                and reads the Order Number column from the first matching row.
    [Arguments]    ${bu_name}
    Ensure Session Is Active
    Go To    ${LIVE_ORDER_URL}
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    ${order_id}=    Capture Order Number From Grid    ${bu_name}
    Log    ===== CAPTURED ORDER NUMBER: ${order_id} for account ${bu_name} =====    console=yes
    Capture Page Screenshot    e2e_order_id_captured.png
    RETURN    ${order_id}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 8: FETCH EC & BU ACCOUNT IDS FROM DATABASE
# ═══════════════════════════════════════════════════════════════════════
E2E Fetch Account IDs From DB
    [Documentation]    Connects to the STC database, fetches the EC and BU account IDs
    ...                by name, then closes the connection immediately.
    [Arguments]    ${ec_name}    ${bu_name}
    Connect To STC Database
    ${ec_id}=    Fetch Account ID By Name    ${ec_name}
    ${bu_id}=    Fetch Account ID By Name    ${bu_name}
    Disconnect From STC Database
    Log    ===== ACCOUNT IDS FROM DB =====    console=yes
    Log    EC "${ec_name}" → ID: ${ec_id}    console=yes
    Log    BU "${bu_name}" → ID: ${bu_id}    console=yes
    RETURN    ${ec_id}    ${bu_id}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 9: SSH — RUN start_createorder.sh
# ═══════════════════════════════════════════════════════════════════════
E2E Run Create Order Script
    [Documentation]    SSH → run start_createorder.sh → validate → always close SSH.
    ...                If exit code is 0, passes even if output contains "Permission denied"
    ...                (server-side log4j log file permission; order processing still succeeds).
    Connect To Order Processing Server
    TRY
        ${output}    ${rc}=    Run Create Order Script On Server
        Log    Validating start_createorder.sh execution...    console=yes
        Should Not Contain    ${output}    No such file
        ...    msg=start_createorder.sh: File not found
        Should Be Equal As Integers    ${rc}    0
        ...    msg=start_createorder.sh exited with code ${rc} (expected 0)
        IF    "Permission denied" in "${output}"
            Log    WARN: Output contains 'Permission denied' (often log/logging.log on server) — script still exited 0.    level=WARN    console=yes
        END
        Log    start_createorder.sh executed successfully (exit code: ${rc}).    console=yes
    FINALLY
        Close Order Processing Server Connection
        Log    SSH closed.    console=yes
    END
    RETURN    ${output}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 10: VALIDATE ORDER STATUS — New → In Progress
# ═══════════════════════════════════════════════════════════════════════
E2E Validate Order Status New To In Progress
    [Documentation]    Waits 2 minutes for server-side processing, then validates order
    ...                status changed to In Progress on Live Order tab.
    [Arguments]    ${order_id}
    Log    Waiting 2 minutes for server to process create order...    console=yes
    Sleep    120s    reason=Waiting 2 min after start_createorder.sh
    Validate Order Status In Live Order Grid    ${order_id}    ${STATUS_IN_PROGRESS}
    Capture Page Screenshot    e2e_order_status_in_progress.png
    Log    Order ${order_id} status confirmed: In Progress    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 11: GENERATE, UPLOAD & VERIFY RESPONSE FILES
# ═══════════════════════════════════════════════════════════════════════
E2E Generate And Upload Response Files
    [Documentation]    Generates 3 response files locally, opens SSH, uploads them,
    ...                verifies upload, then always closes SSH and cleans up locally.
    [Arguments]    ${order_id}
    ${file_pairs}=    Generate All Response Files    ${order_id}
    FOR    ${pair}    IN    @{file_pairs}
        Log    Generated: ${pair}[1] at ${pair}[0]    console=yes
    END
    Connect To Order Processing Server
    TRY
        Upload All Response Files To Server    ${file_pairs}
        Log    Verifying uploaded files on server...    console=yes
        Sleep    5s    reason=Brief wait after upload before verification
        Verify Files Uploaded On Server    ${order_id}    ${file_pairs}
        Log    All files uploaded and verified successfully.    console=yes
    FINALLY
        Close Order Processing Server Connection
        Log    SSH closed.    console=yes
    END
    Cleanup Local Response Files    ${file_pairs}
    Log    All 3 files uploaded, verified and SSH closed for order ${order_id}    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 12: SSH — RUN start_readorder.sh
# ═══════════════════════════════════════════════════════════════════════
E2E Run Read Order Script
    [Documentation]    SSH → run start_readorder.sh → validate → always close SSH.
    ...                If exit code is 0, passes even if output contains "Permission denied"
    ...                (server-side log4j log file permission; order processing still succeeds).
    Connect To Order Processing Server
    TRY
        ${output}    ${rc}=    Run Read Order Script On Server
        Log    Validating start_readorder.sh execution...    console=yes
        Should Not Contain    ${output}    No such file
        ...    msg=start_readorder.sh: File not found
        Should Be Equal As Integers    ${rc}    0
        ...    msg=start_readorder.sh exited with code ${rc} (expected 0)
        IF    "Permission denied" in "${output}"
            Log    WARN: Output contains 'Permission denied' (often log/logging.log on server) — script still exited 0.    level=WARN    console=yes
        END
        Log    start_readorder.sh executed successfully (exit code: ${rc}).    console=yes
    FINALLY
        Close Order Processing Server Connection
        Log    SSH closed.    console=yes
    END
    RETURN    ${output}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 13: VALIDATE ORDER STATUS — In Progress → Completed
# ═══════════════════════════════════════════════════════════════════════
E2E Validate Order Status Completed
    [Documentation]    Waits 2 minutes for server-side processing, then validates order
    ...                status changed to Completed on Order History tab.
    [Arguments]    ${order_id}
    Log    Waiting 2 minutes for server to process read order...    console=yes
    Sleep    120s    reason=Waiting 2 min after start_readorder.sh
    Validate Order Status In Order History    ${order_id}    ${STATUS_COMPLETED}
    Capture Page Screenshot    e2e_order_status_completed.png
    Log    Order ${order_id} status confirmed: Completed in Order History    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 14: VALIDATE SIMs IN WARM STATE ON MANAGE DEVICES
# ═══════════════════════════════════════════════════════════════════════
E2E Validate SIMs In Warm State
    [Documentation]    Navigates to Manage Devices, applies BU account filter for Warm state,
    ...                and validates all SIMs are Warm with count >= 10.
    [Arguments]    ${bu_name}
    Navigate To Manage Devices And Filter BU    ${bu_name}
    ${row_count}=    Validate All SIMs In Warm State
    Capture Page Screenshot    e2e_sims_warm_state.png
    Log    Step 14 complete: ${row_count} SIMs in Warm state for ${bu_name}    console=yes
    RETURN    ${row_count}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 15: SOAP API — UPDATE ORDER STATUS TO APPROVED
# ═══════════════════════════════════════════════════════════════════════
E2E Update Order Status To Approved
    [Documentation]    Calls the SOAP API to update the order status to Approved.
    ...                This transitions SIMs from Warm to InActive on the backend.
    ...                Waits 1 minute for the state change to propagate.
    [Arguments]    ${order_id}
    ${response}=    Call Update Order Status API    ${order_id}
    Log    SOAP API approved. Waiting 1 minute for SIM state change (Warm → InActive)...    console=yes
    Sleep    60s    reason=Waiting 1 min for SIM state to change after approval
    Log    Step 15 complete: Order ${order_id} approved. SIMs should now be InActive.    console=yes
    RETURN    ${response}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 16: ACTIVATE 5 SIMs (InActive → Activated) + CAPTURE IMSIs
# ═══════════════════════════════════════════════════════════════════════
E2E Activate SIMs And Capture IMSIs
    [Documentation]    Selects 5 InActive SIMs, activates them all in one go,
    ...                waits 5 min, then verifies each IMSI is Activated.
    ...                Returns two values: flat IMSI list and list of {imsi, msisdn} dicts.
    [Arguments]    ${bu_name}
    ${activated_imsis}    ${imsi_data}=    Activate SIMs From InActive State    ${bu_name}
    Log    Verifying all ${SIM_ACTIVATE_COUNT} SIMs are now Activated...    console=yes
    Verify Activated SIMs    ${activated_imsis}    ${bu_name}
    Capture Page Screenshot    e2e_all_sims_activated_verified.png
    Log    Step 16 complete: All ${SIM_ACTIVATE_COUNT} SIMs verified Activated for ${bu_name}    console=yes
    RETURN    ${activated_imsis}    ${imsi_data}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 17: INVOICE GENERATION + DOWNLOAD
# ═══════════════════════════════════════════════════════════════════════
E2E Generate And Download Invoice
    [Documentation]    Waits 5 min post-activation, calls Invoice API with BU account ID,
    ...                captures server timestamp, waits 2 min, then retries 3x/2min to find
    ...                and download a new invoice CSV created after the captured timestamp.
    ...                All sessions (HTTP + SSH) are closed at the end regardless of outcome.
    [Arguments]    ${bu_account_id}
    Log    Waiting 5 minutes after activation before invoice generation...    console=yes
    Sleep    300s    reason=5 min wait after SIM activation before invoice
    # Call Invoice API
    TRY
        ${response}=    Call Invoice API    ${bu_account_id}
        Log    Invoice API called successfully.    console=yes
    EXCEPT    AS    ${err}
        Delete All Sessions
        Fail    Invoice API failed: ${err}
    END
    # Connect to invoice server and capture timestamp before waiting
    TRY
        Connect To Invoice Server
        ${epoch}=    Capture Server Timestamp
        Log    Timestamp captured: ${epoch}. Waiting 2 minutes for invoice generation...    console=yes
        Sleep    120s    reason=2 min wait after invoice API call
        ${local_path}    ${filename}=    Download Invoice File With Retry    ${epoch}
        Capture Page Screenshot    e2e_invoice_downloaded.png
        Log    Step 17 complete: Invoice "${filename}" downloaded to ${local_path}    console=yes
    FINALLY
        SSHLibrary.Close All Connections
        Log    SSH connection closed.    console=yes
    END
    RETURN    ${local_path}    ${filename}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 16a/16b: USAGE — USER REQUEST + CDR FOR ALL IMSIs
# ═══════════════════════════════════════════════════════════════════════
E2E Perform Usage For All IMSIs
    [Documentation]    Calls User Request + CDR APIs for all activated IMSIs across
    ...                3 usage types (Data, SMS, Voice). 5 IMSIs × 3 types = 30 API calls.
    ...                HTTP sessions are cleaned up after each API call pair.
    [Arguments]    @{imsi_data}
    ${count}=    Get Length    ${imsi_data}
    Log    Step 16a/16b: Starting usage for ${count} IMSIs × 3 types = ${count * 3} iterations.    console=yes
    Perform Usage For All IMSIs    @{imsi_data}
    Log    Step 16a complete: All usage API calls finished.    console=yes

E2E Validate Usage In UI
    [Documentation]    After all usage APIs are called, navigates to Manage Devices and
    ...                validates DATA USAGE (MB), SMS USAGE, VOICE USAGE (MIN) columns
    ...                are > 0 for each IMSI. Converts CDR volume (bytes) to MB.
    [Arguments]    @{imsi_data}
    ${count}=    Get Length    ${imsi_data}
    Log    Step 16b: Validating usage in UI for ${count} IMSIs...    console=yes
    Validate Usage In UI For All IMSIs    @{imsi_data}
    Log    Step 16b complete: All ${count} IMSIs usage verified in UI.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 18: CREATE SECOND CSR JOURNEY (DIFFERENT TARIFF/APN/DEVICE PLAN)
#  Uses same account as E2E; different APN type (Private) and device plan alias.
# ═══════════════════════════════════════════════════════════════════════
E2E Create Second CSR Journey With Different Plan
    [Documentation]    Creates a second CSR Journey for the same EC/BU using DIFFERENT
    ...                tariff plan, APN type, and device plan alias than the first CSR (Step 3).
    ...                Reads what was saved in E2E_CSR1_TARIFF_PLAN / E2E_CSR1_APN_TYPE from
    ...                Step 3 and dynamically selects a different option for each field.
    [Arguments]    ${ec_name}    ${bu_name}
    Ensure Session Is Active
    Navigate To Module Page    ${BASE_URL}ManageDevices
    Wait For App Loading To Complete
    Navigate To CSR Journey Module
    Select CSR Journey Customer By Name    ${ec_name}
    Select CSR Journey Business Unit By Name    ${bu_name}
    Verify Create Order Button Visible
    Click Create Order
    Verify Standard Services Screen Loaded
    Select Tariff Plan Different From    ${E2E_CSR1_TARIFF_PLAN}
    csr_journey_keywords.Select APN Type    ${E2E_CSR1_APN_TYPE}
    Click Add APNs
    Save APN And IP Preference
    Click Fetch Device Plan
    Wait Until Element Is Visible    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_TIMEOUT}
    Wait For Bundle Plan Options To Load
    Select From List By Value    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_DEFAULT_BUNDLE_PLAN_2}
    Sleep    1s
    Log    Step 18 bundle plan selected: "${CSRJ_DEFAULT_BUNDLE_PLAN_2}"    console=yes
    Set Suite Variable    ${E2E_CSR2_BUNDLE_PLAN}    ${CSRJ_DEFAULT_BUNDLE_PLAN_2}
    ${csr2_alias}=    Enter Second Device Plan Alias
    Set Suite Variable    ${E2E_CSR2_DP_ALIAS}    ${csr2_alias}
    Fill And Save Service Plan
    Click Save On Standard Services Device Plan
    Click Next On Standard Services
    Verify Additional Services Screen Loaded
    Click Next On Additional Services
    Verify Summary Screen Loaded
    Click Save And Exit
    Verify CSR Journey Success Toast
    Verify Redirected To CSR Journey Landing
    Log    E2E second CSR Journey created for EC="${ec_name}" BU="${bu_name}"    console=yes
    Log    Captured Step 18 — Bundle plan: "${CSRJ_DEFAULT_BUNDLE_PLAN_2}", DP alias: "${csr2_alias}"    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 19: DEVICE PLAN CHANGE ON ONE ACTIVATED SIM + VALIDATE
#  Uses same account (E2E_BU_NAME) and one of E2E activated SIMs.
# ═══════════════════════════════════════════════════════════════════════
E2E Perform Device Plan Change On One Activated SIM And Validate
    [Documentation]    Navigates to Manage Devices and performs a device plan change.
    ...                Strategy (in priority order):
    ...                  1. If E2E_ACTIVATED_IMSIS is populated (from Steps 11-14), use the first
    ...                     captured IMSI to search the grid directly and perform the DP change.
    ...                  2. Otherwise fall back to filtering the grid by BU account + Activated state.
    ...                In both cases, Step 18's bundle plan (E2E_CSR2_BUNDLE_PLAN) is passed as
    ...                the preferred new DP so the correct plan is selected explicitly.
    ...                Validates that the grid shows the new DP after the change completes.
    [Arguments]    ${bu_name}
    Ensure Session Is Active
    Login And Navigate To Manage Devices DP
    Log    Step 19: Preferred new DP alias (from Step 18): "${E2E_CSR2_DP_ALIAS}"    console=yes
    ${has_imsis}=    Run Keyword And Return Status    Should Not Be Empty    ${E2E_ACTIVATED_IMSIS}
    ${is_list}=    Evaluate    isinstance($E2E_ACTIVATED_IMSIS, list)
    IF    ${has_imsis}
        ${target_imsi}=    Set Variable If    ${is_list}    ${E2E_ACTIVATED_IMSIS}[0]    ${E2E_ACTIVATED_IMSIS}
        Log    Step 19: Using captured activated IMSI "${target_imsi}" for DP change.    console=yes
        ${imsi}    ${dp1}    ${dp2}=    Perform Full Device Plan Change For IMSI
        ...    ${target_imsi}    ${E2E_CSR2_DP_ALIAS}
    ELSE
        Log    Step 19: No captured IMSI — falling back to account filter for "${bu_name}".    level=WARN    console=yes
        ${imsi}    ${dp1}    ${dp2}=    Perform Full Device Plan Change For Account
        ...    ${bu_name}    Activated    Activated    ${E2E_CSR2_DP_ALIAS}
    END
    IF    '${E2E_CSR2_DP_ALIAS}' != '${EMPTY}' and '${dp2}' != '${E2E_CSR2_DP_ALIAS}'
        Log    WARN: DP change picked "${dp2}" — preferred Step 18 alias "${E2E_CSR2_DP_ALIAS}" was not in dropdown. Proceeding with "${dp2}".    level=WARN    console=yes
    END
    Verify DP Change Success And Wait
    ${expected_dp}=    Set Variable If    '${E2E_CSR2_DP_ALIAS}' != '${EMPTY}'    ${E2E_CSR2_DP_ALIAS}    ${dp2}
    Log    Step 19: Validating Device Plan column shows "${expected_dp}" for IMSI ${imsi} after 6 min wait.    console=yes
    Verify Device Plan After Change    ${imsi}    ${expected_dp}
    Log    E2E DP change complete: IMSI ${imsi} changed "${dp1}" → "${expected_dp}".    console=yes
