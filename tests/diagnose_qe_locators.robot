*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers

*** Test Cases ***
Diagnose SIM Range Page
    Go To    ${CREATE_SIM_RANGE_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Sleep    3s
    ${html}=    Execute Javascript
    ...    var ins = document.querySelectorAll('input, select'); var r = [];
    ...    for (var i = 0; i < ins.length; i++) { var e = ins[i]; r.push({tag:e.tagName, name:e.name, id:e.id, placeholder:e.placeholder, testid:e.getAttribute('data-testid'), type:e.type}); }
    ...    return JSON.stringify(r);
    Log To Console    \n=== SIM RANGE PAGE INPUTS ===
    Log To Console    ${html}

Diagnose CSR Journey Page
    Go To    ${CREATE_CSR_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Sleep    3s
    ${html}=    Execute Javascript
    ...    var els = document.querySelectorAll('div[class*="select"], div[class*="journey"], div[data-testid]'); var r = [];
    ...    for (var i = 0; i < els.length && i < 30; i++) { var e = els[i]; r.push({class:e.className.substring(0,80), testid:e.getAttribute('data-testid'), id:e.id}); }
    ...    return JSON.stringify(r);
    Log To Console    \n=== CSR JOURNEY PAGE CUSTOM DROPDOWNS ===
    Log To Console    ${html}

Diagnose SIM Order Page
    Go To    ${CREATE_SIM_ORDER_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Sleep    3s
    ${html}=    Execute Javascript
    ...    var all = []; var ins = document.querySelectorAll('input, select'); for (var i = 0; i < ins.length; i++) { var e = ins[i]; all.push({kind:'input', tag:e.tagName, name:e.name, id:e.id, placeholder:e.placeholder, testid:e.getAttribute('data-testid'), type:e.type}); }
    ...    var dds = document.querySelectorAll('div[data-testid], div[class*="selectBtn"], div[class*="select"]'); for (var j = 0; j < dds.length && j < 20; j++) { var d = dds[j]; all.push({kind:'div', class:d.className.substring(0,60), testid:d.getAttribute('data-testid'), id:d.id}); }
    ...    var grids = document.querySelectorAll('[id*="rid"], [id*="Grid"]'); for (var k = 0; k < grids.length; k++) { all.push({kind:'grid', tag:grids[k].tagName, id:grids[k].id, class:grids[k].className.substring(0,50)}); }
    ...    return JSON.stringify(all);
    Log To Console    \n=== SIM ORDER PAGE ELEMENTS ===
    Log To Console    ${html}

Diagnose Manage Devices Filter
    Go To    ${MANAGE_DEVICES_URL}
    Wait For Page Load
    Wait For Loading Overlay To Disappear
    Sleep    3s
    ${html}=    Execute Javascript
    ...    var els = document.querySelectorAll('[id*="filter"], [id*="Filter"], button, [data-testid]'); var r = [];
    ...    for (var i = 0; i < els.length && i < 40; i++) { var e = els[i]; r.push({tag:e.tagName, id:e.id, class:(e.className||'').toString().substring(0,60), testid:e.getAttribute('data-testid'), text:(e.textContent||'').substring(0,30)}); }
    ...    return JSON.stringify(r);
    Log To Console    \n=== MANAGE DEVICES FILTER ELEMENTS ===
    Log To Console    ${html}
