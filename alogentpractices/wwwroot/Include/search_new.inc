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
<!--
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
-->
@{
    // Fake data for demonstration. Replace this with your actual data
    var branchRows = 4; 
    var branchArray = new string[,] {
        { "1", "1", "101", "Branch A" },
        { "1", "1", "102", "Branch B" },
        { "2", "2", "201", "Branch C" },
        { "2", "2", "202", "Branch D" }
    };

    var banks = new Dictionary<string, List<KeyValuePair<string, string>>>();
    string lastBankId = "";
    var allBankList = new List<KeyValuePair<string, string>>();

    for (int i = 0; i < branchRows; i++)
    {
        string bankId = branchArray[0, i];

        if (lastBankId != bankId)
        {
            banks["bank=" + bankId] = new List<KeyValuePair<string, string>> {
                new KeyValuePair<string, string>("", ""),
                new KeyValuePair<string, string>("", "All Branches")
            };
            lastBankId = bankId;
        }

        banks["bank=" + bankId].Add(new KeyValuePair<string, string>(branchArray[2, i], branchArray[3, i]));
        allBankList.Add(new KeyValuePair<string, string>(branchArray[2, i], branchArray[3, i]));
    }
    banks["bank=0"] = new List<KeyValuePair<string, string>> {
        new KeyValuePair<string, string>("", ""),
        new KeyValuePair<string, string>("", "All Branches")
    };
    banks["bank=0"].AddRange(allBankList);

    // Serialize banks to JavaScript using JSON
    var banksJson = System.Text.Json.JsonSerializer.Serialize(banks);
}

<script type="text/javascript">
    // Deserialize banks from Razor variable
    var banks = @Html.Raw(banksJson);

    function changeBank(oList){
      var curform = oList.form;
      clearCombo(curform.branch); 
      var newvalue = oList.name + "=" + oList.options[oList.selectedIndex].value;
      fillCombo(curform.branch, newvalue);
    }

    function clearCombo(oList){
      for (var i = oList.options.length - 1; i >= 0; i--){
        oList.options[i] = null;
      }
      oList.selectedIndex = -1;
    }

    function fillCombo(oList, vValue){
      if (vValue !== "" && banks[vValue]){
        var arrX = banks[vValue];
        for (var i = 0; i < arrX.length; i++){
          // arrX[i][0] is branch code, arrX[i][11] is branch name
          oList.options[oList.options.length] = new Option(arrX[i][11], arrX[i]);
        }
      } else {
        oList.options = new Option("None found", "");
      }
    }
</script>
<!--
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
-->
@{
    // Define necessary variables
    List<int> creditFlexFieldIdList;
    List<int> accountFlexFieldIdList;
    List<int> collateralFlexFieldIdList;
    string securityConstraint = "";
    string searchAccountQuery;
    string loginID = Session["userID"]?.ToString();

    // Setup securityConstraint based on user role
    if (!(Session["isSuperUser"] as bool? ?? false))
    {
        securityConstraint = " AND uas.userAccountAccessId IS NOT NULL AND (uas.allowRead=1 Or uas.isAdmin=1)";
    }

    // Prepare SQL query for account and loan type
    searchAccountQuery = @"
        SELECT
            ac.accountClassId,
            uas.accountClassCode,
            ac.accountClassName,
            lt.loanTypeId,
            lt.loanTypeDescription,
            uas.userAccountAccessId
        FROM
            accountClass AS ac INNER JOIN loanType AS lt
                ON ac.accountClassId=lt.accountClassId
            LEFT OUTER JOIN userAccountSecurity AS uas
                ON (uas.accountClassCode=ac.accountClassCode AND uas.userId = @userId)
        WHERE 1=1" + securityConstraint + @"
        ORDER BY
            ac.accountClassSortOrder,
            uas.accountClassCode,
            lt.loanTypeDescription";

    // Execute query: replace with your ORM/data access code (e.g. Entity Framework, Dapper)
    var searchAccountRS = Database.SqlQuery<AccountRecord>(searchAccountQuery, new SqlParameter("@userId", loginID));

    // Prepare SQL query for account status and loan status
    string searchAccountStatusQuery = @"
        SELECT
            ac.accountClassId,
            ac.accountClassName,
            ls.statusId,
            ls.statusDescription,
            uas.userAccountAccessId
        FROM
            accountClass AS ac INNER JOIN loanStatus AS ls
                ON ac.accountClassId=ls.accountClassId
            LEFT OUTER JOIN userAccountSecurity AS uas
                ON uas.accountClassCode=ac.accountClassCode
                AND uas.userId=@userId
        WHERE ls.isApplicationStatus = 0" + securityConstraint + @"
        ORDER BY
            ac.accountClassSortOrder,
            ls.statusDescription";

    var searchAccountStatusRS = Database.SqlQuery<StatusRecord>(searchAccountStatusQuery, new SqlParameter("@userId", loginID));
}

<!--
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
-->


