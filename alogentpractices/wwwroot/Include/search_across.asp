<form action="searchgen.asp" name="frmSearch" method="post">
    <input type="hidden" name="searchType" value="Standard">
    <div id="aa-quick-search-title">Quick Search</div>
    <div id="aa-search-panel">
        <table>
            <tr>
                <td class="aa-label">Customer / Business Name:</td>
                <td><input id="combo_zone_cname" name="name" autocomplete="off" style="width:270px" /></td>
                <td class="aa-label">Customer Number:</td>
                <td><input id="combo_zone_cnumber" name="customerID" autocomplete="off" style="width:270px" /></td>
                <td rowspan="2"><button type="submit" onclick="document.frmSearch.submit();" class="k-button k-primary">Search</button></td>
                <td rowspan="2"><button type="button" onclick="location.href='<%=ParseHtmlPage(Request("URL"))%>?<%=Request("Query_String")%>#pageTop'" id="pageBottom" class="k-button k-primary">Jump To Top</button></td>
            </tr>
            <tr>
                <td class="aa-label">Tax Id:</td>
                <td><input id="combo_zone_taxid" name="taxID" autocomplete="off" style="width:270px" /></td>
                <td class="aa-label">Account Number:</td>
                <td><input id="combo_zone_lnumber" name="loan" autocomplete="off" style="width:270px" /></td>
            </tr>
        </table>
    </div>
</form>
