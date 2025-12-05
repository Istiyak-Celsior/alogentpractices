<%
CONST FIELD_DEF_ID = 0
CONST FIELD_DEF_NAME = 1
CONST FIELD_DEF_LABEL = 2
CONST FIELD_DEF_COLLATERAL = 3
CONST FIELD_DEF_SEARCHABLE = 4
CONST FIELD_DEF_DISPLAYABLE = 5
CONST FIELD_DEF_DISPLAY_ORDER = 6
CONST FIELD_DEF_DATA_TYPE = 7
CONST FIELD_DEF_DATA_SIZE = 8
CONST FIELD_DEF_DATA_PRECISION = 9
CONST FIELD_DEF_CHOICE_LIST = 10
CONST FIELD_DEF_CHOICE_DEFAULT_VALUE = 11
CONST FIELD_DEF_ACCOUNT_CLASS_ID = 12
CONST FIELD_DEF_GROUP_ID = 13
CONST FIELD_DEF_IS_ACTIVE = 14
CONST FIELD_DEF_IS_COVENANT = 15
CONST FIELD_DEF_DEFAULT_MIN_VALUE = 16
CONST FIELD_DEF_DEFAULT_MAX_VALUE = 17
CONST FIELD_DEF_DEFAULT_TEST_FREQUENCY = 18

CONST FIELD_DEF_MAX_COLUMNS = 18

Dim g_fieldDefQuery, gfd
Dim g_fieldDefRS : Set g_fieldDefRS = Server.CreateObject("ADODB.RecordSet")

' ### Load the Credit FieldDefinitions ###
Dim g_creditFieldDefList, g_creditFieldDefCount, g_hasCreditFieldDefList
g_fieldDefQuery = _
    " SELECT " & _
    "   fd.fieldDefId," & _
    "   fd.fieldDefName," & _
    "   fd.fieldDefLabel," & _
    "   fd.fieldDefIsCollateral," & _
    "   fd.fieldDefIsSearchable," & _
    "   fd.fieldDefIsDisplayable," & _
    "   fd.fieldDefDisplayOrder," & _
    "   fd.fieldDefDataType," & _
    "   fd.fieldDefDataSize," & _
    "   fd.fieldDefDataPrecision," & _
    "   fd.fieldDefChoiceList," & _
    "   fd.fieldDefChoiceDefaultValue," & _
    "   fd.accountClassId," & _
    "   fd.fieldDefGroupId," & _
    "   fd.IsActive," & _
    "   fd.IsCovenant," & _
    "   fd.CovenantDefaultMinValue," & _
    "   fd.CovenantDefaultMaxValue," & _
    "   fd.CovenantDefaultTestFrequency" & _
    " FROM" & _
    "   fieldDefinition AS fd INNER JOIN fieldDefGroup AS fdg" & _
    "       ON fd.fieldDefGroupId=fdg.fieldDefGroupId" & _
    " WHERE" & _
    "   fd.accountClassId IS NULL" & _
    " ORDER BY" & _
    "   fdg.fieldDefGroupOrder, fdg.fieldDefGroupLabel," & _
    "   fd.fieldDefDisplayOrder, fd.fieldDefLabel"
g_fieldDefRS.Open g_fieldDefQuery, db, adOpenForwardOnly, adLockReadOnly
g_creditFieldDefCount = 0
g_hasCreditFieldDefList = false
IF NOT g_fieldDefRS.EOF THEN
    g_creditFieldDefList = g_fieldDefRS.GetRows()
    IF isArray(g_creditFieldDefList) THEN
        FOR gfd = 0 TO uBound(g_creditFieldDefList, 2)
            g_creditFieldDefCount = g_creditFieldDefCount + 1
        NEXT
    END IF
    g_hasCreditFieldDefList = true
ELSE
    ReDim g_creditFieldDefList(FIELD_DEF_MAX_COLUMNS, 0)
    g_creditFieldDefCount = -1
END IF
g_fieldDefRs.Close()

