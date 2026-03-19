*** Settings ***
Library    SeleniumLibrary

*** Keywords ***
Open Test Browser
    [Documentation]    Opens browser with the configured settings. Handles SSL warnings for HTTPS IP addresses.
    [Arguments]    ${url}    ${browser}
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome_options}    add_argument    --allow-insecure-localhost
    Call Method    ${chrome_options}    add_argument    --start-maximized
    Evaluate    $chrome_options.set_capability('acceptInsecureCerts', True)
    IF    '${browser}' == 'headlesschrome'
        Call Method    ${chrome_options}    add_argument    --headless=new
        Call Method    ${chrome_options}    add_argument    --window-size=1920,1080
        Create Webdriver    Chrome    options=${chrome_options}
    ELSE IF    '${browser}' == 'chrome'
        Create Webdriver    Chrome    options=${chrome_options}
    ELSE IF    '${browser}' == 'firefox'
        Open Browser    ${url}    ${browser}
    ELSE IF    '${browser}' == 'edge'
        Open Browser    ${url}    ${browser}
    ELSE
        Open Browser    ${url}    ${browser}
    END
    IF    '${browser}' == 'chrome' or '${browser}' == 'headlesschrome'
        Go To    ${url}
    END
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Set Selenium Timeout    ${PAGE_LOAD_TIMEOUT}

Close Test Browser
    [Documentation]    Closes all browser instances.
    Close All Browsers

Navigate To URL
    [Documentation]    Navigates to the given URL and waits for page load.
    [Arguments]    ${url}
    Go To    ${url}
    Wait For Page Load

Clear Session State
    [Documentation]    Clears cookies and session/local storage to ensure a clean state.
    Delete All Cookies
    Execute Javascript    window.sessionStorage.clear();
    Execute Javascript    window.localStorage.clear();

Navigate To URL With Clean Session
    [Documentation]    Clears session state, then navigates to the URL.
    [Arguments]    ${url}
    Clear Session State
    Go To    ${url}
    Wait For Page Load

Input Text Into Field
    [Documentation]    Waits for element and enters text.
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=10s
    Input Text    ${locator}    ${text}

Clear And Input Text Into Field
    [Documentation]    Clears a field and enters new text.
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=10s
    Clear Element Text    ${locator}
    Input Text    ${locator}    ${text}

Click Element Safely
    [Documentation]    Waits for element to be clickable and clicks it.
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    timeout=10s
    Wait Until Element Is Enabled    ${locator}    timeout=10s
    Click Element    ${locator}

Click Element Via JS
    [Documentation]    Clicks an element using JavaScript (bypasses overlay issues).
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    timeout=10s
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Scroll To Element Via JS
    [Documentation]    Scrolls the page until the element is in view.
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].scrollIntoView({behavior: "smooth", block: "center"});    ARGUMENTS    ${element}

Select Option By Label Via JS
    [Documentation]    Selects a dropdown option by visible label using JavaScript.
    [Arguments]    ${locator}    ${label}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    var select = arguments[0]; for(var i=0; i<select.options.length; i++){ if(select.options[i].text.trim()==='${label}'){ select.selectedIndex=i; select.dispatchEvent(new Event('change')); break; } }
    ...    ARGUMENTS    ${element}

Select Option By Index Via JS
    [Documentation]    Selects a dropdown option by index using JavaScript.
    [Arguments]    ${locator}    ${index}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    arguments[0].selectedIndex=${index}; arguments[0].dispatchEvent(new Event('change'));
    ...    ARGUMENTS    ${element}

Set Input Value Via JS
    [Documentation]    Sets input value using JavaScript and dispatches input/change events
    ...                to trigger React state updates.
    [Arguments]    ${locator}    ${value}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    var el = arguments[0];
    ...    var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    ...    nativeInputValueSetter.call(el, arguments[1]);
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('change', { bubbles: true }));
    ...    ARGUMENTS    ${element}    ${value}

Capture Step Screenshot
    [Documentation]    Takes a screenshot with a descriptive name.
    [Arguments]    ${step_name}
    Capture Page Screenshot    ${step_name}.png

Capture Test Screenshot
    [Documentation]    Captures screenshot on test failure.
    Run Keyword If Test Failed    Capture Page Screenshot

Open Browser And Navigate
    [Documentation]    Opens a fresh browser, clears session state, and navigates to the URL.
    [Arguments]    ${url}    ${browser}
    Open Test Browser    ${url}    ${browser}

Capture Screenshot And Close Browser
    [Documentation]    Captures screenshot on failure, then closes the browser.
    Run Keyword If Test Failed    Capture Page Screenshot
    Close All Browsers

Wait For Page Load
    [Documentation]    Waits for the page to fully load (React rendering complete).
    ...                Retries up to 3 times for transient network issues.
    Wait Until Keyword Succeeds    3x    2s    Wait For Document Ready

Wait For Document Ready
    [Documentation]    Checks that document.readyState is complete.
    Wait For Condition    return document.readyState === 'complete'    timeout=30s

Wait For App Loading To Complete
    [Documentation]    Waits until the body loading-indicator class is removed.
    [Arguments]    ${timeout}=30s
    ${has_indicator}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//body[contains(@class,'loading-indicator')]
    IF    ${has_indicator}
        Wait Until Page Does Not Contain Element
        ...    xpath=//body[contains(@class,'loading-indicator')]
        ...    timeout=${timeout}
    END
    Sleep    0.5s
