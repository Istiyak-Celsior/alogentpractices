var InProcessNoticesViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (noticeClient, dialogService, gridHelper, distributionPackage) {
            ViewModel.fn.init.call(this);

            this._noticeClient  = noticeClient;
            this._dialogService = dialogService;
            this._gridHelper    = gridHelper;

            this.set("distributionPackage", distributionPackage);
            this.set("notices", this._notices(distributionPackage));
        },
        cancel: function(selection) {
            let deletes      = selection.map(e => e.id);
            let batchRequest = this._noticeClient.postDeleteEnvelopeBatch(deletes);

            batchRequest.then(batchResponse => {
                let failedResponses = batchResponse.filter(r => r.statusCode < 200 || r.statusCode >= 300);

                let refresh = this._refreshPackage();

                refresh.then(response => {
                    if (failedResponses.length > 0) {
                        this._displayBatchError(failedResponses);
                    }
                });
            });
        },
        confirmCancel: function(e) {
            let confirm = kendo.confirm("The selected notices will be removed from distribution and restored as active notices. This does not cancel any electronic alerts or mail that was already sent.");
                 
            confirm.done(() => this.cancel(this.selection));
        },
        confirmMarkDelivered: function(e) {
            let confirm = kendo.confirm("The selected notices will be have  their delivery date set and will be permanently archived. Staged notices will be allowed to move into their next stage after the appropriate time period has elapsed. This cannot be undone.");
                 
            confirm.done(() => this.markDelivered(this.selection));
        },
        count: function() {
            let notices = this.get("notices");
            let view    = notices.view();

            return view.length;
        },
        deselect: function() {
            this.selection.empty();
            this.set("hasSelection", false);
        },
        distributionPackage: null,
        hasSelection: false,
        markDelivered: function(selection) {
            let deletes      = selection.map(e => e.id);
            let batchRequest = this._noticeClient.postDeliveredEnvelopeBatch(deletes);

            batchRequest.then(batchResponse => {
                let failedResponses = batchResponse.filter(r => r.statusCode < 200 || r.statusCode >= 300);

                let refresh = this._refreshPackage();

                refresh.then(response => {
                    if (failedResponses.length > 0) {
                        this._displayBatchError(failedResponses);
                    }
                });
            });
        },
        selection: [],
        onFilterInit: function(e) {
            this._gridHelper.multiCheckFilter.sort(e.sender, e.field, "asc");
        },
        onSelect: function(e) {
            let grid = e.sender;
            
            let selectionKeys = grid.selectedKeyNames();
            let selection     = selectionKeys.map(id => this.notices.data().find(n => n.id == id));

            this.set("hasSelection", selection.length > 0);

            this.selection.empty();

            for (let selected of selection) {
                this.selection.push(selected);
            }
        },
        print: function(e) {
            this.trigger("print", { 
                items: this._mapPrintLetters(this.selection)
            });
        },
        printOne: function(e) {
            let envelope = e.data;

            this.trigger("print", { 
                items: this._mapPrintLetters([envelope]) 
            });
        },
        _displayBatchError: function(failedResponses) {
            this._dialogService.open("apiErrorDialog", {
                title: "Oops!",
                viewModel: {
                    Status: "204",
                    ErrorMessage: `${failedResponses.length} items could not be processed.`,
                    Reason: "",
                    Errors: failedResponses.map(p => p.body)
                },
                actions: [
                    { text: "OK" }
                ]
            });
        },
        _mapPrintLetters: function(envelopes) {
            return envelopes.map(n => {
                return {
                    name: n.name,
                    contactAddress: n.contactAddress,
                    contactEmail: n.contactEmail,
                    letterHeader: n.letterHeader,
                    letterBody: n.letterBody,
                    letterFooter: n.letterFooter
                }
            });
        },
        _notices: function(distributionPackage) {
            return new kendo.data.DataSource({
                data: distributionPackage.inProcess,
                schema: {
                    model: {
                        id: "id"
                    }
                },
            });
        },
        _refreshPackage: function(e) {
            let listRequest = this._noticeClient.getPackage();

            return listRequest.then(listResponse => {
                let notices   = listResponse.deliverable.map(n => new Notice(n));
                let pending   = listResponse.undeliverable.map(n => new PendingNotices(n));
                let envelopes = listResponse.inProcess.map(n => new NoticeEnvelope(n));

                this.distributionPackage.addDeliverable(notices);
                this.distributionPackage.addUndeliverable(pending);
                this.distributionPackage.addInProcess(envelopes);

                this.deselect();

                return listResponse;
            });
        }
    });

})(window.kendo.jQuery, window.kendo);