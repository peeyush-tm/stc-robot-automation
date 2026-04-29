# STC Automation — All Modules and Test Cases Reference

**Source:** `tasks.csv` (project root) + standalone test suites  
**Last updated:** 2026-04-23  
**Total test cases:** 658 across 30 test suites (22 core + 5 feature) + 1 diagnostic utility

This document lists all test modules, their test case IDs/names, and the prompt documentation available for each. Use it for AI prompts, traceability, and run filters.

---

## Module Summary

| # | Module | Suite File | TCs | Prompt File |
|---|--------|------------|-----|-------------|
| 1 | Login | tests/login_tests.robot | 12 | prompts/login/Login.md |
| 2 | Sanity | tests/sanity_tests.robot | 48 | prompts/sanity/Sanity.md |
| 3 | Onboard Customer API | tests/onboard_customer_api_tests.robot | 38 | prompts/account_onboard/Account_Onboard.md |
| 4 | APN | tests/apn_tests.robot | 65 | prompts/apn/APN.md |
| 5 | SIM Range | tests/sim_range_tests.robot | 21 | prompts/sim_range/SIM_Range.md |
| 6 | SIM Range MSISDN | tests/sim_range_msisdn_tests.robot | 26 | prompts/sim_range_msisdn/SIM_Range_MSISDN.md |
| 7 | SIM Order | tests/sim_order_tests.robot | 21 | prompts/sim_order/SIM_Order.md |
| 8 | IP Pool | tests/ip_pool_tests.robot | 17 | prompts/ip_pool/IP_Pool.md |
| 9 | IP Whitelist | tests/ip_whitelist_tests.robot | 20 | prompts/ip_whitelist/IP_Whitelist.md |
| 10 | Cost Center | tests/cost_center_tests.robot | 25 | prompts/cost_center/Cost_Center.md |
| 11 | CSR Journey | tests/csr_journey_tests.robot | 12 | prompts/csr_journey/CSR_Journey.md |
| 12 | Product Type | tests/product_type_tests.robot | 18 | prompts/sim_product_type/SIM_Product_Type.md |
| 13 | Rule Engine | tests/rule_engine_tests.robot | 155 | prompts/rule_engine/Rule_Engine.md |
| 14 | Role Management | tests/role_management_tests.robot | 33 | prompts/role_management/Role_Management.md |
| 15 | User Management | tests/user_management_tests.robot | 45 | prompts/user_management/User_Management.md |
| 16 | Label | tests/label_tests.robot | 28 | prompts/label/Label.md |
| 17 | Report | tests/report_tests.robot | 14 | prompts/report/Report.md |
| 18 | SIM Movement | tests/sim_movement_tests.robot | 6 | prompts/sim_movement/SIM_Movement.md |
| 19 | SIM Replacement | tests/sim_replacement_tests.robot | 6 | prompts/sim_replacement/SIM_Replacement.md |
| 20 | E2E Flow A | tests/e2e_flow.robot | 21 | prompts/e2e_flow/E2E_Flow.md |
| 21 | E2E Flow B | tests/e2e_flow_with_usage.robot | 23 | prompts/e2e_flow_with_usage/E2E_Flow_With_Usage.md |
| 22 | Role/User CRUD | tests/role_user_crud_tests.robot | 4 | (inline, tested via --with-crud) |
| — | Order Processing | (shared keywords) | — | prompts/order_processing/Order_Processing.md |

### Feature Suites (deep per-page UI coverage)

| # | Module | Suite File | TCs | Prompt File |
|---|--------|------------|-----|-------------|
| 26 | CSR Journey Feature | tests/csr_journey_feature_tests.robot | 213 | prompts/csr_journey_feature/CSR_Journey_Feature.md |
| 27 | Manage Devices Feature | tests/manage_devices_feature_tests.robot | 43 | prompts/manage_devices_feature/Manage_Devices_Feature.md |
| 28 | Device APN Feature | tests/device_apn_feature_tests.robot | 35 | prompts/device_apn_feature/Device_APN_Feature.md |
| 29 | Device VAS Charges Feature | tests/device_vas_charges_feature_tests.robot | 6 | prompts/device_vas_charges_feature/Device_VAS_Charges_Feature.md |
| 30 | Setup Prerequisite Feature | tests/setup_prerequisite_feature_tests.robot | 4 | prompts/setup_prerequisite_feature/Setup_Prerequisite_Feature.md |

### Diagnostic Utility (not counted in the 30 suites)

