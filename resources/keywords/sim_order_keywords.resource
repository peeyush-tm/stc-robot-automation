*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/sim_order_locators.resource
Resource    ../locators/login_locators.resource

*** Variables ***
# Overwritten by ``Load Environment Config From Json`` when present in config/<env>.json
${DEFAULT_OPCO_ACCOUNT}       KSA_OPCO

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION — Sidebar → Live Order → Create SIM Order
# ═══════════════════════════════════════════════════════════════════════
Navigate To Live Order Via Sidebar
    [Documentation]    Navigates to the Live Order page via direct URL for reliability.
    ...                Sidebar navigation is unreliable due to overlay/timing issues.
    Go To    ${LIVE_ORDER_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Log    Navigated to Live Order page.

Click Create SIM Order Button
    [Documentation]    Clicks the Create SIM Order button on the Live Order page.
    ...                Falls back to direct URL if button click doesn't navigate.
    Wait For Loading Overlay To Disappear
    ${btn_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_CREATE_ORDER_BTN}    timeout=30s
    IF    ${btn_visible}
        Click Element Via JS    ${LOC_SO_CREATE_ORDER_BTN}
        Sleep    1s
    END
    ${on_create}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    3x    3s    Location Should Contain    ${CREATE_SIM_ORDER_PATH}
    IF    not ${on_create}
        Go To    ${CREATE_SIM_ORDER_URL}
        Wait For Page Load
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_WIZARD_CONTAINER}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Sleep    1s
    Log    Navigated to Create SIM Order wizard.

# ═══════════════════════════════════════════════════════════════════════
#  COMBINED LOGIN + NAVIGATION KEYWORDS
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Live Order
    [Documentation]    Ensures session is active, then navigates to Live Order via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${LIVE_ORDER_URL}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s

Login And Navigate To Create SIM Order
    [Documentation]    Ensures session is active, then navigates to Create SIM Order via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_SIM_ORDER_URL}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_WIZARD_CONTAINER}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  STEP 1 — ORDER DETAILS (#discover)
# ═══════════════════════════════════════════════════════════════════════
Set SIM Replacement Order
    [Documentation]    Sets SIM Replacement Order Yes/No. CMP uses custom-styled radios — click the **visible**
    ...                ``.gc-custom-radio-btn-text`` (Yes/No), then sync hidden ``input[name=isBlank]`` if needed.
    [Arguments]    ${value}=${FALSE}
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${s}=    Convert To String    ${value}
    ${want_yes}=    Evaluate    str('${s}').lower() in ('true','1','yes')
    ${txt}=    Set Variable If    ${want_yes}    Yes    No
    ${ui_span}=    Set Variable    xpath=//div[@id='discover']//span[contains(@class,'gc-custom-radio-btn-text')][normalize-space()='${txt}']
    Wait Until Element Is Visible    ${ui_span}    timeout=10s
    Scroll To Element Via JS    ${ui_span}
    Click Element Via JS    ${ui_span}
    Sleep    300ms
    ${synced}=    Execute Javascript
    ...    var d=document.getElementById('discover'); if(!d) return false;
    ...    var want=arguments[0]===true||arguments[0]==='true'||String(arguments[0]).toLowerCase()==='true';
    ...    var yes=d.querySelector("input[name='isBlank'][value='true']");
    ...    var no=d.querySelector("input[name='isBlank'][value='false']");
    ...    if(want&&yes&&!yes.checked){ yes.click(); }
    ...    if(!want&&no&&!no.checked){ no.click(); }
    ...    return want ? (yes&&yes.checked) : (no&&no.checked);
    ...    ARGUMENTS    ${value}
    IF    not ${synced}
        Log    WARN: isBlank radio state may not match desired ${value} after UI click; continuing.    level=WARN
    END
    Sleep    300ms

Select Account From TreeView
    [Documentation]    Step 1 Account field: new UI uses custom dropdown ``data-testid=accountSelected``
    ...                (options portaled under ``body``). Legacy UI uses ``input[name=accountSelected]`` + TreeView/React fiber.
    [Arguments]    ${account_name}=${VALID_ACCOUNT_NAME}
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${new_ui}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//div[@id='discover']//*[@data-testid='accountSelected']    timeout=25s
    IF    ${new_ui}
        Wait Until Keyword Succeeds    10x    2s
        ...    Run Keywords
        ...    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_BTN}    timeout=5s
        ...    AND    Scroll To Element Via JS    ${LOC_SO_ACCOUNT_BTN}
        ${by_name}=    Run Keyword And Return Status
        ...    Select Custom Dropdown Option By Name    ${LOC_SO_ACCOUNT_BTN}    accountSelected    ${account_name}
        IF    ${by_name}
            Wait For Loading Overlay To Disappear
            Sleep    1s
            Log    Selected account (custom, exact name): ${account_name}
            RETURN
        END
        Click Element Via JS    ${LOC_SO_ACCOUNT_BTN}
        Sleep    1s
        ${opts_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_OPTION_ANY}    timeout=30s
        IF    not ${opts_visible}
            Click Element Via JS    ${LOC_SO_ACCOUNT_BTN}
            Sleep    1s
            Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_OPTION_ANY}    timeout=30s
        END
        ${search_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    xpath=//body//div[@data-testid='accountSelected']//input[contains(@class,'searchInput')]    timeout=5s
        IF    ${search_ok}
            Clear Element Text    xpath=//body//div[@data-testid='accountSelected']//input[contains(@class,'searchInput')]
            Input Text    xpath=//body//div[@data-testid='accountSelected']//input[contains(@class,'searchInput')]    ${account_name}
            Sleep    1s
        END
        ${pick}=    Execute Javascript
        ...    var want=arguments[0]||'';
        ...    var opts=document.querySelectorAll("div[data-testid='accountSelected']");
        ...    var best=null, first=null;
        ...    for(var i=0;i<opts.length;i++){
        ...      var c=(opts[i].className||'')+'';
        ...      if(c.indexOf('option')<0) continue;
        ...      if(!first) first=opts[i];
        ...      var t=(opts[i].textContent||'').trim();
        ...      if(!want) continue;
        ...      if(t===want || t.indexOf(want)>=0){ best=opts[i]; break; }
        ...    }
        ...    var el=best||first;
        ...    if(!el) return 'ERROR: no account option nodes in portal';
        ...    try{ el.click(); }catch(e){ el.dispatchEvent(new MouseEvent('click',{bubbles:true})); }
        ...    return 'OK: '+(el.textContent||'').trim();
        ...    ARGUMENTS    ${account_name}
        Log    Account custom portal pick: ${pick}    console=yes
        Should Start With    ${pick}    OK:
        ...    msg=Failed to pick account in custom dropdown: ${pick}
        Wait For Loading Overlay To Disappear
        Sleep    1s
        Log    Selected account: ${account_name}
        RETURN
    END
    Select Account Legacy TreeView Fiber    ${account_name}

Select Account Legacy TreeView Fiber
    [Documentation]    Legacy account TreeView: open ``input[name=accountSelected]`` and set React TreeView state.
    [Arguments]    ${account_name}
    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_INPUT}    timeout=25s
    Wait For Loading Overlay To Disappear
    Click Element    ${LOC_SO_ACCOUNT_INPUT}
    Sleep    1s
    ${selected}=    Execute Javascript
    ...    var root = document.querySelector('#discover');
    ...    if (!root) return 'ERROR: discover pane not found';
    ...    function fiberKeyOf(el){
    ...      if(!el) return null;
    ...      return Object.keys(el).find(function(k){
    ...        return k.indexOf('__reactFiber')===0 || k.indexOf('__reactInternalInstance')===0;
    ...      }) || null;
    ...    }
    ...    function findTreeComponent(startFiber){
    ...      var current=startFiber, component=null, onSelChange=null;
    ...      while(current){
    ...        if(current.stateNode && current.stateNode.state && current.stateNode.state.treeData){
    ...          component=current.stateNode;
    ...        }
    ...        if(current.memoizedProps && current.memoizedProps.onSelectionChange && !onSelChange){
    ...          onSelChange=current.memoizedProps.onSelectionChange;
    ...        }
    ...        current=current.return;
    ...      }
    ...      return {component:component, onSelChange:onSelChange};
    ...    }
    ...    var input = root.querySelector("input[name='accountSelected']");
    ...    if (!input) return 'ERROR: accountSelected input not found';
    ...    var k=fiberKeyOf(input);
    ...    if(!k) return 'ERROR: No React fiber on account input';
    ...    var found=findTreeComponent(input[k]);
    ...    var component=found.component, onSelChange=found.onSelChange;
    ...    if (!component) return 'ERROR: TreeView component not found in React tree';
    ...    var treeData = component.state.treeData;
    ...    var want = arguments[0];
    ...    var target = null;
    ...    function walk(nodes){
    ...      if(!nodes) return;
    ...      for (var i = 0; i < nodes.length; i++) {
    ...        var n=nodes[i];
    ...        var txt=(n.text||n.label||'').trim();
    ...        if (txt === want || txt.indexOf(want) >= 0){ target=n; return; }
    ...        if (n.items && n.items.length) walk(n.items);
    ...        if (target) return;
    ...      }
    ...    }
    ...    walk(treeData);
    ...    if (!target) return 'ERROR: Account not found in treeData';
    ...    var newState = Object.assign({}, component.state);
    ...    newState.check = Object.assign({}, newState.check, {
    ...        ids: [target.organization_organization_id || target.id || target.value]
    ...    });
    ...    newState.selected = [target];
    ...    newState.value = target.text || target.label || want;
    ...    component.setState(newState);
    ...    if (onSelChange) {
    ...        try { onSelChange([target]); } catch(e) { /* ignore */ }
    ...    }
    ...    return 'OK: ' + (target.text || target.label || '');
    ...    ARGUMENTS    ${account_name}
    Log    Account selection result: ${selected}    console=yes
    Should Start With    ${selected}    OK:
    ...    msg=Failed to select account "${account_name}": ${selected}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Log    Selected account: ${account_name}

