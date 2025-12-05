<!-- BEGIN Credit Documents Display -->
<%
Dim rowCount : rowCount = 0
Dim creditTabRS : Set creditTabRS = Server.CreateObject("ADODB.RecordSet")
Dim creditDocumentArray, singleTab

' Build Credit Tab query for the currently viewed customer
Dim creditTabQuery : creditTabQuery = _
    " SELECT" & _
    "   c.customerBranchId," & _
    "   c.employee," & _
    "   'credit' AS accountClassCode," & _
    "   dtab.customerId," & _
    "   dtab.documentTabId," & _
    "   IsNull(dtab.documentDefId,dd.documentDefId) AS documentDefId," & _
    "   IsNull(dtab.docTabStatusType,dd.defaultDocumentStatusType) AS docTabStatusType," & _ 
    "   IsNull(dtab.docTabHighlightColor,dd.docDefHighlightColor) AS docTabHighlightColor," & _
    "   dt.documentTypeId," & _
    "   dst.documentSubTypeId," & _
    "   dt.documentTypeName," & _ 
    "   dt.typeSortOrder," & _
    "   dd.sortOrder," & _
    "   dst.subTypeDescription, " & _
    "   dst.subTypeInstruction," & _
    "   dst.subTypeScanFlag," & _
    "   dsto.hasDemographicData," & _
    "   dd.requireExpdate," & _
    "   dd.hideEmployeeFileYN, " & _
    "   dd.hideTabYN," & _
    "   dd.defaultActivationStatus," & _
    "   dd.docDefHighlightColor, " & _
    "   dd.docDefDocSortBy," & _
    "   dd.docDefAllowSchedule," & _
    "   dd.RequireQc," & _
    "   dd.CriticalQc," & _
    "   ISNULL(dh.QcStatus, 0) AS QcStatus," & _
    "   IsNull(dtab.docTabAllowSchedule, dd.docDefAllowSchedule) AS docTabAllowSchedule," & _
    "   IsNull(dtab.docTabScheduleUnits, dd.docDefScheduleUnits) AS docTabScheduleUnits," & _
    "   IsNull(dtab.docTabSchedulePeriod, dd.docDefSchedulePeriod) AS docTabSchedulePeriod," & _
    "   IsNull(dtab.docTabNextCreateDate, dd.docDefNextCreateDate) AS docTabNextCreateDate," & _
    "   IsNull(dtab.docTabProcessingDateEnd, dd.docDefProcessingDateEnd) AS docTabProcessingDateEnd," & _
    "   IsNull(dtab.docTabDocumentExpireUnits, dd.docDefDocumentExpireUnits) AS docTabDocumentExpireUnits," & _
    "   IsNull(dtab.docTabDocumentExpirePeriod, dd.docDefDocumentExpirePeriod) AS docTabDocumentExpirePeriod," & _
    "   IsNull(dtab.docTabDocumentTitlePattern, dd.docDefDocumentTitlePattern) AS docTabDocumentTitlePattern," & _
    "   dtab.docTabOverrideDefinition," & _
    "   dtab.docTabLockSettings," & _
    "   dst.documentSubTypeName," & _
    "   d.[documentId]," & _
    "   d.[documentDescription]," & _
    "   IsNull(d.[loanFile], dd.defaultName) AS loanFile," & _
    "   d.[FileName]," & _
    "   d.[documentAssociation]," & _
    "   IsNull(d.[documentStatus], 2) AS documentStatus," & _
    "   d.[origdate]," & _
    "   d.[modifieddate]," & _
    "   IsNull(d.[expdate], dd.defaultExpDate) AS expDate," & _
    "   CASE" & _
    "       WHEN IsNull(da.activationStatus, dd.defaultActivationStatus) LIKE 'off' THEN" & _
    "           2" & _
    "       ELSE" & _
    "           IsNull(d.[documentStatusType], dd.defaultExistingDocumentStatusType)" & _
    "       END AS documentStatusType," & _
    "   d.[documentComment]," & _
    "   IsNull(d.[documentTitle], dst.documentSubTypeName) AS documentTitle," & _
    "   IsNull(IsNull(d.[documentHighlightColor], dtab.docTabHighlightColor), dd.docDefHighlightColor) AS documentHighlightColor," & _
    "   d.[nonExpiring]" & _
    " FROM" & _
    "   customer AS c INNER JOIN documentDefinitions AS dd" & _
    "       ON c.customerTypeId=dd.customerTypeId" & _
    "       AND c.customerId=" & dbFormatId(selectedCustomerId) & _
    "   INNER JOIN documentType AS dt" & _
    "       ON dt.documentTypeId=dd.documentTypeId" & _
    "   INNER JOIN documentSubType AS dst" & _
    "       ON dst.documentSubTypeId=dd.documentSubTypeId" & _
    "   INNER JOIN documentSubTypeOption AS dsto" & _
    "       ON dsto.documentSubTypeId = dst.documentSubTypeId" & _
    "   LEFT OUTER JOIN documentTab AS dtab" & _
    "       ON dtab.documentDefId=dd.documentDefId" & _
    "       AND dtab.customerId=c.customerId" & _
    "       AND dtab.loanId IS NULL" & _
    "   LEFT OUTER JOIN [document] AS d" & _
    "       ON d.documentTabId=dtab.documentTabId" & _
    "   LEFT OUTER JOIN documentActivation AS da" & _
    "       ON da.customerId=c.customerId" & _
    "       AND da.loanId IS NULL" & _
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
    " WHERE" & _
    "   dd.hideTabYN <> 'Y'" & _
    "   AND (" & _
    "       (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 AND LOWER(IsNull(da.activationStatus,dd.defaultActivationStatus)) = 'on')" & _
    "        OR IsNull(d.documentStatus,2) = 1" & _
    "   ) " & _
    "   AND d.documentStatus = 1" & _
    " ORDER BY " & _
    "   dd.sortOrder," & _
    "   dt.documentTypeName," & _
    "   dst.documentSubTypeName," & _
    "   d.origdate DESC"
