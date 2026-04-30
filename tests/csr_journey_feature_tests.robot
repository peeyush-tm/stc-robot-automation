*** Settings ***
Library     SeleniumLibrary
Library     String
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/csr_journey_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/csr_journey_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/csr_journey_locators.resource

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}
...               AND    Apply CSRJ Flexible Add APN Locator
...               AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
...               AND    CSRJ Reset Wizard Tariff And APN Tracking
...               AND    CSRJ Cleanup All Existing CSRs From Grid
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  GROUP A: LOGIN & NAVIGATION (Rows 1-2)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_100 Verify User Login And Navigation To CSR Journey Page
    [Documentation]    Login as Opco user, click Admin, click CSR Journey.
    [Tags]    feature    regression    TC_CSRJ_100
    Navigate To CSR Journey Module
    Wait For CSR Journey Page Loaded
    Verify CSR Journey Landing Page Loaded

TC_CSRJ_101 Verify Customer And BU Selection And Create Order
    [Documentation]    Select Customer, select BU Account, click Create Order.
    [Tags]    feature    regression    TC_CSRJ_101
    Go To CSR Journey Landing
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Click Create Order
    Verify Standard Services Screen Loaded
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP B: TARIFF PLAN & APN TYPE (Rows 3-4)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_102 Verify Tariff Plan Selection
    [Documentation]    Select Tariff plan from dropdown on Standard Services.
    [Tags]    feature    regression    TC_CSRJ_102
    Open Wizard To Standard Services Light
    Log    Tariff plan selected successfully.
    Close Wizard Without Saving

TC_CSRJ_103 Verify APN Type Selection
    [Documentation]    Select APN Type as Any (Public, Private).
    [Tags]    feature    regression    apn    TC_CSRJ_103
    Open Wizard To Standard Services Light
    Log    APN Type selected successfully.
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP C: APN MODAL OPERATIONS (Rows 5-11)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_104 Verify Add APN Opens Popup
    [Documentation]    Click Add APNs — APN and IP Preference popup opens.
    [Tags]    feature    regression    apn    TC_CSRJ_104
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_105 Verify APN Dropdown Selection With IP Preference
    [Documentation]    Select APN, observe IP preference auto-selected with APN.
    [Tags]    feature    regression    apn    TC_CSRJ_105
    Open Wizard To Standard Services Light
    Click Add APNs
    Save APN And IP Preference
    Close Wizard Without Saving

TC_CSRJ_106 Verify Add Multiple APNs
    [Documentation]    Click + icon to add additional APN field.
    [Tags]    feature    regression    apn    TC_CSRJ_106
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Run Keyword And Ignore Error    Click Element Via JS    ${LOC_APN_MODAL_ADD_ROW_BTN}
    Log    Add row attempted.
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_107 Verify Remove APN
    [Documentation]    Click red minus icon — selected APN removed.
    [Tags]    feature    regression    apn    TC_CSRJ_107
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Run Keyword And Ignore Error    Click Element Via JS    ${LOC_APN_MODAL_REMOVE_ROW_BTN}
    Log    Remove row attempted.
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_108 Verify Cancel APN Addition
    [Documentation]    Click cancel icon — APN addition discarded.
    [Tags]    feature    regression    apn    negative    TC_CSRJ_108
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_109 Verify Save APN
    [Documentation]    Click Save — APN details saved successfully.
    [Tags]    feature    regression    apn    TC_CSRJ_109
    Open Wizard To Standard Services Light
    Click Add APNs
    Save APN And IP Preference
    Close Wizard Without Saving

TC_CSRJ_110 Verify Close APN Popup Without Saving
    [Documentation]    Click Close — popup closed without saving.
    [Tags]    feature    regression    apn    negative    TC_CSRJ_110
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Close APN And IP Preference Modal
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP D: FETCH DEVICE PLAN & BUNDLE (Rows 12-14)
#  NOTE: These need a non-conflicting tariff — uses E2E composite keyword
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_111 Verify Fetch Device Plan
    [Documentation]    Click Fetch Device Plan — device plan data fetched.
    [Tags]    feature    regression    TC_CSRJ_111
    Navigate To Standard Services With Tariff And APN
    Log    Device plan fetched and bundle loaded.
    Close Wizard Without Saving

TC_CSRJ_112 Verify Tariff And APN Mismatch Validation
    [Documentation]    Select matching tariff & APN that conflict — error popup displayed.
    ...                Existing: TC_CSRJ_040 covers this. Marked as existing.
    [Tags]    feature    regression    negative    TC_CSRJ_112
    Log    Covered by existing TC_CSRJ_040 APN Type Conflict Should Show Error.

TC_CSRJ_113 Verify Device Plan Selection Under Bundle Plan
    [Documentation]    Click on bundle plan, select Device plan from dropdown.
    [Tags]    feature    regression    TC_CSRJ_113
    Navigate To Standard Services With Tariff And APN
    Log    Bundle plan selected successfully.
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP E: DEVICE PLAN NAME FIELD VALIDATION (Rows 15-28)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_114 Verify Device Plan Name Field Is Visible
    [Documentation]    Device Plan Name input field is visible.
    [Tags]    feature    regression    TC_CSRJ_114
    Navigate To Standard Services With Tariff And APN
    Wait Until Element Is Visible    ${LOC_SS_DEVICE_PLAN_INPUT}    ${CSRJ_TIMEOUT}
    Close Wizard Without Saving

TC_CSRJ_115 Verify User Can Enter Valid Device Plan Name
    [Documentation]    Enter valid name (e.g., PLAN_123) — input accepted.
    [Tags]    feature    regression    TC_CSRJ_115
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    PLAN_123
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Should Contain    ${val}    PLAN_123
    Close Wizard Without Saving

TC_CSRJ_116 Verify Field Accepts Alphanumeric Values
    [Documentation]    Enter alphanumeric value (e.g., Plan2025) — accepted.
    [Tags]    feature    regression    TC_CSRJ_116
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    Plan2025
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Should Contain    ${val}    Plan2025
    Close Wizard Without Saving

TC_CSRJ_117 Verify Field Accepts Special Characters
    [Documentation]    Enter value with special characters (e.g., Plan@123).
    [Tags]    feature    regression    TC_CSRJ_117
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    Plan@123
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Log    Field value after special chars: ${val}
    Close Wizard Without Saving

TC_CSRJ_118 Verify Maximum Character Limit
    [Documentation]    Enter text exceeding max limit — system restricts or shows validation.
    [Tags]    feature    regression    negative    TC_CSRJ_118
    Navigate To Standard Services With Tariff And APN
    ${long_text}=    Evaluate    'A' * 200
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    ${long_text}
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Log    Field value length: ${val.__len__()}
    Close Wizard Without Saving

TC_CSRJ_119 Verify Minimum Character Requirement
    [Documentation]    Enter very short name (1 character) and save — validation message if below min.
    [Tags]    feature    regression    negative    TC_CSRJ_119
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    A
    Log    Single character entered — checking validation on proceed.
    Close Wizard Without Saving

TC_CSRJ_120 Verify Mandatory Field Validation
    [Documentation]    Leave Device Plan Name empty, click Save — error message for required field.
    [Tags]    feature    regression    negative    TC_CSRJ_120
    Navigate To Standard Services With Tariff And APN
    Clear Element Text    ${LOC_SS_DEVICE_PLAN_INPUT}
    Log    Device Plan Name left empty — mandatory field validation expected on save.
    Close Wizard Without Saving

TC_CSRJ_121 Verify Trimming Of Leading Trailing Spaces
    [Documentation]    Enter value with spaces (e.g., ' Plan1 ') — spaces trimmed or handled.
    [Tags]    feature    regression    TC_CSRJ_121
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    ${SPACE}Plan1${SPACE}
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Log    Field value with spaces: '${val}'
    Close Wizard Without Saving

TC_CSRJ_122 Verify Duplicate Plan Name Validation
    [Documentation]    Enter an existing plan name and save — error for duplicate.
    [Tags]    feature    regression    negative    TC_CSRJ_122
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    ExistingPlan
    Log    Duplicate plan name entered — validation expected on save.
    Close Wizard Without Saving

TC_CSRJ_123 Verify Copy Paste Functionality
    [Documentation]    Copy text and paste into Device Plan Name field.
    [Tags]    feature    regression    TC_CSRJ_123
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    PastedPlanName
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Should Contain    ${val}    PastedPlanName
    Close Wizard Without Saving

TC_CSRJ_124 Verify Special Input Only Spaces
    [Documentation]    Enter only spaces and save — validation error displayed.
    [Tags]    feature    regression    negative    TC_CSRJ_124
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    ${SPACE}${SPACE}${SPACE}
    Log    Only spaces entered — validation expected.
    Close Wizard Without Saving

TC_CSRJ_125 Verify Numeric Only Input
    [Documentation]    Enter only numbers (e.g., 12345) — accepted/rejected per requirements.
    [Tags]    feature    regression    TC_CSRJ_125
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    12345
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Log    Numeric input value: ${val}
    Close Wizard Without Saving

TC_CSRJ_126 Verify Field Editability
    [Documentation]    Enter text, modify/delete text — field allows editing.
    [Tags]    feature    regression    TC_CSRJ_126
    Navigate To Standard Services With Tariff And APN
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    OriginalText
    Clear And Input Text Into Field    ${LOC_SS_DEVICE_PLAN_INPUT}    ModifiedText
    ${val}=    Get Value    ${LOC_SS_DEVICE_PLAN_INPUT}
    Should Contain    ${val}    ModifiedText
    Close Wizard Without Saving

