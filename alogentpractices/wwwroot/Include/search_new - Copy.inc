<!--
<%
Function BuildUserGroupQuery(target)
		' Depending on the filter target adjust the SQL FROM clause as appropriate.
		Dim targetClause
		If target = "approver" Then
            targetClause = " ON list.assigneeId=appr.assignedApproverId"
        ElseIf  target = "lender" _
                Or target = "analyst" _
                Or target = "loanprocessor" Then
			targetClause = "	ON list.assigneeId = la.assigned" & target & "Id" 
		End If
		
		' NOTE: The following joins tha active users and groups based on target (lender, approver, etc)
		' to the list of currently assigned users in case they are not part of the list.
		Dim query
		query = _
			" SELECT" & _
			"	list.assigneeId AS targetId," & _
			"	list.assigneeName AS targetName," & _
			"	list.assigneeType AS targetType" & _
			" FROM " & _
			"	viewAssigneeList AS list LEFT OUTER JOIN [User] as u" & _
			"		ON list.assigneeId=u.userId" & _
			"	LEFT OUTER JOIN userGroup AS ug" & _
			"		ON ug.userGroupId=list.assigneeId" & _
			" WHERE	" & _
			"	ISNULL(u.inactive,'N') = 'N'" & _
			"	AND (list.assigneeType LIKE 'U' OR list.assigneeType LIKE 'G')" & _
			"	AND (u.is" & target & " = 1 OR ug.is" & target & "Group = 1)"  & _
			" UNION" & _
			" SELECT" & _
			"	list.assigneeId AS targetId," & _
			"	list.assigneeName AS targetName," & _
			"	list.assigneeType AS targetType" & _
			" FROM" & _
			"	loan AS l INNER JOIN loanStatus AS ls" & _
			"		ON l.loanStatusId=ls.statusId" & _
			"	INNER JOIN loanApplication AS la" & _
			"		ON la.loanId=l.loanId" & _
			"	LEFT OUTER JOIN approval AS appr" & _
			"		ON appr.approvalId=la.approvalId" & _
			"	INNER JOIN viewAssigneeList AS list" & _
			targetClause & _
			" WHERE" & _
			"	list.assigneeType LIKE 'U'" & _
			"	AND ls.isApplicationStatus=1" & _
			" ORDER BY assigneeName"
			
		BuildUserGroupQuery = query
	End Function
%> -->
// This method should be placed in your PageModel.cs file or a separate service/repository class.

public string BuildUserGroupQuery(string target)
{
    string targetClause = string.Empty;

    // Use a 'switch' statement or an 'if-else' block to handle the conditional logic.
    switch (target)
    {
        case "approver":
            targetClause = " ON list.assigneeId = appr.assignedApproverId";
            break;
        case "lender":
        case "analyst":
        case "loanprocessor":
            // Use string interpolation to dynamically insert the 'target' variable.
            targetClause = $" ON list.assigneeId = la.assigned{target}Id";
            break;
    }

    // Use a verbatim string literal (@"...") for a multiline query.
    // This makes the SQL much easier to read and maintain.
    string query = $@"
        SELECT
            list.assigneeId AS targetId,
            list.assigneeName AS targetName,
            list.assigneeType AS targetType
        FROM
            viewAssigneeList AS list
            LEFT OUTER JOIN [User] AS u ON list.assigneeId = u.userId
            LEFT OUTER JOIN userGroup AS ug ON ug.userGroupId = list.assigneeId
        WHERE
            ISNULL(u.inactive, 'N') = 'N'
            AND (list.assigneeType LIKE 'U' OR list.assigneeType LIKE 'G')
            AND (u.is{target} = 1 OR ug.is{target}Group = 1)
        UNION
        SELECT
            list.assigneeId AS targetId,
            list.assigneeName AS targetName,
            list.assigneeType AS targetType
        FROM
            loan AS l
            INNER JOIN loanStatus AS ls ON l.loanStatusId = ls.statusId
            INNER JOIN loanApplication AS la ON la.loanId = l.loanId
            LEFT OUTER JOIN approval AS appr ON appr.approvalId = la.approvalId
            INNER JOIN viewAssigneeList AS list {targetClause}
        WHERE
            list.assigneeType LIKE 'U'
            AND ls.isApplicationStatus = 1
        ORDER BY assigneeName";

    return query;
}
<%
    'Dynamic javascript to handle bank/branch changes
    Response.write vbcrlf & vbcrlf
    Response.write "<script type='text/javascript'>" & vbcrlf
    Response.write "  var banks = new Object();" & vbcrlf
    
    lastBankId = ""
    allBankList = ""
    
    for i = 0 to branchRows-1
      if CStr(lastBankId) <> CStr(branchArray(0,i)) then
        Response.write "  banks[" & Chr(34) & "bank=" & branchArray(0,i) & Chr(34) & "]= new Array(" & vbcrlf
        Response.write "    " & Chr(34) & Chr(34) & ", " & Chr(34) & "All Branches" & Chr(34) & ", " & vbcrlf
        lastBankId = branchArray(0,i)
      end if
      
      Response.write "    " & Chr(34) & branchArray(2,i) & Chr(34) & ", " & Chr(34) & branchArray(3,i) & Chr(34)
      allBankList = allBankList & "    " &  Chr(34) & branchArray(2,i) & Chr(34) & ", " & Chr(34) & branchArray(3,i) & Chr(34)
      
      if i = (branchRows-1) then
        'Handle last branch
        Response.write vbcrlf & "  );" & vbcrlf
        allBankList = allBankList  & vbcrlf
      elseif CStr(lastBankId) <> CStr(branchArray(0,i+1)) then
        'Check next branch to see if different bank
        Response.write vbcrlf & "  );" & vbcrlf
        allBankList = allBankList & ", " & vbcrlf
      else
        Response.write ", " & vbcrlf
        allBankList = allBankList & ", " & vbcrlf
      end if
    next
    
    
    Response.write "  banks[" & Chr(34) & "bank=0" & Chr(34) & "]= new Array(" & vbcrlf
    Response.write "    " & Chr(34) & Chr(34) & ", " & Chr(34) & "All Branches" & Chr(34) & ", " & vbcrlf
    Response.write allBankList
    Response.write vbcrlf & "  );" & vbcrlf & vbcrlf
