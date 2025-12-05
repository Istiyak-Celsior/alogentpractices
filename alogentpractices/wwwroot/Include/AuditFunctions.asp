<%
SUB AddDocumentAuditHistoryRecord(documentId, actionTaken, actionComment, userName)
    Dim data : data = BuildDocumentAuditHistoryData(documentId, actionTaken, actionComment, userName)
    Call SendWebApiRequest(data, "/api/audit/auditdocument")
END SUB

SUB MigrateDocumentAuditHistoryForCustomerNumberChange( oldCustomerNumber, newCustomerNumber)
    Dim data : data = BuildDocumentAuditHistoryCustomerNumberChangeData( oldCustomerNumber, newCustomerNumber)
    Call SendWebApiRequest(data, "/api/audit/transferdocumentaudithistory")
END SUB

SUB MigrateDocumentAuditHistoryForAccountNumberChange( customerNumber, oldAccountNumber, newAccountNumber, AccountType)
    Dim data : data = BuildDocumentAuditHistoryAccountNumberChangeData(customerNumber, oldAccountNumber, newAccountNumber, AccountType)
    Call SendWebApiRequest(data, "/api/audit/transferdocumentaudithistory")
END SUB

SUB MigrateDocumentAuditHistoryForCollateralNumberChange( customerNumber, accountNumber, accountType, oldCollateralSequence, newCollateralSequence)
    Dim data : data = BuildDocumentAuditHistoryCollateralNumberChangeData(customerNumber, accountNumber, accountType, oldCollateralSequence, newCollateralSequence)
    Call SendWebApiRequest(data, "/api/audit/transferdocumentaudithistory")
END SUB

SUB MigrateDocumentAuditHistoryForAccountTypeChange( customerNumber, accountNumber, oldAccountType, newAccountType)
    Dim data : data = BuildDocumentAuditHistoryAccountTypeChangeData(customerNumber, accountNumber, oldAccountType, newAccountType)
    Call SendWebApiRequest(data, "/api/audit/transferdocumentaudithistory")
END SUB

FUNCTION BuildDocumentAuditHistoryData(documentId, actionTaken, actionComment, userName)
    Dim data : data = "{" & _
        "'DocumentId': '" & documentId & "'," & _
        "'Action': '" & actionTaken & "'," & _
        "'ActionComment': '" & actionComment & "'," & _
        "'UserName': '" & userName & "'" & _
        "}"
    BuildDocumentAuditHistoryData = data
END FUNCTION

