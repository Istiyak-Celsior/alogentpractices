var NoticeLetterTemplateExceptionPolicy = (function($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function(model) {
            kendo.data.ObservableObject.fn.init.call(this, this);

            if (model != null) {
                this.set("id", model.id);
                this.set("type", model.type);
                this.set("accountClass", model.accountClass);
                this.set("accountType", model.accountType);
                this.set("name", model.name);
                this.set("daysBeforeNext", 0);
                this.set("override", false);

                this.set("editDaysBeforeNext", 0);
                this.set("editOverride", false);
            }
        },
        enableExceptionPolicyOverride: function() {
            this.set("editOverride", true);
        },
        disableExceptionPolicyOverride: function() {
            this.set("editOverride", false);
        }

    })

})(window.kendo.jQuery, window.kendo);