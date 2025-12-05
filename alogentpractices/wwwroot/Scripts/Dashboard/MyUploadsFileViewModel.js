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