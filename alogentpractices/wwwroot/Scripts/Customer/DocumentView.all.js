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
var ErrorHandler = kendo.Class.extend({
    init: function () {},
    error: function (error) {
        console.log(error.errorMessage);
    },
    success: function () {
    },
    warning: function () {
    }
});
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


var CustomerBuilder = kendo.Class.extend({
    init: function (customerService, documentService) {
        this._customerService = customerService;
        this._documentService = documentService;
    },
    build: function (customer) {
        var customerModel = new Customer(this._customerService, this._documentService);

        customerModel.set("id", customer.Id);
        customerModel.set("name", customer.FullName);
        customerModel.set("number", customer.CustomerNumber);
        customerModel.set("taxId", customer.TaxId);
        customerModel.set("status", customer.Status);
        customerModel.set("type", customer.Type);
        customerModel.set("officer", customer.OfficerName);
        customerModel.set("branch", customer.BranchName);
        customerModel.set("email", customer.Email);
        customerModel.set("isEmployee", customer.IsEmployee);

        customerModel.set("address", {
            address1: customer.Address1,
            address2: customer.Address2,
            city: customer.City,
            state: customer.State,
            zip: customer.Zip
        });

        customerModel.set("phoneNumbers", {
            home: customer.HomePhoneNumber,
            work: customer.WorkPhoneNumber,
            mobile: customer.MobilePhoneNumber
        });

        customerModel.set("totalLoanBalance", customer.TotalLoanBalance);
        customerModel.set("totalLoanCommitment", customer.TotalLoanCommitment);

        return customerModel;
    }
});


var Customer = kendo.data.Model.extend({
    init: function (customerService, documentService) {
        kendo.data.Model.fn.init.call(this);

        this._customerService = customerService;
        this._documentService = documentService;
    },
    id: undefined,
    name: undefined,
    number: undefined,
    taxId: undefined,
    status: undefined,
    type: undefined,
    officer: undefined,
    branch: undefined,
    email: undefined,
    isEmployee: undefined,
    address: {
        address1: undefined,
        address2: undefined,
        city: undefined,
        state: undefined,
        zip: undefined
    },
    phoneNumbers: {
        home: undefined,
        work: undefined,
        mobile: undefined
    },
    getLoanApplications: function(customerId, user) {
        return this._customerService.getLoanApplications(customerId, user);
    },
    getLoans: function (customerId, user) {
        return this._customerService.getLoans(customerId, user);
    },
    getDeposits: function (customerId, user) {
        return this._customerService.getDeposits(customerId, user);
    },
    getTrusts: function (customerId, user) {
        return this._customerService.getTrusts(customerId, user);
    },
    getDocuments: function (customerId, user, take, skip, search) {
        return this._documentService.getCustomerDocuments(customerId, user, take, skip, search);
    },
    totalLoanBalance: undefined,
    totalLoanCommitment: undefined,
    _customerService: undefined
});

var AccountBuilder = kendo.Class.extend({
    init: function (accountService, documentService) {
        this._accountService  = accountService;
        this._documentService = documentService;
    },
    build: function (account, accountClass) {
        var accountModel;

        if (accountClass === "loan") {
            accountModel = new Loan(this._accountService, this._documentService);
        }
        else if (accountClass === "loanapp") {
            accountModel = new LoanApplication(this._accountService, this._documentService);
        }
        else if (accountClass === "deposit") {
            accountModel = new Deposit(this._accountService, this._documentService);
        }
        else {
            accountModel = new Trust(this._accountService, this._documentService);
        }

        accountModel.set("id", account.Id);
        accountModel.set("number", account.Number);
        accountModel.set("branch", account.BranchName);
        accountModel.set("type", account.Type);
        accountModel.set("status", account.Status);
        accountModel.set("officer", account.OfficerName);
        accountModel.set("balance", null);
        accountModel.set("commitment", null);

        if (accountClass === "loan") {
            accountModel.set("balance", account.Balance);
            accountModel.set("commitment", account.Commitment);
        }

        if (accountClass === "loanapp") {
            accountModel.set("amountRequested", account.AmountRequested);
            accountModel.set("isRenewal", account.IsRenewal);
        }

        return accountModel;
    }
});


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

