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