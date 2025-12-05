var DashboardService = kendo.Class.extend({
    init: function (webapi) {
        this._webapi = webapi;
    },
    getDashboard: function (dashboardId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("dashboards({0})", dashboardId),
            action: "widgets"
        });
    },
    deleteDashboard: function (dashboardId) {
        return this._webapi.delete({
            area: "",
            controller: kendo.format("dashboards({0})", dashboardId),
            action: ""
        });
    },
    getDashboards: function (user) {
        return this._webapi.get({
            area: "",
            controller: "dashboards",
            action: kendo.format("?username={0}", user)
        });
    },
    createDashboard: function (user, name, widgets) {
        return this._webapi.post({
            area: "",
            controller: "dashboards",
            action: "",
            data: this._serializeDashboard(user, name, widgets)
        });
    },
    updateDashboard: function (user, name, widgets, dashboardId) {
        return this._webapi.put({
            area: "",
            controller: kendo.format("dashboards({0})", dashboardId),
            action: "",
            data: this._serializeDashboard(user, name, widgets, dashboardId)
        });
    },
    _serializeDashboard: function (user, name, widgets, dashboardId) {
        var widgetModels = [];

        $.each(widgets, function (i, widget) {
            widgetModels.push({
                "Id": widget.id,
                "Widget": widget.widget,
                "PositionX": widget.positionX,
                "PositionY": widget.positionY,
                "SizeX": widget.sizeX,
                "SizeY": widget.sizeY,
                "Options": widget.options
            });
        });

        return {
            DashboardId: dashboardId,
            UserName: user,
            Name: name,
            Widgets: widgetModels
        };
    }
});