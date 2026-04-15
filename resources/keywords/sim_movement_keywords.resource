*** Settings ***
Library     SeleniumLibrary
Library     Collections
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    device_state_keywords.resource
Resource    ../locators/sim_movement_locators.resource
Resource    ../locators/login_locators.resource
Resource    ../locators/device_state_locators.resource
Variables   ../../variables/sim_movement_variables.py
Variables   ../../variables/device_state_variables.py


*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION
# ═══════════════════════════════════════════════════════════════════════

SM Build URL
    [Documentation]    Builds a full URL without double-slash by stripping trailing slash from BASE_URL.
    [Arguments]    ${path}
    ${base}=    Evaluate    '${BASE_URL}'.rstrip('/')
    ${url}=    Set Variable    ${base}/${path}
    RETURN    ${url}

SM Navigate To Manage Devices
    [Documentation]    Ensures session is active, then navigates to /ManageDevices.
    Ensure Session Is Active
    ${url}=    SM Build URL    ${SM_MANAGE_DEVICES_PATH}
    Navigate To Module Page    ${url}
    Wait Until Element Is Visible    ${LOC_SM_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SM_GRID_ROWS}    timeout=30s
    SM Dismiss Personal Data Alert

SM Navigate To Account Module
    [Documentation]    Opens Admin → Account page (ManageAccount) via direct URL.
    Ensure Session Is Active
    ${url}=    SM Build URL    ${SM_MANAGE_ACCOUNT_PATH}
    Navigate To Module Page    ${url}
    Wait Until Element Is Visible    ${LOC_SM_ACCOUNT_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    1s
    SM Dismiss Personal Data Alert

SM Navigate To Audit Trail
    [Documentation]    Navigates to Application Logging → Audit Trail.
    Ensure Session Is Active
    ${url}=    SM Build URL    ${SM_MANAGE_AUDIT_PATH}
    Navigate To Module Page    ${url}
    Wait Until Element Is Visible    ${LOC_SM_AUDIT_GRID}    timeout=30s

SM Navigate To Batch Job Log
    [Documentation]    Navigates to Application Logging → Batch Job Log.
    Ensure Session Is Active
    ${url}=    SM Build URL    ${SM_BATCH_JOB_PATH}
    Navigate To Module Page    ${url}
    Wait Until Page Contains Element    ${LOC_SM_BATCH_GRID}    timeout=30s

SM Dismiss Personal Data Alert
    [Documentation]    Dismisses the personal data banner if it appears.
    ...                Uses JS click to avoid ElementNotInteractableException on the close button.
    ${present}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SM_PERSONAL_DATA_ALERT}
    IF    ${present}
        Sleep    0.5s
        Run Keyword And Ignore Error    Click Element Via JS    ${LOC_SM_ALERT_CLOSE}
        Sleep    0.5s
    END

# ═══════════════════════════════════════════════════════════════════════
#  ACCOUNT MODULE — EC / CUSTOMER SEARCH
# ═══════════════════════════════════════════════════════════════════════

SM Enable Customer Wise View
    [Documentation]    Enables the "Show Customer Wise Data" toggle (ON) for EC account search.
    ...                Clicks the label[@for='switch'] — same as E2E account onboard validation.
    Wait For Loading Overlay To Disappear
    ${checked}=    Get Element Attribute    ${LOC_SM_SHOW_CUST_TOGGLE}    checked
    IF    '${checked}' != 'true'
        Click Element    xpath=//label[@for='switch']
        Sleep    1s
        Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
        Wait For Loading Overlay To Disappear
    END

SM Disable Customer Wise View
    [Documentation]    Disables the "Show Customer Wise Data" toggle (OFF) for BU account search.
    ...                BU accounts only appear when toggle is OFF.
    ...                Clicks the label[@for='switch'] — same as E2E account onboard validation.
    Wait For Loading Overlay To Disappear
    ${checked}=    Get Element Attribute    ${LOC_SM_SHOW_CUST_TOGGLE}    checked
    IF    '${checked}' == 'true'
        Click Element    xpath=//label[@for='switch']
        Sleep    1s
        Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
        Wait For Loading Overlay To Disappear
    END

SM Search Account By Name
    [Documentation]    Types account name into the ManageAccount grid toolbar search input via JS,
    ...                presses ENTER, waits for grid reload, then validates via Kendo dataSource.
    ...                Uses the same approach as Search And Validate Account In Grid in e2e_keywords.
    [Arguments]    ${account_name}
    Wait For Loading Overlay To Disappear
    # Find the search input scoped to ManageAccountGrid container (not global search bar)
    ${input_loc}=    Set Variable
    ...    xpath=//div[@id='ManageAccountGrid']/ancestor::div[contains(@class,'card') or contains(@class,'panel') or contains(@class,'content')]//input[@type='text' or @type='search' or not(@type)][not(contains(@placeholder,'Search Device'))][not(ancestor::nav)][not(ancestor::header)]
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${input_loc}    timeout=10s
    IF    not ${input_visible}
        ${input_loc}=    Set Variable
        ...    xpath=//input[not(contains(@placeholder,'Search Device'))][not(ancestor::nav)][not(ancestor::*[contains(@class,'navbar')])][@type='text' or @type='search' or not(@type)]
        Wait Until Element Is Visible    ${input_loc}    timeout=10s
    END
    Clear Element Text    ${input_loc}
    Input Text    ${input_loc}    ${account_name}
    Press Keys    ${input_loc}    RETURN
    Sleep    1s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Wait For Loading Overlay To Disappear
    # Validate via Kendo grid dataSource (same as E2E account onboard validation)
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
        Page Should Contain    ${account_name}
        ...    msg=Account "${account_name}" not found in ManageAccount grid after search.
    END
    Log    Account "${account_name}" found in ManageAccount grid.    console=yes

SM Expand Account Row
    [Documentation]    Expands an account row in the Manage Account grid by name.
    ...                Uses JS click to avoid loading overlay interception.
    [Arguments]    ${account_name}
    ${expand}=    Set Variable
    ...    //div[@id='ManageAccountGrid']//td[contains(normalize-space(text()),'${account_name}')]/preceding-sibling::td[contains(@class,'k-hierarchy-cell')]//a
    Wait For Loading Overlay To Disappear
    Click Element Via JS    xpath=${expand}

SM Open Account Edit Form
    [Documentation]    Opens the Edit form for the given account name in ManageAccount grid.
    ...                After SM Search Account By Name filters to one row, clicks the first
    ...                Kendo edit icon (i.k-grid-Edit) in the grid. Uses JS click for off-viewport.
    [Arguments]    ${account_name}
    # After search, grid is filtered to one matching row — click the first edit icon
    ${edit_btn}=    Set Variable    xpath=//div[@id='ManageAccountGrid']//i[contains(@class,'k-grid-Edit') or @title='Edit'][1]
    Wait Until Page Contains Element    ${edit_btn}    timeout=10s
    Click Element Via JS    ${edit_btn}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

SM Close Account Edit Form
    [Documentation]    Closes the account edit wizard using the Close button.
    ...                Uses JS text search — same approach as SM Click Wizard Button By Text.
    Execute Javascript
    ...    var els = document.querySelectorAll('button, input[type="button"], a, input[type="submit"]');
    ...    for(var i=0; i<els.length; i++){
    ...        var t = (els[i].textContent || els[i].value || '').trim();
    ...        if((t === 'Close' || t === 'Cancel') && els[i].offsetParent !== null){
    ...            els[i].click(); return;
    ...        }
    ...    }
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

SM Click Wizard Button By Text
    [Documentation]    Finds and clicks a wizard button (Next/Previous/Update/Close) by its
    ...                visible text using JavaScript — handles button, input[type=button], and
    ...                anchor elements regardless of exact element type (same app pattern as
    ...                btn-custom-color / btn-cancel-color used across all modules).
    [Arguments]    ${btn_text}
    ${clicked}=    Execute Javascript
    ...    var els = document.querySelectorAll('button, input[type="button"], a, input[type="submit"]');
    ...    for(var i=0; i<els.length; i++){
    ...        var t = (els[i].textContent || els[i].value || '').trim();
    ...        if(t === '${btn_text}' && els[i].offsetParent !== null){
    ...            els[i].click(); return true;
    ...        }
    ...    }
    ...    return false;
    Should Be True    ${clicked}    msg=Wizard button '${btn_text}' not found or not visible in DOM
    Sleep    1.5s
    Wait For Loading Overlay To Disappear

SM Navigate Wizard To Account Settings Page
    [Documentation]    Clicks Next ONCE from wizard page 1 to reach the Account Settings page
    ...                where Max No IMSI / Max SIM fields are located.
    SM Click Wizard Button By Text    Next

SM Navigate Wizard To Update And Save
    [Documentation]    Wizard save path: Next until Update is shown → click Update.
    ...                Persisted changes require this full flow; redirect alone does not guarantee save.
    ...                After Update, MUST see a success toast — not inferred from URL/grid only.
    FOR    ${i}    IN RANGE    5
        ${has_update}=    Execute Javascript
        ...    var els = document.querySelectorAll('button, input[type="button"], a, input[type="submit"]');
        ...    for(var i=0; i<els.length; i++){
        ...        var t = (els[i].textContent || els[i].value || '').trim();
        ...        if(t === 'Update' && els[i].offsetParent !== null) return true;
        ...    }
        ...    return false;
        IF    ${has_update}    BREAK
        SM Click Wizard Button By Text    Next
    END
    SM Click Wizard Button By Text    Update
    Sleep    1s
    # ── Success toast required — values are not reliably saved without it ───
    ${toast_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'Toastify__toast--success')]
    ...    timeout=15s
    IF    not ${toast_ok}
        ${toast_ok}=    Run Keyword And Return Status
        ...    Wait Until Page Contains Element
        ...    xpath=//div[contains(@class,'Toastify__toast--success')]//div[contains(@class,'Toastify__toast-body')]
        ...    timeout=5s
    END
    Should Be True    ${toast_ok}
    ...    msg=Account update did NOT show a success toast — save may have failed (complete Next→Update flow; do not rely on redirect only).
    Log    SUCCESS: Account update confirmed via success toast.    console=yes
    # ── After toast: wait for wizard close and ManageAccount (expected navigation) ──
    Wait Until Location Contains    ManageAccount    timeout=15s
    Wait Until Element Is Visible    id=ManageAccountGrid    timeout=30s
    Wait For Loading Overlay To Disappear
    Log    Wizard closed. Back on ManageAccount grid.    console=yes

