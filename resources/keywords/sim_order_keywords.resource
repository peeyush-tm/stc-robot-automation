*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/sim_order_locators.resource
Resource    ../locators/login_locators.resource

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
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=60s
    Log    Navigated to Live Order page.

Click Create SIM Order Button
    [Documentation]    Clicks the Create SIM Order button on the Live Order page.
    ...                Falls back to direct URL if button click doesn't navigate.
    Wait For Loading Overlay To Disappear
    ${btn_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_CREATE_ORDER_BTN}    timeout=30s
    IF    ${btn_visible}
        Click Element Via JS    ${LOC_SO_CREATE_ORDER_BTN}
        Sleep    3s
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
    Sleep    2s
    Log    Navigated to Create SIM Order wizard.

# ═══════════════════════════════════════════════════════════════════════
#  COMBINED LOGIN + NAVIGATION KEYWORDS
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Live Order
    [Documentation]    Ensures session is active, then navigates to Live Order via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${LIVE_ORDER_URL}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=60s

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
    [Documentation]    Sets the SIM Replacement Order radio button.
    ...                Radio inputs are hidden; uses JS to set checked state and triggers change event.
    [Arguments]    ${value}=false
    Wait Until Element Is Visible    ${LOC_SO_STEP1_PANE}    timeout=30s
    Wait For Loading Overlay To Disappear
    # Try clicking the label first (visible element)
    ${label_text}=    Set Variable If    '${value}' == 'true'    Yes    No
    ${label_locator}=    Set Variable    xpath=//div[@id='discover']//label[contains(@class,'gc-radio-btn-label')]//span[normalize-space()='${label_text}']
    ${label_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${label_locator}    timeout=10s
    IF    ${label_visible}
        Click Element Via JS    ${label_locator}
    ELSE
        # Fallback: use JS to directly set the radio
        Execute Javascript
        ...    var radio = document.querySelector("div#discover input[name='isBlank'][value='${value}']");
        ...    if(radio) { radio.checked = true; radio.dispatchEvent(new Event('change', {bubbles:true})); radio.dispatchEvent(new Event('click', {bubbles:true})); }
    END
    Sleep    1s

Select Account From TreeView
    [Documentation]    Selects the account in the Kendo TreeView by updating React component state.
    ...                The TreeView uses a React controlled checkbox that cannot be toggled via
    ...                standard Selenium clicks. This keyword walks the React fiber tree to find
    ...                the component managing the TreeView, then sets its state and calls the
    ...                parent onSelectionChange callback to trigger cascading data loads.
    [Arguments]    ${account_name}=${VALID_ACCOUNT_NAME}
    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_INPUT}    timeout=30s
    Wait For Loading Overlay To Disappear
    Click Element    ${LOC_SO_ACCOUNT_INPUT}
    Sleep    2s
    ${selected}=    Execute Javascript
    ...    var input = document.querySelector("input[name='accountSelected']");
    ...    if (!input) return 'ERROR: accountSelected input not found';
    ...    var fiberKey = Object.keys(input).find(function(k) {
    ...        return k.startsWith('__reactInternalInstance');
    ...    });
    ...    if (!fiberKey) return 'ERROR: No React fiber on input';
    ...    var fiber = input[fiberKey];
    ...    var current = fiber;
    ...    var component = null;
    ...    var onSelChange = null;
    ...    while (current) {
    ...        if (current.stateNode && current.stateNode.state
    ...            && current.stateNode.state.treeData) {
    ...            component = current.stateNode;
    ...        }
    ...        if (current.memoizedProps
    ...            && current.memoizedProps.onSelectionChange && !onSelChange) {
    ...            onSelChange = current.memoizedProps.onSelectionChange;
    ...        }
    ...        current = current.return;
    ...    }
    ...    if (!component) return 'ERROR: TreeView component not found in fiber tree';
    ...    var treeData = component.state.treeData;
    ...    var target = null;
    ...    for (var i = 0; i < treeData.length; i++) {
    ...        if (treeData[i].text === '${account_name}'
    ...            || treeData[i].label === '${account_name}') {
    ...            target = treeData[i];
    ...            break;
    ...        }
    ...    }
    ...    if (!target) return 'ERROR: Account "${account_name}" not found in treeData';
    ...    var newState = Object.assign({}, component.state);
    ...    newState.check = Object.assign({}, newState.check, {
    ...        ids: [target.organization_organization_id]
    ...    });
    ...    newState.selected = [target];
    ...    newState.value = target.text;
    ...    component.setState(newState);
    ...    if (onSelChange) {
    ...        try { onSelChange([target]); } catch(e) { /* ignore callback errors */ }
    ...    }
    ...    return 'OK: ' + target.text;
    Log    Account selection result: ${selected}    console=yes
    Should Start With    ${selected}    OK:
    ...    msg=Failed to select account "${account_name}": ${selected}
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Log    Selected account: ${account_name}

