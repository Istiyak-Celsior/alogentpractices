var EmailSettingsViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function () {
            ViewModel.fn.init.call(this);

            this.set("isValid", false);

            this.set("deliveryMethod.network", new NetworkDeliveryMethod());
            this.set("deliveryMethod.pickup", new PickupFolderDeliveryMethod());
            this.set("deliveryMethod.office365", new Office365DeliveryMethod());
            this.set("deliveryMethod.items", [
                this.deliveryMethod.network,
                this.deliveryMethod.pickup,
                this.deliveryMethod.office365
            ]);

            this.set("deliveryMethod.current", this.get("deliveryMethod.items")[0]);

            // Create primitive field because kendo validator cannot be initialized with
            // an observable object.
            this.validation = this._createValidation();

            this.bind("change", this._onChange);
        },
        canSave: function () {
            var isDirty = this.get("isDirty");
            var isValid = this.get("isValid");

            return isDirty && isValid;
        },
        deliveryMethod: {
            items: [],
            current: null
        },
        isDirty: false,
        serviceMailbox: "",
        messageSizeLimit: 0,
        enableSecureMail: false,
        secureMailPhrase: "",
        applySettings: function (settings) {
            switch (settings.DeliveryMethod) {
                case 0:
                    this.set("deliveryMethod.current", this.deliveryMethod.network);
                    break;
                case 1:
                    this.set("deliveryMethod.current", this.deliveryMethod.pickup);
                    break;
                case 2:
                    this.set("deliveryMethod.current", this.deliveryMethod.office365);
                    break;
            }

            this.set("messageSizeLimit", settings.MaxMessageSize);
            this.set("secureMailPhrase", settings.SecureEmailPhrase);
            this.set("serviceMailbox", settings.ServiceMailbox);
            this.set("enableSecureMail", settings.EnableSecureMail);

            this.set("deliveryMethod.network.server", settings.Server);
            this.set("deliveryMethod.network.port", settings.Port);
            this.set("deliveryMethod.network.requiresAuthentication", settings.RequireAuthentication);
            this.set("deliveryMethod.network.authenticationType", settings.UseDefaultCredentials ? "Windows Authentication" : "Basic Authentication");
            this.set("deliveryMethod.network.enableSsl", settings.EnableSsl);
            this.set("deliveryMethod.network.username", settings.UserName);
            this.set("deliveryMethod.network.password", settings.Password);
            this.set("deliveryMethod.network.hasSendAsPolicy", settings.HasSendAsPolicy);

            this.set("deliveryMethod.pickup.pickupDirectory", settings.PickupDirectory);

            this.set("deliveryMethod.office365.tenantId", settings.MicrosoftAzureTenantId);
            this.set("deliveryMethod.office365.clientId", settings.MicrosoftAzureClientId);
            this.set("deliveryMethod.office365.clientSecret", settings.MicrosoftAzureClientSecret); // Per Specification: TBD Security Vulnerability to resolve.

            this.set("isDirty", false);
        },
        saveSettings: function (e) {
            var scope = this;

            var model = scope._createModel(scope);
            
            scope.trigger("progress", { progress: true });

            $.ajax({
                url: "settings/smtp",
                method: "PUT",
                cache: false,
                contentType: "application/json",
                data: JSON.stringify(model),
                success: function (response) {
                    scope.set("isDirty", false);
                    scope.trigger("progress", { progress: false });
                },
                failure: function (response) {
                }
            });
        },
        test: {
            isAvailable: function () {
                var hasFromAddress = this.get("fromAddress") !== "";
                var hasToAddress   = this.get("toAddress") !== "";
                var parent         = this.parent();
                var isValid        = parent.get("isValid");

                return hasFromAddress && hasToAddress && isValid;
            },
            fromAddress: "",
            toAddress: "",
            action: function (e) {
                e.preventDefault();

                var model       = this._createModel(this);
                var fromAddress = this.test.fromAddress;
                var toAddress   = this.test.toAddress;
                var scope       = this;

                scope.trigger("progress", { progress: true });

                $.ajax({
                     url: kendo.format("settings/smtp/verify?fromAddress={0}&toAddress={1}", fromAddress, toAddress),
                     method: "POST",
                     cache: false,
                     contentType: "application/json",
                     data: JSON.stringify(model),
                     success: function (response) {
                         scope.trigger("progress", { progress: false });
                         scope.set("test.state", 1);
                         scope.set("test.lastError", "");
                     },
                     error: function (response) {
                         scope.trigger("progress", { progress: false });
                         scope.set("test.state", 2);
                         scope.set("test.lastError", response.responseText);
                     }
                 });
            },
            state: 0,
            hasError: function () {
                return this.get("state") === 2;
            },
            hasSuccess: function () {
                return this.get("state") === 1;
            },
            lastError: ""
        },
        _createValidation: function() {
            var scope = this;

            return {
                rules: {
                    pickupFolderRule: function (input) {
                        if (scope.deliveryMethod.current instanceof PickupFolderDeliveryMethod) {
                            if (input[0].name === "pickupFolder") {
                                return scope.deliveryMethod.pickup.pickupDirectory !== "";
                            }
                        }
                        return true;
                    },
                    networkUserNameRule: function (input) {
                        if (scope.deliveryMethod.current instanceof NetworkDeliveryMethod) {
                            if (input[0].name === "username" && 
                                scope.deliveryMethod.current instanceof NetworkDeliveryMethod && 
                                scope.deliveryMethod.network.isBasicAuthenticationType()) {
                
                                return scope.deliveryMethod.network.username !== "";
                
                            }
                        }
                        return true;
                    },
                    networkPasswordRule: function (input) {
                        if (scope.deliveryMethod.current instanceof NetworkDeliveryMethod) {
                            if (input[0].name === "password" && 
                                scope.deliveryMethod.current instanceof NetworkDeliveryMethod && 
                                scope.deliveryMethod.network.isBasicAuthenticationType()) {
                
                                return scope.deliveryMethod.network.password !== "";
                
                            }
                        }
                        return true;
                    },
                    networkPortRule: function (input) {
                        if (scope.deliveryMethod.current instanceof NetworkDeliveryMethod) {
                            if (input[0].name === "port") {
                                return typeof scope.deliveryMethod.current.port === "number" && !isNaN(scope.deliveryMethod.current.port);
                            }
                        }
                        return true;
                    }
                }
            };
        },
        _createModel: function (scope) {
            return {
                // Application options
                EnableSecureMail: scope.enableSecureMail,
                SecureEmailPhrase: scope.secureMailPhrase,
                ServiceMailbox: scope.serviceMailbox,
                DeliveryMethod: scope.deliveryMethod.current.id,
                MaxMessageSize: scope.messageSizeLimit,

                // Network Directory Method options
                Server: scope.deliveryMethod.network.server,
                Port: scope.deliveryMethod.network.port,
                RequireAuthentication: scope.deliveryMethod.network.requiresAuthentication,
                UseDefaultCredentials: scope.deliveryMethod.network.authenticationType === "Windows Authentication",
                UserName: scope.deliveryMethod.network.username,
                Password: scope.deliveryMethod.network.password,
                EnableSsl: scope.deliveryMethod.network.enableSsl,
                HasSendAsPolicy: scope.deliveryMethod.network.hasSendAsPolicy,

                // Pickup Directory Method options
                PickupDirectory: scope.deliveryMethod.pickup.pickupDirectory,

                // Office 365 options
                MicrosoftAzureTenantId: scope.deliveryMethod.office365.tenantId,
                MicrosoftAzureClientId: scope.deliveryMethod.office365.clientId,
                MicrosoftAzureClientSecret: scope.deliveryMethod.office365.clientSecret // Per Specification: Security Vulnerability to resolve
            };
        },
        _onChange: function(e) {
            
            if (e.field === "isDirty") {
                return;
            }

            this.set("isDirty", true);
        }
    });
})(window.kendo.jQuery);