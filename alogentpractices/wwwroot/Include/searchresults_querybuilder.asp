<%
Dim showDebug : showDebug = false
IF showDebug THEN Response.Write "<br/><br/><br/><br/><br/>"

' ### Get search form input - Customer Search Fields ###
Dim searchType            : searchType            = Request("searchType")
Dim searchName            : searchName            = requestOrSession("name", "searchName")
Dim searchCustomerNumber  : searchCustomerNumber  = requestOrSession("customerID", "searchCustomerNumber")
Dim searchTaxId           : searchTaxId           = requestOrSession("taxID", "searchTaxId")
Dim searchcustomerStatus  : searchcustomerStatus  = requestOrSession("searchcustomerStatus", "searchCustomerStatus")
Dim searchcustomerType    : searchcustomerType    = requestOrSession("customerType", "searchcustomerType")
Dim searchCustomerOfficer : searchCustomerOfficer = requestOrSession("customerOfficer", "searchCustomerOfficer")
Dim searchCustomerBranch  : searchCustomerBranch  = requestOrSession("customerBranch", "searchCustomerBranch")

' ### Account Search Fields ###
Dim searchloan             : searchloan             = requestOrSession("loan", "searchLoan")
Dim searchLoanStatus       : searchLoanStatus       = requestOrSession("loanStatus", "searchLoanStatus")
Dim searchloanType         : searchloanType         = requestOrSession("loanType", "searchLoanType")
Dim searchBank             : searchBank             = requestOrSession("bank", "searchbankId")
Dim searchloanOfficer      : searchloanOfficer      = requestOrSession("loanOfficer", "searchLoanOfficer")
Dim searchFromLoanOrgDate  : searchFromLoanOrgDate  = requestOrSession("fromOrgDate", "searchFromLoanOrgDate")
Dim searchToLoanOrgDate    : searchToLoanOrgDate    = requestOrSession("toOrgDate", "searchToLoanOrgDate")
Dim searchLoanDescription  : searchLoanDescription  = requestOrSession("loanDescription", "searchLoanDescription")
Dim searchLoanBranch       : searchLoanBranch       = requestOrSession("loanBranch", "searchLoanBranch")
Dim searchClassificationId : searchClassificationId = requestOrSession("classificationId", "searchClassificationId")
Dim searchAccountClassId   : searchAccountClassId   = requestOrSession("accountClassId", "searchAccountClassId")
Dim searchAccountClassList : searchAccountClassList = requestOrSession("accountClassList", "searchAccountClassList")
Dim searchMaxResult        : searchMaxResult        = requestOrSession("maxResult", "searchMaxResult")
Dim searchDocumentFilter   : searchDocumentFilter   = requestOrSession("documentFilter", "searchDocumentFilter")
Dim searchDisplayDocs      : searchDisplayDocs      = requestOrSession("displayDocs", "searchDisplayDocs")
Dim searchParticipation    : searchParticipation    = requestOrSession("searchParticipation", "searchParticipation")

' ### Application Search Fields ###
Dim srchappDateFrom      : srchappDateFrom      = requestOrSession("appDateFrom", "searchAppDateFrom")
Dim srchappDateTo        : srchappDateTo        = requestOrSession("appDateTo", "searchAppDateTo")
Dim srchappLender        : srchappLender        = requestOrSession("appLender", "searchAppLender")
Dim srchappDelegate      : srchappDelegate      = requestOrSession("appDelegate", "searchAppDelegate")
Dim srchappAnalyst       : srchappAnalyst       = requestOrSession("appAnalyst", "searchAppAnalyst")
Dim srchapprovalStatusId : srchapprovalStatusId = requestOrSession("approvalStatusId", "searchApprovalStatusId")
Dim srchloanStatusId     : srchloanStatusId     = requestOrSession("loanStatusId", "searchLoanStatusId")
Dim srchappApprover      : srchappApprover      = requestOrSession("appApprover", "searchAppApprover")

Dim hasCreditSearchData     : hasCreditSearchData     = False
Dim hasLoanSearchData       : hasLoanSearchData       = False
Dim hasCollateralSearchData : hasCollateralSearchData = False
Dim hasAppSearchData        : hasAppSearchData        = False

IF Len(srchappDateFrom) > 0 OR Len(srchappDateTo) > 0 OR Len(srchappLender) > 0 OR Len(srchappDelegate) > 0 _
    OR Len(srchappAnalyst) > 0 OR Len(srchapprovalStatusId) > 0 OR Len(srchloanStatusId) > 0 _
    OR Len(srchappApprover) > 0 THEN
    hasAppSearchData = True
END IF

' ### Ensure default value for maxResult. -1 indicates unlimited results ###
IF searchMaxResult = "" THEN searchMaxResult = Session("searchMaxResult")
IF searchMaxResult = "" THEN searchMaxResult = 250

' ### Get banks this user can access ###
Dim bankmax : bankmax = int(session("userbanklen"))

IF bankmax > 0 THEN
    banksecurity = Session("userbanks")
ELSE
    Dim banksecurity(20, 2)
END IF

Dim maxResultClause : maxResultClause = " TOP " & searchMaxResult

' ### Corelink Integration Features ###
' ### The following intercepts corelink functionality ###
Dim args            : Set args = Request("search")
Dim coreLink        : coreLink = Trim(Request("coreLink") & "")
Dim interfaceSearch : interfaceSearch = false

' ### Check to see if we have corelink arguments ###
Dim coreLinkCustomerSearchClause    : coreLinkCustomerSearchClause = ""
Dim coreLinkAccountSearchClause     : coreLinkAccountSearchClause = ""
Dim coreLinkCollateralSearchClause  : coreLinkCollateralSearchClause = ""

IF NOT IsEmpty(args) THEN
    ' ### Initialize for building where clauses ###
    Dim argCount : argCount = args.Count
    ReDim searchArg(argCount)
    interfaceSearch = true

    ' ### Parse the search arguments for corelink and build where clauses ###
    Dim coreLinkCustomerClause      : coreLinkCustomerClause = ""
    Dim coreLinkLoanClause          : coreLinkLoanClause = ""
    Dim coreLinkCollateralClause    : coreLinkCollateralClause = ""

    '### Setup search clauses for full search if CORELink returns multiple search arguments ###
    FOR i = 1 TO args.count
        searchArg(i) = Trim(Replace(args(i), "'", "''"))
        IF Session("accuaccount.exactCoreLinkSearch") = 1 THEN
            coreLinkCustomerClause = coreLinkCustomerClause & _
                " c.customerNumber = " & dbformattext(searchArg(i)) & _
                " OR c.customerName LIKE " & dbformattext("%" & searchArg(i) & "%") & _
                " OR c.BusinessName LIKE " & dbformattext("%" & searchArg(i) & "%") & _
                " OR c.TaxId = " & dbformattext(searchArg(i)) & " OR "
            
            coreLinkLoanClause = coreLinkLoanClause & _
                " l.loanNumber = " & dbformattext(searchArg(i)) & " OR "

            coreLinkCollateralClause = coreLinkCollateralClause & _
                " l.loanNumber = " & dbformattext(searchArg(i)) & _
                " OR pl.loanNumber = " & dbformattext(searchArg(i)) & " OR "
        ELSE
            coreLinkCustomerClause = coreLinkCustomerClause & _
                " c.customerNumber LIKE " & dbformattext("%" & searchArg(i) & "%") & _
                " OR c.customerName LIKE " & dbformattext("%" & searchArg(i) & "%") & _
                " OR c.BusinessName LIKE " & dbformattext("%" & searchArg(i) & "%") & _
                " OR c.TaxId LIKE " & dbformattext("%" & searchArg(i) & "%") & " OR "

            coreLinkLoanClause = coreLinkLoanClause & _
                " l.loanNumber LIKE " & dbformattext("%" & searchArg(i) & "%") & " OR "

            coreLinkCollateralClause = coreLinkCollateralClause & _
                "l.loanNumber LIKE " & dbformattext("%" & searchArg(i) & "%") & _
                " OR pl.loanNumber LIKE " & dbformattext("%" & searchArg(i) & "%") & " OR "
        END IF
    NEXT

    coreLinkCustomerClause = Left(coreLinkCustomerClause,Len(coreLinkCustomerClause)-3)
    coreLinkLoanClause = Left(coreLinkLoanClause,Len(coreLinkLoanClause)-3)
    coreLinkCollateralClause = Left(coreLinkCollateralClause,Len(coreLinkCollateralClause)-3)

    coreLinkCustomerClause = coreLinkCustomerClause & ""
    coreLinkLoanClause = coreLinkLoanClause & ""
    coreLinkCollateralClause = coreLinkCollateralClause & ""

    coreLinkCustomerSearchClause = " AND (" & coreLinkCustomerClause & ")"
    coreLinkAccountSearchClause = " AND (" & coreLinkCustomerClause & " OR " & coreLinkLoanClause & ")"
    coreLinkCollateralSearchClause = " AND (" & coreLinkCustomerClause & " OR " & coreLinkCollateralClause & ")"

    '### Setup special filter when CORELink passes only one argument for Quick Search ###
    IF args.Count = 1 THEN ' ### Comes from corelink accelerator
        searchloan = Trim(args(1))
        searchName = Trim(args(1))
        searchCustomerNumber = Trim(args(1))
        searchTaxId = Trim(args(1))
    END IF
END IF

Call CreateTempTables()
Call FillTempTables()

Dim searchQuery : searchQuery = BuildSearchQuery()
Dim loanQuery : loanQuery = BuildLoanQuery()

' ### Check for single customer/account and redirect if singleton ###
ProcessQuickSearch()

IF showDebug THEN
    Response.Write "searchQuery = " & searchQuery & "<br/><br/>"
    Response.Write "loanQuery = " & loanQuery & "<br/><br/>"
END IF

Session("Query") = searchQuery
Session("loanQuery") = loanQuery

