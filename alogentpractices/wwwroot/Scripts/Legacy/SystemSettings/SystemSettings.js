function CoreService() {
    var self = this;

    self.getSystemSettings = function (callback) {
        $.ajax({
            url: 'services/coresvc/getsystemsettings',
            method: 'GET',
            cache: false
        })
        .fail(function(e) {
            $("#error-text").text("Settings are unavailable because of an error (" + e.statusText + ").");
            $("#save-error").show();
        })
        .done(function (data) {
            var systemSettings = new SystemSettingsDTO();

            systemSettings.SiteConnectionString              = data.SiteConnectionString;
            systemSettings.ReportConnectionString            = data.ReportConnectionString;
            systemSettings.ScannedImagesPath                 = data.ScannedImagesPath;
            systemSettings.WebSitePath                       = data.WebSitePath;
            systemSettings.EnableWindowsSecurity             = data.EnableWindowsSecurity;
            systemSettings.EnableBranchSecurity              = data.EnableBranchSecurity;
            systemSettings.ScannedFilesPath                  = data.ScannedFilesPath;
            systemSettings.ServerUrl                         = data.ServerUrl;
            systemSettings.UploadLocalPath                   = data.UploadLocalPath;
            systemSettings.UploadUnc                         = data.UploadUnc;
            systemSettings.BaseFolder                        = data.BaseFolder;
            systemSettings.EnableAmountFilterActivation      = data.EnableAmountFilterActivation;
            systemSettings.DisableRtev                       = data.DisableRtev;
            systemSettings.BranchSecurityLevel               = data.BranchSecurityLevel;
            systemSettings.DaysToKeepLogs                    = data.DaysToKeepLogs;
            systemSettings.OverrideWorkstationOutputFormat   = data.OverrideWorkstationOutputFormat;
            systemSettings.GlobalWorkstationOutputFormat     = data.GlobalWorkstationOutputFormat;
            systemSettings.PurgeEvaluateTimeout              = data.PurgeEvaluateTimeout;
            systemSettings.PurgeExecuteTimeout               = data.PurgeExecuteTimeout;
            systemSettings.PurgeReportTimeout                = data.PurgeReportTimeout;
            systemSettings.EnablePurgeAdvancedOptions        = data.EnablePurgeAdvancedOptions;
            systemSettings.DocumentSchedulerSqlCmdTimeout    = data.DocumentSchedulerSqlCmdTimeout;
            systemSettings.ExceptionValidatorDatabaseTimeout = data.ExceptionValidatorDatabaseTimeout;
            callback(systemSettings);
        });
    };

    self.saveSystemSettings = function (systemSettings, successCallback, failureCallback) {
        $.ajax({
            url: 'services/coresvc/savesystemsettings',
            method: 'POST',
            cache: false,
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify(systemSettings),
            success: successCallback(),
            failure: function (data) {
                failureCallback(data);
            }
        });
    };
}

