function openWindow(page) {
    this.open(page, 'viewWindow', 'toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes');
}
function openWindow(page) {
    this.open(page, 'viewWindow', 'toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes');
}

function DeselectAllCheckboxes() {
    var checkBoxes = $('.uxUploadCheckbox');

    $.each(checkBoxes, function () {
        var isChecked = $(this).prop('checked');
        if (isChecked) {
            $(this).prop('checked', false);
        }
    });

    CheckForSelectedFile();
}

function ReplaceFileUploadControl() {
    var control = $('#upFile');
    control.replaceWith(control.clone(true));
}

function CheckForSelectedFile() {
    var numberChecked = 0;
    var checkBoxes = $('.uxUploadCheckbox');

    $.each(checkBoxes, function () {
        var isChecked = $(this).prop('checked');
        if (isChecked) {
            numberChecked = numberChecked + 1;
        }
    });

    if (numberChecked > 0) {
        if ($('#uploadAction').val() === 'MERGE') {
            EnableButton('uxBtnMergeFromServerWrapper');
            $('#uxMergeRadioButtonsWrapper').show();
        } else if ($('#uploadAction').val() === 'REPLACE') {
            EnableButton('uxBtnReplaceFromServerWrapper');
        } else {
            EnableButton('uxSelectDeleteButtonWrapper');
            EnableButton('uxBtnUploadFromServerWrapper');
        }
    } else {
        if ($('#uploadAction').val() === 'MERGE') {
            DisableButton('uxBtnMergeFromServerWrapper');
            $('#uxMergeRadioButtonsWrapper').hide();
        } else if ($('#uploadAction').val() === 'REPLACE') {
            DisableButton('uxBtnReplaceFromServerWrapper');
        } else {
            DisableButton('uxSelectDeleteButtonWrapper');
            DisableButton('uxBtnUploadFromServerWrapper');
        }
    }
}

function DisableButton(elementId) {
    $('#' + elementId).css({
        'opacity': '.25',
        'pointer-events': 'none',
        'cursor': 'default'
    });
    $('#' + elementId).bind('click', false);
}

function EnableButton(elementId) {
    $('#' + elementId).css({
        'opacity': 'inherit',
        'pointer-events': 'inherit',
        'cursor': 'pointer'
    });
    $('#' + elementId).unbind('click', false);
}

$(function () {
    if ($('#uploadAction').val() === 'MERGE') {
        DisableButton('uxBtnMergeFromClientWrapper');
        DisableButton('uxBtnMergeFromServerWrapper');
    } else if ($('#uploadAction').val() === 'REPLACE') {
        DisableButton('uxBtnReplaceFromClientWrapper');
        DisableButton('uxBtnReplaceFromServerWrapper');
    } else {
        DisableButton('uxSelectDeleteButtonWrapper');
        DisableButton('uxBtnUploadFromServerWrapper');
        DisableButton('uxBtnUploadFromClientWrapper');
    }

    $('input:file').change(function () {
        var error = 0;
        var buttonWrapper = 'uxBtnUploadFromClientWrapper';
        var fileName = $(this).val();
        if ($('#uploadAction').val() === 'MERGE') {
            buttonWrapper = 'uxBtnMergeFromClientWrapper';
            var ext = $(this).val().split('.').pop().toLowerCase();
            if ($.inArray(ext, ['pdf', 'tiff', 'tif']) === -1) {
                alert('Only file extensions of .TIF/.TIFF or .PDF can be selected for merging. \nPlease select another file.');
                ReplaceFileUploadControl();
                error++;
            }
        }
        if ($('#uploadAction').val() === 'REPLACE') {
            buttonWrapper = 'uxBtnReplaceFromClientWrapper';
        }
        if (error === 0) {
            if (fileName !== '') {
                EnableButton(buttonWrapper);
                $('#uxClientMergeRadioButtonsWrapper').show();
            }
        }
    });

    if ($('#errLabel').html() !== '') {
        var errorHeight = $('#errLabel').height() + 10;
        var newHeight = $('#uxFileListWrapper').height() - errorHeight;
        $('#errLabel').css('padding-bottom', '10px');
        $('#uxFileListWrapper').css('max-height', newHeight + 'px').css('min-height', newHeight + 'px').css('height', newHeight + 'px');
        $('.method-wrapper').css('min-height', $('.method-wrapper').height() - errorHeight);
    }

    $(document).on('click', '.uxUploadCheckbox', function () {
        CheckForSelectedFile();
    });

    /* CLIENT UPLOAD BUTTONS */
    $(document).on('click', '#btnUploadFromClient', function () {
        DisableButton('btnUploadFromClient');
        $('.client-save-wrapper').show();
    });

    $(document).on('click', '#btnMergeFromClient', function () {
        DisableButton('btnMergeFromClient');
        $('#uxClientMergeRadioButtonsWrapper').hide();
        $('.client-save-wrapper').show();
    });

    $(document).on('click', '#btnReplaceFromClient', function () {
        DisableButton('btnReplaceFromClient');
        $('.client-save-wrapper').show();
    });

    /* SERVER UPLOAD BUTTONS */
    $(document).on('click', '#uxBtnUploadFromServerWrapper', function () {
        DisableButton('uxBtnUploadFromServerWrapper');
        $('.server-save-wrapper').show();
    });

    $(document).on('click', '#uxBtnMergeFromServerWrapper', function () {
        DisableButton('uxBtnMergeFromServerWrapper');
        $('#uxMergeRadioButtonsWrapper').hide();
        $('.server-save-wrapper').show();
    });

    $(document).on('click', '#uxBtnReplaceFromServerWrapper', function () {
        DisableButton('uxBtnReplaceFromServerWrapper');
        $('.server-save-wrapper').show();
    });
});





function cancelUpload(newUrl) {
    document.location.href = newUrl;
    return false;
}
