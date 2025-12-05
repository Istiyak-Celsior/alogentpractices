<%
CONST FDG_ID = 0
CONST FDG_NAME = 1
CONST FDG_LABEL = 2
CONST FDG_ORDER = 3
CONST FDG_IS_COLLATERAL = 4
CONST FDG_ACCOUNT_CLASS_ID = 5

Dim gfdg
Dim g_fieldDefGroupRS : Set g_fieldDefGroupRS = Server.CreateObject("ADODB.RecordSet")

' ### Get Credit field groups ###
Dim g_fieldDefGroupQuery : g_fieldDefGroupQuery = _
    " SELECT" & _
    "   fieldDefGroupId," & _
    "   fieldDefGroupName," & _
    "   fieldDefGroupLabel," & _
    "   isNull(fieldDefGroupOrder,0) AS fieldDefGroupOrder," & _
    "   fieldDefGroupIsCollateral," & _
    "   accountClassId" & _
    " FROM" & _
    "   fieldDefGroup" & _
    " WHERE" & _
    "   accountClassId IS NULL" & _
    " ORDER BY" & _
    "   fieldDefGroupOrder," & _
    "   fieldDefGroupLabel"
g_fieldDefGroupRS.Open g_fieldDefGroupQuery, db, adOpenForwardOnly, adLockReadOnly

Dim g_creditFieldGroupCount : g_creditFieldGroupCount = 0
IF NOT g_fieldDefGroupRS.EOF THEN
    Dim g_creditFieldGroupList : g_creditFieldGroupList = g_fieldDefGroupRS.GetRows()
    IF isArray(g_creditFieldGroupList) THEN
        FOR gfdg = 0 TO uBound(g_creditFieldGroupList, 2)
            g_creditFieldGroupCount = g_creditFieldGroupCount + 1
        NEXT
    END IF
ELSE
    g_creditFieldGroupCount = -1
END IF
g_fieldDefGroupRS.Close

' ### Get Account field groups ###
g_fieldDefGroupQuery = _
    " SELECT" & _
    "   fieldDefGroupId," & _
    "   fieldDefGroupName," & _
    "   fieldDefGroupLabel," & _
    "   isNull(fieldDefGroupOrder,0) AS fieldDefGroupOrder," & _
    "   fieldDefGroupIsCollateral," & _
    "   accountClassId" & _
    " FROM" & _
    "   fieldDefGroup" & _
    " WHERE" & _
    "   accountClassId IS NOT NULL" & _
    "   AND fieldDefGroupIsCollateral=0" & _
    " ORDER BY" & _
    "   fieldDefGroupOrder," & _
    "   fieldDefGroupLabel"
g_fieldDefGroupRS.Open g_fieldDefGroupQuery, db, adOpenForwardOnly, adLockReadOnly
Dim g_accountFieldGroupCount : g_accountFieldGroupCount = 0
IF NOT g_fieldDefGroupRS.EOF THEN
	Dim g_accountFieldGroupList : g_accountFieldGroupList = g_fieldDefGroupRS.GetRows()
    IF isArray(g_accountFieldGroupList) THEN
        FOR gfdg = 0 TO uBound(g_accountFieldGroupList, 2)
            g_accountFieldGroupCount = g_accountFieldGroupCount + 1
        NEXT
    END IF
ELSE
    g_accountFieldGroupCount = -1
END IF
g_fieldDefGroupRS.Close

' ### Get Collateral field groups ###
g_fieldDefGroupQuery = _
    " SELECT" & _
    "   fieldDefGroupId," & _
    "   fieldDefGroupName," & _
    "   fieldDefGroupLabel," & _
    "   isNull(fieldDefGroupOrder,0) AS fieldDefGroupOrder," & _
    "   fieldDefGroupIsCollateral," & _
    "   accountClassId" & _
    " FROM" & _
    "   fieldDefGroup" & _
    " WHERE" & _
    "   accountClassId IS NOT NULL" & _
    "   AND fieldDefGroupIsCollateral=1" & _
    " ORDER BY" & _
    "   fieldDefGroupOrder," & _
    "   fieldDefGroupLabel"
g_fieldDefGroupRS.Open g_fieldDefGroupQuery, db, adOpenForwardOnly, adLockReadOnly
Dim g_collateralFieldGroupCount : g_collateralFieldGroupCount = 0
IF NOT g_fieldDefGroupRS.EOF THEN
    Dim g_collateralFieldGroupList : g_collateralFieldGroupList = g_fieldDefGroupRS.GetRows()
    IF isArray(g_collateralFieldGroupList) THEN
        FOR gfdg = 0 TO uBound(g_collateralFieldGroupList, 2)
            g_collateralFieldGroupCount = g_collateralFieldGroupCount + 1
        NEXT
    END IF
ELSE
    g_collateralFieldGroupCount = -1
END IF
g_fieldDefGroupRS.Close

FUNCTION GetFieldDefGroup_FieldValue(groupId, field)
    Dim i
    Dim list : list = g_creditFieldGroupList
    Dim count : count = g_creditFieldGroupCount

    FOR i = 0 TO count - 1
        IF list(FDG_ID,i) = CheckForNull(groupId) THEN
            GetFieldDefGroup_FieldValue = list(field,i)
        END IF
    NEXT

    list = g_accountFieldGroupList
    count = g_accountFieldGroupCount
    FOR i = 0 TO count - 1
        IF list(FDG_ID,i) = CheckForNull(groupId) THEN
            GetFieldDefGroup_FieldValue = list(field,i)
        END IF
    NEXT

    list = g_collateralFieldGroupList
    count = g_collateralFieldGroupCount
    FOR i = 0 TO count - 1
        IF list(FDG_ID,i) = CheckForNull(groupId) THEN
            GetFieldDefGroup_FieldValue = list(field,i)
        END IF
    NEXT
END FUNCTION

FUNCTION HasCollateralFieldGroup(accountClassId)
    Dim i
    Dim hasGroup : hasGroup = false

    FOR i = 0 TO g_collateralFieldGroupCount - 1
        IF g_collateralFieldGroupList(FDG_ACCOUNT_CLASS_ID, i) = CheckForNull(accountClassId) THEN
            hasGroup = true
            EXIT FOR
        END IF
    NEXT
    HasCollateralFieldGroup = hasGroup
END FUNCTION
%>