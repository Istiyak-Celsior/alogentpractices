<%
Dim fromCLAUSE : fromCLAUSE = ""
Dim securityRS : Set securityRS = Server.CreateObject("ADODB.RecordSet")
Dim fromCLAUSE1 : fromCLAUSE1 = _
    " FROM" & _
    "   viewExtendedAccountClass AS ac LEFT OUTER JOIN userAccountSecurity AS uas" & _
    "       ON ac.accountClassCode = uas.accountClassCode" & _
    "       AND uas.userId = " & dbFormatId(userId) & _
    "   LEFT OUTER JOIN [user] AS u" & _
    "       ON u.userId = uas.userId"

Dim fromCLAUSE2 : fromCLAUSE2 = _
    " FROM" & _
    "   viewExtendedAccountClass AS ac LEFT OUTER JOIN userAccountSecurity AS uas" & _
    "       ON ac.accountClassCode = uas.accountClassCode" & _
    "       AND uas.userId IS NULL" & _
    "   LEFT OUTER JOIN [user] AS u" & _
    "       ON u.userId=uas.userId" 

IF mode = "ADD" then
    fromCLAUSE = fromCLAUSE2
ELSE
    fromCLAUSE = fromCLAUSE1
END IF

Dim securityQuery : securityQuery = _
    " SELECT" & _
    "   ac.*," & _
    "   uas.userAccountAccessId," & _
    "   ISNULL(uas.allowRead,0) AS allowRead," & _
    "   ISNULL(uas.allowEdit,0) AS allowEdit," & _
    "   ISNULL(uas.allowAdd,0) AS allowAdd," & _
    "   ISNULL(uas.allowDelete,0) AS allowDelete," & _
    "   ISNULL(uas.allowDocRead,0) AS allowDocRead," & _
    "   ISNULL(uas.allowDocEdit,0) AS allowDocEdit," & _
    "   ISNULL(uas.allowDocAdd,0) AS allowDocAdd," & _
    "   ISNULL(uas.allowDocDelete,0) AS allowDocDelete," & _
    "   ISNULL(uas.allowDocScan,0) AS allowDocScan," & _
    "   ISNULL(uas.allowDocScanDelete,0) AS allowDocScanDelete," & _
    "   ISNULL(uas.allowDocUpload,0) AS allowDocUpload," & _
    "   ISNULL(uas.allowDocMoveCopy,0) AS allowDocMoveCopy," & _
    "   ISNULL(uas.isAdmin,0) AS isAdmin," & _
    "   ISNULL(u.isSuperUser,0) AS isSuperUser" & _
    fromCLAUSE & _
    " ORDER BY" & _
    "   ac.accountClassSortOrder"
securityRS.CursorLocation = adUseClient ' Allows getting the RecordCount value from the result set
securityRS.Open securityQuery, db

Dim maxAccountClassCount : maxAccountClassCount = 0

IF NOT securityRS.EOF THEN
    maxAccountClassCount = securityRS.RecordCount
