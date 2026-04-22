# Sanity Tests Guide — 48 Test Cases

> **Purpose:** Quick, broad validation that the CMP app's key pages **load** without JS errors, network failures, or missing grids.
> **Not a functional suite** — each TC simply navigates to a page and asserts the page renders.
> **Ideal for:** post-deploy smoke, daily health checks, pre-release sign-off.

---

## At a Glance

| Attribute | Value |
|---|---|
| **Suite file** | `tests/sanity_tests.robot` |
| **Total test cases** | 48 |
| **Typical duration** | ~15 min sequential · ~5 min with `--parallel 4` |
| **Browser** | Chrome (headed) or Headless Chrome |
| **Prerequisites** | Valid OpCo login; CMP app reachable |
| **Tags** | `sanity`, `positive`, `smoke` (a subset), page-specific tags |

---

## Run Commands

### Most common

```bash
# Full sanity — sequential, headed browser
python run_tests.py --sanity --env qe

# Full sanity — parallel (4 browsers) + email report
python run_tests.py --sanity --env qe --parallel 4 --email

# Only the smoke subset (if you only have 3 minutes)
python run_tests.py --sanity --env qe --include smoke

# Headless (ideal for CI / servers with no display)
python run_tests.py --sanity --env qe --browser headlesschrome
```

### Filtering

```bash
# Run a single sanity TC
python run_tests.py --sanity --env qe --test "TC_SANITY_007"

# Run all Admin-tagged pages
python run_tests.py --sanity --env qe --include "admin"

# Skip specific pages
python run_tests.py --sanity --env qe --skip-test "TC_SANITY_045*" --skip-test "TC_SANITY_046*"
```

---

## Test Case Groups

The 48 test cases are grouped by the CMP menu area they validate. Each TC navigates to the listed URL path and asserts that the page renders with its expected element (typically a data grid or chart).

### Group 1 — Device Pages (6 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_001 | Manage Devices | `/ManageDevices` |
| TC_SANITY_002 | Upload History | `/UploadHistory` |
| TC_SANITY_003 | Blank SIM | `/BlankSims` |
| TC_SANITY_004 | Lost SIM | `/LostSims` |
| TC_SANITY_005 | Pool/Shared Plan Details | `/ManagePoolAndSharedPlanDetails` |
| TC_SANITY_006 | Retention Cases | `/retentioncases` |

### Group 2 — Dashboards (2 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_007 | Dashboard | `/Dashboard` |
| TC_SANITY_008 | Customer Dashboard | `/CustomerDashboard` |

### Group 3 — Rate / Pricing (5 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_009 | Account Plan (Wholesale) | `/WholeSale` |
| TC_SANITY_010 | Price Model | `/PriceModel` |
| TC_SANITY_011 | Addon Plan (Data Plan) | `/DataPlan` |
| TC_SANITY_012 | Device Plan | `/DevicePlan` |
| TC_SANITY_013 | Zone Management | `/ZoneManagement` |

### Group 4 — Services (5 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_014 | Service Plan | `/ServicePlan` |
| TC_SANITY_015 | IP Whitelisting | `/IPWhitelisting` |
| TC_SANITY_016 | APN | `/ManageAPN` |
| TC_SANITY_017 | IP Pooling | `/manageIPPooling` |
| TC_SANITY_018 | APN Request | `/manageApnRequest` |

### Group 5 — Reports (3 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_019 | Report | `/Report` |
| TC_SANITY_020 | Report Subscriptions | `/ReportSubscriptions` |
| TC_SANITY_021 | Report Packages | `/ReportPackage` |

### Group 6 — Billing (1 TC)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_022 | Invoice (with BU filter) | `/ODSInvoice` |

### Group 7 — Admin (15 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_023 | Admin · User | `/ManageUser` |
| TC_SANITY_024 | Admin · API User | `/ManageApiUser` |
| TC_SANITY_025 | Admin · Account | `/ManageAccount` |
| TC_SANITY_026 | Admin · Role & Access | `/ManageRole` |
| TC_SANITY_027 | Admin · WL Account | `/WLBLTemplate` |
| TC_SANITY_028 | Admin · Upload Logo | `/UploadLogo` |
| TC_SANITY_029 | Admin · SIM Range | `/SIMRange` |
| TC_SANITY_030 | Admin · SIM Product Type | `/ProductType` |
| TC_SANITY_031 | Admin · SMSA Config Panel | `/smsaconfigurationpanel` |
| TC_SANITY_032 | Admin · Manage Label | `/ManageLabel` |
| TC_SANITY_033 | Admin · CSR Journey | `/CSRJourney` |
| TC_SANITY_034 | Admin · CSR Journey Penalties | `/CSRJourneyPenaltiesAdjustments` |
| TC_SANITY_035 | Admin · Notification Template | `/NotificationTemplate` |
| TC_SANITY_036 | Admin · LBS Restriction | `/LBSZone` |
| TC_SANITY_037 | Admin · Device Plan Requests | `/DevicePlanRequests` |