' ### Special method to process QuickSearch ###
SUB ProcessQuickSearch()
    ' ### NOTE: the following is to optimize QuickSearch to bypass the searchresults page if only one cutomer/loan results. ###
    Dim creditSelectClause, accountSelectClause, creditFromClause, accountFromClause, creditWhereClause, accountWhereClause, urlRedirect
    Dim baseTestQuery, testQuery
    Dim testRS : Set testRS = Server.CreateObject("ADODB.RecordSet")

    ' ### NOTE: When a new search parameter is added to the search page, please ensure that you add the passed parameter/s to the
    ' following 'IF' statement or it will be ignored by QuickSearch. ###
    IF searchcustomerType <> "" OR searchLoanStatus <> "" OR searchloanType <> "" OR searchloanOfficer <> "" OR searchFromLoanOrgDate <> "" OR searchToLoanOrgDate <> "" OR searchCustomerOfficer <> "" OR searchLoanDescription <> "" OR searchCustomerBranch <> "" OR searchLoanBranch <> "" OR searchClassificationId <> "" OR searchAccountClassId <> "" OR searchAccountClassList <> "" OR searchDocumentFilter <> "" OR searchDisplayDocs <> "" OR searchParticipation = "1" THEN
        EXIT SUB
    END IF

    IF searchloan <> "" Or searchName <> "" Or searchCustomerNumber <> "" Or searchTaxId <> "" THEN
        ' ### Build detailed SELECT clause ###
        creditSelectClause = BuildCreditSelectClause()
        accountSelectClause = BuildAccountSelectClause()

        ' ### Build the core FROM clause ###
        creditFromClause = BuildCreditFromClause(false)
        accountFromClause = BuildAccountFromClause(false)

        ' ### Build the core WHERE clause ###
        creditWhereClause = _
            " WHERE 1 = 1 " & _
            BuildAccountParticipationFilter(searchParticipation, false)

        accountWhereclause = _
            " WHERE 1 = 1 " & _
            BuildAccountParticipationFilter(searchParticipation, false)

        baseTestQuery = _
            " SELECT " & maxResultClause & " * " & _
            " FROM ( " & _
            creditSelectClause & _
            creditFromClause & _
            " @creditWhereClause " & _
            " UNION ALL " & _
            accountSelectClause & _
            accountFromClause & _
            " @accountWhereClause " & _
            " ) AS v"

        IF Trim(searchLoan & "") <> "" THEN
            Dim recordCount : recordCount = 0
            'creditWhereClause = creditWhereClause & BuildAccountNumberFilter(searchLoan)
            accountWhereClause = accountWhereClause & BuildAccountNumberFilter(searchLoan)

            testQuery = Replace(baseTestQuery, "@creditWhereClause", creditWhereClause)
            testQuery = Replace(testQuery, "@accountWhereClause", accountWhereClause)
            testRS.Open testQuery, db, adOpenStatic, adCmdText

            DO UNTIL testRS.EOF
                Dim nLoanId : nLoanId = "" : nLoanId = testRS("loanId")
                IF Trim(nLoanId & "") <> "" THEN
                    recordCount = recordCount + 1
                    Dim nParentLoanId : nParentLoanId = "" : nParentLoanId = testRS("parentLoanId")
                    IF Trim(nParentLoanId & "") <> "" THEN
                        urlRedirect = "customer.asp?customerId=" & testRS("customerId") & "&loanId=" & testRS("parentLoanId") & "&collateralId=" & testRS("loanId")
                    ELSE
                        urlRedirect = "customer.asp?customerId=" & testRS("customerId") & "&loanId=" & testRS("loanId")
                    END IF
                END IF
                testRS.moveNext
            LOOP
            testRS.Close

            IF recordCount > 1 THEN urlRedirect = ""

            IF Trim(urlRedirect & "") <> "" THEN Response.Redirect(urlRedirect)
        END IF

        IF Trim(searchTaxId & "") <> "" THEN
            creditWhereClause = creditWhereClause & BuildTaxIdFilter(searchTaxId)
            accountWhereClause = accountWhereClause & BuildTaxIdFilter(searchTaxId)

            testQuery = Replace(baseTestQuery, "@creditWhereClause", creditWhereClause)
            testQuery = Replace(testQuery, "@accountWhereClause", accountWhereClause)
            testQuery = _
                " SELECT DISTINCT customerId" & _
                " FROM ( " & testQuery & ") AS v2"

            testRS.Open testQuery, db, adOpenStatic, adCmdText
            IF testRS.RecordCount = 1 THEN
                urlRedirect = "customer.asp?customerId=" & testRS("customerId")
            END IF
            testRS.Close

            IF urlRedirect <> "" THEN Response.Redirect(urlRedirect)
        END IF

        IF Trim(searchCustomerNumber & "") <> "" THEN
            creditWhereClause = creditWhereClause & BuildCustomerNumberFilter(searchCustomerNumber)
            accountWhereClause = accountWhereClause & BuildCustomerNumberFilter(searchCustomerNumber)

            testQuery = Replace(baseTestQuery, "@creditWhereClause", creditWhereClause)
            testQuery = Replace(testQuery, "@accountWhereClause", accountWhereClause)
            testQuery = _
                " SELECT DISTINCT customerId" & _
                " FROM ( " & testQuery & ") AS v2"

            testRS.Open testQuery, db, adOpenStatic, adCmdText
            IF testRS.RecordCount = 1 THEN
                urlRedirect = "customer.asp?customerId=" & testRS("customerId")
            END IF
            testRS.Close

            IF urlRedirect <> "" THEN Response.Redirect(urlRedirect)
        END IF

        IF Trim(searchName & "") <> "" THEN
            creditWhereClause = creditWhereClause & BuildCustomerNameFilter(searchName)
            accountWhereClause = accountWhereClause & BuildCustomerNameFilter(searchName)

            testQuery = Replace(baseTestQuery, "@creditWhereClause", creditWhereClause)
            testQuery = Replace(testQuery, "@accountWhereClause", accountWhereClause)
            testQuery = _
                " SELECT DISTINCT customerId" & _
                " FROM ( " & testQuery & ") AS v2"

            testRS.Open testQuery, db, adOpenStatic, adCmdText
            IF testRS.RecordCount = 1 THEN
                urlRedirect = "customer.asp?customerId=" & testRS("customerId")
            END IF
            testRS.Close

            IF urlRedirect <> "" THEN Response.Redirect(urlRedirect)
        END IF
    END IF ' ### searchloan <> "" Or searchName <> "" Or searchCustomerNumber <> "" Or searchTaxId <> ""
END SUB ' ### ProcessQuickSearch()

'### Create the temporary tables for filtering data results ###
SUB CreateTempTables()
    Dim sql : sql  = _
        " CREATE TABLE #tmpCustomer (" & _
        "   customerId uniqueidentifier NOT NULL UNIQUE" & _
        " );" & _
        " CREATE TABLE #tmpAccount (" & _
        "   customerId uniqueidentifier NOT NULL," & _
        "   loanId uniqueidentifier NOT NULL UNIQUE" & _
        " );" & _
        " CREATE TABLE #tmpCollateral (" & _
        "   customerId uniqueidentifier NOT NULL," & _
        "   parentLoanId uniqueidentifier NOT NULL," & _
        "   collateralLoanId uniqueidentifier NOT NULL UNIQUE" & _
        " );"
    IF showDebug THEN Response.write "-- Create Temp Tables <br />" & sql & "<br /><br />"
    db.Execute(sql)
END SUB

SUB DeleteTempTables()
    Dim sql : sql = _
        " IF OBJECT_ID('tempdb..#tmpCollateral') IS NOT NULL DROP TABLE #tmpCollateral;" & _
        " IF OBJECT_ID('tempdb..#tmpAccount') IS NOT NULL DROP TABLE #tmpAccount;" & _
        " IF OBJECT_ID('tempdb..#tmpCustomer') IS NOT NULL DROP TABLE #tmpCustomer;"
    IF showDebug THEN Response.write "-- Delete Temp Tables <br />" & sql & "<br /><br />"
    db.Execute(sql)
END SUB

SUB FillTempTables()
    Call FillTempCollateralTable()
    Call FillTempAccountTable()
    Call FillTempCustomerTable()
END SUB

SUB FillTempCustomerTable()
    IF Trim(Session("FillTempCustomerQuery1") & "") = "" AND Trim(Session("FillTempCustomerQuery2") & "") = "" THEN
        '### Build out the WHERE clause ###
        Dim clause : clause = ""

        '### Branch security filters ###
        clause = clause & BuildBranchSecurityFilter("credit")

        '### Credit field filters ###
        IF CoreLink <> "" THEN
            clause = clause & coreLinkCustomerSearchClause
        ELSE
            clause = clause & BuildCustomerNameFilter(searchName)
            clause = clause & BuildCustomerNumberFilter(searchCustomerNumber)
            clause = clause & BuildTaxIdFilter(searchTaxId)
            clause = clause & BuildCustomerStatusFilter(searchCustomerStatus)
            clause = clause & BuildCustomerTypeFilter(searchCustomerType)
            clause = clause & BuildCustomerOfficerFilter(searchCustomerOfficer)
            clause = clause & BuildCustomerBranchFilter(searchCustomerBranch)
            clause = clause & BuildCreditClassificationFilter(searchClassificationId)
            clause = clause & BuildCustomCreditFieldFilter()

            clause = clause & BuildExtendedSearchFilterWhereClause("credit")
        END IF

        Dim sql : sql = _
            " INSERT INTO #tmpCustomer (customerId)" & _
            " SELECT DISTINCT c.customerId" & _
            " FROM customer AS c" & _
            BuildExtendedSearchFilterFromClause("credit")

        '### Constrain customer results to values found in #tmpAccount if user provided specific account/application filters ###
        IF hasLoanSearchData OR hasAppSearchData THEN
            sql = sql & _
                " INNER JOIN #tmpAccount AS ta" & _
                "   ON ta.customerId = c.customerId"
        END IF

        Session("FillTempCustomerQuery1") = sql & " WHERE 1 = 1 " & clause

        '### Add account customers into #tmpCustomer that did not match parent conditions
        sql = _
            " INSERT INTO #tmpCustomer (customerId) " & _
            " SELECT v1.customerId" & _
            " FROM" & _
            "   (SELECT DISTINCT customerId FROM #tmpAccount) AS v1" & _
            "   LEFT OUTER JOIN #tmpCustomer" & _
            "      ON v1.customerId = #tmpCustomer.customerId" & _
            " WHERE" & _
            "   #tmpCustomer.customerId IS NULL"
            
        Session("FillTempCustomerQuery2") = sql
    END IF

    IF showDebug THEN Response.Write "--FillTempCustomer:<BR>" & Session("FillTempCustomerQuery1") & "<br><br>"
    IF showDebug THEN Response.Write "--FillTempCustomerTable <br/>" & Session("FillTempCustomerQuery2") & "<br/><br/>"

    IF Trim(Session("FillTempCustomerQuery1") & "") <> "" THEN CALL ExecuteCommand(Session("FillTempCustomerQuery1"), BUILD_QUERY_TIMEOUT)
    IF Trim(Session("FillTempCustomerQuery2") & "") <> "" THEN CALL ExecuteCommand(Session("FillTempCustomerQuery2"), BUILD_QUERY_TIMEOUT)

END SUB