function DisplaySystemSettings(systemSettings) {
    $('#uxSiteConnectionString').val(systemSettings.SiteConnectionString);
    $('#uxHiddenSiteConnectionString').val(systemSettings.SiteConnectionString);
    $('#uxScannedImagesPath').val(systemSettings.ScannedImagesPath);
    $('#uxWebSitePath').val(systemSettings.WebSitePath);
    $('#uxReportingConnectionString').val(systemSettings.ReportConnectionString);
    $('#uxHiddenReportingConnectionString').val(systemSettings.ReportConnectionString);
    $('#uxScannedFilesPath').val(systemSettings.ScannedFilesPath);
    $('#uxServerUrl').val(systemSettings.ServerUrl);
    $('#uxUploadLocalPath').val(systemSettings.UploadLocalPath);
    $('#uxUploadUnc').val(systemSettings.UploadUnc);
    $('#uxBaseFolder').val(systemSettings.BaseFolder);
    $('#uxDaysToKeepLogs').val(systemSettings.DaysToKeepLogs);
    $('#purge-evaluate-timeout').val(systemSettings.PurgeEvaluateTimeout / 60);
    $('#purge-execute-timeout').val(systemSettings.PurgeExecuteTimeout / 60);
    $('#purge-report-timeout').val(systemSettings.PurgeReportTimeout / 60);
    $('#ev-database-timeout').val(systemSettings.ExceptionValidatorDatabaseTimeout);
    $('#documentScheduler-sqlCmdTimeout').val(systemSettings.DocumentSchedulerSqlCmdTimeout / 60);

    if (systemSettings.BranchSecurityLevel == 'DU') {
        SetBranchSecurity('uxBranchSecurityFull');
    }
    else if (systemSettings.BranchSecurityLevel == 'DO') {
        SetBranchSecurity('uxBranchSecurityPartial');
    }
    else if (systemSettings.BranchSecurityLevel == 'XX') {
        SetBranchSecurity('uxBranchSecurityNone');
    }

    if (systemSettings.EnableBranchSecurity) {
        $('#uxEnableBranchSecurity').data('kendoDropDownList').value('1');
    } else {
        $('#uxEnableBranchSecurity').data('kendoDropDownList').value('0');
    }

    if (systemSettings.EnableWindowsSecurity) {
        $('#uxEnableWindowsSecurity').data('kendoDropDownList').value('1');
    } else {
        $('#uxEnableWindowsSecurity').data('kendoDropDownList').value('0');
    }

    $('#uxOverrideWorkstationOutputFormat').data('kendoDropDownList').value(systemSettings.OverrideWorkstationOutputFormat);

    $('#uxGlobalWorkstationOutputFormat').data('kendoDropDownList').value(systemSettings.GlobalWorkstationOutputFormat);

    $('#uxEnableAmountFilterActivation').data('kendoDropDownList').value(systemSettings.EnableAmountFilterActivation);

    $('select#enable-advanced-purge-options option').filter(function () {
        return $(this).val() == systemSettings.EnablePurgeAdvancedOptions;
    }).prop('selected', true);

    if (systemSettings.EnablePurgeAdvancedOptions == '1') {
        $('#enable-advanced-purge-options').prop('checked', true);
    } else {
        $('#enable-advanced-purge-options').prop('checked', false);
    }

    $('#uxDisableRtev').data('kendoDropDownList').value(systemSettings.DisableRtev);

    $(function () {
        if ($('#uxEnableBranchSecurity').data('kendoDropDownList').value() == '1') {
            $('#uxBranchSecurityWrapper').show();
        }
    });

    $('#uxEnableBranchSecurity').change(function () {
        if ($('#uxEnableBranchSecurity').data('kendoDropDownList').value() == '1') {
            $('#uxBranchSecurityWrapper').show();
        }
        else {
            $('#uxBranchSecurityWrapper').hide();
        }
    });

    $(function () {
        if ($('#uxOverrideWorkstationOutputFormat').data('kendoDropDownList').value() == '1') {
            $('#uxGlobalWorkstationOutputFormatWrapper').show();
        }
    });

    $('#uxOverrideWorkstationOutputFormat').change(function () {
        if ($('#uxOverrideWorkstationOutputFormat').data('kendoDropDownList').value() == '1') {
            $('#uxGlobalWorkstationOutputFormatWrapper').show();
        }
        else {
            $('#uxGlobalWorkstationOutputFormatWrapper').hide();
        }
    });

    $('#uxBranchSecurityFull').click(function () {
        systemSettings.BranchSecurityLevel = 'DU';
        SetBranchSecurity('uxBranchSecurityFull');
    });

    $('#uxBranchSecurityPartial').click(function() {
        systemSettings.BranchSecurityLevel = 'DO';
        SetBranchSecurity('uxBranchSecurityPartial');
    });

    $('#uxBranchSecurityNone').click(function () {
        systemSettings.BranchSecurityLevel = 'XX';
        SetBranchSecurity('uxBranchSecurityNone');
    });

    $('#uxApplicationConnectionDetails').click(function () {
        var connString = encodeURI($('#uxSiteConnectionString').val());
        openKendoDialog('Manage Connection String', 'ManageConnectionString.asp?elementid=SiteConnectionString&string=' + connString, 280, 460);
    });

    $('#uxReportingConnectionDetails').click(function () {
        var connString = encodeURI($('#uxReportingConnectionString').val());
        openKendoDialog('Manage Connection String', 'ManageConnectionString.asp?elementid=ReportingConnectionString&string=' + connString, 280, 460);
    });
}

