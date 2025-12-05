<%
FUNCTION GetCollateralFolders(nCollateralId)
    Dim collateralRS : Set collateralRS = Server.CreateObject("ADODB.RecordSet")
    Dim collateralQuery : collateralQuery = _
        " SELECT" & _
        "   c.customerFolder," & _
        "   l.loanFolder," & _
        "   l.isCrossCollateralYN," & _
        "   l.primaryCollateralId" & _
        " FROM" & _
        "   customer AS c INNER JOIN viewLoansAndCollaterals AS l" & _
        "       ON c.customerId=l.customerId" & _
        " WHERE l.loanId = " & dbFormatId(nCollateralId) & _
        " ORDER BY l.paddedLoanNumber, l.paddedCollateralNumber"
    collateralRS.Open collateralQuery, db, adOpenStatic, adCmdText
    IF collateralRS("isCrossCollateralYN") = "Y" THEN
        targetCollateralLoanId = collateralRS("primaryCollateralId")
        Dim targetCollateralRS : Set targetCollateralRS = Server.CreateObject("ADODB.RecordSet")
        Dim targetCollateralQuery : targetCollateralQuery = _
            " SELECT" & _
            "   c.customerFolder," & _
            "   l.loanFolder" & _
            " FROM" & _
            "   customer AS c INNER JOIN loan AS l" & _
            "       ON c.customerId=l.customerId" & _
            " WHERE" & _
            "   l.loanId=" & dbFormatId(targetCollateralLoanId)
        targetCollateralRS.Open targetCollateralQuery, db, adOpenStatic, adCmdText
        targetCustomerFolder = targetCollateralRS("customerFolder")
        targetLoanFolder = targetCollateralRS("loanFolder")
        targetCollateralRS.Close
    ELSE
        targetCustomerFolder = collateralRS("customerFolder")
        targetLoanFolder = collateralRS("loanFolder")
    END IF
    GetCollateralFolders = targetCustomerFolder & "||" & targetLoanFolder
END FUNCTION

Dim collateralTabRS : Set collateralTabRS = Server.CreateObject("ADODB.RecordSet")
Dim collateralTabQuery : collateralTabQuery = _
    " SELECT " & _
    "   l.loanBranchId," & _
    "   ac.accountClassCode," & _
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
    " FROM " & _
    "   loan AS l INNER JOIN documentDefinitions AS dd" & _
    "       ON l.loanTypeId=dd.loanTypeId" & _
    "       AND l.loanId=" & dbFormatId(selectedCollateralId) & _
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
    " WHERE" & _
    "   dd.hideTabYN <> 'Y' " & _
    "   AND (" & _
    "       (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 AND LOWER(IsNull(da.activationStatus,dd.defaultActivationStatus)) = 'on')" & _
    "        OR IsNull(d.documentStatus,2) = 1" & _
    "   ) " & _
    "   AND d.documentStatus = 1" & _
    " ORDER BY" & _
    "   dd.sortOrder," & _
    "   dt.documentTypeName," & _
    "   dst.documentSubTypeName," & _
    "   d.origDate DESC"
