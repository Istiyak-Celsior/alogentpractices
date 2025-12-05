<%
statusIcon = "no"
activeDocCountQuery = " SELECT TOP 1 1 FROM document WHERE documentStatus = 1 AND loanId = " & dbFormatId(selectedLoanId)
activeDocCountRS.Open activeDocCountQuery, db
IF NOT activeDocCountRS.EOF THEN statusIcon = "yes"
activeDocCountRS.Close

IF selectedLoanTab = "document" THEN
    %>Documents&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=statusIcon%> fa-fw" aria-hidden="true"></i><%
ELSE
    %><a name="doc<%=loanRS("loanId")%>" href="customer.asp?loanTab=document#doc<%=loanRS("loanId")%>">Documents</a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=statusIcon%> fa-fw" aria-hidden="true"></i><%
END IF
%>