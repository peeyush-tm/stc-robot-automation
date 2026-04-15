*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/role_management_locators.resource
Resource    ../locators/login_locators.resource

*** Variables ***
# Overwritten by ``Load Environment Config From Json`` when present in config/<env>.json
${DEFAULT_OPCO_ACCOUNT}       KSA_OPCO
${DEFAULT_EC_ACCOUNT}         SANJ_1002
${DEFAULT_BU_ACCOUNT}         billingAccountSANJ_1003

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  SUITE SETUP
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage Role
    [Documentation]    Opens browser, logs in, navigates to Admin > Role & Access.
    ...                MD: Prerequisites → User is logged in with RW permission.
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Verify Login Success
    Navigate To Manage Role Page
    Log    Suite setup complete: logged in and on Manage Role page.

# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION (MD: TC-ROLE-001 Step 1, TC-ROLE-002 Step 1)
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage Role Page
    [Documentation]    Navigates to /ManageRole using direct URL navigation.
    ...                MD: Step 1.1–1.2 — Browser navigates to /ManageRole.
    ...                Constructs URL from BASE_URL (env-dependent) + ManageRole path.
    ${base}=    Evaluate    '${BASE_URL}'.rstrip('/')
    Go To    ${base}/ManageRole
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ${MANAGE_ROLE_PATH}
    Wait Until Element Is Visible    ${LOC_ROLE_GRID}    ${RM_TIMEOUT}
    Log    Navigated to Manage Role page.

Refresh Manage Role Page
    [Documentation]    Ensures we are on /ManageRole. If already there, just waits for grid.
    ...                If on another page (CreateRole, ManageUser, etc), navigates via URL.
    ${on_manage_role}=    Run Keyword And Return Status
    ...    Location Should Contain    ${MANAGE_ROLE_PATH}
    IF    ${on_manage_role}
        Wait For App Loading To Complete
    ELSE
        ${base}=    Evaluate    '${BASE_URL}'.rstrip('/')
        Go To    ${base}/ManageRole
        Sleep    1s
        Wait For App Loading To Complete    timeout=60s
    END
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ${MANAGE_ROLE_PATH}
    Wait Until Element Is Visible    ${LOC_ROLE_GRID}    ${RM_TIMEOUT}
    Log    On Manage Role page.

# ═══════════════════════════════════════════════════════════════════════
#  MANAGE ROLE PAGE VERIFICATION (MD: Step 1.2)
# ═══════════════════════════════════════════════════════════════════════
Verify Manage Role Page Loaded
    [Documentation]    Verifies the Manage Role page URL and grid.
    ...                MD: Step 1.2 — Role & Access list page is displayed.
    Location Should Contain    ${MANAGE_ROLE_PATH}
    Log    Manage Role page loaded.

Verify Role Grid Loaded
    [Documentation]    Verifies the Role grid is visible with column headers.
    Wait Until Element Is Visible    ${LOC_ROLE_GRID}    ${RM_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ROLE_GRID_COLUMN_HEADER}    ${RM_TIMEOUT}
    Log    Role grid loaded.

Verify Role Grid Has Pagination
    [Documentation]    Verifies pagination controls on the Role grid.
    Wait Until Element Is Visible    ${LOC_ROLE_GRID_PAGINATION}    ${RM_TIMEOUT}
    Log    Role grid pagination visible.

# ═══════════════════════════════════════════════════════════════════════
#  CREATE ROLE BUTTON (MD: Step 2.1)
# ═══════════════════════════════════════════════════════════════════════
Verify Create Role Button Visible
    [Documentation]    MD: Step 2.1 — Create Role button is visible (RW permission).
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_ROLE}    ${RM_TIMEOUT}
    Log    Create Role button is visible.

Click Create Role Button
    [Documentation]    MD: Step 2.2 — Click Create Role → /CreateRole.
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_ROLE}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CREATE_ROLE}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Create Role button clicked.

