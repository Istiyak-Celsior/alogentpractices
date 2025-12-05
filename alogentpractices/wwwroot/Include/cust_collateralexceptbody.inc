<!-- BEGIN Collateral Exception Display -->
<%
displayClause = ""
IF selectedCollateralExceptionDisplay = "active" THEN
    displayClause = _
        " AND e.statusType='required'" & _
        " AND (" & _
        "   (e.exceptionState <> 'N' OR IsNull(excdoc.documentExceptionState,'N') <> 'N')" & _
        "   OR (e.TaskId IS NOT NULL AND e.exceptionState <> 'N')" & _
        " )"
END IF

collateralExceptionQuery = _
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
    "   ubv.userMiddleInitial," & _
    "   ubv.userLastName," & _
    "   dbo.getdocname(e.exceptionid, excdoc.exceptedDocumentId, excdoc.exceptedDocDefId) as docName, " & _
    "   tk.TaskId," & _
    "   tk.TransferableByUser," & _
    "   CASE WHEN ed.computationType = 'manual' THEN 0 ELSE 1 END AS exceptionGrouping, " & _
    "   nls.noticeLetterSetId" & _
    " FROM" & _
    "   exception AS e " & _
    "   INNER JOIN exceptionDefinition AS ed ON e.exceptionDefId = ed.exceptionDefId " & _
    "   LEFT JOIN qryUserBankView AS ubv ON e.assignedUserId = ubv.userId AND ubv.bankId = ed.bankId " & _
    "   LEFT OUTER JOIN excepteddocument AS excdoc ON excdoc.exceptionid = e.exceptionid " & _
    "   LEFT OUTER JOIN Task AS tk ON tk.TaskId = e.TaskId " & _
    "   LEFT OUTER JOIN TaskGroup AS tg ON tg.TaskGroupId = tk.TaskGroupId " & _
    "   LEFT OUTER JOIN noticeLetterSetException nlse ON ed.exceptionDefId = nlse.exceptionDefinitionId" & _
    "   LEFT OUTER JOIN noticeLetterSet nls ON nlse.noticeLetterSetId = nls.noticeLetterSetId" & _
    "       AND nls.isEnabled = 1" & _
    " WHERE" & _
    "   e.loanId=" & dbFormatId(targetCollateralLoanId) & _
    displayClause & _
    " ORDER BY" & _
    "   exceptionGrouping," & _
    "   ed.sortOrder ASC," & _
    "   ed.exceptionDefName ASC"
collateralExceptionRS.Open collateralExceptionQuery, db, adOpenStatic    

exceptionColSpan = 5
IF Session("accuaccount.enableExpress") <> 1 OR Session("accuaccount.enableNotices") = 1 THEN
    exceptionColSpan = 6
END IF

