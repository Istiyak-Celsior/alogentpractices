var LoanApplication = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "loanapp", accountService, documentService);
        },
        amountRequested: 0,
        getCollateral: function (customerId, user) {
            return this._accountService.getLoanApplicationCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getLoanApplicationDocuments(this.id, user, take, skip, searchText);
        },
        isRenewal: false
    });
})();