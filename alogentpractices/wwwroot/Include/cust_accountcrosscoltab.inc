<% IF selectedLoanTab = "crosscollateral" THEN %>
Cross Collaterals&nbsp;&nbsp;<i class="fas fa-circle aa-status-yes fa-fw" aria-hidden="true"></i>
<% ELSE %>
<a name="crosscollateral<%=loanRS("loanId")%>" href="customer.asp?loanTab=crosscollateral#crosscollateral<%=loanRS("loanId")%>">Cross Collaterals</a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-yes fa-fw" aria-hidden="true"></i>
<%	end if %>