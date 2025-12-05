var MyUploadsFileView = (function(file) {
    var width  = $(window).width() * .85;
    var height = $(window).height() * .85;

    return $("<div></div>").kendoWindow({
        title: (file.info && file.info.document) ? file.info.document : file.name(),
        content: kendo.format("{0}&dispositionType=inline", file.link),
        iframe: true,
        width:  width,
        height: height,
        modal: true,
        actions: [
            "Maximize",
            "Close"
        ]
    }).data("kendoWindow");
});