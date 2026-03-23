# IP Pool Suite

## Overview

| Field | Value |
|-------|-------|
| **Suite ID** | `IP_Pool` |
| **Suite File** | `tests/ip_pool_tests.robot` |
| **Variables File** | `variables/ip_pool_variables.py` |
| **Type** | UI |
| **URLs** | `<BASE_URL>/manageIPPooling` (list), `<BASE_URL>/CreateIPPooling` (create) |
| **Total TCs** | 17 |
| **Tags** | `ip_pool`, `boundary`, `security`, `navigation`, `smoke`, `regression` |

## Run Commands

```bash
python run_tests.py --suite IP_Pool
python run_tests.py tests/ip_pool_tests.robot
python run_tests.py --suite IP_Pool --include smoke
python run_tests.py --suite IP_Pool --include ip_pool
python run_tests.py --suite IP_Pool --test "TC_IPP_001*"
```

## Module Description

The **IP Pool** module is a two-step creation flow. First the user fills in Account, APN Type, Number of IPs, and selects an APN. Clicking Create opens an **IP Details panel** showing the allocated IPs and Pool Count. The user then confirms to complete the creation.

**Navigation:** Login → Service sidebar → IP Pooling tab → Create button → `/CreateIPPooling`

## Test Cases

| TC ID | Test Case Name | Type | Tags |
|-------|---------------|------|------|
| TC_IPP_001 | E2E Create IP Pool With Public APN | Positive | smoke, regression, ip_pool |
| TC_IPP_002 | Verify IP Pool Listing Page Loads | Positive | smoke, regression, ip_pool |
| TC_IPP_003 | Verify Create IP Pool Form Elements Visible | Positive | smoke, regression, ip_pool |
| TC_IPP_004 | Verify IP Details Panel After Clicking Create | Positive | regression, ip_pool |
| TC_IPP_005 | Verify Pool Count In IP Details Panel | Positive | regression, ip_pool |
| TC_IPP_006 | Cancel Before Submit Redirects To Listing | Positive | regression, ip_pool, navigation |
| TC_IPP_007 | Verify APN Dropdown Populates After Account And Type | Positive | regression, ip_pool |
| TC_IPP_008 | Verify Close Button On Create Page Redirects | Positive | regression, ip_pool, navigation |
| TC_IPP_009 | Create With No Fields Filled Should Show Error | Negative | regression, ip_pool |
| TC_IPP_010 | Create Without Account Should Show Error | Negative | regression, ip_pool |
| TC_IPP_011 | Create Without APN Type Should Show Error | Negative | regression, ip_pool |
| TC_IPP_012 | Create Without Number Of IPs Should Show Error | Negative | regression, ip_pool |
| TC_IPP_013 | Create Without APN Selected Should Show Error | Negative | regression, ip_pool |
| TC_IPP_014 | Create With Zero IPs Should Show Error | Negative | regression, ip_pool, boundary |
| TC_IPP_015 | Create With Non Numeric IPs Should Show Error | Negative | regression, ip_pool, boundary |
| TC_IPP_016 | Direct Access To Create IP Pool Without Login | Negative | regression, security, ip_pool, navigation |
| TC_IPP_017 | Direct Access To IP Pool List Without Login | Negative | regression, security, ip_pool, navigation |

## Test Case Categories

### Positive — Happy Path (1 TC)
- **TC_IPP_001** — Select Account, set APN Type=Public, enter Number of IPs, select APN from populated dropdown, click Create, verify IP Details panel opens with Pool Count, confirm creation.

### Positive — UI Verification (7 TCs)
- **TC_IPP_002** — IP Pool listing page loads with grid.
- **TC_IPP_003** — Create form shows Account, APN Type, Number of IPs, APN fields + Create button.
- **TC_IPP_004** — After clicking Create, the IP Details panel slides in showing allocated IP addresses.
- **TC_IPP_005** — IP Details panel shows correct Pool Count matching the requested Number of IPs.
- **TC_IPP_006** — Cancel button (before clicking Create) returns to listing.
- **TC_IPP_007** — APN dropdown remains empty until both Account and APN Type are selected; then populates.
- **TC_IPP_008** — Close button on the Create page returns to listing without saving.

### Negative — Mandatory Field Validation (5 TCs)
- **TC_IPP_009** — Submit empty form → all field errors shown.
- **TC_IPP_010** — Account not selected → error.
- **TC_IPP_011** — APN Type not selected → error.
- **TC_IPP_012** — Number of IPs empty → error.
- **TC_IPP_013** — APN not selected from dropdown → error.

### Negative — Boundary (2 TCs)
- **TC_IPP_014** — Number of IPs = 0 → error.
- **TC_IPP_015** — Non-numeric value in Number of IPs → error.

### Negative — Auth / Navigation (2 TCs)
- **TC_IPP_016** — Direct `/CreateIPPooling` without session → login redirect.
- **TC_IPP_017** — Direct `/manageIPPooling` without session → login redirect.

## Files & Resources

| File | Purpose |
|------|---------|
| `tests/ip_pool_tests.robot` | Test suite |
| `resources/keywords/ip_pool_keywords.resource` | IP Pool two-step creation keywords |
| `resources/locators/ip_pool_locators.resource` | XPath locators (form + IP Details panel) |
| `variables/ip_pool_variables.py` | APN types, number of IPs, account names |
| `prompts/ip_pool/TC_008_Create_IP_Pool_RF.md` | Detailed specification |

## Automation Notes

- The APN dropdown is **dependent**: it only populates after both Account and APN Type are selected. Keyword waits for dropdown to have options before selecting.
- The IP Details panel appears as a side panel (not a modal); keyword waits for it to become visible before verifying Pool Count.
- Loading overlay appears after each major action (Create click, panel load).
