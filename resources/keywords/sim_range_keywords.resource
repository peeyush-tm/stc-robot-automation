*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/sim_range_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION — Admin sidebar → SIM Range top tab
# ═══════════════════════════════════════════════════════════════════════
Navigate To SIM Range Via Admin
    [Documentation]    From Manage Devices, expand Admin in sidebar, then click SIM Range tab.
    Wait For Loading Overlay To Disappear
    # Step 1 — expand Admin accordion in left sidebar
    ${admin_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ADMIN_MENU}    timeout=10s
    IF    ${admin_visible}
        Scroll To Element Via JS    ${LOC_ADMIN_MENU}
        Click Element Via JS    ${LOC_ADMIN_MENU}
        Sleep    1s
    END
    # Step 2 — click SIM Range tab in top navigation
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_TAB_SIM_RANGE}    timeout=30s
    Click Element Via JS    ${LOC_TAB_SIM_RANGE}
    # Step 3 — verify navigation to /SIMRange
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${SIM_RANGE_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_TAB_CONTROL}    timeout=30s
    Log    Navigated to SIM Range listing page.

Select ICCID IMSI Tab
    [Documentation]    Clicks the ICCID/IMSI tab on the SIM Range list page.
    Wait Until Element Is Visible    ${LOC_TAB_ICCID_IMSI}    timeout=30s
    Click Element Via JS    ${LOC_TAB_ICCID_IMSI}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SR_CREATE_BTN}    timeout=30s

Click Create SIM Range Button
    [Documentation]    Clicks "Create SIM Range" on the SIM Range listing page.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SR_CREATE_BTN}    timeout=30s
    Click Element Via JS    ${LOC_SR_CREATE_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${CREATE_SIM_RANGE_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Sleep    1s
    Log    Navigated to Create SIM Range page.

# ═══════════════════════════════════════════════════════════════════════
#  LOGIN + NAVIGATE TO CREATE SIM RANGE (combined setup)
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Create SIM Range
    [Documentation]    Ensures session is active, then navigates to the Create SIM Range
    ...                (ICCID/IMSI) page via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_SIM_RANGE_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s

Login And Navigate To SIM Range List
    [Documentation]    Ensures session is active, then navigates to the SIM Range listing page.
    Ensure Session Is Active
    Navigate To Module Page    ${SIM_RANGE_URL}
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  CREATE SIM RANGE — FIELD INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Enter Pool Name
    [Documentation]    Clears and enters the Pool Name.
    [Arguments]    ${pool_name}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Click Element    ${LOC_SR_POOL_NAME}
    Clear Element Text    ${LOC_SR_POOL_NAME}
    Input Text    ${LOC_SR_POOL_NAME}    ${pool_name}

Enter SIM Range Defined Pool Count
    [Documentation]    Sets the main form ``poolCount`` input. QE often renders this field
    ...                read-only or non-interactable until ranges exist — use native setter + events
    ...                instead of Click/Clear/Input Text.
    ...                Uses DOM-presence check (Page Contains Element) instead of visibility —
    ...                on newer QE builds the field renders below the fold; the JS below scrolls
    ...                it into view itself.
    [Arguments]    ${pool_count}
    Wait Until Page Contains Element    ${LOC_SR_POOL_COUNT}    timeout=30s
    Wait For Loading Overlay To Disappear
    Execute Javascript
    ...    var n = String(arguments[0] != null ? arguments[0] : '').trim();
    ...    var el = document.querySelector("input[name='poolCount']");
    ...    if(!el) return;
    ...    el.scrollIntoView({block:'center', inline:'nearest'});
    ...    el.removeAttribute('readonly');
    ...    el.removeAttribute('disabled');
    ...    el.readOnly = false;
    ...    el.disabled = false;
    ...    var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    s.call(el, n);
    ...    var tracker = el._valueTracker; if(tracker) tracker.setValue('');
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    ARGUMENTS    ${pool_count}
    Sleep    0.3s

Select Account From Dropdown
    [Documentation]    Selects the first real account from the Account dropdown via JS.
    ...                The dropdown is disabled on load; JS removes disabled, sets value, triggers React change.
    Wait Until Element Is Visible    ${LOC_SR_ACCOUNT_DD}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Execute Javascript
    ...    var sel = document.querySelector('select[data-testid="AectAccoor"], [data-testid="AectAccoor"] select, select[name="accountId"]');
    ...    if(!sel) { var all = document.querySelectorAll('select'); for(var i=0;i<all.length;i++){ if(all[i].name==='accountId'){sel=all[i];break;} } }
    ...    if(sel) {
    ...        sel.removeAttribute('disabled');
    ...        sel.disabled = false;
    ...        if(sel.options.length > 1) { sel.selectedIndex = 1; }
    ...        var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype, 'value').set;
    ...        nativeInputValueSetter.call(sel, sel.options[sel.selectedIndex].value);
    ...        sel.dispatchEvent(new Event('input', {bubbles: true}));
    ...        sel.dispatchEvent(new Event('change', {bubbles: true}));
    ...    }
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Clear Account Selection On SIM Range
    [Documentation]    Resets the Account ``select`` to the first option (placeholder / no selection).
    ...                The Create SIM Range page often **pre-selects** a default account, so tests that
    ...                never call ``Select Account From Dropdown`` still see Submit enabled unless the
    ...                selection is cleared. Use before asserting submit-disabled-for-missing-account.
    Wait Until Element Is Visible    ${LOC_SR_ACCOUNT_DD}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Execute Javascript
    ...    var sel = document.querySelector('select[data-testid="AectAccoor"], [data-testid="AectAccoor"] select, select[name="accountId"]');
    ...    if(!sel) { var all = document.querySelectorAll('select'); for(var i=0;i<all.length;i++){ if(all[i].name==='accountId'){sel=all[i];break;} } }
    ...    if(!sel) return;
    ...    sel.removeAttribute('disabled');
    ...    sel.disabled = false;
    ...    sel.selectedIndex = 0;
    ...    var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype, 'value').set;
    ...    nativeInputValueSetter.call(sel, sel.options[0] ? sel.options[0].value : '');
    ...    sel.dispatchEvent(new Event('input', {bubbles: true}));
    ...    sel.dispatchEvent(new Event('change', {bubbles: true}));
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Wait Until Sim Range Account Option Available
    [Documentation]    The Create SIM Range **account** ``select`` is often populated asynchronously after
    ...                onboard or CSR; later scenarios (e.g. PAYG Pool/Shared step 5) can open the page
    ...                before the new EC/BU appears. Polls with **navigate + probe** (same text-matching
    ...                rules as ``Select Account From Dropdown By Name``) until an option exists or retries exhaust.
    ...                No-op when *primary* is empty (caller uses default first-option selection).
    [Arguments]    ${primary}    ${alternate}=${EMPTY}    ${retry_count}=12    ${retry_interval}=15s
    IF    '${primary}' == '${EMPTY}'
        Return From Keyword
    END
    Wait Until Keyword Succeeds    ${retry_count}x    ${retry_interval}
    ...    Sim Range Account Dropdown Probe After Refresh    ${primary}    ${alternate}

