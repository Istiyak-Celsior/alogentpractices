<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<!-- #include file="../getBankArray.inc" -->
<!-- #include file="../getUserBranchSecurityArrayMultiBank.inc" -->
<%
' ### Get user view preferences ###
' 0 - My Active Exceptions (default)
' 1 - Loan Officer
' 2 - Assigned User

' Also the saved filter list string consists of comma delimited, GUID pairs. The GUID pairs are seperated by
' a double colon "::". The first GUID of the pair is the BankId. The second GUID is either the loanOfficerId
' or userId (based on the view preferences settings above).

' If the string consists of only "all" then there is no specific filtering based on bank or officer/user.
' If a GUID pair consists of {bankId}::0, this represents that all officers/users of that bank should be used in the search filter.
' If a GUID pair consists of {bankId}::{userId or officerId} then only that officer/user of that bank should be used in the search filter.

' Below is a short example of a raw filter list string with new lines added for readability:
'   "{B3BEEB18-08A3-4935-B2DF-5CF510D4E894}::all,
'   {E3786103-8878-420D-ACE9-5491A65F56A7}::0,
'   {E3786103-8878-420D-ACE9-5491A65F56A7}::{39FBF697-232C-48F8-BE5C-120910AC0E24},
'   {E3786103-8878-420D-ACE9-5491A65F56A7}::{FDB644ED-ABFA-4773-AF4A-1CDFADD71AC6},
'   {E3786103-8878-420D-ACE9-5491A65F56A7}::{759DE09B-493A-45D6-8209-8326CFB16BE2}"

' This example consist of two banks, the first filtering by all users (including unassigned). The other four entries consist
' of specific users (including unassigned) for the given bank that we want to filter on.

Dim filterBy : filterBy = Session("activeExceptionDisplayFilter")
Dim strFilterList : strFilterList = Session("activeExceptionFilterList")
Dim filterByLabel : filterByLabel = "My Exceptions"

' ### If setting not in session then check cookies, otherwise use default ###
IF filterBy = "" THEN
    filterBy = Request.Cookies(Session("userLogin") & ".acculoan.activeExceptionDisplayFilter")
    strFilterList = Request.Cookies(Session("userLogin") & ".acculoan.activeExceptionFilterList")

    IF filterBy = "" THEN
        ' ### Check old cookie value before making it user specific. ###
        IF Request.Cookies("acculoan.activeExceptionDisplayFilter") <> "" THEN
            filterBy = Request.Cookies("acculoan.activeExceptionDisplayFilter")
            strFilterList = Request.Cookies("acculoan.activeExceptionFilterList")
        ELSE
            filterBy = 0
            strFilterList = ""
        END IF

        ' ### Save settings ###
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionDisplayFilter") = filterBy
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionDisplayFilter").expires =  #12/31/2030#
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionFilterList") = strFilterList
        Response.Cookies(Session("userLogin") & ".acculoan.activeExceptionFilterList").expires =  #12/31/2030#
    END IF
    Session("activeExceptionDisplayFilter") = filterBy
    Session("activeExceptionFilterList") = strFilterList
END IF

IF filterBy = "1" THEN
    filterByLabel = "Officer Filter"
ELSEIF filterBy = "2" THEN
    filterByLabel = "Assigned User Filter"
END IF
%>
<div class="aa-active-exceptions-dashboard-widget" >
<div class="aa-panel-header">
    <div>
         <a href="javascript:void(0);" data-bind="click: openFilterSettings">Exception Filter Settings</a>
    </div>
    <div class="aa-color-info"><%=filterByLabel%></div>
