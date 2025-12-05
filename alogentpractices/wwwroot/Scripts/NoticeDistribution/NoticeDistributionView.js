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