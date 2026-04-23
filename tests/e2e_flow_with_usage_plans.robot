*** Settings ***
Documentation     E2E Flow With Usage — Plan-Duration Matrix (4 scenarios).
...
...               Generated from prompts/e2e_flow_with_usage/Test_Case_Generation_Prompt.md
...               (Part 5 Worked Example).
...
...               Each scenario runs the baseline E2E flow end-to-end with a different
...               Bundle plan (Yearly / Half-Yearly / Quarterly / Monthly) while sharing
...               the same Tariff plan. Fixed overrides (Part 3 of the prompt):
...                   - APN type: Private Dynamic, random ID/name
...                   - SIM count: 2 ICCID/IMSI/MSISDN on KSA_OPCO
...                   - EC/BU limit expansion: +2
...                   - SIM Order quantity: 2
...                   - Activation: all 2 SIMs
...                   - Usage: 5 MB on 1 of 2 IMSIs; 2nd IMSI receives no usage
...                   - Step 18 (Second CSR Journey): SKIP
...                   - Step 19 (Device Plan Change): SKIP
...
...               KNOWN IMPLEMENTATION GAPS (see Part 6 of the prompt) — these MUST be
...               closed before the scenarios will actually run on QE:
...                   Gap 1. E2E Create CSR Journey needs tariff_plan/bundle_plan args.
...                   Gap 2. E2E Perform Usage For Selected IMSIs keyword does not exist.
...                   Gap 3. Private Dynamic APN subtype not yet supported in APN keyword.

Library     SeleniumLibrary
Library     RequestsLibrary
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

# Matrix-fixed values (Part 3 of the generation prompt)
${PLAN_SIM_QUANTITY}        ${2}
${PLAN_USAGE_MB}            ${5}
${PLAN_USAGE_IMSI_INDEX}    ${1}    # which of the activated IMSIs (1-based) receives usage
${PLAN_APN_ALLOC}           Dynamic


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  PLAN-DURATION MATRIX — 4 parallel scenarios
#    Axis of variation: Bundle plan duration (same Tariff, different Bundle)
#    Shared overrides: Part 3 of the generation prompt
# ═══════════════════════════════════════════════════════════════════════

TC_E2EU_YEARLY E2E With Usage Yearly Plan
    [Documentation]    Full E2E with Yearly Bundle (CSR_BUNDLE_PLAN_YEARLY, e.g. RPP-QRA-070425_1) —
    ...                2 SIMs, Private Dynamic APN, usage on 1 of 2 IMSIs, skips Step 18 + 19.
    ...                Validates rate-plan application across the full lifecycle for a yearly bundle.
    [Tags]    e2e    e2e-with-usage    plan-duration    yearly    regression
    E2E Run Plan Duration Scenario
    ...    tariff_config_key=CSR_TARIFF_PLAN_UNLIMITED_PAYG
    ...    bundle_config_key=CSR_BUNDLE_PLAN_YEARLY

TC_E2EU_HALFYEARLY E2E With Usage Half-Yearly Plan
    [Documentation]    Full E2E with Half-Yearly Bundle (CSR_BUNDLE_PLAN_HALFYEARLY,
    ...                e.g. HALFYRLY-SIMPLAN-QRA-070425_1) — 2 SIMs, Private Dynamic APN,
    ...                usage on 1 of 2 IMSIs, skips Step 18 + 19.
    [Tags]    e2e    e2e-with-usage    plan-duration    halfyearly    regression
    E2E Run Plan Duration Scenario
    ...    tariff_config_key=CSR_TARIFF_PLAN_UNLIMITED_PAYG
    ...    bundle_config_key=CSR_BUNDLE_PLAN_HALFYEARLY

TC_E2EU_QUARTERLY E2E With Usage Quarterly Plan
    [Documentation]    Full E2E with Quarterly Bundle (CSR_BUNDLE_PLAN_QUARTERLY,
    ...                e.g. QUARTERLY-SIMPLAN-QRA-070425_1) — 2 SIMs, Private Dynamic APN,
    ...                usage on 1 of 2 IMSIs, skips Step 18 + 19.
    [Tags]    e2e    e2e-with-usage    plan-duration    quarterly    regression
    E2E Run Plan Duration Scenario
    ...    tariff_config_key=CSR_TARIFF_PLAN_UNLIMITED_PAYG
    ...    bundle_config_key=CSR_BUNDLE_PLAN_QUARTERLY

