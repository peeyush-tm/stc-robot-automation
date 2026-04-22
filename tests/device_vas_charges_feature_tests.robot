*** Settings ***
Library     SeleniumLibrary
Library     String
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/device_plan_variables.py
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/device_plan_keywords.resource
Resource    ../resources/keywords/device_vas_charges_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/device_plan_locators.resource

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}
...               AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  DEVICE LEVEL VAS CHARGES — EDIT / SAVE / DELETE (Rows 1-6)
# ═══════════════════════════════════════════════════════════════════════

TC_VAS_001 Verify Edit Device Level VAS Charges Popup Opens
    [Documentation]    PRE: At least one Device Level VAS charge exists in Device Level VAS Charges section.
    ...                STEPS: 1) Scroll to Device Level VAS Charges section
    ...                        2) Click the green edit (pencil) icon on any row
    ...                EXPECTED: Popup opens titled 'Edit Device Level VAS Charges' with fields:
    ...                Device Plan (dropdown, pre-filled), Vas Charge (dropdown, pre-filled),
    ...                End Date (calendar, empty), Amount (pre-filled).
    [Tags]    feature    regression    vas
    Scroll To Device Level VAS Charges Section
    Click Edit Icon On First VAS Row
    Verify Edit Device Level VAS Popup Is Open
    Verify Edit VAS Popup Fields Are Present

TC_VAS_002 Verify Device Plan Dropdown Is Pre-Filled In Edit VAS Popup
    [Documentation]    PRE: Edit Device Level VAS Charges popup open.
    ...                STEPS: 1) Open Edit Device Level VAS popup
    ...                        2) Observe Device Plan field
    ...                EXPECTED: Device Plan dropdown shows the plan name (e.g., SIM-TEST-CSR).
    ...                Field may be read-only or editable as per business rules.
    [Tags]    feature    regression    vas
    Open Edit Device Level VAS Popup
    Verify Device Plan Dropdown Is Pre Filled

TC_VAS_003 Verify Amount Field Is Editable For Override
    [Documentation]    PRE: Edit Device Level VAS Charges popup open.
    ...                STEPS: 1) Clear Amount field
    ...                        2) Enter new amount (e.g., 250.000000)
    ...                        3) Click Save
    ...                EXPECTED: Amount overridden. Row in Device Level VAS table updates to 250.000000 SAR.
    [Tags]    feature    regression    vas
    Open Edit Device Level VAS Popup
    Override VAS Amount    250.000000
    Click Save In Edit VAS Popup
    Verify VAS Row Amount Updated    250.000000 SAR

TC_VAS_004 Verify End Date Calendar Picker In Edit VAS Popup
    [Documentation]    PRE: Edit Device Level VAS Charges popup open.
    ...                STEPS: 1) Click End Date field
    ...                        2) Select a future date
    ...                EXPECTED: Selected date shown in End Date; saved correctly on clicking Save.
    [Tags]    feature    regression    vas
    Open Edit Device Level VAS Popup
    Pick Future End Date In VAS Popup
    Verify End Date Is Displayed In VAS Popup
    Click Save In Edit VAS Popup

TC_VAS_005 Verify Save Persists The Edited VAS Charge
    [Documentation]    PRE: Changes made in Edit Device Level VAS popup.
    ...                STEPS: 1) Change Amount to 250.000000
    ...                        2) Click Save
    ...                EXPECTED: Popup closes. Device Level VAS Charges row reflects 250.000000 SAR.
    [Tags]    feature    regression    vas
    Open Edit Device Level VAS Popup
    Override VAS Amount    250.000000
    Click Save In Edit VAS Popup
    Verify Edit Device Level VAS Popup Is Closed
    Verify VAS Row Amount Updated    250.000000 SAR

TC_VAS_006 Verify Delete Icon Removes The VAS Charge Row
    [Documentation]    PRE: Device Level VAS row exists.
    ...                STEPS: 1) Click red delete (trash) icon on any Device Level VAS row
    ...                        2) Confirm deletion if prompted
    ...                EXPECTED: VAS charge row removed from table; Total charges update accordingly.
    [Tags]    feature    regression    vas
    Note VAS Row Count Before Delete
    Click Delete Icon On First VAS Row
    Confirm VAS Delete If Prompted
    Verify VAS Row Was Removed
    Verify VAS Total Charges Updated