%>
    
    function changeBank(oList){
      var curform = oList.form; // get the containing form
      clearCombo(curform.branch); // clear the downstream list
      var newvalue = oList.name + "=" + oList.options[oList.selectedIndex].value;
      fillCombo(curform.branch, newvalue); // fill the downstream list
    
    }
    
    function clearCombo(oList){
      for (var i = oList.options.length - 1; i >= 0; i--){
        oList.options[i] = null;
      }
      oList.selectedIndex = -1;
    }
    function fillCombo(oList, vValue){
      if (vValue != "" && banks[vValue]){
        var arrX = banks[vValue];
        for (var i = 0; i < arrX.length; i = i + 2){
          oList.options[oList.options.length] = new Option(arrX[i + 1], arrX[i]);
        }
      } else oList.options[0] = new Option("None found", "");
    }

<%
    Response.write "</script>" & vbcrlf
    Response.write vbcrlf & vbcrlf
    
%>


<%
    Dim creditFlexFieldIdList, accountFlexFieldIdList, collateralFlexFieldIdList
	Dim securityConstraint
	Dim searchAccountQuery, searchAccountRS
	dim loginID
	loginID = session("userID")
	Set searchAccountRS = Server.CreateObject("ADODB.RecordSet")
	
	securityConstraint = ""
	if Not Session("isSuperUser") then
		securityConstraint = " AND uas.userAccountAccessId IS NOT NULL AND (uas.allowRead=1 Or uas.isAdmin=1)"
	end if
	
	searchAccountQuery = _
		" SELECT" & _
		"	ac.accountClassId," & _
		"	uas.accountClassCode," & _
		"	ac.accountClassName," & _
		"	lt.loanTypeId," & _
		"	lt.loanTypeDescription," & _
		"	uas.userAccountAccessId" & _
		" FROM" & _
		"	accountClass AS ac INNER JOIN loanType AS lt" & _
		"		ON ac.accountClassId=lt.accountClassId" & _
		"	LEFT OUTER JOIN userAccountSecurity AS uas" & _
		"		ON (uas.accountClassCode=ac.accountClassCode AND uas.userId=" & dbFormatId(Session("userId")) & ")" & _
    " WHERE 1=1 " & _
		securityConstraint & _
		" ORDER BY" & _
		"	ac.accountClassSortOrder," & _
		"	uas.accountClassCode," & _
		"	lt.loanTypeDescription "
	searchAccountRS.Open searchAccountQuery, db, adOpenStatic, adCmdText
	
	Dim searchAccountStatusQuery, searchAccountStatusRS
	Set searchAccountStatusRS = Server.CreateObject("ADODB.RecordSet")
	
	searchAccountStatusQuery = _
		" SELECT" & _
		"	ac.accountClassId," & _
		"	ac.accountClassName," & _
		"	ls.statusId," & _
		"	ls.statusDescription," & _
		"	uas.userAccountAccessId" & _
		" FROM" & _
		"	accountClass AS ac INNER JOIN loanStatus AS ls" & _
		"		ON ac.accountClassId=ls.accountClassId" & _
		"	LEFT OUTER JOIN userAccountSecurity AS uas" & _
		"		ON uas.accountClassCode=ac.accountClassCode" & _
		"		AND uas.userId=" & dbFormatId(Session("userId")) & _
    " WHERE ls.isApplicationStatus = 0 " & _
		securityConstraint & _
		" ORDER BY" & _
		"	ac.accountClassSortOrder," & _
		"	ls.statusDescription"
	searchAccountStatusRS.Open searchAccountStatusQuery, db, adOpenStatic, adCmdText
%>
<script type="text/javascript">
	var accountList = new Array();
	var accountTypeList = new Array();
	var accountStatusList = new Array();
<%
	' Write out accountClass and accountType arrays
	'
	accountIdx = 1
	accountTypeIdx = 1
	prevAccountClassId = ""
	accountClassCount = 0
	do until searchAccountRS.eof
		if searchAccountRS("accountClassId") <> prevAccountClassId then
			accountClassCount = accountClassCount + 1
			prevAccountClassId = searchAccountRS("accountClassId")
		end if
		
		searchAccountRS.MoveNext
	loop
	
	' The All option shows now regardless of how many accounts a user has access to.
  
	Response.write "accountList[0] = new Array('','All');" & vbcrlf
	
	Response.write "accountTypeList[0] = new Array('', '', '', 'All');" & vbcrlf
	
	searchAccountRS.Requery
	prevAccountClassId = ""
	do until searchAccountRS.eof
		if CStr(prevAccountClassId) <> CStr(searchAccountRS("accountClassId")) then
      Response.write "accountList[" & accountIdx & "] = new Array(" & _
				"'" & searchAccountRS("accountClassId") & "'," & _
				"'" & searchAccountRS("accountClassName") & "');" & vbcrlf
			prevAccountClassId = searchAccountRS("accountClassId")
			accountIdx = accountIdx + 1
		end if
		
		Response.write "accountTypeList[" & accountTypeIdx & "] = new Array(" & _
			"'" & searchAccountRS("accountClassId") & "'," & _
			"'" & searchAccountRS("accountClassName") & "'," & _
			"'" & searchAccountRS("loanTypeId") & "'," & _
			"'" & searchAccountRS("loanTypeDescription") & "');" & vbcrlf
		accountTypeIdx = accountTypeIdx + 1
		searchAccountRS.MoveNext
	loop
	
	
	' Write out list of Account Status array
	'
	accountStatusIdx = 1
	Response.write "accountStatusList[0] = new Array('', '', '', 'All');" & vbcrlf
	do until searchAccountStatusRS.eof
		Response.write "accountStatusList[" & accountStatusIdx & "] = new Array(" & _
			"'" & searchAccountStatusRS("accountClassId") & "'," & _
			"'" & searchAccountStatusRS("accountClassName") & "'," & _
			"'" & searchAccountStatusRS("statusId") & "'," & _
			"'" & StringToJSStringSQ(searchAccountStatusRS("statusDescription")) & "');" & vbcrlf
		accountStatusIdx = accountStatusIdx + 1
		searchAccountStatusRS.MoveNext
	loop
	
	searchAccountRS.Close
	searchAccountStatusRS.Close
%>
</script>


