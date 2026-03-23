*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/rule_engine_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/rule_engine_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/rule_engine_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_RE_001 Create Rule With SIM Lifecycle And Raise Alert Action
    [Documentation]    Full 4-tab wizard happy path: Navigate to Rule Engine listing,
    ...                click Create Rule, fill Primary Details (EC level, SIMLifecycle),
    ...                select first Rule Category trigger + save, set Account aggregation,
    ...                add Raise Alert action, submit, verify success toast and redirect.
    [Tags]    smoke    regression    positive    rule-engine    sim-lifecycle
    TC_RE_001

TC_RE_002 Create Rule With SIM Lifecycle Trigger Option 2
    [Documentation]    SIMLifecycle category with 2nd Rule Category option (e.g. Country or Operator change, Data Session Count, etc.).
    [Tags]    regression    positive    rule-engine    sim-lifecycle    trigger-2
    TC_RE_002

TC_RE_003 Create Rule With SIM Lifecycle Trigger Option 3
    [Documentation]    SIMLifecycle category with 3rd Rule Category option (e.g. Data Session End, Data Session Start, etc.).
    [Tags]    regression    positive    rule-engine    sim-lifecycle    trigger-3
    TC_RE_003

TC_RE_004 Create Rule With Fraud Prevention Trigger Option 1
    [Documentation]    FraudPrevention category, 1st trigger option. Full E2E.
    [Tags]    regression    positive    rule-engine    fraud-prevention    trigger-1
    TC_RE_004

TC_RE_005 Create Rule With Fraud Prevention Trigger Option 2
    [Documentation]    FraudPrevention category, 2nd Rule Category option.
    [Tags]    regression    positive    rule-engine    fraud-prevention    trigger-2
    TC_RE_005

TC_RE_006 Create Rule With Cost Control Trigger Option 1
    [Documentation]    CostControl category, 1st trigger option. Full E2E.
    [Tags]    regression    positive    rule-engine    cost-control    trigger-1
    TC_RE_006

TC_RE_007 Create Rule With Cost Control Trigger Option 2
    [Documentation]    CostControl category, 2nd Rule Category option.
    [Tags]    regression    positive    rule-engine    cost-control    trigger-2
    TC_RE_007

TC_RE_008 Create Rule With Others Category Trigger Option 1
    [Documentation]    Others category, 1st trigger option. Full E2E.
    [Tags]    regression    positive    rule-engine    others    trigger-1
    TC_RE_008

TC_RE_009 Create Rule With Others Category Trigger Option 2
    [Documentation]    Others category, 2nd Rule Category option.
    [Tags]    regression    positive    rule-engine    others    trigger-2
    TC_RE_009

# ── All Rule Category options on Define Triggers tab (one rule per option) ─
TC_RE_009A Create Rules For All SIM Lifecycle Rule Category Options
    [Documentation]    Define Triggers: creates one rule per Rule Category dropdown option (SIM Lifecycle).
    [Tags]    regression    positive    rule-engine    sim-lifecycle    all-triggers
    TC_RE_009A

TC_RE_009B Create Rules For All Fraud Prevention Rule Category Options
    [Documentation]    Define Triggers: creates one rule per Rule Category dropdown option (Fraud Prevention).
    [Tags]    regression    positive    rule-engine    fraud-prevention    all-triggers
    TC_RE_009B

TC_RE_009C Create Rules For All Cost Control Rule Category Options
    [Documentation]    Define Triggers: creates one rule per Rule Category dropdown option (Cost Control).
    [Tags]    regression    positive    rule-engine    cost-control    all-triggers
    TC_RE_009C

TC_RE_009D Create Rules For All Others Rule Category Options
    [Documentation]    Define Triggers: creates one rule per Rule Category dropdown option (Others).
    [Tags]    regression    positive    rule-engine    others    all-triggers
    TC_RE_009D

