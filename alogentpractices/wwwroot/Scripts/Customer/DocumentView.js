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