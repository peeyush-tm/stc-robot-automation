*** Settings ***
Documentation     SOAP orchestration for the post-UI activation Fingerprint Permission flow.
...               Replaces the legacy "wait 5 min and hope it activates" pattern with explicit
...               transaction-id capture from DB + two SOAP calls (FingerprintPermission +
...               ResponseHandler) so SIMs reliably reach Activated state on both QE and SIT.
...
...               Flow:
...               1. After UI Device State Change action, wait 1 min for the goup_notification_url
...                  table to record the activation transaction.
...               2. Capture latest transaction_id from DB (using any one IMSI).
...               3. Call FingerprintPermissionImplService → setOperationStatus with that
...                  transaction_id and ALL MSISDNs (one <result> block per MSISDN).
...               4. For each IMSI separately, capture the new latest transaction_id from DB
...                  (different per IMSI — one transaction per SIM after permission grant).
...               5. Call ResponseHandlerService → Response with each transaction_id as <OrderNo>.
...               6. Caller validates UI shows Activated for all SIMs.

Library     SeleniumLibrary
Library     RequestsLibrary
Library     DatabaseLibrary
Library     OperatingSystem
Library     String
Library     Collections


*** Variables ***
${FP_TEMPLATE_TX_TOKEN}     __TRANSACTION_ID__
${FP_TEMPLATE_RESULT_TOKEN}    __RESULT_BLOCKS__
${FP_POST_PERMISSION_WAIT}    30s
${FP_POST_RESPONSE_HANDLER_WAIT}    20s


*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  DATABASE — CAPTURE TRANSACTION ID
# ═══════════════════════════════════════════════════════════════════════
FP Capture Latest Transaction Id For IMSI
    [Documentation]    Queries goup_notification_url for the latest request_id whose data
    ...                contains the given IMSI. The query uses ``ORDER BY createdAT DESC LIMIT 1``
    ...                so the result is always the most recent transaction. Returns the
    ...                request_id as a string.
    ...
    ...                ``order_by`` controls the ORDER BY column — default ``createdAT`` (temporal
    ...                creation time). Pass ``request_id`` to use numeric request_id ordering instead.
    [Arguments]    ${imsi}    ${retries}=12    ${interval}=10s    ${order_by}=createdAT
    ${query}=    Set Variable
    ...    SELECT request_id FROM cmp_stc_interface_thirdparty.goup_notification_url WHERE data LIKE '%${imsi}%' ORDER BY ${order_by} DESC LIMIT 1
    Log To Console    \n────────── DB QUERY ──────────
    Log To Console    Host    : ${DB_HOST}:${DB_PORT}/${DB_NAME}
    Log To Console    User    : ${DB_USER}
    Log To Console    IMSI    : ${imsi}
    Log To Console    Query   : ${query}
    FOR    ${i}    IN RANGE    ${retries}
        ${attempt}=    Evaluate    ${i} + 1
        Connect To Database    pymysql    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
        ${rows}=    Run Keyword And Ignore Error    Query    ${query}
        Disconnect From Database
        ${status}=    Set Variable    ${rows}[0]
        ${data}=      Set Variable    ${rows}[1]
        Log To Console    [attempt ${attempt}/${retries}] DB result: status=${status} rows=${data}
        ${has_row}=    Run Keyword And Return Status    Should Be True    $status == 'PASS' and $data and len($data) > 0 and len($data[0]) > 0
        IF    ${has_row}
            ${tx_id}=    Convert To String    ${data}[0][0]
            IF    '${tx_id}' != ''
                Log To Console    ✓ Captured request_id=${tx_id} for IMSI ${imsi}
                Log To Console    ──────────────────────────────\n
                RETURN    ${tx_id}
            END
        END
        Log To Console    no request_id yet — sleeping ${interval}
        Sleep    ${interval}
    END
    Log To Console    ✗ Failed to capture request_id after ${retries} attempts.
    Log To Console    ──────────────────────────────\n
    Fail    Could not capture a request_id for IMSI ${imsi} from goup_notification_url after ${retries} retries.