SUB FillTempAccountTable()
    IF Trim(Session("FillTempAccountQuery1") & "") = "" AND Trim(Session("FillTempAccountQuery2") & "") = "" AND Trim(Session("FillTempAccountQuery3") & "") = "" AND Trim(Session("FillTempAccountQuery4") & "") = "" THEN
        ' ### Build out the WHERE clause ###
        Dim clause : clause = ""

        ' ### Branch security filters ###
        clause = clause & BuildBranchSecurityFilter("account")

        IF coreLink <> "" THEN
            clause = clause & coreLinkAccountSearchClause
        ELSE
            ' ### credit field filters
            clause = clause & BuildCustomerNameFilter(searchName)
            clause = clause & BuildCustomerNumberFilter(searchCustomerNumber)
            clause = clause & BuildTaxIdFilter(searchTaxId)
            clause = clause & BuildCustomerStatusFilter(searchCustomerStatus)
            clause = clause & BuildCustomerTypeFilter(searchCustomerType)
            clause = clause & BuildCustomerOfficerFilter(searchCustomerOfficer)
            clause = clause & BuildCustomerBranchFilter(searchCustomerBranch)
            clause = clause & BuildCreditClassificationFilter(searchClassificationId)
            clause = clause & BuildCustomCreditFieldFilter()

            ' ### account/collateral field filters
            clause = clause & BuildAccountNumberFilter(searchLoan)
            clause = clause & BuildAccountDescriptionFilter(searchLoanDescription)
            clause = clause & BuildAccountClassFilter(searchAccountClassId, false)
            clause = clause & BuildAccountTypeFilter(searchLoanType)
            clause = clause & BuildAccountStatusFilter(searchLoanStatus)
            clause = clause & BuildAccountOfficerFilter(searchLoanOfficer, false)
            clause = clause & BuildAccountOriginationDateFilter(searchFromLoanOrgDate, searchToLoanOrgDate, false)
            clause = clause & BuildAccountParticipationFilter(searchParticipation, false)
            clause = clause & BuildAccountBranchFilter(searchLoanBranch, false)
            clause = clause & BuildCustomAccountFieldFilter()
            clause = clause & BuildCustomCollateralFieldFilter()

            ' ### Build Loan Application Filters ###
            clause = clause & BuildApplicationDateFilter(srchappDateFrom, srchappDateTo)
            clause = clause & BuildApplicationLenderFilter(srchappLender)
            clause = clause & BuildApplicationDelegateFilter(srchappDelegate)
            clause = clause & BuildApplicationAnalystFilter(srchappAnalyst)
            clause = clause & BuildApplicationApprovalStatusFilter(srchapprovalStatusId)
            clause = clause & BuildApplicationLoanStatusFilter(srchloanStatusId)
            clause = clause & BuildApplicationApproverFilter(srchappApprover)

            clause = clause & BuildExtendedSearchFilterWhereClause("account")
        END IF

        Dim sql : sql = _
            " INSERT INTO #tmpAccount (customerId, loanId)" & _
            " SELECT" & _
            "   DISTINCT c.customerId, l.loanId" & _
            " FROM" & _
            "   customer AS c INNER JOIN loan AS l" & _
            "       ON c.customerId = l.customerId" & _
            "       AND l.isCollateralYN = 'N'" & _
            "   INNER JOIN loanStatus AS ls" & _
            "       ON ls.statusId = l.loanStatusId" & _
            "   INNER JOIN accountClass AS ac" & _
            "       ON ac.accountClassId = ls.accountClassId" & _
            BuildLoanAppFieldFrom() & _
            BuildExtendedSearchFilterFromClause("account")

        Session("FillTempAccountQuery1") = sql & " WHERE 1 = 1 " & clause
        
        ' ### Ensure parentLoanId from #tmpCollateral in the #tmpAccount table ###
        sql = _
            " INSERT INTO #tmpAccount (customerId, loanId)" & _
            " SELECT DISTINCT c.customerId, c.parentLoanId" & _
            " FROM" & _
            "   #tmpCollateral AS c LEFT OUTER JOIN #tmpAccount AS l" & _
            "       ON c.parentLoanId = l.loanId" & _
            " WHERE l.loanId IS NULL"
        Session("FillTempAccountQuery2") = sql

        ' ### Add collateral parentLoanIds into #tmpAccount that did not match parent conditions
        sql = _
            " INSERT INTO #tmpAccount (customerId, loanId) " & _
            " SELECT v1.customerId, v1.parentLoanId" & _
            " FROM" & _
            "   (SELECT DISTINCT customerId, parentLoanId FROM #tmpCollateral) AS v1" & _
            "   LEFT OUTER JOIN #tmpAccount" & _
            "      ON v1.parentLoanId = #tmpAccount.loanId" & _
            " WHERE" & _
            "   #tmpAccount.loanId IS NULL"
        Session("FillTempAccountQuery3") = sql

        ' ### Add collateralLoanIds into #tmpAccount ###
        ' This is to ensure that only the Accounts and their filtered Collaterals are joined in the master searchQuery instead
        ' of getting all Accounts collaterals.
        sql = _
            " INSERT INTO #tmpAccount (customerId, loanId) " & _
            " SELECT v1.customerId, v1.collateralLoanId" & _
            " FROM" & _
            "   (SELECT DISTINCT customerId, collateralLoanId FROM #tmpCollateral) AS v1" & _
            "   LEFT OUTER JOIN #tmpAccount" & _
            "      ON v1.collateralLoanId = #tmpAccount.loanId" & _
            " WHERE" & _
            "   #tmpAccount.loanId IS NULL"
        Session("FillTempAccountQuery4") =  sql
    END IF

    IF showDebug THEN Response.Write "--FillTempAccountTable:<BR>" & Session("FillTempAccountQuery1") & "<br><br>"
    IF showDebug THEN Response.Write "--FillTempAccountTable <br/>" & Session("FillTempAccountQuery2") & "<br/><br/>"
    IF showDebug THEN Response.Write "--FillTempAccountTable <br/>" & Session("FillTempAccountQuery3") & "<br/><br/>"
    IF showDebug THEN Response.Write "--FillTempAccountTable <br/>" & Session("FillTempAccountQuery4") & "<br/><br/>"

    IF Trim(Session("FillTempAccountQuery1") & "") <> "" THEN Call ExecuteCommand(Session("FillTempAccountQuery1"), BUILD_QUERY_TIMEOUT)
    IF Trim(Session("FillTempAccountQuery2") & "") <> "" THEN Call ExecuteCommand(Session("FillTempAccountQuery2"), BUILD_QUERY_TIMEOUT)
    IF Trim(Session("FillTempAccountQuery3") & "") <> "" THEN Call ExecuteCommand(Session("FillTempAccountQuery3"), BUILD_QUERY_TIMEOUT)
    IF Trim(Session("FillTempAccountQuery4") & "") <> "" THEN Call ExecuteCommand(Session("FillTempAccountQuery4"), BUILD_QUERY_TIMEOUT)
END SUB

SUB FillTempCollateralTable()
    IF Trim(Session("FillTempCollateralQuery1") & "") = "" THEN
        ' ### Build out the WHERE clause ###
        Dim clause : clause = ""
    
        ' ### Branch security filters ###
        clause = clause & BuildBranchSecurityFilter("account")
    
        IF coreLink <> "" THEN
            clause = clause & coreLinkCollateralSearchClause
        ELSE
            ' ### credit field filters
            clause = clause & BuildCustomerNameFilter(searchName)
            clause = clause & BuildCustomerNumberFilter(searchCustomerNumber)
            clause = clause & BuildTaxIdFilter(searchTaxId)
            clause = clause & BuildCustomerStatusFilter(searchCustomerStatus)
            clause = clause & BuildCustomerTypeFilter(searchCustomerType)
            clause = clause & BuildCustomerOfficerFilter(searchCustomerOfficer)
            clause = clause & BuildCustomerBranchFilter(searchCustomerBranch)
            clause = clause & BuildCreditClassificationFilter(searchClassificationId)
            clause = clause & BuildCustomCreditFieldFilter()
    
            ' ### account/collateral field filters
            clause = clause & BuildAccountNumberFilter(searchLoan)
            clause = clause & BuildAccountDescriptionFilter(searchLoanDescription)
            clause = clause & BuildAccountClassFilter(searchAccountClassId, true)
            clause = clause & BuildAccountTypeFilter(searchLoanType)
            clause = clause & BuildAccountStatusFilter(searchLoanStatus)
            clause = clause & BuildAccountOfficerFilter(searchLoanOfficer, true)
            clause = clause & BuildAccountOriginationDateFilter(searchFromLoanOrgDate, searchToLoanOrgDate, true)
            clause = clause & BuildAccountParticipationFilter(searchParticipation, true)
            clause = clause & BuildAccountBranchFilter(searchLoanBranch, true)
            clause = clause & BuildCustomAccountFieldFilter()
            clause = clause & BuildCustomCollateralFieldFilter()
    
            clause = clause & BuildExtendedSearchFilterWhereClause("account")
        END IF

        Dim sql : sql = _
            " INSERT INTO #tmpCollateral (customerId, parentLoanId, collateralLoanId)" & _
            " SELECT" & _
            "   DISTINCT c.customerId, cl.parentLoanId AS parentLoanId, l.loanId AS collateralLoanId" & _
            " FROM" & _
            "   customer AS c INNER JOIN loan AS l" & _
            "       ON c.customerId = l.customerId" & _
            "       AND l.isCollateralYN = 'Y'" & _
            "   INNER JOIN loanStatus AS ls" & _
            "       ON ls.statusId = l.loanStatusId" & _
            "   INNER JOIN accountClass AS ac" & _
            "       ON ac.accountClassId = ls.accountClassId" & _
            "   INNER JOIN collateral AS cl" & _
            "       ON cl.collateralLoanId = l.loanId" & _
            "   LEFT OUTER JOIN loan AS pl" & _
            "       ON pl.loanId = cl.parentLoanId" & _
            BuildLoanAppFieldFrom() & _
            BuildExtendedSearchFilterFromClause("account")
        IF clause <> "" THEN
            hasCollateralSearchData = True
            hasLoanSearchData = False
        END IF
        
        Session("FillTempCollateralQuery1") = sql & " WHERE 1 = 1 " & clause
    END IF
    
    IF showDebug THEN Response.Write "--FillTempCollateralTable:<BR>" & Session("FillTempCollateralQuery1") & "<br><br>"

    IF Trim(Session("FillTempCollateralQuery1") & "") <> "" THEN CALL ExecuteCommand(Session("FillTempCollateralQuery1"), BUILD_QUERY_TIMEOUT)

END SUB