SM Get Field Value By Label
    [Documentation]    Finds an input field by scanning for a label whose text matches
    ...                ${label_text}. Handles label[for=id], sibling input, and parent-scoped
    ...                input — works regardless of the actual ID/name attribute on the field.
    ...                Match uses an alphanumeric key so "Max SIM No." matches "Max SIM No.: *" in DOM.
    ...                Returns the field value string, or EMPTY if not found.
    [Arguments]    ${label_text}
    ${value}=    Execute Javascript
    ...    function smLabelKey(s){ return (s||'').toLowerCase().replace(/[^a-z0-9]+/g,''); }
    ...    var want = smLabelKey('${label_text}');
    ...    var labels = document.querySelectorAll('label, td, th, span, div.form-label, div.control-label');
    ...    for(var i=0; i<labels.length; i++){
    ...        var t = labels[i].textContent.trim();
    ...        if(smLabelKey(t) === want){
    ...            var forId = labels[i].getAttribute ? labels[i].getAttribute('for') : null;
    ...            if(forId){ var inp = document.getElementById(forId); if(inp && inp.tagName==='INPUT') return inp.value; }
    ...            var sibling = labels[i].nextElementSibling;
    ...            while(sibling){ if(sibling.tagName==='INPUT') return sibling.value; var nested = sibling.querySelector('input'); if(nested) return nested.value; sibling=sibling.nextElementSibling; }
    ...            var parent = labels[i].parentElement;
    ...            if(parent){ var inp = parent.querySelector('input'); if(inp) return inp.value; }
    ...            var row = labels[i].closest('tr, .form-group, .row, .col');
    ...            if(row){ var inp = row.querySelector('input[type="text"],input[type="number"],input:not([type="checkbox"]):not([type="radio"])'); if(inp) return inp.value; }
    ...        }
    ...    }
    ...    return '';
    RETURN    ${value}

SM Get Field Value By Labels
    [Documentation]    Tries each label with SM Get Field Value By Label; returns first non-empty value.
    [Arguments]    @{labels}
    FOR    ${label}    IN    @{labels}
        ${v}=    SM Get Field Value By Label    ${label}
        IF    '${v}' != ''
            RETURN    ${v}
        END
    END
    RETURN    ${EMPTY}

SM Set Field Value By Label
    [Documentation]    Finds an input field by its label text, marks it with a temporary
    ...                data attribute, then uses Robot Framework's Input Text (real keyboard
    ...                simulation) so AngularJS two-way binding is properly triggered.
    ...                Falls back to AngularJS ngModel.$setViewValue if ng-model is present.
    [Arguments]    ${label_text}    ${new_value}
    # Step 1: Mark the input element with a temporary attribute so RF can locate it
    ${marked}=    Execute Javascript
    ...    function smLabelKey(s){ return (s||'').toLowerCase().replace(/[^a-z0-9]+/g,''); }
    ...    var want = smLabelKey('${label_text}');
    ...    var labels = document.querySelectorAll('label, td, th, span, div.form-label, div.control-label');
    ...    for(var i=0; i<labels.length; i++){
    ...        var t = labels[i].textContent.trim();
    ...        if(smLabelKey(t) === want){
    ...            var forId = labels[i].getAttribute ? labels[i].getAttribute('for') : null;
    ...            var inp = null;
    ...            if(forId) inp = document.getElementById(forId);
    ...            if(!inp){ var sib = labels[i].nextElementSibling; while(sib){ if(sib.tagName==='INPUT'){inp=sib;break;} var n=sib.querySelector('input'); if(n){inp=n;break;} sib=sib.nextElementSibling; } }
    ...            if(!inp){ var row=labels[i].closest('tr,.form-group,.row,.col'); if(row) inp=row.querySelector('input[type="text"],input[type="number"],input:not([type="checkbox"]):not([type="radio"])'); }
    ...            if(inp){ inp.setAttribute('data-sm-edit-target','1'); return true; }
    ...        }
    ...    }
    ...    return false;
    Should Be True    ${marked}    msg=Could not find input field for label '${label_text}'
    # Step 2: Use RF Input Text (triggers real keyboard events, AngularJS detects this)
    ${field_loc}=    Set Variable    xpath=//input[@data-sm-edit-target='1']
    Wait Until Page Contains Element    ${field_loc}    timeout=10s
    Scroll To Element Via JS    ${field_loc}
    Click Element Via JS    ${field_loc}
    Sleep    0.5s
    Press Keys    ${field_loc}    CTRL+a
    Input Text    ${field_loc}    ${new_value}
    # Step 3: Fire change event to ensure AngularJS dirty-checks the new value
    Execute Javascript
    ...    var inp = document.querySelector('[data-sm-edit-target="1"]');
    ...    if(inp){
    ...        var ngEl = typeof angular !== 'undefined' ? angular.element(inp) : null;
    ...        var ngModel = ngEl ? ngEl.controller('ngModel') : null;
    ...        if(ngModel){ ngModel.$setViewValue('${new_value}'); ngModel.$render(); var sc=ngEl.scope(); if(sc) sc.$apply(); }
    ...        else { inp.dispatchEvent(new Event('input',{bubbles:true})); inp.dispatchEvent(new Event('change',{bubbles:true})); }
    ...        inp.removeAttribute('data-sm-edit-target');
    ...    }
    Sleep    0.5s
    Log    Field '${label_text}' set to '${new_value}' via Input Text + AngularJS binding.    console=yes

SM Get EC Max IMSI Count
    [Documentation]    Opens EC Edit wizard → Account Settings → reads max IMSI/SIM limit
    ...                (Max No IMSI or Max SIM No. depending on tenant UI).
    [Arguments]    ${ec_name}
    SM Navigate To Account Module
    SM Enable Customer Wise View
    SM Search Account By Name    ${ec_name}
    SM Open Account Edit Form    ${ec_name}
    SM Navigate Wizard To Account Settings Page
    ${max_imsi_str}=    SM Get Field Value By Labels    Max No IMSI    Max SIM No.
    IF    '${max_imsi_str}' == ''
        Log    Max IMSI / Max SIM No. label not found on Account Settings page (EC)    WARN
        SM Close Account Edit Form
        RETURN    0
    END
    ${max_imsi}=    Convert To Integer    ${max_imsi_str}
    Log    Max No IMSI for EC '${ec_name}': ${max_imsi}    console=yes
    SM Close Account Edit Form
    RETURN    ${max_imsi}

SM Get BU Max SIM Count
    [Documentation]    Opens BU Edit wizard → Account Settings → reads "Max SIM No." (BU limit);
    ...                falls back to "Max No IMSI" if present. Disables Customer Wise View first.
    [Arguments]    ${bu_name}
    SM Navigate To Account Module
    SM Disable Customer Wise View
    SM Search Account By Name    ${bu_name}
    SM Open Account Edit Form    ${bu_name}
    SM Navigate Wizard To Account Settings Page
    ${max_sim_str}=    SM Get Field Value By Labels    Max SIM No.    Max No IMSI
    IF    '${max_sim_str}' == ''
        Log    Max SIM No. / Max No IMSI label not found on Account Settings page (BU)    WARN
        SM Close Account Edit Form
        RETURN    0
    END
    ${max_sim}=    Convert To Integer    ${max_sim_str}
    Log    Max SIM for BU '${bu_name}' (Max SIM No. / Account Settings): ${max_sim}    console=yes
    SM Close Account Edit Form
    RETURN    ${max_sim}

SM Get BU Current SIM Count
    [Documentation]    Counts the rows in Manage Devices filtered to the given BU.
    [Arguments]    ${bu_name}
    SM Navigate To Manage Devices
    Open Filter Popup
    Apply Account Filter    ${bu_name}
    Close Filter Popup
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    ${count}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    Log    Current SIM count in BU '${bu_name}': ${count}    console=yes
    RETURN    ${count}

SM Check And Expand EC IMSI Capacity If Needed
    [Documentation]    EC Max IMSI vs Manage Devices row count. If Max IMSI > row_count → no wizard/modal.
    ...                If Max IMSI <= row_count → target max = (row_count + 1); modal uses delta = (target − current).
    [Arguments]    ${ec_name}    ${row_count}
    ${max_imsi}=    SM Get EC Max IMSI Count    ${ec_name}
    Log    EC '${ec_name}' — Max IMSI: ${max_imsi}, Grid row count: ${row_count}    console=yes
    IF    ${max_imsi} > ${row_count}
        Log    EC Max IMSI (${max_imsi}) > row count (${row_count}) — no limit update.    console=yes
        RETURN    ${max_imsi}
    END
    ${target_max}=    Evaluate    ${row_count} + 1
    Log    EC Max IMSI (${max_imsi}) <= row count (${row_count}) — raising to ${target_max} (row count + 1).    console=yes
    SM Update EC Max IMSI    ${ec_name}    ${target_max}
    RETURN    ${target_max}

SM Check And Expand BU Max SIM If Needed
    [Documentation]    BU max vs SIM rows on that BU. If max > row_count → no update.
    ...                If max <= row_count → target = min(row_count + 1, ec_max_cap). BU must not exceed EC max IMSI.
    [Arguments]    ${bu_name}    ${row_count}    ${ec_max_cap}=999999
    ${max_sim}=    SM Get BU Max SIM Count    ${bu_name}
    ${need}=    Evaluate    ${row_count} + 1
    ${target_max}=    Evaluate    min(${need}, int(${ec_max_cap}))
    Log    BU '${bu_name}' — max=${max_sim}, rows=${row_count}, EC cap=${ec_max_cap}, target max=${target_max}    console=yes
    IF    ${max_sim} > ${row_count}
        Log    BU max (${max_sim}) > row count (${row_count}) — no limit update.    console=yes
        RETURN    ${max_sim}
    END
    IF    ${target_max} <= ${max_sim}
        Fail
        ...    Cannot expand BU '${bu_name}': need headroom above ${row_count} SIM(s) but BU max capped at ${target_max} (EC max IMSI=${ec_max_cap}). Raise EC Max IMSI in TC_SM_002 first.
    END
    Log    BU max (${max_sim}) <= row count (${row_count}) — updating to ${target_max}.    console=yes
    SM Update BU Max SIM    ${bu_name}    ${target_max}
    RETURN    ${target_max}

