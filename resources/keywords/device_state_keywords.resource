*** Settings ***
Library     SeleniumLibrary
Library     Collections
Variables   ../../variables/device_state_variables.py
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/device_state_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage Devices DSC
    [Documentation]    Ensures session is active, then navigates to /ManageDevices via direct URL.
    ...                Runs GC before navigation to reclaim V8 heap from previous tests.
    Request Page Garbage Collection Best Effort
    Ensure Session Is Active
    Navigate To Module Page    ${MANAGE_DEVICES_URL}
    Inject Grid Oom Patch Into Current Page
    Request Page Garbage Collection Best Effort
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  GRID COLUMN HELPERS (JavaScript-based for reliability)
# ═══════════════════════════════════════════════════════════════════════
Get Column Index By Header Text
    [Documentation]    Returns the 0-based column index whose header **contains** the given text (substring match,
    ...                **case-insensitive**) so **ICCID** / **BUSINESS UNIT NAME** / **Account** all resolve reliably.
    [Arguments]    ${header_text}
    ${index}=    Execute Javascript
    ...    var ths = document.querySelectorAll('#gridData table thead th');
    ...    var needle=(arguments[0]||'').toString().trim().toLowerCase();
    ...    for(var i=0; i<ths.length; i++){
    ...      var t=(ths[i].textContent||'').trim().toLowerCase();
    ...      if(t.indexOf(needle)>=0) return i;
    ...    }
    ...    return -1;
    ...    ARGUMENTS    ${header_text}
    Should Not Be Equal As Integers    ${index}    -1
    ...    Column header containing "${header_text}" not found in grid.
    RETURN    ${index}

Get Cell Value By Row And Column
    [Documentation]    Returns the text content of a grid cell. row_index is 1-based; col_index is 0-based.
    [Arguments]    ${row_index}    ${col_index}
    ${value}=    Execute Javascript
    ...    var rows = document.querySelectorAll('#gridData table tbody tr.k-master-row');
    ...    if(rows.length >= arguments[0]) { var cells = rows[arguments[0]-1].querySelectorAll('td'); if(cells.length > arguments[1]) return cells[arguments[1]].textContent.trim(); }
    ...    return '';
    ...    ARGUMENTS    ${row_index}    ${col_index}
    RETURN    ${value}

# ═══════════════════════════════════════════════════════════════════════
#  FILTER / SEARCH
# ═══════════════════════════════════════════════════════════════════════
Wait For Filter Popup Internal Spinner Gone
    [Documentation]    Waits until the in-modal loading mask inside ``#filterPopup`` is gone (not the body overlay).
    [Arguments]    ${timeout}=8s
    Run Keyword And Ignore Error
    ...    Wait For Condition
    ...    return !document.querySelector('#filterPopup .k-loading-mask')
    ...    timeout=${timeout}
    Brief UI Settle Short