FUNCTION BuildSearchQuery()
    Dim accountWhereClause : accountWhereClause = ""

    '### If extended credit document search, filter out account results ###
    IF searchDocumentFilter <> "" THEN
        IF searchDocumentFilter = "C" THEN
			' test credit extend filters to see if it returns accounts
            accountWhereClause = " WHERE 1 = 2"
        END IF
    END IF

    Dim creditSql : creditSql = _
        BuildCreditSelectClause() & _
        BuildCreditFromClause(true)

    Dim accountSql : accountSql = _
        BuildAccountSelectClause() & _
        BuildAccountFromClause(true) & _
        accountWhereClause

    Dim sql : sql = _
        " SELECT " & maxResultClause & " * " & _
        " FROM (" & _
        creditSql & _
        " UNION " & _
        accountSql & _
        " ) AS v" & _
        " ORDER BY" & _
        "   customerName," & _
        "   customerNumber," & _
        "   accountClassSortOrder," & _
        "   CASE WHEN isCollateralYN = 'Y' THEN" & _
        "           LEFT(loanNumber, (LEN(loanNumber)-CHARINDEX('_', REVERSE(loanNumber))))" & _
        "       ELSE" & _
        "           loanNumber" & _
        "   END," & _
        "   collateralSequence"

    BuildSearchQuery = sql
END FUNCTION

FUNCTION BuildLoanQuery()
    Dim sql : sql = _
        " SELECT DISTINCT c.customerNumber, l.loanNumber" & _
        " FROM" & _
        "   customer AS c INNER JOIN loan AS l" & _
        "       ON c.customerId = l.customerId" & _
        "       AND l.isCollateralYN = 'N'" & _
        "   INNER JOIN #tmpAccount AS ta ON l.loanId = ta.loanId " & _
        "   INNER JOIN loanType AS lt" & _
        "       ON lt.loanTypeId = l.loanTypeId" & _
        "   INNER JOIN accountClass AS ac" & _
        "       ON ac.accountClassId = lt.accountClassId"

    Dim whereClause : whereClause = ""
    IF searchDocumentFilter = "C" THEN
        whereClause = " WHERE 1 = 2"
    END IF

    BuildLoanQuery = (sql & whereClause)
END FUNCTION

'### The following functions are responsible for build the SELECT clause for the search results ###

FUNCTION BuildCreditSelectClause()
    Dim clause : clause = _
        " SELECT" & _
        "   c.customerId," & _
        "   c.customerName," & _
        "   c.businessName," & _
        "   c.customerNumber," & _
        "   c.taxId," & _
        "   c.employee," & _
        "   c.ignoreExceptionsYN AS ignoreCreditExceptionsYN," & _
        "   NULL AS loanId," & _
        "   NULL AS loanStatusId," & _
        "   NULL AS isActiveStatus," & _
        "   NULL AS isApplicationStatus," & _
        "   NULL AS isActiveApplicationStatus," & _
        "   NULL AS loanNumber," & _
        "   NULL AS loanDescription," & _
        "   NULL AS isCollateralYN," & _
        "   NULL AS isCrossCollateralYN," & _
        "   NULL AS ignoreAccountExceptionsYN," & _
        "   NULL AS statusDescription," & _
        "   'credit' AS accountClassCode," & _
        "   0 AS accountClassSortOrder," & _
        "   NULL AS accountClassId," & _
        "   NULL AS parentLoanId," & _
        "   -1 AS collateralSequence," &_
        "   NULL AS isParticipationLoan "
    clause = clause & BuildCustomCreditFieldSelect("credit")
    clause = clause & BuildCustomAccountFieldSelect("credit")
    clause = clause & BuildcustomCollateralFieldSelect("credit")

    BuildCreditSelectClause = clause
END FUNCTION

FUNCTION BuildAccountSelectClause()
    Dim clause : clause = _
        " SELECT" & _
        "   c.customerId," & _
        "   c.customerName," & _
        "   c.businessName," & _
        "   c.customerNumber," & _
        "   c.taxId," & _
        "   c.employee," & _
        "   c.ignoreExceptionsYN AS ignoreCreditExceptionsYN," & _
        "   l.loanId," & _
        "   l.loanStatusId," & _
        "   ls.isActive AS isActiveStatus," & _
        "   ls.isApplicationStatus," & _
        "   ls.isActiveApplicationStatus," & _
        "   l.loanNumber," & _
        "   l.loanDescription," & _
        "   l.isCollateralYN," & _
        "   l.isCrossCollateralYN," & _
        "   l.ignoreExceptionsYN AS ignoreAccountExceptionsYN," & _
        "   IsNull(ls.statusDescription, '') AS statusDescription," & _
        "   CASE" & _
        "       WHEN ls.isApplicationStatus = 1 THEN" & _
        "           'loanapp'" & _
        "       ELSE" & _
        "           ac.accountClassCode" & _
        "       END accountClassCode," & _
        "   ac.accountClassSortOrder," & _
        "   ac.accountClassId," & _
        "   CASE" & _
        "       WHEN l.isCollateralYN = 'N' THEN" & _
        "           NULL" & _
        "       ELSE" & _
        "           cref2.parentLoanId" & _
        "       END AS parentLoanId," & _
        "   CASE" & _
        "       WHEN l.isCollateralYN = 'N' THEN -1" & _
        "       ELSE cref2.collateralSequence" & _
        "   END AS collateralSequence," & _
        "   l.isParticipationLoan "
    clause = clause & BuildCustomCreditFieldSelect("account")
    clause = clause & BuildCustomAccountFieldSelect("account")
    clause = clause & BuildcustomCollateralFieldSelect("account")

    BuildAccountSelectClause = clause
END FUNCTION

' ### The following are the functions for dynamically joining on the custom fields defined if the user selects them for viewing ###
FUNCTION BuildCustomCreditFieldSelect(typeCode)
    Dim i, fieldDefName, fieldDefLabel, fieldDefDataType, fieldValue
    Dim str : str = ""
    Dim strLabel : strLabel = ""
    Dim selectClause : selectClause = ""
    Dim strType : strType = ""
    Dim alias : alias = ""
    IF typeCode = "account" THEN 
         alias = " NULL AS "
    END IF

    FOR i = 0 TO g_creditFieldDefCount - 1
        fieldDefName = g_creditFieldDefList(FIELD_DEF_NAME, i)
        fieldDefLabel = g_creditFieldDefList(FIELD_DEF_LABEL, i)
        fieldDefDataType = g_creditFieldDefList(FIELD_DEF_DATA_TYPE, i)
        fieldValue = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_cred_" & fieldDefName)

        IF fieldValue = "1" THEN
            selectClause = selectClause & "," & alias & fieldDefName
            ' ### The following is used in searchresults.asp and and saved to session. ###
            str = str & "," & fieldDefName
            strLabel = strLabel & "," & fieldDefLabel
            strType = strType & "," & fieldDefDataType
        END IF
    NEXT

    ' ### Store the field list into Session for retrieval in search results ###
    IF Trim(str & "") <> "" THEN
        Session("searchResults.customCreditFields") = Right(str, Len(str)-1)
        Session("searchResults.customCreditFieldLabels") = Right(strLabel, Len(strLabel)-1)
        Session("searchResults.customCreditFieldTypes") = Right(strType, Len(strType)-1)
    END IF

    BuildCustomCreditFieldSelect = selectClause
END FUNCTION

FUNCTION BuildCustomAccountFieldSelect(typeCode)
    Dim i, fieldDefName, fieldDefLabel, fieldDefDataType, fieldValue
    Dim str : str = ""
    Dim strLabel : strLabel = ""
    Dim selectClause : selectClause = ""
    Dim strType : strType = ""

    Dim alias : alias = ""
    IF typeCode = "credit" THEN 
         alias = " NULL AS "
    END IF

    FOR i = 0 TO g_accountFieldDefCount - 1
        fieldDefName = g_accountFieldDefList(FIELD_DEF_NAME, i)
        fieldDefLabel = g_accountFieldDefList(FIELD_DEF_LABEL, i)
        fieldDefDataType = g_accountFieldDefList(FIELD_DEF_DATA_TYPE, i)
        fieldValue = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_act_" & fieldDefName)

        IF fieldValue = "1" THEN
            selectClause = selectClause & "," & alias & fieldDefName
            ' ### The following is used in searchresults.asp and and saved to session.
            str = str & "," & fieldDefName
            strLabel = strLabel & "," & fieldDefLabel
            strType = strType & "," & fieldDefDataType
        END IF
    NEXT

    ' ### Store the field list into Session for retrieval in search results ###
    IF str <> "" THEN
        Session("searchResults.customAccountFields") = Right(str, Len(str)-1)
        Session("searchResults.customAccountFieldLabels") = Right(strLabel, Len(strLabel)-1)
        Session("searchResults.customAccountFieldTypes") = Right(strType, Len(strType)-1)
    END IF

    BuildCustomAccountFieldSelect = selectClause
END FUNCTION

FUNCTION BuildcustomCollateralFieldSelect(typeCode)
    Dim i, fieldDefName, fieldDefLabel, fieldDefDataType, fieldDefIsCollateral, fieldValue
    Dim str : str = ""
    Dim strLabel : strLabel = ""
    Dim selectClause : selectClause = ""
    Dim strType : strType = ""

    Dim alias : alias = ""
    IF typeCode = "credit" THEN 
        alias = "NULL AS "
    END IF

    FOR i = 0 TO g_collateralFieldDefCount - 1
        fieldDefName = g_collateralFieldDefList(FIELD_DEF_NAME, i)
        fieldDefLabel = g_collateralFieldDefList(FIELD_DEF_LABEL, i)
        fieldDefDataType = g_collateralFieldDefList(FIELD_DEF_DATA_TYPE, i)
        fieldDefIsCollateral = g_collateralFieldDefList(FIELD_DEF_COLLATERAL, i)
        fieldValue = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_col_" & fieldDefName)

        IF fieldDefIsCollateral THEN
            IF fieldValue = "1" THEN
                selectClause = selectClause & "," & alias & fieldDefName
                ' the following is used in searchresults.asp and and saved to session.
                str = str & "," & fieldDefName
                strLabel = strLabel & "," & fieldDefLabel
                strType = strType & "," & fieldDefDataType
            END IF
        END IF
    NEXT

    ' ### Store the field list into Session for retrieval in search results ###
    IF str <> "" THEN
        Session("searchResults.customCollateralFields") = Right(str, Len(str)-1)
        Session("searchResults.customCollateralFieldLabels") = Right(strLabel, Len(strLabel)-1)
        Session("searchResults.customCollateralFieldTypes") = Right(strType, Len(strType)-1)
    END IF

    BuildcustomCollateralFieldSelect = selectClause
END FUNCTION

' ### The following functions are responsible for building the FROM clause for search results ###

FUNCTION BuildCreditFromClause(joinTempTable)
    IF joinTempTable THEN
        Dim tmpTable : tmpTable = "   INNER JOIN #tmpCustomer AS tc ON c.customerId = tc.customerId "
    END IF
    Dim clause : clause = _
        " FROM" & _
        "   customer AS c " & _
        tmpTable

    clause = clause & BuildBankSecurityFrom()
    clause = clause & BuildAccountClassSecurityFrom("credit")
    clause = clause & BuildCustomCreditFieldFrom()
    ' clause = clause & BuildCustomAccountFieldFrom()
    ' clause = clause & BuildCustomCollateralFieldFrom()
    BuildCreditFromClause = clause