<script type="text/javascript">
    // Account and Type arrays
    var accountList = [];
    var accountTypeList = [];
    var accountStatusList = [];

    // The 'All' options
    accountList[0] = ['', 'All'];
    accountTypeList = ['', '', '', 'All'];
    accountStatusList = ['', '', '', 'All'];

    // Find unique account class entries for accountList
    @{
        var accountIdx = 1;
        string prevAccountClassId = "";
        foreach (var acct in Model.AccountClassTypes.OrderBy(a => a.AccountClassId))
        {
            if (acct.AccountClassId != prevAccountClassId)
            {
                <text>
    accountList[@(accountIdx)] = ['@(acct.AccountClassId)', '@(acct.AccountClassName)'];
                </text>
                prevAccountClassId = acct.AccountClassId;
                accountIdx++;
            }
        }
    }

    // Populate accountTypeList
    @{
        var accountTypeIdx = 1;
        foreach (var acct in Model.AccountClassTypes)
        {
            <text>
    accountTypeList[@(accountTypeIdx)] = [
        '@(acct.AccountClassId)', 
        '@(acct.AccountClassName)', 
        '@(acct.LoanTypeId)', 
        '@(acct.LoanTypeDescription)'
    ];
            </text>
            accountTypeIdx++;
        }
    }

    // Populate accountStatusList
    @{
        var accountStatusIdx = 1;
        foreach (var stat in Model.AccountStatusTypes)
        {
            <text>
    accountStatusList[@(accountStatusIdx)] = [
        '@(stat.AccountClassId)', 
        '@(stat.AccountClassName)', 
        '@(stat.StatusId)', 
        '@(stat.StatusDescription.Replace("'", "\\'"))'
    ];
            </text>
            accountStatusIdx++;
        }
    }
</script>
<!-- Search Form Initialization -->
<!--
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
-->
@{
    // Initialize session variables to empty strings
    Session["searchName"] = "";
    Session["searchCustomerNumber"] = "";
    Session["searchTaxId"] = "";
    Session["searchCustomerStatus"] = "";
    Session["searchLoan"] = "";
    Session["searchLoanStatus"] = "";
    Session["searchLoanType"] = "";
    Session["searchLoanOfficer"] = "";
    Session["searchbankId"] = "";
    Session["searchcustomerType"] = "";
    Session["searchFromLoanOrgDate"] = "";
    Session["searchToLoanOrgDate"] = "";
    Session["searchCustomerOfficer"] = "";
    Session["searchLoanDescription"] = "";
    Session["searchBranch"] = "";

    int bankmax = 0;
    if (Session["userbanklen"] != null)
    {
        int.TryParse(Session["userbanklen"].ToString(), out bankmax);
    }

    string banksecurity = "";
    if (bankmax > 0 && Session["userbanks"] != null)
    {
        banksecurity = Session["userbanks"].ToString();
    }

    string datePickerIds = "";
}

<div id="aa-search-form-wrapper" class="aa-search-hide">
    @if (!string.Equals(searchType, "Standard", StringComparison.OrdinalIgnoreCase))
    {
        <div class="top">
            <h1>Customer and Account Selection: Step 1</h1>
        </div>
    }
</div>


<!--<form id="aa-search-form" action="<%=nextSearchPage%>" name="frmSearch" method="post">--> 
<form id="aa-search-form" name="frmSearch" method="post" action="@nextSearchPage">
    <!--<input type="hidden" name="searchType" value="<%=searchType%>"/>-->
     <input type="hidden" name="searchType" value="@searchType"/>
    <div class="aa-search-wrapper">
        <table id="aa-search-table">
        <!--
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
            -->
            @if (!string.Equals(searchType, "Standard", StringComparison.OrdinalIgnoreCase))
            {
                <tr>
                    <td>&nbsp;</td>
                    <td colspan="2">@searchTypeLabel Type Filter:</td>
                    <td>&nbsp;</td>
                    <td>
                        <ul class="vert-list">
                            <li>
                                <input type="radio" id="aa-search-credit-document" class="k-radio" name="documentFilter" value="C" checked="checked" />
                                <label id="aa-search-credit-document-label" class="k-radio-label" for="aa-search-credit-document">
                                    Credit @searchTypeLabel@s
                                </label>
                            </li>
                            <li>
                                <input type="radio" id="aa-search-account-document" class="k-radio" name="documentFilter" value="L" />
                                <label id="aa-search-account-document-label" class="k-radio-label" for="aa-search-account-document">
                                    Account/Collateral @searchTypeLabel@s
                                </label>
                            </li>
                        </ul>
                    </td>
                </tr>
            }

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
            <!-- Customer Status and Type Selection -->
            <!--
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
            -->
          

            <tr>
                <td>&nbsp;</td>
                <td colspan="2">Customer Status:</td>
                <td>&nbsp;</td>
                <td>
                    <select id="aa-search-customer-status" name="searchcustomerStatus">
                        <option value="">All</option>
                        @foreach (var status in Model.CustomerStatusList)
                        {
                            var selected = (status.CustomerStatusId == Model.SelectedCustomerStatus || status.IsDefault) ? "selected" : "";
                            <option value="@status.CustomerStatusId" @selected>@status.CustomerStatusDescription</option>
                        }
                    </select>
                </td>
            </tr>

            <!--
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
            -->
           

