var NoticeLetterSetExceptionPolicyModel = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, this);

            if (model != null) {
                this.set("id", model.id);
                this.set("name", model.name);
                this.set("type", model.type);
                this.set("accountClass", model.accountClass);
                this.set("accountType", model.accountType);
                this.set("documentType", model.documentType);
            }
        },
        id: null,
        name: null,
        type: null,
        accountClass: null,
        accountType: null,
        documentType: null,
        selected: false
    });

})(window.kendo.jQuery, window.kendo);