# ── All Primary category × Action tab combinations ─────────────────────
TC_RE_009E Create Rules For All Category And Action Combinations
    [Documentation]    Creates one rule per (Primary category × Action type): SIM Lifecycle, Fraud Prevention,
    ...                Cost Control, Others × each Action from Tab 4 dropdown (e.g. Raise Alert, Email).
    [Tags]    regression    positive    rule-engine    category-action-combo
    TC_RE_009E

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_RE_010 NEG01 Next On Tab1 With Rule Name Blank
    [Documentation]    Leave Rule Name empty on Tab 1, click Next. Wizard must stay on Tab 1.
    [Tags]    regression    negative    rule-engine
    TC_RE_010

TC_RE_011 NEG02 Next On Tab1 With Category Not Selected
    [Documentation]    Fill Rule Name and Description but leave Category as default. Click Next.
    ...                Wizard must stay on Tab 1 with validation error.
    [Tags]    regression    negative    rule-engine
    TC_RE_011

TC_RE_012 NEG03 Next On Tab1 With App Level Not Selected
    [Documentation]    Fill Rule Name, select Category, enter Description, but leave
    ...                Application Level as default. Click Next. Wizard must stay on Tab 1.
    [Tags]    regression    negative    rule-engine
    TC_RE_012

TC_RE_013 NEG04 Next On Tab1 With Customer Not Selected
    [Documentation]    Fill all Tab 1 fields except Customer Account. Click Next.
    ...                Wizard must stay on Tab 1 with validation error for Customer.
    [Tags]    regression    negative    rule-engine
    TC_RE_013

TC_RE_014 NEG05 Next On Tab1 With Device Plan Not Selected
    [Documentation]    Fill all Tab 1 fields including Customer, but leave Device Plan
    ...                as default -Select-. Click Next. Wizard must stay on Tab 1.
    [Tags]    regression    negative    rule-engine
    TC_RE_014

TC_RE_015 NEG06 Next On Tab2 With No Rule Category Selected
    [Documentation]    Complete Tab 1, advance to Tab 2, leave Rule Category unselected,
    ...                click Next. Wizard must stay on Tab 2.
    [Tags]    regression    negative    rule-engine
    TC_RE_015

TC_RE_016 NEG07 Next On Tab2 With No Trigger Saved
    [Documentation]    Complete Tab 1, advance to Tab 2, select Rule Category but do NOT
    ...                click Add/Save Trigger. Click Next. Wizard must stay on Tab 2.
    [Tags]    regression    negative    rule-engine
    TC_RE_016

TC_RE_017 NEG08 Next On Tab3 With No Aggregation Level
    [Documentation]    Complete Tabs 1-2, advance to Tab 3, leave Aggregation Level unselected,
    ...                click Next. Wizard must stay on Tab 3.
    [Tags]    regression    negative    rule-engine
    TC_RE_017

TC_RE_018 NEG09 Submit On Tab4 With No Action Saved
    [Documentation]    Complete Tabs 1-3, advance to Tab 4, click Submit without selecting
    ...                any Action Type or saving an action. Wizard must stay on Tab 4.
    [Tags]    regression    negative    rule-engine
    TC_RE_018

TC_RE_019 NEG10 Save Email Action Without Recipients
    [Documentation]    On Tab 4, select Email action type, click Save Action without adding
    ...                any email recipients. Validation error should appear.
    [Tags]    regression    negative    rule-engine
    TC_RE_019

TC_RE_020 NEG11 Invalid Email In Raise Alert To Field
    [Documentation]    On Tab 4, select Raise Alert action, type an invalid email address
    ...                in the ReactTags input, press Enter. Email tag should not be added
    ...                or validation error should appear.
    [Tags]    regression    negative    rule-engine
    TC_RE_020

TC_RE_021 NEG12 Close Wizard Mid Way
    [Documentation]    Navigate to Create Rule, fill Tab 1, click Close button.
    ...                No rule should be created; browser redirects to /RuleEngine listing.
    [Tags]    regression    negative    rule-engine
    TC_RE_021

TC_RE_022 NEG13 Rule Name Exceeds 50 Characters
    [Documentation]    Enter a 51-character string in Rule Name. The field should cap
    ...                at 50 characters (maxLength attribute) or Joi validation should fire.
    [Tags]    regression    negative    rule-engine
    TC_RE_022

