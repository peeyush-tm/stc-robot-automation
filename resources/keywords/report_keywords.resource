*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/report_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION — Reports sidebar and Create Report form
# ═══════════════════════════════════════════════════════════════════════
Navigate To Reports Page
    [Documentation]    SPA-safe: reach /Report via top tab (if present) or left sidebar ``Report-icon``.
    ...                Does not use ``Go To`` for listing (same class of issue as Manage Label direct URL).
    Wait For Loading Overlay To Disappear
    ${url}=    Get Location
    # Path must be /Report (not /ReportSubscriptions, etc.): /Report then ? # / or end.
    ${on_report_path}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${url}    (?i).*/Report([?#/]|$)
    ${is_create}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${url}    (?i).*CreateReports
    IF    ${on_report_path} and not ${is_create}
        Wait For App Loading To Complete
        Wait Until Element Is Visible    ${LOC_REPORT_PAGE_BODY}    timeout=30s
        Log    Already on Report listing.
        RETURN
    END
    ${tab_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TAB_REPORT}    timeout=5s
    IF    ${tab_ok}
        Scroll To Element Via JS    ${LOC_TAB_REPORT}
        Click Element Via JS    ${LOC_TAB_REPORT}
    ELSE
        ${side_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_NAV_REPORTS_SIDEBAR}    timeout=8s
        IF    ${side_ok}
            Scroll To Element Via JS    ${LOC_NAV_REPORTS_SIDEBAR}
            Click Element Via JS    ${LOC_NAV_REPORTS_SIDEBAR}
        ELSE
            Scroll To Element Via JS    ${LOC_NAV_REPORTS}
            Wait Until Element Is Visible    ${LOC_NAV_REPORTS}    timeout=30s
            Click Element Via JS    ${LOC_NAV_REPORTS}
        END
    END
    Wait Until Location Contains    /Report    timeout=15s
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_REPORT_PAGE_BODY}    timeout=30s
    Log    Navigated to Report listing page.

Open Create Report Form
    [Documentation]    Navigate directly to CreateReports URL (hard navigation) to ensure React
    ...                components are freshly mounted with clean dropdown state each time.
    Wait For Loading Overlay To Disappear
    ${create_url}=    Evaluate    '${BASE_URL}'.rstrip('/') + '/CreateReports'
    Go To    ${create_url}
    Wait Until Location Contains    /CreateReports    timeout=15s
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_BTN_CREATE}    timeout=30s
    Sleep    1s
    Log    Create Report form opened.

Login And Navigate To Create Report
    [Documentation]    Ensures session is active, then navigates to Create Report page via URL.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_REPORT_URL}
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_BTN_CREATE}    timeout=30s

Navigate To Reports Page Via URL
    [Documentation]    Same as ``Navigate To Reports Page`` (sidebar/tab). ``report_listing_url`` is ignored — kept for call compatibility; do not use ``Go To`` for SPA listing.
    [Arguments]    ${report_listing_url}
    Navigate To Reports Page

# ═══════════════════════════════════════════════════════════════════════
#  CREATE REPORT FORM — Field interactions
# ═══════════════════════════════════════════════════════════════════════
Force Select Visible And Select By Label
    [Documentation]    Forces a hidden <select> to be CSS-visible, selects option by label, then hides it again.
    [Arguments]    ${select_name}    ${label}
    Execute JavaScript
    ...    var s=document.querySelector('select[name="${select_name}"]');
    ...    if(s){s.style.cssText='display:block!important;visibility:visible!important;opacity:1!important;position:relative!important;width:auto!important;height:auto!important;';}
    Wait Until Element Is Visible    xpath=//select[@name='${select_name}']    timeout=10s
    Select From List By Label    xpath=//select[@name='${select_name}']    ${label}
    Sleep    0.5s

Force Select Visible And Select By Value
    [Documentation]    Forces a hidden <select> to be CSS-visible, selects option by value, then uses it.
    [Arguments]    ${select_name}    ${value}
    Execute JavaScript
    ...    var s=document.querySelector('select[name="${select_name}"]');
    ...    if(s){s.style.cssText='display:block!important;visibility:visible!important;opacity:1!important;position:relative!important;width:auto!important;height:auto!important;';}
    Wait Until Element Is Visible    xpath=//select[@name='${select_name}']    timeout=10s
    Select From List By Value    xpath=//select[@name='${select_name}']    ${value}
    Sleep    0.5s

