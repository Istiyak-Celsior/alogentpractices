var NoticeDistributionClient = (function () {
    return kendo.Class.extend({
        init: function (api) {
            this.api = api;
        },
        api: undefined,
        getDeliveredNotices: function (noticeId) {
            return this.api.get({
                area: "",
                controller: "notice/distribution",
                action: `directory/delivered?noticeId=${noticeId}`
            });
        },
        getPackage: function () {
            return this.api.get({
                area: "",
                controller: "notice/distribution",
                action: "package"
            });
        },
        postDistributionPackage: function(model) {
            return this.api.post({
                area: "",
                controller: "notice/distribution",
                action: "package",
                data: model
            })
        },
        postEnvelopeEmailAlertBatch: function(envelopeIds) {
            let requests = [];

            for (let id of envelopeIds) {
                requests.push({
                    method: "POST",
                    url: `notice/distribution/envelope/${id}/alerts/email`
                });
            }

            return this.api.post({
                area: "",
                controller: "notice/distribution",
                action: `envelope/$batch`,
                data: requests
            });
        },
        postDeleteEnvelopeBatch: function(envelopeIds) {
            let requests = [];

            for (let id of envelopeIds) {
                requests.push({
                    method: "DELETE",
                    headers: [
                        { "Content-Type": "application/json" }
                    ],
                    url: `notice/distribution/envelope/${id}`
                });
            }

            return this.api.post({
                area: "",
                controller: "notice/distribution",
                action: `envelope/$batch`,
                data: requests
            });
        },
        postDeliveredEnvelopeBatch: function(envelopeIds) {
            let requests = [];

            for (let id of envelopeIds) {
                requests.push({
                    method: "POST",
                    headers: [
                        { "Content-Type": "application/json" }
                    ],
                    url: `notice/distribution/package/${id}/delivered`
                });
            }

            return this.api.post({
                area: "",
                controller: "notice/distribution",
                action: `envelope/$batch`,
                data: requests
            });
        },
        maps: {
            mapExceptionPolicy: function(data) {
                return {
                    id: data.Id,
                    name: data.Name,
                    documentType: data.DocumentType,
                    accountType: data.AccountType,
                    type: data.Type,
                    accountClass: data.Class
                };
            }
        }
    });
})();