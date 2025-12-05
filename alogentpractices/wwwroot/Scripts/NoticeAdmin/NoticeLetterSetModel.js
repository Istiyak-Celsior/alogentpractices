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