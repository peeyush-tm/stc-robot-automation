*** Settings ***
Library     SeleniumLibrary
Library     OperatingSystem

*** Keywords ***
Log Page Locators Debug
    [Documentation]    Dumps relevant elements (data-testid, for=, select, react-select, treeview)
    ...                to console and to reports/locator_debug_<timestamp>.txt for IP Whitelist / IP Pool debugging.
    [Arguments]    ${page_name}=Current
    ${timestamp}=    Get Time    epoch
    ${url}=    Get Location
    ${out}=    Execute Javascript
    ...    var out = []; var sel = document.querySelectorAll('[data-testid], [for], select, [class*="select__"], [class*="react-select"], [class*="treeview"], [class*="k-treeview"]');
    ...    sel.forEach(function(el, i) {
    ...      var tag = el.tagName; var id = el.id || ''; var name = el.name || ''; var testid = el.getAttribute('data-testid') || ''; var forAttr = el.getAttribute('for') || '';
    ...      var cls = (el.className && el.className.substring) ? el.className.substring(0, 80) : '';
    ...      var snippet = el.outerHTML ? el.outerHTML.substring(0, 200) : '';
    ...      out.push(tag + ' id=' + id + ' name=' + name + ' data-testid=' + testid + ' for=' + forAttr + ' class=' + cls + ' | ' + snippet);
    ...    });
    ...    return out.join('\\n');
    Log    ========== LOCATOR DEBUG [${page_name}] ==========    console=yes
    Log    URL: ${url}    console=yes
    Log    ${out}    console=yes
    ${safe_name}=    Replace String    ${page_name}    ${SPACE}    _
    ${report_dir}=    Set Variable    ${EXECDIR}${/}reports
    Run Keyword And Ignore Error    Create Directory    ${report_dir}
    ${debug_file}=    Set Variable    ${report_dir}${/}locator_debug_${safe_name}_${timestamp}.txt
    Create File    ${debug_file}    Page: ${page_name}\nURL: ${url}\n\n${out}
    Log    Debug written to: ${debug_file}    console=yes
    RETURN    ${out}

Log Page Source Snippet For Debug
    [Documentation]    Logs a snippet of the page HTML (body innerHTML truncated) to help find correct locators.
    [Arguments]    ${page_name}=Current    ${max_chars}=8000
    ${snippet}=    Execute Javascript
    ...    var html = document.body ? document.body.innerHTML : '';
    ...    return html.length > ${max_chars} ? html.substring(0, ${max_chars}) + '...[truncated]' : html;
    ${timestamp}=    Get Time    epoch
    ${safe_name}=    Replace String    ${page_name}    ${SPACE}    _
    ${report_dir}=    Set Variable    ${EXECDIR}${/}reports
    Run Keyword And Ignore Error    Create Directory    ${report_dir}
    Create File    ${report_dir}${/}page_snippet_${safe_name}_${timestamp}.html    ${snippet}
    Log    Page snippet saved to reports/page_snippet_${safe_name}_${timestamp}.html    console=yes
    RETURN    ${snippet}
