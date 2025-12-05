(function (window, $, kendo, undefined) {

    if (!kendo.mvvm) {
        kendo.mvvm = {};
    }

    kendo.mvvm.Model = kendo.data.Model.extend({
        init: function () {
            kendo.data.Model.fn.init.call(this);
        }
    });
    
    kendo.mvvm.View = kendo.Class.extend({
        init: function (element, viewModel) {
            var that = this;
    
            that.viewModel = viewModel;
    
            $(document).ready($.proxy(that._ready, that, $(element), viewModel));
        },
        _ready: function(element, viewModel) {
            $("[data-role='pageload']").remove();
             
            kendo.ui.progress(element, true);
    
            this.ready(element, viewModel);
        },
        ready: function (element, viewModel) {
            kendo.bind(element, viewModel);
            kendo.ui.progress(element, false);
        }
    });
    
    kendo.mvvm.ViewModel = kendo.data.ObservableObject.extend({
        init: function() {
            kendo.data.ObservableObject.fn.init.call(this, this);
        }
    });
    
    kendo.mvvm.DialogViewModel = kendo.mvvm.ViewModel.extend({
        init: function() {
            ViewModel.fn.init.call(this);
        },
        triggerClose: function(userTriggered, dialogResult) {
            this.trigger("close", { userTriggered: userTriggered, dialogResult: dialogResult });
        }
    });

    kendo.mvvm.DialogService = kendo.Class.extend({
        init: function (views) {
            this.views = views;
        },
        hasDialogOpen: false,
        views: {},
        open: function(view, options) {
            if (!view) throw "Required [view] is missing.";

            var dialogResult  = new $.Deferred();
            var dialogElement = $("<div class='k-custom-dialog' />").kendoDialog({
                actions: options.actions,
                close: function () {
                    this.destroy();
                }
            });

            var dialogView         = this.views[view];
            var template           = dialogView.id;
            var dialogTemplateDOM  = $(template).html();
            var dialog             = dialogElement.data("kendoDialog");
            var dialogTemplate     = $(kendo.template(dialogTemplateDOM)(options.viewModel));

            dialog.content(dialogTemplate);

            if (dialogView.cssClass) {                
                let rootElement = dialog.element.closest(".k-dialog");

                $(rootElement).addClass(dialogView.cssClass);
            }

            if (dialogView.cssContentClass) {
                let contentElement = dialogElement;
                
                $(contentElement).addClass(dialogView.cssContentClass);
            }

            dialog.bind("close", function(e) {
                if (dialogResult.state() !== "resolved") {
                    dialogResult.resolve({userTriggered: e.userTriggered, dialogResult: null});
                };
            });

            if (options.viewModel) {                
                kendo.bind(dialogTemplate, options.viewModel);

                if (options.viewModel instanceof kendo.mvvm.DialogViewModel) {
                    options.viewModel.bind("close", function(e) {
                        dialogResult.resolve({userTriggered: e.userTriggered, dialogResult: e.dialogResult});    
                        dialog.close();                
                    });
                }
            }

            if (options.title) {
                dialog.title(options.title);
            }

            dialog.open();

            this.hasDialogOpen = true;

            if (options.opened) {
                $.proxy(options.opened(), this);
            }

            var promise = dialogResult.promise();
            var that    = this;

            promise.always(function () {
                that.hasDialogOpen = false;
            });

            return promise;
        }
    });
    
    // Plugs for backwards compatibility until we can refactor all the JS
    // bundles and files to switch to the new namespace.
    window.Model     = kendo.mvvm.Model;
    window.ViewModel = kendo.mvvm.ViewModel;
    window.View      = kendo.mvvm.View;

})(window, window.kendo.jQuery, window.kendo);
var ApiService = (function($) {
    var publicApi = {
        authorizationHeader: undefined,
        error: undefined,
        get: undefined,
        post: undefined,
        success: undefined,
        requestStart: undefined,
        requestEnd: undefined
    };

    publicApi.delete = function(options) {
        return _ajax("DELETE", options);
    };

    publicApi.get = function(options) {
        return _ajax("GET", options);
    };

    publicApi.patch = function(options) {
        return _ajax("PATCH", options);
    };

    publicApi.post = function(options) {
        return _ajax("POST", options);
    };

    publicApi.put = function(options) {
        return _ajax("PUT", options);
    };

    function _ajax(method, options) {
        return $.ajax({
            url: _buildUri(options.area, options.controller, options.action),
            method: method,
            cache: false,
            contentType: "application/json",
            data: options.data != undefined ? JSON.stringify(options.data) : undefined,
            beforeSend: function(xhr) {
                if (typeof options.username !== "undefined") {
                    xhr.setRequestHeader('x-accuaccount-username', options.username);
                }

                if (typeof options.password !== "undefined") {
                    xhr.setRequestHeader('x-accuaccount-password', options.password);
                }

                if (publicApi.requestStart) {
                    publicApi.requestStart.bind(publicApi)();
                }
            },
            complete: function(response) {
                if (publicApi.requestEnd) {
                    publicApi.requestEnd.bind(publicApi)();
                }
            },
            success: function(response) {
                if (typeof options.success !== "undefined") {
                    options.success(response);
                }

                if (typeof publicApi.success !== "undefined") {
                    publicApi.success();
                }
            },
            error: function(response) {
                var error = {
                    statusCode: response.status,
                    statusDescription: response.statusText,
                    errorMessage: response.responseJSON != null ? response.responseJSON.ErrorMessage 
                        : "A general failure occurred communicating with the server (status: " + response.statusText + ").",
                    response: response
                };

                if (typeof options.error !== 'undefined') {
                    options.error(error);
                }

                if (typeof publicApi.error !== "undefined") {
                    publicApi.error(error);
                }
            }
        });
    }

    function _buildUri(area, controller, action) {
        var uri = "";

        if (area === null) {
            uri += "api/";
        }
        else if (area === "") {
        }
        else {
	        uri += "api/";
        }

        uri += controller;

        if (action) {
            uri += "/";
            uri += action;
        }

        return uri;
    }

    return publicApi;
});
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
var EmailSettingsView = View.extend({
    init: function (element, viewModel, webapi) {
        View.fn.init.call(this, element, viewModel);

        webapi.error = function (e) {
            console.log(e.errorMessage);
            console.log(e.response.responseText);
        };

        this.webapi = webapi;
    },
    ready: function (element, viewModel) {
        this._ui(element);

        this._events(viewModel);

        kendo.bind(element, viewModel);

        this._setDeliveryMethodView(viewModel);

        var request = this.webapi.get({
            area: "",
            controller: "settings",
            action: "smtp"
        });

        request.done(function(response) {
            viewModel.applySettings(response);
            kendo.ui.progress(element, false);
        });
    },
    _events: function (viewModel) {
        var that = this;

        that.viewModel.bind("change", $.proxy(that._onViewModelChange, that));
        that.viewModel.bind("progress", $.proxy(that._onViewModelProgress, that));
        
        $("#main-form").on("#network-port", "keyup", function (e) {
           that.viewModel.deliveryMethod.network.trigger("change", {field: "port"});
        });
    },
    _onViewModelChange: function (e) {
        if (e.field === "deliveryMethod.current") {
            this._setDeliveryMethodView(e.sender);
        }

        if (e.field !== "isValid") {
            var isValid = this.validator.validate();

            this.viewModel.set("isValid", isValid);
        }

        if (e.field === "test.fromAddress" || e.field === "test.toAddress") {
            var validator = $("#test-form").data("kendoValidator");

            validator.validate();
        }
    },
    _onViewModelProgress: function(e) {
        var body = $(document.body);

        window.kendo.ui.progress(body, e.progress);
    },
    _setDeliveryMethodView: function (viewModel) {
        var deliveryMethod = viewModel.get("deliveryMethod.current");
        var template;

        if (deliveryMethod instanceof NetworkDeliveryMethod) {
            template = "network-template";
        }

        if (deliveryMethod instanceof PickupFolderDeliveryMethod) {
            template = "pickup-template";
        }

        if (deliveryMethod instanceof Office365DeliveryMethod) {
            template = "office365-template";
        }

        var view = new kendo.View(template, { model: deliveryMethod, evalTemplate: true, wrap: false });

        kendo.destroy($("#mail-configuration"));

        $("#mail-configuration").empty();

        view.render($("#mail-configuration"));
    },
    _ui: function (element) {
        this.validator = $("#main-form").kendoValidator(this.viewModel.validation)
                                        .data("kendoValidator");

        $("#test-form").kendoValidator();
    }
});