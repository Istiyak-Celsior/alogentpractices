var ApiService = (function($) {
    var publicApi = {
        authorizationHeader: undefined,
        error: undefined,
        get: undefined,
        post: undefined,
        success: undefined,
        requestStart: undefined,
        requestEnd: undefined
    };

    publicApi.delete = function(options) {
        return _ajax("DELETE", options);
    };

    publicApi.get = function(options) {
        return _ajax("GET", options);
    };

    publicApi.patch = function(options) {
        return _ajax("PATCH", options);
    };

    publicApi.post = function(options) {
        return _ajax("POST", options);
    };

    publicApi.put = function(options) {
        return _ajax("PUT", options);
    };

    function _ajax(method, options) {
        return $.ajax({
            url: _buildUri(options.area, options.controller, options.action),
            method: method,
            cache: false,
            contentType: "application/json",
            data: options.data != undefined ? JSON.stringify(options.data) : undefined,
            beforeSend: function(xhr) {
                if (typeof options.username !== "undefined") {
                    xhr.setRequestHeader('x-accuaccount-username', options.username);
                }

                if (typeof options.password !== "undefined") {
                    xhr.setRequestHeader('x-accuaccount-password', options.password);
                }

                if (publicApi.requestStart) {
                    publicApi.requestStart.bind(publicApi)();
                }
            },
            complete: function(response) {
                if (publicApi.requestEnd) {
                    publicApi.requestEnd.bind(publicApi)();
                }
            },
            success: function(response) {
                if (typeof options.success !== "undefined") {
                    options.success(response);
                }

                if (typeof publicApi.success !== "undefined") {
                    publicApi.success();
                }
            },
            error: function(response) {
                var error = {
                    statusCode: response.status,
                    statusDescription: response.statusText,
                    errorMessage: response.responseJSON != null ? response.responseJSON.ErrorMessage 
                        : "A general failure occurred communicating with the server (status: " + response.statusText + ").",
                    response: response
                };

                if (typeof options.error !== 'undefined') {
                    options.error(error);
                }

                if (typeof publicApi.error !== "undefined") {
                    publicApi.error(error);
                }
            }
        });
    }

    function _buildUri(area, controller, action) {
        var uri = "";

        if (area === null) {
            uri += "api/";
        }
        else if (area === "") {
        }
        else {
	        uri += "api/";
        }

        uri += controller;

        if (action) {
            uri += "/";
            uri += action;
        }

        return uri;
    }

    return publicApi;
});
(function (window, $, kendo, undefined) {

    if (!kendo.mvvm) {
        kendo.mvvm = {};
    }

    kendo.mvvm.Model = kendo.data.Model.extend({
        init: function () {
            kendo.data.Model.fn.init.call(this);
        }
    });
    
    kendo.mvvm.View = kendo.Class.extend({
        init: function (element, viewModel) {
            var that = this;
    
            that.viewModel = viewModel;
    
            $(document).ready($.proxy(that._ready, that, $(element), viewModel));
        },
        _ready: function(element, viewModel) {
            $("[data-role='pageload']").remove();
             
            kendo.ui.progress(element, true);
    
            this.ready(element, viewModel);
        },
        ready: function (element, viewModel) {
            kendo.bind(element, viewModel);
            kendo.ui.progress(element, false);
        }
    });
    
    kendo.mvvm.ViewModel = kendo.data.ObservableObject.extend({
        init: function() {
            kendo.data.ObservableObject.fn.init.call(this, this);
        }
    });
    
    kendo.mvvm.DialogViewModel = kendo.mvvm.ViewModel.extend({
        init: function() {
            ViewModel.fn.init.call(this);
        },
        triggerClose: function(userTriggered, dialogResult) {
            this.trigger("close", { userTriggered: userTriggered, dialogResult: dialogResult });
        }
    });

    kendo.mvvm.DialogService = kendo.Class.extend({
        init: function (views) {
            this.views = views;
        },
        hasDialogOpen: false,
        views: {},
        open: function(view, options) {
            if (!view) throw "Required [view] is missing.";

            var dialogResult  = new $.Deferred();
            var dialogElement = $("<div class='k-custom-dialog' />").kendoDialog({
                actions: options.actions,
                close: function () {
                    this.destroy();
                }
            });

            var dialogView         = this.views[view];
            var template           = dialogView.id;
            var dialogTemplateDOM  = $(template).html();
            var dialog             = dialogElement.data("kendoDialog");
            var dialogTemplate     = $(kendo.template(dialogTemplateDOM)(options.viewModel));

            dialog.content(dialogTemplate);

            if (dialogView.cssClass) {                
                let rootElement = dialog.element.closest(".k-dialog");

                $(rootElement).addClass(dialogView.cssClass);
            }

            if (dialogView.cssContentClass) {
                let contentElement = dialogElement;
                
                $(contentElement).addClass(dialogView.cssContentClass);
            }

            dialog.bind("close", function(e) {
                if (dialogResult.state() !== "resolved") {
                    dialogResult.resolve({userTriggered: e.userTriggered, dialogResult: null});
                };
            });

            if (options.viewModel) {                
                kendo.bind(dialogTemplate, options.viewModel);

                if (options.viewModel instanceof kendo.mvvm.DialogViewModel) {
                    options.viewModel.bind("close", function(e) {
                        dialogResult.resolve({userTriggered: e.userTriggered, dialogResult: e.dialogResult});    
                        dialog.close();                
                    });
                }
            }

            if (options.title) {
                dialog.title(options.title);
            }

            dialog.open();

            this.hasDialogOpen = true;

            if (options.opened) {
                $.proxy(options.opened(), this);
            }

            var promise = dialogResult.promise();
            var that    = this;

            promise.always(function () {
                that.hasDialogOpen = false;
            });

            return promise;
        }
    });
    
    // Plugs for backwards compatibility until we can refactor all the JS
    // bundles and files to switch to the new namespace.
    window.Model     = kendo.mvvm.Model;
    window.ViewModel = kendo.mvvm.ViewModel;
    window.View      = kendo.mvvm.View;

})(window, window.kendo.jQuery, window.kendo);
let KendoGridHelper = undefined;

