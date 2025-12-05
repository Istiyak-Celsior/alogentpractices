var DocumentService = (function (api) {
    var publicApi = {}

    publicApi.updateGroupOrder = function (groups, successCallback, failureCallback) {
        api.post({
            controller: 'document',
            action: 'updategrouporder',
            data: { 'data' : groups },
            success: function (response) {
                successCallback(response);
            },
            error: function (response) {
                failureCallback(response);
            }
        });
    };

    publicApi.updateTabOrder = function (tabs, successCallback, failureCallback) {
        api.post({
            controller: 'document',
            action: 'updatetaborder',
            data: { 'data' : tabs },
            success: function (response) {
                successCallback(response);
            },
            error: function (response) {
                failureCallback(response);
            }
        });
    };

    return publicApi;
});

var DocumentDefinitionService = (function (api) {
    var publicApi = {}

    publicApi.updateDefinitionOrder = function (defs, successCallback, failureCallback) {
        api.post({
            controller: 'document',
            action: 'updatedefinitionorder',
            data: { 'data': defs },
            success: function (response) {
                successCallback(response);
            },
            error: function (response) {
                failureCallback(response);
            }
        });
    };

    return publicApi;
});