<%
Session("searchName") = ""
Session("searchCustomerNumber") = ""
Session("searchTaxId") = ""
Session("searchCustomerStatus") = ""
Session("searchLoan") = ""
Session("searchLoanStatus") = ""
Session("searchLoanType") = ""
Session("searchLoanOfficer") = ""
Session("searchbankId") = ""
Session("searchcustomerType") = ""
Session("searchFromLoanOrgDate") = ""
Session("searchToLoanOrgDate") = ""
Session("searchCustomerOfficer") = ""
Session("searchLoanDescription") = ""
Session("searchBranch") = ""

Dim bankmax : bankmax = int(Session("userbanklen"))
IF bankmax > 0 THEN banksecurity = Session("userbanks")
Dim datePickerIds : datePickerIds = ""
%>
<div id="aa-search-form-wrapper" class="aa-search-hide">
<% IF searchType <> "Standard" THEN %>
<div class="top">
    <h1>Customer and Account Selection: Step 1</h1>
</div>
<% END IF %>
<form id="aa-search-form" action="<%=nextSearchPage%>" name="frmSearch" method="post">
    <input type="hidden" name="searchType" value="<%=searchType%>"/>
    <div class="aa-search-wrapper">
        <table id="aa-search-table">
            <% IF searchType <> "Standard" THEN %>
                <tr>
                    <td>&nbsp;</td>
                    <td colspan="2"><%=searchTypeLabel%> Type Filter:</td>
                    <td>&nbsp;</td>
                    <td>
                        <ul class="vert-list">
                            <li><input type="radio" id="aa-search-credit-document" class="k-radio" name="documentFilter" value="C" checked="checked" /><label id="aa-search-credit-document-label" class="k-radio-label" for="aa-search-credit-document">Credit <%=searchTypeLabel%>s</label></li>
                            <li><input type="radio" id="aa-search-account-document" class="k-radio" name="documentFilter" value="L" /><label id="aa-search-account-document-label" class="k-radio-label" for="aa-search-account-document">Account/Collateral <%=searchTypeLabel%>s</label></li>
                        </ul>
                    </td>
                </tr>
            <% END IF %>
            <tr>
                <td colspan="5" class="sub-header top"><h1>Customer Search Fields</h1></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Name:</td>
                <td>&nbsp;</td>
                <td><input id="combo_zone_cname" name="name" autocomplete="off" style="width:300px" /></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Tax ID:</td>
                <td>&nbsp;</td>
                <td><input id="combo_zone_taxid" name="taxID" autocomplete="off" style="width:300px" /></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Number:</td>
                <td>&nbsp;</td>
                <td><input id="combo_zone_cnumber" name="customerID" autocomplete="off" style="width:300px" /></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Status:</td>
                <td>&nbsp;</td>
                <td><%
                Dim customerStatusRS : Set customerStatusRS = Server.CreateObject("ADODB.Recordset")
                Dim customerStatusQuery : customerStatusQuery = _
                    " SELECT *" & _
                    " FROM customerStatus" & _
                    " ORDER BY customerStatusDescription"
                customerStatusRS.Open customerStatusQuery, db, adOpenDynamic
                %><select id="aa-search-customer-status" name="searchcustomerStatus">
                <option value="">All</option><%
                WHILE NOT customerStatusRS.EOF
                    selected = ""
                    IF cStr(customerStatusRS("customerStatusId")) = Session("searchcustomerStatus") OR customerStatusRS("isDefault") THEN
                        selected = " selected=""selected"""
                    END IF
                    %><option value="<%=customerStatusRS("customerStatusId")%>"<%=selected%>><%=customerStatusRS("customerStatusDescription") %></option><%
                    customerStatusRS.MoveNext()
                WEND
                %></select></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Type:</td>
                <td>&nbsp;</td>
                <td><select id="aa-select-customer-type" name="customerType">
                <option value="" >All</option><%
                savedct = Session("searchCustomerType")
                DO UNTIL customerType.EOF
                    IF savedct = customerType("customerTypeId") THEN
                        htmloption = " selected=""selected"""
                    ELSE
                        htmloption = ""
                    END IF
                    %><option value="<%=customerType("customerTypeid")%>"<%=htmloption%>><%=customerType("customerTypeDescription")%></option><%
                    customerType.MoveNext
                LOOP
                %></select></td>
            </tr>
            <% savedco = Session("searchCustomerOfficer") %>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Officer:</td>
                <td>&nbsp;</td>
                <td><select id="aa-select-customer-officer" name="customerOfficer">
                <option value="">All</option>
                <option value="NULL"<% IF Trim(savedco) = "NULL" THEN %> selected="selected"<% END IF %>>Unassigned</option><%
                DO UNTIL lo.EOF
                    FOR i = 1 TO bankmax
                        IF banksecurity(i,1) = lo("bankid") THEN
                            IF savedco = lo("officerid") THEN
                                htmloption = " selected=""selected"""
                            ELSE
                                htmloption = ""
                            END IF
                            %><option value="<%=lo("officerid")%>"<%=htmloption%>><%=lo("officerName")%></option><%
                        END IF
                    NEXT
                    lo.MoveNext
                LOOP
                %></select></td>
            </tr>
            <tr>
                <% IF branchRows <= 1 THEN %>
                <td colspan="5">&nbsp; <input type="hidden" name="customerBranch" value=""/></td>
                <% ELSE %>
                <td>&nbsp;</td>
                <td colspan="2">Customer ( Region ) Branch:</td>
                <td>&nbsp;</td>
                <td><select id="aa-select-customer-branch" name="customerBranch">
                <option value="">All Branches</option><%
                FOR i = 0 TO branchRows-1
                   %><option value="<%=branchArray(2,i)%>">( <%=branchArray(4,i)%> ) <%=branchArray(3,i)%></option><%
                NEXT
                %></select></td>
                <% END IF ' ### IF branchRows = <1 %>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Credit Classification:</td>
                <td>&nbsp;</td>
                <td><input id="aa-search-select-classification" name="classificationId" value="" style=""/></td>
            </tr>
            <!-- BEGIN Credit Flex Field Block -->
            <%
            fieldDisplayState = Request.Cookies("creditsearchDisplayState")
            IF fieldDisplayState = "collapsed" THEN
                fieldDisplayClass = "aa-search-show"
            ELSE
                fieldDisplayClass = "aa-search-hide"
            END IF
	    
            hasSearchableFields = false
            FOR i = 0 TO g_creditFieldDefCount - 1
                IF g_creditFieldDefList(FIELD_DEF_SEARCHABLE, i) THEN
                    hasSearchableFields = true
                    EXIT FOR
                END IF
            NEXT
	    
            IF hasSearchableFields THEN
                %><tr class="aa-credit-flex-collapsed <%=fieldDisplayClass%>">
                    <td><i id="aa-expand-flex-credit" class="aa-icon fas fa-plus-square" aria-hidden="true" title="Expand Additional Customer Fields"></i></td>
                    <td colspan="4" id="aa-credit-flex-field-banner"><i>View Additional Customer Fields</i></td>
                </tr><%
		idx = 0
		groupIdx = 0 ' Keep count of displayed groups
		for i = 0 to g_creditFieldGroupCount - 1
			fieldDefGroupId = g_creditFieldGroupList(FDG_ID,i)
			fieldDefGroupLabel = g_creditFieldGroupList(FDG_LABEL,i)
			filedDefGroupName = g_creditFieldGroupList(FDG_NAME,i)
			fieldIdx = 0 ' Keep count of displayed fields

			for j = 0 to g_creditFieldDefCount - 1
				fieldLabel = g_creditFieldDefList(FIELD_DEF_LABEL, j)
				fieldName = g_creditFieldDefList(FIELD_DEF_NAME, j)
				fieldDataType = g_creditFieldDefList(FIELD_DEF_DATA_TYPE, j)
				fieldSearchable = g_creditFieldDefList(FIELD_DEF_SEARCHABLE, j)
				fieldChoiceList = g_creditFieldDefList(FIELD_DEF_CHOICE_LIST, j)
				fieldGroupId = g_creditFieldDefList(FIELD_DEF_GROUP_ID,j)

    IF fieldSearchable AND fieldGroupId = fieldDefGroupId THEN
        if fieldDisplayState = "collapsed" then
		    fieldDisplayClass = "aa-search-hide"
        else
            fieldDisplayClass = "aa-search-show"
	    end if
