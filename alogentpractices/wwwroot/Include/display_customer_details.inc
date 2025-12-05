<table>
    <tr>
        <td class="aa-background-base-medium">Customer Name</td>
        <td class="aa-background-base-light">
            <ul id="aa-customer-name-list">
                <% IF Session("acculoan.enablePurge") = 1 THEN %><% IF customerRS("PurgeStatus") OR customerRS("CustomerBlockPurge") OR (NOT customerRS("PurgeStatus") AND customerRS("PurgeStatusLocked")) THEN %><li><%=GetPurgeStatusIcon(customerRS("PurgeStatus"), customerRS("PurgeStatusLocked"), customerRS("CustomerBlockPurge"))%></li><% END IF %><% END IF %>
                <li><%=customerRS("customerName")%></li>
            </ul>
            <% IF customerRS("Employee") = 1 THEN %><div class="aa-employee-badge">employee</div><% END IF %>
        </td>
        <td class="aa-background-base-medium">Customer Number</td>
        <td class="aa-background-base-light"><%=customerRS("customerNumber")%></td>
        <td class="aa-background-base-medium">Customer Type</td>
        <td class="aa-background-base-light"><%
        Dim ii : FOR ii = 0 TO custTypeRows
            IF custTypeArray(0, ii) = customerRS("customerTypeId") THEN Response.Write custTypeArray(1, ii)
        NEXT
        %></td>
    </tr>
    <tr>
        <td class="aa-background-base-medium">Name 2</td>
        <td class="aa-background-base-light"><%=customerRS("businessName")%></td>
        <td class="aa-background-base-medium">Tax Id</td>
        <td class="aa-background-base-light"><%=customerRS("taxID")%></td>
        <td class="aa-background-base-medium">Status</td>
        <td class="aa-background-base-light"><%=customerRS("customerStatusDescription")%></td>
    </tr>
    <%
    Dim classificationStyle : classificationStyle = ""
    Dim classRS : Set classRS = Server.CreateObject("ADODB.RecordSet")
    Dim classQuery : classQuery = _
        "SELECT " & _
        "   displayEmphasis," & _
        "   displayColor," & _
        "   classificationName," & _
        "   classificationCode" & _
        " FROM" & _
        "   creditClassification" & _
        " WHERE" & _
        "   classificationId = " & dbFormatId(customerRS("classificationid"))
    classRS.Open classQuery, db, adOpenForwardOnly, adLockReadOnly
    IF classRS("displayEmphasis") THEN
        classificationStyle = "font-weight: bold"
    ELSE
        classificationStyle = "font-weight: normal"
    END IF
    classificationStyle = classificationStyle & "; color: " & classRS("displayColor")
    Dim classificationName : classificationName = classRS("classificationName")
    Dim classificationCode : classificationCode = classRS("classificationCode")
    classRS.Close
    %>
    <tr>
        <td class="aa-background-base-medium">Credit Classification</td>
        <td class="aa-background-base-light" style="<%=classificationStyle%>"><%=classificationName%></td>
        <td class="aa-background-base-medium">Officer Name</td>
        <td class="aa-background-base-light">
        <%
        IF IsNULL(CustomerRS("customerOfficerName")) THEN
            Response.write "Unassigned"
        ELSE
            Response.write CustomerRS("customerOfficerName")
        END IF
	
        Dim regionName : regionName = CheckForNull(customerRS("regionName"))
        IF regionName = "" THEN regionName = "---"
        %></td>
        <td class="aa-background-base-medium">Branch <i>(Region)</i></td>
        <td class="aa-background-base-light"><%=customerRS("branchName")%> <i>(<%=regionName%>)</i></td>
    </tr>
    <%
    Dim custFso : Set custFso = Server.CreateObject("Scripting.FileSystemObject")
    Dim currentUploadDir : currentUploadDir = GetCurrentUploadDirectory("")
    Dim userUploadPath : userUploadPath = Session("serverPath") & currentUploadDir

    IF NOT custFso.FolderExists(userUploadPath) THEN custFso.CreateFolder userUploadPath

    Dim userUploadFolder : Set userUploadFolder = custFso.GetFolder(userUploadPath)
    Dim uploadFile
    Dim pendingUploadCount : pendingUploadCount = 0
    FOR EACH uploadFile In userUploadFolder.Files
        IF NOT lCase(uploadFile.Name) = "thumbs.db" THEN pendingUploadCount = pendingUploadCount + 1
    NEXT
    %>
    <tr>
        <td class="aa-background-base-medium"><%
        IF Session("accuaccount.enableFinpack") = "1" THEN
            Response.Write "FINPACK Link"
        ELSEIF Trim(session("acculoan.linkToolURL")) <> "" THEN
            IF customerRS("allowExternalAppLink") = "True" THEN Response.Write session("acculoan.linkToolLabel")
        END IF
        %></td>
        <td class="aa-background-base-light">
        <table>
            <tr>
                <td>
                <% IF Session("accuaccount.enableFinpack") = "1" THEN %>
                    <a href="accufp:<%=customerRS("customerNumber")%>"><img src="Content/Images/Nav/button-link.gif" style="border:none" alt="Launch FINPACK" align="middle"/></a>
                <% ELSEIF Trim(session("acculoan.linkToolURL")) <> "" THEN
                    linkURL = session("acculoan.linkToolURL")
                    linkURL = replace(linkURL,"<<TAXID>>",customerRS("taxID"), 1, -1, vbTextCompare)
                    linkURL = replace(linkURL,"<<CUSTOMERNUMBER>>",customerRS("customerNumber"),1, -1, vbTextCompare)			   
                    linkURL = replace(linkURL,"TAXID=","taxID=", 1, -1, vbTextCompare)
                    linkURL = replace(linkURL,"CUSTOMERNUMBER=","customerNumber=",1, -1, vbTextCompare)
                    IF customerRS("allowExternalAppLink") = "True" THEN
                    %>
                    <a href="<%=linkURL%>"><img src="Content/Images/Nav/button-link.gif" style="border:none" alt="Link To" align="middle"/></a>
                    <%
                    END IF
                END IF
                %></td>
                <% IF Session("accuaccount.disableImaging") = "0" THEN %>
                <%
                Dim hasUploadFileAccess : hasUploadFileAccess = False
                IF Session("isSuperUser") _
                OR Session("credit.isAdmin") OR Session("credit.allowDocRead") OR Session("credit.allowDocEdit") _
                OR Session("loanapp.isAdmin") OR Session("loanapp.allowDocRead") OR Session("loanapp.allowDocEdit") _
                OR Session("deposit.isAdmin") OR Session("deposit.allowDocRead") OR Session("deposit.allowDocEdit") _
                OR Session("trust.isAdmin") OR Session("trust.allowDocRead") OR Session("trust.allowDocEdit") _
                OR Session("loan.isAdmin") OR Session("loan.allowDocRead") OR Session("loan.allowDocEdit") THEN
                    hasUploadFileAccess = True
                END IF
                %>
                <td>
                    <ul id="aa-upload-list">
                        <% IF NOT hasUploadFileAccess THEN %>
                        <li><i class="aa-icon fas fa-file-alt fa-fw" title="You do not have Permission to View any Documents. Please Check with your Administrator" aria-hidden="true"></i></li>
                        <li>View Uploaded Files (<%=pendingUploadCount%> File<% IF pendingUploadCount <> "1" THEN %>s<% END IF %>)</li>
                        <% ELSE %>
                        <li><a href="javascript:void(0);" onclick="openKendoDialog('View Upload Files', 'viewuploadfiles.asp', 500, 700);"><i class="aa-icon fas fa-file-alt" title="Upload" aria-hidden="true"></i></a></li>
                        <li><a href="javascript:void(0);" onclick="openKendoDialog('View Upload Files', 'viewuploadfiles.asp', 500, 700);">View Uploaded Files</a>&nbsp;(<a href="viewuploadfolder.asp">Full Screen</a>)</li>
                        <li>(<%=pendingUploadCount%> File<% IF pendingUploadCount <> "1" THEN %>s<% END IF %>)</li>
                        <% END IF %>
                    </ul>
                </td>
                <% END IF %>
            </tr>
        </table>
        </td>
        <td class="aa-background-base-medium"><% IF Session("acculoan.showloantotals") <> 0 THEN %>Total Loan Balance<% END IF %></td>
        <td class="aa-background-base-light">
        <%
        Dim custTotalsRS : Set custTotalsRS = Server.Createobject("ADODB.RecordSet")
        Dim custTotalsQry : custTotalsQry = _
            " SELECT" & _
            "   SUM(v1.loanAmount) AS loanAmount," & _
            "   SUM(v1.commitmentAmount) AS commitmentAmount" & _
            " FROM" & _
            " (" & _
            "   SELECT " & _
            "       l.customerId, " & _
            "       SUM(CAST(l.loanAmount AS money)) AS loanAmount, " & _
            "       SUM(ISNULL(l.commitmentAmount, 0)) AS commitmentAmount " & _
            "   FROM " & _
            "       viewLoansAndCollaterals AS l" & _
            "   WHERE " & _
            "       l.customerId = " & dbformatid(selectedCustomerId) & _
            "       AND l.isActiveLoanStatus = 1" & _
            "       AND l.isCollateralYN LIKE 'N'" & _
            "       AND l.isCrossCollateralYN LIKE 'N'" & _
            "   GROUP BY " & _
            "       l.customerId" & _
            "   UNION" & _
            "   SELECT" & _
            "       cb.customerId," & _
            "       SUM(CAST(cbl.loanAmount AS money))  AS loanAmount," & _
            "       SUM(ISNULL(cbl.commitmentAmount, 0)) AS commitmentAmount" & _
            "   FROM" & _
            "       coborrower AS cb INNER JOIN viewLoansAndCollaterals AS cbl" & _
            "           ON cb.loanId=cbl.loanId" & _
            "   WHERE" & _
            "       cbl.isActiveLoanStatus = 1" & _
            "       AND cbl.isCollateralYN LIKE 'N'" & _
            "       AND cbl.isCrossCollateralYN LIKE 'N'" & _
            "       AND cb.customerId=" & dbFormatId(selectedCustomerId) & _
            "   GROUP BY cb.customerId" & _
            " ) AS v1"
        custTotalsRS.Open custTotalsQry, db, adOpenForwardOnly, adLockReadOnly

        IF NOT custTotalsRS.EOF THEN
            Dim loanAmt : loanAmt = checkForNull(custTotalsRS("loanAmount"))
            IF Session("acculoan.showloantotals") <> 0 THEN
                IF NOT isNumeric(loanAmt) THEN
                    Response.Write FormatCurrency(0)
                ELSE
                    Response.Write FormatCurrency(loanAmt)
                END IF
            END IF ' // Session("acculoan.showloantotals") <> 0 THEN //
        %>
        </td>
        <td class="aa-background-base-medium"><% IF Session("acculoan.showloantotals") <> 0 THEN %>Total Loan Commitment<% END IF %></td>
        <td class="aa-background-base-light">
        <%
        Dim CommitAmt : CommitAmt = checkForNull(custTotalsRS("commitmentAmount"))
        IF Session("acculoan.showloantotals") <> 0 THEN
            IF NOT IsNumeric(CommitAmt) THEN
                Response.Write FormatCurrency(0)
            ELSE
                Response.Write FormatCurrency(custTotalsRS("commitmentAmount"))
            END IF
        END IF
        custTotalsRS.Close
        Response.Write "</td>"

        ELSE
            loanAmt = 0
            Response.Write FormatCurrency(0)
        %></td>
        <td class="aa-background-base-medium">Total Loan Commitment</td>
        <td class="aa-background-base-light"><% CommitAmt = 0 %><%=FormatCurrency(0)%></td>
        <% END IF ' // IF NOT custTotalsRS.EOF THEN // %>
    </tr>
    <!-- BEGIN Credit Flex Field Display -->
    <%
    CheckCustomFieldsExistance(selectedCustomerId)

    hasDisplayedFlexField = False

    Dim rootGroupDisplayState : rootGroupDisplayState = Request.Cookies("creditfield_DisplayState")
    IF rootGroupDisplayState = "" THEN rootGroupDisplayState = "collapsed"

    Dim customerFieldRS : Set customerFieldRS = Server.CreateObject("ADODB.RecordSet")
    Dim customerFieldQuery : customerFieldQuery = _
        " SELECT * FROM customerFields WHERE customerId = " & dbFormatId(selectedCustomerId)
    customerFieldRS.Open customerFieldQuery, db, adOpenForwardOnly, adLockReadOnly

    Dim visibleGroupsCheck
    ' ### Check for Strange VBScript Behavior ###
    visibleFieldsCheck = False
    IF g_creditFieldGroupCount >= 1 AND g_creditFieldDefCount >= 1 THEN
        visibleGroupsCheck = HasVisibleGroups(g_creditFieldDefList, g_creditFieldGroupList, customerFieldRS)
    END IF

    IF visibleGroupsCheck = True THEN
        Dim visibleFieldsCheck
        Dim groupIdx, fieldIdx
        Dim fieldDefGroupId, fieldDefGroupName, fieldDefGroupLabel

        groupIdx = 0
        FOR i = 0 TO g_creditFieldGroupCount - 1
            Dim fieldLabel, fieldName, fieldValue, fieldGroupId
            Dim fieldDisplayed, firstTime

            fieldIdx = 0
            fieldDefGroupId = g_creditFieldGroupList(FDG_ID,i)
            fieldDefGroupName = g_creditFieldGroupList(FDG_NAME,i)
            fieldDefGroupLabel = g_creditFieldGroupList(FDG_LABEL,i)

            ' ### Check for Strange VBScript Behavior ###
            visibleFieldsCheck = False
            IF g_creditFieldDefCount >= 1 THEN visibleFieldsCheck = HasVisibleFields(g_creditFieldDefList, fieldDefGroupId, customerFieldRS)

            IF visibleFieldsCheck = True THEN
                fieldIdx = 0
                fieldDisplayed = False
                firstTime = True

                FOR j = 0 TO g_creditFieldDefCount - 1
                    fieldLabel = g_creditFieldDefList(FIELD_DEF_LABEL, j)
                    fieldName = g_creditFieldDefList(FIELD_DEF_NAME, j)
                    fieldValue = CheckForNull(customerFieldRS(g_creditFieldDefList(FIELD_DEF_NAME,j)))
                    fieldGroupId = g_creditFieldDefList(FIELD_DEF_GROUP_ID, j)
                    fieldDefIsCovenant = Trim(g_creditFieldDefList(FIELD_DEF_IS_COVENANT, j))
                    IF NOT fieldDefIsCovenant THEN
                        IF IsNull(customerFieldRS(fieldName & "_isActive")) THEN
                            isActiveField = True
                        ELSE
                            isActiveField = customerFieldRS(fieldName & "_isActive")
                        END IF

                        IF cStr(fieldGroupId) = cStr(fieldDefGroupId) THEN
                            hasFieldValue = True
                            IF fieldValue = "" THEN hasFieldValue = False

                            IF g_creditFieldDefList(FIELD_DEF_DISPLAYABLE, j) AND hasFieldValue AND isActiveField THEN
                                hasDisplayedFlexField = True
                                fieldDisplayed = True

                                IF g_creditFieldDefList(FIELD_DEF_DATA_TYPE, j) = "money" THEN
                                    IF IsNumeric(fieldValue) THEN fieldValue = FormatCurrency(fieldValue,2)
                                ELSEIF g_creditFieldDefList(FIELD_DEF_DATA_TYPE, j) = "datetime" THEN
                                    IF IsDate(fieldValue) THEN fieldValue = FormatDateTime(fieldValue,2)
                                END IF

                                groupDisplayState = Request.Cookies("creditfield_" & groupIdx & "_DisplayState")
                                IF rootGroupDisplayState = "collapsed" THEN
                                    groupDisplayStyle = "none"
                                    fieldDisplayStyle = "none"
                                ELSEIF groupDisplayState = "collpased" Or groupDisplayState = "" THEN
                                    groupDisplayStyle = ""
                                    fieldDisplayStyle = "none"
                                ELSE
                                    groupDisplayStyle = "none"
                                    fieldDisplayStyle = ""
                                END IF

                                IF firstTime THEN
                                    firstTime = False
                                    %>
                                    <tr id="creditfield_<%=groupIdx%>" style="display:<%=groupDisplayStyle%>">
                                        <td class="aa-tar aa-background-base-dark"><%
                                        IF groupIdx = 0 THEN
                                            Response.Write "<a href=""javascript:void(0);"" onclick=""ExpandFields(this, 'creditfield', 0);""><i class=""aa-icon fas fa-minus-square fa-fw"" title=""Collapse Extended Fields"" aria-hidden=""true""></i></a>"
                                        END IF
                                        %></td>
                                        <td class="aa-tac aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'creditfield_<%=groupIdx%>', 1);"><i class="aa-icon fas fa-plus-square fa-fw" title="View <%=fieldDefGroupLabel%> Fields" aria-hidden="true"></i></a></td>
                                        <td class="aa-background-base-medium"><%=fieldDefGroupLabel%></td>
                                        <td colspan="5" class="aa-background-base-light"><i>View Group Details</i></td>
                                    </tr>
                                    <tr id="creditfield_<%=groupIdx%>_<%=fieldIdx%>" style="display:<%=fieldDisplayStyle%>">
                                        <td class="aa-tar aa-background-base-dark"><%
                                        IF groupIdx = 0 THEN
                                            Response.Write "<a href=""javascript:void(0);"" onclick=""ExpandFields(this, 'creditfield', 0);""><i class=""aa-icon fas fa-minus-square fa-fw"" title=""Collapse Extended Fields"" aria-hidden=""true""></i></a>"
                                        END IF
                                        %></td>
                                        <td class="aa-tac aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'creditfield_<%=groupIdx%>', 1);"><i class="aa-icon fas fa-minus-square fa-fw" title="View <%=fieldDefGroupLabel%> Fields" aria-hidden="true"></i></a></td>
                                        <td class="aa-background-base-dark"><%=fieldDefGroupLabel%></td>
                                        <td class="aa-background-base-medium"><%=fieldLabel%></td>
                                        <td colspan="4" class="aa-background-base-light"><%=fieldValue%>&nbsp;</td>
                                    </tr>
                                    <% ELSE %>
                                    <tr id="creditfield_<%=groupIdx%>_<%=fieldIdx%>" style="display:<%=fieldDisplayStyle%>">
                                        <td class="aa-background-base-dark">&nbsp;</td>
                                        <td class="aa-tac aa-background-base-dark">&nbsp;</td>
                                        <td class="aa-background-base-dark">&nbsp;</td>
                                        <td class="aa-background-base-medium"><%=fieldLabel%></td>
                                        <td colspan="4" class="aa-background-base-light"><div style="word-wrap: break-word;"><%=fieldValue%>&nbsp;</div></td>
                                    </tr>
                                    <%
                                END IF ' // firstTime //
                                fieldIdx = fieldIdx + 1
                            END IF ' // g_creditFieldDefList(FIELD_DEF_DISPLAYABLE, j) AND hasFieldValue //
                        END IF ' // cStr(fieldGroupId) = cStr(fieldDefGroupId) //
                    END IF ' // IF NOT fieldDefIsCovenant
                NEXT ' // j //

                ' ### If one or more group flex fields were displayed increment count. NOTE: we only increment
                ' when there is a displayable Group with Flex Fields. ###
                IF fieldDisplayed THEN groupIdx = groupIdx + 1
            END IF ' // visibleFieldsCheck = True //
        NEXT ' // i //
    END IF ' // visbleGroupsCheck = True //
    IF hasDisplayedFlexField THEN
    %>
    <tr id="creditfield" style="display:<% IF rootGroupDisplayState = "collapsed" THEN %>table-row<% ELSE %>none<% END IF %>">
        <td class="aa-tar aa-background-base-dark"><a href="javascript:void(0);" onclick="ExpandFields(this, 'creditfield', 0);"><i class="aa-icon fas fa-plus-square fa-fw" title="Collapse Extended Fields"></i></a>&nbsp;</td>
        <td colspan="7" class="aa-background-base-light"><i>View Additional Information</i></td>
    </tr>
    <%
    END IF ' // Not hasDisplayedFlexField //
    customerFieldRS.Close
    %>
    <!-- END Credit Flex field Display -->
</table>