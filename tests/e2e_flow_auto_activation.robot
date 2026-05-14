*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Resource    ../resources/keywords/e2e_keywords.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/onboard_customer_variables.py
Variables   ../variables/apn_variables.py
Variables   ../variables/csr_journey_variables.py
Variables   ../variables/sim_range_variables.py
Variables   ../variables/sim_order_variables.py
Variables   ../variables/product_type_variables.py
Variables   ../variables/order_processing_variables.py
Variables   ../variables/device_state_variables.py
Variables   ../variables/e2e_auto_activation_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    E2E Suite Setup
Suite Teardown    Close All Browsers
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Variables ***
${E2E_EC_NAME}              ${EMPTY}
${E2E_BU_NAME}              ${EMPTY}
${E2E_ORDER_ID}             ${EMPTY}
${E2E_EC_ID}                ${EMPTY}
${E2E_BU_ID}                ${EMPTY}
@{E2E_ACTIVATED_IMSIS}
@{E2E_IMSI_DATA}
${E2E_INVOICE_PATH}         ${EMPTY}
${E2E_CSR1_TARIFF_PLAN}     ${EMPTY}
${E2E_CSR1_APN_TYPE}        ${EMPTY}
${E2E_CSR1_APN_NAME}        ${EMPTY}
${E2E_CSR1_BUNDLE_PLAN}     ${EMPTY}
${E2E_CSR1_DP_ALIAS}        ${EMPTY}
${E2E_CSR2_BUNDLE_PLAN}     ${EMPTY}
${E2E_CSR2_DP_ALIAS}        ${EMPTY}

*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  FLOW A — Auto Activation + Activated SIM State
#
#  Tag: e2e_aa_activated
#  Difference from base e2e_flow:
#    TC_008: SIM order with autoActivation + Activated SIM state + Device Plan
#    TC_018: Collect Warm SIMs, drive fingerprint SOAP (setOperationStatus + ResponseHandler), auto-activate
#    TC_018A: SKIPPED — fingerprint SOAP is driven inside TC_018 (E2E Collect Activated IMSI Data)
#    TC_018B: Validates SIMs are Activated in Manage Devices grid
#
#  Run:
#    python run_tests.py tests/e2e_flow_auto_activation.robot --env qe --include e2e_aa_activated
# ═══════════════════════════════════════════════════════════════════════

TC_E2E_AA_ACT_001 Onboard EC And BU Account Via API
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_001    positive
    TC_E2E_AA_ACT_001

TC_E2E_AA_ACT_002 Verify Onboarded Account On UI
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_002    positive
    TC_E2E_AA_ACT_002

TC_E2E_AA_ACT_003 Create APN For Onboarded Account
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_003    positive
    TC_E2E_AA_ACT_003

TC_E2E_AA_ACT_004 Create CSR Journey For Onboarded Account
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_004    positive
    TC_E2E_AA_ACT_004

TC_E2E_AA_ACT_005 Create SIM Range With 5 ICCID IMSI
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_005    positive
    TC_E2E_AA_ACT_005

TC_E2E_AA_ACT_006 Create And Assign SIM Product Type
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_006    positive
    TC_E2E_AA_ACT_006

TC_E2E_AA_ACT_007 Expand EC And BU SIM Limits
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_007    positive
    TC_E2E_AA_ACT_007

TC_E2E_AA_ACT_008 Create SIM Order With Auto Activation And Activated State
    [Documentation]    Creates SIM Order with Auto Activation + Activated SIM state + Device Plan.
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_008    positive
    TC_E2E_AA_ACT_008

TC_E2E_AA_ACT_009 Capture Order ID From Live Order Grid
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_009    positive
    TC_E2E_AA_ACT_009

TC_E2E_AA_ACT_010 Fetch EC And BU Account IDs From Database
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_010    positive    no_sit
    TC_E2E_AA_ACT_010

TC_E2E_AA_ACT_011 Run Create Order Script On Server
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_011    positive    no_sit
    TC_E2E_AA_ACT_011

TC_E2E_AA_ACT_012 Validate Order Status New To In Progress
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_012    positive    no_sit
    TC_E2E_AA_ACT_012

TC_E2E_AA_ACT_013 Generate And Upload Response Files To Server
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_013    positive
    TC_E2E_AA_ACT_013

TC_E2E_AA_ACT_014 Run Read Order Script On Server
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_014    positive    no_sit
    TC_E2E_AA_ACT_014

