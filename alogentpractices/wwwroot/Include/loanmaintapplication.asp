<%
Dim loanApplicationId, applicationStatusId
Dim creditAnalysisStatusId, applicatonNumber
Dim applicationDate, primaryCollateralValue
Dim fico, requestedAmount, valuationDate
Dim reqpaymentOptionId, loanClassificationId
Dim assignedAnalystId, assignedAnalystType
Dim assignedLenderId, assignedLenderType
Dim assignedLoanProcessorId, assignedApproverId
Dim assignedApproverType, estimatedCloseDate
Dim probability

Dim loanApplicationQuery, appStatQuery
Dim loanApplicationRS : Set loanApplicationRS = Server.CreateObject("ADODB.RecordSet")

Dim isappStatus : isappStatus = false

IF action = "NEWLOAN" OR action = "NEWAPP" THEN
    loanApplicationId = ""
    applicationStatusId = ""
    declinedReasonId = ""
    creditAnalysisStatusId = ""
    applicatonNumber = ""
    applicationDate = FormatDateTime(now,2)
    primaryCollateralValue = 0.0
    fico = 0
    requestedAmount = 0.0
    valuationDate = ""
    reqpaymentOptionId = ""
    loanClassificationId = ""
    assignedLenderType = ""
    assignedLenderId = ""
    assignedAnalystType = ""
    assignedAnalystId = ""
    assignedApproverType = ""
    assignedApproverId = ""
    assignedLoanProcessorType = ""
    assignedLoanProcessorId = ""
ELSE
    loanApplicationQuery = _
        " SELECT" & _
        "   la.*," & _
        "   loanStatus.*," & _
        "   approval.approvalStatusId," & _
        "   approval.assignedApproverId," & _
        "   approval.assignedApproverType," & _
        "   la.applicationLocked," & _
        "   loanApplicationCondition.approvalCondition," & _
        "   loanApplicationCondition.postApprovalCondition " & _
        " FROM" & _
        "   loan RIGHT OUTER JOIN loanStatus" & _
        "       ON loan.loanStatusId = loanStatus.statusId" & _
        "   LEFT OUTER JOIN loanApplication AS la" & _
        "   LEFT OUTER JOIN loanApplicationCondition" & _
        "       ON la.loanApplicationId = loanApplicationCondition.loanApplicationId" & _
        "       ON loan.loanId = la.loanId" & _
        "   LEFT OUTER JOIN approval" & _
        "       ON la.approvalId = approval.approvalId " & _
        " WHERE" & _
        "   la.loanId = " & dbFormatId(loanId)
    loanApplicationRS.Open loanApplicationQuery, db
    IF NOT loanApplicationRS.EOF THEN
        applicationNumber = loanApplicationRS("applicationNumber")
        loanApplicationId = loanApplicationRS("loanApplicationId")
        applicationStatusId = loanApplicationRS("statusId")
        loanStatusId = loanApplicationRS("statusId")
        creditAnalysisStatusId = CheckForNull(loanApplicationRS("creditAnalysisStatusId"))
        applicatonNumber = loanApplicationRS("applicationNumber")
        applicationDate = loanApplicationRS("applicationDate")
        primaryCollateralValue = loanApplicationRS("primaryCollateralValue")
        fico = loanApplicationRS("fico")
        requestedAmount = loanApplicationRS("requestedAmount")
        valuationDate = loanApplicationRS("valuationDate")
        repaymentOption = checkfornull(loanApplicationRS("repaymentOption"))
        assignedAnalystId = CheckForNull(loanApplicationRS("assignedAnalystId"))
        assgnedAnalystType = CheckForNull(loanApplicationRS("assignedAnalystType"))
        analysisStatusId  = CheckForNull(loanApplicationRS("creditAnalysisStatusId"))
        interestRate = CheckForNull(loanApplicationRS("interestRate"))
        assignedLenderId = CheckForNull(loanApplicationRS("assignedLenderId"))
        assignedLenderType = CheckForNull(loanApplicationRS("assignedLenderType"))
        assignedLoanProcessorId = CheckForNull(loanApplicationRS("assignedLoanProcessorId"))
        assignedLoanProcessorType = CheckForNull(loanApplicationRS("assignedLoanProcessorType"))
        assignedApproverId = CheckForNull(loanApplicationRS("assignedApproverId"))
        assignedApproverType = CheckForNull(loanApplicationRS("assignedApproverType"))
        approvalStatusId = CheckForNull(loanApplicationRS("approvalStatusId"))
        declinedReasonId = Trim(loanApplicationRS("declinedReasonId") & "")
        appStatusActive = CheckForNull(loanApplicationRS("isActiveApplicationStatus"))
        preCondition = CheckForNull(loanApplicationRS("approvalCondition"))
        postCondition = CheckForNull(loanApplicationRS("postApprovalCondition"))
        isApprovedApplicationStatus = loanApplicationRS("isApprovedApplicationStatus")

        IF CheckForNull(loanApplicationRS("applicationLocked")) = "" THEN
            appLocked = false
        ELSE
            appLocked = loanApplicationRS("applicationLocked")
        END IF

        IF isBookedLoan THEN
            appLocked = true
        END IF

        IF Trim(CheckForNull(loanApplicationRS("isApplicationStatus"))) = "" THEN
            isappStatus = false
        ELSE
            isappStatus = loanApplicationRS("isApplicationStatus")
        END IF
        
        estimatedCloseDate = CheckForNull(loanApplicationRS("estimatedCloseDate"))
        probability = CheckForNull(loanApplicationRS("probability"))

        IF IsDate(applicationDate) THEN
            applicationDate = FormatDateTime(applicationDate,2)
        END IF

        IF IsDate(estimatedCloseDate) THEN
            estimatedCloseDate = FormatDateTime(estimatedCloseDate,2)
        END IF
    END IF
    loanApplicationRS.Close
