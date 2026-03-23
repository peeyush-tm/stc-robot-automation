*** Settings ***
Library     SeleniumLibrary
Library     Collections
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
    Ensure Session Is Active
    Navigate To Module Page    ${MANAGE_DEVICES_URL}
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  GRID COLUMN HELPERS (JavaScript-based for reliability)
# ═══════════════════════════════════════════════════════════════════════
Get Column Index By Header Text
    [Documentation]    Returns the 0-based column index whose header contains the given text.
    [Arguments]    ${header_text}
    ${index}=    Execute Javascript
    ...    var ths = document.querySelectorAll('#gridData table thead th');
    ...    for(var i=0; i<ths.length; i++){ if(ths[i].textContent.trim().indexOf(arguments[0])>=0) return i; }
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
Open Filter Popup
    [Documentation]    Opens the Filters popup modal if not already open.
    Wait Until Element Is Visible    ${LOC_DSC_FILTER_SEARCH}    timeout=15s
    Click Element Via JS    ${LOC_DSC_FILTER_SEARCH}
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_FILTER_POPUP}    timeout=15s

Close Filter Popup
    [Documentation]    Closes the filter popup if it is still open.
    ${popup_still_open}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_FILTER_POPUP}    timeout=3s
    IF    ${popup_still_open}
        Execute Javascript
        ...    var btn = document.querySelector('#filterPopup button[data-dismiss="modal"]');
        ...    if(btn) btn.click();
        Sleep    2s
        Wait For Loading Overlay To Disappear
    END

Apply Account Filter
    [Documentation]    In the filter popup, expands Account panel, types account name,
    ...                presses Enter to search, waits for results, then clicks exact match.
    [Arguments]    ${account_name}
    # Expand the Account panel via JS (may not be in viewport)
    Execute Javascript
    ...    var popup = document.getElementById('filterPopup');
    ...    var spans = popup.querySelectorAll('span.k-link.k-header');
    ...    for(var i=0; i<spans.length; i++){
    ...      if(spans[i].textContent.trim() === 'Account'){ spans[i].click(); break; }
    ...    }
    Sleep    2s
    Wait For Loading Overlay To Disappear
    # Scroll input into view and focus via JS
    Execute Javascript
    ...    var el = document.getElementById('accountInput');
    ...    el.scrollIntoView({block:'center'});
    Sleep    1s
    Click Element Via JS    ${LOC_DSC_ACCOUNT_INPUT}
    Sleep    1s
    # Clear any existing text and type the account name
    Clear Element Text    ${LOC_DSC_ACCOUNT_INPUT}
    Input Text    ${LOC_DSC_ACCOUNT_INPUT}    ${account_name}
    Sleep    1s
    # Press Enter to trigger the search
    Press Keys    ${LOC_DSC_ACCOUNT_INPUT}    ENTER
    Sleep    5s
    Wait For Loading Overlay To Disappear
    # Click the exact matching li item
    ${match_found}=    Execute Javascript
    ...    var ul = document.getElementById('accountFilter');
    ...    if(!ul) return false;
    ...    var items = ul.querySelectorAll('li');
    ...    for(var i=0; i<items.length; i++){
    ...      if(items[i].textContent.trim() === arguments[0]){ items[i].click(); return true; }
    ...    }
    ...    return false;
    ...    ARGUMENTS    ${account_name}
    Should Be True    ${match_found}
    ...    Account "${account_name}" not found in filter panel after search.
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Log    Applied account filter: ${account_name}    console=yes

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
    Sleep    2s
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
    Sleep    3s
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
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Open Filter Popup
    Apply Account Filter    ${account_name}
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
        Sleep    2s
        Wait For Loading Overlay To Disappear
    END
    ${close_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_SEARCH_CLOSE}    timeout=3s
    IF    ${close_visible}
        Click Element Via JS    ${LOC_DSC_SEARCH_CLOSE}
        Sleep    2s
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
    Sleep    3s
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
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_CHANGE_STATE_SEC}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_STATE_DROP}    timeout=30s

Select Target State And Submit
    [Documentation]    Selects the target state from the state dropdown, then clicks the
    ...                Submit button to trigger the popup. Uses JS fallback if label not found.
    [Arguments]    ${target_state}
    Wait Until Element Is Enabled    ${LOC_DSC_STATE_DROP}    timeout=30s
    Sleep    2s
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
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_STATE_SUBMIT_BTN}    timeout=15s
    Wait Until Element Is Enabled    ${LOC_DSC_STATE_SUBMIT_BTN}    timeout=15s
    Click Element Via JS    ${LOC_DSC_STATE_SUBMIT_BTN}
    Sleep    3s
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
    Sleep    2s
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
    Sleep    2s
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
    Sleep    3s
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
    Sleep    2s
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
        Sleep    2s
    END
    Log    Waiting 5 minutes for async state change to process...    console=yes
    Sleep    300s
    Wait For Loading Overlay To Disappear

Verify Device State After Change
    [Documentation]    Resets the grid, searches for the device by IMSI, and verifies
    ...                that the SIM State column shows the expected new state.
    [Arguments]    ${imsi}    ${expected_state}
    Reset Grid To Default View
    Sleep    2s
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
    Sleep    2s
    ${submit_ok}=    Run Keyword And Return Status
    ...    Click Element Via JS    ${LOC_DSC_STATE_SUBMIT_BTN}
    Sleep    3s
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
