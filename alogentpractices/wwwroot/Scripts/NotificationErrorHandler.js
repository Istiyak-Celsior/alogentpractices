var NotificationErrorHandler = (function($, undefined) {
    return ErrorHandler.extend({
        element: undefined,
        notification: undefined,
        init: function(element) {
            ErrorHandler.fn.init.call(this);

            var appendToElement = $(element);

            this.element = appendToElement;

            appendToElement.addClass("notification-error-handler");

            var notificationElement = $("<div></div>")
                .kendoNotification({
                    appendTo: appendToElement,
                    autoHideAfter: 0,
                    button: true,
                    hideOnClick: false
                });

            this.notification = notificationElement.data("kendoNotification");

            notificationElement.appendTo(appendToElement);
        },
        clear: function() {
            var notifications = this.notification.getNotifications();

            notifications.fadeOut(500,
                function() {
                    notifications.remove();
                });
        },
        error: function(error) {
            ErrorHandler.fn.error.call(this, error);
            this.notification.error(error);
        },
        success: function(success) {
            ErrorHandler.fn.success.call(this);
            this.notification.success(success);
        },
        warning: function(warning) {
            ErrorHandler.fn.warning.call(this);
            this.notification.warning(warning);
        }
    });
})(window.kendo.jQuery);