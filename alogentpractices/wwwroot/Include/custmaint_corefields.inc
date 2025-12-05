<tr class="aa-no-background-color">
    <td><i class="fas fa-asterisk aa-color-danger" aria-hidden="true"></i>&nbsp;Required Fields</td>
    <td><i class="aa-icon fas fa-lock no-hover" aria-hidden="true"></i></td>
    <td>Locked from Nightly Updates</td>
</tr>
<%
IF bankRows = 0 THEN
    customerBankId = bankArray(BANK_ID,0)
    theDisplayedBank = customerBankId
    %>
    <tr class="aa-hidden">
        <td colspan="3"><input type="hidden" name="customerBankId" value="<%=bankArray(BANK_ID,0)%>"/></td>
    </tr>
<% ELSE %>
    <tr>
        <td>Bank</td>
        <td><!--<img src="<%=imgLock%>" name="imgLockBank" border="0" onclick="ChangeLockState(frmCustomerMaint.imgLockBank, frmCustomerMaint.lockBank);">--></td>
        <td>
        <%
        IF action <> "ADD" THEN
            FOR i = 0 TO bankRows
                IF cStr(bankArray(BANK_ID,i)) = cStr(customerBankId) THEN
                    theDisplayedBank = bankArray(BANK_ID,i)
                    %><%=bankArray(BANK_NAME,i)%><input type="hidden" id="idBankId" name="customerBankId" value="<%=bankArray(BANK_ID,i)%>"/><%
                END IF
            NEXT
        ELSE
            kendoSelectList = kendoSelectList & "idBankId,"
            %><select id="idBankId" name="customerBankId" onchange="changeBank(this);"><%
            displayBankSet = False
            FOR i = 0 TO bankRows
                ' ### Check if bank name is to be included in the list based on the userbanksecurity table ###
                FOR ii = 0 TO userBankSecurityRows
                    theBankID = userBankSecurityArray(UBS_BANKID,ii)
                    theBankAccess = userBankSecurityArray(UBS_BANKACCESS,ii)
                    IF cStr(bankArray(BANK_ID,i)) = cStr(theBankID) AND Int(theBankAccess) = 1 THEN
                        IF displayBankSet = False THEN
                            theDisplayedBank = bankArray(BANK_ID,i)
                            displayBankSet = true
                        END IF
                        selected = ""
                        IF cStr(customerBankId) = cStr(bankArray(BANK_ID,i)) THEN
                            selected = " selected=""selected"""
                        END IF
                        %><option value="<%=bankArray(BANK_ID,i)%>"<%=selected%>><%=bankArray(BANK_NAME,i)%></option><%
                    END IF
                NEXT
            NEXT
            %></select><%
        END IF
        %></td>
    </tr>
<% END IF ' ### bankRows = 0 %>
<%
imgLock = "unlock"
IF lockCustomerName THEN imgLock = "lock"

IF Session("cifInquiryResult.CustomerName") <> "" THEN
    customerName = Session("cifInquiryResult.CustomerName")
END IF
%>
<tr>
    <td>Name: <i class="fas fa-asterisk aa-color-danger" aria-hidden="true"></i></td>
    <td><input type="hidden" id="hidLockCustomerName" name="lockCustomerName" value="<%=lockCustomerName%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerName"></i></td>
    <td><input type="text" class="k-textbox" name="customerName" id="customer-name" size="40" value="<%=customerName%>"/>
    <% IF action="ADD" AND Session("cifIntegration.enabled") = "1" THEN %>&nbsp;&nbsp;<a id="cifSearchLink" href="javascript:void(0);" onclick="openKendoDialog('CIF Search', 'cifsearch.asp?customerTypeId=<%=customerTypeId%>&bankId=<%=theDisplayedBank%>', 500, 800);" >CIF Search</a><% END IF %></td>
</tr>
<%
imgLock = "unlock"
IF lockBusinessName THEN imgLock = "lock"
%>
<tr>
    <td>Name 2:</td>
    <td><input type="hidden" id="hidLockBusinessName" name="lockBusinessName" value="<%=lockBusinessName%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockBusinessName"></i></td>
    <td><input type="text" class="k-textbox" name="businessName" size="40" value="<%=businessName%>"></td>
</tr>
<%
imgLock = "unlock"
IF lockCustomerNumber THEN imgLock = "lock"

IF Session("cifInquiryResult.CustomerNumber") <> "" THEN
    customerNumber = Session("cifInquiryResult.CustomerNumber")
