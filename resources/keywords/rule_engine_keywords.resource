*** Settings ***
Library     SeleniumLibrary
Library     Collections
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/rule_engine_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION
# ═══════════════════════════════════════════════════════════════════════

Navigate To Rule Engine Listing
    [Documentation]    Navigates to /RuleEngine listing page. No re-login (session from Suite Setup).
    ...                Waits for page and loading overlay to complete before returning.
    Go To    ${RE_RULE_ENGINE_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=30s
    Wait Until Element Is Visible    ${LOC_RE_CREATE_BTN}    timeout=15s
    Wait For Loading Overlay To Disappear

Navigate To Create Rule Page
    [Documentation]    Navigates directly to /CreateRuleEngine. No re-login (session from Suite Setup).
    ...                Waits for page and loading overlay to complete before returning.
    Go To    ${RE_CREATE_RULE_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=15s
    Wait For Loading Overlay To Disappear

Navigate To Rule Engine Via Sidebar
    [Documentation]    Clicks the Rule Engine link in the left sidebar navigation panel.
    Wait For Loading Overlay To Disappear
    ${primary_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_NAV_RULE_ENGINE}    timeout=5s
    IF    ${primary_visible}
        Click Element Via JS    ${LOC_RE_NAV_RULE_ENGINE}
    ELSE
        Wait Until Element Is Visible    ${LOC_RE_NAV_RULE_ENGINE_ALT}    timeout=10s
        Click Element Via JS    ${LOC_RE_NAV_RULE_ENGINE_ALT}
    END
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${RE_RULE_ENGINE_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_CREATE_BTN}    timeout=15s

Click Create Rule Button
    [Documentation]    Clicks the Create Rule button on the Rule Engine listing page.
    Wait Until Element Is Visible    ${LOC_RE_CREATE_BTN}    timeout=15s
    Click Element Via JS    ${LOC_RE_CREATE_BTN}
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${RE_CREATE_RULE_PATH}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=15s

# ═══════════════════════════════════════════════════════════════════════
#  TAB 1 — PRIMARY DETAILS
# ═══════════════════════════════════════════════════════════════════════

Fill Primary Details Tab
    [Documentation]    Fills all mandatory fields on Tab 1 (Primary Details).
    ...                Field order matters: App Level -> Customer -> BU (conditional) -> Device Plan.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}
    ...            ${description}=${RE_DESCRIPTION}    ${app_level}=${RE_APP_LEVEL_EC}
    ...            ${customer_index}=1    ${bu_index}=1    ${device_plan_index}=1
    Wait Until Element Is Visible    ${LOC_RE_RULE_NAME}    timeout=10s
    Input Text    ${LOC_RE_RULE_NAME}    ${rule_name}
    Select From List By Value    ${LOC_RE_CATEGORY}    ${category}
    Input Text    ${LOC_RE_DESCRIPTION}    ${description}
    Select From List By Value    ${LOC_RE_APP_LEVEL}    ${app_level}
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_CUSTOMER_BTN}    ${LOC_RE_CUSTOMER_OPTIONS}    ${customer_index}
    ...    search_text=${RE_CUSTOMER_SEARCH_TEXT}    search_input_locator=${LOC_RE_CUSTOMER_SEARCH}
    Wait For Loading Overlay To Disappear
    IF    '${app_level}' != 'EC'
        Wait And Select BU    ${bu_index}
    END
    # If "All Device Plan" is checked, DP select is disabled — skip selection
    ${all_dp_checked}=    Execute Javascript
    ...    var el = document.getElementById('all_Device_Plan');
    ...    return el ? el.checked : false;
    IF    ${all_dp_checked}
        Log    All Device Plan is checked — skipping Device Plan selection.    console=yes
    ELSE
        Wait Until Element Is Enabled    ${LOC_RE_DEVICE_PLAN}    timeout=20s
        ${dp_count}=    Get Element Count    ${LOC_RE_DEVICE_PLAN_OPTIONS}
        Should Be True    ${dp_count} > 0
        ...    Device Plan dropdown has no options after account resolution.
        Select From List By Index    ${LOC_RE_DEVICE_PLAN}    ${device_plan_index}
    END