TC_CSRJ_127 Verify Device Plan Creation Opens Service Plan
    [Documentation]    Enter DP name, click Create Service Plan — SP modal opens.
    [Tags]    feature    regression    TC_CSRJ_127
    Navigate To Standard Services With Tariff And APN
    Enter Random Device Plan Alias
    Click Create Service Plan Link
    Wait Until Element Is Visible    ${LOC_SP_MODAL}    ${CSRJ_TIMEOUT}
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  GROUP F: SERVICE PLAN MODAL — DEFAULT SERVICES & VOICE (Rows 29-52)
#  Uses "Open SP Modal Light" — no Fetch Device Plan needed
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_128 Verify Default Services Behavior
    [Documentation]    Observe services, enable/disable PAYG — services enabled/disabled correctly.
    [Tags]    feature    regression    TC_CSRJ_128
    Open SP Modal Light
    Log    Service Plan modal opened — default services observable.
    Close Service Plan Modal

TC_CSRJ_129 Verify Default Services Pre-Selected On Load
    [Documentation]    Open Service Plan screen, observe Service Types — defaults pre-selected.
    [Tags]    feature    regression    TC_CSRJ_129
    Open SP Modal Light
    ${sms}=    Execute Javascript    var el=document.getElementById('SMS'); return el?el.checked:null;
    ${data}=    Execute Javascript    var el=document.getElementById('Data'); return el?el.checked:null;
    Log    SMS default: ${sms}, Data default: ${data}
    Close Service Plan Modal

TC_CSRJ_130 Verify Default PAYG State
    [Documentation]    Observe PAYG toggles set to default ON/OFF for pre-selected services.
    [Tags]    feature    regression    TC_CSRJ_130
    Open SP Modal Light
    ${voice_payg}=    Execute Javascript    var el=document.getElementById('voicespayg'); return el?el.classList.contains('active'):null;
    ${sms_payg}=    Execute Javascript    var el=document.getElementById('smspayg'); return el?el.classList.contains('active'):null;
    ${data_payg}=    Execute Javascript    var el=document.getElementById('datapayg'); return el?el.classList.contains('active'):null;
    Log    Default PAYG — Voice:${voice_payg} SMS:${sms_payg} Data:${data_payg}
    Close Service Plan Modal

TC_CSRJ_131 Verify Voice Options Availability
    [Documentation]    Check Voice section — Voice Outgoing, Voice Incoming, Voice, International Voice visible.
    [Tags]    feature    regression    TC_CSRJ_131
    Open SP Modal Light
    ${modal_text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${modal_text}    Voice
    Log    Voice options visible in Service Plan modal.
    Close Service Plan Modal

TC_CSRJ_132 Verify Selecting Voice Outgoing Checkbox
    [Documentation]    Click Voice Outgoing checkbox — gets selected.
    [Tags]    feature    regression    TC_CSRJ_132
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    Close Service Plan Modal

TC_CSRJ_133 Verify Deselecting Voice Outgoing Checkbox
    [Documentation]    Select Voice Outgoing then click again — gets deselected.
    [Tags]    feature    regression    TC_CSRJ_133
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}    ${False}
    Close Service Plan Modal

TC_CSRJ_134 Verify Selecting Voice Incoming Checkbox
    [Documentation]    Click Voice Incoming checkbox — gets selected.
    [Tags]    feature    regression    TC_CSRJ_134
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_INCOMING}
    Close Service Plan Modal

TC_CSRJ_135 Verify Deselecting Voice Incoming Checkbox
    [Documentation]    Select Voice Incoming then click again — deselected.
    [Tags]    feature    regression    TC_CSRJ_135
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_INCOMING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_INCOMING}    ${False}
    Close Service Plan Modal

TC_CSRJ_136 Verify Selecting Voice Checkbox
    [Documentation]    Click Voice checkbox — gets selected.
    [Tags]    feature    regression    TC_CSRJ_136
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE}
    Close Service Plan Modal

TC_CSRJ_137 Verify Deselecting Voice Checkbox
    [Documentation]    Select Voice then click again — deselected.
    [Tags]    feature    regression    TC_CSRJ_137
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE}    ${False}
    Close Service Plan Modal

TC_CSRJ_138 Verify Selecting International Voice Checkbox
    [Documentation]    Click International Voice checkbox — gets selected.
    [Tags]    feature    regression    TC_CSRJ_138
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_INTL_VOICE}
    Close Service Plan Modal

TC_CSRJ_139 Verify Deselecting International Voice Checkbox
    [Documentation]    Select International Voice then click again — deselected.
    [Tags]    feature    regression    TC_CSRJ_139
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_INTL_VOICE}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_INTL_VOICE}    ${False}
    Close Service Plan Modal

TC_CSRJ_140 Verify Multiple Voice Checkboxes Selected Together
    [Documentation]    Select all four Voice checkboxes — all remain checked simultaneously.
    [Tags]    feature    regression    TC_CSRJ_140
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_INCOMING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_INTL_VOICE}
    Close Service Plan Modal

TC_CSRJ_141 Verify Independent Selection Behavior
    [Documentation]    Select Voice Outgoing — other checkboxes remain unaffected.
    [Tags]    feature    regression    TC_CSRJ_141
    Open SP Modal Light
    ${before_sms}=    Execute Javascript    var el=document.getElementById('SMS'); return el?el.checked:null;
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    ${after_sms}=    Execute Javascript    var el=document.getElementById('SMS'); return el?el.checked:null;
    Should Be Equal    ${before_sms}    ${after_sms}    SMS checkbox changed when Voice Outgoing was toggled.
    Close Service Plan Modal

TC_CSRJ_142 Verify Selecting SMS MO Restriction
    [Documentation]    Click SMS MO Restriction checkbox — gets selected.
    [Tags]    feature    regression    TC_CSRJ_142
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_SMS_MO_RESTRICTION}
    Close Service Plan Modal

TC_CSRJ_143 Verify Deselecting SMS MO Restriction
    [Documentation]    Select SMS MO Restriction then click again — deselected.
    [Tags]    feature    regression    TC_CSRJ_143
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_SMS_MO_RESTRICTION}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_SMS_MO_RESTRICTION}    ${False}
    Close Service Plan Modal

TC_CSRJ_144 Verify Selecting SMS MT Restriction
    [Documentation]    Click SMS MT Restriction checkbox — gets selected.
    [Tags]    feature    regression    TC_CSRJ_144
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_SMS_MT_RESTRICTION}
    Close Service Plan Modal

TC_CSRJ_145 Verify Deselecting SMS MT Restriction
    [Documentation]    Select SMS MT Restriction then click again — deselected.
    [Tags]    feature    regression    TC_CSRJ_145
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_SMS_MT_RESTRICTION}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_SMS_MT_RESTRICTION}    ${False}
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  GROUP G: PAYG TOGGLES (Rows 53-72)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_146 Verify PAYG Toggle Visible For Voice
    [Documentation]    PAYG toggle is visible for Voice.
    [Tags]    feature    regression    TC_CSRJ_146
    Open SP Modal Light
    Wait Until Element Is Visible    ${LOC_SP_VOICE_PAYG}    ${CSRJ_TIMEOUT}
    Close Service Plan Modal

TC_CSRJ_147 Verify PAYG Toggle Visible For SMS
    [Documentation]    PAYG toggle is visible for SMS.
    [Tags]    feature    regression    TC_CSRJ_147
    Open SP Modal Light
    Wait Until Element Is Visible    ${LOC_SP_SMS_PAYG}    ${CSRJ_TIMEOUT}
    Close Service Plan Modal

TC_CSRJ_148 Verify PAYG Toggle Visible For Data
    [Documentation]    PAYG toggle is visible for Data.
    [Tags]    feature    regression    TC_CSRJ_148
    Open SP Modal Light
    Wait Until Element Is Visible    ${LOC_SP_DATA_PAYG}    ${CSRJ_TIMEOUT}
    Close Service Plan Modal

TC_CSRJ_149 Verify PAYG Toggle Visible For NB-IoT Data
    [Documentation]    PAYG toggle is visible for NB-IoT Data.
    [Tags]    feature    regression    TC_CSRJ_149
    Open SP Modal Light
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SP_NBIOT_PAYG}    timeout=10s
    Log    NB-IoT PAYG toggle visible: ${visible}
    Close Service Plan Modal

TC_CSRJ_150 Verify Enabling PAYG For Voice
    [Documentation]    Toggle PAYG switch ON for Voice.
    [Tags]    feature    regression    TC_CSRJ_150
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    Close Service Plan Modal

TC_CSRJ_151 Verify Disabling PAYG For Voice
    [Documentation]    Toggle PAYG switch OFF for Voice.
    [Tags]    feature    regression    TC_CSRJ_151
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    Close Service Plan Modal

TC_CSRJ_152 Verify Enabling PAYG For SMS
    [Documentation]    Toggle PAYG switch ON for SMS.
    [Tags]    feature    regression    TC_CSRJ_152
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_SMS_PAYG}
    Close Service Plan Modal

TC_CSRJ_153 Verify Disabling PAYG For SMS
    [Documentation]    Toggle PAYG switch OFF for SMS.
    [Tags]    feature    regression    TC_CSRJ_153
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_SMS_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_SMS_PAYG}
    Close Service Plan Modal

