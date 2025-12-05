<%
    collateralBlockTimeStart = Timer()
%>
<%
strUrl = "customer.asp?"

filterMsg = ""
key = "selected" & selectedAccountClassCode & "CollateralStatusFilter"

selectedCollateralStatusFilter = GetUserViewStatusFilter(key)
IF selectedCollateralStatusFilter <> "all" THEN
    filterMsg = "Collateral Status Filter is On"
END IF

collateralStatusClause = ""
IF selectedCollateralStatusFilter = "all" _
    OR selectedCollateralStatusFilter = "none" _
    OR selectedCollateralStatusFilter = "" THEN
    collateralStatusClause = ""
ELSE
    ' ### Parse filter for status ids to filter on. Seperator is the colon ':' character ###
    str = selectedCollateralStatusFilter
    startIndex = 1
    DO
        endIndex = InStr(str, ":")
        IF endIndex > 0 THEN
            statusId = Left(str, endIndex-1)
            str = Replace(str, statusId & ":", "")
        ELSE
            statusId = str
            str = ""
        END IF

        IF collateralStatusClause = "" THEN
            collateralStatusClause = "(loanStatusId=" & dbFormatId(statusId) & ")"
        ELSE
            collateralStatusClause = collateralStatusClause & " OR (loanStatusId = " & dbFormatId(statusId) & ")"
        END IF

        startIndex = endIndex
    LOOP WHILE(str <> "")
    collateralStatusClause = " AND (" & collateralStatusClause & ")"
END IF

collateralGridStart = Timer()

collateralQuery = _
    " SELECT " & _
    "   l.loanId " & _
    " FROM" & _
    "   loan AS l " & _
    "   INNER JOIN collateral AS cl ON l.loanId = cl.collateralLoanId " & _
    "       AND cl.parentLoanId = " & dbFormatId(selectedLoanId) & collateralStatusClause & _
    " ORDER BY cl.collateralSequence, cl.parentLoanId, l.loanId"
collateralRS.Open collateralQuery, db
IF NOT collateralRS.EOF THEN
    collateralCount = collateralRS.RecordCount
END IF
allowLoanBranchAccess = hasLoanBranchAccess(selectedLoanId)
%>
<div class="aa-collateral-spacer">&nbsp;</div>
<div id="aa-collateral-header">
    <ul class="aa-section-header">
        <li id="collateralHeader"><h2>Additional Collaterals</h2><a href="#collateralHeader"></a></li>
        <% IF Trim(filterMsg & "") <> "" THEN %>
        <li class="aa-color-danger"><%=filterMsg%></li>
        <% END IF %>
    </ul>
</div>
<div>
    <%
    IF collateralCount = 0 Or selectedCollateralStatusFilter = "none" THEN
        displayCollaterals = false
        IF collateralCount = 0 THEN
            %>
            <table class="aa-section-wrapper">
                <tr class="no-results">
                    <td>There are no collaterals for this loan.</td>
                </tr>
            </table>
            <%
        ELSE ' ### There are collaterals but are being filtered
            Dim collateralPlural : collateralPlural = "collaterals"
            IF collateralCount = 1 THEN collateralPlural = "collateral"
            Response.Write "<div>This loan has " & collateralCount & " " & collateralPlural & "," & vbCr _
                         & "but they are not currently viewable.<br/><br/>" & vbCr _
                         & "To see the available collaterals, please click the edit preferences link and select additional collateral statuses to view.</div>" & vbCr
        END IF ' ### IF collateralCount = 0
    ELSE ' ### There are collateral records
        IF Trim(selectedCollateralId & "") = "" THEN
            selectedCollateralId = collateralRS("loanId")
            Session("selectedCollateralId") = selectedCollateralId
        END IF
        IF collateralCount > 0 THEN
           %><!-- #include file="cust_collaterallist.inc" --><%
        END IF
        displayCollaterals = true
    END IF ' ### collateralRS.RecordCount = 0
    collateralRS.Close
    collateralGridEnd = Timer()
    collateralGridDelta = collateralGridEnd-collateralGridStart
    %>
