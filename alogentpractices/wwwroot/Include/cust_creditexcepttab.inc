<%
creditExceptionTimeStart = Timer()
tabHasExceptions = GetExceptionTabCount(selectedCustomerId,"C")

statusIcon = "fa-circle aa-status-no"
IF customerRS("ignoreExceptionsYN") = "Y" THEN
    statusIcon = "fa-ban aa-color-danger"
ELSEIF tabHasExceptions = 1 THEN
    statusIcon = "fa-circle aa-status-yes"
END IF

IF selectedCreditTab = "exception" THEN
    %>Exceptions&nbsp;&nbsp;<i class="fa <%=statusIcon%> fa-fw" aria-hidden="true"></i><%
ELSE
    %><a href="customer.asp?creditTab=exception">Exceptions</a>&nbsp;&nbsp;<i class="fa <%=statusIcon%>" aria-hidden="true"></i><%
END IF

creditExceptionTimeStop = Timer()
creditExceptionTimeDelta = creditExceptionTimeStop - creditExceptionTimeStart
%>