SM Click Add Limit Button And Input Delta
    [Documentation]    Handles the "+ Add IMSI" (EC) / "+ Add SIMs" (BU) modal flow.
    ...                Confirmed element types from app HTML inspection:
    ...                  - Link to open modal : <span> with text "${add_btn_text}"
    ...                  - Modal input        : <input name="maxNoOfSIM" type="number">
    ...                  - Confirm button     : <a normalize-space()='Add'>
    [Arguments]    ${add_btn_text}    ${delta}=1
    # Step 0: Scroll wizard Account Settings so Max limit row (+ Add IMSI / + Add SIMs) is in view
    Execute Javascript
    ...    function inAddCountOnlyPopup(el){
    ...        var m = el.closest('.modal');
    ...        if(!m) return false;
    ...        var st = window.getComputedStyle(m);
    ...        if(st.display === 'none' || st.visibility === 'hidden' || m.offsetParent === null) return false;
    ...        var titleEl = m.querySelector('.modal-title');
    ...        if(titleEl){
    ...            var title = (titleEl.textContent || '').replace(/\\s+/g,' ').trim();
    ...            if(title.indexOf('Add IMSIs Count') >= 0 || title.indexOf('Add SIMs Count') >= 0) return true;
    ...        }
    ...        var hdr = m.querySelector('.modal-header');
    ...        if(hdr){
    ...            var ht = (hdr.textContent || '').replace(/\\s+/g,' ').trim().split(/\\n/)[0].trim();
    ...            if(ht.indexOf('Add IMSIs Count') >= 0 || ht.indexOf('Add SIMs Count') >= 0) return true;
    ...        }
    ...        return false;
    ...    }
    ...    var list = document.querySelectorAll('input[name="maxNoOfSIM"]');
    ...    for(var i=0; i<list.length; i++){
    ...        var inp = list[i];
    ...        if(inp.offsetParent === null) continue;
    ...        if(inAddCountOnlyPopup(inp)) continue;
    ...        inp.scrollIntoView({block:'center', inline:'nearest'});
    ...        break;
    ...    }
    Sleep    0.5s
    Wait For Loading Overlay To Disappear
    # Step 1: Click the "+ Add IMSI" / "+ Add SIMs" SPAN link via full mouse event dispatch
    ${tag_found}=    Execute Javascript
    ...    var allEls = document.querySelectorAll('a, button, span, label, small, em, strong, i, p');
    ...    for(var i=0; i<allEls.length; i++){
    ...        var el = allEls[i];
    ...        if(el.offsetParent === null) continue;
    ...        var t = (el.textContent || '').trim();
    ...        if(t === '${add_btn_text}'){
    ...            el.scrollIntoView({block:'center', inline:'nearest'});
    ...            el.dispatchEvent(new MouseEvent('mouseenter',{bubbles:true,cancelable:true}));
    ...            el.dispatchEvent(new MouseEvent('mouseover',{bubbles:true,cancelable:true}));
    ...            el.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true}));
    ...            el.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true}));
    ...            el.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true}));
    ...            return el.tagName + ':' + el.className;
    ...        }
    ...    }
    ...    return '';
    Should Not Be Empty    ${tag_found}    msg=Link '${add_btn_text}' not found on page
    Log    Clicked '${add_btn_text}' on: ${tag_found}    console=yes
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # Step 2: Wait for the modal input — stable locator: name="maxNoOfSIM"
    Wait Until Page Contains Element    xpath=//input[@name='maxNoOfSIM']    timeout=10s
    Capture Page Screenshot    sm_add_imsi_modal.png
    # Step 2b: Scroll modal input into view before interact (popup may be off-viewport)
    Execute Javascript
    ...    var list = document.querySelectorAll('input[name="maxNoOfSIM"]');
    ...    for(var i=list.length-1; i>=0; i--){
    ...        if(list[i].offsetParent !== null){ list[i].scrollIntoView({block:'center', inline:'nearest'}); break; }
    ...    }
    Sleep    0.3s
    # Step 3: Clear "0" and type delta into the number input
    Click Element Via JS    xpath=//input[@name='maxNoOfSIM']
    Sleep    0.3s
    Press Keys    xpath=//input[@name='maxNoOfSIM']    CTRL+a
    Input Text    xpath=//input[@name='maxNoOfSIM']    ${delta}
    # Step 4: Fire Angular ngModel so AngularJS registers the typed value
    Execute Javascript
    ...    var inp = document.querySelector('input[name="maxNoOfSIM"]');
    ...    if(inp){
    ...        var ngEl = (typeof angular !== 'undefined') ? angular.element(inp) : null;
    ...        var ngModel = ngEl ? ngEl.controller('ngModel') : null;
    ...        if(ngModel){ ngModel.$setViewValue('${delta}'); ngModel.$render(); var sc=ngEl.scope(); if(sc) sc.$apply(); }
    ...        else { inp.dispatchEvent(new Event('input',{bubbles:true})); inp.dispatchEvent(new Event('change',{bubbles:true})); }
    ...    }
    Sleep    0.5s
    # Step 5: Click the "Add" confirm button — stable locator: <a normalize-space()='Add'>
    Wait Until Page Contains Element    xpath=//a[normalize-space()='Add']    timeout=5s
    Scroll To Element Via JS    xpath=//a[normalize-space()='Add']
    Sleep    0.2s
    Click Element Via JS    xpath=//a[normalize-space()='Add']
    Log    Modal "Add" <a> button clicked — delta=${delta} submitted.    console=yes
    Sleep    1.5s
    Wait For Loading Overlay To Disappear
    Capture Page Screenshot    sm_add_imsi_confirmed.png
    Log    '${add_btn_text}' modal completed — delta=${delta} added.    console=yes

SM Update EC Max IMSI
    [Documentation]    Opens EC Edit wizard → Account Settings → reads current max IMSI/SIM field;
    ...                delta = new_max − current. If delta <= 0, skips + Add IMSI / Update.
    ...                Otherwise modal submits delta, wizard saves, then re-open verifies new_max.
    [Arguments]    ${ec_name}    ${new_max}
    SM Navigate To Account Module
    SM Enable Customer Wise View
    SM Search Account By Name    ${ec_name}
    SM Open Account Edit Form    ${ec_name}
    SM Navigate Wizard To Account Settings Page
    ${cur_str}=    SM Get Field Value By Labels    Max No IMSI    Max SIM No.
    Should Not Be Empty    ${cur_str}    msg=Could not read current Max IMSI / Max SIM No. before EC update
    ${cur}=    Convert To Integer    ${cur_str}
    ${delta}=    Evaluate    int(${new_max}) - int(${cur})
    IF    ${delta} <= 0
        Log    EC Max IMSI (${cur}) already >= target (${new_max}) — skipping + Add IMSI / Update.    console=yes
        SM Close Account Edit Form
    ELSE
        SM Click Add Limit Button And Input Delta    + Add IMSI    ${delta}
        SM Navigate Wizard To Update And Save
    END
    # ── Post-save: re-open wizard and verify value persisted ────────────────
    SM Search Account By Name    ${ec_name}
    SM Open Account Edit Form    ${ec_name}
    SM Navigate Wizard To Account Settings Page
    ${saved_val}=    SM Get Field Value By Labels    Max No IMSI    Max SIM No.
    Should Be Equal As Numbers    ${saved_val}    ${new_max}
    ...    msg=EC max IMSI/SIM save failed! Expected ${new_max}, got ${saved_val}
    SM Close Account Edit Form
    Log    VERIFIED: EC '${ec_name}' max limit = ${new_max} confirmed after save.    console=yes

SM Update BU Max SIM
    [Documentation]    Opens BU Edit wizard → Account Settings → reads current Max SIM No. (BU);
    ...                delta = new_max − current. If delta <= 0, skips + Add SIMs / Update.
    ...                Otherwise same modal + verify pattern as SM Update EC Max IMSI.
    ...                Disables Customer Wise View first — BU accounts hidden when toggle is ON.
    [Arguments]    ${bu_name}    ${new_max}
    SM Navigate To Account Module
    SM Disable Customer Wise View
    SM Search Account By Name    ${bu_name}
    SM Open Account Edit Form    ${bu_name}
    SM Navigate Wizard To Account Settings Page
    ${cur_str}=    SM Get Field Value By Labels    Max SIM No.    Max No IMSI
    Should Not Be Empty    ${cur_str}    msg=Could not read current Max SIM No. / Max No IMSI before BU update
    ${cur}=    Convert To Integer    ${cur_str}
    ${delta}=    Evaluate    int(${new_max}) - int(${cur})
    IF    ${delta} <= 0
        Log    BU Max SIM (${cur}) already >= target (${new_max}) — skipping + Add SIMs / Update.    console=yes
        SM Close Account Edit Form
    ELSE
        SM Click Add Limit Button And Input Delta    + Add SIMs    ${delta}
        SM Navigate Wizard To Update And Save
    END
    # ── Post-save: re-open wizard and verify value persisted (same as EC) ───
    SM Search Account By Name    ${bu_name}
    SM Open Account Edit Form    ${bu_name}
    SM Navigate Wizard To Account Settings Page
    ${saved_val}=    SM Get Field Value By Labels    Max SIM No.    Max No IMSI
    Should Be Equal As Numbers    ${saved_val}    ${new_max}
    ...    msg=BU Max SIM No. save failed! Expected ${new_max}, got ${saved_val}
    SM Close Account Edit Form
    Log    VERIFIED: BU '${bu_name}' max SIM limit = ${new_max} confirmed after save.    console=yes

SM Get Manage Devices Row Count
    [Documentation]    Navigates to Manage Devices, applies EC + BU (source) filters,
    ...                waits for the grid to load, and returns the total row count.
    ...                Stores the count as suite variable SM_SIM_ROW_COUNT for reuse.
    [Arguments]    ${ec_name}=${EMPTY}    ${bu_name}=${EMPTY}
    SM Navigate To Manage Devices
    # Apply EC filter first (own open/close cycle so popup resets between selections)
    IF    '${ec_name}' != '${EMPTY}'
        Open Filter Popup
        Apply Account Filter Device Plan Style    ${ec_name}
        Close Filter Popup
        Wait For Loading Overlay To Disappear
    END
    # Apply BU filter in a fresh popup open so the Account section is fully reset
    IF    '${bu_name}' != '${EMPTY}'
        Open Filter Popup
        Apply Account Filter Device Plan Style    ${bu_name}
        Close Filter Popup
        Wait For Loading Overlay To Disappear
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    ${count}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    ${count}=    Convert To Integer    ${count}
    Set Suite Variable    ${SM_SIM_ROW_COUNT}    ${count}
    Log    Manage Devices row count (EC='${ec_name}', BU='${bu_name}'): ${count}    console=yes
    RETURN    ${count}

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE DEVICES — SIM SELECTION
# ═══════════════════════════════════════════════════════════════════════