TC_E2E_AA_ACT_015 Validate Order Status In Progress To Completed
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_015    positive
    TC_E2E_AA_ACT_015

TC_E2E_AA_ACT_016 Validate SIMs In Warm State On Manage Devices
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_016    positive
    TC_E2E_AA_ACT_016

TC_E2E_AA_ACT_017 Update Order Status To Approved Via SOAP API
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_017    positive
    TC_E2E_AA_ACT_017

TC_E2E_AA_ACT_018 Collect IMSI Data From Auto-Activated SIMs
    [Documentation]    Auto Activation (Activated) — no UI activation. Collects IMSI/MSISDN/ICCID
    ...                from already-Activated SIMs in Manage Devices grid.
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_018    positive
    TC_E2E_AA_ACT_018

TC_E2E_AA_ACT_018B Verify All SIMs Activated On UI
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_018B    positive
    TC_E2E_AA_ACT_018B

TC_E2E_AA_ACT_019 Generate Invoice And Download CSV
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_019    positive    no_sit
    TC_E2E_AA_ACT_019

TC_E2E_AA_ACT_020 Create Second CSR Journey With Different Plan
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_020    positive
    TC_E2E_AA_ACT_020

TC_E2E_AA_ACT_021 Perform Device Plan Change On One Activated SIM And Validate
    [Tags]    regression    e2e_aa_activated    TC_E2E_AA_ACT_021    positive
    TC_E2E_AA_ACT_021

# ═══════════════════════════════════════════════════════════════════════
#  FLOW B — Auto Activation + TestActive SIM State
#
#  Tag: e2e_aa_testactive
#  Difference from base e2e_flow:
#    TC_008:  SIM order with autoActivation + TestActive SIM state + Device Plan
#    TC_018:  Collect Warm SIMs → drive auto-FP SOAP (setOperationStatus + ResponseHandler) → SIMs go TestActive
#    TC_018B: Verify all SIMs are in TestActive state on UI
#    TC_018A: UI-activate SIMs from TestActive → Activated (state change via Manage Devices)
#    TC_018C: Drive Activation Fingerprint SOAP Flow (post-UI-activate)
#    TC_018D: Verify all SIMs are Activated in Manage Devices grid
#
#  Run:
#    python run_tests.py tests/e2e_flow_auto_activation.robot --env qe --include e2e_aa_testactive
# ═══════════════════════════════════════════════════════════════════════

TC_E2E_AA_TST_001 Onboard EC And BU Account Via API
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_001    positive
    TC_E2E_AA_TST_001

TC_E2E_AA_TST_002 Verify Onboarded Account On UI
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_002    positive
    TC_E2E_AA_TST_002

TC_E2E_AA_TST_003 Create APN For Onboarded Account
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_003    positive
    TC_E2E_AA_TST_003

TC_E2E_AA_TST_004 Create CSR Journey For Onboarded Account
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_004    positive
    TC_E2E_AA_TST_004

TC_E2E_AA_TST_005 Create SIM Range With 5 ICCID IMSI
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_005    positive
    TC_E2E_AA_TST_005

TC_E2E_AA_TST_006 Create And Assign SIM Product Type
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_006    positive
    TC_E2E_AA_TST_006

TC_E2E_AA_TST_007 Expand EC And BU SIM Limits
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_007    positive
    TC_E2E_AA_TST_007

TC_E2E_AA_TST_008 Create SIM Order
    [Documentation]    Creates SIM Order (nonAutoActivation, no device plan) — SIMs go Warm, TC_018 drives FP SOAP to TestActive.
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_008    positive
    TC_E2E_AA_TST_008

TC_E2E_AA_TST_009 Capture Order ID From Live Order Grid
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_009    positive
    TC_E2E_AA_TST_009

TC_E2E_AA_TST_010 Fetch EC And BU Account IDs From Database
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_010    positive    no_sit
    TC_E2E_AA_TST_010

TC_E2E_AA_TST_011 Run Create Order Script On Server
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_011    positive    no_sit
    TC_E2E_AA_TST_011

TC_E2E_AA_TST_012 Validate Order Status New To In Progress
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_012    positive    no_sit
    TC_E2E_AA_TST_012

TC_E2E_AA_TST_013 Generate And Upload Response Files To Server
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_013    positive
    TC_E2E_AA_TST_013

TC_E2E_AA_TST_014 Run Read Order Script On Server
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_014    positive    no_sit
    TC_E2E_AA_TST_014

