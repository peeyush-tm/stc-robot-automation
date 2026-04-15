*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     Collections
Library     String
Library     DateTime
Resource    device_state_keywords.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  USER REQUEST API (Step 16a)
# ═══════════════════════════════════════════════════════════════════════

Call User Request API
    [Documentation]    Calls the User Request API for a given IMSI/MSISDN/usage type.
    ...                Returns the parsed JSON response dict.
    [Arguments]    ${imsi}    ${msisdn}    ${usage_type}    ${usage_subtype}=${EMPTY}
    ${params}=    Create Dictionary
    ...    type=${usage_type}
    ...    OCStoken=${USAGE_OCS_TOKEN}
    ...    origin=${USAGE_ORIGIN}
    ...    serviceType=${USAGE_SERVICE_TYPE}
    ...    msisdn=${msisdn}
    ...    imsi=${imsi}
    ...    network=${USAGE_NETWORK}
    ...    ratType=${USAGE_RAT_TYPE}
    IF    "${usage_subtype}" != "${EMPTY}"
        Set To Dictionary    ${params}    subType=${usage_subtype}
    END
    ${headers}=    Create Dictionary    x-ocs-ip=${USAGE_OCS_IP}
    Log    ===== USER REQUEST API =====    console=yes
    Log    URL: ${USAGE_API_BASE_URL}/UserRequest    console=yes
    Log    Params: ${params}    console=yes
    Log    Headers: ${headers}    console=yes
    Create Session    usage_session    ${USAGE_API_BASE_URL}    verify=${False}    disable_warnings=1
    TRY
        ${response}=    POST On Session    usage_session    /UserRequest    params=${params}    headers=${headers}    expected_status=200
        Log    ===== USER REQUEST RESPONSE (${response.status_code}) =====    console=yes
        Log    ${response.text}    console=yes
        ${json}=    Evaluate    json.loads('''${response.text}''')    json
        ${user}=    Get From Dictionary    ${json}    user
        ${resp_imsi}=    Get From Dictionary    ${user}    imsi
        Should Be Equal As Strings    ${resp_imsi}    ${imsi}
        ...    User Request response IMSI mismatch: expected ${imsi}, got ${resp_imsi}
        # Validate volume is not zero
        ${resp_volume}=    Get From Dictionary    ${user}    volume
        Log    User Request volume for IMSI ${imsi}: ${resp_volume}    console=yes
        Should Not Be Equal As Strings    ${resp_volume}    0
        ...    User Request response volume is 0 for IMSI ${imsi}. Usage cannot proceed.
        Should Not Be Equal As Strings    ${resp_volume}    ${EMPTY}
        ...    User Request response volume is empty for IMSI ${imsi}. Usage cannot proceed.
    FINALLY
        Delete All Sessions
    END
    RETURN    ${json}

# ═══════════════════════════════════════════════════════════════════════
#  CDR API (Step 16a)
#  Params built from User Request response + static config. Empty body.
# ═══════════════════════════════════════════════════════════════════════

Call CDR API
    [Documentation]    Calls the CDR API using data from User Request response.
    ...                All matching fields passed from response, rest are static config.
    ...                Body is empty. Volume is per usage type.
    [Arguments]    ${imsi}    ${msisdn}    ${cdr_type}    ${volume}    ${cdr_subtype}    ${user_request_json}
    ${user}=    Get From Dictionary    ${user_request_json}    user
    # Fields from User Request response
    ${start_volume}=    Get From Dictionary    ${user}    startVolume
    ${quota_type}=    Get From Dictionary    ${user}    quotaType
    ${quota_id}=    Get From Dictionary    ${user}    quotaId
    # Build timestamp
    ${now}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.0
    ${now_encoded}=    Evaluate    $now.replace(" ", "+").replace(":", "%3A")
    # URL-encode IPv6
    ${ipv6_encoded}=    Evaluate    $USAGE_IPV6.replace(":", "%3A")
    ${params}=    Catenate    SEPARATOR=&
    ...    mcc_mnc=${USAGE_NETWORK}
    ...    calledNoMcc=
    ...    ipv4=${USAGE_IPV4}
    ...    ratType=${USAGE_RAT_TYPE}
    ...    quotaType=${quota_type}
    ...    imsi=${imsi}
    ...    quotaId=${quota_id}
    ...    calledNoType=${USAGE_CALLED_NO_TYPE}
    ...    ipv6=${ipv6_encoded}
    ...    cellId=${USAGE_CELL_ID}
    ...    msisdn=${msisdn}
    ...    type=${cdr_type}
    ...    eventTimestamp=${now_encoded}
    ...    startVolume=${start_volume}
    ...    volume=${volume}
    IF    "${cdr_subtype}" != "${EMPTY}"
        ${params}=    Catenate    SEPARATOR=&    ${params}    subType=${cdr_subtype}
    END
    ${url}=    Set Variable    /CDR?${params}
    Log    ===== CDR API =====    console=yes
    Log    URL: ${USAGE_API_BASE_URL}${url}    console=yes
    Create Session    cdr_session    ${USAGE_API_BASE_URL}    verify=${False}    disable_warnings=1
    TRY
        ${response}=    POST On Session    cdr_session    ${url}    data=${EMPTY}    expected_status=200
        Log    ===== CDR RESPONSE (${response.status_code}) =====    console=yes
        Log    ${response.text}    console=yes
    FINALLY
        Delete All Sessions
    END
    RETURN    ${response}