SM Search SIM By ICCID
    [Documentation]    Types ICCID into Manage Devices main search field (id=searchinput) and
    ...                submits with Enter — same pattern as Search Device By IMSI in device_state_keywords
    ...                (not searchBoxId/txtLimit). Keeps SIM Movement aligned with Change State flows.
    [Arguments]    ${iccid}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_MD_SEARCH_INPUT}    timeout=30s
    Scroll To Element Via JS    ${LOC_MD_SEARCH_INPUT}
    ${element}=    Get WebElement    ${LOC_MD_SEARCH_INPUT}
    Execute Javascript
    ...    var el = arguments[0]; el.focus(); el.value = ''; el.value = arguments[1];
    ...    el.dispatchEvent(new Event('input', {bubbles: true}));
    ...    el.dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}    ${iccid}
    Execute Javascript
    ...    var el = arguments[0]; el.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', keyCode: 13, bubbles: true}));
    ...    el.dispatchEvent(new KeyboardEvent('keyup', {key: 'Enter', keyCode: 13, bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.8s
    Wait For Loading Overlay To Disappear
    Wait Until Page Contains Element
    ...    xpath=//td[normalize-space(text())='${iccid}']    timeout=20s

SM Search SIM By IMSI
    [Documentation]    Same as ICCID search (searchinput + Enter) for post-move verification by IMSI.
    [Arguments]    ${imsi}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_MD_SEARCH_INPUT}    timeout=30s
    Scroll To Element Via JS    ${LOC_MD_SEARCH_INPUT}
    ${element}=    Get WebElement    ${LOC_MD_SEARCH_INPUT}
    Execute Javascript
    ...    var el = arguments[0]; el.focus(); el.value = ''; el.value = arguments[1];
    ...    el.dispatchEvent(new Event('input', {bubbles: true}));
    ...    el.dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}    ${imsi}
    Execute Javascript
    ...    var el = arguments[0]; el.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', keyCode: 13, bubbles: true}));
    ...    el.dispatchEvent(new KeyboardEvent('keyup', {key: 'Enter', keyCode: 13, bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.8s
    Wait For Loading Overlay To Disappear
    Wait Until Page Contains Element
    ...    xpath=//td[contains(normalize-space(.),'${imsi}')]    timeout=20s

SM Select SIM Checkbox By ICCID
    [Documentation]    Selects the checkbox for the row matching the given ICCID.
    [Arguments]    ${iccid}
    ${cb}=    Set Variable
    ...    //td[normalize-space(text())='${iccid}']/preceding-sibling::td//input[contains(@class,'sel')]
    Click Element    xpath=${cb}
    Log    SIM with ICCID ${iccid} selected.

SM Get SIM State By ICCID
    [Documentation]    Searches for a SIM by ICCID and returns its current SIM State
    ...                text from the grid (e.g. 'Activated', 'Warm', 'InActive').
    [Arguments]    ${iccid}
    SM Search SIM By ICCID    ${iccid}
    # locate the state cell in the same row as the ICCID
    ${state}=    Get Text
    ...    xpath=//td[normalize-space(text())='${iccid}']/following-sibling::td[contains(@class,'simState') or @data-field='simState' or position()=4]
    Log    SIM state for ICCID ${iccid}: ${state}    console=yes
    RETURN    ${state}

SM Search And Select SIM By ICCID
    [Documentation]    Full sequence: navigate to Manage Devices, search by ICCID, select checkbox.
    [Arguments]    ${iccid}
    SM Navigate To Manage Devices
    SM Search SIM By ICCID    ${iccid}
    SM Select SIM Checkbox By ICCID    ${iccid}

SM Select SIM Checkbox By IMSI
    [Documentation]    Selects the checkbox for the grid row whose IMSI cell matches ${imsi}.
    [Arguments]    ${imsi}
    ${cb}=    Set Variable
    ...    //td[normalize-space(.)='${imsi}']/preceding-sibling::td//input[contains(@class,'sel')]
    Click Element    xpath=${cb}
    Log    SIM with IMSI ${imsi} selected.

SM Search And Select SIM By IMSI
    [Documentation]    Navigate to Manage Devices, search by IMSI, select checkbox for that row.
    [Arguments]    ${imsi}
    SM Navigate To Manage Devices
    SM Search SIM By IMSI    ${imsi}
    SM Select SIM Checkbox By IMSI    ${imsi}

SM Get ICCID From Visible Row By IMSI
    [Documentation]    Reads ICCID from the grid row that matches ${imsi}. Grid must already show the row.
    [Arguments]    ${imsi}
    ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
    ${iccid_col}=    Get Column Index By Header Text    ${ICCID_COLUMN_HEADER}
    ${total_rows}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    FOR    ${i}    IN RANGE    ${total_rows}
        ${row_num}=    Evaluate    ${i} + 1
        ${cell_imsi}=    Get Cell Value By Row And Column    ${row_num}    ${imsi_col}
        IF    '${cell_imsi}' == '${imsi}'
            ${iccid}=    Get Cell Value By Row And Column    ${row_num}    ${iccid_col}
            RETURN    ${iccid}
        END
    END
    Fail    Could not read ICCID: no grid row matches IMSI ${imsi}.

SM Select First Available Activated SIM From Source BU
    [Documentation]    Filters Manage Devices by Activated state (optionally also by BU name),
    ...                selects the first row's checkbox and returns its ICCID.
    ...                If bu_name is empty, only the Activated state filter is applied.
    [Arguments]    ${bu_name}=${EMPTY}
    SM Navigate To Manage Devices
    Open Filter Popup
    IF    '${bu_name}' != '${EMPTY}'
        Apply Account Filter    ${bu_name}
    END
    Apply SIM State Filter    Activated
    Close Filter Popup
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SM_GRID_ROWS}    timeout=20s
    # Capture the first row's ICCID
    ${iccid_col}=    Get Column Index By Header Text    ICCID
    ${iccid}=    Get Cell Value By Row And Column    1    ${iccid_col}
    # Select its checkbox
    Select Device By Row Index    0
    Log    Auto-selected first Activated SIM: ICCID=${iccid} from BU '${bu_name}'    console=yes
    RETURN    ${iccid}

SM Get Or Resolve ICCID
    [Documentation]    Returns SM_ICCID_TO_MOVE if already set in variables/seed.
    ...                If SM_IMSI_TO_MOVE is set and ICCID is empty, opens Manage Devices,
    ...                searches by IMSI, reads ICCID into SM_ICCID_TO_MOVE (checkbox not selected).
    ...                Otherwise auto-selects the first Activated SIM from the grid
    ...                and stores it as a suite variable so later test cases reuse it.
    ...                The SIM checkbox is NOT selected by this keyword except in the auto-select branch;
    ...                call SM Search And Select SIM By ICCID / By IMSI separately when needed.
    IF    '${SM_ICCID_TO_MOVE}' != ''
        RETURN    ${SM_ICCID_TO_MOVE}
    END
    IF    '${SM_IMSI_TO_MOVE}' != ''
        SM Navigate To Manage Devices
        SM Search SIM By IMSI    ${SM_IMSI_TO_MOVE}
        ${iccid}=    SM Get ICCID From Visible Row By IMSI    ${SM_IMSI_TO_MOVE}
        Set Suite Variable    ${SM_ICCID_TO_MOVE}    ${iccid}
        RETURN    ${iccid}
    END
    ${iccid}=    SM Select First Available Activated SIM From Source BU    ${SM_SOURCE_BU_ACCOUNT}
    Set Suite Variable    ${SM_ICCID_TO_MOVE}    ${iccid}
    RETURN    ${iccid}

SM Resolve ICCID For Movement
    [Documentation]    Resolves the ICCID (seed, IMSI search, or auto-select) and ensures the
    ...                SIM checkbox is selected in the Manage Devices grid.
    ...                Stores the resolved ICCID as SM_ICCID_TO_MOVE suite variable.
    IF    '${SM_ICCID_TO_MOVE}' != ''
        SM Search And Select SIM By ICCID    ${SM_ICCID_TO_MOVE}
        RETURN    ${SM_ICCID_TO_MOVE}
    END
    IF    '${SM_IMSI_TO_MOVE}' != ''
        SM Search And Select SIM By IMSI    ${SM_IMSI_TO_MOVE}
        ${iccid}=    SM Get ICCID From Visible Row By IMSI    ${SM_IMSI_TO_MOVE}
        Set Suite Variable    ${SM_ICCID_TO_MOVE}    ${iccid}
        RETURN    ${iccid}
    END
    ${iccid}=    SM Select First Available Activated SIM From Source BU    ${SM_SOURCE_BU_ACCOUNT}
    Set Suite Variable    ${SM_ICCID_TO_MOVE}    ${iccid}
    RETURN    ${iccid}

SM Get SIM State From Visible Row
    [Documentation]    Reads the SIM State from the currently visible grid row matching ${iccid}.
    ...                Does NOT navigate away or re-search — the row must already be visible.
    [Arguments]    ${iccid}
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${iccid_col}=    Get Column Index By Header Text    ${ICCID_COLUMN_HEADER}
    ${total_rows}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    FOR    ${i}    IN RANGE    ${total_rows}
        ${row_num}=    Evaluate    ${i} + 1
        ${cell_iccid}=    Get Cell Value By Row And Column    ${row_num}    ${iccid_col}
        IF    '${cell_iccid}' == '${iccid}'
            ${sim_state}=    Get Cell Value By Row And Column    ${row_num}    ${state_col}
            RETURN    ${sim_state}
        END
    END
    Log    ICCID ${iccid} not found in current grid — state unknown    WARN
    RETURN    ${EMPTY}

SM Get IMSI From Visible Row By ICCID
    [Documentation]    Reads IMSI from the grid row that matches ${iccid}. Row must already be visible.
    [Arguments]    ${iccid}
    ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
    ${iccid_col}=    Get Column Index By Header Text    ${ICCID_COLUMN_HEADER}
    ${total_rows}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    FOR    ${i}    IN RANGE    ${total_rows}
        ${row_num}=    Evaluate    ${i} + 1
        ${cell_iccid}=    Get Cell Value By Row And Column    ${row_num}    ${iccid_col}
        IF    '${cell_iccid}' == '${iccid}'
            ${imsi}=    Get Cell Value By Row And Column    ${row_num}    ${imsi_col}
            RETURN    ${imsi}
        END
    END
    Fail    Could not read IMSI: no grid row matches ICCID ${iccid}.

SM Verify Manage Devices Business Unit Name For IMSI
    [Documentation]    Search by IMSI, find the row whose IMSI cell matches, assert Business Unit Name
    ...                column contains the target BU (${SM_TARGET_BU_ACCOUNT} / expected text).
    [Arguments]    ${imsi}    ${expected_bu_name}
    SM Navigate To Manage Devices
    SM Search SIM By IMSI    ${imsi}
    ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
    ${bu_col}=    Get Column Index By Header Text    ${BUSINESS_UNIT_NAME_COLUMN_HEADER}
    ${total_rows}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    ${imsi_norm}=    Strip String    ${imsi}
    FOR    ${i}    IN RANGE    ${total_rows}
        ${row_num}=    Evaluate    ${i} + 1
        ${cell_imsi}=    Get Cell Value By Row And Column    ${row_num}    ${imsi_col}
        ${cell_norm}=    Strip String    ${cell_imsi}
        IF    '${cell_norm}' == '${imsi_norm}'
            ${bu_name}=    Get Cell Value By Row And Column    ${row_num}    ${bu_col}
            Should Contain    ${bu_name}    ${expected_bu_name}
            ...    msg=After SIM move, Business Unit Name expected to contain '${expected_bu_name}' for IMSI ${imsi} but column was '${bu_name}'
            Log    VERIFIED: IMSI ${imsi} row → Business Unit Name '${bu_name}' contains '${expected_bu_name}'.    console=yes
            RETURN
        END
    END
    Fail    No grid row found with IMSI '${imsi}' after search — cannot validate Business Unit Name.

SM Verify Manage Devices Account Column For IMSI
    [Documentation]    Deprecated alias — use Business Unit Name column (Manage Devices).
    [Arguments]    ${imsi}    ${expected_account_text}
    SM Verify Manage Devices Business Unit Name For IMSI    ${imsi}    ${expected_account_text}

# ═══════════════════════════════════════════════════════════════════════
#  SIM MOVEMENT — MODAL FLOW
# ═══════════════════════════════════════════════════════════════════════

SM Open SIM Movement Modal
    [Documentation]    Selects "SIM Movement" from the Select Action dropdown, dispatches
    ...                the JavaScript change event (required to trigger the action UI), then
    ...                waits for the action comment textarea (id=actionChangeComment) to appear.
    Wait Until Element Is Enabled    ${LOC_SM_ACTION_DROP}    timeout=10s
    @{options}=    Get List Items    ${LOC_SM_ACTION_DROP}
    Log    Action dropdown options: ${options}    console=yes
    Select From List By Label    ${LOC_SM_ACTION_DROP}    ${SM_ACTION_LABEL}
    # Dispatch change event — same pattern as Select Change State Action in device_state_keywords
    ${el}=    Get WebElement    ${LOC_SM_ACTION_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${el}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # The section may be in DOM but inside a 0-height container (accordion).
    # Use Page Contains Element (DOM check) instead of visual visibility check.
    Wait Until Page Contains Element    ${LOC_SM_COMMENT_TEXTAREA}    timeout=15s
    Log    SIM Movement action section ready (DOM present).    console=yes

SM Open Select Account Dropdown For Sim Movement
    [Documentation]    Clicks the Select Account field so the account hierarchy tree appears.
    ...                Tree is not in DOM as a visible widget until this dropdown opens (showTreeView / Kendo popup).
    ${opened}=    Execute Javascript
    ...    var anchor = document.getElementById('actionChangeComment');
    ...    if(!anchor) return 'no_anchor';
    ...    var walk = anchor;
    ...    for(var d = 0; d < 32 && walk; d++){
    ...        var tv = walk.querySelector('div[id^="showTreeView"]');
    ...        if(tv && tv.id){
    ...            var fname = tv.id.replace(/^showTreeView-/, '');
    ...            var inp = walk.querySelector('input[name="' + fname + '"]');
    ...            if(inp){ inp.scrollIntoView({block:'center', inline:'nearest'}); inp.click(); return 'input:' + fname; }
    ...            var wrap = tv.closest('.form-group') || tv.parentElement;
    ...            if(wrap){ var inp2 = wrap.querySelector('input, .k-input, [role="combobox"]'); if(inp2){ inp2.click(); return 'wrap_input'; } }
    ...        }
    ...        var inputs = walk.querySelectorAll('input');
    ...        for(var i = 0; i < inputs.length; i++){
    ...            var ph = (inputs[i].placeholder || '').toLowerCase();
    ...            if(ph.indexOf('select account') >= 0){
    ...                inputs[i].scrollIntoView({block:'center', inline:'nearest'});
    ...                inputs[i].click();
    ...                return 'placeholder';
    ...            }
    ...        }
    ...        var dd = walk.querySelector('.account-tree-dropdown, .k-dropdown[aria-owns], span.k-dropdown-wrap');
    ...        if(dd){ dd.scrollIntoView({block:'center', inline:'nearest'}); dd.click(); return 'dropdown_wrap'; }
    ...        walk = walk.parentElement;
    ...    }
    ...    var form = document.getElementById('actionForm');
    ...    if(form){
    ...        var ins = form.querySelectorAll('input[placeholder], input[type="text"], input[type="search"]');
    ...        for(var j = 0; j < ins.length; j++){
    ...            var p2 = (ins[j].placeholder || '').toLowerCase();
    ...            if(p2.indexOf('select account') >= 0){ ins[j].click(); return 'form_placeholder'; }
    ...        }
    ...    }
    ...    return 'notfound';
    Log    SIM Movement Select Account open result: ${opened}    console=yes
    Should Not Be Equal    ${opened}    notfound
    ...    msg=Could not find Select Account dropdown near SIM Movement — tree stays hidden until it is opened.
    Wait For Loading Overlay To Disappear
    Sleep    0.5s
    Wait Until Page Contains Element    ${LOC_SM_SELECT_ACCOUNT_TREE_NODE}    timeout=20s

SM Click Tree Expand Icon For Label In Sim Movement Modal
    [Documentation]    Inside SIM Movement modal tree: finds node whose label matches ${label_text}
    ...                (exact or contains), clicks only the row expand icon (.k-i-expand / k-plus),
    ...                not the label. Returns status string for logging.
    ...                Root = nearest ancestor of actionChangeComment that contains the treeview
    ...                (tree is often a sibling of the form, not inside it — form-only scope misses nodes).
    [Arguments]    ${label_text}
    ${status}=    Execute Javascript
    ...    var label = (arguments[0] || '').trim();
    ...    function simMovementTreeRoot(){
    ...        var anchor = document.getElementById('actionChangeComment');
    ...        if(!anchor) return document.body;
    ...        var el = anchor;
    ...        for(var i = 0; i < 28 && el; i++){
    ...            if(el.querySelector('ul.k-treeview-lines, ul[class*="k-treeview-lines"], .k-treeview ul')){
    ...                return el;
    ...            }
    ...            el = el.parentElement;
    ...        }
    ...        return document.body;
    ...    }
    ...    var root = simMovementTreeRoot();
    ...    function norm(s){ return (s || '').replace(/\\s+/g, ' ').trim(); }
    ...    function labelMatch(t, want){
    ...        if(t === want || t.indexOf(want) >= 0) return true;
    ...        var u = t.toUpperCase();
    ...        if(want.toUpperCase() === 'KSA_OPCO' && u.indexOf('KSA') >= 0 && u.indexOf('OPCO') >= 0) return true;
    ...        return false;
    ...    }
    ...    var spans = root.querySelectorAll('ul.k-treeview-lines span.k-in, ul[class*="k-treeview-lines"] span.k-in, .k-treeview span.k-in, li.k-item > div span.k-in');
    ...    var i, t;
    ...    for(i = 0; i < spans.length; i++){
    ...        t = norm(spans[i].textContent);
    ...        if(labelMatch(t, label)){
    ...            var li = spans[i].closest('li.k-item, li[role="treeitem"]');
    ...            if(!li) return 'noli:' + label;
    ...            var row = li.querySelector(':scope > .k-top, :scope > .k-bot, :scope > .k-mid, :scope > div');
    ...            if(!row) return 'norow:' + label;
    ...            var ex = row.querySelector('.k-i-expand, .k-plus, .k-i-plus, span[class*="k-i-expand"], span[class*="expand"], span[class*="chevron-right"]');
    ...            if(!ex) return 'no_expand_icon:' + label;
    ...            try{
    ...                ex.scrollIntoView({block:'center', inline:'nearest'});
    ...                ex.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true}));
    ...                ex.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true}));
    ...                ex.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true}));
    ...            }catch(err){ ex.click(); }
    ...            return 'clicked_expand:' + label;
    ...        }
    ...    }
    ...    return 'notfound:' + label;
    ...    ARGUMENTS    ${label_text}
    RETURN    ${status}