TC_E2E_AA_TST_015 Validate Order Status In Progress To Completed
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_015    positive
    TC_E2E_AA_TST_015

TC_E2E_AA_TST_016 Validate SIMs In Warm State On Manage Devices
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_016    positive
    TC_E2E_AA_TST_016

TC_E2E_AA_TST_017 Update Order Status To Approved Via SOAP API
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_017    positive
    TC_E2E_AA_TST_017

TC_E2E_AA_TST_018 Collect IMSI Data From Auto-Activated TestActive SIMs
    [Documentation]    Auto Activation (TestActive) — drives auto-FP SOAP on Warm SIMs; SIMs go to TestActive state.
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_018    positive
    TC_E2E_AA_TST_018

TC_E2E_AA_TST_018B Verify All SIMs In TestActive State On UI
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_018B    positive
    TC_E2E_AA_TST_018B

TC_E2E_AA_TST_018A Activate SIMs From TestActive State Via UI
    [Documentation]    UI-driven activation: selects TestActive SIMs and submits state change to Activated.
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_018A    positive
    TC_E2E_AA_TST_018A

TC_E2E_AA_TST_018C Drive Activation Fingerprint SOAP Flow
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_018C    positive
    TC_E2E_AA_TST_018C

TC_E2E_AA_TST_018D Verify All SIMs Activated On UI
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_018D    positive
    TC_E2E_AA_TST_018D

TC_E2E_AA_TST_019 Generate Invoice And Download CSV
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_019    positive    no_sit
    TC_E2E_AA_TST_019

TC_E2E_AA_TST_020 Create Second CSR Journey With Different Plan
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_020    positive
    TC_E2E_AA_TST_020

TC_E2E_AA_TST_021 Perform Device Plan Change On One Activated SIM And Validate
    [Tags]    regression    e2e_aa_testactive    TC_E2E_AA_TST_021    positive
    TC_E2E_AA_TST_021

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  FLOW A — AUTO ACTIVATION + ACTIVATED SIM STATE
# ═══════════════════════════════════════════════════════════════════════
TC_E2E_AA_ACT_001
    Create Onboard API Session
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    Log    ===== SOAP REQUEST BODY =====    console=yes
    Log    ${soap_body}    console=yes
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    ===== SOAP RESPONSE (Status: ${response.status_code}) =====    console=yes
    Log    ${response.text}    console=yes
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}
    Delete All Sessions
    Set Suite Variable    ${E2E_EC_NAME}    ${data}[company_name]
    Set Suite Variable    ${E2E_BU_NAME}    ${data}[billing_account_name]
    Write Seed Value    e2e_ec_name    ${E2E_EC_NAME}
    Write Seed Value    e2e_bu_name    ${E2E_BU_NAME}
    Log    ===== ONBOARD SUCCESS =====    console=yes
    Log    EC Name : ${E2E_EC_NAME}    console=yes
    Log    BU Name : ${E2E_BU_NAME}    console=yes

TC_E2E_AA_ACT_002
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    Log    Waiting 5 minutes for backend to process onboarded account...    console=yes
    Sleep    300s    reason=Waiting 5 min for backend to process onboarded account
    ${passed}=    Run Keyword And Return Status
    ...    E2E Verify Account On UI    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    IF    not ${passed}
        Log    Account not found on first attempt. Waiting another 5 minutes and retrying...    console=yes
        Sleep    300s    reason=Retry wait — another 5 min for account to appear
        Go To    ${BASE_URL}ManageAccount
        Sleep    3s
        Wait For App Loading To Complete    timeout=60s
        E2E Verify Account On UI    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    END

TC_E2E_AA_ACT_003
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${E2E_EC_NAME}    ${E2E_BU_NAME}

TC_E2E_AA_ACT_004
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create CSR Journey    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    E2E Activate BU Device Plans In DB    ${E2E_BU_NAME}

TC_E2E_AA_ACT_005
    E2E Create SIM Range

TC_E2E_AA_ACT_006
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create Product Type And Assign EC    ${E2E_EC_NAME}

TC_E2E_AA_ACT_007
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Expand EC And BU SIM Limits    ${E2E_EC_NAME}    ${E2E_BU_NAME}    5

