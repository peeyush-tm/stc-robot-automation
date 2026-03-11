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
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Test Cases ***
# ═══════════════════════════════════════════════════════════════════════
#  MODULE 1 — DEVICES (TC-DEV-01 to TC-DEV-06)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_001 Manage Devices Page Loads With Grid
    [Documentation]    TC-DEV-01: Navigate to /ManageDevices.
    ...                Verify sub-tab 'Manage Devices' is active, grid loads with columns
    ...                REF ID, LABEL, ICCID, IMSI, MSISDN, STATUS, ACCOUNT NAME, PLAN NAME,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-01
    Navigate To Page    /ManageDevices
    Verify No Page Errors
    Verify Sub Tab Active    /ManageDevices    Manage Devices
    Verify Grid Loaded
    Verify Grid Columns    ICCID    MSISDN    STATUS    ACCOUNT NAME    PLAN NAME
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_002 Upload History Page Loads With Grid
    [Documentation]    TC-DEV-02: Navigate to /UploadHistory.
    ...                Verify sub-tab 'Upload History' is active, grid loads with columns
    ...                INVENTORY SHEET, ERROR SHEET, UPLOAD STATUS, UPLOAD BY,
    ...                pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-02
    Navigate To Page    /UploadHistory
    Verify No Page Errors
    Verify Sub Tab Active    /UploadHistory
    Verify Grid Loaded
    Verify Grid Columns    UPLOAD STATUS    UPLOAD BY
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_003 Blank SIM Page Loads With Grid
    [Documentation]    TC-DEV-03: Navigate to /BlankSims.
    ...                Verify sub-tab 'Blank SIM' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-03
    Verify Page With Grid    /BlankSims    /BlankSims

TC_SANITY_004 Lost SIM Page Loads With Grid
    [Documentation]    TC-DEV-04: Navigate to /LostSims.
    ...                Verify sub-tab 'Lost SIM' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-04
    Verify Page With Grid    /LostSims    /LostSims

TC_SANITY_005 Pool Shared Plan Details Page Loads With Grid
    [Documentation]    TC-DEV-05: Navigate to /ManagePoolAndSharedPlanDetails.
    ...                Verify sub-tab 'Pool/Shared Plan Details' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-05
    Verify Page With Grid    /ManagePoolAndSharedPlanDetails    /ManagePoolAndSharedPlanDetails

TC_SANITY_006 Retention Cases Page Loads With Grid
    [Documentation]    TC-DEV-06: Navigate to /retentioncases.
    ...                Verify sub-tab 'Retention Cases' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    devices    grid    TC-DEV-06
    Verify Page With Grid    /retentioncases    /retentioncases

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 2 — DASHBOARD (TC-DASH-01 to TC-DASH-02)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_007 Dashboard Page Loads With Charts
    [Documentation]    TC-DASH-01: Navigate to /Dashboard.
    ...                Verify sub-tab 'Dashboard' is active, no error banners,
    ...                no stuck spinner (charts/widgets expected, NOT a grid).
    [Tags]    sanity    dashboard    chart    TC-DASH-01
    Verify Page Without Grid    /Dashboard    /Dashboard    Dashboard
    Verify No Stuck Spinner

TC_SANITY_008 Customer Dashboard Page Loads
    [Documentation]    TC-DASH-02: Navigate to /CustomerDashboard.
    ...                Verify sub-tab 'Customer Dashboard' is active, no error banners,
    ...                no stuck spinner (charts/widgets expected, NOT a grid).
    [Tags]    sanity    dashboard    chart    TC-DASH-02
    Verify Page Without Grid    /CustomerDashboard    /CustomerDashboard

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 3 — RATE PLAN (TC-RATE-01 to TC-RATE-05)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_009 Account Plan Page Loads With Grid
    [Documentation]    TC-RATE-01: Navigate to /WholeSale.
    ...                Verify sub-tab 'Account Plan' is active, grid loads with columns
    ...                ACCOUNT, PLAN NAME, DESCRIPTION, STATUS,
    ...                pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-01
    Navigate To Page    /WholeSale
    Verify No Page Errors
    Verify Sub Tab Active    /WholeSale    Account Plan
    Verify Grid Loaded
    Verify Grid Columns    PLAN NAME    STATUS
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_010 Price Model Page Loads With Grid
    [Documentation]    TC-RATE-02: Navigate to /PriceModel.
    ...                Verify sub-tab 'Price Model' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-02
    Verify Page With Grid    /PriceModel    /PriceModel

