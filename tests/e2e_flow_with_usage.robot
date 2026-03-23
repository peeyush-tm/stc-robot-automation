*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Resource    ../resources/keywords/e2e_keywords.resource
Resource    ../resources/keywords/usage_keywords.resource
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
Variables   ../variables/usage_variables.py

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
${E2E_IMSI_CSV}             ${EMPTY}
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
#  E2E FLOW B — WITH USAGE (20 Steps)
#
#  Full run:
#    python run_tests.py --e2e-with-usage
#    python run_tests.py --e2e-with-usage --browser headlesschrome
#
#  Partial run (skip earlier steps — pass required variables):
#    python run_tests.py --e2e-with-usage --test "Step 16a*" --test "Step 17*" ^
#        --variable E2E_EC_NAME:AQ_AUTO_EC_11030048 ^
#        --variable E2E_BU_NAME:AQ_AUTO_BU_11030048 ^
#        --variable E2E_ORDER_ID:101076 ^
#        --variable E2E_EC_ID:29421 ^
#        --variable E2E_BU_ID:29422
#
#  Usage-only run (Steps 16a + 16b) — pass IMSIs via E2E_IMSI_CSV:
#    python run_tests.py --e2e-with-usage ^
#        --test "Step 16a*" --test "Step 16b*" ^
#        --variable E2E_IMSI_CSV:IMSI1:MSISDN1,IMSI2:MSISDN2,...
#
#    If MSISDNs are unknown, omit them — they'll be looked up from the grid:
#    python run_tests.py --e2e-with-usage ^
#        --test "Step 16a*" --test "Step 16b*" ^
#        --variable E2E_IMSI_CSV:224444444494501,224444444494502,224444444494503,224444444494504,224444444494505
#
#  Variables (set by earlier steps or passed via --variable):
#    E2E_EC_NAME    — EC account name   (Step 1)
#    E2E_BU_NAME    — BU account name   (Step 1)
#    E2E_ORDER_ID   — Order ID          (Step 7)
#    E2E_EC_ID      — EC account DB ID  (Step 8)
#    E2E_BU_ID      — BU account DB ID  (Step 8)
#    E2E_IMSI_DATA  — list of {imsi, msisdn} dicts (Step 16, auto)
#    E2E_IMSI_CSV   — comma-separated IMSIs or IMSI:MSISDN pairs (CLI)
#
#  Steps:
#    1   Onboard EC + BU via API        10  Validate order → In Progress
#    1b  Verify accounts on UI          11  Generate + upload 3 response files
#    2   Create APN                     12  SSH: run start_readorder.sh
#    3   Create CSR Journey             13  Validate order → Completed
#    4   Create SIM Range (10)          14  Validate SIMs in Warm state
#    5   Create + assign Product Type   15  SOAP API: approve order (→ InActive)
#    6   Create SIM Order               16  Activate 5 SIMs + capture IMSIs/MSISDNs
#    7   Capture Order ID from grid     16a Usage: User Request + CDR (data only)
#    8   Fetch EC/BU IDs from DB        16b Validate usage in UI (data usage column only)
#    9   SSH: run start_createorder.sh  17  Invoice API + download CSV
# ═══════════════════════════════════════════════════════════════════════

Step 1 Onboard EC And BU Account Via API
    [Documentation]    Uses the same proven logic as TC_ONBOARD_001: sends createOnboardCustomer
    ...                SOAP request with all fields. Verifies HTTP 200, no SOAP fault.
    ...                Stores EC and BU names as suite variables for subsequent steps.
    [Tags]    e2e    step-1    api    onboard
    STEP_01

Step 1b Verify Onboarded Account On UI
    [Documentation]    Waits 5 min for backend processing, then navigates to ManageAccount,
    ...                enables Show Customer Wise Data, and validates both EC and BU accounts.
    ...                If not found on first attempt, waits another 5 min, refreshes, and retries.
    [Tags]    e2e    step-1    validation    onboard
    STEP_01B

Step 2 Create APN For Onboarded Account
    [Documentation]    Creates a Private APN under the EC/BU onboarded in Step 1.
    [Tags]    e2e    step-2    apn
    STEP_02

