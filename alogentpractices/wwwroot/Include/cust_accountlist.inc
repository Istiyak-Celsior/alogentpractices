<%
accountGridStart = Timer()

'## Build the ORDER BY Clause Based on User Preferences ###
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

' ### Get the Account Status filter for the current Account Class being viewed ###
selectedAccountStatusFilter = Session("selected" & selectedAccountClassCode & "StatusFilter")
accountStatusClause = ""

IF selectedAccountStatusFilter = "all" OR selectedAccountStatusFilter = "" THEN
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
            accountStatusClause = "(loanStatusId=" & dbFormatId(statusId) & ")"
        ELSE
            accountStatusClause = accountStatusClause & " OR (loanStatusId = " & dbFormatId(statusId) & ")"
        END IF
        startIndex = endIndex
    LOOP WHILE(str <> "")
    accountStatusClause = " AND (" & accountStatusClause & ")"
END IF

Dim loanBranchClause : loanBranchClause = ""
IF Session("bankSecurity") = "DU" AND Not Session("isSuperUser") THEN
    loanBranchClause = " AND loanBranchId IN" & _
        "    (SELECT branchid FROM viewuserBranchSecurity WHERE userId=" & dbFormatId(Session("userId")) & ") "
END IF

accountFilterKey = "selected" & LCase(selectedAccountClassCode) & "StatusFilter"
selectedAccountStatusFilter = Request.Cookies("AccuLoan")(accountFilterKey)

IF (lCase(selectedAccountClassCode) = "deposit" and selectedAccountStatusFilter = "none") OR (lCase(selectedAccountClassCode) = "loan" AND selectedAccountStatusFilter = "none") or (lCase(selectedAccountClassCode) = "trust" and selectedAccountStatusFilter = "none") THEN
    ' ### Do Nothing ###
    accountListRecordCount = 0
ELSE
    Dim accountListClause, accountListRecordCount
    Dim accountListRS : Set accountListRS = Server.CreateObject("ADODB.RecordSet")
    Dim accountListQuery : accountListQuery = _
        " SELECT" & _
        "   v1.loanId," & _
        "   v1.loanNumber" & _
        " FROM (" & _
        " SELECT" & _
        "   l.loanId," & _
        "   l.loanNumber" & _
        " FROM" & _
        "   accountClass AS ac INNER JOIN loanStatus AS ls" & _
        "       ON ac.accountClassId=ls.accountClassId" & _
        "   INNER JOIN loan AS l" & _
        "       ON l.loanStatusId=ls.statusId" & _
        " WHERE" & _
        "   ls.accountClassId=" & dbFormatId(selectedAccountClassId) & _
        "   AND l.customerId=" & dbFormatId(selectedCustomerId) & _
        "   AND l.isCollateralYN LIKE 'N'" & _
        "   AND l.isCrossCollateralYN LIKE 'N'" & accountStatusClause & loanBranchClause
    IF NOT (Session("loanapp.allowRead") OR Session("loanapp.allowEdit") OR Session("isSuperUser") OR Session("credit.isAdmin")) THEN
        accountListQuery = accountListQuery & " AND ls.isApplicationStatus = 0"
    END IF
    accountListQuery = accountListQuery & " UNION" & _
        " SELECT" & _
        "   l.loanId," & _
        "   l.loanNumber" & _
        " FROM" & _
        "   accountClass AS ac INNER JOIN loanStatus AS ls" & _
        "       ON ac.accountClassId=ls.accountClassId" & _
        "   INNER JOIN loan AS l" & _
        "       ON l.loanStatusId=ls.statusId" & _
        "   INNER JOIN coborrower AS cb" & _
        "       ON cb.loanId=l.loanId" & _
        " WHERE" & _
        "    ls.accountClassId=" & dbFormatId(selectedAccountClassId) & _
        "    AND cb.customerId=" & dbFormatId(selectedCustomerId) & _
        "    AND l.isCollateralYN LIKE 'N'" & _
        "    AND l.isCrossCollateralYN LIKE 'N'" & accountStatusClause & loanBranchClause
    IF (Session("loanapp.allowRead") OR Session("loanapp.allowEdit") OR Session("loanapp.isAdmin") OR Session("isSuperUser") OR Session("credit.isAdmin")) THEN
        ' ### Do Nothing ###
    ELSE
        accountListQuery = accountListQuery & " AND ls.isApplicationStatus = 0"
    END IF
    accountListQuery = accountListQuery & " ) AS v1" & _
        " ORDER BY v1.loanNumber"
    accountListRS.Open accountListQuery, db, adOpenStatic, adCmdText

    accountListRecordCount = accountListRS.RecordCount
    IF NOT accountListRS.EOF THEN
        IF selectedLoanId = "" THEN
            selectedLoanId = accountListRS("loanId")
            Session("selectedLoanId") = selectedLoanId
        END IF
    END IF

    accountListRS.Close()
