<table id="aa-kendo-grid">
    <thead>
        <tr>
            <th>Customer Name</th>
            <th class="aa-tac"><%
            IF Session("accuaccount.enableExpress") <> 1 THEN
                Response.Write "Credit<br/>Exceptions"
            ELSE
                Response.Write "&nbsp"
            END IF
            %></th>
            <th class="aa-tac">Emp</th>
            <th>Business Name</th>
            <th>Customer Number</th>
            <th>Tax ID</th>
            <% FOR i = lBound(customCreditFieldLabels) TO uBound(customCreditFieldLabels) %>
            <th class="aa-tac"><%=customCreditFieldLabels(i)%></th>
            <% NEXT %>
            <th class="aa-tac">&nbsp;</th>
            <th class="aa-tac">&nbsp;</th>
            <th>Account Number</th>
            <th>Account Status</th>
            <% IF Session("acculoan.showParticipationLoan") = "1" THEN %>
            <th class="aa-tac">Participation Loan</th>
            <% END IF %>
            <th class="aa-tac"><%
            IF searchDisplayDocs = 1 THEN
                Response.Write "Docs?"
            ELSE
                Response.Write "&nbsp;"
            END IF
            %></th>
            <th class="aa-tac"><%
            IF Session("accuaccount.enableExpress") <> 1 THEN
                Response.Write "Account<br/>Exceptions"
            ELSE
                Response.Write "&nbsp;"
            END IF
            %></th>
            <th>Account / Collateral Description</th>
            <% FOR i = lBound(customAccountFieldLabels) TO uBound(customAccountFieldLabels) %>
            <th class="aa-tac"><%=customAccountFieldLabels(i)%></th>
            <% NEXT %>
            <% FOR i = lBound(customCollateralFieldLabels) TO uBound(customCollateralFieldLabels) %>
            <th class="aa-tac"><%=customCollateralFieldLabels(i)%></th>
            <% NEXT %>
        </tr>
    </thead>
    <tbody>
        <%
        Dim creditColSpan  : creditColSpan  = 6
        Dim accountColSpan : accountColSpan = 7 ' includes the 2 empty cells for padding between credit and account
        IF Session("acculoan.showParticipationLoan") THEN
            accountColSpan = accountColSpan + 1
        END IF

        Dim currentCustomerId : currentCustomerId = ""
        Dim currentCustomerName : currentCustomerName = ""
        Dim currentBusinessName : currentBusinessName = ""
        Dim currentCustomerNumber : currentCustomerNumber = ""
        Dim currentTaxId : currentTaxId = ""
        Dim ignoreCreditExceptionsYN : ignoreCreditExceptionsYN = ""
        Dim customerIsEmployee : customerIsEmployee = ""
        Dim customCreditFieldsHtml : customCreditFieldsHtml = ""
        Dim displayCustomerInfo : displayCustomerInfo = false
        Dim isDifferentCustomer : isDifferentCustomer = false

        customerCount = 0


        DO UNTIL Customer.EOF OR Customer.AbsolutePage <> cLng(page)
            ' #### Build the customer informations columns. ###
            displayCustomerInfo = false
            advanceNextRecord = true

            ' ### Check to see if this a different customer than the previous record ###
            IF Trim(currentCustomerId & "") = Trim(Customer("customerId") & "") THEN
                isDifferentCustomer = false
            ELSE
                isDifferentCustomer = true
            END IF

            ' ### Found Credit Record, start a new table row ###
            IF isDifferentCustomer THEN
                currentCustomerId = Customer("customerId")
                currentCustomerName = Customer("customerName")
                currentBusinessName = Customer("businessName")
                currentCustomerNumber = Customer("customerNumber")
                currentTaxId = Customer("taxId")
                ignoreCreditExceptionsYN = Customer("ignoreCreditExceptionsYN")
                customerIsEmployee = Customer("employee")
                customerExceptionCount = GetCreditExceptionCount(currentCustomerId)

                ' ### Because we need to advance a record forward its necessary to build 
                ' the custom credit fields before advancing. ###
                customCreditFieldsHtml = BuildCustomCreditFields()

                ' ### Move to next record to see if its a loan record for this customer to 
                ' build the loan argument clicking on the customer link ###
                loanUrlArg = ""
                IF NOT Customer.EOF THEN
                    IF cStr(Customer("customerId")) = cStr(currentCustomerId) AND (Customer("loanId") & "") <> "" THEN
                        loanUrlArg = "&loanId=" & Customer("loanId")
                    END IF

                    ' ### Make sure not to advance the current record if the customerId is not the
                    ' same as the currentCustomerId value. This indicates there are two customer
                    ' records back to back with no loan records. ###
                    IF cStr(currentCustomerId) <> cStr(Customer("customerId")) THEN advanceNextRecord = false
                    END IF
                displayCustomerInfo = true
            ELSE
                currentCustomerId = Customer("customerId")
                currentCustomerName = ""
                currentBusinessName = ""
                currentCustomerNumber = ""
                currentTaxId = ""
                ignoreCreditExceptionsYN = "N"
                customerIsEmployee = False
                customerExceptionCount = 0
            END IF
            %>
            <tr>
                <%
                IF displayCustomerInfo THEN
                    customerCount = customerCount + 1
                    IF Session("isSuperUser") OR Session("credit.isAdmin") OR Session("credit.allowEdit") OR Session("credit.allowDelete") THEN
                        Response.Write "<td><a name=""" & currentCustomerId & """ href=""customer.asp?customerid=" & currentCustomerId & loanUrlArg & """>" & currentCustomerName & "</a>&nbsp;(<a class=""noprint"" href=""customermaint.asp?STATE=INITIAL&ACTION=EDIT&customerid=" & currentCustomerId & """>edit</a>)</td>" & vbCr
                    ELSE
                        Response.Write "<td><a name=""" & currentCustomerId & """ href=""customer.asp?customerid=" & currentCustomerId & loanUrlArg & """>" & currentCustomerName & "</a></td>" & vbCr
                    END IF

                    IF Session("accuaccount.enableExpress") <> 1 AND ignoreCreditExceptionsYN = "Y" THEN
                        Response.Write "<td class=""aa-tac aa-color-danger""><i class=""aa-icon fas fa-ban fa-fw"" aria-hidden=""true""></i></td>" & vbCr
                    ELSEIF Session("accuaccount.enableExpress") <> 1 AND customerExceptionCount > 0 THEN
                        Response.Write "<td class=""aa-tac aa-color-danger""><i class=""aa-icon fas fa-exclamation-circle fa-fw"" aria-hidden=""true""></i></td>" & vbCr
                    ELSE
                        Response.Write "<td class=""aa-tac"">&nbsp;</td>"
                    END IF
                    %>
                    <td class="aa-tac"><% IF customerIsEmployee THEN %>Y<% ELSE %>&nbsp;<% END IF %></td>
                    <td><a href="customer.asp?customerid=<%=currentCustomerId%>"><%=currentBusinessName%></a></td>
                    <td><%=currentCustomerNumber%></td>
                    <td><%=currentTaxId%></td>
                    <%=customCreditFieldsHtml%>
                    <%
                ELSE ' ### Create empty cells for account/collateral row
                    %>
                    <td colspan="<%=creditColSpan%>">&nbsp;</td>
                    <% FOR i = lBound(customCreditFields) TO uBound(customCreditFields) %>
                    <td>&nbsp;</td>
                    <% NEXT %>
                    <%
                END IF ' ### displayCustomerInfo

                ' ### Move to next record if not EOF ###
                IF NOT Customer.EOF THEN
                    ' ### Move to next record see if account information is present ###
                    IF CLng(nRecordCount) < CLng(nLastRecordOnPage) AND Trim(Customer("loanId") & "") = "" THEN
                        nRecordCount = nRecordCount + 1
                        Customer.MoveNext
                    END IF

                    IF NOT Customer.EOF THEN
                        IF currentCustomerId <> Trim(Customer("customerId") & "") AND Trim(Customer("loanId") & "") = "" THEN 
                            Call WriteEmptyAccountFields()
                            Customer.MovePrevious
                            nRecordCount = nRecordCount - 1
                        ELSE
                            displayLoanId = Trim(Customer("loanId") & "")
                            Call WriteAccountFields()
                        END IF
                    ELSE
                        Call WriteEmptyAccountFields()
                    END IF
                END IF ' ### IF NOT Customer.EOF
                %>
            </tr>
            <%
            ' ### Display additional borrowers if expanded ###
            IF (cStr(expandLoanId) = cStr(displayLoanId)) AND expandLoanId <> "" AND collapseLoanId = "" AND (NOT Customer.EOF) THEN
                    Call BuildBorrowerRecords()
            END IF
                IF NOT Customer.EOF AND advanceNextRecord THEN
                nRecordCount = nRecordCount + 1
                    Customer.MoveNext
                END IF
            LOOP ' ### until Customer.eof OR Customer.AbsolutePage <> CLng(page)
        %>
    </tbody>
