*** Settings ***
Library     SeleniumLibrary
Library     String
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/apn_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/device_apn_view_keywords.resource
Resource    ../resources/keywords/manage_devices_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/apn_locators.resource

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}
...               AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
...               AND    Open Target Device Detail Page    ${DEVICE_ICCID}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Variables ***
${DEVICE_ICCID}      8992431100167856978
${DEVICE_IMSI}       420023067856978
${DEVICE_MSISDN}     96650100382
${DEVICE_BU}         IPV6_BU_MJ35_BU2
${DEVICE_STATE}      Activated
${PRIVATE_APN}       IPV6_APN_PvtSta
${EXPECTED_IPV6}     abcd:1200:1200:1201:0:0:0:1


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  GROUP A: APN TAB ACCESS & HEADER (Rows 54-56)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_001 Verify APN Tab Is Accessible From Device Detail Page And Loads Without Error
    [Documentation]    PRE: User logged in; device detail open; device Activated.
    ...                STEPS: Open device from Manage Devices; observe tabs:
    ...                General Data, Network And Session Details, Troubleshoot, Plan Details, Usage,
    ...                Subscriber Details, Notes, APN, Overage Amount, History Tab, Triggers; click APN.
    ...                EXPECTED: APN tab visible/clickable; loads APN configuration;
    ...                active (underlined); APN Type dropdown, APN list, IP panel displayed; no error.
    [Tags]    feature    regression    device-apn    TC_DAPN_001
    Verify Device Tabs Are Visible
    ...    General Data    Network And Session Details    Troubleshoot    Plan Details    Usage
    ...    Subscriber Details    Notes    APN    Overage Amount    History Tab    Triggers
    Click APN Tab
    Verify APN Tab Is Active And Underlined
    Verify APN Type Dropdown Is Displayed
    Verify APN Name List Is Displayed
    Verify IP Panel Is Displayed
    Verify No Error Or Blank Page

TC_DAPN_002 Verify All Device Header Fields Are Correctly Displayed When APN Tab Is Active
    [Documentation]    PRE: Device detail open; APN tab active.
    ...                STEPS: Open device ICCID=8992431100167856978; click APN; observe header.
    ...                EXPECTED: ICCID=8992431100167856978, IMSI=420023067856978, MSISDN=96650100382,
    ...                BU=IPV6_BU_MJ35_BU2, SIM STATE=Activated (green); all consistent.
    [Tags]    feature    regression    device-apn    TC_DAPN_002
    Click APN Tab
    Verify Device Header Field    ICCID        ${DEVICE_ICCID}
    Verify Device Header Field    IMSI         ${DEVICE_IMSI}
    Verify Device Header Field    MSISDN       ${DEVICE_MSISDN}
    Verify Device Header Field    BUSINESS UNIT NAME    ${DEVICE_BU}
    Verify Device Header Field    SIM STATE    ${DEVICE_STATE}
    Verify SIM State Colour On Header Is    green

TC_DAPN_003 Verify Navigating Away From APN Tab And Returning Retains APN Tab State
    [Documentation]    PRE: APN tab active.
    ...                STEPS: Click APN; set APN Type=Private; click General Data; return to APN.
    ...                EXPECTED: On return, APN Type (Private) and list state retained or reset per business rules;
    ...                no crash or blank screen.
    [Tags]    feature    regression    device-apn    TC_DAPN_003
    Click APN Tab
    Select APN Type    Private
    Click Tab    General Data
    Click APN Tab
    Verify APN Tab State Retained Or Reset Per Business Rules
    Verify No Crash Or Blank Screen

# ═══════════════════════════════════════════════════════════════════════
#  GROUP B: APN TYPE DROPDOWN (Rows 57-60)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_004 Verify APN Type Dropdown Contains All Expected Options And Defaults Correctly
    [Documentation]    PRE: APN tab loaded.
    ...                STEPS: Click APN Type dropdown; observe options.
    ...                EXPECTED: Options Private/Public/Any; default 'Private'; interactive; selectable.
    [Tags]    feature    regression    device-apn    TC_DAPN_004
    Click APN Tab
    Open APN Type Dropdown
    Verify APN Type Options Include    Private    Public    Any
    Verify Default APN Type Is    Private

