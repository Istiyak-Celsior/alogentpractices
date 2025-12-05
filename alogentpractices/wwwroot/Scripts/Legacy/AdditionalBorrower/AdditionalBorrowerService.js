var AdditionalBorrowerService = (function () {
    var publicApi = {}

    // Gets an array of AdditionalBorrowerDTOs of the given loan
    publicApi.getAdditionalBorrowers = function (loanId, callback) {
        $.ajax({
            url: 'api/additionalborrower/getadditionalborrowers?loanId=' + loanId,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    // gets an array of BorrowerTypeDTOs filtered by accountClassId
    publicApi.getBorrowerTypes = function (accountClassId, callback) {
        $.ajax({
            url: 'api/additionalborrower/getborrowertypes?accountclassid=' + accountClassId,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    }

    publicApi.changePrimaryBorrower = function (newPrimaryBorrowerId, loanId, borrowerTypeId, successCallback, failureCallback) {
        $.ajax({
            url: 'api/additionalborrower/changeprimaryborrower?newPrimaryBorrowerId=' + newPrimaryBorrowerId +'&loanId=' + loanId + '&borrowerTypeId=' + borrowerTypeId,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            var additionalBorrower = new AdditionalBorrowerDTO();

            additionalBorrower.CustomerId = data.CustomerId;
            additionalBorrower.CustomerName = data.CustomerName;
            additionalBorrower.BusinessName = data.BusinessName;
            additionalBorrower.CustomerNumber = data.CustomerNumber;

            additionalBorrower.LoanId = data.LoanId.toUpperCase();
            additionalBorrower.LoanNumber = data.LoanNumber;

            additionalBorrower.BorrowerTypeId = data.BorrowerTypeId;
            additionalBorrower.BorrowerType = data.BorrowerType;

            successCallback(additionalBorrower);
        })
        .fail(function(xhr, textStatus, errorThrown) {
            failureCallback(xhr);
        });
    };

    return publicApi;
});