END IF
%>
<tr>
    <td>Customer Number: <i class="fas fa-asterisk aa-color-danger" aria-hidden="true"></i></td>
    <td><input type="hidden" id="hidLockCustomerNumber" name="lockCustomerNumber" value="<%=lockCustomerNumber%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerNumber"></i></td>
    <%
    IF action = "ADD" THEN
        Response.Write "<td><input type=""text"" class=""k-textbox"" name=""customerNumber"" id=""customerNumber1"" value=""" & customerNumber & """ size=""20"" maxsize=""255""/></td>"
    ELSE
        Response.Write "<td>" & customerNumber
        IF Session("isSuperUser") OR Session("credit.isAdmin") OR Session("credit.allowEdit") OR Session("credit.allowAdd") THEN
            Response.Write "&nbsp;<a href=""javascript:void(0);"" onclick=""openKendoDialog('Change Customer Number', 'changecustomernumbermaint.asp?customerId=" & customerId & "', 400, 500);"" class=""aa-command-link""><i class=""aa-icon fas fa-pencil-alt fa-fw"" title=""Change Customer Number"" aria-hidden=""true""></i></a>"
        END IF
        Response.Write "<input type=""hidden"" name=""customerNumber"" id=""customerNumber1"" value=""" & customerNumber & """/></td>"
    END IF
    %>
</tr>
<%
imgLock = "unlock"
IF lockTaxId THEN imgLock = "lock"

IF Session("cifInquiryResult.CustomerNumber") <> "" THEN
    TaxId = Session("cifInquiryResult.TaxId")
END IF
%>
<tr>
    <td>Customer Tax Id:</td>
    <td><input type="hidden" id="hidLockTaxId" name="lockTaxId" value="<%=lockTaxId%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockTaxId"></i></td>
    <td><input type="text" class="k-textbox" name="taxId" size="9" maxlength="9" value="<%=TaxId%>"></td>
</tr>
<%
imgLock = "unlock"
IF lockCustomerBranch THEN imgLock = "lock"

IF branchRows = 1 THEN
%>
<tr class="aa-hidden">
    <td colspan="3"><input type="hidden" name="customerBranchId" value="<%=branchArray(BRANCH_ID,0)%>"/>
    <input type="hidden" name="lockCustomerBranch" value="<%=lockCustomerBranch%>"/></td>
</tr>
<% ELSE %>
<tr>
    <td>( Region ) Branch:</td>
    <td><input type="hidden" id="hidLockCustomerBranch" name="lockCustomerBranch" value="<%=lockCustomerBranch%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerBranch"></i></td>
    <% Dim cifBranchName : cifBranchName = Session("cifInquiryResult.Branch") %>
    <% kendoSelectList = kendoSelectList & "customer-branch-id," %>
    <td><%
    Dim bankId, branchId, branchName, accessBranchId, userBranchAccess
    Dim displayBranchDropdown : displayBranchDropdown = false
    Dim displayFinancialDocs : displayFinancialDocs = false
    FOR i = lBound(branchArray,2) TO uBound(branchArray,2)
        ' ### Get the various branch properties from the array ###
        bankId = branchArray(BRANCH_BANK_ID,i)
        branchId = branchArray(BRANCH_ID,i)
        branchName = branchArray(BRANCH_NAME,i)
        regionName = branchArray(BRANCH_REGION_ID,i)
        accessBranchId =  checkForNull(branchArray(BRANCH_ACCESSBRANCHID,i))
        userBranchAccess = branchArray(BRANCH_HAS_ACCESS,I)
        branchSelected = ""

        IF action = "EDIT" THEN
            IF customerBranchId = branchId THEN customerBranchName = branchName
            IF cStr(bankId) = cStr(customerBankId) THEN
                IF customerBranchId = branchId AND userBranchAccess = 1 THEN
                    displayBranchDropdown = true
                    displayFinancialDocs = true
                END IF
            END IF
        ELSE
            IF Session("isSuperUser") THEN
                displayBranchDropdown = true
                displayFinancialDocs = true
            ELSE
                FOR bsId = 0 TO userBranchSecurityRows
                    IF (userBranchSecurityArray(BRSEC_BRANCHID, bsId) = branchId) THEN
                        displayBranchDropdown = true
                        displayFinancialDocs = true
                    END IF
                NEXT
            END IF
        END IF
    NEXT 'i

    Dim disableBranch : disableBranch = ""
    IF NOT displayBranchDropdown THEN disableBranch = "disabled"
    %><select name="customerBranchId" id="customer-branch-id" <%=disableBranch%>><%
    FOR i = lBound(branchArray,2) TO uBound(branchArray,2)
        ' ### Get the various branch properties from the array ###
        bankId = branchArray(BRANCH_BANK_ID,i)
        branchId = branchArray(BRANCH_ID,i)
        branchName = branchArray(BRANCH_NAME,i)
        regionName = branchArray(BRANCH_REGION_ID,i)
        accessBranchId =  checkForNull(branchArray(BRANCH_ACCESSBRANCHID,i))
        userBranchAccess = branchArray(BRANCH_HAS_ACCESS,I)
        branchSelected = ""

        IF customerBranchId = branchId THEN branchSelected = "selected"
        IF userBranchAccess = 1 OR branchSelected <> "" THEN
            %><option value="<%=branchId%>" <%=branchSelected%>>(<%=regionName%> ) <%=branchName%></option><%
        END IF
    NEXT
    %></select></td>
</tr>
<% END IF ' ### branchRows = 1 %>
<%
imgLock = "unlock"
IF lockClassification THEN imgLock = "lock"
%>
<tr>
    <td>Credit Classification:</td>
    <td><input type="hidden" id="hidLockClassification" name="lockClassification" value="<%=lockClassification%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockClassification"></i></td>
    <% kendoSelectList = kendoSelectList & "classification-id," %>
    <td><select name="classificationId" id="classification-id"><%
    Dim classRS : Set classRS = Server.CreateObject("ADODB.RecordSet")
    Dim classQuery : classQuery = "SELECT * FROM creditClassification where type = 'credit' ORDER BY classificationCode"
    classRS.Open classQuery, db, adOpenStatic, adCmdText
    DO UNTIL classRS.EOF
        selected = ""
        IF classificationId = cStr(classRS("classificationId")) THEN selected = " selected=""selected"""
        IF classRS("displayEmphasis") THEN
            classificationStyle = "font-weight: bold"
        ELSE
            classificationStyle = "font-weight: normal"
        END IF
        classificationStyle = classificationStyle & "; color: " & classRS("displayColor")
        %><option style="<%=classificationStyle%>" value="<%=classRS("classificationId")%>"<%=selected%>><%=classRS("classificationName")%></option><%
        classRS.MoveNext
    LOOP
    classRS.Close
    %></select></td>