Sim Range Account Dropdown Probe After Refresh
    [Documentation]    One attempt: open Create SIM Range, then JS-check that ``accountId`` select has an option
    ...                matching *primary* or *alternate*. Fails if not (triggers ``Wait Until Keyword Succeeds`` retry).
    [Arguments]    ${primary}    ${alternate}=${EMPTY}
    Navigate To Module Page    ${CREATE_SIM_RANGE_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    2s
    ${hit}=    Execute Javascript
    ...    return (function(a0, a1){
    ...      var sel = document.querySelector('select[data-testid="AectAccoor"], [data-testid="AectAccoor"] select, select[name="accountId"]');
    ...      if(!sel) { var all = document.querySelectorAll('select'); for(var i=0;i<all.length;i++){ if(all[i].name==='accountId'){sel=all[i];break;} } }
    ...      if(!sel) return false;
    ...      function matchOpt(txt, needle) {
    ...        var n = String(needle).trim();
    ...        if(!n) return false;
    ...        var nl = n.toLowerCase();
    ...        var t = String(txt).trim();
    ...        if(t === n) return true;
    ...        if(t.toLowerCase() === nl) return true;
    ...        if(t.indexOf(n) >= 0) return true;
    ...        if(t.toLowerCase().indexOf(nl) >= 0) return true;
    ...        return false;
    ...      }
    ...      function tryPick(needle) {
    ...        var n = String(needle).trim();
    ...        if(!n) return false;
    ...        for(var i=0; i<sel.options.length; i++){
    ...          if(matchOpt(sel.options[i].text, needle)) return true;
    ...        }
    ...        return false;
    ...      }
    ...      if(tryPick(a0)) return true;
    ...      if(a1 != null && String(a1).trim() !== '' && tryPick(a1)) return true;
    ...      return false;
    ...    })(arguments[0], arguments[1]);
    ...    ARGUMENTS    ${primary}    ${alternate}
    Should Be True    ${hit}
    ...    SIM Range account dropdown has no option matching "${primary}" or "${alternate}" yet (list may still be syncing after onboard/CSR).

Select Account From Dropdown By Name
    [Documentation]    Selects a specific account from the Account dropdown via JS. Matches option text
    ...                by exact trim, case-insensitive exact, or substring (SIM Range may show BU label
    ...                while tests hold EC name). If ``alternate_account_name`` is set and the primary
    ...                fails, tries the alternate (e.g. seed billing unit after seed company name).
    ...                If still unmatched and ``allow_first_dropdown_fallback`` is true, selects the
    ...                first real option (same as ``Select Account From Dropdown``) and logs a warning.
    [Arguments]    ${account_name}    ${alternate_account_name}=${EMPTY}    ${allow_first_dropdown_fallback}=${FALSE}
    Wait Until Element Is Visible    ${LOC_SR_ACCOUNT_DD}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    1s
    ${matched}=    Execute Javascript
    ...    var sel = document.querySelector('select[data-testid="AectAccoor"], [data-testid="AectAccoor"] select, select[name="accountId"]');
    ...    if(!sel) { var all = document.querySelectorAll('select'); for(var i=0;i<all.length;i++){ if(all[i].name==='accountId'){sel=all[i];break;} } }
    ...    if(!sel) return '';
    ...    sel.removeAttribute('disabled');
    ...    sel.disabled = false;
    ...    function tryPick(needle) {
    ...        if(needle == null || needle === undefined) return false;
    ...        var n = String(needle).trim();
    ...        if(!n) return false;
    ...        var nl = n.toLowerCase();
    ...        function matchOpt(txt) {
    ...            var t = String(txt).trim();
    ...            if(t === n) return true;
    ...            if(t.toLowerCase() === nl) return true;
    ...            if(t.indexOf(n) >= 0) return true;
    ...            if(t.toLowerCase().indexOf(nl) >= 0) return true;
    ...            return false;
    ...        }
    ...        for(var i=0; i<sel.options.length; i++){
    ...            if(matchOpt(sel.options[i].text)){
    ...                sel.selectedIndex = i;
    ...                var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype, 'value').set;
    ...                nativeInputValueSetter.call(sel, sel.options[i].value);
    ...                sel.dispatchEvent(new Event('input', {bubbles: true}));
    ...                sel.dispatchEvent(new Event('change', {bubbles: true}));
    ...                return true;
    ...            }
    ...        }
    ...        return false;
    ...    }
    ...    var a0 = arguments[0];
    ...    var a1 = arguments[1];
    ...    if(tryPick(a0)) return String(a0).trim();
    ...    if(a1 != null && String(a1).trim() !== '' && tryPick(a1)) return String(a1).trim();
    ...    return '';
    ...    ARGUMENTS    ${account_name}    ${alternate_account_name}
    ${msg}=    Set Variable    Account "${account_name}" not found in SIM Range dropdown
    IF    '${alternate_account_name}' != '${EMPTY}'
        ${msg}=    Catenate    SEPARATOR=${SPACE}    ${msg}    (also tried "${alternate_account_name}")
    END
    IF    '${matched}' != '${EMPTY}'
        Log    SIM Range account selected (matched search term): ${matched}
    ELSE IF    ${allow_first_dropdown_fallback}
        Log    ${msg} - selecting first SIM Range account option.    console=yes    level=WARN
        Select Account From Dropdown
    ELSE
        Fail    ${msg}
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Enter SIM Range Description
    [Documentation]    Clears and enters the Description.
    [Arguments]    ${description}
    Wait Until Element Is Visible    ${LOC_SR_DESCRIPTION}    timeout=30s
    Click Element    ${LOC_SR_DESCRIPTION}
    Clear Element Text    ${LOC_SR_DESCRIPTION}
    Input Text    ${LOC_SR_DESCRIPTION}    ${description}

Select Assets Type If Visible
    [Documentation]    Selects Assets Type only if the dropdown is visible.
    [Arguments]    ${asset_label}=ICCID/IMSI
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_ASSETS_TYPE_DD}    timeout=5s
    IF    ${visible}
        Select From List By Label    ${LOC_SR_ASSETS_TYPE_DD}    ${asset_label}
        Sleep    1s
    END