' ### Process Collateral Covenants for Exceptions ###
covenantExceptionCount = 0 : covenantOutOfDateCount = 0 : covenantCount = 0
Dim collateralCovenants : collateralCovenants = GetCollateralCovenants(targetCollateralLoanId)
IF g_hasCollateralFieldDefList THEN
    FOR i = lBound(g_collateralFieldDefList,1) TO uBound(g_collateralFieldDefList,2)
        fieldDefIsCovenant = Trim(g_collateralFieldDefList(FIELD_DEF_IS_COVENANT,i))
        fieldDefAccountClassId = Trim(g_collateralFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,i))
        IF fieldDefIsCovenant AND cStr(selectedAccountClassId) = cStr(fieldDefAccountClassId) THEN
            fieldTable = "collateralFields"
            fieldColumn = "collateralId" 
            fieldId = targetCollateralLoanId
            fieldDefId = Trim(g_collateralFieldDefList(FIELD_DEF_ID,i))
            fieldDefLabel = Trim(g_collateralFieldDefList(FIELD_DEF_LABEL,i))
            fieldDefName = Trim(g_collateralFieldDefList(FIELD_DEF_NAME,i))
            fieldDefIsActive = Trim(g_collateralFieldDefList(FIELD_DEF_IS_ACTIVE,i))
            covenantDefaultMin = trim(g_collateralFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,i))
            covenantDefaultMax = trim(g_collateralFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,i))
            covenantDefaultTestFrequency = trim(g_collateralFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,i))
            fieldValue = trim(collateralFieldsRS(fieldDefName))
            fieldIsActive = trim(collateralFieldsRS(fieldDefName & "_isActive"))

            IF fieldIsActive OR selectedCollateralExceptionDisplay <> "active" THEN covenantCount = covenantCount + 1

            IF IsNull(fieldIsActive) OR fieldIsActive = "" THEN fieldIsActive = fieldDefIsActive

            covenantMin = covenantDefaultMin
            covenantMax = covenantDefaultMax
            covenantLastTestDate = ""
            covenantTestFrequency = covenantDefaultTestFrequency
            FOR j = lBound(collateralCovenants, 1) TO uBound(collateralCovenants, 2)
                covenantFieldDefId = collateralCovenants(COVENANT_FIELD_DEF_ID, j)
                IF covenantFieldDefId = "" AND uBound(collateralCovenants, 2) = 0 THEN
                    ' ### Use master value defaults ###
                    covenantMin = covenantDefaultMin
                    covenantMax = covenantDefaultMax
                    covenantLastTestDate = ""
                    covenantTestFrequency = covenantDefaultTestFrequency
                    EXIT FOR
                ELSEIF cStr(fieldDefId) = cStr(covenantFieldDefId) THEN
                    covenantMin = covenantDefaultMin
                    covenantMax = covenantDefaultMax
                    covenantLastTestDate = Trim(collateralCovenants(COVENANT_LAST_TEST_DATE,j))
                    covenantTestFrequency = covenantDefaultTestFrequency

                    IF NOT collateralCovenants(COVENANT_USE_MASTER,j) THEN
                        IF IsNumeric(Trim(collateralCovenants(COVENANT_MIN_VALUE,j))) THEN
                            covenantMin = Trim(collateralCovenants(COVENANT_MIN_VALUE,j))
                        END IF

                        IF IsNumeric(Trim(collateralCovenants(COVENANT_MAX_VALUE,j))) THEN
                            covenantMax = Trim(collateralCovenants(COVENANT_MAX_VALUE,j))
                        END IF

                        covenantTestFrequency = Trim(collateralCovenants(COVENANT_TEST_FREQUENCY,j))
                    END IF
                    EXIT FOR
                END IF 
            NEXT

            IF IsCovenantException(fieldValue, covenantMin, covenantMax) AND fieldIsActive THEN
                covenantExceptionCount = covenantExceptionCount + 1
            END IF

            IF IsCovenantOutOfDate(covenantLastTestDate, covenantTestFrequency) AND fieldIsActive THEN
                covenantOutOfDateCount = covenantOutOfDateCount + 1
            END IF
        END IF
    NEXT
END IF