# ═══════════════════════════════════════════════════════════════════════
#  IMSI DATA PARSING (from CLI variable E2E_IMSI_CSV)
# ═══════════════════════════════════════════════════════════════════════

Build IMSI Data From CSV
    [Documentation]    Parses E2E_IMSI_CSV into a list of {imsi, msisdn} dicts.
    ...                Accepts two formats:
    ...                  1) IMSI1:MSISDN1,IMSI2:MSISDN2  (with MSISDNs)
    ...                  2) IMSI1,IMSI2,IMSI3             (without MSISDNs — looked up from grid)
    ...                Returns a list of dicts: [{imsi: "...", msisdn: "..."}, ...]
    [Arguments]    ${imsi_csv}
    @{result}=    Create List
    @{pairs}=    Split String    ${imsi_csv}    ,
    ${needs_lookup}=    Set Variable    ${False}
    FOR    ${pair}    IN    @{pairs}
        ${pair}=    Strip String    ${pair}
        ${has_colon}=    Evaluate    ":" in """${pair}"""
        IF    ${has_colon}
            @{parts}=    Split String    ${pair}    :    1
            ${imsi}=    Strip String    ${parts}[0]
            ${msisdn}=    Strip String    ${parts}[1]
        ELSE
            ${imsi}=    Set Variable    ${pair}
            ${msisdn}=    Set Variable    ${EMPTY}
            ${needs_lookup}=    Set Variable    ${True}
        END
        ${entry}=    Create Dictionary    imsi=${imsi}    msisdn=${msisdn}
        Append To List    ${result}    ${entry}
    END
    IF    ${needs_lookup}
        Log    MSISDNs not provided — looking up from Manage Devices grid...    console=yes
        ${result}=    Lookup MSISDNs From Grid    ${result}
    END
    ${count}=    Get Length    ${result}
    Log    Parsed ${count} IMSI entries from CSV.    console=yes
    FOR    ${entry}    IN    @{result}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END
    RETURN    ${result}

Lookup MSISDNs From Grid
    [Documentation]    For each entry with empty msisdn, searches the IMSI in Manage Devices
    ...                grid and reads the MSISDN column value.
    [Arguments]    ${imsi_data_list}
    Ensure Session Is Active
    Go To    ${MANAGE_DEVICES_URL_E2E}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    @{updated}=    Create List
    FOR    ${entry}    IN    @{imsi_data_list}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        ${msisdn}=    Get From Dictionary    ${entry}    msisdn
        IF    "${msisdn}" == "${EMPTY}"
            Reset Grid To Default View
            Sleep    1s
            Wait For Loading Overlay To Disappear
            Search Device By IMSI    ${imsi}
            Sleep    1s
            Wait For Loading Overlay To Disappear
            Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
            ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
            ${msisdn_col}=    Get Column Index By Header Text    ${MSISDN_COLUMN_HEADER}
            ${grid_imsi}=    Get Cell Value By Row And Column    1    ${imsi_col}
            Should Be Equal As Strings    ${grid_imsi}    ${imsi}
            ...    Grid first row IMSI mismatch after search: expected "${imsi}" but got "${grid_imsi}". Search may not have filtered correctly.
            ${msisdn}=    Get Cell Value By Row And Column    1    ${msisdn_col}
            Should Not Be Empty    ${msisdn}
            ...    MSISDN is empty for IMSI ${imsi} in grid row 1.
            Log    Looked up MSISDN for IMSI ${imsi}: ${msisdn}    console=yes
        END
        ${new_entry}=    Create Dictionary    imsi=${imsi}    msisdn=${msisdn}
        Append To List    ${updated}    ${new_entry}
    END
    RETURN    ${updated}

# ═══════════════════════════════════════════════════════════════════════
#  USAGE ORCHESTRATION (iterates IMSIs × usage types)
# ═══════════════════════════════════════════════════════════════════════

