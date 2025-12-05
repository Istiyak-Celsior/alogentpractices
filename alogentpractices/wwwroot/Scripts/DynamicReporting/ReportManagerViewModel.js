var ReportManagerViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user, hasModule) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user = user;
            this.isPurchased = hasModule;
        },
        addReport: function(report, open) {
            this.userReports.push(report);
            this.set("numberUserReports", this.numberUserReports + 1);

            if (open) {
                this.openReport({
                    data: report
                });
            }
        },
        addSharedReport: function(report) {
            this.sharedReports.push(report);
            this.set("numberSharedReports", this.numberSharedReports + 1);
        },
        copyReport: function(e) {
            e.stopPropagation();

            var that = this;
            var result = new $.Deferred();
            var report = e.data;
            var viewModel = new CopyReportViewModel(that, that.service, report, that.user);

            that.trigger("copy", { viewModel: viewModel, result: result });

            result.then(function(name) {
                var newReport = new ReportTileViewModel(name,
                    report.description,
                    that.user,
                    true,
                    false,
                    false,
                    that.isPurchased,
                    that.canExport,
                    that.canShare,
                    that.canCreate,
                    that.canEmail);

                that.addReport(newReport, false);
            });
        },
        createReport: function() {
            var that = this;
            var viewModel = new NewReportViewModel(that.service, that.user);
            var result = new $.Deferred();

            that.trigger("create", { result: result, viewModel: viewModel });

            result.then(function() {
                var newReport = new ReportTileViewModel(viewModel.name,
                    viewModel.description,
                    that.user,
                    true,
                    false,
                    false,
                    that.isPurchased,
                    that.canExport,
                    that.canShare,
                    that.canCreate,
                    that.canEmail);

                that.addReport(newReport, true);
            });
        },
        deleteReport: function(e) {
            e.stopPropagation();

            var that = this;
            var report = e.data;
            var result = new $.Deferred();

            that.trigger("delete", { user: that.user, report: report, result: result });

            result.then(function() {
                that.service
                    .deleteReport(that.user, report.name)
                    .done(function() {
                        that.removeReport(report);
                    });
            });
        },
        downloadReport: function(e) {
            e.stopPropagation();

            window.location.replace(kendo.format("api/DynamicReporting/DownloadReport?UserName={0}&ReportName={1}",
                e.data.owner,
                e.data.name));
        },
        emailReport: function(e) {
            e.stopPropagation();

            var that      = this;
            var report    = e.data;
            var result    = new $.Deferred();
            var viewModel = new EmailReportViewModel(that.service, that.user, report);

            that.trigger("email", { result: result, viewModel: viewModel });

            result.then(function() {
                var users = [];

                $.each(viewModel.selectedUsers, function(i, user) {
                    users.push(user.userName);
                });

                var tile = that.findReport(report.name);

                tile.set("isBusy", true);

                that.service
                    .emailReport(that.user, report.name, viewModel.message, users)
                    .done(function() {
                        tile.set("isBusy", false);
                    });
            });
        },
        exportReport: function(e) {
            e.stopPropagation();

            this.trigger("export", { report: e.data });
        },
        findReport: function(name) {
            var val = null;
            var reports = this.get("userReports");

            $.each(reports,
                function(i, report) {
                    if (report.name.toLowerCase() === name.toLowerCase()) {
                        val = report;
                        return false;
                    }
                });

            return val;
        },
        findSharedReport: function(name, owner) {
            var val = null;
            var reports = this.get("sharedReports");

            $.each(reports,
                function(i, report) {
                    if (report.name.toLowerCase() === name.toLowerCase()
                        && report.owner.toLowerCase() === owner.toLowerCase()) {
                        val = report;
                        return false;
                    }
                });

            return val;
        },
        importReport: function() {
            var that      = this;
            var viewModel = new ImportReportViewModel(that.service, that.user);
            var result    = new $.Deferred();

            that.trigger("import", { result: result, viewModel: viewModel });

            result.then(function() {
                var importedReport = new ReportTileViewModel(viewModel.name,
                                                             "",
                                                             that.user,
                                                             true,
                                                             false,
                                                             false,
                                                             that.isPurchased,
                                                             that.canExport,
                                                             that.canShare,
                                                             that.canCreate,
                                                             that.canEmail);

                that.addReport(importedReport, false);
            });
        },
        isPurchased: undefined,
        load: function() {
            var that = this;

            var userPermissionsAjax = that.service
                .getUserPermissions(that.user)
                .done(function(e) {
                    that.set("canCreate", e.CanCreateReports);
                    that.set("canExport", e.CanExportReports);
                    that.set("canShare", e.CanShareReports);
                    that.set("canEmail", e.CanEmail);
                });

            var reportListAjax = $.when(userPermissionsAjax)
                .then(function() {
                    return that.service.getReportList(that.user)
                        .done(function(e) {
                            $.each(e.Items,
                                function(index, item) {
                                    that.addReport(new ReportTileViewModel(item.Name,
                                            item.Description,
                                            item.Owner,
                                            item.IsOwned,
                                            item.IsShared,
                                            item.IsSharedBankwide,
                                            that.isPurchased,
                                            that.canExport,
                                            that.canShare,
                                            that.canCreate,
                                            that.canEmail),
                                        false);
                                });

                            $.each(e.SharedItems,
                                function(index, item) {
                                    that.addSharedReport(new ReportTileViewModel(item.Name,
                                            item.Description,
                                            item.Owner,
                                            item.IsOwned,
                                            item.IsShared,
                                            item.IsSharedBankwide,
                                            that.isPurchased,
                                            that.canExport,
                                            that.canShare,
                                            that.canCreate,
                                            that.canEmail),
                                        false);
                                });
                        });
                });

            return $.when(reportListAjax);
        },
        numberSharedReports: 0,
        numberUserReports: 0,
        openReport: function(e) {
            var that = this;
            var viewModel = new ReportEditorViewModel(that.service,
                e.data.isOwned,
                e.data.description,
                that.canExport,
                that.isPurchased);

            viewModel.view(e.data.owner, e.data.name)
                .done(function() {
                    that.trigger("open", { report: viewModel, isOwner: e.data.isOwned });
                });
        },
        removeReport: function(report) {
            var newList = this.userReports.filter(function(item) {
                return item.name !== report.name;
            });

            this.set("userReports", newList);
            this.set("numberUserReports", this.numberUserReports - 1);
        },
        sharedReports: [],
        shareReport: function(e) {
            e.stopPropagation();

            var that      = this;
            var report    = e.data;
            var result    = new $.Deferred();
            var viewModel = new ShareReportViewModel(that.service, 
                                                     that.user, 
                                                     report);

            that.service
                .getSharedUsers(that.user, report.name)
                .done(function(data) {
                    viewModel.select(data.Users, data.IsSharedBankwide);
                    that.trigger("share", { result: result, viewModel: viewModel });
                });

            result.then(function() {
                var users = [];

                $.each(viewModel.selectedUsers, function(i, user) {
                    users.push(user.userName);
                });

                var tile = that.findReport(e.data.name);

                tile.set("isBusy", true);

                that.service
                    .shareReport(that.user, report.name, viewModel.isSharedBankwide, users)
                    .done(function() {
                        report.set("isShared", viewModel.isSharedBankwide || viewModel.selectedUsers.length > 0);
                        report.set("isSharedBankwide", viewModel.isSharedBankwide);
                        tile.set("isBusy", false);
                    });
            });
        },
        updateTile: function(report) {
            $.each(this.userReports, function(i, tile) {
                if (tile.name === report.name) {
                    tile.set("name", report.currentName);
                    tile.set("description", report.description);
                }
            });
        },
        userReports: [],
        user: undefined,
        canDownload: undefined,
        canCreate: false,
        canExport: false,
        canShare: false
    });
})(window.kendo.jQuery);