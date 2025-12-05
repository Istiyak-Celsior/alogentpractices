<%
hasDisplayedFlexFields = false

rootGroupDisplayState = Request.Cookies("accountfield_DisplayState")
IF rootGroupDisplayState = "" THEN rootGroupDisplayState = "collapsed"

Set accountFieldRS = Server.CreateObject("ADODB.RecordSet")
accountFieldQuery = _
    " SELECT lf.*" & _
    " FROM" & _
    "   loan AS l LEFT OUTER JOIN loanFields AS lf" & _
    "       ON l.loanId = lf.loanId" & _
    " WHERE l.loanId = " & dbFormatId(selectedLoanId)
accountFieldRS.Open accountFieldQuery, db, adOpenStatic, adCmdText

hasDisplayableFields = false
FOR i = 0 TO g_accountFieldDefCount - 1
    IF g_accountFieldDefList(FIELD_DEF_DISPLAYABLE, i) AND g_accountFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,i) = selectedAccountClassId THEN
        hasDisplayableFields = true
        EXIT FOR
    END IF
NEXT

' ### Additional check for vb script behavior ###
visibleFieldsCheck = false
IF g_accountFieldGroupCount >= 1 AND g_accountFieldDefCount >= 1 THEN
    visibleGroupsCheck = HasVisibleGroups(g_accountFieldDefList, g_accountFieldGroupList, accountFieldRS)
END IF