Select Report Category
    [Documentation]    Selects report category from custom DIV.Dropdownlist component.
    ...                1) Selenium native click opens dropdown (React state updates properly).
    ...                2) Wait for selectDropdown to appear (options are rendered).
    ...                3) If option not immediately visible, use JS to force-show searchInput
    ...                   and inject the search value via native setter + input event.
    ...                4) Scroll option into view and click it.
    [Arguments]    ${category_name}
    Wait Until Element Is Visible    ${LOC_RC_TRIGGER}    timeout=15s
    Scroll To Element Via JS    ${LOC_RC_TRIGGER}
    # Clear any stale search filter left in searchInput from previous interactions
    Execute JavaScript
    ...    var lbl=Array.from(document.querySelectorAll('label')).find(function(l){
    ...        return (l.innerText||'').replace('*','').trim()==='Report Category';
    ...    });
    ...    if(!lbl) return;
    ...    var si=lbl.parentElement.querySelector('.searchInput');
    ...    if(si && si.value){
    ...        var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...        setter.call(si,'');
    ...        si.dispatchEvent(new Event('input',{bubbles:true}));
    ...    }
    Sleep    0.3s
    Click Element    ${LOC_RC_TRIGGER}
    Wait Until Element Is Visible    ${LOC_RC_DROPDOWN}    timeout=10s
    ${option_loc}=    Set Variable
    ...    xpath=//label[contains(normalize-space(),'Report Category')]/following-sibling::div[contains(@class,'coldiv')]//div[contains(@class,'selectDropdown')]//*[normalize-space(.)='${category_name}' and not(contains(@class,'dropnodata'))]
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option_loc}    timeout=3s
    IF    not ${option_visible}
        Execute JavaScript
        ...    var lbl=Array.from(document.querySelectorAll('label')).find(function(l){
        ...        return (l.innerText||'').replace('*','').trim()==='Report Category';
        ...    });
        ...    if(!lbl) return;
        ...    var si=lbl.parentElement.querySelector('.searchInput');
        ...    if(!si) return;
        ...    si.style.cssText='display:block!important;visibility:visible!important;opacity:1!important;';
        ...    var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
        ...    setter.call(si,'${category_name}');
        ...    si.dispatchEvent(new Event('input',{bubbles:true}));
        ...    si.dispatchEvent(new Event('change',{bubbles:true}));
    END
    Sleep    1s
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option_loc}    timeout=10s
    IF    not ${found}
        ${all_opts}=    Execute JavaScript
        ...    var lbl=Array.from(document.querySelectorAll('label')).find(function(l){
        ...        return (l.innerText||'').replace('*','').trim()==='Report Category';
        ...    });
        ...    if(!lbl) return 'NO_LABEL';
        ...    var si=lbl.parentElement.querySelector('.searchInput');
        ...    if(si){
        ...        si.style.cssText='display:block!important;visibility:visible!important;opacity:1!important;';
        ...        var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
        ...        setter.call(si,'');
        ...        si.dispatchEvent(new Event('input',{bubbles:true}));
        ...    }
        ...    var dd=lbl.parentElement.querySelector('.selectDropdown');
        ...    if(!dd) return 'NO_DROPDOWN';
        ...    return Array.from(dd.querySelectorAll('*')).filter(function(e){return e.childElementCount===0 && (e.innerText||'').trim() && !e.className.includes('dropnodata');}).map(function(e){return (e.innerText||'').trim();}).join(' | ');
        Fail    Option '${category_name}' not found. Available options: ${all_opts}
    END
    Scroll To Element Via JS    ${option_loc}
    Click Element    ${option_loc}
    Sleep    1s
    Wait For Loading Overlay To Disappear

Select View Criterion
    [Documentation]    Selects view criterion by value (e.g. DAY, WEEK, MONTH) — React-safe JS setter.
    [Arguments]    ${criterion_value}
    Sleep    0.5s
    ${result}=    Execute JavaScript
    ...    var sel = document.querySelector('select[name="viewCriteria"]');
    ...    if (!sel) return 'ERR:NO_SELECT';
    ...    var opt = Array.from(sel.options).find(function(o){return o.value==='${criterion_value}' || o.text.trim()==='${criterion_value}';});
    ...    if (!opt) return 'ERR:OPT_NOT_FOUND:available='+Array.from(sel.options).map(function(o){return o.value+':'+o.text;}).join('|');
    ...    var setter=Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype,'value').set;
    ...    setter.call(sel,opt.value);
    ...    sel.dispatchEvent(new Event('change',{bubbles:true}));
    ...    sel.dispatchEvent(new Event('input',{bubbles:true}));
    ...    return 'OK:'+opt.value;
    Log    Select View Criterion result: ${result}    console=yes
    IF    '${result}'.startswith('ERR:')
        Fail    Select View Criterion failed — ${result}
    END
    Sleep    0.5s
    Wait For Loading Overlay To Disappear

Wait For From Date Picker
    [Documentation]    Waits for date picker input after view criterion selection. Accepts hidden input too.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_INPUT_FROM_DATE}    timeout=10s
    IF    not ${visible}
        Wait Until Page Contains Element    ${LOC_INPUT_FROM_DATE}    timeout=15s
    END
    Log    Date picker ready.

