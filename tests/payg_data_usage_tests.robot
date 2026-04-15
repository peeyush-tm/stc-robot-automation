*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     XML
Library     Collections
Library     String
Resource    ../resources/keywords/e2e_keywords.resource
Resource    ../resources/keywords/usage_keywords.resource
Library     ../libraries/ConfigLoader.py
Library     ../libraries/PaygRangeIds.py
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
Variables   ../variables/payg_usage_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    PAYG Hydrate From Seed If Needed    AND    PAYG Apply Resume Imsi Data If Set    AND    E2E Suite Setup
Suite Teardown    Close All Browsers
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Variables ***
${PAYG_EC_NAME}             ${EMPTY}
${PAYG_BU_NAME}             ${EMPTY}
# Optional: when re-running steps 18–20 (or if step 17 fails), pass IMSI/MSISDN from the last grid/log.
${PAYG_RESUME_IMSI}         ${EMPTY}
${PAYG_RESUME_MSISDN}       ${EMPTY}
${PAYG_ORDER_ID}            ${EMPTY}
${PAYG_EC_ID}               ${EMPTY}
${PAYG_BU_ID}               ${EMPTY}
@{PAYG_ACTIVATED_IMSIS}
@{PAYG_IMSI_DATA}

*** Test Cases ***
# ===========================================================================
#  SCENARIO 1: PAYG DATA USAGE WITH SIM PLAN
# ===========================================================================

TC_PAYG_SIM_01 Onboard Account
    [Documentation]    Onboard EC + BU via SOAP API for SIM Plan PAYG scenario.
    [Tags]    payg    sim-plan    step-1    onboard    api
    PAYG Onboard Account

TC_PAYG_SIM_02 Verify Onboarded Account On UI
    [Documentation]    Wait for backend processing and verify account on ManageAccount page.
    [Tags]    payg    sim-plan    step-2    onboard    validation
    PAYG Verify Account On UI

TC_PAYG_SIM_03 Create APN
    [Documentation]    Create APN for the onboarded account.
    [Tags]    payg    sim-plan    step-3    apn
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}

TC_PAYG_SIM_04 Create CSR Journey With SIM Plan
    [Documentation]    CSR wizard with SIM device plan (``${PAYG_SIM_PLAN_DP}`` from config), PAYG tariff ``${PAYG_TARIFF_PLAN}``.
    ...                Uses ``CSRJ Complete Wizard With Specific Plans`` — Add Service Plan enables all main services
    ...                (International Voice, Data NB-IoT, PAYG toggles, Roaming, etc.); restriction checkboxes stay off.
    [Tags]    payg    sim-plan    step-4    csr-journey
    PAYG Create CSR Journey    ${PAYG_SIM_PLAN_DP}

TC_PAYG_SIM_05 Create SIM Range
    [Documentation]    ICCID/IMSI/MSISDN ranges (size 1 each, pool count 1). Refreshes unique IDs for this scenario tag ``sim``.
    ...                SIM Range Account uses default/first option (KSA_OPCO) on both Create pages; onboarded EC is not selected there.
    [Tags]    payg    sim-plan    step-5    sim-range
    PAYG Create SIM Range    sim

TC_PAYG_SIM_06 Create And Assign Product Type
    [Documentation]    SIM Product Type for the same EC as this scenario (E2E flow; config/env URLs apply).
    ...                Unique ``${PT_NAME}`` per scenario so step 7 selects this PT (not a stale name from SIM/Pool/Shared).
    [Tags]    payg    sim-plan    step-6    product-type
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    PAYG Assign Unique Product Type Name
    E2E Create Product Type And Assign EC    ${PAYG_EC_NAME}

TC_PAYG_SIM_07 Create SIM Order
    [Documentation]    Create SIM Order with quantity 1.
    [Tags]    payg    sim-plan    step-7    sim-order
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create SIM Order    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}    quantity=${PAYG_ORDER_QUANTITY}

TC_PAYG_SIM_08 Capture Order ID
    [Documentation]    Capture Order ID from Live Order grid.
    [Tags]    payg    sim-plan    step-8    order-processing    capture
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${PAYG_BU_NAME}
    Set Suite Variable    ${PAYG_ORDER_ID}    ${order_id}
    Log    PAYG_ORDER_ID set to: ${PAYG_ORDER_ID}    console=yes