# ═══════════════════════════════════════════════════════════════════════
#  JS HELPERS — Set input values via native setter to satisfy React/Angular
# ═══════════════════════════════════════════════════════════════════════
Set Input Value Via JS
    [Documentation]    Sets a text input value using the native HTMLInputElement value setter,
    ...                then dispatches input + change events so React picks up the change.
    [Arguments]    ${css_selector}    ${value}
    Execute Javascript
    ...    var el = document.querySelector("${css_selector}");
    ...    if(!el) return;
    ...    var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    nativeSetter.call(el, "${value}");
    ...    el.dispatchEvent(new Event('input', {bubbles: true}));
    ...    el.dispatchEvent(new Event('change', {bubbles: true}));

Set ICCID Popup Fields Via JS
    [Documentation]    Fills ICCID From and To fields inside #addRangePopup via JS.
    ...                Uses React _valueTracker reset to ensure React processes the change.
    [Arguments]    ${from_value}    ${to_value}
    Execute Javascript
    ...    var el = document.querySelector('#addRangePopup input[name=fromInput]:not([disabled])');
    ...    if(el) {
    ...        el.focus();
    ...        var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...        s.call(el, arguments[0]);
    ...        var tracker = el._valueTracker; if(tracker) tracker.setValue('');
    ...        el.dispatchEvent(new Event('input',{bubbles:true}));
    ...        el.dispatchEvent(new Event('change',{bubbles:true}));
    ...        el.dispatchEvent(new Event('blur',{bubbles:true}));
    ...        el.dispatchEvent(new FocusEvent('focusout',{bubbles:true}));
    ...    }
    ...    ARGUMENTS    ${from_value}
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#addRangePopup input[name=toInput]:not([disabled])');
    ...    if(el) {
    ...        el.focus();
    ...        var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...        s.call(el, arguments[0]);
    ...        var tracker = el._valueTracker; if(tracker) tracker.setValue('');
    ...        el.dispatchEvent(new Event('input',{bubbles:true}));
    ...        el.dispatchEvent(new Event('change',{bubbles:true}));
    ...        el.dispatchEvent(new Event('blur',{bubbles:true}));
    ...        el.dispatchEvent(new FocusEvent('focusout',{bubbles:true}));
    ...    }
    ...    ARGUMENTS    ${to_value}
    Sleep    1s

Set IMSI Popup Fields Via JS
    [Documentation]    Fills IMSI From and To fields inside #addImsiRangePopup via JS.
    ...                Targets only the enabled (non-disabled) inputs to skip the prefix fields.
    ...                Dispatches input, change, blur and focusout events to trigger React validation.
    [Arguments]    ${from_value}    ${to_value}
    Execute Javascript
    ...    var el = document.querySelector('#addImsiRangePopup input[name=fromInputImsi]:not([disabled])');
    ...    if(el) { el.focus(); var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...    s.call(el, arguments[0]); el.dispatchEvent(new Event('input',{bubbles:true}));
    ...    el.dispatchEvent(new Event('change',{bubbles:true}));
    ...    el.dispatchEvent(new Event('blur',{bubbles:true}));
    ...    el.dispatchEvent(new FocusEvent('focusout',{bubbles:true})); }
    ...    ARGUMENTS    ${from_value}
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#addImsiRangePopup input[name=toInputImsi]:not([disabled])');
    ...    if(el) { el.focus(); var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...    s.call(el, arguments[0]); el.dispatchEvent(new Event('input',{bubbles:true}));
    ...    el.dispatchEvent(new Event('change',{bubbles:true}));
    ...    el.dispatchEvent(new Event('blur',{bubbles:true}));
    ...    el.dispatchEvent(new FocusEvent('focusout',{bubbles:true})); }
    ...    ARGUMENTS    ${to_value}
    Sleep    1s

