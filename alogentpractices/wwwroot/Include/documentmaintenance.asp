<%
	'
	'	Function:
	'		DeleteDocument
	'
	' Arguments:
	'		theDocumentId						- the document record to be deleted
	'
	'	Returns:
	'		boolean									- returns true for successful deletion, false otherwise.
	'
	'	Description:
	'		Deletes a given document record.
	'
	'	Maintenance History:
	'	Developer					Date				Action
	' -----------------	----------	-------------------------------------------------
	'	MikeF							09/17/2007	Created
	'
FUNCTION DeleteDocument(theDocumentId)
    ' Ensure a documentId exists, if not then exit function.
    If theDocumentId = "" Then
        DeleteDocument = true
        Exit Function
    End If

	Dim fso : Set fso = Server.CreateObject("Scripting.FileSystemObject")
	Dim deleteImages : deleteImages = Trim(Request("deleteImages"))
	Dim inputTypeId : inputTypeId = GetDocumentHistoryInputId("acculoan.inputType.Delete")

    Dim hasDocumentRecord : hasDocumentRecord = False
	Dim documentRS : Set documentRS = Server.CreateObject("ADODB.RecordSet")
	Dim documentQuery : documentQuery = "SELECT * FROM document WHERE documentId = " & dbFormatId(theDocumentId)
	documentRS.Open documentQuery, db, adOpenKeySet, adLockPessimistic
    IF NOT documentRS.EOF THEN
        hasDocumentRecord = True
        Dim docCustomerId : docCustomerId = documentRS("customerId")
        Dim docLoanId : docLoanId = documentRS("loanId")
        Dim docDocumentStatus : docDocumentStatus = documentRS("documentStatus")
        Dim docLoanFile : docLoanFile = documentRS("loanFile")
        Dim docFileName : docFileName = documentRS("fileName")
        Dim docDocumentDefId : docDocumentDefId = documentRS("documentDefId")
    END IF
	documentRS.Close
	
	Dim customerRS : Set customerRS = Server.CreateObject("ADODB.RecordSet")
    Dim customerQuery : customerQuery = "SELECT * FROM customer WHERE customerId = " & dbFormatId(docCustomerId)
	customerRS.Open customerQuery, db, adOpenStatic
    IF NOT customerRS.EOF THEN
	    Dim customerId : customerId = customerRS("customerId")
	    Dim customerNumber : customerNumber = customerRS("customerNumber")
	    Dim customerFolder : customerFolder = customerRS("customerFolder")
	    Dim tmpCustomerTypeId : tmpCustomerTypeId = customerRs("customerTypeID")
    END IF
	customerRS.Close
	
	Dim loanQuery : loanQuery = ""
	Dim loanFolder : loanFolder = ""
	Dim loanId : loanId = ""
	
    IF IsNull(docLoanId) THEN
		loanFolder = ""
	ELSEIF docLoanId = "0" THEN
		loanFolder = ""
	ELSE
        Dim loanRS : Set loanRS = Server.CreateObject("ADODB.RecordSet")
		loanQuery = "SELECT * FROM loan WHERE loanId = " & dbFormatId(docLoanId)
		loanRS.Open loanQuery, db, adOpenStatic
        IF NOT loanRS.EOF THEN
		    loanNumber = loanRS("loanNumber")
		    loanFolder = loanRS("loanFolder")
		    loanId = loanRS("loanId")
		    loanTypeid = loanRS("loanTypeId")
        END IF
		loanRS.Close()
	END IF
	
	IF hasDocumentRecord THEN
		IF deleteImages = "Y" THEN
			IF docDocumentStatus = "1" THEN
				Dim filePath : filePath = Session("fullpath") & "/" & customerFolder & loanFolder & docLoanFile & "/" & docFileName
				IF fso.FileExists(filePath) THEN fso.DeleteFile filePath, True
				
                Dim documentDefRS : Set documentDefRS = Server.CreateObject("ADODB.RecordSet")
                Dim docDefQuery : docDefQuery = _
					" SELECT *" & _
					" FROM qryDocumentDefinitions" & _
					" WHERE documentDefId = " & dbFormatId(docDocumentDefId)
				documentDefRS.Open docDefQuery, db, adOpenStatic, adCmdText
                IF NOT documentDefRS.EOF THEN
	      		    Dim docType : docType = documentDefRS("documentTypeName")
				    Dim docSubType : docSubType = documentDefRS("documentSubTypeName")
                END IF
				documentDefRS.Close()
				
				Dim formattedLoanNumber : formattedLoanNumber = "NULL"
				IF loanId <> "" THEN formattedLoanNumber = dbFormatText(loanNumber)
				
				Dim formattedInputType : formattedInputType = "NULL"
				IF inputTypeId <> "" THEN formattedInputType = dbFormatId(inputTypeId)
				
				Dim formattedComment
				IF loanFolder <> "" THEN
					formattedComment =  _
						"User [" & Session("userName") & "] has <b>deleted</b> this document from" & _
						" Customer [" & customerNumber & "] - " & _
						" Loan/Collateral Number [" & loanNumber & "]."
					formattedComment = dbFormatText(formattedComment)
				ELSE
					formattedComment =  _
						"User [" & Session("userName") & "] has <b>deleted</b> this document from" & _
						" Customer [" & customerNumber & "]."
					formattedComment = dbFormatText(formattedComment)
				END IF
				
				' Insert documentHistory to log the document deletion.
	            Dim scanHistoryRS : Set scanHistoryRS = Server.CreateObject("ADODB.RecordSet")
				Dim scanHistoryInsert : scanHistoryInsert = _
					" INSERT INTO documentHistory (" & _
					"	userLogin," & _
					"	username," & _
					"	customerNumber," & _
					"	loanNumber," & _
					"	documentFilename," & _
					"	documentType," & _
					"	pagesAdded," & _
					"	pagesDeleted," & _
					"	dateChanged," & _
					"	documentDeletedYN," & _
					"	inputType," & _
					"	comment" & _
					" ) VALUES (" & _
					dbFormatText(Session("userLogin")) & ", " & _
					dbFormatText(Session("userName")) & ", " & _
					dbFormatText(customerNumber) & ", " & _
					formattedLoanNumber & ", " & _
					dbFormatText(docFileName) & ", " & _
					dbFormatText(docType & " / " & docSubType) & ", " & _
					" 0, " & _
					" 0, " & _
					dbFormatDate(scanHistoryDateChanged) & ", " & _
					" 1, " & _
					formattedInputType & ", " & _
					formattedComment & _
					" )"
				db.Execute scanHistoryInsert

                ' ### Update existing documentHistory records removing the documentId reference as it no longer exists ###
                Dim cleanDocumentHistoryQuery : cleanDocumentHistoryQuery = _
                    "UPDATE documentHistory SET [documentId] = NULL WHERE documentId = " & dbFormatId(theDocumentId)
                db.Execute(cleanDocumentHistoryQuery)
			end if
		end if

        ' ### Create an array of JSON objects so when the documents are deleted we can create the Document Audit Records ###
        Dim auditSql : auditSql = "SELECT documentId FROM document WHERE documentId = " & dbFormatId(theDocumentId)
        Dim jsonDataArray : jsonDataArray = CreateDeleteDocumentAuditDataArray(auditSql, "Deleted", "", Session("userLogin"))

        ' ### Delete FK references related to document. ###
		db.Execute  "DELETE FROM auditDocumentDetail WHERE documentId = " & dbFormatId(theDocumentId) & ";"
		db.Execute  " DELETE ahd" & _ 
					" FROM DocumentAuditHistoryDiff AS ahd INNER JOIN DocumentAuditHistory AS ah " & _
					"	ON ahd.DocumentAuditHistoryId=ah.DocumentAuditHistoryId" & _
					" WHERE ah.documentId = " & dbFormatId(theDocumentId) & ";"
		db.Execute  "DELETE FROM DocumentAuditHistory WHERE DocumentId = " & dbFormatId(theDocumentId) & ";"
		db.Execute  "DELETE FROM exceptedDocument WHERE exceptedDocumentId = " & dbFormatId(theDocumentId) & "; "
		db.Execute  "DELETE FROM document WHERE documentId = " & dbFormatId(theDocumentId)
                    

        ' ### Process JSON array and create Document Audit Records for each deleted document ###
        ProcessDeleteDocumentAuditDataArray(jsonDataArray)

    END IF
	DeleteDocument = true
