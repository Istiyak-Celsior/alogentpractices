<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<!-- #include file="../getUserBranchSecurityArrayMultiBank.inc" -->
<%
' ### GET USER VIEW PREFERENCES ###
' 0 - My Active Exceptions (default)
' 1 - Other Assigned User
' 2 - Loan Officer

Dim filterBy : filterBy = Session("activeExceptionDisplayFilter")
Dim strFilterList : strFilterList = Session("activeExceptionFilterList")
Dim filterByLabel : filterByLabel = "My Exceptions"

' ### If setting not in session then check cookies, otherwise use default ###
IF filterBy = "" THEN
    filterBy = Request.Cookies(Session("userLogin") & ".acculoan.activeExceptionDisplayFilter")
    strFilterList = Request.Cookies(Session("userLogin") & ".acculoan.activeExceptionFilterList")

    IF filterBy = "" THEN
        ' ### Check old cookie value before making it user specific. ###
        IF Request.Cookies("acculoan.activeExceptionDisplayFilter") <> "" THEN
            filterBy = Request.Cookies("acculoan.activeExceptionDisplayFilter")
            strFilterList = Request.Cookies("acculoan.activeExceptionFilterList")
        ELSE
            filterBy = 0
            strFilterList = ""
        END IF

        ' ### Save settings ###
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionDisplayFilter") = filterBy
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionDisplayFilter").expires =  #12/31/2030#
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionFilterList") = strFilterList
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionFilterList").expires =  #12/31/2030#
    END IF

    Session("activeExceptionDisplayFilter") = filterBy
    Session("activeExceptionFilterList") = strFilterList
END IF

IF filterBy = "1" THEN
    filterByLabel = "Officer Filter"
ELSEIF filterBy = "2" THEN
    filterByLabel = "Assigned User Filter"
