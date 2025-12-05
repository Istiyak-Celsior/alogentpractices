<%
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
	
	Dim userRS, userQuery, userCounter, userRows, userDefault
	Set userRS = Server.CreateObject("ADODB.Recordset")
	userQuery = _
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
		"  		ON u.loanOfficerID = lo.officerID " & _
		" ORDER BY" & _
		"		u.userLastName," & _
		"		u.userFirstName," & _
		"		u.UserMiddleInitial "
		
	userRS.Open userQuery, db, adOpenStatic, adCmdText
	if NOT userRS.eof then
		userArray = userRS.GetRows()
		userRows = Ubound(userArray,2)
	else
		userRows = -1 'No records found.
	end if
	
	userRS.Close
	set userRS = Nothing
	
	
	' Helper function to return the UserName based on a userId
	'
	Function GetUserNameById(uid, default)
		Dim result, userIdx
		result = default
		
		for userIdx = 0 to userRows
			if CStr(uid) = CStr(userArray( USER_ID, userIdx)) then
				result = userArray( USER_FIRST_NAME, userIdx) & " " & userArray(USER_LAST_NAME, userIdx)
				exit for
			end if
		next 'userIdx
		
		GetUserNameById = result
	End Function ' GetUserNameById()
%>