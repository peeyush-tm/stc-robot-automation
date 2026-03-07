*** Settings ***
Library    SeleniumLibrary
Resource   ../locators/product_type_locators.resource

*** Variables ***
${PT_TIMEOUT}         30s
${PT_RETRY_COUNT}     3x
${PT_RETRY_INTERVAL}  5s

*** Keywords ***
# ══════════════════════════════════════════════════════════════════════════════
# COMMON — Wait for loading overlay to disappear
# ══════════════════════════════════════════════════════════════════════════════
Wait For Loading To Complete
    [Documentation]    Wait for the body loading-indicator overlay to disappear before interacting with elements.
    ${loading}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_LOADING_OVERLAY}
    IF    ${loading}
        Wait Until Element Is Not Visible    ${LOC_LOADING_OVERLAY}    ${PT_TIMEOUT}
    END
    Sleep    1s

# ══════════════════════════════════════════════════════════════════════════════
# NAVIGATION — Wait on Manage Devices → click Admin icon → click SIM Product Type
# ══════════════════════════════════════════════════════════════════════════════
Navigate To Product Type Module
    [Documentation]    Wait 10s on Manage Devices → click Admin icon (navigates to /ManageUser) → wait 10s → click SIM Product Type (navigates to /ProductType) → wait 10s → verify listing page.
    Sleep    10s
    Wait Until Element Is Visible    ${LOC_ADMIN_ICON}    ${PT_TIMEOUT}
    Scroll Element Into View         ${LOC_ADMIN_ICON}
    Click Element                    ${LOC_ADMIN_ICON}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}    Location Should Contain    ManageUser
    Sleep    10s
    Wait Until Page Contains Element    ${LOC_PRODUCT_TYPE_NAV}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PRODUCT_TYPE_NAV}    ${PT_TIMEOUT}
    Scroll Element Into View         ${LOC_PRODUCT_TYPE_NAV}
    Execute JavaScript    document.querySelector('a[href="/ProductType"]').click();
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}    Location Should Contain    ProductType
    Sleep    10s
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_CREATE_PT_BTN}    ${PT_TIMEOUT}

Navigate To Product Type Module Via URL
    [Documentation]    Direct URL navigation to /ProductType — reliable for headless/CI.
    Go To                            ${PRODUCT_TYPE_URL}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}    Location Should Contain    ProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_CREATE_PT_BTN}    ${PT_TIMEOUT}

# ══════════════════════════════════════════════════════════════════════════════
# WORKFLOW A — Create SIM Product Type
# ══════════════════════════════════════════════════════════════════════════════
Open Create Product Type Form
    [Documentation]    Click Create Product Type button and wait for /CreateProductType form to load.
    Wait Until Element Is Visible    ${LOC_CREATE_PT_BTN}    ${PT_TIMEOUT}
    Click Element                    ${LOC_CREATE_PT_BTN}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}    Location Should Contain    CreateProductType
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${PT_TIMEOUT}

Select Account From Dropdown
    [Documentation]    Click the custom Account dropdown to open it, then click KSA_OPCO option.
    Wait Until Element Is Visible    ${LOC_ACCOUNT_DD}    ${PT_TIMEOUT}
    Click Element                    ${LOC_ACCOUNT_DD}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_SEARCH}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_OPTION_KSA}    ${PT_TIMEOUT}
    Click Element                    ${LOC_ACCOUNT_OPTION_KSA}

Enter Product Type Name
    [Arguments]    ${pt_name}
    [Documentation]    Enter product type name (name=productCatalogName, max 50 chars).
    Wait Until Element Is Visible    ${LOC_PT_NAME_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PT_NAME_INPUT}    ${pt_name}

Select Service Type
    [Arguments]    ${service_type}
    [Documentation]    Select Prepaid or Postpaid from Service Type dropdown (data-testid=servicetypeet).
    Wait Until Element Is Visible    ${LOC_SERVICE_TYPE_DD}    ${PT_TIMEOUT}
    Select From List By Label        ${LOC_SERVICE_TYPE_DD}    ${service_type}

