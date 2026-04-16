*** Settings ***
Library     SeleniumLibrary
Library     Collections
Library     String
Library     ../../libraries/ReTriggerDebug.py
Library     ../../libraries/RuleEngineTab2.py
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/rule_engine_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION
# ═══════════════════════════════════════════════════════════════════════

Navigate To Rule Engine Listing
    [Documentation]    Navigates to /RuleEngine listing page directly.
    Go To    ${RE_RULE_ENGINE_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=15s

Navigate To Create Rule Page
    [Documentation]    Navigates directly to /CreateRuleEngine. Falls back to listing if direct URL fails.
    Go To    ${RE_CREATE_RULE_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    ${wizard_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=12s
    IF    not ${wizard_ok}
        Navigate To Rule Engine Listing
        Click Create Rule Button
    END

Navigate To Rule Engine Via Sidebar
    [Documentation]    Clicks the Rule Engine link in the left sidebar navigation panel.
    Wait For Loading Overlay To Disappear
    ${primary_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_NAV_RULE_ENGINE}    timeout=3s
    IF    ${primary_visible}
        Click Element Via JS    ${LOC_RE_NAV_RULE_ENGINE}
    ELSE
        Wait Until Element Is Visible    ${LOC_RE_NAV_RULE_ENGINE_ALT}    timeout=5s
        Click Element Via JS    ${LOC_RE_NAV_RULE_ENGINE_ALT}
    END
    Wait For Loading Overlay To Disappear
    Location Should Contain    ${RE_RULE_ENGINE_PATH}
    Wait Until Element Is Visible    ${LOC_RE_CREATE_BTN}    timeout=10s

Click Create Rule Button
    [Documentation]    Clicks the Create Rule button on the Rule Engine listing page.
    Wait Until Element Is Visible    ${LOC_RE_CREATE_BTN}    timeout=10s
    Click Element Via JS    ${LOC_RE_CREATE_BTN}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=15s

# ═══════════════════════════════════════════════════════════════════════
#  TAB 1 — PRIMARY DETAILS
# ═══════════════════════════════════════════════════════════════════════

Fill Primary Details Tab
    [Documentation]    Fills all mandatory fields on Tab 1 (Primary Details).
    ...                Field order matters: App Level -> Customer -> BU (conditional) -> Device Plan.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}
    ...            ${description}=${RE_DESCRIPTION}    ${app_level}=${RE_APP_LEVEL_EC}
    ...            ${customer_index}=1    ${bu_index}=1    ${device_plan_index}=1
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=10s
    Input Text    ${LOC_RE_RULE_NAME}    ${rule_name}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${category}
    Input Text    ${LOC_RE_DESCRIPTION}    ${description}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${app_level}
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_CUSTOMER_BTN}    ${LOC_RE_CUSTOMER_OPTIONS}    ${customer_index}
    ...    search_text=${RE_CUSTOMER_SEARCH_TEXT}    search_input_locator=${LOC_RE_CUSTOMER_SEARCH}
    Wait For Loading Overlay To Disappear
    IF    '${app_level}' != 'EC'
        Wait And Select BU    ${bu_index}
    END
    # If "All Device Plan" is checked, DP select is disabled — skip selection
    ${all_dp_checked}=    Execute Javascript
    ...    var el = document.getElementById('all_Device_Plan');
    ...    return el ? el.checked : false;
    IF    ${all_dp_checked}
        Log    All Device Plan is checked — skipping Device Plan selection.    console=yes
    ELSE
        Wait Until Element Is Enabled    ${LOC_RE_DEVICE_PLAN}    timeout=20s
        ${dp_count}=    Get Element Count    ${LOC_RE_DEVICE_PLAN_OPTIONS}
        Should Be True    ${dp_count} > 0
        ...    Device Plan dropdown has no options after account resolution.
        Select From List By Index    ${LOC_RE_DEVICE_PLAN}    ${device_plan_index}
    END

Wait And Select BU
    [Documentation]    Waits for BU dropdown to populate, then searches and selects by index.
    [Arguments]    ${bu_index}=1
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_BU_BTN}    ${LOC_RE_BU_OPTIONS}    ${bu_index}
    ...    search_text=${RE_BU_SEARCH_TEXT}    search_input_locator=${LOC_RE_BU_SEARCH}
    Wait For Loading Overlay To Disappear

Select Custom Dropdown Option
    [Documentation]    Interacts with a custom div-based dropdown. Clicks the selectBtn to
    ...                open the dropdown, optionally types search text, waits for options, clicks.
    ...                Rule Engine Rule Category: if btn locator is the defineTriggersTab/ruleCategory xpath,
    ...                delegates to Select Rule Category Custom By Index (JS visible click + portal options)
    ...                so stale callers never hit Wait Until Element Is Visible on a hidden first XPath match.
    [Arguments]    ${btn_locator}    ${options_locator}    ${index}=1
    ...            ${search_text}=${EMPTY}    ${search_input_locator}=${EMPTY}
    ...            ${extra_sleep_after_open}=0
    # Python predicate: avoids Robot Evaluate + xpath single-quotes; avoids boolean edge cases in IF.
    ${is_re_rule_cat}=    Locator Is Rule Engine Rule Category    ${btn_locator}
    IF    ${is_re_rule_cat}
        Log    RuleEngine: Rule Category dropdown -> JS open + portal (delegated from Select Custom Dropdown Option).    console=yes
        Select Rule Category Custom By Index    ${index}
        IF    ${extra_sleep_after_open} > 0
            Sleep    ${extra_sleep_after_open}s
            Wait For Loading Overlay To Disappear
        END
        Return From Keyword
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${btn_locator}    timeout=15s
    ${btn_el}=    Get WebElement    ${btn_locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn_el}
    IF    "${search_text}" != "${EMPTY}" and "${search_input_locator}" != "${EMPTY}"
        Wait Until Element Is Visible    ${search_input_locator}    timeout=8s
        Clear Element Text    ${search_input_locator}
        Input Text    ${search_input_locator}    ${search_text}
    END
    Wait Until Element Is Visible    ${options_locator}    timeout=10s
    ${all_options}=    Get WebElements    ${options_locator}
    ${target_index}=    Evaluate    ${index} - 1
    ${option_el}=    Set Variable    ${all_options}[${target_index}]
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${option_el}
    Wait For Loading Overlay To Disappear

