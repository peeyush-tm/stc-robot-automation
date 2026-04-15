*** Settings ***
Library     SeleniumLibrary
Library     Collections
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/device_plan_locators.resource
Resource    ../locators/login_locators.resource
Variables   ../../variables/device_plan_variables.py

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Manage Devices DP
    [Documentation]    Ensures session is active, then navigates to /ManageDevices.
    Ensure Session Is Active
    Navigate To Module Page    ${DP_MANAGE_DEVICES_URL}
    Wait Until Element Is Visible    ${LOC_DP_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s

# ═══════════════════════════════════════════════════════════════════════
#  GRID COLUMN HELPERS (JavaScript-based)
# ═══════════════════════════════════════════════════════════════════════
Get DP Column Index By Header Text
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

Get DP Cell Value By Row And Column
    [Documentation]    Returns text content of a grid cell. row_index is 1-based; col_index is 0-based.
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
Open DP Filter Popup
    [Documentation]    Opens the Filters popup modal.
    Wait Until Element Is Visible    ${LOC_DP_FILTER_SEARCH}    timeout=15s
    Click Element Via JS    ${LOC_DP_FILTER_SEARCH}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DP_FILTER_POPUP}    timeout=15s

Close DP Filter Popup
    [Documentation]    Closes the filter popup if still open.
    ${popup_still_open}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_FILTER_POPUP}    timeout=3s
    IF    ${popup_still_open}
        Execute Javascript
        ...    var btn = document.querySelector('#filterPopup button[data-dismiss="modal"]');
        ...    if(btn) btn.click();
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END

Apply DP Account Filter
    [Documentation]    Expands Account panel, types account name, presses Enter, clicks exact match.
    [Arguments]    ${account_name}
    Execute Javascript
    ...    var popup = document.getElementById('filterPopup');
    ...    var spans = popup.querySelectorAll('span.k-link.k-header');
    ...    for(var i=0; i<spans.length; i++){
    ...      if(spans[i].textContent.trim() === 'Account'){ spans[i].click(); break; }
    ...    }
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Execute Javascript
    ...    var el = document.getElementById('accountInput');
    ...    el.scrollIntoView({block:'center'});
    Sleep    1s
    Click Element Via JS    ${LOC_DP_ACCOUNT_INPUT}
    Sleep    1s
    Clear Element Text    ${LOC_DP_ACCOUNT_INPUT}
    Input Text    ${LOC_DP_ACCOUNT_INPUT}    ${account_name}
    Sleep    1s
    Press Keys    ${LOC_DP_ACCOUNT_INPUT}    ENTER
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
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
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Log    Applied account filter: ${account_name}    console=yes

Apply DP SIM State Filter
    [Documentation]    In the already-open filter popup, expands SIM State panel and clicks the target state.
    [Arguments]    ${filter_label}
    Execute Javascript
    ...    var popup = document.getElementById('filterPopup');
    ...    var spans = popup.querySelectorAll('span.k-link.k-header');
    ...    for(var i=0; i<spans.length; i++){
    ...      if(spans[i].textContent.trim() === 'SIM State'){ spans[i].click(); break; }
    ...    }
    Sleep    1s
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