</tr>
<%
imgLock = "unlock"
IF lockCustomerOfficer THEN imgLock = "lock"
%>
<tr>
    <td>Assigned Officer:</td>
    <td><input type="hidden" id="hidLockCustomerOfficer" name="lockCustomerOfficer" value="<%=lockCustomerOfficer%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerOfficer"></i></td>
    <td><%
    Dim cifOfficerName : cifOfficerName = Session("cifInquiryResult.OfficerName")
    Dim loanOfficerCmd : Set loanOfficerCmd = Server.CreateObject("ADODB.Command")
    Dim loanOfficerRS  : Set loanOfficerRS = Nothing

    loanOfficerCmd.ActiveConnection = db
    loanOfficerCmd.CommandType      = adCmdText
    loanOfficerCmd.CommandText      = "SELECT * FROM loanOfficer WHERE bankId = ? ORDER BY officerName ASC"

    loanOfficerCmd.Parameters.Append(loanOfficerCmd.CreateParameter(, adGUID, adParamInput, , theDisplayedBank))
    
    SET loanOfficerRS = loanOfficerCmd.Execute()
    
    selected = ""
    IF CheckForNull(customerOfficerId) = "" THEN selected = " selected=""selected"""
    kendoSelectList = kendoSelectList & "customer-officer-id,"
    %><select name="customerOfficerId" id="customer-officer-id">
    <option value=""<%=selected%>>None Assigned</option><%
    DO UNTIL loanOfficerRS.EOF
        selected = ""
        Dim officerId : officerId = loanOfficerRS("officerId")
        Dim officerName : officerName = CheckForNull(loanOfficerrs("officerName"))
        IF Trim(cifOfficerName & "") <> "" THEN
            IF InStr(lCase(Trim(officerName)), lCase(Trim(cifOfficerName))) > 0 THEN
                selected = " selected=""selected"""
            ELSEIF cStr(loanOfficerRS("officerId")) = cStr(customerOfficerId) THEN
                selected = " selected=""selected"""
            END IF
        ELSEIF cStr(loanOfficerRS("officerId")) = cStr(customerOfficerId) THEN
            selected = " selected=""selected"""
        END IF
        %><option value="<%=loanOfficerRS("officerId")%>"<%=selected%>><%=loanOfficerRS("officerName")%></option><%
        loanOfficerRS.MoveNext
    LOOP
    loanOfficerRS.Close
    %></select></td>
</tr>
<%
imgLock = "unlock"
IF lockEmployee THEN imgLock = "lock"

