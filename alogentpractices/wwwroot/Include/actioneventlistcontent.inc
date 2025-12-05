<%
Dim statusIconPath
Dim i, idx, sortOrder

Dim actionGroupIdx, actionGroupLabel, actionType, actionSortOrder
Dim actionEventQuery, titleWrapperClass
Dim actionEventRS : Set actionEventRS = Server.CreateObject("ADODB.RecordSet")

FOR actionGroupIdx = 1 TO 3
    IF actionGroupIdx = 1 THEN
        actionType = "lender"
        actionGroupLabel = "Lender"
        actionSortOrder = "lenderSortOrder"
        actionEventQuery = "SELECT *, (SELECT COUNT(actionEventId) from actionEventTimer where actionEventId=ae.actionEventId) as hastimer FROM actionEvent ae WHERE isLenderAction=1 AND loanTypeId=" & dbFormatId(accountTypeId) & " ORDER BY lenderSortOrder, actionEventName"
        titleWrapperClass = "top"
    ELSEIF actionGroupIdx = 2 THEN
        actionType = "analyst"
        actionGroupLabel = "Analyst"
        actionSortOrder = "analystSortOrder"
        actionEventQuery = "SELECT *, (SELECT COUNT(actionEventId) from actionEventTimer where actionEventId=ae.actionEventId) as hastimer FROM actionEvent ae WHERE isAnalystAction=1 AND loanTypeId=" & dbFormatId(accountTypeId) & " ORDER BY analystSortOrder, actionEventName"
        titleWrapperClass = "spacer"
    ELSEIF actionGroupIdx = 3 THEN
        actionType = "approver"
        actionGroupLabel = "Approver"
        actionSortOrder = "approverSortOrder"
        actionEventQuery = "SELECT *, (SELECT COUNT(actionEventId) from actionEventTimer where actionEventId=ae.actionEventId) as hastimer FROM actionEvent ae WHERE isApproverAction=1 AND loanTypeId=" & dbFormatId(accountTypeId) & " ORDER BY approverSortOrder, actionEventName"
        titleWrapperClass = "spacer"
    END IF
    %>
    <div class="<%=titleWrapperClass%>">
        <h2><%=actionGroupLabel%> Workflow Actions</h2>
    </div>
    <%
    actionEventRS.Open actionEventQuery, db, adOpenStatic, adCmdText
    Dim nLoop : nLoop = 0
    IF NOT actionEventRS.EOF THEN
    %>
    <div class="action-grid" id="action-grid">
        <div class="action-grid-row pre-header">
            <div style="width:25%">&nbsp;</div>
            <div style="width:12%" class="head-background"><b>Assign</b></div>
            <div style="width:16%" class="head-background"><b>Notify</b></div>
            <div style="width:12%" class="head-background"><b>Set Status</b></div>
            <div style="width:35%" class="head-space">&nbsp;</div>
        </div>
        <div class="action-grid-row header">
            <div style="width:8%">&nbsp;</div>
            <div style="width:17%">Action&nbsp;Name</div>
            <div>Lender</div>
            <div>Analyst</div>
            <div>Approver</div>
            <div>Lender</div>
            <div>Analyst</div>
            <div>Approver</div>
            <div>Other</div>
            <div>Loan</div>
            <div class="multi-line">Credit<br/>Analysis</div>
            <div>Approval</div>
            <div class="multi-line">Enforce<br/>Limit</div>
            <div class="w5 multi-line">Manage<br/>Conditions</div>
            <div class="w5 multi-line">Lock<br/>Application</div>
            <div class="w5 multi-line">Build<br/>Snapshot</div>
            <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
            <div class="multi-line">Generate<br/>Tasks</div>
            <% END IF 'Session("accuaccount.enableExpress") <> 1 %>
            <div class="multi-line">Declined<br/>Reason</div>
            <div class="multi-line">Timed<br/>Action</div>
            <div class="multi-line">Execute<br/>Program</div>
        </div>
        <div id="actions-<%=accountTypeId%>-<%=actionType%>" class="actions">
            <%
            idx = 1
            DO UNTIL actionEventRS.EOF
                IF CheckForNull(actionEventRS(actionSortOrder)) = "" THEN
                    sortOrder = idx
                ELSE
                    sortOrder = actionEventRS(actionSortOrder)
                END IF
                %>
                <div class="action" data-account-type="<%=accountTypeId%>" data-action-type="<%=actionType%>" data-rowid="<%=i%>" id="<%=RemoveCurlyBrackets(actionEventRS("actionEventId"))%>">
                    <table cellpadding="0" cellspacing="0" class="row-content">
                        <tr>
                            <td class="w2"><img src="Content/Images/Icons/dragger.gif" class="handler" alt=""></td>
                            <td class="w2"><a href="actioneventdeleteconfirm.asp?actionEventId=<%=actionEventRS("actionEventId")%>&actionEventName=<%=replace(actionEventRS("actionEventName")," ","%20")%>&tab=<%=accountTypeCode%>&bankId=<%=bankId%>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete" aria-hidden="true"></i></a></td>
                            <td class="w2"><a href="actioneventmaint.asp?action=COPY&actionEventId=<%=actionEventRS("actionEventId")%>&tab=<%=accountTypeCode%>&bankId=<%=bankId%>" class="aa-command-link"><i class="aa-icon far fa-copy fa-fw" title="Clone the Action" aria-hidden="true"></i></a></div>
                            <td class="w2"><a href="actioneventmaint.asp?action=EDIT&actionEventId=<%=actionEventRS("actionEventId")%>&tab=<%=accountTypeCode%>&bankId=<%=bankId%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></div>
                            <td>
                                <div class="event-name" title="<%=actionEventRS("actionEventName")%>">
                                    <span class="event"><%=actionEventRS("actionEventName")%></span>
                                    <span class="more-less"><a href="javascript:void(0);" id="more-less-<%=i%>">more...</a></span>
                                </td>
                            </td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("selectLender"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("selectAnalyst"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("selectApprover"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("notifyLender"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("notifyAnalyst"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("notifyApprover"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("notifyOther"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("setLoanStatus"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("setCreditAnalysisStatus"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("setApprovalStatus"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("enforceApprovalLimit"), "", "")%></td>
                            <td class="w5"><%=ShowCheckmark(actionEventRS("editConditions"), "", "")%></div>
                            <td class="w5"><%=ShowCheckmark(actionEventRS("setLockApplication"), "", "")%></div>
                            <td class="w5"><%=ShowCheckmark(actionEventRS("buildApplicationSnapshot"), "", "")%></div>
                            <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("GenerateTasks"), "", "")%></td>
                            <% END IF %>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("selectDeclinedReason"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("hastimer"), "", "")%></td>
                            <td class="w4"><%=ShowCheckmark(actionEventRS("executeprogram"), "", "")%></td>
                        </tr>
                        <tr id="desc-<%=i%>" style="display:none">
                            <%
                            IF Trim(actionEventRS("actionEventDescription") & "") <> "" THEN
                                %><td colspan="23" class="description"><%=actionEventRS("actionEventDescription")%></td><%
                            ELSE
                                %><td colspan="23" class="description">---</td><%
                            END IF
                            %>
                        </tr>
                    </table>
                </div>
                <%
                i = i + 1
                idx = idx + 1
                actionEventRS.MoveNext
            LOOP
        %></div>
    </div><%
ELSE
    %><div class="no-records">There are no <%=actionGroupLabel%> actions defined.</div><%
END IF ' ### actionEvent.EOF
actionEventRS.Close
NEXT ' ### actionGroupIdx
%>

<!-- Template for Clone Workflow type selector dialog -->
<script type="text/x-kendo-template" id="aa-clone-workflow-dialog">
    <div id="aa-clone-workflow-content">
        Select Loan Type to Clone to
        &nbsp;
        <i id="aa-type-list-loading" class="fas fa-cog fa-spin fa-fw" aria-hidden="true"></i>
        <select id="targetLoanTypeId"></select>
        <span id="aa-empty-list-message" class="aa-color-danger">There are no empty Loan Types to Clone to.</span>
        <div class="aa-button-wrapper-absolute">
            <ul>
                <li><button id="aa-clone-confirm" class="k-button k-primary">Update</button></li>
                <li><button id="aa-clone-cancel" class="k-button">Cancel</button></li>
            </ul>
        </div>
    </div>
</script>