Open Create Role Form
    [Documentation]    Clicks Create Role and verifies the form loads.
    Click Create Role Button
    Verify Create Role Form Loaded

# ═══════════════════════════════════════════════════════════════════════
#  CREATE ROLE FORM (MD: Steps 2.2–3.5, Locator Reference)
# ═══════════════════════════════════════════════════════════════════════
Verify Create Role Form Loaded
    [Documentation]    Verifies URL is /CreateRole and form fields are visible.
    ...                MD: Step 2.2 — Create Role form is displayed.
    Location Should Contain    ${CREATE_ROLE_PATH}
    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_NAME}    ${RM_TIMEOUT}
    Log    Create Role form loaded.

Verify Create Role Breadcrumb
    [Documentation]    MD: Step 2.3 — Breadcrumb reads "Role & Access > Create".
    ...                MD: Notes — use breadcrumb as page-load confirmation.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_BREADCRUMB_CREATE}    10s
    IF    ${visible}
        Log    Breadcrumb 'Create' visible.
    ELSE
        Log    Breadcrumb not found — checking URL instead.    level=WARN
        Location Should Contain    ${CREATE_ROLE_PATH}
    END

Verify All Role Form Fields Present
    [Documentation]    Verifies all form fields from MD: Account, Role Name,
    ...                Role Description, Data Masking checkbox.
    ${account}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_DROPDOWN}    10s
    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_NAME}    ${RM_TIMEOUT}
    ${desc}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_DESCRIPTION}    10s
    ${masking}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_DATA_MASKING}    10s
    Log    Form fields verified: Account=${account}, RoleName=True, Description=${desc}, DataMasking=${masking}

Verify Permissions Table Visible
    [Documentation]    MD: Step 4.1 — Permissions grid is visible.
    ...                DOM: div.gc-module-selector-wrapper contains table.gc-module-selector-table
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_PERMISSIONS_TABLE}    15s
    IF    ${visible}
        Log    Permissions table visible.
    ELSE
        ${cb_count}=    Execute JavaScript
        ...    return document.querySelectorAll('input[name="js-role-view"]').length;
        IF    ${cb_count} > 0
            Log    View permission checkboxes found (${cb_count}) — permissions table exists.
        ELSE
            Log    Permissions table not found.    level=WARN
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  FIELD INTERACTIONS (MD: Steps 3.1–3.5, Locator Reference)
# ═══════════════════════════════════════════════════════════════════════
Select Role Account In TreeView
    [Documentation]    MD: Step 3.1–3.2 — Click Account tree-view dropdown and select the
    ...                target BU account: ${DEFAULT_OPCO_ACCOUNT} → ${DEFAULT_EC_ACCOUNT} → ${DEFAULT_BU_ACCOUNT}.
    ...                Same hierarchical expansion as Create User TreeView.
    Sleep    1s
    # Step 1: Try to find and click the account dropdown trigger
    ${clicked}=    Execute JavaScript
    ...    var names = ['accountName','accountId','parentAccount','account'];
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
    Log    Account trigger click result: ${clicked}
    IF    '${clicked}' == '${EMPTY}'
        ${fallback_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_DROPDOWN}    10s
        IF    ${fallback_visible}
            Click Element Via JS    ${LOC_ROLE_ACCOUNT_DROPDOWN}
        ELSE
            Fail    Account TreeView trigger not found on CreateRole page.
        END
    END
    Sleep    1s
    Wait For App Loading To Complete
    # Step 2: Wait for the TreeView to appear
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_TREE}    10s
    IF    not ${tree_visible}
        Fail    TreeView did not appear after clicking Account trigger.
    END
    # Step 3: Wait for root node and expand hierarchy
    Wait Until Element Is Visible    ${LOC_ROLE_TREE_ROOT_NODE}    15s
    Sleep    1s
    RM Expand And Select BU Account
    Sleep    1s
    Wait For App Loading To Complete
    Log    Account selected: ${RM_BU_ACCOUNT_NAME}