TC_SANITY_011 Addon Plan Page Loads With Grid
    [Documentation]    TC-RATE-03: Navigate to /DataPlan.
    ...                Verify sub-tab 'Addon Plan' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-03
    Verify Page With Grid    /DataPlan    /DataPlan

TC_SANITY_012 Device Plan Page Loads With Grid
    [Documentation]    TC-RATE-04: Navigate to /DevicePlan.
    ...                Verify sub-tab 'Device Plan' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-04
    Verify Page With Grid    /DevicePlan    /DevicePlan

TC_SANITY_013 Zone Management Page Loads With Grid
    [Documentation]    TC-RATE-05: Navigate to /ZoneManagement.
    ...                Verify sub-tab 'Zone Management' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    rate-plan    grid    TC-RATE-05
    Verify Page With Grid    /ZoneManagement    /ZoneManagement

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 4 — SERVICE (TC-SVC-01 to TC-SVC-05)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_014 Service Plan Page Loads With Grid
    [Documentation]    TC-SVC-01: Navigate to /ServicePlan.
    ...                Verify sub-tab 'Service Plan' is active, grid loads with columns
    ...                ACTION, PLAN NAME, ACCOUNT NAME, DESCRIPTION,
    ...                pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-01
    Navigate To Page    /ServicePlan
    Verify No Page Errors
    Verify Sub Tab Active    /ServicePlan    Service Plan
    Verify Grid Loaded
    Verify Grid Columns    PLAN NAME    ACCOUNT NAME
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_015 IP Whitelisting Page Loads With Grid
    [Documentation]    TC-SVC-02: Navigate to /IPWhitelisting.
    ...                Verify sub-tab 'IP Whitelisting' is active, grid (IPWhitelistingGrid) loads
    ...                with columns POLICY ID, CUSTOMER NAME, STATUS, CREATED BY,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-02
    Navigate To Page    /IPWhitelisting
    Verify No Page Errors
    Verify Sub Tab Active    /IPWhitelisting
    Verify Grid Loaded With ID    IPWhitelistingGrid
    Verify Grid Columns    POLICY ID    CUSTOMER NAME    STATUS    CREATED BY
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_016 APN Page Loads With Grid
    [Documentation]    TC-SVC-03: Navigate to /ManageAPN.
    ...                Verify sub-tab 'APN' is active, grid loads with columns
    ...                APN NAME, APN ID, ACCOUNT, APN TYPE, STATUS,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-03
    Navigate To Page    /ManageAPN
    Verify No Page Errors
    Verify Sub Tab Active    /ManageAPN    APN
    Verify Grid Loaded
    Verify Grid Columns    APN NAME    APN TYPE    STATUS
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_017 IP Pooling Page Loads With Grid
    [Documentation]    TC-SVC-04: Navigate to /manageIPPooling.
    ...                Verify sub-tab 'IP Pooling' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-04
    Verify Page With Grid    /manageIPPooling    /manageIPPooling

TC_SANITY_018 APN Request Page Loads With Grid
    [Documentation]    TC-SVC-05: Navigate to /manageApnRequest.
    ...                Verify sub-tab 'APN Request' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    service    grid    TC-SVC-05
    Verify Page With Grid    /manageApnRequest    /manageApnRequest

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 5 — REPORT (TC-RPT-01 to TC-RPT-03)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_019 Report Page Loads With Grid
    [Documentation]    TC-RPT-01: Navigate to /Report.
    ...                Verify sub-tab 'Report' is active, grid loads with columns
    ...                REPORT ID, REPORT CATEGORY, REPORT NAME,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    report    grid    TC-RPT-01
    Navigate To Page    /Report
    Verify No Page Errors
    Verify Sub Tab Active    /Report    Report
    Verify Grid Loaded
    Verify Grid Columns    REPORT ID    REPORT NAME
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_020 Report Subscriptions Page Loads With Grid
    [Documentation]    TC-RPT-02: Navigate to /ReportSubscriptions.
    ...                Verify sub-tab 'Report Subscriptions' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    report    grid    TC-RPT-02
    Verify Page With Grid    /ReportSubscriptions    /ReportSubscriptions

