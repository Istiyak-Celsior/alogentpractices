var NetworkDeliveryMethod = kendo.data.Model.extend({
    init: function (kind, service) {
        kendo.data.Model.fn.init.call(this);

        var that = this;

        that.kind     = kind;
        that._service = service;

        this.set("authenticationType", this.authenticationTypes[1].name);
    },    
    authenticationType: "",
    authenticationTypes: [
        { name: "Windows Authentication" },
        { name: "Basic Authentication" }
    ],
    id: 0,
    name: "SMTP AUTH",
    server: "",
    port: 25,
    enableSsl: true,
    requiresAuthentication: false,
    username: "",
    password: "",
    hasSendAsPolicy: false,
    isBasicAuthenticationType: function () {
        return this.get("requiresAuthentication") === true && this.get("authenticationType") === "Basic Authentication";
    },
    onPortChange: function (e) {
        this.trigger({field: "port"});
    }
});