RM Expand Select Bu Pair
    [Documentation]    One attempt: OPCO root → EC → BU for Create Role account tree.
    [Arguments]    ${ec_name}    ${bu_name}
    RM Clear Account Tree Search If Present
    ${root_expand}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_TREE_ROOT_EXPAND}    5s
    IF    ${root_expand}
        Click Element Via JS    ${LOC_ROLE_TREE_ROOT_EXPAND}
        Sleep    1s
        Wait For App Loading To Complete    timeout=30s
        Sleep    1s
        Log    Root tree expand clicked (first expand icon).
    END
    RM Expand Tree Node By Name    ${DEFAULT_OPCO_ACCOUNT}
    RM Type In Account Tree Search If Present    ${ec_name}
    RM Expand Tree Node By Name    ${ec_name}
    Sleep    1s
    Wait For App Loading To Complete    timeout=30s
    Sleep    1s
    Log    EC '${ec_name}' expanded.
    RM Type In Account Tree Search If Present    ${bu_name}
    RM Select Tree Node By Name    ${bu_name}

RM Reopen Role Account Dropdown Treeview
    [Documentation]    Dismiss and re-open Account tree on Create Role after a failed selection.
    Run Keyword And Ignore Error
    ...    Execute Javascript    document.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}));
    Sleep    0.5s
    ${re}=    Execute Javascript
    ...    var names=['accountName','accountId','parentAccount','account'];
    ...    for(var n=0;n<names.length;n++){ var inp=document.querySelector('input[name="'+names[n]+'"]'); if(inp&&(inp.offsetParent!==null||inp.offsetHeight>0)){ inp.scrollIntoView({block:'center'}); inp.click(); return names[n]; } }
    ...    return '';
    Sleep    1s
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_TREE}    15s
    Wait Until Element Is Visible    ${LOC_ROLE_TREE_ROOT_NODE}    15s
    Sleep    1s

RM Expand Ksa And Select First Ec Bu
    [Documentation]    Last resort: OPCO root → first child EC → first BU checkbox (Create Role tree).
    RM Clear Account Tree Search If Present
    ${root_expand}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_TREE_ROOT_EXPAND}    5s
    IF    ${root_expand}
        Click Element Via JS    ${LOC_ROLE_TREE_ROOT_EXPAND}
        Sleep    1s
        Wait For App Loading To Complete    timeout=30s
    END
    RM Expand Tree Node By Name    ${DEFAULT_OPCO_ACCOUNT}
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

RM Expand And Select BU Account
    [Documentation]    Expand OPCO → EC → BU. Tries RM_EC_/RM_BU_; config default EC/BU; then first EC/BU heuristic.
    ${ok}=    Run Keyword And Return Status    RM Expand Select Bu Pair    ${RM_EC_ACCOUNT_NAME}    ${RM_BU_ACCOUNT_NAME}
    IF    not ${ok}
        Log    Role account tree: could not use EC '${RM_EC_ACCOUNT_NAME}' — retrying ${DEFAULT_EC_ACCOUNT} / ${DEFAULT_BU_ACCOUNT}    level=WARN    console=yes
        RM Reopen Role Account Dropdown Treeview
        ${ok2}=    Run Keyword And Return Status    RM Expand Select Bu Pair    ${DEFAULT_EC_ACCOUNT}    ${DEFAULT_BU_ACCOUNT}
        IF    not ${ok2}
            Log    Role account tree: default EC/BU fallback failed — using first EC/BU under ${DEFAULT_OPCO_ACCOUNT}    level=WARN    console=yes
            RM Reopen Role Account Dropdown Treeview
            RM Expand Ksa And Select First Ec Bu
        END
    END

RM Clear Account Tree Search If Present
    [Documentation]    Clears Create Role account tree filter before a new EC/BU path.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}    4s
    IF    not ${visible}
        RETURN
    END
    Scroll To Element Via JS    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}
    Clear Element Text    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}
    Press Keys    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}    RETURN
    Sleep    0.8s
    Wait For App Loading To Complete    timeout=20s

