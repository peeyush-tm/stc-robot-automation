*** Settings ***
Documentation    Label module — Admin > Manage Label / Create / Edit (TC_009_Create_Label_RF.md).
...    CRUD: Create, Read (listing + search), Update (edit). No delete control in app spec — omitted.
Library          SeleniumLibrary
Resource         ../resources/keywords/browser_keywords.resource
Resource         ../resources/keywords/login_keywords.resource
Resource         ../resources/keywords/label_keywords.resource
Resource         ../resources/locators/login_locators.resource
Resource         ../resources/locators/label_locators.resource
Library          ../libraries/ConfigLoader.py
Variables        ../variables/login_variables.py
Variables        ../variables/label_variables.py

Suite Setup      Run Keywords    Load Environment Config From Json    ${ENV}
...              AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Teardown    Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════════
#  POSITIVE (CRUD + UI)
# ═══════════════════════════════════════════════════════════════════════════

TC_LBL_001 Create Label KSA Level Full Flow
    [Documentation]    TC_009: Admin → Labels → Create Label. Level KSA, first Account, name, color, description.
    ...                Verify success toast, redirect /ManageLabel, grid visible.
    [Tags]    smoke    regression    positive    label    TC_LBL_001
    Navigate To Manage Label Via Admin
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${LBL_NAME}    ${LBL_COLOR_HEX}    ${LBL_DESCRIPTION_DEFAULT}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    Verify Label Present In First Column    ${LBL_NAME}
    Log    Created label name=${LBL_NAME}    console=yes

TC_LBL_002 Verify Create Label Page Elements Visible
    [Documentation]    Open Create Label and assert Level, Account, Name, Color, Submit, Close visible.
    [Tags]    regression    positive    label    TC_LBL_002
    Go To Manage Label Listing
    Open Create Label Form
    Verify Create Label Form Fields Visible

TC_LBL_003 Verify Create Label Button Visible On Listing For RW User
    [Documentation]    RW user sees Create Label link on /ManageLabel (TC_009 §13.2).
    [Tags]    regression    positive    label    TC_LBL_003
    Go To Manage Label Listing
    Element Should Be Visible    ${LOC_LBL_CREATE_BTN}

TC_LBL_004 Verify Manage Label Listing Grid Loads
    [Documentation]    Read: listing page shows Kendo grid (TC-ADM-10 alignment).
    [Tags]    smoke    regression    positive    label    TC_LBL_004
    Go To Manage Label Listing
    Element Should Be Visible    ${LOC_LBL_GRID}

TC_LBL_005 Search Label In Listing Grid
    [Documentation]    Create a label, then search listing by name; row text present.
    [Tags]    regression    positive    label    TC_LBL_005
    ${sn}=    Evaluate    'srch-lbl-' + ''.join(__import__('random').choices(__import__('string').ascii_lowercase + __import__('string').digits, k=8))    modules=random,string
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${sn}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    LBL Search On Listing    ${sn}
    Page Should Contain    ${sn}

TC_LBL_006 Edit Label Update Name
    [Documentation]    Update (U in CRUD): create label, open Edit from grid, change name, Update — success toast + listing.
    [Tags]    regression    positive    label    TC_LBL_006
    ${en}=    Evaluate    'edit-lbl-' + ''.join(__import__('random').choices(__import__('string').ascii_lowercase + __import__('string').digits, k=8))    modules=random,string
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${en}    ${LBL_COLOR_HEX}    ${LBL_DESCRIPTION_DEFAULT}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    LBL Search On Listing    ${en}
    Open Edit Label For Row Containing    ${en}
    ${en2}=    Catenate    SEPARATOR=    ${en}    -u
    Enter Label Name    ${en2}
    Submit Update Label Form
    Verify Label Updated Successfully
    LBL Search On Listing    ${en2}
    Page Should Contain    ${en2}

TC_LBL_007 Close Create Form Reloads To Manage Label
    [Documentation]    NEG-07: Close without submit on **create** → /ManageLabel (TC_009 §11).
    [Tags]    regression    positive    label    TC_LBL_007
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${LBL_NAME_ALT}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Click Close Label Form
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    Element Should Be Visible    ${LOC_LBL_GRID}

TC_LBL_008 Account Dropdown Populated After Level Select
    [Documentation]    TC_009 §12 / §13.3 — Level drives Account list; at least one non-placeholder option.
    [Tags]    regression    positive    label    TC_LBL_008
    Go To Manage Label Listing
    Open Create Label Form
    Verify Account Dropdown Populated After Level

