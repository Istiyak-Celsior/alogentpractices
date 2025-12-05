var ReportService = (function () {
    return kendo.Class.extend({
        init: function (api) {
            this.api = api;
        },
        api: undefined,
        copyReport: function (user, owner, reportName, newReportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "CopyReport",
                username: user,
                data: {
                    Owner: owner,
                    ReportName: reportName,
                    NewReportName: newReportName
                }
            });
        },
        createReport: function (user, template, reportName, description) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "CreateReport",
                username: user,
                data: { Template: template, User: user, Name: reportName, Description: description }
            });
        },
        deleteReport: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "DeleteReport",
                username: user,
                data: { Name: reportName }
            });
        },
        emailReport: function (user, reportName, message, users) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "EmailReport",
                username: user,
                data: { User: user, ReportName: reportName, Users: users, Message: message }
            });
        },
        getData: function (user, reportName, fields, filters, options) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportData",
                username: user,
                data: {
                    Fields: fields,
                    Skip: options.skip,
                    Take: options.take,
                    User: user,
                    ReportName: reportName,
                    Filters: filters
                }
            });
        },
        getReportTemplate: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportTemplate",
                username: user,
                data: { User: user, ReportName: reportName }
            });
        },
        getReportDefinition: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportDefinition",
                username: user,
                data: { User: user, ReportName: reportName }
            });
        },
        getReportFilterData: function (user, reportName, field) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetReportFilterData",
                data: {
                    User: user,
                    ReportName: reportName,
                    FieldName: field
                }
            });
        },
        getReportTemplates: function (user) {
            return this.api.get({
                controller: "DynamicReporting",
                action: "GetTemplates",
                username: user
            });
        },
        getReportList: function (user) {
            return this.api.get({
                controller: "DynamicReporting",
                action: "GetUserReportList",
                username: user
            });
        },
        getSharedUsers: function (user, reportName) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetSharedUsers",
                data: {
                    UserName: user,
                    ReportName: reportName
                }
            });
        },
        getUsers: function (user) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "GetUsers",
                data: {
                    UserName: user
                }
            });
        },
        getUserPermissions: function (user) {
            return this.api.get({
                controller: "DynamicReporting",
                action: "GetUserPermissions",
                username: user
            });
        },
        shareReport: function (user, reportName, isShared, users) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "ShareReport",
                data: { ReportName: reportName, IsShared: isShared, Users: users },
                username: user
            });
        },
        updateReport: function (user, originalReportName, reportName, description, fields, groups, filters) {
            return this.api.post({
                controller: "DynamicReporting",
                action: "UpdateReport",
                username: user,
                data: {
                    ReportName: originalReportName,
                    NewReportName: reportName,
                    Description: description,
                    Fields: fields,
                    Groups: groups,
                    Filters: filters
                }
            });
        }
    });
})();