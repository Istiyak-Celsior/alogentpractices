<%
strSQL = "EXECUTE getCustomerGroupsCheck'" & selectedCustomerId & "'"
Set cmdEntities = Server.CreateObject("ADODB.Command")
db.CursorLocation = adUseClient

cmdEntities.ActiveConnection = db
cmdEntities.CommandText = strSQL
cmdEntities.CommandType = adCmdText

Set rsGroupsCheck = cmdEntities.Execute() '(, , adCmdStatic)

statusIcon = "no"
IF NOT (rsGroupsCheck.BOF AND rsGroupsCheck.EOF) THEN statusIcon = "yes"
IF selectedCreditTab = "relatedEntities" THEN
    Response.Write "Entities&nbsp;&nbsp;<i class=""fas fa-circle aa-status-" & statusIcon & " fa-fw"" aria-hidden=""true""></i>"
ELSE
    Response.Write "<a href=""customer.asp?creditTab=relatedEntities#finentity"">Entities</a>&nbsp;&nbsp;<i class=""fas fa-circle aa-status-" & statusIcon & " fa-fw"" aria-hidden=""true""></i>"
END IF
%>