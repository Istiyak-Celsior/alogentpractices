<%
Dim tmpAccountClassRS : Set tmpAccountClassRS = Server.CreateObject("ADODB.RecordSet")
Dim tmpAccountClassQuery : tmpAccountClassQuery = "SELECT COUNT(accountClassId) AS gblAccountClassCount FROM accountClass"
tmpAccountClassRS.Open tmpAccountClassQuery, db, adOpenForwardOnly, adLockReadOnly
Dim gblAccountClassCount : gblAccountClassCount = tmpAccountClassRS("gblAccountClassCount")
tmpAccountClassRS.Close

Dim creditTabSecurity, creditTabSecurityRows
Dim accountTabSecurity, accountTabSecurityRows

Dim getTabSecurityQuery, getTabSecurityRS, gdts
Set getTabSecurityRS = Server.CreateObject("ADODB.RecordSet")

Dim tabSecurityFields : Set tabSecurityFields = CreateObject("Scripting.Dictionary") 
tabSecurityFields.CompareMode = 1 ' -- NOTE: Need to set this flag... otherwise field names are CASE SENSITIVE
tabSecurityFields.Add "documentTypeId", 0
tabSecurityFields.Add "documentTypeName", 1
tabSecurityFields.Add "typeCode", 2
tabSecurityFields.Add "documentSubTypeId", 3
tabSecurityFields.Add "documentSubTypeName", 4
tabSecurityFields.Add "accountClassId", 5
tabSecurityFields.Add "accountClassName", 6
tabSecurityFields.Add "accountClassCode", 7
tabSecurityFields.Add "accountClassSortOrder", 8
tabSecurityFields.Add "allowAccess", 9

' ### Load the Credit Tab Security settings ###
getTabSecurityQuery = _
    " SELECT" & _
    "   documentTypeId," & _
    "   documentTypeName," & _
    "   typeCode," & _
    "   documentSubTypeId," & _
    "   documentSubTypeName," & _
    "   accountClassId," & _
    "   accountClassName," & _
    "   accountClassCode," & _
    "   accountClassSortOrder," & _
    "   allowAccess" & _
    " FROM" & _
    "   viewDocumentTabAccountSecurity" & _
    " WHERE" & _
    "   typeCode LIKE 'C'" & _
    " ORDER BY" & _
    "   documentTypeId," & _
    "   documentSubTypeId," & _
    "   accountClassSortOrder"
getTabSecurityRS.Open getTabSecurityQuery, db, adOpenForwardOnly, adLockReadOnly
creditTabSecurityRows = 0
IF NOT getTabSecurityRS.EOF THEN
    creditTabSecurity = getTabSecurityRS.GetRows
    IF isArray(creditTabSecurity) THEN
        FOR gdts = 0 TO uBound(creditTabSecurity, 2)
            creditTabSecurityRows = creditTabSecurityRows + 1
        NEXT
    END IF
ELSE
    creditTabSecurityRows = -1
END IF
getTabSecurityRS.Close

' ### Load the Account Tab Security settings ###
getTabSecurityQuery = _
    " SELECT" & _
    "   documentTypeId," & _
    "   documentTypeName," & _
    "   typeCode," & _
    "   documentSubTypeId," & _
    "   documentSubTypeName," & _
    "   accountClassId," & _
    "   accountClassName," & _
    "   accountClassCode," & _
    "   accountClassSortOrder," & _
    "   allowAccess" & _
    " FROM" & _
    "   viewDocumentTabAccountSecurity" & _
    " WHERE" & _
    "   typeCode LIKE 'L'" & _
    " ORDER BY" & _
    "   documentTypeId," & _
    "   documentSubTypeId," & _
    "   accountClassSortOrder" 
getTabSecurityRS.Open getTabSecurityQuery, db, adOpenForwardOnly, adLockReadOnly
accountTabSecurityRows = 0
IF NOT getTabSecurityRS.EOF THEN
    accountTabSecurity = getTabSecurityRS.GetRows
    IF isArray(accountTabSecurity) THEN
        FOR gdts = 0 TO uBound(accountTabSecurity, 2)
            accountTabSecurityRows = accountTabSecurityRows + 1
        NEXT
    END IF