| Utility | File | Prompt File |
|---------|------|-------------|
| Diagnose QE Locators | tests/diagnose_qe_locators.robot | prompts/diagnose_qe_locators/Diagnose_QE_Locators.md |

---

## Run Commands

```bash
# All suites in tasks.csv order
python run_tests.py --env qe

# By module name
python run_tests.py --suite "Login" --env qe
python run_tests.py --suite "APN" --env qe
python run_tests.py --suite "SIM Range" --env qe
python run_tests.py --suite "SIM Range MSISDN" --env qe
python run_tests.py --suite "SIM Order" --env qe
python run_tests.py --suite "IP Pool" --env qe
python run_tests.py --suite "IP Whitelist" --env qe
python run_tests.py --suite "Cost Center" --env qe
python run_tests.py --suite "CSR Journey" --env qe
python run_tests.py --suite "SIM Product Type" --env qe
python run_tests.py --suite "Rule Engine" --env qe
python run_tests.py --suite "Role Management" --env qe
python run_tests.py --suite "User Management" --env qe
python run_tests.py --suite "Label" --env qe
python run_tests.py --suite "Report" --env qe

# Standalone suites (run by file)
python run_tests.py tests/sim_movement_tests.robot --env qe
python run_tests.py tests/sim_replacement_tests.robot --env qe

# Feature suites (deep UI coverage — run by file, not in tasks.csv)
python run_tests.py tests/csr_journey_feature_tests.robot --env qe
python run_tests.py tests/manage_devices_feature_tests.robot --env qe
python run_tests.py tests/device_apn_feature_tests.robot --env qe
python run_tests.py tests/device_vas_charges_feature_tests.robot --env qe
python run_tests.py tests/setup_prerequisite_feature_tests.robot --env qe

# Diagnostic utility (logs DOM state, no assertions)
python run_tests.py tests/diagnose_qe_locators.robot --env qe

# E2E flows
python run_tests.py --e2e --env qe
python run_tests.py --e2e-with-usage --env qe
python run_tests.py --e2e --with-crud --env qe

# Sanity
python run_tests.py --sanity --env qe
python run_tests.py --sanity --env qe --parallel 4

# By tag
python run_tests.py --include smoke --env qe
python run_tests.py --suite "APN" --env qe --include regression

# With email report
python run_tests.py --suite "Login" --env qe --email

# Headless
python run_tests.py --e2e --env qe --browser headlesschrome
```

---

## Full Test Case ID Ranges

- **Login:** TC_LOGIN_001 … TC_LOGIN_012
- **Sanity:** TC_SANITY_001 … TC_SANITY_048
- **Onboard Customer API:** TC_OCA_001 … TC_OCA_038
- **APN:** TC_APN_001 … TC_APN_065
- **SIM Range:** TC_SR_001 … TC_SR_021
- **SIM Range MSISDN:** TC_SRM_001 … TC_SRM_026
- **SIM Order:** TC_SO_001 … TC_SO_021
- **IP Pool:** TC_IPP_001 … TC_IPP_017
- **IP Whitelist:** TC_IPW_001 … TC_IPW_020
- **Cost Center:** TC_CC_001 … TC_CC_025
- **CSR Journey:** TC_CSRJ_001 … TC_CSRJ_012
- **Product Type:** TC_PT_001 … TC_PT_018
- **Rule Engine:** TC_RE_001 … TC_RE_155
- **Role Management:** TC_RM_001 … TC_RM_033
- **User Management:** TC_UM_001 … TC_UM_045
- **Label:** TC_LBL_001 … TC_LBL_028
- **Report:** TC_RPT_001 … TC_RPT_014
- **SIM Movement:** TC_SMOV_001 … TC_SMOV_006
- **SIM Replacement:** TC_SIMRPL_001 … TC_SIMRPL_006
- **E2E Flow A:** TC_E2E_001 … TC_E2E_021
- **E2E Flow B:** TC_E2EU_001 … TC_E2EU_023
- **Role/User CRUD:** TC_RUCRD_001 … TC_RUCRD_004

### Feature Suites
- **CSR Journey Feature:** TC_CSRJF_001 … TC_CSRJF_213 (213 TCs, grouped A–G)
- **Manage Devices Feature:** TC_MDEV_001 … TC_MDEV_043
- **Device APN Feature:** TC_DAPN_001 … TC_DAPN_035
- **Device VAS Charges Feature:** TC_VAS_001 … TC_VAS_006
- **Setup Prerequisite Feature:** TC_SETUP_001 … TC_SETUP_004

For exact names and tags, open `tasks.csv` or the individual test `.robot` files.

---

