<form action="customer.asp" name="frmHiddenDepositId" method="post">
    <input type="hidden" name="hidDepositId" id="hidDepositId" value="<%=loanRS("loanId")%>" />
</form>
<table class="aa-loan-header">
    <tr>
        <td class="<%=loanClassStyle%>">Account Number</td>
        <td class="displaylabel" colspan="6">
            <ul class="aa-loan-header-list">
                <%
                IF Session("acculoan.enablePurge") = 1 THEN
                    IF loanRS("PurgeStatus") OR loanRS("AccountBlockPurge") OR (NOT loanRS("PurgeStatus") AND loanRS("PurgeStatusLocked")) THEN
                        %><li><%=GetPurgeStatusIcon(loanRS("PurgeStatus"), loanRS("PurgeStatusLocked"), loanRS("AccountBlockPurge")) %></li><%
                    END IF
                END IF
                %>
                <li><%=loanRS("loanNumber")%></li>
                <% IF Session("deposit.allowEdit") OR Session("deposit.isAdmin") OR Session("isSuperUser") THEN %>
                <li><a href="customerscan.asp?state=INITIAL&action=EDITLOAN&customerId=<%=loanRS("customerId")%>&loanId=<%=loanRS("loanId")%>&bankId=<%=CustomerRS("bankId")%>&accountClassId=<%=selectedAccountClassId%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                <% END IF %>
            </ul>
        </td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%>">Relationship to Account</td>
        <td id="displayedBorrowerTypeDescription" class="displaylabel" colspan="6"><%=Replace(borrowerType,"Primary Borrower","Primary")%></td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%>">Account Description</td>
        <td class="displaylabel" colspan="6"><%=loanRS("loanDescription")%></td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%>">Account Type</td>
        <td class="<%=loanClassStyle%>">Status</td>
        <td class="<%=loanClassStyle%>">Branch</td>
        <td class="<%=loanClassStyle%>">Open Date</td>
        <td class="<%=loanClassStyle%>" colspan="3">Responsibility</td>
    </tr>
    <tr>
        <td class="displaylabel"><%=loanRS("loantypedescription")%></td>
        <td class="displaylabel"><%=loanRS("statusdescription")%></td>
        <td class="displaylabel"><%=loanRS("branchName")%></td>
        <td class="displaylabel"><%=loanRS("loanOrigDate")%></td>
        <td class="displaylabel" colspan="3"><%=loanRS("officername")%></td>
    </tr>
    <tr>
      <td class="<%=loanClassStyle%>">Deposit Main Address</td>
      <%
      strAddr=""
       if len(loanRS("Address1"))>0 then
      strAddr=loanRS("Address1") & ", "
      end if
      if len(loanRS("Address2"))>0 then
      strAddr=strAddr & loanRS("Address2") & ", "
      end if
      if len(loanRS("city"))>0 then
      strAddr=strAddr & loanRS("city") & ", "
      end if
      if len(loanRS("state"))>0 then
      strAddr=strAddr & loanRS("state") & ", "
      end if
      if len(strAddr)>0 then
      strAddr=left(strAddr, len(strAddr)-2)
      end if
      if len(loanRS("zipcode"))>0 then
      strAddr=strAddr & ", " & loanRS("zipcode")
      end if
      %>
      <td colspan="7" class="displaylabel">
        <%=strAddr%>
      </td>
    </tr>    
    <!-- #include file="cust_accountheaderflexfields.inc" --> 
</table>