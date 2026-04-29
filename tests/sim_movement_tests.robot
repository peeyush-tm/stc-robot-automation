*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/sim_movement_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/sim_movement_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/sim_movement_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — ACCOUNT / EC VERIFICATION
# ═══════════════════════════════════════════════════════════════════════

TC_SMOV_002 Capture SIM Row Count And Ensure EC IMSI Capacity
    [Documentation]    1) Manage Devices: EC + source BU row count (SM_SIM_ROW_COUNT).
    ...                2) EC Max IMSI vs rows: no change if max > rows; else raise toward rows+1
    ...                   using + Add IMSI delta. Sets SM_EC_MAX_IMSI_CAP for TC_SMOV_003.
    [Tags]    regression    positive    sim-movement    TC_SMOV_002
    TC_SMOV_002

TC_SMOV_003 Ensure Target BU Max SIM Capacity
    [Documentation]    Manage Devices row count for target BU only; BU max vs rows with EC cap
    ...                (SM_EC_MAX_IMSI_CAP). No change if max > rows; else min(rows+1, EC cap) via + Add SIMs delta.
    [Tags]    regression    positive    sim-movement    TC_SMOV_003
    TC_SMOV_003

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — SIM MOVEMENT HAPPY PATH (includes ICCID/IMSI resolve + post-verify)
# ═══════════════════════════════════════════════════════════════════════

TC_SMOV_005 Perform State-Aware SIM Movement To Target BU
    [Documentation]    Resolves ICCID (seed or first Activated in source BU), captures IMSI,
    ...                opens SIM Movement, selects target BU, Device Plan if Activated,
    ...                Submit → Proceed, up to 30s success toast, header bell → GC Request Id → SM_BATCH_REQUEST_ID,
    ...                3 min async wait, search same IMSI, assert Business Unit Name column shows target BU.
    [Tags]    smoke    regression    positive    manage-devices    sim-movement    TC_SMOV_005
    TC_SMOV_005

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — BATCH JOB LOG (Request Id from TC_SMOV_005)
# ═══════════════════════════════════════════════════════════════════════

TC_SMOV_009 Verify SIM Movement In Batch Job Log By Request Id
    [Documentation]    Batch Job Log: filter by SM_BATCH_REQUEST_ID, expand row, assert OPERATION PERFORM = target BU,
    ...                RESULT SUCCESSFUL, Description contains SM_BJL_DETAIL_SUBSTRING (without DP change path).
    [Tags]    regression    positive    sim-movement    TC_SMOV_009
    TC_SMOV_009

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — VALIDATION
# ═══════════════════════════════════════════════════════════════════════

TC_SMOV_012 SIM Movement Without Selecting Any SIM Should Not Allow Action
    [Documentation]    Without selecting any SIM checkbox, attempt to choose
    ...                SIM Movement from the action dropdown and verify the
    ...                system prevents submission.
    [Tags]    regression    negative    sim-movement    TC_SMOV_012
    TC_SMOV_012

TC_SMOV_013 Close SIM Movement Modal Without Proceeding Should Not Move SIM
    [Documentation]    Open the SIM Movement modal for a valid SIM, then close
    ...                it without clicking Proceed. Verify the SIM remains in
    ...                its original BU account.
    [Tags]    regression    negative    sim-movement    TC_SMOV_013
    TC_SMOV_013

