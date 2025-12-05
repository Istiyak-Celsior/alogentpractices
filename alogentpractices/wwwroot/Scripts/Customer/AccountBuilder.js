var AccountBuilder = kendo.Class.extend({
    init: function (accountService, documentService) {
        this._accountService  = accountService;
        this._documentService = documentService;
    },
    build: function (account, accountClass) {
        var accountModel;

        if (accountClass === "loan") {
            accountModel = new Loan(this._accountService, this._documentService);
        }
        else if (accountClass === "loanapp") {
            accountModel = new LoanApplication(this._accountService, this._documentService);
        }
        else if (accountClass === "deposit") {
            accountModel = new Deposit(this._accountService, this._documentService);
        }
        else {
            accountModel = new Trust(this._accountService, this._documentService);
        }

        accountModel.set("id", account.Id);
        accountModel.set("number", account.Number);
        accountModel.set("branch", account.BranchName);
        accountModel.set("type", account.Type);
        accountModel.set("status", account.Status);
        accountModel.set("officer", account.OfficerName);
        accountModel.set("balance", null);
        accountModel.set("commitment", null);

        if (accountClass === "loan") {
            accountModel.set("balance", account.Balance);
            accountModel.set("commitment", account.Commitment);
        }

        if (accountClass === "loanapp") {
            accountModel.set("amountRequested", account.AmountRequested);
            accountModel.set("isRenewal", account.IsRenewal);
        }

        return accountModel;
    }
});

