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