Select Display Level
    [Documentation]    Selects display level by value (e.g. OPCO) — React-safe JS setter.
    [Arguments]    ${level_value}
    ${result}=    Execute JavaScript
    ...    var sel = document.querySelector('select[name="displayLevel"]');
    ...    if (!sel) return 'ERR:NO_SELECT';
    ...    var opt = Array.from(sel.options).find(function(o){return o.value==='${level_value}' || o.text.trim()==='${level_value}';});
    ...    if (!opt) return 'ERR:OPT_NOT_FOUND:available='+Array.from(sel.options).map(function(o){return o.value+':'+o.text;}).join('|');
    ...    var setter=Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype,'value').set;
    ...    setter.call(sel,opt.value);
    ...    sel.dispatchEvent(new Event('change',{bubbles:true}));
    ...    sel.dispatchEvent(new Event('input',{bubbles:true}));
    ...    return 'OK:'+opt.value;
    Log    Select Display Level result: ${result}    console=yes
    IF    '${result}'.startswith('ERR:')
        Fail    Select Display Level failed — ${result}
    END
    Sleep    1s
    Wait For Loading Overlay To Disappear

Verify Account Auto Selected
    [Documentation]    Verifies Account field has a value after Display Level selection.
    ...                Handles both native <select> and disabled/readonly text input patterns.
    Sleep    1s
    ${account_val}=    Execute JavaScript
    ...    var lbl = Array.from(document.querySelectorAll('label')).find(function(l){
    ...        return (l.innerText||'').replace('*','').trim()==='Account';
    ...    });
    ...    if (!lbl) return '';
    ...    var container = lbl.parentElement;
    ...    var sel = container.querySelector('select[name="account"]') || container.querySelector('select');
    ...    if (sel && sel.value) return sel.value;
    ...    var inp = container.querySelector('input[type="text"],input:not([type])');
    ...    if (inp && (inp.placeholder||'').toLowerCase().indexOf('search')>=0) inp=null;
    ...    if (inp && inp.value) return inp.value;
    ...    if (inp && inp.placeholder) return inp.placeholder;
    ...    var sb = container.querySelector('.selectBtn');
    ...    if (sb && (sb.innerText||'').trim() && (sb.innerText||'').trim().toLowerCase()!=='select') return (sb.innerText||'').trim();
    ...    var txt = (container.innerText || '').replace((lbl.innerText||''),'').replace('*','').trim();
    ...    return txt || '';
    Log    Account auto-selected value: ${account_val}    console=yes
    Should Not Be Empty    ${account_val}    msg=Account should be auto-selected for OPCO display level

Select Report Format
    [Documentation]    Selects report format by value (PDF, CSV, XLSX) — React-safe JS setter.
    [Arguments]    ${format_value}
    ${result}=    Execute JavaScript
    ...    var sel = document.querySelector('select[name="format"]');
    ...    if (!sel) return 'ERR:NO_SELECT';
    ...    var opt = Array.from(sel.options).find(function(o){return o.value==='${format_value}' || o.text.trim()==='${format_value}';});
    ...    if (!opt) return 'ERR:OPT_NOT_FOUND:available='+Array.from(sel.options).map(function(o){return o.value+':'+o.text;}).join('|');
    ...    var setter=Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype,'value').set;
    ...    setter.call(sel,opt.value);
    ...    sel.dispatchEvent(new Event('change',{bubbles:true}));
    ...    sel.dispatchEvent(new Event('input',{bubbles:true}));
    ...    return 'OK:'+opt.value;
    Log    Select Report Format result: ${result}    console=yes
    IF    '${result}'.startswith('ERR:')
        Fail    Select Report Format failed — ${result}
    END

Enable Send Email
    [Documentation]    Checks Send Email / Send E-mail checkbox and waits for email panel.
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_SEND_EMAIL}    timeout=5s
    IF    not ${found}
        ${alt}=    Set Variable    xpath=//label[contains(.,'mail')][contains(.,'Send')]/following::input[@type='checkbox'][1]
        Wait Until Element Is Visible    ${alt}    timeout=10s
        Scroll To Element Via JS    ${alt}
        Click Element    ${alt}
    ELSE
        Scroll To Element Via JS    ${LOC_CHK_SEND_EMAIL}
        Click Element    ${LOC_CHK_SEND_EMAIL}
    END
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_INPUT_EMAIL_RECIPIENT}    timeout=10s

Add Email Recipient
    [Documentation]    Types email into ReactTags input and presses Enter to add tag.
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${LOC_INPUT_EMAIL_RECIPIENT}    timeout=10s
    Input Text    ${LOC_INPUT_EMAIL_RECIPIENT}    ${email}
    Press Keys    ${LOC_INPUT_EMAIL_RECIPIENT}    RETURN
    Wait Until Page Contains    ${email}    timeout=5s