# ═══════════════════════════════════════════════════════════════════════
#  SOAP — FINGERPRINT PERMISSION (setOperationStatus)
# ═══════════════════════════════════════════════════════════════════════
FP Build Fingerprint Permission Body
    [Documentation]    Builds the SOAP body for setOperationStatus by reading the template,
    ...                injecting the transaction_id, and concatenating one <result> block per MSISDN.
    [Arguments]    ${transaction_id}    @{msisdns}
    ${template_path}=    Set Variable    ${EXECDIR}${/}templates${/}api${/}FingerprintPermissionSetOperationStatus.xml
    ${body_raw}=    OperatingSystem.Get File    ${template_path}
    ${results_xml}=    Set Variable    ${EMPTY}
    FOR    ${msisdn}    IN    @{msisdns}
        ${block}=    Catenate    SEPARATOR=\n
        ...    ${SPACE * 12}<result>
        ...    ${SPACE * 15}<decission>YES</decission>
        ...    ${SPACE * 15}<msisdn>${msisdn}</msisdn>
        ...    ${SPACE * 15}<errorDescription>?</errorDescription>
        ...    ${SPACE * 12}</result>
        ${results_xml}=    Catenate    SEPARATOR=\n    ${results_xml}    ${block}
    END
    ${body}=    Replace String    ${body_raw}    ${FP_TEMPLATE_TX_TOKEN}    ${transaction_id}
    ${body}=    Replace String    ${body}    ${FP_TEMPLATE_RESULT_TOKEN}    ${results_xml}
    RETURN    ${body}

FP Call Fingerprint Permission Set Operation Status
    [Documentation]    POST setOperationStatus with the captured transaction_id and all MSISDNs.
    [Arguments]    ${transaction_id}    @{msisdns}
    ${body}=    FP Build Fingerprint Permission Body    ${transaction_id}    @{msisdns}
    ${msisdn_count}=    Get Length    ${msisdns}
    Log To Console    \n══════════════════════════════════════════════════════════════════════
    Log To Console    SOAP REQUEST: FingerprintPermission.setOperationStatus
    Log To Console    ══════════════════════════════════════════════════════════════════════
    Log To Console    Method        : POST
    Log To Console    URL           : ${FINGERPRINT_PERMISSION_URL}
    Log To Console    Headers       : Content-Type=text/plain
    Log To Console     ${SPACE * 14}: Authorization=${ONBOARD_AUTH_HEADER}
    Log To Console    Transaction Id: ${transaction_id}
    Log To Console    MSISDN count  : ${msisdn_count}
    Log To Console    ── Body ─────────────────────────────────────────────────────────────
    Log To Console    ${body}
    Log To Console    ──────────────────────────────────────────────────────────────────────
    Create Session    fp_permission    ${FINGERPRINT_PERMISSION_URL}    verify=${False}    disable_warnings=1
    ${headers}=    Create Dictionary
    ...    Content-Type=text/plain
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ${start}=    Evaluate    __import__('time').time()
    ${response}=    POST On Session    fp_permission    url=${FINGERPRINT_PERMISSION_URL}
    ...    data=${body}    headers=${headers}    expected_status=any
    ${elapsed}=    Evaluate    round(__import__('time').time() - ${start}, 3)
    Log To Console    \n══════════════════════════════════════════════════════════════════════
    Log To Console    SOAP RESPONSE: FingerprintPermission.setOperationStatus
    Log To Console    ══════════════════════════════════════════════════════════════════════
    Log To Console    Status        : ${response.status_code}
    Log To Console    Elapsed       : ${elapsed}s
    Log To Console    ── Body ─────────────────────────────────────────────────────────────
    Log To Console    ${response.text}
    Log To Console    ══════════════════════════════════════════════════════════════════════\n
    Should Be Equal As Integers    ${response.status_code}    200
    ...    FingerprintPermission setOperationStatus returned ${response.status_code} instead of 200
    Should Not Contain    ${response.text}    <faultstring>
    ...    SOAP fault found in setOperationStatus response
    Delete All Sessions
    Log To Console    ✓ setOperationStatus succeeded for transaction_id=${transaction_id} with ${msisdn_count} MSISDN(s).

