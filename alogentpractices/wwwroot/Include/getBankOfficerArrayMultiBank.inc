<%
' Developer Notes:
'		The getBankOfficerArrayMultiBank.inc is a 2-dimensional array of loanOfficers from the [loanOfficer] table. 
'		The first index refers to the data column and the second index refers to the data.
'
'		The data columns are indexed with the following values:
'			0 = officerId
'			1 = officerName
'			2 = officerCode
'			3 = bankId
'			4 = officerTitle
'			5 = defaultOfficer

CONST BO_OFFICERID = 0
CONST BO_OFFICERNAME = 1
CONST BO_OFFICERCODE = 2
CONST BO_BANKID = 3
CONST BO_OFFICERTITLE = 4
CONST BO_DEFAULTOFFICER = 5

Dim bankOfficerRS, bankOfficerQuery, bankOfficerArray, bankOfficerRows
Set bankOfficerRS = Server.CreateObject("ADODB.Recordset")

bankOfficerQuery = _
	"SELECT" & _
	"     bo.officerId," & _
	"	  bo.officerName," & _
	"	  bo.officerCode," & _
	"	  bo.bankId," & _
	"     bo.officerTitle," & _
	"     bo.defaultOfficer" & _
	" FROM " & _
	"	  loanOfficer AS bo" & _
	" WHERE (bankId IN " & _
    "     (SELECT bankId" & _
    "       FROM userbanksecurity" & _
    "       WHERE (bankId = bo.bankId) AND (userId = " & dbFormatId(Session("userId")) & " AND (bankaccess = 1))))" & _
	" ORDER BY bo.officerName"

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