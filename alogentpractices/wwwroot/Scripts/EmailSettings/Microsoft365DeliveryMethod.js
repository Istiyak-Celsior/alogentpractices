var Office365DeliveryMethod = kendo.data.Model.extend({
    init: function (kind, service) {
        kendo.data.Model.fn.init.call(this);

        var that = this;

        that.kind     = kind;
        that._service = service;
    },
    id: 2,
    name: "Microsoft 365",
    tenantId: "",
    applicationId: "",
    clientSecret: ""
});