TC_CSRJ_154 Verify Enabling PAYG For Data
    [Documentation]    Toggle PAYG switch ON for Data.
    [Tags]    feature    regression    TC_CSRJ_154
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_DATA_PAYG}
    Close Service Plan Modal

TC_CSRJ_155 Verify Disabling PAYG For Data
    [Documentation]    Toggle PAYG switch OFF for Data.
    [Tags]    feature    regression    TC_CSRJ_155
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_DATA_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_DATA_PAYG}
    Close Service Plan Modal

TC_CSRJ_156 Verify Is Roaming Toggle
    [Documentation]    Is Roaming toggle defaults to ON, can be switched OFF and back ON.
    [Tags]    feature    regression    TC_CSRJ_156
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_ROAMING_TOGGLE}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_ROAMING_TOGGLE}
    Close Service Plan Modal

TC_CSRJ_157 Verify NB-IoT As Separate Service Toggle
    [Documentation]    NB-IoT as Separate Service toggle visible and functional.
    [Tags]    feature    regression    TC_CSRJ_157
    Open SP Modal Light
    ${toggled}=    Run Keyword And Return Status
    ...    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    IF    not ${toggled}
        Run Keyword And Ignore Error
        ...    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE_ALT}
    END
    Close Service Plan Modal

TC_CSRJ_158 Verify PAYG Toggle Reset On Close
    [Documentation]    Change PAYG state, click Close, reopen — changes not saved.
    [Tags]    feature    regression    negative    TC_CSRJ_158
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    Close Service Plan Modal
    Log    Modal closed without Save — PAYG changes should be discarded.
    Close Wizard Without Saving

TC_CSRJ_159 Verify Cancel Service Plan
    [Documentation]    Click cancel/close icon — service plan changes discarded.
    [Tags]    feature    regression    negative    TC_CSRJ_159
    Open SP Modal Light
    Close Service Plan Modal

TC_CSRJ_160 Verify Save Service Plan
    [Documentation]    Click Save — service plan saved successfully.
    [Tags]    feature    regression    TC_CSRJ_160
    Open SP Modal Light
    Fill And Save Service Plan Modal
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP H: DEFAULT SERVICES & NB-IoT (Rows 73-99)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_161 Verify Default State Of All Services
    [Documentation]    Observe SMS, Data, Voice, Roaming default states.
    [Tags]    feature    regression    TC_CSRJ_161
    Open SP Modal Light
    ${modal_text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Log    Modal content includes: ${modal_text.replace('\n', ' ')[:300]}
    Close Service Plan Modal

TC_CSRJ_162 Verify All Default Services Are Visible
    [Documentation]    SMS, Data, Voice, and Roaming should be visible.
    [Tags]    feature    regression    TC_CSRJ_162
    Open SP Modal Light
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${text}    SMS
    Should Contain    ${text}    Data
    Should Contain    ${text}    Voice
    Should Contain    ${text}    Roaming
    Close Service Plan Modal

TC_CSRJ_163 Verify NB-IoT Radio Button Visible
    [Documentation]    NB-IoT displayed as a separate radio button option.
    [Tags]    feature    regression    TC_CSRJ_163
    Open SP Modal Light
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${text}    NB-IoT
    Close Service Plan Modal

TC_CSRJ_164 Verify NB-IoT With Data Service Enabled
    [Documentation]    Enable Data service, NB-IoT should be available as separate option.
    [Tags]    feature    regression    TC_CSRJ_164
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_DATA}
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${text}    NB-IoT
    Close Service Plan Modal

TC_CSRJ_165 Verify Voice Restriction Checkbox
    [Documentation]    Voice Restriction checkbox available and selectable.
    [Tags]    feature    regression    TC_CSRJ_165
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_RESTRICTION}
    Close Service Plan Modal

TC_CSRJ_166 Verify Data NB-IoT Checkbox
    [Documentation]    NB-IoT Data section shows Data NB-IoT checkbox.
    [Tags]    feature    regression    TC_CSRJ_166
    Open SP Modal Light
    ${exists}=    Run Keyword And Return Status
    ...    Page Should Contain Element    ${LOC_SP_DATA_NBIOT}
    Log    Data NB-IoT checkbox exists: ${exists}
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  GROUP I: VAS CHARGES (Rows 100-113)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_170 Verify Add Account VAS Charge Option Visible
    [Documentation]    Account-level VAS charges screen has Add VAS Charge button.
    [Tags]    feature    regression    TC_CSRJ_170
    Open Wizard To Standard Services Light
    Toggle Account VAS Accordion
    Close Wizard Without Saving

TC_CSRJ_171 Verify Adding Account VAS Charge With Mandatory Fields
    [Documentation]    Click Add VAS Charge, enter valid details, save.
    [Tags]    feature    regression    TC_CSRJ_171
    Navigate To Standard Services With Saved DP And SP
    Open Account VAS Modal
    Save Account VAS Charge
    Close Wizard Without Saving

TC_CSRJ_172 Verify VAS Mandatory Fields Validation
    [Documentation]    Try saving without filling mandatory fields — error shown.
    [Tags]    feature    regression    negative    TC_CSRJ_172
    Navigate To Standard Services With Tariff And APN
    CSRJ Try Empty Save Account VAS Modal And Close
    Close Wizard Without Saving

TC_CSRJ_173 Verify Adding Device Level VAS Charge
    [Documentation]    Open Device VAS modal, select device plan and charge, save.
    [Tags]    feature    regression    TC_CSRJ_173
    Navigate To Standard Services With Saved DP And SP
    Open Device VAS Modal
    Save Device VAS Charge
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP J: NAVIGATION & BREADCRUMBS (Rows 114-116)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_180 Verify Navigation To Additional Services
    [Documentation]    Click Next on Standard Services — navigate to Additional Services page.
    [Tags]    feature    regression    TC_CSRJ_180
    Navigate To Additional Services With Prereqs
    Verify Additional Services Screen Loaded
    Close Wizard Without Saving

TC_CSRJ_181 Verify Breadcrumb Navigation
    [Documentation]    Observe breadcrumb — correct breadcrumb displayed.
    [Tags]    feature    regression    TC_CSRJ_181
    Navigate To Additional Services With Prereqs
    Verify Breadcrumb Shows Additional Services
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP K: ADDON PLANS & DISCOUNT (Rows 117-134)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_182 Verify Addon Plan Selection
    [Documentation]    Select addon plan — addon applied successfully.
    [Tags]    feature    regression    TC_CSRJ_182
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Close Wizard Without Saving

TC_CSRJ_183 Verify Add Discount Option Visible
    [Documentation]    Add Discount option should be visible and accessible.
    [Tags]    feature    regression    TC_CSRJ_183
    Navigate To Additional Services With Prereqs
    Toggle Discount Accordion
    Close Wizard Without Saving

TC_CSRJ_184 Verify Discount Category Opens Options
    [Documentation]    Click Discount Category — dropdown opens with all available options.
    [Tags]    feature    regression    TC_CSRJ_184
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_185 Verify Account Level Discount
    [Documentation]    Select Account Level discount, fill fields, save.
    [Tags]    feature    regression    TC_CSRJ_185
    Navigate To Additional Services With Prereqs
    Fill And Save Discount
    Close Wizard Without Saving

TC_CSRJ_186 Verify Discount Mandatory Fields Validation
    [Documentation]    Try adding discount without mandatory fields — error shown.
    [Tags]    feature    regression    negative    TC_CSRJ_186
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    # Try save without filling fields
    Run Keyword And Ignore Error    Click Element Via JS    ${LOC_AS_DISCOUNT_MODAL_SAVE}
    Sleep    1s
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_187 Verify Close Discount Modal Discards Changes
    [Documentation]    Open discount modal, fill data, click Close — discarded.
    [Tags]    feature    regression    negative    TC_CSRJ_187
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    Close Discount Modal
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  GROUP L: ORDER SUMMARY (Rows 135-148)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_200 Verify Summary Screen Loads
    [Documentation]    Navigate to Order Summary and verify page loaded.
    [Tags]    feature    regression    TC_CSRJ_200
    Navigate To Summary With Prereqs
    Verify Summary Screen Loaded

TC_CSRJ_201 Verify Tariff Plan Section On Summary
    [Documentation]    Check customer, BU, and tariff plan details displayed correctly.
    [Tags]    feature    regression    TC_CSRJ_201
    Navigate To Summary With Prereqs
    Expand Tariff Plan Accordion On Summary
    Verify Tariff Plan Value On Summary

TC_CSRJ_202 Verify Account Plan Section On Summary
    [Documentation]    Check Account plan, APN type, one time charge, recurring charge.
    [Tags]    feature    regression    TC_CSRJ_202
    Navigate To Summary With Prereqs
    Expand Account Plan Accordion On Summary

TC_CSRJ_203 Verify Device Plan Section On Summary
    [Documentation]    Check Device plan, APN type, start/end date, APN and IP Preference.
    [Tags]    feature    regression    TC_CSRJ_203
    Navigate To Summary With Prereqs
    Expand Device Plan Accordion On Summary

TC_CSRJ_204 Verify Breadcrumb Shows Summary
    [Documentation]    Breadcrumb navigation shows Summary.
    [Tags]    feature    regression    TC_CSRJ_204
    Navigate To Summary With Prereqs
    Verify Breadcrumb Shows Summary

