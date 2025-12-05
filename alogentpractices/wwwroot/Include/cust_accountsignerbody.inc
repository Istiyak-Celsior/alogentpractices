<%
	accountBorrowerTimeStart = Timer()
%>
<link rel="stylesheet" type="text/css" href="Content/CustAccountSignerBody.css"/>
<%
' ### List additional borrowers ###
' NOTE: The list consists of a UNION of two SELECT statements. The first is the
' actual list of coborrowers against the loan being viewed. The second is
' the Primary borrower adjusted to look like a coborrower, but the Type is hard coded 
' to be 'Primary Borrower', etc for display and evaluation puproses in the HTML.
additionalBorrowerQuery = _
    " SELECT" & _
    "   c.customerId, " & _
    "   c.customerName, " & _
    "   c.customerNumber, " & _
    "   'N' AS customerPrime, " & _
    "   bt.borrowerTypeId, " & _
    "   bt.borrowerTypeName, " & _
    "   bt.borrowerTypeCode " & _
    " FROM" & _
    "   coborrower AS cb INNER JOIN customer AS c" & _
    "       ON cb.customerId = c.customerID" & _
    "   INNER JOIN borrowerType AS bt" & _
    "       ON bt.borrowerTypeId=cb.borrowerTypeId" & _
    " WHERE" & _
    "   cb.loanId = " & dbFormatID(loanRS("loanId")) & _
    " UNION" &_
    " SELECT" & _
    "   c.customerId, " & _
    "   c.customerName, " & _
    "   c.customerNumber, " & _
    "   'Y' AS customerPrime, " & _
    "   NULL AS borrowerTypeId, " & _
    "   'Primary' AS borrowerTypeName, " &_
    "   'P' AS borrowerTypeCode " & _
    " FROM" & _
    "   customer AS c INNER JOIN loan AS l" & _
    "       ON c.customerId = l.customerId" &_
    " WHERE" & _
    "   l.loanId = " & dbFormatID(loanRS("loanId")) & _
    " ORDER BY c.customerName ASC"
additionalBorrowerRS.Open additionalBorrowerQuery, db, adOpenStatic
%>
<div id="changeOfBorrowerErrorDisplay">
    <img id="changeOfBorrowerErrorMessageClose" src="Content/Images/Icons/notification_close.gif"  title="Close" style="vertical-align:middle; float: right;"/>
    <span id="changeOfBorrowerErrorMessage">the message goes here</span>