function SetBranchSecurity(element) {
    $('#uxBranchSecurityFull').removeClass('k-primary');
    $('#uxBranchSecurityPartial').removeClass('k-primary');
    $('#uxBranchSecurityNone').removeClass('k-primary');
    $('#' + element).addClass('k-primary');
}

function SetElementValidationState(element, isValid) {
    if (isValid) {
        element.css({
            'background-color': ''
        });
    }
    else {
        element.css({
            'background-color': '#FFBEBE'
        });
    }
}

function OnValidateSettings() {
    var isValidSiteConnectionString = ValidateParentInput('uxSiteConnectionString');
    var isValidReportConnectionString = ValidateParentInput('uxReportConnectionString');
    var isValidScannedImagesPath = ValidateParentInput('uxScannedImagesPath');
    var isValidWebSitePath = ValidateParentInput('uxWebSitePath');
    var isValidScannedFilesPath = ValidateParentInput('uxScannedFilesPath');
    var isValidServerUrl = ValidateParentInput('uxServerUrl');
    var isValidUploadLocalPath = ValidateParentInput('uxUploadLocalPath');
    var isValidUploadUnc = ValidateParentInput('uxUploadUnc');
    var isValidBaseFolder = ValidateParentInput('uxBaseFolder');
    var isValidDaysToKeepLogs = ValidateDaysToKeepLogsSizeLimit();
    var isValidPurgeEvaluateTimeout = ValidateParentInput('purge-evaluate-timeout');
    var isValidPurgeExecuteTimeout = ValidateParentInput('purge-execute-timeout');
    var isValidPurgeReportTimeout = ValidateParentInput('purge-report-timeout');
    var isNumericalPurgeEvaluateTimeout = ValidateNumericalInput('purge-evaluate-timeout');
    var isNumericalPurgeExecuteTimeout = ValidateNumericalInput('purge-execute-timeout');
    var isNumericalPurgeReportTimeout = ValidateNumericalInput('purge-report-timeout');
    var isNumericalDocumentSchedulerSqlCmdTimeout = ValidateNumericalInput('documentScheduler-sqlCmdTimeout');
    var isAboveZeroDocumentSchedulerSqlCmdTimeout = ValidateAboveZero('documentScheduler-sqlCmdTimeout');
    var isNumericalEValidatorDatabaseTimeout = ValidateNumericalInput('ev-database-timeout');
    var isAboveZeroEValidatorDatabaseTimeout = ValidateAboveZero('ev-database-timeout');

    var isValid = (isValidSiteConnectionString &&
                  isValidReportConnectionString &&
                  isValidScannedImagesPath &&
                  isValidWebSitePath &&
                  isValidScannedFilesPath &&
                  isValidServerUrl &&
                  isValidUploadLocalPath &&
                  isValidUploadUnc &&
                  isValidBaseFolder &&
                  isValidDaysToKeepLogs &&
                  isValidPurgeEvaluateTimeout &&
                  isValidPurgeExecuteTimeout &&
                  isValidPurgeReportTimeout &&
                  isNumericalPurgeEvaluateTimeout &&
                  isNumericalPurgeExecuteTimeout &&
                  isNumericalPurgeReportTimeout &&
                  isNumericalDocumentSchedulerSqlCmdTimeout &&
                  isAboveZeroDocumentSchedulerSqlCmdTimeout &&
                  isNumericalEValidatorDatabaseTimeout &&
                  isAboveZeroEValidatorDatabaseTimeout);

    if (isValid) {
        EnableUpdateButton();
    } else {
        DisableUpdateButton();
    }
}