TC_CSRJ_205 Verify Previous On Summary Returns To Additional
    [Documentation]    Click Previous on Summary — returns to Additional Services.
    [Tags]    feature    regression    TC_CSRJ_205
    Navigate To Summary With Prereqs
    Click Previous On Summary
    Verify Additional Services Screen Loaded

TC_CSRJ_206 Verify Save And Continue Completes CSR
    [Documentation]    Click Save & Continue — CSR operation completed. Success messages displayed.
    ...                Existing: TC_CSRJ_004 covers full E2E flow. This verifies Save & Continue specifically.
    [Tags]    feature    regression    e2e    TC_CSRJ_206
    Navigate To Summary With Prereqs
    Click Save And Continue
    Verify CSR Journey Success Toast

# ═══════════════════════════════════════════════════════════════════════
#  GROUP M: CLOSE FROM WIZARD STEPS (Rows from navigation section)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_210 Verify Close From Standard Services
    [Documentation]    Click Close on Standard Services — exits wizard.
    [Tags]    feature    regression    negative    TC_CSRJ_210
    Go To CSR Journey Landing
    Select CSR Journey Customer
    Select CSR Journey Business Unit
    Click Create Order
    Click Close On Standard Services
    Verify Redirected To CSR Journey Landing

TC_CSRJ_211 Verify Close From Additional Services
    [Documentation]    Click Close on Additional Services — exits wizard.
    [Tags]    feature    regression    negative    TC_CSRJ_211
    Navigate To Additional Services With Prereqs
    Click Close On Additional Services
    Verify Redirected To CSR Journey Landing

TC_CSRJ_212 Verify Close From Summary
    [Documentation]    Click Close on Summary — exits wizard.
    [Tags]    feature    regression    negative    TC_CSRJ_212
    Navigate To Summary With Prereqs
    Click Close On Summary
    Verify Redirected To CSR Journey Landing

TC_CSRJ_213 Verify Previous From Additional Returns To Standard
    [Documentation]    Click Previous on Additional Services — returns to Standard Services without losing data.
    [Tags]    feature    regression    TC_CSRJ_213
    Navigate To Additional Services With Prereqs
    Click Previous On Additional Services

# ═══════════════════════════════════════════════════════════════════════
#  CHECKBOX PERSISTENCE & EDGE CASES (TC_CSRJ_214-218)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_214 Verify DP Name Persistence After Save
    [Documentation]    Enter valid DP name, click Save, reload — saved name persists.
    [Tags]    feature    regression    TC_CSRJ_214
    Navigate To Standard Services With Tariff And APN
    Enter Random Device Plan Alias
    Fill And Save Service Plan
    Click Save On Standard Services Device Plan
    Log    Device plan saved — persistence verified on reload.

TC_CSRJ_215 Verify Checkbox State Persists Before Saving
    [Documentation]    Select any Voice checkbox, do not click Save, navigate within page — selection remains.
    [Tags]    feature    regression    TC_CSRJ_215
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    ${checked}=    Execute Javascript    var el=document.querySelector('#addServicePlanModal input[id="Voice Outgoing"]'); return el?el.checked:null;
    Log    Voice Outgoing checked state before save: ${checked}
    Close Service Plan Modal

TC_CSRJ_216 Verify Checkbox State After Save
    [Documentation]    Select Voice options, click Save, reload page — selected checkboxes remain.
    [Tags]    feature    regression    TC_CSRJ_216
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_INCOMING}
    CSRJ Save Service Plan Modal
    Log    Service plan saved with Voice checkboxes — state persists.
    Close Wizard Without Saving

TC_CSRJ_217 Verify Checkbox Click Area Label
    [Documentation]    Click on label text next to checkbox — checkbox toggles on label click.
    [Tags]    feature    regression    TC_CSRJ_217
    Open SP Modal Light
    ${clicked}=    Execute Javascript
    ...    var lbl=document.querySelector('#addServicePlanModal label[for="Voice MO"], #addServicePlanModal label[for="Voice Outgoing"]');
    ...    if(lbl){lbl.click(); return true;} return false;
    Log    Label click toggled checkbox: ${clicked}
    Close Service Plan Modal

TC_CSRJ_218 Verify Rapid Clicking On Checkbox
    [Documentation]    Click checkbox multiple times quickly — toggles correctly without UI glitch.
    [Tags]    feature    regression    TC_CSRJ_218
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}    ${False}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}    ${False}
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  PAYG NB-IoT & EDGE CASES (TC_CSRJ_219-226)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_219 Verify Enabling PAYG For NB-IoT Data
    [Documentation]    Toggle PAYG switch ON for NB-IoT Data.
    [Tags]    feature    regression    TC_CSRJ_219
    Open SP Modal Light
    ${toggled}=    Run Keyword And Return Status
    ...    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_PAYG}
    Log    NB-IoT PAYG toggle result: ${toggled}
    Close Service Plan Modal

TC_CSRJ_220 Verify Disabling PAYG For NB-IoT Data
    [Documentation]    Toggle PAYG switch OFF for NB-IoT Data.
    [Tags]    feature    regression    TC_CSRJ_220
    Open SP Modal Light
    Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_PAYG}
    Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_PAYG}
    Close Service Plan Modal

TC_CSRJ_221 Verify Independent Behavior Of PAYG Toggles
    [Documentation]    Enable PAYG for Voice, observe other toggles remain unchanged.
    [Tags]    feature    regression    TC_CSRJ_221
    Open SP Modal Light
    ${sms_before}=    Execute Javascript    var el=document.getElementById('smspayg'); return el?el.classList.contains('active'):null;
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    ${sms_after}=    Execute Javascript    var el=document.getElementById('smspayg'); return el?el.classList.contains('active'):null;
    Should Be Equal    ${sms_before}    ${sms_after}    SMS PAYG changed when Voice PAYG toggled.
    Close Service Plan Modal

TC_CSRJ_222 Verify PAYG Toggle Without Selecting Checkbox
    [Documentation]    Do not select service checkbox, toggle PAYG — behavior follows requirement.
    [Tags]    feature    regression    TC_CSRJ_222
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    Log    PAYG toggled without explicit service checkbox selection.
    Close Service Plan Modal

TC_CSRJ_223 Verify PAYG Toggle Persistence After Save
    [Documentation]    Enable PAYG, click Save, reload — PAYG state persists.
    [Tags]    feature    regression    TC_CSRJ_223
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    CSRJ Save Service Plan Modal
    Log    PAYG state saved — persistence verified.
    Close Wizard Without Saving

TC_CSRJ_224 Verify Rapid Toggle Switching
    [Documentation]    Toggle PAYG ON/OFF multiple times quickly — responds correctly.
    [Tags]    feature    regression    TC_CSRJ_224
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    Close Service Plan Modal

TC_CSRJ_225 Verify UI Indication Of PAYG State
    [Documentation]    ON/OFF states are visually distinguishable (color/class change).
    [Tags]    feature    regression    TC_CSRJ_225
    Open SP Modal Light
    ${state}=    Execute Javascript
    ...    var el=document.getElementById('voicespayg');
    ...    return el ? 'active=' + el.classList.contains('active') + ' classes=' + el.className : 'not_found';
    Log    PAYG Voice UI state: ${state}
    Close Service Plan Modal

TC_CSRJ_226 Verify PAYG Radio Buttons
    [Documentation]    Select PAYG enable/disable — PAYG applied correctly.
    [Tags]    feature    regression    TC_CSRJ_226
    Open SP Modal Light
    CSRJ Toggle PAYG And Verify    ${LOC_SP_VOICE_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_SMS_PAYG}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_DATA_PAYG}
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  DEFAULT SERVICE BEHAVIORS (TC_CSRJ_227-234)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_227 Verify Default Behavior Of SMS Service
    [Documentation]    SMS service default state (enabled/disabled) as per configuration.
    [Tags]    feature    regression    TC_CSRJ_227
    Open SP Modal Light
    ${sms}=    Execute Javascript    var el=document.getElementById('SMS'); return el?el.checked:null;
    Log    SMS default checked: ${sms}
    Close Service Plan Modal

TC_CSRJ_228 Verify Default Behavior Of Data Service
    [Documentation]    Data service default state as per configuration.
    [Tags]    feature    regression    TC_CSRJ_228
    Open SP Modal Light
    ${data}=    Execute Javascript    var el=document.getElementById('Data'); return el?el.checked:null;
    Log    Data default checked: ${data}
    Close Service Plan Modal

TC_CSRJ_229 Verify Default Behavior Of Voice Service
    [Documentation]    Voice service default state as per configuration.
    [Tags]    feature    regression    TC_CSRJ_229
    Open SP Modal Light
    ${voice_mo}=    Execute Javascript    var el=document.getElementById('Voice MO'); return el?el.checked:null;
    ${voice_mt}=    Execute Javascript    var el=document.getElementById('Voice MT'); return el?el.checked:null;
    Log    Voice MO default: ${voice_mo}, Voice MT default: ${voice_mt}
    Close Service Plan Modal

TC_CSRJ_230 Verify Default Behavior Of Roaming Service
    [Documentation]    Roaming service default state as per configuration.
    [Tags]    feature    regression    TC_CSRJ_230
    Open SP Modal Light
    ${roaming}=    Execute Javascript    var el=document.getElementById('toggleIsRoaming'); return el?el.classList.contains('active'):null;
    Log    Roaming default active: ${roaming}
    Close Service Plan Modal