SM Select Tree Node By Label In Sim Movement Modal
    [Documentation]    Clicks BU/leaf: checkbox, radio, or span.k-in for ${label_text}.
    ...                Uses same tree root as expand keyword (ancestor that contains treeview).
    [Arguments]    ${label_text}
    ${status}=    Execute Javascript
    ...    var label = (arguments[0] || '').trim();
    ...    function simMovementTreeRoot(){
    ...        var anchor = document.getElementById('actionChangeComment');
    ...        if(!anchor) return document.body;
    ...        var el = anchor;
    ...        for(var i = 0; i < 28 && el; i++){
    ...            if(el.querySelector('ul.k-treeview-lines, ul[class*="k-treeview-lines"], .k-treeview ul')){
    ...                return el;
    ...            }
    ...            el = el.parentElement;
    ...        }
    ...        return document.body;
    ...    }
    ...    var root = simMovementTreeRoot();
    ...    function norm(s){ return (s || '').replace(/\\s+/g, ' ').trim(); }
    ...    function labelMatch(t, want){
    ...        if(t === want || t.indexOf(want) >= 0) return true;
    ...        var u = t.toUpperCase();
    ...        if(want.toUpperCase() === 'KSA_OPCO' && u.indexOf('KSA') >= 0 && u.indexOf('OPCO') >= 0) return true;
    ...        return false;
    ...    }
    ...    var spans = root.querySelectorAll('ul.k-treeview-lines span.k-in, ul[class*="k-treeview-lines"] span.k-in, .k-treeview span.k-in, li.k-item > div span.k-in');
    ...    var i, t, sp = null;
    ...    for(i = 0; i < spans.length; i++){
    ...        t = norm(spans[i].textContent);
    ...        if(t === label){ sp = spans[i]; break; }
    ...    }
    ...    if(!sp){ for(i = 0; i < spans.length; i++){ t = norm(spans[i].textContent); if(labelMatch(t, label)){ sp = spans[i]; break; } } }
    ...    if(!sp) return 'notfound';
    ...    var li = sp.closest('li.k-item, li[role="treeitem"]');
    ...    if(li){
    ...        var cb = li.querySelector('input[type="checkbox"]');
    ...        if(cb){ cb.click(); return 'OK_CHECKBOX'; }
    ...        var rd = li.querySelector('input[type="radio"]');
    ...        if(rd){ rd.click(); return 'OK_RADIO'; }
    ...    }
    ...    try{
    ...        sp.scrollIntoView({block:'center', inline:'nearest'});
    ...        sp.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true}));
    ...        sp.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true}));
    ...        sp.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true}));
    ...    }catch(e){ sp.click(); }
    ...    return 'OK_SPAN';
    ...    ARGUMENTS    ${label_text}
    RETURN    ${status}