</div>
<table class="aa-panel-table">
    <%
    Dim activeExceptionRS : Set activeExceptionRS = Server.CreateObject("ADODB.RecordSet")
    Dim officerFilterId : outerFilterClause = ""
    Dim innerFilterClause : innerFilterClause = ""

    IF filterBy = 0 THEN ' ### My Active Exceptions
        ' NOTE: the inner and outer SQL clauses use different aliases for the exception
        ' table, hence the replace function call in the inner clause below
        outerFilterClause = " AND (ex.assignedUserId = " & dbFormatId(Session("userId")) & ")"
        innerFilterClause = Replace(outerFilterClause, "ex.", "ix.")
        innerFilterClause = Replace(innerFilterClause, "c.", "ic.")
        innerFilterClause = Replace(innerFilterClause, "l.", "il.")
    ELSEIF filterby = 1 THEN
        formattedFilterClause = BuildOfficerFilter(strFilterList)
        IF formattedFilterClause <> "" THEN
            outerFilterClause = formattedFilterClause
            innerFilterClause = Replace(outerFilterClause, "ex.", "ix.")
            innerFilterClause = Replace(innerFilterClause, "c.", "ic.")
            innerFilterClause = Replace(innerFilterClause, "l.", "il.")
        END IF
    ELSEIF filterby = 2 THEN
        formattedFilterClause = BuildAssignedUserFilter(strFilterList)
        ' NOTE: the inner and outer SQL clauses use different aliases for the exception
        ' table, hence the replace function call in the inner clause below
        IF formattedFilterClause <> "" THEN
            outerFilterClause = formattedFilterClause
            innerFilterClause = Replace(outerFilterClause, "ex.", "ix.")
            innerFilterClause = Replace(innerFilterClause, "c.", "ic.")
            innerFilterClause = Replace(innerFilterClause, "l.", "il.")
        END IF
    END IF

    ' ### NOTE: the inner select (really a column consisting of a SELECT based on the outer SELECT)
    ' generates the summary and the outer select contains the details releated to the summary. ###
    Dim activeExceptionQuery : activeExceptionQuery = _
        " SELECT" & _
        "   b.bankId," & _
        "   b.bankName," & _
        "   c.customerId," & _
        "   c.customerBranchId," & _
        "   c.customerName," & _
        "   c.customerNumber," & _
        "   l.loanId," & _
        "   l.loanBranchId," & _
        "   l.loanNumber," & _
        "   l.isCollateralYN," & _
        "   cl.parentLoanId," & _
        "   cl.collateralSequence," & _
        "   SUM(1) as exceptionCount," & _
        "   v1.totalExceptionCount" & _
        " FROM" & _
        "   viewExceptions AS vex INNER JOIN exception AS ex" & _
        "       ON vex.exceptionId = ex.exceptionId" & _
        "   INNER JOIN exceptionDefinition AS ed" & _
        "       ON ex.exceptionDefId=ed.exceptionDefId" & _
        "   INNER JOIN customer AS c " & _
        "       ON c.customerId=ex.customerId" & _
        "   INNER JOIN bank AS b" & _
        "       ON c.bankId=b.bankId" & _
        "   LEFT OUTER JOIN loan AS l" & _
        "       ON ex.loanId=l.loanId" & _
        "   LEFT OUTER JOIN collateral AS cl" & _
        "       ON cl.collateralLoanId=l.loanId" & _
        "   LEFT OUTER JOIN exceptedDocument AS exdoc" & _
        "       ON exdoc.exceptionId=ex.exceptionId" & _
        "   LEFT OUTER JOIN (" & _
        "       SELECT" & _
        "           ic.customerId," & _
        "           SUM(1) AS totalExceptionCount" & _
        "       FROM" & _
        "           viewExceptions AS vix INNER JOIN exception AS ix" & _
        "               ON vix.exceptionId = ix.exceptionId" & _
        "           INNER JOIN exceptionDefinition AS id" & _
        "               ON ix.exceptionDefId=id.exceptionDefId" & _
        "           INNER JOIN customer AS ic " & _
        "               ON ic.customerId=ix.customerId" & _
        "           INNER JOIN bank AS ib" & _
        "               ON ic.bankId=ib.bankId" & _
        "           LEFT OUTER JOIN loan AS il" & _
        "               ON il.loanId=ix.loanId" & _
        "           LEFT OUTER JOIN exceptedDocument AS ixd" & _
        "               ON ixd.exceptionId=ix.exceptionId" & _				
        "       WHERE" & _
        "           ix.statusType = 'required'" & _
        "           AND CASE WHEN ix.loanId IS NOT NULL THEN il.ignoreExceptionsYN ELSE ic.ignoreExceptionsYN END = 'N'" & _
        "           AND (" & _
        "               (id.computationType = 'manual' AND ix.exceptionState <> 'N')" & _
        "               OR" & _
        "               (id.computationType = 'computed' AND ISNULL(ixd.documentExceptionState, ix.exceptionState) <> 'N')" & _
        "           )" & _
        innerFilterClause & _
        "       GROUP BY" & _
        "           ic.customerId" & _
        "   ) AS v1" & _
        "       ON v1.customerId=ex.customerId" & _
        " WHERE" & _
        "   ex.statusType = 'required'" & _
        "   AND CASE WHEN ex.loanId IS NOT NULL THEN l.ignoreExceptionsYN ELSE c.ignoreExceptionsYN END = 'N'" & _
        "   AND (" & _
        "       (ed.computationType = 'manual' AND ex.exceptionState <> 'N')" & _
        "       OR" & _
        "       (ed.computationType = 'computed' AND ISNULL(exdoc.documentExceptionState, ex.exceptionState) <> 'N')" & _
        "   )" & _
        outerFilterClause & _
        " GROUP BY" & _
        "   b.bankId," & _
        "   b.bankName," & _
        "   c.customerId," & _
        "   c.customerBranchId," & _
        "   v1.totalExceptionCount," & _
        "   c.customerName," & _
        "   c.customerNumber," & _
        "   l.loanId," & _
        "   l.loanBranchId," & _
        "   l.loanNumber," & _
        "   l.isCollateralYN," & _
        "   cl.parentLoanId," & _
        "   cl.collateralSequence" & _
        " ORDER BY" & _
        "   v1.totalExceptionCount DESC," & _
        "   b.bankName," & _
        "   c.customerName," & _
        "   exceptionCount DESC," & _
        "   l.loanNumber"
        activeExceptionRS.Open activeExceptionQuery, db
        Dim toggleBankDisplay : toggleBankDisplay = false
        IF bankRows > 1 THEN toggleBankDisplay = true
        IF activeExceptionRS.EOF THEN
        %>
        <tr class="aa-no-results">
            <td>There are no active Exceptions based on your current Exception Filter Settings.</td>
        </tr>
        <% ELSE %>
        <tr class="aa-header">
            <% IF toggleBankDisplay THEN %>
            <td>Bank</td>
            <% END IF %>
            <td>Customer/Account</td>
            <td>Collateral</td>
            <td class="aa-tac">Exceptions</td>
        </tr>
        <%
        Dim customerUrl, customerNumber, customerName, customerId
        Dim loanNumber, loanId, parentLoanId, isCollateralYN, collateralNumber

        Dim customerCount : customerCount = 0
        Dim oldCustomerId : oldCustomerId = ""
        DO UNTIL activeExceptionRS.EOF
            hasBranchPermission = False
            ' ### NOTE: the following iterates through the user's allowable branch access and compares
            ' it to the customerBranchId or loanBranchId to see if the record should be displayed.
            ' ### NOTE: Bypassing branch security for now as it does not make sense
            IF true OR Session("isSuperUser") THEN
                hasBranchPermission = true
            ELSE
                FOR permissionArray = 0 TO userBranchSecurityRows
                    permissionBranchID = userBranchSecurityArray(0, permissionArray)
                    IF permissionBranchID = activeExceptionRS("customerBranchId") OR permissionBranchID = activeExceptionRS("loanBranchId") THEN
                        hasBranchPermission = True
                    END IF
                NEXT
            END IF

            IF hasBranchPermission THEN
                customerId = activeExceptionRS("customerId")
                loanId = activeExceptionRS("loanId")
                isCollateralYN = activeExceptionRS("isCollateralYN")
                parentLoanId = activeExceptionRS("parentLoanId")

                ' ### Display customer name once and build partial URL to go to customer page ###
                customerUrl = "customer.asp?customerId=" & customerId 
                IF cStr(oldCustomerId) <> cStr(customerId) THEN
                    oldCustomerId = customerId
                    customerCount = customerCount + 1
                    %>
                    <tr>
                        <% IF toggleBankDisplay THEN %>
                        <td><%=activeExceptionRS("bankName")%></td>
                        <% END IF %>
                        <td colspan="2"><a href="<%=customerUrl%>&creditTab=exception\\#creditHeader"><%=activeExceptionRS("customerName")%> (<%=activeExceptionRS("customerNumber")%>)</a></td>
                        <td class="aa-tac aa-color-danger"><b><%=activeExceptionRS("totalExceptionCount")%></b></td>
                    </tr>
                    <%
                END IF ' ### CStr(oldCustomerId) <> CStr(customerId)

                ' ### Append loan information for building direct links to customer's loans ###
                loanNumber = activeExceptionRS("loanNumber")
                IF isCollateralYN = "Y" THEN
                    loanNumber = Trim(Left(loanNumber, InStrRev(loanNumber, "_")-1))
                    collateralNumber = GetPaddedCollateralSequence(activeExceptionRS("collateralSequence"))
                    customerUrl = customerUrl & "&loanId=" & parentLoanId & "&collateralId=" & loanId & "&collateralTab=exception\\#collateralHeader"
                ELSE
                    customerUrl = customerUrl & "&loanId=" & loanId & "&loanTab=exception\\#loanHeader"
                END IF
                %>
                <tr>
                    <% IF toggleBankDisplay THEN %>
                    <td>&nbsp;</td>
                    <% END IF %>
                    <% IF CheckForNull(activeExceptionRS("loanNumber")) = "" THEN %>
                    <td class="aa-exception-type-indent">Credit Exceptions</td>
                    <% ELSEIF isCollateralYN = "N" THEN %>
                    <td class="aa-exception-type-indent"><a href="<%=customerUrl%>"><%=loanNumber%></a></td>
                    <% ELSEIF isCollateralYN = "Y" THEN %>
                    <td class="aa-exception-type-indent"><%=loanNumber%></td>
                    <% END IF %>
                    <% IF isCollateralYN = "Y" THEN %>
                    <td><a href="<%=customerUrl%>"><%=collateralNumber%></a></td>
                    <% ELSEIF isCollateralYN = "N" THEN %>
                    <td>---</td>
                    <% ELSE %>
                    <td>&nbsp;</td>
                    <% END IF %>
                    <td class="aa-tac"><%=activeExceptionRS("exceptionCount")%></td>
                </tr>
                <%
            END IF ' ### hasBranchPermission
            activeExceptionRS.MoveNext()

            ' ### Check the next customer and increment counter to test for early exiting ###
            IF NOT activeExceptionRS.EOF THEN
                IF cStr(oldCustomerId) <> cStr(activeExceptionRS("customerId")) THEN
                    customerCount = customerCount + 1
                END IF
            END IF
        LOOP
    END IF ' ### DO UNTIL activeExceptionRS.EOF
    activeExceptionRS.Close()
    %>
