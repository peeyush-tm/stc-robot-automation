*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Resource    ../resources/keywords/e2e_keywords.resource
Resource    ../resources/keywords/usage_keywords.resource
Resource    ../resources/keywords/report_keywords.resource
Resource    ../resources/keywords/device_state_keywords.resource
Resource    ../resources/locators/device_state_locators.resource
Resource    ../resources/keywords/role_management_keywords.resource
Resource    ../resources/keywords/user_management_keywords.resource
Resource    ../resources/locators/report_locators.resource
Resource    ../resources/locators/role_management_locators.resource
Resource    ../resources/locators/user_management_locators.resource
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
Variables   ../variables/report_variables.py
Variables   ../variables/role_management_variables.py
Variables   ../variables/user_management_variables.py

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
${E2E_CRUD_ROLE_NAME}       ${EMPTY}
${E2E_CRUD_USERNAME}        ${EMPTY}
${E2E_CRUD_USER_EMAIL}      ${EMPTY}
${E2E_SUSPEND_IMSI}         ${EMPTY}
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
#    1   Onboard EC + BU via API        10  Validate order → In Progress     [no_sit]
#    1b  Verify accounts on UI          11  Generate + upload 3 response files [no_sit]
#    2   Create APN                     12  SSH: run start_readorder.sh       [no_sit]
#    3   Create CSR Journey             13  Validate order → Completed        [no_sit]
#    4   Create SIM Range (10)          SIT_001 Poll until order completes    [sit_only]
#    5   Create + assign Product Type   14  Validate SIMs in Warm state
#    6   Create SIM Order               15  SOAP: approve order (→ InActive)  [no_sit]
#    7   Capture Order ID from grid     SIT_002 Poll until SIMs → InActive   [sit_only]
#    8   Fetch EC/BU IDs from DB        16  Activate 5 SIMs + capture IMSIs
#    9   SSH: run start_createorder.sh  16a Usage: CDR for all IMSIs
#    [no_sit]                           16b Validate usage in UI
#                                       16c Suspend one IMSI + wait 5 min
#                                       16d Validate IMSI Suspended
#                                       16e Resume IMSI + wait 5 min
#                                       16f Validate IMSI Activated
#                                       17  2nd CSR Journey + DP Change
#                                       18  Create Usage Report + download
#                                       19  Invoice API + SSH download CSV
#                                       20  Role + User CRUD (create + delete)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_001 Onboard EC And BU Account Via API
    [Documentation]    Uses the same proven logic as TC_ONBOARD_001: sends createOnboardCustomer
    ...                SOAP request with all fields. Verifies HTTP 200, no SOAP fault.
    ...                Stores EC and BU names as suite variables for subsequent steps.
    [Tags]    regression    e2e    TC_E2EU_001    positive
    TC_E2EU_001

TC_E2EU_002 Verify Onboarded Account On UI
    [Documentation]    Waits 5 min for backend processing, then navigates to ManageAccount,
    ...                enables Show Customer Wise Data, and validates both EC and BU accounts.
    ...                If not found on first attempt, waits another 5 min, refreshes, and retries.
    [Tags]    regression    e2e    TC_E2EU_002    positive
    TC_E2EU_002

TC_E2EU_003 Create APN For Onboarded Account
    [Documentation]    Creates a Private APN under the EC/BU onboarded in Step 1.
    [Tags]    regression    e2e    TC_E2EU_003    positive
    TC_E2EU_003

TC_E2EU_004 Create CSR Journey For Onboarded Account
    [Documentation]    Creates a CSR Journey (order) for the EC/BU onboarded in Step 1.
    ...                Wizard body: CSRJ Complete Create Wizard Save And Exit Like E2E (csr_journey_keywords.resource).
    ...                Deeper CSR UI checks: tests/csr_journey_tests.robot TC_CSRJ_004.
    [Tags]    regression    e2e    TC_E2EU_004    positive
    TC_E2EU_004

TC_E2EU_005 Create SIM Range With 10 ICCID IMSI
    [Documentation]    Creates a SIM Range with 10 ICCID/IMSI entries using the default account (KSA_OPCO).
    [Tags]    regression    e2e    TC_E2EU_005    positive
    TC_E2EU_005

TC_E2EU_006 Create And Assign SIM Product Type
    [Documentation]    Creates a SIM Product Type with default account (KSA_OPCO),
    ...                then assigns the onboarded EC to it.
    [Tags]    regression    e2e    TC_E2EU_006    positive
    TC_E2EU_006

