var ProductLicensingAdminView = View.extend({
    init: function (element, viewModel) {
        View.fn.init.call(this, element, viewModel);
    },
    ready: function (element, viewModel) {
        var that = this;
        
        element.kendoTooltip({ filter: "a[title], span[title]", position: 'top' });

        viewModel.load()
                 .done(function () {
                     View.fn.ready.call(that, element, viewModel);
                     $("#content").fadeIn();
                     $("footer").fadeIn();
                 });
    }
});