TC_DAPN_005 Verify Selecting Private APN Type Loads Only Private APNs
    [Documentation]    PRE: APN tab open.
    ...                STEPS: Click dropdown; select Private; observe list.
    ...                EXPECTED: List shows only Private APNs; IPV6_APN_PvtSta shown;
    ...                no Public APNs; IP panel updates (IPV6 tab shows abcd:1200:1200:1201:0:0:0:1).
    [Tags]    feature    regression    device-apn    TC_DAPN_005
    Click APN Tab
    Select APN Type    Private
    Verify APN Name List Contains Only Private APNs
    Verify APN Name List Contains    ${PRIVATE_APN}
    Verify No Public APNs In List
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV6
    Verify IP Address Displayed    ${EXPECTED_IPV6}

TC_DAPN_006 Verify Selecting Public APN Type Loads Only Public APNs
    [Documentation]    PRE: APN tab open.
    ...                STEPS: Select Public; observe list and IP panel.
    ...                EXPECTED: List shows only Public APNs; no Private APNs;
    ...                IP panel reflects Public APN IPs; Assigned/Unassigned/All filters functional.
    [Tags]    feature    regression    device-apn    TC_DAPN_006
    Click APN Tab
    Select APN Type    Public
    Verify APN Name List Contains Only Public APNs
    Verify No Private APNs In List
    Verify Filter Tabs Remain Functional    Assigned    Unassigned    All

TC_DAPN_007 Verify Selecting Any APN Type Shows APNs Of All Types
    [Documentation]    PRE: APN Type=Any available.
    ...                STEPS: Select Any; observe list.
    ...                EXPECTED: List shows Private+Public; total count increases; no filtering restriction.
    [Tags]    feature    regression    device-apn    TC_DAPN_007
    Click APN Tab
    Select APN Type    Any
    Verify APN Name List Contains Both Private And Public APNs
    Verify Total APN Count Increased Compared To Filtered Views

# ═══════════════════════════════════════════════════════════════════════
#  GROUP C: REFRESH BUTTON (Rows 61-62)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_008 Verify Refresh Button Reloads APN List Without Changing APN Type
    [Documentation]    PRE: APN Type selected.
    ...                STEPS: Select Private; note list; click Refresh; observe list.
    ...                EXPECTED: List reloads from backend; APN Type (Private) retained;
    ...                new/removed APNs reflected; loading indicator shown; no error/blank list.
    [Tags]    feature    regression    device-apn    TC_DAPN_008
    Click APN Tab
    Select APN Type    Private
    Note APN Name List Content
    Click Refresh Button
    Verify APN Name List Reloaded
    Verify APN Type Selection Retained    Private
    Verify Newly Added Or Removed APNs Are Reflected
    Verify Loading Indicator Was Shown During Refresh
    Verify No Error Or Blank List After Refresh

TC_DAPN_009 Verify Refresh Button Shows Loading State And Completes Within Acceptable Time
    [Documentation]    PRE: APN tab open.
    ...                STEPS: Click Refresh; observe behavior.
    ...                EXPECTED: Spinner/disabled state during reload; APN list refreshes ≤3s; no timeout/error.
    [Tags]    feature    regression    device-apn    TC_DAPN_009
    Click APN Tab
    Click Refresh Button
    Verify Refresh Button Shows Loading State
    Verify APN List Refreshes Within    3
    Verify No Timeout Or Error

# ═══════════════════════════════════════════════════════════════════════
#  GROUP D: ASSIGNED / UNASSIGNED / ALL SUB-TABS (Rows 63-68)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_010 Verify All Filter Tab Is Active By Default And Shows All APNs
    [Documentation]    PRE: APN tab open; APN Type selected (e.g., Private).
    ...                STEPS: Observe default active sub-tab among Assigned/Unassigned/All.
    ...                EXPECTED: 'All' tab active by default (underlined); list shows all APNs regardless of assignment;
    ...                IPV6_APN_PvtSta visible under 'All'.
    [Tags]    feature    regression    device-apn    TC_DAPN_010
    Click APN Tab
    Select APN Type    Private
    Verify Default Active Sub Tab Is    All
    Verify APN Name List Contains    ${PRIVATE_APN}

