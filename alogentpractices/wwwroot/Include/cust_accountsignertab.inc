<%
Dim borrowerStatusImagePath : borrowerStatusImagePath = "no"
Dim borrowerStatusTitle : borrowerStatusTitle = "No Additional " & GuarantorsOrSigners

additionalBorrowerQuery = "SELECT TOP 1 1 FROM coborrower WHERE loanId = " & dbFormatID(loanRS("loanId"))
additionalBorrowerRS.Open additionalBorrowerQuery, db, adOpenStatic
IF NOT additionalBorrowerRS.EOF THEN
    borrowerStatusImagePath = "yes"
    borrowerStatusTitle = "Has Additional " & GuarantorsOrSigners
END IF
additionalBorrowerRS.Close

IF selectedLoanTab = "borrower" THEN
    %><%=GuarantorsOrSigners%>&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=borrowerStatusImagePath%> fa-fw" title="<%=borrowerStatusTitle%>" aria-hidden="true"></i><%
ELSE
    %><a name="borrower<%=loanRS("loanId")%>" href="customer.asp?loanTab=borrower#borrower<%=loanRS("loanId")%>"><%=GuarantorsOrSigners%></a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-<%=borrowerStatusImagePath%> fa-fw" title="<%=borrowerStatusTitle%>" aria-hidden="true"></i><%
END IF
%>