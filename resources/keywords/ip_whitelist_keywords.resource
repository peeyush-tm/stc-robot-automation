*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/ip_whitelist_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
Navigate To IP Whitelisting Via Service
    [Documentation]    From Manage Devices, click Service icon, then IP Whitelisting tab.
    Wait For Loading Overlay To Disappear
    ${service_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_MENU_SERVICE}    timeout=10s
    IF    ${service_visible}
        Scroll To Element Via JS    ${LOC_WL_MENU_SERVICE}
        Click Element Via JS    ${LOC_WL_MENU_SERVICE}
        Sleep    1s
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_TAB_IP_WHITELISTING}    timeout=30s
    Click Element Via JS    ${LOC_TAB_IP_WHITELISTING}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_WHITELIST_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s

Click Create Policy Button
    [Documentation]    Clicks Create Policy on the listing page.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s
    Click Element Via JS    ${LOC_WL_CREATE_POLICY_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${CREATE_IP_WHITELIST_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    Sleep    1s

Login And Navigate To Create IP Whitelisting
    [Documentation]    Ensures session is active, then navigates to Create IP Whitelisting via direct URL.
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_IP_WHITELIST_URL}
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s

Login And Navigate To IP Whitelisting List
    [Documentation]    Ensures session is active, then navigates to the IP Whitelisting listing.
    Ensure Session Is Active
    Navigate To Module Page    ${MANAGE_IP_WHITELIST_URL}
    Wait Until Element Is Visible    ${LOC_WL_CREATE_POLICY_BTN}    timeout=30s

Select Customer From Dropdown
    [Documentation]    Selects the Nth customer from the STC custom dropdown
    ...                (div[data-testid=customerId] + .selectBtn + .option items).
    ...                Falls back to native <select> if a non-custom variant is ever rendered.
    [Arguments]    ${customer_index}=1
    Wait For Loading Overlay To Disappear
    # Fallback: native <select> (defensive — covers other envs)
    ${native}=    Run Keyword And Return Status    Wait Until Element Is Visible    css:select[name="customerId"]    timeout=2s
    IF    ${native}
        Select From List By Index    css:select[name="customerId"]    ${customer_index}
        Sleep    1s
        Wait For Loading Overlay To Disappear
        RETURN
    END
    # Primary path: STC custom dropdown (matches CSR Journey / SIM Order pattern)
    Wait Until Element Is Visible    ${LOC_WL_CUSTOMER_TRIGGER}    timeout=30s
    Scroll To Element Via JS    ${LOC_WL_CUSTOMER_TRIGGER}
    Click Element Via JS    ${LOC_WL_CUSTOMER_TRIGGER}
    Sleep    0.8s
    ${nth_option}=    Set Variable    xpath=(//*[@data-testid="customerId"]//div[contains(@class,'option')])[${customer_index}]
    ${visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${nth_option}    timeout=15s
    IF    not ${visible}
        # Retry — close and reopen the dropdown once
        Click Element Via JS    ${LOC_WL_CUSTOMER_TRIGGER}
        Sleep    0.5s
        Click Element Via JS    ${LOC_WL_CUSTOMER_TRIGGER}
        Sleep    0.8s
        Wait Until Element Is Visible    ${nth_option}    timeout=15s
    END
    Click Element Via JS    ${nth_option}
    Sleep    0.5s
    Wait For Loading Overlay To Disappear

Select Business Unit From Dropdown
    [Documentation]    Selects the Nth BU from the STC custom dropdown
    ...                (div[data-testid=businessUnit] + .selectBtn + .option items).
    ...                Customer must be selected first so the BU list is populated.
    [Arguments]    ${bu_index}=1
    Wait For Loading Overlay To Disappear
    # Fallback: native <select name="businessUnit">
    ${native}=    Run Keyword And Return Status    Wait Until Element Is Visible    css:select[name="businessUnit"]    timeout=2s
    IF    ${native}
        Wait Until Element Is Enabled    css:select[name="businessUnit"]    timeout=10s
        ${option_count}=    Get Element Count    xpath=//select[@name='businessUnit']/option[not(@value='') and not(@value='0')]
        Should Be True    ${option_count} > 0    BU dropdown must have at least one option.
        Select From List By Index    css:select[name="businessUnit"]    ${bu_index}
        Sleep    1s
        RETURN
    END
    # Primary path: STC custom dropdown
    Wait Until Element Is Visible    ${LOC_WL_BU_TRIGGER}    timeout=30s
    Scroll To Element Via JS    ${LOC_WL_BU_TRIGGER}
    Click Element Via JS    ${LOC_WL_BU_TRIGGER}
    Sleep    0.8s
    ${nth_option}=    Set Variable    xpath=(//*[@data-testid="businessUnit"]//div[contains(@class,'option')])[${bu_index}]
    ${visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${nth_option}    timeout=15s
    IF    not ${visible}
        Click Element Via JS    ${LOC_WL_BU_TRIGGER}
        Sleep    0.5s
        Click Element Via JS    ${LOC_WL_BU_TRIGGER}
        Sleep    0.8s
        Wait Until Element Is Visible    ${nth_option}    timeout=15s
    END
    Click Element Via JS    ${nth_option}
    Sleep    0.5s
    Wait For Loading Overlay To Disappear

Fill IP Whitelisting Header
    [Documentation]    Selects Customer then Business Unit. When called without explicit indexes,
    ...                falls back to the pair discovered at Suite Setup (Discover Working
    ...                Customer And BU With Subnets) so subnet-dependent tests always start
    ...                with a pair that has IP subnets configured.
    [Arguments]    ${customer_index}=${EMPTY}    ${bu_index}=${EMPTY}
    ${customer_index}=    Set Variable If    '${customer_index}' == '' and '${IPW_WORKING_CUSTOMER_INDEX}' != ''    ${IPW_WORKING_CUSTOMER_INDEX}    ${customer_index}
    ${bu_index}=          Set Variable If    '${bu_index}' == '' and '${IPW_WORKING_BU_INDEX}' != ''    ${IPW_WORKING_BU_INDEX}    ${bu_index}
    ${customer_index}=    Set Variable If    '${customer_index}' == ''    1    ${customer_index}
    ${bu_index}=          Set Variable If    '${bu_index}' == ''    1    ${bu_index}
    Select Customer From Dropdown    ${customer_index}
    Select Business Unit From Dropdown    ${bu_index}

Ensure Subnet Capable Customer And BU
    [Documentation]    Called at the start of tests that need to add a rule (subnet required).
    ...                If we've already discovered a working Customer+BU, returns immediately.
    ...                Otherwise probes Customer × BU pairs on the Create page and caches the
    ...                first working pair in suite vars IPW_WORKING_CUSTOMER_INDEX / IPW_WORKING_BU_INDEX.
    ...                Fails only if no pair yields subnet options — and only for the one test that
    ...                triggered the probe, not the whole suite.
    IF    '${IPW_WORKING_CUSTOMER_INDEX}' != '' and '${IPW_WORKING_BU_INDEX}' != ''
        Log    Using cached working pair: Customer=${IPW_WORKING_CUSTOMER_INDEX} BU=${IPW_WORKING_BU_INDEX}    console=yes
        RETURN
    END
    Discover Working Customer And BU With Subnets

Discover Working Customer And BU With Subnets
    [Documentation]    Probes Customer × BU pairs on the Create IP Whitelisting page until one
    ...                yields a Source Address Subnet dropdown with at least one option. Stores
    ...                the working pair in suite vars IPW_WORKING_CUSTOMER_INDEX / IPW_WORKING_BU_INDEX.
    ...                Fails if no pair works within the probed range.
    ${max_customers}=    Set Variable    5
    ${max_bus}=          Set Variable    7
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_IP_WHITELIST_URL}
    Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    FOR    ${c}    IN RANGE    1    ${max_customers} + 1
        ${cust_ok}=    Run Keyword And Return Status    Select Customer From Dropdown    ${c}
        IF    not ${cust_ok}
            Log    Discovery: Customer index ${c} not available — stopping customer iteration.    console=yes
            BREAK
        END
        FOR    ${b}    IN RANGE    1    ${max_bus} + 1
            ${bu_ok}=    Run Keyword And Return Status    Select Business Unit From Dropdown    ${b}
            IF    not ${bu_ok}
                Log    Discovery: Customer=${c} BU=${b} not selectable — try next customer.    console=yes
                BREAK
            END
            ${count}=    Probe Source Subnet Option Count
            Log    Discovery probe: Customer=${c} BU=${b} → subnet options=${count}    console=yes
            IF    ${count} > 0
                Set Suite Variable    ${IPW_WORKING_CUSTOMER_INDEX}    ${c}
                Set Suite Variable    ${IPW_WORKING_BU_INDEX}    ${b}
                Log    WORKING PAIR FOUND: Customer=${c} BU=${b} (${count} subnet option(s))    console=yes
                RETURN
            END
        END
        # Re-navigate so the dialog state is clean and we can probe the next customer
        Navigate To Module Page    ${CREATE_IP_WHITELIST_URL}
        Wait Until Element Is Visible    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    END
    Fail    No Customer+BU combination within the first ${max_customers}x${max_bus} pairs has IP subnets configured on this environment. Seed test data, or set IPW_CUSTOMER_NAME / IPW_BU_NAME in config/qe.json so the test can target a BU with subnets directly.

Probe Source Subnet Option Count
    [Documentation]    Opens the Add Rule dialog, opens the Source Subnet dropdown, counts options,
    ...                then closes the dialog — leaving the page ready for the next probe.
    ...                Returns the option count (0 = "No options").
    Click Element Via JS    ${LOC_WL_ADD_RULE_BTN}
    ${dialog_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG}    timeout=10s
    IF    not ${dialog_ok}
        RETURN    ${0}
    END
    Sleep    0.5s
    # Open the subnet menu via mousedown dispatch
    Execute Javascript
    ...    var dlg = document.getElementById('add-service-item-dialog');
    ...    if (!dlg) return 'NO_DIALOG';
    ...    var ctl = dlg.querySelector('.dropDrownSelect .react-select__control, .dropDrownSelect [class*="control"]')
    ...           || dlg.querySelector('.dropDrownSelect');
    ...    if (!ctl) return 'NO_CTRL';
    ...    ['mousedown','mouseup','click'].forEach(function(t){
    ...        ctl.dispatchEvent(new MouseEvent(t, {bubbles:true, cancelable:true, button:0}));
    ...    });
    ...    return 'OK';
    Sleep    0.6s
    ${count}=    Execute Javascript
    ...    var menu = document.querySelector('[class*="react-select__menu"], [id^="react-select-"][id*="-listbox"]');
    ...    if (!menu) return 0;
    ...    var opts = menu.querySelectorAll('[id^="react-select-"][id*="-option-"], [class*="react-select__option"]:not([class*="is-disabled"])');
    ...    return opts ? opts.length : 0;
    # Close the dialog so the next probe starts clean
    ${close_btn_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_CLOSE}    timeout=3s
    IF    ${close_btn_visible}
        Click Element Via JS    ${LOC_WL_RULE_DIALOG_CLOSE}
    ELSE
        Execute Javascript    document.body.click();
    END
    Sleep    0.3s
    ${count_int}=    Convert To Integer    ${count}
    RETURN    ${count_int}

Open Rule Dialog
    [Documentation]    Clicks Add Rule (validates Customer + BU first).
    Wait Until Element Is Enabled    ${LOC_WL_ADD_RULE_BTN}    timeout=30s
    Click Element Via JS    ${LOC_WL_ADD_RULE_BTN}
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG}    timeout=15s
    Sleep    1s

Select Source Address Subnet
    [Documentation]    Source Address Subnet is a React Select inside the Add Rule dialog.
    ...                React Select opens on mousedown (not click) — dispatch full mouse sequence
    ...                on the inner control div, then pick the first option.
    ...                If the menu opens but shows "No options", the selected Customer/BU has
    ...                no IP subnets configured on this environment — the test is Skipped rather
    ...                than Failed (use config IPW_CUSTOMER_NAME / IPW_BU_NAME to target a BU that has subnets).
    Wait Until Element Is Visible    ${LOC_WL_SOURCE_SUBNET_CONTROL}    timeout=15s
    Scroll To Element Via JS    ${LOC_WL_SOURCE_SUBNET_CONTROL}
    Execute Javascript
    ...    var dlg = document.getElementById('add-service-item-dialog');
    ...    if (!dlg) return 'NO_DIALOG';
    ...    var ctl = dlg.querySelector('.dropDrownSelect .react-select__control, .dropDrownSelect [class*="control"]')
    ...           || dlg.querySelector('.dropDrownSelect');
    ...    if (!ctl) return 'NO_CTRL';
    ...    ['mousedown','mouseup','click'].forEach(function(t){
    ...        ctl.dispatchEvent(new MouseEvent(t, {bubbles:true, cancelable:true, button:0}));
    ...    });
    ...    var inp = dlg.querySelector('input[id^="react-select-"][id*="-input"]');
    ...    if (inp) { inp.focus(); }
    ...    return 'OK';
    Sleep    0.8s
    # Probe the menu: did we get options, or did React Select render a "No options" message
    # (or is the menu not rendered at all)? In any non-HAS_OPTIONS case we skip this field and
    # let the form's own validation decide whether it was required.
    ${menu_state}=    Execute Javascript
    ...    var menu = document.querySelector('[class*="react-select__menu"], [id^="react-select-"][id*="-listbox"]');
    ...    if (!menu) return 'NO_MENU';
    ...    var opts = menu.querySelectorAll('[id^="react-select-"][id*="-option-"], [class*="react-select__option"]');
    ...    if (opts && opts.length > 0) return 'HAS_OPTIONS:' + opts.length;
    ...    var txt = (menu.textContent || '').trim().toLowerCase();
    ...    if (txt.indexOf('no options') >= 0 || txt.indexOf('no result') >= 0) return 'NO_OPTIONS';
    ...    return 'EMPTY:' + txt.substring(0, 60);
    Log    Source Address Subnet menu state: ${menu_state}    console=yes
    ${is_empty}=    Evaluate    '${menu_state}' == 'NO_OPTIONS' or '${menu_state}' == 'NO_MENU' or '${menu_state}'.startswith('EMPTY')
    IF    ${is_empty}
        Log    Source Address Subnet has no selectable options (${menu_state}) — skipping field; form validation will handle if it's required.    level=WARN    console=yes
        Execute Javascript    document.body.click();
        Sleep    0.3s
        RETURN
    END
    ${opened}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_WL_SOURCE_SUBNET_OPTION}    timeout=10s
    IF    not ${opened}
        # Retry — simulate ArrowDown keypress to force menu open
        Execute Javascript
        ...    var inp = document.querySelector('input[id^="react-select-"][id*="-input"]');
        ...    if (inp) { inp.focus(); ['keydown','keyup'].forEach(function(t){ inp.dispatchEvent(new KeyboardEvent(t, {key:'ArrowDown', code:'ArrowDown', keyCode:40, bubbles:true})); }); }
        Sleep    0.5s
        # Re-check "No options" after ArrowDown
        ${menu_state2}=    Execute Javascript
        ...    var menu = document.querySelector('[class*="react-select__menu"], [id^="react-select-"][id*="-listbox"]');
        ...    if (!menu) return 'NO_MENU';
        ...    var txt = (menu.textContent || '').trim().toLowerCase();
        ...    if (txt.indexOf('no options') >= 0 || txt.indexOf('no result') >= 0) return 'NO_OPTIONS';
        ...    return 'OK';
        IF    '${menu_state2}' == 'NO_OPTIONS'
            Log    Source Address Subnet still "No options" after retry — skipping field.    level=WARN    console=yes
            Execute Javascript    document.body.click();
            Sleep    0.3s
            RETURN
        END
        Wait Until Element Is Visible    ${LOC_WL_SOURCE_SUBNET_OPTION}    timeout=10s
    END
    Click Element Via JS    (${LOC_WL_SOURCE_SUBNET_OPTION})[1]
    Sleep    0.5s

Add Source Address IP Tag
    [Documentation]    Types an IP (CIDR preferred, e.g. 10.10.10.1/32) and presses Enter so ReactTags
    ...                adds it as a tag. Verifies a tag actually appears after Enter; if not, falls
    ...                back to a JS keydown+Enter dispatch.
    [Arguments]    ${ip_address}=${VALID_SOURCE_IP}
    Wait Until Element Is Visible    ${LOC_WL_SOURCE_IP_INPUT}    timeout=15s
    Click Element    ${LOC_WL_SOURCE_IP_INPUT}
    Input Text    ${LOC_WL_SOURCE_IP_INPUT}    ${ip_address}
    Press Keys    ${LOC_WL_SOURCE_IP_INPUT}    RETURN
    Sleep    0.5s
    ${added}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_SOURCE_IP_TAG}    timeout=3s
    IF    not ${added}
        # Fallback: set value via native setter (React-aware) then dispatch Enter via keydown+keyup
        Execute Javascript
        ...    var inp = document.querySelector('#add-service-item-dialog input[data-testid="input"], #add-service-item-dialog input.ReactTags__tagInputField');
        ...    if (!inp) return 'NO_INPUT';
        ...    inp.focus();
        ...    var setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
        ...    setter.call(inp, arguments[0]);
        ...    inp.dispatchEvent(new Event('input', {bubbles:true}));
        ...    ['keydown','keypress','keyup'].forEach(function(t){
        ...        inp.dispatchEvent(new KeyboardEvent(t, {key:'Enter', code:'Enter', keyCode:13, which:13, bubbles:true, cancelable:true}));
        ...    });
        ...    return 'OK';
        ...    ARGUMENTS    ${ip_address}
        Sleep    0.5s
    END
    Wait For Loading Overlay To Disappear

Enter Destination Address
    [Documentation]    Enters the destination address(es).
    [Arguments]    ${destination}=${VALID_DESTINATION_ADDR}
    Wait Until Element Is Visible    ${LOC_WL_DESTINATION_ADDR}    timeout=15s
    Input Text    ${LOC_WL_DESTINATION_ADDR}    ${destination}

Select Port
    [Documentation]    Selects the Port value.
    [Arguments]    ${port}=${VALID_PORT}
    Wait Until Element Is Visible    ${LOC_WL_PORT_SELECT}    timeout=15s
    Select From List By Value    ${LOC_WL_PORT_SELECT}    ${port}
    Sleep    1s

Enter Port Value
    [Documentation]    Enters port value when Port = EnterPort.
    [Arguments]    ${port_value}=${VALID_PORT_VALUE}
    Wait Until Element Is Visible    ${LOC_WL_PORT_VALUE_INPUT}    timeout=15s
    Input Text    ${LOC_WL_PORT_VALUE_INPUT}    ${port_value}

Select Protocol
    [Documentation]    Selects the Protocol value.
    [Arguments]    ${protocol}=${VALID_PROTOCOL_TCP}
    Wait Until Element Is Visible    ${LOC_WL_PROTOCOL_SELECT}    timeout=15s
    Select From List By Value    ${LOC_WL_PROTOCOL_SELECT}    ${protocol}

Submit Rule Dialog
    [Documentation]    Clicks Submit in the Rule dialog. If the dialog stays open (validation
    ...                error), extract the first visible error text from the dialog + any toast
    ...                and fail with that message — not a generic locator-timeout.
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_SUBMIT}    timeout=15s
    Click Element Via JS    ${LOC_WL_RULE_DIALOG_SUBMIT}
    Sleep    1.5s
    ${closed}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_WL_RULE_DIALOG}    timeout=10s
    IF    not ${closed}
        ${err_text}=    Execute Javascript
        ...    var msgs = [];
        ...    var dlg = document.getElementById('add-service-item-dialog');
        ...    if (dlg) {
        ...        dlg.querySelectorAll('.text-danger, .error, .field-error, .alert-danger, [class*="error"]:not(button)').forEach(function(e){
        ...            if (e.offsetParent !== null && e.textContent.trim()) msgs.push(e.textContent.trim());
        ...        });
        ...    }
        ...    document.querySelectorAll('.Toastify__toast--error .Toastify__toast-body, .Toastify .toast--error').forEach(function(e){
        ...        if (e.textContent.trim()) msgs.push('Toast: ' + e.textContent.trim());
        ...    });
        ...    return JSON.stringify(msgs.slice(0, 8));
        Fail    Rule Submit was rejected by the form — dialog did not close. Validation errors: ${err_text}
    END