Select Rule Category Custom By Index
    [Documentation]    Custom Rule Category: opens dropdown via visible-pane JS click, then selects 1-based option.
    [Arguments]    ${index}=1
    Wait For Loading Overlay To Disappear
    Click Visible Rule Category Select Button
    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}    timeout=10s
    ${all_options}=    Get WebElements    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}
    ${target_index}=    Evaluate    ${index} - 1
    ${option_el}=    Set Variable    ${all_options}[${target_index}]
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${option_el}
    Wait For Loading Overlay To Disappear

Custom Dropdown Should Have Options
    [Documentation]    Asserts that a custom dropdown has at least one non-placeholder option.
    [Arguments]    ${options_locator}
    ${count}=    Get Element Count    ${options_locator}
    Should Be True    ${count} > 0
    ...    Custom dropdown has no selectable options (still loading or Not Found).

RE Rule Category Control Visible
    [Documentation]    Tab 2: waits up to 15s for Rule Category widget (native select or custom div) to appear.
    ${sel}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    10s
    IF    ${sel}    RETURN
    ${btn_js}=    Visible Rule Category Select Button Present
    Should Be True    ${btn_js}    msg=Rule Category field not visible on Define Triggers tab after 10s.

# ═══════════════════════════════════════════════════════════════════════
#  TAB 2 — DEFINE TRIGGERS
# ═══════════════════════════════════════════════════════════════════════

Fill Define Triggers Tab
    [Documentation]    Selects a Rule Category by index (1-based, first real option = 1), fills required trigger fields, and saves.
    [Arguments]    ${rule_category_index}=1
    Wait For Loading Overlay To Disappear
    RE Rule Category Control Visible
    ${is_native}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    3s
    IF    ${is_native}
        ${option_value}=    Get Rule Category Option Value By Index    ${rule_category_index}
        Select From List By Value    ${LOC_RE_RULE_CATEGORY_SELECT}    ${option_value}
    ELSE
        Log    RuleEngine: Fill Define Triggers Tab -> custom Rule Category (JS+portal).    console=yes
        Select Rule Category Custom By Index    ${rule_category_index}
    END
    Wait For Loading Overlay To Disappear
    Fill Trigger Form Fields
    Save First Available Trigger

Get Rule Category Option Count
    [Documentation]    Returns the number of available Rule Category options (native or custom).
    ${is_native}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    3s
    IF    ${is_native}
        ${count}=    Get Element Count    ${LOC_RE_RULE_CATEGORY_NATIVE_OPTIONS}
    ELSE
        Click Visible Rule Category Select Button
        Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}    timeout=10s
        ${count}=    Get Element Count    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}
        Press Keys    None    ESCAPE
    END
    RETURN    ${count}

Get Rule Category Option Text
    [Documentation]    Returns the text of the Rule Category option at the given 1-based index.
    [Arguments]    ${index}=1
    Wait For Loading Overlay To Disappear
    RE Rule Category Control Visible
    ${is_native}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    3s
    IF    ${is_native}
        ${options}=    Get WebElements    ${LOC_RE_RULE_CATEGORY_NATIVE_OPTIONS}
        ${target}=    Evaluate    ${index} - 1
        ${text}=    Get Text    ${options}[${target}]
    ELSE
        Click Visible Rule Category Select Button
        Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}    timeout=10s
        ${options}=    Get WebElements    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}
        ${target}=    Evaluate    ${index} - 1
        ${text}=    Get Text    ${options}[${target}]
        Press Keys    None    ESCAPE
    END
    RETURN    ${text}

Get Rule Category Option Value By Index
    [Documentation]    Returns the value attribute of the Rule Category option at the given 1-based index (native select only).
    [Arguments]    ${index}=1
    ${vis}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    5s
    Should Be True    ${vis}    Native Rule Category select not visible within 10s (custom UI?).
    ${options}=    Get WebElements    ${LOC_RE_RULE_CATEGORY_NATIVE_OPTIONS}
    ${target}=    Evaluate    ${index} - 1
    ${value}=    Get Element Attribute    ${options}[${target}]    value
    RETURN    ${value}

Fill Trigger Form Fields
    [Documentation]    Comprehensive trigger form filler for Tab 2 (Define Triggers).
    ...                Each Rule Category option produces a different form layout with different
    ...                selects and inputs. This keyword uses a single JS function that:
    ...                1. Scans ALL visible selects (excluding ruleCategory) and picks first real option
    ...                2. Fills ALL visible text/number inputs with safe values
    ...                3. Runs in multiple passes (options load lazily after each select change)
    ...                4. Detects DAYS/month limits and uses safe values (5 instead of 100)
    ...                5. Handles date pickers by leaving them with current value if pre-filled
    # Run comprehensive fill in up to 2 passes — options load lazily after each select change
    FOR    ${pass_num}    IN RANGE    2
        ${result}=    Fill All Trigger Fields Via JS
        Wait For Loading Overlay To Disappear
        ${filled_any}=    Evaluate    isinstance($result, dict) and ($result.get('filledSelects', 0) + $result.get('filledInputs', 0)) > 0
        ${has_unfilled}=    Evaluate    isinstance($result, dict) and ($result.get('unfilledSelects', 0) > 0)
        IF    ${filled_any} and ${has_unfilled}
            Sleep    0.5s
            Wait For Loading Overlay To Disappear
        END
        IF    not ${has_unfilled}    BREAK
    END
    # Robot-level fallback: fill any still-empty inputs that JS/React may have reset
    Fill Empty Trigger Inputs Via Robot

