<%
' ### Constants for accessing the Table columns by name in the array. The
' constant is used in the first array position in the 2-d array. The
' second array index is for the table row position. ###

Const ACCOUNT_CLASS_ID = 0
Const ACCOUNT_CLASS_NAME = 1
Const ACCOUNT_CLASS_CODE = 2
Const ACCOUNT_CLASS_SORT_ORDER = 3

' ### Fill the accountClass array ###
Dim gaca
Dim g_AccountClassList, g_AccountClassListCount
Dim g_AccountClassRS : Set g_AccountClassRS = Server.CreateObject("ADODB.RecordSet")
Dim g_AccountClassQuery : g_AccountClassQuery = _
    " SELECT" & _
    "   accountClassId," & _
    "   accountClassName," & _
    "   accountClassCode," & _
    "   accountClassSortOrder" & _
    " FROM accountClass" & _
    " ORDER BY accountClassSortOrder"
g_AccountClassRS.Open g_AccountClassQuery, db, adOpenForwardOnly, adLockReadOnly

g_AccountClassListCount = 0
IF NOT g_AccountClassRS.EOF THEN
    g_AccountClassList = g_AccountClassRS.GetRows()
    IF isArray(g_AccountClassList) THEN
        FOR gaca = 0 TO uBound(g_AccountClassList, 2)
            g_AccountClassListCount = g_AccountClassListCount + 1
        NEXT
    END IF
ELSE
    g_AccountClassListCount = -1
END IF
g_AccountClassRS.Close

Dim g_ExtendedAccountClassList, g_ExtendedAccountClassCount
g_AccountClassQuery = _
    " SELECT" & _
    "   accountClassId," & _
    "   accountClassName," & _
    "   accountClassCode," & _
    "   accountClassSortOrder" & _
    " FROM viewExtendedAccountClass" & _
    " ORDER BY accountClassSortOrder"
g_AccountClassRS.Open g_AccountClassQuery, db, adOpenForwardOnly, adLockReadOnly
g_ExtendedAccountClassCount = 0
if Not g_AccountClassRS.eof then
    g_ExtendedAccountClassList = g_AccountClassRS.GetRows()
    IF isArray(g_ExtendedAccountClassList) THEN
        FOR gaca = 0 TO uBound(g_ExtendedAccountClassList, 2)
            g_ExtendedAccountClassCount = g_ExtendedAccountClassCount + 1
        NEXT
    END IF
ELSE
    g_ExtendedAccountClassCount = -1
END IF
g_AccountClassRS.Close

FUNCTION GetAccountClassCode(id)
    Dim code : code = ""
    IF CheckForNull(id) = "" THEN
        code = "credit"
    ELSE
        Dim idx
        FOR idx = 0 TO g_AccountClassListCount - 1
            IF CheckForNull(id) = g_accountClassList(ACCOUNT_CLASS_ID,idx) THEN
                code = g_accountClassList(ACCOUNT_CLASS_CODE,idx)
                EXIT FOR
            END IF
        NEXT
    END IF
    GetAccountClassCode = code
END FUNCTION
%>