<%
creditExceptionTimeStart = Timer()
displayClause = ""
IF selectedCreditExceptionDisplay = "active" THEN
    displayClause = _
        " AND e.statusType='required'" & _
        " AND (" & _
        "   (e.exceptionState <> 'N' OR IsNull(excdoc.documentExceptionState,'N') <> 'N')" & _
        "   OR (e.TaskId IS NOT NULL AND e.exceptionState <> 'N')" & _
        " )"
END IF

customerExceptionQuery = _
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
    "   LEFT OUTER JOIN qryUserBankView AS ubv ON (ISNULL(e.assignedUserId, ed.defaultAssignedUserId) = ubv.userId) AND ubv.bankId = ed.bankId " & _
    "   LEFT OUTER JOIN exceptedDocument AS excdoc ON excdoc.exceptionid = e.exceptionid " & _
    "   LEFT OUTER JOIN Task AS tk ON tk.TaskId = e.TaskId " & _
    "   LEFT OUTER JOIN TaskGroup AS tg ON tg.TaskGroupId = tk.TaskGroupId " & _
    "   LEFT OUTER JOIN noticeLetterSetException nlse ON ed.exceptionDefId = nlse.exceptionDefinitionId" & _
    "   LEFT OUTER JOIN noticeLetterSet nls ON nlse.noticeLetterSetId = nls.noticeLetterSetId" & _
    "       AND nls.isEnabled = 1" & _
    " WHERE" & _
    "   e.customerId = " & dbFormatId(selectedCustomerId) & _
    "   AND e.loanId IS NULL " & _
    displayClause & _
    " ORDER BY" & _
    "   exceptionGrouping," & _
    "   ed.sortOrder ASC," & _
    "   ed.exceptionDefName ASC"
customerExceptionRS.Open customerExceptionQuery, db, adOpenStatic
exceptionColSpan = 5
IF Session("accuaccount.enableExpress") <> 1 Or Session("accuaccount.enableNotices") = 1 THEN
    exceptionColSpan = 6
END IF


' ### Process Credit Covenants for Exceptions ###
covenantExceptionCount = 0 : covenantOutOfDateCount = 0 : covenantCount = 0
Dim creditCovenants : creditCovenants = GetCreditCovenants(selectedCustomerId)
IF g_hasCreditFieldDefList THEN
    FOR i = lBound(g_creditFieldDefList,1) TO uBound(g_creditFieldDefList,2)
        fieldDefIsCovenant = Trim(g_creditFieldDefList(FIELD_DEF_IS_COVENANT,i))
        IF fieldDefIsCovenant THEN
            fieldTable = "customerFields"
            fieldColumn = "customerId" 
            fieldId = selectedCustomerId
            fieldDefId = Trim(g_creditFieldDefList(FIELD_DEF_ID,i))
            fieldDefLabel = Trim(g_creditFieldDefList(FIELD_DEF_LABEL,i))
            fieldDefName = Trim(g_creditFieldDefList(FIELD_DEF_NAME,i))
            fieldDefIsActive = Trim(g_creditFieldDefList(FIELD_DEF_IS_ACTIVE,i))
            covenantDefaultMin = trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,i))
            covenantDefaultMax = trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,i))
            covenantDefaultTestFrequency = trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,i))
            fieldValue = trim(creditFieldsRS(fieldDefName)) 'GetFlexField("customerFields", "customerId", selectedCustomerId, fieldDefName)
            fieldIsActive = trim(creditFieldsRS(fieldDefName & "_isActive"))

            IF fieldIsActive OR selectedCreditExceptionDisplay <> "active" THEN covenantCount = covenantCount + 1

            IF IsNull(fieldIsActive) OR fieldIsActive = "" THEN fieldIsActive = fieldDefIsActive

            covenantMin = covenantDefaultMin
            covenantMax = covenantDefaultMax
            covenantLastTestDate = ""
            covenantTestFrequency = covenantDefaultTestFrequency
            FOR j = lBound(creditCovenants, 1) TO uBound(creditCovenants, 2)
                covenantFieldDefId = creditCovenants(COVENANT_FIELD_DEF_ID,j)

                IF covenantFieldDefId = "" THEN
                    ' ### Use master value defaults ###
                    covenantMin = covenantDefaultMin
                    covenantMax = covenantDefaultMax
                    covenantLastTestDate = ""
                    covenantTestFrequency = covenantDefaultTestFrequency
                    EXIT FOR
                ELSEIF cStr(fieldDefId) = cStr(covenantFieldDefId) THEN
                    covenantLastTestDate = Trim(creditCovenants(COVENANT_LAST_TEST_DATE,j))
                    covenantTestFrequency = covenantDefaultTestFrequency

                    IF creditCovenants(COVENANT_USE_MASTER,j) then
                        covenantMin = covenantDefaultMin
                        covenantMax = covenantDefaultMax
                    ELSE
                        IF IsNumeric(Trim(creditCovenants(COVENANT_MIN_VALUE,j))) THEN
                            covenantMin = Trim(creditCovenants(COVENANT_MIN_VALUE,j))
                        END IF

                        IF IsNumeric(Trim(creditCovenants(COVENANT_MAX_VALUE,j))) THEN
                            covenantMax = Trim(creditCovenants(COVENANT_MAX_VALUE,j))
                        END IF

                        covenantTestFrequency = Trim(creditCovenants(COVENANT_TEST_FREQUENCY,j))
                    END IF
                    EXIT FOR
                END IF 
            NEXT 'j

            IF IsCovenantException(fieldValue, covenantMin, covenantMax) AND fieldIsActive THEN
                covenantExceptionCount = covenantExceptionCount + 1
            END IF

            IF IsCovenantOutOfDate(covenantLastTestDate, covenantTestFrequency) And fieldIsActive THEN
                covenantOutOfDateCount = covenantOutOfDateCount + 1
            END IF
        END IF
    NEXT