SM Select Target BU In Modal
    [Documentation]    SIM Movement account tree: open Select Account dropdown (tree hidden until then),
    ...                then expand KSA_OPCO → EC → optional BU expand → select BU by name.
    ...                After each expand/selection, waits for loading overlay to finish.
    [Arguments]    ${ec_name}    ${bu_name}
    SM Open Select Account Dropdown For Sim Movement
    # ── 1) Expand KSA_OPCO (triangle only), then wait for tree/grid load ─────
    ${st}=    SM Click Tree Expand Icon For Label In Sim Movement Modal    KSA_OPCO
    Log    SIM Movement tree step KSA_OPCO: ${st}    console=yes
    Wait For Loading Overlay To Disappear
    Sleep    0.5s
    # ── 2) Expand EC (target BU's parent) by EC account name ─────────────────
    IF    '${ec_name}' != ''
        ${st_ec}=    SM Click Tree Expand Icon For Label In Sim Movement Modal    ${ec_name}
        Log    SIM Movement tree step EC '${ec_name}': ${st_ec}    console=yes
        Wait For Loading Overlay To Disappear
        Sleep    0.5s
    END
    # ── 3) Expand BU node if it shows an expand icon (nested structure) ───────
    ${st_bu_exp}=    SM Click Tree Expand Icon For Label In Sim Movement Modal    ${bu_name}
    Log    SIM Movement tree step BU expand '${bu_name}': ${st_bu_exp}    console=yes
    Wait For Loading Overlay To Disappear
    Sleep    0.5s
    # ── 4) Select target BU (click name / checkbox / radio) ───────────────────
    FOR    ${attempt}    IN RANGE    3
        ${sel}=    SM Select Tree Node By Label In Sim Movement Modal    ${bu_name}
        ${ok}=    Run Keyword And Return Status    Should Start With    ${sel}    OK_
        IF    ${ok}
            Log    Target BU '${bu_name}' selected (${sel}).    console=yes
            Wait For Loading Overlay To Disappear
            Sleep    0.5s
            RETURN
        END
        Log    SIM Movement BU select attempt ${attempt}: ${sel} — re-expanding EC and retrying.    console=yes
        IF    '${ec_name}' != ''
            ${st_ec2}=    SM Click Tree Expand Icon For Label In Sim Movement Modal    ${ec_name}
            Log    Retry expand EC: ${st_ec2}    console=yes
            Wait For Loading Overlay To Disappear
            Sleep    0.5s
        END
        ${st_bu2}=    SM Click Tree Expand Icon For Label In Sim Movement Modal    ${bu_name}
        Log    Retry expand BU: ${st_bu2}    console=yes
        Wait For Loading Overlay To Disappear
        Sleep    0.5s
    END
    Fail    Could not select target BU '${bu_name}' in SIM Movement tree. Last select result: ${sel}

SM Select Device Plan In Modal If Present
    [Documentation]    Checks if a Device Plan dropdown is visible inside the SIM Movement modal.
    ...                If present (required for Activated SIMs), selects the plan by visible text.
    ...                Skips silently if the dropdown is absent (Warm/InActive SIMs).
    [Arguments]    ${device_plan_name}
    ${dp_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SM_DP_DROPDOWN}
    IF    ${dp_visible}
        Select From List By Label    ${LOC_SM_DP_DROPDOWN}    ${device_plan_name}
        Log    Device Plan '${device_plan_name}' selected in SIM Movement modal.    console=yes
    ELSE
        Log    No Device Plan dropdown visible — SIM is likely Warm/InActive. Skipping DP selection.    console=yes
    END

SM Click Sim Movement Toolbar Submit
    [Documentation]    Clicks the Submit next to Target Account / SIM Movement row (not Case ID Submit).
    ...                Prefers last visible "Submit" in #actionForm; falls back to scoped submitActionBtn.
    Wait For Loading Overlay To Disappear
    ${js_ok}=    Run Keyword And Return Status    SM Click Sim Movement Toolbar Submit Via JS
    IF    ${js_ok}
        RETURN
    END
    ${s0}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SM_SIM_MOVEMENT_SUBMIT}    timeout=6s
    IF    ${s0}
        Click Element Via JS    ${LOC_SM_SIM_MOVEMENT_SUBMIT}
        RETURN
    END
    ${s_id}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SM_SUBMIT_ACTION_BTN_SCOPED}    timeout=4s
    IF    ${s_id}
        Click Element Via JS    ${LOC_SM_SUBMIT_ACTION_BTN_SCOPED}
        RETURN
    END
    Fail    Could not find SIM Movement toolbar Submit (last Submit in actionForm or JS scan).

SM Click Sim Movement Toolbar Submit Via JS
    [Documentation]    Finds visible Submit buttons inside #actionForm; clicks the last one (SIM Movement row).
    ${r}=    Execute Javascript
    ...    var form=document.getElementById('actionForm');
    ...    if(!form) return 'no_form';
    ...    var all=form.querySelectorAll('button');
    ...    var vis=[];
    ...    for(var i=0;i<all.length;i++){
    ...      var t=(all[i].textContent||'').replace(/\\s+/g,' ').trim();
    ...      if(t!=='Submit') continue;
    ...      var r=all[i].getBoundingClientRect();
    ...      if(r.width<1||r.height<1) continue;
    ...      var st=window.getComputedStyle(all[i]);
    ...      if(st.display==='none'||st.visibility==='hidden'||parseFloat(st.opacity||'1')===0) continue;
    ...      vis.push(all[i]);
    ...    }
    ...    if(!vis.length) return 'no_submit';
    ...    var btn=vis[vis.length-1];
    ...    btn.scrollIntoView({block:'center',inline:'nearest'});
    ...    try{
    ...      btn.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true}));
    ...      btn.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true}));
    ...      btn.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true}));
    ...    }catch(e){ btn.click(); }
    ...    return 'ok';
    Should Be Equal    ${r}    ok    msg=JS SIM Movement Submit failed: ${r}

SM Submit SIM Movement
    [Documentation]    Clicks the SIM Movement row Submit (next to target BU), then Proceed on #savePopup.
    ...                Falls back to legacy ids / single Proceed if the popup pattern differs.
    Wait For Loading Overlay To Disappear
    ${clicked_submit}=    Set Variable    no
    ${s_sm}=    Run Keyword And Return Status    SM Click Sim Movement Toolbar Submit
    IF    ${s_sm}
        ${clicked_submit}=    Set Variable    yes
    ELSE
        ${s1}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_SM_SUBMIT_ACTION_BTN}    timeout=4s
        IF    ${s1}
            Click Element Via JS    ${LOC_SM_SUBMIT_ACTION_BTN}
            ${clicked_submit}=    Set Variable    yes
        ELSE
            ${s2}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_SM_SUBMIT_ACTION_BTN_ALT}    timeout=4s
            IF    ${s2}
                Click Element Via JS    ${LOC_SM_SUBMIT_ACTION_BTN_ALT}
                ${clicked_submit}=    Set Variable    yes
            END
        END
    END
    IF    '${clicked_submit}' == 'yes'
        Wait For Loading Overlay To Disappear
        ${popup}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_SM_SAVE_POPUP}    timeout=12s
        IF    ${popup}
            Wait Until Element Is Visible    ${LOC_SM_SAVE_POPUP_PROCEED}    timeout=10s
            Click Element Via JS    ${LOC_SM_SAVE_POPUP_PROCEED}
            Log    SIM Movement: Submit + confirmation Proceed clicked.    console=yes
            RETURN
        END
    END
    # Scoped Proceed only — bare id=prceedBtn can match a hidden duplicate elsewhere; Click Element Via JS
    # then waits 30s for visibility and fails even if you saw a toast from a manual/other path.
    ${proceed_scoped}=    Set Variable    xpath=//div[@id='savePopup']//button[@id='prceedBtn']
    ${proceed_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${proceed_scoped}    timeout=8s
    IF    ${proceed_ok}
        Click Element Via JS    ${proceed_scoped}
        Log    SIM Movement: Proceed clicked inside #savePopup (late-detected popup).    console=yes
        RETURN
    END
    ${inline_proceed}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SM_PROCEED_BTN}    timeout=4s
    IF    ${inline_proceed}
        Click Element Via JS    ${LOC_SM_PROCEED_BTN}
        Log    SIM Movement: inline Proceed on action form (no #savePopup).    console=yes
        RETURN
    END
    Fail
    ...    SIM Movement: after Submit, neither #savePopup Proceed nor inline Proceed appeared. Wrong Submit or UI timing. (Chrome GCM/Plausible/USB lines in the terminal are browser noise, not this failure.)

SM Close SIM Movement Modal
    [Documentation]    Cancels/dismisses the SIM Movement action section without submitting.
    ...                Tries Cancel/Close button first, then ESC key, then dropdown reset.
    # Try the Cancel/Close button inside the action section
    ${cancel_clicked}=    Run Keyword And Return Status
    ...    Click Element Via JS    ${LOC_SM_MODAL_CLOSE_BTN}
    IF    not ${cancel_clicked}
        # Fallback: press ESC to close popup/action section
        Press Key    ${LOC_SM_ACTION_DROP}    \\27
        Sleep    1s
    END
    Sleep    1s
    # Reset action dropdown to "Select Action" to clear the section
    ${el}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_SM_ACTION_DROP}
    IF    ${el}
        ${dropdown}=    Get WebElement    ${LOC_SM_ACTION_DROP}
        Execute Javascript
        ...    arguments[0].selectedIndex = 0;
        ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
        ...    ARGUMENTS    ${dropdown}
        Sleep    1s
    END
    Log    SIM Movement action section dismissed.    console=yes

