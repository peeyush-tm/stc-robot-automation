*** Variables ***
# Login Page — from login-and-navigate-managedevices-automation (Login.js)
${LOC_LOGIN_ROOT}              xpath=//div[@id='root']
${LOC_LOGIN_USERNAME}          xpath=//input[@name='username']
${LOC_LOGIN_PASSWORD}          xpath=//input[@name='password']
# CAPTCHA: id is dynamic (UUID), use name=captcha. HTML: <input name="captcha" placeholder="Enter Captcha" ...>
${LOC_LOGIN_CAPTCHA}           name=captcha
${LOC_LOGIN_CAPTCHA_IMG}       xpath=//img[@id='image']
${LOC_LOGIN_BUTTON}            xpath=//input[@type='button' and contains(@class,'btn-custom-color')]
${LOC_LOGIN_ERROR}             xpath=//div[contains(@class,'erre-it')]

# Manage Devices Page — validate successful login (post-login lands here)
# Main devices grid — id=gridData or xpath=//div[@id='gridData'] (source line 10691)
${LOC_MANAGEDEVICES_GRID}      id=gridData
${LOC_MANAGEDEVICES_SEARCH}    xpath=//input[@id='searchinput']
${LOC_MANAGEDEVICES_ACTION_FORM}    xpath=//form[@id='actionForm']