Fill Empty Trigger Inputs Via Robot
    [Documentation]    Finds all empty visible text inputs in the trigger pane and fills them
    ...                using SeleniumLibrary Input Text (works with React controlled inputs).
    ...                Uses direct xpath — no custom attributes that React might remove on re-render.
    ${empty_count}=    Execute Javascript
    ...    var _t = document.querySelectorAll('div[id="defineTriggersTab"]');
    ...    var pane = _t.length ? _t[_t.length - 1] : null;
    ...    if (!pane) return 0;
    ...    var c = 0;
    ...    var inputs = pane.querySelectorAll('input');
    ...    for (var i = 0; i < inputs.length; i++) {
    ...        var inp = inputs[i];
    ...        if (inp.disabled || inp.readOnly || inp.offsetParent === null) continue;
    ...        if (inp.type === 'hidden' || inp.type === 'checkbox' || inp.type === 'radio') continue;
    ...        if (!(inp.value || '').trim()) c++;
    ...    }
    ...    return c;
    IF    ${empty_count} == 0    RETURN
    # Get all visible inputs in the trigger pane
    ${inputs}=    Get WebElements    xpath=(//div[@id='defineTriggersTab'])[last()]//input[not(@type='hidden') and not(@type='checkbox') and not(@type='radio')]
    FOR    ${inp}    IN    @{inputs}
        ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${inp}
        IF    not ${visible}    CONTINUE
        ${val}=    Get Value    ${inp}
        IF    '${val}'.strip() != ''    CONTINUE
        # Determine smart fill value
        ${ph}=    Get Element Attribute    ${inp}    placeholder
        ${fill_val}=    Execute Javascript
        ...    var inp = arguments[0];
        ...    var nearby = ''; var p = inp;
        ...    for (var k=0; k<4 && p; k++) { nearby += ' ' + (p.textContent||''); p = p.parentElement; }
        ...    nearby = nearby.toLowerCase();
        ...    var hasHours = false, hasDays = false;
        ...    var nd = inp.closest ? inp.closest('.row,.form-group') || inp.parentElement : inp.parentElement;
        ...    if (nd) { var ss = nd.querySelectorAll('select');
        ...        for (var j=0;j<ss.length;j++) {
        ...            var t = ss[j].selectedIndex>=0 ? (ss[j].options[ss[j].selectedIndex].text||'') : '';
        ...            if (/hours/i.test(t)) hasHours = true;
        ...            if (/days/i.test(t)) hasDays = true;
        ...        }
        ...    }
        ...    if (hasHours || /12 to 24/i.test(nearby)) return '12';
        ...    if (hasDays || /between 1 and 30/i.test(nearby)) return '5';
        ...    if (/duration/i.test(inp.placeholder||'')) return '12';
        ...    return '10';
        ...    ARGUMENTS    ${inp}
        Click Element    ${inp}
        Run Keyword And Ignore Error    Clear Element Text    ${inp}
        Input Text    ${inp}    ${fill_val}
        Log    Robot filled empty trigger input (ph=${ph}) with ${fill_val}    console=yes
    END
    Wait For Loading Overlay To Disappear

Fill All Trigger Fields Via JS
    [Documentation]    Single comprehensive JS call that fills ALL unfilled selects and inputs
    ...                in the trigger pane. Returns dict with counts of what was filled.
    ${result}=    Execute Javascript
    ...    var _t = document.querySelectorAll('div[id="defineTriggersTab"]');
    ...    var pane = _t.length ? _t[_t.length - 1] : null;
    ...    if (!pane) return {ok: false, reason: 'no_pane'};
    ...    var skipTestIds = ['ruleCategory','in_ruleCategory','selected_rule_category'];
    ...    var filledSelects = 0, filledInputs = 0, unfilledSelects = 0, unfilledInputs = 0;
    ...    var actions = [];
    ...    function isPlaceholder(opt) {
    ...        var t = (opt.text || '').trim().toLowerCase();
    ...        var v = (opt.value || '').trim();
    ...        if (!v || v === '0') return true;
    ...        if (/^select\s|^please select|^choose|^--/i.test(t)) return true;
    ...        if (/device plan (from|to)/i.test(t)) return true;
    ...        return false;
    ...    }
    ...    function fireChange(el) {
    ...        el.dispatchEvent(new Event('change', {bubbles:true}));
    ...        el.dispatchEvent(new Event('input', {bubbles:true}));
    ...    }
    ...    function nativeSet(inp, val) {
    ...        var ns = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...        ns.call(inp, val);
    ...        fireChange(inp);
    ...    }
    ...    function nearbyText(el) {
    ...        var p = el; var txt = '';
    ...        for (var k = 0; k < 4 && p; k++) { txt += ' ' + (p.textContent || ''); p = p.parentElement; }
    ...        return txt;
    ...    }
    ...    /* PASS 1: Fill all selects that still show placeholder */
    ...    var sels = pane.querySelectorAll('select');
    ...    for (var i = 0; i < sels.length; i++) {
    ...        var s = sels[i];
    ...        if (s.disabled || s.offsetParent === null) continue;
    ...        var tid = (s.getAttribute('data-testid') || '');
    ...        if (skipTestIds.indexOf(tid) >= 0) continue;
    ...        var curOpt = s.selectedIndex >= 0 ? s.options[s.selectedIndex] : null;
    ...        if (curOpt && !isPlaceholder(curOpt)) continue;
    ...        var picked = false;
    ...        for (var j = 0; j < s.options.length; j++) {
    ...            if (!isPlaceholder(s.options[j])) {
    ...                s.selectedIndex = j;
    ...                fireChange(s);
    ...                actions.push({type:'select', idx:i, testid:tid, picked:(s.options[j].text||'').trim()});
    ...                filledSelects++;
    ...                picked = true;
    ...                break;
    ...            }
    ...        }
    ...        if (!picked) unfilledSelects++;
    ...    }
    ...    /* PASS 2: Fill ALL empty visible text/number inputs + fix invalid values */
    ...    var inputs = pane.querySelectorAll('input[type="text"], input[type="number"], input:not([type])');
    ...    for (var k = 0; k < inputs.length; k++) {
    ...        var inp = inputs[k];
    ...        if (inp.disabled || inp.readOnly || inp.offsetParent === null) continue;
    ...        if (inp.type === 'hidden' || inp.type === 'checkbox' || inp.type === 'radio') continue;
    ...        var val = (inp.value || '').trim();
    ...        var ph = (inp.placeholder || '').toLowerCase();
    ...        var nearby = nearbyText(inp).toLowerCase();
    ...        var isDatePicker = inp.type === 'date' || (inp.closest && inp.closest('.k-datepicker, .react-datepicker-wrapper')) || /^\d{4}-\d{2}|^\w{3}-\d{4}/i.test(val);
    ...        if (isDatePicker) continue;
    ...        /* Detect nearby select values (HOURS/DAYS) and validation messages */
    ...        var hasHours = false, hasDays = false;
    ...        var nearDiv = inp.closest && inp.closest('.row, .form-group') || inp.parentElement;
    ...        if (nearDiv) {
    ...            var nss = nearDiv.querySelectorAll('select');
    ...            for (var si = 0; si < nss.length; si++) {
    ...                var st = nss[si].selectedIndex >= 0 ? (nss[si].options[nss[si].selectedIndex].text||'').toLowerCase() : '';
    ...                if (/hours/i.test(st)) hasHours = true;
    ...                if (/days/i.test(st)) hasDays = true;
    ...            }
    ...        }
    ...        var hoursCtx = hasHours || /12 to 24/i.test(nearby);
    ...        var daysCtx = hasDays || /between 1 and 30/i.test(nearby);
    ...        function bestVal() {
    ...            if (hoursCtx) return '12';
    ...            if (daysCtx) return '5';
    ...            if (/duration/i.test(ph)) return '12';
    ...            return '10';
    ...        }
    ...        if (!val) {
    ...            nativeSet(inp, bestVal());
    ...            actions.push({type:'input', idx:k, ph:ph.substring(0,30), filled:bestVal()});
    ...            filledInputs++;
    ...        } else {
    ...            var nv = parseInt(val);
    ...            var fix = false;
    ...            if (hoursCtx && (nv < 12 || nv > 24)) fix = true;
    ...            if (daysCtx && nv > 30) fix = true;
    ...            if (fix) {
    ...                var fv = hoursCtx ? '12' : '5';
    ...                nativeSet(inp, fv);
    ...                actions.push({type:'fix', idx:k, was:val, to:fv});
    ...                filledInputs++;
    ...            }
    ...        }
    ...    }
    ...    return {ok:true, filledSelects:filledSelects, filledInputs:filledInputs,
    ...            unfilledSelects:unfilledSelects, unfilledInputs:unfilledInputs, actions:actions};
    RETURN    ${result}

Save First Available Trigger
    [Documentation]    Clicks the Save Trigger / Add Trigger button. Tries main locator first.
    ${btn_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TRIGGER_SAVE_BTN}    timeout=5s
    IF    ${btn_visible}
        ${btn_el}=    Get WebElement    ${LOC_RE_TRIGGER_SAVE_BTN}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn_el}
        Wait For Loading Overlay To Disappear
    ELSE
        Log    No Save Trigger button found — category may auto-save.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  TAB 3 — ASSIGN DEVICES
