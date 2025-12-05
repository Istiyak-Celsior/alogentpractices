<%	

'-------------------------------------------------------------------------
'   Sub: ChangeCustomerType
'
'   Changes a customer to a new customerTypeId
'-------------------------------------------------------------------------
SUB ChangeCustomerType(theCustomerId, theNewCustomerTypeId)
    changeOfTypeTarget = "Customer"

    ' ### Step 1: Establish if folder is blocked ###
    Dim folderPath : folderPath = ""
    Dim pathRS : Set pathRS = Server.CreateObject("ADODB.RecordSet")
    Dim pathQuery : pathQuery = _
        " SELECT customerFolder AS folderPath" & _
        " FROM customer " & _
        " WHERE customerId = " & dbFormatId(theCustomerId)
    pathRS.Open pathQuery, db
    IF NOT pathRS.EOF THEN
        folderPath = Trim(TrimLeadingSlash(pathRS("folderPath")))
    END IF
    pathRS.Close

    IF IsFolderBlocked(folderPath) THEN
        Response.Clear
        Response.Redirect "CustomerChangeError.asp"
    END IF

    ' ### Step 2: Refactor shared document tab references ###
    Call RefactorSharedDocumentTabs(theCustomerId, theNewCustomerTypeId, "C")

    ' ### Step 3: Change the customer's customerType ###
    Dim sqlCmd : sqlCmd = _
        " UPDATE customer SET" & _
        "   customerTypeId = " & dbFormatId(theNewCustomerTypeId) & _
        " WHERE" & _
        "   customerId = " & dbFormatId(theCustomerId)
    db.Execute sqlCmd

    ' ### Step 4: Process orphan documents ###
    Call ProcessOrphanDocuments(theCustomerId, theNewCustomerTypeId, "C")

    ' ### Step 5: Remove any unused documents based on tabs removed ###
    sqlCmd = "EXEC spDeleteUnusedCreditDocuments " & dbFormatId(theCustomerId) & ";"
    db.Execute sqlCmd

    ' ### Step 6: Remove unused tabs ###
    sqlCmd = "EXEC spDeleteUnusedCreditDocumentTabs " & dbFormatId(theCustomerId) & ";"
    db.Execute sqlCmd

    ' ### Step 7: Call addMissingDocuments to insert any new documents that might have a different
    ' default NewStatustype vs ExistingStatusType ###
    sqlCmd = "EXEC spAddNewCreditDocuments " & dbFormatId(theCustomerId) & ";"
    db.Execute sqlCmd

    ' ### Step 8: Call spDeleteUnusedCreditExceptions in order to delete exceptions from previous Customer Type
    ' Before deleting the unused exceptions based on customerType, custom Task exceptions need to be
    ' refactored to the new customerTypeId as they are retained. ###
    sqlCmd = _
        " UPDATE exceptionDefinition SET" & _
        "   customerTypeId = " & dbFormatId(theNewCustomerTypeId) & _
        " FROM" & _
        "   exceptionDefinition INNER JOIN customer AS c" & _
        "       ON exceptionDefinition.customCustomerId = c.customerId" & _
        " WHERE" & _
        "   c.customerId = " & dbFormatId(theCustomerId) & _
        "   AND exceptionDefinition.exceptionDefType = 'custom'" & _
        "   AND exceptionDefinition.computationType = 'manual'" & _
        "   AND exceptionDefinition.customerTypeId <> c.customerTypeId;"
    db.Execute sqlCmd

    sqlCmd = "EXEC spDeleteUnusedCreditExceptions 'C', " & dbFormatId(theCustomerId) & ";"
    db.Execute sqlCmd

    ' ### Step 9: Call spAddMissingCreditExceptions To create new Exceptions based on the new Customer Type ###
    sqlCmd = "EXEC spAddMissingCreditExceptions 'C', " & dbFormatId(theCustomerId) & ";"
    db.Execute sqlCmd

    Call ProcessDocumentAuditHistories(documentAuditHistoryArray)
END SUB

