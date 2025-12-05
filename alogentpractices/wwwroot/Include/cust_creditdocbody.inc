<%
creditDocStart = Timer()

Dim CREDIT_DOC_SPAN : CREDIT_DOC_SPAN = 12
IF Session("acculoan.enablePurge") = 0 THEN CREDIT_DOC_SPAN = CREDIT_DOC_SPAN - 1
IF Session("accuaccount.disableImaging") = "1" THEN CREDIT_DOC_SPAN = CREDIT_DOC_SPAN - 1

Dim rowCount : rowCount = 0
Dim creditTabQuery
Dim creditTabRS : Set creditTabRS = Server.CreateObject("ADODB.RecordSet")
Dim creditDocumentArray, singleTab
Dim urlEmpAccessAllowed
Dim empAccessAllowed : empAccessAllowed = True
Dim textOpacity : textOpacity = "0.5"

' ### Build Credit Tab query for the currently viewed customer ###
creditTabQuery = _
    " SELECT" & _
    "   dtab.customerId," & _
    "   c.customerBranchId," & _
    "   dtab.documentTabId," & _
    "   IsNull(dtab.documentDefId,dd.documentDefId) AS documentDefId," & _
    "   IsNull(dtab.docTabStatusType,dd.defaultDocumentStatusType) AS docTabStatusType," & _ 
    "   IsNull(dtab.docTabHighlightColor,dd.docDefHighlightColor) AS docTabHighlightColor," & _
    "   dt.documentTypeId," & _
    "   dst.documentSubTypeId," & _
    "   dt.documentTypeName," & _ 
    "   dt.typeSortOrder," & _
    "   dd.sortOrder," & _
    "   IsNull(d.[PurgeStatus], 0) AS PurgeStatus," & _
    "   IsNull(d.[PurgeStatusLocked], 0) AS PurgeStatusLocked," & _
    "   CASE WHEN IsNull(d.documentStatus,2)=1 AND (dst.[BlockPurge]=1 OR dd.[BlockPurge]=1) THEN CONVERT(bit,1) ELSE CONVERT(bit,0) END AS BlockPurge," & _
    "   dst.subTypeDescription," & _
    "   dst.subTypeInstruction," & _
    "   dst.subTypeScanFlag," & _
    "   dd.requireExpdate," & _
    "   dd.hideEmployeeFileYN, " & _
    "   dd.hideTabYN," & _
    "   dd.defaultActivationStatus," & _
    "   dd.docDefHighlightColor, " & _
    "   dd.docDefDocSortBy," & _
    "   dd.docDefAllowSchedule," & _
    "   dd.RequireQc," & _
    "   dd.CriticalQc," & _
    "   ISNULL(qc.QcStatus, 0) AS QcStatus," & _
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
    "   d.[documentComment]," & _
    "   IsNull(d.[documentTitle], dst.documentSubTypeName) AS documentTitle," & _
    "   IsNull(IsNull(d.[documentHighlightColor], dtab.docTabHighlightColor), dd.docDefHighlightColor) AS documentHighlightColor," & _
    "   IsNull(d.[nonExpiring], 0) AS nonExpiring," & _
    "   dsto.hasDemographicData" & _
    " FROM" & _
    "   customer AS c INNER JOIN documentDefinitions AS dd" & _
    "       ON c.customerTypeId=dd.customerTypeId" & _
    "       AND c.customerId=" & dbFormatId(selectedCustomerId) & _
    "       AND c.bankId=dd.bankId" & _
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
    " WHERE " & _
    "   dd.hideTabYN <> 'Y'" & _
    "   AND (" & _
    "       (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 AND LOWER(IsNull(da.activationStatus,dd.defaultActivationStatus)) = 'on')" & _
    "        OR IsNull(d.documentStatus,2) = 1" & _
    "   ) " & _
    " ORDER BY " & _
    "   dd.sortOrder," & _
    "   dt.documentTypeName," & _
    "   dst.documentSubTypeName," & _
    "   d.origdate DESC"