# ═══════════════════════════════════════════════════════════════════════

Fill Assign Devices Tab
    [Documentation]    Selects Aggregation Level (first non-placeholder option). Handles conditional Rest Period.
    [Arguments]    ${aggregation_index}=1
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_AGGREGATION}    timeout=10s
    Aggregation Should Have Options
    ${agg_ok}=    Run Keyword And Return Status
    ...    Select From List By Index    ${LOC_RE_AGGREGATION}    ${aggregation_index}
    IF    not ${agg_ok}
        Execute Javascript
        ...    var sel = document.querySelector('select[data-testid="aggregationLevel"]');
        ...    if (sel && sel.options.length > ${aggregation_index}) { sel.selectedIndex = ${aggregation_index}; sel.dispatchEvent(new Event('change',{bubbles:true})); }
        Log    Selected aggregation via JS fallback (index ${aggregation_index}).    console=yes
    END
    Wait For Loading Overlay To Disappear
    ${rest_present}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_REST_PERIOD}    timeout=2s
    IF    ${rest_present}
        ${rest_opts}=    Get Element Count    xpath=//div[@id='assignDevicesTab']//select[@data-testid='in_reset_period' or @data-testid='reset_period' or @data-testid='in_resetPeriod' or contains(translate(@name,'RESET','reset'),'reset')]/option[not(@value='') and not(@value='0')]
        IF    ${rest_opts} > 0
            ${sel_ok}=    Run Keyword And Return Status    Select From List By Index    ${LOC_RE_REST_PERIOD}    1
            IF    not ${sel_ok}
                Log    Rest Period select present but Select From List failed — continuing.    level=WARN
            END
        END
    END

Aggregation Should Have Options
    [Documentation]    Asserts that the Aggregation Level dropdown has at least one selectable option.
    ${count}=    Get Element Count    xpath=//select[@data-testid='aggregationLevel']/option[not(@value='') and not(@value='0')]
    Should Be True    ${count} > 0
    ...    Aggregation Level dropdown has no options yet.

# ═══════════════════════════════════════════════════════════════════════
#  TAB 4 — ACTION
# ═══════════════════════════════════════════════════════════════════════

Get Action Type Option Count
    [Documentation]    Returns the number of selectable Action Type options on Tab 4 (excludes empty and Select Action placeholder).
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=10s
    ${count}=    Get Element Count    xpath=//select[@data-testid='racactionType']/option[normalize-space(@value)!='' and normalize-space(text())!='' and normalize-space(text())!='Select Action']
    RETURN    ${count}

Get Action Type Option Label
    [Documentation]    Returns the label of the Action Type option at the given 1-based index (real options only; Select Action excluded).
    [Arguments]    ${index}=1
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=10s
    ${options}=    Get WebElements    xpath=//select[@data-testid='racactionType']/option[normalize-space(@value)!='' and normalize-space(text())!='' and normalize-space(text())!='Select Action']
    ${target}=    Evaluate    ${index} - 1
    ${text}=    Get Text    ${options}[${target}]
    RETURN    ${text}

