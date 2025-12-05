<% accountDocStart = Timer() %>
<table class="aa-section-wrapper">
    <%
    Dim LOAN_DOC_SPAN : LOAN_DOC_SPAN = 12
    IF Session("acculoan.enablePurge") = 0 THEN LOAN_DOC_SPAN = LOAN_DOC_SPAN - 1
    IF Session("accuaccount.disableImaging") = "1" THEN LOAN_DOC_SPAN = LOAN_DOC_SPAN - 1

    Dim loanTabQuery, loanDocumentArray
    Dim loanTabRS : Set loanTabRS = Server.CreateObject("ADODB.RecordSet")
    singleTab = false
    
    ' ### Build query to get DocumentTabs and their document information ###
    loanTabQuery = _
        " SELECT" & _
        "   l.loanBranchId," & _
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
        "   IsNull(d.[PurgeStatus], 0) AS PurgeStatus," & _
        "   IsNull(d.[PurgeStatusLocked], 0) AS PurgeStatusLocked," & _
        "   CASE WHEN IsNull(d.documentStatus,2)=1 AND (dst.[BlockPurge]=1 OR dd.[BlockPurge]=1) THEN CONVERT(bit,1) ELSE CONVERT(bit,0) END AS BlockPurge," & _
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
        "   l.isParticipationLoan," & _
        "   dsto.hasDemographicData" & _
        " FROM" & _
        "   customer AS c INNER JOIN loan AS l" & _
        "       ON c.customerId=l.customerId" & _
        "   INNER JOIN documentDefinitions AS dd" & _
        "       ON l.loanTypeId=dd.loanTypeId" & _
        "       AND l.loanId=" & dbFormatId(targetLoanId) & _
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
        " WHERE " & _
        "   dd.hideTabYN <> 'Y'" & _
        "   AND (" & _
        "       (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 AND LOWER(IsNull(da.activationStatus,dd.defaultActivationStatus)) = 'on')" & _
        "        OR IsNull(d.documentStatus,2) = 1" & _
        "   ) " & _
        " ORDER BY" & _
        "   dd.sortOrder," & _
        "   dt.documentTypeName," & _
        "   dst.documentSubTypeName," & _
        "   d.origdate DESC"
    loanTabRS.Open loanTabQuery, db, adOpenForwardOnly, adLockReadOnly
    IF NOT loanTabRS.EOF THEN
        loanDocumentArray = loanTabRS.GetRows(adGetRowsRest, , loanFieldsArray)
        loanDocumentCount = UBound(loanDocumentArray,2)
        tabDisplayEmpty = false
    ELSE
        loanDocumentCount = -1
        tabDisplayEmpty = true
    END IF
    loanTabRS.Close()

    ' ### DEFINE ACCOUNT EDITOR PERMISSION ###
    cust_isAccountEditor = false

    IF (Session(extendedAccountClassCode & ".allowDocEdit") _
        OR Session(extendedAccountClassCode & ".allowDocAdd") _
        OR Session(extendedAccountClassCode & ".allowDocScan") _
        OR Session(extendedAccountClassCode & ".allowDocUpload") _
        OR Session(extendedAccountClassCode & ".allowDocScanDelete") _
        OR Session(extendedAccountClassCode & ".allowDocMoveCopy")) THEN
            cust_isAccountEditor = true
    ELSE
        LOAN_DOC_SPAN = LOAN_DOC_SPAN - 2
    END IF

    ' ### Loop through loan documentTabs for given customer ###
    documentTypeName = ""
    numRows = loanDocumentCount + 1 
    rowCount = 0
    WHILE rowCount < numRows
        nextRow = rowCount + 1
        documentTabId = loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount)
        Dim isParticipationLoan : isParticipationLoan = loanDocumentArray(loanFieldsDict.Item("isParticipationLoan"), rowCount)
        
        ' ### Only display the Group (documentType) once ###
        IF documentTypeName <> loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount) THEN
            displayTab = true
            documentTypeName = loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount)
            %>
            <tr class="aa-header-row" id="tabHeader<%=GetNextGroupCount()%>">
                <td colspan="<%=LOAN_DOC_SPAN%>">
                    <input type="hidden" id="uxTabHeader<%=groupCount-1%>Children" name="tabHeader<%=groupCount-1%>Children" value="<%=groupChildren%>"/>
                    <% groupChildren = "" %>
                    <ul class="aa-row-icons groups">
                        <li><span id="tabHeader<%=groupCount%>Expander" onclick="CollapsibleGroupsToggle('<%=groupCount%>')" class="aa-collapse-expand-icon"><i class="aa-icon fas fa-<% IF Session("enableCollapsibleGroups") THEN %>plus<% ELSE %>minus<% END IF %>-square fa-fw" id="tab-header-expander-icon-<%=groupCount%>" aria-hidden="true"></i></span></li>
                        <li><a href="javascript:void(0);"  onclick="openKendoDialog('Activate Loan Tabs', 'custactivatetabs.asp?group=loan&customerId=<%=selectedCustomerId%>&loanId=<%=targetLoanId%>&documentTypeId=<%=loanDocumentArray(loanFieldsDict.Item("documentTypeId"), rowCount)%>&accountClassCode=<%=extendedAccountClassCode%>', 500, 700);"><%=loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount)%></a></li>
                    </ul>
                </td>
            </tr>
            <%
        END IF ' ### IF documentTypeName <> loanDocumentArray(loanFieldsDict.Item("documentTypeName"), rowCount)

        ' ### Prepare the document instruction for tool tip hover ###
        documentInstruction = loanDocumentArray(loanFieldsDict.Item("subTypeInstruction"), rowCount)

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
            IF documentTabId = loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount + 1) THEN
                singleTab = false
            END IF
        END IF

        IF loanDocumentArray(loanFieldsDict.Item("documentStatus"), rowCount) = 1 THEN
            iconFilename = "fa-circle aa-status-yes fa-fw"
            altDocumentStatus = "Exists"
            altTitleStatus = "Document Exists"
        ELSEIF loanDocumentArray(loanFieldsDict.Item("documentStatus"), rowCount) = 3 THEN
            iconFilename = "fa-circle aa-status-pending fa-fw"
            altDocumentStatus = "Changed"
            altTitleStatus = "Document has Changed"
        ELSE
            iconFilename = "fa-circle aa-status-no fa-fw"
            altDocumentStatus = "Doesn't Exist"
            altTitleStatus = "No Document Exists"
        END IF

        ' ### Process documentTitle if the name is the same as the Tab ###
        documentTitleColor = loanDocumentArray(loanFieldsDict.Item("documentHighlightColor"), rowCount)
        documentTitle = loanDocumentArray(loanFieldsDict.Item("documentTitle"), rowCount)

        IF Trim(documentTitle) = Trim(loanDocumentArray(loanFieldsDict.Item("documentSubTypeName"), rowCount)) AND displayTab THEN
            documentTitle = ""
        END IF

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


        docTabAllowSchedule = loanDocumentArray(loanFieldsDict.Item("docTabAllowSchedule"), rowCount)

        tabMaintUrl = ""
        showDocSchedule = False
        imgDocSchedule = ""
        altDocSchedule = ""

        documentTabId = loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount)
        documentDefId = loanDocumentArray(loanFieldsDict.Item("documentDefId"), rowCount)

        IF IsNull(documentTabId) THEN
            tabmaintUrl = "documenttabmaint.asp?loanId=" & selectedLoanId & "&documentDefId=" & documentDefId
        ELSE
            tabMaintUrl = "documenttabmaint.asp?documentTabId=" & documentTabId
        END IF

        IF docTabAllowSchedule THEN
            showDocSchedule = True
            imgDocSchedule = "fa-calendar-check"
            altDocSchedule = "Manage Document Schedule"
        END IF

        docTabProcessingDateEnd = CheckForNull(loanDocumentArray(loanFieldsDict.Item("docTabProcessingDateEnd"), rowCount))
        IF IsDate(docTabProcessingDateEnd) THEN
            IF Now() >= cDate(docTabProcessingDateEnd) + 1 THEN
                showDocSchedule = True
                imgDocSchedule = "fa-calendar-times"
                altDocSchedule = "Schedule stopped on " & FormatDateTime(docTabProcessingDateEnd,2)
            END IF
        END IF

        ' ### Add logic here to get tab security access for document viewing ###
        documentSubTypeId = loanDocumentArray(loanFieldsDict.Item("documentSubTypeId"), rowCount)
        allowDocumentAccess = AllowAccountTabAccess(documentSubtypeId)

        '### Determine access to employee hidden file ###
        docHideEmployeeFileYN = loanDocumentArray(loanFieldsDict.Item("hideEmployeeFileYN"), rowCount)
        empAccessAllowed = True

        IF NOT employeeViewer AND cBool(CustomerRS("employee")) AND docHideEmployeeFileYN = "Y" THEN
            empAccessAllowed = False
        END IF

        Dim hasLoanAdminAccess : hasLoanAdminAccess = False
        IF Session(extendedAccountClassCode & ".isAdmin") AND employeeViewer AND docHideEmployeefileYN = "Y" THEN
            hasLoanAdminAccess = True
        END IF

        IF empAccessAllowed THEN
            urlEmpAccessAllowed = ""
        ELSE
            urlEmpAccessAllowed = "&empAccessAllowed=N"
        END IF

        IF loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount) <> "" THEN
            documentActionUrl = _
                "documentaction.asp?" & _
                "documentTabId=" & loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount) & _
                "&loanId=" & selectedLoanId & _
                "&customerId=" & customerId & _
                "&extendedAccountClassCode=" & extendedAccountClassCode & urlEmpAccessAllowed
        ELSE
            documentActionUrl = _
                "documentaction.asp?" & _
                "loanId=" & selectedLoanId & _
                "&customerId=" & customerId & _
                "&documentDefId=" & loanDocumentArray(loanFieldsDict.Item("documentDefId"), rowCount) & _
                "&extendedAccountClassCode=" & extendedAccountClassCode & urlEmpAccessAllowed
        END IF

        ' ### DRAG AND DROP ROW BASED ON PERMISSIONS ###
        Dim accountDocStatus : accountDocStatus = loanDocumentArray(loanFieldsDict.Item("documentStatus"), rowCount)

        IF Session("accuaccount.disableImaging") = "0" THEN ' ### ENSURE IMAGING IS ENABLED
            IF Session("isSuperUser") OR (Session(extendedAccountClassCode & ".allowDocUpload") AND allowLoanBranchAccess AND empAccessAllowed) THEN
                IF Trim(accountDocStatus & "") = "1" THEN
                    %><tr <%=display%><% IF displayTab THEN %> class="aa-row doc-drop" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row doc-drop tabGroup<%=tabCount%>Child"<% END IF %> ondragover="allowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropCopyData('<%=targetLoanId%>', '<%=loanDocumentArray(loanFieldsDict.Item("documentDefId"), rowCount)%>', '', '<%=loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount)%>', event);"><%
                ELSE
                    %><tr <%=display%><% IF displayTab THEN %> class="aa-row doc-drop" id="tabGroup<%=GetNextTabCount()%>Parent"<% ELSE %> class="aa-row doc-drop tabGroup<%=tabCount%>Child"<% END IF %> ondragover="allowDrop(event);" ondragleave="clearDropZone(event);" ondrop="dragDropCopyData('<%=targetLoanId%>', '<%=loanDocumentArray(loanFieldsDict.Item("documentDefId"), rowCount)%>', '<%=loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)%>', '<%=loanDocumentArray(loanFieldsDict.Item("documentTabId"), rowCount)%>', event);"><%
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
                        OR Session(extendedAccountClassCode & ".allowDocUpload") _
                        OR Session(extendedAccountClassCode & ".allowDocScanDelete") _
                        OR Session(extendedAccountClassCode & ".allowDocMoveCopy") ) _
                        AND allowLoanBranchAccess THEN
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
            ' ### THE FOLLOWING HAS SOME VERY SUBTLE LOGIC FOR DETERMINING THE VIEW DOCUMENT ICON. PLEASE BE CAREFUL WHEN MAKING CHANGES TO THESE CONDITIONS. ###

            escFileName = loanDocumentArray(loanFieldsDict.Item("fileName"), rowCount)
            documentTypeIcon = GetDocumentTypeIcon(escFileName)

            loanBranchId              = loanDocumentArray(loanFieldsDict.Item("loanBranchId"), rowCount)
            customerIsEmployee        = CustomerRS("employee")
            documentTabIsEmployeeFile = loanDocumentArray(loanFieldsDict.Item("hideEmployeeFileYN"), rowCount) = "Y"
            documentFilename          = loanDocumentArray(loanFieldsDict.Item("filename"), rowCount)
            documentStatus            = loanDocumentArray(loanFieldsDict.Item("documentStatus"), rowCount)
            serverUrl                 = TrimTrailingSlash(Session("acculoan.serverURL"))
            documentId                = loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)
            customerFolder            = loanDocumentArray(loanFieldsDict.Item("customerFolder"), rowCount)
            loanFolder                = loanDocumentArray(loanFieldsDict.Item("loanFolder"), rowCount)
            documentTabFolder         = loanDocumentArray(loanFieldsDict.Item("loanFile"), rowCount)

            ' ### Determine the document's view access
            '
            'allowBranchAccess      = hasCustomerBranchAccess(selectedCustomerId)
            isCustomerEmployeeFile = customerIsEmployee And documentTabIsEmployeeFile
            fileHasDemographicData = loanDocumentArray(loanFieldsDict.Item("hasDemographicData"), rowCount)
            Set viewDocumentAccess = usr.Security.HasDocumentViewAccess(extendedAccountClassCode, loanBranchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)

            IF Session("accuaccount.disableImaging") = "1" THEN
                ' ### DO NOTHING, HAS COLUMN IS HIDDEN IF DISABLED
            ELSEIF (documentStatus = "1" Or (documentStatus = "3" And documentFilename <> "")) THEN
                IF viewDocumentAccess.HasAccess THEN
                    Dim accountDocumentId : accountDocumentId = loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)
                    Dim accountFileRoute  : accountFileRoute  = GetDocumentFileViewUrl(accountDocumentId, Session("userId"))

                    viewDocumentUrl = "Start('" & accountFileRoute & "');"
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
            displayDocumentTitle = Trim(loanDocumentArray(loanFieldsDict.Item("documentTitle"), rowCount) & "")
            displayDocumentSubTypeName = Trim(loanDocumentArray(loanFieldsDict.Item("documentSubTypeName"), rowCount) & "")

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

            IF (accountDocStatus = "1" OR (accountDocStatus = "3" AND loanDocumentArray(loanFieldsDict.Item("filename"), rowCount) <> "")) THEN
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
            IF loanDocumentArray(loanFieldsDict.Item("requireExpDate"), rowCount) THEN
                today = Now()
                expDate = loanDocumentArray(loanFieldsDict.Item("expDate"), rowCount)

                IF loanDocumentArray(loanFieldsDict.Item("nonExpiring"), rowCount) THEN
                    %><td class="column-expiration"><span class="expiring-date expirable" title="Document would normally expire, but was overridden not to.">Expirable</span></td><%
                ELSEIF NOT IsDate(expDate) THEN
                    %><td class="column-expiration">&nbsp;</td><%
                ELSEIF cDate(today) > cDate(expDate) THEN
                    ' ### EXPIRED ###
                    %><td class="column-expiration"><span class="expiring-date expired" title="Expired"><%=GetPaddedDateString(loanDocumentArray(loanFieldsDict.Item("expDate"), rowCount))%></span></td><%
                ELSE
                    ' ### EXPIRES ON CERTAIN DATE ###
                    %><td class="column-expiration"><span class="expiring-date expires" title="Expires on"><%=GetPaddedDateString(loanDocumentArray(loanFieldsDict.Item("expDate"), rowCount))%></span></td><%
               END IF
            ELSE
                %><td class="column-expiration">&nbsp;</td><%
            END IF
            %>

            <!-- Require QC Indicator -->
            <%
                QcApprovalIcon = "&nbsp;"
                RequireQc      = loanDocumentArray(loanFieldsDict.Item("RequireQc"), rowCount)
                QcStatus       = loanDocumentArray(loanFieldsDict.Item("QcStatus"), rowCount)

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
                %><td class="column-purge"><%=GetPurgeStatusIcon(loanDocumentArray(loanFieldsDict.Item("PurgeStatus"), rowCount), loanDocumentArray(loanFieldsDict.Item("PurgeStatusLocked"), rowCount), loanDocumentArray(loanFieldsDict.Item("BlockPurge"), rowCount))%></td><%
            END IF
            %>
            <!-- WAIVED DOCUMENT COLUMN -->
            <%
            ' ### WAIVED DOCUMENT LOGIC ###
            IF loanDocumentArray(loanFieldsDict.Item("documentStatusType"), rowCount) = "3" THEN
                %><td class="column-waived"><i class="aa-icon fas fa-exclamation-triangle aa-color-warning fa-fw" title="Waived" aria-hidden="true"></i></td><%
            ELSE
                %><td class="column-waived">&nbsp;</td><%
            END IF
            %>
            <!-- COMMENT ICON COLUMN -->
            <%
            IF Trim(loanDocumentArray(loanFieldsDict.Item("documentComment"), rowCount)) <> "" THEN
                Dim accountComment : accountComment = Trim(loanDocumentArray(loanFieldsDict.Item("documentComment"), rowCount))
                accountComment = InsertCarriageReturns(accountComment, 40)
                IF LEN(accountComment) > 70 THEN accountComment = Left(accountComment, 70) & "..."
                accountComment = Server.HTMLEncode(accountComment)
                %><td class="column-comment"><a href="javascript:void(0);" onclick="openKendoDialog('View Document Comment', 'viewcomment.asp?documentId=<%=loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)%>', 400, 500);" class="aa-command-link"><i class="aa-icon fas fa-comments fa-fw" title="<%=accountComment%>" aria-hidden="true"></i></a></td><%
            ELSE
                %><td class="column-comment">&nbsp;</td><%
            END IF
            %>
            <!-- DOCUMENT SCHEDULE COLUMN -->
            <%
            IF cust_isAccountEditor THEN
                IF displayTab THEN
                    DocType = uCase(Left(selectedAccountClassCode, 1)) & lCase(Right(selectedAccountClassCode, Len(selectedAccountClassCode) - 1))
                    IF showDocSchedule AND (Session("isSuperUser") OR (allowLoanBranchAccess AND (Session(extendedAccountClassCode & ".isAdmin") OR Session(extendedAccountClassCode & ".allowEdit")))) THEN
                        %><td class="column-doc-schedule"><a href="javascript:void(0);" onclick="openKendoDialog('Manage <%=DocType%> Document Schedule', '<%=tabMaintUrl%>', 500, 700);" class="aa-action-button"><i class="aa-icon fa <%=imgDocSchedule%> fa-fw" title="<%=altDocSchedule%>" aria-hidden="true"></i></a></td><%
                    ELSEIF showDocSchedule THEN
                        %><td class="column-doc-schedule"><i class="aa-icon far fa-calendar-check aa-disabled fa-fw" title="Schedules Enabled" aria-hidden="true"></i></td><%
                    ELSE
                        %><td class="column-doc-schedule">&nbsp;</td><%
                    END IF
                ELSE
                    %><td class="column-doc-schedule">&nbsp;</td><%
                END IF
            END IF ' ### IF cust_isAccountEditor
            %>
            <!-- EDIT DOCUMENT ICON COLUMN -->
            <%
            IF cust_isAccountEditor THEN
                ' ### CHECK FOR FILE EXISTANCE ###
                IF accountDocStatus = "-1" THEN
                    ' ### CHECK FOR FILE EXISTANCE ###
                    docUpdateQuery = "SELECT documentStatus FROM document WHERE documentId=" & dbFormatId(loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount))
                    Set docUpdateRS = Server.CreateObject("ADODB.RecordSet")
                    docUpdateRS.Open docUpdateQuery, db, adOpenKeySet, adLockPessimistic
                    f = Session("fullpath") & trim(primaryCustomerFolder) & trim(loanDocumentArray(loanFieldsDict.Item("LoanFile"), rowCount)) & "/" & trim(loanDocumentArray(loanFieldsDict.Item("FileName"), rowCount))
                    IF fso.FileExists(f) THEN
                        docUpdateRS("documentStatus") = 1
                        accountDocStatus = "1"
                    ELSE
                        docUpdateRS("documentStatus") = 2
                        accountDocStatus = "2"
                    END IF
                    docUpdateRS.Update
                    docUpdateRS.Close
                END IF

                docFilename = loanDocumentArray(loanFieldsDict.Item("filename"), rowCount)
                docHideEmployeeFileYN = loanDocumentArray(loanFieldsDict.Item("hideEmployeeFileYN"), rowCount)
                empAccessAllowed = True

                IF empAccessAllowed THEN
                    urlEmpAccessAllowed = ""
                ELSE
                    urlEmpAccessAllowed = "&empAccessAllowed=N&path=" & customerRS("customerFolder")
                END IF

                IF ( Session(extendedAccountClassCode & ".allowDocEdit") _
                    OR Session(extendedAccountClassCode & ".allowDocScan") _
                    OR Session(extendedAccountClassCode & ".allowDocScanDelete") _
                    OR Session(extendedAccountClassCode & ".allowDocUpload") _
                    OR Session(extendedAccountClassCode & ".allowDocMoveCopy")) _
                    AND allowLoanBranchAccess THEN

                    IF allowDocumentAccess THEN
                        IF loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount) <> "" THEN
                            IF empAccessAllowed THEN
                                documentMaintArgList = "action=EDIT" & "&documentId=" & loanDocumentArray(loanFieldsDict.Item("documentId"), rowCount)
                            ELSE
                                documentMaintArgList = "action=ADDSCAN" & "&loanId=" & selectedLoanId & "&documentDefId=" & loanDocumentArray(loanFieldsDict.Item("documentDefId"), rowCount)
                            END IF
                        ELSE
                            documentMaintArgList = "action=ADD&loanId=" & selectedLoanId & "&documentDefId=" & loanDocumentArray(loanFieldsDict.Item("documentDefId"), rowCount)
                        END IF
                        %><td class="column-doc-edit"><a href="javascript:void(0);" onclick="openKendoDialog('Edit Document', 'documentmaint.asp?<%=documentMaintArgList%>&extendedAccountClassCode=<%=extendedAccountClassCode%>&isParticipation=<%=isParticipationLoan%>', 470, 700);" class="aa-action-button"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></td><%
                    ELSE
                        %><td class="column-doc-edit"><span class="aa-action-button disabled"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Disabled" aria-hidden="true"></i></span></td><%
                    END IF
                ELSE
                    %><td class="column-doc-edit"><span class="aa-action-button disabled"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Disabled" aria-hidden="true"></i></span></td><%
                END IF
            END IF ' ### IF cust_isAccountEditor
            %>
        </tr>
        <%
        lastDocumentTabId = documentTabId
        rowCount = rowCount + 1
    WEND ' ### END WHILE loop through loanDocumentArray

    Set loanFieldsDict = Nothing
    Set loanFieldsArray = Nothing

    ' ### Display message if no active documents can be displayed ###
    IF tabDisplayEmpty THEN
        loanDocCount = 0
        Dim loanDocTestRS : Set loanDocTestRS = Server.CreateObject("ADODB.RecordSet")
        Dim loanDocTestQuery : loanDocTestQuery = _
            " SELECT " & _
            "   TOP 1 1 " & _
            " FROM" & _
            "   loan AS l " & _
            "   INNER JOIN documentDefinitions AS dd ON l.loanTypeId = dd.loanTypeId " & _
            "   INNER JOIN documentType AS dt ON dt.documentTypeId = dd.documentTypeId" & _
            "   INNER JOIN documentSubType AS dst ON dst.documentSubTypeId = dd.documentSubTypeId" & _
            "   LEFT OUTER JOIN documentTab AS dtab ON dtab.loanId = l.loanId AND dtab.documentDefId = dd.documentDefId" & _
            "   LEFT OUTER JOIN document AS d ON d.documentTabId = dtab.documentTabId" & _
            " WHERE " & _
            "   l.loanId = " & dbFormatId(targetLoanId) & _
            "   AND dd.hideTabYN <> 'Y' " & _
            "   AND (IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) <> 2 OR IsNull(d.documentStatus, 2) = 1) "
        loanDocTestRS.Open loanDocTestQuery, db, adOpenStatic, adCmdText
        IF NOT loanDocTestRS.EOF THEN loanDocCount = 1
        loanDocTestRS.Close
        Set loanDocTestRS = Nothing

        IF (Session(extenededAccountClassCode & ".isAdmin") _
            OR Session(extendedAccountClassCode & ".allowEdit") ) _
            AND allowLoanBranchAccess _
            AND loanDocCount > 0 THEN
            Response.Write "<tr class=""activate-groups"">" & vbCr _
                         & "    <td colspan=""" & LOAN_DOC_SPAN & """><a href=""javascript:void(0);"" onclick=""openKendoDialog('Activate Loan Groups', 'custactivategroups.asp?group=loan&customerId=" & customerId & "&loanId=" & targetLoanId & "&accountClassCode=" & selectedAccountClassCode & "', 500, 700);"">Activate Groups</a></td>" & vbCr _
                         & "</tr>" & vbCr
        END IF
        %>
        <tr>
            <td colspan="<%=LOAN_DOC_SPAN%>">&nbsp; &nbsp;<b><i>No active/defined documents.</i></b><br/><br/></td>
        </tr>
        <% END IF %>
    </table>
    <%
    accountDocEnd = Timer()
    accountDocDelta = accountDocEnd-accountDocStart
    %>