## Prompts Folder Structure

| Folder / File | Description |
|---------------|-------------|
| prompts/ALL_MODULES_AND_TESTCASES.md | This file — master module and test case reference |
| prompts/login/Login.md | Login module specification |
| prompts/login/TC_001_Login_Navigate_RF.md | Login & Navigate detailed spec |
| prompts/sanity/Sanity.md | Sanity suite — 48 page-load checks |
| prompts/account_onboard/Account_Onboard.md | SOAP API customer onboarding spec |
| prompts/apn/APN.md | APN module specification |
| prompts/apn/TC_007_Create_APN_RF.md | APN detailed spec |
| prompts/sim_range/SIM_Range.md | SIM Range ICCID/IMSI spec |
| prompts/sim_range/TC_004_Create_SIM_Range_RF.md | SIM Range detailed spec |
| prompts/sim_range/TC_012_Create_SIM_Range_MSISDN_RF.md | SIM Range MSISDN detailed spec |
| prompts/sim_range_msisdn/SIM_Range_MSISDN.md | SIM Range MSISDN module spec |
| prompts/sim_order/SIM_Order.md | SIM Order module spec |
| prompts/sim_order/TC_003_Create_SIM_Order_RF.md | SIM Order detailed spec |
| prompts/ip_pool/IP_Pool.md | IP Pool module spec |
| prompts/ip_pool/TC_008_Create_IP_Pool_RF.md | IP Pool detailed spec |
| prompts/ip_whitelist/IP_Whitelist.md | IP Whitelisting module spec |
| prompts/ip_whitelist/TC_010_Create_IP_Whitelisting_RF.md | IP Whitelist detailed spec |
| prompts/device_state/Device_State.md | Device State Change module spec |
| prompts/device_state/TC_002_Device_State_Change_RF.md | Device State detailed spec |
| prompts/device_plan/Device_Plan.md | Device Plan module spec |
| prompts/device_plan/TC_014_Change_Device_Plan_RF.md | Device Plan detailed spec |
| prompts/cost_center/Cost_Center.md | Cost Center module spec |
| prompts/cost_center/TC_013_Create_Cost_Center_RF.md | Cost Center detailed spec |
| prompts/csr_journey/CSR_Journey.md | CSR Journey module spec |
| prompts/csr_journey/TC_005_Create_CSR_Journey_RF 1.md | CSR Journey detailed spec |
| prompts/sim_product_type/SIM_Product_Type.md | SIM Product Type module spec |
| prompts/sim_product_type/TC_006_Create_SIM_Product_Type_RF 1.md | Product Type detailed spec |
| prompts/e2e_flow/E2E_Flow.md | E2E Flow A specification (17 steps) |
| prompts/e2e_flow_with_usage/E2E_Flow_With_Usage.md | E2E Flow B specification (20 steps) |
| prompts/rule_engine/Rule_Engine.md | Rule Engine module spec (4-tab wizard) |
| prompts/role_management/Role_Management.md | Role Management module spec |
| prompts/user_management/User_Management.md | User Management module spec |
| prompts/label/Label.md | Label module spec (CRUD + tag assignment) |
| prompts/report/Report.md | Report module spec (create/download/email) |
| prompts/sim_movement/SIM_Movement.md | SIM Movement module spec |
| prompts/sim_replacement/SIM_Replacement.md | SIM Replacement module spec |
| prompts/payg_data_usage/PAYG_Data_Usage.md | PAYG Data Usage multi-scenario spec |
| prompts/order_processing/Order_Processing.md | Order Processing shared keywords spec |
| prompts/csr_journey_feature/CSR_Journey_Feature.md | CSR Journey Feature suite (213 TCs) |
| prompts/manage_devices_feature/Manage_Devices_Feature.md | Manage Devices Feature suite (43 TCs) |
| prompts/device_apn_feature/Device_APN_Feature.md | Device APN Feature suite (35 TCs) |
| prompts/device_vas_charges_feature/Device_VAS_Charges_Feature.md | Device VAS Charges Feature suite (6 TCs) |
| prompts/setup_prerequisite_feature/Setup_Prerequisite_Feature.md | Setup Prerequisite Feature suite (4 TCs) |
| prompts/diagnose_qe_locators/Diagnose_QE_Locators.md | Diagnostic utility — logs DOM state per page |

---

## Bug Reports & Email

```bash
# Bug reports auto-generate after every run with failures
# Email report
python run_tests.py --suite "Login" --env qe --email

# Jira bug logger
python jira_bug_logger.py --all
python jira_bug_logger.py --list
```