TC_E2EU_007 Expand EC And BU SIM Limits
    [Documentation]    Before SIM Order: opens EC and BU accounts on ManageAccount,
    ...                navigates to Account Settings, and adds +10 to each Max IMSI /
    ...                Max SIM. Required so the BU has SIM capacity headroom.
    [Tags]    regression    e2e    TC_E2EU_007    positive
    TC_E2EU_007

TC_E2EU_008 Create SIM Order
    [Documentation]    Creates a SIM Order with quantity 10 using the onboarded BU account
    ...                selected via treeview (KSA_OPCO > EC > BU).
    [Tags]    regression    e2e    TC_E2EU_008    positive
    TC_E2EU_008

# ═══════════════════════════════════════════════════════════════════════
#  ORDER PROCESSING FLOW (Steps 7–13)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_009 Capture Order ID From Live Order Grid
    [Documentation]    Navigates to the Live Order tab, searches for the BU account,
    ...                and captures the Order Number from the first matching row.
    [Tags]    regression    e2e    TC_E2EU_009    positive
    TC_E2EU_009

TC_E2EU_010 Fetch EC And BU Account IDs From Database
    [Documentation]    Connects to the STC database, queries for the EC and BU account
    ...                IDs by name, stores them, and closes the DB connection.
    [Tags]    regression    e2e    TC_E2EU_010    positive
    TC_E2EU_010

TC_E2EU_011 Run Create Order Script On Server
    [Documentation]    Connects to the order processing server via SSH and runs
    ...                start_createorder.sh. Waits for script completion.
    ...                SKIPPED on SIT — cron job triggers order processing automatically.
    [Tags]    regression    e2e    TC_E2EU_011    positive    no_sit
    TC_E2EU_011

TC_E2EU_012 Validate Order Status New To In Progress
    [Documentation]    After start_createorder.sh completes, navigates to the Live Order
    ...                tab and validates the order status changed from New to In Progress.
    ...                SKIPPED on SIT — order progresses automatically via cron.
    [Tags]    regression    e2e    TC_E2EU_012    positive    no_sit
    TC_E2EU_012

TC_E2EU_013 Generate And Upload Response Files To Server
    [Documentation]    Generates 3 response files and uploads them to the server.
    ...                SKIPPED on SIT — response files are handled automatically.
    [Tags]    regression    e2e    TC_E2EU_013    positive    no_sit
    TC_E2EU_013

TC_E2EU_014 Run Read Order Script On Server
    [Documentation]    Runs start_readorder.sh on the server to process the uploaded
    ...                response files. Closes the SSH connection after completion.
    ...                SKIPPED on SIT — cron job runs read order automatically.
    [Tags]    regression    e2e    TC_E2EU_014    positive    no_sit
    TC_E2EU_014

TC_E2EU_015 Validate Order Status In Progress To Completed
    [Documentation]    After start_readorder.sh completes, navigates to the Order History
    ...                tab and validates the order status changed to Completed.
    ...                SKIPPED on SIT — replaced by TC_E2EU_SIT_001 which polls until auto-complete.
    [Tags]    regression    e2e    TC_E2EU_015    positive    no_sit
    TC_E2EU_015

TC_E2EU_SIT_001 Wait For Order To Complete Automatically
    [Documentation]    SIT only — polls Order History every 30s for up to 30 min until
    ...                the order status reaches Completed (cron job drives this automatically).
    [Tags]    regression    e2e    TC_E2EU_SIT_001    positive    sit_only
    TC_E2EU_SIT_001

# ═══════════════════════════════════════════════════════════════════════
#  POST-ORDER VALIDATION & ACTIVATION (Steps 14–16)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_016 Validate SIMs In Warm State On Manage Devices
    [Documentation]    Navigates to Manage Devices page, applies BU account filter,
    ...                verifies all SIMs are in Warm state and row count >= 10.
    [Tags]    regression    e2e    TC_E2EU_016    positive
    TC_E2EU_016

TC_E2EU_017 Update Order Status To Approved Via SOAP API
    [Documentation]    Calls SOAP API to update the SIM order status to Approved.
    ...                SKIPPED on SIT — order approval and InActive transition are automatic.
    [Tags]    regression    e2e    TC_E2EU_017    positive    no_sit
    TC_E2EU_017

