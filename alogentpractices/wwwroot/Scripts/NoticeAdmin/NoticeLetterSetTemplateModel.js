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