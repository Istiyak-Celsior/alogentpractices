<%
Dim readerYN : readerYN = 1
Dim permAssignedUserId : permAssignedUserId = exceptionRS("assignedUserId")
IF Trim(permAssignedUserId & "") <> "" THEN permAssignedUserId = cStr(permAssignedUserId)
Dim transferableByUser : transferableByUser = exceptionRS("TransferableByUser")
IF Trim(transferableByUser & "") = "" THEN transferableByUser = 0
Dim exceptionTaskId : exceptionTaskId = exceptionRS("taskId")

IF exceptionRS("computationType") = "manual" THEN
    IF Trim(exceptionTaskId & "") = "" THEN
        IF Session("isSuperUser") _
            OR Session(activeTab & ".isAdmin") _
            OR Session("permissionException") >= 2 _
            OR cStr(Session("userId")) = permAssignedUserId THEN
            readerYN = 0
        END IF
    ELSE
        IF Session("isSuperUser") _
            OR Session(activeTab & ".isAdmin") _
            OR (Session("permissionException") >= 2 AND transferableByUser) _
            OR (cStr(Session("userId")) = permAssignedUserId AND transferableByUser) THEN
            readerYN = 0
        END IF
    END IF
ELSEIF exceptionRS("computationType") = "computed" THEN
    IF Session("isSuperUser") _
        OR Session(activeTab & ".isAdmin") _
        OR Session("permissionException") >= 2 _
        OR cStr(Session("userId")) = permAssignedUserId THEN
        readerYN = 0
    END IF
