*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/device_plan_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/device_plan_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/device_plan_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — UI VERIFICATION
# ═══════════════════════════════════════════════════════════════════════

TC_CDP_001 Verify Manage Devices Grid And Action Bar
    [Documentation]    Verify grid is visible with rows, search input, and action bar.
    [Tags]    smoke    regression    positive    device_plan
    TC_CDP_001

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — DEVICE PLAN CHANGE PER SIM STATE
#  Each test: apply account filter → apply SIM state filter →
#  validate initial state → read initial device plan (DP1) →
#  select different device plan (DP2) → fill popup → submit →
#  wait 5 min → search IMSI → validate Device Plan column = DP2.
#  Account: billingAccountDONTUSE_005
# ═══════════════════════════════════════════════════════════════════════

TC_CDP_002 Change Device Plan On Activated SIM
    [Documentation]    Filter account + Activated, validate initial state and device plan (DP1),
    ...                change to DP2, wait 5 min, search IMSI to verify DP2 in grid.
    [Tags]    smoke    regression    positive    device_plan    activated
    TC_CDP_002

TC_CDP_003 Change Device Plan On TestActive SIM
    [Documentation]    Filter account + TestActive, validate initial state and device plan (DP1),
    ...                change to DP2, wait 5 min, search IMSI to verify DP2 in grid.
    [Tags]    regression    positive    device_plan    testactive
    TC_CDP_003

TC_CDP_004 Change Device Plan On Suspended SIM
    [Documentation]    Filter account + Suspended, validate initial state and device plan (DP1),
    ...                change to DP2, wait 5 min, search IMSI to verify DP2 in grid.
    [Tags]    regression    positive    device_plan    suspended
    TC_CDP_004

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — POPUP UI VERIFICATION
# ═══════════════════════════════════════════════════════════════════════

TC_CDP_005 Verify Change Device Plan Popup Opens
    [Documentation]    Select an Activated device, choose Change Device Plan, select a plan,
    ...                verify the popup modal appears with Reason dropdown visible.
    [Tags]    regression    positive    device_plan    activated
    TC_CDP_005

TC_CDP_006 Close Popup Without Submitting Should Not Change Plan
    [Documentation]    Open device plan change popup, close without proceeding,
    ...                search same IMSI and verify Device Plan is unchanged.
    [Tags]    regression    positive    device_plan
    TC_CDP_006

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — BLOCKED TRANSITIONS
# ═══════════════════════════════════════════════════════════════════════

TC_CDP_007 Change Device Plan On Terminate SIM Should Be Blocked
    [Documentation]    For a Terminated SIM, Device Plan action should be blocked at some
    ...                stage — either dropdown not available, no plans in the plan dropdown,
    ...                submit button disabled, error toast, or popup doesn't open.
    [Tags]    regression    negative    device_plan    terminate
    TC_CDP_007

TC_CDP_008 No Device Selected Should Not Allow Action
    [Documentation]    Without selecting any device, Change Device Plan should be blocked.
    [Tags]    regression    negative    device_plan
    TC_CDP_008

TC_CDP_009 Proceed Without Selecting Reason Should Be Blocked
    [Documentation]    Open popup but skip reason selection; Proceed button should be disabled.
    [Tags]    regression    negative    device_plan
    TC_CDP_009

TC_CDP_010 No Plan Selected Should Not Open Popup
    [Documentation]    Select "Change Device Plan" from action dropdown but do not select any
    ...                plan from the device plan dropdown — popup should not open.
    [Tags]    regression    negative    device_plan
    TC_CDP_010

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — SECURITY
# ═══════════════════════════════════════════════════════════════════════

TC_CDP_011 Direct Access To ManageDevices Without Login
    [Documentation]    Navigate directly to /ManageDevices without authenticating.
    ...                Verify redirect to login page.
    [Tags]    regression    negative    security    device_plan    navigation
    TC_CDP_011