END FUNCTION

FUNCTION BuildAccountFromClause(joinTempTable)
    IF joinTempTable THEN
        Dim tmpTable : tmpTable = "   INNER JOIN #tmpAccount AS ta ON ta.loanId = l.loanId "
    END IF
    Dim clause : clause = _
        " FROM" & _
        "   customer AS c " & _
        "   INNER JOIN loan AS l ON c.customerId = l.customerId " & _
        tmpTable & _
        "   INNER JOIN loanStatus AS ls ON ls.statusId = l.loanStatusId " & _
        "   INNER JOIN accountClass AS ac ON ac.accountClassId = ls.accountClassId " & _
        "   LEFT OUTER JOIN collateral AS cref1 ON cref1.parentLoanId = l.loanId " & _
        "   LEFT OUTER JOIN loan AS cc ON cc.loanId = cref1.collateralLoanId " & _
        "   LEFT OUTER JOIN collateral AS cref2 ON cref2.collateralLoanId = l.loanId "
    clause = clause & BuildBankSecurityFrom()
    clause = clause & BuildAccountClassSecurityFrom("account")
    clause = clause & BuildCustomCreditFieldFrom()
    clause = clause & BuildCustomAccountFieldFrom()
    clause = clause & BuildCustomCollateralFieldFrom()
    clause = clause & BuildLoanAppFieldFrom()

    BuildAccountFromClause = clause
END FUNCTION

' Security filters
'   The following are filters for ensure proper user access. They should be included in any FROM clause being built
'   so the proper security rules can be applied.
'   The filters listed below:
'       BuildBankSecurityFrom()             - Security for bank access (multi-bank primarily)
'       BuildAccountClassSecurityFrom()     - Security for AccountClass access (credit.isReader, etc.)
'

' ### This filter is to make sure that the user has been given access to the bank to be able to view the 
' to be able to view the view the customer. This filters is primarily for multi-bank. ###
FUNCTION BuildBankSecurityFrom()
    Dim str : str = ""

    IF NOT Session("isSuperUser") THEN
        str = _
            " INNER JOIN userbanksecurity AS ubs" & _
            "   ON ubs.bankId = c.bankId" & _
            "   AND ubs.userId = " & dbFormatId(Session("userId")) & _
            "   AND ubs.bankaccess = 1"
    END IF

    ' NOTE: Since multi-bank is not fully implmented, always return an empty string for now
    str = ""
    BuildBankSecurityFrom = str
END FUNCTION

' BuildAccountClassSecurityFrom
' Ensures the user has proper AccountClass access (at least Read access).
FUNCTION BuildAccountClassSecurityFrom(typeCode)
    Dim str : str = ""

    IF NOT Session("isSuperUser") THEN
        IF typeCode = "credit" THEN
            str = _
                "   INNER JOIN userAccountSecurity AS uas" & _
                "       ON uas.userId = " & dbFormatId(Session("userId")) & _
                "       AND uas.allowRead = 1" & _
                "       AND uas.accountClassCode = 'credit'"
        ELSE
            str = _
                "   INNER JOIN userAccountSecurity AS uas" & _
                "       ON uas.userId = " & dbFormatId(Session("userId")) & _
                "       AND uas.allowRead = 1" & _
                "       AND (" & _
                "           uas.accountClassCode = (" & _
                "               CASE " & _
                "                   WHEN ac.accountClassCode = 'loan' AND isApplicationStatus = 1 THEN" & _
                "                       'loanApp'" & _
                "                   ELSE" & _
                "                       ac.accountClassCode" & _
                "               END" & _
                "           )" & _
                "       )"
            END IF
        END IF 
        BuildAccountClassSecurityFrom = str
END FUNCTION

FUNCTION BuildCustomCreditFieldFrom()
    Dim i, fieldDefName, fieldValue
    Dim str : str = ""

    FOR i = 0 TO g_creditFieldDefCount - 1
        fieldDefName = g_creditFieldDefList(FIELD_DEF_NAME, i)
        fieldValue = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_cred_" & fieldDefName)
        IF fieldValue = "1" THEN
            str = _
                " LEFT OUTER JOIN customerFields AS cf" & _
                "   ON cf.customerId = c.customerId"
            EXIT FOR
        END IF
    NEXT
    BuildCustomCreditFieldFrom = str
END FUNCTION

FUNCTION BuildCustomAccountFieldFrom()
    Dim i, fieldDefName, fieldValue
    Dim str : str = ""

    FOR i = 0 TO g_accountFieldDefCount - 1
        fieldDefName = g_accountFieldDefList(FIELD_DEF_NAME, i)
        fieldValue = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_act_" & fieldDefName)
        IF fieldValue = "1" THEN
            str = _
                " LEFT OUTER JOIN loanFields AS lf" & _
                "   ON lf.loanId = l.loanId"
            exit for
        END IF
    NEXT
    BuildCustomAccountFieldFrom = str
END FUNCTION

FUNCTION BuildLoanAppFieldFrom()
    Dim str : str = ""
    IF hasAppSearchData THEN
        str = " INNER JOIN loanApplication la on l.loanId = la.loanId " & _
            " LEFT OUTER JOIN approval ON la.approvalId = approval.approvalId "
    END IF
    BuildLoanAppFieldFrom = str
END FUNCTION

FUNCTION BuildCustomCollateralFieldFrom()
    Dim i, fieldDefName, fieldValue
    Dim str : str = ""

    FOR i = 0 TO g_collateralFieldDefCount - 1
        fieldDefName = g_collateralFieldDefList(FIELD_DEF_NAME, i)
        fieldValue = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_col_" & fieldDefName)
        IF fieldValue = "1" THEN
            str = _
                " LEFT OUTER JOIN collateralFields AS clf" & _
                "   ON clf.collateralId = l.loanId"
            exit for
        END IF
    NEXT
    BuildCustomCollateralFieldFrom = str
END FUNCTION

'### Core Credit Field Filters ###
FUNCTION BuildCustomerNameFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    Dim formattedValue : formattedValue = "%" & ReplaceWildcards(value) & "%"
    BuildCustomerNameFilter = " AND (c.customerName LIKE " & dbFormatText(formattedValue) & " ESCAPE '^' OR c.businessName LIKE " & dbFormatText(formattedValue) & " ESCAPE '^')"
END FUNCTION

FUNCTION BuildCustomerNumberFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    Dim formattedValue : formattedValue = "%" & ReplaceWildcards(value) & "%"
    BuildCustomerNumberFilter = " AND (c.customerNumber LIKE " & dbFormatText(formattedValue) & " ESCAPE '^')"
END FUNCTION

FUNCTION BuildTaxIdFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    Dim formattedValue : formattedValue = "%" & ReplaceWildcards(value) & "%"
    BuildTaxIdFilter = " AND (c.taxId LIKE " & dbFormatText(formattedValue) & " ESCAPE '^')"
END FUNCTION

FUNCTION BuildCustomerStatusFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    BuildCustomerStatusFilter = " AND (c.customerStatusId = " & dbFormatId(value) & ")"
END FUNCTION

FUNCTION BuildCustomerTypeFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    BuildCustomerTypeFilter = " AND (c.customerTypeId = " & dbFormatId(value) & ")"
END FUNCTION

FUNCTION BuildCustomerOfficerFilter(value)
    Dim str : str = ""
    IF Trim(value) = "NULL" THEN
        hasCreditSearchData = True
        str = " AND (c.customerOfficerId IS NULL)"
    ELSEIF Trim(value) <> "" THEN
        hasCreditSearchData = True
        str = " AND (c.customerOfficerId = " & dbFormatId(value) & ")"
    END IF
    BuildCustomerOfficerFilter = str
END FUNCTION

FUNCTION BuildCustomerBranchFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    BuildCustomerBranchFilter = " AND (c.customerBranchId = " & dbFormatId(value) & ")"
END FUNCTION

FUNCTION BuildCreditClassificationFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasCreditSearchData = True
    BuildCreditClassificationFilter = " AND (c.classificationId = " & dbFormatId(value) & ")"
END FUNCTION

FUNCTION BuildCustomCreditFieldFilter()
    Dim i, itemClause, value1, value2
    Dim fieldDefName, fieldDefIsSearchable, fieldDefDataType, conductSearch
    Dim str : str = ""
    Dim searchClause : searchClause = ""

    FOR i = 0 TO g_creditFieldDefCount - 1
        fieldDefName = g_creditFieldDefList(FIELD_DEF_NAME, i)
        fieldDefIsSearchable = g_creditFieldDefList(FIELD_DEF_SEARCHABLE, i)
        fieldDefDataType = g_creditFieldDefList(FIELD_DEF_DATA_TYPE, i)

        IF fieldDefIsSearchable THEN
            IF fieldDefDataType = "datetime" _
                OR fieldDefDataType = "int" _
                OR fieldDefDataType = "decimal" _
                OR fieldDefDataType = "money" THEN
                value1 = requestOrSession("from_flex_" & fieldDefName, "from_flex_cred_" & fieldDefName)
                value2 = requestOrSession("to_flex_" & fieldDefName, "to_flex_cred_" & fieldDefName)
            ELSE
                value1 = requestOrSession("flex_" & fieldDefName, "flex_cred_" & fieldDefName)
            END IF

            conductSearch = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_cred_" & fieldDefName)
            IF conductSearch = "1" THEN itemClause = BuildCustomFieldClause( fieldDefName, fieldDefDataType, value1, value2)

            IF itemClause <> "" THEN
                IF searchClause = "" THEN
                    searchClause = itemClause
                ELSE
                    searchClause = searchClause & " AND " & itemClause
                END IF
            END IF
        END IF
    NEXT

    IF searchClause <> "" THEN
        str = _
        "   AND  c.customerId IN (" & _
        "       SELECT customerId" & _
        "       FROM customerFields" & _
        "       WHERE " & searchClause & _
        "   )"
    END IF
    'Response.Write str & "<br/><br/>"
    BuildCustomCreditFieldFilter = str
END FUNCTION

'### Account field filters ###
FUNCTION BuildAccountNumberFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    Dim formattedValue : formattedValue = "%" & ReplaceWildcards(value) & "%"
    BuildAccountNumberFilter = " AND (l.loanNumber LIKE " & dbFormatText(formattedValue) & " ESCAPE '^')"
END FUNCTION

FUNCTION BuildAccountDescriptionFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    Dim formattedValue : formattedValue = "%" & ReplaceWildcards(value) & "%"
    BuildAccountDescriptionFilter = " AND (l.loanDescription LIKE " & dbFormatText(formattedValue) & " ESCAPE '^')"