ELSE
    accountTabSecurityRows = -1
END IF
getTabSecurityRS.Close

FUNCTION AllowCreditTabAccess(documentSubTypeId)
    Dim tabIdx, accountOffset, fn_AccountClassCode
    Dim accessResult : accessResult = false
    FOR tabIdx = 0 TO creditTabSecurityRows - 1
        IF cStr(documentSubTypeId) = cStr(creditTabSecurity(tabSecurityFields("documentSubTypeId"), tabIdx)) THEN
            FOR accountOffset = 0 TO gblAccountClassCount - 1
                fn_AccountClassCode = creditTabSecurity(tabSecurityFields("accountClassCode"), tabIdx + accountOffset)
                IF creditTabSecurity(tabSecurityFields("allowAccess"), tabIdx + accountOffset) _
                    AND (_
                         Session(fn_AccountClassCode & ".allowDocRead") _
                         OR Session(fn_AccountClassCode & ".allowDocEdit") _
                         OR Session(fn_AccountClassCode & ".allowDocAdd") _
                         OR Session(fn_AccountClassCode & ".allowDocDelete") _
                         OR Session(fn_AccountClassCode & ".isAdmin")  _
                         OR Session("isSuperUser")  _
                         ) THEN
                    accessResult = true
                END IF
            NEXT
            EXIT FOR
        END IF
    NEXT
    AllowCreditTabAccess = accessResult
END FUNCTION

FUNCTION AllowAccountTabAccess(documentSubTypeId)
    Dim tabIdx, fn_AccountClassCode, accountOffset
    Dim accessResult : accessResult = False
    FOR tabIdx = 0 TO accountTabSecurityRows - 1
        IF cStr(documentSubTypeId) = cStr(accountTabSecurity(tabSecurityFields("documentSubTypeId"), tabIdx)) THEN
            FOR accountOffset = 0 TO gblAccountClassCount - 1
                fn_AccountClassCode = accountTabSecurity(tabSecurityFields("accountClassCode"), tabIdx + accountOffset)
                IF Trim(fn_AccountClassCode & "") = "loan" THEN
                    IF accountTabSecurity(tabSecurityFields("allowAccess"), tabIdx + accountOffset) _
                        AND ( _
                                Session(fn_AccountClassCode & ".allowDocRead") OR Session(fn_AccountClassCode & ".allowDocEdit") _
                                OR Session(fn_AccountClassCode & ".allowDocAdd") OR Session(fn_AccountClassCode & ".allowDocDelete") _
                                OR Session(fn_AccountClassCode & "app.allowDocRead") OR Session(fn_AccountClassCode & "app.allowDocEdit") _
                                OR Session(fn_AccountClassCode & "app.allowDocAdd") OR Session(fn_AccountClassCode & "app.allowDocDelete") _
                                OR Session(fn_AccountClassCode & ".isAdmin") _
                                OR Session("isSuperUser") _
                            ) THEN
                        accessResult = True
                    END IF
                ELSE
                    IF accountTabSecurity(tabSecurityFields("allowAccess"), tabIdx + accountOffset) _
                        AND (_
                                Session(fn_AccountClassCode & ".allowDocRead") _
                                OR Session(fn_AccountClassCode & ".allowDocEdit") _
                                OR Session(fn_AccountClassCode & ".allowDocAdd") _
                                OR Session(fn_AccountClassCode & ".allowDocDelete") _
                                OR Session(fn_AccountClassCode & ".isAdmin")  _
                                OR Session("isSuperUser")  _
                            ) THEN
                        accessResult = True
                    END IF
                END IF
            NEXT
            EXIT FOR
        END IF
    NEXT
    AllowAccountTabAccess = accessResult
END FUNCTION ' AllowCreditTabAccess
%>