</table>
<%
' ### The following is for writing out empty cells when its a customer only record. ###
SUB WriteEmptyAccountFields()
    Response.Write "<td colspan=""" & accountColSpan & """><i>Contains Credit Matches Only</i></td>" & vbCr
    FOR i = lBound(customAccountFieldLabels) TO uBound(customAccountFieldLabels)
        Response.Write "<td>&nbsp;</td>" & vbCr
    NEXT
    FOR i = lBound(customCollateralFieldLabels) TO uBound(customCollateralFieldLabels)
        Response.Write "<td>&nbsp;</td>" & vbCr
    NEXT
END SUB

    ' The following writes the account fields for an existing account or collateral.
SUB WriteAccountFields()
    hasBorrowers = false ' global page variable
    borrowerCount = 0 ' Make sure to reset count so that accounts without borrowers don't display expander/collapser button, especially if it's a collateral.
    IF Customer("isCollateralYN") = "N" THEN
        borrowerCountStart = Timer()
        Dim borrowerRS : Set borrowerRS = Server.CreateObject("ADODB.Recordset")
        Dim borrowerQuery : borrowerQuery = _
            " SELECT TOP 1 1" & _
            " FROM (coborrower AS cb INNER JOIN customer AS c ON cb.customerId=c.customerId)" & _
            " WHERE loanId=" & dbFormatId(displayLoanId)
        borrowerRS.Open borrowerQuery, db, adOpenForwardOnly, adLockReadOnly
        IF NOT borrowerRS.EOF THEN borrowerCount = 1
        IF borrowerCount > 0 THEN hasBorrowers = True
        borrowerRS.Close

        borrowerCountEnd = Timer()
        borrowerCountDelta = borrowerCountDelta + (borrowerCountEnd - borrowerCountStart)
        borrowerCounter  = borrowerCounter +1
    END IF

    Dim accountIcon : accountIcon = ""
    IF Customer("accountClassCode") = "loan" OR Customer("accountClassCode") = "loanapp" THEN
        accountIcon = "L"
    ELSEIF Customer("accountClassCode") = "deposit" THEN
        accountIcon = "D"
    ELSEIF Customer("accountClassCode") = "trust" THEN
        accountIcon = "T"
    END IF

    loanUrlArg = BuildLoanUrlArgs( Customer("loanId"), Customer("parentLoanId"), Customer("isCollateralYN"))
    loanExceptionCount = GetAccountExceptionCount(Customer("loanId"), Customer("ignoreAccountExceptionsYN"))

    Response.Write "<td class=""aa-tac"">"
    IF Customer("isCollateralYN") = "N" THEN
        Response.Write "<div class=""account-visibility-badge"">" & accountIcon & "</div>"
    ELSE
        Response.Write "&nbsp;"
    END IF
    Response.Write "</td>" & vbCr
    Response.Write "<td class=""aa-tar"">"
    IF hasBorrowers AND (cStr(displayLoanId) <> cStr(expandLoanId)) THEN
        Response.Write "<a href=""searchresults.asp?searchtype=" & searchtype & "&page=" & page & "&expandloanId=" & Customer("loanId") & "#" & Customer("customerId") & """><i class=""aa-icon fas fa-plus-square fa-fw"" aria-hidden=""true""></i></a>"
    ELSEIF hasBorrowers AND (cStr(displayLoanId) = cStr(expandLoanId)) THEN
        Response.Write "<a href=""searchresults.asp?searchtype=" & searchtype & "&page=" & page & "&collapseloanId=" & Customer("loanId") & "#" & Customer("customerId") & """><i class=""aa-icon fas fa-minus-square fa-fw"" aria-hidden=""true""></i></a>"
    ELSE
        Response.Write "&nbsp;"
    END IF
    Response.Write "</td>" & vbCr
    Response.Write "<td>"
    IF cStr(displayLoanId) <> "" AND Customer("isCollateralYN") = "N" AND Customer("isCrossCollateralYN") = "N" THEN
        Response.Write "<a href=""customer.asp?customerid=" & Trim(Customer("customerID")) & "&loanid=" & Trim(Customer("loanID")) & """>" & Customer("loanNumber") & "</a>"
    ELSEIF Customer("isCollateralYN") = "Y" OR Customer("isCrossCollateralYN") = "Y" THEN
        displayUrl = "customer.asp?customerId=" & Customer("customerId") & "&loanId=" & Customer("parentLoanId") & "&collateralId=" & Customer("loanId") & "#collateralHeader"
        Response.Write "&nbsp; &nbsp; &nbsp;<a href=""" & displayUrl & """><i>Collateral</i></a>"
    END IF
    Response.Write "</td>" & vbCr
    Response.Write "<td>" & Customer("statusDescription") & "</td>" & vbCr

    IF Session("acculoan.showParticipationLoan") THEN
        Response.Write "<td class=""aa-tac"">"
        IF Customer("isParticipationLoan") THEN
            Response.Write "Y"
        ELSE
            Response.Write "N"
        END IF
        Response.Write "</td>" & vbCr
    END IF
    Response.Write "<td class=""aa-tac"">"
    IF searchDisplayDocs = 1 THEN
            Dim documentCount : documentCount = GetDocumentCount(displayLoanId)
        IF documentCount = 0 THEN
            Response.Write "<i class=""fas fa-circle aa-status-no fa-fw"" aria-hidden=""true""></i>"
        ELSEIF documentCount > 0 THEN
            Response.Write "<i class=""fas fa-circle aa-status-yes fa-fw"" aria-hidden=""true""></i>"
        ELSE
            Response.Write "&nbsp;"
        END IF
    ELSE
        Response.Write "&nbsp;"
    END IF
    Response.Write "</td>"
    Response.Write "<td class=""aa-tac aa-color-danger"">"
    IF Session("accuaccount.enableExpress") <> 1 AND Customer("ignoreAccountExceptionsYN") = "Y" THEN
        Response.Write "<i class=""aa-icon fas fa-ban fa-fw"" aria-hidden=""true""></i>"
    ELSEIF Session("accuaccount.enableExpress") <> 1 AND loanExceptionCount > 0 THEN
        Response.Write "<i class=""aa-icon fas fa-exclamation-circle fa-fw"" aria-hidden=""true""></i>"
    ELSE
        Response.Write "&nbsp;"
    END IF
    Response.Write "</td>" & vbCr

    Response.Write "<td>"
    IF cStr(displayLoanId) <> "" THEN
        IF Customer("isCollateralYN") = "N" AND Customer("isCrossCollateralYN") = "N" THEN
            displayUrl = "customer.asp?customerId=" & Customer("customerId") & "&loanId=" & Customer("loanId") 
        ELSE
            displayUrl = "customer.asp?customerId=" & Customer("customerId") & "&loanId=" & Customer("parentLoanId") & "&collateralId=" & Customer("loanId") & "#showCollaterals"
        END IF
        Response.Write "<a href=""" & displayUrl & """>" & Customer("loanDescription") & "</a>"
    END IF
    Response.Write "</td>" & vbCr

    FOR i = lBound(customAccountFields) TO uBound(customAccountFields)
        Response.Write "<td>" & Customer(customAccountFields(i)) & "</td>" & vbCr
    NEXT
    FOR i = lBound(customCollateralFields) TO uBound(customCollateralFields)
        Response.Write "<td>" & Customer(customCollateralFields(i)) & "</td>" & vbCr
    NEXT
END SUB ' ###WriteAccountFields()

SUB BuildBorrowerRecords()
    Dim borrowerQuery : borrowerQuery = _
        " SELECT c.customerName, c.customerNumber, c.customerId, c.bankId, cb.loanId" & _
        " FROM (coborrower AS cb INNER JOIN customer AS c ON cb.customerId=c.customerId)" & _
        " WHERE cb.loanId=" & dbFormatId(expandLoanId)
    Dim borrowerRS : SET borrowerRS = Server.CreateObject("ADODB.RecordSet")
    borrowerRS.Open borrowerQuery, db, adOpenStatic
    Response.Write "<tr>" & vbCr _
                 & "<td colspan=""" & creditColSpan & """>&nbsp;</td>" & vbCr _
                 & "<td>&nbsp;</td>" & vbCr _
                 & "<td>&nbsp;</td>" & vbCr _
                 & "<td colspan=""" & accountColSpan + uBound(customAccountFieldLabels) + uBound(customCollateralFieldLabels) & """>" & vbCr _
                 & "<table style=""width:100%"" border=""0"" cellpadding=""2"" cellspacing=""0"">" & vbCr
    Dim firstTime : firstTime = true
    DO UNTIL borrowerRS.EOF
        IF firstTime THEN
            Response.Write "<tr>" & vbCr _
                         & "<td><b>Additional Borrowers</b></td>" & vbCr _
                         & "<td>&nbsp; &nbsp;</td>" & vbCr _
                         & "<td><b>Customer Number</b></td>" & vbCr _
                         & "</tr>" & vbCr
            firstTime = false
        END IF
        Response.Write "<tr>" & vbCr _
                     & "<td><a href=""customer.asp?customerId=" & borrowerRS("customerId") & "&loanId=" & borrowerRS("loanId") & """>" & borrowerRS("customerName") & "</a></td>" & vbCr _
                     & "<td>&nbsp; &nbsp;</td>" & vbCr _
                     & "<td>" & borrowerRS("customerNumber") & "</td>" & vbCr _
                     & "</tr>" & vbCr
        borrowerRS.MoveNext
    LOOP
    Response.Write "</table>" & vbCr _
                 & "</td>" & vbCr _
                 & "</tr>" & vbCr
    borrowerRS.Close