</div>
<%
IF Trim(selectedCollateralId & "") <> "" THEN
    collateralQuery = _
        " SELECT" & _ 
        "	c.customerNumber, " & _ 
        "	c.customerFolder, " & _ 
        "	c.customerTypeId, " & _ 
        "	c.bankId, " & _ 
        "	c.employee, " & _ 
        "	l.ignoreExceptionsYN, " & _ 
        "	l.isCrossCollateralYN, " & _ 
        "	l.isCollateralYN, " & _ 
        "	l.loanId, " & _ 
        "	l.customerId, " & _ 
        "	l.parentLoanId, " & _ 
        "	l.loanNumber, " & _ 
        "	l.primaryCollateralId, " & _ 
        "	l.loanFolder, " & _ 
        "	l.loanTypeId, " & _ 
        "	l.accountClassId, " & _ 
        "	l.accountClassCode, " & _ 
        "	l.PurgeStatus," & _ 
        "	l.PurgeStatusLocked, " & _ 
        "	l.paddedCollateralNumber, " & _ 
        "	l.statusDescription, " & _ 
        "	l.loanTypeDescription, " & _ 
        "	l.statusDescription, " & _ 
        "	l.loanDescription, " & _ 
        "	l.isParticipationLoan," & _ 
        "	(SELECT COUNT(loanId) FROM loan WHERE primaryCollateralId=" &  dbFormatId(selectedCollateralId) &  ") AS ccCount," & _ 
        "	CASE WHEN EXISTS(" & _ 
        "		SELECT CONVERT(bit,1) AS CollateralBlockPurge" & _ 
        "		FROM " & _ 
        "			document INNER JOIN documentDefinitions " & _ 
        "				ON document.documentDefId = documentDefinitions.documentDefId " & _ 
        "			INNER JOIN documentSubType " & _ 
        "				ON documentSubType.documentSubTypeId = documentDefinitions.documentSubTypeId " & _ 
        "       WHERE" & _ 
        "           document.loanId = l.loanId " & _ 
        "           AND document.documentStatus = 1 " & _ 
        "           AND (" & _ 
        "               documentDefinitions.BlockPurge = 1 " & _ 
        "               OR documentSubType.BlockPurge = 1 " & _ 
        "               OR (document.PurgeStatus = 0 AND document.PurgeStatusLocked = 1) " & _ 
        "           )" & _ 
        "   ) " & _ 
        "   THEN CONVERT(bit,1) ELSE CONVERT(bit,0) END AS CollateralBlockPurge," & _ 
        "   pl.isParticipationLoan AS parentIsParticipationLoan," & _
        "   l.collateralSequence" & _
        " FROM " & _ 
        "	customer AS c INNER JOIN viewLoansAndCollaterals AS l" & _ 
        "		ON c.customerId = l.customerId " & _ 
        "	INNER JOIN collateral AS cl" & _
        "		ON cl.collateralLoanId=l.loanId" & _
        "	INNER JOIN loan AS pl" & _
        "		ON pl.loanId=cl.parentLoanId" & _
        " WHERE" & _ 
        "	l.loanId = " & dbFormatId(selectedCollateralId) & _ 
        " ORDER BY " & _ 
        "	l.paddedLoanNumber, " & _ 
        "	l.paddedCollateralNumber"

    collateralRS.Open collateralQuery, db, adOpenStatic, adCmdText

    IF NOT collateralRS.EOF THEN
        ' ### Use the appropriate target IDs for accessing documents and excpeionts ###
        isCrossCollateralYN = collateralRS("isCrossCollateralYN")
        isCollateralYN = collateralRS("isCollateralYN")
        ccCount = collateralRS("ccCount")

        ' ### Default collateral label styles to slatered ###
        collateralStyle = "non-crossed aa-background-base-blue"
        IF isCrossCollateralYN = "Y" OR ccCount > 0 THEN collateralStyle = "crossed aa-background-base-green"

        ' ### Check to see if additional collateral is cross collateralized.
        ' If so, change the header style to slategreen ###
        IF isCrossCollateralYN = "Y" THEN
            targetCollateralLoanId = collateralRS("primaryCollateralId")
            collateralStyle = "crossed aa-background-base-green"

            Dim targetCollateralRS : Set targetCollateralRS = Server.CreateObject("ADODB.RecordSet")
            Dim targetCollateralQuery : targetCollateralQuery = _
                " SELECT" & _
                "   c.customerNumber," & _ 
                "	c.customerFolder," & _ 
                "	c.customerTypeId," & _ 
                "	c.bankId," & _ 
                "	c.employee," & _ 
                "   l.loanFolder," & _ 
                "	l.customerId," & _ 
                "	l.loanId," & _ 
                "	l.loanNumber," & _ 
                "	l.loanTypeId," & _ 
                "	l.PurgeStatus," & _ 
                "	l.PurgeStatusLocked," & _ 
                "   col.parentLoanId," & _ 
                "   lt.accountClassId," & _ 
                "   ac.accountClassCode," & _ 
                "   (SELECT COUNT(loanId) FROM loan WHERE primaryCollateralId=" & dbFormatId(selectedCollateralId) & ") AS ccCount," & _ 
                "   CASE WHEN EXISTS(" & _
                "       SELECT CONVERT(bit,1) AS CollateralBlockPurge" & _
                "       FROM" & _
                "           document INNER JOIN documentDefinitions ON document.documentDefId=documentDefinitions.documentDefId" & _
                "           INNER JOIN documentSubType ON documentSubType.documentSubTypeId=documentDefinitions.documentSubTypeId" & _
                "       WHERE" & _
                "           document.loanId=l.loanId" & _
                "           AND" & _
                "           (" & _
                "               (" & _
                "                   document.documentStatus=1" & _
                "                   AND (documentDefinitions.BlockPurge=1 OR documentSubType.BlockPurge=1)" & _
                "               )" & _
                "               OR (document.PurgeStatus=0 AND document.PurgeStatusLocked=1)" & _
                "           )" & _
                "   ) THEN CONVERT(bit,1) ELSE CONVERT(bit,0) END AS CollateralBlockPurge," & _
                "   pl.isParticipationLoan AS parentIsParticipationLoan," & _
                "   col.collateralSequence" & _
                " FROM " & _
                "   customer AS c " & _
                "   INNER JOIN loan AS l" & _
                "		ON c.customerId = l.customerId " & _
                "   INNER JOIN loanType AS lt" & _
                "		ON lt.loanTypeId = l.loanTypeId " & _
                "   INNER JOIN accountClass AS ac" & _
                "		ON ac.accountClassId = lt.accountClassId " & _
                "   LEFT OUTER JOIN collateral AS col" & _
                "		ON col.collateralLoanId = l.loanId " & _
                "   LEFT OUTER JOIN loan AS pl" & _
                "       ON pl.loanId = col.parentLoanId" & _
                " WHERE" & _
                "   l.loanId = " & dbFormatId(targetCollateralLoanId)
            targetCollateralRS.Open targetCollateralQuery, db, adOpenStatic, adCmdText
            targetBankId                    = targetCollateralRS("bankId")
            targetCustomerId                = targetCollateralRS("customerId")
            targetCustomerNumber            = targetCollateralRS("customerNumber")
            targetCustomerFolder            = targetCollateralRS("customerFolder")
            targetCustomerEmployee          = targetCollateralRS("employee")
            targetParentLoanId              = targetCollateralRS("parentLoanId")
            targetLoanId                    = targetCollateralRS("loanId")
            targetLoanNumber                = targetCollateralRS("loanNumber")
            targetLoanFolder                = targetCollateralRS("loanFolder")
            targetLoanTypeId                = targetCollateralRS("loanTypeId")
            targetAccountClassId            = targetCollateralRS("accountClassId")
            targetAccountClassCode          = targetCollateralRS("accountClassCode")
            targetPurgeStatus               = targetCollateralRS("PurgeStatus")
            targetPurgeStatusLocked         = targetCollateralRS("PurgeStatusLocked")
            targetCollateralBlockPurge      = targetCollateralRS("CollateralBlockPurge")
            targetCollateralSequence        = targetCollateralRS("collateralSequence")
            targetCollateralRS.Close
        ELSE
            targetCollateralLoanid          = collateralRS("loanId")
            targetBankId                    = collateralRS("bankId")
            targetCustomerId                = collateralRS("customerId")
            targetCustomerNumber            = collateralRS("customerNumber")
            targetCustomerFolder            = collateralRS("customerFolder")
            targetCustomerEmployee          = collateralRS("employee")
            targetParentLoanId              = collateralRS("parentLoanId")
            targetLoanId                    = collateralRS("loanId")
            targetLoanNumber                = collateralRS("loanNumber")
            targetLoanFolder                = collateralRS("loanFolder")
            targetLoanTypeId                = collateralRS("loanTypeId")
            targetAccountClassId            = collateralRS("accountClassId")
            targetAccountClassCode          = collateralRS("accountClassCode")
            targetPurgeStatus               = collateralRS("PurgeStatus")
            targetPurgeStatusLocked         = collateralRS("PurgeStatusLocked")
            targetCollateralBlockPurge      = collateralRS("CollateralBlockPurge")
            targetCollateralSequence        = collateralRS("collateralSequence")
        END IF

        ' Participation is determined by the direct owning loan.IsParticipation flag even for secondary cross collateral.
        '
        targetParentIsParticipationLoan = collateralRS("parentIsParticipationLoan")
    
        collateralCount = 0
        Set collateralCountRS = Server.CreateObject("ADODB.RecordSet")
        collateralCountQuery = "SELECT TOP 1 1 FROM collateral WHERE parentLoanId = " & dbFormatId(selectedLoanId)
        collateralCountRS.Open collateralCountQuery, db
        IF NOT collateralCountRS.EOF THEN collateralCount = 1
        collateralCountRS.Close



        ' ### RecordSet and query for primaryCollateral. Used only for Cross collaterals. ###
        Dim primaryCollateralQuery
        Dim primaryCollateralRS : Set primaryCollateralRS = Server.CreateObject("ADODB.RecordSet")

        ' ### The following is used for accessing Credit Flex Fields for all credit
        ' include pages. It will always create due to the OUTER JOIN with the customer table. ###
        Dim collateralFieldsQuery
        Dim collateralFieldsRS : Set collateralFieldsRS = Server.CreateObject("ADODB.RecordSet")

        collateralFieldsQuery = _
            " SELECT" & _
            "   cf.*" & _
            " FROM" & _
            "   loan AS l LEFT OUTER JOIN collateralFields AS cf" & _
            "       ON l.loanId=cf.collateralId" & _
            " WHERE" & _
            "   l.loanId = " & dbFormatId(targetCollateralLoanid)
        collateralFieldsRS.Open collateralFieldsQuery, db, adOpenStatic, adCmdText
        %>
        <div><!-- #include file="cust_collateralheader.inc" --></div>
        <%
        ' ### Default activeCollateralTab ###
        IF selectedCollateralTab = "" THEN selectedCollateralTab = "document"

        ' ### Set active tab style ###
        IF selectedCollateralTab = "exception" THEN
            activeTabStyle = "exception"
        ELSEIF selectedCollateralTab = "crosscollateral" THEN
            activeTabStyle = "crosscollateral"
        ELSE
            activeTabStyle = "document"
        END IF

        ' ### Check for Collateral Exceptions for the target Collateral ###
        collateralExceptionQuery = "SELECT TOP 1 1 FROM exception WHERE loanId = " & dbFormatId(targetCollateralLoanId) & " AND exceptionState = 'Y'"
        collateralExceptionRS.Open collateralExceptionQuery, db, adOpenStatic
        exceptionCount = collateralExceptionRS.RecordCount
        collateralExceptionRS.Close

        collateralExceptionQuery = "SELECT TOP 1 1 FROM exception WHERE loanId = " & dbFormatId(targetCollateralLoanId) & " AND exceptionState = 'P'"
        collateralExceptionRS.Open collateralExceptionQuery, db, adOpenStatic
        pendingExceptionCount = collateralExceptionRS.RecordCount
        collateralExceptionRS.Close

        ' ### Check for cross collaterals associated with this collateral ###
        crossCollateralQuery = "SELECT TOP 1 1 FROM loan WHERE primaryCollateralId = " & dbFormatId(targetCollateralLoanId)
        crossCollateralRS.Open crossCollateralQuery, db, adOpenStatic, adCmdText
        crossCollateralCount = crossCollateralRS.RecordCount
        crossCollateralRS.Close
        %>
        <div id="loan-header-separator"></div>
        <a name="collateralGroupActivate" href="#"></a>
        <table class="aa-tab-table">
            <tr class="aa-tab-wrapper">
                <td class="aa-tab-separator"></td>
                <td class="aa-tab<% IF activeTabStyle = "document" THEN %>-selected<% END IF %>"><!-- #include file="cust_collateraldoctab.inc" --></td>
                <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
                <td class="aa-tab-separator"></td>
                <td class="aa-tab<% IF activeTabStyle = "exception" THEN %>-selected<% END IF %>"><!-- #include file="cust_collateralexcepttab.inc" --></td>
                <% END IF %>
                <% IF crossCollateralCount > 0 AND Session("accuaccount.enableExpress") <> 1 THEN %>
                <td class="aa-tab-separator"></td>
                <td class="aa-tab<% IF activeTabStyle = "crosscollateral" THEN %>-selected<% END IF %>"><!-- #include file="cust_collateralcrosscoltab.inc" --></td>
                <% END IF %>
                <td class="aa-tab-separator"></td>
                <td class="aa-pl6"><!-- #include file="cust_collateral_dropdown.asp" --></td>
                <td class="aa-width-100">&nbsp;</td>
            </tr>
        </table>
        <table class="aa-width-100">
            <tr>
                <% IF selectedCollateralTab = "exception" THEN %>
                <td><!-- #include file="cust_collateralexceptbody.inc" --></td>
                <% ELSEIF selectedCollateralTab = "crosscollateral" AND crossCollateralCount > 0 AND Session("accuaccount.enableExpress") <> 1 THEN %>
                <td><!-- #include file="cust_collateralcrosscolbody.inc" --></td>
                <% ELSE %>
                <td><!-- #include file="cust_collateraldocbody.inc" --></td>
                <% END IF %>
            </tr>
        </table>
        <%
        collateralFieldsRS.Close
    END IF ' ### IF NOT collateralRS.EOF
    collateralRS.Close
END IF ' ### IF Trim(selectedCollateralId & "") <> ""
%>
<%
collateralBlockTimeStop = Timer()
collateralBlockTimeDelta = collateralBlockTimeStop-collateralBlockTimeStart
%>