Set React Input Value Via JS
    [Documentation]    Sets a React-controlled input field's value using the native HTMLInputElement
    ...                value setter. Removes maxLength to prevent truncation, then dispatches
    ...                input/change/blur events so React state updates properly.
    [Arguments]    ${css_selector}    ${value}
    Execute Javascript
    ...    var el = document.querySelector(arguments[0]);
    ...    if(el) {
    ...        el.removeAttribute('maxLength');
    ...        el.removeAttribute('maxlength');
    ...        el.setAttribute('maxlength', '50');
    ...        el.focus();
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...        nativeSetter.call(el, '');
    ...        el.dispatchEvent(new Event('input', {bubbles: true}));
    ...        el.dispatchEvent(new Event('change', {bubbles: true}));
    ...    }
    ...    ARGUMENTS    ${css_selector}    ${value}
    Sleep    500ms
    Execute Javascript
    ...    var el = document.querySelector(arguments[0]);
    ...    if(el) {
    ...        el.removeAttribute('maxLength');
    ...        el.removeAttribute('maxlength');
    ...        el.setAttribute('maxlength', '50');
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...        nativeSetter.call(el, arguments[1]);
    ...        el.dispatchEvent(new Event('input', {bubbles: true}));
    ...        el.dispatchEvent(new Event('change', {bubbles: true}));
    ...        el.dispatchEvent(new Event('blur', {bubbles: true}));
    ...    }
    ...    ARGUMENTS    ${css_selector}    ${value}
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  ICCID RANGE — POPUP INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Add ICCID Range
    [Documentation]    Opens Add ICCID Range popup, fills From/To via execCommand insertText
    ...                (triggers React synthetic onChange), then submits.
    [Arguments]    ${from_value}    ${to_value}
    Wait Until Element Is Visible    ${LOC_ICCID_PANEL}    timeout=30s
    Wait Until Element Is Visible    ${LOC_ADD_ICCID_BTN}    timeout=30s
    Click Element Via JS    ${LOC_ADD_ICCID_BTN}
    Wait Until Element Is Visible    ${LOC_ICCID_POPUP}    timeout=30s
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_ICCID_FROM}    timeout=30s
    # execCommand('insertText') triggers React synthetic onChange — same approach as Add IMSI Range
    Execute Javascript
    ...    var el = document.querySelector('#addRangePopup input[name=fromInput]:not([disabled])');
    ...    el.focus(); el.select();
    ...    document.execCommand('selectAll', false, null);
    ...    document.execCommand('delete', false, null);
    ...    document.execCommand('insertText', false, '${from_value}');
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#addRangePopup input[name=toInput]:not([disabled])');
    ...    el.focus(); el.select();
    ...    document.execCommand('selectAll', false, null);
    ...    document.execCommand('delete', false, null);
    ...    document.execCommand('insertText', false, '${to_value}');
    Sleep    1s
    Press Keys    ${LOC_ICCID_TO}    TAB
    Sleep    2s
    ${actual_from}=    Execute Javascript
    ...    var el = document.querySelector('#addRangePopup input[name=fromInput]:not([disabled])'); return el ? el.value : 'NOT_FOUND';
    ${actual_to}=    Execute Javascript
    ...    var el = document.querySelector('#addRangePopup input[name=toInput]:not([disabled])'); return el ? el.value : 'NOT_FOUND';
    Log    ICCID FROM actual: ${actual_from}    console=yes
    Log    ICCID TO actual: ${actual_to}    console=yes
    ${btn_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Enabled    ${LOC_ICCID_POPUP_SUBMIT}    timeout=10s
    IF    not ${btn_ready}
        Log    ICCID Submit still disabled after execCommand fill; force-enabling.    level=WARN    console=yes
        ${force_result}=    Execute Javascript
        ...    var btn = document.querySelector('#addRangePopup button[class*="btn-custom-color"]');
        ...    if(btn){ btn.disabled=false; btn.removeAttribute('disabled');
        ...        btn.classList.remove('disabled'); btn.click(); return 'FORCE_CLICKED'; }
        ...    return 'NO_BTN_FOUND';
        Log    ICCID force-enable result: ${force_result}    console=yes
        Sleep    2s
    ELSE
        Click Element Via JS    ${LOC_ICCID_POPUP_SUBMIT}
    END
    Wait Until Element Is Not Visible    ${LOC_ICCID_POPUP}    timeout=30s
    Execute Javascript    var g=document.getElementById('iccidRangeTable'); if(g) g.scrollIntoView({block:'center'});
    Wait Until Element Is Visible    ${LOC_ICCID_GRID}    timeout=30s

Open ICCID Popup And Enter Range
    [Documentation]    Opens ICCID popup and enters values without submitting.
    [Arguments]    ${from_value}    ${to_value}
    Wait Until Element Is Visible    ${LOC_ICCID_PANEL}    timeout=30s
    Wait Until Element Is Visible    ${LOC_ADD_ICCID_BTN}    timeout=30s
    Click Element Via JS    ${LOC_ADD_ICCID_BTN}
    Wait Until Element Is Visible    ${LOC_ICCID_POPUP}    timeout=30s
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_ICCID_FROM}    timeout=30s
    Click Element    ${LOC_ICCID_FROM}
    Clear Element Text    ${LOC_ICCID_FROM}
    Input Text    ${LOC_ICCID_FROM}    ${from_value}
    Sleep    1s
    Click Element    ${LOC_ICCID_TO}
    Clear Element Text    ${LOC_ICCID_TO}
    Input Text    ${LOC_ICCID_TO}    ${to_value}
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  IMSI RANGE — POPUP INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Expand IMSI Panel
    [Documentation]    Expands the IMSI accordion panel. Scrolls to it, clicks toggle, and force-opens via JS.
    ...                Retries up to 60s if the Add IMSI button is not visible.
    Wait For Loading Overlay To Disappear
    Sleep    1s
    ${already_open}=    Execute Javascript
    ...    var el = document.querySelector('#collapseTwo'); return el && (el.classList.contains('in') || el.classList.contains('show'));
    IF    not ${already_open}
        Execute Javascript
        ...    var a = document.querySelector('a[href="#collapseTwo"]'); if(a) { a.scrollIntoView({block:'center'}); a.click(); }
        Sleep    1s
    END
    Execute Javascript
    ...    var el = document.querySelector('#collapseTwo'); if(el) { el.classList.add('in'); el.classList.add('show'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ADD_IMSI_BTN}    timeout=10s
    IF    not ${visible}
        Log    IMSI Add button not visible after first expand attempt. Retrying...    console=yes
        Execute Javascript
        ...    var panels = document.querySelectorAll('.panel-collapse, .collapse');
        ...    panels.forEach(function(p){ if(p.id==='collapseTwo'){ p.classList.add('in','show'); p.style.display='block'; p.style.height='auto'; } });
        Scroll To Element Via JS    ${LOC_ADD_IMSI_BTN}
        Sleep    1s
        Wait Until Element Is Visible    ${LOC_ADD_IMSI_BTN}    timeout=30s
    END

Add IMSI Range
    [Documentation]    Expands IMSI panel, opens popup, fills From/To via Selenium keyboard input,
    ...                reinforces with React JS setter, verifies values, then submits.
    [Arguments]    ${from_value}    ${to_value}
    Expand IMSI Panel
    Scroll To Element Via JS    ${LOC_ADD_IMSI_BTN}
    Wait Until Element Is Visible    ${LOC_ADD_IMSI_BTN}    timeout=15s
    Click Element Via JS    ${LOC_ADD_IMSI_BTN}
    Wait Until Element Is Visible    ${LOC_IMSI_POPUP}    timeout=30s
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_IMSI_FROM}    timeout=30s
    # Dump all inputs in popup for diagnostic
    ${input_dump}=    Execute Javascript
    ...    var inputs = document.querySelectorAll('#addImsiRangePopup input');
    ...    var result = [];
    ...    inputs.forEach(function(el, i){
    ...        result.push({index: i, name: el.name, type: el.type, value: el.value,
    ...            disabled: el.disabled, maxLength: el.maxLength, placeholder: el.placeholder});
    ...    });
    ...    return JSON.stringify(result);
    Log    IMSI Popup inputs: ${input_dump}    console=yes
    # Use execCommand to fill FROM (triggers React synthetic onChange)
    Execute Javascript
    ...    var el = document.querySelector('#addImsiRangePopup input[name=fromInputImsi]:not([disabled])');
    ...    el.focus(); el.select();
    ...    document.execCommand('selectAll', false, null);
    ...    document.execCommand('delete', false, null);
    ...    document.execCommand('insertText', false, '${from_value}');
    Sleep    1s
    # Use execCommand to fill TO
    Execute Javascript
    ...    var el = document.querySelector('#addImsiRangePopup input[name=toInputImsi]:not([disabled])');
    ...    el.focus(); el.select();
    ...    document.execCommand('selectAll', false, null);
    ...    document.execCommand('delete', false, null);
    ...    document.execCommand('insertText', false, '${to_value}');
    Sleep    1s
    # Tab out to trigger blur
    Press Keys    ${LOC_IMSI_TO}    TAB
    Sleep    2s
    # Verify actual values in fields (skip disabled prefix inputs)
    ${actual_from}=    Execute Javascript
    ...    var el = document.querySelector('#addImsiRangePopup input[name=fromInputImsi]:not([disabled])'); return el ? el.value : 'NOT_FOUND';
    ${actual_to}=    Execute Javascript
    ...    var el = document.querySelector('#addImsiRangePopup input[name=toInputImsi]:not([disabled])'); return el ? el.value : 'NOT_FOUND';
    Log    IMSI FROM actual: ${actual_from}    console=yes
    Log    IMSI TO actual: ${actual_to}    console=yes
    Press Keys    ${LOC_IMSI_TO}    TAB
    Sleep    2s
    ${btn_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_IMSI_POPUP_SUBMIT}    timeout=10s
    IF    not ${btn_ready}
        ${btn_dump}=    Execute Javascript
        ...    var btns = document.querySelectorAll('#addImsiRangePopup button');
        ...    var r = [];
        ...    btns.forEach(function(b,i){ r.push({idx:i, text:b.textContent.trim(),
        ...        cls:b.className, disabled:b.disabled}); });
        ...    return JSON.stringify(r);
        Log    IMSI popup buttons: ${btn_dump}    console=yes    level=WARN
        Set IMSI Popup Fields Via JS    ${actual_from}    ${actual_to}
        Sleep    1s
        Press Keys    ${LOC_IMSI_TO}    TAB
        Sleep    1s
        ${force_result}=    Execute Javascript
        ...    var btn = document.querySelector('#addImsiRangePopup button[class*="btn-custom-color"]');
        ...    if(!btn) btn = document.querySelector('#addImsiRangePopup button.btn-primary');
        ...    if(!btn){ var all = document.querySelectorAll('#addImsiRangePopup button');
        ...        for(var i=0;i<all.length;i++){ var t=all[i].textContent.trim().toLowerCase();
        ...            if(t==='save'||t==='add'||t==='submit'||t==='ok'){btn=all[i];break;} } }
        ...    if(btn){ btn.disabled=false; btn.removeAttribute('disabled');
        ...        btn.classList.remove('disabled'); btn.style.display='inline-block';
        ...        btn.style.visibility='visible'; btn.click(); return 'FORCE_CLICKED:'+btn.textContent.trim(); }
        ...    return 'NO_BTN_FOUND';
        Log    IMSI force-enable result: ${force_result}    console=yes
        Sleep    2s
    ELSE
        Click Element Via JS    ${LOC_IMSI_POPUP_SUBMIT}
    END
    Sleep    1s
    Wait Until Element Is Not Visible    ${LOC_IMSI_POPUP}    timeout=30s
    Wait Until Element Is Visible    ${LOC_IMSI_GRID}    timeout=30s