END IF

IF (loanApplicationId <> "" OR action = "NEWAPP") THEN %>
<div id="aa-application-fields">
    <div class="aa-widget" id="aa-loan-app-maint">
        <h2 class="top">Loan Application Details</h2>
        <table class="aa-form-table">
            <tr class="aa-no-background-color">
                <td colspan="3">
                    <ul class="aa-loan-app-list">
                        <% IF appLocked THEN %>
                        <li><i class="aa-icon fas fa-lock no-hover" aria-hidden="true"></i>&nbsp;THIS APPLICATION IS LOCKED</li>
                        <% END IF %>
                        <li><a href="#box3">Go to Conditions/History</a></li>
                        <%
                        IF isApprovedApplicationStatus THEN
                            IF Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") _
                            OR Session(extAccountClassCode & ".allowEdit") THEN
                                Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Convert Application to Booked Loan', 'convertapplicationselect.asp?customerId=" & customerId & "&loanId=" & loanId & "&applicationId=" & loanApplicationId & "', 500, 750);"">Convert Application to Booked Loan</a></li>" & vbCr
                            END IF
                        END IF
                        %>
                    </ul>
                </td>
            </tr>
            <% IF loanApplicationId <> "" THEN %>
            <tr class="aa-no-background-color">
                <td><h2>Application</h2></td>
            </tr>
            <tr>
                <td>Application Number:</td>
                <td>&nbsp;</td>
                <td><%=applicationNumber%></td>
            </tr>
            <% END IF %>
            <tr>
                <td><%=accountClassName%> Type:</td>
                <td>&nbsp;</td>
                <td>
                    <ul class="aa-loan-app-list">
                        <li><%=loanLabel%></li>
                        <%
                        IF Session("isSuperUser") _
                            OR ((Session(extAccountClassCode & ".isAdmin") _
                            OR Session(extAccountClassCode & ".allowEdit") _
                            OR Session(extAccountClassCode & ".allowAdd")) _
                            AND hasLoanBranchAccess(loanId) _
                            AND NOT appLocked) THEN
                            Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Change " & accountClassName & " Type', 'loanchangemaint.asp?customerId=" & customerId & "&amp;loanId=" & loanId & "&amp;loanTypeId=" & loanTypeId & "&amp;loanTypeDescr=" & loanTypeDescription & "&amp;bankId=" & bankId & "', 500, 700);"" class=""aa-command-link""><i class=""fas fa-pencil-alt fa-fw"" title=""Change " & accountClassName & " Type"" aria-hidden=""true""></i></a></td>" & vbCr
                        END IF
                        %>
                    </ul>
                </td>
            </tr>
            <tr>
                <td>Application Date:</td>
                <td>&nbsp;</td>
                <% 
                    IF NOT appLocked THEN 
                        dateFields = dateFields & "applicationDate,"
                %>
                <td>
                    <ul class="aa-horizontal-list">
                        <li>
                            <input 
                                type="date" 
                                id="applicationDate" 
                                name="applicationDate" 
                                data-type="date"
                                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" 
                                data-date-msg="Invalid 'Application' Date" />
                        </li>
                        <li>
                            <span class="k-invalid-msg" data-for="applicationDate"></span>
                        </li>
                    </ul>
                </td>
                <% ELSE %>
                <td><%=applicationDate%></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Estimated Close Date:</td>
                <td>&nbsp;</td>
                <% 
                    IF NOT appLocked THEN 
                        dateFields = dateFields & "estimatedCloseDate,"
                %>
                <td>
                    <ul class="aa-horizontal-list">
                        <li>
                            <input 
                                type="date" 
                                id="estimatedCloseDate" 
                                name="estimatedCloseDate" 
                                data-type="date"
                                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999"
                                data-date-msg="Invalid 'Estimated Closed' Date"/>
                        </li>
                        <li>
                            <span class="k-invalid-msg" data-for="estimatedCloseDate"></span>
                        </li>
                    </ul>
                </td>
                <% ELSE %>
                <td><%=estimatedCloseDate%></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Probability Of Closing:</td>
                <td>&nbsp;</td>
                <%
                IF checkfornull(probability) = "" THEN
                    prob = ""
                ELSE
                    prob = cInt(cDbl(probability))
                END IF
                IF NOT appLocked THEN
                %>
                <td><input type="text" class="k-textbox" id="probability" name="probability" size="10" maxlength="10" value="<%=prob%>" onchange="needsSaved();"/></td>
                <% ELSE %>
                <td><%=prob%></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Address 1:</td>
                <td>&nbsp;</td>
                <td><input type="text" class="k-textbox" name="address1" size="40" maxlength="128" value="<%=Address1%>"<% IF appLocked THEN %> disabled="disabled"<% END IF %>/></td>
            </tr>
            <tr>
                <td>Address 2:</td>
                <td>&nbsp;</td>
                <td><input type="text" class="k-textbox" name="address2" size="40" maxlength="128" value="<%=Address2%>"<% IF appLocked THEN %> disabled="disabled"<% END IF %>/></td>
            </tr>
            <tr>
                <td>City:</td>
                <td>&nbsp;</td>
                <td><input type="text" class="k-textbox" name="city" size="40" maxlength="128" value="<%=city%>"<% IF appLocked THEN %> disabled="disabled"<% END IF %>/></td>
            </tr>
            <tr>
                <td>State:</td>
                <td>&nbsp;</td>
                <td><input type="text" class="k-textbox" name="strState" size="2" maxlength="2" value="<%=strState%>"<% IF appLocked THEN %> disabled="disabled"<% END IF %>/></td>
            </tr>
            <tr>
                <td>Zip Code:</td>
                <td>&nbsp;</td>
                <td><input type="text" class="k-textbox" name="zipcode" size="10" maxlength="10" value="<%=zipcode%>"<% IF appLocked THEN %> disabled="disabled"<% END IF %>/></td>
            </tr>
            <tr>
                <td>E-Mail Address:</td>
                <td>&nbsp;</td>
                <td>
                    <input type="text" class="k-textbox" name="email" id="loan-email" size="15" maxlength="128" value="<%=email%>"<% IF appLocked THEN %> disabled="disabled"<% END IF %>/>
                </td>
            </tr>
            <%
            IF CanAccessPurge() AND loanTypePurgeControl <> "0" THEN
                IF lockPurgeStatusLock THEN
                    imgLock = "lock"
                ELSE
                    imgLock = "unlock"
                END IF
                IF NOT appLocked THEN
                    kendoSelectList = kendoSelectList & "la-purge-status,"
                    %>
                    <tr>
                        <td>Purge Status:</td>
                        <td><input type="hidden" name="purgeStatusLock" id="hidLockPurgeStatus-La" value="<%=lockPurgeStatusLock%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockPurgeStatus-La"></i></td>
                        <td><select name="ddPurgeStatus" id="la-purge-status" onchange="needsSaved();"<% IF appLocked THEN %> disabled="disabled"<%end if %>>
                        <option value="1"<% IF purgeStatus THEN %> selected="selected"<% END IF %>>Yes</option>
                        <option value="0"<% IF NOT purgeStatus THEN %> selected="selected"<% END IF %>>No</option>
                        </select></td>
                    </tr>
                    <%
                END IF
            END IF
            IF extAccountClassCode ="loanapp" THEN %>
                <% IF Session("acculoan.showParticipationLoan") = 1 THEN %>
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
            <% END IF %>
            <% IF extAccountClassCode ="loanapp" THEN %>
                <% IF Session("acculoan.showParticipationLoan") = 1 AND isParticipationLoan THEN %>
                <tr>
                    <td>Push Participation Docs?</td>
                    <td>&nbsp;</td>
                    <td><input type="checkbox" class="k-checkbox" name="pushDocumentControl" id="pushDocumentControl" value="1"<% IF pushDocumentControl THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="pushDocumentControl">Selecting this checkbox will resend all credit, account, and collateral documents to their associated affiliate banks at the end of the day.</label></td>
                </tr>
                <% ELSE %>
                <tr class="aa-hidden">
                    <td colspan="3"><input type="hidden" name="pushDocumentControl" id="pushDocumentControl" value="<% IF pushDocumentControl THEN %>1<% ELSE %>0<% END IF %>"/></td>
                </tr>
                <%
                END IF
            END IF %>
            <% IF extAccountClassCode ="loanapp" THEN %>
                <% IF Session("acculoan.showParticipationLoan") = 1 AND isParticipationLoan THEN %>
                <tr>
                    <td>Block Participation</td>
                    <td>&nbsp;</td>
                    <td><input type="checkbox" class="k-checkbox" name="cbBlockParticipation" id="cbBlockParticipationId"<% IF blockParticipation THEN %> checked="checked"<% END IF %> value="1"/><label class="k-checkbox-label" for="cbBlockParticipationId">Yes, Block Loan from Pushing Participation Documents</label></td>
                </tr>
                <% ELSE %>
                <tr class="aa-hidden">
                    <td colspan="3"><input type="hidden" name="cbBlockParticipation" id="cbBlockParticipationId" value="<% IF blockParticipation THEN %>1<% ELSE %>0<% END IF %>"/></td>
                </tr>
                <% END IF
            END IF %>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Collateral</h2></td>
            </tr>
            <tr>
                <td>Loan Description:</td>
                <td>&nbsp;</td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session( extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess OR appLocked THEN
                    %>
                    <td><%=loanDescription%><input type="hidden" name="loanDescription" value="<%=loanDescription %>" /></td>
                <% ELSE %>
                <td><textarea class="k-textbox" name="loanDescription" rows="5" cols="50" onchange="needsSaved();"><%=loandescription%></textarea></td>
                <%
                END IF
        
                IF IsNumeric(primaryCollateralValue) THEN
                    primaryCollateralValue = FormatCurrency(primaryCollateralValue)
                END IF
        
                IF IsNumeric(requestedAmount) THEN
                    requestedAmount = FormatCurrency(requestedAmount)
                END IF
                %>
            </tr>
            <tr>
                <td>Requested Amount:</td>
                <td>&nbsp;</td>
                <% IF NOT appLocked THEN %>
                <td><input type="text" class="k-textbox" id="requestedAmountApp" name="requestedAmount" value="<%=requestedAmount%>" onchange="needsSaved();"/></td>
                <% ELSE %>
                <td><%=requestedAmount%></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Primary Collateral Value:</td>
                <td>&nbsp;</td>
                <% IF NOT appLocked THEN %>
                <td><input type="text" class="k-textbox" name="primaryCollateralValue" value="<%=primaryCollateralValue%>" onchange="needsSaved();"/></td>
                <% ELSE %>
                <td><%=primaryCollateralValue%></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Valuation Date:</td>
                <td>&nbsp;</td>
                <% 
                    IF NOT appLocked THEN 
                        dateFields = dateFields & "valuationDate," 
                %>
                <td>
                    <ul class="aa-horizontal-list">
                        <li>
                            <input 
                                type="date" 
                                id="valuationDate" 
                                name="valuationDate" 
                                data-type="date"
                                data-mindate-msg="Minimum date must be later or equal to 1/1/1753"
                                data-maxdate-msg="Maximum date must be prior or equal to 12/31/9999" 
                                data-date-msg="Invalid 'Valuation' Date"/>
                        </li>
                        <li>
                            <span class="k-invalid-msg" data-for="valuationDate"></span>
                        </li>
                    </ul>
                </td>
                <% ELSE %>
                <td><%=valuationDate%></td>
                <% END IF %>
            </tr>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Lender</h2></td>
            </tr>

            <% initAssignedLenderDropdown = false %>
            <tr>
                <td>Lender:</td>
                <td>&nbsp;</td>
                <% IF (editor OR Session("isLender") OR action="NEWAPP") AND NOT appLocked THEN %>
                    <td>
                        <input id="cbo_lender" name="targetLenderId" onchange="needsSaved();"/>
                        <script id="aa-select-lender-template" type="text/x-kendo-template">
                            <span>
                                <i class="fas fa-#: userIcon #" aria-hidden="true"></i><span class="aa-icon-spacer">#: name #</span>
                            </span>
                        </script>
                        <script type="text/javascript">
                            var lenderSelectData = [];

                            lenderSelectData.push({
                                "name": "Unassigned",
                                "id": "--null",
                                "userIcon": "times"
                            });
                        <%
                            Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
                            userGroupQuery = BuildUserGroupQuery("lender")
                            userGroupRS.Open userGroupQuery, db

                            selectedIndex = 0
                            idx = 0
                            DO UNTIL userGroupRS.EOF
                                idx = idx + 1
                                targetName = userGroupRS("targetName")
                                targetType = userGroupRS("targetType")
                                targetId = userGroupRS("targetId")
                                optionValue = Left(targetType, 1) & ":" & userGroupRS("targetId")

                                IF cStr(assignedLenderId) = cStr(targetId) THEN
                                    selectedIndex = idx
                                END IF

                                userIcon = "user"
                                IF targetType = "group" THEN userIcon = "users" END IF

                                ' Add user/group to datasource
                        %>
                                lenderSelectData.push({
                                    name: "<% response.write targetName %>",
                                    id: "<% response.write optionValue %>",
                                    userIcon: "<% response.write userIcon %>"
                                });
                        <%
                                userGroupRS.MoveNext
                            LOOP
                            userGroupRS.Close
                            
                            initAssignedLenderDropdown = true
                        %>
                            // NOTE: function to initialize is here with the rest but it should
                            // be called in the $(document).ready() as the DOM needs to be fully loaded
                            // before initializing
                            function initializeAssignedLenderDropdown(){
                                $("#cbo_lender").kendoDropDownList({
                                    dataSource: lenderSelectData,
                                    dataTextField: "name",
                                    dataValueField: "id",
                                    valueTemplate:  kendo.template($("#aa-select-lender-template").html()),
                                    template: kendo.template($("#aa-select-lender-template").html())
                                });
    
                                var assignedLenderDropdown = $("#cbo_lender").data("kendoDropDownList");
                                assignedLenderDropdown.select(<% response.write selectedIndex %>);
                            }
                        </script>
                    </td>
                    <% ELSE %>
                    <%
                    IF assignedLenderId <> "" THEN
                        Dim lenderQueryRS : Set lenderQueryRS = Server.CreateObject("ADODB.RecordSet")
                        Dim assignedLenderQuery : assignedLenderQuery = _
                            "SELECT userId AS targetId, userLastName + ', ' + userFirstName + ' ' + userMiddleInitial AS targetName, 'user' AS targetType " & _
                            "FROM [user] AS u " & _
                            "WHERE (userId = '" & assignedLenderId & "')" & _
                            "UNION " & _
                            "SELECT userGroupId AS targetId, userGroupName AS targetName, 'group' AS targetType " & _
                            "FROM userGroup AS g " & _
                            "WHERE (userGroupId = '" & assignedLenderId & "')"
                        lenderQueryRS.Open assignedLenderQuery, db
                        targetName = lenderQueryRS("targetName")
                        targetType = lenderQueryRS("targetType")
                        targetId1 = Left(targetType,1) & ":" & lenderQueryRS("targetId")
                        %>
                        <td><%=lenderQueryRS("targetName") %><input name="targetLenderId" type="hidden" value="<%=targetId1%>"/></td>
                        <% lenderQueryRS.Close() %>
                    <% ELSE %>
                        <td>Unassigned<input name="targetLenderId" type="hidden" value="--null"/></td>
                    <% END IF %>
                <% END IF %>
            </tr>
            <tr>
                <td>Loan Officer:</td>
                <td>&nbsp;</td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT ( Session("isSuperUser") Or Session( extAccountClassCode & ".isAdmin") Or Session( extAccountClassCode & ".allowEdit") Or Session( extAccountClassCode & ".allowAdd")  ) _ 
                    OR NOT allowLoanBranchAccess _
                    OR appLocked THEN
                    DO UNTIL loanOfficerRS.EOF
                        IF loanOfficerId = loanOfficerRS("officerid") THEN
                            loanOfficerName = loanOfficerRS("officerName")
                        END IF
                        loanOfficerRS.MoveNext
                    LOOP
                    %>
                    <td><%=loanOfficerName%></td><%
                    ELSE
                        kendoSelectList = kendoSelectList & "la-loan-officer-id,"
                    %><td><select name="loanOfficerId" id="la-loan-officer-id" onchange="needsSaved();"><%
                    DO UNTIL loanOfficerRS.EOF
                        IF loanOfficerId = loanOfficerRS("officerid") THEN
                            htmloption = " selected=""selected"""
                        ELSE
                            htmloption = ""
                        END IF
                        Response.Write "<option value=""" & loanOfficerRS("officerid") & """" & htmloption & ">" & loanOfficerRS("officerName") & "</option>" & vbCr
                        loanOfficerRS.MoveNext
                    LOOP
                    %></select></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Branch:</td>
                <td>&nbsp;</td>
                <%
                branchClause = ""
                IF Session("bankSecurity") = "DU" OR Session("bankSecurity") = "DO" THEN
                    branchClause = _
                        " AND " & _
                        "   (" & _
                        "       branchId = " & dbFormatId(branchId) & " OR " & _
                        "       branchId IN " & _
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
        
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess THEN
        
                    DO UNTIL branchRS.EOF
                        selectBranchId = branchRS("branchId")
                        selectBranchName = branchRS("branchName")
                        accessBranchId = CheckForNull(branchRS("accessBranchId"))
        
                        IF cStr(CheckForNull(selectBranchId)) = cStr(CheckForNull(branchId)) THEN
                            branchName = selectBranchName
                        END IF
                        branchRS.MoveNext
                    LOOP
                    Response.Write "<td>" & branchName & "</td>" & vbCr
                ELSE
                    kendoSelectList = kendoSelectList & "la-branch-id,"
                    Response.Write "<td><select name=""branchId"" id=""la-branch-id"" onchange=""needsSaved();"">" & vbCr
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
                    Response.Write "</select></td>" & vbCr
                END IF
                branchRS.Close
                %>
            </tr>
            <%
            IF Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") THEN
                admin = true
            END IF
        
            IF Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd") THEN
                editor = true
            END IF
            
                initAssignedProcessorDropdown = false
            %>
            <tr>
                <td>Loan Delegate:</td>
                <td>&nbsp;</td>
                <%
                IF (editor OR session("isLender") OR action="NEWAPP") AND NOT appLocked THEN

                    %>
                    <td>
                        <input id="cbo_processor" name="targetProcessorId" onchange="needsSaved();"/>
                        <script id="aa-select-processor-template" type="text/x-kendo-template">
                            <span>
                                <i class="fas fa-#: userIcon #" aria-hidden="true"></i><span class="aa-icon-spacer">#: name #</span>
                            </span>
                        </script>
                        <script type="text/javascript">
                            var processorSelectData = [];

                            processorSelectData.push({
                                "name": "Unassigned",
                                "id": "--null",
                                "userIcon": "times"
                            });
                        <%
                            Set userGroupRS = Server.CreateObject("ADODB.RecordSet")
                            userGroupQuery = BuildUserGroupQuery("loanprocessor")
                            userGroupRS.Open userGroupQuery, db

                            selectedIndex = 0
                            idx = 0
                            DO UNTIL userGroupRS.EOF
                                idx = idx + 1
                                targetName = userGroupRS("targetName")
                                targetType = userGroupRS("targetType")
                                targetId = userGroupRS("targetId")
                                optionValue = Left(targetType, 1) & ":" & userGroupRS("targetId")

                                IF cStr(assignedLoanProcessorId) = cStr(targetId) THEN
                                    selectedIndex = idx
                                END IF

                                userIcon = "user"
                                IF targetType = "group" THEN userIcon = "users" END IF

                                ' Add user/group to datasource
                        %>
                                processorSelectData.push({
                                    name: "<% response.write targetName %>",
                                    id: "<% response.write optionValue %>",
                                    userIcon: "<% response.write userIcon %>"
                                });
                        <%
                                userGroupRS.MoveNext
                            LOOP
                            userGroupRS.Close

                            initAssignedProcessorDropdown = true
                        %>
                            // NOTE: function to initialize is here with the rest but it should
                            // be called in the $(document).ready() as the DOM needs to be fully loaded
                            // before initializing
                            function initializeAssignedProcessorDropdown(){
                                $("#cbo_processor").kendoDropDownList({
                                    dataSource: processorSelectData,
                                    dataTextField: "name",
                                    dataValueField: "id",
                                    valueTemplate:  kendo.template($("#aa-select-processor-template").html()),
                                    template: kendo.template($("#aa-select-processor-template").html())
                                });
    
                                var assignedProcessorDropdown = $("#cbo_processor").data("kendoDropDownList");
                                assignedProcessorDropdown.select(<% response.write selectedIndex %>);
                            }
                        </script>                      
                    </td>
                <% ELSE %>
                    <%
                    IF assignedLoanProcessorId <> "" THEN
                        Dim processorRS : Set processorRS = Server.CreateObject("ADODB.RecordSet")
                        Dim processorQuery : processorQuery = _
                            "SELECT userId AS targetId, userLastName + ', ' + userFirstName + ' ' + userMiddleInitial AS targetName, 'user' AS targetType " & _
                            "FROM [user] AS u " & _
                            "WHERE (userId = '" & assignedLoanProcessorId & "')" & _
                            "UNION " & _
                            "SELECT userGroupId AS targetId, userGroupName AS targetName, 'group' AS targetType " & _
                            "FROM userGroup AS g " & _
                            "WHERE (userGroupId = '" & assignedLoanProcessorId & "')"
                        processorRS.Open processorQuery, db, adOpenStatic, adCmdText
                        targetName = processorRS("targetName")
                        targetType = processorRS("targetType")
                        targetId2 = Left(targetType,1) & ":" & processorRS("targetId")
                        %>
                        <td><%=processorRS("targetName")%><input name="targetProcessorId" type="hidden" value="<%=targetId2%>"/></td>
                        <% processorRS.Close() %>
                    <% ELSE %>
                        <td>Unassigned<input name="targetProcessorId" type="hidden" value="--null"/></td>
                    <% END IF %>
                <% END IF %>
            </tr>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Terms</h2></td>
            </tr>
            <tr>
                <td>Repayment Option:</td>
                <td>&nbsp;</td>
                <%
                IF isCrossCollateralYN = "Y" _
                    OR NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowEdit") OR Session(extAccountClassCode & ".allowAdd")) _
                    OR NOT allowLoanBranchAccess OR appLocked THEN
                    Response.Write "<td>" & repaymentOption & "</td>" & vbCr
                ELSE
                    Response.Write "<td><input type=""text"" class=""k-textbox"" size=""60"" maxlength=""2048"" name=""repaymentOption"" value=""" & repaymentOption & """/></td>" & vbCr
                END IF
                %>
            </tr>
            <%
            IF NOT (Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin")) THEN
                disabled = true
                dis = "disabled=""disabled"""
            END IF
            %>
            <tr>
                <td>Interest Rate:</td>
                <td>&nbsp;</td>
                <% IF NOT appLocked THEN %>
                <td><input type="text" class="k-textbox" name="interestRate" value="<%=interestRate%>" onchange="needsSaved();"/></td>
                <% ELSE %>
                <td><%=interestRate%></td>
                <% END IF %>
            </tr>
            <tr>
                <td>Credit Score:</td>
                <td>&nbsp;</td>
                <% IF NOT appLocked THEN %>
                <td><input type="text" class="k-textbox" id="fico" name="fico" value="<%=fico%>" maxlength="20" onchange="needsSaved();"/></td>
                <% ELSE %>
                <td><%=fico%></td>
                <% END IF %>
            </tr>
            <%
            ' ### Only include this section if not an application status. This code is the same
            ' in the include/loanmaintdetails.asp page and we don't want to duplicated fields. ###
            IF g_accountFieldDefCount > 0 AND action = "EDITLOAN" AND isAppStatus THEN
            %>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Additional Account Information</h2></td>
            </tr>
            <%
            accountFieldQuery = _
                " SELECT lf.*" & _
                " FROM loan AS l LEFT OUTER JOIN loanFields AS lf" & _
                "   ON l.loanId=lf.loanId" & _
                " WHERE" & _
                " l.loanId=" & dbFormatId(loanId)
            Set accountFieldsRS = db.Execute(accountFieldQuery)

            ' ### NOTE TO DEVELOPERS ###
            ' WHEN MODIFIYING THE FLEX FIELD LOOPING, PLEASE BE SURE TO MODIFY LOAN 
            ' MAINTENANCE (loanmaintdetail.asp) AS THIS SAME LOOPING APPEARS THERE TOO.
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
        
                    IF fieldGroupId = fieldDefGroupId THEN
                        formSize = "20"
                        formMaxLength = ""
                        fieldValue = ""
                        IF NOT accountFieldsRS.EOF THEN
                            fieldValue = accountFieldsRS(fieldDefName)
                        END IF

                        IF ISNULL(accountFieldsRS(fieldDefName & "_isActive")) THEN
                            ' ### GET THE ACCURATE STATUS OF THE FLEX FIELD FOR WHEN VALUE IS NULL ###
                            defaultStatusQuery = _
                                " SELECT " & _
                                "    CAST(IsActive AS INT) AS IsActive" & _
                                " FROM " & _
                                "    fieldDefinition" & _
                                " WHERE" & _
                                "    fieldDefId = " & dbFormatId(fieldDefId)
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
                            IF fieldValue = "" THEN fieldValue = 0
                            fieldValue = FormatCurrency(fieldValue,2)
                        END IF

                        IF fieldIsActive THEN
                            fieldActiveIcon = "aa-icon fas fa-circle aa-status-yes fa-fw"
                            fieldActiveStatus = "Active Field"
                        ELSE
                            fieldActiveIcon = "aa-icon fas fa-circle aa-status-no fa-fw"
                            fieldActiveStatus = "Inctive Field"
                        END IF

                        IF fieldDefIsDisplayable AND fieldDefAccountClassId = accountClassId THEN
                            IF firstTime THEN
                                firstTime = false
                                %>
                                <tr class="aa-flexfield-header">
                                    <td colspan="3"><%=fieldDefGroupLabel%></td>
                                </tr><%
                            END IF ' ### firstTime
                            %>
                            <tr>
                                <td><%=fieldDefLabel%>:</td>
                                <td><a href="javascript:void(0);" id="link_flex_<%=fieldDefName%>_isActive" class="aa-command-link"><i class="<%=fieldActiveIcon%>" id="img_flex_<%=fieldDefName%>_isActive" title="<%=fieldActiveStatus%> - Click to Change" aria-hidden="true"></i><input type="hidden" id="id_flex_<%=fieldDefName%>_isActive" name="flex_<%=fieldDefName%>_isActive" value="<%=fieldIsActive%>"/></a></td>
                                <%
                                IF fieldDefDataType = "choice" then
                                    choiceList = ""
                                    IF Trim(fieldDefChoiceList & "") <> "" THEN choiceList = Split(fieldDefChoiceList, "||")
                                    Call BuildFieldSelectElement3(fieldDefName, choiceList, fieldValue, fieldDefChoiceDefaultValue)
                                ELSEIF fieldDefDataType = "bit" THEN
                                    IF fieldValue = "" THEN fieldValue = "0"
                                    %>
                                    <td><input type="checkbox" class="k-checkbox" name="flex_<%=fieldDefName%>" id="flex_<%=fieldDefName%>" value="1"<% IF fieldValue THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="flex_<%=fieldDefName%>"></label></td>
                                <% ELSEIF fieldDefDataType = "varchar" AND fieldDefDataSize > 128 THEN %>
                                    <td><textarea class="k-textbox document-date" name="flex_<%=fieldDefName%>" cols="40" rows="5"><%=fieldValue%></textarea></td>
                                <% ELSE
                                    IF fieldDefDataType="money" THEN
                                        fieldType = "Currency"
                                        IF IsNumeric(fieldValue) THEN fieldValue = FormatCurrency(fieldValue)
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
                                    <td><input type="text" class="k-textbox" name="flex_<%=fieldDefName%>" size="<%=formSize%>" maxlength="<%=formMaxLength%>" value="<%=fieldValue%>" onblur="Validate<%=fieldType%>Field(this, <%=fieldSize-fieldPrecision%>, <%=fieldPrecision%>);"/></td>
                                    <% ELSE %>
                                    <td><input type="text" class="k-textbox" name="flex_<%=fieldDefName%>" size="<%=formSize%>" maxlength="<%=formMaxLength%>" value="<%=fieldValue%>" onblur="Validate<%=fieldType%>Field(this);"/></td>
                                    <%
                                    END IF
                                END IF
                                %>
                            </tr>
                            <%
                            END IF ' ### fieldDefIsDisplayable And fieldDefAccountClassId=accountClassId
                        END IF ' ### fieldGroupId = fieldDefGroupId
                    NEXT ' ### j
                NEXT ' ### i
                accountFieldsRS.Close
            END IF ' ### gblAccuntfieldDefCount > 0
            %>
            <tr class="aa-no-background-color">
                <td colspan="3"><h2>Conditions</h2></td>
            </tr>
            <tr>
                <td>Pre-Closing:</td>
                <td>&nbsp;</td>
                <td><textarea class="k-textbox conditions" id="TextArea1" cols="20" name="preclosing" rows="5"><%=preCondition%></textarea></td>
            </tr>
            <tr>
                <td>Post-Closing:</td>
                <td>&nbsp;</td>
                <td><textarea class="k-textbox conditions" id="TextArea2" cols="20" name="postclosing" rows="5"><%=postCondition%></textarea></td>
            </tr>
            <% IF loanApplicationId <> "" THEN %>
                <tr class="aa-no-background-color">
                    <td colspan="3" id="box3">
                        <ul class="aa-loan-app-list">
                            <li><h2>Application History</h2></li>
                            <% IF (Session("isAnalyst") OR Session("isApprover") OR Session("isLender")) AND NOT appLocked THEN %>
                            <li><a href="javascript:void(0);" onclick="openKendoDialog('Take Action', 'processactionselect.asp?loanApplicationId=<%=loanApplicationId%>', 600, 800)" class="aa-command-link"><i class="aa-icon fas fa-bolt fa-fw" title="Take Action" aria-hidden="true"></i></a></li>
                            <% END IF %>
                        </ul>
                    </td>
                </tr>
                <tr class="aa-no-background-color">
                    <td colspan="3">
                    <table id="aa-kendo-grid-app-history">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>By</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                    </table>
                    <div id="aa-app-history-scroller">
                        <table id="aa-kendo-grid-app-history2">
                            <tbody>
                                <%
                                Dim applicationHistoryRS : Set applicationHistoryRS = Server.CreateObject("ADODB.RecordSet")
                                Dim applicationHistoryQuery : applicationHistoryQuery = _
                                    "SELECT " & _
                                    "   dateModified, " & _
                                    "   actionTaken, " & _
                                    "   [user].userLastName + ', ' + [user].userFirstName AS usr " & _
                                    "FROM " & _
                                    "   loanApplicationHistory LEFT OUTER JOIN " & _
                                    "       [user] ON loanApplicationHistory.changedByUserId = [user].userId " & _
                                    "WHERE " & _
                                    "   (loanApplicationId = " & dbformatid(loanApplicationId) & ")" & _
                                    "ORDER BY dateModified desc"
                                applicationHistoryRS.Open applicationHistoryQuery, db, adOpenStatic, adCmdText
                                DO UNTIL applicationHistoryRS.EOF
                                    %>
                                    <tr>
                                        <td><%=applicationHistoryRS("dateModified") %></td>
                                        <td><%=applicationHistoryRS("usr")%></td>
                                        <td><%=applicationHistoryRS("actionTaken") %></td>
                                    </tr>
                                    <%
                                    applicationHistoryRS.MoveNext
                                LOOP
                                applicationHistoryRS.Close
                                %>
                            </tbody>
                        </table>
                    </div>
                </td>
            </tr>
        <% END IF ' ### loanApplicationId <> "" %>
        </table>
    </div>
    <input name="isAppLocked" type="hidden" value="<%=appLocked %>"/>
</div>
<% ELSE %>
    <div id="history" style="margin-left:32px; margin-top:20px;">
        <% IF Session("enableLoanApprovalsYN") = "Y" THEN %>
        <table cellspacing="0" cellpadding="0" border="0">
            <tr>
                <td class="fb fi">-No Application For This Loan-</td>
            </tr>
        </table>
        <% END IF %>
    </div>
<% END IF ' ### if loanApplicationId <> "" Or action = "NEWAPP" then %>
<%
FUNCTION BuildUserGroupQuery(target)
    Dim query : query = _
        " select" & _
        "   u.userId AS targetId," & _
        "   u.userFirstName + (CASE WHEN (u.userMiddleInitial = '') THEN '' ELSE ' ' + u.userMiddleInitial END) + ' ' + u.userLastName AS targetName," & _
        "   'user' AS targetType" & _
        " FROM" & _
        "   [user] AS u" & _
        " WHERE" & _
        "   u.inactive LIKE 'N'" & _
        "   AND u.is" & target & "=1" & _
        " UNION" & _
        " SELECT" & _
        "   g.userGroupId As targetId," & _
        "   g.userGroupName As targetName," & _
        "   'group' AS targetType" & _
        " FROM" & _
        "   userGroup AS g" & _
        " WHERE" & _
        "   g.is" & target & "Group=1" & _
        " ORDER BY" & _
        "   targetName"
    BuildUserGroupQuery = query
END FUNCTION
%>