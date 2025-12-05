<%
Dim loanTabRS : Set loanTabRS = Server.CreateObject("ADODB.RecordSet")
Dim loanDocumentArray
singleTab = False

' If the loan is a cross collateral, ensure that the primary collateral id is used
' as that record has the documents associated with it
targetLoanId = selectedLoanId
IF loanIsCrossColl = "Y" THEN targetLoanId = loanPrimaryCollateralId

' Build query to get DocumentTabs and their document information
Dim loanTabQuery : loanTabQuery = _
    " SELECT" & _
    "   l.loanBranchId," & _
    "   CASE" & _
    "       WHEN ls.isApplicationStatus = 1 THEN 'loanapp'" & _
    "       ELSE ac.accountClassCode" & _
    "   END AS accountClassCode," & _
    "   dtab.documentTabId, " & _
    "   dtab.documentTabId, " & _
    "   IsNull(dtab.documentDefId,dd.documentDefId) AS documentDefId," & _
    "   IsNull(dtab.docTabStatusType,dd.defaultDocumentStatusType) AS docTabStatusType," & _ 
    "   IsNull(dtab.docTabHighlightColor,dd.docDefHighlightColor) AS docTabHighlightColor," & _
    "   dt.documentTypeName, " & _
    "   dt.typeSortOrder," & _
    "   dt.typeActivationStatus," & _
    "   dst.documentSubTypeName," & _
    "   dst.subTypeDescription, " & _
    "   dst.subTypeInstruction," & _
    "   dst.subTypeScanFlag," & _
    "   dsto.hasDemographicData," & _
    "   dd.documentTypeId," & _
    "   dd.documentSubTypeId," & _
    "   dd.sortOrder," & _
    "   dd.requireExpdate," & _
    "   dd.hideEmployeeFileYN, " & _
    "   dd.hideTabYN," & _
    "   dd.defaultActivationStatus," & _
    "   dd.docDefHighlightColor, " & _
    "   dd.docDefDocSortBy," & _
    "   dd.RequireQc," & _
    "   dd.CriticalQc," & _
    "   ISNULL(dh.QcStatus, 0) AS QcStatus," & _
    "   d.documentId," & _
    "   d.documentDescription," & _
    "   IsNull(d.[loanFile], dd.defaultName) AS loanFile," & _
    "   d.[FileName]," & _
    "   d.documentAssociation," & _
    "   IsNull(d.[documentStatus], 2) AS documentStatus," & _
    "   d.origdate," & _
    "   d.modifieddate," & _
    "   IsNull(d.[expdate], dd.defaultExpDate) AS expDate," & _
    "   CASE" & _
    "       WHEN IsNull(da.activationStatus, dd.defaultActivationStatus) LIKE 'off' THEN" & _
    "           2" & _
    "       ELSE" & _
    "           IsNull(d.[documentStatusType], dd.defaultExistingDocumentStatusType)" & _
    "       END AS documentStatusType," & _
    "   d.documentComment," & _
    "   IsNull(d.[documentTitle], dst.documentSubTypeName) AS documentTitle," & _
    "   IsNull(IsNull(d.[documentHighlightColor], dtab.docTabHighlightColor), dd.docDefHighlightColor) AS documentHighlightColor," & _
    "   d.nonExpiring," & _
    "   IsNull(dtab.docTabAllowSchedule, dd.docDefAllowSchedule) AS docTabAllowSchedule," & _
    "   IsNull(dtab.docTabScheduleUnits, dd.docDefScheduleUnits) AS docTabScheduleUnits," & _
    "   IsNull(dtab.docTabSchedulePeriod, dd.docDefSchedulePeriod) AS docTabSchedulePeriod," & _
    "   IsNull(dtab.docTabNextCreateDate, dd.docDefNextCreateDate) AS docTabNextCreateDate," & _
    "   IsNull(dtab.docTabProcessingDateEnd, dd.docDefProcessingDateEnd) AS docTabProcessingDateEnd," & _
    "   IsNull(dtab.docTabDocumentExpireUnits, dd.docDefDocumentExpireUnits) AS docTabDocumentExpireUnits," & _
    "   IsNull(dtab.docTabDocumentExpirePeriod, dd.docDefDocumentExpirePeriod) AS docTabDocumentExpirePeriod," & _
    "   IsNull(dtab.docTabDocumentTitlePattern, dd.docDefDocumentTitlePattern) AS docTabDocumentTitlePattern," & _
    "   dtab.docTabOverrideDefinition," & _
    "   dtab.docTabLockSettings" & _
    " FROM" & _
    "   loan AS l INNER JOIN documentDefinitions AS dd" & _
    "       ON l.loanTypeId=dd.loanTypeId" & _
    "       AND l.loanId=" & dbFormatId(targetLoanId) & _
    "   INNER JOIN loanStatus AS ls" & _
    "       ON ls.statusId = l.loanStatusId" & _
    "   INNER JOIN accountClass AS ac" & _
    "       ON ac.accountClassId = ls.accountClassId" & _
    "   INNER JOIN documentType AS dt" & _
    "       ON dt.documentTypeId=dd.documentTypeId" & _
    "   INNER JOIN documentSubType AS dst" & _
    "       ON dst.documentSubTypeId=dd.documentSubTypeId" & _
    "   INNER JOIN documentSubTypeOption AS dsto" & _
    "       ON dsto.documentSubTypeId = dst.documentSubTypeId" & _
    "   LEFT OUTER JOIN documentTab AS dtab" & _
    "       ON dtab.documentDefId=dd.documentDefId" & _
    "       AND dtab.loanId=l.loanId" & _
    "   LEFT OUTER JOIN [document] AS d" & _
    "       ON d.documentTabId=dtab.documentTabId" & _
    "   LEFT OUTER JOIN documentActivation AS da" & _
    "       ON da.loanId=l.loanId" & _
    "       AND da.documentTypeId=dd.documentTypeId" & _
    "   LEFT OUTER JOIN (" & _
    " 	    SELECT d.documentId AS historyDocumentId, ISNULL(dh.qcStatus, 0) AS qcStatus" & _
    " 	    FROM" & _
    "		    document AS d INNER JOIN (" & _
    "			    SELECT documentId, qcStatus, ROW_NUMBER() OVER(PARTITION BY documentId ORDER BY dateChanged DESC) AS rowNumber" & _
    "			    FROM documentHistory AS dh INNER JOIN documentHistoryInput AS dhi" & _
    "                  ON dh.inputType = dhi.documentHistoryInputId" & _
    "			    WHERE" & _
    "				    documentId IS NOT NULL" & _
    "                   AND dhi.IsFileChange = 1" & _
    "		    ) AS dh" & _
    "		    ON d.documentId = dh.documentId" & _
    " 	    WHERE" & _
    "		    dh.rowNumber = 1" & _
    "   ) AS dh" & _
    "	    ON dh.historyDocumentId = d.documentId" & _
    " WHERE " & _
    "   dd.hideTabYN <> 'Y'" & _
    "   AND (" & _
    "       (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 AND LOWER(IsNull(da.activationStatus,dd.defaultActivationStatus)) = 'on')" & _
    "        OR IsNull(d.documentStatus,2) = 1" & _
    "   ) " & _
    "   AND d.documentStatus = 1" & _
    " ORDER BY" & _
    "   dd.sortOrder," & _
    "   dt.documentTypeName," & _
    "   dst.documentSubTypeName," & _
    "   d.origdate DESC"