TC_PAYG_SIM_09 Fetch Account IDs From Database
    [Documentation]    Fetch EC and BU account IDs from database.
    [Tags]    payg    sim-plan    step-9    order-processing    database
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}
    Set Suite Variable    ${PAYG_EC_ID}    ${ec_id}
    Set Suite Variable    ${PAYG_BU_ID}    ${bu_id}
    Log    EC ID: ${PAYG_EC_ID}, BU ID: ${PAYG_BU_ID}    console=yes

TC_PAYG_SIM_10 Run Create Order Script
    [Documentation]    Run start_createorder.sh on server.
    [Tags]    payg    sim-plan    step-10    order-processing    ssh
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Run Create Order Script
    Log    Create order script completed for order ${PAYG_ORDER_ID}    console=yes

TC_PAYG_SIM_11 Validate Order In Progress
    [Documentation]    Validate order status changed from New to In Progress.
    [Tags]    payg    sim-plan    step-11    order-processing    validation
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${PAYG_ORDER_ID}

TC_PAYG_SIM_12 Upload Response Files
    [Documentation]    Generate and upload response files to server.
    [Tags]    payg    sim-plan    step-12    order-processing    files
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${PAYG_ORDER_ID}

TC_PAYG_SIM_13 Run Read Order Script
    [Documentation]    Run start_readorder.sh on server.
    [Tags]    payg    sim-plan    step-13    order-processing    ssh
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Run Read Order Script
    Log    Read order script completed for order ${PAYG_ORDER_ID}    console=yes

TC_PAYG_SIM_14 Validate Order Completed
    [Documentation]    Validate order status changed to Completed.
    [Tags]    payg    sim-plan    step-14    order-processing    validation
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${PAYG_ORDER_ID}

TC_PAYG_SIM_15 Validate SIMs In Warm State
    [Documentation]    Validate 1 SIM in Warm state on Manage Devices.
    [Tags]    payg    sim-plan    step-15    manage-devices    validation
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${PAYG_BU_NAME}    min_count=${PAYG_SIM_ACTIVATE_COUNT}
    Log    ${row_count} SIMs in Warm state for BU: ${PAYG_BU_NAME}    console=yes

TC_PAYG_SIM_16 Approve Order Via SOAP
    [Documentation]    Update order status to Approved via SOAP API.
    [Tags]    payg    sim-plan    step-16    api    soap
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${PAYG_ORDER_ID}

TC_PAYG_SIM_17 Activate SIMs And Capture Data
    [Documentation]    Activate 1 SIM and capture IMSI + MSISDN for usage.
    [Tags]    payg    sim-plan    step-17    device-state-change    activation
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${activated_imsis}    ${imsi_data}=    E2E Activate SIMs And Capture IMSIs    ${PAYG_BU_NAME}    count=${PAYG_SIM_ACTIVATE_COUNT}
    Set Suite Variable    @{PAYG_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{PAYG_IMSI_DATA}    @{imsi_data}
    Log    Activated SIMs. IMSIs + MSISDNs stored for usage.    console=yes
    FOR    ${entry}    IN    @{PAYG_IMSI_DATA}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END

TC_PAYG_SIM_18 Iterative Usage Until PAYG Quota
    [Documentation]    For each IMSI, iterate User Request + CDR until quotaType becomes payg.
    [Tags]    payg    sim-plan    step-18    usage    api
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    Perform Iterative Usage Until PAYG For All IMSIs    @{PAYG_IMSI_DATA}
    Log    Iterative usage complete: all IMSIs reached quotaType=payg.    console=yes

TC_PAYG_SIM_19 Perform PAYG Data Usage
    [Documentation]    After quotaType=payg, perform one PAYG data usage for each IMSI.
    [Tags]    payg    sim-plan    step-19    usage    api    payg-data
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    FOR    ${entry}    IN    @{PAYG_IMSI_DATA}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        ${msisdn}=    Get From Dictionary    ${entry}    msisdn
        Perform PAYG Data Usage For Single IMSI    ${imsi}    ${msisdn}
    END
    Log    PAYG data usage performed for all IMSIs.    console=yes

TC_PAYG_SIM_20 Validate PAYG Usage In UI
    [Documentation]    Expand each IMSI on Manage Devices, verify PAYG data usage > 0 MB.
    [Tags]    payg    sim-plan    step-20    usage    validation    ui
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    Validate PAYG Usage In UI For All IMSIs    @{PAYG_IMSI_DATA}
    Log    PAYG usage validated in UI for all IMSIs.    console=yes

# ===========================================================================
#  SCENARIO 2: PAYG DATA USAGE WITH POOL PLAN
# ===========================================================================

TC_PAYG_POOL_01 Onboard Account
    [Documentation]    Onboard EC + BU via SOAP API for Pool Plan PAYG scenario.
    [Tags]    payg    pool-plan    step-1    onboard    api
    PAYG Onboard Account

TC_PAYG_POOL_02 Verify Onboarded Account On UI
    [Documentation]    Wait for backend processing and verify account on ManageAccount page.
    [Tags]    payg    pool-plan    step-2    onboard    validation
    PAYG Verify Account On UI

TC_PAYG_POOL_03 Create APN
    [Documentation]    Create APN for the onboarded account.
    [Tags]    payg    pool-plan    step-3    apn
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}

