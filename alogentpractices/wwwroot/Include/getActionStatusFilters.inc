<%
	' The following constants are generalized for the three data columns in 
	' the actionEventStatusFilter tables. These constants should be used
	' when referencing the various status filter list arrays and is always the
	' first array element of the 2d arrays with the second array element denoting
	' the row within the data table.
	'
	CONST ACTION_FILTER_ID = 0
	CONST ACTION_EVENT_ID = 1
	CONST ACTION_STATUS_ID = 2
	
	
	' Members for geting status filter information from database
	'
	Dim gActionStatusQuery, gActionStatusRS
	Set gActionStatusRS = Server.CreateObject("ADODB.RecordSet")
	
	
	' Load the applicationStatusFilters for events into memory arrays
	'
	Dim gActionApplicationStatusList, gActionApplicationStatusCount
	gActionStatusQuery = _
		" SELECT" & _
		"	actionApplicationStatusFilterId," & _
		"	actionEventId," & _
		"	loanStatusId" & _
		" FROM actionApplicationStatusFilter" & _
		" ORDER BY actionEventId"
	gActionStatusRS.Open gActionStatusQuery, db, adOpenStatic, adCmdText
	gActionApplicationStatusCount = -1
	if Not gActionStatusRS.eof then
		gActionApplicationStatusList = gActionStatusRS.GetRows()
		gActionApplicationStatusCount = gActionStatusRS.RecordCount
	end if
	gActionStatusRS.Close
	
	
	' Load the analysisStatusFilters for events into memory arrays
	'
	Dim gActionAnalysisStatusList, gActionAnalysisStatusCount
	gActionStatusQuery = _
		" SELECT" & _
		"	actionAnalysisStatusFilterId," & _
		"	actionEventId," & _
		"	creditAnalysisStatusId" & _
		" FROM actionAnalysisStatusFilter" & _
		" ORDER BY actionEventId"
	gActionStatusRS.Open gActionStatusQuery, db, adOpenStatic, adCmdText
	gActionAnalysisStatusCount = -1
	if Not gActionStatusRS.eof then
		gActionAnalysisStatusList = gActionStatusRS.GetRows()
		gActionAnalysisStatusCount = gActionStatusRS.RecordCount
	end if
	gActionStatusRS.Close
	
	
	' Load the approvalStatusFilters for events into memory arrays
	'
	Dim gActionApprovalStatusList, gActionApprovalStatusCount
	gActionStatusQuery = _
		" SELECT" & _
		"	actionApprovalStatusFilterId," & _
		"	actionEventId," & _
		"	approvalStatusId" & _
		" FROM actionApprovalStatusFilter" & _
		" ORDER BY actionEventId"
	gActionStatusRS.Open gActionStatusQuery, db, adOpenStatic, adCmdText
	gActionApprovalStatusCount = -1
	if Not gActionStatusRS.eof then
		gActionApprovalStatusList = gActionStatusRS.GetRows()
		gActionApprovalStatusCount = gActionStatusRS.RecordCount
	end if
	gActionStatusRS.Close
%>