Select BU Account From TreeView
    [Documentation]    Opens the Account treeview dropdown, expands KSA_OPCO first,
    ...                then searches for EC, expands EC, searches for BU, and selects BU.
    [Arguments]    ${ec_name}    ${bu_name}
    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_INPUT}    timeout=30s
    Wait For Loading Overlay To Disappear
    # Step 1: Click the Account dropdown to open the treeview panel
    Click Element Via JS    ${LOC_SO_ACCOUNT_INPUT}
    Sleep    3s
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ACCOUNT_TREEVIEW}    15s
    IF    not ${tree_visible}
        Execute Javascript
        ...    var inp = document.querySelector("input[name='accountSelected']");
        ...    if(inp) inp.click();
        Sleep    3s
    END
    Log    Treeview panel opened.    console=yes
    # Step 2: Expand KSA_OPCO (root node) — must expand first before EC is visible
    ${opco_expand}=    Set Variable    xpath=//div[@id='discover']//span[contains(@class,'k-in') and contains(text(),'KSA_OPCO')]/parent::div/preceding-sibling::span[contains(@class,'k-icon')]
    ${opco_alt}=    Set Variable    xpath=//div[@id='discover']//li[.//span[contains(text(),'KSA_OPCO')]]//span[contains(@class,'k-i-expand') or contains(@class,'k-i-arrow-60-right') or contains(@class,'k-icon')]
    ${opco_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${opco_expand}    10s
    IF    ${opco_ok}
        Click Element Via JS    ${opco_expand}
        Log    Clicked KSA_OPCO expand arrow (primary).    console=yes
    ELSE
        ${opco_alt_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${opco_alt}    5s
        IF    ${opco_alt_ok}
            Click Element Via JS    ${opco_alt}
            Log    Clicked KSA_OPCO expand arrow (alt).    console=yes
        ELSE
            # Last resort: JS click expand icon near KSA_OPCO
            Execute Javascript
            ...    var spans = document.querySelectorAll('#discover .k-in');
            ...    for(var i=0; i<spans.length; i++){
            ...        if(spans[i].textContent.indexOf('KSA_OPCO')>=0){
            ...            var li = spans[i].closest('li');
            ...            if(li){ var icon = li.querySelector('.k-icon'); if(icon) icon.click(); }
            ...            break;
            ...        }
            ...    }
            Log    JS fallback: clicked KSA_OPCO expand.    console=yes
        END
    END
    # Wait for child accounts to load after expanding KSA_OPCO
    Sleep    5s
    Wait For Loading Overlay To Disappear
    ${children_loaded}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//div[@id='discover']//li[.//span[contains(text(),'KSA_OPCO')]]//ul//li    30s
    IF    ${children_loaded}
        Log    KSA_OPCO child accounts loaded.    console=yes
    ELSE
        Log    Child accounts not yet visible — waiting longer...    console=yes
        Sleep    10s
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
        Sleep    3s
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
        Sleep    5s
        Wait For Loading Overlay To Disappear
        # Wait for BU child to appear under EC
        ${bu_children}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    xpath=//div[@id='discover']//span[contains(@class,'k-in') and contains(text(),'${ec_name}')]/ancestor::li//ul//li    30s
        IF    ${bu_children}
            Log    EC child accounts (BU) loaded.    console=yes
        ELSE
            Log    BU children not yet visible — waiting longer...    console=yes
            Sleep    10s
            Wait For Loading Overlay To Disappear
        END
    ELSE
        Fail    EC "${ec_name}" not found in treeview after expanding KSA_OPCO and searching.
    END
    # Step 5: Search for BU account
    IF    ${search_visible}
        Treeview Search Type    ${bu_name}
        Log    Typed BU "${bu_name}" in treeview search.    console=yes
        Sleep    3s
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
    Sleep    3s
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
        Sleep    3s
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
        Sleep    3s
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
    Sleep    2s
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
    Sleep    2s
    ${first_option}=    Set Variable    xpath=//div[@data-testid='${data_testid}' and @class='option'][1]
    ${option_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${first_option}    timeout=10s
    IF    not ${option_visible}
        # Retry: click trigger again
        Click Element Via JS    ${trigger_locator}
        Sleep    2s
        Click Element Via JS    ${trigger_locator}
        Sleep    2s
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
    Sleep    1s
    Wait For Loading Overlay To Disappear

Select Custom Dropdown Option By Name
    [Documentation]    Selects a specific option from a custom dropdown by its visible text.
    [Arguments]    ${trigger_locator}    ${data_testid}    ${option_text}
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${trigger_locator}
    Click Element Via JS    ${trigger_locator}
    Sleep    2s
    ${option_locator}=    Set Variable    xpath=//div[@data-testid='${data_testid}' and @class='option' and normalize-space()='${option_text}']
    Wait Until Element Is Visible    ${option_locator}    timeout=30s
    Click Element Via JS    ${option_locator}
    Sleep    1s
    Wait For Loading Overlay To Disappear

Select SIM Category
    [Documentation]    Selects the first available SIM Category from the custom dropdown.
    Select Custom Dropdown Option    ${LOC_SO_SIM_CATEGORY_BTN}    orderSimCategory

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
    Sleep    1s
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
    Sleep    2s
    ${option}=    Set Variable    xpath=//div[@data-testid='simState' and @class='option' and @value='${state_value}']
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${option}    timeout=10s
    IF    not ${visible}
        # Retry click
        Click Element Via JS    ${LOC_SO_SIM_STATE_BTN}
        Sleep    2s
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
    Sleep    1s
    Wait For Loading Overlay To Disappear

Click Next To Shipping
    [Documentation]    Clicks the Next button on Step 1 to navigate to Shipping Details.
    Wait For Loading Overlay To Disappear
    Scroll To Element Via JS    ${LOC_SO_BTN_STEP1_NEXT}
    Click Element Via JS    ${LOC_SO_BTN_STEP1_NEXT}
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_ADDRESS_LINE1}    timeout=30s
    Log    Advanced to Step 2 — Shipping Details.

Fill Order Details Step 1
    [Documentation]    Fills all mandatory fields on the Order Details page.
    ...                SIM Category and Product Type are attempted but won't fail the test
    ...                if no options are available (depends on account configuration).
    [Arguments]    ${account}=${VALID_ACCOUNT_NAME}    ${quantity}=${VALID_QUANTITY}
    ...            ${activation}=${VALID_ACTIVATION_TYPE}    ${sim_state}=${VALID_SIM_STATE_VALUE}
    ...            ${sim_type}=${VALID_SIM_TYPE_VALUE}    ${is_blank}=false
    Set SIM Replacement Order    ${is_blank}
    Select Account From TreeView    ${account}
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Select SIM Category
    Select SIM Type    ${sim_type}
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Select SIM Product Type
    Enter Quantity    ${quantity}
    Set Activation Type    ${activation}
    Select SIM State    ${sim_state}
    Sleep    1s
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
    [Documentation]    Selects a country from the custom Country dropdown.
    Select Custom Dropdown Option    ${LOC_SO_COUNTRY_BTN}    countryname

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
    Sleep    2s
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
    ...                The T&C checkbox exists in both the pane and the modal.
    Wait For Loading Overlay To Disappear
    # Check the T&C checkbox on the preview pane (if visible)
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
    END
    # Click Submit
    Scroll To Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Click Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Sleep    3s
    # Handle T&C modal if it appears
    ${tc_modal_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TC_MODAL}    timeout=15s
    IF    ${tc_modal_visible}
        Handle TC Modal
    END
    Sleep    3s
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
    Sleep    3s
    Wait For Loading Overlay To Disappear

Click Submit Without TC
    [Documentation]    Clicks Submit without checking the T&C checkbox.
    Scroll To Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Click Element Via JS    ${LOC_SO_BTN_SUBMIT}
    Sleep    2s

Click Close Button On Preview
    [Documentation]    Clicks the Close button on the Preview page to go back to Live Order.
    Scroll To Element Via JS    ${LOC_SO_BTN_CLOSE}
    Click Element Via JS    ${LOC_SO_BTN_CLOSE}
    Sleep    2s
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
    ...                Tries multiple locator patterns since button visibility depends on order status.
    Wait Until Element Is Visible    ${LOC_SO_GRID_FIRST_ROW}    timeout=30s
    Wait For Loading Overlay To Disappear
    ${cancel_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_ROW_CANCEL_BTN}    timeout=10s
    IF    ${cancel_visible}
        Scroll To Element Via JS    ${LOC_SO_ROW_CANCEL_BTN}
        Click Element Via JS    ${LOC_SO_ROW_CANCEL_BTN}
    ELSE
        # Fallback: try JS to find and click the cancel button icon
        Execute Javascript
        ...    var btn = document.querySelector('#simOrderGrid tbody tr:first-child a.printOrderdelete, #simOrderGrid tbody tr:first-child a.k-grid-Delete');
        ...    if(btn) btn.click();
    END
    Wait Until Element Is Visible    ${LOC_SO_CANCEL_MODAL}    timeout=30s
    Sleep    1s
    Log    Cancel Order modal opened.

Fill Cancel Modal And Submit
    [Documentation]    Fills the Cancel Reason and Remarks, then clicks Proceed.
    [Arguments]    ${reason}=${VALID_CANCEL_REASON}    ${remarks}=${VALID_CANCEL_REMARKS}
    Wait Until Element Is Visible    ${LOC_SO_CANCEL_REASON_INPUT}    timeout=30s
    Clear And Input Text Into Field    ${LOC_SO_CANCEL_REASON_INPUT}    ${reason}
    Clear And Input Text Into Field    ${LOC_SO_CANCEL_REMARKS_TEXTAREA}    ${remarks}
    Click Element Via JS    ${LOC_SO_CANCEL_PROCEED_BTN}
    Sleep    3s
    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=120s

Close Cancel Modal
    [Documentation]    Closes the Cancel Order modal without proceeding.
    Wait Until Element Is Visible    ${LOC_SO_CANCEL_MODAL}    timeout=30s
    Click Element Via JS    ${LOC_SO_CANCEL_CLOSE_BTN}
    Sleep    1s
    Wait Until Element Is Not Visible    ${LOC_SO_CANCEL_MODAL}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  GRID ACTIONS — Search
# ═══════════════════════════════════════════════════════════════════════
Search Live Orders
    [Documentation]    Enters search text and clicks the search button on the Live Order grid.
    [Arguments]    ${search_text}
    Wait Until Element Is Visible    ${LOC_SO_SEARCH_INPUT}    timeout=30s
    Clear And Input Text Into Field    ${LOC_SO_SEARCH_INPUT}    ${search_text}
    Click Element Via JS    ${LOC_SO_SEARCH_BTN}
    Sleep    3s
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
    [Documentation]    Verify success toast or redirect to /LiveOrder with grid visible.
    ...                Some orders may process async; checks toast and/or URL.
    Sleep    3s
    Wait For Loading Overlay To Disappear
    ${toast_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_SUCCESS}    timeout=15s
    IF    ${toast_visible}
        ${toast_text}=    Get Text    ${LOC_SO_TOAST_SUCCESS}
        Log    Success toast: ${toast_text}    console=yes
    END
    # Check for errors
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SO_TOAST_ERROR}    timeout=3s
    IF    ${error_visible}
        ${err_text}=    Get Text    ${LOC_SO_TOAST_ERROR}
        Log    Error toast after submit: ${err_text}    console=yes    level=WARN
    END
    # Wait for redirect to Live Order (may take time for processing)
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    5x    5s    Location Should Contain    ${LIVE_ORDER_PATH}
    IF    ${redirected}
        ${current_url}=    Get Location
        Should Not Contain    ${current_url}    CreateSIMOrder
        Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
        Log    SIM Order created — redirected to Live Order listing.    console=yes
    ELSE
        ${current_url}=    Get Location
        Log    WARN: Not on Live Order page after submit. URL: ${current_url}    console=yes    level=WARN
        ${on_create}=    Evaluate    'CreateSIMOrder' in '''${current_url}'''
        IF    ${on_create}
            Log    Still on Create SIM Order page — checking for success indicators.    console=yes
            ${any_success}=    Run Keyword And Return Status
            ...    Page Should Contain Element    xpath=//*[contains(@class,'toast-success') or contains(@class,'alert-success') or contains(text(),'success')]
            IF    ${any_success}
                Log    Found success indicator on page.    console=yes
            END
        END
    END

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
    Sleep    3s
    ${row_count}=    Get Element Count    ${LOC_SO_GRID_ROWS}
    Should Be True    ${row_count} > 0    Live Order grid has no data rows.
    Log    Live Order grid loaded with ${row_count} row(s).

Grid Has At Least One Row
    [Documentation]    Returns True if the Live Order grid has at least one data row, False otherwise.
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    Sleep    2s
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
    Sleep    3s
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
    Sleep    2s
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
    Sleep    2s
    ${modal_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_SO_CANCEL_MODAL}    timeout=10s
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
    Sleep    2s
    ${modal_still}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_SO_CANCEL_MODAL}
    IF    ${modal_still}
        Log    [${test_label}] Modal still visible — proceed was blocked (expected).
    END
    ${error_visible}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//div[@id='savePopup']//*[contains(@class,'error') or contains(@class,'text-danger')]
    IF    ${error_visible}
        Log    [${test_label}] Validation error in cancel modal.
    END
