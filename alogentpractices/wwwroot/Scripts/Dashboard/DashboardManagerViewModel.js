
// TODO: Dashboard refreshes after rename because name is used as the ID in the datasource. When this changes it has to update.

var DashboardManagerViewModel = ViewModel.extend({
    init: function($, kendo, webapi, service, reportService, errorHandler, user, userId) {
        ViewModel.fn.init.call(this);

        this.$              = $;
        this.kendo          = kendo;
        this._webapi        = webapi;
        this._service       = service;
        this._reportService = reportService;
        this._errorHandler  = errorHandler;
        this.user           = user;
        this.userId         = userId;

        this.bind("change", this._change);
    },
    addDashboard: function(e) {
        var dashboard = new DashboardViewModel("New Dashboard");

        dashboard.set("_isNew", true);

        this.widgets.data([]);

        this.dashboards.add(dashboard);

        this._triggerDashboardsChange();

        this._changeDashboard(dashboard);

        this.editDashboard();
    },
    addDashboardWidget: function(e) {
        var factory = new DashboardWidgetViewModelFactory();

        var viewModel = factory.create(this.dashboard, this.currentDashboard.id, e.data.name, 1, 1, null, null, this.user, this.userId, null, this._reportService);

        if (this.canAddDashboardWidget()) {
            this.dashboard.addWidget(viewModel);
        }
    },
    canAddDashboard: function() {
        return !this.get("isEditingDashboard");
    },
    canAddDashboardWidget: function() {
        return this.dashboard.nextPosition(1, 1) !== false;
    },
    canDeleteDashboard: function() {
        if (!this.get("currentDashboard")
            || this.dashboards.view().length === 1
            || this.get("currentDashboard._isNew")
            || this.get("isEditingDashboard")) {
            return false;
        }

        return true;
    },
    canEditDashboard: function() {
        return this.get("currentDashboard") && !this.get("isEditingDashboard");
    },
    canRefreshDashboard: function() {
        return !this.get("isEditingDashboard");
    },
    cancelEditDashboard: function() {
        var that = this;

        var dashboard = that.get("currentDashboard");

        dashboard.setName(dashboard.name);

        if (dashboard.get("_isNew")) {
            that.removeDashboard(dashboard);
        }

        that._errorHandler.clear();

        that._endEditDashboard();

        if (that.currentDashboard) {
            that._refreshDashboard(that.currentDashboard.id);
        } else {
            if (that.dashboards.view().length > 0) {
                that._changeDashboard(that.dashboards.view()[0]);
            }
        }
    },
    currentDashboard: null,
    currentDashboardChanged: function(e) {
        this._errorHandler.clear();

        if (!this.currentDashboard) {
            e.sender.select(-1);
            return;
        }

        this._refreshDashboard(this.currentDashboard.id);
    },
    dashboard: null,
    dashboards: new kendo.data.DataSource({
        data: []
    }),
    deleteDashboard: function() {
        var that = this;

        if (!that.currentDashboard) {
            return;
        }

        kendo.confirm("Are you sure you want to delete your current dashboard?")
            .then(function() {

                var promise = that._service.deleteDashboard(that.currentDashboard.id);

                promise.done(function() {
                    that.widgets.data([]);

                    that.removeDashboard(that.currentDashboard);

                    if (that.dashboards.view().length > 0) {
                        that._changeDashboard(that.dashboards.view()[0]);
                    }
                });
            });
    },
    editDashboard: function() {
        this.set("isEditingDashboard", !this.isEditingDashboard);

        this.dashboard.edit();

        this.trigger("edit");

        this.trigger("change", { field: "canAddDashboardWidget" });
    },
    hasDashboards: function() {
        // TODO: https://www.telerik.com/forums/how-do-i-bind-to-a-calculated-property-that-depends-on-an-observable-array-or-datasource
        //       currently this is refreshed by trigger("change") for the dashboards property.

        var ds   = this.get("dashboards");
        var data = ds.data();

        return data.length > 0;
    },
    isEditingDashboard: false,
    open: function(items) {
        var that = this;

        that.widgets.data([]);

        if (items.Dashboards.length === 0) {
            that._createFirstDashboard();
            return;
        }

        var dashboards = that._getDashboardsFromResponse(items);

        that.dashboards.data(dashboards.items);

        if (dashboards.default) {
            that._changeDashboard(dashboards.default);
            that._triggerDashboardsChange();
        }

        if (!dashboards.default && dashboards.items.length > 0) {
            that._changeDashboard(dashboards.items[0]);
            that._triggerDashboardsChange();
        }
    },
    refreshDashboard: function(e) {
        this._refreshDashboard(this.currentDashboard.id);
    },
    removeDashboard: function(dashboard) {
        this.widgets.data([]);

        if (this.currentDashboard.name === dashboard.name) {
            this._changeDashboard(null);
        }

        this.dashboards.remove(dashboard);

        this._triggerDashboardsChange();
    },
    saveDashboard: function(e) {
        var that     = this;
        var promise  = null;

        that.dashboard.save();

        if (that.currentDashboard._isNew) {
            promise = that._service.createDashboard(that.user, that.currentDashboard.currentName, that.widgets.data());
        } else {
            promise = that._service.updateDashboard(that.user, that.currentDashboard.currentName, that.widgets.data(), that.currentDashboard.id);
        }

        promise.done(function(e) {
            that._updateDashboardState(that.currentDashboard, e, that.widgets.data());
            that._endEditDashboard();
        });
    },
    user: null,
    widgets: new kendo.data.DataSource({
        data: []
    }),
    _change: function(e) {
        var that = this;
        
        if (e.field === "dashboard" && that.dashboard) {
            that.dashboard.bind("change", function(event) {
                that.trigger("change", { field: "canAddDashboardWidget" });
            });
        }  
    },
    _changeDashboard: function(dashboard) {
        this.set("currentDashboard", dashboard);

        // change event for Kendo DropDownList is not triggered by viewmodel code, so we must manually notify
        // the component when set currentDashboard to another value from code and not the UI.
        this.trigger("dashboardchange");
    },
    _createFirstDashboard: function() {
        var that    = this;
        var promise = that._createWelcomeDashboard();

        promise.done(function (e) {
            that.dashboards.data([new DashboardViewModel("Welcome", e.DashboardId)]);

            that._changeDashboard(that.dashboards.view()[0]);

            that._triggerDashboardsChange();
        });
    },
    _createWelcomeDashboard: function () {
        var dashboard = {
            name: "Welcome",
            currentName: "Welcome"
        };

        var widgets = [
            {
                widget:    "Quick Search",
                positionX: 1,
                positionY: 1,
                sizeX:     2,
                sizeY:     8,
                options:   null
            }
        ];

        return this._service.createDashboard(this.user, dashboard.name, widgets);
    },
    _endEditDashboard: function() {
        this.set("isEditingDashboard", false);

        this.dashboard.endEdit(); 

        this._errorHandler.clear();

        this.trigger("editend");
    },
    _getDashboardsFromResponse: function(response) {
        var defaultDashboard;
        var viewModels = [];

        $.each(response.Dashboards, function(i, dashboard) {
            var viewModel = new DashboardViewModel(dashboard.Name, dashboard.Id);

            viewModels.push(viewModel);

            if (dashboard.Name === response.Default) {
                defaultDashboard = viewModel;
            }
        });

        return { items: viewModels, default: defaultDashboard };
    },
    _refreshDashboard: function(dashboardId) {
        var that = this;

        if (that.currentDashboard._isNew) {
            that.widgets.data([]);
            return;
        }

        var promise = that._service.getDashboard(dashboardId);

        promise.done(function (response) {
            var widgets = [];

            $.each(response.Widgets, function (i, widget) {
                var factory = new DashboardWidgetViewModelFactory();

                var viewModel = factory.create(that.dashboard, dashboardId, widget.Widget, widget.PositionX, widget.PositionY, widget.SizeX, widget.SizeY, that.user, that.userId, widget.Options, that._reportService);

                viewModel.set("id", widget.Id);

                widgets.push(viewModel);
            });

            that.widgets.data(widgets);
        });
    },
    _triggerDashboardsChange: function() {
        // Binding to a calculated property that depends on a kendo.data.ObservableArray or kendo.data.DataSource
        // does not seem to fire the appropriate binding events, so we manually do this for those here.
        this.trigger("change", { field: "dashboards" });
    },
    _updateDashboardState: function(dashboard, data, widgets) {
        dashboard.setName(dashboard.currentName);
        dashboard.set("id", data.DashboardId);

        if (dashboard._isNew) {
            dashboard.set("_isNew", false); // TODO: Direct access to internal
        }

        $.each(data.Widgets, function(i, model) {
            $.each(widgets, function(j, widget) {
                if (model.PositionX === widget.positionX && model.PositionY === widget.positionY) {
                    widget.set("id", model.Id);
                }
            });
        });
    }
});