Fill Action Tab And Save
    [Documentation]    Selects Action Type, fills action fields, clicks Save Action.
    [Arguments]    ${action_label}=${RE_ACTION_RAISE_ALERT}
    ...            ${alert_email}=${RE_ALERT_EMAIL}
    ...            ${alert_desc}=${RE_ALERT_DESC}
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=10s
    ${act_ok}=    Run Keyword And Return Status
    ...    Select From List By Label    ${LOC_RE_ACTION_TYPE}    ${action_label}
    IF    not ${act_ok}
        Execute Javascript
        ...    var sel = document.querySelector('select[data-testid="racactionType"]');
        ...    if (sel) { for (var i=0;i<sel.options.length;i++) { if (sel.options[i].text.trim()==='${action_label}') { sel.selectedIndex=i; sel.dispatchEvent(new Event('change',{bubbles:true})); break; } } }
        Log    Selected action type via JS fallback: ${action_label}    console=yes
    END
    Wait For Loading Overlay To Disappear
    IF    '${action_label}' == 'Raise Alert in Web GUI'
        Fill Raise Alert In Web GUI Action    ${alert_email}    ${alert_desc}
    ELSE IF    '${action_label}' == 'Email'
        Fill Email Action    ${alert_email}
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_SAVE_ACTION_BTN}    timeout=8s
    ${save_btn}=    Get WebElement    ${LOC_RE_SAVE_ACTION_BTN}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Wait For Loading Overlay To Disappear

Fill Email Action
    [Documentation]    Fills Email action: adds one recipient in the To/ReactTags input.
    [Arguments]    ${email}=${RE_ALERT_EMAIL}
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_INPUT}    timeout=5s
    IF    ${input_visible}
        Input Text    ${LOC_RE_ALERT_EMAIL_INPUT}    ${email}
        Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    RETURN
    END

Fill Raise Alert In Web GUI Action
    [Documentation]    Fills Raise Alert fields: email via ReactTags + description.
    [Arguments]    ${alert_email}=${RE_ALERT_EMAIL}    ${alert_desc}=${RE_ALERT_DESC}
    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_INPUT}    timeout=8s
    Clear Element Text    ${LOC_RE_ALERT_EMAIL_INPUT}
    Input Text    ${LOC_RE_ALERT_EMAIL_INPUT}    ${alert_email}
    Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    RETURN
    ${tag_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_TAG}    timeout=3s
    IF    not ${tag_ok}
        Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    TAB
        Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_TAG}    timeout=3s
    END
    Wait Until Element Is Visible    ${LOC_RE_ALERT_DESC}    timeout=5s
    Input Text    ${LOC_RE_ALERT_DESC}    ${alert_desc}

# ═══════════════════════════════════════════════════════════════════════
#  WIZARD NAVIGATION
# ═══════════════════════════════════════════════════════════════════════

Click Next Tab
    [Documentation]    Clicks the Next button to advance to the next wizard tab.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_NEXT_BTN}    timeout=8s
    Click Element Via JS    ${LOC_RE_NEXT_BTN}
    Wait For Loading Overlay To Disappear

Click Previous Tab
    [Documentation]    Clicks the Previous button to go back to the prior tab.
    Wait For Loading Overlay To Disappear
    ${clicked}=    Run Keyword And Return Status
    ...    Run Keywords    Wait Until Element Is Visible    ${LOC_RE_PREVIOUS_BTN}    timeout=12s
    ...    AND    Click Element Via JS    ${LOC_RE_PREVIOUS_BTN}
    IF    not ${clicked}
        ${js_click}=    Execute Javascript
        ...    var inputs=document.querySelectorAll('input[type="button"],input[type="submit"],button');
        ...    for(var i=0;i<inputs.length;i++){
        ...      var el=inputs[i];
        ...      if(el.offsetParent===null) continue;
        ...      var v=(el.value||el.textContent||'').trim().toLowerCase();
        ...      if(v==='previous'||el.getAttribute('name')==='Base'){ el.click(); return true; }
        ...    }
        ...    return false;
        Should Be True    ${js_click}    msg=Previous wizard button not found (class/name/value).
    END
    Wait For Loading Overlay To Disappear

Submit Rule
    [Documentation]    Clicks the Submit button on Tab 4. Uses JS to find the visible Submit-like button.
    ...                Waits for loading to complete before click and after submit (redirect/toast).
    Wait For Loading Overlay To Disappear
    # The Submit button on Tab 4 replaces the Next button.
    # Try to find it by value='Submit' first, then fallback to class-based.
    ${submit_found}=    Execute Javascript
    ...    var btns = document.querySelectorAll('input[type="button"], button');
    ...    for (var i = 0; i < btns.length; i++) {
    ...        var b = btns[i];
    ...        var val = (b.value || b.textContent || '').trim();
    ...        if (b.offsetParent !== null && val.toLowerCase() === 'submit') {
    ...            b.click();
    ...            return 'clicked: ' + val;
    ...        }
    ...    }
    ...    return 'not_found';
    Log    Submit button result: ${submit_found}    console=yes
    IF    "${submit_found}" == "not_found"
        Wait Until Element Is Visible    ${LOC_RE_SUBMIT_BTN}    timeout=8s
        Click Element Via JS    ${LOC_RE_SUBMIT_BTN}
    END
    Wait For Loading Overlay To Disappear

Click Close Wizard
    [Documentation]    Clicks the Close/Cancel button to exit the wizard.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_CLOSE_BTN}    timeout=10s
    Click Element Via JS    ${LOC_RE_CLOSE_BTN}
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  HELPER — FILL TABS UP TO N (for negative tests)
# ═══════════════════════════════════════════════════════════════════════

Fill Tabs Up To Tab 2
    [Documentation]    Fills Tab 1 with defaults and clicks Next to arrive at Tab 2.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}
    Fill Primary Details Tab    rule_name=${rule_name}    category=${category}
    Click Next Tab
    Wait For Loading Overlay To Disappear

