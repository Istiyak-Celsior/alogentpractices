<%
	accountCrossCollateralTimeStart = Timer()
%>
<table class="aa-cross-collateral-list">
    <% IF crossCollateralCount > 0 THEN %>
    <tr>
        <td colspan="4">This loan is pledge to the following loan(s).</td>
    </tr>
    <tr>
        <td>Customer Name</td>
        <td>Loan Number</td>
        <td>Collateral Number</td>
        <td>Loan Description</td>
    </tr>
    <%
    crossCollateralQuery = _
        " SELECT" & _
        "   c.customerName," & _
        "   c.businessName," & _
        "   ccl.loanId AS collateralLoanId," & _
        "   col.collateralSequence," & _
        "   pl.customerId, " & _
        "   pl.loanId, " & _
        "   pl.loanNumber, " & _
        "   pl.loanDescription " & _
        " FROM" & _
        "   loan AS ccl INNER JOIN collateral AS col" & _
        "       ON ccl.loanId=col.collateralLoanId" & _
        "   INNER JOIN loan AS pl" & _
        "       ON col.parentLoanId=pl.loanId" & _
        "   INNER JOIN customer AS c" & _
        "       ON ccl.customerId=c.customerId" & _
        " WHERE" & _
        "   ccl.primaryCollateralId=" & dbFormatId(loanRS("loanId")) & _
        " ORDER BY" & _
        "   ccl.loanNumber"
    crossCollateralRS.Open crossCollateralQuery, db, adOpenStatic, adCmdText
    DO UNTIL crossCollateralRS.EOF
        Dim collateralSequence : collateralSequence = crossCollateralRS("collateralSequence")
        IF IsNumeric(collateralSequence) THEN
            collateralSequence = GetPaddedCollateralSequence(collateralSequence)
        ELSE
            collateralSequence = "---"
        END IF
        ccCustomerName = CheckForNull(crossCollateralRS("customerName"))
        IF ccCustomerName = "" THEN
            ccCustomerName = CheckForNull(CrossCollateralRS("businessName"))
        END IF
        %>
        <tr>
            <td><%=crossCollateralRS("customerName")%></td>
            <td><a href="customer.asp?customerId=<%=crossCollateralRS("customerId")%>&loanId=<%=crossCollateralRS("loanId")%>&collateralId=<%=crossCollateralRS("collateralLoanId")%>"><%=crossCollateralRS("loanNumber")%></a></td>
            <td><%= collateralSequence %></td>
            <td><%=crossCollateralRS("loanDescription")%></td>
        </tr>
        <%
        crossCollateralRS.MoveNext
    LOOP
    crossCollateralRS.Close
ELSE
    %><tr>
        <td class="aa-tac">There are no cross collaterals referring to this loan.</td>
    </tr>
    <%
END IF
%>
</table>
<%
	accountCrossCollateralTimeStop = Timer()
	accountCrosscollateralTimeDelta = accountCrossCollateralTimeStop-accountCrossCollateralTimeStart
%>