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