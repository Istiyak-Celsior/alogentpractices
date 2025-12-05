<%
	'-------------------------------------------------------------------------
	'	Sub:	ProcessLoanRenewalAction
	'	
	'-------------------------------------------------------------------------
	Sub ProcessLoanRenewalAction( srcLoanId, dstLoanId, theNewLoanTypeId)
		logTa(9) = now()
		logTlabel(9) = "[movecopyloan.asp][ProcessLoanRenewalAction] Total Time to process Loan Renewal"
		if CStr(targetLoanTypeId) <> CStr(theNewLoanTypeId) then
			ChangeLoanType dstLoanId, theNewLoanTypeId
		end if
		
		ProcessRenewalDocuments srcLoanId, dstLoanId, theNewLoanTypeId, "L"

		logTb(9) = now()
		logTdelta(9) = calculateDelta( logTa(9), logTb(9))
		writeDebugLog logTlabel(9)
		writeDebugLog "    Time: " & logTdelta(9) & " seconds."
	End Sub ' ProcessLoanRenewalAction()
	
	
	'-------------------------------------------------------------------------
	'	Sub:	ProcessRenewalDocuments
	'	
	'-------------------------------------------------------------------------
	Sub ProcessRenewalDocuments( srcLoanId, targetId, targetTypeId, targetType)
logTa(8) = now()
		response.write "[movecopyloan.asp] ProcessRenewalDocuments()...<br><br>"
		
		Dim moveTargetDocumentDefId
		Set moveTargetDocumentDefId = Request("moveTargetDocumentDefId")
		
		Dim moveDocumentTabId
		Set moveDocumentTabId		= Request("moveDocumentTabId")
		
		Dim moveDocumentId
		Set moveDocumentId			= Request("moveDocumentId")
		
		Dim i
		Dim firstTime : firstTime = true

		for i = 1 to moveDocumentId.Count
			if moveTargetDocumentDefId(i) <> "" then
				response.write "moveTargetDocumentDefId(" & i & "): " & moveTargetDocumentDefId(i) & "<br>"
				CopyRenewalDocument srcLoanId, targetId, moveDocumentId(i), moveDocumentTabId(i), moveTargetDocumentDefId(i), firstTime
                firstTime = false
			end if
		next
		
		logTb(8) = now()
		logTdelta(8) = calculateDelta( logTa(8), logTb(8))
		logTlabel(8) = "[movecopyloan.asp][ProcessRenewalDocuments] Total time to process Renwal Documents "
		writeDebugLog logTlabel(8)
		writeDebugLog "    Time: " & logTdelta(8) & " seconds."

        ProcessComments srcLoanId, targetId
	End Sub ' ProcessRenewalDocuments()


	'-------------------------------------------------------------------------
	'	Sub:	ProcessComments
	'   Comment: Copy Comments from one Loan to Another
	'-------------------------------------------------------------------------
	Sub ProcessComments(sourceLoanId, targetLoanId)
        Dim srcCommentQuery, srcCommentRS
        Set srcCommentRS = Server.CreateObject("ADODB.RecordSet")
        srcCommentQuery= _
            " Insert into loanComments (loanid, userid, commentDate, comment) " &_
            " select top 100 " &_
            " '" & targetLoanId & "', userid, commentDate, comment from loanComments where loanid='" & sourceLoanId & "'"
            response.write "[movecopyloan.asp ProcessComments] srcCommentQuery =<Br>" & srcCommentQuery & "<br><br>"
		    srcCommentRS.Open srcCommentQuery, db, adOpenStatic, adCmdText
            'srcCommentRS.Close
End Sub ' ProcessComments()
	
	
	'-------------------------------------------------------------------------
	'	Sub:	CopyRenewalDocument
	'	
	'-------------------------------------------------------------------------
	Sub CopyRenewalDocument(srcLoanId, dstLoanId, srcDocumentId, srcDocumentTabId, targetDocumentDefId, firstTime)
