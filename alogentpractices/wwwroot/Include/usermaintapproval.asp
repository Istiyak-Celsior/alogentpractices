<div class="aa-panel">
    <div>
        <h2 class="tab-title">Approval / Underwriting Security Settings</h2>
        <%
        checked = ""
        IF isApprover THEN checked = " checked=""checked"""

        disabled = ""
        IF NOT isApprover THEN disabled = " disabled=""disabled"""

        Dim approvalLimit, renewalLimit
        Dim defaultApprovalLimit : defaultApprovalLimit = loanApprovalLimit
        IF NOT IsNumeric(defaultApprovalLimit) THEN defaultApprovalLimit = 0.0
        defaultApprovalLimit = FormatCurrency(defaultApprovalLimit,2)
        %>
        <table class="aa-two-column-form-table">
            <tr>
                <td>Is an Approver?</td>
                <td><input type="checkbox" class="k-checkbox" name="isApprover" id="is-approver" value="1" onclick="changeApprovalSecurity(frmUserMaint);"<%=checked%>/><label class="k-checkbox-label" for="is-approver"></label></td>
            </tr>
            <tr>
                <td>Default Approval Limit?</td>
                <td><input type="text" class="k-textbox" name="loanApprovalLimit" value="<%=defaultApprovalLimit%>"<%=disabled%>/>
                <input type="hidden" name="orgLoanApprovalLimit" value="<%=defaultApprovalLimit%>"/></td>
            </tr>
            <%
            checked = ""
            IF isAnalyst THEN checked = " checked=""checked"""
            %>
            <tr>
                <td>Is an Analyst?</td>
                <td><input type="checkbox" class="k-checkbox" name="isAnalyst" id="is-analyst" value="1" onclick="changeApprovalSecurity(frmUserMaint);"<%=checked%>/><label class="k-checkbox-label" for="is-analyst"></label></td>
            </tr>
            <%
            checked = ""
            IF isLender THEN checked = " checked=""checked"""
            %>
            <tr>
                <td>Is a Lender?</td>
                <td><input type="checkbox" class="k-checkbox" name="isLender" id="is-lender" value="1" onclick="changeApprovalSecurity(frmUserMaint);"<%=checked%>/><label class="k-checkbox-label" for="is-lender"></label></td>
            </tr>
            <%
            checked = ""
            IF isLoanProcessor THEN checked = " checked=""checked"""
            %>
            <tr>
                <td>Is a Loan Delegate?</td>
                <td><input type="checkbox" class="k-checkbox" name="isLoanProcessor" id="is-loan-processor" value="1" onclick="changeApprovalSecurity(frmUserMaint);"<%=checked%>/><label class="k-checkbox-label" for="is-loan-processor"></label></td>
            </tr>
        </table>
    </div>
    <div>
        <div class="top">Override Default Approval Limit by Loan Type. Leave field blank to use Default Limit.</div>
        <table class="aa-kendo-grid">
            <thead>
                <tr>
                    <th>Loan Type</th>
                    <th class="aa-tac">New Application Limit</th>
                    <th class="aa-tac">Renewal Limit</th>
                </tr>
            </thead>
            <tbody>
                <%
                Dim approvalLimitRS : Set approvalLimitRS = Server.CreateObject("ADODB.RecordSet")
                Dim approvalLimitQuery : approvalLimitQuery = _
                    " SELECT " & _
                    "   lt.*," & _
                    "   ual.ApprovalLimit," & _
                    "   ual.RenewalLimit" & _
                    " FROM" & _
                    "   loanType AS lt INNER JOIN accountClass AS ac" & _
                    "       ON lt.accountClassId = ac.accountClassId" & _
                    "   LEFT OUTER JOIN UserApprovalLimit AS ual" & _
                    "       ON lt.loanTypeId = ual.loanTypeId" & _
                    "       AND ual.userId = " & dbFormatId(userId) & _
                    " WHERE" & _
                    "   ac.accountClassCode LIKE 'loan'" & _
                    "   AND lt.isCollateralType = 0" & _
                    " ORDER BY lt.loanTypeDescription"
                approvalLimitRS.Open approvalLimitQuery, db
                i = 0
                DO UNTIL approvalLimitRS.EOF
                    approvalLimit = CheckForNull(approvalLimitRS("approvalLimit"))
                    renewalLimit = CheckForNull(approvalLimitRS("RenewalLimit"))
                    IF IsNumerIc(approvalLimit) THEN approvalLimit = FormatCurrency(approvalLimit,2)
                    IF IsNumeric(renewalLimit) THEN renewalLimit = Formatcurrency(renewalLimit,2)
                    %>
                    <tr>
                        <td><%=approvalLimitRS("loanTypeDescription")%>:</td>
                        <td class="aa-tac"><input type="text" class="k-textbox" id="approvalLimit_<%=i%>" name="<%=approvalLimitRS("loanTypeId")%>" maxlength="15" value="<%=approvalLimit%>"<%=disabled%>/></td>
                        <td class="aa-tac"><input type="text" class="k-textbox" id="renewalLimit_<%=i%>" name="renewal_<%=approvalLimitRS("loanTypeId")%>" maxlength="15" value="<%=renewalLimit%>"<%=disabled%>/></td>
                    </tr>
                    <%
                    i = i + 1
                    approvalLimitRS.MoveNext
                LOOP
                %>
            </tbody>
        </table>
    </div>
</div>