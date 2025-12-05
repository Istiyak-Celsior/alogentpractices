<%
activeDocCountQuery = "SELECT TOP 1 1 FROM document WHERE documentStatus = 1 AND loanId IS NULL AND customerId = " & dbFormatId(selectedCustomerId)
activeDocCountRS.Open activeDocCountQuery, db, adOpenForwardOnly, adLockReadOnly
IF NOT activeDocCountRS.EOF THEN
    statusIcon = "yes"
ELSE
    statusIcon = "no"
END IF
activeDocCountRS.Close
%>
<% IF selectedCreditTab = "document" THEN %>
Documents&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=statusIcon%> fa-fw" aria-hidden="true"></i>
<% ELSE %>
<a href="customer.asp?creditTab=document">Documents</a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=statusIcon%> fa-fw" aria-hidden="true"></i>
<% END IF %>