<tr>
    <td>&nbsp;</td>
    <td colspan="2">Customer Type:</td>
    <td>&nbsp;</td>
    <td>
        <select id="aa-select-customer-type" name="customerType">
            <option value="">All</option>
            @foreach (var item in Model.CustomerTypeList)
            {
                var selected = (item.CustomerTypeId == Model.SelectedCustomerType) ? "selected" : "";
                <option value="@item.CustomerTypeId" @selected>@item.CustomerTypeDescription</option>
            }
        </select>
    </td>
</tr>
 var savedco = Session["searchCustomerOfficer"]?.ToString() ?? "";
 <!-- Customer Officer Selection -->
 <!--
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
            -->
            @model MyViewModel

@{
    var savedco = Model.SavedCustomerOfficer ?? "";
    var bankmax = Model.BankMax; // assuming int
    var banksecurity = Model.BankSecurity; // assuming a list or array of bank info
    var loList = Model.LoanOfficers; // list of officers with properties OfficerId, OfficerName, BankId
    var branchRows = Model.BranchRows; // int representing number of branches
    var branchArray = Model.BranchArray; // a collection/array of branch info
}

<tr>
    <td>&nbsp;</td>
    <td colspan="2">Customer Officer:</td>
    <td>&nbsp;</td>
    <td>
        <select id="aa-select-customer-officer" name="customerOfficer">
            <option value="">All</option>
            <option value="NULL" @(savedco.Trim() == "NULL" ? "selected=\"selected\"" : "")>Unassigned</option>
            @foreach (var lo in loList)
            {
                if (banksecurity.Any(b => b.BankId == lo.BankId)) // example condition
                {
                    var htmloption = (savedco == lo.OfficerId) ? "selected=\"selected\"" : "";
                    <option value="@lo.OfficerId" @Html.Raw(htmloption)>@lo.OfficerName</option>
                }
            }
        </select>
    </td>
</tr>

<tr>
    @if (branchRows <= 1)
    {
        <td colspan="5">&nbsp;<input type="hidden" name="customerBranch" value="" /></td>
    }
    else
    {
        <td>&nbsp;</td>
        <td colspan="2">Customer ( Region ) Branch:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-customer-branch" name="customerBranch">
                <option value="">All Branches</option>
                @for (int i = 0; i < branchRows; i++)
                {
                    <option value="@branchArray[i].Id">( @branchArray[i].Code ) @branchArray[i].Name</option>
                }
            </select>
        </td>
    }
</tr>

<tr>
    <td>&nbsp;</td>
    <td colspan="2">Credit Classification:</td>
    <td>&nbsp;</td>
    <td><input id="aa-search-select-classification" name="classificationId" value="" style="" /></td>
</tr>

            <!-- BEGIN Credit Flex Field Block -->
            <!--
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
-->
@{
    // Read cookie value
    var fieldDisplayState = Request.Cookies["creditsearchDisplayState"];
    var fieldDisplayClass = (fieldDisplayState == "collapsed") ? "aa-search-show" : "aa-search-hide";

    bool hasSearchableFields = false;

    // Assume g_creditFieldDefList is a list of some FieldDef objects accessible in the model or viewbag
    for (int i = 0; i < g_creditFieldDefCount; i++)
    {
        if (g_creditFieldDefList[i].Searchable)  // PROPERTY names replaced by PascalCase properties
        {
            hasSearchableFields = true;
            break;
        }
    }
}

@if (hasSearchableFields)
{
    <tr class="aa-credit-flex-collapsed @fieldDisplayClass">
        <td>
            <i id="aa-expand-flex-credit" class="aa-icon fas fa-plus-square" aria-hidden="true" title="Expand Additional Customer Fields"></i>
        </td>
        <td colspan="4" id="aa-credit-flex-field-banner">
            <i>View Additional Customer Fields</i>
        </td>
    </tr>
}

@{
    var idx = 0;
    var groupIdx = 0; // Keep count of displayed groups

    for (int i = 0; i < g_creditFieldGroupCount; i++)
    {
        var fieldDefGroupId = g_creditFieldGroupList[i].Id;       // Adjust property names as needed
        var fieldDefGroupLabel = g_creditFieldGroupList[i].Label;
        var filedDefGroupName = g_creditFieldGroupList[i].Name;
        var fieldIdx = 0; // Keep count of displayed fields

        for (int j = 0; j < g_creditFieldDefCount; j++)
        {
            var fieldLabel = g_creditFieldDefList[j].Label;
            var fieldName = g_creditFieldDefList[j].Name;
            var fieldDataType = g_creditFieldDefList[j].DataType;
            var fieldSearchable = g_creditFieldDefList[j].Searchable;
            var fieldChoiceList = g_creditFieldDefList[j].ChoiceList;
            var fieldGroupId = g_creditFieldDefList[j].GroupId;

            if (fieldSearchable && fieldGroupId == fieldDefGroupId)
            {
                string currentFieldDisplayClass = (fieldDisplayState == "collapsed") ? "aa-search-hide" : "aa-search-show";

                // Your rendering logic goes here...
            }
        }
    }
}

