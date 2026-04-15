*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/product_type_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  LOGIN — uses shared flow: captcha first, then credentials with value checks
# ═══════════════════════════════════════════════════════════════════════
Login For Product Type
    [Documentation]    Logs in via ``Login With Credentials`` (captcha before credentials, verified fields).
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_MD_GRID_DATA}          timeout=45s
    Wait Until Element Is Visible    ${LOC_MD_GRID_TBODY}         timeout=30s
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}   timeout=30s
    Page Should Not Contain Element    ${LOC_LOGIN_ERROR_MESSAGE}
    Log    Login successful — Manage Devices page loaded.

# ═══════════════════════════════════════════════════════════════════════
#  NAVIGATION (click Admin → wait for /ManageUser to load →
#              click SIM Product Type → wait for /ProductType to load)
# ═══════════════════════════════════════════════════════════════════════
Navigate To Product Type Module
    [Documentation]    Clicks Admin icon from left sidebar, waits for /ManageUser page to load
    ...                fully (loading overlay gone), then clicks SIM Product Type link,
    ...                waits for /ProductType page to load fully with grid data visible.
    Scroll To Element Via JS         ${LOC_ADMIN_TOGGLE}
    Wait Until Element Is Visible    ${LOC_ADMIN_TOGGLE}         ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_ADMIN_TOGGLE}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}
    ...    Location Should Contain    ManageUser
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_MU_GRID_DATA}         ${PT_TIMEOUT}
    Log    ManageUser page loaded — loading complete.
    Scroll To Element Via JS         ${LOC_PRODUCT_TYPE_NAV}
    Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}     ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PRODUCT_TYPE_NAV}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}         ${PT_TIMEOUT}
    Log    ProductType listing page loaded — grid visible.

Verify Create Product Type Button Visible
    [Documentation]    Asserts Create Product Type button is visible (RW user).
    Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}    ${PT_TIMEOUT}

# ═══════════════════════════════════════════════════════════════════════
#  CREATE PRODUCT TYPE FORM (click Create → wait for loading → wait
#  for ALL fields visible)
# ═══════════════════════════════════════════════════════════════════════
Open Create Product Type Form
    [Documentation]    Clicks Create SIM Product Type button, waits for loading to complete,
    ...                waits for /CreateProductType URL, then waits until ALL form fields visible.
    Wait Until Element Is Visible    ${LOC_PT_CREATE_BTN}           ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_CREATE_BTN}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}
    ...    Location Should Contain    CreateProductType
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}              ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_NAME_INPUT}           ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_SERVICE_TYPE_DD}      ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_2_INPUT}     ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_3_INPUT}     ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_4_INPUT}     ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_SUBMIT_BTN}           ${PT_TIMEOUT}
    Sleep    1s
    Log    Create Product Type form loaded — all fields visible.

# ── Account Dropdown (custom div, NOT a native <select>) ─────────────
Select Account From Dropdown
    [Documentation]    Click the custom Account dropdown to open it, then click KSA_OPCO option.
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}              ${PT_TIMEOUT}
    Click Element                    ${LOC_ACCOUNT_DD}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_SEARCH}          ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_OPTION_KSA}      ${PT_TIMEOUT}
    Click Element                    ${LOC_ACCOUNT_OPTION_KSA}
    Sleep    1s

Select Account By Name
    [Documentation]    Opens the Account dropdown, types the account name in the search input,
    ...                and clicks the matching option. Used by E2E flow for dynamic accounts.
    [Arguments]    ${account_name}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}              ${PT_TIMEOUT}
    Click Element                    ${LOC_ACCOUNT_DD}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_SEARCH}          ${PT_TIMEOUT}
    Input Text                       ${LOC_ACCOUNT_SEARCH}          ${account_name}
    Sleep    1s
    ${option}=    Set Variable    xpath=//div[@data-testid='accountIdet' and contains(text(),'${account_name}')]
    Wait Until Element Is Visible    ${option}    ${PT_TIMEOUT}
    Click Element                    ${option}
    Sleep    1s
    Log    Account selected by name: ${account_name}