' ### Load the Account FieldDefintions ###
g_fieldDefQuery = _
    " SELECT " & _
    "   fd.fieldDefId," & _
    "   fd.fieldDefName," & _
    "   fd.fieldDefLabel," & _
    "   fd.fieldDefIsCollateral," & _
    "   fd.fieldDefIsSearchable," & _
    "   fd.fieldDefIsDisplayable," & _
    "   fd.fieldDefDisplayOrder," & _
    "   fd.fieldDefDataType," & _
    "   fd.fieldDefDataSize," & _
    "   fd.fieldDefDataPrecision," & _
    "   fd.fieldDefChoiceList," & _
    "   fd.fieldDefChoiceDefaultValue," & _
    "   fd.accountClassId," & _
    "   fd.fieldDefGroupId," & _
    "   fd.IsActive," & _
    "   fd.IsCovenant," & _
    "   fd.CovenantDefaultMinValue," & _
    "   fd.CovenantDefaultMaxValue," & _
    "   fd.CovenantDefaultTestFrequency" & _
    " FROM" & _
    "   fieldDefinition AS fd INNER JOIN fieldDefGroup AS fdg" & _
    "       ON fd.fieldDefGroupId=fdg.fieldDefGroupId" & _
    " WHERE" & _
    "   fd.accountClassId IS NOT NULL" & _
    "   AND fd.fieldDefIsCollateral=0" & _
    " ORDER BY" & _
    "   fdg.fieldDefGroupOrder, fdg.fieldDefGroupLabel," & _
    "   fd.fieldDefDisplayOrder, fd.fieldDefLabel"
g_fieldDefRS.Open g_fieldDefQuery, db, adOpenForwardOnly, adLockReadOnly
Dim g_accountFieldDefCount : g_accountFieldDefCount = 0
Dim g_hasAccountFieldDefList : g_hasAccountFieldDefList = false
IF NOT g_fieldDefRS.EOF THEN
    Dim g_accountFieldDefList : g_accountFieldDefList = g_fieldDefRS.GetRows()
    IF isArray(g_accountFieldDefList) THEN
        FOR gfd = 0 TO uBound(g_accountFieldDefList, 2)
            g_accountFieldDefCount = g_accountFieldDefCount + 1
        NEXT
    END IF
    g_hasAccountFieldDefList = true
ELSE
    ReDim g_accountFieldDefList(FIELD_DEF_MAX_COLUMNS, 0)
    g_accountFieldDefCount = -1
END IF
g_fieldDefRS.Close()

' ### Load the Collateral FieldDefinitions ###
g_fieldDefQuery = _
    " SELECT " & _
    "   fd.fieldDefId," & _
    "   fd.fieldDefName," & _
    "   fd.fieldDefLabel," & _
    "   fd.fieldDefIsCollateral," & _
    "   fd.fieldDefIsSearchable," & _
    "   fd.fieldDefIsDisplayable," & _
    "   fd.fieldDefDisplayOrder," & _
    "   fd.fieldDefDataType," & _
    "   fd.fieldDefDataSize," & _
    "   fd.fieldDefDataPrecision," & _
    "   fd.fieldDefChoiceList," & _
    "   fd.fieldDefChoiceDefaultValue," & _
    "   fd.accountClassId," & _
    "   fd.fieldDefGroupId," & _
    "   fd.IsActive," & _
    "   fd.IsCovenant," & _
    "   fd.CovenantDefaultMinValue," & _
    "   fd.CovenantDefaultMaxValue," & _
    "   fd.CovenantDefaultTestFrequency" & _
    " FROM" & _
    "   fieldDefinition AS fd INNER JOIN fieldDefGroup AS fdg" & _
    "       ON fd.fieldDefGroupId=fdg.fieldDefGroupId" & _
    " WHERE" & _
    "   fd.accountClassId IS NOT NULL" & _
    "   AND fd.fieldDefIsCollateral=1" & _
    " ORDER BY" & _
    "   fdg.fieldDefGroupOrder, fdg.fieldDefGroupLabel," & _
    "   fd.fieldDefDisplayOrder, fd.fieldDefLabel"
g_fieldDefRS.Open g_fieldDefQuery, db, adOpenForwardOnly, adLockReadOnly
Dim g_collateralFieldDefCount : g_collateralFieldDefCount = 0
Dim g_hasCollateralFieldDefList : g_hasCollateralFieldDefList = false
IF NOT g_fieldDefRS.EOF THEN
    Dim g_collateralFieldDefList : g_collateralFieldDefList = g_fieldDefRS.GetRows()
    IF isArray(g_collateralFieldDefList) THEN
        FOR gfd = 0 TO uBound(g_collateralFieldDefList, 2)
            g_collateralFieldDefCount = g_collateralFieldDefCount + 1
        NEXT
    END IF
    g_hasCollateralFieldDefList = true
ELSE
    ReDim g_collateralFieldDefList(FIELD_DEF_MAX_COLUMNS, 0)
    g_collateralFieldDefCount = -1
END IF
g_fieldDefRS.Close()

FUNCTION HasVisibleGroups(fieldDefList, fieldDefGroupList, rs)
    Dim i
    Dim isVisible : isVisible = false
    FOR i = lBound(fieldDefGroupList,2) TO uBound(fieldDefGroupList,2)
        Dim fieldDefGroupId : fieldDefGroupId = fieldDefGroupList(FDG_ID, i)
        isVisible = HasVisibleFields(fieldDefList, fieldDefGroupId, rs)
        IF isVisible THEN EXIT FOR
    NEXT
    HasVisibleGroups = isVisible
