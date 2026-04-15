*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/cost_center_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  LOGIN & NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Login For Cost Center
    [Documentation]    Login and land on Manage Devices page (shared login flow with credential verification).
    Go To    ${BASE_URL}
    Wait For App Loading To Complete
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}          timeout=45s
    Wait Until Element Is Visible    ${LOC_MD_GRID_TBODY}         timeout=30s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}   timeout=30s
    Log    Login successful — Manage Devices page loaded.

Navigate To Manage Account
    [Documentation]    From Manage Devices: click Admin icon (left sidebar) → lands on ManageUser →
    ...                click Account tab in top navigation → ManageAccount page loads with grid.
    Wait For App Loading To Complete
    # Step 1: Click Admin icon in left sidebar to go to ManageUser page
    Scroll To Element Via JS         ${LOC_CC_ADMIN_ICON}
    Wait Until Element Is Visible    ${LOC_CC_ADMIN_ICON}    ${CC_TIMEOUT}
    Click Element Via JS             ${LOC_CC_ADMIN_ICON}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageUser
    Sleep    1s
    Wait For App Loading To Complete
    Log    ManageUser page loaded.
    # Step 2: Click Account tab in top navigation to go to ManageAccount
    Scroll To Element Via JS         ${LOC_NAV_ACCOUNT_TAB}
    Wait Until Element Is Visible    ${LOC_NAV_ACCOUNT_TAB}    ${CC_TIMEOUT}
    Click Element Via JS             ${LOC_NAV_ACCOUNT_TAB}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Keyword Succeeds    3x    5s    Location Should Contain    ManageAccount
    Wait Until Element Is Visible    ${LOC_GRID_MANAGE_ACCOUNT}    ${CC_TIMEOUT}
    Sleep    1s
    Wait For App Loading To Complete
    Log    ManageAccount page loaded; grid visible.

Login And Navigate To Manage Account
    [Documentation]    Complete flow: login → navigate to ManageAccount.
    Login For Cost Center
    Navigate To Manage Account

Login And Navigate To Manage Account Suite
    [Documentation]    Suite-level setup: open browser, login, navigate to ManageAccount once.
    ...                All test cases share this single browser session.
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
    Login For Cost Center
    Navigate To Manage Account

Refresh ManageAccount Page
    [Documentation]    Test-level setup: ensures we are on ManageAccount page with grid loaded.
    ...                Skips navigation if already on the correct page.
    ${on_ma}=    Run Keyword And Return Status    Location Should Contain    ManageAccount
    IF    ${on_ma}
        Wait For App Loading To Complete
    ELSE
        Go To    ${MANAGE_ACCOUNT_URL}
        Sleep    1s
        Wait For App Loading To Complete    timeout=60s
    END
    Wait Until Element Is Visible    ${LOC_GRID_MANAGE_ACCOUNT}    ${CC_TIMEOUT}
    Wait For App Loading To Complete
    Log    ManageAccount page refreshed and ready.

# ═══════════════════════════════════════════════════════════════════════
#  CREATE COST CENTER FORM — OPEN
# ═══════════════════════════════════════════════════════════════════════
Verify Create Cost Center Button Visible
    [Documentation]    Asserts the Create Cost Center button is visible on ManageAccount page.
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_COST_CENTER}    ${CC_TIMEOUT}
    Log    Create Cost Center button is visible.

Verify Create Cost Center Button Not Visible
    [Documentation]    Asserts the Create Cost Center button is NOT visible (no RW permission).
    Sleep    1s
    Element Should Not Be Visible    ${LOC_BTN_CREATE_COST_CENTER}
    Log    Create Cost Center button is NOT visible (expected for non-RW users).

Open Create Cost Center Form
    [Documentation]    Clicks the Create Cost Center button and waits for the form to fully load.
    Wait Until Element Is Visible    ${LOC_BTN_CREATE_COST_CENTER}    ${CC_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CREATE_COST_CENTER}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Location Contains    /CreateCostCenter    timeout=${CC_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_ACCOUNT_NAME}    ${CC_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_COMMENT}         ${CC_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}            ${CC_TIMEOUT}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Create Cost Center form loaded; all fields visible.