TC_PAYG_POOL_04 Create CSR Journey With Pool Plan
    [Documentation]    CSR wizard with Pool device plan (``${PAYG_POOL_PLAN_DP}`` from config), PAYG tariff ``${PAYG_TARIFF_PLAN}``.
    ...                Same full Add Service Plan behaviour as SIM scenario (all main services; restrictions off).
    [Tags]    payg    pool-plan    step-4    csr-journey
    PAYG Create CSR Journey    ${PAYG_POOL_PLAN_DP}

TC_PAYG_POOL_05 Create SIM Range
    [Documentation]    ICCID/IMSI/MSISDN ranges (size 1 each). Refreshes unique IDs for tag ``pool`` (avoids collision with SIM/shared in same run).
    ...                SIM Range Account: default KSA_OPCO (same as SIM plan step 5).
    [Tags]    payg    pool-plan    step-5    sim-range
    PAYG Create SIM Range    pool

TC_PAYG_POOL_06 Create And Assign Product Type
    [Documentation]    SIM Product Type for the same EC as this scenario (same E2E keywords as SIM plan).
    ...                Unique ``${PT_NAME}`` per scenario for SIM Order step 7 (same as SIM plan step 6).
    [Tags]    payg    pool-plan    step-6    product-type
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    PAYG Assign Unique Product Type Name
    E2E Create Product Type And Assign EC    ${PAYG_EC_NAME}

TC_PAYG_POOL_07 Create SIM Order
    [Documentation]    Create SIM Order with quantity 1.
    [Tags]    payg    pool-plan    step-7    sim-order
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create SIM Order    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}    quantity=${PAYG_ORDER_QUANTITY}

TC_PAYG_POOL_08 Capture Order ID
    [Documentation]    Capture Order ID from Live Order grid.
    [Tags]    payg    pool-plan    step-8    order-processing    capture
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${PAYG_BU_NAME}
    Set Suite Variable    ${PAYG_ORDER_ID}    ${order_id}
    Log    PAYG_ORDER_ID set to: ${PAYG_ORDER_ID}    console=yes

TC_PAYG_POOL_09 Fetch Account IDs From Database
    [Documentation]    Fetch EC and BU account IDs from database.
    [Tags]    payg    pool-plan    step-9    order-processing    database
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}
    Set Suite Variable    ${PAYG_EC_ID}    ${ec_id}
    Set Suite Variable    ${PAYG_BU_ID}    ${bu_id}
    Log    EC ID: ${PAYG_EC_ID}, BU ID: ${PAYG_BU_ID}    console=yes

TC_PAYG_POOL_10 Run Create Order Script
    [Documentation]    Run start_createorder.sh on server.
    [Tags]    payg    pool-plan    step-10    order-processing    ssh
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Run Create Order Script
    Log    Create order script completed for order ${PAYG_ORDER_ID}    console=yes