logTa(7) = now()
		Dim srcCustomerId, srcCustomerName, srcCustomerNumber, srcCustomerFolder, srcLoanNumber, srcLoanFolder
		Dim srcDocumentTypeName, srcDocumentSubTypeName
		Dim srcTabFolder, srcFilename, srcFilePath
		
		Dim dstCustomerId, dstCustomerName, dstCustomerNumber, dstCustomerFolder, dstLoanNumber, dstLoanFolder
		Dim dstTabFolder, dstFilename, dstFilePath, dstDocumentTypeName, dstDocumentSubTypeName
		Dim dstDocumentTabId, dstDocumentId, dstDocumentCount, dstActiveDocumentCount
		
		' Get Source customer/loan folder information
		'
		Dim srcDocumentQuery, srcDocumentRS
		Set srcDocumentRS = Server.CreateObject("ADODB.RecordSet")
		srcDocumentQuery = _ 
			" SELECT " & _
			"	c.customerId," & _
			"	c.customerNumber," & _
			"	c.customerName," & _
			"	c.customerFolder," & _
			"	l.loanId," & _
			"	l.loanNumber," & _
			"	l.loanFolder," & _
			"	l.IsCollateralYN," & _
			"	dt.documentTabId," & _
			"	dd.documentDefId," & _
			"	dd.documentTypeId," & _
			"	dd.documentSubTypeId, " & _
			"	dtype.documentTypeName," & _
			"	dstype.documentSubTypeName," & _
			"	d.loanFile," & _
			"	d.filename," & _
			"	d.documentTitle" & _
			" FROM" & _
			"	customer AS c INNER JOIN loan AS l" & _
			"		ON c.customerId=l.customerId" & _
			"	INNER JOIN documentTab AS dt" & _
			"		ON dt.loanId=l.loanId" & _
			"	INNER JOIN documentDefinitions AS dd" & _
			"		ON dd.documentDefId=dt.documentDefId AND dd.loanTypeId=l.loanTypeId AND dd.bankId=c.bankId" & _
			"	INNER JOIN documentType AS dtype" & _
			"		ON dtype.documentTypeId=dd.documentTypeId" & _
			"	INNER JOIN documentSubType AS dstype" & _
			"		ON dstype.documentSubTypeId=dd.documentSubTypeId AND dstype.documentTypeId=dd.documentTypeId" & _
			"	INNER JOIN document AS d" & _
			"		ON d.documentTabId=dt.documentTabId AND d.documentId=" & dbFormatId(srcDocumentId) & _
			" WHERE" & _
			"	l.loanId=" & dbformatId(srcLoanId)
		response.write "[movecopyloan.asp CopyRenewalDocument] srcDocumentQuery =<Br>" & srcDocumentQuery & "<br><br>"
		srcDocumentRS.Open srcDocumentQuery, db, adOpenStatic, adCmdText
		
		' Get customer/loan/document related information
		'
		if Not srcDocumentRS.eof then
			
			srcCustomerId = srcDocumentRS("customerId")
			srcCustomerNumber = srcDocumentRS("customerNumber")
			srcLoanNumber = srcDocumentRS("loanNumber")
			srcIsCollateralYN = srcDocumentRS("IsCollateralYN")
			srcDocumentTypeName = srcDocumentRS("documentTypeName")
			srcDocumentSubTypeName = srcDocumentRS("documentSubTypeName")
			
			' Get Folder/File related information
			'
			srcCustomerFolder = srcDocumentRS("customerFolder")
			srcLoanFolder = srcDocumentRS("loanFolder")
			srcTabFolder = srcDocumentRS("loanFile")
			srcFilename = srcDocumentRS("filename")

            ' Build document history for source documents that are being moved ---begin
            '-------------------------------------------------------------------------
            ' builds a SQL INSERT string to add a history record to
            ' the document history table for the move/copy for each document processed			
            '-------------------------------------------------------------------------		

            insertCmd  = ""
            IF UCase(ActionType) = "MOVE" THEN
                actionLabel = "moved to"

                IF srcLoanNumber <> "" AND UCase(dstIsCollateralYN) = "Y" THEN
                    functionLabel = "move loan function"
                    targetLabel = dstLoanNumber
                    targetTypeLabel = "Customer Number [" & dstCustomerNumber & "], Collateral Number [" & targetLabel & "]"
                ELSEIF srcLoanNumber <> "" AND UCase(dstIsCollateralYN) = "N" THEN
                    functionLabel = "move loan function"
                    targetLabel = dstLoanNumber
                    targetTypeLabel = "Customer Number [" & dstCustomerNumber & "], Loan Number [" & targetLabel & "]"
                ELSE
                    functionLabel = "move credit files function"
                    targetLabel = dstCustomerNumber
                    targetTypeLabel = "Customer Number [" & targetLabel & "]"
                END IF

                ' ### Build historyText comment. ###
                historyText = _
                	"Document has been <b>" & actionLabel & "</b> " & targetTypeLabel & " by user [" & Session("userName") & "] via the " & functionLabel & "."

                ' ### Build document history for the source document indicating it's been moved to another customer/loan. ###
                insertCmd = _
                    " INSERT INTO documentHistory" & _
                    " (" & _
                    "   userLogin," & _
                    "   userName," & _
                    "   customerNumber," & _
                    "   loanNumber," & _
                    "   documentFileName," & _
                    "   documentType," & _
                    "   pagesAdded," & _
                    "   pagesDeleted," & _
                    "   dateChanged," & _
                    "   documentDeletedYN," & _
                    "   documentId," & _
                    "   inputType," & _
                    "   comment" & _
                    " )" & _
                    " VALUES" & _
                    " (" & _
                    dbFormatText(Session("userLogin")) & "," & _
                    dbFormatText(Session("userName")) & "," & _
                    dbFormatText(srcCustomerNumber) & "," & _
                    dbFormatText(srcLoanNumber) & "," & _
                    dbFormatText(srcFilename) & "," & _
                    dbFormatText(srcDocumentTypeName & ": " & srcDocumentSubTypeName) & "," & _
                    " 0," & _
                    " 0," & _
                    dbFormatDate(Now()) & "," & _
                    dbFormatText("N") & "," & _
                    dbFormatId(srcDocumentId) & "," & _
                    inputTypeId & "," & _
                    dbFormatText(historyText) & _
                    " )"
            END IF
            ' ### END :: Build document history for source documents that are being moved ###
        ELSE
            srcDocumentRS.Close
            EXIT SUB
        END IF
        srcDocumentRS.Close

		' If there are any documentHistory changes then execute them
		if insertCmd <> "" then
		'	  response.write "ActionType:" & ActionType & "<br>"
		'		response.write "source insertCmd:<br>"& insertCmd &"<br><br>"		
				db.Execute insertCmd
		end if
		
		' Get destination customer/loan folder information
		'
		Dim dstDocumentQuery, dstDocumentRS
		Set dstDocumentRS = Server.CreateObject("ADODB.RecordSet")
		dstDocumentQuery = _
			" SELECT" & _
			"	c.customerId," & _
			"	c.customerNumber," & _
			"	c.customerName," & _
			"	c.customerFolder," & _
			"	l.loanId," & _
			"	l.loanNumber," & _
			"	l.loanFolder," & _
			"	dt.documentTabId," & _
			"	dd.documentDefId," & _
			"	dd.documentTypeId," & _
			"	dd.documentSubTypeId," & _
			"	dtype.documentTypeName," & _
			"	dstype.documentSubTypeName," & _
			"	dd.defaultName," & _
			"	(SELECT COUNT(*) FROM document WHERE documentTabId=dt.documentTabId) AS documentCount," & _
			"	(SELECT COUNT(*) FROM document WHERE documentStatus=1 AND documentTabId=dt.documentTabId) AS activeDocumentCount" & _
			" FROM" & _
			"	customer AS c INNER JOIN loan AS l" & _
			"		ON c.customerId=l.customerId" & _
			"	INNER JOIN documentDefinitions AS dd" & _
			"		ON dd.loanTypeId=l.loanTypeId" & _
			"		AND dd.bankId=c.bankId" & _
			"	INNER JOIN documentType AS dtype" & _
			"		ON dtype.documentTypeId=dd.documentTypeId" & _
			"	INNER JOIN documentSubType AS dstype" & _
			"		ON dstype.documentSubTypeId=dd.documentSubTypeId AND dstype.documentTypeId=dd.documentTypeId" & _
			"	LEFT OUTER JOIN documentTab AS dt" & _
			"		ON dt.loanId=l.loanId" & _
			"		AND dt.documentDefId=dd.documentDefId" & _
			" WHERE" & _
			"	l.loanId=" & dbFormatId(dstLoanId) & _
			"	AND dd.documentDefId=" & dbFormatId(targetDocumentDefId)
		response.write "[movecopyloan.asp CopyRenewalDocument] dstDocumentQuery =<Br>" & dstDocumentQuery & "<br><br>"
		dstDocumentRS.Open dstDocumentQuery, db, adOpenStatic, adCmdText

		' Get customer/loan/tab information
		'
		dstCustomerId = dstDocumentRS("customerId")
		dstCustomerName = dstDocumentRS("customerName")
		dstCustomerNumber = dstDocumentRS("customerNumber")
		dstLoanNumber = dstDocumentRS("loanNumber")
		dstDocumentTabId = CheckForNull(dstDocumentRS("documentTabId"))
		dstDocumentDefId = dstDocumentRS("documentDefId")
		dstDocumentTypeId = dstDocumentRS("documentTypeId")
		dstDocumentSubTypeId = dstDocumentRS("documentSubTypeId")
		dstDocumentCount = CInt(dstDocumentRS("documentCount"))
		dstActiveDocumentCount = CInt(dstDocumentRS("activedocumentCount"))
		dstDocumentTypeName = dstDocumentRS("documentTypeName")
		dstDocumentSubTypeName = dstDocumentRS("documentSubTypeName")
		
		' Get folder information
		'
		dstCustomerFolder = dstDocumentRS("customerFolder")
		dstLoanFolder = dstDocumentRS("loanFolder")
		dstTabFolder = dstDocumentRS("defaultName")
				
		dstDocumentRS.Close	
		
		' If the destination documentTabId does not exist, then
		' create it.
		'
		if dstDocumentTabId = "" then
			' NOTE: AddMissingDocumentTab() is located in the include/chagetypefunctions.asp file
			'
			dstDocumentTabId = AddMissingDocumentTab(dstLoanId, "L", dstDocumentDefId)
		end if
		



	    
		' If there is only one document record with no existing files
		' then delete it as it will be replaced with the copied renewal document
		'
        IF firstTime AND dstDocumentCount = 1 AND dstActiveDocumentCount = 0 THEN
            ' Get the destination document to copy the information into.
            Dim query : query = _
                " SELECT documentId" & _
                " FROM document" & _
			    " WHERE" & _
			    "	loanId=" & dbFormatId(dstLoanId) & _
			    "	AND documentDefId=" & dbFormatId(targetDocumentDefId)
            Dim docRS : Set docRS = Server.CreateObject("ADODB.RecordSet")
            docRS.Open query, db
            IF NOT docRS.EOF THEN
                dstDocumentId = docRS("documentId")
            END IF
            docRS.Close

            IF dstDocumentId <> "" THEN
                'Copy source document information to destination document record.
                query = _
                    " UPDATE document SET" & _
                    "   documentDescription = src.documentDescription," & _
                    "   loanFile = src.loanFile," & _
                    "   filename = src.filename," & _
                    "   documentStatus = src.documentStatus," & _
                    "   origDate = src.origDate," & _
                    "   modifiedDate = " & dbFormatDate(NOW()) & "," & _
                    "   expDate = src.expDate," & _
                    "   email = src.email," & _
                    "   documentStatusType = src.documentStatusType," & _
                    "   documentComment = src.documentComment," & _
                    "   documentTitle = src.documentTitle," & _
                    "   documentHighlightColor = src.documentHighlightColor," & _
                    "   nonExpiring = src.nonExpiring," & _
                    "   PurgeStatus = src.PurgeStatus," & _
                    "   PurgeStatusLocked = src.PurgeStatusLocked," & _
                    "   BlockParticipation = src.BlockParticipation," & _
                    "   LastPushDate = src.LastPushDate," & _
                    "   BlockPDFBookmarking = src.BlockPDFBookmarking," & _
                    "   BlockPDFConversion = src.BlockPDFConversion," & _
                    "   BookmarkPDF = src.BookmarkPDF," & _
                    "   BlockPDFIndexing = src.BlockPDFIndexing," & _
                    "   IndexPDF = src.IndexPDf" & _
                    " FROM" & _
                    "   document CROSS JOIN document AS src" & _
                    " WHERE" & _
                    "   document.documentId=" & dbFormatId(dstDocumentId) & _
                    "   AND src.documentId=" & dbFormatId(srcDocumentId)
                db.Execute query

                Call AddDocumentAuditHistoryRecord(dstDocumentId, "Modified", "Document modified during Copying of Account Documents", Session("userLogin"))
            END IF
        ELSE
	        ' Clone the source document
	        response.write "Cloning document...<br>"
	        response.write "srcDocumentId = " & srcDocumentId & "<br>"
	        response.write "dstCustomerId = " & dstCustomerId & "<br>"
	        response.write "dstLoanId = " & dstLoanId & "<br>"
	        response.write "dstDocumentTabId = " & dstDocumentTabId & "<br>"
	        response.write "dstDocumentDefId = " & dstDocumentDefId & "<br>"
            
            dstDocumentId = CloneDocumentRecord(srcDocumentId, dstCustomerId, dstLoanId, dstDocumentTabId, dstDocumentDefId, dstDocumentTypeId, dstDocumentSubTypeId)	
            
            response.write "dstDocumentId = " & dstDocumentId & "<br>"
	        response.write "source Tab = " & srcDocumentTypeName & " : " & Server.HTMLEncode(srcDocumentSubTypeName) & "<br>"
	        response.write "dst Tab = " & dstDocumentTypeName & " : " & Server.HTMLEncode(dstDocumentSubTypeName) & "<br><br>"
        END IF

	    '-------------------------------------------------------------------------
	    ' Build document history for destination documents ---begin
        '-------------------------------------------------------------------------

        insertCmd = ""

        ' ### Build historyText for destination document's comment. ###
        Dim thisAction : thisAction = "move"
        IF actionType = "MOVE" THEN
            actionLabel = "moved from"
        ELSE
            actionLabel = "copied from"
            thisAction = "copy"
        END IF

        Response.Write "srcLoanNumber = " & srcLoanNumber & "<br/>"
        Response.Write "srcIsCollateralYN = " & srcIsCollateralYN & "<br/>"

        IF srcLoanNumber <> "" AND UCase(srcIsCollateralYN) = "Y" THEN
            functionLabel = thisAction & " loan function"
            targetLabel = srcLoanNumber
            targetTypeLabel = "Customer Number [" & srcCustomerNumber & "], Collateral Number [" & targetLabel & "]" 
        ELSEIF srcLoanNumber <> "" AND uCase(srcIsCollateralYN) = "N" THEN
            functionLabel = thisAction & " loan function"
            targetLabel = srcLoanNumber
            targetTypeLabel = "Customer Number [" & srcCustomerNumber & "], Loan Number [" & targetLabel & "]"
        ELSE
            functionLabel = thisAction & " credit files function"
            targetLabel = srcCustomerNumber
            targetTypeLabel = "Customer Number [" & targetLabel & "]"
        END IF

        ' ### Build historyText comment. ###
        historyText = _
            "Document has been <b>" & actionLabel & "</b> " & targetTypeLabel & " by user [" & Session("userName") & "] via the " & functionLabel & "."

        Response.Write "historyText = " & historyText & "<br/>"

        ' ### Build documentHistory for destination documents ###
        insertCmd = insertCmd & _
            " INSERT INTO documentHistory" & _
            " (" & _
            "   userLogin," & _
            "   userName," & _
            "   customerNumber," & _
            "   loanNumber," & _
            "   documentFileName," & _
            "   documentType," & _
            "   pagesAdded," & _
            "   pagesDeleted," & _
            "   dateChanged," & _
            "   documentDeletedYN," & _
            "   documentId," & _
            "   inputType," & _
            "   comment" & _
            " )" & _
            " VALUES" & _
            " (" & _
            dbFormatText(Session("userLogin")) & "," & _
            dbFormatText(Session("userName")) & "," & _
            dbFormatText(dstCustomerNumber) & "," & _
            dbFormatText(dstLoanNumber) & "," & _
            dbFormatText(dstFilename) & "," & _
            dbFormatText(dstDocumentTypeName & ": " & dstDocumentSubTypeName) & "," & _
            " 0," & _
            " 0," & _
            dbFormatDate(Now()) & "," & _
            dbFormatText("N") & "," & _
            dbFormatId(dstDocumentId) & "," & _
            inputTypeId & "," & _
            dbFormatText(historyText) & _
            " )"

        ' ### If there are any documentHistory changes then execute them ###
        IF insertCmd <> "" THEN
            ' response.write "dest insertCmd:<br>"& insertCmd &"<br><br>"
            db.Execute insertCmd
        END IF

        '-------------------------------------------------------------------------
        ' Build document history for destination documents ---end
        '-------------------------------------------------------------------------							 							
		
		' Build path to source file
		'
		srcFilePath = Session("fullpath") & srcCustomerFolder & srcLoanFolder & srcTabFolder & "\" & srcFilename
		
		
		' Copy the source file
		'
		MoveCopyFile srcFilePath, dstCustomerFolder, dstLoanFolder, dstTabFolder, srcFilename, "copy"
		
		' Update documentTab and definition references for the document Record.
		'
		sqlCmd = _
			" UPDATE document SET" & _
			"	documentTabId=" & dbFormatId(dstDocumentTabId) & "," & _
			"	documentDefId=" & dbFormatId(dstDocumentDefId) & "," & _
			"	documentTypeId=" & dbFormatId(dstDocumentTypeId) & "," & _
			"	documentSubTypeId=" & dbFormatId(dstDocumentSubTypeId) & _
			" WHERE" & _
			"	documentId=" & dbFormatId(dstDocumentId) & ";" 
		'response.write "[movecopyloan.asp CopyRenewalDocument] update document references =<br>" & sqlCmd & "<br><br>"
		'db.Execute sqlCmd
		
	    logTb(7) = now()
	    logTdelta(7) = calculateDelta( logTa(7), logTb(7))
	    logTlabel(7) = "[movecopyloan.asp][CopyRenewalDocument] Total time in CopyRenewalDocument"
	    writeDebugLog logTlabel(7)
	    writeDebugLog "    Time: " & logTdelta(7) & " seconds."
    End Sub ' CopyRenewalDocument()

	'-------------------------------------------------------------------------
	'	FUNCTION:	CloneDocumentRecord
	'	
	'	
	'-------------------------------------------------------------------------
	Function CloneDocumentRecord(srcDocumentId, dstCustomerId, dstLoanId, dstTabId, dstDocumentDefId, dstDocumentTypeId, dstDocumentSubTypeId)