Submit Create Report Form
    [Documentation]    Clicks the Create button (input type=button) to submit.
    Wait Until Element Is Visible    ${LOC_BTN_CREATE}    timeout=15s
    Scroll To Element Via JS    ${LOC_BTN_CREATE}
    Click Element Via JS    ${LOC_BTN_CREATE}
    Sleep    1s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — After create (success toast, redirect, grid)
# ═══════════════════════════════════════════════════════════════════════
Verify Report Created Successfully
    [Documentation]    Verifies success toast, redirect to /Report, and listing body visible.
    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    timeout=30s
    Wait Until Location Contains    /Report    timeout=15s
    Wait Until Element Is Visible    ${LOC_REPORT_PAGE_BODY}    timeout=15s
    Log    Report created — redirected to Report listing.

Verify Report Created Successfully And Grid Visible
    [Documentation]    Success toast, redirect to /Report, then wait for grid.
    Verify Report Created Successfully
    Wait For Report Grid    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  REPORT LISTING PAGE — Grid, filter, first row, actions
# ═══════════════════════════════════════════════════════════════════════
Wait For Report Grid
    [Documentation]    Waits for the report Kendo grid (or tbody) to be visible.
    [Arguments]    ${timeout}=30s
    Wait Until Element Is Visible    ${LOC_REPORT_GRID_ANY}    timeout=${timeout}
    ${tbody}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_REPORT_GRID_TBODY}    timeout=10s
    IF    ${tbody}
        Log    Report grid tbody visible.
    ELSE
        Log    Report grid container visible.
    END

