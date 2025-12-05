<%
strCustomerId = RemoveCurlyBrackets(selectedCustomerId)

scanUrl = "accuimg://accuaccount/barcodescan?customer=" & selectedCustomerId

IF isAccuCaptureEnabled THEN
    barcodeUrl = "barcodeselect.asp?custid=" & LCase(strCustomerId)
    h = 300
    w = 300
ELSE
    barcodeUrl = "barcodeselect.asp?custid=" & LCase(strCustomerId) & "&isAccucapture=no"
    h = 300
    w = 300
END IF

Dim creditMenu1 : creditMenu1 = ""
IF  Session("accuaccount.disableImaging") = "0" _
    AND Session("accuaccount.enableExpress") <> 1 _
    AND Session("barcodeScanYN") = "Y" _
    AND IsScanner("credit") THEN
        creditMenu1 = "<a href=""" & scanUrl & """ ><i class=""aa-icon fas fa-print fa-fw"" aria-hidden=""true""></i>&nbsp;Scan Credit Files</a>"
END IF

Dim creditMenu2 : creditMenu2 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Tab Action', '" & barcodeUrl & "', " & h & ", " & w & ");""><i class=""aa-icon fas fa-barcode fa-fw"" aria-hidden=""true""></i>&nbsp;Print Barcodes</a>"
Dim creditMenu3 : creditMenu3 = "<a href=""javascript:void(0);"" onclick=""openPopup('checklistLoanDocumentMaintenance.asp?customerNumber=" & lCase(strCustomerId) & "','500','600');""><i class=""aa-icon fas fa-th-list fa-fw"" aria-hidden=""true""></i>&nbsp;View Document Checklist</a>"

IF Session("isSuperUser") OR (Session("credit.isAdmin") AND allowCustomerBranchAccess) OR (Session("credit.allowAdd") AND allowCustomerBranchAccess) OR (Session("credit.allowEdit") AND allowCustomerBranchAccess) THEN
    Dim creditMenu4 : creditMenu4 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Copy Credit Documents', formatURL('copycreditdocuments.asp','srcCustID','" & customerID & "'), 330, 600);""><i class=""aa-icon far fa-copy fa-fw"" aria-hidden=""true""></i>&nbsp;Copy Credit Documents</a>"
END IF

IF  Session("isSuperUser") _
    OR ( _
        (Session("credit.isAdmin") OR Session("credit.allowDocEdit")) _
        AND allowCustomerBranchAccess _
    ) THEN
        Dim creditMenu6 : creditMenu6 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Activate Credit Groups', 'custactivategroups.asp?group=credit&customerId=" & selectedCustomerId & "&accountClassCode=credit', 500, 700);""><i class=""aa-icon far fa-object-group fa-fw"" aria-hidden=""true""></i>&nbsp;Activate Groups</a>"
END IF
%>
<ul id="credit-dropdown">
    <li>
        <i class="aa-icon fas fa-bars fa-fw" aria-hidden="true"></i>
        <ul>
            <li><%=creditMenu1%></li>
            <li><%=creditMenu2%></li>
            <li><%=creditMenu3%></li>
            <% IF TRIM(creditMenu4 & "") <> "" THEN %>
            <li><%=creditMenu4%></li>
            <% END IF %>
            <% IF TRIM(creditMenu6 & "") <> "" THEN %>
            <li><%=creditMenu6%></li>
            <% END IF %>
        </ul>
    </li>
</ul>