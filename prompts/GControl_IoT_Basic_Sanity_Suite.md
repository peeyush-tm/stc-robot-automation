# Basic Sanity Test Suite — Global Connectivity Things Platform
**Application:** Global Connectivity Things Platform (GControl IoT Management Center)
**Base URL:** https://192.168.1.26:7874
**Test Type:** Basic Sanity — Post-Login Page Load & Grid Verification
**Framework:** Robot Framework + SeleniumLibrary
**Date Prepared:** 2026-03-10
**Scope:** Visit every main menu and sub-tab after login; verify page loads, grid headers render, no JS errors appear.

---

## Table of Contents

1. [Sanity Check Strategy](#1-sanity-check-strategy)
2. [Pre-requisites](#2-pre-requisites)
3. [Error Detection Criteria](#3-error-detection-criteria)
4. [Grid Load Verification Criteria](#4-grid-load-verification-criteria)
5. [Page Inventory & Test Matrix](#5-page-inventory--test-matrix)
6. [Common XPaths for Sanity Checks](#6-common-xpaths-for-sanity-checks)
7. [Robot Framework — Settings & Keywords Library](#7-robot-framework--settings--keywords-library)
8. [Robot Framework — Test Cases](#8-robot-framework--test-cases)
9. [Sanity Execution Checklist](#9-sanity-execution-checklist)

---

## 1. Sanity Check Strategy

For each page/tab, the following checks are performed in order:

1. **Navigate** to the page URL directly.
2. **Verify page title** is correct (browser tab title).
3. **Verify no full-page error** is displayed (no 500/404 error page, no red alert banners).
4. **Verify the sub-tab navigation** is visible and correct tab is active.
5. **Verify the grid/table renders** — at minimum, column headers must be visible.
6. **Verify pagination controls** are present.
7. **Verify no browser console errors** (JS exceptions, network failures).
8. For pages with **filter/search bars**, verify inputs are visible.
9. For pages with **action buttons** (Create, Add, Export), verify they are present.

---

## 2. Pre-requisites

| # | Item | Detail |
|---|------|--------|
| 1 | Valid Credentials | Admin-level username and password |
| 2 | Browser | Google Chrome (latest) or Firefox |
| 3 | Robot Framework | >= 6.0 with SeleniumLibrary >= 6.0 |
| 4 | ChromeDriver | Version matching installed Chrome |
| 5 | Network Access | Machine must reach 192.168.1.26:7874 |
| 6 | SSL Certificate | Accept self-signed cert or add to trusted store |

---

## 3. Error Detection Criteria

Sanity checks must **FAIL** if any of the following are detected:

| Error Type | XPath / Indicator |
|---|---|
| HTTP 500/404 page | `//h1[contains(text(),'500')] or //h1[contains(text(),'404')]` |
| Red alert/error banner | `//*[contains(@class,'alert-danger')]` |
| JS exception dialog | `//*[contains(@class,'error-overlay')]` |
| "Something went wrong" text | `//*[contains(text(),'Something went wrong')]` |
| Unauthorized / 401 | `//*[contains(text(),'Unauthorized')]` |
| Spinner stuck after 30s | `//*[contains(@class,'k-loading-mask')]` |
| Error inside grid | `//div[contains(@class,'k-grid')]//*[contains(text(),'Error')]` |

> **Note:** "0 of 0 items" or "No items to display" is ACCEPTABLE — grid loaded but no data in this environment.

---

## 4. Grid Load Verification Criteria

A grid is considered **successfully loaded** when ALL of the following are true:

| # | Criteria | XPath |
|---|----------|-------|
| 1 | Grid container is visible | `//div[contains(@class,'k-grid')]` |
| 2 | At least one column header rendered | `//th[@role='columnheader']` |
| 3 | Loading spinner is gone | NOT `//*[contains(@class,'k-loading-mask')]` |
| 4 | Pagination bar is visible | `//*[contains(@class,'k-pager-wrap')]` |
| 5 | No error text inside grid | Grid does NOT contain "Error loading data" |

---

## 5. Page Inventory & Test Matrix

### MODULE 1 — DEVICES

#### TC-DEV-01 | Manage Devices
| Property | Value |
|---|---|
| **URL** | `/ManageDevices` |
| **Page Title** | Global Connectivity Things Platform | Manage Devices |
| **Active Sidebar** | Devices |
| **Active Sub-Tab** | Manage Devices |
| **Has Grid** | YES |
| **Grid Columns** | REF ID, LABEL, ICCID, IMSI, MSISDN, STATUS, ACCOUNT NAME, PLAN NAME |
| **Has Search Bar** | YES |
| **Has Pagination** | YES |
| **Special Notes** | Personal data warning banner may appear — expected behavior |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageDevices' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'ICCID')]
Search Input   : //input[@placeholder='Enter Search Text']
Pagination     : //*[contains(@class,'k-pager-wrap')]
Error Banner   : NOT //*[contains(@class,'alert-danger')]
```

---

#### TC-DEV-02 | Upload History
| Property | Value |
|---|---|
| **URL** | `/UploadHistory` |
| **Page Title** | Global Connectivity Things Platform | Upload History |
| **Active Sub-Tab** | Upload History |
| **Has Grid** | YES |
| **Grid Columns** | INVENTORY SHEET, ERROR SHEET, UPLOAD STATUS, UPLOAD BY |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/UploadHistory' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[contains(.,'UPLOAD STATUS')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-DEV-03 | Blank SIM
| Property | Value |
|---|---|
| **URL** | `/BlankSims` |
| **Page Title** | Global Connectivity Things Platform | Blank SIM |
| **Active Sub-Tab** | Blank SIM |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/BlankSims' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-DEV-04 | Lost SIM
| Property | Value |
|---|---|
| **URL** | `/LostSims` |
| **Page Title** | Global Connectivity Things Platform | Lost SIM |
| **Active Sub-Tab** | Lost SIM |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/LostSims' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-DEV-05 | Pool/Shared Plan Details
| Property | Value |
|---|---|
| **URL** | `/ManagePoolAndSharedPlanDetails` |
| **Active Sub-Tab** | Pool/Shared Plan Details |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManagePoolAndSharedPlanDetails' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-DEV-06 | Retention Cases
| Property | Value |
|---|---|
| **URL** | `/retentioncases` |
| **Active Sub-Tab** | Retention Cases |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/retentioncases' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 2 — DASHBOARD

#### TC-DASH-01 | Dashboard
| Property | Value |
|---|---|
| **URL** | `/Dashboard` |
| **Page Title** | Global Connectivity Things Platform | Dashboard |
| **Active Sidebar** | Dashboard |
| **Active Sub-Tab** | Dashboard |
| **Has Grid** | NO — Charts/Widgets |
| **Special Notes** | Verify no spinner stuck after 15s; charts render |

**Sanity XPaths:**
```
Sub-Tab Active    : //ul//a[@href='/Dashboard' and normalize-space(text())='Dashboard' and contains(@class,'selected')]
No Error Banner   : NOT //*[contains(@class,'alert-danger')]
No Stuck Spinner  : NOT //*[contains(@class,'k-loading-mask')]
```

---

#### TC-DASH-02 | Customer Dashboard
| Property | Value |
|---|---|
| **URL** | `/CustomerDashboard` |
| **Active Sub-Tab** | Customer Dashboard |
| **Has Grid** | NO — Charts/Widgets |

**Sanity XPaths:**
```
Sub-Tab Active  : //ul//a[@href='/CustomerDashboard' and contains(@class,'selected')]
No Error Banner : NOT //*[contains(@class,'alert-danger')]
```

---

### MODULE 3 — RATE PLAN

#### TC-RATE-01 | Account Plan
| Property | Value |
|---|---|
| **URL** | `/WholeSale` |
| **Page Title** | Global Connectivity Things Platform | Account Plan |
| **Active Sidebar** | Rate Plan |
| **Active Sub-Tab** | Account Plan |
| **Has Grid** | YES |
| **Grid Columns** | ACCOUNT, PLAN NAME, DESCRIPTION, STATUS |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/WholeSale' and normalize-space(text())='Account Plan' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'PLAN NAME')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-RATE-02 | Price Model
| Property | Value |
|---|---|
| **URL** | `/PriceModel` |
| **Active Sub-Tab** | Price Model |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/PriceModel' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-RATE-03 | Addon Plan
| Property | Value |
|---|---|
| **URL** | `/DataPlan` |
| **Active Sub-Tab** | Addon Plan |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/DataPlan' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-RATE-04 | Device Plan
| Property | Value |
|---|---|
| **URL** | `/DevicePlan` |
| **Active Sub-Tab** | Device Plan |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/DevicePlan' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-RATE-05 | Zone Management
| Property | Value |
|---|---|
| **URL** | `/ZoneManagement` |
| **Active Sub-Tab** | Zone Management |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ZoneManagement' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 4 — SERVICE

#### TC-SVC-01 | Service Plan
| Property | Value |
|---|---|
| **URL** | `/ServicePlan` |
| **Page Title** | Global Connectivity Things Platform | Service Plan |
| **Active Sidebar** | Service |
| **Active Sub-Tab** | Service Plan |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, PLAN NAME, ACCOUNT NAME, DESCRIPTION |
| **Has Pagination** | YES |
| **Has Action Buttons** | YES — Create Service Plan |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ServicePlan' and normalize-space(text())='Service Plan' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'PLAN NAME')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-SVC-02 | IP Whitelisting
| Property | Value |
|---|---|
| **URL** | `/IPWhitelisting` |
| **Page Title** | Global Connectivity Things Platform | IP Whitelisting |
| **Active Sub-Tab** | IP Whitelisting |
| **Has Grid** | YES — Kendo TreeGrid (id="IPWhitelistingGrid") |
| **Grid Columns** | ACTION, POLICY ID, CUSTOMER ID, CUSTOMER NAME, BU ID, BU NAME, STATUS, CREATED BY |
| **Has Search Bar** | YES |
| **Has Action Buttons** | YES — Create Policy, Download CSV |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/IPWhitelisting' and contains(@class,'selected')]
Grid Container : //div[@id='IPWhitelistingGrid']
Column Header  : //th[@data-title='Policy ID']
Search Input   : //input[@placeholder='Enter Search Text']
Create Policy  : //a[@href='/CreateIPWhitelisting']
Download CSV   : //a[@id='export']
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-SVC-03 | APN
| Property | Value |
|---|---|
| **URL** | `/ManageAPN` |
| **Page Title** | Global Connectivity Things Platform | APN |
| **Active Sub-Tab** | APN |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, APN NAME, APN ID, ACCOUNT, APN TYPE, STATUS, ECC |
| **Has Search Bar** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageAPN' and normalize-space(text())='APN' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'APN NAME')]
Search Input   : //input[@placeholder='Enter Search Text']
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-SVC-04 | IP Pooling
| Property | Value |
|---|---|
| **URL** | `/manageIPPooling` |
| **Active Sub-Tab** | IP Pooling |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/manageIPPooling' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-SVC-05 | APN Request
| Property | Value |
|---|---|
| **URL** | `/manageApnRequest` |
| **Active Sub-Tab** | APN Request |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/manageApnRequest' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 5 — REPORT

#### TC-RPT-01 | Report
| Property | Value |
|---|---|
| **URL** | `/Report` |
| **Page Title** | Global Connectivity Things Platform | Reports |
| **Active Sidebar** | Report |
| **Active Sub-Tab** | Report |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, REPORT ID, REPORT CATEGORY, REPORT NAME |
| **Has Filter Form** | YES — Report ID, Category, Name, Start Date, Created By, Customer, BU, Generation Status |
| **Has Search Bar** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/Report' and normalize-space(text())='Report' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'REPORT ID')]
Search Input   : //input[@placeholder='Enter Search Text']
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-RPT-02 | Report Subscriptions
| Property | Value |
|---|---|
| **URL** | `/ReportSubscriptions` |
| **Active Sub-Tab** | Report Subscriptions |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ReportSubscriptions' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-RPT-03 | Report Packages
| Property | Value |
|---|---|
| **URL** | `/ReportPackage` |
| **Active Sub-Tab** | Report Packages |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ReportPackage' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 6 — BILLING

#### TC-BILL-01 | Invoice
| Property | Value |
|---|---|
| **URL** | `/ODSInvoice` |
| **Page Title** | Global Connectivity Things Platform | Total Invoicing |
| **Active Sidebar** | Billing |
| **Active Sub-Tab** | Invoice |
| **Has Grid** | NO initially — requires BU selection |
| **Has Filter** | YES — Select BU dropdown + Show button |
| **Special Notes** | Verify Select BU dropdown is visible and enabled |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ODSInvoice' and normalize-space(text())='Invoice' and contains(@class,'selected')]
Select BU      : //select[contains(@id,'BU') or contains(@name,'BU')] or //*[contains(@placeholder,'Select BU')]
Show Button    : //button[normalize-space(text())='Show'] or //input[@value='Show']
No Error       : NOT //*[contains(@class,'alert-danger')]
```

---

### MODULE 7 — ADMIN

#### TC-ADM-01 | User
| Property | Value |
|---|---|
| **URL** | `/ManageUser` |
| **Page Title** | Global Connectivity Things Platform | Users |
| **Active Sidebar** | Admin |
| **Active Sub-Tab** | User |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, USER NAME, USER TYPE, USER CATEGORY |
| **Has Search Bar** | YES |
| **Has Action Buttons** | YES — Create User |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageUser' and normalize-space(text())='User' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'USER NAME')]
Search Input   : //input[@placeholder='Enter Search Text']
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-02 | Api User
| Property | Value |
|---|---|
| **URL** | `/ManageApiUser` |
| **Active Sub-Tab** | Api User |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageApiUser' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-03 | Account (Cost Center)
| Property | Value |
|---|---|
| **URL** | `/ManageAccount` |
| **Page Title** | Global Connectivity Things Platform | Cost Center |
| **Active Sub-Tab** | Account |
| **Has Grid** | YES |
| **Has Action Buttons** | YES — Create Account |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageAccount' and normalize-space(text())='Account' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-04 | Role & Access
| Property | Value |
|---|---|
| **URL** | `/ManageRole` |
| **Page Title** | Global Connectivity Things Platform | Role & Access |
| **Active Sub-Tab** | Role & Access |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageRole' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-05 | WL Account
| Property | Value |
|---|---|
| **URL** | `/WLBLTemplate` |
| **Active Sub-Tab** | WL Account |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/WLBLTemplate' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-06 | Upload Logo
| Property | Value |
|---|---|
| **URL** | `/UploadLogo` |
| **Active Sub-Tab** | Upload Logo |
| **Has Grid** | NO — Upload form |
| **Special Notes** | Verify upload control is present, no error shown |

**Sanity XPaths:**
```
Sub-Tab Active  : //ul//a[@href='/UploadLogo' and contains(@class,'selected')]
Upload Control  : //input[@type='file'] or //label[contains(.,'Upload')]
No Error Banner : NOT //*[contains(@class,'alert-danger')]
```

---

#### TC-ADM-07 | SIM Range
| Property | Value |
|---|---|
| **URL** | `/SIMRange` |
| **Active Sub-Tab** | SIM Range |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/SIMRange' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-08 | SIM Product Type
| Property | Value |
|---|---|
| **URL** | `/ProductType` |
| **Active Sub-Tab** | SIM Product Type |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ProductType' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-09 | SMSA Configuration Panel
| Property | Value |
|---|---|
| **URL** | `/smsaconfigurationpanel` |
| **Active Sub-Tab** | SMSA Configuration Panel |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/smsaconfigurationpanel' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-10 | Manage Label
| Property | Value |
|---|---|
| **URL** | `/ManageLabel` |
| **Active Sub-Tab** | Manage Label |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageLabel' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-11 | CSR Journey
| Property | Value |
|---|---|
| **URL** | `/CSRJourney` |
| **Active Sub-Tab** | CSR Journey |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/CSRJourney' and normalize-space(text())='CSR Journey' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-12 | CSR Journey Penalties and Adjustments
| Property | Value |
|---|---|
| **URL** | `/CSRJourneyPenaltiesAdjustments` |
| **Active Sub-Tab** | CSR Journey Penalties and Adjustments |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/CSRJourneyPenaltiesAdjustments' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-13 | Notification Template
| Property | Value |
|---|---|
| **URL** | `/NotificationTemplate` |
| **Active Sub-Tab** | Notification Template |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/NotificationTemplate' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-14 | LBS Restriction
| Property | Value |
|---|---|
| **URL** | `/LBSZone` |
| **Active Sub-Tab** | LBS Restriction |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/LBSZone' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ADM-15 | Device Plan Requests
| Property | Value |
|---|---|
| **URL** | `/DevicePlanRequests` |
| **Active Sub-Tab** | Device Plan Requests |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/DevicePlanRequests' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 8 — APPLICATION LOGGING

#### TC-LOG-01 | Audit Trail
| Property | Value |
|---|---|
| **URL** | `/ManageAudit` |
| **Page Title** | Global Connectivity Things Platform | Manage Audit Log |
| **Active Sidebar** | Application Logging |
| **Active Sub-Tab** | Audit Trail |
| **Has Grid** | YES |
| **Grid Columns** | DATE/TIME, USER, MODULE, ACTION, DESCRIPTION, OLD VALUE, NEW VALUE |
| **Has Filter Form** | YES — Account, Message Type, Module, Start Date, End Date |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageAudit' and normalize-space(text())='Audit Trail' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'USER')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-LOG-02 | API Transaction Log
| Property | Value |
|---|---|
| **URL** | `/APITransactionLog` |
| **Page Title** | Global Connectivity Things Platform | API Transaction Logs |
| **Active Sub-Tab** | API Transaction Log |
| **Has Grid** | YES |
| **Grid Columns** | DATE/TIME, USER NAME, REQUEST ID, REQUEST API, MODULE/SUB MODULE, ACTION, DESCRIPTION, OLD VALUE, NEW VALUE, RESULT, ERROR CODE |
| **Has Filter** | YES — Start Date, End Date (pre-populated with today's date) |
| **Has Search Bar** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active  : //ul//a[@href='/APITransactionLog' and contains(@class,'selected')]
Grid Container  : //div[contains(@class,'k-grid')]
Column Header   : //th[@role='columnheader' and contains(.,'REQUEST')]
Start Date      : //input[contains(@placeholder,'Start Date') or contains(@id,'startDate')]
End Date        : //input[contains(@placeholder,'End Date') or contains(@id,'endDate')]
Pagination      : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-LOG-03 | Rule Engine Log
| Property | Value |
|---|---|
| **URL** | `/ManageRuleAuditLog` |
| **Active Sub-Tab** | Rule Engine Log |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ManageRuleAuditLog' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-LOG-04 | Batch Job Log
| Property | Value |
|---|---|
| **URL** | `/BatchJobLog` |
| **Active Sub-Tab** | Batch Job Log |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/BatchJobLog' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 9 — RULE ENGINE

#### TC-RE-01 | Rule Engine
| Property | Value |
|---|---|
| **URL** | `/RuleEngine` |
| **Page Title** | Global Connectivity Things Platform | Rule Engine |
| **Active Sidebar** | Rule Engine |
| **Active Sub-Tab** | Rule Engine |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, RULE NAME, RULE CATEGORY, ACCOUNT |
| **Has Filter** | YES — Select Account, Select Rule Category, Select Condition |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active   : //ul//a[@href='/RuleEngine' and normalize-space(text())='Rule Engine' and contains(@class,'selected')]
Grid Container   : //div[contains(@class,'k-grid')]
Column Header    : //th[@role='columnheader' and contains(.,'RULE NAME')]
Account Filter   : //*[contains(@placeholder,'Select Account')]
Category Filter  : //*[contains(@placeholder,'Select Rule Category')]
Pagination       : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 10 — ALERT CENTRE

#### TC-ALERT-01 | Active Alerts
| Property | Value |
|---|---|
| **URL** | `/ActiveAlerts` |
| **Page Title** | Global Connectivity Things Platform | Active Alerts |
| **Active Sidebar** | Alert Centre |
| **Active Sub-Tab** | Active Alerts |
| **Has Grid** | YES |
| **Grid Columns** | RULE NAME, RULE CATEGORY, ACCOUNT NAME, DESCRIPTION |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/ActiveAlerts' and normalize-space(text())='Active Alerts' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'RULE NAME')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ALERT-02 | Alerts History
| Property | Value |
|---|---|
| **URL** | `/AlertsHistory` |
| **Active Sub-Tab** | Alerts History |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/AlertsHistory' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 11 — ORDERS

#### TC-ORD-01 | Live Order
| Property | Value |
|---|---|
| **URL** | `/LiveOrder` |
| **Page Title** | Global Connectivity Things Platform | Live Order |
| **Active Sidebar** | Orders |
| **Active Sub-Tab** | Live Order |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, ORDER, ORDER TIME, ACCOUNT, CREATED BY, STATUS, SIM |
| **Has Search Bar** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/LiveOrder' and normalize-space(text())='Live Order' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[@role='columnheader' and contains(.,'ORDER TIME')]
Search Input   : //input[@placeholder='Enter Search Text']
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

#### TC-ORD-02 | Order History
| Property | Value |
|---|---|
| **URL** | `/OrderHistory` |
| **Active Sub-Tab** | Order History |
| **Has Grid** | YES |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/OrderHistory' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 12 — DOWNLOAD CENTER

#### TC-DL-01 | Download Center
| Property | Value |
|---|---|
| **URL** | `/DownloadCenter` |
| **Page Title** | Global Connectivity Things Platform | Download Center |
| **Active Sidebar** | Download Center |
| **Active Sub-Tab** | Download Center |
| **Has Grid** | YES |
| **Grid Columns** | ACTION, MODULE, STATUS |
| **Has Pagination** | YES |

**Sanity XPaths:**
```
Sub-Tab Active : //ul//a[@href='/DownloadCenter' and normalize-space(text())='Download Center' and contains(@class,'selected')]
Grid Container : //div[contains(@class,'k-grid')]
Column Header  : //th[contains(.,'MODULE')]
Pagination     : //*[contains(@class,'k-pager-wrap')]
```

---

### MODULE 13 — TICKETING

#### TC-TICK-01 | Ticketing
| Property | Value |
|---|---|
| **URL** | `/Ticketing` |
| **Page Title** | Global Connectivity Things Platform | Ticketing |
| **Active Sidebar** | Ticketing |
| **Active Sub-Tab** | Ticketing |
| **Has Grid** | YES |
| **Has Pagination** | YES |
| **Special Notes** | Page may show loading spinner; verify it resolves |

**Sanity XPaths:**
```
Sub-Tab Active   : //ul//a[@href='/Ticketing' and normalize-space(text())='Ticketing' and contains(@class,'selected')]
Grid Container   : //div[contains(@class,'k-grid')]
Pagination       : //*[contains(@class,'k-pager-wrap')]
No Stuck Spinner : NOT //*[contains(@class,'k-loading-mask')]
```

---

## 9. Sanity Execution Checklist

Use this checklist to manually track execution results.

| TC ID | Module | Page/Tab | URL | Page Loads | No Error | Grid Headers | Pagination | Status |
|---|---|---|---|---|---|---|---|---|
| TC-DEV-01 | Devices | Manage Devices | /ManageDevices | [ ] | [ ] | [ ] | [ ] | |
| TC-DEV-02 | Devices | Upload History | /UploadHistory | [ ] | [ ] | [ ] | [ ] | |
| TC-DEV-03 | Devices | Blank SIM | /BlankSims | [ ] | [ ] | [ ] | [ ] | |
| TC-DEV-04 | Devices | Lost SIM | /LostSims | [ ] | [ ] | [ ] | [ ] | |
| TC-DEV-05 | Devices | Pool/Shared Plan Details | /ManagePoolAndSharedPlanDetails | [ ] | [ ] | [ ] | [ ] | |
| TC-DEV-06 | Devices | Retention Cases | /retentioncases | [ ] | [ ] | [ ] | [ ] | |
| TC-DASH-01 | Dashboard | Dashboard | /Dashboard | [ ] | [ ] | [ ] | [ ] | |
| TC-DASH-02 | Dashboard | Customer Dashboard | /CustomerDashboard | [ ] | [ ] | [ ] | [ ] | |
| TC-RATE-01 | Rate Plan | Account Plan | /WholeSale | [ ] | [ ] | [ ] | [ ] | |
| TC-RATE-02 | Rate Plan | Price Model | /PriceModel | [ ] | [ ] | [ ] | [ ] | |
| TC-RATE-03 | Rate Plan | Addon Plan | /DataPlan | [ ] | [ ] | [ ] | [ ] | |
| TC-RATE-04 | Rate Plan | Device Plan | /DevicePlan | [ ] | [ ] | [ ] | [ ] | |
| TC-RATE-05 | Rate Plan | Zone Management | /ZoneManagement | [ ] | [ ] | [ ] | [ ] | |
| TC-SVC-01 | Service | Service Plan | /ServicePlan | [ ] | [ ] | [ ] | [ ] | |
| TC-SVC-02 | Service | IP Whitelisting | /IPWhitelisting | [ ] | [ ] | [ ] | [ ] | |
| TC-SVC-03 | Service | APN | /ManageAPN | [ ] | [ ] | [ ] | [ ] | |
| TC-SVC-04 | Service | IP Pooling | /manageIPPooling | [ ] | [ ] | [ ] | [ ] | |
| TC-SVC-05 | Service | APN Request | /manageApnRequest | [ ] | [ ] | [ ] | [ ] | |
| TC-RPT-01 | Report | Report | /Report | [ ] | [ ] | [ ] | [ ] | |
| TC-RPT-02 | Report | Report Subscriptions | /ReportSubscriptions | [ ] | [ ] | [ ] | [ ] | |
| TC-RPT-03 | Report | Report Packages | /ReportPackage | [ ] | [ ] | [ ] | [ ] | |
| TC-BILL-01 | Billing | Invoice | /ODSInvoice | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-01 | Admin | User | /ManageUser | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-02 | Admin | Api User | /ManageApiUser | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-03 | Admin | Account | /ManageAccount | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-04 | Admin | Role & Access | /ManageRole | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-05 | Admin | WL Account | /WLBLTemplate | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-06 | Admin | Upload Logo | /UploadLogo | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-07 | Admin | SIM Range | /SIMRange | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-08 | Admin | SIM Product Type | /ProductType | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-09 | Admin | SMSA Config Panel | /smsaconfigurationpanel | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-10 | Admin | Manage Label | /ManageLabel | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-11 | Admin | CSR Journey | /CSRJourney | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-12 | Admin | CSR Journey Penalties | /CSRJourneyPenaltiesAdjustments | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-13 | Admin | Notification Template | /NotificationTemplate | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-14 | Admin | LBS Restriction | /LBSZone | [ ] | [ ] | [ ] | [ ] | |
| TC-ADM-15 | Admin | Device Plan Requests | /DevicePlanRequests | [ ] | [ ] | [ ] | [ ] | |
| TC-LOG-01 | App Logging | Audit Trail | /ManageAudit | [ ] | [ ] | [ ] | [ ] | |
| TC-LOG-02 | App Logging | API Transaction Log | /APITransactionLog | [ ] | [ ] | [ ] | [ ] | |
| TC-LOG-03 | App Logging | Rule Engine Log | /ManageRuleAuditLog | [ ] | [ ] | [ ] | [ ] | |
| TC-LOG-04 | App Logging | Batch Job Log | /BatchJobLog | [ ] | [ ] | [ ] | [ ] | |
| TC-RE-01 | Rule Engine | Rule Engine | /RuleEngine | [ ] | [ ] | [ ] | [ ] | |
| TC-ALERT-01 | Alert Centre | Active Alerts | /ActiveAlerts | [ ] | [ ] | [ ] | [ ] | |
| TC-ALERT-02 | Alert Centre | Alerts History | /AlertsHistory | [ ] | [ ] | [ ] | [ ] | |
| TC-ORD-01 | Orders | Live Order | /LiveOrder | [ ] | [ ] | [ ] | [ ] | |
| TC-ORD-02 | Orders | Order History | /OrderHistory | [ ] | [ ] | [ ] | [ ] | |
| TC-DL-01 | Download Center | Download Center | /DownloadCenter | [ ] | [ ] | [ ] | [ ] | |
| TC-TICK-01 | Ticketing | Ticketing | /Ticketing | [ ] | [ ] | [ ] | [ ] | |

**Total Test Cases: 48**

---

*Generated: 2026-03-10 | App: GControl IoT Management Center | Host: 192.168.1.26:7874*

---

## 10. Current Project Implementation

This section documents the **actual implementation** in the project.

### Project Files

| Content | Location |
|---------|----------|
| Test cases (48 tests) | `tests/sanity_tests.robot` |
| Keywords | `resources/keywords/sanity_keywords.resource` |
| Locators | `resources/locators/sanity_locators.resource` |
| Variables / Test data | `variables/sanity_variables.py` |
| Browser setup | `resources/keywords/browser_keywords.resource` |
| Login keywords | `resources/keywords/login_keywords.resource` |

### Run Command

```bash
robot --outputdir results tests/sanity_tests.robot
```

### Test Case List (48 tests)

| ID | Name | Module |
|----|------|--------|
| TC_SANITY_001 | Manage Devices Page Loads With Grid | Devices |
| TC_SANITY_002 | Upload History Page Loads With Grid | Devices |
| TC_SANITY_003 | Blank SIM Page Loads With Grid | Devices |
| TC_SANITY_004 | Lost SIM Page Loads With Grid | Devices |
| TC_SANITY_005 | Pool Shared Plan Details Page Loads With Grid | Devices |
| TC_SANITY_006 | Retention Cases Page Loads With Grid | Devices |
| TC_SANITY_007 | Dashboard Page Loads With Charts | Dashboard |
| TC_SANITY_008 | Customer Dashboard Page Loads | Dashboard |
| TC_SANITY_009 | Account Plan Page Loads With Grid | Rate Plan |
| TC_SANITY_010 | Price Model Page Loads With Grid | Rate Plan |
| TC_SANITY_011 | Addon Plan Page Loads With Grid | Rate Plan |
| TC_SANITY_012 | Device Plan Page Loads With Grid | Rate Plan |
| TC_SANITY_013 | Zone Management Page Loads With Grid | Rate Plan |
| TC_SANITY_014 | Service Plan Page Loads With Grid | Service |
| TC_SANITY_015 | IP Whitelisting Page Loads With Grid | Service |
| TC_SANITY_016 | APN Page Loads With Grid | Service |
| TC_SANITY_017 | IP Pooling Page Loads With Grid | Service |
| TC_SANITY_018 | APN Request Page Loads With Grid | Service |
| TC_SANITY_019 | Report Page Loads With Grid | Report |
| TC_SANITY_020 | Report Subscriptions Page Loads With Grid | Report |
| TC_SANITY_021 | Report Packages Page Loads With Grid | Report |
| TC_SANITY_022 | Invoice Page Loads With BU Filter | Billing |
| TC_SANITY_023 | Admin User Page Loads With Grid | Admin |
| TC_SANITY_024 | Admin Api User Page Loads With Grid | Admin |
| TC_SANITY_025 | Admin Account Page Loads With Grid | Admin |
| TC_SANITY_026 | Admin Role And Access Page Loads With Grid | Admin |
| TC_SANITY_027 | Admin WL Account Page Loads With Grid | Admin |
| TC_SANITY_028 | Admin Upload Logo Page Loads | Admin |
| TC_SANITY_029 | Admin SIM Range Page Loads With Grid | Admin |
| TC_SANITY_030 | Admin SIM Product Type Page Loads With Grid | Admin |
| TC_SANITY_031 | Admin SMSA Configuration Panel Page Loads With Grid | Admin |
| TC_SANITY_032 | Admin Manage Label Page Loads With Grid | Admin |
| TC_SANITY_033 | Admin CSR Journey Page Loads With Grid | Admin |
| TC_SANITY_034 | Admin CSR Journey Penalties Page Loads With Grid | Admin |
| TC_SANITY_035 | Admin Notification Template Page Loads With Grid | Admin |
| TC_SANITY_036 | Admin LBS Restriction Page Loads With Grid | Admin |
| TC_SANITY_037 | Admin Device Plan Requests Page Loads With Grid | Admin |
| TC_SANITY_038 | Audit Trail Page Loads With Grid | App Logging |
| TC_SANITY_039 | API Transaction Log Page Loads With Grid | App Logging |
| TC_SANITY_040 | Rule Engine Log Page Loads With Grid | App Logging |
| TC_SANITY_041 | Batch Job Log Page Loads With Grid | App Logging |
| TC_SANITY_042 | Rule Engine Page Loads With Grid | Rule Engine |
| TC_SANITY_043 | Active Alerts Page Loads With Grid | Alert Centre |
| TC_SANITY_044 | Alerts History Page Loads With Grid | Alert Centre |
| TC_SANITY_045 | Live Order Page Loads With Grid | Orders |
| TC_SANITY_046 | Order History Page Loads With Grid | Orders |
| TC_SANITY_047 | Download Center Page Loads With Grid | Download Center |
| TC_SANITY_048 | Ticketing Page Loads With Grid | Ticketing |

### Key Implementation Details

- **Browser Session:** Suite-level login; all 48 tests share a single session
- **Navigation:** Each test navigates to its URL via `Navigate To Page` keyword (direct URL navigation)
- **Verification Keywords:** `Verify Page With Grid` and `Verify Page Without Grid` are the main reusable keywords
- **Error Detection:** Checks for HTTP 500, 404, alert-danger, stuck spinners, and unauthorized errors on every page
- **Grid Validation:** Verifies grid container presence, column headers (when specified), pagination, and search bar
- **Page Load Waits:** Uses `Wait For App Loading To Complete` keyword after each page navigation