END IF
%>
<script type="text/javascript">
    var classChecked = "aa-icon fas fa-check aa-color-success aa-has-hover";
    var classUncheckedHighlight = "aa-icon fas fa-check aa-tick aa-has-hover";
    var classUncheckedHover = "aa-icon fas fa-check aa-tick-highlight aa-has-hover";
    var classUnchecked = "aa-icon fa aa-tick aa-has-hover";

    function getSecurityStatusClass(showCheckMark) {
        if (showCheckMark) {
            displayClass = classChecked;
        }
        else {
            displayClass = classUnchecked;
        }
        return displayClass;
    }

    function onToggleStatus(obj, typeIdx, statusIdx) {
        var statusId = "#status_" + typeIdx + "_" + statusIdx;
        var adminStatusId = "#status_" + typeIdx + "_" + 13;

        // Get new checked state based on the current class of object clicked
        var currentValue = $(obj).attr('class');
        var isChecked;
        if (currentValue.indexOf('aa-color-success') >= 0) {
            isChecked = false;
        } 
        else {
            isChecked = true;
        }

        if (!skipToggle(typeIdx, statusIdx)) {
            setStatus(isChecked, typeIdx, statusIdx);

            // toggle all settings for current type if Admin selected
            if (statusIdx == 13) {
                for (i = 1; i < 13; i++) {
                    setStatus(isChecked, typeIdx, i);
                }
            }

            // Ensure Credit-Read is active if any Account-Read is active
            if (typeIdx > 0 && statusIdx == 1 && isChecked) {
                setStatus(isChecked, 0, 1);
            }

            // Ensure Document-Read is active if any Document settings are active
            for (i = 0; i <= 4; i++) {
                for (j = 6; j <= 12; j++) {
                    fieldId = "#status_" + i + "_" + j;
                    if ($(fieldId).attr("value") == 1) {
                        setStatus(true, i, 5);
                    }
                }
            }

            // Ensure Record-Read is active if any of Record or Document settings are active
            for (i = 0; i <= 4; i++) {
                for (j = 2; j <= 12; j++) {
                    fieldId = "#status_" + i + "_" + j;
                    if ($(fieldId).attr("value") == 1) {
                        setStatus(true, i, 1);
                    }
                }
            }

            // Ensure Loan-Read is active if Application-Read is active
            if ($("#status_2_1").attr("value") == 1) {
                setStatus(true, 1, 1);
            }

            // Ensure Credit-Read is active if any Account-Read type is active
            for (i = 1; i <= 4; i++) {
                if ($("#status_" + i + "_1").attr("value") == 1) {
                    setStatus(true, 0, 1);
                }
            }

            // Reset to checked-hover icon if unchecked.
            if (!isChecked) {
                $('#status-check_' + typeIdx + '_' + statusIdx).attr('class', classUncheckedHover);
            }

            updateStatusHoverPointer();
        }
    }

    function skipToggle(typeIdx, statusIdx) {
        skip = false;
        // Determine if toggle should be skipped because of minimum settings
        // Skip if using is SU
        if ($('#chkIsSuperUser').prop('checked')) {
            skip = true;
        }

        // Skip if  the toggled status is of a type the user is an Admin for
        if ($("#status_" + typeIdx + "_" + 13).attr("value") == 1 && statusIdx >= 1 && statusIdx <= 12) {
            skip = true;
        }

        // If Record-Read clicked, ignore if any Record or Document status selected
        if (statusIdx == 1) {
            for (i = 2; i <= 12; i++) {
                if ($("#status_" + typeIdx + "_" + i).attr("value") == "1") {
                    skip = true;
                }
            }
        }

        // If Document-Read clicked, ignore if any document status checked
        if (statusIdx == 5) {
            for (i = 6; i <= 12; i++) {
                if ($("#status_" + typeIdx + "_" + i).attr("value") == "1") {
                    skip = true;
                }
            }
        }

        // Skip if the toggled status is Credit Read and at least one other type is checked
        if (typeIdx == 0 && statusIdx == 1) {
            for ( i = 1; i <= 4; i++) {
                if ($("#status_" + i + "_1").attr("value") == "1") {
                    skip = true;
                }
            }
        } 

        // If Account Record-Read is checked, ignore toggle if application Record-Read checked
        if (typeIdx == 1 && statusIdx == 1) {
            if ($("#status_2_1").attr("value") == "1") {
                skip = true;
            }
        }
        return skip;
    }

    function onToggleAllPermissions(chkBox) {
        toggleUserDetails(chkBox.checked);
        toggleClassPermissions(chkBox.checked);
        toggleUserSecurityPermissions(chkBox.checked);
        toggleExceptionPermissions(chkBox.checked);
        togglePurgePermissions(chkBox.checked);
        toggleApprovalPermissions(chkBox.checked);
        toggleBankBranchSecurity(chkBox.checked);
    }

    function toggleUserDetails(isChecked) {
        var sendEmails = $('#cbAllowEmailSending');

        if (isChecked) {
            sendEmails.prop('checked', true);
            sendEmails.prop('disabled', true);
        }
        else {
            sendEmails.prop('checked', false);
            sendEmails.prop('disabled', false);
        }
    }

    function toggleClassPermissions(isChecked) {
        for (var i = 0; i <= 4; i++) {
            for (var j = 1; j <= 13; j++) {
                var statusId = "#status_" + i + "_" + j;
                var checkId = "#status-check_" + i + "_" + j;
                if (isChecked) {
                    $(checkId).attr('class', classChecked);
                    $(statusId).attr('value', 1);
                }
                else {
                    $(checkId).attr('class', classUnchecked);
                    $(statusId).attr('value', 0);
                }
            }
        }

        updateStatusHoverPointer();
    }

    function toggleUserSecurityPermissions(isChecked) {
        $("input[id^='permission-']").each(function () {
            var kendoSwitchElement = $('#' + this.id);
            var kendoSwitchData = kendoSwitchElement.data("kendoMobileSwitch");

            if (isChecked) {
                if (kendoSwitchElement.data("defaultValue") === 1) {
                    kendoSwitchData.check(false);
                }
                else {
                    kendoSwitchData.check(true);
                }

                kendoSwitchData.enable(false);
            }
            else {
                kendoSwitchData.check(false);
                kendoSwitchData.enable(true);
            }

        });
    }

    function toggleExceptionPermissions(isChecked) {
        var kendoDropdownElement = $('#user-permission-exception');
        var kendoDropdownData = kendoDropdownElement.data("kendoDropDownList");

        if (isChecked) {
            kendoDropdownData.select(2);
            kendoDropdownData.enable(false);
        }
        else {
            kendoDropdownData.select(0);
            kendoDropdownData.enable(true);
        }
    }

    function togglePurgePermissions(isChecked) {
        if (isChecked) {
            $("#uxAllowPurgeModiciations").prop('checked', true).prop('disabled', true);
        }
        else {
            $("#uxAllowPurgeModiciations").prop('checked', false).prop('disabled', false);
        }
    }

    function toggleApprovalPermissions(isChecked) {
        if (isChecked) {
            $("#is-approver").prop('checked', true).prop('disabled', true);
            $("#is-analyst").prop('checked', true).prop('disabled', true);
            $("#is-lender").prop('checked', true).prop('disabled', true);
            $("#is-loan-processor").prop('checked', true).prop('disabled', true);
        }
        else {
            $("#is-approver").prop('checked', false).prop('disabled', false);
            $("#is-analyst").prop('checked', false).prop('disabled', false);
            $("#is-lender").prop('checked', false).prop('disabled', false);
            $("#is-loan-processor").prop('checked', false).prop('disabled', false);
        }
    }

    function toggleBankBranchSecurity(isChecked) {
        SetBankAccess(0, isChecked);
        SetAllBranchAccess(0, isChecked);
        SetEmployeeAccess(0, isChecked);

        updateBankBranchHoverPointer();
    }

    function setStatus(newState, typeIdx, statusIdx) {
        var statusId = "#status_" + typeIdx + "_" + statusIdx;
        var checkId = "#status-check_" + typeIdx + "_" + statusIdx;
        if (newState) {
            $(checkId).attr('class', classChecked);
            $(statusId).attr('value', 1);
        } 
        else {
            $(checkId).attr('class', classUncheckedHighlight);
            $(statusId).attr('value', 0);
        }
    }

    function highlightSecurityRowIn(typeId) {
        typeIdx = typeId.replace('admin-type-accesss_', '');

        $("[id^='status-check_" + typeIdx + "_13']").each(function () {
            if ($('#' + this.id).attr('class').indexOf("aa-color-success") == -1) {
                $("[id^=status-check_" + typeIdx + "_").each(function () {
                    if ($('#' + this.id).attr('class').indexOf("aa-color-success") == -1) {
                        $('#' + this.id).attr('class', classUncheckedHighlight);
                    }
                });
            }
        });  
    }

    function highlightSecurityRowOut(typeId) {
        typeIdx = typeId.replace('admin-type-accesss_', '');

        $("[id^='status-check_" + typeIdx + "_13']").each(function () {
            if ( $('#' + this.id).attr('class').indexOf("aa-color-success") == -1) {
                $("[id^=status-check_" + typeIdx + "_").each(function () {
                    if ( $('#' + this.id).attr('class').indexOf("aa-color-success") == -1) {
                        $('#' + this.id).attr('class', classUnchecked);
                    }
                });
            }
        });  
    }

    function highlightCheckmarkIn(checkId) {
        if ($('#' + checkId).attr('class').indexOf("aa-color-success") == -1) {
            $('#' + checkId).attr('class', classUncheckedHover);
        }
    }

    function highlightCheckmarkOut(checkId) {
        if ($('#' + checkId).attr('class').indexOf("aa-color-success") == -1) {
            $('#' + checkId).attr('class', classUncheckedHighlight);
        }
    }

    function initializeStatusHoverPointers() {
        $("[id^='status-check_']").each(function () {
            if ($('#' + this.id).attr('class').indexOf('aa-has-hover') == -1) {
                $('#' + this.id).addClass("aa-has-hover");
            }
        });
    }

    function updateStatusHoverPointer() {
        for (i = 0; i < <%=maxAccountClassCount%>; i++) {
            adminCheckId = "status-check_" + i + "_13";
            typeRecordReadId = "status-check_" + i + "_1";
            typeDocumentReadId = "status-check_" + i + "_5";

            // Disable hover pointer for admin is SU is enabled.
            if ($('#chkIsSuperUser').prop('checked') && $("#" + adminCheckId).attr("class").indexOf("aa-color-success") >= 0 ) {
                $("#" + adminCheckId).removeClass("aa-has-hover");
            }

            // Disable hover pointer for all statuses if admin or SU is enabled.
            for (j = 1; j <= 12; j++) {
                statusCheckId = "status-check_" + i + "_" + j;
                if ($("#" + statusCheckId).attr("class").indexOf("aa-color-success") >= 0 && ($("#" + adminCheckId).attr("class").indexOf("aa-color-success") >= 0 || $("#chkIsSuperUser").prop("checked")) ) {
                    $("#" + statusCheckId).removeClass("aa-has-hover");
                }
            }

            // Disabled hover pointer for Record-Read if any status enabled other than admin
            for (j = 2; j <= 12; j++) {
                statusCheckId = "status-check_" + i + "_" + j;
                if ($("#" + statusCheckId).attr("class").indexOf("aa-color-success") >= 0 && $("#" + typeRecordReadId).attr("class").indexOf("aa-color-success") >= 0) {
                    $("#" + typeRecordReadId).removeClass("aa-has-hover");
                }
            }

            // disable hover pointer for Document-Read if any document statues enabled
            for (j = 6; j <= 12; j++) {
                statusCheckId = "status-check_" + i + "_" + j;
                if ($("#" + statusCheckId).attr("class").indexOf("aa-color-success") >= 0 && $("#" + typeDocumentReadId).attr("class").indexOf("aa-color-success") >= 0) {
                    $("#" + typeDocumentReadId).removeClass("aa-has-hover");
                }
            }

            // disable hover point for Account Record-Read if Application Record-Read enabled
            if ($("#status-check_2_1").attr("class").indexOf("aa-color-success")) {
                $("#status-check_1_1").removeClass("aa-has-hover");
            }
        }
    }