TC_E2EU_SIT_002 Wait For SIMs To Reach InActive State Automatically
    [Documentation]    SIT only — polls Manage Devices every 30s for up to 30 min until
    ...                SIMs transition to InActive state (cron job drives this automatically).
    [Tags]    regression    e2e    TC_E2EU_SIT_002    positive    sit_only
    TC_E2EU_SIT_002

TC_E2EU_018 Activate 5 SIMs And Capture IMSIs And MSISDNs
    [Documentation]    Performs Device State Change on Manage Devices page to activate
    ...                5 SIMs from InActive to Activated state. Captures both IMSIs and
    ...                MSISDNs for usage steps. Stores E2E_IMSI_DATA for Steps 16a/16b.
    [Tags]    regression    e2e    TC_E2EU_018    positive
    TC_E2EU_018

# ═══════════════════════════════════════════════════════════════════════
#  USAGE FLOW (Steps 16a, 16b) — Flow B Only (data usage only)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_019 Perform Usage For All Activated IMSIs
    [Documentation]    For each activated IMSI, calls User Request API then CDR API for
    ...                data usage only. Uses E2E_IMSI_DATA from Step 16, or parses E2E_IMSI_CSV from CLI.
    [Tags]    regression    e2e    TC_E2EU_019    positive
    TC_E2EU_019

TC_E2EU_020 Validate Usage In UI For All IMSIs
    [Documentation]    Navigate to Manage Devices page; for each IMSI validate DATA USAGE (MB).
    [Tags]    regression    e2e    TC_E2EU_020    positive
    TC_E2EU_020

# ═══════════════════════════════════════════════════════════════════════
#  SUSPEND & RESUME (Steps 16c–16f)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_029 Suspend One Activated IMSI
    [Documentation]    Takes the first IMSI from E2E_IMSI_DATA, performs device state change
    ...                Activated → Suspended. Waits 5 min for async processing.
    [Tags]    regression    e2e    TC_E2EU_029    positive
    TC_E2EU_029

TC_E2EU_030 Validate IMSI Is Suspended
    [Documentation]    Searches Manage Devices by IMSI captured in TC_E2EU_029 and
    ...                verifies the state column shows Suspended.
    [Tags]    regression    e2e    TC_E2EU_030    positive
    TC_E2EU_030

TC_E2EU_031 Resume Suspended IMSI Back To Activated
    [Documentation]    Takes the suspended IMSI from TC_E2EU_029, performs device state change
    ...                Suspended → Activated. Waits 5 min for async processing.
    [Tags]    regression    e2e    TC_E2EU_031    positive
    TC_E2EU_031

TC_E2EU_032 Validate IMSI Is Activated Again
    [Documentation]    Searches Manage Devices by IMSI captured in TC_E2EU_029 and
    ...                verifies the state column shows Activated again.
    [Tags]    regression    e2e    TC_E2EU_032    positive
    TC_E2EU_032

# ═══════════════════════════════════════════════════════════════════════
#  2nd CSR JOURNEY + DEVICE PLAN CHANGE (Steps 17–18)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_022 Create Second CSR Journey With Different Plan
    [Documentation]    Creates a second CSR Journey for the same account with different
    ...                tariff/APN/device plan so a different device plan is available for DP change.
    [Tags]    regression    e2e    TC_E2EU_022    positive
    TC_E2EU_022

TC_E2EU_023 Perform Device Plan Change On One Activated SIM And Validate
    [Documentation]    On Manage Devices, filters by BU + Activated, performs device plan
    ...                change on one SIM, waits 5 min, then verifies device plan updated in grid.
    [Tags]    regression    e2e    TC_E2EU_023    positive
    TC_E2EU_023

# ═══════════════════════════════════════════════════════════════════════
#  REPORT (Step 19 — before invoice so report captures all usage events)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_024 Create Usage Report For Onboarded Account And Download
    [Documentation]    Creates a Usage Report at OPCO display level (KSA_OPCO) covering
    ...                the onboarded EC and BU account. Downloads the report file to the
    ...                Report subfolder of the current run's output directory.
    [Tags]    regression    e2e    TC_E2EU_024    positive
    TC_E2EU_024

# ═══════════════════════════════════════════════════════════════════════
#  INVOICE (Step 20 — after all events: usage + suspend/resume + DP change)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_021 Generate Invoice And Download CSV
    [Documentation]    Calls Invoice API with BU account ID after all billing events
    ...                (usage, suspend/resume, DP change) so the invoice billing file
    ...                includes all charges. Downloads CSV from server to local billing/ folder.
    [Tags]    regression    e2e    TC_E2EU_021    positive
    TC_E2EU_021