Wait And Select BU
    [Documentation]    Waits for BU dropdown to populate, then searches and selects by index.
    [Arguments]    ${bu_index}=1
    Wait For Loading Overlay To Disappear
    Select Custom Dropdown Option    ${LOC_RE_BU_BTN}    ${LOC_RE_BU_OPTIONS}    ${bu_index}
    ...    search_text=${RE_BU_SEARCH_TEXT}    search_input_locator=${LOC_RE_BU_SEARCH}
    Wait For Loading Overlay To Disappear

Select Custom Dropdown Option
    [Documentation]    Interacts with a custom div-based dropdown. Clicks the selectBtn to
    ...                open the dropdown, optionally types search text, waits for options, clicks.
    [Arguments]    ${btn_locator}    ${options_locator}    ${index}=1
    ...            ${search_text}=${EMPTY}    ${search_input_locator}=${EMPTY}
    ...            ${extra_sleep_after_open}=0
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${btn_locator}    timeout=15s
    # Click the dropdown button to open it
    ${btn_el}=    Get WebElement    ${btn_locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn_el}
    Sleep    1s
    IF    ${extra_sleep_after_open} > 0
        Sleep    ${extra_sleep_after_open}s
        Wait For Loading Overlay To Disappear
    END
    IF    "${search_text}" != "${EMPTY}" and "${search_input_locator}" != "${EMPTY}"
        # Search input becomes visible after opening — type to trigger API search
        Wait Until Element Is Visible    ${search_input_locator}    timeout=10s
        Clear Element Text    ${search_input_locator}
        Input Text    ${search_input_locator}    ${search_text}
        Log    Typed "${search_text}" in custom dropdown search.    console=yes
        Sleep    2s
    END
    Wait Until Keyword Succeeds    10x    3s
    ...    Custom Dropdown Should Have Options    ${options_locator}
    ${all_options}=    Get WebElements    ${options_locator}
    ${target_index}=    Evaluate    ${index} - 1
    ${option_el}=    Set Variable    ${all_options}[${target_index}]
    ${option_text}=    Get Text    ${option_el}
    Log    Selecting custom dropdown option [${index}]: ${option_text}    console=yes
    Execute Javascript    arguments[0].scrollIntoView({block:'center'}); arguments[0].click();    ARGUMENTS    ${option_el}
    Sleep    1s

Custom Dropdown Should Have Options
    [Documentation]    Asserts that a custom dropdown has at least one non-placeholder option.
    [Arguments]    ${options_locator}
    ${count}=    Get Element Count    ${options_locator}
    Should Be True    ${count} > 0
    ...    Custom dropdown has no selectable options (still loading or Not Found).

# ═══════════════════════════════════════════════════════════════════════
#  TAB 2 — DEFINE TRIGGERS
# ═══════════════════════════════════════════════════════════════════════

Fill Define Triggers Tab
    [Documentation]    Selects a Rule Category by index (1-based, first real option = 1), fills required trigger fields, and saves.
    ...                Rule Category may be a native select or a custom div dropdown.
    [Arguments]    ${rule_category_index}=1
    Wait For Loading Overlay To Disappear
    ${is_native}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_SELECT}    timeout=5s
    IF    ${is_native}
        # Native select often has a placeholder as first option; select by value of the Nth real option
        ${option_value}=    Get Rule Category Option Value By Index    ${rule_category_index}
        Select From List By Value    ${LOC_RE_RULE_CATEGORY_SELECT}    ${option_value}
    ELSE
        # Custom dropdown: wait longer for options to load after opening, then select by index
        Select Custom Dropdown Option    ${LOC_RE_RULE_CATEGORY_BTN}    ${LOC_RE_RULE_CATEGORY_OPTIONS}    ${rule_category_index}
        ...    extra_sleep_after_open=2
    END
    Sleep    2s
    Wait For Loading Overlay To Disappear
    Fill Trigger Form Fields
    Save First Available Trigger