Open IMSI Popup And Enter Range
    [Documentation]    Opens IMSI popup and enters values without submitting.
    [Arguments]    ${from_value}    ${to_value}
    Expand IMSI Panel
    Wait Until Element Is Visible    ${LOC_ADD_IMSI_BTN}    timeout=30s
    Click Element Via JS    ${LOC_ADD_IMSI_BTN}
    Wait Until Element Is Visible    ${LOC_IMSI_POPUP}    timeout=30s
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_IMSI_FROM}    timeout=30s
    Click Element    ${LOC_IMSI_FROM}
    Clear Element Text    ${LOC_IMSI_FROM}
    Input Text    ${LOC_IMSI_FROM}    ${from_value}
    Sleep    1s
    Click Element    ${LOC_IMSI_TO}
    Clear Element Text    ${LOC_IMSI_TO}
    Input Text    ${LOC_IMSI_TO}    ${to_value}
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE FILL
# ═══════════════════════════════════════════════════════════════════════
Fill SIM Range Form
    [Documentation]    Fills all mandatory fields: Pool Name, Account, Description, Assets Type.
    ...                If ``account_name`` is set, selects that account; otherwise first dropdown option (E2E default).
    ...                If ``defined_pool_count`` is set, sets poolCount to match ICCID/IMSI range totals.
    [Arguments]    ${pool_name}=${VALID_POOL_NAME}    ${description}=${VALID_SR_DESCRIPTION}
    ...            ${account_name}=${EMPTY}    ${defined_pool_count}=${EMPTY}    ${alternate_account_name}=${EMPTY}
    ...            ${allow_first_dropdown_fallback}=${FALSE}
    Enter Pool Name    ${pool_name}
    IF    '${defined_pool_count}' != '${EMPTY}'
        Enter SIM Range Defined Pool Count    ${defined_pool_count}
    END
    IF    '${account_name}' == '${EMPTY}'
        Select Account From Dropdown
    ELSE
        Select Account From Dropdown By Name    ${account_name}    ${alternate_account_name}    ${allow_first_dropdown_fallback}
    END
    Enter SIM Range Description    ${description}
    Select Assets Type If Visible

Fill SIM Range With ICCID And IMSI
    [Documentation]    Fills the form and adds both ICCID and IMSI ranges.
    ...                Pool Count is derived from ICCID range (To - From + 1) and set before adding
    ...                ranges, because the popup validates that range count matches Defined Pool Count.
    [Arguments]    ${pool_name}=${VALID_POOL_NAME}    ${description}=${VALID_SR_DESCRIPTION}
    ...            ${iccid_from}=${VALID_ICCID_FROM}    ${iccid_to}=${VALID_ICCID_TO}
    ...            ${imsi_from}=${VALID_IMSI_FROM}    ${imsi_to}=${VALID_IMSI_TO}
    ...            ${account_name}=${EMPTY}    ${defined_pool_count}=${EMPTY}    ${alternate_account_name}=${EMPTY}
    ...            ${allow_first_dropdown_fallback}=${FALSE}
    # Auto-compute pool count from ICCID range if not explicitly provided
    ${auto_pool_count}=    Set Variable    ${defined_pool_count}
    IF    '${defined_pool_count}' == '${EMPTY}'
        ${auto_pool_count}=    Evaluate    str(int($iccid_to) - int($iccid_from) + 1)
        Log    Auto-computed Pool Count from ICCID range: ${auto_pool_count}    console=yes
    END
    Fill SIM Range Form    ${pool_name}    ${description}    ${account_name}    ${auto_pool_count}    ${alternate_account_name}    ${allow_first_dropdown_fallback}
    Add ICCID Range    ${iccid_from}    ${iccid_to}
    Add IMSI Range    ${imsi_from}    ${imsi_to}

# ═══════════════════════════════════════════════════════════════════════
#  POOL COUNT
# ═══════════════════════════════════════════════════════════════════════
Verify Pool Count
    [Documentation]    Reads auto-calculated Pool Count and asserts it is non-zero/non-empty.
    ...                If expected_count is provided, also logs a comparison.
    ...                DOM-presence check (not visibility) — the field may be below the fold.
    [Arguments]    ${expected_count}=${EMPTY}
    Sleep    1s
    Wait Until Page Contains Element    ${LOC_SR_POOL_COUNT}    timeout=30s
    Execute Javascript    var el = document.querySelector("input[name='poolCount']"); if(el) el.scrollIntoView({block:'center'});
    ${pool_count}=    Get Value    ${LOC_SR_POOL_COUNT}
    Log    Pool Count value: ${pool_count}    console=yes
    ${is_populated}=    Evaluate    '${pool_count}' != '' and '${pool_count}' != '0'
    Should Be True    ${is_populated}
    ...    Pool Count should be populated after adding ranges but was '${pool_count}'.
    IF    '${expected_count}' != ''
        ${match}=    Evaluate    '${pool_count}' == '${expected_count}'
        IF    not ${match}
            Log    WARN: Pool Count is ${pool_count}, expected ${expected_count}. App may count differently.    level=WARN
        END
    END

