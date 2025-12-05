<%  

scanUrl = "accuimg://accuaccount/barcodescan?customer=" & targetCustomerId & "&account=" & targetParentLoanId & "&collateral=" & targetCollateralSequence

strCollId = RemoveCurlyBrackets(targetCollateralLoanId)
strLId = RemoveCurlyBrackets(selectedCollateralId)

IF cStr(strCollId) <> cStr(strLId) THEN
    barcodeUrl = "barcodeselect.asp?collid=" & lCase(strCollId)
ELSE
    barcodeUrl = "barcodeselect.asp?collid=" & lCase(strLId)
END IF

IF NOT isAccuCaptureEnabled THEN barcodeUrl = barcodeUrl & "&isAccucapture=no"

h = 300 : w = 300

IF NOT employeeViewer AND cBool(CustomerRS("employee")) THEN
    empAccessAllowed = False
END IF

Dim collateralMenu1 : collateralMenu1 = ""

IF  Session("accuaccount.disableImaging") = "0" _
    AND Session("accuaccount.enableExpress") <> 1 _
    AND Session("barcodeScanYN") = "Y" _
    AND IsScanner(extendedAccountClassCode) _
    AND allowLoanBranchAccess THEN
        collateralMenu1 = "<a href=""" & scanUrl & """><i class=""aa-icon fas fa-print fa-fw"" aria-hidden=""true""></i>&nbsp;Scan Collateral Files</a>"
END IF

Dim collateralMenu2 : collateralMenu2 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Print Barcodes', '" & barcodeUrl & "', " & h & ", " & w & ");""><i class=""aa-icon fas fa-barcode fa-fw"" aria-hidden=""true""></i>&nbsp;Print Barcodes</a>"

IF  Session("isSuperUser") _
    OR ( _
        (Session(extendedAccountClassCode & ".allowDocEdit") OR Session(extendedAccountClassCode & ".isAdmin")) _
        AND allowLoanBranchAccess _
    ) THEN
    Dim collateralMenu4 : collateralMenu4 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Activate Collateral Groups', 'custactivategroups.asp?group=loan&customerId=" & targetCustomerId & "&loanId=" & targetCollateralLoanId & "&accountClassCode=" & extendedAccountClassCode & "', 500, 700);""><i class=""aa-icon far fa-object-group fa-fw"" aria-hidden=""true""></i>&nbsp;Activate Groups</a>"
END IF
%>
<ul id="collateral-dropdown">
    <li>
        <i class="aa-icon fas fa-bars fa-fw" aria-hidden="true"></i>
        <ul>
            <li><%=collateralMenu1%></li>
            <li><%=collateralMenu2%></li>
            <% IF TRIM(collateralMenu4 & "") <> "" THEN %>
            <li><%=collateralMenu4%></li>
            <% END IF %>
        </ul>
    </li>
</ul>