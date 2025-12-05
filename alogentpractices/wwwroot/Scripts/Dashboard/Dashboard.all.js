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
// kendo.ui.Dashboard
// 
// Configuration
//    autoBind
//    template
//    widgetList : array
//    widgetList.content
//    widgetList.content.name
//    widgetList.content.template
//    widgetList.title
//    widgetList.title.template
//    widgetList.title.text
//    widgetList.cssClass
//    widgetList.popout
//    widgetList.popout.appendTo
//    widgetList.popout.cssClass
//    widgetList.popout.template
//    dataSizeXField
//    dataSizeYField
//    dataRowField
//    dataColField
//    widgetFailedTemplate
//    widgetMisconfiguredTemplate
//
// Fields
//
//    element   
//
// Methods
//
//     addWidget
//     dataItem
//     edit
//     endEdit
//     nextPosition
//     refresh
//     refreshWidget
//     setWidgetState
//     save
//
// Events
//
//     change
//         e.action
//             add
//             itemchange
//             remove
//             resize
//     dataBinding
//     dataBound
//     drag
//     save

(function($, kendo, undefined) {
    var CHANGE       = "change",
        DATABINDING  = "dataBinding",
        DATABOUND    = "dataBound",
        DRAG         = "drag",
        ITEMCHANGE   = "itemChange",
        RESIZE       = "resize",
        SAVE         = "save",
        WIDGET_X     = "data-gs-x",
        WIDGET_Y     = "data-gs-y",
        WIDGET_W     = "data-gs-width",
        WIDGET_H     = "data-gs-height";

    var Dashboard = kendo.ui.Widget.extend({  
        init: function(element, options) {
            var that = this;

            kendo.ui.Widget.fn.init.call(that, element, options);
            
            that._templates();

            that._widgetList();

            that._gridstack();
            
            that._dataSource();

            kendo.notify(that);
        },
        events: [
            CHANGE,
            DATABINDING,
            DATABOUND,
            DRAG,
            ITEMCHANGE,
            SAVE
        ],
        options: {
            name: "Dashboard",
            autoBind: true,
            template: "",
            widgetList: [],
            dataSizeXField: "",
            dataSizeYField: "",
            dataRowField: "",
            dataColField: "",
            widgetFailedTemplate: "",
            widgetMisconfiguredTemplate: ""
        },
        _templates: function() {
            var options = this.options;

            this.template                    = kendo.template(options.template || "<div class='grid-stack grid-stack-8'></div>");
            this.widgetFailedTemplate        = kendo.template(options.widgetFailedTemplate || "");
            this.widgetMisconfiguredTemplate = kendo.template(options.widgetMisconfiguredTemplate || "");
        },
        _dataSource: function() {
            var that = this;

            if (that.dataSource && that._refreshHandler) {
                that.dataSource.unbind(CHANGE, that._refreshHandler);
            } 
            else {
                that._refreshHandler = $.proxy(that._refresh, that);
            }

            that.dataSource = kendo.data.DataSource.create(that.options.dataSource);

            that.dataSource.bind(CHANGE, that._refreshHandler);

            if (that.options.autoBind) {
                that.dataSource.fetch();
            }
        },
        addWidget: function(dataItem) {
            var nextPosition = this.nextPosition(dataItem.sizeX, dataItem.sizeY);

            if (!nextPosition) {
                return false;
            }
            else {
                dataItem.positionX = nextPosition.col;
                dataItem.positionY = nextPosition.row;
                dataItem.sizeX     = nextPosition.size_x;
                dataItem.sizeY     = nextPosition.size_y;
            }

            this.dataSource.add(dataItem);

            return true;
        },
        dataItem: function(element) {
            var uid = element.attr(kendo.attr('uid'));
            
            return this.dataSource.getByUid(uid);
        },
        edit: function() {
            var that = this;

            $(that.element).addClass("k-state-edit");

            var items = that.items();

            $.each(items, function(i, item) {
                $(item).addClass("k-state-edit");
            });

            that._gridstack.enable();
        },
        endEdit: function() {
            var that = this;

            $(that.element).removeClass("k-state-edit");

            var items = that.items();

            $.each(items, function(i, item) {
                $(item).removeClass("k-state-edit");

                if ($(that.element).hasClass("k-state-ready") && !$(that.element).hasClass("k-state-edit")) {
                    $(that.element).removeClass("k-state-ready");
                }
            });
 
            that._gridstack.disable();
        },
        items: function() {
            return $(this.element).find(".k-dashboard-widget");
        },
        nextPosition: function(sizeX, sizeY) {
            var position = this._gridstack.willItFit(0, 0, sizeX, sizeY, true);

            if (!position) {
                return false;
            }

            return {
                positionX: position.col,
                positionY: position.row,
                sizeX: position.size_x,
                sizeY: position.size_y
            };
        },
        refresh: function () {
            this._refresh({action:undefined});
        },
        refreshWidget: function(dataItem) {
            var that = this;

            that._refreshWidget(dataItem)
                .done(function (widget) {
                    that.trigger(ITEMCHANGE, { item: widget, data:  dataItem });
                });
        },
        save: function() {
            var that  = this;
            var items = that.items();

            $.each(items, function(i, item){
               var widget       = $(item).data("widget");

               widget.positionX = parseInt($(item).attr(WIDGET_X)) + 1;
               widget.positionY = parseInt($(item).attr(WIDGET_Y)) + 1;
               widget.sizeX     = parseInt($(item).attr(WIDGET_W));
               widget.sizeY     = parseInt($(item).attr(WIDGET_H));
            });

            that.trigger(SAVE);
        },
        setDataSource: function(dataSource) {
            this.options.dataSource = dataSource;
            this._dataSource();
        },
        setWidgetState: function (dataItem, state, message) {
            var widget = this._getWidget(dataItem);

            switch (state) {
                case "normal":
                    widget.removeClass("k-state-failed");
                    widget.removeClass("k-state-misconfigured");
                    widget.addClass("k-state-normal");
                    break;
                case "misconfigured":
                    widget.removeClass("k-state-normal");
                    widget.removeClass("k-state-failed");
                    widget.addClass("k-state-misconfigured");
                    break;
                case "error":
                    widget.removeClass("k-state-normal");
                    widget.removeClass("k-state-misconfigured");
                    widget.addClass("k-state-failed");
                    console.log(message);
                    break;
            }
        },
        widget: function (dataItem) {
            return this._getWidget(dataItem);
        },
        _addWidget: function(dataItem) {
            var that = this;
            
            var widgetOption = that.widgetList.find(function(option) {
                return dataItem.widget === option.name;
            });

            if (!widgetOption) {
                widgetOption = {
                    name: dataItem.widget
                };
            }
            
            if (widgetOption) {
                var isEdit    = $(that.element).hasClass("k-state-edit");
                var widgetDOM = that._renderItem(widgetOption.name, widgetOption.title, widgetOption.content, widgetOption.edit, dataItem, widgetOption.commands, widgetOption.popout);
                var widget;

                if (dataItem.positionX && dataItem.positionY) {
                    widget = $(that._gridstack.addWidget(widgetDOM, {x: dataItem.positionX - 1, y: dataItem.positionY - 1, width: dataItem.sizeX, height: dataItem.sizeY, noResize: !isEdit, noMove: !isEdit }));
                }
                else {
                    widget = $(that._gridstack.addWidget(widgetDOM, {x: 0, y: 0, width: dataItem.sizeX, height: dataItem.sizeY, autoPosition: true, noResize: !isEdit, noMove: !isEdit}));
                }
           
                widget.data("widget", dataItem);

                if (isEdit) {
                    widget.addClass("k-state-edit");
                }

                if (widgetOption.cssClass) {
                    $(widget).addClass(widgetOption.cssClass);
                }

                $(widget).addClass("k-state-ready");
                
                $(widget).find(".k-dashboard-widget-header .k-dashboard-widget-command.remove").on("click", function() {
                     that.dataSource.remove(dataItem);
                });
    
                $(widget).find(".k-dashboard-widget-header .k-dashboard-widget-command.refresh").on("click", function() {
                    if (dataItem.refresh && widgetOption.content.template) {
                        dataItem.refresh();
                    }
                    else {
                        that.refreshWidget(dataItem);
                    }
                });

                $(widget).find(".k-dashboard-widget-header .k-dashboard-widget-command.expand[title='Popout']").on("click", function () {
                    that._popoutDataItem(dataItem, widgetOption.content, widgetOption.popout);
                });

                // If no template is specified, we assume this is a url
                if (widgetOption.content && !widgetOption.content.template) {
                    return that._renderAjax(dataItem, widget, widgetOption.content);
                }

                if (!widgetOption.content) {
                    that.setWidgetState(dataItem, "error", kendo.format("Widget '{0}' is not recognized.", widgetOption.name));
                }
               
                return $.Deferred().resolve(widget).promise();
            }
        },
        _getWidget: function (dataItem) {
            var widget;

            $.each(this.items(), function(i, item) {
                if ($(item).data("uid") == dataItem.uid) {
                    widget = $(item);
                    return false;
                }     
            });

            if (!widget) {
                return null;
            }

            return widget;
        },
        _getWidgetBody: function (widget) {
            return widget.find(".k-dashboard-widget-body");
        },
        _gridstack: function() {
            var that        = this;
            var html        = that.template({});
            var gridElement = $(html);

            $(that.element).html(gridElement);

            that._gridstack = GridStack.init({
                disableOneColumnMode: true,
                float: true,
                cellHeight: 100,
                maxRow: 8,
                maxCol: 8,
                column: 8,
                row: 8,
                verticalMargin: 0,
                handleClass: "k-dashboard-widget-header"
            }, $(gridElement));

            that._gridstack.disable();
            that._gridstack.on("dragstart", $.proxy(that._gridstack_drag, that));
            that._gridstack.on("dragstop", $.proxy(that._gridstack_drag, that));
            that._gridstack.on("resizestart", $.proxy(that._gridstack_resize, that));
            that._gridstack.on("resizestop", $.proxy(that._gridstack_resize, that));
        },
        _gridstack_drag: function(e, ui, scope) {
            var widget   = $(ui.element);
            var dataItem = this.dataItem(widget);

            this.trigger(CHANGE, { action: "drag", widget: widget.eq(0), data: dataItem });
        },
        _gridstack_resize: function(e, ui, scope) {
            var widget   = $(ui.element);
            var dataItem = this.dataItem(widget);

            this.trigger(CHANGE, { action: "resize", item: widget.eq(0), data: dataItem });
        },
        _popoutDataItem: function(dataItem, content, popoutOptions) {
            var that     = this; 

            var template = popoutOptions.template ? kendo.template($("#" + popoutOptions.template).html()) 
                                                  : kendo.template($("#" + content.template).html());

            var html     = template(dataItem);           
            var element  = $("<div></div>");
            var options  = this._popoutOptions(element, dataItem, popoutOptions);
            var popout   = element.kendoWindow(options)
                                  .data("kendoWindow");

            $(popout.wrapper).addClass("dashboard-popout");

            if (popoutOptions.cssClass) {
                $(popout.wrapper).addClass(popoutOptions.cssClass);
            }

            popout.content(html);

            if (!popoutOptions.appendTo) {
                popout.center();
            }

            that.bind(DATABOUND, function () {
                popout.close();
            });
            
            popout.open();
        },
        _popoutOptions: function (element, dataItem, popoutOptions) {
            var that    = this;
            var options = {
                title: dataItem.widget,
                modal: false,
                animation: {
                    close: false
                },
                open: function() {
                    kendo.bind(element, dataItem);
                    that.trigger("popoutOpen", {modal: options.modal, dataItem: dataItem});
                },
                close: function() {
                    this.destroy();
                    that.trigger("popoutClose", {modal: options.modal, dataItem: dataItem});
                }
            };

            if (popoutOptions.appendTo == null) {
                options.modal     = true;
                options.resizable = true;
                options.draggable = true;
                options.actions   = ["Maximize", "Close"];
                
                if (popoutOptions.width) {
                    options.width = popoutOptions.width;
                }

                if (popoutOptions.height) {
                    options.height = popoutOptions.height;
                }
            }
            else if (popoutOptions.appendTo) {
                var width  = "calc(100% - 24px)";
                
                options.scrollable = false;
                options.resizable  = false;
                options.draggable  = false;
                options.appendTo   = popoutOptions.appendTo;
                options.width      = width;
                options.actions    = ["Close"];
            }

            return options;
        },
        _refresh: function(e) {
            var that = this;

            // NOTE: This is required by kendo custom widgets to unbind anything already bound prior to
            //       DOM recreation and binding again, but I found that in some controls like Kendo TreeView
            //       they do not call it at all, but make use of itemChange. This seems to resolve issues
            //       when items are added dynamically and prevents binding from happening too many items across
            //       different items, but does not appear typical for a UI component.
            // that.trigger(DATABINDING);

            switch (e.action) {
                case undefined:
                    that._gridstack.removeAll();

                    // NOTE: Only called for the initial binding when the data source is initially
                    //       changed, then ITEMCHANGE handles future binding concerns.
                    that.trigger(DATABOUND);

                    $.each(that.dataSource !== null ? that.dataSource.view() : [], function(i, dataItem) {
                        that._addWidget(dataItem)
                            .done(function (widget) {
                                that.trigger(ITEMCHANGE, { item: widget.eq(0), data: dataItem });
                            });
                    });

                    break;
                case "add":
                    $.each(e.items, function(i, dataItem) {
                        that._addWidget(dataItem)
                            .done(function (widget) {
                                that.trigger(ITEMCHANGE, { item: widget.eq(0), data: dataItem });
                            });
                    });
                    break;
                case "remove":
                    $.each(e.items, function(i, dataItem) {
                        var widget = that._getWidget(dataItem);

                        that.trigger(ITEMCHANGE, { item: widget.eq(0), data: dataItem });
                        
                        that._removeWidget(dataItem);  
                    });
                    break;
            }
        },
        _refreshWidget: function(dataItem) {
            var that   = this;
            var widget = that._getWidget(dataItem);

            var widgetOption = that.widgetList.find(function(option) {
                return dataItem.widget === option.name;
            });

            if (!widgetOption.content.template) {
                return that._renderAjax(dataItem, widget, widgetOption.content);           
            }

            return $.Deferred().resolve(widget).promise();
        },
        _removeWidget: function(dataItem) {
            var that = this;
            var removedWidget;

            $.each(this.items(), function(i, widget) {
                var widgetData = $(widget).data("widget");

                if (dataItem === widgetData) {
                    kendo.unbind(widget);
                    that._gridstack.removeWidget($(widget));
                    removedWidget = widget;
                    return false;
                }
            });

            return $(removedWidget);
        },
        _renderItem: function(name, title, content, edit, data, commands, popoutOptions) {
            var item      = "";

            item += "<div class='k-dashboard-widget k-state-normal grid-stack-item' data-uid='#:uid#'>";
            item += "    <div class='k-dashboard-widget-content grid-stack-item-content'>";
            item += "        <div class='k-dashboard-widget-header clearfix'>";
            item += "            <span class='pull-left'>";

            if (title && title.template) {
                item += kendo.template($("#" + title.template).html())(data);
            }
            else if (title && title.text) {
                item += title.text;
            }
            else {
                item += name;
            }

            item += "            </span>";
            item += "            <div class='pull-right'>";
            item += "                <span class='k-dashboard-widget-commands'>";

            if (commands || popoutOptions) {
                item += this._renderItemCommands(name, commands, data, content, popoutOptions);
            }

            item += "                    <span class='k-dashboard-widget-command refresh fas fa-sync fa-fw' title='Refresh'></span>";
            item += "                </span>";
            item += "                <span class='k-dashboard-widget-command remove fas fa-times-circle fa-fw' title='Remove'></span>";
            item += "            </div>";
            item += "        </div>";
            item += "        <div class='k-dashboard-widget-body'>";
            item += "            <div class='k-state-normal'>";
 
            if (content && content.template) {
                item += kendo.template($("#" + content.template).html() || "")(data);
            }

            item += "            </div>";
                                 
            item += "            <div class='k-state-failed'>";
            item +=                  this.widgetFailedTemplate(data);
            item += "            </div>";
                                 
            item += "            <div class='k-state-misconfigured'>";
            item +=                  this.widgetMisconfiguredTemplate(data);
            item += "            </div>";

            if (edit && edit.template) {
                item += "        <div class='k-state-edit'>";
                item += "            <h3>Widget Options</h3>";
                item +=              kendo.template($("#" + edit.template).html())(data);
                item += "        </div>";
            }

            item += "        </div>";
            item += "    </div>";
            item += "</div>";

            return kendo.template(item)(data);
        },
        _renderItemCommand: function (command) {
            var that = this;
            var item = $("<span class='k-dashboard-widget-command'></span>");

            if (command.click) {
                item.attr("data-bind", kendo.format("click: {0}", command.click));
            }
            
            if (command.iconClass) {
                item.addClass(command.iconClass);
            }
            
            if (command.title) {
                item.attr("title", command.title);
            }

            return item[0].outerHTML;
        },
        _renderItemCommands: function (name, commands, dataItem, content, popoutOptions) {
            var that = this;
            var html = "";

            if (popoutOptions) {
                if (!content.template) {
                    throw kendo.format("Popout options are not supported for widget {0} with ajax content.", name);
                }

                html += that._renderItemCommand({
                    title: "Popout",
                    iconClass: "expand fas fa-expand-alt fa-fw"
                });
            }

            $.each(commands, function (i, command) {
                html += that._renderItemCommand(command, dataItem);
            });

            return html;
        },
        _renderAjax: function(dataItem, widget, uri) {
            var that = this;
            var body = $(widget).find(".k-dashboard-widget-body .k-state-normal");

            kendo.ui.progress($(body), true);

            var promise = $.Deferred();
            var get = $.get({
                url: uri,
                cache: false,
                success: function(e) {
                    that.template = e;
                
                    var html    = that.template;
                    var content = $(html);
                
                    body.html(content);

                    that.setWidgetState(dataItem, "normal");

                    promise.resolve(widget);
                }
            });  

            get.fail(function(e) {
                kendo.ui.progress($(body), false);
                that.setWidgetState(dataItem, "error", e.responseText);
            });

            return promise.promise();
        },
        _widgetList: function() {
            var options = this.options;

            this.widgetList = options.widgetList || [];
        }
    });

    kendo.ui.plugin(Dashboard);

    $.fn.extend({
        Dashboard: function (options) {
            this.kendoDashboard(options);
        }
    });
})(window.kendo.jQuery, window.kendo);
var ApiService = (function($) {
    var publicApi = {
        authorizationHeader: undefined,
        error: undefined,
        get: undefined,
        post: undefined,
        success: undefined,
        requestStart: undefined,
        requestEnd: undefined
    };

    publicApi.delete = function(options) {
        return _ajax("DELETE", options);
    };

    publicApi.get = function(options) {
        return _ajax("GET", options);
    };

    publicApi.patch = function(options) {
        return _ajax("PATCH", options);
    };

    publicApi.post = function(options) {
        return _ajax("POST", options);
    };

    publicApi.put = function(options) {
        return _ajax("PUT", options);
    };

    function _ajax(method, options) {
        return $.ajax({
            url: _buildUri(options.area, options.controller, options.action),
            method: method,
            cache: false,
            contentType: "application/json",
            data: options.data != undefined ? JSON.stringify(options.data) : undefined,
            beforeSend: function(xhr) {
                if (typeof options.username !== "undefined") {
                    xhr.setRequestHeader('x-accuaccount-username', options.username);
                }

                if (typeof options.password !== "undefined") {
                    xhr.setRequestHeader('x-accuaccount-password', options.password);
                }

                if (publicApi.requestStart) {
                    publicApi.requestStart.bind(publicApi)();
                }
            },
            complete: function(response) {
                if (publicApi.requestEnd) {
                    publicApi.requestEnd.bind(publicApi)();
                }
            },
            success: function(response) {
                if (typeof options.success !== "undefined") {
                    options.success(response);
                }

                if (typeof publicApi.success !== "undefined") {
                    publicApi.success();
                }
            },
            error: function(response) {
                var error = {
                    statusCode: response.status,
                    statusDescription: response.statusText,
                    errorMessage: response.responseJSON != null ? response.responseJSON.ErrorMessage 
                        : "A general failure occurred communicating with the server (status: " + response.statusText + ").",
                    response: response
                };

                if (typeof options.error !== 'undefined') {
                    options.error(error);
                }

                if (typeof publicApi.error !== "undefined") {
                    publicApi.error(error);
                }
            }
        });
    }

    function _buildUri(area, controller, action) {
        var uri = "";

        if (area === null) {
            uri += "api/";
        }
        else if (area === "") {
        }
        else {
	        uri += "api/";
        }

        uri += controller;

        if (action) {
            uri += "/";
            uri += action;
        }

        return uri;
    }

    return publicApi;
});
var ErrorHandler = kendo.Class.extend({
    init: function () {},
    error: function (error) {
        console.log(error.errorMessage);
    },
    success: function () {
    },
    warning: function () {
    }
});
var NotificationErrorHandler = (function($, undefined) {
    return ErrorHandler.extend({
        element: undefined,
        notification: undefined,
        init: function(element) {
            ErrorHandler.fn.init.call(this);

            var appendToElement = $(element);

            this.element = appendToElement;

            appendToElement.addClass("notification-error-handler");

            var notificationElement = $("<div></div>")
                .kendoNotification({
                    appendTo: appendToElement,
                    autoHideAfter: 0,
                    button: true,
                    hideOnClick: false
                });

            this.notification = notificationElement.data("kendoNotification");

            notificationElement.appendTo(appendToElement);
        },
        clear: function() {
            var notifications = this.notification.getNotifications();

            notifications.fadeOut(500,
                function() {
                    notifications.remove();
                });
        },
        error: function(error) {
            ErrorHandler.fn.error.call(this, error);
            this.notification.error(error);
        },
        success: function(success) {
            ErrorHandler.fn.success.call(this);
            this.notification.success(success);
        },
        warning: function(warning) {
            ErrorHandler.fn.warning.call(this);
            this.notification.warning(warning);
        }
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
// https://tc39.github.io/ecma262/#sec-array.prototype.find
if (!Array.prototype.find) {
    Object.defineProperty(Array.prototype, 'find', {
        value: function(predicate) {
            // 1. Let O be ? ToObject(this value).
            if (this == null) {
                throw new TypeError('"this" is null or not defined');
            }

            var o = Object(this);

            // 2. Let len be ? ToLength(? Get(O, "length")).
            var len = o.length >>> 0;

            // 3. If IsCallable(predicate) is false, throw a TypeError exception.
            if (typeof predicate !== 'function') {
                throw new TypeError('predicate must be a function');
            }

            // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
            var thisArg = arguments[1];

            // 5. Let k be 0.
            var k = 0;

            // 6. Repeat, while k < len
            while (k < len) {
                // a. Let Pk be ! ToString(k).
                // b. Let kValue be ? Get(O, Pk).
                // c. Let testResult be ToBoolean(? Call(predicate, T, « kValue, k, O »)).
                // d. If testResult is true, return kValue.
                var kValue = o[k];
                if (predicate.call(thisArg, kValue, k, o)) {
                    return kValue;
                }
                // e. Increase k by 1.
                k++;
            }

            // 7. Return undefined.
            return undefined;
        },
        configurable: true,
        writable: true
    });
}
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
var DashboardView = View.extend({
    init: function (element, viewModel, webapi, service, errorHandler) {        
        View.fn.init.call(this, element, viewModel);
        
        this._webapi = webapi;
        this._service = service;

        this._errorHandler = errorHandler;
    },
    ready: function (element, viewModel) {
        var that = this;

        that._errorHandling(that._webapi, that._errorHandler);

        var promise = that._service.getDashboards(viewModel.user);

        promise.done(function(response) {
            $(".init-hidden").removeClass("init-hidden");

            View.fn.ready.call(that, element, viewModel);

            that._ui(element, viewModel);
            
            that._events(viewModel);

            viewModel.open(response);
        });
    },
    _closeDropDowns: function(e) {
        var dropdownlist = $(e.item).find("*[data-role='dropdownlist']")
                                    .data("kendoDropDownList");

        if (dropdownlist) {
            dropdownlist.close();
        }
    },
    _dashboardChange: function(e){
        var list = $("#dashboard-dropdownlist").data("kendoDropDownList");

        list.trigger("change");
    },
    _drag: function(e) {
        this._closeDropDowns(e);
    },
    _edit: function(e) {
        $("#name-input").css("display", "flex");
        $("#name-input input[type='text']").focus();
        $("#name-input input[type='text']").select();
    },
    _editEnd: function(e) {
        document.getSelection().removeAllRanges();
    },
    _errorHandling: function(webapi, errorHandler) {
        webapi.error = function(e) {
            errorHandler.clear();
            errorHandler.error(e.errorMessage);
        };
    },
    _events: function(viewModel) {
        viewModel.bind("dashboardchange", this._dashboardChange);
        viewModel.bind("edit", this._edit);
        viewModel.bind("editend", this._editEnd);

        viewModel.dashboard.bind("change", $.proxy(this._change, this));
        viewModel.dashboard.bind("popoutOpen", this._popoutOpen);
        viewModel.dashboard.bind("popoutClose", this._popoutClose);
        
        $("#name-input input").on("keyup", $.proxy(this._nameInputKeyUp, this));
    },
    _change: function(e) {
        if (e.action === "resize" || e.action === "drag") {
            this._closeDropDowns(e);
        }
    },
    _nameInputKeyUp: function(e) {
        switch (e.keyCode) {
            case /*ENTER*/ 13:
                this.viewModel.saveDashboard();
                break;
            case /*ESC*/ 27:
                this.viewModel.cancelEditDashboard();
                break;
        }
    },
    _popoutClose: function(e) {
        if (!e.modal) {
            $("#dashboard-container").show();
        }
    },
    _popoutOpen: function(e) {
        if (!e.modal) {
            $("#dashboard-container").hide();
        }
    },
    _ui: function(element, viewModel) {
        var dashboard = $("#dashboard").data("kendoDashboard");

        viewModel.set("dashboard", dashboard);

        element.kendoTooltip({ filter: "a[title]:not(a[title='']), span[title]:not(span[title=''])", position: "top" });
    }
});
var DashboardViewModel = ViewModel.extend({
    init: function(name, id) {      
        ViewModel.fn.init.call(this);  
        this.setName(name);

        if (id) {
            this.set("id", id);
        }
    },
    id: null,
    name: null,
    currentName: null,
    _isNew: false,
    setName: function(name) {
        this.set("name", name);
        this.set("currentName", name);
    }
});
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
var ActiveTasksDashboardWidgetView = (function (viewModel, template) {
    var content = $(template);
    var form    = content.find("#reassign-user-form");
    var title   = content.find("#page-title").val();

    var view = $("<div class='aa-active-task-dashboard-widget'></div>").kendoDialog({
        title: title,
        closable: false,
        modal: true,
        content: content,
        actions: [{
            text: "Update",
            primary: true,
            action: function () {
                var formData = form.serialize();
                viewModel.updateTask($.proxy(view.close, view), formData);
            }
        },
        {
            text: "Cancel"
        }],
        open: function () {
            // Did not use declarative syntax because the content is shared with legacy
            // parts of the system that cannot be data bound.
            $("#assigned-user-id").kendoDropDownList();
        },
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");

    return view;
});
var ExceptionFilterSettingsView = (function(viewModel, template) {
    var content  = $(template);
    var form     = content.find("#active-exception-filter-form");
    var view     = $("<div class='aa-active-exception-filter'></div>").kendoDialog({
        width: "700px",
        title: "Exception Filter Settings",
        closable: false,
        modal: true,
        content: content,
        actions: [{
            text: "Update",
            primary: true,
            action: function () {
                var formData = form.serialize();
                viewModel.updateSettings($.proxy(view.close, view), formData);
            }
        },
        {
            text: "Cancel"
        }],
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");

    return view;
});
var QuickSearchDashboardWidgetViewModel = DashboardWidgetViewModel.extend({
    init: function (dashboard, widget, x, y, width, height, id) {
        DashboardWidgetViewModel.fn.init.call(this, dashboard, widget, x, y, width, height, id);
    },
    customerNames: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=customer&key=customerName&val=customerName',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: "string" }
                }
            }
        }
    }),
    customerNumbers: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=customer&key=customerNumber&val=customerNumber',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: 'string' }
                }
            }
        }
    }),
    taxIds: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=customer&key=taxid&val=taxid',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: 'string' }
                }
            }
        }
    }),
    accountNumbers: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=loan&key=loanNumber&val=loanNumber',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: 'string' }
                }
            }
        }
    })
});
var MyUploadsItemViewModel = ViewModel.extend({
    init: function (widget, name, type, link, size, createdDate) {
        ViewModel.fn.init.call(this);

        this._widget     = widget;
        this.name        = name;
        this.type        = type;
        this.link        = link;
        this.size        = size;
        this.createdDate = createdDate;

    },
    _widget: undefined,
    name: undefined,
    type: undefined,
    link: undefined,
    size: undefined,
    createdDate: undefined
});
var MyUploadsDirectoryViewModel = MyUploadsItemViewModel.extend({
    init: function (widget, name, type, link) {
        MyUploadsItemViewModel.fn.init.call(this, widget, name, type, link);
    },
    open: function () {
        this._widget.openDirectory(this);
    }
});
var MyUploadsFileInfoModel = Model.extend({
    init: function (customerName, customerNumber, customerLink, account, accountType, accountLink, document, comment, expirationDate, uploadSource, uploadUser, fileClass, moveLink, documentGroup, documentTab, authorization) {
        Model.fn.init.call(this);

        this.customerName   = customerName;
        this.customerNumber = customerNumber;
        this.customerLink   = customerLink;
        this.account        = account;
        this.accountType    = accountType;
        this.accountLink    = accountLink;
        this.document       = document;
        this.comment        = comment;
        this.expirationDate = expirationDate;
        this.uploadSource   = uploadSource;
        this.uploadUser     = uploadUser;
        this.fileClass      = fileClass;
        this.moveLink       = moveLink;
        this.documentGroup  = documentGroup;
        this.documentTab    = documentTab;
        this.authorization  = authorization;
    },
    customerName: undefined,
    customerNumber: undefined,
    customerLink: undefined,
    account: undefined,
    accountType: undefined,
    accountLink: undefined,
    document: undefined,
    link: undefined,
    comment: undefined,
    expirationDate: undefined,
    uploadSource: undefined,
    uploadUser: undefined,
    fileClass: undefined,
    moveLink: undefined,
    documentGroup: undefined,
    documentTab: undefined,
    authorization: undefined
});
var MyUploadsFileInfoView = (function (info) {
    return $("<div id=\"document-info-window\"></div>").kendoDialog({
        width: "700px",
        height: "430px",
        closable: false,
        actions: [{
            text: "Close",
            primary: true
        }],
        visible: false,
        content: kendo.template($("#dashboard-myuploads-fingerprinting").html())(info),
        title: "Document Upload Details",
        modal: true,
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");
});
var MyUploadsFileViewModel = MyUploadsItemViewModel.extend({
    init: function (widget, name, type, link, extension, info, size, createdDate) {
        MyUploadsItemViewModel.fn.init.call(this, widget, name, type, link, size, createdDate);

        this._name = name;
        this._size = size;
        this.extension = extension;
        this.info = info;

        this.set("name", this._getName);
        this.set("size", this._getSize());
    },
    _getName: function () {
        if (this.info && this.info.document) {
            return this.info.document;
        }

        return this._name;
    },
    _getSize: function () {
        if (this._size) {
            var calc = Math.floor(Math.log(this._size) / Math.log(1024));

            return (this._size / Math.pow(1024, calc)).toFixed(2) * 1 + " " + ["bytes", "KB", "MB", "GB", "TB"][calc];
        }

        return this._size;
    },
    createdDate: undefined,
    extension: undefined,
    open: function () {
        var that = this;

        $.ajax({
            type: "HEAD",
            url: that.link,
            success: function () {
                var view = new MyUploadsFileView(that);

                view.center()
                    .open();
            },
            error: function () {
                var view = new MyUploadsFileNotFoundView(name);

                view.open();
            }
        });
    },
    info: undefined,
    hasInfo: function () {
        return this.get("info");
    },
    openInfo: function () {
        var info   = this.get("info");
        var dialog = new MyUploadsFileInfoView(info);

        dialog.open();
    },
    beginMove: function () {
        var that = this;

        $.ajax({
            url: that.info.moveLink,
            cache: false,
            success: function (e) {
                var view = new MyUploadsFileMoveView(that, e);

                view.open();
            },
            error: function (e) {
                var view = new MyUploadsFileNotMovedView(that.name());

                view.open();

                console.log(e.responseText);
            }
        });
    },
    endMove: function (formData) {
        var that        = this;
        var uploadParam = that._getUploadDirUrlParam(that.info.moveLink, "uploadDir");

        $.ajax({
            type: "POST",
            url: kendo.format("uploadquickmoveupdate.asp?uploadDir={0}", uploadParam),
            cache: false,
            data: formData,
            success: function () {
                that._refreshUploadWidgets();
            },
            error: function (e) {
                var view = new MyUploadsFileNotMovedView(that.name());

                view.open();

                console.log(e.responseText);
            }
        });
    },
    _getUploadDirUrlParam: function(url, name) {
        var parameters = url.split("&");
        
        for (var i = 0; i < parameters.length; i++) {
            var key = parameters[i].split("=");
        
            if (key[0] === name) {
                return key[1] === undefined ? null : decodeURIComponent(key[1]);
            }
        }

        return null;
    },
    _refreshUploadWidgets: function() {
        var that  = this;
        var items = that._widget.dashboard.dataSource.data();

        $.each(items, function(i, item) {
            if (item.widget === that._widget.widget && item.path === that._widget.path) {
                item.refresh();
            }
        });
    }
});
var MyUploadsFileView = (function(file) {
    var width  = $(window).width() * .85;
    var height = $(window).height() * .85;

    return $("<div></div>").kendoWindow({
        title: (file.info && file.info.document) ? file.info.document : file.name(),
        content: kendo.format("{0}&dispositionType=inline", file.link),
        iframe: true,
        width:  width,
        height: height,
        modal: true,
        actions: [
            "Maximize",
            "Close"
        ]
    }).data("kendoWindow");
});
var MyUploadsFileNotFoundView = (function(name) {
    return $("<div></div>").kendoDialog({
        title: kendo.format("{0} is unavailable", name),
        content: $("#dashboard-myuploads-fileerror").html(),
        width: "520px"
    }).data("kendoDialog");
});
var MyUploadsFileNotMovedView = (function (name) {
    return $("<div></div>").kendoDialog({
        title: kendo.format("{0} failed to move", name),
        content: $("#dashboard-myuploads-moveerror").html(),
        width: "520px"
    }).data("kendoDialog");
});
var MyUploadsWidgetViewModel = DashboardWidgetViewModel.extend({
    init: function(dashboard, widget, x, y, width, height, id, user, userId, options, dashboardId) {
        DashboardWidgetViewModel.fn.init.call(this, dashboard, widget, x, y, width, height, id, options);

        this.user        = user;
        this.userId      = userId;
        this.dashboardId = dashboardId;

        if (options) {
            this.set("options", options);
        } 
        else {
            this.set("options", [{Name: "Path", Value: null}]);
        }

        this.items = this._dataSource(this);
    },
    _dataSource: function (viewModel) {
        var that       = viewModel;
        var pathOption = that.getOption("Path");
        var path       = pathOption && pathOption.Value !== null ? pathOption.Value : that.user;
        var url        = kendo.format("uploads/items?path={0}&userId={1}", path, that.userId);

        var ds = new kendo.data.DataSource({
            transport: {
                read: {
                    url: url,
                    dataType: "json",
                    cache: false
                }
            },
            schema: {
                data: function(response) {
                    return that._getViewModels(response.Items);
                }
            },
            error: function (e) {
                that.dashboard.setWidgetState(that, "error", e.xhr.responseText);
            },
            requestEnd: function (e) {
                if (e.response) {
                    that.dashboard.setWidgetState(that, "normal");
                    that._onRequestEnd(e.response);
                }
            }
        });

        return ds;
    },
    _getViewModels: function(items) {
        var viewModels = [];
        var that = this;

        $.each(items, function(i, item) {
            switch (item.Type) {
                case "folder":
                    viewModels.push(that._getDirectoryViewModel(item));
                    break;
                case "file":
                    viewModels.push(that._getFileViewModel(item));
                    break;
                default: throw "Item type is not known.";
            }
        });
        
        return viewModels;
    },
    _getDirectoryViewModel: function(item) {
        return new MyUploadsDirectoryViewModel(this, item.Name, item.Type, item.Link);
    },
    _getFileViewModel: function(item) {
        var model = null;
        
        if (item.Info !== null) {
            model = new MyUploadsFileInfoModel(item.Info.CustomerName,
                                               item.Info.CustomerNumber,
                                               item.Info.CustomerLink,
                                               item.Info.Account,
                                               item.Info.AccountType,
                                               item.Info.AccountLink,
                                               item.Info.Document,
                                               item.Info.Comment,
                                               item.Info.ExpirationDate,
                                               item.Info.UploadSource,
                                               item.Info.UploadUser,
                                               item.Info.FileClass,
                                               item.Info.MoveLink,
                                               item.Info.DocumentGroup,
                                               item.Info.DocumentTab,
                                               {
                                                   canRead: item.Info.Authorization.CanRead,
                                                   canUpload: item.Info.Authorization.CanUpload
                                               });
        }

        return new MyUploadsFileViewModel(this,
                                          item.Name,
                                          item.Type,
                                          item.Link,
                                          item.Extension,
                                          model,
                                          item.Size,
                                          item.CreatedDate);
    },
    _onRequestEnd: function (response) {
        this.set("path", response.Path);
        this.set("parent", response.Parent);

        if (this.id) {
            this.setOption("Path", response.Path);

            $.post({
                url: kendo.format("dashboards({0})/widgets({1})", this.dashboardId, this.id),
                contentType: "application/json",
                data: JSON.stringify({
                    Id: this.id,
                    Widget: this.widget,
                    PositionX: this.positionX,
                    PositionY: this.positionY,
                    SizeX: this.sizeX,
                    SizeY: this.sizeY,
                    Options: this.options
                })
            });
        }
    },
    dashboardId: null,
    openParentDirectory: function() {
        var that        = this;
        var parentPath  = that.get("parent");

        that.items.transport.options.read.url = kendo.format("{0}&userId={1}", parentPath, that.userId);

        that.refresh();
    },
    openDirectory: function (directoryItem) {
        var that = this;

        that.items.transport.options.read.url = kendo.format("{0}&userId={1}", directoryItem.link, that.userId);

        that.refresh();
    },
    path: undefined,
    hasParent: function() {
        return this.get("path");
    },
    items: undefined,
    parentDirectory: null,
    user: undefined,
    userId: undefined,
    refresh: function() {
        this.items.read();
    },
    options: []
});
var MyUploadsFileMoveView = (function (widget, template) {
    var content = $(template);
    var form = content.find("#form-upload-quickmove");
    var view = $("<div></div>").kendoDialog({
        width: "700px",
        title: "Move Document",
        closable: false,
        modal: true,
        content: content,
        actions: [{
            text: "Update",
            primary: true,
            action: function () {
                var formData = form.serialize();
                widget.endMove(formData);
            }
        },
        {
            text: "Cancel"
        }],
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");

    $("#target-value").kendoDropDownList();

    return view;
});
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
var ActiveExceptionsFilter = (function (document) {
    var that = {
        validateCheckboxes: undefined,
        enableDropdowns: undefined,
        disableSection: undefined,
        clearAll: undefined,
        checkAll: undefined,
        checkBank: undefined,
        checkItem: undefined,
        updateCheckList: undefined
    };

    that.validateCheckboxes = function () {
        var alertMessage = '';
        var currentFilter = document.frmDisplayPrefs.hidFilterBy.value;
        var f = document.frmDisplayPrefs;
        var somethingChecked = false;
        if (currentFilter == 0) {
            somethingChecked = true;
        }
        else if (currentFilter == 1) // Filter - Loan Officer
        {
            for (i = 0; i < f.chkOfficerId.length; i++) {
                if (f.chkOfficerId[i].checked) {
                    somethingChecked = true;
                }
            }
            if (f.chkOfficerAll.checked) { somethingChecked = true; }
            if (f.chkOfficerBankId.checked) { somethingChecked = true; }
            alertMessage = 'Please select at least one officer.'
        }
        else if (currentFilter == 2) // Filter - Assigned User
        {
            for (i = 0; i < f.chkUserId.length; i++) {
                if (f.chkUserId[i].checked) {
                    somethingChecked = true;
                }
            }
            if (f.chkUserAll.checked) { somethingChecked = true; }
            if (f.chkUserBankId.checked) { somethingChecked = true; }
            alertMessage = 'Please select at least one user.'
        }

        if (somethingChecked == true) {
            document.frmDisplayPrefs.submit();
        }
        else {
            alert(alertMessage);
        }
    };

    that.enableDropdowns = function (filterBy) {
        var obj;
        var bankIdx, bankObj, bankDone;
        var itemIdx, itemObj, itemDone;

        document.frmDisplayPrefs.hidFilterBy.value = filterBy;

        if (filterBy == 1) {
            that.disableSection("chkOfficerAll", "chkOfficerBank", "chkOfficerItem", false);
            that.disableSection("chkUserAll", "chkUserBank", "chkUserItem", true);
            that.clearAll("chkUserAll", "chkUserBank", "chkUserItem");
        }
        else if (filterBy == 2) {
            that.disableSection("chkOfficerAll", "chkOfficerBank", "chkOfficerItem", true);
            that.clearAll("chkOfficerAll", "chkOfficerBank", "chkOfficerItem");
            that.disableSection("chkUserAll", "chkUserBank", "chkUserItem", false);
        }
        else {
            that.disableSection("chkOfficerAll", "chkOfficerBank", "chkOfficerItem", true);
            that.clearAll("chkOfficerAll", "chkOfficerBank", "chkOfficerItem");
            that.disableSection("chkUserAll", "chkUserBank", "chkUserItem", true);
            that.clearAll("chkUserAll", "chkUserBank", "chkUserItem");
        }
    };

    that.disableSection = function (chkAllName, chkBankName, chkItemName, newState) {
        obj = document.getElementById(chkAllName);
        obj.disabled = newState;

        bankIdx = 0;
        bankDone = false;
        while (!bankDone) {
            bankObj = document.getElementById(chkBankName + "_" + bankIdx);

            if (bankObj == null) {
                bankDone = true;
            }
            else {
                bankObj.disabled = newState;

                itemIdx = 0;
                itemDone = false;
                while (!itemDone) {
                    itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        itemObj.disabled = newState;
                    }

                    itemIdx++;
                }
            }

            bankIdx++;
        }

        return true;
    };

    that.clearAll = function (chkAllName, chkBankName, chkItemName) {
        var chkAllObj;
        var bankObj, bankIdx, bankDone;
        var itemObj, itemIdx, itemDone;

        chkAllObj = document.getElementById(chkAllName);
        chkAllObj.checked = false;

        bankDone = false;
        bankIdx = 0;
        while (!bankDone) {
            bankObj = document.getElementById(chkBankName + "_" + bankIdx);
            if (bankObj == null) {
                bankDone = true;
            }
            else {
                bankObj.checked = false;

                itemDone = false;
                itemIdx = 0;
                while (!itemDone) {
                    itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        itemObj.checked = false;
                    }

                    itemIdx++;
                }
            }
            bankIdx++;
        }
    };

    that.checkAll = function (chkAllName, chkBankName, chkItemName) {
        var elementId;
        var bankIdx, itemIdx;
        var bankObj, itemObj;
        var bankDone, itemDone;

        var chkAllObj = document.getElementById(chkAllName);

        bankIdx = 0;
        bankDone = false;
        itemDone = false;
        while (!bankDone) {
            elementId = chkBankName + "_" + bankIdx;
            bankObj = document.getElementById(elementId);
            if (bankObj == null) {
                bankDone = true;
            }
            else {
                bankObj.checked = chkAllObj.checked;
                itemIdx = 0;
                itemDone = false;
                while (!itemDone) {
                    elementId = chkItemName + "_" + bankIdx + "_" + itemIdx;
                    itemObj = document.getElementById(elementId);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        itemObj.checked = chkAllObj.checked;
                    }

                    itemIdx++;
                }
            }

            bankIdx++;
        }
    };

    that.checkBank = function (bankObj, chkAllName, chkBankName, chkItemName) {
        var itemIdx, itemObj, itemDone;
        var bankIdx = bankObj.id.split("_")[1];

        itemIdx = 0;
        itemDone = false;
        while (!itemDone) {
            itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
            if (itemObj == null) {
                itemDone = true;
            }
            else {
                itemObj.checked = bankObj.checked;
            }

            itemIdx++;
        }

        that.updateCheckList(chkAllName, chkBankName, chkItemName);
    };

    that.checkItem = function (chkAllName, chkBankName, chkItemName) {
        that.updateCheckList(chkAllName, chkBankName, chkItemName);
    };

    that.updateCheckList = function (chkAllName, chkBankName, chkItemName) {
        var bankDone, bankIdx, bankObj, checkBankState;
        var itemDone, itemIdx, itemObj;
        var chkAllObj = document.getElementById(chkAllName);
        var checkAllState = true;

        bankIdx = 0;
        bankDone = false;
        while (!bankDone) {
            bankObj = document.getElementById(chkBankName + "_" + bankIdx);
            if (bankObj == null) {
                bankDone = true;
            }
            else {
                checkBankState = true;
                itemIdx = 0;
                itemDone = false;
                while (!itemDone) {
                    itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        if (!itemObj.checked) {
                            checkBankState = false;
                            checkAllState = false;
                        }
                    }

                    itemIdx++;
                }
                bankObj.checked = checkBankState;
            }
            bankIdx++;
        }
        chkAllObj.checked = checkAllState;
    };

    return that;
})(window.document);