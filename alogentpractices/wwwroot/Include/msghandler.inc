<%
Dim msgFlag : msgFlag = Session("msgFlag")
Dim errFlag : errFlag = Session("errFlag")
Dim msg : msg = Session("msg")
Dim errMsg : errMsg = Session("errMsg")

' ### Handle any user messages ###
IF msgFlag THEN
    Response.Write "<div class=""aa-alert aa-color-info aa-background-info""><i class=""fas fa-info-circle"" aria-hidden=""true""></i>&nbsp;&nbsp;" & uCase(msg) & "</div>" & vbCr
    Session("msgFlag") = False
    Session("msg") = ""
END IF
IF errFlag THEN
    Response.Write "<div class=""aa-alert aa-color-danger aa-background-danger""><i class=""fas fa-ban"" aria-hidden=""true""></i>&nbsp;&nbsp;" & uCase(errMsg) & "</div>" & vbCr
    Session("errFlag") = false
    Session("errMsg") = ""
END IF
%>