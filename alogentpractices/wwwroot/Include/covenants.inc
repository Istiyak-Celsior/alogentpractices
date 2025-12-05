<%
	' The following Functions/Subs are listed here for quick review/search
	'	BuildCovenantQuery( fieldId, fieldDefId)
	'	GetAccountCovenants( accountId)
	'	GetAccountCovenant( accountId, fieldDefId)
	'	GetCollateralCovenants( collateralId)
	'	GetCollateralCovenant( collateralId, fieldDefId)
	'	GetCovenantArray( sqlQuery)
	'	GetCreditCovenants( customerId)
	'	GetCreditCovenant( customerId, fieldDefId)
	'	IsCovenantException(currentValue, minValue, maxValue)
	'	IsCovenantOutOfDate(lastTestDate, testFrequency)
	
	
	' General Notes
	'
	' Arrays: 
	'	Covenant Arrays are two-dimensional due to using the RecordSet GetRows function.
	'	The first dimension of the array signifies the Column of the data table. The second
	'	dimension indicates the data row of the table returned. So data should be accessed as
	'		value = array(columnIndex, rowIndex)
	'
	'	Also note that if there are no data rows returned, a single 2D array will be returned
	'	consisting of a single data row of columns whose elements default to variant default values.
	'	So if the CovenentId for the first row is "blank", no record was found
	'		if covenantList(COVENANT_ID,0) = "" then
	'			no record returned from database
	'
	
	
	' Covenant Field Name Constants for array access
	'
	CONST COVENANT_ID = 0
	CONST COVENANT_FIELD_DEF_ID = 1
	CONST COVENANT_FIELD_ID = 2
	CONST COVENANT_USE_MASTER = 3
	CONST COVENANT_MIN_VALUE = 4
	CONST COVENANT_MAX_VALUE = 5
	CONST COVENANT_TEST_FREQUENCY = 6
	CONST COVENANT_LAST_TEST_DATE = 7
	CONST COVENANT_DEFAULT_MIN_VALUE = 8
	CONST COVENANT_DEFAULT_MAX_VALUE = 9
	
	
	' This should be modified if more columns are added. It's used to ReDim
	' an empty array if no records are found in the database
	'
	CONST COVENANT_MAX_COLUMNS = 9
	
	
	' Test Frequancy constants
	'
	CONST COVENANT_FREQ_NONE = 0
	CONST COVENANT_FREQ_MONTHLY = 1
	CONST COVENANT_FREQ_QUARTERLY = 2
	CONST COVENANT_FREQ_SEMI_ANNUALLY = 3
	CONST COVENANT_FREQ_ANNUALLY = 4
	
	
	' Function: BuildCovenantQuery
	' Description:
	'	Builds a SQL query string the will, when executed, return
	'	the Covenant record for the specfied fieldId and fieldDefId.
	'
	' Returns:
	'	SQL query string to be executed.
	'
	Function BuildCovenantQuery(fieldId, fieldDefId)
		Dim fieldDefClause : fieldDefClause = ""
		
		if fieldDefId <> "" then
			fieldDefClause = " AND c.fieldDefId=" & dbFormatId(fieldDefId)
		end if
		
		Dim sqlQuery
		sqlQuery = _
			" SELECT" & _
			"	c.CovenantId," & _
			"	c.FieldDefId," & _
			"	c.FieldId," & _
			"	c.UseMasterValues," & _
			"	c.MinValue," & _
			"	c.MaxValue," & _
			"	c.TestFrequency," & _
			"	c.LastTestDate," & _
			"	fd.CovenantDefaultMinValue," & _
			"	fd.CovenantDefaultMaxValue" & _
			" FROM" & _
			"	covenant AS c INNER JOIN fieldDefinition AS fd" & _
			"		ON c.fieldDefId=fd.fieldDefId" & _
			" WHERE" & _
			"	c.FieldId = " & dbFormatId(fieldId) & _
			fieldDefClause & _
			" ORDER BY" & _
			"	fd.fieldDefDisplayOrder"
		BuildCovenantQuery = sqlQuery
	End Function 'BuildCovenantQuery()
	
	
	' Function: GetAccountCovenants
	' Description:
	'	Returns a 2D array of all Account Covenants for the specified accountId.
	'
	' Returns:
	'	2D array of Covenants of the given Account.
	'
	Function GetAccountCovenants(accountId)
		Dim covenantList
		Dim sqlQuery :	sqlQuery = BuildCovenantQuery(accountId, "")
		covenantList = GetCovenantArray(sqlQuery)
		GetAccountCovenants = covenantList
	End Function 'GetAccountCovenants()
	
	
	' Function: GetAccountCovenant
	' Description:
	'	Gets a specific Account Covenant
	'
	' Returns:
	'	2D array of specific Covenant for given Account.
	'
	Function GetAccountCovenant(accountId, fieldDefId)
		Dim covenantList
		Dim sqlQuery : sqlQuery = BuildCovenantQuery(accountId, fieldDefId)
		covenantList = GetCovenantArray(sqlQuery)
		GetAccountCovenant = covenantList
	End Function 'GetAccountCovenant()
	
	
	' Function: GetCollateralCovenants
	' Description:
	'	Gets an array of Covenants for the specified Collateral.
	'
	' Returns:
	'	2D array of a Collateral's Covenants for all FlexField instances.
	'
	Function GetCollateralCovenants(collateralId)
		Dim covenantList
		Dim sqlQuery : sqlQuery = BuildCovenantQuery(collateralId, "")
		covenantList = GetCovenantArray(sqlQuery)
		GetCollateralCovenants = covenantList
	End Function 'GetCollateralCovenants()
	
	
	' Function: GetCollateralCovenant
	' Description:
	'	Given Collateral and specific FlexField it will return the Covenant information
	'	for associated Collateral FlexField instance.
	'
	' Returns:
	'	2D array of a Collateral's Covenant information for a specific FlexField instance.
	'
	Function GetCollateralCovenant(collateralId, fieldDefId)
		Dim covenantList
		Dim sqlQuery : sqlQuery = BuildCovenantQuery(collateralId, fieldDefId)
		covenantList = GetCovenantArray(sqlQuery)
		GetCollateralCovenant = covenantList
	End Function 'GetCollateralCovenant()
	
	
	' Function: GetCovenantArray
	' Description:
	'	Given a SQL query it returns an 2D array of results from the Covenant Table.
	'	If no results then the array consists of a single data row of "empty" elements.
	'
	' Returns:
	'	2D array of Covenant data rows.
	'
	Function GetCovenantArray(sqlQuery)
		Dim arr
		Dim sqlRS : Set sqlRS = Server.CreateObject("ADODB.RecordSet")
		sqlRS.Open sqlQuery, db, adOpenForwardOnly, adLockReadOnly
		
		IF NOT sqlRS.EOF THEN
			arr = sqlRS.GetRows()
		ELSE
			ReDim arr(COVENANT_MAX_COLUMNS,0)
		END IF
		
		sqlRS.Close
		
		GetCovenantArray = arr
	End Function
	
	
	' Function: GetCreditCovenants
	' Description:
	'	Gets an array of credit Covenants for the specified Customer.
	'
	' Returns:
	'	2D array of a Collateral's Covenants for all FlexField instances.
	'
	Function GetCreditCovenants(customerId)
		Dim covenantList
		Dim sqlQuery : sqlQuery = BuildCovenantQuery(customerId, "")
		covenantList = GetCovenantArray(sqlQuery)
		GetCreditCovenants = covenantList
	End Function 'GetCreditCovenants()
	
	
	' Function: GetCreditCovenant
	' Description:
	'	Gets the array for specific credit Covenant for the given customer
	'
	' Returns:
	'	2D array of the specific Covenant for the given FlexField instance.
	'
	Function GetCreditCovenant(customerId, fieldDefId)
		Dim covenantList
		Dim sqlQuery : sqlQuery = BuildCovenantQuery(customerId, fieldDefId)
		covenantList = GetCovenantArray(sqlQuery)
		GetCreditCovenant = covenantList
	End Function 'GetCreditCovenant
	
	
	' Function: IsCovenantException
	' Description:
	'	Tests if current Covenant Value is an exception. If the current value
	'	is less then the MinValue or the current value is greater then the MaxValue,
	'	then it is an exception.
	'
	'	if a Test Value is not valid (due to it being NULL) then that test condtion
	'	is ignored.
	'
	' Returns:
	'	true if an exception, false otherwise.
	'
	Function IsCovenantException(currentValue, minValue, maxValue)
		Dim result : result = false
		Dim tmpValue : tmpValue = Trim(currentValue)
		Dim tmpMin : tmpMin = Trim(minValue)
		Dim tmpMax : tmpMax = Trim(maxValue)
		
		if IsNumeric(tmpValue) And IsNumeric(tmpMin) then
			if CDbl(tmpValue) < CDbl(tmpMin) then
				result = true
			end if
		end if
		
		if IsNumeric(tmpValue) And IsNumeric(tmpMax) then
			if CDbl(tmpValue) > CDbl(tmpMax) then
				result = true
			end if
		end if
		
		IsCovenantException = result
	End Function 'IsCovenantException()
	
	
	' Function: IsCovenantOutOfDate
	' Description:
	'	Checks to see if the the Covenants LastTestDate + the testFrequency is 
	'	less than the current Date to see if the Covenant is "out of date".
	'
	'	if the TestFrequency is Never then it always returns false.
	'
	'	if the LastTestValue is blank then it always returns true.
	'
	' Returns:
	'	true if out of date, false otherwise.
	'
	Function IsCovenantOutOfDate(lastTestDate, testFrequency)
		Dim retest : retest = false
		if CInt(testFrequency) = COVENANT_FREQ_NONE then
			retest = false
		elseif IsDate(Trim(lastTestDate)) then
			' Calculate if Covenant needs retesting based on lastTestDate and
			' the testFrequency
			'
			Dim adjustedDate

			if CInt(testFrequency) = COVENANT_FREQ_MONTHLY then
				adjustedDate = DateAdd("m", 1, lastTestDate)
			elseif CInt(testFrequency) = COVENANT_FREQ_QUARTERLY then
				adjustedDate = DateAdd("q", 1, lastTestDate)
			elseif CInt(testFrequency) = COVENANT_FREQ_SEMI_ANNUALLY then
				adjustedDate = DateAdd("m", 6, lastTestDate)
			elseif CInt(testFrequency) = COVENANT_FREQ_ANNUALLY then
				adjustedDate = DateAdd("yyyy", 1, lastTestDate)
			end if
			
			' Is today greater than the last time we tested with frequency adjustments
			'
			if CDate(Now()) > adjustedDate then
				retest = true
			end if
		else
			retest = true
		end if
		
		IsCovenantOutOfDate = retest
	End Function
	
	
	' Helper function for debugging.
	'
	Sub DisplayCovenantArray(arr)
		Dim idx
		for idx = LBound(arr,1) to UBound(arr,1)
			response.write "element(" & idx & ") = " & arr(idx,0) & "<br>"
		next
		response.write "<br>"
	End Sub
%>