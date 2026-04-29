*** Settings ***
Library     SeleniumLibrary
Library     String
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/device_state_keywords.resource
Resource    ../resources/keywords/manage_devices_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/device_state_locators.resource

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}
...               AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
...               AND    Navigate To Manage Devices Page
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  GROUP A: PAGE LOAD / DISPLAY (Rows 11-16)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_001 Verify Manage Devices Page Loads And Displays Device List With All Expected Columns
    [Documentation]    PRE: User logged in; Devices module accessible.
    ...                STEPS: 1) Login  2) Click 'Devices' in left nav  3) Click 'Manage Devices' tab  4) Observe list.
    ...                EXPECTED: Page loads; table shows columns REF ID, LABEL, ICCID, IMSI, MSISDN,
    ...                BUSINESS UNIT NAME, COST CENTER NAME, SIM STATE, VIN DETAILS, IMEI.
    ...                Rows populated; pagination shows Page 1 of N (e.g., 1 of 142); total (e.g., 2831 items).
    [Tags]    feature    regression    manage-devices    TC_MDEV_001
    Navigate To Devices Module
    Click Manage Devices Tab
    Verify Manage Devices Page Loaded Without Error
    Verify Manage Devices Columns Are Displayed
    Verify Device Rows Are Populated
    Verify Pagination Shows Page X Of N
    Verify Total Items Count Is Displayed

TC_MDEV_002 Verify SIM STATE Column Displays Correct Colour-Coded States
    [Documentation]    PRE: Manage Devices page with device records.
    ...                STEPS: 1) Open page  2) Observe SIM STATE column  3) Cross-check legend.
    ...                EXPECTED: Activated=green, Warm=orange/amber, InActive=blue,
    ...                Suspended / TestActive / Terminate / Retired — shown in their mapped colours; legend matches.
    [Tags]    feature    regression    manage-devices    TC_MDEV_002
    Verify SIM State Colour For    Activated    green
    Verify SIM State Colour For    Warm    orange
    Verify SIM State Colour For    InActive    blue
    Verify SIM State Colour For    Suspended    ${EMPTY}
    Verify SIM State Colour For    TestActive    ${EMPTY}
    Verify SIM State Colour For    Terminate    ${EMPTY}
    Verify SIM State Colour For    Retired    ${EMPTY}
    Verify Legend At Page Bottom Matches Colour Mapping

TC_MDEV_003 Verify Pagination Controls Navigate Correctly Between Pages
    [Documentation]    PRE: Manage Devices multi-page data (2831 items).
    ...                STEPS: Click ►, ◄, ►|, |◄ and change page size to 20/50/100.
    ...                EXPECTED: Each navigation loads expected page; last page shows 2831 mod 20 = 11 rows;
    ...                page size changes row count; total 2831 stays consistent.
    [Tags]    feature    regression    manage-devices    TC_MDEV_003
    Note Current Page Indicator
    Click Next Page Button
    Verify Current Page Is    2
    Click Previous Page Button
    Verify Current Page Is    1
    Click Last Page Button
    Verify Last Page Row Count    11
    Click First Page Button
    Verify Current Page Is    1
    Change Page Size To    20
    Change Page Size To    50
    Change Page Size To    100
    Verify Total Items Count Is    2831

TC_MDEV_004 Verify Column Sort Ascending And Descending On Key Columns
    [Documentation]    PRE: Manage Devices page loaded.
    ...                STEPS: Click sort icons on REF ID, ICCID, IMSI, MSISDN, BUSINESS UNIT NAME,
    ...                SIM STATE, VIN DETAILS, IMEI; click again to reverse.
    ...                EXPECTED: Asc on first click, desc on second; rows reorder; other columns unaffected;
    ...                pagination resets to page 1 after sort.
    [Tags]    feature    regression    manage-devices    TC_MDEV_004
    FOR    ${col}    IN    REF ID    ICCID    IMSI    MSISDN    BUSINESS UNIT NAME    SIM STATE    VIN DETAILS    IMEI
        Click Sort Icon On Column    ${col}
        Verify Column Sorted Ascending    ${col}
        Click Sort Icon On Column    ${col}
        Verify Column Sorted Descending    ${col}
        Verify Pagination Reset To Page 1
    END

