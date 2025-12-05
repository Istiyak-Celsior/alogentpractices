<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<%
Dim activeApplicationRS : Set activeApplicationRS = Server.CreateObject("ADODB.RecordSet")
Dim activeApplicationQuery : activeApplicationQuery = _
    " SELECT" & _
    "   c.customerId," & _
    "   c.customerName," & _
    "   l.loanId," & _
    "   l.loanNumber," & _
    "   la.requestedAmount" & _
    " FROM" & _
    "   customer AS c INNER JOIN loan AS l" & _
    "       ON c.customerId=l.customerId" & _
    "   INNER JOIN loanStatus AS ls" & _
    "       ON ls.statusId=l.loanStatusId" & _
    "   INNER JOIN loanApplication AS la" & _
    "       ON la.loanId=l.loanId" & _
    "   INNER JOIN creditAnalysisStatus As cas" & _
    "       ON cas.creditAnalysisStatusId=la.creditAnalysisStatusId" & _
    " WHERE" & _
    "   ls.isActiveApplicationStatus=1" & _
    "   AND ls.isApplicationStatus=1" & _
    "   AND cas.isActiveAnalysisStatus=1" & _
    "   AND (" & _
    "       la.assignedAnalystId=" & dbFormatId(Session("userId")) & _
    "       OR" & _
    "       la.assignedAnalystId IN (" & _
    "           SELECT ugu.userGroupId" & _
    "           FROM " & _
    "               userGroup AS ug INNER JOIN userGroup_user AS ugu" & _
    "                   ON ug.userGroupId=ugu.userGroupId" & _
    "           WHERE " & _
    "               ug.isAnalystGroup=1" & _
    "               AND ugu.userId=" & dbFormatId(Session("userId")) & _
    "       )" & _
    "   )" & _
    " ORDER BY" & _
    "   c.customerName, l.loanNumber" 
activeApplicationRS.Open activeApplicationQuery, db, adOpenStatic, adCmdText
%>
<table class="aa-approval-dashboard-widget aa-panel-table credit">
    <% IF activeApplicationRS.RecordCount = 0 THEN %>
    <tr class="aa-no-results">
        <td>There are no active Loan Applications assigned to you for Credit Analysis.</td>
    </tr>
    <% ELSE %>
    <tr class="aa-header">
        <td>Customer</td>
        <td class="aa-tar">Requested Amt.</td>
    </tr>
    <%
    totalRequestedAmount = 0.0
    oldCustomerId = ""
    DO UNTIL activeApplicationRS.EOF
        customerId = activeApplicationRS("customerId")
        loanId = activeApplicationRS("loanId")
        customerUrl = "customer.asp?customerId=" & customerId
        IF cStr(oldCustomerId) <> cStr(customerId) THEN
            oldCustomerId = customerId
            %>
            <tr>
                <td><a href="<%=customerUrl%>"><%=activeApplicationRS("customerName")%></a></td>
                <td>&nbsp;</td>
            </tr>
            <%
        END IF
        requestedAmount = CheckForNull(activeApplicationRS("requestedAmount"))
        IF IsNumeric(requestedAmount) THEN
            totalRequestedAmount = totalRequestedAmount + CDbl(requestedAmount)
            requestedAmount = FormatCurrency(requestedAmount)
        ELSE
            requestedAmount = "---"
        END IF

        customerUrl = "customer.asp?customerId=" & customerId & "&loanId=" & loanId
        %>
        <tr>
            <td class="aa-exception-type-indent"><a href="<%=customerUrl%>"><%=activeApplicationRS("loanNumber")%></a></td>
            <td class="aa-tar"><%=requestedAmount%></td>
        </tr>
        <%
        activeApplicationRS.MoveNext
    LOOP
    %>
    <tr class="aa-total">
        <td>Total Requested Amount: </td>
        <td><%=FormatCurrency(totalRequestedAmount)%></td>
    </tr>
    <%
    END IF ' ### activeApplicationRS.RecordCount = 0
    activeApplicationRS.Close()
    %>
</table>
<!-- #include file="../dbclose.inc" -->