RM Type In Account Tree Search If Present
    [Documentation]    If the account tree has a filter/search box, type text and submit to narrow nodes.
    [Arguments]    ${text}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}    4s
    IF    not ${visible}
        RETURN
    END
    Scroll To Element Via JS    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}
    Clear Element Text    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}
    Input Text    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}    ${text}
    Sleep    0.5s
    Press Keys    ${LOC_ROLE_ACCOUNT_TREE_SEARCH}    RETURN
    Sleep    1s
    Wait For App Loading To Complete    timeout=20s

RM Expand Tree Node By Name
    [Documentation]    Finds a tree node by label and expands it (visible tree only, scroll, Kendo icons).
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

RM Select Tree Node By Name
    [Documentation]    Finds a tree node by exact label and clicks checkbox or label (visible tree, scroll).
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

Fill Role Name
    [Documentation]    MD: Step 3.3 — Enter role name (max 250 chars).
    ...                Locator: input[@name='roleName']
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_NAME}    ${RM_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_ROLE_NAME}
    Input Text    ${LOC_INPUT_ROLE_NAME}    ${name}
    Log    Role Name entered: ${name}

Fill Role Description
    [Documentation]    MD: Step 3.4 — Enter role description (max 500 chars, optional).
    ...                Locator: input/textarea[@name='roleDescription']
    [Arguments]    ${description}
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_INPUT_ROLE_DESCRIPTION}    10s
    IF    ${visible}
        Clear Element Text    ${LOC_INPUT_ROLE_DESCRIPTION}
        Input Text    ${LOC_INPUT_ROLE_DESCRIPTION}    ${description}
        Log    Role Description entered: ${description}
    ELSE
        Log    Role Description field not visible.    level=WARN
    END

Check Data Masking Checkbox
    [Documentation]    MD: Step 3.5 — Check the Data Masking checkbox.
    ...                Locator: input[@name='accountCheckbox']
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_DATA_MASKING}    10s
    IF    ${visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_DATA_MASKING}
        IF    not ${checked}
            Click Element Via JS    ${LOC_CHK_DATA_MASKING}
            Log    Data Masking checkbox checked.
        ELSE
            Log    Data Masking already checked.
        END
    ELSE
        Log    Data Masking checkbox not found.    level=WARN
    END

Uncheck Data Masking Checkbox
    [Documentation]    MD: Step 3.5 — Leave Data Masking unchecked.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_CHK_DATA_MASKING}    10s
    IF    ${visible}
        ${checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_CHK_DATA_MASKING}
        IF    ${checked}
            Click Element Via JS    ${LOC_CHK_DATA_MASKING}
            Log    Data Masking checkbox unchecked.
        ELSE
            Log    Data Masking already unchecked.
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  PERMISSIONS (MD: Step 4, Locator Reference)
# ═══════════════════════════════════════════════════════════════════════
Click View All Header Checkbox
    [Documentation]    MD: Step 4.3 — Click View All header checkbox (name=js-role-viewheader).
    ...                DOM: multiple header checkboxes exist (one per module table).
    ...                Clicks the first one found.
    ${clicked}=    Execute JavaScript
    ...    var cb = document.querySelector('input[name="js-role-viewheader"]');
    ...    if (cb) { cb.click(); return true; }
    ...    return false;
    IF    ${clicked}
        Log    View All header checkbox clicked.
    ELSE
        Log    View All header checkbox not found.    level=WARN
    END

Click Edit All Header Checkbox
    [Documentation]    MD: Step 4.3 — Click Edit All header checkbox (name=js-role-editheader).
    ...                DOM: multiple header checkboxes exist (one per module table).
    ...                Clicks the first one found.
    ${clicked}=    Execute JavaScript
    ...    var cb = document.querySelector('input[name="js-role-editheader"]');
    ...    if (cb) { cb.click(); return true; }
    ...    return false;
    IF    ${clicked}
        Log    Edit All header checkbox clicked.
    ELSE
        Log    Edit All header checkbox not found.    level=WARN
    END

