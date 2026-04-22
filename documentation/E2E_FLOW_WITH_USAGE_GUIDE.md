# E2E Flow With Usage — Step-by-Step Guide

> **Purpose:** Full SIM lifecycle end-to-end, from **customer onboarding** through **usage injection** and **invoicing**.
> This is the most comprehensive test in the framework — 22 sequential steps spanning API, UI, SSH, and DB.
> **Ideal for:** release sign-off, regression validation, post-deploy full-system check.

---

## At a Glance

| Attribute | Value |
|---|---|
| **Suite file** | `tests/e2e_flow_with_usage.robot` |
| **Total steps** | 22 (Step 1 → Step 19, with 1b / 5b / 16a / 16b inserts) |
| **Typical duration** | **~1.5 hours** (includes 5-min + 6-min waits for backend processing) |
| **Browser** | Chrome (headed — do not use headless) |
| **Prerequisites** | QE app reachable · VPN connected · SSH to order server · MySQL accessible · SMTP (if emailing) |
| **Cleanup** | None — each run creates fresh EC/BU accounts (timestamped) |

---

## Run Commands

### Most common

```bash
# Full E2E with usage — headed Chrome, emails report at end
python run_tests.py --e2e-with-usage --env qe --email
```

### Step-level control

```bash
# Skip invoice step (if invoice server is known down)
python run_tests.py --e2e-with-usage --env qe --skip-test "Step 17*"

# Resume from Step 16a with known EC/BU
python run_tests.py tests/e2e_flow_with_usage.robot --env qe \
    --test "Step 16a*" --test "Step 16b*" \
    --variable E2E_EC_NAME:AQ_AUTO_EC_20260422140426 \
    --variable E2E_BU_NAME:AQ_AUTO_BU_20260422140426

# Re-run only failures
python run_tests.py --e2e-with-usage --env qe --rerunfailed reports/2026-04-22_14-03-08
```

---

## The 22 Steps — Detailed Walkthrough

Each step is a Robot test case in `tests/e2e_flow_with_usage.robot`. Steps run **sequentially** — if a step fails, all subsequent steps are skipped.

| | Duration | Type | Depends On |
|---|---|---|---|
| Each row below shows typical runtime, whether it's UI/API/SSH/DB, and which earlier step(s) it needs. |

---

### Phase 1 — Onboarding (Steps 1 to 3)

#### **Step 1 · Onboard EC and BU Account via API**

| | |
|---|---|
| **Action** | SOAP call to `createOnboardCustomer` creating a timestamped EC + BU account |
| **Output** | `E2E_EC_NAME = AQ_AUTO_EC_<timestamp>`, `E2E_BU_NAME = AQ_AUTO_BU_<timestamp>` |
| **Type** | SOAP API |
| **Duration** | ~2 seconds |
| **Pass criteria** | HTTP 200, no SOAP fault in response |

#### **Step 1b · Verify Onboarded Account on UI**

| | |
|---|---|
| **Action** | Waits 5 min for backend processing, navigates to `ManageAccount`, enables "Show Customer Wise Data", verifies both accounts are listed |
| **Type** | UI |
| **Duration** | ~5.5 min (5 min wait + 30s UI) |
| **Retry** | If not found first attempt, waits another 5 min and retries |

#### **Step 2 · Create APN for Onboarded Account**

| | |
|---|---|
| **Action** | Creates a Private APN under the new EC/BU (random APN ID + name) |
| **Type** | UI |
| **Duration** | ~40 seconds |
| **Output** | `auto-apn-<random>` APN associated with EC/BU |

#### **Step 3 · Create CSR Journey for Onboarded Account**

| | |
|---|---|
| **Action** | Fills CSR Journey wizard (Tariff, APN, Bundle/Device Plan, Summary), saves and exits |
| **Type** | UI |
| **Duration** | ~2.5 min |
| **Output** | Captures `E2E_CSR1_DP_ALIAS` for the device plan selected |

