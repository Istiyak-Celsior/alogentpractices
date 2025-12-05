var ReportTemplateFieldViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function(group, name, label, type) {
            ViewModel.fn.init.call(this);

            this.group = group;
            this.name  = name;
            this.label = label;
            this.type  = type;

            this.set("behaviors", new kendo.data.ObservableObject({
                linkBehavior: new ReportTemplateFieldBehaviorViewModel()
            }));
            
            this.bind("change", this._change);
        },
        group: undefined,
        name: undefined,
        label: undefined,
        type: undefined,
        checked: undefined,
        behaviors: undefined,
        _change: function(e) {
            if (e.field === "checked") {
                this.behaviors.linkBehavior.set("isAvailable", this.checked === true && this.behaviors.linkBehavior.isSupported === true);
            }
        }
    });
})(window.kendo.jQuery);