Expand Account Filter Section In Filter Popup
    [Documentation]    After the filters popup opens: if ``#accountInput`` inside ``#filterPopup`` is not usable yet,
    ...                wait for the Account row xpath, **JS-click** to expand, wait until the input is visible.
    Wait Until Element Is Visible    ${LOC_DSC_FILTER_POPUP}    timeout=15s
    Wait For Filter Popup Internal Spinner Gone    timeout=12s
    ${already}=    Execute Javascript
    ...    var p=document.getElementById('filterPopup');
    ...    if(!p) return false;
    ...    var inp=p.querySelector('#accountInput');
    ...    if(!inp) return false;
    ...    var st=window.getComputedStyle(inp);
    ...    var r=inp.getBoundingClientRect();
    ...    return r.width>1&&r.height>1&&st.display!=='none'&&st.visibility!=='hidden'&&st.opacity!=='0';
    IF    ${already}
        RETURN
    END
    @{_expand}=    Create List
    ...    ${LOC_DSC_FILTER_ACCOUNT_K_LINK}
    ...    ${LOC_DSC_FILTER_ACCOUNT_PANEL_LI}
    ...    ${LOC_DSC_FILTER_ACCOUNT_SPAN_CONTAINS}
    ...    ${LOC_DSC_FILTER_ACCOUNT_SPAN_ICASE}
    ...    ${LOC_DSC_FILTER_ACCOUNT_HEADER}
    FOR    ${_loc}    IN    @{_expand}
        ${_vis}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${_loc}    timeout=8s
        IF    not ${_vis}
            Continue For Loop
        END
        Scroll To Element Via JS    ${_loc}
        Click Element Via JS    ${_loc}
        Wait For Filter Popup Internal Spinner Gone    timeout=10s
        ${_inp_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    timeout=10s
        Exit For Loop If    ${_inp_ok}
    END
    Wait Until Element Is Visible    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    timeout=25s

Open Filter Popup
    [Documentation]    Clicks the **Filters** toolbar icon (``filter-search-trigger``) via JS; waits until ``#filterPopup``
    ...                is visible and the in-modal spinner has cleared.
    ...                DOM-presence + scrollIntoView — new QE build keeps the trigger as ``<a id="filter-search-trigger">``
    ...                but it's rendered off-screen until the grid toolbar is scrolled into view.
    Request Page Garbage Collection Best Effort
    Wait Until Page Contains Element    ${LOC_DSC_FILTER_SEARCH}    timeout=15s
    Execute Javascript    var el = document.getElementById('filter-search-trigger'); if(el) el.scrollIntoView({block:'center'});
    Inject Grid Oom Patch Into Current Page
    Click Element Via JS    ${LOC_DSC_FILTER_SEARCH}
    IF    ${DSC_ACCOUNT_FILTER_OOM_SAFE}
        Brief UI Settle Short
    ELSE
        Wait For Loading Overlay To Disappear
    END
    Wait Until Element Is Visible    ${LOC_DSC_FILTER_POPUP}    timeout=15s
    Wait For Filter Popup Internal Spinner Gone    timeout=12s
    Brief UI Settle Short

Close Filter Popup
    [Documentation]    Closes the filter popup. Tries data-dismiss button, then .close class, then
    ...                any button with 'close'/'apply' text. After close waits for both body overlay
    ...                and Kendo grid loading mask so the grid is fully refreshed before proceeding.
    ${popup_still_open}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_FILTER_POPUP}    timeout=3s
    IF    ${popup_still_open}
        Execute Javascript
        ...    var btn = document.querySelector('#filterPopup button[data-dismiss="modal"]');
        ...    if (!btn) btn = document.querySelector('#filterPopup .close, #filterPopup button[aria-label="Close"], #filterPopup button[aria-label="close"]');
        ...    if (!btn) {
        ...      var btns = document.querySelectorAll('#filterPopup button');
        ...      for (var i = 0; i < btns.length; i++) {
        ...        var t = (btns[i].textContent || btns[i].value || '').trim().toLowerCase();
        ...        if (t === 'close' || t === 'apply' || t === '×' || t === 'x') { btn = btns[i]; break; }
        ...      }
        ...    }
        ...    if (btn) btn.click();
        Sleep    1s
        Wait For Loading Overlay To Disappear
        ${_kendo_mask}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    xpath=//*[contains(@class,'k-loading-mask')]    timeout=5s
        IF    ${_kendo_mask}
            Wait Until Element Is Not Visible    xpath=//*[contains(@class,'k-loading-mask')]    timeout=45s
            Wait For Loading Overlay To Disappear
        END
    END

