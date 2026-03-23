*** Settings ***
Library     SeleniumLibrary
Library     SSHLibrary
Library     DatabaseLibrary
Library     OperatingSystem
Library     String
Library     Collections
Library     RequestsLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    device_state_keywords.resource
Resource    sim_order_keywords.resource
Resource    ../locators/sim_order_locators.resource
Resource    ../locators/device_state_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  ORDER ID CAPTURE — Live Order Grid
# ═══════════════════════════════════════════════════════════════════════
Capture Order Number From Grid
    [Documentation]    Waits for the grid table to load, applies Account column filter,
    ...                waits for filtered rows to appear, then reads Order Number from first row.
    [Arguments]    ${account_name}
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    xpath=//div[@id='simOrderGrid']//table/tbody/tr    timeout=30s
    Sleep    2s
    Filter Grid By Account Column    ${account_name}
    Wait Until Element Is Visible    xpath=//div[@id='simOrderGrid']//table/tbody/tr    timeout=30s
    Sleep    2s
    ${order_number}=    Read Order Number From First Row
    Should Not Be Empty    ${order_number}    No order found for account "${account_name}" after filtering.
    Log    Captured Order Number: "${order_number}" for account "${account_name}"    console=yes
    RETURN    ${order_number}

Filter Grid By Account Column
    [Documentation]    Clicks the Account column filter icon, types account name, applies filter.
    [Arguments]    ${account_name}
    # Click the filter icon on the Account column header
    ${filter_clicked}=    Execute Javascript
    ...    var grid = document.getElementById('simOrderGrid');
    ...    if(!grid) return false;
    ...    var ths = grid.querySelectorAll('thead th');
    ...    for(var i=0; i<ths.length; i++){
    ...        if(ths[i].textContent.trim().toLowerCase() === 'account'){
    ...            var filterBtn = ths[i].querySelector('a.k-grid-filter, a.k-header-column-menu, .k-grid-filter-menu, [data-role="columnmenu"]');
    ...            if(!filterBtn) filterBtn = ths[i].querySelector('a[href*="filter"], a[class*="filter"], span[class*="filter"]');
    ...            if(filterBtn){ filterBtn.click(); return true; }
    ...        }
    ...    }
    ...    return false;
    Log    Account filter icon clicked: ${filter_clicked}    console=yes
    IF    not ${filter_clicked}
        # Fallback: try the filter icon by position (Account is typically 4th column)
        ${icons}=    Execute Javascript
        ...    var grid = document.getElementById('simOrderGrid');
        ...    var filters = grid.querySelectorAll('thead th a.k-grid-filter, thead th a[class*="filter"]');
        ...    return filters.length;
        Log    Total filter icons found: ${icons}    console=yes
        Execute Javascript
        ...    var grid = document.getElementById('simOrderGrid');
        ...    var ths = grid.querySelectorAll('thead th');
        ...    for(var i=0; i<ths.length; i++){
        ...        if(ths[i].textContent.trim().toLowerCase() === 'account'){
        ...            var a = ths[i].querySelector('a');
        ...            if(a) a.click();
        ...            break;
        ...        }
        ...    }
    END
    Sleep    2s
    # Type account name in the filter input
    ${filter_input}=    Set Variable    xpath=//div[contains(@class,'k-filter-menu') or contains(@class,'k-column-menu')]//input[@type='text']
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${filter_input}    10s
    IF    ${input_visible}
        Clear Element Text    ${filter_input}
        Input Text    ${filter_input}    ${account_name}
        Sleep    1s
        # Click the Filter button
        ${filter_btn}=    Set Variable    xpath=//div[contains(@class,'k-filter-menu') or contains(@class,'k-column-menu')]//button[contains(@class,'k-primary') or normalize-space()='Filter']
        ${btn_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${filter_btn}    5s
        IF    ${btn_visible}
            Click Element    ${filter_btn}
        ELSE
            Press Keys    ${filter_input}    ENTER
        END
    ELSE
        Log    Filter popup input not found. Trying search input instead...    console=yes
        Wait Until Element Is Visible    ${LOC_SO_SEARCH_INPUT}    timeout=10s
        Clear Element Text    ${LOC_SO_SEARCH_INPUT}
        Input Text    ${LOC_SO_SEARCH_INPUT}    ${account_name}
        Click Element Via JS    ${LOC_SO_SEARCH_BTN}
    END
    Sleep    5s
    Wait For Loading Overlay To Disappear
    Log    Grid filtered by account: ${account_name}    console=yes

Read Order Number From First Row
    [Documentation]    Reads the Order Number column value from the first visible row.
    ${order_number}=    Execute Javascript
    ...    var grid = document.getElementById('simOrderGrid');
    ...    if(!grid) return '';
    ...    var ths = grid.querySelectorAll('thead th');
    ...    var orderCol = -1;
    ...    for(var i=0; i<ths.length; i++){
    ...        var txt = ths[i].textContent.trim().toLowerCase();
    ...        if(txt.indexOf('order') >= 0 && txt.indexOf('number') >= 0){ orderCol = i; break; }
    ...    }
    ...    var row = grid.querySelector('tbody tr');
    ...    if(!row) return '';
    ...    var cells = row.querySelectorAll('td');
    ...    if(orderCol >= 0 && cells[orderCol]) return cells[orderCol].textContent.trim();
    ...    for(var j=0; j<cells.length && j<5; j++){
    ...        var t = cells[j].textContent.trim();
    ...        if(/^\d+$/.test(t) && t.length >= 3) return t;
    ...    }
    ...    return '';
    Log    First row Order Number: "${order_number}"    console=yes
    RETURN    ${order_number}

# ═══════════════════════════════════════════════════════════════════════
#  DATABASE OPERATIONS
# ═══════════════════════════════════════════════════════════════════════
Connect To STC Database
    [Documentation]    Opens a pymysql connection using credentials from env_config.
    Connect To Database    pymysql    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
    Log    Connected to DB: ${DB_HOST}:${DB_PORT}/${DB_NAME}    console=yes

Fetch Account ID By Name
    [Documentation]    Queries the accounts table for the given name and returns the id.
    [Arguments]    ${account_name}
    ${query}=    Set Variable    SELECT id FROM accounts WHERE name = '${account_name}'
    Log    Executing query: ${query}    console=yes
    ${result}=    Query    ${query}
    ${row_count}=    Get Length    ${result}
    Should Be True    ${row_count} > 0
    ...    No account found with name "${account_name}" in database.
    ${account_id}=    Set Variable    ${result}[0][0]
    Log    Account "${account_name}" → ID: ${account_id}    console=yes
    RETURN    ${account_id}

Disconnect From STC Database
    [Documentation]    Closes the DB connection.
    Disconnect From Database
    Log    DB connection closed.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  SSH SERVER OPERATIONS
# ═══════════════════════════════════════════════════════════════════════
Connect To Order Processing Server
    [Documentation]    Opens SSH connection to the order processing server.
    SSHLibrary.Open Connection    ${SSH_HOST}    timeout=120s
    SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    Log    SSH connected to ${SSH_HOST} as ${SSH_USERNAME}    console=yes

Run Create Order Script On Server
    [Documentation]    Navigates to the SIM Order directory and runs start_createorder.sh as root
    ...                via sudo (password same as SSH user). Uses 'bash' to run the script.
    ...                Returns stdout+stderr and the exit code.
    Log    Running start_createorder.sh on server as root (sudo)...    console=yes
    ${output}    ${stderr}    ${rc}=    SSHLibrary.Execute Command
    ...    cd ${SSH_ORDER_DIR} && echo '${SSH_PASSWORD}' | sudo -S bash start_createorder.sh
    ...    timeout=300s
    ...    return_stdout=True
    ...    return_stderr=True
    ...    return_rc=True
    Log    ===== start_createorder.sh OUTPUT =====    console=yes
    Log    ${output}    console=yes
    ${stderr_len}=    Get Length    ${stderr}
    IF    ${stderr_len} > 0
        Log    ===== start_createorder.sh STDERR =====    console=yes
        Log    ${stderr}    console=yes
    END
    Log    Exit code: ${rc}    console=yes
    RETURN    ${output}    ${rc}

Upload Response File To Server
    [Documentation]    Uploads a local file to the server's order/input directory via SFTP.
    ...                Removes existing file first to ensure overwrite.
    [Arguments]    ${local_path}    ${remote_filename}
    ${remote_path}=    Set Variable    ${SSH_ORDER_INPUT_DIR}/${remote_filename}
    SSHLibrary.Execute Command    rm -f ${remote_path}
    SSHLibrary.Put File    ${local_path}    ${remote_path}    mode=0755
    Log    Uploaded (overwrite): ${remote_filename} → ${remote_path}    console=yes

Verify Files Uploaded On Server
    [Documentation]    Verifies each uploaded file exists on the server immediately after upload.
    ...                Fails if any file is missing.
    [Arguments]    ${order_id}    ${file_pairs}
    ${total}=    Get Length    ${file_pairs}
    ${verified}=    Set Variable    ${0}
    FOR    ${pair}    IN    @{file_pairs}
        ${filename}=    Set Variable    ${pair}[1]
        ${remote_path}=    Set Variable    ${SSH_ORDER_INPUT_DIR}/${filename}
        ${ls_result}=    SSHLibrary.Execute Command    ls -la ${remote_path} 2>&1
        Log    Verify ${filename}: ${ls_result}    console=yes
        Should Contain    ${ls_result}    ${filename}
        ...    msg=File ${filename} NOT found on server after upload! ls output: ${ls_result}
        ${verified}=    Evaluate    ${verified} + 1
        Log    VERIFIED: ${filename} exists on server (${verified}/${total}).    console=yes
    END
    Log    All ${verified}/${total} response files verified on server.    console=yes

Run Read Order Script On Server
    [Documentation]    Navigates to the SIM Order directory and runs start_readorder.sh as root
    ...                via sudo (password same as SSH user). Uses 'bash' to run the script.
    ...                Returns stdout+stderr and the exit code.
    Log    Running start_readorder.sh on server as root (sudo)...    console=yes
    ${output}    ${stderr}    ${rc}=    SSHLibrary.Execute Command
    ...    cd ${SSH_ORDER_DIR} && echo '${SSH_PASSWORD}' | sudo -S bash start_readorder.sh
    ...    timeout=300s
    ...    return_stdout=True
    ...    return_stderr=True
    ...    return_rc=True
    Log    ===== start_readorder.sh OUTPUT =====    console=yes
    Log    ${output}    console=yes
    ${stderr_len}=    Get Length    ${stderr}
    IF    ${stderr_len} > 0
        Log    ===== start_readorder.sh STDERR =====    console=yes
        Log    ${stderr}    console=yes
    END
    Log    Exit code: ${rc}    console=yes
    RETURN    ${output}    ${rc}

Close Order Processing Server Connection
    [Documentation]    Closes all SSH connections.
    SSHLibrary.Close All Connections
    Log    SSH connection closed.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  RESPONSE FILE GENERATION
# ═══════════════════════════════════════════════════════════════════════
Generate Response File From Template
    [Documentation]    Creates a response file by replacing the template orderId
    ...                with the actual orderId. Prints file content to terminal.
    [Arguments]    ${order_id}    ${template_content}    ${extension}
    ${content}=    Replace String    ${template_content}    ${TEMPLATE_ORDER_ID}    ${order_id}
    ${filename}=    Set Variable    ${order_id}.${extension}
    ${local_path}=    Set Variable    ${EXECDIR}${/}${filename}
    Create File    ${local_path}    ${content}
    Log    Generated file: ${filename}    console=yes
    Log    ===== ${filename} CONTENT =====    console=yes
    Log    ${content}    console=yes
    Log    ===== END ${filename} =====    console=yes
    RETURN    ${local_path}    ${filename}

Generate All Response Files
    [Documentation]    Generates all 3 response files (dsprsp, ordrsp, pcsrsp) from templates.
    ...                Loads template from templates/order_processing/<ext>.template if present,
    ...                otherwise uses in-code TEMPLATE_MAP (variables). Returns list of [local_path, remote_filename] pairs.
    [Arguments]    ${order_id}
    @{files}=    Create List
    ${templates_dir}=    Set Variable    ${EXECDIR}${/}templates${/}order_processing
    FOR    ${ext}    IN    @{RESPONSE_FILE_EXTENSIONS}
        ${path}=    Set Variable    ${templates_dir}${/}${ext}.template
        ${exists}=    Run Keyword And Return Status    File Should Exist    ${path}
        IF    ${exists}
            ${template}=    Get File    ${path}
            Log    Using template file: ${path}    console=yes
        ELSE
            ${template}=    Set Variable    ${TEMPLATE_MAP}[${ext}]
            Log    Using in-code template for ${ext} (file not found: ${path})    console=yes
        END
        ${local_path}    ${filename}=    Generate Response File From Template
        ...    ${order_id}    ${template}    ${ext}
        ${pair}=    Create List    ${local_path}    ${filename}
        Append To List    ${files}    ${pair}
    END
    RETURN    ${files}

Upload All Response Files To Server
    [Documentation]    Uploads all generated response files to the server input directory.
    [Arguments]    ${file_pairs}
    FOR    ${pair}    IN    @{file_pairs}
        Upload Response File To Server    ${pair}[0]    ${pair}[1]
    END
    Log    All response files uploaded to server.    console=yes

Cleanup Local Response Files
    [Documentation]    Removes locally generated response files after upload.
    [Arguments]    ${file_pairs}
    FOR    ${pair}    IN    @{file_pairs}
        Remove File    ${pair}[0]
    END
    Log    Local response files cleaned up.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  ORDER STATUS VALIDATION
# ═══════════════════════════════════════════════════════════════════════
Validate Order Status In Live Order Grid
    [Documentation]    Navigates to Live Order, waits for table to load,
    ...                searches order ID, waits 30s, then validates status.
    [Arguments]    ${order_id}    ${expected_status}
    Ensure Session Is Active
    Go To    ${LIVE_ORDER_URL}
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_SO_GRID}    timeout=30s
    Wait Until Element Is Visible    xpath=//table/tbody/tr    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_SEARCH_INPUT}    timeout=15s
    Clear Element Text    ${LOC_SO_SEARCH_INPUT}
    Input Text    ${LOC_SO_SEARCH_INPUT}    ${order_id}
    Click Element Via JS    ${LOC_SO_SEARCH_BTN}
    Sleep    30s
    Wait For Loading Overlay To Disappear
    ${status}=    Get Order Status From Grid    ${order_id}
    Log    Order ${order_id} status: "${status}" (expected: "${expected_status}")    console=yes
    Capture Page Screenshot    live_order_status_${order_id}.png
    Should Contain    ${status}    ${expected_status}
    ...    msg=Order ${order_id} status is "${status}" — expected "${expected_status}"
    ...    ignore_case=True
    Log    Order ${order_id} status confirmed: "${expected_status}"    console=yes

