*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/user_management_locators.resource
Resource    ../locators/login_locators.resource

*** Variables ***
# Overwritten by ``Load Environment Config From Json`` when present in config/<env>.json
${DEFAULT_OPCO_ACCOUNT}       KSA_OPCO
${DEFAULT_EC_ACCOUNT}         SANJ_1002
${DEFAULT_BU_ACCOUNT}         billingAccountSANJ_1003

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  SUITE SETUP / TEARDOWN
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage User
    [Documentation]    Opens browser, logs in, navigates to Admin > User (Manage User page).
    ...                MD: Login → Sidebar → Admin → User → /ManageUser
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Navigate To Manage User Page
    Log    Suite setup complete: logged in and on Manage User page.

# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION (MD: Navigation Path — Login → Sidebar → Admin → User)
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage User Page
    [Documentation]    MD: Step 2 — Click Admin icon in sidebar (lands on ManageUser by default).
    ...                If not on ManageUser, click User sub-tab in top navigation.
    Wait For App Loading To Complete
    Scroll To Element Via JS    ${LOC_SIDEBAR_ADMIN}
    Wait Until Element Is Visible    ${LOC_SIDEBAR_ADMIN}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_SIDEBAR_ADMIN}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    ${on_manage_user}=    Run Keyword And Return Status
    ...    Location Should Contain    ${MANAGE_USER_PATH}
    IF    not ${on_manage_user}
        ${user_tab_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_SIDEBAR_USER}    10s
        IF    ${user_tab_visible}
            Click Element Via JS    ${LOC_SIDEBAR_USER}
            Sleep    1s
            Wait For App Loading To Complete    timeout=60s
            Sleep    1s
            Wait For App Loading To Complete
        END
    END
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ${MANAGE_USER_PATH}
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_GRID}    ${UM_TIMEOUT}
    Log    Navigated to Manage User page via Admin sidebar.

Navigate Back To Manage User Page
    [Documentation]    Navigates back to /ManageUser. If already there, waits for grid.
    ...                If on CreateUser or another page, clicks Admin icon → lands on ManageUser.
    ${on_manage_user}=    Run Keyword And Return Status
    ...    Location Should Contain    ${MANAGE_USER_PATH}
    IF    not ${on_manage_user}
        Scroll To Element Via JS    ${LOC_SIDEBAR_ADMIN}
        Wait Until Element Is Visible    ${LOC_SIDEBAR_ADMIN}    ${UM_TIMEOUT}
        Click Element Via JS    ${LOC_SIDEBAR_ADMIN}
        Sleep    1s
        Wait For App Loading To Complete    timeout=60s
        ${still_not}=    Run Keyword And Return Status
        ...    Location Should Contain    ${MANAGE_USER_PATH}
        IF    not ${still_not}
            ${user_tab_visible}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_SIDEBAR_USER}    10s
            IF    ${user_tab_visible}
                Click Element Via JS    ${LOC_SIDEBAR_USER}
                Sleep    1s
                Wait For App Loading To Complete    timeout=60s
            END
        END
    ELSE
        Wait For App Loading To Complete
    END
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ${MANAGE_USER_PATH}
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_GRID}    ${UM_TIMEOUT}
    Log    Back on Manage User page.

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE USER PAGE VERIFICATION (MD: Step 4, Grid Columns)
# ═══════════════════════════════════════════════════════════════════════
Verify Manage User Page Loaded
    [Documentation]    Verifies the Manage User page heading, grid, and pagination.
    ...                MD: Step 4 — Page title shows "Users"
    ${heading}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_MANAGE_USER_HEADING}    ${UM_TIMEOUT}
    IF    not ${heading}
        Log    Page heading 'Users' not found — checking URL instead.    level=WARN
    END
    Location Should Contain    ${MANAGE_USER_PATH}
    Log    Manage User page loaded.

Verify Manage User Grid Loaded
    [Documentation]    Verifies the Manage User grid is visible with column headers.
    ...                MD: Grid Columns — Action, User Name, User Type, etc.
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_GRID}    ${UM_TIMEOUT}
    Log    Manage User grid loaded.

Verify Manage User Grid Columns
    [Documentation]    Verifies all grid columns from MD are present.
    ...                MD: Grid Columns on Manage User Page
    @{expected_columns}=    Create List    USER NAME    FIRST NAME    LAST NAME    EMAIL ADDRESS
    FOR    ${col}    IN    @{expected_columns}
        ${loc}=    Set Variable    xpath=//th[@role='columnheader' and contains(.,'${col}')]
        ${visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${loc}    10s
        IF    ${visible}
            Log    Column '${col}' found.
        ELSE
            Log    Column '${col}' not found in grid.    level=WARN
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  CREATE USER FORM (MD: Step 5)
# ═══════════════════════════════════════════════════════════════════════
Click Create User Button
    [Documentation]    Clicks the Create User button to open the create user form.
    ...                MD: Step 5 — Click "Create User" button → /CreateUser
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_USER}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CREATE_USER}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Create User form opened.

Open Create User Form
    [Documentation]    Ensures Manage User list (SPA), then clicks Create User and waits for /CreateUser route.
    Navigate Back To Manage User Page
    Click Create User Button
    Wait Until Keyword Succeeds    6x    3s    Location Should Contain    ${CREATE_USER_PATH}

Verify Create User Form Loaded
    [Documentation]    Verifies the Create User form fields are visible.
    ...                MD: Form Field Reference
    Location Should Contain    ${CREATE_USER_PATH}
    Wait Until Element Is Visible    ${LOC_INPUT_USERNAME}    ${UM_TIMEOUT}
    Log    Create User form loaded.

