<%
hasDisplayedFlexField = false

rootGroupDisplayState = Request.Cookies("collateralfield_DisplayState")
IF rootGroupDisplayState = "" THEN rootGroupDisplayState = "collapsed"

Set collateralFieldRS = Server.CreateObject("ADODB.RecordSet")
collateralfieldQuery = _
    " SELECT cf.*" & _
    " FROM" & _
    "   loan AS l LEFT OUTER JOIN collateralFields AS cf" & _
    "       ON l.loanId = cf.collateralId" & _
    " WHERE l.loanId=" & dbFormatId(primaryCollateralId)
collateralFieldRS.Open collateralfieldQuery, db, adOpenStatic, adCmdText

hasDisplayableFields = false
FOR i = 0 TO g_collateralFieldDefCount - 1
    IF g_collateralFieldDefList(FIELD_DEF_DISPLAYABLE, i) AND g_collateralFieldDefList(FIELD_DEF_ACCOUNT_CLASS_ID,i) = selectedAccountClassId THEN
        hasDisplayableFields = true
        EXIT FOR
    END IF
NEXT

visibleFieldsCheck = false
IF g_collateralFieldGroupCount >= 1 AND g_collateralFieldDefCount >= 1 THEN
    visibleGroupsCheck = HasVisibleGroups(g_collateralFieldDefList, g_collateralFieldGroupList, collateralFieldRS)
END IF

