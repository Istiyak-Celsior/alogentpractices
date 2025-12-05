<%
Dim PolicyExceptionRS : Set PolicyExceptionRS = CreateObject("ADODB.RecordSet")
Dim PolicyQuery : PolicyQuery = "SELECT policyId, policyTitle, policyDescription FROM PolicyDefinitions ORDER BY PolicyTitle"
PolicyExceptionRS.Open PolicyQuery, db, adOpenStatic, adCmdText

IF NOT policyExceptionRS.EOF THEN
    policyList = policyExceptionRS.GetRows
    policyCount = UBound(policyList,2)
ELSE
    policyCount = -1
END IF
policyExceptionRS.Close

' ### If it's a policy exception set the default name to the policyTitle ###
IF Trim(exceptionDefName & "") = "" AND isPolicyException THEN
    FOR i = 0 TO policyCount
        IF cStr(PolicyId) = cStr(policyList(0,i)) THEN exceptionDefName = policyList(1,i)
    NEXT
END IF
%>
<main class="inner">
    <table class="aa-two-column-form-table">
        <tr>
            <td>Exception Name:</td>
            <td><input type="text" class="k-textbox exception-name" size="60" maxlength="80" name="exceptionDefName" value="<%=exceptionDefName%>"/></td>
        </tr>
        <tr>
            <td><%=accountClassName%> Type:</td>
            <td><%=targetTypeLabel%><input type="hidden" name="targetType" value="<%=targetType%>"/>
            <input type="hidden" name="targetTypeId" value="<%=targetTypeId%>"/><input type="hidden" name="targetId" value="<%=targetId%>"/></td>
        </tr>
        <tr>
            <td>Exception Type:</td>
            <td><%
            IF computationType = "computed" THEN
                Response.Write "Document Exception"
            ELSE
                Response.Write "Standard Task Exception"
            END IF %><input type="hidden" name="taskType" value="0"/>
            <input type="hidden" name="computationType" value="<%=computationType%>"/></td>
        </tr>
        <tr>
            <td>Associated Policy:</td>
            <% kendoSelectList = kendoSelectList & "policy-id," %>
            <td><select name="PolicyId" id="policy-id"><%
            IF CheckForNull(PolicyId) = "" OR uCase(action) = "ADD" THEN
                %><option value="">No Policy Selected</option><%
            ELSE
                %><option value="">-- Remove Associated Policy --</option><%
            END IF
            FOR i = 0 TO policyCount
                selected = ""
                IF cStr(CheckForNull(PolicyId)) = cStr(policyList(0,i)) THEN selected = " selected=""selected"""
                %><option value="<%=policyList(0,i)%>"<%=selected%>><%=policyList(1,i)%></option><%
            NEXT
            %></select></td>
        </tr>
        <% IF computationType = "computed" THEN %>
        <tr class="aa-hidden">
            <td colspan="2"><input type="hidden" name="defaultNewExceptionState" value="N"/>
            <input type="hidden" name="defaultExistingExceptionState" value="N"/></td>
        </tr>
        <%
        ELSEIF exceptionDefType = "custom" THEN
            option1Selected = ""
            option2Selected = ""
            IF isPolicyException THEN
                option1Selected = " selected=""selected"""
            ELSEIF defaultStatusType = "n/a" THEN
                option2Selected = " selected=""selected"""
            END IF
            %>
            <tr>
                <td>Default Exception Value:</td>
                <% kendoSelectList = kendoSelectList & "default-new-exception-state," %>
                <td><select name="defaultNewExceptionState" id="default-new-exception-state">
                <option value="Y"<%=option1Selected%>>Is An Exception</option>
                <% IF computationType <> "manual" THEN %>
                <option value="P"<%=option2Selected%>>Pending Exception</option>
                <% END IF %>
                <option value="N"<%=option3Selected%>>Not An Exception</option>
                </select><input type="hidden" name="defaultExistingExceptionState" value="N"/></td>
            </tr>
            <%
        ELSE
            option1Selected = ""
            option2Selected = ""
            option3Selected = ""
            IF defaultNewExceptionState = "Y" OR isPolicyException THEN
                option1Selected = " selected=""selected"""
            ELSEIF defaultNewExceptionState = "P" THEN
                option2Selected = " selected=""selected"""
            ELSE
                option3Selected = " selected=""selected"""
            END IF
            %>
            <tr>
                <td>Default For New <%=targetTypeLabel%>s:</td>
                <% kendoSelectList = kendoSelectList & "default-new-exception-state," %>
                <td>
                    <div class="flex-list">
                        <div>
                            <select name="defaultNewExceptionState" id="default-new-exception-state">
                            <option value="Y"<%=option1Selected%>>Is An Exception</option>
                            <% IF computationType <> "manual" THEN %>
                            <option value="P"<%=option2Selected%>>Pending Exception</option>
                            <% END IF %>
                            <option value="N"<%=option3Selected%>>Not An Exception</option>
                            </select>
                        </div>
                        <div>
                            <i class="aa-icon fas fa-question-circle aa-color-info" title="Sets this exception state for customers/accounts added manually or via the nightly process." aria-hidden="true"></i>
                        </div>
                    </div>
                </td>
            </tr>
            <%
            option1Selected = ""
            option2Selected = ""
            option3Selected = ""
            IF defaultExistingExceptionState = "Y" OR isPolicyException THEN
                option1Selected = " selected=""selected"""
            ELSEIF defaultExistingExceptionState = "P" THEN
                option2Selected = " selected=""selected"""
            ELSE
                option3Selected = " selected=""selected"""
            END IF
            %>
            <tr>
                <td>Default For Existing <%=targetTypeLabel%>s:</td>
                <% kendoSelectList = kendoSelectList & "default-existing-exception-state," %>
                <td>
                    <div class="flex-list">
                        <div>
                            <select name="defaultExistingExceptionState" id="default-existing-exception-state">
                            <option value="Y"<%=option1Selected%>>Is An Exception</option>
                            <% IF computationType <> "manual" THEN %>
                            <option value="P"<%=option2Selected%>>Pending Exception</option>
                            <% END IF %>
                            <option value="N"<%=option3Selected%>>Not An Exception</option>
                            </select>
                        </div>
                        <div>
                            <i class="aa-icon fas fa-question-circle aa-color-info" title="Sets this exception state for any customers/accounts already existing in AccuAccount." aria-hidden="true"></i>
                        </div>
                    </div>
                </td>
            </tr>
            <%
        END IF ' ### computationType = "computed"

        Dim exceptionCategoryRS : Set exceptionCategoryRS = CreateObject("ADODB.RecordSet")
        Dim exceptionCategoryQuery : exceptionCategoryQuery = "SELECT * FROM exceptionCategory ORDER BY categoryName"
        exceptionCategoryRS.Open exceptionCategoryQuery, db, adOpenStatic, adCmdText
        %>
        <tr>
            <td>Exception Category:</td>
            <% kendoSelectList = kendoSelectList & "exception-category-id," %>
            <td><select name="exceptionCategoryId" id="exception-category-id">
            <option value="">No Category Selected</option>
            <%
            DO UNTIL exceptionCategoryRS.EOF
                IF isNull(exceptionCategoryId) THEN
                    %><option value="<%=exceptionCategoryRS("categoryId")%>"><%=exceptionCategoryRS("categoryName")%></option><%
                ELSE
                    IF cStr(exceptionCategoryId) = cStr(exceptionCategoryRS("categoryId")) THEN
                        option1Selected = " selected=""selected"""
                    ELSE
                        option1Selected = ""
                    END IF
                    %><option value="<%=exceptionCategoryRS("categoryId")%>"<%=option1Selected%>><%=exceptionCategoryRS("categoryName")%></option><%
                END IF
                exceptionCategoryRS.MoveNext
            LOOP
            exceptionCategoryRS.Close
            %></select></td>
        </tr>
        <%
        option1Selected = ""
        option2Selected = ""
        IF defaultStatusType = "required" THEN
            option1Selected = " selected=""selected"""
        ELSEIF defaultStatusType = "n/a" THEN
            option2Selected = " selected=""selected"""
        END IF
        %>
        <tr>
            <td>Exception Status:</td>
            <% kendoSelectList = kendoSelectList & "default-status-type," %>
            <td id="default-status-type-wrapper">
                <ul class="list">
                    <li><select name="defaultStatusType" id="default-status-type">
                    <option value="required" <%=option1Selected%>>Required</option>
                    <option value="n/a" <%=option2Selected%>>N/A</option>
                    </select></li>
                    <%
                    IF action = "EDIT" THEN
                        IF resetDefaultStatus <> "" THEN
                            checked = " checked=""checked"""
                        ELSE
                            checked = ""
                        END IF
                        %><li><input type="checkbox" class="k-checkbox" name="resetDefaultStatus" id="reset-default-status"<%=checked%>/><label class="k-checkbox-label" for="reset-default-status">Check to reset the Default Status for all exceptions of this type.</label></li><%
                    END IF %>
                </ul>
            </td>
        </tr>
        <%
        Dim userBankRS : Set userBankRS = CreateObject("ADODB.RecordSet")
        Dim userBankQuery : userBankQuery = "SELECT * FROM qryUserBankView WHERE bankId=" & dbFormatId(bankId) & " ORDER BY userLastName"
        userBankRS.Open userBankQuery, db, adOpenStatic
        %>
        <tr>
            <td>Default Assigned User</td>
            <% kendoSelectList = kendoSelectList & "default-assigned-user-id," %>
            <td class="default-assigned-user-id">
                <ul class="list">
                    <li><select name="defaultAssignedUserId" id="default-assigned-user-id"><%
            IF action = "ADD" THEN
                %><option value=""> -- Select Default User -- </option><%
            ELSE
                IF Len(defaultAssignedUserId) = 0 THEN
                    %><option value="" selected="selected"> -- Unassigned -- </option><%
                END IF
            END IF
            DO UNTIL userBankRS.EOF
                selected = ""
                userName = userBankRS("userLastName") & ", " & userBankRS("userFirstName") & " " & userBankRS("userMiddleInitial")
                IF cStr(defaultAssignedUserId) = cStr(userBankRS("userId")) THEN
                    selected = " selected=""selected"""
                END IF
                %><option value="<%=userBankRS("userId")%>"<%=selected%>><%=userName%></option><%
                userBankRS.MoveNext
            LOOP
            userBankRS.Close
            %></select></li><%
            IF action = "ADD" OR exceptionDefType = "custom" THEN
                %><li><input type="hidden" name="resetDefaultUser" value=""/></li><%
            ELSE
                checked = ""
                IF resetDefaultUser <> "" THEN checked = " checked=""checked"""
                %><li><input type="checkbox" class="k-checkbox" name="resetDefaultUser" id="reset-default-user"<%=checked%>/><label class="k-checkbox-label" for="reset-default-user">Reset the Default User for all exceptions of this type.</label></li><%
            END IF %></ul></td>
        </tr>
        <%
        IF computationType = "manual" THEN
            checked = ""
            disabled = ""
            IF requireReminderDate = "Y" THEN
                checked = " checked=""checked"""
            ELSE
                disabled = " disabled=""disabled"""
            END IF
            %>
            <tr class="aa-no-background-color narrow">
                <td colspan="2">&nbsp;</td>
            </tr>
            <tr>
                <td>Task Reminder Date:</td>
                <td>
                    <div><input type="checkbox" class="k-checkbox" name="requireReminderDate" id="require-reminder-date" value="Y"<%=checked%> onclick="toggleDateSettings(frmExceptionMaint, this, '<%=exceptionDefType%>');"/><label class="k-checkbox-label" for="require-reminder-date">Check to set Reminder Date</label></div>
                    <div>
                        <ul class="list">
                            <li>Default Reminder Date</li>
                            <li>
                                <input type="date"
                                    id="default-reminder-date"
                                    name="defaultReminderDate"
                                    data-type="date"
                                    data-date-msg="Invalid 'Reminder' date"
                                    data-mindate-msg="Date must be later or equal to 1/1/1753"
                                    data-maxdate-msg="Date must be prior or equal to 12/31/9999"
                                    <%=disabled%>/></li>
                            <li>
                                <div class="validator-msg">
                                    <span class="k-invalid-msg" data-for="defaultReminderDate"></span>
                                </div>
                            </li>
                        </ul>
                    </div>
                    <%
                    IF uCase(targetType) = "L" THEN
                        checked = ""
                        IF requireLoanMaturityDate THEN checked = " checked=""checked"""
                        %><div><input type="checkbox" class="k-checkbox" name="requireLoanMaturityDate" id="require-loan-maturity-date" value="1"<%=checked%> onclick="toggleDateSettings(frmExceptionMaint, this, '<%=exceptionDefType%>');"/><label class="k-checkbox-label" for="require-loan-maturity-date">Check to use Loan's Maturity Date</label></div><%
                    END IF
                %></td>
            </tr>
            <tr>
                <td>Reminder Date Grace Period:</td>
                <td><input type="text" class="k-textbox" name="defaultReminderDateGracePeriod" size="5" value="<%=defaultReminderDateGracePeriod%>"/></td>
            </tr>
        <% ELSE %>
        <tr class="aa-hidden">
            <td colspan="2"><input type="hidden" name="requireReminderDate" value="N"/>
            <input type="hidden" name="requireLoanMaturityDate" value="0"/></td>
        </tr>
        <% END IF ' ### computationType = "manual" %>
        <tr class="aa-no-background-color narrow">
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td>Exception Weight:</td>
            <td><input type="text" class="k-textbox" name="exceptionWeight" value="<%=exceptionWeight%>" size="10"/></td>
        </tr>
        <tr>
            <td>Sort Order:</td>
            <td><input type="text" class="k-textbox" name="sortOrder" value="<%=sortOrder%>"/></td>
        </tr>
    </table>
</main>