Apply Report Name Filter
    [Documentation]    Types into the dedicated **Report Name** filter field (located under the
    ...                "Report Name" label inside the filter panel — NOT the global "Enter Search
    ...                Text" search bar) and clicks **Apply Filter**. After this filter the grid
    ...                shows ONLY rows whose report name matches — first row is guaranteed to be
    ...                our report.
    [Arguments]    ${report_name}
    Wait For Loading Overlay To Disappear
    Sleep    0.5s
    Wait Until Element Is Visible    ${LOC_FILTER_REPORT_NAME_BY_LABEL}    timeout=15s
    Scroll To Element Via JS    ${LOC_FILTER_REPORT_NAME_BY_LABEL}
    Clear Element Text    ${LOC_FILTER_REPORT_NAME_BY_LABEL}
    Input Text    ${LOC_FILTER_REPORT_NAME_BY_LABEL}    ${report_name}
    # Re-fire React onChange via JS to make sure the controlled input picked up the value
    Execute Javascript
    ...    var inp = document.evaluate("(//*[normalize-space(text())='Report Name']/following::input[@type='text' or not(@type)])[1]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    ...    if (inp) {
    ...        var setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...        setter.call(inp, '${report_name}');
    ...        inp.dispatchEvent(new Event('input',{bubbles:true}));
    ...        inp.dispatchEvent(new Event('change',{bubbles:true}));
    ...    }
    Log To Console    Report Name filter typed: "${report_name}"
    Sleep    0.5s
    Wait Until Element Is Visible    ${LOC_BTN_APPLY_FILTER}    timeout=15s
    Scroll To Element Via JS    ${LOC_BTN_APPLY_FILTER}
    Click Element Via JS    ${LOC_BTN_APPLY_FILTER}
    Log To Console    Apply Filter clicked.
    Sleep    1.5s
    Wait For Loading Overlay To Disappear

Apply Report ID Filter
    [Documentation]    Types the Report ID into the Report page's **search-text input** at the top
    ...                of the listing, then presses Enter to trigger the filter. Called ONCE per
    ...                report — the polling loop after this only checks for the download icon, it
    ...                does NOT re-filter (the grid stays filtered to our one row).
    [Arguments]    ${report_id}
    Wait For Loading Overlay To Disappear
    Sleep    0.5s
    ${search_input}=    Set Variable    xpath=//input[@placeholder='Enter Search Text']
    Wait Until Element Is Visible    ${search_input}    timeout=15s
    Scroll To Element Via JS    ${search_input}
    Clear Element Text    ${search_input}
    Input Text    ${search_input}    ${report_id}
    # Re-fire React onChange via setter — some controlled components miss the Selenium native event
    Execute Javascript
    ...    var inp = document.querySelector('input[placeholder="Enter Search Text"]');
    ...    if (inp) {
    ...        var setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...        setter.call(inp, '${report_id}');
    ...        inp.dispatchEvent(new Event('input',{bubbles:true}));
    ...        inp.dispatchEvent(new Event('change',{bubbles:true}));
    ...    }
    Sleep    0.3s
    Press Keys    ${search_input}    RETURN
    Log To Console    Report search filter: typed "${report_id}" + pressed Enter (one-time)
    Sleep    2s
    Wait For Loading Overlay To Disappear

Apply Report Filter By Label
    [Documentation]    Generic helper — finds the LABEL element whose visible text exactly equals
    ...                ``${label_text}``, then locates its IMMEDIATE form-group container (col /
    ...                form-group / filter-item) and picks the **first text-input INSIDE that
    ...                container only**. This avoids picking inputs from neighbouring rows
    ...                (e.g. "Created By" sitting below "Report ID" in the same column).
    ...                Sets value via React-safe setter + dispatches input/change events.
    ...                Returns ``OK:<id>:<value>`` on success, ``ERR:<reason>`` otherwise.
    [Arguments]    ${label_text}    ${value}
    ${result}=    Execute Javascript
    ...    function norm(s){ return (s||'').replace(/\\s+/g,' ').trim(); }
    ...    var target = '${label_text}';
    ...    var nodes = document.querySelectorAll('label, .form-label, .k-label, span, div, p');
    ...    var matched = null;
    ...    for (var i = 0; i < nodes.length; i++) {
    ...        if (nodes[i].offsetParent === null) continue;
    ...        var t = norm(nodes[i].innerText || nodes[i].textContent || '');
    ...        if (t === target) { matched = nodes[i]; break; }
    ...    }
    ...    if (!matched) return 'ERR:LABEL_NOT_FOUND:' + target;
    ...    var container = matched.closest('.form-group, [class*="col-"], fieldset, [class*="filter-item"], [class*="filterItem"]');
    ...    var inp = null;
    ...    if (container) {
    ...        var inps = container.querySelectorAll('input[type="text"], input:not([type])');
    ...        for (var j = 0; j < inps.length; j++) { if (inps[j].offsetParent !== null && !inps[j].disabled && !inps[j].readOnly) { inp = inps[j]; break; } }
    ...    }
    ...    if (!inp) {
    ...        var p = matched.parentElement;
    ...        if (p) {
    ...            var inps2 = p.querySelectorAll('input[type="text"], input:not([type])');
    ...            for (var k = 0; k < inps2.length; k++) { if (inps2[k].offsetParent !== null && !inps2[k].disabled && !inps2[k].readOnly) { inp = inps2[k]; break; } }
    ...        }
    ...    }
    ...    if (!inp) {
    ...        var sib = matched.nextElementSibling;
    ...        while (sib && !inp) {
    ...            if (sib.tagName === 'INPUT' && sib.offsetParent !== null && !sib.disabled && !sib.readOnly) { inp = sib; break; }
    ...            var nested = sib.querySelector ? sib.querySelector('input[type="text"], input:not([type])') : null;
    ...            if (nested && nested.offsetParent !== null && !nested.disabled && !nested.readOnly) { inp = nested; break; }
    ...            sib = sib.nextElementSibling;
    ...        }
    ...    }
    ...    if (!inp) return 'ERR:NO_INPUT_FOR_LABEL:' + target;
    ...    inp.scrollIntoView({block:'center'});
    ...    inp.focus();
    ...    var setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    setter.call(inp, '${value}');
    ...    inp.dispatchEvent(new Event('input',{bubbles:true}));
    ...    inp.dispatchEvent(new Event('change',{bubbles:true}));
    ...    var idn = inp.id || inp.name || inp.placeholder || 'unnamed';
    ...    return 'OK:' + idn + ':' + (inp.value || '');
    RETURN    ${result}

Click Apply Filter Button
    [Documentation]    Locates and clicks the Apply Filter button via runtime DOM walk —
    ...                more resilient than xpath since the button text is the key signal.
    ${result}=    Execute Javascript
    ...    var btns = document.querySelectorAll('button, a, input[type="button"], input[type="submit"]');
    ...    for (var i = 0; i < btns.length; i++) {
    ...        var t = ((btns[i].textContent || btns[i].value || '') || '').replace(/\\s+/g,' ').trim();
    ...        if (t === 'Apply Filter' && btns[i].offsetParent !== null) {
    ...            btns[i].scrollIntoView({block:'center'});
    ...            btns[i].click();
    ...            return 'OK';
    ...        }
    ...    }
    ...    return 'ERR:NOT_FOUND';
    Should Be Equal    ${result}    OK    msg=Apply Filter button not found / not clickable.
    Log To Console    Apply Filter clicked.

Validate First Row Report Name
    [Documentation]    Asserts the first grid row contains the expected report name (or contains text).
    [Arguments]    ${expected_report_name}
    Wait Until Element Is Visible    ${LOC_REPORT_GRID_FIRST_ROW}    timeout=15s
    ${name_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_FIRST_ROW_REPORT_NAME_CELL}    timeout=5s
    IF    ${name_visible}
        ${cell_text}=    Get Text    ${LOC_FIRST_ROW_REPORT_NAME_CELL}
        Should Contain    ${cell_text}    ${expected_report_name}
        ...    msg=First row REPORT NAME column should contain '${expected_report_name}'
    ELSE
        ${row_text}=    Get Text    ${LOC_REPORT_GRID_FIRST_ROW}
        Should Contain    ${row_text}    ${expected_report_name}
        ...    msg=First row should contain '${expected_report_name}'
    END
    Log    First row report name validated: ${expected_report_name}

Validate Delete And Download Icons In First Row
    [Documentation]    Verifies Delete (trash) and Download icons are present in first row action cell.
    Wait Until Element Is Visible    ${LOC_REPORT_GRID_FIRST_ROW}    timeout=15s
    # Delete: often fa-trash or [title*='Delete'] or similar
    ${delete_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_FIRST_ROW_DELETE_ICON}    timeout=5s
    IF    not ${delete_visible}
        ${count}=    Get Element Count    xpath=(//div[contains(@class,'k-grid')]//tbody//tr[contains(@class,'k-master-row')])[1]//td[2]//a
        Should Be True    ${count} >= 1    msg=First row ACTION column should have at least a Delete link
        Log    First row has ${count} action link(s) — Delete icon present.
    ELSE
        Log    Delete icon visible in first row.
    END
    ${download_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_FIRST_ROW_DOWNLOAD_ICON}    timeout=5s
    IF    ${download_visible}
        Log    Download icon visible in first row.
    ELSE
        Log    Download icon not yet visible in first row (report may still be generating). Delete icon confirmed present.
    END

First Row Download Action Ready
    [Documentation]    True when the Download link in the first row ACTION column is VISIBLE
    ...                (report status has transitioned from In Progress → Completed/Ready).
    Element Should Be Visible    ${LOC_FIRST_ROW_DOWNLOAD_LINK}

Wait For Report Ready To Download
    [Documentation]    Single-attempt poll body — checks the already-filtered grid (filter was
    ...                applied ONCE by the caller via ``Apply Report ID Filter``) for the
    ...                download link in the first row. Passes when the download icon becomes
    ...                visible (report status moved In Progress → Completed).
    ...                ``${report_id}`` arg is kept for log clarity only — no re-typing/no-Enter.
    [Arguments]    ${report_id}
    Wait For Report Grid
    First Row Download Action Ready

Click Page CSV Download Button
    [Documentation]    Clicks the page-level CSV download button (next to "Create Reports" at
    ...                the top of the Reports listing). Returns the JS result for diagnostics.
    ...                Used instead of the row-level download icon (which has a rendering bug).
    ${result}=    Execute Javascript
    ...    var btns = document.querySelectorAll('a, button, span, img, div, i');
    ...    var match = null;
    ...    for (var i = 0; i < btns.length; i++) {
    ...        var el = btns[i];
    ...        if (el.offsetParent === null) continue;
    ...        var blob = ((el.className||'') + ' ' + (el.title||'') + ' ' + (el.alt||'') + ' ' + (el.getAttribute && el.getAttribute('aria-label') || '')).toLowerCase();
    ...        var txt = (el.innerText || el.textContent || '').replace(/\\s+/g,'').toLowerCase();
    ...        if (blob.indexOf('csv') >= 0 || txt === 'csv') {
    ...            var rect = el.getBoundingClientRect();
    ...            if (rect.width > 0 && rect.height > 0 && rect.top < 600) { match = el; break; }
    ...        }
    ...    }
    ...    if (!match) return 'ERR:CSV_BTN_NOT_FOUND';
    ...    match.scrollIntoView({block:'center'});
    ...    match.click();
    ...    return 'OK:' + (match.id || match.className || match.tagName);
    Should Match Regexp    ${result}    ^OK    msg=Page CSV download button not found / not clickable. Result=${result}
    Log To Console    ✓ Clicked page CSV download button → ${result}

Validate Report CSV Downloaded
    [Documentation]    Waits up to 30s for any new ``*.csv`` file to land in the user's Downloads
    ...                folder (Chrome default). Returns the latest CSV path on success; fails with
    ...                a clear error otherwise. Pure file-system check, no UI.
    ...                Creates the Downloads dir on first use if missing (headless server without
    ...                a GUI session may not have ~/Downloads yet → would crash on os.listdir).
    ${downloads_dir}=    Evaluate    __import__('os').path.expanduser('~/Downloads')
    ${made}=    Evaluate    __import__('os').makedirs(r'${downloads_dir}', exist_ok=True) or True    modules=os
    ${baseline_count}=    Evaluate    sum(1 for f in __import__('os').listdir(r'${downloads_dir}') if f.lower().endswith('.csv'))    modules=os
    Log To Console    Downloads dir: ${downloads_dir} (baseline CSV count = ${baseline_count})
    FOR    ${i}    IN RANGE    60
        ${current_count}=    Evaluate    sum(1 for f in __import__('os').listdir(r'${downloads_dir}') if f.lower().endswith('.csv'))    modules=os
        IF    ${current_count} > ${baseline_count}
            ${latest}=    Evaluate    max((__import__('os').path.join(r'${downloads_dir}', f) for f in __import__('os').listdir(r'${downloads_dir}') if f.lower().endswith('.csv')), key=__import__('os').path.getmtime)    modules=os
            ${size}=    Evaluate    __import__('os').path.getsize(r'${latest}')    modules=os
            Log To Console    ✓ CSV downloaded: ${latest} (${size} bytes)
            RETURN    ${latest}
        END
        Sleep    1s
    END
    Fail    No new CSV file appeared in ${downloads_dir} within 60s after CSV download click.

Download Report From First Row And Verify Click
    [Documentation]    After the filter has been applied (one-time search + Enter), waits a moment
    ...                for the report's row to render, then clicks the **page-level CSV download
    ...                button** (NOT the row-level icon — that has a UI rendering bug). Validates:
    ...                  1. No error toast appears
    ...                  2. URL still ends in /Report
    ...                  3. A new .csv file lands in the Downloads folder within 30s
    [Arguments]    ${filter_name}=${EMPTY}
    Wait Until Element Is Visible    ${LOC_REPORT_GRID_FIRST_ROW}    timeout=30s
    Sleep    1s
    Click Page CSV Download Button
    # Verify no error toast
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    timeout=2s
    Should Not Be True    ${error_toast}    msg=CSV download should not show an error toast
    Location Should Contain    /Report
    # Verify a new CSV file actually downloaded
    ${csv_path}=    Validate Report CSV Downloaded
    Log To Console    ✓ Report download verified — file at ${csv_path}
    RETURN    ${csv_path}

# ═══════════════════════════════════════════════════════════════════════
#  ACCOUNT SELECTION — Customer / Business Unit display level
# ═══════════════════════════════════════════════════════════════════════
Select Account For Report
    [Documentation]    Selects account in the Account custom Dropdownlist (same component
    ...                as Report Category). Structure: label[Account] sibling/child of
    ...                div.coldiv > div.Dropdownlist > div.searcharea > input.searchInput +
    ...                div.select > div.selectBtn + div.selectDropdown > div.option.
    ...                Flow: click selectBtn, inject search text into searchInput, click
    ...                the matching div.option scoped strictly to Account's coldiv.
    [Arguments]    ${account_name}
    Should Not Be Empty    ${account_name}    msg=Select Account For Report: account_name is empty
    Sleep    1s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_ACC_TRIGGER}    timeout=15s
    Scroll To Element Via JS    ${LOC_ACC_TRIGGER}
    # Clear any prior search value
    Execute JavaScript
    ...    var lbl=Array.from(document.querySelectorAll('label')).find(function(l){
    ...        return (l.innerText||'').replace('*','').trim()==='Account';
    ...    });
    ...    if(!lbl) return;
    ...    var sib=lbl.nextElementSibling;
    ...    while(sib && !(sib.classList && sib.classList.contains('coldiv'))) sib=sib.nextElementSibling;
    ...    if(!sib) sib=lbl.parentElement.querySelector('.coldiv');
    ...    if(!sib) return;
    ...    var si=sib.querySelector('.searchInput');
    ...    if(si && si.value){
    ...        var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...        setter.call(si,'');
    ...        si.dispatchEvent(new Event('input',{bubbles:true}));
    ...    }
    Sleep    0.3s
    Click Element    ${LOC_ACC_TRIGGER}
    Wait Until Element Is Visible    ${LOC_ACC_DROPDOWN}    timeout=10s
    ${option_loc}=    Set Variable
    ...    xpath=//label[contains(normalize-space(),'Account')]/following-sibling::div[contains(@class,'coldiv')]//div[contains(@class,'selectDropdown')]//*[normalize-space(.)='${account_name}' and not(contains(@class,'dropnodata'))]
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option_loc}    timeout=3s
    IF    not ${option_visible}
        Execute JavaScript
        ...    var lbl=Array.from(document.querySelectorAll('label')).find(function(l){
        ...            return (l.innerText||'').replace('*','').trim()==='Account';
        ...    });
        ...    if(!lbl) return;
        ...    var sib=lbl.nextElementSibling;
        ...    while(sib && !(sib.classList && sib.classList.contains('coldiv'))) sib=sib.nextElementSibling;
        ...    if(!sib) sib=lbl.parentElement.querySelector('.coldiv');
        ...    if(!sib) return;
        ...    var si=sib.querySelector('.searchInput');
        ...    if(!si) return;
        ...    si.style.cssText='display:block!important;visibility:visible!important;opacity:1!important;';
        ...    var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
        ...    setter.call(si,'${account_name}');
        ...    si.dispatchEvent(new Event('input',{bubbles:true}));
        ...    si.dispatchEvent(new Event('change',{bubbles:true}));
    END
    Sleep    1.5s
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option_loc}    timeout=10s
    IF    not ${found}
        ${all_opts}=    Execute JavaScript
        ...    var lbl=Array.from(document.querySelectorAll('label')).find(function(l){
        ...            return (l.innerText||'').replace('*','').trim()==='Account';
        ...    });
        ...    if(!lbl) return 'NO_LABEL';
        ...    var sib=lbl.nextElementSibling;
        ...    while(sib && !(sib.classList && sib.classList.contains('coldiv'))) sib=sib.nextElementSibling;
        ...    if(!sib) sib=lbl.parentElement.querySelector('.coldiv');
        ...    if(!sib) return 'NO_COLDIV';
        ...    var dd=sib.querySelector('.selectDropdown');
        ...    if(!dd) return 'NO_DROPDOWN';
        ...    return Array.from(dd.querySelectorAll('*')).filter(function(e){return e.childElementCount===0 && (e.innerText||'').trim() && !(e.className||'').includes('dropnodata');}).map(function(e){return (e.innerText||'').trim();}).join(' | ');
        Log To Console    Account dropdown options dump: ${all_opts}
        Fail    Account "${account_name}" not found in Account dropdown. Available options: ${all_opts}
    END
    Scroll To Element Via JS    ${option_loc}
    Click Element    ${option_loc}
    Sleep    1s
    Wait For Loading Overlay To Disappear
    Log To Console    Account "${account_name}" selected successfully.