END IF
%>
<div class="aa-active-task-dashboard-widget">
    <div class="aa-panel-header">
        <div><a href="javascript:void(0);" data-bind="click: openFilterSettings">Exception Filter Settings</a></div>
        <div class="aa-color-info"><%=filterByLabel%></div>
    </div>
    <table class="aa-panel-table">
        <%
        Dim filterClause : filterClause = ""
        IF filterBy = 0 THEN
            ' ### Filter by current user ###
            filterClause = _
                " AND (" & _
                "   ex.assignedUserId = " & dbFormatId(Session("userId")) & _
                " )"
        ELSEIF filterBy = 1 THEN
            ' ### Filter by Loan Officer ###
            filterClause = BuildOfficerFilter(strFilterList)
        ELSEIF filterBy = 2 THEN
            ' ### Filter by Assigned User ###
            filterClause = BuildAssignedUserFilter(strFilterList)
        END IF
    
        Dim activeExceptionRS : Set activeExceptionRS = Server.CreateObject("ADODB.RecordSet")
        Dim activeExceptionQuery : activeExceptionQuery = _
            " SELECT " & _
            "   c.customerId, " & _
            "   c.customerNumber, " & _
            "   c.customerName, " & _
            "   c.customerBranchId, " & _
            "   l.loanId, " & _
            "   l.loanBranchId, " & _
            "   l.loanNumber, " & _
            "   l.isCollateralYN, " & _
            "   ISNULL(ls.isApplicationStatus, 0) AS isApplicationStatus, " & _
            "   ac.accountClassCode, " & _
            "   col.collateralSequence, " & _
            "   ed.exceptionDefName, " & _
            "   ed.exceptionDefType, " &_ 
            "   ex.exceptionId, " & _
            "   ex.exceptionState, " & _
            "   ex.reminderDate, " & _
            "   ex.assignedUserId, " & _
            "   t.TransferableByUser, " & _
            "   t.AssignActionTaker " & _
            " FROM " & _
            "   viewExceptions AS vex INNER JOIN exception AS ex ON vex.exceptionId = ex.exceptionId" & _
            "   INNER JOIN exceptionDefinition AS ed ON ex.exceptionDefId = ed.exceptionDefId " & _
            "   INNER JOIN customer AS c ON c.customerId = ex.customerId " & _
            "   LEFT OUTER JOIN loan AS l ON l.loanId = ex.loanId " & _
            "   LEFT OUTER JOIN loanStatus AS ls ON ls.statusId = l.loanStatusId " & _
            "   LEFT OUTER JOIN accountClass AS ac ON ac.accountClassId = ls.accountClassId " & _
            "   LEFT OUTER JOIN collateral AS col ON col.collateralLoanId = l.loanId " & _
            "   LEFT OUTER JOIN Task AS t ON t.TaskId = ex.TaskId " & _
            " WHERE " & _
            "   ex.exceptionState = 'Y' " & _
            "   AND CASE WHEN ex.loanId IS NOT NULL THEN l.ignoreExceptionsYN ELSE c.ignoreExceptionsYN END = 'N' " & _
            "   AND ex.statusType = 'required' " & _
            "   AND ed.computationType = 'manual' " & _
            filterClause & _
            " ORDER BY " & _
            "   c.customerName, " & _
            "   IsNull(ac.accountClassSortOrder, 0), " & _
            "   l.loanNumber, " & _
            "   ed.exceptionDefName"
        activeExceptionRS.Open activeExceptionQuery, db
        IF activeExceptionRS.EOF THEN
            %><tr class="aa-no-results">
                <td>There are no active Task Exceptions based on your current Exception Filter Settings.</td>
            </tr><%
        ELSE
            %><tr class="aa-header">
                <td>Customer</td>
                <td>Task</td>
                <td class="aa-tac">Overdue</td>
                <td class="aa-tac">Action</td>
            </tr>
            <%
            Dim loanBranchId, permissionArray, hasBranchPermission, allowReassignException, allowResolveTask
            Dim prevCustomerId : prevCustomerId = ""
            Dim prevLoanId : prevLoanId = ""
    
            DO WHILE NOT activeExceptionRS.EOF
                Dim loanId : loanId = activeExceptionRS("loanId")
                Dim isCollateralYN : isCollateralYN = activeExceptionRS("isCollateralYN")
                Dim isApplicationStatus : isApplicationStatus = activeExceptionRS("isApplicationStatus")
                Dim accountClassCode : accountClassCode = activeExceptionRS("accountClassCode")
    
                ' ### Setup for Session permission checks. ###
                IF loanId = "" THEN
                    accountClassCode = "credit"
                ELSEIF isApplicationStatus AND IsCollateralYN = "N" THEN
                    accountClassCode = "loanapp"
                END IF
    
                hasBranchPermission = False
    
                ' ### NOTE: the following iterates through the user's allowable branch access and compares
                ' it to the customerBranchId or loanBranchId to see if the record should be displayed. ###
    
                ' ### NOTE: Bypassing branch security for now as it does not make sense ###
                IF true OR Session("isSuperUser") THEN
                    hasBranchPermission = true
                ELSE
                    FOR permissionArray = 0 TO userBranchSecurityRows
                        permissionBranchID = userBranchSecurityArray(0, permissionArray)
                        IF permissionBranchID = activeExceptionRS("customerBranchId") OR permissionBranchID = activeExceptionRS("loanBranchId") THEN
                            hasBranchPermission = True
                        END IF
                    NEXT
                END IF
    
                IF hasBranchPermission THEN
                    Dim customerId : customerId = CheckForNull(activeExceptionRS("customerId"))
                    Dim customerNumber : customerNumber = CheckForNull(activeExceptionRS("customerNumber"))
                    Dim customerName : customerName = CheckForNull(activeExceptionRS("customerName"))
                    loanId = CheckForNull(activeExceptionRS("loanId"))
                    Dim loanNumber : loanNumber = CheckForNull(activeExceptionRS("loanNumber"))
                    isCollateralYN = activeExceptionRS("isCollateralYN")
                    Dim collateralSequence : collateralSequence = CheckForNull(activeExceptionRS("collateralSequence"))
                    Dim exceptionId : exceptionId = activeExceptionRS("exceptionId")
                    Dim exceptionDefType : exceptionDefType = activeExceptionRS("exceptionDefType")
                    Dim exceptionDefName : exceptionDefName = activeExceptionRS("exceptionDefName")
                    Dim exceptionState : exceptionState = activeExceptionRS("exceptionState")
                    Dim transferableByUser : transferableByUser = activeExceptionRS("TransferableByUser")
                    Dim reminderDate : reminderDate = CheckForNull(activeExceptionRS("reminderDate"))
                    Dim assignedUserId : assignedUserId = activeExceptionRS("assignedUserId")
    
                    IF IsNull(assignedUserId) THEN assignedUserId = ""
    
                    ' ### Set the default ability to reassign the exception/task's assigned user ###
                    allowReassignException = False
    
                    ' ### Always allow Super User and AccountClass admins to reassign. ###
                    IF Session("isSuperUser") OR Session(accountClassCode & ".isAdmin") THEN
                        allowReassignException = true
                    END IF
    
                    ' ### Always allow Exception Editors or better of Exceptions that are not
                    ' associated with the Task transferable flag (has a NULL value)
                    ' to reassign assigned users. ###
                    IF Session("permissionException") >= 2 AND IsNull(transferableByUser) THEN
                        allowReassignException = True
                    END IF
    
                    ' ### Finally check to see if the Task exception is transferable and the user
                    ' is the currently assigned user. ###
                    IF NOT IsNull(transferableByUser) THEN
                        IF cBool(transferableByUser) AND cStr(Session("userId")) = cStr(assignedUserId) THEN
                            allowReassignException = True
                        END IF
                    END IF
    
                    ' ### Set the ability to resolve the task exception in the window. ###
                    allowResolveTask = False
                    IF Session("isSuperUser") OR Session(accountClassCode & ".isAdmin") _
                        OR Session("permissionException") >= 2 _
                        OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                        allowResolveTask = True
                    END IF
    
                    Dim customerUrl : customerUrl = ""
                    IF isCollateralYN = "Y" THEN
                        customerUrl = "customer.asp?customerId=" & customerId & "&loanId=" & parentLoanId & "&collateralId=" & loanId & "&collateralTab=exception#collateralHeader"
                    ELSEIF loanId <> "" THEN
                        customerUrl = "customer.asp?customerId=" & customerId & "&loanId=" & loanId& "&loanTab=exception#loanHeader"
                    ELSE
                        customerUrl = "customer.asp?customerId=" & customerId & "&creditTab=exception#creditHeader"
                    END IF
    
                    IF cStr(prevCustomerId) <> cStr(customerId) THEN
                        prevCustomerId = customerId
                        %><tr>
                            <td colspan="4"><a name="dashboard<%=customerId%>" href="<%=customerUrl%>"><%=customerName%> (<%=customerNumber%>)</a></td>
                        </tr><%
                    END IF
    
                    IF cStr(prevLoanId) <> cStr(loanId) THEN
                        prevLoanId = loanId
                        IF isCollateralYN = "Y" THEN loanNumber = Left(loanNumber, InStr(loanNumber, "_")-1) & " (Collateral " & collateralSequence & ")"
                        IF Trim(loanId & "") <> "" THEN
                        %><tr class="aa-loan-indent">
                            <td colspan="4"><a name="dashboard<%=loanId%>" href="<%=customerUrl%>"><%=loanNumber%></a></td>
                        </tr><%
                        END IF
                    END IF
    
                    Dim dashboardArg : dashboardArg = ""
                    IF loanId <> "" THEN
                        dashboardArg = "dashboard" & loanId
                    ELSE
                        dashboardArg = "dashboard" & customerId
                    END IF
                    %><tr class="aa-exception-def-indent">
                        <td colspan="2"><%=exceptionDefName%></td><%
                        Dim daysOverDue : daysOverDue = ""
                        IF IsDate(reminderDate) THEN
                            daysOverDue = "---"
    
                            ' ### NOTE: The following is a special data check for custom LQAS import exceptions
                            ' so that we ignore reminderDates of 1/1/9999 and we care only about overdue ###
                            ' ## Reminder dates. ###
                            IF reminderDate <> cDate("1/1/9999") AND cDate(reminderDate) < Now() THEN
                                daysOverDue = DateDiff("d", reminderDate, Now())
                            END IF
                        ELSE
                            daysOverDue = "---"
                        END IF
                        %><td class="aa-tac"><%=daysOverdue%></td>
                        <td class="aa-tac">
                            <ul class="icon-list">
                                <% IF allowReassignException THEN %><li><a href="javascript:void(0);" data-bind="click: reassignTask" data-exceptionid="<%=exceptionId%>"><i class="aa-icon fas fa-user fa-fw" title="Reassign Task" aria-hidden="true"></i></a></li><% END IF %>
                                <% IF allowResolveTask THEN %><li><a href="javascript:void(0);" data-bind="click: resolveTask" data-exceptionid="<%=exceptionId%>"><i class="aa-icon fas fa-check fa-fw" title="Resolve Task" aria-hidden="true"></i></a></li><% END IF %>
                            </ul>
                        </td>
                    </tr>
                    <%
                END IF ' ### IF hasBranchPermission
                activeExceptionRS.MoveNext()
            LOOP
        END IF ' ### activeExceptionRS.RecordCount = 0
        activeExceptionRS.Close()
        %>
    </table>
