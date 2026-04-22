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
#  E2E FLOW — 17 Steps (Account Onboard → Invoice Download)
#
#  Full run:
#    python run_tests.py --e2e
#    python run_tests.py --e2e --browser headlesschrome
#
#  Partial run (skip earlier steps — pass required variables):
#    python run_tests.py --e2e --test "Step 16*" --test "Step 17*" \
#        --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 \
#        --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 \
#        --variable E2E_ORDER_ID:101076 \
#        --variable E2E_EC_ID:29421 \
#        --variable E2E_BU_ID:29422
#
#  Variables (set by earlier steps or passed via --variable):
#    E2E_EC_NAME   — EC account name   (Step 1)
#    E2E_BU_NAME   — BU account name   (Step 1)
#    E2E_ORDER_ID  — Order ID          (Step 7)
#    E2E_EC_ID     — EC account DB ID  (Step 8)
#    E2E_BU_ID     — BU account DB ID  (Step 8)
#
#  Steps:
#    1  Onboard EC + BU via API       9  SSH: run start_createorder.sh
#    1b Verify accounts on UI         10 Validate order → In Progress
#    2  Create APN                    11 Generate + upload 3 response files
#    3  Create CSR Journey            12 SSH: run start_readorder.sh
#    4  Create SIM Range (10)         13 Validate order → Completed
#    5  Create + assign Product Type  14 Validate SIMs in Warm state
#    6  Create SIM Order              15 SOAP API: approve order (→ InActive)
#    7  Capture Order ID from grid    16 Activate 5 SIMs + verify Activated
#    8  Fetch EC/BU IDs from DB       17 Invoice API + download CSV
# ═══════════════════════════════════════════════════════════════════════

Step 1 Onboard EC And BU Account Via API
    [Documentation]    Uses the same proven logic as TC_ONBOARD_001: sends createOnboardCustomer
    ...                SOAP request with all fields. Verifies HTTP 200, no SOAP fault.
    ...                Stores EC and BU names as suite variables for subsequent steps.
    [Tags]    e2e    api    onboard
    STEP_01

Step 1b Verify Onboarded Account On UI
    [Documentation]    Waits 5 min for backend processing, then navigates to ManageAccount,
    ...                enables Show Customer Wise Data, and validates both EC and BU accounts.
    ...                If not found on first attempt, waits another 5 min, refreshes, and retries.
    [Tags]    e2e    validation    onboard
    STEP_01B

Step 2 Create APN For Onboarded Account
    [Documentation]    Creates a Private APN under the EC/BU onboarded in Step 1.
    [Tags]    e2e    apn
    STEP_02

Step 3 Create CSR Journey For Onboarded Account
    [Documentation]    Creates a CSR Journey (order) for the EC/BU onboarded in Step 1.
    ...                Goes through the full wizard: tariff plan, APN, device plan, service plan,
    ...                additional services, summary, and save.
    ...                Implementation: E2E Create CSR Journey → CSRJ Complete Create Wizard Save And Exit Like E2E
    ...                (csr_journey_keywords.resource). Deeper CSR UI regression: tests/csr_journey_tests.robot TC_CSRJ_004.
    [Tags]    e2e    csr-journey
    STEP_03

Step 4 Create SIM Range With 10 ICCID IMSI
    [Documentation]    Creates a SIM Range with 10 ICCID/IMSI entries using the default account (KSA_OPCO).
    [Tags]    e2e    sim-range
    STEP_04

Step 5 Create And Assign SIM Product Type
    [Documentation]    Creates a SIM Product Type with default account (KSA_OPCO),
    ...                then assigns the onboarded EC to it.
    [Tags]    e2e    product-type
    STEP_05

Step 5b Expand EC And BU SIM Limits
    [Documentation]    Before SIM Order: opens EC and BU accounts on ManageAccount,
    ...                navigates to Account Settings, and adds +10 to each Max IMSI /
    ...                Max SIM. Required so the BU has SIM capacity headroom.
    [Tags]    e2e
    STEP_05B

