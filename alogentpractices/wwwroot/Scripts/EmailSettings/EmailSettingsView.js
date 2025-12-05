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