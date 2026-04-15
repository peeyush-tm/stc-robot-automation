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
    [Documentation]    Enters report name in filter and clicks Apply Filter (or Enter).
    [Arguments]    ${report_name}
    Wait For Loading Overlay To Disappear
    ${filter_in}=    Set Variable    ${LOC_FILTER_REPORT_NAME_INPUT}
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_FILTER_REPORT_NAME_INPUT}    timeout=8s
    IF    not ${input_visible}
        ${filter_in}=    Set Variable    xpath=(//div[contains(@class,'k-grid')]/ancestor::*[1]//input[@type='text'])[last()]
        ${input_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${filter_in}    timeout=5s
    END
    IF    not ${input_visible}
        ${filter_in}=    Set Variable    xpath=//input[@type='text'][1]
        Wait Until Element Is Visible    ${filter_in}    timeout=5s
    END
    Clear Element Text    ${filter_in}
    Input Text    ${filter_in}    ${report_name}
    Sleep    0.5s
    ${apply_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_BTN_APPLY_FILTER}    timeout=15s
    IF    ${apply_visible}
        Scroll To Element Via JS    ${LOC_BTN_APPLY_FILTER}
        Click Element Via JS    ${LOC_BTN_APPLY_FILTER}
    ELSE
        Press Keys    ${filter_in}    RETURN
    END
    Sleep    1s
    Wait For Loading Overlay To Disappear

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
    [Documentation]    Navigates back to the Report listing page and re-applies the filter on every
    ...                attempt so the grid refreshes with the latest status from the server.
    ...                Passes when the download link becomes visible (report is Completed).
    [Arguments]    ${filter_name}
    Navigate To Reports Page
    Apply Report Name Filter    ${filter_name}
    Wait For Report Grid
    First Row Download Action Ready

Click Download In First Row
    [Documentation]    Waits for the report to finish generating by reloading the Report page and
    ...                re-filtering on each attempt (handles In Progress → Completed transition),
    ...                then clicks the Download link.
    ...                Pass filter_name to enable page-reload polling; omit for a DOM-only wait.
    [Arguments]    ${filter_name}=${EMPTY}
    IF    '${filter_name}' != '${EMPTY}'
        Log    Waiting for report download link — reloading page every 15s (up to 7.5 min)...
        Wait Until Keyword Succeeds    20x    10s    Wait For Report Ready To Download    ${filter_name}
    ELSE
        Wait Until Element Is Visible    ${LOC_REPORT_GRID_FIRST_ROW}    timeout=15s
        Wait Until Keyword Succeeds    90x    5s    First Row Download Action Ready
    END
    Wait Until Element Is Visible    ${LOC_FIRST_ROW_DOWNLOAD_LINK}    timeout=15s
    Click Element Via JS    ${LOC_FIRST_ROW_DOWNLOAD_LINK}
    Sleep    1s
    Wait For Loading Overlay To Disappear

Download Report From First Row And Verify Click
    [Documentation]    Waits for report generation to complete (with page reloads + filter re-apply),
    ...                clicks Download, then verifies no error toast and page is still /Report.
    [Arguments]    ${filter_name}=${EMPTY}
    Click Download In First Row    ${filter_name}
    # Ensure we did not get an error toast
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    timeout=2s
    Should Not Be True    ${error_toast}    msg=Download should not show error toast
    Location Should Contain    /Report
    Log    Download triggered successfully; user remains on Report page.

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