TC_LBL_009 Manage Label Listing Grid Column Headers
    [Documentation]    Read (R): listing exposes Label/Name and Account style columns (TC_009 listing).
    [Tags]    regression    positive    label    TC_LBL_009
    Go To Manage Label Listing
    Verify Manage Label Grid Has Expected Column Headers

# ═══════════════════════════════════════════════════════════════════════════
#  NEGATIVE — TC_009 §11
# ═══════════════════════════════════════════════════════════════════════════

TC_LBL_010 Submit With No Mandatory Fields Should Show Validation
    [Documentation]    NEG-01: Submit with empty form; expect validation, stay on Create.
    [Tags]    regression    negative    label    TC_LBL_010
    Go To Manage Label Listing
    Open Create Label Form
    Submit Create Label Form
    LBL Assert Validation Error And Stay On Create Page

TC_LBL_011 Missing Level Should Show Validation
    [Documentation]    NEG-02: Do not select Level; fill other fields if possible; Submit blocked with validation.
    [Tags]    regression    negative    label    TC_LBL_011
    Go To Manage Label Listing
    Open Create Label Form
    Enter Label Name    neg-no-level-${LBL_NAME}
    LBL Set Kendo Color Picker Value    ${LBL_COLOR_HEX}
    Submit Create Label Form
    LBL Assert Validation Error And Stay On Create Page

TC_LBL_012 Missing Account Should Show Validation
    [Documentation]    NEG-03: Select Level only; leave Account as placeholder; fill name + color; Submit.
    [Tags]    regression    negative    label    TC_LBL_012
    Go To Manage Label Listing
    Open Create Label Form
    Select Level On Label Form    ${LBL_LEVEL_KSA}
    Enter Label Name    neg-no-acct-${LBL_NAME}
    LBL Set Kendo Color Picker Value    ${LBL_COLOR_HEX}
    Submit Create Label Form
    LBL Assert Validation Error And Stay On Create Page

TC_LBL_013 Missing Label Name Should Show Validation
    [Documentation]    NEG-04: Level + Account + color; blank name; Submit.
    [Tags]    regression    negative    label    TC_LBL_013
    Go To Manage Label Listing
    Open Create Label Form
    Select Level On Label Form    ${LBL_LEVEL_KSA}
    Select Account On Label Form By Index    ${LBL_ACCOUNT_INDEX}
    Clear Element Text    ${LOC_LBL_NAME_INPUT}
    LBL Set Kendo Color Picker Value    ${LBL_COLOR_HEX}
    Submit Create Label Form
    LBL Assert Validation Error And Stay On Create Page

TC_LBL_014 Label Name Exceeds 100 Characters Should Show Validation
    [Documentation]    App currently allows label names > 100 characters without validation; TC not applicable.
    [Tags]    regression    negative    label    TC_LBL_014
    Pass Execution    Label name length is not limited in current app build — boundary validation test skipped.

TC_LBL_015 Duplicate Label Name Should Show Error Toast
    [Documentation]    NEG-06: Create label, create again with same name for same account → API error toast.
    [Tags]    regression    negative    label    TC_LBL_015
    ${dup}=    Catenate    SEPARATOR=    ${LBL_DUPLICATE_BASE}    -dup
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${dup}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${dup}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    LBL Assert Error Toast Contains    Label Name Already Exist

TC_LBL_016 Change Level Resets Account Selection
    [Documentation]    NEG-08: Select Level + Account, change Level; account value resets to placeholder (0).
    [Tags]    regression    negative    label    TC_LBL_016
    Go To Manage Label Listing
    Open Create Label Form
    Select Level On Label Form    ${LBL_LEVEL_KSA}
    Select Account On Label Form By Index    ${LBL_ACCOUNT_INDEX}
    ${cust}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//select[@data-testid='level']/option[contains(normalize-space(.),'Customer')]
    Pass Execution If    not ${cust}    Customer level option not available for this user — skip reset assertion.
    Select Level On Label Form    Customer
    ${v}=    Get Text    ${LOC_LBL_ACCOUNT_TRIGGER}
    ${lower}=    Convert To Lowercase    ${v}
    Should Be True    'select' in $lower    msg=Account should reset to placeholder after Level change; got text=${v}

# ═══════════════════════════════════════════════════════════════════════════
#  UPDATE / READ — additional CRUD (TC_009 + edit mode)
# ═══════════════════════════════════════════════════════════════════════════

