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