FUNCTION GetDeleteDocumentAuditHistoryData(documentId, actionTaken, actionComment, userName)
    IF Trim(documentId & "") = "" THEN EXIT FUNCTION

    Dim documentDetailRS : Set documentDetailRS = Server.CreateObject("ADODB.RecordSet")
    Dim documentDetailSQL : documentDetailSQL = _
        " SELECT " & _
        "   c.customerNumber, " & _
        "   ct.customerTypeDescription, " & _
        "   CASE " & _
        "       WHEN dl.isCollateralYN = 'Y' THEN " & _
        "           pl.loanNumber " & _
        "       ELSE " & _
        "           dl.loanNumber " & _
        "       END AS AccountNumber, " & _
        "   CASE " & _
        "       WHEN dl.isCollateralYN = 'Y' THEN " & _
        "           plt.loanTypeDescription " & _
        "       ELSE " & _
        "           dlt.loanTypeDescription " & _
        "       END AS AccountType, " & _
        "   CASE " & _
        "       WHEN dl.isCollateralYN = 'Y' THEN " & _
        "           CONVERT(NVARCHAR(255), cl.collateralSequence) " & _
        "       ELSE " & _
        "           NULL " & _
        "       END AS CollateralNumber, " & _
        "   dt.documentTypeName, " & _
        "   dst.documentSubTypeName, " & _
        "   CASE" & _
        "       WHEN d.documentTitle IS NULL THEN" & _
        "           'null'" & _
        "       ELSE" & _
        "           '''' + d.documentTitle + ''''" & _
        "       END AS documentTitle, " & _
        "   d.documentStatusType, " & _
        "   ISNULL(d.origDate, d.modifiedDate) AS DocumentDate, " & _
        "   CASE" & _
        "       WHEN ISNULL(~d.nonExpiring, dd.requireExpDate) = 1 THEN" & _
        "           'true'" & _
        "       ELSE" & _
        "           'false'" & _
        "       END AS DocumentCanExpire, " & _
        "   CASE" & _
        "       WHEN dd.requireExpDate = 1 THEN" & _
        "           '''' + CONVERT(nvarchar(50),IsNull(d.expDate, dd.defaultExpDate)) + ''''" & _
        "       ELSE" & _
        "           'null'" & _
        "       END AS DocumentExpiration," & _
        "   CASE " & _
        "       WHEN d.email IS NULL THEN " & _
        "           'null'" & _
        "       ELSE" & _
        "           '''' + d.email + ''''" & _
        "       END AS email," & _
        "   CASE" & _
        "       WHEN d.documentComment IS NULL THEN" & _
        "           'null'" & _
        "       ELSE" & _
        "           '''' + CONVERT(NVARCHAR(MAX), d.documentComment) + ''''" & _
        "       END AS DocumentComment, " & _
        "   d.documentHighlightColor, " & _
        "   CASE " & _
        "       WHEN d.documentStatus = 1 THEN" & _
        "           'true'" & _
        "       ELSE" & _
        "           'false'" & _
        "       END AS documentHasFile" & _
        " FROM " & _
        "   document AS d " & _
        "   INNER JOIN customer AS c ON d.customerId = c.customerId AND d.documentId = " & dbFormatId(documentId) & _
        "   INNER JOIN customerType AS ct ON ct.customerTypeId = c.customerTypeId " & _
        "   INNER JOIN documentDefinitions AS dd ON dd.documentDefId = d.documentDefId " & _
        "   INNER JOIN documentType AS dt ON dt.documentTypeId = dd.documentTypeId " & _
        "   INNER JOIN documentSubType AS dst ON dst.documentSubTypeId = dd.documentSubTypeId " & _
        "   LEFT OUTER JOIN loan AS dl ON dl.loanId = d.loanId " & _
        "   LEFT OUTER JOIN loanType AS dlt ON dlt.loanTypeId = dl.loanTypeId " & _
        "   LEFT OUTER JOIN collateral AS cl ON cl.collateralLoanId = dl.loanId " & _
        "   LEFT OUTER JOIN loan AS pl ON pl.loanId = cl.parentLoanId " & _
        "   LEFT OUTER JOIN loanType AS plt ON plt.loanTypeId = pl.loanTypeId"
    documentDetailRS.Open documentDetailSQL, db
    IF NOT documentDetailRS.EOF THEN
        Dim customerNumber : customerNumber = documentDetailRS("customerNumber")
        Dim customerTypeDescription : customerTypeDescription = documentDetailRS("customerTypeDescription")
        Dim accountNumber : accountNumber = documentDetailRS("AccountNumber")
        Dim accountType : accountType = documentDetailRS("AccountType")
        Dim collateralNumber : collateralNumber = documentDetailRS("CollateralNumber")
        Dim documentTypeName : documentTypeName = documentDetailRS("documentTypeName")
        Dim documentSubTypeName : documentSubTypeName = documentDetailRS("documentSubTypeName")
        Dim documentTitle : documentTitle = documentDetailRS("documentTitle")
        Dim documentHasFile : documentHasFile = documentDetailRS("documentHasFile")
        Dim documentStatusType : documentStatusType = documentDetailRS("documentStatusType")
        Dim documentDate : documentDate = documentDetailRS("DocumentDate")
        Dim documentCanExpire : documentCanExpire = documentDetailRS("DocumentCanExpire")
        Dim documentExpiration : documentExpiration = documentDetailRS("DocumentExpiration")
        Dim documentEmail : documentEmail = documentDetailRS("email")
        Dim documentComment : documentComment = documentDetailRS("DocumentComment")
        Dim documentHighlightColor : documentHighlightColor = documentDetailRS("documentHighlightColor")
    END IF
    documentDetailRS.Close

    IF Trim(accountNumber & "") = "" THEN
        accountNumber = null
    ELSE
        accountNumber = "'" & accountNumber & "'"
    END IF
    IF Trim(accountType & "") = "" THEN
        accountType = null
    ELSE
        accountType = "'" & accountType & "'"
    END IF
    IF Trim(collateralNumber & "") = "" THEN
        collateralNumber = null
    ELSE
        collateralNumber = "'" & collateralNumber & "'"
    END IF

    Dim data : data = "{" & _
        "'UserName': '" & userName & "'," & _
        "'Action': '" & actionTaken & "'," & _
        "'ActionComment': '" & actionComment & "'," & _
        "'CustomerNumber': '" & customerNumber & "'," & _
        "'AccountNumber': " & accountNumber & "," & _
        "'AccountType': " & accountType & "," & _
        "'CollateralNumber': " & collateralNumber & "," & _
        "'DocumentId': '" & documentId & "'," & _
        "'GroupName': '" & documentTypeName & "'," & _
        "'TabName': '" & documentSubTypeName & "'," & _
        "'Status': " & documentStatusType & "," & _
        "'CanExpire': " & documentCanExpire & "," & _
        "'ExpirationDate': " & documentExpiration & "," & _
        "'Date': '" & documentDate & "'," & _
        "'Title': " & documentTitle & "," & _
        "'Comment': " & documentComment & "," & _
        "'HasFile': " & documentHasFile & ", " & _
        "'Email': " & documentEmail & "," & _
        "'HighlightColor': '" & documentHighlightColor & "'" & _
        "}"
    GetDeleteDocumentAuditHistoryData = data