Validate Order Status In Order History
    [Documentation]    Navigates to Order History, waits for table to load,
    ...                searches order ID, waits 30s, then validates status.
    [Arguments]    ${order_id}    ${expected_status}
    Ensure Session Is Active
    Go To    ${ORDER_HISTORY_URL}
    Sleep    5s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    xpath=//div[contains(@class,'k-grid')]    timeout=30s
    Wait Until Element Is Visible    xpath=//table/tbody/tr    timeout=30s
    Wait Until Element Is Visible    ${LOC_SO_SEARCH_INPUT}    timeout=15s
    Clear Element Text    ${LOC_SO_SEARCH_INPUT}
    Input Text    ${LOC_SO_SEARCH_INPUT}    ${order_id}
    Click Element Via JS    ${LOC_SO_SEARCH_BTN}
    Sleep    30s
    Wait For Loading Overlay To Disappear
    ${status}=    Get Order Status From Grid    ${order_id}
    Log    Order History — ${order_id} status: "${status}" (expected: "${expected_status}")    console=yes
    Capture Page Screenshot    order_history_status_${order_id}.png
    Should Contain    ${status}    ${expected_status}
    ...    msg=Order History — ${order_id} status is "${status}" — expected "${expected_status}"
    ...    ignore_case=True
    Log    Order ${order_id} status confirmed: "${expected_status}" in Order History    console=yes