var Loan = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "loan", accountService, documentService);
        },
        balance: undefined,
        commitment: undefined,
        getCollateral: function (customerId, user) {
            return this._accountService.getLoanCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getLoanDocuments(this.id, user, take, skip, searchText);
        }
    });
})();
var LoanApplication = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "loanapp", accountService, documentService);
        },
        amountRequested: 0,
        getCollateral: function (customerId, user) {
            return this._accountService.getLoanApplicationCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getLoanApplicationDocuments(this.id, user, take, skip, searchText);
        },
        isRenewal: false
    });
})();
var Deposit = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "deposit", accountService, documentService);
        },
        getCollateral: function (customerId, user) {
            return this._accountService.getDepositCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getDepositDocuments(this.id, user, take, skip, searchText);
        }
    });
})();
var Trust = (function () {
    return Account.extend({
        init: function (accountService, documentService) {
            Account.fn.init.call(this, "trust", accountService, documentService);
        },
        getCollateral: function (customerId, user) {
            return this._accountService.getTrustCollaterals(customerId, this.id, user);
        },
        getDocuments: function (user, take, skip, searchText) {
            return this._documentService.getTrustDocuments(this.id, user, take, skip, searchText);
        }
    });
})();
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
var DocumentEvent = kendo.data.ObservableObject.extend({
    id: undefined,
    author: undefined,
    authorEmail: undefined,
    date: undefined,
    eventSource: undefined,
    information: undefined,
    quality: undefined,
    pagesAdded: undefined,
    pagesDeleted: undefined,
    approvals: [],
    approvalCount: function() {
        return this.get("approvals").length;
    },
    approvalStatus: function() {
        var quality = this.get("quality");

        switch (quality) {
            case 1:
                return "Approved";
            case 2:
                return "Rejected";
            default:
                return "Not Verified";
        }
    },
    hasApprovals: function() {
        return this.get("approvals").length > 0;
    }
});