# ═══════════════════════════════════════════════════════════════════════
#  FORM FIELD INTERACTIONS
# ═══════════════════════════════════════════════════════════════════════
Select Parent Account
    [Documentation]    Opens the TreeView dropdown and selects the BU account specified by
    ...                CC_PARENT_ACCOUNT_NAME. Expands tree nodes one at a time, waiting for
    ...                children to load after each expansion, until the target is found.
    Wait Until Element Is Visible    ${LOC_DDL_PARENT_ACCOUNT}    ${CC_TIMEOUT}
    Click Element Via JS    ${LOC_DDL_PARENT_ACCOUNT}
    Sleep    1s
    Wait For App Loading To Complete
    # Wait for the tree to become visible
    ${tree_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_TREEVIEW}    10s
    IF    not ${tree_visible}
        Click Element    ${LOC_DDL_PARENT_ACCOUNT}
        Sleep    1s
        Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_TREEVIEW}    15s
    END
    # Wait for root node
    Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_ROOT_NODE}    15s
    Sleep    1s
    # Expand KSA_OPCO → EC → select BU
    Expand And Select BU Account
    Sleep    1s
    Wait For App Loading To Complete
    ${val}=    Get Value    ${LOC_DDL_PARENT_ACCOUNT}
    Log    Parent Account input value after selection: ${val}
    Log    Parent Account selected: ${CC_PARENT_ACCOUNT_NAME}

Expand And Select BU Account
    [Documentation]    Expand KSA_OPCO → find and expand EC (CC_EC_ACCOUNT_NAME) →
    ...                find and select BU (CC_PARENT_ACCOUNT_NAME). Only 2 expand clicks.
    # Step 1: Expand KSA_OPCO (root node)
    ${root_expand}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_PARENT_ACCOUNT_ROOT_EXPAND}    5s
    IF    ${root_expand}
        Click Element Via JS    ${LOC_PARENT_ACCOUNT_ROOT_EXPAND}
        Sleep    1s
        Wait For App Loading To Complete    timeout=30s
        Sleep    1s
        Log    KSA_OPCO expanded. EC accounts should now be visible.
    END
    # Step 2: Find EC account and expand it
    Expand Tree Node By Name    ${CC_EC_ACCOUNT_NAME}
    Sleep    1s
    Wait For App Loading To Complete    timeout=30s
    Sleep    1s
    Log    EC '${CC_EC_ACCOUNT_NAME}' expanded. BU accounts should now be visible.
    # Step 3: Find BU account and select it
    Select Tree Node By Name    ${CC_PARENT_ACCOUNT_NAME}

Expand Tree Node By Name
    [Documentation]    Finds a tree node by name and clicks its expand icon (▶) to reveal children.
    [Arguments]    ${node_name}
    ${expanded}=    Execute JavaScript
    ...    var nodes = document.querySelectorAll('#showTreeView-parentAccount span.k-in'); for(var i=0; i<nodes.length; i++){if(nodes[i].textContent.trim()==='${node_name}'){var li = nodes[i].closest('li.k-item'); if(li){var icon = li.querySelector(':scope > div span.k-i-expand'); if(icon){icon.click(); return true;}}}} return false;
    Should Be True    ${expanded}    Could not find or expand node '${node_name}' in the TreeView.
    Log    Expanded node: ${node_name}

Select Tree Node By Name
    [Documentation]    Finds a tree node by its exact text and clicks its checkbox to select it.
    [Arguments]    ${account_name}
    ${clicked}=    Execute JavaScript
    ...    var nodes = document.querySelectorAll('#showTreeView-parentAccount span.k-in'); for(var i=0; i<nodes.length; i++){if(nodes[i].textContent.trim()==='${account_name}'){var li = nodes[i].closest('li.k-item'); var cb = li ? li.querySelector(':scope > div input.k-checkbox') : null; if(cb){cb.click(); return true;} else {nodes[i].click(); return true;}}} return false;
    Should Be True    ${clicked}    Account '${account_name}' not found in the TreeView.
    Log    Selected account: ${account_name}

Fill Account Name
    [Documentation]    Clears and types the given name into Account Name field.
    ...                Uses JS event dispatch to trigger React onChange (which runs removeSpecialChar).
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${LOC_INPUT_ACCOUNT_NAME}    ${CC_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_ACCOUNT_NAME}
    Input Text    ${LOC_INPUT_ACCOUNT_NAME}    ${name}
    # Trigger React onChange via native setter + input event dispatch
    Execute JavaScript
    ...    var el=document.querySelector('input[name="accountName"]'); var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set; setter.call(el,el.value); el.dispatchEvent(new Event('input',{bubbles:true})); el.dispatchEvent(new Event('change',{bubbles:true}));
    Sleep    0.5s
    Log    Account Name entered: ${name}