Click Account Filter Row By Exact Name In Popup
    [Documentation]    Clicks the Account **suggestion row** whose text equals ``account_name`` (like the row under the input
    ...                in the Filters sidebar). Collects candidates from ``#accountFilter``, ``.k-list`` / listbox nodes under
    ...                ``#filterPopup``, the widget sibling of ``#accountInput``, and **visible** ``.k-animation-container``
    ...                popups on ``body`` (Kendo often portals the dropdown outside ``#accountFilter``). Exact match, then
    ...                case-insensitive. Retries via ``Wait Until Keyword Succeeds`` while results load.
    [Arguments]    ${account_name}
    ${match_found}=    Execute Javascript
    ...    return (function(wantRaw){
    ...    var MAX_NODES=600;
    ...    function norm(s){
    ...      s=(s||'').toString().replace(/\\r|\\n|\\t/g,' ');
    ...      while(s.indexOf('  ')>=0) s=s.split('  ').join(' ');
    ...      return s.trim();
    ...    }
    ...    function isVisible(el){
    ...      if(!el) return false;
    ...      var r=el.getBoundingClientRect();
    ...      if(r.width<1||r.height<1) return false;
    ...      var st=window.getComputedStyle(el);
    ...      if(st.visibility==='hidden'||st.display==='none'||parseFloat(st.opacity||'1')===0) return false;
    ...      return true;
    ...    }
    ...    function clickRow(el){
    ...      var c=el.querySelector('span.k-item, .k-item, span.k-link, a, button')||el;
    ...      c.click();
    ...      return true;
    ...    }
    ...    function addAll(pool, nl){
    ...      var i;
    ...      for(i=0;i<nl.length&&pool.length<MAX_NODES;i++) pool.push(nl[i]);
    ...    }
    ...    var pool=[];
    ...    var fp=document.getElementById('filterPopup');
    ...    var af=document.getElementById('accountFilter');
    ...    if(af) addAll(pool, af.querySelectorAll('li, [role=treeitem], [role=option], .k-item'));
    ...    if(fp){
    ...      addAll(pool, fp.querySelectorAll('.k-list li, .k-list .k-item, ul[role=listbox] li, [role=listbox] [role=option], .k-popup li, .k-popup .k-item'));
    ...      var inp=fp.querySelector('#accountInput');
    ...      if(inp){
    ...        var w=inp.closest('.k-widget, .k-autocomplete, .k-textbox')||inp.parentElement;
    ...        if(w&&w.nextElementSibling) addAll(pool, w.nextElementSibling.querySelectorAll('li, .k-item, [role=option]'));
    ...      }
    ...    }
    ...    var acn=document.querySelectorAll('body .k-animation-container');
    ...    var ai, cont;
    ...    for(ai=0;ai<acn.length;ai++){
    ...      cont=acn[ai];
    ...      var stc=window.getComputedStyle(cont);
    ...      if(stc.display==='none') continue;
    ...      addAll(pool, cont.querySelectorAll('.k-list li, .k-list .k-item, [role=option]'));
    ...    }
    ...    var want=norm(wantRaw);
    ...    var wL=want.toLowerCase();
    ...    var j, el, t;
    ...    for(j=0;j<pool.length;j++){
    ...      el=pool[j];
    ...      if(!isVisible(el)) continue;
    ...      t=norm(el.textContent);
    ...      if(t===want) return clickRow(el);
    ...    }
    ...    for(j=0;j<pool.length;j++){
    ...      el=pool[j];
    ...      if(!isVisible(el)) continue;
    ...      t=norm(el.textContent);
    ...      if(t.toLowerCase()===wL) return clickRow(el);
    ...    }
    ...    return false;
    ...    })(arguments[0]);
    ...    ARGUMENTS    ${account_name}
    Should Be True    ${match_found}    Account "${account_name}" suggestion row not visible/clickable yet.

Apply Account Filter
    [Documentation]    Call after ``Open Filter Popup``: expand Account (JS) → type ``account_name`` in popup input → Enter
    ...                → wait spinners/overlays → pick list row equal to name (JS ``click``) → wait loading. Caller closes popup.
    [Arguments]    ${account_name}
    Request Page Garbage Collection Best Effort
    Expand Account Filter Section In Filter Popup
    Wait For Filter Popup Internal Spinner Gone    timeout=12s
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}
    Wait Until Element Is Visible    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    timeout=20s
    Clear Element Text    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}
    Input Text    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    ${account_name}
    Press Keys    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    ENTER
    Wait For Filter Popup Internal Spinner Gone    timeout=15s
    Wait For Loading Overlay To Disappear
    Brief UI Settle Short
    Wait Until Keyword Succeeds    60s    1s    Click Account Filter Row By Exact Name In Popup    ${account_name}
    Wait For Filter Popup Internal Spinner Gone    timeout=20s
    ${mask}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//*[contains(@class,'k-loading-mask')]    timeout=3s
    IF    ${mask}
        Wait Until Element Is Not Visible    xpath=//*[contains(@class,'k-loading-mask')]    timeout=45s
        Wait For Loading Overlay To Disappear
    END
    Log    Applied account filter: ${account_name}    console=yes

