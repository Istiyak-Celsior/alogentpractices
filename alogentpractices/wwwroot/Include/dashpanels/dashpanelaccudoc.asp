<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<!-- #include file="../base64encode_decode.inc" -->
<% IF Session("strconnAccuDoc") = "" THEN %>
<div class="common">AccuDoc is not accessible at this time. If you find this to be
in error, contact your AccuSystems Administrator.</div>
<%
ELSE
    IF Session("accudoc.userName") = "" THEN AccuDocLogin()
END IF

IF Session("strconnAccuDoc") = "" THEN
    ' ### Do nothing ###
ELSEIF Session("accudoc.userLoginYN") = "N" THEN
    %>
    <div class="common">You do not have permission to access any AccuDoc Systems.</div>
    <%
ELSE
    %>
    <table class="aa-accudoc-dashboard-widget aa-panel-table accudoc">
        <tr class="aa-header">
            <td class="aa-tac">&nbsp;</td>
            <td>System</td>
            <td>Description</td>
        </tr>
        <%
        Dim adocSystemRS : Set adocSystemRS = Server.CreateObject("ADODB.RecordSet")
        Dim adocSystemQuery : adocSystemQuery = _
            " SELECT DISTINCT (s.systemId), s.systemLabel, s.systemName, s.systemDescription" & _
            " FROM" & _
            "   adoc_role AS r INNER JOIN adoc_user_role AS ur ON r.roleId = ur.roleId" & _
            "   INNER JOIN adoc_user AS u  ON ur.userId = u.userId" & _
            "   INNER JOIN adoc_system AS s ON r.systemId = s.systemId" & _
            " WHERE" & _
            "   u.userName=" & dbFormatText(Session("userLogin")) & _
            "   AND (r.permissionReadYN = 'Y' OR r.permissionAdminYN = 'Y' OR r.permissionAddYN = 'Y' OR r.permissionEditYN = 'Y' OR r.permissionDeleteYN = 'Y' OR r.permissionScanYN = 'Y' OR r.permissionUploadYN = 'Y')" & _
            " ORDER BY s.systemLabel"
        adocSystemRS.Open adocSystemQuery, dbAccuDoc, adOpenStatic, adCmdText

        Dim pageRedirect, encryptedArgs
        Dim firstTime : firstTime = true
        Dim i : i = 1
        DO UNTIL adocSystemRS.EOF
            IF firstTime THEN
                pageRedirect = "systemselect.asp?systemId=" & adocSystemRS("systemId")
                firstTime = false
            END IF
            urlArgs = "page=systemselect.asp&systemId=" & adocSystemRS("systemId") & "&l=" & Base64Encode(Session("userLogin"))
            %>
            <tr>
                <td class="aa-tac"><a target="_blank" rel="noopener noreferrer" href="<%=Session("accudoc.serverURL")%>/externalportal.asp?<%=urlArgs%>" class="aa-command-link"><i class="aa-icon fas fa-arrow-right fa-fw" aria-hidden="true" title="Click to login into <%=adocSystemRS("systemLabel")%>"></i></a></td>
                <td><%=adocSystemRS("systemLabel")%></td>
                <td><%=adocSystemRS("systemDescription")%></td>
            </tr>
            <%
            i = i + 1
            adocSystemRS.MoveNext()
        LOOP
        %>
    </table>
    <%
    adocSystemRS.Close
END IF ' ### dbAccuDoc IS NOTHING

FUNCTION AccuDocLogin()
    Dim successfulLogin : successfulLogin = false
    IF Session("enableWindowsSecurityYN") = "Y" THEN
        pwdClause = ""
    ELSE
        pwdClause = " AND (UserPassword = " & dbFormatText(Session("userPassword")) & ")"
    END IF

    Set userRS = Server.CreateObject("ADODB.RecordSet")
    userQuery = _
        " SELECT" & _
        "   u.*," &_
        "   r.*" & _
        " FROM" & _
        "   adoc_user AS u LEFT OUTER JOIN adoc_user_role AS ur" &_
        "       ON u.userId=ur.userId" & _
        "   LEFT OUTER JOIN adoc_role AS r" & _
        "       ON r.roleId=ur.roleId" & _
        " WHERE" & _
        "   userName=" & dbFormatText(Session("userLogin")) & pwdClause
    userRS.Open userQuery, dbAccuDoc, adOpenStatic

    Session("accudoc.userId") = ""
    Session("accudoc.roleId") = ""
    Session("accudoc.userName") = ""
    Session("accudoc.userFirstName") = ""
    Session("accudoc.userLastName") = ""
    Session("accudoc.userScanModule") = ""
    Session("accudoc.userMappedPath") = ""
    Session("accudoc.userEmail") = ""
    Session("accudoc.permissionSuperUserYN") = "N"
    Session("accudoc.permissionAdminYN") = "N"
    Session("accudoc.permissionReadYN") = "N"
    Session("accudoc.permissionAddYN") = "N"
    Session("accudoc.permissionEditYN") = "N"
    Session("accudoc.permissionDeleteYN") = "N"
    Session("accudoc.permissionScanYN") = "N"
    Session("accudoc.permissionUploadYN") = "N"
    Session("accudoc.allDocTypeAccessYN") = "N"
    Session("accudoc.userLoginYN") = "N"

    IF NOT userRS.EOF THEN
        Session("accudoc.userLoginYN") = userRS("userLoginYN")
        IF Session("accudoc.userLoginYN") = "Y" THEN
            Session("accudoc.userId") = userRS("userId")
            Session("accudoc.roleId") = userRS("roleId")
            Session("accudoc.userName") = userRS("userName")
            Session("accudoc.userFirstName") = userRS("userFirstName")
            Session("accudoc.userLastName") = userRS("userLastName")
            Session("accudoc.userScanModule") = userRS("userScanModule")
            Session("accudoc.userMappedPath") = userRS("userMappedPath")
            Session("accudoc.userEmail") = checkForNull(userRS("userEmail"))
            Session("accudoc.permissionSuperUserYN") = userRS("permissionSuperUserYN")
            Session("accudoc.permissionAdminYN") = userRS("permissionAdminYN")
            Session("accudoc.permissionReadYN") = userRS("permissionReadYN")
            Session("accudoc.permissionAddYN") = userRS("permissionAddYN")
            Session("accudoc.permissionEditYN") = userRS("permissionEditYN")
            Session("accudoc.permissionDeleteYN") = userRS("permissionDeleteYN")
            Session("accudoc.permissionScanYN") = userRS("permissionScanYN")
            Session("accudoc.permissionUploadYN") = userRS("permissionUploadYN")
            Session("accudoc.allDocTypeAccessYN") = userRS("allDocTypeAccessYN")
            successfulLogin = true
        END IF
    END IF
    userRS.Close
    AccuDocLogin = successfulLogin
END FUNCTION
%>