SM Perform Full SIM Movement
    [Documentation]    End-to-end SIM Movement: select SIM → open modal →
    ...                select target BU → submit.
    [Arguments]    ${iccid}    ${ec_name}    ${bu_name}
    SM Search And Select SIM By ICCID    ${iccid}
    SM Open SIM Movement Modal
    SM Select Target BU In Modal    ${ec_name}    ${bu_name}
    SM Submit SIM Movement

SM Perform SIM Movement With State Awareness
    [Documentation]    Full state-aware SIM Movement flow:
    ...                1. Resolves ICCID (from seed or auto-select), selects checkbox, captures IMSI (suite var SM_IMSI_FOR_MOVE).
    ...                2. Reads SIM state from the visible row (same SIM used for movement).
    ...                3. Opens SIM Movement, selects target BU, optional Device Plan for Activated.
    ...                4. Submits (Submit → confirmation Proceed when popup is shown).
    ...                Returns the resolved ICCID.
    [Arguments]    ${ec_name}    ${bu_name}    ${device_plan_name}=${EMPTY}
    # Step 1 — navigate to Manage Devices, resolve ICCID, select checkbox
    SM Navigate To Manage Devices
    ${iccid}=    SM Resolve ICCID For Movement
    # Step 2 — state + IMSI from same row (for post-move search by IMSI)
    ${sim_state}=    SM Get SIM State From Visible Row    ${iccid}
    ${imsi}=    SM Get IMSI From Visible Row By ICCID    ${iccid}
    Set Suite Variable    ${SM_IMSI_FOR_MOVE}    ${imsi}
    Page Should Contain Element    xpath=//td[normalize-space(text())='${iccid}']
    Log    SIM ICCID=${iccid} IMSI=${imsi} state='${sim_state}' — proceeding with movement.    console=yes
    # Step 3 — open SIM Movement modal (checkbox is still selected from Step 1)
    SM Open SIM Movement Modal
    # Step 4 — select target BU
    SM Select Target BU In Modal    ${ec_name}    ${bu_name}
    # Step 5 — conditional Device Plan selection
    ${is_activated}=    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${sim_state}    Activated
    IF    ${is_activated}
        ${dp_to_use}=    Set Variable If    '${device_plan_name}' != ''    ${device_plan_name}    ${SM_DEVICE_PLAN_NAME}
        IF    '${dp_to_use}' != ''
            SM Select Device Plan In Modal If Present    ${dp_to_use}
        END
    ELSE
        Log    SIM state is '${sim_state}' — Device Plan dropdown not required.    console=yes
    END
    # Step 6 — submit
    SM Submit SIM Movement
    Log    SIM Movement submitted for ICCID ${iccid} (state: '${sim_state}').    console=yes
    RETURN    ${iccid}

SM Verify SIM Movement Submission Success
    [Documentation]    After Proceed, waits up to 30s for the green Toastify success toast
    ...                (same pattern as other CMP screens — not inline page text).
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SM_TOAST_SUCCESS}    timeout=30s
    Log    SIM Movement success toast visible (Toastify).    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  HEADER NOTIFICATIONS — REQUEST ID (Batch Job Log correlation)
# ═══════════════════════════════════════════════════════════════════════

SM Open Header Notifications Panel
    [Documentation]    Clicks header bell; waits for notifications list (div.fixed-height-not / div.alertrequestno).
    ...                Does not rely on #openNotificationPopup — your DOM uses class-based wrappers only.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SM_NOTIFICATION_BELL}    timeout=10s
    Execute Javascript
    ...    var b=document.getElementById('dropdownbell');
    ...    if(!b) return 'no_bell';
    ...    b.scrollIntoView({block:'center'});
    ...    b.click();
    ...    return 'ok';
    Sleep    0.6s
    Wait Until Element Is Visible    ${LOC_SM_NOTIFICATION_FIRST_RID}    timeout=12s

SM Get First Notification Request Id From Open Panel
    [Documentation]    First Request Id from div.alertrequestno inside the notifications scroll list (top item).
    ${rid}=    Execute Javascript
    ...    var root=document.querySelector('.infinite-scroll-component')||document.querySelector('.fixed-height-not')||document.body;
    ...    var el=root.querySelector('.alertrequestno');
    ...    if(!el){
    ...      var all=document.querySelectorAll('div.alertrequestno');
    ...      el=all.length?all[0]:null;
    ...    }
    ...    if(!el) return '';
    ...    var t=(el.textContent||'').replace(/\\s+/g,'').trim();
    ...    if(/^GC[0-9]{10,}$/.test(t)) return t;
    ...    var m=t.match(/GC[0-9]{10,}/);
    ...    return m?m[0]:'';
    Should Not Be Empty    ${rid}
    ...    msg=No div.alertrequestno / GC id in notification panel. Is the bell list open?
    RETURN    ${rid}

SM Capture Batch Request Id From Notifications After Sim Movement
    [Documentation]    After toast: open bell → read first div.alertrequestno → suite variable SM_BATCH_REQUEST_ID.
    ...                Used to filter Batch Job Log and confirm the async request completed.
    SM Open Header Notifications Panel
    ${has_success}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath=//div[contains(@class,'fixed-height-not')]//*[contains(@class,'Successful') or contains(@class,'Completed') or contains(.,'SUCCESSFUL') or contains(.,'COMPLETED')]
    IF    ${has_success}
        Log    Top notification shows SUCCESSFUL/COMPLETED — capturing Request Id.    console=yes
    ELSE
        Log    SUCCESSFUL/COMPLETED text not detected in panel yet — capturing Request Id anyway.    WARN
    END
    ${rid}=    SM Get First Notification Request Id From Open Panel
    Set Suite Variable    ${SM_BATCH_REQUEST_ID}    ${rid}
    Log    SM_BATCH_REQUEST_ID=${rid} (use in Batch Job Log filter).    console=yes
    Run Keyword And Ignore Error    Execute Javascript
    ...    var b=document.getElementById('dropdownbell'); if(b) b.click();

# ═══════════════════════════════════════════════════════════════════════
#  BATCH JOBS
# ═══════════════════════════════════════════════════════════════════════

SM Wait For Batch Job Log Loading Complete
    [Documentation]    After Batch Job Log search or row expand: CMP body loading-indicator gone,
    ...                then Kendo ``k-loading-mask`` cleared if it was shown (grid / nested detail).
    Wait For Loading Overlay To Disappear
    Set Selenium Implicit Wait    0s
    ${mask}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SM_K_LOADING_MASK}    timeout=3s
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    IF    ${mask}
        Set Selenium Implicit Wait    0s
        Wait Until Element Is Not Visible    ${LOC_SM_K_LOADING_MASK}    timeout=45s
        Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
        Wait For Loading Overlay To Disappear
    END

SM Filter Batch Job Log By Request Id
    [Documentation]    Batch Job Log toolbar search: type Request Id, Enter, wait until load complete (overlay + grid mask).
    [Arguments]    ${request_id}
    SM Navigate To Batch Job Log
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SM_BATCH_SEARCH_INPUT}    timeout=15s
    ${el}=    Get WebElement    ${LOC_SM_BATCH_SEARCH_INPUT}
    Execute Javascript
    ...    var e=arguments[0]; e.focus(); e.value=''; e.value=arguments[1];
    ...    e.dispatchEvent(new Event('input',{bubbles:true}));
    ...    e.dispatchEvent(new Event('change',{bubbles:true}));
    ...    ARGUMENTS    ${el}    ${request_id}
    Press Keys    ${LOC_SM_BATCH_SEARCH_INPUT}    ENTER
    SM Wait For Batch Job Log Loading Complete

