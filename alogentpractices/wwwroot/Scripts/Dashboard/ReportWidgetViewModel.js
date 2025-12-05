var ReportWidgetViewModel = (function($, undefined) {
    return ReportViewModel.extend({
        init: function (dashboard, widget, x, y, width, height, id, user, options, reportService) {
            ReportViewModel.fn.init.call(this, reportService);

            this.user = user;

            this._reportService = reportService;

            //this.set("dashboard", dashboard); // BUG: Is causing a stack overflow, but don't know why, possibly because its a kendo widget reference
            this.dashboard = dashboard;
            this.set("widget", widget);
            this.set("positionX", x);
            this.set("positionY", y);
            this.set("sizeX", width);
            this.set("sizeY", height);
            this.set("id", id);
            this.set("options", options);
            this.set("reports", this._reports());

            if (options) {
                this.set("options", options);
            } else {
                this.set("options", [{ Name: "ReportName", Value: null }, { Name: "ReportOwner", Value: null }]);
            }
        },
        widget: undefined,
        positionX: undefined,
        positionY: undefined,
        sizeX: undefined,
        sizeY: undefined,
        id: undefined,
        options: [],
        getOption: function (name) {
            var item = null;

            $.each(this.options,
                function (i, option) {
                    if (option.Name === name) {
                        item = option;
                    }
                });

            return item;
        },
        setOption: function (name, value) {
            $.each(this.options,
                function (i, option) {
                    if (option.Name === name) {
                        option.Value = value;
                    }
                });
        },
        hasReports: function () {
            var reports = this.get("reports");

            var data = reports.view();

            return data.length > 0;
        },
        isfiltered: function() {
            return this.get("filters").length > 0;
        },
        refresh: function () {
            var that = this;

            if (that.report) {
                that.view(that.report.owner, that.report.name);
            }
        },
        refreshReports: function() {
            this.reports.read();
        },
        report: null,
        reports: undefined,
        reportChanged: function () {
            var that = this;

            if (that.report) {
                that.setOption("ReportName", that.report.name);
                that.setOption("ReportOwner", that.report.owner);
                that.dashboard.setWidgetState(that, "normal");
            } else {
                that.setOption("ReportName", null);
                that.setOption("ReportOwner", null);
            }

            if (that.report) {
                that.view(that.report.owner, that.report.name);
            }
        },
        user: undefined,
        view: function(owner, name) {
            var that = this;

            that.dashboard.setWidgetState(that, "normal");

            var view = ReportViewModel.fn.view.call(that, owner, name);

            view.fail($.proxy(that._viewFail, that));

            view.done(function () {
                that.data.fetch();
            });
        },
        _reports: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that._reportService.getReportList(that.user);

                        api.fail(function (result) {
                            options.error(result);
                        });

                        api.done(function (result) {
                            options.success(result);
                        });
                    }
                },
                change: function () {
                    var reportNameOption = that.getOption("ReportName").Value;

                    if (reportNameOption) {
                        $.each(this.view(), function (i, item) {
                            if (item.name === reportNameOption) {
                                that.set("report", item);
                            }
                        });
                    }

                    if (!that.report) {
                        that.dashboard.setWidgetState(that, "misconfigured");
                    }
                    else {
                        that.view(that.report.owner, that.report.name);
                    }
                },
                error: function (e) {
                    that.dashboard.setWidgetState(that, "error", e.xhr.responseText);
                },
                schema: {
                    data: function (response) {
                        return that._reportItems(response);
                    },
                    type: "json",
                    model: {
                        id: "ReportId",
                        fields: {
                            name: {
                                field: "Name"
                            },
                            owner: {
                                field: "Owner"
                            },
                            isOwned: {
                                field: "IsOwned",
                                type: "boolean"
                            }
                        }
                    }
                },
                sort: {
                    field: "name",
                    dir: "asc"
                }
            });
        },
        _reportItems: function (data) {
            var items = [];

            $.each(data.Items, function (i, item) {
                items.push(item);
            });

            $.each(data.SharedItems, function (i, item) {
                items.push(item);
            });

            return items;
        },
        _viewFail: function(e) {
            if (e.responseJSON) {
                this.dashboard.setWidgetState(this, "error", e.responseJSON);
            } else {
                this.dashboard.setWidgetState(this, "error", e.responseText);
            }
        }
    });
})(window.kendo.jQuery);