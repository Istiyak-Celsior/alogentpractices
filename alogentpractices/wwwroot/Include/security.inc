<%
	' If inactive user redirect to error page
	'
	if Session("userInactive") = "Y" then
		Session("userName") = ""
		Session("userID") = ""
		Response.Redirect "default.asp?error=3"
	end if
	
	if Not Session("userLoggedIn") then
		Dim loginErrorArgs : loginErrorArgs = ""

        ' only pass error argument if windows authentication is off. 
        ' Necessary due to users bookmarking pages other than the default
        ' when autologin is enabled.
        If Session("enableWindowsSecurityYN") = "N" Then
			loginErrorArgs = "?error=2"
		End If

		Response.redirect ("default.asp" & loginErrorArgs)
	end if
%>



<%
	' Flags for the various levels of Record and Document Security
	'
	CONST REC_READ = "allowRead"
	CONST REC_EDIT = "allowEdit"
	CONST REC_ADD = "allowAdd"
	CONST REC_DELETE = "allowDelete"
	CONST DOC_READ = "allowDocRead"
	CONST DOC_EDIT = "allowDocEdit"
	CONST DOC_ADD = "allowDocAdd"
	CONST DOC_DELETE = "allowDocDelete"
	CONST DOC_SCAN = "allowDocScan"
	CONST DOC_SCAN_DELETE = "allowDocScanDelete"
	CONST DOC_UPLOAD = "allowDocUpload"
	CONST DOC_MOVECOPY = "allowDocMoveCopy"
	CONST IS_ADMIN = "isAdmin"
	
	' This is used for bitwise checks of security
	' and should be used over the above flags when possible
	'
	CONST SEC_NONE				= 0
	CONST SEC_READ				= 1		'2^0
	CONST SEC_EDIT				= 2		'2^1
	CONST SEC_ADD				= 4		'2^2
	CONST SEC_DELETE			= 8		'2^3
	CONST SEC_DOC_READ			= 16	'2^4
	CONST SEC_DOC_EDIT			= 32	'2^5
	CONST SEC_DOC_ADD			= 64	'2^6
	CONST SEC_DOC_DELETE		= 128	'2^7
	CONST SEC_DOC_SCAN			= 256	'2^8
	CONST SEC_DOC_SCAN_DELETE	= 512	'2^9
	CONST SEC_DOC_UPLOAD		= 1024	'2^10
	CONST SEC_DOC_MOVECOPY		= 2048	'2^11
	CONST SEC_ADMIN				= 4096	'2^12
	
	Function CheckRecordSecurity(typeCode, recordLevel)
		Dim statusCheck
		statusCheck = Session(typeCode & "."  & recordLevel)
		
		if statusCheck = "" then
			statusCheck = false
		end if
		
		' Always take into account Admin and SuperUser access for Records.
		'
		CheckRecordSecurity = (statusCheck Or Session(typeCode & ".isAdmin") Or Session("isSuperUser"))
	End Function 'CheckRecordSecurity()
	
	Function CheckDocumentSecurity(typeCode, documentLevel)
		Dim statusCheck
		statusCheck = Session(typeCode & "."  & documentLevel)
		
		if statusCheck = "" then
			statusCheck = false
		end if
		
		' Use the better of the individual status or the admin flag
		'
		if	documentLevel = DOC_READ _
			Or documentLevel = DOC_EDIT _
			Or documentLevel = DOC_ADD _
			Or documentLevel = DOC_DELETE then
			statusCheck = (statusCheck Or Session(typeCode & ".isAdmin"))
		end if
		
		' Account for SuperUser access
		'
		CheckDocumentSecurity = (statusCheck Or Session("isSuperUser"))
	End Function 'CheckDocumentSecurity()
	
	Function IsAdministrator()
		Dim result
		result = _
			Session("credit.isAdmin") _
			Or Session("loan.isAdmin") _
			Or Session("loanapp.isAdmin") _
			Or Session("deposit.isAdmin") _
			Or Session("trust.isAdmin") _
			Or Session("isSuperUser")
		IsAdministrator = CBool(result)
	End Function 'IsAdministrator()
	
	Function IsAccountAdministrator()
		Dim result
		result = _
			Session("loan.isAdmin") _
			Or Session("loanapp.isAdmin") _
			Or Session("deposit.isAdmin") _
			Or Session("trust.isAdmin") _
			Or Session("isSuperUser")
		IsAccountAdministrator = CBool(result)
	End Function 'IsAccountAdministrator()
	
	Function IsReader()
		Dim result
		result = _
			Session("credit.allowRead") _
			Or Session("loan.allowRead") _
			Or Session("loanapp.allowRead") _
			Or Session("deposit.allowRead") _
			Or Session("trust.allowRead") _
			Or Session("isSuperUser")
		IsReader = CBool(result)
	End Function 'IsReader()
	
	Function IsAccountReader()
		Dim result
		result = _
			Session("loan.allowRead") _
			Or Session("loanapp.allowRead") _
			Or Session("deposit.allowRead") _
			Or Session("trust.allowRead") _
			Or Session("isSuperUser")
		IsAccountReader = CBool(result)
	End Function 'IsAccountReader()
	
	Function IsEditor()
		Dim result
		result = _
			Session("credit.allowEdit") _
			Or Session("loan.allowEdit") _
			Or Session("loanapp.allowEdit") _
			Or Session("deposit.allowEdit") _
			Or Session("trust.allowEdit") _
			Or Session("isSuperUser")
		IsEditor = CBool(result)
	End Function 'IsEditor()
	
	Function IsAccountEditor()
		Dim result
		result = _
			Session("loan.allowEdit") _
			Or Session("loanapp.allowEdit") _
			Or Session("deposit.allowEdit") _
			Or Session("trust.allowEdit") _
			Or Session("isSuperUser")
		IsAccountEditor = CBool(result)
	End Function 'IsAccountEditor()
	
	Function IsCreator()
		Dim result
		result = _
			Session("credit.allowAdd") _
			Or Session("loan.allowAdd") _
			Or Session("loanapp.allowAdd") _
			Or Session("deposit.allowAdd") _
			Or Session("trust.allowAdd") _
			Or Session("isSuperUser")
		IsCreator = CBool(result)
	End Function 'IsCreator()
	
	Function IsAccountCreator()
		Dim result
		result = _
			Session("loan.allowAdd") _
			Or Session("loanapp.allowAdd") _
			Or Session("deposit.allowAdd") _
			Or Session("trust.allowAdd") _
			Or Session("isSuperUser")
		IsAccountCreator = CBool(result)
	End Function 'IsAccountCreator()
	
	Function IsDestroyer()
		Dim result
		result = _
			Session("credit.allowDelete") _
			Or Session("loan.allowDelete") _
			Or Session("loanapp.allowDelete") _
			Or Session("deposit.allowDelete") _
			Or Session("trust.allowDelete") _
			Or Session("isSuperUser")
		IsDestroyer = CBool(result)
	End Function 'IsDestroyer()
	
	Function IsAccountDestroyer()
		Dim result
		result = _
			Session("loan.allowDelete") _
			Or Session("loanapp.allowDelete") _
			Or Session("deposit.allowDelete") _
			Or Session("trust.allowDelete") _
			Or Session("isSuperUser")
		IsAccountDestroyer = CBool(result)
	End Function 'IsAccountDestroyer()
	
	Function CheckExceptionSecurity( minLevel)
		' Check for minimum security levels
		'	userSecurity Admin+ always checks out, otherwise check the permissionException level
		'	for minimum level of security
		'
		if Session("permissionException") < minLevel then
			Response.Redirect "error.asp?error=1"
		end if
	End Function
	
	Function IsScanner(extendedAccountClassCode)
		Dim result
		result = _
			(Session(extendedAccountClassCode & ".allowDocScan") AND Session(extendedAccountClassCode & ".allowDocAdd")) _
			OR Session("isSuperUser")
		
		IsScanner = CBool(result)
	End Function 'IsScanner()
%>