function DisableUpdateButton() {
    $('#uxUpdateButton').css({
        'opacity': '.25',
        'pointer-events': 'none',
        'cursor': 'default'
    });
    $('#uxUpdateButton').bind('click', false);
}

function EnableUpdateButton() {
    $('#uxUpdateButton').css({
        'opacity': 'inherit',
        'pointer-events': 'inherit',
        'cursor': 'pointer'
    });
    $('#uxUpdateButton').unbind('click', false);
}

function ValidateDaysToKeepLogsSizeLimit() {
    var element = $('#uxDaysToKeepLogs');
    var elementValue = element.val();
    var num = Number(elementValue);

    var validInt = elementValue == '0' || ((num % 1) == 0 && num > 0 && num < 91);
   
    if (!validInt)
    {
        SetElementValidationState(element, false);
        return false;
    }

    SetElementValidationState(element, true);
    return true;
}

function ValidateParentInput(childElement) {
    var element = $('#' + childElement);

    if (element.val() == '') {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function ValidateNumericalInput(childElement) {
    var element = $('#' + childElement);
    var valueIsNumeric = $.isNumeric(element.val());

    if (!valueIsNumeric) {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function ValidateAboveZero(childElement) {
    var element = $('#' + childElement);
    var elementValue = element.val();
    var valueIsAboveZero = elementValue > 0;

    if (!valueIsAboveZero) {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function ValidateChildInput(childElement, parentElement) {
    var element = $('#' + childElement);

    if ($('#' + parentElement).val() == '1' && element.val() == '') {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function UpdateConnectionStringBindings() {
    $('#uxHiddenSiteConnectionString').trigger('keyup');
    $('#uxHiddenReportingConnectionString').trigger('keyup');
}

function EnableFormBindings(service, systemSettings) {
    $('#uxHiddenSiteConnectionString').on('change paste keyup', function () {
        systemSettings.SiteConnectionString = $(this).val();
        OnValidateSettings();
    });

    $('#uxScannedImagesPath').on('change paste keyup', function () {
        systemSettings.ScannedImagesPath = $(this).val();
        OnValidateSettings();
    });

    $('#uxWebSitePath').on('change paste keyup', function () {
        systemSettings.WebSitePath = $(this).val();
        OnValidateSettings();
    });

    $('#uxHiddenReportingConnectionString').on('change paste keyup', function () {
        systemSettings.ReportConnectionString = $(this).val();
        OnValidateSettings();
    });

    $('#uxEnableWindowsSecurity').on('change paste keyup', function () {
        systemSettings.EnableWindowsSecurity = $('#uxEnableWindowsSecurity').data('kendoDropDownList').value() == '1';
        OnValidateSettings();
    });

    $('#uxEnableBranchSecurity').on('change paste keyup', function () {
        systemSettings.EnableBranchSecurity = $('#uxEnableBranchSecurity').data('kendoDropDownList').value() == '1';
        OnValidateSettings();
    });

    $('#uxEnableAmountFilterActivation').on('change paste keyup', function () {
        systemSettings.EnableAmountFilterActivation = $('#uxEnableAmountFilterActivation').data('kendoDropDownList').value();
        OnValidateSettings();
    });

    $('#uxDisableRtev').on('change paste keyup', function () {
        systemSettings.DisableRtev = $('#uxDisableRtev').data('kendoDropDownList').value();
        OnValidateSettings();
    });

    $('#uxDaysToKeepLogs').on('change paste keyup', function () {
        systemSettings.DaysToKeepLogs = $(this).val();
        OnValidateSettings();
    });

    $('#uxScannedFilesPath').on('change paste keyup', function () {
        systemSettings.ScannedFilesPath = $(this).val();
        OnValidateSettings();
    });

    $('#uxServerUrl').on('change paste keyup', function () {
        systemSettings.ServerUrl = $(this).val();
        OnValidateSettings();
    });

    $('#uxDaysToKeepLogs').on('change paste keyup', function () {
        systemSettings.DaysToKeepLogs = $(this).val();
        OnValidateSettings();
    });

    $('#uxUploadLocalPath').on('change paste keyup', function () {
        systemSettings.UploadLocalPath = $(this).val();
        OnValidateSettings();
    });

    $('#uxUploadUnc').on('change paste keyup', function () {
        systemSettings.UploadUnc = $(this).val();
        OnValidateSettings();
    });

    $('#uxBaseFolder').on('change paste keyup', function () {
        systemSettings.BaseFolder = $(this).val();
        OnValidateSettings();
    });

    $('#uxOverrideWorkstationOutputFormat').on('change paste keyup', function () {
        systemSettings.OverrideWorkstationOutputFormat = $('#uxOverrideWorkstationOutputFormat').data('kendoDropDownList').value();
    });

    $('#uxGlobalWorkstationOutputFormat').on('change paste keyup', function () {
        systemSettings.GlobalWorkstationOutputFormat = $('#uxGlobalWorkstationOutputFormat').data('kendoDropDownList').value();
    });

    $('#purge-evaluate-timeout').on('change paste keyup', function () {
        systemSettings.PurgeEvaluateTimeout = $(this).val() * 60;
        OnValidateSettings();
    });

    $('#purge-execute-timeout').on('change paste keyup', function () {
        systemSettings.PurgeExecuteTimeout = $(this).val() * 60;
        OnValidateSettings();
    });

    $('#purge-report-timeout').on('change paste keyup', function () {
        systemSettings.PurgeReportTimeout = $(this).val() * 60;
        OnValidateSettings();
    });

    $('#documentScheduler-sqlCmdTimeout').on('change paste keyp', function () {
        systemSettings.DocumentSchedulerSqlCmdTimeout = $(this).val() * 60;
        OnValidateSettings();
    });

    $('#ev-database-timeout').on('change paste keyp', function () {
        systemSettings.ExceptionValidatorDatabaseTimeout = $(this).val();
        OnValidateSettings();
    });

    $('#enable-advanced-purge-options').on('change paste keyup', function () {
        if ($('#enable-advanced-purge-options').prop('checked')) {
            systemSettings.EnablePurgeAdvancedOptions = '1';
        } else {
            var alertMessage = 'Disabling the Advanced Purge Setting will reset any existing advanced options.  This will overwrite options currently configured and update<br/>the purge status accordingly when the next purge evaluation is executed.  Are you sure you wish to continue?';
            kendo.confirm(alertMessage).then(function () {
                systemSettings.EnforceSimpleMode = true;
                systemSettings.EnablePurgeAdvancedOptions = '0';
            }, function () {
                $('#enable-advanced-purge-options').prop('checked', true);
                systemSettings.EnforceSimpleMode = false;
                systemSettings.EnablePurgeAdvancedOptions = '1';
            });
        }
    });

    $('#uxUpdateButton').click(function () {
        if ($('#uxUpdateButton').css('opacity') != .25) {
            UpdateSystemSettings(service, systemSettings);
        }
    });
}

function UpdateSystemSettings(service, systemSettings) {
    $('#uxWorkingIcon').show();
    DisableUpdateButton();

    service.saveSystemSettings(systemSettings, function () {
        $('html, body').scrollTop(0);
        $('#save-success').show();
        $('#uxWorkingIcon').hide();
    }, function (data) {
        $('#uxWorkingIcon').hide();
        alert(data.d);
    });

    if (systemSettings.EnforceSimpleMode) {
        $('#form-enforce-simple').submit();
    } else {
        EnableUpdateButton();
    }
}

var GlobalService;
var GlobalSettings;

$(function () {
    var service = new CoreService();

    service.getSystemSettings(function (systemSettings) {
        EnableFormBindings(service, systemSettings);
        DisplaySystemSettings(systemSettings);

        OnValidateSettings();

        GlobalService = service;
        GlobalSettings = systemSettings;
    });
});