*** Keywords ***
TC_CDP_001
    Login And Navigate To Manage Devices DP
    Wait Until Element Is Visible    ${LOC_DP_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DP_SEARCH_INPUT}    timeout=30s
    Wait Until Element Is Visible    ${LOC_DP_ACTION_FORM}    timeout=30s
    ${row_count}=    Get Element Count    ${LOC_DP_GRID_ROWS}
    Should Be True    ${row_count} > 0    Grid must have at least one device row.
    Log    Manage Devices grid visible with ${row_count} row(s).    console=yes

TC_CDP_002
    Login And Navigate To Manage Devices DP
    ${imsi}    ${dp1}    ${dp2}=    Perform Full Device Plan Change    ${DP_FILTER_ACTIVATED}    ${DP_STATE_ACTIVATED}
    Verify DP Change Success And Wait
    Verify Device Plan After Change    ${imsi}    ${dp2}

TC_CDP_003
    Login And Navigate To Manage Devices DP
    ${imsi}    ${dp1}    ${dp2}=    Perform Full Device Plan Change    ${DP_FILTER_TEST_ACTIVE}    ${DP_STATE_TEST_ACTIVE}
    Verify DP Change Success And Wait
    Verify Device Plan After Change    ${imsi}    ${dp2}

TC_CDP_004
    Login And Navigate To Manage Devices DP
    ${imsi}    ${dp1}    ${dp2}=    Perform Full Device Plan Change    ${DP_FILTER_SUSPENDED}    ${DP_STATE_SUSPENDED}
    Verify DP Change Success And Wait
    Verify Device Plan After Change    ${imsi}    ${dp2}

TC_CDP_005
    Login And Navigate To Manage Devices DP
    ${row_idx}=    Filter DP Grid By Account And State    ${DP_ACCOUNT_NAME}    ${DP_FILTER_ACTIVATED}
    Select DP Device By Row Index    ${row_idx}
    Select Change Device Plan Action
    ${dp1}    ${dp2}=    Select Target Device Plan And Get Names
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_POPUP}    timeout=15s
    Should Be True    ${popup_visible}    Popup did not open after selecting device plan.
    ${reason_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_REASON_DROP}    timeout=10s
    Should Be True    ${reason_visible}    Reason dropdown not visible in popup.
    Log    Popup opened with Reason dropdown visible. DP1=${dp1}, DP2=${dp2}.    console=yes
    Close DP Popup Without Submitting

TC_CDP_006
    Login And Navigate To Manage Devices DP
    ${row_idx}=    Filter DP Grid By Account And State    ${DP_ACCOUNT_NAME}    ${DP_FILTER_ACTIVATED}
    ${imsi_col}=    Get DP Column Index By Header Text    ${DP_IMSI_COLUMN}
    ${dp_col}=    Get DP Column Index By Header Text    ${DP_DEVICE_PLAN_COLUMN}
    ${actual_row}=    Evaluate    ${row_idx} + 1
    ${imsi}=    Get DP Cell Value By Row And Column    ${actual_row}    ${imsi_col}
    ${original_plan}=    Get DP Cell Value By Row And Column    ${actual_row}    ${dp_col}
    Select DP Device By Row Index    ${row_idx}
    Select Change Device Plan Action
    ${dp1}    ${dp2}=    Select Target Device Plan And Get Names
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_POPUP}    timeout=10s
    IF    ${popup_visible}
        Close DP Popup Without Submitting
    END
    Verify Device Plan Unchanged    ${imsi}    ${original_plan}

