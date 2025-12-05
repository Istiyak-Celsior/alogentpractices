<%
displayClause = ""
IF selectedLoanExceptionDisplay = "active" THEN
    displayClause = _
        " AND e.statusType='required'" & _
        " AND (" & _
        "   (e.exceptionState <> 'N' OR IsNull(excdoc.documentExceptionState,'N') <> 'N')" & _
        "   OR (e.TaskId IS NOT NULL AND e.exceptionState <> 'N')" & _
        " )"
END IF

loanExceptionQuery = _
    " SELECT" & _
    "   ed.computationType, " & _
    "   ed.exceptionDefName, " & _
    "   ed.PolicyId, " & _
    "   e.exceptionId," & _
    "   e.exceptionState," & _
    "   e.comment," & _
    "   e.customerId," & _
    "   e.loanId," & _
    "   e.statusType," & _
    "   e.assignedUserId," & _
    "   excdoc.exception_documentId," & _
    "   excdoc.documentExceptionState," & _
    "   ubv.userFirstName," & _
    "   ubv.userLastName," & _
    "   dbo.getdocname(e.exceptionid, excdoc.exceptedDocumentId, excdoc.exceptedDocDefId) as docName, " & _
    "   tk.TaskId," & _
    "   tk.TransferableByUser," & _
    "   CASE WHEN ed.computationType = 'manual' THEN 0 ELSE 1 END AS exceptionGrouping," & _
    "   ls.isApplicationStatus," & _
    "   ac.accountClassCode," & _
    "   nls.noticeLetterSetId" & _
    " FROM" & _
    "   exception AS e " & _
    "   INNER JOIN exceptionDefinition AS ed ON e.exceptionDefId = ed.exceptionDefId " & _
    "   LEFT OUTER JOIN qryUserBankView AS ubv ON ubv.userId = ISNULL(e.assignedUserId,ed.defaultAssignedUserId) AND ubv.bankId = ed.bankId " & _
    "   LEFT OUTER JOIN excepteddocument AS excdoc ON excdoc.exceptionid = e.exceptionid " & _
    "   LEFT OUTER JOIN Task AS tk ON tk.TaskId = e.TaskId " & _
    "   LEFT OUTER JOIN TaskGroup AS tg ON tg.TaskGroupId=tk.TaskGroupId " & _
    "   LEFT OUTER JOIN loan AS l ON e.loanId = l.loanId" & _
    "   LEFT OUTER JOIN loanStatus AS ls ON l.loanStatusId = ls.statusId " & _
    "   LEFT OUTER JOIN accountClass AS ac ON ls.accountClassId = ac.accountClassId " & _
    "   LEFT OUTER JOIN noticeLetterSetException nlse ON ed.exceptionDefId = nlse.exceptionDefinitionId" & _
    "   LEFT OUTER JOIN noticeLetterSet nls ON nlse.noticeLetterSetId = nls.noticeLetterSetId" & _
    "       AND nls.isEnabled = 1" & _
    " WHERE" & _
    "   e.loanId = " & dbFormatId(loanRS("loanId")) & _
    displayClause & _
    " ORDER BY" & _
    "   exceptionGrouping," & _
    "   ed.sortOrder ASC," & _
    "   ed.exceptionDefName ASC"
loanExceptionRS.Open loanExceptionQuery, db, adOpenStatic
exceptionColSpan = 5
IF Session("accuaccount.enableExpress") <> 1 Or Session("accuaccount.enableNotices") = 1 THEN exceptionColSpan = 6

