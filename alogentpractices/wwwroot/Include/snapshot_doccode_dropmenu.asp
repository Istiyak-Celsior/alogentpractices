<% OPTION EXPLICIT %>
<!-- #include file="adovbs.inc" -->
<!-- #include file="dbopen.inc" -->
<!-- #include file="common.inc" -->
<!-- #include file="security.inc" -->
<%
Dim pstrOut : pstrOut = ""
Dim selectedCode : selectedCode = Request("selectedCode")
IF Trim(selectedCode & "") <> "" THEN selectedCode = cStr(selectedCode)
Dim selectedLoanTypeId : selectedLoanTypeId = Request("selectedLoanTypeId")

pstrOut = "<select name=""snapshotDocumentCode"" id=""aa-snapshot-document-code"">" & vbCr _
        & "<option value="""">Select Document Tab</option>" & vbcr
Dim documentCodeRS : Set documentCodeRS = Server.CreateObject("ADODB.RecordSet")
Dim documentCodeQuery : documentCodeQuery = _
	"SELECT documentcode, documentTypeName, documentSubTypeName" & _
    " FROM qryDocumentDefinitions" & _
    " WHERE loanTypeId = " & dbFormatId(selectedLoanTypeId) & _
    " ORDER BY sortOrder, documentSubTypeName"
documentCodeRS.Open documentCodeQuery, db, adOpenStatic, adCmdText
DO UNTIL documentCodeRS.EOF
    IF cStr(documentCodeRS("documentcode")) = selectedCode THEN
        pstrOut = pstrOut & "<option value=""" & documentCodeRS("documentcode") & """ selected=""selected"">" & Server.HTMLEncode(documentCodeRS("documentSubTypeName")) & "</option>" & vbCr
    ELSE
        pstrOut = pstrOut & "<option value=""" & documentCodeRS("documentcode") & """>" & documentCodeRS("documentTypeName") & " - " & Server.HTMLEncode(documentCodeRS("documentSubTypeName")) & "</option>" & vbCr
    END IF
    documentCodeRS.MoveNext()
LOOP
documentCodeRS.Close()
pstrOut = pstrOut & "</select>"
%>							
<!-- #include file="dbclose.inc" -->
<%
Response.Write pstrOut
%>