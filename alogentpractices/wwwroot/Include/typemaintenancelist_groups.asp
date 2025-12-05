<%
Dim docTypeQuery, typeCode
Dim docTypeRS : Set docTypeRS = Server.CreateObject("ADODB.RecordSet")

IF activeGroupTab = "credit" THEN
    typeCode = "C"
    docTypeQuery = _
        " SELECT" & _
        "   dt.*," & _
        "   ((SELECT COUNT(*) FROM documentDefinitions WHERE documentTypeId=dt.documentTypeId)" & _
        "   +" & _
        "   (SELECT COUNT(*) FROM documentSubType WHERE documentTypeId=dt.documentTypeId)) AS typeUsed," & _
        "   (SELECT COUNT(*) FROM documentSubType WHERE documentTypeId=dt.documentTypeId) AS tabCount" & _
        BuildAccountVisibilityClause() & _
        " FROM" & _
        "   documentType AS dt" & _
        " WHERE" & _
        "   dt.typeCode LIKE " & dbFormatText(typeCode) & _
        " ORDER BY" & _
        "   dt.typeSortOrder," & _
        "   dt.documentTypeName" 
ELSE
    typeCode = "L"
    Dim whereClause : whereClause = BuildAccountVisibilityWhereClause(activeGroupTab)

    ' ### DEV NOTE: make {accountClassCode}visibilityCounts dynamic string build below and above ###
    docTypeQuery = _
        " SELECT" & _
        "   dt.*," & _
        "   v1.typeUsed," & _
        "   v1.tabCount" & _
        BuildAccountVisibilitySelectClause() & _
        " FROM" & _
        "   documentType AS dt INNER JOIN (" & _
        "       SELECT DISTINCT" & _
        "           dt.documentTypeId," & _
        "           (   (SELECT COUNT(*) FROM documentDefinitions WHERE documentTypeId=dt.documentTypeId)" & _
        "               +" & _
        "               (SELECT COUNT(*) FROM documentSubType WHERE documentTypeId=dt.documentTypeId)" & _
        "           ) AS typeUsed," & _
        "           (SELECT COUNT(*) FROM documentSubType WHERE documentTypeId=dt.documentTypeId) AS tabCount" & _
        BuildAccountVisibilityClause() & _
        "       FROM" & _
        "           documentType AS dt LEFT OUTER JOIN documentSubType AS dst" & _
        "               ON dt.documentTypeId=dst.documentTypeId" & _
        "       WHERE" & _
        "           dt.typeCode = " & dbFormatText(typeCode) & _
        "   ) AS v1" & _
        "       ON v1.documentTypeId = dt.documentTypeId" & _
        whereClause & _
        " ORDER BY" & _
        "   dt.typeSortOrder," & _
        "   dt.documentTypeName"
END IF

Dim visibilitySpan
IF typeCode = "C" THEN
    visibilitySpan = 2 * uBound(g_AccountClassList)
ELSE
    visibilitySpan = 2
END IF
%>
<div class="group-header">
    <ul>
        <li>Action</li>
        <li>Group Name</li>
        <li>Tabs in Group</li>
    </ul>
</div>
<div id="sortable-handlers-groups">
    <%
    Dim grpCount : grpCount = 0
    docTypeRS.Open docTypeQuery, db, adOpenStatic, adCmdText
    DO UNTIL docTypeRS.EOF
        Dim typeUsed : typeUsed = docTypeRS("typeUsed")
        Dim tabCount : tabCount = docTypeRS("tabCount")
        Dim typeSortOrder : typeSortOrder = docTypeRS("typeSortOrder")
        Dim style : style = "inactive"
        IF activeTypeId = "" THEN activeTypeId = docTypeRS("documentTypeId")
        IF activeTypeId = docTypeRS("documentTypeId") THEN style = "active"
        %>
        <div class="group" id="<%=docTypeRS("documentTypeId")%>">
            <ul class="<%=style%>">
                <li><img src="Content/Images/Icons/dragger.gif" class="handler" alt=""/></li>
                <li><% IF cInt(docTypeRS("typeUsed")) = 0 THEN %>
                <a href="javascript:void(0);" onclick="openKendoWindow('Delete Group', 'typemaintconfirmdelete.asp?documentTypeId=<%=docTypeRS("documentTypeId")%>', 500, 700);"><i class="aa-icon fas fa-times fa-fw" title="Delete Group" aria-hidden="true"></i></a>
                <% ELSE %>
                <i class="aa-icon fas fa-times fa-fw disabled" title="Delete Group" aria-hidden="true"></i>
                <% END IF %></li>
                <li><a href="doctypemaint.asp?action=EDIT&documentTypeId=<%=docTypeRS("documentTypeId")%>&activeGroupTab=<%=activeGroupTab%>"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Group" aria-hidden="true"></i></a></li>
                <li><% IF docTypeRS("typeActivationStatus") = "off" THEN %>
                <%=StatusIconFlat("#C0392B", "Inactive")%>
                <% ELSE %>
                <%=StatusIconFlat("#27AE60", "Active")%>
                <% END IF %></li>
                <li><% IF style = "active" THEN %>
                <span style="font-weight: bold;"><%=docTypeRS("documentTypeName")%></span>
                <% ELSE %>
                <a href="typemaintenancelist.asp?activeTypeId=<%=docTypeRS("documentTypeId")%>&activeGroupTab=<%=activeGroupTab%>"><%=docTypeRS("documentTypeName")%></a>
                <% END IF %></li>
                <% Call BuildTabVisibilityDetails(typeCode, activeGroupTab) %>
            </ul>
        </div>
        <%
        grpCount = grpCount + 1
        docTypeRS.MoveNext
    LOOP
    docTypeRS.Close
    %>
    <% 
        IF grpCount = 0 THEN
            Dim typeGroupName : typeGroupName = "Credit"
            IF typeCode = "L" THEN
                typeGroupName = "Account"
            END IF
    %>
        <br /><br />
        <i>No <%=typeGroupName%> Document Groups created yet.</i>
    <% END IF %>
    <div class="spacer">&nbsp;</div>