Get Rule Category Option Count
    [Documentation]    Returns the number of available Rule Category options (native or custom).
    ${is_native}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_SELECT}    timeout=5s
    IF    ${is_native}
        ${count}=    Get Element Count    xpath=//select[@data-testid='ruleCategory']/option[not(@value='') and not(@value='selectRuleCategory')]
    ELSE
        Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_BTN}    timeout=10s
        ${btn_el}=    Get WebElement    ${LOC_RE_RULE_CATEGORY_BTN}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn_el}
        Sleep    2s
        ${count}=    Get Element Count    ${LOC_RE_RULE_CATEGORY_OPTIONS}
        Press Keys    None    ESCAPE
        Sleep    0.5s
    END
    RETURN    ${count}

Get Rule Category Option Text
    [Documentation]    Returns the text of the Rule Category option at the given 1-based index.
    [Arguments]    ${index}=1
    ${is_native}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_SELECT}    timeout=3s
    IF    ${is_native}
        ${options}=    Get WebElements    xpath=//select[@data-testid='ruleCategory']/option[not(@value='') and not(@value='selectRuleCategory')]
        ${target}=    Evaluate    ${index} - 1
        ${text}=    Get Text    ${options}[${target}]
    ELSE
        Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_BTN}    timeout=10s
        ${btn_el}=    Get WebElement    ${LOC_RE_RULE_CATEGORY_BTN}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn_el}
        Sleep    2s
        ${options}=    Get WebElements    ${LOC_RE_RULE_CATEGORY_OPTIONS}
        ${target}=    Evaluate    ${index} - 1
        ${text}=    Get Text    ${options}[${target}]
        Press Keys    None    ESCAPE
        Sleep    0.5s
    END
    RETURN    ${text}

Get Rule Category Option Value By Index
    [Documentation]    Returns the value attribute of the Rule Category option at the given 1-based index (native select only).
    [Arguments]    ${index}=1
    Wait Until Element Is Visible    ${LOC_RE_RULE_CATEGORY_SELECT}    timeout=10s
    ${options}=    Get WebElements    xpath=//select[@data-testid='ruleCategory']/option[not(@value='') and not(@value='selectRuleCategory')]
    ${target}=    Evaluate    ${index} - 1
    ${value}=    Get Element Attribute    ${options}[${target}]    value
    RETURN    ${value}

Fill Trigger Form Fields
    [Documentation]    Fills any required trigger sub-form fields visible on Tab 2.
    ...                Selects "Select Trigger: If" / default condition first when visible (avoids "Please Select a Default Condition"),
    ...                then comparator and condition value if present.
    ...                Tries multiple locators for fields that vary by Rule Category.
    # "Select Trigger: If" / "Select Condition" — required for some Rule Categories (e.g. Country or Operator change); avoids "Please Select a Default Condition"
    ${default_condition_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TRIGGER_DEFAULT_CONDITION}    timeout=5s
    IF    ${default_condition_visible}
        # Get options only from the same select (the one with "Select Condition" placeholder) to avoid wrong value from another dropdown
        ${opts}=    Get WebElements    xpath=//div[@id='defineTriggersTab']//select[not(@data-testid='ruleCategory') and not(@data-testid='conditionalssd') and .//option[contains(normalize-space(text()),'Select Condition')]]/option[not(@value='') and normalize-space(text())!='Select Condition']
        ${opt_count}=    Get Length    ${opts}
        IF    ${opt_count} > 0
            ${first_val}=    Get Element Attribute    ${opts}[0]    value
            Select From List By Value    ${LOC_RE_TRIGGER_DEFAULT_CONDITION}    ${first_val}
            Log    Selected default condition (Select Trigger: If): ${first_val}    console=yes
            Sleep    1s
            Wait For Loading Overlay To Disappear
        END
    END
    ${comparator_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TRIGGER_COMPARATOR}    timeout=5s
    IF    ${comparator_visible}
        ${opt_count}=    Get Element Count    xpath=//select[@data-testid='conditionalssd']/option[not(@value='')]
        IF    ${opt_count} > 0
            Select From List By Index    ${LOC_RE_TRIGGER_COMPARATOR}    1
            Sleep    1s
        END
    END
    ${condition_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TRIGGER_CONDITION_VALUE}    timeout=5s
    IF    not ${condition_visible}
        ${condition_visible}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_RE_TRIGGER_CONDITION_VALUE_ALT}    timeout=3s
        IF    ${condition_visible}
            Clear Element Text    ${LOC_RE_TRIGGER_CONDITION_VALUE_ALT}
            Input Text    ${LOC_RE_TRIGGER_CONDITION_VALUE_ALT}    100
            Log    Entered trigger condition value (alt locator): 100    console=yes
        END
    ELSE
        Clear Element Text    ${LOC_RE_TRIGGER_CONDITION_VALUE}
        Input Text    ${LOC_RE_TRIGGER_CONDITION_VALUE}    100
        Log    Entered trigger condition value: 100    console=yes
    END