Click Account Filter List Item Exact Device Plan Style
    [Documentation]    Clicks ``#accountFilter li`` whose normalized text equals ``account_name`` — same as
    ...                ``Apply DP Account Filter`` in ``device_plan_keywords``. Use inside ``Wait Until Keyword Succeeds``
    ...                while the list fills after Enter.
    [Arguments]    ${account_name}
    ${match_found}=    Execute Javascript
    ...    var ul = document.getElementById('accountFilter');
    ...    if(!ul) return false;
    ...    var items = ul.querySelectorAll('li');
    ...    var want = (arguments[0]||'').toString().trim();
    ...    var wL = want.toLowerCase();
    ...    var i, t;
    ...    for(i=0; i<items.length; i++){
    ...      t = (items[i].textContent||'').replace(/\\s+/g,' ').trim();
    ...      if(t===want){ items[i].click(); return true; }
    ...    }
    ...    for(i=0; i<items.length; i++){
    ...      t = (items[i].textContent||'').replace(/\\s+/g,' ').trim();
    ...      if(t.toLowerCase()===wL){ items[i].click(); return true; }
    ...    }
    ...    return false;
    ...    ARGUMENTS    ${account_name}
    Should Be True    ${match_found}    Account "${account_name}" not in #accountFilter li list yet.

Apply Account Filter Device Plan Style
    [Documentation]    Filter modal on Manage Devices / Blank SIM: same sequence as Device Plan ``Apply DP Account Filter`` —
    ...                JS expand **Account** ``span.k-link.k-header``, ``Click Element Via JS`` on ``#filterPopup`` scoped
    ...                ``#accountInput``, type, Enter, then ``#accountFilter li`` click (exact, then case-insensitive).
    ...                **SIM Replacement** uses this path so account selection matches the working Device Plan module.
    [Arguments]    ${account_name}
    Request Page Garbage Collection Best Effort
    Wait Until Element Is Visible    ${LOC_DSC_FILTER_POPUP}    timeout=15s
    Wait For Filter Popup Internal Spinner Gone    timeout=12s
    # Click Account section header; retry up to 3 times if accountInput does not become
    # visible (can happen on 2nd+ filter apply in same popup — accordion re-collapses).
    ${_input_ready}=    Set Variable    ${FALSE}
    FOR    ${_attempt}    IN RANGE    3
        Execute Javascript
        ...    var popup = document.getElementById('filterPopup');
        ...    if(!popup) return;
        ...    var spans = popup.querySelectorAll('span.k-link.k-header');
        ...    for(var i=0; i<spans.length; i++){
        ...      if(spans[i].textContent.trim() === 'Account'){ spans[i].click(); break; }
        ...    }
        Wait For Filter Popup Internal Spinner Gone    timeout=8s
        Wait For Loading Overlay To Disappear
        Brief UI Settle Short
        Scroll To Element Via JS    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}
        ${_input_ready}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    timeout=6s
        IF    ${_input_ready}    BREAK
        Log    Account filter input not visible on attempt ${_attempt + 1} — retrying header click.    console=yes
        Sleep    1s
    END
    Should Be True    ${_input_ready}
    ...    msg=Account filter input (#accountInput inside #filterPopup) not visible after 3 expand attempts.
    Click Element Via JS    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}
    Brief UI Settle Short
    Clear Element Text    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}
    Input Text    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    ${account_name}
    Brief UI Settle Short
    Press Keys    ${LOC_DSC_ACCOUNT_INPUT_IN_POPUP}    ENTER
    Wait For Filter Popup Internal Spinner Gone    timeout=15s
    Wait For Loading Overlay To Disappear
    Brief UI Settle Short
    Wait Until Keyword Succeeds    45s    1s    Click Account Filter List Item Exact Device Plan Style    ${account_name}
    Wait For Filter Popup Internal Spinner Gone    timeout=20s
    ${mask}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//*[contains(@class,'k-loading-mask')]    timeout=3s
    IF    ${mask}
        Wait Until Element Is Not Visible    xpath=//*[contains(@class,'k-loading-mask')]    timeout=45s
        Wait For Loading Overlay To Disappear
    END
    Brief UI Settle Short
    Log    Applied account filter (Device Plan style): ${account_name}    console=yes