creditTabRS.Open creditTabQuery, db, adOpenForwardOnly, adLockReadOnly

IF IsNull(CustomerEmployee) OR cInt(CustomerEmployee) = 0 THEN
    employeeViewer = true
ELSE
    FOR i = 1 TO bankmax
        IF cStr(bankId) = cStr(banksecurity(i,1)) THEN
            IF banksecurity(i,2) = 1 THEN employeeViewer = true
        END IF
    NEXT
END IF
%>
<table class="tabstrip-inner-table">
    <%
    IF NOT creditTabRS.EOF THEN
        creditDocumentArray = creditTabRS.GetRows(adGetRowsRest,,creditFieldsArray)
        ' Loop through credit documentTabs for given customer
        documentTypeName = ""
        numRows = uBound(creditDocumentArray, 2) + 1
        tabDisplayEmpty = false
    ELSE
        tabDisplayEmpty = true
    END IF
    creditTabRS.Close()

    WHILE rowCount < numRows 
        nextRow = rowCount + 1
        documentTabId = creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount)
        ' Only display the Group (documentType) once
        IF documentTypeName <> creditDocumentArray(creditFieldsDict.Item("documentTypeName"), rowCount) THEN
            displayTab = true
            documentTypeName = creditDocumentArray(creditFieldsDict.Item("documentTypeName"), rowCount)
            %>
            <tr>
                <td class="section-header"><%=creditDocumentArray(creditFieldsDict.Item("documentTypeName"), rowCount)%></td>
            </tr>
            <%
        END IF ' ### documentTypeName <> creditTabRS("documentTypeName")

        ' ### Prepare the document instruction for tool tip hover ###
        documentInstruction = creditDocumentArray(creditFieldsDict.Item("subTypeInstruction"), rowCount)
        displayTab = True ' ### Reset flag to display tab information
        singleTab = True ' ### Reset flag to check if more than one doc within tab

        ' ### Logic for displaying Tab only for first row AND document title when needed ###
        IF (lastDocumentTabId = documentTabId) THEN displayTab = False

        ' ### Check the next row ###
        IF nextRow < numRows THEN
            IF documentTabId = creditDocumentArray(creditFieldsDict.Item("documentTabId"), nextRow) THEN singleTab = False
        END IF

        ' ### Process documentTitle if the name is the same as the Tab ###
        documentTitleColor = creditDocumentArray(creditFieldsDict.Item("documentHighlightColor"), rowCount)
        documentTitle = creditDocumentArray(creditFieldsDict.Item("documentTitle"), rowCount)

        IF documentTitle = creditDocumentArray(creditFieldsDict.Item("documentSubTypeName"), rowCount) AND displayTab AND SingleTab THEN
            documentTitle = ""
        END IF
        %>
        <tr>
            <%
            IF displayTab THEN
                documentSubTypeId     = creditDocumentArray(creditFieldsDict.Item("documentSubTypeId"), rowCount)
                docHideEmployeeFileYN = creditDocumentArray(creditFieldsDict.Item("hideEmployeeFileYN"), rowCount)
            END IF

            Dim documentTypeIcon : documentTypeIcon = GetDocumentTypeIcon(creditDocumentArray(creditFieldsDict.Item("FileName"), rowCount))
            Dim escFileName : escFileName = EscapeJSStr(creditDocumentArray(creditFieldsDict.Item("FileName"), rowCount))


	        Dim QcApprovalIcon : QcApprovalIcon = "&nbsp;"
            Dim RequireQc      : RequireQc      = creditDocumentArray(creditFieldsDict.Item("RequireQc"), rowCount)
            Dim QcStatus       : QcStatus       = creditDocumentArray(creditFieldsDict.Item("QcStatus"), rowCount)

            IF RequireQc AND QcStatus <> 1 THEN
                QcApprovalIcon = "<i class=""aa-icon fad fa-shield-exclamation aa-document-unapproved"" style=""--fa-primary-color:#ca3f3f; --fa-secondary-color:#e27d7a;"" title=""<div style='text-align: left'><strong>Requires QC</strong><br />This type of document requires quality control and must be approved before it can be used. Documents that are not approved may be incomplete or incorrect.</div>"" aria-hidden=""true""></i>"    
            ELSEIF RequireQc AND QcStatus = 1 THEN
                QcApprovalIcon = "<i class=""aa-icon fad fa-shield-check aa-document-approved"" style=""--fa-primary-color: #3fca5b; --fa-secondary-color: #89d489"" title=""<div style='text-align: left'><strong>Approved</strong><br />This document is approved and is good to go!</div>"" aria-hidden=""true""></i>"    
            END IF

            ' ### Determine the document's view access
            '
            Dim documentSubTypeId         : documentSubTypeId          = creditDocumentArray(creditFieldsDict.Item("documentSubTypeId"), rowCount)
            Dim branchId                  : branchId                   = creditDocumentArray(creditFieldsDict.Item("customerBranchId"), rowCount)
            Dim accountClassCode          : accountClassCode           = creditDocumentArray(creditFieldsDict.Item("accountClassCode"), rowCount)
            Dim customerIsEmployee        : customerIsEmployee         = creditDocumentArray(creditFieldsDict.Item("employee"), rowCount)
            Dim hideEmployeeFileYN        : hideEmployeeFileYN         = creditDocumentArray(creditFieldsDict.Item("hideEmployeeFileYN"), rowCount)
            Dim fileHasDemographicData    : fileHasDemographicData     = creditDocumentArray(creditFieldsDict.Item("hasDemographicData"), rowCount)
            Dim documentTabIsEmployeeFile : documentTabIsEmployeeFile  = True AND (hideEmployeeFileYN = "Y")
            Dim allowDocumentAccess       : allowDocumentAccess        = AllowCreditTabAccess(documentSubtypeId)
            Dim isCustomerEmployeeFile    : isCustomerEmployeeFile     = customerIsEmployee And documentTabIsEmployeeFile
            Dim viewDocumentAccess        : Set viewDocumentAccess     = usr.Security.HasDocumentViewAccess(accountClassCode, branchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)
            %>
            <td class="row">
                <table>
                    <tr>
                        <td><input type="checkbox" class="k-checkbox" id="cDoc<%=rowCount%>" name="SelectDoc" value="<%=creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)%>"<% IF NOT viewDocumentAccess.HasAccess THEN %> disabled="disabled" title="You do not have permission to send this document"<% END IF %>/><label class="k-checkbox-label" for="cDoc<%=rowCount%>"></label></td>
                        <td><label for="cDoc<%=rowCount%>"><%=Server.HTMLEncode(creditDocumentArray(creditFieldsDict.Item("documentSubTypeName"), rowCount))%></label></td>
                        <td><span style="color:<%=documentTitleColor%>;" class="document-title" title="<%=documentTitle%>"><%=Server.HTMLEncode(documentTitle)%></span></td>
                        <td><%=QcApprovalIcon%></td>
                        <td class="aa-tar"><%
                        IF viewDocumentAccess.HasAccess THEN
                            Dim creditDocumentId  : creditDocumentId  = creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)
                            Dim creditFilename    : creditFilename    = creditDocumentArray(creditFieldsDict.Item("FileName"), rowCount)
                            Dim creditFileRoute   : creditFileRoute   = GetDocumentFileViewUrl(creditDocumentId, Session("userId"))

                            creditViewFileUrl = "Start('" & creditFileRoute & "');"
                            %><a href="javascript:void(0);" onclick="<%=creditViewFileUrl%>";><i class="<%=documentTypeIcon%>" title="Click here to view document"></i></a><%
                        ELSE
                            %><i class="aa-icon lock fad fa-lock fa-fw aa-disabled" title="<%= viewDocumentAccess.Reason %>"></i><%
                        END IF
                        %></td>
                    </tr>
                </table>
            </td>
        </tr>
        <%
        lastDocumentTabId = documentTabId
        rowCount = rowCount + 1
    WEND ' ### END WHILE loop through creditDocumentArray

    Set creditFieldsDict = nothing
    Set creditFieldsArray = nothing

    ' ### Display message if no active documents can be displayed ###
    IF tabDisplayEmpty THEN
    %>
    <tr>
        <td class="warning-icon"><i class="fas fa-exclamation-triangle aa-color-warning" aria-hidden="true"></i></td>
    </tr>
    <tr>
        <td class="warning-message">No Active/Defined Credit Documents.</td>
    </tr>
    <% END IF %>
</table>