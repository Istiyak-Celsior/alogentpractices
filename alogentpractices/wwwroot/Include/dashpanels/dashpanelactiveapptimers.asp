<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<%
IF Session("enableLoanApprovalsYN") = "N" THEN
    %><div class="common">No Action Timers are available due to Account Approvals being disabled.</div><%
ELSE
    Dim actionTimerRS : Set actionTimerRS = Server.CreateObject("ADODB.RecordSet")
    Dim actionTimerQuery : actionTimerQuery = _
        " SELECT" & _
        "   l.customerId," & _
        "   l.loanId," & _
        "   l.loanNumber," & _
        "   atd.actionTimerDefName," & _
        "   atd.notificationPeriod," & _
        "   atd.CountBusinessDays," & _
        "   atmr.timerStart," & _
        "   ISNULL(atmr.timerEnd, GetDate()) AS timerEnd," & _
        "   c.customerName" & _
        " FROM" & _
        "   loanApplication AS la INNER JOIN loan AS l" & _
        "       ON la.loanId=l.loanId" & _
        "   INNER JOIN loanStatus AS ls" & _
        "       ON ls.statusId=l.loanStatusId" & _
        "   INNER JOIN actionTimer AS atmr " & _
        "       ON atmr.loanApplicationId=la.loanApplicationId" & _
        "   INNER JOIN actionTimerDefinition AS atd" & _
        "       ON atmr.actionTimerDefId=atd.actionTimerDefId" & _
        "   INNER JOIN customer AS c" & _
        "       ON c.customerId = l.customerId " & _
        " WHERE" & _
        "   timerStart IS NOT NULL" & _
        "   AND timerEnd IS NULL" & _
        "   AND ls.isActiveApplicationStatus=1" & _
        " ORDER BY " & _
        "   atd.actionTimerDefName," & _
        "   l.loanNumber;"
    actionTimerRS.Open actionTimerQuery, db, adOpenStatic, adCmdText
    %>
    <table class="aa-approval-dashboard-widget aa-panel-table apptimer">
        <% IF actionTimerRS.EOF THEN %>
        <tr class="aa-no-results">
            <td>There are no active Action Timers currently running.</td>
        </tr>
        <% ELSE %>
        <tr class="aa-header">
            <td>Customer</td>
            <td>App. Number</td>
            <td class="aa-tac">Elapsed</td>
            <td>&nbsp;</td>
        </tr>
        <%
        Dim actionTimerName
        Dim currentTimerDefName : currentTimerDefName = ""
        DO UNTIL actionTimerRS.EOF
            Dim actionTimerDefName : actionTimerDefName =  actionTimerRS("actionTimerDefName")
            Dim applicationNumber : applicationNumber = actionTimerRS("loanNumber")
            Dim elapasedTime : elapasedTime = GetActionTimerDays(actionTimerRS("timerStart"), actionTimerRS("timerEnd"), actionTimerRS("CountBusinessDays"))
            Dim notificationPeriod : notificationPeriod = CInt(actionTimerRS("notificationPeriod"))

            IF actionTimerDefName <> currentTimerDefName THEN
                currentTimerDefName = actionTimerDefName
                actionTimerName = actionTimerDefName
            ELSE
                actionTimerName = ""
            END IF

            IF Trim(actionTimerName & "") <> "" THEN %>
            <tr class="aa-timer-name">
                <td colspan="4"><%=actionTimerName%></td>
            </tr>
            <% END IF %>
            <tr class="aa-restrict">
                <td><div><a href="customer.asp?customerId=<%=actionTimerRS("customerId")%>" title="<%=actionTimerRS("customerName")%>"><%=actionTimerRS("customerName")%></a></div></td>
                <td><a href="customer.asp?customerId=<%=actionTimerRS("customerId")%>&loanId=<%=actionTimerRS("loanId")%>"><%=applicationNumber%></a></td>
                <%
                Dim nDayType : nDayType = ""
                IF actionTimerRS("CountBusinessDays") THEN
                    nDayType = "<acronym title=""Business Days"">BD</acronym>"
                ELSE
                    nDayType = "<acronym title=""Calendar Days"">CD</acronym>"
                END IF
                %>
                <% IF elapasedTime >= notificationPeriod THEN %>
                <td class="aa-tar aa-color-danger"><b><%=elapasedTime & " " & nDayType%></b></td>
                <% ELSE %>
                <td class="aa-tar"><%=elapasedTime & " " & nDayType%></td>
                <% END IF %>
                <td><%
                IF elapasedTime >= notificationPeriod THEN
                    %><i class="aa-icon fas fa-exclamation-circle fa-fw aa-color-danger" aria-hidden="true"></i><%
                ELSE
                    %>&nbsp;<%
                END IF
                %></td>
            </tr>
            <%
            actionTimerRS.MoveNext
        LOOP
        END IF
        %>
    </table>
    <%
    actionTimerRS.Close
END IF ' ### Session("enableLoanApprovalsYN") = "N"
%>