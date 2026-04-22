*** Settings ***
Documentation    SIM Replacement — Blank SIM order, replacement action, batch jobs, validations (spec TC_017 + SIM Replacement Test Suite).
...    Same session pattern as other suites: Suite Setup login, ``Suite Teardown`` closes browsers.
Resource         ../resources/keywords/browser_keywords.resource
Resource         ../resources/keywords/login_keywords.resource
Resource         ../resources/keywords/sim_replacement_keywords.resource
Library          ../libraries/ConfigLoader.py
Variables        ../variables/login_variables.py
Variables        ../variables/sim_replacement_variables.py
Variables        ../variables/sim_movement_variables.py
Variables        ../variables/order_processing_variables.py

Suite Setup      Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Teardown    Handle Test Teardown


*** Test Cases ***
TC_SIMRPL_01 SIM Replacement Blank Order Creation And Preparation
    [Documentation]    Phase 1 of SIM replacement: creates Admin SIM ranges, bumps SIM limits, captures the device
    ...                identity (old ICCID/IMSI/MSISDN) from Manage Devices, submits the blank SIM order wizard,
    ...                runs the server-side order pipeline to Completed, and captures the new blank SIM ICCID/IMSI
    ...                from the Blank SIMs page.
    ...
    ...                Suite variables set for TC_SIMRPL_03 (same session) or override via env/seed for standalone:
    ...                  SIMR_MSISDN, SIMR_OLD_ICCID, SIMR_OLD_IMSI  → captured from Manage Devices
    ...                  SIMR_NEW_ICCID, SIMR_NEW_IMSI               → captured from Blank SIMs
    ...                  SIMR_SIM_ORDER_ID                            → Live Order row order number
    ...
    ...                Requires SSH/order-processing config; DB not required for this path.
    [Tags]    sim-replacement    regression    smoke
    SR Ensure EC Account For Sim Replacement Order
    SR Create Sim Ranges Iccid Imsi And Msisdn For Replacement Ec
    SR Ensure Sim Limits For Ec And Bu Before Replacement
    SR Capture Target Device Identity For Sim Replacement
    SR Submit Blank Sim Order Wizard Only
    ${order_id}=    SR Capture Sim Replacement Order Id From Live Order
    Set Suite Variable    ${SIMR_SIM_ORDER_ID}    ${order_id}
    SR Run Order Processing Pipeline New To Completed    ${order_id}
    SR Capture New Blank Sim Pool Iccid And Imsi For Ec
    Log    TC_SIMRPL_01 complete — MSISDN=${SIMR_MSISDN} OLD_ICCID=${SIMR_OLD_ICCID} NEW_ICCID=${SIMR_NEW_ICCID} ORDER=${SIMR_SIM_ORDER_ID}    console=yes