</div>
<%
FUNCTION BuildAccountVisibilityClause()
    Dim selectClause : selectClause = ""
    Dim i

    FOR i = lBound(g_AccountClassList,2) To uBound(g_AccountClassList,2)
        selectClause = selectClause & _
            " , (" &_
            "       SELECT COUNT(*) " &_
            "       FROM documentTabAccountSecurity " &_
            "       WHERE " &_
            "           accountClassId IN (SELECT accountClassId FROM accountClass WHERE accountClassCode = " & dbFormatText(g_AccountClassList( ACCOUNT_CLASS_CODE,i)) & ") " &_
            "           AND documentSubTypeId IN (SELECT documentSubTypeId FROM documentSubType WHERE documentTypeId=dt.documentTypeId)" &_
            "   ) AS " & g_AccountClassList( ACCOUNT_CLASS_CODE,i) & "VisibilityCount"       
    NEXT
    BuildAccountVisibilityClause = selectClause
END FUNCTION

SUB BuildTabVisibilityDetails(typeCode, activeGroupTab)
    Dim i, count, imgsrc
    Dim accountClassCode, accountClassName

    FOR i =  lBound(g_AccountClassList,2) To uBound(g_AccountClassList,2)
        accountClassCode = g_AccountClassList(ACCOUNT_CLASS_CODE,i)
        accountClassName = g_AccountClassList(ACCOUNT_CLASS_NAME,i)

        IF typeCode = "C" OR ( accountClassCode = activeGroupTab) THEN
            count = docTypeRS( accountClassCode & "VisibilityCount")
            IF count = 0 THEN
                imgsrc = "--"
                count = ""
            ELSE
                Dim accountLetter : accountLetter = ""
                accountLetter = uCase(Left(accountClassCode, 1))
                imgsrc = "<span class=""account-letter-group"" title=""Visible " & accountClassName & " Tabs"">" & accountLetter & "</span>"
            END IF
            Response.Write "<li>" & count & "&nbsp;" & imgsrc & "</li>" & vbCr
        END IF
    NEXT
END SUB

' ### Builds the aliased view columns based on the accountClasses available. ###
FUNCTION BuildAccountVisibilitySelectClause()
    Dim str : str = ""
    Dim i

    FOR i = lBound(g_AccountClassList,2) To uBound(g_AccountClassList,2)
        str = str & ", " & g_AccountClassList(ACCOUNT_CLASS_CODE,i) & "VisibilityCount"
    NEXT
    BuildAccountVisibilitySelectClause = str
END FUNCTION

' ### Builds the WHERE clause based on whether the Active tab has tabs associated with it
' or tabs with no association (e.g. not associated with any accountClass yet). ###
FUNCTION BuildAccountVisibilityWhereClause(activeCode)
    Dim activeCountClause : activeCountClause = ""
    Dim noCountClause : noCountClause = ""
    Dim i

    FOR i = lBound(g_AccountClassList,2) TO uBound(g_AccountClassList,2)
        IF noCountClause = "" THEN
            noCountClause = noCountClause & g_AccountClassList(ACCOUNT_CLASS_CODE,i) & "VisibilityCount = 0"
        ELSE
            noCountClause = noCountClause & " AND " & g_AccountClassList(ACCOUNT_CLASS_CODE,i) & "VisibilityCount = 0"
        END IF

        IF g_AccountClassList(ACCOUNT_CLASS_CODE,i) = activeCode THEN
            activeCountClause = " WHERE " & g_AccountClassList(ACCOUNT_CLASS_CODE,i) & "VisibilityCount > 0" 
        END IF
    NEXT

    IF noCountClause <> "" THEN
        activeCountClause = activeCountClause & " OR (" & noCountClause & ")"
    END IF

    BuildAccountVisibilityWhereClause = activeCountClause
END FUNCTION
%>