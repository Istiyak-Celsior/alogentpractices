<%
	Sub UserLogin(sqlUserQuery)
	    dim userbank(20,2)
	    
        dim userRS
		Set userRS = Server.CreateObject("ADODB.Recordset")
		
        userRS.Open sqlUserQuery, db, adOpenStatic

		if Session("enableWindowsSecurityYN") = "N" And Request("PASSWORD") = "" then
			Response.Redirect "default.asp?error=1"
		end if
        
		if userRS.Recordcount <> 1 then
          Response.Redirect "default.asp?error=1"
        else
			if userRS("inactive") = "Y" then
				Session("userInactive") = "Y"
				Response.Redirect "default.asp?error=4"
			end if
			
			Session("userLoggedIn") = true
			session("userLogin") = userRS("userLogin")
			session("userPassword") = password
			session("userID") = userRS("userID")
			session("userName") = ProcDocHistUsername(userRS("userID"))
			Session("userEmail") = userRS("userEmail")
			Session("userInactive") = checkfornull(userRS("inactive"))
			Session("userOfficerId") = CheckForNull(userRS("loanOfficerId"))
			Session("isSuperUser") = userRS("isSuperUser")
			Session("allowEmailSending") = userRS("allowEmailSending")
			Session("CustomerListPref") = userRS("custViewPref")
			Session("enableCollapsibleDocuments") = userRS("enableCollapsibleDocuments")
			Session("enableCollapsibleGroups") = userRS("enableCollapsibleGroups")
			Session("allowPurgeModifications") = userRS("allowPurgeModifications")

			if IsNull(userRS("permissionException")) then
				session("permissionException") = 1
			else
				session("permissionException") = CInt(userRS("permissionException"))
			end if
			
			 ' Get underwriting flags
			 '
			if Session("enableLoanApprovalsYN") = "Y" then
				Session("isAnalyst") = userRS("isAnalyst")
				Session("isApprover") = userRS("isApprover")
				Session("isLender") = userRS("isLender")
				Session("isDelegate") = userRS("isLoanProcessor")
				Session("defaultApprovalLimit") = userRS("loanApprovalLimit")
			end if
			
			' Load account access settings
			'	Session key: {accountClassCode}.allowUserAccess = {true|false}
			'
			Dim accountQuery, accountRS
			Set accountRS = Server.CreateObject("ADODB.RecordSet")
			
			accountQuery = _
				" SELECT" & _
				"	uas.*" & _
				" FROM" & _
				"	viewExtendedAccountClass AS ac LEFT OUTER JOIN userAccountSecurity AS uas" & _
				"		ON ac.accountClassCode=uas.accountClassCode" & _
				"		AND uas.userId=" & dbFormatId(Session("userId"))
			accountRS.Open accountQuery, db, adOpenStatic, adCmdText

			Dim hasAccess : hasAccess = False
			do until accountRS.eof
				IF accountRS("allowRead") OR accountRS("isAdmin") OR Session("isSuperUser") THEN
					hasAccess = True
				END IF

				Session(accountRS("accountClassCode") & ".allowRead") = accountRS("allowRead")
				Session(accountRS("accountClassCode") & ".allowEdit") = accountRS("allowEdit")
				Session(accountRS("accountClassCode") & ".allowAdd") = accountRS("allowAdd")
				Session(accountRS("accountClassCode") & ".allowDelete") = accountRS("allowDelete")
				Session(accountRS("accountClassCode") & ".allowDocRead") = accountRS("allowDocRead")
				Session(accountRS("accountClassCode") & ".allowDocEdit") = accountRS("allowDocEdit")
				Session(accountRS("accountClassCode") & ".allowDocAdd") = accountRS("allowDocAdd")
				Session(accountRS("accountClassCode") & ".allowDocDelete") = accountRS("allowDocDelete")
				Session(accountRS("accountClassCode") & ".allowDocScan") = accountRS("allowDocScan")
				Session(accountRS("accountClassCode") & ".allowDocScanDelete") = accountRS("allowDocScanDelete")
				Session(accountRS("accountClassCode") & ".allowDocUpload") = accountRS("allowDocUpload")
				Session(accountRS("accountClassCode") & ".allowDocMoveCopy") = accountRS("allowDocMoveCopy")
				Session(accountRS("accountClassCode") & ".isAdmin") = accountRS("isAdmin")
				
				accountRS.MoveNext
			loop
			accountRS.Close

			IF NOT hasAccess THEN
				Response.Clear()
				Session("userLoggedIn") = false
				Response.redirect "default.asp?error=6"
			END IF
			
			' Load bank/branch security settings
			'
			dim USRS, USQuery, USlen
			set USRS = Server.CreateObject("ADODB.Recordset")
			USQuery = "SELECT * FROM [userbanksecurity] where userID=" & dbFormatId(userRS("userID")) & " and bankaccess=1"
			USRS.Open USQuery, db, adOpenStatic
    
            USlen = 0
            IF USRS.EOF THEN
				USRS.Close
                Session("userLoggedIn") = false
                Response.Redirect "default.asp?error=3"
            ELSE
			    USlen = USRS.Recordcount
			    Session("multiBank") = False

                IF USlen > 1 THEN
                    Session("multiBank") = True
                END IF

				Dim i : i = 0
				do until USRS.eof
					Dim employeeAccess : employeeAccess = USRS("employeeFiles")
					IF Session("isSuperUser") THEN employeeAccess = 1

					i = i + 1
					userbank(i,1) = USRS("bankid")
					userbank(i,2) = employeeAccess

					USRS.MoveNext
				loop
				
				session("userbanks") = userbank
				USRS.Close
            END IF

			Session("userbanklen") = USlen
			maxbanks = 1
			Response.buffer = True
			Response.Cookies("AccuSystemUserLogin") = userid
			
			' see if branch security is enabled
			'  ----------- SETUP -----------------------------------------------------------------------------------
			Dim cnnStoredProc ' Connection object
			Dim cmdStoredProc ' Command object
			Dim rstStoredProc ' Recordset object (for part 2)
			Set cnnStoredProc = Server.CreateObject("ADODB.Connection")
			cnnStoredProc.Open  Session("strconn")	
			Set cmdStoredProc = Server.CreateObject("ADODB.Command")  ' Create Command object we'll use to execute the SP
			cmdStoredProc.ActiveConnection = cnnStoredProc  ' Set our Command to use our existing connection
			cmdStoredProc.CommandText = "accusystemPropertiesOperations"  ' Set the SP's name and tell the Command object
			cmdStoredProc.CommandType = adCmdStoredProc
			cmdStoredProc.Parameters.Refresh
			
			'  ---------- SET PARAMETERS ----LIST ALL RECORD--------------------------------------------------------------------
			cmdStoredProc.Parameters("@functionCode").Value = "G"  'the property from a accusystem Property variable
			cmdStoredProc.Parameters("@propertyName").Value = "BRANCHSECURITYLEVEL"   'userID
			set rstStoredProc = cmdStoredProc.Execute   ' Run the SP by executing the command. 
			
			'This set the condition for the check of Bank Security to be a binary condition
			isFullBranchSecurity = False
			
			if (Session("UseBranchSecurity") = "Y") AND (NOT rstStoredProc.eof) then
				if trim(rstStoredProc("propertyValue")) <> "" then
					session("bankSecurity") = trim(rstStoredProc("propertyValue"))
					if session("bankSecurity") = "DU" then
						isFullBranchSecurity = True
					end if
				else
					session("bankSecurity") = "XX"
				end if
			else
				session("bankSecurity") = "XX"
			end if
            ' ### Assign isFullBranchSecurity to Session ###
            Session("isFullBranchSecurity") = isFullBranchSecurity


			'### Get User Permission settings to store in session
			'
			Dim permissionRS  : Set permissionRS = Server.CreateObject("ADODB.RecordSet")
			Dim permissionCmd : Set permissionCmd = Server.CreateObject("ADODB.Command")
			Dim permissionQuery : permissionQuery = _
				" SELECT" & _
				"	p.Resource," & _
				"	p.Name," & _
				"	p.Type" & _
				" FROM" & _
				"	UserPermission AS up LEFT OUTER JOIN Permission AS p" & _
				"		ON up.PermissionId = p.PermissionId" & _
				" WHERE up.userId = ?"
			permissionCmd.ActiveConnection = db
			permissionCmd.CommandType      = adCmdText
			permissionCmd.CommandText      = permissionQuery

			permissionCmd.Parameters.Append(permissionCmd.CreateParameter("?", adGUID, adParamInput))
			permissionCmd.Parameters("?").Value = session("userID")
			
			Set permissionRS = permissionCmd.Execute

			IF NOT permissionRS.EOF Then
				Do UNTIL permissionRS.EOF
					Dim key : key = permissionRS("Resource") & "::" & permissionRS("Name")
					Session(key) = permissionRS("Type")
					permissionRS.MoveNext
				Loop
			END IF
			
			permissionRS.Close

