<%
	' Function: GetFlexField
	' Description:
	'	Given the metadata about a particular FlexField instance, this function returns
	'	the current value of the given FlexField instance.
	'
	'	This value is stored as a 2D array with the first dimension indexing the column details and
	'	and the second dimension indexing a specific FlexField (for multiple FlexFields).
	'	This function only returns one FlexField instance so the second dimension will always be 0 (1 element)
	'	and described as follows:
	'		array(0,0) -- contains the value of the flex field
	'		array(1,0) -- holds the isActive flag for the flex field
	'
	'	NOTE: this is provided to get access to a specific FlexField on the fly. It should not be called as
	'	part of a loop to avoid multiple database hits.
	'
	' Returns:
	'	2D array consisting of a single FlexField instance
	'
	Function GetFlexField(fieldTable, fieldColumn, fieldId, fieldDefName)
		Dim result(1,0)
		Dim fieldQuery, fieldRS
		Set fieldRS = Server.CreateObject("ADODB.RecordSet")
		
		' Get the instance field joined with the field definition to get
		' defaults if necessary.
		'
		fieldQuery = _
			" SELECT " & _
			fieldDefName & ", " & _
			" IsNull(" & fieldDefName & "_isActive, fd.isActive) AS " & fieldDefName & "_isActive" & _
			" FROM " & _
			fieldTable & " CROSS JOIN fieldDefinition AS fd" & _
			" WHERE " & _
			fieldColumn & " = " & dbFormatId(fieldId) & _
			" AND fd.fieldDefName LIKE " & dbFormatText(fieldDefName)
		fieldRS.Open fieldQuery, db, adOpenStatic, adCmdText
		
		if Not fieldRS.eof then
			result(0,0) = Trim(fieldRS(fieldDefName))
			result(1,0) = Trim(fieldRS(fieldDefName & "_isActive"))
		else
			result(0,0) = ""
			result(1,0) = 0
		end if
		
		fieldRS.Close
		
		GetFlexField = result
	End Function ' GetFlexField()
	
%>
