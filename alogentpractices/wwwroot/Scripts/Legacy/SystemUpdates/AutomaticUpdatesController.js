var AutomaticUpdatesController = (function(service, $, undefined) {
    var publicApi = {};

    publicApi.checkForUpdates = function(updateServerUrl, version) {
        var promise = service.checkForUpdates(version, function(data) {
            if (data.CanUpdate)
                displayUpdateNotification(updateServerUrl, data);
            else
                displayUpdatedNotification();
        });

        promise.fail(function(e) {
            displayErrorNotification(updateServerUrl);
        });

        return promise;
    };

    function displayErrorNotification(updateServerUrl) {
        $('#updateNotification .title').text('Unable to check for updates');
        $('#updateNotification .description').text("The license server is currently unavailable. This might be due to access being blocked, maintenance, or an error could have occurred during the update check. If you believe you are seeing this message in error, or you believe there might be a service outage, please contact AccuSystems.");
        $('#updateNotification').addClass('elevated');

        $('#updateNotification').css('opacity', 0)
            .slideDown('slow')
            .animate({ opacity: 1 }, { queue: false, duration: 2000 });
    };

    function displayUpdatedNotification() {
        $('#updateNotification .title').removeClass('title').html('<span><i class="aa-icon fas fa-check-circle fa-fw" aria-hidden="true"></i> You are running the latest version of AccuAccount.</span>');
        $('#updateNotification .description').hide();

        $('#updateNotification').css('opacity', 0)
                                .slideDown('slow')
                                .animate({ opacity: 1 }, { queue: false, duration: 2000 });
    };

    function displayUpdateNotification(updateServerUrl, updateInfo) {
        $('#update-link').attr('href', updateInfo.ServerVersionDownloadUrl);
        $('#updatenotes-link').attr('href', updateInfo.ServerVersionReleaseNotesUrl);

        switch (updateInfo.ServerVersionPriority) {
            case 0:
                $('#updateNotification').addClass('none');
                break;
            case 1:
                $('#updateNotification .title').prepend('Important ');
                $('#updateNotification').addClass('elevated');
                break;
            case 2:
                $('#updateNotification .title').prepend('Critical ');
                $('#updateNotification').addClass('critical');
                break;
        }

        $('#updateNotification').css('opacity', 0)
                                .slideDown('slow')
                                .animate({ opacity: 1 }, { queue: false, duration: 2000 });
    };

    return publicApi;
});