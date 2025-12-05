<%
creditBlockTimeStart = Timer()

' ### NOTE: This code is dependant on variables in the customer.asp page. If changes are made make sure
' they are consistant with the parent page. ###
%>
<!-- #include file="base64encode_decode.inc" -->
<%
Dim creditFieldsString
' ### Credit DOCUMENT FIELD LIST ###
' This should be a well ordered --comma seperated-- list of field names to be used in retrieving document data
creditFieldsString = _
    "customerId,customerBranchId,documentTabId,documentDefId,docTabStatusType," & _
    "docTabHighlightColor,documentTypeId,documentSubTypeId,documentTypeName," & _
    "typeSortOrder,sortOrder,PurgeStatus,PurgeStatusLocked," & _
    "BlockPurge,subTypeDescription,subTypeInstruction,requireExpDate," & _
    "hideEmployeeFileYN,hideTabYN,defaultActivationStatus,docDefHighlightColor," & _
    "docDefDocSortBy,documentSubTypeName,documentStatus,documentStatusType," & _
    "documentTitle,documentHighlightColor,loanFile,filename," & _
    "documentId,documentComment,expDate,nonExpiring," & _
    "origDate,docTabAllowSchedule,docTabNextCreateDate,docTabProcessingDateEnd," & _
    "RequireQc,CriticalQc,QcStatus,hasDemographicData"
Dim exceptionCountPending
Dim creditFieldsArray : creditFieldsArray = Split(creditFieldsString, ",")
Dim creditFieldsDict : Set creditFieldsDict = CreateObject("Scripting.Dictionary") 
creditFieldsDict.CompareMode = TextMode ' ### NOTE: Need to set this flag... otherwise field names are CASE SENSITIVE
' ### Convert array into dictionary so we can use field names ###
FOR i = lBound(creditFieldsArray) TO uBound(creditFieldsArray)
    IF NOT creditFieldsDict.exists(creditFieldsArray(i)) THEN
        ' ### Name is the key, then matched with the field ordinal in the dictionary ###
        creditFieldsDict.add creditFieldsArray(i), i
    END IF
NEXT

' ### Check for if credit tab default is set or not ###
IF selectedCreditTab = "" THEN selectedCreditTab = "document"
Session("selectedCreditTab") = selectedCreditTab

' ### keep track of this page so we can go back to it when we finish adding or changing a group ###
Session("fromCustomerRelatedEntitiesTab") = "customer.asp"

' ### Set the tab styles ###
documentTabStyle = "tabStyle1"
exceptionTabStyle = "tabStyle2"
entityTabStyle = "tabStyle3"
commentTabStyle = "tabStyle5"

' ### Determine which tab is active and apply appropriate style. ###
IF selectedCreditTab = "exception" THEN
    activeTabStyle = exceptionTabStyle
ELSEIF selectedCreditTab = "relatedEntities" THEN
    activeTabStyle = entityTabStyle
ELSEIF selectedCreditTab = "comments" THEN
    activeTabStyle = commentTabStyle
ELSE
    activeTabStyle = documentTabStyle
END IF

customerID = selectedCustomerId

' ### Get branch security access for this customer ###
Dim allowCustomerBranchAccess : allowCustomerBranchAccess = hasCustomerBranchAccess(selectedCustomerId)


' ### The following is used for accessing Credit Flex Fields for all credit
' include pages. It will always create due to the OUTER JOIN with the customer table. ###
Dim creditFieldsRS : Set creditFieldsRS = Server.CreateObject("ADODB.RecordSet")
Dim creditFieldsQuery : creditFieldsQuery = "SELECT * FROM customerFields WHERE customerId = " & dbFormatId(selectedCustomerId)
creditFieldsRS.Open creditFieldsQuery, db, adOpenForwardOnly, adLockReadOnly
 
IF IsNull(customerRS("employee")) OR Session("isSuperUser") THEN
    employeeViewer = True
ELSEIF cInt(customerRS("employee")) = 0 OR Session("isSuperUser") THEN
    employeeViewer = True
ELSE
    FOR i = 1 TO bankmax
        IF cStr(customerRS("bankid")) = cStr(banksecurity(i,1)) THEN
            IF banksecurity(i,2) = 1 THEN employeeViewer = True
        END IF
    NEXT
END IF
%>
<a name="creditGroupActivate" href="javascript:void(0);"></a>
<table class="aa-tab-table">
    <tr class="aa-tab-wrapper">
        <td class="aa-tab<% IF selectedCreditTab = "document" THEN %>-selected<% END IF %>"><!-- #include file="cust_creditdoctab.inc" --></td>
        <td class="aa-tab-separator"></td>
        <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
        <td class="aa-tab<% IF selectedCreditTab = "exception" THEN %>-selected<% END IF %>"><!-- #include file="cust_creditexcepttab.inc" --></td>
        <% END IF %>
        <td class="aa-tab-separator"></td>
        <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
        <td class="aa-tab<% IF selectedCreditTab = "relatedEntities" THEN %>-selected<% END IF %>"><!-- #include file="cust_creditentitytab.inc" --></td>
        <% END IF %>
        <td class="aa-tab-separator"></td>
        <td class="aa-tab<% IF selectedCreditTab = "comments" THEN %>-selected<% END IF %>"><!-- #include file="cust_creditcommenttab.inc" --></td>
        <td class="aa-pl6"><!-- #include file="cust_credit_dropdown.asp" --></td>
        <td class="aa-width-100">&nbsp;</td>
    </tr>
</table>
<div class="aa-tab-content-wrapper">
    <table class="aa-width-100">
        <tr>
            <td class="<%=activeTabStyle%>">
            <% IF selectedCreditTab = "exception" THEN %>
            <!-- #include file="cust_creditexceptbody.inc" -->
            <% ELSEIF selectedCreditTab = "relatedEntities" THEN %>
            <!-- #include file="cust_creditentitybody.inc" -->
            <% ELSEIF selectedCreditTab = "comments" THEN %>
            <!-- #include file="cust_creditcommentbody.inc" -->
            <% ELSE %>
            <!-- #include file="cust_creditdocbody.inc" -->
            <% END IF %>
            </td>
        </tr>
    </table>
</div>
<%
creditFieldsRS.Close

CreditBlockTimeStop = Timer()
creditBlockTimeDelta = creditBlockTimeStop-creditBlockTimeStart
%>