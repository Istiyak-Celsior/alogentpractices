/* IN ORDER TO USE THESE FUNCTIONS THE FOLLOWING KENDO UI DEPENDENCIES ARE REQUIRED 
   - JQUERY.MIN.JS, - KENDO.CORE.MIN.JS, - KENDO.USEREVENTS.MIN.JS, - KENDO.DRAGANDDROP.MIN.JS
   - KENDO.POPUP.MIN.JS, - KENDO.FX.MIN.JS - ANIMATION FEATURE (OPTIONAL), - KENDO.WINDOW.MIN.JS

   <script type="text/javascript" src="Packages/kendo-ui/js/kendo.core.min.js"></script>
   <script type="text/javascript" src="Packages/kendo-ui/js/kendo.userevents.min.js"></script>
   <script type="text/javascript" src="Packages/kendo-ui/js/kendo.draganddrop.min.js"></script>
   <script type="text/javascript" src="Packages/kendo-ui/js/kendo.popup.min.js"></script>
   <script type="text/javascript" src="Packages/kendo-ui/js/kendo.window.min.js"></script>
*/

function resizeKendoDialog(height, width, recenter) {
    var dialogNew = $('#kendo-dialog').data('kendoWindow');
    dialogNew.wrapper.css({
        width: width,
        height: height
    });
    if (recenter) {
        dialogNew.center();
    }
}

function closeKendoDialog() {
    var dialogNew = $('#kendo-dialog').data('kendoWindow');
    dialogNew.close();
    dialogNew.destroy();
}

function openKendoWindow(title, url, height, width) {
    $('body').append('<div id="kendo-dialog"></div>');
    var dialog = $('#kendo-dialog');
    dialog.kendoWindow({
        width: width,
        height: height,
        title: title,
        visible: false,
        actions: ['Close'],
        iframe: true,
        content: url,
        close: function () {
            this.destroy();
        }
    }).data('kendoWindow');

    var dialogNew = dialog.data('kendoWindow');
    dialogNew.center().open();
}

function openKendoDialog(title, url, height, width) {
    $('body').append('<div id="kendo-dialog"></div>');
    var dialog = $('#kendo-dialog');
    dialog.kendoWindow({
        width: width,
        height: height,
        title: title,
        modal: true,
        visible: false,
        resizable: false,
        draggable: true,
        actions: ['Close'],
        iframe: true,
        content: url,
        close: function () {
            this.destroy();
        }
    }).data('kendoWindow');

    var dialogNew = dialog.data('kendoWindow');
    dialogNew.center().open();
}