TC_MDEV_005 Verify Expand Row Button Shows Device Sub-Details
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Click ► (expand) on a row; observe.
    ...                EXPECTED: Row expands to reveal device plan, service plan, APN, etc.;
    ...                collapse icon ▼ appears; clicking it hides details; other rows unaffected.
    [Tags]    feature    regression    manage-devices    TC_MDEV_005
    Click Expand Icon On First Device Row
    Verify Expanded Row Details Visible
    Click Collapse Icon On First Device Row
    Verify Expanded Row Details Hidden
    Verify Other Rows Unaffected

TC_MDEV_006 Verify Top-Right Lock Or Export Icon Is Functional
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Observe top-right icon; click it.
    ...                EXPECTED: Icon triggers expected functionality (export CSV or lock columns); no error.
    [Tags]    feature    regression    manage-devices    TC_MDEV_006
    Verify Top Right Lock Or Export Icon Is Visible
    Click Top Right Lock Or Export Icon
    Verify Expected Action Performed Without Error

# ═══════════════════════════════════════════════════════════════════════
#  GROUP B: SEARCH & FILTERS (Rows 17-21)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_007 Verify Search By ICCID Returns Correct Device
    [Documentation]    PRE: Search bar visible; filter 'ICCID'.
    ...                STEPS: Set filter ICCID; enter 111111009831634253; click 🔍.
    ...                EXPECTED: Only matching device shown; columns correct; 'No results' when not found; clear restores list.
    [Tags]    feature    regression    manage-devices    TC_MDEV_007
    Set Search Filter Dropdown To    ICCID
    Enter Search Term    111111009831634253
    Click Search Icon
    Verify Device List Filtered To Matching ICCID    111111009831634253
    Clear Search And Verify Full List Restored

TC_MDEV_008 Verify Search Filter Dropdown Can Be Changed
    [Documentation]    PRE: Search bar visible; dropdown shows filter options.
    ...                STEPS: Open dropdown; observe options; select MSISDN; enter valid MSISDN; search.
    ...                EXPECTED: Dropdown shows ICCID/IMSI/MSISDN etc.; selecting MSISDN filters by MSISDN correctly.
    [Tags]    feature    regression    manage-devices    TC_MDEV_008
    Open Search Filter Dropdown
    Verify Filter Options Include    ICCID    IMSI    MSISDN
    Select Search Filter    MSISDN
    Enter Search Term    96650100382
    Click Search Icon
    Verify Device List Filtered By MSISDN    96650100382

TC_MDEV_009 Verify Change State Filter Dropdown Filters List By SIM State
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Locate 'Change State' dropdown; observe options; select Activated.
    ...                EXPECTED: Options include Activated/Warm/Suspended/TestActive/InActive/Terminate/Retired;
    ...                selecting Activated shows only Activated devices; count updates.
    [Tags]    feature    regression    manage-devices    TC_MDEV_009
    Open Change State Filter Dropdown
    Verify SIM State Filter Options Are Present
    Select Change State Filter    Activated
    Verify All Rows Show SIM State    Activated
    Verify Item Count Updated To Reflect Filter

TC_MDEV_010 Verify Search With Invalid Or Non-Existent ICCID Shows No Results
    [Documentation]    PRE: Search bar visible.
    ...                STEPS: Enter 000000000000000; click search.
    ...                EXPECTED: 'No devices found' message; empty state; no error/crash.
    [Tags]    feature    regression    manage-devices    TC_MDEV_010    negative
    Set Search Filter Dropdown To    ICCID
    Enter Search Term    000000000000000
    Click Search Icon
    Verify No Devices Found Message Is Displayed
    Verify Device Table Is Empty
    Verify No Error Or Crash Occurred