IF visibleGroupsCheck THEN
    groupIdx = 0
    FOR i = 0 TO g_accountFieldGroupCount - 1
        fieldIdx = 0
        fieldDefGroupId = g_accountFieldGroupList(FDG_ID,i)
        fieldDefGroupName = g_accountFieldGroupList(FDG_NAME,i)
        fieldDefGroupLabel = g_accountFieldGroupList(FDG_LABEL,i)

        ' ### Additional check for vb script behavior ###
        visibleFieldsCheck = false
        IF g_accountFieldDefCount >= 1 THEN
            visibleFieldsCheck = HasVisibleFields(g_accountFieldDefList, fieldDefGroupId, accountFieldRS)
        END IF

        IF visibleFieldsCheck THEN
            fieldIdx = 0
            fieldDisplayed = false
            firstTime = true
            FOR j = 0 TO g_accountFieldDefCount - 1
                fieldDefIsCovenant = Trim(g_accountFieldDefList(FIELD_DEF_IS_COVENANT,j))
                fieldLabel = g_accountFieldDefList(FIELD_DEF_LABEL, j)
                fieldName = g_accountFieldDefList(FIELD_DEF_NAME, j)
                fieldValue = CheckForNull(accountFieldRS(g_accountFieldDefList(FIELD_DEF_NAME,j)))
                fieldGroupId = g_accountFieldDefList(FIELD_DEF_GROUP_ID, j)

                IF IsNull(accountFieldRS(fieldName & "_isActive")) THEN
                    isActiveField = true
                ELSE
                    isActiveField = accountFieldRS(fieldName & "_isActive")
                END IF

                IF NOT fieldDefIsCovenant AND fieldGroupId = fieldDefGroupId THEN
                    hasFieldValue = true
                    IF Trim(fieldValue & "") = "" THEN hasFieldValue = false

                    IF g_accountFieldDefList(FIELD_DEF_DISPLAYABLE, j) AND hasFieldValue AND isActiveField THEN
                        hasDisplayedFlexFields = true
                        fieldDisplayed = true

                        IF g_accountFieldDefList(FIELD_DEF_DATA_TYPE, j) = "money" THEN
                            IF IsNumeric(fieldValue) THEN fieldValue = FormatCurrency(fieldValue,2)
                        ELSEIF g_accountFieldDefList(FIELD_DEF_DATA_TYPE, j) = "datetime" THEN
                            IF IsDate(fieldValue) THEN fieldValue = FormatDateTime(fieldValue,2)
                        END IF

                        groupDisplayState = Request.Cookies("accountfield_" & groupIdx & "_DisplayState")
                        IF rootGroupDisplayState = "collapsed" THEN
                            groupDisplayStyle = "none"
                            fieldDisplayStyle = "none"
                        ELSEIF groupDisplayState = "collpased" OR groupDisplayState = "" THEN
                            groupDisplayStyle = "table-row"
                            fieldDisplayStyle = "none"
                        ELSE
                            groupDisplayStyle = "none"
                            fieldDisplayStyle = "table-row"
                        END IF

                        IF firstTime THEN
                            firstTime = false
                            %>
                            <tr id="accountfield_<%=groupIdx%>" style="display:<%=groupDisplayStyle%>;">
                                <td class="aa-tar aa-background-base-dark"><%
                                IF groupIdx = 0 THEN
                                    Response.Write "<a href=""javascript:void(0);"" onclick=""ExpandFields(this, 'accountfield', 0);""><i class=""aa-icon fas fa-minus-square fa-fw"" title=""Collapse Extended Fields"" aria-hidden=""true""></i></a>"
                                END IF
                                %></td>
                                <td class="aa-tac aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'accountfield_<%=groupIdx%>', 1);"><i class="aa-icon fas fa-plus-square fa-fw" title="View <%=fieldDefGroupLabel%> Fields" aria-hidden="true"></i></a></td>
                                <td class="aa-background-base-dark"><%=fieldDefGroupLabel%></td>
                                <td colspan="5"><i>View Group Details</i></td>
                            </tr>
                            <tr id="accountfield_<%=groupIdx%>_<%=fieldIdx%>" style="display:<%=fieldDisplayStyle%>;">
                                <td class="aa-tar aa-background-base-dark"><%
                                IF groupIdx = 0 THEN
                                    Response.Write "<a href=""javascript:void(0);"" onclick=""ExpandFields(this, 'accountfield', 0);""><i class=""aa-icon fas fa-minus-square fa-fw"" title=""Collapse Extended Fields"" aria-hidden=""true""></i></a>"
                                END IF
                                %></td>
                                <td class="aa-tac aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'accountfield_<%=groupIdx%>', 1);"><i class="aa-icon fas fa-minus-square fa-fw" title="View <%=fieldDefGroupLabel%> Fields" aria-hidden="true"></i></a></td>
                                <td class="aa-background-base-dark"><%=fieldDefGroupLabel%></td>
                                <td colspan="2"><%=fieldLabel%></td>
                                <td colspan="3"><%=fieldValue%></td>
                            </tr>
                            <%
                        ELSE
                            %>
                            <tr id="accountfield_<%=groupIdx%>_<%=fieldIdx%>" style="display:<%=fieldDisplayStyle%>;">
                                <td class="aa-background-base-dark">&nbsp;</td>
                                <td class="aa-tac aa-background-base-dark">&nbsp;</td>
                                <td class="aa-background-base-dark">&nbsp;</td>
                                <td colspan="2"><%=fieldLabel%></td>
                                <td colspan="3"><div style="word-wrap: break-word;"><%=fieldValue%></div></td>
                            </tr>
                            <%
                        END IF ' ### firstTime
                        fieldIdx = fieldIdx + 1
                    END IF ' ### g_creditFieldDefList(FIELD_DEF_DISPLAYABLE, j) And hasFieldValue 
                END IF ' ### fieldGroupId=fieldDefGroupId
            NEXT

            ' ### If one or more group flex fields were displayed increment count. NOTE: we only increment
            ' when there is a displayable Group with Flex Fields. ###
            IF fieldDisplayed THEN groupIdx = groupIdx + 1
        END IF ' ### visibleFieldsCheck = true
    NEXT ' ### i 
END IF ' ### visbleGroupsCheck = true

IF hasDisplayedFlexFields THEN
    %>
    <tr id="accountfield" style="display:<% IF rootGroupDisplayState = "collapsed" THEN %>table-row<% ELSE %>none<% END IF %>;">
        <td class="aa-tar aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'accountfield', 0);"><i class="aa-icon fas fa-plus-square fa-fw" title="Collapse Extended Fields" aria-hidden="true"></i></a></td>
        <td colspan="7" class="aa-background-base-dark"><i>View Additional Information</i></td>
    </tr>
    <%
END IF
accountFieldRS.Close()
%>