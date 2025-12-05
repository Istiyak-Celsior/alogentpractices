var CustomerService = kendo.Class.extend({
    init: function (webapi) {
        this._webapi = webapi;
    },
    getCustomerDetails: function (customerId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: ""
        });
    },
    getModuleInformation: function () {
        return this._webapi.get({
            area: "",
            controller: "customer/module",
            action: ""
        });
    },
    getLoans: function (customerId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("loan?username={0}", username)
        });
    },
    getLoanApplications: function(customerId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("loanapplication?username={0}", username)
        });
    },
    getDeposits: function (customerId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("deposit?username={0}", username)
        });
    },
    getTrusts: function (customerId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("trust?username={0}", username)
        });
    },
    getLoanApplicationDetails: function (customerId, applicationId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("loanapplication({0})", applicationId)
        });
    },
    getLoanDetails: function (customerId, loanId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("loan({0})", loanId)
        });
    },
    getLoanApplicationCollaterals: function (customerId, applicationId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})/loanapplication({1})", customerId, applicationId),
            action: kendo.format("collateral?user={0}", username)
        });
    },
    getLoanCollaterals: function (customerId, loanId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})/loan({1})", customerId, loanId),
            action: kendo.format("collateral?user={0}", username)
        });
    },
    getDeposit: function (customerId, depositId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("deposit({0})", depositId)
        });
    },
    getDepositCollaterals: function (customerId, depositId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})/deposit({1})", customerId, depositId),
            action: kendo.format("collateral?username={0}", username)
        });
    },
    getTrustDetails: function (customerId, trustId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})", customerId),
            action: kendo.format("trust({0})", trustId)
        });
    },
    getTrustCollaterals: function (customerId, trustId, username) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("customer({0})/trust({1})", customerId, trustId),
            action: kendo.format("collateral?username={0}", username)
        });
    }
});

