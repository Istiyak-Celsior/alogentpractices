<%
Class UserSecurity
    Private m_isInactive
    Private m_isSuperUser
    Private m_hasEmployeeFileAccess
    Private m_accountSecurityList
    Private m_permissionList
    Private m_branchSecurity

    ' Default Constructor
    Public Sub Class_Initialize
        ' Perform any default initializations
        m_accountSecurityList   = Array()
        m_permissionList        = Array()
        Set m_branchSecurity    = new UserBranchSecurity
    End Sub

    Public Property Let IsInactive(value)
        m_isInactive = value
    End Property
    Public Property Get IsInactive()
        IsInactive = m_isInactive
    End Property

    Public Property Let IsSuperUser(value)
        m_isSuperUser = value
    End Property
    Public Property Get IsSuperUser()
        IsSuperUser = m_isSuperUser
    End Property

    Public Property Let HasEmployeeFileAccess(value)
        m_hasEmployeeFileAccess = value
    End Property
    Public Property Get HasEmployeeFileAccess()
        HasEmployeeFileAccess = IsSuperUser Or m_hasEmployeeFileAccess
    End Property

    Public Property Get AccountSecurityList
        AccountSecurityList = m_accountSecurityList
    End Property
    Public Property Let AccountSecurityList(Value)
        m_accountSecurityList = Value
    End Property

    Public Property Get PermissionList
        PermissionList = m_permissionList
    End Property
    Public Property Let PermissionList(Value)
        m_permissionList = Value
    End Property

    Public Property Get BranchSecurity
        Set BranchSecurity = m_branchSecurity
    End Property
    Public Property Set BranchSecurity(value)
        Set m_branchSecurity = value
    End Property

    Public Property Get UserAccountSecurityByAccountClass(classCode)
        Dim i
        Dim accountSecurity

        For i = LBound(m_accountSecurityList) To UBound(m_accountSecurityList)
            Set accountSecurity = m_accountSecurityList(i)
            If accountSecurity.AccountClassCode = LCase(classCode) Then
                Exit For
            End If
        Next

        Set UserAccountSecurityByAccountClass = accountSecurity
    End Property

    Public Property Get HasPermission(permissionReource, permissionName)
        Dim i
        Dim permission
        Dim result : result = False

        For i = LBound(m_permissionList) To UBound(m_permissionList)
            Set permission = m_permissionList(i)
            If permission.Resource = permissionReource And permission.Name = permissionName Then
                result = permission.PermissionType
                Exit For
            End If
        Next

        HasPermission = result
    End Property

    Public Property Get HasDocumentViewAccess(accountClassCode, branchId, hasDocumentAccess, isEmployeeCustomerFile, hasDemographicData)
        Dim result : Set result = New UserDocumentViewAccess

        result.HasAccess = True
        result.Reason    = ""

        ' TODO: implement security logic to determine access
        '
        Dim accountSecurity : Set accountSecurity = Me.UserAccountSecurityByAccountClass(accountClassCode)
        Dim hasBranchAccess : hasBranchAccess     = Me.BranchSecurity.HasAccess(branchId)

        If Me.IsSuperUser Then
            result.HasAccess = True
        ElseIf accountSecurity.AllowDocRead Then
            result.HasAccess = True

            ' ### Process security from general to specific settings
            '
            If Not hasBranchAccess Then
                result.HasAccess = False
                result.Reason    = "Branch Access Denied"
            ElseIf Not hasDocumentAccess Then
                result.HasAccess = False
                result.Reason    = "Document Access Denied"
            ElseIf isEmployeeCustomerFile And Not Me.HasEmployeeFileAccess Then
                result.HasAccess = False
                result.Reason    = "Employee Access Denied"
            ElseIf hasDemographicData And (Me.HasPermission(RESOURCE_DOCUMENT, RESOURCE_DOCUMENT_NAME_DEMOGRAPHIC) = PERMISSION_TYPE_DENY) THEN
                result.HasAccess = False
                result.Reason    = "Demographic Data Access Denied"
            End If
        Else
            result.HasAccess = False
            result.Reason    = "Document Access Denied"
        End If

        Set HasDocumentViewAccess = result
    End Property

    Public Property Get AllowAnyDocumentScanAccess
       Dim result : result = False
       Dim i

       For i = LBound(m_accountSecurityList) TO UBound(m_accountSecurityList)
           result = result Or m_accountSecurityList(i).AllowDocScan
       Next

       AllowAnyDocumentScanAccess = result
    End Property

    Public Property Get AllowAnyAdminAccess
       Dim result : result = False
       Dim i

       For i = LBound(m_accountSecurityList) TO UBound(m_accountSecurityList)
           result = result Or m_accountSecurityList(i).IsAdmin
       Next

       AllowAnyAdminAccess = result
    End Property

    Public Property Get AllowBranchAccess(branchId)
        AllowBranchAccess = Me.IsSuperUser Or Me.BranchSecurity.HasAccess(branchId)
    End Property

    Public Property Get AllowEmployeeFileAccess(isEmployeeCustomerFile)
        AllowEmployeeFileAccess = Me.IsSuperUser OR (Not isEmployeeCustomerFile OR (Me.HasEmployeeFileAccess And isEmployeeCustomerFile))
    End Property
End Class
%>