Fill Tabs Up To Tab 3
    [Documentation]    Fills Tabs 1-2 and clicks Next to arrive at Tab 3.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}    ${rule_category_index}=1
    Fill Tabs Up To Tab 2    rule_name=${rule_name}    category=${category}
    Fill Define Triggers Tab    rule_category_index=${rule_category_index}
    Click Next Tab
    Wait Until Element Is Visible    ${LOC_RE_AGGREGATION}    timeout=10s

Fill Tabs Up To Tab 4
    [Documentation]    Fills Tabs 1-3 and clicks Next to arrive at Tab 4.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}    ${rule_category_index}=1
    Fill Tabs Up To Tab 3    rule_name=${rule_name}    category=${category}    rule_category_index=${rule_category_index}
    Fill Assign Devices Tab
    Click Next Tab
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s

Create Rule End To End
    [Documentation]    Full E2E: create rule → submit → auto-redirect → delete. Minimal navigation.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}
    ...            ${rule_category_index}=1
    Navigate To Create Rule Page
    Fill Primary Details Tab    rule_name=${rule_name}    category=${category}
    Click Next Tab
    Fill Define Triggers Tab    rule_category_index=${rule_category_index}
    Click Next Tab
    Fill Assign Devices Tab
    Click Next Tab
    Fill Action Tab And Save
    Submit Rule
    Validate Rule Created Successfully    ${rule_name}
    Delete Rule From Listing By Name    ${rule_name}    skip_navigation=${TRUE}

Create Rule For Single Rule Category Option
    [Documentation]    Full wizard for one Rule Category option. Skips if index exceeds available options.
    [Arguments]    ${category}    ${rule_category_index}    ${name_prefix}
    Navigate To Create Rule Page
    Fill Primary Details Tab    rule_name=${name_prefix}_${rule_category_index}_${RE_SUFFIX}    category=${category}
    Click Next Tab
    ${count}=    Get Rule Category Option Count
    Skip If    ${rule_category_index} > ${count}
    ...    Primary category has ${count} Rule Category option(s) on Tab 2; skipping index ${rule_category_index}.
    Fill Define Triggers Tab    rule_category_index=${rule_category_index}
    Click Next Tab
    Fill Assign Devices Tab
    Click Next Tab
    Fill Action Tab And Save
    Submit Rule
    Validate Rule Created Successfully    ${name_prefix}_${rule_category_index}_${RE_SUFFIX}
    Delete Rule From Listing By Name    ${name_prefix}_${rule_category_index}_${RE_SUFFIX}    skip_navigation=${TRUE}

Create Rule With Category And Action
    [Documentation]    Creates one rule with given Primary category and Action tab action type.
    [Arguments]    ${rule_name}    ${category}    ${action_label}
    Navigate To Create Rule Page
    Fill Primary Details Tab    rule_name=${rule_name}    category=${category}
    Click Next Tab
    Fill Define Triggers Tab    rule_category_index=1
    Click Next Tab
    Fill Assign Devices Tab
    Click Next Tab
    Fill Action Tab And Save    action_label=${action_label}
    Submit Rule
    Validate Rule Created Successfully    ${rule_name}
    Delete Rule From Listing By Name    ${rule_name}    skip_navigation=${TRUE}

Create Rule For Primary Category And Nth Action
    [Documentation]    Full wizard with trigger option 1; on Tab 4 selects the Nth Action Type. Skips if N exceeds available.
    [Arguments]    ${category}    ${action_index}    ${name_prefix}
    Navigate To Create Rule Page
    Fill Primary Details Tab    rule_name=${name_prefix}_${action_index}_${RE_SUFFIX}    category=${category}
    Click Next Tab
    Fill Define Triggers Tab    rule_category_index=1
    Click Next Tab
    Fill Assign Devices Tab
    Click Next Tab
    ${action_count}=    Get Action Type Option Count
    Skip If    ${action_index} > ${action_count}
    ...    Tab 4 has ${action_count} action type(s); skipping index ${action_index}.
    ${action_label}=    Get Action Type Option Label    ${action_index}
    Fill Action Tab And Save    action_label=${action_label}
    Submit Rule
    Validate Rule Created Successfully    ${name_prefix}_${action_index}_${RE_SUFFIX}
    Delete Rule From Listing By Name    ${name_prefix}_${action_index}_${RE_SUFFIX}    skip_navigation=${TRUE}

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATION
# ═══════════════════════════════════════════════════════════════════════

Validate Tab 2 Ready
    [Documentation]    Asserts Define Triggers tab is visible (Rule Category dropdown present).
    Wait For Loading Overlay To Disappear
    RE Rule Category Control Visible

Validate Tab 3 Ready
    [Documentation]    Asserts Assign Devices tab is visible.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_AGGREGATION}    timeout=8s

Validate Tab 4 Ready
    [Documentation]    Asserts Action tab is visible.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=8s