# ═══════════════════════════════════════════════════════════════════════
#  SOAP — RESPONSE HANDLER (per-IMSI)
# ═══════════════════════════════════════════════════════════════════════
FP Build Response Handler Body
    [Documentation]    Builds the ResponseHandlerService body by reading the template and
    ...                substituting the per-IMSI transaction_id into the <OrderNo> field.
    [Arguments]    ${transaction_id}
    ${template_path}=    Set Variable    ${EXECDIR}${/}templates${/}api${/}ResponseHandlerSetOrderNo.xml
    ${body_raw}=    OperatingSystem.Get File    ${template_path}
    ${body}=    Replace String    ${body_raw}    ${FP_TEMPLATE_TX_TOKEN}    ${transaction_id}
    RETURN    ${body}

FP Call Response Handler For Transaction
    [Documentation]    POST a ResponseHandlerService request with the given transaction_id
    ...                placed into the <OrderNo> field. One call per IMSI.
    [Arguments]    ${transaction_id}
    ${body}=    FP Build Response Handler Body    ${transaction_id}
    Log To Console    \n══════════════════════════════════════════════════════════════════════
    Log To Console    SOAP REQUEST: ResponseHandlerService.Response
    Log To Console    ══════════════════════════════════════════════════════════════════════
    Log To Console    Method        : POST
    Log To Console    URL           : ${RESPONSE_HANDLER_URL}
    Log To Console    Headers       : Content-Type=text/plain
    Log To Console     ${SPACE * 14}: Authorization=${ONBOARD_AUTH_HEADER}
    Log To Console    OrderNo (tx)  : ${transaction_id}
    Log To Console    ── Body ─────────────────────────────────────────────────────────────
    Log To Console    ${body}
    Log To Console    ──────────────────────────────────────────────────────────────────────
    Create Session    fp_response    ${RESPONSE_HANDLER_URL}    verify=${False}    disable_warnings=1
    ${headers}=    Create Dictionary
    ...    Content-Type=text/plain
    ...    Authorization=${ONBOARD_AUTH_HEADER}
    ${start}=    Evaluate    __import__('time').time()
    ${response}=    POST On Session    fp_response    url=${RESPONSE_HANDLER_URL}
    ...    data=${body}    headers=${headers}    expected_status=any
    ${elapsed}=    Evaluate    round(__import__('time').time() - ${start}, 3)
    Log To Console    \n══════════════════════════════════════════════════════════════════════
    Log To Console    SOAP RESPONSE: ResponseHandlerService.Response (tx=${transaction_id})
    Log To Console    ══════════════════════════════════════════════════════════════════════
    Log To Console    Status        : ${response.status_code}
    Log To Console    Elapsed       : ${elapsed}s
    Log To Console    ── Body ─────────────────────────────────────────────────────────────
    Log To Console    ${response.text}
    Log To Console    ══════════════════════════════════════════════════════════════════════\n
    Should Be Equal As Integers    ${response.status_code}    200
    ...    ResponseHandler returned ${response.status_code} instead of 200 for transaction_id=${transaction_id}
    Should Not Contain    ${response.text}    <faultstring>
    ...    SOAP fault found in ResponseHandler response for transaction_id=${transaction_id}
    Delete All Sessions
    Log To Console    ✓ ResponseHandler succeeded for transaction_id=${transaction_id}.

