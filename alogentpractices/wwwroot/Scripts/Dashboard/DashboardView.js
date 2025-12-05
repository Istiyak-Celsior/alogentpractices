var DashboardView = View.extend({
    init: function (element, viewModel, webapi, service, errorHandler) {        
        View.fn.init.call(this, element, viewModel);
        
        this._webapi = webapi;
        this._service = service;

        this._errorHandler = errorHandler;
    },
    ready: function (element, viewModel) {
        var that = this;

        that._errorHandling(that._webapi, that._errorHandler);

        var promise = that._service.getDashboards(viewModel.user);

        promise.done(function(response) {
            $(".init-hidden").removeClass("init-hidden");

            View.fn.ready.call(that, element, viewModel);

            that._ui(element, viewModel);
            
            that._events(viewModel);

            viewModel.open(response);
        });
    },
    _closeDropDowns: function(e) {
        var dropdownlist = $(e.item).find("*[data-role='dropdownlist']")
                                    .data("kendoDropDownList");

        if (dropdownlist) {
            dropdownlist.close();
        }
    },
    _dashboardChange: function(e){
        var list = $("#dashboard-dropdownlist").data("kendoDropDownList");

        list.trigger("change");
    },
    _drag: function(e) {
        this._closeDropDowns(e);
    },
    _edit: function(e) {
        $("#name-input").css("display", "flex");
        $("#name-input input[type='text']").focus();
        $("#name-input input[type='text']").select();
    },
    _editEnd: function(e) {
        document.getSelection().removeAllRanges();
    },
    _errorHandling: function(webapi, errorHandler) {
        webapi.error = function(e) {
            errorHandler.clear();
            errorHandler.error(e.errorMessage);
        };
    },
    _events: function(viewModel) {
        viewModel.bind("dashboardchange", this._dashboardChange);
        viewModel.bind("edit", this._edit);
        viewModel.bind("editend", this._editEnd);

        viewModel.dashboard.bind("change", $.proxy(this._change, this));
        viewModel.dashboard.bind("popoutOpen", this._popoutOpen);
        viewModel.dashboard.bind("popoutClose", this._popoutClose);
        
        $("#name-input input").on("keyup", $.proxy(this._nameInputKeyUp, this));
    },
    _change: function(e) {
        if (e.action === "resize" || e.action === "drag") {
            this._closeDropDowns(e);
        }
    },
    _nameInputKeyUp: function(e) {
        switch (e.keyCode) {
            case /*ENTER*/ 13:
                this.viewModel.saveDashboard();
                break;
            case /*ESC*/ 27:
                this.viewModel.cancelEditDashboard();
                break;
        }
    },
    _popoutClose: function(e) {
        if (!e.modal) {
            $("#dashboard-container").show();
        }
    },
    _popoutOpen: function(e) {
        if (!e.modal) {
            $("#dashboard-container").hide();
        }
    },
    _ui: function(element, viewModel) {
        var dashboard = $("#dashboard").data("kendoDashboard");

        viewModel.set("dashboard", dashboard);

        element.kendoTooltip({ filter: "a[title]:not(a[title='']), span[title]:not(span[title=''])", position: "top" });
    }
});