%>
    <tr class="aa-credit-flex-expanded <%= fieldDisplayClass %>">
<%      IF groupIdx = 0 THEN %><td><i id="aa-collapse-flex-credit" class="aa-icon fas fa-minus-square" aria-hidden="true" title="Collapse Additional Customer Fields"></i></td><% ELSE %><td>&nbsp;</td><% END IF %>
        <td><% IF fieldIdx = 0 THEN %><%=fieldDefGroupLabel%><% END IF %>&nbsp;</td>
        <td class="aa-search-flex-field-label"><label for="aa-chk-flex-<%=fieldName%>"><%=fieldLabel%>: &nbsp; &nbsp;</label><input type="checkbox" class="k-checkbox" id="aa-chk-flex-<%=fieldName%>" name="chk_flex_<%=fieldName%>" value="1" /><label class="k-checkbox-label" for="aa-chk-flex-<%=fieldName%>"></label></td>
        <td>&nbsp;</td>
        <td><%
        IF fieldDataType = "datetime" THEN
            datePickerIds = datePickerIds & "from-flex-" & fieldName & ","
            datePickerIds = datePickerIds & "to-flex-" & fieldName & ","
            %><ul class="aa-horizontal-list">
                <li><input
                    type="text"
                    name="from_flex_<%=fieldName%>"
                    id="from-flex-<%=fieldName%>"
                    data-type="date"
                    data-date-msg="Invalid 'from' date"
                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                    /></li>
                <li><b>to</b></li>
                <li><input
                    type="text"
                    name="to_flex_<%=fieldName%>"
                    id="to-flex-<%=fieldName%>"
                    data-type="date"
                    data-date-msg="Invalid 'to' date"
                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                    /></li>
                <li>
                    <div class="validator-msg">
                        <span class="k-invalid-msg" data-for="from_flex_<%=fieldName%>"></span>
                        <span class="k-invalid-msg" data-for="to_flex_<%=fieldName%>"></span>
                    </div>
                </li>
            </ul>
            <% ELSEIF fieldDataType = "int" OR fieldDataType = "decimal" OR fieldDataType = "money" THEN %>
            <input type="text" class="k-textbox range" name="from_flex_<%=fieldName%>" size="16" value="" />
            &nbsp; <b>to</b> &nbsp;
            <input type="text" class="k-textbox range" name="to_flex_<%=fieldName%>" size="16" value="" />
            <% ELSEIF fieldDataType = "bit" THEN %>
            <select id="aa-select-flex-<%=fieldName%>" name="flex_<%=fieldName%>">
                <option value="">Any</option>
                <option value="1">True</option>
                <option value="0">False</option>
            </select>
            <% ELSEIF fieldDataType = "choice" THEN %>
            <select id="aa-select-flex-<%=fieldName%>" name="flex_<%=fieldName%>">
            <% IF Trim(fieldChoiceList & "") <> "" THEN
                    Response.Write "<option value=""" & fieldChoiceList & """>All</option>" & vbCr
                    choiceList = Split(fieldChoiceList, "||")
                    FOR k = lBound(choiceList) TO uBound(choiceList)
                        Response.Write "<option value=""" & choiceList(k) & """>" & choiceList(k) & "</option>" & vbCr
                    NEXT
                ELSE
                    Response.Write "<option value="""">All</option>" & vbCr
                END IF
            %></select>
<%          ELSE %>
            <input type="text" class="k-textbox" name="flex_<%=fieldName%>" size="41" value="" />
            <% END IF %>
        </td>
    </tr>
<%
        IF fieldDataType = "choice" OR fieldDataType = "bit" THEN
            IF creditFlexFieldIdList = "" THEN
                creditFlexFieldIdList = "#aa-select-flex-" & fieldName
            ELSE
                creditFlexFieldIdList = creditFlexFieldIdList + ", #aa-select-flex-" & fieldName
            END IF
        END IF
        idx = idx + 1
        fieldIdx = fieldIdx + 1
    END IF 'fieldSearchable
    groupIdx = groupIdx + 1
    next 'j
    next 'i

end if 'hasSearchableFields
 %>