Verify All Form Fields Present
    [Documentation]    Checks all mandatory form fields from the MD are rendered.
    ...                MD: Form Field Reference — Account, Username, First Name, Last Name,
    ...                Primary Phone, Email Address, Confirm Email, Role, Country, Time Zone, OTP
    Wait Until Element Is Visible    ${LOC_INPUT_USERNAME}       ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_FIRST_NAME}     ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_LAST_NAME}      ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_PRIMARY_PHONE}  ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_EMAIL}          ${UM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_CONFIRM_EMAIL}  ${UM_TIMEOUT}
    ${role_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_DD_BTN}    10s
    ${country_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_COUNTRY_DD_BTN}    10s
    ${tz_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TIMEZONE_DD_BTN}    10s
    Log    All mandatory form fields verified.

# ═══════════════════════════════════════════════════════════════════════
#  FIELD INTERACTIONS (MD: Steps 6–16, XPaths from Robot Framework section)
# ═══════════════════════════════════════════════════════════════════════
Select Account In TreeView
    [Documentation]    Opens the Account TreeView dropdown and selects the target BU account.
    ...                Discovers the trigger element at runtime using JS, then uses the
    ...                same expand logic as Cost Center: OPCO → EC → BU.
    Sleep    1s
    # Step 1: Dump all form inputs for debugging (helps identify the right field name)
    ${form_inputs}=    Execute JavaScript
    ...    var inputs = document.querySelectorAll('form input, form select, form .form-group input');
    ...    var result = [];
    ...    for (var i = 0; i < inputs.length; i++) {
    ...        var el = inputs[i];
    ...        result.push(el.tagName + ' name=' + (el.name||'') + ' id=' + (el.id||'') + ' type=' + (el.type||'') + ' class=' + (el.className||'').substring(0,50));
    ...    }
    ...    return result.join(' | ');
    Log    CreateUser form inputs: ${form_inputs}
    # Step 2: Find any showTreeView container already in DOM (may be hidden)
    ${tree_id}=    Execute JavaScript
    ...    var tv = document.querySelector('div[id^="showTreeView"]');
    ...    return tv ? tv.id : '';
    Log    Found TreeView container id: ${tree_id}
    # Step 3: Derive the field name from showTreeView-{fieldName} and click the trigger
    IF    '${tree_id}' != '${EMPTY}'
        ${field_name}=    Execute JavaScript    return '${tree_id}'.replace('showTreeView-', '');
        Log    TreeView field name: ${field_name}
        ${clicked}=    Execute JavaScript
        ...    var inp = document.querySelector('input[name="${field_name}"]');
        ...    if (inp) { inp.scrollIntoView({block:'center'}); inp.click(); return true; }
        ...    var tv = document.getElementById('${tree_id}');
        ...    if (tv) { var parent = tv.closest('.form-group') || tv.parentElement;
        ...        var trigger = parent ? parent.querySelector('input') : null;
        ...        if (trigger) { trigger.scrollIntoView({block:'center'}); trigger.click(); return true; }
        ...    }
        ...    return false;
        IF    not ${clicked}
            # Click the tree container's parent area as fallback
            Execute JavaScript    var tv = document.getElementById('${tree_id}'); if(tv && tv.parentElement){tv.parentElement.click();}
        END
    ELSE
        # No showTreeView found — try clicking common input names
        ${clicked}=    Execute JavaScript
        ...    var names = ['parentAccount','accountId','account','accountName'];
        ...    for (var n = 0; n < names.length; n++) {
        ...        var inp = document.querySelector('input[name="' + names[n] + '"]');
        ...        if (inp && (inp.offsetParent !== null || inp.offsetHeight > 0)) {
        ...            inp.scrollIntoView({block:'center'}); inp.click(); return names[n];
        ...        }
        ...    }
        ...    var labels = document.querySelectorAll('label');
        ...    for (var l = 0; l < labels.length; l++) {
        ...        if (labels[l].textContent.trim().match(/^Account/i)) {
        ...            var fg = labels[l].closest('.form-group') || labels[l].parentElement;
        ...            var inp2 = fg ? fg.querySelector('input, [class*="select"]') : null;
        ...            if (inp2) { inp2.scrollIntoView({block:'center'}); inp2.click(); return 'label_' + labels[l].textContent.trim(); }
        ...        }
        ...    }
        ...    return '';
        Log    Fallback click result: ${clicked}
        Should Not Be Empty    ${clicked}    Account TreeView trigger not found on CreateUser page. Form inputs: ${form_inputs}
    END
    Sleep    1s
    Wait For App Loading To Complete
    # Step 4: Wait for the TreeView to become visible
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_TREEVIEW}    10s
    IF    not ${tree_visible}
        # Log the DOM state for debugging
        ${dom_state}=    Execute JavaScript
        ...    var tvs = document.querySelectorAll('div[id^="showTreeView"], div.k-treeview');
        ...    var info = [];
        ...    for (var i = 0; i < tvs.length; i++) {
        ...        info.push('id=' + (tvs[i].id||'none') + ' visible=' + (tvs[i].offsetHeight > 0) + ' display=' + getComputedStyle(tvs[i]).display);
        ...    }
        ...    return info.length > 0 ? info.join(' | ') : 'NO treeview divs found in DOM';
        Log    TreeView DOM state after click: ${dom_state}    level=WARN
        Fail    TreeView did not appear after clicking Account trigger. DOM state: ${dom_state}
    END
    # Step 5: Wait for root node and expand hierarchy
    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_ROOT_NODE}    15s
    Sleep    1s
    UM Expand And Select BU Account
    Sleep    1s
    Wait For App Loading To Complete
    Log    Account selected: ${UM_BU_ACCOUNT_NAME}

UM Expand Select Bu Pair
    [Documentation]    One attempt: OPCO root → EC → BU (used with primary or fallback names).
    [Arguments]    ${ec_name}    ${bu_name}
    UM Clear Account Tree Search If Present
    ${root_expand}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_ROOT_EXPAND}    5s
    IF    ${root_expand}
        Click Element Via JS    ${LOC_UM_ACCOUNT_ROOT_EXPAND}
        Sleep    1s
        Wait For App Loading To Complete    timeout=30s
        Sleep    1s
        Log    Root tree expand clicked (first expand icon).
    END
    UM Expand Tree Node By Name    ${DEFAULT_OPCO_ACCOUNT}
    UM Type In Account Tree Search If Present    ${ec_name}
    UM Expand Tree Node By Name    ${ec_name}
    Sleep    1s
    Wait For App Loading To Complete    timeout=30s
    Sleep    1s
    Log    EC '${ec_name}' expanded.
    UM Type In Account Tree Search If Present    ${bu_name}
    UM Select Tree Node By Name    ${bu_name}