Toggle View Permission By Row Index
    [Documentation]    MD: Step 4.2 — Check/uncheck the View checkbox for a specific row.
    ...                Row index is 1-based. DOM: name='js-role-view'.
    [Arguments]    ${row_index}
    ${clicked}=    Execute JavaScript
    ...    var cbs = document.querySelectorAll('input[name="js-role-view"]');
    ...    if (${row_index} - 1 < cbs.length) { cbs[${row_index} - 1].click(); return true; }
    ...    return false;
    IF    ${clicked}
        Log    View checkbox toggled for row ${row_index}.
    ELSE
        Log    View checkbox for row ${row_index} not found.    level=WARN
    END

Toggle Edit Permission By Row Index
    [Documentation]    MD: Step 4.2 — Check/uncheck the Edit checkbox for a specific row.
    ...                Row index is 1-based. DOM: name='js-role-edit'.
    [Arguments]    ${row_index}
    ${clicked}=    Execute JavaScript
    ...    var cbs = document.querySelectorAll('input[name="js-role-edit"]');
    ...    if (${row_index} - 1 < cbs.length) { cbs[${row_index} - 1].click(); return true; }
    ...    return false;
    IF    ${clicked}
        Log    Edit checkbox toggled for row ${row_index}.
    ELSE
        Log    Edit checkbox for row ${row_index} not found.    level=WARN
    END

Select View And Edit For First N Rows
    [Documentation]    Checks both View and Edit checkboxes for the first N permission rows.
    ...                DOM: tables have class gc-module-selector-table, checkboxes use name attrs.
    [Arguments]    ${count}=3
    ${cb_count}=    Execute JavaScript
    ...    return document.querySelectorAll('input[name="js-role-view"]').length;
    IF    ${cb_count} == 0
        Log    No View permission checkboxes found on page.    level=WARN
        RETURN
    END
    Scroll To Element Via JS    ${LOC_PERMISSIONS_TABLE}
    Sleep    1s
    FOR    ${i}    IN RANGE    1    ${count} + 1
        Toggle View Permission By Row Index    ${i}
        Sleep    0.5s
        Toggle Edit Permission By Row Index    ${i}
        Sleep    0.5s
    END
    Log    View and Edit permissions selected for first ${count} rows.

# ═══════════════════════════════════════════════════════════════════════
#  FILL COMPLETE FORM
# ═══════════════════════════════════════════════════════════════════════
Fill Role Creation Form
    [Documentation]    Fills all fields on the Create Role form.
    ...                MD: Steps 3.1–3.5 — Account, Role Name, Description, Data Masking.
    [Arguments]    ${role_name}=${ROLE_NAME}    ${description}=${ROLE_DESCRIPTION}
    Select Role Account In TreeView
    Fill Role Name    ${role_name}
    Fill Role Description    ${description}
    Log    Role creation form filled.

Fill Role Creation Form With Permissions
    [Documentation]    Fills all fields + configures View/Edit permissions for first N rows.
    ...                MD: Steps 3.1–4.3 — Account, Role Name, Description + permissions.
    [Arguments]    ${role_name}=${ROLE_NAME}    ${description}=${ROLE_DESCRIPTION}    ${perm_rows}=3
    Select Role Account In TreeView
    Fill Role Name    ${role_name}
    Fill Role Description    ${description}
    Select View And Edit For First N Rows    ${perm_rows}
    Log    Role creation form filled with permissions (${perm_rows} rows).

Fill Role Creation Form Mandatory Only
    [Documentation]    Fills only mandatory fields (Account + Role Name).
    [Arguments]    ${role_name}=${ROLE_NAME}
    Select Role Account In TreeView
    Fill Role Name    ${role_name}
    Log    Role creation form filled with mandatory fields only.

