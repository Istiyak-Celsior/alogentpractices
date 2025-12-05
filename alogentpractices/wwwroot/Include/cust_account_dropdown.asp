<%
Dim primaryLoanHolderCustomerId : primaryLoanHolderCustomerId = GetCustomerId(selectedLoanId)
Dim nSelectedCustomerNumber : nSelectedCustomerNumber = customerRS("customerNumber")
Dim nSelectedCustomerId : nSelectedCustomerId = selectedCustomerId

IF cStr(nSelectedCustomerId) <> cStr(primaryLoanHolderCustomerId) THEN
    nSelectedCustomerId = primaryLoanHolderCustomerId
    nSelectedCustomerNumber = GetCustomerNumber(nSelectedCustomerId)
END IF

'### Get the primary borrower customerId based on the selected loan
'###
Dim rs1 : SET rs1 = Server.CreateObject("ADODB.RecordSet")
Dim rs1Query : rs1Query = "SELECT customerId FROM loan WHERE loanId = " & dbFormatId(selectedLoanId)
Dim rs1PrimaryBorrowerId : rsPrimaryBorrowerId = ""

rs1.Open rs1Query, db

IF NOT rs1.EOF THEN
    rs1PrimaryBorrowerId = rs1("customerId")
END IF

rs1.Close

scanUrl = "accuimg://accuaccount/barcodescan?customer=" & rs1PrimaryBorrowerId & "&account=" & selectedLoanId

strLoanId = RemoveCurlyBrackets(loanRS("loanId"))
IF isAccuCaptureEnabled THEN
    barcodeUrl = "barcodeselect.asp?loanid=" & LCase(strLoanId)
    h = 300
    w = 300
ELSE
    barcodeUrl = "barcodeselect.asp?loanid=" & LCase(strLoanId) & "&isAccucapture=no"
    h = 300
    w = 300
END IF

Dim accountMenu1 : accountMenu1 = ""
Dim scanModuleTitle : scanModuleTitle = ""

IF  Session("accuaccount.disableImaging") = "0" _
    AND Session("accuaccount.enableExpress") <> 1 _
    AND Session("barcodeScanYN") = "Y" _
    AND IsScanner(selectedAccountClassCode) _
    AND allowLoanBranchAccess THEN
        IF lCase(selectedAccountClassCode) = "loan" THEN
            scanModuleTitle = "Scan Loan Files"
        ELSEIF lCase(selectedAccountClassCode) = "deposit" THEN
            scanModuleTitle = "Scan Deposit Files"
        ELSEIF lCase(selectedAccountClassCode) = "trust" THEN
            scanModuleTitle = "Scan Trust Files"
        END IF
        accountMenu1 = "<a href=""" & scanUrl & """><i class=""aa-icon fas fa-print fa-fw"" aria-hidden=""true""></i>&nbsp;" & scanModuleTitle & "</a>"
END IF

Dim accountMenu2 : accountMenu2 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('', '" & barcodeUrl & "', " & h & ", " & w & ");""><i class=""aa-icon fas fa-barcode fa-fw"" aria-hidden=""true""></i>&nbsp;Print Barcodes</a>"

' ### If the loan is a cross collateral, ensure that the primary collateral id is used
' as that record has the documents associated with it ###
targetLoanId = selectedLoanId
IF loanRS("isCrossCollateralYN") = "Y" THEN targetLoanId = loanRS("primaryCollateralId")

IF  Session("isSuperUser") _
    OR ( _
        (Session(extendedAccountClassCode & ".allowDocEdit") OR Session(extendedAccountClassCode & ".isAdmin")) _
        AND allowLoanBranchAccess _
    ) THEN
    Dim accountMenu4 : accountMenu4 = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Activate Loan Groups', 'custactivategroups.asp?group=loan&customerId=" & customerId & "&loanId=" & targetLoanId & "&accountClassCode=" & extendedAccountClassCode & "', 500, 700);""><i class=""aa-icon far fa-object-group fa-fw"" aria-hidden=""true""></i>&nbsp;Activate Groups</a>"
END IF
%>
<ul id="account-dropdown">
    <li>
        <i class="aa-icon fas fa-bars fa-fw" aria-hidden="true"></i>
        <ul>
            <li><%=accountMenu1%></li>
            <li><%=accountMenu2%></li>
            <% IF TRIM(accountMenu4 & "") <> "" THEN %>
            <li><%=accountMenu4%></li>
            <% END IF %>
        </ul>
    </li>
</ul>