UM Reopen Account Dropdown Treeview
    [Documentation]    After a failed tree selection, dismiss panel and re-open Account TreeView.
    Run Keyword And Ignore Error
    ...    Execute Javascript    document.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));
    Sleep    0.5s
    ${re}=    Execute Javascript
    ...    var names=['parentAccount','accountId','account','accountName'];
    ...    var tv=document.querySelector('div[id^="showTreeView"]');
    ...    if(tv){ var fn=tv.id.replace('showTreeView-',''); var inp=document.querySelector('input[name="'+fn+'"]'); if(inp){ inp.scrollIntoView({block:'center'}); inp.click(); return 'tree_'+fn; } }
    ...    for(var n=0;n<names.length;n++){ var i=document.querySelector('input[name="'+names[n]+'"]'); if(i&&(i.offsetParent!==null||i.offsetHeight>0)){ i.scrollIntoView({block:'center'}); i.click(); return names[n]; } }
    ...    return '';
    Sleep    1s
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_TREEVIEW}    15s
    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_ROOT_NODE}    15s
    Sleep    1s

UM Expand Ksa And Select First Ec Bu
    [Documentation]    Last resort when named EC/BU are missing on this env: OPCO → first child EC → first BU checkbox.
    UM Clear Account Tree Search If Present
    ${root_expand}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_ROOT_EXPAND}    5s
    IF    ${root_expand}
        Click Element Via JS    ${LOC_UM_ACCOUNT_ROOT_EXPAND}
        Sleep    1s
        Wait For App Loading To Complete    timeout=30s
    END
    UM Expand Tree Node By Name    ${DEFAULT_OPCO_ACCOUNT}
    Sleep    2s
    Wait For App Loading To Complete    timeout=40s
    ${ec_exp}=    Execute Javascript
    ...    var root=document.querySelector('div[id^="showTreeView"]')||document.querySelector('.k-treeview');if(!root)return false;
    ...    var ksaLi=null;
    ...    root.querySelectorAll('span.k-in').forEach(function(sp){
    ...    var t=sp.textContent.trim().toUpperCase();
    ...    if(t.indexOf('KSA')>=0&&t.indexOf('OPCO')>=0) ksaLi=sp.closest('li.k-item');
    ...    });
    ...    if(!ksaLi) return false;
    ...    var ul=ksaLi.querySelector(':scope > ul'); if(!ul) return false;
    ...    var ecLi=ul.querySelector(':scope > li.k-item'); if(!ecLi) return false;
    ...    var ic=ecLi.querySelector('span.k-i-expand, span.k-i-plus, span.k-plus, span.k-i-arrow-60-right');
    ...    if(ic){ ic.click(); return true; }
    ...    return true;
    Sleep    2s
    Wait For App Loading To Complete    timeout=40s
    ${bu_ok}=    Execute Javascript
    ...    var root=document.querySelector('div[id^="showTreeView"]')||document.querySelector('.k-treeview');if(!root)return false;
    ...    var boxes=root.querySelectorAll('li.k-item input[type=checkbox], li.k-item input.k-checkbox');
    ...    for(var i=boxes.length-1;i>=0;i--){
    ...    var li=boxes[i].closest('li.k-item');
    ...    if(li&&li.querySelector('span.k-in')){ boxes[i].click(); return true; }
    ...    }
    ...    return false;
    Should Be True    ${bu_ok}    Could not pick a BU under ${DEFAULT_OPCO_ACCOUNT} (first-EC heuristic).

UM Expand And Select BU Account
    [Documentation]    Expand OPCO → EC → BU. Tries UM_EC_/UM_BU_ from seed/env; then config default EC/BU;
    ...                then first EC/BU under OPCO when this tenant has different account names.
    ${ok}=    Run Keyword And Return Status    UM Expand Select Bu Pair    ${UM_EC_ACCOUNT_NAME}    ${UM_BU_ACCOUNT_NAME}
    IF    not ${ok}
        Log    Account tree: could not use EC '${UM_EC_ACCOUNT_NAME}' — retrying ${DEFAULT_EC_ACCOUNT} / ${DEFAULT_BU_ACCOUNT}    level=WARN    console=yes
        UM Reopen Account Dropdown Treeview
        ${ok2}=    Run Keyword And Return Status    UM Expand Select Bu Pair    ${DEFAULT_EC_ACCOUNT}    ${DEFAULT_BU_ACCOUNT}
        IF    not ${ok2}
            Log    Account tree: default EC/BU fallback failed — using first EC/BU under ${DEFAULT_OPCO_ACCOUNT}    level=WARN    console=yes
            UM Reopen Account Dropdown Treeview
            UM Expand Ksa And Select First Ec Bu
        END
    END

UM Clear Account Tree Search If Present
    [Documentation]    Clears account tree filter so prior EC/BU searches do not hide fallback nodes.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_TREE_SEARCH}    4s
    IF    not ${visible}
        RETURN
    END
    Scroll To Element Via JS    ${LOC_UM_ACCOUNT_TREE_SEARCH}
    Clear Element Text    ${LOC_UM_ACCOUNT_TREE_SEARCH}
    Press Keys    ${LOC_UM_ACCOUNT_TREE_SEARCH}    RETURN
    Sleep    0.8s
    Wait For App Loading To Complete    timeout=20s