</script>

<table class="aa-kendo-grid">
    <thead>
        <tr>
            <th class="head-space" colspan="4">&nbsp;</th>
            <th class="aa-tac head-background" colspan="4">Record Access</th>
            <th class="head-space">&nbsp;</th>
            <th class="aa-tac head-background" colspan="8">Document Access</th>
        </tr>
        <tr>
            <th class="aa-tac">Data Type</th>
            <th class="head-space">&nbsp;</th>
            <th class="aa-tac">Admin</th>
            <th class="head-space">&nbsp;</th>
            <th class="aa-tac">Read</th>
            <th class="aa-tac">Edit</th>
            <th class="aa-tac">Add</th>
            <th class="aa-tac">Delete</th>
            <th class="head-space">&nbsp;</th>
            <th class="aa-tac">Read</th>
            <th class="aa-tac">Edit</th>
            <th class="aa-tac">Add</th>
            <th class="aa-tac">Delete</th>
            <th class="aa-tac">Page Add/Edit</th>
            <th class="aa-tac">Page Delete</th>
            <th class="aa-tac">File Upload/Merge</th>
            <th class="aa-tac">File Move/Copy</th>
        </tr>
    </thead>
    <tbody>
        <%
        Dim j, accountClassName
        Dim flipper : flipper = -1
        Dim i : i = 0
        DO UNTIL securityRS.EOF
            accountClassName = securityRS("accountClassName")
            accountClassCode = securityRS("accountClassCode")
            %>
            <tr id="admin-type-accesss_<%= i %>">
                <td><%=accountClassName%>
                <input type="hidden" id="status_<%=i%>_0" name="<%=accountClassCode%>_userAccountAccessId" value="<%=securityRS("userAccountAccessId")%>"/>
                <input type="hidden" id="status_<%=i%>_13" name="<%=accountClassCode%>_isAdmin" value="<%=Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_1" name="<%=accountClassCode%>_allowRead" value="<%=Abs(CInt(securityRS("allowRead"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_2" name="<%=accountClassCode%>_allowEdit" value="<%=Abs(CInt(securityRS("allowEdit"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_3" name="<%=accountClassCode%>_allowAdd" value="<%=Abs(CInt(securityRS("allowAdd"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_4" name="<%=accountClassCode%>_allowDelete" value="<%=Abs(CInt(securityRS("allowDelete"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_5" name="<%=accountClassCode%>_allowDocRead" value="<%=Abs(CInt(securityRS("allowDocRead"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_6" name="<%=accountClassCode%>_allowDocEdit" value="<%=Abs(CInt(securityRS("allowDocEdit"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_7" name="<%=accountClassCode%>_allowDocAdd" value="<%=Abs(CInt(securityRS("allowDocAdd"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_8" name="<%=accountClassCode%>_allowDocDelete" value="<%=Abs(CInt(securityRS("allowDocDelete"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_9" name="<%=accountClassCode%>_allowDocScan" value="<%=Abs(CInt(securityRS("allowDocScan"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_10" name="<%=accountClassCode%>_allowDocScanDelete" value="<%=Abs(CInt(securityRS("allowDocScanDelete"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_11" name="<%=accountClassCode%>_allowDocUpload" value="<%=Abs(CInt(securityRS("allowDocUpload"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                <input type="hidden" id="status_<%=i%>_12" name="<%=accountClassCode%>_allowDocMoveCopy" value="<%=Abs(CInt(securityRS("allowDocMoveCopy"))) Or Abs(CInt(securityRS("isAdmin"))) Or Abs(CInt(securityRS("isSuperUser")))%>"/>
                </td>
                <td>&nbsp;</td>
                <td class="aa-tac" ><%= ShowCheckmark( (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 13)", "status-check_" & i & "_13" ) %></td>
                <td>&nbsp;</td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowRead") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 1)", "status-check_" & i & "_1" ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowEdit") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 2)", "status-check_" & i & "_2"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowAdd") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 3)", "status-check_" & i & "_3"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDelete") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 4)", "status-check_" & i & "_4"  ) %></td>
                <td>&nbsp;</td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocRead") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 5)", "status-check_" & i & "_5"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocEdit") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 6)", "status-check_" & i & "_6"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocAdd") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 7)", "status-check_" & i & "_7"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocDelete") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 8)", "status-check_" & i & "_8"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocScan") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 9)", "status-check_" & i & "_9"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocScanDelete") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 10)", "status-check_" & i & "_10" ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocUpload") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 11)", "status-check_" & i & "_11"  ) %></td>
                <td class="aa-tac"><%= ShowCheckmark( securityRS("allowDocMoveCopy") Or (securityRS("isAdmin") Or securityRS("isSuperUser")), "onToggleStatus(this," & i & ", 12)", "status-check_" & i & "_12"  ) %></td>
            </tr>
            <%
            i = i + 1
            securityRS.MoveNext()
        LOOP
        %>
    </tbody>