<!--
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
    -->
    @{
    // Variables assumed declared and populated previously:
    // int groupIdx, fieldIdx, idx;
    // string fieldDisplayClass, fieldDefGroupLabel, fieldName, fieldLabel, fieldDataType, fieldChoiceList;
    // System.Text.StringBuilder creditFlexFieldIdList = new System.Text.StringBuilder();
    // string datePickerIds = "";  // should be declared outside loop to accumulate
}

<tr class="aa-credit-flex-expanded @fieldDisplayClass">
    <td>
        @(groupIdx == 0
            ? new HtmlString(@"<i id=""aa-collapse-flex-credit"" class=""aa-icon fas fa-minus-square"" aria-hidden=""true"" title=""Collapse Additional Customer Fields""></i>")
            : (new HtmlString("&nbsp;"))
        )
    </td>
    <td>
        @(fieldIdx == 0 ? fieldDefGroupLabel : "")&nbsp;
    </td>
    <td class="aa-search-flex-field-label">
        <label for="aa-chk-flex-@fieldName">@fieldLabel:&nbsp;&nbsp;</label>
        <input type="checkbox" class="k-checkbox" id="aa-chk-flex-@fieldName" name="chk_flex_@fieldName" value="1" />
        <label class="k-checkbox-label" for="aa-chk-flex-@fieldName"></label>
    </td>
    <td>&nbsp;</td>
    <td>
        @switch (fieldDataType.ToLower())
        {
            case "datetime":
                {
                    datePickerIds += $"from-flex-{fieldName},to-flex-{fieldName},";
                    <ul class="aa-horizontal-list">
                        <li>
                            <input type="text" name="from_flex_@fieldName" id="from-flex-@fieldName" data-type="date"
                                   data-date-msg="Invalid 'from' date"
                                   data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                   data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                        </li>
                        <li><b>to</b></li>
                        <li>
                            <input type="text" name="to_flex_@fieldName" id="to-flex-@fieldName" data-type="date"
                                   data-date-msg="Invalid 'to' date"
                                   data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                   data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                        </li>
                        <li>
                            <div class="validator-msg">
                                <span class="k-invalid-msg" data-for="from_flex_@fieldName"></span>
                                <span class="k-invalid-msg" data-for="to_flex_@fieldName"></span>
                            </div>
                        </li>
                    </ul>
                    break;
                }
            case "int":
            case "decimal":
            case "money":
                {
                    <input type="text" class="k-textbox range" name="from_flex_@fieldName" size="16" value="" />&nbsp;
                    <b>to</b>&nbsp;
                    <input type="text" class="k-textbox range" name="to_flex_@fieldName" size="16" value="" />
                    break;
                }
            case "bit":
                {
                    <select id="aa-select-flex-@fieldName" name="flex_@fieldName">
                        <option value="">Any</option>
                        <option value="1">True</option>
                        <option value="0">False</option>
                    </select>
                    break;
                }
            case "choice":
                {
                    <select id="aa-select-flex-@fieldName" name="flex_@fieldName">
                        @if (!string.IsNullOrWhiteSpace(fieldChoiceList))
                        {
                            var choiceList = fieldChoiceList.Split(new string[] { "||" }, StringSplitOptions.RemoveEmptyEntries);
                            <option value="@fieldChoiceList">All</option>
                            @foreach (var choice in choiceList)
                            {
                                <option value="@choice">@choice</option>
                            }
                        }
                        else
                        {
                            <option value="">All</option>
                        }
                    </select>
                    break;
                }
            default:
                {
                    <input type="text" class="k-textbox" name="flex_@fieldName" size="41" value="" />
                    break;
                }
        }
    </td>
</tr>

@{
    if (fieldDataType == "choice" || fieldDataType == "bit")
    {
        if (creditFlexFieldIdList.Length == 0)
        {
            creditFlexFieldIdList.Append($"#aa-select-flex-{fieldName}");
        }
        else
        {
            creditFlexFieldIdList.Append($", #aa-select-flex-{fieldName}");
        }
    }
    idx++;
    fieldIdx++;
}

// Note: Increment groupIdx and loop handling should be done in your outer loops as per original code.

<!--
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
 -->
 @{
    // Assuming creditFlexFieldIdList is a StringBuilder declared outside this snippet
    if (fieldDataType == "choice" || fieldDataType == "bit")
    {
        if (creditFlexFieldIdList.Length == 0)
        {
            creditFlexFieldIdList.Append($"#aa-select-flex-{fieldName}");
        }
        else
        {
            creditFlexFieldIdList.Append($", #aa-select-flex-{fieldName}");
        }
    }

    idx++;
    fieldIdx++;
}
 groupIdx++;


