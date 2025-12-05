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
var PlaceholderVisualizer = (function ($, kendo, undefined) {

    const HtmlExpression = /<template-placeholder\s+[^>]*data-identifier="([^"]+)"[^>]*>[\s\S]*?<\/template-placeholder>/gis;
    const TextExpression = /\[placeholder:\s*([a-f0-9\-]{36})\]/gis;

    return kendo.Class.extend({
       createPlaceholderElement: function(editor, dataItem) {      
           let placeholder     = dataItem;
           let placeholderHtml = kendo.template($("#noticeplaceholder-template").html())(placeholder);
   
           placeholderHtml = placeholderHtml.trim();
   
           editor.paste(placeholderHtml, true);
   
           setTimeout(() => {
               editor.focus();
   
               let range = editor.getRange();
               let parentNode = range.endContainer.parentNode;
               
               range.selectNode(parentNode);
               range.collapse();
   
               editor.selectRange(range);
           });
       },
       devisualizeText: function(text) {
        
           let visualizedText = text.replace(HtmlExpression, (match, p1) => {
               let placeholderHtml = `[placeholder: ${p1}]`;

               return placeholderHtml;
           });

           return visualizedText;
       },
       visualizeText: function(text, placeholders) {

           let visualizedText = text.replace(TextExpression, (match, p1) => {
               var placeholder = placeholders.find(p => p.id == p1);

               if (placeholder) {
                   let placeholderTemplate = $("#noticeplaceholder-template").html();
                   let placeholderHtml     = kendo.template(placeholderTemplate)(placeholder);
                   let cleanHtml           = placeholderHtml.trim();
                   
                   return cleanHtml;
               }
               
               return match;
           });

           return visualizedText;      
       },
    });

})(window.kendo.jQuery, window.kendo, undefined);
var NoticeClient = (function () {
    return kendo.Class.extend({
        init: function (api) {
            this.api = api;
        },
        api: undefined,
        getNoticeLetterSet: function () {
            return this.api.get({
                area: "",
                controller: "noticeletterset",
                action: ""
            });
        },
        postNoticeLetterSet: function (model) {
            return this.api.post({
                area: "",
                controller: "noticeletterset",
                action: "",
                data: model
            });
        },
        patchNoticeLetterSet: function (model) {
            return this.api.patch({
                area: "",
                controller: "noticeletterset",
                action: model.id,
                data: model
            });
        },
        deleteNoticeLetterSet: function (model) {
            return this.api.delete({
                area: "",
                controller: "noticeletterset",
                action: model.id
            });
        },
        getExceptionPolicies: function(type) {
            return this.api.get({
                area: "",
                controller: "exceptionpolicy",
                action: `?type=${type}`
            }); 
        },
        deleteExceptionPolicy: function(letterSetId, exceptionPolicyId) {
            return this.api.delete({
                area: "",
                controller: "noticeletterset",
                action: `${letterSetId}/exceptionpolicy/${exceptionPolicyId}`
            });
        },
        deleteTemplate: function(letterSetId, templateId) {
            return this.api.delete({
                area: "",
                controller: "noticeletterset",
                action: `${letterSetId}/template/${templateId}`
            });
        },
        getPlaceholders: function() {
            return this.api.get({
                area: "",
                controller: "notice/admin",
                action: "placeholder"
            });
        },
        patchTemplate: function(letterSetId, templateId, model) {
            return this.api.patch({
                area: "",
                controller: "noticeletterset",
                action: `${letterSetId}/template/${templateId}`,
                data: model
            });
        },
        postExceptionPolicy: function(letterSetId, exceptionPolicyId) {
            return this.api.post({
                area: "",
                controller: "noticeletterset",
                action: `${letterSetId}/exceptionpolicy/${exceptionPolicyId}`
            });
        },
        putStage: function(letterSetId, model) {
            return this.api.put({
                area: "",
                controller: "noticeletterset",
                action: `${letterSetId}/stage`,
                data: model
            });
        },
        postTemplate: function(letterSetId, model) {
            return this.api.post({
                area: "",
                controller: "noticeletterset",
                action: `${letterSetId}/template`,
                data: model
            });
        },
        maps: {
            mapNoticeLetterSet: function(data) {
                return {
                    id: data.Id,
                    name: data.Name,
                    isEnabled: data.IsEnabled,
                    isMailMergeEnabled: data.IsMailMergeEnabled,
                    exceptionPolicies: data.ExceptionPolicies == null ? [] : data.ExceptionPolicies.map(p => this.mapExceptionPolicy(p)),
                    templates: data.Templates == null ? [] : data.Templates.map(p => this.mapTemplate(p))
                };
            },
            mapExceptionPolicy: function(data) {
                return {
                    id: data.Id,
                    name: data.Name,
                    documentType: data.DocumentType,
                    accountType: data.AccountType,
                    type: data.Type,
                    accountClass: data.Class
                };
            },
            mapPlaceholder: function(data) {
                return {
                    id: data.Identifier,
                    label: data.Label,
                    class: data.Class
                };
            },
            mapTemplate: function(data) {
                return {
                    id: data.Id,
                    name: data.Name,
                    isEnabled: data.IsEnabled,
                    templateHeader: data.Header,
                    templateBody: data.Body,
                    templateFooter: data.Footer,
                    stage: data.Stage,
                    daysBeforeNext: data.DaysBeforeNext,
                    exceptionPolicies: data.ExceptionPolicies.map( p => this.mapTemplateExceptionPolicy(p))
                };
            },
            mapTemplateExceptionPolicy: function(data) {
                return {
                    exceptionPolicyId: data.ExceptionPolicyId,
                    daysBeforeNext: data.DaysBeforeNext
                }
            }
        }
    });
})();
var NoticeAdminExceptionPolicyDataSource = (function ($, kendo, undefined) {

    return function(data) {
        return new kendo.data.DataSource({
            data: data,
            pageSize: 10,
            group: [
                { field: "type" }
            ],
            sort: [
                { field: "accountClass", dir: "asc" },
                { field: "accountType", dir: "asc" },
                { field: "type", dir: "desc" },
                { field: "name", dir: "asc" }
            ]
        })
    };

})(window.kendo.jQuery, window.kendo, undefined);
var NoticeLetterSetExceptionPolicyModel = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, this);

            if (model != null) {
                this.set("id", model.id);
                this.set("name", model.name);
                this.set("type", model.type);
                this.set("accountClass", model.accountClass);
                this.set("accountType", model.accountType);
                this.set("documentType", model.documentType);
            }
        },
        id: null,
        name: null,
        type: null,
        accountClass: null,
        accountType: null,
        documentType: null,
        selected: false
    });

})(window.kendo.jQuery, window.kendo);
var NoticeLetterTemplateExceptionPolicy = (function($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function(model) {
            kendo.data.ObservableObject.fn.init.call(this, this);

            if (model != null) {
                this.set("id", model.id);
                this.set("type", model.type);
                this.set("accountClass", model.accountClass);
                this.set("accountType", model.accountType);
                this.set("name", model.name);
                this.set("daysBeforeNext", 0);
                this.set("override", false);

                this.set("editDaysBeforeNext", 0);
                this.set("editOverride", false);
            }
        },
        enableExceptionPolicyOverride: function() {
            this.set("editOverride", true);
        },
        disableExceptionPolicyOverride: function() {
            this.set("editOverride", false);
        }

    })

})(window.kendo.jQuery, window.kendo);
var NoticeLetterSetTemplateModel = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model, exceptionPolicies, noticeClient) {
            kendo.data.ObservableObject.fn.init.call(this, this);

            this.set("exceptionPolicies", new kendo.data.DataSource({
                sort: [
                    { field: "accountClass", dir: "asc" },
                    { field: "accountType", dir: "asc" },
                    { field: "type", dir: "desc" },
                    { field: "name", dir: "asc" }
                ]
            }));

            this.set("placeholders", new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        let response = noticeClient.getPlaceholders();
    
                        response.done(data => {
                            let placeholders = data.map(p => noticeClient.maps.mapPlaceholder(p));
    
                            options.success(placeholders);
                        });
                        
                        response.fail(function (result) {
                            options.error(result);
                        });
                    }
                },
                group: {
                    field: "class",
                    dir: "asc"
                },
                sort: [
                    { field: "class", dir: "asc" },
                    { field: "label", dir: "asc" }
                ]
            }));

            if (model != null) {
                this.set("id", model.id);
                this.set("name", model.name);
                this.set("isEnabled", model.isEnabled);
                this.set("stage", model.stage);
                this.set("daysBeforeNext", model.daysBeforeNext);
                this.set("templateHeader", model.templateHeader);
                this.set("templateBody", model.templateBody);
                this.set("templateFooter", model.templateFooter);

                exceptionPolicies.forEach(p => {
                    this.exceptionPolicies.add(new NoticeLetterTemplateExceptionPolicy(p));
                });

                model.exceptionPolicies.forEach(exceptionPolicyOverride => {
                    let exceptionPolicy = this.exceptionPolicies.data().find(p => p.id == exceptionPolicyOverride.exceptionPolicyId);

                    if (exceptionPolicy != null) {
                        exceptionPolicy.set("override", true);
                        exceptionPolicy.set("daysBeforeNext", exceptionPolicyOverride.daysBeforeNext);
                        exceptionPolicy.set("editDaysBeforeNext", exceptionPolicyOverride.daysBeforeNext);
                    }
                });
            }
        },
        id: null,
        name: "",
        isEnabled: true,
        editMode: false,
        editName: "",
        editDaysBeforeNext: 0,
        editIsEnabled: true,
        editStage: 0,
        editTemplateHeader: "",
        editTemplateBody: "",
        editTemplateFooter: "",
        placeholderVisualizer: new PlaceholderVisualizer(),
        applyChanges: function() {
            this.set("name", this.editName);
            this.set("isEnabled", this.editIsEnabled);
            this.set("daysBeforeNext", this.editDaysBeforeNext);
            this.set("templateHeader", this.devisualizeText(this.editTemplateHeader));
            this.set("templateBody", this.devisualizeText(this.editTemplateBody));
            this.set("templateFooter", this.devisualizeText(this.editTemplateFooter));

            this.exceptionPolicies.data().forEach(p => {
                p.set("override", p.editOverride);
                p.set("daysBeforeNext", p.editDaysBeforeNext);
            });

            this.set("editMode", false);
            this.set("isDirty", false);
        },
        cancelEdit: function() {
            this.set("editName", this.name);
            this.set("editDaysBeforeNext", this.daysBeforeNext);
            this.set("editIsEnabled", this.isEnabled);
            this.set("editTemplateHeader", this.visualizeText(this.templateHeader));
            this.set("editTemplateBody", this.visualizeText(this.templateBody));
            this.set("editTemplateFooter", this.visualizeText(this.templateFooter));

            this.exceptionPolicies.data().forEach(p => {
                p.set("editOverride", p.override);
                p.set("editDaysBeforeNext", p.daysBeforeNext);
            });

            this.set("editMode", false);
            this.set("isDirty", false);
        },
        edit: function() {
            let fetch = this.placeholders.fetch();

            fetch.done(() => {    
                this.set("editName", this.name);
                this.set("editDaysBeforeNext", this.daysBeforeNext);
                this.set("editIsEnabled", this.isEnabled);
                this.set("editTemplateHeader", this.visualizeText(this.templateHeader));
                this.set("editTemplateBody", this.visualizeText(this.templateBody));
                this.set("editTemplateFooter", this.visualizeText(this.templateFooter));
                this.set("editMode", true);
    
                this.exceptionPolicies.data().forEach(p => {
                    p.set("editOverride", p.override);
                    p.set("editDaysBeforeNext", p.daysBeforeNext);
                });
            });
        },
        devisualizeText: function(text) {
            return this.placeholderVisualizer.devisualizeText(text);
        },
        getPreviewText: function() {
            let header = this.get("templateHeader");
            let body   = this.get("templateBody");
            let footer = this.get("templateFooter");

            let text           = `${header}${body}${footer}`;
            let visualizedText = this.visualizeText(text);

            return visualizedText;
        },
        visualizeText: function(text) {
            return this.placeholderVisualizer.visualizeText(text, this.placeholders.data());
        },
        isNew: function () {
            return this.get("id") == "" || this.get("id") == undefined || this.get("id") == null;
        },
        hasExceptionPolicyOverrides: function(e) {
            let overrides = this.exceptionPolicies.data();

            let override = overrides.some(p => p.override == true);

            return override;
        },
        isStageChanged: function () { 
            let newStage = this.get("editStage");
            let oldStage = this.get("stage");
            
            if (newStage == 0) {
                return false;
            }

            return newStage != oldStage;
        },
        isUpdating: function() {
            if (this.isNew()) {
                return false;
            }

            return this.get("editMode");
        },
        isValid: function () {
            return this.get("editName") != "";
        },
        reset: function () {
            this.set("editName", null);
            this.set("editIsEnabled", null);
            this.set("isDirty", false);
        },
        onPlaceholderSelected: function(e) {
            if (e.dataItem == null) {
                return;
            }

            e.preventDefault();

            let editorId = $(e.sender.element).data("editor");
            let editor   = $(editorId).data("kendoEditor");

            this.placeholderVisualizer.createPlaceholderElement(editor, e.dataItem);
        },
        templateHeader: "",
        templateBody: "",
        templateFooter: ""
    });

})(window.kendo.jQuery, window.kendo);
var NoticeLetterSetModel = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        _noticeClient: null,
        _dialogService: null,

        init: function (model, noticeClient, exceptionPolicies, dialogService, focusManager) {
            kendo.data.ObservableObject.fn.init.call(this, this);

            this._noticeClient  = noticeClient;
            this._dialogService = dialogService;
            this._focusManager  = focusManager;

            this.set("unassignedExceptionPolicies", new NoticeAdminExceptionPolicyDataSource(exceptionPolicies));

            this.set("templates", new kendo.data.DataSource({
                sort: [
                    { field: "stage", dir: "asc" }
                ]
            }));

            this.set("exceptionPolicies", new kendo.data.DataSource({
                sort: [
                    { field: "accountClass", dir: "asc" },
                    { field: "accountType", dir: "asc" },
                    { field: "type", dir: "desc" },
                    { field: "name", dir: "asc" }
                ]
            }));

            if (model != null) {
                this.set("id", model.id);
                this.set("name", model.name);
                this.set("isEnabled", model.isEnabled);
                this.set("isMailMergeEnabled", model.isMailMergeEnabled);
                
                this.exceptionPolicies.data(model.exceptionPolicies.map(p => new NoticeLetterSetExceptionPolicyModel(p)));
                this.templates.data(model.templates.map(p => new NoticeLetterSetTemplateModel(p, this.exceptionPolicies.data(), this._noticeClient)));
            }
        },
        id: null,
        name: "",
        isEnabled: true,
        isMailMergeEnabled: false,
        editMode: false,
        editName: "",
        editIsEnabled: true,
        editIsMailMergeEnabled: false,
        exceptionPolicies: [],
        unassignedExceptionPolicies: [],
        selectedExceptionsTab: "Active",
        selectedTemplate: null,
        stageMode: false,
        templates: [],
        addTemplate: function() {
            let stage = 1;

            this.templates.data().forEach(t => stage++);

            let template = new NoticeLetterSetTemplateModel({
                name: "New Template",
                isEnabled: false,
                stage: stage,
                templateHeader: "",
                templateBody: "", 
                templateFooter: "",
                daysBeforeNext: 0,
                exceptionPolicies: []
            }, this.exceptionPolicies.data(), this._noticeClient);

            template.edit();
            
            this.templates.add(template);
            this.set("selectedTemplate", template);

            this._focusManager.trigger("focus", { target: "template.name" });
        },
        applyChanges: function() {
            this.set("name", this.editName);
            this.set("isEnabled", this.editIsEnabled);
            this.set("isMailMergeEnabled", this.editIsMailMergeEnabled);
            this.set("editMode", false);
            this.set("isDirty", false);
        },
        cancelEdit: function() {
            this.set("editMode", false);
        },
        cancelStageMode: function() {   
            this.templates.sort({ field: "editStage", dir: "asc" });
                     
            this.templates.data().forEach(stage => {
                stage.set("editStage", stage.stage);
            });

            this.set("stageMode", false);
        },
        cancelTemplate: function(e) {
            let template = e.data;

            if (template.isNew()) {
                this.templates.remove(template);
            }

            template.cancelEdit();

            this.set("selectedTemplate", null);

            this._focusManager.trigger("focus", { target: "top" });
        },
        commitStageMode: function(e) {
            let confirm = null;

            let dialogResult = this._dialogService.open("confirmStageOrder", {
                title: "Confirm",
                viewModel: this,
                actions: [
                    { 
                        text: "OK",
                        primary: true,
                        action: () => {
                            confirm = true;
                            return true;                
                        } 
                    },
                    { 
                        text: "Cancel", 
                        action: () => {
                            confirm = false;
                            return true;
                        } 
                    }
                ]
            });

            dialogResult.done((e) => {
                if (confirm == false) {
                    return;
                }

                let model = {
                    stages: []
                };

                this.templates.data().forEach(stage => {
                    model.stages.push({
                        templateId: stage.id,
                        stage: stage.editStage
                    });
                });

                let request = this._noticeClient.putStage(this.id, model);
    
                request.done(response => {
                    this.templates.data().forEach(stage => {
                        stage.set("stage", stage.editStage);
                    });
                    this.templates.sort({ field: "editStage", dir: "asc" });
                    this.set("stageMode", false);
                });
            });
        },
        createTemplate: function(e) {
            let template = e.data;

            let model = {
                name: template.editName,
                isEnabled: template.editIsEnabled,
                daysBeforeNext: template.editDaysBeforeNext,
                header: template.editTemplateHeader,
                body: template.editTemplateBody,
                footer: template.editTemplateFooter,
                exceptionPolicies: template.exceptionPolicies.data()
                                           .filter(p => p.editOverride)
                                           .map(p => ({
                                               exceptionPolicyId: p.id,
                                               daysBeforeNext: p.editDaysBeforeNext
                                           }))
            };

            let request = this._noticeClient.postTemplate(this.id, model);
            let that    = this;

            request.done(response => {
                template.applyChanges();

                if (template.isNew()) {
                    template.set("id", response.Id);
                }
                
                that.set("selectedTemplate", null);

                this._focusManager.trigger("focus", { target: "top" });
            });
        },
        deleteTemplate: function(e) {
            let template = e.data;
            let that     = this;

            kendo.confirm("Are you sure you want to delete this template?")
                 .done(function () {                 
                     let deleteRequest = that._noticeClient.deleteTemplate(that.id, template.id);
                 
                     deleteRequest.done(function (response) {
                         that.templates.remove(template);
                         that.set("selectedTemplate", null);

                         that.templates.data().forEach(t => {
                            if (t.stage > template.stage) {
                                t.set("stage", t.stage - 1);
                            }
                        });
                     });
                 });
        },
        edit: function() {
            this.set("editName", this.name);
            this.set("editIsEnabled", this.isEnabled);
            this.set("editIsMailMergeEnabled", this.isMailMergeEnabled);
            this.set("editMode", true);
        },
        editStages: function() {
            this.templates.sort({ field: "editStage", dir: "asc" });
            this.set("stageMode", true);
        },
        editTemplate: function(e) {
            let template = e.data;

            this.set("selectedTemplate", template);
            
            template.edit();
        },
        isNew: function () {
            return this.get("id") == "" || this.get("id") == undefined || this.get("id") == null;
        },
        isUpdating: function() {
            if (this.isNew()) {
                return false;
            }

            if (this.get("editMode") || this.get("stageMode")) {
                return true;
            }

            return this.get("templates").data().some(t => t.get("editMode"));
        },
        isValid: function () {
            return this.get("editName") != "";
        },
        reset: function () {
            this.set("editName", null);
            this.set("editIsEnabled", null);
            this.set("editIsMailMergeEnabled", null);
            this.set("isDirty", false);
        },
        disableExceptionPolicy: function(e) {
            let confirm = kendo.confirm(`Are you sure you want to revoke the policy for ${e.data.name} exceptions from this letter set?<br /><br />Revoking this policy will remove all associated configuration and disable the ability to create and send notice letters for this type of exception.`);
            let that    = this;
            let policy  = e.data;

            confirm.done(function() {
                let request = that._noticeClient.deleteExceptionPolicy(that.id, policy.id);

                request.done(response => {                    
                    that.exceptionPolicies.remove(policy);

                    that.templates.data().forEach(p => {
                        let exceptionPolicy = p.exceptionPolicies.data().find(q => q.id == policy.id);

                        if (exceptionPolicy != null) {
                            p.exceptionPolicies.remove(exceptionPolicy);
                        }
                    });
                });
            });
        },
        enableExceptionPolicy: function(e) {
            let policy  = e.data;
            let confirm = kendo.confirm(`Are you sure you want to assign the policy for ${e.data.name} exceptions to this letter set?<br /><br />This will enable the ability to create and send notice letters for this type of exception.`);
            let that    = this;

            confirm.done(() => {
                let update = that._noticeClient.postExceptionPolicy(that.id, policy.id);
    
                update.done(response => {
                    that.exceptionPolicies.add(policy); 

                    that.templates.data().forEach(p => {
                        p.exceptionPolicies.add(new NoticeLetterTemplateExceptionPolicy(policy));
                    });
                });
            });            
        },
        canEnableExceptionPolicies: function(e) {
            let policies = this.get("unassignedExceptionPolicies")
                               .view();

            return policies.some(g => g.items.some(i => i.selected));
        },
        canStage: function(e) {
            let templates = this.get("templates").data();

            return templates.length > 1;
        },
        canUpdateStage: function(e) {
            let templates = this.get("templates").data();

            let isChanged = templates.some(p => {
                let oldStage = p.get("stage");
                let newStage = p.get("editStage");

                if (newStage == 0) {
                    return false;
                }

                return oldStage != newStage;
            });

            return isChanged;
        },
        updateTemplate: function(e) {
            let template = e.data;

            let model = {
                name: template.editName,
                isEnabled: template.editIsEnabled,
                daysBeforeNext: template.editDaysBeforeNext,
                header: template.devisualizeText(template.editTemplateHeader),
                body: template.devisualizeText(template.editTemplateBody),
                footer: template.devisualizeText(template.editTemplateFooter),
                exceptionPolicies: template.exceptionPolicies.data()
                                           .filter(p => p.editOverride)
                                           .map(p => ({
                                               exceptionPolicyId: p.id,
                                               daysBeforeNext: p.editDaysBeforeNext
                                           }))
            };

            let request = this._noticeClient.patchTemplate(this.id, template.id, model);
            let that    = this;

            request.done(response => {
                template.applyChanges();                
                that.set("selectedTemplate", null);                
                this._focusManager.trigger("focus", { target: "top" });
            });
        },
        updateUnassignedExceptionPoliciesFilter: function(exceptionPolicyIds) {
            let filters = [];

            exceptionPolicyIds.forEach(p => filters.push({ field: "id", value: p, operator: "neq" }));

            this.unassignedExceptionPolicies.filter(filters);
        },
        isExceptionPoliciesVisible: function(e) {
            if (this.isNew()) {
                return false;
            }

            if (this.get("selectedTemplate.editMode")) {
                return false;
            }

            return true;
        }
    });

})(window.kendo.jQuery, window.kendo);
var NoticeAdminViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (webapi, dialogService) {
            ViewModel.fn.init.call(this);

            this._webapi        = webapi;
            this._noticeClient  = new NoticeClient(webapi);
            this._dialogService = dialogService;

            let that = this;

            this.bind("change", (e) =>{
                if (e.field == "selectedSet.stageMode") {
                    if (this.get("selectedSet.stageMode") == true) {
                        this.trigger("ui.stage", { data: this.selectedSet })
                    }
                }
            });
            
            this.set("exceptionPolicies", new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        let response = that._noticeClient.getExceptionPolicies("standard");

                        response.done(data => {
                            let policies = data.map(p => that._noticeClient.maps.mapExceptionPolicy(p));
                            let models   = policies.map(p => new NoticeLetterSetExceptionPolicyModel(p));

                            options.success(models);
                        });
                        
                        response.fail(function (result) {
                            options.error(result);
                        });
                    }
                }
            }));

            this.set("sets", new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        let response = that._noticeClient.getNoticeLetterSet();

                        response.done(function (data) {
                            let sets   = data.map(p => that._noticeClient.maps.mapNoticeLetterSet(p));
                            let models = sets.map(n => new NoticeLetterSetModel(n, that._noticeClient, that.exceptionPolicies.view(), that._dialogService, that));
                            
                            options.success(models);

                            that.updateExceptionPoliciesFilter(models);

                            models.forEach(p => {
                                p.bind("change", that.onSelectedSetChange.bind(that));
                            });
                        });

                        response.fail(function (result) {
                            options.error(result);
                        });
                    }
                },
                sort: [
                    { field: "name", dir: "asc" }
                ]
            }));
        },
        addSet: function (e) {
            let set = new NoticeLetterSetModel({
                name: "New Notice Letter Set",
                isEnabled: true,
                isMailMergeEnabled: false,
                exceptionPolicies: [],
                templates: []
            }, this._noticeClient, this.exceptionPolicies.view(), this._dialogService, this);

            this.sets.add(set);

            this.trigger("selectset", { item: set });

            this.editSet();

            this.trigger("focus", { target: "setname" });
        },
        cancelSetEdit: function (e) {
            let item = this.selectedSet;

            item.reset();

            if (item.isNew()) {
                this.sets.remove(item);
                this.set("selectedSet", null);
                return;
            }

            this.selectedSet.cancelEdit();
        },
        createSet: function (e) {
            let model = {
                name: this.selectedSet.editName,
                isEnabled: this.selectedSet.editIsEnabled,
                isMailMergeEnabled: this.selectedSet.editIsMailMergeEnabled,
                exceptionPolicies: [],
                templates: []
            };

            let promise = this._noticeClient.postNoticeLetterSet(model);
            let that    = this;

            promise.done(function (response) {
                that.selectedSet.applyChanges();

                if (that.selectedSet.isNew()) {
                    that.selectedSet.set("id", response.Id);
                    that.updateExceptionPoliciesFilter(that.sets.data());
                }
            });
        },
        deleteSet: function (e) {
            let deletedSet = this.selectedSet;

            if (this.selectedSet.isNew()) {
                this.sets.remove(deletedSet);
                this.set("selectedSet", null);
                return;
            }

            let that = this;

            kendo.confirm("Are you sure you want to delete this set? It will delete all of its templates and configuration.")
                 .done(function () {                 
                     let promise = that._noticeClient.deleteNoticeLetterSet(deletedSet);
                 
                     promise.done(function (response) {
                         that.sets.remove(deletedSet);
                         that.set("selectedSet", null);
                     });
                 });
        },
        editSet: function (e) {
            if (this.selectedSet == null) {
                return;
            }

            this.selectedSet.edit();

            this.trigger("focus", { target: "setname" });
        },
        isSetVisible: function(e) {
            if (this.get("selectedSet") == null) {
                return false;
            }
            
            if (this.get("selectedSet.selectedTemplate.editMode")) {
                return false;
            }

            return true;
        },
        isLettersVisible: function(e) {
            let selectedSet = this.get("selectedSet");

            if (selectedSet == null) {
                return false;
            }

            let selectedTemplate = this.get("selectedSet.selectedTemplate");

            if (selectedTemplate != null) {
                return false;
            }

            return !selectedSet.isNew();
        },
        sets: null,
        selectedSet: null,
        onSelectedSet: function (e) {
            let selectedItem = e.sender.dataItem(e.sender.select());

            e.data.set("selectedSet", selectedItem);
        },
        onSelectedSetChange: function(e) {
            if (e.field == "exceptionPolicies") {
                this.updateExceptionPoliciesFilter(this.sets.data());
            }
        },
        previewTemplate: function(e) {
            let template = e.data;

            let placeholdersRequest = template.placeholders.fetch();

            placeholdersRequest.done(() => {
                let placeholders = template.placeholders.data();
                let templateText = template.getPreviewText();
                let templateBody = template.placeholderVisualizer.visualizeText(templateText, placeholders);
    
                this._dialogService.open("previewTemplate", {
                    title: "Preview",
                    viewModel: {
                        letter: templateBody
                    },
                    actions: [
                        { 
                            text: "OK",
                            primary: true,
                            action: () =>  true
                        }
                    ]
                });
            });
        },
        updateExceptionPoliciesFilter: function(sets) {
            let exceptionPolicyIds = [];

            sets.forEach(s => {
                s.exceptionPolicies.data().forEach(p => {
                    exceptionPolicyIds.push(p.id);
                }); 
            });
            
            sets.forEach(s => {
                s.updateUnassignedExceptionPoliciesFilter(exceptionPolicyIds);
            });
        },
        updateSet: function (e) {
            let model = {
                id: this.selectedSet.id,
                name: this.selectedSet.editName,
                isEnabled: this.selectedSet.editIsEnabled,
                isMailMergeEnabled: this.selectedSet.editIsMailMergeEnabled
            };

            let promise = this._noticeClient.patchNoticeLetterSet(model);
            let that    = this;

            promise.done(function () {
                that.selectedSet.applyChanges();
            });
        }
    });

})(window.kendo.jQuery, window.kendo);
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