# ═══════════════════════════════════════════════════════════════════════
#  ROLE & USER CRUD (Step 21)
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_025 Create Role
    [Documentation]    Creates a new role with account, name, description and permissions.
    ...                Verifies success toast and role visible in the grid.
    [Tags]    regression    e2e    TC_E2EU_025    positive
    TC_E2EU_025

TC_E2EU_026 Delete Created Role
    [Documentation]    Deletes the role created in TC_E2EU_025 and verifies removal from grid.
    [Tags]    regression    e2e    TC_E2EU_026    positive
    TC_E2EU_026

TC_E2EU_027 Create User
    [Documentation]    Creates a new user with all required fields.
    ...                Verifies success toast and user visible in the grid.
    [Tags]    regression    e2e    TC_E2EU_027    positive
    TC_E2EU_027

TC_E2EU_028 Delete Created User
    [Documentation]    Deletes the user created in TC_E2EU_027 and verifies removal from grid.
    [Tags]    regression    e2e    TC_E2EU_028    positive
    TC_E2EU_028

*** Keywords ***
TC_E2EU_001
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
    # Persist EC/BU names under flow-specific seed keys (e2e_flow_with_usage)
    Write Seed Value    e2e_usage_ec_name    ${E2E_EC_NAME}
    Write Seed Value    e2e_usage_bu_name    ${E2E_BU_NAME}
    Log    ===== ONBOARD SUCCESS =====    console=yes
    Log    EC Name : ${E2E_EC_NAME}    console=yes
    Log    BU Name : ${E2E_BU_NAME}    console=yes

TC_E2EU_002
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

TC_E2EU_003
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${E2E_EC_NAME}    ${E2E_BU_NAME}

TC_E2EU_004
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create CSR Journey    ${E2E_EC_NAME}    ${E2E_BU_NAME}

TC_E2EU_005
    E2E Create SIM Range

TC_E2EU_006
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create Product Type And Assign EC    ${E2E_EC_NAME}

TC_E2EU_007
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Expand EC And BU SIM Limits    ${E2E_EC_NAME}    ${E2E_BU_NAME}    10

TC_E2EU_008
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create SIM Order    ${E2E_EC_NAME}    ${E2E_BU_NAME}

TC_E2EU_009
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_ORDER_ID}    ${order_id}
    Log    Suite variable E2E_ORDER_ID set to: ${E2E_ORDER_ID}    console=yes

TC_E2EU_010
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_EC_ID}    ${ec_id}
    Set Suite Variable    ${E2E_BU_ID}    ${bu_id}
    Log    EC ID: ${E2E_EC_ID}, BU ID: ${E2E_BU_ID}    console=yes

TC_E2EU_011
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    ${output}=    E2E Run Create Order Script
    Log    Create order script completed for order ${E2E_ORDER_ID}    console=yes

TC_E2EU_012
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${E2E_ORDER_ID}

TC_E2EU_013
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${E2E_ORDER_ID}

TC_E2EU_014
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    ${output}=    E2E Run Read Order Script
    Log    Read order script completed for order ${E2E_ORDER_ID}    console=yes

TC_E2EU_015
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${E2E_ORDER_ID}

TC_E2EU_016
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${E2E_BU_NAME}
    Log    ${row_count} SIMs in Warm state for BU: ${E2E_BU_NAME}    console=yes

TC_E2EU_017
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 7 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${E2E_ORDER_ID}

