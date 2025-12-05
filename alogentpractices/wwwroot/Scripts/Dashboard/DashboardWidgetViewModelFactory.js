var DashboardWidgetViewModelFactory = kendo.Class.extend({
    create: function(dashboard, dashboardId, widget, positionX, positionY, sizeX, sizeY, user, userId, options, reportService) {
        switch (widget) {
            case 'Active Tasks':
                return new ActiveTasksDashboardWidgetViewModel(dashboard, widget, positionX, positionY, sizeX, sizeY);
            case 'My Active Exceptions Summary':
                return new ExceptionDashboardWidgetViewModel(dashboard, widget, positionX, positionY, sizeX, sizeY);
            case 'Quick Search':
                return new QuickSearchDashboardWidgetViewModel(dashboard, widget, positionX, positionY, sizeX, sizeY);
            case 'My Uploads':
                return new MyUploadsWidgetViewModel(dashboard, widget, positionX, positionY, sizeX, sizeY, null, user, userId, options, dashboardId);
            case 'Report':
                return new ReportWidgetViewModel(dashboard, widget, positionX, positionY, sizeX, sizeY, null, user, options, reportService);
            default:
                return new DashboardWidgetViewModel(dashboard, widget, positionX, positionY, sizeX, sizeY);
        }
    }
});