Get Order Status From Grid
    [Documentation]    Finds the "Status" column header, reads that cell from the first row.
    ...                Tries simOrderGrid first, then falls back to any k-grid on the page.
    [Arguments]    ${order_id}
    ${status}=    Execute Javascript
    ...    var grid = document.getElementById('simOrderGrid');
    ...    if(!grid) grid = document.querySelector('div.k-grid');
    ...    if(!grid) grid = document.querySelector('[class*="grid"]');
    ...    if(!grid) return 'NO_GRID';
    ...    var ths = grid.querySelectorAll('thead th');
    ...    var statusIdx = -1;
    ...    for(var i=0; i<ths.length; i++){
    ...        var txt = ths[i].textContent.trim().toLowerCase();
    ...        if(txt === 'status'){ statusIdx = i; break; }
    ...    }
    ...    if(statusIdx < 0){
    ...        for(var j=0; j<ths.length; j++){
    ...            if(ths[j].textContent.trim().toLowerCase().indexOf('status') >= 0){ statusIdx = j; break; }
    ...        }
    ...    }
    ...    var row = grid.querySelector('tbody tr');
    ...    if(!row) return 'NO_ROWS';
    ...    var cells = row.querySelectorAll('td');
    ...    if(statusIdx >= 0 && cells[statusIdx]) return cells[statusIdx].textContent.trim();
    ...    var allText = [];
    ...    cells.forEach(function(c){ allText.push(c.textContent.trim()); });
    ...    return 'STATUS_COL_NOT_FOUND. Row: ' + JSON.stringify(allText);
    Log    First row status: "${status}"    console=yes
    RETURN    ${status}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 14: MANAGE DEVICES — VALIDATE SIMs IN WARM STATE
