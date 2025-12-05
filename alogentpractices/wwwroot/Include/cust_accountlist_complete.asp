<%
accountGridStart = Timer()
Const fixedPadding = 128

' ### Build the ORDER BY clause based on user preferences
' NOTE: This has been deprecated and can be removed for a default
' order. Users do not have the ability to set the order by clause
' in their view preferences ###
loanOrderByClause = ""

FOR i = 0 to 2
    SELECT CASE selectedSortLoanBy(i)
        CASE "0"  ' ### Ignore Sort - not used
        CASE "1"  ' ### Loan Number
            IF loanOrderByClause = "" THEN
                loanOrderByClause = "paddedLoanNumber"
            ELSE
                loanOrderByClause = loanOrderByClause & ", paddedLoanNumber"
            END IF
        CASE "2"  ' ### Loan Type
            IF loanOrderByClause = "" THEN
                loanOrderByClause = "loanTypeDescription"
            ELSE
                loanOrderByClause = loanOrderByClause & ", loanTypeDescription"
            END IF
        CASE "3"  ' ### Loan Status
            IF loanOrderByClause = "" THEN
                loanOrderByClause = "statusDescription"
            ELSE
                loanOrderByClause = loanOrderByClause & ", statusDescription"
            END IF
        CASE "4"  ' ### Loan Origination date
            IF loanOrderByClause = "" THEN
                loanOrderByClause = "loanOrigDate DESC"
            ELSE
                loanOrderByClause = loanOrderByClause & ", loanOrigDate DESC"
            END IF
        CASE "5"  ' ### Loan Principle Balance
            IF loanOrderByClause = "" THEN
                loanOrderByClause = "principleBalance DESC"
            ELSE
                loanOrderByClause = loanOrderByClause & ", principleBalance DESC"
            END IF
        CASE "6"  ' ### Loan Description
            IF loanOrderByClause = "" THEN
                loanOrderByClause = "shortLoanDescription"
            ELSE
                loanOrderByClause = loanOrderByClause & ", shortLoanDescription"
            END IF
    END SELECT
NEXT
    
selectedAccountClassId = Session("selectedAccountClassId")

' ### Get the Account Status filter for the current Account Class being viewed ###
selectedAccountStatusFilter = Session("selected" & selectedAccountClassCode & "StatusFilter")
accountStatusClause = ""

'Response.Write "selectedAccountStatusFilter = " & selectedAccountStatusFilter & "<br/>"

IF selectedAccountStatusFilter = "all" OR selectedAccountStatusFilter = "" OR selectedAccountStatusFilter = "none" THEN
    accountStatusClause = ""
ELSE
    ' ### Parse filter for status ids to filter on. Seperator is the colon ':' character ###
    str = selectedAccountStatusFilter
    startIndex = 1
    DO
        endIndex = InStr(str, ":")
        IF endIndex > 0 THEN
            statusId = Left(str, endIndex-1)
            str = replace(str, statusId & ":", "")
        ELSE
            statusId = str
            str = ""
        END IF
        IF accountStatusClause = "" THEN
            accountStatusClause = "(l.loanStatusId=" & dbFormatId(statusId) & ")"
        ELSE
            accountStatusClause = accountStatusClause & " OR (l.loanStatusId = " & dbFormatId(statusId) & ")"
        END IF
        startIndex = endIndex
    LOOP WHILE(str <> "")
    accountStatusClause = " AND (" & accountStatusClause & ")"
END IF