---

### Phase 2 — SIM Setup (Steps 4 to 5b)

#### **Step 4 · Create SIM Range with 10 ICCID/IMSI**

| | |
|---|---|
| **Action** | Uses `KSA_OPCO` account + deterministic values from `config/qe.json` (`SIM_RANGE_ICCID_FROM` etc.) |
| **Type** | UI |
| **Duration** | ~30 seconds |
| **Range size** | 10 ICCIDs + 10 IMSIs + 10 MSISDNs |

#### **Step 5 · Create and Assign SIM Product Type**

| | |
|---|---|
| **Action** | Creates a new Product Type, assigns it to the EC account |
| **Type** | UI |
| **Duration** | ~30 seconds |
| **Output** | `PT_NAME = Auto PT <random>` |

#### **Step 5b · Expand EC and BU SIM Limits** *(inserted between 5 and 6)*

| | |
|---|---|
| **Action** | Opens each account's Settings, adds +10 to Max IMSI (EC) and +10 to Max SIM (BU) |
| **Type** | UI |
| **Duration** | ~90 seconds |
| **Why** | Provides SIM capacity headroom for the upcoming SIM Order |
| **Verify** | Re-reads the Max value from the saved wizard |

---

### Phase 3 — SIM Order (Steps 6 to 10)

#### **Step 6 · Create SIM Order**

| | |
|---|---|
| **Action** | Creates order for 10 SIMs on the BU account, with the Product Type from Step 5 |
| **Type** | UI |
| **Duration** | ~1 min |
| **Output** | Order appears in `Live Order` grid |

#### **Step 7 · Capture Order ID from Live Order Grid**

| | |
|---|---|
| **Action** | Navigates to Live Order tab, searches by BU account, extracts Order ID |
| **Type** | UI |
| **Duration** | ~20 seconds |
| **Output** | `E2E_ORDER_ID = <numeric>` |

#### **Step 8 · Fetch EC and BU Account IDs from DB**

| | |
|---|---|
| **Action** | MySQL query using `DB_HOST` / `DB_USER` from config |
| **Type** | DB |
| **Duration** | ~5 seconds |
| **Output** | `E2E_EC_ID`, `E2E_BU_ID` |

#### **Step 9 · Run Create Order Script on Server**

| | |
|---|---|
| **Action** | SSH to order processing server, executes `start_createorder.sh <order_id>` |
| **Type** | SSH |
| **Duration** | ~30 seconds |
| **Failure mode** | If SSH fails, verify `SSH_HOST`/`SSH_USER`/`SSH_PASS` in config/qe.json |

#### **Step 10 · Validate Order Status (New → In Progress)**

| | |
|---|---|
| **Action** | Re-navigates Live Order grid, checks order moved to `In Progress` state |
| **Type** | UI |
| **Duration** | ~20 seconds |

---

### Phase 4 — Response File Processing (Steps 11 to 14)

#### **Step 11 · Generate + Upload Response Files**

| | |
|---|---|
| **Action** | Generates 3 response files (dsprsp/ordrsp/pcsrsp) from templates + uploads via SCP |
| **Type** | SSH (SCP) |
| **Duration** | ~30 seconds |

#### **Step 12 · Run Read Order Script on Server**

| | |
|---|---|
| **Action** | SSH, executes `start_readorder.sh <order_id>` which processes uploaded response files |
| **Type** | SSH |
| **Duration** | ~30 seconds |

#### **Step 13 · Validate Order Status (In Progress → Completed)**

| | |
|---|---|
| **Action** | Order History grid — verify order is now `Completed` |
| **Type** | UI |
| **Duration** | ~20 seconds |

#### **Step 14 · Validate SIMs in Warm State**

| | |
|---|---|
| **Action** | Manage Devices, filters by BU, verifies all 10 SIMs show `Warm` state |
| **Type** | UI |
| **Duration** | ~30 seconds |