# ═══════════════════════════════════════════════════════════════════════
Navigate To Manage Devices And Filter BU
    [Documentation]    Navigates to Manage Devices, resets grid, applies BU account filter
    ...                for Warm state, closes filter popup, and waits for grid to load.
    [Arguments]    ${bu_name}
    Ensure Session Is Active
    Go To    ${MANAGE_DEVICES_URL_E2E}
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Reset Grid To Default View
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Open Filter Popup
    Apply Account Filter    ${bu_name}
    Apply SIM State Filter    ${EXPECTED_WARM_STATE}
    Close Filter Popup
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s

Validate All SIMs In Warm State
    [Documentation]    After filtering, verifies every visible row has SIM State = Warm
    ...                and the total row count is >= 10.
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${row_count}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    Log    Filtered grid row count: ${row_count}    console=yes
    Should Be True    ${row_count} >= 10
    ...    Expected >= 10 SIMs in Warm state, but found ${row_count}.
    ${all_warm}=    Execute Javascript
    ...    var rows = document.querySelectorAll('#gridData table tbody tr.k-master-row');
    ...    var stateCol = arguments[0];
    ...    for(var i=0; i<rows.length; i++){
    ...        var cells = rows[i].querySelectorAll('td');
    ...        if(cells[stateCol] && cells[stateCol].textContent.trim() !== 'Warm') return false;
    ...    }
    ...    return true;
    ...    ARGUMENTS    ${state_col}
    Should Be True    ${all_warm}    Not all SIMs are in Warm state.
    Log    All ${row_count} SIMs confirmed in Warm state.    console=yes
    RETURN    ${row_count}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 15: SOAP API — UPDATE ORDER STATUS TO APPROVED