END FUNCTION

FUNCTION CreateDeleteDocumentAuditDataArray(sqlQuery, actionTaken, actionComment, userName)
    Dim jsonDataArray : jsonDataArray = Array()
    Dim documentRS : Set documentRS = CreateObject("ADODB.RecordSet")
    documentRS.Open sqlQuery, db
    DO UNTIL documentRS.EOF
        Dim jsonData : jsonData = ""
        jsonData = GetDeleteDocumentAuditHistoryData(documentRS("documentId"), actionTaken, actionComment, userName)
        jsonDataArray = AddItem(jsonDataArray, jsonData)
        documentRS.MoveNext
    LOOP
    documentRS.Close
    CreateDeleteDocumentAuditDataArray = jsonDataArray
END FUNCTION

SUB ProcessDeleteDocumentAuditDataArray(jsonDataArray)
    Dim jsonBlock
    FOR EACH jsonBlock IN jsonDataArray
        Call SendWebApiRequest(jsonBlock, "/api/audit/auditdocumentsnapshot")
    NEXT
END SUB

FUNCTION BuildDocumentAuditHistoryCustomerNumberChangeData(oldCustomerNumber, newCustomerNumber)
    Dim data : data = _
        "{" & _
        "   Type:   'CustomerNumber'," & _
        "   Keys:   [" & _
        "       {Name:  'OriginalCustomerNumber', Value: '" & oldCustomerNumber & "'}," & _
        "       {Name:  'CurrentCustomerNumber', Value: '" & newCustomerNumber & "'}" & _
        "   ]" & _
        "}"

    BuildDocumentAuditHistoryCustomerNumberChangeData = data
END FUNCTION

FUNCTION BuildDocumentAuditHistoryAccountNumberChangeData(customerNumber, oldAccountNumber, newAccountNumber, accountType)
    Dim data : data = _
        "{" & _
        "   Type:   'AccountNumber'," & _
        "   Keys:   [" & _
        "       {Name:  'CustomerNumber', Value: '" & customerNumber & "'}," & _
        "       {Name:  'OriginalAccountNumber', Value: '" & oldAccountNumber & "'}," & _
        "       {Name:  'CurrentAccountNumber', Value: '" & newAccountNumber & "'}," & _
        "       {Name:  'AccountType', Value: '" & accountType & "'}" & _
        "   ]" & _
        "}"    

    BuildDocumentAuditHistoryAccountNumberChangeData = data