loanTabRS.Open loanTabQuery, db, adOpenForwardOnly, adLockReadOnly
IF NOT loanTabRS.EOF THEN
    loanDocumentArray = loanTabRS.GetRows(adGetRowsRest,,loanFieldsArray)
    loanDocumentCount = UBound(loanDocumentArray,2)
    tabDisplayEmpty = False
ELSE
    loanDocumentCount = -1
    tabDisplayEmpty = True
END IF
loanTabRS.Close

Set primaryBorrowerRS = Server.CreateObject("ADODB.RecordSet")
primaryIsEmployee = 0
primaryBorrowerQuery = _
    " SELECT" & _
    "   c.employee," & _
    "   c.customerFolder," & _
    "   c.bankId," & _
    "   l.loanFolder, " & _
    "   ac.accountClassCode " & _
    " FROM" & _
    "   customer AS c " & _
    "   INNER JOIN loan AS l ON c.customerId = l.customerId " & _
    "   INNER JOIN loanType AS lt ON l.loanTypeId = lt.loanTypeId " & _
    "   INNER JOIN accountClass AS ac ON ac.accountClassId = lt.accountClassId " & _
    " WHERE" & _
    "   l.loanId=" & dbFormatId(targetLoanId)
primaryBorrowerRS.Open primaryBorrowerQuery, db, adOpenStatic, adCmdText
primaryCustomerFolder   = primaryBorrowerRS("customerFolder")
primaryLoanFolder       = primaryBorrowerRS("loanFolder")
primaryAccountClassCode = primaryBorrowerRS("accountClassCode")
primaryIsEmployee       = primaryBorrowerRS("employee")
IF IsNull(primaryIsEmployee) OR primaryIsEmployee = "" THEN primaryIsEmployee = 0

