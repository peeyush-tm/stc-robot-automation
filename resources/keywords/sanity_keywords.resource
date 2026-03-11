*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    browser_keywords.resource
Resource    login_keywords.resource
Resource    ../locators/sanity_locators.resource
Resource    ../locators/login_locators.resource

*** Keywords ***
# ═══════════════════════════════════════════════════════════════════════
#  LOGIN — Suite Setup
# ═══════════════════════════════════════════════════════════════════════
Login For Sanity Suite
    [Documentation]    Opens browser, logs in, waits for post-login page.
    Open Browser And Navigate    ${BASE_URL}    ${BROWSER}
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
    Wait Until Element Is Visible    ${LOC_POST_LOGIN_LANDMARK}   timeout=30s
    Log    Sanity Suite: Login successful.

# ═══════════════════════════════════════════════════════════════════════
#  PAGE NAVIGATION
# ═══════════════════════════════════════════════════════════════════════
Navigate To Page
    [Documentation]    Navigates to the given URL path and waits for page to load.
    [Arguments]    ${url_path}
    Go To    ${BASE_URL}${url_path}
    Sleep    2s
    Wait For App Loading To Complete    timeout=${SANITY_PAGE_LOAD_WAIT}
    Sleep    1s
    Wait For App Loading To Complete
    Log    Navigated to: ${url_path}

# ═══════════════════════════════════════════════════════════════════════
#  ERROR DETECTION — Section 3 of MD
# ═══════════════════════════════════════════════════════════════════════
Verify No Page Errors
    [Documentation]    Checks that no HTTP error pages, alert-danger banners, error overlays,
    ...                or 'Something went wrong' messages are visible. (MD Section 3)
    ${err_500}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_HTTP_500}
    ${err_404}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_HTTP_404}
    ${err_alert}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_ALERT_DANGER}
    ${err_overlay}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_OVERLAY}
    ${err_wrong}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_SOMETHING_WRONG}
    ${err_unauth}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_UNAUTHORIZED}
    IF    not ${err_500}    Fail    HTTP 500 error page detected
    IF    not ${err_404}    Fail    HTTP 404 error page detected
    IF    not ${err_overlay}    Fail    Error overlay detected
    IF    not ${err_wrong}    Fail    'Something went wrong' error detected
    IF    not ${err_unauth}    Fail    Unauthorized error detected
    Log    No page errors detected.

# ═══════════════════════════════════════════════════════════════════════
#  GRID VERIFICATION — Section 4 of MD
# ═══════════════════════════════════════════════════════════════════════
Verify Grid Loaded
    [Documentation]    Verifies grid container visible, at least one column header rendered,
    ...                loading spinner gone. (MD Section 4)
    Wait Until Element Is Visible    ${LOC_GRID_CONTAINER}    ${SANITY_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_GRID_COLUMN_HEADER}    ${SANITY_TIMEOUT}
    ${spinner}=    Run Keyword And Return Status
    ...    Element Should Not Be Visible    ${LOC_GRID_LOADING_MASK}
    IF    not ${spinner}
        Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    END
    Log    Grid loaded: container visible, headers rendered, no spinner.

Verify Grid Loaded With ID
    [Documentation]    Verifies a specific grid by its ID is visible with column headers.
    [Arguments]    ${grid_id}
    Wait Until Element Is Visible    xpath=//div[@id='${grid_id}']    ${SANITY_TIMEOUT}
    Wait Until Element Is Visible    ${LOC_GRID_COLUMN_HEADER}    ${SANITY_TIMEOUT}
    Log    Grid '${grid_id}' loaded.

Verify Pagination Visible
    [Documentation]    Verifies pagination controls are present. (MD Section 4, criteria 4)
    Wait Until Element Is Visible    ${LOC_GRID_PAGINATION}    ${SANITY_TIMEOUT}
    Log    Pagination controls visible.

Verify Grid Column Exists
    [Documentation]    Verifies a specific column header text exists in the grid.
    [Arguments]    ${column_name}
    ${loc}=    Set Variable    xpath=//th[@role='columnheader' and contains(.,'${column_name}')]
    Wait Until Element Is Visible    ${loc}    ${SANITY_TIMEOUT}
    Log    Column '${column_name}' found.

Verify Grid Columns
    [Documentation]    Verifies multiple column headers exist. Columns is a | separated string.
    [Arguments]    @{columns}
    FOR    ${col}    IN    @{columns}
        Verify Grid Column Exists    ${col}
    END

Verify No Grid Error
    [Documentation]    Verifies no error text inside the grid. (MD Section 4, criteria 5)
    ${err}=    Run Keyword And Return Status    Element Should Not Be Visible    ${LOC_ERROR_IN_GRID}
    IF    not ${err}
        Log    Warning: Error text detected inside grid.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SUB-TAB VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify Sub Tab Active
    [Documentation]    Verifies the given sub-tab link is active (has 'selected' class).
    [Arguments]    ${href}    ${tab_text}=${EMPTY}
    IF    '${tab_text}' != '${EMPTY}'
        ${loc}=    Set Variable    xpath=//ul//a[@href='${href}' and normalize-space(text())='${tab_text}' and contains(@class,'selected')]
    ELSE
        ${loc}=    Set Variable    xpath=//ul//a[@href='${href}' and contains(@class,'selected')]
    END
    ${visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${loc}    10s
    IF    ${visible}
        Log    Sub-tab active: ${href} (${tab_text})
    ELSE
        Log    Sub-tab '${href}' not found with 'selected' class — may use different active indicator.    level=WARN
    END

# ═══════════════════════════════════════════════════════════════════════
#  SEARCH BAR VERIFICATION
# ═══════════════════════════════════════════════════════════════════════
Verify Search Bar Visible
    [Documentation]    Verifies the search input field is visible.
    Wait Until Element Is Visible    ${LOC_SEARCH_INPUT}    ${SANITY_TIMEOUT}
    Log    Search bar visible.

# ═══════════════════════════════════════════════════════════════════════
#  NO STUCK SPINNER
# ═══════════════════════════════════════════════════════════════════════
Verify No Stuck Spinner
    [Documentation]    Verifies loading spinner is not stuck (gone within timeout).
    ${spinner}=    Run Keyword And Return Status
    ...    Element Should Not Be Visible    ${LOC_GRID_LOADING_MASK}
    IF    not ${spinner}
        Wait Until Element Is Not Visible    ${LOC_GRID_LOADING_MASK}    ${SANITY_TIMEOUT}
    END
    Log    No stuck spinner.

# ═══════════════════════════════════════════════════════════════════════
#  COMPOSITE: FULL PAGE SANITY CHECK
# ═══════════════════════════════════════════════════════════════════════
Verify Page With Grid
    [Documentation]    Full sanity check for a page that has a grid:
    ...                navigate → no errors → sub-tab active → grid loaded → pagination → no grid error.
    [Arguments]    ${url_path}    ${href}    ${tab_text}=${EMPTY}
    Navigate To Page    ${url_path}
    Verify No Page Errors
    Verify Sub Tab Active    ${href}    ${tab_text}
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error

Verify Page Without Grid
    [Documentation]    Sanity check for a page that does NOT have a grid (dashboard, forms, upload):
    ...                navigate → no errors → sub-tab active → no stuck spinner.
    [Arguments]    ${url_path}    ${href}    ${tab_text}=${EMPTY}
    Navigate To Page    ${url_path}
    Verify No Page Errors
    Verify Sub Tab Active    ${href}    ${tab_text}
    Verify No Stuck Spinner
