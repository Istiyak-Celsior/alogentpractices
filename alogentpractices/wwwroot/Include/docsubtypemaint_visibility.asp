
<h2>Account Security Access</h2>
<br>
<table style="margin:0,25px;">
	<tr>
		<td>
			Check which Accounts this Tab belongs to.
		</td>
	</tr>
</table>

<%
	Dim tabSecurityQuery, tabSecurityRS
	Set tabSecurityRS = Server.CreateObject("ADODB.RecordSet")
	
	if action = "ADD" then
		tabSecurityQuery = _
			" SELECT" & _
			"	NULL AS tabAccountAccessId," & _
			"	accountClassId," & _
			"	accountClassName," & _
			"	accountClassCode" & _
			" FROM" & _
			"	accountClass" & _
			" ORDER BY" & _
			"	accountClassSortOrder"
	else
		tabSecurityQuery = _
			" SELECT" & _
			" 	tabAccountAccessId," & _
			"	ac.accountClassId," & _
			" 	ac.accountClassName," & _
			" 	ac.accountClassCode" & _
			" FROM" & _
			"	documentSubType AS dst CROSS JOIN accountClass AS ac" & _
			"	LEFT OUTER JOIN documentTabAccountSecurity AS tabsec" & _
			"		ON tabsec.documentSubTypeId=dst.documentSubTypeId AND tabsec.accountClassId=ac.accountClassId" & _
			" WHERE" & _
			"	dst.documentSubTypeId=" & dbFormatId(documentSubTypeId) & _
			" ORDER BY" & _
			"	ac.accountClassSortOrder"
	end if
	tabSecurityRS.Open tabSecurityQuery, db, adOpenStatic, adCmdText
	
	Dim tabAccountAccess, rowCount
	tabAccountAccess = tabSecurityRS.GetRows
	rowCount = tabSecurityRS.RecordCount
	tabSecurityRS.Close
	
	' Set the checkAll checkbox if there are no NULL access fields
	'
	checked = "checked=""true"""
	for i =  0 to rowCount - 1
		if CheckForNull(tabAccountAccess(0,i)) = "" then
			checked = ""
		end if
%>
<input type="hidden" name="tabAccountAccessId" value="<%=tabAccountAccess(0,i)%>" />
<input type="hidden" name="accountClassId" value="<%=tabAccountAccess(1,i)%>" />
<%
	next
%>
<table id="aa-visibility-table">
    <tbody>
	    <tr>
		    <td><input type="checkbox" class="k-checkbox" id="aa-visibility-check-all" name="chkAll" value="" onclick="javascript:toggleAccountCheckAll(chkAll, chkIndex);" <%=checked%> /><label for="aa-visibility-check-all" class="k-checkbox-label"></label></td>
		    <td colspan="2">Check All</td>
	    </tr>
<%
	for i = 0 to rowCount -1
		checked = ""
		if CheckForNull(tabAccountAccess(0,i)) <> "" then
			checked = "checked=""true"""
		end if
		
		if action = "ADD" And tabAccountAccess(3,i) = activeAccountTab then
			checked = "checked=""true"""
		end if
%>
	    <tr>
		    <td>&nbsp;</td>
		    <td><input type="checkbox" class="k-checkbox" id="aa-visibility-check-<%=i%>" name="chkIndex" value="<%=i%>" onclick="javascript:toggleAccount(chkAll, chkIndex);" <%=checked%> /><label for="aa-visibility-check-<%=i%>" class="k-checkbox-label"></label></td>
		    <td ><%=tabAccountAccess(2,i)%></td>
	    </tr>
<%
	next

%>
    </tbody>
</table>
	