Save First Available Trigger
    [Documentation]    Clicks the Save Trigger / Add Trigger button. Tries main locator first.
    ${btn_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_TRIGGER_SAVE_BTN}    timeout=5s
    IF    ${btn_visible}
        ${btn_el}=    Get WebElement    ${LOC_RE_TRIGGER_SAVE_BTN}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn_el}
        Log    Clicked Save Trigger button.    console=yes
        Sleep    2s
        Wait For Loading Overlay To Disappear
    ELSE
        Log    No Save Trigger button found — category may auto-save.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  TAB 3 — ASSIGN DEVICES
# ═══════════════════════════════════════════════════════════════════════

Fill Assign Devices Tab
    [Documentation]    Selects Aggregation Level (first non-placeholder option). Handles conditional Rest Period.
    [Arguments]    ${aggregation_index}=1
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_AGGREGATION}    timeout=15s
    # Wait for aggregation options to be populated by API
    Wait Until Keyword Succeeds    5x    3s
    ...    Aggregation Should Have Options
    Select From List By Index    ${LOC_RE_AGGREGATION}    ${aggregation_index}
    Sleep    1s
    ${rest_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_REST_PERIOD}
    IF    ${rest_visible}
        Select From List By Index    ${LOC_RE_REST_PERIOD}    1
    END

Aggregation Should Have Options
    [Documentation]    Asserts that the Aggregation Level dropdown has at least one selectable option.
    ${count}=    Get Element Count    xpath=//select[@data-testid='aggregationLevel']/option[not(@value='') and not(@value='0')]
    Should Be True    ${count} > 0
    ...    Aggregation Level dropdown has no options yet.

# ═══════════════════════════════════════════════════════════════════════
#  TAB 4 — ACTION
# ═══════════════════════════════════════════════════════════════════════

Get Action Type Option Count
    [Documentation]    Returns the number of selectable Action Type options on Tab 4 (excludes placeholder).
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=10s
    ${count}=    Get Element Count    xpath=//select[@data-testid='racactionType']/option[normalize-space(@value)!='' and normalize-space(text())!='']
    RETURN    ${count}

Get Action Type Option Label
    [Documentation]    Returns the label of the Action Type option at the given 1-based index.
    [Arguments]    ${index}=1
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=10s
    ${options}=    Get WebElements    xpath=//select[@data-testid='racactionType']/option[normalize-space(@value)!='' and normalize-space(text())!='']
    ${target}=    Evaluate    ${index} - 1
    ${text}=    Get Text    ${options}[${target}]
    RETURN    ${text}

Fill Action Tab And Save
    [Documentation]    Selects Action Type, fills action fields, clicks Save Action.
    [Arguments]    ${action_label}=${RE_ACTION_RAISE_ALERT}
    ...            ${alert_email}=${RE_ALERT_EMAIL}
    ...            ${alert_desc}=${RE_ALERT_DESC}
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s
    Select From List By Label    ${LOC_RE_ACTION_TYPE}    ${action_label}
    Sleep    1s
    IF    '${action_label}' == 'Raise Alert in Web GUI'
        Fill Raise Alert In Web GUI Action    ${alert_email}    ${alert_desc}
    ELSE IF    '${action_label}' == 'Email'
        Fill Email Action    ${alert_email}
    ELSE
        Log    Action type "${action_label}" — no specific fields; attempting Save.    console=yes
    END
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_SAVE_ACTION_BTN}    timeout=10s
    ${save_btn}=    Get WebElement    ${LOC_RE_SAVE_ACTION_BTN}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    Wait For Loading Overlay To Disappear