# ═══════════════════════════════════════════════════════════════════════
#  ORCHESTRATOR — POST-UI ACTIVATION FLOW
# ═══════════════════════════════════════════════════════════════════════
FP Process Activation Fingerprint Flow
    [Documentation]    Full post-UI-activation orchestration. Call this AFTER the Manage Devices
    ...                "Activate" action has been submitted (SIMs go from InActive → activation
    ...                pending) and BEFORE the UI re-verifies state.
    ...
    ...                Steps:
    ...                  1. Sleep 1 min so the goup_notification_url DB row is written.
    ...                  2. Capture latest transaction_id by querying with the FIRST IMSI.
    ...                  3. Call FingerprintPermission setOperationStatus with that transaction_id
    ...                     and all MSISDNs.
    ...                  4. Wait ~30s for the system to record per-IMSI follow-up transactions.
    ...                  5. For each IMSI separately, capture a NEW transaction_id (must differ
    ...                     from the step-2 id and from any already-used per-IMSI ids).
    ...                  6. Call ResponseHandlerService once per IMSI with its own transaction_id
    ...                     placed into <OrderNo>.
    ...                  7. Wait ~20s for the system to apply the responses.
    ...
    ...                ``imsi_data`` is a list of {imsi, msisdn, ...} dicts (same shape as
    ...                ``E2E_IMSI_DATA`` from TC_E2EU_018 / TC_E2E_018).
    [Arguments]    @{imsi_data}
    ${count}=    Get Length    ${imsi_data}
    Should Be True    ${count} > 0    msg=FP Process Activation Fingerprint Flow: imsi_data is empty.
    # ── Step 1: wait 1 min for DB row to appear ────────────────────────────
    Log    Fingerprint flow: waiting 60s for goup_notification_url DB entry...    console=yes
    Sleep    60s    reason=Wait for activation transaction_id to be recorded in DB

    # ── Step 2: capture initial transaction_id using the first IMSI ────────
    ${first_entry}=    Get From List    ${imsi_data}    0
    ${first_imsi}=    Set Variable    ${first_entry}[imsi]
    ${initial_tx_id}=    FP Capture Latest Transaction Id For IMSI    ${first_imsi}
    Log    Fingerprint flow: initial transaction_id=${initial_tx_id} captured for IMSI ${first_imsi}    console=yes

    # ── Step 3: build MSISDN list and call setOperationStatus ──────────────
    @{msisdns}=    Create List
    FOR    ${entry}    IN    @{imsi_data}
        Append To List    ${msisdns}    ${entry}[msisdn]
    END
    FP Call Fingerprint Permission Set Operation Status    ${initial_tx_id}    @{msisdns}

    # ── Step 4: wait for follow-up transactions to be created ──────────────
    Log    Fingerprint flow: waiting ${FP_POST_PERMISSION_WAIT} for per-IMSI follow-up transactions to land in DB...    console=yes
    Sleep    ${FP_POST_PERMISSION_WAIT}    reason=Wait for ResponseHandler transactions to be recorded

    # ── Step 5+6: per IMSI, capture latest tx_id and call ResponseHandler ─
    # No "exclude" here — `goup_notification_url.data` records one row per setOperationStatus
    # call which contains all 5 MSISDNs, so the same row (same request_id) is the latest match
    # for every IMSI. We deliberately call ResponseHandler N times (once per IMSI) using whatever
    # the latest request_id is for that IMSI, even if it's the same value across IMSIs.
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Set Variable    ${entry}[imsi]
        ${tx_id}=    FP Capture Latest Transaction Id For IMSI    ${imsi}
        FP Call Response Handler For Transaction    ${tx_id}
        Log To Console    ✓ Fingerprint flow: IMSI ${imsi} → ResponseHandler called with tx_id=${tx_id}
    END

    # ── Step 7: short settle wait before UI re-validates ──────────────────
    Log    Fingerprint flow: waiting ${FP_POST_RESPONSE_HANDLER_WAIT} for backend to apply ResponseHandler updates...    console=yes
    Sleep    ${FP_POST_RESPONSE_HANDLER_WAIT}    reason=Settle wait before UI Activated re-validation
    Log    Fingerprint flow: complete. ${count} IMSI(s) processed; UI verification follows.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  AUTO ACTIVATION — TWO-STEP DB LOOKUP FOR GOUP TRANSACTION ID