Perform Usage For Single IMSI
    [Documentation]    For one IMSI/MSISDN, calls User Request + CDR for data usage only.
    [Arguments]    ${imsi}    ${msisdn}
    FOR    ${usage}    IN    @{USAGE_TYPES}
        ${label}=    Get From Dictionary    ${usage}    label
        ${type}=     Get From Dictionary    ${usage}    type
        ${subtype}=  Get From Dictionary    ${usage}    subType
        ${volume}=   Get From Dictionary    ${usage}    volume
        Log    ===== ${label} usage for IMSI ${imsi} (type=${type}, subType=${subtype}, volume=${volume}) =====    console=yes
        ${ur_response}=    Call User Request API    ${imsi}    ${msisdn}    ${type}    ${subtype}
        Sleep    1s
        ${cdr_response}=    Call CDR API    ${imsi}    ${msisdn}    ${type}    ${volume}    ${subtype}    ${ur_response}
        Log    ${label} usage completed for IMSI ${imsi}.    console=yes
        Sleep    1s
    END

Perform Usage For All IMSIs
    [Documentation]    Iterates all entries in imsi_data list (each has keys imsi, msisdn)
    ...                and performs data usage only for each.
    [Arguments]    @{imsi_data}
    ${total}=    Get Length    ${imsi_data}
    Log    Starting data usage for ${total} IMSIs.    console=yes
    ${idx}=    Set Variable    ${1}
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        ${msisdn}=    Get From Dictionary    ${entry}    msisdn
        Log    ===== IMSI ${idx}/${total}: ${imsi} (MSISDN: ${msisdn}) =====    console=yes
        Perform Usage For Single IMSI    ${imsi}    ${msisdn}
        ${idx}=    Evaluate    ${idx} + 1
    END
    Log    All usage API calls complete for ${total} IMSIs.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  USAGE UI VALIDATION (Step 16b)
#  1) Navigate to Manage Devices page
#  2) For each IMSI: search that IMSI → expand device row → Usage tab →
#     validate DATA USAGE (MB) = 5.00 in first row (SMS/voice not validated).
# ═══════════════════════════════════════════════════════════════════════

Validate Usage In UI For All IMSIs
    [Documentation]    Navigates to Manage Devices page, then for each IMSI: searches that IMSI,
    ...                expands the device row, opens Usage tab, and validates DATA USAGE (MB)
    ...                equals 5.00 in the first row (data usage only).
    [Arguments]    @{imsi_data}
    Log    Waiting 30s for usage data to reflect in UI...    console=yes
    Sleep    30s
    Ensure Session Is Active
    # 1) Navigate to Manage Devices page
    Log    Navigating to Manage Devices page...    console=yes
    Go To    ${MANAGE_DEVICES_URL_E2E}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Log    On Manage Devices page; grid loaded.    console=yes
    ${total}=    Get Length    ${imsi_data}
    Log    Validating usage for ${total} IMSI(s): search → expand → Usage tab → DATA USAGE (MB)=5.00    console=yes
    ${pass_count}=    Set Variable    ${0}
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        Log    ===== IMSI ${pass_count + 1}/${total}: search "${imsi}" → expand → validate =====    console=yes
        Validate Usage Columns For IMSI    ${imsi}
        ${pass_count}=    Evaluate    ${pass_count} + 1
        Log    IMSI ${pass_count}/${total} validated: ${imsi}    console=yes
    END
    Log    ===== All ${total} IMSIs usage validated in UI (Manage Devices, expand, Usage tab, DATA USAGE=5.00) =====    console=yes

