<%
        ' ### NOTE: The subquery to get blocking purge elements has been removed (Ticket #3289) to improve speed and we can optimize it. ###
        loanApplicationQuery = _
            " SELECT" & _
            "   la.loanApplicationId, " & _
            "   la.applicationLocked," & _
            "   la.assignedLenderType, " & _
            "   la.assignedLenderId, " & _
            "   la.assignedLoanProcessorType, " & _
            "   la.assignedLoanProcessorId, " & _
            "   la.assignedAnalystType, " & _
            "   la.assignedAnalystId, " & _
            "   la.isRenewalApp, " & _
            "   la.applicationDate, " & _
            "   la.valuationDate, " & _
            "   la.requestedAmount, " & _
            "   la.fico, " & _
            "   la.interestRate, " & _
            "   la.primaryCollateralValue, " & _
            "   la.repaymentOption, " & _
            "   la.probability, " & _
            "   la.approvalId, " & _
            "   la.declinedReasonId, " & _
            "   lah.loanApplicationHistoryId," & _
            "   IsNull(l.loanAmount, '0.0') AS loanAmount," & _
            "   IsNull(l.commitmentAmount, 0.0) AS commitmentAmount," & _
            "   IsNull(cc.classificationName, '---') AS classificationName," & _
            "   cc.displayEmphasis," & _
            "   cc.displayColor," & _
            "   lac.approvalCondition," & _
            "   lac.postApprovalCondition," & _
            "   las.statusDescription," & _
            "   cas.creditAnalysisStatusDescription," & _
            "   apr.assignedApproverType," & _
            "   apr.assignedApproverId," & _
            "   l.PurgeStatus," & _
            "   l.PurgeStatusLocked," & _
            "   CONVERT(bit, 0) AS AccountBlockPurge," & _
            "   CAST(del.userFirstName + ' ' + del.userMiddleInitial + ' ' + del.userLastName as Varchar(100)) AS Delegate" & _
            " FROM" & _
            "   loanApplication AS la " & _
            "   INNER JOIN loan as l ON la.loanId = l.loanId " & _
            "   LEFT OUTER JOIN loanApplicationCondition AS lac ON la.loanApplicationId = lac.loanApplicationId " & _
            "   LEFT OUTER JOIN loanStatus AS las ON l.loanStatusId = las.statusId" & _
            "   LEFT OUTER JOIN creditAnalysisStatus AS cas ON cas.creditAnalysisStatusId = la.creditAnalysisStatusId" & _
            "   LEFT OUTER JOIN approval AS apr ON apr.approvalId = la.approvalId" & _
            "   LEFT OUTER JOIN creditClassification AS cc ON cc.classificationId = l.loanClassificationId" & _
            "   LEFT OUTER JOIN loanApplicationHistory AS lah ON lah.loanApplicationId = la.loanApplicationId" & _
            "   LEFT OUTER JOIN [user] AS del ON la.assignedLoanProcessorId = del.userId " &_
            " WHERE " & _
            "       la.loanId=" & dbFormatId(selectedLoanId)
        loanApplicationRS.Open loanApplicationQuery, db, adOpenStatic, adCmdText

Dim loanDelegate : loanDelegate = CheckForNull(loanApplicationRS("Delegate"))
Dim appLocked

IF checkfornull(loanApplicationRS("applicationLocked")) = "" THEN
    appLocked = false
ELSE
    appLocked = loanApplicationRS("applicationLocked")
END IF

' ### Check to see if the currently logged in user can take actions ###
Dim assignedLenderType : assignedLenderType = CheckForNull(loanApplicationRS("assignedLenderType"))
Dim assignedLenderId : assignedLenderId = CheckForNull(loanApplicationRS("assignedLenderId"))
Dim assignedLoanProcessorType : assignedLoanProcessorType = CheckForNull(loanApplicationRS("assignedLoanProcessorType"))
Dim assignedLoanProcessorId : assignedLoanProcessorId = CheckForNull(loanApplicationRS("assignedLoanProcessorId"))
Dim assignedAnalystType : assignedAnalystType = CheckForNull(loanApplicationRS("assignedAnalystType"))
Dim assignedAnalystId : assignedAnalystId = CheckForNull(loanApplicationRS("assignedAnalystId"))
Dim assignedApproverType : assignedApproverType = CheckForNull(loanApplicationRS("assignedApproverType"))
Dim assignedApproverId : assignedApproverId = CheckForNull(loanApplicationRS("assignedApproverId"))
Dim enableAction : enableAction = false