var DocumentChange = DocumentEvent.extend({
    /*
     * TODO: separate changes from events
     */
});
var DocumentChangeApproval = kendo.data.ObservableObject.extend({
    date: undefined,
    approver: undefined,
    comment: undefined,
    quality: undefined,
    qualityName: function() {
        var quality = this.get("quality");

        switch (quality) {
        case 1:  return "Approved";
        case 2:  return "Rejected";
        default: return "Not Verified";
        }
    }
});
var DocumentViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function (document, dialogService) {
            ViewModel.fn.init.call(this);

            this.set("document", document);
            this._dialogService = dialogService;
        },
        canApprove: function () {
            return this.get("isSelected") && !this.isApproved();
        },
        canEdit: true,
        canReject: function () {
            return this.get("isSelected") && !this.isRejected();
        },
        document: null,
        displayId: function () {
            this.set("isIdVisible", !this.get("isIdVisible"));
        },
        isIdVisible: false,
        isSelected: false,
        isApproved: function () {
            return this.get("document.quality") === 1;
        },
        isMenuOpen: false,
        isRejected: function () {
            return this.get("document.quality") === 2;
        },
        isQcRequiredAndApproved: function() {
            return this.get("document.requireQC") === true && this.isApproved() === true;
        },
        isQcRequiredAndNotApproved: function() {
            return this.get("document.requireQC") === true && this.isApproved() === false;
        },
        openHistory: function () {
            var that = this;

            var documentHistoryViewModel = new DocumentHistoryViewModel(this.document);

            this._dialogService.open("documentHistoryDialog", {
                title: that.document.title + " History",
                viewModel: documentHistoryViewModel
            });
        },
        _dialogService: undefined
    });
})(window.kendo.jQuery);
var RejectDialogViewModel = (function ($, undefined) {
    return kendo.mvvm.DialogViewModel.extend({
        init: function (documentService, document, username, userEmail, userCanSendMail) {
            kendo.mvvm.DialogViewModel.fn.init.call(this);

            this._documentService = documentService;
            this.document         = document;
            this.username         = username;
            this.userEmail        = userEmail;
            this.userCanSendMail  = userCanSendMail;
            this.title            = "Reject " + document.title;
        },
        author: undefined,
        authorEmail: undefined,
        cancel: function () {
            this.triggerClose(true, false);
        },
        cannotNotifyTitle: function() {
            if (!this.get("userCanSendMail")) {
                return "You do not have permission to send mail.";
            }

            if (!this.get("userEmail")) {
                return "You do not have an email address configured.";
            }

            if (!this.get("authorEmail")) {
                return "The author does not have an email address configured.";
            }
        },
        canNotifyAuthor: function() {
            var userCanSendMail = this.get("userCanSendMail");

            if (!userCanSendMail) {
                return false;
            }

            var authorEmail = this.get("authorEmail");
            var userEmail   = this.get("userEmail");

            if (!userEmail || !authorEmail) {
                return false;
            }

            return true;
        },
        canReject: function() {
            return this.get("isBusy") === false && !this.get("error");
        },
        changeDate: undefined,
        comment: undefined,
        error: null,
        isBusy: false,
        notifyAuthor: false,
        onRejectFail: function(e) {
            this.set("error", {
                 errorMessage: e.responseJSON.ErrorMessage, 
                 errors: e.responseJSON.Errors, 
                 reason: "The document could not be rejected because a problem occurred."
            });

            throw "Reject failed";
        },
        onNotificationFail: function(e) {
            var that = this;

            that.set("error", {
                errorMessage: e.responseJSON.ErrorMessage, 
                errors: e.responseJSON.Errors, 
                reason: kendo.format("The document was rejected, but {0} could not be notified because a problem occurred.", that.author)
            });

            throw "Notification failed";
        },
        reject: function () {
            this.set("isBusy", true);

            var promise = this.document.reject(this.username, this.comment);
            var that    = this;

            promise.then(null, that.onRejectFail.bind(that))
                        .then(function() {
                            if (that.notifyAuthor) {
                                return that._documentService
                                           .rejectNotification(that.document.id, that.document.latestChangeId, that.username)
                                           .then(null, that.onNotificationFail.bind(that));
                            }
                        })
                        .then(function() {
                            that.triggerClose(true, true);
                        })
                        .always(function() {
                            that.set("isBusy", false);
                        });
        },
        title: undefined,
        userCanSendMail: false
    });
})(window.kendo.jQuery);
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
var DocumentView = View.extend({
    init: function (window, element, viewModel, webapi, dialogService, customerService, customerId, userId) {
        View.fn.init.call(this, element, viewModel);

        this._dialogService   = dialogService;
        this._customerService = customerService;
        this._customerId      = customerId;
        this._userId          = userId;

        webapi.error = function (e) {
            console.log(e.errorMessage);
            console.log(e.response.responseText);
        };
    },
    ready: function (element, viewModel) {
        this._ui(element);

        this._events(viewModel);

        var customerRequest = this._customerService.getCustomerDetails(this._customerId);
        var moduleRequest   = this._customerService.getModuleInformation();

        customerRequest.done(function (response) {
            viewModel.openCustomer(response);
        });

        moduleRequest.done(function (response) {
            viewModel.set("hasLoanApprovalModule", response.EnableLoanApprovalModule);
            viewModel.set("hasLoanModule", response.EnableLoanModule);
            viewModel.set("hasDepositModule", response.EnableDepositModule);
            viewModel.set("hasTrustModule", response.EnableTrustModule);
        });

        $.when(customerRequest, moduleRequest).done(function () {
            $("#left-panel, #document-toolbar, #document-pager, #document-pager .k-pager-sizes, #document-pager .k-pager-info, #footer").show();

            $("#search-input").focus();
            
            kendo.bind(element, viewModel);

            if ($.active === 0) {
                kendo.ui.progress(element, false);
            }
        });
    },
    setAccountClassTab: function (element) {
        this.viewModel._closeAccountLists();

        $("#toolbar li").removeClass("selected");
        $(element).addClass("selected");
    },
    _events: function (viewModel) {
        var that = this;

        that.viewModel.bind("openDocument", $.proxy(that._openDocument, this));
        that.viewModel.bind("opendocumentmenu", $.proxy(that._openDocumentMenu, this));
        that.viewModel.bind("openDialog", that._openDialog);
        that.viewModel.bind("openEdit", that._openEdit);

        $("#btn-customer").click(function () {
            $("#toolbar li").removeClass("selected");
            $(this).addClass("selected");

            viewModel.selectCustomer();
        });

        $("#btn-loanapplications").click(function () {
            that.setAccountClassTab(this);
            viewModel.openLoanApplicationList();
            $("#loanapplications-list .content").mCustomScrollbar({ theme: "dark", setHeight: "250px" });
        });

        $("#btn-loans").click(function () {
            that.setAccountClassTab(this);
            viewModel.openLoanList();
            $("#loans-list .content").mCustomScrollbar({ theme: "dark", setHeight: "250px" });
        });

        $("#btn-deposits").click(function () {
            that.setAccountClassTab(this);
            viewModel.openDepositList();
            $("#deposits-list .content").mCustomScrollbar({ theme: "dark", setHeight: "250px" });
        });

        $("#btn-trusts").click(function () {
            that.setAccountClassTab(this);
            viewModel.openTrustList();
            $("#trusts-list .content").mCustomScrollbar({ theme: "dark", setHeight: "250px" });
        });

        $("body").mousedown(function (e) {
            if (e.target.className !== "account-list" && $(e.target).parents(".account-list").length === 0) {
                viewModel._closeAccountLists();
            }
        });

        $("#search-input").keypress(function (e) {
            if (e.which === 13) {
                viewModel.search();
            }
        });
    },
    _openDialog: function (e) {
        if (e.dialog === "rejectDialog") {
            $("#reject-comment").focus();
        }
    },
    _openDocument: function (document) {
        if (document.extension) {
            if (document.extension === ".pdf" && document.pageCount > 0) {
                var width      = $(window).width() * .85;
                var height     = $(window).height() * .85;
                var fileUrl    = kendo.format("{0}?userId={1}&dispositionType=inline", document.url, this._userId);
                var fileWindow = $("<div></div>").kendoWindow({
                    title: document.title,
                    content: fileUrl,
                    iframe: true,
                    width: width,
                    height: height,
                    modal: true,
                    actions: [
                        "Maximize",
                        "Close"
                    ]
                }).data("kendoWindow");

                fileWindow.center()
                          .open();
            }
            else {
                var fileUrl = kendo.format("{0}?userId={1}&dispositionType=attachment", document.url, this._userId);

                window.open(fileUrl, "_self", "toolbar=no, menubar=no, location=no, scrollbars=yes, resizable=yes");
            }
        }
        else {
            this._openErrorDialog(document);
        }
    },
    _openDocumentMenu: function (e) {
        var document  = $(e.event.currentTarget).closest(".document");
        var container = $(document).find(".thumb-container");
        var thumb     = $(container).find(".thumb");
        var menu      = $(container).find(".actionsheet");
        
        if ($(thumb).is(":visible")) {
            kendo.fx($(container))
                 .flip("horizontal", thumb, menu)
                 .play();
        }
        else{
            kendo.fx($(container))
                 .flip("horizontal", menu, thumb)
                 .play();
        }
    },
    _openEdit: function(document){
        window.location = kendo.format("accuimg://accuaccount/open?document={0}", document.id);  
    },
    _openErrorDialog: function (document) {
        var documentErrorDialog =
            $("<div></div>").kendoDialog({
                content: "<span>There was a problem accessing the file, please try again later.</span><br/><br/>You may see this error if the file is in use, such as another user adding or removing pages. In this case, try again later. Otherwise, if you feel there is an error, contact your system administrator for further guidance.",
                modal: true,
                width: "640px",
                closable: true,
                visible: false
            }).data('kendoDialog');

        documentErrorDialog.title("Cannot open " + document.title);
        documentErrorDialog.open();
    },
    _ui: function (element) {
        var that = this;

        $("#document-pager").kendoPager({
            dataSource: that.viewModel.documents,
            pageSizes: [6, 10, 25],
            autoBind: false
        });

        element.kendoTooltip({
            filter: "a[title]:not(a[title='']), span[title]:not(span[title='']), i[title]:not(i[title=''])",
            position: "top"
        });

        $(document).ajaxStart(function() {
            if ($.active > 0) {
                if (!that._dialogService.hasDialogOpen) {
                    kendo.ui.progress($("body"), true);
                }
            }
        });

        $(document).ajaxStop(function() {
            if ($.active < 1) {
                kendo.ui.progress($("body"), false);
            }
        });
    }
});
var CustomerViewModel = (function ($, undefined) {
    var CUSTOMER_VIEW   = "customer",
        ACCOUNT_VIEW    = "account",
        COLLATERAL_VIEW = "collateral";

    return ViewModel.extend({
        init: function (customerService, documentService, dialogService, user, userEmail, userCanSendMail, customerId) {
            ViewModel.fn.init.call(this);

            this._customerService = customerService;
            this._documentService = documentService;
            this._dialogService   = dialogService;
            this.customerId       = customerId;
            this.user             = user;
            this.userEmail        = userEmail;
            this.userCanSendMail  = userCanSendMail;

            var that              = this;

            that.set("documents", that._documentsDataSource());
            that.set("loanApplications", that._loanApplicationsDataSource());
            that.set("loans", that._loansDataSource());
            that.set("deposits", that._depositsDataSource());
            that.set("trusts", that._trustsDataSource());
            that.set("collaterals", that._collateralsDataSource());
        },
        abbreviatedTotalLoanBalance: function () {
            var customer = this.get("customer");
            return this._getAbbreviatedNumber(customer.totalLoanBalance);
        },
        abbreviatedTotalLoanCommitment: function () {
            var customer = this.get("customer");

            return this._getAbbreviatedNumber(customer.totalLoanCommitment);
        },
        approveDocuments: function () {
            var that      = this;
            var documents = this.get("documents").view();
            var promises  = [];

            $.each(documents, function (i, viewModel) {
                if (viewModel.canApprove()) {
                    var promise = viewModel.document.approve(that.user)
                                                    .then(function () {
                                                              viewModel.set("isSelected", false);
                                                          });

                    promises.push(promise);
                }
            });

            return $.when.apply($, promises);
        },
        balances: function () {
            var customer = this.get("customer");

            if (customer) {
                return [
                    { name: "Balance", value: customer.totalLoanBalance },
                    { name: "Commitment", value: customer.totalLoanCommitment }
                ];
            }
        },
        canApproveDocuments: function () {
            var result = false;
            var documents = this.get("documents").view();

            $.each(documents, function (i, document) {
                if (document.canApprove()) {
                    result = true;
                }
            });

            return result;
        },
        canRejectDocument: function () {
            var count     = 0;
            var documents = this.get("documents").view();

            $.each(documents, function (i, document) {
                if (document.canReject()) {
                    count++;
                }
            });

            return count === 1;
        },
        collaterals: undefined,
        customer: undefined,
        deposits: undefined,
        documents: undefined,
        filterText: undefined,
        hasCollaterals: function () {
            return this.get("collaterals").data().length > 0;
        },
        hasDeposits: function () {
            return this.get("deposits").data().length > 0;
        },
        hasDepositModule: false,
        hasDocuments: function () {
            return this.get("documents").data().length > 0;
        },
        hasLoanApplications: function() {
            return this.get("loanApplications").data().length > 0;
        },
        hasLoanApprovalModule: false,
        hasLoans: function () {
            return this.get("loans").data().length > 0;
        },
        hasLoanModule: false,
        hasTotals: function () {
            var customer = this.get("customer");
            if (customer) {
                if (customer.totalLoanBalance === 0 && customer.totalLoanCommitment === 0) {
                    return false;
                }
                else {
                    return true;
                }
            }
        },
        hasTrusts: function () {
            return this.get("trusts").data().length > 0;
        },
        hasTrustModule: false,
        includeCrossCollateral: false,
        isDepositListOpen: false,
        isLoanApplicationListOpen: false,
        isLoanListOpen: false,
        isTrustListOpen: false,
        loans: undefined,
        openCustomer: function(customerDto) {
            var builder = new CustomerBuilder(this._customerService, this._documentService);
            var model   = builder.build(customerDto);

            this.set("customerId", model.id);
            this.set("customer", model);

            this._currentView = CUSTOMER_VIEW;

            this.documents.page(1);
        },
        openDepositList: function () {
            var that = this;

            this.deposits
                .fetch()
                .then(function() {
                    that.set("isDepositListOpen", true);
                });
        },
        openDocument: function (e) {
            this.trigger("openDocument", e.data.document);
        },
        openDocumentMenu: function (e) {
            var document   = e.data;
            var isMenuOpen = document.get("isMenuOpen");

            document.set("isMenuOpen", !isMenuOpen);

            this.trigger("opendocumentmenu", { event: e, document: document })
        },
        openEdit: function(e) {
            this.trigger("openEdit", e.data.document);
        },
        openLoanApplicationList: function () {
            var that = this;

            this.loanApplications
                .fetch()
                .then(function() {
                    that.set("isLoanApplicationListOpen", true);
                });
        },
        openLoanList: function () {
            var that = this;

            this.loans
                .fetch()
                .then(function() {
                    that.set("isLoanListOpen", true);
                });
        },
        openTrustList: function () {
            var that = this;

            this.trusts
                .fetch()
                .then(function() {
                    that.set("isTrustListOpen", true);
                });
        },
        rejectDocument: function () {
            var that      = this;
            var documents = this.get("documents").view();

            var viewModel = documents.find(function(document) {
                return document.isSelected === true;
            });

            var document = viewModel.document;

            if (viewModel.canReject()) {
                var changePromise         = this._documentService.getEvent(document.id, document.latestChangeId);
                var rejectDialogViewModel = new RejectDialogViewModel(that._documentService, document, that.user, that.userEmail, that.userCanSendMail);

                changePromise.then(function (response) {
                    rejectDialogViewModel.set("changeDate", response.Date);
                    rejectDialogViewModel.set("author", response.Author);
                    rejectDialogViewModel.set("authorEmail", response.AuthorEmail);

                    return that.showRejectPrompt(rejectDialogViewModel);
                })
                .then(function(e) {
                    if (e.userTriggered && e.dialogResult === true) {
                        viewModel.set("isSelected", false);
                    }
                });
            }
        },
        selectAccount: function (e) {
            var that = this;
            var accountClass = e.target.dataset.class;
            var request;

            if (accountClass === "loan") {
                request = that._customerService.getLoanDetails(that.customer.id, e.data.Id);
            }
            else if (accountClass === "loanapp") {
                request = that._customerService.getLoanApplicationDetails(that.customer.id, e.data.Id);
            }
            else if (accountClass === "deposit") {
                request = that._customerService.getDeposit(that.customer.id, e.data.Id);
            }
            else {
                request = that._customerService.getTrustDetails(that.customer.id, e.data.Id);
            }

            request.done(function (response) {
                var builder = new AccountBuilder(that._customerService, that._documentService);
                var accountModel = builder.build(response, accountClass);

                that.set("selectedAccount", accountModel);
                that.set("selectedCollateral", {});

                that._currentView = ACCOUNT_VIEW;

                that.documents.page(1);

                that.collaterals.read()
                    .then(function() {
                        that._closeAccountLists();
                    });

                that.set("totalsIsVisible", false);
            });
        },
        selectCollateral: function (e) {
            var that  = this;
            var model = e.data;

            that.set("selectedCollateral", model);

            that._currentView = COLLATERAL_VIEW;

            that.documents.page(1);
        },
        selectCustomer: function(e) {
            this._closeAccountLists();

            this.set("selectedAccount", {});
            this.set("selectedCollateral", {});
            this.set("totalsIsVisible", true);

            this._currentView = CUSTOMER_VIEW;

            this.documents.page(1);
        },
        selectedAccount: {},
        selectedCollateral: {},
        search: function () {
            this.documents.page(1);
        },
        showRejectPrompt: function (rejectDialogViewModel) {
            var that = this;

            return that._dialogService.open("rejectDialog", {
                title: rejectDialogViewModel.title,
                viewModel: rejectDialogViewModel,
                opened: function () {
                    that.trigger("openDialog", { dialog: "rejectDialog" });
                }
            });
        },
        totalsIsVisible: true,
        trusts: undefined,
        user: undefined,
        userEmail: undefined,
        userCanSendMail: undefined,
        _closeAccountLists: function () {
            this.set("isLoanApplicationListOpen", false);
            this.set("isLoanListOpen", false);
            this.set("isDepositListOpen", false);
            this.set("isTrustListOpen", false);
        },
        _collateralsDataSource: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that.selectedAccount.getCollateral(that.customer.id, that.user);

                        api.fail(function (response) {
                            options.error(response);
                        });

                        api.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                schema: {
                    data: function(response) {
                        var models = [];

                        $.each(response, function(i, dto) {
                            var model = new Collateral(that.selectedAccount.kind, that._documentService);

                            model.set("number", dto.Number);
                            model.set("status", dto.Status);
                            model.set("type", dto.Type);
                            model.set("isCrossCollateral", dto.IsCrossCollateral);

                            if (model.isCrossCollateral === true) {
                                if (that.includeCrossCollateral === true) {
                                    models.push(model);
                                }
                            } else {
                                models.push(model);
                            }
                        });

                        return models;
                    }
                }
            });
        },
        _currentView: undefined,
        _customerService: undefined,
        _depositsDataSource: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that.customer.getDeposits(that.customer.id, that.user);

                        api.fail(function (response) {
                            options.error(response);
                        });

                        api.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                schema: {
                    type: "json",
                    model: {
                        fields: {
                            number: {
                                field: "Number"
                            },
                            type: {
                                field: "Type"
                            }
                        }
                    }
                }
            });
        },
        _dialogService: undefined,
        _documentsDataSource: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var request,
                            model,
                            searchText = that.get("filterText"),
                            view = that._currentView;

                        switch (view) {
                            case CUSTOMER_VIEW:
                                model = that.get("customer");
                                request = model.getDocuments(that.customer.id, that.user, options.data.take, options.data.skip, searchText);
                                break;
                            case ACCOUNT_VIEW:
                                model = that.get("selectedAccount");
                                request = model.getDocuments(that.user, options.data.take, options.data.skip, searchText);
                                break;
                            case COLLATERAL_VIEW:
                                model = that.get("selectedCollateral");
                                request = model.getDocuments(that.selectedAccount.id, that.user, options.data.take, options.data.skip, searchText);
                                break;
                            default: throw "value of _currentView is not a supported view.";
                        }

                        request.fail(function(response) {
                            options.error(response);
                        });

                        request.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                page: 1,
                pageSize: 6,
                serverPaging: true,
                schema: {
                    data: function(response) {
                        var viewModels = [];

                        $.each(response.Documents, function(i, dto) {
                            var model = new Document(that._documentService);

                            model.set("id", dto.Id);
                            model.set("canExpire", dto.CanExpire);
                            model.set("comment", dto.Comment);
                            model.set("changeCount", dto.ChangeCount);
                            model.set("expirationDate", dto.ExpirationDate);
                            model.set("extension", dto.Extension);
                            model.set("isExpired", dto.IsExpired);
                            model.set("pageCount", dto.PageCount);
                            model.set("size", dto.Size);
                            model.set("quality", dto.Quality);
                            model.set("tab", dto.Tab);
                            model.set("thumbnail", dto.ThumbnailUri);
                            model.set("title", dto.Title);
                            model.set("url", dto.Uri);
                            model.set("latestChangeId", dto.LatestChangeId);
                            model.set("isExpirable", dto.IsExpirable);
                            model.set("requireQC", dto.RequireQC);

                            var viewModel = new DocumentViewModel(model, that._dialogService);

                            viewModel.set("canEdit", dto.CanEdit);

                            viewModels.push(viewModel);
                        });

                        return viewModels;
                    },
                    total: function (response) {
                        return response.Total;
                    }
                }
            });
        },
        _documentService: undefined,
        _getAbbreviatedNumber: function (number) {
            if (number > 999)
                return (number / 1000).toFixed(0) + "K";
            else if (number > 999999)
                return (number / 1000000).toFixed(0) + "M";
            else
                return number;
        },
        _loanApplicationsDataSource: function() {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that.customer.getLoanApplications(that.customer.id, that.user);

                        api.fail(function (response) {
                            options.error(response);
                        });

                        api.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                schema: {
                    type: "json",
                    model: {
                        fields: {
                            number: {
                                field: "Number"
                            },
                            type: {
                                field: "Type"
                            }
                        }
                    }
                }
            });
        },
        _loansDataSource: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that.customer.getLoans(that.customer.id, that.user);

                        api.fail(function (response) {
                            options.error(response);
                        });

                        api.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                schema: {
                    type: "json",
                    model: {
                        fields: {
                            number: {
                                field: "Number"
                            },
                            type: {
                                field: "Type"
                            }
                        }
                    }
                }
            });
        },
        _trustsDataSource: function () {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        var api = that.customer.getTrusts(that.customer.id, that.user);

                        api.fail(function (response) {
                            options.error(response);
                        });

                        api.done(function (response) {
                            options.success(response);
                        });
                    }
                },
                schema: {
                    type: "json",
                    model: {
                        fields: {
                            number: {
                                field: "Number"
                            },
                            type: {
                                field: "Type"
                            }
                        }
                    }
                }
            });
        }
    });
})(window.kendo.jQuery);