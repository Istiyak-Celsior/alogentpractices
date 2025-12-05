<%
	accountParticipationTimeStart = Timer()
%>
<div style="padding: 10px">
    <% IF Session("acculoan.showParticipationLoan") = 0 THEN %>
    <div class="common">Participation Loans is a module that allows affiliated banks to share a percentage of loans with other banks</div>
    <div class="common">You can inquire about purchasing Participation Loans Module by visiting our website or calling our sales department</div>
    <% ELSE %>
    <h2 class="aa-participation-bank-title">Participating Banks</h2>
    <%
    Dim loopCounter : loopCounter = 0
    Set rs = Server.CreateObject("ADODB.RecordSet")
    sqlstr = "SELECT " _
           & "   pc.participationBankContactInfoId, " _
           & "   pb.participationBankName, " _
           & "   pl.participationPercentage, " _
           & "   pl.participationLoanId " _
           & " FROM " _
           & "   participationLoan AS pl " _
           & "       INNER JOIN participationBank AS pb ON pl.participationBankId = pb.participationBankId " _
           & "       LEFT OUTER JOIN participationBankContactInfo pc ON pl.participationBankContactInfoId = pc.participationBankContactInfoId " _
           & "           AND pl.participationBankContactInfoId = pc.participationBankContactInfoId " _
           & " WHERE " _
           & "   pl.loanId = " & dbFormatId(selectedLoanId)
    rs.Open sqlstr, db, 3, 3
    IF NOT rs.EOF THEN
        %><ul id="panelbar"><%
        DO WHILE NOT rs.EOF
            IF loopCounter = 0 THEN
                Response.Write "<li class=""k-state-active"">" & vbCr _
                             & "    " & rs("participationBankName") & "&nbsp;-&nbsp;" & rs("participationPercentage") & "%" & vbCr _
                             & "    <div>" & GetParticipationContactDetails(rs("participationBankContactInfoId"), rs("participationLoanId")) & "</div>" & vbCr _
                             & "</li>" & vbCr
            ELSE
                Response.Write "<li>" & vbCr _
                             & "    " & rs("participationBankName") & "&nbsp;-&nbsp;" & rs("participationPercentage") & "%" & vbCr _
                             & "    <div>" & GetParticipationContactDetails(rs("participationBankContactInfoId"), rs("participationLoanId")) & "</div>" & vbCr _
                             & "</li>" & vbCr
            END IF
            loopCounter = loopCounter + 1
            rs.MoveNext
        LOOP
        %></ul><%
    ELSE
        Response.Write "<table cellpadding=""0"" cellspacing=""0"" border=""0""><tr><td>No Participation Banks or Contacts Have Been Assigned...</td></tr></table>" & vbCr
    END IF
    rs.Close
    %>
    <% END IF %>
</div>
<%
	accountParticipationTimeStop = Timer()
	accountParticipationTimeDelta = accountParticipationTimeStop-accountParticipationTimeStart
%>