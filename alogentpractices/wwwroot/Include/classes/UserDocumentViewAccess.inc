<%
Class UserDocumentViewAccess
    Private m_hasAccess
    Private m_reason

    Public Property Get HasAccess
        HasAccess = m_hasAccess
    End Property
    Public Property Let HasAccess(value)
        m_hasAccess = value
    End Property

    Public Property Get Reason
        Reason = m_reason
    End Property
    Public Property Let Reason(value)
        m_reason = value
    End Property
End Class    
%>