IF visibleGroupsCheck THEN
    groupIdx = 0
    FOR i = 0 TO g_collateralFieldGroupCount - 1
        fieldIdx = 0
        fieldDefGroupId = g_collateralFieldGroupList(FDG_ID,i)
        fieldDefGroupName = g_collateralFieldGroupList(FDG_NAME,i)
        fieldDefGroupLabel = g_collateralFieldGroupList(FDG_LABEL,i)
        fieldDefGroupAccountClassId = g_collateralFieldGroupList(FDG_ACCOUNT_CLASS_ID, i)

        IF cStr(fieldDefGroupAccountClassId) = cStr(targetAccountClassId) THEN

            visibleFieldsCheck = false
            IF g_collateralFieldDefCount >= 1 THEN
                visibleFieldsCheck = HasVisibleFields(g_collateralFieldDefList, fieldDefGroupId, collateralFieldRS)
            END IF

            IF visibleFieldsCheck THEN
                fieldIdx = 0
                fieldDisplayed = false
                firstTime = true
                FOR j = 0 TO g_collateralFieldDefCount - 1
                    fieldGroupId = g_collateralFieldDefList(FIELD_DEF_GROUP_ID, j)
                    IF fieldGroupId = fieldDefGroupId THEN
                        fieldLabel = g_collateralFieldDefList(FIELD_DEF_LABEL, j)
                        fieldName = g_collateralFieldDefList(FIELD_DEF_NAME, j)
                        fieldValue = CheckForNull(collateralFieldRS(g_collateralFieldDefList(FIELD_DEF_NAME,j)))

                        IF IsNull(collateralFieldRS(fieldName & "_isActive")) THEN
                            isActiveField = true
                        ELSE
                            isActiveField = collateralFieldRS(fieldName & "_isActive")
                        END IF

                        IF fieldGroupId = fieldDefGroupId THEN
                            hasFieldValue = true
                            IF fieldValue = "" THEN hasFieldValue = false

                            IF g_collateralFieldDefList(FIELD_DEF_DISPLAYABLE, j) AND hasFieldValue AND isActiveField THEN
                                hasDisplayedFlexField = true
                                fieldDisplayed = true

                                IF g_collateralFieldDefList(FIELD_DEF_DATA_TYPE, j) = "money" THEN
                                    IF IsNumeric(fieldValue) THEN fieldValue = FormatCurrency(fieldValue, 2)
                                ELSEIF g_collateralFieldDefList(FIELD_DEF_DATA_TYPE, j) = "datetime" THEN
                                    IF IsDate(fieldValue) THEN fieldValue = FormatDateTime(fieldValue, 2)
                                END IF

                                groupDisplayState = Request.Cookies("collateralfield_" & groupIdx & "_DisplayState")
                                IF rootGroupDisplayState = "collapsed" THEN
                                    groupDisplayStyle = "none"
                                    fieldDisplayStyle = "none"
                                ELSEIF groupDisplayState = "collpased" OR groupDisplayState = "" THEN
                                    groupDisplayStyle = ""
                                    fieldDisplayStyle = "none"
                                ELSE
                                    groupDisplayStyle = "none"
                                    fieldDisplayStyle = ""
                                END IF

                                IF firstTime THEN
                                    firstTime = false
                                    %>
                                    <tr id="collateralfield_<%=groupIdx%>" style="display:<%=groupDisplayStyle%>;">
                                        <td class="aa-tar aa-background-base-dark" colspan="2"><%
                                        IF groupIdx = 0 THEN
                                            Response.Write "<a href=""javascript:void(0);"" onclick=""ExpandFields(this, 'collateralfield', 0);""><i class=""aa-icon fas fa-minus-square fa-fw"" title=""Collapse Extended Fields"" aria-hidden=""true""></i></a>"
                                        END IF
                                        %></td>
                                        <td class="aa-tac aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'collateralfield_<%=groupIdx%>', 1);"><i class="aa-icon fas fa-plus-square fa-fw" title="View <%=fieldDefGroupLabel%> Fields" aria-hidden="true"></i></a></td>
                                        <td class="aa-background-base-dark"><%=fieldDefGroupLabel%></td>
                                        <td colspan="2"><i>View Group Details</i></td>
                                    </tr>
                                    <tr id="collateralfield_<%=groupIdx%>_<%=fieldIdx%>" style="display:<%=fieldDisplayStyle%>;">
                                        <td class="aa-tar aa-background-base-dark" colspan="2"><%
                                        IF groupIdx = 0 THEN
                                            Response.Write "<a href=""javascript:void(0);"" onclick=""ExpandFields(this, 'collateralfield', 0);""><i class=""aa-icon fas fa-minus-square fa-fw"" title=""Collapse Extended Fields"" aria-hidden=""true""></i></a>"
                                        END IF
                                        %></td>
                                        <td class="aa-tac aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'collateralfield_<%=groupIdx%>', 1);"><i class="aa-icon fas fa-minus-square fa-fw" title="View <%=fieldDefGroupLabel%> Fields" aria-hidden="true"></i></a></td>
                                        <td class="aa-background-base-dark"><%=fieldDefGroupLabel%></td>
                                        <td><%=fieldLabel%></td>
                                        <td><%=fieldValue%>&nbsp;</td>
                                    </tr>
                                    <%
                                ELSE
                                    %>
                                    <tr id="collateralfield_<%=groupIdx%>_<%=fieldIdx%>" style="display:<%=fieldDisplayStyle%>;">
                                        <td class="aa-background-base-dark" colspan="2">&nbsp;</td>
                                        <td class="aa-tac aa-background-base-dark">&nbsp;</td>
                                        <td class="aa-background-base-dark">&nbsp;</td>
                                        <td><%=fieldLabel%></td>
                                        <td><div style="word-wrap: break-word;"><%=fieldValue%>&nbsp;</div></td>
                                    </tr>
                                    <%
                                END IF ' ### firstTime
                                fieldIdx = fieldIdx + 1
                            END IF ' ### g_creditFieldDefList(FIELD_DEF_DISPLAYABLE, j) And hasFieldValue 
                        END IF ' ### IF fieldGroupId = fieldDefGroupId'
                    END IF ' ### IF fieldGroupId = fieldDefGroupId'
                NEXT ' ### j

                ' ### If one or more group flex fields were displayed increment count. NOTE: we only increment
                ' when there is a displayable Group with Flex Fields. ###

                IF true THEN groupIdx = groupIdx + 1
            END IF ' ### visibleFieldsCheck = true
        END IF ' ### CStr(fieldDefGroupAccountClassId) = CStr(targetAccountClassId)
    NEXT ' ### i
END IF ' ### visbleGroupsCheck = true

IF hasDisplayedFlexField THEN
    %>
    <tr id="collateralfield" style="display:<% IF rootGroupDisplayState = "collapsed" THEN %>table-row<% ELSE %>none<% END IF %>;">
        <td class="aa-tar aa-background-base-dark" colspan="2"><a href="javascript:void(0);" onclick="ExpandFields(this, 'collateralfield', 0);"><i class="aa-icon fas fa-plus-square fa-fw" title="Collapse Extended Fields" aria-hidden="true"></i></a></td>
        <td colspan="4" class="aa-background-base-dark"><i>View Additional Information</i></td>
    </tr>
    <%
END IF
collateralFieldRS.Close()
%>