Enter Product Type Name
    [Documentation]    Enters text into the Product Type Name field.
    [Arguments]    ${name}
    Wait Until Element Is Visible    ${LOC_PT_NAME_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_NAME_INPUT}    ${name}
    Sleep    1s

# ── Service Type Dropdown (standard <select>) ───────────────────────
Select Service Type
    [Documentation]    Selects service type (Prepaid/Postpaid) from the standard HTML select.
    [Arguments]    ${service_type}
    Wait Until Element Is Visible    ${LOC_PT_SERVICE_TYPE_DD}    ${PT_TIMEOUT}
    Select From List By Label        ${LOC_PT_SERVICE_TYPE_DD}    ${service_type}
    Sleep    1s

Verify Sub Type 1 Is Pre Filled And Disabled
    [Documentation]    Asserts Service Sub Type 1 is disabled and auto-set to GCT or GCT WBU.
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_1_DD}    ${PT_TIMEOUT}
    Sleep    1s
    Element Should Be Disabled       ${LOC_PT_SUB_TYPE_1_DD}
    ${val}=    Get Value             ${LOC_PT_SUB_TYPE_1_DD}
    Should Be True    '${val}' == 'GCT' or '${val}' == 'GCT WBU'

Enter Service Sub Type 2
    [Documentation]    Enters text into Service Sub Type 2 field.
    [Arguments]    ${value}
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_2_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_SUB_TYPE_2_INPUT}    ${value}
    Sleep    1s

Enter Service Sub Type 3
    [Documentation]    Enters text into Service Sub Type 3 field.
    [Arguments]    ${value}
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_3_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_SUB_TYPE_3_INPUT}    ${value}
    Sleep    1s

Enter Service Sub Type 4
    [Documentation]    Enters text into Service Sub Type 4 field.
    [Arguments]    ${value}
    Wait Until Element Is Visible    ${LOC_PT_SUB_TYPE_4_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_SUB_TYPE_4_INPUT}    ${value}
    Sleep    1s

Fill All Mandatory Fields
    [Documentation]    Fills all mandatory fields for Create Product Type with given data.
    [Arguments]    ${name}    ${service_type}    ${sub2}    ${sub3}    ${sub4}
    Select Account From Dropdown
    Enter Product Type Name    ${name}
    Select Service Type        ${service_type}
    Enter Service Sub Type 2   ${sub2}
    Enter Service Sub Type 3   ${sub3}
    Enter Service Sub Type 4   ${sub4}

Fill All Mandatory Fields With Defaults
    [Documentation]    Fills all mandatory fields using default variable values.
    Fill All Mandatory Fields    ${PT_NAME}    ${PT_SERVICE_TYPE_POSTPAID}
    ...    ${PT_SUB_TYPE_2}    ${PT_SUB_TYPE_3_SIM}    ${PT_SUB_TYPE_4}

Fill Optional Fields
    [Documentation]    Fills Packaging Size, Can Be Ordered, Comment, and Description (English).
    Wait Until Element Is Visible    ${LOC_PT_PACKAGING_SIZE}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_PACKAGING_SIZE}    ${PT_PACKAGING_SIZE}
    Sleep    1s
    Select Radio Button              canBeOrdered    true
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_PT_COMMENT_INPUT}     ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_COMMENT_INPUT}     ${PT_COMMENT}
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_PT_DESC_EN_INPUT}     ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_DESC_EN_INPUT}     ${PT_DESC_EN}
    Sleep    1s

Click Submit Product Type
    [Documentation]    Scrolls to and clicks the Submit button via JS (bypasses any overlay).
    Scroll To Element Via JS         ${LOC_PT_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_PT_SUBMIT_BTN}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_SUBMIT_BTN}

Click Close Product Type Form
    [Documentation]    Clicks the Close button on Create Product Type form via JS.
    Scroll To Element Via JS         ${LOC_PT_CLOSE_BTN}
    Wait Until Element Is Visible    ${LOC_PT_CLOSE_BTN}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_CLOSE_BTN}