TC_E2E_AA_ACT_008
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    # Use config DP if set, otherwise fall back to DP alias captured from TC_004 CSR Journey
    ${_dp}=    Set Variable If    '${E2E_AA_DEVICE_PLAN}' != ''    ${E2E_AA_DEVICE_PLAN}    ${E2E_CSR1_DP_ALIAS}
    Log    SIM Order DP for auto activation: "${_dp}"    console=yes
    E2E Create SIM Order
    ...    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    ...    activation_type=autoActivation
    ...    sim_state=${E2E_AA_SIM_STATE_ACTIVATED}
    ...    dp_name=${_dp}

TC_E2E_AA_ACT_009
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_ORDER_ID}    ${order_id}
    Log    Suite variable E2E_ORDER_ID set to: ${E2E_ORDER_ID}    console=yes

TC_E2E_AA_ACT_010
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_EC_ID}    ${ec_id}
    Set Suite Variable    ${E2E_BU_ID}    ${bu_id}
    Log    EC ID: ${E2E_EC_ID}, BU ID: ${E2E_BU_ID}    console=yes

TC_E2E_AA_ACT_011
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    ${output}=    E2E Run Create Order Script
    Log    Create order script completed for order ${E2E_ORDER_ID}    console=yes

TC_E2E_AA_ACT_012
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${E2E_ORDER_ID}

TC_E2E_AA_ACT_013
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${E2E_ORDER_ID}

TC_E2E_AA_ACT_014
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    ${output}=    E2E Run Read Order Script
    Log    Read order script completed for order ${E2E_ORDER_ID}    console=yes

TC_E2E_AA_ACT_015
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${E2E_ORDER_ID}

TC_E2E_AA_ACT_016
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${E2E_BU_NAME}
    Log    ${row_count} SIMs in Warm state for BU: ${E2E_BU_NAME}    console=yes

TC_E2E_AA_ACT_017
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${E2E_ORDER_ID}
    # Auto Activation: SIMs transition directly to Activated state — allow extra time.
    Log    Auto Activation (Activated): waiting 2 additional minutes for state propagation...    console=yes
    Sleep    120s    reason=Extra wait for auto activation to complete after SOAP approve

