
<% IF NOT isappStatus AND action <> "NEWAPP" THEN %>
<div id="aa-loan-detail-fields">
    <div class="aa-widget" id="aa-loan-maint-codes">
        <h2 class="top">Loan Details</h2>
        <table class="aa-form-table">
            <tr class="aa-no-background-color">
                <td >General</td>
                <td><i class="aa-icon fas fa-lock no-hover" aria-hidden="true"></i></td>
                <td>Locked from Nightly Updates</td>
            </tr>
            <tr>
                <td><%=accountClassName%> Number:</td>
                <% IF action = "NEWLOAN" THEN %>
                <td>&nbsp;</td>
                <% ELSE %>
                <td></td>
                <% END IF %>
                <% IF action = "NEWLOAN" THEN %>
                <td><script type="text/javascript">
                window.onload = function () {
                    document.frmCustomerMaint.loanNumber.focus();
                }

                function CheckLoanNumber() {
                    var ErrorFound = 0;
                    var c_theLoanNumber = document.frmCustomerMaint.loanNumber;
                    if (c_theLoanNumber.value == '') {
                        alert('You must enter a loan number.');
                        document.frmCustomerMaint.loanNumber.focus();
                        ErrorFound = ErrorFound + 1
                    }
                    if (ErrorFound == 0) {
                        document.frmCustomerMaint.submit();
                    }
                }
                </script>
                <input type="text" class="k-textbox" name="loanNumber" id="loanNumber" value="" size="20" maxlength="255"/></td>
                <%
                ELSE
                    Response.Write "<td>" & loanNumber
                    IF isCrossCollateralYN = "Y" _
                        OR NOT (Session("isSuperUser") OR Session( extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                        OR NOT allowLoanBranchAccess THEN
                    ELSE
                        Response.Write "&nbsp;&nbsp;<a href=""javascript:void(0);"" onclick=""openKendoDialog('Change " & typeNameString & " Number', 'changeloannumbermaint.asp?loanId=" & loanId & "', 400, 550);"" class=""aa-command-link""><i class=""aa-icon fas fa-pencil-alt fa-fw"" title=""Change " & typeNameString & " Number"" aria-hidden=""true""></i></a>"
                    END IF
                    Response.Write "<input type=""hidden"" name=""loanNumber"" value=""" & Server.htmlencode(loannumber) & """/></td>"
                END IF
                %>
            </tr>
            <tr>
                <td><%=accountClassName%> Type:</td>
                <td>&nbsp;</td>
                <td><%=loanLabel%><%
                IF Session("isSuperUser") _
                    OR ((Session(accountClassCode & ".isAdmin") _
                    OR Session(accountClassCode & ".allowEdit") _
                    OR Session(accountClassCode & ".allowAdd")) _
                    AND hasLoanBranchAccess(loanId)) THEN
                    %>&nbsp;&nbsp;<a href="javascript:void(0);" onclick="openKendoDialog('Change <%=accountClassName %> Type', 'loanchangemaint.asp?customerId=<%=customerid%>&amp;loanId=<%=loanId%>&amp;loanTypeId=<%=loanTypeId%>&amp;loanTypeDescr=<%=loanTypeDescription%>&amp;bankId=<%=bankId%>', 500, 700);" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Change <%=accountClassName%> Type" aria-hidden="true"></i></a><%
                END IF
                %></td>
            </tr>
            <tr>
                <td>( Region ) Branch:</td>
                <%
                imgLock = "unlock"
                IF lockBranch THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockBranch" name="lockBranch" value="<%=lockBranch%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockBranch"></i></td>
                <%
                branchClause = ""
                IF Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO" THEN
                    branchClause = _
                        " AND " & _
                        "   (" & _
                        "       branchId = " & dbFormatId(branchId) & " OR " & _
                        "        branchId IN " & _
                        "       (SELECT branchId FROM viewUserBranchSecurity WHERE userId=" & dbFormatId(Session("userId")) & ")" & _
                        "   )"
                END IF

                Set branchRS = Server.CreateObject("ADODB.RecordSet")
                IF Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO" THEN
                    branchQuery = _
                        " SELECT" & _
                        "   br.branchId, br.branchName, br.branchCode, ubs.branchId AS accessBranchId, reg.regionName" & _
                        " FROM" & _
                        "   branch AS br LEFT OUTER JOIN viewUserBranchSecurity AS ubs" & _
                        "       ON br.branchId=ubs.branchId AND ubs.userId=" & dbFormatId(Session("userId")) & _
                        "   LEFT OUTER JOIN region AS reg" & _
                        "       ON reg.regionId=br.regionId" & _
                        " WHERE br.bankId=" & dbFormatId(bankId) & _
                        " ORDER BY" & _
                        "   reg.regionName ASC, br.branchName ASC"
                ELSE
                    branchQuery = _
                        " SELECT" & _
                        "   br.branchId, br.branchName, br.branchCode, br.branchId AS accessBranchId, reg.regionName" & _
                        " FROM" & _
                        "   branch AS br LEFT OUTER JOIN region AS reg" & _
                        "       ON br.regionId=reg.regionId" & _
                        " WHERE br.bankId=" & dbFormatId(bankId) & _
                        " ORDER BY" & _
                        "   reg.regionName ASC, br.branchName ASC"
                END IF
                branchRS.Open branchQuery, db

                ' ### IF PARTIAL OR NO BRANCH SECURITY THEN RESET BRANCH ACCESS ###
                IF (Session("bankSecurity") = "DO" OR Session("bankSecurity") = "XX") THEN
                    allowLoanBranchAccess = hasLoanBranchAccess(loanId)
                END IF

                Dim disableBranch : disableBranch = false
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    disableBranch = true
                END IF

                kendoSelectList = kendoSelectList & "branch-id,"
                IF disableBranch THEN
                    Response.Write "<td><select name=""branchId"" id=""branch-id"" disabled=""disabled"">"
                ELSE
                    Response.Write "<td><select name=""branchId"" id=""branch-id"" onchange=""needsSaved();"">"
                END IF
                branchSelected = ""
                DO UNTIL branchRS.EOF
                    selectBranchId = CheckForNull(branchRS("branchId"))
                    selectBranchName = branchRS("branchName")
                    accessBranchId = CheckForNull(branchRS("accessBranchId"))
                    regionName = CheckForNull(branchRS("regionName"))

                    IF cStr(CheckForNull(selectBranchId)) = cStr(CheckForNull(branchId)) THEN
                        branchSelected = " selected=""selected"""
                    ELSE
                        branchSelected = ""
                    END IF

                    IF Session("isSuperUser") THEN
                        Response.Write "<option value=""" & selectBranchId & """" & branchSelected & ">( " & regionName & " ) " & selectBranchName & "</option>"
                    ELSE
                        IF accessBranchId <> "" OR branchSelected = " selected=""selected""" THEN
                            Response.Write "<option value=""" & selectBranchId & """" & branchSelected & ">( " & regionName & " ) " & selectBranchName & "</option>"
                        END IF
                    END IF
                    branchRS.MoveNext
                LOOP
                Response.Write "</select></td>"
                branchRS.Close
                loanOfficerRS.MoveFirst

                ' ### IF PARTIAL OR NO BRANCH SECURITY THEN OVERRIDE BRANCH ACCESS ###
                IF (Session("bankSecurity") = "DO" OR Session("bankSecurity") = "XX") THEN
                    allowLoanBranchAccess = true
                END IF
                %>
            </tr>
            <tr>
                <td><%=accountClassName%> Officer:</td>
                <%
                imgLock = "unlock"
                IF lockLoanOfficer THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanOfficer" name="lockLoanOfficer" value="<%=lockLoanOfficer%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanOfficer"></i></td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN

                    DO UNTIL loanOfficerRS.EOF
                        IF loanOfficerId = loanOfficerRS("officerid") THEN
                            loanOfficerName = loanOfficerRS("officerName")
                        END IF
                        loanOfficerRS.MoveNext
                    LOOP
                    Response.Write "<td>" & loanOfficerName & "</td>" & vbCr
                ELSE
                    kendoSelectList = kendoSelectList & "loan-officer-id,"
                    Response.Write "<td><select name=""loanOfficerId"" id=""loan-officer-id"" onchange=""needsSaved();"">" & vbCr
                    DO UNTIL loanOfficerRS.EOF
                        htmloption = ""
                        IF loanOfficerId = loanOfficerRS("officerid") THEN htmloption = " selected=""selected"""
                        Response.Write "<option value=""" & loanOfficerRS("officerid") & """ " & htmloption & ">" & loanOfficerRS("officerName") & "</option>" & vbCr
                        loanOfficerRS.MoveNext
                    LOOP
                    Response.Write "</select></td>" & vbCr
                END IF
                %>
            </tr>
            <tr>
                <td><%=accountClassName%> Status:</td>
                <%
                imgLock = "unlock"
                IF lockloanStatus THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanStatus" name="lockloanStatus" value="<%=lockloanStatus%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanStatus"></i></td>
                <%
                IF NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) OR NOT allowLoanBranchAccess THEN
                    DO UNTIL loanStatusRS.EOF
                        IF loanstatusid = loanStatusRS("Statusid") THEN
                            Response.Write "<td>" & loanStatusRS("statusDescription") & "</td>"
                        END IF
                        loanStatusRS.MoveNext
                    LOOP
                ELSE
                    kendoSelectList = kendoSelectList & "loan-status-id,"
                    Response.Write "<td><select name=""loanStatusid"" id=""loan-status-id"" onchange=""needsSaved();"">" & vbCr
                    DO UNTIL loanStatusRS.EOF
                        htmloption = ""
                        IF action = "NEWAPP" THEN
                            IF loanStatusRS("isApplicationStatus") AND loanStatusRS("isDefaultYN") = "Y" THEN
                                htmloption = " selected=""selected"""
                            END IF
                        ELSEIF loanstatusid = loanStatusRS("Statusid") THEN
                            htmloption = " selected=""selected"""
                        END IF
                        Response.Write "<option value=""" & loanStatusRS("Statusid") & """" & htmloption & ">" & loanStatusRS("statusDescription") & "</option>" & vbCr
                        loanStatusRS.MoveNext
                    LOOP
                    Response.Write "</select></td>"
                END IF
                %>
            </tr>
            <% IF lCase(accountClassCode) = "loan" THEN %>
            <tr>
                <td>Loan Classification:</td>
                <%
                imgLock = "unlock"
                IF lockLoanClassificationCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanClassificationCode" name="lockLoanClassificationCode" value="<%=lockLoanClassificationCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanClassificationCode"></i></td>
                <% kendoSelectList = kendoSelectList & "loan-classification-id," %>
                <td><select name="loanClassificationId" id="loan-classification-id" onchange="needsSaved();">
                <%
                Dim loanClassificationRS : Set loanClassificationRS = Server.CreateObject("ADODB.RecordSet")
                Dim loanClassificationQuery : loanClassificationQuery = "SELECT * FROM creditClassification where type = 'loan' ORDER BY classificationCode"
                loanClassificationRS.Open loanClassificationQuery, db
                DO UNTIL loanClassificationRS.EOF
                    strSelected = ""
                    IF cStr(loanClassificationRS("classificationId")) = cStr(loanClassificationId) THEN
                        strSelected = "selected=""selected"""
                    END IF

                    classificationStyle = ""
                    IF loanClassificationRS("displayEmphasis") THEN
                        classificationStyle = "font-weight: bold"
                    ELSE
                        classificationStyle = "font-weight: normal"
                    END IF

                    classificationStyle = classificationStyle & "; color: " & loanClassificationRS("displayColor")
                    Response.Write "<option style=""" & classificationStyle & """ value=""" & loanClassificationRS("classificationId") & """ " & strSelected & ">" & loanClassificationRS("classificationName") & "</option>" & vbCr
                    loanClassificationRS.MoveNext
                LOOP
                loanClassificationRS.Close
                %></select></td>
            </tr>
            <% END IF ' ### IF lCase(accountClassCode) = "loan" THEN %>
            <% IF lCase(accountClassCode) = "loan" THEN %>
            <tr>
                <td>Loan Balance:</td>
                <%
                imgLock = "unlock"
                IF lockLoanAmount THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanAmount" name="lockLoanAmount" value="<%=lockLoanAmount%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanAmount"></i></td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    Response.Write "<td>" & loanAmount & "</td>"
                ELSE
                    Response.Write "<td><input type=""text"" class=""k-textbox"" id=""loan-amount"" name=""loanAmount"" value=""" & loanAmount & """ size=""20"" maxlength=""20"" onchange=""needsSaved();""></td>" & vbCr
                END IF
                %>
            </tr>
            <tr>
                <td>Loan Commitment:</td>
                <%
                imgLock = "unlock"
                IF lockCommitmentAmount THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCommitmentAmount" name="lockCommitmentAmount" value="<%=lockCommitmentAmount%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCommitmentAmount"></i></td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    Response.Write "<td>" & commitmentAmount & "</td>" & vbCr
                ELSE
                    IF IsNumeric(commitmentAmount) THEN
                        commitmentAmount = FormatNumber(commitmentAmount,2,,,0)
                    ELSE
                        commitmentAmount = ""
                    END IF
                    Response.Write "<td><input type=""text"" class=""k-textbox"" id=""commitment-amount"" name=""commitmentAmount"" value=""" & commitmentAmount & """ size=""20"" maxlength=""20"" onchange=""needsSaved();""></td>" & vbCr
                END IF
                %>
            </tr>
            <% END IF ' ### IF lCase(accountClassCode) = "loan" THEN %>
            <%
            Dim origDateLabel : origDateLabel = ""
            IF lCase(accountClassCode) = "deposit" THEN
                origDateLabel = "Deposit Open Date"
            ELSEIF lCase(accountClassCode) = "trust" THEN
                origDateLabel = "Trust Origination Date"
            ELSE
                origDateLabel = "Loan Origination Date"
            END IF
            %>
            <tr>
                <td><%=origDateLabel%>:</td>
                <%
                imgLock = "unlock"
                IF lockLoanOriginationDate THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanOriginationDate" name="lockLoanOriginationDate" value="<%=lockLoanOriginationDate%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanOriginationDate"></i></td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    Response.Write "<td>" & loanOrigDate & "</td>" & vbCr
                ELSE
                %>
                    <td>
                        <ul class="aa-horizontal-list">
                            <li>
                                <input
                                    type="date" 
                                    id="loanOrigDate" 
                                    name="loanOrigDate" 
                                    data-type="date"
                                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                                    data-date-msg="Invalid 'Loan Origination' Date" />
                            </li>
                            <li>
                                <div class="validator-msg">
                                    <span class="k-invalid-msg" data-for="loanOrigDate"></span>
                                </div>
                            </li>
                        </ul>
                    </td>
                <%
                END IF
                %>
            </tr>
            <% IF lCase(accountClassCode) = "loan" THEN %>
            <tr>
                <td>Loan Maturity Date:</td>
                <%
                imgLock = "unlock"
                IF lockLoanMaturityDate THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanMaturityDate" name="lockLoanMaturityDate" value="<%=lockLoanMaturityDate%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanMaturityDate"></i></td>
                <td>
                    <ul class="aa-horizontal-list">
                        <li>
                            <input 
                                type="date" 
                                id="loanMatureDate" 
                                name="loanMatureDate" 
                                data-type="date"
                                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                                data-date-msg="Invalid 'Loan Maturity' Date" />
                        </li>
                        <li>
                            <span class="k-invalid-msg" data-for="loanMatureDate"></span> 
                        </li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td>Loan Closed Date:</td>
                <%
                imgLock = "unlock"
                IF lockLoanClosed THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockLoanClosed" name="lockLoanClosed" value="<%=lockLoanClosed%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanClosed"></i></td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session( extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    Response.Write "<td>" & loanClosed & "</td>" & vbCr
                ELSE
                %>
                    <td>
                        <ul class="aa-horizontal-list">
                            <li>
                                <input 
                                    type="date" 
                                    id="loanClosed" 
                                    name="loanClosed" 
                                    data-type="date"
                                    data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                    data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                                    data-date-msg="Invalid 'Loan Closed' Date" />
                            </li>
                            <li>
                                <span class="k-invalid-msg" data-for="loanClosed"></span>  
                            </li>
                        </ul>
                    </td>    
                <%
                END IF
                %>
            </tr>
            <% END IF ' ### IF lCase(accountClassCode) = "loan" THEN %>
            <% IF action <> "NEWAPP" THEN %>
                <tr>
                    <td><%=accountClassName%> Description:</td>
                    <%
                    imgLock = "unlock"
                    IF lockLoanDescription THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockLoanDescription" name="lockLoanDescription" value="<%=lockLoanDescription%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockLoanDescription"></i></td>
                    <%
                    IF isCrossCollateralYN = "Y" _
                        OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                        OR NOT allowLoanBranchAccess THEN
                        Response.Write "<td>" & loanDescription & "</td>" & vbCr
                    ELSE
                        Response.Write "<td><textarea class=""k-textbox"" name=""loanDescription"" rows=""5"" cols=""60"" onchange=""needsSaved();"">" & loandescription & "</textarea></td>" & vbCr
                    END IF
                    %>
                </tr>
                <tr>
                    <td>Address 1:</td>
                    <%
                    imgLock = "unlock"
                    IF lockAddress1 THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockAddress1" name="lockAddress1" value="<%=lockAddress1%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockAddress1"></i></td>
                    <td><input type="text" class="k-textbox" name="address1" size="40" maxlength="128" value="<%=Address1%>"/></td>
                </tr>
                <tr>
                    <td>Address 2:</td>
                    <%
                    imgLock = "unlock"
                    IF lockAddress2 THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockAddress2" name="lockAddress2" value="<%=lockAddress2%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockAddress2"></i></td>
                    <td><input type="text" class="k-textbox" name="address2" size="40" maxlength="128" value="<%=Address2%>"/></td>
                </tr>
                <tr>
                    <td>City:</td>
                    <%
                    imgLock = "unlock"
                    IF lockCity THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockCity" name="lockCity" value="<%=lockCity%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCity"></i></td>
                    <td><input type="text" class="k-textbox" name="city" size="40" maxlength="128" value="<%=city%>"/></td>
                </tr>
                <tr>
                    <td>State</td>
                    <%
                    imgLock = "unlock"
                    IF lockState THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockState" name="lockState" value="<%=lockState%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockState"></i></td>
                    <td><input type="text" class="k-textbox" name="strState" size="2" maxlength="2" value="<%=strState%>"/></td>
                </tr>
                <tr>
                    <td>Zip Code:</td>
                    <%
                    imgLock = "unlock"
                    IF lockZipcode THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockZipcode" name="lockZipcode" value="<%=lockZipcode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockZipcode"></i></td>
                    <td><input type="text" class="k-textbox" name="zipcode" size="10" maxlength="10" value="<%=zipcode%>"/></td>
                </tr>
                <tr>
                    <td>E-Mail Address:</td>
                    <%
                    imgLock = "unlock"
                    IF lockEmail THEN imgLock = "lock"
                    %>
                    <td><input type="hidden" id="hidLockEmail" name="lockEmail" value="<%=lockEmail%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockEmail"></i></td>
                    <td><input type="text" class="k-textbox" name="email" id="loan-email" size="15" maxlength="128" value="<%=email%>"/></td>
                </tr>
                <% IF Session("acculoan.showParticipationLoan") = 1 AND accountClassName = "Loan" THEN %>
                <tr>
                    <td>Is Participation Loan?</td>
                    <td>&nbsp;</td>
                    <td><input type="checkbox" class="k-checkbox" name="isParticipationLoan" id="isParticipationLoan" value="1"<% IF isParticipationLoan THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="isParticipationLoan">&nbsp;</label></td>
                </tr>
                <% ELSE %>
                <tr class="aa-hidden">
                    <td colspan="3"><input type="hidden" name="isParticipationLoan" id="isParticipationLoan" value="<% IF isParticipationLoan THEN %>1<% ELSE %>0<% END IF %>"/></td>
                </tr>
                <% END IF %>
                <% IF Session("acculoan.showParticipationLoan") = 1 AND accountClassName = "Loan" AND isParticipationLoan THEN %>
                <tr>
                    <td>Push Participation Docs?</td>
                    <td>&nbsp;</td>
                    <td><input type="checkbox" class="k-checkbox" name="pushDocumentControl" id="pushDocumentControl" value="1"<% IF pushDocumentControl THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="pushDocumentControl">Selecting this checkbox will resend all credit, account, and collateral documents to their associated affiliate banks at the end of the day.</label></td>
                </tr>
                <% ELSE %>
                <tr class="aa-hidden">
                    <td colspan="3"><input type="hidden" name="pushDocumentControl" id="pushDocumentControl" value="<% IF pushDocumentControl THEN %>1<% ELSE %>0<% END IF %>"/></td>
                </tr>
                <% END IF %>
                <% IF Session("acculoan.showParticipationLoan") = 1 AND accountClassName = "Loan" AND isParticipationLoan THEN %>
                <tr>
                    <td>Block Participation:</td>
                    <td>&nbsp;</td>
                    <td><input type="checkbox" class="k-checkbox" name="cbBlockParticipation" id="cbBlockParticipationId"<% IF blockParticipation THEN %> checked="checked"<% END IF %> value="1"/><label for="cbBlockParticipationId" class="k-checkbox-label">Yes, Block Loan from Pushing Participation Documents</label></td>
                </tr>
                <% ELSE %>
                <tr class="aa-hidden">
                    <td colspan="3"><input type="hidden" name="cbBlockParticipation" id="cbBlockParticipationId" value="<% IF blockParticipation THEN %>1<% ELSE %>0<% END IF %>"/></td>
                </tr>
                <% END IF ' ### IF Session("acculoan.showParticipationLoan") = 1 %>
            <% END IF ' ### IF action <> "NEWAPP" THEN %>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Administrative</h2></td>
            </tr>
            <tr>
                <td>Lock <%=accountClassName%> Type?</td>
                <td>&nbsp;</td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    IF lockLoanTypeYN = "Y" THEN
                        Response.Write "<td>Yes</td>"
                    ELSE
                        Response.Write "<td>No</td>"
                    END IF
                ELSE
                    kendoSelectList = kendoSelectList & "lock-loantype-yn,"
                    Response.Write "<td><select name=""lockLoanTypeYN"" id=""lock-loantype-yn"" onchange=""needsSaved();"">" & vbCr
                    IF lockLoanTypeYN = "Y" THEN
                        ySelected = "selected=""selected"""
                        nSelected = ""
                    ELSE
                        ySelected = ""
                        nSelected = "selected=""selected"""
                    END IF
                    Response.Write "<option value=""Y"" " & ySelected & ">Yes</option>" & vbCr
                    Response.Write "<option value=""N"" " & nSelected & ">No</option>" & vbCr
                    Response.Write "</select></td>" & vbCr
                END IF
                %>
            </tr>
            <%
            imgLock = "unlock"
            IF lockIgnoreExceptionsYN THEN imgLock = "lock"

            IF ignoreExceptionsYN = "Y" THEN
                ySelected = "selected=""selected"""
                nSelected = ""
            ELSE
                ySelected = ""
                nSelected = "selected=""selected"""
            END IF
            IF Session("accuaccount.enableExpress") <> 1 THEN
            %>
            <tr>
                <td>Ignore Exceptions:</td>
                <td><input type="hidden" id="hidLockIgnoreExceptionsYN" name="lockIgnoreExceptionsYN" value="<%=lockIgnoreExceptionsYN%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockIgnoreExceptionsYN"></i></td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session( extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    IF ignoreExceptionsYN = "Y" THEN
                        Response.Write "<td>Yes</td>"
                    ELSE
                        Response.Write "<td>No</td>"
                    END IF
                ELSE
                    kendoSelectList = kendoSelectList & "ignore-exceptions-yn,"
                    Response.Write "<td><select name=""ignoreExceptionsYN"" id=""ignore-exceptions-yn"" onchange=""needsSaved();"">" & vbCr _
                                 & "<option value=""Y"" " & ySelected & ">Yes</option>" & vbCr _
                                 & "<option value=""N"" " & nSelected & ">No</option>" & vbCr _
                                 & "</select></td>" & vbCr
                END IF
                %>
            </tr>
            <% ELSE %>
            <tr class="aa-hidden">
                <td><input type="hidden" name="lockIgnoreExceptionsYN" value="false"/>
                <input type="hidden" name="ignoreExceptionsYN" value="N"/></td>
            </tr>
            <% END IF 'Session("accuaccount.enableExpress") <> 1 %>
            <% IF lCase(accountClassCode) = "loan" THEN %>
            <tr>
                <td>Order #</td>
                <td>&nbsp;</td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    Response.Write "<td>" & orderNumber & "</td>" & vbCr
                ELSE
                    Response.Write "<td><input type=""text"" class=""k-textbox"" name=""orderNumber"" value=""" & orderNumber & """ size=""25"" onchange=""needsSaved();""/></td>" & vbCr
                END IF
                %>
            </tr>
            <% END IF ' ### IF lCase(accountClassCode) = "loan" THEN %>
            <% IF lCase(accountClassCode) = "loan" THEN %>
            <tr>
                <td>Property Description:</td>
                <td>&nbsp;</td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
                    Response.Write "<td>" & PropertyDesc & "</td>" & vbCr
                ELSE
                    Response.Write "<td><textarea name=""PropertyDesc"" class=""k-textbox"" rows=""2"" cols=""40"" onchange=""needsSaved();"">" & PropertyDesc & "</textarea></td>" & vbCr
                END IF
                %>
            </tr>
            <%
            END IF ' ### IF lCase(accountClassCode) = "loan" THEN

            IF CanAccessPurge() AND loanTypePurgeControl <> "0" THEN
            imgLock = "unlock"
            IF lockPurgeStatusLock THEN imgLock = "lock"
            %>
            <tr>

                <td>Purge Status:</td>
                <td><input type="hidden" id="hidLockPurgeStatus" name="purgeStatusLock" value="<%=lockPurgeStatusLock%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockPurgeStatus"></i></td>
                <% kendoSelectList = kendoSelectList & "purge-status-field," %>
                <td><select name="ddPurgeStatus" id="purge-status-field" onchange="needsSaved();">
                <option value="1"<% IF purgeStatus THEN %> selected="selected"<% END IF %>>Yes</option>
                <option value="0"<% IF NOT purgeStatus THEN %> selected="selected"<% END IF %>>No</option>
                </select></td>
            </tr>
            <% ELSE %>
            <tr class="aa-hidden">
                <td colspan="3"><input type="hidden" name="purgeStatusLock" value="0"/>
                <input type="hidden" name="ddPurgeStatus" value="0"/></td>
            </tr>
            <% END IF ' ### IF CanAccessPurge() %>
            <%
            ' ### Only include this section if not an application status. This code is the same
            ' in the include/loanmaintapplication.asp page and we don't want to duplicated fields. ###
            IF g_accountFieldDefCount > 0 AND action = "EDITLOAN" AND NOT isAppStatus THEN
            %>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Additional Account Information</h2></td>
            </tr>
            <%
            Dim accountFieldQuery : accountFieldQuery = _
                " SELECT lf.*" & _
                " FROM loan AS l LEFT OUTER JOIN loanFields AS lf" & _
                "   ON l.loanId = lf.loanId" & _
                " WHERE" & _
                " l.loanId=" & dbFormatId(loanId)
            Dim accountFieldsRS : Set accountFieldsRS = db.Execute(accountFieldQuery)

            Dim defaultStatusQuery, defaultStatusRS
            Dim fieldDefId, fieldDefName, fieldDefLabel
            Dim fieldDefIsDisplayable
            Dim fieldDefDataType, fieldDefDataSize, fieldDefAccountClassId
            Dim fieldDefChoiceList, fieldDefChoiceDefaultValue
            Dim fieldDefIsCovenant, fieldSize, fieldPrecision
            Dim formType, formSize, formMaxLength

            ' ### NOTE TO DEVELOPERS ###
            ' WHEN MODIFIYING THE FLEX FIELD LOOPING, PLEASE BE SURE TO MODIFY LOAN APPLICATION
            ' MAINTENANCE (loanmaintapplication.asp) AS THIS SAME LOOPING APPEARS THERE TOO.
            FOR i = 0 TO g_accountFieldGroupCount - 1
                fieldSize = ""
                fieldPrecision = ""
                fieldDefGroupId = g_accountFieldGroupList(FDG_ID,i)
                fieldDefGroupLabel = g_accountFieldGroupList(FDG_LABEL,i)
                fieldDefGroupName = g_accountFieldGroupList(FDG_NAME,i)
                firstTime = true
                FOR j = 0 TO g_accountFieldDefCount - 1
                    fieldDefId = g_accountFieldDefList(FIELD_DEF_ID ,j)
                    fieldDefName = g_accountFieldDefList(FIELD_DEF_NAME ,j)
                    fieldDefLabel  = g_accountFieldDefList(FIELD_DEF_LABEL,j)
                    fieldDefIsDisplayable  = g_accountFieldDefList(FIELD_DEF_DISPLAYABLE,j)
                    fieldDefDataType  = g_accountFieldDefList(FIELD_DEF_DATA_TYPE,j)
                    fieldDefDataSize = g_accountFieldDefList(FIELD_DEF_DATA_SIZE,j)
                    fieldDefAccountClassId = g_accountFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,j)
                    fieldDefChoiceList = g_accountFieldDefList(FIELD_DEF_CHOICE_LIST,j)
                    fieldDefChoiceDefaultValue = g_accountFieldDefList(FIELD_DEF_CHOICE_DEFAULT_VALUE,j)
                    fieldGroupId = g_accountFieldDefList(FIELD_DEF_GROUP_ID,j)

                    ' ### Covenant related fields ###
                    fieldDefIsCovenant = Trim(g_accountFieldDefList(FIELD_DEF_IS_COVENANT, j))
                    CovenantDefaultTestFrequency = Trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,j))
                    CovenantDefaultMinValue = Trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,j))
                    CovenantDefaultMaxValue = Trim(g_accountFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,j))

                    IF fieldGroupId = fieldDefGroupId THEN
                        formSize = "20"
                        formMaxLength = ""

                        fieldValue = ""
                        IF NOT accountFieldsRS.EOF THEN
                            fieldValue = accountFieldsRS(fieldDefName)
                        END IF

                        IF IsNull(accountFieldsRS(fieldDefName & "_isActive")) THEN
                            ' ### Get the accurate status of the flex field for when value is NULL ###
                            defaultStatusQuery = _
                                " SELECT cast(IsActive as int) AS IsActive" & _
                                " FROM fieldDefinition" & _
                                " WHERE" & _
                                " (fieldDefId = " & dbFormatId(fieldDefId) & ")"
                            Set defaultStatusRS = db.Execute(defaultStatusQuery)
                            fieldIsActive = defaultStatusRS("IsActive")
                        ELSEIF accountFieldsRS(fieldDefName & "_isActive") THEN
                            fieldIsActive = 1
                        ELSE
                            fieldIsActive = 0
                        END IF

                        IF fieldDefDatatype = "varchar" THEN
                            IF fieldDefDataSize > 60 THEN
                                formSize = 60
                            ELSE
                                formSize = fieldDefDataSize
                            END IF
                            formMaxLength = fieldDefDataSize
                        ELSEIF fieldDefDataType = "datetime" THEN
                            formMaxLength = "10"
                        ELSEIF fieldDefDataType = "money" AND IsNumeric(fieldValue) THEN
                            IF fieldValue = "" THEN
                                fieldValue = 0
                            END IF
                            fieldValue = FormatCurrency(fieldValue,2)
                        END IF

                        Dim fieldActiveIcon, fieldActiveStatus
                        IF fieldIsActive THEN
                            fieldActiveIcon = "aa-icon fas fa-circle aa-status-yes fa-fw"
                            fieldActiveStatus = "Active Field"
                        ELSE
                            fieldActiveIcon = "aa-icon fas fa-circle aa-status-no fa-fw"
                            fieldActiveStatus = "Inactive Field"
                        END IF

                        IF fieldDefIsDisplayable AND fieldDefAccountClassId = accountClassId THEN
                            IF firstTime THEN
                                firstTime = false
                                %>
                                <tr class="aa-flexfield-header">
                                    <td colspan="3"><%=fieldDefGroupLabel%></td>
                                </tr>
                                <%
                            END IF ' ### firstTime

                            Dim covenantException, covenantOutOfDate, covenantMinValue
                            Dim covenantMaxValue, covenantTestFrequency, covenantLastTestDate

                            Dim covenant : covenant = GetAccountCovenant(loanId, fieldDefId)
                            Dim covenantId : covenantId = Trim(covenant(COVENANT_ID, 0))

                            ' ### Get the Covenant Values ###
                            IF covenantId = "" THEN
                                ' ### Covenant Record does not exist, use defaults
                                CovenantMinValue = CovenantDefaultMinValue
                                CovenantMaxValue = CovenantDefaultMaxValue
                                CovenantTestFrequency = CovenantDefaultTestFrequency
                            ELSE
                                Dim useMaster : useMaster = cBool(Trim(covenant(COVENANT_USE_MASTER,0)))
                                IF useMaster THEN
                                    CovenantMinValue = Trim(covenant(COVENANT_DEFAULT_MIN_VALUE, 0))
                                    CovenantMaxValue = Trim(covenant(COVENANT_DEFAULT_MAX_VALUE, 0))
                                ELSE
                                    CovenantMinValue = Trim(covenant(COVENANT_MIN_VALUE, 0))
                                    CovenantMaxValue = Trim(covenant(COVENANT_MAX_VALUE, 0))
                                END IF
                                CovenantLastTestDate = Trim(covenant(COVENANT_LAST_TEST_DATE, 0))
                                CovenantTestFrequency = Trim(covenant(COVENANT_TEST_FREQUENCY, 0))
                            END IF

                            covenantException = IsCovenantException(fieldValue, CovenantMinValue, CovenantMaxValue)
                            covenantOutOfDate = IsCovenantOutOfDate(CovenantLastTestDate, CovenantTestFrequency)
                            %>
                            <tr>
                                <td><%=fieldDefLabel%></td>
                                <td colspan="2">
                                    <ul class="aa-flexfield-list">
                                        <li class="status-icon"><a href="javascript:void(0);" id="link_flex_<%=fieldDefName%>_isActive" class="aa-command-link"><i class="<%=fieldActiveIcon%>" id="img_flex_<%=fieldDefName%>_isActive" title="<%=fieldActiveStatus%> - Click to Change" aria-hidden="true"></i><input type="hidden" id="id_flex_<%=fieldDefName%>_isActive" name="flex_<%=fieldDefName%>_isActive" value="<%=fieldIsActive%>"/></a></li>
                                        <%
                                        IF fieldDefIsCovenant THEN
                                            Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?loanId=" & loanId & "&fieldDefId=" & fieldDefId & "', 500, 700);"" class=""aa-command-link""><i class=""aa-icon fas fa-pencil-alt fa-fw"" title=""Edit Covenant"" aria-hidden=""true""></i></a></li>" & vbCr
                                        ELSE
                                            Response.Write "<li><i class=""aa-icon fas fa-pencil-alt fa-fw aa-partial"" aria-hidden=""true""></i></li>"
                                        END IF

                                        IF fieldDefIsCovenant AND covenantException THEN
                                            Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-full aa-color-danger"" title=""Covenant Exception"" aria-hidden=""true""></i></li>" & vbCr
                                        ELSE
                                            Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-partial"" aria-hidden=""true""></i></li>"
                                        END IF

                                        IF fieldIsActive THEN
                                            IF fieldDefIsCovenant AND covenantOutOfDate THEN
                                                Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?loanId=" & loanId & "&fieldDefId=" & fieldDefId & "', 500, 700);"" class=""aa-command-link""><i class=""aa-icon fas fa-bell fa-fw"" title=""Covenant Value Requires Review"" aria-hidden=""true""></i></a></li>" & vbCr
                                            ELSE
                                                Response.Write "<li><i class=""aa-icon fas fa-bell fa-fw aa-partial"" aria-hidden=""true""></i></li>"
                                            END IF
                                        ELSE
                                            Response.Write "<li><i class=""aa-icon fas fa-bell fa-fw aa-partial"" aria-hidden=""true""></i></li>"
                                        END IF

                                        IF fieldDefDataType = "choice" THEN
                                            choiceList = ""
                                            IF Trim(fieldDefChoiceList & "") <> "" THEN choiceList = Split(fieldDefChoiceList, "||")
                                            Call BuildFieldSelectElement2(fieldDefName, choiceList, fieldValue, fieldDefChoiceDefaultValue)
                                        ELSEIF fieldDefDataType = "bit" THEN
                                            IF fieldValue = "" THEN
                                                fieldValue = "0"
                                            END IF
                                            %><li class="checkbox"><input type="checkbox" class="k-checkbox" name="flex_<%=fieldDefName%>" id="flex_<%=fieldDefName%>" value="1"<% IF fieldValue THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="flex_<%=fieldDefName%>"></label></li><%
                                        ELSEIF fieldDefDataType = "varchar" AND fieldDefDataSize > 128 THEN
                                            %><li><textarea name="flex_<%=fieldDefName%>" class="k-textbox" cols="40" rows="5" maxlength="<%=formMaxLength%>"><%=fieldValue%></textarea></li><%
                                        ELSE
                                            IF fieldDefDataType = "money" THEN
                                                fieldType = "Currency"
                                                IF IsNumeric(fieldValue) THEN fieldValue = FormatCurrency(fieldValue,2)
                                            ELSEIF fieldDefDataType = "decimal" THEN
                                                fieldType = "Decimal"
                                                Call GetDecimalDetails(fieldDefId)
                                            ELSEIF fieldDefDataType = "int" THEN
                                                fieldType = "Integer"
                                            ELSEIF fieldDefDataType = "datetime" THEN
                                                fieldType = "Date"
                                            ELSE
                                                fieldType = "Text"
                                            END IF
        
                                            IF fieldDefDataType = "decimal" THEN
                                            %>
                                            <li><input type="text" name="flex_<%=fieldDefName%>" class="k-textbox" size="<%=formSize%>" maxlength="<%=formMaxLength%>" value="<%=fieldValue%>" onblur="Validate<%=fieldType%>Field(this, <%=fieldSize-fieldPrecision%>, <%=fieldPrecision%>);"/></li>
                                            <% ELSE %>
                                            <li><input type="text" name="flex_<%=fieldDefName%>" class="k-textbox" size="<%=formSize%>" maxlength="<%=formMaxLength%>" value="<%=fieldValue%>" onblur="Validate<%=fieldType%>Field(this);"/></li>
                                            <%
                                            END IF
                                        END IF
                                        %>
                                    </ul>
                                </td>
                            </tr>
                            <%
                        END IF ' ### fieldDefIsDisplayable And fieldDefAccountClassId = accountClassId
                    END IF ' ### fieldGroupId = fieldDefGroupId
                NEXT ' ### j
            NEXT ' ### i
            accountFieldsRS.Close
            END IF ' ### gblAccuntfieldDefCount > 0

            ' ### Only display the Actions section on a loan Edit ###
            IF action = "EDITLOAN" THEN
                %>
                <tr class="aa-no-background-color">
                    <td colspan="3"><h2>Actions</h2></td>
                </tr>
                <tr class="aa-no-background-color">
                    <td colspan="3"><a href="javascript:void(0);" onclick="openKendoDialog('Copy <%=accountClassName %> Documents', 'loanrenewalstart.asp?actionType=RENEWAL&sourceCustomerId=<%=customerId%>&sourceLoanId=<%=loan("loanid")%>&accountClassName=<%=accountClassName%>', 500, 750);" class="k-button k-primary"><i class="far fa-copy" aria-hidden="true"></i>&nbsp;&nbsp;Copy Account Documents</a><% IF accountClassCode = "loan" AND Session("enableLoanApprovalsYN") = "Y" THEN %>&nbsp;&nbsp;<a href="javascript:void(0);" onclick="openKendoDialog('Renewal Application', 'loantoapplicationstart.asp?loanId=<%=loan("loanId")%>&loanApplicationId=<%=loanApplicationId%>', 500, 750);" class="k-button k-primary"><i class="fas fa-external-link-square-alt" aria-hidden="true"></i>&nbsp;&nbsp;Renewal Application</a><% END IF %></td>
                </tr>
                <%
            END IF
            %>
        </table>
    </div>
</div>
<% ELSE %>
    <div class="aa-widget" id="aa-loan-maint-codes">
        <h4>This application is Not a Loan Yet</h4>
    </div>
    <input type="hidden" name="loanNumber" value="<%=loannumber%>"/>
<% END IF %>