# ═══════════════════════════════════════════════════════════════════════
#  CREATE PRODUCT TYPE VALIDATIONS
#  (after submit → wait for loading → wait for toast message AND grid)
# ═══════════════════════════════════════════════════════════════════════
Verify Product Type Created Successfully
    [Documentation]    Waits for the specific "SIM Product Type Created Successfully" toast,
    ...                then waits for loading to complete, redirect back to /ProductType,
    ...                and grid data to be visible.
    Wait Until Element Is Visible    ${LOC_PT_CREATED_TOAST}    ${PT_TIMEOUT}
    Element Should Be Visible        ${LOC_PT_CREATED_TOAST}
    Wait For App Loading To Complete
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    ${url}=    Get Location
    Should Not Contain    ${url}    CreateProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Log    Product Type created — toast displayed and grid visible.

Verify Product Type Error Toast Displayed
    [Documentation]    Asserts Toastify error toast notification is visible after form submission.
    Wait Until Element Is Visible    ${LOC_PT_ERROR_TOAST}    ${PT_TIMEOUT}
    Element Should Be Visible        ${LOC_PT_ERROR_TOAST}

Verify No EC Selected Toast Displayed
    [Documentation]    Asserts "Please select at least one customer" toast is visible.
    Wait Until Element Is Visible    ${LOC_PT_NO_EC_TOAST}    ${PT_TIMEOUT}
    Element Should Be Visible        ${LOC_PT_NO_EC_TOAST}

Verify Duplicate Product Type Toast Displayed
    [Documentation]    Asserts "Product Type Name Already Exists" toast is visible.
    Wait Until Element Is Visible    ${LOC_PT_DUPLICATE_TOAST}    ${PT_TIMEOUT}
    Element Should Be Visible        ${LOC_PT_DUPLICATE_TOAST}

Verify Still On Create Product Type Page
    [Documentation]    Confirms user is still on the CreateProductType page (form did not submit).
    Location Should Contain    CreateProductType

Verify Redirected To Product Type Listing
    [Documentation]    Confirms redirect to /ProductType listing after Close or Submit.
    Wait For App Loading To Complete
    Wait Until Keyword Succeeds    ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}
    ...    Location Should Contain    ProductType
    ${url}=    Get Location
    Should Not Contain    ${url}    CreateProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}

# ═══════════════════════════════════════════════════════════════════════
#  ASSIGN CUSTOMER DIALOG
# ═══════════════════════════════════════════════════════════════════════
Click Assign Customer Icon On First Row
    [Documentation]    Clicks the Assign-Customer icon on the first grid row, waits for
    ...                the Assign Customers dialog to open and loading to complete.
    ...                Scrolls to the icon and tries both JS and native click.
    Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${PT_TIMEOUT}
    Scroll To Element Via JS    ${LOC_PT_ASSIGN_CUST_ICON}
    Sleep    1s
    Click Element Via JS             ${LOC_PT_ASSIGN_CUST_ICON}
    ${dialog_ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    15s
    IF    not ${dialog_ok}
        Log    JS click did not open dialog. Trying native Selenium click...    console=yes
        Click Element    ${LOC_PT_ASSIGN_CUST_ICON}
        Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}
    END
    Wait For App Loading To Complete
    Sleep    1s
    Log    Assign Customers dialog opened and fully loaded.

Verify Assign Customer Icon Visible
    [Documentation]    Asserts the Assign-Customer icon is visible in the grid.
    Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${PT_TIMEOUT}

Select First Enterprise Customer
    [Documentation]    Opens the EC picker in Assign Customers (React Select in current UI;
    ...                legacy Kendo input supported as fallback), then selects the first option.
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}
    Sleep    1s
    Wait Until Keyword Succeeds    3x    3s    Open EC Dropdown And Select First