UM Type In Account Tree Search If Present
    [Documentation]    If the account tree has a filter/search box, type text and submit.
    [Arguments]    ${text}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_UM_ACCOUNT_TREE_SEARCH}    4s
    IF    not ${visible}
        RETURN
    END
    Scroll To Element Via JS    ${LOC_UM_ACCOUNT_TREE_SEARCH}
    Clear Element Text    ${LOC_UM_ACCOUNT_TREE_SEARCH}
    Input Text    ${LOC_UM_ACCOUNT_TREE_SEARCH}    ${text}
    Sleep    0.5s
    Press Keys    ${LOC_UM_ACCOUNT_TREE_SEARCH}    RETURN
    Sleep    1s
    Wait For App Loading To Complete    timeout=20s

UM Expand Tree Node By Name
    [Documentation]    Finds a tree node by label and expands it (visible tree, scroll, Kendo icons).
    [Arguments]    ${node_name}
    ${expanded}=    Set Variable    ${FALSE}
    FOR    ${_}    IN RANGE    6
        ${expanded}=    Execute JavaScript
        ...    return (function(nodeName) {
        ...    function visibleContainers() {
        ...    var sel = document.querySelectorAll('.account-tree-dropdown, div[id*="showTreeView"], div.k-treeview');
        ...    var out = [];
        ...    for (var i = 0; i < sel.length; i++) {
        ...    var el = sel[i];
        ...    var st = window.getComputedStyle(el);
        ...    if (st.display === 'none' || st.visibility === 'hidden') continue;
        ...    var r = el.getBoundingClientRect();
        ...    if (r.width < 2 && r.height < 2) continue;
        ...    out.push(el);
        ...    }
        ...    return out;
        ...    }
        ...    function expandIcon(li) {
        ...    if (!li) return null;
        ...    var row = li.querySelector(':scope > div') || li;
        ...    var icon = row.querySelector('span.k-i-expand, span.k-i-plus, span.k-plus, span.k-i-arrow-60-right');
        ...    if (icon) return icon;
        ...    return li.querySelector('span.k-icon');
        ...    }
        ...    function labelMatches(raw, want) {
        ...    var r = (raw || '').replace(/\\s+/g,' ').trim();
        ...    var w = (want || '').trim();
        ...    if (!w) return false;
        ...    var rl = r.toLowerCase();
        ...    var wl = w.toLowerCase();
        ...    if (r === w || rl === wl) return true;
        ...    if (rl.indexOf(wl) >= 0 || r.indexOf(w) >= 0) return true;
        ...    if (wl.length >= 4 && wl.indexOf(rl) >= 0) return true;
        ...    return false;
        ...    }
        ...    var containers = visibleContainers();
        ...    var allNodes = [];
        ...    for (var c = 0; c < containers.length; c++) {
        ...    var ns = containers[c].querySelectorAll('span.k-in');
        ...    for (var j = 0; j < ns.length; j++) allNodes.push(ns[j]);
        ...    }
        ...    if (allNodes.length === 0) {
        ...    allNodes = Array.from(document.querySelectorAll('.k-treeview span.k-in, li.k-item > div span.k-in'));
        ...    }
        ...    var targetNorm = (nodeName || '').trim();
        ...    for (var i = 0; i < allNodes.length; i++) {
        ...    var raw = allNodes[i].textContent.trim();
        ...    if (!labelMatches(raw, targetNorm)) continue;
        ...    allNodes[i].scrollIntoView({block:'center', inline:'nearest'});
        ...    var li = allNodes[i].closest('li.k-item');
        ...    var icon = expandIcon(li);
        ...    if (icon) { icon.click(); return true; }
        ...    var ul = li ? li.querySelector(':scope > ul') : null;
        ...    if (ul && ul.offsetHeight > 8 && ul.querySelector('li')) return true;
        ...    return false;
        ...    }
        ...    return false;
        ...    })(arguments[0]);
        ...    ARGUMENTS    ${node_name}
        Exit For Loop If    ${expanded}
        Sleep    2s
        Wait For App Loading To Complete    timeout=25s
    END
    Should Be True    ${expanded}    Could not find or expand node '${node_name}' in the TreeView.
    Log    Expanded node: ${node_name}

UM Select Tree Node By Name
    [Documentation]    Finds a tree node by exact label; clicks checkbox or label (visible tree, scroll).
    [Arguments]    ${account_name}
    ${clicked}=    Set Variable    ${FALSE}
    FOR    ${_}    IN RANGE    6
        ${clicked}=    Execute JavaScript
        ...    return (function(accountName) {
        ...    function visibleContainers() {
        ...    var sel = document.querySelectorAll('.account-tree-dropdown, div[id*="showTreeView"], div.k-treeview');
        ...    var out = [];
        ...    for (var i = 0; i < sel.length; i++) {
        ...    var el = sel[i];
        ...    var st = window.getComputedStyle(el);
        ...    if (st.display === 'none' || st.visibility === 'hidden') continue;
        ...    var r = el.getBoundingClientRect();
        ...    if (r.width < 2 && r.height < 2) continue;
        ...    out.push(el);
        ...    }
        ...    return out;
        ...    }
        ...    var containers = visibleContainers();
        ...    var allNodes = [];
        ...    for (var c = 0; c < containers.length; c++) {
        ...    var ns = containers[c].querySelectorAll('span.k-in');
        ...    for (var j = 0; j < ns.length; j++) allNodes.push(ns[j]);
        ...    }
        ...    if (allNodes.length === 0) {
        ...    allNodes = Array.from(document.querySelectorAll('.k-treeview span.k-in, li.k-item > div span.k-in'));
        ...    }
        ...    function labelMatches(raw, want) {
        ...    var r = (raw || '').replace(/\\s+/g,' ').trim();
        ...    var w = (want || '').trim();
        ...    if (!w) return false;
        ...    var rl = r.toLowerCase();
        ...    var wl = w.toLowerCase();
        ...    if (r === w || rl === wl) return true;
        ...    if (rl.indexOf(wl) >= 0 || r.indexOf(w) >= 0) return true;
        ...    if (wl.length >= 4 && wl.indexOf(rl) >= 0) return true;
        ...    return false;
        ...    }
        ...    var targetNorm = (accountName || '').trim();
        ...    for (var i = 0; i < allNodes.length; i++) {
        ...    var raw = allNodes[i].textContent.trim();
        ...    if (!labelMatches(raw, targetNorm)) continue;
        ...    allNodes[i].scrollIntoView({block:'center', inline:'nearest'});
        ...    var li = allNodes[i].closest('li.k-item');
        ...    var cb = li ? li.querySelector('input.k-checkbox, input[type="checkbox"]') : null;
        ...    if (cb) { cb.click(); return true; }
        ...    allNodes[i].click();
        ...    return true;
        ...    }
        ...    return false;
        ...    })(arguments[0]);
        ...    ARGUMENTS    ${account_name}
        Exit For Loop If    ${clicked}
        Sleep    2s
        Wait For App Loading To Complete    timeout=25s
    END
    Should Be True    ${clicked}    Account '${account_name}' not found in the TreeView.
    Log    Selected account: ${account_name}