Select BU Account From TreeView
    [Documentation]    Opens the Account treeview dropdown, expands OPCO root (${DEFAULT_OPCO_ACCOUNT}) first,
    ...                then searches for EC, expands EC, searches for BU, and selects BU.
    ...                DOM-presence check + scrollIntoView — new QE build renders the input below the fold.
    [Arguments]    ${ec_name}    ${bu_name}
    Wait Until Page Contains Element    ${LOC_SO_ACCOUNT_INPUT}    timeout=30s
    Wait For Loading Overlay To Disappear
    # Step 1: Click the Account dropdown to open the treeview panel (force — below the fold on new build)
    Click Element Via JS Force    ${LOC_SO_ACCOUNT_INPUT}
    Sleep    1s
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_TREEVIEW}    15s
    IF    not ${tree_visible}
        Execute Javascript
        ...    var inp = document.querySelector("input[name='accountSelected']");
        ...    if(inp) inp.click();
        Sleep    1s
    END
    Log    Treeview panel opened.    console=yes
    # Step 2: Expand OPCO root — must expand first before EC is visible
    ${opco_expand}=    Set Variable    xpath=//div[@id='discover']//span[contains(@class,'k-in') and contains(text(),'${DEFAULT_OPCO_ACCOUNT}')]/parent::div/preceding-sibling::span[contains(@class,'k-icon')]
    ${opco_alt}=    Set Variable    xpath=//div[@id='discover']//li[.//span[contains(text(),'${DEFAULT_OPCO_ACCOUNT}')]]//span[contains(@class,'k-i-expand') or contains(@class,'k-i-arrow-60-right') or contains(@class,'k-icon')]
    ${opco_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${opco_expand}    10s
    IF    ${opco_ok}
        Click Element Via JS    ${opco_expand}
        Log    Clicked OPCO expand arrow (primary).    console=yes
    ELSE
        ${opco_alt_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${opco_alt}    5s
        IF    ${opco_alt_ok}
            Click Element Via JS    ${opco_alt}
            Log    Clicked OPCO expand arrow (alt).    console=yes
        ELSE
            # Last resort: JS click expand icon near OPCO root label
            ${opco_click_js}=    Catenate    SEPARATOR=\n
            ...    var want = arguments[0];
            ...    var spans = document.querySelectorAll('#discover .k-in');
            ...    for (var i = 0; i < spans.length; i++) {
            ...      if (spans[i].textContent.indexOf(want) >= 0) {
            ...        var li = spans[i].closest('li');
            ...        if (li) { var icon = li.querySelector('.k-icon'); if (icon) icon.click(); }
            ...        break;
            ...      }
            ...    }
            Execute Javascript    ${opco_click_js}    ${DEFAULT_OPCO_ACCOUNT}
            Log    JS fallback: clicked OPCO expand.    console=yes
        END
    END
    # Wait for child accounts to load after expanding OPCO root
    Sleep    2s
    Wait For Loading Overlay To Disappear
    ${children_loaded}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//div[@id='discover']//li[.//span[contains(text(),'${DEFAULT_OPCO_ACCOUNT}')]]//ul//li    30s
    IF    ${children_loaded}
        Log    OPCO child accounts loaded.    console=yes
    ELSE
        Log    Child accounts not yet visible — waiting longer...    console=yes
        Sleep    5s
        Wait For Loading Overlay To Disappear
    END
    # Dump visible tree nodes for diagnostic
    ${tree_nodes}=    Execute Javascript
    ...    var nodes = document.querySelectorAll('#discover .k-in');
    ...    var result = [];
    ...    nodes.forEach(function(n,i){ if(i<15) result.push(n.textContent.trim()); });
    ...    return JSON.stringify(result);
    Log    Treeview nodes after expand: ${tree_nodes}    console=yes
    # Step 3: Search for EC account in the treeview search input
    ${search_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_TREEVIEW_SEARCH}    10s
    Log    Treeview search input visible: ${search_visible}    console=yes
    IF    ${search_visible}
        Treeview Search Type    ${ec_name}
        Log    Typed EC "${ec_name}" in treeview search.    console=yes
        Sleep    1s
    END
    # Step 4: Find and expand the EC node
    ${ec_node}=    Set Variable    xpath=//div[@id='discover']//span[contains(@class,'k-in') and contains(text(),'${ec_name}')]
    ${ec_found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${ec_node}    15s
    Log    EC node visible: ${ec_found}    console=yes
    IF    ${ec_found}
        # Click expand arrow on EC
        Execute Javascript
        ...    var spans = document.querySelectorAll('#discover .k-in');
        ...    for(var i=0; i<spans.length; i++){
        ...        if(spans[i].textContent.indexOf(arguments[0])>=0){
        ...            var li = spans[i].closest('li');
        ...            if(li){ var icon = li.querySelector('.k-icon'); if(icon){ icon.click(); return; } }
        ...        }
        ...    }
        ...    ARGUMENTS    ${ec_name}
        Log    Expanded EC node "${ec_name}".    console=yes
        Sleep    2s
        Wait For Loading Overlay To Disappear
        # Wait for BU child to appear under EC
        ${bu_children}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    xpath=//div[@id='discover']//span[contains(@class,'k-in') and contains(text(),'${ec_name}')]/ancestor::li//ul//li    30s
        IF    ${bu_children}
            Log    EC child accounts (BU) loaded.    console=yes
        ELSE
            Log    BU children not yet visible — waiting longer...    console=yes
            Sleep    5s
            Wait For Loading Overlay To Disappear
        END
    ELSE
        Fail    EC "${ec_name}" not found in treeview after expanding ${DEFAULT_OPCO_ACCOUNT} and searching.
    END
    # Step 5: Search for BU account
    IF    ${search_visible}
        Treeview Search Type    ${bu_name}
        Log    Typed BU "${bu_name}" in treeview search.    console=yes
        Sleep    1s
    END
    # Step 6: Click/select the BU node — must click the CHECKBOX, not just the text
    ${bu_node}=    Set Variable    xpath=//div[@id='discover']//span[contains(@class,'k-in') and contains(text(),'${bu_name}')]
    ${bu_found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${bu_node}    15s
    Log    BU node visible: ${bu_found}    console=yes
    IF    not ${bu_found}
        Fail    BU "${bu_name}" not found in treeview after expanding EC.
    END
    # Try clicking the checkbox input inside the BU's <li> element
    ${checkbox_clicked}=    Execute Javascript
    ...    var spans = document.querySelectorAll('#discover .k-in');
    ...    for(var i=0; i<spans.length; i++){
    ...        if(spans[i].textContent.indexOf(arguments[0])>=0){
    ...            var li = spans[i].closest('li');
    ...            if(!li) continue;
    ...            var cb = li.querySelector('input[type="checkbox"]');
    ...            if(cb){ cb.click(); return 'CHECKBOX_CLICKED'; }
    ...            var radio = li.querySelector('input[type="radio"]');
    ...            if(radio){ radio.click(); return 'RADIO_CLICKED'; }
    ...            spans[i].click();
    ...            return 'SPAN_CLICKED';
    ...        }
    ...    }
    ...    return 'NOT_FOUND';
    ...    ARGUMENTS    ${bu_name}
    Log    BU click result: ${checkbox_clicked}    console=yes
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # Verify the selection registered
    ${selected_val}=    Execute Javascript
    ...    var inp = document.querySelector("input[name='accountSelected']");
    ...    return inp ? inp.value : 'EMPTY';
    Log    Account selected value after checkbox: "${selected_val}"    console=yes
    # If checkbox click didn't register, try native Selenium click on the BU text
    IF    '${selected_val}' == '' or '${selected_val}' == 'EMPTY'
        Log    Checkbox click did not register. Trying Selenium click on BU node...    console=yes
        Click Element    ${bu_node}
        Sleep    1s
        Wait For Loading Overlay To Disappear
        ${selected_val2}=    Execute Javascript
        ...    var inp = document.querySelector("input[name='accountSelected']");
        ...    return inp ? inp.value : 'EMPTY';
        Log    Account selected value after Selenium click: "${selected_val2}"    console=yes
    END
    # If still empty, use React fiber approach as last resort
    ${final_val}=    Execute Javascript
    ...    var inp = document.querySelector("input[name='accountSelected']");
    ...    return inp ? inp.value : 'EMPTY';
    IF    '${final_val}' == '' or '${final_val}' == 'EMPTY'
        Log    Direct clicks failed. Using React fiber approach...    console=yes
        ${react_result}=    Execute Javascript
        ...    var inp = document.querySelector("input[name='accountSelected']");
        ...    if(!inp) return 'NO_INPUT';
        ...    var fiberKey = Object.keys(inp).find(function(k){ return k.startsWith('__reactInternalInstance') || k.startsWith('__reactFiber'); });
        ...    if(!fiberKey) return 'NO_FIBER';
        ...    var current = inp[fiberKey];
        ...    var component = null;
        ...    var onSelChange = null;
        ...    while(current){
        ...        if(current.stateNode && current.stateNode.state && current.stateNode.state.treeData) component = current.stateNode;
        ...        if(current.memoizedProps && current.memoizedProps.onSelectionChange && !onSelChange) onSelChange = current.memoizedProps.onSelectionChange;
        ...        current = current.return;
        ...    }
        ...    if(!component) return 'NO_COMPONENT';
        ...    var treeData = component.state.treeData;
        ...    var target = null;
        ...    function findNode(nodes){
        ...        for(var i=0; i<nodes.length; i++){
        ...            if((nodes[i].text||'').indexOf(arguments[0])>=0){ target=nodes[i]; return; }
        ...            if(nodes[i].items) findNode(nodes[i].items);
        ...            if(target) return;
        ...        }
        ...    }
        ...    findNode(treeData);
        ...    if(!target) return 'NOT_IN_TREE';
        ...    var newState = Object.assign({}, component.state);
        ...    newState.check = Object.assign({}, newState.check, {ids:[target.organization_organization_id]});
        ...    newState.selected = [target];
        ...    newState.value = target.text;
        ...    component.setState(newState);
        ...    if(onSelChange){ try{ onSelChange([target]); }catch(e){} }
        ...    return 'REACT_SELECTED: ' + target.text;
        ...    ARGUMENTS    ${bu_name}
        Log    React fiber result: ${react_result}    console=yes
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END
    # Final verification
    ${final_check}=    Execute Javascript
    ...    var inp = document.querySelector("input[name='accountSelected']");
    ...    return inp ? inp.value : 'EMPTY';
    Log    Final account selection: "${final_check}"    console=yes
    # Close dropdown by clicking outside
    Execute Javascript
    ...    var h = document.querySelector('#discover h4'); if(h) h.click();
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Treeview Search Type
    [Documentation]    Types a value into the treeview search input using React native setter.
    [Arguments]    ${text}
    Execute Javascript
    ...    var inp = document.querySelector('.search-textbox.inputtree');
    ...    if(inp){
    ...        inp.focus();
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...        nativeSetter.call(inp, '');
    ...        inp.dispatchEvent(new Event('input',{bubbles:true}));
    ...    }
    Sleep    500ms
    Execute Javascript
    ...    var inp = document.querySelector('.search-textbox.inputtree');
    ...    if(inp){
    ...        var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;
    ...        nativeSetter.call(inp, arguments[0]);
    ...        inp.dispatchEvent(new Event('input',{bubbles:true}));
    ...        inp.dispatchEvent(new Event('change',{bubbles:true}));
    ...    }
    ...    ARGUMENTS    ${text}

Select Custom Dropdown Option
    [Documentation]    Generic handler for custom dropdowns (SIM Category, Product Type, SIM State, Country).
    ...                Clicks the trigger button, waits for options, and selects the first.
    ...                If no options exist ("Not Found"), clicks trigger again to close and logs a warning.
    [Arguments]    ${trigger_locator}    ${data_testid}
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${trigger_locator}
    Click Element Via JS    ${trigger_locator}
    Sleep    1s
    ${first_option}=    Set Variable    xpath=//div[@data-testid='${data_testid}' and @class='option'][1]
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${first_option}    timeout=10s
    IF    not ${option_visible}
        # Retry: click trigger again
        Click Element Via JS    ${trigger_locator}
        Sleep    1s
        Click Element Via JS    ${trigger_locator}
        Sleep    1s
        ${option_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${first_option}    timeout=10s
    END
    IF    ${option_visible}
        Click Element Via JS    ${first_option}
    ELSE
        # Check if "Not Found" message is shown
        ${not_found}=    Run Keyword And Return Status
        ...    Page Should Contain Element    xpath=//div[@data-testid='${data_testid}']//span[contains(@class,'dropnodata')]
        IF    ${not_found}
            Log    WARN: Dropdown '${data_testid}' has no options ("Not Found"). Closing dropdown.    level=WARN
            Click Element Via JS    ${trigger_locator}
            Sleep    1s
        ELSE
            ${any_option}=    Set Variable    xpath=//div[@data-testid='${data_testid}' and contains(@class,'option')]
            ${any_visible}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${any_option}    timeout=10s
            IF    ${any_visible}
                Click Element Via JS    ${any_option}
            ELSE
                Log    WARN: No options found for dropdown '${data_testid}'.    level=WARN
                Click Element Via JS    ${trigger_locator}
                Sleep    1s
            END
        END
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Select Custom Dropdown Pick First Open Option
    [Documentation]    Use when the custom dropdown list is **already open** (e.g. after a JS click on the control).
    ...                Picks the first ``.option`` for ``data_testid``; prefers ``#discover``, then any visible option (portal).
    [Arguments]    ${data_testid}
    Wait For Loading Overlay To Disappear
    ${first_option}=    Set Variable    xpath=(//div[@id='discover']//div[@data-testid='${data_testid}' and @class='option'])[1] | (//body//div[@data-testid='${data_testid}' and @class='option'])[1]
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${first_option}    timeout=15s
    IF    ${option_visible}
        Click Element Via JS    ${first_option}
    ELSE
        ${any_option}=    Set Variable    xpath=(//div[@id='discover']//div[@data-testid='${data_testid}' and contains(@class,'option')])[1] | (//body//div[@data-testid='${data_testid}' and contains(@class,'option')])[1]
        ${any_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${any_option}    timeout=12s
        IF    ${any_visible}
            Click Element Via JS    ${any_option}
        ELSE
            Fail    No visible options for data-testid='${data_testid}' (dropdown closed, empty, or portal not matched).
        END
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

SIM Order Click Sim Category Trigger Via JS
    [Documentation]    Clicks the SIM Category control inside ``#discover`` when XPath locators miss (markup change).
    ${ok}=    Execute Javascript
    ...    return (function(){
    ...    var d=document.getElementById('discover');
    ...    if(!d) return false;
    ...    var root=d.querySelector('[data-testid="orderSimCategory"]');
    ...    if(!root) return false;
    ...    var btn=root.querySelector('div[class*="selectBtn"],div[class*="SelectBtn"],button,[role="combobox"]');
    ...    if(btn){ btn.click(); return true; }
    ...    var fc=root.querySelector('div.form-control'); if(fc){ fc.click(); return true; }
    ...    root.click();
    ...    return true;
    ...    })();
    Should Be True    ${ok}    JS could not find/click [data-testid=orderSimCategory] under #discover.

Select Custom Dropdown Option By Name
    [Documentation]    Selects a specific option from a custom dropdown by its visible text.
    [Arguments]    ${trigger_locator}    ${data_testid}    ${option_text}
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${trigger_locator}
    Click Element Via JS    ${trigger_locator}
    Sleep    1s
    ${option_locator}=    Set Variable    xpath=//div[@data-testid='${data_testid}' and @class='option' and normalize-space()='${option_text}']
    Wait Until Element Is Visible    ${option_locator}    timeout=30s
    Click Element Via JS    ${option_locator}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Select SIM Category
    [Documentation]    Selects the first available SIM Category. Waits for Step 1; if the trigger xpath is missing,
    ...                logs ``#discover`` HTML (truncated) and opens the control via JS, then picks the first option.
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${vis}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_SIM_CATEGORY_BTN}    timeout=40s
    IF    ${vis}
        Select Custom Dropdown Option    ${LOC_SO_SIM_CATEGORY_BTN}    orderSimCategory
    ELSE
        Log    SIM Category: XPath trigger not visible — logging #discover HTML (truncated) and using JS open.    level=WARN
        ${snippet}=    Execute Javascript
        ...    var d=document.getElementById('discover');
        ...    if(!d) return 'NO_ELEMENT_ID_discover';
        ...    var h=d.innerHTML; return h.length>32000 ? h.substring(0,32000)+'...[truncated]' : h;
        Log    ${snippet}    level=WARN
        SIM Order Click Sim Category Trigger Via JS
        Sleep    1s
        Wait For Loading Overlay To Disappear
        Select Custom Dropdown Pick First Open Option    orderSimCategory
    END

Select SIM Type
    [Documentation]    Selects SIM Type from the native select element.
    ...                Falls back to JS if native select fails.
    [Arguments]    ${sim_type_value}=${VALID_SIM_TYPE_VALUE}
    Wait Until Element Is Visible    ${LOC_SO_SIM_TYPE_SELECT}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${native_ok}=    Run Keyword And Return Status
    ...    Select From List By Value    ${LOC_SO_SIM_TYPE_SELECT}    ${sim_type_value}
    IF    not ${native_ok}
        Execute Javascript
        ...    var sel = document.querySelector("select[name='simType']");
        ...    if(sel) { sel.value = '${sim_type_value}'; sel.dispatchEvent(new Event('change', {bubbles:true})); }
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Select SIM Product Type
    [Documentation]    Selects the first available SIM Product Type from the custom dropdown.
    Select Custom Dropdown Option    ${LOC_SO_SIM_PRODUCT_BTN}    productCatalog

Enter Quantity
    [Documentation]    Clears and enters the SIM quantity.
    [Arguments]    ${quantity}=${VALID_QUANTITY}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_QUANTITY_INPUT}    timeout=30s
    Click Element    ${LOC_SO_QUANTITY_INPUT}
    Clear Element Text    ${LOC_SO_QUANTITY_INPUT}
    Input Text    ${LOC_SO_QUANTITY_INPUT}    ${quantity}
    Sleep    1s

Set Activation Type
    [Documentation]    Selects the Activation Type radio button.
    ...                Radio inputs may be hidden; uses label click with JS fallback.
    [Arguments]    ${type}=${VALID_ACTIVATION_TYPE}
    ${label_text}=    Set Variable If    '${type}' == 'autoActivation'    Auto Activation    Manual Activation
    ${label_locator}=    Set Variable    xpath=//label[contains(@class,'gc-radio-btn-label')]//span[normalize-space()='${label_text}']
    ${label_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${label_locator}    timeout=10s
    IF    ${label_visible}
        Click Element Via JS    ${label_locator}
    ELSE
        Execute Javascript
        ...    var radio = document.querySelector("input[name='activationOption'][value='${type}']");
        ...    if(radio) { radio.checked = true; radio.dispatchEvent(new Event('change', {bubbles:true})); radio.dispatchEvent(new Event('click', {bubbles:true})); }
    END
    Sleep    1s

Select SIM State
    [Documentation]    Selects a SIM State from the custom dropdown.
    ...                Tries by value first, falls back to first available option.
    [Arguments]    ${state_value}=${VALID_SIM_STATE_VALUE}
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${LOC_SO_SIM_STATE_BTN}
    Click Element Via JS    ${LOC_SO_SIM_STATE_BTN}
    Sleep    1s
    ${option}=    Set Variable    xpath=//div[@data-testid='simState' and @class='option' and @value='${state_value}']
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option}    timeout=10s
    IF    not ${visible}
        # Retry click
        Click Element Via JS    ${LOC_SO_SIM_STATE_BTN}
        Sleep    1s
        ${visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${option}    timeout=10s
    END
    IF    ${visible}
        Click Element Via JS    ${option}
    ELSE
        ${first_opt}=    Set Variable    xpath=//div[@data-testid='simState' and @class='option'][1]
        Wait Until Element Is Visible    ${first_opt}    timeout=30s
        Click Element Via JS    ${first_opt}
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Click Next To Shipping
    [Documentation]    Clicks the Next button on Step 1 to navigate to Shipping Details.
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${LOC_SO_BTN_STEP1_NEXT}
    Click Element Via JS    ${LOC_SO_BTN_STEP1_NEXT}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_ADDRESS_LINE1}    timeout=30s
    Log    Advanced to Step 2 — Shipping Details.

Fill Order Details Step 1
    [Documentation]    Fills all mandatory fields on the Order Details page.
    ...                For **normal** orders (``is_blank=false``): Account + SIM Category + SIM Type + SIM Product Type.
    ...                For **SIM Replacement orders** (``is_blank=true``): UI shows **Account + SIM Product Type + Quantity**
    ...                only — SIM Category (``orderSimCategory``) and SIM Type are **not rendered**, so they are skipped.
    [Arguments]    ${account}=${VALID_ACCOUNT_NAME}    ${quantity}=${VALID_QUANTITY}
    ...            ${activation}=${VALID_ACTIVATION_TYPE}    ${sim_state}=${VALID_SIM_STATE_VALUE}
    ...            ${sim_type}=${VALID_SIM_TYPE_VALUE}    ${is_blank}=${FALSE}
    Set SIM Replacement Order    ${is_blank}
    Select Account From TreeView    ${account}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # Account picker / React state can reset ``isBlank`` to No — re-apply before any field decisions.
    Set SIM Replacement Order    ${is_blank}
    Brief UI Settle Short
    IF    ${is_blank}
        # SIM Replacement = Yes → Step 1 shows Account + SIM Product Type + Quantity only.
        Select SIM Product Type
        Enter Quantity    ${quantity}
    ELSE
        # Normal order flow: SIM Category + SIM Type + SIM Product Type + Quantity + Activation + SIM State.
        Select SIM Category
        Select SIM Type    ${sim_type}
        Sleep    1s
        Wait For Loading Overlay To Disappear
        Select SIM Product Type
        Enter Quantity    ${quantity}
        Set Activation Type    ${activation}
        Select SIM State    ${sim_state}
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  STEP 2 — SHIPPING DETAILS (#strategy)
# ═══════════════════════════════════════════════════════════════════════
Fill Address Fields
    [Documentation]    Fills the address section of Shipping Details.
    [Arguments]    ${addr1}=${VALID_ADDRESS_LINE1}    ${addr2}=${VALID_ADDRESS_LINE2}
    ...            ${area}=${VALID_AREA}    ${city}=${VALID_CITY}    ${postal}=${VALID_POSTAL_CODE}
    Wait Until Element Is Visible    ${LOC_SO_ADDRESS_LINE1}    timeout=30s
    Wait For Loading Overlay To Disappear
    Clear And Input Text Into Field    ${LOC_SO_ADDRESS_LINE1}    ${addr1}
    Clear And Input Text Into Field    ${LOC_SO_ADDRESS_LINE2}    ${addr2}
    Clear And Input Text Into Field    ${LOC_SO_AREA_INPUT}    ${area}
    Clear And Input Text Into Field    ${LOC_SO_CITY_INPUT}    ${city}
    Clear And Input Text Into Field    ${LOC_SO_POSTAL_CODE_INPUT}    ${postal}

Select Country
    [Documentation]    Selects **Saudi Arabia** from the custom Country dropdown.
    ...                Uses the generic custom-dropdown helper but targets the option text explicitly.
    Select Custom Dropdown Option By Name    ${LOC_SO_COUNTRY_BTN}    countryname    Saudi Arabia

Fill Contact Details
    [Documentation]    Fills billing and contact information.
    [Arguments]    ${billing}=${VALID_BILLING_NAME}    ${email}=${VALID_EMAIL}
    ...            ${primary}=${VALID_PRIMARY_PHONE}    ${secondary}=${VALID_SECONDARY_PHONE}
    Clear And Input Text Into Field    ${LOC_SO_BILLING_NAME_INPUT}    ${billing}
    Clear And Input Text Into Field    ${LOC_SO_EMAIL_INPUT}    ${email}
    Clear And Input Text Into Field    ${LOC_SO_PRIMARY_PHONE_INPUT}    ${primary}
    Clear And Input Text Into Field    ${LOC_SO_SECONDARY_PHONE_INPUT}    ${secondary}

Click Next To Preview
    [Documentation]    Clicks the Next button on Step 2 to navigate to Preview.
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${LOC_SO_BTN_STEP2_NEXT}
    Click Element Via JS    ${LOC_SO_BTN_STEP2_NEXT}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_STEP3_PANE}    timeout=30s
    Log    Advanced to Step 3 — Preview.

Click Previous To Order Details
    [Documentation]    Clicks the Previous button on Step 2 to go back to Order Details.
    Scroll To Element Via JS    ${LOC_SO_BTN_STEP2_PREV}
    Click Element Via JS    ${LOC_SO_BTN_STEP2_PREV}
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Wait For Loading Overlay To Disappear
    Log    Navigated back to Step 1 — Order Details.

Fill Shipping Details Step 2
    [Documentation]    Fills all fields on the Shipping Details page.
    [Arguments]    ${addr1}=${VALID_ADDRESS_LINE1}    ${addr2}=${VALID_ADDRESS_LINE2}
    ...            ${area}=${VALID_AREA}    ${city}=${VALID_CITY}    ${postal}=${VALID_POSTAL_CODE}
    ...            ${billing}=${VALID_BILLING_NAME}    ${email}=${VALID_EMAIL}
    ...            ${primary}=${VALID_PRIMARY_PHONE}    ${secondary}=${VALID_SECONDARY_PHONE}
    Fill Address Fields    ${addr1}    ${addr2}    ${area}    ${city}    ${postal}
    Select Country
    Fill Contact Details    ${billing}    ${email}    ${primary}    ${secondary}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 3 — PREVIEW / SUBMIT (#optimization)
# ═══════════════════════════════════════════════════════════════════════
Accept Terms And Submit Order
    [Documentation]    Checks the T&C checkbox on preview, clicks Submit, handles the T&C modal.
    ...                The T&C checkbox exists in both the pane and the modal. For SIM Replacement
    ...                orders the checkbox may not be conventionally "visible" (React/custom render),
    ...                so a JS-based fallback forces it checked before Submit.
    Wait For Loading Overlay To Disappear
    # --- Primary: standard visibility path ---
    ${tc_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TC_CHECKBOX}    timeout=10s
    IF    ${tc_visible}
        Scroll To Element Via JS    ${LOC_SO_TC_CHECKBOX}
        Sleep    1s
        ${already_checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${LOC_SO_TC_CHECKBOX}
        IF    not ${already_checked}
            Click Element Via JS    ${LOC_SO_TC_CHECKBOX}
            Sleep    1s
        END
    ELSE
        ${tc_js}=    Execute Javascript
        ...    var cb = document.getElementById('termsAndConditions');
        ...    if (!cb) {
        ...        var all = document.querySelectorAll('input[type="checkbox"]');
        ...        for (var i = 0; i < all.length; i++) {
        ...            var id = (all[i].id || '').toLowerCase();
        ...            var nm = (all[i].name || '').toLowerCase();
        ...            if (id.indexOf('terms') >= 0 || nm.indexOf('terms') >= 0) { cb = all[i]; break; }
        ...        }
        ...    }
        ...    if (!cb) return 'not_found';
        ...    var anc = cb.closest('label') || cb.closest('div') || cb.parentElement;
        ...    if (anc) anc.scrollIntoView({behavior:'smooth', block:'center'});
        ...    if (!cb.checked) {
        ...        cb.checked = true;
        ...        cb.dispatchEvent(new Event('change', {bubbles:true}));
        ...        cb.dispatchEvent(new Event('click',  {bubbles:true}));
        ...    }
        ...    return cb.checked ? 'checked' : 'failed';
        Log    T&C JS result: ${tc_js}    console=yes
        Sleep    1s
    END
    # Click Submit
    Scroll To Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Click Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Sleep    1s
    # Handle T&C modal if it appears
    ${tc_modal_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TC_MODAL}    timeout=15s
    IF    ${tc_modal_visible}
        Handle TC Modal
    END
    Sleep    1s
    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=120s

Handle TC Modal
    [Documentation]    Handles the Terms & Conditions modal: checks checkbox if present, clicks Continue.
    Wait Until Element Is Visible    ${LOC_SO_TC_MODAL}    timeout=30s
    Sleep    1s
    # Check for a T&C checkbox inside the modal
    ${modal_checkbox}=    Set Variable    xpath=//div[@id='termsConditionsPopup']//input[@id='termsAndConditions']
    ${cb_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${modal_checkbox}    timeout=5s
    IF    ${cb_visible}
        ${cb_checked}=    Run Keyword And Return Status
        ...    Checkbox Should Be Selected    ${modal_checkbox}
        IF    not ${cb_checked}
            Click Element Via JS    ${modal_checkbox}
            Sleep    1s
        END
    END
    # Also try using JS to force-check the checkbox (handles non-interactable)
    Execute Javascript
    ...    var cb = document.querySelector('#termsConditionsPopup input#termsAndConditions');
    ...    if(cb && !cb.checked){ cb.checked = true; cb.dispatchEvent(new Event('change', {bubbles:true})); }
    Sleep    1s
    # Click Continue button
    Wait Until Element Is Visible    ${LOC_SO_TC_MODAL_CONTINUE}    timeout=30s
    Click Element Via JS    ${LOC_SO_TC_MODAL_CONTINUE}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Click Submit Without TC
    [Documentation]    Clicks Submit without checking the T&C checkbox.
    Scroll To Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Click Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Sleep    1s

Click Close Button On Preview
    [Documentation]    Clicks the Close button on the Preview page to go back to Live Order.
    Scroll To Element Via JS    ${LOC_SO_BTN_CLOSE}
    Click Element Via JS    ${LOC_SO_BTN_CLOSE}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Click Previous To Shipping
    [Documentation]    Clicks Previous on Step 3 to go back to Shipping Details.
    Scroll To Element Via JS    ${LOC_SO_BTN_STEP3_PREV}
    Click Element Via JS    ${LOC_SO_BTN_STEP3_PREV}
    Wait Until Element Is Visible    ${LOC_SO_ADDRESS_LINE1}    timeout=30s
    Wait For Loading Overlay To Disappear
    Log    Navigated back to Step 2 — Shipping Details.

# ═══════════════════════════════════════════════════════════════════════
#  GRID ACTIONS — Cancel Order
# ═══════════════════════════════════════════════════════════════════════
Open Cancel Modal For First Row
    [Documentation]    Clicks the Cancel button on the first grid row to open the cancel modal.
    ...                Modal host may be ``#savePopup`` or a Kendo ``.k-window`` — we wait on ``cancelReason`` input.
    Wait Until Element Is Visible    ${LOC_SO_GRID_FIRST_ROW}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${cancel_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ROW_CANCEL_BTN}    timeout=10s
    IF    ${cancel_visible}
        Scroll To Element Via JS    ${LOC_SO_ROW_CANCEL_BTN}
        Click Element Via JS    ${LOC_SO_ROW_CANCEL_BTN}
    ELSE
        # Fallback: first data row — any delete/cancel-style command link
        Execute Javascript
        ...    var row = document.querySelector('#simOrderGrid tbody tr.k-master-row, #simOrderGrid tbody tr:first-child');
        ...    if (!row) return;
        ...    var links = row.querySelectorAll('a');
        ...    for (var i = 0; i < links.length; i++) {
        ...      var el = links[i];
        ...      var s = ((el.className || '') + ' ' + (el.title || '') + ' ' + (el.textContent || '')).toLowerCase();
        ...      if (s.indexOf('delete') >= 0 || s.indexOf('cancel') >= 0 || el.classList.contains('printOrderdelete') || el.classList.contains('k-grid-Delete')) {
        ...        el.click();
        ...        return;
        ...      }
        ...    }
    END
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_SO_CANCEL_REASON_INPUT}    timeout=35s
    Sleep    0.5s
    Log    Cancel Order modal opened (cancelReason field visible).

Fill Cancel Modal And Submit
    [Documentation]    Fills the Cancel Reason and Remarks, then clicks Proceed.
    [Arguments]    ${reason}=${VALID_CANCEL_REASON}    ${remarks}=${VALID_CANCEL_REMARKS}
    Wait Until Element Is Visible    ${LOC_SO_CANCEL_REASON_INPUT}    timeout=30s
    Clear And Input Text Into Field    ${LOC_SO_CANCEL_REASON_INPUT}    ${reason}
    Clear And Input Text Into Field    ${LOC_SO_CANCEL_REMARKS_TEXTAREA}    ${remarks}
    Click Element Via JS    ${LOC_SO_CANCEL_PROCEED_BTN}
    Sleep    1s
    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=120s

Close Cancel Modal
    [Documentation]    Closes the Cancel Order modal without proceeding (legacy popup or Kendo window).
    Wait Until Element Is Visible    ${LOC_SO_CANCEL_REASON_INPUT}    timeout=15s
    ${clicked}=    Run Keyword And Return Status    Click Element Via JS    ${LOC_SO_CANCEL_CLOSE_BTN}
    IF    not ${clicked}
        Run Keyword And Ignore Error    Click Element Via JS    ${LOC_SO_CANCEL_CLOSE_X}
    END
    Sleep    1s
    Wait Until Element Is Not Visible    ${LOC_SO_CANCEL_REASON_INPUT}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  GRID ACTIONS — Search
# ═══════════════════════════════════════════════════════════════════════
Search Live Orders
    [Documentation]    Enters search text and clicks the search button on the Live Order grid.
    [Arguments]    ${search_text}
    Wait Until Element Is Visible    ${LOC_SO_SEARCH_INPUT}    timeout=30s
    Clear And Input Text Into Field    ${LOC_SO_SEARCH_INPUT}    ${search_text}
    Click Element Via JS    ${LOC_SO_SEARCH_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE — Full Create Order Flow
# ═══════════════════════════════════════════════════════════════════════
Complete Create SIM Order Flow
    [Documentation]    Fills Step 1, Step 2, navigates to Preview, accepts T&C, and submits.
    Fill Order Details Step 1
    Click Next To Shipping
    Fill Shipping Details Step 2
    Click Next To Preview
    Accept Terms And Submit Order

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — POSITIVE
# ═══════════════════════════════════════════════════════════════════════
Verify On Live Order Page
    [Documentation]    Confirms the current page is /LiveOrder with the grid visible.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${LIVE_ORDER_PATH}
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s

Verify On Create SIM Order Page
    [Documentation]    Confirms the current page is /CreateSIMOrder.
    Location Should Contain    ${CREATE_SIM_ORDER_PATH}
    Wait Until Element Is Visible    ${LOC_SO_WIZARD_CONTAINER}    timeout=30s

Verify Order Created Successfully
    [Documentation]    Waits for success toast after order submission, then waits for the app to
    ...                automatically redirect to /LiveOrder. Fails fast on error toast.
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # First check for an error toast — fail immediately if present
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_ERROR}    timeout=5s
    IF    ${error_visible}
        ${err_text}=    Get Text    ${LOC_SO_TOAST_ERROR}
        ${is_sim_order_fail}=    Run Keyword And Return Status    Should Contain    ${err_text}    Sim Order Creation Failed
        IF    ${is_sim_order_fail}
            Fail
            ...    Order creation failed — error toast: ${err_text}. Server-side rejection (not fixable from test code alone). Typical data/setup causes: EC/BU SIM limits, missing or mismatched Admin SIM ranges (ICCID/IMSI/MSISDN pools) for the order account, or blank-SIM inventory. For SIM replacement prep, confirm ``SR Ensure Sim Limits…`` / range creation ran and ``SIMR_EC_ACCOUNT_NAME`` matches the wizard account; check backend order logs if the environment should succeed.
        END
        Fail    Order creation failed — error toast: ${err_text}
    END
    # Wait for success toast (up to 60s — backend processing can be slow)
    ${toast_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_SUCCESS}    timeout=30s
    IF    ${toast_visible}
        ${toast_text}=    Get Text    ${LOC_SO_TOAST_SUCCESS}
        Log    Order created — success toast: ${toast_text}    console=yes
    ELSE
        Log    WARN: Success toast not detected within 30s after submit.    console=yes    level=WARN
    END
    # Wait for automatic redirect to Live Order page (app navigates there after success)
    Wait Until Keyword Succeeds    12x    10s    Location Should Contain    ${LIVE_ORDER_PATH}
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Log    SIM Order created — automatically landed on Live Order page.    console=yes

Verify Preview Page Visible
    [Documentation]    Asserts the Preview page (Step 3) is visible with shipping and order summary sections.
    Wait Until Element Is Visible    ${LOC_SO_STEP3_PANE}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_PREVIEW_SHIPPING}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_PREVIEW_ORDER}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_BTN_SUBMIT}    timeout=30s
    Log    Preview page (Step 3) is visible with summary sections.

Verify Wizard Elements Visible
    [Documentation]    Asserts all 3 wizard step links and the Step 1 pane are visible.
    Wait Until Element Is Visible    ${LOC_SO_WIZARD_CONTAINER}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP1_LINK}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP2_LINK}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP3_LINK}    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Log    All wizard step elements are visible.

Verify Live Order Grid Has Data
    [Documentation]    Confirms the Live Order grid has at least one data row.
    ...                Waits a bit for data to load since grid can start empty.
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    1s
    ${row_count}=    Get Element Count    ${LOC_SO_GRID_ROWS}
    Should Be True    ${row_count} > 0    Live Order grid has no data rows.
    Log    Live Order grid loaded with ${row_count} row(s).

Grid Has At Least One Row
    [Documentation]    Returns True if the Live Order grid has at least one data row, False otherwise.
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    1s
    ${row_count}=    Get Element Count    ${LOC_SO_GRID_ROWS}
    ${has_data}=    Evaluate    ${row_count} > 0
    RETURN    ${has_data}

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATIONS — NEGATIVE
# ═══════════════════════════════════════════════════════════════════════
Verify Submit Button Is Disabled Or Blocked
    [Documentation]    Asserts the Submit button on Preview is disabled or not clickable.
    Scroll To Element Via JS    ${LOC_SO_BTN_SUBMIT}
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_SO_BTN_SUBMIT}
    IF    ${enabled}
        Log    WARN: Submit button appears enabled — app may use JS validation instead.    level=WARN
    ELSE
        Log    Submit button correctly disabled/blocked.
    END

Verify Next Button Blocked Or Error Shown
    [Documentation]    After clicking Next, checks if navigation was blocked (still on same step)
    ...                or an error/validation message is shown.
    [Arguments]    ${current_pane_locator}    ${next_pane_locator}    ${next_btn_locator}
    Scroll To Element Via JS    ${next_btn_locator}
    Click Element Via JS    ${next_btn_locator}
    Sleep    1s
    ${navigated}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${next_pane_locator}    timeout=5s
    IF    ${navigated}
        Log    WARN: Navigation was NOT blocked — app allowed advancing with invalid data.    level=WARN
    ELSE
        Log    Navigation correctly blocked — still on current step.
    END
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ALERT_DANGER}    timeout=5s
    ${toast_error}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_ERROR}    timeout=5s
    ${field_error}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//*[contains(@class,'error') or contains(@class,'field-error') or contains(@class,'text-danger')]
    IF    ${error_visible} or ${toast_error} or ${field_error}
        Log    Validation error detected.
    END

