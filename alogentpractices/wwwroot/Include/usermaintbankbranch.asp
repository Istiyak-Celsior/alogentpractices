<script type="text/javascript">
    function initializeBankBranchHoverPointers() {
        if (hasBankAccess) {
            $("[id^='bank-check_'").each(function () {
                if ($('#' + this.id).attr('class').indexOf('aa-has-hover') == -1) {
                    $('#' + this.id).addClass("aa-has-hover");
                }
            });
        }

        if (isSuperUser) {
            $("[id^='ingBankBranch_empFiles_'").each(function () {
                if ($('#' + this.id).attr('class').indexOf('aa-has-hover') == -1) {
                    $('#' + this.id).addClass("aa-has-hover");
                }
            });
        }

        if (enableBranchSecurity && (branchSecurityLevel == 'DU' || branchSecurityLevel == 'DO')) {
            $("[id^='branch-check_']").each(function () {
                if ($('#' + this.id).attr('class').indexOf('aa-has-hover') == -1) {
                    $('#' + this.id).addClass("aa-has-hover");
                }
            });
        }
    }

    function toggleBankStatus(obj, bankIdx) {
        skip = false;
        // Determine if toggle should be skipped because of minimum settings
        // Skip if using is SU
        if ($('#chkIsSuperUser').prop('checked')) {
            skip = true;
        }

        if (!skip) {
            var currentValue = $(obj).attr('class');
            var isChecked;
            if (currentValue.indexOf('aa-color-success') >= 0) {
                isChecked = false;
            }
            else {
                isChecked = true;
            }

            SetBankAccess(bankIdx, isChecked);
            SetAllBranchAccess(bankIdx, isChecked);

            // Reset to checked-hover icon if unchecked.
            if (!isChecked) {
                $(obj).attr('class', classUncheckedHover);
            }
        }
        else {
            // set selector to a pointer since no clicking allowed.
        }       
        return skip;
    }

    function toggleEmployeeStatus(obj, bankIdx) {
        skip = false;

        // Determine if toggle should be skipped because of minimum settings
        // Skip if using is SU
        if ($('#chkIsSuperUser').prop('checked')) {
            skip = true;
        }

        if (!skip) {
            var currentValue = $(obj).attr('class');
            var isChecked;
            if (currentValue.indexOf('aa-color-success') >= 0) {
                isChecked = false;
            }
            else {
                isChecked = true;
            }

            SetEmployeeAccess(bankIdx, isChecked);

            // Reset to checked-hover icon if unchecked.
            if (!isChecked) {
                $(obj).attr('class', classUncheckedHover);
            }
        }
    }

    function toggleBranchStatus(obj, bankIdx, branchIdx) {
        var currentValue = $(obj).attr('class');
        var isChecked;
        if (currentValue.indexOf('aa-color-success') >= 0) {
            isChecked = false;
        }
        else {
            isChecked = true;
        }

        SetBranchAccess(bankIdx, branchIdx, isChecked);
        CheckBankAccess(bankIdx);

        // Reset to checked-hover icon if unchecked.
        if (!isChecked) {
            $(obj).attr('class', classUncheckedHover);
        }
    }

    function SetBankAccess(bankIdx, isChecked) {
        if (isChecked) {
            $("#bankaccess_" + bankIdx).attr("value", "1");
            $("#bank-check_" + bankIdx).attr("class", classChecked);
        }
        else {
            $("#bankaccess_" + bankIdx).attr("value", "0");
            $("#bank-check_" + bankIdx).attr("class", classUncheckedHighlight);
        }
    }

    function SetAllBranchAccess(bankIdx, isChecked) {
        var branchCount = $('#rowNumber_' + bankIdx).attr("value");
        for (i = 0; i < branchCount; i++) {
            SetBranchAccess(bankIdx, i, isChecked);
        }
    }

    function SetBranchAccess(bankIdx, branchIdx, isChecked) {
        var branchValueElement = $('#branches_' + bankIdx + "_" + branchIdx);
        var branchCheckElement = $('#branch-check_' + bankIdx + "_" + branchIdx);
        var uncheckedStatusClass = '';

        if (isChecked) {
            branchValueElement.attr("value", "1");
            branchCheckElement.attr("class", classChecked);
        }
        else {
            if (enableBranchSecurity && branchSecurityLevel != "XX") {
                uncheckedStatusClass = classUncheckedHighlight;
            }
            else {
                uncheckedStatusClass = classUnchecked;
            }

            branchValueElement.attr("value", "0");
            branchCheckElement.attr("class", uncheckedStatusClass);
        }

        // Always remove pointer for branches if branch security disabled or not used
        //
        if (!enableBranchSecurity || branchSecurityLevel == "XX") {
            if (branchCheckElement.attr('class').indexOf('aa-has-hover') >= 0) {
                branchCheckElement.removeClass('aa-has-hover');
            }
        }
    }

    function SetEmployeeAccess(bankIdx, isChecked) {
        if (isChecked) {
            $('#employeeaccess_' + bankIdx).attr("value", "1");
            $('#ingBankBranch_empFiles_' + bankIdx).attr("class", classChecked);
        }
        else {
            $('#employeeaccess_' + bankIdx).attr("value", "0");
            $('#ingBankBranch_empFiles_' + bankIdx).attr("class", classUncheckedHover);
        }
    }

    function CheckBankAccess(bankIdx) {
        var bankAccessChecked = false;
        var branchCount = $('#rowNumber_' + bankIdx).attr("value");

        for (i = 0; i < branchCount; i++) {
            if ($('#branch-check_' + bankIdx + '_' + i).attr('class').indexOf('aa-color-success') >= 0) {
                bankAccessChecked = true;
            }
        }

        SetBankAccess(bankIdx, bankAccessChecked);
    }

    function highlightBankRowIn(bankId) {
        bankIdx = bankId.replace('bank-highlight_', '');

        if ($("#bank-check_" + bankIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#bank-check_" + bankIdx).attr('class', classUncheckedHighlight);
        }

        if ($("#ingBankBranch_empFiles_" + bankIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#ingBankBranch_empFiles_" + bankIdx).attr('class', classUncheckedHighlight);
        }

        if (enableBranchSecurity && branchSecurityLevel != "XX") {
            uncheckedStatusClass = classUncheckedHighlight;
        }
        else {
            uncheckedStatusClass = classUnchecked;
        }

        $("[id^='branch-check_" + bankIdx).each(function () {
            if ($('#' + this.id).attr('class').indexOf("aa-color-success") == -1) {
                $('#' + this.id).attr('class', uncheckedStatusClass);
            }
        });
    }

    function highlightBankRowOut(bankId) {
        bankIdx = bankId.replace('bank-highlight_', '');

        if ($("#bank-check_" + bankIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#bank-check_" + bankIdx).attr('class', classUnchecked);
        }

        if ($("#ingBankBranch_empFiles_" + bankIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#ingBankBranch_empFiles_" + bankIdx).attr('class', classUnchecked);
        }

        $("[id^='branch-check_" + bankIdx).each(function () {
            if ($('#' + this.id).attr('class').indexOf("aa-color-success") == -1) {
                $('#' + this.id).attr('class', classUnchecked);
            }
        });
    }

    function highlightBranchRowIn(branchId) {
        idx = branchId.replace('branch-highlight_', '');
        arr = idx.split("_");
        bankIdx = arr[0];
        branchIdx = arr[1];

        if ($("#bank-check_" + bankIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#bank-check_" + bankIdx).attr('class', classUncheckedHighlight);
        }

        if (enableBranchSecurity && branchSecurityLevel != "XX") {
            uncheckedStatusClass = classUncheckedHighlight;
        }
        else {
            uncheckedStatusClass = classUnchecked;
        }

        if ($("#branch-check_" + bankIdx + "_" + branchIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#branch-check_" + bankIdx + "_" + branchIdx).attr('class', uncheckedStatusClass);
        }
    }

    function highlightBranchRowOut(branchId) {
        idx = branchId.replace('branch-highlight_', '');
        arr = idx.split("_");
        bankIdx = arr[0];
        branchIdx = arr[1];

        if ($("#bank-check_" + bankIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#bank-check_" + bankIdx).attr('class', classUncheckedHighlight);
        }

        if ($("#branch-check_" + bankIdx + "_" + branchIdx).attr("class").indexOf("aa-color-success") == -1) {
            $("#branch-check_" + bankIdx + "_" + branchIdx).attr('class', classUnchecked);
        }
    }

    function updateBankBranchHoverPointer() {
        if (isSuperUser) {
            // Disable hover pointer on Bank access
            //
            $("[id^='bank-check_']").each(function () {
                if ($('#' + this.id).attr('class').indexOf('aa-has-hover') >= 0) {
                    $('#' + this.id).removeClass('aa-has-hover');
                }
            });

            // Disable hover pointer on Employee access
            //
            $("[id^='ingBankBranch_empFiles_']").each(function () {
                if ($('#' + this.id).attr('class').indexOf('aa-has-hover') >= 0) {
                    $('#' + this.id).removeClass('aa-has-hover');
                }
            });

            // Disable hover pointer on Branch access
            //
            $("[id^='branch-check_']").each(function () {
                if ($('#' + this.id).attr('class').indexOf('aa-has-hover') >= 0) {
                    $('#' + this.id).removeClass('aa-has-hover');
                }
            });
        }
    }
</script>
<h2 class="tab-title">Bank / Branch Security Access</h2>
<table class="aa-kendo-grid bank-security">
    <thead>
        <tr>
            <th>Bank / (Region) Branch</th>
            <th class="aa-tac">Bank Access</th>
            <th class="aa-tac">Branch Access</th>
            <th class="aa-tac">Access To Employee Files</th>
        </tr>
    </thead>
    <%
    Dim theBankSecId : theBankSecId = ""
    Dim bankAccess : bankAccess = False
    Dim accessEmployeeFiles : accessEmployeeFiles = False

    IF Session("isSuperUser") THEN
        FOR ba = 0 TO userBankSecurityRows
            theBankSecId = userBankSecurityArray(UBS_BANKSECURITY, ba)
            IF mode <> "ADD" THEN
                IF userBankSecurityArray(UBS_BANKACCESS, ba) = 1 THEN bankAccess = True
                IF userBankSecurityArray(UBS_EMPLOYEEFILES, ba) = 1 THEN accessEmployeeFiles = True
            END IF
        NEXT
        %>
        <tr id="bank-highlight_0">
            <td><input type="hidden" id="bankaccess_0" name="bankaccess_0" value="<% IF bankAccess THEN %>1<% ELSE %>0<% END IF %>"/>
            <input type="hidden" id="employeeaccess_0" name="employeeaccess_0" value="<% IF accessEmployeeFiles THEN %>1<% ELSE %>0<% END IF %>"/>
            <input type="hidden" name="bankid_0" value="<%=bankArray(BANK_ID, 0)%>"/>
            <input type="hidden" name="banksecurityid_0" value="<%=theBankSecId%>"/><b><%=bankArray(BANK_NAME, 0)%></b></td>
            <td class="aa-tac"><%=ShowCheckmark(bankAccess, "toggleBankStatus(this, 0)", "bank-check_0") %></td>
            <td class="aa-tac">&nbsp;</td>
            <td class="aa-tac"><%
            IF Session("isSuperUser") THEN
                Response.Write ShowCheckmark(accessEmployeeFiles, "toggleEmployeeStatus(this, 0)", "ingBankBranch_empFiles_0")
            ELSE
                Response.Write ShowCheckmark(accessEmployeeFiles, "", "")
            END IF
            %></td>
        </tr>
        <%
        rowNumber = 0
        FOR br = 0 TO branchRows - 1
            branchAccess = False
            IF userBranchSecurityRows <> -1 THEN
                FOR brsec = 0 TO userBranchSecurityRows
                    IF userBranchSecurityArray(BRSEC_BRANCHID, brsec) = branchArray(BRANCH_ID, br) _
                        AND (Session("UseBranchSecurity") = "Y" _
                        AND (Session("acculoan.branchSecurity.level") = "DU" OR Session("acculoan.branchSecurity.level") = "DO")) _
                        AND mode <> "ADD" _
                    THEN branchAccess = True
                NEXT
            END IF
            %>
            <tr id="branch-highlight_0_<%=rowNumber%>">
                <td><input type="hidden" id="branches_0_<%=rowNumber%>" name="branches_0_<%=rowNumber%>" value="<% IF branchAccess THEN %>1<% ELSE %>0<% END IF %>"/>( <%=branchArray(BRANCH_REGION_ID, br)%> ) <%=branchArray(BRANCH_NAME, br)%></td>
                <td class="aa-tac">&nbsp;</td>
                <td class="aa-tac"><%
                IF Session("UseBranchSecurity") = "Y" AND (Session("acculoan.branchSecurity.level") = "DU" OR Session("acculoan.branchSecurity.level") = "DO") THEN
                    Response.Write ShowCheckmark(branchAccess, "toggleBranchStatus(this, 0," & rowNumber & ")", "branch-check_0_" & rowNumber)
                ELSE
                    Response.Write ShowCheckmark(true, "", "branch-check_0_" & rowNumber)
                END IF
                %></td>
                <td class="aa-tac">&nbsp;</td>
            </tr>
            <%
            rowNumber = rowNumber + 1
        NEXT ' ### FOR br = 0 TO branchRows - 1
        %>
        <tr class="aa-hidden">
            <td colspan="4"><input type="hidden" id="rowNumber_0" name="rowNumber_0" value="<%=rowNumber%>"/></td>
        </tr>
    <% ELSE %>
        <tr>
            <td colspan="4" class="aa-tac"><%
            IF Trim(mode & "") = "ADD" THEN
                Response.Write "The User Must be Created Before Bank and Branch Security can be Assigned."
            ELSE
                Response.Write "You Must Have Super User Privileges to Add User Branch and Bank Security. Contact your System Administrator."
            END IF
            %></td>
        </tr>
        <%
    END IF ' ### IF Session("isSuperUser")
    %>
</table>