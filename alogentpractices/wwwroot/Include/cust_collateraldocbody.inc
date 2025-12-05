<%
collateralDocStart = Timer()

Dim COLLATERAL_DOC_SPAN : COLLATERAL_DOC_SPAN = 12
IF Session("acculoan.enablePurge") = "0" THEN COLLATERAL_DOC_SPAN = COLLATERAL_DOC_SPAN - 1
IF Session("accuaccount.disableImaging") = "1" THEN COLLATERAL_DOC_SPAN = COLLATERAL_DOC_SPAN - 1

empAccessAllowed = True

' ### Build Credit Tab query for the currently viewed customer ###
Dim collateralTabRS : Set collateralTabRS = Server.CreateObject("ADODB.RecordSet")
Dim collateralTabQuery : collateralTabQuery = _
    " SELECT " & _
    "   c.customerFolder," & _
    "   l.loanBranchId, " & _
    "   l.loanFolder," & _
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
    "   ISNULL(qc.QcStatus, 0) AS QcStatus," & _
    "   d.documentId," & _
    "   d.documentDescription," & _
    "   IsNull(d.[loanFile], dd.defaultName) AS loanFile," & _
    "   d.[FileName]," & _
    "   d.documentAssociation," & _
    "   IsNull(d.[documentStatus], 2) AS documentStatus," & _
    "   d.origdate," & _
    "   d.modifieddate," & _
    "   CASE WHEN d.documentId IS NOT NULL THEN" & _
    "       d.expDate" & _
    "   ELSE" & _
    "       dd.defaultExpDate" & _
    "   END AS expDate," & _
    "   CASE" & _
    "       WHEN IsNull(da.activationStatus, dd.defaultActivationStatus) LIKE 'off' THEN" & _
    "           2" & _
    "       ELSE" & _
    "           IsNull(d.[documentStatusType], dd.defaultExistingDocumentStatusType)" & _
    "       END AS documentStatusType," & _
    "   d.documentComment," & _
    "   IsNull(d.[documentTitle], dst.documentSubTypeName) AS documentTitle," & _
    "   IsNull(IsNull(d.[documentHighlightColor], dtab.docTabHighlightColor), dd.docDefHighlightColor) AS documentHighlightColor," & _
    "   IsNull(d.[nonExpiring], 0) AS nonExpiring," & _
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
    "   IsNull(d.PurgeStatus, 0) AS PurgeStatus," & _
    "   IsNUll(d.[PurgeStatusLocked], 0) AS PurgeStatusLocked," & _
    "   CASE WHEN IsNull(d.documentStatus,2)=1 AND (dst.[BlockPurge]=1 OR dd.[BlockPurge]=1) THEN CONVERT(bit,1) ELSE CONVERT(bit,0) END AS BlockPurge," & _
    "   dsto.hasDemographicData" & _
    " FROM " & _
    "   customer AS c INNER JOIN loan AS l" & _
    "       ON c.customerId=l.customerId" & _
    "   INNER JOIN documentDefinitions AS dd" & _
    "       ON l.loanTypeId=dd.loanTypeId" & _
    "       AND l.loanId=" & dbFormatId(targetCollateralLoanId) & _
    "       AND dd.bankId=c.bankId" & _
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
	"   OUTER APPLY" & _
	"   (" & _
	" 	    SELECT TOP(1) dh.qcStatus" & _
	" 	    FROM documentHistory dh" & _
	" 		    INNER JOIN documentHistoryInput dhi ON dh.inputType = dhi.documentHistoryInputId" & _
	" 	    WHERE dd.requireQC = 1" & _
	" 		    AND dh.documentId = d.documentId" & _
	" 		    AND dhi.isFileChange = 1" & _
	" 	    ORDER BY dh.dateChanged DESC" & _
	"   ) AS qc" & _
    " WHERE" & _
    "   dd.hideTabYN <> 'Y' " & _
    "   AND (" & _
    "       (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 AND LOWER(IsNull(da.activationStatus,dd.defaultActivationStatus)) = 'on')" & _
    "        OR IsNull(d.documentStatus,2) = 1" & _
    "   ) " & _
    " ORDER BY" & _
    "   dd.sortOrder," & _
    "   dt.documentTypeName," & _
    "   dst.documentSubTypeName," & _
    "   d.origDate DESC"