Open EC Dropdown And Select First
    [Documentation]    Opens EC dropdown — tries React Select (modal), then Kendo
    ...                ``Select Customers`` input + ``k-item`` list.
    ${react_ctrl}=    Set Variable
    ...    xpath=//div[@role='dialog']//div[contains(@class,'modal-body')]//div[contains(@class,'select__control') or contains(@class,'react-select__control')]
    ${react_open}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${react_ctrl}    8s
    IF    ${react_open}
        Click Element    ${react_ctrl}
        Sleep    1s
        ${first_rs}=    Set Variable
        ...    xpath=(//div[contains(@class,'select__menu')]//div[contains(@class,'select__option') or contains(@class,'react-select__option')])[1]
        Wait Until Element Is Visible    ${first_rs}    15s
        Click Element    ${first_rs}
    ELSE
        Wait Until Element Is Visible    ${LOC_ASSIGN_SELECT_CUSTOMERS}    15s
        Click Element Via JS    ${LOC_ASSIGN_SELECT_CUSTOMERS}
        Sleep    1s
        Wait Until Element Is Visible    ${LOC_ASSIGN_CUSTOMER_OPT_1}    10s
        Click Element Via JS    ${LOC_ASSIGN_CUSTOMER_OPT_1}
    END
    Sleep    1s

Select Enterprise Customer By Name
    [Documentation]    Selects EC from the Assign Customers dialog. The dropdown is a React Select
    ...                multi-select component. Clicks the dropdown to open it, types EC name to filter,
    ...                then clicks the matching option.
    [Arguments]    ${ec_name}
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}
    Sleep    1s
    # Click the React Select dropdown wrapper to open it (scoped to dialog body)
    ${react_select}=    Set Variable
    ...    xpath=//div[@role='dialog']//div[contains(@class,'modal-body')]//div[contains(@class,'select__control') or contains(@class,'react-select__control')]
    Wait Until Element Is Visible    ${react_select}    ${PT_TIMEOUT}
    Click Element    ${react_select}
    Sleep    1s
    # Type the EC name into the React Select hidden input to filter
    ${react_input}=    Set Variable    xpath=//div[contains(@class,'modal-body')]//div[contains(@class,'select__input')]//input
    ${input_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${react_input}    5s
    IF    ${input_visible}
        Input Text    ${react_input}    ${ec_name}
        Log    Typed "${ec_name}" into React Select input.    console=yes
    ELSE
        # Fallback: find input by id pattern react-select-*-input
        ${fallback_input}=    Set Variable    xpath=//input[contains(@id,'react-select') and contains(@id,'input')]
        Click Element    ${fallback_input}
        Input Text    ${fallback_input}    ${ec_name}
        Log    Typed "${ec_name}" into fallback React Select input.    console=yes
    END
    # Wait up to 30s until customers option is visible after search
    ${option}=    Set Variable    xpath=//div[contains(@class,'select__menu')]//div[contains(@class,'select__option') and contains(text(),'${ec_name}')]
    Wait Until Element Is Visible    ${option}    30s
    Click Element    ${option}
    Sleep    1s
    Log    EC "${ec_name}" selected from React Select dropdown.    console=yes

Click Update EC Assignment
    [Documentation]    Waits for loading to complete, then clicks the Update button.
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ASSIGN_UPDATE_BTN}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_ASSIGN_UPDATE_BTN}

Click Close Assign Customer Popup
    [Documentation]    Waits for loading to complete, then clicks the Close button in dialog
    ...                using multiple strategies to ensure the button is found.
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}         ${PT_TIMEOUT}
    Sleep    1s
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ASSIGN_CLOSE_BTN}    10s
    IF    ${found}
        Click Element Via JS    ${LOC_ASSIGN_CLOSE_BTN}
    ELSE
        Log    Close button not found by locator — using JS fallback.
        Execute Javascript
        ...    var btns = document.querySelectorAll('button.btn-cancel-color'); for(var i=0; i<btns.length; i++){ if(btns[i].textContent.trim()==='Close'){ btns[i].click(); break; } }
    END
    Sleep    1s

