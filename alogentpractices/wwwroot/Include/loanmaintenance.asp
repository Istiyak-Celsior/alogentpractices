<%
	' DEVELOPER'S NOTE:
	'		This file is intended to replace some of the complex logic in the customerscanupdate.asp page
	'		and to have modular functionality. This file includes any mainteance that will be done on
	'		loans.
	'
	'		MikeF 09/17/2007
	'
	
	
	'
	'	Function:
	'		GetCrossCollaterals
	'
	' Arguments:
	'		theCollateralId	- the loanId to build the list of collateral references from.
	'
	'	Returns:
	'		array - returns an array of loan IDs that consist of the cross
	'				collateral references. This array may be empty (zero elements).
	'				The array uses zero based indexing.
	'				DEV NOTE: When passed back from the function you do not need 
	'				to use the SET keyword to assign the result to a variable.
	'
	'	Description:
	'		Returns the list of collateral loanId references of the given loanId, if any.
	'
	'	Maintenance History:
	'	Developer					Date				Action
	' -----------------	----------	-------------------------------------------------
	'	MikeF							09/17/2007	Created
	'
	function GetCrossCollaterals( theCollateralId)
		response.write "[GetCrossCollaterals] Begin processing...<br><br>"
		response.write "[GetCrossCollaterals] theCollateralId = " & theCollateralId & "<br><br>"
		
		Dim crossCollateralQuery, crossCollateralRS
		Set crossCollateralRS = Server.CreateObject("ADODB.RecordSet")
		
		' Select the collaterals (from the loan table) that have a primaryCollateralId
		' of the passed ID
		'
		crossCollateralQuery = "SELECT loanId FROM loan WHERE primaryCollateralId = " & dbFormatId(theCollateralId)
		crossCollateralRS.Open crossCollateralQuery, db, adOpenStatic, adCmdText
		
		Dim crossCollateralList()
		ReDim crossCollateralList(crossCollateralRS.RecordCount)
		
		' Create an array of IDs
		'
		Dim idx
		idx = 0
		do until crossCollateralRS.eof
			crossCollateralList(idx) = crossCollateralRS("loanId")
			idx = idx + 1
			crossCollateralRS.MoveNext
		loop
		
		' Close the record set
		'
		crossCollateralRS.Close
		
		' Return the list
		'
		GetCrossCollaterals = crossCollateralList
		
		response.write "[GetCrossCollaterals] End processing...<br><br>"
	end function ' GetCrossCollaterals


'
'	Function:
'		DeleteLoan
'
' Arguments:
'		theLoanId - the loanId to be deleted.
'
'	Returns:
'		boolean - returns true for successful deletion, false otherwise.
'
'	Description:
'		Deletes a loan or collateral, but checks for Cross Collateral references and reassigns if
'		necessary before deletion occurs.
'
'	Maintenance History:
'	Developer					Date				Action
' -----------------	----------	-------------------------------------------------
'	MikeF							09/17/2007	Created
'
function DeleteLoan( theLoanId)
	response.write "[DeleteLoan] Begin processing...<br><br>"
	response.write "[DeleteLoan] Deleting loanId = " & theLoanId & "<br><br>"

	Dim loanQuery, loanRS
	Set loanRS = Server.CreateObject("ADODB.RecordSet")
	
		
	Dim deleteImages
	deleteImages = trim(Request("deleteImages"))
			
	Dim inputTypeId
	inputTypeId = GetDocumentHistoryInputId("acculoan.inputType.Delete")
	
	' Get information about the loan that will be deleted, the delete everything
	' related to the loan but the loan record. If the loan record is being referenced
    ' as a cross collateral, an existing cross collateral will be refactored to become
    ' the primary.
	loanQuery = _
		" SELECT" & _
		"	l.loanId," & _ 
		"	l.isCollateralYN," & _ 
		"	l.isCrossCollateralYN," & _ 
		"	l.primaryCollateralId," & _
        "   (SELECT COUNT(loanId) FROM loan WHERE primaryCollateralId=l.loanId) AS crossCollateralRefCount" & _
		" FROM loan AS l" & _
		" WHERE l.loanId = " & dbFormatId(theLoanId)
	loanRS.Open loanQuery, db, adOpenStatic, adCmdText
	
	If Not loanRS.eof Then
		Dim targetLoanId	        : targetLoanId = loanRS("loanId")
        Dim isCollateralYN          : isCollateralYN = loanRS("isCollateralYN")
	    Dim isCrossCollateralYN     : isCrossCollateralYN = loanRS("isCrossCollateralYN")
        Dim crossCollateralRefCount : crossCollateralRefCount = loanRS("crossCollateralRefCount")

        ' check to see if this is a primary loan record referenced by other cross collaterals.
        ' If it is then the documents need to reassigned to an existing cross collatral and 
        ' made the primary before deleting this loan record.
        If crossCollateralRefCount > 0 Then
	        Dim crossCollateralList
	        crossCollateralList = GetCrossCollaterals(targetLoanId)
	        If UBound(crossCollateralList) > 0 Then
		        ' Reassign cross collaterals to a new primary.
		        '
		        ReassignCrossCollaterals theLoanId, crossCollateralList
	        End If
        End If

        ' Insert document histories of files that will be deleted
		sqlQuery = BuildMassDocumentHistoryInsert(targetLoanId, inputTypeId)
		db.Execute sqlQuery
		
        If deleteImages = "Y" Then
		    DeleteLoanFiles targetLoanId
		End If

        ' ### Create an array of JSON objects so when the documents are deleted we can create the Document Audit Records ###
        Dim auditSql : auditSql = "SELECT documentId FROM document WHERE loanId = " & dbFormatId(targetLoanId)
        Dim jsonDataArray : jsonDataArray = CreateDeleteDocumentAuditDataArray(auditSql, "Deleted", "", Session("userLogin"))

        ' Delete loan related records
        sqlQuery = _
            " DELETE FROM exceptedDocument WHERE exceptedDocumentId IN (SELECT documentId FROM document WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
			" DELETE FROM exceptionComment WHERE exceptionId IN " & _
            "   (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM exceptionHistory WHERE exceptionId IN " & _
            "   (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM exceptedDocument WHERE exceptionId IN " & _
            "   (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM exception WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM computation WHERE exceptionDefId IN (" & _
            "   SELECT exceptionDefId FROM exceptionDefinition WHERE customLoanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM exceptionDefinition WHERE customLoanId = " & dbFormatId(targetLoanId) & ";" & _
			" DELETE FROM auditDocumentDetail WHERE documentId IN (SELECT documentId FROM document WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
			" DELETE FROM auditDetail WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM document WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM documentActivation WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM documentTab WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM coborrower WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM loanFields WHERE loanId = " & dbFormatId(theLoanId) & ";" & _
            " DELETE FROM collateralFields WHERE collateralId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM collateral WHERE parentLoanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM collateral WHERE collateralLoanId = " & dbFormatId(targetLoanId) & ";" & _
			" DELETE FROM actionTimer WHERE loanApplicationId IN (SELECT loanApplicationId FROM loanApplication WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM approval WHERE approvalId IN (" & _
            "   SELECT approvalId FROM loanApplication WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM loanApplicationHistory WHERE loanApplicationId IN (" & _
            "   SELECT loanApplicationId FROM loanApplication WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM loanApplicationCondition WHERE loanApplicationId IN (" & _
            "   SELECT loanApplicationId FROM loanApplication WHERE loanId = " & dbFormatId(targetLoanId) & ");" & _
            " DELETE FROM loanApplication WHERE loanId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM participationCollateral WHERE originatingCollateralId = " & dbFormatId(targetLoanId) & ";" & _
            " DELETE FROM participationLoan WHERE loanId = " & dbFormatId(targetLoanId) & ";" 
        db.Execute sqlQuery

        ' ### Process JSON array and create Document Audit Records for each deleted document ###
        ProcessDeleteDocumentAuditDataArray(jsonDataArray)

    END IF
    loanRS.Close

    sqlQuery = "DELETE FROM loan WHERE loanId = " & dbFormatId(theLoanId)
    db.Execute sqlQuery
    	
	DeleteLoan = true
	response.write "[DeleteLoan] End processing...<br><br>"