RE Rule Create Success Toast Or Listing
    [Documentation]    One poll step: green Toastify toast visible, OR already on listing with grid.
    ...                If an error toast is detected, stores msg in suite var and returns (stops retry loop).
    ...                Toasts often auto-dismiss quickly; long runs may miss a 30s single wait.
    ...                Also checks for toast that already disappeared (page source contains success text).
    ${error_toast}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_TOAST_ERROR}
    IF    ${error_toast}
        ${err_text}=    Get Text    ${LOC_RE_TOAST_ERROR}
        Set Suite Variable    $RE_CREATE_ERROR_MSG    ${err_text}
        RETURN
    END
    ${toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TOAST_SUCCESS}    timeout=3s
    IF    ${toast}
        RETURN
    END
    # Check if success toast appeared and auto-dismissed (text still in DOM)
    ${source_has_success}=    Run Keyword And Return Status
    ...    Page Should Contain    ${RE_SUCCESS_TOAST_TEXT}
    IF    ${source_has_success}
        Log    Success toast text found in page source (toast may have auto-dismissed).    console=yes
        RETURN
    END
    ${on_listing}=    Run Keyword And Return Status
    ...    Location Should Contain    ${RE_RULE_ENGINE_PATH}
    IF    ${on_listing}
        ${grid_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=5s
        IF    ${grid_ok}
            Log    Already on listing with grid visible — rule creation likely succeeded.    console=yes
            RETURN
        END
    END
    Fail    Rule create success not detected yet (no success toast, URL not listing).

Validate Rule Created Successfully
    [Documentation]    Waits for success toast or auto-redirect to listing. No extra navigation.
    [Arguments]    ${rule_name}=${EMPTY}
    # Single JS poll: checks toast/error/listing — resolves as soon as any is detected
    ${success}=    Execute Javascript
    ...    return new Promise(function(resolve) {
    ...        var start = Date.now();
    ...        function check() {
    ...            var err = document.querySelector('.Toastify__toast--error, [class*="toast--error"]');
    ...            if (err && err.offsetParent !== null) { resolve('error:' + (err.textContent||'').substring(0,100)); return; }
    ...            var ok = document.querySelector('.Toastify__toast--success, [class*="toast--success"]');
    ...            if (ok && ok.offsetParent !== null) { resolve('toast'); return; }
    ...            if (document.body.textContent.indexOf('Rule Added Successfully') >= 0) { resolve('text'); return; }
    ...            if (window.location.href.indexOf('/RuleEngine') >= 0 && window.location.href.indexOf('Create') < 0) {
    ...                if (document.getElementById('gridData')) { resolve('listing'); return; }
    ...            }
    ...            if (Date.now() - start > 90000) { resolve('timeout'); return; }
    ...            setTimeout(check, 300);
    ...        }
    ...        check();
    ...    });
    IF    '${success}'.startswith('error:')
        Fail    Rule creation FAILED: ${success}
    END
    Should Not Be Equal    ${success}    timeout    Rule creation not confirmed within 90s.
    # App auto-routes to listing — just wait for grid
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=10s

Delete Rule From Listing By Name
    [Documentation]    After rule creation, navigates to Rule Engine listing, waits for page
    ...                and grid to fully load, finds and clicks the delete icon on the first row,
    ...                confirms popup, waits for success toast and loading to complete.
    [Arguments]    ${rule_name}    ${skip_navigation}=${FALSE}
    # 1. Navigate to listing and wait for everything to load
    Navigate To Rule Engine Listing
    Wait For Loading Overlay To Disappear
    Sleep    3s    reason=Wait for grid data and React to render after page load
    Wait For Loading Overlay To Disappear
    # 2. Find and click the delete icon on first row using JS (most reliable)
    ${delete_result}=    Execute Javascript
    ...    var row = document.querySelector('#gridData tr.k-master-row, #gridData tbody tr');
    ...    if (!row) return 'no_row_found';
    ...    /* Log the first row rule name */
    ...    var ruleName = '';
    ...    var cells = row.querySelectorAll('td');
    ...    for (var j = 0; j < cells.length; j++) {
    ...        var t = cells[j].textContent.trim();
    ...        if (t.length > 2 && !t.includes('✎') && !t.includes('✖')) { ruleName = t; break; }
    ...    }
    ...    console.log('First row rule: ' + ruleName);
    ...    /* Find the delete button — look for red icons, trash icons, delete links */
    ...    /* Click the k-grid-Delete link directly */
    ...    var del = row.querySelector('a.k-grid-Delete, .k-grid-Delete');
    ...    if (del) { del.click(); return 'clicked:' + ruleName + ':k-grid-Delete'; }
    ...    return 'no_delete_found:' + ruleName;
    Log    Delete result: ${delete_result}    console=yes
    IF    not '${delete_result}'.startswith('clicked')
        Log    WARN: Could not find delete icon — ${delete_result}    level=WARN    console=yes
        RETURN
    END
    # 3. Confirm deletion popup and wait for completion
    Wait Until Element Is Visible    ${LOC_RE_DELETE_CONFIRM_OK}    10s
    Click Element Via JS    ${LOC_RE_DELETE_CONFIRM_OK}
    Wait For Loading Overlay To Disappear
    # 4. Validate delete success toast
    Wait Until Element Is Visible    ${LOC_RE_TOAST_SUCCESS}    timeout=10s
    ...    error=Delete success toast not visible after deleting rule "${rule_name}"
    Wait For Loading Overlay To Disappear
    Log    Rule "${rule_name}" deleted successfully — success toast verified.    console=yes

Cleanup Automation Rules
    [Documentation]    Deletes all rules created by automation (names starting with Auto/All/SL_/FP_/CC_/OT_)
    ...                from the listing grid. Handles pagination by navigating through all grid pages.
    ...                Call at suite start to avoid "Max Rule Creation Limit" errors.
    Navigate To Rule Engine Listing
    ${deleted_count}=    Execute Javascript
    ...    return new Promise(async function(resolve) {
    ...        var count = 0;
    ...        var pattern = /^(Auto|All|AllSL|AllFP|AllCC|AllOT|SL_Trg|FP_Trg|CC_Trg|OT_Trg)/i;
    ...        async function deleteFromCurrentPage() {
    ...            var found = true;
    ...            while (found) {
    ...                found = false;
    ...                var rows = document.querySelectorAll('#gridData tr.k-master-row, #gridData tbody tr');
    ...                for (var i = 0; i < rows.length; i++) {
    ...                    var cells = rows[i].querySelectorAll('td');
    ...                    for (var j = 0; j < cells.length; j++) {
    ...                        var t = (cells[j].textContent || '').trim();
    ...                        if (pattern.test(t)) {
    ...                            var allLinks = rows[i].querySelectorAll('a, button, span.fa, i.fa');
    ...                            var del = null;
    ...                            for (var k = 0; k < allLinks.length; k++) {
    ...                                var c = (allLinks[k].className||'').toLowerCase();
    ...                                var col = window.getComputedStyle(allLinks[k]).color||'';
    ...                                if (c.includes('delete')||c.includes('trash')||c.includes('times')||c.includes('danger')||c.includes('red')||col.includes('255, 0')||col.includes('220, 53')) { del=allLinks[k]; break; }
    ...                            }
    ...                            if (!del) del = rows[i].querySelector('.k-grid-Delete, .fa-trash, .k-i-delete, [class*="delete"]');
    ...                            if (del) {
    ...                                del.click();
    ...                                await new Promise(r => setTimeout(r, 500));
    ...                                var ok = document.querySelector('.modal .btn-primary, .k-dialog .k-button-solid-primary, [class*="confirm"] .btn-primary, .modal-footer .btn-danger');
    ...                                if (ok) { ok.click(); count++; }
    ...                                await new Promise(r => setTimeout(r, 2000));
    ...                                found = true;
    ...                                break;
    ...                            }
    ...                        }
    ...                    }
    ...                    if (found) break;
    ...                }
    ...            }
    ...        }
    ...        /* Delete from current page, then navigate to next page and repeat */
    ...        for (var pageAttempt = 0; pageAttempt < 10; pageAttempt++) {
    ...            await deleteFromCurrentPage();
    ...            var nextBtn = document.querySelector('.k-pager-nav .k-i-arrow-60-right, .k-pager-nav .k-i-caret-alt-right, a[title="Go to the next page"]:not(.k-state-disabled)');
    ...            if (nextBtn && !nextBtn.closest('.k-state-disabled')) {
    ...                nextBtn.click();
    ...                await new Promise(r => setTimeout(r, 2000));
    ...            } else {
    ...                break;
    ...            }
    ...        }
    ...        resolve(count);
    ...    });
    Log    Cleanup: deleted ${deleted_count} leftover automation rule(s) from grid.    console=yes
    IF    ${deleted_count} > 0
        Wait For Loading Overlay To Disappear
    END

Validate Wizard Stays On Tab 1
    [Documentation]    Asserts the wizard did NOT advance past Tab 1.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    10s
    ${on_create_page}=    Run Keyword And Return Status
    ...    Location Should Contain    ${RE_CREATE_RULE_PATH}
    Should Be True    ${on_create_page}    Expected to remain on Create Rule page.

Validate Wizard Stays On Tab 2
    [Documentation]    Asserts the wizard remains on Tab 2 (Define Triggers).
    Wait For Loading Overlay To Disappear
    ${native}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    5s
    ${js}=    Visible Rule Category Select Button Present
    Should Be True    ${native} or ${js}    msg=Expected Rule Category control on Tab 2.

Validate Wizard Stays On Tab 3
    [Documentation]    Asserts the wizard remains on Tab 3 (Assign Devices).
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_AGGREGATION}    8s

