var ReportGroup = (function () {
    return kendo.Class.extend({
        init: function (name, sortDirection) {
            this.name = name;
            this.sortDirection = sortDirection;
        },
        name: undefined,
        sortDirection: undefined
    });
})();