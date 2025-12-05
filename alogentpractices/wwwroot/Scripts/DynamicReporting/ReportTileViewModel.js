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