END FUNCTION

FUNCTION BuildAccountClassFilter(value, isCollateral)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    
    IF isCollateral THEN
        BuildAccountClassFilter = " AND (l.isCollateralYN='Y' AND ac.accountClassId = " & dbFormatId(value) & ")"
    ELSE
        BuildAccountClassFilter = " AND (l.isCollateralYN='N' AND ac.accountClassId = " & dbFormatId(value) & ")"
    END IF
END FUNCTION

FUNCTION BuildAccountTypeFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    BuildAccountTypeFilter = " AND  (l.loanTypeId = " & dbFormatId(value) & ")"
END FUNCTION

FUNCTION BuildAccountStatusFilter(value)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    BuildAccountStatusFilter = " AND (l.loanStatusId = " & dbFormatId(value) & ")"
END FUNCTION

FUNCTION BuildAccountOfficerFilter(value, isCollateral)
    Dim str : str = ""

    IF isCollateral THEN
        IF Trim(value) = "NULL" THEN
            hasLoanSearchData = True
            str = " AND (l.isCollateralYN='Y' AND pl.loanOfficerId IS NULL)"
        ELSEIF Trim(value) <> "" THEN
            hasLoanSearchData = True
            str = " AND (l.isCollateralYN='Y' AND pl.loanOfficerId = " & dbFormatId(value) & ")"
        END IF
    ELSE
        IF Trim(value) = "NULL" THEN
            hasLoanSearchData = True
            str = " AND (l.isCollateralYN='N' AND l.loanOfficerId IS NULL)"
        ELSEIF Trim(value) <> "" THEN
            hasLoanSearchData = True
            str = " AND (l.isCollateralYN='N' AND l.loanOfficerId = " & dbFormatId(value) & ")"
        END IF
    END IF


    BuildAccountOfficerFilter = str
END FUNCTION

FUNCTION BuildAccountOriginationDateFilter(fromDate, toDate, isCollateral)
    Dim str : str = ""
    Dim dateClause : dateClause = ""

    IF isCollateral THEN
        IF IsDate(fromDate) THEN dateClause = " (l.isCollateralYN = 'Y' AND pl.loanOrigDate >= " & dbFormatDate(fromDate) & ")"

        IF IsDate(toDate) THEN
            IF dateClause = "" THEN
                dateClause = "(l.isCollateralYN = 'Y' AND pl.loanOrigDate <= " & dbFormatDate(toDate) & ")"
            ELSE
                dateClause = dateClause & " AND (l.isCollateralYN = 'Y' AND pl.loanOrigDate <= " & dbFormatDate(toDate) & ")"
            END IF
        END IF
    ELSE
        IF IsDate(fromDate) THEN dateClause = " (l.isCollateralYN = 'N' AND l.loanOrigDate >= " & dbFormatDate(fromDate) & ")"

        IF IsDate(toDate) THEN
            IF dateClause = "" THEN
                dateClause = "(l.isCollateralYN = 'N' AND l.loanOrigDate <= " & dbFormatDate(toDate) & ")"
            ELSE
                dateClause = dateClause & " AND (l.isCollateralYN = 'N' AND l.loanOrigDate <= " & dbFormatDate(toDate) & ")"
            END IF
        END IF
    END IF

    IF Trim(dateClause & "") <> "" THEN
        hasLoanSearchData = True
        str = " AND (" & dateClause & ")"
    END IF

    BuildAccountOriginationDateFilter = str
END FUNCTION

FUNCTION BuildAccountParticipationFilter(value, isCollateral)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    IF isCollateral THEN
        BuildAccountParticipationFilter = " AND (l.isCollateralYN = 'Y' AND pl.isParticipationLoan = " & dbFormatBoolean(value) & ")"
    ELSE
        BuildAccountParticipationFilter = " AND (l.isCollateralYN = 'N' AND l.isParticipationLoan = " & dbFormatBoolean(value) & ")"
    END IF
END FUNCTION

FUNCTION BuildAccountBranchFilter(value, isCollateral)
    IF Trim(value & "") = "" THEN EXIT FUNCTION
    hasLoanSearchData = True
    IF isCollateral THEN
        BuildAccountBranchFilter = " AND (l.isCollateralYN = 'Y' AND pl.loanBranchId = " & dbFormatId(value) & ")"
    ELSE
        BuildAccountBranchFilter = " AND (l.isCollateralYN = 'N' AND l.loanBranchId = " & dbFormatId(value) & ")"
    END IF
END FUNCTION

FUNCTION BuildCustomAccountFieldFilter()
    Dim itemClause, i, value1, value2
    Dim fieldDefName, fieldDefIsSearchable, fieldDefDataType, conductSearch

    Dim str : str = ""
    Dim searchClause : searchClause = ""

    FOR i = 0 TO g_accountFieldDefCount - 1
        fieldDefName = g_accountFieldDefList(FIELD_DEF_NAME, i)
        fieldDefIsSearchable = g_accountFieldDefList(FIELD_DEF_SEARCHABLE, i)
        fieldDefDataType = g_accountFieldDefList(FIELD_DEF_DATA_TYPE, i)

        IF fieldDefIsSearchable THEN
            IF fieldDefDataType = "datetime" _
                OR fieldDefDataType = "int" _
                OR fieldDefDataType = "decimal" _
                OR fieldDefDataType = "money" THEN
                value1 = requestOrSession("from_flex_" & fieldDefName, "from_flex_act_" & fieldDefName)
                value2 = requestOrSession("to_flex_" & fieldDefName, "to_flex_act_" & fieldDefName)
            ELSE
                value1 = requestOrSession("flex_" & fieldDefName, "flex_act_" & fieldDefName)
            END IF

            conductSearch = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_act_" & fieldDefName)
            IF conductSearch = "1" THEN itemClause = BuildCustomFieldClause( fieldDefName, fieldDefDataType, value1, value2)

            IF itemClause <> "" THEN
                IF searchClause = "" THEN
                    searchClause = itemClause
                ELSE
                    searchClause = searchClause & " AND " & itemClause
                END IF
            END IF
        END IF
    NEXT

    IF Trim(searchClause & "") <> "" THEN
        hasLoanSearchData = True
        str = _
            " AND l.isCollateralYN = 'N' " & _
            " AND l.loanId IN (" & _
            "     SELECT loanId" & _
            "     FROM loanFields" & _
            "     WHERE " & searchClause & _
            " )"
    END IF

    BuildCustomAccountFieldFilter = str
END FUNCTION

FUNCTION BuildCustomCollateralFieldFilter()
    Dim itemClause, i, value1, value2
    Dim fieldDefName, fieldDefIsSearchable, fieldDefDataType, fieldDefIsCollateral, conductSearch
    Dim searchClause : searchClause = ""

    FOR i = 0 TO g_collateralFieldDefCount - 1
        fieldDefName = g_collateralFieldDefList(FIELD_DEF_NAME, i)
        fieldDefIsSearchable = g_collateralFieldDefList(FIELD_DEF_SEARCHABLE, i)
        fieldDefDataType = g_collateralFieldDefList(FIELD_DEF_DATA_TYPE, i)
        fieldDefIsCollateral = g_collateralFieldDefList(FIELD_DEF_COLLATERAL, i)

        IF fieldDefIsCollateral THEN
            IF fieldDefIsSearchable THEN
                IF fieldDefDataType = "datetime" _
                    OR fieldDefDataType = "int" _
                    OR fieldDefDataType = "decimal" _
                    OR fieldDefDataType = "money" THEN
                    value1 = requestOrSession("from_flex_" & fieldDefName, "from_flex_col_" & fieldDefName)
                    value2 = requestOrSession("to_flex_" & fieldDefName, "to_flex_col_" & fieldDefName)
                ELSE
                    value1 = requestOrSession("flex_" & fieldDefName, "flex_col_" & fieldDefName)
                END IF

                conductSearch = requestOrSession("chk_flex_" & fieldDefName, "chk_flex_col_" & fieldDefName)
                IF conductSearch = "1" THEN itemClause = BuildCustomFieldClause( fieldDefName, fieldDefDataType, value1, value2)

                IF itemClause <> "" THEN
                    IF searchClause = "" THEN
                        searchClause = itemClause
                    ELSE
                        searchClause = searchClause & " AND " & itemClause
                    END IF
                END IF
            END IF ' ### fieldDefIsSearchable
        END IF ' ### fieldDefIsCollateral
    NEXT ' ### i

    Dim str: str = ""
    IF Trim(searchClause & "") <> "" THEN
        hasLoanSearchData = True
        str = _
            " AND (" & _
            "       l.isCollateralYN = 'Y' " & _
            "       AND (" & _
            "           l.loanId IN (" & _
            "               SELECT collateralId" & _
            "               FROM collateralFields" & _
            "               WHERE " & searchClause & _
            "           )" & _
            "       )" & _
            " )"
    END IF

    BuildCustomCollateralFieldFilter = str
END FUNCTION

'### Application specific field filters ###
FUNCTION BuildApplicationDateFilter(inDataFrom, inDataTo)
    Dim str : str = ""
    IF Trim(inDataFrom & "") <> "" OR Trim(inDataTo & "") <> "" THEN
        Dim dateClause : dateClause = ""
        IF IsDate(inDataFrom) THEN dateClause = " (la.applicationDate >= " & dbFormatDate(inDataFrom) & ")"
        IF IsDate(inDataTo) THEN
            IF dateClause = "" THEN
                dateClause = "(la.applicationDate <= " & dbFormatDate(inDataTo) & ")"
            ELSE
                dateClause = dateClause & " AND (la.applicationDate <= " & dbFormatDate(inDataTo) & ")"
            END IF
        END IF

        IF dateClause <> "" THEN 
            str = " AND (" & dateClause & ") AND ls.isApplicationStatus = 1 "
            hasAppSearchData = True
        END IF
    END IF
    BuildApplicationDateFilter = str
END FUNCTION

FUNCTION BuildApplicationLenderFilter(inData)
    IF Trim(inData & "") = "" THEN EXIT FUNCTION
    Dim paryLender : paryLender = Split(inData, ":")
    Dim strLenderType : strLenderType = paryLender(0)
    Dim guidLenderId : guidLenderId = paryLender(1)
    hasAppSearchData = True
    ' ### The assignee type (user or group) is not needed for processing as the assignedLenderId can be a group or user id.
    BuildApplicationLenderFilter = " AND (la.assignedLenderId = " & dbFormatId(guidLenderId) & " AND ls.isApplicationStatus = 1)"
END FUNCTION