TC_MDEV_011 Verify Search Field With Special Characters Or SQL Injection Is Handled Safely
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Enter ' OR 1=1; -- in search; click search.
    ...                EXPECTED: Input sanitized; no SQL error; appropriate 'no results' or validation message.
    [Tags]    feature    regression    manage-devices    TC_MDEV_011    negative
    Enter Search Term    ' OR 1=1; --
    Click Search Icon
    Verify No SQL Error Or Unexpected Data Returned
    Verify No Results Or Validation Message Shown

# ═══════════════════════════════════════════════════════════════════════
#  GROUP C: ROW SELECTION (Rows 22-25)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_012 Verify Individual Device Row Selection Via Checkbox
    [Documentation]    PRE: Device rows visible.
    ...                STEPS: Click checkbox on first row; observe; click again to deselect.
    ...                EXPECTED: Checkbox toggles (blue tick); row highlighted on select; other rows unaffected.
    [Tags]    feature    regression    manage-devices    TC_MDEV_012
    Click Checkbox On Device Row    1
    Verify Device Row Is Selected    1
    Verify Device Row Is Highlighted    1
    Click Checkbox On Device Row    1
    Verify Device Row Is Not Selected    1
    Verify Other Rows Are Unaffected

TC_MDEV_013 Verify Select All Checkbox In Header Selects And Deselects All Rows
    [Documentation]    PRE: Multiple rows visible.
    ...                STEPS: Click header checkbox; observe all rows; click again.
    ...                EXPECTED: All rows on current page selected; bulk buttons active; deselecting clears;
    ...                selection does NOT carry over pages.
    [Tags]    feature    regression    manage-devices    TC_MDEV_013
    Click Select All Header Checkbox
    Verify All Rows On Current Page Are Selected
    Verify Bulk Action Buttons Are Active
    Click Select All Header Checkbox
    Verify All Rows On Current Page Are Deselected
    Verify Selection Does Not Carry Over Pages

TC_MDEV_014 Verify Select Dropdown Provides Selection Options
    [Documentation]    PRE: Device rows visible; 'Select' dropdown in toolbar.
    ...                STEPS: Click Select dropdown; observe; apply each option.
    ...                EXPECTED: Options include Select All / Select Page / Deselect All; each applies; count reflects.
    [Tags]    feature    regression    manage-devices    TC_MDEV_014
    Open Select Dropdown In Toolbar
    Verify Select Dropdown Options    Select All    Select Page    Deselect All
    Apply Select Option And Verify Count    Select All
    Apply Select Option And Verify Count    Select Page
    Apply Select Option And Verify Count    Deselect All

TC_MDEV_015 Verify Close Button In Selection Toolbar Clears Selection
    [Documentation]    PRE: At least one row selected.
    ...                STEPS: Select rows; click Close button in toolbar (next to Submit).
    ...                EXPECTED: All selections cleared; checkboxes unchecked; no state change performed; list unchanged.
    [Tags]    feature    regression    manage-devices    TC_MDEV_015
    Click Checkbox On Device Row    1
    Click Checkbox On Device Row    2
    Click Close Button In Selection Toolbar
    Verify All Checkboxes Are Unchecked
    Verify No State Change Action Was Performed
    Verify Device List Remains Unchanged

# ═══════════════════════════════════════════════════════════════════════
#  GROUP D: CHANGE STATE TOOLBAR (Rows 26-30)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_016 Verify Change State Toolbar Contains Correct Controls
    [Documentation]    PRE: Manage Devices loaded; toolbar visible.
    ...                STEPS: Observe Change State section (right).
    ...                EXPECTED: 'Change State' label/dropdown; state filter (e.g., Activated);
    ...                Submit (purple); Close (red); blue + button; all controls in correct positions.
    [Tags]    feature    regression    manage-devices    TC_MDEV_016
    Verify Change State Label Or Dropdown Is Present
    Verify State Filter Dropdown Shows Current State
    Verify Submit Button Is Visible
    Verify Close Button Is Visible
    Verify Blue Plus Button Is Visible
    Verify All Change State Controls Are In Correct Positions