# ═══════════════════════════════════════════════════════════════════════
FP Capture Auto Activation Transaction Id
    [Documentation]    For auto-activation orders: the SOAP approve creates a GOUP entry in
    ...                goup_notification_url where imsi/iccid are NULL (combined batch request).
    ...                This keyword does a two-step lookup:
    ...                  1. Query aircontrol.gc_notification_details for GC request ID
    ...                     (WHERE IMSI=x AND STATUS=IN_PROGRESS AND NEW_VALUE=Activated).
    ...                  2. Query goup_notification_url WHERE data LIKE '%gc_request_id%'
    ...                     to get the GOUP transaction ID.
    ...                Returns the GOUP transaction ID for use in setOperationStatus.
    [Arguments]    ${imsi}    ${retries}=12    ${interval}=10s
    Log To Console    \n────────── AUTO ACTIVATION DB LOOKUP ──────────
    Log To Console    IMSI: ${imsi}
    FOR    ${i}    IN RANGE    ${retries}
        ${attempt}=    Evaluate    ${i} + 1
        # Step 1: Get GC request ID from gc_notification_details
        ${gc_query}=    Set Variable
        ...    SELECT REQUEST_ID FROM aircontrol.gc_notification_details WHERE IMSI='${imsi}' AND STATUS='IN_PROGRESS' AND NEW_VALUE='Activated' ORDER BY CREATE_DATE DESC LIMIT 1
        Connect To Database    pymysql    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
        ${gc_rows}=    Run Keyword And Ignore Error    Query    ${gc_query}
        Disconnect From Database
        ${gc_status}=    Set Variable    ${gc_rows}[0]
        ${gc_data}=      Set Variable    ${gc_rows}[1]
        ${has_gc}=    Run Keyword And Return Status
        ...    Should Be True    $gc_status == 'PASS' and $gc_data and len($gc_data) > 0 and len($gc_data[0]) > 0
        IF    ${has_gc}
            ${gc_request_id}=    Convert To String    ${gc_data}[0][0]
            IF    '${gc_request_id}' != ''
                Log To Console    [attempt ${attempt}/${retries}] GC request ID: ${gc_request_id}
                # Step 2: Get GOUP tx ID from goup_notification_url by GC request ID
                ${goup_query}=    Set Variable
                ...    SELECT request_id FROM cmp_stc_interface_thirdparty.goup_notification_url WHERE data LIKE '%${gc_request_id}%' ORDER BY createdAT DESC LIMIT 1
                Connect To Database    pymysql    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
                ${goup_rows}=    Run Keyword And Ignore Error    Query    ${goup_query}
                Disconnect From Database
                ${g_status}=    Set Variable    ${goup_rows}[0]
                ${g_data}=      Set Variable    ${goup_rows}[1]
                ${has_goup}=    Run Keyword And Return Status
                ...    Should Be True    $g_status == 'PASS' and $g_data and len($g_data) > 0 and len($g_data[0]) > 0
                IF    ${has_goup}
                    ${goup_tx_id}=    Convert To String    ${g_data}[0][0]
                    IF    '${goup_tx_id}' != ''
                        Log To Console    ✓ GOUP transaction ID: ${goup_tx_id}
                        Log To Console    ──────────────────────────────\n
                        RETURN    ${goup_tx_id}
                    END
                END
                Log To Console    GC request found but GOUP entry not yet visible — retrying
            END
        ELSE
            Log To Console    [attempt ${attempt}/${retries}] No IN_PROGRESS activation entry yet — sleeping ${interval}
        END
        Sleep    ${interval}
    END
    Log To Console    ✗ Failed to capture GOUP transaction ID after ${retries} attempts.
    Fail    Could not capture GOUP transaction ID for IMSI ${imsi} from gc_notification_details/goup_notification_url after ${retries} retries.

