var ExceptionDashboardWidgetViewModel = DashboardWidgetViewModel.extend({
    init: function(dashboard, widget, x, y, width,  height, id) {
        DashboardWidgetViewModel.fn.init.call(this, dashboard, widget, x, y, width, height, id);
    },
    openFilterSettings: function (content) {
        var that = this;

        $.ajax({
            url: "activeexceptionfilter.asp",
            cache: false,
            success: function (e) {
                var view = new ExceptionFilterSettingsView(that, e);

                view.open();
            },
            error: function (err) {
                console.log(err);
            }
        });
    },
    updateSettings: function (closeCallback, settings) {
        var that = this;

        $.ajax({
            type: "POST",
            url: "activeexceptionfilterupdate.asp",
            cache: false,
            data: settings,
            success: function () {
                closeCallback();
                that.dashboard.refreshWidget(that);
            },
            error: function (err) {
                console.log(err);
            }
        });
    }
});