IF Session("cifInquiryResult.Employee") <> "" THEN
    IF Session("cifInquiryResult.Employee") = "N" THEN
        customerEmployee = 0
    ELSE
        customerEmployee = 1
    END IF
END IF

Dim enableEmployeeCheckbox : enableEmployeeCheckbox = " disabled=""disabled"""
Dim employeeInformation : employeeInformation = "<label for=""cbCustomerEmployee"" class=""k-checkbox-label"">You don&#39;t have permission to change this flag.</label>"
IF Session("isSuperUser") OR Session("credit.isAdmin") THEN
    enableEmployeeCheckbox = ""
    employeeInformation = "<label for=""cbCustomerEmployee"" class=""k-checkbox-label"">Yes, this customer is an employee.</label>"
END IF
%>
<tr>
    <td>Employee?:</td>
    <td><input type="hidden" id="hidLockEmployee" name="lockEmployee" value="<%=lockEmployee%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockEmployee"></i></td>
    <td><input type="checkbox" class="k-checkbox" onclick="ChangeEmployeeYN();" id="cbCustomerEmployee" name="cbCustomerEmployee" value="1"<% IF customerEmployee = 1 THEN %> checked="checked"<% END IF %><%=enableEmployeeCheckbox%>/><%=employeeInformation%><input type="hidden" name="customerEmployee" value="<%=customerEmployee%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockCustomerType THEN imgLock = "lock"
%>
<tr>
    <td>Customer Type:</td>
    <td><input type="hidden" id="hidLockCustomerType" name="lockCustomerType" value="<%=lockCustomerType%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerType"></i></td>
    <td><input type="hidden" name="orgCustomerTypeId" value="<%=customerTypeId%>"/><%
    IF InStr("EDIT", uCase(action)) > 0 THEN
        FOR i = 0 TO custTypeRows
            IF custTypeArray(0,i) = customerTypeId THEN
               %><%=custTypeArray(1,i)%><input type="hidden" name="customerTypeId" value="<%=custTypeArray(0,i)%>"/><%
               IF NOT lockCustomerType THEN
                   %>&nbsp;<%
                   IF Session("isSuperUser") OR ( Session("credit.isAdmin") OR Session("credit.allowEdit") OR Session("credit.allowAdd") ) THEN
                       %><a href="javascript:void(0);" onclick="openKendoDialog('Change Customer Type', 'customerchangemaint.asp?customerId=<%=customerId%>', 500, 700);" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Change Customer Type" aria-hidden="true"></i></a><%
                   END IF
               END IF
            END IF
        NEXT
    ELSE
        Dim customerTypeRS : Set customerTypeRS = Server.CreateObject("ADODB.Recordset")
        Dim customerTypeQuery : customerTypeQuery = _
            " SELECT *" & _
            " FROM customerType" & _
            " ORDER BY customerTypeDescription"
        customerTypeRS.Open customerTypeQuery, db, adOpenDynamic
        kendoSelectList = kendoSelectList & "idCustomerTypeId,"
        %><select id="idCustomerTypeId" name="customerTypeId" onchange="CustomerTypeChanged();"><%
        DO UNTIL customerTypeRS.EOF
            ctselected = ""
            IF customerTypeRS("customerTypeId") = customerTypeId THEN ctselected = " selected=""selected"""
            %><option<%=ctselected%> value="<%=customerTypeRS("customerTypeId")%>"><%=customerTypeRS("customerTypeDescription")%></option><%
            customerTypeRS.moveNext
        LOOP
        %></select><%
    END IF
    %></td>
</tr>
<%
IF (customerStatus = "") OR (uCase(customerStatus) = "ACTIVE") THEN
    htmloption1 = " selected=""selected"""
    htmloption2 = ""
ELSE
    htmloption2 = " selected=""selected"""
    htmloption1 = ""
END IF

imgLock = "unlock"
IF lockStatus THEN imgLock = "lock"
%>
<tr>
    <td>Customer Status:</td>
    <td><input type="hidden" id="hidLockStatus" name="lockStatus" value="<%=lockStatus%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockStatus"></i></td>
    <td><%
    Dim customerStatusRS : Set customerStatusRS = Server.CreateObject("ADODB.Recordset")
    Dim customerStatusQuery : customerStatusQuery = _
        " SELECT *" & _
        " FROM customerStatus" & _
        " ORDER BY customerStatusDescription"
    customerStatusRS.Open customerStatusQuery, db, adOpenDynamic
    kendoSelectList = kendoSelectList & "customer-status,"
    %><select name="customerStatus" id="customer-status"><%
    WHILE NOT customerStatusRS.EOF
        selected = ""
        IF cStr(customerStatusRS("customerStatusId")) = customerStatusId OR (customerStatusId="" AND customerStatusRS("isDefault")) THEN selected = " selected=""selected"""
        %><option value="<%=customerStatusRS("customerStatusId")%>"<%=selected%>><%=customerStatusRS("customerStatusDescription")%></option><%
        customerStatusRS.MoveNext()
    WEND
    %></select></td>