TC_MDEV_017 Verify Selecting A State And Clicking Submit Opens Change State Popup
    [Documentation]    PRE: At least one device selected.
    ...                STEPS: Select device; pick Change State=Activated; click Submit.
    ...                EXPECTED: 'Change State?' popup opens with Device Plan pre-filled (DP2_8ERCDT),
    ...                Reason pre-selected (Activation by Opco), Proceed and Close buttons visible.
    [Tags]    feature    regression    manage-devices    TC_MDEV_017
    Click Checkbox On Device Row    1
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Verify Change State Popup Title Is    Change State?
    Verify Device Plan Is Pre Filled    DP2_8ERCDT
    Verify Reason Dropdown Pre Selected    Activation by Opco
    Verify Proceed Button Is Visible
    Verify Close Button Is Visible In Popup

TC_MDEV_018 Verify Clicking Submit Without Selecting Any Device Shows Validation
    [Documentation]    PRE: Manage Devices loaded; no device selected.
    ...                STEPS: Do not select; pick state; click Submit.
    ...                EXPECTED: 'Please select at least one device' validation; no popup; list unchanged.
    [Tags]    feature    regression    manage-devices    TC_MDEV_018    negative
    Ensure No Device Is Selected
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Verify Validation Message Contains    Please select at least one device
    Verify Change State Popup Is Not Open
    Verify Device List Unchanged

TC_MDEV_019 Verify Change State Close Button Dismisses Toolbar Action Without Changes
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Pick state; click Close (red) next to Submit.
    ...                EXPECTED: Action cancelled; no popup; states unchanged; selections cleared.
    [Tags]    feature    regression    manage-devices    TC_MDEV_019
    Click Checkbox On Device Row    1
    Select Change State    Activated
    Click Close Button In Change State Toolbar
    Verify Change State Popup Is Not Open
    Verify Device States Remain Unchanged
    Verify All Selections Are Cleared

TC_MDEV_020 Verify Bulk State Change Can Be Applied To Multiple Selected Devices
    [Documentation]    PRE: Multiple devices selected; Change State dropdown set.
    ...                STEPS: Select 3 rows; pick target state; Submit; observe popup.
    ...                EXPECTED: Popup opens with bulk indication or selected count; can proceed;
    ...                all selected transition to new state after Proceed.
    [Tags]    feature    regression    manage-devices    TC_MDEV_020
    Click Checkbox On Device Row    1
    Click Checkbox On Device Row    2
    Click Checkbox On Device Row    3
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Verify Change State Popup Shows Bulk Or Count    3
    Click Proceed In Change State Popup
    Verify All Selected Devices Transitioned To    Activated

# ═══════════════════════════════════════════════════════════════════════
#  GROUP E: CHANGE STATE POPUP (Rows 31-38)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_021 Verify Change State Popup Displays Correct Fields
    [Documentation]    PRE: Change State popup open.
    ...                EXPECTED: Title='Change State?'; Device Plan dropdown pre-filled (e.g., DP2_8ERCDT);
    ...                Reason dropdown pre-filled (e.g., Activation by Opco); Proceed (blue/purple);
    ...                Close (red); X close icon in top-right.
    [Tags]    feature    regression    manage-devices    TC_MDEV_021
    Open Change State Popup From Manage Devices
    Verify Change State Popup Title Is    Change State?
    Verify Device Plan Dropdown Is Visible And Pre Filled
    Verify Reason Dropdown Is Visible And Pre Filled
    Verify Proceed Button Is Visible
    Verify Close Button Is Visible In Popup
    Verify X Close Icon Is Visible In Popup Header

