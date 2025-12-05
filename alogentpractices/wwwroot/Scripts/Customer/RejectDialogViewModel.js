var RejectDialogViewModel = (function ($, undefined) {
    return kendo.mvvm.DialogViewModel.extend({
        init: function (documentService, document, username, userEmail, userCanSendMail) {
            kendo.mvvm.DialogViewModel.fn.init.call(this);

            this._documentService = documentService;
            this.document         = document;
            this.username         = username;
            this.userEmail        = userEmail;
            this.userCanSendMail  = userCanSendMail;
            this.title            = "Reject " + document.title;
        },
        author: undefined,
        authorEmail: undefined,
        cancel: function () {
            this.triggerClose(true, false);
        },
        cannotNotifyTitle: function() {
            if (!this.get("userCanSendMail")) {
                return "You do not have permission to send mail.";
            }

            if (!this.get("userEmail")) {
                return "You do not have an email address configured.";
            }

            if (!this.get("authorEmail")) {
                return "The author does not have an email address configured.";
            }
        },
        canNotifyAuthor: function() {
            var userCanSendMail = this.get("userCanSendMail");

            if (!userCanSendMail) {
                return false;
            }

            var authorEmail = this.get("authorEmail");
            var userEmail   = this.get("userEmail");

            if (!userEmail || !authorEmail) {
                return false;
            }

            return true;
        },
        canReject: function() {
            return this.get("isBusy") === false && !this.get("error");
        },
        changeDate: undefined,
        comment: undefined,
        error: null,
        isBusy: false,
        notifyAuthor: false,
        onRejectFail: function(e) {
            this.set("error", {
                 errorMessage: e.responseJSON.ErrorMessage, 
                 errors: e.responseJSON.Errors, 
                 reason: "The document could not be rejected because a problem occurred."
            });

            throw "Reject failed";
        },
        onNotificationFail: function(e) {
            var that = this;

            that.set("error", {
                errorMessage: e.responseJSON.ErrorMessage, 
                errors: e.responseJSON.Errors, 
                reason: kendo.format("The document was rejected, but {0} could not be notified because a problem occurred.", that.author)
            });

            throw "Notification failed";
        },
        reject: function () {
            this.set("isBusy", true);

            var promise = this.document.reject(this.username, this.comment);
            var that    = this;

            promise.then(null, that.onRejectFail.bind(that))
                        .then(function() {
                            if (that.notifyAuthor) {
                                return that._documentService
                                           .rejectNotification(that.document.id, that.document.latestChangeId, that.username)
                                           .then(null, that.onNotificationFail.bind(that));
                            }
                        })
                        .then(function() {
                            that.triggerClose(true, true);
                        })
                        .always(function() {
                            that.set("isBusy", false);
                        });
        },
        title: undefined,
        userCanSendMail: false
    });
})(window.kendo.jQuery);