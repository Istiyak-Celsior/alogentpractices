var CopyCreditDocumentsService = (function () {
    var publicApi = {}

    publicApi.copyCreditDocuments = function (sourceCustomerId, targetCustomerId, userLogin, callback) {
        $.ajax({
            url: 'api/copycreditdocuments/copycreditdocuments?sourcecustomerid=' + sourceCustomerId + '&targetcustomerid=' + targetCustomerId +'&userlogin=' + userLogin,
            method: 'GET',
            cache: false
        })
        .success(function (data) {
            callback(data);
        });
    };

    publicApi.getCustomerInfo = function (customerId, callback) {
        $.ajax({
            url: 'api/copycreditdocuments/getcustomerinfo?customerid=' + customerId,
            method: 'GET',
            cache: false,
            async: false
        })
        .success(function (data) {
            callback(data);
        });
    };

    return publicApi;
});