<!-- END Credit Flex Field Block -->

	
	<tr>
		<td colspan="5" class="sub-header"><h1>Account/Collateral Search Fields</h1></td>
	</tr>
    <tr>
        <td>&nbsp;</td>
      <!--  <td colspan="2">Account<% IF Session("enableLoanApprovalsYN") = "Y" THEN %> / Application<% END IF %> Number:</td> -->
        <td colspan="2">
            Account@if (Session["enableLoanApprovalsYN"]?.ToString() == "Y")
            {
                @: / Application
            }
            Number:
        </td>
        <td>&nbsp;</td>
        <td><input id="combo_zone_lnumber" name="loan" autocomplete="off" style="width:300px" /></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Account / Collateral Description:</td>
        <td>&nbsp;</td>
        <td>
          <!--  <input type="text" class="k-textbox" name="loanDescription" size="40" value="<%=session("searchLoanDescription") %>"> -->
            <input type="text" class="k-textbox" name="loanDescription" size="40" 
                value="@(HttpContext.Session.GetString("searchLoanDescription") ?? "")" />

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
                <!--
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
-->
@{
    var savedlo = Model.SelectedLoanOfficer; // passed from controller
    var bankmax = Model.BankMax;
    var banksecurity = Model.BankSecurity;  // Assume list or array of banks user has access to
    var loanOfficers = Model.LoanOfficers;  // List of loan officers with OfficerId, OfficerName, BankId
}

<select name="loanOfficer" id="loanOfficer">
    @foreach (var lo in loanOfficers)
    {
        // Check if the current loan officer's bankid exists in banksecurity
        bool hasAccess = banksecurity.Any(b => b.BankId == lo.BankId);

        if (hasAccess)
        {
            var selected = (savedlo == lo.OfficerId) ? "selected" : "";
            <option value="@lo.OfficerId" @selected>@lo.OfficerName</option>
        }
    }
</select>

          
        </td>
    </tr>
    <!-- Branch Region Selection -->
    <!--
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
  -->
  <tr>
    @if (branchRows <= 1)
    {
        <td colspan="5">&nbsp;<input type="hidden" name="loanBranch" value="" /></td>
    }
    else
    {
        <td>&nbsp;</td>
        <td colspan="2">Account ( Region ) Branch:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-account-branch" name="loanBranch">
                <option value="">All Branches</option>
                @for (int i = 0; i < branchRows; i++)
                {
                    <option value="@branchArray[i].Id">( @branchArray[i].Code ) @branchArray[i].Name</option>
                }
            </select>
        </td>
    }
</tr>
   <!-- <% IF Session("acculoan.showParticipationLoan") = "1" THEN %> -->
    @if (Session["acculoan.showParticipationLoan"]?.ToString() == "1")
{
     <tr>
        <td>&nbsp;</td>
        <td colspan="2">Search Participation Loans Only?</td>
        <td>&nbsp;</td>
        <td><input type="checkbox" class="k-checkbox" name="searchParticipation" id="searchParticipation" value="1"/><label class="k-checkbox-label" for="searchParticipation"></label></td>
    </tr>
}
  
   <!-- <% END IF %> -->

<!-- BEGIN Account Flex Field Block -->

<!--
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
-->
@{
    var fieldDisplayState = Request.Cookies["accountsearchDisplayState"];
    var fieldDisplayClassCollapsed = (fieldDisplayState == "collapsed") ? "aa-search-show" : "aa-search-hide";

    bool hasSearchableFields = false;
    for (int i = 0; i < g_accountFieldDefCount; i++)
    {
        if (g_accountFieldDefList[i].Searchable) // Adjust property name accordingly
        {
            hasSearchableFields = true;
            break;
        }
    }

    int idx = 0;
    int groupIdx = 0;
}