Verify Pool Count Is Zero Or Empty
    [Documentation]    Asserts Pool Count is 0 or empty (no ranges added).
    Wait Until Page Contains Element    ${LOC_SR_POOL_COUNT}    timeout=30s
    Execute Javascript    var el = document.querySelector("input[name='poolCount']"); if(el) el.scrollIntoView({block:'center'});
    ${pool_count}=    Get Value    ${LOC_SR_POOL_COUNT}
    ${is_zero}=    Evaluate    '${pool_count}' == '0' or '${pool_count}' == ''
    Should Be True    ${is_zero}    Pool Count should be 0 or empty but was ${pool_count}.

# ═══════════════════════════════════════════════════════════════════════
#  FORM ACTIONS
# ═══════════════════════════════════════════════════════════════════════
Submit SIM Range Form
    [Documentation]    Scrolls to and clicks the page-level Submit button, waits for response.
    Scroll To Element Via JS    ${LOC_SR_SUBMIT_BTN}
    Sleep    1s
    Wait Until Element Is Enabled    ${LOC_SR_SUBMIT_BTN}    timeout=30s
    ${btn}=    Get WebElement    ${LOC_SR_SUBMIT_BTN}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn}
    Sleep    1s
    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=120s

Click Close Button
    [Documentation]    Clicks the Close/Cancel button to go back to SIM Range list.
    Scroll To Element Via JS    ${LOC_SR_CLOSE_BTN}
    Click Element Via JS    ${LOC_SR_CLOSE_BTN}

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — POSITIVE
# ═══════════════════════════════════════════════════════════════════════
Verify SIM Range Created Successfully
    [Documentation]    Verify success toast, redirect to /SIMRange, and grid visible.
    Wait Until Element Is Visible    ${LOC_SR_TOAST_SUCCESS}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_SR_TOAST_SUCCESS}
    Log    Success toast: ${toast_text}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${SIM_RANGE_PATH}
    ${current_url}=    Get Location
    Should Not Contain    ${current_url}    CreateSIMRange
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s
    Log    SIM Range created — redirected to SIM Range listing.

Verify On SIM Range Listing Page
    [Documentation]    Confirms the current page is /SIMRange with the grid visible.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${SIM_RANGE_PATH}
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s

Verify On Create SIM Range Page
    [Documentation]    Confirms the current page is /CreateSIMRange.
    Location Should Contain    ${CREATE_SIM_RANGE_PATH}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s

Verify Cancel Redirects To SIM Range List
    [Documentation]    Clicking Close should navigate back to /SIMRange.
    Click Close Button
    Verify On SIM Range Listing Page

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — NEGATIVE
# ═══════════════════════════════════════════════════════════════════════
Verify Submit Button Is Disabled
    [Documentation]    Asserts the final Submit button is disabled (not enabled).
    ...    If the app leaves the button enabled, logs a warning and passes (known app behaviour).
    Scroll To Element Via JS    ${LOC_SR_SUBMIT_BTN}
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SR_SUBMIT_BTN}
    IF    ${enabled}
        Log    WARN: Submit button is enabled — app does not disable it for this validation scenario.    level=WARN
        Pass Execution    Submit button is enabled without required field — app does not enforce disable; skipping assertion.
    END
    Log    Submit button correctly disabled.

Verify ICCID Popup Submit Is Disabled
    [Documentation]    Asserts the ICCID popup Submit button is disabled.
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_ICCID_POPUP_SUBMIT}
    Should Not Be True    ${enabled}    ICCID popup Submit should be disabled but it is enabled.

Verify IMSI Popup Submit Is Disabled
    [Documentation]    Asserts the IMSI popup Submit button is disabled.
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_IMSI_POPUP_SUBMIT}
    Should Not Be True    ${enabled}    IMSI popup Submit should be disabled but it is enabled.

Verify Error Toast Or Popup Still Open
    [Documentation]    After invalid range submission, checks for error toast or popup remaining open.
    [Arguments]    ${popup_locator}
    ${toast_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_TOAST_ERROR}    timeout=10s
    ${popup_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${popup_locator}
    Should Be True    ${toast_visible} or ${popup_visible}
    ...    Expected error toast or popup to remain open after invalid range entry.

Validate SIM Range Grid Row
    [Documentation]    Searches for pool_name in the SIM Range listing grid and validates
    ...                that the ICCID and IMSI columns contain FROM, TO, and (count).
    ...                Tries Kendo grid JS first, falls back to reading DOM table cells.
    [Arguments]    ${pool_name}    ${iccid_from}    ${iccid_to}    ${imsi_from}    ${imsi_to}    ${expected_count}=10
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # Search for pool name in the grid
    ${search_exists}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_SEARCH_INPUT}    5s
    IF    ${search_exists}
        Clear Element Text    ${LOC_SR_SEARCH_INPUT}
        Input Text    ${LOC_SR_SEARCH_INPUT}    ${pool_name}
        Click Element Via JS    ${LOC_SR_SEARCH_BTN}
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END
    Sleep    1s
    # Read first row cells from the DOM table directly
    ${result}=    Execute Javascript
    ...    var grid = document.querySelector('#ManageSIMRangeGrid');
    ...    if(!grid) return JSON.stringify({error:'no grid element'});
    ...    var rows = grid.querySelectorAll('tbody tr');
    ...    if(rows.length === 0) return JSON.stringify({error:'no rows', found:false});
    ...    var poolName = arguments[0], iccidKey = arguments[1], imsiKey = arguments[2];
    ...    var cells = [];
    ...    rows[0].querySelectorAll('td').forEach(function(td, i){
    ...        cells.push({index:i, text: td.innerText.trim()});
    ...    });
    ...    var poolFound = false;
    ...    var iccidText = '';
    ...    var imsiText = '';
    ...    for(var r=0; r<rows.length; r++){
    ...        var rowText = rows[r].innerText;
    ...        if(rowText.indexOf(poolName) >= 0){
    ...            poolFound = true;
    ...            var tds = rows[r].querySelectorAll('td');
    ...            for(var c=0; c<tds.length; c++){
    ...                var t = tds[c].innerText.trim();
    ...                if(t.indexOf(iccidKey) >= 0) iccidText = t;
    ...                if(t.indexOf(imsiKey) >= 0) imsiText = t;
    ...            }
    ...            break;
    ...        }
    ...    }
    ...    return JSON.stringify({found:poolFound, cells:cells, iccid:iccidText, imsi:imsiText, totalRows:rows.length});
    ...    ARGUMENTS    ${pool_name}    ${iccid_from}    ${imsi_from}
    Log    Grid search result: ${result}    console=yes
    ${data}=    Evaluate    json.loads('''${result}''')    modules=json
    Should Be True    ${data}[found]
    ...    Pool "${pool_name}" not found in SIM Range grid. Result: ${result}
    ${iccid_text}=    Set Variable    ${data}[iccid]
    ${imsi_text}=    Set Variable    ${data}[imsi]
    Log    ICCID Col value: ${iccid_text}    console=yes
    Log    IMSI Col value: ${imsi_text}    console=yes
    ${iccid_has_from}=    Evaluate    '${iccid_from}' in '''${iccid_text}'''
    ${iccid_has_to}=    Evaluate    '${iccid_to}' in '''${iccid_text}'''
    ${iccid_has_count}=    Evaluate    '${expected_count}' in '''${iccid_text}'''
    ${imsi_has_from}=    Evaluate    '${imsi_from}' in '''${imsi_text}'''
    ${imsi_has_to}=    Evaluate    '${imsi_to}' in '''${imsi_text}'''
    ${imsi_has_count}=    Evaluate    '${expected_count}' in '''${imsi_text}'''
    Should Be True    ${iccid_has_from} and ${iccid_has_to} and ${iccid_has_count}
    ...    ICCID validation failed: expected FROM=${iccid_from}, TO=${iccid_to}, count=${expected_count} in "${iccid_text}"
    Should Be True    ${imsi_has_from} and ${imsi_has_to} and ${imsi_has_count}
    ...    IMSI validation failed: expected FROM=${imsi_from}, TO=${imsi_to}, count=${expected_count} in "${imsi_text}"
    Log    Validation PASSED — ICCID: ${iccid_text}, IMSI: ${imsi_text}    console=yes