Fill Email Action
    [Documentation]    Fills Email action: adds one recipient in the To/ReactTags input.
    [Arguments]    ${email}=${RE_ALERT_EMAIL}
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_INPUT}    timeout=8s
    IF    ${input_visible}
        Input Text    ${LOC_RE_ALERT_EMAIL_INPUT}    ${email}
        Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    RETURN
        Sleep    1s
        Log    Added Email recipient: ${email}    console=yes
    ELSE
        Log    Email To input not found — form may differ; trying Save anyway.    level=WARN
    END

Fill Raise Alert In Web GUI Action
    [Documentation]    Fills Raise Alert fields: email via ReactTags + description.
    [Arguments]    ${alert_email}=${RE_ALERT_EMAIL}    ${alert_desc}=${RE_ALERT_DESC}
    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_INPUT}    timeout=10s
    Input Text    ${LOC_RE_ALERT_EMAIL_INPUT}    ${alert_email}
    Press Keys    ${LOC_RE_ALERT_EMAIL_INPUT}    RETURN
    Wait Until Element Is Visible    ${LOC_RE_ALERT_EMAIL_TAG}    timeout=10s
    Wait Until Element Is Visible    ${LOC_RE_ALERT_DESC}    timeout=5s
    Input Text    ${LOC_RE_ALERT_DESC}    ${alert_desc}

# ═══════════════════════════════════════════════════════════════════════
#  WIZARD NAVIGATION
# ═══════════════════════════════════════════════════════════════════════

Click Next Tab
    [Documentation]    Clicks the Next button to advance to the next wizard tab.
    ...                Waits for loading to complete before and after click.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_NEXT_BTN}    timeout=10s
    Click Element Via JS    ${LOC_RE_NEXT_BTN}
    Sleep    2s
    Wait For Loading Overlay To Disappear

Click Previous Tab
    [Documentation]    Clicks the Previous button to go back to the prior tab.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_PREVIOUS_BTN}    timeout=10s
    Click Element Via JS    ${LOC_RE_PREVIOUS_BTN}
    Sleep    1s
    Wait For Loading Overlay To Disappear

Submit Rule
    [Documentation]    Clicks the Submit button on Tab 4. Uses JS to find the visible Submit-like button.
    ...                Waits for loading to complete before click and after submit (redirect/toast).
    Wait For Loading Overlay To Disappear
    Sleep    1s
    # The Submit button on Tab 4 replaces the Next button.
    # Try to find it by value='Submit' first, then fallback to class-based.
    ${submit_found}=    Execute Javascript
    ...    var btns = document.querySelectorAll('input[type="button"], button');
    ...    for (var i = 0; i < btns.length; i++) {
    ...        var b = btns[i];
    ...        var val = (b.value || b.textContent || '').trim();
    ...        if (b.offsetParent !== null && val.toLowerCase() === 'submit') {
    ...            b.click();
    ...            return 'clicked: ' + val;
    ...        }
    ...    }
    ...    return 'not_found';
    Log    Submit button result: ${submit_found}    console=yes
    IF    "${submit_found}" == "not_found"
        # Fallback — click via locator
        Wait Until Element Is Visible    ${LOC_RE_SUBMIT_BTN}    timeout=10s
        Click Element Via JS    ${LOC_RE_SUBMIT_BTN}
    END
    Sleep    2s
    Wait For Loading Overlay To Disappear

Click Close Wizard
    [Documentation]    Clicks the Close/Cancel button to exit the wizard.
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${LOC_RE_CLOSE_BTN}    timeout=10s
    Click Element Via JS    ${LOC_RE_CLOSE_BTN}
    Wait For Loading Overlay To Disappear

# ═══════════════════════════════════════════════════════════════════════
#  HELPER — FILL TABS UP TO N (for negative tests)
# ═══════════════════════════════════════════════════════════════════════

Fill Tabs Up To Tab 2
    [Documentation]    Fills Tab 1 with defaults and clicks Next to arrive at Tab 2.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}
    Fill Primary Details Tab    rule_name=${rule_name}    category=${category}
    Click Next Tab
    Wait For Loading Overlay To Disappear
    Sleep    2s

