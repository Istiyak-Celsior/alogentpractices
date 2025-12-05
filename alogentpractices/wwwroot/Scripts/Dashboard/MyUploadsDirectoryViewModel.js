var MyUploadsDirectoryViewModel = MyUploadsItemViewModel.extend({
    init: function (widget, name, type, link) {
        MyUploadsItemViewModel.fn.init.call(this, widget, name, type, link);
    },
    open: function () {
        this._widget.openDirectory(this);
    }
});