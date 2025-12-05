var PendingNotices = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, model);

            if (model.contactName == null) {
                this.set("contactName", "");
            }

            if (model.contactEmail == null) {
                this.set("contactEmail", "");
            }

            if (model.contactAddress == null) {
                this.set("contactAddress", "");
            }
        }
    });

})(window.kendo.jQuery, window.kendo);