<!-- END Credit Flex Field Block -->

	
	<tr>
		<td colspan="5" class="sub-header"><h1>Account/Collateral Search Fields</h1></td>
	</tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account<% IF Session("enableLoanApprovalsYN") = "Y" THEN %> / Application<% END IF %> Number:</td>
        <td>&nbsp;</td>
        <td><input id="combo_zone_lnumber" name="loan" autocomplete="off" style="width:300px" /></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account / Collateral Description:</td>
        <td>&nbsp;</td>
        <td>
            <input type="text" class="k-textbox" name="loanDescription" size="40" value="<%=session("searchLoanDescription") %>">
        </td>
    </tr>
	
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account Class:</td>
        <td>&nbsp;</td>
        <td>
            <input id="aa-select-account-class" name="accountClassId" />
        </td>
    </tr>	
	
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account Type:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-account-type" name="loanType"></select>
        </td>
    </tr>
	
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account Status:</td>
        <td>&nbsp;</td>
        <td>
			<select id="aa-select-account-status" name="loanStatus"></select>
        </td>
    </tr>
	
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account Origination Date:</td>
        <td>&nbsp;</td>
        <%
        datePickerIds = datePickerIds & "from-org-date,"
        datePickerIds = datePickerIds & "to-org-date,"
        %>
        <td>
            <ul class="aa-horizontal-list">
                <li><input
                    type="text"
                    name="fromOrgDate"
                    id="from-org-date"
                    data-type="date"
                    data-date-msg="Invalid 'from' date"
                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                    /></li>
                <li><b>to</b></li>
                <li><input
                    type="text"
                    name="toOrgDate"
                    id="to-org-date"
                    data-type="date"
                    data-date-msg="Invalid 'to' date"
                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                    /></li>
                <li>
                    <div class="validator-msg">
                        <span class="k-invalid-msg" data-for="fromOrgDate"></span>
                        <span class="k-invalid-msg" data-for="toOrgDate"></span>
                    </div>
                </li>
            </ul>
        </td>
    </tr>
    <tr>
		<td>&nbsp;</td>
        <td colspan="2">Account Officer:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-account-officer" name="loanofficer">
                <option value="" >All</option>
<%
				savedlo = Session("searchLoanOfficer")
                lo.requery
				do until lo.eof
				   for i = 1 to bankmax
				      if banksecurity(i,1) = lo("bankid") then

						   if savedlo = lo("officerid") then
						      htmloption = " selected"
						   else
					   		   htmloption = ""
						   end if
%>
                <option value="<%= lo("officerid") %>" <%=htmloption%>><%= lo("officerName") %></option>
<%
						end if
					next
					lo.MoveNext
				loop
%>
            </select>
        </td>
    </tr>
    <tr>
<%  if branchRows <= 1 then %>
        <td colspan="5">&nbsp; <input type="hidden" name="loanBranch" value=""/></td>
<%  else %>
        <td>&nbsp;</td>
        <td colspan="2">Account ( Region ) Branch:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-account-branch" name="loanBranch">
                <option value="">All Branches</option>
<%
        for i = 0 to branchRows-1
%>
                <option value="<%=branchArray(2,i)%>">( <%=branchArray(4,i)%> ) <%=branchArray(3,i)%></option>
<%
        next
%>          
            </select>
        </td>
<%  end if 'branchRows = 1 %>
    </tr>  
  
    <% IF Session("acculoan.showParticipationLoan") = "1" THEN %>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Search Participation Loans Only?</td>
        <td>&nbsp;</td>
        <td><input type="checkbox" class="k-checkbox" name="searchParticipation" id="searchParticipation" value="1"/><label class="k-checkbox-label" for="searchParticipation"></label></td>
    </tr>
    <% END IF %>

<!-- BEGIN Account Flex Field Block -->

<%
	fieldDisplayState = Request.Cookies("accountsearchDisplayState")
    if fieldDisplayState = "collapsed" then
		fieldDisplayClass = "aa-search-show"
    else
        fieldDisplayClass = "aa-search-hide"
	end if
	
	hasSearchableFields = false
	for i = 0 to g_accountFieldDefCount - 1
		if g_accountFieldDefList(FIELD_DEF_SEARCHABLE, i) then
			hasSearchableFields = true
			exit for
		end if
	next 'i
	
	if hasSearchableFields then
%>
	<tr class="aa-account-flex-collapsed <%= fieldDisplayClass %>">
		<td><i id="aa-expand-flex-account" class="fas fa-plus-square" aria-hidden="true" title="Expand Additional Account Fields"></i></td>
		<td colspan="4" id="aa-account-flex-field-banner"><i>View Additional Account Fields</i></td>
	</tr>
<%
    idx = 0
    groupIdx = 0 ' Keep count of displayed groups
    if g_accountFieldDefCount > 0 And hasSearchableFields then
	    for i = 0 to g_accountFieldGroupCount - 1
		    fieldDefGroupId = g_accountFieldGroupList(FDG_ID,i)
		    fieldDefGroupLabel = g_accountFieldGroupList(FDG_LABEL,i)
		    filedDefGroupName = g_accountFieldGroupList(FDG_NAME,i)
		    fieldIdx = 0 ' Keep count of displayed fields
				
		    for j = 0 to g_accountFieldDefCount - 1
			    fieldLabel = g_accountFieldDefList(FIELD_DEF_LABEL, j)
			    fieldName = g_accountFieldDefList(FIELD_DEF_NAME, j)
			    fieldDataType = g_accountFieldDefList(FIELD_DEF_DATA_TYPE, j)
			    fieldSearchable = g_accountFieldDefList(FIELD_DEF_SEARCHABLE, j)
			    fieldChoiceList = g_accountFieldDefList(FIELD_DEF_CHOICE_LIST, j)
			    fieldGroupId = g_accountFieldDefList(FIELD_DEF_GROUP_ID,j)
					
			    if fieldSearchable And fieldGroupId = fieldDefGroupId  then
                    if fieldDisplayState = "collapsed" then
		                fieldDisplayClass = "aa-search-hide"
                    else
                        fieldDisplayClass = "aa-search-show"
	                end if
%>
	<tr class="aa-account-flex-expanded <%= fieldDisplayClass %>">
