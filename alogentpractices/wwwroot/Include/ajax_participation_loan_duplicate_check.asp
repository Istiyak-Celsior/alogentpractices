<% OPTION EXPLICIT %>
<!-- #include file="adovbs.inc" -->
<!-- #include file="dbopen.inc" -->
<!-- #include file="common.inc" -->
<!-- #include file="security.inc" -->
<%
Dim pstrOut : pstrOut = 0
Dim passedCode : passedCode = Request("passedCode")
Dim passedGuid : passedGuid = Request("passedGuid")

IF Trim(passedCode & "") <> "" THEN
    Dim bankCodeCheckRS : Set bankCodeCheckRS = Server.CreateObject("ADODB.RecordSet")
    Dim bankCodeCheckQuery : bankCodeCheckQuery = _
        "SELECT COUNT(participationBankId) AS numberOfBanks" & _
        " FROM participationBank" & _
        " WHERE participationBankCode = " & dbFormatText(passedCode)
    IF Trim(passedGuid & "") <> "" THEN
        bankCodeCheckQuery = bankCodeCheckQuery & " AND participationBankId <> " & dbFormatId(passedGuid)
    END IF
    bankCodeCheckRS.Open bankCodeCheckQuery, db, adOpenStatic, adCmdText
    IF NOT bankCodeCheckRS.EOF THEN
        pstrOut = bankCodeCheckRS("numberOfBanks")
    END IF
    bankCodeCheckRS.Close()
END IF
%>
<!-- #include file="dbclose.inc" -->
<%
Response.Write pstrOut
%>