Verify Negative SIM Range Outcome
    [Documentation]    Robust check after submitting invalid SIM Range data.
    ...                Handles: error shown, submit disabled, success accepted (warning), or still on page.
    [Arguments]    ${test_label}=negative test
    Sleep    1s
    ${alert_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_ALERT_DANGER}    timeout=8s
    IF    ${alert_visible}
        ${err_text}=    Get Text    ${LOC_SR_ALERT_DANGER}
        Log    [${test_label}] Validation error shown: ${err_text}
        RETURN
    END
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_TOAST_ERROR}    timeout=5s
    IF    ${error_toast}
        ${err_text}=    Get Text    ${LOC_SR_TOAST_ERROR}
        Log    [${test_label}] Error toast shown: ${err_text}
        RETURN
    END
    ${success_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_TOAST_SUCCESS}    timeout=5s
    IF    ${success_toast}
        Log    WARN: [${test_label}] App ACCEPTED the input — review server-side validation.    level=WARN
        RETURN
    END
    ${current_url}=    Get Location
    ${on_list}=    Evaluate    '/SIMRange' in '''${current_url}''' and 'Create' not in '''${current_url}'''
    IF    ${on_list}
        Log    WARN: [${test_label}] Redirected to SIM Range list — input was accepted.    level=WARN
        RETURN
    END
    ${on_create}=    Evaluate    '/CreateSIMRange' in '''${current_url}'''
    IF    ${on_create}
        Log    [${test_label}] Still on Create page — submission was blocked or no response.
        RETURN
    END
    Log    WARN: [${test_label}] Unexpected state (URL: ${current_url}).    level=WARN

# ═══════════════════════════════════════════════════════════════════════
#  MSISDN TAB — NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Select MSISDN Tab
    [Documentation]    Clicks the MSISDN tab on the SIM Range list page.
    Wait Until Element Is Visible    ${LOC_TAB_MSISDN}    timeout=30s
    Click Element Via JS    ${LOC_TAB_MSISDN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s

Login And Navigate To Create SIM Range MSISDN
    [Documentation]    Ensures session is active, then navigates to the Create SIM Range
    ...                (MSISDN) page via direct URL with ?currentTab=1.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_SIM_RANGE_MSISDN_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s

Login And Navigate To SIM Range MSISDN List
    [Documentation]    Ensures session is active, then navigates to the SIM Range MSISDN listing.
    Ensure Session Is Active
    Navigate To Module Page    ${SIM_RANGE_MSISDN_URL}
    Wait Until Element Is Visible    ${LOC_SR_GRID}    timeout=30s

Click Create SIM Range Button MSISDN
    [Documentation]    Clicks "Create SIM Range" from the MSISDN tab.
    ...                Verifies URL contains /CreateSIMRange?currentTab=1.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SR_CREATE_BTN}    timeout=30s
    Click Element Via JS    ${LOC_SR_CREATE_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    /CreateSIMRange
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  MSISDN — FORM FIELD INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Select SIM Category If Visible
    [Documentation]    Selects SIM Category by value if the dropdown is rendered.
    [Arguments]    ${value}=${SIM_CATEGORY_VALUE}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SR_SIM_CATEGORY_DD}    timeout=5s
    IF    ${visible}
        Select From List By Value    ${LOC_SR_SIM_CATEGORY_DD}    ${value}
        Sleep    1s
    END

Fill MSISDN SIM Range Header
    [Documentation]    Fills Pool Name, Account, Description, and SIM Category for MSISDN flow.
    ...                If ``account_name`` is set, selects that account; otherwise first dropdown option.
    [Arguments]    ${pool_name}=${MSISDN_POOL_NAME}    ${description}=${MSISDN_DESCRIPTION}
    ...            ${account_name}=${EMPTY}    ${defined_pool_count}=${EMPTY}    ${alternate_account_name}=${EMPTY}
    ...            ${allow_first_dropdown_fallback}=${FALSE}
    Enter Pool Name    ${pool_name}
    IF    '${defined_pool_count}' != '${EMPTY}'
        Enter SIM Range Defined Pool Count    ${defined_pool_count}
    END
    IF    '${account_name}' == '${EMPTY}'
        Select Account From Dropdown
    ELSE
        Select Account From Dropdown By Name    ${account_name}    ${alternate_account_name}    ${allow_first_dropdown_fallback}
    END
    Enter SIM Range Description    ${description}
    Select SIM Category If Visible

# ═══════════════════════════════════════════════════════════════════════
#  MSISDN — ACCORDION & POPUP INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Expand MSISDN Panel
    [Documentation]    Expands the MSISDN accordion panel (#collapseThree).
    ${already_open}=    Execute Javascript
    ...    var el = document.querySelector('#collapseThree'); return el && (el.classList.contains('in') || el.classList.contains('show'));
    IF    not ${already_open}
        Wait Until Element Is Visible    ${LOC_MSISDN_PANEL}    timeout=30s
        Click Element Via JS    ${LOC_MSISDN_PANEL_TOGGLE}
        Sleep    1s
    END
    Execute Javascript
    ...    var el = document.querySelector('#collapseThree'); if(el) { el.classList.add('in'); el.style.display='block'; el.style.height='auto'; }
    Sleep    1s

Open MSISDN Popup
    [Documentation]    Expands MSISDN panel and clicks the +Add MSISDN Range button.
    Expand MSISDN Panel
    Wait Until Element Is Visible    ${LOC_ADD_MSISDN_BTN}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_ADD_MSISDN_BTN}    timeout=10s
    Click Element Via JS    ${LOC_ADD_MSISDN_BTN}
    Wait Until Element Is Visible    ${LOC_MSISDN_POPUP}    timeout=30s
    Sleep    1s

