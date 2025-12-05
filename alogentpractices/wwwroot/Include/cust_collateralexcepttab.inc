<%
' ### Check for Collateral Exceptions for the target Collateral ###
tabHasExceptions = GetExceptionTabCount(targetCollateralLoanId,"L")

statusIcon = "fa-circle aa-status-no"
IF collateralRS("ignoreExceptionsYN") = "Y" THEN
    statusIcon = "fa-ban aa-color-danger"
ELSEIF tabHasExceptions = 1 THEN
    statusIcon = "fa-circle aa-status-yes"
END IF

IF selectedCollateralTab = "exception" THEN
    %>Exceptions&nbsp;&nbsp;<i class="fa <%=statusIcon%> fa-fw" aria-hidden="true"></i><%
ELSE
    %><a name="except<%=targetCollateralLoanId%>" href="customer.asp?collateralTab=exception#collateralHeader">Exceptions</a>&nbsp;&nbsp;<i class="fa <%=statusIcon%> fa-fw" aria-hidden="true"></i><%
END IF
%>