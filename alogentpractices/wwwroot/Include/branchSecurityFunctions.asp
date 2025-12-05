<%
'---------------------------------------------------------------------
'   Function: hasBranchAccess
'   Description: Returns true if the current session user has access to the passed branchId
'   Arguments: theBranchId - the branchId to check for
'   Returns: boolean - true if the user has branchAccess, false otherwise
'---------------------------------------------------------------------
FUNCTION hasBranchAccess(theBranchId)
    Dim status : status = true
    IF (Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO") AND NOT Session("isSuperUser") THEN
        Dim numberRecords : numberRecords = 0
        Dim branhcSecurityRS : Set branchSecurityRS = Server.CreateObject("ADODB.RecordSet")
        Dim branchSecurityQuery : branchSecurityQuery = _
            " SELECT TOP 1 1 FROM viewUserBranchSecurity WHERE userId = " & dbFormatId(Session("userId"))
        branchSecurityRS.Open branchSecurityQuery, db
        IF NOT branchSecurityRS.EOF THEN numberRecords = 1
        IF numberRecords = 0 THEN status = false
        branchSecurityRS.Close
    END IF
    hasBranchAccess = status
END FUNCTION

'---------------------------------------------------------------------
'   Function: hasCustomerBranchAccess
'---------------------------------------------------------------------
FUNCTION hasCustomerBranchAccess(theCustomerId)
    Dim status : status = true
    IF Trim(theCustomerId & "") = "" THEN
        IF Session("credit.allowAdd") THEN status = false
    ELSEIF (Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO") AND NOT Session("isSuperUser") THEN
        Dim numberRecords : numberRecords = 0
        Dim branchSecurityRS : Set branchSecurityRS = Server.CreateObject("ADODB.RecordSet")
        Dim branchSecurityQuery : branchSecurityQuery = _
            " SELECT TOP 1 1 " & _
            " FROM" & _
            "   customer AS c " & _
            "   INNER JOIN viewUserBranchSecurity AS ubs ON c.customerBranchId = ubs.branchId " & _
            " WHERE " & _
            "   c.customerId = " & dbFormatId(theCustomerId) & " AND " & _
            "   ubs.userId = " & dbFormatId(Session("userId"))
        branchSecurityRS.Open branchSecurityQuery, db
        IF NOT branchSecurityRS.EOF THEN numberRecords = 1 
        IF numberRecords = 0 THEN status = false
        branchSecurityRS.Close
    END IF
    hasCustomerBranchAccess = status
END FUNCTION

'---------------------------------------------------------------------
'   Function: hasLoanBranchAccess
'---------------------------------------------------------------------
FUNCTION hasLoanBranchAccess(theLoanId)
    Dim status : status = true
    IF (Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO") AND Trim(theLoanId & "") <> "" AND NOT Session("isSuperUser") THEN
        Dim numberRecords : numberRecords = 0
        Dim branchSecurityRS : Set branchSecurityRS = Server.CreateObject("ADODB.RecordSet")
        Dim branchSecurityQuery : branchSecurityQuery = _
            " SELECT TOP 1 1 " & _
            " FROM " & _
            "   loan AS l " & _
            "   INNER JOIN viewUserBranchSecurity AS ubs ON l.loanBranchId = ubs.branchId " & _
            " WHERE " & _
            "   l.loanId = " & dbFormatId(theLoanId) & " AND " & _
            "   ubs.userId = " & dbFormatId(Session("userId"))
        branchSecurityRS.Open branchSecurityQuery, db
        IF NOT branchSecurityRS.EOF THEN numberRecords = 1
        IF numberRecords = 0 THEN status = false
        branchSecurityRS.Close
    END IF
    hasLoanBranchAccess = status
END FUNCTION

'---------------------------------------------------------------------
'   Function: allowCustomerLoansBranchSecurity
'---------------------------------------------------------------------
FUNCTION allowCustomerLoansBranchSecurity(theCustomerId)
    Dim status : status = true
    IF (Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO") AND NOT Session("isSueperUser") THEN
        Dim numberRecords : numberRecords = 0
        Dim branchSecurityRS : Set branchSecurityRS = Server.CreateObject("ADODB.RecordSet")
        Dim branchSecurityQuery : branchSecurityQuery = _
            " SELECT TOP 1 1 " & _
            " FROM " & _
            "   loan AS l INNER JOIN viewUserBranchSecurity AS ubs ON l.loanBranchId = ubs.branchId" & _
            " WHERE " & _
            "   l.customerId = " & dbFormatId(theCustomerId) & " AND " & _
            "   ubs.userId = " & dbFormatId(Session("userId"))
        branchSecurityRS.Open branchSecurityQuery, db
        IF NOT branchSecurityRS.EOF THEN numberRecords = 1
        IF numberRecords = 0 THEN status = false
        branchSecurityRS.Close
    END IF
    allowCustomerLoansBranchSecurity = status
END FUNCTION

'---------------------------------------------------------------------
'   Function: checkCustomerBranchSecurity
'   Description:
'       Checks branch security and general security of the given customer
'       and its loan branches as well. As long as a least one branch is
'       accessible, the user is not redirected to the error page.
'       Use hasCustomerBranchAccess to determine if the user actually
'       has access or not for customers with mixed branch loans.
'---------------------------------------------------------------------
SUB checkCustomerBranchSecurity(theCustomerId)
    IF Session("bankSecurity") = "DU" AND NOT Session("isSuperUser") THEN
        IF NOT hasCustomerBranchAccess(theCustomerId) THEN
            IF NOT allowCustomerLoansBranchSecurity(theCustomerId) THEN
                Response.Redirect("error.asp?error=101")
            END IF
        END IF
    END IF
END SUB

'---------------------------------------------------------------------
'   Function: checkLoanBranchSecurity
'   Description:
'       Checks branch security and general security levels to see if this
'       user can access the given loan. If not, it redirects to the
'       error page.
'---------------------------------------------------------------------
SUB checkLoanBranchSecurity(theLoanId)
    IF Session("bankSecurity") = "DU" AND NOT Session("isSuperUser") THEN
        IF NOT hasLoanBranchAccess(theLoanId) THEN
            Response.Redirect("error.asp?error=102")
        END IF
    END IF
END SUB
%>