creditTabRS.Open creditTabQuery, db, adOpenForwardOnly, adLockReadOnly
%>
<table class="aa-section-wrapper">
    <%
    ' ### DEFINE CREDIT EDITOR PERMISSION ###
    Dim cust_isCreditEditor : cust_isCreditEditor = false

    IF (Session("credit.allowDocEdit") _
        OR Session("credit.allowDocAdd") _
        OR Session("credit.allowDocScan") _
        OR Session("credit.allowDocScanDelete") _
        OR Session("credit.allowDocUpload") _
        OR Session("credit.allowDocMoveCopy")) THEN
        cust_isCreditEditor = true
    ELSE
        CREDIT_DOC_SPAN = CREDIT_DOC_SPAN - 2
    END IF

    IF NOT creditTabRS.EOF THEN
        creditDocumentArray = creditTabRS.GetRows(adGetRowsRest, , creditFieldsArray)
        ' ### Loop through credit documentTabs for given customer ###
        documentTypeName = ""
        numRows = uBound(creditDocumentArray, 2) + 1
        tabDisplayEmpty = false
    ELSE
        tabDisplayEmpty = true
    END IF
    creditTabRS.Close

    WHILE rowCount < numRows
        nextRow = rowCount + 1
        documentTabId = creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount)

        ' ### Only display the Group (documentType) once ###
        IF documentTypeName <> creditDocumentArray(creditFieldsDict.Item("documentTypeName"), rowCount) THEN
            displayTab = true
            documentTypeName = creditDocumentArray(creditFieldsDict.Item("documentTypeName"), rowCount)
            %>
            <tr class="aa-header-row" id="tabHeader<%=GetNextGroupCount()%>">
                <td colspan="<%=CREDIT_DOC_SPAN%>">
                    <input type="hidden" id="uxTabHeader<%=groupCount-1%>Children" name="tabHeader<%=groupCount-1%>Children" value="<%=groupChildren%>"/>
                    <% groupChildren = "" %>
                    <ul class="aa-row-icons groups">
                        <li><span id="tabHeader<%=groupCount%>Expander" onclick="CollapsibleGroupsToggle('<%=groupCount%>')" class="aa-collapse-expand-icon aa-command-link"><i class="aa-icon fas fa-<% IF Session("enableCollapsibleGroups") THEN %>plus<% ELSE %>minus<% END IF %>-square fa-fw" id="tab-header-expander-icon-<%=groupCount%>" aria-hidden="true"></i></span></li>
                        <li><a href="javascript:void(0);" onclick="openKendoDialog('Active Credit Tabs', 'custactivatetabs.asp?group=credit&customerId=<%=selectedCustomerId%>&documentTypeId=<%=creditDocumentArray(creditFieldsDict.Item("documentTypeId"), rowCount)%>&accountClassCode=credit', 500, 700);"><%=creditDocumentArray(creditFieldsDict.Item("documentTypeName"), rowCount)%></a></li>
                    </ul>
                </td>
            </tr>
            <%
        END IF ' ### oldDocumentTypeName <> creditTabRS("documentTypeName")

        ' ### Prepare the document instruction for tool tip hover ###
        documentInstruction = creditDocumentArray(creditFieldsDict.Item("subTypeInstruction"), rowCount)
        IF Trim(documentInstruction & "") <> "" THEN
            documentInstruction = Server.HTMLEncode(Replace(documentInstruction, vbcrlf, "<br/>"))
        ELSE
            documentInstruction = ""
        END IF

        displayTab = true ' ### Reset flag to display tab information
        singleTab = true ' ### Reset flag to check if more than one doc within tab

        ' ### Logic for displaying Tab only for first row AND document title when needed ###
        IF (lastDocumentTabId = documentTabId) THEN displayTab = false

        ' ### Check the next row ###
        IF nextRow < numRows THEN
            IF documentTabId = creditDocumentArray(creditFieldsDict.Item("documentTabId"), nextRow) THEN
                singleTab = false
            END IF
        END IF


        IF creditDocumentArray(creditFieldsDict.Item("documentStatus"), rowCount) = 1 THEN
            iconFilename = "fa-circle aa-status-yes fa-fw"
            altDocumentStatus = "Exists"
            altTitleStatus = "Document Exists"
        ELSEIF creditDocumentArray(creditFieldsDict.Item("documentStatus"), rowCount) = 3 THEN
            iconFilename = "fa-circle aa-status-pending fa-fw"
            altDocumentStatus = "Changed"
            altTitleStatus = "Document has Changed"
        ELSE
            iconFilename = "fa-circle aa-status-no fa-fw"
            altDocumentStatus = "Doesn't Exist"
            altTitleStatus = "No Document Exists"
        END IF

        ' ### Process documentTitle if the name is the same as the Tab ###
        documentTitleColor = creditDocumentArray(creditFieldsDict.Item("documentHighlightColor"), rowCount)
        documentTitle = creditDocumentArray(creditFieldsDict.Item("documentTitle"), rowCount)

        IF documentTitle = creditDocumentArray(creditFieldsDict.Item("documentSubTypeName"), rowCount) AND displayTab THEN
            documentTitle = ""
        END IF

        Dim display : display = ""
        IF Session("enableCollapsibleGroups") THEN
            display = " style=""display:none"""
        ELSE
            IF Session("enableCollapsibleDocuments") THEN
                IF NOT displayTab THEN
                    display = " style=""display:none"""
                END IF
            END IF
        END IF

        docTabAllowSchedule = creditDocumentArray(creditFieldsDict.Item("docTabAllowSchedule"), rowCount)
        tabMaintUrl = ""
        showDocSchedule = False
        imgDocSchedule = ""
        altDocSchedule = ""

        documentTabId = creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount)
        documentDefId = creditDocumentArray(creditFieldsDict.Item("documentDefId"), rowCount)
        IF IsNull(documentTabId) THEN
            tabMaintUrl = "documenttabmaint.asp?customerId=" & selectedCustomerId & "&documentDefId=" & documentDefId
        ELSE
            tabMaintUrl = "documenttabmaint.asp?documentTabId=" & documentTabId
        END IF

        IF docTabAllowSchedule THEN
            imgDocSchedule = "fa-calendar-check"
            showDocSchedule = True
            altDocSchedule = "Manage Document Schedule"
        END IF

        docTabProcessingDateEnd = CheckForNull(creditDocumentArray(creditFieldsDict.Item("docTabProcessingDateEnd"), rowCount))
        IF IsDate(docTabProcessingDateEnd) THEN
            IF Now() >= cDate(docTabProcessingDateEnd) + 1 THEN
                showDocSchedule = True
                imgDocSchedule = "fa-calendar-times"
                altDocSchedule = "Schedule stopped on " & FormatDateTime(docTabProcessingDateEnd,2)
            END IF
        END IF

        ' ### Add logic here to get tab security access for document viewing ###
        documentSubTypeId = creditDocumentArray(creditFieldsDict.Item("documentSubTypeId"), rowCount)
        allowDocumentAccess = AllowCreditTabAccess(documentSubtypeId)

        ' ### Determine access to employee hidden file ###
        docHideEmployeeFileYN = creditDocumentArray(creditFieldsDict.Item("hideEmployeeFileYN"), rowCount)
        empAccessAllowed = True

        IF NOT employeeViewer AND cBool(CustomerRS("employee")) AND docHideEmployeeFileYN = "Y" THEN
            empAccessAllowed = False
        END IF

        Dim creditDocStatus : creditDocStatus = creditDocumentArray(creditFieldsDict.Item("documentStatus"), rowCount)

        ' ### DRAG AND DROP ROW BASED ON PERMISSIONS ###
        IF Session("accuaccount.disableImaging") = "0" THEN ' ### ENSURE IMAGING IS ENABLED
            IF Session("IsSuperUser") OR (Session("credit.allowDocUpload") AND allowCustomerBranchAccess AND empAccessAllowed) THEN
                IF Trim(creditDocStatus & "") = "1" THEN
                    %><tr <%=display%><% IF displayTab THEN %> class="aa-row doc-drop" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row doc-drop tabGroup<%=tabCount%>Child"<% END IF %> ondragover="allowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropCopyData('', '<%=creditDocumentArray(creditFieldsDict.Item("documentDefId"), rowCount)%>', '', '<%=creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount)%>', event);"><%
                ELSE
                    %><tr <%=display%><% IF displayTab THEN %> class="aa-row doc-drop" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row doc-drop tabGroup<%=tabCount%>Child"<% END IF %> ondragover="allowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropCopyData('', '<%=creditDocumentArray(creditFieldsDict.Item("documentDefId"), rowCount)%>', '<%=creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)%>', '<%=creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount)%>', event);"><%
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
            IF cust_isCreditEditor THEN
                IF displayTab THEN
                    IF (Session("credit.allowDocEdit") _
                        OR Session("credit.allowDocAdd") _
                        OR Session("credit.allowDocScan") _
                        OR Session("credit.allowDocScanDelete") _
                        OR Session("credit.allowDocUpload") _
                        OR Session("credit.allowDocMoveCopy") ) _
                        AND allowCustomerBranchAccess THEN

                        IF empAccessAllowed THEN
                            urlEmpAccessAllowed = ""
                        ELSE
                            urlEmpAccessAllowed = "&empAccessAllowed=N"
                        END IF

                        IF creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount) <> "" THEN
                            documentActionUrl = _
                                "documentaction.asp?" & _
                                "documentTabId=" & creditDocumentArray(creditFieldsDict.Item("documentTabId"), rowCount) & _
                                "&customerId=" & selectedCustomerId & _
                                "&extendedAccountClassCode=credit" & urlEmpAccessAllowed
                        ELSE
                            documentActionUrl = _
                                "documentaction.asp?" & _
                                "customerId=" & selectedCustomerId & _
                                "&documentDefId=" & creditDocumentArray(creditFieldsDict.Item("documentDefId"), rowCount) & _
                                "&extendedAccountClassCode=credit" & urlEmpAccessAllowed
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
            END IF ' ### IF cust_isCreditEditor
            %>
            <!-- DOCUMENT STATUS COLUMN -->
            <td class="column-doc-status"><i class="fa <%=iconFilename%> fa-fw" title="<%=altDocumentStatus%>" aria-hidden="true"></i></td>
            <!-- DOCUMENT ACCESS COLUMN -->
            <%
            ' ### THE FOLLOWING HAS SOME VERY SUBTLE LOGIC FOR DETERMINING THE VIEW DOCUMENT ICON. PLEASE BE CAREFUL WHEN MAKING CHANGES TO THESE CONDITIONS. ###
            docHideEmployeeFileYN = creditDocumentArray(creditFieldsDict.Item("hideEmployeeFileYN"), rowCount)
            empAccessAllowed = True

            Dim escFileName : escFileName = creditDocumentArray(creditFieldsDict.Item("fileName"), rowCount)
            Dim documentTypeIcon : documentTypeIcon = GetDocumentTypeIcon(escFileName)

            customerBranchId          = creditDocumentArray(creditFieldsDict.Item("customerBranchId"), rowCount)
            customerIsEmployee        = CustomerRS("employee")
            documentTabIsEmployeeFile = creditDocumentArray(creditFieldsDict.Item("hideEmployeeFileYN"), rowCount) = "Y"
            documentFilename          = creditDocumentArray(creditFieldsDict.Item("filename"), rowCount)
            documentStatus            = creditDocumentArray(creditFieldsDict.Item("documentStatus"), rowCount)
            serverUrl                 = TrimTrailingSlash(Session("acculoan.serverURL"))
            documentId                = creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)
            customerFolder            = creditDocumentArray(creditFieldsDict.Item("customerFolder"), rowCount)
            loanFolder                = ""
            documentTabFolder         = creditDocumentArray(creditFieldsDict.Item("loanFile"), rowCount)

            ' ### Determine the document's view access
            '
            
            isCustomerEmployeeFile = customerIsEmployee AND documentTabIsEmployeeFile
            fileHasDemographicData = creditDocumentArray(creditFieldsDict.Item("hasDemographicData"), rowCount)
            Set viewDocumentAccess = usr.Security.HasDocumentViewAccess("credit", customerBranchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)

            IF Session("accuaccount.disableImaging") = "1" THEN
                ' ### DO NOTHING, HAS COLUMN IS HIDDEN IF DISABLED
            ELSEIF (documentStatus = "1" Or (documentStatus = "3" And documentFilename <> "")) THEN
                IF viewDocumentAccess.HasAccess THEN
                    Dim creditDocumentId : creditDocumentId = creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)
                    Dim creditFileRoute  : creditFileRoute  = GetDocumentFileViewUrl(creditDocumentId, Session("userId"))
                    viewDocumentUrl = "javascript:Start('" & creditFileRoute & "');"
                %><td class="column-doc-access"><a href="javascript:void(0);" onclick="<%=viewDocumentUrl%>" class="aa-command-link"><i class="<%=documentTypeIcon%>" title="Click Here to View Document" aria-hidden="true"></i></a></td><%
                ELSE
                %><td class="column-doc-access"><i class="aa-icon lock fad fa-lock fa-fw aa-disabled" title="<%=viewDocumentAccess.Reason%>" aria-hidden="true"></i></td><%
                END IF
            ELSE
                %><td class="column-doc-access"><i class="aa-file-type-icon misc fad fa-file fa-fw aa-disabled" title="No Document" aria-hidden="true"></i></td><%
            END IF
            %>
            <!-- DOCUMENT SUBTYPE NAME Or DOCUMENT TITLE COLUMN -->
            <%
            Dim displayDocumentTitle : displayDocumentTitle = Trim(creditDocumentArray(creditFieldsDict.Item("documentTitle"), rowCount) & "")
            Dim displayDocumentSubTypeName : displayDocumentSubTypeName = Trim(creditDocumentArray(creditFieldsDict.Item("documentSubTypeName"), rowCount) & "")

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

            Dim ellipsisDocumentTitle : ellipsisDocumentTitle = "<div class=""ellipsis-outer""><div>" & Server.HTMLEncode(displayDocumentTitle) & "</div></div>"

            IF (creditDocStatus = "1" OR (creditDocStatus = "3" AND creditDocumentArray(creditFieldsDict.Item("filename"), rowCount) <> "")) THEN
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
            IF creditDocumentArray(creditFieldsDict.Item("requireExpDate"), rowCount) THEN
                today = Now()
                expDate = creditDocumentArray(creditFieldsDict.Item("expDate"), rowCount)

                IF creditDocumentArray(creditFieldsDict.Item("nonExpiring"), rowCount) THEN
                    %><td class="column-expiration"><span class="expiring-date expirable" title="Document would normally expire, but was overridden not to.">Expirable</span></td><%
                ELSEIF NOT IsDate(expDate) THEN
                    %><td class="column-expiration">&nbsp;</td><%
                ELSEIF NOT creditDocumentArray(creditFieldsDict.Item("nonExpiring"), rowCount) AND cDate(today) > cDate(expDate)  THEN
                    %><td class="column-expiration"><span class="expiring-date expired" title="Expired"><%=GetPaddedDateString(creditDocumentArray(creditFieldsDict.Item("expDate"), rowCount))%></span></td><%
                ELSE
                    ' ### EXPIRES ON CERTAIN DATE ###
                    %><td class="column-expiration"><span class="expiring-date expires" title="Expires on"><%=GetPaddedDateString(creditDocumentArray(creditFieldsDict.Item("expDate"), rowCount))%></span></td><%
                END IF
            ELSE
                %><td class="column-expiration">&nbsp;</td><%
            END IF
            %>

            <!-- Require QC Indicator -->
            <%
                QcApprovalIcon     = "&nbsp;"
                RequireQc          = creditDocumentArray(creditFieldsDict.Item("RequireQc"), rowCount)
                QcStatus           = creditDocumentArray(creditFieldsDict.Item("QcStatus"), rowCount)

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
                %><td class="column-purge"><%=GetPurgeStatusIcon(creditDocumentArray(creditFieldsDict.Item("PurgeStatus"), rowCount), creditDocumentArray(creditFieldsDict.Item("PurgeStatusLocked"), rowCount), creditDocumentArray(creditFieldsDict.Item("BlockPurge"), rowCount))%></td><%
            END IF
            %>
            <!-- WAIVED DOCUMENT COLUMN -->
            <%
            IF creditDocumentArray(creditFieldsDict.Item("documentStatusType"),rowCount) = "3" THEN
                %><td class="column-waived"><i class="aa-icon fas fa-exclamation-triangle aa-color-warning fa-fw" title="Waived" aria-hidden="true"></i></td><%
            ELSE
                %><td class="column-waived">&nbsp;</td><%
            END IF
            %>
            <!-- COMMENT ICON COLUMN -->
            <%
            IF Trim(creditDocumentArray(creditFieldsDict.Item("documentComment"), rowCount)) <> "" THEN
                Dim creditComment : creditComment = Trim(creditDocumentArray(creditFieldsDict.Item("documentComment"), rowCount))
                creditComment = InsertCarriageReturns(creditComment, 40)
                IF LEN(creditComment) > 70 THEN creditComment = Left(creditComment, 70) & "..."
                creditComment = Server.HTMLEncode(creditComment)
                %><td class="column-comment"><a href="javascript:void(0);" onclick="openKendoDialog('View Document Comment', 'viewcomment.asp?documentId=<%=creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)%>', 400, 500);" class="aa-command-link"><i class="aa-icon fas fa-comments fa-fw" title="<%=creditComment%>" aria-hidden="true"></i></a></td><%
            ELSE
                %><td class="column-comment">&nbsp;</td><%
            END IF
            %>
            <!-- DOCUMENT SCHEDULE COLUMN -->
            <%
            IF cust_isCreditEditor THEN
                IF displayTab THEN
                    IF showDocSchedule AND (Session("isSuperUser") OR (allowCustomerBranchAccess AND (Session("credit.isAdmin") OR Session("credit.allowEdit")))) THEN
                        %><td class="column-doc-schedule"><a href="javascript:void(0);" onclick="openKendoDialog('Manage Credit Document Schedule', '<%=tabMaintUrl%>', 500, 700);" class="aa-action-button"><i class="aa-icon fa <%=imgDocSchedule%> fa-fw" title="<%=altDocSchedule%>" aria-hidden="true"></i></a></td><%
                    ELSEIF showDocSchedule THEN
                        %><td class="column-doc-schedule"><i class="aa-icon far fa-calendar-check aa-disabled fa-fw" title="Schedules Enabled" aria-hidden="true"></i></td><%
                    ELSE
                        %><td class="column-doc-schedule">&nbsp;</td><%
                    END IF
                ELSE
                    %><td class="column-doc-schedule">&nbsp;</td><%
                END IF ' ### IF displayTab
            END IF ' ### IF cust_isCreditEditor
            %>
            <!-- EDIT DOCUMENT ICON COLUMN -->
            <%
            IF cust_isCreditEditor THEN
                ' ### Check for file existance ###
                IF creditDocStatus = "-1" THEN
                    ' ### Check for file existance ###
                    docUpdateQuery = "SELECT documentStatus FROM document WHERE documentId=" & dbFormatId(creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount))
                    Set docUpdateRS = Server.CreateObject("ADODB.RecordSet")
                    docUpdateRS.Open docUpdateQuery, db
                    f = Session("fullpath") & trim(customerRS("customerFolder")) & trim(creditDocumentArray(creditFieldsDict.Item("LoanFile"), rowCount)) & "/" & trim(creditDocumentArray(creditFieldsDict.Item("FileName"), rowCount))
                    IF fso.FileExists(f) THEN
                        docUpdateRS("documentStatus") = 1
                        creditDocStatus = "1"
                    ELSE
                        docUpdateRS("documentStatus") = 2
                        creditDocStatus = "2"
                    END IF
                    docUpdateRS.Update
                    docUpdateRS.Close
                END IF

                IF empAccessAllowed THEN
                    urlEmpAccessAllowed = ""
                ELSE
                    urlEmpAccessAllowed = "&empAccessAllowed=N&path=" & customerRS("customerFolder")
                END IF

                IF (Session("credit.allowDocEdit") _
                    OR Session("credit.allowDocScan") _
                    OR Session("credit.allowDocScanDelete") _
                    OR Session("credit.allowDocUpload") _
                    OR Session("credit.allowDocMoveCopy")) _
                    AND allowCustomerBranchAccess then

                    IF creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount) <> "" THEN
                        IF empAccessAllowed THEN
                            documentMaintArgList = "action=EDIT" & "&documentId=" & creditDocumentArray(creditFieldsDict.Item("documentId"), rowCount)
                        ELSE
                            documentMaintArgList = "action=ADDSCAN" & "&customerId=" & selectedCustomerId & "&documentDefId=" & creditDocumentArray(creditFieldsDict.Item("documentDefId"), rowCount)
                        END IF
                    ELSE
                        documentMaintArgList = "action=ADD&customerId=" & selectedCustomerId & "&documentDefId=" & creditDocumentArray(creditFieldsDict.Item("documentDefId"), rowCount)
                    END IF

                    IF allowDocumentAccess THEN
                        %><td class="column-doc-edit"><a href="javascript:void(0);" onclick="openKendoDialog('Edit Document', 'documentmaint.asp?<%=documentMaintArgList%>&extendedAccountClassCode=credit&isParticipation=false', 470, 700);" class="aa-action-button"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></td><%
                    ELSE
                        %><td class="column-doc-edit"><span class="aa-action-button disabled"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Disabled" aria-hidden="true"></i></span></td><%
                    END IF
                ELSE
                    %><td class="column-doc-edit"><span class="aa-action-button disabled"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Disabled" aria-hidden="true"></i></span></td><%
                END IF
            END IF ' ### IF cust_isCreditEditor
            %>
        </tr>
        <%
        lastDocumentTabId = documentTabId
        rowCount = rowCount + 1
    WEND ' ### END WHILE loop through creditDocumentArray

    Set creditFieldsDict = nothing
    Set creditFieldsArray = nothing

    ' ### Display message if no active documents can be displayed ###
    IF tabDisplayEmpty THEN
        creditDocCount = 0
        Dim creditDocTestRS : Set creditDocTestRS = Server.CreateObject("ADODB.RecordSet")
        Dim creditDocTestQuery : creditDocTestQuery = "SELECT TOP 1 1 FROM viewCreditDocuments WHERE customerId=" & dbFormatId(selectedCustomerId)
        creditDocTestRS.Open creditDocTestQuery, db
        IF NOT creditDocTestRS.EOF THEN creditDocCount = 1
        creditDocTestRS.Close
        Set creditDocTestRS = Nothing

        IF (Session("credit.allowEdit") OR Session("credit.isAdmin")) AND allowCustomerBranchAccess AND creditDocCount > 0 THEN
            Response.Write "<tr class=""activate-groups"">" & vbCr _
                         & "    <td colspan=""" & CREDIT_DOC_SPAN & """><a href=""javascript:void(0);"" onclick=""openKendoDialog('Active Credit Groups', 'custactivategroups.asp?group=credit&customerId=" & selectedCustomerId & "&accountClassCode=credit', 500, 700);"">Activate Groups</a></td>" & vbCr _
                         & "</tr>"
        END IF
        %>
        <tr>
            <td colspan="<%=CREDIT_DOC_SPAN%>">&nbsp; &nbsp;<b><i>No active/defined documents.</i></b><br><br></td>
        </tr>
        <%
    END IF
    %>
</table>
<%
creditDocEnd = Timer()
creditDocDelta = creditDocEnd-creditDocStart
%>