</div>
<!-- #include file="../dbclose.inc" -->
<%
FUNCTION BuildBankFilter(strFilters)
    Dim bankFilter : bankFilter = ""

    ' ### Only process filters if not "all" ###
    IF strFilters <> "all" THEN
        Dim filterListPairs : filterListPairs = Split(strFilters, "::")
        Dim idx
        FOR idx = 0 TO uBound(filterListPairs)
            ' ### NOTE: we only care about the first element of the value pair because it's the bankId. ###
            Dim filterPair : filterPair = Split(filterListPairs(i), ",")
            Dim filterBankId : filterBankId = filterPair(0)

            ' ### Only add to the bankFilter if the bankId does not already exist in the list. ###
            IF InStr(bankFilter, filterBankId, 1) THEN
                IF bankFilter = "" THEN
                    bankFilter = dbFormatId(filterBankId)
                ELSE
                    bankFilter = bankFilter & ", " & dbFormatId(filterBankId)
                END IF
            END IF
        NEXT
    END IF

    IF bankFilter <> "" THEN bankFilter = " AND bankId IN (" & bankFilter & ")"

    BuildBankFilter = bankFilter
END FUNCTION

FUNCTION BuildOfficerFilter(strFilters)
    Dim officerFilter : officerFilter = ""

    ' ### Only process filters if not "all" ###
    IF strFilters <> "all" THEN
        Dim filterListPairs : filterListPairs = Split(strFilters, ",")
        Dim idx
        FOR idx = 0 TO uBound(filterListPairs)
            ' ### NOTE: we only care about the first element of the value pair because it's the bankId. ###
            Dim filterPair : filterPair = Split(filterListPairs(idx), "::")
            Dim filterBankId : filterBankId = filterPair(0)
            Dim filterOfficerId : filterOfficerId = filterPair(1)

            ' ### Only add to the officerFilter if the officerFilterId does not already exist in the list. ###
            IF officerFilter = "" THEN
                officerFilter = dbFormatId(filterOfficerId)
            ELSEIF InStr(officerFilter, filterOfficerId) = 0 THEN
                officerFilter = officerFilter & ", " & dbFormatId(filterOfficerId)
            END IF
        NEXT
    END IF

    IF officerFilter <> "" THEN
        officerFilter = _
            " AND (" & _
            "   (c.customerOfficerId IN (" & officerFilter & ") AND ex.loanId IS NULL)" & _
            "   OR (l.loanOfficerId IN (" & officerFilter & ") AND ex.loanId IS NOT NULL)" & _
            " )"
    END IF

    BuildOfficerFilter = officerFilter