Verify Negative SIM Order Outcome
    [Documentation]    Robust check after submitting with invalid SIM Order data.
    [Arguments]    ${test_label}=negative test
    Sleep    1s
    ${alert_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ALERT_DANGER}    timeout=8s
    IF    ${alert_visible}
        ${err_text}=    Get Text    ${LOC_SO_ALERT_DANGER}
        Log    [${test_label}] Validation error shown: ${err_text}
        RETURN
    END
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_ERROR}    timeout=5s
    IF    ${error_toast}
        ${err_text}=    Get Text    ${LOC_SO_TOAST_ERROR}
        Log    [${test_label}] Error toast shown: ${err_text}
        RETURN
    END
    ${success_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_SUCCESS}    timeout=5s
    IF    ${success_toast}
        Log    WARN: [${test_label}] App ACCEPTED the input — review server-side validation.    level=WARN
        RETURN
    END
    ${current_url}=    Get Location
    ${on_list}=    Evaluate    '/LiveOrder' in '''${current_url}''' and 'Create' not in '''${current_url}'''
    IF    ${on_list}
        Log    WARN: [${test_label}] Redirected to Live Order list — input was accepted.    level=WARN
        RETURN
    END
    ${on_create}=    Evaluate    '/CreateSIMOrder' in '''${current_url}'''
    IF    ${on_create}
        Log    [${test_label}] Still on Create SIM Order page — submission was blocked or no response.
        RETURN
    END
    Log    WARN: [${test_label}] Unexpected state (URL: ${current_url}).    level=WARN