</table>
<div class="common">
    <h2>Security Permissions</h2>
</div>
<%
Dim permissionRS : Set permissionRS = Server.CreateObject("ADODB.RecordSet")
Dim permissionQuery
    
IF mode = "ADD" THEN
    permissionQuery = _
        " SELECT" & _
        "   p.PermissionId," & _
        "   p.Resource," & _
        "   p.Name," & _
        "   p.Description," & _
        "   p.Type," & _
        "   NULL AS currentPermissioinId, " & _
        "   0 AS hasPermission" & _
        " FROM Permission AS p" & _
        " ORDER BY" & _
        "   p.Resource," & _
        "   p.Name"
ELSE
    permissionQuery = _
        " SELECT" & _
        "   p.PermissionId," & _
        "   p.Resource," & _
        "   p.Name," & _
        "   p.Description," & _
        "   p.Type," & _
        "   up.PermissionId AS currentPermissionId," & _
        "   CASE" & _
        "       WHEN up.PermissionId IS NOT NULL THEN 1" & _
        "       ELSE 0" & _
        "       END AS hasPermission" & _
        " FROM" & _
        "   [user] AS u CROSS JOIN Permission AS p" & _
        "   LEFT OUTER JOIN UserPermission AS up" & _
        "       ON up.UserId=u.userId" & _
        "       AND up.PermissionId=p.PermissionId" & _
        " WHERE" & _
        "   u.userId=" & dbFormatId(userid) & _
        " ORDER BY" & _
        "   p.Resource," & _
        "   p.Name"
