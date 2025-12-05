<%
srcActiveImg = "no" : altText = "No Participations"

Set hasParticipationsRS = Server.CreateObject("ADODB.RecordSet")
Dim hasParticipationsSQL : hasParticipationsSQL = "SELECT TOP 1 1 FROM participationLoan WHERE loanId = " & dbFormatId(selectedLoanId)
hasParticipationsRS.open hasParticipationsSQL, db
IF NOT hasParticipationsRS.EOF THEN
    srcActiveImg = "yes"
    altText = "Has Participations"
END IF
hasParticipationsRS.Close
Set hasParticipationsRS = Nothing

IF selectedLoanTab = "participation" THEN
    %>Participations&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=srcActiveImg%> fa-fw" title="<%=altText%>" aria-hidden="true"></i><%
ELSE
    %><a name="part<%=loanRS("loanId")%>" href="customer.asp?loanid=<%=loanRS("loanId")%>&loanTab=participation#part<%=loanRS("loanId")%>">Participations</a>&nbsp;<i class="fas fa-circle aa-status-<%=srcActiveImg%> fa-fw" title="<%=altText%>" aria-hidden="true"></i><%
END IF
%>