TC_DAPN_011 Verify Assigned Filter Tab Shows Only Device-Assigned APNs
    [Documentation]    PRE: Device has at least one assigned APN.
    ...                STEPS: Click 'Assigned' sub-tab; observe list.
    ...                EXPECTED: Assigned tab active (underlined); list shows only assigned APNs;
    ...                unassigned excluded; empty-state if none; IP panel updates.
    [Tags]    feature    regression    device-apn    TC_DAPN_011
    Click APN Tab
    Click Sub Tab    Assigned
    Verify Sub Tab Is Active    Assigned
    Verify APN Name List Shows Only Assigned APNs
    Verify Unassigned APNs Are Not Shown
    ${assigned_count}=    Get APN Count In List
    Run Keyword If    ${assigned_count} == 0    Verify Empty State Message Is Displayed

TC_DAPN_012 Verify Unassigned Filter Tab Shows Only APNs Not Yet Assigned
    [Documentation]    PRE: Device has at least one unassigned APN available.
    ...                STEPS: Click 'Unassigned' sub-tab; observe list.
    ...                EXPECTED: Unassigned tab active; list shows only unassigned APNs;
    ...                assigned excluded; empty-state if all assigned.
    [Tags]    feature    regression    device-apn    TC_DAPN_012
    Click APN Tab
    Click Sub Tab    Unassigned
    Verify Sub Tab Is Active    Unassigned
    Verify APN Name List Shows Only Unassigned APNs
    Verify Assigned APNs Are Excluded

TC_DAPN_013 Verify Switching Between Assigned Unassigned And All Tabs Updates List
    [Documentation]    PRE: Assigned tab selected.
    ...                STEPS: Click Assigned → note count; Unassigned → note count; All → note count.
    ...                EXPECTED: Each switch updates immediately; active tab highlighted;
    ...                All count = Assigned + Unassigned; no residual data.
    [Tags]    feature    regression    device-apn    TC_DAPN_013
    Click APN Tab
    Click Sub Tab    Assigned
    ${assigned}=    Get APN Count In List
    Click Sub Tab    Unassigned
    ${unassigned}=    Get APN Count In List
    Click Sub Tab    All
    ${all}=    Get APN Count In List
    ${sum}=    Evaluate    ${assigned} + ${unassigned}
    Should Be Equal As Integers    ${all}    ${sum}
    Verify No Residual Data Between Tab Switches

TC_DAPN_014 Verify Empty State Is Handled When No APNs Match The Filter
    [Documentation]    PRE: No APNs exist for selected APN Type.
    ...                STEPS: Select APN Type with no APNs; click 'All'; observe.
    ...                EXPECTED: 'No APNs available' message; no error/crash; Refresh still functional.
    [Tags]    feature    regression    device-apn    TC_DAPN_014    negative
    Click APN Tab
    Select APN Type With No Available APNs
    Click Sub Tab    All
    Verify Empty State Message Is Displayed    No APNs available
    Verify No Error Or Crash
    Verify Refresh Button Remains Functional

TC_DAPN_015 Verify APN Name List Is Scrollable With Many APNs
    [Documentation]    PRE: Many APNs returned by filter.
    ...                STEPS: Select APN Type returning many APNs (e.g., Public or Any); scroll list.
    ...                EXPECTED: List scrollable; scrolling reveals more; no layout overflow.
    [Tags]    feature    regression    device-apn    TC_DAPN_015
    Click APN Tab
    Select APN Type    Public
    Verify APN Name List Is Scrollable
    Scroll APN Name List Down
    Verify Additional APNs Are Revealed
    Verify No Layout Overflow Into Other Sections

# ═══════════════════════════════════════════════════════════════════════
#  GROUP E: APN SELECTION & IP PANEL (Rows 69-71)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_016 Verify Clicking APN Name Selects It And Updates IP Panel
    [Documentation]    PRE: APN tab open; APN Type=Private; at least one APN visible.
    ...                STEPS: Click IPV6_APN_PvtSta; observe right-side IP panel.
    ...                EXPECTED: Row highlighted; IP panel updates to show IPs for selected APN;
    ...                IPV4 and IPV6 tabs become relevant; no reload.
    [Tags]    feature    regression    device-apn    TC_DAPN_016
    Click APN Tab
    Select APN Type    Private
    Click APN In List    ${PRIVATE_APN}
    Verify APN Row Is Highlighted    ${PRIVATE_APN}
    Verify IP Panel Updates For Selected APN    ${PRIVATE_APN}
    Verify IPV4 And IPV6 Tabs Are Relevant
    Verify No Page Reload Occurred