### Group 8 — Logs (4 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_038 | Audit Trail | `/ManageAudit` |
| TC_SANITY_039 | API Transaction Log | `/APITransactionLog` |
| TC_SANITY_040 | Rule Engine Log | `/ManageRuleAuditLog` |
| TC_SANITY_041 | Batch Job Log | `/BatchJobLog` |

### Group 9 — Rule Engine & Alerts (3 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_042 | Rule Engine | `/RuleEngine` |
| TC_SANITY_043 | Active Alerts | `/ActiveAlerts` |
| TC_SANITY_044 | Alerts History | `/AlertsHistory` |

### Group 10 — Orders & Misc (4 TCs)

| TC ID | Page | URL Path |
|---|---|---|
| TC_SANITY_045 | Live Order | `/LiveOrder` |
| TC_SANITY_046 | Order History | `/OrderHistory` |
| TC_SANITY_047 | Download Center | `/DownloadCenter` |
| TC_SANITY_048 | Ticketing | `/Ticketing` |

---

## What Each Test Does

Every sanity TC follows the **same 3-step pattern**:

```
1. Login to CMP (once per suite — Suite Setup)
2. Navigate to the page's URL path (e.g. /ManageDevices)
3. Assert the expected element is present:
   - Data grid    → #gridData table tbody tr
   - Charts       → canvas/svg element inside dashboard container
   - Form page    → the form's submit button
```

If the element is **visible within 30 seconds**, the TC passes. Otherwise it fails with a screenshot.

### Why this matters

Sanity catches two common breakages:

| Breakage | Caught By |
|---|---|
| **Backend outage** (API returns 500 / timeout) | Grid never renders → test fails |
| **Frontend regression** (JS error on page load) | Grid container missing → test fails |

Sanity does **not** catch functional bugs (wrong data, broken buttons, validation issues). Use the module-specific suites for those.

---

## Reading the Results

After a sanity run, open:

```
reports/<timestamp>/combined_report.html
```

### Interpreting the Pass/Fail Dashboard

| Color | Meaning | What to Do |
|---|---|---|
| **Green (all PASS)** | All 48 pages loaded successfully | Deploy or proceed |
| **Yellow (1-3 FAIL)** | A couple of pages failed | Check screenshots; may be flaky — re-run failures |
| **Red (4+ FAIL)** | Widespread page failures | Likely backend/config issue — check VPN, check captcha DB, check CMP app health |

### Re-running Failures Only

```bash
python run_tests.py --sanity --env qe --rerunfailed reports/2026-04-22_13-00-00
```

This re-executes only the failing tests from the referenced run. Combined report merges new run into the original.

---

## Common Failure Patterns

| Error in Log | Likely Cause | Fix |
|---|---|---|
| "Element '#gridData' not visible after 30s" | Grid API failed on backend | Check CMP API, check DB connection |
| "Captcha DB connection refused" | VPN down or DB host unreachable | Reconnect VPN, verify `DB_HOST` in config |
| "Login page not redirected after submit" | Wrong credentials in `config/qe.json` | Update `VALID_USERNAME` / `VALID_PASSWORD` |
| "Chrome crashed" | OOM on CI server | Add `--parallel 2` (lower parallelism) or use headless |
| Multiple pages "element not visible" simultaneously | Viewport too small (800×600 default) | Export `STC_CHROME_HEADED_WINDOW_SIZE=1680,945` |

---

## Related Files & Resources

| File | Purpose |
|---|---|
| `tests/sanity_tests.robot` | The 48 test cases |
| `resources/keywords/sanity_keywords.resource` | Shared navigation + assertion keywords |
| `libraries/STCReportListener.py` | Renames screenshots with TC_ID prefix |
| `variables/_config_defaults.py` | Config JSON loader |
| `prompts/sanity/Sanity.md` | Original module prompt spec |

---

**Runtime command cheat sheet:**

```bash
python run_tests.py --sanity --env qe                           # Most common
python run_tests.py --sanity --env qe --parallel 4 --email       # Fast + report
python run_tests.py --sanity --env qe --include smoke            # Quick subset
python run_tests.py --sanity --env qe --browser headlesschrome   # CI mode
```