Validate Wizard Stays On Tab 4
    [Documentation]    Asserts the wizard remains on Tab 4 (Action).
    Wait For Loading Overlay To Disappear
    Element Should Be Visible    ${LOC_RE_ACTION_TYPE}

Validate Tab 1 Fields Visible
    [Documentation]    Asserts all mandatory Tab 1 fields are present on the page.
    Element Should Be Visible    ${LOC_RE_RULE_NAME}
    Element Should Be Visible    ${LOC_RE_CATEGORY}
    Element Should Be Visible    ${LOC_RE_DESCRIPTION}
    Element Should Be Visible    ${LOC_RE_APP_LEVEL}
    Element Should Be Visible    ${LOC_RE_NEXT_BTN}
    Element Should Be Visible    ${LOC_RE_CLOSE_BTN}

Validate Device Plan Options Loaded
    [Documentation]    Asserts Device Plan dropdown has at least one selectable option.
    ${count}=    Get Element Count    ${LOC_RE_DEVICE_PLAN_OPTIONS}
    Should Be True    ${count} > 0
    ...    Device Plan dropdown must have options after account resolution.

Validate Rule Category Options Loaded
    [Documentation]    Asserts Rule Category dropdown has at least one option from API.
    ${is_native}=    Element Visible After Poll    ${LOC_RE_RULE_CATEGORY_SELECT}    5s
    IF    ${is_native}
        ${count}=    Get Element Count    ${LOC_RE_RULE_CATEGORY_NATIVE_OPTIONS}
        Should Be True    ${count} > 0
        ...    Rule Category dropdown must have options from API.
    ELSE
        Click Visible Rule Category Select Button
        Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_OPTIONS_PORTAL}    timeout=10s
        Press Keys    None    ESCAPE
    END

Validate Action Saved In List
    [Documentation]    Asserts at least one action is saved in the action panel.
    [Arguments]    ${expected_text}=${EMPTY}
    Wait For Loading Overlay To Disappear
    IF    "${expected_text}" != "${EMPTY}"
        Page Should Contain    ${expected_text}
        Log    Action saved and visible (found: ${expected_text}).    console=yes
    ELSE
        ${has_email}=    Run Keyword And Return Status    Page Should Contain    ${RE_ALERT_EMAIL}
        IF    ${has_email}
            Log    Action saved and visible (found ${RE_ALERT_EMAIL}).    console=yes
        ELSE
            ${has_panel}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_RE_ACTION_LIST_PANEL}
            ${has_saved}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_RE_SAVED_ACTION_ENTRY}
            Should Be True    ${has_panel} or ${has_saved}
            ...    No saved action found: expected email text, action list panel, or saved action entry.
            Log    Action saved and visible (panel or saved entry).    console=yes
        END
    END

Validate Device Plan Disabled
    [Documentation]    Asserts the Device Plan dropdown is disabled.
    Element Should Be Disabled    ${LOC_RE_DEVICE_PLAN}

Validate Previous Button Not Visible On Tab 1
    [Documentation]    Previous button should not exist in DOM when Tab 1 is active.
    ${visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_PREVIOUS_BTN}
    Should Not Be True    ${visible}
    ...    Previous button should be hidden on Tab 1.

Validate Redirected To Rule Engine Listing
    [Documentation]    Asserts browser navigated back to /RuleEngine listing.
    Wait For Loading Overlay To Disappear
    Location Should Contain    ${RE_RULE_ENGINE_PATH}
    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=10s
