var FilterViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(api, field) {
            ViewModel.fn.init.call(this);

            this.api      = api;
            this.field    = field;
            this.options  = this._options();

            this.set("selectedOption", { value: "Search" });
        },
        isDateRangeSelected: function() {
            return this.get("selectedOption").value === "DateRange";
        },
        isSearchSelected: function() {
            return this.get("selectedOption").value === "Search";
        },
        isMultiSelected: function() {
            return this.get("selectedOption").value === "Multi";
        },
        options: undefined,
        selectedOption: null,
        _options: function() {
            var options = new kendo.data.ObservableArray([
                { name: "Search", value: "Search" },
                { name: "Multi-select List", value: "Multi" }
            ]);

            if (this.field.type === "DateTime") {
                options.push({ name: "Date Range", value: "DateRange" });
            }

            return options;
        }
    });
})(window.kendo.jQuery);