Step 3 Create CSR Journey For Onboarded Account
    [Documentation]    Creates a CSR Journey (order) for the EC/BU onboarded in Step 1.
    [Tags]    e2e    step-3    csr-journey
    STEP_03

Step 4 Create SIM Range With 10 ICCID IMSI
    [Documentation]    Creates a SIM Range with 10 ICCID/IMSI entries using the default account (KSA_OPCO).
    [Tags]    e2e    step-4    sim-range
    STEP_04

Step 5 Create And Assign SIM Product Type
    [Documentation]    Creates a SIM Product Type with default account (KSA_OPCO),
    ...                then assigns the onboarded EC to it.
    [Tags]    e2e    step-5    product-type
    STEP_05

Step 6 Create SIM Order
    [Documentation]    Creates a SIM Order with quantity 10 using the onboarded BU account
    ...                selected via treeview (KSA_OPCO > EC > BU).
    [Tags]    e2e    step-6    sim-order
    STEP_06

# ═══════════════════════════════════════════════════════════════════════
#  ORDER PROCESSING FLOW (Steps 7–13)
# ═══════════════════════════════════════════════════════════════════════

Step 7 Capture Order ID From Live Order Grid
    [Documentation]    Navigates to the Live Order tab, searches for the BU account,
    ...                and captures the Order Number from the first matching row.
    [Tags]    e2e    step-7    order-processing    capture
    STEP_07

Step 8 Fetch EC And BU Account IDs From Database
    [Documentation]    Connects to the STC database, queries for the EC and BU account
    ...                IDs by name, stores them, and closes the DB connection.
    [Tags]    e2e    step-8    order-processing    database
    STEP_08

Step 9 Run Create Order Script On Server
    [Documentation]    Connects to the order processing server via SSH and runs
    ...                start_createorder.sh. Waits for script completion.
    [Tags]    e2e    step-9    order-processing    ssh
    STEP_09

Step 10 Validate Order Status New To In Progress
    [Documentation]    After start_createorder.sh completes, navigates to the Live Order
    ...                tab and validates the order status changed from New to In Progress.
    [Tags]    e2e    step-10    order-processing    validation
    STEP_10

Step 11 Generate And Upload Response Files To Server
    [Documentation]    Generates 3 response files and uploads them to the server.
    [Tags]    e2e    step-11    order-processing    files
    STEP_11

Step 12 Run Read Order Script On Server
    [Documentation]    Runs start_readorder.sh on the server to process the uploaded
    ...                response files. Closes the SSH connection after completion.
    [Tags]    e2e    step-12    order-processing    ssh
    STEP_12

Step 13 Validate Order Status In Progress To Completed
    [Documentation]    After start_readorder.sh completes, navigates to the Order History
    ...                tab and validates the order status changed to Completed.
    [Tags]    e2e    step-13    order-processing    validation
    STEP_13

# ═══════════════════════════════════════════════════════════════════════
#  POST-ORDER VALIDATION & ACTIVATION (Steps 14–16)
# ═══════════════════════════════════════════════════════════════════════

Step 14 Validate SIMs In Warm State On Manage Devices
    [Documentation]    Navigates to Manage Devices page, applies BU account filter,
    ...                verifies all SIMs are in Warm state and row count >= 10.
    [Tags]    e2e    step-14    manage-devices    validation
    STEP_14

Step 15 Update Order Status To Approved Via SOAP API
    [Documentation]    Calls SOAP API to update the SIM order status to Approved.
    [Tags]    e2e    step-15    api    soap
    STEP_15

Step 16 Activate 5 SIMs And Capture IMSIs And MSISDNs
    [Documentation]    Performs Device State Change on Manage Devices page to activate
    ...                5 SIMs from InActive to Activated state. Captures both IMSIs and
    ...                MSISDNs for usage steps. Stores E2E_IMSI_DATA for Steps 16a/16b.
    [Tags]    e2e    step-16    device-state-change    activation
    STEP_16

