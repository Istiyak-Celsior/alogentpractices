var NotificationListService = (function () {
    var publicApi = {};
   
    publicApi.GetUserNotificationList = function (userId, callback) {
        $.ajax({
            url: 'services/coresvc/getusernotificationlist?userId=' + userId,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    publicApi.GetNotificationCount = function (userId, callback) {        
        $.ajax({
            url: 'services/coresvc/getundismissedusernotificationcount?userId=' + userId,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    }

    publicApi.DismissNotification = function(userNotificationId, callback) {
        $.ajax({
            url: 'services/coresvc/dismissusernotification?userNotificationId=' + userNotificationId,
            method: 'POST',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    }

    publicApi.DismissAllNotifications = function(userId, callback) {
        $.ajax({
            url: 'services/coresvc/dismissallusernotifications?userId=' + userId,
            method: 'POST',
            cache: false
        })
        .done(function(data) {
            callback(data.d);
        });
    }

    return publicApi;
}());