</tr>
<%
IF ignoreExceptionsYN = "Y" THEN
    htmloption1 = " selected=""selected"""
    htmloption2 = ""
ELSE
    htmloption1 = ""
    htmloption2 = " selected=""selected"""
END IF

imgLock = "unlock"
IF lockIgnoreExceptionsYN THEN imgLock = "lock"
%>
<% IF Session("accuaccount.enableExpress") <> 1 THEN %>
<% kendoSelectList = kendoSelectList & "ignore-exceptions-yn," %>
<tr>
    <td>Ignore Financial Exceptions:</td>
    <td><input type="hidden" id="hidLockIgnoreExceptionsYN" name="lockIgnoreExceptionsYN" value="<%=lockIgnoreExceptionsYN%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockIgnoreExceptionsYN"></i></td>
    <td><select name="ignoreExceptionsYN" id="ignore-exceptions-yn">
    <option value="Y"<%=htmloption1%>>Yes</option>
    <option value="N"<%=htmloption2%>>No</option>
    </select></td>
</tr>
<% ELSE %>
<tr class="aa-hidden">
    <td colspan="3"><input type="hidden" name="lockIgnoreExceptionsYN" value="false"/>
    <input type="hidden" name="ignoreExceptionsYN" value="N"/></td>
</tr>
<% END IF %>
<% IF CanAccessPurge() AND customerPurgeControl <> "0" THEN %>
<% kendoSelectList = kendoSelectList & "purge-status," %>
<tr>
    <td>Purge Status:</td>
    <td>&nbsp;</td>
    <td><select name="ddPurgeStatus" id="purge-status">
    <% IF action <> "ADD" THEN %>
    <option value="1"<% IF purgeStatus THEN %> selected="selected"<% END IF %>>Yes</option>
    <option value="0"<% IF NOT purgeStatus THEN %> selected="selected"<% END IF %>>No</option>
    <% ELSE %>
    <option value="0" selected="selected">No</option>
    <% END IF %></select></td>
</tr>
<% ELSE %>
<tr class="aa-hidden">
    <td colspan="3"><input type="hidden" name="ddPurgeStatus" value="0"/></td>
</tr>
<% END IF ' ### IF CanAccessPurge() %>
<% IF Session("acculoan.showParticipationLoan") = 1 AND HasParticipationLoans(customerId) > 0 THEN %>
<tr>
    <td>Block Participation:</td>
    <td>&nbsp;</td>
    <td>
        <table cellspacing="0" cellpadding="0" border="0">
            <tr>
                <td><input type="checkbox" name="cbBlockParticipation" id="cbBlockParticipationId"<% IF blockParticipation THEN %> checked="checked"<% END IF %> value="1"/></td>
                <td class="pl"><label for="cbBlockParticipationId">Yes, Block Customer from Pushing Participation Documents</label></td>
            </tr>
        </table>
    </td>
</tr>
<% ELSE %>
<tr class="aa-hidden">
    <td colspan="3"><input type="hidden" name="cbBlockParticipation" value="<% IF blockParticipation THEN %>1<% ELSE %>0<% END IF %>"/></td>
</tr>
<% END IF ' ### IF Session("acculoan.showParticipationLoan") = 1 %>
<%
IF allowExternalAppLink = "True" THEN
    htmloption1 = " selected=""selected"""
    htmloption2 = ""
ELSE
    htmloption1 = ""
    htmloption2 = " selected=""seleceted"""
END IF

imgLock = "unlock"
IF lockAllowExternalAppLink THEN imgLock = "lock"

IF Trim(Session("acculoan.linkToolURL")) <> "" THEN %>
<% kendoSelectList = kendoSelectList & "allow-external-app-link," %>
<tr>
    <td>Allow Link to External:</td>
    <td><input type="hidden" name="lockAllowExternalAppLink" value="<%=lockAllowExternalAppLink%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imglockAllowExternalAppLink"></i></td>
    <td><select name="allowExternalAppLink" id="allow-external-app-link">
    <option value="True"<%=htmloption1%>>Yes</option>
    <option value="False"<%=htmloption2%>>No</option>
    </select></td>
</tr>
<% ELSE %>
<tr class="aa-hidden">
    <td colspan="3"><input type="hidden" name="lockAllowExternalAppLink" value="false"/></td>
</tr>
<% END IF %>