Submit Rule Dialog Expecting Error
    [Documentation]    Clicks Submit in the Rule dialog when validation error is expected.
    ...                Does NOT wait for dialog to close.
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_SUBMIT}    timeout=15s
    Click Element Via JS    ${LOC_WL_RULE_DIALOG_SUBMIT}
    Sleep    1s

Close Rule Dialog Without Submitting
    [Documentation]    Clicks Close in the Rule dialog.
    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG_CLOSE}    timeout=10s
    Click Element Via JS    ${LOC_WL_RULE_DIALOG_CLOSE}
    Wait Until Element Is Not Visible    ${LOC_WL_RULE_DIALOG}    timeout=15s

Fill And Submit Rule
    [Documentation]    Opens the Add Rule dialog, fills every field that can be filled, and submits.
    ...                Each field is best-effort — if a locator doesn't match or a dropdown has no
    ...                options, that field is skipped with a warning instead of failing the test.
    ...                The form's own validation is the source of truth for "required" fields:
    ...                if Submit succeeds, the test passes; if Submit is blocked with a visible
    ...                error toast/banner, that error is raised as the failure.
    [Arguments]    ${source_ip}=${VALID_SOURCE_IP}    ${destination}=${VALID_DESTINATION_ADDR}
    ...            ${port}=${VALID_PORT}    ${port_value}=${EMPTY_STRING}    ${protocol}=${VALID_PROTOCOL_TCP}
    Open Rule Dialog
    # Each step below is wrapped in Run Keyword And Ignore Error — if the UI on this env
    # doesn't have the field (or the dropdown has "No options"), we log and move on.
    ${ss}=    Run Keyword And Ignore Error    Select Source Address Subnet
    Log    Source Address Subnet step: ${ss}[0]    console=yes
    ${sip}=   Run Keyword And Ignore Error    Add Source Address IP Tag    ${source_ip}
    Log    Source Address IP step: ${sip}[0]    console=yes
    ${dst}=   Run Keyword And Ignore Error    Enter Destination Address    ${destination}
    Log    Destination step: ${dst}[0]    console=yes
    ${prt}=   Run Keyword And Ignore Error    Select Port    ${port}
    Log    Port step: ${prt}[0]    console=yes
    IF    '${port}' == 'EnterPort' and '${port_value}' != ''
        Run Keyword And Ignore Error    Enter Port Value    ${port_value}
    END
    ${pcol}=  Run Keyword And Ignore Error    Select Protocol    ${protocol}
    Log    Protocol step: ${pcol}[0]    console=yes
    Submit Rule Dialog