(function() {
    KendoGridHelper = kendo.Class.extend({
        init: function (element) {
            
        },
        multiCheckFilter: {
            sort: function(grid, field, direction) {
                let header      = grid.thead.find("[data-field=" + field + "]");
                let multiCheck  = header.data("kendoFilterMultiCheck");
                let checkSource = multiCheck.checkSource;
                
                multiCheck.container.empty();
                
                checkSource.sort({field: field, dir: direction});
                checkSource.data(checkSource.view().toJSON());
                
                multiCheck.createCheckBoxes();
            }
        }
    });
})();
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
var Notice = (function($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, model);

            this.set("exceptionDate", new Date(model.exceptionDate));
        }
    });

})(window.kendo.jQuery, window.kendo);
var NoticeEnvelope = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, model);

            this.set("contactByMailYN", model.contactByMail == true ? "Y" : "N");
            this.set("lastEmailAlert", this._getLastEmailAlert());
            this.set("lastEmailAlertDeliveryState", this._getLastEmailAlertDeliveryState());

            if (model.deliveryDate) {
                this.set("deliveryDate", new Date(model.deliveryDate));
            }
        },
        _getLastEmailAlert: function(e) {
            let alerts = this.get("alerts");

            if (alerts.length == 0) {
                return {
                    deliveryState: "",
                    deliveryStatus: ""
                }
            }
            
            // Future: design supports more than one alert, but only one alert
            //         ever created in the current design.
            let alert = alerts[0];
            
            return alert;
        },
        _getLastEmailAlertDeliveryState: function() {
            let alert = this._getLastEmailAlert();

            if (alert == null) {
                return "";
            }

            return alert.deliveryState;
        }
    });

})(window.kendo.jQuery, window.kendo);
var PendingNotices = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, model);

            if (model.contactName == null) {
                this.set("contactName", "");
            }

            if (model.contactEmail == null) {
                this.set("contactEmail", "");
            }

            if (model.contactAddress == null) {
                this.set("contactAddress", "");
            }
        }
    });

})(window.kendo.jQuery, window.kendo);
var NoticeDistributionPackage = (function($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function() {
            kendo.data.ObservableObject.fn.init.call(this, this);
        },
        deliverable: [],
        undeliverable: [],
        inProcess: [],
        addDeliverable: function(notices) {
            this.deliverable.empty();
            
            this.deliverable.push.apply(this.deliverable, notices);
        },
        addInProcess: function(notices) {
            this.inProcess.empty();

            this.inProcess.push.apply(this.inProcess, notices);
        },
        addUndeliverable: function(notices) {
            this.undeliverable.empty();

            let groupedNotices = this.groupUndeliverableNotices(notices);

            this.undeliverable.push.apply(this.undeliverable, groupedNotices);
        },
        _getDeliverByValue: function(envelope) {
            let deliverBy;

            if (envelope.holdLetter) {
                deliverBy = "Do Not Contact";
            }
            else if (envelope.usePaper && !envelope.useEmail) {
                deliverBy = "Paper";
            }
            else if (envelope.useEmail && !envelope.usePaper) {
                deliverBy = "Email";
            }
            else if (!envelope.holdLetter && !envelope.useEmail && !envelope.usePaper) {
                deliverBy = "Unspecified";
            }
            else {
                deliverBy = "Any";
            }

            return deliverBy;
        },
        groupUndeliverableNotices: function(notices) {
            let groups = notices.reduce((result, envelope) => {
                const group = result.find(g => g.recordNumber == envelope.recordNumber)

                if (group) {
                    group.items.push(envelope);
                }
                else {
                    result.push({
                        recordLink: envelope.recordLink,
                        recordName: envelope.recordName,
                        recordNumber: envelope.recordNumber,
                        usePaper: envelope.usePaper,
                        useEmail: envelope.useEmail,
                        hasValidAddress: envelope.hasValidAddress,
                        hasValidEmail: envelope.hasValidEmail,
                        contactName: envelope.contactName,
                        contactAddress: envelope.contactAddress == null ? "" : envelope.contactAddress,
                        contactEmail: envelope.contactEmail == null ? "" : envelope.contactEmail,
                        contactMethod: envelope.contactMethod,
                        holdLetter: envelope.holdLetter,
                        deliverBy: this._getDeliverByValue(envelope),
                        items: [envelope]
                    });
                }

                return result;
            }, []);

            return groups;
        }
    });

})(window.kendo.jQuery, window.kendo);
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
var PendingNoticesViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (noticeClient, dialogService, gridHelper, distributionPackage) {
            ViewModel.fn.init.call(this);

            this._dialogService = dialogService;
            this._gridHelper    = gridHelper;

            this.set("notices", this._notices(distributionPackage));
        },
        count: function() {
            let notices = this.get("notices");
            let view    = notices.view();

            let count = view.reduce((sum, item) => sum + item.items.length, 0);

            return count;
        },
        onFilterInit: function(e) {
            this._gridHelper.multiCheckFilter.sort(e.sender, e.field, "asc");
        },
        _notices: function(distributionPackage) {
            let that = this;

            return new kendo.data.DataSource({
                data: distributionPackage.undeliverable,
                sort: [
                    { field: "recordName", dir: "asc" },
                    { field: "recordNumber", dir: "asc" }
                ]
            });
        }
    });

})(window.kendo.jQuery, window.kendo);
var SentNoticesViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (noticeClient, dialogService) {
            ViewModel.fn.init.call(this);

            this._dialogService = dialogService;

            this.set("notices", this._notices(this, noticeClient));
        },
        _notices: function(viewModel, noticeClient) {
            return new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        /*let response = noticeClient.getNotices();
                        let models   = [];
                        
                        response.done(data => {
                            //let policies = data.map(p => that._noticeClient.maps.mapExceptionPolicy(p));
                            //let models   = policies.map(p => new NoticeLetterSetExceptionPolicyModel(p));
                        
                            data.forEach(d => {
                                let model = new NoticeLetter(d);
                                
                                models.push(model);
                            });
                            
                            options.success(models);
                        });
                        
                        response.fail(function (result) {
                            options.error(result);
                        });*/
                    }
                },
                sort: [
                    { field: "RecordName" },
                    { field: "RecordNumber" },
                    { field: "RecordType" }
                ]
            });
        }
    });

})(window.kendo.jQuery, window.kendo);
var PrintViewModel = (function ($, kendo, undefined) {   

    return ViewModel.extend({
        letters: []
    });

})(window.kendo.jQuery, window.kendo);
var NoticeDistributionViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (webapi, dialogService, gridHelper) {
            ViewModel.fn.init.call(this);

            let noticeClient = new NoticeDistributionClient(webapi);            

            this.initDistribution = function() {
                let request = noticeClient.getPackage();

                request.done(response => {
                    var package = new NoticeDistributionPackage();

                    var deliverableModels   = response.deliverable.map(m => new Notice(m));
                    var undeliverableModels = response.undeliverable.map(m => new PendingNotices(m));
                    var inprocessModels     = response.inProcess.map(m => new NoticeEnvelope(m));
    
                    this.set("unsentNotices", new UnsentNoticesViewModel(noticeClient, dialogService, gridHelper, package));
                    this.set("pendingNotices", new PendingNoticesViewModel(noticeClient, dialogService, gridHelper, package));
                    this.set("inProcessNotices", new InProcessNoticesViewModel(noticeClient, dialogService, gridHelper, package));
                    this.set("sentNotices", new SentNoticesViewModel(noticeClient, dialogService, package));

                    package.addDeliverable(deliverableModels);
                    package.addUndeliverable(undeliverableModels);
                    package.addInProcess(inprocessModels);
                });

                return request;
            };
        }
    });

})(window.kendo.jQuery, window.kendo);
var NoticeDistributionView = (function ($, kendo, undefined) {

    return View.extend({
        init: function (element, viewModel, webapi, dialogService) {
            View.fn.init.call(this, element, viewModel);

            this._webapi = webapi;

            this._webapi.error = this.onApiError.bind(this);

            this._webapi.requestStart = () => kendo.ui.progress($(document.body), true);
            this._webapi.requestEnd = () => kendo.ui.progress($(document.body), false);

            this._dialogService = dialogService;
        },
        ready: function (element, viewModel) {
            var that = this;
            
            View.fn.ready.call(that, element, viewModel);

            kendo.ui.progress($(document.body), true);

            var init = viewModel.initDistribution();

            init.then(() => {
                kendo.ui.progress($(document.body), false);

                $(".init-hidden").removeClass("init-hidden");
    
                that._ui(element, viewModel);
        
                that._events(viewModel);
    
                that._nav(viewModel);
            });
        },
        onApiError: function(e) {
            let responseJSON = e.response.responseJSON;

            if (responseJSON == null || responseJSON == undefined) {
                responseJSON = {
                    ErrorMessage: e.response.responseText,
                    Errors: []
                };
            }

            responseJSON.Status = e.response.status;
            responseJSON.Reason = e.response.statusText;

            this._dialogService.open("apiErrorDialog", {
                title: "Oops!",
                viewModel: responseJSON,
                actions: [
                    { text: "OK" }
                ]
            });
        },
        onfocus: function (e) {
            let element;
            
            setTimeout(function () {
                element.focus();
                element.scrollIntoView({
                    behavior: "smooth"
                });
            });
        },
        ui: {
            letterGrid: undefined
        },
        _events: function (viewModel) {
            viewModel.inProcessNotices.bind("print", this._print);
            viewModel.unsentNotices.bind("print", this._print);
        },
        _nav: function(viewModel) {
            const urlParams   = new URLSearchParams(window.location.search);
        },
        _print: function(e) {            
            let iframe = document.getElementById("printframe");

            kendo.ui.progress($(document.body), true);
             
            let framedocument = iframe.contentDocument || iframe.contentWindow.document;
            let body          = $(framedocument).find("body");
            let viewModel     = new PrintViewModel();
            
            kendo.unbind(body);

            viewModel.set("letters", e.items);

            kendo.bind(body, viewModel);

            kendo.ui.progress($(document.body), false);

            iframe.focus();

            iframe.contentWindow.print();
        },
        _ui: function (element, viewModel) {
            this.ui.letterGrid = () => document.getElementById("noticeletterlist-grid");
        }
    });

})(window.kendo.jQuery, window.kendo);