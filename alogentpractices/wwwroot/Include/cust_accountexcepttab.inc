<%
tabHasExceptions = GetExceptionTabCount(loanRS("loanId"),"L")

statusIcon = "fa-circle aa-status-no"
IF loanRS("ignoreExceptionsYN") = "Y" THEN
    statusIcon = "fa-ban aa-color-danger"
ELSEIF tabHasExceptions = 1 THEN
    statusIcon = "fa-circle aa-status-yes"
END IF

IF selectedLoanTab = "exception" THEN
    %>Exceptions&nbsp;&nbsp;<i class="fa <%=statusIcon%> fa-fw" aria-hidden="true"></i><%
ELSE
    %><a name="except<%=loanRS("loanId")%>" href="customer.asp?loanTab=exception#except<%=loanRS("loanId")%>">Exceptions</a>&nbsp;&nbsp;<i class="fa <%=statusIcon%> fa-fw" aria-hidden="true"></i><%
END IF
%>