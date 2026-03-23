# STC Automation — All Modules and Test Cases Reference

**Source:** `tasks.csv` (project root)  
**Last updated:** From current tasks.csv  
**Total test cases:** 445 (in tasks.csv execution order)

This document lists all test modules and their test case IDs/names as defined in `tasks.csv`. Use it for AI prompts, traceability, and run filters.

---

## Module Summary

| # | Module | Suite File | Test Count | Type |
|---|--------|------------|------------|------|
| 1 | Login | tests/login_tests.robot | 16 | positive, negative |
| 2 | APN | tests/apn_tests.robot | 22 | positive, negative |
| 3 | SIM Range | tests/sim_range_tests.robot | 21 | positive, negative |
| 4 | SIM Order | tests/sim_order_tests.robot | 21 | positive, negative |
| 5 | SIM Range MSISDN | tests/sim_range_msisdn_tests.robot | 26 | positive, negative |
| 6 | IP Pool | tests/ip_pool_tests.robot | 17 | positive, negative |
| 7 | IP Whitelist | tests/ip_whitelist_tests.robot | 20 | positive, negative |
| 8 | Device State | tests/device_state_tests.robot | 16 | positive, negative |
| 9 | Device Plan | tests/device_plan_tests.robot | 11 | positive, negative |
| 10 | Account Onboard | tests/onboard_customer_api_tests.robot | 38 | positive, negative, edge-case |
| 11 | Cost Center | tests/cost_center_tests.robot | 25 | positive, negative |
| 12 | CSR Journey | tests/csr_journey_tests.robot | 56 | positive, negative, edge-case |
| 13 | SIM Product Type | tests/product_type_tests.robot | 18 | positive, negative, edge-case |
| 14 | E2E Flow | tests/e2e_flow.robot | 17 | steps (STEP_01 … STEP_17) |
| 15 | E2E Flow With Usage | tests/e2e_flow_with_usage.robot | 20 | steps + Step 16a, 16b |
| 16 | Rule Engine | tests/rule_engine_tests.robot | 37 | positive, negative |
| 17 | Role Management | tests/role_management_tests.robot | 32 | positive, negative, edge-case |
| 18 | User Management | tests/user_management_tests.robot | 45 | positive, negative, edge-case |

---

## Run Commands (from run_tests.py)

```bash
# All suites in tasks.csv order
python run_tests.py

# By module name (from tasks.csv)
python run_tests.py --suite Login
python run_tests.py --suite APN
python run_tests.py --suite "SIM Range"
python run_tests.py --suite "SIM Range MSISDN"
python run_tests.py --suite "SIM Order"
python run_tests.py --suite "IP Pool"
python run_tests.py --suite "IP Whitelist"
python run_tests.py --suite "Device State"
python run_tests.py --suite "Device Plan"
python run_tests.py --suite "Account Onboard"
python run_tests.py --suite "Cost Center"
python run_tests.py --suite "CSR Journey"
python run_tests.py --suite "SIM Product Type"
python run_tests.py --suite "E2E Flow"
python run_tests.py --suite "E2E Flow With Usage"
python run_tests.py --suite "Rule Engine"
python run_tests.py --suite "Role Management"
python run_tests.py --suite "User Management"

# E2E flows (bypass tasks.csv)
python run_tests.py --e2e
python run_tests.py --e2e-with-usage
python run_tests.py --e2e-with-usage --browser headlesschrome
```

---

## Full Test Case List (tasks.csv)

The authoritative list is `tasks.csv` with columns: **order, module, suite_file, test_case_id, test_case_name, type, tags**.

- **Login:** TC_LOGIN_001 … TC_LOGIN_016  
- **APN:** TC_APN_001 … TC_APN_022  
- **SIM Range:** TC_SR_001 … TC_SR_021  
- **SIM Order:** TC_SO_001 … TC_SO_021  
- **SIM Range MSISDN:** TC_SRM_001 … TC_SRM_026  
- **IP Pool:** TC_IPP_001 … TC_IPP_017  
- **IP Whitelist:** TC_WL_001 … TC_WL_020  
- **Device State:** TC_DSC_001 … TC_DSC_016  
- **Device Plan:** TC_CDP_001 … TC_CDP_011  
- **Account Onboard:** TC_ONBOARD_001 … TC_ONBOARD_040  
- **Cost Center:** TC_CC_001 … TC_CC_026  
- **CSR Journey:** TC_CSRJ_001 … TC_CSRJ_055, TC_CSRJ_004_Delete  
- **SIM Product Type:** TC_PT_001 … TC_PT_18, TC_PT_13, TC_PT_14, TC_PT_15, TC_PT_16, TC_PT_17  
- **E2E Flow:** STEP_01, STEP_01B, STEP_02 … STEP_17  
- **E2E Flow With Usage:** STEP_01 … STEP_16, STEP_16A, STEP_16B, STEP_17  
- **Rule Engine:** TC_RE_001 … TC_RE_023  
- **Role Management:** TC_ROLE_001 … TC_ROLE_033  
- **User Management:** TC_USER_001 … TC_USER_045  

For exact names and tags, open `tasks.csv` or use:

```bash
python run_tests.py --test "TC_LOGIN_001*"
python run_tests.py --include smoke
```

---

## Prompts Folder Structure

| Folder / File | Description |
|---------------|-------------|
| prompts/ALL_MODULES_AND_TESTCASES.md | This file — modules and test case reference |
| prompts/login/TC_001_Login_Navigate_RF.md | Login & Navigate specification |
| prompts/apn/TC_007_Create_APN_RF.md | APN module specification |
| prompts/sim_range/TC_004_Create_SIM_Range_RF.md | SIM Range ICCID/IMSI |
| prompts/sim_range/TC_012_Create_SIM_Range_MSISDN_RF.md | SIM Range MSISDN |
| prompts/sim_order/TC_003_Create_SIM_Order_RF.md | SIM Order specification |
| prompts/ip_pool/TC_008_Create_IP_Pool_RF.md | IP Pool specification |
| prompts/ip_whitelist/TC_010_Create_IP_Whitelisting_RF.md | IP Whitelisting specification |
| prompts/device_state/TC_002_Device_State_Change_RF.md | Device State Change specification |
| prompts/device_plan/TC_014_Change_Device_Plan_RF.md | Change Device Plan specification |
| prompts/cost_center/TC_013_Create_Cost_Center_RF.md | Cost Center specification |
| prompts/csr_journey/TC_005_Create_CSR_Journey_RF 1.md | CSR Journey specification |
| prompts/sim_product_type/TC_006_Create_SIM_Product_Type_RF 1.md | SIM Product Type specification |
| prompts/e2e_flow/E2E_Flow.md | E2E Flow A & B (with usage) specification |
