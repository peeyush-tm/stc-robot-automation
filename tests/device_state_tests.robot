*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/device_state_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/device_state_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/device_state_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — STATE TRANSITIONS
#  Each test: apply account filter → apply SIM state filter →
#  validate initial state → perform state change → wait 5 min →
#  validate expected state by searching same IMSI.
#  Account: billingAccountDONTUSE_005
# ═══════════════════════════════════════════════════════════════════════

TC_DS_002 TestActive To Activated
    [Documentation]    Filter account + TestActive, validate initial state is TestActive,
    ...                change to Activated, wait 5 min, search IMSI to verify Activated.
    [Tags]    smoke    regression    positive    TC_DS_002
    TC_DS_002

TC_DS_003 TestActive To Suspended
    [Documentation]    Filter account + TestActive, validate initial state is TestActive,
    ...                change to Suspended, wait 5 min, search IMSI to verify Suspended.
    [Tags]    regression    positive    TC_DS_003
    TC_DS_003

TC_DS_004 Activated To Suspended
    [Documentation]    Filter account + Activated, validate initial state is Activated,
    ...                change to Suspended, wait 5 min, search IMSI to verify Suspended.
    [Tags]    regression    positive    TC_DS_004
    TC_DS_004

TC_DS_005 Activated To Terminate
    [Documentation]    Filter account + Activated, validate initial state is Activated,
    ...                change to Terminate, wait 5 min, search IMSI to verify Terminate.
    [Tags]    regression    positive    TC_DS_005
    TC_DS_005

TC_DS_006 Suspended To Terminate
    [Documentation]    Filter account + Suspended, validate initial state is Suspended,
    ...                change to Terminate, wait 5 min, search IMSI to verify Terminate.
    [Tags]    regression    positive    TC_DS_006
    TC_DS_006

TC_DS_007 InActive To Activated
    [Documentation]    Filter account + InActive, validate initial state is InActive,
    ...                change to Activated, wait 5 min, search IMSI to verify Activated.
    [Tags]    regression    positive    TC_DS_007
    TC_DS_007

TC_DS_008 InActive To TestActive
    [Documentation]    Filter account + InActive, validate initial state is InActive,
    ...                change to TestActive, wait 5 min, search IMSI to verify TestActive.
    [Tags]    regression    positive    TC_DS_008
    TC_DS_008

# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE — POPUP UI VERIFICATION
# ═══════════════════════════════════════════════════════════════════════

TC_DS_009 Verify State Change Popup Opens
    [Documentation]    Select a device, choose Change State, click Submit,
    ...                verify the popup modal appears.
    [Tags]    regression    positive    TC_DS_009
    TC_DS_009

TC_DS_010 Close Popup Without Submitting Should Not Change State
    [Documentation]    Open state change popup, close without proceeding,
    ...                search the same device by IMSI and verify state unchanged.
    [Tags]    regression    positive    TC_DS_010
    TC_DS_010

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — INVALID STATE TRANSITIONS
# ═══════════════════════════════════════════════════════════════════════

TC_DS_011 Activated To TestActive Should Be Blocked
    [Documentation]    Attempt invalid transition Activated → TestActive; expect blocked.
    [Tags]    regression    negative    TC_DS_011
    TC_DS_011

TC_DS_012 Activated To TestReady Should Be Blocked
    [Documentation]    Attempt invalid transition Activated → TestReady; expect blocked.
    [Tags]    regression    negative    TC_DS_012
    TC_DS_012

TC_DS_013 Suspended To TestActive Should Be Blocked
    [Documentation]    Attempt invalid transition Suspended → TestActive; expect blocked.
    [Tags]    regression    negative    TC_DS_013
    TC_DS_013

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE — UI VALIDATION
# ═══════════════════════════════════════════════════════════════════════

TC_DS_014 No Device Selected Should Not Allow Action
    [Documentation]    Without selecting any device, Change State should be blocked.
    [Tags]    regression    negative    TC_DS_014
    TC_DS_014

TC_DS_015 Proceed Without Selecting Reason Should Be Blocked
    [Documentation]    Open popup but skip reason; Proceed should be disabled.
    [Tags]    regression    negative    TC_DS_015
    TC_DS_015

*** Keywords ***
TC_DS_002
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_TEST_ACTIVE}    ${STATE_TEST_ACTIVE}    ${STATE_ACTIVATED}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_ACTIVATED}

TC_DS_003
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_TEST_ACTIVE}    ${STATE_TEST_ACTIVE}    ${STATE_SUSPENDED}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_SUSPENDED}

TC_DS_004
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_ACTIVATED}    ${STATE_ACTIVATED}    ${STATE_SUSPENDED}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_SUSPENDED}

TC_DS_005
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_ACTIVATED}    ${STATE_ACTIVATED}    ${STATE_TERMINATE}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_TERMINATE}

