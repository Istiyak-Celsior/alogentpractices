var MyUploadsFileMoveView = (function (widget, template) {
    var content = $(template);
    var form = content.find("#form-upload-quickmove");
    var view = $("<div></div>").kendoDialog({
        width: "700px",
        title: "Move Document",
        closable: false,
        modal: true,
        content: content,
        actions: [{
            text: "Update",
            primary: true,
            action: function () {
                var formData = form.serialize();
                widget.endMove(formData);
            }
        },
        {
            text: "Cancel"
        }],
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");

    $("#target-value").kendoDropDownList();

    return view;
});