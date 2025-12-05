<ul id="nav">
    <li><a href="dashboard.asp" class="menu" id="mmenu0">Dashboard</a></li>
    <li><a href="home.asp" target="_self" class="menu" id="mmenu1" onmouseover="mopen(1);" onmouseout="mclosetime();">Search</a>
        <div class="submenu" id="menu1" onmouseover="mcancelclosetime()" onmouseout="mclosetime();">
            <% IF Session("accuaccount.enableExpress") <> 1 THEN %><a href="searchq1.asp?searchType=Exception">Exceptions</a><% END IF %>
            <a href="searchq1.asp?searchType=Existing">Existing Documents</a>
            <a href="searchq1.asp?searchType=Expired">Expired Documents</a>
            <a href="searchq1.asp?searchType=Missing">Missing Documents</a>
            <a href="searchq1.asp?searchType=Waived">Waived Documents</a>
        </div>
    </li>
    <li><a href="#" class="menu" id="mmenu2" onmouseover="mopen(2);" onmouseout="mclosetime();">User</a>
        <div class="submenu" id="menu2" onmouseover="mcancelclosetime()" onmouseout="mclosetime();">
            <a href="user_barcode_cover_sheet.asp" target="_blank">Print User Barcode Covers</a>
        </div>
    </li>
    <li><a href="#" class="menu" id="mmenu3" onmouseover="mopen(3);" onmouseout="mclosetime();">Reporting</a>
        <div class="submenu" id="menu3" onmouseover="mcancelclosetime()" onmouseout="mclosetime();">
            <a href="dynamicreporting.asp">My Reports</a>
            <a href="exceptionreports.asp?mode=checklist">Checklists</a>
            <a href="exceptionreports.asp?mode=classifiedaccounts">Classified Accounts</a>
            <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
            <a href="exceptionreports.asp?mode=crosscollaterals">Cross Collaterals</a>
            <a href="exceptionreports.asp">Exception Reports</a>
            <% END IF %>
            <a href="exceptionreports.asp?mode=expiringdocuments">Expiring Documents</a>
            <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
            <a href="exceptionreports.asp?mode=accountapplications">Account Applications</a>
            <a href="exceptionreports.asp?mode=policyexceptions">Policy Exceptions</a>
            <a href="exceptionreports.asp?mode=relatedentities">Related Entities</a>
            <% END IF %>
            <% IF Session("acculoan.showParticipationLoan") = 1 THEN %>
            <a href="exceptionreports.asp?mode=participations">Participation Loans</a>
            <% END IF %>
            <a href="sh_search.asp?action=SCAN">Document History</a>
            <% IF Session("accuaccount.disableImaging") = "0" THEN %>
            <a href="sh_search.asp?action=VIEW">Documents Viewed</a>
            <% END IF %>
        </div>
    </li>
    <% 
        IF Session("credit.allowAdd") OR Session("credit.isAdmin") OR Session("isSuperUser") THEN
            IF Session("isSuperUser") OR Session("UseBranchSecurity") = "N" OR (Session("UseBranchSecurity") = "Y" AND branchAccessCount > 0) THEN
    %>
    <li><a href="customermaintadd.asp?state=INITIAL&action=ADD" class="menu" id="mmenu4">Add Customer</a></li>
    <%      ELSE %>
    <li><a href="javascript:void(0);" class="menu" id="mmenu4" style="cursor:default;"><span title="Cannot add Customers because you do not have access to any Branches">Add Customer</span></a></li>
    <%      END IF %>
    <%  END IF %>
    <% IF Session("accuaccount.disableImaging") = "0" AND (Session("isSuperUser") OR (Session("AccuAccount.Audit::Manage") & "" = "0"))  THEN %>
    <li><a href="auditlist.asp" class="menu" id="mmenu5">Audit</a></li>
    <% END IF %>
    <% IF Session("accuaccount.enableExpress") <> 1 THEN %>
    <li><a href="#" class="menu" id="mmenu6" onmouseover="mopen(6);" onmouseout="mclosetime();">Exceptions</a>
        <div class="submenu" id="menu6" onmouseover="mcancelclosetime()" onmouseout="mclosetime();">
            <a href="exceptionbankselection.asp">Exception Maintenance</a>
            <a href="PolicyMaintenance.asp">Policy Exception Maintenance</a>
            <a href="taskgrouplist.asp">Task List Maintenance</a>
            <a href="contactMaint.asp">Contacts Maintenance</a>
            <a href="contactTypeMaint.asp">Contact Types Maintenance</a>
        </div>
    </li>
    <% END IF %>
    <% IF Session("accuaccount.enableExpress") <> 1 AND Session("accuaccount.enableNotices") = 1 AND (Session("isSuperUser") OR Session("AccuAccount.Notice::Manage") & "" = "0" OR Session("AccuAccount.Notice::Distribute") & "" = "0") THEN %>
    <li><a href="#" class="menu" id="mmenu7" onmouseover="mopen(7);" onmouseout="mclosetime();">Notices</a>
        <div class="submenu" id="menu7" onmouseover="mcancelclosetime()" onmouseout="mclosetime();">
    <% IF Session("isSuperUser") OR Session("AccuAccount.Notice::Manage") & "" = "0" THEN %>
            <a href="noticeadmin.asp">Notice Administration</a>
    <% END IF %>
    <% IF Session("isSuperUser") OR Session("AccuAccount.Notice::Distribute") & "" = "0" THEN %>
            <a href="noticedistribution.asp">Notice Distribution</a>
    <% END IF %>
        </div>
    </li>
    <% END IF %>
    <li><a href="adminlist.asp" class="menu" id="mmenu8">Admin</a></li>
    <li><a href="logoff.asp" class="menu" id="mmenu19">Sign Out</a></li>
</ul>