TC_SIMRPL_03 Perform SIM Replacement And Verify
    [Documentation]    Phase 2 of SIM replacement: performs the actual replacement action on the MSISDN, waits for
    ...                propagation, then verifies Notes, Blank SIM "In Use" state, and Lost SIM entry.
    ...
    ...                Designed to run after TC_SIMRPL_01 in the same suite session (picks up suite variables
    ...                automatically) OR as a standalone test by supplying the required identifiers via env vars
    ...                or ``.run_seed.json`` seed keys:
    ...
    ...                  Variable            Env var               Seed key
    ...                  ─────────────────   ─────────────────     ────────────────
    ...                  SIMR_MSISDN         STC_SIMR_MSISDN       simr_msisdn
    ...                  SIMR_OLD_ICCID      STC_SIMR_OLD_ICCID    simr_old_iccid
    ...
    ...                NOTE: SIMR_NEW_ICCID is captured at runtime from the Blank SIMs grid (Account Name column
    ...                filter) — no need to supply it externally.
    ...
    [Tags]    sim-replacement    regression    smoke
    Should Not Be Empty    ${SIMR_MSISDN}
    ...    msg=SIMR_MSISDN required — run TC_SIMRPL_01 first (same suite session) or set env STC_SIMR_MSISDN / seed simr_msisdn.
    Should Not Be Empty    ${SIMR_OLD_ICCID}
    ...    msg=SIMR_OLD_ICCID required — run TC_SIMRPL_01 first (same suite session) or set env STC_SIMR_OLD_ICCID / seed simr_old_iccid.
    Log    Starting replacement — MSISDN=${SIMR_MSISDN} old ICCID=${SIMR_OLD_ICCID}    console=yes
    SR Perform Sim Replacement For Msisdn    ${SIMR_MSISDN}
    SR Wait Sim Replacement Propagation Minutes    ${SIMR_PROPAGATION_WAIT_MINUTES}
    SR Verify Post Replacement Iccid And Imsi    ${SIMR_MSISDN}
    SR Expand First Row Open Notes And Assert Replacement    ${SIMR_MSISDN}
    SR Verify New Blank Sim In Use By Account Name Filter
    SR Navigate To Lost Sims Page
    SR Search Grid On Current Page    ${SIMR_OLD_ICCID}
    SR Verify Lost Sim Row For Old Iccid

TC_SIMRPL_04 Verify Notes After Replacement
    [Documentation]    Requires SIMR_MSISDN and completed replacement (e.g. after TC_SIMRPL_01).
    [Tags]    regression
    Should Not Be Empty    ${SIMR_MSISDN}
    SR Expand First Row Open Notes And Assert Replacement    ${SIMR_MSISDN}

TC_SIMRPL_05 Verify New SIM On Blank SIM Tab
    [Documentation]    Requires ${SIMR_NEW_ICCID} from TC_SIMRPL_01 (same suite session).
    [Tags]    regression
    Should Not Be Empty    ${SIMR_NEW_ICCID}    msg=Run TC_SIMRPL_01 first or set suite variable SIMR_NEW_ICCID.
    SR Navigate To Blank Sims Page
    SR Search Grid On Current Page    ${SIMR_NEW_ICCID}
    SR Verify Blank Sim Row In Use

TC_SIMRPL_06 Verify Old SIM On Lost SIM Module
    [Documentation]    Requires ${SIMR_OLD_ICCID} / ${SIMR_OLD_IMSI} from TC_SIMRPL_01.
    [Tags]    regression
    Should Not Be Empty    ${SIMR_OLD_ICCID}    msg=Run TC_SIMRPL_01 first.
    SR Navigate To Lost Sims Page
    SR Search Grid On Current Page    ${SIMR_OLD_ICCID}
    SR Verify Lost Sim Row For Old Iccid

TC_SIMRPL_07 Negative No IMSI Options Submit Disabled
    [Documentation]    If the IMSI dropdown has only the placeholder, Submit in savePopup should stay disabled.
    ...                Skipped when pool has selectable IMSIs (normal environments).
    [Tags]    sim-replacement    negative
    Pass Execution If    '${SIMR_MSISDN}' == '${EMPTY}'
    ...    No MSISDN: run TC_SIMRPL_01 first in this suite or set STC_SIMR_MSISDN / seed simr_msisdn.
    SR Navigate To Manage Devices Page
    SR Manage Devices Search By Type And Value    MSISDN    ${SIMR_MSISDN}
    SR Select First Row Checkbox
    SR Select Sim Replacement From Action Bar
    ${n}=    SeleniumLibrary.Get Element Count    xpath=//div[@id='savePopup']//select//option
    IF    ${n} > 1
        Run Keyword And Ignore Error    Click Element Via JS    ${LOC_SR_POPUP_CANCEL}
        Pass Execution    Pool has IMSI options; N-01 scenario not applicable.
    END
    SR Assert Save Popup Proceed Disabled When Only Placeholder Imsi
    Click Element Via JS    ${LOC_SR_POPUP_CANCEL}