END SUB

FUNCTION GetCreditExceptionCount(theCustomerId)
    Dim exceptionCount : exceptionCount = 0
    creditExceptCountStart = Timer()
    IF Customer("ignoreCreditExceptionsYN") = "N" THEN
        customerExceptionQuery = _
        " SELECT TOP 1 1" & _
        " FROM exception AS ex" & _
        " WHERE" & _
        "   ex.customerId=" & dbFormatId(theCustomerId) & _
        "   AND ex.loanId IS NULL" & _
        "   AND ex.statusType='required'" & _
        "   AND ex.exceptionState <> 'N'"
        customerExceptionRS.Open customerExceptionQuery, db, adOpenStatic
        exceptionCount = customerExceptionRS.RecordCount
        customerExceptionRS.Close
    END IF

    creditExceptCountEnd = Timer ()
    creditExceptCountDelta = creditExceptCountDelta + (creditExceptCountEnd-creditExceptCountStart)
    creditExceptCount = creditExceptCount + 1

    GetCreditExceptionCount = exceptionCount
END FUNCTION

FUNCTION GetAccountExceptionCount(theLoanId, ignoreAccountExceptionsYN)
    Dim count : count = 0
    IF ignoreAccountExceptionsYN = "N" THEN
        accountExceptCountStart = Timer()
        loanExceptionQuery = _
            " SELECT TOP 1 1" & _
            " FROM " & _
            " 	exception AS ex INNER JOIN (" & _
            " 		SELECT" & _
            " 			CASE WHEN isCrossCollateralYN = N'Y' THEN primaryCollateralId ELSE loanId END AS loanId" & _
            " 		FROM loan" & _
            " 		WHERE loanId = " & dbFormatId(theLoanId) & _
            " 	) AS l" & _
            " 		ON ex.loanId = l.loanId" & _
            " WHERE" & _
            " 	ex.statusType='required'" & _
            " 	AND ex.exceptionState <> 'N'"
        loanExceptionRS.Open loanExceptionQuery, db, adOpenStatic
        count = loanExceptionRS.RecordCount
        loanExceptionRS.Close
        accountExceptCountEnd = Timer()
        accountExceptCountDelta = accountExceptCountDelta + (accountExceptCountEnd-accountExceptCountStart)
        accountExceptCount = accountExceptCount + 1
    END IF
    GetAccountExceptionCount = count