TC_MDEV_022 Verify Device Plan Dropdown Lists Available Plans And Is Pre-Filled
    [Documentation]    PRE: Change State popup open.
    ...                STEPS: Observe Device Plan (DP2_8ERCDT); open dropdown; observe options.
    ...                EXPECTED: Pre-filled with current/applicable plan; lists all eligible plans for target state;
    ...                user can change; selection updates field.
    [Tags]    feature    regression    manage-devices    TC_MDEV_022
    Open Change State Popup From Manage Devices
    Verify Device Plan Is Pre Filled    DP2_8ERCDT
    Open Device Plan Dropdown In Popup
    Verify Eligible Device Plans Are Listed
    Select A Different Device Plan
    Verify Selected Device Plan Is Reflected

TC_MDEV_023 Verify Reason Dropdown Contains All Valid Reasons And Default Is Pre-Selected
    [Documentation]    PRE: Change State popup open.
    ...                STEPS: Observe Reason ('Activation by Opco'); open dropdown; observe options.
    ...                EXPECTED: Default pre-selected; all valid reasons listed for target state;
    ...                user can select another; retained until Proceed/Close.
    [Tags]    feature    regression    manage-devices    TC_MDEV_023
    Open Change State Popup From Manage Devices
    Verify Reason Dropdown Pre Selected    Activation by Opco
    Open Reason Dropdown In Popup
    Verify All Valid Reasons Are Listed
    Select A Different Reason
    Verify Reason Is Retained Until Proceed Or Close

TC_MDEV_024 Verify Clicking Proceed Successfully Changes The Device State
    [Documentation]    PRE: Popup open; Device Plan and Reason filled.
    ...                STEPS: Confirm Device Plan=DP2_8ERCDT and Reason=Activation by Opco; click Proceed.
    ...                EXPECTED: Popup closes; success toast; SIM STATE updates; colour matches legend;
    ...                no errors or partial updates.
    [Tags]    feature    regression    manage-devices    TC_MDEV_024    positive
    Open Change State Popup From Manage Devices
    Verify Device Plan Is Pre Filled    DP2_8ERCDT
    Verify Reason Dropdown Pre Selected    Activation by Opco
    Click Proceed In Change State Popup
    Verify Change State Popup Is Closed
    Verify Success Toast Is Shown    State changed successfully
    Verify Device Row SIM State Updated
    Verify SIM State Colour Matches Legend
    Verify No Error Or Partial Update

TC_MDEV_025 Verify Clicking Close On Popup Cancels The State Change
    [Documentation]    PRE: Change State popup open.
    ...                STEPS: Click Close inside popup.
    ...                EXPECTED: Popup closes; SIM STATE unchanged; no toast; returns to Manage Devices.
    [Tags]    feature    regression    manage-devices    TC_MDEV_025
    Open Change State Popup From Manage Devices
    Click Close Button In Popup
    Verify Change State Popup Is Closed
    Verify Device SIM State Is Unchanged
    Verify No Toast Notification Shown

TC_MDEV_026 Verify Clicking X Icon On Popup Header Cancels Without Changes
    [Documentation]    PRE: Change State popup open.
    ...                STEPS: Click X (cross) in top right.
    ...                EXPECTED: Popup closes; device state unchanged; no action; equivalent to Close.
    [Tags]    feature    regression    manage-devices    TC_MDEV_026
    Open Change State Popup From Manage Devices
    Click X Close Icon On Popup Header
    Verify Change State Popup Is Closed
    Verify Device SIM State Is Unchanged

TC_MDEV_027 Verify Proceed Button Without Selecting Reason Shows Validation
    [Documentation]    PRE: Change State popup open.
    ...                STEPS: Clear Reason; click Proceed.
    ...                EXPECTED: Validation 'Reason is required'; state change does not proceed; popup stays open.
    [Tags]    feature    regression    manage-devices    TC_MDEV_027    negative
    Open Change State Popup From Manage Devices
    Clear Reason Dropdown In Popup
    Click Proceed In Change State Popup
    Verify Validation Message Contains    Reason is required
    Verify Change State Popup Is Still Open