TC_DAPN_017 Verify Selecting Different APNs Updates IP Panel Independently
    [Documentation]    PRE: Multiple APNs visible.
    ...                STEPS: Click APN 1; note IP. Click APN 2; note IP. Compare.
    ...                EXPECTED: Panel updates independently for each APN; IPs match APN config;
    ...                no stale data from previous APN.
    [Tags]    feature    regression    device-apn    TC_DAPN_017
    Click APN Tab
    Click APN By Index    1
    ${ip1}=    Get IP Panel Content
    Click APN By Index    2
    ${ip2}=    Get IP Panel Content
    Should Not Be Equal    ${ip1}    ${ip2}
    Verify IP Addresses Match Selected APN Configuration
    Verify No Stale Data From Previous APN

TC_DAPN_018 Verify APN Name Column Header Is Displayed And List Is Properly Formatted
    [Documentation]    PRE: APN Name list visible.
    ...                STEPS: Observe header and row formatting.
    ...                EXPECTED: 'APN Name' header displayed; clear row formatting;
    ...                alternate styling/separation; selected row (IPV6_APN_PvtSta) highlighted.
    [Tags]    feature    regression    device-apn    TC_DAPN_018
    Click APN Tab
    Verify APN Name Column Header Is Displayed
    Verify APN Rows Are Properly Formatted
    Click APN In List    ${PRIVATE_APN}
    Verify Selected Row Is Visually Highlighted    ${PRIVATE_APN}

# ═══════════════════════════════════════════════════════════════════════
#  GROUP F: IPV4 / IPV6 TABS (Rows 72-79)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_019 Verify IPV4 And IPV6 Tabs Are Both Present In IP Address Panel
    [Documentation]    PRE: An APN is selected.
    ...                STEPS: Select an APN; observe right IP panel.
    ...                EXPECTED: IP panel on right; two tabs 'IPV4' and 'IPV6'; both clickable;
    ...                active underlined (IPV6 active per screenshot).
    [Tags]    feature    regression    device-apn    TC_DAPN_019
    Click APN Tab
    Click APN In List    ${PRIVATE_APN}
    Verify IP Panel Contains Tabs    IPV4    IPV6
    Verify IP Panel Tab Is Clickable    IPV4
    Verify IP Panel Tab Is Clickable    IPV6
    Verify IP Panel Active Tab Is Underlined    IPV6

TC_DAPN_020 Verify IPV6 Tab Displays Correct IPV6 Address For Selected APN
    [Documentation]    PRE: APN selected; IP panel showing; IPV6 configured.
    ...                STEPS: Click IPV6 tab; observe address.
    ...                EXPECTED: IPV6 tab active (underlined); shows abcd:1200:1200:1201:0:0:0:1;
    ...                radio button ● selected next to it (assigned); valid IPv6 format.
    [Tags]    feature    regression    device-apn    TC_DAPN_020
    Click APN Tab
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV6
    Verify IP Panel Active Tab Is    IPV6
    Verify IP Address Displayed    ${EXPECTED_IPV6}
    Verify Radio Button Is Selected Next To    ${EXPECTED_IPV6}
    Verify IP Address Format Is Valid IPv6    ${EXPECTED_IPV6}

TC_DAPN_021 Verify IPV4 Tab Displays Correct IPV4 Address For Selected APN
    [Documentation]    PRE: APN selected; IP panel showing; IPV4 configured.
    ...                STEPS: Click IPV4 tab; observe.
    ...                EXPECTED: IPV4 tab active; correct IPv4 address shown;
    ...                radio indicates assigned; valid IPv4 format (xxx.xxx.xxx.xxx).
    [Tags]    feature    regression    device-apn    TC_DAPN_021
    Click APN Tab
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV4
    Verify IP Panel Active Tab Is    IPV4
    ${ipv4}=    Get Displayed IPv4 Address
    Verify Radio Button Is Selected Next To    ${ipv4}
    Verify IP Address Format Is Valid IPv4    ${ipv4}