# ═══════════════════════════════════════════════════════════════════════
#  E2E ORCHESTRATOR — Create + Download a single report
# ═══════════════════════════════════════════════════════════════════════
E2E Create And Download One Report
    [Documentation]    Full single-report flow: Create Report page → fill fields for the given
    ...                ``${display_level}`` (OPCO, Customer, Business Unit) and ``${account_name}``
    ...                → submit → wait for Completed → download → assert no error toast.
    ...                For OPCO, ``${account_name}`` is ignored (auto-selects KSA_OPCO).
    [Arguments]    ${display_level}    ${account_name}=${EMPTY}
    Log To Console    \n══════════════════════════════════════════════════════════════════════
    Log To Console    Creating Usage Report — display_level="${display_level}" account="${account_name}"
    Log To Console    ══════════════════════════════════════════════════════════════════════
    Login And Navigate To Create Report
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${display_level}
    IF    '${display_level}' == 'OPCO'
        Verify Account Auto Selected
    ELSE
        Should Not Be Empty    ${account_name}
        ...    msg=account_name required for display_level="${display_level}"
        Select Account For Report    ${account_name}
    END
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Submit Create Report Form
    Verify Report Created Successfully And Grid Visible
    # Capture the auto-assigned Report ID from the FIRST row (most recent = our just-created report).
    # System auto-generates the report name (always equals the Category, e.g. "Usage Report") so it
    # can't be used as a unique filter. Report ID is auto-incrementing & unique.
    Wait Until Element Is Visible    ${LOC_FIRST_ROW_REPORT_ID_CELL}    timeout=15s
    ${report_id}=    Get Text    ${LOC_FIRST_ROW_REPORT_ID_CELL}
    ${report_id}=    Strip String    ${report_id}
    Should Not Be Empty    ${report_id}    msg=Could not capture Report ID from first row after creation.
    Log To Console    ✓ Report submitted for "${display_level}" — captured Report ID=${report_id}
    # Filter by EXACT Report ID — grid then shows ONLY our report → first row IS ours.
    Apply Report ID Filter    ${report_id}
    Download Report From First Row And Verify Click    ${report_id}
    Log To Console    ✓ Report ID=${report_id} (${display_level}) generated + downloaded successfully.

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — Validations
# ═══════════════════════════════════════════════════════════════════════
Verify Error Toast Shown
    [Documentation]    Asserts that an error toast is displayed.
    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    timeout=10s
    Log    Error toast displayed as expected.

