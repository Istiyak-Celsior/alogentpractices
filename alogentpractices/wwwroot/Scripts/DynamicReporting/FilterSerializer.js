var FilterSerializer = (function () {
    return kendo.Class.extend({
        init: function (filters) {
            this.serialize(filters);
        },
        serialize: function (filters) {
            var obj = {
                SearchFilters: [],
                MultiFilters: [],
                DateFilters: [],
                DateRangeFilters: []
            };

            $.each(filters, function (i, filter) {
                switch (filter.type) {
                    case "DateRange":
                        var dateRangeFilter = {
                            Field: filter.field,
                            FromDate: filter.fromDate,
                            ToDate: filter.toDate,
                            FilterType: filter.filterType,
                            RelativeType: filter.relativeType,
                            RelativeValue: filter.relativeValue
                        };
                        obj.DateRangeFilters.push(dateRangeFilter);
                        break;
                    case "Search":
                        var searchFilter = {
                            Field: filter.field,
                            Operator: filter.operator,
                            Value: filter.value
                        };
                        obj.SearchFilters.push(searchFilter);
                        break;
                    case "Multi":
                        var multiFilter = {
                            Field: filter.field,
                            Values: []
                        };

                        $.each(filter.items,
                            function (i, item) {
                                if (typeof MultiFilterEditViewModel !== "undefined" && filter instanceof MultiFilterEditViewModel) {
                                    if (item.isSelected === true) {
                                        multiFilter.Values.push(item.value);
                                    }
                                }
                                else if (filter instanceof MultiFilterViewModel) {
                                    multiFilter.Values.push(item.value);
                                }
                            });

                        obj.MultiFilters.push(multiFilter);
                        break;
                }
            });
            return obj;
        }
    });
})();