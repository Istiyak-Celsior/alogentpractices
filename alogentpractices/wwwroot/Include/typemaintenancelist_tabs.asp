<%
Dim groupRS : Set groupRS = Server.CreateObject("ADODB.RecordSet")
Dim groupQuery : groupQuery = "SELECT * FROM documentType WHERE documentTypeId=" & dbFormatId(activeTypeId)
groupRS.Open groupQuery, db, adOpenStatic, adCmdText

IF Not groupRS.EOF THEN
documentTypeName = groupRS("documentTypeName")
%>
<div id="tabs-title" class="clearfix">
    <h2>Tab: <%=documentTypeName%></h2>
    <span><a href="docsubtypemaint.asp?action=ADD&documentTypeId=<%=activeTypeId%>&activeGroupTab=<%=activeGroupTab%>" class="k-button k-primary small"><i class="fas fa-plus-circle" aria-hidden="true"></i>&nbsp; Add Tab</a></span>
</div>
<div class="tab-header">
    <ul>
        <li>Action</li>
        <li>Tab Name</li>
        <li>Default Status</li>
        <li>Visibility</li>
        <li>Require Exp Date?</li>
        <li>Hide Emp File?</li>
        <li>Allow AccuCapture</li>
        <li>Scan Rule</li>
        <% IF CanAccessPurge() THEN %>
        <li>Purge</li>
        <% END IF %>
        <% IF Session("acculoan.showParticipationLoan") = 1 THEN %>
        <li>Block Participation</li>
        <% END IF %>
        <% IF Session("acculoan.enablePDFModule") = 1 THEN %>
        <li>Enable Bookmarks</li>
        <% END IF %>
    </ul>
