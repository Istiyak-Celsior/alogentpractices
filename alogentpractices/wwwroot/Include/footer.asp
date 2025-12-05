<footer id="pageBottom">AccuAccount <%=Session("acculoan.version")%></footer>
<% IF Session("userName") <> "" THEN %>
<div class="aa-hidden" id="uxUserId"><%=Session("userId")%></div>
<div id="uxNotificationMessageHolder">
    <div id="uxNotificationMessageWrapper">
        <div id="uxNotificationMessageInnerWrapper"></div>
    </div>
    <div id="uxNotificationDismissAll">
        <div><a href="javascript:void(0)" id="uxDismissAll">Dismiss All</a></div>
    </div>
    <div id="uxNoNewNotifications">
        <div>
            <span class="fas fa-bell-slash" id="no-notification-glyph" aria-hidden="true"></span>
            <span id="no-notification-text">No New Notifications</span>
        </div>
    </div>
</div>
<% END IF %>