@if (hasSearchableFields)
{
    <tr class="aa-account-flex-collapsed @fieldDisplayClassCollapsed">
        <td><i id="aa-expand-flex-account" class="fas fa-plus-square" aria-hidden="true" title="Expand Additional Account Fields"></i></td>
        <td colspan="4" id="aa-account-flex-field-banner"><i>View Additional Account Fields</i></td>
    </tr>

    @if (g_accountFieldDefCount > 0)
    {
        for (int i = 0; i < g_accountFieldGroupCount; i++)
        {
            var fieldDefGroupId = g_accountFieldGroupList[i].Id;
            var fieldDefGroupLabel = g_accountFieldGroupList[i].Label;
            var filedDefGroupName = g_accountFieldGroupList[i].Name;
            int fieldIdx = 0;

            for (int j = 0; j < g_accountFieldDefCount; j++)
            {
                var fieldLabel = g_accountFieldDefList[j].Label;
                var fieldName = g_accountFieldDefList[j].Name;
                var fieldDataType = g_accountFieldDefList[j].DataType.ToLower();
                var fieldSearchable = g_accountFieldDefList[j].Searchable;
                var fieldChoiceList = g_accountFieldDefList[j].ChoiceList;
                var fieldGroupId = g_accountFieldDefList[j].GroupId;

                if (fieldSearchable && fieldGroupId == fieldDefGroupId)
                {
                    string fieldDisplayClass = (fieldDisplayState == "collapsed") ? "aa-search-hide" : "aa-search-show";

                    <tr class="aa-account-flex-expanded @fieldDisplayClass">
                        <td>
                            @(groupIdx == 0
                                ? new HtmlString(@"<i id=""aa-collapse-flex-account"" class=""fas fa-minus-square"" aria-hidden=""true"" title=""Collapse Additional Account Fields""></i>")
                                : new HtmlString("&nbsp;"))
                        </td>
                        <td>@(fieldIdx == 0 ? fieldDefGroupLabel : "")&nbsp;</td>
                        <td class="aa-search-flex-field-label">
                            <label for="aa-chk-flex-@fieldName">@fieldLabel:&nbsp;&nbsp;</label>
                            <input type="checkbox" class="k-checkbox" id="aa-chk-flex-@fieldName" name="chk_flex_@fieldName" value="1" />
                            <label class="k-checkbox-label" for="aa-chk-flex-@fieldName"></label>
                        </td>
                        <td>&nbsp;</td>
                        <td>
                            @switch (fieldDataType)
                            {
                                case "datetime":
                                    {
                                        datePickerIds += $"from-flex-{fieldName},to-flex-{fieldName},";

                                        <ul class="aa-horizontal-list">
                                            <li>
                                                <input type="text" name="from_flex_@fieldName" id="from-flex-@fieldName" data-type="date"
                                                       data-date-msg="Invalid 'from' date"
                                                       data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                                       data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                                            </li>
                                            <li><b>to</b></li>
                                            <li>
                                                <input type="text" name="to_flex_@fieldName" id="to-flex-@fieldName" data-type="date"
                                                       data-date-msg="Invalid 'to' date"
                                                       data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                                       data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                                            </li>
                                            <li>
                                                <div class="validator-msg">
                                                    <span class="k-invalid-msg" data-for="from_flex_@fieldName"></span>
                                                    <span class="k-invalid-msg" data-for="to_flex_@fieldName"></span>
                                                </div>
                                            </li>
                                        </ul>
                                        break;
                                    }
                                case "int":
                                case "decimal":
                                case "money":
                                    {
                                        <input type="text" class="k-textbox range" name="from_flex_@fieldName" size="16" value="" />
                                        &nbsp; <b>to</b> &nbsp;
                                        <input type="text" class="k-textbox range" name="to_flex_@fieldName" size="16" value="" />
                                        break;
                                    }
                                case "bit":
                                    {
                                        <select id="aa-select-flex-@fieldName" name="flex_@fieldName">
                                            <option value="">Any</option>
                                            <option value="1">True</option>
                                            <option value="0">False</option>
                                        </select>
                                        break;
                                    }
                                case "choice":
                                    {
                                        <select id="aa-select-flex-@fieldName" name="flex_@fieldName">
                                            @if (!string.IsNullOrWhiteSpace(fieldChoiceList))
                                            {
                                                var choiceList = fieldChoiceList.Split(new string[] { "||" }, StringSplitOptions.RemoveEmptyEntries);
                                                <option value="@fieldChoiceList">All</option>
                                                @foreach (var choice in choiceList)
                                                {
                                                    <option value="@choice">@choice</option>
                                                }
                                            }
                                            else
                                            {
                                                <option value="">All</option>
                                            }
                                        </select>
                                        break;
                                    }
                                default:
                                    {
                                        <input type="text" class="k-textbox" name="flex_@fieldName" size="41" value="" />
                                        break;
                                    }
                            }
                        </td>
                    </tr>

                    if (fieldDataType == "choice" || fieldDataType == "bit")
                    {
                        if (string.IsNullOrEmpty(accountFlexFieldIdList))
                        {
                            accountFlexFieldIdList = $"#aa-select-flex-{fieldName}";
                        }
                        else
                        {
                            accountFlexFieldIdList += $", #aa-select-flex-{fieldName}";
                        }
                    }
                    idx++;
                    fieldIdx++;
                }
                groupIdx++;
            }
        }
    }
}

<!-- END Account Flex Field Block -->

<!-- BEGIN Collateral Flex Field Block -->
<!--
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
-->
@{
    var fieldDisplayState = Request.Cookies["collateralsearchDisplayState"];
    string fieldDisplayClass = (fieldDisplayState == "collapsed") ? "aa-search-show" : "aa-search-hide";

    bool hasSearchableFields = false;
    if (g_hasCollateralFieldDefList)
    {
        for (int i = 0; i < g_collateralFieldDefCount; i++)
        {
            if (g_collateralFieldDefList[i].Searchable) // Adjust property names
            {
                hasSearchableFields = true;
                break;
            }
        }
    }

    int idx = 0;
    int groupIdx = 0;
    // Assume datePickerIds is declared as a string above for accumulating IDs
}

