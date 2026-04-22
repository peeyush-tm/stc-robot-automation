*** Settings ***
Documentation    Stub keywords for Device Level VAS Charges feature tests.
...              TODO: Implement each keyword against real locators/actions.
Library          SeleniumLibrary


*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION / POPUP LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════

Scroll To Device Level VAS Charges Section
    [Documentation]    STUB: Scroll to the Device Level VAS Charges section on the page.
    No Operation

Click Edit Icon On First VAS Row
    [Documentation]    STUB: Click the green edit (pencil) icon on the first VAS row.
    No Operation

Open Edit Device Level VAS Popup
    [Documentation]    STUB: Compound helper — scroll + click edit icon — to open the popup.
    Scroll To Device Level VAS Charges Section
    Click Edit Icon On First VAS Row
    Verify Edit Device Level VAS Popup Is Open

Click Save In Edit VAS Popup
    [Documentation]    STUB: Click Save inside the Edit Device Level VAS popup.
    No Operation

# ═══════════════════════════════════════════════════════════════════════
#  FIELD INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════

Override VAS Amount
    [Arguments]    ${amount}
    [Documentation]    STUB: Clear Amount field and enter the given value.
    Log    Override VAS Amount → ${amount}

Pick Future End Date In VAS Popup
    [Documentation]    STUB: Open calendar picker and select a future date.
    No Operation

Click Delete Icon On First VAS Row
    [Documentation]    STUB: Click red delete (trash) icon on first VAS row.
    No Operation

Confirm VAS Delete If Prompted
    [Documentation]    STUB: Confirm the deletion if a confirmation dialog appears.
    No Operation

Note VAS Row Count Before Delete
    [Documentation]    STUB: Capture current VAS row count for later comparison.
    No Operation

# ═══════════════════════════════════════════════════════════════════════
#  VERIFICATIONS
# ═══════════════════════════════════════════════════════════════════════

Verify Edit Device Level VAS Popup Is Open
    [Documentation]    STUB: Verify popup titled 'Edit Device Level VAS Charges' is visible.
    No Operation

Verify Edit Device Level VAS Popup Is Closed
    [Documentation]    STUB: Verify the edit popup is no longer visible.
    No Operation

Verify Edit VAS Popup Fields Are Present
    [Documentation]    STUB: Verify Device Plan, Vas Charge, End Date, Amount fields exist.
    No Operation

Verify Device Plan Dropdown Is Pre Filled
    [Documentation]    STUB: Assert Device Plan dropdown shows a non-empty value.
    No Operation

Verify End Date Is Displayed In VAS Popup
    [Documentation]    STUB: Assert End Date field shows a selected date.
    No Operation

Verify VAS Row Amount Updated
    [Arguments]    ${expected_amount}
    [Documentation]    STUB: Assert the first VAS row shows the expected amount.
    Log    Verify VAS Row Amount Updated → ${expected_amount}

Verify VAS Row Was Removed
    [Documentation]    STUB: Assert the deleted row is no longer present in the table.
    No Operation

Verify VAS Total Charges Updated
    [Documentation]    STUB: Assert the Total charges line has updated to reflect removal.
    No Operation
