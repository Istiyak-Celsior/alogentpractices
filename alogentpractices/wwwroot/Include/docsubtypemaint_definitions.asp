<%
    Dim typeQuery, typeRS
    Set typeRS = Server.CreateObject("ADODB.RecordSet")
    
    If typeCode = "C" Then
        typeQuery = _
            " SELECT" & _
            "   'Customer Type' AS typeHeader," & _
            "   'C' AS typeCode," & _
            "   ct.customerTypeId AS typeId," & _
            "   ct.customerTypeDescription AS typeDescription," & _
            "   'credit' AS accountClassCode," & _
            "   'customer' AS exceptionDefType," & _
            "   dd.documentDefId," & _
            "   dd.requireExpDate," & _
            "   IsNull( dd.bankId, (SELECT TOP 1 bankId FROM bank)) AS bankId," & _ 
            "   missingEx.exceptionDefId AS missingExceptionDefId," & _
            "   missingEx.exceptionDefName AS missingExceptionDefName," & _
            "   expiredEx.exceptionDefId AS expiredExceptionDefId," & _
            "   expiredEx.exceptionDefName AS expiredExceptionDefName" & _
            " FROM" & _
            "   customerType AS ct CROSS JOIN documentSubType AS dst" & _
            "   LEFT OUTER JOIN documentDefinitions AS dd" & _
            "       ON dd.customerTypeId=ct.customerTypeId" & _
            "       AND dd.documentSubTypeId=dst.documentSubTypeId" & _
            "       AND dd.documentTypeId=dst.documentTypeId" & _
            "   LEFT OUTER JOIN (" & _
            "       SELECT" & _
            "           ed.exceptionDefId," & _
            "           ed.exceptionDefName," & _
            "           ed.customerTypeId," & _
            "           comp.docDefId," & _
            "           comp.statusTypeCheck" & _
            "       FROM" & _
            "           exceptionDefinition AS ed LEFT OUTER JOIN computation AS comp" & _
            "               ON ed.exceptionDefId=comp.exceptionDefId" & _
            "       WHERE" & _
            "           customerTypeId IS NOT NULL" & _
            "           AND customCustomerId IS NULL" & _
            "           AND ed.computationType LIKE 'computed'" & _
            "           AND IsNull(comp.statusTypeCheck, 'missing') LIKE 'missing'" & _
            "   ) AS missingEx" & _
            "       ON missingEx.customerTypeId=ct.customerTypeId" & _
            "       AND missingEx.docDefId=dd.documentDefId" & _
            "   LEFT OUTER JOIN (" & _
            "       SELECT" & _
            "           ed.exceptionDefId," & _
            "           ed.exceptionDefName," & _
            "           ed.customerTypeId," & _
            "           comp.docDefId," & _
            "           comp.statusTypeCheck" & _
            "       FROM" & _
            "           exceptionDefinition AS ed LEFT OUTER JOIN computation AS comp" & _
            "               ON ed.exceptionDefId=comp.exceptionDefId" & _
            "       WHERE" & _
            "           customerTypeId IS NOT NULL" & _
            "           AND customCustomerId IS NULL" & _
            "           AND ed.computationType LIKE 'computed'" & _
            "           AND IsNull(comp.statusTypeCheck, 'expired') LIKE 'expired'" & _
            "   ) AS expiredEx" & _
            "       ON expiredEx.customerTypeId=ct.customerTypeId" & _
            "       AND expiredEx.docDefId=dd.documentDefId" & _
            " WHERE" & _
            "   dst.documentSubTypeId=" & dbFormatId(documentSubTypeId) & _
            " ORDER BY" & _
            "   ct.customerTypeDescription"
    Else
		typeQuery = _
            " SELECT" & _
            "   (ac.accountClassName + ' Type') AS typeHeader," & _
            "   'L' AS typeCode," & _
            "   lt.loanTypeId AS typeId," & _
            "   lt.loanTypeDescription AS typeDescription," & _
            "   ac.accountClassCode," & _
            "   'loan' AS exceptionDefType," & _
            "   dd.documentDefId," & _
            "   dd.requireExpDate," & _
            "   IsNull( dd.bankId, (SELECT TOP 1 bankId FROM bank)) AS bankId," & _ 
            "   missingEx.exceptionDefId AS missingExceptionDefId," & _
            "   missingEx.exceptionDefName AS missingExceptionDefName," & _
            "   expiredEx.exceptionDefId AS expiredExceptionDefId," & _
            "   expiredEx.exceptionDefName AS expiredExceptionDefName" & _
            " FROM" & _
            "   loanType AS lt CROSS JOIN documentSubType AS dst" & _
			"	INNER JOIN accountClass AS ac" & _
			"		ON ac.accountClassId=lt.accountClassId" & _
            "   LEFT OUTER JOIN documentDefinitions AS dd" & _
            "       ON dd.loanTypeId=lt.loanTypeId" & _
            "       AND dd.documentSubTypeId=dst.documentSubTypeId" & _
            "       AND dd.documentTypeId=dst.documentTypeId" & _
            "   LEFT OUTER JOIN (" & _
            "       SELECT" & _
            "           ed.exceptionDefId," & _
            "           ed.exceptionDefName," & _
            "           ed.loanTypeId," & _
            "           comp.docDefId," & _
            "           comp.statusTypeCheck" & _
            "       FROM" & _
            "           exceptionDefinition AS ed LEFT OUTER JOIN computation AS comp" & _
            "               ON ed.exceptionDefId=comp.exceptionDefId" & _
            "       WHERE" & _
            "           loanTypeId IS NOT NULL" & _
            "           AND customLoanId IS NULL" & _
            "           AND ed.computationType LIKE 'computed'" & _
            "           AND IsNull(comp.statusTypeCheck, 'missing') LIKE 'missing'" & _
            "   ) AS missingEx" & _
            "       ON missingEx.loanTypeId=lt.loanTypeId" & _
            "       AND missingEx.docDefId=dd.documentDefId" & _
            "   LEFT OUTER JOIN (" & _
            "       SELECT" & _
            "           ed.exceptionDefId," & _
            "           ed.exceptionDefName," & _
            "           ed.loanTypeId," & _
            "           comp.docDefId," & _
            "           comp.statusTypeCheck" & _
            "       FROM" & _
            "           exceptionDefinition AS ed LEFT OUTER JOIN computation AS comp" & _
            "               ON ed.exceptionDefId=comp.exceptionDefId" & _
            "       WHERE" & _
            "           loanTypeId IS NOT NULL" & _
            "           AND customLoanId IS NULL" & _
            "           AND ed.computationType LIKE 'computed'" & _
            "           AND IsNull(comp.statusTypeCheck, 'expired') LIKE 'expired'" & _
            "   ) AS expiredEx" & _
            "       ON expiredEx.loanTypeId=lt.loanTypeId" & _
            "       AND expiredEx.docDefId=dd.documentDefId" & _
            " WHERE" & _
            "   dst.documentSubTypeId=" & dbFormatId(documentSubTypeId) & _
            "   AND ac.accountClassCode = " & dbFormatText(LCase(activeGroupTab)) & _
            " ORDER BY" & _
            "   lt.loanTypeDescription"
    End If
    
    typeRS.Open typeQuery, db, adOpenStatic, adCmdText

    If typeRS.EOF Then
