var ReportTemplateFieldBehaviorViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function() {
            ViewModel.fn.init.call(this);
        },
        isAvailable: false,
        isEnabled: false,
        isSupported: false
    });
})(window.kendo.jQuery);