' ### Check if user is a member of a lender, loan processor, analyst, or approver group ###
Dim assignedToGroupRS : Set assignedToGroupRS = Server.CreateObject("ADODB.RecordSet")
Dim assignedToGroupQuery : assignedToGroupQuery = _
    " SELECT 1" & _
    " FROM" & _
    "   [userGroup] AS ug" & _
    "   LEFT OUTER JOIN [userGroup_user] AS ugu" & _
    "   ON ugu.userGroupId = ug.userGroupId" & _
    " WHERE" & _
    "   (ug.isAnalystGroup = 1 OR ug.isApproverGroup = 1 OR ug.isLenderGroup = 1 OR ug.isLoanProcessorGroup = 1)" & _
    "   AND ugu.userId = " & dbFormatId(Session("userId"))
assignedToGroupRS.Open assignedToGroupQuery, db, adOpenStatic, adCmdText
IF assignedToGroupRS.RecordCount > 0 THEN
    enableAction = true
END IF
assignedToGroupRS.Close

' ### Enable Actions based on user permissions ###
IF Session("loanapp.isAdmin") OR Session("isSuperUser") THEN
    enableAction = true
END IF

' ### Enable actions if user approval security is enabled for 
IF Session("isAnalyst") OR Session("isApprover") OR Session("isLender") OR Session("isDelegate") THEN
    enableAction = true
END IF

Dim isRenewalApp : isRenewalApp = loanApplicationRS("isRenewalApp")
Dim renewalLabel : renewalLabel = ""
IF isRenewalApp THEN renewalLabel = "&nbsp; (<i>Renewal Application</i>) &nbsp;"
%>
<form action="customer.asp" name="frmHiddenLoanId" method="post">
    <input type="hidden" name="hidCustomerId" id="hidCustomerId" value="<%=loanRS("customerId")%>" />
    <input type="hidden" name="hidLoanId" id="hidLoanId" value="<%=loanRS("loanId")%>" />