Set accountListRS = Server.CreateObject("ADODB.RecordSet")
'### Get list of Primary and borrowed loans based on the current customer and user access ###
accountListQuery = _
    " SELECT " & _ 
    "   l.loanId," & _
    " 	l.loanNumber," & _
    "   l.loanDescription," & _
    "   l.loanAmount," & _
    " 	l.loanOrigDate," & _ 
    " 	lt.loanTypeDescription," & _ 
    " 	ls.statusDescription," & _ 
    " 	CASE WHEN ls.isApplicationStatus = 1 THEN 'loanapp' ELSE ac.accountClassCode END AS extendedAccountClassCode," & _ 
    " 	CASE WHEN cb.loanId IS NULL THEN 'Primary Borrower' ELSE bt.borrowerTypeName END AS borrowerTypeName," & _ 
    " 	CASE WHEN ubs.branchSecurityID IS NOT NULL THEN 1 ELSE 0 END hasBranchAccess," & _ 
    " 	ISNULL(v1.hasFiles,0) AS hasFiles" & _ 
    " FROM" & _ 
    " 	loan AS l INNER JOIN loanType AS lt" & _ 
    " 		ON lt.loanTypeId = l.loanTypeId" & _ 
    " 	INNER JOIN loanStatus AS ls" & _ 
    " 		ON ls.statusId = l.loanStatusId" & _ 
    " 	INNER JOIN accountClass AS ac" & _ 
    " 		ON ac.accountClassId = lt.accountClassId" & _ 
    " 	LEFT OUTER JOIN coborrower AS cb" & _ 
    " 		ON cb.loanId=l.loanId" & _
    "       AND cb.customerId = " & dbFormatId(customerId) & _ 
    " 	LEFT OUTER JOIN borrowerType AS bt" & _ 
    " 		ON bt.borrowerTypeId=cb.borrowerTypeId" & _ 
    " 	LEFT OUTER JOIN userBranchSecurity AS ubs" & _ 
    " 		ON ubs.branchId = l.loanBranchId" & _ 
    " 		AND ubs.userId = " & dbFormatId(Session("userId")) & _ 
    " 	OUTER APPLY (" & _ 
    " 		SELECT TOP (1) 1 AS hasFiles" & _ 
    " 		FROM document" & _ 
    " 		WHERE " & _ 
    " 			document.loanId = l.loanId" & _ 
    " 			AND document.documentStatus = 1" & _ 
    " 	) AS v1" & _ 
    " WHERE" & _ 
    " 	(l.customerId = " & dbFormatId(customerId) & " OR cb.customerId = " & dbFormatId(customerId) & ")" & _ 
    " 	AND ac.accountClassId = " & dbFormatId(selectedAccountClassId) & _ 
    " 	AND l.isCollateralYN = 'N'" & _ 
    accountStatusClause & _
    " ORDER BY" & _ 
    " 	REPLICATE('0', 255) + l.loanNumber," & _ 
    " 	ls.statusDescription," & _ 
    " 	lt.loanTypeDescription"
accountListRS.Open accountListQuery, db, adOpenStatic, adCmdText
accountListRecordCount = accountListRS.RecordCount
LoanNewLink = ""
LoanAppLink = ""
TellerLink = ""

IF lCase(selectedAccountClassCode) = "deposit" AND Session("deposit.allowDocRead") AND selectedAccountStatusFilter <> "none" AND (Session("deposit.allowRead") OR Session("deposit.allowEdit") OR Session("deposit.isAdmin")) THEN
    TellerLink = "<a href=""tellerviewframe.asp?view=teller""><i class=""aa-icon fas fa-university"" aria-hidden=""true""></i>&nbsp;Switch to Teller View</a>"
END IF
IF (lCase(selectedAccountClassCode) = "deposit" or lCase(selectedAccountClassCode) = "loan" or lCase(selectedAccountClassCode) = "trust") AND selectedAccountStatusFilter = "none" THEN
    ' ### Do nothing ###
ELSE
    IF Session("isSuperUser") OR Session(selectedAccountClassCode & ".isAdmin") OR Session(selectedAccountClassCode & ".allowAdd") THEN
        LoanNewLink = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Take Action', 'loanmaintadd.asp?action=NEWLOAN&customerId=" & selectedCustomerId & "&bankId=" & customerRS("bankId") & "&accountClassCode=" & selectedAccountClassCode & "', 600, 800);""><i class=""aa-icon fas fa-plus-circle"" title=""Create New " & createnewAccountLabel & """ aria-hidden=""true""></i>&nbsp;" & createnewAccountLabel & "</a>"
    END IF ' ### Loan security check
    IF (Session("isSuperUser") OR Session(selectedAccountClassCode & ".isAdmin") OR Session("loanApp.allowAdd")) AND Session("enableLoanApprovalsYN") = "Y" AND selectedAccountClassCode = "loan" THEN
        LoanAppLink = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Take Action', 'loanmaintadd.asp?action=NEWAPP&customerId=" & selectedCustomerId & "&bankId=" & customerRS("bankId") & "&accountClassCode=" & selectedAccountClassCode & "', 600, 800);""><i class=""aa-icon fas fa-plus-circle"" title=""Create New " & createnewAccountLabel & """ aria-hidden=""true""></i>&nbsp;Loan Application</a>"
    END IF ' ### Application security check