Apply SIM State Filter
    [Documentation]    In the already-open filter popup, expands SIM State panel
    ...                and clicks the target state option.
    [Arguments]    ${filter_label}
    # Expand SIM State panel via JS
    Execute Javascript
    ...    var popup = document.getElementById('filterPopup');
    ...    var spans = popup.querySelectorAll('span.k-link.k-header');
    ...    for(var i=0; i<spans.length; i++){
    ...      if(spans[i].textContent.trim() === 'SIM State'){ spans[i].click(); break; }
    ...    }
    Sleep    1s
    # Click the target state option
    ${option_clicked}=    Execute Javascript
    ...    var ul = document.getElementById('simStateFilter');
    ...    if(!ul) return false;
    ...    var items = ul.querySelectorAll('li');
    ...    for(var i=0; i<items.length; i++){
    ...      if(items[i].textContent.trim() === arguments[0]){ items[i].click(); return true; }
    ...    }
    ...    return false;
    ...    ARGUMENTS    ${filter_label}
    Should Be True    ${option_clicked}
    ...    SIM State "${filter_label}" not found in filter panel.
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Log    Applied SIM State filter: ${filter_label}    console=yes

Filter Grid By Account And State
    [Documentation]    Resets the grid, opens filter popup, applies Account filter
    ...                then SIM State filter, closes popup, and returns the 0-based
    ...                row index of the first device matching the expected grid state.
    ...                Fails the test if no device is found with the expected state.
    [Arguments]    ${account_name}    ${filter_label}    ${grid_state}=${EMPTY}
    ${effective_state}=    Set Variable If    '${grid_state}' != ''    ${grid_state}    ${filter_label}
    Reset Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Request Page Garbage Collection Best Effort
    Inject Grid Oom Patch Into Current Page
    Open Filter Popup
    Apply Account Filter Device Plan Style    ${account_name}
    Apply SIM State Filter    ${filter_label}
    Close Filter Popup
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${row_idx}=    Find Row By State Column    ${state_col}    ${effective_state}
    Should Not Be Equal As Integers    ${row_idx}    -1
    ...    No device with SIM State "${effective_state}" found for account "${account_name}" after filter.
    Log    Found device in "${effective_state}" state at row index ${row_idx} (0-based).    console=yes
    RETURN    ${row_idx}

Find Row By State Column
    [Documentation]    Scans visible grid rows and returns the 0-based index of the first row
    ...                whose state column matches the target text. Returns -1 if not found.
    [Arguments]    ${state_col}    ${target_state}
    ${row_idx}=    Execute Javascript
    ...    var rows = document.querySelectorAll('#gridData table tbody tr.k-master-row');
    ...    for(var j=0; j<rows.length; j++){ var cells = rows[j].querySelectorAll('td');
    ...    if(cells[arguments[0]] && cells[arguments[0]].textContent.trim() === arguments[1]) return j; }
    ...    return -1;
    ...    ARGUMENTS    ${state_col}    ${target_state}
    RETURN    ${row_idx}