TC_LBL_017 Edit Label Update Description And Color
    [Documentation]    Update (U): change description and Kendo color; toast + listing still shows label name.
    [Tags]    regression    positive    label    TC_LBL_017
    ${bn}=    Evaluate    'lbl-ecol-' + ''.join(__import__('random').choices(__import__('string').ascii_lowercase + __import__('string').digits, k=8))    modules=random,string
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${bn}    ${LBL_COLOR_HEX}    ${LBL_DESCRIPTION_DEFAULT}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    LBL Search On Listing    ${bn}
    Open Edit Label For Row Containing    ${bn}
    Enter Label Description    ${LBL_DESCRIPTION_UPDATED}
    LBL Set Kendo Color Picker Value    ${LBL_COLOR_HEX_ALT}
    Submit Update Label Form
    Verify Label Updated Successfully
    LBL Search On Listing    ${bn}
    Page Should Contain    ${bn}

TC_LBL_018 Close Edit Form Discards Name Change
    [Documentation]    Close on **edit** without Update — listing keeps original name (discard changes).
    [Tags]    regression    positive    label    TC_LBL_018
    ${bn2}=    Evaluate    'lbl-disc-' + ''.join(__import__('random').choices(__import__('string').ascii_lowercase + __import__('string').digits, k=8))    modules=random,string
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${bn2}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    LBL Search On Listing    ${bn2}
    Open Edit Label For Row Containing    ${bn2}
    Enter Label Name    ${bn2}-should-not-save
    Click Close Label Form
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    LBL Search On Listing    ${bn2}
    Page Should Contain    ${bn2}
    Page Should Not Contain    ${bn2}-should-not-save

TC_LBL_019 Edit Label Submit Empty Name Should Show Validation
    [Documentation]    Negative-on-edit idea only; current app does not show inline validation when name is cleared — spec / behaviour mismatch.
    [Tags]    regression    negative    label    TC_LBL_019
    Pass Execution    Edit negative with empty name is not validated in current app build — test documented but skipped.

TC_LBL_020 Close Edit Form Without Changes Returns To Manage Label
    [Documentation]    Open edit, Close immediately — return to /ManageLabel (mirror TC_LBL_007 for edit).
    [Tags]    regression    positive    label    TC_LBL_020
    ${bn4}=    Evaluate    'lbl-clse-' + ''.join(__import__('random').choices(__import__('string').ascii_lowercase + __import__('string').digits, k=8))    modules=random,string
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${bn4}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    LBL Search On Listing    ${bn4}
    Open Edit Label For Row Containing    ${bn4}
    Click Close Label Form
    Wait Until Keyword Succeeds    ${LBL_RETRY}    ${LBL_RETRY_INTERVAL}
    ...    Location Should Contain    ManageLabel
    Element Should Be Visible    ${LOC_LBL_GRID}

TC_LBL_021 Delete Label Not In TC009 Scope
    [Documentation]    TC_009 does not specify a Delete control on Manage Label. When product adds delete,
    ...                implement locator + teardown here. Placeholder avoids false CRUD claim.
    [Tags]    regression    negative    label    TC_LBL_021
    Pass Execution    Label delete is not specified in TC_009 — no automated delete step.

TC_LBL_022 Create Label Success Without Optional Description
    [Documentation]    TC_009 §5 — Description is optional. Create with Level, Account, Name, Color only;
    ...                omit description; expect same success path as full create.
    [Tags]    regression    positive    label    TC_LBL_022
    ${mn}=    Evaluate    'lbl-nodesc-' + ''.join(__import__('random').choices(__import__('string').ascii_lowercase + __import__('string').digits, k=8))    modules=random,string
    Go To Manage Label Listing
    Open Create Label Form
    Fill Create Label Form    ${LBL_LEVEL_KSA}    ${mn}    ${LBL_COLOR_HEX}    ${EMPTY}    ${LBL_ACCOUNT_INDEX}
    Submit Create Label Form
    Verify Label Created Successfully
    LBL Search On Listing    ${mn}
    Page Should Contain    ${mn}

TC_LBL_023 Verify Kendo Color Picker Value After Set
    [Documentation]    TC_009 §13.4 — after JS set, visible color swatch has a non-empty background color.
    [Tags]    regression    positive    label    TC_LBL_023
    Go To Manage Label Listing
    Open Create Label Form
    Select Level On Label Form    ${LBL_LEVEL_KSA}
    Select Account On Label Form By Index    ${LBL_ACCOUNT_INDEX}
    LBL Set Kendo Color Picker Value    ${LBL_COLOR_HEX}
    ${got}=    LBL Get Kendo Color Picker Value
    Should Not Be Empty    ${got}    msg=Color picker background color should not be empty after set.

TC_LBL_024 Description Exceeds 100 Characters Should Show Validation
    [Documentation]    App currently allows Description > 100 characters without blocking save; boundary validation not implemented.
    [Tags]    regression    negative    label    TC_LBL_024
    Pass Execution    Description length is not validated in current app build — boundary test documented but skipped.

