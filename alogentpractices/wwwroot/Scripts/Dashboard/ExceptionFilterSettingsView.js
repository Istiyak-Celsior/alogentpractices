var ExceptionFilterSettingsView = (function(viewModel, template) {
    var content  = $(template);
    var form     = content.find("#active-exception-filter-form");
    var view     = $("<div class='aa-active-exception-filter'></div>").kendoDialog({
        width: "700px",
        title: "Exception Filter Settings",
        closable: false,
        modal: true,
        content: content,
        actions: [{
            text: "Update",
            primary: true,
            action: function () {
                var formData = form.serialize();
                viewModel.updateSettings($.proxy(view.close, view), formData);
            }
        },
        {
            text: "Cancel"
        }],
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");

    return view;
});