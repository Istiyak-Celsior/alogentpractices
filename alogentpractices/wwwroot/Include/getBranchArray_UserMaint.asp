<%
CONST BRANCH_BANK_ID = 0
CONST BRANCH_BANKNAME = 1
CONST BRANCH_ID = 2
CONST BRANCH_NAME = 3
CONST BRANCH_REGION_ID = 4
CONST BRANCH_ACCESSBRANCHID = 5

Dim branchQuery, branchCounter, branchRows, branchDefault, branchArray
Dim branchRS : Set branchRS = Server.CreateObject("ADODB.Recordset")

' ### If Branch Security is Turned on then Only Generate the Branches that are Assigned to the Signed on User ###
IF Session("isFullBranchSecurity") AND NOT IsAdministrator() THEN
    branchQuery = _
        " SELECT b.bankId, b.bankName, br.branchId, br.branchName, reg.regionName, br.branchId AS accessBranchId" & _
        " FROM" & _
        "   branch AS br INNER JOIN bank AS b" & _
        "       ON b.bankId = br.bankId" & _
        "   LEFT OUTER JOIN region AS reg" & _
        "       ON reg.regionId = br.regionId" & _
        "   WHERE br.branchId IN" & _
        "       (SELECT branchId FROM viewUserBranchSecurity WHERE userId = " & dbFormatId(Session("userId")) & ") " & _
        " ORDER BY b.bankName ASC, reg.regionName ASC, br.branchName ASC"
ELSE
    branchQuery = _
        " SELECT" & _
        "   b.bankId, b.bankName, br.branchId, br.branchName, reg.regionName, br.branchId AS accessBranchId" & _
        " FROM" & _
        "   branch AS br INNER JOIN bank AS b" & _
        "       ON b.bankId = br.bankId" & _
        "   LEFT OUTER JOIN region AS reg" & _
        "       ON reg.regionId = br.regionId" & _
        " ORDER BY b.bankName ASC, reg.regionName, br.branchName ASC"
END IF
branchRS.Open branchQuery , db, adOpenStatic

IF NOT branchRS.EOF THEN
    branchArray = branchRS.GetRows()
    branchRows = branchRS.RecordCount
ELSE
    branchRows = -1 'No records found.
END IF

branchRS.Close
Set branchRS = Nothing
%>