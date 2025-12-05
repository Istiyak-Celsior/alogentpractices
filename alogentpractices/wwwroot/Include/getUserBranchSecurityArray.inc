<%
' Developer Notes:
'		The getBranchArray is a 2-dimensional array of branch security info from the [userBranchSecurity] table. 
'		The first index refers to the data column and the second index refers to the data.
'
'		The data columns are indexed with the following values:
'			0 = branchID
'			1 = userId
'			2 = branchName

CONST BRSEC_BRANCHID = 0
CONST BRSEC_USERID = 1
CONST BRSEC_BRANCHNAME = 2

Dim userBranchSecurityRS, userBranchSecurityQuery, userBranchSecurityArray, userBranchSecurityRows
Set userBranchSecurityRS = Server.CreateObject("ADODB.Recordset")

if Request("userid") <> "" then
	userLogin = Request("userid")
else
	userLogin = Session("userId")
end if

IF Session("bankSecurity") = "XX" OR UCase(Session("UseBranchSecurity")) = "N" then
	userBranchSecurityQuery = _
		" SELECT" & _
		" 	br.branchId," & _
		" 	u.userId," & _
		" 	br.branchName" & _
		" FROM" & _
		" 	[user] AS u CROSS JOIN branch AS br" & _
		" 	LEFT OUTER JOIN userBranchSecurity AS ubs" & _
		" 		ON ubs.userId=u.userId" & _
		" 		AND ubs.branchId=br.branchId" & _
		" WHERE" & _
		"	u.userId=" & dbFormatId(userLogin) & _
		" ORDER BY" & _
		" 	br.branchName"
ELSE
	userBranchSecurityQuery = _
		" SELECT" & _
		"     brsec.branchID, brsec.userID, branch.branchName" & _
		" FROM" & _
		"     [userBranchSecurity] AS brsec" & _
		" INNER JOIN" & _
		"	  branch ON branch.branchId = brsec.branchID" & _
		" WHERE (brsec.userID = " & dbFormatId(userLogin) & ")" & _
		" ORDER BY branch.branchName"	
END IF
userBranchSecurityRS.Open userBranchSecurityQuery, db, adOpenStatic

if NOT userBranchSecurityRS.eof then
	userBranchSecurityArray = userBranchSecurityRS.GetRows()
	userBranchSecurityRows = Ubound(userBranchSecurityArray,2)
else
	userBranchSecurityRows = -1 'No records found.
end if

userBranchSecurityRS.Close
set userBranchSecurityRS = Nothing
%>