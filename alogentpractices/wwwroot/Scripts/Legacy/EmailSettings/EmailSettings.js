function CoreSettings() {
    var self = this;

    self.Server = '';
    self.Port = '';
    self.EnableSecureMail = '';
    self.EnableSsl = false;
    self.SecureEmailPhrase = '';
    self.UserName = '';
    self.Password = '';
    self.ServiceMailbox = '';
    self.DeliveryMethod = '';
    self.PickupDirectory = '';
    self.MaxMessageSize = '';
    self.UseDefaultCredentials = false;
    self.HasSendAsPolicy = false;
    self.RequireAuthentication = false;

    return self;
}

function CoreService() {
    var self = this;

    self.getEmailSettings = function (callback) {
        $.ajax({
            url: 'settings/smtp',
            method: 'GET',
            cache: false
        }).done(function (data) {
            settings.Server = data.Server;
            settings.Port = data.Port;
            settings.EnableSecureMail = data.EnableSecureMail;
            settings.EnableSsl = data.EnableSsl;
            settings.SecureEmailPhrase = data.SecureEmailPhrase;
            settings.UserName = data.UserName;
            settings.Password = data.Password;
            settings.ServiceMailbox = data.ServiceMailbox;
            settings.DeliveryMethod = data.DeliveryMethod;
            settings.PickupDirectory = data.PickupDirectory;
            settings.MaxMessageSize = data.MaxMessageSize;
            settings.UseDefaultCredentials = data.UseDefaultCredentials;
            settings.HasSendAsPolicy = data.HasSendAsPolicy;
            settings.RequireAuthentication = data.RequireAuthentication;

            callback(settings);
        });
    };

    self.saveEmailSettings = function (settings, successCallback, failureCallback) {
        $.ajax({
            url: 'settings/smtp',
            method: 'PUT',
            cache: false,
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({
                Server: settings.Server,
                Port: settings.Port,
                EnableSecureMail: settings.EnableSecureMail,
                EnableSsl: settings.EnableSsl,
                SecureEmailPhrase: settings.SecureEmailPhrase,
                UserName: settings.UserName,
                Password: settings.Password,
                ServiceMailbox: settings.ServiceMailbox,
                DeliveryMethod: settings.DeliveryMethod,
                PickupDirectory: settings.PickupDirectory,
                MaxMessageSize: settings.MaxMessageSize,
                UseDefaultCredentials: settings.UseDefaultCredentials,
                HasSendAsPolicy: settings.HasSendAsPolicy,
                RequireAuthentication: settings.RequireAuthentication
            }),
            success: successCallback(),
            failure: function (data) {
                failureCallback(data);
            }
        });
    };

    self.testEmailSettings = function (fromEmailAddress, toEmailAddress, settings, successCallback, failureCallback) {
        $.ajax({
            url: kendo.format("settings/smtp/verify?fromAddress={0}&toAddress={1}", fromEmailAddress, toEmailAddress),
            method: 'POST',
            cache: false,
            contentType: 'application/json',
            data: JSON.stringify(settings),
            success: function (e) {
                successCallback(e);
            },
            error: function (e) {
                failureCallback(e);
            }
        });
    };
}

