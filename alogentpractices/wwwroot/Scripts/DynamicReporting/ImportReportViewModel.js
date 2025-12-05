var ImportReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;
        },
        user: undefined,
        canUpload: function() {
            return this.get("name").length > 0;
        },
        onError: function(e) {
            var errors = this.get("errors");

            errors.splice(0, errors.length);

            var error = JSON.parse(e.XMLHttpRequest.response);

            errors.push(error.ErrorMessage);

            this.set("hasError", true);
        },
        onSuccess: function(e) {
            var errors = this.get("errors");

            errors.splice(0, errors.length);

            if (!e.response.Success) {
                $.each(e.response.Errors, function(i, error) {
                    errors.push(error);
                });

                this.set("hasError", true);
            } 
            else {
                this.set("hasError", false);
                this.trigger("upload");
            }
        },
        onUpload: function(e) {
            var that = this;
            var xhr  = e.XMLHttpRequest;

            xhr.addEventListener("readystatechange", function(e) {
                if (xhr.readyState === 1 /* OPENED */) {
                    xhr.setRequestHeader("x-accuaccount-username", that.user);
                    xhr.setRequestHeader("x-accuaccount-reportname", that.name);
                }
            });
        },
        errors: [],
        hasError: false,
        name: ""
    });
})(window.kendo.jQuery);