'-------------------------------------------------------------------------
'   Sub: ChangeLoanType
'
'   Changes a customer to a new customerTypeId
'-------------------------------------------------------------------------
SUB ChangeLoanType(theLoanId, theNewLoanTypeId)
    changeOfTypeTarget = "Account"

    ' ### Step 0: Get infomraiton for Audit tracking
    Dim customerNumber, accountNumber, oldAccountType, newAccountType
    Dim auditRS : Set auditRS = Server.CreateObject("ADODB.RecordSet")
    Dim auditQuery : auditQuery = _
        "SELECT customerNumber, loanNumber, loanTypeDescription" & _
        " FROM" & _
        "   customer AS c INNER JOIN loan AS l" & _
        "       ON c.customerId=l.customerId" & _
        "   INNER JOIN loanType AS lt" & _
        "       ON lt.loanTypeId=l.loanTypeId" & _
        "   WHERE l.loanId=" & dbFormatId(theLoanId)
    auditRS.Open auditQuery, db
    IF NOT auditRS.EOF THEN
        customerNumber = auditRS("customerNumber")
        accountNumber = auditRS("loanNumber")
        oldAccountType = auditRS("loanTypeDescription")
    END IF
    auditRS.Close

    auditQuery = "SELECT loanTypeDescription FROM loanType WHERE loanTypeId=" & dbFormatId(theNewLoanTypeId)
    auditRS.Open auditQuery, db
    IF NOT auditRS.EOF THEN
        newAccountType = auditRS("loanTypeDescription")
    END IF
    auditRS.Close

    ' ### Step 1: Establish if folder is blocked ###
    Dim folderPath : folderPath = ""
    Dim pathRS : Set pathRS = Server.CreateObject("ADODB.RecordSet")
    Dim pathQuery : pathQuery = _
        " SELECT c.customerFolder + IsNull(l.loanFolder, '') AS folderPath" & _
        " FROM customer AS c INNER JOIN loan AS l" & _
        "   ON c.customerId = l.customerId" & _
        " WHERE l.loanId = " & dbFormatId(theLoanId)
    pathRS.Open pathQuery, db
    IF NOT pathRS.EOF THEN
         folderPath = Trim(TrimLeadingSlash(pathRS("folderPath")))
    END IF
    pathRS.Close

    IF IsFolderBlocked(folderPath) THEN
        Response.Clear
        Response.Redirect("AccountChangeError.asp")
    END IF

    ' ### Step 2: Refactor shared document tab references ###
    Call RefactorSharedDocumentTabs(theLoanId, theNewLoanTypeId, "L")

    ' ### Step 3: Change the loan's loanType ###
    Dim sqlCmd : sqlCmd = _
        " UPDATE loan SET" & _
        "   loanTypeId=" & dbFormatId(theNewLoanTypeId) & _
        " WHERE" & _
        "   loanId=" & dbFormatId(theLoanId)
    db.Execute sqlCmd

    ' ### Step 4: Process orphan documents
    Call ProcessOrphanDocuments(theLoanId, theNewLoanTypeId, "L")

    ' ### Step 5: Remove any unused documents based on tabs removed ###
    sqlCmd = "EXEC spDeleteUnusedLoanDocuments " & dbFormatId(theLoanId) & ";"
    db.Execute sqlCmd

    ' ### Step 6: Remove unused tabs ###
    sqlCmd = "EXEC spDeleteUnusedLoanDocumentTabs " & dbFormatId(theLoanId) & ";" 
    db.Execute sqlCmd

    ' ### Step 7: Update any cross collaterals associated with this loans
    ' so that they display the same loanType ###
    sqlCmd = _
        " UPDATE loan SET" & _
        "   loanTypeId=" & dbFormatId(theNewLoanTypeId) & _
        " WHERE" & _
        "   primaryCollateralId=" & dbFormatId(theLoanId)
    db.Execute sqlCmd

    ' ### Step 8: Call addMissingDocuments to insert any new documents that might have a different
    ' default NewStatustype vs ExistingStatusType. ###
    sqlCmd = "EXEC spAddNewAccountDocuments " & dbFormatId(theLoanId) & ";"
    db.Execute sqlCmd

    ' ### Step 9: Call spDeleteUnusedLoanExceptions in order to delete exceptions from previous Loan Type
    ' Before deleting the unused exceptions based on loanType, custom Task exceptions need to be
    ' refactored to the new loanTypeId as they are retained.
    sqlCmd = _
        " UPDATE exceptionDefinition SET" & _
        "   loanTypeId = " & dbFormatId(theNewLoanTypeId) & _
        "FROM" & _
        "   exceptionDefinition INNER JOIN loan AS l" & _
        "       ON exceptionDefinition.customLoanId=l.loanId" & _
        " WHERE" & _
        "   l.loanId = " & dbFormatId(theLoanId) & _
        "   AND exceptionDefinition.exceptionDefType = 'custom'" & _
        "   AND exceptionDefinition.computationType = 'manual'" & _
        "   AND exceptionDefinition.loanTypeId <> l.loanTypeId;"
    db.Execute sqlCmd

    sqlCmd = "EXEC spDeleteUnusedLoanExceptions 'L', " & dbFormatId(theLoanId) & ";"
    db.Execute sqlCmd

    ' Step 10: Call spAddMissingLoanExceptions To create new Exceptions based on the new Loan Type
    sqlCmd = "EXEC spAddMissingLoanExceptions 'L', " & dbFormatId(theLoanId) & ";"
    db.Execute sqlCmd

    ' Perform audit tracking on document changes.
    Call MigrateDocumentAuditHistoryForAccountTypeChange( customerNumber, accountNumber, oldAccountType, newAccountType)
    Call ProcessDocumentAuditHistories(documentAuditHistoryArray)