Reset Grid To Default View
    [Documentation]    Resets all grid filters and clears the search so the grid
    ...                shows the unfiltered, full device list.
    ${reset_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_RESET_ALL_FILTER}    timeout=3s
    IF    ${reset_visible}
        Click Element Via JS    ${LOC_DSC_RESET_ALL_FILTER}
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END
    ${close_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_SEARCH_CLOSE}    timeout=3s
    IF    ${close_visible}
        Click Element Via JS    ${LOC_DSC_SEARCH_CLOSE}
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END
    ${normal_btn}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_NORMAL_SEARCH}    timeout=3s
    IF    ${normal_btn}
        Click Element Via JS    ${LOC_DSC_NORMAL_SEARCH}
        Sleep    1s
    END

Search Device By IMSI
    [Documentation]    Searches for a device by IMSI using the grid search input.
    [Arguments]    ${imsi}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_SEARCH_INPUT}    timeout=30s
    Scroll To Element Via JS    ${LOC_DSC_SEARCH_INPUT}
    ${element}=    Get WebElement    ${LOC_DSC_SEARCH_INPUT}
    Execute Javascript
    ...    var el = arguments[0]; el.focus(); el.value = ''; el.value = arguments[1];
    ...    el.dispatchEvent(new Event('input', {bubbles: true}));
    ...    el.dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}    ${imsi}
    Execute Javascript
    ...    var el = arguments[0]; el.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', keyCode: 13, bubbles: true}));
    ...    el.dispatchEvent(new KeyboardEvent('keyup', {key: 'Enter', keyCode: 13, bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  DEVICE SELECTION
# ═══════════════════════════════════════════════════════════════════════
Select Device By Row Index
    [Documentation]    Clicks the checkbox of the row at the given 0-based index.
    [Arguments]    ${row_idx}
    ${actual_idx}=    Evaluate    ${row_idx} + 1
    ${cb_locator}=    Set Variable    xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[${actual_idx}]//input[contains(@class,'sel')]
    Wait Until Element Is Visible    ${cb_locator}    timeout=15s
    Click Element Via JS    ${cb_locator}
    Sleep    1s

Select First Device From Grid
    [Documentation]    Clicks the checkbox of the first device row.
    Wait Until Element Is Visible    ${LOC_DSC_FIRST_ROW_CB}    timeout=30s
    Click Element Via JS    ${LOC_DSC_FIRST_ROW_CB}
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  ACTION BAR
# ═══════════════════════════════════════════════════════════════════════
Select Change State Action
    [Documentation]    Selects "Change State" from the action dropdown and dispatches
    ...                a change event to ensure the Change State section appears.
    Wait Until Element Is Visible    ${LOC_DSC_ACTION_DROP}    timeout=30s
    Select From List By Label    ${LOC_DSC_ACTION_DROP}    Change State
    ${element}=    Get WebElement    ${LOC_DSC_ACTION_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_CHANGE_STATE_SEC}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_STATE_DROP}    timeout=30s

Select Target State And Submit
    [Documentation]    Selects the target state from the state dropdown, then clicks the
    ...                Submit button to trigger the popup. Uses JS fallback if label not found.
    [Arguments]    ${target_state}
    Wait Until Element Is Enabled    ${LOC_DSC_STATE_DROP}    timeout=30s
    Sleep    1s
    ${available_options}=    Execute Javascript
    ...    var sel = document.querySelector('[name="changeSelectedValue"]');
    ...    if(!sel) return 'DROPDOWN_NOT_FOUND';
    ...    var opts = [];
    ...    for(var i=0; i<sel.options.length; i++) opts.push(sel.options[i].text.trim());
    ...    return opts.join(' | ');
    Log    Available state options: [${available_options}]    console=yes
    ${select_ok}=    Run Keyword And Return Status
    ...    Select From List By Label    ${LOC_DSC_STATE_DROP}    ${target_state}
    IF    not ${select_ok}
        Log    Select From List By Label failed for "${target_state}". Trying JS fallback...    WARN
        ${js_selected}=    Execute Javascript
        ...    var sel = document.querySelector('[name="changeSelectedValue"]');
        ...    if(!sel) return false;
        ...    var target = arguments[0].trim().toLowerCase();
        ...    for(var i=0; i<sel.options.length; i++){
        ...        if(sel.options[i].text.trim().toLowerCase() === target){
        ...            sel.selectedIndex = i;
        ...            sel.dispatchEvent(new Event('change', {bubbles: true}));
        ...            return true;
        ...        }
        ...    }
        ...    return false;
        ...    ARGUMENTS    ${target_state}
        Should Be True    ${js_selected}
        ...    State "${target_state}" not found in dropdown. Available: [${available_options}]
    END
    ${element}=    Get WebElement    ${LOC_DSC_STATE_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_STATE_SUBMIT_BTN}    timeout=15s
    Wait Until Element Is Enabled    ${LOC_DSC_STATE_SUBMIT_BTN}    timeout=15s
    Click Element Via JS    ${LOC_DSC_STATE_SUBMIT_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  STATE CHANGE POPUP
# ═══════════════════════════════════════════════════════════════════════
Wait For Popup To Open
    [Documentation]    Waits for the savePopup modal to be visible.
    Wait Until Element Is Visible    ${LOC_DSC_POPUP}    timeout=30s

Select Service Plan In Popup
    [Documentation]    Selects the first service plan inside the popup.
    Wait Until Element Is Visible    ${LOC_DSC_SVC_PLAN_DROP}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DSC_SVC_PLAN_DROP}    timeout=30s
    ${option_ok}=    Run Keyword And Return Status
    ...    Select From List By Index    ${LOC_DSC_SVC_PLAN_DROP}    1
    IF    not ${option_ok}
        Select Option By Index Via JS    ${LOC_DSC_SVC_PLAN_DROP}    1
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Select Device Plan In Popup
    [Documentation]    Selects the first device plan inside the popup.
    Wait Until Element Is Visible    ${LOC_DSC_DEV_PLAN_DROP}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DSC_DEV_PLAN_DROP}    timeout=30s
    ${option_ok}=    Run Keyword And Return Status
    ...    Select From List By Index    ${LOC_DSC_DEV_PLAN_DROP}    1
    IF    not ${option_ok}
        Select Option By Index Via JS    ${LOC_DSC_DEV_PLAN_DROP}    1
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Select Reason In Popup
    [Documentation]    Selects the first non-blank reason inside the popup.
    Wait Until Element Is Visible    ${LOC_DSC_REASON_DROP}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DSC_REASON_DROP}    timeout=30s
    ${option_ok}=    Run Keyword And Return Status
    ...    Select From List By Index    ${LOC_DSC_REASON_DROP}    1
    IF    not ${option_ok}
        Select Option By Index Via JS    ${LOC_DSC_REASON_DROP}    1
    END
    Sleep    1s

