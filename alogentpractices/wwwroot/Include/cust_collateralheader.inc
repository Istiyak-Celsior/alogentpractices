<%
	collateralHeaderTimeStart = Timer()
%>
<table class="aa-collateral-header">
    <%
    fieldDisplayState = Request.Cookies("collateralfieldDisplayState")
    IF fieldDisplayState = "" THEN fieldDisplayState = "collapsed"

    IF isCrossCollateralYN = "N" THEN
        primaryCollateralId = selectedCollateralId
    ELSE
        primaryCollateralId = collateralRS("primaryCollateralId")
    END IF

    primaryCollateralQuery = _
        " SELECT " & _
        "   l.isCollateralYN, " & _
        "   l.loanDescription, " & _
        "   l.loanAmount, " & _
        "   l.loantypedescription, " & _
        "   l.statusdescription, " & _
        "   l.branchName, " & _
        "   l.officername, " & _
        "   l.loanOrigDate " & _
        " FROM " & _
        "   customer AS c " & _
        "   INNER JOIN viewLoansAndCollaterals AS l ON c.customerId = l.customerId" & _
        " WHERE " & _
        "   l.loanId = " & dbFormatId(primaryCollateralId)
    primaryCollateralRS.Open primaryCollateralQuery, db, adOpenStatic, adCmdText

    ' ### Check to see if the primaryCollateral being referred to is a collateral or a loan ###
    IF NOT primaryCollateralRS.EOF THEN
        IF primaryCollateralRS("isCollateralYN") = "Y" THEN
            %>
            <tr>
                <td class="<%=collateralStyle%>" width="20%" colspan="2">Collateral Number</td>
                <td colspan="4">
                    <ul class="aa-loan-header-list">
                        <%
                        IF Session("acculoan.enablePurge") = 1 THEN
                            IF targetPurgeStatus OR targetCollateralBlockPurge OR (NOT targetPurgeStatus AND targetPurgeStatusLocked) THEN
                                Response.Write "<li>" & GetPurgeStatusIcon(targetPurgeStatus, targetPurgeStatusLocked, targetCollateralBlockPurge) & "</li>"
                            END IF
                        END IF
                        %>
                        <li><%=GetPaddedCollateralSequence(cLng(collateralRS("paddedCollateralNumber")))%></li>
                        <% IF Session(extendedAccountClassCode & ".allowEdit") OR Session(extendedAccountClassCode & ".allowAdd") OR Session(extendedAccountClassCode & ".isAdmin") OR Session("isSuperUser") THEN %>
                        <li><a href="collateralmaint.asp?action=EDIT&customerId=<%=selectedCustomerId%>&loanId=<%=selectedLoanId%>&collateralLoanId=<%=selectedCollateralId%>&bankId=<%=CustomerRS("bankId")%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></li>
                        <% END IF %>
                    </ul>
                </td>
            </tr>
            <tr>
                <td class="<%=collateralStyle%>" colspan="2">Collateral Type</td>
                <td class="<%=collateralStyle%>" colspan="2">Status</td>
                <td class="<%=collateralStyle%>" colspan="2">Description</td>
            </tr>
            <tr>
                <td colspan="2"><%=collateralRS("loanTypeDescription")%></td>
                <td colspan="2"><%=collateralRS("statusDescription")%></td>
                <td colspan="2"><%=collateralRS("loanDescription")%></td>
            </tr>
            <% ELSE %>
            <tr>
                <td class="<%=collateralStyle%>">Collateral Number </td>
                <td colspan="5"><%=collateralRS("paddedCollateralNumber")%><% IF Session("allowLoanAddEdit") THEN %>&nbsp; &nbsp;<a href="customerscan.asp?state=INITIAL&action=EDITLOAN&customerId=<%=collateralRS("customerId")%>&loanId=<%=collateralRS("loanId")%>&bankId=<%=CustomerRS("bankId")%>&accountClassId=<%=targetAccountClassId%>">Edit</a><% END IF %></td>
            </tr>
            <tr>
                <td class="<%=collateralStyle%>">Borrower Type </td>
                <td colspan="5"><%=borrowerType%></td>
            </tr>
            <% IF Trim(primaryCollateralRS("loanDescription")) <> "" THEN %>
                <tr>
                    <td class="<%=collateralStyle%>">Loan Description</td>
                    <td colspan="5"><%=primaryCollateralRS("loanDescription")%></td>
                </tr>
               <%
            END IF

            primaryCollateralAmount = primaryCollateralRS("loanAmount")
            IF IsNumeric(primaryCollateralAmount) THEN
                primaryCollateralAmount = FormatCurrency(primaryCollateralAmount)
            ELSE
                primaryCollateralAmount = ""
            END IF
            %>
            <tr>
                <td class="<%=collateralStyle%>">Loan Type</td>
                <td class="<%=collateralStyle%>">Status</td>
                <td class="<%=collateralStyle%>">Branch</td>
                <td class="<%=collateralStyle%>">Loan Officer</td>
                <td class="<%=collateralStyle%>">Origination Date</td>
                <td class="<%=collateralStyle%>">Balance</td>
            </tr>
            <tr>
                <td><%=primaryCollateralRS("loantypedescription")%></td>
                <td><%=primaryCollateralRS("statusdescription")%></td>
                <td><%=primaryCollateralRS("branchName")%></td>
                <td><%=primaryCollateralRS("officername")%></td>
                <td><%=primaryCollateralRS("loanOrigDate")%></td>
                <td><%=primaryCollateralAmount%></td>
            </tr>
            <%
        END IF ' ### primaryCollateralRS("isCollateralYN") = "Y"
    END IF
    primaryCollateralRS.Close
    Set primaryCollateralRS = Nothing
    %>
    <!-- #include file="cust_collateralheaderflexfields.inc" -->
</table>
<form action="customer.asp" name="frmHiddenCollateralId" method="post">
    <input type="hidden" name="hidCollateralId" id="hidCollateralId" value="<%=targetCollateralLoanId%>" />
</form>
<%
collateralHeaderTimeStop = Timer()
collateralHeaderTimeDelta = collateralHeaderTimeStop-collateralHeaderTimeStart
%>