</form>
<table class="aa-loan-header">
    <tr>
        <td class="<%=loanClassStyle%>" colspan="2">Application Number </td>
        <td class="displaylabel" colspan="5">
            <ul class="aa-loan-header-list">
                <% IF Session("acculoan.enablePurge") = 1 THEN %>
                    <% IF loanRS("PurgeStatus") OR loanRS("AccountBlockPurge") OR (NOT loanRS("PurgeStatus") AND loanRS("PurgeStatusLocked")) THEN %>
                        <li><%=GetPurgeStatusIcon(loanApplicationRS("PurgeStatus"), loanApplicationRS("PurgeStatusLocked"), loanApplicationRS("AccountBlockPurge")) %></li>
                    <% END IF %>
                <% END IF %>
                <% IF appLocked THEN %><li><i class="aa-icon fas fa-lock fa-fw" title="This application is locked" aria-hidden="true"></i></li><% END IF %>
                <li><%=loanRS("loanNumber") %> <%=renewalLabel%></li>
                <% IF Session("loanapp.isAdmin") OR Session("loanapp.allowEdit") OR Session("isSuperUser") THEN %>
                <li><a href="customerscan.asp?state=INITIAL&action=EDITLOAN&customerId=<%=loanRS("customerId")%>&loanId=<%=loanRS("loanId")%>&bankId=<%=CustomerRS("bankId")%>&accountClassId=<%=selectedAccountClassId%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                <% END IF %>
                <% IF enableAction AND NOT appLocked THEN %>
                <li><a href="javascript:void(0);" onclick="openKendoDialog('Take Action', 'processactionselect.asp?loanApplicationId=<%=loanApplicationRS("loanApplicationId")%>', 600, 800);" class="aa-command-link"><i class="aa-icon fas fa-bolt fa-fw" title="Take Action" aria-hidden="true"></i></a></li>
                <% END IF %>
                <% IF CheckForNull(loanApplicationRS("loanApplicationHistoryId")) <> "" THEN %>
                <li><a href="javascript:void(0);" onclick="openKendoDialog('Application History', 'viewapplicationhistory.asp?loanApplicationId=<%=loanApplicationRS("loanApplicationId")%>', 500, 700);" class="aa-command-link"><i class="aa-icon fas fa-history fa-fw" title="View Application History" aria-hidden="true"></i></a></li>
                <% END IF %>
            </ul>
        </td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%>" colspan="2">Borrower Type </td>
        <td id="displayedBorrowerTypeDescription" class="displaylabel" colspan="5"><%=borrowerType%></td>
    </tr>
    <% IF Trim(loanRS("loanDescription")) <> "" THEN %>
    <tr>
        <td class="<%=loanClassStyle%>" colspan="2">Loan Description </td>
        <td class="displaylabel" colspan="5"><%=loanRS("loanDescription")%></td>
    </tr>
    <% END IF %>
    <%
    IF Len(loanRS("Address1")) > 0 THEN strAddr = loanRS("Address1") & ", "
    IF Len(loanRS("Address2")) > 0 THEN strAddr = strAddr & loanRS("Address2") & ", "
    IF Len(loanRS("city")) > 0 THEN strAddr = strAddr & loanRS("city") & ", "
    IF Len(loanRS("state")) > 0 THEN strAddr = strAddr & loanRS("state") & ", "
    IF Len(strAddr) > 0 THEN
        strAddr = Left(strAddr, Len(strAddr)-2)
        strAddr = strAddr & ", " & loanRS("zipcode") 
    END IF
    IF Trim(Replace(strAddr, ",", "") & "") <> "" THEN
    %>
    <tr>
        <td class="<%=loanClassStyle%>" colspan="2">Loan Main Address</td>
        <td colspan="5" class="displaylabel"><%=strAddr%></td>
    </tr>
    <% END IF %>
    <tr>
        <td class="<%=loanClassStyle%> aa-tac" colspan="3">Loan Type</td>
        <td class="<%=loanClassStyle%> aa-tac">Branch</td>
        <td class="<%=loanClassStyle%> aa-tac">Loan Officer</td>
        <td class="<%=loanClassStyle%> aa-tac">Application Date</td>
        <td class="<%=loanClassStyle%> aa-tac">Valuation Date</td>
    </tr>
    <tr>
        <td colspan="3" class="displaylabel aa-tac"><%=loanRS("loantypedescription")%></td>
        <td class="displaylabel aa-tac"><%=loanRS("branchName")%></td>
        <td class="displaylabel aa-tac"><%=loanRS("officername")%></td>
        <td class="displaylabel aa-tac"><%=loanApplicationRS("applicationDate")%></td>
        <td class="displaylabel aa-tac"><% IF CheckForNull(loanApplicationRS("valuationDate")) = "" THEN %>---<% ELSE %><%=loanApplicationRS("valuationDate")%><% END IF %></td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%> aa-tac" colspan="3">Requested Amount</td>
        <td class="<%=loanClassStyle%> aa-tac">Credit Score</td>
        <td class="<%=loanClassStyle%> aa-tac">Interest Rate</td>
        <td class="<%=loanClassStyle%> aa-tac">Primary Collateral Value</td>
        <td class="<%=loanClassStyle%> aa-tac">Repayment Option</td>
    </tr>
    <tr>
        <%
        Dim reqAmt
        IF checkfornull(loanApplicationRS("requestedAmount")) = "" THEN
            reqAmt = 0
        ELSE
            reqAmt = loanApplicationRS("requestedAmount")
        END IF
        %>
        <td class="displaylabel aa-tac" colspan="3"><%=FormatCurrency(reqAmt)%></td>
        <td class="displaylabel aa-tac"><%=loanApplicationRS("fico")%></td>
        <td class="displaylabel aa-tac"><% IF CheckForNull(loanApplicationRS("interestRate")) = "" THEN %>---<% ELSE %><%=loanApplicationRS("interestRate")%><% END IF %></td>
        <%
        Dim priColl
        IF Checkfornull(loanApplicationRS("primaryCollateralValue")) = "" THEN
            priColl = "0.0"
        ELSE
            priColl = loanApplicationRS("primaryCollateralValue")
        END IF
        %>
        <td class="displaylabel aa-tac"><%=FormatCurrency(priColl)%></td>
        <td class="displaylabel aa-tac"><% IF Trim(CheckForNull(loanApplicationRS("repaymentOption"))) = "" THEN %>---<% ELSE %><%=loanApplicationRS("repaymentOption")%><% END IF %></td>
    </tr>
    <%
    Dim commitmentAmount : commitmentAmount = loanApplicationRS("commitmentAmount")
    IF IsNumeric(commitmentAmount) THEN
        commitmentAmount = FormatCurrency(commitmentAmount)
    ELSE
        commitmentAmount = "---"
    END IF

    Dim loanAmount : loanAmount = loanApplicationRS("loanAmount")
    IF IsNumeric(loanAmount) THEN
        loanAmount = FormatCurrency(loanAmount)
    ELSE
        loanAmount = "---"
    END IF

    ' ### Build format for Risk classification ###
    IF loanApplicationRS("displayEmphasis") THEN
        classificationStyle = "font-weight: bold"
    ELSE
        classificationStyle = "font-weight: normal"
    END IF
    classificationStyle = classificationStyle & "; color: " & loanApplicationRS("displayColor")
    classificationName = loanApplicationRS("classificationName")
    %>
    <tr>
        <td class="<%=loanClassStyle%> aa-tac" colspan="3">Commitment</td>
        <td class="<%=loanClassStyle%> aa-tac" colspan="2">Balance</td>
        <td class="<%=loanClassStyle%> aa-tac" colspan="2">Risk</td>
    </tr>
    <tr>
        <td class="aa-tac" colspan="3"><%=commitmentAmount%></td>
        <td class="aa-tac" colspan="2"><%=loanAmount%></td>
        <td class="aa-tac" colspan="2"><div style="<%=classificationStyle%>"><%=classificationName%></div></td>
    </tr>
    <tr>
        <td class="<%=loanClassStyle%> aa-tac">NAICS Code</td>
        <td class="<%=loanClassStyle%> aa-tac">Collateral<br/>Code</td>
        <td class="<%=loanClassStyle%> aa-tac">Call<br/>Code</td>
        <td class="<%=loanClassStyle%> aa-tac">Class<br/>Code</td>
        <td class="<%=loanClassStyle%> aa-tac">Purpose<br/>Code</td>
        <td class="<%=loanClassStyle%> aa-tac">Type<br/>Code</td>
        <td class="<%=loanClassStyle%> aa-tac">Probability of<br/>Closing</td>
    </tr>
    <tr>
        <td class="aa-tac"><% IF CheckForNull(loanRS("coreNaicsCode")) = "" THEN %>---<% ELSE %><%=loanRS("coreNaicsCode")%><% END IF %></td>
        <td class="aa-tac"><% IF CheckForNull(loanRS("coreCollateralCode")) = "" THEN %>---<% ELSE %><%=loanRS("coreCollateralCode")%><% END IF %></td>
        <td class="aa-tac"><% IF CheckForNull(loanRS("coreCollCode")) = "" THEN %>---<% ELSE %><%=loanRS("coreCollCode")%><% END IF %></td>
        <td class="aa-tac"><% IF CheckForNull(loanRS("coreClassCode")) = "" THEN %>---<% ELSE %><%=loanRS("coreClassCode")%><% END IF %></td>
        <td class="aa-tac"><% IF CheckForNull(loanRS("corePurposeCode")) = "" THEN %>---<% ELSE %><%=loanRS("corePurposeCode")%><% END IF %></td>
        <td class="aa-tac"><% IF CheckForNull(loanRS("coreTypeCode")) = "" THEN %>---<% ELSE %><%=loanRS("coreTypeCode")%><% END IF %></td>
        <td class="aa-tac"><% IF CheckForNull(loanApplicationRS("probability")) = "" THEN %>---<% ELSE %><%=loanApplicationRS("probability")%><% END IF %></td>
    </tr>
    <%
    Dim actionTimerStart, actionTimerEnd, actionTimerElapsedTime, actionTimerStatus
    Dim notificationPeriod, countBusinessDays, timerLabel
    Dim actionTimerList, actionTimerCount
    Dim actionTimerQuery, actionTimerRS
    Set actionTimerRS = Server.CreateObject("ADODB.RecordSet")

    actionTimerQuery = _
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
        "   actionTimer AS atmr INNER JOIN actionTimerDefinition AS atd" & _
        "       ON atmr.actionTimerDefId=atd.actionTimerDefId" & _
        " WHERE" & _
        "   atmr.loanApplicationId=" & dbFormatId(loanApplicationRS("loanApplicationId")) & _
        " ORDER BY" & _
        "   atd.notificationPeriod DESC, atd.actionTimerDefName ASC"
    actionTimerRS.Open actionTimerQuery, db, adOpenStatic, adCmdText

    actionTimerCount = -1
    IF NOT actionTimerRS.EOF THEN
        actionTimerList = actionTimerRS.GetRows()
        actionTimerCount = actionTimerRS.RecordCount
    END IF
    actionTimerRS.Close
    %>
    <tr>
        <td colspan="7" class="<%=loanClassStyle%>"><b>Timers</b></td>
    </tr>
    <tr>
        <td colspan="7" class="displaylabel pb pt">
        <% IF actionTimerCount <= 0 THEN %>
        <i>No timers have been set for this application.</i>
        <% ELSE %>
        <% IF actionTimerCount > 0 THEN %>
        <div id="application-timer-header">
            <ul>
                <li><a href="javascript:void(0);" onclick="expandDiv('divActionTimers', 'timerExpander');"><i class="aa-icon fas fa-plus-square fa-fw" id="timerExpander" aria-hidden="true"></i></a></li>
                <li><a href="javascript:void(0);" onclick="expandDiv('divActionTimers', 'timerExpander');" style="text-decoration:none; color:#000" id="timerLinkId">View All Timers</a></li>
            </ul>
        </div>
        <% END IF %>
        <div id="divActionTimers">
            <table>
                <tr class="aa-column-headers">
                    <td>Timer</td>
                    <td class="aa-tac">Status</td>
                    <td>Elapsed Time</td>
                </tr>
                <%
                FOR i = 0 TO actionTimerCount - 1
                    actionTimerDefault = actionTimerList(2,i)
                    actionTimerStart = actionTimerList(5,i)
                    actionTimerEnd = actionTimerList(6,i)
                    actionTimerStatus = GetActionTimerStatus(actionTimerStart, actionTimerEnd)
                    notificationPeriod = actionTimerList(3,i)
                    countBusinessDays = actionTimerList(7,i)

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

                    Dim rowColor : rowColor = "#F5F5F5"
                    IF (i MOD 2 = 0) THEN rowColor = "#E2E0E2"
                    %>
                    <tr>
                        <td><%=actionTimerList(1,i)%></td>
                        <%
                        Dim timerTitle : timerTitle = ""
                        Dim timerIcon : timerIcon = ""
                        Dim showWarning : showWarning = ""
                        IF actionTimerStatus = 1 AND actionTimerElapsedTime < notificationPeriod THEN
                            timerTitle = "Running"
                            timerIcon = "fa-bell"
                        ELSEIF actionTimerStatus = 1 AND actionTimerElapsedTime >= notificationPeriod THEN
                            timerTitle = "Running"
                            timerIcon = "fa-bell"
                            showWarning = "&nbsp;&nbsp;<i class=""aa-icon fas fa-exclamation-triangle fa-fw"" aria-hidden=""true""></i>"
                        ELSEIF actionTimerStatus = 2 THEN
                            timerTitle = "Timer Stopped"
                            timerIcon = "fa-bell-slash"
                        ELSE
                            timerTitle = "Stopped"
                            timerIcon = "fa-bell-slash"
                        END IF
                        %>
                        <td class="aa-tac"><i class="aa-icon fa <%=timerIcon%> fa-fw" title="<%=timerTitle%>" aria-hidden="true"></i><%=showWarning%></td>
                        <%
                        IF actionTimerStatus > 0 THEN
                            Dim daysLeft : daysLeft = " has"
                            IF actionTimerElapsedTime <> "1" THEN daysLeft = "s have"
                            Response.Write "<td>" & actionTimerElapsedTime & "&nbsp;" & timerLabel & " Day" & daysLeft & " Elapsed</td>"
                        ELSE
                            Response.Write "<td>---</td>"
                        END IF
                        %>
                    </tr>
                    <% NEXT ' ### i %>
                </table>
            </div>
            <% END IF %>
        </td>
    </tr>
    <%
    IF checkfornull(loanApplicationRS("assignedLenderId")) <> "" THEN
        Dim lenderRS : Set lenderRS = Server.CreateObject("ADODB.RecordSet")
        Dim lenderQuery : lenderQuery = _
            " SELECT" & _
            "   u.userFirstName + ' ' + u.userMiddleInitial + ' ' + u.userLastName AS targetName," & _
            "   'user' AS targetType" & _
            " FROM" & _
            "   [user] AS u" & _
            " WHERE" & _
            "   u.userId = " & dbformatid(loanApplicationRS("assignedLenderId")) & _
            " UNION" & _
            " SELECT" & _
            "   g.userGroupName As targetName," & _
            "   'group' AS targetType" & _
            " FROM" & _
            "   userGroup AS g " & _
            " WHERE" & _
            "   g.userGroupId = " & dbformatid(loanApplicationRS("assignedLenderId"))
        lenderRS.Open lenderQuery, db, adOpenStatic, adCmdText
        Dim lenderIcon
        Dim lenderName : lenderName = lenderRS("targetName")
        Dim targetType : targetType = lenderRS("targetType")
        IF targetType = "user" THEN
            lenderIcon = "fa-user"
        ELSE
            lenderIcon = "fa-users"
        END IF
        lenderRS.Close()
    ELSE
        lenderIcon = "fa-times"
        lenderName = "Unassigned"
    END IF
    %>
    <tr>
        <td colspan="3" class="<%=loanClassStyle%> aa-tac">Assigned Lender</td>
        <td colspan="2" class="<%=loanClassStyle%> aa-tac">Assigned Analyst</td>
        <td class="<%=loanClassStyle%> aa-tac">Assigned Approver</td>
        <td class="<%=loanClassStyle%> aa-tac">Loan Delegate</td>
    </tr>
    <tr>
        <td colspan="3" class="displaylabel" align="center">
        <table>
            <tr>
                <% IF lenderIcon <> "" THEN %>
                <td valign="middle"><i class="aa-icon fa <%=lenderIcon%> fa-fw" aria-hidden="true"></i></td>
                <% END IF %>
                <td align="left">&nbsp;<%=lenderName%></td>
            </tr>
        </table>
        </td>
        <%
        Dim analystName, analystIcon
        IF checkfornull(loanApplicationRS("assignedAnalystId")) <> "" THEN
            Dim analystRS : Set analystRS = Server.CreateObject("ADODB.RecordSet")
            Dim analystQuery : analystQuery = _
                " SELECT" & _
                " 	u.userFirstName + ' ' + u.userMiddleInitial + ' ' + u.userLastName AS targetName," & _
                " 	'user' AS targetType" & _
                " FROM" & _
                " 	[user] AS u" & _
                " WHERE" & _
                " 	u.userId =" & dbformatid(loanApplicationRS("assignedAnalystId")) & _
                " UNION" & _
                " SELECT" & _
                " 	g.userGroupName As targetName," & _
                " 	'group' AS targetType" & _
                " FROM" & _
                " 	userGroup AS g" & _
                " WHERE" & _
                " 	g.userGroupId =" & dbformatid(loanApplicationRS("assignedAnalystId"))
            analystRS.Open analystQuery, db, adOpenStatic, adCmdText
            analystName = analystRS("targetName")
            targetType = analystRS("targetType")
            IF targetType = "user" THEN
                analystIcon = "fa-user"
            ELSE
                analystIcon = "fa-users"
            END IF
            analystRS.Close()
        ELSE
            analystIcon = "fa-times"
            analystName = "Unassigned"
        END IF
        %>
        <td colspan="2" class="displaylabel" align="center">
        <table>
            <tr>
                <% IF analystIcon <> "" THEN %>
                <td valign="middle"><i class="aa-icon fa <%=analystIcon%> fa-fw" aria-hidden="true"></i></td>
                <% END IF %>
                <td>&nbsp;<%=analystName%></td>
            </tr>
        </table>
        </td>
        <%
        Dim approverIcon : approverIcon = "fa-times"
        Dim approverName : approverName = "Unassigned"
        Dim approvalStatus : approvalStatus = ""
        Dim approver : approver = ""

        IF CheckForNull(loanApplicationRS("approvalId")) <> "" THEN
            Dim approvalRS : Set approvalRS = Server.CreateObject("ADODB.RecordSet")
            Dim approvalQuery : approvalQuery = _
                " SELECT" & _
                "   ap.assignedApproverId," & _
                "   aps.approvalStatusDescription" & _
                " FROM" & _
                "   approval AS ap INNER JOIN approvalStatus AS aps" & _
                "       ON ap.approvalStatusId=aps.approvalStatusId" & _
                " WHERE" & _
                "   ap.approvalId=" & dbFormatId(loanApplicationRS("approvalId"))
            approvalRS.Open approvalQuery, db, adOpenStatic, adCmdText
            IF NOT approvalRS.EOF THEN
                approvalStatus = approvalRS("approvalStatusDescription")
                approver = approvalRS("assignedApproverId")
            END IF
            approvalRS.Close()
        END IF

        Dim approverRS : Set approverRS = Server.CreateObject("ADODB.RecordSet")
        IF approver <> "" THEN
            Dim approverQuery : approverQuery = _
                " SELECT" & _
                "   u.userFirstName + ' ' + u.userMiddleInitial + ' ' + u.userLastName AS targetName," & _
                "   'user' AS targetType" & _
                " FROM" & _
                "   [user] AS u" & _
                " WHERE" & _
                "   u.userId = " & dbformatid(approver) & _
                " UNION" & _
                " SELECT" & _
                "   g.userGroupName As targetName," & _
                "   'group' AS targetType" & _
                " FROM" & _
                "   userGroup AS g" & _
                " WHERE" & _
                "   g.userGroupId = " & dbformatid(approver)
            approverRS.Open approverQuery, db, adOpenStatic, adCmdText
            approverName = approverRS("targetName")
            targetType = approverRS("targetType")

            IF targetType = "user" THEN
                approverIcon = "fa-user"
            ELSE
                approverIcon = "fa-users"
            END IF

            approverRS.Close()
        END IF
        %>
        <td class="displaylabel" align="center">
        <table cellpadding="0" cellspacing="0">
            <tr>
                <td valign="middle"><i class="aa-icon fa <%=approverIcon%> fa-fw" aria-hidden="true"></i></td>
                <td align="left" class="pl"><%=approverName%></td>
            </tr>
        </table>
        </td>
        <%
        IF Trim(loanDelegate & "") = "" THEN
            delegateIcon = "fa-times"
            delegateName = "Unassigned"
        ELSE
            delegateIcon = "fa-user"
            delegateName = loanDelegate
        END IF
        %>
        <td class="displaylabel" align="center">
        <table cellpadding="0" cellspacing="0">
            <tr>
                <td valign="middle"><i class="aa-icon fa <%=delegateIcon%> fa-fw" aria-hidden="true"></i></td>
                <td align="left">&nbsp;<%=delegateName%></td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td colspan="3" class="<%=loanClassStyle%> aa-tac">Declined Reason</td>
        <td colspan="2" class="<%=loanClassStyle%> aa-tac">Pre Closing</td>
        <td class="<%=loanClassStyle%> aa-tac" colspan="2">Post Closing</td>
    </tr>
    <tr>
        <td colspan="3" class="aa-tac">
        <%
        IF CheckForNull(loanApplicationRS("declinedReasonId")) <> "" THEN
            Dim declinedRS : Set declinedRS = Server.CreateObject("ADODB.RecordSet")
            Dim declinedQuery : declinedQuery = _
                " SELECT declinedReasonDescription FROM declinedReason WHERE declinedReasonId = " & dbFormatId(loanApplicationRS("declinedReasonId"))
            declinedRS.Open declinedQuery, db
            declinedReason = checkfornull(declinedRS("declinedReasonDescription"))
            declinedRS.Close
            Set declinedRS = Nothing
            Response.Write declinedReason
        ELSE
            Response.Write "---"
        END IF
        %></td>
        <td colspan="2" class="aa-tac"><% IF CheckForNull(loanApplicationRS("approvalCondition")) <> "" THEN %><%=loanApplicationRS("approvalCondition")%><% ELSE %>---<% END IF %></td>
        <td class="aa-tac" colspan="2"><% IF CheckForNull(loanApplicationRS("postApprovalCondition")) <> "" THEN %><%=loanApplicationRS("postApprovalCondition")%><% ELSE %>---<% END IF %></td>
    </tr>
    <tr>
        <td colspan="3" class="<%=loanClassStyle%> aa-tac">Application Status</td>
        <td colspan="2" class="<%=loanClassStyle%> aa-tac">Analysis Status</td>
        <td class="<%=loanClassStyle%> aa-tac" colspan="2">Approval Status</td>
    </tr>
    <tr>
        <td colspan="3" class="aa-tac"><%=loanRS("statusdescription")%></td>
        <td colspan="2" class="aa-tac"><% if IsNull(loanApplicationRS("creditAnalysisStatusDescription")) then %>---<% else %><%=loanApplicationRS("creditAnalysisStatusDescription")%><% end if %></td>
        <td class="aa-tac" colspan="2"><%=approvalStatus%></td>
    </tr>
    <!-- #include file="cust_accountheaderflexfields.inc" -->
</table>
<% loanApplicationRS.Close %>