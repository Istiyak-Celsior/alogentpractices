<%
loanApplicationQuery = _
    " SELECT la.loanApplicationId, lah.loanApplicationHistoryId" & _
    " FROM" & _
    "   loanApplication AS la LEFT OUTER JOIN loanApplicationHistory AS lah" & _
    "       ON la.loanApplicationId = lah.loanApplicationId" & _
    " WHERE la.loanId=" & dbFormatId(loanRS("loanId"))
loanApplicationRS.Open loanApplicationQuery, db, adOpenStatic, adCmdText

loanApplicationId = ""
loanApplicationHistoryId = ""
IF NOT loanApplicationRS.EOF THEN
    loanApplicationId = loanApplicationRS("loanApplicationId")
    loanApplicationHistoryId = loanApplicationRS("loanApplicationHistoryId")
END IF
loanApplicationRS.Close
%>
<form action="customer.asp" name="frmHiddenLoanId" method="post">
    <input type="hidden" name="hidCustomerId" id="hidCustomerId" value="<%=loanRS("customerId")%>"/>
    <input type="hidden" name="hidLoanId" id="hidLoanId" value="<%=loanRS("loanId")%>"/>
</form>
<table class="aa-loan-header">
    <tr>
        <td class="<%=loanClassStyle%>">Loan Number</td>
        <td colspan="7">
            <ul class="aa-loan-header-list">
                <%
                IF Session("acculoan.enablePurge") = 1 THEN
                    IF loanRS("PurgeStatus") OR loanRS("AccountBlockPurge") OR (NOT loanRS("PurgeStatus") AND loanRS("PurgeStatusLocked")) THEN
                        Response.Write "<li>" & GetPurgeStatusIcon(loanRS("PurgeStatus"), loanRS("PurgeStatusLocked"), loanRS("AccountBlockPurge")) & "</li>"
                    END IF
                END IF
                %>
                <li><%=loanRS("loanNumber")%></li>
                <% IF Session("loan.allowEdit") OR Session("loan.isAdmin") OR Session("isSuperUser") THEN %>
                <li><a href="customerscan.asp?state=INITIAL&action=EDITLOAN&customerId=<%=loanRS("customerId")%>&loanId=<%=loanRS("loanId")%>&bankId=<%=CustomerRS("bankId")%>&accountClassId=<%=selectedAccountClassId%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                <% END IF %>
                <% IF loanApplicationHistoryId <> "" THEN %>
                <li><a href="javascript:void(0);" onclick="openKendoDialog('Application History', 'viewapplicationhistory.asp?loanApplicationId=<%=loanApplicationId%>', 500, 700);" class="aa-command-link"><i class="aa-icon fas fa-history fa-fw" title="View Application History" aria-hidden="true"></i></a></li>
                <% END IF %>
            </ul>
        </td>
    </tr>
    <%
    loanClassificationStyle = "color:" & loanRS("loanClassificationDisplayColor") & ";"
    IF loanRS("loanClassificationDisplayEmphasis") THEN
        loanClassificationStyle = loanClassificationStyle & "font-weight:bold;"
    END IF
    %>
    <tr>
        <td class="<%=loanClassStyle%>">Borrower Type </td>
        <td id="displayedBorrowerTypeDescription" class="displaylabel" colspan="2"><%=borrowerType%></td>
        <td class="<%=loanClassStyle%>" colspan="2">Loan Classification</td>
        <td class="displaylabel" colspan="3" style="<%=loanClassificationStyle%>"><% if loanRS("loanClassificationDisplayEmphasis") then%><b><%=loanRS("loanClassificationName")%></b><%else%><%=loanRS("loanClassificationName")%><% end if%></td>
    </tr>
    <% IF Trim(loanRS("loanDescription") & "") <> "" THEN %>
    <tr>
        <td class="<%=loanClassStyle%>">Loan Description</td>
        <td class="displaylabel" colspan="7"><%=loanRS("loanDescription")%></td>
    </tr>
    <% END IF %>
    <tr>
        <td class="<%=loanClassStyle%>">Loan Type</td>
        <td class="<%=loanClassStyle%>">Status</td>
        <td class="<%=loanClassStyle%>">Branch</td>
        <td class="<%=loanClassStyle%>" colspan="2">Loan Officer</td>
        <td class="<%=loanClassStyle%>">Origination Date</td>
        <td class="<%=loanClassStyle%>">Balance</td>
        <td class="<%=loanClassStyle%>">Commitment</td>
    </tr>
    <tr>
        <td><%=loanRS("loantypedescription")%></td>
        <td><%=loanRS("statusdescription")%></td>
        <td><%=loanRS("branchName")%></td>
        <td colspan="2"><%=loanRS("officername")%></td>
        <td><%=loanRS("loanOrigDate")%></td>
        <td><%=FormatCurrency(ccur(loanAmountStr))%></td>
        <td><%=FormatCurrency(ccur(commitAmtStr))%></td>
    </tr>
    <%
    Dim strAddr : strAddr = ""
    IF Len(loanRS("Address1")) > 0 THEN strAddr = loanRS("Address1") & ", "
    IF Len(loanRS("Address2")) > 0 THEN strAddr = strAddr & loanRS("Address2") & ", "
    IF Len(loanRS("city")) > 0 THEN strAddr = strAddr & loanRS("city") & ", "
    IF Len(loanRS("state")) > 0 THEN strAddr = strAddr & loanRS("state") & ", "
    IF Len(strAddr) > 0 THEN strAddr = Left(strAddr, Len(strAddr) - 2)
    IF Len(loanRS("zipcode")) > 0 THEN strAddr = strAddr & ", " & loanRS("zipcode") 
    IF Trim(Replace(strAddr, ",", "") & "") <> "" THEN
    %>
    <tr>
        <td class="<%=loanClassStyle%>">Loan Main Address</td>
        <td colspan="7" class="displaylabel"><%=strAddr%></td>
    </tr>
    <% END IF %>
    <!-- #include file="cust_accountheaderflexfields.inc" -->
</table>