END IF
permissionRS.Open permissionQuery, db
%>
<table class="aa-kendo-grid">
    <thead>
        <tr>
            <th>Permission Resource</th>
            <th>Permission Name</th>
            <th>Description</th>
            <th>Assigned</th>
        </tr>
    </thead>
    <tbody>
        <%
        Dim enablePermission
        Dim displayResourceName
        Dim prevResourceName : prevResourceName = ""
        DO UNTIL permissionRS.EOF
            Dim permissionId : permissionId = permissionRS("PermissionId")
            Dim resourceName : resourceName = permissionRS("Resource")
            Dim permissionName : permissionName = permissionRS("Name")
            Dim permissionType : permissionType = permissionRS("Type")
            Dim permissionDescription : permissionDescription = permissionRS("Description")
            Dim hasPermission : hasPermission = permissionRS("hasPermission")
            Dim permissionChecked : permissionChecked = ""

            IF workingUserId <> "" AND hasPermission = 1 THEN
                permissionChecked = " checked=""checked"""
            END IF

            IF prevResourceName <> resourceName THEN
                displayResourceName = resourceName
                prevResourceName = resourceName
            ELSE
                displayResourceName = "&nbsp;"
            END IF
                      
            enablePermission = true

            IF Session("accuaccount.enableNotices") = 0 AND permissionRS("Resource") = "AccuAccount.Notice" THEN
                enablePermission = false
            END IF

            IF enablePermission THEN
            %>
            <tr>
                <td><%=displayResourceName%></td>
                <td><%=permissionName%></td>
                <td><%=permissionDescription%></td>
                <td><input type="checkbox" id="permission-<%=FormatGuid(permissionId)%>" name="permissionId" value="<%=permissionId%>" data-role="switch"<%=permissionChecked%> data-off-label="No" data-on-label="Yes" data-default-value="<%=permissionType%>"/></td>
            </tr>
            <%
            END IF

            permissionRS.MoveNext
        LOOP
        permissionRS.Close
        %>
    </tbody>
