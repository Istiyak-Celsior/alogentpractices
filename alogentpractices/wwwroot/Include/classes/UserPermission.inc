<%
CONST RESOURCE_AUDIT                           = "AccuAccount.Audit"
CONST RESOURCE_DOCUMENT                        = "AccuAccount.Document"
CONST RESOURCE_DYNAMIC_REPORTING               = "AccuAccount.DynamicReporting"
CONST RESOURCE_NOTICE                          = "AccuAccount.Notice"

CONST RESOURCE_AUDIT_NAME_MANAGE               = "Manage"
CONST RESOURCE_DOCUMENT_NAME_DEMOGRAPHIC       = "Restrict Demographic Data"
CONST RESOURCE_REPORTING_NAME_CREATE           = "Create"
CONST RESOURCE_REPORTING_NAME_REPORTING_EXPORT = "Export"
CONST RESOURCE_REPORTING_NAME_REPORTING_SHARE  = "Share"
CONST RESOURCE_NOTICE_NAME_MANAGE              = "Manage"
CONST RESOURCE_NOTICE_NAME_DISTRIBUTE          = "Distribute"

CONST PERMISSION_TYPE_ALLOW                    = 0
CONST PERMISSION_TYPE_DENY                     = 1

Class UserPermission
    Private m_name
    Private m_resource
    Private m_description
    Private m_type

    Public Property Let Name(value)
        m_name = value
    End Property
    Public Property Get Name()
        Name = m_name
    End Property   
    
    Public Property Get Resource
        Resource = m_resource
    End Property
    Public Property Let Resource(value)
        m_resource = value
    End Property
    
    Public Property Get Description
        Description = m_description
    End Property
    Public Property Let Description(value)
        m_description = value
    End Property

    Public Property Get PermissionType
        PermissionType = m_type
    End Property
    Public Property Let PermissionType(value)
        m_type = value
    End Property
End Class    
%>