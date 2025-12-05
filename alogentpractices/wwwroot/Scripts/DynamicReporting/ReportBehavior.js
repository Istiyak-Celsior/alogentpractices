var ReportBehavior = kendo.data.Model.extend({
    init: function (id, field) {
        kendo.data.Model.fn.init.call(this);

        this.id    = id;
        this.field = field
    },
    id: undefined,
    field : undefined
});