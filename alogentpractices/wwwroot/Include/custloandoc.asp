<%
    accountBlockTimeStart = Timer()
%>
<%
' ### NOTE: This code is dependant on variables in the customer.asp page. If changes are made make sure
' they are consistant with the parent page. ###

    Dim loanFieldsString
    employeeViewer = False
    ' ### Loan DOCUMENT FIELD LIST ###
    loanFieldsString = _
        "loanBranchId,documentTabId,docTabHighlightColor,docTabStatusType," & _
        "documentDefId,documentTypeId,documentSubTypeId," & _
        "documentSubTypeName,documentTypeName,typeSortOrder," & _
        "sortOrder,PurgeStatus,PurgeStatusLocked," & _
        "BlockPurge,subTypeDescription,subTypeInstruction," & _
        "requireExpdate,hideEmployeeFileYN,hideTabYN," & _
        "defaultActivationStatus,docDefHighlightColor,docDefDocSortBy," & _
        "typeActivationStatus,documentId,documentDescription," & _
        "loanFile,filename,documentAssociation,documentStatus," & _
        "origdate,modifieddate,expdate,documentStatusType," & _
        "documentComment,documentTitle," & _
        "documentHighlightColor,nonExpiring,docTabAllowSchedule," & _
        "docTabNextCreateDate,docTabProcessingDateEnd,"  & _
        "isParticipationLoan,CriticalQc,RequireQc,QcStatus,hasDemographicData"
    Dim loanFieldsArray : loanFieldsArray = Split(loanFieldsString, ",")
    Dim loanFieldsDict : Set loanFieldsDict = CreateObject("Scripting.Dictionary") 
    loanFieldsDict.CompareMode = TextMode ' ### NOTE: Need to set this flag... otherwise field names are CASE SENSITIVE

    ' ### Convert array into dictionary so we can use field names ###
    FOR i = lBound(loanFieldsArray) TO uBound(loanFieldsArray) 
        IF NOT loanFieldsDict.exists(loanFieldsArray(i)) THEN
            ' ### Name is the key, then matched with the field ordinal in the dictionary ###
            loanFieldsDict.add loanFieldsArray(i), i
        END IF
    NEXT

    IF (selectedAccountClassName = "Loan") THEN
        tabType = "L"
    ELSEIF (selectedAccountClassName = "Deposit") THEN
        tabType = "D"
    ELSEIF (selectedAccountClassName = "Trust") THEN
        tabType = "T"
    END IF

    Dim defaultSortBy(2)
    defaultSortBy(0) = 1
    defaultSortBy(1) = 3
    defaultSortBy(2) = 2

    Dim defaultDisplayBy(3)
    defaultDisplayBy(0) = 1
    defaultDisplayBy(1) = 3
    defaultDisplayBy(2) = 2
    defaultDisplayBy(3) = 7

    Dim loanSortBy : loanSortBy = Trim(Request("loanSortBy"))

    ' ### Initialize user sort loan by preferences ###
    Dim selectedSortLoanBy(2)
    FOR i = 0 TO 2
        selectedSortLoanBy(i) = Session("selectedSortLoanBy" & i)
        IF Trim(selectedSortLoanBy(i) & "") = "" THEN
            selectedSortLoanBy(i) = Request.Cookies("AccuLoan")("selectedSortLoanBy" & i)
            IF Trim(selectedSortLoanBy(i) & "") = "" THEN
                selectedSortLoanBy(i) = defaultSortBy(i)
                Session("selectedSortLoanBy" & i) = selectedSortLoanBy(i)
                Response.Cookies("AccuLoan")("selectedSortLoanBy" & i) = selectedSortLoanBy(i)
            END IF
        END IF
    NEXT

    ' ### Initialize user display loan by preferences ###
    Dim selectedDisplayLoanBy(3)
    FOR i = 0 TO 3
        selectedDisplayLoanBy(i) = Session("selectedDisplayLoanBy" & i)
        IF Trim(selectedDisplayLoanBy(i) & "") = "" THEN
            selectedDisplayLoanBy(i) = Request.Cookies("AccuLoan")("selectedDisplayLoanBy" & i)
            IF Trim(selectedDisplayLoanBy(i) & "") = "" THEN
                selectedDisplayLoanBy(i) = defaultdisplayBy(i)
                Session("selectedDisplayLoanBy" & i) = selectedDisplayLoanBy(i)
                Response.Cookies("AccuLoan")("selectedDisplayLoanBy" & i) = selectedDisplayLoanBy(i)
            END IF
        END IF
    NEXT

    strUrl = "customer.asp?"

    IF Session("selectedAccountClassCode") = "loan" THEN
        createNewAccountLabel = "Booked Loan"
        accountClassLabel = "Loan"
    ELSEIF Session("selectedAccountClassCode") = "deposit" THEN
        createNewAccountLabel = "Deposit"
        accountClassLabel = "Deposit"
    ELSEIF Session("selectedAccountClassCode") = "trust" THEN
        createNewAccountLabel = "Trust"
        accountClassLabel = "Trust"
    ELSE
        createNewAccountLabel = "Account"
        accountClassLabel = "Account"
    END IF

    accountFilterKey = "selected" & selectedAccountClassCode & "StatusFilter"
    selectedAccountStatusFilter = Request.Cookies("AccuLoan")(accountFilterKey)

    Dim selectedCustomerListPref : selectedCustomerListPref = Session("CustomerListPref")
    IF Trim(selectedCustomerListPref & "") = "" THEN selectedCustomerListPref = Request.Cookies("AccuLoan")("CustomerListPref")
    IF Trim(selectedCustomerListPref & "") = "" THEN selectedCustomerListPref = 0

    ' ### In 15.1 we made a conversion from char(1) to bit in the user table for custViewPref.
    ' This line of code is to prevent an error during the update when the char(1) could be
    ' stored in the session variable and cause an error when it converts to a boolean - PaulJ ###
    IF NOT IsNumeric(selectedCustomerListPref) THEN selectedCustomerListPref = 0
    %>

    <% IF NOT cBool(selectedCustomerListPref) THEN %>
    <!-- #include file="cust_accountlist.inc" -->
    <% ELSEIF cBool(selectedCustomerListPref) THEN %>
    <!-- #include file="cust_accountlist_complete.asp" -->
    <% END IF %>

    <%
    allowLoanBranchAccess = hasLoanBranchAccess(selectedLoanId)

    FUNCTION GetParticipationContactDetails(nContactId, nParticipationLoanId)
        Dim pStrOut : pStrOut = ""
        IF Trim(nContactId & "") = "" THEN
            Dim BankDetailsRS : Set BankDetailsRS = Server.CreateObject("ADODB.RecordSet")
            Dim BankDetailsQuery : BankDetailsQuery = _
                " SELECT " & _
                "   pl.participationPercentage " & _
                " FROM " & _
                "   participationLoan AS pl " & _
                " WHERE pl.participationLoanId = " & dbformatText2(nParticipationLoanId, false)
            BankDetailsRS.Open BankDetailsQuery, db, 3, 3

            pStrOut = "<table class=""aa-kendo-grid"">" & vbCr _
                    & "    <tbody>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td colspan=""2"">Participation Details</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Name:</td>" & vbCr _
                    & "            <td>No Contact is Currently Assigned</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Participation Percentage:</td>" & vbCr _
                    & "            <td>" & BankDetailsRS("ParticipationPercentage") & " %</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "    </tbody>" & vbCr _
                    & "</table>" & vbCr
            BankDetailsRS.Close
        ELSE
            Dim ContactDetailsRS : Set ContactDetailsRS = Server.CreateObject("ADODB.RecordSet")
            Dim ContactDetailsQuery : ContactDetailsQuery = _
                " SELECT " & _
                "   pl.participationloanId, " & _
                "   pbc.participationBankContactInfoId, " & _
                "   pb.participationBankId, " & _
                "   pb.participationBankname, " & _
                "   pbc.primaryContactName, " & _
                "   pbc.primaryPhoneNumber, " & _
                "   pbc.primaryEmail, " & _
                "   pbc.ccEmail, " & _
                "   pbc.rateChangeContactName, " & _
                "   pbc.rateChangePhone, " & _
                "   pbc.rateChangeEmail, " & _
                "   pl.affiliateCustomerNumber, " & _
                "   pl.affiliateLoanNumber, " & _
                "   pl.affiliateAccountTypeCode, " & _
                "   pl.participationPercentage, " & _
                "   l.customerId, " & _
                "   b.bankId, " & _
                "   (SELECT accountClassId FROM accountClass WHERE accountClassName = 'Loan') AS accountClassId " & _
                " FROM " & _
                "   participationBank AS pb " & _
                "   INNER JOIN participationBankContactInfo AS pbc ON pb.participationBankId = pbc.participationBankId " & _
                "   LEFT OUTER JOIN participationLoan AS pl ON pl.participationBankId = pb.participationBankId " & _
                "       AND pl.participationBankContactInfoId = pbc.participationBankContactInfoId " & _
                "   LEFT OUTER JOIN loan AS l ON l.loanId = " & dbformatText2(selectedLoanId, false) & _
                "   LEFT OUTER JOIN branch AS br ON l.loanBranchId = br.branchId" & _
                "   LEFT OUTER JOIN bank AS b ON b.bankId = br.bankId" & _
                " WHERE pl.participationBankContactInfoId = " & dbformatText2(nContactId, false) & _
                "   AND pl.loanId = "  & dbformatText2(selectedLoanId, false)
            ContactDetailsRS.Open ContactDetailsQuery, db, 3, 3
    
            pStrOut = "<table class=""aa-kendo-grid"">" & vbCr _
                    & "    <tbody>" & vbCr _
                    & "        <tr class=""no-background"">" & vbCr _
                    & "            <td colspan=""2""><h3>Primary Contact Details</h3></td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Name:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("primarycontactname") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Phone:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("primaryphonenumber") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Email:</td>" & vbCr _
                    & "            <td><a href=""mailto:" & ContactDetailsRS("primaryEmail") & """>" & ContactDetailsRS("primaryEmail") & "</a></td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>CC EMail:</td>" & vbCr _
                    & "            <td><a href=""mailto:" & ContactDetailsRS("ccEmail") & """>" & ContactDetailsRS("ccEmail") & "</a></td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr class=""no-background"">" & vbCr _
                    & "            <td colspan=""2""><h3>Rate Change Contact Details</h3></td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Name:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("ratechangecontactname") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Phone:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("ratechangephone") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Contact Email:</td>" & vbCr _
                    & "            <td><a href=""mailto:" & ContactDetailsRS("ratechangeEmail") & """>" & ContactDetailsRS("ratechangeEmail") & "</a></td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr class=""no-background"">" & vbCr _
                    & "            <td colspan=""2""><h3>Affiliate Bank Account Details</h3></td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Affiliate Customer Number:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("affiliatecustomernumber") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Affiliate Loan Number:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("affiliateLoannumber") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Affiliate Loan Type Code:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("affiliateAccountTypeCode") & "</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "        <tr>" & vbCr _
                    & "            <td>Participation Percentage:</td>" & vbCr _
                    & "            <td>" & ContactDetailsRS("ParticipationPercentage") & " %</td>" & vbCr _
                    & "        </tr>" & vbCr _
                    & "    </tbody>" & vbCr _
                    & "</table>" & vbCr
            ContactDetailsRS.Close
        END IF
        GetParticipationContactDetails = pStrOut
    END FUNCTION

    ' ### The following is a Hack to deal with Mat's poorly formed loanDocumentQuery below
    ' as it does not take into account guarantors for the file path.
    IF selectedLoanId <> "" THEN
        Dim primaryBorrowerRS : Set primaryBorrowerRS = Server.CreateObject("ADODB.RecordSet")
        Dim primaryIsEmployee : primaryIsEmployee = 0	
        Dim primaryBorrowerQuery : primaryBorrowerQuery = _
            " SELECT" & _
            "   c.employee," & _
            "   c.customerFolder," & _
            "   c.bankId," & _
            "   l.loanFolder" & _
            " FROM" & _
            "   customer AS c INNER JOIN loan AS l" & _
            "       ON c.customerId=l.customerId" & _
            " WHERE" & _
            "   l.loanId=" & dbFormatId(selectedLoanId)
        primaryBorrowerRS.Open primaryBorrowerQuery, db, adOpenStatic, adCmdText
        primaryCustomerFolder = primaryBorrowerRS("customerFolder")
        primaryLoanFolder = primaryBorrowerRS("loanFolder")
        primaryIsEmployee = primaryBorrowerRS("employee")
        IF IsNull(primaryIsEmployee) OR primaryIsEmployee = "" THEN primaryIsEmployee = 0

        IF Session("isSuperUser") THEN
            employeeViewer = True
        ELSEIF NOT IsThereAnEmployee(primaryIsEmployee, selectedLoanId) THEN
            employeeViewer = True
        ELSE
            FOR i = 1 TO bankmax
                IF cStr(primaryBorrowerRS("bankid")) = CStr(banksecurity(i,1)) THEN
                    IF banksecurity(i,2) = 1 THEN
                employeeViewer = True
                    END IF
                END IF
            NEXT
        END IF
        primaryBorrowerRS.Close
    END IF ' ### IF selectedLoanId <> ""

    ' ### The following code for determining displayLoans was in include/cust_accountlist.inc, but is moved
    ' here to avoid spaghetti code. ###
    extendedAccountClassCode = selectedAccountClassCode

    IF selectedLoanId <> "" THEN
        loanQuery = _
            "SELECT ls.isApplicationStatus" & _
            " FROM" & _
            "   loan AS l INNER JOIN loanStatus AS ls" & _
            "       ON l.loanStatusId=ls.statusId" & _
            " WHERE l.loanId=" & dbFormatId(selectedLoanId)
        loanRS.Open loanQuery, db, adOpenStatic, adCmdText
        IF NOT loanRS.EOF THEN
            IF loanRS("isApplicationStatus") THEN
                extendedAccountClassCode = "loanapp"
            END IF
        END IF
        loanRS.Close
    END IF

    displayLoans = False
    IF Session("isSuperUser") OR Session(extendedAccountClassCode & ".isAdmin") OR Session(extendedAccountClassCode & ".allowRead") OR Session(extendedAccountClassCode & ".allowEdit") THEN
        displayLoans = True
    END IF
    IF selectedAccountStatusFilter = "none" THEN displayLoans = False

    IF displayLoans then
        Dim loanClause
        IF selectedLoanId <> "" THEN
            loanClause = " AND loanId=" & dbFormatId(selectedLoanId) & " "
        ELSE
            loanClause = ""
        END IF

        ' ### NOTE: The subquery to get blocking purge elements has been removed (Ticket #3285) to
        ' improve speed and we can optimize it. ###

        loanQuery = _
            "SELECT " & _
            "   l.*, " & _
            "   ls.isApplicationStatus, " & _
            "   ls.statusDescription, " & _
            "   lt.loanTypeDescription, " & _
            "   lc.classificationName AS loanClassificationName, " & _
            "   lc.displayColor AS loanClassificationDisplayColor, " & _
            "   lc.displayEmphasis AS loanClassificationDisplayEmphasis, " & _
            "   lo.officerName, " & _
            "   br.branchName, " & _
            "   c.customerFolder, " & _
            "   IsNull(bt.borrowerTypeName, 'Primary') AS borrowerType, " & _
            "   ac.accountClassName, " & _
            "   ac.accountClassCode, " & _
            "   lt.PurgeControl AS loanTypePurgeControl, " & _
            "   CONVERT(bit, 0) AS AccountBlockPurge " & _
            " FROM " & _
            "   customer AS c  " & _
            "   INNER JOIN loan AS l ON c.customerId = l.customerId " & _
            "   INNER JOIN loanType as lt ON l.loanTypeId = lt.loanTypeId " & _
            "   INNER JOIN accountClass AS ac ON lt.accountClassId = ac.accountClassId " & _
            "   INNER JOIN loanOfficer AS lo ON lo.officerId = l.loanOfficerId " & _
            "   LEFT OUTER JOIN loanStatus AS ls ON ls.statusId = l.loanStatusId " & _
            "   LEFT OUTER JOIN creditClassification AS lc ON lc.classificationId = l.loanClassificationId " & _
            "   LEFT OUTER JOIN branch AS br ON br.branchId = l.loanBranchId " & _
            "   LEFT OUTER JOIN coborrower AS cb ON cb.loanId = l.loanId " & _
            "       AND cb.customerId = " & dbFormatId(selectedCustomerId) & _
            "   LEFT OUTER JOIN borrowerType AS bt ON bt.borrowerTypeId = cb.borrowerTypeId " & _
            " WHERE " & _
            "   l.loanId = " & dbFormatId(selectedLoanId)
        loanRS.Open loanQuery, db
        IF NOT loanRS.EOF THEN
            accountClassName=loanRS("accountClassName")
            IF uCase(accountClassName) = "LOAN" THEN
                typeNameString = "Loan"
                GuarantorsOrSigners = "Guarantors"
            ELSE
                typeNameString = "Account"
                GuarantorsOrSigners = "Signers"
            END IF
        END IF

        ' ### The following is used for accessing Account Flex Fields for all account
        ' include pages. It will always create due to the OUTER JOIN with the loan
        ' table. ###

        Dim loanFieldsRS : Set loanFieldsRS = Server.CreateObject("ADODB.RecordSet")
        Dim loanFieldsQuery : loanFieldsQuery = _
            " SELECT" & _
            "   lf.*" & _
            " FROM" & _
            "   loan AS l LEFT OUTER JOIN loanFields AS lf" & _
            "       ON l.loanId = lf.loanId" & _
            " WHERE" & _
            "   l.loanId = " & dbFormatId(selectedLoanId)
        loanFieldsRS.Open loanFieldsQuery, db, adOpenStatic, adCmdText

        DO UNTIL loanRS.EOF
            borrowerType = loanRS("borrowerType")
            loanAmountStr = loanRS("loanAmount")
            IF Trim(loanAmountStr & "") = "" OR IsNULL(loanAmountStr) THEN
                loanAmountStr = "0.0"
            END IF

            IF checkfornull(loanRS("commitmentAmount")) = "" then
                commitAmtStr = "0.0"
            ELSE
                commitAmtStr = loanRS("commitmentAmount")
            END IF

            ' ### Check for cross collaterals referencing this loan ###
            crossCollateralCount = 0
            crossCollateralQuery = "SELECT TOP 1 1 FROM loan WHERE primaryCollateralId = " & dbFormatId(loanRS("loanId"))
            crossCollateralRS.Open crossCollateralQuery, db
            IF NOT crossCollateralRS.EOF THEN crossCollateralCount = 1
            crossCollateralRS.Close

            IF crossCollateralCount > 0 THEN
                loanClassStyle = "crossed aa-background-base-green"
            ELSE
                loanClassStyle = "non-crossed aa-background-base-blue"
            END IF

            ' ### extededAccountClassCode used of user security permission levels ###
            extendedAccountClassCode = loanRS("accountClassCode")
            IF loanRS("isApplicationStatus") THEN extendedAccountClassCode = "loanapp"
        
            accountHeaderTimeStart = Timer()
            
            ' ### Display Header for active Application Accounts ###
            IF lCase(selectedAccountClassCode) = "loan" AND loanRS("isApplicationStatus") THEN
                Session("isloanapp") = true
                loanClassStyle = "non-crossed aa-background-base-blue"
                %>
                <!-- #include file="cust_accountheaderloanapp.inc" -->
                <%
            ' ### Display any Loan Account ###
            ELSEIF lCase(selectedAccountClassCode) = "loan" THEN
                Session("isloanapp") = false
                %>
                <!-- #include file="cust_accountheaderloan.inc" -->
                <%
            ' ### Display Header for Deposit Accounts ###
            ELSEIF lCase(selectedAccountClassCode) = "deposit" THEN
                Session("isloanapp") = false
                %>
                <!-- #include file="cust_accountheaderdeposit.inc" -->
                <%
            ELSEIF lCase(selectedAccountClassCode) = "trust" THEN
                Session("isloanapp") = false
                %>
                <!-- #include file="cust_accountheadertrust.inc" -->
                <%
            END IF ' ### Switch Account Headings

            accountHeaderTimeStop = Timer()
            accountHeaderTimeDelta = accountHeaderTimeStop-accountHeaderTimeStart

            IF selectedLoanTab = "" THEN selectedLoanTab = "document"
            arglist = "customerId=" & selectedCustomerId
            IF Trim(loanId & "") <> "" THEN arglist = arglist & "&loanId=" & selectedLoanId

            ' ### Set active tab style ###
            IF selectedLoanTab = "exception" AND cStr(selectedLoanId) = cStr(loanRS("loanId")) THEN
                activeTabStyle = "exception"
            ELSEIF selectedLoanTab = "borrower" AND cStr(selectedLoanId) = cStr(loanRS("loanId")) THEN
                activeTabStyle = "borrower"
            ELSEIF selectedLoanTab = "crosscollateral" AND cStr(selectedLoanId) = cStr(loanRS("loanId")) THEN
                activeTabStyle = "crosscollateral"
            ELSEIF selectedLoanTab = "comments" AND cStr(selectedLoanId) = cStr(loanRS("loanId")) THEN
                activeTabStyle = "comment"
            ELSEIF selectedLoanTab = "participation" THEN
                activeTabStyle = "participation"
            ELSE
                activeTabStyle = "document"
            END IF
            %>
            <div id="loan-header-separator"></div>
            <a name="loanGroupActivate" href="#"></a>
            <table class="aa-tab-table">
                <tr class="aa-tab-wrapper">
                    <td class="aa-tab-separator"></td>
                    <td class="aa-tab<% IF activeTabStyle = "document" THEN %>-selected<% END IF %>"><!-- #include file="cust_accountdoctab.inc" --></td>
                    <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
                    <td class="aa-tab-separator"></td>
                    <td class="aa-tab<% IF activeTabStyle = "exception" THEN %>-selected<% END IF %>"><!-- #include file="cust_accountexcepttab.inc" --></td>
                    <% END IF 'exceptiomMaintenanceYN = "Y" %>
                    <td class="aa-tab-separator"></td>
                    <td class="aa-tab<% IF activeTabStyle = "borrower" THEN %>-selected<% END IF %>"><!-- #include file="cust_accountsignertab.inc" --></td>
                    <% IF LoanRS("isParticipationLoan") THEN %>
                    <td class="aa-tab-separator"></td>
                    <td class="aa-tab<% IF activeTabStyle = "participation" THEN %>-selected<% END IF %>"><!-- #include file="cust_accountparticipationtab.inc" --></td>
                    <% END IF %>
                    <% IF crossCollateralCount > 0 AND (lCase(selectedAccountClassCode) = "loan") AND Session("accuaccount.enableExpress") <> 1 THEN %>
                    <td class="aa-tab-separator"></td>
                    <td class="aa-tab<% IF activeTabStyle = "crosscollateral" THEN %>-selected<% END IF %>"><!-- #include file="cust_accountcrosscoltab.inc" --></td>
                    <% END IF %>
                    <td class="aa-tab-separator"></td>
                    <td class="aa-tab<% IF activeTabStyle = "comment" THEN %>-selected<% END IF %>"><!-- #include file="cust_accountcommenttab.inc" --></td>
                    <td class="aa-pl6"><!-- #include file="cust_account_dropdown.asp" --></td>
                    <td class="aa-width-100">&nbsp;</td>
                </tr>
            </table>
            <table class="aa-width-100">
                <tr>
                    <td>
                    <% IF selectedLoanTab = "exception" AND CStr(selectedLoanId) = CStr(loanRS("loanId")) THEN %>
                    <!-- #include file="cust_accountexceptbody.inc" -->
                    <% ELSEIF selectedLoanTab = "borrower" AND CStr(selectedLoanId) = CStr(loanRS("loanId")) THEN %>
                    <!-- #include file="cust_accountsignerbody.inc" -->
                    <% ELSEIF selectedLoanTab = "crosscollateral" AND Session("accuaccount.enableExpress") <> 1 THEN %>
                    <!-- #include file="cust_accountcrosscolbody.inc" -->
                    <% ELSEIF selectedLoanTab = "comments" THEN %>
                    <!-- #include file="cust_accountcommentbody.inc" -->
                    <% ELSEIF selectedLoanTab = "participation" THEN %>
                    <!-- #include file="cust_accountparticipationbody.inc" -->
                    <% ELSE 'Default to document tab %>
                    <!-- #include file="cust_accountdocbody.inc" -->
                    <% END IF %>
                    </td>
                </tr>
            </table>
            <a name="collateralHeader"></a><%
            IF lCase(selectedAccountClassCode) = "loan" _
                OR (lCase(selectedAccountClassCode) = "deposit" And Session("accuaccount.enableDepositCollaterals") = 1) _
                OR (lCase(selectedAccountClassCode) = "trust" And Session("accuaccount.enableTrustCollaterals") = 1) THEN
                %><!-- #include file="collateraldocdisplay.asp" --><%
            END IF
            loanRS.MoveNext
        LOOP ' ### Until loanRS.eof
        loanRS.Close
    ELSE
        Dim loanCount : loanCount = 0
        Dim accountLabel
        Dim loanCountRS : Set loanCountRS = Server.CreateObject("ADODB.RecordSet")
        Dim loanCountQuery : loanCountQuery = _
            " SELECT" & _
            "   TOP 1 1 AS loanCount" & _
            " FROM" & _
            "   loan AS l " & _
            "   INNER JOIN loanType AS lt ON l.loanTypeId = lt.loanTypeId " & _
            "   INNER JOIN accountClass AS ac ON ac.accountClassId = lt.accountClassId" & _
            " WHERE" & _
            "   ac.accountClassId = " & dbFormatId(selectedAccountClassId) & _
            "   AND isCollateralYN = 'N' " & _
            "   AND customerId = " & dbFormatId(selectedCustomerId)
        loanCountRS.Open loanCountQuery, db, adOpenStatic, adCmdText
        IF NOT loanCountRS.EOF THEN loanCount = 1
        loanCountRS.Close
        Set loanCountRS = Nothing

        IF loanCount = 0 THEN
            IF selectedAccountClassName <> "" THEN
                %><div style="padding:10px"><b><i>This customer has no <%=selectedAccountClassName%>s.</i></b></div><%
            ELSE
                %><div style="padding:10px"><b><i>You do not have permission to view any accounts.  Please check with your administrator.</i></b></div><%
            END IF
        ELSE
            IF (Session(extendedAccountClassCode & ".allowRead") OR Session(extendedAccountClassCode & ".allowEdit") OR Session("isSuperUser") OR Session("credit.isAdmin")) THEN
                %><div style="padding:10px"><b><i>This customer has <%=loanCount%>&nbsp;<%=selectedAccountClassCode%><% if loanCount > 1 THEN %>s<% END IF %>, but they are not currently viewable.<br/><br/>
                To see the available <%=selectedAccountClassCode%>s, please click the edit preferences link and select additional <%=selectedAccountClassName%> statuses to view.</i></b></div><%
            ELSE
                %><div style="padding:10px"><b><i>You do not have permission to view this account or application.  Please check with your administrator.</i></b></div><%
            END IF ' ### User has Necessary Permission
        END IF ' ### loanCount = 0
    END IF ' ### displayLoans = true

    ' ### NOTE: collateralBlockTime subtracted as it's included in this page
    accountBlockTimeStop = Timer()
    accountBlockTimeDelta = accountBlockTimeStop - accountBlockTimeStart - collateralBlockTimeDelta

    FUNCTION IsThereAnEmployee(nPrimaryEmployee, nLoanId)
        Dim loanBorrowersQuery, loanBorrowersRS, coborrowersEmployee
        Set loanBorrowersRS = Server.CreateObject("ADODB.RecordSet")
        loanBorrowersQuery = _
            " SELECT COUNT(c.customerId) AS NumEmployeeCoborrowers" & _
            "   FROM coborrower AS cb" & _
            "       INNER JOIN customer AS c ON cb.customerId=c.customerId" & _
            " WHERE cb.loanId = " & dbFormatId(nLoanId) & _
            "   AND c.employee = 1"
        loanBorrowersRS.Open loanBorrowersQuery, db, adOpenStatic, adCmdText
        coborrowersEmployee = cBool(loanBorrowersRS("NumEmployeeCoborrowers"))
        loanBorrowersRS.Close
        IF (nPrimaryEmployee OR coborrowersEmployee) THEN
            IsThereAnEmployee = True
        ELSE
            IsThereAnEmployee = False
        END IF
    END FUNCTION
%>