TC_E2EU_018
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    ${activated_imsis}    ${imsi_data}=    E2E Activate SIMs And Capture IMSIs    ${E2E_BU_NAME}
    Set Suite Variable    @{E2E_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{E2E_IMSI_DATA}    @{imsi_data}
    Log    Activated ${SIM_ACTIVATE_COUNT} SIMs. IMSIs + MSISDNs stored for usage.    console=yes
    FOR    ${entry}    IN    @{E2E_IMSI_DATA}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END
    # Persist flow-specific IMSI/ICCID seed keys for SIM Movement / Device Plan / SIM Replacement
    ${_imsi_count}=    Get Length    ${activated_imsis}
    IF    ${_imsi_count} > 0
        ${_first}=    Get From List    ${activated_imsis}    0
        Write Seed Value    e2e_usage_first_activated_imsi    ${_first}
    END
    IF    ${_imsi_count} > 1
        ${_second}=    Get From List    ${activated_imsis}    1
        Write Seed Value    e2e_usage_second_activated_imsi    ${_second}
    END

TC_E2EU_019
    Populate IMSI Data If Needed
    ${count}=    Get Length    ${E2E_IMSI_DATA}
    Should Be True    ${count} > 0
    ...    No IMSI data available. Run Step 16 first or pass --variable E2E_IMSI_CSV:IMSI1,IMSI2,...
    E2E Perform Usage For All IMSIs    @{E2E_IMSI_DATA}
    Log    Step 16a complete: Usage performed for all ${count} IMSIs.    console=yes

TC_E2EU_020
    Populate IMSI Data If Needed
    ${count}=    Get Length    ${E2E_IMSI_DATA}
    Should Be True    ${count} > 0
    ...    No IMSI data available. Run Step 16 first or pass --variable E2E_IMSI_CSV:IMSI1,IMSI2,...
    E2E Validate Usage In UI    @{E2E_IMSI_DATA}
    Log    Step 16b complete: All ${count} IMSIs usage verified in UI.    console=yes

TC_E2EU_021
    ${bu_id_str}=    Convert To String    ${E2E_BU_ID}
    Should Not Be Empty    ${bu_id_str}    Step 8 must run first — BU ID is empty.
    ${local_path}    ${filename}=    E2E Generate And Download Invoice    ${bu_id_str}
    Set Suite Variable    ${E2E_INVOICE_PATH}    ${local_path}
    Log    Invoice downloaded: ${filename} → ${local_path}    console=yes

TC_E2EU_022
    Should Not Be Empty    ${E2E_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create Second CSR Journey With Different Plan    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Log    Step 18 complete: Second CSR Journey created (different APN/device plan).    console=yes

TC_E2EU_023
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Perform Device Plan Change On One Activated SIM And Validate    ${E2E_BU_NAME}
    Log    Step 19 complete: DP change performed and validated on one activated SIM.    console=yes

TC_E2EU_024
    [Documentation]    Creates a Usage Report at OPCO display level (auto-selects KSA_OPCO),
    ...                waits for it to be ready, downloads it into the Report subfolder of
    ...                the current run output directory.
    ${report_dir}=    Set Variable    ${OUTPUT DIR}${/}Report
    Create Directory    ${report_dir}
    Login And Navigate To Create Report
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    OPCO
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Submit Create Report Form
    Verify Report Created Successfully And Grid Visible
    Apply Report Name Filter    ${REPORT_CATEGORY_NAME}
    Download Report From First Row And Verify Click    ${REPORT_CATEGORY_NAME}
    Log    Step 17 complete: Usage Report created and downloaded to ${report_dir}    console=yes

TC_E2EU_025
    [Documentation]    Creates a role for E2E CRUD validation.
    ${suffix}=    Generate Random String    6    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    Set Suite Variable    ${E2E_CRUD_ROLE_NAME}    E2ERole_${suffix}
    ${crud_email}=    Set Variable    e2euser${suffix}@mailinator.com
    Set Suite Variable    ${E2E_CRUD_USER_EMAIL}    ${crud_email}
    Set Suite Variable    ${E2E_CRUD_USERNAME}    e2euser${suffix}
    Login And Navigate To Manage Role
    Open Create Role Form
    Fill Role Creation Form With Permissions    role_name=${E2E_CRUD_ROLE_NAME}
    Click Role Submit Button
    Verify Role Success Toast
    Refresh Manage Role Page
    Verify Role In Grid    ${E2E_CRUD_ROLE_NAME}
    Log    Step 20a complete: Role '${E2E_CRUD_ROLE_NAME}' created.    console=yes

TC_E2EU_026
    [Documentation]    Deletes the role created in TC_E2EU_025.
    Should Not Be Empty    ${E2E_CRUD_ROLE_NAME}    TC_E2EU_025 must run first.
    Navigate To Manage Role Page
    Delete Role End To End    ${E2E_CRUD_ROLE_NAME}
    Log    Step 20b complete: Role '${E2E_CRUD_ROLE_NAME}' deleted.    console=yes

TC_E2EU_027
    [Documentation]    Creates a user for E2E CRUD validation.
    Should Not Be Empty    ${E2E_CRUD_USERNAME}    TC_E2EU_025 must run first (sets username).
    Navigate To Manage User Page
    Open Create User Form
    Verify Create User Form Loaded
    Fill User Creation Form
    ...    username=${E2E_CRUD_USERNAME}
    ...    email=${E2E_CRUD_USER_EMAIL}
    Click Submit Button
    Verify Success Toast Displayed
    Navigate Back To Manage User Page
    Verify User In Grid    ${E2E_CRUD_USERNAME}
    Log    Step 20c complete: User '${E2E_CRUD_USERNAME}' created.    console=yes

TC_E2EU_028
    [Documentation]    Deletes the user created in TC_E2EU_027.
    Should Not Be Empty    ${E2E_CRUD_USERNAME}    TC_E2EU_025 must run first (sets username).
    Navigate To Manage User Page
    Delete User End To End    ${E2E_CRUD_USERNAME}
    Log    Step 20d complete: User '${E2E_CRUD_USERNAME}' deleted.    console=yes

TC_E2EU_029
    Populate IMSI Data If Needed
    ${count}=    Get Length    ${E2E_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data available. TC_E2EU_018 must run first.
    ${first_entry}=    Get From List    ${E2E_IMSI_DATA}    0
    ${imsi}=    Set Variable    ${first_entry}[imsi]
    Set Suite Variable    ${E2E_SUSPEND_IMSI}    ${imsi}
    Log    Step 16c: Suspending IMSI ${imsi} (Activated → Suspended)...    console=yes
    E2E Change SIM State    ${E2E_BU_NAME}    ${imsi}    Activated    Suspended
    Log    Step 16c complete: Suspend submitted for IMSI ${imsi}. Waiting 5 min...    console=yes

TC_E2EU_030
    Should Not Be Empty    ${E2E_SUSPEND_IMSI}    TC_E2EU_029 must run first.
    Log    Step 16d: Verifying IMSI ${E2E_SUSPEND_IMSI} is Suspended...    console=yes
    Verify Device State After Change    ${E2E_SUSPEND_IMSI}    Suspended
    Log    Step 16d complete: IMSI ${E2E_SUSPEND_IMSI} confirmed Suspended.    console=yes

TC_E2EU_031
    Should Not Be Empty    ${E2E_SUSPEND_IMSI}    TC_E2EU_029 must run first.
    Log    Step 16e: Resuming IMSI ${E2E_SUSPEND_IMSI} (Suspended → Activated)...    console=yes
    E2E Change SIM State    ${E2E_BU_NAME}    ${E2E_SUSPEND_IMSI}    Suspended    Activated
    Log    Step 16e complete: Resume submitted for IMSI ${E2E_SUSPEND_IMSI}. Waiting 5 min...    console=yes

TC_E2EU_032
    Should Not Be Empty    ${E2E_SUSPEND_IMSI}    TC_E2EU_029 must run first.
    Log    Step 16f: Verifying IMSI ${E2E_SUSPEND_IMSI} is Activated again...    console=yes
    Verify Device State After Change    ${E2E_SUSPEND_IMSI}    Activated
    Log    Step 16f complete: IMSI ${E2E_SUSPEND_IMSI} confirmed Activated.    console=yes

TC_E2EU_SIT_001
    [Documentation]    Polls Order History every 30s for up to 30 min until order reaches Completed.
    Should Not Be Empty    ${E2E_ORDER_ID}    Step 9 must run first — Order ID is empty.
    Should Not Be Empty    ${E2E_BU_NAME}     Step 1 must run first — BU name is empty.
    Log    SIT: Waiting for order ${E2E_ORDER_ID} to complete automatically (up to 30 min)...    console=yes
    Wait Until Keyword Succeeds    60x    30s
    ...    E2E Verify Order Status In History    ${E2E_BU_NAME}    ${E2E_ORDER_ID}    Completed
    Log    SIT Step: Order ${E2E_ORDER_ID} reached Completed status.    console=yes

TC_E2EU_SIT_002
    [Documentation]    Polls Manage Devices every 30s for up to 30 min until SIMs reach InActive state.
    Should Not Be Empty    ${E2E_BU_NAME}    Step 1 must run first — BU name is empty.
    Log    SIT: Waiting for SIMs to reach InActive state automatically (up to 30 min)...    console=yes
    Wait Until Keyword Succeeds    60x    30s
    ...    E2E Verify At Least One SIM In State    ${E2E_BU_NAME}    InActive
    Log    SIT Step: SIMs reached InActive state.    console=yes

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