TC_MDEV_028 Verify Proceed Button Without Selecting Device Plan Shows Validation
    [Documentation]    PRE: Change State popup open.
    ...                STEPS: Clear Device Plan; click Proceed.
    ...                EXPECTED: Validation 'Device Plan is required'; state change does not proceed; popup stays open.
    [Tags]    feature    regression    manage-devices    TC_MDEV_028    negative
    Open Change State Popup From Manage Devices
    Clear Device Plan Dropdown In Popup
    Click Proceed In Change State Popup
    Verify Validation Message Contains    Device Plan is required
    Verify Change State Popup Is Still Open

# ═══════════════════════════════════════════════════════════════════════
#  GROUP F: STATE TRANSITIONS (Rows 39-42)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_029 Verify State Transition From InActive To Activated
    [Documentation]    PRE: Device in InActive state selected.
    ...                STEPS: Filter InActive; select device; Change State=Activated; Submit; set plan/reason; Proceed.
    ...                EXPECTED: Device transitions InActive → Activated; column shows 'Activated' (green);
    ...                success toast; device appears in Activated filter.
    [Tags]    feature    regression    manage-devices    TC_MDEV_029
    Filter Device List By SIM State    InActive
    Select First Device In Filtered List
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Set Device Plan And Reason In Popup    DP2_8ERCDT    Activation by Opco
    Click Proceed In Change State Popup
    Verify Device Row SIM State Is    Activated
    Verify SIM State Colour Is    green
    Verify Success Toast Is Shown    State changed successfully
    Verify Device Visible In Activated Filter

TC_MDEV_030 Verify State Transition From Activated To Suspended
    [Documentation]    PRE: Device in Activated state selected.
    ...                STEPS: Filter Activated; select device; Change State=Suspended; Submit; set plan/reason; Proceed.
    ...                EXPECTED: Activated → Suspended; column shows Suspended with correct colour; success toast.
    [Tags]    feature    regression    manage-devices    TC_MDEV_030
    Filter Device List By SIM State    Activated
    Select First Device In Filtered List
    Select Change State    Suspended
    Click Submit Button In Change State Toolbar
    Set Device Plan And Reason In Popup    DP2_8ERCDT    Suspended by Opco
    Click Proceed In Change State Popup
    Verify Device Row SIM State Is    Suspended
    Verify SIM State Colour Matches Legend
    Verify Success Toast Is Shown    State changed successfully

TC_MDEV_031 Verify State Transition From Warm To Activated
    [Documentation]    PRE: Device in Warm state selected.
    ...                STEPS: Find Warm device; select; Change State=Activated; Submit; Proceed.
    ...                EXPECTED: Warm → Activated; column shows green 'Activated'; success toast.
    [Tags]    feature    regression    manage-devices    TC_MDEV_031
    Filter Device List By SIM State    Warm
    Select First Device In Filtered List
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Set Device Plan And Reason In Popup    DP2_8ERCDT    Activation by Opco
    Click Proceed In Change State Popup
    Verify Device Row SIM State Is    Activated
    Verify SIM State Colour Is    green
    Verify Success Toast Is Shown    State changed successfully

TC_MDEV_032 Verify System Prevents Or Warns When Setting Device To Its Current State
    [Documentation]    PRE: Device already in target state (e.g., Activated).
    ...                STEPS: Select Activated device; set Change State=Activated; Submit.
    ...                EXPECTED: Warning 'Device is already in Activated state'; state change blocked/handled; no duplicate.
    [Tags]    feature    regression    manage-devices    TC_MDEV_032    negative
    Filter Device List By SIM State    Activated
    Select First Device In Filtered List
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Verify Warning Contains    Device is already in Activated state
    Verify No Duplicate State Change Performed

