*** Variables ***
# ── Sidebar Navigation ──────────────────────────────────────────────
${LOC_MENU_SERVICE}                xpath=//*[@id="service-menu-icon"]

# ── Top Navigation Tabs (on Service page) ───────────────────────────
${LOC_TAB_SERVICE_PLAN}            xpath=//*[@id="pageHeading"]/li[1]/a[1]
${LOC_TAB_IP_WHITELISTING}         xpath=//*[@id="pageHeading"]/li[2]/a[1]
${LOC_TAB_APN}                     xpath=//*[@id="pageHeading"]/li[3]/a[1]
${LOC_TAB_IP_POOLING}              xpath=//*[@id="pageHeading"]/li[4]/a[1]
${LOC_TAB_APN_REQUEST}             xpath=//*[@id="pageHeading"]/li[5]/a[1]

# ── Manage APN Listing Page ─────────────────────────────────────────
${LOC_CREATE_APN_BTN}              xpath=//a[contains(@href,'/CreateAPN')]
${LOC_MANAGE_APN_GRID}             xpath=//div[contains(@class,'k-grid')]

# ── Create APN — Accordion Headers ─────────────────────────────────
${LOC_PRIMARY_DETAILS_TAB}         xpath=//*[@id="openPrimaryDetailsTab"]
${LOC_RADIUS_DETAILS_TAB}          id=openRadiusDetailsTab
${LOC_SUBNET_MASK_PANEL}           xpath=//a[@href="#onetimechanges"]
${LOC_SECONDARY_DETAILS_PANEL}     xpath=//a[@href="#secondary"]
${LOC_QOS_PANEL}                   xpath=//a[@href="#quality"]

# ── Primary Details Fields ──────────────────────────────────────────
${LOC_APN_TYPE}                    xpath=//select[@name="apnCategory"]
${LOC_ACCOUNT_DROPDOWN}            xpath=//div[contains(@class,'selectBtn') and contains(@class,'form-control')]
${LOC_ACCOUNT_SEARCH_INPUT}        xpath=//div[@id='primarydetails']//input[@placeholder='Search']
${LOC_ACCOUNT_OPTION}              xpath=//div[contains(@class,'selectDropdown')]
${LOC_BU_DROPDOWN}                 xpath=//div[contains(@class,'basic-multi-select')]//div[contains(@class,'select__control')]
${LOC_BU_SEARCH_INPUT}             id=react-select-2-input
${LOC_APN_ID}                      xpath=//input[@name="apnIDID"]
${LOC_APN_NAME}                    xpath=//input[@name="roleName"]
${LOC_DESCRIPTION}                 xpath=//input[@name="roleDescription"]
${LOC_EQOS_ID}                     xpath=//input[@name="EQOSID"]
${LOC_HSS_CONTEXT_ID}              xpath=//input[@name="hssContextId"]
${LOC_IP_ADDRESS_TYPE}             xpath=//*[@id="ipAddressType"]
${LOC_IP_ALLOC_TYPE}               xpath=//select[@name="modificationType"]
${LOC_APN_SERVICE_TYPE}            xpath=//*[@id="apnServiceType"]
${LOC_ROAMING_CHECKBOX}            xpath=//*[@id="Roaming"]

# ── Subnet Mask Section ────────────────────────────────────────────
${LOC_SUBNET_MASK_HEADER}          xpath=//a[@href="#onetimechanges"]
${LOC_SUBNET_MASK_CONTENT}         id=onetimechanges
${LOC_ADD_SUBNET_MASK_BTN}         xpath=//div[@id='onetimechanges']//a[contains(@class,'pulsgreen')]
${LOC_SUBNET_MASK_INPUT}           id=subnetmaskinput0
${LOC_SUBNET_MASK_CIDR}            xpath=//select[@name="subnetmasklist"]
${LOC_SUBNET_CALCULATE_BTN}        xpath=//div[@id='onetimechanges']//button[contains(text(),'Calculate')]
${LOC_SUBNET_FIRST_USABLE_IP}     id=nextAvailableIp0

# ── Secondary Details Fields ────────────────────────────────────────
${LOC_HLR_APN_ID}                  xpath=//input[@name="hlrApnId"]
${LOC_MCC}                         xpath=//input[@name="mcc"]
${LOC_MNC}                         xpath=//input[@name="mnc"]
${LOC_PROFILE_ID}                  xpath=//input[@name="profileId"]

# ── Radius Configuration Fields ────────────────────────────────────
${LOC_RADIUS_CONFIG}               name=apnRediusConfigurationstate
${LOC_RADIUS_AUTH_TYPE}            name=radiusAuthType
${LOC_RADIUS_PASSWORD}             name=radiusPassword
${LOC_REALM}                       name=realmlistdata

# ── QoS — 2G/3G Fields ─────────────────────────────────────────────
${LOC_PROFILE_NAME_2G3G}           xpath=//input[@name="profileName2g3g"]
${LOC_BW_UPLINK_2G3G}             xpath=//input[@name="bandwidthUplink2g3g"]
${LOC_BW_UPLINK_UNIT_2G3G}        xpath=//*[@id="bandwidthUplinkUnit2g3g"]
${LOC_BW_DOWNLINK_2G3G}           xpath=//input[@name="bandwidthDownlink2g3g"]
${LOC_BW_DOWNLINK_UNIT_2G3G}      xpath=//*[@id="bandwidthDownlinkUnit2g3g"]

# ── QoS — LTE Fields ───────────────────────────────────────────────
${LOC_PROFILE_NAME_LTE}           xpath=//input[@name="profileNameLTE"]
${LOC_BW_UPLINK_LTE}              xpath=//input[@name="bandwidthUplinkLTE"]
${LOC_BW_UPLINK_UNIT_LTE}         xpath=//*[@id="bandwidthUplinkUnitLTE"]
${LOC_BW_DOWNLINK_LTE}            xpath=//input[@name="bandwidthDownlinkLTE"]
${LOC_BW_DOWNLINK_UNIT_LTE}       xpath=//*[@id="bandwidthDownlinkUnitLTE"]

# ── File Upload ─────────────────────────────────────────────────────
${LOC_FILE_UPLOAD}                 xpath=//*[@id="files"]

# ── Form Actions ────────────────────────────────────────────────────
${LOC_SUBMIT_BTN}                  xpath=//a[contains(@class,'btn-custom-color') and normalize-space()='Submit']
${LOC_CLOSE_BTN}                   xpath=//a[contains(@class,'btn-cancel-color') and normalize-space()='Close']

# ── Validation ──────────────────────────────────────────────────────
${LOC_TOAST_SUCCESS}               xpath=//div[contains(@class,'Toastify__toast--success')]
${LOC_TOAST_ERROR}                 xpath=//div[contains(@class,'Toastify__toast--error')]
${LOC_ALERT_DANGER}                xpath=//div[contains(@class,'alert-danger')]

# ── Header Elements ─────────────────────────────────────────────────
${LOC_SEARCH_DEVICE_INPUT}         xpath=//*[@id="txtLimit"]
${LOC_SEARCH_TYPE_SELECT}          xpath=//*[@id="searchBoxId"]/div[1]/div[1]/div[1]/select[1]
${LOC_LANGUAGE_DROPDOWN}           xpath=//a[contains(@id,"header-notification")]
${LOC_NOTIFICATION_BELL}           xpath=//*[@id="dropdownbell"]