Filter DP Grid By Account And State
    [Documentation]    Resets grid, opens filter popup, applies Account + SIM State filters,
    ...                closes popup, validates that the filter was applied by checking the
    ...                first row's state, and returns the 0-based row index of first matching device.
    [Arguments]    ${account_name}    ${filter_label}    ${grid_state}=${EMPTY}
    ${effective_state}=    Set Variable If    '${grid_state}' != ''    ${grid_state}    ${filter_label}
    Reset DP Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s
    Open DP Filter Popup
    Apply DP Account Filter    ${account_name}
    Apply DP SIM State Filter    ${filter_label}
    Close DP Filter Popup
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s
    ${state_col}=    Get DP Column Index By Header Text    ${DP_STATE_COLUMN}
    # Validate filter was applied: first row must match expected state
    ${first_row_state}=    Get DP Cell Value By Row And Column    1    ${state_col}
    Log    First row SIM State after filter: "${first_row_state}" (expected: "${effective_state}")    console=yes
    IF    '${first_row_state}' != '${effective_state}'
        Log    Filter may not have been applied. Retrying filter...    level=WARN    console=yes
        Reset DP Grid To Default View
        Sleep    1s
        Wait For Loading Overlay To Disappear
        Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s
        Open DP Filter Popup
        Apply DP Account Filter    ${account_name}
        Sleep    1s
        Apply DP SIM State Filter    ${filter_label}
        Sleep    1s
        Wait For Loading Overlay To Disappear
        Close DP Filter Popup
        Sleep    1s
        Wait For Loading Overlay To Disappear
        Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s
        ${first_row_state_retry}=    Get DP Cell Value By Row And Column    1    ${state_col}
        Log    First row SIM State after retry: "${first_row_state_retry}" (expected: "${effective_state}")    console=yes
        Should Be Equal As Strings    ${first_row_state_retry}    ${effective_state}
        ...    SIM State filter "${effective_state}" was NOT applied successfully. Grid first row shows "${first_row_state_retry}".
    END
    ${row_idx}=    Find DP Row By State Column    ${state_col}    ${effective_state}
    Should Not Be Equal As Integers    ${row_idx}    -1
    ...    No device with SIM State "${effective_state}" found for account "${account_name}" after filter.
    # Additional validation: row_idx should be 0 if filter is working correctly
    IF    ${row_idx} != 0
        Log    WARNING: Expected filtered device at row 0 but found at row ${row_idx}. Filter might not be fully applied.    level=WARN    console=yes
    END
    Log    Found device in "${effective_state}" state at row index ${row_idx} (0-based).    console=yes
    RETURN    ${row_idx}

Find DP Row By State Column
    [Documentation]    Returns 0-based index of first row matching target state, or -1.
    [Arguments]    ${state_col}    ${target_state}
    ${row_idx}=    Execute Javascript
    ...    var rows = document.querySelectorAll('#gridData table tbody tr.k-master-row');
    ...    for(var j=0; j<rows.length; j++){ var cells = rows[j].querySelectorAll('td');
    ...    if(cells[arguments[0]] && cells[arguments[0]].textContent.trim() === arguments[1]) return j; }
    ...    return -1;
    ...    ARGUMENTS    ${state_col}    ${target_state}
    RETURN    ${row_idx}

Reset DP Grid To Default View
    [Documentation]    Resets all grid filters and clears search.
    ${reset_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_RESET_ALL_FILTER}    timeout=3s
    IF    ${reset_visible}
        Click Element Via JS    ${LOC_DP_RESET_ALL_FILTER}
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END
    ${close_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_SEARCH_CLOSE}    timeout=3s
    IF    ${close_visible}
        Click Element Via JS    ${LOC_DP_SEARCH_CLOSE}
        Sleep    1s
        Wait For Loading Overlay To Disappear
    END
    ${normal_btn}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_NORMAL_SEARCH}    timeout=3s
    IF    ${normal_btn}
        Click Element Via JS    ${LOC_DP_NORMAL_SEARCH}
        Sleep    1s
    END

Search DP Device By IMSI
    [Documentation]    Searches for a device by IMSI using the grid search input.
    ...                Uses Input Text + Enter key to trigger proper search.
    [Arguments]    ${imsi}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DP_SEARCH_INPUT}    timeout=30s
    Scroll To Element Via JS    ${LOC_DP_SEARCH_INPUT}
    Click Element Via JS    ${LOC_DP_SEARCH_INPUT}
    Sleep    1s
    Clear Element Text    ${LOC_DP_SEARCH_INPUT}
    Input Text    ${LOC_DP_SEARCH_INPUT}    ${imsi}
    Sleep    1s
    Press Keys    ${LOC_DP_SEARCH_INPUT}    ENTER
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    ${row_count}=    Get Element Count    ${LOC_DP_GRID_ROWS}
    Log    IMSI search for "${imsi}" returned ${row_count} row(s).    console=yes
    Should Be True    ${row_count} > 0
    ...    No device found when searching IMSI "${imsi}" in grid.