END FUNCTION

FUNCTION BuildAssignedUserFilter(strFilters)
    Dim userFilter : userFilter = ""
    Dim unassignedUserFilter : unassignedUserFilter = ""

    ' ### Only process filters if not "all" ###
    IF strFilters <> "all" THEN
        Dim filterListPairs : filterListPairs = Split(strFilters, ",")
        Dim idx
        FOR idx = 0 TO uBound(filterListPairs)
            ' ### NOTE: we only care about the first element of the value pair because it's the bankId. ###
            Dim filterPair : filterPair = Split(filterListPairs(idx), "::")
            Dim filterBankId : filterBankId = filterPair(0)
            Dim filterUserId : filterUserId = filterPair(1)

            IF filterUserId = "0" THEN
                ' ### Special check for userId=0, unassigned users check for NULL ###
                IF unassignedUserFilter = "" THEN unassignedUserFilter = " ex.assignedUserId IS NULL "
            ELSE
                ' ### Only add to the userFilter if the userId does not already exist in the list. ###
                IF userFilter = "" THEN
                    userFilter = dbFormatId(filterUserId)
                ELSEIF InStr(userFilter, filterUserId) = 0 THEN
                    userFilter = userFilter & ", " & dbFormatId(filterUserId)
                END IF
            END IF
        NEXT
    END IF

    IF userFilter <> "" OR unassignedUserFilter <> "" THEN
        IF userFilter <> "" AND unassignedUserFilter = "" THEN
            userFilter = " AND (ex.assignedUserId IN (" & userFilter & "))"
        ELSEIF userFilter <> "" AND unassignedUserFilter <> "" THEN
            userFilter = " AND (ex.assignedUserId IN (" & userFilter & ") OR " & unassignedUserFilter & " )"
        ELSEIF userFilter = "" AND unassignedUserFilter <> "" THEN
            userFilter = " AND (" & unassignedUserFilter & ") "
        END IF
    END IF

    buildAssignedUserFilter = userFilter
END FUNCTION
%>