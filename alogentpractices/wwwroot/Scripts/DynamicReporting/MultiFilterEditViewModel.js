var MultiFilterEditViewModel = (function ($, undefined) {
    return MultiFilterViewModel.extend({
        init: function (name, field) {
            MultiFilterViewModel.fn.init.call(this, name, field);
        },
        add: function (value) {
            this.items.push(kendo.observable({
                value: value,
                isSelected: false
            }));
        },
        limit: 500,
        exceedsLimit: function () {
            return this.get("items").length >= this.limit;
        },
        isBusy: false,
        selectValue: function (value) {
            $.each(this.items, function (i, item) {
                if (item.value === value) {
                    item.set("isSelected", true);
                    return false;
                }
            });
        }
    });
})(window.kendo.jQuery);