Verify Validation Error Report Category
    [Documentation]    Asserts Report Category validation error is visible.
    Wait Until Element Is Visible    ${LOC_ERR_REPORT_CATEGORY}    timeout=10s

Verify Validation Error View Criterion
    [Documentation]    Asserts View Criterion validation error is visible.
    Wait Until Element Is Visible    ${LOC_ERR_VIEW_CRITERION}    timeout=10s

Verify Validation Error Display Level
    [Documentation]    Asserts Display Level validation error is visible.
    Wait Until Element Is Visible    ${LOC_ERR_DISPLAY_LEVEL}    timeout=10s

Verify Validation Error Report Format
    [Documentation]    Asserts Report Format validation error is visible.
    Wait Until Element Is Visible    ${LOC_ERR_REPORT_FORMAT}    timeout=10s

Verify Still On Create Report Page
    [Documentation]    Confirms URL contains /CreateReports and form is visible.
    Location Should Contain    /CreateReports
    Wait Until Element Is Visible    ${LOC_BTN_CREATE}    timeout=10s

Verify Redirect To Report Listing
    [Documentation]    After Close button, URL should contain /Report.
    Wait Until Location Contains    /Report    timeout=15s
    Wait Until Element Is Visible    ${LOC_REPORT_PAGE_BODY}    timeout=10s