TC_PAYG_POOL_11 Validate Order In Progress
    [Documentation]    Validate order status changed from New to In Progress.
    [Tags]    payg    pool-plan    step-11    order-processing    validation
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${PAYG_ORDER_ID}

TC_PAYG_POOL_12 Upload Response Files
    [Documentation]    Generate and upload response files to server.
    [Tags]    payg    pool-plan    step-12    order-processing    files
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${PAYG_ORDER_ID}

TC_PAYG_POOL_13 Run Read Order Script
    [Documentation]    Run start_readorder.sh on server.
    [Tags]    payg    pool-plan    step-13    order-processing    ssh
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Run Read Order Script
    Log    Read order script completed for order ${PAYG_ORDER_ID}    console=yes

TC_PAYG_POOL_14 Validate Order Completed
    [Documentation]    Validate order status changed to Completed.
    [Tags]    payg    pool-plan    step-14    order-processing    validation
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${PAYG_ORDER_ID}

TC_PAYG_POOL_15 Validate SIMs In Warm State
    [Documentation]    Validate 1 SIM in Warm state on Manage Devices.
    [Tags]    payg    pool-plan    step-15    manage-devices    validation
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${PAYG_BU_NAME}    min_count=${PAYG_SIM_ACTIVATE_COUNT}
    Log    ${row_count} SIMs in Warm state for BU: ${PAYG_BU_NAME}    console=yes

TC_PAYG_POOL_16 Approve Order Via SOAP
    [Documentation]    Update order status to Approved via SOAP API.
    [Tags]    payg    pool-plan    step-16    api    soap
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${PAYG_ORDER_ID}

TC_PAYG_POOL_17 Activate SIMs And Capture Data
    [Documentation]    Activate 1 SIM and capture IMSI + MSISDN for usage.
    [Tags]    payg    pool-plan    step-17    device-state-change    activation
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${activated_imsis}    ${imsi_data}=    E2E Activate SIMs And Capture IMSIs    ${PAYG_BU_NAME}    count=${PAYG_SIM_ACTIVATE_COUNT}
    Set Suite Variable    @{PAYG_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{PAYG_IMSI_DATA}    @{imsi_data}
    Log    Activated SIMs. IMSIs + MSISDNs stored for usage.    console=yes
    FOR    ${entry}    IN    @{PAYG_IMSI_DATA}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END

TC_PAYG_POOL_18 Iterative Usage Until PAYG Quota
    [Documentation]    For each IMSI, iterate User Request + CDR until quotaType becomes payg.
    [Tags]    payg    pool-plan    step-18    usage    api
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    Perform Iterative Usage Until PAYG For All IMSIs    @{PAYG_IMSI_DATA}
    Log    Iterative usage complete: all IMSIs reached quotaType=payg.    console=yes

TC_PAYG_POOL_19 Perform PAYG Data Usage
    [Documentation]    After quotaType=payg, perform one PAYG data usage for each IMSI.
    [Tags]    payg    pool-plan    step-19    usage    api    payg-data
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    FOR    ${entry}    IN    @{PAYG_IMSI_DATA}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        ${msisdn}=    Get From Dictionary    ${entry}    msisdn
        Perform PAYG Data Usage For Single IMSI    ${imsi}    ${msisdn}
    END
    Log    PAYG data usage performed for all IMSIs.    console=yes

TC_PAYG_POOL_20 Validate PAYG Usage In UI
    [Documentation]    Expand each IMSI on Manage Devices, verify PAYG data usage > 0 MB.
    [Tags]    payg    pool-plan    step-20    usage    validation    ui
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    Validate PAYG Usage In UI For All IMSIs    @{PAYG_IMSI_DATA}
    Log    PAYG usage validated in UI for all IMSIs.    console=yes

# ===========================================================================
#  SCENARIO 3: PAYG DATA USAGE WITH SHARED PLAN
# ===========================================================================

TC_PAYG_SHARED_01 Onboard Account
    [Documentation]    Onboard EC + BU via SOAP API for Shared Plan PAYG scenario.
    [Tags]    payg    shared-plan    step-1    onboard    api
    PAYG Onboard Account

TC_PAYG_SHARED_02 Verify Onboarded Account On UI
    [Documentation]    Wait for backend processing and verify account on ManageAccount page.
    [Tags]    payg    shared-plan    step-2    onboard    validation
    PAYG Verify Account On UI

TC_PAYG_SHARED_03 Create APN
    [Documentation]    Create APN for the onboarded account.
    [Tags]    payg    shared-plan    step-3    apn
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    E2E Create APN    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}