</table>
</div>
<!-- #include file="../dbclose.inc" -->
<%
FUNCTION BuildBankFilter(strFilters)
    Dim bankFilter : bankFilter = ""
    IF strFilters <> "all" THEN
        Dim filterListPairs : filterListPairs = Split(strFilters, "::")
        Dim idx
        FOR idx = 0 TO uBound(filterListPairs)
            ' ### NOTE: we only care about the first element of the value pair because it's the bankId. ###
            Dim filterPair : filterPair = Split(filterListPairs(i), ",")
            Dim filterBankId : filterBankId = filterPair(0)

            ' ### Only add to the bankFilter if the bankId does not already exist in the list. ###
            IF InStr(bankFilter, filterBankId, 1) THEN
                IF bankFilter = "" THEN
                    bankFilter = dbFormatId(filterBankId)
                ELSE
                    bankFilter = bankFilter & ", " & dbFormatId(filterBankId)
                END IF
            END IF
        NEXT
    END IF
    IF bankFilter <> "" THEN bankFilter = " AND bankId IN (" & bankFilter & ")"
    BuildBankFilter = bankFilter
END FUNCTION

FUNCTION BuildOfficerFilter(strFilters)
    Dim officerFilter : officerFilter = ""
    IF strFilters <> "all" THEN
        Dim filterListPairs : filterListPairs = Split(strFilters, ",")
        Dim idx
        FOR idx = 0 TO uBound(filterListPairs)
            ' ### NOTE: we only care about the first element of the value pair because it's the bankId. ###
            Dim filterPair : filterPair = Split(filterListPairs(idx), "::")
            Dim filterBankId : filterBankId = filterPair(0)
            Dim filterOfficerId : filterOfficerId = filterPair(1)

            ' ### Only add to the officerFilter if the officerFilterId does not already exist in the list. ###
            IF officerFilter = "" THEN
                officerFilter = dbFormatId(filterOfficerId)
            ELSEIF InStr(officerFilter, filterOfficerId) = 0 THEN
                officerFilter = officerFilter & ", " & dbFormatId(filterOfficerId)
            END IF
        NEXT
    END IF
    IF officerFilter <> "" THEN
        officerFilter = _
            " AND (" & _
            "   (c.customerOfficerId IN (" & officerFilter & ") AND ex.loanId IS NULL)" & _
            "   OR (l.loanOfficerId IN (" & officerFilter & ") AND ex.loanId IS NOT NULL)" & _
            " )"
    END IF
    BuildOfficerFilter = officerFilter
