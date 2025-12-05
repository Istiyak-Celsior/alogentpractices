var MultiFilterViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, field) {
            ViewModel.fn.init.call(this);

            this.name = name;
            this.field = field;
        },
        add: function (value) {
            this.items.push(kendo.observable({
                 value: value
            }));
        },
        field: undefined,
        items: [],
        name: undefined,
        type: "Multi"
    });
})(window.kendo.jQuery);