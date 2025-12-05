var Document = kendo.data.Model.extend({
    init: function (documentService) {
        kendo.data.Model.fn.init.call(this);

        this._documentService = documentService;
    },
    approve: function (user) {
        var that = this;

        return this._documentService.approve(this.id, user)
                   .then(function() {
                       that.set("quality", 1);
                   });
    },
    canExpire: undefined,
    changeCount: undefined,
    comment: undefined,
    expirationDate: undefined,
    extension: undefined,
    getHistory: function () {
        return this._documentService.getHistory(this.id);
    },
    id: undefined,
    isExpirable: undefined,
    isExpired: undefined,
    latestChangeId: undefined,
    pageCount: undefined,
    quality: undefined,
    reject: function (user, comment) {
        var that = this;

        return this._documentService.reject(this.id, user, comment)
                                    .then(function() {
                                              that.set("quality", 2);
                                          });
    },
    requireQC: undefined,
    size: undefined,
    tab: undefined,
    thumbnail: undefined,
    title: undefined,
    url: undefined
});