<%
Dim customerTabCommentRS : Set customerTabCommentRS = Server.CreateObject("ADODB.RecordSet")
Dim customerTabCommentQuery : customerTabCommentQuery = _
    "SELECT TOP 1 1 FROM customerComments WHERE customerId = " & dbFormatId(selectedCustomerId)
customerTabCommentRS.Open customerTabCommentQuery, db
statusIcon = "no"
IF NOT customerTabCommentRS.EOF THEN statusIcon = "yes"
customerTabCommentRS.Close

IF selectedCreditTab = "comments" THEN
    Response.Write "Comments&nbsp;&nbsp;<i class=""fas fa-circle aa-status-" & statusIcon & " fa-fw"" aria-hidden=""true""></i>"
ELSE
    Response.Write "<a href=""customer.asp?creditTab=comments"">Comments</a>&nbsp;&nbsp;<i class=""fas fa-circle aa-status-" & statusIcon & " fa-fw"" aria-hidden=""true""></i>"
END IF
%>