Fill Tabs Up To Tab 3
    [Documentation]    Fills Tabs 1-2 and clicks Next to arrive at Tab 3.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}    ${rule_category_index}=1
    Fill Tabs Up To Tab 2    rule_name=${rule_name}    category=${category}
    Fill Define Triggers Tab    rule_category_index=${rule_category_index}
    Click Next Tab
    Wait Until Element Is Visible    ${LOC_RE_AGGREGATION}    timeout=15s

Fill Tabs Up To Tab 4
    [Documentation]    Fills Tabs 1-3 and clicks Next to arrive at Tab 4.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}    ${rule_category_index}=1
    Fill Tabs Up To Tab 3    rule_name=${rule_name}    category=${category}    rule_category_index=${rule_category_index}
    Fill Assign Devices Tab
    Click Next Tab
    Wait Until Element Is Visible    ${LOC_RE_ACTION_TYPE}    timeout=15s

Create Rule End To End
    [Documentation]    Full E2E: navigate → fill all 4 tabs → save action → submit → validate at each step.
    ...                Accepts category and trigger index to support all trigger options.
    [Arguments]    ${rule_name}=${RE_RULE_NAME}    ${category}=${RE_CATEGORY}
    ...            ${rule_category_index}=1
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=${rule_name}    category=${category}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=${rule_category_index}
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    ${rule_name}

Create Rules For All Rule Category Options
    [Documentation]    Define Triggers tab: creates one rule per Rule Category dropdown option.
    ...                Tab 1 category (SIM Lifecycle/Fraud/Cost/Others) is given; on Tab 2 the
    ...                Rule Category options are counted and a full rule is created for each (unique name per rule).
    [Arguments]    ${category}    ${name_prefix}=All
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=${name_prefix}_1_${RE_SUFFIX}    category=${category}
    Click Next Tab
    Validate Tab 2 Ready
    Wait For Loading Overlay To Disappear
    Sleep    2s
    ${count}=    Get Rule Category Option Count
    Log    Rule Category has ${count} option(s) for category ${category}. Creating ${count} rules.    console=yes
    ${end}=    Evaluate    ${count} + 1
    FOR    ${i}    IN RANGE    1    ${end}
        ${option_text}=    Get Rule Category Option Text    ${i}
        Log    Creating rule ${i}/${count}: Rule Category "${option_text}"    console=yes
        IF    ${i} > 1
            Click Create Rule Button
            Fill Primary Details Tab    rule_name=${name_prefix}_${i}_${RE_SUFFIX}    category=${category}
            Click Next Tab
            Validate Tab 2 Ready
            Wait For Loading Overlay To Disappear
            Sleep    2s
        END
        Fill Define Triggers Tab    rule_category_index=${i}
        Click Next Tab
        Validate Tab 3 Ready
        Fill Assign Devices Tab
        Click Next Tab
        Validate Tab 4 Ready
        Fill Action Tab And Save
        Validate Action Saved In List
        Submit Rule
        Validate Rule Created Successfully    ${name_prefix}_${i}_${RE_SUFFIX}
    END

Create Rule With Category And Action
    [Documentation]    Creates one rule with given Primary category and Action tab action type (trigger index 1). Validates each step.
    [Arguments]    ${rule_name}    ${category}    ${action_label}
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=${rule_name}    category=${category}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=1
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    Fill Action Tab And Save    action_label=${action_label}
    Validate Action Saved In List
    Submit Rule
    Validate Rule Created Successfully    ${rule_name}

