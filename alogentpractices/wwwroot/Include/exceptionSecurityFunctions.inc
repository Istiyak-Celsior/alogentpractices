<%
	
	
	Function IsExceptionReader
		Dim result
		result = false
		
		if	Session("permissionException") >= 1 _
			Or Session("isSuperUser") then
			result = true
		end if
		
		IsExceptionReader = result
	End Function 'IsExceptionReader()
	
	
	Function IsExceptionEditor
		Dim result
		result = false
		
		if	Session("permissionException") >= 2 _
			Or Session("isSuperUser") then
			result = true
		end if
		
		IsExceptionEditor = result
	End Function 'IsExceptionEditor()
	
	
	Function isExceptionAdministrator
		Dim result
		result = false
		
		if	Session("permissionException") >= 3 _
			Or Session("isSuperUser") then
			result = true
		end if
		
		isExceptionAdministrator = result
	End Function 'isExceptionAdministrator()

%>