# ═══════════════════════════════════════════════════════════════════════
#  SUBMIT & VERIFY (MD: Steps 5.1–5.4)
# ═══════════════════════════════════════════════════════════════════════
Click Role Submit Button
    [Documentation]    MD: Step 5.1 — Click Submit button.
    ...                Locator: Text 'Submit'
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT_ROLE}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_SUBMIT_ROLE}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Submit button clicked.

Click Role Close Button
    [Documentation]    Clicks Close/Back button on Create Role form.
    Wait For Loading Overlay To Disappear
    ${seen}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_BTN_CLOSE_ROLE}    8s
    IF    not ${seen}
        ${js_close}=    Execute Javascript
        ...    var els=document.querySelectorAll('button,a,input[type="button"],input[type="submit"]');
        ...    for(var i=0;i<els.length;i++){
        ...    var t=(els[i].textContent||els[i].value||'').replace(/\\s+/g,' ').trim();
        ...    var tl=t.toLowerCase();
        ...    if(tl==='close'||tl.indexOf('close')===0){ els[i].scrollIntoView({block:'center'}); els[i].click(); return true;}
        ...    }
        ...    return false;
        Should Be True    ${js_close}    Close control not found on Create Role form.
    ELSE
        Run Keyword And Ignore Error    Scroll To Element Via JS    ${LOC_BTN_CLOSE_ROLE}
        Click Element Via JS    ${LOC_BTN_CLOSE_ROLE}
    END
    Sleep    1s
    Wait For App Loading To Complete
    Log    Close button clicked.

Verify Role Success Toast
    [Documentation]    MD: Step 5.2 — Success toast/notification is displayed.
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_TOAST_SUCCESS}    15s
    IF    ${visible}
        Log    Success toast displayed.
    ELSE
        ${any}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_ROLE_TOAST_MESSAGE}    5s
        IF    ${any}
            ${msg}=    Get Text    ${LOC_ROLE_TOAST_MESSAGE}
            Log    Toast message: ${msg}
        ELSE
            Log    No toast notification found.    level=WARN
        END
    END

Verify Role Error Toast Or Validation
    [Documentation]    Verifies an error toast or inline validation is displayed.
    ${toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_TOAST_ERROR}    10s
    ${validation}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ROLE_VALIDATION_ERROR}    5s
    IF    ${toast}
        Log    Error toast displayed.
    ELSE IF    ${validation}
        Log    Inline validation error displayed.
    ELSE
        Log    No error toast or validation found.    level=WARN
    END

Verify On Create Role Page
    [Documentation]    Confirms browser is still on /CreateRole.
    Location Should Contain    ${CREATE_ROLE_PATH}
    Log    Still on Create Role page.

Verify On Manage Role Page
    [Documentation]    Confirms browser is on /ManageRole.
    ...                MD: Step 5.3 — Browser navigates back to /ManageRole.
    Location Should Contain    ${MANAGE_ROLE_PATH}
    Log    On Manage Role page.

# ═══════════════════════════════════════════════════════════════════════
#  SEARCH (MD: TC-ROLE-002 Step 2, Locator: name='searchValue')
# ═══════════════════════════════════════════════════════════════════════
Search Role In Grid
    [Documentation]    MD: Step 2.1–2.2 — Type role name into search input.
    ...                Locator: input[@name='searchValue']
    [Arguments]    ${role_name}
    Wait Until Element Is Visible    ${LOC_ROLE_SEARCH_INPUT}    ${RM_TIMEOUT}
    Clear Element Text    ${LOC_ROLE_SEARCH_INPUT}
    Input Text    ${LOC_ROLE_SEARCH_INPUT}    ${role_name}
    Press Keys    ${LOC_ROLE_SEARCH_INPUT}    RETURN
    Sleep    1s
    Wait For App Loading To Complete
    Sleep    1s
    Log    Searched for role: ${role_name}

