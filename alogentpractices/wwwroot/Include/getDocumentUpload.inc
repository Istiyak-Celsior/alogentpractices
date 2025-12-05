<%
	' Constants for accessing the Table columns by name in the array. The
	' constant is used in the first array position in the 2-d array. The
	' second array index is for the table row position.
	'
	CONST DU_CUSTOMER_ID = 0
	CONST DU_CUSTOMER_TYPE_ID = 1
	CONST DU_CUSTOMER_NUMBER = 2
	CONST DU_CUSTOMER_NAME = 3
	CONST DU_CUSTOMER_FOLDER = 4
	CONST DU_LOAN_ID = 5
	CONST DU_LOAN_TYPE_ID = 6
	CONST DU_LOAN_NUMBER = 7
	CONST DU_LOAN_FOLDER = 8
	CONST DU_GROUP_NAME = 9
	CONST DU_TAB_NAME = 10
	CONST DU_TAB_FOLDER = 11
	CONST DU_FILENAME = 12
	CONST DU_TITLE = 13
	CONST DU_COMMENT = 14
	CONST DU_EXP_DATE = 15
	CONST DU_DOCUMENT_CODE = 16
	CONST DU_UPLOAD_SOURCE = 17
	CONST DU_UPLOADED_BY = 18
	CONST DU_DOCUMENT_UPLOAD_ID = 19
	CONST DU_UPLOAD_PATH = 20
	CONST DU_ACCOUNT_CLASS_NAME = 21
	CONST DU_ACCOUNT_CLASS_CODE = 22
    CONST DU_LOAN_TYPE_DESCRIPTION = 23
	CONST DU_COLLATERAL_PARENT_LOAN_ID = 24
	CONST DU_CUSTOMER_IS_EMPLOYEE = 25
	CONST DU_BRANCH_ID = 26
	CONST DU_HIDE_EMPLOYEE_FILE_YN = 27
	CONST DU_HAS_DEMOGRAPHIC_DATA = 28
	CONST DU_DOCUMENT_SUB_TYPE_ID = 29


	' Fill array with result contents
	'
	Dim gdu
	Dim g_documentUploadList, g_documentUploadCount
	Dim g_documentUploadQuery, g_documentUploadRS
	Set g_documentUploadRS = Server.CreateObject("ADODB.RecordSet")
	
	Dim uploadDirString : uploadDirString = GetCurrentUploadDirectory("uploadDir")
	Dim uploadDirStringBack : uploadDirStringBack = ""
	IF InStr(uploadDirString, "\") > 0 THEN
		uploadDirStringBack = Replace(uploadDirString, "\", "/")
	ELSE
		uploadDirStringBack = Replace(uploadDirString, "/", "\")
	END IF
	g_documentUploadQuery = _
		" SELECT" & _
		"	c.customerId," & _
		"	c.customerTypeId," & _
		"	c.customerNumber," & _
		"	c.customerName," & _
		"	c.customerFolder," & _
		"	NULL AS loanId," & _
		"	NULL AS loanTypeId," & _
		"	NULL AS loanNumber," & _
		"	NULL AS loanFolder," & _
		"	dt.documentTypeName," & _
		"	dst.documentSubTypeName," & _
		"	dd.defaultName AS tabFolder," & _
		"	du.documentFilename," & _
		"	du.documentTitle," & _
		"	CONVERT(nvarchar(MAX),du.documentComment) AS documentComment," & _
		"	du.documentExpDate," & _
		"	du.documentCode," & _
		"	du.uploadSource," & _
		"	du.uploadedBy," & _
		"	du.documentUploadId," & _
		"	du.UploadPath," & _
		"	'' AS accountClassName," & _
		"	'credit' AS accountClassCode," & _
        "   '' AS loanTypeDescription," & _
		"   NULL AS parentLoanId," & _
		"	c.employee," & _
		"	c.customerBranchId AS branchId," & _
		"	dd.hideEmployeeFileYN," & _
		"	dsto.hasDemographicData," & _
		"	dd.documentSubTypeId" & _
		" FROM" & _
		"	customer AS c INNER JOIN documentDefinitions AS dd" & _
		"		ON c.customerTypeId=dd.customerTypeId" & _
		"		AND c.bankId=dd.bankId" & _
		"	INNER JOIN documentType AS dt" & _
		"		ON dt.documentTypeId=dd.documentTypeId" & _
		"	INNER JOIN documentSubType AS dst" & _
		"		ON dst.documentSubTypeId=dd.documentSubTypeId" & _
		"		AND dst.documentTypeId=dt.documentTypeId" & _
		"	INNER JOIN documentSubTypeOption AS dsto" & _
		"		ON dsto.documentSubTypeId = dst.documentSubTypeId" & _
		"	INNER JOIN documentUpload AS du" & _
		"		ON LOWER(du.customerNumber) = LOWER(c.customerNumber)" & _
		"		AND du.loanNumber IS NULL" & _
        "       AND du.customerNumber = c.customerNumber" & _
		" WHERE" & _
		"	( " & _
		"		LOWER(du.UploadPath) = LOWER(" & dbFormatText(uploadDirString) & ")" & _
		"	OR " & _
		"		LOWER(du.UploadPath) = LOWER(" & dbFormatText(uploadDirStringBack) & ")" & _
		"	) " & _
		"	AND LOWER(dst.documentCode) = LOWER(du.documentCode)" & _
		" UNION ALL" & _
		" SELECT" & _
		"	CASE" & _
		"		WHEN l.isCrossCollateralYN = 'Y' THEN" & _
		"			primaryCustomer.customerId" & _
		"		ELSE" & _
		"			c.customerId" & _
		"		END AS customerId," & _
		"	CASE" & _
		"		WHEN l.isCrossCollateralYN = 'Y' THEN" & _
		"			primaryCustomer.customerTypeId" & _
		"		ELSE" & _
		"			c.customerTypeId" & _
		"		END AS customerTypeId," & _
        "	CASE" & _
		"		WHEN l.isCrossCollateralYN = 'Y' THEN" & _
		"			primaryCustomer.customerNumber" & _
		"		ELSE" & _
		"			c.customerNumber" & _
		"		END AS customerNumber," & _
		"	CASE" & _
		"		WHEN l.isCrossCollateralYN = 'Y' THEN" & _
		"			primaryCustomer.customerName" & _
		"		ELSE" & _
		"			c.customerName" & _
		"		END AS customerName," & _
        "	CASE" & _
		"		WHEN l.isCrossCollateralYN = 'Y' THEN" & _
		"			primaryCustomer.customerFolder" & _
		"		ELSE" & _
		"			c.customerFolder" & _
		"		END AS customerFolder," & _
		"	CASE" & _
		"		WHEN l.primaryCollateralId IS NOT NULL THEN" & _
		"			primaryCollateral.loanId" & _
		"		ELSE" & _
		"			l.loanId" & _
		"		END AS loanId," & _
		"	CASE" & _
		"		WHEN l.primaryCollateralId IS NOT NULL THEN" & _
		"			primaryCollateral.loanTypeId" & _
		"		ELSE" & _
		"			l.loanTypeId" & _
		"		END AS loanTypeId," & _
		"	CASE" & _
		"		WHEN l.primaryCollateralId IS NOT NULL THEN" & _
		"			IsNull(primaryCollateral.loanNumber, '')" & _
		"		ELSE" & _
		"			IsNull(l.loanNumber, '')" & _
		"		END AS loanNumber," & _
		"	CASE" & _
		"		WHEN l.primaryCollateralId IS NOT NULL THEN" & _
		"			IsNull(primaryCollateral.loanFolder, '')" & _
		"		ELSE" & _
		"			IsNull(l.loanFolder, '')" & _
		"		END AS loanFolder," & _
		"	dt.documentTypeName," & _
		"	dst.documentSubTypeName," & _
		"	dd.defaultName AS tabFolder," & _
		"	du.documentFilename," & _
		"	du.documentTitle," & _
		"	CONVERT(nvarchar(MAX),du.documentComment) AS documentComment," & _
		"	du.documentExpDate," & _
		"	du.documentCode," & _
		"	du.uploadSource," & _
		"	du.uploadedBy," & _
		"	du.documentUploadId," & _
		"	du.UploadPath," & _
		"	ac.accountClassName," & _
		"	CASE" & _
		"		WHEN ls.isApplicationStatus = 1 THEN 'loanapp'" & _
		"		ELSE ac.accountClassCode" & _
		"	END AS accountClassCode," & _
        "   lt.loanTypeDescription," & _
		"	cl.parentLoanId," & _
		"	c.employee," & _
		"	l.loanBranchId AS branchId," & _
		"	dd.hideEmployeeFileYN," & _
		"	dsto.hasDemographicData," & _
		"	dd.documentSubTypeId" & _
		" FROM" & _
		"	customer AS c INNER JOIN loan AS l" & _
		"		ON c.customerId=l.customerId" & _
		"	INNER JOIN loanStatus AS ls" & _
		"		ON ls.statusId = l.loanStatusId" & _
		"	INNER JOIN loanType AS lt" & _
		"		ON lt.loanTypeId=l.loanTypeId" & _
		"	INNER JOIN accountClass AS ac" & _
		"		ON ac.accountClassId=lt.accountClassId" & _
		"	INNER JOIN documentDefinitions AS dd" & _
		"		ON dd.loanTypeId=l.loanTypeId" & _
		"		AND c.bankId=dd.bankId" & _
		"	INNER JOIN documentType AS dt" & _
		"		ON dt.documentTypeId=dd.documentTypeId" & _
		"	INNER JOIN documentSubType AS dst" & _
		"		ON dst.documentSubTypeId=dd.documentSubTypeId" & _
		"		AND dst.documentTypeId=dt.documentTypeId" & _
		"	INNER JOIN documentSubTypeOption AS dsto" & _
		"		ON dsto.documentSubTypeId = dst.documentSubTypeId" & _
		"	INNER JOIN documentUpload AS du" & _
		"		ON LOWER(du.loanNumber) = LOWER(l.loanNumber)" & _
		"		AND du.loanTypeId=l.loanTypeId" & _
        "       AND du.customerNumber = c.customerNumber" & _
		"	LEFT OUTER JOIN collateral AS cl" & _
		"		ON cl.collateralLoanId=l.loanId" & _
		"	LEFT OUTER JOIN loan AS primaryCollateral" & _
		"		ON primaryCollateral.loanId=l.primaryCollateralId" & _
		"	LEFT OUTER JOIN customer AS primaryCustomer" & _
		"		ON primaryCustomer.customerId=primaryCollateral.customerId" & _
		" WHERE" & _
		"	( " & _
		"		LOWER(du.UploadPath) = LOWER(" & dbFormatText(uploadDirString) & ")" & _
		"	OR " & _
		"		LOWER(du.UploadPath) = LOWER(" & dbFormatText(uploadDirStringBack) & ")" & _
		"	) " & _
		"	AND LOWER(dst.documentCode) = LOWER(du.documentCode)"		

	db.CommandTimeout = 90 'secs
	g_documentUploadRS.Open g_documentUploadQuery, db
	g_documentUploadCount = 0
	IF NOT g_documentUploadRS.EOF THEN
		g_documentUploadList = g_documentUploadRS.GetRows()
		IF isArray(g_documentUploadList) THEN
		    FOR gdu = 0 TO uBound(g_documentUploadList, 2)
		        g_documentUploadCount = g_documentUploadCount + 1
		    NEXT
		END IF
	END IF
	g_documentUploadRS.Close
	
	' Create a mapping of Lower Case filenames to the record's array index
	' NOTE: this is for speed up for finding document fingerprints in
	' the documentUpload table.
	'
	Dim g_documentUploadDict
	Set g_documentUploadDict = Server.CreateObject("Scripting.Dictionary")
	
	Dim g_documentUploadDictById
	Set g_documentUploadDictById = Server.CreateObject("Scripting.Dictionary")
	
	Dim g_idx
	for g_idx = 0 to g_documentUploadCount - 1
		if Not g_documentUploadDict.Exists(LCase(g_documentUploadList(DU_FILENAME, g_idx))) then
			g_documentUploadDict.Add LCase(g_documentUploadList(DU_FILENAME, g_idx)), g_idx
		end if
		
		if Not g_documentUploadDictById.Exists(LCase(g_documentUploadList(DU_DOCUMENT_UPLOAD_ID, g_idx))) then
			g_documentUploadDictById.Add LCase(g_documentUploadList(DU_DOCUMENT_UPLOAD_ID, g_idx)), g_idx
		end if
	next 'g_idx
%>