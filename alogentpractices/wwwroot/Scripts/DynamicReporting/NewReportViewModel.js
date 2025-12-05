var NewReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;

            this.set("templates", this._templates());
        },
        create: function() {
            var that    = this;
            var request = that.service.createReport(that.user, that.selectedTemplate.name, that.name, that.description);

            request.done(function(response) {
                that.set("errors", []);
                that.set("hasErrors", false);

                if (response.Errors.length > 0) {
                    that.set("hasErrors", true);

                    $.each(response.Errors, function(i, error) {
                        that.errors.push(error);
                    });
                } 
                else {
                    that.set("result", "created");
                    that.set("hasErrors", false);
                }
            });

            return request;
        },
        description: "",
        errors: new kendo.data.ObservableArray([]),
        hasErrors: false,
        name: "",
        resizeWindow: undefined,
        result: "none",
        selectedTemplate: undefined,
        templates: undefined,
        user: undefined, 
        _templates: function() {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        var response = that.service.getReportTemplates(that.user);

                        response.done(function(e) {
                            options.success(e);
                        });

                        response.fail(function(e) {
                            options.error(e);
                        });
                    }
                },
                schema: {
                    data: function(response) {
                        var templates = [];

                        $.each(response.Templates, function(index, template) {
                            var viewModel;

                            viewModel = new ReportTemplateViewModel(template.Name, template.Description, template.IsLicensed);

                            templates.push(viewModel);
                        });

                        return templates;
                    }
                },
                change: function() {
                    var templates = that.templates.view();

                    if (templates.length > 0) {
                        that.set("selectedTemplate", templates[0]);
                    }
                }
            });
        }
    });
})(window.kendo.jQuery);