# ═══════════════════════════════════════════════════════════════════════
Call Update Order Status API
    [Documentation]    Sends SOAP request to update order status to Approved.
    ...                Uses the captured orderId in the request body.
    ...                Loads body from templates/api/SimOrderUpdateStatus.xml if present, else from variables.
    [Arguments]    ${order_id}
    ${soap_template_path}=    Set Variable    ${EXECDIR}${/}templates${/}api${/}SimOrderUpdateStatus.xml
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${soap_template_path}
    IF    ${file_exists}
        ${body_raw}=    Get File    ${soap_template_path}
    ELSE
        ${body_raw}=    Set Variable    ${UPDATE_ORDER_STATUS_BODY}
    END
    ${body}=    Replace String    ${body_raw}    ${TEMPLATE_ORDER_ID}    ${order_id}
    Log    ===== SOAP Request Body =====    console=yes
    Log    ${body}    console=yes
    Create Session    order_status    ${SOAP_ORDER_STATUS_URL}    verify=${False}    disable_warnings=1
    ${headers}=    Create Dictionary
    ...    Content-Type=text/xml;charset=UTF-8
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ...    SOAPAction=${SOAP_ORDER_STATUS_ACTION}
    ${response}=    POST On Session    order_status    url=${SOAP_ORDER_STATUS_URL}
    ...    data=${body}    headers=${headers}    expected_status=any
    Log    ===== SOAP Response (Status: ${response.status_code}) =====    console=yes
    Log    ${response.text}    console=yes
    Should Be Equal As Integers    ${response.status_code}    200
    ...    Update Order Status API returned ${response.status_code} instead of 200
    Should Not Contain    ${response.text}    <faultstring>
    ...    SOAP fault found in updateOrderStatus response
    Delete All Sessions
    Log    Order ${order_id} status updated to Approved successfully.    console=yes
    RETURN    ${response}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 16: DEVICE STATE CHANGE — ACTIVATE 5 SIMs IN ONE GO (InActive → Activated)
