var ActionEventService = (function (api) {
    var publicApi = {};

    publicApi.updateEventActionOrder = function (ids, successCallback, failureCallback) {
        api.post({
            controller: 'actionevent',
            action: 'updateactioneventorder',
            data: { 'data': ids },
            success: function (response) {
                successCallback(response);
            },
            error: function (response) {
                failureCallback(response);
            }
        });
    };

    publicApi.getCloneableWorkflowTypes = function (callback) {
        $.ajax({
            url: 'include/services/actionevents/actioneventservices.asp?srv=list',
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            if (data === 'NOSESSION') {
                window.location.reload();
            } else {
                callback($.parseJSON(data));
            }
        });
    };

    publicApi.cloneWorkflow = function (sourceLoanTypeId, targetLoanTypeId, successCallback, failureCallback) {
        $.ajax({
            url: 'include/services/actionevents/actioneventservices.asp?srv=clone&src=' + sourceLoanTypeId + '&dst=' + targetLoanTypeId,
            method: 'GET',
            cache: false,
            success: function () {
                var url = window.location.href;

                var loantypeIndex = url.lastIndexOf('&ltid');
                if (loantypeIndex !== -1) {
                    url = url.substring(0, loantypeIndex);
                }

                url = url + '&ltid={' + targetLoanTypeId + '}';

                successCallback(url);
            },
            error: function (xhr) {
                failureCallback(xhr);
            }
        });
    };

    return publicApi;
});