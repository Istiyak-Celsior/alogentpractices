<% IF g_creditFieldDefCount > 0 THEN %>
<tr class="aa-no-background-color">
    <td colspan="3"><h2>Custom Fields</h2></td>
</tr>
<% END IF %>
<%
Dim customerFieldCmd   : SET customerFieldCmd = Server.CreateObject("ADODB.Command")
Dim customerFieldsRS   : SET customerFieldRS = Nothing
Dim customerFieldQuery : customerFieldQuery = "SELECT cf.* FROM customer AS c LEFT OUTER JOIN customerFields AS cf ON c.customerId=cf.customerId WHERE c.customerId = ?"

IF action = "ADD" THEN
    ' ### NOTE the WHERE clause is necessary to force an empty RecordSet to allow displaying the flex fields on an ADD action. This is due to a customerId not existing yet.
    customerFieldQuery = "SELECT cf.* FROM customer AS c LEFT OUTER JOIN customerFields AS cf ON c.customerId=cf.customerId WHERE 1=2"
END IF
    
customerFieldCmd.ActiveConnection = db
customerFieldCmd.CommandType      = adCmdText
customerFieldCmd.CommandText      = customerFieldQuery

IF action <> "ADD" THEN
    customerFieldCmd.Parameters.Append(customerFieldCmd.CreateParameter(, adGUID, adParamInput, , customerId))
END IF
    
SET customerFieldsRS = customerFieldCmd.Execute()

Dim fieldDefGroupId, fieldDefGroupName, fieldDefGroupLabel
Dim fieldDefId, fieldDefName, fieldDefLabel
Dim fieldDefIsDisplayable
Dim fieldDefDataType, fieldDefDataSize
Dim fieldDefChoiceList, fieldDefChoiceDefaultValue
Dim fieldDefIsCovenant, covenantDefaultMinValue, covenantDefaultMaxValue, covenantDefaultTestFrequency
Dim formType, formSize, formMaxLength
Dim fieldValue, fieldIsActive, fieldSize, fieldPrecision