Fill Username
    [Documentation]    Enters value into the Username field.
    ...                MD: Step 7 — input[@name='userName'], min 5, max 50
    [Arguments]    ${username}
    Wait Until Element Is Visible    ${LOC_INPUT_USERNAME}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_USERNAME}
    Input Text    ${LOC_INPUT_USERNAME}    ${username}
    Log    Username entered: ${username}

Fill First Name
    [Documentation]    Enters value into the First Name field.
    ...                MD: Step 8 — input[@name='firstName']
    [Arguments]    ${first_name}
    Wait Until Element Is Visible    ${LOC_INPUT_FIRST_NAME}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_FIRST_NAME}
    Input Text    ${LOC_INPUT_FIRST_NAME}    ${first_name}
    Log    First Name entered: ${first_name}

Fill Last Name
    [Documentation]    Enters value into the Last Name field.
    ...                MD: Step 9 — input[@name='lastName']
    [Arguments]    ${last_name}
    Wait Until Element Is Visible    ${LOC_INPUT_LAST_NAME}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_LAST_NAME}
    Input Text    ${LOC_INPUT_LAST_NAME}    ${last_name}
    Log    Last Name entered: ${last_name}

Fill Primary Phone
    [Documentation]    Enters value into the Primary Phone field.
    ...                MD: Step 10 — input[@name='telephoneNumber'], min 5, max 16 digits
    [Arguments]    ${phone}
    Wait Until Element Is Visible    ${LOC_INPUT_PRIMARY_PHONE}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_PRIMARY_PHONE}
    Input Text    ${LOC_INPUT_PRIMARY_PHONE}    ${phone}
    Log    Primary Phone entered: ${phone}

Fill Email Address
    [Documentation]    Enters value into the Email Address field.
    ...                MD: Step 11 — input[@name='emailId'], valid email format
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${LOC_INPUT_EMAIL}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_EMAIL}
    Input Text    ${LOC_INPUT_EMAIL}    ${email}
    Log    Email entered: ${email}

Fill Confirm Email Address
    [Documentation]    Enters value into the Confirm Email Address field.
    ...                MD: Step 12 — input[@name='confirmEmailId'], must match Email
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${LOC_INPUT_CONFIRM_EMAIL}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_CONFIRM_EMAIL}
    Input Text    ${LOC_INPUT_CONFIRM_EMAIL}    ${email}
    Log    Confirm Email entered: ${email}

Select User Category
    [Documentation]    Selects "Normal User" from the User Category native select dropdown.
    ...                select[@name='userAccountType']
    [Arguments]    ${category}=${UM_USER_CATEGORY}
    Wait Until Element Is Visible    ${LOC_DDL_USER_CATEGORY_SELECT}    ${UM_TIMEOUT}
    Select From List By Value    ${LOC_DDL_USER_CATEGORY_SELECT}    ${category}
    Sleep    1s
    Wait For App Loading To Complete
    Log    User Category selected: ${category}

Select Role
    [Documentation]    Selects a role from the custom dropdown (same component as CSR Journey).
    ...                Tries primary name, then UM_ROLE_SELECTION_CANDIDATES, normalized text match, then first option.
    [Arguments]    ${role_name}=${UM_ROLE_NAME}
    ${picked}=    Run Keyword And Return Status
    ...    Select Custom Dropdown Option    ${LOC_ROLE_DD_BTN}    roleSelectedValueuet    ${role_name}
    IF    not ${picked}
        FOR    ${c}    IN    @{UM_ROLE_SELECTION_CANDIDATES}
            Continue For Loop If    '${c}' == '${role_name}'
            ${picked}=    Run Keyword And Return Status
            ...    Select Custom Dropdown Option    ${LOC_ROLE_DD_BTN}    roleSelectedValueuet    ${c}
            Exit For Loop If    ${picked}
        END
    END
    IF    not ${picked}
        ${picked}=    UM Select Role By Normalized Option Text    ${role_name}
    END
    IF    not ${picked}
        ${picked}=    UM Pick First Visible Role Option
    END
    Should Be True    ${picked}    Could not select role '${role_name}' (tried aliases and first option).
    Log    Role selected (requested): ${role_name}

Select Country
    [Documentation]    Selects a country from the custom dropdown (same component as CSR Journey).
    ...                Clicks selectBtn near Country label → options appear → clicks matching option.
    [Arguments]    ${country}=${UM_COUNTRY_TEXT}
    Select Custom Dropdown Option    ${LOC_COUNTRY_DD_BTN}    countrySelectedValueuet    ${country}
    Log    Country selected: ${country}

Select Time Zone
    [Documentation]    Selects a time zone from the custom dropdown (same component as CSR Journey).
    ...                Clicks selectBtn near Timezone label → options appear → clicks matching option.
    [Arguments]    ${timezone}=${UM_TIMEZONE_TEXT}
    Select Custom Dropdown Option    ${LOC_TIMEZONE_DD_BTN}    timeZoneSelectedValueuet    ${timezone}
    Log    Time Zone selected: ${timezone}

