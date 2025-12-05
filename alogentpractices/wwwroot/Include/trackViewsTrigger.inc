<% 
  	'This function checks to see if the field "Track Views" is checked and if so this process will write the
  	'data to the documenthistory table
  
   	function trackViews(trackViewsDocumentId)
		
		Dim trackViewsQuery, trackViewsRS
		Dim trackViewsTrigger, trackViewsUpdateResults
		Set trackViewsRS = Server.CreateObject("ADODB.RecordSet")
		Dim theDocumentTabId, theDocumentFileName
		
		trackViewsQuery = _
			" SELECT" & _
			"	d.documentTabId, d.FileName, dst.TrackViews" & _
			" FROM" & _
			"	document AS d INNER JOIN documentSubType AS dst" & _
			"		ON d.documentSubTypeId=dst.documentSubTypeId" & _
			" WHERE" & _
			"	d.documentId=" & dbFormatId(trackViewsDocumentId)
			
		trackViewsRS.Open trackViewsQuery, db, adOpenStatic, adCmdText
		
		trackViewsTrigger = trackViewsRS("TrackViews")
		theDocumentTabId = trackViewsRS("documentTabId")
		
		if trackViewsTrigger then
			trackViewsUpdateResults = trackViewsInsert(theDocumentTabId, trackViewsDocumentId)
		end if
	   
	    trackViews = "successful"
	   
   	end function
%>
 
<% 
  	'This function write the data directly into the document history table

   	function trackViewsInsert(theDocumentTabId, documentId)

		Dim trackViewsDataQuery, trackViewsDataRS
		Set trackViewsDataRS = Server.CreateObject("ADODB.RecordSet")
	
		trackViewsDataQuery = _
			" SELECT" & _
			"	c.customerId," & _
			"	c.customerName," & _
			"	c.customerNumber," & _
			"	c.customerFolder," & _
			"	IsNull(l.loanNumber, '') AS loanNumber," & _
			"	IsNull(l.loanFolder, '') AS loanFolder," & _
			"	l.loanId," & _
			"	l.loanNumber," & _
			"	d.fileName," & _
			"	dd.documentDefId," & _
			"	dd.documentTypeId," & _
			"	dd.documentSubTypeId," & _
			"	dd.documentTypeName," & _
			"	dd.documentSubTypeName," & _
			"	dd.defaultDocumentStatusType," & _
			"	dd.requireExpDate," & _
			"	dd.defaultExpDate," & _
			"	dd.docDefHighlightColor," & _
			"	dd.defaultName," & _
			"	(SELECT documentHistoryInputId FROM documentHistoryInput WHERE inputKey LIKE 'acculoan.inputType.Upload') AS inputTypeId" & _
			" FROM" & _
			"	customer AS c INNER JOIN documentTab AS dtab" & _
			"		ON c.customerId=dtab.customerId" & _
			"		AND dtab.documentTabId=" & dbFormatId(theDocumentTabId) & _
			"	INNER JOIN document AS d" & _
        	"		ON c.customerId=d.customerId" & _
			"	INNER JOIN qryDocumentDefinitions AS dd" & _
			"		ON dd.documentDefId=dtab.documentDefId" & _
			"	LEFT OUTER JOIN loan AS l" & _
			"		ON l.loanId=dtab.loanId"
		trackViewsDataRS.Open trackViewsDataQuery, db, adOpenStatic, adCmdText
		
		Dim trackViewsInsertQuery, trackViewsInsertRS
		Dim theComment, theInputTypeId, theCustomerNumber, theLoanNumber
		Dim theFileName, theFileType
		Dim inputTypeQuery, inputTypeQueryRS
		
      	theComment = "Document History Viewer Trigger"
		theCustomerNumber = trackViewsDataRS("customerNumber")
		theLoanNumber = trackViewsDataRS("loanNumber")
		theFileName = trackViewsDataRS("fileName")
		theFileType = trackViewsDataRS("documentTypeName") & ": " & trackViewsDataRS("documentSubTypeName")
		
		theInputTypeId = GetDocumentHistoryInputId("acculoan.inputType.DocumentViewed")

		Set trackViewsInsertRS = Server.CreateObject("ADODB.RecordSet")
		
		trackViewsInsertQuery = _
			" INSERT INTO documentHistory" & _
			" (" & _
			"	userLogin," & _
			"	userName," & _
			"	customerNumber," & _
			"	loanNumber," & _
			"	documentFilename," & _
			"	documentType," & _
			"	pagesAdded," & _
			"	pagesDeleted," & _
			"	documentDeletedYN," & _
			"	dateChanged," & _
			"	comment," & _
			"	documentId," & _
			"	inputType" & _
			" )" & _
			" VALUES" & _
			" (" & _
			dbFormatText(Session("userLogin")) & "," & _
			dbFormatText(Session("userName")) & "," & _
			dbFormatText(theCustomerNumber) & "," & _
			dbFormatText2(theLoanNumber, true) & "," & _
			dbFormatText(theFilename) & "," & _
			dbFormatText(theFileType) & "," & _
			0 & "," & _
			0 & "," & _
			0 & "," & _
			dbFormatDate(Now()) & "," & _
			dbFormatText(theComment) & "," & _
			dbFormatId(documentId) & "," & _
			dbFormatId(theInputTypeId) & _
			" )"	
			
		trackViewsInsertRS.Open trackViewsInsertQuery, db, adOpenStatic, adCmdText
   	end function
%>