TC_DAPN_022 Verify Switching Between IPV4 And IPV6 Tabs Updates IP Display
    [Documentation]    PRE: IPV6 tab active.
    ...                STEPS: Click IPV6 → note; click IPV4 → note; click IPV6 again.
    ...                EXPECTED: Each switch updates IP display; IPV6=hex colons, IPV4=dot decimals;
    ...                underline moves; radio matches assigned IP per protocol.
    [Tags]    feature    regression    device-apn    TC_DAPN_022
    Click APN Tab
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV6
    ${v6}=    Get Displayed IP Address
    Click IP Panel Tab    IPV4
    ${v4}=    Get Displayed IP Address
    Click IP Panel Tab    IPV6
    Verify IP Address Format Is Valid IPv6    ${v6}
    Verify IP Address Format Is Valid IPv4    ${v4}
    Verify Active Tab Underline Follows Selection

TC_DAPN_023 Verify Radio Button Indicates Currently Assigned Active IP
    [Documentation]    PRE: APN with both IPV4 and IPV6 configured.
    ...                STEPS: Select IPV6_APN_PvtSta; IPV6 tab; observe radio next to abcd:1200:1200:1201:0:0:0:1.
    ...                EXPECTED: Radio filled ● next to assigned IP; unassigned IPs have empty radios;
    ...                state matches device's current assignment.
    [Tags]    feature    regression    device-apn    TC_DAPN_023
    Click APN Tab
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV6
    Verify Radio Button Is Filled Next To    ${EXPECTED_IPV6}
    Verify Unassigned IPs Have Empty Radio Buttons
    Verify Radio Button State Matches Device Current Assignment

TC_DAPN_024 Verify IPV4 Tab Shows Empty State When No IPV4 Address Is Assigned
    [Documentation]    PRE: APN configured for IPV6 only.
    ...                STEPS: Select such APN; click IPV4 tab.
    ...                EXPECTED: 'No IPV4 address assigned' or similar; no crash/null pointer;
    ...                IPV6 tab continues to show correct address.
    [Tags]    feature    regression    device-apn    TC_DAPN_024    negative
    Click APN Tab
    Select APN Configured For IPV6 Only
    Click IP Panel Tab    IPV4
    Verify Empty State Message Is Displayed    No IPV4 address assigned
    Verify No Crash Or Null Pointer Error
    Click IP Panel Tab    IPV6
    Verify IPV6 Tab Continues To Show Correct Address

TC_DAPN_025 Verify IPV6 Tab Shows Empty State When No IPV6 Address Is Assigned
    [Documentation]    PRE: APN configured for IPV4 only.
    ...                STEPS: Select such APN; click IPV6 tab.
    ...                EXPECTED: 'No IPV6 address assigned' message; no crash; IPV4 continues to function.
    [Tags]    feature    regression    device-apn    TC_DAPN_025    negative
    Click APN Tab
    Select APN Configured For IPV4 Only
    Click IP Panel Tab    IPV6
    Verify Empty State Message Is Displayed    No IPV6 address assigned
    Verify No Crash Occurred
    Click IP Panel Tab    IPV4
    Verify IPV4 Tab Continues To Function

TC_DAPN_026 Verify Multiple IP Addresses Are Displayed When An APN Has Multiple IPs
    [Documentation]    PRE: APN with multiple IPs assigned.
    ...                STEPS: Select such APN; click IPV6 tab; observe IP list.
    ...                EXPECTED: All assigned IPs listed; each has own radio; active IP has filled radio;
    ...                user can see all IPs without truncation.
    [Tags]    feature    regression    device-apn    TC_DAPN_026
    Click APN Tab
    Select APN With Multiple IP Allocations
    Click IP Panel Tab    IPV6
    Verify All Assigned IPs Are Listed
    Verify Each IP Has A Radio Button
    Verify Active IP Radio Is Filled
    Verify All IPs Visible Without Truncation

# ═══════════════════════════════════════════════════════════════════════
#  GROUP G: ERROR HANDLING / EDGE CASES (Rows 80-84)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_027 Verify Error Handling When APN List Fails To Load
    [Documentation]    PRE: Backend API temporarily unavailable.
    ...                STEPS: Open APN tab; simulate API failure; click Refresh.
    ...                EXPECTED: Error 'Failed to load APN data. Please try again.'; list shows empty state;
    ...                Refresh remains clickable; no unhandled JS errors.
    [Tags]    feature    regression    device-apn    TC_DAPN_027    negative
    Click APN Tab
    Simulate APN API Failure
    Click Refresh Button
    Verify Error Message Contains    Failed to load APN data
    Verify APN Name List Shows Empty State
    Verify Refresh Button Remains Clickable
    Verify No Unhandled JS Errors In Console