END IF

page = "exceptiondefselecttype.asp?action=ADD&exceptionDefType=custom&targetType=C&targetTypeId=" & customerRS("customerTypeId") & "&targetId=" & selectedCustomerId & "&bankId=" & customerRS("bankId") & "&activeTab=credit"
policyExceptionPage = "exceptiondefselectpolicy.asp?action=ADD&exceptionDefType=custom&targetType=C&targetTypeId=" & customerRS("customerTypeId") & "&targetId=" & selectedCustomerId & "&bankId=" & customerRS("bankId")
%>
<table class="aa-exceptions">
    <tr class="aa-menu-bar">
        <td colspan="<%=exceptionColSpan%>">
        <% IF Session("exceptionValidator.disableRtev") <> "1" THEN %>
        <a href="refreshexceptions.asp?processType=<%=VALIDATOR_PROCESS_CUSTOMER%>&processId=<%=selectedCustomerId%>&returnPage=customer.asp" class="aa-command-button"><i class="aa-icon fas fa-sync fa-fw" title="Refresh Exceptions" aria-hidden="true"></i></a>
        <% END IF %>
        <% IF selectedCreditExceptionDisplay="active" THEN %>
        <a href="customer.asp?creditExceptionDisplay=all" class="aa-command-button"><i class="aa-icon fas fa-search-plus fa-fw" title="Show All Exceptions" aria-hidden="true"></i></a>
        <% ELSE %>
        <a href="customer.asp?creditExceptionDisplay=active" class="aa-command-button"><i class="aa-icon fas fa-search fa-fw" title="Show Active Exceptions Only" aria-hidden="true"></i></a>
        <% END IF %>
        <% IF Session("isSuperUser") OR cInt(Session("permissionException")) >= 3 THEN %>
            <a href="javascript:void(0);" onclick="openKendoDialog('Create Custom Exception', '<%=page%>', 550, 850);" class="aa-command-button"><i class="aa-icon fas fa-exclamation-circle fa-fw" title="Add Custom Exception" aria-hidden="true"></i></a>
            <% IF Session("accuaccount.enableExpress") <> 1 OR Session("accuaccount.enableNotices") = 1 THEN %>
            <a href="javascript:void(0);" onclick="openKendoDialog('Create Custom Policy Exception', '<%=policyExceptionPage%>', 550, 850);" class="aa-command-button"><i class="aa-icon fab fa-product-hunt fa-fw" title="Add Custom Policy Exception" aria-hidden="true"></i></a>
            <% END IF %>
        <% END IF %>
        <% IF Session("isSuperUser") OR Session("permissionException") >= 2 THEN %>
        <a href="javascript:void(0);" onclick="openKendoDialog('Execute Task Group', 'executetaskgroupselect.asp?customerId=<%=selectedCustomerId%>&taskGroupType=C', 500, 800);" class="aa-command-button"><i class="aa-icon fas fa-tasks fa-fw" title="Execute Task List" aria-hidden="true"></i></a>
        <% END IF %></td>
    </tr>
    <% IF tabHasExceptions = 0 AND selectedCreditExceptionDisplay = "active" THEN %>
    <tr class="no-results">
        <td>There are No Active Document or Task Exceptions.</td>
    </tr>
    <%
    ELSE
        taskFirstTime = true
        exceptionFirstTime = true
        DO UNTIL customerExceptionRS.EOF
            Dim creditExceptionTaskId : creditExceptionTaskId = ""
            creditExceptionTaskId = customerExceptionRS("TaskId")
            assignedUserId = CheckForNull( customerExceptionRS("assignedUserId"))
            transferableByUser = customerExceptionRS("TransferableByUser")

            ' ### Determine if user can reassign Exceptions ###
            allowReassignException = false
            IF customerExceptionRS("computationType") = "manual" THEN
                IF Trim(creditExceptionTaskId & "") = "" THEN
                    IF Session("isSuperUser") _
                        OR Session("credit.isAdmin") _
                        OR Session("permissionException") >= 2 _
                        OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                            allowReassignException = true
                    END IF
                ELSE
                    IF Session("isSuperUser") _
                        OR Session("credit.isAdmin") _
                        OR (Session("permissionException") >= 2 AND transferableByUser) _
                        OR (cStr(Session("userId")) = cStr(assignedUserId) AND transferableByUser) THEN
                            allowReassignException = true
                    END IF
                END IF
            ELSEIF customerExceptionRS("computationType") = "computed" THEN
                IF Session("isSuperUser") _
                    OR Session("credit.isAdmin") _
                    OR Session("permissionException") >= 2 _
                    OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                        allowReassignException = true
                END IF
            END IF

            ' ### Determine if user can resolve Task Exceptions ###
            allowResolveTask = false
            IF Session("isSuperUser") _
                OR Session("permissionException") >= 2 _
                OR cStr(Session("userId")) = cStr(assignedUserId) THEN
                    allowResolveTask = true
            END IF

            IF Trim(checkForNull(customerExceptionRS("documentExceptionState"))) = "" THEN
                exceptionState = customerExceptionRS("exceptionState")
            ELSE
                exceptionState = customerExceptionRS("documentExceptionState")
            END IF

            editUrl = "exceptionmaint.asp?exceptionId=" & customerExceptionRS("exceptionId") & "&customerId=" & customerId & "&exceptionDocId=" & customerExceptionRS("exception_documentId")

            IF taskFirstTime AND customerExceptionRS("computationType") = "manual" THEN
                taskFirstTime = false
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
                    <% END IF %>
                    <td>Assigned User</td>
                </tr>
                <%
            ELSEIF exceptionFirstTime AND customerExceptionRS("computationType") = "computed" THEN
                exceptionFirstTime = false
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
                    <% END IF %>
                    <td>Assigned User</td>
                </tr>
                <%
            END IF
            %>
            <tr class="data-row">
                <td class="aa-exception-icon-list">
                    <ul>
                        <li><a name="except<%=customerExceptionRS("exceptionId")%>" href="javascript:void(0);" onclick="openKendoDialog('Edit Exception Properties', '<%=editUrl%>', 550, 850);"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                        <% IF customerExceptionRS("exceptionState") <> "N" AND allowReassignException THEN %>
                        <li><a href="javascript:void(0);" onclick="openKendoDialog('Edit Exception Properties', 'reassigntask.asp?exceptionId=<%=customerExceptionRS("exceptionId")%>&section=credit', 500, 850);"><i class="aa-icon fas fa-user fa-fw" title="Reassign Task" aria-hidden="true"></i></a></li>
                        <% ELSE %>
                        <li>&nbsp;</li>
                        <% END IF %>
                        <% IF customerExceptionRS("computationType") = "manual" AND customerExceptionRS("exceptionState") <> "N" And allowResolveTask THEN %>
                        <li><a href="resolvetask.asp?exceptionId=<%=customerExceptionRS("exceptionId")%>&section=credit"><i class="aa-icon fas fa-check fa-fw" title="Resolve Task" aria-hidden="true"></i></a></li>
                        <% ELSE %>
                        <li>&nbsp;</li>
                        <% END IF %>
                    </ul>
                </td> 
                <% IF customerExceptionRS("docName") <> "" THEN %>
                <td class="description"><%=customerExceptionRS("exceptionDefName")%> (<em> <%=customerExceptionRS("docName")%></em> )</td>
                <% ELSE %>
                <td class="description"><%=customerExceptionRS("exceptionDefName")%></td>
                <% END IF %>
                <td class="aa-exception-icon-list">
                    <ul>
                        <%
                        IF customerRS("ignoreExceptionsYN") = "Y" THEN
                            Response.Write "<li>Ignored</li>"
                        ELSEIF customerExceptionRS("statusType") = "n/a" THEN
                            Response.Write "<li>N/A</li>"
                        ELSEIF exceptionState = "Y" THEN
                            Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-color-danger"" title=""Exception"" aria-hidden=""true""></i></li>"
                        ELSEIF exceptionState = "P" THEN
                            Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-color-warning"" title=""Pending Exception"" aria-hidden=""true""></i></li>"
                        ELSE
                            Response.Write "<li>&nbsp;</li>"
                        END IF
                        IF NOT IsNull(customerExceptionRS("PolicyId")) THEN
                            Response.Write "<li><i class=""aa-icon fab fa-product-hunt fa-fw"" aria-hidden=""true""></i>"
                        ELSE
                            Response.Write "<li>&nbsp;</li>"
                        END IF
                        %>
                    </ul>
                </td>
                <% IF Trim(CheckForNull(customerExceptionRS("comment"))) <> "" THEN %>
                <td class="aa-tac"><a href="javascript:void(0);" onclick="openKendoDialog('View Exception Comment', 'viewcomment.asp?exceptionId=<%=customerExceptionRS("exceptionId")%>&type=exception', 400, 500);"><i class="aa-icon fas fa-comments fa-fw" title="<%=CheckForNull(customerExceptionRS("comment"))%>" aria-hidden="true"></i></a></td>
                <% ELSE %>
                <td>&nbsp;</td>
                <% END IF %>
                <% IF Session("accuaccount.enableExpress") <> 1 OR Session("accuaccount.enableNotices") = 1 THEN %>
                    <td class="aa-tac"><%
                        Dim creditNoticeLetterSetId  : creditNoticeLetterSetId  = customerExceptionRS("noticeLetterSetId") & ""
                        Dim creditNoticeImageType    : creditNoticeImageType    = ""
                        Dim creditNoticeMsg          : creditNoticeMsg          = ""
                        IF  creditNoticeLetterSetId <> "" THEN
                            response.write  "<i class=""aa-icon far fa-envelope" & creditNoticeImageType & """ title=""" & creditNoticeMsg & """ aria-hidden=""true""></i>"
                        END IF
                    %></td>
                <% END IF %>
                <td><%
                assignedUser = customerExceptionRS("userFirstName") & " " & customerExceptionRS("userLastName")
                IF Len(trim(assignedUser)) = 0 THEN assignedUser = "Unassigned"
                Response.Write assignedUser
                %></td>
            </tr>
            <%
            customerExceptionRS.MoveNext
        LOOP
    END IF ' ### customerExceptionRS.EOF
    %>
    <tr class="header">
        <td colspan="<%=exceptionColSpan%>"><h3>Covenants</h3></td>
    </tr>
    <tr>
        <td colspan="<%=exceptionColSpan%>">
        <table class="aa-convenants">
            <tr class="aa-column-headers">
                <td class="aa-tac">Action</td>
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
                    FOR i = lBound(g_creditFieldDefList,1) TO uBound(g_creditFieldDefList,2)
                        fieldDefIsCovenant = Trim(g_creditFieldDefList(FIELD_DEF_IS_COVENANT,i))
                        IF fieldDefIsCovenant THEN
                            fieldTable = "customerFields"
                            fieldColumn = "customerId" 
                            fieldId = selectedCustomerId
                            fieldDefId = Trim(g_creditFieldDefList(FIELD_DEF_ID,i))
                            fieldDefLabel = Trim(g_creditFieldDefList(FIELD_DEF_LABEL,i))
                            fieldDefName = Trim(g_creditFieldDefList(FIELD_DEF_NAME,i))
                            fieldDefIsActive = Trim(g_creditFieldDefList(FIELD_DEF_IS_ACTIVE,i))
                            isCovenant = Trim(g_creditFieldDefList(FIELD_DEF_IS_COVENANT,i))
                            covenantDefaultMin = Trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,i))
                            covenantDefaultMax = Trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,i))
                            covenantDefaultTestFrequency = Trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,i))
                            fieldValue = Trim(creditFieldsRS(fieldDefName))
                            fieldIsActive = Trim(creditFieldsRS(fieldDefName & "_isActive"))
			        
                            IF IsNull(fieldIsActive) OR fieldIsActive = "" THEN
                                fieldIsActive = fieldDefIsActive
                            END IF
			        
                            covenantMin = covenantDefaultMin
                            covenantMax = covenantDefaultMax
                            covenantLastTestDate = ""
                            covenantTestFrequency = covenantDefaultTestFrequency
                            FOR j = lBound(creditCovenants,1) TO uBound(creditCovenants,2)
                                covenantFieldDefId = Trim(creditCovenants(COVENANT_FIELD_DEF_ID,j))
			        
                                IF covenantFieldDefId = "" AND UBound(creditCovenants,2) = 0 THEN
                                    ' ### Use master value defaults ###
                                    covenantMin = covenantDefaultMin
                                    covenantMax = covenantDefaultMax
                                    covenantLastTestDate = ""
                                    covenantTestFrequency = covenantDefaultTestFrequency
                                    EXIT FOR
                                ELSEIF cStr(fieldDefId) = cStr(covenantFieldDefId) THEN
                                    covenantLastTestDate = Trim(creditCovenants(COVENANT_LAST_TEST_DATE,j))
                                    covenantTestFrequency = covenantDefaultTestFrequency
			        
                                    IF creditCovenants(COVENANT_USE_MASTER, j) THEN
                                        covenantMin = covenantDefaultMin
                                        covenantMax = covenantDefaultMax
                                    ELSE
                                        IF IsNumeric(Trim(creditCovenants(COVENANT_MIN_VALUE,j))) THEN
                                            covenantMin = Trim(creditCovenants(COVENANT_MIN_VALUE,j))
                                        END IF
			        
                                        IF IsNumeric(Trim(creditCovenants(COVENANT_MAX_VALUE,j))) THEN
                                            covenantMax = Trim(creditCovenants(COVENANT_MAX_VALUE,j))
                                        END IF
			        
                                        covenantTestFrequency = Trim(creditCovenants(COVENANT_TEST_FREQUENCY,j))
                                    END IF
                                    EXIT FOR
                                END IF
                            NEXT ' ### j
			        
                            ' ### Display only Active Covenants or all when dislay all is active ###
                            IF fieldIsActive OR selectedCreditExceptionDisplay <> "active" THEN
                                %>
                                <tr class="data-row">
                                    <% IF IsExceptionEditor THEN %>
                                    <td class="aa-tac"><a href="javascript:void(0);" onClick="openKendoDialog('Edit Covenant', 'covenantmaint.asp?customerId=<%=selectedCustomerId%>&fieldDefId=<%=fieldDefId%>', 500, 700);"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Covenant" aria-hidden="true"></i></a></td>
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
                                                    Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?customerId=" & customerId & "&fieldDefId=" & fieldDefId & "', 500, 700);""><i class=""aa-icon fas fa-bell fa-fw"" title=""Covenant Value Requires Review"" aria-hidden=""true""></i></a></li>"
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
                                    IF IsNull(fieldValue) OR Trim(fieldValue & "") = "" THEN fieldValue = "---"
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
                            END IF ' ### IF fieldIsActive OR selectedCreditExceptionDisplay <> "active"
                        END IF ' ### IF fieldDefIsCovenant
                    NEXT ' ### i
                END IF ' ### IF covenantCount = 0
                %>
            </tbody>
        </table>
        </td>
    </tr>
    <% customerExceptionRS.Close %>
</table>
<%
creditExceptionTimeStop = Timer()
creditExceptionTimeDelta = creditExceptionTimeDelta + creditExceptionTimeStop - creditExceptionTimeStart
%>