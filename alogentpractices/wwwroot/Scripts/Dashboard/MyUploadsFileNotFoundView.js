var MyUploadsFileNotFoundView = (function(name) {
    return $("<div></div>").kendoDialog({
        title: kendo.format("{0} is unavailable", name),
        content: $("#dashboard-myuploads-fileerror").html(),
        width: "520px"
    }).data("kendoDialog");
});