logTa(6) = now()
		Dim srcDocumentQuery, srcDocumentRS
		Set srcDocumentRS = Server.CreateObject("ADODB.RecordSet")
		
		Dim dstDocumentDefQuery, dstDocumentDefRS
		Set dstDocumentDefRS = Server.CreateObject("ADODB.RecordSet")
		
		srcDocumentQuery = "SELECT * FROM document WHERE documentId=" & dbFormatId(srcDocumentId)
		srcDocumentRS.Open srcDocumentQuery, db, adOpenStatic, adCmdText
		
		dstDocumentDefQuery = "SELECT * FROM documentDefinitions WHERE documentDefId=" & dbFormatId(dstDocumentDefId)
		dstDocumentDefRS.Open dstDocumentDefQuery, db, adOpenStatic, adCmdText
		
		' Generate a new documentId for INSERT.
		'
		Dim newDocumentId
		newDocumentId = GenerateGuid( "document", "documentId")
		
		Dim nonExpiring
		if CheckForNull(srcDocumentRS("nonExpiring")) = "" then
			nonExpiring = ""
		elseif srcDocumentRS("nonExpiring") then
			nonExpiring = 1
		else
			nonExpiring = 0
		end if
		
		Dim sqlCmd
		sqlCmd = _
			" INSERT INTO document" & _
			" (" & _
			"	documentId," & _
			"	customerId," & _
			"	loanId," & _
			"	documentTypeId," & _
			"	documentSubTypeId," & _
			"	documentDefId," & _
			"	documentTabId," & _
			"	loanFile," & _
			"	filename," & _
			"	documentStatus," & _
			"	documentStatusType," & _
			"	documentTitle," & _
			"	documentDescription," & _
			"	documentComment," & _
			"	email," & _
			"	origDate," & _
			"	modifiedDate," & _
			"	expDate," & _
			"	nonExpiring," & _
			"	documentHighlightColor" & _
			" )" & _
			" VALUES" & _
			" (" & _
			dbFormatId2(newDocumentId, false) & "," & _
			dbFormatId2(dstCustomerId, false) & "," & _
			dbFormatId2(dstLoanId, true) & "," & _
			dbFormatId2(dstDocumentTypeId, false) & "," & _
			dbFormatId2(dstDocumentSubTypeId, false) & "," & _
			dbFormatId2(dstDocumentDefId, false) & "," & _
			dbFormatId2(dstTabId, false) & "," & _
			dbFormatText2(dstDocumentDefRS("defaultName"), true) & "," & _
			dbFormatText2(srcDocumentRS("filename"), true) & "," & _
			dbFormatNumeric2(srcDocumentRS("documentStatus"), true) & "," & _
			dbFormatNumeric2(srcDocumentRS("documentStatusType"), true) & "," & _
			dbFormatText2(srcDocumentRS("documentTitle"), false) & "," & _
			dbFormatText2(srcDocumentRS("documentDescription"), true) & "," & _
			dbFormatText2(srcDocumentRS("documentComment"), true) & "," & _
			dbFormatText2(srcDocumentRS("email"), true) & "," & _
			dbFormatDate2(srcDocumentRS("origDate"), true) & "," & _
			dbFormatDate2(Now(), true) & "," & _
			dbFormatDate2(srcDocumentRS("expDate"), true) & "," & _
			dbFormatNumeric2(nonExpiring, true) & "," & _
			dbFormatText(srcDocumentRS("documentHighlightColor")) & _
			" );"
		db.Execute sqlCmd

        Call AddDocumentAuditHistoryRecord(newDocumentId, "Created", "Document Created during Copying of Account Documents", Session("userLogin"))
		
		' Close Record sets
		'
		dstDocumentDefRS.Close
		srcDocumentRS.Close
		

