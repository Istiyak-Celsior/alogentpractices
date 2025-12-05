var SentNoticesViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (noticeClient, dialogService) {
            ViewModel.fn.init.call(this);

            this._dialogService = dialogService;

            this.set("notices", this._notices(this, noticeClient));
        },
        _notices: function(viewModel, noticeClient) {
            return new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        /*let response = noticeClient.getNotices();
                        let models   = [];
                        
                        response.done(data => {
                            //let policies = data.map(p => that._noticeClient.maps.mapExceptionPolicy(p));
                            //let models   = policies.map(p => new NoticeLetterSetExceptionPolicyModel(p));
                        
                            data.forEach(d => {
                                let model = new NoticeLetter(d);
                                
                                models.push(model);
                            });
                            
                            options.success(models);
                        });
                        
                        response.fail(function (result) {
                            options.error(result);
                        });*/
                    }
                },
                sort: [
                    { field: "RecordName" },
                    { field: "RecordNumber" },
                    { field: "RecordType" }
                ]
            });
        }
    });

})(window.kendo.jQuery, window.kendo);