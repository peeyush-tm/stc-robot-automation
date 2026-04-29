*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Library     ../../libraries/SeedWriter.py
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
Resource    sim_movement_keywords.resource
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
    Sleep    0.3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageUser
    Wait For App Loading To Complete
    Sleep    1s
    Scroll To Element Via JS    xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]
    Wait Until Element Is Visible    xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]    timeout=30s
    Click Element Via JS    xpath=//ul[@id='pageHeading']//a[contains(@href,'/ManageAccount')]
    Sleep    0.3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageAccount
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Sleep    0.3s
    Wait For App Loading To Complete
    Log    ManageAccount page loaded.    console=yes

Click Show Customer Wise Data Toggle
    [Documentation]    Clicks the "Show Customer Wise Data" toggle switch on the ManageAccount page.
    ...                The toggle is ON by default — clicking it turns it OFF so both EC and BU
    ...                accounts are visible in the grid.
    Sleep    1s
    Wait Until Element Is Visible    xpath=//label[@for='switch']    timeout=10s
    Click Element    xpath=//label[@for='switch']
    Log    "Show Customer Wise Data" toggle clicked (turning OFF).    console=yes
    Sleep    0.3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Sleep    1s
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
    Sleep    0.3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Sleep    1s
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
    ...                creates order, then delegates the wizard to ``CSRJ Complete Create Wizard Save And Exit Like E2E``
    ...                in ``csr_journey_keywords.resource`` (keeps UI flow aligned with CSR module keywords).
    ...                For deep regression (Save & Continue, field-level checks) see ``tests/csr_journey_tests.robot`` TC_CSRJ_004.
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
    ${csr1_bundle_actual}=    CSRJ Complete Create Wizard Save And Exit Like E2E
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
    Validate SIM Range Grid Row    ${pool_name}    ${iccid_from}    ${iccid_to}    ${imsi_from}    ${imsi_to}    ${EXPECTED_POOL_COUNT}

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
    Sleep    0.3s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    timeout=30s
    Sleep    1s
    # Scroll grid to the right to expose the assign icon
    Execute Javascript
    ...    var grid = document.querySelector('.k-grid-content'); if(grid) grid.scrollLeft = grid.scrollWidth;
    Sleep    1s
    # Try clicking the assign icon — retry with page refresh if it fails
    ${assign_ok}=    Run Keyword And Return Status
    ...    Click Assign Customer Icon On First Row
    IF    not ${assign_ok}
        Log    Assign icon click failed on first attempt. Refreshing page and retrying...    console=yes
        Go To    ${BASE_URL}ProductType
        Sleep    1s
        Wait For App Loading To Complete    timeout=60s
        Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    timeout=30s
        Sleep    1s
        Execute Javascript
        ...    var grid = document.querySelector('.k-grid-content'); if(grid) grid.scrollLeft = grid.scrollWidth;
        Sleep    1s
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
E2E SIM Order Stale Preview Resubmit
    [Documentation]    When the wizard stays on Preview (#optimization) with no visible errors, re-apply T&C,
    ...                Continue, and Submit once. Used by ``E2E Create SIM Order`` retry loop (PAYG Pool/Shared timing).
    Wait For Loading Overlay To Disappear
    Execute Javascript
    ...    var cb=document.getElementById('termsAndConditions');
    ...    if(cb&&!cb.checked){ var lbl=document.querySelector('label[for="termsAndConditions"]'); if(lbl) lbl.click(); else cb.click(); }
    Sleep    1s
    Execute Javascript
    ...    var btns=document.querySelectorAll('#optimization button');
    ...    for(var i=0;i<btns.length;i++){
    ...      var t=btns[i].textContent.trim().toLowerCase();
    ...      if(t==='continue'){ btns[i].disabled=false; btns[i].removeAttribute('disabled'); btns[i].click(); break; }
    ...    }
    Sleep    2s
    Wait For Loading Overlay To Disappear
    ${tc2}=    Execute Javascript
    ...    var m=document.querySelector('#termsConditionsPopup, .modal.show, .modal.in');
    ...    return !!(m && (m.offsetParent !== null || getComputedStyle(m).display !== 'none'));
    IF    ${tc2}
        Execute Javascript
        ...    var modal=document.querySelector('#termsConditionsPopup')||document.querySelector('.modal.show, .modal.in');
        ...    if(modal){ modal.querySelectorAll('input[type="checkbox"]').forEach(function(c){ if(!c.checked) c.click(); });
        ...      var bs=modal.querySelectorAll('button, a.btn');
        ...      for(var j=0;j<bs.length;j++){ var x=bs[j].textContent.trim().toLowerCase();
        ...        if(x.indexOf('proceed')>=0||x.indexOf('continue')>=0||x.indexOf('accept')>=0||x.indexOf('submit')>=0){ bs[j].click(); break; } }
        ...    }
        Sleep    2s
        Wait For Loading Overlay To Disappear
    END
    Execute Javascript
    ...    var as=document.querySelectorAll('#optimization a');
    ...    for(var i=0;i<as.length;i++){
    ...      if(as[i].textContent.trim().toLowerCase()==='submit'){ as[i].click(); break; }
    ...    }
    Sleep    2s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  STEP 5B: EXPAND EC AND BU SIM LIMITS (UI — ManageAccount)
# ═══════════════════════════════════════════════════════════════════════
E2E Expand EC And BU SIM Limits
    [Documentation]    Before SIM Order creation: open each account (EC then BU) in
    ...                ManageAccount, go to Account Settings page, click + Add IMSI /
    ...                + Add SIMs modal with the given increment, then Next → Update.
    ...                Required so the BU has SIM capacity headroom for the upcoming order.
    [Arguments]    ${ec_name}    ${bu_name}    ${increment}=10
    Ensure Session Is Active
    # ─── EC ───────────────────────────────────────────────
    ${ec_cur}=    SM Get EC Max IMSI Count    ${ec_name}
    ${ec_target}=    Evaluate    int(${ec_cur}) + int(${increment})
    Log    EC '${ec_name}': current Max IMSI=${ec_cur} → target=${ec_target}    console=yes
    SM Update EC Max IMSI    ${ec_name}    ${ec_target}
    # ─── BU ───────────────────────────────────────────────
    ${bu_cur}=    SM Get BU Max SIM Count    ${bu_name}
    ${bu_target}=    Evaluate    int(${bu_cur}) + int(${increment})
    Log    BU '${bu_name}': current Max SIM=${bu_cur} → target=${bu_target}    console=yes
    SM Update BU Max SIM    ${bu_name}    ${bu_target}
    Log    E2E SIM limits expanded: EC=${ec_target}, BU=${bu_target}    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 6: SIM ORDER (UI)
# ═══════════════════════════════════════════════════════════════════════
E2E Create SIM Order
    [Documentation]    Creates a SIM Order by selecting the onboarded BU account from the
    ...                treeview (KSA_OPCO > EC > BU) with configurable quantity (default 10).
    [Arguments]    ${ec_name}    ${bu_name}    ${quantity}=${10}
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_SIM_ORDER_URL}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_WIZARD_CONTAINER}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Set SIM Replacement Order    ${FALSE}
    Select BU Account From TreeView    ${ec_name}    ${bu_name}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # Wait extra for cascading dropdowns to populate after account selection
    Sleep    0.3s
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
    Sleep    0.3s
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
        Sleep    1s
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
    Enter Quantity    ${quantity}
    Set Activation Type    nonAutoActivation
    Sleep    0.3s
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
    Sleep    0.3s
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
    Sleep    0.3s
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
    # Dump preview page state for diagnostics
    ${preview_dump}=    Execute Javascript
    ...    var cbs = document.querySelectorAll('#optimization input[type="checkbox"]');
    ...    var cbArr = [];
    ...    cbs.forEach(function(c){ cbArr.push({id:c.id, name:c.name, checked:c.checked, visible:c.offsetParent!==null}); });
    ...    var btns = document.querySelectorAll('#optimization a, #optimization button');
    ...    var btnArr = [];
    ...    btns.forEach(function(b){ btnArr.push({text:b.textContent.trim(), tag:b.tagName, cls:b.className, disabled:b.disabled}); });
    ...    return JSON.stringify({checkboxes:cbArr, buttons:btnArr});
    Log    Preview page state: ${preview_dump}    console=yes
    # ── STEP A: Handle T&C checkbox FIRST (before any Submit attempt) ──
    # Reveal hidden T&C checkbox and click it via label (proper React state update)
    Execute Javascript
    ...    var cb = document.getElementById('termsAndConditions');
    ...    if(cb){
    ...        var p = cb.parentElement;
    ...        while(p && p !== document.body){
    ...            p.style.display = ''; p.style.visibility = 'visible';
    ...            p.style.opacity = '1'; p.style.height = 'auto';
    ...            p.style.overflow = 'visible';
    ...            if(p.classList) p.classList.remove('d-none','hidden','collapse');
    ...            p = p.parentElement;
    ...        }
    ...        cb.style.display = ''; cb.style.visibility = 'visible';
    ...        cb.style.width = '20px'; cb.style.height = '20px';
    ...        cb.style.opacity = '1'; cb.style.position = 'relative';
    ...    }
    Sleep    1s
    ${tc_checked}=    Execute Javascript
    ...    var cb = document.getElementById('termsAndConditions');
    ...    if(!cb) return false;
    ...    if(!cb.checked){
    ...        var lbl = document.querySelector('label[for="termsAndConditions"]');
    ...        if(lbl){ lbl.click(); } else { cb.click(); }
    ...    }
    ...    return cb.checked;
    Log    T&C checkbox checked: ${tc_checked}    console=yes
    IF    not ${tc_checked}
        Execute Javascript
        ...    var cb = document.getElementById('termsAndConditions');
        ...    if(cb && !cb.checked) cb.click();
        Sleep    1s
    END
    Sleep    2s
    # ── STEP B: Check if Continue became enabled, then click via Selenium ──
    ${continue_state}=    Execute Javascript
    ...    var btns = document.querySelectorAll('#optimization button');
    ...    for(var i=0; i<btns.length; i++){
    ...        var t = btns[i].textContent.trim().toLowerCase();
    ...        if(t==='continue') return JSON.stringify({disabled:btns[i].disabled});
    ...    }
    ...    return 'NOT_FOUND';
    Log    Continue button state after T&C: ${continue_state}    console=yes
    # Make Continue enabled if React didn't auto-enable it
    Execute Javascript
    ...    var btns = document.querySelectorAll('#optimization button');
    ...    for(var i=0; i<btns.length; i++){
    ...        var t = btns[i].textContent.trim().toLowerCase();
    ...        if(t==='continue'){ btns[i].disabled=false; btns[i].removeAttribute('disabled'); break; }
    ...    }
    # Discover the tag name of #optimization for diagnostics
    ${opt_tag}=    Execute Javascript
    ...    var el = document.getElementById('optimization');
    ...    return el ? el.tagName : 'NOT_FOUND';
    Log    DOM id optimization element tag: ${opt_tag}    console=yes
    # Click Continue via Selenium (use * instead of div to match any tag)
    ${continue_loc}=    Set Variable    xpath=//*[@id='optimization']//button[normalize-space()='Continue']
    ${continue_exists}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${continue_loc}    timeout=5s
    IF    ${continue_exists}
        Click Element    ${continue_loc}
        Log    Clicked Continue via Selenium.    console=yes
        Sleep    3s
    ELSE
        Log    Continue button not found via Selenium. Trying JS click...    console=yes    level=WARN
        Execute Javascript
        ...    var btns = document.querySelectorAll('#optimization button');
        ...    for(var i=0; i<btns.length; i++){
        ...        var t = btns[i].textContent.trim().toLowerCase();
        ...        if(t==='continue'){ btns[i].click(); break; } }
        Sleep    3s
    END
    # ── STEP C: Check if we moved to a new page or modal appeared ──
    ${tc_modal_visible}=    Execute Javascript
    ...    var m = document.querySelector('#termsConditionsPopup, .modal.show, .modal.in');
    ...    return !!(m && (m.offsetParent !== null || getComputedStyle(m).display !== 'none'));
    IF    ${tc_modal_visible}
        Log    T&C modal detected after Continue. Handling...    console=yes
        Capture Page Screenshot    e2e_simorder_tc_modal.png
        # Check modal checkboxes via click (not nativeSet)
        Execute Javascript
        ...    var modal = document.querySelector('#termsConditionsPopup') || document.querySelector('.modal.show, .modal.in');
        ...    if(modal){
        ...        var cbs = modal.querySelectorAll('input[type="checkbox"]');
        ...        cbs.forEach(function(cb){ if(!cb.checked) cb.click(); });
        ...    }
        Sleep    2s
        # Click Proceed/Continue button in modal
        ${proceed_result}=    Execute Javascript
        ...    var modal = document.querySelector('#termsConditionsPopup') || document.querySelector('.modal.show, .modal.in');
        ...    if(!modal) return 'NO_MODAL';
        ...    var btn = document.getElementById('prceedBtnGeneralAPN');
        ...    if(!btn) btn = document.getElementById('proceedBtn');
        ...    if(!btn){
        ...        var all = modal.querySelectorAll('button, a.btn');
        ...        for(var i=0; i<all.length; i++){
        ...            var t = all[i].textContent.trim().toLowerCase();
        ...            if(t.indexOf('proceed')>=0 || t.indexOf('continue')>=0 || t.indexOf('accept')>=0
        ...                || t.indexOf('confirm')>=0 || t.indexOf('submit')>=0 || t.indexOf('agree')>=0){
        ...                btn = all[i]; break;
        ...            }
        ...        }
        ...    }
        ...    if(btn){ btn.disabled=false; btn.removeAttribute('disabled'); btn.click();
        ...        return 'CLICKED:'+btn.id+':'+btn.textContent.trim(); }
        ...    return 'NO_PROCEED_BTN';
        Log    Proceed result: ${proceed_result}    console=yes
        Sleep    3s
    END
    # ── STEP D: Click Submit anchor via Selenium ──
    ${still_on_preview}=    Execute Javascript
    ...    var opt = document.querySelector('#optimization');
    ...    return !!(opt && opt.offsetParent);
    IF    ${still_on_preview}
        Log    Still on preview. Clicking Submit via Selenium...    console=yes
        ${submit_loc}=    Set Variable    xpath=//*[@id='optimization']//a[normalize-space()='Submit']
        ${submit_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${submit_loc}    timeout=5s
        IF    ${submit_exists}
            Click Element    ${submit_loc}
            Log    Clicked Submit anchor via Selenium.    console=yes
            Sleep    5s
        ELSE
            Log    Submit anchor not found via XPath. Trying CSS selector...    console=yes    level=WARN
            # Try finding Submit by CSS selector through Selenium
            ${submit_css}=    Set Variable    css=#optimization a.btn-custom-color
            ${css_found}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${submit_css}    timeout=3s
            IF    ${css_found}
                Click Element    ${submit_css}
                Log    Clicked Submit via CSS selector Selenium.    console=yes
            ELSE
                Execute Javascript
                ...    var btns = document.querySelectorAll('#optimization a');
                ...    for(var i=0; i<btns.length; i++){
                ...        var t = btns[i].textContent.trim().toLowerCase();
                ...        if(t==='submit'){ btns[i].click(); break; } }
                Log    JS fallback Submit clicked.    console=yes
            END
            Sleep    5s
        END
    END
    # ── STEP E: If another T&C modal appears after Submit, handle it ──
    ${tc_modal2}=    Execute Javascript
    ...    var m = document.querySelector('#termsConditionsPopup, .modal.show, .modal.in');
    ...    return !!(m && (m.offsetParent !== null || getComputedStyle(m).display !== 'none'));
    IF    ${tc_modal2}
        Log    Second T&C modal detected. Checking and proceeding...    console=yes
        Execute Javascript
        ...    var modal = document.querySelector('#termsConditionsPopup') || document.querySelector('.modal.show, .modal.in');
        ...    if(modal){
        ...        var cbs = modal.querySelectorAll('input[type="checkbox"]');
        ...        cbs.forEach(function(cb){ if(!cb.checked) cb.click(); });
        ...        var btns = modal.querySelectorAll('button, a.btn');
        ...        for(var i=0; i<btns.length; i++){
        ...            var t = btns[i].textContent.trim().toLowerCase();
        ...            if(t.indexOf('proceed')>=0 || t.indexOf('continue')>=0 || t.indexOf('accept')>=0
        ...                || t.indexOf('submit')>=0 || t.indexOf('agree')>=0){
        ...                btns[i].disabled=false; btns[i].click(); break;
        ...            }
        ...        }
        ...    }
        Sleep    3s
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
    FOR    ${retry_idx}    IN RANGE    3
        Exit For Loop If    ${on_live}
        Log    SIM Order still on Create flow — preview resubmit attempt index ${retry_idx}    console=yes
        E2E SIM Order Stale Preview Resubmit
        Run Keyword And Ignore Error
        ...    Wait Until Keyword Succeeds    8x    8s    Location Should Contain    LiveOrder
        ${current_url}=    Get Location
        ${on_live}=    Evaluate    'LiveOrder' in '''${current_url}''' and 'Create' not in '''${current_url}'''
    END
    Log    Post-submit URL (after preview retries): ${current_url}    console=yes
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
    Log    E2E SIM Order created with quantity=${quantity} for BU="${bu_name}" under EC="${ec_name}"    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  STEP 7: CAPTURE ORDER ID FROM LIVE ORDER GRID
# ═══════════════════════════════════════════════════════════════════════
E2E Capture Order ID
    [Documentation]    Navigates to Live Order tab, searches for the BU account name,
    ...                and reads the Order Number column from the first matching row.
    ...                DOM-presence check — the grid may be below the fold on new builds.
    [Arguments]    ${bu_name}
    Ensure Session Is Active
    Go To    ${LIVE_ORDER_URL}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Page Contains Element    ${LOC_SO_GRID}    timeout=30s
    Execute Javascript    var el = document.querySelector('#simOrderGrid, #gridData'); if(el) el.scrollIntoView({block:'start'});
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
    ...                Retries up to 3 times on transient OSError / socket errors.
    [Arguments]    ${ec_name}    ${bu_name}
    ${ec_id}=    Set Variable    ${EMPTY}
    ${bu_id}=    Set Variable    ${EMPTY}
    FOR    ${attempt}    IN RANGE    3
        TRY
            Connect To STC Database
            ${ec_id}=    Fetch Account ID By Name    ${ec_name}
            ${bu_id}=    Fetch Account ID By Name    ${bu_name}
            Disconnect From STC Database
            BREAK
        EXCEPT    OSError*    type=GLOB    AS    ${err}
            Log    DB query attempt ${attempt + 1} failed with OSError: ${err}. Retrying...    console=yes    level=WARN
            Run Keyword And Ignore Error    Disconnect From STC Database
            IF    ${attempt} >= 2
                Fail    DB query failed after 3 attempts: ${err}
            END
            Sleep    5s
        END
    END
    Log    ===== ACCOUNT IDS FROM DB =====    console=yes
    Log    EC "${ec_name}" → ID: ${ec_id}    console=yes
    Log    BU "${bu_name}" → ID: ${bu_id}    console=yes
    RETURN    ${ec_id}    ${bu_id}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 9: SSH — RUN start_createorder.sh
# ═══════════════════════════════════════════════════════════════════════
E2E Run Create Order Script
    [Documentation]    SSH → run start_createorder.sh → always close SSH.
    ...                Ignores script output errors; only checks that execution completed.
    Connect To Order Processing Server
    TRY
        ${output}    ${rc}=    Run Create Order Script On Server
        Log    start_createorder.sh executed (exit code: ${rc}).    console=yes
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
    [Documentation]    SSH → run start_readorder.sh → always close SSH.
    ...                Ignores script output errors; only checks that execution completed.
    Connect To Order Processing Server
    TRY
        ${output}    ${rc}=    Run Read Order Script On Server
        Log    start_readorder.sh executed (exit code: ${rc}).    console=yes
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
    ...                and validates all SIMs are Warm with count >= min_count (default 10).
    [Arguments]    ${bu_name}    ${min_count}=${10}
    Navigate To Manage Devices And Filter BU    ${bu_name}
    ${row_count}=    Validate All SIMs In Warm State    ${min_count}
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
    [Documentation]    Selects InActive SIMs (default ${SIM_ACTIVATE_COUNT}), activates them all in one go,
    ...                waits 5 min, then verifies each IMSI is Activated.
    ...                Writes ``first_activated_imsi``, ``first_activated_iccid``, and when present
    ...                ``second_activated_imsi`` / ``second_activated_iccid`` to .run_seed.json for downstream suites.
    ...                Returns two values: flat IMSI list and list of {imsi, msisdn, iccid} dicts.
    [Arguments]    ${bu_name}    ${count}=${SIM_ACTIVATE_COUNT}
    ${activated_imsis}    ${imsi_data}    ${activated_iccids}=    Activate SIMs From InActive State    ${bu_name}    ${count}
    Log    Verifying all ${count} SIMs are now Activated...    console=yes
    Verify Activated SIMs    ${activated_imsis}    ${bu_name}
    Capture Page Screenshot    e2e_all_sims_activated_verified.png
    # Persist activated IMSIs/ICCIDs for SIM Movement, Device Plan, Device State (full pipeline)
    ${iccid_count}=    Get Length    ${activated_iccids}
    ${imsi_count}=    Get Length    ${activated_imsis}
    IF    ${imsi_count} > 0
        ${first_imsi}=    Get From List    ${activated_imsis}    0
        Write Seed Value    first_activated_imsi    ${first_imsi}
        Log    Persisted first_activated_imsi=${first_imsi} to .run_seed.json    console=yes
    END
    IF    ${iccid_count} > 0
        ${first_iccid}=    Get From List    ${activated_iccids}    0
        Write Seed Value    first_activated_iccid    ${first_iccid}
        Log    Persisted first_activated_iccid=${first_iccid} to .run_seed.json    console=yes
    END
    IF    ${imsi_count} > 1
        ${second_imsi}=    Get From List    ${activated_imsis}    1
        Write Seed Value    second_activated_imsi    ${second_imsi}
        Log    Persisted second_activated_imsi=${second_imsi} to .run_seed.json    console=yes
    END
    IF    ${iccid_count} > 1
        ${second_iccid}=    Get From List    ${activated_iccids}    1
        Write Seed Value    second_activated_iccid    ${second_iccid}
        Log    Persisted second_activated_iccid=${second_iccid} to .run_seed.json    console=yes
    END
    Log    Step 16 complete: All ${SIM_ACTIVATE_COUNT} SIMs verified Activated for ${bu_name}    console=yes
    RETURN    ${activated_imsis}    ${imsi_data}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 17: INVOICE GENERATION + DOWNLOAD
# ═══════════════════════════════════════════════════════════════════════
E2E Generate And Download Invoice
    [Documentation]    Waits 5 min post-activation, captures server timestamp BEFORE calling
    ...                Invoice API so that any CSV created after the API call is guaranteed
    ...                to be newer than the captured epoch. Retries 3x/2min to find and
    ...                download the new invoice CSV. All sessions closed at the end.
    [Arguments]    ${bu_account_id}
    Log    Waiting 5 minutes after activation before invoice generation...    console=yes
    Sleep    300s    reason=5 min wait after SIM activation before invoice
    # Connect to invoice server and capture timestamp BEFORE calling the API
    # so any invoice file created after the API call is guaranteed to be newer.
    TRY
        Connect To Invoice Server
        ${epoch}=    Capture Server Timestamp
        Log    Timestamp captured BEFORE API call: ${epoch}    console=yes
    EXCEPT    AS    ${err}
        SSHLibrary.Close All Connections
        Fail    SSH connect / timestamp failed: ${err}
    END
    # Call Invoice API
    TRY
        ${response}=    Call Invoice API    ${bu_account_id}
        Log    Invoice API called successfully.    console=yes
    EXCEPT    AS    ${err}
        SSHLibrary.Close All Connections
        Delete All Sessions
        Fail    Invoice API failed: ${err}
    END
    # Wait for invoice generation and download
    TRY
        Log    Waiting 2 minutes for invoice generation...    console=yes
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
E2E Create CSR Journey With Specific Plans
    [Documentation]    Creates CSR Journey selecting tariff/bundle by name and Private APN by created name.
    ...                Uses CSRJ_DEFAULT_TARIFF_PLAN, CSRJ_DEFAULT_BUNDLE_PLAN, VALID_APN_NAME (Private type).
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
    Select Tariff Plan By Name    ${CSRJ_DEFAULT_TARIFF_PLAN}
    Wait For App Loading To Complete    timeout=30s
    Sleep    1s
    csr_journey_keywords.Select APN Type    ${CSRJ_APN_TYPE_PRIVATE}
    Click Add APNs
    Select First Available APN And Save    ${VALID_APN_NAME}
    Click Fetch Device Plan
    Wait Until Element Is Visible    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_TIMEOUT}
    Wait For Bundle Plan Options To Load
    ${bundle_ok}=    Run Keyword And Return Status
    ...    Select From List By Value    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_DEFAULT_BUNDLE_PLAN}
    IF    not ${bundle_ok}
        Log    Bundle "${CSRJ_DEFAULT_BUNDLE_PLAN}" not found by value — selecting first available.    level=WARN    console=yes
        Select Bundle Plan First Option
    END
    ${bundle_label}=    Get Selected List Label    ${LOC_SS_BUNDLE_PLAN_DD}
    Log    [RESULT] Bundle Plan selected: ${bundle_label}    console=yes
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
    Set Suite Variable    ${E2E_CSR1_APN_TYPE}        ${CSRJ_APN_TYPE_PRIVATE}
    Set Suite Variable    ${E2E_CSR1_APN_NAME}        ${VALID_APN_NAME}
    Set Suite Variable    ${E2E_CSR1_BUNDLE_PLAN}     ${bundle_label}
    Log    E2E CSR Journey created — Tariff: "${CSRJ_DEFAULT_TARIFF_PLAN}", APN: "${VALID_APN_NAME}" (Private), Bundle: "${bundle_label}"    console=yes