TC_PAYG_SHARED_04 Create CSR Journey With Shared Plan
    [Documentation]    CSR wizard with Shared device plan (``${PAYG_SHARED_PLAN_DP}`` from config), PAYG tariff ``${PAYG_TARIFF_PLAN}``.
    ...                Same full Add Service Plan behaviour as SIM scenario (all main services; restrictions off).
    [Tags]    payg    shared-plan    step-4    csr-journey
    PAYG Create CSR Journey    ${PAYG_SHARED_PLAN_DP}

TC_PAYG_SHARED_05 Create SIM Range
    [Documentation]    ICCID/IMSI/MSISDN ranges (size 1 each). Refreshes unique IDs for tag ``shared``.
    ...                SIM Range Account: default KSA_OPCO (same as SIM plan step 5).
    [Tags]    payg    shared-plan    step-5    sim-range
    PAYG Create SIM Range    shared

TC_PAYG_SHARED_06 Create And Assign Product Type
    [Documentation]    SIM Product Type for the same EC as this scenario (same E2E keywords as SIM plan).
    ...                Unique ``${PT_NAME}`` per scenario for SIM Order step 7 (same as SIM plan step 6).
    [Tags]    payg    shared-plan    step-6    product-type
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    PAYG Assign Unique Product Type Name
    E2E Create Product Type And Assign EC    ${PAYG_EC_NAME}

TC_PAYG_SHARED_07 Create SIM Order
    [Documentation]    Create SIM Order with quantity 1.
    [Tags]    payg    shared-plan    step-7    sim-order
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    E2E Create SIM Order    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}    quantity=${PAYG_ORDER_QUANTITY}

TC_PAYG_SHARED_08 Capture Order ID
    [Documentation]    Capture Order ID from Live Order grid.
    [Tags]    payg    shared-plan    step-8    order-processing    capture
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${order_id}=    E2E Capture Order ID    ${PAYG_BU_NAME}
    Set Suite Variable    ${PAYG_ORDER_ID}    ${order_id}
    Log    PAYG_ORDER_ID set to: ${PAYG_ORDER_ID}    console=yes

TC_PAYG_SHARED_09 Fetch Account IDs From Database
    [Documentation]    Fetch EC and BU account IDs from database.
    [Tags]    payg    shared-plan    step-9    order-processing    database
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${ec_id}    ${bu_id}=    E2E Fetch Account IDs From DB    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}
    Set Suite Variable    ${PAYG_EC_ID}    ${ec_id}
    Set Suite Variable    ${PAYG_BU_ID}    ${bu_id}
    Log    EC ID: ${PAYG_EC_ID}, BU ID: ${PAYG_BU_ID}    console=yes

TC_PAYG_SHARED_10 Run Create Order Script
    [Documentation]    Run start_createorder.sh on server.
    [Tags]    payg    shared-plan    step-10    order-processing    ssh
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Run Create Order Script
    Log    Create order script completed for order ${PAYG_ORDER_ID}    console=yes

TC_PAYG_SHARED_11 Validate Order In Progress
    [Documentation]    Validate order status changed from New to In Progress.
    [Tags]    payg    shared-plan    step-11    order-processing    validation
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Validate Order Status New To In Progress    ${PAYG_ORDER_ID}

TC_PAYG_SHARED_12 Upload Response Files
    [Documentation]    Generate and upload response files to server.
    [Tags]    payg    shared-plan    step-12    order-processing    files
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Generate And Upload Response Files    ${PAYG_ORDER_ID}

