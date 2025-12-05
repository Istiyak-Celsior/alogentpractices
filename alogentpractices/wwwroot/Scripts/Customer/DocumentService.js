var DocumentService = kendo.Class.extend({
    init: function (webapi) {
        this._webapi = webapi;
    },
    approve: function (documentId, username) {
        return this._webapi.post({
            area: "",
            controller: kendo.format("document({0})", documentId),
            action: kendo.format("approve?username={0}", username)
        });
    },
    getEvent: function (documentId, eventId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("document({0})", documentId),
            action: kendo.format("history({0})", eventId)
        });
    },
    getHistory: function (documentId) {
        return this._webapi.get({
            area: "",
            controller: kendo.format("document({0})", documentId),
            action: "history"
        });
    },
    reject: function (documentId, username, comment) {
        var action = kendo.format("reject?username={0}", username);

        if (comment && comment.length > 0) {
            action += kendo.format("&comment={0}", encodeURIComponent(comment));
        }

        return this._webapi.post({
            area: "",
            controller: kendo.format("document({0})", documentId),
            action: action
        });
    },
    rejectNotification: function(documentId, changeId, username) {
        return this._webapi.post({
            area: "",
            controller: kendo.format("document({0})", documentId),
            action: kendo.format("change({0})/reject/notification?username={1}", changeId, username)
        });
    },
    getCustomerDocuments: function (customerId, username, take, skip, searchText) {
        var url = kendo.format("document(credit)?accountId={0}&username={1}&take={2}&skip={3}", customerId, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getLoanApplicationDocuments: function (applicationId, username, take, skip, searchText) {
        var url = kendo.format("document(loanapp)?accountId={0}&username={1}&take={2}&skip={3}", applicationId, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getLoanDocuments: function (loanId, username, take, skip, searchText) {
        var url = kendo.format("document(loan)?accountId={0}&username={1}&take={2}&skip={3}", loanId, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getDepositDocuments: function (depositId, username, take, skip, searchText) {
        var url = kendo.format("document(deposit)?accountId={0}&username={1}&take={2}&skip={3}", depositId, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getTrustDocuments: function (trustId, username, take, skip, searchText) {
        var url = kendo.format("document(trust)?accountId={0}&username={1}&take={2}&skip={3}", trustId, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getLoanApplicationCollateralDocuments: function (applicationId, collateralNumber, username, take, skip, searchText) {
        var url = kendo.format("document(loanapp)?accountId={0}&collateralNumber={1}&username={2}&take={3}&skip={4}", applicationId, collateralNumber, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getLoanCollateralDocuments: function (loanId, collateralNumber, username, take, skip, searchText) {
        var url = kendo.format("document(loan)?accountId={0}&collateralNumber={1}&username={2}&take={3}&skip={4}", loanId, collateralNumber, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getDepositCollateralDocuments: function (depositId, collateralNumber, username, take, skip, searchText) {
        var url = kendo.format("document(deposit)?accountId={0}&collateralNumber={1}&username={2}&take={3}&skip={4}", depositId, collateralNumber, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    },
    getTrustCollateralDocuments: function (trustId, collateralNumber, username, take, skip, searchText) {
        var url = kendo.format("document(trust)?accountId={0}&collateralNumber={1}&username={2}&take={3}&skip={4}", trustId, collateralNumber, username, take, skip)

        if (searchText && searchText.length > 0) {
            url += kendo.format("&searchText={0}", encodeURIComponent(searchText))
        }

        return this._webapi.get({
            area: "",
            controller: url,
            action: ""
        });
    }
});