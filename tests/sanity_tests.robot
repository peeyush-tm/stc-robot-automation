*** Settings ***
Library     SeleniumLibrary
Library     String
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/sanity_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/sanity_locators.resource
Variables   ../config/env_config.py
Variables   ../variables/login_variables.py
Variables   ../variables/sanity_variables.py

Suite Setup       Login For Sanity Suite
Suite Teardown    Close All Browsers
Test Teardown     Capture Test End Screenshot    ${TEST NAME}

*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  MODULE 1 — DEVICES (TC-DEV-01 to TC-DEV-06)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_001 Manage Devices Page Loads With Grid
    [Documentation]    TC-DEV-01: Navigate to /ManageDevices.
    ...                Verify grid loads with columns REF ID, LABEL, ICCID, IMSI, MSISDN, SIM STATE,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-01
    Navigate To Page    /ManageDevices
    Verify No Page Errors
    Verify Sub Tab Active    /ManageDevices    Manage Devices
    Verify Grid Loaded
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Manage Devices

TC_SANITY_002 Upload History Page Loads With Grid
    [Documentation]    TC-DEV-02: Navigate to /UploadHistory.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-02
    Navigate To Page    /UploadHistory
    Verify No Page Errors
    Verify Sub Tab Active    /UploadHistory
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Upload History

TC_SANITY_003 Blank SIM Page Loads With Grid
    [Documentation]    TC-DEV-03: Navigate to /BlankSims.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-03
    Verify Page With Grid    /BlankSims    /BlankSims    page_name=Blank SIM

TC_SANITY_004 Lost SIM Page Loads With Grid
    [Documentation]    TC-DEV-04: Navigate to /LostSims.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-04
    Verify Page With Grid    /LostSims    /LostSims    page_name=Lost SIM

TC_SANITY_005 Pool Shared Plan Details Page Loads With Grid
    [Documentation]    TC-DEV-05: Navigate to /ManagePoolAndSharedPlanDetails.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-05
    Verify Page With Grid    /ManagePoolAndSharedPlanDetails    /ManagePoolAndSharedPlanDetails    page_name=Pool Shared Plan Details

TC_SANITY_006 Retention Cases Page Loads With Grid
    [Documentation]    TC-DEV-06: Navigate to /retentioncases.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-06
    Verify Page With Grid    /retentioncases    /retentioncases    page_name=Retention Cases

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 2 — DASHBOARD (TC-DASH-01 to TC-DASH-02)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_007 Dashboard Page Loads With Charts
    [Documentation]    TC-DASH-01: Navigate to /Dashboard.
    ...                Verify no error banners, no stuck spinner.
    [Tags]    sanity    dashboard    chart    TC-DASH-01
    Verify Page Without Grid    /Dashboard    /Dashboard    Dashboard    page_name=Dashboard

TC_SANITY_008 Customer Dashboard Page Loads
    [Documentation]    TC-DASH-02: Navigate to /CustomerDashboard.
    ...                Verify no error banners, no stuck spinner.
    [Tags]    sanity    dashboard    chart    TC-DASH-02
    Verify Page Without Grid    /CustomerDashboard    /CustomerDashboard    page_name=Customer Dashboard

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 3 — RATE PLAN (TC-RATE-01 to TC-RATE-05)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_009 Account Plan Page Loads With Grid
    [Documentation]    TC-RATE-01: Navigate to /WholeSale.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-01
    Navigate To Page    /WholeSale
    Verify No Page Errors
    Verify Sub Tab Active    /WholeSale    Account Plan
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Account Plan

TC_SANITY_010 Price Model Page Loads With Grid
    [Documentation]    TC-RATE-02: Navigate to /PriceModel.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-02
    Verify Page With Grid    /PriceModel    /PriceModel    page_name=Price Model

TC_SANITY_011 Addon Plan Page Loads With Grid
    [Documentation]    TC-RATE-03: Navigate to /DataPlan.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-03
    Verify Page With Grid    /DataPlan    /DataPlan    page_name=Addon Plan

TC_SANITY_012 Device Plan Page Loads With Grid
    [Documentation]    TC-RATE-04: Navigate to /DevicePlan.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-04
    Verify Page With Grid    /DevicePlan    /DevicePlan    page_name=Device Plan

