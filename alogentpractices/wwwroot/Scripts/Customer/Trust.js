var Trust = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "trust", accountService, documentService);
        },
        getCollateral: function (customerId, user) {
            return this._accountService.getTrustCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getTrustDocuments(this.id, user, take, skip, searchText);
        }
    });
})();