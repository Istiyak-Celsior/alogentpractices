<%
IF action = "CLEAR" THEN
    Session("searchName")=""
    Session("searchCustomerNumber")=""
    Session("searchTaxId")=""
    Session("searchLoan")=""
    Session("searchLoanType")="0"
    Session("searchLoanOfficer")="0"
    Session("searchBranch")="0"
    Session("searchBankId")="0"
    Session("searchCustomerType")="0"
END IF

IF Len(Trim(Session("searchBankId"))) = 0 THEN
    Session("searchBankId") = 0
END IF

IF Len(Trim(Session("searchCustomerType"))) = 0 THEN
    Session("searchCustomerType") = 0
END IF

Dim bank : Set bank = Server.CreateObject("ADODB.Recordset")
Dim bankQuery : bankQuery = "SELECT * FROM bank ORDER by bankName"
bank.Open bankQuery, db, adOpenForwardOnly, adLockReadOnly

Dim lo : Set lo = Server.CreateObject("ADODB.Recordset")
Dim loQuery : loQuery = "SELECT * FROM loanOfficer ORDER by officerName"
lo.Open loQuery, db, adOpenForwardOnly, adLockReadOnly

Dim loanType : Set loanType = Server.CreateObject("ADODB.Recordset")
Dim loanTypeQuery : loanTypeQuery = "SELECT * FROM loanType ORDER by loanTypeDescription"
loanType.Open loanTypeQuery, db, adOpenForwardOnly, adLockReadOnly

Dim customerType : Set customerType = Server.CreateObject("ADODB.Recordset")
Dim customerTypeQuery : customerTypeQuery = "SELECT * FROM customerType ORDER by customerTypeDescription"
customerType.Open customerTypeQuery, db, adOpenForwardOnly, adLockReadOnly
%>