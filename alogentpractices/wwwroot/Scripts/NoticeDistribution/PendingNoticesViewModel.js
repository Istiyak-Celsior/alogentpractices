var PendingNoticesViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (noticeClient, dialogService, gridHelper, distributionPackage) {
            ViewModel.fn.init.call(this);

            this._dialogService = dialogService;
            this._gridHelper    = gridHelper;

            this.set("notices", this._notices(distributionPackage));
        },
        count: function() {
            let notices = this.get("notices");
            let view    = notices.view();

            let count = view.reduce((sum, item) => sum + item.items.length, 0);

            return count;
        },
        onFilterInit: function(e) {
            this._gridHelper.multiCheckFilter.sort(e.sender, e.field, "asc");
        },
        _notices: function(distributionPackage) {
            let that = this;

            return new kendo.data.DataSource({
                data: distributionPackage.undeliverable,
                sort: [
                    { field: "recordName", dir: "asc" },
                    { field: "recordNumber", dir: "asc" }
                ]
            });
        }
    });

})(window.kendo.jQuery, window.kendo);