Verify Sub Type 1 Pre Filled
    [Documentation]    Assert Service Sub Type 1 is disabled and auto-set to GCT or GCT WBU.
    Wait Until Element Is Visible    ${LOC_SUB_TYPE_1_DD}    ${PT_TIMEOUT}
    Element Should Be Disabled       ${LOC_SUB_TYPE_1_DD}
    ${val}=                          Get Value    ${LOC_SUB_TYPE_1_DD}
    Should Be True                   '${val}' == 'GCT' or '${val}' == 'GCT WBU'

Enter Service Sub Type 2
    [Arguments]    ${value}
    Wait Until Element Is Visible    ${LOC_SUB_TYPE_2_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_SUB_TYPE_2_INPUT}    ${value}

Enter Service Sub Type 3
    [Arguments]    ${value}
    [Documentation]    Enter SIM category (SIM / esim). If esim, Profile Name becomes required.
    Wait Until Element Is Visible    ${LOC_SUB_TYPE_3_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_SUB_TYPE_3_INPUT}    ${value}

Enter Service Sub Type 3 With Profile
    [Arguments]    ${sub_type_3}    ${profile_name}
    [Documentation]    Enter esim in Sub Type 3 and fill the required Profile Name field.
    Enter Service Sub Type 3         ${sub_type_3}
    Wait Until Element Is Visible    ${LOC_PROFILE_NAME}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PROFILE_NAME}    ${profile_name}

Enter Service Sub Type 4
    [Arguments]    ${value}
    Wait Until Element Is Visible    ${LOC_SUB_TYPE_4_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_SUB_TYPE_4_INPUT}    ${value}

Fill Optional Fields
    [Arguments]    ${packaging_size}    ${comment}    ${desc_en}
    [Documentation]    Fill Packaging Size, select Can Be Ordered = Yes, enter Comment and Description (English).
    Wait Until Element Is Visible    ${LOC_PACKAGING_SIZE}    ${PT_TIMEOUT}
    Input Text                       ${LOC_PACKAGING_SIZE}    ${packaging_size}
    Select Radio Button              canBeOrdered    true
    Wait Until Element Is Visible    ${LOC_COMMENT_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_COMMENT_INPUT}    ${comment}
    Wait Until Element Is Visible    ${LOC_DESC_EN_INPUT}    ${PT_TIMEOUT}
    Input Text                       ${LOC_DESC_EN_INPUT}    ${desc_en}

Submit Product Type Form
    [Documentation]    Scroll to and click Submit <a> button; wait for success toast.
    Scroll Element Into View         ${LOC_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_SUBMIT_BTN}    ${PT_TIMEOUT}
    Click Element                    ${LOC_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}    ${PT_TIMEOUT}

Click Submit Without Waiting For Success
    [Documentation]    Click Submit but do NOT wait for success toast (for negative tests expecting validation errors).
    Scroll Element Into View         ${LOC_SUBMIT_BTN}
    Wait Until Element Is Visible    ${LOC_SUBMIT_BTN}    ${PT_TIMEOUT}
    Click Element                    ${LOC_SUBMIT_BTN}

Click Close Button On Create Form
    [Documentation]    Click Close <a> button on the Create form — navigates back to /ProductType without saving.
    Scroll Element Into View         ${LOC_CLOSE_BTN}
    Wait Until Element Is Visible    ${LOC_CLOSE_BTN}    ${PT_TIMEOUT}
    Click Element                    ${LOC_CLOSE_BTN}

Validate Product Type Creation
    [Documentation]    Assert success toast, redirect to /ProductType (not CreateProductType), and grid visible.
    Element Should Be Visible        ${LOC_SUCCESS_TOAST}
    Page Should Not Contain Element  ${LOC_ERROR_TOAST}
    Wait Until Keyword Succeeds      ${PT_RETRY_COUNT}    ${PT_RETRY_INTERVAL}    Location Should Contain    ProductType
    ${url}=    Get Location
    Should Not Contain    ${url}    CreateProductType
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}

Verify Still On Create Form
    [Documentation]    Assert we are still on /CreateProductType (submit was blocked by validation).
    Location Should Contain    CreateProductType