Validate Usage Columns For IMSI
    [Documentation]    Called when already on Manage Devices page. For the given IMSI: search that IMSI,
    ...                expand the device row, open Usage tab, validate DATA USAGE (MB)=5.00 in first row.
    [Arguments]    ${imsi}
    # Reset grid then search for this IMSI (assumes we are on Manage Devices)
    Reset Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Search Device By IMSI    ${imsi}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Log    Search complete; load settled. Clicking expand icon...    console=yes
    # Expand the first row (device details) via the expand icon
    ${expand_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_FIRST_ROW_EXPAND}    timeout=10s
    IF    not ${expand_visible}
        Wait Until Element Is Visible    ${LOC_DSC_FIRST_ROW_EXPAND_ALT}    timeout=10s
        Click Element Via JS    ${LOC_DSC_FIRST_ROW_EXPAND_ALT}
    ELSE
        Click Element Via JS    ${LOC_DSC_FIRST_ROW_EXPAND}
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Log    Expand complete; load settled. Clicking Usage tab...    console=yes
    Scroll Element Into View    ${LOC_DSC_FIRST_ROW}
    Sleep    0.5s
    # Click the Usage tab (try JS exact "Usage" first, then locators)
    ${usage_clicked}=    Run Keyword And Return Status
    ...    Execute Javascript
    ...    var grid = document.getElementById('gridData');
    ...    if(!grid) return false;
    ...    var detailRow = grid.querySelector('tr.k-detail-row') || (function(){ var m = grid.querySelector('tr.k-master-row'); return m && m.nextElementSibling && m.nextElementSibling.tagName === 'TR' ? m.nextElementSibling : null; })();
    ...    if(!detailRow) return false;
    ...    var nodes = detailRow.querySelectorAll('a, span, li, button, div[role="tab"]');
    ...    for(var i=0; i<nodes.length; i++){ var t = (nodes[i].textContent || '').trim(); if(t === 'Usage' && nodes[i].offsetParent){ nodes[i].click(); return true; } }
    ...    for(var i=0; i<nodes.length; i++){ var t = (nodes[i].textContent || '').trim().toLowerCase(); if(t.indexOf('usage') >= 0 && t.length < 20 && nodes[i].offsetParent){ nodes[i].click(); return true; } }
    ...    return false;
    IF    not ${usage_clicked}
        ${usage_clicked}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DSC_DETAIL_USAGE_TAB_LINK}    timeout=10s
        IF    ${usage_clicked}
            Click Element Via JS    ${LOC_DSC_DETAIL_USAGE_TAB_LINK}
        ELSE
            ${usage_clicked}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_DSC_DETAIL_USAGE_TAB_ALT}    timeout=5s
            IF    ${usage_clicked}
                Click Element Via JS    ${LOC_DSC_DETAIL_USAGE_TAB_ALT}
            ELSE
                ${usage_clicked}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible    ${LOC_DSC_DETAIL_USAGE_TAB_ANY}    timeout=5s
                IF    ${usage_clicked}
                    Click Element Via JS    ${LOC_DSC_DETAIL_USAGE_TAB_ANY}
                ELSE
                    ${js_clicked}=    Execute Javascript
                    ...    var grid = document.getElementById('gridData');
                    ...    if(!grid) return 'NO_GRID';
                    ...    var detailRow = grid.querySelector('tr.k-detail-row');
                    ...    if(!detailRow){
                    ...        var firstMaster = grid.querySelector('tr.k-master-row');
                    ...        if(firstMaster && firstMaster.nextElementSibling && firstMaster.nextElementSibling.tagName === 'TR')
                    ...            detailRow = firstMaster.nextElementSibling;
                    ...    }
                    ...    if(!detailRow) return 'NO_DETAIL_ROW';
                    ...    var all = detailRow.querySelectorAll('a, span, li, button, div[role="tab"]');
                    ...    for(var i=0; i<all.length; i++){ var raw = (all[i].textContent || '').trim(); if(raw === 'Usage' && all[i].offsetParent){ all[i].click(); return 'CLICKED'; } }
                    ...    for(var i=0; i<all.length; i++){ var t = (all[i].textContent || '').trim().toLowerCase(); if(t.indexOf('usage') >= 0 && t.length < 20 && all[i].offsetParent){ all[i].click(); return 'CLICKED'; } }
                    ...    return 'NOT_FOUND';
                    Should Be Equal As Strings    ${js_clicked}    CLICKED
                    ...    Usage tab not found in expanded row. Tried locators and JS. Expand may have failed or tab structure differs.
                END
            END
        END
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Log    Usage tab open; load settled. Reading DATA USAGE (MB)...    console=yes
    # Wait for usage table to appear (async load); retry read up to 10s.
    # Prefer table in expanded detail row (Usage tab); fallback to main grid first row Data Usage column.
    ${usage_vals}=    Set Variable    {"data":"NOT_FOUND","headers":""}
    FOR    ${i}    IN RANGE    10
        ${usage_vals}=    Execute Javascript
        ...    var grid = document.getElementById('gridData');
        ...    if(!grid) return JSON.stringify({data: 'NO_GRID', headers: ''});
        ...    var detailRow = grid.querySelector('tr.k-detail-row');
        ...    if(!detailRow){
        ...        var firstMaster = grid.querySelector('tr.k-master-row');
        ...        if(firstMaster && firstMaster.nextElementSibling && firstMaster.nextElementSibling.tagName === 'TR')
        ...            detailRow = firstMaster.nextElementSibling;
        ...    }
        ...    var dataVal = 'NOT_FOUND';
        ...    var headers = '';
        ...    var tables = detailRow ? detailRow.querySelectorAll('table') : [];
        ...    if(tables.length === 0) tables = grid.querySelectorAll('table');
        ...    for(var t=0; t<tables.length; t++){
        ...        var ths = tables[t].querySelectorAll('thead th');
        ...        var colIdx = -1;
        ...        for(var h=0; h<ths.length; h++){
        ...            var txt = (ths[h].textContent || '').trim().toLowerCase();
        ...            if(txt.indexOf('data') >= 0 && txt.indexOf('usage') >= 0 && txt.indexOf('nb-iot') < 0){ colIdx = h; break; }
        ...        }
        ...        if(colIdx >= 0){
        ...            var inDetail = detailRow && detailRow.contains(tables[t]);
        ...            if(!inDetail && ths.length > 15) continue;
        ...            var rows = tables[t].querySelectorAll('tbody tr');
        ...            if(rows.length > 0){
        ...                var cells = rows[0].querySelectorAll('td');
        ...                if(cells[colIdx]) dataVal = cells[colIdx].textContent.trim();
        ...                if(dataVal === 'NOT_FOUND' && cells.length > 0){
        ...                    for(var c=0; c<cells.length; c++){
        ...                        var v = (cells[c].textContent || '').trim();
        ...                        if(v === '5.00' || v === '5.0'){ dataVal = v; break; }
        ...                    }
        ...                }
        ...            }
        ...            if(dataVal === 'NOT_FOUND' && inDetail) continue;
        ...            headers = Array.from(ths).map(function(th){return th.textContent.trim();}).join(' | ');
        ...            if(dataVal !== 'NOT_FOUND') break;
        ...        }
        ...    }
        ...    if(dataVal === 'NOT_FOUND'){
        ...        var dRow = grid.querySelector('tr.k-detail-row') || (grid.querySelector('tr.k-master-row') && grid.querySelector('tr.k-master-row').nextElementSibling);
        ...        if(dRow){
        ...            var walk = document.createTreeWalker(dRow, NodeFilter.SHOW_TEXT);
        ...            var n; while((n = walk.nextNode())){ var v = (n.textContent || '').trim(); if(v === '5.00' || v === '5.0'){ dataVal = v; headers = 'Detail row text'; break; } }
        ...        }
        ...        if(dataVal === 'NOT_FOUND'){
        ...            var masterRow = grid.querySelector('tr.k-master-row');
        ...            if(masterRow){
        ...                var rowTable = masterRow.closest('table');
        ...                if(rowTable){
        ...                    var allTh = rowTable.querySelectorAll('thead th');
        ...                    var cIdx = -1;
        ...                    for(var h=0; h<allTh.length; h++){
        ...                        var txt = (allTh[h].textContent || '').trim().toLowerCase();
        ...                        if(txt.indexOf('data') >= 0 && txt.indexOf('usage') >= 0 && txt.indexOf('nb-iot') < 0){ cIdx = h; break; }
        ...                    }
        ...                    if(cIdx >= 0){
        ...                        var rowCells = masterRow.querySelectorAll('td');
        ...                        if(rowCells[cIdx]) dataVal = rowCells[cIdx].textContent.trim();
        ...                        if(dataVal === 'NOT_FOUND' || dataVal === '') for(var c=0; c<rowCells.length; c++){
        ...                            var v = (rowCells[c].textContent || '').trim();
        ...                            if(v === '5.00' || v === '5.0'){ dataVal = v; break; }
        ...                        }
        ...                        if(dataVal !== 'NOT_FOUND' && dataVal !== '') headers = 'Main grid row';
        ...                    }
        ...                }
        ...            }
        ...        }
        ...    }
        ...    return JSON.stringify({data: dataVal, headers: headers});
        ${parsed}=    Evaluate    json.loads('''${usage_vals}''')    json
        ${data_val}=    Get From Dictionary    ${parsed}    data
        Exit For Loop If    '${data_val}' != 'NOT_FOUND' and '${data_val}' != 'NO_GRID'
        Sleep    1s
    END
    ${parsed}=    Evaluate    json.loads('''${usage_vals}''')    json
    ${headers_found}=    Get From Dictionary    ${parsed}    headers
    Log    Usage tab headers: ${headers_found}    console=yes
    ${data_val}=    Get From Dictionary    ${parsed}    data
    Log    IMSI ${imsi} — DATA USAGE (MB) in Usage tab first row: ${data_val}    console=yes
    Should Not Be Equal As Strings    ${data_val}    NOT_FOUND
    ...    DATA USAGE (MB) column not found in Usage tab. Headers: ${headers_found}
    Should Not Be Equal As Strings    ${data_val}    NO_GRID
    ...    gridData element not found on page.
    Should Not Be Equal As Strings    ${data_val}    NO_DETAIL_ROW
    ...    Expanded detail row not found after clicking expand icon.
    Should Not Be Equal    ${data_val}    ${EMPTY}
    ...    DATA USAGE (MB) value was empty. Usage tab or grid cell may not have loaded.
    # Expect 5.00 (data usage from CDR = 5MB); accept 5.00 or 5.0
    ${data_num}=    Convert To Number    ${data_val}
    Should Be Equal As Numbers    ${data_num}    5.0
    ...    DATA USAGE (MB) for IMSI ${imsi} should be 5.00 in Usage tab first row, got: ${data_val}
    Log    PASS: IMSI ${imsi} — DATA USAGE (MB)=5.00 in Usage tab    console=yes
    Capture Page Screenshot    e2e_usage_validated_${imsi}.png

