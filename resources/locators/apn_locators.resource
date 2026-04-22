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

# ── Manage APN Grid — Search ───────────────────────────────────────
${LOC_APN_SEARCH_INPUT}            xpath=//input[@placeholder='Enter Search Text']

# ── Manage APN Grid — Rows ──────────────────────────────────────────
${LOC_APN_GRID_ROWS}               xpath=//div[contains(@class,'k-grid')]//tbody/tr[contains(@class,'k-master-row')]

# ── Manage APN Grid — Pagination ────────────────────────────────────
${LOC_APN_PAGINATION}              xpath=//*[contains(@class,'k-pager-wrap')]
${LOC_APN_PAGE_NEXT}               xpath=//*[contains(@class,'k-pager-wrap')]//a[@title='Go to the next page']
${LOC_APN_PAGE_PREV}               xpath=//*[contains(@class,'k-pager-wrap')]//a[@title='Go to the previous page']
${LOC_APN_PAGE_LAST}               xpath=//*[contains(@class,'k-pager-wrap')]//a[@title='Go to the last page']
${LOC_APN_PAGE_SIZE_SELECT}        xpath=//*[contains(@class,'k-pager-sizes')]//select
${LOC_APN_PAGER_INFO}              xpath=//*[contains(@class,'k-pager-info')]

# ── Manage APN Grid — Export ────────────────────────────────────────
${LOC_APN_EXPORT_BTN}              xpath=//a[contains(@class,'k-grid-excel') or @title='Export to Excel' or @title='Export' or contains(@class,'export')] | //button[contains(@title,'Export') or contains(@class,'export')] | //i[contains(@class,'fa-download') or contains(@class,'fa-file-excel') or contains(@class,'fa-file-csv')]/parent::* | //span[contains(@class,'k-i-excel') or contains(@class,'k-i-download')]/parent::*

# ── Manage APN Grid — Column Headers & Sort ─────────────────────────
${LOC_APN_COLUMN_HEADERS}          xpath=//div[contains(@class,'k-grid')]//th[@role='columnheader']
${LOC_APN_SORT_LINK}               xpath=//th[@role='columnheader']//a[@class='k-link']

# ── Manage APN Grid — Column Filter ────────────────────────────────
${LOC_APN_FILTER_ICON}             xpath=(//th[@role='columnheader']//a[contains(@class,'k-grid-filter')])[1]
${LOC_APN_FILTER_INPUT}            xpath=//div[contains(@class,'k-filter-menu')]//input[contains(@class,'k-textbox')]
${LOC_APN_FILTER_SUBMIT}           xpath=//div[contains(@class,'k-filter-menu')]//button[contains(@class,'k-primary')]
${LOC_APN_FILTER_CLEAR}            xpath=//div[contains(@class,'k-filter-menu')]//button[not(contains(@class,'k-primary'))]

# ── Manage APN Grid — Action Icons ─────────────────────────────────
${LOC_APN_EDIT_ICON_FIRST}         xpath=(//div[contains(@class,'k-grid')]//tbody//tr[contains(@class,'k-master-row')]//a[contains(@class,'k-grid-Edit') or @title='Edit'] | //div[contains(@class,'k-grid')]//tbody//tr[1]//i[contains(@class,'fa-pencil') or contains(@class,'fa-edit') or contains(@class,'k-i-edit') or @title='Edit']/parent::* | //div[contains(@class,'k-grid')]//tbody//tr[1]/td[1]//a)[1]
${LOC_APN_DELETE_ICON_FIRST}       xpath=(//div[contains(@class,'k-grid')]//tbody//tr[contains(@class,'k-master-row')]//a[@title='Delete'] | //div[contains(@class,'k-grid')]//tbody//tr[1]//i[contains(@class,'fa-trash') or @title='Delete']/parent::*)[1]

# ── Delete Confirmation Dialog (SweetAlert / Custom Modal) ──────────
${LOC_APN_DELETE_CONFIRM}          xpath=//div[contains(@class,'swal2-popup') or contains(@class,'swal2-modal') or contains(@class,'swal-modal') or contains(@class,'modal-dialog') or contains(@class,'k-window') or contains(@class,'confirm')]
${LOC_APN_DELETE_OK_BTN}           xpath=//button[contains(@class,'swal2-confirm') or contains(@class,'swal-confirm')] | //div[contains(@class,'swal2-actions') or contains(@class,'swal-buttonswrapper')]//button[normalize-space()='OK'] | //div[contains(@class,'modal') or contains(@class,'confirm')]//button[normalize-space()='OK' or normalize-space()='Yes']

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

# ── Subnet Mask — IPV4 Row Elements ────────────────────────────────
${LOC_IPV4_ADD_SUBNET_BTN}         xpath=(//div[@id='onetimechanges']//a[contains(@class,'pulsgreen')])[1]
${LOC_IPV4_CSV_UPLOAD_LINK}        xpath=(//div[@id='onetimechanges']//*[contains(text(),'CSV Upload')])[1]
${LOC_IPV4_CSV_FILE_INPUT}         xpath=(//div[@id='onetimechanges']//input[@type='file'])[1]
${LOC_IPV4_TOTAL_HOST}             xpath=//div[@id='onetimechanges']//*[contains(text(),'Total Host IPV4') or contains(text(),'Total Host IPv4') or contains(text(),'Total Host Ipv4')]

# ── Subnet Mask — IPV6 Row Elements ────────────────────────────────
${LOC_IPV6_ADD_SUBNET_BTN}         xpath=(//div[@id='onetimechanges']//a[contains(@class,'pulsgreen')])[last()]
${LOC_IPV6_CSV_UPLOAD_LINK}        xpath=(//div[@id='onetimechanges']//*[contains(text(),'CSV Upload')])[last()]
${LOC_IPV6_CSV_FILE_INPUT}         xpath=(//div[@id='onetimechanges']//input[@type='file'])[last()]
${LOC_IPV6_TOTAL_HOST}             xpath=//div[@id='onetimechanges']//*[contains(text(),'Total Host IPV6') or contains(text(),'Total Host IPv6') or contains(text(),'Total Host Ipv6')]

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