@if (hasSearchableFields)
{
    <tr class="aa-collateral-flex-collapsed @fieldDisplayClass">
        <td>
            <i id="aa-expand-flex-collateral" class="fas fa-plus-square" aria-hidden="true" title="Expand Additional Collateral Fields"></i>
        </td>
        <td colspan="4" id="aa-collateral-flex-field-banner">
            <i>View Additional Collateral Fields</i>
        </td>
    </tr>

    @if (g_collateralFieldDefCount > 0)
    {
        for (int i = 0; i < g_collateralFieldGroupCount; i++)
        {
            var fieldDefGroupId = g_collateralFieldGroupList[i].Id;
            var fieldDefGroupLabel = g_collateralFieldGroupList[i].Label;
            var filedDefGroupName = g_collateralFieldGroupList[i].Name;
            int fieldIdx = 0;

            for (int j = 0; j < g_collateralFieldDefCount; j++)
            {
                var fieldLabel = g_collateralFieldDefList[j].Label;
                var fieldName = g_collateralFieldDefList[j].Name;
                var fieldDataType = g_collateralFieldDefList[j].DataType.ToLower();
                var fieldSearchable = g_collateralFieldDefList[j].Searchable;
                var fieldChoiceList = g_collateralFieldDefList[j].ChoiceList;
                var fieldGroupId = g_collateralFieldDefList[j].GroupId;

                if (fieldSearchable && fieldGroupId == fieldDefGroupId)
                {
                    string currFieldDisplayClass = (fieldDisplayState == "collapsed") ? "aa-search-hide" : "aa-search-show";

                    <tr class="aa-collateral-flex-expanded @currFieldDisplayClass">
                        <td>
                            @(groupIdx == 0
                                ? new HtmlString(@"<i id=""aa-collapse-flex-collateral"" class=""fas fa-minus-square"" aria-hidden=""true"" title=""Collapse Additional Customer Fields""></i>")
                                : new HtmlString("&nbsp;")
                            )
                        </td>
                        <td>@(fieldIdx == 0 ? fieldDefGroupLabel : "")&nbsp;</td>
                        <td class="aa-search-flex-field-label">
                            <label for="aa-chk-flex-@fieldName">@fieldLabel:&nbsp;&nbsp;</label>
                            <input type="checkbox" class="k-checkbox" id="aa-chk-flex-@fieldName" name="chk_flex_@fieldName" value="1" />
                            <label class="k-checkbox-label" for="aa-chk-flex-@fieldName"></label>
                        </td>
                        <td>&nbsp;</td>
                        <td>
                            @switch (fieldDataType)
                            {
                                case "datetime":
                                    {
                                        datePickerIds += $"from-flex-{fieldName},to-flex-{fieldName},";

                                        <ul class="aa-horizontal-list">
                                            <li>
                                                <input type="text" name="from_flex_@fieldName" id="from-flex-@fieldName" data-type="date"
                                                       data-date-msg="Invalid 'from' date"
                                                       data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                                       data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                                            </li>
                                            <li><b>to</b></li>
                                            <li>
                                                <input type="text" name="to_flex_@fieldName" id="to-flex-@fieldName" data-type="date"
                                                       data-date-msg="Invalid 'to' date"
                                                       data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                                       data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                                            </li>
                                            <li>
                                                <div class="validator-msg">
                                                    <span class="k-invalid-msg" data-for="from_flex_@fieldName"></span>
                                                    <span class="k-invalid-msg" data-for="to_flex_@fieldName"></span>
                                                </div>
                                            </li>
                                        </ul>
                                        break;
                                    }
                                case "int":
                                case "decimal":
                                case "money":
                                    {
                                        <input type="text" class="k-textbox range" name="from_flex_@fieldName" size="16" value="" />
                                        &nbsp; <b>to</b> &nbsp;
                                        <input type="text" class="k-textbox range" name="to_flex_@fieldName" size="16" value="" />
                                        break;
                                    }
                                case "bit":
                                    {
                                        <select id="aa-select-flex-@fieldName" name="flex_@fieldName">
                                            <option value="">Any</option>
                                            <option value="1">True</option>
                                            <option value="0">False</option>
                                        </select>
                                        break;
                                    }
                                case "choice":
                                    {
                                        <select id="aa-select-flex-@fieldName" name="flex_@fieldName">
                                            @if (!string.IsNullOrWhiteSpace(fieldChoiceList))
                                            {
                                                var choiceList = fieldChoiceList.Split(new[] { "||" }, StringSplitOptions.RemoveEmptyEntries);
                                                <option value="@fieldChoiceList">All</option>
                                                @foreach (var choice in choiceList)
                                                {
                                                    <option value="@choice">@choice</option>
                                                }
                                            }
                                            else
                                            {
                                                <option value="">All</option>
                                            }
                                        </select>
                                        break;
                                    }
                                default:
                                    {
                                        <input type="text" class="k-textbox" name="flex_@fieldName" size="41" value="" />
                                        break;
                                    }
                            }
                        </td>
                    </tr>

                    if (fieldDataType == "choice" || fieldDataType == "bit")
                    {
                        if (string.IsNullOrEmpty(collateralFlexFieldIdList))
                        {
                            collateralFlexFieldIdList = $"#aa-select-flex-{fieldName}";
                        }
                        else
                        {
                            collateralFlexFieldIdList += $", #aa-select-flex-{fieldName}";
                        }
                    }

                    idx++;
                    fieldIdx++;
                }
                groupIdx++;
            }
        }
    }
}

<!-- END Collateral Flex Field Block -->	



  <!-- Approval search fields (2780) -->
  <!--
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
    -->
    <!-- End Approval search fields (2780) //-->
   <!--
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
-->

@{
    var enableLoanApprovalsYN = Session["enableLoanApprovalsYN"]?.ToString();
    // Assume datePickerIds is a string for accumulating date picker IDs
}

