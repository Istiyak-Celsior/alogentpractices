var ReportField = kendo.Class.extend({
    init: function(name, sortOrder, sortDirection, width) {
        this.name          = name;
        this.sortOrder     = sortOrder;
        this.sortDirection = sortDirection;
        this.width         = Math.floor(width);
        this.behaviors = {
            linkBehavior: null
        }
    },
    name: undefined,
    sortOrder: undefined,
    sortDirection: undefined,
    width: undefined,
    behaviors: undefined
});