E2E Create Second CSR Journey With Different Plan
    [Documentation]    Creates a second CSR Journey for the same EC/BU using config variables:
    ...                CSRJ_DEFAULT_TARIFF_PLAN_2, CSRJ_DEFAULT_APN_TYPE_2,
    ...                CSRJ_DEFAULT_APN_NAME_2, CSRJ_DEFAULT_BUNDLE_PLAN_2.
    ...                Falls back to dynamic selection if any configured value is empty or not found.
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
    # ── Tariff Plan: use configured plan 2, fall back to "different from Step 3" ──
    ${has_tp2}=    Run Keyword And Return Status    Should Not Be Empty    ${CSRJ_DEFAULT_TARIFF_PLAN_2}
    IF    ${has_tp2}
        Select Tariff Plan By Name    ${CSRJ_DEFAULT_TARIFF_PLAN_2}
        Log    Step 18 tariff plan: "${CSRJ_DEFAULT_TARIFF_PLAN_2}" (from config)    console=yes
    ELSE
        Select Tariff Plan Different From    ${E2E_CSR1_TARIFF_PLAN}
    END
    # ── APN Type: use configured type 2 ──
    csr_journey_keywords.Select APN Type    ${CSRJ_DEFAULT_APN_TYPE_2}
    Log    Step 18 APN type: "${CSRJ_DEFAULT_APN_TYPE_2}"    console=yes
    Click Add APNs
    # ── APN: type configured APN name 2 into modal and select it ──
    Select First Available APN And Save    ${CSRJ_DEFAULT_APN_NAME_2}
    Click Fetch Device Plan
    Wait Until Element Is Visible    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_TIMEOUT}
    Wait For Bundle Plan Options To Load
    # ── Bundle Plan: use configured plan 2, fall back to different available ──
    ${items}=    Get List Items    ${LOC_SS_BUNDLE_PLAN_DD}    values=True
    Log    Step 18 bundle plan dropdown options: ${items}    console=yes
    ${preferred_ok}=    Run Keyword And Return Status
    ...    Select From List By Value    ${LOC_SS_BUNDLE_PLAN_DD}    ${CSRJ_DEFAULT_BUNDLE_PLAN_2}
    IF    not ${preferred_ok}
        Log    Configured plan "${CSRJ_DEFAULT_BUNDLE_PLAN_2}" not in dropdown — selecting a different available plan.    level=WARN
        ${selected}=    Select Different Bundle Plan From Available    ${LOC_SS_BUNDLE_PLAN_DD}    ${E2E_CSR1_BUNDLE_PLAN}
        Set Suite Variable    ${E2E_CSR2_BUNDLE_PLAN}    ${selected}
    ELSE
        Set Suite Variable    ${E2E_CSR2_BUNDLE_PLAN}    ${CSRJ_DEFAULT_BUNDLE_PLAN_2}
    END
    Sleep    1s
    Log    Step 18 bundle plan selected: "${E2E_CSR2_BUNDLE_PLAN}"    console=yes
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
    Log    E2E DP change complete: IMSI ${imsi} changed "${dp1}" → "${dp2}". Verified in grid: "${expected_dp}".    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  E2E SUSPEND / RESUME — single IMSI state change with 5 min wait