TC_RE_023 NEG14 Device Plan Disabled When All DP Checked
    [Documentation]    On Tab 1, select Customer so Device Plan populates, then check the
    ...                "All Device Plan" checkbox. Device Plan dropdown must become disabled.
    [Tags]    regression    negative    rule-engine
    TC_RE_023

*** Keywords ***
TC_RE_001
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Validate Tab 1 Fields Visible
    Validate Previous Button Not Visible On Tab 1
    Fill Primary Details Tab
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=1
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    ${RE_RULE_NAME}

TC_RE_002
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=SL_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY}
    Click Next Tab
    Validate Tab 2 Ready
    Wait For Loading Overlay To Disappear
    Sleep    2s
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    SL_Trg2_${RE_SUFFIX}

TC_RE_003
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=SL_Trg3_${RE_SUFFIX}    category=${RE_CATEGORY}
    Click Next Tab
    Validate Tab 2 Ready
    Wait For Loading Overlay To Disappear
    Sleep    2s
    Fill Define Triggers Tab    rule_category_index=3
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    SL_Trg3_${RE_SUFFIX}

TC_RE_004
    Create Rule End To End
    ...    rule_name=FP_Trg1_${RE_SUFFIX}
    ...    category=${RE_CATEGORY_FRAUD}
    ...    rule_category_index=1

TC_RE_005
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=FP_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY_FRAUD}
    Click Next Tab
    Validate Tab 2 Ready
    Wait For Loading Overlay To Disappear
    Sleep    2s
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    FP_Trg2_${RE_SUFFIX}

TC_RE_006
    Create Rule End To End
    ...    rule_name=CC_Trg1_${RE_SUFFIX}
    ...    category=${RE_CATEGORY_COST}
    ...    rule_category_index=1

TC_RE_007
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=CC_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY_COST}
    Click Next Tab
    Validate Tab 2 Ready
    Wait For Loading Overlay To Disappear
    Sleep    2s
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    CC_Trg2_${RE_SUFFIX}

TC_RE_008
    Create Rule End To End
    ...    rule_name=OT_Trg1_${RE_SUFFIX}
    ...    category=${RE_CATEGORY_OTHER}
    ...    rule_category_index=1

TC_RE_009
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=OT_Trg2_${RE_SUFFIX}    category=${RE_CATEGORY_OTHER}
    Click Next Tab
    Validate Tab 2 Ready
    Wait For Loading Overlay To Disappear
    Sleep    2s
    Fill Define Triggers Tab    rule_category_index=2
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    OT_Trg2_${RE_SUFFIX}

TC_RE_009A
    Create Rules For All Rule Category Options    ${RE_CATEGORY}    name_prefix=AllSL

TC_RE_009B
    Create Rules For All Rule Category Options    ${RE_CATEGORY_FRAUD}    name_prefix=AllFP

TC_RE_009C
    Create Rules For All Rule Category Options    ${RE_CATEGORY_COST}    name_prefix=AllCC

TC_RE_009D
    Create Rules For All Rule Category Options    ${RE_CATEGORY_OTHER}    name_prefix=AllOT

TC_RE_009E
    Create Rules For All Category Action Combinations

TC_RE_010
    Navigate To Create Rule Page
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_011
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_012
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_013
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Sleep    1s
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_014
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_CUSTOMER_BTN}    ${LOC_RE_CUSTOMER_OPTIONS}    1
    ...    search_text=${RE_CUSTOMER_SEARCH_TEXT}    search_input_locator=${LOC_RE_CUSTOMER_SEARCH}
    Wait For Loading Overlay To Disappear
    # Uncheck All Device Plan so DP dropdown is enabled but leave DP unselected
    ${all_dp_checked}=    Execute Javascript
    ...    var el = document.getElementById('all_Device_Plan'); return el ? el.checked : false;
    IF    ${all_dp_checked}
        Unselect Checkbox    ${LOC_RE_ALL_DEVICE_PLAN}
        Sleep    1s
    END
    Click Next Tab
    Validate Wizard Stays On Tab 1

TC_RE_015
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 2
    Click Next Tab
    Validate Wizard Stays On Tab 2