Step 6 Create SIM Order
    [Documentation]    Creates a SIM Order with quantity 10 using the onboarded BU account
    ...                selected via treeview (KSA_OPCO > EC > BU).
    [Tags]    e2e    sim-order
    STEP_06

Step 7 Capture Order ID From Live Order Grid
    [Documentation]    Navigates to the Live Order tab, searches for the BU account,
    ...                and captures the Order Number from the first matching row.
    ...                Stores it as a suite variable for all subsequent steps.
    [Tags]    e2e
    STEP_07

Step 8 Fetch EC And BU Account IDs From Database
    [Documentation]    Connects to the STC database, queries for the EC and BU account
    ...                IDs by name, stores them, and closes the DB connection.
    [Tags]    e2e
    STEP_08

Step 9 Run Create Order Script On Server
    [Documentation]    Connects to the order processing server via SSH and runs
    ...                start_createorder.sh. Waits for script completion.
    [Tags]    e2e
    STEP_09

Step 10 Validate Order Status New To In Progress
    [Documentation]    After start_createorder.sh completes, navigates to the Live Order
    ...                tab and validates the order status changed from New to In Progress.
    ...                Retries up to 6 times with 30s between attempts.
    [Tags]    e2e    validation
    STEP_10

Step 11 Generate And Upload Response Files To Server
    [Documentation]    Generates 3 response files (orderId.dsprsp, orderId.ordrsp,
    ...                orderId.pcsrsp) from templates by replacing 120326 with the
    ...                actual orderId. Uploads them to the server's order/input directory.
    [Tags]    e2e
    STEP_11

Step 12 Run Read Order Script On Server
    [Documentation]    Runs start_readorder.sh on the server to process the uploaded
    ...                response files. Closes the SSH connection after completion.
    [Tags]    e2e
    STEP_12

Step 13 Validate Order Status In Progress To Completed
    [Documentation]    After start_readorder.sh completes, navigates to the Order History
    ...                tab and validates the order status changed to Completed.
    [Tags]    e2e    validation
    STEP_13

Step 14 Validate SIMs In Warm State On Manage Devices
    [Documentation]    Navigates to Manage Devices page, applies BU account filter,
    ...                verifies all SIMs are in Warm state and row count >= 10.
    [Tags]    e2e    manage-devices    validation
    STEP_14

Step 15 Update Order Status To Approved Via SOAP API
    [Documentation]    Calls SOAP API to update the SIM order status to Approved.
    ...                Uses the captured orderId from Step 7.
    [Tags]    e2e    api
    STEP_15

Step 16 Activate 5 SIMs And Capture IMSIs
    [Documentation]    Performs Device State Change on Manage Devices page to activate
    ...                5 SIMs from InActive to Activated state. After Step 15 approval,
    ...                SIMs are in InActive state. Captures all activated IMSIs for future use.
    [Tags]    e2e
    STEP_16

Step 17 Generate Invoice And Download CSV
    [Documentation]    Calls Invoice API with BU account ID, waits for server-side
    ...                invoice generation, then downloads latest CSV from server
    ...                to the local billing/ folder.
    [Tags]    e2e
    STEP_17

Step 18 Create Second CSR Journey With Different Plan
    [Documentation]    Creates a second CSR Journey for the same account with different
    ...                tariff/APN/device plan so a different device plan is available for DP change.
    [Tags]    e2e    csr-journey    device-plan
    STEP_18

Step 19 Perform Device Plan Change On One Activated SIM And Validate
    [Documentation]    On Manage Devices, filters by BU + Activated, performs device plan
    ...                change on one SIM, waits 5 min, then verifies device plan updated in grid.
    [Tags]    e2e    device-plan
    STEP_19

