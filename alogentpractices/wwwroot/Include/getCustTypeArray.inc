<%
Dim custTypeCounter
Dim custTypeRS : Set custTypeRS = Server.CreateObject("ADODB.Recordset")
Dim custTypeQuery : custTypeQuery = _
    "SELECT customerTypeID, customerTypeDescription, defaultType FROM [customerType] ORDER BY customerTypeDescription"
custTypeRS.Open custTypeQuery, db, adOpenForwardOnly, adLockReadOnly

IF NOT custTypeRS.EOF THEN
    Dim custTypeArray : custTypeArray = custTypeRS.GetRows()
    Dim custTypeRows : custTypeRows = uBound(custTypeArray, 2)
    Dim custTypeDefault : custTypeDefault = 0
    FOR custTypeCounter = 0 TO CustTypeRows
        IF custTypeArray(2, custTypeCounter) = "True" THEN
            custTypeDefault = custTypeArray(0, custTypeCounter)
        END IF
    NEXT
ELSE
    custTypeRows = -1 ' ### No records found
    custTypeDefault = 0
END IF

custTypeRS.Close
Set custTypeRS = Nothing
%>