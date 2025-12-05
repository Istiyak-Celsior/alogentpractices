<%
	Sub GenerateCreditTasks(theTaskGroupId, theCustomerId)
		Dim acctQuery, acctRS
		Set acctRS = Server.CreateObject("ADODB.RecordSet")
		
		acctQuery = _
			" SELECT" & _
			"	c.customerId," & _
			"	c.customerName," & _
			"	c.customerNumber," & _
			"	c.bankId," & _
			"	c.customerTypeId," & _
			"	NULL AS loanId," & _
			"	NULL AS loanTypeId," & _
			"	'' AS loanNumber" & _
			" FROM" & _
			"	customer AS c" & _
			" WHERE" & _
			"	c.customerId=" & dbFormatId(theCustomerId)
		acctRS.Open acctQuery, db, adOpenStatic, adCmdText
		
		Dim taskQuery, taskRS
		Set taskRS = Server.CreateObject("ADODB.RecordSet")
		
		taskQuery = _
			" SELECT" & _
			"	tg.TaskGroupId," & _
			"	tg.TaskGroupLabel," & _
			"	tg.TaskGroupType," & _
			"	tg.TaskProcessing," & _
			"	tg.BankId," & _
			"	t.TaskId," & _
			"	t.TaskLabel," & _
			"	t.ProcessOrder," & _
			"	t.AssignedUserId," & _
			"	t.EnableNotification," & _
			"	t.CCNotification," & _
			"	t.TransferableByUser," & _
			"	t.DueDateOffset," & _
			"	t.AssignActionTaker," & _
			"	t.ExceptionCategoryId," & _
			"	ex.exceptionId," & _
			"	ex.exceptionState" & _
			" FROM" & _
			"	TaskGroup AS tg INNER JOIN Task AS t" & _
			"		ON tg.TaskGroupId=t.TaskGroupId" & _
			"	LEFT OUTER JOIN exception AS ex" & _
			"		ON ex.TaskId=t.TaskId" & _
			"		AND ex.customerId=" & dbFormatId(theCustomerId) & _
			"		AND ex.loanId IS NULL" & _
			" WHERE" & _
			"	tg.taskGroupId=" & dbFormatId(theTaskGroupId) & _
			" ORDER BY" & _
			"	t.ProcessOrder," & _
			"	t.TaskLabel"
		taskRS.Open taskQuery, db, adOpenStatic, adCmdText
		
		GenerateTaskExceptions taskRS, acctRS
		
		taskRS.Close
		acctRS.Close
	End Sub ' GenerateCreditTasks()
	
	Sub GenerateAccountTasks(theTaskGroupId, theLoanId)
		Dim acctQuery, acctRS
		Set acctRS = Server.CreateObject("ADODB.RecordSet")
		
		acctQuery = _
			" SELECT" & _
			"	l.*," & _
			"	c.customerName," & _
			"	c.customerNumber," & _
			"	c.bankId," & _
			"	c.customerTypeId" & _
			" FROM" & _
			"	loan AS l INNER JOIN customer AS c" & _
			"		ON l.customerId=c.customerId" & _
			" WHERE" & _
			"	l.loanId=" & dbFormatId(theLoanId)
		acctRS.Open acctQuery, db, adOpenStatic, adCmdText
		
		Dim taskQuery, taskRS
		Set taskRS = Server.CreateObject("ADODB.RecordSet")
		
		taskQuery = _
			" SELECT" & _
			"	tg.TaskGroupId," & _
			"	tg.TaskGroupLabel," & _
			"	tg.TaskGroupType," & _
			"	tg.TaskProcessing," & _
			"	tg.BankId," & _
			"	t.TaskId," & _
			"	t.TaskLabel," & _
			"	t.ProcessOrder," & _
			"	t.AssignedUserId," & _
			"	t.EnableNotification," & _
			"	t.CCNotification," & _
			"	t.TransferableByUser," & _
			"	t.DueDateOffset," & _
			"	t.AssignActionTaker," & _
			"	t.ExceptionCategoryId," & _
			"	ex.exceptionId," & _
			"	ex.exceptionState" & _
			" FROM" & _
			"	TaskGroup AS tg INNER JOIN Task AS t" & _
			"		ON tg.TaskGroupId=t.TaskGroupId" & _
			"	LEFT OUTER JOIN exception AS ex" & _
			"		ON ex.TaskId=t.TaskId" & _
			"		AND ex.loanId=" & dbFormatId(theLoanId) & _
			" WHERE" & _
			"	tg.taskGroupId=" & dbFormatId(theTaskGroupId) & _
			" ORDER BY" & _
			"	t.ProcessOrder," & _
			"	t.TaskLabel"
		taskRS.Open taskQuery, db, adOpenStatic, adCmdText
		
		GenerateTaskExceptions taskRS, acctRS
		
		taskRS.Close
		acctRS.Close
	End Sub
	
	Sub GenerateTaskExceptions( theTaskRS, theAcctRS)
		' Clear session error flags
		'
		Session("action.errorFlag") = false
		Session("action.errorMessage") = ""
		
		' Process each task
		'
		Dim exceptionId, prevExceptionState, done, createTask
		
		prevExceptionState = ""
		done = false
		do while Not theTaskRS.eof And Not done
			createTask = false
			
			if theTaskRS("TaskProcessing") = "S" then
				' Only create Task if exception does not exist and the
				' previous exceptin is resolved (exceptionState = "N")
				'
				if (prevExceptionState = "" And IsNull(theTaskRS("exceptionId"))) _
					Or (prevExceptionState = "N" And IsNull(theTaskRS("exceptionId"))) then
					' Create first task or next unresolved task.
					'
					createTask = true
					
					' exit loop
					'
					done = true
				end if
				
				if Not IsNull(theTaskRS("exceptionState")) then
					prevExceptionState = theTaskRS("exceptionState")
				else
					prevExceptionState = "skip"
				end if
			else
				' Create all Tasks. Check for Task Exception existance. 
				'	If NULL then create the Task Exception
				'
				if IsNull(theTaskRS("exceptionId")) then
					createTask = true
				end if
			end if
			
			if createTask then
				' Generate the Task Exception
				'
				exceptionId = CreateTaskException(theTaskRS, theAcctRS)
				
				' Send email notifications if enabled
				'
				if theTaskRS("EnableNotification") then
					Dim userQuery, userRS
					Set userRS = Server.CreateObject("ADODB.RecordSet")
					userQuery = "SELECT * FROM [user] WHERE userId IN (SELECT assignedUserId FROM exception WHERE exceptionId=" & dbFormatId(exceptionId) & ")"
					userRS.Open userQuery, db, adOpenStatic, adCmdText
					if Not userRS.eof then
						SendTaskEmailNotification theTaskRS, theAcctRS, userRS
					end if
				end if
			end if
			
			theTaskRS.MoveNext
		loop
	End Sub ' GenerateTaskExceptions()
	
	
	Function CreateTaskException(theTaskRS, theAcctRS)
		' Create new GUID for exceptionDefinition
		'
		Dim exceptionDefId
		exceptionDefId = GenerateGuid("exceptionDefinition", "exceptionDefId")
		
		
		' Calculate the ReminderDate for the Task Exception. Use 0
		' if the value is invalid.
		'
		Dim reminderDate, dateOffset, exceptionState
		exceptionState = "P"
		dateOffset = CheckForNull(theTaskRS("DueDateOffset"))
		
		if Not IsNumeric(dateOffset) then
			dateOffset = 0
		end if
		
		' Check to see if the reminder date is for today, if so
		' set the exception now. Otherwise default to "Pending"
		'
		if dateOffset = 0 then
			exceptionState = "Y"
		end if
		
		reminderDate = DateAdd("d", dateOffset, Now())
		
		
		' Check to see if the Action taker should be used as the Task Assigned user
		'
		Dim assignedUserId
		
		assignedUserId = CheckForNull(theTaskRS("AssignedUserId"))
		if theTaskRS("AssignActionTaker") then
			assignedUserId = Session("userId")
		end if
		
		
		' Create the exceptionDefinition
		'
		Dim sqlCmd
		sqlCmd = BuildInsertQuery_ExceptionDefinition()
		sqlCmd = Replace(sqlCmd, "@exceptionDefId", dbFormatId(exceptionDefId))
		sqlCmd = Replace(sqlCmd, "@exceptionDefName", dbFormatText(theTaskRS("TaskLabel")))
		sqlCmd = Replace(sqlCmd, "@exceptionCategoryId", dbFormatId2(theTaskRS("ExceptionCategoryId"), 2))
		sqlCmd = Replace(sqlCmd, "@bankId", dbFormatId(theAcctRS("bankId")))
		sqlCmd = Replace(sqlCmd, "@defaultAssignedUserId", dbFormatId(assignedUserId))
		sqlCmd = Replace(sqlCmd, "@defaultExistingExceptionState", dbFormatText(exceptionState))
		sqlCmd = Replace(sqlCmd, "@defaultNewExceptionState", dbFormatText(exceptionState))
		sqlCmd = Replace(sqlCmd, "@defaultReminderDateGracePeriod", 0)
		sqlCmd = Replace(sqlCmd, "@defaultReminderDate", dbFormatDate(reminderDate))
		
		' Replace type dependent information
		'
		if theTaskRS("TaskGroupType") = "C" then
			sqlCmd = Replace(sqlCmd, "@customerTypeId", dbFormatId(theAcctRS("customerTypeId")))
			sqlCmd = Replace(sqlCmd, "@customCustomerId", dbFormatId(theAcctRS("customerId")))
			sqlCmd = Replace(sqlCmd, "@loanTypeId", "NULL")
			sqlCmd = Replace(sqlCmd, "@customLoanId", "NULL")
		else
			sqlCmd = Replace(sqlCmd, "@customerTypeId", "NULL")
			sqlCmd = Replace(sqlCmd, "@customCustomerId", "NULL")			
			sqlCmd = Replace(sqlCmd, "@loanTypeId", dbFormatId(theAcctRS("loanTypeId")))
			sqlCmd = Replace(sqlCmd, "@customLoanId", dbFormatId(theAcctRS("loanId")))
		end if
		
		'response.write sqlCmd & "<BR><BR>"
		db.Execute sqlCmd
		
		
		' Create the exception
		'
		Dim exceptionId
		exceptionId = GenerateGuid("exception", "exceptionId")
		
		sqlCmd = BuildInsertQuery_Exception()
		sqlCmd = Replace(sqlCmd, "@exceptionId", dbFormatId(exceptionId))
		sqlCmd = Replace(sqlCmd, "@exceptionDefId", dbFormatId(exceptionDefId))
		sqlCmd = Replace(sqlCmd, "@customerId", dbFormatId(theAcctRS("customerId")))
		sqlCmd = Replace(sqlCmd, "@assignedUserId", dbFormatId(assignedUserId))
		sqlCmd = Replace(sqlCmd, "@exceptionState", dbFormatText(exceptionState))
		sqlCmd = Replace(sqlCmd, "@reminderDateGracePeriod", 0)
		sqlCmd = Replace(sqlCmd, "@reminderDate", dbFormatDate(reminderDate))
		sqlCmd = Replace(sqlCmd, "@TaskId", dbFormatId(theTaskRS("TaskId")))
		
		' Replace type dependent information
		'
		if theTaskRS("TaskGroupType") = "L" then
			sqlCmd = Replace(sqlCmd, "@loanId", dbFormatId(theAcctRS("loanId")))
		else
			sqlCmd = Replace(sqlCmd, "@loanId", "NULL")
		end if
		
		'response.write sqlCmd & "<BR><BR>"
		db.Execute sqlCmd
		
		CreateTaskException = exceptionId
	End Function ' CreateTaskException()
	
	
	' Function: BuildInsertQuery_ExceptionDefinition
	'
	' The following Fields that need to be replaced by the caller
	'	@exceptionDefId
	'	@exceptionDefName
	'	@bankId
	'	@customerTypeId
	'	@loanTypeId
	'	@defaultAssignedUserId
	'	@defaultExistingExceptionState
	'	@defaultNewExceptionState
	'	@defaultReminderDate
	'	@customCustomerId
	'	@customLoanId
	'	@defaultReminderDateGracePeriod
	'	@exceptionCategoryId
	'
	Private Function BuildInsertQuery_ExceptionDefinition()
		Dim sqlQuery
		sqlQuery = _
			" INSERT INTO exceptionDefinition (" & _
			"	exceptionDefId," & _
			"	exceptionDefName," & _
			"	weight," & _
			"	isGlobalYN," & _
			"	bankId," & _
			"	customerTypeId," & _
			"	loanTypeId," & _
			"	exceptionDefType," & _
			"	computationType," & _
			"	defaultAssignedUserId," & _
			"	defaultStatusType," & _
			"	sortOrder," & _
			"	defaultExistingExceptionState," & _
			"	defaultNewExceptionState," & _
			"	exceptionCategoryId," & _
			"	requireReminderDate," & _
			"	defaultReminderDate," & _
			"	PolicyId," & _
			"	dateChanged," & _
			"	dateAdded," & _
			"	changedBy," & _
			"	exceptionDefCode," & _
			"	customCustomerId," & _
			"	customLoanId," & _
			"	defaultReminderDateGracePeriod," & _
			"	taskType" & _
			" ) VALUES (" & _
			"	@exceptionDefId," & _
			"	@exceptionDefName," & _
			"	0," & _
			"	'N'," & _
			"	@bankId," & _
			"	@customerTypeId," & _
			"	@loanTypeId," & _
			"	'custom'," & _
			"	'manual'," & _
			"	@defaultAssignedUserId," & _
			"	'required'," & _
			"	0," & _
			"	@defaultExistingExceptionState," & _
			"	@defaultNewExceptionState," & _
			"	@exceptionCategoryId," & _
			"	'Y'," & _
			"	@defaultReminderDate," & _
			"	NULL," & _
			"	GETDATE()," & _
			"	GETDATE()," & _
			dbFormatId(Session("userFirstName") & " " & Session("userLasName")) & "," & _
			"	NULL," & _
			"	@customCustomerId," & _
			"	@customLoanId," & _
			"	@defaultReminderDateGracePeriod," & _
			"	0" & _
			" )"		
		BuildInsertQuery_ExceptionDefinition = sqlQuery
	End Function ' BuildInsertQuery_ExceptionDefinition()
	
	
	' Function: BuildInsertQuery_ExceptionDefinition
	'
	' The following Fields that need to be replaced by the caller
	'	@exceptionId
	'	@exceptionDefId
	'	@customerId
	'	@loanId
	'	@assignedUserId
	'	@exceptionState
	'	@reminderDate
	'	@reminderDateGracePeriod
	'	@TaskId
	'
	Private Function BuildInsertQuery_Exception()
		Dim today
		today = Now()
		
		Dim sqlQuery
		sqlQuery = _
			" INSERT INTO exception (" & _
			"	exceptionId," & _
			"	exceptionDefId," & _
			"	customerId," & _
			"	loanId," & _
			"	exceptionState," & _
			"	statusType," & _
			"	dateExcepted," & _
			"	dateAdded," & _
			"	dateChanged," & _
			"	assignedUserId," & _
			"	reminderDate," & _
			"	reminderDateGracePeriod," & _
			"	TaskId" & _
			" ) VALUES (" & _
			"	@exceptionId," & _
			"	@exceptionDefId," & _
			"	@customerId," & _
			"	@loanId," & _
			"	@exceptionState," & _
			"	'required'," & _
			dbFormatDate(today) & ", " & _
			dbFormatDate(today) & ", " & _
			dbFormatDate(today) & ", " & _
			"	@assignedUserId," & _
			"	@reminderDate," & _
			"	@reminderDateGracePeriod," & _
			"	@TaskId" & _
			" )"
			
		BuildInsertQuery_Exception = sqlQuery
	End Function ' BuildInsertQuery_Exception()		
	
	
	'------------------------------------------------------------------------
	'
	'------------------------------------------------------------------------
	Sub SendTaskEmailNotification(theTaskRS, theAcctRS, theUserRS)
		Dim sendTo, ccTo
		sendTo = CheckForNull(theUserRS("userEmail"))
		ccTo   = CheckForNull(theTaskRS("CCNotification"))
		
		' Make sure email properties have been set, otherwise skip notification.
		' This includes the sender not having an email address.
		'
		IF Session("userEmail") = "" THEN
			Dim detailedMsg
			detailedMsg = _
				"The assigned User <b>[" & _
				theUserRS("userFirstName") & " " & theUserRS("userLastName") & _
				"</b> for Task <b>[" & _
				theTaskRS("TaskLabel") & "]</b> has a blank E-Mail address."
					
			Session("action.errorFlag")    = true
			Session("action.errorMessage") =  Session("action.errorMessage") & _
											  "<b>Error:</b> Assigned User has no E-Mail address.<br>" & _
											  "<b>Error Description:</b> " & detailedMsg & "<br><br>"
		ELSE
			Dim from        : from           = Session("userEmail")
			Dim recipients  : recipients     = sendTo
			Dim subject     : subject        = "New Task: " & theTaskRS("TaskLabel")
			Dim body        : body           = BuildTaskEmailBody(theTaskRS, theAcctRS)
			Dim httpRequest
			
			IF(Trim(ccTo) <> "") THEN
				recipients = recipients & ";" & Trim(ccTo)
			END IF

			recipients	 = BuildRecipientList(recipients)

			SET httpRequest = MailMessage( from, recipients, subject, body)

			IF httpRequest.status <> 204 THEN
				Session("action.errorFlag")		= true
				Session("action.errorMessage")  =  Session("action.errorMessage") & _
												   "<b>Error:</b> Task Generated but Email notification failed with the following error details.<br>" & _
												   "<b>Error Number:</b> " & httpRequest.status  & "<br>" & _
												   "<b>Error Description:</b> "  & httpRequest.statusText  & "<br><br>"
			END IF  
		END IF
	End Sub ' SendTaskEmailNotification()
	
	
	'------------------------------------------------------------------------
	'
	'------------------------------------------------------------------------
	Function BuildTaskEmailBody(theTaskRS, theAcctRS)
		'  Get the AccuDoc Server URL property
		' 
		Dim acculoanServerURL
		Dim reportServerQuery, reportServerRS
		Set reportServerRS = Server.CreateObject("ADODB.RecordSet")
		reportServerQuery = "SELECT * FROM accusystemsProperties WHERE propertyKey LIKE " & dbFormatText("acculoan.serverURL")
		reportServerRS.Open reportServerQuery, db, adOpenStatic, adCmdText
		acculoanServerURL = reportServerRS("propertyValue")
		reportServerRS.Close
		
		
		'  Build Text Body
		' 
		Dim pageURL, textBody
		
		pageURL = "/customer.asp?customerId=" & theAcctRS("customerId") & "&loanId=" & theAcctRS("loanId")
		
		Dim reminderDate, dateOffset
		dateOffset = CheckForNull(theTaskRS("DueDateOffset"))
		
		if Not IsNumeric(dateOffset) then
			dateOffset = 0
		end if
		
		reminderDate = DateAdd("d", dateOffset, Now())
		
		'  Build the notification text
		' 
		textBody = _
			"This notification is to alert you to the following Task:<br><br>" & _
			"<b>Task:</b> " & theTaskRS("TaskLabel") & "<br>" & _
			"<b>Customer Name:</b> " & theAcctRS("CustomerName") & "<br>" & _
			"<b>Customer Number:</b> <a href='" & acculoanServerURL & pageUrl & "'>" & theAcctRS("customerNumber") & "</a><br>"
		
		if theTaskRS("TaskGroupType") = "L" then
			textBody = textBody & _
			"<b>Application/Account Number:</b> <a href='" & acculoanServerURL & pageUrl & "'>" & theAcctRS("loanNumber") & "</a><br>"
		end if
		
		textBody = textBody & _
			"<b>Task Resolution Date:</b> " & FormatDateTime(reminderDate,2)
		
		
		BuildTaskEmailBody = textBody
	End Function ' BuildTaskEmailBody()
%>

