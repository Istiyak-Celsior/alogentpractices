            <div class="aa-content-panel">
                <div>
                    <% IF accountClassCode <> "credit" THEN %>
                        <div class="spacer"></div>
                        <div class="aa-panel">
                            <div>
                                <h2>Collateral Fields</h2>
                            </div>
                            <div>
                                <a href="javascript:void(0);" onclick="openKendoDialog('Add New <%=accountClassName%> Field Group', 'fielddefgroupmaint.asp?action=ADD&accountClassId=<%=accountClassId%>&isCollateral=1', 500, 700);" class="k-button k-primary"><i class="aa-icon fas fa-plus-circle" aria-hidden="true"></i>&nbsp;&nbsp;Collateral Field Group</a>
                            </div>
                        </div>
                        <table class="aa-kendo-grid">
                            <thead>
                                <tr>
                                    <th>Delete</th>
                                    <th>Edit</th>
                                    <th>Name</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                groupCount = g_collateralFieldGroupCount
                                IF groupCount >= 0 THEN
                                    groupList = g_collateralFieldGroupList
                                ELSE
                                    Set groupList = Nothing
                                END IF

                                Dim groupsCollateralDisplayed : groupsCollateralDisplayed = 0
                                hasGroups = false
                                FOR j = 0 TO groupCount - 1
                                    tabStyle=""
                                    IF CheckForNull(accountClassId) = CheckForNull(groupList(FDG_ACCOUNT_CLASS_ID,j)) THEN
                                        hasGroups = true

                                        IF selectCollateralGroup = "" THEN
                                            selectCollateralGroup = groupList(FDG_ID,j)
                                        END IF

                                        IF selectCollateralGroup = groupList(FDG_ID,j) THEN
                                            tabStyle= "group-selected"
                                            Session("fieldDefMaint.selectCollateralGroup") = selectCollateralGroup
                                        END IF

                                        sqlCmd = "SELECT COUNT(*) AS result FROM fieldDefinition WHERE fieldDefGroupId=" & dbFormatId(groupList(FDG_ID,j))
                                        Set resultRS = db.Execute(sqlCmd)
                                        enableDelete = false
                                        IF resultRS("result") = 0 THEN enableDelete = true
                                        resultRS.Close
                                        %>
                                        <tr class="<%=tabStyle%>">
                                            <td><%
                                            IF enableDelete THEN
                                                %><a href="fielddefgroupupdate.asp?action=DELETE&fieldDefGroupId=<%= groupList(FDG_ID,j) %>&fieldDefGroupLabel=<%= groupList(FDG_LABEL,j) %>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete" aria-hidden="true"></i></a><%
                                            ELSE
                                                %><i class="aa-icon fas fa-trash-alt fa-fw disabled" title="Delete" aria-hidden="true"></i><%
                                            END IF
                                            %></td>
                                            <td><a href="javascript:void(0);" onclick="openKendoDialog('Edit <%=accountClassName%> Field Group', 'fielddefgroupmaint.asp?action=EDIT&fieldDefGroupId=<%=groupList(FDG_ID,j)%>&accountClassId=<%=accountClassId%>&isCollateral=1', 500, 700);" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></td>
                                            <td><a href="fielddeflist.asp?selectTab=<%=accountClassCode%>Tab&selectGroup=<%=selectGroup%>&selectCollateralGroup=<%= groupList(FDG_ID,j) %>&isCollateral=1"><%= groupList(FDG_LABEL,j) %></a></td>
                                        </tr>
                                        <%
                                        groupsCollateralDisplayed = groupsCollateralDisplayed + 1
                                    END IF ' ### IF CheckForNull(accountClassId) = CheckForNull(groupList(FDG_ACCOUNT_CLASS_ID,j))
                                NEXT ' ### j
                                IF groupsCollateralDisplayed = 0 THEN
                                    %><tr>
                                        <td class="aa-tac" colspan="3"><b>No Collateral Groups are Defined. Please Add a New Collateral Group to Continue.</b></td>
                                    </tr><%
                                END IF
                            %></tbody>
                        </table>
                    </div>
                    <div>
                        <% IF hasGroups THEN %>
                            <div class="spacer"></div>
                            <div class="aa-panel">
                                <div>
                                    <h2><%=GetGroupName(selectCollateralGroup)%></h2>
                                </div>
                                <div>
                                    <a href="javascript:void(0);" onclick="openKendoDialog('Add New <%=accountClassName%> Field', 'fielddefmaint.asp?action=ADD&accountClassId=<%=accountClassId%>&fieldDefGroupId=<%=selectCollateralGroup%>&isCollateral=1', 500, 700);" class="k-button k-primary"><i class="aa-icon fas fa-plus-circle" aria-hidden="true"></i>&nbsp;&nbsp;<%=accountClassName%> Collateral Field</a>
                                </div>
                            </div>
                            <table class="aa-kendo-grid main">
                                <thead>
                                    <tr>
                                        <th>Delete</th>
                                        <th>Edit</th>
                                        <th>Field Name</th>
                                        <th>Default Status</th>
                                        <th>Searchable</th>
                                        <th>Displayable</th>
                                        <th>Display Order</th>
                                        <th>Covenant</th>
                                        <th>DataType</th>
                                        <th>Column Name</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    fieldDefCount = g_collateralFieldDefCount
                                    IF fieldDefCount >= 0 THEN
                                        fieldDefList = g_collateralFieldDefList
                                    ELSE
                                        Set fieldDefList = Nothing
                                    END IF

                                    Dim nFieldColCount : nFieldColCount = 0
                                    FOR j = 0 TO fieldDefCount - 1
                                        IF cStr(selectCollateralGroup) = cStr(fieldDefList(FIELD_DEF_GROUP_ID, j)) THEN
                                            %>
                                            <tr>
                                                <td><a href="javascript:void(0);" onclick="openKendoDialog('Delete <%=Replace(fieldDefList(FIELD_DEF_LABEL,j), "'", "\'")%>', 'fielddefdeleteconfirm.asp?action=DELETE&fieldDefId=<%=fieldDefList(FIELD_DEF_ID,j)%>&fieldDefLabel=<%=fieldDefList(FIELD_DEF_LABEL,j)%>&fieldDefName=<%=fieldDefList(FIELD_DEF_NAME,j)%>&accountClassCode=<%=accountClassCode%>', 500, 700);" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete" aria-hidden="true"></i></a></td>
                                                <td><a href="javascript:void(0);" onclick="openKendoDialog('Edit <%=Replace(fieldDefList(FIELD_DEF_LABEL,j), "'", "\'")%>', 'fielddefmaint.asp?action=EDIT&fieldDefId=<%=fieldDefList(FIELD_DEF_ID,j)%>&accountClassCode=<%=accountClassCode%>', 600, 700);" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></td>
                                                <td><%=fieldDefList(FIELD_DEF_LABEL,j)%></td>
			                                    <td><%=ShowCheckmark(fieldDefList(FIELD_DEF_IS_ACTIVE, j), "", "")%></td>
			                                    <td><%=ShowCheckmark(fieldDefList(FIELD_DEF_SEARCHABLE, j), "", "")%></td>
			                                    <td><%=ShowCheckmark(fieldDefList(FIELD_DEF_DISPLAYABLE, j), "", "")%></td>
                                                <td><%=fieldDefList(FIELD_DEF_DISPLAY_ORDER,j)%></td>
			                                    <td><%=ShowCheckmark(fieldDefList(FIELD_DEF_IS_COVENANT, j), "", "")%></td>
                                                <td><%=GetDataTypeLabel(fieldDefList(FIELD_DEF_DATA_TYPE,j))%></td>
                                                <td><%=fieldDefList(FIELD_DEF_NAME,j)%></td>
                                            </tr>
                                            <%
                                            nFieldColCount = nFieldColCount + 1
                                        END IF
                                    NEXT ' ### j
                                    IF nFieldColCount = 0 THEN
                                        %><tr>
                                            <td class="aa-tac" colspan="10">No Flex Fields Found</td>
                                        </tr><%
                                    END IF
                                %></tbody>
                            </table>
                        <% END IF ' ### groupCount > 0 %>
                    <% END IF ' ### IF accountClassCode <> "credit" %>
                </div>
            </div>