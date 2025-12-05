var CopyReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(manager, service, report, user) {
            ViewModel.fn.init.call(this);

            this.manager           = manager;
            this.service           = service;
            this.report            = report;
            this.user              = user;
            this.report            = report;
        },
        errorMessage: "",
        isBusy: false,
        isValid: function() {
            return this.newReportName.length > 0;
        },
        newReportName: "",
        reportDescription: undefined,
        reportName: undefined,
        reportOwner: undefined,
        user: undefined,
        copy: function() {
            var that    = this;
            var request = that.service.copyReport(that.user, that.report.owner, that.report.name, that.newReportName);

            request.fail(function(e) {
                that.set("errorMessage", e.responseJSON.ErrorMessage);
            });

            return request;
        }
    });
})(window.kendo.jQuery);