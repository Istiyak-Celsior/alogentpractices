var DashboardWidgetViewModel = ViewModel.extend({
    init: function (dashboard, widget, x, y, width, height, id, options) {
        ViewModel.fn.init.call(this);

        //this.set("dashboard", dashboard); // BUG: Is causing a stack overflow, but don't know why, possibly because its a kendo widget reference
        this.dashboard = dashboard;
        this.set("widget", widget);
        this.set("positionX", x);
        this.set("positionY", y);
        this.set("sizeX", width);
        this.set("sizeY", height);
        this.set("id", id);
        this.set("options", options);
    },
    widget: undefined,
    positionX: undefined,
    positionY: undefined,
    sizeX: undefined,
    sizeY: undefined,
    id: undefined,
    refresh: function() {},
    options: [],
    getOption: function (name) {
        var item = null;

        $.each(this.options, function (i, option) {
            if (option.Name === name) {
                item = option;
            }
        });

        return item;
    },
    setOption: function (name, value) {
        $.each(this.options, function (i, option) {
            if (option.Name === name) {
                option.Value = value;
            }
        });
    }
});