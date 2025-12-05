<%
	creditEntityTimeStart = Timer()
%>
<!-- BEGIN Related Entities Display Area -->
<%
Dim isInEntityGroup : isInEntityGroup = false
Dim entityGroupSpan : entityGroupSpan = 5

Dim entityGroupRS : Set entityGroupRS = Server.CreateObject("ADODB.RecordSet")
Dim entityGroupQuery : entityGroupQuery = _
    " SELECT" & _
    "   gc.groupId," & _
    "   reg.entityRelationship," & _
    "   c.customerId," & _
    "   c.customerName," & _
    "   c.customerNumber," & _
    "   ISNULL(l.totalLoanAmount, 0) AS outstandingLoanAmount," & _
    "   ISNULL(l.totalCommitmentAmount, 0) AS commitment" & _
    " FROM" & _
    "   RelatedEntityGroups AS reg INNER JOIN GroupsCustomers AS gc " & _
    "       ON reg.groupId=gc.groupId" & _
    "   INNER JOIN customer AS c" & _
    "       ON c.customerId=gc.custId" & _
    "   LEFT OUTER JOIN" & _
    "   (" & _
    "       SELECT" & _
    "           customerId," & _
    "           SUM(CAST(ISNULL(loanAmount,0) AS money)) As totalLoanAmount, SUM(CAST(ISNULL(commitmentAmount, 0) AS money)) AS totalCommitmentAmount" & _
    "       FROM" & _
    "           loan INNER JOIN loanStatus ON loan.loanStatusId = loanStatus.statusId" & _
    "       WHERE" & _
    "           isCollateralYN = 'N' AND isCrossCollateralYN = 'N' AND (loanStatus.isActive = 1)" & _
    "       GROUP BY customerId" & _
    "   ) AS l" & _
    "       ON l.customerId=gc.custId" & _
    " WHERE" & _
    "   gc.groupId IN" & _
    "   ( SELECT groupId FROM GroupsCustomers WHERE custId=" & dbFormatId(selectedCustomerId) & ")" & _
    " ORDER BY" & _
    "   reg.EntityRelationship," & _
    "   c.customerName," & _
    "   c.customerNumber"