logTb(6) = now()
logTdelta(6) = calculateDelta( logTa(6), logTb(6))
logTlabel(6) = "[movecopyloan.asp][CloneDocumentRecord] Total Time to Clone document record"
writeDebugLog logTlabel(6)
writeDebugLog "    Time: " & logTdelta(6) & " seconds."
		CloneDocumentRecord = newDocumentId
	End Function ' CloneDocumentRecord
	
	
	
	'-------------------------------------------------------------------------
	'	Sub:	CopyDocumentRecord
	'	
	'	
	'-------------------------------------------------------------------------
	Sub CopyDocumentRecord(srcDocumentId, dstDocumentId)
logTa(5) = now()
		' Open source document for reading
		'
		Dim srcDocumentQuery, srcDocumentRS
		Set srcDocumentRS = Server.CreateObject("ADODB.RecordSet")
		
		srcDocumentQuery = "SELECT * FROM document WHERE documentId=" & dbFormatId(srcDocumentId)
		srcDocumentRS.Open srcDocumentQuery, db, adOpenStatic, adCmdText
		
		' Open destination document for editing
		'
		Dim dstDocumentQuery, dstDocumentRS
		Set dstDocumentRS = Server.CreateObject("ADODB.RecordSet")
		
		dstDocumentQuery = "SELECT * FROM document WHERE documentId=" & dbFormatId(dstDocumentId)
		dstDocumentRS.Open dstDocumentQuery, db, adOpenKeySet, adLockPessimistic, adCmdText
		response.write "[CopyDocumentRecord] dstDocumentQuery = <br>" & dstDocumentQuery & "<br><br>"
		
		dstDocumentRS("documentTypeId") = srcDocumentRS("documentTypeId")
		dstDocumentRS("documentSubTypeId") = srcDocumentRS("documentSubTypeId")
		dstDocumentRS("documentDescription") = srcDocumentRS("documentDescription")
		dstDocumentRS("loanFile") = srcDocumentRS("loanFile")
		dstDocumentRS("filename") = srcDocumentRS("filename")
		dstDocumentRS("documentStatus") = srcDocumentRS("documentStatus")
		dstDocumentRS("origDate") = srcDocumentRS("origDate")
		dstDocumentRS("modifiedDate") = NOW()
		dstDocumentRS("expDate") = srcDocumentRS("expDate")
		dstDocumentRS("email") = srcDocumentRS("email")
		dstDocumentRS("documentStatusType") = srcDocumentRS("documentStatusType")
		dstDocumentRS("documentComment") = srcDocumentRS("documentComment")
		dstDocumentRS("documentDefId") = srcDocumentRS("documentDefId")
		dstDocumentRS("documentTitle") = srcDocumentRS("documentTitle")
		dstDocumentRS("documentHighlightColor") = srcDocumentRS("documentHighlightColor")
		dstDocumentRS("nonExpiring") = srcDocumentRS("nonExpiring")
		
		' Update new document and get the documentId to return
		'
		dstDocumentRS.Update
		
		srcDocumentRS.Close
		dstDocumentRS.Close

