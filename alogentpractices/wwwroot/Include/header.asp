<%
Dim headerBranchQuery, branchAccessCount
Dim headerBranchRS : Set headerBranchRS = Server.CreateObject("ADODB.Recordset")

' ### If Branch Security is Turned on then Only Generate the Branches that are Assigned to the Signed on User ###
branchAccessCount = 0
IF Session("bankSecurity") = "XX" OR Session("isSuperUser") THEN
    branchAccessCount = 1
ELSEIF (Session("bankSecurity") = "DO" OR Session("bankSecurity") = "DU") AND NOT Session("isSuperUser") THEN
    headerBranchQuery = _
        " SELECT COUNT(br.branchId) AS branchCount" & _
        " FROM" & _
        "   branch AS br INNER JOIN bank AS b" & _
        "       ON b.bankId = br.bankId" & _
        "   LEFT OUTER JOIN region AS reg" & _
        "       ON reg.regionId = br.regionId" & _
        "   WHERE br.branchId IN" & _
        "       (SELECT branchId FROM viewUserBranchSecurity WHERE userId = " & dbFormatId(Session("userId")) & ") "
    headerBranchRS.open headerBranchQuery, db
    IF NOT headerBranchRS.EOF THEN
        branchAccessCount = headerBranchRS("branchCount")
    END IF
    headerBranchRS.Close
END IF
%>
<div id="aa-header-logo-container">
    <a href="dashboard.asp" title="Go to the dashboard" id="pageTop"><img src="Content/Images/Nav/Logo.png" alt="AccuSystems Logo"/></a>
</div>
<nav>
    <div>
        <% IF IsAdministrator THEN %>
        <!-- #include file="menu_items_su.asp" -->
        <% ELSEIF IsReader THEN %>
        <!-- #include file="menu_items_user.asp" -->
        <% END IF %>
    </div>
        <div id="head-search-wrapper">
            <div class="aa-icon-block" id="cog"><i class="fas fa-cog fa-fw" title="Change User Password" id="header-config" aria-hidden="true"></i></div>
            <div id="notification-no-count"><i class="fas fa-bell fa-fw" aria-hidden="true"></i></div>
            <div id="notification-count">0</div>
            <div id="notification-user-wrapper"><%=Session("userName")%></div>
        </div>
</nav>