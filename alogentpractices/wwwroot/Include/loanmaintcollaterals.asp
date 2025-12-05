<%
IF isCrossCollateralYN = "N" THEN

collateralMaintURL = "collateralmaintselect.asp?action=ADD&customerId=" & customerId & "&loanId=" & loanId & "&bankId=" & bankId
IF action <> "NEWAPP" AND action <> "NEWLOAN" THEN
%>
<div id="aa-collateral-header-section">
    <ul class="aa-horizontal-list">
        <li><h1 id="aa-collateral-header">Collaterals</h1></li><%
        IF Session("isSuperUser") _
            OR ((Session(extAccountClassCode & ".isAdmin") _
            OR Session(extAccountClassCode & ".allowEdit") _
            OR Session(extAccountClassCode & ".allowAdd")) _
            AND allowLoanBranchAccess) THEN

            IF Session("accuaccount.enableExpress") = 1 THEN
                collateralMaintURL = "collateralmaint.asp?action=ADD&customerId=" & customerId & "&loanId=" & loanId & "&bankId=" & bankId & "&collateralType=REGULAR"
                %><li>&nbsp;<a href="<%=collateralMaintURL%>" class="k-button k-primary"><i class="aa-icon fas fa-plus-circle" aria-hidden="true"></i>&nbsp;&nbsp;New Collateral</a></li><%
            ELSE
                %><li>&nbsp;<a href="javascript:void(0);" onclick="openKendoDialog('Add New Collateral', '<%=collateralMaintURL%>', 400, 900);" class="k-button k-primary"><i class="aa-icon fas fa-plus-circle" aria-hidden="true"></i>&nbsp;&nbsp;New Collateral</a></li><%
            END IF
        END IF
        %>
    </ul>
</div>
<table class="aa-kendo-grid collateral">
    <thead>
        <tr>
            <% IF Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowDelete") OR Session("loan.isAdmin") OR Session("loan.allowDelete") THEN %>
            <th class="aa-tac">Delete</th>
            <% END IF %>
            <th class="aa-tac">Edit</th>
            <th>Collateral #</th>
            <th class="aa-description-column">Description</th>
            <th>Type</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
        <%
        Dim collateralRS : Set collateralRS = Server.CreateObject("ADODB.RecordSet")
        Dim collateralQuery : collateralQuery = _
            " SELECT" & _
            "   cl.collateralLoanId," & _
            "   l.loanDescription," & _
            "   lt.loanTypeDescription," & _
            "   ls.statusDescription," & _
            "   lo.officerName," & _
            "   br.branchName," & _
            "   cl.CollateralSequence, " & _
            "   CASE" & _
            "       WHEN isCollateralYN LIKE 'Y' THEN" & _
            "           RIGHT( (REPLICATE('0',50) + (LEFT(l.loanNumber, CHARINDEX('_',l.loanNumber)-1))), 50)" & _
            "       ELSE" & _
            "           RIGHT( (REPLICATE('0', 50) + l.loanNumber), 50)" & _
            "       END AS paddedLoanNumber," & _
            "   CASE " & _
            "       WHEN isCollateralYN LIKE 'Y' THEN" & _
            "           RIGHT( (REPLICATE('0',50) + (RIGHT(l.loanNumber, CHARINDEX('_',REVERSE(l.loanNumber),0)-1))), 50)" & _
            "       ELSE" & _
            "           REPLICATE('0',50)" & _
            "   END as paddedCollateralNumber," & _
            "   (SELECT COUNT(loanId) FROM loan WHERE primaryCollateralId=l.loanId) AS crossCollateralCount" & _
            " FROM" & _
            "   collateral AS cl INNER JOIN loan AS l" & _
            "       ON cl.collateralLoanId=l.loanId" & _
            "   INNER JOIN loanType AS lt" & _
            "       ON lt.loanTypeId=l.loanTypeId" & _
            "   INNER JOIN loanStatus AS ls" & _
            "       ON ls.statusId=l.loanStatusId" & _
            "   LEFT OUTER JOIN loanOfficer AS lo" & _
            "       ON lo.officerId=l.loanOfficerId" & _
            "   LEFT OUTER JOIN branch AS br" & _
            "       ON br.branchId=l.loanBranchId" & _
            " WHERE" & _
            "   cl.parentLoanId=" & dbFormatId(loanId) & _
            " ORDER BY paddedCollateralNumber"
        collateralRS.Open collateralQuery, db
        Dim crossCollateralized : crossCollateralized = false
        Dim nCollateralLoop : nCollateralLoop = 0
        IF collateralRS.EOF THEN
        %>
        <tr>
            <td colspan="6" class="aa-tac">No Collaterals Available</td>
        </tr>
        <%
        ELSE
            DO UNTIL collateralRS.EOF
                Dim crossCollateralCount : crossCollateralCount = collateralRS("crossCollateralCount")
                %>
                <tr>
                    <% IF Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowDelete") OR Session("loan.isAdmin") OR Session("loan.allowDelete") THEN %>
                    <td class="aa-tac">
                    <% IF crossCollateralCount = 0 THEN %>
                    <a href="collateralmaintdelete.asp?collateralLoanId=<%=collateralRS("collateralLoanId")%>&parentLoanId=<%=loanId%>&extAccountClassCode=<%=extAccountClassCode%>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete Collateral" aria-hidden="true"></i></a>
                    <% ELSE %>
                    <% crossCollateralized = true %>
                    <i class="aa-icon fas fa-asterisk aa-color-danger"></i>
                    <% END IF %>
                    </td>
                    <% END IF %>
                    <td class="aa-tac"><a href="collateralmaint.asp?action=EDIT&customerId=<%=customerId%>&loanId=<%=loanid%>&bankId=<%=bankId%>&collateralLoanId=<%=collateralRS("collateralLoanId")%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Change Collateral" aria-hidden="true"></i></a></td>
                    <td><%=GetPaddedCollateralSequence(CLng(collateralRS("CollateralSequence")))%></td>
                    <td><%=collateralRS("loanDescription")%></td>
                    <td><%=collateralRS("loanTypeDescription")%></td>
                    <td><%=collateralRS("statusDescription")%></td>
                </tr>
                <%
                nCollateralLoop = nCollateralLoop + 1
                collateralRS.MoveNext
            LOOP
        END IF
        collateralRS.Close
        %>
    </tbody>
</table>
<% IF crossCollateralized THEN %>
<div class="common"><i class="aa-icon fas fa-asterisk aa-color-danger"></i>&nbsp;&nbsp;Collateral has been cross collateralized and cannot be deleted until the cross collaterals have been deleted or converted to regular collaterals.</div>
<% END IF %>
<% ELSE %>
<div class="common">The Collateral options will appear after creating the application by clicking the UPDATE BUTTON</div>
<% END IF %>
<% END IF ' ### isCrossCollateralYN = "N" %>