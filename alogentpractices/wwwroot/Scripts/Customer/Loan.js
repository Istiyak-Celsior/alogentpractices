var Loan = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "loan", accountService, documentService);
        },
        balance: undefined,
        commitment: undefined,
        getCollateral: function (customerId, user) {
            return this._accountService.getLoanCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getLoanDocuments(this.id, user, take, skip, searchText);
        }
    });
})();