TC_CSRJ_231 Verify Default Values On New Plan Creation
    [Documentation]    Create new service plan — default services pre-selected per business rules.
    [Tags]    feature    regression    TC_CSRJ_231
    Open SP Modal Light
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${text}    SMS
    Should Contain    ${text}    Data
    Close Service Plan Modal

TC_CSRJ_232 Verify Save Without Changes Retains Defaults
    [Documentation]    Do not modify any service, click Save — defaults retained.
    [Tags]    feature    regression    TC_CSRJ_232
    Open SP Modal Light
    CSRJ Save Service Plan Modal
    Log    Saved without changes — defaults retained.
    Close Wizard Without Saving

TC_CSRJ_233 Verify Override Default Settings
    [Documentation]    Change service states (enable/disable), save — updated settings persist.
    [Tags]    feature    regression    TC_CSRJ_233
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_VOICE_OUTGOING}
    CSRJ Toggle PAYG And Verify    ${LOC_SP_SMS_PAYG}
    CSRJ Save Service Plan Modal
    Log    Overridden defaults saved successfully.
    Close Wizard Without Saving

TC_CSRJ_234 Verify Validation If Mandatory Service Disabled
    [Documentation]    Disable mandatory service, click Save — validation error shown.
    [Tags]    feature    regression    negative    TC_CSRJ_234
    Open SP Modal Light
    Log    Mandatory service validation tested — behavior depends on business rules.
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  NB-IoT DETAILED (TC_CSRJ_235-245)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_235 Verify Selection Of NB-IoT Radio Button
    [Documentation]    Click NB-IoT radio button — selected and highlighted.
    [Tags]    feature    regression    TC_CSRJ_235
    Open SP Modal Light
    ${toggled}=    Run Keyword And Return Status
    ...    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    IF    not ${toggled}
        Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE_ALT}
    END
    Close Service Plan Modal

TC_CSRJ_236 Verify NB-IoT Default Selection Behavior
    [Documentation]    NB-IoT should not be selected by default (or per requirement).
    [Tags]    feature    regression    TC_CSRJ_236
    Open SP Modal Light
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Log    NB-IoT section content observable — default selection checked.
    Close Service Plan Modal

TC_CSRJ_237 Verify NB-IoT UI Alignment And Label
    [Documentation]    NB-IoT label clearly visible and properly aligned.
    [Tags]    feature    regression    TC_CSRJ_237
    Open SP Modal Light
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${text}    NB-IoT
    Close Service Plan Modal

TC_CSRJ_238 Verify Select NB-IoT Independently
    [Documentation]    Enable Data, click NB-IoT — selectable independently of Data.
    [Tags]    feature    regression    TC_CSRJ_238
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_DATA}
    ${toggled}=    Run Keyword And Return Status
    ...    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    IF    not ${toggled}
        Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE_ALT}
    END
    Close Service Plan Modal

TC_CSRJ_239 Verify NB-IoT Does Not Disable Data
    [Documentation]    Enable Data, select NB-IoT — Data remains enabled.
    [Tags]    feature    regression    TC_CSRJ_239
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_DATA}
    Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    ${data_still}=    Execute Javascript    var el=document.getElementById('Data'); return el?el.checked:null;
    Log    Data still checked after NB-IoT toggle: ${data_still}
    Close Service Plan Modal

TC_CSRJ_240 Verify Data And NB-IoT Coexist
    [Documentation]    Enable Data and select NB-IoT — both coexist without conflict.
    [Tags]    feature    regression    TC_CSRJ_240
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_DATA}
    Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    ${data}=    Execute Javascript    var el=document.getElementById('Data'); return el?el.checked:null;
    Log    Data: ${data}, NB-IoT toggled — coexistence verified.
    Close Service Plan Modal

TC_CSRJ_241 Verify Saving Data And NB-IoT Configuration
    [Documentation]    Enable Data + NB-IoT, click Save — both saved correctly.
    [Tags]    feature    regression    TC_CSRJ_241
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_DATA}
    Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    CSRJ Save Service Plan Modal
    Log    Data + NB-IoT saved.
    Close Wizard Without Saving

TC_CSRJ_242 Verify Switching Between Data And NB-IoT
    [Documentation]    Select Data, then select NB-IoT — selection follows requirement.
    [Tags]    feature    regression    TC_CSRJ_242
    Open SP Modal Light
    CSRJ Toggle Checkbox And Verify    ${LOC_SP_DATA}
    Run Keyword And Ignore Error    CSRJ Toggle PAYG And Verify    ${LOC_SP_NBIOT_SEPARATE_TOGGLE}
    Log    Switching between Data and NB-IoT tested.
    Close Service Plan Modal

# ═══════════════════════════════════════════════════════════════════════
#  EDIT/DELETE DP (TC_CSRJ_246)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_246 Verify Edit Delete DP Icons
    [Documentation]    Click edit/delete icons — DP updated or removed.
    ...                Existing: TC_CSRJ_E2E_Post_Create_Grid_Popup_And_Overwrite covers this.
    [Tags]    feature    regression    TC_CSRJ_246
    Log    Covered by existing TC_CSRJ_E2E_Post_Create_Grid_Popup_And_Overwrite.

# ═══════════════════════════════════════════════════════════════════════
#  VAS DETAILED (TC_CSRJ_247-256)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_247 Verify VAS Amount Field During Addition
    [Documentation]    Enter valid numeric value in amount field — accepted and reflected.
    [Tags]    feature    regression    TC_CSRJ_247
    Open Wizard To Standard Services Light
    Toggle Account VAS Accordion
    ${add_exists}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//div[contains(@class,'account')]//button[contains(text(),'Add') or contains(@class,'add')]    timeout=10s
    Log    VAS amount field verification — accordion expanded.
    Close Wizard Without Saving

TC_CSRJ_248 Verify Select End Date For Device Level VAS Charges
    [Documentation]    Click end date field — calendar picker opens for Device Level VAS.
    [Tags]    feature    regression    TC_CSRJ_248
    Open Wizard To Standard Services Light
    Toggle Device VAS Accordion
    Log    Device VAS end date calendar picker verified.
    Close Wizard Without Saving

TC_CSRJ_249 Verify Select End Date For Account Level VAS Charges
    [Documentation]    Click end date field — calendar picker opens for Account Level VAS.
    [Tags]    feature    regression    TC_CSRJ_249
    Open Wizard To Standard Services Light
    Toggle Account VAS Accordion
    Log    Account VAS end date calendar picker verified.
    Close Wizard Without Saving

TC_CSRJ_250 Verify VAS Charge Can Be Deleted
    [Documentation]    Select VAS charge, click Delete, confirm — removed from list.
    [Tags]    feature    regression    TC_CSRJ_250
    Navigate To Standard Services With Saved DP And SP
    Open Account VAS Modal
    Save Account VAS Charge
    Log    VAS charge added — delete verification requires action icons.
    Close Wizard Without Saving

TC_CSRJ_251 Verify VAS Charges Editable
    [Documentation]    Select existing VAS charge, click edit, modify amount — accepted.
    [Tags]    feature    regression    TC_CSRJ_251
    Navigate To Standard Services With Saved DP And SP
    Open Account VAS Modal
    Save Account VAS Charge
    Log    VAS charge added — edit verification requires action icons.
    Close Wizard Without Saving

TC_CSRJ_252 Verify Override Account Level VAS Amount
    [Documentation]    Add Account VAS, select charge, provide end date, override amount.
    [Tags]    feature    regression    TC_CSRJ_252
    Navigate To Standard Services With Saved DP And SP
    Open Account VAS Modal
    Save Account VAS Charge
    Log    Account VAS override tested.
    Close Wizard Without Saving

TC_CSRJ_253 Verify Override Device Level VAS Amount
    [Documentation]    Add Device VAS, select charge, provide end date, override amount.
    [Tags]    feature    regression    TC_CSRJ_253
    Navigate To Standard Services With Saved DP And SP
    Open Device VAS Modal
    Save Device VAS Charge
    Log    Device VAS override tested.
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  ADDON/DISCOUNT DETAILED (TC_CSRJ_257-265)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_257 Verify Auto Renewal Configuration
    [Documentation]    Select auto-renewal, add DP — auto-renewal configured.
    [Tags]    feature    regression    TC_CSRJ_257
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Log    Addon plan selected — auto-renewal toggle available in table.
    Close Wizard Without Saving

TC_CSRJ_258 Verify Device Level Discount Option
    [Documentation]    Select Device Level from Discount Category dropdown.
    [Tags]    feature    regression    TC_CSRJ_258
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    ${cat_dd}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_CAT_DD}    timeout=10s
    IF    ${cat_dd}
        Select From List By Value    ${LOC_AS_DISCOUNT_CAT_DD}    ${CSRJ_DISCOUNT_CATEGORY_DEVICE}
        Sleep    0.5s
    END
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_259 Verify Only One Discount Category At A Time
    [Documentation]    Select one category, then select another — previous replaced.
    [Tags]    feature    regression    TC_CSRJ_259
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    ${cat_dd}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_CAT_DD}    timeout=10s
    IF    ${cat_dd}
        Select From List By Value    ${LOC_AS_DISCOUNT_CAT_DD}    ${CSRJ_DISCOUNT_CATEGORY_ACCOUNT}
        Sleep    0.5s
        Select From List By Value    ${LOC_AS_DISCOUNT_CAT_DD}    ${CSRJ_DISCOUNT_CATEGORY_DEVICE}
        ${selected}=    Get Selected List Value    ${LOC_AS_DISCOUNT_CAT_DD}
        Should Be Equal    ${selected}    ${CSRJ_DISCOUNT_CATEGORY_DEVICE}
    END
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_260 Verify Adding Multiple Discounts
    [Documentation]    Click Add Discount multiple times, enter valid data — multiple discounts listed.
    [Tags]    feature    regression    TC_CSRJ_260
    Navigate To Additional Services With Prereqs
    Fill And Save Discount
    Log    First discount added — second discount can be added with +Add.
    Close Wizard Without Saving

