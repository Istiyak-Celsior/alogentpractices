var NotificationsController = (function() {
    var publicApi = {};
    var service = NotificationListService;

    function displayNotificationList(notificationList) {
        var listContent = '';
        var notificationDate = '';

        $.each(notificationList, function (index, value) {
            notificationDate = formatNotificationDate(value.Date);

            var messageStyle = 'uxNotificationMessage';
            if (index == '0') { messageStyle = 'uxNotificationMessageFirst' };

            listContent += '<div class="' + messageStyle + '" id=Message' + value.UserNotificationId + '>' +
                           '    <table cellpadding="0" cellspacing="0" border="0" class="fw">' +
                           '        <tr>' +
                           '            <td class="uxNotificationMessageTitle">' + value.Title + '</td>' +
                           '            <td class="uxDismissButtonWrapper" rowspan="3" align="center"><a href="javascript:void(0);" class="uxDismissButton" id="Dismiss' + value.UserNotificationId + '" title="Dismiss Notification"><i class="fas fa-times" aria-hidden="true"></i></a></td>' +
                           '        </tr>' +
                           '        <tr>' +
                           '            <td class="uxNotificationMessageBody">' + value.Message + '</td>' +
                           '        </tr>' +
                           '        <tr>' +
                           '            <td class="uxNotificationDate" style="color:#888">' + notificationDate + '</td>' +
                           '        </tr>' +
                           '    </table>' +
                           '</div>';
        });

        if ($('#uxNotificationMessageInnerWrapper').is(':hidden')) {
            $('#uxNotificationMessageInnerWrapper').show();
        }
        $('#uxNotificationMessageInnerWrapper').html(listContent);
        $('#uxNotificationDismissAll').show();
        $('#uxNoNewNotifications').hide();
    }

    function displayNoNewNotifications() {
        $('#uxNotificationDismissAll').hide();
        $('#uxNoNewNotifications').show();
        $('#uxNotificationMessageInnerWrapper').hide();
        $('#uxNotificationMessageWrapper').height('auto');
    }

    function formatNotificationDate(currentDate) {
        var notificationDate = new Date(parseInt(currentDate.substr(6))).toString();
        var bits = notificationDate.split(' ');
        return bits[0] + ' ' + bits[1] + ' ' + bits[2] + ' ' + bits[3];
    }

    function displayNotificationCount(userId, callback) {
        getCount(userId, function(currentCount) {
            if (currentCount == '0') {
                $('#notification-count').html(currentCount);
                $('#notification-count').hide();
                $('#notification-no-count').show();
            } else {
                $('#notification-count').show();
                $('#notification-count').html(currentCount);
                $('#notification-no-count').hide();
            }
            callback();
        });
    }

    function getCount(userId, result) {
        service.GetNotificationCount(userId, function (notificationCount) {
            result(notificationCount);
        });
    }

    $(function () {
        var userId = $('#uxUserId').html();

        displayNotificationCount(userId, function() {});
        moveNotificationList();
        $('#uxNotificationMessageWrapper').mCustomScrollbar({ axis: 'y', theme: 'dark-2' });

        $(document).on('click', '.uxDismissButton', function () {
            var dismissId = this.id;
            var userNotificationId = dismissId.replace('Dismiss', '');

            service.DismissNotification(userNotificationId, function () {
                displayNotificationCount(userId, function () {
                    if ($('#notification-count').html() == '0') {
                        displayNoNewNotifications();
                    } else {
                        service.GetUserNotificationList(userId, function (notificationList) {
                            displayNotificationList(notificationList);
                        });
                    }
                });
            });
        });

        $('#notification-count, #notification-no-count').click(function (e) {
            e.stopPropagation();
            displayNotificationCount(userId, function () {
                if ($('#notification-count').html() == '0') {
                    displayNoNewNotifications();
                } else {
                    service.GetUserNotificationList(userId, function (notificationList) {
                        displayNotificationList(notificationList);
                    });
                }
            });
            $('#uxNotificationMessageHolder').toggle('slide', { direction: 'right' });
        });

        $('#uxDismissAll').click(function () {
            service.DismissAllNotifications(userId, function () {
                displayNotificationCount(userId, function () {
                    displayNoNewNotifications();
                });
            });
        });

        $(document).click(function (e) {
            var container = $('#uxNotificationMessageHolder');

            if (container.has(e.target).length === 0) {
                $('#uxNotificationMessageHolder').hide('slide', { direction: 'right' });
            }
        });

        function moveNotificationList() {
            $('#uxNotificationMessageHolder').css('top', '88px').css('right', '0');
        };

        $(window).on('resize', function() {
            moveNotificationList();
        });
    });

    return publicApi;
}());