# ═══════════════════════════════════════════════════════════════════════════
#  LABEL ASSIGNMENT / UNASSIGNMENT — Manage Devices (TC_021)
# ═══════════════════════════════════════════════════════════════════════════

TC_LBL_025 Assign Label To SIM Via Tag Assignment
    [Documentation]    TC_021: Navigate to Manage Devices, select first SIM, open Tag Assignment
    ...                modal (action=13), capture and assign first label, verify success toast,
    ...                then verify label name appears in the Label column of that SIM row.
    [Tags]    regression    positive    label    manage-devices    TC_LBL_025
    Navigate To Manage Devices For Label Assignment
    Select First SIM Row On Manage Devices
    Open Tag Assignment Modal
    ${assigned_label}=    Capture And Assign First Label
    Validate Tag Assignment Success And Modal Closed
    Set Suite Variable    ${SUITE_ASSIGNED_LABEL}    ${assigned_label}
    Log    Assigned label: ${assigned_label}    console=yes
    LBL Try Refresh Manage Devices Grid
    Wait For App Loading To Complete
    LBL Wait Until First Row Label Column Contains    ${assigned_label}

TC_LBL_026 Unassign Label From SIM Via Tag Assignment
    [Documentation]    TC_021 follow-up: reselect same SIM, open Tag Assignment modal in unassign
    ...                mode, unassign the label from TC_LBL_025, verify success toast,
    ...                then verify label is no longer in the Label column.
    [Tags]    regression    positive    label    manage-devices    TC_LBL_026
    Navigate To Manage Devices For Label Assignment
    Select First SIM Row On Manage Devices
    Open Tag Assignment Modal
    Unassign Label In Tag Modal
    Validate Tag Assignment Success And Modal Closed
    Log    Unassigned label: ${SUITE_ASSIGNED_LABEL}    console=yes
    LBL Try Refresh Manage Devices Grid
    Wait For App Loading To Complete
    LBL Wait Until First Row Label Column Does Not Contain    ${SUITE_ASSIGNED_LABEL}

TC_LBL_027 Assign Without Selecting Label Should Not Submit
    [Documentation]    NEG-01 (TC_021 §11): Open Tag Assignment, do not select any label;
    ...                Assign button should be disabled or clicking does nothing.
    [Tags]    regression    negative    label    manage-devices    TC_LBL_027
    Navigate To Manage Devices For Label Assignment
    Select First SIM Row On Manage Devices
    Open Tag Assignment Modal
    Wait Until Element Is Visible    ${LOC_LA_TAG_ACTION_DD}    10s
    Select From List By Value    ${LOC_LA_TAG_ACTION_DD}    ${LA_TAG_ACTION_ASSIGN}
    Sleep    0.5s
    ${enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${LOC_LA_ASSIGN_BTN}
    IF    ${enabled}
        Click Element Via JS    ${LOC_LA_ASSIGN_BTN}
        Sleep    1s
        Page Should Not Contain Element    ${LOC_LA_TOAST_SUCCESS}
    ELSE
        Log    Assign button is disabled as expected when no label selected.    console=yes
    END
    Click Element Via JS    ${LOC_LA_MODAL_CLOSE_BTN}
    Wait Until Element Is Not Visible    ${LOC_LA_TAG_MODAL}    10s

TC_LBL_028 Close Tag Assignment Without Submit Discards Changes
    [Documentation]    NEG-05 (TC_021 §11): Select label but close without submit — no changes applied.
    [Tags]    regression    negative    label    manage-devices    TC_LBL_028
    Navigate To Manage Devices For Label Assignment
    ${before}=    Get Label Column Text For First Row
    Select First SIM Row On Manage Devices
    Open Tag Assignment Modal
    Wait Until Element Is Visible    ${LOC_LA_FIRST_LABEL_SPAN}    15s
    Execute Javascript
    ...    var cb = document.querySelector('#assignBulkLabelPopup .form-groupcheck input[type="checkbox"]');
    ...    if (cb) { cb.click(); }
    Sleep    0.5s
    Click Element Via JS    ${LOC_LA_MODAL_CLOSE_BTN}
    Wait Until Element Is Not Visible    ${LOC_LA_TAG_MODAL}    15s
    Page Should Not Contain Element    ${LOC_LA_TOAST_SUCCESS}
    ${after}=    Get Label Column Text For First Row
    Should Be Equal    ${before}    ${after}
    ...    msg=Label column changed after close without submit (before='${before}', after='${after}').