TC_E2E_AA_ACT_018
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    # Auto Activation (Activated) — SIMs are already Activated; collect data without activation.
    ${activated_imsis}    ${imsi_data}    ${activated_iccids}=    E2E Collect Activated IMSI Data    ${E2E_BU_NAME}
    Set Suite Variable    @{E2E_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{E2E_IMSI_DATA}    @{imsi_data}
    Log    Auto-activated SIMs collected for BU: ${E2E_BU_NAME}. Count: ${SIM_ACTIVATE_COUNT}    console=yes
    FOR    ${imsi}    IN    @{E2E_ACTIVATED_IMSIS}
        Log    Activated IMSI: ${imsi}    console=yes
    END
    ${_imsi_count}=    Get Length    ${activated_imsis}
    IF    ${_imsi_count} > 0
        ${_first}=    Get From List    ${activated_imsis}    0
        Write Seed Value    e2e_first_activated_imsi    ${_first}
    END
    IF    ${_imsi_count} > 1
        ${_second}=    Get From List    ${activated_imsis}    1
        Write Seed Value    e2e_second_activated_imsi    ${_second}
    END

TC_E2E_AA_ACT_018B
    Should Not Be Empty    ${E2E_BU_NAME}            Step 1 must run first — BU name is empty.
    Should Not Be Empty    ${E2E_ACTIVATED_IMSIS}    TC_E2E_AA_ACT_018 must run first — activated IMSI list is empty.
    E2E Verify SIMs Activated UI    ${E2E_ACTIVATED_IMSIS}    ${E2E_BU_NAME}

TC_E2E_AA_ACT_019
    ${bu_id_str}=    Convert To String    ${E2E_BU_ID}
    Should Not Be Empty    ${bu_id_str}    Step 10 must run first — BU ID is empty.
    ${local_path}    ${filename}=    E2E Generate And Download Invoice    ${bu_id_str}
    Set Suite Variable    ${E2E_INVOICE_PATH}    ${local_path}
    Log    Invoice downloaded: ${filename} → ${local_path}    console=yes

TC_E2E_AA_ACT_020
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create Second CSR Journey With Different Plan    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Log    Step 20 complete: Second CSR Journey created (different APN/device plan).    console=yes

TC_E2E_AA_ACT_021
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Perform Device Plan Change On One Activated SIM And Validate    ${E2E_BU_NAME}
    Log    Step 21 complete: DP change performed and validated on one activated SIM.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  FLOW B — AUTO ACTIVATION + TESTACTIVE SIM STATE
# ═══════════════════════════════════════════════════════════════════════
TC_E2E_AA_TST_001
    Create Onboard API Session
    ${data}=    Generate Unique Test Data
    ${soap_body}=    Build Onboard Customer SOAP Envelope
    ...    order_number=${data}[order_number]
    ...    task_id=${data}[task_id]
    ...    business_unit_name=${data}[business_unit_name]
    ...    customer_reference_number=${data}[customer_reference_number]
    ...    company_name=${data}[company_name]
    ...    billing_account_name=${data}[billing_account_name]
    ...    billing_account_number=${data}[billing_account_number]
    Log    ===== SOAP REQUEST BODY =====    console=yes
    Log    ${soap_body}    console=yes
    ${response}=    Send Onboard Customer Request    ${soap_body}
    Log    ===== SOAP RESPONSE (Status: ${response.status_code}) =====    console=yes
    Log    ${response.text}    console=yes
    Verify Response Status Code    ${response}    200
    Verify SOAP Response Does Not Contain Fault    ${response}
    Delete All Sessions
    Set Suite Variable    ${E2E_EC_NAME}    ${data}[company_name]
    Set Suite Variable    ${E2E_BU_NAME}    ${data}[billing_account_name]
    Write Seed Value    e2e_ec_name    ${E2E_EC_NAME}
    Write Seed Value    e2e_bu_name    ${E2E_BU_NAME}
    Log    ===== ONBOARD SUCCESS =====    console=yes
    Log    EC Name : ${E2E_EC_NAME}    console=yes
    Log    BU Name : ${E2E_BU_NAME}    console=yes

TC_E2E_AA_TST_002
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    Log    Waiting 5 minutes for backend to process onboarded account...    console=yes
    Sleep    300s    reason=Waiting 5 min for backend to process onboarded account
    ${passed}=    Run Keyword And Return Status
    ...    E2E Verify Account On UI    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    IF    not ${passed}
        Log    Account not found on first attempt. Waiting another 5 minutes and retrying...    console=yes
        Sleep    300s    reason=Retry wait — another 5 min for account to appear
        Go To    ${BASE_URL}ManageAccount
        Sleep    3s
        Wait For App Loading To Complete    timeout=60s
        E2E Verify Account On UI    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    END

TC_E2E_AA_TST_003
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${E2E_EC_NAME}    ${E2E_BU_NAME}

TC_E2E_AA_TST_004
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create CSR Journey    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    E2E Activate BU Device Plans In DB    ${E2E_BU_NAME}

TC_E2E_AA_TST_005
    E2E Create SIM Range

TC_E2E_AA_TST_006
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create Product Type And Assign EC    ${E2E_EC_NAME}

TC_E2E_AA_TST_007
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Expand EC And BU SIM Limits    ${E2E_EC_NAME}    ${E2E_BU_NAME}    5

TC_E2E_AA_TST_008
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create SIM Order    ${E2E_EC_NAME}    ${E2E_BU_NAME}

TC_E2E_AA_TST_009
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_ORDER_ID}    ${order_id}
    Log    Suite variable E2E_ORDER_ID set to: ${E2E_ORDER_ID}    console=yes

TC_E2E_AA_TST_010
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_EC_ID}    ${ec_id}
    Set Suite Variable    ${E2E_BU_ID}    ${bu_id}
    Log    EC ID: ${E2E_EC_ID}, BU ID: ${E2E_BU_ID}    console=yes

TC_E2E_AA_TST_011
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    ${output}=    E2E Run Create Order Script
    Log    Create order script completed for order ${E2E_ORDER_ID}    console=yes

TC_E2E_AA_TST_012
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${E2E_ORDER_ID}

TC_E2E_AA_TST_013
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${E2E_ORDER_ID}

TC_E2E_AA_TST_014
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    ${output}=    E2E Run Read Order Script
    Log    Read order script completed for order ${E2E_ORDER_ID}    console=yes

TC_E2E_AA_TST_015
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${E2E_ORDER_ID}

TC_E2E_AA_TST_016
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${E2E_BU_NAME}
    Log    ${row_count} SIMs in Warm state for BU: ${E2E_BU_NAME}    console=yes