TC_DAPN_028 Verify APN Tab Shows Empty State When No APNs Configured For Device
    [Documentation]    PRE: Device has no APNs at all.
    ...                STEPS: Open device with no APN; click APN tab; observe.
    ...                EXPECTED: 'No APNs available' in list; IP panel empty or hidden;
    ...                Refresh and APN Type controls functional; no error.
    [Tags]    feature    regression    device-apn    TC_DAPN_028    negative
    Open Device With No APNs Configured
    Click APN Tab
    Verify Empty State Message Is Displayed    No APNs available
    Verify IP Panel Is Empty Or Hidden
    Verify Refresh And APN Type Controls Remain Functional
    Verify No Error Thrown

TC_DAPN_029 Verify Long APN Names Are Displayed Without Breaking Layout
    [Documentation]    PRE: APN list visible.
    ...                STEPS: Find APN with name >40 chars; observe display.
    ...                EXPECTED: Shown fully with horizontal scroll, OR truncated with tooltip on hover;
    ...                no overflow into IP panel or other sections.
    [Tags]    feature    regression    device-apn    TC_DAPN_029
    Click APN Tab
    Locate APN With Long Name
    Verify Long APN Name Fits With Scroll Or Tooltip
    Verify No Layout Overflow Into IP Panel Or Other Sections

TC_DAPN_030 Verify Long IPv6 Address Is Fully Displayed Without Truncation
    [Documentation]    PRE: Long IPv6 address displayed (e.g., abcd:1200:1200:1201:0:0:0:1).
    ...                STEPS: Select APN with IPv6; click IPV6; observe.
    ...                EXPECTED: Full address displayed; panel width accommodates; no overflow outside boundary.
    [Tags]    feature    regression    device-apn    TC_DAPN_030
    Click APN Tab
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV6
    Verify Full IPv6 Address Displayed Without Truncation    ${EXPECTED_IPV6}
    Verify IP Panel Width Accommodates Full Address
    Verify No Overflow Outside Panel Boundary

TC_DAPN_031 Verify Unauthorized User Cannot Modify APN Configuration
    [Documentation]    PRE: User without APN write permissions.
    ...                STEPS: Login as such user; open device APN tab; attempt interaction.
    ...                EXPECTED: Read-only view; APN Type disabled/read-only; Refresh may remain;
    ...                no edit/reassign actions; message shown if write attempted.
    [Tags]    feature    regression    device-apn    TC_DAPN_031    negative
    Login As User Without APN Write Permission
    Open Target Device Detail Page    ${DEVICE_ICCID}
    Click APN Tab
    Verify APN Type Dropdown Is Disabled Or Read Only
    Verify Refresh Button May Be Available
    Verify No Edit Or Reassign Actions Available
    Run Keyword And Expect Error    *permission*    Attempt APN Write Action

# ═══════════════════════════════════════════════════════════════════════
#  GROUP H: END-TO-END AND REFRESH-RETAIN (Rows 85-88)
# ═══════════════════════════════════════════════════════════════════════

TC_DAPN_032 Verify E2E Open Device APN Tab Private APN Select And View IPV6
    [Documentation]    PRE: User logged in; device ICCID=8992431100167856978 Activated with Private APN IPV6.
    ...                STEPS: 1) Login & go to Manage Devices  2) Search ICCID  3) Open detail  4) Click APN  5) Verify APN Type=Private
    ...                        6) Click 'All' sub-tab  7) Click IPV6_APN_PvtSta  8) Click IPV6 tab  9) Verify IP address.
    ...                EXPECTED: Header correct (ICCID/IMSI/MSISDN/BU/State); APN tab loads;
    ...                APN Type=Private; 'All' active; IPV6_APN_PvtSta selectable;
    ...                IPV6 tab shows abcd:1200:1200:1201:0:0:0:1 with filled radio; flow completes without error.
    [Tags]    feature    regression    device-apn    TC_DAPN_032    smoke
    Navigate To Manage Devices Page
    Set Search Filter Dropdown To    ICCID
    Enter Search Term    ${DEVICE_ICCID}
    Click Search Icon
    Open Device Detail From Row With ICCID    ${DEVICE_ICCID}
    Verify Device Header Field    ICCID        ${DEVICE_ICCID}
    Verify Device Header Field    IMSI         ${DEVICE_IMSI}
    Verify Device Header Field    MSISDN       ${DEVICE_MSISDN}
    Verify Device Header Field    BUSINESS UNIT NAME    ${DEVICE_BU}
    Verify Device Header Field    SIM STATE    ${DEVICE_STATE}
    Click APN Tab
    Verify Default APN Type Is    Private
    Click Sub Tab    All
    Verify Sub Tab Is Active    All
    Click APN In List    ${PRIVATE_APN}
    Click IP Panel Tab    IPV6
    Verify IP Address Displayed    ${EXPECTED_IPV6}
    Verify Radio Button Is Filled Next To    ${EXPECTED_IPV6}
    Verify Entire Flow Completed Without Error

