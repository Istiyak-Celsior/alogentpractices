<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<%
' ### NOTE: To avoid naming conflicts with other panels variables are prefixed with "dpConvert_" ###

' ### Field constants for array indices ###
Const dpConvert_customerIdIndex = 0
Const dpConvert_loanIdIndex = 1
Const dpConvert_loanApplicationIdIndex = 2
Const dpConvert_customerNameIndex = 3
Const dpConvert_customerNumberIndex = 4
Const dpConvert_loanNumberIndex = 5

' ### Get approved applications and store into memory ###
Dim dpConvert_applicationRS : Set dpConvert_applicationRS = Server.CreateObject("ADODB.RecordSet")
Dim dpConvert_applicationQuery : dpConvert_applicationQuery = _
    " SELECT" & _
    "   l.customerId," &_
    "   l.loanId," & _
    "   la.loanApplicationId," & _
    "   c.customerName," & _
    "   c.customerNumber," & _
    "   l.loanNumber" & _
    " FROM" & _
    "   loanApplication AS la INNER JOIN viewLoansAndCollaterals AS l" & _
    "       ON la.loanId=l.loanId" & _
    "   INNER JOIN customer AS c" & _
    "       ON c.customerId=l.customerId" & _
    " WHERE" & _
    "   l.isApprovedApplicationStatus=1" & _
    " ORDER BY" &_ 
    "   c.customerName, l.paddedLoanNumber"
dpConvert_applicationRS.Open dpConvert_applicationQuery, db, adOpenStatic, adCmdText
IF NOT dpConvert_applicationRS.EOF THEN
    dpConvert_approvedApps = dpConvert_applicationRS.GetRows()
    dpConvert_approvedAppCount = uBound(dpConvert_approvedApps,2)
ELSE
    dpConvert_approvedAppCount = -1
END IF
dpConvert_applicationRS.Close