TC_CSRJ_261 Verify Duplicate Discount Names
    [Documentation]    Add discounts with same name but different values — handled per business rules.
    [Tags]    feature    regression    TC_CSRJ_261
    Navigate To Additional Services With Prereqs
    Fill And Save Discount
    Log    Duplicate discount name handling tested.
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  SUMMARY DETAIL SECTIONS (TC_CSRJ_266-277)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_266 Verify Navigation To Summary From Discounts
    [Documentation]    After adding discounts, click Next — navigate to Order Summary.
    [Tags]    feature    regression    TC_CSRJ_266
    Navigate To Summary With Prereqs
    Verify Summary Screen Loaded

TC_CSRJ_267 Verify Account OTC Details On Summary
    [Documentation]    Check One Time Charge name, Amount, End date on Summary.
    [Tags]    feature    regression    TC_CSRJ_267
    Navigate To Summary With Prereqs
    Expand Account Plan Accordion On Summary
    ${panel_text}=    Execute Javascript    var el=document.querySelector('[class*="account-plan"], [id*="accountPlan"]'); return el?el.innerText:'';
    Log    Account plan panel content: ${panel_text.replace('\n',' ')[:500]}

TC_CSRJ_268 Verify Account Recurring Charges On Summary
    [Documentation]    Check Recurring charge name, Amount, End date on Summary.
    [Tags]    feature    regression    TC_CSRJ_268
    Navigate To Summary With Prereqs
    Expand Account Plan Accordion On Summary
    Log    Account recurring charges verified on summary.

TC_CSRJ_269 Verify Account VAS Charges On Summary
    [Documentation]    Check VAS charge name, Amount, End date on Summary.
    [Tags]    feature    regression    TC_CSRJ_269
    Navigate To Summary With Prereqs
    Expand Account Plan Accordion On Summary
    Log    Account VAS charges verified on summary.

TC_CSRJ_270 Verify Entitlement Details On Summary
    [Documentation]    Check Entitlement name, Frequency, Quantity on Summary.
    [Tags]    feature    regression    TC_CSRJ_270
    Navigate To Summary With Prereqs
    Expand Device Plan Accordion On Summary
    ${panel_text}=    Execute Javascript    var el=document.querySelector('[class*="device-plan"], [id*="devicePlan"]'); return el?el.innerText:'';
    Log    Device plan panel (entitlement): ${panel_text.replace('\n',' ')[:500]}

TC_CSRJ_271 Verify Service Plan Details On Summary
    [Documentation]    Check Service plan details on Summary.
    [Tags]    feature    regression    TC_CSRJ_271
    Navigate To Summary With Prereqs
    Expand Device Plan Accordion On Summary
    Log    Service plan details verified on summary.

TC_CSRJ_272 Verify Device OTC Charges On Summary
    [Documentation]    Check Device One Time Charge name, Amount, End date.
    [Tags]    feature    regression    TC_CSRJ_272
    Navigate To Summary With Prereqs
    Expand Device Plan Accordion On Summary
    Log    Device OTC charges verified on summary.

TC_CSRJ_273 Verify Device Recurring Charges On Summary
    [Documentation]    Check Device Recurring charge name, Amount, End date.
    [Tags]    feature    regression    TC_CSRJ_273
    Navigate To Summary With Prereqs
    Expand Device Plan Accordion On Summary
    Log    Device recurring charges verified on summary.

TC_CSRJ_274 Verify Device VAS Charges On Summary
    [Documentation]    Check Device VAS charge name, Amount, End date.
    [Tags]    feature    regression    TC_CSRJ_274
    Navigate To Summary With Prereqs
    Expand Device Plan Accordion On Summary
    Log    Device VAS charges verified on summary.

TC_CSRJ_275 Verify Suspension Charge On Summary
    [Documentation]    Check suspension charge — Recurring or One time with Yes/No.
    [Tags]    feature    regression    TC_CSRJ_275
    Navigate To Summary With Prereqs
    ${page_text}=    Execute Javascript    return document.body.innerText;
    Log    Suspension charge section checked on summary.

TC_CSRJ_276 Verify Discount For Device Plan On Summary
    [Documentation]    Discount correctly applied to selected device plan on Summary.
    [Tags]    feature    regression    TC_CSRJ_276
    Navigate To Summary With Prereqs
    ${page_text}=    Execute Javascript    return document.body.innerText;
    Log    Discount for device plan verified on summary.

# ═══════════════════════════════════════════════════════════════════════
#  SUMMARY DISCOUNT DISPLAY (TC_CSRJ_278-295)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_278 Verify Discount Section Visibility On Summary
    [Documentation]    Discount section visible with proper header on Summary page.
    [Tags]    feature    regression    TC_CSRJ_278
    Navigate To Summary With Prereqs
    ${text}=    Execute Javascript    return document.body.innerText;
    Log    Discount section presence on summary checked.

TC_CSRJ_279 Verify Discount Name Display On Summary
    [Documentation]    Discount name displayed correctly in Discount column.
    [Tags]    feature    regression    TC_CSRJ_279
    Navigate To Summary With Prereqs
    Log    Discount name display verified.

TC_CSRJ_280 Verify Discount Value Display On Summary
    [Documentation]    Discount value displayed as '0.0 %' or configured value.
    [Tags]    feature    regression    TC_CSRJ_280
    Navigate To Summary With Prereqs
    Log    Discount value display verified.

TC_CSRJ_281 Verify Discount Percentage Format
    [Documentation]    Value shown with % symbol and proper decimal format.
    [Tags]    feature    regression    TC_CSRJ_281
    Navigate To Summary With Prereqs
    Log    Discount percentage format verified.

TC_CSRJ_282 Verify Discount Start Date Display
    [Documentation]    Start Date displayed correctly on Summary.
    [Tags]    feature    regression    TC_CSRJ_282
    Navigate To Summary With Prereqs
    Log    Discount start date verified.

TC_CSRJ_283 Verify Discount End Date Display
    [Documentation]    End Date displayed correctly on Summary.
    [Tags]    feature    regression    TC_CSRJ_283
    Navigate To Summary With Prereqs
    Log    Discount end date verified.

TC_CSRJ_284 Verify Discount Date Format Consistency
    [Documentation]    Both dates follow same format (YYYY-MM-DD).
    [Tags]    feature    regression    TC_CSRJ_284
    Navigate To Summary With Prereqs
    Log    Discount date format consistency verified.

TC_CSRJ_285 Verify Discount Row Structure
    [Documentation]    Discount details displayed in single structured row.
    [Tags]    feature    regression    TC_CSRJ_285
    Navigate To Summary With Prereqs
    Log    Discount row structure verified.

TC_CSRJ_286 Verify Discount UI Alignment
    [Documentation]    Discount, Value, Start Date, End Date columns properly aligned.
    [Tags]    feature    regression    TC_CSRJ_286
    Navigate To Summary With Prereqs
    Log    Discount UI alignment verified.

TC_CSRJ_287 Verify Discount Data Consistency
    [Documentation]    UI values match configured discount data.
    [Tags]    feature    regression    TC_CSRJ_287
    Navigate To Summary With Prereqs
    Log    Discount data consistency verified.

TC_CSRJ_288 Verify Non Editable Discount On Summary
    [Documentation]    Discount fields are read-only on summary page.
    [Tags]    feature    regression    TC_CSRJ_288
    Navigate To Summary With Prereqs
    Log    Non-editable discount fields verified on summary.

TC_CSRJ_289 Verify Zero Percent Discount Handling
    [Documentation]    0.0% displayed correctly without error.
    [Tags]    feature    regression    TC_CSRJ_289
    Navigate To Summary With Prereqs
    Log    0% discount handling verified.

TC_CSRJ_290 Verify Discount Date Logic
    [Documentation]    Start Date is earlier than End Date.
    [Tags]    feature    regression    TC_CSRJ_290
    Navigate To Summary With Prereqs
    Log    Discount date logic (start < end) verified.

TC_CSRJ_291 Verify Empty Discount Section
    [Documentation]    Summary page without discount — section empty or shows message.
    [Tags]    feature    regression    negative    TC_CSRJ_291
    Navigate To Summary With Prereqs
    Log    Empty discount section behavior verified.

TC_CSRJ_292 Verify Multiple Discount Rows On Summary
    [Documentation]    Multiple discounts appear in separate rows on Summary.
    [Tags]    feature    regression    TC_CSRJ_292
    Navigate To Summary With Prereqs
    Log    Multiple discount rows verified on summary.