END FUNCTION

FUNCTION BuildDocumentAuditHistoryCollateralNumberChangeData(customerNumber, accountNumber, accountType, oldCollateralSequence, newCollateralSequence)
    Dim data : data = _
        "{" & _
        "   Type:   'CollateralNumber'," & _
        "   Keys:   [" & _
        "       {Name:  'CustomerNumber', Value: '" & customerNumber & "'}," & _
        "       {Name:  'AccountNumber', Value: '" & accountNumber & "'}," & _
        "       {Name:  'AccountType', Value: '" & accountType & "'}," & _
        "       {Name:  'OriginalCollateralNumber', Value: '" & oldCollateralSequence & "'}," & _
        "       {Name:  'CurrentCollateralNumber', Value: '" & newCollateralSequence & "'}" & _
        "   ]" & _
        "}"        

    BuildDocumentAuditHistoryCollateralNumberChangeData = data
END FUNCTION

FUNCTION BuildDocumentAuditHistoryAccountTypeChangeData( customerNumber, accountNumber, oldAccountType, newAccountType)
    Dim data : data = _
        "{" & _
        "   Type:   'AccountType'," & _
        "   Keys:   [" & _
        "       {Name:  'CustomerNumber', Value: '" & customerNumber & "'}," & _
        "       {Name:  'AccountNumber', Value: '" & accountNumber & "'}," & _
        "       {Name:  'OriginalAccountType', Value: '" & oldAccountType & "'}," & _
        "       {Name:  'CurrentAccountType', Value: '" & newAccountType & "'}" & _
        "   ]" & _
        "}" 
    BuildDocumentAuditHistoryAccountTypeChangeData = data
END FUNCTION

SUB ProcessDocumentAuditHistories(auditHistories)
    Dim auditHistory
    FOR EACH auditHistory IN auditHistories
        Call AddDocumentAuditHistoryRecord(auditHistory.DocumentId, auditHistory.ActionTaken, auditHistory.ActionComment, auditHistory.UserName)
    NEXT
END SUB

SUB CreateDocumentAuditList(documentIdSQL, documentActionTaken, documentActionComment)
    IF Trim(documentIdSQL & "") = "" THEN EXIT SUB
    IF Trim(documentActionTaken & "") = "" THEN EXIT SUB

    Dim documentIdRS : Set documentIdRS = Server.CreateObject("ADODB.RecordSet")
    documentIdRS.open documentIdSQL, db
    IF NOT (documentIdRS.BOF AND documentIdRS.EOF) THEN
        paryDocumentIds = documentIdRS.Getrows()
    END IF
    documentIdRS.Close

    IF IsArray(paryDocumentIds) THEN
        FOR i = 0 TO uBound(paryDocumentIds, 2)
            Call AddDocumentAuditHistoryRecord(paryDocumentIds(0, i), documentActionTaken, documentActionComment, Session("userLogin"))
        NEXT
    END IF
END SUB

FUNCTION AddObject(arr, obj)
    ReDim Preserve arr(uBound(arr) + 1)
    SET arr(uBound(arr)) = obj
    AddObject = arr
END FUNCTION

Class DocumentAuditHistory
    Private id
    Private action
    Private comment
    Private name

    Public Property Get DocumentId()
        DocumentId = id
    End Property

    Public Property Let DocumentId(value)
        id = value
    End Property

    Public Property Get ActionTaken()
        ActionTaken = action
    End Property

    Public Property Let ActionTaken(value)
        action = value
    End Property

    Public Property Get ActionComment()
        ActionComment = comment
    End Property

    Public Property Let ActionComment(value)
        comment = value
    End Property

    Public Property Get UserName()
        UserName = name
    End Property

    Public Property Let UserName(value)
        name = value
    End Property
End Class
%>