@if (enableLoanApprovalsYN == "Y")
{
    <tr>
        <td colspan="5" class="sub-header"><h1>Approval Search Fields</h1></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Application Date:</td>
        <td>&nbsp;</td>
        @{
            datePickerIds += "app-date-from,app-date-to,";
        }
        <td>
            <ul class="aa-horizontal-list">
                <li>
                    <input type="text" name="appDateFrom" id="app-date-from" data-type="date"
                        data-date-msg="Invalid 'from' date"
                        data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                        data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                </li>
                <li>to</li>
                <li>
                    <input type="text" name="appDateTo" id="app-date-to" data-type="date"
                        data-date-msg="Invalid 'to' date"
                        data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                        data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" />
                </li>
                <li>
                    <div class="validator-msg">
                        <span class="k-invalid-msg" data-for="appDateFrom"></span>
                        <span class="k-invalid-msg" data-for="appDateTo"></span>
                    </div>
                </li>
            </ul>
        </td>
    </tr>

    @* Helper method or service call to get user groups for different roles *@
    @functions {
        // This simulates a data fetch - replace with your data access method
        public IEnumerable<UserGroup> GetUserGroups(string role)
        {
            // mock or real data retrieval here
            return new List<UserGroup>();
        }
    }

    @* Assigned Lender Dropdown *@
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Assigned Lender:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-assigned-lender" name="appLender">
                <option value=""></option>
                @foreach(var ug in GetUserGroups("lender"))
                {
                    var targetId1 = ug.TargetType.Substring(0, 1) + ":" + ug.TargetId;
                    <option value="@targetId1">@ug.TargetName</option>
                }
            </select>
        </td>
    </tr>

    @* Loan Delegate Dropdown *@
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Loan Delegate:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-app-delegate" name="appDelegate">
                <option value=""></option>
                @foreach(var ug in GetUserGroups("loanprocessor"))
                {
                    var targetId1 = ug.TargetType.Substring(0, 1) + ":" + ug.TargetId;
                    <option value="@targetId1">@ug.TargetName</option>
                }
            </select>
        </td>
    </tr>

    @* Assigned Analyst Dropdown *@
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Assigned Analyst:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-app-analyst" name="appAnalyst">
                <option value=""></option>
                @foreach(var ug in GetUserGroups("analyst"))
                {
                    var targetId1 = ug.TargetType.Substring(0, 1) + ":" + ug.TargetId;
                    <option value="@targetId1">@ug.TargetName</option>
                }
            </select>
        </td>
    </tr>

    @* Assigned Approver Dropdown *@
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Assigned Approver:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-app-approver" name="appApprover">
                <option value=""></option>
                @foreach(var ug in GetUserGroups("approver"))
                {
                    var targetId1 = ug.TargetType.Substring(0, 1) + ":" + ug.TargetId;
                    <option value="@targetId1">@ug.TargetName</option>
                }
            </select>
        </td>
    </tr>

    @* Approval Status Dropdown *@
    @{
        var applicationStatusList = GetApprovalStatuses(); // fetch list from your datasource
    }
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Approval Status:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-app-approval-status" name="approvalStatusId">
                <option value=""></option>
                @foreach(var status in applicationStatusList)
                {
                    <option value="@status.Id">@status.Description</option>
                }
            </select>
        </td>
    </tr>

    @* Application Status Dropdown *@
    @{
        var appAdminStatusList = GetApplicationStatuses(); // fetch list
        string selectedStatusId = Model.LoanStatusId; // or from wherever you get the selected value
    }
    <tr>
        <td>&nbsp;</td>
        <td colspan="2">Application Status:</td>
        <td>&nbsp;</td>
        <td>
            <select id="aa-select-app-status" name="loanStatusId">
                <option value=""></option>
                @foreach(var status in appAdminStatusList)
                {
                    var optionSelected = status.Id.ToString() == selectedStatusId ? "selected" : null;
                    <option value="@status.Id" selected="@(optionSelected != null)">@status.Description</option>
                }
            </select>
        </td>
    </tr>
}

@if (bankmax == 1)
{
    <tr>
        <td colspan="5"><input type="hidden" name="bank" value="@banksecurity[0, 1]" /></td>
    </tr>
}
else
{
    <tr><td colspan="5">&nbsp;</td></tr>
    <tr>
        @if (bankmax == 1)
        {
            <td colspan="5">&nbsp; <input type="hidden" name="bank" value="@bank.BankId" /></td>
        }
        else
        {
            <td>&nbsp;</td>
            <td colspan="2">Bank:</td>
            <td>&nbsp;</td>
            <td>
                <select name="bank" onchange="changeBank(this);">
                    <option value="0">All Banks</option>
                    @{
                        string savedBankId = Session["searchBankId"]?.ToString();
                        foreach (var b in bankList) // bankList from controller
                        {
                            if (banksecurity.Any(bs => bs == b.BankId))
                            {
                                string htmloption = savedBankId == b.BankId ? "selected" : "";
                                <option value="@b.BankId" @htmloption>@b.BankName</option>
                            }
                        }
                    }
                </select>
            </td>
        }
    </tr>
}

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
