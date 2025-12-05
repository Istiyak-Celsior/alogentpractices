<%
	Function GetUserViewStatusFilter(filterKey)
		Dim result
		result = Session(filterKey)
		
		if result = "" then
			result = Request.Cookies("AccuLoan")(filterKey)
			if result = "" then
				result = "all"
				Response.Cookies("AccuLoan")(filterKey) = result
			end if
			
			Session(filterKey) = result
		end if
		
		GetUserViewStatusFilter = result
	End Function
%>