END FUNCTION

Function HasVisibleFields(fieldDefList, groupId, rs)
    Dim isVisible : isVisible = true

    ' ### If no RecordSet then there are no active fields ###
    IF NOT rs.EOF THEN
        Dim fieldValue, fieldIsActive, fieldHasValue, i

        ' ### Iterate through given fieldDefList ###
        FOR i = lBound(fieldDefList,2) TO uBound(fieldDefList,2)
            Dim fieldDefName : fieldDefName = fieldDefList(FIELD_DEF_NAME,i)
            Dim fieldDefGroupId : fieldDefGroupId = fieldDefList(FIELD_DEF_GROUP_ID,i)
            
            IF groupId = fieldDefGroupId THEN
                IF IsNull(rs(fieldDefName)) THEN
                    fieldHasValue = false
                    fieldValue = ""
                ELSE
                    fieldHasValue = true
                    fieldValue = rs(fieldDefName)
                END IF

                ' ### Get activity flag and check for NULL ###
                IF IsNull(rs(fieldDefname & "_isActive")) THEN
                    fieldIsActive = true
                ELSE
                    fieldIsActive = rs(fieldDefName & "_isActive")
                END IF

                ' ### If the field (RecordSet value) for the given group is active
                ' or has a non-blank value the return true ###
                IF fieldIsActive AND fieldHasValue THEN
                    isVisible = true
                    EXIT FOR
                END IF
            END IF
        NEXT
    END IF
    HasVisibleFields = isVisible
END FUNCTION

SUB BuildFieldSelectElement(name, valueList, currentValue, defaultValue)
    Response.Write "<li><select name=""flex_" & name & """ style=""min-width:82px"">"
    Response.Write "<option value="""">---</option>"
    IF IsArray(valueList) THEN
        FOR EACH value IN valueList
            IF RemoveCarriageReturns(CheckForNull(currentValue)) = "" THEN currentValue = defaultValue

            IF lCase(RemoveCarriageReturns(value)) = lCase(RemoveCarriageReturns(currentValue)) THEN
                Response.Write "<option value=""" & RemoveCarriageReturns(value) & """ selected=""selected"">" & RemoveCarriageReturns(value) & "</option>"
            ELSE
                Response.Write "<option value=""" & RemoveCarriageReturns(value) & """>" & RemoveCarriageReturns(value) & "</option>"
            END IF
        NEXT
    END IF
    Response.Write "</select></li>"
END SUB

SUB BuildFieldSelectElement2(name, valueList, currentValue, defaultValue)
    kendoSelectList = kendoSelectList & "flex_" & name & ","
    Response.Write "<li><select name=""flex_" & name & """ id=""flex_" & name & """ style=""min-width:82px"">"
    Response.Write "<option value="""">---</option>"
    IF IsArray(valueList) THEN
        FOR EACH value IN valueList
            IF RemoveCarriageReturns(CheckForNull(currentValue)) = "" THEN currentValue = defaultValue

            IF lCase(RemoveCarriageReturns(value)) = lCase(RemoveCarriageReturns(currentValue)) THEN
                Response.Write "<option value=""" & RemoveCarriageReturns(value) & """ selected=""selected"">" & RemoveCarriageReturns(value) & "</option>"
            ELSE
                Response.Write "<option value=""" & RemoveCarriageReturns(value) & """>" & RemoveCarriageReturns(value) & "</option>"
            END IF
        NEXT
    END IF
    Response.Write "</select></li>"
END SUB

SUB BuildFieldSelectElement3(name, valueList, currentValue, defaultValue)
    kendoSelectList = kendoSelectList & "flex_" & name & ","
    Response.Write "<td><select name=""flex_" & name & """ id=""flex_" & name & """ style=""min-width:82px"">"
    Response.Write "<option value="""">---</option>"
    IF IsArray(valueList) THEN
        FOR EACH value IN valueList
            IF RemoveCarriageReturns(CheckForNull(currentValue)) = "" THEN currentValue = defaultValue

            IF lCase(RemoveCarriageReturns(value)) = lCase(RemoveCarriageReturns(currentValue)) THEN
                Response.Write "<option value=""" & RemoveCarriageReturns(value) & """ selected=""selected"">" & RemoveCarriageReturns(value) & "</option>"
            ELSE
                Response.Write "<option value=""" & RemoveCarriageReturns(value) & """>" & RemoveCarriageReturns(value) & "</option>"
            END IF
        NEXT
    END IF
    Response.Write "</select></td>"
END SUB
%>