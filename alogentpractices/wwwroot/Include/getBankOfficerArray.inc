<%
Dim bankOfficerRS, bankOfficerQuery, bankOfficerArray, bankOfficerRows
Set bankOfficerRS = Server.CreateObject("ADODB.Recordset")

CONST OFFICER_ID = 0
CONST OFFICER_NAME = 1
CONST OFFICER_CODE = 2
CONST OFFICER_BANKID = 3
CONST OFFICER_TITLE = 4
CONST OFFICER_DEFAULT = 5

bankOfficerQuery = _
	" SELECT" & _
	"		bo.officerId," & _
	"		bo.officerName," & _
	"		bo.officerCode," & _
	"		bo.bankId," & _
	"		bo.officerTitle," & _
	"		bo.defaultOfficer" & _
	" FROM" & _
	"		[loanOfficer] AS bo " & _
	" ORDER BY bankId" 

bankOfficerRS.Open bankOfficerQuery, db, adOpenStatic

if NOT bankOfficerRS.eof then
	bankOfficerArray = bankOfficerRS.GetRows()
	bankOfficerRows = Ubound(bankOfficerArray,2)
else
	bankOfficerRows = -1 'No records found.
end if

bankOfficerRS.Close
set bankOfficerRS = Nothing
%>