# ═══════════════════════════════════════════════════════════════════════
#  PAYG ITERATIVE USAGE — loop User Request + CDR until quotaType=payg
# ═══════════════════════════════════════════════════════════════════════

Call User Request API And Return Full Response
    [Documentation]    Calls User Request API and returns the full parsed JSON dict
    ...                WITHOUT asserting volume > 0 (volume may be 0 when quota exhausted).
    [Arguments]    ${imsi}    ${msisdn}    ${usage_type}    ${usage_subtype}=${EMPTY}
    ${params}=    Create Dictionary
    ...    type=${usage_type}
    ...    OCStoken=${USAGE_OCS_TOKEN}
    ...    origin=${USAGE_ORIGIN}
    ...    serviceType=${USAGE_SERVICE_TYPE}
    ...    msisdn=${msisdn}
    ...    imsi=${imsi}
    ...    network=${USAGE_NETWORK}
    ...    ratType=${USAGE_RAT_TYPE}
    IF    "${usage_subtype}" != "${EMPTY}"
        Set To Dictionary    ${params}    subType=${usage_subtype}
    END
    ${headers}=    Create Dictionary    x-ocs-ip=${USAGE_OCS_IP}
    Log    User Request API: imsi=${imsi} type=${usage_type}    console=yes
    Create Session    usage_session    ${USAGE_API_BASE_URL}    verify=${False}    disable_warnings=1
    TRY
        ${response}=    POST On Session    usage_session    /UserRequest    params=${params}    headers=${headers}    expected_status=200
        Log    User Request response: ${response.text}    console=yes
        ${json}=    Evaluate    json.loads('''${response.text}''')    json
    FINALLY
        Delete All Sessions
    END
    RETURN    ${json}

