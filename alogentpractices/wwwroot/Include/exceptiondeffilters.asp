<main class="inner filters">
    <div class="filters">
        <h2>Account Balance and Commitment Filters</h2>
        <p><i>Disable exception when:</i></p>
        <%
        IF amountThresholdFlag = "" THEN amountThresholdFlag = 0
        checked = ""
        IF amountThresholdFlag = 0 THEN checked = " checked=""checked"""
        %>
        <div><input type="radio" class="k-radio" name="amountThresholdFlag" id="amount-threshold-flag0" value="0"<%=checked%>/><label class="k-radio-label" for="amount-threshold-flag0">Never disable exception due to balance or commitment amounts.</label></div>
        <%
        checked = ""
        IF amountThresholdFlag = 1 THEN checked = " checked=""checked"""
        %>
        <div><input type="radio" class="k-radio" name="amountThresholdFlag" id="amount-threshold-flag1" value="1"<%=checked%>/><label class="k-radio-label" for="amount-threshold-flag1">Total Account Balances goes below the threshold amount.</label></div>
        <%
        checked = ""
        IF amountThresholdFlag = 2 THEN checked = " checked=""checked"""
        %>
        <div><input type="radio" class="k-radio" name="amountThresholdFlag" id="amount-threshold-flag2" value="2"<%=checked%>/><label class="k-radio-label" for="amount-threshold-flag2">Total Commitment Amounts goes below the threshold amount.</label></div>
        <% IF exceptionDefType = "loan" THEN %>
            <%
            checked = ""
            IF amountThresholdFlag = 3 THEN checked = " checked=""checked"""
            %>
            <div><input type="radio" class="k-radio" name="amountThresholdFlag" id="amount-threshold-flag3" value="3"<%=checked%>/><label class="k-radio-label" for="amount-threshold-flag3">Account Balance goes below the threshold amount.</label></div>
            <%
            checked = ""
            IF amountThresholdFlag = 4 THEN checked = " checked=""checked"""
            %>
            <div><input type="radio" class="k-radio" name="amountThresholdFlag" id="amount-threshold-flag4" value="4"<%=checked%>/><label class="k-radio-label" for="amount-threshold-flag4">Account Commitment Amount goes below the threshold amount.</label></div>
        <% END IF ' ### exceptionDefType = "loan" %>
        <%
        IF IsNumeric(amountThreshold) THEN
            strThreshold = FormatCurrency(amountThreshold)
        ELSE
            strThreshold = FormatCurrency(0.00)
        END IF
        %>
        <div class="threshold-amount"><b>Threshold Amount:</b> &nbsp; <input type="text" class="k-textbox" name="amountThreshold" value="<%=strThreshold%>"/></div>
    </div>
    <div>
        <%
        IF exceptionDefType = "loan" OR (exceptionDefType = "custom" AND activeTab <> "credit") THEN
            Dim loanStatusQuery
            Dim loanStatuRS : Set loanStatusRS = Server.CreateObject("ADODB.RecordSet")
            IF action = "ADD" THEN
                loanStatusQuery = _
                    " SELECT" & _
                    "   ls.*," & _
                    "   NULL AS exceptionIgnoreLoanStatusId," & _
                    "   ac.accountClassName," & _
                    "   ac.accountClassCode" & _
                    " FROM" & _
                    "   loanStatus AS ls INNER JOIN accountClass AS ac" & _
                    "       ON ls.accountClassId=ac.accountClassId" & _
                    " WHERE" & _
                    "   ac.accountClassCode LIKE " & dbFormatText(activeTab) & _
                    " ORDER BY" & _
                    "   ls.isApplicationStatus ASC," & _
                    "   ls.statusDescription"
            ELSE
                loanStatusQuery = _
                    " SELECT" & _
                    "   ls.*," & _
                    "   v1.exceptionIgnoreLoanStatusId," & _
                    "   ac.accountClassName," & _
                    "   ac.accountClassCode" & _
                    " FROM" & _
                    "   exceptionDefinition AS ed INNER JOIN loanType AS lt" & _
                    "       ON ed.loanTypeId=lt.loanTypeId" & _
                    "   INNER JOIN accountClass AS ac" & _
                    "       ON ac.accountClassId=lt.accountClassId" & _
                    "   INNER JOIN loanStatus AS ls" & _
                    "       ON ls.accountClassId=ac.accountClassId" & _
                    "   LEFT OUTER JOIN " & _
                    "   (SELECT * FROM exceptionIgnoreLoanStatus WHERE exceptionDefId=" & dbFormatId(exceptionDefId) & ") AS v1" & _
                    "       ON ls.statusId=v1.loanStatusId" & _
                    " WHERE" & _
                    "   ed.exceptionDefId=" & dbFormatId(exceptionDefId) & _
                    " ORDER BY" & _
                    "   ls.isApplicationStatus ASC," & _
                    "   ls.statusDescription"
            END IF
            loanStatusRS.Open loanStatusQuery, db, adOpenStatic, adCmdText

            Dim filterTypeHeader
            IF loanStatusRS("accountClassCode") = "loan" THEN
                IF Session("accuaccount.enableExpress") <> 1 AND Session("enableApprovalsYN") = "Y" THEN
                    filterTypeHeader = "Loan/Application"
                ELSE
                    filterTypeHeader = "Loan"
                END IF
            ELSE
                filterTypeHeader = loanStatusRS("accountClassName")
            END IF
            %>
            <h2><%=filterTypeHeader%> Status Filters</h2>
            <p><i>Check Statuses that this Exception Type will be Active for.</i></p>
            <div class="aa-kendo-grid-wrapper">
                <table class="aa-kendo-grid no-border">
                    <thead>
                        <tr>
                            <th class="aa-tac">Allow</th>
                            <th><%=loanStatusRS("accountClassName")%> Status</th>
                            <th class="aa-tac">Is Active<br/><%=loanStatusRS("accountClassName")%> Status?</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Dim checked, imgActiveStatus
                        Dim statusCount : statusCount = loanStatusRS.RecordCount
                        Dim checkCount : checkCount = 0
                        Dim idx : idx = 0
                        Dim isApplicationStatus : isApplicationStatus = 0
                        DO UNTIL loanStatusRS.EOF
                            IF isApplicationStatus <> loanStatusRS("isApplicationStatus") THEN
                                isApplicationStatus = loanStatusRS("isApplicationStatus")
                                %><tr class="header">
                                    <td class="aa-tac">Allow</td>
                                    <td>Application Status</td>
                                    <td class="aa-tac">Is Active<br/>Application Status?</td>
                                </tr><%
                            END IF
                            IF loanStatusRS("isApplicationStatus") THEN
                                ' ### Set active image icon for application status ###
                                IF loanStatusRS("isActiveApplicationStatus") THEN
                                    imgActiveStatus = "fa-circle aa-status-yes fa-fw"
                                ELSE
                                    imgActiveStatus = "fa-circle aa-status-no fa-fw"
                                END IF
                            ELSE
                                ' ### Set active image icon for loan status ###
                                IF loanStatusRS("isActive") THEN
                                    imgActiveStatus = "fa-circle aa-status-yes fa-fw"
                                ELSE
                                    imgActiveStatus = "fa-circle aa-status-no fa-fw"
                                END IF
                            END IF

                            ' ### Check to see if a exceptionIgnoreLoanStatusId value exists. ###
                            checked = ""
                            IF CheckForNull(loanStatusRS("exceptionIgnoreLoanStatusId")) = "" THEN
                                checked = " checked=""checked"""
                                checkCount = checkCount + 1
                            END IF
                            %><tr>
                                <td class="aa-tac"><input type="checkbox" class="k-checkbox" name="checkStatusIndex" id="checkstatusindex<%=idx%>" value="<%=idx%>" onclick="javascript:toggleCheckbox(checkAllStatus, checkStatusIndex);"<%=checked%>/><label class="k-checkbox-label" for="checkstatusindex<%=idx%>"></label>
                                <input type="hidden" name="statusIndex" value="<%=idx%>"/>
                                <input type="hidden" name="loanStatusId" value="<%=loanStatusRS("statusId")%>"/>
                                <input type="hidden" name="exceptionIgnoreLoanStatusId" value="<%=loanStatusRS("exceptionIgnoreLoanStatusId")%>"/></td>
                                <td><%=loanStatusRS("statusDescription")%></td>
                                <td class="aa-tac"><i class="fa <%=imgActiveStatus%>" aria-hidden="true"></i></td>
                            </tr>
                            <%
                            idx = idx + 1
                            loanStatusRS.MoveNext()
                        LOOP
                        loanStatusRS.Close

                        checked = ""
                        IF checkCount = statusCount THEN checked = " checked=""checked"""
                        %><tr>
                            <td class="aa-tac"><input type="checkbox" class="k-checkbox" name="checkAllStatus" id="check-all-status" value=""<%=checked%> onclick="toggleCheckboxAll(checkAllStatus,checkStatusIndex);"/><label class="k-checkbox-label" for="check-all-status"></label></td>
                            <td colspan="3" style="font-style:italic; font-weight:bold;">Check/Uncheck All</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        <% END IF ' ### exceptionDefType = "loan" %>
    </div>
</main>