Create Rules For All Category Action Combinations
    [Documentation]    Primary page category × Action page action: creates one rule per (category, action) combination.
    ...                Categories: SIM Lifecycle, Fraud Prevention, Cost Control, Others. Actions: from Tab 4 dropdown.
    @{categories}=    Create List    ${RE_CATEGORY}    ${RE_CATEGORY_FRAUD}    ${RE_CATEGORY_COST}    ${RE_CATEGORY_OTHER}
    Navigate To Rule Engine Listing
    Click Create Rule Button
    Fill Primary Details Tab    rule_name=Combo_1_${RE_SUFFIX}    category=${RE_CATEGORY}
    Click Next Tab
    Validate Tab 2 Ready
    Fill Define Triggers Tab    rule_category_index=1
    Click Next Tab
    Validate Tab 3 Ready
    Fill Assign Devices Tab
    Click Next Tab
    Validate Tab 4 Ready
    ${action_count}=    Get Action Type Option Count
    @{action_labels}=    Create List
    FOR    ${idx}    IN RANGE    1    ${action_count + 1}
        ${label}=    Get Action Type Option Label    ${idx}
        Append To List    ${action_labels}    ${label}
    END
    ${total}=    Evaluate    4 * ${action_count}
    Log    Categories: ${categories}; Actions: ${action_labels}. Creating ${total} rules.    console=yes
    ${combo_idx}=    Set Variable    0
    FOR    ${cat}    IN    @{categories}
        FOR    ${action_label}    IN    @{action_labels}
            ${combo_idx}=    Evaluate    ${combo_idx} + 1
            ${rule_name}=    Set Variable    Combo_${combo_idx}_${RE_SUFFIX}
            Log    Creating rule ${combo_idx}/${total}: category=${cat}, action=${action_label}    console=yes
            IF    ${combo_idx} == 1
                Fill Action Tab And Save    action_label=${action_label}
                Validate Action Saved In List
                Submit Rule
                Validate Rule Created Successfully    Combo_1_${RE_SUFFIX}
            ELSE
                Create Rule With Category And Action    rule_name=${rule_name}    category=${cat}    action_label=${action_label}
            END
        END
    END

# ═══════════════════════════════════════════════════════════════════════
#  VALIDATION
# ═══════════════════════════════════════════════════════════════════════

Validate Tab 2 Ready
    [Documentation]    Asserts Define Triggers tab is visible (Rule Category dropdown present).
    Wait For Loading Overlay To Disappear
    Sleep    1s
    ${native}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_RE_RULE_CATEGORY_SELECT}
    IF    not ${native}    Element Should Be Visible    ${LOC_RE_RULE_CATEGORY_BTN}
    Log    Tab 2 (Define Triggers) ready.    console=yes

Validate Tab 3 Ready
    [Documentation]    Asserts Assign Devices tab is visible (Aggregation dropdown present).
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Element Should Be Visible    ${LOC_RE_AGGREGATION}
    Log    Tab 3 (Assign Devices) ready.    console=yes

Validate Tab 4 Ready
    [Documentation]    Asserts Action tab is visible (Action Type dropdown present).
    Wait For Loading Overlay To Disappear
    Sleep    1s
    Element Should Be Visible    ${LOC_RE_ACTION_TYPE}
    Log    Tab 4 (Action) ready.    console=yes

Validate Rule Created Successfully
    [Documentation]    Verifies: success toast (wait up to 30s), URL on Rule Engine listing,
    ...                grid visible, rule name visible in grid rule name column. Fails if success message not shown.
    [Arguments]    ${rule_name}=${EMPTY}
    Wait Until Element Is Visible    ${LOC_RE_TOAST_SUCCESS}    timeout=30s
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${RE_RULE_ENGINE_PATH}
    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=15s
    IF    "${rule_name}" != "${EMPTY}"
        ${safe_name}=    Replace String    ${rule_name}    '    ''     # escape single quote for xpath
        Wait Until Element Is Visible    xpath=//div[@id='gridData']//*[contains(normalize-space(.),'${safe_name}')]    timeout=15s
        Log    Rule name "${rule_name}" visible in listing grid.    console=yes
    END
    Log    Rule created successfully — toast shown, redirected to listing, rule in grid.    console=yes

Validate Wizard Stays On Tab 1
    [Documentation]    Asserts the wizard did NOT advance past Tab 1.
    Sleep    1s
    Element Should Be Visible    ${LOC_RE_RULE_NAME}
    ${on_create_page}=    Run Keyword And Return Status
    ...    Location Should Contain    ${RE_CREATE_RULE_PATH}
    Should Be True    ${on_create_page}    Expected to remain on Create Rule page.

