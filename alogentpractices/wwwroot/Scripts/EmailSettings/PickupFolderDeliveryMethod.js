var PickupFolderDeliveryMethod = kendo.data.Model.extend({
    init: function (kind, service) {
        kendo.data.Model.fn.init.call(this);

        var that = this;

        that.kind     = kind;
        that._service = service;
    },
    id: 1,
    name: "Pickup Directory",
    pickupDirectory: ""
});