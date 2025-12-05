var ReportView = View.extend({
    init: function(element, viewModel, webapi, reportName, reportOwner) {
        View.fn.init.call(this, element, viewModel);
        
        this._webapi      = webapi;
        this._reportName  = reportName;
        this._reportOwner = reportOwner;
    },
    ready: function(element, viewModel) {
        var that = this;

        that._ui(element, viewModel);

        that._events(viewModel);
        
        viewModel.load()
                 .done(function() {
                     View.fn.ready.call(that, element, viewModel);

                     if (that._reportName) {
                         var report = viewModel.findSharedReport(that._reportName, that._reportOwner);
                 
                         if (report !== null) {
                             viewModel.openReport({ data: report });
                         }
                     }
                 });
    },
    _events: function() {
        this.viewModel.bind("create", $.proxy(this._createReport, this));
        this.viewModel.bind("open", $.proxy(this._openReport, this));
        this.viewModel.bind("copy", $.proxy(this._copyReport, this));
        this.viewModel.bind("delete", $.proxy(this._deleteReport, this));
        this.viewModel.bind("email", $.proxy(this._emailReport, this));
        this.viewModel.bind("export", $.proxy(this._exportReport, this));
        this.viewModel.bind("import", $.proxy(this._importReport, this));
        this.viewModel.bind("share", $.proxy(this._shareReport, this));

        $(document).on("click", ".r-cardheader", $.proxy(this._toggleCard, this));
    },
    _copyReport: function(e) {
        var dialogOptions = {
            title: "Copy Report",
            closable: false,
            modal: true,
            content: kendo.template($("#rm-copy-prompt-template").html()),
            actions: [
                {
                    text: "OK",
                    primary: true,
                    action: function (actionArgs) {
                        var promise = e.viewModel.copy();

                        promise.fail(function() {
                            $("#rm-copy-name").focus();
                        });

                        promise.done(function() {
                            e.result.resolve(e.viewModel.newReportName);
                            actionArgs.sender.close();
                        });

                        return false;
                    }
                },
                { text: "Cancel" }
            ],
            close: function () {
                this.destroy();
            }
        };

        var dialog = $("<div></div>").kendoDialog(dialogOptions)
                                     .data("kendoDialog");

        kendo.bind($(dialog.element), e.viewModel);

        dialog.open();

        $("#rm-copy-name").focus();
    },
    _createReport: function(e) {
        var dialogOptions = {
            width: "450px",
            title: "New Report",
            visible: false,
            content: kendo.template($("#nr-window-template").html()),
            actions: [
                {
                    text: "Create",
                    action: function(action) {
                        var deferred = e.viewModel.create();

                        deferred.done(function(result) {
                            if (result.Errors.length === 0) {
                                action.sender.close();
                                e.result.resolve();
                            }
                        });

                        return false;
                    },
                    primary: true
                },
                {
                    text: "Cancel"
                }
            ],
            close: function() {
                this.destroy();
            }
        };

        var dialog = $("<div></div>").kendoDialog(dialogOptions)
                                     .data("kendoDialog");
        
        kendo.bind(dialog.element, e.viewModel);

        dialog.open();

        $("#nr-name").focus();
    },
    _deleteReport: function(e) {
        var template = kendo.template($("#dr-template").html());

        var dataItem = { name: e.report.name };

        kendo.confirm(template(dataItem))
             .done(function() {
                 e.result.resolve();
             });
    },
    _emailReport: function(e) {
        var dialogOptions = {
            title: "Email Report",
            closable: false,
            modal: true,
            content: kendo.template($("#er-window-template").html()),
            width: 500,
            actions: [
                {
                    text: "OK",
                    primary: true,
                    action: function() {
                        e.result.resolve();
                    }
                },
                { text: "Cancel" }
            ],
            close: function() {
                this.destroy();
            }
        };

        var dialog = $("<div></div>").kendoDialog(dialogOptions)
                                     .data("kendoDialog");

        kendo.bind($(dialog.element), e.viewModel);

        dialog.open();
    },
    _exportReport: function(e) {
        kendo.prompt(kendo.template($("#rm-export-prompt-template").html()))
             .then(function(exportName) {
                 window.location.replace(kendo.format("api/DynamicReporting/ExportReport?UserName={0}&ReportName={1}&ExportName={2}",
                     e.report.owner,
                     e.report.name,
                     exportName));
             });
    },
    _focus: function (e, property) {
        setTimeout(function () {
            switch (property) {
            case "filters":
                $("#r-properties-scrollable").animate({ scrollTop: $("#r-properties-scrollable").height() });
                break;
            }
        });
    },
    _importReport: function(e) {
        var dialogOptions = {
            title: "Import Report",
            closable: false,
            modal: true,
            content: kendo.template($("#ir-window-template").html()),
            width: 500,
            actions: [
                { text: "Cancel" }
            ],
            close: function() {
                this.destroy();
            }
        };

        var dialog = $("<div></div>").kendoDialog(dialogOptions)
                                     .data("kendoDialog");

        var handler = null;
        
        handler = function() {
            dialog.close();

            if (handler !== null) {
                e.viewModel.unbind("upload", handler);
                e.result.resolve();
            }
        };

        e.viewModel.bind("upload", handler);
        
        kendo.bind($(dialog.element), e.viewModel);

        dialog.open();

        $("#ir-name").focus();
    },
    _isBusyChanged: function(e) {
        if (e.isBusy) {
            $("#r-panel a").attr("disabled", "disabled");
            $("#r-panel input").prop("disabled", true);
            $("#r-panel textarea").prop("disabled", true);
            $("#r-panel label").attr("disabled", "disabled");
            $("#r-panel td").attr("disabled", "disabled");
        }
        else{
            $("#r-panel a").removeAttr("disabled");
            $("#r-panel input").prop("disabled", false);
            $("#r-panel textarea").prop("disabled", false);
            $("#r-panel label").removeAttr("disabled");
            $("#r-panel td").removeAttr("disabled");
        }
    },
    _openReport: function(e) {
        var that   = this;
        var window = that._reportWindow(e.report, e.isOwner);

        window.title(e.report.name);
        window.maximize();
        window.open();

        var saveHandler = $.proxy(function() {
            that._reportSave(window, e.report);
        }, that);

        var exportHandler = $.proxy(function(handler) {
            that._exportReport(handler);
        });

        var closeHandler = null;
        
        closeHandler = $.proxy(function() {
            that._reportWindowClose(window, e.report, saveHandler, exportHandler);
            window.unbind("close", closeHandler);
        }, that);

        e.report.bind("busy", that._isBusyChanged); 
        e.report.bind("save", saveHandler);
        e.report.bind("filter", that._reportFilter);
        e.report.bind("export", exportHandler);

        window.bind("close", closeHandler);
    },
    _collapsePanel: function(e) {
        var splitter = $("#r-report").data("kendoSplitter");

        splitter.collapse(".k-pane:first");
    },
    _reportFilter: function(e) {
        var dialogOptions = {
            title: kendo.format("{0} Filter", e.viewModel.field.name),
            closable: false,
            modal: true,
            content: kendo.template($("#r-filter-prompt-template").html()),
            actions: [
                {
                    text: "OK",
                    primary: true,
                    action: function() {
                        e.result.resolve();
                    }
                },
                { text: "Cancel" }
            ],
            close: function() {
                this.destroy();
            }
        };

        var dialog = $("<div></div>").kendoDialog(dialogOptions)
                                     .data("kendoDialog");

        kendo.bind($(dialog.element), e.viewModel);

        dialog.open();
    },
    _reportSave: function(window, report) {
        this.viewModel.updateTile(report);

        window.title(report.currentName);
    },
    _reportWindow: function(report, isOwner) {
        var windowOptions = {
            width: "1024px",
            height: "720px",
            visible: false,
            modal: true,
            content: {
                template: kendo.template($("#r-template").html())
            },
            actions: [
                "Maximize",
                "Close"
            ]
        };

        var splitterOptions = {
            panes: [
                { collapsed: !isOwner, collapsible: isOwner, size: "325px", min: "325px" },
                { collapsible: false }
            ],
            orientation: "horizontal"
        };

        var windowElement   = $("<div id='r-window'></div>");
        var window          = windowElement.kendoWindow(windowOptions).data("kendoWindow");

        var splitterElement = $("#r-report");
        var splitter        = splitterElement.kendoSplitter(splitterOptions).data("kendoSplitter");

        $("#r-panel-collapse").on("click", this._collapsePanel);

        kendo.bind($("#r-report"), report);

        return window;
    },
    _reportWindowClose: function(window, report, saveHandler, exportHandler) {
        $("#r-panel-collapse").off("click", this._collapsePanel);
        
        report.unbind("export", exportHandler);
        report.unbind("save", saveHandler);

        window.destroy();
    },
    _shareReport: function(e) {
        var dialogOptions = {
            title: "Share Report",
            closable: false,
            modal: true,
            content: kendo.template($("#sr-window-template").html()),
            width: 500,
            actions: [
                {
                    text: "OK",
                    primary: true,
                    action: function() {
                        e.result.resolve();
                    }
                },
                { text: "Cancel" }
            ],
            close: function() {
                this.destroy();
            }
        };

        var dialog = $("<div></div>").kendoDialog(dialogOptions)
                                     .data("kendoDialog");

        kendo.bind($(dialog.element), e.viewModel);

        dialog.open();
    },
    _toggleCard: function(e) {
        var card = $(e.target).parents(".r-card")[0];
        var body = $(card).find(".r-card-body")[0];

        if ($(body).is(":visible")) {
            $(body).fadeOut(225);
        } else {
            $(body).fadeIn(225);
        }
    },
    _ui: function() {
        $("body").kendoTooltip({ filter: "a[title]:not(a[title='']), span[title]:not(span[title=''])", position: "top" });
    }
});