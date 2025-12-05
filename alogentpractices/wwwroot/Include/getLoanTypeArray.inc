<%
Dim loanTypeArray, loanTypeRows
Dim loanTypeRS : Set loanTypeRS = Server.CreateObject("ADODB.Recordset")
Dim loanTypeQuery : loanTypeQuery = "SELECT loanTypeID, loanTypeDescription FROM loanType ORDER BY loanTypeDescription"
loanTypeRS.Open loanTypeQuery, db, adOpenForwardOnly, adLockReadOnly

IF NOT loanTypeRS.EOF THEN
    loanTypeArray = loanTypeRS.GetRows()
    loanTypeRows = uBound(loanTypeArray, 2)
ELSE
    loanTypeRows = -1
END IF

loanTypeRS.Close
Set loanTypeRS = Nothing
%>