---

### Phase 5 — Activation + Usage (Steps 15 to 16b)

#### **Step 15 · Update Order Status to Approved via SOAP**

| | |
|---|---|
| **Action** | SOAP API call to mark order approved — triggers SIMs to `InActive` state |
| **Type** | SOAP API |
| **Duration** | ~5 seconds |

#### **Step 16 · Activate 5 SIMs and Capture IMSIs + MSISDNs**

| | |
|---|---|
| **Action** | Multi-select 5 InActive SIMs, triggers state change to Active, captures their IMSIs/MSISDNs |
| **Type** | UI |
| **Duration** | ~2 min |
| **Output** | `E2E_ACTIVATED_IMSIS = [imsi1, imsi2, imsi3, imsi4, imsi5]` |

#### **Step 16a · Perform Usage for All Activated IMSIs**

| | |
|---|---|
| **Action** | For each IMSI: calls User Request API, then CDR API — injects data usage records |
| **Type** | REST API |
| **Duration** | ~2 min |

#### **Step 16b · Validate Usage in UI**

| | |
|---|---|
| **Action** | Manage Devices — for each IMSI, verifies `DATA USAGE (MB)` column has non-zero value |
| **Type** | UI |
| **Duration** | ~1.5 min |

---

### Phase 6 — Invoice + Post-Order (Steps 17 to 19)

#### **Step 17 · Generate Invoice and Download CSV**

| | |
|---|---|
| **Action** | Invoice API call with BU ID, waits for server-side generation, downloads CSV to `reports/<run>/billing/` |
| **Type** | API + SSH (SCP download) |
| **Duration** | ~2 min |

#### **Step 18 · Create Second CSR Journey with Different Plan**

| | |
|---|---|
| **Action** | Creates a 2nd CSR Journey for the same BU — different bundle plan |
| **Type** | UI |
| **Duration** | ~2.5 min |
| **Output** | `E2E_CSR2_DP_ALIAS` — used in Step 19 |

#### **Step 19 · Perform Device Plan Change on One Activated SIM and Validate**

| | |
|---|---|
| **Action** | Device Plan Change on the first activated SIM → preferred DP from Step 18 → verifies in grid after 6-min wait |
| **Type** | UI |
| **Duration** | ~7 min (includes 6-min backend wait) |
| **Validates** | New DP appears in the SIM's Device Plan column |

---

## Step Dependency Graph

```
Step 1 ──► Step 1b ──► Step 2 ──► Step 3 ──► Step 4 ──► Step 5 ──► Step 5b
                                                                       │
                                                                       ▼
                                   Step 8 (DB) ◄── Step 7 (UI) ◄── Step 6 (UI)
                                      │
                                      ▼
                                   Step 9 (SSH) ──► Step 10 (UI)
                                                      │
                                                      ▼
                                                   Step 11 (SCP) ──► Step 12 (SSH) ──► Step 13 (UI)
                                                                                          │
                                                                                          ▼
                                                                                       Step 14 (UI)
                                                                                          │
                                                                                          ▼
                                                                                       Step 15 (API) ──► Step 16 (UI)
                                                                                                              │
                                                                                                              ▼
                                                                                                           Step 16a (API) ──► Step 16b (UI)
                                                                                                                                 │
                                                                                                                                 ▼
                                                                                                                              Step 17 (API+SCP)
                                                                                                                                 │
                                                                                                                                 ▼
                                                                                                                              Step 18 (UI) ──► Step 19 (UI)
```

---

## Variables Produced by Each Step

The E2E flow passes data between steps via **suite-level variables**. If you need to resume from a middle step, you must pass these via `--variable`:

| Variable | Set By | Used By |
|---|---|---|
| `E2E_EC_NAME` | Step 1 | Steps 1b, 2, 3, 5, 5b, 6, 8 |
| `E2E_BU_NAME` | Step 1 | Steps 1b, 2, 3, 5b, 6, 8, 14, 16, 19 |
| `E2E_ORDER_ID` | Step 7 | Steps 8, 9, 10, 11, 12, 13 |
| `E2E_EC_ID` / `E2E_BU_ID` | Step 8 | Steps 9, 11, 17 |
| `@E2E_ACTIVATED_IMSIS` | Step 16 | Steps 16a, 16b, 19 |
| `@E2E_IMSI_DATA` | Step 16 | Step 16b (MSISDNs) |
| `E2E_CSR1_DP_ALIAS` | Step 3 | Reference only |
| `E2E_CSR2_BUNDLE_PLAN` | Step 18 | Step 19 |
| `E2E_CSR2_DP_ALIAS` | Step 18 | Step 19 |

**Example — resume from Step 17 onward:**

```bash
python run_tests.py tests/e2e_flow_with_usage.robot --env qe \
    --test "Step 17*" --test "Step 18*" --test "Step 19*" \
    --variable E2E_EC_NAME:AQ_AUTO_EC_20260422140426 \
    --variable E2E_BU_NAME:AQ_AUTO_BU_20260422140426 \
    --variable E2E_BU_ID:29422 \
    --variable E2E_ACTIVATED_IMSIS:420023027457473
```

---

## Total Runtime Breakdown

| Phase | Steps | Duration |
|---|---|---|
| Phase 1 — Onboarding | 1, 1b, 2, 3 | ~9 min (mostly 5-min wait in 1b) |
| Phase 2 — SIM Setup | 4, 5, 5b | ~2.5 min |
| Phase 3 — SIM Order | 6-10 | ~2.5 min |
| Phase 4 — Response Processing | 11-14 | ~1.5 min |
| Phase 5 — Activation + Usage | 15, 16, 16a, 16b | ~6 min |
| Phase 6 — Invoice + Post-Order | 17, 18, 19 | ~11.5 min (includes 6-min wait in 19) |
| **Total** | **22 steps** | **~1.5 hours** |

---

## Troubleshooting E2E Failures

| Symptom | Likely Step | Fix |
|---|---|---|
| Account not found in Step 1b | Onboarding backend slow — wait extended 10 min already | If QE is very slow, bump to 15 min |
| Captcha DB error at login | Suite Setup | VPN down; verify `DB_HOST` reachable |
| SSH timeout | Step 9 or 12 | Check SSH credentials + server reachable; try `ssh user@host` |
| "Max IMSI save failed" in Step 5b | Toast wait | Already fixed — post-save verify is authoritative (see commit `86603d2`) |
| "old & new device plan can't be same" in Step 19 | DP selection | Already fixed — exclude grid DP from candidates (commit `41a9458`) |
| Usage not showing in Step 16b | Backend async | Wait extended; retry Step 16b standalone |
| Invoice download missing | Step 17 | Check `INVOICE_API_URL` + SSH creds; re-run step |

---

## Related Documentation

| Document | Purpose |
|---|---|
| [USER_MANUAL.md](USER_MANUAL.md) | Full setup, install, run, email guide |
| [SANITY_TESTS_GUIDE.md](SANITY_TESTS_GUIDE.md) | Sanity suite (48 TCs) |
| [../prompts/e2e_flow_with_usage/E2E_Flow_With_Usage.md](../prompts/e2e_flow_with_usage/E2E_Flow_With_Usage.md) | Original module prompt spec |
| [../tests/e2e_flow_with_usage.robot](../tests/e2e_flow_with_usage.robot) | Source test file |

---

**Command cheat sheet:**

```bash
python run_tests.py --e2e-with-usage --env qe                             # Most common
python run_tests.py --e2e-with-usage --env qe --email                      # + email report
python run_tests.py --e2e-with-usage --env qe --skip-test "Step 17*"       # Skip invoice step
python run_tests.py --e2e-with-usage --env qe --rerunfailed reports/<run>  # Re-run failures
```