end function ' DeleteLoan
		
		
	'
	'	Function:
	'		ReassignCrossCollaterals
	'
	' Arguments:
	'		thePrimaryCollateralId	- the loanId to be checked for references.
	'		crossCollateralList			- array of cross collateral id references (0 index array).
	'
	'	Returns:
	'		boolean									- returns true for successful if it has references,
	'															false otherwise.
	'
	'	Description:
	'		Reassigns a given list of collateralId's to a new primaryCollateralId, such
	'		that the first id in the list is converted to a regular loan/collateral and
	'		becomes the primaryId for the remainder in the list.
	'
	'	Maintenance History:
	'	Developer					Date				Action
	' -----------------	----------	-------------------------------------------------
	'	MikeF							09/19/2007	Created
	'	
	function ReassignCrossCollaterals( thePrimaryCollateralId, crossCollateralList)
		response.write "[ReassignCrossCollaterals] Begin processing...<br><br>"
		response.write "[ReassignCrossCollaterals] thePrimaryCollateralId = " & thePrimaryCollateralId & "<br>"
		Dim newPrimaryCollateralId
		newPrimaryCollateralId = crossCollateralList(0)
		response.write "[ReassignCrossCollaterals] newPrimaryCollateralId = " & newPrimaryCollateralId & "<br><br>"
		
		' convert the first cross collateral id to a regular one.
		'
		Convert2Collateral(newPrimaryCollateralId)
		
		' adjust cross collateral references using the first one as the
		' new primaryCollateralId.
		'
		Dim idx, sqlCmd
		sqlCmd = ""
		for idx = 1 to UBound(crossCollateralList)-1
			sqlCmd = sqlCmd & _
				" UPDATE loan" & _
				" SET primaryCollateralId = " & dbFormatId(newPrimaryCollateralId) & _
				" WHERE loanId = " & dbFormatId(crossCollateralList(idx)) & "; "
		next ' idx
		
		' Execute the reference updates if necessary.
		'
		if sqlCmd <> "" then
			db.Execute sqlCmd
		end if
		
		ReassignCrossCollaterals = true
		response.write "[ReassignCrossCollaterals] End processing...<br><br>"
	end function ' ReassignCrossCollaterals
		
		
	'
	'	Function:
	'		Convert2CrossCollateral
	'
	' Arguments:
	'		theCollateralId					- the loan/collateral to convert
	'		thePrimaryCollateralId	- the referenced primary loan/collateral id
	'
	'	Returns:
	'		boolean
	'
	'	Description:
	'		Converts a loan record into a cross collateral reference.
	'
	'	Maintenance History:
	'	Developer					Date				Action
	' -----------------	----------	-------------------------------------------------
	'	MikeF							09/19/2007	Created
	'	
	function Convert2CrossCollateral( theCollateralId, thePrimaryCollateralId)
		response.write "[Convert2CrossCollateral] Begin processing...<br><br>"
		
		' Create reference to primary collateral loan Id and change
		' any related reference fields (e.g. loanType, loanStatus, loanDescription, etc).
		'
		sqlQuery = _
			" UPDATE loan SET" & _
			"	isCrossCollateralYN = 'Y'," & _
			"	primaryCollateralId = " & dbFormatId(thePrimaryCollateralId) & "," & _
			"	loanDescription=v1.loanDescription," & _
			"	loanTypeId=v1.loanTypeId," & _
			"	loanStatusId=v1.loanStatusId" & _
			" FROM" & _
			"	loan CROSS JOIN" & _
			"	(" & _
			"		SELECT loanDescription, loanTypeId, loanStatusId" & _
			"		FROM loan" & _
			"		WHERE loanId = " & dbFormatId(thePrimaryCollateralId) & _
			"	) AS v1" & _
			" WHERE loanId = " & dbFormatId(theCollateralId)
		db.Execute sqlQuery

        db.Execute "EXEC spSyncCrossCollateralToPrimaryCollateral"
		
		' Delete the folder and documents the collateral originally had.
		'
		Dim fso, filePath
		Set fso = Server.CreateObject("Scripting.FileSystemObject")
		
		Dim folderQuery, folderRS
		Set folderRS = Server.CreateObject("ADODB.RecordSet")
		folderQuery = _
			" SELECT 	c.customerFolder, l.loanFolder" & _
			" FROM		customer AS c INNER JOIN loan AS l ON c.customerId=l.customerId" & _
			" WHERE		l.loanId = " & dbFormatId(theCollateralId)
		folderRS.Open folderQuery, db, adOpenStatic, adCmdText
		folderPath = Session("fullPath") & folderRS("customerFolder") & Replace(folderRS("loanFolder"), "/", "")
		folderPath = Replace(folderPath, "/", "\")
		if fso.FolderExists(folderPath) then
			fso.DeleteFolder folderPath, true
		end if
		folderRS.Close
		
        ' Delete Exception related records referenced by the collateral
		sqlQuery = " DELETE exceptionComment WHERE exceptionId IN (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(theCollateralId) & "); "
		sqlQuery = sqlQuery & " DELETE exceptionHistory WHERE exceptionId IN (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(theCollateralId) & "); "
		sqlQuery = sqlQuery & " DELETE exceptedDocument WHERE exceptionId IN (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(theCollateralId) & "); "
		sqlQuery = sqlQuery & " DELETE exception WHERE loanId = " & dbFormatId(theCollateralId) & "; "
        
        ' Delete Document related records referenced by the collateral.
		sqlQuery = sqlQuery & " DELETE documentActivation WHERE loanId = " & dbFormatId(theCollateralId) & "; "
    	sqlQuery = sqlQuery & " DELETE document WHERE loanId = " & dbFormatId(theCollateralId) & "; "
		sqlQuery = sqlQuery & " DELETE documentTab WHERE loanId = " & dbFormatId(theCollateralId) & "; "

        ' Delete flex fields referenced by the collateral.
		sqlQuery = sqlQuery & " DELETE collateralFields WHERE collateralId = " & dbFormatId(theCollateralId) & "; "
	
		db.Execute sqlQuery
		
		response.write "[Convert2CrossCollateral] End processing...<br><br>"
	end function
	
	
	'
	'	Function:
	'		Convert2Collateral
	'
	' Arguments:
	'		theCrossCollateralId			- the collateral/loan id that needs to be converted.
	'
	'	Returns:
	'		boolean
	'
	'	Description:
	'		Converts the given cross collateral/loan into a regular collateral/loan.
	'
	'	Maintenance History:
	'	Developer					Date				Action
	' -----------------	----------	-------------------------------------------------
	'	MikeF							09/19/2007	Created
	'	
	function Convert2Collateral(theCrossCollateralId)
		response.write "[Convert2Collateral] Begin processing...<br><br>"
		Dim collateralQuery, collateralRS
		Set	collateralRS = Server.CreateObject("ADODB.RecordSet")
		
		Dim primaryCollateralQuery, primaryCollateralRS
		Set primaryCollateralRS = Server.CreateObject("ADODB.RecordSet")
		
		Dim crossCollateralCustomerId, primaryCollateralId
		
		
		' Update collateral to reflect new non-cross collateral state.
		'
		collateralQuery = "SELECT * FROM loan WHERE loanId = " & dbFormatId(theCrossCollateralId)
		response.write "[Convert2Collateral] collateralQuery =<br>" & collateralQuery & "<br><br>"
		collateralRS.Open collateralQuery, db, adOpenKeyset, adLockPessimistic, adCmdText
		
		crossCollateralCustomerId	= collateralRS("customerId")						' Get customerId of the cross collateral
		primaryCollateralId 			= collateralRS("primaryCollateralId")		' Grab the primaryCollateralId
		
		' Get information on the primary collateral references
		'
		primaryCollateralQuery = "SELECT * FROM loan WHERE loanId = " & dbFormatId(primaryCollateralId)
		response.write "[Convert2Collateral] primaryCollateralQuery =<br>" & primaryCollateralQuery & "<br><br>"
		primaryCollateralRS.Open primaryCollateralQuery, db, adOpenStatic, adCmdText
		
		
		' Set collateral specific flags
		'
		collateralRS("isCollateralYN")		= "Y"		' Always set to a collateral
		collateralRS("isCrossCollateralYN") = "N"		' Set status to non-cross collateral
		collateralRS("primaryCollateralId") = NULL		' Remove primaryCollateralId reference
		
		' Copy the primary collateral information into the converted collateral
		'
		collateralRS("loanDescription") 		= primaryCollateralRS("loanDescription")
		
		' Update the converted collateral
		'
		collateralRS.Update
		
		' Close record sets
		'
		primaryCollateralRS.Close
		collateralRS.Close
		
		
		' update the collateral to match parent loanStatus and ignoreFlags
		'
		sqlCmd = _
			" UPDATE loan SET" & _
			"	loanStatusId = pl.loanStatusId," & _
			"	ignoreExceptionsYN = pl.ignoreExceptionsYN" & _
			" FROM" & _
			"	loan INNER JOIN collateral AS cl" & _
			"		ON cl.collateralLoanId=loan.loanId" & _
			"	INNER JOIN loan AS pl" & _
			"		ON pl.loanId=cl.parentLoanId" & _
			" WHERE" & _
			"	loan.loanId = " & dbFormatId(theCrossCollateralId)
		db.Execute sqlCmd

        ' ### Create an array of JSON objects so when the documents are deleted we can create the Document Audit Records ###
        Dim auditSql2 : auditSql2 = "SELECT documentId FROM document WHERE loanId = " & dbFormatId(theCrossCollateralId)
        Dim jsonDataArray2 : jsonDataArray2 = CreateDeleteDocumentAuditDataArray(auditSql2, "Deleted", "", Session("userLogin"))

        ' Ensure there are no document or exception records for the cross collateral
        sqlCmd = _
            " DELETE FROM exceptionComment WHERE exceptionId IN (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(theCrossCollateralId) & "); " &_
            " DELETE FROM exceptionHistory WHERE exceptionId IN (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(theCrossCollateralId) & "); " &_
            " DELETE FROM exceptedDocument WHERE exceptionId IN (SELECT exceptionId FROM exception WHERE loanId = " & dbFormatId(theCrossCollateralId) & "); " &_
            " DELETE FROM exception WHERE loanId = " & dbFormatId(theCrossCollateralId) & ";" & _
            " UPDATE documentHistory SET documentId = NULL WHERE documentId IN (SELECT documentId FROM document WHERE loanId = " & dbFormatId(thCrossCollateralId) & ");" & _
            " DELETE FROM document WHERE loanId = " & dbFormatId(theCrossCollateralId) & ";" & _
            " DELETE FROM documentActivation WHERE loanId = " & dbFormatId(theCrossCollateralId) & ";" & _
            " DELETE FROM documantTab WHERE loanId = " & dbFormatId(theCrossCollateralId) & ";" & _
            " DELETE FROM collateralFields WHERE collateralId = " & dbFormatId(theCrossCollateralId) & ";"
        db.Execute sqlCmd

        ' ### Process JSON array and create Document Audit Records for each deleted document ###
        ProcessDeleteDocumentAuditDataArray(jsonDataArray2)

		' Copy documentTabs of the primaryCollateral
		'
		sqlCmd = _
			" INSERT INTO documentTab (" & _
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
			"	docTabDocumentTitlePattern," & _
			"	docTabOverrideDefinition," & _
			"	docTabNextCreateDate," & _
			"	docTabLockSettings" & _
			" )" & _
			" SELECT " & _
			dbFormatId(crossCollateralCustomerId) & "," & _
			dbFormatId(theCrossCollateralId) & "," & _
			"	documentDefId," & _
			"	docTabStatusType," & _
			"	docTabHighlightColor," & _
			"	docTabAllowSchedule," & _
			"	docTabScheduleUnits," & _
			"	docTabSchedulePeriod," & _
			"	docTabProcessingDateEnd," & _
			"	docTabDocumentExpireUnits," & _
			"	docTabDocumentExpirePeriod," & _
			"	docTabDocumentTitlePattern," & _
			"	docTabOverrideDefinition," & _
			"	docTabNextCreateDate," & _
			"	docTabLockSettings" & _
			" FROM documentTab" & _
			" WHERE loanId = " & dbFormatId(primaryCollateralId) & ";"
		
		' Copy the documentActivations of the primaryCollateral
		'
		sqlCmd = sqlCmd & _
			" INSERT INTO documentActivation (" & _
			"	customerId," & _
			"	loanId," & _
			"	documentTypeId," & _
			"	activationStatus" & _
			" )" & _
			" SELECT " & _
			dbFormatId(crossCollateralCustomerId) & "," & _
			dbFormatId(theCrossCollateralId) & "," & _
			" 	documentTypeId," & _
			" 	activationStatus" & _
			" FROM documentActivation" & _
			" WHERE loanId = " & dbFormatId(primaryCollateralId) & ";"

		' Create mapping of primary documents with potento uncrossed collateral documents
		' by creating new documentIds ahead of time. This is to ensure the documentHistory
		' is updated correctly.
		'
		sqlCmd = sqlCmd & _
			" SELECT" & _
			" 	d.documentId AS primary_documentId," & _
			" 	NEWID() AS uncrossed_documentId" & _
			" INTO #tmpDocumentMap" & _
			" FROM" & _
			" 	document AS d" & _
			" WHERE" & _
			" 	d.loanId = " & dbFormatId(primaryCollateralId)

        ' ### Copy the primaryCollateral documents to the newly converted collateral ###
		sqlCmd = sqlCmd & _
			" INSERT INTO document" & _ 
			" (" & _ 
			" 	documentId," & _ 
			" 	customerId," & _ 
			" 	loanId," & _ 
			" 	documentTypeId," & _ 
			" 	documentSubTypeId, " & _ 
			" 	documentDescription," & _ 
			" 	documentTitle," & _ 
			" 	documentHighlightColor," & _ 
			" 	nonExpiring," & _ 
			" 	loanFile," & _ 
			" 	filename," & _ 
			" 	documentAssociation," & _ 
			" 	documentStatus," & _ 
			" 	origdate," & _ 
			" 	modifieddate," & _ 
			" 	expdate," & _ 
			" 	email," & _ 
			" 	documentStatusType," & _ 
			" 	documentComment," & _ 
			" 	documentTabId," & _ 
			" 	documentDefId" & _ 
			" )" & _ 
			" SELECT" & _ 
			" 	temp.uncrossed_documentId," & _ 
			dbFormatId(crossCollateralCustomerId) & ", " & _
			dbFormatId(theCrossCollateralId) & ", " & _
			" 	d.documentTypeId," & _ 
			" 	d.documentSubTypeId, " & _ 
			" 	d.documentDescription," & _ 
			" 	d.documentTitle," & _ 
			" 	d.documentHighlightColor," & _ 
			" 	d.nonExpiring," & _ 
			" 	d.loanFile," & _ 
			" 	d.filename," & _ 
			" 	d.documentAssociation," & _ 
			" 	d.documentStatus," & _ 
			" 	d.origdate," & _ 
			dbFormatDate(NOW()) & ", " & _
			" 	d.expdate," & _ 
			" 	d.email," & _ 
			" 	d.documentStatusType," & _ 
			" 	d.documentComment," & _ 
			" 	target.documentTabId AS targetDocumentTabId," & _ 
			" 	target.documentDefId AS targetDocumentDefId" & _ 
			" FROM" & _ 
			" 	loan AS l INNER JOIN documentTab AS dt" & _ 
			" 		ON l.loanId=dt.loanId" & _ 
			" 	INNER JOIN qryDocumentDefinitions AS dd" & _ 
			" 		ON dd.documentDefId=dt.documentDefId AND dd.loanTypeId=l.loanTypeId" & _ 
			" 	INNER JOIN document AS d" & _ 
			" 		ON d.documentTabId=dt.documentTabId" & _ 
			" 	INNER JOIN" & _ 
			" 	(" & _ 
			" 		SELECT" & _ 
			" 			dt.documentTabId," & _ 
			" 			dd.documentDefId," & _ 
			" 			dd.documentTypeId," & _ 
			" 			dd.documentSubTypeId" & _ 
			" 		FROM" & _ 
			" 			loan AS l INNER JOIN documentTab AS dt" & _ 
			" 				ON l.loanId=dt.loanId" & _ 
			" 			INNER JOIN qryDocumentDefinitions AS dd" & _ 
			" 				ON dd.documentDefId=dt.documentDefId AND dd.loanTypeId=l.loanTypeId" & _ 
			" 		WHERE" & _ 
			" 			l.loanId = " & dbFormatId(theCrossCollateralId) & _
			" 	) AS target" & _ 
			" 		ON target.documentTypeId=dd.documentTypeId AND target.documentSubTypeId=dd.documentSubTypeId" & _ 
			" 	INNER JOIN #tmpDocumentMap AS temp" & _ 
			" 		ON temp.primary_documentId = d.documentId" & _ 
			" WHERE" & _ 
			" 	l.loanId = " & dbFormatId(primaryCollateralId)

		
		' Copy the primary collateral flex fields to converted cross collateral
		'
		Dim tmpStr : tmpStr = BuildCollateralFieldInsertSQL(primaryCollateralId, theCrossCollateralId)
		sqlCmd = sqlCmd & tmpStr 'BuildCollateralFieldInsertSQL(primaryCollateralId, theCrossCollateralId)
		Response.Write "Insert String = <br/>" & tmpStr & "<br/>"
		
		db.Execute sqlCmd
		
        ' ### Create Document Audit records for the newly converted collateral ###
        Dim documentListSQL : documentListSQL = _
            " SELECT documentId FROM document WHERE loanId = " & dbFormatId(theCrossCollateralId) & ";"

        Call CreateDocumentAuditList(documentListSQL, "Created", "Document created during conversion from cross collateral to regular collateral.")

		' Get the primary collateral documents information and copy to the newly
		' converted collateral. Also copy any files from the primary to the newly
		' created collateral.
		'
		Dim fso
		Set fso = Server.CreateObject("Scripting.FileSystemObject")
		
		Dim documentQuery, documentRS
		Set documentRS = Server.CreateObject("ADODB.RecordSet")
		documentQuery = _
			" SELECT	*" & _
			" FROM	(" & _
			" 			SELECT	c.customerFolder AS srcCustomerFolder, l.loanFolder AS srcLoanFolder, d.loanFile AS srcLoanFile, d.filename AS srcFilename, d.documentStatus AS srcDocumentStatus, d.documentTypeId, d.documentSubTypeId" & _
			" 			FROM	customer AS c INNER JOIN loan AS l ON c.customerId=l.customerId" & _
			" 					INNER JOIN document AS d ON d.loanId=l.loanId" & _
			" 			WHERE	d.loanId = " & dbFormatId(primaryCollateralId) & _
			" 		) AS src INNER JOIN" & _
			" 		(" & _
			" 			SELECT	c.customerFolder AS dstCustomerFolder, l.loanFolder AS dstLoanFolder, d.loanFile AS dstLoanFile, d.filename AS dstFilename, d.documentStatus AS dstDocumentStatus, d.documentTypeId, d.documentSubTypeId" & _
			" 			FROM	customer AS c INNER JOIN loan AS l ON c.customerId=l.customerId" & _
			" 					INNER JOIN document AS d ON d.loanId=l.loanId" & _
			" 			WHERE	d.loanId = " & dbFormatId(theCrossCollateralId) & _
			" 		) AS dst " & _
			" 		ON src.documentTypeId=dst.documentTypeid" & _
            "       AND src.documentSubTypeId=dst.documentSubTypeId" & _
            "       AND src.srcFilename=dst.dstFilename" & _
			" WHERE	srcDocumentStatus = 1"
		response.write "[Convert2Collateral] documentQuery =<br>" & documentQuery & "<br><br>"
		documentRS.Open documentQuery, db, adOpenStatic, adCmdText
		
		Dim srcPath, dstPath
		response.write "[Convert2Collateral] documentRS.eof = " & documentRS.eof & "<br><br>"
		do until documentRS.eof
			' Ensure the source customer folder exists
			'
			srcPath = Replace(Session("fullPath") & documentRS("srcCustomerFolder"), "/", "\")
			if Not fso.FolderExists(srcPath) then
				fso.CreateFolder(srcPath)
			end if
			
			' Ensure the source loan folder exists
			'
			srcPath = srcPath & Replace(documentRS("srcLoanFolder"), "/", "\")
			if Not fso.FolderExists(srcPath) then
				fso.CreateFolder(srcPath)
			end if
			
			' Ensure the source document folder exits
			'
			srcPath = srcPath & Replace(documentRS("srcLoanFile"), "/", "\")
			if Not fso.FolderExists(srcPath) then
				fso.CreateFolder(srcPath)
			end if
			
			' Ensure the destination customer folder exists
			'
			dstPath = Replace(Session("fullPath") & documentRS("dstCustomerFolder"), "/", "\")
			if Not fso.FolderExists(dstPath) then
				fso.CreateFolder(dstPath)
			end if
			
			' Ensure the destination loan folder exists
			'
			dstPath = dstPath & Replace(documentRS("dstLoanFolder"), "/", "\")
			if Not fso.FolderExists(dstPath) then
				fso.CreateFolder(dstPath)
			end if
			
			' Ensure the destination document folder exits
			'
			dstPath = dstPath & Replace(documentRS("dstLoanFile"), "/", "\")
			if Not fso.FolderExists(dstPath) then
				fso.CreateFolder(dstPath)
			end if
			
			srcPath = srcPath & "/" & documentRS("srcFilename")
			dstPath = dstPath & "/" & documentRS("dstFilename")
			
			srcPath = Replace(srcPath, "/", "\")
			dstPath = Replace(dstPath, "/", "\")
			
			' Copy the file
			'
			if fso.FileExists(srcPath) then
				response.write "[Convert2Collateral] Copying src file: " & srcPath & "<br>"
				response.write "[Convert2Collateral] To dst file: " & dstPath & "<br><br>"
				Call CopyPhysicalFile(srcPath, dstPath)
			end if
			
			' Move to next document
			'
			documentRS.MoveNext
		loop
		
		documentRS.Close
		
		
		' The following clones the exceptions and custom exceptions and their histories to
		' the collateral that is being uncrossed.
		'
		' Create temporary tables for mapping the custom primary exceptionDefintions, computations
		' and documents to new exceptionDefinitions, computations and documents for the uncrossed collateral
		'
		sqlCmd = _
			" SELECT" & _ 
			" 	ed.exceptionDefId AS primary_exceptionDefId," & _ 
			" 	comp.computationId AS primary_computationId," & _ 
			" 	NEWID() AS uncrossed_exceptionDefId," & _ 
			" 	NEWID() AS uncrossed_computationId" & _ 
			" INTO #tmpCustomExceptionDefinitionMap" & _ 
			" FROM" & _ 
			" 	exceptionDefinition AS ed INNER JOIN computation AS comp" & _ 
			" 		ON ed.exceptionDefId = comp.exceptionDefId" & _ 
			" WHERE" & _ 
			" 	ed.customLoanId = " & dbFormatId(primaryCollateralId)
		db.Execute sqlCmd



		' Create custom exceptionDefinitions based on the custom primary collateral
		'
		sqlCmd = _
			" INSERT INTO exceptionDefinition (" & _ 
			" 	exceptionDefId," & _ 
			" 	exceptionDefName," & _ 
			" 	weight," & _ 
			" 	isGlobalYN," & _ 
			" 	bankId," & _ 
			" 	customerTypeId," & _ 
			" 	loanTypeId," & _ 
			" 	exceptionDefType," & _ 
			" 	computationType," & _ 
			" 	defaultAssignedUserId," & _ 
			" 	defaultStatusType," & _ 
			" 	sortOrder," & _ 
			" 	defaultExistingExceptionState," & _ 
			" 	defaultNewExceptionState," & _ 
			" 	exceptionCategoryId," & _ 
			" 	requireReminderDate," & _ 
			" 	defaultReminderDate," & _ 
			" 	PolicyId," & _ 
			" 	dateChanged," & _ 
			" 	dateAdded," & _ 
			" 	changedBy," & _ 
			" 	exceptionDefCode," & _ 
			" 	amountThresholdFlag," & _ 
			" 	amountThreshold," & _ 
			" 	requireLoanMaturityDate," & _ 
			" 	customCustomerId," & _ 
			" 	customLoanId," & _ 
			" 	defaultReminderDateGracePeriod," & _ 
			" 	allowNotificationDefault," & _ 
			" 	taskType," & _ 
			" 	qcType," & _ 
			" 	ccNotificationDefault" & _ 
			" )" & _
			" SELECT" & _ 
			" 	map.uncrossed_exceptionDefId," & _ 
			" 	exceptionDefName," & _ 
			" 	weight," & _ 
			" 	isGlobalYN," & _ 
			" 	bankId," & _ 
			" 	customerTypeId," & _ 
			" 	loanTypeId," & _ 
			" 	exceptionDefType," & _ 
			" 	computationType," & _ 
			" 	defaultAssignedUserId," & _ 
			" 	defaultStatusType," & _ 
			" 	sortOrder," & _ 
			" 	defaultExistingExceptionState," & _ 
			" 	defaultNewExceptionState," & _ 
			" 	exceptionCategoryId," & _ 
			" 	requireReminderDate," & _ 
			" 	defaultReminderDate," & _ 
			" 	PolicyId," & _ 
			" 	dateChanged," & _ 
			" 	dateAdded," & _ 
			" 	changedBy," & _ 
			" 	exceptionDefCode," & _ 
			" 	amountThresholdFlag," & _ 
			" 	amountThreshold," & _ 
			" 	requireLoanMaturityDate," & _ 
			" 	customCustomerId," & _ 
			dbFormatId(theCrossCollateralId) & " AS customLoanId," & _ 
			" 	defaultReminderDateGracePeriod," & _ 
			" 	allowNotificationDefault," & _ 
			" 	taskType," & _ 
			" 	qcType," & _ 
			" 	ccNotificationDefault" & _ 
			" FROM" & _ 
			" 	exceptionDefinition AS ed INNER JOIN computation AS comp" & _ 
			" 		ON ed.exceptionDefId = comp.exceptionDefId" & _ 
			" 	INNER JOIN #tmpCustomExceptionDefinitionMap AS map" & _ 
			" 		ON map.primary_exceptionDefId = ed.exceptionDefId" & _ 
			" WHERE" & _ 
			" 	ed.customLoanId = " & dbFormatId(primaryCollateralId)
		db.Execute sqlCmd

		' Create computatons for the new custom exceptionDefinitions
		'
		sqlCmd = _
			" INSERT INTO computation (" & _ 
			" 	computationId," & _ 
			" 	exceptionDefId," & _ 
			" 	docDefId," & _ 
			" 	gracePeriod," & _ 
			" 	statusTypeCheck" & _ 
			" )" & _ 
			" SELECT " & _ 
			" 	map.uncrossed_computationId," & _ 
			" 	map.uncrossed_exceptionDefId," & _ 
			" 	comp.docDefId," & _ 
			" 	comp.gracePeriod," & _ 
			" 	comp.statusTypeCheck	" & _ 
			" FROM" & _ 
			" 	exceptionDefinition AS ed INNER JOIN computation AS comp" & _ 
			" 		ON ed.exceptionDefId = comp.exceptionDefId" & _ 
			" 	INNER JOIN #tmpCustomExceptionDefinitionMap AS map" & _ 
			" 		ON map.primary_computationId = comp.computationId" & _ 
			" WHERE" & _ 
			" 	ed.customLoanId = " & dbFormatId(primaryCollateralId)
		db.Execute sqlCmd

		' Create temporary exception map of the exceptions to be cloned and new ID values. This necessary to clone the
		' exceptedDocument table to ensure the correct information is copied
		'
		sqlCmd = _
			" SELECT" & _
			" 	ex.exceptionId AS primary_exceptionId," & _
			" 	NEWID() AS uncrossed_exceptionId" & _
			" INTO #tmpExceptionMap" & _
			" FROM" & _
			" 	exception AS ex" & _
			" WHERE" & _
			" 	ex.loanId = " & dbFormatId(primaryCollateralId)
		db.Execute sqlCmd

		' Insert a copy of the primaryCollateralId exceptions into the
		' converted cross collateral.
		'
		sqlCmd = _
			" INSERT INTO exception (" & _
			"	exceptionId," & _
			" 	exceptionDefId, " & _
			" 	exceptionState, " & _
			" 	assignedUserId, " & _
			" 	customerId, " & _
			" 	loanId, " & _
			" 	comment, " & _
			" 	statusType, " & _
			" 	datePending, " & _
			" 	dateExcepted, " & _
			" 	dateResolved, " & _
			" 	reminderDate, " & _
			" 	dateAdded, " & _
			" 	dateChanged, " & _
			" 	changedBy " & _
			" )" & _
			"	SELECT " & _
			"	exMap.uncrossed_exceptionId AS exceptionId," & _
			" 	CASE WHEN defMap.uncrossed_exceptionDefId IS NOT NULL THEN" & _
			"		defMap.uncrossed_exceptionDefId" & _
			"	ELSE " & _
			"		ex.exceptionDefId" & _
			"	END AS exceptionDefId," & _
			" 	exceptionState, " & _
			" 	assignedUserId, " & _
			dbFormatId(crossCollateralCustomerId) & ", " & _
			dbFormatId(theCrossCollateralId) & ", " & _
			" 	comment, " & _
			" 	statusType, " & _
			" 	datePending, " & _
			" 	dateExcepted, " & _
			" 	dateResolved, " & _
			" 	reminderDate, " & _
			" 	dateAdded, " & _
			" 	dateChanged, " & _
			" 	changedBy" & _
			" FROM" & _
			"	exception AS ex LEFT OUTER JOIN #tmpCustomExceptionDefinitionMap AS defMap" & _
			"		ON ex.exceptionDefId = defMap.primary_exceptionDefId" & _
			"	INNER JOIN #tmpExceptionMap AS exMap" & _
			"		ON ex.exceptionId = exMap.primary_exceptionId" &_
			" WHERE loanId = " & dbFormatId(primaryCollateralId)
		db.Execute sqlCmd
		
		' TODO: Clone the primary exceptedDocument table for new documents created
		'
		sqlCmd = _
			" INSERT INTO exceptedDocument(" & _
			"	exceptionId," & _
			"	exceptedDocDefId," & _
			"	exceptedDocumentId," & _
			"	documentExceptionState," & _
			"	documentDateExcepted," & _
			"	documentDatePending" & _
			" )" & _
			" SELECT" & _
			"	exMap.uncrossed_exceptionId AS exceptionId," & _
			"	exdoc.exceptedDocDefId," & _
			"	exdoc.exceptedDocumentId," & _
			"	exdoc.documentExceptionState," & _
			"	exdoc.documentDateExcepted," & _
			"	exdoc.documentDatePending" & _
			" FROM" & _
			"	exception AS ex INNER JOIN exceptedDocument AS exdoc" & _
			"		ON ex.exceptionId = exdoc.exceptionId" & _
			"	INNER JOIN #tmpExceptionMap AS exMap" & _
			"		ON exMap.primary_exceptionId = ex.exceptionId" & _
			" WHERE" & _
			"	ex.loanId = " & dbFormatId(primaryCollateralId)
		db.Execute sqlCmd

		' Copy the exception comments as well.
		'
		sqlCmd = _
			"	INSERT INTO exceptionComment" & _
			"		(" & _
			"		exceptionId," & _
			"		exceptionComment," & _
			"		userId," & _
			"		dateAdded," & _
			"		dateModified" & _
			"		)" & _
			"	SELECT	dst.exceptionId, ec.exceptionComment, ec.userId, ec.dateAdded, ec.dateModified" & _
			"	FROM" & _
			"		(" & _
			"			SELECT * FROM exception WHERE loanId = " & dbFormatId(primaryCollateralId) & _
			"		) AS src INNER JOIN" & _
			"		(" & _
			"			SELECT * FROM exception WHERE loanId = " & dbFormatId(theCrossCollateralId) & _
			"		) AS dst " & _
			"		ON src.exceptionDefId=dst.ExceptionDefId" & _
			"		INNER JOIN exceptionComment AS ec" & _
			"		ON ec.exceptionId=src.exceptionId"
		db.Execute sqlCmd
		
		' Copy the exception history also.
		'
		sqlCmd = _
			"	INSERT INTO exceptionHistory" & _
			"		(" & _
			"		exceptionId," & _
			"		changedByUserId," & _
			"		actionTaken," & _
			"		dateChanged" & _
			"		)" & _
			"	SELECT	dst.exceptionId, eh.changedByUserId, eh.actionTaken, eh.dateChanged" & _
			"	FROM" & _
			"		(" & _
			"			SELECT * FROM exception WHERE loanId = " & dbFormatId(primaryCollateralId) & _
			"		) AS src INNER JOIN" & _
			"		(" & _
			"			SELECT * FROM exception WHERE loanId = " & dbFormatId(theCrossCollateralId) & _
			"		) AS dst " & _
			"		ON src.exceptionDefId=dst.ExceptionDefId" & _
			"		INNER JOIN exceptionHistory AS eh" & _
			"		ON eh.exceptionId=src.exceptionId"
		db.Execute sqlCmd
			
	
		' Create documentHistory for uncrossed documents to copy in the primary documents
		' qcStatus and qcHistory.
		'
		sqlCmd = _
			" INSERT INTO documentHistory (" & _ 
			" 	userLogin," & _ 
			" 	userName," & _ 
			" 	customerNumber," & _ 
			" 	loanNumber," & _ 
			" 	documentFilename," & _ 
			" 	documentType," & _ 
			" 	pagesAdded," & _ 
			" 	pagesDeleted," & _ 
			" 	dateChanged," & _ 
			" 	documentDeletedYN," & _ 
			" 	comment," & _ 
			" 	documentId," & _ 
			" 	qcHistory," & _ 
			" 	inputType," & _ 
			" 	qcStatus" & _ 
			" )" & _ 
			" SELECT" & _ 
			" 	usr.userLogin," & _ 
			" 	usr.userName," & _ 
			" 	c.customerNumber," & _ 
			" 	l.loanNumber," & _ 
			" 	d.filename," & _ 
			" 	primaryHistory.documentType," & _ 
			" 	primaryHistory.pagesAdded," & _ 
			" 	primaryHistory.pagesDeleted," & _ 
			" 	GETDATE() AS dateChanged," & _ 
			" 	primaryHistory.documentDeletedYN," & _ 
			" 	N'User [' + usr.userName + '] converted the cross collateral to a regular collateral. The document was copied from the primary Customer [' + primary_customer.CustomerNumber + '] Loan Number [' + primary_loan.LoanNumber + '] Collateral Sequence [' + CAST(p_col.collateralSequence AS NVARCHAR(50)) + '].' AS comment," & _ 
			" 	d.documentId," & _ 
			" 	primaryHistory.qcHistory," & _ 
			" 	dhi.documentHistoryInputId AS inputType," & _ 
			" 	primaryHistory.qcStatus" & _ 
			" FROM" & _ 
			" 	#tmpDocumentMap AS temp INNER JOIN document AS d" & _ 
			" 		ON temp.uncrossed_documentId = d.documentId" & _ 
			" 	INNER JOIN loan AS l" & _ 
			" 		ON l.customerId = d.customerId" & _ 
			" 		AND l.loanId = d.loanId" & _ 
			" 	INNER JOIN customer AS c" & _ 
			" 		ON c.customerId = l.customerId" & _ 
			" 	INNER JOIN document AS primary_document" & _ 
			" 		ON primary_document.documentId = temp.primary_documentId" & _ 
			" 	INNER JOIN loan AS primary_collateral" & _
			" 		ON primary_collateral.loanId = primary_document.loanId" & _
			" 		AND primary_collateral.customerId = primary_document.customerId" & _
			" 	INNER JOIN collateral AS p_col" & _
			" 		ON p_col.collateralLoanId = primary_collateral.loanId" & _
			" 	INNER JOIN loan AS primary_loan" & _
			" 		ON primary_loan.loanId = p_col.parentLoanId" & _
			" 	INNER JOIN customer AS primary_customer" & _ 
			" 		ON primary_customer.customerId = primary_loan.customerId" & _ 
			" 	OUTER APPLY" & _ 
			" 	(" & _ 
			" 	    SELECT TOP(1)" & _ 
			" 			dh.documentType," & _ 
			" 			dh.pagesAdded," & _ 
			" 			dh.pagesDeleted," & _ 
			" 			dh.dateChanged," & _ 
			" 			dh.documentDeletedYN," & _ 
			" 			dh.qcHistory," & _ 
			" 			dh.qcStatus," & _ 
			" 			dh.documentId" & _ 
			" 	    FROM" & _ 
			" 			documentHistory dh INNER JOIN documentHistoryInput dhi " & _ 
			" 				ON dh.inputType = dhi.documentHistoryInputId" & _ 
			" 	    WHERE " & _ 
			" 			dhi.isFileChange = 1" & _ 
			" 			AND dh.documentId = temp.primary_documentId" & _ 
			" 		ORDER BY dh.dateChanged DESC" & _ 
			" 	) AS primaryHistory		" & _ 
			" 	OUTER APPLY (" & _ 
			" 		SELECT documentHistoryInputId" & _ 
			" 		FROM documentHistoryInput" & _ 
			" 		WHERE inputKey = 'acculoan.inputType.CopyMove'" & _ 
			" 	) AS dhi" & _ 
			" 	OUTER APPLY (" & _ 
			" 		SELECT " & _ 
			" 			u.userLogin," & _ 
			" 			u.userFirstName + ' ' + u.userLastName AS userName" & _ 
			" 		FROM [user] AS u" & _ 
			" 		WHERE u.userId = " & dbFormatId(Session("userId")) & _
			" 	) AS usr" & _ 
			" WHERE" & _ 
			" 	d.loanId = " & dbFormatId(theCrossCollateralId) & _
			" 	AND d.documentStatus = 1"
		db.Execute sqlCmd
		
		DropTempTables()
		response.write "[Convert2Collateral] End processing...<br><br>"	
	end function ' Convert2Collateral()
		
		
	Function BuildCollateralFieldInsertSQL(pid, ccid)
		Dim collateralQuery, collateralRS
		Set collateralRS = Server.CreateObject("ADODB.RecordSet")
		collateralQuery = "SELECT * FROM collateralFields WHERE collateralId = " & dbFormatId(pid)
response.write "collateralQuery = " & collateralQuery & "<br>"		
		collateralRS.Open collateralQuery, db, adOpenStatic, adCmdText
		
		if Not collateralRS.eof then
			Dim sqlQuery, fieldList, valueList, fieldType, fieldName, i, fieldDefIsCollateral
            Response.Write "g_collateralFieldDefCount = " & g_collateralFieldDefCount & "<br>"
            Response.Write "g_hasCollateralFieldDefList = " & g_hasCollateralFieldDefList & "<br>"
			if g_collateralFieldDefCount > 0 then 'g_hasCollateralFieldDefList then
				fieldList = ""
				valueList = ""
				for i = 0 to g_collateralFieldDefCount - 1
                    fieldDefIsCollateral = g_collateralFieldDefList(FIELD_DEF_COLLATERAL, i)
                    IF fieldDefIsCollateral THEN
					fieldType = g_collateralFieldDefList(FIELD_DEF_DATA_TYPE,i)
					fieldName = g_collateralFieldDefList(FIELD_DEF_NAME,i)
                        Response.Write "Processing [" & fieldName & "]...<br>"					
					fieldList = fieldList & fieldName & ","
					fieldList = fieldList & fieldName & "_isActive,"
					valueList = valueList & GetFormattedFieldValue(fieldType, collateralRS(fieldName)) & ","
					valueList = valueList & GetFormattedFieldValue("bit", collateralRS(fieldName & "_isActive")) & ","
                    END IF
				next 'i
				
				' Remove trailing comma
				'
				if i > 0 then
					fieldList = Left(fieldList, Len(fieldList)-1)
					valueList = Left(valueList, Len(valueList)-1)
					
					sqlQuery = "INSERT INTO collateralFields (collateralId," & fieldList & ") VALUES (" & dbFormatId(ccid) & "," & valueList & ");"
				end if
			end if
		end if ' Not collateralRS.eof
		
		collateralRS.Close
		
		BuildCollateralFieldInsertSQL = sqlQuery
	End Function 'BuildCollateralFieldInsertSQL
	
	Function GetFormattedFieldValue(theType, theValue)
		Dim result
		result = "NULL"
		
		if theType = "decimal" Or theType = "int" then
			result = dbFormatNumeric2(theValue, true)
		elseif theType = "bit" then
			result = dbFormatBoolean2(theValue, true)
		elseif theType = "datetime" then
			result = dbFormatDate2(theValue, true)
		else
			result = dbFormatText2(theValue, true)
		end if
		
		GetFormattedFieldValue = result
	End Function '


    Function BuildMassDocumentHistoryInsert(deletedLoanId, inputTypeId)
        Dim sqlCmd : sqlCmd = ""

        sqlCmd = _
            " INSERT INTO documentHistory (" & _
            " 	userLogin," & _
            " 	userName," & _
            " 	customerNumber," & _
            " 	loanNumber," & _
            " 	documentFileName," & _
            " 	documentType," & _
            " 	pagesAdded," & _
            " 	pagesDeleted," & _
            " 	dateChanged," & _
            " 	documentDeletedYN," & _
            " 	inputType," & _
            " 	comment" & _
            " )" & _
            " SELECT " & _
            dbFormatText(Session("userLogin")) & " AS userLogin," & _
            dbFormatText(Session("userName")) & " AS userName," & _
            " 	c.customerNumber," & _
            " 	l.loanNumber," & _
            " 	d.filename," & _
            " 	dd.documentTypeName + ' \ ' + dd.documentSubTypeName AS documentType," & _
            " 	0," & _
            " 	0," & _
            dbFormatDate(Now()) & " AS dateChanged," & _
            " 	1," & _
            dbFormatId(inputTypeId) & " AS inputType,	" & _
            " 	'User [' + " & dbFormatText(Session("userName")) & "+ '] has <b>deleted</b> this document from Customer [' + c.customerNumber + '] - Loan/Collateral Number [' + l.loanNumber + '].' AS scanHistoryComment" & _
            " FROM" & _
            " 	customer AS c INNER JOIN loan AS l" & _
            " 		ON c.customerId=l.customerId" & _
            " 	INNER JOIN qryDocumentDefinitions AS dd" & _
            " 		ON dd.loanTypeId=l.loanTypeId" & _
            " 	INNER JOIN documentTab AS dt" & _
            " 		ON dt.customerId=l.customerId" & _
            " 		AND dt.loanId=l.loanId" & _
            " 		AND dt.documentDefId=dd.documentDefId" & _
            " 	INNER JOIN document AS d" & _
            " 		ON d.documentTabId=dt.documentTabId" & _
            " WHERE" & _
            " 	l.loanId = " & dbFormatId(deletedLoanId) & _
            "   AND d.documentStatus = 1;"

        BuildMassDocumentHistoryInsert = sqlCmd
    End Function

    Sub DeleteLoanFiles(deletedLoanId)
        Dim documentQuery, documentRS
        Set documentRS = Server.CreateObject("ADODB.RecordSet")
        
        documentQuery = _
            " SELECT" & _
            "   c.customerFolder," & _
            "   l.loanFolder," & _
            "   d.loanFile," & _
            "   d.filename" & _
            " FROM" & _
            " 	customer AS c INNER JOIN loan AS l" & _
            " 		ON c.customerId=l.customerId" & _
            " 	INNER JOIN qryDocumentDefinitions AS dd" & _
            " 		ON dd.loanTypeId=l.loanTypeId" & _
            " 	INNER JOIN documentTab AS dt" & _
            " 		ON dt.customerId=l.customerId" & _
            " 		AND dt.loanId=l.loanId" & _
            " 		AND dt.documentDefId=dd.documentDefId" & _
            " 	INNER JOIN document AS d" & _
            " 		ON d.documentTabId=dt.documentTabId" & _
            " WHERE" & _
            "   l.loanId = " & dbFormatId(deletedLoanId)
        documentRS.Open documentQuery, db, adOpenStatic, adCmdText
        do until documentRS.Eof
            Dim customerFolder      : customerFolder = documentRS("customerFolder")
            Dim loanFolder          : loanFolder = documentRS("loanFolder")
            Dim tabFolder           : tabFolder = documentRS("loanfile")
            Dim filename            : filename = documentRS("filename")

            filePath = Session("fullpath") & "/" & customerFolder & loanFolder & tabFolder & "/" & documentRS("fileName")
			Call DeletePhysicalFile(filepath)	

            documentRS.MoveNext
        loop
        documentRS.Close
    End Sub

    ' Error handling code deals with issue of file being locked without cascading
    ' to other 
    Function DeletePhysicalFile(filepath)
        On Error Resume Next
        Dim fileDeleted : fileDeleted = true

        if g_fso.FileExists(filePath) then
	        g_fso.DeleteFile filePath, true
        end if

        If Err.Number <> 0 Then
            fileDeleted = false
        End If

        DeletePhysicalFile = fileDeleted
    End Function ' DeletePhysicalFile()

    Function CopyPhysicalFile( srcPath, dstPath)
        On Error Resume Next
        Dim fileCopied  : fileCopied = true
        
        Call g_fso.CopyFile( srcPath, dstPath, true)
        If Err.number <> 0 Then
            fileCopied = false
        End If

        CopyPhysicalFile = fileCopied
    End Function ' CopyPhysicalFile()

	FUNCTION DropTempTables()
		Dim sqlCmd : sqlCmd = _
			" IF OBJECT_ID('tempdb..#tmpDocumentMap') IS NOT NULL DROP TABLE #tmpDocumentMap;" & _
			" IF OBJECT_ID('tempdb..#tmpExceptionMap') IS NOT NULL DROP TABLE #tmpExceptionMap;" & _
			" IF OBJECT_ID('tempdb..#tmpCustomExceptionDefinitionMap') IS NOT NULL DROP TABLE #tmpCustomExceptionDefinitionMap;"
		db.Execute sqlCmd
	END FUNCTION 
%>