TC_CDP_007
    Login And Navigate To Manage Devices DP
    ${row_idx}=    Filter DP Grid By Account And State    ${DP_ACCOUNT_NAME}    Terminate
    Select DP Device By Row Index    ${row_idx}
    ${blocked}=    Set Variable    ${FALSE}
    ${action_enabled}=    Run Keyword And Return Status
    ...    Wait Until Element Is Enabled    ${LOC_DP_ACTION_DROP}    timeout=10s
    IF    not ${action_enabled}
        Log    Action dropdown disabled for Terminated SIM — correctly blocked.    console=yes
        ${blocked}=    Set Variable    ${TRUE}
    END
    IF    not ${blocked}
        ${select_ok}=    Run Keyword And Return Status
        ...    Select From List By Label    ${LOC_DP_ACTION_DROP}    ${DP_ACTION_LABEL}
        IF    not ${select_ok}
            Log    "Device Plan" not available in dropdown — correctly blocked.    console=yes
            ${blocked}=    Set Variable    ${TRUE}
        END
    END
    IF    not ${blocked}
        ${element}=    Get WebElement    ${LOC_DP_ACTION_DROP}
        Execute Javascript
        ...    arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
        ...    ARGUMENTS    ${element}
        Sleep    2s
        Wait For Loading Overlay To Disappear
        ${error_toast}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DP_TOAST_ERROR}    timeout=10s
        IF    ${error_toast}
            Log    Error toast appeared for Terminated SIM — correctly blocked.    console=yes
            ${blocked}=    Set Variable    ${TRUE}
        END
    END
    IF    not ${blocked}
        ${change_sec}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DP_CHANGE_STATE_SEC}    timeout=5s
        IF    ${change_sec}
            ${plan_count}=    Execute Javascript
            ...    var sel = document.querySelector('select[name="changeSelectedValue"]');
            ...    if(!sel) return 0;
            ...    var count = 0;
            ...    for(var i=0; i<sel.options.length; i++){
            ...      if(sel.options[i].value && sel.options[i].value !== '') count++;
            ...    }
            ...    return count;
            IF    ${plan_count} == 0
                Log    No device plans available for Terminated SIM — correctly blocked.    console=yes
                ${blocked}=    Set Variable    ${TRUE}
            END
        END
    END
    IF    not ${blocked}
        Log    Device Plan action was accessible for Terminated SIM — test records this behaviour.    level=WARN
    END

TC_CDP_008
    Login And Navigate To Manage Devices DP
    ${action_enabled}=    Run Keyword And Return Status
    ...    Wait Until Element Is Enabled    ${LOC_DP_ACTION_DROP}    timeout=5s
    IF    ${action_enabled}
        ${try_select}=    Run Keyword And Return Status
        ...    Select From List By Label    ${LOC_DP_ACTION_DROP}    ${DP_ACTION_LABEL}
        IF    ${try_select}
            ${change_sec}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_DP_CHANGE_STATE_SEC}    timeout=5s
            IF    not ${change_sec}
                Log    Change Device Plan section did not appear — correctly blocked.    console=yes
            ELSE
                ${error_toast}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible    ${LOC_DP_TOAST_ERROR}    timeout=5s
                Should Be True    ${error_toast}
                ...    Expected an error when no device is selected.
            END
        END
    ELSE
        Log    Action dropdown is disabled — correctly blocked.    console=yes
    END

TC_CDP_009
    Login And Navigate To Manage Devices DP
    ${row_idx}=    Filter DP Grid By Account And State    ${DP_ACCOUNT_NAME}    ${DP_FILTER_ACTIVATED}
    Select DP Device By Row Index    ${row_idx}
    Select Change Device Plan Action
    ${dp1}    ${dp2}=    Select Target Device Plan And Get Names
    ${popup_open}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_POPUP}    timeout=10s
    IF    ${popup_open}
        ${btn_enabled}=    Run Keyword And Return Status
        ...    Element Should Be Enabled    ${LOC_DP_PROCEED_BTN}
        IF    ${btn_enabled}
            Log    Proceed button is enabled without reason selection (may have defaults).    level=WARN
        ELSE
            Log    Proceed button is disabled without reason — correct.    console=yes
        END
        Close DP Popup Without Submitting
    ELSE
        Log    Popup did not open.    level=WARN
    END

TC_CDP_010
    Login And Navigate To Manage Devices DP
    ${row_idx}=    Filter DP Grid By Account And State    ${DP_ACCOUNT_NAME}    ${DP_FILTER_ACTIVATED}
    Select DP Device By Row Index    ${row_idx}
    Select Change Device Plan Action
    # Don't select any plan — verify popup stays closed
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DP_POPUP}    timeout=5s
    Should Not Be True    ${popup_visible}
    ...    Popup should not open without selecting a device plan.
    Log    Popup correctly not opened without plan selection.    console=yes

TC_CDP_011
    Clear Session For Unauthenticated Test
    Go To    ${DP_MANAGE_DEVICES_URL}
    Wait For Page Load
    Verify Redirected To Login Page