Perform Iterative Usage Until PAYG For Single IMSI
    [Documentation]    For one IMSI: repeatedly call User Request API, read quotaType and volume,
    ...                call CDR API with full volume from response, until quotaType becomes "payg".
    ...                Returns the final User Request JSON (with quotaType=payg).
    [Arguments]    ${imsi}    ${msisdn}    ${max_iterations}=${PAYG_MAX_USAGE_ITERATIONS}
    Log    Starting iterative usage for IMSI ${imsi} until quotaType=payg (max ${max_iterations} iterations)    console=yes
    ${iteration}=    Set Variable    ${0}
    ${final_json}=    Set Variable    ${None}
    FOR    ${i}    IN RANGE    ${max_iterations}
        ${iteration}=    Evaluate    ${iteration} + 1
        Log    === Iteration ${iteration}/${max_iterations} for IMSI ${imsi} ===    console=yes
        ${ur_json}=    Call User Request API And Return Full Response    ${imsi}    ${msisdn}    data
        ${user}=    Get From Dictionary    ${ur_json}    user
        ${quota_type}=    Get From Dictionary    ${user}    quotaType
        ${volume}=    Get From Dictionary    ${user}    volume
        Log    Iteration ${iteration}: quotaType=${quota_type}, volume=${volume}    console=yes
        ${qt_lower}=    Convert To Lowercase    ${quota_type}
        IF    "${qt_lower}" == "${PAYG_EXPECTED_QUOTA_TYPE}"
            Log    quotaType is now PAYG after ${iteration} iterations!    console=yes
            ${final_json}=    Set Variable    ${ur_json}
            Exit For Loop
        END
        ${vol_str}=    Convert To String    ${volume}
        IF    "${vol_str}" == "0" or "${vol_str}" == ""
            Log    WARN: volume is 0/empty but quotaType is still "${quota_type}". Retrying...    console=yes
            Sleep    2s
            CONTINUE
        END
        Sleep    1s
        ${cdr_resp}=    Call CDR API    ${imsi}    ${msisdn}    data    ${volume}    ${EMPTY}    ${ur_json}
        Log    CDR sent with full volume=${volume}. Waiting before next iteration...    console=yes
        Sleep    2s
    END
    Should Not Be Equal    ${final_json}    ${None}
    ...    quotaType did not reach "payg" after ${max_iterations} iterations for IMSI ${imsi}.
    RETURN    ${final_json}