<%      IF groupIdx = 0 then %><td><i id="aa-collapse-flex-account" class="fas fa-minus-square" aria-hidden="true" title="Collapse Additional Account Fields"></i></td><% ELSE %><td>&nbsp;</td><% END IF %>
		<td><% IF fieldIdx = 0 then %><%=fieldDefGroupLabel%><% END IF %>&nbsp;</td>		
        <td class="aa-search-flex-field-label"><label for="aa-chk-flex-<%=fieldName%>"><%=fieldLabel%>: &nbsp; &nbsp;</label><input type="checkbox" class="k-checkbox" id="aa-chk-flex-<%=fieldName%>" name="chk_flex_<%=fieldName%>" value="1" /><label class="k-checkbox-label" for="aa-chk-flex-<%=fieldName%>"></label></td>
        <td>&nbsp;</td>
		<td>
        <% IF fieldDataType = "datetime" THEN
        datePickerIds = datePickerIds & "from-flex-" & fieldName & ","
        datePickerIds = datePickerIds & "to-flex-" & fieldName & ","
        %><ul class="aa-horizontal-list">
            <li><input
                type="text"
                name="from_flex_<%=fieldName%>"
                id="from-flex-<%=fieldName%>"
                data-type="date"
                data-date-msg="Invalid 'from' date"
                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                /></li>
            <li><b>to</b></li>
            <li><input
                type="text"
                name="to_flex_<%=fieldName%>"
                id="to-flex-<%=fieldName%>"
                data-type="date"
                data-date-msg="Invalid 'to' date"
                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                /></li>
            <li>
                <div class="validator-msg">
                    <span class="k-invalid-msg" data-for="from_flex_<%=fieldName%>"></span>
                    <span class="k-invalid-msg" data-for="to_flex_<%=fieldName%>"></span>
                </div>
            </li>
        </ul>
        <% ELSEIF fieldDataType = "int" Or fieldDataType = "decimal" Or fieldDataType = "money" then %>
			<input type="text" class="k-textbox range" name="from_flex_<%=fieldName%>" size="16" value="" />
			&nbsp; <b>to</b> &nbsp;
			<input type="text" class="k-textbox range" name="to_flex_<%=fieldName%>" size="16" value="" />
<%						elseif fieldDataType = "bit" then %>
			<select id="aa-select-flex-<%=fieldName%>" name="flex_<%=fieldName%>">
				<option value="">Any</option>
				<option value="1">True</option>
				<option value="0">False</option>
			</select>	
<%						elseif fieldDataType = "choice" then %>
			<select id="aa-select-flex-<%=fieldName%>" name="flex_<%=fieldName%>">
        <%
        IF Trim(fieldChoiceList & "") <> "" THEN
            Response.Write "<option value=""" & fieldChoiceList & """>All</option>" & vbCr
            choiceList = Split(fieldChoiceList, "||")
            FOR k = lBound(choiceList) TO uBound(choiceList)
                Response.Write "<option value=""" & choiceList(k) & """>" & choiceList(k) & "</option>" & vbCr
            NEXT
        ELSE
            Response.Write "<option value="""">All</option>" & vbCr
        END IF
        %></select>
        <% else %>
			<input type="text" class="k-textbox" name="flex_<%=fieldName%>" size="41" value="" />
        <%  end if %>
		</td>
	</tr>
<%
        IF fieldDataType = "choice" OR fieldDataType = "bit" THEN
            IF accountFlexFieldIdList = "" THEN
                accountFlexFieldIdList = "#aa-select-flex-" & fieldName
            ELSE
                accountFlexFieldIdList = accountFlexFieldIdList + ", #aa-select-flex-" & fieldName
            END IF
        END IF

        idx = idx + 1
        fieldIdx = fieldIdx + 1
    end if ' fieldSearchable 
%>

<%
					groupIdx = groupIdx + 1
				next 'j
			next 'i
		end if
%>
<%
	end if 'hasSearchableFields
%>

<!-- END Account Flex Field Block -->

<!-- BEGIN Collateral Flex Field Block -->

<%	
	fieldDisplayState = Request.Cookies("collateralsearchDisplayState")
    if fieldDisplayState = "collapsed" then
		fieldDisplayClass = "aa-search-show"
    else
        fieldDisplayClass = "aa-search-hide"
	end if
	
	hasSearchableFields = false
	
	if g_hasCollateralFieldDefList then
	  for i = 0 to g_collateralFieldDefCount - 1
		  if g_collateralFieldDefList(FIELD_DEF_SEARCHABLE, i) then
			  hasSearchableFields = true
			  exit for
		  end if
	  next 'i
	end if
	
	if hasSearchableFields then
%>
	<tr class="aa-collateral-flex-collapsed <%= fieldDisplayClass %>">
		<td><i id="aa-expand-flex-collateral" class="fas fa-plus-square" aria-hidden="true" title="Expand Additional Collateral Fields"></i></td>
		<td colspan="4" id="aa-collateral-flex-field-banner"><i>View Additional Collateral Fields</i></td>
	</tr>
<%
		idx = 0
		groupIdx = 0 ' Keep count of displayed groups
		if g_collateralFieldDefCount > 0 And hasSearchableFields then
			for i = 0 to g_collateralFieldGroupCount - 1
				fieldDefGroupId = g_collateralFieldGroupList(FDG_ID,i)
				fieldDefGroupLabel = g_collateralFieldGroupList(FDG_LABEL,i)
				filedDefGroupName = g_collateralFieldGroupList(FDG_NAME,i)
				fieldIdx = 0 ' Keep count of displayed fields
				
				for j = 0 to g_collateralFieldDefCount - 1
					fieldLabel = g_collateralFieldDefList(FIELD_DEF_LABEL, j)
					fieldName = g_collateralFieldDefList(FIELD_DEF_NAME, j)
					fieldDataType = g_collateralFieldDefList(FIELD_DEF_DATA_TYPE, j)
					fieldSearchable = g_collateralFieldDefList(FIELD_DEF_SEARCHABLE, j)
					fieldChoiceList = g_collateralFieldDefList(FIELD_DEF_CHOICE_LIST, j)
					fieldGroupId = g_collateralFieldDefList(FIELD_DEF_GROUP_ID,j)
					
					if fieldSearchable And fieldGroupId = fieldDefGroupId then
                        if fieldDisplayState = "collapsed" then
		                    fieldDisplayClass = "aa-search-hide"
                        else
                            fieldDisplayClass = "aa-search-show"
	                    end if
%>
	<tr class="aa-collateral-flex-expanded <%= fieldDisplayClass %>">