collateralTabRS.Open collateralTabQuery, db, adOpenStatic, adCmdText
%>
<table class="aa-section-wrapper">
    <%
    ' ### LOOP THROUGH COLLATERAL DOCUMENTTABS ###
    documentTypeName = ""
    documentSubTypeName = ""
    tabDisplayEmpty = true
    DO UNTIL collateralTabRS.EOF
        tabDisplayEmpty = false

        ' ### Only display the Group (documentType) once ###
        IF documentTypeName <> collateralTabRS("documentTypeName") THEN
            documentTypeName = collateralTabRS("documentTypeName")
            documentSubTypeName = ""
            %>
            <tr class="aa-header-row" id="tabHeader<%=GetNextGroupCount()%>">
                <td colspan="<%=COLLATERAL_DOC_SPAN%>">
                    <input type="hidden" id="uxTabHeader<%=groupCount-1%>Children" name="tabHeader<%=groupCount-1%>Children" value="<%=groupChildren%>"/>
                    <% groupChildren = "" %>
                    <ul class="aa-row-icons groups">
                        <li><span id="tabHeader<%=groupCount%>Expander" onclick="CollapsibleGroupsToggle('<%=groupCount%>')" class="aa-collapse-expand-icon"><i class="aa-icon fas fa-<% IF Session("enableCollapsibleGroups") THEN %>plus<% ELSE %>minus<% END IF %>-square fa-fw" id="tab-header-expander-icon-<%=groupCount%>" aria-hidden="true"></i></span></li>
                        <li><a href="javascript:void(0);" onclick="openKendoDialog('Activate Collateral Tabs', 'custactivatetabs.asp?group=loan&customerId=<%=selectedCustomerId%>&loanId=<%=targetCollateralLoanId%>&documentTypeId=<%=collateralTabRS("documentTypeId")%>&accountClassCode=<%=extendedAccountClassCode%>', 500, 700);"><%=collateralTabRS("documentTypeName")%></a></li>
                    </ul>
                </td>
            </tr>
            <%
        END IF ' ### IF documentTypeName <> collateralTabRS("documentTypeName")

        IF documentSubTypeName <> collateralTabRS("documentSubTypeName") THEN
            displayTab = true
            documentSubTypeName = collateralTabRS("documentSubTypeName")
        ELSE
            displayTab = false
        END IF

        ' ### Prepare the document instruction for tool tip hover ###
        documentInstruction = collateralTabRS("subTypeInstruction")
        IF Trim(documentInstruction & "") <> "" THEN
            documentInstruction = Server.HTMLEncode(Replace(documentInstruction, vbcrlf, "<br/>"))
        ELSE
            documentInstruction = ""
        END IF

        IF collateralTabRS("documentStatus") = 1 THEN
            iconFilename = "fa-circle aa-status-yes fa-fw"
            altDocumentStatus = "Exists"
            altTitleStatus = "Document Exists"
        ELSEIF collateralTabRS("documentStatus") = 3 THEN
            iconFilename = "fa-circle aa-status-pending fa-fw"
            altDocumentStatus = "Changed"
            altTitleStatus = "Document has Changed"
        ELSE
            iconFilename = "fa-circle aa-status-no fa-fw"
            altDocumentStatus = "Doesn't Exist"
            altTitleStatus = "No Document Exists"
        END IF

        ' ### Process documentTitle if the name is the same as the Tab ###
        documentTitleColor = collateralTabRS("documentHighlightColor")
        documentTitle = collateralTabRS("documentTitle")

        IF documentTitle = collateralTabRS("documentSubTypeName") AND displayTab THEN documentTitle = ""

        display = ""
        IF Session("enableCollapsibleGroups") THEN
            display = " style=""display:none"""
        ELSE
            IF Session("enableCollapsibleDocuments") THEN
                IF NOT displayTab THEN
                    display = " style=""display:none"""
                END IF
            END IF
        END IF

        docTabAllowSchedule = collateralTabRS("docTabAllowSchedule")
        tabMaintUrl = ""
        showDocSchedule = False
        imgDocSchedule = ""
        altDocSchedule = ""

        IF IsNull(collateralTabRS("documentTabId")) THEN
            tabMaintUrl = "documenttabmaint.asp?documentDefId=" & collateralTabRS("documentDefId") & "&loanId=" & targetCollateralLoanId
        ELSE
            tabMaintUrl = "documenttabmaint.asp?documentTabId=" & collateralTabRS("documentTabId")
        END IF

        IF docTabAllowSchedule THEN
            showDocSchedule = True
            imgDocSchedule = "fa-calendar-check"
            altDocSchedule = "Manage Document Schedule"
        END IF

        docTabProcessingDateEnd = CheckForNull(collateralTabRS("docTabProcessingDateEnd"))
        IF IsDate(docTabProcessingDateEnd) THEN
            IF Now() >= cDate(docTabProcessingDateEnd) + 1 THEN
                showDocSchedule = True
                imgDocSchedule = "fa-calendar-times"
                altDocSchedule = "Schedule stopped on " & FormatDateTime(docTabProcessingDateEnd,2)
            END IF
        END IF

        ' ### DEFINE ACCOUNT EDITOR PERMISSION ###
        cust_isAccountEditor = false

        IF (Session(extendedAccountClassCode & ".allowDocEdit") _
            OR Session(extendedAccountClassCode & ".allowDocAdd") _
            OR Session(extendedAccountClassCode & ".allowDocScan") _
            OR Session(extendedAccountClassCode & ".allowDocUpload") _
            OR Session(extendedAccountClassCode & ".allowDocScanDelete") _
            OR Session(extendedAccountClassCode & ".allowDocMoveCopy")) THEN
                cust_isAccountEditor = true
        END IF

        ' ### GET DOCUMENT ACCESS PERMISSIONS ###
        documentSubTypeId = collateralTabRS("documentSubTypeId")
        allowDocumentAccess = AllowAccountTabAccess(documentSubtypeId)

        '### Determine access to employee hidden file ###
        docHideEmployeeFileYN = collateralTabRS("hideEmployeeFileYN")
        empAccessAllowed = True

        IF NOT employeeViewer AND cBool(CustomerRS("employee")) AND docHideEmployeeFileYN = "Y" THEN
            empAccessAllowed = False
        END IF

        ' ### DRAG AND DROP ROW BASED ON PERMISSIONS ###
        Dim collateralDocStatus : collateralDocStatus = collateralTabRS("documentStatus")
        IF Session("accuaccount.disableImaging") = "0" THEN ' ### ENSURE IMAGING IS ENABLED
            IF Session("IsSuperUser") OR (Session(extendedAccountClassCode & ".allowDocUpload") AND allowLoanBranchAccess AND empAccessAllowed) THEN
                IF Trim(collateralDocStatus & "") = "1" THEN
                    %><tr <%=display%><% IF displayTab THEN %> class="aa-row doc-drop" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row doc-drop tabGroup<%=tabCount%>Child"<% END IF %> ondragover="allowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropCopyData('<%=targetCollateralLoanId%>', '<%=collateralTabRS("documentDefId")%>', '', '<%=collateralTabRS("documentTabId")%>', event);"><%
                ELSE
                    %><tr <%=display%><% IF displayTab THEN %> class="aa-row doc-drop" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row doc-drop tabGroup<%=tabCount%>Child"<% END IF %> ondragover="allowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropCopyData('<%=targetCollateralLoanId%>', '<%=collateralTabRS("documentDefId")%>', '<%=collateralTabRS("documentId")%>', '<%=collateralTabRS("documentTabId")%>', event);"><%
                END IF
            ELSE
                %><tr <%=display%><% IF displayTab THEN %> class="aa-row" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row tabGroup<%=tabCount%>Child"<% END IF %> ondragover="disallowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropNoPermission(event);"><%
            END IF
        ELSE
           %><tr <%=display%><% IF displayTab THEN %> class="aa-row" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row tabGroup<%=tabCount%>Child"<% END IF %>><%
        END IF
            %>
            <!-- EXPANDER COLUMN -->
            <%
            IF displayTab THEN
                %><td class="column-expander"><a href="javascript:void(0);" style="display:none" id="tabGroup<%=tabCount%>Expander" onclick="CollapsibleDocumentsToggle('<%=tabCount%>')"><i class="aa-icon fas fa-caret-right<% IF NOT cBool(Session("enableCollapsibleDocuments")) THEN %> rotate<% END IF %> fa-fw" id="tab-group-expander-icon-<%=tabCount%>" aria-hidden="true"></i></a></td><%
            ELSE
                %><td class="column-expander">&nbsp;</td><%
            END IF ' ### IF displayTab
            %>
            <!-- TAB ACTION COLUMN -->
            <%
            IF cust_isAccountEditor THEN
                IF displayTab THEN
                    IF (Session(extendedAccountClassCode & ".allowDocEdit") _
                        OR Session(extendedAccountClassCode & ".allowDocAdd") _
                        OR Session(extendedAccountClassCode & ".allowDocScan") _
                        OR Session(extendedAccountClassCode & ".allowDocScanDelete") _
                        OR Session(extendedAccountClassCode & ".allowDocUpload") _
                        OR Session(extendedAccountClassCode & ".allowDocMoveCopy") ) _
                        AND allowLoanBranchAccess THEN

                        IF collateralTabRS("documentTabId") <> "" THEN
                            documentActionUrl = "documentaction.asp?documentTabId=" & collateralTabRS("documentTabId") & "&loanId=" & targetCollateralLoanId & "&customerId=" & customerId & "&extendedAccountClassCode=" & extendedAccountClassCode
                        ELSE
                            documentActionUrl = "documentaction.asp?loanId=" & targetCollateralLoanId & "&customerId=" & customerId & "&documentDefId=" & collateralTabRS("documentDefId") & "&extendedAccountClassCode=" & extendedAccountClassCode
                        END IF
                        IF NOT cBool(Session("enableCollapsibleDocuments")) THEN ' ### IF FOLDER IS EXPANDED ###
                            %><td class="column-tab-action"><a href="javascript:void(0);" onclick="openKendoDialog('Tab Action', '<%=documentActionUrl%>', 500, 735);" class="aa-command-link aa-tab-action-link"><i class="aa-icon fas fa-folder-open fa-fw" id="tab-folder-<%=tabCount%>" title="<%=documentInstruction%>" aria-hidden="true"></i></a></td><%
                        ELSE
                            %><td class="column-tab-action"><a href="javascript:void(0);" onclick="openKendoDialog('Tab Action', '<%=documentActionUrl%>', 500, 735);" class="aa-command-link aa-tab-action-link"><i class="aa-icon fas fa-folder fa-fw" id="tab-folder-<%=tabCount%>" title="<%=documentInstruction%>" aria-hidden="true"></i></a></td><%
                        END IF
                    ELSE
                        IF NOT cBool(Session("enableCollapsibleDocuments")) THEN ' ### IF FOLDER IS EXPANDED ###
                            %><td class="column-tab-action"><i class="aa-icon folder fas fa-folder-open fa-fw" id="tab-folder-<%=tabCount%>" aria-hidden="true"></i></td><%
                        ELSE
                            %><td class="column-tab-action"><i class="aa-icon folder fas fa-folder fa-fw" id="tab-folder-<%=tabCount%>" aria-hidden="true"></i></td><%
                        END IF
                    END IF
                ELSE
                    %><td class="column-tab-action">&nbsp;</td><%
                END IF ' ### IF displayTab
            ELSE
                IF displayTab THEN
                    IF NOT cBool(Session("enableCollapsibleDocuments")) THEN ' ### IF FOLDER IS EXPANDED ###
                        %><td class="column-tab-action"><i class="aa-icon folder fas fa-folder-open fa-fw" id="tab-folder-<%=tabCount%>" aria-hidden="true"></i></td><%
                    ELSE
                        %><td class="column-tab-action"><i class="aa-icon folder fas fa-folder fa-fw" id="tab-folder-<%=tabCount%>" aria-hidden="true"></i></td><%
                    END IF
                ELSE
                    %><td class="column-tab-action">&nbsp;</td><%
                END IF
            END IF ' ### IF cust_isAccountEditor
            %>
            <!-- DOCUMENT STATUS COLUMN -->
            <td class="column-doc-status"><i class="fa <%=iconFilename%> fa-fw" title="<%=altDocumentStatus%>" aria-hidden="true"></i></td>
            <!-- DOCUMENT ACCESS COLUMN -->
            <%
            escFileName = collateralTabRS("fileName")
            documentTypeIcon = GetDocumentTypeIcon(escFileName)

            loanBranchId              = collateralTabRS("loanBranchId")
            customerIsEmployee        = CustomerRS("employee")
            documentTabIsEmployeeFile = collateralTabRS("hideEmployeeFileYN") = "Y"
            documentFilename          = collateralTabRS("filename")
            documentStatus            = collateralTabRS("documentStatus")
            serverUrl                 = TrimTrailingSlash(Session("acculoan.serverURL"))
            documentId                = collateralTabRS("documentId")
            customerFolder            = collateralTabRS("customerFolder")
            loanFolder                = collateralTabRS("loanFolder")
            documentTabFolder         = collateralTabRS("loanFile")

            ' ### Determine the document's view access
            '
            'allowBranchAccess      = hasCustomerBranchAccess(selectedCustomerId)
            isCustomerEmployeeFile = customerIsEmployee And documentTabIsEmployeeFile
            fileHasDemographicData = collateralTabRS("hasDemographicData")
            Set viewDocumentAccess = usr.Security.HasDocumentViewAccess(extendedAccountClassCode, loanBranchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)

            IF Session("accuaccount.disableImaging") = "1" THEN
                ' ### DO NOTHING, HAS COLUMN IS HIDDEN IF DISABLED
            ELSEIF (documentStatus = "1" Or (documentStatus = "3" And documentFilename <> "")) THEN
                IF viewDocumentAccess.HasAccess THEN
                    Dim collateralDocumentId : collateralDocumentId = collateralTabRS("documentId")
                    Dim collateralFileRoute  : collateralFileRoute  = GetDocumentFileViewUrl(collateralDocumentId, Session("userId"))

                    viewDocumentUrl = "Start('" & collateralFileRoute & "');"
                %><td class="column-doc-access"><a href="javascript:void(0);" onclick="<%=viewDocumentUrl%>" class="aa-command-link"><i class="<%=documentTypeIcon%>" title="Click Here to View Document" aria-hidden="true"></i></a></td><%
                ELSE
                %><td class="column-doc-access"><i class="aa-icon lock fad fa-lock fa-fw aa-disabled" title="<%=viewDocumentAccess.Reason%>" aria-hidden="true"></i></td><%
                END IF
            ELSE
                %><td class="column-doc-access"><i class="aa-file-type-icon misc fad fa-file fa-fw aa-disabled" title="No Document" aria-hidden="true"></i></td><%
            END IF
            %>
            <!-- DOCUMENT SUBTYPE NAME OR DOCUMENT TITLE COLUMN -->
            <%
            displayDocumentTitle = Trim(collateralTabRS("documentTitle") & "")
            displayDocumentSubTypeName = Trim(collateralTabRS("documentSubTypeName") & "")

            IF displayTab THEN
                IF displayDocumentTitle <> "" THEN
                    IF displayDocumentTitle <> displayDocumentSubTypeName THEN
                        displayDocumentTitle = displayDocumentSubTypeName & " (" & displayDocumentTitle & ")"
                    ELSE
                        displayDocumentTitle = displayDocumentSubTypeName
                    END IF
                ELSE
                    displayDocumentTitle = displayDocumentSubTypeName
                END IF
            ELSE
                IF displayDocumentTitle = "" THEN
                    displayDocumentTitle = displayDocumentSubTypeName
                END IF
            END IF

            ellipsisDocumentTitle = "<div class=""ellipsis-outer""><div>" & Server.HTMLEncode(displayDocumentTitle) & "</div></div>"

            IF (collateralDocStatus = "1" OR (collateralDocStatus = "3" AND collateralTabRS("filename") <> "")) THEN
                IF viewDocumentAccess.HasAccess THEN
                    IF Trim(documentTitleColor & "") <> "#000000" THEN
                        %><td style="color:<%=documentTitleColor%>"><%=ellipsisDocumentTitle%></td><%
                    ELSE
                        %><td><%=ellipsisDocumentTitle%></td><%
                    END IF
                ELSE
                    IF Trim(documentTitleColor & "") <> "#000000" THEN
                        %><td style="color:rgba(<%=hexConvert(documentTitleColor)%>, <%=textOpacity%>)"><%=ellipsisDocumentTitle%></td><%
                    ELSE
                        %><td class="aa-disabled-title"><%=ellipsisDocumentTitle%></td><%
                    END IF
                END IF
            ELSE
                IF Trim(documentTitleColor & "") <> "#000000" THEN
                    %><td style="color:rgba(<%=hexConvert(documentTitleColor)%>, <%=textOpacity%>)"><%=ellipsisDocumentTitle%></td><%
                ELSE
                    %><td class="aa-disabled-title"><%=ellipsisDocumentTitle%></td><%
                END IF
            END IF
            %>
            <!-- EXPIRATION DATE COLUMN -->
            <%
            IF collateralTabRS("requireExpDate") THEN
                today = Now()
                expDate = collateralTabRS("expDate")

                IF collateralTabRS("nonExpiring") THEN
                    %><td class="column-expiration"><span class="expiring-date expirable" title="Document would normally expire, but was overridden not to.">Expirable</span></td><%
                ELSEIF NOT IsDate(expDate) THEN
                    %><td class="column-expiration">&nbsp;</td><%
                ELSEIF cDate(today) > cDate(expDate) THEN
                        ' ### EXPIRED ###
                    %><td class="column-expiration"><span class="expiring-date expired" title="Expired"><%=GetPaddedDateString(collateralTabRS("expDate"))%></span></td><%
                ELSE
                        ' ### EXPIRES ON CERTAIN DATE ###
                    %><td class="column-expiration"><span class="expiring-date expires" title="Expires on"><%=GetPaddedDateString(collateralTabRS("expDate"))%></span></td><%
                END IF
            ELSE
                %><td class="column-expiration">&nbsp;</td><%
            END IF
            %>
            <!-- Require QC Indicator -->
			<%
                QcApprovalIcon = "&nbsp;"
                RequireQc      = collateralTabRS("RequireQc")
                QcStatus       = collateralTabRS("QcStatus")

                IF RequireQc AND QcStatus <> 1 THEN
                    QcApprovalIcon = "<i class=""aa-icon fad fa-shield-exclamation aa-document-unapproved"" style=""--fa-primary-color:#ca3f3f; --fa-secondary-color:#e27d7a;"" title=""<div style='text-align: left'><strong>Requires QC</strong><br />This type of document requires quality control and must be approved before it can be used. Documents that are not approved may be incomplete or incorrect.</div>"" aria-hidden=""true""></i>"    
                ELSEIF RequireQc AND QcStatus = 1 THEN
                    QcApprovalIcon = "<i class=""aa-icon fad fa-shield-check aa-document-approved"" style=""--fa-primary-color: #3fca5b; --fa-secondary-color: #89d489"" title=""<div style='text-align: left'><strong>Approved</strong><br />This document is approved and is good to go!</div>"" aria-hidden=""true""></i>"    
                END IF
            %>
                <td class=""><%=QcApprovalIcon%></td>
            <!-- PURGE ICON COLUMN -->
            <%
            IF Session("acculoan.enablePurge") = 1 THEN
                %><td class="column-purge"><%=GetPurgeStatusIcon(collateralTabRS("PurgeStatus"), collateralTabRS("PurgeStatusLocked"), collateralTabRS("BlockPurge"))%></td><%
            END IF
            %>
            <!-- WAIVED DOCUMENT COLUMN -->
            <%
            IF collateralTabRS("documentStatusType") = "3" THEN
                %><td class="column-waived"><i class="aa-icon fas fa-exclamation-triangle aa-color-warning fa-fw" title="Waived" aria-hidden="true"></i></td><%
            ELSE
                %><td class="column-waived">&nbsp;</td><%
            END IF
            %>
            <!-- COMMENT ICON COLUMN -->
            <%
            IF Trim(collateralTabRS("documentComment")) <> "" THEN
                Dim collateralComment : collateralComment = Trim(collateralTabRS("documentComment"))
                collateralComment = InsertCarriageReturns(collateralComment, 40)
                IF LEN(collateralComment) > 70 THEN collateralComment = Left(collateralComment, 70) & "..."
                collateralComment = Server.HTMLEncode(collateralComment)
                %><td class="column-comment"><a href="javascript:void(0);" onclick="openKendoDialog('View Document Comment', 'viewcomment.asp?documentId=<%=collateralTabRS("documentId")%>', 400, 500);" class="aa-command-link"><i class="aa-icon fas fa-comments fa-fw" title="<%=collateralComment%>" aria-hidden="true"></i></a></td><%
            ELSE
                %><td class="column-comment">&nbsp;</td><%
            END IF
            %>
            <!-- DOCUMENT SCHEDULE COLUMN -->
            <%
            IF cust_isAccountEditor THEN
                IF displayTab THEN
                    IF showDocSchedule AND (Session("isSuperUser") OR (allowLoanBranchAccess AND (Session(extendedAccountClassCode & ".isAdmin") OR Session(extendedAccountClassCode & ".allowEdit")))) THEN
                        %><td class="column-doc-schedule"><a href="javascript:void(0);" onclick="openKendoDialog('Manage Collateral Document Schedule', '<%=tabMaintUrl%>', 500, 700);" class="aa-action-button"><i class="aa-icon fa <%=imgDocSchedule%> fa-fw" title="<%=altDocSchedule%>" aria-hidden="true"></i></a></td><%
                    ELSEIF showDocSchedule THEN
                        %><td class="column-doc-schedule"><i class="aa-icon far fa-calendar-check aa-disabled fa-fw" title="Schedules Enabled" aria-hidden="true"></i></td><%
                    ELSE
                        %><td class="column-doc-schedule">&nbsp;</td><%
                    END IF
                ELSE
                    %><td class="column-doc-schedule">&nbsp;</td><%
                END IF
            END IF ' ### IF cust_isAccountEditor'
            %>
            <!-- EDIT DOCUMENT ICON COLUMN -->
            <%
            IF cust_isAccountEditor THEN
                ' ### CHECK FOR FILE EXISTANCE ###
                IF collateralDocStatus = "-1" THEN
                    ' ### CHECK FOR FILE EXISTANCE ###
                    docUpdateQuery = "SELECT documentStatus FROM document WHERE documentId = " & dbFormatId(collateralTabRS("documentId"))
                    Set docUpdateRS = Server.CreateObject("ADODB.RecordSet")
                    docUpdateRS.Open docUpdateQuery, db, adOpenKeySet, adLockPessimistic
                    f = Session("fullpath") & Trim(customerRS("customerFolder")) & Trim(collateralTabRS("LoanFile")) & "/" & Trim(collateralTabRS("FileName"))
                    IF fso.FileExists(f) THEN
                        docUpdateRS("documentStatus") = 1
                        collateralDocStatus = "1"
                    ELSE
                        docUpdateRS("documentStatus") = 2
                        collateralDocStatus = "2"
                    END IF
                    docUpdateRS.Update
                    docUpdateRS.Close
                END IF

                ' ### ALSO THE CHECK FOR BRANCH SECURITY IS ON THE PARENT LOAN AND NOT THE COLLATERAL ITSELF. THIS ENSURES THAT THE SECURITY IS CALCULATED PROPERLY BASED ON THE ACCOUNT AND NOT THE COLLATERAL AS COLLATERALS TECHNICALLY HAVE NO BRANCH. ###

                docFilename = collateralTabRS("filename")

                IF empAccessAllowed THEN
                    urlEmpAccessAllowed = ""
                ELSE
                    urlEmpAccessAllowed = "&empAccessAllowed=N&path=" & customerRS("customerFolder")
                END IF

                IF ( Session(extendedAccountClassCode & ".allowDocEdit") _
                    OR Session(extendedAccountClassCode & ".allowDocAdd") _
                    OR Session(extendedAccountClassCode & ".allowDocScan") _
                    OR Session(extendedAccountClassCode & ".allowDocScanDelete") _
                    OR Session(extendedAccountClassCode & ".allowDocUpload") _
                    OR Session(extendedAccountClassCode & ".allowDocMoveCopy") ) _
                    AND allowLoanBranchAccess THEN

                    IF allowDocumentAccess THEN
                        IF collateralTabRS("documentId") <> "" THEN
                            IF empAccessAllowed THEN
                                documentMaintArgList = _
                                    "action=EDIT&" & _
                                    "documentId=" & collateralTabRS("documentId") & _
                                    "&loanId=" & targetCollateralLoanId & urlEmpAccessAllowed
                            ELSE
                                documentMaintArgList = _
                                    "action=ADDSCAN&" & _
                                    "loanId=" & targetCollateralLoanId & _
                                    "&documentDefId=" & collateralTabRS("documentDefId") & urlEmpAccessAllowed
                            END IF
                        ELSE
                            documentMaintArgList = _
                                "action=ADD" & _
                                "&loanId=" & targetCollateralLoanId & _
                                "&documentDefId=" & collateralTabRS("documentDefId") & urlEmpAccessAllowed
                        END IF
                        %><td class="column-doc-edit"><a href="javascript:void(0);" onclick="openKendoDialog('Edit Document', 'documentmaint.asp?<%=documentMaintArgList%>&extendedAccountClassCode=<%=extendedAccountClassCode%>&isParticipation=<%=targetParentIsParticipationLoan%>', 470, 700);" class="aa-action-button"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Document" aria-hidden="true"></i></a></td><%
                    ELSE
                        %><td class="column-doc-edit"><span class="aa-action-button disabled"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Document" aria-hidden="true"></i></span></td><%
                    END IF
                ELSE
                    %><td class="column-doc-edit"><span class="aa-action-button disabled"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Disabled" aria-hidden="true"></i></span></td><%
                END IF
            END IF ' ### IF cust_isAccountEditor
            %>
        </tr>
        <%
        collateralTabRS.MoveNext
    LOOP ' ### DO UNTIL collateralTabRS.EOF
    collateralTabRS.Close

    ' ### Display message if no active documents can be displayed ###
    IF tabDisplayEmpty THEN
        collateralDocCount = 0
        Dim collateralDocTestQuery, collateralDocTestRS
        Set collateralDocTestRS = Server.CreateObject("ADODB.RecordSet")
        collateralDocTestQuery = _
            " SELECT " & _
            "   TOP 1 1 " & _
            " FROM " & _
            "   loan AS l " & _
            "   INNER JOIN documentDefinitions AS dd ON l.loanTypeId = dd.loanTypeId " & _
            "   INNER JOIN documentType AS dt ON dt.documentTypeId = dd.documentTypeId " & _
            "   INNER JOIN documentSubType AS dst ON dst.documentSubTypeId = dd.documentSubTypeId " & _
            "   LEFT OUTER JOIN documentTab AS dtab ON dtab.loanId = l.loanId AND dtab.documentDefId = dd.documentDefId " & _
            "   LEFT OUTER JOIN document AS d ON d.documentTabId = dtab.documentTabId " & _
            " WHERE " & _
            "   l.loanId = " & dbFormatId(targetCollateralLoanId) & _
            "   AND dd.hideTabYN <> 'Y' " & _
            "   AND (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 OR IsNull(d.documentStatus, 2) = 1) "
        collateralDocTestRS.Open collateralDocTestQuery, db
        IF NOT collateralDocTestRS.EOF THEN collateralDocCount = 1
        collateralDocTestRS.Close
        Set collateralDocTestRS = Nothing

        IF (Session(extendedAccountClassCode & ".allowDocEdit") _
            OR Session(extendedAccountClassCode & ".allowEdit") _
            OR Session(extendedAccountClassCode & ".isAdmin") _
            OR Session("isSuperUser") ) _
            AND allowLoanBranchAccess _
            AND collateralDocCount > 0 THEN
            Response.Write "<tr class=""activate-groups"">" & vbCr _
                         & "    <td colspan=""" & COLLATERAL_DOC_SPAN & """><a href=""javascript:void(0)"" onclick=""openKendoDialog('Activate Collateral Groups', 'custactivategroups.asp?group=loan&customerId=" & targetCustomerId & "&loanId=" & targetCollateralLoanId & "&accountClassCode=" & extendedAccountClassCode & "', 500, 700);"">Activate Groups</a></td>" & vbCr _
                         & "</tr>" & vbCr
        END IF
        %>
        <tr>
            <td colspan="<%=COLLATERAL_DOC_SPAN%>">&nbsp; &nbsp;<b><i>No active/defined documents.</i></b><br><br></td>
        </tr>
        <% END IF %>
    </table>
    <%
    collateralDocEnd = Timer()
    collateralDocDelta = collateralDocEnd-collateralDocStart
    %>