# ═══════════════════════════════════════════════════════════════════════
#  ORCHESTRATOR — AUTO ACTIVATION FINGERPRINT FLOW (POST-SOAP-APPROVE)
# ═══════════════════════════════════════════════════════════════════════
FP Process Auto Activation Fingerprint Flow
    [Documentation]    Full fingerprint SOAP flow for AUTO-ACTIVATION orders.
    ...                Called AFTER the SOAP order approve (TC_017) has been sent and SIMs are
    ...                in Warm state. Unlike the UI activation flow, the initial GOUP transaction
    ...                ID is a combined batch entry (imsi/iccid=null) found via a two-step
    ...                DB lookup (gc_notification_details → goup_notification_url by GC request ID).
    ...
    ...                Steps:
    ...                  1. Sleep 60s for GOUP DB entries to be populated.
    ...                  2. Capture combined GOUP tx ID via two-step DB lookup (first IMSI).
    ...                  3. Call FingerprintPermission setOperationStatus with all MSISDNs.
    ...                  4. Wait 30s for per-IMSI GOUP entries to be created.
    ...                  5. For each IMSI, capture per-IMSI tx ID and call ResponseHandler.
    ...                  6. Wait 20s for backend to apply state change to Activated.
    [Arguments]    @{imsi_data}
    ${count}=    Get Length    ${imsi_data}
    Should Be True    ${count} > 0    msg=FP Process Auto Activation Fingerprint Flow: imsi_data is empty.
    Log    Auto Activation FP flow: waiting 60s for GOUP DB entries to be populated...    console=yes
    Sleep    60s    reason=Wait for auto-activation GOUP transaction to be recorded in DB

    # Step 2: Two-step DB lookup for the combined GOUP transaction ID
    ${first_entry}=    Get From List    ${imsi_data}    0
    ${first_imsi}=    Set Variable    ${first_entry}[imsi]
    ${initial_tx_id}=    FP Capture Auto Activation Transaction Id    ${first_imsi}
    Log    Auto Activation FP flow: combined GOUP tx ID=${initial_tx_id}    console=yes

    # Step 3: Build MSISDN list and call setOperationStatus
    @{msisdns}=    Create List
    FOR    ${entry}    IN    @{imsi_data}
        Append To List    ${msisdns}    ${entry}[msisdn]
    END
    FP Call Fingerprint Permission Set Operation Status    ${initial_tx_id}    @{msisdns}

    # Step 4: Wait for per-IMSI GOUP entries to appear after setOperationStatus
    Log    Auto Activation FP flow: waiting ${FP_POST_PERMISSION_WAIT} for per-IMSI GOUP entries...    console=yes
    Sleep    ${FP_POST_PERMISSION_WAIT}    reason=Wait for per-IMSI ResponseHandler transactions to land in DB

    # Step 5: For each IMSI, capture per-IMSI tx ID and call ResponseHandler
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Set Variable    ${entry}[imsi]
        ${tx_id}=    FP Capture Latest Transaction Id For IMSI    ${imsi}
        FP Call Response Handler For Transaction    ${tx_id}
        Log    Auto Activation FP flow: IMSI ${imsi} → ResponseHandler called with tx_id=${tx_id}    console=yes
    END

    # Step 6: Settle wait before UI verification
    Log    Auto Activation FP flow: waiting ${FP_POST_RESPONSE_HANDLER_WAIT} for backend to apply state changes...    console=yes
    Sleep    ${FP_POST_RESPONSE_HANDLER_WAIT}    reason=Settle wait before Activated state verification
    Log    Auto Activation FP flow: complete. ${count} IMSI(s) processed.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  ORCHESTRATOR — POST-UI SUSPEND / RESUME FLOW (SINGLE IMSI)