Dim firstTime, dpConvert_activeLoanQuery
Dim dpConvert_activeLoanRS : Set dpConvert_activeLoanRS = Server.CreateObject("ADODB.RecordSet")
Dim dpConvert_customerId, dpConvert_customerName, dpConvert_customerNumber
Dim dpConvert_loanId, dpConvert_loanNumber
%>
<table class="aa-convert-app-widget">
    <thead>
        <tr class="aa-header">
            <th>Approved Applications</th>
            <th>Recent Booked Loans</th>
            <th class="aa-convert-app-link">Book Loan</th>
        </tr>
    </thead>
    <tbody>
    <%
    dpConvert_customerId = ""
    dpConvert_loanApplicationId = ""
    FOR i = 0 TO dpConvert_approvedAppCount
        ' ### Only process customer once in this loop pass ###
        IF cStr(dpConvert_customerId) <> cStr(dpConvert_approvedApps(dpConvert_customerIdField,i)) THEN
            dpConvert_customerId = dpConvert_approvedApps(dpConvert_customerIdField,i)
            dpConvert_activeLoanQuery = _
                " SELECT" & _
                "   l.customerId," & _
                "   l.loanId," & _
                "   la.loanApplicationId," & _
                "   c.customerName," & _
                "   c.customerNumber," & _
                "   l.loanNumber" & _
                " FROM" & _
                "   viewLoansAndCollaterals AS l INNER JOIN customer AS c" & _
                "       ON l.customerId=c.customerId" & _
                "   LEFT OUTER JOIN loanApplication AS la" & _
                "       ON la.loanId=l.loanId" & _
                " WHERE" & _
                "   l.isCollateralYN='N'" & _
                "   AND l.isCrossCollateralYN='N'" & _
                "   AND l.isActiveLoanStatus=1" & _
                "   AND la.loanApplicationId IS NULL" & _
                "   AND l.customerId=" & dbFormatId(dpConvert_customerId) & _
                "   AND l.accountClassCode LIKE 'loan'" & _
                "   AND l.loanOrigDate >= DATEADD(DAY, -30, GETDATE())" & _ 
                " ORDER BY l.paddedLoanNumber"
            dpConvert_activeLoanRS.Open dpConvert_activeLoanQuery, db, adOpenStatic, adCmdText
            IF NOT dpConvert_activeLoanRS.EOF THEN
                dpConvert_activeLoans = dpConvert_activeLoanRS.GetRows()
                dpConvert_activeLoanCount = uBound(dpConvert_activeLoans,2)
            ELSE
                dpConvert_activeLoanCount = -1
            END IF
            dpConvert_ActiveLoanRS.Close

            Dim customerHyperlink : customerHyperlink = ""
            FOR j = 0 TO dpConvert_approvedAppCount
                IF cStr(dpConvert_customerId) = cStr(dpConvert_approvedApps(dpConvert_customerIdIndex,j)) THEN
                    IF Trim(customerHyperlink & "") = "" THEN
                        customerHyperlink = "customer.asp?customerId=" & dpConvert_approvedApps(dpConvert_customerIdIndex,i) & "&loanId=" & dpConvert_approvedApps(dpConvert_loanIdIndex,j)
                    END IF
                END IF
            NEXT
            %>
            <tr>
                <td colspan="2"><a href="<%=customerHyperlink%>"><b><%=dpConvert_approvedApps(dpConvert_customerNameIndex,i)%></b></a></td>
            </tr>
            <tr>
                <td class="aa-exception-type-indent"><%
                ' ### Loop over and display applications for this customer ###
                FOR j = 0 TO dpConvert_approvedAppCount
                    IF cStr(dpConvert_customerId) = cStr(dpConvert_approvedApps(dpConvert_customerIdIndex,j)) THEN
                        %><a href="customer.asp?customerId=<%=dpConvert_approvedApps(dpConvert_customerIdIndex,j)%>&loanId=<%=dpConvert_approvedApps(dpConvert_loanIdIndex,j)%>"><%=dpConvert_approvedApps(dpConvert_loanNumberIndex,j)%></a><br/><%
                    END IF
                NEXT
                %></td>
                <td><%
                ' ### Loop over and display active loans for this customer ###
                Dim recentBookedLoan : recentBookedLoan = false
                FOR j = 0 TO dpConvert_activeLoanCount
                    IF cStr(dpConvert_customerId) = cStr(dpConvert_activeLoans(dpConvert_customerIdIndex,j)) THEN
                        recentBookedLoan = true
                        %><%=dpConvert_activeLoans(dpConvert_loanNumberIndex,j)%><br/><%
                    END IF
                NEXT
                IF NOT recentBookedLoan THEN
                    %>---<%
                END IF
                %></td>
                <td class="aa-convert-app-link"><%
                ' ### Loop over and display applications for this customer ###
                FOR j = 0 TO dpConvert_approvedAppCount
                    IF cStr(dpConvert_customerId) = cStr(dpConvert_approvedApps(dpConvert_customerIdIndex,j)) THEN
                        IF Session("isSuperUser") _
                            OR Session("loanapp.isAdmin") _
                            OR Session("loanapp.allowEdit") THEN
                           %><a href="customer.asp?customerId=<%=dpConvert_approvedApps(dpConvert_customerIdIndex,j)%>&loanId=<%=dpConvert_approvedApps(dpConvert_loanIdIndex,j)%>&applicationId=<%=dpConvert_approvedApps(dpConvert_loanApplicationIdIndex,j)%>&bookLoan=true"><i class="aa-icon fas fa-share-square fa-fw" title="Book Loan" aria-hidden="true"></i></a><br/><%
                        ELSE %>
                            <i class="aa-icon fas fa-share-square fa-fw aa-disabled" title="You do not have permission to book this loan" aria-hidden="true"></i><br />
                        <%
                        END IF
                    END IF
                NEXT
                %></td>
            </tr>
            <%
        END IF
    NEXT
    %>
    </tbody>
</table>
<!-- #include file="../dbclose.inc" -->