for i = 0 to g_creditFieldGroupCount - 1
    fieldSize = ""
    fieldPrecision = ""
    fieldDefGroupId = g_creditFieldGroupList(FDG_ID,i)
    fieldDefGroupName = g_creditFieldGroupList(FDG_NAME,i)
    fieldDefGroupLabel = g_creditFieldGroupList(FDG_LABEL,i)

    firstTime = true
    Dim fieldDisplayCount : fieldDisplayCount = 0
    FOR k = 0 TO g_creditFieldDefCount - 1
        fieldDefIsDisplayable  = g_creditFieldDefList(FIELD_DEF_DISPLAYABLE,k)
        fieldGroupId = g_creditFieldDefList(FIELD_DEF_GROUP_ID,k)
        IF fieldGroupId = fieldDefGroupId THEN
            IF fieldDefIsDisplayable THEN fieldDisplayCount = fieldDisplayCount + 1
        END IF
    NEXT

    FOR j = 0 TO g_creditFieldDefCount - 1
        IF fieldDisplayCount > 0 THEN
            fieldDefId = g_creditFieldDefList(FIELD_DEF_ID ,j)
            fieldDefName = g_creditFieldDefList(FIELD_DEF_NAME ,j)
            fieldDefIsActive = Trim(g_creditFieldDefList(FIELD_DEF_IS_ACTIVE,j))
            fieldDefLabel = g_creditFieldDefList(FIELD_DEF_LABEL,j)
            fieldDefIsDisplayable = g_creditFieldDefList(FIELD_DEF_DISPLAYABLE,j)
            fieldDefDataType  = g_creditFieldDefList(FIELD_DEF_DATA_TYPE,j)
            fieldDefDataSize = g_creditFieldDefList(FIELD_DEF_DATA_SIZE,j)
            fieldDefChoiceList = g_creditFieldDefList(FIELD_DEF_CHOICE_LIST,j)
            fieldDefChoiceDefaultValue = g_creditFieldDefList(FIELD_DEF_CHOICE_DEFAULT_VALUE,j)
            fieldGroupId = g_creditFieldDefList(FIELD_DEF_GROUP_ID,j)
            fieldIsActive = g_creditFieldDefList(FIELD_DEF_IS_ACTIVE, j)

            IF IsNull(fieldIsActive) Or fieldIsActive = "" THEN
                fieldIsActive = fieldDefIsActive
            END IF

            ' ### Covenant related fields ###
            fieldDefIsCovenant = Trim(g_creditFieldDefList(FIELD_DEF_IS_COVENANT, j))
            CovenantDefaultTestFrequency = Trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_TEST_FREQUENCY,j))
            CovenantDefaultMinValue = Trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_MIN_VALUE,j))
            CovenantDefaultMaxValue = Trim(g_creditFieldDefList(FIELD_DEF_DEFAULT_MAX_VALUE,j))

            IF fieldGroupId = fieldDefGroupId THEN
                formSize = "20"
                formMaxLength = ""

                IF fieldDefDatatype = "varchar" THEN
                    IF fieldDefDataSize > 60 THEN
                        formSize = 60
                    ELSE
                        formSize = fieldDefDataSize
                    END IF
                    formMaxLength = fieldDefDataSize
                ELSEIF fieldDefDataType = "datetime" THEN
                    formMaxLength = "10"
                END IF

                IF NOT customerFieldsRS.EOF THEN
                    fieldValue = CheckForNull(customerFieldsRS(fieldDefName))
                    IF (IsNull(customerFieldsRS(fieldDefName & "_isActive"))) THEN
                        fieldIsActive = 1
                    ELSEIF (customerFieldsRS(fieldDefName & "_isActive")) THEN
                        fieldIsActive = 1
                    ELSE
                        fieldIsActive = 0
                    END IF
                END IF

                IF action = "ADD" THEN
                    fieldValue = ""
                    ' ### Special check for CIF integration during an add to bring in the CIF Number. ###
                    IF Session("cifIntegration.enabled") = "1" AND lCase(fieldDefName) = lCase("flex_CustomerIDNumber") THEN
                        fieldValue = Session("cifInquiryResult.CifNumber")
                    END IF
                END IF

                Dim fieldActiveIcon, fieldActiveStatus
                IF fieldIsActive THEN
                    fieldActiveIcon = "aa-icon fas fa-circle aa-status-yes fa-fw"
                    fieldActiveStatus = "Active Field"
                ELSE
                    fieldActiveIcon = "aa-icon fas fa-circle aa-status-no fa-fw"
                    fieldActiveStatus = "Inactive Field"
                END IF

                IF firstTime THEN
                    firstTime = false
                    %>
                    <tr class="aa-flexfield-header">
                        <td colspan="3"><%=fieldDefGroupLabel%></td>
                    </tr>
                    <%
                END IF

                Dim covenantException, covenantOutOfDate
                Dim covenantMinValue, covenantMaxValue, covenantTestFrequency, covenantLastTestDate

                Dim covenant : covenant = GetCreditCovenant(customerId, fieldDefId)
                Dim covenantId : covenantId = Trim(covenant(COVENANT_ID, 0))

                ' ### Get the Covenant Values ###
                IF Trim(covenantId & "") = "" THEN
                    ' ### Covenant Record does not exist, use defaults ###
                    CovenantMinValue = CovenantDefaultMinValue
                    CovenantMaxValue = CovenantDefaultMaxValue
                    CovenantTestFrequency = CovenantDefaultTestFrequency
                ELSE
                    Dim useMaster : useMaster = CBool(Trim(covenant(COVENANT_USE_MASTER,0)))
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
                IF fieldDefIsDisplayable THEN
                    fieldDisplayCount = fieldDisplayCount + 1
                    %>
                    <tr>
                        <td><%=fieldDefLabel%>:</td>
                        <td colspan="2">
                            <ul class="aa-flexfield-list">
                                <li class="status-icon"><a href="javascript:void(0);" id="link_flex_<%=fieldDefName%>_isActive" class="aa-command-link"><i class="<%=fieldActiveIcon%>" id="img_flex_<%=fieldDefName%>_isActive" title="<%=fieldActiveStatus%> - Click to Change" aria-hidden="true"></i><input type="hidden" id="id_flex_<%=fieldDefName%>_isActive" name="flex_<%=fieldDefName%>_isActive" value="<%=fieldIsActive%>"/></a></li>
                                <%
                                IF action="EDIT" AND fieldDefIsCovenant THEN
                                    Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?customerId=" & customerId & "&fieldDefId=" & fieldDefId & "', 500, 700);"" class=""aa-command-link""><i class=""aa-icon fas fa-pencil-alt fa-fw"" title=""Edit Covenant"" aria-hidden=""true""></i></a></li>" & vbCr
                                ELSE
                                    Response.Write "<li><i class=""aa-icon fas fa-pencil-alt fa-fw aa-partial"" aria-hidden=""true""></i></li>" & vbCr
                                END IF

                                IF fieldDefIsCovenant AND covenantException THEN
                                    Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-full aa-color-danger"" title=""Covenant Exception"" aria-hidden=""true""></i></li>" & vbCr
                                ELSE
                                    Response.Write "<li><i class=""aa-icon fas fa-exclamation-circle fa-fw aa-partial"" aria-hidden=""true""></i></li>"
                                END IF

                                IF fieldIsActive THEN
                                    IF action = "EDIT" AND fieldDefIsCovenant AND covenantOutOfDate THEN
                                        Response.Write "<li><a href=""javascript:void(0);"" onclick=""openKendoDialog('Edit Covenant', 'covenantmaint.asp?customerId=" & customerId & "&fieldDefId=" & fieldDefId & "', 500, 700);"" class=""aa-command-link""><i class=""aa-icon fas fa-bell fa-fw"" title=""Covenant Value Requires Review"" aria-hidden=""true""></i></a></li>" & vbCr
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
                                    IF Trim(fieldValue & "") = "" THEN fieldValue = "0"
                                    %><li><input type="checkbox" class="k-checkbox" name="flex_<%=fieldDefName%>" id="flex_<%=fieldDefName%>" value="1"<% IF fieldValue THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="flex_<%=fieldDefName%>"></label></li><%
                                ELSEIF fieldDefDataType = "varchar" AND fieldDefDataSize > 128 THEN
                                    %><li><textarea class="k-textbox" name="flex_<%=fieldDefName%>" cols="40" rows="5" maxlength="<%=formMaxLength%>"><%=fieldValue%></textarea><li><%
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
                                        %><li><input type="text" class="k-textbox" name="flex_<%=fieldDefName%>" size="<%=formSize%>" maxlength="<%=formMaxLength%>" value="<%=fieldValue%>" onblur="Validate<%=fieldType%>Field(this, <%=fieldSize-fieldPrecision%>, <%=fieldPrecision%>);"/></li><%
                                    ELSE
                                        %><li><input type="text" class="k-textbox" name="flex_<%=fieldDefName%>" size="<%=formSize%>" maxlength="<%=formMaxLength%>" value="<%=fieldValue%>" onblur="Validate<%=fieldType%>Field(this);"/><li><%
                                    END IF
                                END IF
                                %>
                            </ul>
                        </td>
                    </tr>
                    <%
                END IF ' ### IF fieldIsDisplayable
            END IF ' ### fieldGroupId = fieldDefGroupid
        END IF ' ### IF fieldDefIsDisplayable > 0
    NEXT ' ###j
NEXT ' ### i
customerFieldsRS.Close

%>