*** Settings ***
Library     SeleniumLibrary
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/product_type_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  LOGIN (wait for username, password, captcha fields → enter creds →
#         wait for captcha image → enter captcha → click login →
#         wait for Manage Devices page to load fully)
# ═══════════════════════════════════════════════════════════════════════
Login For Product Type
    [Documentation]    Waits for login page fields (username, password, captcha) to be visible,
    ...                enters credentials, waits for captcha image, fetches and enters captcha,
    ...                clicks Login, then waits until Manage Devices page loads fully.
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_LOGIN_ROOT}            timeout=15s
    Wait Until Element Is Visible    ${LOC_LOGIN_USERNAME_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_PASSWORD_INPUT}  timeout=10s
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_INPUT}   timeout=10s
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Wait Until Element Is Visible    ${LOC_LOGIN_CAPTCHA_IMAGE}   timeout=20s
    Sleep    2s
    ${captcha_value}=    Fetch Captcha Value
    Enter Captcha    ${captcha_value}
    Click Login Button
    Wait For App Loading To Complete
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
    ...                the Assign Customers dialog to open.
    Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_ASSIGN_CUST_ICON}
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}           ${PT_TIMEOUT}
    Sleep    3s
    Log    Assign Customers dialog opened.

Verify Assign Customer Icon Visible
    [Documentation]    Asserts the Assign-Customer icon is visible in the grid.
    Wait Until Element Is Visible    ${LOC_PT_ASSIGN_CUST_ICON}    ${PT_TIMEOUT}

Select First Enterprise Customer
    [Documentation]    Opens the React Select dropdown in the Assign Customer dialog,
    ...                types the EC name to filter, then clicks the matching option.
    [Arguments]    ${ec_name}=${PT_EC_ACCOUNT_NAME}
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}
    Sleep    2s
    Wait Until Keyword Succeeds    3x    3s    Open React Select And Pick EC    ${ec_name}
    Sleep    1s
    Log    EC '${ec_name}' selected in Assign Customer dialog.

Open React Select And Pick EC
    [Documentation]    Opens the React Select dropdown by focusing the input, types the full
    ...                EC name using Selenium Press Keys, waits up to 30s for the API-backed
    ...                search to return results, then clicks the matching option.
    [Arguments]    ${ec_name}
    # Step 1: Focus the React Select input via JS (hidden behind placeholder)
    Execute JavaScript
    ...    var inp = document.querySelector('div[role="dialog"] input[id*="react-select"]');
    ...    if (inp) { inp.focus(); inp.style.opacity = '1'; inp.style.width = '200px'; }
    Sleep    1s
    # Step 2: Clear any previous text and type full EC name
    ${inp_loc}=    Set Variable    xpath=//div[@role='dialog']//input[contains(@id,'react-select')]
    Press Keys    ${inp_loc}    CTRL+a    BACKSPACE
    Sleep    0.5s
    Press Keys    ${inp_loc}    ${ec_name}
    Log    Typed '${ec_name}' — waiting up to 30s for search results...    console=yes
    # Step 3: Poll for matching option to appear (API search takes 20-30s)
    ${clicked}=    Set Variable    ${EMPTY}
    FOR    ${attempt}    IN RANGE    1    7
        Sleep    5s
        ${clicked}=    Execute JavaScript
        ...    var menu = document.querySelector('div[class*="select__menu"]');
        ...    if (!menu) return '';
        ...    var opts = menu.querySelectorAll('div[class*="select__option"]');
        ...    for (var i = 0; i < opts.length; i++) {
        ...        var text = opts[i].textContent.trim();
        ...        if (text === '${ec_name}') {
        ...            opts[i].scrollIntoView({block: 'nearest'});
        ...            opts[i].click();
        ...            return 'exact: ' + text;
        ...        }
        ...    }
        ...    for (var i = 0; i < opts.length; i++) {
        ...        if (opts[i].textContent.indexOf('${ec_name}') >= 0) {
        ...            opts[i].scrollIntoView({block: 'nearest'});
        ...            opts[i].click();
        ...            return 'partial: ' + opts[i].textContent.trim();
        ...        }
        ...    }
        ...    return '';
        IF    '${clicked}' != ''    BREAK
        Log    Attempt ${attempt}/6: option not yet available, waiting...    console=yes
    END
    Should Not Be Empty    ${clicked}    EC '${ec_name}' not found after 30s of polling.
    Log    EC selected: ${clicked}    console=yes

Click Update EC Assignment
    [Documentation]    Clicks the Update button inside the Assign Customer dialog.
    Sleep    2s
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOC_ASSIGN_UPDATE_BTN}    15s
    IF    ${found}
        Click Element Via JS    ${LOC_ASSIGN_UPDATE_BTN}
    ELSE
        ${clicked}=    Execute JavaScript
        ...    var btns = document.querySelectorAll('div#customers button.btn-custom-color, div.modal button.btn-custom-color');
        ...    for (var i = 0; i < btns.length; i++) {
        ...        if (btns[i].textContent.trim() === 'Update') { btns[i].click(); return true; }
        ...    }
        ...    return false;
        Should Be True    ${clicked}    Update button not found in Assign Customer dialog.
    END
    Sleep    2s
    Log    Update button clicked.

Click Close Assign Customer Popup
    [Documentation]    Waits for loading to complete, then clicks the Close button in dialog
    ...                using multiple strategies to ensure the button is found.
    Wait For App Loading To Complete
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}         ${PT_TIMEOUT}
    Sleep    3s
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
    [Documentation]    Waits for the "Updated Successfully" toast, loading complete,
    ...                dialog closed, and grid refreshed.
    Wait Until Element Is Visible      ${LOC_PT_UPDATED_TOAST}    ${PT_TIMEOUT}
    Element Should Be Visible          ${LOC_PT_UPDATED_TOAST}
    Wait For App Loading To Complete
    Wait Until Element Is Not Visible  ${LOC_ASSIGN_POPUP}        ${PT_TIMEOUT}
    Wait Until Element Is Visible      ${LOC_PT_GRID_DATA}        ${PT_TIMEOUT}

Verify Assign Popup Still Open
    [Documentation]    Asserts that the Assign Customers dialog is still open.
    Element Should Be Visible    ${LOC_ASSIGN_POPUP}

Verify Assign Popup Closed
    [Documentation]    Asserts that the Assign Customers dialog has been dismissed.
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}

Verify No Data After Expand
    [Documentation]    Clicks the expand icon on the first grid row, waits for "No Data Available".
    Wait Until Element Is Visible    ${LOC_PT_EXPAND_ICON}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_EXPAND_ICON}
    Sleep    2s
    Wait Until Element Is Visible    ${LOC_PT_NO_DATA}        ${PT_TIMEOUT}
    Element Should Be Visible        ${LOC_PT_NO_DATA}
    Log    Row expanded — No Data Available confirmed.

Verify EC Visible After Expand
    [Documentation]    Clicks the expand icon on the first grid row, verifies that
    ...                expanded content is visible (NOT "No Data Available").
    Wait Until Element Is Visible    ${LOC_PT_EXPAND_ICON}    ${PT_TIMEOUT}
    Click Element Via JS             ${LOC_PT_EXPAND_ICON}
    Sleep    2s
    Page Should Not Contain Element  ${LOC_PT_NO_DATA}
    Log    Row expanded — assigned EC data is visible.

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
