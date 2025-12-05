<%
' MASTER Developer Notes:  - Multibank Implementation
'		When using this code you must ensure that do not use the following includes in your code.
'			a) include/getUserBankSecurityArray.inc
'			b) include/getUserArray.inc
'
' 		Both of these includes are included within this include for MultiBank processing
'
' Developer Notes:
'		The getUserBankSecurityArray.inc is a 2-dimensional array of bank/user security info from the [userbanksecurity] table. 
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

	' Developer Notes:
	'		The userArray is a 2-dimensional array of users from the user table. The first
	'		index refers to the data column and the second index refers to the customer
	'		record.
	'
	'		The data columns are indexed with the following values:
	'			0 = userID
	'			1 = userLogin
	'			2 = userPassword
	'			3 = userFirstName
	'			4 = userLastName
	'			5 = userMiddleInitial
	'			6 = isSuperUser
	'			7 = userEmail
	'			8 = userNotes
	'			9 = officerName
	'			10 = permissionException
	'			11 = isApprover
	'			12 = isAnalyst
	'			13 = isLender
	'			14 = loanApprovalAmount		NOTE: This is the user default limit now - MikeF
	'			15 = isLoanProcessor
	'			16 = inactive
	
	CONST USER_ID = 0
	CONST USER_LOGIN = 1
	CONST USER_PASSWORD = 2
	CONST USER_FIRST_NAME = 3
	CONST USER_LAST_NAME = 4
	CONST USER_MIDDLE_INITIAL = 5
	CONST USER_SUPER_USER = 6
	CONST USER_EMAIL = 7
	CONST USER_NOTES = 8
	CONST USER_OFFICER_NAME = 9
	CONST USER_PERMISSION_EXCEPTION = 10
	CONST USER_IS_APPROVER = 11
	CONST USER_IS_ANALYST = 12
	CONST USER_IS_LENDER = 13
	CONST USER_APPROVAL_LIMIT = 14
	CONST USER_IS_LOAN_PROCESSOR = 15
	CONST USER_INACTIVE = 16

	'* Build the list of banks that belong the current logged in User
	'*
	theWhereLoop = 0
	whereClause = ""
	For x = 0 to userBankSecurityRows
		if userBankSecurityArray(2,x) = 1 then '* Bank Access is Allowed
		  if theWhereLoop > 0 then 
			  whereClause = whereClause & " OR "
		  end if
		  whereClause = whereClause & "ubs.bankId = " & dbFormatId(userBankSecurityArray(0,x))
		  theWhereLoop = theWhereLoop + 1
		end if
	next

	Dim userDataListRS, userDataListQuery, userDataListCounter, userDataListRows, userDataListDefault
	Set userDataListRS = Server.CreateObject("ADODB.Recordset")

	userDataListQuery = _
		"	SELECT" & _
		"		u.userID," & _
		"		u.userLogin," & _
		"		u.userPassword," & _
		"		u.userFirstName," & _
		"		u.userLastName," & _
		"		u.userMiddleInitial," & _
		"		u.isSuperUser," & _
		"		u.userEmail," & _
		"		u.userNotes," & _
		"		lo.officerName," & _
		"		u.permissionException," & _
		"		u.isApprover," & _
		"		u.isAnalyst," & _
		"		u.isLender," & _
		"		u.loanApprovalLimit," & _
		"		u.isLoanProcessor," & _
		"       u.inactive" & _
		" FROM" & _
		"		[user] AS u LEFT OUTER JOIN loanOfficer AS lo" & _
		"  		ON u.loanOfficerID = lo.officerID "
    IF Trim(whereClause & "") <> "" THEN
		userDataListQuery = userDataListQuery & " WHERE (u.userId IN" & _
		"	(SELECT u.userId" & _
		"      FROM [user] AS u LEFT OUTER JOIN" & _
		"          userbanksecurity AS ubs ON u.userId = ubs.userId AND ubs.bankaccess = 1 AND (" & _
		whereClause & _	
		" )))"
    END IF
    userDataListQuery = userDataListQuery & " ORDER BY" & _
		"		u.userLastName," & _
		"		u.userFirstName," & _
		"		u.UserMiddleInitial "
	userDataListRS.Open userDataListQuery, db, adOpenStatic, adCmdText

	if NOT userDataListRS.eof then
		userDataListArray = userDataListRS.GetRows()
		userDataListRows = Ubound(userDataListArray,2)
	else
		userDataListRows = -1 'No records found.
	end if
	
	' Helper function to return the UserName based on a userId
	'
	Function GetUserNameById(uid, default)
		Dim result, userIdx
		result = default
		
		for userIdx = 0 to userDataListRows
			if CStr(uid) = CStr(userDataListArray( USER_ID, userIdx)) then
				result = userDataListArray( USER_FIRST_NAME, userIdx) & " " & userDataListArray(USER_LAST_NAME, userIdx)
				exit for
			end if
		next 'userIdx
		
		GetUserNameById = result
	End Function ' GetUserNameById()

userDataListRS.Close
set userDataListRS = Nothing
userBankSecurityRS.Close
set userBankSecurityRS = Nothing
%>

<%
	Function GetSingletonBank()
		Dim bankId, i, bankAccessCount
		bankId = ""
		bankAccessCount = 0
		
		for i = 0 to userBankSecurityRows
			if	Session("isSuperUser") _
				Or CStr(userBankSecurityArray(UBS_USERID, i) = CStr(Session("userId")) _
					And CBool(userBankSecurityArray(UBS_BANKACCESS, i))  _
				) _
				then
				bankId = userBankSecurityArray(UBS_BANKID, i)
				bankAccessCount = bankAccessCount + 1
			end if
		next 'i
		
		if bankAccessCount <> 1 then
			bankId = ""
		end if
		
		GetSingletonBank = bankId
	End Function
	
	Function HasMultiBankAccess()
		Dim result : result = false
		
		Dim i, bankAccessCount
		bankAccessCount = 0
		for i = 0 to userBankSecurityRows
			if	Session("isSuperUser") _
				Or CStr(userBankSecurityArray(UBS_USERID, i) = CStr(Session("userId")) _
					And CBool(userBankSecurityArray(UBS_BANKACCESS, i))  _
				) _
				then
				bankAccessCount = bankAccessCount + 1
			end if
		next 'i
		
		if bankAccessCount > 1 then
			result = true
		end if
		
		HasMultiBankAccess = result
	End Function ' HasHultiBankAccess()
	
%>