<%
'-------------------------------------------------------------------------
' Manages a dictionary of boolean valuess by branchId key indicating
' access to the branch.
'-------------------------------------------------------------------------
Class UserBranchSecurity
    Private m_branchSecurity

    ' Default Constructor
    Public Sub Class_Initialize
        ' Perform any default initializations
        Set m_branchSecurity    = Server.CreateObject("Scripting.Dictionary")
    End Sub

    Public Sub AddBranchAccess(branchId, hasAccess)
        If Not m_branchSecurity.Exists(branchId) Then
            m_branchSecurity.Add branchId, CBool(hasAccess)
        End If
    End Sub

    Public Function HasAccess(branchId)
        Dim result : result = False
        If m_branchSecurity.Exists(branchId) Then
            result = m_branchSecurity.Item(branchId)
        End If

        HasAccess = result
    End Function
End Class   

%>