Verify Error Toast Visible
    [Documentation]    Assert error toast notification is displayed.
    Wait Until Element Is Visible    ${LOC_ERROR_TOAST}    ${PT_TIMEOUT}

# ══════════════════════════════════════════════════════════════════════════════
# WORKFLOW B — Assign EC to Product Type
# ══════════════════════════════════════════════════════════════════════════════
Click Assign Customer Icon On First Row
    [Documentation]    Click Assign-Customer icon (k-grid-Assign-Customer) on the first visible row.
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_ASSIGN_CUST_ICON}    ${PT_TIMEOUT}
    Click Element                    ${LOC_ASSIGN_CUST_ICON}
    Wait For Loading To Complete
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}

Select Enterprise Customer From Popup
    [Documentation]    Open EC react-select dropdown by focusing the input, then select first available EC.
    Wait Until Element Is Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}
    Wait For Loading To Complete
    Wait Until Element Is Visible    ${LOC_CUSTOMERS_DD_CTRL}    ${PT_TIMEOUT}
    # Focus and click the react-select input to open the dropdown
    Execute JavaScript    var el = document.querySelector('#AssignCustomerPopup [class*="select__control"]'); if(el) el.click();
    Sleep    2s
    # If menu still not open, try clicking the input directly
    ${menu_open}=    Run Keyword And Return Status    Element Should Be Visible    ${LOC_CUSTOMERS_MENU}
    IF    not ${menu_open}
        Wait Until Element Is Visible    ${LOC_CUSTOMERS_INPUT}    ${PT_TIMEOUT}
        Click Element                    ${LOC_CUSTOMERS_INPUT}
    END
    Wait Until Element Is Visible    ${LOC_CUSTOMERS_MENU}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_CUSTOMER_OPT_1}    ${PT_TIMEOUT}
    Click Element                    ${LOC_CUSTOMER_OPT_1}
    Wait Until Element Is Not Visible    ${LOC_CUSTOMERS_MENU}    ${PT_TIMEOUT}

Select All Enterprise Customers
    [Documentation]    Click Select All = Yes radio; this disables the multi-select and submits all ECs.
    Wait Until Element Is Visible    ${LOC_SEL_ALL_YES}    ${PT_TIMEOUT}
    Click Element                    ${LOC_SEL_ALL_YES}

Submit EC Assignment
    [Documentation]    Click Update button inside #AssignCustomerPopup; wait for success toast.
    Wait For Loading To Complete
    Scroll Element Into View         ${LOC_ASSIGN_UPDATE_BTN}
    Wait Until Element Is Visible    ${LOC_ASSIGN_UPDATE_BTN}    ${PT_TIMEOUT}
    Execute JavaScript    document.querySelector('#customers button.btn-custom-color').click();
    Wait Until Element Is Visible    ${LOC_SUCCESS_TOAST}    ${PT_TIMEOUT}

Click Update Without Selecting EC
    [Documentation]    Click Update without selecting any EC (for negative test).
    Wait For Loading To Complete
    Scroll Element Into View         ${LOC_ASSIGN_UPDATE_BTN}
    Wait Until Element Is Visible    ${LOC_ASSIGN_UPDATE_BTN}    ${PT_TIMEOUT}
    Execute JavaScript    document.querySelector('#customers button.btn-custom-color').click();

Close Assign Customer Popup
    [Documentation]    Click Close button inside the popup without saving.
    Wait For Loading To Complete
    Scroll Element Into View         ${LOC_ASSIGN_CLOSE_BTN}
    Wait Until Element Is Visible    ${LOC_ASSIGN_CLOSE_BTN}    ${PT_TIMEOUT}
    Execute JavaScript    document.querySelector('#customers button.btn-cancel-color').click();
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}

Validate EC Assignment Success
    [Documentation]    Assert success toast, popup closed, and listing grid refreshed.
    Element Should Be Visible        ${LOC_SUCCESS_TOAST}
    Wait Until Element Is Not Visible    ${LOC_ASSIGN_POPUP}    ${PT_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_PT_GRID_DATA}    ${PT_TIMEOUT}