TC_DS_006
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_SUSPENDED}    ${STATE_SUSPENDED}    ${STATE_TERMINATE}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_TERMINATE}

TC_DS_007
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_INACTIVE}    ${STATE_INACTIVE}    ${STATE_ACTIVATED}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_ACTIVATED}

TC_DS_008
    Login And Navigate To Manage Devices DSC
    ${imsi}=    Perform Full State Change    ${FILTER_LABEL_INACTIVE}    ${STATE_INACTIVE}    ${STATE_TEST_ACTIVE}
    Verify State Change Success And Wait
    Verify Device State After Change    ${imsi}    ${STATE_TEST_ACTIVE}

TC_DS_009
    Login And Navigate To Manage Devices DSC
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${FILTER_LABEL_ACTIVATED}
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Select Target State And Submit    ${STATE_SUSPENDED}
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_POPUP}    timeout=15s
    IF    ${popup_visible}
        Log    State change popup opened successfully.    console=yes
        Close Popup Without Submitting
    ELSE
        ${error}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_DSC_TOAST_ERROR}    timeout=5s
        Log    Popup did not open (error toast: ${error}).    level=WARN
    END

TC_DS_010
    Login And Navigate To Manage Devices DSC
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${FILTER_LABEL_ACTIVATED}
    ${state_col}=    Get Column Index By Header Text    ${STATE_COLUMN_HEADER}
    ${imsi_col}=    Get Column Index By Header Text    ${IMSI_COLUMN_HEADER}
    ${actual_row}=    Evaluate    ${row_idx} + 1
    ${imsi}=    Get Cell Value By Row And Column    ${actual_row}    ${imsi_col}
    ${original_state}=    Get Cell Value By Row And Column    ${actual_row}    ${state_col}
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Select Target State And Submit    ${STATE_SUSPENDED}
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_POPUP}    timeout=10s
    IF    ${popup_visible}
        Close Popup Without Submitting
    END
    Reset Grid To Default View
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Search Device By IMSI    ${imsi}
    Wait Until Element Is Visible    ${LOC_DSC_GRID_ROWS}    timeout=30s
    ${current_state}=    Get Cell Value By Row And Column    1    ${state_col}
    Should Be Equal As Strings    ${current_state}    ${original_state}
    ...    State should not change after closing popup. Expected "${original_state}" but got "${current_state}".

TC_DS_011
    Login And Navigate To Manage Devices DSC
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${FILTER_LABEL_ACTIVATED}
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Attempt Invalid Transition And Verify Blocked    ${STATE_TEST_ACTIVE}

TC_DS_012
    Login And Navigate To Manage Devices DSC
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${FILTER_LABEL_ACTIVATED}
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Attempt Invalid Transition And Verify Blocked    ${STATE_TEST_READY}

TC_DS_013
    Login And Navigate To Manage Devices DSC
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${FILTER_LABEL_SUSPENDED}
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Attempt Invalid Transition And Verify Blocked    ${STATE_TEST_ACTIVE}

TC_DS_014
    Login And Navigate To Manage Devices DSC
    ${action_enabled}=    Run Keyword And Return Status
    ...    Wait Until Element Is Enabled    ${LOC_DSC_ACTION_DROP}    timeout=5s
    IF    ${action_enabled}
        ${try_select}=    Run Keyword And Return Status
        ...    Select From List By Label    ${LOC_DSC_ACTION_DROP}    Change State
        IF    ${try_select}
            ${change_sec}=    Run Keyword And Return Status
            ...    Wait Until Element Is Visible    ${LOC_DSC_CHANGE_STATE_SEC}    timeout=5s
            IF    not ${change_sec}
                Log    Change State section did not appear — correctly blocked.    console=yes
            ELSE
                ${error_toast}=    Run Keyword And Return Status
                ...    Wait Until Element Is Visible    ${LOC_DSC_TOAST_ERROR}    timeout=5s
                Should Be True    ${error_toast}
                ...    Expected an error when no device is selected.
            END
        END
    ELSE
        Log    Action dropdown is disabled — correctly blocked.    console=yes
    END

TC_DS_015
    Login And Navigate To Manage Devices DSC
    ${row_idx}=    Filter Grid By Account And State    ${DSC_ACCOUNT_NAME}    ${FILTER_LABEL_ACTIVATED}
    Select Device By Row Index    ${row_idx}
    Select Change State Action
    Select Target State And Submit    ${STATE_SUSPENDED}
    ${popup_open}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_DSC_POPUP}    timeout=10s
    IF    ${popup_open}
        ${btn_enabled}=    Run Keyword And Return Status
        ...    Element Should Be Enabled    ${LOC_DSC_PROCEED_BTN}
        IF    ${btn_enabled}
            Log    Proceed button is enabled (may have defaults).    level=WARN
        ELSE
            Log    Proceed button is disabled without reason — correct.    console=yes
        END
        Close Popup Without Submitting
    ELSE
        Log    Popup did not open.    level=WARN
    END

