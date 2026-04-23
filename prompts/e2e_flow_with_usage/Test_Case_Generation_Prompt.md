# E2E Flow With Usage — Test Case Generation Prompt

> **Purpose:** Paste this entire file into any LLM (Claude, ChatGPT, etc.) or hand it to a human tester.
> Edit **only** the marked `<<...>>` placeholders; everything else is the fixed pattern.
> Output: a fully specified test case with step-by-step actions + expected results, ready to drop into `tests/e2e_flow_with_usage.robot` (or a new scenario variant file).

---

## Part 1 — Scenario Metadata (edit these)

```
SCENARIO_NAME:        <<Short title, e.g. "E2E With Usage — UDP Protocol, 3 SIMs">>
SCENARIO_ID:          <<TC ID prefix, e.g. TC_E2E_UDP_03SIM>>
PURPOSE:              <<1–2 sentences. What is this variation trying to validate?>>
BASELINE:             tests/e2e_flow_with_usage.robot  (22 steps — keep as reference)
SCOPE:                <<Which steps differ from baseline? List by step number, e.g. "4, 6, 16, 16a">>
SKIP_STEPS:           <<Step numbers to skip entirely, or "NONE">>
TOTAL_DURATION:       <<Expected runtime, e.g. "~1.5 hr" — adjust if scenario shortens/extends>>
```

---

## Part 2 — Scenario Inputs (edit the table)

| Variable | Baseline Value | Scenario Value |
|---|---|---|
| SIM Range quantity | 10 | <<e.g. 3>> |
| SIM Order quantity | 10 | <<e.g. 3>> |
| SIMs to activate in Step 16 | 5 | <<e.g. 3>> |
| Protocol (Step 19 DP change) | TCP | <<e.g. UDP / TCP / ANY>> |
| APN type | Private | <<Private / Public>> |
| Bundle plan preference | First available | <<Specific plan name or "First available">> |
| Usage injection MB per IMSI | 10 MB | <<e.g. 100 MB>> |
| Invoice expected (Step 17) | Yes | <<Yes / No — skip if No>> |
| Device Plan change (Step 19) | Yes, to Step 18 plan | <<Yes / No>> |
| Environment | qe | <<qe / dev / staging / prod>> |

---

## Part 3 — Step-By-Step Template

Each step below lists:
- **Baseline action** (fixed — do not change unless the scenario specifically overrides it)
- **Scenario override** (edit ONLY if SCOPE includes this step; otherwise write "USE BASELINE")
- **Expected result** (change if the scenario changes the outcome)

---

### Phase 1 — Onboarding

#### Step 1 · Onboard EC and BU via SOAP API
- **Baseline:** SOAP call `createOnboardCustomer` creates timestamped EC + BU
- **Scenario override:** <<USE BASELINE  |  OR describe the SOAP tweak>>
- **Expected:** HTTP 200, no SOAP fault, stored `E2E_EC_NAME` / `E2E_BU_NAME`

#### Step 1b · Verify Onboarded Account on UI
- **Baseline:** Wait 5 min, open ManageAccount with Customer Wise Data enabled, verify both accounts
- **Scenario override:** <<USE BASELINE  |  OR new wait time / different verification>>
- **Expected:** Both EC and BU rows visible in grid

#### Step 2 · Create APN for Onboarded Account
- **Baseline:** Create Private APN with random ID/name
- **Scenario override:** <<USE BASELINE  |  OR e.g. "Create Public APN instead">>
- **Expected:** APN visible under EC/BU

#### Step 3 · Create CSR Journey
- **Baseline:** Wizard flow: Tariff → APN → Bundle/DP → Save & Exit
- **Scenario override:** <<USE BASELINE  |  OR specific Tariff/Bundle choices>>
- **Expected:** CSR created; `E2E_CSR1_DP_ALIAS` captured

---

### Phase 2 — SIM Setup

#### Step 4 · Create SIM Range
- **Baseline:** 10 ICCID/IMSI on KSA_OPCO
- **Scenario override:** <<e.g. "5 ICCID/IMSI" or "Use specific range 8992...033 - 8992...037">>
- **Expected:** SIM Range row created with N entries

