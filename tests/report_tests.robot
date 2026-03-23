*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/report_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/report_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/report_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers
Test Teardown     Handle Test Teardown


*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  POSITIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_015_001 Create Report Happy Path And Validate Grid
    [Documentation]    Create Data Usage report (DAY, OPCO, CSV). Verify success toast,
    ...                redirect to /Report, wait for grid, filter by report name,
    ...                validate first row REPORT NAME and Delete/Download icons.
    [Tags]    smoke    regression    positive    report
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Submit Create Report Form
    Verify Report Created Successfully And Grid Visible
    Apply Report Name Filter    ${REPORT_CATEGORY_NAME}
    Validate First Row Report Name    ${REPORT_CATEGORY_NAME}
    Validate Delete And Download Icons In First Row

TC_015_002 Create Report And Download File
    [Documentation]    Create report, then click Download in first row and verify no error.
    [Tags]    regression    positive    report    download
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Submit Create Report Form
    Verify Report Created Successfully And Grid Visible
    Download Report From First Row And Verify Click    ${REPORT_CATEGORY_NAME}

TC_015_003 Create Report With Send Email
    [Documentation]    Create report with Send Email enabled and one recipient.
    [Tags]    regression    positive    report    email
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Enable Send Email
    Add Email Recipient    ${EMAIL_RECIPIENT}
    Submit Create Report Form
    Verify Report Created Successfully

TC_015_004 Create Report Weekly View
    [Documentation]    Create Data Usage report with WEEK view criterion.
    [Tags]    regression    positive    report    extended
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_WEEK}
    Wait For From Date Picker
    Wait Until Element Is Visible    ${LOC_INPUT_TO_DATE}    timeout=10s
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Submit Create Report Form
    Verify Report Created Successfully

TC_015_005 Create Report Monthly View
    [Documentation]    Create Data Usage report with MONTH view criterion.
    [Tags]    regression    positive    report    extended
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_MONTH}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Submit Create Report Form
    Verify Report Created Successfully

TC_015_006 Create Report PDF Format
    [Documentation]    Create Data Usage report in PDF format.
    [Tags]    regression    positive    report    extended
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_PDF}
    Submit Create Report Form
    Verify Report Created Successfully

TC_015_007 Create Report XLSX Format
    [Documentation]    Create Data Usage report in XLSX format.
    [Tags]    regression    positive    report    extended
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_XLSX}
    Submit Create Report Form
    Verify Report Created Successfully

TC_015_008 Close Button Redirects To Report Listing
    [Documentation]    Fill form partially, click Close; verify redirect to /Report.
    [Tags]    regression    positive    report    navigation
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Click Element Via JS    ${LOC_BTN_CLOSE}
    Verify Redirect To Report Listing

# ═══════════════════════════════════════════════════════════════════════
#  NEGATIVE TEST CASES
# ═══════════════════════════════════════════════════════════════════════

TC_015_NEG_01 No Report Category Should Show Error
    [Documentation]    Submit without selecting Report Category; expect validation error.
    [Tags]    regression    negative    report
    Navigate To Reports Page
    Open Create Report Form
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Click Element Via JS    ${LOC_BTN_CREATE}
    Verify Validation Error Report Category
    Verify Still On Create Report Page

TC_015_NEG_02 No View Criterion Should Show Error
    [Documentation]    Select Report Category but not View Criterion; expect validation error.
    [Tags]    regression    negative    report
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Click Element Via JS    ${LOC_BTN_CREATE}
    Verify Validation Error View Criterion
    Verify Still On Create Report Page

TC_015_NEG_03 No Display Level Should Show Error
    [Documentation]    Select category and view criterion but not Display Level; expect error.
    [Tags]    regression    negative    report
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Click Element Via JS    ${LOC_BTN_CREATE}
    Verify Validation Error Display Level
    Verify Still On Create Report Page

TC_015_NEG_04 No Report Format Should Show Error
    [Documentation]    Fill all except Report Format; expect validation error.
    [Tags]    regression    negative    report
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Click Element Via JS    ${LOC_BTN_CREATE}
    Verify Validation Error Report Format
    Verify Still On Create Report Page

TC_015_NEG_05 Send Email Without Recipients Should Show Error
    [Documentation]    Enable Send Email but add no recipient; expect error toast.
    [Tags]    regression    negative    report    email
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Verify Account Auto Selected
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Enable Send Email
    Click Element Via JS    ${LOC_BTN_CREATE}
    Verify Error Toast Shown
    Verify Still On Create Report Page

TC_015_NEG_06 Close Without Submit Redirects To Report
    [Documentation]    Fill form, click Close; verify redirect to /Report, no success toast.
    [Tags]    regression    negative    report
    Navigate To Reports Page
    Open Create Report Form
    Select Report Category    ${REPORT_CATEGORY_NAME}
    Select View Criterion    ${VIEW_CRITERION_VALUE}
    Wait For From Date Picker
    Select Display Level    ${DISPLAY_LEVEL_VALUE}
    Select Report Format    ${REPORT_FORMAT_VALUE}
    Click Element Via JS    ${LOC_BTN_CLOSE}
    Verify Redirect To Report Listing
