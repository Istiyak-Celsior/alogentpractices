var MyUploadsFileNotMovedView = (function (name) {
    return $("<div></div>").kendoDialog({
        title: kendo.format("{0} failed to move", name),
        content: $("#dashboard-myuploads-moveerror").html(),
        width: "520px"
    }).data("kendoDialog");
});