# ═══════════════════════════════════════════════════════════════════════
Activate SIMs From InActive State
    [Documentation]    On Manage Devices: apply Account + InActive filter,
    ...                verify each row is truly InActive, click checkboxes for up to
    ...                ${count} InActive SIMs, capture their IMSIs and MSISDNs,
    ...                perform a single state change to Activated, wait 5 min.
    ...                Returns two values:
    ...                  1) flat list of IMSI strings (backward compat)
    ...                  2) list of dicts [{imsi, msisdn}, ...] for usage flow
    [Arguments]    ${bu_name}    ${count}=${SIM_ACTIVATE_COUNT}
    Ensure Session Is Active
    Go To    ${MANAGE_DEVICES_URL_E2E}
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Reset Grid To Default View
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    # --- 1. Apply Account + InActive state filter ---
    Open Filter Popup
    Apply Account Filter    ${bu_name}
    Apply SIM State Filter    ${EXPECTED_INACTIVE_STATE}
    Close Filter Popup
    Sleep    3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Log    Filters applied: Account=${bu_name}, State=${EXPECTED_INACTIVE_STATE}    console=yes
    Capture Page Screenshot    e2e_step16_filtered.png
    # --- 2. Scan rows, verify actual state, click checkboxes + capture IMSIs & MSISDNs ---
    ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${msisdn_col}=    Get Column Index By Header Text    ${MSISDN_COLUMN_HEADER}
    ${total_rows}=    Execute Javascript
    ...    return document.querySelectorAll('#gridData table tbody tr.k-master-row').length;
    Log    Total visible rows after filter: ${total_rows}    console=yes
    @{activated_imsis}=    Create List
    @{imsi_data}=    Create List
    ${selected}=    Set Variable    ${0}
    FOR    ${i}    IN RANGE    ${total_rows}
        IF    ${selected} >= ${count}    BREAK
        ${row_num}=    Evaluate    ${i} + 1
        ${actual_state}=    Get Cell Value By Row And Column    ${row_num}    ${state_col}
        ${imsi}=    Get Cell Value By Row And Column    ${row_num}    ${imsi_col}
        ${msisdn}=    Get Cell Value By Row And Column    ${row_num}    ${msisdn_col}
        Log    Row ${row_num}: IMSI=${imsi}, MSISDN=${msisdn}, State=${actual_state}    console=yes
        IF    "${actual_state}" == "${EXPECTED_INACTIVE_STATE}"
            Select Device By Row Index    ${i}
            Log    Clicked checkbox for row ${row_num} (IMSI: ${imsi}, MSISDN: ${msisdn})    console=yes
            Append To List    ${activated_imsis}    ${imsi}
            ${entry}=    Create Dictionary    imsi=${imsi}    msisdn=${msisdn}
            Append To List    ${imsi_data}    ${entry}
            ${selected}=    Evaluate    ${selected} + 1
        ELSE
            Log    Skipping row ${row_num}: state is "${actual_state}", not InActive    WARN
        END
    END
    Should Be True    ${selected} >= ${count}
    ...    Only found ${selected} InActive SIMs but need ${count}. Check if SIMs are already activated.
    Capture Page Screenshot    e2e_step16_5_checked.png
    Log    ===== Selected ${selected} InActive SIMs =====    console=yes
    FOR    ${entry}    IN    @{imsi_data}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END
    Sleep    2s
    # --- 3. Perform activation in one go ---
    Select Change State Action
    Select Target State And Submit    ${EXPECTED_ACTIVATED_STATE}
    Fill Popup And Submit    InActive    ${EXPECTED_ACTIVATED_STATE}
    ${toast_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_TOAST_SUCCESS}    timeout=30s
    IF    ${toast_ok}
        ${toast_text}=    Get Text    ${LOC_DSC_TOAST_SUCCESS}
        Log    Success toast: ${toast_text}    console=yes
    ELSE
        Log    No success toast found within 30s — proceeding anyway.    WARN
    END
    ${popup_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_DSC_POPUP}    timeout=15s
    IF    not ${popup_gone}
        Run Keyword And Ignore Error    Click Element Via JS    ${LOC_DSC_POPUP_X_BTN}
        Sleep    2s
    END
    Capture Page Screenshot    e2e_step16_state_change_submitted.png
    Log    State change submitted for ${selected} SIMs. Waiting 5 minutes...    console=yes
    Sleep    300s
    Wait For Loading Overlay To Disappear
    RETURN    ${activated_imsis}    ${imsi_data}

