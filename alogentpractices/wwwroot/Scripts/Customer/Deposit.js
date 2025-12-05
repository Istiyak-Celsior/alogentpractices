var Deposit = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "deposit", accountService, documentService);
        },
        getCollateral: function (customerId, user) {
            return this._accountService.getDepositCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getDepositDocuments(this.id, user, take, skip, searchText);
        }
    });
})();