Fill Comment
    [Documentation]    Types the given comment into the optional Comment field.
    ...                Uses JS event dispatch to trigger React onChange.
    [Arguments]    ${comment}
    Wait Until Element Is Visible    ${LOC_INPUT_COMMENT}    ${CC_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_COMMENT}
    Input Text    ${LOC_INPUT_COMMENT}    ${comment}
    Execute JavaScript
    ...    var el=document.querySelector('input[name="comment"]'); var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set; setter.call(el,el.value); el.dispatchEvent(new Event('input',{bubbles:true})); el.dispatchEvent(new Event('change',{bubbles:true}));
    Sleep    0.5s
    Log    Comment entered: ${comment}

Clear Account Name
    [Documentation]    Clears the Account Name field completely and triggers React onChange.
    Wait Until Element Is Visible    ${LOC_INPUT_ACCOUNT_NAME}    ${CC_TIMEOUT}
    Clear Element Text    ${LOC_INPUT_ACCOUNT_NAME}
    Execute JavaScript
    ...    var el=document.querySelector('input[name="accountName"]'); var setter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set; setter.call(el,''); el.dispatchEvent(new Event('input',{bubbles:true})); el.dispatchEvent(new Event('change',{bubbles:true}));
    Sleep    0.5s

# ═══════════════════════════════════════════════════════════════════════
#  FORM SUBMISSION
# ═══════════════════════════════════════════════════════════════════════
Click Submit Button
    [Documentation]    Clicks the Submit button (input type=button).
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}    ${CC_TIMEOUT}
    Wait Until Element Is Enabled    ${LOC_BTN_SUBMIT}    ${CC_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_SUBMIT}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Log    Submit button clicked.

Click Close Button
    [Documentation]    Clicks the Close button to discard form and go back to ManageAccount.
    Wait Until Element Is Visible    ${LOC_BTN_CLOSE}    ${CC_TIMEOUT}
    Click Element Via JS    ${LOC_BTN_CLOSE}
    Sleep    1s
    Wait For App Loading To Complete    timeout=60s
    Log    Close button clicked.

# ═══════════════════════════════════════════════════════════════════════
#  VERIFICATION KEYWORDS
# ═══════════════════════════════════════════════════════════════════════
Verify Success Toast Displayed
    [Documentation]    Asserts success toast is visible after form submission.
    Wait Until Element Is Visible    ${LOC_CC_SUCCESS_TOAST}    15s
    Log    Success toast displayed.

Verify Error Toast Displayed
    [Documentation]    Asserts error toast is visible after form submission.
    Wait Until Element Is Visible    ${LOC_CC_ERROR_TOAST}    15s
    Log    Error toast displayed.

Verify Redirect To Manage Account
    [Documentation]    Confirms redirect to ManageAccount page after successful submit or close.
    Wait Until Location Contains    /ManageAccount    timeout=15s
    Wait For App Loading To Complete    timeout=60s
    Wait Until Element Is Visible    ${LOC_GRID_MANAGE_ACCOUNT}    ${CC_TIMEOUT}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Redirected to ManageAccount — grid visible.

Verify Cost Center Created Successfully
    [Documentation]    Verifies success toast and redirect to ManageAccount listing page.
    Verify Success Toast Displayed
    Verify Redirect To Manage Account

Verify Parent Account Error Displayed
    [Documentation]    Asserts validation error is shown for Parent Account field.
    Wait Until Element Is Visible    ${LOC_ERROR_PARENT_ACCOUNT}    10s
    Log    Parent Account validation error displayed.

Verify Account Name Error Displayed
    [Documentation]    Asserts validation error is shown for Account Name field.
    Wait Until Element Is Visible    ${LOC_ERROR_ACCOUNT_NAME}    10s
    Log    Account Name validation error displayed.

Verify No Parent Account Error
    [Documentation]    Asserts NO validation error for Parent Account.
    Element Should Not Be Visible    ${LOC_ERROR_PARENT_ACCOUNT}