END IF ' ### Deposit and Cookie filter = none
IF (Trim(LoanNewLink & "") <> "" OR Trim(LoanAppLink & "") <> "" OR Trim(TellerLink & "") <> "") THEN
%>
<div class="aa-account-options">
    <ul>
        <%
        accountLinks = ""
        IF Trim(LoanNewLink & "") <> "" THEN
            accountLinks = accountLinks & "<li>" & ThisOrThat(Trim(accountLinks & "") <> "", "&nbsp;&nbsp;", "") & LoanNewLink & "</li>"
        END IF
        IF Trim(LoanAppLink & "") <> "" THEN
            accountLinks = accountLinks & "<li>" & ThisOrThat(Trim(accountLinks & "") <> "", "&nbsp;&nbsp;", "") & LoanAppLink & "</li>"
        END IF
        IF Trim(TellerLink & "") <> "" THEN
            accountLinks = accountLinks & "<li>" & ThisOrThat(Trim(accountLinks & "") <> "", "&nbsp;&nbsp;", "") & TellerLink & "</li>"
        END IF
        Response.Write accountLinks
        %>
    </ul>
</div>
<% END IF %>
<%
IF NOT accountListRS.EOF THEN
    firstLoanId = ""

    IF TRIM(selectedLoanId & "") <> "" THEN 
        allowLoanBranchAccess = hasLoanBranchAccess(selectedLoanId)
    END IF

    ' ### Remember the first loan, in case currently selected loan is not in filtered list.
    firstLoanId = accountListRS("loanId")

    ' ### If there is not currently selected loan the select the first loan
    IF selectedLoanId = "" THEN
        selectedLoanId = firstLoanId
        Session("selectedLoanId") = selectedLoanId
    END IF

    IF selectedAccountStatusFilter <> "none" THEN
        %>
        <div id="loan-select-grid">
            <table id="loanSelectGrid">
                <colgroup>
                    <% IF lCase(selectedAccountClassCode) = "loan" THEN %>
                    <col style="width:29%"/>
                    <col style="width:15%"/>
                    <col style="width:14%"/>
                    <col style="width:17%"/>
                    <col style="width:11%"/>
                    <col style="width:9%"/>
                    <col style="width:5%"/>
                    <% ELSE %>
                    <col style="width:40%"/>
                    <col style="width:15%"/>
                    <col style="width:14%"/>
                    <col style="width:17%"/>
                    <col style="width:9%"/>
                    <col style="width:5%"/>
                    <% END IF %>
                </colgroup>
                <thead>
                    <tr>
                        <th data-field="account" data-title="Account">Account</th>
                        <th data-field="type" data-title="Type">Type</th>
                        <th data-field="relationship" data-title="Relationship">Relationship</th>
                        <th data-field="status" data-title="Status">Status</th>
                        <% IF lCase(selectedAccountClassCode) = "loan" THEN %>
                        <th data-field="balance" data-template="#if(balance === null){##}else{##=kendo.format('{0:c2}', balance)##}#" data-type="number" data-title="Balance">Balance</th>
                        <th data-field="origination" data-type="date" data-template="#if(origination === null){##}else{##=kendo.format('{0:dd-MMM-yyyy}', origination)##}#" data-title="Origination">Origination</th>
                        <% ELSE ' ### IF lCase(selectedAccountClassCode) = "deposit" THEN %>
                        <th data-field="opened" data-type="date" data-template="#if(opened === null){##}else{##=kendo.format('{0:dd-MMM-yyyy}', opened)##}#" data-title="Opened">Opened</th>
                        <% END IF %>
                        <th data-field="documents" data-title="Docs">Docs</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Dim nLoop : nLoop = 0
                    DO UNTIL accountListRS.EOF
                        formattedDate = CheckForNull(accountListRS("loanOrigDate"))
                        IF IsDate(formattedDate) THEN
                            formattedDate = FormatDateTime(formattedDate,2)
                        ELSE
                            formattedDate = "---"
                        END IF
                        formattedAmount = CheckForNull(accountListRS("loanAmount"))
                        IF isNumeric(formattedAmount) THEN
                            formattedAmount = FormatCurrency(formattedAmount)
                        ELSE
                            formattedAmount = FormatCurrency(0)
                        END IF

                        Dim alc_useBranchSecurity : alc_useBranchSecurity     = UCase(Session("UseBranchSecurity"))
                        Dim alc_branchSecurity : alc_branchSecurity           = Session("bankSecurity")
                        Dim alc_isSuperUser : alc_isSuperUser                 = Session("isSuperUser")
                        Dim alc_allowRead : alc_allowRead                     = Session(accountListRS("extendedAccountClassCode") & ".allowRead")
                        Dim alc_userHasBranchAccess : alc_userHasBranchAccess = accountListRS("hasBranchAccess")
                        Dim displayAccountItem : displayAccountItem           = true

                        ' ### Check for Full Branch Security access if enabled
                        IF alc_useBranchSecurity = "Y" AND alc_branchSecurity = "DU" THEN
                            displayAccountItem = false
                    
                            IF (alc_isSuperUser OR (alc_userHasBranchAccess AND alc_allowRead)) THEN
                                displayAccountItem = true
                            END IF
                        END IF

                        IF displayAccountItem THEN
                        %>                        
                        <tr>
                            <%
                            Dim accountNumber : accountNumber = accountListRS("loanNumber")
                            IF cStr(selectedLoanId) = cStr(accountListRS("loanId")) THEN accountNumber = "<b>" & accountNumber & "</b>"

                            IF Trim(accountListRS("loanDescription") & "") <> "" THEN
                                %><td><a id="<%=accountListRS("loanNumber") & "-" & nLoop %>" href="customer.asp?loanId=<%=accountListRS("loanId")%>&accountClassId=<%=selectedAccountClassId%>"><%=accountNumber%></a><br/>
                                <span class="light"><%=CheckForNull(accountListRS("loanDescription"))%></span></td><%
                            ELSE
                                %><td><a id="<%=accountListRS("loanNumber") & "-" & nLoop %>" href="customer.asp?loanId=<%=accountListRS("loanId")%>&accountClassId=<%=selectedAccountClassId%>"><%=accountNumber%></a></td><%
                            END IF
                            %>
                            <td><%=accountListRS("loanTypeDescription")%></td>
                            <td><% IF selectedAccountClassCode = "loan" THEN %><%=accountListRS("borrowerTypeName")%><% ELSE %><%=Replace(accountListRS("borrowerTypeName"), "Primary Borrower", "Primary")%><% END IF %></td>
                            <td><%=accountListRS("statusDescription")%></td>
                            <% IF lCase(selectedAccountClassCode) = "loan" THEN %>
                            <td><%=formattedAmount%></td>
                            <% END IF %>
                            <td><%=formattedDate%></td>
                            <%
                            Dim imgUrl : imgUrl = "no"
                            IF accountListRS("hasFiles") THEN imgUrl = "yes"
                            %>
                            <td><i class="aa-icon fas fa-circle aa-status-<%=imgUrl%> fa-fw" title="Documents?" aria-hidden="true"></i></td>
                        </tr>
                        <%
                        END IF

                        nLoop = nLoop + 1
                        accountListRS.MoveNext
                    LOOP
                    %>
                </tbody>
            </table>
        </div>
        <%
    END IF ' ### IF selectedAccountStatusFilter = "none"
    
    displayLoans = True
    accountListRS.Close
ELSE
    displayLoans = False
END IF 'accountLIstRecordCount > 0

accountGridEnd = Timer()
accountGridDelta = accountGridEnd - accountGridStart
%>