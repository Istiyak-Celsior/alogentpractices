var CoreLinkAdminView = View.extend({
    init: function (element, viewModel) {
        View.fn.init.call(this, element, viewModel);
    },
    ready: function (element, viewModel) {
        var that = this;
        
        element.kendoTooltip({ filter: "a[title], span[title]", position: 'top' });

        $("body").kendoTooltip({
            filter: "a[title], span[title], i[title]:not(i[title=''])", 
            position: 'top',
            content: function(e) {
                var text = $(e.target).data("title");
                return "<div style='max-width: 20em'>" + text + "</div>";
            }
        });

        viewModel.load()
                 .done(function () {
                     View.fn.ready.call(that, element, viewModel);
                     $("#content").fadeIn();
                     $("footer").fadeIn();
                 });

        viewModel.bind("editField",
            function(e) {
                that.disableElement(e.container.find("input[name=Pattern]"));
                that.disableElement(e.container.find("input[name=Description]"));
            });

    },
    disableElement: function(element) {
        element.prop("disabled", true);
        element.attr("readonly", "readonly");
        element.css({ "background-color": "#ececec" });
    }
});