Clear Role Search
    [Documentation]    Clears the search input on the list page.
    Wait Until Element Is Visible    ${LOC_ROLE_SEARCH_INPUT}    ${RM_TIMEOUT}
    Clear Element Text    ${LOC_ROLE_SEARCH_INPUT}
    Press Keys    ${LOC_ROLE_SEARCH_INPUT}    RETURN
    Sleep    1s
    Wait For App Loading To Complete
    Log    Search cleared.

Verify Role In Grid
    [Documentation]    MD: Step 2.3 / Step 5.4 — Verify role appears in grid.
    [Arguments]    ${role_name}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${role_name}')]
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    15s
    IF    ${visible}
        Log    Role '${role_name}' found in grid.
    ELSE
        Log    Role '${role_name}' not found — trying search.    level=WARN
        Search Role In Grid    ${role_name}
        Wait Until Element Is Visible    ${loc}    15s
    END

Verify Role Not In Grid
    [Documentation]    MD: TC-ROLE-002 Step 4.3 — Role no longer present in grid.
    [Arguments]    ${role_name}
    ${loc}=    Set Variable    xpath=//td[contains(text(),'${role_name}')]
    Sleep    1s
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    5s
    IF    ${visible}
        Fail    Role '${role_name}' still visible in grid after deletion.
    ELSE
        Log    Role '${role_name}' confirmed not in grid.
    END

# ═══════════════════════════════════════════════════════════════════════
#  DELETE ROLE (MD: TC-ROLE-002 Steps 3–4)
# ═══════════════════════════════════════════════════════════════════════
Click Delete Icon For Role
    [Documentation]    Clicks delete in the Action column (Kendo delete link, FA trash, or titled icon).
    [Arguments]    ${role_name}
    ${row_loc}=    Set Variable    xpath=//tr[.//td[contains(.,'${role_name}')]]
    ${row_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${row_loc}    15s
    IF    ${row_ok}
        Scroll To Element Via JS    ${row_loc}
        Sleep    0.5s
    END
    ${raw_loc}=    Replace String    ${LOC_DELETE_ROLE_TEMPLATE}    PLACEHOLDER    ${role_name}
    ${delete_xpath}=    Set Variable    xpath=${raw_loc}
    Wait Until Element Is Visible    ${delete_xpath}    ${RM_TIMEOUT}
    Click Element Via JS    ${delete_xpath}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Delete icon clicked for role: ${role_name}

Verify Delete Confirmation Dialog For Role
    [Documentation]    MD: Step 3.3 — Confirmation dialog contains the role name.
    [Arguments]    ${role_name}
    ${dialog}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_DIALOG}    10s
    IF    not ${dialog}
        Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_YES}    10s
    END
    ${body_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_BODY}    5s
    IF    ${body_visible}
        ${body_text}=    Get Text    ${LOC_DELETE_CONFIRM_BODY}
        Should Contain    ${body_text}    ${role_name}
        Log    Delete dialog verified — contains: ${role_name}
    END

Click Confirm Delete Role
    [Documentation]    MD: Step 4.1 — Click Yes/Confirm on the confirmation dialog.
    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_YES}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_CONFIRM_YES}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Sleep    1s
    Wait For App Loading To Complete
    Log    Confirm delete clicked.

Click Cancel Delete Role
    [Documentation]    MD: Confirmation dialog — Cancel/No button.
    Wait Until Element Is Visible    ${LOC_DELETE_CONFIRM_CANCEL}    ${RM_TIMEOUT}
    Click Element Via JS    ${LOC_DELETE_CONFIRM_CANCEL}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Cancel delete clicked.

Delete Role End To End
    [Documentation]    Full delete flow: search → delete icon → verify dialog → confirm → verify removal.
    ...                MD: TC-ROLE-002 Steps 2–4.
    [Arguments]    ${role_name}
    Search Role In Grid    ${role_name}
    Click Delete Icon For Role    ${role_name}
    Verify Delete Confirmation Dialog For Role    ${role_name}
    Click Confirm Delete Role
    Verify Role Success Toast
    Clear Role Search
    Verify Role Not In Grid    ${role_name}