' ### Process Loan Covenants for Exceptions ###
covenantExceptionCount = 0 : covenantOutOfDateCount = 0 : covenantCount = 0
Dim loanCovenants : loanCovenants = GetAccountCovenants(selectedLoanId)
IF g_hasAccountFieldDefList THEN
    FOR i = lBound(g_accountFieldDefList,1) TO uBound(g_accountFieldDefList,2)
        fieldDefIsCovenant = Trim(g_accountFieldDefList(FIELD_DEF_IS_COVENANT,i))
        fieldDefAccountClassId = Trim(g_accountFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,i))
        IF fieldDefIsCovenant AND cStr(selectedAccountClassId) = cStr(fieldDefAccountClassId) THEN
            fieldTable = "loanFields"
            fieldColumn = "loanId" 
            fieldId = selectedLoanId
            fieldDefId = Trim(g_accountFieldDefList(FIELD_DEF_ID,i))
            fieldDefLabel = Trim(g_accountFieldDefList(FIELD_DEF_LABEL,i))
            fieldDefName = Trim(g_accountFieldDefList(FIELD_DEF_NAME,i))
            fieldDefIsActive = Trim(g_accountFieldDefList(FIELD_DEF_IS_ACTIVE,i))
            covenantDefaultMin = trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,i))
            covenantDefaultMax = trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,i))
            covenantDefaultTestFrequency = trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,i))
            fieldValue = trim(loanFieldsRS(fieldDefName))
            fieldIsActive = trim(loanFieldsRS(fieldDefName & "_isActive"))

            IF fieldIsActive OR selectedLoanExceptionDisplay <> "active" THEN covenantCount = covenantCount + 1

            IF IsNull(fieldIsActive) OR fieldIsActive = "" THEN fieldIsActive = fieldDefIsActive

            covenantMin = covenantDefaultMin
            covenantMax = covenantDefaultMax
            covenantLastTestDate = ""
            covenantTestFrequency = covenantDefaultTestFrequency
            FOR j = lBound(loanCovenants, 1) TO uBound(loanCovenants, 2)
                covenantFieldDefId = loanCovenants(COVENANT_FIELD_DEF_ID,j)

                IF Trim(covenantFieldDefId & "") = "" AND uBound(loanCovenants, 2) = 0 THEN
                    ' ### Use master value defaults ###
                    covenantMin = covenantDefaultMin
                    covenantMax = covenantDefaultMax
                    covenantLastTestDate = ""
                    covenantTestFrequency = covenantDefaultTestFrequency
                    EXIT FOR
                ELSEIF cStr(fieldDefId) = cStr(covenantFieldDefId) THEN
                    covenantMin = covenantDefaultMin
                    covenantMax = covenantDefaultMax
                    covenantLastTestDate = Trim(loanCovenants(COVENANT_LAST_TEST_DATE,j))
                    covenantTestFrequency = covenantDefaultTestFrequency

                    IF NOT loanCovenants(COVENANT_USE_MASTER,j) THEN
                        IF IsNumeric(Trim(loanCovenants(COVENANT_MIN_VALUE,j))) THEN
                            covenantMin = Trim(loanCovenants(COVENANT_MIN_VALUE,j))
                        END IF

                        IF IsNumeric(Trim(loanCovenants(COVENANT_MAX_VALUE,j))) THEN
                            covenantMax = Trim(loanCovenants(COVENANT_MAX_VALUE,j))
                        END IF

                        covenantTestFrequency = Trim(loanCovenants(COVENANT_TEST_FREQUENCY,j))
                    END IF
                    EXIT FOR
                END IF
            NEXT

            IF IsCovenantException(fieldValue, covenantMin, covenantMax) AND fieldIsActive THEN
                covenantExceptionCount = covenantExceptionCount + 1
            END IF

            IF IsCovenantOutOfDate(covenantLastTestDate, covenantTestFrequency ) AND fieldIsActive THEN
                covenantOutOfDateCount = covenantOutOfDateCount + 1
            END IF
        END IF
    NEXT
END IF

