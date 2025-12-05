var ExceptionValidatorService = (function () {
    var publicApi = {}

    publicApi.processByType = function (proccessType, processId, redirecturl) {
        $.ajax({
            url: 'api/exceptionvalidator/processbytype?processtype=' + proccessType + '&processid=' + processId,
            method: "GET",
            cache: false
        })
        .done(function () {
            if (redirecturl != '') {
                window.location.href = redirecturl;
            }
        })

    };

    return publicApi;
});