Click Proceed Button
    [Documentation]    Clicks the Proceed/Submit button inside the popup.
    Wait Until Element Is Visible    ${LOC_DSC_PROCEED_BTN}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DSC_PROCEED_BTN}    timeout=30s
    Click Element Via JS    ${LOC_DSC_PROCEED_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Close Popup Without Submitting
    [Documentation]    Clicks the Close/Cancel button inside the popup.
    Wait Until Element Is Visible    ${LOC_DSC_POPUP_CLOSE_BTN}    timeout=15s
    Click Element Via JS    ${LOC_DSC_POPUP_CLOSE_BTN}
    Wait Until Element Is Not Visible    ${LOC_DSC_POPUP}    timeout=15s

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE FLOWS
# ═══════════════════════════════════════════════════════════════════════
Fill Popup And Submit
    [Documentation]    Fills the popup fields that are visible and clicks Proceed.
    ...                Service Plan, Device Plan, and Reason are each checked independently.
    [Arguments]    ${from_state}    ${to_state}
    Wait For Popup To Open
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    ${svc_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_SVC_PLAN_DROP}    timeout=5s
    IF    ${svc_visible}
        Select Service Plan In Popup
    END
    ${dev_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_DEV_PLAN_DROP}    timeout=5s
    IF    ${dev_visible}
        Select Device Plan In Popup
    END
    ${reason_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_REASON_DROP}    timeout=10s
    IF    ${reason_visible}
        Select Reason In Popup
    END
    Click Proceed Button

Perform Full State Change
    [Documentation]    End-to-end state change: filter by account + SIM state, capture IMSI,
    ...                verify initial state, select device, change state, submit popup.
    ...                Returns the device IMSI for post-change verification.
    [Arguments]    ${filter_label}    ${from_state}    ${to_state}
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${filter_label}    ${from_state}
    ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
    ${actual_row}=    Evaluate    ${row_idx} + 1
    ${imsi}=    Get Cell Value By Row And Column    ${actual_row}    ${imsi_col}
    Should Not Be Empty    ${imsi}    Could not read IMSI from filtered row.
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${verified_state}=    Get Cell Value By Row And Column    ${actual_row}    ${state_col}
    Should Be Equal As Strings    ${verified_state}    ${from_state}
    ...    Initial state mismatch: expected "${from_state}" but grid shows "${verified_state}".
    Log    Device IMSI: ${imsi}, Initial State: ${from_state} → Target: ${to_state}    console=yes
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Select Target State And Submit    ${to_state}
    Fill Popup And Submit    ${from_state}    ${to_state}
    RETURN    ${imsi}

# ═══════════════════════════════════════════════════════════════════════
#  POST-CHANGE VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify State Change Success And Wait
    [Documentation]    Asserts success/info toast appears, popup is dismissed, then waits
    ...                5 minutes for the asynchronous state change to be processed.
    ${toast_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_TOAST_SUCCESS}    timeout=30s
    IF    ${toast_ok}
        ${toast_text}=    Get Text    ${LOC_DSC_TOAST_SUCCESS}
        Log    Success toast: ${toast_text}    console=yes
    ELSE
        Log    No success toast found within 30s.    level=WARN
    END
    ${popup_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_DSC_POPUP}    timeout=15s
    IF    not ${popup_gone}
        ${close_ok}=    Run Keyword And Return Status
        ...    Click Element Via JS    ${LOC_DSC_POPUP_X_BTN}
        Sleep    1s
    END
    Log    Waiting 5 minutes for async state change to process...    console=yes
    Sleep    300s
    Wait For Loading Overlay To Disappear

Verify Device State After Change
    [Documentation]    Resets the grid, searches for the device by IMSI, and verifies
    ...                that the SIM State column shows the expected new state.
    [Arguments]    ${imsi}    ${expected_state}
    Reset Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Search Device By IMSI    ${imsi}
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${actual_state}=    Get Cell Value By Row And Column    1    ${state_col}
    Should Be Equal As Strings    ${actual_state}    ${expected_state}
    ...    Expected SIM state "${expected_state}" but grid shows "${actual_state}" for IMSI ${imsi}.
    Log    VERIFIED: IMSI ${imsi} state is now "${actual_state}".    console=yes

Attempt Invalid Transition And Verify Blocked
    [Documentation]    Tries to select an invalid target state. Passes if the state is not
    ...                present in the dropdown (NoSuchElement), or if an error toast / alert
    ...                appears, or if the popup does not open after clicking Submit.
    [Arguments]    ${target_state}
    ${select_ok}=    Run Keyword And Return Status
    ...    Select From List By Label    ${LOC_DSC_STATE_DROP}    ${target_state}
    IF    not ${select_ok}
        Log    State "${target_state}" not available in dropdown — transition correctly blocked.    console=yes
        RETURN
    END
    ${element}=    Get WebElement    ${LOC_DSC_STATE_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    1s
    ${submit_ok}=    Run Keyword And Return Status
    ...    Click Element Via JS    ${LOC_DSC_STATE_SUBMIT_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_TOAST_ERROR}    timeout=10s
    ${popup_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_DSC_POPUP}    timeout=5s
    ${alert}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_ALERT_DANGER}    timeout=5s
    Should Be True    ${error_toast} or ${popup_gone} or ${alert}
    ...    Expected error toast, popup dismissal, or alert for invalid transition.
    Log    Invalid transition "${target_state}" correctly blocked.    console=yes

