<div id="tabstrip">
    <ul>
        <%
        Dim tabLoop : tabLoop = 0
        Dim accountClassRS : Set accountClassRS = Server.CreateObject("ADODB.RecordSet")
        Dim accountClassQuery : accountClassQuery = "SELECT accountClassName FROM accountClass ORDER BY accountClassSortOrder"
        accountClassRS.Open accountClassQuery, db, adOpenStatic, adCmdText
        DO UNTIL accountClassRS.EOF
            Dim accClassName : accClassName = accountClassRS("accountClassName")
            Dim hasAccess : hasAccess = _
                Session(accClassName & ".isAdmin") _
                OR Session(accClassName & ".allowEdit") _
                OR Session(accClassName & ".allowAdd") _
                OR Session(accClassName & ".allowRead") _
                OR Session("isSuperUser")

            IF accClassName = "loan" THEN
                hasAccess = hasAccess _
                    OR Session("loanapp.isAdmin") _
                    OR Session("loanapp.allowEdit") _
                    OR Session("loanapp.allowAdd") _
                    OR Session("loanapp.allowRead")
            END IF

            IF hasAccess THEN
                IF tabLoop = 0 THEN
                    Response.Write "<li class=""k-state-active"">" & accClassName & "</li>"
                ELSE
                    Response.Write "<li>" & accClassName & "</li>"
                END IF
                tabLoop = tabloop + 1
            END IF
            accountClassRS.MoveNext
        LOOP
        accountClassRS.Close
        %>
    </ul>
    <%
    Dim loginID : loginID = session("userID")
    
    Dim accountRS : Set accountRS = Server.CreateObject("ADODB.RecordSet")
    Dim accountQuery : accountQuery = "SELECT * FROM accountClass ORDER BY accountClassSortORder"
    accountRS.Open accountQuery, db, adOpenStatic, adCmdText
    
    DO UNTIL accountRS.EOF
        accountClassId = accountRS("accountClassId")
        accountClassName = accountRS("accountClassName")
        accountClassCode = accountRS("accountClassCode")
        extAccountClassCode = accountRS("accountClassCode")
        enableActionDisplayOnly = False
        enableActionDisplayData = False

        Dim Loan : Set Loan = Server.CreateObject("ADODB.Recordset")
        Dim LoanQuery : LoanQuery = _
            " SELECT" & _
            "   pl.*," & _
            "   lt.loanTypeDescription," & _
            "   ls.statusDescription," & _
            "   ls.isApplicationStatus," & _
            "   ac.accountClassCode," & _
            "   (SELECT COUNT(rowguid) FROM collateral WHERE parentLoanId=pl.loanId) AS collateralCount," & _
            "   (SELECT COUNT(loanId) FROM loan wHERE primaryCollateralId=pl.loanId) AS crossCollateralCount" & _
            " FROM" & _
            "   loan AS pl INNER JOIN loanType AS lt" & _
            "       ON pl.loanTypeId=lt.loanTypeId" & _
            "   INNER JOIN loanStatus AS ls" & _
            "       ON ls.statusId=pl.loanStatusId" & _
            "   INNER JOIN accountClass AS ac" & _
            "       ON ac.accountClassId=ls.accountClassId" & _
            " WHERE" & _
            "   pl.customerId=" & dbFormatId(customerId) & _
            "   AND ac.accountClassId=" & dbFormatId(accountClassId) & _
            "   AND pl.isCollateralYN='N'" & _
            "   AND pl.isCrossCollateralYN='N'"
        IF NOT (Session("loanapp.allowRead") OR Session("loanapp.allowEdit") OR Session("isSuperUser") OR Session("credit.isAdmin")) THEN
            LoanQuery = LoanQuery & " AND ls.isApplicationStatus = 0"
        END IF
        LoanQuery = LoanQuery & " ORDER BY pl.loanNumber"
        Loan.Open LoanQuery, db, adOpenStatic
    
        accountCount = Loan.RecordCount
    
        IF accountCount > 0 THEN
            enableActionDisplayData = _
                Session(extAccountClassCode & ".isAdmin") _
                Or Session(extAccountClassCode & ".allowEdit") _
                Or Session(extAccountClassCode & ".allowAdd") _
                Or Session(extAccountClassCode & ".allowRead") _
                Or Session("isSuperUser")
    
                IF extAccountClassCode = "loan" THEN
                    enableActionDisplayData = _
                        enableActionDisplayData _
                        OR Session("loanapp.isAdmin") _
                        OR Session("loanapp.allowEdit") _
                        OR Session("loanapp.allowAdd") _
                        OR Session("loanapp.allowRead")
                END IF
        ELSE
            enableActionDisplayOnly = _
                Session(extAccountClassCode & ".isAdmin") _
                OR Session(extAccountClassCode & ".allowEdit") _
                OR Session(extAccountClassCode & ".allowAdd") _
                OR Session(extAccountClassCode & ".allowRead") _
                OR Session("isSuperUser")
        END IF
        IF enableActionDisplayData OR enableActionDisplayOnly THEN
        %>
        <div>
            <%
            IF enableActionDisplayData THEN
                Dim collateralized : collateralized = False
                IF Loan.RecordCount > 0 THEN
                    IF accountClassName = "Loan" THEN
                        microhelpType = "Loan"
                    ELSE
                        microhelpType = "Account"
                    END IF
                    %>
                    <table id="aa-kendo-grid" style="table-layout:fixed">
                        <thead>
                            <tr>
                                <th style="width:15%"><%=accountClassName%> Number</th>
                                <th style="width:20%"><%=accountClassName%> Status</th>
                                <th style="width:33%"><%=accountClassName%> Description</th>
                                <% IF Session("isSuperUser") OR (isAccountEditor() OR IsAccountCreator() OR isAccountDestroyer()) THEN %>
                                <th style="width:20%"><%=accountClassName%> Type</th>
                                <th style="width:12%">Action</th>
                                <% ELSE %>
                                <th style="width:32%"><%=accountClassName%> Type</th>
                                <% END IF %>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            Dim rowCount : rowCount = 0
                            savedExtAccountClassCode = extAccountClassCode
                            DO UNTIL Loan.EOF
                                isApplicationStatus = loan("isApplicationStatus")
                                extAccountClassCode = savedExtAccountClassCode
                                IF isApplicationStatus THEN extAccountClassCode = "loanapp"
                                loanId = Loan("loanId")
                                displayRow = True
                                IF Session("bankSecurity") = "DU" AND NOT hasLoanBranchAccess(loan("loanId")) THEN displayRow = False
                                IF displayRow THEN
                                %>
                                <tr>
                                    <td><%
                                    IF Session("isSuperUser") OR (Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) THEN
                                        Response.Write "<a href=""customerscan.asp?state=INITIAL&amp;action=EDITLOAN&amp;customerId=" & customerId & "&amp;loanid=" & loan("loanid") & "&amp;bankid=" & customerbankid & "&amp;accountClassId=" & accountClassId & """>" & loan("loanNumber") & "</a>"
                                    ELSE
                                        Response.Write loan("loanNumber")
                                    END IF
                                    %></td>
                                    <td><%=loan("statusDescription") %></td>
                                    <td><div class="aa-account-description" title="<%=loan("loanDescription")%>"><%=loan("loanDescription")%></div></td>
                                    <% IF Session("isSuperUser") OR (isAccountEditor() OR IsAccountCreator() OR isAccountDestroyer()) THEN %>
                                    <td><%=loan("loanTypeDescription")%></td>
                                    <td>
                                        <ul><%
                                            IF Session("isSuperUser") OR Session(extAccountClassCode & ".allowDelete") OR Session(extAccountClassCode & ".allowDEdit") THEN
                                                Dim collateralCount : collateralCount = Loan("collateralCount")
                                                Dim crossCollateralCount : crossCollateralCount = Loan("crossCollateralCount")

                                                ' ### If the account has no collaterals the allow delete ###
                                                IF collateralCount = 0 AND crossCollateralCount = 0 THEN
                                                    Response.Write "<li><a href=""loandeletemaint.asp?loanId=" & loan("loanId") & "&amp;accountClassName=" & accountClassName & """><i class=""aa-icon fas fa-trash-alt"" title=""Delete " & microhelpType & """ aria-hidden=""true""></i></a></li>"
                                                ELSE
                                                    collateralized = True
                                                    Response.Write "<li><i class=""aa-icon fas fa-asterisk aa-color-danger"" aria-hidden=""true""></i></li>"
                                                END IF
                                            ELSE
                                                Response.Write "<li>&nbsp;</li>"
                                            END IF

                                            IF loan("lockLoanTypeYN") = "Y" THEN
                                                Response.Write "<li><i class=""aa-icon fas fa-lock"" title=""Loan Type is Locked"" aria-hidden=""true""></i></li>"
                                            ELSEIF Session("isSuperUser") OR ((Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) AND hasLoanBranchAccess(loan("loanId"))) THEN
                                                Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Change " & accountClassName & " Type', 'loanchangemaint.asp?customerId=" & customerid & "&amp;loanId=" & loan("loanid") & "&amp;loanTypeId=" & loan("loanTypeId") & "&amp;loanTypeDescr=" & loan("loanTypeDescription") & "&amp;bankId=" & customerbankid & "', 500, 700);""><i class=""aa-icon fas fa-pencil-alt"" title=""Change " & microhelpType & " Type"" aria-hidden=""true""></i></a></li>"
                                            ELSE
                                                Response.Write "<li>&nbsp;</li>"
                                            END IF

                                            IF (Session("isSuperUser") OR (Session(extAccountClassCode & ".isAdmin") AND hasLoanBranchAccess(loanId))) _
                                                OR (Session(extAccountClassCode & ".allowEdit")) AND loan("isCrossCollateralYN") = "N" THEN
                                                Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Copy " & accountClassName & " Documents', 'loanrenewalstart.asp?actionType=RENEWAL&amp;sourceCustomerId=" & customerId & "&amp;sourceLoanId=" & loan("loanid") & "&amp;accountClassName=" & accountClassName & "', 500, 750);""><i class=""aa-icon far fa-copy"" title=""Copy " & microhelpType & " Documents"" aria-hidden=""true""></i></a></li>"
                                            ELSE
                                                Response.Write "<li>&nbsp;</li>"
                                            END IF
                                        %></ul>
                                    </td>
                                    <% ELSE %>
                                    <td><%=loan("loanTypeDescription")%></td>
                                    <% END IF %>
                                </tr>
                                <%
                                END IF ' ### IF displayRow
                                rowCount = rowCount + 1
                                loan.movenext
                            LOOP
                            IF collateralized THEN
                            %>
                            <% END IF %>
                        </tbody>
                    </table>
                    <table class="aa-warning">
                        <tr>
                            <td><i class="fas fa-asterisk aa-color-danger" aria-hidden="true"></i>
                            Account has one or more collaterals or has been cross collateralized. Any collaterals
                            need to be deleted first and cross collaterals need to be deleted or converted to
                            regular collaterals before deleting the account.</td>
                        </tr>
                    </table>
                    <%
                END IF ' ### IF Loan.RecordCount > 0

                extAccountClassCode = savedExtAccountClassCode
                enableActionSection = False

                enableActionSection = _
                    Session("isSuperUser") _
                    OR Session(extAccountClassCode & ".isAdmin") _
                    OR Session(extAccountClassCode & ".allowEdit") _
                    OR Session(extAccountClassCode & ".allowAdd")

                IF extAccountClassCode = "loan" THEN
                    enableActionSection = _
                        enableActionSection _
                        OR Session("loanapp.isAdmin") _
                        OR Session("loanapp.allowEdit") _
                        OR Session("loanapp.allowAdd")
                END IF
            END IF ' ### IF enableActionDisplayData

            IF enableActionSection OR enableActionDisplayData OR enableActionDisplayOnly THEN
                Dim showActionSection : showActionSection = false
                IF lCase(extAccountClassCode) = "loan" AND action <> "ADD" THEN
                    IF (Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowAdd")) THEN
                        showActionSection = true
                    END IF
                    IF Session("enableLoanApprovalsYN") = "Y" AND (Session("isSuperUser") OR Session("loanapp.IsAdmin") OR Session("loanapp.allowAdd")) THEN
                        showActionSection = true
                    END IF
                ELSEIF action <> "ADD" AND (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowAdd")) THEN
                    showActionSection = true
                END IF
                IF (Session("isSuperUser") OR Session("credit.isAdmin") OR Session("credit.allowEdit") OR Session("credit.allowAdd")) AND displayFinancialDocs THEN
                    showActionSection = true
                END IF
                IF showActionSection THEN
                %>
                <div class="aa-actions-section">
                    <h2>Actions</h2>
                    <ul>
                        <% IF lCase(extAccountClassCode) = "loan" AND action <> "ADD" THEN %>
                            <% IF (Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowAdd")) THEN %>
                            <li><a href="javascript:void(0);" onclick="openKendoDialog('Add Booked Loan', 'loanmaintadd.asp?action=NEWLOAN&amp;customerId=<%=customerId%>&amp;bankId=<%=customerBankId%>&amp;accountClassCode=loan', 600, 800)" class="k-button k-primary"><i class="fas fa-plus-circle fa-fw" aria-hidden="true"></i>&nbsp;&nbsp;Booked Loan</a></li>
                            <% END IF %>
                            <% IF Session("enableLoanApprovalsYN") = "Y" AND (Session("isSuperUser") OR Session("loanapp.IsAdmin") OR Session("loanapp.allowAdd")) THEN %>
                            <li><a href="javascript:void(0);" onclick="openKendoDialog('Add Loan Application', 'loanmaintadd.asp?action=NEWAPP&amp;customerId=<%=customerId%>&amp;bankId=<%=customerBankId%>&amp;accountClassCode=loan&amp;extAccountClassCode=loanapp', 600, 800)" class="k-button k-primary"><i class="fas fa-plus-circle fa-fw" aria-hidden="true"></i>&nbsp;&nbsp;Loan Application</a></li>
                            <% END IF %>
                        <% ELSEIF action <> "ADD" AND (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowAdd")) THEN %>
                            <li><a href="javascript:void(0);" onclick="openKendoDialog('Add <%=accountClassName%>', 'loanmaintadd.asp?action=NEWLOAN&amp;customerId=<%=customerId%>&amp;bankId=<%=customerBankId%>&amp;accountClassCode=<%=accountClassCode%>', 600, 800)" class="k-button k-primary"><i class="fas fa-plus-circle fa-fw" aria-hidden="true"></i>&nbsp;&nbsp;<%=accountClassName%></a></li>
                        <% END IF %>
                        <% IF (Session("isSuperUser") OR Session("credit.isAdmin") OR Session("credit.allowEdit") OR Session("credit.allowAdd")) AND displayFinancialDocs THEN %>
                            <li><a href="customerscan.asp?state=INITIAL&amp;action=EDITCUSTOMERDOCS&amp;customerId=<%=customerId%>&amp;bankid=<%=customerbankid%>&amp;fromcustmaint=1" class="k-button k-primary"><i class="fas fa-pencil-alt fa-fw" aria-hidden="true"></i>&nbsp;&nbsp;Financial Documents</a></li>
                        <% END IF %>
                    </ul>
                </div>
                <%
                END IF ' ### IF showActionSection
            END IF
            %>
        </div>
        <%
    END IF ' ### IF enableActionDisplayData OR enableActionDisplayOnly
    accountRS.MoveNext
LOOP
accountRS.Close
%>
</div>