TC_E2E_AA_TST_017
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${E2E_ORDER_ID}
    # Auto Activation (TestActive): SIMs transition to TestActive — allow extra time.
    Log    Auto Activation (TestActive): waiting 2 additional minutes for state propagation...    console=yes
    Sleep    120s    reason=Extra wait for auto activation to complete after SOAP approve

TC_E2E_AA_TST_018
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    # Auto Activation (TestActive) — same auto-FP SOAP as Activated variant; SIMs go to TestActive.
    ${activated_imsis}    ${imsi_data}    ${activated_iccids}=    E2E Collect Activated IMSI Data    ${E2E_BU_NAME}
    Set Suite Variable    @{E2E_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{E2E_IMSI_DATA}    @{imsi_data}
    Log    Auto-FP SOAP submitted for ${SIM_ACTIVATE_COUNT} Warm SIMs. TestActive state expected.    console=yes
    FOR    ${imsi}    IN    @{E2E_ACTIVATED_IMSIS}
        Log    Captured IMSI: ${imsi}    console=yes
    END
    ${_imsi_count}=    Get Length    ${activated_imsis}
    IF    ${_imsi_count} > 0
        ${_first}=    Get From List    ${activated_imsis}    0
        Write Seed Value    e2e_first_activated_imsi    ${_first}
    END
    IF    ${_imsi_count} > 1
        ${_second}=    Get From List    ${activated_imsis}    1
        Write Seed Value    e2e_second_activated_imsi    ${_second}
    END

TC_E2E_AA_TST_018B
    Should Not Be Empty    ${E2E_BU_NAME}            Step 1 must run first — BU name is empty.
    Should Not Be Empty    ${E2E_ACTIVATED_IMSIS}    TC_E2E_AA_TST_018 must run first — IMSI list is empty.
    E2E Verify SIMs TestActive UI    ${E2E_ACTIVATED_IMSIS}    ${E2E_BU_NAME}

TC_E2E_AA_TST_018A
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${activated_imsis}    ${imsi_data}    ${activated_iccids}=    E2E Activate SIMs From TestActive State    ${E2E_BU_NAME}
    Set Suite Variable    @{E2E_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{E2E_IMSI_DATA}    @{imsi_data}
    Log    UI Activate submitted for ${SIM_ACTIVATE_COUNT} TestActive SIMs. IMSIs captured.    console=yes
    FOR    ${imsi}    IN    @{E2E_ACTIVATED_IMSIS}
        Log    Activated IMSI: ${imsi}    console=yes
    END
    ${_imsi_count}=    Get Length    ${activated_imsis}
    IF    ${_imsi_count} > 0
        ${_first}=    Get From List    ${activated_imsis}    0
        Write Seed Value    e2e_first_activated_imsi    ${_first}
    END
    IF    ${_imsi_count} > 1
        ${_second}=    Get From List    ${activated_imsis}    1
        Write Seed Value    e2e_second_activated_imsi    ${_second}
    END

TC_E2E_AA_TST_018C
    Should Not Be Empty    ${E2E_IMSI_DATA}    TC_E2E_AA_TST_018A must run first — IMSI/MSISDN data is empty.
    E2E Drive Activation Fingerprint Flow    @{E2E_IMSI_DATA}

TC_E2E_AA_TST_018D
    Should Not Be Empty    ${E2E_BU_NAME}            Step 1 must run first — BU name is empty.
    Should Not Be Empty    ${E2E_ACTIVATED_IMSIS}    TC_E2E_AA_TST_018A must run first — activated IMSI list is empty.
    E2E Verify SIMs Activated UI    ${E2E_ACTIVATED_IMSIS}    ${E2E_BU_NAME}

TC_E2E_AA_TST_019
    ${bu_id_str}=    Convert To String    ${E2E_BU_ID}
    Should Not Be Empty    ${bu_id_str}    Step 10 must run first — BU ID is empty.
    ${local_path}    ${filename}=    E2E Generate And Download Invoice    ${bu_id_str}
    Set Suite Variable    ${E2E_INVOICE_PATH}    ${local_path}
    Log    Invoice downloaded: ${filename} → ${local_path}    console=yes

TC_E2E_AA_TST_020
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create Second CSR Journey With Different Plan    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Log    Step 20 complete: Second CSR Journey created (different APN/device plan).    console=yes

TC_E2E_AA_TST_021
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Perform Device Plan Change On One Activated SIM And Validate    ${E2E_BU_NAME}
    Log    Step 21 complete: DP change performed and validated on one activated SIM.    console=yes
