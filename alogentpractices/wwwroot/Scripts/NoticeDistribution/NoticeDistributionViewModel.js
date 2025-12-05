var NoticeDistributionViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (webapi, dialogService, gridHelper) {
            ViewModel.fn.init.call(this);

            let noticeClient = new NoticeDistributionClient(webapi);            

            this.initDistribution = function() {
                let request = noticeClient.getPackage();

                request.done(response => {
                    var package = new NoticeDistributionPackage();

                    var deliverableModels   = response.deliverable.map(m => new Notice(m));
                    var undeliverableModels = response.undeliverable.map(m => new PendingNotices(m));
                    var inprocessModels     = response.inProcess.map(m => new NoticeEnvelope(m));
    
                    this.set("unsentNotices", new UnsentNoticesViewModel(noticeClient, dialogService, gridHelper, package));
                    this.set("pendingNotices", new PendingNoticesViewModel(noticeClient, dialogService, gridHelper, package));
                    this.set("inProcessNotices", new InProcessNoticesViewModel(noticeClient, dialogService, gridHelper, package));
                    this.set("sentNotices", new SentNoticesViewModel(noticeClient, dialogService, package));

                    package.addDeliverable(deliverableModels);
                    package.addUndeliverable(undeliverableModels);
                    package.addInProcess(inprocessModels);
                });

                return request;
            };
        }
    });

})(window.kendo.jQuery, window.kendo);