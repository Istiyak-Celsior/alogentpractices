<form action="searchgen.asp" name="frmSearch" method="post">
    <input type="hidden" name="searchType" value="Standard">
    <div id="aa-quick-search-title">Quick Search</div>
    <div id="aa-search-panel">
        <table border="0">
            <tr>
                <td class="aa-label">Customer / Business Name:</td>
                <td><div id="combo_zone_cname"></div></td>
                <td class="aa-label">Customer Number:</td>
                <td><div id="combo_zone_cnumber"></div></td>
                <td rowspan="2"><button type="submit" onclick="document.frmSearch.submit();" class="k-button k-primary">Search</button></td>
                <td rowspan="2"><button type="button" onclick="location.href='<%=ParseHtmlPage(Request("URL"))%>?<%=Request("Query_String")%>#pageTop'" id="pageBottom" class="k-button k-primary">Jump To Top</button></td>
            </tr>
            <tr>
                <td class="aa-label">Tax Id:</td>
                <td><div id="combo_zone_taxid"></div></td>
                <td class="aa-label">Account Number:</td>
                <td><div id="combo_zone_lnumber"></div></td>
            </tr>
        </table>
    </div>
</form>
