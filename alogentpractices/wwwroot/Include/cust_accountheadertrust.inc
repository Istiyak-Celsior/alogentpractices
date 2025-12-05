<form action="customer.asp" name="frmHiddenTrustId" method="post">
    <input type="hidden" name="hidTrustId" id="hidTrustId" value="<%=loanRS("loanId")%>"/>
</form>
<table class="aa-loan-header">
    <tr>
        <td class="<%=loanClassStyle%>">Account Number</td>
        <td class="displaylabel" colspan="7">
            <ul class="aa-loan-header-list">
                <%
                IF Session("acculoan.enablePurge") = 1 THEN
                    IF loanRS("PurgeStatus") OR loanRS("AccountBlockPurge") OR (NOT loanRS("PurgeStatus") AND loanRS("PurgeStatusLocked")) THEN
                        %><li><%=GetPurgeStatusIcon(loanRS("PurgeStatus"), loanRS("PurgeStatusLocked"), loanRS("AccountBlockPurge")) %></li><%
                    END IF
                END IF
                %>
                <li><%=loanRS("loanNumber")%></li>
                <% IF Session("trust.allowEdit") OR Session("trust.isAdmin") OR Session("isSuperUser") THEN %>
                <li><a href="customerscan.asp?state=INITIAL&action=EDITLOAN&customerId=<%=loanRS("customerId")%>&loanId=<%=loanRS("loanId")%>&bankId=<%=CustomerRS("bankId")%>&accountClassId=<%=selectedAccountClassId%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                <% END IF %>
            </ul>
        </td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%>">Relationship to Account</td>
        <td id="displayedBorrowerTypeDescription" class="displaylabel" colspan="7"><%=Replace(borrowerType,"Primary Borrower","Primary")%></td>
    </tr>
    <% IF Trim(loanRS("loanDescription")) <> "" THEN %>
    <tr>
        <td class="<%=loanClassStyle%>">Account Description</td>
        <td class="displaylabel" colspan="7"><%=loanRS("loanDescription")%></td>
    </tr>
    <% END IF %>
    <tr>
        <td class="<%=loanClassStyle%>">Account Type</td>
        <td class="<%=loanClassStyle%>">Status</td>
        <td class="<%=loanClassStyle%>">Branch</td>
        <td class="<%=loanClassStyle%>">Open Date</td>
        <td class="<%=loanClassStyle%>" colspan="2">Responsibility</td>
    </tr>
    <tr>
        <td class="displaylabel"><%=loanRS("loantypedescription")%></td>
        <td class="displaylabel"><%=loanRS("statusdescription")%></td>
        <td class="displaylabel"><%=loanRS("branchName")%></td>
        <td class="displaylabel"><%=loanRS("loanOrigDate")%></td>
        <td class="displaylabel" colspan="2"><%=loanRS("officername")%></td>
    </tr>
    <%
    strAddr=""
    IF Len(loanRS("Address1")) > 0 THEN strAddr = loanRS("Address1") & ", "
    IF Len(loanRS("Address2")) > 0 THEN strAddr = strAddr & loanRS("Address2") & ", "
    IF Len(loanRS("city")) > 0 THEN strAddr = strAddr & loanRS("city") & ", "
    IF Len(loanRS("state")) > 0 THEN strAddr = strAddr & loanRS("state") & ", "
    IF Len(strAddr) > 0 THEN strAddr = Left(strAddr, Len(strAddr) - 2)
    IF Len(loanRS("zipcode")) > 0 THEN strAddr = strAddr & ", " & loanRS("zipcode")
    IF Trim(Replace(strAddr, ",", "") & "") <> "" THEN
    %>
    <tr>
        <td class="<%=loanClassStyle%>">Trust Main Address</td>
        <td colspan="7" class="displaylabel"><%=strAddr%></td>
    </tr>
    <% END IF %>
    <!-- #include file="cust_accountheaderflexfields.inc" --> 
</table>