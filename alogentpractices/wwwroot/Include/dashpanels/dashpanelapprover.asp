<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<%
Dim requestedAmount, totalRequestedAmount, oldCustomerId, customerId, loanId, customerUrl
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
    "   INNER JOIN approval" & _
    "       ON approval.approvalId=la.approvalId" & _
    "   INNER JOIN approvalStatus" & _
    "       ON approvalStatus.approvalStatusId=approval.approvalStatusId" & _
    " WHERE" & _
    "   ls.isActiveApplicationStatus=1" & _
    "   AND ls.isApplicationStatus=1" & _
    "   AND approvalStatus.isActiveApprovalStatus=1" & _
    "   AND (" & _
    "       approval.assignedApproverId = " & dbFormatId(Session("userId")) & _
    "       OR approval.assignedApproverId IN (" & _
    "           SELECT ugu.userGroupId" & _
    "           FROM " & _
    "               userGroup AS ug INNER JOIN userGroup_user AS ugu" & _
    "                   ON ug.userGroupId=ugu.userGroupId" & _
    "           WHERE " & _
    "               ug.isApproverGroup=1" & _
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
        <td>There are no active Loan Applications assigned to you for Approval.</td>
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
            totalRequestedAmount = totalRequestedAmount + cDbl(requestedAmount)
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
    activeApplicationRS.Close
    %>
</table>
<!-- #include file="../dbclose.inc" -->