END IF
%>
<main class="inner">
    <%
    Dim exceptionDate ' ### This is for the overall Exception State and date processed
    Dim documentExceptionDate ' ### This is for the specific Document Exception State and date processed
    %>
    <table class="aa-two-column-form-table">
        <tr>
            <td><%=Trim(exceptionRS("exceptionDefName"))%>:</td>
            <td><%
            Dim exceptionState : exceptionState = exceptionRS("exceptionState")
            Dim documentExceptionState : documentExceptionState = exceptionRS("documentExceptionState")
            IF exceptionRS("computationType") = "manual" THEN
                computedOrNot= "Y"
                IF Session("permissionException") < 2 THEN
                    IF exceptionState = "Y" THEN
                        Response.Write "Is An Exception"
                    ELSEIF exceptionState = "P" THEN
                        Response.Write "Pending Exception"
                    ELSE
                        Response.Write "Not An Exception"
                    END IF
                    %><input type="hidden" name="exceptionState" value="<%=exceptionState%>"/><%
                ELSE
                    kendoSelectList = kendoSelectList & "exception-state,"
                    %><select name="<% IF readerYN = 1 THEN %>dis<% END IF %>exceptionState" id="exception-state"<% IF readerYN = 1 THEN %> disabled="disabled"<% END IF %>>
                    <option value="Y" <%=isExceptionSelected%>>Is An Exception</option><%
                    IF exceptionRS("requireReminderDate") = "Y" THEN
                        %><option value="P" <%=isPendingSelected%>>Pending Exception</option><%
                    END IF
                    %><option value="N" <%=isNotExceptionSelected%>>Not An Exception</option>
                    </select><input type="hidden" name="orgExceptionState" value="<%=exceptionState%>"/><%
                    IF readerYN = 1 THEN
                        %><input type="hidden" name="exceptionState" value="<%=exceptionState%>"/><%
                    END IF
                END IF
            ELSE
                ' ### Handle computed (aka Document) exceptions here
                computedOrNot= "N"
                IF documentExceptionState = "Y" THEN
                    Response.Write "Is An Exception"
                ELSEIF documentExceptionState = "P" THEN
                    Response.Write "Pending Exception"
                ELSE
                    Response.Write "Not An Exception"
                END IF
                %><input type="hidden" name="exceptionState" value="<%=exceptionRS("exceptionState")%>"/><%
            END IF
            %></td>
        </tr><%
        IF exceptionRS("computationType") = "manual" THEN
            IF exceptionState = "Y" THEN
                exceptionDate = exceptionRS("dateExcepted")
                dateLabel = "Date Pending Exception Set"
            ELSEIF exceptionState = "P" THEN
                exceptionDate = exceptionRS("datePending")
                dateLabel = "Date Exception Set"
            ELSEIF exceptionSate = "N" THEN
                exceptionDate = exceptionRS("dateResolved")
                dateLabel = "Date Exception Resolved"
            END IF
            theDate = exceptionDate
        ELSE
            IF documentExceptionState = "Y" THEN
                documentExceptionDate = exceptionRS("documentDateExcepted")
                dateLabel = "Document Date Exception Set"
            ELSEIF documentExceptionState = "P" THEN
                documentExceptionDate = exceptionRS("documentDatePending")
                dateLabel = "Document Date Pending Exception Set"
            ELSEIF documentExceptionState = "N" THEN
                documentExceptionDate = exceptionRS("documentDateResolved")
                dateLabel = "Document Date Exception Resolved"
            END IF
            theDate = documentExceptionDate
        END IF
        IF Trim(theDate & "") <> "" THEN
            %><tr>
                <td><%=dateLabel%>:</td>
                <td><%=theDate%></td>
            </tr><%
        END IF
        IF CheckForNull(exceptionRS("PolicyId")) <> "" THEN
            PolicyLabel = "Policy Description"
            PolicyDesc = exceptionRS("policyDescription")
            %><tr>
                <td>Associated Policy:</td>
                <td><%=exceptionRS("policyTitle")%></td>
            </tr>
            <tr>
                <td><%=PolicyLabel%>:</td>
                <td><%=PolicyDesc%></td>
            </tr><%
        END IF
        %><tr>
            <td>Assigned User:</td>
            <td><%
            Dim assignedUserQuery
            Dim assignedUserRS : Set assignedUserRS = CreateObject("ADODB.RecordSet")

            ' ### Set the assigned user ###
            IF Trim(newAssignedUserId & "") <> "" THEN
                assignedUserId = trim(newAssignedUserId)
            ELSE
                assignedUserId = exceptionRS("assignedUserId")
            END IF 

            IF Session("permissionException") = "read" THEN
                assignedUserQuery = " SELECT userLastName, userFirstName, userMiddleInitial FROM qryUserBankView WHERE userId=" & dbFormatId(exceptionRS("assignedUserId") & " order by userlastname,userfirstname")
                assignedUserRS.Open assignedUserQuery, db, adOpenStatic
                username = assignedUserRS("userLastName") & ", " & assignedUserRS("userFirstName") & " " & assignedUserRS("userMiddleInitial")
                assignedUserRS.Close
                %><%=userName%><input type="hidden" name="assignedUserId" value="<%=exceptionRS("assignedUserId")%>"/><%
            ELSE
                IF readerYN = 1 THEN
                    kendoSelectList = kendoSelectList & "assigned-user-id-d,"
                    %><%=userName%><input type="hidden" name="assignedUserId" value="<%=exceptionRS("assignedUserId")%>"/>
                    <select name="assignedUserIdD" id="assigned-user-id-d" disabled="disabled"><%
                ELSE
                    kendoSelectList = kendoSelectList & "assigned-user-id,"
                    %><select name="assignedUserId" id="assigned-user-id"><%
                    IF isnull(exceptionRS("assignedUserId")) THEN
                        %><option value="" selected="selected"> -- Unassigned -- </option><%
                    END IF
                END IF

                assignedUserQuery = " SELECT * FROM qryUserBankView WHERE bankId=" & dbFormatId(bankId)  & " order by userlastname,userfirstname"
                assigneduserRS.Open assignedUserQuery, db, adOpenStatic
                DO UNTIL assignedUserRS.EOF
                    selected = ""
                    IF cStr(CheckForNull(assignedUserRS("userId"))) = cStr(CheckForNull(exceptionRS("assignedUserId"))) THEN
                        selected = " selected=""selected"""
                    END IF
                    username = assignedUserRS("userLastName") & ", " & assignedUserRS("userFirstName") & " " & assignedUserRS("userMiddleInitial")
                    %><option <% IF autoDefaultAssignedUser = assignedUserRS("userId") THEN %> selected="selected"<% END IF %> value="<%=assignedUserRS("userId")%>"<%=selected%>><%=username%></option><%
                    assignedUserRS.MoveNext
                LOOP
                assignedUserRS.Close
                %></select><%
            END IF
            %></td>
        </tr><%
        option1Selected = ""
        option2Selected = ""
        IF Trim(newStatusType & "") <> "" THEN
            StatusType =  newStatusType
        ELSE
            StatusType = exceptionRS("StatusType")
        END IF

        IF exceptionRS("statusType") = "n/a" THEN
            option2Selected = " selected=""selected"""
            displayValue = "N/A"
        ELSE
            option1Selected = " selected=""selected"""
            displayValue = "Required"
        END IF
        %><tr>
            <td>Status Type:</td>
            <td><%
            IF Session("permissionException") = "read" THEN
                %><%=displayValue%><input type="hidden" name="statusType" value="<%=exceptionRS("statusType")%>"/><%
            ELSEIF readerYN = 1 THEN
                kendoSelectList = kendoSelectList & "status-type,"
                %><input type="hidden" name="statusType" id="status-type" value="<%=exceptionRS("statusType")%>"/>
                <select name="statusTyped" disabled="disabled">
                <option value="required"<%=option1Selected%>>Required</option>
                <option value="n/a"<%=option2Selected%>>N/A</option>
                </select><%
            ELSE
                kendoSelectList = kendoSelectList & "status-type,"
                %><select name="statusType" id="status-type">
                <option value="required"<%=option1Selected%>>Required</option>
                <option value="n/a"<%=option2Selected%>>N/A</option>
                </select><%
            END IF
            %><input type="hidden" name="orgStatusType" value="<%=exceptionRS("statusType")%>"/></td>
        </tr><%
        IF exceptionRS("computationType") = "manual" AND exceptionRS("requireReminderDate") = "Y" THEN
            reminderDate = exceptionRS("reminderDate")
            reminderDateGracePeriod = exceptionRS("reminderDateGracePeriod")
            %><tr>
                <td>Reminder Date:</td>
                <td>
                    <ul class="aa-horizontal-list">
                        <%
                        IF Trim(reminderDate & "") <> "" THEN reminderDate = FormatDateTime(reminderDate, 2)
                        IF Session("permissionException") <> 1 THEN
                            %><li><input type="date"
                                id="reminder-date"
                                name="reminderDate"
                                data-type="date"
                                data-date-msg="Invalid 'Reminder' date"
                                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                                /></li>
                            <li><span class="k-invalid-msg" data-for="reminderDate"></span></li><%
                        ELSE
                            %><li><input type="date"
                                id="reminder-date"
                                name="reminderDate"
                                data-type="date"
                                data-date-msg="Invalid 'Reminder' date"
                                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                                disabled="disabled" /></li>
                            <li><span class="k-invalid-msg" data-for="reminderDate"></span></li><%
                        END IF
                        %><li>
                            <div class="validator-msg">
                                <input type="hidden" name="orgReminderDate" value="<%=reminderDate%>"/>
                            </div>
                        </li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td>Grace Period:</td>
                <td><%
                IF Session("permissionException") <> 1 THEN
                    %><input type="text" class="k-textbox grace" name="reminderDateGracePeriod" size="5" value="<%=reminderDateGracePeriod%>"/><%
                ELSE
                    %><input type="text" name="reminderDateGracePeriod" size="5" value="<%=reminderDateGracePeriod%>" disabled="disabled"/><%
                END IF
                %></td>
            </tr><%
        END IF
        IF exceptionRS("computationType") = "manual" AND exceptionRS("requireLoanMaturityDate") AND CheckForNull(exceptionRS("loanId")) <> "" THEN
            ' ### Get the loanMaturity date from the loan table ###
            Dim loanRS : Set loanRS = Server.CreateObject("ADODB.RecordSet")
            Dim loanQuery : loanQuery = "SELECT loanMaturityDate FROM loan WHERE loanId=" & dbFormatId(exceptionRS("loanId"))
            loanRS.Open loanQuery,db, adOpenStatic, adCmdText
            IF NOT loanRS.EOF THEN loanMaturityDate = CheckForNull(loanRS("loanMaturityDate"))
            loanRS.Close
            reminderDateGracePeriod = exceptionRS("reminderDateGracePeriod")
            %><tr>
                <td>Reminder Date (Loan Maturity):</td>
                <td><input type="text" class="k-textbox date" name="reminderDate" value="<%=loanMaturityDate%>" readonly="readonly"/>
                <input type="hidden" name="orgReminderDate" value=""/></td>
            </tr>
            <tr>
                <td>Grace Period:</td>
                <td><input type="text" class="k-textbox" name="reminderDateGracePeriod" size="5" value="<%=reminderDateGracePeriod%>"/></td>
            </tr><%
        END IF
        %><tr>
            <td>Add Comment:</td>
            <td><textarea name="addComment" class="k-textbox text-area" cols="40" rows="6"><%= newAddComment %></textarea></td>
        </tr>
    </table>
</main>