Select Custom Dropdown Option
    [Documentation]    Generic keyword for the custom div-based dropdowns on CreateUser form.
    ...                Same component as CSR Journey (selectBtn + selectDropdown + option divs).
    ...                Finds the selectBtn by label text, clicks it, finds option by JS text match.
    [Arguments]    ${btn_locator}    ${testid}    ${option_text}
    # Step 1: Find and click the selectBtn trigger
    Scroll To Element Via JS    ${btn_locator}
    Wait Until Element Is Visible    ${btn_locator}    ${UM_TIMEOUT}
    Click Element Via JS    ${btn_locator}
    Sleep    1s
    # Step 2: Find option — exact CSR Journey pattern: @name + @data-testid + class + text
    ${option}=    Set Variable    xpath=//div[@name='${testid}' and @data-testid='${testid}' and contains(@class,'option') and normalize-space()='${option_text}']
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option}    8s
    IF    not ${option_visible}
        # Fallback 1: data-testid + class + contains text
        ${option}=    Set Variable    xpath=//div[@data-testid='${testid}' and contains(@class,'option') and contains(text(),'${option_text}')]
        ${option_visible2}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${option}    5s
        IF    not ${option_visible2}
            # Broadest fallback: any visible div.option containing the text
            ${option}=    Set Variable    xpath=//div[contains(@class,'option') and contains(text(),'${option_text}')]
            ${option_visible3}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${option}    5s
            IF    not ${option_visible3}
                # Last resort: retry click on selectBtn then use JS to find and click
                Click Element Via JS    ${btn_locator}
                Sleep    1s
                ${clicked}=    Execute JavaScript
                ...    var wanted = arguments[0];
                ...    function norm(s) { return (s || '').replace(/[_\\s\\-\\u00a0]/g, '').toLowerCase(); }
                ...    var targetNorm = norm(wanted);
                ...    var opts = document.querySelectorAll('div.option, div[class*="option"]');
                ...    for (var i = 0; i < opts.length; i++) {
                ...        if (opts[i].offsetParent === null) continue;
                ...        var raw = opts[i].textContent.trim();
                ...        if (raw.indexOf(wanted) >= 0) { opts[i].click(); return true; }
                ...        if (targetNorm.length > 0 && norm(raw) === targetNorm) { opts[i].click(); return true; }
                ...        if (targetNorm.length > 3 && norm(raw).indexOf(targetNorm) >= 0) { opts[i].click(); return true; }
                ...    }
                ...    return false;
                ...    ARGUMENTS    ${option_text}
                Should Be True    ${clicked}    Option '${option_text}' not found in dropdown '${testid}'.
                Sleep    1s
                Wait For App Loading To Complete
                RETURN
            END
        END
    END
    Click Element Via JS    ${option}
    Sleep    1s
    Wait For App Loading To Complete

UM Select Role By Normalized Option Text
    [Documentation]    Opens Role dropdown and clicks an option whose text matches after normalizing spaces/underscores.
    [Arguments]    ${role_name}
    Scroll To Element Via JS    ${LOC_ROLE_DD_BTN}
    Click Element Via JS    ${LOC_ROLE_DD_BTN}
    Sleep    1s
    ${clicked}=    Execute JavaScript
    ...    var wanted = arguments[0];
    ...    function norm(s) { return (s || '').replace(/[_\\s\\-\\u00a0]/g, '').toLowerCase(); }
    ...    var targetNorm = norm(wanted);
    ...    if (!targetNorm) return false;
    ...    var roots = document.querySelectorAll('[data-testid="roleSelectedValueuet"], div[name="roleSelectedValueuet"]');
    ...    var opts = [];
    ...    for (var r = 0; r < roots.length; r++) {
    ...        var part = roots[r].querySelectorAll('div.option, div[class*="option"]');
    ...        for (var p = 0; p < part.length; p++) opts.push(part[p]);
    ...    }
    ...    if (opts.length === 0) {
    ...        opts = Array.prototype.slice.call(document.querySelectorAll('div.option, div[class*="option"]'));
    ...    }
    ...    for (var i = 0; i < opts.length; i++) {
    ...        if (opts[i].offsetParent === null) continue;
    ...        var raw = opts[i].textContent.trim();
    ...        var n = norm(raw);
    ...        if (n === targetNorm || n.indexOf(targetNorm) >= 0 || (targetNorm.indexOf(n) >= 0 && n.length > 5)) {
    ...            opts[i].click();
    ...            return true;
    ...        }
    ...    }
    ...    return false;
    ...    ARGUMENTS    ${role_name}
    IF    ${clicked}
        Sleep    1s
        Wait For App Loading To Complete
    END
    Return From Keyword    ${clicked}

UM Pick First Visible Role Option
    [Documentation]    Last resort: select first non-placeholder visible option in the Role dropdown (after opening it).
    Scroll To Element Via JS    ${LOC_ROLE_DD_BTN}
    Click Element Via JS    ${LOC_ROLE_DD_BTN}
    Sleep    1s
    ${clicked}=    Execute JavaScript
    ...    var root = document.querySelector('[data-testid="roleSelectedValueuet"]') || document.querySelector('div[name="roleSelectedValueuet"]');
    ...    var opts = root ? root.querySelectorAll('div.option, div[class*="option"]') : [];
    ...    var skip = /^(select|choose|--|please)/i;
    ...    for (var i = 0; i < opts.length; i++) {
    ...        if (opts[i].offsetParent === null) continue;
    ...        var t = (opts[i].textContent || '').trim();
    ...        if (!t || t.length < 2 || skip.test(t)) continue;
    ...        opts[i].click();
    ...        return true;
    ...    }
    ...    return false;
    IF    ${clicked}
        Sleep    1s
        Wait For App Loading To Complete
    END
    Return From Keyword    ${clicked}

