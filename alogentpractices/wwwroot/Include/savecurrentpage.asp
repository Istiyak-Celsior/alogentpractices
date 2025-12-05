<%
    Dim urlPage
    urlPage       = Trim(Request.ServerVariables("URL"))
    
    Dim argList
    argList       = Trim(Request.Querystring)
    
    Dim currentPage
    
    if argList <> "" then
      currentPage = urlPage & "?" & argList
    else
      currentPage = urlPage
    end if
    
    Session("workingPage") = currentPage
    
%>