SM Verify Sim Movement Batch Job Detail For Request Id
    [Documentation]    Batch Job Log: filter by Request Id (TC_SM_005), expand master row, wait loads, validate nested Details —
    ...                OPERATION PERFORM contains target BU, RESULT SUCCESSFUL, Description contains substring.
    [Arguments]    ${request_id}    ${expected_target_bu}    ${expected_description_contains}=${SM_BJL_DETAIL_SUBSTRING}
    SM Filter Batch Job Log By Request Id    ${request_id}
    Wait Until Page Contains Element    xpath=//td[contains(.,'${request_id}')]    timeout=25s
    SM Wait For Batch Job Log Loading Complete
    ${expand}=    Set Variable
    ...    xpath=(//tr[contains(@class,'k-master-row')][.//td[contains(.,'${request_id}')]])[1]//td[contains(@class,'k-hierarchy-cell')]//a
    Wait Until Element Is Visible    ${expand}    timeout=12s
    Click Element Via JS    ${expand}
    SM Wait For Batch Job Log Loading Complete
    ${detail_row}=    Set Variable
    ...    (//tr[contains(@class,'k-master-row')][.//td[contains(.,'${request_id}')]])[1]/following-sibling::tr[contains(@class,'k-detail-row')][1]
    Wait Until Element Is Visible    xpath=${detail_row}    timeout=15s
    SM Wait For Batch Job Log Loading Complete
    Wait Until Element Is Visible    xpath=${detail_row}//td[contains(.,'${expected_target_bu}')]    timeout=15s
    Wait Until Element Is Visible    xpath=${detail_row}//td[contains(.,'SUCCESSFUL')]    timeout=15s
    Wait Until Element Is Visible    xpath=${detail_row}//td[contains(.,'${expected_description_contains}')]    timeout=15s
    Log    Batch Job Log: Request ${request_id} — BU '${expected_target_bu}', SUCCESSFUL, description fragment OK.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  POST-MOVEMENT VERIFICATION — NOTES (reusable keywords; no suite test)
# ═══════════════════════════════════════════════════════════════════════

SM Expand SIM And Go To Notes Tab
    [Documentation]    Searches for a SIM by ICCID, expands its row and navigates
    ...                to the Notes tab. Uses JS click to avoid overlay interception.
    [Arguments]    ${iccid}
    SM Navigate To Manage Devices
    SM Search SIM By ICCID    ${iccid}
    Wait For Loading Overlay To Disappear
    ${expand}=    Set Variable
    ...    //td[normalize-space(text())='${iccid}']/preceding-sibling::td[contains(@class,'k-hierarchy-cell')]//a
    Wait Until Page Contains Element    xpath=${expand}    timeout=10s
    Click Element Via JS    xpath=${expand}
    Wait Until Element Is Visible    ${LOC_SM_TAB_NOTES}    timeout=15s
    Click Element Via JS    ${LOC_SM_TAB_NOTES}
    Sleep    1s
    Log    Notes tab opened for ICCID: ${iccid}

SM Verify SIM Movement Successful Note
    [Documentation]    Confirms 'SIM Movement Successful' entry is present in the Notes grid.
    Wait Until Page Contains Element    ${LOC_SM_NOTES_SM_SUCCESSFUL}    timeout=15s
    ${text}=    Get Text    ${LOC_SM_NOTES_SM_SUCCESSFUL}
    Should Contain    ${text}    SIM Movement
    Log    SIM Movement Successful note confirmed: ${text}

# ═══════════════════════════════════════════════════════════════════════
#  POST-MOVEMENT VERIFICATION — AUDIT TRAIL
# ═══════════════════════════════════════════════════════════════════════

SM Verify SIM Movement In Audit Trail
    [Documentation]    Checks the Audit Trail grid for a SIM Movement entry,
    ...                optionally filtered by account name.
    [Arguments]    ${account_name}=${EMPTY}
    SM Navigate To Audit Trail
    Run Keyword If    '${account_name}' != '${EMPTY}'
    ...    Input Text    ${LOC_SM_AUDIT_ACCOUNT_INPUT}    ${account_name}
    Wait Until Element Is Visible    ${LOC_SM_AUDIT_GRID}    timeout=15s
    Page Should Contain Element    ${LOC_SM_AUDIT_SM_ROW}
    ${text}=    Get Text    ${LOC_SM_AUDIT_SM_ROW}
    Log    Audit Trail SIM Movement entry confirmed: ${text}

# ═══════════════════════════════════════════════════════════════════════
#  TEST CASE IMPLEMENTATIONS
# ═══════════════════════════════════════════════════════════════════════

TC_SM_002
    [Documentation]    Step 1 — Manage Devices: EC + source BU filter; row count → SM_SIM_ROW_COUNT.
    ...                Step 2 — EC Max IMSI vs rows: if max > rows, no change; else raise toward rows+1
    ...                (modal delta). Sets SM_EC_MAX_IMSI_CAP for TC_SM_003 BU cap enforcement.
    # ── Step 1: capture row count from Manage Devices ──────────────────────
    IF    '${SM_EC_ACCOUNT_NAME}' != ''
        ${row_count}=    SM Get Manage Devices Row Count    ${SM_EC_ACCOUNT_NAME}    ${SM_SOURCE_BU_ACCOUNT}
    ELSE
        ${row_count}=    SM Get Manage Devices Row Count
    END
    Log    SIM row count from Manage Devices: ${row_count}    console=yes
    # ── Step 2: check EC Max IMSI vs row count ──────────────────────────────
    IF    '${SM_EC_ACCOUNT_NAME}' != ''
        ${max_imsi}=    SM Check And Expand EC IMSI Capacity If Needed    ${SM_EC_ACCOUNT_NAME}    ${row_count}
        Set Suite Variable    ${SM_EC_MAX_IMSI_CAP}    ${max_imsi}
        Should Be True    ${max_imsi} > ${row_count}
        Log    PASS: EC '${SM_EC_ACCOUNT_NAME}' Max IMSI=${max_imsi} > row count=${row_count}. Capacity OK.
    ELSE
        Log    SM_EC_ACCOUNT_NAME not set (no E2E seed) — row count captured only.    WARN
        Log    PASS: Manage Devices grid row count = ${row_count}.
    END

TC_SM_003
    [Documentation]    Target BU: Manage Devices row count for that BU only (not EC+source from TC_SM_002).
    ...                BU max vs rows: if max > rows, OK; else raise toward min(rows+1, SM_EC_MAX_IMSI_CAP).
    ${ec_cap}=    Get Variable Value    ${SM_EC_MAX_IMSI_CAP}    999999
    IF    '${SM_TARGET_BU_ACCOUNT}' != ''
        ${row_count}=    SM Get Manage Devices Row Count    ${EMPTY}    ${SM_TARGET_BU_ACCOUNT}
        Log    Target BU '${SM_TARGET_BU_ACCOUNT}' Manage Devices row count: ${row_count}    console=yes
        ${max_sim}=    SM Check And Expand BU Max SIM If Needed    ${SM_TARGET_BU_ACCOUNT}    ${row_count}    ${ec_cap}
        Should Be True    ${max_sim} > ${row_count}
        Log    PASS: BU '${SM_TARGET_BU_ACCOUNT}' Max SIM=${max_sim} > row count=${row_count}. Capacity OK.
    ELSE
        Log    SM_TARGET_BU_ACCOUNT not set (no E2E seed) — ManageAccount grid verified only.    WARN
        SM Navigate To Account Module
        Element Should Be Visible    ${LOC_SM_ACCOUNT_GRID}
        Log    PASS: ManageAccount grid is accessible.
    END

TC_SM_005
    [Documentation]    Single flow (ex-TC_SM_004 + movement): resolve ICCID, capture IMSI, state-aware move,
    ...                Submit → Proceed → success toast (30s) → bell: capture GC Request Id → SM_BATCH_REQUEST_ID,
    ...                then 3 min wait, IMSI search + Business Unit Name column = target BU.
    ...                Requires SM_TARGET_BU_ACCOUNT (E2E seed or --variable).
    IF    '${SM_TARGET_BU_ACCOUNT}' == ''
        Skip    TC_SM_005 requires SM_TARGET_BU_ACCOUNT. Run E2E first or pass --variable SM_TARGET_BU_ACCOUNT:BuName
    END
    ${iccid}=    SM Perform SIM Movement With State Awareness
    ...    ${SM_EC_ACCOUNT_NAME}
    ...    ${SM_TARGET_BU_ACCOUNT}
    SM Verify SIM Movement Submission Success
    SM Capture Batch Request Id From Notifications After Sim Movement
    ${imsi}=    Get Variable Value    ${SM_IMSI_FOR_MOVE}    ${EMPTY}
    Should Not Be Empty    ${imsi}    msg=IMSI was not captured before movement — cannot verify grid by IMSI.
    Log    Waiting 3 minutes for SIM movement to complete before IMSI/account verification...    console=yes
    Sleep    3m
    SM Verify Manage Devices Business Unit Name For IMSI    ${imsi}    ${SM_TARGET_BU_ACCOUNT}
    Log    PASS: SIM Movement completed for ICCID ${iccid} (IMSI ${imsi}); Business Unit Name reflects target BU.

TC_SM_009
    [Documentation]    Application Logging → Batch Job Log: filter by SM_BATCH_REQUEST_ID (TC_SM_005), expand row,
    ...                validate Details grid — OPERATION PERFORM (target BU), RESULT SUCCESSFUL,
    ...                Description contains SM_BJL_DETAIL_SUBSTRING.
    IF    '${SM_TARGET_BU_ACCOUNT}' == ''
        Skip    TC_SM_009 requires SM_TARGET_BU_ACCOUNT (same suite as TC_SM_005).
    END
    ${rid}=    Get Variable Value    ${SM_BATCH_REQUEST_ID}    ${EMPTY}
    Should Not Be Empty    ${rid}
    ...    msg=SM_BATCH_REQUEST_ID empty — run TC_SM_005 first to capture GC Request Id from notifications.
    SM Verify Sim Movement Batch Job Detail For Request Id    ${rid}    ${SM_TARGET_BU_ACCOUNT}    ${SM_BJL_DETAIL_SUBSTRING}
    Log    PASS: Batch Job Log SIM movement detail verified for Request Id ${rid}.

TC_SM_012
    [Documentation]    Without selecting any SIM, SIM Movement action should be blocked.
    ...                The action dropdown may be disabled OR the modal should not open.
    SM Navigate To Manage Devices
    # Action dropdown may be disabled when no SIM is selected — both outcomes are valid
    ${enabled}=    Run Keyword And Return Status
    ...    Wait Until Element Is Enabled    ${LOC_SM_ACTION_DROP}    timeout=5s
    IF    ${enabled}
        Select From List By Value    ${LOC_SM_ACTION_DROP}    ${SM_ACTION_VALUE}
        Sleep    1s
        ${modal_visible}=    Run Keyword And Return Status
        ...    Element Should Be Visible    ${LOC_SM_MODAL}
        Run Keyword If    ${modal_visible}
        ...    Fail    SIM Movement modal should not open when no SIM is selected
        Log    PASS: Dropdown usable but modal did not appear without SIM selection.
    ELSE
        Log    PASS: Action dropdown is disabled when no SIM is selected.
    END

TC_SM_013
    [Documentation]    Open SIM Movement modal then close it; SIM should not be moved.
    ${iccid}=    SM Get Or Resolve ICCID
    SM Navigate To Manage Devices
    SM Search And Select SIM By ICCID    ${iccid}
    SM Open SIM Movement Modal
    SM Close SIM Movement Modal
    # Verify the SIM movement was cancelled — SIM selection still exists in grid
    # (No toast/success message should appear; grid row still selected)
    ${has_success}=    Run Keyword And Return Status
    ...    Page Should Contain Element    ${LOC_SM_SUCCESS_MSG}
    Should Not Be True    ${has_success}
    ...    msg=SIM Movement should NOT have completed but a success message appeared!
    Log    PASS: SIM Movement cancelled without submitting. No success message confirmed.