*** Keywords ***
STEP_01
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
    # Persist EC/BU names under flow-specific seed keys (e2e_flow without usage)
    Write Seed Value    e2e_ec_name    ${E2E_EC_NAME}
    Write Seed Value    e2e_bu_name    ${E2E_BU_NAME}
    Log    ===== ONBOARD SUCCESS =====    console=yes
    Log    EC Name : ${E2E_EC_NAME}    console=yes
    Log    BU Name : ${E2E_BU_NAME}    console=yes

STEP_01B
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

STEP_02
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${E2E_EC_NAME}    ${E2E_BU_NAME}

STEP_03
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create CSR Journey    ${E2E_EC_NAME}    ${E2E_BU_NAME}

STEP_04
    E2E Create SIM Range

STEP_05
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create Product Type And Assign EC    ${E2E_EC_NAME}

STEP_05B
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Expand EC And BU SIM Limits    ${E2E_EC_NAME}    ${E2E_BU_NAME}    10

STEP_06
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create SIM Order    ${E2E_EC_NAME}    ${E2E_BU_NAME}

STEP_07
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_ORDER_ID}    ${order_id}
    Log    Suite variable E2E_ORDER_ID set to: ${E2E_ORDER_ID}    console=yes

STEP_08
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_EC_ID}    ${ec_id}
    Set Suite Variable    ${E2E_BU_ID}    ${bu_id}
    Log    EC ID: ${E2E_EC_ID}, BU ID: ${E2E_BU_ID}    console=yes

STEP_09
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    ${output}=    E2E Run Create Order Script
    Log    Create order script completed for order ${E2E_ORDER_ID}    console=yes

STEP_10
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${E2E_ORDER_ID}

STEP_11
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${E2E_ORDER_ID}

STEP_12
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    ${output}=    E2E Run Read Order Script
    Log    Read order script completed for order ${E2E_ORDER_ID}    console=yes

STEP_13
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${E2E_ORDER_ID}

STEP_14
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${E2E_BU_NAME}
    Log    ${row_count} SIMs in Warm state for BU: ${E2E_BU_NAME}    console=yes

STEP_15
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${E2E_ORDER_ID}

STEP_16
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${activated_imsis}    ${imsi_data}=    E2E Activate SIMs And Capture IMSIs    ${E2E_BU_NAME}
    Set Suite Variable    @{E2E_ACTIVATED_IMSIS}    @{activated_imsis}
    Log    Activated ${SIM_ACTIVATE_COUNT} SIMs. IMSIs stored for future use.    console=yes
    FOR    ${imsi}    IN    @{E2E_ACTIVATED_IMSIS}
        Log    Activated IMSI: ${imsi}    console=yes
    END
    # Persist flow-specific IMSI/ICCID seed keys for Device State (e2e_flow without usage)
    ${_imsi_count}=    Get Length    ${activated_imsis}
    IF    ${_imsi_count} > 0
        ${_first}=    Get From List    ${activated_imsis}    0
        Write Seed Value    e2e_first_activated_imsi    ${_first}
    END
    IF    ${_imsi_count} > 1
        ${_second}=    Get From List    ${activated_imsis}    1
        Write Seed Value    e2e_second_activated_imsi    ${_second}
    END

STEP_17
    ${bu_id_str}=    Convert To String    ${E2E_BU_ID}
    Should Not Be Empty    ${bu_id_str}    Step 8 must run first — BU ID is empty.
    ${local_path}    ${filename}=    E2E Generate And Download Invoice    ${bu_id_str}
    Set Suite Variable    ${E2E_INVOICE_PATH}    ${local_path}
    Log    Invoice downloaded: ${filename} → ${local_path}    console=yes

STEP_18
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create Second CSR Journey With Different Plan    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Log    Step 18 complete: Second CSR Journey created (different APN/device plan).    console=yes

STEP_19
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Perform Device Plan Change On One Activated SIM And Validate    ${E2E_BU_NAME}
    Log    Step 19 complete: DP change performed and validated on one activated SIM.    console=yes