Verify No Account Name Error
    [Documentation]    Asserts NO validation error for Account Name.
    Element Should Not Be Visible    ${LOC_ERROR_ACCOUNT_NAME}

Verify On Create Cost Center Page
    [Documentation]    Confirms current URL contains /CreateCostCenter.
    Location Should Contain    CreateCostCenter

Verify Form Fields Present
    [Documentation]    Asserts all form fields are visible on the Create Cost Center page.
    Wait Until Element Is Visible    ${LOC_INPUT_ACCOUNT_NAME}    ${CC_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_INPUT_COMMENT}         ${CC_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_BTN_SUBMIT}            ${CC_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_BTN_CLOSE}             ${CC_TIMEOUT}
    Log    All form fields are present.

# ═══════════════════════════════════════════════════════════════════════
#  COST CENTER TAB VERIFICATION (ManageAccount Listing)
# ═══════════════════════════════════════════════════════════════════════
Expand Row Until Cost Center Tab Found
    [Documentation]    Tries expanding grid rows one by one (up to 5) until one with tab9 is found.
    ...                Returns True if found, False otherwise. Only accountTypeId=6 rows have tab9.
    Wait Until Element Is Visible    ${LOC_GRID_MANAGE_ACCOUNT}    ${CC_TIMEOUT}
    Sleep    1s
    FOR    ${idx}    IN RANGE    1    6
        ${expand_loc}=    Set Variable    xpath=//div[@id='ManageAccountGrid']//tr[@data-uid][${idx}]//td[contains(@class,'k-hierarchy-cell')]/a
        ${exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${expand_loc}    5s
        IF    not ${exists}    BREAK
        Click Element Via JS    ${expand_loc}
        Sleep    1s
        Wait For App Loading To Complete
        ${tab_found}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_TAB_COST_CENTER}    5s
        IF    ${tab_found}
            Log    Found Cost Center tab in row ${idx}.
            RETURN    ${TRUE}
        END
        # Collapse this row before trying the next
        Click Element Via JS    ${expand_loc}
        Sleep    1s
    END
    Log    No row with Cost Center tab (tab9) found in first 5 rows.
    RETURN    ${FALSE}

Open Cost Center Tab In Billing Account
    [Documentation]    Expands rows until Cost Center tab is found, then clicks it.
    ${found}=    Expand Row Until Cost Center Tab Found
    Should Be True    ${found}    No row with Cost Center tab found.
    Click Element Via JS    ${LOC_TAB_COST_CENTER}
    Sleep    1s
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_GRID_COST_CENTER}    15s
    Log    Cost Center tab opened; CostCenterAccount grid visible.

Verify Cost Center In Grid
    [Documentation]    Asserts the given account name appears in the CostCenter grid.
    [Arguments]    ${account_name}
    Wait Until Page Contains    ${account_name}    timeout=15s
    Log    Cost Center '${account_name}' found in grid.

Verify Edit Delete Buttons Visible In Cost Center Grid
    [Documentation]    Asserts Edit and Delete icons are visible in the CostCenter grid.
    Wait Until Element Is Visible    ${LOC_CC_GRID_EDIT_BTN}    10s
    Wait Until Element Is Visible    ${LOC_CC_GRID_DELETE_BTN}    10s
    Log    Edit and Delete buttons visible in Cost Center grid.

Verify Edit Delete Buttons Not Visible In Cost Center Grid
    [Documentation]    Asserts Edit and Delete icons are NOT visible in the CostCenter grid.
    Element Should Not Be Visible    ${LOC_CC_GRID_EDIT_BTN}
    Element Should Not Be Visible    ${LOC_CC_GRID_DELETE_BTN}
    Log    Edit and Delete buttons are hidden.

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE FLOWS
# ═══════════════════════════════════════════════════════════════════════
Create Cost Center End To End
    [Documentation]    Full flow: navigate → open form → fill all fields → submit → verify success.
    [Arguments]    ${name}    ${comment}=${EMPTY}
    Login And Navigate To Manage Account
    Open Create Cost Center Form
    Select Parent Account
    Fill Account Name    ${name}
    IF    '${comment}' != '${EMPTY}'
        Fill Comment    ${comment}
    END
    Click Submit Button
    Verify Cost Center Created Successfully
    Log    Cost Center '${name}' created successfully.
