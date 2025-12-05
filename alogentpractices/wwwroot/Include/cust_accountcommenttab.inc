<%
srcActiveImg = "no" : altText = "No Comments"

Dim loanTabCommentRS : Set loanTabCommentRS = Server.CreateObject("ADODB.RecordSet")
Dim loanTabCommentQuery : loanTabCommentQuery = "SELECT TOP 1 1 FROM loanComments WHERE loanId = " & dbFormatId(selectedLoanId)
loanTabCommentRS.Open loanTabCommentQuery, db
IF NOT loanTabCommentRS.EOF THEN
    srcActiveImg = "yes"
    altText = "Has Comments"
END IF
loanTabCommentRS.Close
Set loanTabCommentRS = Nothing

IF selectedLoanTab = "comments" THEN
    %>Comments&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=srcActiveImg%> fa-fw" title="<%=altText%>" aria-hidden="true"></i><%
ELSE
    %><a href="customer.asp?loanTab=comments#comments<%=loanRS("loanId")%>">Comments</a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=srcActiveImg%> fa-fw" title="<%=altText%>" aria-hidden="true"></i><%
END IF
%>