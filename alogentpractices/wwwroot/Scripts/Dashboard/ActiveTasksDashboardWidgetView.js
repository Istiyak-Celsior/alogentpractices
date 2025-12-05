var ActiveTasksDashboardWidgetView = (function (viewModel, template) {
    var content = $(template);
    var form    = content.find("#reassign-user-form");
    var title   = content.find("#page-title").val();

    var view = $("<div class='aa-active-task-dashboard-widget'></div>").kendoDialog({
        title: title,
        closable: false,
        modal: true,
        content: content,
        actions: [{
            text: "Update",
            primary: true,
            action: function () {
                var formData = form.serialize();
                viewModel.updateTask($.proxy(view.close, view), formData);
            }
        },
        {
            text: "Cancel"
        }],
        open: function () {
            // Did not use declarative syntax because the content is shared with legacy
            // parts of the system that cannot be data bound.
            $("#assigned-user-id").kendoDropDownList();
        },
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");

    return view;
});