</div>
<div id="sortable-handlers-tabs">
    <%
    Dim tabRS : Set tabRS = Server.CreateObject("ADODB.RecordSet")
    Dim accountClassConstraint : accountClassConstraint = ""
    IF accountClassId <> "" THEN accountClassConstraint = "   AND tabsec.accountClassId=" & dbFormatId(accountClassId)

    Dim tabQuery : tabQuery = _
        " SELECT" & _
        "   dt.documentTypeId," & _
        "   dt.documentTypeName," & _
        "   dt.typeCode," & _
        "   dst.documentTypeId," & _
        "   dst.documentSubTypeId," & _
        "   dst.documentSubTypeName," & _
        "   dst.subTypeSortOrder," & _
        "   dst.subTypeFolderName," & _
        "   dst.subTypeDefaultStatus," & _
        "   dst.subTypeHideEmployeeFileYN," &_
        "   dst.documentCode," & _
        "   dst.subTypeRequireExpDateYN," & _
        "   dst.subTypeScanFlag," & _
        "   dst.allowAccuCapture," & _
        "   (SELECT COUNT(*) FROM documentDefinitions WHERE documentSubTypeId=dst.documentSubTypeId) AS subTypeUsed," & _
        "   dst.blockParticipation," & _
        "   dst.BlockPurge," & _
        "   dst.BookmarkPDF" & _
        " FROM" & _
        "   documentSubType AS dst INNER JOIN documentType AS dt" & _
        "       ON dt.documentTypeId=dst.documentTypeId" & _
        " WHERE" & _
        "   dst.documentTypeId = " & dbFormatId(activeTypeId) & _
        " ORDER BY dst.subTypeSortOrder, dst.documentSubTypeName"
    tabRS.Open tabQuery, db, adOpenStatic, adCmdText
    DO UNTIL tabRS.EOF
        typeCode = tabRS("typeCode")
        IF typeCode = "C" THEN
            workingTabSecurity = creditTabSecurity
            workingTabSecurityRows = creditTabSecurityRows
        ELSE
            workingTabSecurity = accountTabSecurity
            workingTabSecurityRows = accountTabSecurityRows
        END IF

        IF tabRS("subTypeDefaultStatus") = 3 THEN
            defaultStatusMsg = "Waived"
        ELSEIF tabRS("subTypeDefaultStatus") = 2 THEN
            defaultStatusMsg = "N/A"
        ELSE
            defaultStatusMsg = "Required"
        END IF

        srcScanFlag = "<span class=""scan-container"" title=""Scan into New Document"">SCAN NEW</span>"
        IF tabRS("subTypeScanFlag") = "1" THEN
            srcScanFlag = "<span class=""scan-container"" title=""Insert Pages into Newest Document"">INSERT NEW</span>"
        ELSEIF tabRS("subTypeScanFlag") = "2" THEN
            srcScanFlag = "<span class=""scan-container"" title=""Insert Pages into Oldest Document"">INSERT OLD</span>"
        ELSEIF tabRS("subTypeScanFlag") = "3" THEN
            srcScanFlag = "<span class=""scan-container"" title=""Append Pages into Newest Document"">APPEND NEW</span>"
        ELSEIF tabRS("subTypeScanFlag") = "4" THEN
            srcScanFlag = "<span class=""scan-container"" title=""Append Pages into Oldest Document"">APPEND OLD</span>"
        END IF

        IF tabRS("BlockPurge") THEN
            blockPurgeIcon = "<i class=""fas fa-minus-circle m6"" title=""Purge Changes Blocked"" aria-hidden=""true""></i>"
        ELSE
            blockPurgeIcon = "<i class=""fas fa-check-circle m6"" title=""Purge Changes Allowed"" aria-hidden=""true""></i>"
        END IF
        %>
        <div class="tab" id="<%=tabRS("documentSubTypeId")%>">
            <ul>
                <li><img src="Content/Images/Icons/dragger.gif" class="handler-tab" alt=""/></li>
                <li><% IF cInt(tabRS("subTypeUsed")) = 0 THEN %>
                <a href="javascript:void(0);" onclick="openKendoWindow('Delete Tab', 'typemaintconfirmdelete.asp?documentTypeId=<%=tabRS("documentTypeId")%>&documentSubTypeId=<%=tabRS("documentSubTypeId")%>&greybox=1', 500, 700);"><i class="aa-icon fas fa-times fa-fw" title="Delete Tab" aria-hidden="true"></i></a>
                <% ELSE %>
                <i class="aa-icon fas fa-times fa-fw disabled" title="Delete Tab" aria-hidden="true"></i>
                <% END IF %></li>
                <li><a href="javascript:void(0);" onclick="openKendoWindow('Move Tab', 'typemaintcopymove.asp?action=MOVE&documentTypeId=<%=tabRS("documentTypeId")%>&documentSubTypeId=<%=tabRS("documentSubTypeId")%>&typeCode=<%=tabRS("typeCode")%>&activeGroupTab=<%=activeGroupTab%>', 500, 700);"><i class="aa-icon fas fa-arrow-right fa-fw" title="Move Tab to New Group" aria-hidden="true"></i></a></li>
                <li><a href="docsubtypemaint.asp?action=EDIT&documentTypeId=<%=tabRS("documentTypeId")%>&documentSubTypeId=<%=tabRS("documentSubTypeId")%>&activeGroupTab=<%= activeGroupTab %>"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Tab" aria-hidden="true"></i></a></li>
                <li><%=Server.HTMLEncode(tabRS("documentSubTypeName"))%></li>
                <li><%=defaultStatusMsg%></li>
                <li><%
                FOR i = 0 TO workingTabSecurityRows - 1
                    workingSubTypeId = workingTabSecurity(tabSecurityFields("documentSubTypeId"),i)
                    workingAccountCode = workingTabSecurity(tabSecurityFields("accountClassCode"),i)
                    workingAllowAccess = workingTabSecurity(tabSecurityFields("allowAccess"),i)
                    IF cStr(tabRS("documentSubTypeId")) = cStr(workingSubTypeId) AND workingAccountCode = "loan" AND workingAllowAccess THEN
                        Response.Write "<span class=""account-letter"" title=""Loan Access"">L</span>"
                        EXIT FOR
                    END IF
                NEXT
                %></li>
                <li><%
                FOR i = 0 TO workingTabSecurityRows - 1
                    workingSubTypeId = workingTabSecurity(tabSecurityFields("documentSubTypeId"),i)
                    workingAccountCode = workingTabSecurity(tabSecurityFields("accountClassCode"),i)
                    workingAllowAccess = workingTabSecurity(tabSecurityFields("allowAccess"),i)
                    IF cStr(tabRS("documentSubTypeId")) = cStr(workingSubTypeId) AND workingAccountCode = "deposit" AND workingAllowAccess THEN
                        Response.Write "<span class=""account-letter"" title=""Deposit Access"">D</span>"
                        EXIT FOR
                    END IF
                NEXT
                %></li>
                <li><%
                FOR i = 0 TO workingTabSecurityRows - 1
                    workingSubTypeId = workingTabSecurity(tabSecurityFields("documentSubTypeId"),i)
                    workingAccountCode = workingTabSecurity(tabSecurityFields("accountClassCode"),i)
                    workingAllowAccess = workingTabSecurity(tabSecurityFields("allowAccess"),i)
                    IF cStr(tabRS("documentSubTypeId")) = cStr(workingSubTypeId) AND workingAccountCode = "trust" AND workingAllowAccess THEN
                        Response.Write "<span class=""account-letter"" title=""Trust Access"">T</span>"
                        EXIT FOR
                    END IF
                NEXT
                %></li>
                <%
                IF tabRS("subTypeRequireExpdateYN") = "Y" THEN
                    statusIconColor = "#27AE60"
                ELSE
                    statusIconColor = "#C0392B"
                END IF
                %>
                <li><%=StatusIconFlat(statusIconColor, "")%></li>
                <%
                IF tabRS("subTypeHideEmployeeFileYN") = "Y" THEN
                    statusIconColor = "#27AE60"
                ELSE
                    statusIconColor = "#C0392B"
                END IF
                %>
                <li><%=StatusIconFlat(statusIconColor, "")%></li>
                <%
                IF tabRS("allowAccuCapture") THEN
                    statusIconColor = "#27AE60"
                ELSE
                    statusIconColor = "#C0392B"
                END IF
                %>
                <li><%=StatusIconFlat(statusIconColor, "")%></li>
                <li><%=srcScanFlag%></li>
                <% IF CanAccessPurge() THEN %>
                <li><%=blockPurgeIcon%></li>
                <% END IF %>
                <% IF Session("acculoan.showParticipationLoan") = 1 THEN %>
                <%
                Dim participationTip
                IF tabRS("blockParticipation") THEN
                    statusIconColor = "#27AE60"
                    statusIconTitle = "Documents do not Participate"
                ELSE
                    statusIconColor = "#C0392B"
                    statusIconTitle = "Documents Participate"
                END IF
                %>
                <li><%=StatusIconFlat(statusIconColor, statusIconTitle)%></li>
                <%
                END IF

                IF Session("acculoan.enablePDFModule") = 1 THEN
                    IF tabRS("BookmarkPDF") THEN
                        statusIconColor = "#27AE60"
                        statusIconTitle = "Bookmarking Enabled"
                    ELSE
                        statusIconColor = "#C0392B"
                        statusIconTitle = "Bookmarking Disabled"
                    END IF
                    %>
                    <li><%=StatusIconFlat(statusIconColor, statusIconTitle)%></li>
                    <%
                END IF
                %>
            </ul>
            <%
            tabRS.MoveNext
            %>
        </div>
        <%
    LOOP
    tabRS.Close
    %>
    <div class="spacer">&nbsp;</div>
</div>
<%
END IF ' Not GroupRS.EOF
groupRS.Close
%>