TC_RE_016
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 2
    Wait For Loading Overlay To Disappear
    ${is_native}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_SELECT}    timeout=5s
    IF    ${is_native}
        Select From List By Index    ${LOC_RE_RULE_CATEGORY_SELECT}    1
    ELSE
        Select Custom Dropdown Option    ${LOC_RE_RULE_CATEGORY_BTN}    ${LOC_RE_RULE_CATEGORY_OPTIONS}    1
    END
    Sleep    1s
    Click Next Tab
    Validate Wizard Stays On Tab 2

TC_RE_017
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 3
    Click Next Tab
    Validate Wizard Stays On Tab 3

TC_RE_018
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 4
    Submit Rule
    Validate Wizard Stays On Tab 4

TC_RE_019
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 4
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s
    Select From List By Label    ${LOC_RE_ACTION_TYPE}    Email
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_RE_SAVE_ACTION_BTN}    timeout=10s
    Click Element    ${LOC_RE_SAVE_ACTION_BTN}
    Sleep    1s
    ${action_panel_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_ACTION_LIST_PANEL}
    Should Not Be True    ${action_panel_visible}
    ...    Email action should NOT be saved without recipients.

TC_RE_020
    Navigate To Create Rule Page
    Fill Tabs Up To Tab 4
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s
    Select From List By Label    ${LOC_RE_ACTION_TYPE}    ${RE_ACTION_RAISE_ALERT}
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_INPUT}    timeout=10s
    Input Text    ${LOC_RE_ALERT_EMAIL_INPUT}    ${RE_INVALID_EMAIL}
    Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    RETURN
    Sleep    1s
    ${tag_exists}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_ALERT_EMAIL_TAG}
    IF    ${tag_exists}
        Log    Tag was added — checking for error toast or inline error.    level=WARN
    END
    ${error_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TOAST_ERROR}    timeout=5s
    ${either_blocked}=    Evaluate    not ${tag_exists} or ${error_visible}
    Should Be True    ${either_blocked}
    ...    Invalid email should be blocked (no tag) or show an error toast.

TC_RE_021
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Click Close Wizard
    Validate Redirected To Rule Engine Listing

TC_RE_022
    Navigate To Create Rule Page
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=10s
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_LONG_RULE_NAME}
    ${actual_value}=    Get Element Attribute    ${LOC_RE_RULE_NAME}    value
    ${length}=    Get Length    ${actual_value}
    Should Be True    ${length} <= ${RE_RULE_NAME_MAX_LENGTH}
    ...    Rule Name field accepted ${length} chars — must be capped at ${RE_RULE_NAME_MAX_LENGTH}.
    Log    Rule Name capped at ${length} characters (max ${RE_RULE_NAME_MAX_LENGTH}).    console=yes

TC_RE_023
    Navigate To Create Rule Page
    Input Text    ${LOC_RE_RULE_NAME}    ${RE_RULE_NAME}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${RE_CATEGORY}
    Input Text    ${LOC_RE_DESCRIPTION}    ${RE_DESCRIPTION}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${RE_APP_LEVEL_EC}
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_CUSTOMER_BTN}    ${LOC_RE_CUSTOMER_OPTIONS}    1
    ...    search_text=${RE_CUSTOMER_SEARCH_TEXT}    search_input_locator=${LOC_RE_CUSTOMER_SEARCH}
    Wait For Loading Overlay To Disappear
    # Uncheck All DP first (it may be checked by default)
    ${all_dp_checked}=    Execute Javascript
    ...    var el = document.getElementById('all_Device_Plan'); return el ? el.checked : false;
    IF    ${all_dp_checked}
        Unselect Checkbox    ${LOC_RE_ALL_DEVICE_PLAN}
        Sleep    1s
    END
    Wait Until Element Is Enabled    ${LOC_RE_DEVICE_PLAN}    timeout=20s
    Select Checkbox    ${LOC_RE_ALL_DEVICE_PLAN}
    Sleep    1s
    Validate Device Plan Disabled
    Unselect Checkbox    ${LOC_RE_ALL_DEVICE_PLAN}
    Sleep    1s
    Element Should Be Enabled    ${LOC_RE_DEVICE_PLAN}
    Log    Device Plan correctly disabled when All DP checked, re-enabled when unchecked.    console=yes
