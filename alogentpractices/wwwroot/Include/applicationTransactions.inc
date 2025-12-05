<%
Function GetUserBySession(session)
	Set usr = New User

	If session("userId") & "" <> "" Then
		usr.Id                              = session("userId")
		usr.Login                           = session("userLogin")
		usr.Name                            = session("userName")
		usr.Email                           = session("userEmail")
		usr.AllowEmailSending               = session("allowEmailSending")
			
		usr.Security						= new UserSecurity
		usr.Security.IsSuperUser            = session("isSuperUser")
		usr.Security.HasEmployeeFileAccess  = CBool(Session("userbanks")(1,2))

		If session("userInactive") = "Y" Then usr.Security.IsInactive = True Else usr.Security.IsInactive = False End If

		usr.Security.AccountSecurityList	= GetUserAccountSecurityListBySession(session)
		usr.Security.PermissionList			= GetPermissionsByUserId(usr.Id)
		Set usr.Security.BranchSecurity		= GetUserBranchSecurityByArray(branchArray)
	End If

	Set GetUserBySession = usr
End Function

Function GetUserAccountSecurityListBySession(session)
	Dim extendedAccountClassList : extendedAccountClassList = Array("credit", "loan", "loanapp", "deposit", "trust")
	Dim accountSecurityList		 : accountSecurityList = Array()
	Dim accountClassCode

	For Each accountClassCode In extendedAccountClassList
		Dim uas : Set uas = new UserAccountSecurity

		With uas
			If session(accountClassCode & ".allowRead") & "" <> "" Then
				.AccountClassCode   = accountClassCode
				.AllowRead          = session(accountClassCode & ".allowRead")
				.AllowEdit          = session(accountClassCode & ".allowEdit")
				.AllowAdd           = session(accountClassCode & ".allowAdd")
				.AllowDelete        = session(accountClassCode & ".allowDelete")
				.AllowDocRead       = session(accountClassCode & ".allowDocRead")
				.AllowDocEdit       = session(accountClassCode & ".allowDocEdit")
				.AllowDocAdd        = session(accountClassCode & ".allowDocAdd")
				.AllowDocDelete     = session(accountClassCode & ".allowDocDelete")
				.AllowDocUpload     = session(accountClassCode & ".allowDocUpload")
				.AllowDocScan       = session(accountClassCode & ".allowDocScan")
				.AllowDocScanDelete = session (accountClassCode & ".allowDocScanDelete")
				.AllowDocMoveCopy   = session(accountClassCode & ".allowDocMoveCopy")
				.IsAdmin            = session(accountClassCode & ".isAdmin")

				ReDim Preserve accountSecurityList(UBound(accountSecurityList) + 1)
				Set accountSecurityList(UBound(accountSecurityList)) = uas
			End If
		End With
	Next

	GetUserAccountSecurityListBySession = accountSecurityList
End Function

Function GetUserBranchSecurityByArray(branchSecurityArray)
	Dim i
	Dim ubs : Set ubs = new UserBranchSecurity

	For i = LBound(branchArray,2) To UBound(branchArray,2)
		ubs.AddBranchAccess branchArray(BRANCH_ID, i), branchArray(BRANCH_HAS_ACCESS, i)
	Next

	Set GetUserBranchSecurityByArray = ubs
End Function

Function GetPermissionsByUserId(userId)
	Dim permissionList	: permissionList   = Array()
	Dim permissionRS	: Set permissionRS = Server.CreateObject("ADODB.RecordSet")
	Dim permissionQuery : permissionQuery  = _
		" SELECT p.*" & _
		" FROM" & _
		"	[user] AS u INNER JOIN [userPermission] AS up" & _
		"		ON u.userId = up.userId" & _
		"	INNER JOIN [Permission] AS p" & _
		"		ON p.permissionId = up.permissionId" & _
		" WHERE u.userId = " & dbFormatId(userId)

	permissionRS.Open permissionQuery, db

	Do While Not permissionRS.EOF
		ReDim Preserve permissionList(UBound(permissionList) + 1)

		Dim permission : Set permission = new UserPermission
		
		permission.Name           = permissionRS("Name")
		permission.Resource       = permissionRS("Resource")
		permission.Description    = permissionRS("Description")
		permission.PermissionType = permissionRS("Type")

		Set permissionList(UBound(permissionList)) = permission

		permissionRS.MoveNext
	Loop

	permissionRS.Close

	GetPermissionsByUserId = permissionList
End Function
%>