# ═══════════════════════════════════════════════════════════════════════
E2E Change SIM State
    [Documentation]    Navigates to Manage Devices, searches for the given IMSI, selects it,
    ...                performs a state change from ${from_state} to ${to_state},
    ...                waits for success toast, then waits 5 minutes for async processing.
    [Arguments]    ${bu_name}    ${imsi}    ${from_state}    ${to_state}
    Ensure Session Is Active
    Go To    ${MANAGE_DEVICES_URL_E2E}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Reset Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Search Device By IMSI    ${imsi}
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${actual_state}=    Get Cell Value By Row And Column    1    ${state_col}
    Should Be Equal As Strings    ${actual_state}    ${from_state}
    ...    Expected IMSI ${imsi} to be in "${from_state}" but grid shows "${actual_state}".
    Select Device By Row Index    ${0}
    Select Change State Action
    Select Target State And Submit    ${to_state}
    Fill Popup And Submit    ${from_state}    ${to_state}
    ${toast_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_TOAST_SUCCESS}    timeout=30s
    IF    ${toast_ok}
        ${toast_text}=    Get Text    ${LOC_DSC_TOAST_SUCCESS}
        Log    Success toast: ${toast_text}    console=yes
    ELSE
        Log    No success toast within 30s — proceeding.    level=WARN
    END
    ${popup_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_DSC_POPUP}    timeout=15s
    IF    not ${popup_gone}
        Run Keyword And Ignore Error    Click Element Via JS    ${LOC_DSC_POPUP_X_BTN}
        Sleep    1s
    END
    Capture Page Screenshot    e2e_state_change_${from_state}_to_${to_state}_${imsi}.png
    Log    State change ${from_state} → ${to_state} submitted for IMSI ${imsi}. Waiting 5 min...    console=yes
    Sleep    300s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  SIT-ONLY: POLLING KEYWORDS (used by TC_E2E_SIT_001/002)
# ═══════════════════════════════════════════════════════════════════════
E2E Verify Order Status In History
    [Documentation]    Single-attempt check: navigates to Order History, filters by BU+order,
    ...                and asserts status equals expected. Used with Wait Until Keyword Succeeds
    ...                for SIT polling (cron-driven completion).
    [Arguments]    ${bu_name}    ${order_id}    ${expected_status}
    Validate Order Status In Order History    ${order_id}    ${expected_status}

E2E Verify At Least One SIM In State
    [Documentation]    Single-attempt check: navigates to Manage Devices, filters by BU + state,
    ...                and asserts at least one SIM row is visible. Used with Wait Until Keyword
    ...                Succeeds for SIT polling (cron-driven InActive transition).
    [Arguments]    ${bu_name}    ${expected_state}
    Navigate To Manage Devices And Filter BU    ${bu_name}
    Apply SIM State Filter    ${expected_state}
    Wait Until Element Is Visible    xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]    timeout=15s
