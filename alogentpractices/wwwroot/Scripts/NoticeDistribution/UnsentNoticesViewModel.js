var UnsentNoticesViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (noticeClient, dialogService, gridHelper, distributionPackage) {
            ViewModel.fn.init.call(this);

            this._noticeClient  = noticeClient;
            this._dialogService = dialogService;
            this._gridHelper    = gridHelper;
            
            this.set("distributionPackage", distributionPackage);
            
            this.set("notices", this._notices(this, noticeClient, distributionPackage));
        },        
        confirmDistribute: function(e) {
            let confirm = kendo.confirm("Letters for the selected notices will be generated, mail merged, packaged, and moved into the distribution queue where you can distribute them to contacts. Any electronic alerts contacts have opted into will also be automatically queued and sent.");
                 
            confirm.done(() => this.distributeSelected(this.selection));
        },
        distributionPackage: null,
        hasSelection: false,
        selection: [],
        count: function() {
            let notices = this.get("notices");

            // In v2020.1.219, datasource.total() does not return data().length, 
            // it seems to return view().length. Because we use persistSelection in
            // conjunction with filtering, we need the unfiltered count.
            let data    = notices.data();
            let total   = data.length;

            return total;
        },
        deselect: function() {
            this.selection.empty();
            this.set("hasSelection", false);
        },
        distributeSelected: function(selection) {
            let noticeIdentities = selection.map(n => n.letterId);
            
            let distributeRequest = this._noticeClient.postDistributionPackage({
                noticeIdentities: noticeIdentities
            });

            distributeRequest.then(distributeResponse => {
                let envelopeIds  = distributeResponse.filter(e => e.contactByEmail === true)
                                                     .map(e => e.id);

                let batchRequest;
                
                if (envelopeIds.length === 0) {
                    batchRequest = Promise.resolve([]);
                }
                else {
                    batchRequest = this._noticeClient.postEnvelopeEmailAlertBatch(envelopeIds);
                }

                batchRequest.then(batchResponse => {
                    let failedResponses = batchResponse.filter(r => r.statusCode < 200 || r.statusCode >= 300);
    
                    let refresh = this._refreshPackage();
    
                    refresh.then(response => {
                        if (failedResponses.length > 0) {
                            this._displayBatchError(failedResponses);
                        }
                    });
                });
            });
        },
        onFilterInit: function(e) {
            this._gridHelper.multiCheckFilter.sort(e.sender, e.field, "asc");
        },
        onSelect: function(e) {
            let grid = e.sender;
            
            let selectionKeys = grid.selectedKeyNames();
            let selection     = selectionKeys.map(id => this.notices.data().find(n => n.letterId == id));

            this.set("hasSelection", selection.length > 0);

            this.selection.empty();

            for (let selected of selection) {
                this.selection.push(selected);
            }
        },
        openHistory: function(e) {
            let notice   = e.data;
            let noticeId = notice.letterId;
            let request  = this._noticeClient.getDeliveredNotices(noticeId);

            request.then(response => {
                var envelopes = response.map(e => new NoticeEnvelope(e));

                this._dialogService.open("historyDialog", {
                    title: `Completed Stages for ${notice.exception}`,
                    viewModel: {
                        notices: envelopes,
                        printOne: this.printOne.bind(this),
                        _mapPrintLetters: this._mapPrintLetters.bind(this)
                    },
                    actions: [
                        { text: "OK" }
                    ]
                });
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
        _notices: function(viewModel, noticeClient, distributionPackage) {
            return new kendo.data.DataSource({
                data: distributionPackage.deliverable,
                pageSize: 20,
                schema: {
                    model: {
                        id: "letterId"
                    }
                },
                sort: [
                    { field: "exceptionDate", dir: "asc" },
                    { field: "recordName" },
                    { field: "recordNumber" },
                    { field: "exception" }
                ]
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