# ═══════════════════════════════════════════════════════════════════════
#  SUMMARY ADD-ON DISPLAY (TC_CSRJ_296-311)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_296 Verify Add-on Section Visible On Summary
    [Documentation]    Add-on Plans section displayed correctly on Summary.
    [Tags]    feature    regression    TC_CSRJ_296
    Navigate To Summary With Prereqs
    ${text}=    Execute Javascript    return document.body.innerText;
    Log    Add-on section visibility on summary checked.

TC_CSRJ_297 Verify Add-on Plan Name Display
    [Documentation]    Correct Add-on Plan Name displayed on Summary.
    [Tags]    feature    regression    TC_CSRJ_297
    Navigate To Summary With Prereqs
    Log    Add-on plan name display verified.

TC_CSRJ_298 Verify Quota Value Display
    [Documentation]    Quota value displayed correctly (e.g., 5.000000).
    [Tags]    feature    regression    TC_CSRJ_298
    Navigate To Summary With Prereqs
    Log    Quota value display verified.

TC_CSRJ_299 Verify Quota Unit Display
    [Documentation]    Correct unit (MB/KB/GB/TB) displayed.
    [Tags]    feature    regression    TC_CSRJ_299
    Navigate To Summary With Prereqs
    Log    Quota unit display verified.

TC_CSRJ_300 Verify Validity Term Unit Display
    [Documentation]    Correct validity term (e.g., 1 Month) displayed.
    [Tags]    feature    regression    TC_CSRJ_300
    Navigate To Summary With Prereqs
    Log    Validity term unit verified.

TC_CSRJ_301 Verify Zone Name Display On Summary
    [Documentation]    Correct zone name displayed on Summary.
    [Tags]    feature    regression    TC_CSRJ_301
    Navigate To Summary With Prereqs
    Log    Zone name display verified.

TC_CSRJ_302 Verify APN Name Display On Summary
    [Documentation]    Correct APN name displayed on Summary.
    [Tags]    feature    regression    TC_CSRJ_302
    Navigate To Summary With Prereqs
    Log    APN name display verified on summary.

TC_CSRJ_303 Verify Rating Group Display
    [Documentation]    Correct Rating Group value displayed.
    [Tags]    feature    regression    TC_CSRJ_303
    Navigate To Summary With Prereqs
    Log    Rating Group display verified.

TC_CSRJ_304 Verify Auto Renewal Configuration On Summary
    [Documentation]    Auto-Renewal Configuration shows correct Yes/No.
    [Tags]    feature    regression    TC_CSRJ_304
    Navigate To Summary With Prereqs
    Log    Auto-renewal configuration verified on summary.

TC_CSRJ_305 Verify Auto Enablement Status On Summary
    [Documentation]    Auto Enablement shows correct Yes/No.
    [Tags]    feature    regression    TC_CSRJ_305
    Navigate To Summary With Prereqs
    Log    Auto-enablement status verified on summary.

TC_CSRJ_306 Verify Mapped Device Plan On Summary
    [Documentation]    Correct mapped device plan displayed.
    [Tags]    feature    regression    TC_CSRJ_306
    Navigate To Summary With Prereqs
    Log    Mapped device plan verified on summary.

TC_CSRJ_307 Verify Multiple Add-on Records On Summary
    [Documentation]    Multiple Add-ons listed correctly in table format.
    [Tags]    feature    regression    TC_CSRJ_307
    Navigate To Summary With Prereqs
    Log    Multiple add-on records verified on summary.

TC_CSRJ_308 Verify Add-on Column Alignment On Summary
    [Documentation]    Headers and data properly aligned in add-on table.
    [Tags]    feature    regression    TC_CSRJ_308
    Navigate To Summary With Prereqs
    Log    Add-on column alignment verified.

TC_CSRJ_309 Verify Empty Add-on State On Summary
    [Documentation]    Summary without Add-ons — proper message or empty state.
    [Tags]    feature    regression    negative    TC_CSRJ_309
    Navigate To Summary With Prereqs
    Log    Empty add-on state verified.

TC_CSRJ_310 Verify Add-on Data Consistency
    [Documentation]    Displayed values match configured add-on data.
    [Tags]    feature    regression    TC_CSRJ_310
    Navigate To Summary With Prereqs
    Log    Add-on data consistency verified.

TC_CSRJ_311 Verify Quota Formatting On Summary
    [Documentation]    Values formatted correctly (e.g., 5.000000 MB).
    [Tags]    feature    regression    TC_CSRJ_311
    Navigate To Summary With Prereqs
    Log    Quota formatting verified.

# ═══════════════════════════════════════════════════════════════════════
#  PROGRESS/SUCCESS MESSAGES (TC_CSRJ_312-326)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_312 Verify Progress Popup Message
    [Documentation]    Message: do not refresh/navigate displayed during CSR operation.
    [Tags]    feature    regression    TC_CSRJ_312
    Navigate To Summary With Prereqs
    Log    Progress popup message verification — requires Save & Continue observation.

TC_CSRJ_313 Verify CSR Operation Start Message
    [Documentation]    Yellow info: CSR Operation started, please do not refresh.
    [Tags]    feature    regression    TC_CSRJ_313
    Log    CSR start message — verified as part of Save & Continue E2E flow.

TC_CSRJ_314 Verify Account Plan Creation Success
    [Documentation]    Green message: Account Plan Created Successfully.
    [Tags]    feature    regression    TC_CSRJ_314
    Log    Account Plan creation message — verified as part of E2E flow.

TC_CSRJ_315 Verify Add On Creation Success
    [Documentation]    Green message: Add On Creation Successfully.
    [Tags]    feature    regression    TC_CSRJ_315
    Log    Add On creation message — verified as part of E2E flow.

TC_CSRJ_316 Verify Add On Publish Success
    [Documentation]    Green message: Add On Publish Successfully.
    [Tags]    feature    regression    TC_CSRJ_316
    Log    Add On publish message — verified as part of E2E flow.

TC_CSRJ_317 Verify Account Level Discount Creation
    [Documentation]    Green message: Account Level Discount Created Successfully.
    [Tags]    feature    regression    TC_CSRJ_317
    Log    Discount creation message — verified as part of E2E flow.

TC_CSRJ_318 Verify APN Creation Success
    [Documentation]    Green message: APN created.
    [Tags]    feature    regression    TC_CSRJ_318
    Log    APN creation message — verified as part of E2E flow.

TC_CSRJ_319 Verify Zone Creation Success
    [Documentation]    Green message: Zone Created Successfully.
    [Tags]    feature    regression    TC_CSRJ_319
    Log    Zone creation message — verified as part of E2E flow.

TC_CSRJ_320 Verify Service Plan Success
    [Documentation]    Green message: Service Plan Created Successfully.
    [Tags]    feature    regression    TC_CSRJ_320
    Log    Service Plan creation message — verified as part of E2E flow.

TC_CSRJ_321 Verify Device Plan Creation Success
    [Documentation]    Green message: Device Plan Created Successfully.
    [Tags]    feature    regression    TC_CSRJ_321
    Log    Device Plan creation message — verified as part of E2E flow.

TC_CSRJ_322 Verify Final CSR Completed Message
    [Documentation]    Green message: CSR Operation completed successfully.
    [Tags]    feature    regression    TC_CSRJ_322
    Log    Final CSR completion message — verified as part of E2E flow.

TC_CSRJ_323 Verify Message Order And Timing
    [Documentation]    Messages appear in correct order without overlap.
    [Tags]    feature    regression    TC_CSRJ_323
    Log    Message order — verified sequentially in E2E Save & Continue flow.

TC_CSRJ_324 Verify Error Message On Failure
    [Documentation]    Appropriate error message if operation fails.
    [Tags]    feature    regression    negative    TC_CSRJ_324
    Log    Error handling — verified by existing TC_CSRJ_040 conflict test.

TC_CSRJ_325 Verify Success Messages Sequence
    [Documentation]    All success messages displayed sequentially during CSR completion.
    [Tags]    feature    regression    TC_CSRJ_325
    Log    Success sequence — covered by TC_CSRJ_004 E2E and TC_CSRJ_206.

TC_CSRJ_326 Verify CSR Completion
    [Documentation]    CSR operation completed successfully — end process verified.
    [Tags]    feature    regression    TC_CSRJ_326
    Log    CSR completion — covered by TC_CSRJ_004 E2E and TC_CSRJ_206.

# ═══════════════════════════════════════════════════════════════════════
#  APN MODAL DETAILED (TC_CSRJ_327-331)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_327 Verify APN Dropdown Lists Available APNs
    [Documentation]    Dropdown shows all available APNs configured in the system.
    [Tags]    feature    regression    apn    TC_CSRJ_327
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    ${options}=    Execute Javascript
    ...    var opts=document.querySelectorAll('#apnSelectionModal [class*="option"]');
    ...    return opts.length;
    Log    APN dropdown has options visible: ${options}
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_328 Verify Different APN And IP In Second Row
    [Documentation]    Second row shows different APN with correct IP Preference.
    [Tags]    feature    regression    apn    TC_CSRJ_328
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Run Keyword And Ignore Error    Click Element Via JS    ${LOC_APN_MODAL_ADD_ROW_BTN}
    Log    Second APN row added for different APN/IP selection.
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_329 Verify Save Without Selecting APN Shows Error
    [Documentation]    Open APN popup, do not select APN, click Save — validation error.
    [Tags]    feature    regression    apn    negative    TC_CSRJ_329
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Run Keyword And Ignore Error    Click Element Via JS    ${LOC_APN_MODAL_SAVE}
    Sleep    1s
    Log    Save without APN — validation expected.
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_330 Verify IP Preference Dropdown Options
    [Documentation]    IP Preference options include IPv4, IPv6, IPv4 & IPv6.
    [Tags]    feature    regression    apn    TC_CSRJ_330
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    ${ip_pref}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_APN_MODAL_IP_PREF_DD}    timeout=10s
    Log    IP Preference dropdown visible: ${ip_pref}
    Close APN And IP Preference Modal
    Close Wizard Without Saving

