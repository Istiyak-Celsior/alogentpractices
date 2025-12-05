<tr class="aa-no-background-color">
    <td colspan="3"><%
    IF Session("accuaccount.enableExpress") <> 1 THEN
        Response.Write "<h2>Contact Information for Notices</h2>"
    ELSE
        Response.Write "<h2>Detailed Contact Information</h2>"
    END IF
    %></td>
</tr>
<%
imgLock = "unlock"
IF lockLetterName THEN imgLock = "lock"

IF Session("accuaccount.enableExpress") <> 1 THEN
    Dim customerContactId       : customerContactId       = ""
    Dim customerContactMethodId : customerContactMethodId = ""
    Dim customerContactUseEmail : customerContactUseEmail = false
    Dim customerContactUsePaper : customerContactUsePaper = false
    Dim customerContactUsePhone : customerContactUsePhone = false

    IF action = "EDIT" THEN
        Dim customerContactCmd   : SET customerContactCmd = Server.CreateObject("ADODB.Command")
        Dim customerContactRS    : SET customerContractRS = Nothing
        Dim customerContactQuery : customerContactQuery = "SELECT * FROM customerContact WHERE customerId = ?"

        customerContactCmd.ActiveConnection = db
        customerContactCmd.CommandType      = adCmdText
        customerContactCmd.CommandText      = customerContactQuery

        customerContactCmd.Parameters.Append(customerContactCmd.CreateParameter(, adGUID, adParamInput, , customerId))

        SET customerContactRS = customerContactCmd.Execute()

        IF NOT customerContactRS.EOF THEN
            customerContactId       = customerContactRS("contactId")
            customerContactMethodId = customerContactRS("customerContactMethodId")
            customerContactUseEmail = CBool(customerContactRS("useEmail"))
            customerContactUsePaper = CBool(customerContactRS("usePaper"))
            customerContactUsePhone = CBool(customerContactRS("usePhone"))
        END IF

        customerContactRS.Close
    END IF

    Dim useEmailSelected : IF customerContactUseEmail THEN useEmailSelected = " checked"
    Dim usePaperSelected : IF customerContactUsePaper THEN usePaperSelected = " checked"
    Dim usePhoneSelected : IF customerContactUsePhone THEN usePhoneSelected = " checked"
%>
<input type="hidden" id="customer-contact-use-email" value="<%=customerContactUseEmail%>" />
<input type="hidden" id="customer-contact-use-paper" value="<%=customerContactUsePaper%>" />
<input type="hidden" id="customer-contact-use-phone" value="<%=customerContactUsePhone%>" />
<tr>
    <td>Contact</td>
    <td>&nbsp;</td>
    <td>
<%
    kendoSelectList = kendoSelectList & "customer-contact-method-id,"
    Dim contactMethodRS    : Set contactMethodRS = Server.CreateObject("ADODB.RecordSet")
    Dim contactMethodQuery : contactMethodQuery = "SELECT customerContactMethodId, name FROM customerContactMethod ORDER BY name DESC"
    Dim contactMethodNmae  : contactMethodName = ""
    contactMethodRS.Open contactMethodQuery, db, adOpenStatic
%>
        <select id="customer-contact-method-id" name="customerContactMethodId" onchange="toggleContactDisplay();">
            <option value="">No Preference Chosen</option>
<%

    DO UNTIL contactMethodRS.EOF
        Dim contactMethodSelected : contactMethodSelected = ""

        IF contactmethodRS("customerContactMethodId") = customerContactMethodId THEN 
            contactMethodSelected = "selected"
            contactMethodName = contactMethodRS("name")
        END IF
%>
            <option value="<%= contactMethodRS("customerContactMethodId") %>" <%= contactMethodSelected %>><%= contactMethodRS("name") %></option>
<%
        contactMethodRS.MoveNext
    LOOP

    contactMethodRS.Close
%>
        </select>
        <input type="hidden" name="customerContactExists" value="<%= customerContactExists %>" />
    </td>
</tr>
<% 
    Dim hideCustomContact : hideCustomContact = ""

    IF customerContactMethodName <> "Contact" THEN 
        hideCustomContact = "class=""hide-contact"""
    END IF
%>
<tr id="tr-contact-display" <%= hideCustomContact %>>
    <td>Contact Name</td>
    <td>&nbsp;</td>
    <td>
<%
        Dim contactRS : SET contactRS = Server.CreateObject("ADODB.RecordSet")
        Dim contactQuery : contactQuery = "SELECT contactId, contactName, useEmail, usePaper FROM contacts ORDER BY contactName"

        contactRS.Open contactQuery, db

        IF NOT contactRS.EOF THEN
            kendoSelectList = kendoSelectList & "customer-contact-id,"

            Dim idx : idx = 0
            DO UNTIL contactRS.EOF