FUNCTION BuildApplicationDelegateFilter(inData)
    IF Trim(inData & "") = "" THEN EXIT FUNCTION
    Dim paryDelegate : paryDelegate = Split(inData, ":")
    Dim strDelegateType : strDelegateType = paryDelegate(0)
    Dim guidDelegateId : guidDelegateId = paryDelegate(1)
    hasAppSearchData = True
    ' ### The assignee type (user or group) is not needed for processing as the assignedLoanProcessorId can be a group or user id.
    BuildApplicationDelegateFilter = " AND (la.assignedLoanProcessorId = " & dbFormatId(guidDelegateId) & " AND ls.isApplicationStatus = 1)"
END FUNCTION

FUNCTION BuildApplicationAnalystFilter(inData)
    IF Trim(inData & "") = "" THEN EXIT FUNCTION
    Dim paryAnalyst : paryAnalyst = Split(inData, ":")
    Dim strAnalystType : strAnalystType = paryAnalyst(0)
    Dim guidAnalystId : guidAnalystId = paryAnalyst(1)
    hasAppSearchData = True
    ' ### The assignee type (user or group) is not needed for processing as the assignedAnalystId can be a group or user id.
    BuildApplicationAnalystFilter = " AND (la.assignedAnalystId = " & dbFormatId(guidAnalystId) & " AND ls.isApplicationStatus = 1)"
END FUNCTION

FUNCTION BuildApplicationApprovalStatusFilter(inData)
    IF Trim(inData & "") = "" THEN EXIT FUNCTION
    hasAppSearchData = True
    BuildApplicationApprovalStatusFilter = " AND (approval.approvalStatusId = " & dbFormatId(inData) & " AND ls.isApplicationStatus = 1) "
END FUNCTION

FUNCTION BuildApplicationLoanStatusFilter(inData)
    IF Trim(inData & "") = "" THEN EXIT FUNCTION
    hasAppSearchData = True
    BuildApplicationLoanStatusFilter = " AND (l.loanStatusId = " & dbFormatId(inData) & " AND ls.isApplicationStatus = 1) "
END FUNCTION

FUNCTION BuildApplicationApproverFilter(inData)
    IF Trim(inData & "") = "" THEN EXIT FUNCTION
    Dim paryApprover : paryApprover = Split(inData, ":")
    Dim strApproverType : strApproverType = paryApprover(0)
    Dim guidApproverId : guidApproverId = paryApprover(1)
    hasAppSearchData = True
    ' ### The assignee type (user or group) is not needed for processing as the assignedApproverId can be a group or user id.
    BuildApplicationApproverFilter = " AND (approval.assignedApproverId = " & dbFormatId(guidApproverId) & " AND ls.isApplicationStatus = 1) "
END FUNCTION

'### Extended Search Functions ###
FUNCTION BuildExtendedSearchFilterFromClause(typeCode)
    Dim fromClause : fromClause = ""
    IF lCase(searchType) = "missing" OR lCase(searchType) = "existing" OR lCase(searchType) = "expired" OR lCase(searchType) = "waived" THEN
        IF typeCode = "credit" THEN
            fromClause = _
                " INNER JOIN documentDefinitions AS dd" & _
                "   ON dd.customerTypeId = c.customerTypeId" & _
                " LEFT OUTER JOIN document AS d" & _
                "   ON d.customerId = c.customerId" & _
                "   AND d.documentDefId = dd.documentDefId" & _
                " LEFT OUTER JOIN documentActivation AS da" & _
                "   ON da.customerId = c.customerId" & _
                "   AND da.loanId IS NULL" & _
                "   AND da.documentTypeId = dd.documentTypeId"
        ELSE
            fromClause = _
                " INNER JOIN documentDefinitions AS dd" & _
                "   ON dd.loanTypeId = l.loanTypeId" & _
                " LEFT OUTER JOIN document AS d" & _
                "   ON d.loanId = l.loanId" & _
                "   AND d.documentDefId = dd.documentDefId" & _
                " LEFT OUTER JOIN documentActivation AS da" & _
                "   ON da.customerId = l.customerId" & _
                "   AND da.loanId = l.loanId" & _
                "   AND da.documentTypeId = dd.documentTypeId"
        END IF
    ELSEIF lCase(searchType) = "exception" THEN
        IF typeCode = "credit" THEN
            fromClause = _
                " INNER JOIN exception AS ex" & _
                "   ON ex.customerId = c.customerId" & _
                "   AND ex.loanId IS NULL" & _
                "   AND c.ignoreExceptionsYN = 'N'" & _
                " INNER JOIN exceptionDefinition AS ed" & _
                "   ON ed.exceptionDefId = ex.exceptionDefId" & _
                " INNER JOIN exceptedDocument AS exdoc" & _
                "   ON exdoc.exceptionId = ex.exceptionId"
        ELSE
            fromClause = _
                " INNER JOIN exception AS ex" & _
                "   ON ex.customerId = l.customerId" & _
                "   AND ex.loanId = l.loanId" & _
                "   AND l.ignoreExceptionsYN = 'N'" & _
                " INNER JOIN exceptionDefinition AS ed" & _
                "   ON ed.exceptionDefId = ex.exceptionDefId" & _
                " INNER JOIN exceptedDocument AS exdoc" & _
                "   ON exdoc.exceptionId = ex.exceptionId"
        END IF
    END IF
    BuildExtendedSearchFilterFromClause = fromClause
END FUNCTION

FUNCTION BuildExtendedSearchFilterWhereClause(typeCode)
    Dim extendedClause : extendedClause = ""
    IF lCase(searchType) = "missing" THEN
        extendedClause = BuildMissingDocumentFilter()
    ELSEIF lCase(searchType) = "existing" THEN
        extendedClause = BuildExistingDocumentFilter()
    ELSEIF lCase(searchType) = "expired" THEN
        extendedClause = BuildExpiredDocumentFilter()
    ELSEIF lCase(searchType) = "waived" THEN
        extendedClause = BuildWaivedDocumentFilter()
    ELSEIF lCase(searchType) = "exception" THEN
        extendedClause = BuildExceptionFilter(typeCode)
    END IF
    BuildExtendedSearchFilterWhereClause = extendedClause
END FUNCTION

FUNCTION BuildMissingDocumentFilter()
    Dim accountClassCodeList : Set accountClassCodeList = Request("accountClassCode")
    Dim documentSubTypeIdList : documentSubTypeIdList = ""
    Dim chkTab, i, j

    FOR i = 1 TO accountClassCodeList.Count
        Set chkTab = Request("chkTab_" & accountClassCodeList(i))
        FOR j = 1 TO chkTab.Count
            IF NOT InStr(documentSubTypeIdList, chkTab(j)) THEN
                IF documentSubTypeIdList = "" THEN
                    documentSubTypeIdList = dbFormatId(chkTab(j))
                ELSE
                    documentSubTypeIdList = documentSubtypeIdList & "," & dbFormatId(chkTab(j))
                END IF
            END IF
        NEXT
    NEXT

    IF documentSubTypeIdList <> "" THEN
        documentSubTypeIdList = " AND dd.documentSubTypeId IN (" & documentSubTypeIdList & ")"
    END IF

    Dim extendedCondition : extendedCondition = _
        " AND IsNull(d.documentStatus, 2) = 2 AND dd.hideTabYN <> 'Y'" & _
        " AND IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) = 1" & _
        " AND IsNull(da.activationStatus, dd.defaultActivationStatus) = 'on'" & _
        documentSubTypeIdList

    BuildMissingDocumentFilter = extendedCondition
END FUNCTION

FUNCTION BuildExistingDocumentFilter()
    Dim accountClassCodeList : Set accountClassCodeList = Request("accountClassCode")
    Dim documentSubTypeIdList : documentSubTypeIdList = ""
    Dim chkTab, i, j

    FOR i = 1 TO accountClassCodeList.Count
        Set chkTab = Request("chkTab_" & accountClassCodeList(i))
        FOR j = 1 TO chkTab.Count
            IF NOT InStr(documentSubTypeIdList, chkTab(j)) THEN
                IF documentSubTypeIdList = "" THEN
                    documentSubTypeIdList = dbFormatId(chkTab(j))
                ELSE
                    documentSubTypeIdList = documentSubtypeIdList & "," & dbFormatId(chkTab(j))
                END IF
            END IF
        NEXT
    NEXT

    IF documentSubTypeIdList <> "" THEN
        documentSubTypeIdList = " AND dd.documentSubTypeId IN (" & documentSubTypeIdList & ")"
    END IF

    Dim extendedCondition : extendedCondition = _
        " AND IsNull(d.documentStatus, 2) = 1 AND dd.hideTabYN <> 'Y'" & _
        " AND IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) = 1" & _
        " AND IsNull(da.activationStatus, dd.defaultActivationStatus) = 'on'" & _
        documentSubTypeIdList

    BuildExistingDocumentFilter = extendedCondition
END FUNCTION

FUNCTION BuildWaivedDocumentFilter()
    Dim accountClassCodeList : Set accountClassCodeList = Request("accountClassCode")
    Dim documentSubTypeIdList : documentSubTypeIdList = ""
    Dim chkTab, i, j

    FOR i = 1 TO accountClassCodeList.Count
        Set chkTab = Request("chkTab_" & accountClassCodeList(i))
        FOR j = 1 TO chkTab.Count
            IF NOT InStr(documentSubTypeIdList, chkTab(j)) THEN
                IF documentSubTypeIdList = "" THEN
                    documentSubTypeIdList = dbFormatId(chkTab(j))
                ELSE
                    documentSubTypeIdList = documentSubtypeIdList & "," & dbFormatId(chkTab(j))
                END IF
            END IF
        NEXT
    NEXT

    IF documentSubTypeIdList <> "" THEN
        documentSubTypeIdList = " AND dd.documentSubTypeId IN (" & documentSubTypeIdList & ")"
    END IF

    Dim extendedCondition : extendedCondition = _
        " AND IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) = 3 AND dd.hideTabYN <> 'Y'" & _
        " AND IsNull(da.activationStatus, dd.defaultActivationStatus) = 'on'" & _
        documentSubTypeIdList

    BuildWaivedDocumentFilter = extendedCondition
END FUNCTION