function DisplayEmailSettings(settings) {
    $('#uxSmtpServer').val(settings.Server);
    $('#uxSmtpSender').val(settings.ServiceMailbox);
    $('#uxSmtpUserName').val(settings.UserName);
    $('#uxSmtpPassword').val(settings.Password);
    $('#uxSmtpPort').val(settings.Port);
    $('#uxSmtpPickupDirectory').val(settings.PickupDirectory);
    $('#uxSecureEmailString').val(settings.SecureEmailPhrase);
    $('#uxEmailSizeLimit').val(settings.MaxMessageSize);

    if (!settings.UseDefaultCredentials) {
        $('#authentication-type').data('kendoDropDownList').value('0');
    } else {
        $('#authentication-type').data('kendoDropDownList').value('1');
    }
    $('#uxSendUsing').data('kendoDropDownList').value(settings.DeliveryMethod);

    $('#require-sender').prop('checked', settings.HasSendAsPolicy);
    $('#requires-authentication').prop('checked', settings.RequireAuthentication);
    $('#enable-secure-email').prop('checked', settings.EnableSecureMail);
    $('#enable-ssl').prop('checked', settings.EnableSsl);

    /* DELIVERY METHOD (SEND USING) */
    $(function () {
        SetUsingTooltip();

        if ($('select#uxSendUsing option:selected').val() === '0') { // NETWORK
            $('.send-using-spec-pickup').hide();
            $('.send-using-network, #uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').show();
        } else if ($('select#uxSendUsing option:selected').val() === '1') { // USE PICKUP DIRECTORY
            $('.send-using-spec-pickup').show();
            $('.send-using-network, #uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
        }
    });

    $('#uxSendUsing').change(function () {
        if ($('#uxSendUsing').val() === '0') { // NETWORK
            $('.send-using-spec-pickup').hide();
            $('.send-using-network, #uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').show();
        } else if ($('#uxSendUsing').val() === '1') { // USE PICKUP DIRECTORY
            $('.send-using-spec-pickup').show();
            $('.send-using-network, #uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
        }
    });

    /* REQUIRES AUTENTICATION */
    $(function () {
        if ($('select#uxSendUsing option:selected').val() === '0') {
            if ($('#requires-authentication').prop('checked')) {
                $('#authentication-type-wrapper').show();
                if ($('#authentication-type').val() === '1') {
                    $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
                } else {
                    $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').show();
                }
            } else {
                $('#authentication-type-wrapper, #uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
            }
        }
    });

    $('#requires-authentication').change(function () {
        if ($('#requires-authentication').prop('checked')) {
            $('#authentication-type-wrapper').show();
            if ($('#authentication-type').val() === '1') {
                $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
            } else {
                $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').show();
            }
        } else {
            $('#authentication-type-wrapper').hide();
            if ($('#authentication-type').val() === '1') {
                $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
            } else {
                $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').show();
            }
            $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper, #authentication-type-wrapper').hide();
        }
    });

    $('#authentication-type').change(function () {
        if ($('#authentication-type').val() === '1') {
            $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').hide();
        } else {
            $('#uxUserNameWrapper, #uxPasswordWrapper, #send-as-policy-wrapper').show();
        }
    });

    /* ENABLE SECURE MAIL */
    $(function () {
        if ($('#enable-secure-email').prop('checked')) {
            $('#uxSecureEmailStringWrapper').show();
        }
    });

    $('#enable-secure-email').change(function () {
        if ($('#enable-secure-email').prop('checked')) {
            $('#uxSecureEmailStringWrapper').show();
        } else {
            $('#uxSecureEmailStringWrapper').hide();
        }
    });

    $('#uxSendUsing').change(function () {
        SetUsingTooltip();
    });
}

function SetUsingTooltip() {
    if ($('#uxSendUsing').val() === '1') {
        $('#uxSendUsingInformation').html('<i class="aa-icon fas fa-question-circle aa-color-info" title="Send the message using the local SMTP service pickup directory." aria-hidden="true"></i>');
    } else if ($('#uxSendUsing').val() === '0') {
        $('#uxSendUsingInformation').html('<i class="aa-icon fas fa-question-circle aa-color-info" title="Send the message using the network ( SMTP over the network)." aria-hidden="true"></i>');
    }
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
    var isValidServer = ValidateSmtpServer();
    var isValidPort = ValidateSmtpPort();
    var isValidPickupDirectory = ValidateSmtpPickupDirectory();
    var isValidSecureEmailString = ValidateSecureEmailString();
    var isValidEmailSizeLimit = ValidateEmailSizeLimit();
    var isValidHasSendAsPolicy = validateHasSendAsPolicy();

    var isValid = (isValidServer &&
                   isValidPort &&
                   isValidPickupDirectory &&
                   isValidSecureEmailString &&
                   isValidEmailSizeLimit &&
                   isValidHasSendAsPolicy);

    if (isValid) {
        EnableUpdateButton();
    } else {
        DisableUpdateButton();
    }
}

function DisableUpdateButton() {
    $('#uxUpdateButton').css({
        'opacity': '.25',
        'pointer-events': 'none'
    });
    $('#uxTestSettings').attr('disabled', 'disabled');
}

function EnableUpdateButton() {
    $('#uxUpdateButton').css({
        'opacity': 'inherit',
        'pointer-events': 'inherit'
    });
    $('#uxTestSettings').removeAttr('disabled');
}

function ValidateSmtpServer() {
    var element = $('#uxSmtpServer');

    if (element.val() === '') {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function ValidateSmtpPort() {
    var element = $('#uxSmtpPort');

    if (element.val() === '' || !$.isNumeric(element.val()) || element.val() < 1 || element.val() > 65535) {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function ValidateEmailSizeLimit() {
    var element = $('#uxEmailSizeLimit');

    if (element.val() === '' || !$.isNumeric(element.val()) || element.val() < 0 || element.val() > 99999) {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function validateHasSendAsPolicy() {
    var element = $('#uxSmtpUserName');

    if ($('#require-sender').prop('checked')) {
        if (element.val() === '') {
            SetElementValidationState(element, false);
            return false;
        } else if (!isValidEmail(element.val())) {
            SetElementValidationState(element, false);
            return false;
        } else {
            SetElementValidationState(element, true);
            return true;
        }
    } else {
        SetElementValidationState(element, true);
        return true;
    }
}

function ValidateSmtpPickupDirectory() {
    var element = $('#uxSmtpPickupDirectory');

    if ($('#uxSendUsing').val() === '1' && element.val() === '') {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function ValidateSecureEmailString() {
    var element = $('#uxSecureEmailString');

    if ($('#uxEnableSecureEmail').val() === '1' && element.val() === '') {
        SetElementValidationState(element, false);
        return false;
    }
    else {
        SetElementValidationState(element, true);
    }

    return true;
}

function EnableFormBindings(service, settings) {
    $('#uxSmtpServer').bind('change paste keyup', function () {
        settings.Server = $(this).val();
        OnValidateSettings();
    });

    $('#requires-authentication').bind('click', function () {
        if ($(this).prop('checked')) {
            settings.RequireAuthentication = true;
        } else {
            settings.RequireAuthentication = false;
        }
    });

    $('#enable-secure-email').bind('change paste keyup', function () {
        if ($(this).prop('checked')) {
            settings.EnableSecureMail = true;
        } else {
            settings.EnableSecureMail = false;
        }
        OnValidateSettings();
    });

    $('#uxSmtpSender').bind('change paste keyup', function () {
        settings.ServiceMailbox = $(this).val();
    });

    $('#require-sender').bind('click', function () {
        if ($(this).prop('checked')) {
            settings.HasSendAsPolicy = true;
        } else {
            settings.HasSendAsPolicy = false;
        }
        OnValidateSettings();
    });

    $('#uxSmtpUserName').bind('change paste keyup', function () {
        settings.UserName = $(this).val();
        OnValidateSettings();
    });

    $('#uxSmtpPassword').bind('change paste keyup', function () {
        settings.Password = $(this).val();
    });

    $('#uxSendUsing').bind('change paste keyup', function () {
        settings.DeliveryMethod = $('#uxSendUsing').data('kendoDropDownList').value();
        OnValidateSettings();
    });

    $('#uxSmtpPort').bind('change paste keyup', function () {
        settings.Port = $(this).val();
        OnValidateSettings();
    });

    $('#uxSmtpPickupDirectory').bind('change paste keyup', function () {
        settings.PickupDirectory = $(this).val();
        OnValidateSettings();
    });

    $('#uxSecureEmailString').bind('change paste keyup', function () {
        settings.SecureEmailPhrase = $(this).val();
        OnValidateSettings();
    });

    $('#authentication-type').bind('change paste keyup', function () {
        if ($(this).data('kendoDropDownList').value() === '1') {
            settings.UseDefaultCredentials = true;
        } else {
            settings.UseDefaultCredentials = false;
        }
        OnValidateSettings();
    });

    $('#enable-ssl').bind('click', function () {
        if ($(this).prop('checked')) {
            settings.EnableSsl = true;
        } else {
            settings.EnableSsl = false;
        }
    });

    $('#uxEmailSizeLimit').bind('change paste keyup', function () {
        settings.MaxMessageSize = $(this).val();
        OnValidateSettings();
    });

    $('#uxUpdateButton').click(function () {
        UpdateEmailSettings(service, settings);
    });
}

function UpdateEmailSettings(service, settings) {
    $('#uxWorkingIcon').show();

    service.saveEmailSettings(settings, function () {
        $('#uxSaveAlert').show();
        $('#uxWorkingIcon').hide();
    }, function (data) {
        $('#uxWorkingIcon').hide();
        alert(data.d);
    });
}

function TestEmailService(ToEmail, FromEmail) {
    parent.closeKendoDialog();
    $('#uxTestSettings').attr('disabled', 'disabled');

    $('#uxTestResultText').html('<i class="aa-icon fas fa-cog fa-spin fa-fw" title="Verifying..." aria-hidden="true"></i>&nbsp;Verifying...');

    GlobalService.testEmailSettings(FromEmail, ToEmail, GlobalSettings,
        function () {
            $('#uxTestSettings').removeAttr('disabled');
            $('#uxTestResultText').html('&nbsp;<i class="aa-icon fas fa-check-circle aa-color-success" aria-hidden="true"></i>&nbsp;&nbsp;Verified');
            $('#error-message').hide();
        },
        function (data) {
            console.log(data);
            $('#uxTestSettings').removeAttr('disabled');
            $('#uxTestResultText').html('');
            $('#error-message').show();
            $('#error-message span').html(data.responseText);
        });
}

var GlobalService;
var GlobalSettings;

$(function () {
    settings = new CoreSettings();
    service = new CoreService();

    service.getEmailSettings(function () {
        EnableFormBindings(service, settings);
        DisplayEmailSettings(settings);

        ValidateSmtpServer();
        ValidateSmtpPort();

        GlobalService = service;
        GlobalSettings = settings;
    });
});