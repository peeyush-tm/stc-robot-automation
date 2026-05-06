*** Settings ***
Documentation     Standalone harness for the post-UI SOAP fingerprint flows. Use to re-run just
...               the SOAP orchestration when the UI Activate / Suspend / Resume action has already
...               been performed (e.g. SIMs sitting in IN_PROGRESS / Async state in the grid).
...
...               Suite Setup loads env config so ${FINGERPRINT_PERMISSION_URL} / ${RESPONSE_HANDLER_URL}
...               / ${ONBOARD_AUTH_HEADER} / DB credentials are populated. No browser is launched.
Library           ../libraries/ConfigLoader.py
Resource          ../resources/keywords/fingerprint_permission_keywords.resource

Suite Setup       Load Environment Config From Json    ${ENV}


*** Variables ***
# Provide via CLI: --variable FP_IMSI_LIST:IMSI1,IMSI2,...  --variable FP_MSISDN_LIST:MSISDN1,MSISDN2,...
${FP_IMSI_LIST}        ${EMPTY}
${FP_MSISDN_LIST}      ${EMPTY}
# For single-IMSI suspend / resume tests
${FP_IMSI}             ${EMPTY}


*** Test Cases ***
TC_FP_ACTIVATION Run Activation Fingerprint Flow For Given IMSIs And MSISDNs
    [Documentation]    Runs setOperationStatus (with all MSISDNs) + per-IMSI ResponseHandlerService.
    ...                Pass paired CSV lists via --variable. Order matters; index 0 is IMSI0/MSISDN0.
    [Tags]    fp-activation    standalone    TC_FP_ACTIVATION
    Should Not Be Empty    ${FP_IMSI_LIST}      msg=Pass --variable FP_IMSI_LIST:IMSI1,IMSI2,...
    Should Not Be Empty    ${FP_MSISDN_LIST}    msg=Pass --variable FP_MSISDN_LIST:MSISDN1,MSISDN2,...
    @{imsis}=     Split String    ${FP_IMSI_LIST}      ,
    @{msisdns}=   Split String    ${FP_MSISDN_LIST}    ,
    ${ic}=    Get Length    ${imsis}
    ${mc}=    Get Length    ${msisdns}
    Should Be Equal As Numbers    ${ic}    ${mc}
    ...    msg=IMSI count (${ic}) and MSISDN count (${mc}) must match.
    @{imsi_data}=    Create List
    FOR    ${i}    IN RANGE    ${ic}
        ${entry}=    Create Dictionary    imsi=${imsis}[${i}]    msisdn=${msisdns}[${i}]
        Append To List    ${imsi_data}    ${entry}
    END
    Log    Activation flow for ${ic} IMSI(s)    console=yes
    FP Process Activation Fingerprint Flow    @{imsi_data}

TC_FP_SUSPEND Run Suspend ResponseHandler Flow For Given IMSI
    [Documentation]    Single-IMSI flow: wait 60s → DB query → ResponseHandlerService → settle.
    ...                Use after the UI has already submitted the Suspend action.
    [Tags]    fp-suspend    standalone    TC_FP_SUSPEND
    Should Not Be Empty    ${FP_IMSI}    msg=Pass --variable FP_IMSI:<imsi>
    FP Process Single IMSI Transaction Flow    ${FP_IMSI}    state_label=Suspend

TC_FP_RESUME Run Resume ResponseHandler Flow For Given IMSI
    [Documentation]    Single-IMSI flow: wait 60s → DB query → ResponseHandlerService → settle.
    ...                Use after the UI has already submitted the Resume action.
    [Tags]    fp-resume    standalone    TC_FP_RESUME
    Should Not Be Empty    ${FP_IMSI}    msg=Pass --variable FP_IMSI:<imsi>
    FP Process Single IMSI Transaction Flow    ${FP_IMSI}    state_label=Resume