%>
<div>
    <br /><br />
    <i>This document tab cannot add or edit exceptions because there are no <%=activeGroupTab%> types to associate the tab to.</i>
</div>
<%
    Else
        Dim typeHeader              : typeHeader = typeRS("typeHeader")
        Dim accountClassCode        : accountClassCode = typeRS("accountClassCode")
        Dim exceptionDefType        : exceptionDefType = typeRS("exceptionDefType")
%>
<div>
    <p>
        The following displays the Customer Types associated with the Document Tab and related Exceptions. Use the status icons
        to  manage the Customer Types and Exceptions associated with this Document Tab.        
    </p>
    
    <table>
        <tbody>
            <tr>
                <td style="text-align:center;"><a class="k-button k-edit aa-static-button">Edit</a></td>
                <td>
                    Tab or Exception exists for the given type. Clicking on the active icon will allow you to edit the appropriate Document Tab, Missing Exception or Expired Exception settings.
                </td>
            </tr>
            <tr>
                <td style="text-align:center;"><a class="k-button k-add aa-static-button">Add</a></td>
                <td>
                    Tab or exception does not exist for the given type. Clicking on the inactive icon will allow you to add the appropriate Document Tab, Missing Exception or Expired Exception so that it will be visible to users.
                </td>
            </tr>
            <tr>
                <td style="text-align:center;"><a class="k-button k-default aa-static-button">&nbsp;---&nbsp;&nbsp;</a></td>
                <td>
                    Exception does not exist for the given type. Exception creation and editing disabled until a document tab is created to associate to the exception.
                </td>
            </tr>
        </tbody>
    </table>
    <br />
    <table id="aa-definition-table" class="aa-kendo-grid">
        <thead>
            <tr>
                <th><%= typeHeader %></th>
                <th>Document Tab Add/Edit</th>
                <th>Missing Document Exception Name</th>
                <th>Add/Edit</th>
                <th>Expired Document Exception Name</th>
                <th>Add/Edit</th>
            </tr>
        </thead>
        <tbody>
<%
    Do Until typeRS.EOF
        Dim bankId                  : bankId = typeRS("bankId")
        Dim typeId                  : typeId = typeRS("typeId")
        Dim typeCode                : typeCode = typeRS("typeCode")
        Dim typeDescription         : typeDescription = typeRS("typeDescription")
        Dim documentDefId           : documentDefId = typeRS("documentDefId")
        Dim missingExceptionDefId   : missingExceptionDefId = typeRS("missingExceptionDefId")
        Dim missingExceptionDefName : missingExceptionDefName = typeRS("missingExceptionDefName")
        Dim expiredExceptionDefId   : expiredExceptionDefId = typeRS("expiredExceptionDefId")
        Dim expiredExceptionDefName : expiredExceptionDefName = typeRS("expiredExceptionDefName")
        Dim requireExpDate          : requireExpDate = typeRS("requireExpDate")
