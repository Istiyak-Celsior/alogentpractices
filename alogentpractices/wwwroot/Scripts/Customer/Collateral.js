var Collateral = kendo.data.Model.extend({
    init: function (kind, service) {
        kendo.data.Model.fn.init.call(this);

        var that = this;

        that.kind     = kind;
        that._service = service;
    },
    number: undefined,
    kind: undefined,
    type: undefined,
    isCrossCollateral: undefined,
    getDocuments: function (accountId, user, take, skip, searchText) {
        var that = this;

        if (that.kind === "loan") {
            return this._service.getLoanCollateralDocuments(accountId, that.number, user, take, skip, searchText);
        }
        else if (that.kind === "deposit") {
            return this._service.getDepositCollateralDocuments(accountId, that.number, user, take, skip, searchText);
        }
        else {
            return this._service.getTrustCollateralDocuments(accountId, that.number, user, take, skip, searchText);
        }
    },
    _service: undefined
});