Validate Wizard Stays On Tab 2
    [Documentation]    Asserts the wizard remains on Tab 2 (Define Triggers).
    Sleep    1s
    ${native}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_RE_RULE_CATEGORY_SELECT}
    IF    not ${native}
        Element Should Be Visible    ${LOC_RE_RULE_CATEGORY_BTN}
    END

Validate Wizard Stays On Tab 3
    [Documentation]    Asserts the wizard remains on Tab 3 (Assign Devices).
    Sleep    1s
    Element Should Be Visible    ${LOC_RE_AGGREGATION}

Validate Wizard Stays On Tab 4
    [Documentation]    Asserts the wizard remains on Tab 4 (Action).
    Sleep    1s
    Element Should Be Visible    ${LOC_RE_ACTION_TYPE}

Validate Tab 1 Fields Visible
    [Documentation]    Asserts all mandatory Tab 1 fields are present on the page.
    Element Should Be Visible    ${LOC_RE_RULE_NAME}
    Element Should Be Visible    ${LOC_RE_CATEGORY}
    Element Should Be Visible    ${LOC_RE_DESCRIPTION}
    Element Should Be Visible    ${LOC_RE_APP_LEVEL}
    Element Should Be Visible    ${LOC_RE_NEXT_BTN}
    Element Should Be Visible    ${LOC_RE_CLOSE_BTN}

Validate Device Plan Options Loaded
    [Documentation]    Asserts Device Plan dropdown has at least one selectable option.
    ${count}=    Get Element Count    ${LOC_RE_DEVICE_PLAN_OPTIONS}
    Should Be True    ${count} > 0
    ...    Device Plan dropdown must have options after account resolution.

Validate Rule Category Options Loaded
    [Documentation]    Asserts Rule Category dropdown has at least one option from API.
    ${is_native}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_RULE_CATEGORY_SELECT}
    IF    ${is_native}
        ${count}=    Get Element Count    xpath=//select[@data-testid='ruleCategory']/option[not(@value='') and not(@value='selectRuleCategory')]
        Should Be True    ${count} > 0
        ...    Rule Category dropdown must have options from API.
    ELSE
        Custom Dropdown Should Have Options    ${LOC_RE_RULE_CATEGORY_OPTIONS}
    END

Validate Action Saved In List
    [Documentation]    Asserts at least one action is saved in the action panel.
    ...                If expected_text is given, page must contain it; else checks panel has saved entry (Raise Alert/Email/SMS text or panel visible).
    [Arguments]    ${expected_text}=${EMPTY}
    Sleep    1s
    IF    "${expected_text}" != "${EMPTY}"
        Page Should Contain    ${expected_text}
        Log    Action saved and visible (found: ${expected_text}).    console=yes
    ELSE
        ${has_email}=    Run Keyword And Return Status    Page Should Contain    ${RE_ALERT_EMAIL}
        IF    ${has_email}
            Log    Action saved and visible (found ${RE_ALERT_EMAIL}).    console=yes
        ELSE
            ${has_panel}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_RE_ACTION_LIST_PANEL}
            ${has_saved}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_RE_SAVED_ACTION_ENTRY}
            Should Be True    ${has_panel} or ${has_saved}
            ...    No saved action found: expected email text, action list panel, or saved action entry.
            Log    Action saved and visible (panel or saved entry).    console=yes
        END
    END

Validate Device Plan Disabled
    [Documentation]    Asserts the Device Plan dropdown is disabled.
    Element Should Be Disabled    ${LOC_RE_DEVICE_PLAN}

Validate Previous Button Not Visible On Tab 1
    [Documentation]    Previous button should not exist in DOM when Tab 1 is active.
    ${visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${LOC_RE_PREVIOUS_BTN}
    Should Not Be True    ${visible}
    ...    Previous button should be hidden on Tab 1.

Validate Redirected To Rule Engine Listing
    [Documentation]    Asserts browser navigated back to /RuleEngine listing.
    Wait Until Keyword Succeeds    3x    5s
    ...    Location Should Contain    ${RE_RULE_ENGINE_PATH}
    Wait Until Element Is Visible    ${LOC_RE_LISTING_GRID}    timeout=15s
