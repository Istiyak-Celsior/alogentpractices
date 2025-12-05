var PDFModuleService = (function () {
    var publicApi = {}

    publicApi.getHistory = function(searchQuery, limit, convertedFilter, callback) {
        $.ajax({
            url: 'api/pdfmodule/gethistory',
            method: 'POST',
            cache: false,
            contentType: 'application/json',
            data: JSON.stringify({ 'Query': searchQuery, 'Limit': limit, 'ConvertedFilter': convertedFilter })
        })
        .done(function(data) {
            callback(data);
        });
    };

    publicApi.getBlockedDocuments = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/getblockeddocuments',
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    publicApi.unblockAllDocuments = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/unblockalldocuments',
            method: 'GET',
            cache: false
        })
        .done(function () {
            callback();
        });
    };

    publicApi.unblockDocuments = function(documents, callback) {
        $.ajax({
            url: 'api/pdfmodule/unblockdocuments',
            data: JSON.stringify(documents),
            contentType: 'application/json',
            method: 'POST',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    publicApi.getSettings = function (callback) {
        $.ajax({
            url: 'api/pdfmodule/getsettings',
            method: 'GET',
            cache: false
        })
        .done(function(data) {
            var settings = new PDFServiceSettingsDTO();

            settings.IsActive = data.IsActive;
            settings.IsBackupEnabled = data.IsBackupEnabled;
            settings.IsConversionEnabled = data.IsConversionEnabled;
            settings.IsAutomaticPageRecognitionEnabled = data.IsAutomaticPageRecognitionEnabled;
            settings.IsSearchableTextEnabled = data.IsSearchableTextEnabled;
            settings.RunOnTimeframe = data.RunOnTimeframe;
            settings.StartTime = data.StartTime;
            settings.EndTime = data.EndTime;
            settings.ServiceDays = data.ServiceDays;
            settings.BackupDirectory = data.BackupDirectory;

            callback(settings);
        });
    };

    publicApi.getDocumentCountByFileType = function (callback) {
        $.ajax({
            url: 'api/pdfmodule/getdocumentcountbyfiletype',
            method: 'GET',
            cache: false
        }).done(function (data) {
            callback(data);
        });
    };

    publicApi.getDocumentCountByCustomerType = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/getdocumentcountbycustomertype',
            method: 'GET',
            cache: false
        }).done(function(data) {
            callback(data);
        });
    };

    publicApi.getDocumentCountByAccountType = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/getdocumentcountbyaccounttype',
            method: 'GET',
            cache: false
        }).done(function(data) {
            callback(data);
        });
    };

    publicApi.getEstimatedDiskSpaceForBackup = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/getestimateddiskspaceforbackup',
            method: 'GET',
            cache: false
        }).done(function(data) {
            callback(data);
        });
    };

    publicApi.getEstimatedCompletionTimeframe = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/getestimatedcompletiontimeframe',
            method: 'GET',
            cache: false
        }).done(function(data) {
            callback(data);
        });
    };

    publicApi.getDocumentCountHistory = function(converted, callback) {
        $.ajax({
            url: 'api/pdfmodule/getdocumentcounthistory?converted=' + converted,
            method: 'GET',
            cache: false
        })
        .done(function (data) {
                callback(data);
        });
    };

    publicApi.getHistoryLog = function(historyId, callback) {
        $.ajax({
            url: 'api/pdfmodule/gethistorylog?historyId=' + historyId,
            method: 'GET',
            cache: false
        })
        .done(function(data) {
            callback(data);
        });
    };

    publicApi.getPageRecognitionDefinitions = function(callback) {
        $.ajax({
            url: 'api/pdfmodule/getpagerecognitiondefinitions',
            method: 'GET',
            cache: false
        })
        .done(function (data) {
            callback(data);
        });
    };

    publicApi.addPageRecognitionDefinition = function (definition, successCallback, failureCallback) {
        $.ajax({
            url: 'api/pdfmodule/AddPageRecognitionDefinition',
            contentType: 'application/json; charset=utf-8',
            method: 'POST',
            cache: false,
            data: JSON.stringify(definition),
            dataType: 'json'
        })
        .fail(function(response) {
            failureCallback(response.responseJSON);
        })
        .done(function (definitionId) {
            successCallback(definitionId);
        });
    };

    publicApi.updatePageRecognitionDefinition = function(definition, successCallback, failureCallback) {
        $.ajax({
            url: 'api/pdfmodule/UpdatePageRecognitionDefinition',
            contentType: 'application/json; charset=utf-8',
            method: 'POST',
            cache: false,
            data: JSON.stringify(definition),
            dataType: 'json'
        })
        .fail(function (response) {
            failureCallback(response.responseJSON);
        })
        .done(function (data) {
            successCallback(data);
        });
    };

    publicApi.deletePageRecognitionDefinition = function(definitionId, callback) {
        $.ajax({
            url: 'api/pdfmodule/DeletePageRecognitionDefinition?definitionId=' + definitionId,
            method: 'GET',
            cache: false
        })
        .done(function () {
            callback();
        });
    };

    publicApi.deletePageRecognitionPattern = function(patternId, callback) {
        $.ajax({
            url: 'api/pdfmodule/DeletePageRecognitionPattern?patternId=' + patternId,
            method: 'GET',
            cache: false
        })
        .done(function() {
            callback();
        });
    };

    publicApi.updatePageRecognitionPattern = function(pattern, successCallback, failureCallback) {
        $.ajax({
                url: 'api/pdfmodule/UpdatePageRecognitionPattern',
                contentType: 'application/json; charset=utf-8',
                method: 'POST',
                cache: false,
                data: JSON.stringify(pattern),
                dataType: 'json'
        })
        .fail(function (response) {
            failureCallback(response.responseJSON);
        })
        .done(function(data) {
            successCallback(data);
        });
    };

    publicApi.addPageRecognitionPattern = function (pattern, successCallback, failureCallback) {
        $.ajax({
            url: 'api/pdfmodule/AddPageRecognitionPattern',
            contentType: 'application/json; charset=utf-8',
            method: 'POST',
            cache: false,
            data: JSON.stringify(pattern),
            dataType: 'json'
        })
        .fail(function (response) {
            failureCallback(response.responseJSON);
        })
        .done(function (data) {
            successCallback(data);
        });
    };

    publicApi.saveSettings = function (settings, successCallback, failureCallback) {
        $.ajax({
            url: 'api/pdfmodule/savesettings',
            method: 'POST',
            cache: false,
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify(settings),
            success: successCallback(),
            failure: function(data) {
                failureCallback(data);
            }
        });
    };

    publicApi.testPageRecognitionDefinitions = function(data, successCallback, failureCallback) {
        $.ajax({
            url: 'api/pdfmodule/testpagerecognitiondefinitions',
            method: 'POST',
            cache: true,
            contentType: false,
            processData: false,
            data: data,
            success: function (data) { successCallback(data); },
            error: function (response) { failureCallback(response.responseJSON); }
        });
    };

    return publicApi;
});