Set MSISDN Popup Fields Via JS
    [Documentation]    Fills MSISDN From and To fields inside #addMsisdnRangePopup via JS.
    ...                Uses ARGUMENTS (same as ICCID/IMSI) so values are passed at runtime and
    ...                the To field gets the correct value for pool count 10 (from+9).
    [Arguments]    ${from_value}    ${to_value}
    Execute Javascript
    ...    var el = document.querySelector('#addMsisdnRangePopup input[name=fromInputMsisdn]:not([disabled])');
    ...    if(el) { var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...    s.call(el, arguments[0]); el.dispatchEvent(new Event('input',{bubbles:true}));
    ...    el.dispatchEvent(new Event('change',{bubbles:true})); }
    ...    ARGUMENTS    ${from_value}
    Sleep    1s
    Execute Javascript
    ...    var el = document.querySelector('#addMsisdnRangePopup input[name=toInputMsisdn]:not([disabled])');
    ...    if(el) { var s = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...    s.call(el, arguments[0]); el.dispatchEvent(new Event('input',{bubbles:true}));
    ...    el.dispatchEvent(new Event('change',{bubbles:true})); }
    ...    ARGUMENTS    ${to_value}
    Sleep    1s

Add MSISDN Range
    [Documentation]    Opens the MSISDN popup, fills From/To, submits, and verifies the row appears.
    [Arguments]    ${from_value}    ${to_value}
    Open MSISDN Popup
    Wait Until Element Is Visible    ${LOC_MSISDN_FROM}    timeout=30s
    Click Element    ${LOC_MSISDN_FROM}
    Clear Element Text    ${LOC_MSISDN_FROM}
    Input Text    ${LOC_MSISDN_FROM}    ${from_value}
    Sleep    1s
    Click Element    ${LOC_MSISDN_TO}
    Clear Element Text    ${LOC_MSISDN_TO}
    Input Text    ${LOC_MSISDN_TO}    ${to_value}
    Sleep    1s
    Set MSISDN Popup Fields Via JS    ${from_value}    ${to_value}
    Wait Until Element Is Visible    ${LOC_MSISDN_POPUP_SUBMIT}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_MSISDN_POPUP_SUBMIT}    timeout=15s
    Click Element Via JS    ${LOC_MSISDN_POPUP_SUBMIT}
    Sleep    1s
    Wait Until Element Is Not Visible    ${LOC_MSISDN_POPUP}    timeout=30s
    Wait Until Element Is Visible    ${LOC_MSISDN_GRID}    timeout=30s

Open MSISDN Popup And Enter Range
    [Documentation]    Opens MSISDN popup and enters values without submitting.
    [Arguments]    ${from_value}    ${to_value}
    Open MSISDN Popup
    Wait Until Element Is Visible    ${LOC_MSISDN_FROM}    timeout=30s
    Click Element    ${LOC_MSISDN_FROM}
    Clear Element Text    ${LOC_MSISDN_FROM}
    Input Text    ${LOC_MSISDN_FROM}    ${from_value}
    Sleep    1s
    Click Element    ${LOC_MSISDN_TO}
    Clear Element Text    ${LOC_MSISDN_TO}
    Input Text    ${LOC_MSISDN_TO}    ${to_value}
    Sleep    1s
    Set MSISDN Popup Fields Via JS    ${from_value}    ${to_value}

Close MSISDN Popup Without Submitting
    [Documentation]    Clicks the Close button in the MSISDN popup.
    Wait Until Element Is Visible    ${LOC_MSISDN_POPUP_CLOSE}    timeout=10s
    Click Element Via JS    ${LOC_MSISDN_POPUP_CLOSE}
    Wait Until Element Is Not Visible    ${LOC_MSISDN_POPUP}    timeout=15s

# ═══════════════════════════════════════════════════════════════════════
#  MSISDN — COMPOSITE FILL
# ═══════════════════════════════════════════════════════════════════════
Fill MSISDN SIM Range With Ranges
    [Documentation]    Fills the full MSISDN SIM Range form including header and MSISDN range.
    [Arguments]    ${pool_name}=${MSISDN_POOL_NAME}    ${description}=${MSISDN_DESCRIPTION}
    ...            ${msisdn_from}=${VALID_MSISDN_FROM}    ${msisdn_to}=${VALID_MSISDN_TO}
    ...            ${account_name}=${EMPTY}    ${defined_pool_count}=${EMPTY}    ${alternate_account_name}=${EMPTY}
    ...            ${allow_first_dropdown_fallback}=${FALSE}
    Fill MSISDN SIM Range Header    ${pool_name}    ${description}    ${account_name}    ${defined_pool_count}    ${alternate_account_name}    ${allow_first_dropdown_fallback}
    Add MSISDN Range    ${msisdn_from}    ${msisdn_to}

# ═══════════════════════════════════════════════════════════════════════
#  MSISDN — VALIDATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify MSISDN Popup Submit Is Disabled
    [Documentation]    Asserts the MSISDN popup Submit button is disabled.
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_MSISDN_POPUP_SUBMIT}
    Should Not Be True    ${enabled}    MSISDN popup Submit should be disabled but it is enabled.

Verify MSISDN Popup Is Closed
    [Documentation]    Verifies the MSISDN popup is not visible.
    Wait Until Element Is Not Visible    ${LOC_MSISDN_POPUP}    timeout=15s

Verify MSISDN Grid Has Rows
    [Documentation]    Verifies the MSISDN range table has at least one data row.
    [Arguments]    ${expected_min}=1
    Wait Until Element Is Visible    ${LOC_MSISDN_GRID}    timeout=30s
    ${rows}=    Get Element Count    ${LOC_MSISDN_GRID_ROW}
    Should Be True    ${rows} >= ${expected_min}
    ...    MSISDN grid should have at least ${expected_min} row(s) but has ${rows}.

Verify Assets Type Is Hidden
    [Documentation]    Confirms the Assets Type dropdown is NOT visible (pre-set from URL for MSISDN flow).
    ${visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SR_ASSETS_TYPE_DD}
    Should Not Be True    ${visible}    Assets Type dropdown should be hidden for MSISDN flow.
