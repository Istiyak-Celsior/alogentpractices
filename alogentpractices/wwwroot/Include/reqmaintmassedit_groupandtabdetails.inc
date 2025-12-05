<form name="frmMaintenance" id="form-definition-maint" action="reqmaintupdatenotice.asp" method="post">
        <input type="hidden" name="action" value="MASSUPDATE"/>
        <input type="hidden" name="objectType" value="<%=objectType%>"/>
        <input type="hidden" name="objectTypeId" value="<%=objectTypeId%>"/>
        <input type="hidden" name="bankId" value="<%=bankId%>"/>
        <input type="hidden" name="updateTimestamp" value="<%=Now()%>"/>
        <div class="aa-button-wrapper-left">
            <ul>
                <li><a href="javascript:void(0);" onclick="validate();" id="updateButton1" class="k-button k-primary">Update</a></li>
                <li><a href="reqmaintenancelist.asp?bankId=<%=bankId%>" class="k-button">Cancel</a></li>
            </ul>
        </div>
        <%
        CONST MAX_COLSPAN     = 13
        Dim index   : index   = 1
        Dim qcIndex : qcIndex = 1
        groupIndex = 0
        Dim oldDocumentTypeId : oldDocumentTypeId = ""
        DO UNTIL documentDefRS.EOF
            IF cStr(oldDocumentTypeId) <> cStr(documentDefRS("documentTypeId")) THEN

            ' ### Write out the closing table block when encountering new document group except for the first time ###
            IF Trim(cStr(oldDocumentTypeId) & "") <> "" THEN
                    Response.Write "</tbody></table>"
                END IF

                IF NOT IsNull(documentDefRS("defaultActivationStatus")) THEN
                    activationStatus = documentDefRS("defaultActivationStatus")
                ELSE
                    activationStatus = documentDefRS("typeActivationStatus")
                END IF

                IF docDefScheduleUnits < 1 THEN docDefScheduleUnits = 1

                Dim blockPurgeFlag : blockPurgeFlag = documentDefRS("BlockPurge")
                IF Trim(blockPurgeFlag & "") = "" THEN blockPurgeFlag = false

                activationStatus = Trim(activationStatus)
                IF activationStatus = "on" THEN
                    selected1 = " selected=""selected"""
                    selected2 = ""
                ELSE
                    selected1 = ""
                    selected2 = " selected=""selected"""
                END IF
                %>
                <div class="aa-group-header">
                    <div>
                        <h2>Group: <%=documentDefRS("documentTypeName")%></h2>
                    </div>
                    <div>
                        <ul>
                            <li>Default Group Activation</li>
                            <li><select name="defaultActivationStatus">
                            <option value="on"<%=selected1%>>Active</option>
                            <option value="off"<%=selected2%>>Inactive</option>
                            </select><input type="hidden" name="orgDefaultActivationStatus" value="<%=activationStatus%>"/></li>
                            <li><a href="typemaintenancelist.asp?activeAccountTab=<%=activeAccountTab%>&activeGroupTab=<%=activeGroupTab%>&activeTypeId=<%=documentDefRS("documentTypeId")%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Manage Groups and Tabs" aria-hidden="true"></i></a></li>
                        </ul>
                    </div>
                </div>
                <table class="aa-kendo-grid">
                    <thead>
                        <tr>
                            <th>Add</th>
                            <th>Import Default</th>
                            <th>Document Tab</th>
                            <th>Folder Name</th>
                            <th>Barcode Id</th>
                            <th style="min-width: 230px">Existing Default Status</th>
                            <th>New Default<br/>Status</th>
                            <th style="min-width: 155px">
                                <div class="clearfix">
                                    <span class="pull-left aa-header-cell">Can Expire /<br/>Default Expiration Date</span>
                                    <span class="pull-right aa-header-cell aa-header-icon">
<i class="aa-icon aa-v-align-middle fas fa-question-circle aa-color-info fa-fw" 
                            aria-hidden="true" 
                            title=
"Specifies a default expiration date that will be used for new documents added to the system for this document tab day-forward. Documents already added to the system will be unaffected.

Leave blank if you do not want new documents to use a default expiration date and prefer to set an expiration date for each document.