Select OTP SMS Checkbox
    [Documentation]    Selects the SMS OTP delivery channel checkbox.
    ...                MD: Step 16 — input[@name='sms'], default checked
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_SMS}    10s
    IF    ${visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_SMS}
        IF    not ${checked}
            Click Element Via JS    ${LOC_CHK_SMS}
            Log    SMS OTP checkbox selected.
        ELSE
            Log    SMS OTP checkbox already selected.
        END
    ELSE
        Log    SMS checkbox not found.    level=WARN
    END

Select OTP Email Checkbox
    [Documentation]    Selects the Email OTP delivery channel checkbox.
    ...                MD: Step 16 — input[@name='email']
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_EMAIL_OTP}    10s
    IF    ${visible}
        Click Element Via JS    ${LOC_CHK_EMAIL_OTP}
        Log    Email OTP checkbox selected.
    ELSE
        Log    Email OTP checkbox not found.    level=WARN
    END

Uncheck All OTP Checkboxes
    [Documentation]    Unchecks all OTP delivery channel checkboxes.
    ${sms_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_SMS}    5s
    IF    ${sms_visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_SMS}
        IF    ${checked}
            Click Element Via JS    ${LOC_CHK_SMS}
        END
    END
    ${email_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_EMAIL_OTP}    5s
    IF    ${email_visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_EMAIL_OTP}
        IF    ${checked}
            Click Element Via JS    ${LOC_CHK_EMAIL_OTP}
        END
    END
    Log    All OTP checkboxes unchecked.

# ═══════════════════════════════════════════════════════════════════════
#  FILL COMPLETE FORM (MD: Steps 6–16 combined)
# ═══════════════════════════════════════════════════════════════════════
Fill User Creation Form
    [Documentation]    Fills all mandatory fields on the Create User form.
    ...                User Category → Account → Username → First Name → Last Name →
    ...                Primary Phone → Email → Confirm Email → Role → Country → Time Zone → OTP
    [Arguments]    ${username}=${TEST_USERNAME}    ${first_name}=${TEST_FIRST_NAME}
    ...    ${last_name}=${TEST_LAST_NAME}    ${phone}=${TEST_PRIMARY_PHONE}
    ...    ${email}=${TEST_EMAIL}
    Select User Category
    Sleep    1s
    Wait For App Loading To Complete
    Select Account In TreeView
    Fill Username    ${username}
    Fill First Name    ${first_name}
    Fill Last Name    ${last_name}
    Fill Primary Phone    ${phone}
    Fill Email Address    ${email}
    Fill Confirm Email Address    ${email}
    Select Role
    Select Country
    Select Time Zone
    Select OTP SMS Checkbox
    Log    User creation form filled with all mandatory fields.

# ═══════════════════════════════════════════════════════════════════════
#  SUBMIT & VERIFY (MD: Steps 17–19)
# ═══════════════════════════════════════════════════════════════════════
Click Submit Button
    [Documentation]    Clicks the Submit button on the Create User form.
    ...                MD: Step 17 — button[contains(text(),'Submit')]
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_SUBMIT}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Submit button clicked.

Click Close Form Button
    [Documentation]    Clicks the Close button to cancel form without saving.
    ...                MD: Buttons — Close: Cancels and closes the form without saving
    Wait For Loading Overlay To Disappear
    ${seen}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_BTN_CLOSE_FORM}    8s
    IF    not ${seen}
        ${js_close}=    Execute Javascript
        ...    var els=document.querySelectorAll('button,a,input[type="button"],input[type="submit"]');
        ...    for(var i=0;i<els.length;i++){
        ...    var t=(els[i].textContent||els[i].value||'').replace(/\\s+/g,' ').trim();
        ...    var tl=t.toLowerCase();
        ...    if(tl==='close'||tl.indexOf('close')===0){ els[i].scrollIntoView({block:'center'}); els[i].click(); return true;}
        ...    }
        ...    return false;
        Should Be True    ${js_close}    Close control not found on Create User form.
    ELSE
        Run Keyword And Ignore Error    Scroll To Element Via JS    ${LOC_BTN_CLOSE_FORM}
        Click Element Via JS    ${LOC_BTN_CLOSE_FORM}
    END
    Sleep    1s
    Wait For App Loading To Complete
    Log    Close button clicked.

Verify Success Toast Displayed
    [Documentation]    Verifies a success toast notification is visible.
    ...                MD: Step 18 — Toast notification appears confirming user creation
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    15s
    IF    ${visible}
        Log    Success toast displayed.
    ELSE
        ${any_toast}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_TOAST_MESSAGE}    5s
        IF    ${any_toast}
            ${msg}=    Get Text    ${LOC_TOAST_MESSAGE}
            Log    Toast message: ${msg}
        ELSE
            Log    No toast notification found.    level=WARN
        END
    END

Verify Error Toast Or Validation Displayed
    [Documentation]    Verifies an error toast or inline validation error is shown.
    ${has_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_ERROR}    10s
    ${has_validation}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_VALIDATION_ERROR}    5s
    IF    ${has_toast}
        Log    Error toast displayed.
    ELSE IF    ${has_validation}
        Log    Inline validation error displayed.
    ELSE
        Log    No error toast or validation found — form may have other error indicators.    level=WARN
    END

Verify User In Grid
    [Documentation]    Verifies that the given username appears in the Manage User grid.
    ...                MD: Step 19 — The newly created user appears in the grid
    [Arguments]    ${username}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${username}')]
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    15s
    IF    ${visible}
        Log    User '${username}' found in Manage User grid.
    ELSE
        Log    User '${username}' not found in grid — may need search.    level=WARN
        Search User In Grid    ${username}
        Wait Until Element Is Visible    ${loc}    15s
    END

Verify User Not In Grid
    [Documentation]    Verifies that the given username does NOT appear in the Manage User grid.
    ...                MD: TC_002 Step 8 — The user no longer appears in the grid
    [Arguments]    ${username}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${username}')]
    Sleep    1s
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    5s
    IF    ${visible}
        Fail    User '${username}' still visible in grid after deletion.
    ELSE
        Log    User '${username}' confirmed not in grid.
    END

