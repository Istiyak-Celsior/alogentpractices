var SystemUpdatesService = (function ($, undefined) {
    var publicApi = {};

    publicApi.getHistory = function(callback) {
        $.ajax({
            url: 'api/systemupdates/gethistory',
            method: 'GET',
            cache: false
        })
        .done(function(data) {
            callback(data);
        });
    };

    publicApi.getLog = function (updateHistoryId, callback) {
        $.ajax({
            url: 'api/systemupdates/downloadlog?updateHistoryId=' + updateHistoryId,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    return publicApi;
});