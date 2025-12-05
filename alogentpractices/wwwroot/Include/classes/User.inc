<%
Class User
    Private m_id
    Private m_login
    Private m_name
    Private m_email
    Private m_allowEmailSending
    Private m_security

    Public Property Let Id(value)
        m_id = value
    End Property
    Public Property Get Id()
        Id = m_id
    End Property

    Public Property Let Login(value)
        m_login = value
    End Property
    Public Property Get Login()
        Login = m_login
    End Property
    
    Public Property Let Name(value)
        m_name = value
    End Property
    Public Property Get Name()
        Name = m_name
    End Property

     Public Property Get Email
        Email = m_email
    End Property
    Public Property Let Email(value)
        m_email = value
    End Property
    
    Public Property Get AllowEmailSending
        AllowEmailSending = m_allowEmailSending
    End Property
    Public Property Let AllowEmailSending(value)
        m_allowEmailSending = value
    End Property

    Public Property Let Security(value)
        Set m_security = value
    End Property
    Public Property Get Security
        Set Security = m_security
    End Property
End Class
%>