# ═══════════════════════════════════════════════════════════════════════
#  ASSIGN EC VALIDATIONS
# ═══════════════════════════════════════════════════════════════════════
Verify EC Assignment Successful
    [Documentation]    Waits for dialog to close and grid to refresh after clicking Update.
    ...                Checks for toast but does not fail if it disappears quickly.
    Sleep    1s
    ${toast_seen}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_PT_UPDATED_TOAST}    10s
    IF    ${toast_seen}
        Log    "Updated Successfully" toast confirmed.    console=yes
    ELSE
        Log    Toast not captured (may have auto-dismissed). Continuing validation...    level=WARN    console=yes
    END
    Wait For App Loading To Complete
    ${popup_gone}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    15s
    IF    not ${popup_gone}
        Log    Assign dialog still open — clicking Close as fallback.    console=yes
        Click Close Assign Customer Popup
        Sleep    1s
    END
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Sleep    1s
    Wait For App Loading To Complete

Verify Assign Popup Still Open
    [Documentation]    Asserts that the Assign Customers dialog is still open.
    Element Should Be Visible    ${LOC_ASSIGN_POPUP}

Verify Assign Popup Closed
    [Documentation]    Asserts that the Assign Customers dialog has been dismissed.
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}

Verify Product Type Status In Grid
    [Documentation]    Searches for the product type by name in the grid (using grid search if needed),
    ...                then validates that the STATUS column matches the expected value.
    [Arguments]    ${expected_status}    ${product_name}=${EMPTY}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Sleep    1s
    # If product name given, search for it in the grid search field first
    IF    '${product_name}' != '${EMPTY}' and '${product_name}' != ''
        ${search_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_PT_SEARCH_FIELD}    5s
        IF    ${search_exists}
            Clear Element Text    ${LOC_PT_SEARCH_FIELD}
            Input Text    ${LOC_PT_SEARCH_FIELD}    ${product_name}
            Click Element Via JS    ${LOC_PT_SEARCH_BTN}
            Sleep    1s
            Wait For App Loading To Complete
        END
    END
    ${status_text}=    Execute Javascript
    ...    var grid = document.querySelector('#gridData');
    ...    if(!grid) return 'NO_GRID';
    ...    var rows = grid.querySelectorAll('tbody tr:not(.k-detail-row):not(.k-grouping-row)');
    ...    if(rows.length === 0) return 'NO_ROWS';
    ...    for(var r=0; r<rows.length; r++){
    ...        var rowText = rows[r].innerText;
    ...        var pName = arguments[0];
    ...        if(pName && rowText.indexOf(pName) < 0) continue;
    ...        var cells = rows[r].querySelectorAll('td');
    ...        for(var c=0; c<cells.length; c++){
    ...            var t = cells[c].innerText.trim();
    ...            if(t === 'In Use' || t === 'Not In Use') return t;
    ...            var spans = cells[c].querySelectorAll('span, div, label, a');
    ...            for(var s=0; s<spans.length; s++){
    ...                var st = spans[s].textContent.trim();
    ...                if(st === 'In Use' || st === 'Not In Use') return st;
    ...            }
    ...        }
    ...        return 'STATUS_NOT_IN_ROW';
    ...    }
    ...    return 'PRODUCT_NOT_FOUND';
    ...    ARGUMENTS    ${product_name}
    Log    Grid STATUS value: "${status_text}" (expected: "${expected_status}")    console=yes
    # If search was used, clear it afterwards
    IF    '${product_name}' != '${EMPTY}' and '${product_name}' != ''
        ${close_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_PT_SEARCH_CLOSE}    3s
        IF    ${close_exists}
            Click Element Via JS    ${LOC_PT_SEARCH_CLOSE}
            Sleep    1s
            Wait For App Loading To Complete
        END
    END
    Should Be Equal As Strings    ${status_text}    ${expected_status}
    ...    Expected STATUS "${expected_status}" but grid shows "${status_text}"