TC_SANITY_013 Zone Management Page Loads With Grid
    [Documentation]    TC-RATE-05: Navigate to /ZoneManagement.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-05
    Verify Page With Grid    /ZoneManagement    /ZoneManagement    page_name=Zone Management

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 4 — SERVICE (TC-SVC-01 to TC-SVC-05)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_014 Service Plan Page Loads With Grid
    [Documentation]    TC-SVC-01: Navigate to /ServicePlan.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-01
    Navigate To Page    /ServicePlan
    Verify No Page Errors
    Verify Sub Tab Active    /ServicePlan    Service Plan
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Service Plan

TC_SANITY_015 IP Whitelisting Page Loads With Grid
    [Documentation]    TC-SVC-02: Navigate to /IPWhitelisting.
    ...                Verify grid (IPWhitelistingGrid) loads,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-02
    Navigate To Page    /IPWhitelisting
    Verify No Page Errors
    Verify Sub Tab Active    /IPWhitelisting
    Verify Grid Loaded With ID    IPWhitelistingGrid
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    IP Whitelisting

TC_SANITY_016 APN Page Loads With Grid
    [Documentation]    TC-SVC-03: Navigate to /ManageAPN.
    ...                Verify grid loads, search bar visible, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-03
    Navigate To Page    /ManageAPN
    Verify No Page Errors
    Verify Sub Tab Active    /ManageAPN    APN
    Verify Grid Loaded
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    APN

TC_SANITY_017 IP Pooling Page Loads With Grid
    [Documentation]    TC-SVC-04: Navigate to /manageIPPooling.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-04
    Verify Page With Grid    /manageIPPooling    /manageIPPooling    page_name=IP Pooling

TC_SANITY_018 APN Request Page Loads With Grid
    [Documentation]    TC-SVC-05: Navigate to /manageApnRequest.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-05
    Verify Page With Grid    /manageApnRequest    /manageApnRequest    page_name=APN Request

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 5 — REPORT (TC-RPT-01 to TC-RPT-03)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_019 Report Page Loads With Grid
    [Documentation]    TC-RPT-01: Navigate to /Report.
    ...                Verify grid loads, search bar visible, pagination visible, no errors.
    [Tags]    sanity    report    grid    TC-RPT-01
    Navigate To Page    /Report
    Verify No Page Errors
    Verify Sub Tab Active    /Report    Report
    Verify Grid Loaded
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Report

TC_SANITY_020 Report Subscriptions Page Loads With Grid
    [Documentation]    TC-RPT-02: Navigate to /ReportSubscriptions.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    report    grid    TC-RPT-02
    Verify Page With Grid    /ReportSubscriptions    /ReportSubscriptions    page_name=Report Subscriptions

