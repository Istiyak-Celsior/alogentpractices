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