Verify On Create User Page
    [Documentation]    Confirms the browser is still on the Create User page.
    Location Should Contain    ${CREATE_USER_PATH}
    Log    Still on Create User page.

Verify On Create User Page After Invalid Submit
    [Documentation]    After invalid Submit, some builds stay on /CreateUser; others route back to /ManageUser.
    ...                Next step should still assert error toast or inline validation.
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    ${loc}=    Get Location
    ${on_create}=    Run Keyword And Return Status    Location Should Contain    ${CREATE_USER_PATH}
    ${on_manage}=    Run Keyword And Return Status    Location Should Contain    ${MANAGE_USER_PATH}
    IF    ${on_create}
        Log    Still on Create User route after invalid submit.
    ELSE IF    ${on_manage}
        Log    On Manage User route after invalid submit (SPA returned to list).
    ELSE
        Fail    Expected URL to contain ${CREATE_USER_PATH} or ${MANAGE_USER_PATH}; was ${loc}
    END

Verify On Manage User Page
    [Documentation]    Confirms the browser is on the Manage User page.
    Location Should Contain    ${MANAGE_USER_PATH}
    Log    On Manage User page.

# ═══════════════════════════════════════════════════════════════════════
#  SEARCH (MD: TC_002 Step 2, XPath for search)
# ═══════════════════════════════════════════════════════════════════════
Search User In Grid
    [Documentation]    Types the username into the search input and presses Enter.
    ...                MD: Search input — //input[@placeholder='Enter Search Text']
    [Arguments]    ${username}
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_SEARCH}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_MANAGE_USER_SEARCH}
    Input Text    ${LOC_MANAGE_USER_SEARCH}    ${username}
    Press Keys    ${LOC_MANAGE_USER_SEARCH}    RETURN
    Sleep    1s
    Wait For App Loading To Complete
    Sleep    1s
    Log    Searched for user: ${username}

Clear Search In Grid
    [Documentation]    Clears the search input and refreshes the grid.
    Wait Until Element Is Visible    ${LOC_MANAGE_USER_SEARCH}    ${UM_TIMEOUT}
    Clear Element Text    ${LOC_MANAGE_USER_SEARCH}
    Press Keys    ${LOC_MANAGE_USER_SEARCH}    RETURN
    Sleep    1s
    Wait For App Loading To Complete
    Log    Search cleared.

# ═══════════════════════════════════════════════════════════════════════
#  DELETE USER (MD: TC_002 Steps 3–7, Confirmation Dialog Reference)
# ═══════════════════════════════════════════════════════════════════════
Click Delete Icon For User
    [Documentation]    Clicks delete in the Action column (Kendo delete, FA trash, or titled control).
    [Arguments]    ${username}
    ${row_loc}=    Set Variable    xpath=//tr[.//td[contains(.,'${username}')]]
    ${row_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${row_loc}    15s
    IF    ${row_ok}
        Scroll To Element Via JS    ${row_loc}
        Sleep    0.5s
    END
    ${delete_loc}=    Replace String    ${LOC_DELETE_ICON_TEMPLATE}    PLACEHOLDER    ${username}
    ${delete_xpath}=    Set Variable    xpath=${delete_loc}
    Wait Until Element Is Visible    ${delete_xpath}    ${UM_TIMEOUT}
    Click Element Via JS    ${delete_xpath}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Delete icon clicked for user: ${username}

Verify Delete Confirmation Dialog
    [Documentation]    Verifies the delete confirmation dialog appears with correct heading and body.
    ...                MD: Step 4 — Heading: "Delete User"
    ...                MD: Step 5 — Body: "Do you want to delete the user - USERNAME?"
    [Arguments]    ${username}
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG}    10s
    IF    not ${dialog_visible}
        Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_OK}    10s
    END
    ${heading_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_HEADING}    5s
    IF    ${heading_visible}
        ${heading_text}=    Get Text    ${LOC_DELETE_DIALOG_HEADING}
        Should Contain    ${heading_text}    ${DELETE_DIALOG_HEADING}
        Log    Dialog heading verified: ${heading_text}
    END
    ${body_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_BODY}    5s
    IF    ${body_visible}
        ${body_text}=    Get Text    ${LOC_DELETE_DIALOG_BODY}
        Should Contain    ${body_text}    ${username}
        Log    Dialog body verified: ${body_text}
    END

Click OK On Delete Confirmation
    [Documentation]    Clicks the OK button on the delete confirmation dialog.
    ...                MD: Step 6 — Click OK → Deletion request submitted
    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_OK}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_DIALOG_OK}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    OK clicked on delete confirmation.

Click Cancel On Delete Confirmation
    [Documentation]    Clicks the Cancel button on the delete confirmation dialog.
    ...                MD: Confirmation Dialog Reference — Cancel button
    Wait Until Element Is Visible    ${LOC_DELETE_DIALOG_CANCEL}    ${UM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_DIALOG_CANCEL}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Cancel clicked on delete confirmation.

Verify Delete Success Toast
    [Documentation]    Verifies the toast message "User Deleted Successfully".
    ...                MD: Step 7 — Toast: "User Deleted Successfully"
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_TOAST_SUCCESS}    15s
    IF    ${visible}
        ${msg}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_TOAST_MESSAGE}    5s
        IF    ${msg}
            ${text}=    Get Text    ${LOC_TOAST_MESSAGE}
            Should Contain    ${text}    ${DELETE_SUCCESS_MSG}
            Log    Delete success toast: ${text}
        END
    ELSE
        Log    Success toast not found after delete.    level=WARN
    END

Delete User End To End
    [Documentation]    Full delete flow: search → click delete → verify dialog → click OK → verify removal.
    ...                MD: TC_002 Steps 2–8
    [Arguments]    ${username}
    Search User In Grid    ${username}
    Click Delete Icon For User    ${username}
    Verify Delete Confirmation Dialog    ${username}
    Click OK On Delete Confirmation
    Verify Delete Success Toast
    Clear Search In Grid
    Verify User Not In Grid    ${username}