# ═══════════════════════════════════════════════════════════════════════
#  GROUP G: CASE ID & LEFT TOOLBAR (Rows 43-45)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_033 Verify Case ID Dropdown Lists Available Cases And Can Be Selected
    [Documentation]    PRE: 'Please Select Case ID' dropdown visible in left toolbar.
    ...                STEPS: Click dropdown; observe cases; select one.
    ...                EXPECTED: Dropdown lists cases; selected case shown; device list may filter/associate.
    [Tags]    feature    regression    manage-devices    TC_MDEV_033
    Open Case ID Dropdown
    Verify Case ID Dropdown Lists Cases
    Select First Available Case ID
    Verify Selected Case ID Is Shown In Dropdown
    Verify Device List May Filter Or Associate With Selected Case

TC_MDEV_034 Verify Submit Button In Left Toolbar With Case ID Submits Action
    [Documentation]    PRE: Case ID selected; devices selected.
    ...                STEPS: Select Case ID; select devices; click left Submit (purple).
    ...                EXPECTED: Action submitted with Case ID; success toast or confirmation flow.
    [Tags]    feature    regression    manage-devices    TC_MDEV_034
    Select First Available Case ID
    Click Checkbox On Device Row    1
    Click Left Toolbar Submit Button
    Verify Success Or Confirmation Flow Triggered

TC_MDEV_035 Verify Submit Left Toolbar Without Case ID Shows Validation
    [Documentation]    PRE: No Case ID selected.
    ...                STEPS: Do not select Case ID; select device; click left Submit.
    ...                EXPECTED: Validation 'Please select a Case ID'; action not submitted.
    [Tags]    feature    regression    manage-devices    TC_MDEV_035    negative
    Ensure No Case ID Is Selected
    Click Checkbox On Device Row    1
    Click Left Toolbar Submit Button
    Verify Validation Message Contains    Please select a Case ID
    Verify Action Is Not Submitted

# ═══════════════════════════════════════════════════════════════════════
#  GROUP H: TABS / NAVIGATION (Rows 46-47)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_036 Verify All Tabs In Devices Module Are Accessible And Load Correctly
    [Documentation]    PRE: User on Devices module.
    ...                STEPS: Click each tab: Manage Devices, Upload History, Blank SIM, Lost SIM,
    ...                Pool/Shared Plan Details, Retention Cases.
    ...                EXPECTED: Each tab loads; active tab underlined; correct content; no data loss.
    [Tags]    feature    regression    manage-devices    TC_MDEV_036
    FOR    ${tab}    IN    Manage Devices    Upload History    Blank SIM    Lost SIM    Pool/Shared Plan Details    Retention Cases
        Click Tab    ${tab}
        Verify Tab Loaded Without Error    ${tab}
        Verify Tab Is Highlighted    ${tab}
        Verify Correct Content For Tab    ${tab}
    END
    Verify Navigation Between Tabs Does Not Cause Data Loss

TC_MDEV_037 Verify Returning To Manage Devices Tab Retains Or Resets List State
    [Documentation]    PRE: User navigated away from Manage Devices tab.
    ...                STEPS: Apply filter (Activated); click Lost SIM tab; return to Manage Devices.
    ...                EXPECTED: List state handled per business rules (retained or reset);
    ...                no crash or blank page.
    [Tags]    feature    regression    manage-devices    TC_MDEV_037
    Click Tab    Manage Devices
    Select Change State Filter    Activated
    Click Tab    Lost SIM
    Click Tab    Manage Devices
    Verify List State Retained Or Reset Per Business Rules
    Verify No Crash Or Blank Page On Return

# ═══════════════════════════════════════════════════════════════════════
#  GROUP I: PERFORMANCE / ROBUSTNESS (Rows 48-52)
# ═══════════════════════════════════════════════════════════════════════

TC_MDEV_038 Verify Page Performance With Large Data Set (2831 Devices / 142 Pages)
    [Documentation]    PRE: Manage Devices has 2831 devices.
    ...                STEPS: Measure page load; navigate first 5 pages; sort ICCID.
    ...                EXPECTED: Load ≤5s; smooth pagination; sort ≤3s; no freeze/timeout;
    ...                2831 count consistent throughout.
    [Tags]    feature    regression    manage-devices    TC_MDEV_038
    Measure Page Load Time Within    5
    Navigate Through First N Pages    5
    Click Sort Icon On Column    ICCID
    Verify Sort Completes Within    3
    Verify No Browser Freeze Or Timeout
    Verify Total Items Count Is    2831