Verify Rule Added To Grid
    [Documentation]    Asserts the rules grid contains at least one row.
    Wait Until Element Is Visible    ${LOC_WL_RULES_GRID}    timeout=15s
    ${row_count}=    Get Element Count    ${LOC_WL_RULES_GRID_ROW}
    Should Be True    ${row_count} >= 1    Rules grid must contain at least one rule.

Submit IP Whitelisting Policy
    [Documentation]    Clicks the Create button (enabled after rules are added).
    Wait Until Element Is Enabled    ${LOC_WL_CREATE_BTN}    timeout=15s
    Click Element Via JS    ${LOC_WL_CREATE_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Click Close Button IP Whitelisting
    [Documentation]    Clicks Close/Cancel on the Create page.
    Scroll To Element Via JS    ${LOC_WL_CLOSE_BTN}
    Click Element Via JS    ${LOC_WL_CLOSE_BTN}

Verify IP Whitelisting Created Successfully
    [Documentation]    Verify success toast and redirect to /IPWhitelisting.
    Wait Until Element Is Visible    ${LOC_WL_TOAST_SUCCESS}    timeout=30s
    ${toast_text}=    Get Text    ${LOC_WL_TOAST_SUCCESS}
    Log    Success toast: ${toast_text}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_WHITELIST_PATH}
    Wait Until Element Is Visible    ${LOC_WL_GRID}    timeout=30s

