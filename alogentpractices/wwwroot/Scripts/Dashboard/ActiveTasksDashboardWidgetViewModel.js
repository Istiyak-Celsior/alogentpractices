var ActiveTasksDashboardWidgetViewModel = ExceptionDashboardWidgetViewModel.extend({
    init: function (dashboard, widget, x, y, width, height, id) {
        ExceptionDashboardWidgetViewModel.fn.init.call(this, dashboard, widget, x, y, width, height, id);
    },
    resolveTask: function (e) {
        var that = this;
        var exceptionId = $(e.currentTarget).attr("data-exceptionId");

        $.ajax({
            url: kendo.format("resolvetask.asp?exceptionId={0}&section=dashboard", exceptionId),
            cache: false,
            success: function (e) {
                that.dashboard.refreshWidget(that);
            },
            error: function (err) {
                console.log(err);
            }
        });
    },
    reassignTask: function (e) {
        var that = this;
        var exceptionId = $(e.currentTarget).attr("data-exceptionId");
       
        $.ajax({
            url: kendo.format("reassigntaskInclude.asp?exceptionId={0}", exceptionId),
            cache: false,
            success: function (e) {
                var view = new ActiveTasksDashboardWidgetView(that, e);

                view.open();
            },
            error: function (err) {
                console.log(err);
            }
        });
    },
    updateTask: function (closeCallback, settings) {
        var that = this;

        $.ajax({
            type: "POST",
            url: "reassigntaskupdate.asp",
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