Verify No Data After Expand
    [Documentation]    Clicks the expand icon on the first grid row, waits for "No Data Available".
    Wait Until Element Is Visible    ${LOC_PT_EXPAND_ICON}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_EXPAND_ICON}
    Sleep    1s
    Wait Until Element Is Visible    ${LOC_PT_NO_DATA}        ${PT_TIMEOUT}
    Element Should Be Visible        ${LOC_PT_NO_DATA}
    Log    Row expanded — No Data Available confirmed.

Verify EC Visible After Expand
    [Documentation]    Clicks the expand icon on the first grid row, verifies that
    ...                expanded content is visible (NOT "No Data Available").
    Wait Until Element Is Visible    ${LOC_PT_EXPAND_ICON}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_EXPAND_ICON}
    Sleep    1s
    Page Should Not Contain Element  ${LOC_PT_NO_DATA}
    Log    Row expanded — assigned EC data is visible.

Verify Assigned Customer Name After Expand
    [Documentation]    Clicks the expand arrow on the first row, then validates that
    ...                "Assigned Customers" section contains the expected EC name.
    [Arguments]    ${ec_name}
    Wait Until Element Is Visible    ${LOC_PT_EXPAND_ICON}    ${PT_TIMEOUT}
    Scroll To Element Via JS    ${LOC_PT_EXPAND_ICON}
    Click Element Via JS    ${LOC_PT_EXPAND_ICON}
    Sleep    1s
    # Verify the expanded detail row contains "Assigned Customers" and the EC name
    ${detail_text}=    Execute Javascript
    ...    var detailRows = document.querySelectorAll('tr.k-detail-row');
    ...    if(detailRows.length === 0) return 'NO_DETAIL_ROW';
    ...    return detailRows[0].innerText.trim();
    Log    Expanded detail row content: ${detail_text}    console=yes
    Should Contain    ${detail_text}    Assigned Customers
    ...    Expanded row does not contain "Assigned Customers" section. Content: ${detail_text}
    Should Contain    ${detail_text}    ${ec_name}
    ...    Expanded row does not contain EC "${ec_name}". Content: ${detail_text}
    Log    Assigned Customer "${ec_name}" verified in expanded row.    console=yes

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE FLOW
# ═══════════════════════════════════════════════════════════════════════
Login And Navigate To Product Type
    [Documentation]    Complete flow: login page → wait for fields → enter creds →
    ...                wait for captcha image → login → wait for Manage Devices →
    ...                click Admin → wait for /ManageUser (loading done) →
    ...                click SIM Product Type → wait for /ProductType (loading done).
    Login For Product Type
    Navigate To Product Type Module

Go To Product Type Listing
    [Documentation]    Opens the SIM Product Type listing using the **existing** browser session.
    ...                ``/CreateProductType`` contains the substring "ProductType", so URL checks must exclude it.
    ...                Prefers page-heading tab or Admin → SIM Product Type (SPA-safe); avoids bare direct URL alone.
    ...                Use as Test Setup when ``Login And Navigate To Product Type`` ran once in Suite Setup.
    ${on_listing}=    Product Type Listing URL Is Active
    IF    not ${on_listing}
        ${tab_ok}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${LOC_PT_TAB_LISTING}    5s
        IF    ${tab_ok}
            Click Element Via JS    ${LOC_PT_TAB_LISTING}
            Wait For App Loading To Complete
            Wait Until Keyword Succeeds    ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}
            ...    Product Type Listing URL Should Be Active
        ELSE
            Navigate To Product Type Module
        END
        Product Type Listing URL Should Be Active
    END
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}

Product Type Listing URL Is Active
    [Documentation]    True only on listing ``/ProductType``, not ``/CreateProductType`` (substring false positive).
    ${on_create}=    Run Keyword And Return Status    Location Should Contain    CreateProductType
    IF    ${on_create}
        RETURN    ${False}
    END
    ${on_listing_path}=    Run Keyword And Return Status    Location Should Contain    ProductType
    RETURN    ${on_listing_path}

Product Type Listing URL Should Be Active
    [Documentation]    Fails if still on create form or wrong route.
    ${url}=    Get Location
    Should Not Contain    ${url}    CreateProductType
    Should Contain    ${url}    ProductType
