var ReportTemplateGroupViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, fields) {
            ViewModel.fn.init.call(this);

            this.name   = name;
            this.fields = [];
        },
        name: undefined,
        fields: undefined
    });
})(window.kendo.jQuery);