Verify Activated SIMs
    [Documentation]    Verifies all IMSIs are Activated. If any IMSI is not yet Activated,
    ...                refreshes the page and retries every 1 min for up to 5 minutes.
    [Arguments]    ${imsi_list}    ${bu_name}
    ${total}=    Get Length    ${imsi_list}
    FOR    ${attempt}    IN RANGE    5
        ${attempt_num}=    Evaluate    ${attempt} + 1
        Log    ===== Verification attempt ${attempt_num}/5 =====    console=yes
        Ensure Session Is Active
        Go To    ${MANAGE_DEVICES_URL_E2E}
        Sleep    3s
        Wait For Loading Overlay To Disappear
        Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
        Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
        ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
        ${pass_count}=    Set Variable    ${0}
        @{pending_imsis}=    Create List
        FOR    ${imsi}    IN    @{imsi_list}
            Reset Grid To Default View
            Sleep    2s
            Wait For Loading Overlay To Disappear
            Search Device By IMSI    ${imsi}
            Sleep    3s
            Wait For Loading Overlay To Disappear
            Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
            ${actual_state}=    Get Cell Value By Row And Column    1    ${state_col}
            Log    IMSI ${imsi}: state = "${actual_state}"    console=yes
            IF    "${actual_state}" == "${EXPECTED_ACTIVATED_STATE}"
                ${pass_count}=    Evaluate    ${pass_count} + 1
                Log    VERIFIED ${pass_count}/${total}: IMSI ${imsi} is Activated    console=yes
                Capture Page Screenshot    e2e_step16_verified_${imsi}.png
            ELSE
                Log    IMSI ${imsi} is "${actual_state}" — not yet Activated    WARN
                Append To List    ${pending_imsis}    ${imsi}
            END
        END
        IF    ${pass_count} == ${total}
            Log    ===== ALL ${total} SIMs VERIFIED AS ACTIVATED =====    console=yes
            RETURN
        END
        Log    ${pass_count}/${total} Activated. ${total - ${pass_count}} pending. Waiting 60s before retry...    console=yes
        Sleep    60s
    END
    Fail    After 5 attempts (5 min), only ${pass_count}/${total} SIMs are Activated. Still pending: @{pending_imsis}