'			if NOT rstStoredProc.eof then
'				if trim(rstStoredProc("propertyValue")) <> "XX" then  
'					session("bankSecurity") = trim(rstStoredProc("propertyValue"))
'				else  ' bank security is disables
'					session("bankSecurity") = "N"
'				end if    
'			else  ' branch security has never be set, so disable it
'	               session("bankSecurity") = "N"
'			end if
			
			' Get the user's current upload directory, if it doesn't exist
			' create it.
			'
			Dim path : path = GetCurrentUploadDirectory("")
			SetCurrentUploadDirectory(path)
			Call BuildFolderPath(Session("serverPath"), path)

		end if ' userRS.RecordCount <> 1
	End Sub 'UserLogin()

    Function GetWindowsUserName()
        Dim userDomainLogin, userLogin, userDomain
        userDomainLogin = Request.ServerVariables("LOGON_USER")

        if userDomainLogin <> "" then
            'NOTE: IIS security must not allow Anonymous login for this code to be executed
            userLogin = Right(userDomainLogin, Len(userDomainLogin)-InStrRev(userDomainLogin,"\"))
            userDomain = Left(userDomainLogin, InStr(userDomainLogin,"\")-1)
        else
            'If the autoLogin flag is set but IIS security is not set properly default to login
            'depending if the enableWindowsSecurityYN flag is set to.
            userLogin = ""
            userDomain = Session("securityDomain") ' From config.xml propteries file
        end if

        Session("WidowsAuthentication.userLogin") = userLogin
        Session("WindwsAuthentication.userDomain") = userDomain

        GetWindowsUserName = userLogin
    End Function ' GetWindowsUserName()

%>