END FUNCTION

FUNCTION BuildAssignedUserFilter(strFilters)
    Dim userFilter : userFilter = ""
    Dim unassignedUserFilter : unassignedUserFilter = ""
    IF strFilters <> "all" THEN
        Dim filterListPairs : filterListPairs = Split(strFilters, ",")
        Dim idx
        FOR idx = 0 TO uBound(filterListPairs)
            ' ### NOTE: we only care about the first element of the value pair because it's the bankId. ###
            Dim filterPair : filterPair = Split(filterListPairs(idx), "::")
            Dim filterBankId : filterBankId = filterPair(0)
            Dim filterUserId : filterUserId = filterPair(1)

            IF filterUserId = "0" THEN
                ' ### Special check for userId=0, unassigned users check for NULL ###
                IF unassignedUserFilter = "" THEN
                    unassignedUserFilter = " ex.assignedUserId IS NULL "
                END IF
            ELSE
                ' ### Only add to the userFilter if the userId does not already exist in the list. ###
                IF userFilter = "" THEN
                    userFilter = dbFormatId(filterUserId)
                ELSEIF InStr(userFilter, filterUserId) = 0 THEN
                    userFilter = userFilter & ", " & dbFormatId(filterUserId)
                END IF
            END IF
        NEXT
    END IF
    IF userFilter <> "" OR unassignedUserFilter <> "" THEN
        IF userFilter <> "" AND unassignedUserFilter = "" THEN
            userFilter = " AND (ex.assignedUserId IN (" & userFilter & "))"
        ELSEIF userFilter <> "" And unassignedUserFilter <> "" THEN
            userFilter = " AND (ex.assignedUserId IN (" & userFilter & ") OR " & unassignedUserFilter & " )"
        ELSEIF userFilter = "" AND unassignedUserFilter <> "" THEN
            userFilter = " AND (" & unassignedUserFilter & ") "
        END IF
    END IF
    buildAssignedUserFilter = userFilter
END FUNCTION
%>