TC_PAYG_SHARED_13 Run Read Order Script
    [Documentation]    Run start_readorder.sh on server.
    [Tags]    payg    shared-plan    step-13    order-processing    ssh
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Run Read Order Script
    Log    Read order script completed for order ${PAYG_ORDER_ID}    console=yes

TC_PAYG_SHARED_14 Validate Order Completed
    [Documentation]    Validate order status changed to Completed.
    [Tags]    payg    shared-plan    step-14    order-processing    validation
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Validate Order Status Completed    ${PAYG_ORDER_ID}

TC_PAYG_SHARED_15 Validate SIMs In Warm State
    [Documentation]    Validate 1 SIM in Warm state on Manage Devices.
    [Tags]    payg    shared-plan    step-15    manage-devices    validation
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${row_count}=    E2E Validate SIMs In Warm State    ${PAYG_BU_NAME}    min_count=${PAYG_SIM_ACTIVATE_COUNT}
    Log    ${row_count} SIMs in Warm state for BU: ${PAYG_BU_NAME}    console=yes

TC_PAYG_SHARED_16 Approve Order Via SOAP
    [Documentation]    Update order status to Approved via SOAP API.
    [Tags]    payg    shared-plan    step-16    api    soap
    Should Not Be Empty    ${PAYG_ORDER_ID}    Step 8 must run first — Order ID is empty.
    E2E Update Order Status To Approved    ${PAYG_ORDER_ID}

TC_PAYG_SHARED_17 Activate SIMs And Capture Data
    [Documentation]    Activate 1 SIM and capture IMSI + MSISDN for usage.
    [Tags]    payg    shared-plan    step-17    device-state-change    activation
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    ${activated_imsis}    ${imsi_data}=    E2E Activate SIMs And Capture IMSIs    ${PAYG_BU_NAME}    count=${PAYG_SIM_ACTIVATE_COUNT}
    Set Suite Variable    @{PAYG_ACTIVATED_IMSIS}    @{activated_imsis}
    Set Suite Variable    @{PAYG_IMSI_DATA}    @{imsi_data}
    Log    Activated SIMs. IMSIs + MSISDNs stored for usage.    console=yes
    FOR    ${entry}    IN    @{PAYG_IMSI_DATA}
        Log    IMSI: ${entry}[imsi] | MSISDN: ${entry}[msisdn]    console=yes
    END

TC_PAYG_SHARED_18 Iterative Usage Until PAYG Quota
    [Documentation]    For each IMSI, iterate User Request + CDR until quotaType becomes payg.
    [Tags]    payg    shared-plan    step-18    usage    api
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    Perform Iterative Usage Until PAYG For All IMSIs    @{PAYG_IMSI_DATA}
    Log    Iterative usage complete: all IMSIs reached quotaType=payg.    console=yes

TC_PAYG_SHARED_19 Perform PAYG Data Usage
    [Documentation]    After quotaType=payg, perform one PAYG data usage for each IMSI.
    [Tags]    payg    shared-plan    step-19    usage    api    payg-data
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    FOR    ${entry}    IN    @{PAYG_IMSI_DATA}
        ${imsi}=    Get From Dictionary    ${entry}    imsi
        ${msisdn}=    Get From Dictionary    ${entry}    msisdn
        Perform PAYG Data Usage For Single IMSI    ${imsi}    ${msisdn}
    END
    Log    PAYG data usage performed for all IMSIs.    console=yes

TC_PAYG_SHARED_20 Validate PAYG Usage In UI
    [Documentation]    Expand each IMSI on Manage Devices, verify PAYG data usage > 0 MB.
    [Tags]    payg    shared-plan    step-20    usage    validation    ui
    ${count}=    Get Length    ${PAYG_IMSI_DATA}
    Should Be True    ${count} > 0    No IMSI data. Run Step 17 first.
    Validate PAYG Usage In UI For All IMSIs    @{PAYG_IMSI_DATA}
    Log    PAYG usage validated in UI for all IMSIs.    console=yes

