*** Settings ***
Library    SeleniumLibrary

*** Keywords ***
Open Test Browser
    [Arguments]    ${url}    ${browser}=chrome
    # Chrome: accept self-signed SSL (e.g. https://192.168.1.26:7874)
    Run Keyword If    '${browser}'=='chrome'    Open Chrome With SSL Ignore    ${url}
    Run Keyword If    '${browser}'!='chrome'    Open Browser    ${url}    ${browser}

Open Chrome With SSL Ignore
    [Arguments]    ${url}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --ignore-certificate-errors
    Open Browser    ${url}    chrome    options=${options}

Close Test Browser
    Close All Browsers

Open Test Browser And Go To Login
    [Arguments]    ${url}    ${browser}=chrome
    [Documentation]    Open browser and navigate to login URL. Use in Test Setup for a fresh browser per test.
    Open Test Browser    ${url}    ${browser}

Navigate To URL
    [Arguments]    ${url}
    Go To    ${url}