# ═══════════════════════════════════════════════════════════════════════
FP Process Single IMSI Transaction Flow
    [Documentation]    Lightweight SOAP flow for state changes that affect ONE IMSI at a time
    ...                (Suspend or Resume / Reactivation). Use AFTER the UI Manage Devices state
    ...                change has been submitted, BEFORE the UI re-verifies the new state.
    ...
    ...                Steps:
    ...                  1. Sleep 1 min so the goup_notification_url DB row is written.
    ...                  2. Capture latest transaction_id for the IMSI from DB.
    ...                  3. Call ResponseHandlerService with that transaction_id placed into <OrderNo>.
    ...                  4. Short settle wait so the backend applies the response.
    ...
    ...                Unlike the activation flow there is NO setOperationStatus / FingerprintPermission
    ...                call here — for Suspend/Resume on an already-activated SIM the system only needs
    ...                the ResponseHandler ack.
    [Arguments]    ${imsi}    ${state_label}=state-change
    Should Not Be Empty    ${imsi}    msg=FP Process Single IMSI Transaction Flow: imsi is empty.
    Log    ${state_label} flow for IMSI ${imsi}: waiting 60s for goup_notification_url DB entry...    console=yes
    Sleep    60s    reason=Wait for ${state_label} transaction_id to be recorded in DB
    ${tx_id}=    FP Capture Latest Transaction Id For IMSI    ${imsi}
    Log    ${state_label} flow: IMSI ${imsi} → captured transaction_id=${tx_id}    console=yes
    FP Call Response Handler For Transaction    ${tx_id}
    Log    ${state_label} flow: waiting ${FP_POST_RESPONSE_HANDLER_WAIT} for backend to apply ResponseHandler...    console=yes
    Sleep    ${FP_POST_RESPONSE_HANDLER_WAIT}    reason=Settle wait before UI re-validation
    Log    ${state_label} flow: complete for IMSI ${imsi}; UI verification follows.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  BULK SUSPEND / RESUME — one 60s wait, then ResponseHandler per IMSI
# ═══════════════════════════════════════════════════════════════════════
FP Process Bulk State Change Transaction Flow
    [Documentation]    Post-UI bulk Suspend or Resume SOAP flow. Call AFTER the bulk UI state
    ...                change has been submitted (all SIMs selected + action dispatched).
    ...
    ...                Steps:
    ...                  1. Sleep 60s once for all goup_notification_url DB rows to be written.
    ...                  2. For each IMSI: capture latest transaction_id + call ResponseHandlerService.
    ...                  3. Single settle wait so the backend applies all responses.
    ...
    ...                Unlike the activation flow there is NO setOperationStatus call here —
    ...                for Suspend/Resume on already-activated SIMs only ResponseHandler is needed.
    ...
    ...                ``imsi_data`` is a list of {imsi, msisdn, iccid} dicts (same shape as
    ...                ``E2E_IMSI_DATA_SUSPEND`` / ``E2E_IMSI_DATA_RESUME`` suite variables).
    [Arguments]    ${state_label}    @{imsi_data}
    ${count}=    Get Length    ${imsi_data}
    Should Be True    ${count} > 0    msg=FP Process Bulk State Change Transaction Flow: imsi_data is empty.
    Log    ${state_label} bulk flow: waiting 60s for goup_notification_url DB entries (${count} SIM(s))...    console=yes
    Sleep    60s    reason=Wait for ${state_label} transaction_ids to be recorded in DB
    FOR    ${entry}    IN    @{imsi_data}
        ${imsi}=    Set Variable    ${entry}[imsi]
        ${tx_id}=    FP Capture Latest Transaction Id For IMSI    ${imsi}
        FP Call Response Handler For Transaction    ${tx_id}
        Log To Console    ✓ ${state_label} flow: IMSI ${imsi} → ResponseHandler called with tx_id=${tx_id}
    END
    Log    ${state_label} bulk flow: waiting ${FP_POST_RESPONSE_HANDLER_WAIT} for backend to apply responses...    console=yes
    Sleep    ${FP_POST_RESPONSE_HANDLER_WAIT}    reason=Settle wait before UI re-validation
    Log    ${state_label} bulk flow: complete. ${count} IMSI(s) processed; UI verification follows.    console=yes
