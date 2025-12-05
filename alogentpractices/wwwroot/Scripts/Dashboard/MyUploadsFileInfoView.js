var MyUploadsFileInfoView = (function (info) {
    return $("<div id=\"document-info-window\"></div>").kendoDialog({
        width: "700px",
        height: "430px",
        closable: false,
        actions: [{
            text: "Close",
            primary: true
        }],
        visible: false,
        content: kendo.template($("#dashboard-myuploads-fingerprinting").html())(info),
        title: "Document Upload Details",
        modal: true,
        close: function () {
            this.destroy();
        }
    }).data("kendoDialog");
});