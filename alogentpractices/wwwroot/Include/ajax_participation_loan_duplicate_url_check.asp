<% OPTION EXPLICIT %>
<!-- #include file="adovbs.inc" -->
<!-- #include file="dbopen.inc" -->
<!-- #include file="common.inc" -->
<!-- #include file="security.inc" -->
<%
Dim pstrOut : pstrOut = 0
Dim passedUrl : passedUrl = RemoveTrailingSlash(Request("passedUrl")) & "/services/loan/participation/document"
Dim passedGuid : passedGuid = Request("passedGuid")

IF Trim(passedUrl & "") <> "" THEN
    Dim bankAffiliateUrlCheckRS : Set bankAffiliateUrlCheckRS = Server.CreateObject("ADODB.RecordSet")
    Dim bankAffiliateUrlCheckQuery : bankAffiliateUrlCheckQuery = _
        "SELECT COUNT(participationBankId) AS numberOfBanks" & _
        " FROM participationBank" & _
        " WHERE affiliateUrl = " & dbFormatText(passedUrl)
    IF Trim(passedGuid & "") <> "" THEN
        bankAffiliateUrlCheckQuery = bankAffiliateUrlCheckQuery & " AND participationBankId <> " & dbFormatId(passedGuid)
    END IF
    bankAffiliateUrlCheckRS.Open bankAffiliateUrlCheckQuery, db, adOpenStatic, adCmdText
    IF NOT bankAffiliateUrlCheckRS.EOF THEN
        pstrOut = bankAffiliateUrlCheckRS("numberOfBanks")
    END IF
    bankAffiliateUrlCheckRS.Close()
END IF
%>
<!-- #include file="dbclose.inc" -->
<%
Response.Write pstrOut
%>