TC_DAPN_033 Verify Switching APN Type From Private To Public Updates List And IP Panel
    [Documentation]    PRE: Device has both Private and Public APNs with IPV4 and IPV6.
    ...                STEPS: Open APN tab; APN Type=Private → note list; change to Public; select Public APN;
    ...                click IPV4 → note IP; click IPV6 → note IP.
    ...                EXPECTED: Public switch clears Private list and shows only Public APNs;
    ...                IP panel updates; IPV4 shows correct IPv4; IPV6 shows correct IPv6; no data bleeding.
    [Tags]    feature    regression    device-apn    TC_DAPN_033
    Click APN Tab
    Select APN Type    Private
    Note APN Name List Content
    Select APN Type    Public
    Verify APN Name List Contains Only Public APNs
    ${public_apn}=    Get First APN In List
    Click APN In List    ${public_apn}
    Click IP Panel Tab    IPV4
    ${pub_v4}=    Get Displayed IP Address
    Verify IP Address Format Is Valid IPv4    ${pub_v4}
    Click IP Panel Tab    IPV6
    ${pub_v6}=    Get Displayed IP Address
    Verify IP Address Format Is Valid IPv6    ${pub_v6}
    Verify No Data Bleeding Between Private And Public Views

TC_DAPN_034 Verify Assigned Filter Shows Only Device-Assigned APN And Unassigned Shows Rest
    [Documentation]    PRE: Device with APNs; both Assigned and Unassigned exist.
    ...                STEPS: Click Assigned → note list/count; select APN → observe IP; Click Unassigned → note;
    ...                Click All → verify All count = Assigned + Unassigned.
    ...                EXPECTED: Assigned tab shows only assigned with correct IP; Unassigned shows the rest;
    ...                All count equals sum; IP panel shows relevant address for selected APN.
    [Tags]    feature    regression    device-apn    TC_DAPN_034
    Click APN Tab
    Click Sub Tab    Assigned
    ${assigned_count}=    Get APN Count In List
    ${assigned_apn}=    Get First APN In List
    Click APN In List    ${assigned_apn}
    Verify IP Panel Updates For Selected APN    ${assigned_apn}
    Click Sub Tab    Unassigned
    ${unassigned_count}=    Get APN Count In List
    Click Sub Tab    All
    ${all_count}=    Get APN Count In List
    ${sum}=    Evaluate    ${assigned_count} + ${unassigned_count}
    Should Be Equal As Integers    ${all_count}    ${sum}

TC_DAPN_035 Verify Refresh Button Re-Syncs APN Data Without Losing Current Filter State
    [Documentation]    PRE: Device APN tab open; data visible.
    ...                STEPS: Open APN tab; APN Type=Private; click 'Assigned'; note list; click Refresh; observe.
    ...                EXPECTED: List reloads; APN Type=Private retained; 'Assigned' sub-tab still active;
    ...                new APNs reflected; removed APNs gone; loading indicator during refresh.
    [Tags]    feature    regression    device-apn    TC_DAPN_035
    Click APN Tab
    Select APN Type    Private
    Click Sub Tab    Assigned
    Note APN Name List Content
    Click Refresh Button
    Verify APN Name List Reloaded
    Verify APN Type Selection Retained    Private
    Verify Sub Tab Is Active    Assigned
    Verify Newly Added Or Removed APNs Are Reflected
    Verify Loading Indicator Was Shown During Refresh
