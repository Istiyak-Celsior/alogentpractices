<%
	crossCollateralTimeStart = Timer()
%>
<table class="aa-cross-collateral-list">
    <% IF crossCollateralCount > 0 THEN %>
    <tr>
        <td colspan="5">This collateral is pledged to the following loan(s).</td>
    </tr>
    <tr>
        <td>Customer Name</td>
        <td>Loan Number</td>
        <td>&nbsp;</td>
        <td>Collateral Number</td>
        <td>Collateral Description</td>
    </tr>
    <%
    crossCollateralQuery = _
        " SELECT" & _
        "   c.customerId," & _
        "   c.customerName," & _
        "   c.customerNumber," & _
        "   col.parentLoanId," & _
        "   IsNull(col.collateralLoanId, l.loanId) AS collateralLoanId," & _
        "   pl.loanNumber," & _
        "   l.loanDescription," & _
        "   l.primaryCollateralId," & _
        "   RIGHT('00000000000000000000' + IsNull(pl.loanNumber, l.loanNumber), 20) AS paddedLoanNumber," & _
        "   RIGHT('00000' + CONVERT(nvarchar(15),col.collateralSequence), 15) AS collateralNumber" & _
        " FROM" & _
        "   loan AS l LEFT OUTER JOIN collateral AS col" & _
        "       ON l.loanId=col.collateralLoanId" & _
        "   LEFT OUTER JOIN loan AS pl" & _
        "       ON pl.loanId=col.parentLoanId" & _
        "   LEFT OUTER JOIN customer AS c" & _
        "       ON (c.customerId=pl.customerId OR c.customerId=l.customerId)" & _
        " WHERE" & _
        "   l.loanId=" & dbFormatId(targetCollateralLoanId) & _
        "   OR l.primaryCollateralId=" & dbFormatId(targetCollateralLoanId) & _
        " ORDER BY paddedLoanNumber"
    crossCollateralRS.Open crossCollateralQuery, db
    DO UNTIL crossCollateralRS.EOF
        ccCustomerName = CheckForNull(crossCollateralRS("customerName"))
        IF ccCustomerName = "" THEN
            ccCustomerName = CheckForNull(crossCollateralRS("businessName"))
        END IF

        IF CheckForNull(crossCollateralRS("parentLoanId")) = "" THEN
            theUrl = "customer.asp?customerId=" &crossCollateralRS("customerId") & "&loanId=" & crossCollateralRS("collateralLoanId") & "#loanHeader"
        ELSE
            theUrl = "customer.asp?customerId=" & crossCollateralRS("customerId") & "&loanId=" & crossCollateralRS("parentLoanId") & "&collateralId=" & crossCollateralRS("collateralLoanId") & "#collateralHeader"
        END IF
        %>
        <tr>
            <td><%=ccCustomerName%></td>
            <% IF selectedCollateralId <> crossCollateralRS("collateralLoanId") THEN %>
            <td><a href="<%=theUrl%>"><%=crossCollateralRS("loanNumber")%></a></td>
            <% ELSE %>
            <td><%=crossCollateralRS("loanNumber")%></td>
            <% END IF %>
            <% IF CheckForNull(crossCollateralRS("primaryCollateralId")) = "" THEN %>
            <td><i class="fas fa-circle aa-status-yes fa-fw" title="Primary Collateral Reference" aria-hidden="true"></i></td>
            <% ELSE %>
            <td>&nbsp;</td>
            <% END IF %></td>
            <td><%=crossCollateralRS("collateralNumber")%></td>
            <td><%=crossCollateralRS("loanDescription")%></td>
        </tr>
        <%
        crossCollateralRS.MoveNext
    LOOP
    crossCollateralRS.Close
    ELSE
    %>
    <tr>
        <td>There are no cross collaterals referring to this loan.</td>
    </tr>
    <% END IF %>
</table>
<%
crossCollateralTimeStop = Timer()
crossCollateralTimerDelta = crossCollateralTimeStop-crossCollateralTimeStop
%>