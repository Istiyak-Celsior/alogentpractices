<h2 class="tab-title">User Details</h2>
<table class="aa-two-column-form-table">
    <tr>
        <td>User Id:</td>
        <td><input type="text" class="k-textbox" name="userLogin" value="<%=userLogin%>" size="8"/></td>
    </tr>
    <tr>
        <td>Password:</td>
        <td><input type="password" class="k-textbox" name="userPassword" value="<%=userPassword%>" size="8"/></td>
    </tr>
    <tr>
        <td>First Name:</td>
        <td><input type="text" class="k-textbox" name="userFirstName" value="<%=userFirstName%>" size="20" maxlength="20"/></td>
    </tr>
    <tr>
        <td>Middle Initial:</td>
        <td><input type="text" class="k-textbox" name="userMiddleInitial" value="<%=userMiddleInitial%>" size="1" maxlength="1"/></td>
    </tr>
    <tr>
        <td>Last Name:</td>
        <td><input type="text" class="k-textbox" name="userLastName" value="<%=userLastName%>" size="30" maxlength="30"/></td>
    </tr>
    <tr>
        <td>Inactive:</td>
        <td><%
        kendoSelectList = kendoSelectList & "user-inactive,"
        IF mode = "ADD" THEN
            %><select name="userInactive" id="user-inactive">
            <option value="N">No</option>
            </select><%
        ELSE
            %><select name="userInactive" id="user-inactive">
            <option value="N"<% IF NOT userInactive THEN %> selected="selected"<% END IF %>>No</option>
            <option value="Y"<% IF userInactive THEN %> selected="selected"<% END IF %>>Yes</option>
            </select><%
        END IF
        %></td>
    </tr>
    <%
        Dim officerCmd   : Set officerCmd = Server.CreateObject("ADODB.Command")
        Dim officerRS    : Set officerRS  = Server.CreateObject("ADODB.RecordSet")
        Dim officerQuery : officerQuery   = _
            " SELECT lo.officerId, lo.officerName" & _
            " FROM" & _
            " 	loanOfficer AS lo INNER JOIN bank AS b" & _
            " 		ON lo.bankId = b.bankId" & _
            " ORDER BY lo.officerName"
            
        officerCmd.ActiveConnection = db
        officerCmd.CommandText = officerQuery
        officerCmd.CommandType = adCmdText

        Set officerRS = officerCmd.Execute
    %>
    <tr>
        <td>Loan Officer:</td>
        <td><select name="loanOfficerID" id="loan-officer-id">
        <option value="">Not Assigned</option><%
        kendoSelectList = kendoSelectList & "loan-officer-id,"
        IF NOT (officerRS.BOF AND officerRS.EOF) THEN
            DO WHILE (NOT(officerRS.EOF))
                IF officerRS("officerID") = loanOfficerID THEN
                    selected = " selected=""selected"""
                ELSE
                    selected = ""
                END IF
                %><option value="<%=officerRS("officerID")%>"<%=selected%>><%=officerRS("officerName")%></option><%
                officerRS.MoveNext 
            LOOP
        END IF
        %></select></td>
    </tr>
    <tr>
        <td>E-Mail Address:</td>
        <td><input type="text" class="k-textbox" name="userEmail" value="<%=userEmail%>" size="50"/></td>
    </tr>
    <tr>
        <td>Allow E-Mail Sending:</td>
        <td class="pl"><input type="checkbox" class="k-checkbox" name="cbAllowEmailSending" id="cbAllowEmailSending" <% IF allowEmailSending THEN %> checked="checked"<% END IF %> value="1" /><label class="k-checkbox-label" for="cbAllowEmailSending">Yes, This User can Send Emails from AccuAccount</label></td>
    </tr>
    <tr>
        <td>User Notes:</td>
        <td><textarea name="userNotes" class="k-textbox" rows="5" cols="50" tabindex=""><%=userNotes%></textarea></td>
    </tr>
</table>