END FUNCTION

FUNCTION GetDocumentCount(theLoanId)
    Dim count : count = 0
    Dim docCountStart : docCountStart = Timer()
    IF searchDisplayDocs = 1 THEN
        Dim docRS : Set docRS = Server.CreateObject("ADODB.Recordset")
        Dim docQuery : docQuery = _
            " SELECT TOP 1 1" & _
            " FROM" & _
            " 	[document] as d INNER JOIN (" & _
            " 		SELECT CASE WHEN isCrossCollateralYN = N'Y' THEN primaryCollateralId ELSE loanId END AS loanId" & _
            " 		FROM loan" & _
            "       WHERE loanId = " & dbFormatId(theLoanId) & _
            " 	) AS l" & _
            " 	ON d.loanId = l.loanId" & _
            " WHERE d.documentStatus = 1"   
        docRS.Open docQuery, db
        IF NOT docRS.EOF THEN count = 1
        docRS.Close
    END IF

    Dim docCountEnd : docCountEnd = Timer()
    docCountDelta = docCountDelta + (docCountEnd-docCountStart)
    docCount = docCount + 1

    GetDocumentCount = count
END FUNCTION

FUNCTION BuildLoanUrlArgs( theloanId, theParentLoanId, isCollateralYN)
    Dim urlArgs : urlArgs = ""
    IF isCollateralYN = "Y" THEN
        urlArgs = "&loanId=" & theParentLoanId & "&collateralId=" & theloanId
    ELSE
        urlArgs = "&loanId=" & theloanId
    END IF
    BuildLoanUrlArgs = urlArgs
END FUNCTION

FUNCTION BuildCustomCreditFields()
    Dim str : str = ""
    FOR i = lBound(customCreditFields) TO uBound(customCreditFields)
        str = str & _
        "<td style=""" & GetCellStyle(customCreditFieldTypes(i)) & """>" & _
            FormatDataCell(customCreditFieldTypes(i), Customer(customCreditFields(i))) & _
        "</td>" & vbCr
    NEXT 
    BuildCustomCreditFields = str
END FUNCTION
%>