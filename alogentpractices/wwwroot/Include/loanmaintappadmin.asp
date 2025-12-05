<%
IF isBookedLoan THEN
    admin = false
    dis = "disabled=""disabled"""
END IF

IF (loanApplicationId <> "" AND action <> "NEWAPP") THEN
    hideadminflag = ""
ELSE
    hideadminflag = "style=""display:none"""
    Dim nMessage : nMessage = ""
    IF action = "NEWLOAN" THEN
        nMessage = "-Loan application N/A for booked loans-"
    ELSEIF action = "NEWAPP" THEN
        nMessage = "-App Admin options will appear after clicking Update-"
    ELSE
        nMessage = "-Only available for loan applications-"
    END IF
    Response.Write "<div>" & vbCr _
                 & "<table>" & vbCr _
                 & "<tr>" & vbCr _
                 & "<td>" & nMessage & "</td>" & vbCr _
                 & "</tr>" & vbCr _
                 & "</table>" & vbCr _
                 & "</div>" & vbCr
END IF
%>
<div id="aa-application-status-wrapper" <%=hideadminflag %>>
    <ul class="aa-document-header-list">
        <li><h2>Application Admin</h2></li>
    </ul>
    <% initAssignedAnalystDropdown = false %>
    <table class="aa-two-column-form-table app-admin">
        <tbody>
            <tr class="aa-no-background-color">
                <td colspan="4"><h2>Credit Analysis</h2></td>
            </tr>
            <tr>
                <td>Assigned Analyst:</td>
                <td>&nbsp;</td>
                <% IF admin THEN %>
                <td><input id="cbo_analyst" name="targetAnalystId" onchange="needsSaved();" />
                <script id="aa-select-analyst-template" type="text/x-kendo-template">
                    <span>
                        <i class="fas fa-#: userIcon #" aria-hidden="true"></i><span class="aa-icon-spacer">#: name #</span>
                    </span>
                </script>
                <script type="text/javascript">
                    var analystSelectData = [];
                    analystSelectData.push({
                        "name": "Unassigned",
                        "id": "--null",
                        "userIcon": "times"
                    });
                    <%
                    Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
                    userGroupQuery = BuildUserGroupQuery("analyst")
                    userGroupRS.Open userGroupQuery, db
                    optionSelected = ""
                    IF assignedAnalystId = "" THEN
                        optionSelected = "selected=""selected"""
                    END IF

                    ' TODO: build out datasource for analyst
                    selectedIndex = 0
                    idx = 0
                    DO UNTIL userGroupRS.EOF
                        idx = idx + 1
                        targetName = userGroupRS("targetName")
                        targetType = userGroupRS("targetType")
                        targetId = userGroupRS("targetId")
                        optionValue = Left(targetType, 1) & ":" & userGroupRS("targetId")

                        IF cStr(assignedAnalystId) = cStr(targetId) THEN
                            selectedIndex = idx
                        END IF

                        userIcon = "user"
                        IF targetType = "group" THEN userIcon = "users" END IF

                        ' Add user/group to datasource
                        %>
                        analystSelectData.push({
                            name: "<% response.write targetName %>",
                            id: "<% response.write optionValue %>",
                            userIcon: "<% response.write userIcon %>"
                        });
                        <%
                            userGroupRS.MoveNext
                        LOOP
                        userGroupRS.Close

                    initAssignedAnalystDropdown = true
                        %>
                        function initializeAssignedAnalystDropdown() {
                            $("#cbo_analyst").kendoDropDownList({
                                dataSource: analystSelectData,
                                dataTextField: "name",
                                dataValueField: "id",
                                valueTemplate: kendo.template($("#aa-select-analyst-template").html()),
                                template: kendo.template($("#aa-select-analyst-template").html())
                            });

                            var assignedAnalystDropdown = $("#cbo_analyst").data("kendoDropDownList");
                            assignedAnalystDropdown.select(<% response.write selectedIndex %>);
                            assignedAnalystDropdown.list.width(400);
                        }
                    </script>
                </td>
                <% ELSE ' ### IF admin THEN %>
                <%
                IF assignedAnalystId <> "" THEN
                Dim analystRS : Set analystRS = Server.CreateObject("ADODB.RecordSet")
                Dim analystQuery : analystQuery = _
                    " SELECT" & _
                    "   userId AS targetId," & _
                    "   userLastName + ', ' + userFirstName + ' ' + userMiddleInitial AS targetName," & _
                    "   'user' AS targetType " & _
                    " FROM" & _
                    "   [user] AS u " & _
                    " WHERE" & _
                    "   (userId = '" & assignedAnalystId & "')" & _
                    " UNION " & _
                    " SELECT" & _
                    "   userGroupId AS targetId," & _
                    "   userGroupName AS targetName," & _
                    "   'group' AS targetType " & _
                    " FROM" & _
                    "   userGroup AS g " & _
                    " WHERE" & _
                    "   (userGroupId = '" & assignedAnalystId & "')"
                analystRS.Open analystQuery, db
                %>
                <td><%=analystRS("targetName")%><%
                targetName = analystRS("targetName")
                targetType = analystRS("targetType")
                targetId = analystRS("targetId")
                optionValue = Left(targetType,1) & ":" & analystRS("targetId")
                analystRS.Close
                %><input type="hidden" name="targetAnalystId" value="<%=optionValue%>"/></td>
                <% ELSE %>
                <td>Unassigned<input type="hidden" name="targetAnalystId" value="--null"/></td>
                <% END IF %>
                <% END IF ' ### IF admin THEN %>
            </tr>
            <tr>
                <td>Analysis Status:</td>
                <td>&nbsp;</td>
                <td><select id="aa-select-credit-analysis" class="k-dropdown" name="creditAnalysisStatusId" <%=dis%>><%
                kendoSelectList = kendoSelectList & "aa-select-credit-analysis,"
                Dim analysisStatusRS : Set analysisStatusRS = Server.CreateObject("ADODB.RecordSet")
                Dim analysisStatusQuery : analysisStatusQuery = _
                    " SELECT COUNT(creditAnalysisStatusId) AS theDefaultCount" & _
                    "   FROM creditAnalysisStatus" & _
                    "   WHERE (isDefault = 1)"
                analysisStatusRS.Open analysisStatusQuery, db

                Dim theDefaultCount : theDefaultCount = analysisStatusRS("theDefaultCount")
                Dim theLoopCount : theLoopCount = 0

                Set analysisStatusRS = Server.CreateObject("ADODB.RecordSet")
                analysisStatusQuery = _
                    " SELECT " & _ 
                    "   creditAnalysisStatusId, " & _
                    "   creditAnalysisStatusDescription, " & _
                    "   isDefault " & _
                    " FROM " & _
                    "   creditAnalysisStatus " & _
                    " ORDER BY creditAnalysisStatusCode"
                analysisStatusRS.Open analysisStatusQuery, db

                Dim statusSelected : statusSelected = False
                DO UNTIL analysisStatusRS.EOF
                    Dim statusId : statusId = analysisStatusRS("creditAnalysisStatusId")
                    Dim statusLabel : statusLabel = analysisStatusRS("creditAnalysisStatusDescription")
                    Dim isDefaultStatus : isDefaultStatus = analysisStatusRS("isDefault")
                    strSelected = ""

                    IF isDefaultStatus THEN defaultCreditAnalysisStatusId = statusId

                    IF creditAnalysisStatusId = "" AND isDefaultStatus THEN
                        strSelected = " selected=""selected"""
                        statusSelected = True
                    ELSEIF cStr(creditAnalysisStatusId) = cStr(statusId) THEN
                        strSelected = " selected=""selected"""
                        statusSelected = True
                    END IF
                    Response.Write "<option value=""" & statusId & """" & strSelected & ">" & statusLabel & "</option>"
                    analysisStatusRS.MoveNext
                LOOP
                analysisStatusRS.Close
                IF NOT statusSelected THEN Response.Write "<option value="""" selected=""selected"">No Default Value Selected</option>"
                %>
                </select><%
                IF dis = "disabled=""disabled""" THEN
                    %><input type="hidden" name="hidCreditAnalysisStatusId" value="<%=creditAnalysisStatusId%>"/><%
                END IF
                %><input type="hidden" name="defaultCreditAnalysisStatusId" value="<%=defaultCreditAnalysisStatusId%>"/></td>
            </tr>
            <tr class="aa-no-background-color">
                <td colspan="4"><h2>Loan Approval</h2></td>
            </tr>
            <% initAssignedApproverDropdown = false %>
            <tr>
                <td>Assigned Approver:</td>
                <td>&nbsp;</td>
                <% IF admin THEN %>
                <td><input id="cbo_approver" name="targetApproverId" onchange="needsSaved();" />
                <script id="aa-select-approver-template" type="text/x-kendo-template">
                    <span>
                        <i class="fas fa-#: userIcon #" aria-hidden="true"></i><span class="aa-icon-spacer">#: name #</span>
                    </span>
                </script>
                <script type="text/javascript">
                    var assignedApproverData = [];

                    assignedApproverData.push({
                        "name": "Unassigned",
                        "id": "--null",
                        "userIcon": "times"
                    });
                    <%
                    Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
                    userGroupQuery = BuildUserGroupQuery("Approver")
                    'Response.Write "userGroupQuery = " & userGroupQuery & "<br/>"
                    userGroupRS.Open userGroupQuery, db
                    optionSelected = ""
                    IF assignedApproverId = "" THEN
                        optionSelected = "selected=""selected"""
                    END IF

                    selectedIndex = 0
                    idx = 0
                    DO UNTIL userGroupRS.EOF
                        idx = idx + 1
                        targetName = userGroupRS("targetName")
                        targetType = userGroupRS("targetType")
                        targetId = userGroupRS("targetId")
                        optionValue = Left(targetType, 1) & ":" & userGroupRS("targetId")

                        IF cStr(assignedApproverId) = cStr(targetId) THEN
                            selectedIndex = idx
                        END IF

                        userIcon = "user"
                        IF targetType = "group" THEN userIcon = "users" END IF

                        ' Add user/group to datasource
                        %>
                        assignedApproverData.push({
                            name: "<%=targetName %>",
                            id: "<%=optionValue %>",
                            userIcon: "<%=userIcon %>"
                        });
                        <%
                        userGroupRS.MoveNext
                    LOOP
                    userGroupRS.Close

                    initAssignedApproverDropdown = true
                    %>
                    // NOTE: function to initialize is here with the rest but it should
                    // be called in the $(document).ready() as the DOM needs to be fully loaded
                    // before initializing
                    function initializeAssignedApproverDropdown(){
                        $("#cbo_approver").kendoDropDownList({
                            dataSource: assignedApproverData,
                            dataTextField: "name",
                            dataValueField: "id",
                            valueTemplate:  kendo.template($("#aa-select-approver-template").html()),
                            template: kendo.template($("#aa-select-approver-template").html())
                        });
    
                        var assignedApproverDropdown = $("#cbo_approver").data("kendoDropDownList");
                        assignedApproverDropdown.select(<%=selectedIndex%>);
                    }
                </script></td>
                <% ELSE ' ### IF admin THEN %>
                <%
                IF assignedApproverId <> "" THEN
                    Dim approverRS : Set approverRS = Server.CreateObject("ADODB.RecordSet")
                    Dim approverQuery : approverQuery = _
                        " SELECT" & _
                        "   userId AS targetId," & _
                        "   userLastName + ', ' + userFirstName + ' ' + userMiddleInitial AS targetName," & _
                        "   'user' AS targetType " & _
                        " FROM" & _
                        "   [user] AS u " & _
                        " WHERE" & _
                        "   (userId = '" & assignedApproverId & "')" & _
                        " UNION " & _
                        " SELECT" & _
                        "   userGroupId AS targetId," & _
                        "   userGroupName AS targetName," & _
                        "   'group' AS targetType " & _
                        " FROM" & _
                        "   userGroup AS g " & _
                        " WHERE" & _
                        "   (userGroupId = '" & assignedApproverId & "')"
                    approverRS.Open approverQuery, db
                    targetName = approverRS("targetName")
                    targetType = approverRS("targetType")
                    targetId = Left(targetType,1) & ":" & approverRS("targetId")
                    %><td><%=approverRS("targetName")%><input name="targetApproverId" type="hidden" value="  <%=targetId %>"/></td><%
                    approverRS.Close
                ELSE
                    %><td>Unassigned<input name="targetApproverId" type="hidden" value="--null"/></td><%
                END IF
                END IF ' ### IF admin THEN %>
            </tr>
            <tr>
                <td>Approval Status:</td>
                <td>&nbsp;</td>
                <%
                dis = "disabled=""disabled"""
                IF Session("isSuperUser") OR Session("loanApp.isAdmin") THEN
                    dis = ""
                END IF

                Dim approvalStatusRS : Set approvalStatusRS = Server.CreateObject("ADODB.RecordSet")
                Dim approvalStatusQuery : approvalStatusQuery = _
                    " SELECT " & _ 
                    "   approvalStatusId, " & _
                    "   approvalStatusDescription, " & _
                    "   approvalStatusCode, " & _
                    "   isDefault " & _
                    " FROM " & _
                    "   approvalStatus " & _
                    " ORDER BY approvalStatusDescription"
                approvalStatusRS.Open approvalStatusQuery, db
                kendoSelectList = kendoSelectList & "aa-select-approval-status,"
                IF approvalStatusRS.EOF THEN
                    Response.Write "<td><select id=""aa-select-approval-status"" name=""approvalStatusId"" " & dis & "><option value=""""></option></select></td>" & vbCr
                ELSE
                    Response.Write "<td><select id=""aa-select-approval-status"" name=""approvalStatusId"" " & dis & ">" & vbCr
                    DO UNTIL approvalStatusRS.EOF
                        strSelected = ""
                        IF approvalStatusId = "" AND approvalStatusRS("isDefault") THEN
                            strSelected = " selected=""selected"""
                            approvalStatusId = approvalStatusRS("approvalStatusId")
                        ELSEIF cStr(approvalStatusId) = cStr(approvalStatusRS("approvalStatusId")) THEN
                            strSelected = " selected=""selected"""
                            approvalStatusId = approvalStatusRS("approvalStatusId")
                        END IF
                        Response.Write "<option value=""" & approvalStatusRS("approvalStatusId") & """" & strSelected & ">" & approvalStatusRS("approvalStatusDescription") & "</option>" & vbCr
                        approvalStatusRS.MoveNext
                    LOOP
                    approvalStatusRS.Close
                    Response.Write "</select>" & vbCr
                    Response.Write "<input name=""defaultApprovalStatusId"" type=""hidden"" value=""" & approvalStatusId & """/></td>" & vbCr
                END IF
                %>
            </tr>
            <% IF declinedReasonID <> "" THEN %>
            <tr>
                <td>Declined Reason:</td>
                <td>&nbsp;</td>
                <td><select id="aa-select-declined-reason" name="declinedReasonId" <%=dis%>><%
                kendoSelectList = kendoSelectList & "aa-select-declined-reason,"
                Dim declinedReasonRS : Set declinedReasonRS = Server.CreateObject("ADODB.RecordSet")
                Dim declinedReasonQuery : declinedReasonQuery = _
                    " SELECT declinedReasonId, declinedReasonDescription" & _
                    " FROM declinedReason" & _
                    " ORDER BY declinedReasonDescription"

                declinedReasonRS.Open declinedReasonQuery, db
                IF NOT statusSelected THEN Response.Write "<option value="""" selected=""selected"">No Default Value Selected</option>"

                IF declinedReasonRS.EOF THEN

                ELSE
                    Response.write "<option value="""">--- Clear Declined Reason ---</option>"
                    DO UNTIL declinedReasonRS.EOF
                        strSelected = ""
                        IF cStr(declinedReasonId) = cStr(declinedReasonRS("declinedReasonId")) THEN
                            strSelected = " selected=""selected"""
                        END IF
                        Response.Write "<option value=""" & declinedReasonRS("declinedReasonId") & """" & strSelected & ">" & declinedReasonRS("declinedReasonDescription") & "</option>" & vbCr
                        declinedReasonRS.MoveNext
                    LOOP
                    declinedReasonRS.Close
                END IF
                %>
                </select><%
                IF dis <> "disabled=""disabled""" THEN
                    %><input type="hidden" name="orgDeclinedReasonId" value="<%=declinedReasonId%>"/><%
                END IF
                %></td>
            </tr>
            <% END IF ' declinedReasondId <> "" %>
            <tr class="aa-no-background-color">
                <td colspan="4"><h2>Application State</h2></td>
            </tr>
            <% IF action = "EDITLOAN" THEN %>
            <tr>
                <td>Application Status:</td>
                <td>&nbsp;</td>
                <%
                IF isBookedLoan THEN
                    Response.Write "<td>Is Booked Loan"
                ELSE
                    dis = "disabled=""disabled"""
                    IF NOT isBookedLoan AND (Session("isSuperUser") OR Session("loanApp.isAdmin")) THEN
                        dis = ""
                    END IF
                    kendoSelectList = kendoSelectList & "aa-select-application-status,"
                    Response.Write "<td><select id=""aa-select-application-status"" name=""loanStatusId"" " & dis & ">" & vbCr
                    Dim appAdminStatusRS : Set appAdminStatusRS = Server.CreateObject("ADODB.RecordSet")
                    Dim appAdminStatusQuery : appAdminStatusQuery = _
                        " SELECT statusId, statusDescription" & _
                        " FROM loanStatus" & _
                        " WHERE isApplicationStatus = 1" & _
                        " ORDER BY statusDescription"
                    appAdminStatusRS.Open appAdminStatusQuery, db
                    DO UNTIL appAdminStatusRS.EOF
                        optionSelected = ""
                        IF cStr(appAdminStatusRS("statusId")) = cStr(applicationStatusId) THEN
                            optionSelected = "selected=""selected"""
                        END IF
                        Response.Write "<option value=""" & appAdminStatusRS("statusId") & """ " & optionSelected & ">" & appAdminStatusRS("statusDescription") & "</option>" & vbCr
                        appAdminStatusRS.MoveNext
                    LOOP
                    appAdminStatusRS.Close
                    Response.Write "</select>"
                END IF
                Response.Write "<input type=""hidden"" name=""defaultLoanStatusId"" value=""" & loanStatusId & """/></td>" & vbCr
                %>
            </tr>
            <% END IF ' ### action = "EDITLOAN" %>
            <tr>
                <td>Application Locked:</td>
                <td>&nbsp;</td>
                <%
                dis = "disabled=""disabled"""
                IF NOT isBookedLoan AND (Session("isSuperUser") OR Session("loanApp.isAdmin")) THEN
                    dis = ""
                END IF
                kendoSelectList = kendoSelectList & "aa-select-application-locked,"
                Response.Write "<td><select id=""aa-select-application-locked"" name=""appLocked"" " & dis & ">" & vbCr
                Dim defaultLockedValue
                IF appLocked THEN
                    yesselect = "selected=""selected"""
                    defaultLockedValue = "true"
                ELSE
                    noselect = "selected=""selected"""
                    defaultLockedValue = "false"
                END IF
                Response.Write "<option value=""true"" " & yesselect & ">Yes</option>" & vbCr
                Response.Write "<option value=""false"" " & noselect & ">No</option>" & vbCr
                Response.Write "</select>" & vbCr
                Response.Write "<input type=""hidden"" name=""defaultAppLocked"" value=""" & defaultLockedValue & """/></td>" & vbCr
                %>
            </tr>
            <%
            IF NOT isBookedLoan THEN
                IF ignoreExceptionsYN = "Y" THEN
                    ySelected = "selected=""selected"""
                    nSelected = ""
                ELSE
                    ySelected = ""
                    nSelected = "selected=""selected"""
                END IF

                imgLock = "unlock"
                IF lockIgnoreExceptionsYN THEN imgLock = "lock"
                
                IF Session("accuaccount.enableExpress") <> 1 THEN
                %>
                <tr class="aa-no-background-color narrow">
                    <td colspan="4"></td>
                </tr>
                <tr>
                    <td>Ignore Exceptions:</td>
                    <td><input type="hidden" id="hidLockIgnoreExceptions" name="lockIgnoreExceptionsYN" value="<%=lockIgnoreExceptionsYN%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockIgnoreExceptions"></i></td>
                    <%
                    IF isCrossCollateralYN = "Y" _
                        OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                        OR NOT allowLoanBranchAccess THEN
                        IF ignoreExceptionsYN = "Y" THEN
                            Response.Write "<td>Yes</td>" & vbCr
                        ELSE
                            Response.Write "<td>No</td>" & vbCr
                        END IF
                    ELSE
                        kendoSelectList = kendoSelectList & "aa-select-ignore-exceptions,"

                        Response.Write "<td><select id=""aa-select-ignore-exceptions"" name=""ignoreExceptionsYN"" onchange=""needsSaved();"">" & vbCr
                        Response.Write "<option value=""Y"" " & ySelected & ">Yes</option>" & vbCr
                        Response.Write "<option value=""N"" " & nSelected & ">No</option>" & vbCr
                        Response.Write "</select>" & vbCr
                        Response.Write "<input type=""hidden"" name=""orgIgnoreExceptionsYN"" value=""" & ignoreExceptionsYN & """/></td>" & vbCr
                    END IF
                    %>
                </tr>
                <% ELSE %>
                <tr>
                    <td><input type="hidden" name="lockIgnoreExceptionsYN" value="false"/>
                    <input type="hidden" name="ignoreExceptionsYN" value="N" /></td>
                </tr>
                <% END IF ' ### Session("accuaccount.enableExpress" <> 1 %>
            <% END IF ' ### isBookedLoan %>
            <tr class="aa-no-background-color">
                <td colspan="4"><h2>Reset Timers</h2></td>
            </tr>
            <tr class="aa-no-background-color">
                <td colspan="4">
                <%
                Const ACTION_TIMER_DEF_ID = 0
                Const ACTION_TIMER_DEF_NAME = 1
                Const ISDEFAULT_APPLICATION_TIMER = 2
                Const NOTIFICATION_PERIOD = 3
                Const ACTION_TIMER_ID = 4
                Const TIMER_START = 5
                Const TIMER_END = 6
                Const COUNT_BUSINESS_DAYS = 7

                Dim actionTimerStart, actionTimerEnd, actionTimerElapsedTime, actionTimerStatus
                Dim notificationPeriod, countBusinessDays, timerLabel
                Dim actionTimerList, actionTimerCount

                Dim actionTimerRS : Set actionTimerRS = Server.CreateObject("ADODB.RecordSet")
                Dim actionTimerQuery : actionTimerQuery = _
                    " SELECT " & _
                    "   atd.actionTimerDefId," & _
                    "   atd.actionTimerDefName," & _
                    "   atd.isDefaultApplicationTimer," & _
                    "   atd.notificationPeriod," & _
                    "   atmr.actionTimerId," & _
                    "   atmr.timerStart," & _
                    "   atmr.timerEnd," & _
                    "   atd.countBusinessDays" & _
                    " FROM" & _
                    "   actionTimer AS atmr" & _
                    "       INNER JOIN actionTimerDefinition AS atd ON atmr.actionTimerDefId = atd.actionTimerDefId" & _
                    "       INNER JOIN loanApplication la ON la.loanApplicationId = atmr.loanApplicationId" &_
                    " WHERE" & _
                    "   la.loanId = " & dbFormatId(loanId) & _
                    " ORDER BY" & _
                    "   atd.actionTimerDefName"
                actionTimerRS.Open actionTimerQuery, db
                actionTimerCount = -1
                IF NOT actionTimerRS.EOF THEN
                    actionTimerList = actionTimerRS.GetRows()
                    actionTimerCount = uBound(actionTimerList, 2) + 1
                END IF
                actionTimerRS.Close

                IF actionTimerCount <= 0 THEN
                    Response.Write "<i>No timers have been set for this application.</i>"
                ELSE
                %>
                <table class="aa-kendo-grid">
                    <thead>
                        <tr>
                            <th>Reset</th>
                            <th>Timer</th>
                            <th>Status</th>
                            <th>Elapsed Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    FOR i = 0 TO actionTimerCount -1
                        actionTimerStart = actionTimerList(TIMER_START, i)
                        actionTimerEnd = actionTimerList(TIMER_END, i)
                        actionTimerStatus = GetActionTimerStatus(actionTimerStart, actionTimerEnd)
                        notificationPeriod = actionTimerList(NOTIFICATION_PERIOD, i)
                        countBusinessDays = actionTimerList(COUNT_BUSINESS_DAYS, i)

                        IF countBusinessDays THEN
                            timerLabel = "Business"
                        ELSE
                            timerLabel = "Calendar"
                        END IF

                        IF actionTimerStatus = 1 THEN
                            actionTimerElapsedTime = GetActionTimerDays(actionTimerStart, Now(), countBusinessDays)
                        ELSEIF actionTimerStatus = 2 THEN
                            actionTimerElapsedTime = GetActionTimerDays(actionTimerStart, actionTimerEnd, countBusinessDays)
                        END IF
                        %>
                        <tr>
                            <td >&nbsp;<input type="checkbox" class="k-checkbox" id="aa-action-timer-<%=i%>" name="actionTimer_<%=i%>" value="<%=actionTimerList(ACTION_TIMER_ID,i) %>"/><label for="aa-action-timer-<%=i%>" class="k-checkbox-label"></label></td>
                            <td><%=actionTimerList(ACTION_TIMER_DEF_NAME,i)%></td>
                            <td>
                                <ul class="aa-horizontal-list"><%
                                    IF actionTimerStatus = 1 AND actionTimerElapsedTime < notificationPeriod THEN
                                        %><li><i class="aa-icon far fa-clock fa-fw" aria-hidden="true" title="Running"></i></li><%
                                    ELSEIF actionTimerStatus = 1 AND actionTimerElapsedTime >= notificationPeriod THEN
                                        %><li><i class="aa-icon far fa-clock fa-fw" aria-hidden="true" title="Running"></i></li>
                                    <li><i class="aa-icon fas fa-exclamation fa-fw" aria-hidden="true" title="Time Elapsed"></i></li><%
                                    ELSEIF actionTimerStatus = 2 THEN
                                        %><li>Timer Stopped</li><%
                                    ELSE
                                        %><li><i class="aa-icon far fa-clock fa-fw" aria-hidden="true" title="Stopped"></i></li><%
                                    END IF
                                %></ul>
                            </td>
                            <td><%
                            IF actionTimerStatus > 0 THEN
                                %><%=actionTimerElapsedTime%>&nbsp;<%=timerLabel%> Day<% IF actionTimerElapsedTime <> "1" THEN %>s have<% ELSE %> has<% END IF %> Elapsed<%
                            ELSE
                                %>---<%
                            END IF
                            %></td>
                        </tr>
                        <%
                    NEXT ' ### i
                    %>
                    </tbody>
                </table>
                <% END IF ' ### IF actionTimerCount <= 0 %>
                </td>
            </tr>
            </tbody>
        </table>
</div>