FUNCTION BuildExpiredDocumentFilter()
    Dim accountClassCodeList : Set accountClassCodeList = Request("accountClassCode")
    Dim documentExpDate, documentSubTypeId
    Dim chkTab, i, j

    Dim dateClause  : dateClause = ""
    FOR i = 1 TO accountClassCodeList.Count
        Set documentSubTypeId = Request("documentSubTypeId_" & accountClassCodeList(i))
        FOR j = 1 TO documentSubTypeId.Count
            documentExpDate = Request("documentExpDate_" & accountClassCodeList(i) & "_" & j)

            IF IsDate(documentExpDate) THEN
                IF dateClause = "" THEN
                    dateClause = _
                        " (" & _
                        "   dd.documentSubTypeId = " & dbFormatId(documentSubTypeId(j)) & _
                        "   AND IsNull(d.nonExpiring, 0) = 0" & _
                        "   AND (CASE WHEN d.documentId IS NOT NULL THEN d.expDate ELSE dd.defaultExpDate END) <= " & dbFormatDate(documentExpDate) & _
                        " )"
                ELSE
                    dateClause = dateClause & _
                        " OR (" & _
                        "   dd.documentSubTypeId = " & dbFormatId(documentSubTypeId(j)) & _
                        "   AND IsNull(d.nonExpiring, 0) = 0" & _
                        "   AND (CASE WHEN d.documentId IS NOT NULL THEN d.expDate ELSE dd.defaultExpDate END) <= " & dbFormatDate(documentExpDate) & _
                        " )"
                END IF
            END IF
        NEXT
    NEXT

    Dim extendedCondition : extendedCondition = ""
    IF dateClause <> "" THEN
        dateClause = " AND (" & dateClause & ")"

        extendedCondition = _
            " AND IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) = 1 AND dd.hideTabYN <> 'Y'" & _
            " AND IsNull(da.activationStatus, dd.defaultActivationStatus) = 'on'" & _
            dateClause
    END IF

    BuildExpiredDocumentFilter = extendedCondition
END FUNCTION

FUNCTION BuildExceptionFilter(typeCode)
    Dim chkAssignedUserId : Set chkAssignedUserId = Request("chkAssignedUserId")
    Dim chkCustomerExceptionDefId : Set chkCustomerExceptionDefId = Request("chkCustomerExceptionDefId")
    Dim chkLoanExceptionDefId : Set chkLoanExceptionDefId = Request("chkLoanExceptionDefId")
    Dim chkDepositExceptionDefId : Set chkDepositExceptionDefId = Request("chkDepositExceptionDefId")
    Dim chkTrustExceptionDefId : Set chkTrustExceptionDefId = Request("chkTrustExceptionDefId")
    Dim exceptionFilter : exceptionFilter = ""
    Dim extendedCondition : extendedCondition = ""
    Dim assignedUserIdList : assignedUserIdList = ""
    Dim exceptionDefIdList : exceptionDefIdList = ""
    Dim i

    ' ### Build assigned user clause ###
    FOR i = 1 TO chkAssignedUserId.Count
        IF assignedUserIdList = "" THEN
            assignedUserIdList = dbFormatId(chkAssignedUserId(i))
        ELSE
            assignedUserIdList = assignedUserIdList & ", " & dbFormatId(chkAssignedUserId(i))
        END IF
    NEXT

    IF assignedUserIdList <> "" AND extendedCondition = "" THEN
        IF searchDocumentFilter = "C" THEN
            IF typeCode = "account" THEN
                extendedCondition = " 1 = 2 "
            ELSE
                extendedCondition = " (ex.assignedUserId IN ( " & assignedUserIdList & "))"
            END IF
        ELSE
            IF typeCode = "credit" THEN
                extendedCondition = " 1 = 2 "
            ELSE
                extendedCondition = " (ex.assignedUserId IN ( " & assignedUserIdList & "))"
            END IF
        END IF
    END IF

    ' ### Build list of exceptionDefIds ###
    IF searchDocumentFilter = "C" THEN
        FOR i = 1 TO chkCustomerExceptionDefId.Count
            IF exceptionDefIdList = "" THEN
                exceptionDefIdList = dbFormatId(chkCustomerExceptionDefId(i))
            ELSE
                exceptionDefIdList = exceptionDefIdList & ", " & dbFormatId(chkCustomerExceptionDefId(i))
            END IF
        NEXT
    ELSE
        FOR i = 1 TO chkLoanExceptionDefId.count
            IF exceptionDefIdList = "" THEN
                exceptionDefIdList = dbFormatId(chkLoanExceptionDefId(i))
            ELSE
                exceptionDefIdList = exceptionDefIdList & ", " & dbFormatId(chkLoanExceptionDefId(i))
            END IF
        NEXT
        FOR i = 1 TO chkDepositExceptionDefId.count
            IF exceptionDefIdList = "" THEN
                exceptionDefIdList = dbFormatId(chkDepositExceptionDefId(i))
            ELSE
                exceptionDefIdList = exceptionDefIdList & ", " & dbFormatId(chkDepositExceptionDefId(i))
            END IF
        NEXT
        FOR i = 1 TO chkTrustExceptionDefId.count
            IF exceptionDefIdList = "" THEN
                exceptionDefIdList = dbFormatId(chkTrustExceptionDefId(i))
            ELSE
                exceptionDefIdList = exceptionDefIdList & ", " & dbFormatId(chkTrustExceptionDefId(i))
            END IF
        NEXT
    END IF

    '### Build extended condtion of selected exceptions ###
    IF Trim(exceptionDefIdList & "") <> "" THEN
        IF Trim(extendedCondition & "") = "" THEN
            extendedCondition = " (ex.exceptionDefId IN ( " & exceptionDefIdList & "))"
        ELSE 
            extendedCondition = " (" & extendedCondition & " AND (ex.exceptionDefId IN ( " & exceptionDefIdList & ")))"
        END IF
    END IF

    IF Trim(extendedCondition & "") <> "" THEN
         extendedCondition = " AND " & extendedCondition
    END IF
    'Response.Write "extended condition <BR>" & extendedCondition & "<BR><BR>"
    BuildExceptionFilter = extendedCondition
END FUNCTION 'BuildExceptionFilter()

'### Branch security filters ###
FUNCTION BuildBranchSecurityFilter(typeCode)
    Dim str : str = ""
    Dim branchList

    ' ### Check for branch security settings being enabled or the user is a super-user ###
    IF (Session("UseBranchSecurity") = "Y" AND Session("bankSecurity") = "DU") And Not Session("isSuperUser") THEN
        branchList = BuildAccessibleBranchList()

        ' ### Special check for when user has no access to branches, for the SQL statement to be false. ###
        IF branchList = "" THEN 
            str = " AND 1 = 2"
        ELSEIF typeCode = "credit" THEN
            str = " AND (c.customerBranchId IN (" & branchList & "))"
        ELSEIF typeCode = "account" THEN
            str = " AND (l.loanBranchId IN (" & branchLIst & "))"
        END IF
    END If
    BuildBranchSecurityFilter = str
END FUNCTION

FUNCTION BuildAccessibleBranchList()
    Dim branchList : branchList = ""
    Dim sqlRS : Set sqlRS = Server.CreateObject("ADODB.RecordSet")
    Dim sql : sql = _
        " SELECT " & _
        "    u.userId," & _
        "    ubs.branchId" & _
        " FROM" & _
        "    [user] AS u INNER JOIN userBranchSecurity AS ubs" & _
        "        ON u.userId = ubs.userId" & _
        " WHERE" & _
        "    u.userId = " & dbFormatId(Session("userId"))
    sqlRS.Open sql, db, adOpenStatic, adCmdText
    DO UNTIL sqlRS.eof
        IF branchList = "" THEN
            branchList = dbFormatId(sqlRS("branchId"))
        ELSE
            branchList = branchList & ", " & dbFormatId(sqlRS("branchId"))
        END IF
        sqlRS.MoveNext
    LOOP
    sqlRS.Close
    BuildAccessibleBranchList = branchList
END FUNCTION

FUNCTION BuildCustomFieldClause(fieldName, fieldType, val1, val2)
    Dim clause : clause = ""
    IF fieldType = "datetime" THEN
        IF Trim(val1 & "") <> "" THEN
            clause = fieldName & " >= " & dbFormatDate(val1)
        END IF
        IF Trim(val2 & "") <> "" AND Trim(clause & "") <> "" THEN
            clause = clause & " AND " & fieldName & " <= " & dbFormatDate(val2)
        ELSEIF Trim(val2 & "") <> "" THEN
            clause = fieldName & "<=" & dbFormatDate(val2)
        END IF
        IF clause <> "" THEN clause = "(" & clause & ")"
    ELSEIF fieldType = "int" OR fieldType = "decimal" THEN
        IF Trim(val1 & "") <> "" THEN
            clause = fieldName & " >= " & val1
        END IF
        IF Trim(val2 & "") <> "" AND Trim(clause & "") <> "" THEN
            clause = clause & " AND " & fieldName & " <= " & val2
        ELSEIF Trim(val2 & "") <> "" THEN
            clause = fieldName & " <= " & val2
        END IF
        IF clause <> "" THEN clause = "(" & clause & ")"
    ELSEIF fieldType = "money" THEN
        IF Trim(val1 & "") <> "" THEN
            clause = fieldName & " >= " & dbFormatText(val1)
        END IF
        IF Trim(val2 & "") <> "" AND Trim(clause & "") <> "" THEN
            clause = clause & " AND " & fieldName & " <= " & dbFormatText(val2)
        ELSEIF Trim(val2 & "") <> "" THEN
            clause = fieldName & " <= " & val2
        END IF
        IF clause <> "" THEN clause = "(" & clause & ")"
    ELSEIF fieldType = "boolean" THEN
        IF Trim(val1 & "") <> "" THEN
            clause = fieldName & " = " & val1
        END IF
    ELSEIF fieldType = "choice" THEN
        IF InStr(Trim(val1 & ""), "||") > 0 THEN
            Dim valueAry : valueAry = ""
            Dim fullChoiceList : fullChoiceList = ""
            valueAry = Split(Trim(val1 & ""), "||")
            Dim k : FOR k = lBound(valueAry) TO uBound(valueAry)
                fullChoiceList = fullChoiceList & "'" & valueAry(k) & "', "
            NEXT
            fullChoiceList = Left(fullChoiceList, Len(fullChoiceList) - 2)
            clause = "(" & fieldName & " IN (" & fullChoiceList & "))"
        ELSEIF Trim(val1 & "") <> "" THEN
            clause = "(" & fieldName & " = " & dbFormatText(val1) & ")"
        END IF
    ELSE
        IF val1 <> "" THEN
            clause = "(" & fieldName & " LIKE " & dbFormatText("%" & val1 & "%") & ")"
        END IF
    END IF

    '### Add check for active field status if clause is built ###
    IF clause <> "" THEN
        clause = "(" & clause & " AND (" & fieldName & "_isActive = 1))"
    END IF

    BuildCustomFieldClause = clause
END FUNCTION

FUNCTION ReplaceWildcards(str)
    IF Trim(str & "") = "" THEN EXIT FUNCTION
    Dim strResult : strResult = Replace(str, "_", "^_")
    replaceWildcards = Replace(strResult, "%", "^%")
END FUNCTION

FUNCTION GetRecordCount(tableName)
    Dim rs : rs = db.Execute("SELECT COUNT(*) FROM " & tableName)
    GetRecordCount = rs(0).value
END FUNCTION

%>