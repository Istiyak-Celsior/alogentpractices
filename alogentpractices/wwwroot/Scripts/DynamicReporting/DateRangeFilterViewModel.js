var DateRangeFilterViewModel = (function ($, undefined) {
    return ViewModel.extend({
        /*
         * Filter Types
         *   0 - Date Range
         *   1 - Relative Range
         * Relative Types
         *   0 - Last N Day(s)
         *   1 - Next N Day(s)
         *
         * As dictated by the DTO structure of the service layer classes.
         */

        init: function (name, field) {
            ViewModel.fn.init.call(this);

            this.field = field;
            this.name  = name;
            this.type  = "DateRange";
        },
        field: undefined,
        fromDate: null,
        toDate: null,
        type: undefined,
        filterType: 0,
        isRelative: function() {
            return this.get("filterType") == 1; // Used == instead of === because kendo data-type for strongly-typed bindings isn't working - instead of setting an integer it is setting a string
        },
        isDate: function() {
            return this.get("filterType") == 0; // Used == instead of === because kendo data-type for strongly-typed bindings isn't working - instead of setting an integer it is setting a string
        },
        name: undefined,
        relativeValue: null,
        relativeType: 0
    });
})(window.kendo.jQuery);