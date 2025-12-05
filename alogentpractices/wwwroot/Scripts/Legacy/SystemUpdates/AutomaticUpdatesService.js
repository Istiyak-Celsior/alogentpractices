var AutomaticUpdatesService = (function($, undefined) {
    var publicApi = {};

    publicApi.checkForUpdates = function (version, callback) {
        return $.ajax({
            url: 'api/systemupdates/checkforupdates?version=' + version,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    return publicApi;
});