*** Keywords ***
PAYG Assign Unique Product Type Name
    [Documentation]    Sets suite ``${PT_NAME}`` to a new value before creating a SIM Product Type.
    ...                ``product_type_variables.PT_NAME`` is fixed at import time; without this, SIM/Pool/Shared in one suite
    ...                reuse the same name and step 7 may pick the wrong or missing catalog row (stuck on Preview).
    ${rnd}=    Evaluate    random.randint(10000, 99999)    modules=random
    ${ts}=    Evaluate    int(__import__('time').time())    modules=time
    Set Suite Variable    ${PT_NAME}    PAYG Auto PT ${ts}_${rnd}
    Log    PAYG PT_NAME for this scenario: ${PT_NAME}    console=yes

PAYG Hydrate From Seed If Needed
    [Documentation]    If PAYG_EC_NAME / PAYG_BU_NAME are empty, copy from ``payg_ec_name`` / ``payg_bu_name``
    ...                in ``variables/.run_seed.json`` (written by TC_PAYG_SIM_01 / TC_PAYG_POOL_01 / TC_PAYG_SHARED_01).
    ...                Use ``--keep-seed`` when re-running partial steps.
    IF    '${PAYG_EC_NAME}' == '${EMPTY}' and '${PAYG_SEED_EC_NAME}' != '${EMPTY}'
        Set Suite Variable    ${PAYG_EC_NAME}    ${PAYG_SEED_EC_NAME}
        Log    PAYG: set PAYG_EC_NAME from seed: ${PAYG_SEED_EC_NAME}    console=yes
    END
    IF    '${PAYG_BU_NAME}' == '${EMPTY}' and '${PAYG_SEED_BU_NAME}' != '${EMPTY}'
        Set Suite Variable    ${PAYG_BU_NAME}    ${PAYG_SEED_BU_NAME}
        Log    PAYG: set PAYG_BU_NAME from seed: ${PAYG_SEED_BU_NAME}    console=yes
    END

PAYG Apply Resume Imsi Data If Set
    [Documentation]    If PAYG_RESUME_IMSI and PAYG_RESUME_MSISDN are set (e.g. ``-v PAYG_RESUME_IMSI:...``),
    ...                pre-fills ``@{PAYG_IMSI_DATA}`` so steps 18–20 can run when step 17 is skipped or fails.
    ...                Step 17 still overwrites this list when activation succeeds.
    IF    '${PAYG_RESUME_IMSI}' != '${EMPTY}' and '${PAYG_RESUME_MSISDN}' != '${EMPTY}'
        ${row}=    Create Dictionary    imsi=${PAYG_RESUME_IMSI}    msisdn=${PAYG_RESUME_MSISDN}
        @{lst}=    Create List    ${row}
        Set Suite Variable    @{PAYG_IMSI_DATA}    @{lst}
        Log    PAYG: pre-filled PAYG_IMSI_DATA from PAYG_RESUME_IMSI/MSISDN for downstream steps.    console=yes
    END

PAYG Onboard Account
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
    Set Suite Variable    ${PAYG_EC_NAME}    ${data}[company_name]
    Set Suite Variable    ${PAYG_BU_NAME}    ${data}[billing_account_name]
    Write Seed Value    payg_ec_name    ${PAYG_EC_NAME}
    Write Seed Value    payg_bu_name    ${PAYG_BU_NAME}
    Log    ===== ONBOARD SUCCESS =====    console=yes
    Log    EC Name : ${PAYG_EC_NAME}    console=yes
    Log    BU Name : ${PAYG_BU_NAME}    console=yes

PAYG Verify Account On UI
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Should Not Be Empty    ${PAYG_BU_NAME}    Step 1 must run first — BU name is empty.
    Log    Waiting 5 minutes for backend to process onboarded account...    console=yes
    Sleep    300s    reason=Waiting 5 min for backend to process onboarded account
    ${passed}=    Run Keyword And Return Status
    ...    E2E Verify Account On UI    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}
    IF    not ${passed}
        Log    Account not found on first attempt. Waiting another 5 minutes and retrying...    console=yes
        Sleep    300s    reason=Retry wait — another 5 min for account to appear
        Go To    ${BASE_URL}ManageAccount
        Sleep    3s
        Wait For App Loading To Complete    timeout=60s
        E2E Verify Account On UI    ${PAYG_EC_NAME}    ${PAYG_BU_NAME}
    END