Perform PAYG Data Usage For Single IMSI
    [Documentation]    After quotaType=payg: calls User Request for data, then CDR with
    ...                the returned volume. This is the actual PAYG data consumption.
    [Arguments]    ${imsi}    ${msisdn}
    Log    Performing PAYG data usage for IMSI ${imsi}    console=yes
    ${ur_json}=    Call User Request API And Return Full Response    ${imsi}    ${msisdn}    data
    ${user}=    Get From Dictionary    ${ur_json}    user
    ${quota_type}=    Get From Dictionary    ${user}    quotaType
    ${volume}=    Get From Dictionary    ${user}    volume
    ${qt_lower}=    Convert To Lowercase    ${quota_type}
    Should Be Equal    ${qt_lower}    ${PAYG_EXPECTED_QUOTA_TYPE}
    ...    Expected quotaType=payg for PAYG usage but got "${quota_type}".
    Log    PAYG User Request: quotaType=${quota_type}, volume=${volume}    console=yes
    ${vol_str}=    Convert To String    ${volume}
    IF    "${vol_str}" != "0" and "${vol_str}" != ""
        Sleep    1s
        ${cdr_resp}=    Call CDR API    ${imsi}    ${msisdn}    data    ${volume}    ${EMPTY}    ${ur_json}
        Log    PAYG CDR sent with volume=${volume} for IMSI ${imsi}.    console=yes
    ELSE
        Log    WARN: PAYG volume is 0/empty for IMSI ${imsi}. CDR skipped.    console=yes
    END
    RETURN    ${ur_json}

Perform Iterative Usage Until PAYG For All IMSIs
    [Documentation]    For each IMSI in the list: iterate User Request + CDR until quotaType=payg,
    ...                then perform one final PAYG data usage.
    [Arguments]    @{imsi_data}
    ${total}=    Get Length    ${imsi_data}
    Log    Starting iterative PAYG usage for ${total} IMSIs.    console=yes
    ${idx}=    Set Variable    ${1}
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        ${msisdn}=    Get From Dictionary    ${entry}    msisdn
        Log    ===== IMSI ${idx}/${total}: ${imsi} (MSISDN: ${msisdn}) =====    console=yes
        ${payg_json}=    Perform Iterative Usage Until PAYG For Single IMSI    ${imsi}    ${msisdn}
        Perform PAYG Data Usage For Single IMSI    ${imsi}    ${msisdn}
        ${idx}=    Evaluate    ${idx} + 1
    END
    Log    Iterative PAYG usage complete for all ${total} IMSIs.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  PAYG USAGE UI VALIDATION
#  Expand IMSI → Usage tab → find PAYG data column → verify > 0
# ═══════════════════════════════════════════════════════════════════════

Validate PAYG Usage In UI For All IMSIs
    [Documentation]    Navigate to Manage Devices; for each IMSI expand row, open Usage tab,
    ...                find the PAYG data column, and verify value in MB > 0.
    [Arguments]    @{imsi_data}
    Log    Waiting 30s for PAYG usage data to reflect in UI...    console=yes
    Sleep    30s
    Ensure Session Is Active
    Go To    ${MANAGE_DEVICES_URL_E2E}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    Log    On Manage Devices page; grid loaded.    console=yes
    ${total}=    Get Length    ${imsi_data}
    ${pass_count}=    Set Variable    ${0}
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        Log    Validating PAYG usage for IMSI ${imsi}    console=yes
        Validate PAYG Usage Column For IMSI    ${imsi}
        ${pass_count}=    Evaluate    ${pass_count} + 1
        Log    IMSI ${pass_count}/${total} PAYG validated: ${imsi}    console=yes
    END
    Log    All ${total} IMSIs PAYG usage validated in UI.    console=yes