#### Step 5 · Create and Assign SIM Product Type
- **Baseline:** New Product Type `Auto PT <random>`, assigned to EC
- **Scenario override:** <<USE BASELINE  |  OR specific PT name>>
- **Expected:** `PT_NAME` stored; PT visible on EC

#### Step 5b · Expand EC and BU SIM Limits
- **Baseline:** +10 to EC Max IMSI and BU Max SIM
- **Scenario override:** <<e.g. "+3" if quantity=3; or "SKIP" if already has headroom>>
- **Expected:** Both EC and BU max increased and verified on save

---

### Phase 3 — SIM Order

#### Step 6 · Create SIM Order
- **Baseline:** Quantity=10, PT from Step 5, BU from Step 1
- **Scenario override:** <<e.g. Quantity=3, activation type=autoActivation>>
- **Expected:** Order appears in Live Order grid

#### Step 7 · Capture Order ID
- **Baseline:** Search BU in Live Order, extract Order ID
- **Scenario override:** USE BASELINE
- **Expected:** `E2E_ORDER_ID` captured (numeric)

#### Step 8 · Fetch EC/BU IDs from DB
- **Baseline:** MySQL query by company/billing name
- **Scenario override:** USE BASELINE
- **Expected:** `E2E_EC_ID` + `E2E_BU_ID` captured

#### Step 9 · Run Create Order Script on Server
- **Baseline:** SSH → `start_createorder.sh <order_id>`
- **Scenario override:** USE BASELINE
- **Expected:** Script exits 0

#### Step 10 · Validate Order Status (New → In Progress)
- **Baseline:** Live Order grid shows `In Progress`
- **Scenario override:** USE BASELINE
- **Expected:** State transition confirmed

---

### Phase 4 — Response Processing

#### Step 11 · Generate + Upload Response Files
- **Baseline:** 3 files from templates, SCP upload
- **Scenario override:** USE BASELINE
- **Expected:** All 3 files land on server

#### Step 12 · Run Read Order Script on Server
- **Baseline:** SSH → `start_readorder.sh <order_id>`
- **Scenario override:** USE BASELINE
- **Expected:** Script exits 0

#### Step 13 · Validate Order Status (In Progress → Completed)
- **Baseline:** Order History shows `Completed`
- **Scenario override:** USE BASELINE
- **Expected:** State transition confirmed

#### Step 14 · Validate SIMs in Warm State
- **Baseline:** Manage Devices filtered by BU shows all 10 SIMs Warm
- **Scenario override:** <<Adjust count to scenario quantity>>
- **Expected:** N/N SIMs in `Warm` state

---

### Phase 5 — Activation + Usage

#### Step 15 · Approve Order via SOAP API
- **Baseline:** SOAP call → SIMs move to InActive
- **Scenario override:** USE BASELINE
- **Expected:** 200 OK; SIMs transition to InActive

#### Step 16 · Activate SIMs + Capture IMSIs/MSISDNs
- **Baseline:** Bulk activate 5 of 10 SIMs
- **Scenario override:** <<e.g. "Activate 3 of 3" — adjust count>>
- **Expected:** `E2E_ACTIVATED_IMSIS` list has N entries

#### Step 16a · Inject Usage per IMSI
- **Baseline:** User Request API + CDR API, 10 MB per IMSI
- **Scenario override:** <<Change MB or protocol or skip if no usage wanted>>
- **Expected:** All IMSIs accept usage; API returns 200

#### Step 16b · Validate Usage in UI
- **Baseline:** Manage Devices — DATA USAGE (MB) column > 0 for each IMSI
- **Scenario override:** <<Or >= specific threshold>>
- **Expected:** Each IMSI row shows non-zero data usage

---

### Phase 6 — Invoice + Post-Order

#### Step 17 · Generate Invoice + Download CSV
- **Baseline:** Invoice API with BU ID, SCP download CSV
- **Scenario override:** <<USE BASELINE  |  SKIP if scenario doesn't need invoice>>
- **Expected:** CSV lands in `reports/<run>/billing/`

#### Step 18 · Create Second CSR Journey
- **Baseline:** Different Bundle plan for same BU
- **Scenario override:** <<USE BASELINE  |  Or skip>>
- **Expected:** `E2E_CSR2_DP_ALIAS` captured