PAYG Create CSR Journey
    [Arguments]    ${device_plan}
    Should Not Be Empty    ${PAYG_EC_NAME}    Step 1 must run first — EC name is empty.
    Ensure Session Is Active
    # Use Admin → CSR tab (same as csr_journey_tests). Direct ${BASE_URL}CSRJourney often redirects away from listing.
    Go To CSR Journey Landing
    ${selected}=    Set Variable    ${FALSE}
    FOR    ${attempt}    IN RANGE    5
        ${selected}=    Run Keyword And Return Status
        ...    Select CSR Journey Customer By Name    ${PAYG_EC_NAME}
        IF    ${selected}    BREAK
        Log    Customer "${PAYG_EC_NAME}" not found on attempt ${attempt + 1}. Reloading CSR Journey landing...    console=yes    level=WARN
        CSRJ Dismiss Open Dropdowns On Landing
        Go To CSR Journey Landing
        Sleep    2s
    END
    Should Be True    ${selected}
    ...    Could not select customer "${PAYG_EC_NAME}" after 5 attempts (check EC visible in CSR Journey for this user / env).
    Select CSR Journey Business Unit By Name    ${PAYG_BU_NAME}
    Verify Create Order Button Visible
    Click Create Order
    Verify Standard Services Screen Loaded
    ${bundle_actual}=    CSRJ Complete Wizard With Specific Plans    ${PAYG_TARIFF_PLAN}    ${device_plan}
    Log    PAYG CSR Journey created: Tariff=${PAYG_TARIFF_PLAN}, DP=${device_plan}, Bundle=${bundle_actual}    console=yes

PAYG Create SIM Range
    [Arguments]    ${payg_range_tag}=sim
    [Documentation]    Creates ICCID/IMSI/MSISDN ranges with From=To (size 1 each) and defined pool count=1.
    ...                Refreshes ICCID/IMSI/MSISDN and pool names per call (tag: sim / pool / shared) so multi-scenario runs do not reuse values.
    ...                Account: uses default SIM Range behavior (``Select Account From Dropdown`` — first/default option, e.g. KSA_OPCO) for both ICCID/IMSI and MSISDN pages; the Account field is disabled/pre-filled in QE.
    Apply Fresh Payg Range Identifiers    ${payg_range_tag}
    Ensure Session Is Active
    Navigate To Module Page    ${CREATE_SIM_RANGE_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Fill SIM Range With ICCID And IMSI
    ...    pool_name=${PAYG_POOL_NAME}
    ...    description=${PAYG_SR_DESCRIPTION}
    ...    iccid_from=${PAYG_ICCID_FROM}
    ...    iccid_to=${PAYG_ICCID_TO}
    ...    imsi_from=${PAYG_IMSI_FROM}
    ...    imsi_to=${PAYG_IMSI_TO}
    ...    defined_pool_count=${PAYG_EXPECTED_POOL_COUNT}
    Verify Pool Count    ${PAYG_EXPECTED_POOL_COUNT}
    Submit SIM Range Form
    Verify SIM Range Created Successfully
    Log    PAYG SIM Range created: pool="${PAYG_POOL_NAME}" ICCID/IMSI count=1 each    console=yes
    Navigate To Module Page    ${CREATE_SIM_RANGE_MSISDN_URL}
    Wait Until Element Is Visible    ${LOC_SR_POOL_NAME}    timeout=30s
    Fill MSISDN SIM Range With Ranges
    ...    pool_name=${PAYG_MSISDN_POOL_NAME}
    ...    description=${PAYG_MSISDN_DESCRIPTION}
    ...    msisdn_from=${PAYG_MSISDN_FROM}
    ...    msisdn_to=${PAYG_MSISDN_TO}
    ...    defined_pool_count=${PAYG_EXPECTED_POOL_COUNT}
    Verify MSISDN Grid Has Rows    expected_min=1
    Submit SIM Range Form
    Verify SIM Range Created Successfully
    Log    PAYG MSISDN Range created: pool="${PAYG_MSISDN_POOL_NAME}" count=1    console=yes