</div>
<table id="aa-additional-borrowers-list">
    <% IF additionalBorrowerRS.EOF THEN %>
    <tr class="no-results">
        <td><i>There are no additional <%=GuarantorsOrSigners%> on this <%=typeNameString%>.</i></td>
    </tr>
    <% ELSE %>
    <tr class="header-cell">
        <td>Principle</td>
        <td>Additional <%=GuarantorsOrSigners%></td>
        <td>Type</td>
        <td>Customer Number</td>
    </tr>
    <%
    Dim borrowerCount : borrowerCount = 0
    IF NOT additionalBorrowerRS.EOF THEN
        borrowerCount = additionalBorrowerRS.recordCount
    END IF

    idxGuarantor = 0
    primaryBorrowerId = selectedCustomerId
    DO UNTIL additionalBorrowerRS.EOF
        borrowerType = additionalBorrowerRS("borrowerTypeName")
        IF lCase(borrowerType) = "primary" THEN
            primaryBorrowerId = additionalBorrowerRS("customerId")
        END IF
        Dim strippedBorrowerId : strippedBorrowerId = FormatGuid(additionalBorrowerRS("customerId"))
        %>
        <tr class="data-row" id="uxBorrowerRow_<%=strippedBorrowerId%>">
            <% IF additionalBorrowerRS("customerPrime") = "Y" then %>
                <td id="uxBorrowerActionCell_<%=strippedBorrowerId%>" class="aa-tac">
                <i class="fas fa-circle aa-status-yes fa-fw" title="Primary Borrower" aria-hidden="true"></i><%
                ' ### Security check for change of borrower icon and number of borrowers displayed ###
                IF borrowerCount > 1 AND _
                    (Session("isSuperUser") OR ( _
                        (Session(extendedAccountClassCode & ".allowEdit") Or Session(extendedAccountClassCode & ".allowAdd") Or Session(extendedAccountClassCode & ".isAdmin")) _
                    )) THEN
                    Response.Write "&nbsp;&nbsp;<a id=""changePrimaryBorrower"" href=""javascript:void(0)""><i class=""aa-icon fas fa-cog fa-fw"" title=""Change Primary Borrower"" aria-hidden=""true""></i></a>"
                END IF
                Response.Write "</td>"
            ELSE
                Response.Write "<td id=""uxBorrowerActionCell_" & strippedBorrowerId & """ class=""aa-tac"">&nbsp;</td>"
            END IF

            Dim displayLink : displayLink = true
            IF cStr(selectedCustomerId) = cStr(additionalBorrowerRS("customerId")) THEN displayLink = false
            %>
            <td id="uxBorrowerNameCell_<%=strippedBorrowerId%>" class="<%=borrowerClassStyle%>"><%
            IF NOT hasCustomerBranchAccess(additionalBorrowerRS("customerId")) AND Session("bankSecurity") = "DU" THEN
                Response.Write additionalBorrowerRS("customerName")
            ELSEIF displayLink THEN
                Response.Write "<a href=""customer.asp?customerId=" & additionalBorrowerRS("customerId") & "&loanId=" & loanRS("loanId") & """>" & additionalBorrowerRS("customerName") & "</a>"
            ELSE
                Response.Write additionalBorrowerRS("customerName")
            END IF
            %></td>
            <td id="uxBorrowerTypeCell_<%=strippedBorrowerId%>" class="<%=borrowerClassStyle%>"><%
            IF NOT hasCustomerBranchAccess(additionalBorrowerRS("customerId")) _
                OR NOT( _
                    Session("credit.allowEdit") Or Session("credit.allowAdd") Or Session("credit.isAdmin") _
                    OR Session(extendedAccountClassCode & ".allowEdit") Or Session(extendedAccountClassCode & ".allowAdd") Or Session(extendedAccountClassCode & ".isAdmin") ) _
                    OR borrowerType = "Primary" THEN
                Response.Write borrowertype
            ELSE
                Response.Write borrowertype & "&nbsp;<a href=""javascript:void(0);"" onclick=""openKendoDialog('Change Borrower Type', 'borrowerMaintenance.asp?customerId=" & additionalBorrowerRS("customerId") & "&loanId=" & loanRS("loanId") & "&borrowerTypeId=" & additionalBorrowerRS("borrowerTypeId") & "', 315, 500);"" class=""aa-command-link""><i class=""aa-icon fas fa-pencil-alt fa-fw"" title=""Edit"" aria-hidden=""true""></i></a>"
            END IF
            %></td>
            <td class="<%=borrowerClassStyle%>"><%=additionalBorrowerRS("customerNumber")%></td>
        </tr>
        <%
        idxGuarantor = idxGuarantor + 1
        additionalBorrowerRS.MoveNext
    LOOP
    END IF ' ### NOT additionalBorrower.EOF
    %>
</table>
<% additionalBorrowerRS.Close %>
<%
	accountBorrowerTimeStop = Timer()
	accountBorrowerTimeDelta = accountBorrowerTimeStop-accountBorrowerTimeStart
%>
<script id="changePrimaryBorrowerContent" type="text/x-kendo-template">
    <div id="changePrimaryBorrowerContentWrapper">
        <p>Select a borrower type to change the current Primary Borrower to...</p>
        <i id="borrowerTypeListLoading" class="fas fa-cog fa-spin fa-fw" aria-hidden="true"></i>
        <select id="borrowerTypeIdToChangeTo"></select>
        <p>Select an existing borrower to become the primary customer for this account.</p>
        <i id="newBorrowerListLoading" class="fas fa-cog fa-spin fa-fw" aria-hidden="true"></i>
        <select id="newPrimaryBorrowerId"></select>
        <div class="aa-button-wrapper-absolute">
            <ul>
                <li><button id="aa-change-borrower-confirm" class="k-button k-primary">Update</button></li>
                <li><button id="aa-change-borrower-cancel" class="k-button">Cancel</button></li>
            </ul>
        </div>
    </div>
</script>