collateralTabRS.Open collateralTabQuery, db, adOpenStatic, adCmdText
%>
<table class="tabstrip-inner-table">
    <%
    ' ### LOOP THROUGH COLLATERAL DOCUMENTTABS ###
    documentTypeName = ""
    documentSubTypeName = ""
    tabDisplayEmpty = true
    DO UNTIL collateralTabRS.EOF
        tabDisplayEmpty = false

        ' ### ONLY DISPLAY THE GROUP (DOCUMENTTYPE) ONCE ###
        IF documentTypeName <> collateralTabRS("documentTypeName") THEN
            documentTypeName = collateralTabRS("documentTypeName")
            %>
            <tr>
                <td class="section-header"><%=collateralTabRS("documentTypeName")%></td>
            </tr>
            <%
        END IF

        IF documentSubTypeName <> collateralTabRS("documentSubTypeName") THEN
            displayTab = True
            documentSubTypeName = collateralTabRS("documentSubTypeName")
        ELSE
            displayTab = False
        END IF

        ' ### PROCESS DOCUMENTTITLE IF THE NAME IS THE SAME AS THE TAB ###
        documentTitleColor	= collateralTabRS("documentHighlightColor")
        documentTitle = collateralTabRS("documentTitle")
        IF documentTitle = collateralTabRS("documentSubTypeName") AND displayTab THEN documentTitle = ""
        %>
        <tr>
            <%
            IF displayTab THEN
                documentSubTypeId = collateralTabRS("documentSubTypeId")
                docHideEmployeeFileYN = collateralTabRS("hideEmployeeFileYN")
            END IF

            documentTypeIcon = GetDocumentTypeIcon(collateralTabRS("FileName"))
            escFileName = EscapeJSStr(collateralTabRS("FileName"))

	        QcApprovalIcon = "&nbsp;"
            RequireQc      = collateralTabRS("RequireQc")
            QcStatus       = collateralTabRS("QcStatus")

            IF RequireQc AND QcStatus <> 1 THEN
                QcApprovalIcon = "<i class=""aa-icon fad fa-shield-exclamation aa-document-unapproved"" style=""--fa-primary-color:#ca3f3f; --fa-secondary-color:#e27d7a;"" title=""<div style='text-align: left'><strong>Requires QC</strong><br />This type of document requires quality control and must be approved before it can be used. Documents that are not approved may be incomplete or incorrect.</div>"" aria-hidden=""true""></i>"    
            ELSEIF RequireQc AND QcStatus = 1 THEN
                QcApprovalIcon = "<i class=""aa-icon fad fa-shield-check aa-document-approved"" style=""--fa-primary-color: #3fca5b; --fa-secondary-color: #89d489"" title=""<div style='text-align: left'><strong>Approved</strong><br />This document is approved and is good to go!</div>"" aria-hidden=""true""></i>"    
            END IF

            ' ### Determine the document's view access
            '
            documentSubTypeId          = collateralTabRS("documentSubTypeId")
            branchId                   = collateralTabRS("loanBranchId")
            accountClassCode           = collateralTabRS("accountClassCode")
            hideEmployeeFileYN         = collateralTabRS("hideEmployeeFileYN")
            fileHasDemographicData     = collateralTabRS("hasDemographicData")
            documentTabIsEmployeeFile  = True AND (hideEmployeeFileYN = "Y")
            allowDocumentAccess        = AllowAccountTabAccess(documentSubtypeId)
            isCustomerEmployeeFile     = primaryIsEmployee And documentTabIsEmployeeFile
            Set viewDocumentAccess     = usr.Security.HasDocumentViewAccess(accountClassCode, branchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)
            %>
            <td class="row">
                <table>
                    <tr>
                        <td><input type="checkbox" class="k-checkbox" id="oDoc<%=rowCount%>" name="SelectDoc" value="<%=collateralTabRS("documentId")%>"<% IF NOT viewDocumentAccess.HasAccess THEN %> disabled="disabled" title="You do not have permission to send this document"<% END IF %>/><label class="k-checkbox-label" for="oDoc<%=rowCount%>"></label></td>
                        <td><label for="oDoc<%=rowCount%>"><%=Server.HTMLEncode(collateralTabRS("documentSubTypeName"))%></label></td>
                        <td><span style="color:<%=documentTitleColor%>;" class="document-title" title="<%=documentTitle%>"><%=Server.HTMLEncode(documentTitle)%></span></td>
                        <td><%=QcApprovalIcon%></td>
                        <td class="aa-tar"><%
                        IF viewDocumentAccess.HasAccess THEN
                            targetCustomerFolder = "" : targetLoanFolder = ""
                            Dim paryFolders : paryFolders = Split(GetCollateralFolders(selectedCollateralId),"||")
                            targetCustomerFolder = paryFolders(0)
                            targetLoanFolder = paryFolders(1)

                            Dim collateralDocumentId  : collateralDocumentId  = collateralTabRS("documentId")
                            Dim collateralFilename    : collateralFilename    = collateralTabRS("FileName")
                            Dim collateralFileRoute   : collateralFileRoute   = GetDocumentFileViewUrl(collateralDocumentId, Session("userId"))

                            collateralViewFileUrl = "Start('" & collateralFileRoute & "');"
                            %><a href="javascript:void(0);" onclick="<%=collateralViewFileUrl%>";><i class="<%=documentTypeIcon%>" title="Click here to view document"></i></a><%
                        ELSE
                            %><i class="aa-icon lock fad fa-lock fa-fw aa-disabled" title="<%=viewDocumentAccess.Reason%>"></i><%
                        END IF
                        %></td>
                    </tr>
                </table>
            </td>
        </tr>
        <%
        rowCount = rowCount + 1
        collateralTabRS.MoveNext
    LOOP ' ### UNTIL collateralTabRS.EOF
    collateralTabRS.Close

    ' ### DISPLAY MESSAGE IF NO ACTIVE DOCUMENTS CAN BE DISPLAYED ###
    IF tabDisplayEmpty THEN
    %>
    <tr>
        <td class="warning-icon"><i class="fas fa-exclamation-triangle aa-color-warning" aria-hidden="true"></i></td>
    </tr>
    <tr>
        <td class="warning-message">No Active/Defined Collateral Documents.</td>
    </tr>
    <% END IF %>
</table>