%>
            <input type="hidden" id="contact-use-email-<%=RemoveCurlyBrackets(contactRS("contactId"))%>" value="<%=contactRS("useEmail")%>" />
            <input type="hidden" id="contact-use-paper-<%=RemoveCurlyBrackets(contactRS("contactId"))%>" value="<%=contactRS("usePaper")%>" />
<%
                idx = idx + 1
                contactRS.MoveNext()
            LOOP
%>
        <select id="customer-contact-id" name="customerContactId" onchange="contactNameChanged();">
            <option value="">No Contact Chosen</option>
<%
            contactRS.MoveFirst
            DO UNTIL contactRS.EOF
                Dim contactSelected : contactSelected = ""
                
                IF contactRS("contactId") = customerContactId THEN 
                    contactSelected = "selected"
                    contactSelectedUseEmail = contactRS("useEmail")
                    contactSelectedUsePaper = contactRS("usePaper")
                END IF
%>
            <option value="<%=contactRS("contactId")%>" <%= contactSelected %>><%= contactRS("contactName") %></option>
<%
                contactRS.MoveNext
            LOOP
%>
        </select>
<%
        END IF

        contactRS.Close
%>
    </td>
</tr>
<%
    Dim hideContactMethod : hideContactMethod = ""

    IF customerContactMethodId = "" OR contactMethodName = "Do Not Contact" THEN 
        hideContactMethod = "class=""hide-contact"""
    END IF

    Dim useEmailDisabled : useEmailDisabled = ""
    Dim usePaperDisabled : usePaperDisabled = ""
    Dim usePhoneDisabled : usePhoneDisabled = ""

    IF contactMethodName = "Contact" THEN
        useEmailDisabled = " disabled"
        usePaperDisabled = " disabled"
        usePhoneDisabled = " disabled"

        IF contactSelectedUseEmail THEN useEmailSelected = " checked"
        IF contactSelectedUsePaper THEN usePaperSelected = " checked"
        usePhoneSelected = ""
    END IF
%>
<tr id="tr-contact-method-display" <%= hideContactMethod %>>
    <td>Contact Method</td>
    <td>&nbsp;</td>
    <td>
        <input type="checkbox" class="k-checkbox" id="cb-use-email" name="customerContactUseEmail" value="1" <%=useEmailSelected%> <%=useEmailDisabled%>/><label for="cb-use-email" class="k-checkbox-label">Use Email</label><br \ />
        <input type="checkbox" class="k-checkbox" id="cb-use-paper" name="customerContactUsePaper" value="1" <%=usePaperSelected%> <%=usePaperDisabled%>/><label for="cb-use-paper" class="k-checkbox-label">Use Paper</label><br \ />
        <input type="checkbox" class="k-checkbox" id="cb-use-phone" name="customerContactUsePhone" value="1" <%=usePhoneSelected%> <%=usePhoneDisabled%>/><label for="cb-use-phone" class="k-checkbox-label">Use Phone</label>
    </td>
</tr>
<tr>
    <td>Letter Name:</td>
    <td><input type="hidden" id="hidLockLetterName" name="lockLetterName" value="<%=lockLetterName%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLetterName"></i></td>
    <td><input type="text" class="k-textbox" name="letterName" size="40" value="<%=letterName%>"></td>
</tr>
<% END IF %>
<%
imgLock = "unlock"
IF lockCustomerFirstName THEN imgLock = "lock"
%>
<tr>
    <td>First Name:</td>
    <td><input type="hidden" id="hidLockCustomerFirstName" name="lockCustomerFirstName" value="<%=lockCustomerFirstName%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerFirstName"></i></td>
    <td><input type="text" class="k-textbox" name="customerFirstName" size="40" value="<%= customerFirstName %>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockCustomerMiddleName THEN imgLock = "lock"
%>
<tr>
    <td>Middle Name:</td>
    <td><input type="hidden" id="hidLockCustomerMiddleName" name="lockCustomerMiddleName" value="<%=lockCustomerMiddleName%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerMiddleName"></i></td>
    <td><input type="text" class="k-textbox" name="customerMiddleName" size="40" value="<%= customerMiddleName %>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockCustomerLastName THEN imgLock = "lock"
%>
<tr>
    <td>Last Name:</td>
    <td><input type="hidden" id="hidLockCustomerLastName" name="lockCustomerLastName" value="<%=lockCustomerLastName%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCustomerLastName"></i></td>
    <td><input type="text" class="k-textbox" name="customerLastName" size="40" value="<%=customerLastName%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockAddress1 THEN imgLock = "lock"

