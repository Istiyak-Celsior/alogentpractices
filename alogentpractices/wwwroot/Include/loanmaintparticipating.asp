<%
Dim passedContactId : passedContactId = Request("participationContactId")
IF Trim(passedContactId & "") = "" THEN
    Dim topParticipationRS : Set topParticipationRS = Server.CreateObject("adodb.recordset")
    Dim topParticipationQuery : topParticipationQuery = _
        " SELECT TOP 1 " & _
        "   pl.participationLoanId" & _
        " FROM" &_
        "   participationLoan pl INNER JOIN participationBank pb" & _
        "       ON pl.participationBankId = pb.participationBankId " & _
        " WHERE" & _
        "   pl.loanId = " & dbFormatId(Request("loanID")) & _
        " ORDER BY" & _
        "   pb.participationBankName"
    topParticipationRS.open topParticipationQuery, db
    IF NOT topParticipationRS.EOF THEN
        passedContactId = topParticipationRS("participationLoanId")
    END IF
    topParticipationRS.Close
END IF

Dim refreshUrl : refreshUrl = "customerscan.asp?state=INITIAL&action=EDITLOAN&customerId=" & customerId & "&loanId=" & loanId & "&bankId=" & bankId & "&accountClassId=" & accountClassId & "&selTab=a8"
Session("participationRefreshUrl") = refreshUrl
%>
<div class="aa-widget" id="aa-loan-maint-participations">
    <% IF Session("acculoan.showParticipationLoan") =  0 THEN %>
    <div class="sales-text">
        <p>Participation Loans is a module that allows affiliated banks to share a percentage of loans with other banks</p>
        <p>You can inquire about purchasing Participation Loans Module by visiting our website or calling our sales department</p>
    </div>
    <% ELSE %>
    <div>
        <h2 class="top">Current Participations</h2>
        <table id="pbList">
            <thead>
                <tr>
                    <th class="aa-tac">Action</th>
                    <th>Participating Bank</th>
                    <th>Primary Contact Name</th>
                    <th>Percent Participating</th>
                </tr>
            </thead>
            <tbody>
                <%
                Dim currentParticipationsRS : set currentParticipationsRS = Server.CreateObject("adodb.recordset")
                Dim currentParticipationsQuery : currentParticipationsQuery = _
                    " SELECT" & _
                    "   pl.participationLoanId," & _
                    "   pc.participationBankContactInfoId," & _
                    "   pb.participationBankName," & _
                    "   pc.primaryContactName," & _
                    "   pl.participationPercentage" & _
                    " FROM" &_
                    "   participationLoan pl INNER JOIN participationBank pb" & _
                    "       ON pl.participationBankId = pb.participationBankId " & _
                    "   LEFT OUTER JOIN participationBankContactInfo pc" & _
                    "       ON Pl.participationBankContactInfoId = pc.participationBankContactInfoId" & _
                    "       AND pl.participationBankContactInfoId = pc.participationBankContactInfoId " &_
                    " WHERE" & _
                    "   pl.loanId = " & dbFormatId(Request("loanID")) & _
                    " ORDER BY" & _
                    "   pb.participationBankName"
                currentParticipationsRS.open currentParticipationsQuery, db
                Dim firstParticipationContactId : firstParticipationContactId = Request("selectedContactId")

                IF NOT currentParticipationsRS.EOF THEN
                    DO WHILE NOT currentParticipationsRS.EOF
                        IF Trim(firstParticipationContactId & "") = "" THEN
                            firstParticipationContactId = currentParticipationsRS("participationBankContactInfoId")
                        END IF

                        Dim primaryContactName : primaryContactName = ""
                        IF Trim(currentParticipationsRS("primaryContactName") & "") = "" THEN
                            primaryContactName = "<i>Not Assigned</i>"
                        ELSE
                            primaryContactName = currentParticipationsRS("primaryContactName")
                        END IF

                        Response.Write "<tr>" & vbCr _
                                     & "    <td class=""aa-tac"" id=""delWrapper" & RemoveCurlyBrackets(currentParticipationsRS("participationLoanId")) & """><a href=""javascript:void(0);"" id=""delPB" & currentParticipationsRS("participationLoanId") & """><i class=""aa-icon fas fa-trash-alt fa-fw"" title=""Delete"" aria-hidden=""true""></i></a></td>" & vbCr _
                                     & "    <td><a href=""javascript:void(0);"" onclick=""OpenContactDetails('" & currentParticipationsRS("participationLoanId") & "')"">" & currentParticipationsRS("participationBankName") & "</a></td>" & vbCr _
                                     & "    <td>" & primaryContactName & "</td>" & vbCr _
                                     & "    <td>" & currentParticipationsRS("participationPercentage") & "%</td>" & vbCr _
                                     & "</tr>" & vbCr
                        currentParticipationsRS.MoveNext
                    LOOP
                ELSE
                    Response.Write "<tr>" & vbCr _
                                 & "<td class=""aa-tac"" colspan=""4"">Currently No Participation Banks or Contacts Have Been Assigned...</td>" & vbCr _
                                 & "</tr>" & vbCr
                END IF
                currentParticipationsRS.Close
                %>
            </tbody>
        </table>
        <h2>Add New Participation</h2>
        <table class="aa-form-participation-table">
            <tr>
                <td>Bank:</td>
                <%
                Dim participationRS : Set participationRS = Server.CreateObject("ADODB.RecordSet")
                Dim sqlQuery : sqlQuery = _
                    " SELECT " & _
                    "   pb.participationBankId, " & _
                    "   pb.participationBankName " & _
                    " FROM " & _
                    "   participationBank AS pb " & _
                    " WHERE " & _
                    "   pb.participationBankId NOT IN (" & _
                    "       SELECT participationBankId " & _
                    "       FROM participationLoan " & _
                    "       WHERE loanId = " & dbFormatId(loanId) & _
                    "       )" & _
                    " ORDER BY " & _
                    "   pb.participationBankName"
                participationRS.Open sqlQuery, db
                kendoSelectList = kendoSelectList & "participationBankList,"
                IF participationRS.EOF THEN
                    Response.Write "<td><select id=""participationBankList"" style=""width:280px"" name=""ddparticipationBankList"">" & vbCr _
                                 & "<option value="""">No New Participations Banks to Add</option></select></td>"
                ELSE
                    Response.Write "<td><select id=""participationBankList"" style=""width:280px"" name=""ddparticipationBankList"">" & vbCr _
                                 & "<option value="""">Select Participation Bank</option>" & vbCr
                    DO WHILE NOT participationRS.EOF
                        Dim participationBankId : participationBankId = participationRS("participationBankId")
                        Dim participationBankName : participationBankName = participationRS("participationBankName")
                        IF IsNull(participationContactId) THEN primaryContactName = "No Contacts Added Yet"
                        Response.Write "<option value=""" & participationBankId & """>" & participationBankName & "</option>" & vbCr
                        participationRS.MoveNext
                    LOOP
                    Response.Write "</select></td>" & vbCr
                END IF
                participationRS.Close
                %>
            </tr>
            <tr>
                <td>Participation Percentage:</td>
                <td>
                    <ul class="aa-loan-participation-list">
                        <li><input id="newParticipationPercentage" class="k-textbox document-date" type="text" maxlength="10" size="10" name="pbPercent"/>
                        <input type="hidden" name="bankId"/>
                        <input type="hidden" name="bankName"/>
                        <input type="hidden" name="primaryContactName"/></li>
                        <li>%</li>
                    </ul>
                </td>
            </tr>
            <tr class="aa-no-background-color" id="aa-participation-button-wrapper">
                <td colspan="2">
                    <ul class="aa-loan-participation-list">
                        <li><button type="button" id="addParticipation" class="k-button k-primary">Add Participation</button></li>
                        <li id="uxAddButtonWrapper"></li>
                    </ul>
                </td>
            </tr>
        </table>
    </div>
    <div id="contactinfo"></div>
    <% END IF %>
</div>