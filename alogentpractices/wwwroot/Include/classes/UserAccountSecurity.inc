<%
Class UserAccountSecurity
    Private m_isAdmin
    Private m_accountClassCode
    Private m_allowRead
    Private m_allowEdit
    Private m_allowAdd
    Private m_allowDelete
    Private m_allowDocRead
    Private m_allowDocEdit
    Private m_allowDocAdd
    Private m_allowDocDelete
    Private m_allowDocScan
    Private m_allowDocScanDelete
    Private m_allowDocUpload
    Private m_allowDocMoveCopy
    
    Public Property Let IsAdmin(value)
        m_isAdmin = value
    End Property
    Public Property Get IsAdmin()
        IsAdmin = m_isAdmin
    End Property

    Public Property Let AccountClassCode(value)
        m_accountClassCode = value
    End Property
    Public Property Get AccountClassCode()
        AccountClassCode = m_accountClassCode
    End Property

    Public Property Let AllowRead(value)
        m_allowRead = value
    End Property
    Public Property Get AllowRead()
        AllowRead = m_allowRead
    End Property

    Public Property Let AllowEdit(value)
        m_allowEdit = value
    End Property
    Public Property Get AllowEdit()
        AllowEdit = m_allowEdit
    End Property

    Public Property Let AllowAdd(value)
        m_allowAdd = value
    End Property
    Public Property Get AllowAdd()
        AllowAdd = m_allowAdd
    End Property

    Public Property Let AllowDelete(value)
        m_allowDelete = value
    End Property
    Public Property Get AllowDelete()
        AllowDelete = m_allowDelete
    End Property

    Public Property Let AllowDocRead(value)
        m_allowDocRead = value
    End Property
    Public Property Get AllowDocRead()
        AllowDocRead = m_allowDocRead
    End Property

    Public Property Let AllowDocEdit(value)
        m_allowDocEdit = value
    End Property
    Public Property Get AllowDocEdit()
        AllowDocEdit = m_allowDocEdit
    End Property

    Public Property Let AllowDocAdd(value)
        m_allowDocAdd = value
    End Property
    Public Property Get AllowDocAdd()
        AllowDocAdd = m_allowDocAdd
    End Property

    Public Property Let AllowDocDelete(value)
        m_allowDocDelete = value
    End Property
    Public Property Get AllowDocDelete()
        AllowDocDelete = m_allowDocDelete
    End Property

    Public Property Let AllowDocScan(value)
        m_allowDocScan = value
    End Property
    Public Property Get AllowDocScan()
        AllowDocScan = m_allowDocScan
    End Property

    Public Property Let AllowDocScanDelete(value)
        m_allowDocScanDelete = value
    End Property
    Public Property Get AllowDocScanDelete()
        AllowDocScanDelete = m_allowDocScanDelete
    End Property

    Public Property Let AllowDocUpload(value)
        m_allowDocUpload = value
    End Property
    Public Property Get AllowDocUpload()
        AllowDocUpload = m_allowDocUpload
    End Property                                                

    Public Property Let AllowDocMoveCopy(value)
        m_allowDocMoveCopy = value
    End Property
    Public Property Get AllowDocMoveCopy()
        AllowDocMoveCopy = m_allowDocMoveCopy
    End Property  
End Class    
%>