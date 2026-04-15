# Sanity Module

## Overview
The Sanity suite performs quick page-load checks across all CMP portal pages. Each test navigates to a specific URL and verifies the page loads without errors — checking for grid visibility, pagination, search bars, and absence of error banners. Designed to run as a fast smoke check before deeper regression testing.

## CMP Pages Covered
48 pages across all portal sections: Devices, Dashboard, Rate Plan, Service, Report, Billing, Admin, Logging, Rule Engine, Alert Centre, Orders, Download Center, Ticketing.

## Test Suite
- **File:** `tests/sanity_tests.robot`
- **Keywords:** `resources/keywords/sanity_keywords.resource`
- **Locators:** `resources/locators/sanity_locators.resource`
- **Variables:** `variables/sanity_variables.py`
- **Total Test Cases:** 48

## Test Cases

### Devices Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_001 | Manage Devices Page Loads With Grid | /ManageDevices |
| TC_SANITY_002 | Upload History Page Loads With Grid | /UploadHistory |
| TC_SANITY_003 | Blank SIM Page Loads With Grid | /BlankSims |
| TC_SANITY_004 | Lost SIM Page Loads With Grid | /LostSims |
| TC_SANITY_005 | Pool Shared Plan Details Page Loads With Grid | /ManagePoolAndSharedPlanDetails |
| TC_SANITY_006 | Retention Cases Page Loads With Grid | /retentioncases |

### Dashboard Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_007 | Dashboard Page Loads With Charts | /Dashboard |
| TC_SANITY_008 | Customer Dashboard Page Loads | /CustomerDashboard |

### Rate Plan Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_009 | Account Plan Page Loads With Grid | /WholeSale |
| TC_SANITY_010 | Price Model Page Loads With Grid | /PriceModel |
| TC_SANITY_011 | Addon Plan Page Loads With Grid | /DataPlan |
| TC_SANITY_012 | Device Plan Page Loads With Grid | /DevicePlan |
| TC_SANITY_013 | Zone Management Page Loads With Grid | /ZoneManagement |

### Service Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_014 | Service Plan Page Loads With Grid | /ServicePlan |
| TC_SANITY_015 | IP Whitelisting Page Loads With Grid | /IPWhitelisting |
| TC_SANITY_016 | APN Page Loads With Grid | /ManageAPN |
| TC_SANITY_017 | IP Pooling Page Loads With Grid | /manageIPPooling |
| TC_SANITY_018 | APN Request Page Loads With Grid | /manageApnRequest |

### Report Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_019 | Report Page Loads With Grid | /Report |
| TC_SANITY_020 | Report Subscriptions Page Loads With Grid | /ReportSubscriptions |
| TC_SANITY_021 | Report Packages Page Loads With Grid | /ReportPackage |

### Billing Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_022 | Invoice Page Loads With BU Filter | /ODSInvoice |

### Admin Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_023 | Admin User Page Loads With Grid | /ManageUser |
| TC_SANITY_024 | Admin Api User Page Loads With Grid | /ManageApiUser |
| TC_SANITY_025 | Admin Account Page Loads With Grid | /ManageAccount |
| TC_SANITY_026 | Admin Role And Access Page Loads With Grid | /ManageRole |
| TC_SANITY_027 | Admin WL Account Page Loads With Grid | /WLBLTemplate |
| TC_SANITY_028 | Admin Upload Logo Page Loads | /UploadLogo |
| TC_SANITY_029 | Admin SIM Range Page Loads With Grid | /SIMRange |
| TC_SANITY_030 | Admin SIM Product Type Page Loads With Grid | /ProductType |
| TC_SANITY_031 | Admin SMSA Configuration Panel Page Loads With Grid | /smsaconfigurationpanel |
| TC_SANITY_032 | Admin Manage Label Page Loads With Grid | /ManageLabel |
| TC_SANITY_033 | Admin CSR Journey Page Loads | /CSRJourney |
| TC_SANITY_034 | Admin CSR Journey Penalties Page Loads | /CSRJourneyPenaltiesAdjustments |
| TC_SANITY_035 | Admin Notification Template Page Loads With Grid | /NotificationTemplate |
| TC_SANITY_036 | Admin LBS Restriction Page Loads With Grid | /LBSZone |
| TC_SANITY_037 | Admin Device Plan Requests Page Loads With Grid | /DevicePlanRequests |

### Logging Section
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_038 | Audit Trail Page Loads With Grid | /ManageAudit |
| TC_SANITY_039 | API Transaction Log Page Loads With Grid | /APITransactionLog |
| TC_SANITY_040 | Rule Engine Log Page Loads With Grid | /ManageRuleAuditLog |
| TC_SANITY_041 | Batch Job Log Page Loads With Grid | /BatchJobLog |

### Other Sections
| TC ID | Name | URL |
|-------|------|-----|
| TC_SANITY_042 | Rule Engine Page Loads With Grid | /RuleEngine |
| TC_SANITY_043 | Active Alerts Page Loads With Grid | /ActiveAlerts |
| TC_SANITY_044 | Alerts History Page Loads With Grid | /AlertsHistory |
| TC_SANITY_045 | Live Order Page Loads With Grid | /LiveOrder |
| TC_SANITY_046 | Order History Page Loads With Grid | /OrderHistory |
| TC_SANITY_047 | Download Center Page Loads With Grid | /DownloadCenter |
| TC_SANITY_048 | Ticketing Page Loads With Grid | /Ticketing |

## Run Commands
```bash
python run_tests.py --sanity --env qe                   # Sequential
python run_tests.py --sanity --env qe --parallel 4       # Parallel (4 processes)
python run_tests.py --sanity --env qe --include admin    # Only admin pages
python run_tests.py --sanity --env qe --test "TC_SANITY_001*"
```
