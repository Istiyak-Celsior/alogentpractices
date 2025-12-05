var Account = kendo.data.Model.extend({
    init: function (kind, accountService, documentService) {
        kendo.data.Model.fn.init.call(this);

        var that = this;

        that.kind             = kind;
        that._accountService  = accountService;
        that._documentService = documentService;
    },
    id: undefined,
    number: undefined,
    branch: undefined,
    kind: undefined,
    type: undefined,
    status: undefined,
    officer: undefined,
    getCollateral: function () {
        return [];
    },
    getDocuments: function () {
        return [];
    },
    _accountService: undefined,
    _documentService: undefined
});