TC_SANITY_021 Report Packages Page Loads With Grid
    [Documentation]    TC-RPT-03: Navigate to /ReportPackage.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    report    grid    TC-RPT-03
    Verify Page With Grid    /ReportPackage    /ReportPackage    page_name=Report Packages

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 6 — BILLING (TC-BILL-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_022 Invoice Page Loads With BU Filter
    [Documentation]    TC-BILL-01: Navigate to /ODSInvoice.
    ...                Verify no error banners, Select BU dropdown visible (no grid until BU selected).
    [Tags]    sanity    billing    filter    TC-BILL-01
    Navigate To Page    /ODSInvoice
    Verify No Page Errors
    Verify Sub Tab Active    /ODSInvoice    Invoice
    Verify No Stuck Spinner
    Verify BU Dropdown Visible
    Capture Sanity Evidence No Grid    Invoice

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 7 — ADMIN (TC-ADM-01 to TC-ADM-15)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_023 Admin User Page Loads With Grid
    [Documentation]    TC-ADM-01: Navigate to /ManageUser.
    ...                Verify grid loads, search bar visible, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-01
    Navigate To Page    /ManageUser
    Verify No Page Errors
    Verify Sub Tab Active    /ManageUser    User
    Verify Grid Loaded
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Manage User

TC_SANITY_024 Admin Api User Page Loads With Grid
    [Documentation]    TC-ADM-02: Navigate to /ManageApiUser.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-02
    Verify Page With Grid    /ManageApiUser    /ManageApiUser    page_name=Api User

TC_SANITY_025 Admin Account Page Loads With Grid
    [Documentation]    TC-ADM-03: Navigate to /ManageAccount.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-03
    Navigate To Page    /ManageAccount
    Verify No Page Errors
    Verify Sub Tab Active    /ManageAccount    Account
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Manage Account

TC_SANITY_026 Admin Role And Access Page Loads With Grid
    [Documentation]    TC-ADM-04: Navigate to /ManageRole.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-04
    Verify Page With Grid    /ManageRole    /ManageRole    page_name=Role And Access

TC_SANITY_027 Admin WL Account Page Loads With Grid
    [Documentation]    TC-ADM-05: Navigate to /WLBLTemplate.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-05
    Verify Page With Grid    /WLBLTemplate    /WLBLTemplate    page_name=WL Account

TC_SANITY_028 Admin Upload Logo Page Loads
    [Documentation]    TC-ADM-06: Navigate to /UploadLogo.
    ...                Verify no error banners, file upload control visible (form page, no grid).
    [Tags]    sanity    admin    form    TC-ADM-06
    Navigate To Page    /UploadLogo
    Verify No Page Errors
    Verify Sub Tab Active    /UploadLogo
    Verify No Stuck Spinner
    Verify Upload Control Visible
    Capture Sanity Evidence No Grid    Upload Logo

TC_SANITY_029 Admin SIM Range Page Loads With Grid
    [Documentation]    TC-ADM-07: Navigate to /SIMRange.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-07
    Verify Page With Grid    /SIMRange    /SIMRange    page_name=SIM Range

TC_SANITY_030 Admin SIM Product Type Page Loads With Grid
    [Documentation]    TC-ADM-08: Navigate to /ProductType.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-08
    Verify Page With Grid    /ProductType    /ProductType    page_name=SIM Product Type

TC_SANITY_031 Admin SMSA Configuration Panel Page Loads With Grid
    [Documentation]    TC-ADM-09: Navigate to /smsaconfigurationpanel.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-09
    Verify Page With Grid    /smsaconfigurationpanel    /smsaconfigurationpanel    page_name=SMSA Configuration Panel

TC_SANITY_032 Admin Manage Label Page Loads With Grid
    [Documentation]    TC-ADM-10: Navigate to /ManageLabel.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-10
    Verify Page With Grid    /ManageLabel    /ManageLabel    page_name=Manage Label

TC_SANITY_033 Admin CSR Journey Page Loads
    [Documentation]    TC-ADM-11: Navigate to /CSRJourney.
    ...                Verify page loads, no errors (page uses custom layout, not a standard grid).
    [Tags]    sanity    admin    TC-ADM-11
    Navigate To Page    /CSRJourney
    Verify No Page Errors
    Verify Sub Tab Active    /CSRJourney    CSR Journey
    Verify No Stuck Spinner
    Capture Sanity Evidence No Grid    CSR Journey

TC_SANITY_034 Admin CSR Journey Penalties Page Loads
    [Documentation]    TC-ADM-12: Navigate to /CSRJourneyPenaltiesAdjustments.
    ...                Verify page loads, no errors (page uses custom layout, not a standard grid).
    [Tags]    sanity    admin    TC-ADM-12
    Verify Page Without Grid    /CSRJourneyPenaltiesAdjustments    /CSRJourneyPenaltiesAdjustments    page_name=CSR Journey Penalties

TC_SANITY_035 Admin Notification Template Page Loads With Grid
    [Documentation]    TC-ADM-13: Navigate to /NotificationTemplate.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-13
    Verify Page With Grid    /NotificationTemplate    /NotificationTemplate    page_name=Notification Template

TC_SANITY_036 Admin LBS Restriction Page Loads With Grid
    [Documentation]    TC-ADM-14: Navigate to /LBSZone.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-14
    Verify Page With Grid    /LBSZone    /LBSZone    page_name=LBS Restriction

TC_SANITY_037 Admin Device Plan Requests Page Loads With Grid
    [Documentation]    TC-ADM-15: Navigate to /DevicePlanRequests.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-15
    Verify Page With Grid    /DevicePlanRequests    /DevicePlanRequests    page_name=Device Plan Requests

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 8 — APPLICATION LOGGING (TC-LOG-01 to TC-LOG-04)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_038 Audit Trail Page Loads With Grid
    [Documentation]    TC-LOG-01: Navigate to /ManageAudit.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-01
    Navigate To Page    /ManageAudit
    Verify No Page Errors
    Verify Sub Tab Active    /ManageAudit    Audit Trail
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Audit Trail

TC_SANITY_039 API Transaction Log Page Loads With Grid
    [Documentation]    TC-LOG-02: Navigate to /APITransactionLog.
    ...                Verify grid loads, search bar visible, pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-02
    Navigate To Page    /APITransactionLog
    Verify No Page Errors
    Verify Sub Tab Active    /APITransactionLog
    Verify Grid Loaded
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    API Transaction Log

TC_SANITY_040 Rule Engine Log Page Loads With Grid
    [Documentation]    TC-LOG-03: Navigate to /ManageRuleAuditLog.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-03
    Verify Page With Grid    /ManageRuleAuditLog    /ManageRuleAuditLog    page_name=Rule Engine Log

TC_SANITY_041 Batch Job Log Page Loads With Grid
    [Documentation]    TC-LOG-04: Navigate to /BatchJobLog.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-04
    Verify Page With Grid    /BatchJobLog    /BatchJobLog    page_name=Batch Job Log

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 9 — RULE ENGINE (TC-RE-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_042 Rule Engine Page Loads With Grid
    [Documentation]    TC-RE-01: Navigate to /RuleEngine.
    ...                Verify grid loads, Account filter, Rule Category filter, pagination visible, no errors.
    [Tags]    sanity    rule-engine    grid    TC-RE-01
    Navigate To Page    /RuleEngine
    Verify No Page Errors
    Verify Sub Tab Active    /RuleEngine    Rule Engine
    Verify Grid Loaded
    Verify Filter Dropdown Visible    Select Account
    Verify Filter Dropdown Visible    Select Rule Category
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Rule Engine

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 10 — ALERT CENTRE (TC-ALERT-01 to TC-ALERT-02)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_043 Active Alerts Page Loads With Grid
    [Documentation]    TC-ALERT-01: Navigate to /ActiveAlerts.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    alert-centre    grid    TC-ALERT-01
    Navigate To Page    /ActiveAlerts
    Verify No Page Errors
    Verify Sub Tab Active    /ActiveAlerts    Active Alerts
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Active Alerts

TC_SANITY_044 Alerts History Page Loads With Grid
    [Documentation]    TC-ALERT-02: Navigate to /AlertsHistory.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    alert-centre    grid    TC-ALERT-02
    Verify Page With Grid    /AlertsHistory    /AlertsHistory    page_name=Alerts History

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 11 — ORDERS (TC-ORD-01 to TC-ORD-02)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_045 Live Order Page Loads With Grid
    [Documentation]    TC-ORD-01: Navigate to /LiveOrder.
    ...                Verify grid loads, search bar visible, pagination visible, no errors.
    [Tags]    sanity    orders    grid    TC-ORD-01
    Navigate To Page    /LiveOrder
    Verify No Page Errors
    Verify Sub Tab Active    /LiveOrder    Live Order
    Verify Grid Loaded
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Live Order

TC_SANITY_046 Order History Page Loads With Grid
    [Documentation]    TC-ORD-02: Navigate to /OrderHistory.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    orders    grid    TC-ORD-02
    Verify Page With Grid    /OrderHistory    /OrderHistory    page_name=Order History

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 12 — DOWNLOAD CENTER (TC-DL-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_047 Download Center Page Loads With Grid
    [Documentation]    TC-DL-01: Navigate to /DownloadCenter.
    ...                Verify grid loads, pagination visible, no errors.
    [Tags]    sanity    download-center    grid    TC-DL-01
    Navigate To Page    /DownloadCenter
    Verify No Page Errors
    Verify Sub Tab Active    /DownloadCenter    Download Center
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Download Center

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 13 — TICKETING (TC-TICK-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_048 Ticketing Page Loads With Grid
    [Documentation]    TC-TICK-01: Navigate to /Ticketing.
    ...                Verify grid loads (page may show loading spinner — wait for it to resolve),
    ...                pagination visible, no errors.
    [Tags]    sanity    ticketing    grid    TC-TICK-01
    Navigate To Page    /Ticketing
    Verify No Page Errors
    Verify Sub Tab Active    /Ticketing    Ticketing
    Verify No Stuck Spinner
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error
    Capture Sanity Evidence    Ticketing