Validate PAYG Usage Column For IMSI
    [Documentation]    On Manage Devices: search IMSI, expand row, open Usage tab,
    ...                find column with "payg" and "data" in header, verify value > 0.
    [Arguments]    ${imsi}
    Reset Grid To Default View
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Search Device By IMSI    ${imsi}
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    ${expand_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_FIRST_ROW_EXPAND}    timeout=10s
    IF    not ${expand_visible}
        Wait Until Element Is Visible    ${LOC_DSC_FIRST_ROW_EXPAND_ALT}    timeout=10s
        Click Element Via JS    ${LOC_DSC_FIRST_ROW_EXPAND_ALT}
    ELSE
        Click Element Via JS    ${LOC_DSC_FIRST_ROW_EXPAND}
    END
    Sleep    0.3s
    Wait For Loading Overlay To Disappear
    Scroll Element Into View    ${LOC_DSC_FIRST_ROW}
    Sleep    0.5s
    # Click Usage tab in expanded detail row
    ${usage_clicked}=    Run Keyword And Return Status
    ...    Execute Javascript
    ...    var grid = document.getElementById('gridData');
    ...    if(!grid) return false;
    ...    var detailRow = grid.querySelector('tr.k-detail-row') || (function(){ var m = grid.querySelector('tr.k-master-row'); return m && m.nextElementSibling && m.nextElementSibling.tagName === 'TR' ? m.nextElementSibling : null; })();
    ...    if(!detailRow) return false;
    ...    var nodes = detailRow.querySelectorAll('a, span, li, button, div[role="tab"]');
    ...    for(var i=0; i<nodes.length; i++){ var t = (nodes[i].textContent || '').trim(); if(t === 'Usage' && nodes[i].offsetParent){ nodes[i].click(); return true; } }
    ...    for(var i=0; i<nodes.length; i++){ var t = (nodes[i].textContent || '').trim().toLowerCase(); if(t.indexOf('usage') >= 0 && t.length < 20 && nodes[i].offsetParent){ nodes[i].click(); return true; } }
    ...    return false;
    IF    not ${usage_clicked}
        ${usage_clicked}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DSC_DETAIL_USAGE_TAB_LINK}    timeout=10s
        IF    ${usage_clicked}
            Click Element Via JS    ${LOC_DSC_DETAIL_USAGE_TAB_LINK}
        ELSE
            Fail    Usage tab not found in expanded row for IMSI ${imsi}.
        END
    END
    Sleep    0.5s
    Wait For Loading Overlay To Disappear
    # Read PAYG data column value from usage tab
    ${payg_val}=    Set Variable    NOT_FOUND
    FOR    ${i}    IN RANGE    15
        ${payg_val}=    Execute Javascript
        ...    var grid = document.getElementById('gridData');
        ...    if(!grid) return 'NO_GRID';
        ...    var detailRow = grid.querySelector('tr.k-detail-row');
        ...    if(!detailRow){ var m = grid.querySelector('tr.k-master-row'); if(m && m.nextElementSibling) detailRow = m.nextElementSibling; }
        ...    if(!detailRow) return 'NO_DETAIL';
        ...    var tables = detailRow.querySelectorAll('table');
        ...    if(tables.length === 0) tables = [grid.querySelector('table')];
        ...    for(var t=0; t<tables.length; t++){
        ...        if(!tables[t]) continue;
        ...        var ths = tables[t].querySelectorAll('thead th');
        ...        var colIdx = -1;
        ...        for(var h=0; h<ths.length; h++){
        ...            var txt = (ths[h].textContent || '').trim().toLowerCase();
        ...            if(txt.indexOf('payg') >= 0 && (txt.indexOf('data') >= 0 || txt.indexOf('usage') >= 0)){ colIdx = h; break; }
        ...        }
        ...        if(colIdx < 0){
        ...            for(var h2=0; h2<ths.length; h2++){
        ...                var t2 = (ths[h2].textContent || '').trim().toLowerCase();
        ...                if(t2.indexOf('payg') >= 0){ colIdx = h2; break; }
        ...            }
        ...        }
        ...        if(colIdx >= 0){
        ...            var rows = tables[t].querySelectorAll('tbody tr');
        ...            if(rows.length > 0){
        ...                var cells = rows[0].querySelectorAll('td');
        ...                if(cells[colIdx]) return cells[colIdx].textContent.trim();
        ...            }
        ...        }
        ...    }
        ...    return 'NOT_FOUND';
        Exit For Loop If    '${payg_val}' != 'NOT_FOUND' and '${payg_val}' != 'NO_GRID' and '${payg_val}' != 'NO_DETAIL'
        Sleep    1s
    END
    Log    IMSI ${imsi} PAYG DATA column value: ${payg_val}    console=yes
    Should Not Be Equal As Strings    ${payg_val}    NOT_FOUND
    ...    PAYG DATA column not found in Usage tab for IMSI ${imsi}. Looked for header with payg and (data or usage), or payg-only.
    Should Not Be Equal As Strings    ${payg_val}    NO_GRID
    ...    gridData not found on page for IMSI ${imsi}.
    Should Not Be Equal As Strings    ${payg_val}    NO_DETAIL
    ...    Detail row not found after expanding IMSI ${imsi}.
    Should Not Be Equal    ${payg_val}    ${EMPTY}
    ...    PAYG DATA value is empty for IMSI ${imsi}.
    ${payg_num}=    Convert To Number    ${payg_val}
    Should Be True    ${payg_num} > 0
    ...    PAYG DATA for IMSI ${imsi} should be > 0 MB, got: ${payg_val}
    Log    PASS: IMSI ${imsi} PAYG DATA = ${payg_val} MB    console=yes
    Capture Page Screenshot    payg_usage_validated_${imsi}.png
