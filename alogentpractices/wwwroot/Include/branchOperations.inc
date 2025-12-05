<% 
' ### This function does the processing for the branch security processing to enter data into the 
' userBranchSecurity table. ###
	
FUNCTION branchOperations(theProcessCode , theUserid)
	Dim userID : userID = theUserid
	Dim changedBy : changedBy = session("userName")
	Dim listOfBranchIDs : listOfBranchIDs = Session("theBranches")
	Dim Msgs : Msgs = ""
	
	Dim branchSecurityQuery : branchSecurityQuery = "DELETE FROM userBranchSecurity WHERE userId=" & dbFormatId(userID)
	db.Execute userbanksecurityQuery  
	
	Dim branchArray : branchArray = Split(listOfBranchIDs,",")
	Dim branchCount : branchCount = uBound(branchArray)
	
	IF listOfBranchIDs = "none" THEN
		Msgs = "Error No Branches to Add"
	ELSE
		Msgs = "Branches Added"
		branchSecurityQuery = "DELETE FROM userBranchSecurity WHERE userId=" & dbFormatId(userID)
		db.Execute branchSecurityQuery
			
		Dim theDate : theDate = Now()
		theDate = dbFormatDate2(theDate,False)
			
		FOR x = 0 TO branchCount
			branchSecurityQuery = _
				" INSERT INTO userBranchSecurity (" & _
				"	branchID," & _
				"	userID," & _                   
				"	DateCreated," & _
				"	DateChanged," & _
				"	ChangedBy" & _
				"	) VALUES (" & _
				dbFormatId(branchArray(x)) & ", " & _
				dbFormatId(userID) & ", " & _
				theDate & ", " & _
				theDate & ", '" & _
				changedBy & "'" & _
				" )"	
			db.Execute branchSecurityQuery
		NEXT
	END IF
	branchOperations = Msgs
END FUNCTION
%>
