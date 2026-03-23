*** Settings ***
Library     SeleniumLibrary
Library     OperatingSystem
Resource    ../resources/keywords/browser_keywords.resource
Resource    ../resources/keywords/login_keywords.resource
Resource    ../resources/keywords/report_keywords.resource
Resource    ../resources/locators/login_locators.resource
Resource    ../resources/locators/report_locators.resource
Library     ../libraries/ConfigLoader.py
Variables   ../variables/login_variables.py
Variables   ../variables/report_variables.py

Suite Setup       Run Keywords    Load Environment Config From Json    ${ENV}    AND    Suite Login Setup    ${BASE_URL}    ${BROWSER}
Suite Teardown    Close All Browsers

*** Test Cases ***
TC_015_000 Debug Report Form DOM
    [Documentation]    DOM dump: finds all select elements and custom components on the Create Report form.
    Navigate To Reports Page
    Open Create Report Form
    Capture Page Screenshot    debug_form_open.png

    # Dump 1: all <select> elements — name, visibility, options
    ${d1}=    Execute JavaScript
    ...    return JSON.stringify(Array.from(document.querySelectorAll('select')).map(function(s){
    ...        var cs=window.getComputedStyle(s);
    ...        return {name:s.name,id:s.id,display:cs.display,visibility:cs.visibility,
    ...                optCount:s.options.length,
    ...                opts:Array.from(s.options).slice(0,6).map(function(o){return o.value+'|'+o.text;})};
    ...    }),null,0);
    Log    SELECTS=${d1}    console=yes

    # Dump 2: parent structure around each label
    ${d2}=    Execute JavaScript
    ...    var out={};
    ...    ['Report Category','View Criteria','Display Level','Account','Report Format'].forEach(function(name){
    ...        var lbl=Array.from(document.querySelectorAll('label')).find(function(l){return (l.innerText||'').trim()===name;});
    ...        if(!lbl){out[name]='NO LABEL FOUND';return;}
    ...        var par=lbl.parentElement;
    ...        out[name]={parentTag:par.tagName,parentClass:par.className,
    ...            children:Array.from(par.children).map(function(c){
    ...                return c.tagName+'[cls='+c.className.substring(0,50)+'][html='+c.outerHTML.substring(0,200)+']';})};
    ...    });
    ...    return JSON.stringify(out,null,0);
    Log    LABEL_PARENTS=${d2}    console=yes

    # Dump 3: any .Dropdownlist divs
    ${d3}=    Execute JavaScript
    ...    var els=document.querySelectorAll('.Dropdownlist,.searchInput,[class*="dropdown"],[class*="Dropdown"]');
    ...    return JSON.stringify(Array.from(els).map(function(e){
    ...        return {tag:e.tagName,cls:e.className,html:e.outerHTML.substring(0,200)};
    ...    }),null,0);
    Log    CUSTOM_DROPDOWNS=${d3}    console=yes

    # Write to log file
    Create File    ${EXECDIR}${/}debug-356cec.log
    ...    {"dump1":${d1},"dump2":${d2},"dump3":${d3}}\n
    ...    encoding=UTF-8
    Log    LOG WRITTEN: ${EXECDIR}/debug-356cec.log    console=yes