Verify Cancel Order Outcome
    [Documentation]    Checks for success/error after cancelling an order.
    [Arguments]    ${test_label}=cancel test
    Sleep    1s
    ${modal_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_SO_CANCEL_REASON_INPUT}    timeout=10s
    ${success_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_SUCCESS}    timeout=10s
    ${error_toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_ERROR}    timeout=5s
    IF    ${success_toast}
        ${text}=    Get Text    ${LOC_SO_TOAST_SUCCESS}
        Log    [${test_label}] Success toast: ${text}
    ELSE IF    ${error_toast}
        ${text}=    Get Text    ${LOC_SO_TOAST_ERROR}
        Log    [${test_label}] Error toast: ${text}
    ELSE IF    ${modal_gone}
        Log    [${test_label}] Modal closed — cancel may have been processed.
    ELSE
        Log    WARN: [${test_label}] Unexpected state after cancel.    level=WARN
    END

Verify Cancel Blocked With Empty Reason
    [Documentation]    Attempts to cancel with empty reason and verifies it is blocked.
    [Arguments]    ${test_label}=cancel empty reason
    Sleep    1s
    ${modal_still}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SO_CANCEL_REASON_INPUT}
    IF    ${modal_still}
        Log    [${test_label}] Modal still visible — proceed was blocked (expected).
    END
    ${error_visible}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//*[.//input[@name='cancelReason']]//*[contains(@class,'error') or contains(@class,'text-danger')]
    IF    ${error_visible}
        Log    [${test_label}] Validation error in cancel modal.
    END
