*** Settings ***
Library    SeleniumLibrary

*** Keywords ***
Open Test Browser
    [Documentation]    Opens browser with the configured settings. Handles SSL warnings for HTTPS IP addresses.
    ...                Supports: chrome, headlesschrome, firefox, edge.
    [Arguments]    ${url}    ${browser}
    IF    '${browser}' == 'headlesschrome'
        ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
        # SSL / certificate bypass
        Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
        Call Method    ${chrome_options}    add_argument    --allow-insecure-localhost
        Call Method    ${chrome_options}    add_argument    --allow-running-insecure-content
        Evaluate    $chrome_options.set_capability('acceptInsecureCerts', True)
        # Headless-specific — must NOT use --start-maximized in headless mode
        # Use Evaluate for args containing "=" to avoid RF named-argument parsing
        Evaluate    $chrome_options.add_argument('--headless=new')
        Evaluate    $chrome_options.add_argument('--window-size=1920,1080')
        Call Method    ${chrome_options}    add_argument    --disable-gpu
        Call Method    ${chrome_options}    add_argument    --no-sandbox
        Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
        Call Method    ${chrome_options}    add_argument    --disable-extensions
        Call Method    ${chrome_options}    add_argument    --disable-infobars
        Evaluate    $chrome_options.add_argument('--remote-debugging-port=0')
        Create Webdriver    Chrome    options=${chrome_options}
        Go To    ${url}
    ELSE IF    '${browser}' == 'chrome'
        ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
        Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
        Call Method    ${chrome_options}    add_argument    --allow-insecure-localhost
        Call Method    ${chrome_options}    add_argument    --start-maximized
        Evaluate    $chrome_options.set_capability('acceptInsecureCerts', True)
        Create Webdriver    Chrome    options=${chrome_options}
        Go To    ${url}
    ELSE IF    '${browser}' == 'firefox'
        Open Browser    ${url}    ${browser}
    ELSE IF    '${browser}' == 'edge'
        Open Browser    ${url}    ${browser}
    ELSE
        Open Browser    ${url}    ${browser}
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
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Input Text    ${locator}    ${text}

Clear And Input Text Into Field
    [Documentation]    Clears a field and enters new text.
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Clear Element Text    ${locator}
    Input Text    ${locator}    ${text}

Click Element Safely
    [Documentation]    Waits for loading overlay to disappear, then clicks element.
    [Arguments]    ${locator}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Wait Until Element Is Enabled    ${locator}    timeout=30s
    Click Element    ${locator}

Click Element Via JS
    [Documentation]    Waits for loading overlay, then clicks via JavaScript (bypasses overlay issues).
    [Arguments]    ${locator}
    Wait For Loading Overlay To Disappear
    Wait Until Element Is Visible    ${locator}    timeout=30s
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

Handle Test Teardown
    [Documentation]    Captures screenshot on failure only. Does NOT close the browser
    ...                so that the suite-level session is preserved for the next test.
    Run Keyword If Test Failed    Capture Page Screenshot

Wait For Page Load
    [Documentation]    Waits for the page to fully load (React rendering complete).
    ...                Retries up to 3 times for transient network issues.
    Wait Until Keyword Succeeds    3x    2s    Wait For Document Ready
    Wait For Loading Overlay To Disappear

Wait For App Loading To Complete
    [Documentation]    Alias for Wait For Page Load. Waits until document is ready and loading overlay gone.
    ...                Accepts optional timeout argument for backward compatibility.
    [Arguments]    ${timeout}=60s
    Wait Until Keyword Succeeds    3x    2s    Wait For Document Ready
    Wait For Loading Overlay To Disappear

Wait For Document Ready
    [Documentation]    Checks that document.readyState is complete.
    Wait For Condition    return document.readyState === 'complete'    timeout=30s

Wait For Loading Overlay To Disappear
    [Documentation]    Waits until the body.loading-indicator overlay is gone.
    ...                The CMP app adds class "loading-indicator" to <body> during API calls.
    ...                If the indicator is stuck for > 25s, force-removes it via JS and warns.
    ${cleared}=    Run Keyword And Return Status
    ...    Wait For Condition
    ...    return !document.body.classList.contains('loading-indicator')
    ...    timeout=25s
    IF    not ${cleared}
        Log    Loading overlay stuck for 25s — force-removing via JS.    level=WARN
        Execute Javascript    document.body.classList.remove('loading-indicator');
        Sleep    1s
    END
