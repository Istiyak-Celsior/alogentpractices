(function (window, $, kendo, undefined) {

    if (!kendo.mvvm) {
        kendo.mvvm = {};
    }

    kendo.mvvm.Model = kendo.data.Model.extend({
        init: function () {
            kendo.data.Model.fn.init.call(this);
        }
    });
    
    kendo.mvvm.View = kendo.Class.extend({
        init: function (element, viewModel) {
            var that = this;
    
            that.viewModel = viewModel;
    
            $(document).ready($.proxy(that._ready, that, $(element), viewModel));
        },
        _ready: function(element, viewModel) {
            $("[data-role='pageload']").remove();
             
            kendo.ui.progress(element, true);
    
            this.ready(element, viewModel);
        },
        ready: function (element, viewModel) {
            kendo.bind(element, viewModel);
            kendo.ui.progress(element, false);
        }
    });
    
    kendo.mvvm.ViewModel = kendo.data.ObservableObject.extend({
        init: function() {
            kendo.data.ObservableObject.fn.init.call(this, this);
        }
    });
    
    kendo.mvvm.DialogViewModel = kendo.mvvm.ViewModel.extend({
        init: function() {
            ViewModel.fn.init.call(this);
        },
        triggerClose: function(userTriggered, dialogResult) {
            this.trigger("close", { userTriggered: userTriggered, dialogResult: dialogResult });
        }
    });

    kendo.mvvm.DialogService = kendo.Class.extend({
        init: function (views) {
            this.views = views;
        },
        hasDialogOpen: false,
        views: {},
        open: function(view, options) {
            if (!view) throw "Required [view] is missing.";

            var dialogResult  = new $.Deferred();
            var dialogElement = $("<div class='k-custom-dialog' />").kendoDialog({
                actions: options.actions,
                close: function () {
                    this.destroy();
                }
            });

            var dialogView         = this.views[view];
            var template           = dialogView.id;
            var dialogTemplateDOM  = $(template).html();
            var dialog             = dialogElement.data("kendoDialog");
            var dialogTemplate     = $(kendo.template(dialogTemplateDOM)(options.viewModel));

            dialog.content(dialogTemplate);

            if (dialogView.cssClass) {                
                let rootElement = dialog.element.closest(".k-dialog");

                $(rootElement).addClass(dialogView.cssClass);
            }

            if (dialogView.cssContentClass) {
                let contentElement = dialogElement;
                
                $(contentElement).addClass(dialogView.cssContentClass);
            }

            dialog.bind("close", function(e) {
                if (dialogResult.state() !== "resolved") {
                    dialogResult.resolve({userTriggered: e.userTriggered, dialogResult: null});
                };
            });

            if (options.viewModel) {                
                kendo.bind(dialogTemplate, options.viewModel);

                if (options.viewModel instanceof kendo.mvvm.DialogViewModel) {
                    options.viewModel.bind("close", function(e) {
                        dialogResult.resolve({userTriggered: e.userTriggered, dialogResult: e.dialogResult});    
                        dialog.close();                
                    });
                }
            }

            if (options.title) {
                dialog.title(options.title);
            }

            dialog.open();

            this.hasDialogOpen = true;

            if (options.opened) {
                $.proxy(options.opened(), this);
            }

            var promise = dialogResult.promise();
            var that    = this;

            promise.always(function () {
                that.hasDialogOpen = false;
            });

            return promise;
        }
    });
    
    // Plugs for backwards compatibility until we can refactor all the JS
    // bundles and files to switch to the new namespace.
    window.Model     = kendo.mvvm.Model;
    window.ViewModel = kendo.mvvm.ViewModel;
    window.View      = kendo.mvvm.View;

})(window, window.kendo.jQuery, window.kendo);
(function ($, kendo, undefined) {

    kendo.data.ObservableGridColumn = kendo.data.ObservableObject.extend({
       init: function(field) {
           kendo.data.ObservableObject.fn.init.call(this, this);
    
           this.set("field", field);
       },
       expandedField: undefined,
       field: undefined,
       title: undefined,
       hidden: false,
       format: undefined,
       filterable: false,
       template: undefined,
       width: 150
    });

    // One-way binding for kendo.ui.Grid
    // autoBind must be turned off on the grid if this binding is used
    // because it calls setOptions which destroys and recreates the grid,
    kendo.data.binders.widget.grid.columns = kendo.data.Binder.extend({
        init: function (widget, bindings, options) {
            kendo.data.Binder.fn.init.call(this, widget.element[0], bindings, options);

            this._options();

            this._columnResize  = $.proxy(this.columnResize, this);
            this._columnShow    = $.proxy(this.columnShow, this);
            this._columnHide    = $.proxy(this.columnHide, this);
            this._columnReorder = $.proxy(this.columnReorder, this);
            this._columnChange  = $.proxy(this.columnChange, this);
            
            widget.bind("columnResize", this._columnResize);
            widget.bind("columnShow", this._columnShow);
            widget.bind("columnHide", this._columnHide);
            widget.bind("columnReorder", this._columnReorder);

            this.widget      = widget;
            this._initChange = false;
        },
        change: function (e, action) {
            this._initChange = true;

            var that    = this;
            var grid    = $(that.element).data("kendoGrid");
            var binding = that.bindings["columns"];

            if (binding.source.columns) {                
                switch (action) {
                    case "reorder":
                        if (that.columnFill) {
                            that._moveColumnFill();
                        }
                        break;
                }

                var columns = that._cloneArray(grid.columns);
                
                if (binding.get() instanceof kendo.data.ObservableArray) {
                    columns = new kendo.data.ObservableArray(columns);
                }

                if (action === "reorder") {
                    that._moveArrayItem(columns, e.oldIndex, e.newIndex);
                }

                if (this.columnFill) {
                    that._removeColumnFill(columns);
                }

                binding.source.set("columns", columns);
            }

            this._initChange = false;
        },
        columnChange: function (e) {
            if (e.action === "itemchange") {
                this.change(e);
            }
        },
        columnFill: false,
        columnResize: function (e) {
            this.change(e);
        },
        columnShow: function (e) {
            this.change(e);
        },
        columnHide: function (e) {
            this.change(e);
        },
        columnReorder: function (e) {
            this.change(e, "reorder");
        },
        destroy: function() {
            this.widget.unbind("columnResize", this._columnResize);
            this.widget.unbind("columnShow", this._columnShow);
            this.widget.unbind("columnHide", this._columnHide);
            this.widget.unbind("columnReorder", this._columnReorder);
        },
        refresh: function () {
            if (this._initChange) {
                return;
            }

            var grid         = $(this.element).data("kendoGrid");
            var binding      = this.bindings["columns"];
            var value        = binding.get();
            var columns      = (value instanceof kendo.data.ObservableArray) ? value.toJSON() : value;

            if (this.columnFill) {
                this._addColumnFill(columns);
            }
            
            if (grid._refreshOptions !== undefined && grid._refreshOptions === false) {
                grid._refreshOptions = true;

                grid.setOptions({columns: columns});
                
                grid._refreshOptions = false;
            }

            if (grid._refreshOptions === undefined) {
                grid.setOptions({columns: columns});
                grid._refreshOptions = false;
            }
        },
        _cloneArray: function (arr) {
            var columns = [];

            $.each(arr, function (i, column) {
                columns.push({
                    field: column.field,
                    hidden: column.hidden,
                    template: column.template,
                    filterable: column.filterable,
                    format: column.format,
                    width: column.width,
                    title: column.title
                });
            });

            return columns;
        },
        _moveArrayItem: function(arr, fromIndex, toIndex) {
           var element = arr[fromIndex];
           arr.splice(fromIndex, 1);
           arr.splice(toIndex, 0, element);
        },
        _moveColumnFill: function () {
            var grid  = $(this.element).data("kendoGrid");
            
            var emptyColumn;

            $.each(grid.columns, function (i, column) {
                if (column.field === "") {
                    emptyColumn = column;
                }
            });

            setTimeout(function () {
                grid.reorderColumn(grid.columns.length - 1, emptyColumn);
            }, 0);
        },
        _options: function () {
            this.columnFill = $(this.element).data("columnFill") === true;
        },
        _addColumnFill: function (columns) {            
            // Add empty column to avoid KendoUI Grid column width side effects.
            // See Kendo Reference https://docs.telerik.com/kendo-ui/web/grid/appearance#column-widths
            var lastColumn = new kendo.data.ObservableGridColumn("");
            
            lastColumn.width = undefined;
            
            columns.push(lastColumn.toJSON());
        },
        _removeColumnFill: function (columns) {
            $.each(columns, function (i, column) {
                if (column.field === "") {
                    columns.splice(i, 1);
                    return false;
                }
            });
            return true;
        }
    });
})(window.kendo.jQuery, window.kendo);
var CopyReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(manager, service, report, user) {
            ViewModel.fn.init.call(this);

            this.manager           = manager;
            this.service           = service;
            this.report            = report;
            this.user              = user;
            this.report            = report;
        },
        errorMessage: "",
        isBusy: false,
        isValid: function() {
            return this.newReportName.length > 0;
        },
        newReportName: "",
        reportDescription: undefined,
        reportName: undefined,
        reportOwner: undefined,
        user: undefined,
        copy: function() {
            var that    = this;
            var request = that.service.copyReport(that.user, that.report.owner, that.report.name, that.newReportName);

            request.fail(function(e) {
                that.set("errorMessage", e.responseJSON.ErrorMessage);
            });

            return request;
        }
    });
})(window.kendo.jQuery);
var DateRangeFilterViewModel = (function ($, undefined) {
    return ViewModel.extend({
        /*
         * Filter Types
         *   0 - Date Range
         *   1 - Relative Range
         * Relative Types
         *   0 - Last N Day(s)
         *   1 - Next N Day(s)
         *
         * As dictated by the DTO structure of the service layer classes.
         */

        init: function (name, field) {
            ViewModel.fn.init.call(this);

            this.field = field;
            this.name  = name;
            this.type  = "DateRange";
        },
        field: undefined,
        fromDate: null,
        toDate: null,
        type: undefined,
        filterType: 0,
        isRelative: function() {
            return this.get("filterType") == 1; // Used == instead of === because kendo data-type for strongly-typed bindings isn't working - instead of setting an integer it is setting a string
        },
        isDate: function() {
            return this.get("filterType") == 0; // Used == instead of === because kendo data-type for strongly-typed bindings isn't working - instead of setting an integer it is setting a string
        },
        name: undefined,
        relativeValue: null,
        relativeType: 0
    });
})(window.kendo.jQuery);
var ReportService = (function () {
    return kendo.Class.extend({
        init: function (api) {
            this.api = api;
        },
        api: undefined,
        copyReport: function (user, owner, reportName, newReportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "CopyReport",
                username: user,
                data: {
                    Owner: owner,
                    ReportName: reportName,
                    NewReportName: newReportName
                }
            });
        },
        createReport: function (user, template, reportName, description) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "CreateReport",
                username: user,
                data: { Template: template, User: user, Name: reportName, Description: description }
            });
        },
        deleteReport: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "DeleteReport",
                username: user,
                data: { Name: reportName }
            });
        },
        emailReport: function (user, reportName, message, users) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "EmailReport",
                username: user,
                data: { User: user, ReportName: reportName, Users: users, Message: message }
            });
        },
        getData: function (user, reportName, fields, filters, options) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportData",
                username: user,
                data: {
                    Fields: fields,
                    Skip: options.skip,
                    Take: options.take,
                    User: user,
                    ReportName: reportName,
                    Filters: filters
                }
            });
        },
        getReportTemplate: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportTemplate",
                username: user,
                data: { User: user, ReportName: reportName }
            });
        },
        getReportDefinition: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportDefinition",
                username: user,
                data: { User: user, ReportName: reportName }
            });
        },
        getReportFilterData: function (user, reportName, field) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportFilterData",
                data: {
                    User: user,
                    ReportName: reportName,
                    FieldName: field
                }
            });
        },
        getReportTemplates: function (user) {
            return this.api.get({
                controller: "DynamicReporting",
                action: "GetTemplates",
                username: user
            });
        },
        getReportList: function (user) {
            return this.api.get({
                controller: "DynamicReporting",
                action: "GetUserReportList",
                username: user
            });
        },
        getSharedUsers: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetSharedUsers",
                data: {
                    UserName: user,
                    ReportName: reportName
                }
            });
        },
        getUsers: function (user) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetUsers",
                data: {
                    UserName: user
                }
            });
        },
        getUserPermissions: function (user) {
            return this.api.get({
                controller: "DynamicReporting",
                action: "GetUserPermissions",
                username: user
            });
        },
        shareReport: function (user, reportName, isShared, users) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "ShareReport",
                data: { ReportName: reportName, IsShared: isShared, Users: users },
                username: user
            });
        },
        updateReport: function (user, originalReportName, reportName, description, fields, groups, filters) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "UpdateReport",
                username: user,
                data: {
                    ReportName: originalReportName,
                    NewReportName: reportName,
                    Description: description,
                    Fields: fields,
                    Groups: groups,
                    Filters: filters
                }
            });
        }
    });
})();
var EmailReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user, report) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;
            this.report  = report;

            this.set("users", this._dataSource());
        },
        message: undefined,
        user: undefined,
        users: undefined,
        selectedUsers: [],
        showDialog: undefined,
        _dataSource: function() {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: {
                        url: that.report.isSharedBankwide ? "api/DynamicReporting/GetUsers" : "api/DynamicReporting/GetSharedUsers",
                        type: "POST"
                    },
                    parameterMap: function(data, type) {
                        if (that.report.isSharedBankwide) {
                            return {
                                UserName: that.user
                            }
                        } else {
                            return {
                                UserName: that.user,
                                ReportName: that.report.name
                            }
                        }
                    }
                },
                schema: {
                    data: function(response) {
                        return that._users(response.Users);
                    }
                },
                group: {
                    field: "group"
                }
            });
        },
        _getFullName: function(user) {
            if ((user.FirstName == null || user.FirstName.length === 0) && (user.LastName == null || user.LastName.length === 0)) {
                return null;
            }

            if (user.LastName == null || user.LastName.length < 1) {
                return user.FirstName;
            }
            else if (user.FirstName == null || user.FirstName.length < 1) {
                return user.LastName;
            } 
            else {
                return user.FirstName + " " + user.LastName;
            }
        },
        _getGroup: function(user) {
            return user.LastName === undefined || user.LastName.length === 0 ? "" : user.LastName[0].toLowerCase();
        },
        _getLabel: function(user) {
            var label = this._getFullName(user);

            // No first or last name
            if (label === null) {
                if (user.Email == null) {
                    return user.UserName;
                } else {
                    return user.Email + " (" + user.UserName + ")";
                }
            }
        
            // Has a name part
            if (user.Email === undefined || user.Email.length === 0) {
                return label + " (" + user.UserName + ")";
            }

            return label + " (" + user.Email + ")";
        },
        _users: function(users) {
            var that  = this;
            var array = new kendo.data.ObservableArray([]);

            $.each(users, function(i, dataItem) {
                array.push({
                    userName: dataItem.UserName,
                    fullName: that._getFullName(dataItem),
                    email: dataItem.Email,
                    label: that._getLabel(dataItem),
                    group: that._getGroup(dataItem)
                });
            });

            return array;
        }
    });
})(window.kendo.jQuery);
var FilterViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(api, field) {
            ViewModel.fn.init.call(this);

            this.api      = api;
            this.field    = field;
            this.options  = this._options();

            this.set("selectedOption", { value: "Search" });
        },
        isDateRangeSelected: function() {
            return this.get("selectedOption").value === "DateRange";
        },
        isSearchSelected: function() {
            return this.get("selectedOption").value === "Search";
        },
        isMultiSelected: function() {
            return this.get("selectedOption").value === "Multi";
        },
        options: undefined,
        selectedOption: null,
        _options: function() {
            var options = new kendo.data.ObservableArray([
                { name: "Search", value: "Search" },
                { name: "Multi-select List", value: "Multi" }
            ]);

            if (this.field.type === "DateTime") {
                options.push({ name: "Date Range", value: "DateRange" });
            }

            return options;
        }
    });
})(window.kendo.jQuery);
var FilterSerializer = (function () {
    return kendo.Class.extend({
        init: function (filters) {
            this.serialize(filters);
        },
        serialize: function (filters) {
            var obj = {
                SearchFilters: [],
                MultiFilters: [],
                DateFilters: [],
                DateRangeFilters: []
            };

            $.each(filters, function (i, filter) {
                switch (filter.type) {
                    case "DateRange":
                        var dateRangeFilter = {
                            Field: filter.field,
                            FromDate: filter.fromDate,
                            ToDate: filter.toDate,
                            FilterType: filter.filterType,
                            RelativeType: filter.relativeType,
                            RelativeValue: filter.relativeValue
                        };
                        obj.DateRangeFilters.push(dateRangeFilter);
                        break;
                    case "Search":
                        var searchFilter = {
                            Field: filter.field,
                            Operator: filter.operator,
                            Value: filter.value
                        };
                        obj.SearchFilters.push(searchFilter);
                        break;
                    case "Multi":
                        var multiFilter = {
                            Field: filter.field,
                            Values: []
                        };

                        $.each(filter.items,
                            function (i, item) {
                                if (typeof MultiFilterEditViewModel !== "undefined" && filter instanceof MultiFilterEditViewModel) {
                                    if (item.isSelected === true) {
                                        multiFilter.Values.push(item.value);
                                    }
                                }
                                else if (filter instanceof MultiFilterViewModel) {
                                    multiFilter.Values.push(item.value);
                                }
                            });

                        obj.MultiFilters.push(multiFilter);
                        break;
                }
            });
            return obj;
        }
    });
})();
var ImportReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;
        },
        user: undefined,
        canUpload: function() {
            return this.get("name").length > 0;
        },
        onError: function(e) {
            var errors = this.get("errors");

            errors.splice(0, errors.length);

            var error = JSON.parse(e.XMLHttpRequest.response);

            errors.push(error.ErrorMessage);

            this.set("hasError", true);
        },
        onSuccess: function(e) {
            var errors = this.get("errors");

            errors.splice(0, errors.length);

            if (!e.response.Success) {
                $.each(e.response.Errors, function(i, error) {
                    errors.push(error);
                });

                this.set("hasError", true);
            } 
            else {
                this.set("hasError", false);
                this.trigger("upload");
            }
        },
        onUpload: function(e) {
            var that = this;
            var xhr  = e.XMLHttpRequest;

            xhr.addEventListener("readystatechange", function(e) {
                if (xhr.readyState === 1 /* OPENED */) {
                    xhr.setRequestHeader("x-accuaccount-username", that.user);
                    xhr.setRequestHeader("x-accuaccount-reportname", that.name);
                }
            });
        },
        errors: [],
        hasError: false,
        name: ""
    });
})(window.kendo.jQuery);
var MultiFilterViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, field) {
            ViewModel.fn.init.call(this);

            this.name = name;
            this.field = field;
        },
        add: function (value) {
            this.items.push(kendo.observable({
                 value: value
            }));
        },
        field: undefined,
        items: [],
        name: undefined,
        type: "Multi"
    });
})(window.kendo.jQuery);
var MultiFilterEditViewModel = (function ($, undefined) {
    return MultiFilterViewModel.extend({
        init: function (name, field) {
            MultiFilterViewModel.fn.init.call(this, name, field);
        },
        add: function (value) {
            this.items.push(kendo.observable({
                value: value,
                isSelected: false
            }));
        },
        limit: 500,
        exceedsLimit: function () {
            return this.get("items").length >= this.limit;
        },
        isBusy: false,
        selectValue: function (value) {
            $.each(this.items, function (i, item) {
                if (item.value === value) {
                    item.set("isSelected", true);
                    return false;
                }
            });
        }
    });
})(window.kendo.jQuery);
var NewReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;

            this.set("templates", this._templates());
        },
        create: function() {
            var that    = this;
            var request = that.service.createReport(that.user, that.selectedTemplate.name, that.name, that.description);

            request.done(function(response) {
                that.set("errors", []);
                that.set("hasErrors", false);

                if (response.Errors.length > 0) {
                    that.set("hasErrors", true);

                    $.each(response.Errors, function(i, error) {
                        that.errors.push(error);
                    });
                } 
                else {
                    that.set("result", "created");
                    that.set("hasErrors", false);
                }
            });

            return request;
        },
        description: "",
        errors: new kendo.data.ObservableArray([]),
        hasErrors: false,
        name: "",
        resizeWindow: undefined,
        result: "none",
        selectedTemplate: undefined,
        templates: undefined,
        user: undefined, 
        _templates: function() {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        var response = that.service.getReportTemplates(that.user);

                        response.done(function(e) {
                            options.success(e);
                        });

                        response.fail(function(e) {
                            options.error(e);
                        });
                    }
                },
                schema: {
                    data: function(response) {
                        var templates = [];

                        $.each(response.Templates, function(index, template) {
                            var viewModel;

                            viewModel = new ReportTemplateViewModel(template.Name, template.Description, template.IsLicensed);

                            templates.push(viewModel);
                        });

                        return templates;
                    }
                },
                change: function() {
                    var templates = that.templates.view();

                    if (templates.length > 0) {
                        that.set("selectedTemplate", templates[0]);
                    }
                }
            });
        }
    });
})(window.kendo.jQuery);
var ReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service) {
            ViewModel.fn.init.call(this);
    
            this._service = service;
            this._canRead = true;
        },
        behaviors: new kendo.data.ObservableArray([]),
        columns: [],
        data: undefined,
        filters: [],
        isLicensed: true,
        name: undefined,
        owner: undefined,
        pageSize: 25,
        template: undefined,
        view: function(owner, name) {
            var that = this;
    
            that.set("owner", owner);
            that.set("name", name);

            return $.when(that._service.getReportTemplate(owner, name), that._service.getReportDefinition(owner, name))
                    .then(function(templateResponse, definitionResponse) {
                        return $.proxy(that._initialize, that, templateResponse[0], definitionResponse[0])();
                    });
        },
        _createColumn: function(template, templateField) {
            var that   = this;
            var column = new kendo.data.ObservableGridColumn(templateField.name);

            if (templateField.behaviors.linkBehavior.isSupported && templateField.behaviors.linkBehavior.isEnabled) {
                column.set("field", templateField.name + ".Value");
            }

            column.title     = that._getFieldLabel(template, templateField);
            column.hidden    = false;
            column.format    = that._getColumnFormat(templateField);
            column.template  = that._getColumnTemplate(templateField);

            return column;
        },
        _data: function(template, groupDescriptions, sortDescriptions, pageSize) {
            var that  = this;
            var model = {};
            
            $.each(template, function (i, group) {
                $.each(group.fields, function (j, field) {
                    model[field.name] = {
                         type: that._getFieldType(field)
                    };
                });
            });
    
            return new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        $.proxy(that._read, that)(options);
                    }
                },
                schema: {
                    data: "Data",
                    total: "Total",
                    model: { fields: model }
                },
                pageSize: pageSize,
                serverGrouping: false,
                serverPaging: true,
                serverFiltering: true,
                serverSorting: true,
                sort: sortDescriptions,
                group: groupDescriptions
            });
        },
        _getColumnName: function(column) {
            if (column.indexOf(".") > -1) {
                return column.substr(0, column.indexOf("."));
            } else {
                return column;
            }
        },
        _getColumn: function(fieldName) {
            var foundColumn;
            var that = this;

            $.each(this.columns, function(i, column) {
                if (that._getColumnName(column.field) === that._getColumnName(fieldName)) {
                    foundColumn = column;
                    return false;
                }
                return true;
            });

            return foundColumn;
        },
        _getColumnFormat: function(templateField) {
            switch (templateField.type) {
                case "DateTime": return "{0:MM/dd/yyyy hh:mm:ss tt}";
                case "Money": return "{0:c2}";
                default: return undefined;
            }
        },
        _getColumns: function(template, selectedFields) {
            var that    = this;
            var columns = [];
            var fields  = [];

            $.each(template, function (i, group) {
                $.each(group.fields, function(j, field) {
                    fields.push(field);
                });
            });

            $.each(selectedFields, function(i, selectedField) {
                $.each(fields, function(j, field) {
                    if (selectedField.name === field.name) {
                        var column = that._createColumn(template, field);

                        column.width = selectedField.width;

                        columns.splice(i, 0, column);

                        return false;
                    }
                });
            });

            return columns;
        },
        _getColumnTemplate: function (templateField) {
            if (templateField.behaviors.linkBehavior.isSupported) {
                if (templateField.behaviors.linkBehavior.isEnabled) {
                    return "<a href='#= " + templateField.name + ".Link #'><span data-bind='text: " + templateField.name + ".Value'></span></a>";
                } else {
                    return undefined;
                }
            } else {
                switch (templateField.type) {
                case "True/False":
                    return "#= " + templateField.name + ' == true ? "Y" : "N"#';
                default:
                    return undefined;
                }
            }
        },
        _getDateRangeFilters: function(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field  = that._getTemplateField(template, value.Field);
                var label  = that._getFieldLabel(template, field);
                var filter = new DateRangeFilterViewModel(label, value.Field);

                filter.set("fromDate", value.FromDate);
                filter.set("toDate", value.ToDate);
                filter.set("filterType", value.FilterType);
                filter.set("relativeType", value.RelativeType);
                filter.set("relativeValue", value.RelativeValue);

                filters.push(filter);
            });

            return filters;
        },
        _getFields: function(Fields) {
            var fields = [];
    
            $.each(Fields, function (key, value) {
                var field = new ReportField(value.Name, value.SortOrder, value.SortDirection, value.Width);

                field.behaviors.linkBehavior = value.Behaviors.LinkBehavior;

                fields.push(field);
            });
    
            return fields;
        },
        _getFieldType: function(field) {
            if (field.behaviors.linkBehavior.isSupported && field.behaviors.linkBehavior.isEnabled) {
                return "object";
            }

            switch (field.type) {
                case "True/False": return "boolean";
                case "DateTime":   return "date";
                case "Money":      return "number";
                case "Number":     return "number";
                default:           return "string";
            }
        },
        _getFilters: function(template, Filters) {
            var searchFilters = this._getSearchFilters(template, Filters.SearchFilters);
            var dateFilters   = this._getDateRangeFilters(template, Filters.DateRangeFilters);
            var multiFilters  = this._getMultiFilters(template, Filters.MultiFilters);

            return [].concat.apply([], [searchFilters, dateFilters, multiFilters]);
        },
        _getFieldLabel: function(template, field) {
            var label = field.label;

            $.each(template, function(i, currentGroup) {
                $.each(currentGroup.fields, function(j, currentField) {
                    if (field.group !== currentGroup.name && field.label === currentField.label) {
                        label = field.label + " (" + field.group + ")";
                    }
                });
            });

            return label;
        },
        _getGroups: function(Groups) {
            var groups = [];
    
            $.each(Groups, function (key, value) {
                groups.push({ field: value.Name, dir: value.SortDirection === 1 ? "desc" : "asc" });
            });
    
            return groups;
        },
        _getMultiFilterPromise: function (MultiFilters, multifilter) {
            $.each(MultiFilters, function (i, Filter) {
                if (Filter.Field === multifilter.field) {
                    $.each(Filter.Values, function (j, serverValue) {
                        multifilter.add(serverValue);
                    });
                }
            });

            return new $.Deferred().resolve();
        },
        _getMultiFilters: function loadMultiFilters(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field     = that._getTemplateField(template, value.Field);
                var label     = that._getFieldLabel(that.template, field);
                var viewModel = new MultiFilterViewModel(label, field.name);

                filters.push(viewModel);
            });

            return filters;
        },
        _getSearchFilters: function(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field  = that._getTemplateField(template, value.Field);
                var label  = that._getFieldLabel(template, field);
                var filter = new SearchFilterViewModel(label, value.Field, field.type);
    
                filter.set("operator", value.Operator);
                filter.set("value", value.Value);

                filters.push(filter);
            });

            return filters;
        },
        _getSortDescriptions: function(template, fields) {
            var descriptions = [];
            var that = this;

            var array = fields.sort(function(x, y) {
                return ((x.sortOrder < y.sortOrder) ? -1 : ((x.sortOrder > y.sortOrder) ? 1 : 0));
            });

            $.each(array, function(i, field) {
                if (field.sortOrder !== -1) {
                    var templateField = that._getTemplateField(template, field.name);
                    var columnName;

                    if (templateField.behaviors.linkBehavior.isSupported === true && templateField.behaviors.linkBehavior.isEnabled) {
                        columnName = kendo.format("{0}.Value", field.name);
                    } else {
                        columnName = field.name;
                    }

                    descriptions.push({ field: columnName, dir: field.sortDirection === 1 ? "desc" : "asc" });

                }
            });

            return descriptions;
        },
        _getSortDirection: function(direction) {
            switch (direction) {
                case 0:
                    return "asc";
                case 1:
                    return "desc";
                default:
                    return "asc";
            }
        },
        _getSortDirectionInt: function(direction) {
            switch (direction) {
                case "asc":
                    return 0;
                case "desc":
                    return 1;
                default:
                    return -1;
            }
        },
        _getTemplate: function (Template, selectedFields) {
            var template = [];

            $.each(Template, function (i, templateGroup) {
                var group = new ReportTemplateGroupViewModel(templateGroup.Name);

                $.each(templateGroup.Fields, function (j, field) {
                    var templateField = new ReportTemplateFieldViewModel(group.name, field.Name, field.Label, field.Type);

                    templateField.behaviors.linkBehavior.set("isSupported", field.Behaviors.LinkBehavior);

                    $.each(selectedFields, function (k, selectedField) {
                        if (selectedField.name === field.Name) {
                            templateField.set("checked", true);

                            if (templateField.behaviors.linkBehavior.isSupported === true && selectedField.behaviors.linkBehavior !== null) {
                                templateField.behaviors.linkBehavior.set("isEnabled", true);
                            } else {
                                templateField.behaviors.linkBehavior.set("isEnabled", false);
                            }
                        }
                    });

                    group.fields.push(templateField);
                });

                template.push(group);
            });

            return template;
        },
        _getTemplateField: function(template, name) {
            var value;

            $.each(template, function (i, group) {
                $.each(group.fields, function(j, field) {
                    if (field.name === name) {
                        value = field;
                        return false;
                    }
                });

                if (value) {
                    return false;
                }
            });

            return value;
        },
        _initialize: function(Template, Definition) {
            var that             = this;
            var groups           = that._getGroups(Definition.Groups);
            var fields           = that._getFields(Definition.Fields);
            var template         = that._getTemplate(Template.Groups, fields);
            var columns          = new kendo.data.ObservableArray(that._getColumns(template, fields));
            var sortDescriptions = that._getSortDescriptions(template, fields);

            that.set("template", template);
            that.set("data", this._data(template, groups, sortDescriptions, that.pageSize));
            that.set("columns", columns);
            that.set("filters", that._getFilters(that.template, Definition.Filters));
            that.set("isLicensed", Template.IsLicensed);

            var filterPromises = [];
    
            $.each(that.filters, function(i, filter) {
                if (filter.type === "Multi") {
                    filterPromises.push(that._getMultiFilterPromise(Definition.Filters.MultiFilters, filter));
                }
            });

            var deferred = new $.Deferred();

            $.when.apply($, filterPromises)
                  .then(function() {
                      deferred.resolve();
                  });

            return deferred;
        },
        _read: function(options) {
            if (this._canRead === false) {
                return options.success([]);
            }
            var that = this;

            var filterSerializer = new FilterSerializer();
            var filters          = filterSerializer.serialize(that.filters);
            var fields           = that._serializeColumns(that.columns, options.data.sort);

            var api = that._service.getData(that.owner, that.name, fields, filters, options.data);

            api.fail(function (result) {
                options.error(result);
            });

            api.done(function (result) {
                options.success(result);
            });
        },
        _serializeBehaviors: function (templateField) {
            var behaviors = {
                linkBehavior: null
            };

            if (templateField.behaviors.linkBehavior.isSupported === true && templateField.behaviors.linkBehavior.isEnabled === true) {
                behaviors.linkBehavior = {};
            }
        
            return behaviors;
        },
        _serializeColumns: function (columns, sorts) {
            var fields = [];
            var that   = this;

            $.each(columns, function(i, column) {
                var field = new ReportField(column.field, -1, -1, column.width);

                $.each(that.template, function(i, templateGroup) {
                    $.each(templateGroup.fields, function(j, templateField) {
                        var columnName = that._getColumnName(column.field);

                        if (templateField.name === columnName) {
                            if (templateField.behaviors.linkBehavior.isSupported === true && templateField.behaviors.linkBehavior.isEnabled === true) {
                                field.name      = columnName;
                                field.behaviors = that._serializeBehaviors(templateField);
                            }
                        }
                    });
                });

                fields.push(field);
            });

            var order  = 0;

            $.each(sorts, function(i, sort) {
                $.each(fields, function(j, field) {
                    var columnName = that._getColumnName(sort.field);

                    if (columnName === field.name) {
                        switch (sort.dir) {
                            case "asc":
                                field.sortDirection = 0;
                                break;
                            case "desc":
                                field.sortDirection = 1;
                                break;
                        }

                        field.sortOrder = ++order;

                        return false;
                    }

                    return true;
                });

                return true;
            });

            return fields;
        },
        _service: undefined
    });
})(window.kendo.jQuery);
var ReportEditorViewModel = (function($, undefined) {
    var SAVE = "save";

    return ReportViewModel.extend({
        init: function(service, isOwner, description, canExport) {
            ReportViewModel.fn.init.call(this, service);

            this.set("description", description);
            this.set("isShared", !isOwner);
            this.set("pageSize", 100);

            this.canExport(canExport);
        },
        canExport: function(value) {
            if (value !== undefined) {
                this._canExport = value && this.get("isLicensed");
            }
            else {
                return this._canExport && this.get("isLicensed");
            }
        },
        currentName: undefined,
        description: undefined,
        editFilter: function(e) {
            var that = this;

            e.stopPropagation();

            if (that.isBusy) {
                return;
            }

            var field     = e.data;
            var result    = new $.Deferred();
            var viewModel = new FilterViewModel(that._service, field);
            var args      = { viewModel: viewModel, result: result, filter: undefined };

            that.trigger("filter", args);

            result.then(function() {
                var filter      = undefined;
                var filterLabel = that._getFieldLabel(that.template, field);

                switch (viewModel.selectedOption.value) {
                    case "DateRange":
                        filter = new DateRangeFilterViewModel(filterLabel, field.name);
                        break;
                    case "Search":
                        filter = new SearchFilterViewModel(filterLabel, field.name, field.type);
                        filter.set("value", "");
                        break;
                    case "Multi":
                        filter = new MultiFilterEditViewModel(filterLabel, field.name);
                        that._getMultiFilterItems(that._service, that.owner, that.name, filter);
                        break;
                }

                that.filters.push(filter);
            });
        },
        error: undefined,
        exportData: function(e) {
            var that = this;

            e.stopPropagation();

            that.save()
                .done(function() {
                    that.trigger("export", { report: that });
                });
        },
        _getMultiFilterItems: function (service, user, reportName, filter) {
            var that = this;

            that.set("isBusy", true);
            that.set("items", []);

            var request = service.getReportFilterData(user, reportName, filter.field);

            request.done(function (e) {
                var items = [];
                var set = {};

                $.each(e.Data, function (i, dataItem) {
                    if (!dataItem.Value) {
                        dataItem.Value = "";
                    }

                    set[dataItem.Value] = dataItem;
                });

                $.each(set, function (i, member) {
                    items.push(member);
                });

                items.sort(function (x, y) {
                    return x.Value.localeCompare(y.Value);
                });

                $.each(items, function (j, item) {
                    filter.add(item.Value);
                });
            });

            request.always(function () {
                that.set("isBusy", false);
            });

            return request;
        },
        _getMultiFilters: function loadMultiFilters(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field     = that._getTemplateField(template, value.Field);
                var label     = that._getFieldLabel(that.template, field);
                var viewModel = new MultiFilterEditViewModel(label, field.name);

                filters.push(viewModel);
            });

            return filters;
        },
        _getMultiFilterPromise: function (MultiFilters, multifilter) {
            var that = this;

            return that._getMultiFilterItems(that._service, that.owner, that.name, multifilter)
                .then(function () {
                    $.each(MultiFilters, function (i, Filter) {
                        if (Filter.Field === multifilter.field) {
                            $.each(Filter.Values, function (j, serverValue) {
                                multifilter.selectValue(serverValue);
                            });
                        }
                    });
                });
        },
        hasError: false,
        hasColumns: function() {
            var columns = this.get("columns");

            var visibleColumns = $.grep(columns, function(column) {
                return column.hidden === false && column.field !== "";
            });

            return visibleColumns.length > 0;
        },
        hasFilters: function() {
            return this.get("filters").length > 0;
        },
        isBusy: false,
        isShared: undefined,
        view: function(owner, name) {
            var that = this;

            that.set("currentName", name);

            return ReportViewModel.fn
                                  .view
                                  .call(that, owner, name)
                                  .done(function() {
                                      that.refresh();
                                  });
        },
        refresh: function() {
            var that = this;

            that._toggleIsBusy(true);

            if (!that.hasColumns()) {
                that._toggleIsBusy(false);
                return null;
            }

            var request = that.data.fetch();

            request.done(function(e) {
                that._hideError();
            });

            request.fail(function(e) {
                that._showError(e.responseJSON.ErrorMessage);
            });

            request.always(function() {
                setTimeout(function() {
                    that._toggleIsBusy(false);
                });
            });

            return request;
        },
        removeFilter: function(e) {
            var that = this;

            var index = that.filters.indexOf(e.data);

            that.filters.splice(index, 1);
        },
        save: function() {
            var that = this;

            that._toggleIsBusy(true);

            var groups                = that._serializeGroups(that.data.group());
            var fieldSortDescriptions = that.data.sort();
            var fields                = that._serializeColumns(that.columns, fieldSortDescriptions);
            var filterSerializer      = new FilterSerializer();
            var filters               = filterSerializer.serialize(that.filters);

            var request = that._service
                              .updateReport(that.owner,
                                            that.name,
                                            that.currentName,
                                            that.description,
                                            fields,
                                            groups,
                                            filters);

            request.fail(function(e) {
                that._showError(e.responseJSON.ErrorMessage);
            });

            request.done(function(e) {
                that._hideError();

                that.trigger(SAVE, that);

                that.set("name", that.currentName);
            });

            request.always(function() {
                setTimeout(function() {
                    that._toggleIsBusy(false);
                },
                25);
            });

            return request;
        },
        toggleColumn: function(e) {
            var that = this;

            that._toggleIsBusy(true);

            if (e.data.checked) {
                that._showColumn(e.data.name);
            } else {
                that._hideColumn(e.data.name);
            }

            if (!that.hasColumns()) {
                that.data.data([]);
                that._toggleIsBusy(false);
                return;
            }

            var isSorted = that._isColumnSorted(e.data.name);

            if (e.data.checked || !isSorted) {
                that.refresh();
            }
            else {
                that.data.sort(that._removeColumnSortConfiguration(e.data.name));
            }

            that._toggleIsBusy(false);
        },
        toggleBehavior: function (e) {
            var that = this;

            that._toggleIsBusy(true);

            var behaviorType = e.target.dataset.behaviortype;

            switch (behaviorType) {
                case "link":
                    that._toggleLinkBehavior(e.data, e.data.behaviors.linkBehavior, that.data);
                    break;
            }

            that.refresh()
                .done(function () {
                    that._toggleIsBusy(false);
                });
        },
        _getDataSourceGroup: function(groups, columnName) {
            var group;

            $.each(groups, function(i, datasourceGroup) {
                if (datasourceGroup.field === columnName) {
                    group = datasourceGroup;
                    return false;
                }
                return true;
            });

            return group;
        },
        _hideColumn: function(name) {
            var that   = this;
            var column = that._getColumn(name);

            if (column) {
                that._canRead = false;

                that._ungroupColumn(column.field);

                that._canRead = true;

                var index = that.columns.indexOf(column);

                that.columns.splice(index, 1);
            }
        },
        _hideError: function() {
            var that = this;

            that.set("hasError", false);
            that.set("error", "");
        },
        _isColumnSorted: function(column) {
            var that = this;

            var sortConfiguration = that.data.sort();

            if (sortConfiguration == null || sortConfiguration.length === 0) {
                return false;
            }

            var isColumnSorted = false;

            for (var i = 0; i < sortConfiguration.length; i++) {
                if (sortConfiguration[i].field.toLowerCase() === column.toLowerCase()) {
                    isColumnSorted = true;
                    break;
                }
            }

            return isColumnSorted;
        },
        _removeColumnSortConfiguration: function(column) {
            var sort  = this.data.sort();
            var index = -1;

            for (var i = 0; i < sort.length; i++) {
                if (sort[i].field.toLowerCase() === column.toLowerCase()) {
                    index = i;
                    break;
                }
            }

            if (index !== -1) {
                sort.splice(index, 1);
            }

            return sort;
        },
        _serializeGroups: function(groupDescriptors) {
            var groups = [];

            $.each(groupDescriptors, function(i, gridGroup) {
                var dir;

                switch (gridGroup.dir) {
                    case "asc":
                        dir = 0;
                        break;
                    case "desc":
                        dir = 1;
                        break;
                    default:
                        dir = -1;
                        break;
                }

                groups.push(new ReportGroup(gridGroup.field, dir));
            });

            return groups;
        },
        _showColumn: function(name) {
            var that = this;

            var templateField = that._getTemplateField(that.template, name);
            var column        = that._createColumn(that.template, templateField);

            that.columns.push(column);
        },
        _showError: function(error) {
            var that = this;

            that.set("hasError", true);
            that.set("error", error);
        },
        _toggleIsBusy: function(isBusy) {
            this.set("isBusy", isBusy);
            this.trigger("busy", { isBusy: this.get("isBusy") });
        },
        _disableLinkBehavior: function(templateField, column, datasource) {
            var that    = this;
            var options = datasource.options;

            options.group = datasource.group();

            var group = that._getDataSourceGroup(options.group, kendo.format("{0}.Value", templateField.name));

            if (group) {
                group.field = templateField.name;
            }

            options.schema.model.fields[templateField.name] = {
                type: "string"
            };

            that.set("data", new kendo.data.DataSource(options));

            column.set("field", templateField.name);
        },
        _enableLinkBehavior: function(templateField, column, datasource) {
            var that    = this;
            var options = datasource.options;

            options.group = datasource.group();

            var group = that._getDataSourceGroup(options.group, templateField.name);

            if (group) {
                group.field = kendo.format("{0}.Value", templateField.name);
            }

            options.schema.model.fields[templateField.name] = {
                type: "object"
            };

            that.set("data", new kendo.data.DataSource(options));

            column.set("field", kendo.format("{0}.Value", templateField.name));
        },
        _toggleLinkBehavior: function(templateField, behavior, datasource) {
            var that = this;
            var column;

            if (behavior.isEnabled === true) {
                column = that._getColumn(kendo.format("{0}.Value", templateField.name));

                that._disableLinkBehavior(templateField, column, datasource);
            }
            else {
                column = that._getColumn(templateField.name);

                that._enableLinkBehavior(templateField, column, datasource);
            }

            behavior.set("isEnabled", !behavior.isEnabled);

            var columnTemplate = that._getColumnTemplate(templateField);

            column.set("template", columnTemplate);
        },
        _ungroupColumn: function(columnName) {
            var that       = this;
            var datasource = this.data;
            var groups     = datasource.group();
            var group      = that._getDataSourceGroup(datasource.group(), columnName);

            if (group) {
                var index = groups.indexOf(group);

                groups.splice(index, 1);

                datasource.group(groups);
            }
        }
    });
})(window.kendo.jQuery);
var ReportField = kendo.Class.extend({
    init: function(name, sortOrder, sortDirection, width) {
        this.name          = name;
        this.sortOrder     = sortOrder;
        this.sortDirection = sortDirection;
        this.width         = Math.floor(width);
        this.behaviors = {
            linkBehavior: null
        }
    },
    name: undefined,
    sortOrder: undefined,
    sortDirection: undefined,
    width: undefined,
    behaviors: undefined
});
var ReportGroup = (function () {
    return kendo.Class.extend({
        init: function (name, sortDirection) {
            this.name = name;
            this.sortDirection = sortDirection;
        },
        name: undefined,
        sortDirection: undefined
    });
})();
var ReportBehavior = kendo.data.Model.extend({
    init: function (id, field) {
        kendo.data.Model.fn.init.call(this);

        this.id    = id;
        this.field = field
    },
    id: undefined,
    field : undefined
});
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
var ReportTemplateFieldBehaviorViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function() {
            ViewModel.fn.init.call(this);
        },
        isAvailable: false,
        isEnabled: false,
        isSupported: false
    });
})(window.kendo.jQuery);
var ReportTemplateFieldViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function(group, name, label, type) {
            ViewModel.fn.init.call(this);

            this.group = group;
            this.name  = name;
            this.label = label;
            this.type  = type;

            this.set("behaviors", new kendo.data.ObservableObject({
                linkBehavior: new ReportTemplateFieldBehaviorViewModel()
            }));
            
            this.bind("change", this._change);
        },
        group: undefined,
        name: undefined,
        label: undefined,
        type: undefined,
        checked: undefined,
        behaviors: undefined,
        _change: function(e) {
            if (e.field === "checked") {
                this.behaviors.linkBehavior.set("isAvailable", this.checked === true && this.behaviors.linkBehavior.isSupported === true);
            }
        }
    });
})(window.kendo.jQuery);
var ReportTemplateGroupViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, fields) {
            ViewModel.fn.init.call(this);

            this.name   = name;
            this.fields = [];
        },
        name: undefined,
        fields: undefined
    });
})(window.kendo.jQuery);
var ReportTemplateViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, description, isPurchased) {
            ViewModel.fn.init.call(this);

            this.name        = name;
            this.description = description;
            this.isPurchased = isPurchased;
        },
        name: undefined,
        description: undefined,
        isPurchased: undefined
    });
})(window.kendo.jQuery);
var ReportTileViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, description, owner, isOwned, isShared, isSharedBankwide, isPurchased, userCanExport, userCanShare, userCanCreate, userCanSendMail) {
            ViewModel.fn.init.call(this);

            this.description      = description;
            this.name             = name;
            this.isBusy           = false;
            this.isOwned          = isOwned;
            this.isShared         = isShared;
            this.isSharedBankwide = isSharedBankwide;
            this.owner            = owner;
            this.isPurchased      = isPurchased;
            this.userCanCreate    = userCanCreate;
            this.userCanExport    = userCanExport;
            this.userCanShare     = userCanShare;
            this.userCanSendMail  = userCanSendMail;
        },
        description: undefined,
        name: undefined,
        isBusy: undefined,
        isOwned: undefined,
        isShared: undefined,
        isSharedBankwide: undefined,
        owner: undefined,
        isPurchased: undefined,
        canCopy: function () {
            return this.get("isPurchased") && this.get("userCanCreate") && !this.get("isBusy");
        },
        canEmail: function () {
            if (!this.get("userCanSendMail")) {
                return false;
            }
            return this.get("isPurchased") && this.get("userCanShare") && !this.get("isBusy");
        },
        canExport: function () {
            return this.get("isPurchased") && this.get("userCanExport") && !this.get("isBusy");
        },
        canDownload: function () {
            return this.get("isPurchased") && this.get("userCanCreate") && !this.get("isBusy");
        },
        canShare: function () {
            return this.get("isPurchased") && this.get("userCanShare") && !this.get("isBusy");
        },
        userCanCreate: undefined,
        userCanExport: undefined,
        userCanShare: undefined,
        userCanSendMail: undefined
    });
})(window.kendo.jQuery);
var SearchFilterViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, field, type) {
            ViewModel.fn.init.call(this);

            this.field     = field;
            this.fieldType = type;
            this.name      = name;

            this.value     = this.getDefaultValue(type);
            this.operators = this.getOperators(type);
            this.operator  = this.getDefaultOperator(type);
        },
        field: undefined,
        fieldType: undefined,
        getDefaultOperator: function (fieldType) {
            switch (fieldType) {
                case "Text":
                    return "Contains";
                default:
                    return "=";
            }
        },
        getDefaultValue: function (fieldType) {
            switch (fieldType) {
                case "True/False":
                    return "True";
                default:
                    return null;
            }
        },
        getOperators: function (fieldType) {
            switch (fieldType) {
                case "True/False":
                    return ["="];
                case "Text":
                    return ["Starts With", "Contains", "Ends With", "="];
                default:
                    return ["<", "<=", "=", ">", ">="];
            }
        },
        name: undefined,
        operator: undefined,
        operators: undefined,
        type: "Search",
        value: undefined
    });
})(window.kendo.jQuery);
var ShareReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user, report, isSharedBankwide) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;
            this.report  = report;
            
            this.set("users", this._dataSource());
        },
        _dataSource: function() {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "api/DynamicReporting/GetUsers",
                        type: "POST"
                    },
                    parameterMap: function(data, type) {
                        return { UserName: that.user };
                    }
                },
                schema: {
                    data: function(response) {
                        return that._users(response.Users);
                    }
                },
                group: {
                    field: "group"
                }
            });
        },
        isSharedBankwide: undefined,
        user: undefined,
        users: undefined,
        select: function(users, bankwide) {
            this.set("selectedUsers", this._users(users));
            this.set("isSharedBankwide", bankwide);
        },
        selectedUsers: [],
        showDialog: undefined,
        _getFullName: function(user) {
            if ((user.FirstName == null || user.FirstName.length === 0) && (user.LastName == null || user.LastName.length === 0)) {
                return null;
            }

            if (user.LastName == null || user.LastName.length < 1) {
                return user.FirstName;
            }
            else if (user.FirstName == null || user.FirstName.length < 1) {
                return user.LastName;
            } 
            else {
                return user.FirstName + " " + user.LastName;
            }
        },
        _getGroup: function(user) {
            return user.LastName === undefined || user.LastName.length === 0 ? "" : user.LastName[0].toLowerCase();
        },
        _getLabel: function(user) {
            var label = this._getFullName(user);

            // No first or last name
            if (label === null) {
                if (user.Email == null) {
                    return user.UserName;
                } else {
                    return user.Email + " (" + user.UserName + ")";
                }
            }
        
            // Has a name part
            if (user.Email === undefined || user.Email.length === 0) {
                return label + " (" + user.UserName + ")";
            }

            return label + " (" + user.Email + ")";
        },
        _users: function(users) {
            var that  = this;
            var array = new kendo.data.ObservableArray([]);

            $.each(users, function(i, dataItem) {
                var sharedUser = {
                    userName: dataItem.UserName,
                    fullName: that._getFullName(dataItem),
                    email: dataItem.Email,
                    label: that._getLabel(dataItem),
                    group: that._getGroup(dataItem)
                };

                array.push(sharedUser);
            });

            return array;
        }
    });
})(window.kendo.jQuery);
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