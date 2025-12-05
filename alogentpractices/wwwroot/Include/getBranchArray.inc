<%
' ### Developer Notes ###
' The getBranchArray is a 2-dimensional array of branch info from the branch table. The first
' index refers to the data column and the second index refers to the branch record
' 
' The data columns are indexed with the following values:
'     0 = bankId
'     1 = bankName
'     2 = branchId
'     3 = branchName
'     4 = regionName
'     5 = accessBranchId
'     6 = hasAccess
	
CONST BRANCH_BANK_ID = 0
CONST BRANCH_BANKNAME = 1
CONST BRANCH_ID = 2
CONST BRANCH_NAME = 3
CONST BRANCH_REGION_ID = 4
CONST BRANCH_ACCESSBRANCHID = 5
CONST BRANCH_HAS_ACCESS = 6
	
Dim branchQuery, branchCounter, branchRows, branchDefault, branchArray, gba
Dim branchRS : Set branchRS = Server.CreateObject("ADODB.Recordset")

' ### If Branch Security is Turned on then Only Generate the Branches that are Assigned to the Signed on User ###
IF NOT Session("isSuperUser") AND Session("bankSecurity") <> "XX" AND Session("UseBranchSecurity") = "Y" THEN
	IF Session("bankSecurity") = "DO" THEN
		'### NOTE this query is for partial branch security when we want the list of all branches but need a flag to indicate if
		'### user has access or not for display purposes. This is primarily due the array is used by a number of pages that focused on Full Branch security
		'### versus No Branch security
		branchQuery = _
			" SELECT " & _
			"	b.bankId," & _
			"	b.bankName," & _
			"	br.branchId," & _
			"	br.branchName," & _
			"	reg.regionName," & _
			"	CASE WHEN (ubs.branchSecurityId IS NOT NULL AND u.isSuperUser=0) THEN br.branchId ELSE NULL END AS branchAccessId," & _
			"	CASE WHEN (ubs.branchSecurityId IS NOT NULL AND u.isSuperUser=0) THEN 1 ELSE 0 END AS hasBranchAccess" & _
			" FROM" & _
			"	branch AS br INNER JOIN bank AS b" & _
			"		ON br.bankId=b.bankId" & _
			"	LEFT OUTER JOIN region AS reg" & _
			"		ON reg.regionId=br.regionId" & _
			"	LEFT OUTER JOIN viewUserBranchSecurity AS ubs" & _
			"		ON ubs.branchId=br.branchId" & _
			"		AND ubs.userId=" & dbFormatId(Session("userId")) & _
			"	CROSS JOIN [user] AS u" & _
			" WHERE" & _
			"	u.userId=" & dbFormatId(Session("userId")) & _
			"ORDER BY b.bankName ASC, reg.regionName ASC, br.branchName ASC"
	ELSEIF Session("bankSecurity") = "DU" THEN
		'### This is the original query for Full Branch Security when not a Super User
		branchQuery = _
			" SELECT b.bankId, b.bankName, br.branchId, br.branchName, reg.regionName, br.branchId AS accessBranchId, 1 AS hasBranchAccess" & _
			" FROM" & _
			"   branch AS br INNER JOIN bank AS b" & _
			"       ON b.bankId = br.bankId" & _
			"   LEFT OUTER JOIN region AS reg" & _
			"       ON reg.regionId = br.regionId" & _
			"   WHERE br.branchId IN" & _
			"       (SELECT branchId FROM viewUserBranchSecurity WHERE userId = " & dbFormatId(Session("userId")) & ") " & _
			" ORDER BY b.bankName ASC, reg.regionName ASC, br.branchName ASC"

	END IF
ELSE
	'### This is the original query for No Branch Security
    branchQuery = _
        " SELECT" & _
        "       b.bankId, b.bankName, br.branchId, br.branchName, reg.regionName, br.branchId AS accessBranchId, 1 AS hasBranchAccess" & _
        " FROM" & _
        "   branch AS br INNER JOIN bank AS b" & _
        "       ON b.bankId = br.bankId" & _
        "   LEFT OUTER JOIN region AS reg" & _
        "       ON reg.regionId = br.regionId" & _
        " ORDER BY b.bankName ASC, reg.regionName, br.branchName ASC"
END IF

branchRS.Open branchQuery, db, adOpenForwardOnly, adLockReadOnly

branchRows = 0
IF NOT branchRS.EOF THEN
    branchArray = branchRS.GetRows()
    IF isArray(branchArray) THEN
        FOR gba = 0 TO uBound(branchArray, 2)
            branchRows = branchRows + 1
        NEXT
    END IF
ELSE
    branchRows = -1 ' ### No records found.
END IF

branchRS.Close
Set branchRS = Nothing
%>