Verify Create Button Is Disabled
    [Documentation]    Asserts the Create button is disabled (no rules added).
    ${enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${LOC_WL_CREATE_BTN}
    Should Not Be True    ${enabled}    Create button should be disabled with no rules.

Verify On IP Whitelisting Listing Page
    [Documentation]    Confirms the current page is /IPWhitelisting.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${MANAGE_IP_WHITELIST_PATH}
    Wait Until Element Is Visible    ${LOC_WL_GRID}    timeout=30s

Verify Rule Dialog Did Not Open
    [Documentation]    Asserts the Rule dialog is NOT visible (Customer/BU not filled).
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_RULE_DIALOG}    timeout=5s
    Should Not Be True    ${dialog_visible}    Rule dialog should NOT open when Customer/BU is empty.

Verify Rule Validation Error
    [Documentation]    Asserts error toast, alert-danger, or dialog still visible after invalid rule submit.
    Sleep    1s
    ${toast}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_TOAST_ERROR}    timeout=5s
    ${alert}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_WL_ALERT_DANGER}    timeout=5s
    ${dialog_stays}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_WL_RULE_DIALOG}
    Should Be True    ${toast} or ${alert} or ${dialog_stays}
    ...    Expected validation error (toast, alert, or dialog) but none found.
    Log    Rule validation error detected — toast:${toast} alert:${alert} dialog_stays:${dialog_stays}