# ═══════════════════════════════════════════════════════════════════════
#  DEVICE SELECTION
# ═══════════════════════════════════════════════════════════════════════
Select DP Device By Row Index
    [Documentation]    Clicks the checkbox of the row at the given 0-based index.
    [Arguments]    ${row_idx}
    ${actual_idx}=    Evaluate    ${row_idx} + 1
    ${cb_locator}=    Set Variable    xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[${actual_idx}]//input[contains(@class,'sel')]
    Wait Until Element Is Visible    ${cb_locator}    timeout=15s
    Click Element Via JS    ${cb_locator}
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  CHANGE DEVICE PLAN ACTION
# ═══════════════════════════════════════════════════════════════════════
Select Change Device Plan Action
    [Documentation]    Selects "Change Device Plan" from the action dropdown and waits
    ...                for the changeState section to appear with the plan dropdown.
    Wait Until Element Is Visible    ${LOC_DP_ACTION_FORM}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DP_ACTION_DROP}    timeout=30s
    Select From List By Label    ${LOC_DP_ACTION_DROP}    ${DP_ACTION_LABEL}
    ${element}=    Get WebElement    ${LOC_DP_ACTION_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DP_CHANGE_STATE_SEC}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DP_PLAN_DROP}    timeout=30s

Get Current Device Plan Name
    [Documentation]    Reads the currently selected option text from the plan dropdown.
    ${current_plan}=    Execute Javascript
    ...    var sel = document.querySelector('select[name="changeSelectedValue"]');
    ...    if(sel && sel.selectedIndex >= 0) return sel.options[sel.selectedIndex].text.trim();
    ...    return '';
    RETURN    ${current_plan}

Get Available Device Plan Options
    [Documentation]    Returns the number of device plan options (excluding blank/default).
    ${count}=    Execute Javascript
    ...    var sel = document.querySelector('select[name="changeSelectedValue"]');
    ...    if(!sel) return 0;
    ...    var count = 0;
    ...    for(var i=0; i<sel.options.length; i++){
    ...      if(sel.options[i].value && sel.options[i].value !== '') count++;
    ...    }
    ...    return count;
    RETURN    ${count}