TC_E2EU_MONTHLY E2E With Usage Monthly Plan
    [Documentation]    Full E2E with Monthly Bundle (CSR_BUNDLE_PLAN_MONTHLY,
    ...                e.g. SIMPLAN-QRA-070425_1) — 2 SIMs, Private Dynamic APN,
    ...                usage on 1 of 2 IMSIs, skips Step 18 + 19.
    [Tags]    e2e    e2e-with-usage    plan-duration    monthly    regression
    E2E Run Plan Duration Scenario
    ...    tariff_config_key=CSR_TARIFF_PLAN_UNLIMITED_PAYG
    ...    bundle_config_key=CSR_BUNDLE_PLAN_MONTHLY


*** Keywords ***
E2E Run Plan Duration Scenario
    [Documentation]    Runs the baseline E2E Flow With Usage end-to-end with Part 3 fixed
    ...                overrides applied and the scenario-specific Tariff + Bundle plan
    ...                resolved from config keys passed in by the caller.
    ...
    ...                ASSUMES the Part 6 Known Implementation Gaps have been closed:
    ...                  - E2E Create APN accepts ``apn_alloc`` argument (Gap 3)
    ...                  - E2E Create CSR Journey accepts ``tariff_plan`` and ``bundle_plan``
    ...                    arguments (Gap 1)
    ...                  - E2E Perform Usage For Selected IMSIs keyword exists (Gap 2)
    [Arguments]    ${tariff_config_key}    ${bundle_config_key}

    # ── Resolve plan names from config at runtime ─────────────────────
    ${tariff_plan}=    Get Variable Value    \${${tariff_config_key}}
    ${bundle_plan}=    Get Variable Value    \${${bundle_config_key}}
    Should Not Be Empty    ${tariff_plan}    msg=Config key '${tariff_config_key}' is empty or missing in config/${ENV}.json
    Should Not Be Empty    ${bundle_plan}    msg=Config key '${bundle_config_key}' is empty or missing in config/${ENV}.json
    Log    Plan-duration scenario: Tariff='${tariff_plan}' Bundle='${bundle_plan}'    console=yes

    # ─────────────────────────────────────────────────────────────────
    #  Phase 1 — Onboarding (Steps 1, 1b, 2, 3)
    # ─────────────────────────────────────────────────────────────────
    # Step 1 · Onboard EC + BU via SOAP API
    ${data}=    E2E Onboard EC BU Via API
    Set Suite Variable    ${E2E_EC_NAME}    ${data}[company_name]
    Set Suite Variable    ${E2E_BU_NAME}    ${data}[billing_account_name]
    Log    Step 1 complete: EC=${E2E_EC_NAME}, BU=${E2E_BU_NAME}    console=yes

    # Step 1b · Verify onboarded account on UI
    E2E Verify Account On UI    ${E2E_EC_NAME}    ${E2E_BU_NAME}

    # Step 2 · Create APN — Private Dynamic (Gap 3)
    E2E Create APN    ${E2E_EC_NAME}    ${E2E_BU_NAME}    apn_alloc=${PLAN_APN_ALLOC}

    # Step 3 · Create CSR Journey with scenario-specific Tariff + Bundle (Gap 1)
    E2E Create CSR Journey    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    ...    tariff_plan=${tariff_plan}    bundle_plan=${bundle_plan}

    # ─────────────────────────────────────────────────────────────────
    #  Phase 2 — SIM Setup (Steps 4, 5, 5b)
    # ─────────────────────────────────────────────────────────────────
    # Step 4 · Create SIM Range with 2 ICCID/IMSI/MSISDN (not the baseline 10)
    E2E Create SIM Range    quantity=${PLAN_SIM_QUANTITY}

    # Step 5 · Create and assign SIM Product Type
    E2E Create Product Type And Assign EC    ${E2E_EC_NAME}

    # Step 5b · Expand EC/BU limits by +2 (to match scenario quantity)
    E2E Expand EC And BU SIM Limits    ${E2E_EC_NAME}    ${E2E_BU_NAME}    ${PLAN_SIM_QUANTITY}

    # ─────────────────────────────────────────────────────────────────
    #  Phase 3 — SIM Order (Steps 6, 7, 8, 9, 10)
    # ─────────────────────────────────────────────────────────────────
    # Step 6 · SIM Order with quantity = 2
    E2E Create SIM Order    ${E2E_EC_NAME}    ${E2E_BU_NAME}    ${PLAN_SIM_QUANTITY}

    # Step 7 · Capture Order ID from Live Order grid
    ${order_id}=    E2E Capture Order ID From Grid    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_ORDER_ID}    ${order_id}

    # Step 8 · Fetch EC + BU IDs from DB
    ${ec_id}    ${bu_id}=    E2E Fetch EC And BU IDs From DB    ${E2E_EC_NAME}    ${E2E_BU_NAME}
    Set Suite Variable    ${E2E_EC_ID}    ${ec_id}
    Set Suite Variable    ${E2E_BU_ID}    ${bu_id}

    # Step 9 · Run create-order script on server (SSH)
    E2E Run Create Order Script On Server    ${E2E_ORDER_ID}

    # Step 10 · Validate order New → In Progress
    E2E Validate Order Status    ${E2E_ORDER_ID}    In Progress

    # ─────────────────────────────────────────────────────────────────
    #  Phase 4 — Response Processing (Steps 11, 12, 13, 14)
    # ─────────────────────────────────────────────────────────────────
    # Step 11 · Generate + upload response files
    E2E Generate And Upload Response Files    ${E2E_ORDER_ID}    ${E2E_EC_ID}    ${E2E_BU_ID}

    # Step 12 · Run read-order script on server (SSH)
    E2E Run Read Order Script On Server    ${E2E_ORDER_ID}

    # Step 13 · Validate order In Progress → Completed
    E2E Validate Order Status    ${E2E_ORDER_ID}    Completed

    # Step 14 · Validate 2 SIMs in Warm state
    E2E Validate SIMs In State    ${E2E_BU_NAME}    Warm    ${PLAN_SIM_QUANTITY}

    # ─────────────────────────────────────────────────────────────────
    #  Phase 5 — Activation + Usage (Steps 15, 16, 16a, 16b)
    # ─────────────────────────────────────────────────────────────────
    # Step 15 · Approve order via SOAP API (→ InActive)
    E2E Approve Order Via SOAP API    ${E2E_ORDER_ID}

    # Step 16 · Activate all 2 SIMs; capture IMSIs + MSISDNs
    @{imsis}    @{imsi_data}=    E2E Activate SIMs And Capture IMSIs
    ...    ${E2E_BU_NAME}    count=${PLAN_SIM_QUANTITY}
    Set Suite Variable    @{E2E_ACTIVATED_IMSIS}    @{imsis}
    Set Suite Variable    @{E2E_IMSI_DATA}    @{imsi_data}
    Length Should Be    ${E2E_ACTIVATED_IMSIS}    ${PLAN_SIM_QUANTITY}
    ...    msg=Expected ${PLAN_SIM_QUANTITY} activated IMSIs; got ${E2E_ACTIVATED_IMSIS}

    # Step 16a · Inject 5 MB usage on the 1st of 2 IMSIs only (Gap 2)
    # Leaves IMSI[2] with zero usage so Step 16b validates the contrast.
    E2E Perform Usage For Selected IMSIs
    ...    imsi_indexes=${PLAN_USAGE_IMSI_INDEX}
    ...    mb_per_imsi=${PLAN_USAGE_MB}

    # Step 16b · Validate UI data usage — expect 1 IMSI > 0, 1 IMSI == 0
    E2E Validate Usage In UI    ${E2E_BU_NAME}
    ...    expect_usage_imsi_indexes=${PLAN_USAGE_IMSI_INDEX}
    ...    min_mb_for_used=${PLAN_USAGE_MB}

    # ─────────────────────────────────────────────────────────────────
    #  Phase 6 — Invoice only (Steps 18 and 19 intentionally SKIPPED)
    # ─────────────────────────────────────────────────────────────────
    # Step 17 · Generate invoice + download CSV
    E2E Generate Invoice And Download CSV    ${E2E_BU_ID}

    # Step 18 · SKIPPED for plan-duration matrix (no second CSR Journey)
    # Step 19 · SKIPPED for plan-duration matrix (no Device Plan change)
    Log    Plan-duration scenario completed — Tariff='${tariff_plan}' Bundle='${bundle_plan}'    console=yes
