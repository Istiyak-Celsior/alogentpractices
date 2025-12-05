<%
statusIcon = "no"
activeDocCountQuery = "SELECT TOP 1 1 FROM document WHERE documentStatus = 1 AND loanId = " & dbFormatId(targetCollateralLoanId)
activeDocCountRS.Open activeDocCountQuery, db
IF NOT activeDocCountRS.EOF THEN statusIcon = "yes"
activeDocCountRS.Close

IF selectedCollateralTab = "document" THEN
    %>Documents&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=statusIcon%> fa-fw" aria-hidden="true"></i><%
ELSE
    %><a name="doc<%=targetCollateralLoanId%>" href="customer.asp?collateralTab=document#collateralHeader">Documents</a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=statusIcon%> fa-fw" aria-hidden="true"></i><%
END IF
%>