entityGroupRS.Open entityGroupQuery, db, adOpenStatic, adCmdText
%>
<table id="aa-entity-body">
    <% IF Session("credit.allowEdit") OR Session("credit.isAdmin") OR Session("isSuperUser") THEN %>
    <tr class="aa-menu-bar">
        <td colspan="<%=entityGroupSpan%>"><a href="RelatedGroupAddIndividual.asp?mode=ADD&customerId=<%=selectedCustomerId%>&customerName=<%=customerName%>" class="aa-command-button"><i class="aa-icon fas fa-user-plus fa-fw" title="Add Customer to a Group" aria-hidden="true"></i></a>
        <a href="RelatedGroupEdit.asp?mode=ADD&customerId=<%=selectedCustomerId%>" class="aa-command-button"><i class="aa-icon fas fa-users fa-fw" title="Add New Group" aria-hidden="true"></i></a>
        <% IF NOT entityGroupRS.EOF THEN %>
        <a href="RelatedGroupAddIndividual.asp?mode=DELETE&customerId=<%=selectedCustomerId%>&customerName=<%=customerName%>" class="aa-command-button"><i class="aa-icon fas fa-user-times fa-fw" title="Delete Customer from a Group" aria-hidden="true"></i></a>
        <% END IF %>
        </td>
    </tr>
    <% END IF %>
    <%
    Dim groupLabel : groupLabel = ""
    DO UNTIL entityGroupRS.EOF
        isInEntityGroup = true
        IF groupLabel <> entityGroupRS("entityRelationship") THEN
            groupLabel = entityGroupRS("entityRelationship")
            %>
            <tr class="entity-group">
                <td colspan="<%=entityGroupSpan%>"><h3>Related Entity:&nbsp;<span class="aa-color-link"><%=groupLabel%></span></h3></td>
            </tr>
            <tr class="head-bar">
                <td>Customer Number</td>
                <td>Customer Name</td>
                <td class="total-header"><% IF Session("acculoan.showloantotals") <> 0 THEN %>Outstanding Balance<% ELSE %>&nbsp;<% END IF %></td>
                <td class="total-header"><% IF Session("acculoan.showloantotals") <> 0 THEN %>Commitment Amount<% ELSE %>&nbsp;<% END IF %></td>
            </tr>
        <% END IF ' ### groupLabel <> entityGroupRS("entityRelationship") %>
        <tr>
            <% IF cStr(selectedCustomerId) = cStr(entityGroupRS("customerId")) OR (NOT allowCustomerBranchAccess AND Session("bankSecurity") = "DU") THEN %>
            <td><%=entityGroupRS("customerNumber")%></td>
            <% ELSE %>
            <td><a href="customer.asp?customerId=<%=entityGroupRS("customerId")%>"><%=entityGroupRS("customerNumber")%></a></td>
            <% END IF %>
            <% IF cStr(selectedCustomerId) = cStr(entityGroupRS("customerId")) OR (NOT allowCustomerBranchAccess AND Session("bankSecurity") = "DU") THEN %>
            <td><%=entityGroupRS("customerName")%></td>
            <% ELSE %>
            <td><a href="customer.asp?customerId=<%=entityGroupRS("customerId")%>"><%=entityGroupRS("customerName")%></a></td>
            <% END IF %>
            <%
            Dim outstandingLoanAmount : outstandingLoanAmount = FormatCurrency(entityGroupRS("outstandingLoanAmount"))
            %>
            <td class="total"><% IF Session("acculoan.showloantotals") <> 0 THEN %><%=outstandingLoanAmount%><% End If %></td>
            <td class="total"><% IF Session("acculoan.showloantotals") <> 0 THEN %><%=FormatCurrency(entityGroupRS("commitment"))%><% END IF %></td>
        </tr>
        <%
        entityGroupRS.MoveNext
    LOOP
    entityGroupRS.Close

    IF isInEntityGroup THEN
        ' ### Sum the outstanding total ###
        Dim totalOutstandingAmount
        entityGroupQuery = _
            " SELECT" & _
            "   SUM(v1.outstandingLoanAmount) AS totalOutstandingAmount," & _
            "   SUM(v1.totalCommitment) AS totalOutstandingCommitment" & _
            " FROM" & _
            "   (" & _
            "   SELECT" & _
            "       c.customerId," & _
            "       ISNULL(l.totalLoanAmount, 0) AS outstandingLoanAmount, " & _
            "       ISNULL(l.totalCommitmentAmount, 0) AS totalCommitment" & _
            "   FROM" & _
            "       RelatedEntityGroups AS reg INNER JOIN GroupsCustomers AS gc " & _
            "           ON reg.groupId=gc.groupId" & _
            "       INNER JOIN customer AS c" & _
            "           ON c.customerId=gc.custId" & _
            "       LEFT OUTER JOIN" & _
            "       (" & _
            "           SELECT" & _
            "               customerId," & _
            "               SUM(CAST(ISNULL(loanAmount,0) AS money)) As totalLoanAmount," & _
            "               SUM(CAST(ISNULL(commitmentAmount,0) AS money)) As totalCommitmentAmount" & _
            "           FROM" & _
            "               loan INNER JOIN loanStatus ON loan.loanStatusId = loanStatus.statusId" & _
            "           WHERE" & _
            "               isCollateralYN = 'N' AND isCrossCollateralYN = 'N' AND (loanStatus.isActive = 1)" & _
            "           GROUP BY customerId" & _
            "       ) AS l" & _
            "           ON l.customerId=gc.custId" & _
            "   WHERE" & _
            "       gc.groupId IN" & _
            "       ( SELECT groupId FROM GroupsCustomers WHERE custId=" & dbFormatId(selectedCustomerId) & ")" & _
            "       GROUP BY c.customerId, l.totalLoanAmount, l.totalCommitmentAmount" & _
            " ) AS v1"
        entityGroupRS.Open entityGroupQuery, db, adOpenStatic, adCmdText
        totalOutstandingAmount = 0
        totalOutstandingCommitment = 0
        IF NOT entityGroupRS.EOF THEN
            totalOutstandingAmount = entityGroupRS("totalOutstandingAmount")
            totalOutstandingCommitment = entityGroupRS("totalOutstandingCommitment")
        END IF
        entityGroupRS.Close

        totalOutstandingAmount = FormatCurrency(totalOutstandingAmount)
        totalOutstandingCommitment = FormatCurrency(totalOutstandingCommitment)

        IF Session("acculoan.showloantotals") <> 0 THEN %>
            <tr class="line">
                <td colspan="<%=entityGroupSpan%>"></td>
            </tr>
            <tr>
                <td colspan="<%=entityGroupSpan-4%>">&nbsp;</td>
                <td><h3>Totals:</h3></td>
                <td class="total"><%=totalOutstandingAmount%></td>
                <td class="total"><%=totalOutstandingCommitment%></td>
            </tr>
        <% END IF %>
    <% ELSE %>
        <tr>
            <td colspan="<%=entityGroupSpan%>">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="<%=entityGroupSpan%>" style="font-weight:bold; font-style:italic; text-align:center;">This customer does not belong to any Related Entities.<br><br></td>
        </tr>
    <% END IF %>
</table>
<%
	creditEntityTimeStop = Timer()
	creditEntityTimeDelta = creditEntityTimeStop-creditEntityTimeStart
%>