page = "exceptiondefselecttype.asp?action=ADD&exceptionDefType=custom&targetType=" + tabType + "&targetTypeId=" & loanRS("loanTypeId") & "&targetId=" & selectedLoanId & "&bankId=" & customerRS("bankId") & "&activeTab=" & loanRS("accountClassCode")
policyExceptionPage = "exceptiondefselectpolicy.asp?action=ADD&exceptionDefType=custom&activeTab=" + selectedAccountClassCode + "&targetTypeId=" & loanRS("loanTypeId") & "&targetId=" & selectedLoanId & "&bankId=" & customerRS("bankId")
%>
<table class="aa-exceptions">
    <tr class="aa-menu-bar">
        <td colspan="<%=exceptionColSpan%>"><a name="accountExceptBody" href="javascript:void(0);"></a>
        <% IF Session("exceptionValidator.disableRtev") <> "1" THEN %>
        <a href="refreshexceptions.asp?processType=<%=VALIDATOR_PROCESS_ACCOUNT%>&processId=<%=selectedLoanId%>&returnPage=customer.asp" class="aa-command-button"><i class="aa-icon fas fa-sync fa-fw" title="Refresh Exceptions" aria-hidden="true"></i></a>
        <% END IF %>
        <% IF selectedLoanExceptionDisplay = "active" THEN %>
        <a href="customer.asp?loanExceptionDisplay=all&pad=#except<%=loanRS("loanId")%>" class="aa-command-button"><i class="aa-icon fas fa-search-plus fa-fw" title="Show All Exceptions" aria-hidden="true"></i></a>
        <% ELSE %>
        <a href="customer.asp?loanExceptionDisplay=active&pad=#except<%=loanRS("loanId")%>" class="aa-command-button"><i class="aa-icon fas fa-search fa-fw" title="Show Active Exceptions Only" aria-hidden="true"></i></a>
        <% END IF %>
        <% IF Session("isSuperUser") OR Session("permissionException") >= 3 THEN %>
            <a href="javascript:void(0);" onclick="openKendoDialog('Create Custom Exception', '<%=page%>', 550, 850);" class="aa-command-button"><i class="aa-icon fas fa-exclamation-circle fa-fw" title="Add Custom Exception" aria-hidden="true"></i></a>
            <% IF Session("accuaccount.enableExpress") <> 1 OR Session("accuaccount.enableNotices") = 1 THEN %>
            <a href="javascript:void(0);" onclick="openKendoDialog('Create Custom Policy Exception', '<%=policyExceptionPage%>', 550, 850);" class="aa-command-button"><i class="aa-icon fab fa-product-hunt fa-fw" title="Add Custom Policy Exception" aria-hidden="true"></i></a>
            <% END IF %>
        <% END IF %>
        <% IF Session("isSuperUser") OR Session("permissionException") >= 2 THEN %>
        <a href="javascript:void(0);" onclick="openKendoDialog('Execute Task Group', 'executetaskgroupselect.asp?loanId=<%=selectedLoanId%>&taskGroupType=L', 500, 800);" class="aa-command-button"><i class="aa-icon fas fa-tasks fa-fw" title="Execute Task List" aria-hidden="true"></i></a>
        <% END IF %></td>
    </tr>
    <% IF tabHasExceptions=0 AND selectedLoanExceptionDisplay = "active" THEN %>
    <tr class="no-results">
        <td>There are no active Document or Task Exceptions.</td>
    </tr>
    <% ELSE %>
    <%
    taskFirstTime = True
    exceptionFirstTime = True
    DO UNTIL loanExceptionRS.EOF
        Dim loanExceptionTaskId : loanExceptionTaskId = ""
        loanExceptionTaskId = loanExceptionRS("TaskId")
        assignedUserId = CheckForNull(loanExceptionRS("assignedUserId"))
        transferableByUser = loanExceptionRS("TransferableByUser")

        ' ### Determine if user can reassign Exceptions ###
        Dim currentAccountClass : currentAccountClass = loanExceptionRS("accountClassCode")
        IF currentAccountClass = "loan" AND loanExceptionRS("isApplicationStatus") THEN currentAccountClass = "loanapp"
        allowReassignException = False

        IF loanExceptionRS("computationType") = "manual" THEN
            IF Trim(loanExceptionTaskId & "") = "" THEN
                IF Session("isSuperUser") _
                    OR Session(currentAccountClass & ".isAdmin") _
                    OR Session("permissionException") >= 2 _
                    OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                        allowReassignException = True
                END IF
            ELSE
                IF Session("isSuperUser") _
                    OR Session(currentAccountClass & ".isAdmin") _
                    OR (Session("permissionException") >= 2 AND transferableByUser) _
                    OR (cStr(Session("userId")) = cStr(assignedUserId) AND transferableByUser) THEN
                        allowReassignException = True
                END IF
            END IF
        ELSEIF loanExceptionRS("computationType") = "computed" THEN
            IF Session("isSuperUser") _
                OR Session(currentAccountClass & ".isAdmin") _
                OR Session("permissionException") >= 2 _
                OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                    allowReassignException = True
            END IF
        END IF

        ' ### Determine if user can resolve Task Exceptions ###
        allowResolveTask = False
        IF Session("isSuperUser") OR Session("permissionException") >= 2 OR cStr(Session("userId")) = cStr(assignedUserId) THEN
            allowResolveTask = True
        END IF

        IF Trim(checkForNull(loanExceptionRS("documentExceptionState"))) = "" THEN
            exceptionState = loanExceptionRS("exceptionState")
        ELSE
            exceptionState = loanExceptionRS("documentExceptionState")
        END IF

        editUrl = "exceptionmaint.asp?exceptionId=" & loanExceptionRS("exceptionId") & "&exceptionDocId=" & loanExceptionRS("exception_documentId")

        IF taskFirstTime AND loanExceptionRS("computationType") = "manual" THEN
            taskFirstTime = False
            %>
            <tr class="header">
                <td colspan="<%=exceptionColSpan%>"><h3>Tasks</h3></td>
            </tr>
            <tr class="aa-column-headers">
                <td class="aa-tac">Action</td>
                <td>Description</td>
                <td class="aa-tac">Exception</td>
                <td class="aa-tac">Comments</td>
                <% IF Session("accuaccount.enableExpress") <> 1 AND Session("accuaccount.enableNotices") = 1 THEN %>
                <td class="aa-tac">Notices</td>
                <% END IF 'Session("accuaccount.enableExpress") <> 1 %>
                <td>Assigned User</td>
            </tr>
            <%
        ELSEIF exceptionFirstTime AND loanExceptionRS("computationType") = "computed" THEN
            exceptionFirstTime = False
            %>
            <tr class="header">
                <td colspan="<%=exceptionColSpan%>"><h3>Document Exceptions</h3></td>
            </tr>
            <tr class="aa-column-headers">
                <td class="aa-tac">Action</td>
                <td>Description</td>
                <td class="aa-tac">Exception</td>
                <td class="aa-tac">Comments</td>
                <% IF Session("accuaccount.enableExpress") <> 1 AND Session("accuaccount.enableNotices") = 1 THEN %>
                <td class="aa-tac">Notices</td>
                <% END IF 'Session("accuaccount.enableExpress") <> 1 %>
                <td>Assigned User</td>
            </tr>
        <% END IF %>
        <tr class="data-row">
            <td class="aa-exception-icon-list">
                <ul>
                    <li><a name="except<%=loanExceptionRS("exceptionId")%>" href="javascript:void(0);" onclick="openKendoDialog('Edit Exception Properties', '<%=editUrl%>', 550, 850);"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                    <% IF loanExceptionRS("exceptionState") <> "N" AND allowReassignException THEN %>
                    <li><a href="javascript:void(0);" onclick="openKendoDialog('Edit Exception Properties', 'reassigntask.asp?exceptionId=<%=loanExceptionRS("exceptionId")%>&section=account', 500, 850);"><i class="aa-icon fas fa-user fa-fw" title="Reassign Task" aria-hidden="true"></i></a></li>
                    <% ELSE %>
                    <li>&nbsp;</li>
                    <% END IF %>
                    <% IF loanExceptionRS("computationType") = "manual" AND loanExceptionRS("exceptionState") <> "N" AND allowResolveTask THEN %>
                    <li><a href="resolvetask.asp?exceptionId=<%=loanExceptionRS("exceptionId")%>&section=account"><i class="aa-icon fas fa-check fa-fw" title="Resolve Task" aria-hidden="true"></i></a></li>
                    <% ELSE %>
                    <li>&nbsp;</li>
                    <% END IF %>
                </ul>
            </td>
            <% IF loanExceptionRS("docName") <> "" THEN %>
            <td class="description"><%=loanExceptionRS("exceptionDefName")%> (<em> <%=loanExceptionRS("docName")%> </em>)</td>
            <% ELSE %>
            <td class="description"><%=loanExceptionRS("exceptionDefName")%></td>
            <% END IF %>
            <td class="aa-exception-icon-list">
                <ul>
                    <%
                    IF loanRS("ignoreExceptionsYN") = "Y" THEN
                        Response.Write "<li>Ignored</li>"
                    ELSEIF loanExceptionRS("statusType") = "n/a" THEN
                        Response.Write "<li>N/A</li>"
                    ELSEIF exceptionState = "Y" THEN
                        Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-color-danger"" title=""Exception"" aria-hidden=""true""></i></li>"
                    ELSEIF exceptionState = "P" THEN
                        Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-color-warning"" title=""Pending Exception"" aria-hidden=""true""></i></li>"
                    ELSE
                        Response.Write "<li>&nbsp;</li>"
                    END IF
                    IF NOT IsNull(loanExceptionRS("PolicyId")) THEN
                        Response.Write "<li><i class=""aa-icon fab fa-product-hunt fa-fw"" aria-hidden=""true""></i></li>"
                    ELSE
                        Response.Write "<li>&nbsp;</li>"
                    END IF
                    %>
                </ul>
            </td>
            <% IF Trim(CheckForNull(loanExceptionRS("comment"))) <> "" THEN %>
            <td class="aa-tac"><a href="javascript:void(0);" onclick="openKendoDialog('View Exception Comment', 'viewcomment.asp?exceptionId=<%=loanExceptionRS("exceptionId")%>&type=exception', 400, 500);"><i class="aa-icon fas fa-comments fa-fw" title="<%=CheckForNull(loanExceptionRS("comment"))%>" aria-hidden="true"></i></a></td>
            <% ELSE %>
            <td>&nbsp;</td>
            <% END IF %>
            <% IF Session("accuaccount.enableExpress") <> 1 AND Session("accuaccount.enableNotices") = 1 THEN %>
               <td class="aa-tac">
               <%
                    Dim accountNoticeLetterSetId  : accountNoticeLetterSetId  = loanExceptionRS("noticeLetterSetId") & ""
                    Dim accountNoticeImageType    : accountNoticeImageType    = ""
                    Dim accountNoticeMsg          : accountNoticeMsg          = ""
                    IF  accountNoticeLetterSetId <> "" THEN
                        response.write  "<i class=""aa-icon far fa-envelope" & accountNoticeImageType & """ title=""" & accountNoticeMsg & """ aria-hidden=""true""></i>"
                    END IF
               %></td>
            <% END IF %>
            <td><%
            assignedUser = loanExceptionRS("userFirstName") & " " & loanExceptionRS("userLastName")
            IF Len(Trim(assignedUser)) = 0 THEN assignedUser = "Unassigned"
            Response.Write assignedUser
            %></td>
        </tr>
        <%
        loanExceptionRS.MoveNext
    LOOP ' ### loanExceptionRS.EOF
    END IF ' ### computedExceptionCount = 0 AND computedPendingCount = 0 AND manualExceptionCount = 0 AND manualPendingCount = 0 AND selectedLoanExceptionDisplay = "active"
    loanExceptionRS.Close
    %>
    <tr class="header">
        <td colspan="<%=exceptionColSpan%>"><h3>Covenants</h3></td>
    </tr>
    <tr>
        <td colspan="<%=exceptionColSpan%>">
        <table class="aa-convenants">
            <tr class="aa-column-headers">
                <td>Action</td>
                <td>Covenant</td>
                <td style="width:66px">&nbsp;</td>
                <td class="aa-tac">Current Value</td>
                <td class="aa-tac">Min</td>
                <td class="aa-tac">Max</td>
                <td class="aa-tac">Date</td>
                <td>Frequency</td>
            </tr>
            <tbody>
                <%
                IF covenantCount = 0 THEN
                %><tr class="no-results">
                    <td colspan="8">There are no covenants available.</td>
                </tr>
                <% ELSE
                    ' ### Process Credit Covenants for Exceptions ###
                    FOR i = lBound(g_accountFieldDefList,1) TO uBound(g_accountFieldDefList,2)
                        fieldDefIsCovenant = Trim(g_accountFieldDefList(FIELD_DEF_IS_COVENANT,i))
                        fieldDefAccountClassId = Trim(g_accountFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,i))
                        IF fieldDefIsCovenant And cStr(selectedAccountClassId) = cStr(fieldDefAccountClassId) THEN
                            fieldTable = "loanFields"
                            fieldColumn = "loanId" 
                            fieldId = selectedLoanId
                            fieldDefId = Trim(g_accountFieldDefList(FIELD_DEF_ID,i))
                            fieldDefLabel = Trim(g_accountFieldDefList(FIELD_DEF_LABEL,i))
                            fieldDefName = Trim(g_accountFieldDefList(FIELD_DEF_NAME,i))
                            fieldDefIsActive = Trim(g_accountFieldDefList(FIELD_DEF_IS_ACTIVE,i))
                            covenantDefaultMin = trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,i))
                            covenantDefaultMax = trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,i))
                            covenantDefaultTestFrequency = trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,i))
                            fieldValue = trim(loanFieldsRS(fieldDefName))
                            fieldIsActive = trim(loanFieldsRS(fieldDefName & "_isActive"))
                            IF IsNull(fieldIsActive) OR fieldIsActive = "" THEN fieldIsActive = fieldDefIsActive
                            covenantMin = covenantDefaultMin
                            covenantMax = covenantDefaultMax
                            covenantLastTestDate = ""
                            covenantTestFrequency = covenantDefaultTestFrequency
                            FOR j = lBound(loanCovenants, 1) TO uBound(loanCovenants, 2)
                                covenantFieldDefId = loanCovenants(COVENANT_FIELD_DEF_ID, j)
                                IF covenantFieldDefId = "" AND uBound(loanCovenants, 2) = 0 THEN
                                    ' ### Use master value defaults ###
                                    covenantMin = covenantDefaultMin
                                    covenantMax = covenantDefaultMax
                                    covenantLastTestDate = ""
                                    covenantTestFrequency = covenantDefaultTestFrequency
                                    EXIT FOR
                                ELSEIF cStr(fieldDefId) = cStr(covenantFieldDefId) THEN
                                    covenantMin = covenantDefaultMin
                                    covenantMax = covenantDefaultMax
                                    covenantLastTestDate = Trim(loanCovenants(COVENANT_LAST_TEST_DATE,j))
                                    covenantTestFrequency = covenantDefaultTestFrequency
                                    IF NOT loanCovenants(COVENANT_USE_MASTER,j) THEN
                                        IF IsNumeric(Trim(loanCovenants(COVENANT_MIN_VALUE,j))) THEN covenantMin = Trim(loanCovenants(COVENANT_MIN_VALUE,j))
                                        IF IsNumeric(Trim(loanCovenants(COVENANT_MAX_VALUE,j))) THEN covenantMax = Trim(loanCovenants(COVENANT_MAX_VALUE,j))
                                        covenantTestFrequency = Trim(loanCovenants(COVENANT_TEST_FREQUENCY,j))
                                    END IF
                                    EXIT FOR
                                END IF
                            NEXT 'j
                            ' ### Display only Active Covenants or all when dislay all is active ###
                            IF fieldIsActive OR selectedLoanExceptionDisplay = "all" THEN
                                %>
                                <tr class="data-row">
                                    <% IF IsExceptionEditor THEN %>
                                    <td class="aa-tac"><a href="javascript:void(0);" onclick="openKendoDialog('Edit Covenant', 'covenantmaint.asp?loanId=<%=selectedLoanId%>&fieldDefId=<%=fieldDefId%>', 500, 700);"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Covenant" aria-hidden="true"></i></a></td>
                                    <% ELSE %>
                                    <td>&nbsp;</td>
                                    <% END IF %>
                                    <td><%=fieldDefLabel%></td>
                                    <%
                                    imgStatus = "no"
                                    IF fieldIsActive THEN imgStatus = "yes"
                                    %>
                                    <td class="aa-exception-icon-list">
                                        <ul>
                                            <li><i class="fas fa-circle aa-status-<%=imgStatus%> fa-fw" aria-hidden="true"></i></li>
                                            <% IF isCovenantException(fieldValue, covenantMin, covenantMax) THEN %>
                                            <li><i class="aa-icon fas fa-exclamation-circle aa-color-danger fa-fw" title="Covenant Exception" aria-hidden="true"></i></li>
                                            <% ELSE %>
                                            <li></li>
                                            <% END IF %>
                                            <%
                                            IF fieldIsActive THEN
                                                IF IsExceptionEditor AND IsCovenantOutOfDate(covenantLastTestDate, covenantTestFrequency ) THEN
                                                    Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?loanId=" & selectedLoanId & "&fieldDefId=" & fieldDefId & "', 500, 700);""><i class=""aa-icon fas fa-bell fa-fw"" title=""Covenant Value Requires Review"" aria-hidden=""true""></i></a></li>"
                                                ELSE
                                                    Response.Write "<li></li>"
                                                END IF
                                            ELSE
                                                Response.Write "<li></li>"
                                            END IF
                                            %>
                                        </ul>
                                    </td>
                                    <%
                                    IF IsNull(fieldValue) OR fieldValue = "" THEN fieldValue = "---"
                                    IF IsNull(covenantMin) Or covenantMin = "" THEN covenantMin = "---"
                                    IF IsNull(covenantMax) Or covenantMax = "" THEN covenantMax = "---"
                                    IF IsNull(covenantLastTestDate) Or covenantLastTestDate = "" THEN covenantLastTestDate = "---"
                                    %>
                                    <td class="aa-tac"><%=fieldValue%></td>
                                    <td class="aa-tac"><%=covenantMin%></td>
                                    <td class="aa-tac"><%=covenantMax%></td>
                                    <td class="aa-tac"><%=covenantLastTestDate%></td>
                                    <td><%
                                    IF covenantTestFrequency = 0 THEN
                                        Response.Write "Never"
                                    ELSEIF covenantTestFrequency = 1 THEN
                                        Response.Write "Monthly"
                                    ELSEIF covenantTestFrequency = 2 THEN
                                        Response.Write "Quarterly"
                                    ELSEIF covenantTestFrequency = 3 THEN
                                        Response.Write "Semi-Annual"
                                    ELSEIF covenantTestFrequency = 4 THEN
                                        Response.Write "Annual"
                                    END IF
                                    %></td>
                                </tr>
                                <%
                            END IF ' ### IF fieldIsActive OR selectedLoanExceptionDisplay = "all"
                        END IF ' ### fieldDefIsCovenant
                    NEXT ' ### i
                END IF ' ### IF covenantCount = 0
                %>
            </tbody>
        </table>
        </td>
    </tr>
</table>