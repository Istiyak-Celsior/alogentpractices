var ReportTemplateViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, description, isPurchased) {
            ViewModel.fn.init.call(this);

            this.name        = name;
            this.description = description;
            this.isPurchased = isPurchased;
        },
        name: undefined,
        description: undefined,
        isPurchased: undefined
    });
})(window.kendo.jQuery);