<% OPTION EXPLICIT %>
<!-- #include file="../../adovbs.inc" -->
<!-- #include file="../../common.inc" -->
<%
IF NOT Session("userLoggedIn") THEN
    Response.Write "NOSESSION"
ELSE
    %>
    <!-- #include file="../../dbopen.inc" -->
    <!-- #include file="../../security.inc" -->
    <!-- #include file="actionEventFunctions.inc" -->
    <%
    Dim serviceName : serviceName = Trim(Request("srv") & "")

    IF serviceName = "list" THEN
        ' ### GET CLONEABLE LOAN TYPE LIST ###
        Dim accountClassId : accountClassId = GetAccountClassId()
        Response.Write GetCloneableTypeList(accountClassId)
    ELSEIF serviceName = "clone" THEN
        ' ### CLONE WORK FLOW EVENTS FOR LOAN TYPE ###
        Dim srcLoanTypeId : srcLoanTypeId = Request("src")
        Dim dstLoanTypeId : dstLoanTypeId = Request("dst")
        Call CloneLoanTypeWorkflowEvents(srcLoanTypeId, dstLoanTypeId)
    END IF
END IF
%>