logTb(5) = now()
logTdelta(5) = calculateDelta( logTa(5), logTb(5))
logTlabel(5) = "[movecopyloan.asp][CopyDocumentRecord] Total Time to Copy Document Record"
writeDebugLog logTlabel(5)
writeDebugLog "    Time: " & logTdelta(5) & " seconds."
	End Sub ' CopyDocumentRecord
	
	
	'-------------------------------------------------------------------------
	'	Sub:	MoveCopyFile
	'	
	'	
	'-------------------------------------------------------------------------
	Sub MoveCopyFile(srcFilePath, dstCustomerFolder, dstLoanFolder, dstTabFolder, dstFilename, action)
logTa(4) = now()
		
		
		' Ensure destination path exists
		'
		Dim dstImageFolder
		
		dstImageFolder = Replace(Session("fullpath"), "/", "\")
		if Not fso.FolderExists(dstImageFolder) then
			fso.CreateFolder(dstImageFolder)
		end if
		
		dstImageFolder = dstImageFolder & Replace(dstCustomerFolder, "/", "\")
		if Not fso.FolderExists(dstImageFolder) then
			fso.CreateFolder(dstImageFolder)
		end if
		
		dstImageFolder = dstImageFolder & Replace(dstLoanFolder, "/", "\")
		if Not fso.FolderExists(dstImageFolder) then
			fso.CreateFolder(dstImageFolder)
		end if
		
		dstImageFolder = dstImageFolder & Replace(dstTabFolder, "/", "\")
		if Not fso.FolderExists(dstImageFolder) then
			fso.CreateFolder(dstImageFolder)
		end if
		
		if action = "move" then
			if fso.FileExists(srcFilePath) then
				response.write "[MoveCopyFile] fso.MoveFile " & srcFilePath & ", " & dstImageFolder & "\" & dstFilename & "<br><br>"
				fso.MoveFile srcFilePath, dstImageFolder & "\" & dstFilename
			end if
		else
			if fso.FileExists(srcFilePath) then
				response.write "[MoveCopyFile] fso.CopyFile " & srcFilePath & ", " & dstImageFolder & "\" & dstFilename & "<br><br>"
				fso.CopyFile srcFilePath, dstImageFolder & "\" & dstFilename
			end if
		end if
		
logTb(4) = now()
logTdelta(4) = calculateDelta( logTa(4), logTb(4))
logTlabel(4) = "[movecopyloan.asp][MoveCopyFile] Total time in MoveCopyFile"
writeDebugLog logTlabel(4)
writeDebugLog "    Time: " & logTdelta(4) & " seconds."
	End Sub 'MoveCopyFile()
	
	
%>