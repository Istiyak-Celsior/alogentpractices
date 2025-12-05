var DocumentViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function (document, dialogService) {
            ViewModel.fn.init.call(this);

            this.set("document", document);
            this._dialogService = dialogService;
        },
        canApprove: function () {
            return this.get("isSelected") && !this.isApproved();
        },
        canEdit: true,
        canReject: function () {
            return this.get("isSelected") && !this.isRejected();
        },
        document: null,
        displayId: function () {
            this.set("isIdVisible", !this.get("isIdVisible"));
        },
        isIdVisible: false,
        isSelected: false,
        isApproved: function () {
            return this.get("document.quality") === 1;
        },
        isMenuOpen: false,
        isRejected: function () {
            return this.get("document.quality") === 2;
        },
        isQcRequiredAndApproved: function() {
            return this.get("document.requireQC") === true && this.isApproved() === true;
        },
        isQcRequiredAndNotApproved: function() {
            return this.get("document.requireQC") === true && this.isApproved() === false;
        },
        openHistory: function () {
            var that = this;

            var documentHistoryViewModel = new DocumentHistoryViewModel(this.document);

            this._dialogService.open("documentHistoryDialog", {
                title: that.document.title + " History",
                viewModel: documentHistoryViewModel
            });
        },
        _dialogService: undefined
    });
})(window.kendo.jQuery);