</table>
<div class="common">
    <h2>Administrative Settings</h2>
</div>
<table class="aa-two-column-form-table">
    <tr <% IF NOT Session("isSuperUser") THEN %>class="aa-hidden"<% END IF %>>
        <td>Super User:</td>
        <td><input type="checkbox" class="k-checkbox" id="chkIsSuperUser" name="isSuperUser" value="1" onclick="onToggleAllPermissions(this);" <% IF isSuperUser THEN %> checked="checked"<% END IF %> /><label class="k-checkbox-label" for="chkIsSuperUser">Yes, this user is a Super User</label></td>
    </tr>
    <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
    <% kendoSelectList = kendoSelectList & "user-permission-exception," %>
    <tr>
        <td>Exception Administration:</td>
        <td><select name="userPermissionException" id="user-permission-exception">
        <option value="1"<% IF userPermissionException = 1 OR userPermission = "" THEN %> selected="selected"<% END IF %>>Reader</option>
        <option value="2"<% IF userPermissionException = 2 THEN %> selected="selected"<% END IF %>>Editor</option>
        <option value="3"<% IF userPermissionException = 3 THEN %> selected="selected"<% END IF %>>Administrator</option>
        </select></td>
    </tr>
    <% ELSE %>
    <tr class="aa-hidden">
        <td colspan="2"><input type="hidden" name="userPermissionException" value="1"/></td>
    </tr>
    <% END IF %>
    <%
    IF Session("acculoan.enablePurge") = 1 THEN 
        Dim disablePurgeCheckbox : disablePurgeCheckbox = ""

        ' Disable checkbox if the user being edited is a SuperUser or the user
        ' doing the editing is not a SuperUser.
        IF isSuperUser OR NOT Session("isSuperUser") THEN
            disablePurgeCheckbox = " disabled=""disabled"""
        END IF
        %>
        <tr class="aa-no-background-color narrow">
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td>Allow Purge Modifications:</td>
            <td><input type="checkbox"class="k-checkbox" name="cbAllowPurgeModiciations" id="uxAllowPurgeModiciations"<% IF allowPurgeModifications THEN %> checked="checked"<% END IF %> value="1" <%=disablePurgeCheckbox%>/><label class="k-checkbox-label" for="uxAllowPurgeModiciations">Yes, This User can Modify Purge Settings and Execute a Purge</label></td>
        </tr>
    <% END IF %>
</table>