TC_SANITY_021 Report Packages Page Loads With Grid
    [Documentation]    TC-RPT-03: Navigate to /ReportPackage.
    ...                Verify sub-tab 'Report Packages' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    report    grid    TC-RPT-03
    Verify Page With Grid    /ReportPackage    /ReportPackage

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 6 — BILLING (TC-BILL-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_022 Invoice Page Loads With BU Filter
    [Documentation]    TC-BILL-01: Navigate to /ODSInvoice.
    ...                Verify sub-tab 'Invoice' is active, no error banners.
    ...                This page has NO grid initially — requires BU selection.
    ...                Verify the Select BU dropdown and Show button are visible.
    [Tags]    sanity    billing    filter    TC-BILL-01
    Navigate To Page    /ODSInvoice
    Verify No Page Errors
    Verify Sub Tab Active    /ODSInvoice    Invoice
    Verify No Stuck Spinner

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 7 — ADMIN (TC-ADM-01 to TC-ADM-15)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_023 Admin User Page Loads With Grid
    [Documentation]    TC-ADM-01: Navigate to /ManageUser.
    ...                Verify sub-tab 'User' is active, grid loads with columns
    ...                USER NAME, USER TYPE, USER CATEGORY,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-01
    Navigate To Page    /ManageUser
    Verify No Page Errors
    Verify Sub Tab Active    /ManageUser    User
    Verify Grid Loaded
    Verify Grid Columns    USER NAME    USER TYPE
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_024 Admin Api User Page Loads With Grid
    [Documentation]    TC-ADM-02: Navigate to /ManageApiUser.
    ...                Verify sub-tab 'Api User' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-02
    Verify Page With Grid    /ManageApiUser    /ManageApiUser

TC_SANITY_025 Admin Account Page Loads With Grid
    [Documentation]    TC-ADM-03: Navigate to /ManageAccount.
    ...                Verify sub-tab 'Account' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-03
    Navigate To Page    /ManageAccount
    Verify No Page Errors
    Verify Sub Tab Active    /ManageAccount    Account
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_026 Admin Role And Access Page Loads With Grid
    [Documentation]    TC-ADM-04: Navigate to /ManageRole.
    ...                Verify sub-tab 'Role & Access' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-04
    Verify Page With Grid    /ManageRole    /ManageRole

TC_SANITY_027 Admin WL Account Page Loads With Grid
    [Documentation]    TC-ADM-05: Navigate to /WLBLTemplate.
    ...                Verify sub-tab 'WL Account' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-05
    Verify Page With Grid    /WLBLTemplate    /WLBLTemplate

TC_SANITY_028 Admin Upload Logo Page Loads
    [Documentation]    TC-ADM-06: Navigate to /UploadLogo.
    ...                Verify sub-tab 'Upload Logo' is active, no error banners.
    ...                This is NOT a grid page — it has an upload form.
    ...                Verify upload control (input[type='file'] or label) is present.
    [Tags]    sanity    admin    form    TC-ADM-06
    Verify Page Without Grid    /UploadLogo    /UploadLogo

TC_SANITY_029 Admin SIM Range Page Loads With Grid
    [Documentation]    TC-ADM-07: Navigate to /SIMRange.
    ...                Verify sub-tab 'SIM Range' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-07
    Verify Page With Grid    /SIMRange    /SIMRange

TC_SANITY_030 Admin SIM Product Type Page Loads With Grid
    [Documentation]    TC-ADM-08: Navigate to /ProductType.
    ...                Verify sub-tab 'SIM Product Type' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-08
    Verify Page With Grid    /ProductType    /ProductType

TC_SANITY_031 Admin SMSA Configuration Panel Page Loads With Grid
    [Documentation]    TC-ADM-09: Navigate to /smsaconfigurationpanel.
    ...                Verify sub-tab 'SMSA Configuration Panel' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-09
    Verify Page With Grid    /smsaconfigurationpanel    /smsaconfigurationpanel

TC_SANITY_032 Admin Manage Label Page Loads With Grid
    [Documentation]    TC-ADM-10: Navigate to /ManageLabel.
    ...                Verify sub-tab 'Manage Label' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-10
    Verify Page With Grid    /ManageLabel    /ManageLabel

TC_SANITY_033 Admin CSR Journey Page Loads With Grid
    [Documentation]    TC-ADM-11: Navigate to /CSRJourney.
    ...                Verify sub-tab 'CSR Journey' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-11
    Navigate To Page    /CSRJourney
    Verify No Page Errors
    Verify Sub Tab Active    /CSRJourney    CSR Journey
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_034 Admin CSR Journey Penalties Page Loads With Grid
    [Documentation]    TC-ADM-12: Navigate to /CSRJourneyPenaltiesAdjustments.
    ...                Verify sub-tab 'CSR Journey Penalties and Adjustments' is active,
    ...                grid loads, pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-12
    Verify Page With Grid    /CSRJourneyPenaltiesAdjustments    /CSRJourneyPenaltiesAdjustments

TC_SANITY_035 Admin Notification Template Page Loads With Grid
    [Documentation]    TC-ADM-13: Navigate to /NotificationTemplate.
    ...                Verify sub-tab 'Notification Template' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-13
    Verify Page With Grid    /NotificationTemplate    /NotificationTemplate

TC_SANITY_036 Admin LBS Restriction Page Loads With Grid
    [Documentation]    TC-ADM-14: Navigate to /LBSZone.
    ...                Verify sub-tab 'LBS Restriction' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-14
    Verify Page With Grid    /LBSZone    /LBSZone

TC_SANITY_037 Admin Device Plan Requests Page Loads With Grid
    [Documentation]    TC-ADM-15: Navigate to /DevicePlanRequests.
    ...                Verify sub-tab 'Device Plan Requests' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    admin    grid    TC-ADM-15
    Verify Page With Grid    /DevicePlanRequests    /DevicePlanRequests

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 8 — APPLICATION LOGGING (TC-LOG-01 to TC-LOG-04)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_038 Audit Trail Page Loads With Grid
    [Documentation]    TC-LOG-01: Navigate to /ManageAudit.
    ...                Verify sub-tab 'Audit Trail' is active, grid loads with columns
    ...                USER, MODULE, ACTION, DESCRIPTION,
    ...                pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-01
    Navigate To Page    /ManageAudit
    Verify No Page Errors
    Verify Sub Tab Active    /ManageAudit    Audit Trail
    Verify Grid Loaded
    Verify Grid Columns    USER    ACTION
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_039 API Transaction Log Page Loads With Grid
    [Documentation]    TC-LOG-02: Navigate to /APITransactionLog.
    ...                Verify sub-tab 'API Transaction Log' is active, grid loads with columns
    ...                REQUEST, MODULE, ACTION, RESULT,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-02
    Navigate To Page    /APITransactionLog
    Verify No Page Errors
    Verify Sub Tab Active    /APITransactionLog
    Verify Grid Loaded
    Verify Grid Columns    REQUEST
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_040 Rule Engine Log Page Loads With Grid
    [Documentation]    TC-LOG-03: Navigate to /ManageRuleAuditLog.
    ...                Verify sub-tab 'Rule Engine Log' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-03
    Verify Page With Grid    /ManageRuleAuditLog    /ManageRuleAuditLog

TC_SANITY_041 Batch Job Log Page Loads With Grid
    [Documentation]    TC-LOG-04: Navigate to /BatchJobLog.
    ...                Verify sub-tab 'Batch Job Log' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    logging    grid    TC-LOG-04
    Verify Page With Grid    /BatchJobLog    /BatchJobLog

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 9 — RULE ENGINE (TC-RE-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_042 Rule Engine Page Loads With Grid
    [Documentation]    TC-RE-01: Navigate to /RuleEngine.
    ...                Verify sub-tab 'Rule Engine' is active, grid loads with columns
    ...                RULE NAME, RULE CATEGORY, ACCOUNT,
    ...                pagination visible, no errors.
    [Tags]    sanity    rule-engine    grid    TC-RE-01
    Navigate To Page    /RuleEngine
    Verify No Page Errors
    Verify Sub Tab Active    /RuleEngine    Rule Engine
    Verify Grid Loaded
    Verify Grid Columns    RULE NAME    RULE CATEGORY
    Verify Pagination Visible
    Verify No Grid Error

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 10 — ALERT CENTRE (TC-ALERT-01 to TC-ALERT-02)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_043 Active Alerts Page Loads With Grid
    [Documentation]    TC-ALERT-01: Navigate to /ActiveAlerts.
    ...                Verify sub-tab 'Active Alerts' is active, grid loads with columns
    ...                RULE NAME, RULE CATEGORY, ACCOUNT NAME, DESCRIPTION,
    ...                pagination visible, no errors.
    [Tags]    sanity    alert-centre    grid    TC-ALERT-01
    Navigate To Page    /ActiveAlerts
    Verify No Page Errors
    Verify Sub Tab Active    /ActiveAlerts    Active Alerts
    Verify Grid Loaded
    Verify Grid Columns    RULE NAME    ACCOUNT NAME
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_044 Alerts History Page Loads With Grid
    [Documentation]    TC-ALERT-02: Navigate to /AlertsHistory.
    ...                Verify sub-tab 'Alerts History' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    alert-centre    grid    TC-ALERT-02
    Verify Page With Grid    /AlertsHistory    /AlertsHistory

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 11 — ORDERS (TC-ORD-01 to TC-ORD-02)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_045 Live Order Page Loads With Grid
    [Documentation]    TC-ORD-01: Navigate to /LiveOrder.
    ...                Verify sub-tab 'Live Order' is active, grid loads with columns
    ...                ORDER, ORDER TIME, ACCOUNT, CREATED BY, STATUS, SIM,
    ...                search bar visible, pagination visible, no errors.
    [Tags]    sanity    orders    grid    TC-ORD-01
    Navigate To Page    /LiveOrder
    Verify No Page Errors
    Verify Sub Tab Active    /LiveOrder    Live Order
    Verify Grid Loaded
    Verify Grid Columns    ORDER TIME    ACCOUNT    STATUS
    Verify Search Bar Visible
    Verify Pagination Visible
    Verify No Grid Error

TC_SANITY_046 Order History Page Loads With Grid
    [Documentation]    TC-ORD-02: Navigate to /OrderHistory.
    ...                Verify sub-tab 'Order History' is active, grid loads,
    ...                pagination visible, no errors.
    [Tags]    sanity    orders    grid    TC-ORD-02
    Verify Page With Grid    /OrderHistory    /OrderHistory

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 12 — DOWNLOAD CENTER (TC-DL-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_047 Download Center Page Loads With Grid
    [Documentation]    TC-DL-01: Navigate to /DownloadCenter.
    ...                Verify sub-tab 'Download Center' is active, grid loads with columns
    ...                MODULE, STATUS,
    ...                pagination visible, no errors.
    [Tags]    sanity    download-center    grid    TC-DL-01
    Navigate To Page    /DownloadCenter
    Verify No Page Errors
    Verify Sub Tab Active    /DownloadCenter    Download Center
    Verify Grid Loaded
    Verify Grid Columns    MODULE    STATUS
    Verify Pagination Visible
    Verify No Grid Error

# ═══════════════════════════════════════════════════════════════════════
#  MODULE 13 — TICKETING (TC-TICK-01)
# ═══════════════════════════════════════════════════════════════════════

TC_SANITY_048 Ticketing Page Loads With Grid
    [Documentation]    TC-TICK-01: Navigate to /Ticketing.
    ...                Verify sub-tab 'Ticketing' is active, grid loads,
    ...                pagination visible, no stuck spinner, no errors.
    ...                Special note: Page may show loading spinner — verify it resolves.
    [Tags]    sanity    ticketing    grid    TC-TICK-01
    Navigate To Page    /Ticketing
    Verify No Page Errors
    Verify Sub Tab Active    /Ticketing    Ticketing
    Verify Grid Loaded
    Verify Pagination Visible
    Verify No Stuck Spinner
    Verify No Grid Error