Select Target Device Plan And Get Names
    [Documentation]    Reads the initial device plan (DP1 - first option text at index 0 or the pre-selected),
    ...                then selects a different plan (DP2 - next available option) from the dropdown.
    ...                Returns initial_plan (DP1) and target_plan (DP2).
    Wait Until Element Is Enabled    ${LOC_DP_PLAN_DROP}    timeout=30s
    # Read all option texts to find DP1 (currently assigned) and DP2 (different plan)
    ${plan_info}=    Execute Javascript
    ...    var sel = document.querySelector('select[name="changeSelectedValue"]');
    ...    if(!sel) return JSON.stringify({dp1: '', dp2: '', dp2_idx: -1});
    ...    var options = [];
    ...    for(var i=0; i<sel.options.length; i++){
    ...      if(sel.options[i].value && sel.options[i].value !== '')
    ...        options.push({idx: i, text: sel.options[i].text.trim()});
    ...    }
    ...    if(options.length === 0) return JSON.stringify({dp1: '', dp2: '', dp2_idx: -1});
    ...    var dp1 = options[0].text;
    ...    var dp2 = options.length > 1 ? options[1].text : options[0].text;
    ...    var dp2_idx = options.length > 1 ? options[1].idx : options[0].idx;
    ...    return JSON.stringify({dp1: dp1, dp2: dp2, dp2_idx: dp2_idx});
    ${parsed}=    Evaluate    json.loads('''${plan_info}''')    json
    ${initial_plan}=    Set Variable    ${parsed}[dp1]
    ${target_plan}=    Set Variable    ${parsed}[dp2]
    ${target_idx}=    Set Variable    ${parsed}[dp2_idx]
    Should Not Be Empty    ${target_plan}    No device plans available in dropdown.
    Log    Initial plan (DP1): ${initial_plan}, Target plan (DP2): ${target_plan} (index ${target_idx})    console=yes
    # Select the target plan
    Select From List By Index    ${LOC_DP_PLAN_DROP}    ${target_idx}
    ${element}=    Get WebElement    ${LOC_DP_PLAN_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    # Click Submit Action button to trigger the popup
    Wait Until Element Is Visible    ${LOC_DP_SUBMIT_ACTION_BTN}    timeout=15s
    Wait Until Element Is Enabled    ${LOC_DP_SUBMIT_ACTION_BTN}    timeout=15s
    Click Element Via JS    ${LOC_DP_SUBMIT_ACTION_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    RETURN    ${initial_plan}    ${target_plan}

Select Target Device Plan By Preferred Name
    [Documentation]    Reads the currently selected option as dp1 (the SIM's current plan).
    ...                Then picks dp2 as:
    ...                  1. preferred_dp_name — if provided AND found AND different from dp1.
    ...                  2. Otherwise the first available option that is different from dp1.
    ...                Guarantees dp2 != dp1 so the change is meaningful.
    ...                Returns dp1 (current plan) and dp2 (selected target plan).
    [Arguments]    ${preferred_dp_name}=${EMPTY}
    Wait Until Element Is Enabled    ${LOC_DP_PLAN_DROP}    timeout=30s
    ${plan_info}=    Execute Javascript
    ...    var sel = document.querySelector('select[name="changeSelectedValue"]');
    ...    if(!sel) return JSON.stringify({dp1:'', dp2:'', dp2_idx:-1, found:false});
    ...    var dp1 = sel.options[sel.selectedIndex] ? sel.options[sel.selectedIndex].text.trim() : '';
    ...    var options = [];
    ...    for(var i=0; i<sel.options.length; i++){
    ...      if(sel.options[i].value && sel.options[i].value !== '')
    ...        options.push({idx: i, text: sel.options[i].text.trim()});
    ...    }
    ...    if(options.length === 0) return JSON.stringify({dp1:dp1, dp2:'', dp2_idx:-1, found:false});
    ...    var pref = arguments[0] ? arguments[0].toLowerCase().trim() : '';
    ...    if(pref){
    ...      for(var j=0; j<options.length; j++){
    ...        if(options[j].text.toLowerCase().trim() === pref && options[j].text.trim().toLowerCase() !== dp1.toLowerCase())
    ...          return JSON.stringify({dp1:dp1, dp2:options[j].text, dp2_idx:options[j].idx, found:true});
    ...      }
    ...    }
    ...    for(var k=0; k<options.length; k++){
    ...      if(options[k].text.trim().toLowerCase() !== dp1.toLowerCase())
    ...        return JSON.stringify({dp1:dp1, dp2:options[k].text, dp2_idx:options[k].idx, found:false});
    ...    }
    ...    return JSON.stringify({dp1:dp1, dp2:'', dp2_idx:-1, found:false});
    ...    ARGUMENTS    ${preferred_dp_name}
    ${parsed}=    Evaluate    json.loads('''${plan_info}''')    json
    ${initial_plan}=    Set Variable    ${parsed}[dp1]
    ${target_plan}=    Set Variable    ${parsed}[dp2]
    ${target_idx}=    Set Variable    ${parsed}[dp2_idx]
    ${found}=    Set Variable    ${parsed}[found]
    Should Not Be Empty    ${target_plan}
    ...    No different device plan available. Current plan: "${initial_plan}". Cannot change to the same plan.
    IF    '${preferred_dp_name}' != '${EMPTY}' and not ${found}
        Log    WARN: Preferred DP "${preferred_dp_name}" not found or same as current — auto-picked "${target_plan}" instead.    level=WARN    console=yes
    ELSE IF    ${found}
        Log    Preferred DP "${target_plan}" found and selected (current: "${initial_plan}").    console=yes
    ELSE
        Log    Auto-picked DP: "${initial_plan}" → "${target_plan}" (idx ${target_idx}).    console=yes
    END
    Select From List By Index    ${LOC_DP_PLAN_DROP}    ${target_idx}
    ${element}=    Get WebElement    ${LOC_DP_PLAN_DROP}
    Execute Javascript
    ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DP_SUBMIT_ACTION_BTN}    timeout=15s
    Wait Until Element Is Enabled    ${LOC_DP_SUBMIT_ACTION_BTN}    timeout=15s
    Click Element Via JS    ${LOC_DP_SUBMIT_ACTION_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    RETURN    ${initial_plan}    ${target_plan}

# ═══════════════════════════════════════════════════════════════════════
#  POPUP INTERACTION
# ═══════════════════════════════════════════════════════════════════════
Wait For DP Popup To Open
    [Documentation]    Waits for the savePopup modal to appear after selecting a device plan.
    Wait Until Element Is Visible    ${LOC_DP_POPUP}    timeout=30s

Select DP Reason In Popup
    [Documentation]    Selects the first non-blank reason inside the popup.
    Wait Until Element Is Visible    ${LOC_DP_REASON_DROP}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DP_REASON_DROP}    timeout=30s
    ${option_ok}=    Run Keyword And Return Status
    ...    Select From List By Index    ${LOC_DP_REASON_DROP}    1
    IF    not ${option_ok}
        Select Option By Index Via JS    ${LOC_DP_REASON_DROP}    1
    END
    Sleep    1s

Click DP Proceed Button
    [Documentation]    Clicks the Proceed button inside the popup.
    Wait Until Element Is Visible    ${LOC_DP_PROCEED_BTN}    timeout=30s
    Wait Until Element Is Enabled    ${LOC_DP_PROCEED_BTN}    timeout=30s
    Click Element Via JS    ${LOC_DP_PROCEED_BTN}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear

Close DP Popup Without Submitting
    [Documentation]    Clicks the Close/Cancel button inside the popup.
    Wait Until Element Is Visible    ${LOC_DP_POPUP_CLOSE_BTN}    timeout=15s
    Click Element Via JS    ${LOC_DP_POPUP_CLOSE_BTN}
    Wait Until Element Is Not Visible    ${LOC_DP_POPUP}    timeout=15s

Fill DP Popup And Submit
    [Documentation]    Fills the popup (Reason only for Device Plan action) and clicks Proceed.
    Wait For DP Popup To Open
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Select DP Reason In Popup
    Click DP Proceed Button

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE FLOWS
# ═══════════════════════════════════════════════════════════════════════
Perform Full Device Plan Change
    [Documentation]    End-to-end device plan change: filter by account + SIM state,
    ...                validate initial state, capture IMSI + initial device plan (DP1),
    ...                select device, select "Change Device Plan", pick a different plan (DP2),
    ...                fill popup and submit. Returns IMSI, DP1, and DP2.
    [Arguments]    ${filter_label}    ${from_state}
    ${row_idx}=    Filter DP Grid By Account And State    ${DP_ACCOUNT_NAME}    ${filter_label}    ${from_state}
    ${imsi_col}=    Get DP Column Index By Header Text    ${DP_IMSI_COLUMN}
    ${dp_col}=    Get DP Column Index By Header Text    ${DP_DEVICE_PLAN_COLUMN}
    ${state_col}=    Get DP Column Index By Header Text    ${DP_STATE_COLUMN}
    ${actual_row}=    Evaluate    ${row_idx} + 1
    ${imsi}=    Get DP Cell Value By Row And Column    ${actual_row}    ${imsi_col}
    Should Not Be Empty    ${imsi}    Could not read IMSI from filtered row.
    ${verified_state}=    Get DP Cell Value By Row And Column    ${actual_row}    ${state_col}
    Should Be Equal As Strings    ${verified_state}    ${from_state}
    ...    Initial state mismatch: expected "${from_state}" but grid shows "${verified_state}".
    ${initial_dp_grid}=    Get DP Cell Value By Row And Column    ${actual_row}    ${dp_col}
    Log    IMSI: ${imsi}, State: ${from_state}, Initial Device Plan (grid): ${initial_dp_grid}    console=yes
    Select DP Device By Row Index    ${row_idx}
    Select Change Device Plan Action
    ${dp1}=    Set Variable    ${EMPTY}
    ${dp2}=    Set Variable    ${EMPTY}
    ${dp1}    ${dp2}=    Select Target Device Plan And Get Names
    Log    Changing Device Plan: "${dp1}" -> "${dp2}"    console=yes
    Fill DP Popup And Submit
    RETURN    ${imsi}    ${dp1}    ${dp2}

Perform Full Device Plan Change For IMSI
    [Documentation]    Searches for a specific IMSI in the grid, then performs a full device
    ...                plan change on that row. Preferred_dp: if set, explicitly selects that
    ...                plan (e.g. Step 18 bundle plan) via Select Target Device Plan By Preferred Name.
    ...                Falls back to auto-picking second option if preferred plan is not found.
    ...                Returns imsi, initial_dp_grid, dp2.
    [Arguments]    ${imsi}    ${preferred_dp}=${EMPTY}
    Search DP Device By IMSI    ${imsi}
    ${imsi_col}=    Get DP Column Index By Header Text    ${DP_IMSI_COLUMN}
    ${dp_col}=    Get DP Column Index By Header Text    ${DP_DEVICE_PLAN_COLUMN}
    ${state_col}=    Get DP Column Index By Header Text    ${DP_STATE_COLUMN}
    ${grid_imsi}=    Get DP Cell Value By Row And Column    1    ${imsi_col}
    Should Be Equal As Strings    ${grid_imsi}    ${imsi}
    ...    Grid first row shows IMSI "${grid_imsi}" but expected "${imsi}" — search may not have filtered correctly.
    ${initial_dp_grid}=    Get DP Cell Value By Row And Column    1    ${dp_col}
    ${grid_state}=    Get DP Cell Value By Row And Column    1    ${state_col}
    Log    IMSI: ${imsi}, State: ${grid_state}, Current DP (grid): ${initial_dp_grid}, Preferred DP: "${preferred_dp}"    console=yes
    Select DP Device By Row Index    0
    Select Change Device Plan Action
    ${dp1}=    Set Variable    ${EMPTY}
    ${dp2}=    Set Variable    ${EMPTY}
    ${dp1}    ${dp2}=    Select Target Device Plan By Preferred Name    ${preferred_dp}
    Log    Changing Device Plan: "${initial_dp_grid}" → "${dp2}" (dropdown current: "${dp1}")    console=yes
    Fill DP Popup And Submit
    RETURN    ${imsi}    ${initial_dp_grid}    ${dp2}

Perform Full Device Plan Change For Account
    [Documentation]    Same as Perform Full Device Plan Change but takes account name as argument.
    ...                Accepts optional preferred_dp: if set, Select Target Device Plan By Preferred Name
    ...                is used so the DP from Step 18 is explicitly chosen. Falls back to auto-pick if
    ...                preferred_dp is empty or not found in the dropdown.
    [Arguments]    ${account_name}    ${filter_label}    ${from_state}    ${preferred_dp}=${EMPTY}
    ${row_idx}=    Filter DP Grid By Account And State    ${account_name}    ${filter_label}    ${from_state}
    ${imsi_col}=    Get DP Column Index By Header Text    ${DP_IMSI_COLUMN}
    ${dp_col}=    Get DP Column Index By Header Text    ${DP_DEVICE_PLAN_COLUMN}
    ${state_col}=    Get DP Column Index By Header Text    ${DP_STATE_COLUMN}
    ${actual_row}=    Evaluate    ${row_idx} + 1
    ${imsi}=    Get DP Cell Value By Row And Column    ${actual_row}    ${imsi_col}
    Should Not Be Empty    ${imsi}    Could not read IMSI from filtered row.
    ${verified_state}=    Get DP Cell Value By Row And Column    ${actual_row}    ${state_col}
    Should Be Equal As Strings    ${verified_state}    ${from_state}
    ...    Initial state mismatch: expected "${from_state}" but grid shows "${verified_state}".
    ${initial_dp_grid}=    Get DP Cell Value By Row And Column    ${actual_row}    ${dp_col}
    Log    IMSI: ${imsi}, State: ${from_state}, Current DP (grid): ${initial_dp_grid}, Preferred DP: "${preferred_dp}"    console=yes
    Select DP Device By Row Index    ${row_idx}
    Select Change Device Plan Action
    ${dp1}=    Set Variable    ${EMPTY}
    ${dp2}=    Set Variable    ${EMPTY}
    ${dp1}    ${dp2}=    Select Target Device Plan By Preferred Name    ${preferred_dp}
    Log    Changing Device Plan: "${initial_dp_grid}" → "${dp2}" (dropdown current: "${dp1}")    console=yes
    Fill DP Popup And Submit
    RETURN    ${imsi}    ${initial_dp_grid}    ${dp2}

# ═══════════════════════════════════════════════════════════════════════
#  POST-CHANGE VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify DP Change Success And Wait
    [Documentation]    Checks for success toast, closes popup if still open,
    ...                then waits 5 minutes for async processing.
    ${toast_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_TOAST_SUCCESS}    timeout=30s
    IF    ${toast_ok}
        ${toast_text}=    Get Text    ${LOC_DP_TOAST_SUCCESS}
        Log    Success toast: ${toast_text}    console=yes
    ELSE
        Log    No success toast found within 30s.    level=WARN
    END
    ${popup_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_DP_POPUP}    timeout=15s
    IF    not ${popup_gone}
        ${close_ok}=    Run Keyword And Return Status
        ...    Click Element Via JS    ${LOC_DP_POPUP_X_BTN}
        Sleep    1s
    END
    Log    Waiting 6 minutes for async device plan change to process...    console=yes
    Sleep    360s
    Wait For Loading Overlay To Disappear

Verify Device Plan After Change
    [Documentation]    Resets the grid, searches by IMSI, verifies Device Plan column
    ...                shows the expected new plan (DP2).
    [Arguments]    ${imsi}    ${expected_plan}
    Reset DP Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Search DP Device By IMSI    ${imsi}
    Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s
    ${dp_col}=    Get DP Column Index By Header Text    ${DP_DEVICE_PLAN_COLUMN}
    ${actual_plan}=    Get DP Cell Value By Row And Column    1    ${dp_col}
    Should Be Equal As Strings    ${actual_plan}    ${expected_plan}
    ...    Expected Device Plan "${expected_plan}" but grid shows "${actual_plan}" for IMSI ${imsi}.
    Log    VERIFIED: IMSI ${imsi} Device Plan is now "${actual_plan}".    console=yes

Verify Device Plan Unchanged
    [Documentation]    Verifies that the Device Plan has NOT changed for the given IMSI.
    [Arguments]    ${imsi}    ${expected_plan}
    Reset DP Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Search DP Device By IMSI    ${imsi}
    Wait Until Element Is Visible    ${LOC_DP_GRID_ROWS}    timeout=30s
    ${dp_col}=    Get DP Column Index By Header Text    ${DP_DEVICE_PLAN_COLUMN}
    ${actual_plan}=    Get DP Cell Value By Row And Column    1    ${dp_col}
    Should Be Equal As Strings    ${actual_plan}    ${expected_plan}
    ...    Device Plan should not have changed. Expected "${expected_plan}" but got "${actual_plan}" for IMSI ${imsi}.
    Log    CONFIRMED: IMSI ${imsi} Device Plan unchanged: "${actual_plan}".    console=yes