IF Session("cifInquiryResult.Address1") <> "" THEN address1 = Session("cifInquiryResult.Address1")
%>
<tr>
    <td>Address 1:</td>
    <td><input type="hidden" id="hidLockAddress1" name="lockAddress1" value="<%=lockAddress1%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockAddress1"></i></td>
    <td><input type="text" class="k-textbox width350" name="address1" size="40" maxlength="128" value="<%=address1%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockAddress2 THEN imgLock = "lock"

IF Session("cifInquiryResult.Address2") <> "" THEN address2 = Session("cifInquiryResult.Address2")
%>
<tr>
    <td>Address 2:</td>
    <td><input type="hidden" id="hidLockAddress2" name="lockAddress2" value="<%=lockAddress2%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockAddress2"></i></td>
    <td><input type="text" class="k-textbox" name="address2" size="40" maxlength="128" value="<%=address2%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockCity THEN imgLock = "lock"

IF Session("cifInquiryResult.City") <> "" THEN city = Session("cifInquiryResult.City")
%>
<tr>
    <td>City:</td>
    <td><input type="hidden" id="hidLockCity" name="lockCity" value="<%=lockCity%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCity"></i></td>
    <td><input type="text" class="k-textbox" name="city" size="40" maxlength="128" value="<%=city%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockState THEN imgLock = "lock"

IF Session("cifInquiryResult.State") <> "" THEN state = Session("cifInquiryResult.State")
%>
<tr>
    <td>State:</td>
    <td><input type="hidden" id="hidLockState" name="lockState" value="<%=lockState%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockState"></i></td>
    <td><input type="text" class="k-textbox" name="state" size="2"  maxlength="2" value="<%=state%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockZip THEN imgLock = "lock"

IF Session("cifInquiryResult.Zip") <> "" THEN zipcode = Session("cifInquiryResult.Zip")
%>
<tr>
    <td>Zip Code:</td>
    <td><input type="hidden" id="hidLockZip" name="lockZip" value="<%=lockZip%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockZip"></i></td>
    <td><input type="text" class="k-textbox" name="zipcode" size="10" maxlength="10" value="<%=zipcode%>"/></td>
</tr>
<tr class="aa-no-background-color">
    <td colspan="3">&nbsp;</td>
</tr>
<%
imgLock = "unlock"
IF lockPhoneHome THEN imgLock = "lock"

IF Session("cifInquiryResult.PhoneHome") <> "" THEN phoneHome = Session("cifInquiryResult.PhoneHome")
%>
<tr>
    <td>Home Phone:</td>
    <td><input type="hidden" id="hidLockPhoneHome" name="lockPhoneHome" value="<%=lockPhoneHome%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockPhoneHome"></i></td>
    <td><input type="text" class="k-textbox" name="phoneHome" size="20" maxlength="20" value="<%=phoneHome%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockPhoneWork THEN imgLock = "lock"

IF Session("cifInquiryResult.PhoneWork") <> "" THEN phoneWork = Session("cifInquiryResult.PhoneWork")
%>
<tr>
    <td>Work Phone:</td>
    <td><input type="hidden" id="hidLockPhoneWork" name="lockPhoneWork" value="<%=lockPhoneWork%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockPhoneWork"></i></td>
    <td><input type="text" class="k-textbox" name="phoneWork" size="20" maxsize="20" value="<%=phoneWork%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockPhoneMobile THEN imgLock = "lock"

IF Session("cifInquiryResult.PhoneMobile") <> "" THEN phoneMobile = Session("cifInquiryResult.PhoneMobile")
%>
<tr>
    <td>Mobile Phone:</td>
    <td><input type="hidden" id="hidLockPhoneMobile" name="lockPhoneMobile" value="<%=lockPhoneMobile%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockPhoneMobile"></i></td>
    <td><input type="text" class="k-textbox" name="phoneMobile" size="20" maxsize="20" value="<%=phoneMobile%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockPhoneFax THEN imgLock = "lock"
%>
<tr>
    <td>Fax Number:</td>
    <td><input type="hidden" id="hidLockPhoneFax" name="lockPhoneFax" value="<%=lockPhoneFax%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockPhoneFax"></i></td>
    <td><input type="text" class="k-textbox" name="phoneFax" size="20" maxsize="20" value="<%=phoneFax%>"/></td>
</tr>
<%
imgLock = "unlock"
IF lockEmail THEN imgLock = "lock"

IF Session("cifInquiryResult.Email") <> "" THEN email = Session("cifInquiryResult.Email")
%>
<tr>
    <td>E-Mail Address:</td>
    <td><input type="hidden" id="hidLockEmail" name="lockEmail" value="<%=lockEmail%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockEmail"></i></td>
    <td><input type="text" class="k-textbox" name="customerEmail" id="customer_email" size="40" value="<%=customerEmail%>"/></td>
</tr>