TC_MDEV_039 Verify Browser Refresh Does Not Crash The Page Or Lose Critical Context
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Apply filter; navigate page 3; press F5.
    ...                EXPECTED: Page reloads to default (page 1, no filter); no crash; list fully functional.
    [Tags]    feature    regression    manage-devices    TC_MDEV_039
    Apply Any Search Filter
    Go To Page    3
    Refresh Browser
    Verify Page Reloads To Default State
    Verify Device List Is Fully Functional After Refresh

TC_MDEV_040 Verify Error Handling When Change State API Fails
    [Documentation]    PRE: User attempts state change; backend API unavailable.
    ...                STEPS: Select device; Change State=Activated; Submit; simulate API failure; Proceed.
    ...                EXPECTED: Error 'State change failed. Please try again.'; SIM STATE unchanged;
    ...                popup may stay open for retry; no partial update.
    [Tags]    feature    regression    manage-devices    TC_MDEV_040    negative
    Click Checkbox On Device Row    1
    Select Change State    Activated
    Click Submit Button In Change State Toolbar
    Simulate Change State API Failure
    Click Proceed In Change State Popup
    Verify Error Message Contains    State change failed. Please try again.
    Verify Device SIM State Is Unchanged
    Verify Change State Popup May Stay Open For Retry
    Verify No Partial Update Or Data Corruption

TC_MDEV_041 Verify Unauthorized User Cannot Perform State Change
    [Documentation]    PRE: User without 'Change State' permission.
    ...                STEPS: Login as unauthorized user; open Manage Devices; attempt state change.
    ...                EXPECTED: Change State controls hidden/disabled; if accessible, shows
    ...                'You do not have permission to perform this action'; no change executed.
    [Tags]    feature    regression    manage-devices    TC_MDEV_041    negative
    Login As User Without Change State Permission
    Navigate To Manage Devices Page
    Verify Change State Controls Are Hidden Or Disabled
    Run Keyword And Expect Error    *permission*    Click Submit Button In Change State Toolbar
    Verify No State Change Is Executed

TC_MDEV_042 Verify UI Layout Is Responsive And Columns Remain Readable
    [Documentation]    PRE: Manage Devices loaded.
    ...                STEPS: Open at 1920×1080; resize to 1366×768; observe.
    ...                EXPECTED: Columns readable (h-scroll if needed); toolbar buttons clickable;
    ...                pagination accessible; no column overlap or text truncation breaking layout.
    [Tags]    feature    regression    manage-devices    TC_MDEV_042
    Set Browser Resolution    1920    1080
    Verify Manage Devices Columns Are Displayed
    Set Browser Resolution    1366    768
    Verify Columns Remain Readable With H Scroll If Needed
    Verify Toolbar Buttons Remain Clickable
    Verify Pagination Controls Are Accessible
    Verify No Column Overlap Or Text Truncation

TC_MDEV_043 Verify Blue Pencil Icon On Device Row Opens Device Detail Or Note Editor
    [Documentation]    PRE: Valid device in list; blue pencil/note icon visible.
    ...                STEPS: Click blue pencil icon on any row; observe action.
    ...                EXPECTED: Opens device detail view or note/comment editor; user can view/add notes;
    ...                saving persists; cancel discards.
    [Tags]    feature    regression    manage-devices    TC_MDEV_043
    Locate Blue Pencil Icon On First Device Row
    Click Blue Pencil Icon On First Device Row
    Verify Device Detail Or Note Editor Opens
    Add A Sample Note
    Save Note And Verify Persisted
    Open Note Editor Again
    Cancel Note And Verify Discarded
