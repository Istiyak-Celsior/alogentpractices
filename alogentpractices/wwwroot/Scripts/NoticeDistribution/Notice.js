var Notice = (function($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, model);

            this.set("exceptionDate", new Date(model.exceptionDate));
        }
    });

})(window.kendo.jQuery, window.kendo);