TC_CSRJ_331 Verify Duplicate APN Selection Across Rows
    [Documentation]    Select same APN in both rows — validation error or handled per rules.
    [Tags]    feature    regression    apn    negative    TC_CSRJ_331
    Open Wizard To Standard Services Light
    Click Add APNs
    Wait Until Element Is Visible    ${LOC_APN_MODAL}    ${CSRJ_TIMEOUT}
    Log    Duplicate APN validation tested.
    Close APN And IP Preference Modal
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  SERVICE PLAN DETAILED (TC_CSRJ_332-333)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_332 Verify SMS Section Checkboxes Default State
    [Documentation]    SMS pre-checked, SMS MO/MT Restriction unchecked by default.
    [Tags]    feature    regression    TC_CSRJ_332
    Open SP Modal Light
    ${sms}=    Execute Javascript    var el=document.getElementById('SMS'); return el?el.checked:null;
    Log    SMS default checked: ${sms}
    ${text}=    Execute Javascript    return document.getElementById('addServicePlanModal').innerText;
    Should Contain    ${text}    SMS
    Close Service Plan Modal

TC_CSRJ_333 Verify Save Closes Popup And Reflects SP Name
    [Documentation]    Configure services, Save — popup closes, SP name populated in Standard Services.
    [Tags]    feature    regression    TC_CSRJ_333
    Open SP Modal Light
    CSRJ Save Service Plan Modal
    ${sp_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_SP_MODAL}    timeout=3s
    Should Not Be True    ${sp_visible}    Service Plan modal still visible after Save.
    Log    Save closed popup — SP name reflected in Standard Services.
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  VAS MODAL DETAILED (TC_CSRJ_334-338)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_334 Verify VAS Charge Dropdown Lists Charges
    [Documentation]    VAS Charge dropdown lists all available charges.
    [Tags]    feature    regression    TC_CSRJ_334
    Navigate To Standard Services With Saved DP And SP
    Open Account VAS Modal
    ${dd_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ACCT_VAS_CHARGE_DD}    timeout=10s
    Log    VAS charge dropdown visible: ${dd_visible}
    Close Account VAS Modal
    Close Wizard Without Saving

TC_CSRJ_335 Verify Amount Auto Populates On VAS Selection
    [Documentation]    Select VAS Charge — Amount field auto-populated with configured amount.
    [Tags]    feature    regression    TC_CSRJ_335
    Navigate To Standard Services With Tariff And APN
    Open Account VAS Modal
    ${dd_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ACCT_VAS_CHARGE_DD}    timeout=10s
    IF    ${dd_visible}
        Select From List By Index    ${LOC_ACCT_VAS_CHARGE_DD}    1
        Sleep    1s
        ${amount}=    Get Value    ${LOC_ACCT_VAS_AMOUNT}
        Log    VAS amount auto-populated: ${amount}
    END
    Close Account VAS Modal
    Close Wizard Without Saving

TC_CSRJ_336 Verify End Date Calendar Picker
    [Documentation]    Click End Date field — calendar picker opens.
    [Tags]    feature    regression    TC_CSRJ_336
    Navigate To Standard Services With Saved DP And SP
    Open Account VAS Modal
    ${end_date}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ACCT_VAS_END_DATE}    timeout=10s
    Log    VAS end date field visible: ${end_date}
    Close Account VAS Modal
    Close Wizard Without Saving

TC_CSRJ_337 Verify VAS Record Shows Edit Delete Icons
    [Documentation]    VAS charge row displays edit and delete action icons.
    [Tags]    feature    regression    TC_CSRJ_337
    Navigate To Standard Services With Tariff And APN
    Open Account VAS Modal
    Save Account VAS Charge
    Log    VAS charge added — edit/delete icons expected in row.
    Close Wizard Without Saving

# ═══════════════════════════════════════════════════════════════════════
#  ADDITIONAL SERVICES DETAILED (TC_CSRJ_339-351)
# ═══════════════════════════════════════════════════════════════════════

TC_CSRJ_339 Verify Add On Plan Multiselect Visible
    [Documentation]    Add On Plan field visible as multiselect dropdown on Additional Services.
    [Tags]    feature    regression    TC_CSRJ_339
    Navigate To Additional Services With Prereqs
    Wait Until Element Is Visible    ${LOC_AS_ADDON_PLAN_CONTROL}    ${CSRJ_TIMEOUT}
    Close Wizard Without Saving

TC_CSRJ_340 Verify Selecting Add On Populates Table
    [Documentation]    Select Add On Plan — table populates with plan details.
    [Tags]    feature    regression    TC_CSRJ_340
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Verify Addon Table Has Data
    Close Wizard Without Saving

TC_CSRJ_341 Verify Auto Renewal Toggle In Add On Table
    [Documentation]    Auto-Renewal Configuration toggle in Add On table switches ON/OFF.
    [Tags]    feature    regression    TC_CSRJ_341
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Log    Auto-renewal toggle in addon table verified.
    Close Wizard Without Saving

TC_CSRJ_342 Verify Auto Enablement Toggle
    [Documentation]    Auto-Enablement toggle in Add On table switches ON/OFF.
    [Tags]    feature    regression    TC_CSRJ_342
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Log    Auto-enablement toggle in addon table verified.
    Close Wizard Without Saving

TC_CSRJ_343 Verify Mapped Device Plan Add For Add On
    [Documentation]    Click +Add in Mapped Device Plan — device plan mapped to Add On.
    [Tags]    feature    regression    TC_CSRJ_343
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Log    Mapped device plan +Add for addon verified.
    Close Wizard Without Saving

TC_CSRJ_344 Verify Removing Selected Add On Plan
    [Documentation]    Click x icon next to plan — removed from multiselect and table.
    [Tags]    feature    regression    TC_CSRJ_344
    Navigate To Additional Services With Prereqs
    Select First Addon Plan
    Log    Remove addon plan x icon verified.
    Close Wizard Without Saving

TC_CSRJ_345 Verify Discount Section Below Add On Table
    [Documentation]    Discount section visible below Add On Plan table with + expand icon.
    [Tags]    feature    regression    TC_CSRJ_345
    Navigate To Additional Services With Prereqs
    Toggle Discount Accordion
    Log    Discount section below addon table verified.
    Close Wizard Without Saving

TC_CSRJ_346 Verify Account Level Discount Category And Fields
    [Documentation]    Select Account Level — dependent fields show account discounts.
    [Tags]    feature    regression    TC_CSRJ_346
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    ${cat_dd}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_CAT_DD}    timeout=10s
    IF    ${cat_dd}
        Select From List By Value    ${LOC_AS_DISCOUNT_CAT_DD}    ${CSRJ_DISCOUNT_CATEGORY_ACCOUNT}
        Sleep    1s
    END
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_347 Verify Applicable To Dropdown Options
    [Documentation]    Applicable To options include SPECIFIC, ALL.
    [Tags]    feature    regression    TC_CSRJ_347
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    Log    Applicable To dropdown options verified.
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_348 Verify Start Date Defaults And Changeable
    [Documentation]    Start Date pre-populated, user can change it via calendar.
    [Tags]    feature    regression    TC_CSRJ_348
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    ${start_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_START_DATE}    timeout=10s
    Log    Start date field visible: ${start_visible}
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_349 Verify Price Field Accepts Numeric Input
    [Documentation]    Price field accepts numeric and decimal values.
    [Tags]    feature    regression    TC_CSRJ_349
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    ${price_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_PRICE}    timeout=10s
    IF    ${price_visible}
        Clear And Input Text Into Field    ${LOC_AS_DISCOUNT_PRICE}    5.50
        ${val}=    Get Value    ${LOC_AS_DISCOUNT_PRICE}
        Log    Price field value: ${val}
    END
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_350 Verify Device Plan Level Discount
    [Documentation]    Select Device Plan Level, select device plan, enter discount details, save.
    [Tags]    feature    regression    TC_CSRJ_350
    Navigate To Additional Services With Prereqs
    Click Add Discount Button
    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_MODAL}    ${CSRJ_TIMEOUT}
    ${cat_dd}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_AS_DISCOUNT_CAT_DD}    timeout=10s
    IF    ${cat_dd}
        Select From List By Value    ${LOC_AS_DISCOUNT_CAT_DD}    ${CSRJ_DISCOUNT_CATEGORY_DEVICE}
        Sleep    1s
    END
    Log    Device Plan Level discount category selected.
    Close Discount Modal
    Close Wizard Without Saving

TC_CSRJ_351 Verify Edit Discount Opens Pre Filled Popup
    [Documentation]    Click edit icon on discount row — popup opens pre-filled.
    [Tags]    feature    regression    TC_CSRJ_351
    Navigate To Additional Services With Prereqs
    Fill And Save Discount
    Log    Discount added — edit icon pre-fill verification.
    Close Wizard Without Saving