<%      IF groupIdx = 0 THEN %><td><i id="aa-collapse-flex-collateral" class="fas fa-minus-square" aria-hidden="true" title="Collapse Additional Customer Fields"></i></td><% else %><td>&nbsp;</td><% END IF%>
		<td><% IF fieldIdx = 0 THEN %><%=fieldDefGroupLabel%><% END IF %>&nbsp;</td>
		<td class="aa-search-flex-field-label"><label for="aa-chk-flex-<%=fieldName%>"><%=fieldLabel%>: &nbsp; &nbsp;</label><input type="checkbox" class="k-checkbox" id="aa-chk-flex-<%=fieldName%>" name="chk_flex_<%=fieldName%>" value="1" /><label class="k-checkbox-label" for="aa-chk-flex-<%=fieldName%>"></label></td>
		<td>&nbsp;</td>
		<td>
        <% IF fieldDataType = "datetime" THEN
        datePickerIds = datePickerIds & "from-flex-" & fieldName & ","
        datePickerIds = datePickerIds & "to-flex-" & fieldName & ","
        %><ul class="aa-horizontal-list">
            <li><input
                type="text"
                name="from_flex_<%=fieldName%>"
                id="from-flex-<%=fieldName%>"
                data-type="date"
                data-date-msg="Invalid 'from' date"
                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                /></li>
            <li><b>to</b></li>
            <li><input
                type="text"
                name="to_flex_<%=fieldName%>"
                id="to-flex-<%=fieldName%>"
                data-type="date"
                data-date-msg="Invalid 'to' date"
                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                /></li>
            <li>
                <div class="validator-msg">
                    <span class="k-invalid-msg" data-for="from_flex_<%=fieldName%>"></span>
                    <span class="k-invalid-msg" data-for="to_flex_<%=fieldName%>"></span>
                </div>
            </li>
        </ul>
        <% ELSEIF fieldDataType = "int" Or fieldDataType = "decimal" Or fieldDataType = "money" then %>
        <input type="text" class="k-textbox range" name="from_flex_<%=fieldName%>" size="16" value="" />
        &nbsp; <b>to</b> &nbsp;
        <input type="text" class="k-textbox range" name="to_flex_<%=fieldName%>" size="16" value="" />
        <% ELSEIF fieldDataType = "bit" then %>
        <select id="aa-select-flex-<%=fieldName%>" name="flex_<%=fieldName%>">
        <option value="">Any</option>
        <option value="1">True</option>
        <option value="0">False</option>
        </select>
        <% ELSEIF fieldDataType = "choice" THEN %>
			<select id="aa-select-flex-<%=fieldName%>" name="flex_<%=fieldName%>">
        <%
            IF Trim(fieldChoiceList & "") <> "" THEN
                Response.Write "<option value=""" & fieldChoiceList & """>All</option>" & vbCr
                choiceList = Split(fieldChoiceList, "||")
                FOR k = lBound(choiceList) TO uBound(choiceList)
                    Response.Write "<option value=""" & choiceList(k) & """>" & choiceList(k) & "</option>" & vbCr
                NEXT
            ELSE
                Response.Write "<option value="""">All</option>" & vbCr
            END IF
        %></select>
<%      ELSE %>
			<input type="text" class="k-textbox" name="flex_<%=fieldName%>" size="41" value="" />
<%      END IF %>
		</td>
	</tr>
<%
        IF fieldDataType = "choice" OR fieldDataType = "bit" THEN
            IF collateralFlexFieldIdList = "" THEN
                collateralFlexFieldIdList = "#aa-select-flex-" & fieldName
            ELSE
                collateralFlexFieldIdList = collateralFlexFieldIdList + ", #aa-select-flex-" & fieldName
            END IF
        END IF

        idx = idx + 1
        fieldIdx = fieldIdx + 1
    end if ' fieldSearchable
%>

<%
					groupIdx = groupIdx + 1
				next 'j
			next 'i
		end if
%>
<%	end if 'hasSearchableFields %>

