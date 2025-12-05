var NoticeAdminView = (function ($, kendo, undefined) {

    return View.extend({
        init: function (element, viewModel, webapi, dialogService) {
            View.fn.init.call(this, element, viewModel);

            this._webapi = webapi;

            this._webapi.error = this.onApiError.bind(this);

            this._webapi.requestStart = () => kendo.ui.progress($(element), true);
            this._webapi.requestEnd = () => kendo.ui.progress($(element), false);

            this._dialogService = dialogService;            

            // Kendo does not support binding via MVVM for paste-cleanup, so it must be made
            // globally accessible.
            window.kendoEditorPasteCleanup = this.onPasteCleanup;
        },
        ready: function (element, viewModel) {
            var that = this;

            let exceptionPoliciesRead = viewModel.exceptionPolicies.read();

            exceptionPoliciesRead.done(() =>{
                let setsRead = viewModel.sets.read();

                setsRead.done(() => {
                    View.fn.ready.call(that, element, viewModel);

                    $(".init-hidden").removeClass("init-hidden");
            
                    that._ui(element, viewModel);
            
                    that._events(viewModel);

                    that.ui.setlist.refresh();

                    that._nav(viewModel);
                });
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

            if (e.target == "setname") {
                element = document.getElementById("aa-notice-admin-setname-edit");
            }
            else if (e.target == "template.name") {
                element = document.getElementById("noticelettertemplate-name-edit");
            }
            else if (e.target == "top") {
                element = document.body;
            }
            
            setTimeout(function () {
                element.focus();
                element.scrollIntoView({
                    behavior: "smooth"
                });
            });
        },
        onPasteCleanup: function(html) {
            const parser = new DOMParser();
            const document = parser.parseFromString(html, "text/html");

            let elements = document.querySelectorAll(":not(template-placeholder):not(.aa-noticeplaceholder-group):not(.aa-noticeplaceholder-label)");

            for (let element of elements) {
                element.removeAttribute("style");
                element.removeAttribute("class");
            }

            return document.body.innerHTML;
        },
        onSelectSet: function(e) {
            let listview = $("#aa-noticeadmin-setlist").data("kendoListView");

            let element = listview.element.find("[data-uid=" + e.item.uid + "]");

            listview.select(element);
        },
        ui: {
            setlist: undefined
        },
        _events: function (viewModel) {
            viewModel.bind("focus", this.onfocus);
            viewModel.bind("selectset", this.onSelectSet);
            viewModel.bind("ui.stage", (e) => this.ui.stagelist(e));
        },
        _nav: function(viewModel) {
            const urlParams   = new URLSearchParams(window.location.search);
            const letterSetId = urlParams.get('letterSet');
            const templateId  = urlParams.get("templateId");

            if (letterSetId != null) {
                let uid          = letterSetId.toLowerCase();
                let letterSetRow = this.ui.setlist.element.find('[data-id="' + uid + '"]');
                let letterSet    = this.ui.setlist.dataItem(letterSetRow);

                if (letterSet != null) {
                    this.ui.setlist.select(letterSetRow);
                }
                

                if (templateId != null) {
                    let template = letterSet.templates.data().find(p => p.id == templateId.toLowerCase());
        
                    if (template != null) {
                        letterSet.editTemplate({ data: template });
                    };
                }
            }
        },
        _ui: function (element, viewModel) {
            this.ui.setlist = $("#aa-noticeadmin-setlist").data("kendoListView");
            
            this.ui.templateEditor = () => $("#templateEditor").data("kendoEditor");

            this.ui.placeholderTemplate = () => kendo.template($("#noticeplaceholder-template").html());

            this.ui.stagelist = function(e) {
                let grid = $(".noticelettertemplate-stagelist").data("kendoGrid");
                let selectedSet = e.data;

                grid.table.kendoSortable({
                    filter: "> tbody > tr",
                    handler: ".noticelettertemplate-stage-draghandle",
                    hint: $.noop,
                    cursor: "move",
                    placeholder: function(element) {
                        return element.clone().addClass("k-state-drag");
                    },
                    start: () => {
                        grid.table[0].classList.add("k-state-dragging");
                    },
                    move: function(changeEvent) {
                        console.log("move to index: " + this.indexOf(this.placeholder));
                    },
                    change: function(changeEvent) {
                        let gridItems = grid.items();
    
                        let stages = [];
    
                        for (let i = 0; i < gridItems.length; i++) {
                            let item     = gridItems[i];
                            let dataItem = grid.dataSource.getByUid(item.getAttribute("data-uid"));
    
                            stages.push({
                                item: dataItem,
                                stage: i + 1
                            });
                        }
    
                        stages.forEach(stage => {
                            stage.item.set("editStage", stage.stage);
                        });
                        
                        selectedSet.set("stageEdit", stages.some(s => s.item.stage != s.item.editStage));
                    },
                    end: function(endEvent) {
                        grid.table[0].classList.remove("k-state-dragging");
                    }
                });
            }
        }
    });

})(window.kendo.jQuery, window.kendo);