# ═══════════════════════════════════════════════════════════════════════
#  STEP 17: INVOICE GENERATION
# ═══════════════════════════════════════════════════════════════════════
Call Invoice API
    [Documentation]    Calls the Invoice API with the BU account ID.
    ...                Retries up to 3 times with 30s gap if connection fails.
    [Arguments]    ${bu_account_id}
    ${url}=    Set Variable    ${INVOICE_API_URL}/${bu_account_id}
    Log    Calling Invoice API: ${url}    console=yes
    ${response}=    Wait Until Keyword Succeeds    3x    30s
    ...    Call Invoice API Once    ${url}
    Log    Invoice API called successfully for BU ID: ${bu_account_id}    console=yes
    RETURN    ${response}

Call Invoice API Once
    [Documentation]    Single attempt to call the Invoice API.
    [Arguments]    ${url}
    Create Session    invoice    ${url}    verify=${False}    disable_warnings=1    timeout=120
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    invoice    url=${url}
    ...    headers=${headers}    expected_status=any    timeout=300
    Log    ===== Invoice API Response (Status: ${response.status_code}) =====    console=yes
    Log    ${response.text}    console=yes
    Should Be Equal As Integers    ${response.status_code}    200
    ...    Invoice API returned ${response.status_code} instead of 200. Response: ${response.text}
    Delete All Sessions
    RETURN    ${response}

Connect To Invoice Server
    [Documentation]    Opens SSH connection to the invoice server (10.121.77.114).
    SSHLibrary.Open Connection    ${INVOICE_SSH_HOST}    timeout=60s
    SSHLibrary.Login    ${INVOICE_SSH_USERNAME}    ${INVOICE_SSH_PASSWORD}
    Log    SSH connected to ${INVOICE_SSH_HOST} as ${INVOICE_SSH_USERNAME} (invoice)    console=yes

Capture Server Timestamp
    [Documentation]    Captures the current server timestamp in epoch seconds.
    ...                Must be called while SSH is connected.
    ${epoch}=    SSHLibrary.Execute Command    date +%s
    Log    Server timestamp captured: ${epoch}    console=yes
    RETURN    ${epoch}

Find New Files After Timestamp
    [Documentation]    Finds CSV files in INVOICE_SERVER_DIR newer than the given epoch.
    ...                Returns the full path of the newest file, or empty string.
    [Arguments]    ${epoch}
    ${cmd}=    Set Variable    find ${INVOICE_SERVER_DIR} -maxdepth 1 -name "*.csv" -newermt @${epoch} -printf '%T@ %p\\n' 2>/dev/null | sort -rn | head -1 | awk '{print $2}'
    ${result}=    SSHLibrary.Execute Command    ${cmd}
    ${result}=    Evaluate    """${result}""".strip()
    Log    New file search result: "${result}"    console=yes
    RETURN    ${result}

Download Invoice File With Retry
    [Documentation]    Retries 3 times (every 2 min, total 6 min) to find a new CSV file
    ...                created after the captured timestamp. Downloads it to billing/ folder.
    [Arguments]    ${epoch}
    ${billing_dir}=    Set Variable    ${OUTPUT DIR}${/}billing
    Create Directory    ${billing_dir}
    FOR    ${attempt}    IN RANGE    3
        ${attempt_num}=    Evaluate    ${attempt} + 1
        Log    ===== Invoice file check attempt ${attempt_num}/3 =====    console=yes
        ${new_file}=    Find New Files After Timestamp    ${epoch}
        IF    "${new_file}" != "${EMPTY}"
            ${remote_filename}=    Evaluate    """${new_file}""".strip().split('/')[-1]
            Log    Found new invoice file: ${remote_filename}    console=yes
            ${local_path}=    Set Variable    ${billing_dir}${/}${remote_filename}
            SSHLibrary.Get File    ${new_file}    ${local_path}
            Log    Downloaded: ${new_file} → ${local_path}    console=yes
            OperatingSystem.File Should Exist    ${local_path}
            Log    Invoice file saved locally: ${local_path}    console=yes
            RETURN    ${local_path}    ${remote_filename}
        END
        IF    ${attempt} < 2
            Log    No new file yet. Waiting 2 minutes before retry...    console=yes
            Sleep    120s
        END
    END
    Fail    No new invoice CSV found after 3 attempts (6 min). Timestamp: ${epoch}