END IF

Dim LoanLink : LoanLink = ""
Dim LoanNewLink : LoanNewLink = ""
Dim LoanAppLink : LoanAppLink = ""
Dim TellerLink : TellerLink = ""

IF lCase(selectedAccountClassCode) = "deposit" AND Session("deposit.allowDocRead") AND selectedAccountStatusFilter <> "none" AND (Session("deposit.allowRead") OR Session("deposit.allowEdit") OR Session("deposit.isAdmin")) THEN
    TellerLink = "<a href=""tellerviewframe.asp?view=teller""><i class=""aa-icon fas fa-university"" aria-hidden=""true""></i>&nbsp;Switch to Teller View</a>"
END IF

Dim allowAppAccess : allowAppAccess = (Session("loanapp.allowRead") OR Session("loanapp.allowEdit") OR Session("loanapp.Admin"))

IF accountListRecordCount > 0 AND (Session(selectedAccountClassCode & ".allowRead") OR Session(selectedAccountClassCode & ".allowEdit") OR Session("isSuperUser") OR Session("credit.isAdmin") ) THEN
    LoanLink = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('View Account Listing', 'accountlist.asp?customerId=" & selectedCustomerId & "&accountClassId=" & selectedAccountClassId & "', 500, 900);"">View " & accountClassLabel & "s (" & accountListRecordCount & ")</a>"
END IF

IF (lCase(selectedAccountClassCode) = "deposit" or lCase(selectedAccountClassCode) = "loan" or lCase(selectedAccountClassCode) = "trust") AND selectedAccountStatusFilter = "none" THEN
    'Do nothing
ELSE
    IF Session("isSuperUser") OR Session(selectedAccountClassCode & ".isAdmin") OR Session(selectedAccountClassCode & ".allowAdd") THEN
        LoanNewLink = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Take Action', 'loanmaintadd.asp?action=NEWLOAN&customerId=" & selectedCustomerId & "&bankId=" & customerRS("bankId") & "&accountClassCode=" & selectedAccountClassCode & "', 600, 800);""><i class=""aa-icon fas fa-plus-circle"" title=""Create New " & createnewAccountLabel & """ aria-hidden=""true""></i>&nbsp;" & createnewAccountLabel & "</a>"
    END IF 'loan security check

    IF (Session("isSuperUser") OR Session("loanapp.isAdmin") OR Session("loanApp.allowAdd")) AND Session("enableLoanApprovalsYN") = "Y" AND selectedAccountClassCode = "loan" THEN
        LoanAppLink = "<a href=""javascript:void(0);"" onclick=""openKendoDialog('Take Action', 'loanmaintadd.asp?action=NEWAPP&customerId=" & selectedCustomerId & "&bankId=" & customerRS("bankId") & "&accountClassCode=" & selectedAccountClassCode & "', 600, 800);""><i class=""aa-icon fas fa-plus-circle"" title=""Create New Loan Application"" aria-hidden=""true""></i>&nbsp;Loan Application</a>"
    END IF ' application security check
END IF ' deposit and Cookie filter = none

IF (Trim(LoanLink & "") <> "" OR Trim(LoanNewLink & "") <> "" OR Trim(LoanAppLink & "") <> "" OR Trim(TellerLink & "") <> "") THEN
%>
<div class="aa-account-options">
    <ul>
        <%
        Dim accountLinks : accountLinks = ""
        IF Trim(LoanLink & "") <> "" THEN
            accountLinks = accountLinks & "<li>" & ThisOrThat(Trim(accountLinks & "") <> "", "&nbsp;&nbsp;", "") & LoanLink & "</li>"
        END IF
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