Documents that do not have an expiration date or default expiration date but are tracking expiring document exceptions are ignored until an expiration date is specified."></i></span>
                                </div>
                             </th>
                            <th>
                                <div class="clearfix">
                                    <span id="aa-require-qc-header" class="pull-left aa-header-cell">Require<br />QC?</span>
                                    <span class="pull-right aa-header-cell aa-header-icon">
    <i class="aa-icon aa-v-align-middle fas fa-question-circle aa-color-info fa-fw" 
                            aria-hidden="true" 
                            title=
    "Indicates that documents of this type require quality control before they are considered complete. Documents that require quality control that are not approved will have a status that indicates quality control needs to be completed before that document can be used. These documents will still be accessible to users, but they will not be included in audits or shared with participation loans."></i>
                                    </span>
                                </div>
                            </th>
                            <th>
                                <div class="clearfix">
                                    <span id="aa-require-qc-header" class="pull-left aa-header-cell">Critical<br />QC?</span>
                                    <span class="pull-right aa-header-cell aa-header-icon">
    <i class="aa-icon aa-v-align-middle fas fa-question-circle aa-color-info fa-fw" 
                            aria-hidden="true" 
                            title=
    "If documents of this type require QC, you can enable this option to continue to track an active missing or expiring document exception on a document until the document has also been approved."></i>
                                    </span>
                                </div>                            
                            </th>
                            <th>Critical QC<br />as of Date</th>
                            <th>Hidden for<br/>Employees</th>
                            <th>Hide<br/>Tab</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                oldDocumentTypeId = documentDefRS("documentTypeId")
                groupIndex = groupIndex + 1
            END IF ' ### IF cStr(oldDocumentTypeId) <> cStr(documentDefRS("documentTypeId"))

            documentDefExists = false

            ' ### Determine flags based on existance of a document definition ###
            IF IsNull(documentDefRS("documentDefId")) THEN
                disabledFlag = ""
                documentDefId = ""
            ELSE
                documentDefExists = true
                disabledFlag = "disabled"
                documentDefId = documentDefRS("documentDefId")
            END IF

            ' ### Purge Data ###
            purgeControl = documentDefRS("PurgeControl")
            purgeControlDateFieldTable = documentDefRS("PurgeControlDateFieldTable")
            purgeControlDateFieldName = documentDefRS("PurgeControlDateFieldName")
            purgeControlGracePeriod = documentDefRS("PurgeControlGracePeriod")
            purgeControlGracePeriod = purgeControlGracePeriod / 365
            IF documentDefRS("BlockPurge") THEN
                purgeBlock = "1"
            ELSE
                purgeBlock = "0"
            END IF

            ' ### Get default folder name ###
            IF NOT IsNull(documentDefRS("defaultName")) THEN
                folderName = documentDefRS("defaultName")
            ELSEIF NOT IsNull(documentDefRS("subTypeFolderName")) THEN
                folderName = documentDefRS("subTypeFolderName")
            ELSE
                folderName = ""
            END IF

            ' ### Always use "Docs" for the tab folder when commonTabFolderNames is enabled. ###
            IF Session("acculoan.enableCommonTabFolderNames") = "1" THEN folderName = "Docs"

            ' ### Get default status type ###
            IF NOT IsNull(documentDefRS("defaultExistingDocumentStatusType")) THEN
                defaultExistingStatusType = documentDefRS("defaultExistingDocumentStatusType")
            ELSE
                defaultExistingStatusType = "1"
            END IF

            ' ### Get default status type ###
            IF NOT IsNull(documentDefRS("defaultDocumentStatusType")) THEN
                defaultStatusType = documentDefRS("defaultDocumentStatusType")
            ELSE
                IF NOT IsNull(documentDefRS("subTypeDefaultStatus")) THEN
                    defaultStatusType = documentDefRS("subTypeDefaultStatus")
                ELSE
                    defaultStatusType = "1"
                END IF
            END IF

            ' ### Get required expiration date flag ###
            IF NOT IsNull(documentDefRS("requireExpDate")) THEN
                requireExpDate = documentDefRS("requireExpDate")
            ELSEIF NOT IsNull(documentDefRS("subTypeRequireExpDateYN")) THEN
                requireExpDate = documentDefRS("subtypeRequireExpDateYN")
            ELSE
                requireExpDate = "N"
            END IF

            ' ### Get default expiration date ###
            IF IsDate(documentDefRS("defaultExpDate")) THEN
                defaultExpDate = documentDefRS("defaultExpDate")
            ELSE
                defaultExpDate = ""
            END IF

            ' ### Get hide employee flag ###
            hideEmployee = CheckForNull(documentDefRS("hideEmployeeFileYN"))
            IF Trim(hideEmployee & "") = "" THEN hideEmployee = documentDefRS("subTypeHideEmployeeFileYN")

            ' ### Get hide tab flag ###
            hideTabYN = CheckForNull(documentDefRS("hideTabYN"))
            IF Trim(hideTabYN & "") = "" THEN hideTabYN = "N"
            %>
            <tr class="tab-row<% IF NOT IsNull(documentDefRS("documentDefId")) THEN %>-added<% END IF %>">
                <td><%
                IF IsNull(documentDefRS("documentDefId")) THEN
                    %><input type="checkbox" class="k-checkbox" id="documentChecked<%=index%>" name="documentChecked" onclick="ValidateBarcode('barcodeKey<%=index%>', '<%= documentDefRS("documentDefId") %>', 'documentChecked<%=index%>');" value="<%=index%>"/><label class="k-checkbox-label" for="documentChecked<%=index%>"></label><%
                ELSE
                    %><input type="hidden" name="documentChecked" value="<%=index%>"/><%
                END IF
                %><input type="hidden" name="documentIndex" value="<%=index%>"/>
                <input type="hidden" name="documentDefId" value="<%=documentDefId%>"/>
                <input type="hidden" name="documentTypeId" value="<%=documentDefRS("documentTypeId")%>"/>
                <input type="hidden" name="documentSubTypeId" value="<%=documentDefRS("documentSubTypeId")%>"/>
                <input type="hidden" name="groupIndex" value="<%=groupIndex%>"/></td>
                <%
                checked = ""
                IF documentDefRS("isDefault") THEN checked = " checked=""checked"""
                %>
                <td><input type="radio" class="k-radio" name="isDefault" id="is-default-<%=index%>" value="<%=index%>"<%=checked%>/><label class="k-radio-label" for="is-default-<%=index%>"></label></td>
                <td><%
                IF NOT IsNull(documentDefRS("documentDefId")) THEN
                    %><a href="reqmaintedit.asp?reqid=<%=documentDefId%>&reqtype=<%=objectType%>&mode=EDIT&typeId=<%=objectTypeId%>"><%
                END IF
                %><div class="aa-name"><%=Server.HTMLEncode(documentDefRS("documentSubTypeName"))%></div><%
                IF NOT IsNull(documentDefRS("documentDefId")) THEN
                    %></a><%
                END IF
                %></td>
                <td><%=folderName%><input type="hidden" name="folderName" value="<%=folderName%>"/><input type="hidden" name="orgFolderName" value="<%=folderName%>"/></td>
                <% Dim barcodeKey : barcodeKey = documentDefRS("barcodeKey") %>
                <td><input type="text" class="k-textbox aa-barcode-id" id="barcodeKey<%=index%>" name="barcodeKey" size="5" maxlength="12" value="<%=barcodeKey%>" onblur="ValidateBarcode('barcodeKey<%=index%>', '<%= documentDefRS("documentDefId") %>', 'documentChecked<%=index%>');" /><input type="hidden" name="orgBarcodeKey" value="<%=barcodeKey%>"/></td>
                <%
                selected1 = ""
                selected2 = ""
                selected3 = ""
                IF cInt(defaultExistingStatusType) = 1 THEN
                    selected1 = " selected=""selected"""
                ELSEIF cInt(defaultExistingStatusType) = 2 THEN
                    selected2 = " selected=""selected"""
                ELSEIF cInt(defaultExistingStatusType) = 3 THEN
                    selected3 = " selected=""selected"""
                END IF
                %>
                <td>
                    <ul class="aa-horizontal-list">
                        <li><select name="defaultExistingStatusType">
                        <option value="1"<%=selected1%>>Required</option>
                        <option value="2"<%=selected2%>>N/A</option>
                        <option value="3"<%=selected3%>>Waived</option>
                        </select><input type="hidden" name="orgDefaultExistingStatusType" value="<%=defaultExistingStatusType%>"/><%
                        IF documentDefId = "" THEN
                            %><input type="hidden" name="overwriteExistingStatus" value="overwrite"/><%
                        ELSE
                            %></li><li><select name="overwriteExistingStatus">
                        <option value="leave">Leave Existing</option>
                        <option value="overwrite">Overwrite Existing</option>
                        </select><%
                        END IF
                        %></li>
                    </ul>
                </td><%
                selected1 = ""
                selected2 = ""
                selected3 = ""
                IF cInt(defaultStatusType) = 1 THEN
                    selected1 = " selected=""selected"""
                ELSEIF CInt(defaultStatusType) = 2 THEN
                    selected2 = " selected=""selected"""
                ELSEIF cInt(defaultStatusType) = 3 THEN
                    selected3 = " selected=""selected"""
                ELSE
                    ' ### DO NOTHING ###
                END IF
                %><td><select name="defaultStatusType">
                <option value="1"<%=selected1%>>Required</option>
                <option value="2"<%=selected2%>>N/A</option>
                <option value="3"<%=selected3%>>Waived</option>
                </select><input type="hidden" name="orgDefaultStatusType" value="<%=defaultStatusType%>"/></td><%
                selected1 = ""
                selected2 = ""
                IF requireExpDate = false OR requireExpDate = "N" THEN
                    selected1 = " selected=""selected"""
                ELSEIF requireExpDate = true OR requireExpDate = "Y" THEN
                    selected2 = " selected=""selected"""
                END IF
                %><td>
					<select id="requireExpDate_<%=index%>" name="requireExpDate">
                        <option value="0"<%=selected1%>>No</option>
                        <option value="1"<%=selected2%>>Yes</option>
                    </select>
                    <input type="text" class="k-textbox aa-datefield" name="defaultExpDate" size="12" value="<%=defaultExpDate%>"/><input type="hidden" name="orgRequireExpDate" value="<%=requireExpDate%>"/><input type="hidden" name="orgDefaultExpDate" value="<%=defaultExpDate%>"/>
                </td><%
                RequireQc = documentDefRS("RequireQc")
                selected1 = ""
                selected2 = ""
                IF NOT RequireQc THEN
                    selected1 = " selected=""selected"""
                ELSEIF RequireQc THEN
                    selected2 = " selected=""selected"""
                END IF                    
                %><td><select name="RequireQc"  id="aa-require-qc-<%=index%>" onchange="toggleRequireQc(<%=index%>)">
                <option value="False"<%=selected1%>>No</option>
                <option value="True"<%=selected2%>>Yes</option>
                </select><input type="hidden" name="orgRequireQc" value="<%=RequireQc%>"/></td><%

                criticalQc = documentDefRS("criticalQc")
                disabled = "disabled=""true"""
                IF RequireQC THEN
                    disabled = ""
                END IF

                checked = ""
                IF (criticalQc & "") = "" THEN
                    criticalQc = "False"
                END IF

                IF criticalQc THEN
                    checked = "checked=""true"""
                END IF     
                %><td><input type="checkbox" name="criticalQc" id="aa-critical-qc-<%=index%>" value="<%=index%>" onchange="toggleCriticalQc(<%=index%>)" <%=disabled%> <%=checked%> />
                      <input type="hidden" name="orgCriticalQc" value="<%=criticalQc%>" />
                      <input type="hidden" name="criticalQcIndex" value="<%=index%>" /></td>
                <%
                    Dim CriticalQcAsOfDate : CriticalQcAsOfDate = documentDefRS("CriticalQcAsOfDate")

                    IF IsDate(CriticalQCAsOfDate) THEN
                        CriticalQCAsOfDate = FormatDateTime(CriticalQcAsOfDate)
                    ELSE
                        CriticalQCAsOfDate = ""
                    END IF
                %><td>
                    <div id="aa-critical-date-field-<%=index%>">
					<input 
                        type="date" 
                        id="aa-critical-qc-datepicker-<%=index%>" 
                        name="CriticalQCAsOfDate" 
                        required=""
                        validationMessage="Date is Required"
                        data-type="date"
                        data-date-msg="Invalid Date"
                        data-mindate-msg="Date must be later than 1/1/1753"
                        data-maxdate-msg="Date must be prior to 12/31/9999" 
                        />
                    <span class="k-invalid-msg" data-for="CriticalQCAsOfDate"></span>
                    <input type="hidden" id="aa-initial-critical-qc-date-<%=index%>" value="<%=CriticalQcAsOfDate%>" />
                    </div>
                  </td>
                <%
                qcIndex = qcIndex + 1

                selected1 = ""
                selected2 = ""
                IF hideEmployee = "N" THEN
                    selected1 = " selected=""selected"""
                ELSEIF hideEmployee = "Y" THEN
                    selected2 = " selected=""selected"""
                END IF
                %><td><select name="hideEmployee">
                <option value="N"<%=selected1%>>No</option>
                <option value="Y"<%=selected2%>>Yes</option>
                </select><input type="hidden" name="orgHideEmployee" value="<%=hideEmployee%>"/></td><%
                selected1 = ""
                selected2 = ""
                IF hideTabYN = "Y" THEN
                    selected2 = " selected=""selected"""
                ELSE
                    selected1 = " selected=""selected""" ' ### Always default to N if not Y
                END IF
                %><td><select name="hideTabYN">
                <option value="N"<%=selected1%>>No</option>
                <option value="Y"<%=selected2%>>Yes</option>
                </select><input type="hidden" name="orgHideTabYN" value="<%=hideTabYN%>"/></td>
            </tr>
            <%
            ' ### Assume schedule is disabled for UI settings ###
            Dim scheduleStyle : scheduleStyle = "slategrey"
            Dim disabled : disabled = "disabled=""disabled"""
            Dim imgDocSchedule : imgDocSchedule = "Content/Images/Nav/icon-scheduleInactive16.png"
            Dim altDocSchedule : altDocSchedule = "Schedule disabled"
            Dim controls : controls = " style=""display:none"""
            checked = ""
            IF documentDefRS("docDefAllowSchedule") THEN
                scheduleStyle = "slateblue"
                disabled = ""
                checked = "checked=""checked"""
                imgDocSchedule = "Content/Images/Nav/icon-scheduleActive16.png"
                altDocSchedule = "Schedule enabled"
                controls = ""
            END IF

            Dim docDefProcessingDateEnd : docDefProcessingDateEnd = CheckForNull(documentDefRS("docDefProcessingDateEnd"))
            IF IsDate(docDefProcessingDateEnd) THEN
                IF Now() >= cDate(docDefProcessingDateEnd) THEN
                    imgDocSchedule = "Content/Images/Nav/icon-scheduleStopped16.png"
                    altDocSchedule = "Schedule stopped on " & FormatDateTime(docTabProcessingDateEnd,2)
                END IF
            END IF
            %>
            <tr class="tab-row-extras">
                <td>&nbsp;</td>
                <td colspan="<%=MAX_COLSPAN-1%>">
                <div id="scheduleBlock_<%=index%>">
                    <ul class="aa-schedule-list">
                        <li><a href="javascript:void(0);" id="imgSchedule<%=index%>" class="aa-command-link"><i class="aa-icon fas fa-plus-circle fa-fw" id="iconSchedule<%=index%>" aria-hidden="true"></i></a></li>
                        <li><i class="aa-icon fas fa-calendar-alt" aria-hidden="true"></i></li>
                        <li>Manage Document Schedule</li>
                    </ul>
                    <div class="extras-row" id="manageSchedule<%=index%>" style="display:none;">
                        <table class="aa-two-column-form-table scheduling">
                            <tr>
                                <td>Enable Document Scheduling:</td>
                                <td><input type="checkbox" class="k-checkbox" id="chkSchedule<%=index%>" name="docDefAllowSchedule" value="<%=index%>" onclick="toggleScheduleFields(<%=index%>);" <%=checked%>/><label class="k-checkbox-label" for="chkSchedule<%=index%>"></label>
                                <input type="hidden" name="orgDocDefAllowSchedule" value="<%=documentDefRS("docDefAllowSchedule")%>"/></td>
                                <td colspan="6">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>Create Document on:</td>
                                <td><input type="text" class="k-textbox" id="fldSchedule_1_<%=index%>" name="docDefNextCreateDate" value="<%=documentDefRS("docDefNextCreateDate")%>" size="13" maxlength="13" <%=disabled%>/>
                                <a href="javascript:show_calendar('frmMaintenance.fldSchedule_1_<%=index%>');" id="imgCalendar_1_<%=index%>" class="aa-command-link"<%=controls%>><i class="aa-icon fas fa-calendar-alt fa-fw" title="Pick Date" aria-hidden="true"></i></a></td>
                                <td>&nbsp;</td>
                                <td class="highlight">Reoccurs every:</td>
                                <td class="highlight-right"><input type="text" class="k-textbox" id="fldSchedule_2_<%=index%>" name="docDefScheduleUnits" onblur="CheckReoccurValue(<%=index%>, this.value);" value="<%=documentDefRS("docDefScheduleUnits")%>" size="4" maxlength="4" <%=disabled%>/>
                                <select id="fldSchedule_3_<%=index%>" name="docDefSchedulePeriod" <%=disabled%>>
                                <option value="0" <% IF cInt(documentDefRS("docDefSchedulePeriod")) = 0 THEN %> selected="selected"<% END IF %> >Days</option>
                                <option value="1" <% IF cInt(documentDefRS("docDefSchedulePeriod")) = 1 THEN %> selected="selected"<% END IF %> >Months</option>
                                <option value="2" <% IF cInt(documentDefRS("docDefSchedulePeriod")) = 2 THEN %> selected="selected"<% END IF %> >Quarters</option>
                                <option value="3" <% IF cInt(documentDefRS("docDefSchedulePeriod")) = 3 THEN %> selected="selected"<% END IF %> >Years</option>
                                </select></td>
                                <%
                                expPeriodDisabled = ""
                                IF disabled <> "" THEN expPeriodDisabled = "disabled=""disabled"""
                                %>
                                <td colspan="4">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>Schedule Ends:</td>
                                <td><input type="text" class="k-textbox" id="fldSchedule_4_<%=index%>" name="docDefProcessingDateEnd" value="<%=documentDefRS("docDefProcessingDateEnd")%>" size="13" maxlength="13" <%=disabled%>/>
                                <a href="javascript:show_calendar('frmMaintenance.fldSchedule_4_<%=index%>');" id="imgCalendar_2_<%=index%>" class="aa-command-link"<%=controls%>><i class="aa-icon fas fa-calendar-alt fa-fw" title="Pick Date" aria-hidden="true"></i></a></td>
                                <td>&nbsp;</td>
                                <td class="highlight">Doc Expiration Period:</td>
                                <td class="highlight-right"><input id="fldSchedule_5_<%=index%>" type="text" class="k-textbox" name="docDefDocumentExpireUnits" value="<%=documentDefRS("docDefDocumentExpireUnits")%>" size="4" maxlength="4" <%=expPeriodDisabled%>/>
                                <select id="fldSchedule_6_<%=index%>" name="docDefDocumentExpirePeriod" <%=expPeriodDisabled%>>
                                <option value="0" <% IF cInt(documentDefRS("docDefDocumentExpirePeriod")) = 0 THEN %> selected="selected"<% END IF %> >Days</option>
                                <option value="1" <% IF cInt(documentDefRS("docDefDocumentExpirePeriod")) = 1 THEN %> selected="selected"<% END IF %> >Months</option>
                                <option value="2" <% IF cInt(documentDefRS("docDefDocumentExpirePeriod")) = 2 THEN %> selected="selected"<% END IF %> >Quarters</option>
                                <option value="3" <% IF cInt(documentDefRS("docDefDocumentExpirePeriod")) = 3 THEN %> selected="selected"<% END IF %> >Years</option>
                                </select></td>
                                <td colspan="4">&nbsp;</td>
                            </tr>
                            <%
                            ' ### Check to see if TabName tag is in string ###
                            Dim chkTabName : chkTabName = ""
                            IF InStr(lCase(documentDefRS("docDefDocumentTitlePattern")), "<<tabname>>") > 0 THEN chkTabName = "checked=""checked"""

                            ' ### Check to see if crateMonth tag is in string ###
                            Dim chkMonth : chkMonth = ""
                            IF InStr(lCase(documentDefRS("docDefDocumentTitlePattern")), "<<createmonth>>") > 0 THEN chkMonth = "checked=""checked"""

                            ' ### Check to see if createYear tag is in string ###
                            Dim chkYear : chkYear = ""
                            IF InStr(lCase(documentDefRS("docDefDocumentTitlePattern")), "<<createyear>>") > 0 THEN chkYear = "checked=""true"""
                            %>
                            <tr>
                                <td class="<%=scheduleStyle%>">Document Title:&nbsp;</td>
                                <td colspan="4"><input type="text" class="k-textbox doc-title" id="fldSchedule_7_<%=index%>" name="docDefDocumentTitlePattern" value="<%=documentDefRS("docDefDocumentTitlePattern")%>" size="90" maxlength="1024" <%=disabled%>/>
                                <div class="common" id="instructionWarning_<%=index%>" style="display:none;"><i class="aa-icon fas fa-exclamation-triangle aa-color-warning" aria-hidden="true"></i>&nbsp;The Document Title cannot be left blank. Please enter a title for Document Scheduler to generate.</div></td>
                                <td colspan="4">
                                    <ul class="aa-horizontal-list" id="schedule-controls-<%=index%>"<%=controls%>>
                                        <li><a href="javascript:void(0);" onclick="replaceTitleTag(<%=index%>, '<<tabName>>');" class="aa-command-link"><i class="aa-icon fas fa-plus-square fa-fw" id="fldSchedule_8_<%=index%>" title="Add Tab Tag" aria-hidden="true"></i></a>&nbsp;Tab Name</li>
                                        <li><a href="javascript:void(0);" onclick="replaceTitleTag(<%=index%>, '<<createMonth>>');" class="aa-command-link"><i class="aa-icon fas fa-plus-square fa-fw" id="fldSchedule_9_<%=index%>" title="Add Month Tag" aria-hidden="true"></i></a>&nbsp;Month</li>
                                        <li><a href="javascript:void(0);" onclick="replaceTitleTag(<%=index%>, '<<createYear>>');" class="aa-command-link"><i class="aa-icon fas fa-plus-square fa-fw" id="fldSchedule_10_<%=index%>" title="Add Year Tag" aria-hidden="true"></i></a>&nbsp;Year</li>
                                        <li><i class="aa-icon fas fa-question-circle aa-color-info" id="instructions_<%=index%>" title="This field cannot be left blank. Type the desired document title for Document Scheduler to generate. Use the buttons above to create tags within the document title to have Document Scheduler auto generate the field contents for the given tags. For example pressing the Tab Name and Year button will generate a document title with the Tab's name and the year the document is generated." aria-hidden="true"></i></li>
                                    </ul>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                </td>
            </tr>
            <% IF CanAccessPurge() AND Session("acculoan.enablePurgeAdvancedOptions") = "1" THEN %>
            <tr class="tab-row-extras">
                <td>&nbsp;</td>
                <td colspan="<%=MAX_COLSPAN-1%>">
                    <ul class="aa-schedule-list">
                        <li><a href="javascript:void(0);" id="imgPurge<%=index%>" class="aa-command-link"><i class="aa-icon fas fa-plus-circle fa-fw" id="iconPurge<%=index%>" aria-hidden="true"></i></a></li>
                        <li><i class="aa-icon far fa-trash-alt" aria-hidden="true"></i></li>
                        <li>Manage Purge Control</li>
                    </ul>
                    <div class="extras-row" id="managePurge<%=index%>" style="display:none">
                        <table class="aa-two-column-form-table">
                            <tr>
                                <td>Block Purge State:</td>
                                <td><select name="cbPurgeBlock">
                                <option value="0"<% IF NOT cBool(purgeBlock) THEN %> selected="selected"<% END IF %>>No</option>
                                <option value="1"<% IF cBool(purgeBlock) THEN %> selected="selected"<% END IF %>>Yes</option>
                                </select><input type="hidden" name="orgPurgeBlock" value="<%=purgeBlock%>"/></td>
                            </tr>
                            <tr>
                                <td>Purge Control:</td>
                                <td><input type="hidden" name="hidPurgeFieldName" id="idHidPurgeFieldName<%=index%>" value="<%=purgeControlDateFieldName%>"/>
                                <input type="hidden" name="hidPurgeFieldTable" id="idHidPurgeFieldTable<%=index%>" value="<%=purgeControlDateFieldTable%>"/>
                                <input type="hidden" name="orgPurgeFieldName" value="<%=purgeControlDateFieldName%>"/>
                                <input type="hidden" name="orgPurgeFieldTable" value="<%=purgeControlDateFieldTable%>"/><select name="ddPurgeControl" onchange="ShowHideDateComponents(this.value, <%=index%>);">
                                <option value="0"<% IF purgeControl = "0" THEN %> selected="selected"<% END IF %>>No Control</option>
                                <option value="1"<% IF purgeControl = "1" THEN %> selected="selected"<% END IF %>>Manual Purge</option>
                                <% IF (Trim(objectType & "") = "C" AND IsArray(paryFlexFields)) OR Trim(objectType & "") = "L" THEN %><option value="2"<% IF purgeControl = "2" THEN %> selected="selected"<% END IF %>>Date Control</option><% END IF %>
                                </select><input type="hidden" name="orgPurgeControl" value="<%=purgeControl%>"/></td>
                            </tr>
                            <tr <% IF Trim(purgeControl & "") <> "2" THEN %>style="display:none"<% END IF %> id="dateProcessField<%=index%>">
                                <td>Processing Field:</td>
                                <td><select name="ddProcessField" id="idProcessField<%=index%>" onchange="SetProcessFields(this.value, <%=index%>);">
                                <option value="">Select One...</option>
                                <% IF Trim(objectType & "") <> "C" THEN %><option value="AOD"<% IF purgeControlDateFieldTable = "loan" THEN %> selected="selected"<% END IF %>>Account Origination Date</option><% END IF %>
                                    <% IF Trim(objectType & "") <> "C" AND objectCategory = "Loan" THEN %><option value="ACD"<% IF purgeControlDateFieldTable = "loanClosed" THEN %> selected="selected"<% END IF %>>Account Closed Date</option><% END IF %>
                                    <% IF Trim(objectType & "") <> "C" AND objectCategory = "Loan" THEN %><option value="APD"<% IF purgeControlDateFieldTable = "loanApplication" THEN %> selected="selected"<% END IF %>>Application Date</option><% END IF %>
                                <% IF NumFlexFields > 0 THEN %><option value="DFF"<% IF InStr(purgeControlDateFieldName,"flex_") > 0 THEN %> selected="selected"<% END IF %>>Date Flex Field</option><% END IF %>
                                </select></td>
                            </tr>
                            <%
                            IF IsArray(paryFlexFields) THEN
                            Dim HideFlex : HideFlex = False
                            IF Trim(purgeControlDateFieldName & "") <> "" THEN
                                IF InStr(purgeControlDateFieldName,"flex_") = 0 THEN ' Is flex_ missing from the datefieldname
                                    HideFlex = True
                                END IF
                            ELSE
                                IF Trim(purgeControl & "") <> "2" THEN
                                    HideFlex = True
                                END IF
                            END IF
                            %>
                            <tr <% IF HideFlex THEN %>style="display:none"<% END IF %> id="dateFlexField<%=index%>">
                                <td>Flex Field:</td>
                                <td><select name="ddProcessFlexField" id="idFlexField<%=index%>" onchange="SetFlexProcessFields(this.value, <%=index%>);">
                                <option value="">Select One...</option>
                                <% FOR i = 0 TO uBound(paryFlexFields,2) %>
                                <% IF Trim(purgeControlDateFieldName & "") <> "" THEN %>
                                <option value="<%=paryFlexFields(2,i)%>|<%=paryFlexFields(0,i)%>"<% IF cStr(paryFlexFields(0,i)) = cStr(purgeControlDateFieldName) THEN %> selected="selected"<% END IF %>><%=paryFlexFields(1,i)%></option>
                                <% ELSE %>
                                <option value="<%=paryFlexFields(2,i)%>|<%=paryFlexFields(0,i)%>"><%=paryFlexFields(1,i)%></option>
                                <% END IF %>
                                <% NEXT %>
                                </select></td>
                            </tr>
                            <% END IF %>
                            <tr <% IF Trim(purgeControl & "") <> "2" THEN %>style="display:none"<% END IF %> id="gracePeriod<%=index%>">
                                <td>Grace Period:</td>
                                <td>
                                <% orgPurgeGracePeriod = purgeControlGracePeriod %>
                                <% IF Trim(purgeControlGracePeriod & "") = "" THEN purgeControlGracePeriod = "0" %>
                                <table>
                                    <tr>
                                        <td><input type="text" class="k-textbox" name="tbPurgeGracePeriod" id="idPurgeGracePeriod<%=index%>" value="<%=purgeControlGracePeriod%>" maxlength="3"/></td>
                                        <td>Years (Required Field)</td>
                                        <td><input type="hidden" name="orgPurgeGracePeriod" value="<%=orgPurgeGracePeriod%>"/></td>
                                    </tr>
                                </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <% ELSE %>
            <tr>
                <td colspan="2"><input type="hidden" name="hidPurgeFieldName" value=""/>
                <input type="hidden" name="hidPurgeFieldTable" value=""/>
                <input type="hidden" name="orgPurgeFieldName" value=""/>
                <input type="hidden" name="orgPurgeFieldTable" value=""/>
                <input type="hidden" name="cbPurgeBlock" value="0"/>
                <input type="hidden" name="orgPurgeBlock" value="0"/>
                <input type="hidden" name="ddPurgeControl" value="0"/>
                <input type="hidden" name="orgPurgeControl" value="0"/>
                <input type="hidden" name="ddProcessField" value=""/>
                <input type="hidden" name="ddProcessFlexField" value=""/>
                <input type="hidden" name="tbPurgeGracePeriod" value="0"/>
                <input type="hidden" name="orgPurgeGracePeriod" value="0"/>
                <input type="hidden" name="cbPurgeBlock" value="0"/>
                <input type="hidden" name="orgPurgeBlock" value="0"/></td>
            </tr>
            <%
            END IF ' ### IF CanAccessPurge()
            index = index + 1
            documentDefRS.MoveNext
        LOOP
        documentDefRS.Close
        Response.Write "</tbody></table>"
        %>
        <div class="aa-button-wrapper-left">
            <ul>
                <li><a href="javascript:void(0);" onclick="validate();" id="updateButton2" class="k-button k-primary">Update</a></li>
                <li><a href="reqmaintenancelist.asp?bankId=<%=bankId%>" class="k-button">Cancel</a></li>
            </ul>
        </div>
        <input type="hidden" id="aa-index-count" value="<%= index-1 %>" />
    </form>