<!-- END Collateral Flex Field Block -->	



  <!-- Approval search fields (2780) -->
    <% IF Session("enableLoanApprovalsYN") = "Y" THEN %>
    <tr>
		    <td colspan="5" class="sub-header"><h1>Approval Search Fields</h1></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Application Date:</td>
        <td>&nbsp;</td>
        <%
        datePickerIds = datePickerIds & "app-date-from,"
        datePickerIds = datePickerIds & "app-date-to,"
        %>
        <td>
            <ul class="aa-horizontal-list">
                <li><input
                    type="text"
                    name="appDateFrom"
                    id="app-date-from"
                    data-type="date"
                    data-date-msg="Invalid 'from' date"
                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                    /></li>
                <li>to</li>
                <li><input
                    type="text"
                    name="appDateTo"
                    id="app-date-to"
                    data-type="date"
                    data-date-msg="Invalid 'to' date"
                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                    /></li>
                <li>
                    <div class="validator-msg">
                        <span class="k-invalid-msg" data-for="appDateFrom"></span>
                        <span class="k-invalid-msg" data-for="appDateTo"></span>
                    </div>
                </li>
            </ul>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Assigned Lender:</td>
        <td>&nbsp;</td>
        <td><%
        Dim userGroupQuery, userGroupRS
        Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
        userGroupQuery = BuildUserGroupQuery("lender")
        userGroupRS.Open userGroupQuery, db, adOpenStatic, adCmdText
        %><select id="aa-select-assigned-lender" name="appLender">
        <option value=""></option><%
        userGroupRS.Requery
          do until userGroupRS.eof
          targetName	= userGroupRS("targetName")
          targetType	= userGroupRS("targetType")
          targetId1	= Left(targetType,1) & ":" & userGroupRS("targetId")
        lenderType = UCase(Left(targetType,1))
        %><option value="<%=targetId1%>"><%=targetName%></option><%
				userGroupRS.MoveNext()
        loop
        userGroupRS.Close()
        %></select></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Loan Delegate:</td>
        <td>&nbsp;</td>
        <td><%
        Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
        userGroupQuery = BuildUserGroupQuery("loanprocessor")
        userGroupRS.Open userGroupQuery, db, adOpenStatic, adCmdText
        %><select id="aa-select-app-delegate" name="appDelegate">
        <option value=""></option><%
        userGroupRS.Requery
          do until userGroupRS.eof
          targetName	= userGroupRS("targetName")
          targetType	= userGroupRS("targetType")
          targetId1	= Left(targetType,1) & ":" & userGroupRS("targetId")
        lenderType = UCase(Left(targetType,1))
        %><option value="<%=targetId1%>"><%=targetName%></option><%
				userGroupRS.MoveNext()
        loop
        userGroupRS.Close()
        %></select></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Assigned Analyst:</td>
        <td>&nbsp;</td>
        <td><%
        Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
        userGroupQuery = BuildUserGroupQuery("analyst")
        userGroupRS.Open userGroupQuery, db, adOpenStatic, adCmdText
        %><select id="aa-select-app-analyst" name="appAnalyst">
        <option value=""></option><%
		 	  userGroupRS.Requery
          do until userGroupRS.eof
          targetName	= userGroupRS("targetName")
          targetType	= userGroupRS("targetType")
          targetId1	= Left(targetType,1) & ":" & userGroupRS("targetId")
        lenderType = UCase(Left(targetType,1))
        %><option value="<%=targetId1%>"><%=targetName%></option><%
        userGroupRS.MoveNext()
        loop
        userGroupRS.Close()
        %></select></td>
    </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="2">Assigned Approver:</td>
        <td>&nbsp;</td>
        <td>
          <%
        Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
          userGroupQuery = BuildUserGroupQuery("approver")
          userGroupRS.Open userGroupQuery, db, adOpenStatic, adCmdText
          %><select id="aa-select-app-approver" name="appApprover">
            <option value=""></option><%
        userGroupRS.Requery
            do until userGroupRS.eof
            targetName	= userGroupRS("targetName")
            targetType	= userGroupRS("targetType")
            targetId1	= Left(targetType,1) & ":" & userGroupRS("targetId")
            lenderType = UCase(Left(targetType,1))
            %><option value="<%=targetId1%>"><%=targetName%>
            </option><%
				userGroupRS.MoveNext()
            loop
            userGroupRS.Close()
            %>
          </select>
        </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="2">Approval Status:</td>
        <td>&nbsp;</td>
        <td><%
        Dim applicationStatusQuery, applicationStatusRS, defaultapprovalstatus
        Set applicationStatusRS = Server.CreateObject("ADODB.RecordSet")
        applicationStatusQuery = _
            " SELECT " & _
            "   approvalStatusId, " & _
            "   approvalStatusDescription, " & _
            "   approvalStatusCode, " & _
            "   isDefault " & _
            " FROM " & _
            "   approvalStatus " & _
            " ORDER BY approvalStatusDescription"
        %><select id="aa-select-app-approval-status" name="approvalStatusId">
        <option value=""></option><%
        applicationStatusRS.Open applicationStatusQuery, db, adOpenStatic, adCmdText
        do until applicationStatusRS.eof
        %><option value="<%=applicationStatusRS("approvalStatusId")%>"><%=applicationStatusRS("approvalStatusDescription")%></option><%
				applicationStatusRS.MoveNext
        loop
        applicationStatusRS.Close
        %></select></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Application Status:</td>
        <td>&nbsp;</td>
        <td><select id="aa-select-app-status" name="loanStatusId">
        <option value=""></option>
        <%
        Dim appAdminStatusQuery, appAdminStatusRS
        Set appAdminStatusRS = Server.CreateObject("ADODB.RecordSet")
        appAdminStatusQuery = _
            " SELECT *" & _
            " FROM loanStatus" & _
            " WHERE isApplicationStatus=1" & _
            " ORDER BY statusDescription"
        appAdminStatusRS.Open appAdminStatusQuery, db, adOpenStatic, adCmdText
        do until appAdminStatusRS.eof
        optionSelected = ""
        if CStr(appAdminStatusRS("statusId")) = CStr(loanStatusId) then
        optionSelected = "selected=""true"""
        end if
        %><option value="<%=appAdminStatusRS("statusId")%>"><%=appAdminStatusRS("statusDescription")%></option><%
				appAdminStatusRS.MoveNext
        loop
        appAdminStatusRS.Close
        %></select></td>
    </tr>
    <% END IF ' ### IF Session("enableLoanApprovalsYN") = "Y" %>
    <!-- End Approval search fields (2780) //-->
   
<%
if bankmax = 1 then
%>
    <tr>
		<td colspan="5"><input type="hidden" name="bank" value="<%=banksecurity(1,1)%>"/></td>
	</tr>
<%
else
%>
	<tr><td colspan="5">&nbsp;</td></tr>
    <tr>
<%      if bankmax = 1 then %>
      <td colspan="5">&nbsp; <input type="hidden" name="bank" value="<%=bank("bankId")%>"/></td>
<%      else %>
	  <td>&nbsp;</td>
      <td colspan="2">Bank:</td>
	  <td>&nbsp;</td>
      <td>
		    <select name="bank" onchange="changeBank(this);">
          <option value="0">All Banks</option>
<%
					savedBankId = Session("searchBankId")
				    do until bank.eof
					   for i = 1 to bankmax
					       if bank("bankid") = banksecurity(i,1) then
							    if savedBankId = bank("bankid") then
				      				htmloption = " selected"
								else
							    	htmloption = ""
							    end if
						   
%>
					<option value="<%=bank("bankid")%>" <%=htmloption%>> <%= bank("bankName") %></option>	
<%
						   end if
						next
				    bank.MoveNext
					loop							   		   
%>				 
        </select>
      </td>
<%      end if 'bankmax = 1 %>
    </tr>
<% end if %>

    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Maximum Results Displayed:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-display-max-result" name="maxResult">
                <option value="250" >10 Pages</option>
                <option value="500" >20 Pages</option>
                <option value="10000000" >All Pages</option>
            </select>
        </td>
    </tr>
    <tr class="h30">
	  <td>&nbsp;</td>
      <td colspan="2">Display Document Status?</td>
	  <td>&nbsp;</td>
      <td>
        <input id="aa-search-display-documents" type="checkbox" class="k-checkbox" name="displayDocs" value="1"/>
        <label class="k-checkbox-label" for="aa-search-display-documents">Checking this may slow down the Search Results.</label>
      </td>
    </tr>
    </table>
    </div>
    <div class="aa-button-wrapper-left">
        <ul>
            <li><button type="submit" class="k-button k-primary">Search</button></li>
            <li><button id="aa-search-button-clear" type="button" class="k-button">Clear</button></li>
        </ul>
    </div>
    <input type="hidden" name="searchPageSize" value="25" />  
    </form>
</div>
