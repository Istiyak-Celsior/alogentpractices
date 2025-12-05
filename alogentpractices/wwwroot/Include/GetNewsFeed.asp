<!-- #include file="adovbs.inc" -->
<!-- #include file="dbopen.inc" -->
<!-- #include file="security.inc" -->
<!-- #include file="common.inc" -->
<%
Dim inUrl : inUrl = Session("acculoan.RSSUrl")

ON ERROR RESUME NEXT

Dim httpObject : Set httpObject = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
httpObject.Open "GET", inUrl
httpObject.Send

IF Err.Number = 0 THEN
    IF httpObject.Status = "200" THEN
        Response.Write RebuildXml(httpObject.ResponseText)
    ELSE
        Response.Status = httpObject.Status & " " & httpObject.StatusText
        Response.Write Response.Status
    END IF
ELSE
    Response.Status = "400 Bad Request"
    Response.Write Response.Status
END IF

Set httpObject = Nothing

FUNCTION RebuildXml(strIn)
    IF Trim(strIn & "") = "" THEN EXIT FUNCTION
    Dim strOut : strOut = Replace(strIn, "&apos;", "'")
    strOut = Replace(strOut, "&quot;", CHR(34))
    strOut = Replace(strOut, "&gt;", ">")
    strOut = Replace(strOut, "&lt;", "<")
    strOut = Replace(strOut, "&amp;", "&")
    RebuildXml = strOut
END FUNCTION
%>
<!-- #include file="dbclose.inc" -->