END FUNCTION ' ### DeleteDocument()


	Function MoveDocument(theDocumentId, theTargetDocumentTabId)
		' Get the inputTypeId for DocumentHistory logging.
		'
		Dim inputTypeId : inputTypeId = GetDocumentHistoryInputId("acculoan.inputType.CopyMove")
		
		' Get customer, account and documentInformation for the move.
		'
		Dim srcCustomerName, srcCustomerNumber, srcLoanNumber, srcDocumentTypeName, srcDocumentSubTypeName
		Dim srcCustomerFolder, srcLoanFolder, srcLoanFile, srcFilename, srcFilePath
		Dim dstCustomerName, dstCustomerNumber, dstLoanNumber, dstDocumentTypeName, dstDocumentSubTypeName
		Dim dstCustomerFolder, dstLoanFolder, dstLoanFile, dstFilename, dstFilePath
		
		Dim docQuery, docRS
		Set docRS = Server.CreateObject("ADODB.RecordSet")
		
		' Get source path information
		'
		docQuery = _
			" SELECT" & _
			"	c.customerName," & _
			"	c.customerNumber," & _
			"	c.customerFolder," & _
			"	IsNull(l.loanNumber, '---') AS loanNumber," & _
			"	IsNull(l.loanFolder, '') AS loanFolder," & _
			"	dd.documentTypeName," & _ 
			"	dd.documentSubTypeName," & _
			"	d.loanFile," & _
			"	d.filename," & _
			"	d.documentStatus" & _
			" FROM" & _
			"	customer AS c INNER JOIN [document] AS d" & _
			"		ON c.customerId=d.customerId" & _
			"	INNER JOIN qryDocumentDefinitions AS dd" & _
			"		ON dd.documentDefId=d.documentDefId" & _
			"	LEFT OUTER JOIN loan AS l" & _
			"		ON l.loanId=d.loanId" & _
			" WHERE" & _
			"	d.documentId=" & dbFormatId(theDocumentId)
		docRS.Open docQuery, db, adOpenStatic, adCmdText
		
		if Not docRS.eof then
			srcCustomerName = docRS("customerName")
			srcCustomerNumber = docRS("customerNumber")
			srcCustomerFolder = docRS("customerFolder")
			srcLoanNumber = docRS("loanNumber")
			srcLoanFolder = docRS("loanFolder")
			srcDocumentTypeName = docRS("documentTypeName")
			srcDocumentSubTypeName = docRS("documentSubTypeName")
			srcLoanFile = docRS("loanFile")
			srcFilename = docRS("filename")
		end if
		
		docRS.Close
		
		' Get destination path information
		'
		docQuery = _
			" SELECT" & _
			"	c.customerName," & _
			"	c.customerNumber," & _
			"	c.customerFolder," & _
			"	IsNull(l.loanNumber, '---') AS loanNumber," & _
			"	IsNull(l.loanFolder, '') AS loanFolder," & _
			"	dd.documentTypeName," & _ 
			"	dd.documentSubTypeName," & _
			"	dd.defaultName AS loanFile" & _
			" FROM" & _
			"	customer AS c INNER JOIN documentTab AS dt" & _
			"		ON dt.customerId=c.customerId" & _
			"	INNER JOIN qryDocumentDefinitions AS dd" & _
			"		ON dd.documentDefId=dt.documentDefId" & _
			"	LEFT OUTER JOIN loan AS l" & _
			"		ON l.loanId=dt.loanId" & _
			" WHERE" & _
			"	dt.documentTabId=" & dbFormatId(theTargetDocumentTabId)
		response.write docQuery & "<br><br>"
		docRS.Open docQuery, db, adOpenStatic, adCmdText
		if Not docRS.eof then
			dstCustomerName = docRS("customerName")
			dstCustomerNumber = docRS("customerNumber")
			dstCustomerFolder = docRS("customerFolder")
			dstLoanNumber = docRS("loanNumber")
			dstLoanFolder = docRS("loanFolder")
			dstDocumentTypeName = docRS("documentTypeName")
			dstDocumentSubTypeName = docRS("documentSubTypeName")
			dstLoanFile = docRS("loanFile")
			
			' Destination filename same as the source
			dstFilename = srcFilename
		end if
		docRS.Close
		
		Dim imageFolder
		imageFolder = Replace(TrimTrailingSlash(Session("fullpath")), "/", "\")
		
		srcFilePath = "\" & Replace(srcCustomerFolder & srcLoanFolder & srcLoanFile, "/", "\")
		BuildFolderPath imageFolder, srcFilePath
		
		dstFilePath = "\" & Replace(dstCustomerFolder & dstLoanFolder & dstLoanFile, "/", "\")
		BuildFolderPath imageFolder, dstFilePath
		
		' Check for destination filename uniqueness
		'
		Dim filenameUnique, fileExtension
		filenameUnique = false
		do until filenameUnique
			if Not g_fso.FileExists( imageFolder & dstFilePath & "\" & dstFilename) then
				filenameUnique = true
			else
				' generate a new filename
				'
				fileExtension = GetFileExtension(dstFilename)
				dstFilename = RandomString(32) & fileExtension
			end if
		loop
		
		' Set the full path names
		'
		srcFilePath = imageFolder & srcFilePath & "\" & srcFilename
		dstFilePath = imageFolder & dstFilePath & "\" & dstFilename
		
		' Update the document references to reflect move to target DocumentTab
		'
		docQuery = _
			" UPDATE [document] SET" & _
			"	customerId=v1.customerId," & _
			"	loanId=v1.loanId," & _
			"	documentTypeId=v1.documentTypeId," & _
			"	documentSubTypeId=v1.documentSubTypeId," & _
			"	documentDefId=v1.documentDefId," & _
			"	documentTabId=v1.documentTabId," & _
			"	modifiedDate=GETDATE()," & _
			"	loanFile=" & dbFormatText(dstLoanFile) & "," & _
			"	filename=" & dbFormatText(dstFilename) & _
			" FROM" & _
			"	document CROSS JOIN (" & _
			"		SELECT" & _
			"			dt.customerId," & _
			"			dt.loanId," & _
			"			dd.documentTypeId," & _
			"			dd.documentSubTypeId," & _
			"			dt.documentDefId," & _
			"			dt.documentTabId" & _
			"		FROM" & _
			"			documentTab AS dt INNER JOIN qryDocumentDefinitions AS dd" & _
			"				ON dt.documentDefId=dd.documentDefId" & _
			"		WHERE" & _
			"			dt.documentTabId=" & dbFormatId(theTargetDocumentTabId) & _
			"	) AS v1" & _
			" WHERE" & _
			"	document.documentId=" & dbFormatId(theDocumentId)
		db.Execute docQuery
		
		' Move the physical image if it exists
		'
		if g_fso.FileExists(srcFilePath) then
			g_fso.MoveFile srcFilePath, dstFilePath
		end if
		
		Dim historyComment
		historyComment = _
			"Document Moved from [" & srcDocumentTypeName & " : " & srcDocumentSubTypename & _
			"] to [" & dstDocumentTypeName & " : " & dstDocumentSubTypeName & "]"
		
		InsertDocumentHistory _
			srcCustomerNumber, _
			srcLoanNumber, _
			dstFilename, _
			dstDocumentTypeName, _
			dstDocumentSubTypeName, _
			theDocumentId, _
			inputTypeId, _
			historyComment
	End Function ' MoveDocument
	
	Sub InsertDocumentHistory( _
		theCustomerNumber, theloanNumber, theFilename, theDocTypeName, theDocSubTypeName, theDocumentId, theInputTypeId, theComment	)
        ON ERROR RESUME NEXT
		Dim today
		today = Now()
		Dim sqlCmd
		sqlCmd = _
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
			"	documentId," & _
			"	inputType," & _
			"	comment" & _
			" )" & _
			" VALUES" & _
			" (" & _
			dbFormatText(Session("userLogin")) & "," & _
			dbFormatText(Session("userName")) & "," & _
			dbFormatText(theCustomerNumber) & "," & _
			dbFormatText2(theLoanNumber, true) & "," & _
			dbFormatText2(theFilename, true) & "," & _
			dbFormatText(theDocTypeName & ": " & theDocSubTypeName) & "," & _
			"0," & _
			"0," & _
			"0," & _
			dbFormatDate(Now()) & "," & _
			dbFormatId(theDocumentId) & "," & _
			dbFormatId(theInputTypeId) & "," & _
			dbFormatText(theComment) & _
			" )"
		db.Execute sqlCmd
	End Sub
	

    FUNCTION GetEmptyDocument(tabId)
        Dim result : Set result = New EmptyDocumentResult
        result.documentId = ""
        result.isNewDocument = false

        Dim docRS : Set docRS = Server.CreateObject("ADODB.RecordSet")
        Dim docQuery : docQuery = "SELECT documentId FROM document WHERE documentStatus = 2 AND documentTabId = " & dbFormatId(tabId)
        Response.Write docQuery & "<br/><br/>"
        docRS.Open docQuery, db, adOpenStatic, adCmdText
        IF NOT docRS.EOF THEN
            IF docRS.RecordCount = 1 THEN result.documentId = docRS("documentId")
        END IF
        docRS.Close

        IF Trim(result.documentId & "") = "" THEN
            result.documentId = GenerateGuid("document", "documentId")
            result.isNewDocument = true

            ' ### Create a new documentRecord ###
            docQuery = _
                " INSERT INTO document (" & _
                "   documentId," & _
                "   customerId," & _
                "   loanId," & _
                "   documentTypeId," & _
                "   documentSubTypeId," & _
                "   documentDefId," & _
                "   documentTabId," & _
                "   loanFile," & _
                "   filename," & _
                "   documentStatus," & _
                "   documentTitle," & _
                "   documentStatusType," & _
                "   origDate," & _
                "   modifiedDate," & _
                "   expDate," & _
                "   documentHighlightColor" & _
                " )" & _
                " SELECT " & _
                dbFormatId(result.documentId) & "," & _
                "   c.customerId," & _
                "   l.loanId," & _
                "   dd.documentTypeId," & _
                "   dd.documentSubTypeId," & _
                "   dd.documentDefId," & _
                "   dt.documentTabId," & _
                "   dd.defaultName," & _
                "   NULL," & _
                "   2," & _
                "   dd.documentSubTypeName," & _
                "   dd.defaultExistingDocumentStatusType," & _
                "   GETDATE()," & _
                "   GETDATE()," & _
                "   dd.defaultExpDate," & _
                "   dt.docTabHighlightColor" & _
                " FROM" & _
                "   documentTab AS dt INNER JOIN customer AS c" & _
                "       ON dt.customerId = c.customerId" & _
                "   LEFT OUTER JOIN loan AS l" & _
                "       ON l.loanId = dt.loanId" & _
                "   INNER JOIN qryDocumentDefinitions AS dd" & _
                "       ON dd.documentDefId = dt.documentDefId" & _
                " WHERE" & _
                "   dt.documentTabId=" & dbFormatId(tabId)
            db.Execute docQuery
        END IF

        Set GetEmptyDocument = result
    END FUNCTION

	Sub TrackWaivedDocument(documentId, orgStatusType, newStatusType)
		Dim docQuery, docRS
		Set docRS = Server.CreateObject("ADODB.RecordSet")
		
		docQuery = _
			" SELECT" & _
			"	c.customerNumber," & _
			"	l.loanNumber," & _
			"	d.filename," & _
			"	dd.documentTypeName," & _
			"	dd.documentSubTypeName," & _
			"	(SELECT documentHistoryInputId FROM documentHistoryInput WHERE inputKey LIKE " & dbFormatText("acculoan.inputType.DocumentWaived") & ") AS inputType" & _
			" FROM" & _
			"	document AS d INNER JOIN documentTab AS dt" & _
			"		ON dt.documentTabId=d.documentTabId" & _
			"	INNER JOIN qryDocumentDefinitions AS dd" & _
			"		ON dd.documentDefId=dt.documentDefId" & _
			"	INNER JOIN customer AS c" & _
			"		ON d.customerId=c.customerId" & _
			"	LEFT OUTER JOIN loan AS l" & _
			"		ON l.loanId=d.loanId" & _
			" WHERE" & _
			"	d.documentId = " & dbFormatId(documentId)
		docRS.Open docQuery, db, adOpenStatic, adCmdText
		
		Dim historyComment, orgDisplayValue
		
		if orgStatusType = 1 then
			orgDisplayValue = "Required"
		elseif orgStatusType = 2 then
			orgDisplayValue = "N/A"
		end if
		
		historyComment = "User [" & Session("userName") & "] has changed the Document Status Type from [" & orgDisplayValue & "] to [Waived]."
    
    dim strTheFile
    strTheFile = docRS("filename")

    if isnull(strTheFile) then
        strTheFile="NULL"
   end if
		dim sqlCmd
        sqlCmd = _
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
			"	documentId," & _
			"	inputType," & _
			"	comment" & _
			" )" & _
			" VALUES" & _
			" (" & _
			dbFormatText(Session("userLogin")) & "," & _
			dbFormatText(Session("userName")) & "," & _
			dbFormatText(docRS("customerNumber")) & "," & _
			dbFormatText2(docRS("loanNumber"), true) & "," & _
			dbFormatText2(strTheFile, true) & "," & _
			dbFormatText(docRS("documentTypeName") & ": " & docRS("documentSubTypeName")) & "," & _
			"0," & _
			"0," & _
			"0," & _
			dbFormatDate(Now()) & "," & _
			dbFormatId(documentId) & "," & _
			dbFormatId(docRS("inputType")) & "," & _
			dbFormatText(historyComment) & _
			" )"
			db.Execute sqlCmd
		
		docRS.Close
		
	End Sub
	
	
	Function GetDocumentTabId(documentId)
		Dim documentTabId
		Dim tabQuery, tabRS
		Set tabRS = Server.CreateObject("ADODB.RecordSet")
		
		tabQuery = "SELECT documentTabId FROM document WHERE documentId=" & dbFormatId(documentId)
		tabRS.Open tabQuery, db, adOpenStatic, adCmdText
		
		documentTabId = ""
		if Not tabRS.eof then
			documentTabId = tabRS("documentTabId")
		end if
		
		GetDocumentTabId = documentTabId
	End Function ' GetDocumentTabId()


    SUB AccuTrackDocumentHistoryInsert(documentId, orgDocumentStatus, newDocumentStatus)
        IF orgDocumentStatus <> newDocumentStatus  THEN
            Dim historyComment : historyComment = "The value of DocumentStatus [" & newDocumentStatus & "] is invalid."
            IF newDocumentStatus = 1 THEN
                historyComment = "User [" & Session("userName") & "] has set the document to 'Has File'."
            ELSEIF newDocumentStatus = 2 THEN
                historyComment = "User [" & Session("userName") & "] has set the document to 'No File'."
            END IF

		    Dim docQuery, docRS
		    Set docRS = Server.CreateObject("ADODB.RecordSet")
		
		    docQuery = _
			    " SELECT" & _
			    "	c.customerNumber," & _
			    "	l.loanNumber," & _
			    "	d.filename," & _
			    "	dd.documentTypeName," & _
			    "	dd.documentSubTypeName," & _
			    "	(SELECT documentHistoryInputId FROM documentHistoryInput WHERE inputKey LIKE " & dbFormatText("acculoan.inputType.ExternalDocument") & ") AS inputType" & _
			    " FROM" & _
			    "	document AS d INNER JOIN documentTab AS dt" & _
			    "		ON dt.documentTabId=d.documentTabId" & _
			    "	INNER JOIN qryDocumentDefinitions AS dd" & _
			    "		ON dd.documentDefId=dt.documentDefId" & _
			    "	INNER JOIN customer AS c" & _
			    "		ON d.customerId=c.customerId" & _
			    "	LEFT OUTER JOIN loan AS l" & _
			    "		ON l.loanId=d.loanId" & _
			    " WHERE" & _
			    "	d.documentId = " & dbFormatId(documentId)
		    docRS.Open docQuery, db, adOpenStatic, adCmdText
		    dim sqlCmd
            sqlCmd = _
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
			    "	documentId," & _
			    "	inputType," & _
			    "	comment" & _
			    " )" & _
			    " VALUES" & _
			    " (" & _
			    dbFormatText(Session("userLogin")) & "," & _
			    dbFormatText(Session("userName")) & "," & _
			    dbFormatText(docRS("customerNumber")) & "," & _
			    dbFormatText2(docRS("loanNumber"), true) & "," & _
			    "NULL," & _
			    dbFormatText(docRS("documentTypeName") & ": " & docRS("documentSubTypeName")) & "," & _
			    "0," & _
			    "0," & _
			    "0," & _
			    dbFormatDate(Now()) & "," & _
			    dbFormatId(documentId) & "," & _
			    dbFormatId(docRS("inputType")) & "," & _
			    dbFormatText(historyComment) & _
			    " )"
			    db.Execute sqlCmd

    		docRS.Close
        END IF
    END SUB

    
    '### The following are document and documentTab related functions that have been refactored from other pages to aggregate
    '### the document functions together.


    '### This is the main logic for handling QuickMove. It'll coordinate moving a file to the scanned images folder, updating
    '### the document record, inserting document history and tracking information.
    '###
    '###    documentUploadI     : The document fingerprint Id of the file to move
    '###    targetCustomerId    : The taget customerId of the document move
    '###    targetLoanId        : The target loan record (account or collateral) of the document move
    '###    targetValue         : The target reference of the documentTab for the file to be dropped in.
    '###                          NOTE: the target value is passed as either a documentTabId, documentDefId or documentId value.
    '###                          If the string starts with "T:" its a tabId reference, a "D:" for documentDefinition
    '###                          reference or "I:" for documentId. This prefix will be stripped to get the Id value.
    FUNCTION ProcessQuickMove(documentUploadId, targetCustomerId, targetLoanId, targetValue)
        Dim documentInfo    : SET documentInfo = New DocumentProjection
        Dim uploadFolder, uploadSource

        '### Assume successful process unless a failure occurs.
        documentInfo.actionSuccessful = true

        ' ### Process targetValue into an Id value based on the prefix
        IF Left(targetValue, 2) = "I:" THEN
            documentInfo.DocumentId = Right(targetValue, Len(targetValue)-2)
            documentInfo.DocumentTabId = GetDocumentTabIdByGeneralValue("document", "documentId", documentInfo.DocumentId, targetCustomerId, targetLoanId)
        ELSEIF Left(targetValue, 2) = "T:" THEN
            documentInfo.DocumentTabId = Right(targetValue, Len(targetValue)-2)
        ELSE
            documentInfo.DocumentDefId = Right(targetValue, Len(targetValue)-2)
            documentInfo.DocumentTabId = GetDocumentTabIdByGeneralValue("documentTab", "documentDefId", documentInfo.DocumentDefId, targetCustomerId, targetLoanId)
        END IF

        IF documentInfo.DocumentTabId = "" AND documentInfo.DocumentId = "" THEN
            documentInfo.DocumentTabId = InsertDocumentTabWithDefaults(targetCustomerId, targetLoanId, documentInfo.DocumentDefId)
        END IF

        '### ensure curly braces are part of the GUID as they can be stripped by javascript and are required for the dictionary lookup.
        IF InStr(documentUploadId, "{") = 0 THEN documentUploadId = "{" & documentUploadId & "}"

        '### Get document fingerprint information
        Dim i
        IF g_documentUploadDictById.Exists(LCase(CStr(documentUploadId))) THEN
            i = g_documentUploadDictById(LCase(CStr(documentUploadId)))
            documentInfo.customerId = g_documentUploadList(DU_CUSTOMER_ID,i)
            documentInfo.customerName = g_documentUploadList(DU_CUSTOMER_NAME,i)
            documentInfo.customerNumber = g_documentUploadList(DU_CUSTOMER_NUMBER,i)
            IF g_documentUploadList(DU_COLLATERAL_PARENT_LOAN_ID,i) & "" = "" THEN
                documentInfo.loanId = g_documentUploadList(DU_LOAN_ID,i)
                documentInfo.collateralLoanId = ""
                documentInfo.isCollateralYN = "N"
            ELSE
                documentInfo.loanId = g_documentUploadList(DU_COLLATERAL_PARENT_LOAN_ID,i)
                documentInfo.collateralLoanId = g_documentUploadList(DU_LOAN_ID,i)
                documentInfo.isCollateralYN = "Y"
            END IF
            documentInfo.loanNumber = g_documentUploadList(DU_LOAN_NUMBER,i)
            documentInfo.documentFilename = g_documentUploadList(DU_FILENAME,i)
            documentInfo.documentTitle = g_documentUploadList(DU_TITLE,i)
            documentInfo.documentComment = g_documentUploadList(DU_COMMENT,i)
            documentInfo.documentExpDate = g_documentUploadList(DU_EXP_DATE,i)
            uploadSource = g_documentUploadList(DU_UPLOAD_SOURCE,i)
            uploadFolder = g_documentUploadList(DU_UPLOAD_PATH,i)
        END IF

        '### get additional document tab and folder information
        Dim targetTabRS : Set targetTabRS = Server.CreateObject("ADODB.RecordSet")
        Dim targetTabQuery : targetTabQuery = _
            " SELECT" & _
            "   c.customerFolder," & _
            "   IsNull(l.loanFolder, '') AS loanFolder," & _
            "   dd.defaultName AS tabFolder," & _
            "   dd.documentTypeName," & _
            "   dd.documentSubTypeName," & _
            "   dd.requireExpDate," & _
            "   dd.defaultExpDate" & _
            " FROM" & _
            "   documentTab AS dt INNER JOIN qryDocumentDefinitions AS dd" & _
            "       ON dt.documentDefId=dd.documentDefId" & _
            "   INNER JOIN customer AS c" & _
            "       ON c.customerId=dt.customerId" & _
            "   LEFT OUTER JOIN loan AS l" & _
            "       ON l.loanId=dt.loanId" & _
            "   LEFT OUTER JOIN collateral AS cl" & _
            "       ON cl.collateralLoanId=l.loanId" & _
            " WHERE" & _
            "   dt.documentTabId=" & dbFormatId(documentInfo.documentTabId)
        targetTabRS.Open targetTabQuery, db
        IF NOT targetTabRS.EOF THEN
            documentInfo.customerFolder = targetTabRS("customerFolder")
            documentInfo.loanFolder = targetTabRS("loanFolder")
            documentInfo.tabFolder = targetTabRS("tabFolder")

            ' ### ONLY MODIFY THE DOCUMENT TITLE IF NULL OR THE SAME AS THE DOCUMENT
            ' SUBTYPE NAME. IF NOT, LEAVE THE UNIQUE MODIFIED DOCUMENT TITLE ###
            IF cStr(documentInfo.documentTitle) = cStr(targetTabRS("documentSubTypeName")) THEN
                documentInfo.documentTitle = targetTabRS("documentSubTypeName")
            ELSEIF Trim(documentInfo.documentTitle & "") = "" THEN
                documentInfo.documentTitle = targetTabRS("documentSubTypeName")
            END IF

            documentInfo.requireExpDate = targetTabRS("requireExpDate")
            documentInfo.defaultExpDate = targetTabRS("defaultExpDate")
            documentInfo.documentTypeName = targetTabRS("documentTypeName")
            documentInfo.documentSubTypeName = targetTabRS("documentSubTypeName")
        END IF
        targetTabRS.Close


        ' ### find empty document if there is one, create one if not ###
        documentInfo.isNewDocument = false
        IF Trim(documentInfo.documentId & "") = "" THEN
            Dim result : Set result = GetEmptyDocument(documentInfo.documentTabId)
            documentInfo.documentId = result.documentId
            documentInfo.isNewDocument = result.isNewDocument
        END IF

        Call MoveDocumentFromUpload(uploadFolder, documentInfo)

        ' ### Delete the documentUploadId record ###
        CALL DeleteDocumentFingerprint(documentUploadId)   

        SET ProcessQuickMove = documentInfo
    END FUNCTION

    FUNCTION InsertDocumentTabWithDefaults(customerId, loanId, documentDefId)
		Dim sqlCmd
		Dim newTabId
		newTabId = GenerateGuid("documentTab", "documentTabId")
		
		Dim loanClause
		
		if loanId = "" then
			loanClause = " AND dt.loanId IS NULL"
		else
			loanClause = " AND dt.loanId=" & dbFormatId(loanId)
		end if
		
		sqlCmd = _
			" INSERT INTO documentTab (" & _
			"	documentTabId," & _
			"	documentDefId," & _
			"	customerId," & _
			"	loanId," & _
			"	docTabStatusType," & _
			"	docTabHighlightColor" & _
			" )" & _
			" SELECT " & _
			dbFormatId(newTabId) & ", " & _
			dbFormatId(documentDefId) & ", " & _
			dbFormatId(customerId) & ", " & _
			dbFormatId(loanId) & ", " & _
			"	dd.defaultExistingDocumentStatusType, " & _
			"	dd.docDefHighlightColor" & _
			" FROM" & _
			"	 documentDefinitions AS dd LEFT OUTER JOIN documentTab AS dt" & _
			"		ON dt.customerId=" & dbFormatId(customerId) & _
			loanClause & _
			"		AND dd.documentDefId=dt.documentDefId" & _
			" WHERE" & _
			"	dd.documentDefId=" & dbFormatId(documentDefId) & _
			"	AND dt.documentTabId IS NULL"
		
		db.Execute sqlCmd
		
		InsertDocumentTabWithDefaults = newTabId
	END FUNCTION ' InsertDocumentTabWithDefaults()

    '### Returns a DocumentTabId based on the general database arguments provided.
    '###
    '###    dbTable:        The table to lookup the DocumentTabId in.
    '###    dbFieldname:    The fieldname in the table to lookup.
    '###    dbFieldValue:   The field value to match the record lookup
    '###    customerId:     The customerId of the table lookup
    '###    loanId:         The loanId for the table lookup. NOTE: pass as a blank string for credit record lookup.
    '###
    FUNCTION GetDocumentTabIdByGeneralValue(dbTable, dbFieldname, dbFieldValue, customerId, loanId)
        IF (Trim(dbTable & "") = "" OR Trim(dbFieldname & "") = "" OR Trim(dbFieldValue & "") = "") THEN EXIT FUNCTION
        Dim result : result = ""
        Dim DocumentTabSQL : DocumentTabSQL = ""
        Dim DocumentTabRS : Set DocumentTabRS = Server.CreateObject("ADODB.RecordSet")
        IF Trim(loanId & "") <> "" THEN
            DocumentTabSQL = "SELECT documentTabId FROM " & dbTable & " WHERE loanId = " & dbFormatId(loanId) & " AND customerId = " & dbFormatId(customerId) & " AND " & dbFieldname & " = " & dbFormatId(dbFieldValue)
        ELSE
            DocumentTabSQL = "SELECT documentTabId FROM " & dbTable & " WHERE customerId = " & dbFormatId(customerId) & " AND " & dbFieldname & " = " & dbFormatId(dbFieldValue)
        END IF
        DocumentTabRS.Open DocumentTabSQL, db
        IF NOT DocumentTabRS.EOF THEN result = DocumentTabRS("documentTabId")
        DocumentTabRS.Close
        GetDocumentTabIdByGeneralValue = result
    END FUNCTION


    SUB DeleteDocumentFingerprint(documentUploadId)
        IF documentUploadId <> "" THEN
            db.Execute "DELETE FROM documentUpload WHERE documentUploadId=" & dbFormatId(documentUploadId)
        END IF
    END SUB

   SUB MoveDocumentFromUpload(uploadedFileFolder, documentInfo)
        Dim baseFolder      : baseFolder = Replace(RemoveTrailingSlash(Session("serverPath")), "/", "\")
        Dim uploadFolder    : uploadFolder = baseFolder & Replace(uploadedFileFolder, "/", "\")
        Dim imagesFolder    : imagesFolder = Replace(Session("fullpath"), "/", "\")
        Dim srcFilePath     : srcFilePath = uploadFolder & "\" & documentInfo.documentFilename
        Dim dstFilePath     : dstFilepath = TrimTrailingSlash(Replace(imagesFolder & documentInfo.customerFolder, "/", "\"))

        CALL EnsureFolderExists(dstFilePath)

        IF Trim(documentInfo.LoanFolder & "") <> "" THEN
            dstFilePath = dstFilePath & "\" & TrimTrailingSlash(Replace(documentInfo.LoanFolder, "/", "\"))
            CALL EnsureFolderExists(dstFilePath)
        END IF

        dstFilePath = dstFilePath & "\" & TrimTrailingSlash(Replace(documentInfo.tabFolder, "/", "\"))
        CALL EnsureFolderExists(dstFilePath)

        Dim newFilename : newFilename = GetNewFileName(dstFilePath, documentInfo.documentFilename)
        dstFilePath = dstFilePath & "\" & newFilename

        '### TODO: Add errorhandling for potentially locked file or other FileIO error here
        '### copy file to images folder ###
        g_fso.CopyFile srcFilePath, dstFilePath

        Dim sqlQuery : sqlQuery = _
            " UPDATE document SET" & _
            "   documentTitle=" & dbFormatText2(documentInfo.documentTitle,true) & "," & _
            "   modifiedDate=" & dbFormatDate(Now()) & "," & _
            "   expDate=" & dbFormatDate2(documentInfo.documentExpDate,true) & "," & _
            "   loanFile=" & dbFormatText(documentInfo.tabFolder) & "," & _
            "   filename=" & dbFormatText(newFilename) & "," & _
            "   documentComment=" & dbFormatText2(documentInfo.documentComment,true) & "," & _
            "   documentStatus=1" & _
            " WHERE" & _
            "   documentId=" & dbFormatId(documentInfo.documentId)
        db.Execute sqlQuery

  		'### Delete upload file ###	
		g_fso.DeleteFile srcFilePath, true

        documentInfo.documentFilename = newFilename
    END SUB

    Class DocumentProjection
        '### Customer projections
        Public customerId
        Public customerName
        Public customerNumber
        Public customerFolder

        '### Account and collateral projections
        Public loanId
        Public loanNumber
        Public loanFolder
        Public isCollateralYN
        Public collateralLoanId

        '### Document projections
        Public documentId
        Public documentTabId
        Public documentTypeId
        Public documentSubTypeId
        Public documentDefId
        Public documentTypeName
        Public documentSubTypeName
        Public tabFolder
        Public documentFilename
        Public documentTitle
        Public documentComment
        Public requireExpDate
        Public defaultExpDate
        Public documentExpDate
       
        '### Status flags
        Public actionSuccessful
        Public errorMessage
        Public isNewDocument
    End Class

    Class EmptyDocumentResult
        Public documentId
        Public isNewDocument
    End Class
%>