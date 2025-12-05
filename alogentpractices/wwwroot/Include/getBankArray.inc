<%
' Developer Notes:
'    The getBankArray is a 2-dimensional array of bank info from the bank table. The first
'    index refers to the data column and the second index refers to the bank
'    record.
'    
'    The data columns are indexed with the following values:
'        0 = bankId
'        1 = bankName
'        2 = bankCode
'        3 = privacyStatement
'        4 = isDefault
'        5 = Row Count

CONST BANK_ID = 0
CONST BANK_NAME = 1
CONST BANK_CODE = 2
CONST BANK_PRIVACY_STATEMENT = 3
CONST BANK_IS_DEFAULT = 4
CONST BANK_ROW_COUNT = 5

Dim bankCounter, bankRows, bankDefault, bankArray, bankNumberOf, gbnka
Dim bankRS : Set bankRS = Server.CreateObject("ADODB.Recordset")
Dim bankQuery : bankQuery = _
    " SELECT" & _
    "   bk.bankId," & _
    "   bk.bankName," & _
    "   bk.bankCode," & _
    "   bk.privacyStatement," & _
    "   bk.isDefault," & _
    "   (SELECT COUNT(bankId) FROM [bank]) AS NumRows" & _
    " FROM" & _
    "   [bank] AS bk " & _
    " ORDER BY" & _
    "   bk.bankName "
bankRS.Open bankQuery, db, adOpenForwardOnly, adLockReadOnly
bankRows = 0
IF NOT bankRS.EOF THEN
    bankArray = bankRS.GetRows()
    IF isArray(bankArray) THEN
        FOR gbnka = 0 TO uBound(bankArray, 2)
            bankRows = bankRows + 1
        NEXT
    END IF
    bankRows = bankRows -1
    bankNumberOf = bankArray(BANK_ROW_COUNT,i)
ELSE
    bankRows = -1 ' ### No records found.
END IF

bankRS.Close
Set bankRS = Nothing
%>