#### Step 19 · Device Plan Change on One Activated SIM + Validate
- **Baseline:** Change DP on first activated IMSI to Step 18 plan, wait 6 min, verify in grid
- **Scenario override:** <<Change protocol / change timeout / change target SIM>>
- **Expected:** Grid Device Plan column shows new plan after wait

---

## Part 4 — Output Format Requested

After filling in the placeholders above, the generator (AI or human) should produce:

1. **A Robot Framework test case block** matching the existing style in `tests/e2e_flow_with_usage.robot`:
   ```robot
   <<SCENARIO_ID>>_01 <<Scenario-specific step title>>
       [Documentation]    <<What this step does + expected result>>
       [Tags]    e2e    <<scenario-tag>>    <<phase-tag>>
       STEP_01   # Calls existing keyword if unchanged, or new keyword if overridden
   ```

2. **A scenario-specific keyword block** for any overridden steps (append to `*** Keywords ***` section or to `resources/keywords/e2e_keywords.resource`).

3. **A markdown summary table** showing:
   | Step | Action | Duration | Result |

4. **Run command** using the new test IDs:
   ```bash
   python run_tests.py tests/e2e_flow_with_usage.robot --env <<env>> --test "<<SCENARIO_ID>>*"
   ```

---

## Part 5 — Worked Example

**Scenario:** "E2E With Usage — 3 SIMs UDP"

Filled-in placeholders:
```
SCENARIO_NAME:   E2E With Usage — 3 SIMs UDP Protocol
SCENARIO_ID:     TC_E2E_UDP_03SIM
PURPOSE:         Exercise the full E2E flow with reduced SIM count (3) and UDP protocol at
                 Step 19 to validate the DP change path for UDP-based rate plans.
SCOPE:           4, 5b, 6, 14, 16, 19
SKIP_STEPS:      NONE
TOTAL_DURATION:  ~1.2 hr (reduced SIM count trims some steps)
```

Scenario inputs:
| Variable | Scenario Value |
|---|---|
| SIM Range quantity | 3 |
| SIM Order quantity | 3 |
| SIMs to activate in Step 16 | 3 (all) |
| Protocol (Step 19 DP change) | UDP |
| Environment | qe |

Overrides:
- **Step 4:** "Create SIM Range with 3 ICCID/IMSI" (not 10)
- **Step 5b:** "+3 to EC Max IMSI / BU Max SIM" (not +10)
- **Step 6:** "Quantity = 3"
- **Step 14:** "Verify 3 SIMs in Warm state"
- **Step 16:** "Activate 3 of 3 SIMs (all)"
- **Step 19:** "Pick UDP-compatible DP from Step 18 catalog"

The generator outputs a `tests/e2e_flow_udp_3sim.robot` file with 22 test cases plus a new `E2E Create SIM Range 3` keyword variant.

---

## Part 6 — Checklist Before Committing Generated Test

- [ ] All `<<placeholders>>` have been replaced (search for `<<` to verify)
- [ ] `SCENARIO_ID` prefix is unique (grep `tasks.csv` to confirm)
- [ ] Scope list matches the steps actually overridden
- [ ] New keywords (if any) are defined in `resources/keywords/e2e_keywords.resource` or a scenario resource file
- [ ] `tasks.csv` has one row per new TC — easiest way: regenerate via `python _gen_tasks.py`
- [ ] Run the new scenario end-to-end at least once on `qe` before merging
- [ ] PDF/HTML report produces the expected step screenshots and per-phase timings

---

## Appendix — Baseline Step Reference

See [E2E_FLOW_WITH_USAGE_GUIDE.md](../../documentation/E2E_FLOW_WITH_USAGE_GUIDE.md) for the detailed walkthrough of every baseline step (action, type, duration, dependencies).

Quick links:
- Baseline test file: [tests/e2e_flow_with_usage.robot](../../tests/e2e_flow_with_usage.robot)
- Baseline keywords: [resources/keywords/e2e_keywords.resource](../../resources/keywords/e2e_keywords.resource)
- Suite prompt: [prompts/e2e_flow_with_usage/E2E_Flow_With_Usage.md](E2E_Flow_With_Usage.md)