# ═══════════════════════════════════════════════════════════════════════
#  USAGE FLOW (Steps 16a, 16b) — Flow B Only (data usage only)
# ═══════════════════════════════════════════════════════════════════════

Step 16a Perform Usage For All Activated IMSIs
    [Documentation]    For each activated IMSI, calls User Request API then CDR API for
    ...                data usage only. Uses E2E_IMSI_DATA from Step 16, or parses E2E_IMSI_CSV from CLI.
    [Tags]    e2e    step-16a    usage    api
    STEP_16A

Step 16b Validate Usage In UI For All IMSIs
    [Documentation]    Navigate to Manage Devices page; for each IMSI validate DATA USAGE (MB).
    [Tags]    e2e    step-16b    usage    validation    ui
    STEP_16B

# ═══════════════════════════════════════════════════════════════════════
#  INVOICE (Step 17)
# ═══════════════════════════════════════════════════════════════════════

Step 17 Generate Invoice And Download CSV
    [Documentation]    Calls Invoice API with BU account ID, waits for server-side
    ...                invoice generation, then downloads latest CSV from server
    ...                to the local billing/ folder.
    [Tags]    e2e    step-17    invoice    billing
    STEP_17

Step 18 Create Second CSR Journey With Different Plan
    [Documentation]    Creates a second CSR Journey for the same account with different
    ...                tariff/APN/device plan so a different device plan is available for DP change.
    [Tags]    e2e    step-18    csr-journey    device-plan
    STEP_18

Step 19 Perform Device Plan Change On One Activated SIM And Validate
    [Documentation]    On Manage Devices, filters by BU + Activated, performs device plan
    ...                change on one SIM, waits 5 min, then verifies device plan updated in grid.
    [Tags]    e2e    step-19    device-plan    dp-change
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
    Set Suite Variable    @{E2E_IMSI_DATA}    @{imsi_data}
    Log    Activated ${SIM_ACTIVATE_COUNT} SIMs. IMSIs + MSISDNs stored for usage.    console=yes
    FOR    ${entry}    IN    @{E2E_IMSI_DATA}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END

STEP_16A
    Populate IMSI Data If Needed
    ${count}=    Get Length    ${E2E_IMSI_DATA}
    Should Be True    ${count} > 0
    ...    No IMSI data available. Run Step 16 first or pass --variable E2E_IMSI_CSV:IMSI1,IMSI2,...
    E2E Perform Usage For All IMSIs    @{E2E_IMSI_DATA}
    Log    Step 16a complete: Usage performed for all ${count} IMSIs.    console=yes

STEP_16B
    Populate IMSI Data If Needed
    ${count}=    Get Length    ${E2E_IMSI_DATA}
    Should Be True    ${count} > 0
    ...    No IMSI data available. Run Step 16 first or pass --variable E2E_IMSI_CSV:IMSI1,IMSI2,...
    E2E Validate Usage In UI    @{E2E_IMSI_DATA}
    Log    Step 16b complete: All ${count} IMSIs usage verified in UI.    console=yes

STEP_17
    Should Not Be Empty    ${E2E_BU_ID}    Step 8 must run first — BU ID is empty.
    ${local_path}    ${filename}=    E2E Generate And Download Invoice    ${E2E_BU_ID}
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

Populate IMSI Data If Needed
    [Documentation]    If E2E_IMSI_DATA is empty but E2E_IMSI_CSV was passed via CLI,
    ...                parses the CSV and looks up MSISDNs from the grid if needed.
    ${count}=    Get Length    ${E2E_IMSI_DATA}
    IF    ${count} == 0 and "${E2E_IMSI_CSV}" != "${EMPTY}"
        Log    E2E_IMSI_DATA is empty — building from E2E_IMSI_CSV: ${E2E_IMSI_CSV}    console=yes
        ${parsed}=    Build IMSI Data From CSV    ${E2E_IMSI_CSV}
        Set Suite Variable    @{E2E_IMSI_DATA}    @{parsed}
        Log    E2E_IMSI_DATA populated with ${parsed.__len__()} entries from CLI.    console=yes
    END
