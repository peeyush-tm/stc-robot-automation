*** Variables ***
# ── Login Page Locators (verified against Login.js) ─────────────────
${LOC_LOGIN_ROOT}                  xpath=//div[@id='root']
${LOC_LOGIN_USERNAME_INPUT}        xpath=//input[@name='username']
${LOC_LOGIN_PASSWORD_INPUT}        xpath=//input[@name='password']
${LOC_LOGIN_CAPTCHA_INPUT}         xpath=//input[@name='captcha']
${LOC_LOGIN_CAPTCHA_IMAGE}         xpath=//img[@id='image']
${LOC_LOGIN_BUTTON}                xpath=//input[@type='button' and contains(@class,'btn-custom-color')]
${LOC_LOGIN_ERROR_MESSAGE}         xpath=//div[contains(@class,'erre-it')]
${LOC_LOGIN_TOAST_ERROR}           xpath=//div[contains(@class,'Toastify__toast--error')] | //div[contains(@class,'Toastify')]//div[contains(@class,'toast--error')]
${LOC_LOGIN_FIELD_VALIDATION}      xpath=//*[contains(text(),'is required') or contains(text(),'Required')]
${LOC_USERNAME_VALIDATION}         xpath=//*[contains(text(),'Username is required')]
${LOC_PASSWORD_VALIDATION}         xpath=//*[contains(text(),'Password Required')]

# ── Post-Login / Navigation Locators ────────────────────────────────
${LOC_POST_LOGIN_LANDMARK}         xpath=//div[@id='gridData']//tbody[@role='rowgroup']//tr[contains(@class,'k-master-row')]
${LOC_USER_PROFILE_MENU}           xpath=//li[@id='userSetting']//a
# Open user menu: first li under #userSetting, then Log Out (see Perform Logout).
${LOC_USER_SETTING_DROPDOWN_TRIGGER}    xpath=//li[@id='userSetting']//li[1]
# Icon class (CMP) or visible "Log Out" / "Logout" text inside user menu
${LOC_LOGOUT_BUTTON}               xpath=//li[@id='userSetting']//a[.//i[contains(@class,'user-log-out')]] | //a[.//i[contains(@class,'user-log-out')]] | //li[@id='userSetting']//*[self::a or self::span][contains(translate(normalize-space(.),'LOGOUT','logout'),'log out')] | //a[contains(translate(normalize-space(.),'LOGOUT','logout'),'log out')]

# ── Manage Devices Page Locators (verified against ManageDevices.js) ─
${LOC_MD_GRID_DATA}                xpath=//div[@id='gridData']
${LOC_MD_SEARCH_INPUT}             xpath=//input[@id='searchinput'] | //input[@placeholder='Search Device'] | //input[@placeholder='Enter Search Text']
${LOC_MD_ACTION_FORM}              xpath=//form[@id='actionForm']
${LOC_MD_GRID_TBODY}               xpath=//div[@id='gridData']//tbody[@role='rowgroup']
${LOC_MD_FIRST_DEVICE_ROW}         xpath=(//div[@id='gridData']//tr[contains(@class,'k-master-row')])[1]
${LOC_MD_DEVICE_ROWS}              xpath=//div[@id='gridData']//tr[contains(@class,'k-master-row')]