%>
            <tr>
                <td><a href="reqmaintenancelistedit.asp?documentType=<%=typeCode%>&typeId=<%=typeId%>&bankId=<%=bankId%>"><%= typeDescription %></a></td>
            
<%
    Dim associationAction, associationIcon, associationUrl

    associationAction = "Add"
    associationIcon = "k-add"
    associationUrl = "reqmaintedit.asp?mode=ADD&reqtype=" & typeCode & "&typeid=" & typeid & "&documentTypeId=" & documentTypeId & "&documentSubTypeId=" & documentSubTypeId & "&bankid=" & bankId & "&grouptabmaint=1&activeGroupTab=" & activeGroupTab   
    If Not IsNull(documentDefId) Then
        associationAction = "Edit"
        associationIcon = "k-edit"
        associationUrl = "reqmaintedit.asp?reqid=" & documentDefId & "&reqtype=" & typeCode & "&mode=EDIT&typeId=" & typeId & "&grouptabmaint=1&activeGroupTab=" & activeGroupTab
    End If
%>
                <td>
                    <a href="<%= associationUrl %>" class="k-button <%=associationIcon%>"><%= associationAction %></a>
                </td>

<%
    associationAction = "Add"
    greyboxTitle = "Add Missing Document Exception"
    associationIcon = "k-add"
    associationUrl = _
        "exceptiondefmaint1.asp" & _
        "?action=ADD&exceptionDefType=" & exceptionDefType & _
        "&targetType=" & typeCode & _
        "&targetTypeId=" & typeId & _
        "&documentDefId=" & documentDefId & _
        "&computationType=computed" & _
        "&statusTypeCheck=missing" & _
        "&activeTab=" & accountClassCode & _
        "&bankId=" & bankId & _
        "&grouptabmaint=1" & _
        "&activeGroupTab=" & activeGroupTab

    If IsNull(documentDefId) Then
        associationIcon = "<img src='Content/Images/Nav/remove-cross-through.png' border='0' title=Exception creation disabled' />"
    ElseIf Not IsNull(missingExceptionDefId) Then
        associationAction = "Edit"
        greyboxTitle = "Edit Missing Document Exception"
        associationIcon = "k-edit"
        associationUrl = "exceptiondefmaint1.asp?action=EDIT&exceptionDefId=" & missingExceptionDefId & "&activeTab=" & accountClassCode & "&grouptabmaint=1&activeGroupTab=" & activeGroupTab
    End If
%>
                <td>
                    <%= missingExceptionDefName %>
                </td>
                <td>
                <% If Not IsNull(documentDefId) Then %>
                    <a href="javascript:void(0);" onclick="openKendoDialog('<%=greyboxTitle%>', '<%=associationUrl%>', 500, 800);" class="k-button <%=associationIcon%>"><%=associationAction%></a>
                <% Else %>
                    <b>---</b>
                <% End If %>
                </td>
<%
    associationAction = "Add"
    greyboxTitle = "Add Expired Document Exception"
    associationIcon = "k-add"
    associationUrl = _
        "exceptiondefmaint1.asp" & _
        "?action=ADD&exceptionDefType=" & exceptionDefType & _
        "&targetType=" & typeCode & _
        "&targetTypeId=" & typeId & _
        "&documentDefId=" & documentDefId & _
        "&computationType=computed" & _
        "&statusTypeCheck=expired" & _
        "&activeTab=" & accountClassCode & _
        "&bankId=" & bankId & _
        "&grouptabmaint=1" & _
        "&activeGroupTab=" & activeGroupTab

    If IsNull(documentDefId) Then
        associationIcon = "<img src='Content/Images/Nav/remove-cross-through.png' border='0' title='Exception creation disabled' />"
    ElseIf Not IsNull(expiredExceptionDefId) Then
        associationAction = "Edit"
        greyboxTitle = "Edit Expired Document Exception"
        associationIcon = "k-edit"
        associationUrl = "exceptiondefmaint1.asp?action=EDIT&exceptionDefId=" & expiredExceptionDefId & "&activeTab=" & accountClassCode & "&grouptabmaint=1&activeGroupTab=" & activeGroupTab
    End If
       
%>
                <td>
                    <%= expiredExceptionDefName %>
                </td>
                <td>
                <% If Not IsNull(documentDefId) Then %>
                    <% If requireExpDate Then %>
                        <a href="javascript:void(0);" onclick="openKendoDialog('<%= greyboxTitle %>', '<%= associationUrl %>', 500, 800);" class="k-button <%=associationIcon%>"><%= associationAction %></a>
                    <% Else %>
                        N/A
                    <% End If %>
                <% Else %>
                    <b>---</b>
                <% End If %>
                </td>
            </tr>
<%
            typeRS.MoveNext
        Loop
        typeRS.Close
%>
        </tbody>
    </table>
</div>
<%
    End If ' typeRS.EOF
%>