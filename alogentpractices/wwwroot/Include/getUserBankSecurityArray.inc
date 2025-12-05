<%
' Developer Notes:
'		The getBankArray is a 2-dimensional array of bank/branch/user security info from the [userbanksecurity] table. 
'		The first index refers to the data column and the second index refers to the data.
'
'		The data columns are indexed with the following values:
'			0 = bankId
'			1 = userId
'			2 = bankaccess
'			3 = employeefiles
'			4 = bankSecurityId

CONST UBS_BANKID = 0
CONST UBS_USERID = 1
CONST UBS_BANKACCESS = 2
CONST UBS_EMPLOYEEFILES = 3
CONST UBS_BANKSECURITY = 4

Dim userBankSecurityRS, userBankSecurityQuery, userBankSecurityArray, userBankSecurityRows
Set userBankSecurityRS = Server.CreateObject("ADODB.Recordset")

if Request("userid") = "" then
	userBankSecurityQuery = _
		" SELECT" & _
		"		ubs.bankId," & _
		"		ubs.userId," & _
		"		ubs.bankaccess," & _
		"		ubs.employeefiles," & _
		"		ubs.bankSecurityId" & _
		" FROM" & _
		"		[userbanksecurity] AS ubs " & _
		" WHERE" & _
		"		(userId IN (SELECT userId FROM [user] WHERE (userLogin = '" & Session("userLogin") & "')))"
else  'This else means that the processing is coming from the Admin / User Maintenance processing
	userBankSecurityQuery = _
		" SELECT" & _
		"		ubs.bankId," & _
		"		ubs.userId," & _
		"		ubs.bankaccess," & _
		"		ubs.employeefiles," & _
		"		ubs.bankSecurityId" & _		
		" FROM" & _
		"		[userbanksecurity] AS ubs " & _
		" WHERE (userId = " & dbFormatId(Request("userid")) & ")"
end if

userBankSecurityRS.Open userBankSecurityQuery, db, adOpenStatic

if NOT userBankSecurityRS.eof then
	userBankSecurityArray = userBankSecurityRS.GetRows()
	userBankSecurityRows = Ubound(userBankSecurityArray,2)
else
	userBankSecurityRows = -1 'No records found.
end if

userBankSecurityRS.Close
set userBankSecurityRS = Nothing
%>

<%
	Function HasBankAccess(bankId)
		Dim result
		result = false
		
		Dim i
		for i = 0 to userBankSecurityRows
			if	Session("isSuperUser") _
				Or (userBankSecurityArray(UBS_BANKID, i) = bankId _
					And userBankSecurityArray(UBS_USERID, i) = Session("userId") _
				) _
				then
				result = true
				exit for
			end if
		next 'i
		
		HasBankAccess = result
	End Function 'HasBankAccess()
	
	Function HasEmployeeFileAccess(bankId)
		Dim result
		result = false
		
		Dim i
		for i = 0 to userBankSecurityRows
			if 	Session("isSuperUser") _
				Or (userBankSecurityArray(UBS_BANKID, i) = bankId _
				And userBankSecurityArray(UBS_USERID, i) = Session("userId") _
				And userBankSecurityArray(UBS_EMPLOYEEFILES, i) = 1 _
				) _
				then
				result = true
				exit for
			end if
		next 'i
		
		HasEmployeeFileAccess = result
	End Function 'HasEmployeeFileAccess()
%>