page = "exceptiondefselecttype.asp?action=ADD&exceptionDefType=custom&targetType=L&targetTypeId=" & targetLoanTypeId & "&targetId=" & targetCollateralLoanId & "&bankId=" & targetBankId & "&activeTab=loan"
policyExceptionPage = "exceptiondefselectpolicy.asp?action=ADD&exceptionDefType=custom&activeTab=loan&targetTypeId=" & targetLoanTypeId & "&targetId=" & targetCollateralLoanId & "&bankId=" & targetBankId
%>
<table class="aa-exceptions">
    <tr class="aa-menu-bar">
        <td colspan="<%=exceptionColSpan%>" align="left"><a name="accountExceptBody" href=""></a>
        <% IF Session("exceptionValidator.disableRtev") <> "1" THEN %>
        <a href="refreshexceptions.asp?processType=<%=VALIDATOR_PROCESS_ACCOUNT%>&processId=<%=targetCollateralLoanId%>&returnPage=customer.asp" class="aa-command-button"><i class="aa-icon fas fa-sync fa-fw" title="Refresh Exceptions" aria-hidden="true"></i></a>
        <% END IF %>
        <% IF selectedCollateralExceptionDisplay = "active" THEN %>
        <a href="customer.asp?collateralTab=<%=selectedCollateralTab%>&collateralExceptionDisplay=all#collateralHeader" class="aa-command-button"><i class="aa-icon fas fa-search-plus fa-fw" title="Show All Exceptions" aria-hidden="true"></i></a>
        <% ELSE %>
        <a href="customer.asp?collateralTab=<%=selectedCollateralTab%>&collateralExceptionDisplay=active#collateralHeader" class="aa-command-button"><i class="aa-icon fas fa-search fa-fw" title="Show Active Exceptions Only" aria-hidden="true"></i></a>
        <% END IF %>
        <% IF Session("isSuperUser") OR Session("permissionException") >= 3 THEN %>
            <a href="javascript:void(0);" onclick="openKendoDialog('Create Custom Exception', '<%=page%>', 550, 850);" class="aa-command-button"><i class="aa-icon fas fa-exclamation-circle fa-fw" title="Add Custom Exception" aria-hidden="true"></i></a>
            <% IF Session("accuaccount.enableExpress") <> 1 OR Session("accuaccount.enableNotices") = 1 THEN %>
            <a href="javascript:void(0);" onclick="openKendoDialog('Create Custom Policy Exception', '<%=policyExceptionPage%>', 550, 850);" class="aa-command-button"><i class="aa-icon fab fa-product-hunt fa-fw" title="Add Custom Policy Exception" aria-hidden="true"></i></a>
            <% END IF %>
        <% END IF %>
        <% IF Session("isSuperUser") OR Session("permissionException") >= 2 THEN %>
        <a href="javascript:void(0);" onclick="openKendoDialog('Execute Task Group', 'executetaskgroupselect.asp?loanId=<%=targetCollateralLoanId%>&taskGroupType=L', 500, 800);" class="aa-command-button"><i class="aa-icon fas fa-tasks fa-fw" title="Execute Task List" aria-hidden="true"></i></a>
        <% END IF %>
        </td>
    </tr>
    <%
    IF tabHasExceptions = 0 AND selectedCollateralExceptionDisplay = "active" THEN
    %>
    <tr class="no-results">
        <td>There are no active Document or Task Exceptions.</td>
    </tr>
    <% ELSE %>
    <%
    taskFirstTime = true
    exceptionFirstTime = true
    DO UNTIL collateralExceptionRS.EOF
        Dim collateralExceptionTaskId : collateralExceptionTaskId = ""
        collateralExceptionTaskId = collateralExceptionRS("TaskId")
        assignedUserId = CheckForNull( collateralExceptionRS("assignedUserId"))
        transferableByUser = collateralExceptionRS("TransferableByUser")

        ' ### Determine if user can reassign Exceptions ###
        allowReassignException = false
        IF collateralExceptionRS("computationType") = "manual" THEN
            IF Trim(collateralExceptionTaskId & "") = "" THEN
                IF Session("isSuperUser") _
                    OR Session(currentAccountClass & ".isAdmin") _
                    OR Session("permissionException") >= 2 _
                    OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                    allowReassignException = true
                END IF
            ELSE
                IF Session("isSuperUser") _
                    OR Session(currentAccountClass & ".isAdmin") _
                        OR (Session("permissionException") >= 2 AND transferableByUser) _
                        OR (cStr(Session("userId")) = cStr(assignedUserId) AND transferableByUser) THEN
                        allowReassignException = true
                END IF
            END IF
        ELSEIF collateralExceptionRS("computationType") = "computed" THEN
            IF Session("isSuperUser") _
                OR Session(currentAccountClass & ".isAdmin") _
                OR Session("permissionException") >= 2 _
                OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                allowReassignException = true
            END IF
        END IF

        ' ### Determine if user can resolve Task Exceptions ###
        allowResolveTask = false
        IF Session("isSuperUser") _
            OR Session("permissionException") >= 2 _
            OR CStr(Session("userId")) = CStr(assignedUserId) THEN
            allowResolveTask = true
        END IF

        editUrl = "exceptionmaint.asp?exceptionId=" & collateralExceptionRS("exceptionId") & "&exceptionDocId=" & collateralExceptionRS("exception_documentId")
        IF Trim(checkForNull(collateralExceptionRS("documentExceptionState"))) = "" THEN
            exceptionState = collateralExceptionRS("exceptionState")
        ELSE
            exceptionState = collateralExceptionRS("documentExceptionState")
        END IF

        IF taskFirstTime AND collateralExceptionRS("computationType") = "manual" THEN
            taskFirstTime = false
            %>
            <tr>
                <td colspan="<%=exceptionColSpan%>"><h3>Tasks</h3></td>
            </tr>
            <tr class="aa-column-headers">
                <td class="aa-tac">Action</td>
                <td>Description</td>
                <td class="aa-tac">Exception</td>
                <td class="aa-tac">Comments</td>
                <% IF Session("accuaccount.enableExpress") <> 1 AND Session("accuaccount.enableNotices") = 1 THEN %>
                <td class="aa-tac">Notices</td>
                <% END IF %>
                <td>Assigned User</td>
            </tr>
            <%
        ELSEIF exceptionFirstTime AND collateralExceptionRS("computationType") = "computed" THEN
            exceptionFirstTime = false
            %>
            <tr>
                <td colspan="<%=exceptionColSpan%>"><h3>Document Exceptions</h3></td>
            </tr>
            <tr class="aa-column-headers">
                <td class="aa-tac">Action</td>
                <td>Description</td>
                <td class="aa-tac">Exception</td>
                <td class="aa-tac">Comments</td>
                <% IF Session("accuaccount.enableExpress") <> 1 AND Session("accuaccount.enableNotices") = 1 THEN %>
                <td class="aa-tac">Notices</td>
                <% END IF %>
                <td>Assigned User</td>
            </tr>
        <% END IF %>
        <tr class="data-row">
            <td class="aa-exception-icon-list">
                <ul>
                    <li><a name="except<%=collateralExceptionRS("exceptionId")%>" href="javascript:void(0);" onclick="openKendoDialog('Edit Exception Properties', '<%=editUrl%>', 550, 850);"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                    <% IF collateralExceptionRS("exceptionState") <> "N" AND allowReassignException THEN %>
                    <li><a href="javascript:void(0);" onclick="openKendoDialog('Edit Exception Properties', 'reassigntask.asp?exceptionId=<%=collateralExceptionRS("exceptionId")%>&section=account', 500, 850);"><i class="aa-icon fas fa-user fa-fw" title="Reassign Task" aria-hidden="true"></i></a></li>
                    <% ELSE %>
                    <li>&nbsp;</li>
                    <% END IF %>
                    <% IF collateralExceptionRS("computationType") = "manual" AND collateralExceptionRS("exceptionState") <> "N" And allowResolveTask THEN %>
                    <li><a href="resolvetask.asp?exceptionId=<%=collateralExceptionRS("exceptionId")%>&section=account"><i class="aa-icon fas fa-check fa-fw" title="Resolve Task" aria-hidden="true"></i></a></li>
                    <% ELSE %>
                    <li>&nbsp;</li>
                    <% END IF %>
                </ul>
            </td> 
            <% IF collateralExceptionRS("docName") <> "" THEN %>
            <td class="description"><%=collateralExceptionRS("exceptionDefName")%> (<em> <%=collateralExceptionRS("docName")%> </em>)</td>
            <% ELSE %>
            <td class="description"><%=collateralExceptionRS("exceptionDefName")%></td>
            <% END IF %>
            <td class="aa-exception-icon-list">
                <ul>
                    <%
                    IF collateralRS("ignoreExceptionsYN") = "Y" THEN
                        Response.Write "<li>Ignored</li>"
                    ELSEIF collateralExceptionRS("statusType") = "n/a" THEN
                        Response.Write "<li>N/A</li>"
                    ELSEIF exceptionState = "Y" THEN
                        Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-color-danger"" title=""Exception"" aria-hidden=""true""></i></li>"
                    ELSEIF exceptionState = "P" THEN
                        Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-color-warning"" title=""Pending Exception"" aria-hidden=""true""></i></li>"
                    ELSE
                        Response.Write "<li>&nbsp;</li>"
                    END IF
                    IF NOT IsNull(collateralExceptionRS("PolicyId")) THEN
                        Response.Write "<li><i class=""aa-icon fab fa-product-hunt fa-fw"" aria-hidden=""true""></i>"
                    ELSE
                        Response.Write "<li>&nbsp;</li>"
                    END IF
                    %>
                </ul>
            </td>
            <% IF Trim(CheckForNull(collateralExceptionRS("comment"))) <> "" THEN %>
            <td class="aa-tac"><a href="javascript:void(0);" onclick="openKendoDialog('View Exception Comment', 'viewcomment.asp?exceptionId=<%=collateralExceptionRS("exceptionId")%>&type=exception', 400, 500);"><i class="aa-icon fas fa-comments fa-fw" title="<%=CheckForNull(collateralExceptionRS("comment"))%>" aria-hidden="true"></i></a></td>
            <% ELSE %>
            <td class="aa-tac">&nbsp;</td>
            <% END IF %>
            <% IF Session("accuaccount.enableExpress") <> 1 Or Session("accuaccount.enableNotices") = 1 THEN %>
                <td class="aa-tac">
                <%
                    Dim collateralNoticeLetterSetId  : collateralNoticeLetterSetId  = collateralExceptionRS("noticeLetterSetId") & ""
                    Dim collateralNoticeImageType    : collateralNoticeImageType    = ""
                    Dim collateralNoticeMsg          : collateralNoticeMsg          = ""
                    IF  collateralNoticeLetterSetId <> "" THEN
                        response.write  "<i class=""aa-icon far fa-envelope" & collateralNoticeImageType & """ title=""" & collateralNoticeMsg & """ aria-hidden=""true""></i>"
                    END IF
                %></td>
        <% END IF %>
        <td><%
        assignedUser = collateralExceptionRS("userFirstName") & " " & collateralExceptionRS("userLastName")
        IF Len(Trim(assignedUser)) = 0 THEN assignedUser = "Unassigned"
        Response.Write assignedUser
        %></td>
        </tr>
        <%
        collateralExceptionRS.MoveNext
    LOOP
    END IF ' ### collateralExceptionRS.EOF
    collateralExceptionRS.Close
    %>
    <tr>
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
                    ' ### Process Collateral Covenants for Exceptions ###
                    FOR i = lBound(g_collateralFieldDefList,1) TO uBound(g_collateralFieldDefList,2)
                        fieldDefIsCovenant = Trim(g_collateralFieldDefList(FIELD_DEF_IS_COVENANT,i))
                        fieldDefAccountClassId = Trim(g_collateralFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,i))
                        IF fieldDefIsCovenant AND cStr(selectedAccountClassId) = cStr(fieldDefAccountClassId) THEN
                            fieldTable = "collateralFields"
                            fieldColumn = "collateralId" 
                            fieldId = targetCollateralLoanId
                            fieldDefId = Trim(g_collateralFieldDefList(FIELD_DEF_ID,i))
                            fieldDefLabel = Trim(g_collateralFieldDefList(FIELD_DEF_LABEL,i))
                            fieldDefName = Trim(g_collateralFieldDefList(FIELD_DEF_NAME,i))
                            fieldDefIsActive = Trim(g_collateralFieldDefList(FIELD_DEF_IS_ACTIVE,i))
                            covenantDefaultMin = Trim(g_collateralFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,i))
                            covenantDefaultMax = Trim(g_collateralFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,i))
                            covenantDefaultTestFrequency = Trim(g_collateralFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,i))
                            fieldValue = Trim(collateralFieldsRS(fieldDefName))
                            fieldIsActive = Trim(collateralFieldsRS(fieldDefName & "_isActive"))
        
                            IF IsNull(fieldIsActive) OR fieldIsActive = "" THEN
                                fieldIsActive = fieldDefIsActive
                            END IF
        
                            covenantMin = covenantDefaultMin
                            covenantMax = covenantDefaultMax
                            covenantLastTestDate = ""
                            covenantTestFrequency = covenantDefaultTestFrequency
                            FOR j = lBound(collateralCovenants,1) TO uBound(collateralCovenants,2)
                                covenantFieldDefId = collateralCovenants(COVENANT_FIELD_DEF_ID,j)
                                IF covenantFieldDefId = "" AND uBound(collateralCovenants,2) = 0 THEN
                                    ' ### Use master value defaults ###
                                    covenantMin = covenantDefaultMin
                                    covenantMax = covenantDefaultMax
                                    covenantLastTestDate = ""
                                    covenantTestFrequency = covenantDefaultTestFrequency
                                    EXIT FOR
                                ELSEIF cStr(fieldDefId) = cStr(covenantFieldDefId) THEN
                                    covenantMin = covenantDefaultMin
                                    covenantMax = covenantDefaultMax
                                    covenantLastTestDate = Trim(collateralCovenants(COVENANT_LAST_TEST_DATE,j))
                                    covenantTestFrequency = covenantDefaultTestFrequency
        
                                    IF NOT collateralCovenants(COVENANT_USE_MASTER,j) THEN
                                        IF IsNumeric(Trim(collateralCovenants(COVENANT_MIN_VALUE,j))) THEN
                                            covenantMin = Trim(collateralCovenants(COVENANT_MIN_VALUE,j))
                                        END IF
        
                                        IF IsNumeric(Trim(collateralCovenants(COVENANT_MAX_VALUE,j))) THEN
                                            covenantMax = Trim(collateralCovenants(COVENANT_MAX_VALUE,j))
                                        END IF
        
                                        covenantTestFrequency = Trim(collateralCovenants(COVENANT_TEST_FREQUENCY,j))
                                    END IF
                                    EXIT FOR
                                END IF
                            NEXT ' ### j
        
                            ' ### Display only Active Covenants or all when dislay all is active ###
                            IF fieldIsActive Or selectedCollateralExceptionDisplay = "all" then
                                %>
                                <tr class="data-row">
                                    <% IF IsExceptionEditor THEN %>
                                    <td class="aa-tac"><a href="javascript:void(0);" onClick="openKendoDialog('Edit Covenant', 'covenantmaint.asp?collateralId=<%=targetCollateralLoanId%>&fieldDefId=<%=fieldDefId%>', 500, 700);"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Covenant" aria-hidden="true"></i></a></td>
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
                                                    Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?collateralId=" & targetCollateralLoanId & "&fieldDefId=" & fieldDefId & "', 500, 700);""><i class=""aa-icon fas fa-bell fa-fw"" title=""Covenant Value Requires Review"" aria-hidden=""true""></i></a></li>"
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
                                    IF IsNull(covenantMin) OR covenantMin = "" THEN covenantMin = "---"
                                    IF IsNull(covenantMax) OR covenantMax = "" THEN covenantMax = "---"
                                    IF IsNull(covenantLastTestDate) OR covenantLastTestDate = "" THEN covenantLastTestDate = "---"
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
                            END IF ' ### IF fieldIsActive Or selectedCollateralExceptionDisplay = "all"
                        END IF ' ### fieldDefIsCovenant
                    NEXT ' ### i
                END IF ' ### IF covenantCount = 0
                %>
            </tbody>
        </table>
        </td>
    </tr>
</table>