IF NOT IsThereAnEmployee(primaryIsEmployee, targetLoanId) THEN
    employeeViewer = true
ELSE
    FOR i = 1 TO bankmax
        IF cStr(primaryBorrowerRS("bankid")) = cStr(banksecurity(i,1)) THEN
            IF banksecurity(i,2) = 1 THEN
                employeeViewer = true
            END IF
        END IF
    NEXT
END IF
primaryBorrowerRS.Close
Set primaryBorrowerRS = Nothing
%>
<table class="tabstrip-inner-table">
    <%
    ' ### Loop through loan documentTabs for given customer ###
    documentTypeName = ""
    numRows = loanDocumentCount + 1 
    rowCount = 0
    WHILE rowCount < numRows 
        nextRow = rowCount + 1
        documentTabId = loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount)

        ' ### Only display the Group (documentType) once ###
        IF documentTypeName <> loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount) THEN
            displayTab = true
            documentTypeName = loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount)
            %>
            <tr>
                <td class="section-header"><%=loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount)%></td>
            </tr>
            <%
        END IF

        displayTab = True ' ### RESET FLAG TO DISPLAY TAB INFORMATION
        singleTab = True ' ### RESET FLAG TO CHECK IF MORE THAN ONE DOC WITHIN TAB

        ' ### LOGIC FOR DISPLAYING TAB ONLY FOR FIRST ROW AND DOCUMENT TITLE WHEN NEEDED ###
        IF (lastDocumentTabId = documentTabId) THEN displayTab = False

        ' ### CHECK THE NEXT ROW ###
        IF nextRow < numRows THEN
            IF documentTabId = loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount + 1) THEN singleTab = False
        END IF

        ' ### Process documentTitle if the name is the same as the Tab ###
        documentTitleColor = loanDocumentArray(loanFieldsDict.Item("documentHighlightColor"), rowCount)
        documentTitle = loanDocumentArray(loanFieldsDict.Item("documentTitle"), rowCount)

        IF Trim(documentTitle) = Trim(loanDocumentArray(loanFieldsDict.Item("documentSubTypeName"), rowCount)) AND displayTab AND SingleTab THEN
            documentTitle = ""
        END IF
        %>
        <tr>
            <%
            IF displayTab THEN
                documentSubTypeId = loanDocumentArray(loanFieldsDict.Item("documentSubTypeId"), rowCount)
                docHideEmployeeFileYN = loanDocumentArray(loanFieldsDict.Item("hideEmployeeFileYN"), rowCount)
            END IF

            documentTypeIcon = GetDocumentTypeIcon(loanDocumentArray(loanFieldsDict.Item("FileName"), rowCount))
            escFileName = EscapeJSStr(loanDocumentArray(loanFieldsDict.Item("FileName"), rowCount))

	        QcApprovalIcon = "&nbsp;"
            RequireQc      = loanDocumentArray(loanFieldsDict.Item("RequireQc"), rowCount)
            QcStatus       = loanDocumentArray(loanFieldsDict.Item("QcStatus"), rowCount)

            IF RequireQc AND QcStatus <> 1 THEN
                QcApprovalIcon = "<i class=""aa-icon fad fa-shield-exclamation aa-document-unapproved"" style=""--fa-primary-color:#ca3f3f; --fa-secondary-color:#e27d7a;"" title=""<div style='text-align: left'><strong>Requires QC</strong><br />This type of document requires quality control and must be approved before it can be used. Documents that are not approved may be incomplete or incorrect.</div>"" aria-hidden=""true""></i>"    
            ELSEIF RequireQc AND QcStatus = 1 THEN
                QcApprovalIcon = "<i class=""aa-icon fad fa-shield-check aa-document-approved"" style=""--fa-primary-color: #3fca5b; --fa-secondary-color: #89d489"" title=""<div style='text-align: left'><strong>Approved</strong><br />This document is approved and is good to go!</div>"" aria-hidden=""true""></i>"    
            END IF

            ' ### Determine the document's view access
            '
            documentSubTypeId          = loanDocumentArray(loanFieldsDict.Item("documentSubTypeId"), rowCount)
            branchId                   = loanDocumentArray(loanFieldsDict.Item("loanBranchId"), rowCount)
            accountClassCode           = loanDocumentArray(loanFieldsDict.Item("accountClassCode"), rowCount)
            hideEmployeeFileYN         = loanDocumentArray(loanFieldsDict.Item("hideEmployeeFileYN"), rowCount)
            fileHasDemographicData     = loanDocumentArray(loanFieldsDict.Item("hasDemographicData"), rowCount)
            documentTabIsEmployeeFile  = True AND (hideEmployeeFileYN = "Y")
            allowDocumentAccess        = AllowAccountTabAccess(documentSubtypeId)
            isCustomerEmployeeFile     = primaryIsEmployee And documentTabIsEmployeeFile
            Set viewDocumentAccess     = usr.Security.HasDocumentViewAccess(accountClassCode, branchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)
            %>
            <td class="row">
                <table>
                    <tr>
                        <td><input type="checkbox" class="k-checkbox" id="lDoc<%=rowCount%>" name="SelectDoc" value="<%=loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)%>"<% IF NOT viewDocumentAccess.HasAccess THEN %> disabled="disabled" title="You do not have permission to send this document"<% END IF %>/><label class="k-checkbox-label" for="lDoc<%=rowCount%>"></label></td>
                        <td><label for="lDoc<%=rowCount%>"><%=Server.HTMLEncode(loanDocumentArray(loanFieldsDict.Item("documentSubTypeName"), rowCount))%></label></td>
                        <td><span style="color:<%=documentTitleColor%>;" class="document-title" title="<%=documentTitle%>"><%=Server.HTMLEncode(documentTitle)%></span></td>
                        <td><%=QcApprovalIcon%></td>
                        <td class="aa-tar"><%
                        IF viewDocumentAccess.HasAccess THEN
                            Dim accountDocumentId  : accountDocumentId  = loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)
                            Dim accountFilename    : accountFilename    = loanDocumentArray(loanFieldsDict.Item("FileName"), rowCount)
                            Dim accountFileRoute   : accountFileRoute   = GetDocumentFileViewUrl(accountDocumentId, Session("userId"))

                            accountViewFileUrl = "Start('" & accountFileRoute & "')"
                            %><a href="javascript:void(0);" onclick="<%=accountViewFileUrl%>"<i class="<%=documentTypeIcon%>" title="Click here to view document"></i></a><%
                        ELSE
                            %><i class="aa-icon lock fad fa-lock fa-fw aa-disabled" title="<%=viewDocumentAccess.Reason%>"></i><%
                        END IF
                        %></td>
                    </tr>
                </table>
            </td>
        </tr>
        <%
        lastDocumentTabId = documentTabId
        rowCount = rowCount + 1
    WEND ' ### END WHILE loop through loanDocumentArray

    Set loanFieldsDict = nothing
    Set loanFieldsArray = nothing

    ' ### Display message if no active documents can be displayed ###
    IF tabDisplayEmpty THEN
    %>
    <tr>
        <td class="warning-icon"><i class="fas fa-exclamation-triangle aa-color-warning" aria-hidden="true"></i></td>
    </tr>
    <tr>
        <td class="warning-message">No Active/Defined Loan Documents.</td>
    </tr>
    <% END IF %>
</table>