END SUB

	'-------------------------------------------------------------------------
	'	Sub:		ChangeCollateralType
	'	
	'	Changes a collateral to a new loanTypeId
	'-------------------------------------------------------------------------
	Sub ChangeCollateralType(theCollateralId, theNewCollateralTypeId)
        changeOfTypeTarget = "Collateral"

        ' Pre-conversion:
        Dim folderPath  : folderPath = ""
        Dim pathRS      : Set pathRS = Server.CreateObject("ADODB.RecordSet")
        Dim pathQuery   : pathQuery = _
            " SELECT c.customerFolder + IsNull(l.loanFolder, '') AS folderPath" & _
            " FROM customer AS c INNER JOIN loan AS l" & _
            "   ON c.customerId=l.customerId" & _
            " WHERE l.loanId = " & dbFormatId(theCollateralId)
        pathRS.Open pathQuery, db
        IF NOT pathRS.EOF THEN
             folderPath = Trim(TrimLeadingSlash(pathRS("folderPath")))
        END IF
        pathRS.Close

        IF IsFolderBlocked(folderPath) THEN
            Response.Clear
            Response.Redirect "CollateralChangeError.asp"
        END IF

		' Step 1: Refactor shared document tab references
		'
		RefactorSharedDocumentTabs theCollateralId, theNewCollateralTypeId, "L"
		
		' Step 2: Change the collateral's type
		'
		Dim sqlCmd
		sqlCmd = _
			" UPDATE loan SET" & _
			" 	loanTypeId=" & dbFormatId(theNewCollateralTypeId) & _
			" WHERE" & _
			"	loanId=" & dbFormatId(theCollateralId)
		db.Execute sqlCmd
		
		
		' Step 3: Process orphan documents
		' 10/23/2009 - moved here because tabs need to be in place for ophaned documents
		' to move to new document tabs.
		'
		ProcessOrphanDocuments theCollateralId, theNewCollateralTypeId, "L"
		
		
		' Step 4: Remove any unused documents based on tabs removed
		'
		sqlCmd = "EXEC spDeleteUnusedLoanDocuments " & dbFormatId(theCollateralId) & ";"
		db.Execute sqlCmd
	
		' Step 5: Remove unused tabs
		'
		sqlCmd = "EXEC spDeleteUnusedLoanDocumentTabs " & dbFormatId(theCollateralId) & ";" 
		db.Execute sqlCmd
		
		
		' Step 6: Update any cross collaterals associated with this collateral
		' so that they display the same loanType
		'
		sqlCmd = _
			" UPDATE loan SET" & _
			" 	loanTypeId=" & dbFormatId(theNewCollateralTypeId) & _
			" WHERE" & _
			"	primaryCollateralId=" & dbFormatId(theCollateralId)
		db.Execute sqlCmd

        ' Step 7: Call addMissingDocuments to insert any new documents that might have a different
        ' default NewStatustype vs ExistingStatusType.
        '
        sqlCmd = "EXEC spAddNewAccountDocuments " & dbFormatId(theCollateralId) & ";"
        db.Execute sqlCmd

        ' Step 8: Call spDeleteUnusedLoanExceptions in order to delete exceptions from previous Loan Type
        ' Before deleting the unused exceptions based on loanType, custom Task exceptions need to be
        ' refactored to the new loanTypeId as they are retained.
        sqlCmd = _
            " UPDATE exceptionDefinition SET" & _
            "	loanTypeId = " & dbFormatId(theNewCollateralTypeId) & _
            "FROM" & _
            "   exceptionDefinition INNER JOIN loan AS l" & _
            "		ON exceptionDefinition.customLoanId=l.loanId" & _
            " WHERE" & _
            "   l.loanId = " & dbFormatId(theCollateralId) & _
            "	AND exceptionDefinition.exceptionDefType = 'custom'" & _
            "	AND exceptionDefinition.computationType = 'manual'" & _
            "	AND exceptionDefinition.loanTypeId <> l.loanTypeId;"
        db.Execute sqlCmd

        sqlCmd = "EXEC spDeleteUnusedLoanExceptions 'L', " & dbFormatId(theCollateralId) & ";"
        db.Execute sqlCmd
 
        ' Step 9: Call spAddMissingLoanExceptions To create new Exceptions based on the new Loan Type
        sqlCmd = "EXEC spAddMissingLoanExceptions 'L', " & dbFormatId(theCollateralId) & ";"
        db.Execute sqlCmd

        Call ProcessDocumentAuditHistories(documentAuditHistoryArray)
   	End Sub ' ChangeCollateralType()
	
	
	'-------------------------------------------------------------------------
	'	Sub:	RefactorSharedDocumentTabs
	'	
	'	targetId		- The ID of the record being changed
	'	targetType		- Flag indicating the type of record being converted
	'						'C' for credit
	'						'L' for loan/collateral
	'-------------------------------------------------------------------------
	Sub RefactorSharedDocumentTabs(targetId, newTargetTypeId, targetType)
		'response.write "-----------------------------------------------------------<br>"
		'response.write "[changetypefunctions.asp] RefactorSharedDocumentTabs()....<br><br>"
		Dim tabFields
		tabFields = _
			"documentTypeName," & _
			"documentSubTypeName," & _
			"documentTabId," & _
			"documentDefId," & _
			"documentTypeId," & _
			"documentSubTypeId," & _
			"targetDocumentDefId," & _
			"sortOrder," & _
			"targetSortOrder"
		
		' Build dictionary of tab fields for easier indexing
		'
	    Dim tabFieldArray, tabFieldDict
	    tabFieldArray = Split(tabFields, ",")
	    Set tabFieldDict = CreateObject("Scripting.Dictionary") 
	    tabFieldDict.CompareMode = 1 ' -- NOTE: Need to set this flag... otherwise field names are CASE SENSITIVE
	    
		' Convert array into dictionary so we can use field names
	    '
		Dim i
		For i = lbound(tabFieldArray) to ubound(tabFieldArray) 
	        if not tabFieldDict.exists(tabFieldArray(i)) then
	            'Name is the key, then matched with the field ordinal in the dictionary
	            tabFieldDict.add tabFieldArray(i), i
	        end if
	    next
		
		
		' Based on targetType (credit/loan) build the FROM and WHERE clauses
		' specific to the credit or loan type.
		'
		Dim fromClause, whereClause
		if UCase(targetType) = "C" then
			fromClause = _
				" 	customer AS c INNER JOIN documentTab AS dt" & _
				"		ON c.customerId=dt.customerId AND dt.loanId IS NULL" & _
				"	INNER JOIN qryDocumentDefinitions AS dd" & _
				"		ON dd.documentDefId=dt.documentDefId" & _
				"		AND dd.customerTypeId=c.customerTypeId" & _
				"	LEFT OUTER JOIN qryDocumentDefinitions AS targetDef" & _
				"		ON targetDef.documentTypeId=dd.documentTypeId" & _
				"		AND targetDef.documentSubTypeId=dd.documentSubTypeId" & _
				"		AND targetDef.bankId=c.bankId" & _
				"		AND targetDef.customerTypeId=" & dbFormatId(newTargetTypeId)
			whereClause = _
				"	targetDef.documentDefId IS NOT NULL" & _
				"	AND c.customerId=" & dbFormatId(targetId)
		else
			fromClause = _
				" 	customer AS c INNER JOIN loan AS l" & _
				"		ON c.customerId=l.customerId" & _
				"	INNER JOIN documentTab AS dt" & _
				"		ON dt.loanId=l.loanId" & _
				"	INNER JOIN qryDocumentDefinitions AS dd" & _
				"		ON dd.documentDefId=dt.documentDefId" & _
				"		AND dd.loanTypeId=l.loanTypeId" & _
				"	LEFT OUTER JOIN qryDocumentDefinitions AS targetDef" & _
				"		ON targetDef.documentTypeId=dd.documentTypeId" & _
				"		AND targetDef.documentSubTypeId=dd.documentSubTypeId" & _
				"		AND targetDef.bankId=c.bankId" & _
				"		AND targetDef.loanTypeId=" & dbFormatId(newTargetTypeId)
			whereClause = _
				"	targetDef.documentDefId IS NOT NULL" & _
				"	AND l.loanId=" & dbFormatId(targetId)
		end if
		
		
		' Build tab Map of ID equivilances based on the shared (documentTypeId, documentSubTypeId)
		' pairs for the differing loanTypes.
		'
		Dim tabMap, tabCount
		Dim tabQuery, tabRS
		Set tabRS = Server.CreateObject("ADODB.RecordSet")
		
		tabQuery = _
			" SELECT " & _
			tabFields & _
			" FROM " & _
			" (" & _
			"	SELECT" & _
			"		dd.documentTypeName," & _
			"		dd.documentSubTypeName," & _
			"		dt.documentTabId," & _
			"		dd.documentDefId," & _
			"		dd.documentTypeId," & _
			"		dd.documentSubTypeId," & _
			"		targetDef.documentDefId AS targetDocumentDefId," & _
			"		dd.sortOrder," & _
			"		targetDef.sortOrder AS targetSortOrder" & _
			"	FROM " & _
			fromClause & _
			" 	WHERE " & _
			whereClause & _
			" ) AS v1" & _
			" ORDER BY" & _
			" 	sortOrder, targetSortOrder"
		
		tabRS.Open tabQuery, db, adOpenStatic, adCmdText
		if Not tabRS.eof then
			tabMap = tabRS.GetRows
			tabCount = Ubound(tabMap,2)
		else
			tabCount = -1
		end if
		tabRS.Close
		
		Dim updateCmd
		for i = 0 to tabCount
			' Update documentTab references in the document table
			'
			updateCmd = _
				" UPDATE document SET" & _
				"	documentDefId=" & dbFormatId( tabMap(tabFieldDict("targetDocumentDefId"),i) ) & "," & _
				"	documentTypeId=" & dbFormatId( tabMap(tabFieldDict("documentTypeId"),i) ) & "," & _
				"	documentSubTypeId=" & dbFormatId( tabMap(tabFieldDict("documentSubTypeId"),i) ) & _
				" WHERE" & _
				"	documentTabId=" & dbFormatId( tabMap(tabFieldDict("documentTabId"),i) ) & ";"	
				
			' Update documentTab references in the documentTab table.
			'
			updateCmd = updateCmd & _
				" UPDATE documentTab SET" & _
				"	documentDefId=" & dbFormatId( tabMap(tabFieldDict("targetDocumentDefId"),i) ) & _
				" WHERE" & _
				"	documentTabId=" & dbFormatId( tabMap(tabFieldDict("documentTabId"),i) ) & ";"
			
			db.Execute updateCmd
		next
	End Sub ' RefactorDocumentTabs()
	
	
	'-------------------------------------------------------------------------
	'	Sub:	ProcessOrphanDocuments
	'	
	'	targetId		- The ID of the record being changed
	'	targetType		- Flag indicating the type of record being converted
	'						'C' for credit
	'						'L' for loan/collateral
	'-------------------------------------------------------------------------
	Sub ProcessOrphanDocuments(targetId, targetTypeId, targetType)
		'response.write "[include\changetypefunctions.asp] ProcessOrphanDocuments()...<br><br>"
		
		Dim targetDocumentDefId
		Set targetDocumentDefId = Request("targetDocumentDefId")
		
		Dim orphanDocumentTabId
		Set orphanDocumentTabId = Request("orphanDocumentTabId")
		
		Dim orphanDocumentId
		Set orphanDocumentId	= Request("orphanDocumentId")
		
		Dim i
		
		for i = 1 to orphanDocumentId.Count
			if targetDocumentDefId(i) <> "" then
				Dim newTargetDocumentTabId
				AddMissingDocumentTab targetId, targetType, targetDocumentDefId(i)
				MoveOrphanDocument targetId, targetTypeId, targetType, orphanDocumentId(i), orphanDocumentTabId(i), targetDocumentDefId(i)
			end if
		next
	End Sub ' ProcessOrphanDocuments()
	
	
	'-------------------------------------------------------------------------
	'	Function:	AddMissingDocumentTab
	'	
	'	targetId		- The ID of the record being changed
	'	targetType		- Flag indicating the type of record being converted
	'						'C' for credit
	'						'L' for loan/collateral
	'	targetDocumentDefId
	'					- The target documentDefId to create if missing.
	'-------------------------------------------------------------------------
	Function AddMissingDocumentTab(targetId, targetType, targetDocumentDefId)
		Dim tabQuery, newDocumentTabId
		
		' Generate a new documentTabId
		'
		newDocumentTabId = GenerateGuid("documentTab", "documentTabId")
		
		if targetType = "C" then
			tabQuery = _
				" INSERT INTO documentTab (" & _
				"	documentTabId," & _
				"	customerId," & _
				"	loanId," & _
				"	documentDefId," & _
				"	docTabStatusType," & _
				"	docTabHighlightColor," & _
				"	docTabAllowSchedule," & _
				"	docTabScheduleUnits," & _
				"	docTabSchedulePeriod," & _
				"	docTabProcessingDateEnd," & _
				"	docTabDocumentExpireUnits," & _
				"	docTabDocumentExpirePeriod," & _
				"	docTabDocumentTitlePattern" & _
				" )" & _
				" SELECT" & _
				dbFormatId(newDocumentTabId) & "," &_
				"	c.customerId," & _
				"	NULL AS loanId," & _
				"	dd.documentDefId," & _
				"	dd.defaultExistingDocumentStatusType, " & _
				"	dd.docDefHighlightColor," & _
				"	dd.docDefAllowSchedule," & _
				"	dd.docDefScheduleUnits," & _
				"	dd.docDefSchedulePeriod," & _
				"	dd.docDefProcessingDateEnd," & _
				"	dd.docDefDocumentExpireUnits," & _
				"	dd.docDefDocumentExpirePeriod," & _
				"	dd.docDefDocumentTitlePattern" & _
				" FROM" & _
				"	customer AS c INNER JOIN qryDocumentDefinitions AS dd" & _
				"		ON c.customerTypeId=dd.customerTypeId" & _
				"		AND c.bankId=dd.bankId" & _
				"	LEFT OUTER JOIN documentTab AS dtab" & _
				"		ON dtab.customerId=c.customerId" & _
				"		AND dtab.loanId IS NULL" & _
				"		AND dtab.documentDefId=dd.documentDefId" & _
				" WHERE" & _
				"	c.customerId=" & dbFormatId(targetId) & _
				"	AND dd.documentDefId=" & dbFormatId(targetDocumentDefId) & _
				"	AND dtab.documentTabId IS NULL"
		else
			tabQuery = _
				" INSERT INTO documentTab (" & _
				"	documentTabId," & _
				"	customerId," & _
				"	loanId," & _
				"	documentDefId," & _
				"	docTabStatusType," & _
				"	docTabHighlightColor," & _
				"	docTabAllowSchedule," & _
				"	docTabScheduleUnits," & _
				"	docTabSchedulePeriod," & _
				"	docTabProcessingDateEnd," & _
				"	docTabDocumentExpireUnits," & _
				"	docTabDocumentExpirePeriod," & _
				"	docTabDocumentTitlePattern" & _
				" )" & _
				" SELECT" & _
				dbFormatId(newDocumentTabId) & "," &_
				"	l.customerId," & _
				"	l.loanId," & _
				"	dd.documentDefId," & _
				"	dd.defaultExistingDocumentStatusType, " & _
				"	dd.docDefHighlightColor," & _
				"	dd.docDefAllowSchedule," & _
				"	dd.docDefScheduleUnits," & _
				"	dd.docDefSchedulePeriod," & _
				"	dd.docDefProcessingDateEnd," & _
				"	dd.docDefDocumentExpireUnits," & _
				"	dd.docDefDocumentExpirePeriod," & _
				"	dd.docDefDocumentTitlePattern" & _
				" FROM" & _
				"	customer AS c INNER JOIN loan AS l" & _
				"		ON c.customerId=l.customerId" & _
				"	INNER JOIN qryDocumentDefinitions AS dd" & _
				"		ON dd.loanTypeId=l.loanTypeId" & _
				"		AND dd.bankId=c.bankId" & _
				"	LEFT OUTER JOIN documentTab AS dtab" & _
				"		ON dtab.loanId=l.loanId" & _
				"		ANd dtab.documentDefId=dd.documentDefId" & _
				" WHERE" & _
				"	l.loanId=" & dbFormatId(targetId) & _
				"	AND dd.documentDefId=" & dbFormatId(targetDocumentDefId) & _
				"	AND dtab.documentDefId IS NULL"
		end if
		
		' Insert targetDocumentTab if not in documentTab table
		'
		db.Execute tabQuery
		
		AddMissingDocumentTab = newDocumentTabId
	End Function ' AddMissingDocumentTab()
	
	'-------------------------------------------------------------------------
	'	Sub:	MoveOrphanDocument
	'	
	'-------------------------------------------------------------------------
	Sub MoveOrphanDocument(targetId, targetTypeId, targetType, orphanDocumentId, orphanTabId, targetDocumentDefId)
		'response.write "[include\changetypefunctions.asp] MoveOrphanDocument()...<br><br>"

		' Get target Tab information
		'
		Dim targetCustomerId, targetLoanId
		Dim targetDocumentTabId, targetDocumentTypeId, targetDocumentSubTypeId
		Dim targetLoanFile, targetFilename, targetDocumentTypeName, targetDocumentSubTypeName
        Dim targetRequireExpDate, targetDefaultExpDate
		Dim targetTabQuery, targetTabRS
		Set targetTabRS = Server.CreateObject("ADODB.RecordSet")
		
		if UCase(targetType) = "C" then
			targetTabQuery = _
				" SELECT" & _
				"	dtab.documentTabId," & _
				"	dd.documentDefId," & _
				"	dd.documentTypeId," & _
				"	dd.documentSubTypeId," & _
				"	dd.documentTypeName," & _
				"	dd.documentSubTypeName," & _
				"	dd.defaultName," & _
                "   dd.requireExpDate," & _
                "   dd.defaultExpDate" & _
				" FROM" & _
				"	qryDocumentDefinitions AS dd LEFT OUTER JOIN documentTab AS dtab" & _
				"		ON dd.documentDefId=dtab.documentDefId" & _
				" WHERE" & _
				"	dtab.customerId=" & dbFormatId(targetId) & _
				"	AND dd.documentDefId=" & dbFormatId(targetDocumentDefId)
		else
			targetTabQuery = _
				" SELECT" & _
				"	l.customerId," & _
				"	dtab.documentTabId," & _
				"	dd.documentDefId," & _
				"	dd.documentTypeId," & _
				"	dd.documentSubTypeId," & _
				"	dd.documentTypeName," & _
				"	dd.documentSubTypeName," & _
				"	dd.defaultName," & _
                "   dd.requireExpDate," & _
                "   dd.defaultExpDate" & _
				" FROM" & _
				"	qryDocumentDefinitions AS dd INNER JOIN loan AS l" & _
				"		ON dd.loanTypeId=l.loanTypeId" & _
				"	LEFT OUTER JOIN documentTab AS dtab" & _
				"		ON dd.documentDefId=dtab.documentDefId" & _
				" WHERE" & _
				"	dtab.loanId=" & dbFormatId(targetId) & _
				"	AND dd.documentDefId=" & dbFormatId(targetdocumentDefId)
		end if
		
		targetTabRS.Open targetTabQuery, db, adOpenStatic, adCmdText
		if Not targetTabRS.eof then
			targetDocumentTabId = targetTabRS("documentTabId")
			targetDocumentTypeId = targetTabRS("documentTypeId")
			targetDocumentSubTypeId = targetTabRS("documentSubTypeId")
			targetDocumentTypeName = targetTabRS("documentTypeName")
			targetDocumentSubTypeName = targetTabRS("documentSubTypeName")
			targetLoanFile = targetTabRS("defaultName")
            targetRequireExpDate = targetTabRS("requireExpDate")
            targetDefaultExpDate = targetTabRS("defaultExpDate")
		end if
		targetTabRS.Close()
		
		
		' Get existing Tab and document information of the orphan document
		'
		Dim customerName, customerNumber, customerFolder
		Dim loanNumber, loanFolder
		Dim documentTabId, documentDefId, documentTypeId, documentSubTypeId
		Dim orphanLoanFile, orphanFilename, orphanDocumentTypeName, orphanDocumentSubTypeName
		Dim tabQuery, tabRS, tabList, tabCount
        Dim sourceRequireExpDate, sourceExpDate, sourceNonExpiring
		Set tabRS = Server.CreateObject("ADODB.RecordSet")
		
		if UCase(targetType) = "C" then
			' Build tab query specific to credit tabs
			' NOTE: I did a direct join on the documentDefId and bypassed the
			' documentTab table as the references are out of date.
			'
			tabQuery = _
				" SELECT" & _
				"	dd.documentDefId," & _
				"	dd.documentTypeId," & _
				"	dd.documentSubTypeId," & _
				"	c.customerFolder," & _
				"	'' AS loanFolder," & _
				"	IsNull(d.loanFile, dd.defaultName) AS loanFile," & _
				"	d.filename," & _
				"	dd.defaultName," & _
				"	c.customerId," & _
				"	c.customerName," & _
				"	c.customerNumber," & _
				"	NULL AS loanId, " & _
				"	'' AS loanNumber," & _
				"	dd.documentTypeName," & _
				"	dd.documentSubTypeName," & _
				"	dd.sortOrder," & _
                "   dd.requireExpDate," & _
                "   CASE WHEN dd.requireExpDate = 1" & _
                "       THEN (CASE WHEN d.documentId IS NOT NULL THEN d.expDate ELSE dd.defaultExpDate END)" & _
                "       ELSE NULL" & _
                "       END AS expDate," & _
                "   d.nonExpiring" & _
				" FROM" & _
				"	document AS d INNER JOIN qryDocumentDefinitions AS dd" & _
				"		ON d.documentDefId=dd.documentDefId" & _
				"	INNER JOIN customer AS c" & _
				"		ON c.customerId=d.customerId" & _
				" WHERE" & _
				"	d.documentId=" & dbFormatId(orphanDocumentId)
		elseif UCase(targetType) = "L" then
			' Build tab query specific for loans/collateral tabs
			' NOTE: I did a direct join on the documentDefId and bypassed the
			' documentTab table as the references are out of date.
			'
			tabQuery = _
				" SELECT" & _
				"	dd.documentDefId," & _
				"	dd.documentTypeId," & _
				"	dd.documentSubTypeId," & _
				"	c.customerFolder," & _
				"	l.loanFolder," & _
				"	d.loanFile," & _
				"	d.filename," & _
				"	dd.defaultName," & _
				"	c.customerId," & _
				"	c.customerName," & _
				"	c.customerNumber," & _
				"	l.loanId," & _
				"	l.loanNumber," & _
				"	dd.documentTypeName," & _
				"	dd.documentSubTypeName," & _
				"	dd.sortOrder," & _
                "   dd.requireExpDate," & _
                "   CASE WHEN dd.requireExpDate = 1" & _
                "       THEN (CASE WHEN d.documentId IS NOT NULL THEN d.expDate ELSE dd.defaultExpDate END)" & _
                "       ELSE NULL" & _
                "       END AS expDate," & _
                "   d.nonExpiring" & _
				" FROM" & _
				"	document AS d INNER JOIN qryDocumentDefinitions AS dd" & _
				"		ON d.documentDefId=dd.documentDefId" & _
				"	INNER JOIN customer AS c" & _
				"		ON c.customerId=d.customerId" & _
				"	INNER JOIN loan AS l" & _
				"		ON l.loanId=d.loanId" & _
				" WHERE" & _
				"	d.documentId=" & dbFormatId(orphanDocumentId)
		else
			exit sub
		end if
		
		tabRS.Open tabQuery, db, adOpenStatic, adCmdText
		if Not tabRS.eof then
			customerName = tabRS("customerName")
			customerNumber = tabRS("customerNumber")
			customerFolder = tabRS("customerFolder")
			loanNumber = tabRS("loanNumber")
			loanFolder = tabRS("loanFolder")
			orphanDocumentTypeName = tabRS("documentTypeName")
			orphanDocumentSubTypeName = tabRS("documentSubTypeName")
			orphanLoanFile = tabRS("loanFile")
			orphanFilename = tabRS("filename")
			'documentTabId = tabRS("documentTabId")
			documentDefId = tabRS("documentDefId")
			documentTypeId = tabRS("documentTypeId")
			documentSubTypeId = tabRS("documentSubTypeId")
			
			targetCustomerId = tabRS("customerId")
			targetLoanId = CheckForNull(tabRS("loanId"))
			
			targetFilename = orphanFilename

            sourceRequireExpDate = tabRS("requireExpDate")
            sourceExpDate = tabRS("expDate")
            sourceNonExpiring = tabRS("nonExpiring")
		else
			'response.write "MoveOrphanDocuments()...Exiting Sub<br><br>"
			exit sub
		end if
		
		tabRS.Close
		
		Dim targetFolderPath 
		
		' Ensure customer folder existance
		'
		targetFolderPath = Session("fullpath") & customerFolder 
		targetFolderPath = Replace(targetFolderPath, "/", "\")
		if Not fso.FolderExists(targetFolderPath) then
			fso.CreateFolder targetFolderPath
		end if
		
		' Ensure loan folder existance
		'
		if loanFolder <> "" then
			targetFolderPath = targetFolderPath & loanFolder 
			targetFolderPath = Replace(targetFolderPath, "/", "\")
			if Not fso.FolderExists(targetFolderPath) then
				fso.CreateFolder targetFolderPath
			end if
		end if
		
		' Ensure tab folder existance
		'
		targetFolderPath = targetFolderPath & targetLoanFile
		targetFolderPath = Replace(targetFolderPath, "/", "\")
		if Not fso.FolderExists(targetFolderPath) then
			fso.CreateFolder targetFolderPath
		end if
		
		
		' Ensure unique filename within the target Tab folder
		'
   		Dim extension
		extension =  GetFileExtension(targetFilename)
		
		Dim targetFilePath
		targetFilePath = targetFolderPath  & "\" & targetFilename
		do until Not fso.FileExists(targetFilepath)
			targetFilename = randomString(32) & extension
			targetFilePath = targetFolderPath & "\" & targetFilename
		loop
		
		
		' Move the orphaned file to target location and name
		'
		Dim orphanFolderPath, orphanFilePath
		orphanFolderPath = Session("fullpath") & customerFolder & loanFolder & orphanLoanFile
		orphanFolderPath = Replace(orphanFolderPath, "/", "\")
		orphanFilePath = orphanFolderPath & "\" & orphanFilename
		
		if fso.FileExists(orphanFilePath) then
			'response.write "Orphan file exists. Moving orphaned file...<br>"
			fso.MoveFile orphanFilePath, targetFilePath
		end if
		
		
		' Check for single, empty document record for targetDocumentTabId.
		' If it exists delete it as it will be replaced by new document record
		'
		Dim updateCmd
		Dim targetDocCount, targetActiveDocCount
		Dim targetDocQuery, targetDocRS
		Set targetDocRS = Server.CreateObject("ADODB.RecordSet")
		
		if targetDocumentTabId <> "" then
			targetDocQuery = _
				"SELECT " & _
				" (SELECT COUNT(*) FROM document WHERE documentTabId=" & dbFormatId(targetDocumentTabId) & ") AS docCount," & _
				" (SELECT COUNT(*) FROM document WHERE documentStatus=1 AND documentTabId=" & dbFormatId(targetDocumentTabId) & ") AS activeDocCount"
			'response.write "Check for single empty document...<br>"
			'response.write "targetDocQuery =<br>" & targetDocQuery & "<br><br>"
			targetDocRS.Open targetDocQuery, db, adOpenStatic, adCmdText
			
			targetDocCount = 0
			targetActiveDocCount = 0
			if Not targetDocRS.eof then
				targetDocCount = CInt(targetDocRS("docCount"))
				targetActiveDocCount = CInt(targetDocRS("ActiveDocCount"))
			end if
			targetDocRS.Close
			

            IF targetDocCount = 1 AND targetActiveDocCount = 0 THEN

                ' ### Create an array of JSON objects so when the documents are deleted we can create the Document Audit Records ###
                Dim auditSql : auditSql = "SELECT documentId FROM document WHERE documentTabId = " & dbFormatId(targetDocumentTabId)
                Dim jsonDataArray : jsonDataArray = CreateDeleteDocumentAuditDataArray(auditSql, "Deleted", "", Session("userLogin"))

                updateCmd = _
                    " DELETE FROM exceptedDocument WHERE exceptedDocumentId IN (SELECT documentId FROM document WHERE documentTabId=" & dbFormatId(targetDocumentTabId) & ");" & _
                    " DELETE FROM document WHERE documentTabId = " & dbFormatId(targetDocumentTabId) & ";" & _
                    " DELETE FROM documentHistory WHERE documentId NOT IN (SELECT documentId FROM document);"
                db.Execute updateCmd

                ' ### Process JSON array and create Document Audit Records for each deleted document ###
                ProcessDeleteDocumentAuditDataArray(jsonDataArray)
            END IF
		end if
		
        ' Ensure expiration date and non expiring flag are set based on new target defaults
        Dim targetExpDate : targetExpDate = null
        Dim targetNonExpiring : targetNonExpiring = null

        IF targetRequireExpDate THEN
            ' Keep source expiration information if it was required
            IF sourceRequireExpDate THEN
                IF sourceNonExpiring THEN
                    targetNonExpiring = 1
                    targetExpDate = null
                Else
                    targetNonExpiring = 0
                    targetExpDate = sourceExpDate
                END IF
            ELSE
                targetExpDate = targetDefaultExpDate
                targetNonExpiring = 0
            END IF
        END IF

		' Update document record with the new tabId and folder information
		'
		updateCmd = _
			" UPDATE document SET" & _
			"	documentTabId=" & dbFormatId(targetDocumentTabId) & "," & _
			"	documentTypeId=" & dbFormatId(targetDocumentTypeId) & "," & _
			"	documentSubTypeId=" & dbFormatId(targetDocumentSubTypeId) & "," & _
			"	documentDefId=" & dbFormatId(targetDocumentDefId) & "," & _
			"	loanfile=" & dbFormatText(targetLoanFile) & "," & _
			"	filename=" & dbFormatText(targetFilename) & "," & _
			"	documentStatus=1," & _
			"	modifiedDate=" & dbFormatDate(Now()) & "," & _
            "   expDate = " & dbFormatDate2(targetExpDate, true) & "," & _
            "   nonExpiring=" & dbFormatNumeric2(targetNonExpiring, true) & _
			" WHERE" & _
			"	documentId=" & dbFormatId(orphanDocumentId) & ";"
		db.Execute updateCmd

        ' Need to queue DocumentAuditHistory changes so that they can be processed after the loan type migration.
        Dim documentAuditHistoryData : Set documentAuditHistoryData = New DocumentAuditHistory
	    documentAuditHistoryData.DocumentId = orphanDocumentId
	    documentAuditHistoryData.ActionTaken = "Modified"
	    documentAuditHistoryData.ActionComment = "Document changed due to " & changeOfTypeTarget & " change of type."
	    documentAuditHistoryData.UserName = Session("userLogin")
	    documentAuditHistoryArray = AddObject(documentAuditHistoryArray, documentAuditHistoryData)
	End Sub ' MoveOrphanDocument()
	
%>