var DocumentHistoryViewModel = (function ($, undefined) {
    return kendo.mvvm.DialogViewModel.extend({
        init: function (document) {
            kendo.mvvm.DialogViewModel.fn.init.call(this);

            this.document = document;
            this.set("documentEvents", this._documentEventsDataSource());
        },
        document: undefined,
        documentEvents: undefined,
        _documentEventsDataSource: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that.document.getHistory();

                        api.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                schema: {
                    data: function(response) {
                        var models = [];

                        $.each(response, function(i, model) {
                            var eventModel;

                            if (model.Quality || model.Quality === 0) {
                                eventModel = new DocumentChange();

                                eventModel.set("pagesAdded", model.PagesAdded);
                                eventModel.set("pagesDeleted", model.PagesRemoved);
                                eventModel.set("approvals", []);
                                eventModel.set("quality", model.Quality);

                                $.each(model.Approvals, function(j, childModel) {
                                    var approval = new DocumentChangeApproval();

                                    approval.set("approver", childModel.Approver);
                                    approval.set("quality", childModel.Quality);
                                    approval.set("comment", childModel.Comment);
                                    approval.set("date", new Date(childModel.Date));

                                    eventModel.approvals.push(approval);
                                });
                            } 
                            else {
                                eventModel = new DocumentEvent();
                            }

                            eventModel.set("id", model.Id);
                            eventModel.set("author", model.Author);
                            eventModel.set("authorEmail", model.AuthorEmail);
                            eventModel.set("date", new Date(model.Date));
                            eventModel.set("information", model.Information);
                            eventModel.set("eventSource", model.EventSource);

                            models.push(eventModel);
                        });

                        return models;
                    }
                },
                pageSize: 7
            });
        },
        onChangeExpanded: function (e) {
            var row = e.masterRow.eq(0);

            var dataItem = e.sender.dataItem(row);

            kendo.bind(e.detailRow, dataItem);
        }
    });
})(window.kendo.jQuery);