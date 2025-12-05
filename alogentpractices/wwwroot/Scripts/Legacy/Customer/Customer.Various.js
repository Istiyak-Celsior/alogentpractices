// The following instantiates the AdditionalBorrower service and controller for use by the Change of Primary Borrower.
var additionalBorrowerService = new AdditionalBorrowerService();
var additionalBorrowerController = new AdditionalBorrowerController(additionalBorrowerService, jQuery, undefined);

additionalBorrowerController.load();

// Plumbing for the change of primary borrower error display window
$('#changeOfBorrowerErrorMessageClose').css('cursor', 'pointer');
$('#changeOfBorrowerErrorMessageClose').on("click", function (e) {
    closeChangeBorrowerErrorMessage();
});

function closeChangeBorrowerErrorMessage() {
    $('#changeOfBorrowerErrorDisplay').hide();
}

function CollapsibleDocumentsToggle(theClassNumber) {
    var element = $('tr.tabGroup' + theClassNumber + 'Child');
    var elementFirst = $('tr.tabGroup' + theClassNumber + 'Child:first');
    var isHidden = false;
    if (elementFirst.is(':hidden')) { isHidden = true; }

    if (isHidden === true) {
        element.show();
        $('#tabGroup' + theClassNumber + 'Expander').html('<i class="aa-icon fa fas fa-caret-right rotate fa-fw" aria-hidden="true"></i>');
        $('#tab-folder-' + theClassNumber).removeClass('fa-folder').addClass('fa-folder-open');
    } else {
        element.hide();
        $('#tabGroup' + theClassNumber + 'Expander').html('<i class="aa-icon fa fas fa-caret-right fa-fw" aria-hidden="true"></i>');
        $('#tab-folder-' + theClassNumber).removeClass('fa-folder-open').addClass('fa-folder');
    }

    // LOGIC TO OPEN THE FOLDER ICON IF ONLY ONE DOCUMENT IS AVAILABLE
    if ($('.tabGroup' + theClassNumber + 'Child').length == 0) {
        $('#tab-folder-' + theClassNumber).removeClass('fa-folder').addClass('fa-folder-open');
    }
}

function CollapsibleGroupsToggle(theGroupNumber) {
    let enableCollapsibleDocuments = $('#enable-collapsible-documents').html();
    var groupHeader = $('#tabHeader' + theGroupNumber + 'Expander').html();
    var isExpanded = groupHeader.indexOf('minus-square') > -1;

    var groupContent = $('#uxTabHeader' + theGroupNumber + 'Children').val();

    if ($.type(groupContent) === "undefined") {
        groupContent = $('#lastChildContent').html();
    }

    var groupContentAry = groupContent.split("|");

    for (var i = 0; i < groupContentAry.length; i++) {
        if (isExpanded) { // COLLAPSE GROUP
            $('#tabGroup' + groupContentAry[i] + 'Parent').hide();
            $('.tabGroup' + groupContentAry[i] + 'Child').hide();
            $('#tabHeader' + theGroupNumber + 'Expander').html('<i class="aa-icon fas fa-plus-square fa-fw" aria-hidden="true"></i>');
        }
        else { // EXPAND GROUP
            $('#tabGroup' + groupContentAry[i] + 'Parent').show();
            $('.tabGroup' + groupContentAry[i] + 'Child').show();
            $('#tabHeader' + theGroupNumber + 'Expander').html('<i class="aa-icon fas fa-minus-square fa-fw" aria-hidden="true"></i>');
            $('#tabGroup' + groupContentAry[i] + 'Expander').html('<i class="aa-icon fas fa-caret-right rotate fa-fw" aria-hidden="true"></i>');

            if (enableCollapsibleDocuments + '' === '1') {
                CollapsibleDocumentsToggle(groupContentAry[i]);
            }
        }
    }
}

$(function () {
    var finalTabCount = $('#tabCountFinal').html();

    for (i = 1; i < finalTabCount + 1; i++) {
        if ($('.tabGroup' + i + 'Child').length > 0) {
            $('#tabGroup' + i + 'Expander').show();
        } else {
            $('#tab-folder-' + i).removeClass('fa-folder').addClass('fa-folder-open');
        }
    }

    $(document).on('dragover', function (ev) {
        if ($(ev.target).attr('className') !== 'doc-drop') {
            ev.preventDefault();
        }
    });

    $(document).on('dragleave', function (ev) {
        if ($(ev.target).attr('className') !== 'doc-drop') {
            ev.preventDefault();
        }
    });

    $(document).on('drop', function (ev) {
        if ($(ev.target).attr('className') !== 'doc-drop') {
            ev.preventDefault();
        }
    });
});

function expandDiv(gridBlock, elementId) {
    if ($('#' + elementId).hasClass('fa-minus-square')) {
        $('#' + elementId).removeClass('fa-minus-square').addClass('fa-plus-square');
        $('#timerLinkId').html('Close Timers');
        $('#' + gridBlock).hide();
    } else {
        $('#' + elementId).addClass('fa-minus-square').removeClass('fa-plus-square');
        $('#timerLinkId').html('View All Timers');
        $('#' + gridBlock).show();
    }
}

function ExpandFields(objImgButton, idName, level) {
    let displayFieldState = 'none';
    let displayGroupState = 'none';
    let expansionState = 'collapsed';
    let objRow = document.getElementById(idName);

    if ($(objImgButton).find('i').hasClass('fa-plus-square')) {
        displayGroupState = '';
        displayFieldState = '';
        expansionState = 'expanded';
        $('#' + idName).hide();
    } else {
        $('#' + idName).show();
    }

    // Set display preference as a cookie
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + 365);
    var c_value = escape(expansionState) + "; expires=" + exdate.toUTCString();
    document.cookie = idName + "_DisplayState=" + c_value;

    // toggle rows to display/hide
    var groupDone, groupIdx, fieldDone, fieldIdx, fieldName;

    if (level == 0) {
        // toggle root field display
        groupIdx = 0;
        groupDone = false;
        while (!groupDone) {
            fieldDone = false;
            fieldIdx = 0;
            while (!fieldDone) {
                fieldName = idName + "_" + groupIdx + "_" + fieldIdx;
                objRow = document.getElementById(fieldName);
                if (objRow == null) {
                    fieldDone = true;
                }
                else {
                    objRow.style.display = "none";
                }
                fieldIdx++;
            }

            fieldName = idName + "_" + groupIdx;
            objRow = document.getElementById(fieldName);
            if (objRow == null) {
                groupDone = true;
            } else {
                objRow.style.display = displayGroupState;
            }
            groupIdx++;
        }
    }
    else {
        // toggle specific group fields
        fieldDone = false;
        fieldIdx = 0;
        while (!fieldDone) {
            fieldName = idName + "_" + fieldIdx;
            objRow = document.getElementById(fieldName);
            if (objRow == null) {
                fieldDone = true;
            } else {
                objRow.style.display = displayFieldState;
            }
            fieldIdx++;
        }
    }
}

function GetEmailSenderURL() {
    var customerGuid = $('#hidCustomerId').val();

    var loanGuid = '';
    if ($('#hidLoanId').length) {
        loanGuid = $('#hidLoanId').val();
    }

    var collGuid = '';
    if ($('#hidCollateralId').length) {
        collGuid = $('#hidCollateralId').val();
    }

    var depositGuid = '';
    if ($('#hidDepositId').length) {
        depositGuid = $('#hidDepositId').val();
    }

    var trustGuid = '';
    if ($('#hidTrustId').length) {
        trustGuid = $('#hidTrustId').val();
    }

    var url = 'email_sender_create.asp?customerId=' + customerGuid + '&loanId=' + loanGuid + '&collId=' + collGuid + '&depositId=' + depositGuid + '&trustId=' + trustGuid;
    var path = window.location.protocol + "//" + window.location.host + window.location.pathname;
    var pathArray = path.split('/');
    var newPathname = '';

    for (i = 0; i < pathArray.length - 1; i++) {
        newPathname += pathArray[i];
        newPathname += "/";
    }

    return newPathname + url;
}

function formatURL(strUrl, strParam, strValue) {
    var URL = '';
    URL = strUrl + '?' + strParam + '=' + strValue;
    var path = window.location.protocol + "//" + window.location.host + window.location.pathname;
    var pathArray = path.split('/');
    var newPathname = '';
    for (i = 0; i < pathArray.length - 1; i++) {
        newPathname += pathArray[i];
        newPathname += "/";
    }
    var fullURL = newPathname + URL;
    return fullURL;
}

$(window).resize(function () {
    resizeGrid();
});

$(document).ready(function () {
    kendo.ui.progress($(document.body), true);

    setTimeout(function () {
        initializeKendoComponents();
        resizeGrid();
    }, 300);

    $('#files').kendoUpload({
        async: {
            saveUrl: $('#dragdrop-handler').val(),
            removeUrl: 'api/documentupload/removedocument',
            autoUpload: true
        },
        select: function (e) {
            multiFileCheck(e);
            fileSizeCheck(e);
        },
        upload: function (e) {
            kendo.ui.progress($(document.body), true);

            $('#dragdrop-error').val('0');

            e.data = {
                UserLogin: $('#dragdrop-user-login').val(),
                CustomerId: $('#dragdrop-customer-id').val(),
                DocumentDefId: $('#dragdrop-document-def-id').val(),
                DocumentId: $('#dragdrop-document-id').val(),
                DocumentTabId: $('#dragdrop-document-tab-id').val(),
                LoanId: $('#dragdrop-loan-id').val(),
                UploadDir: $('#dragdrop-upload-dir').val()
            };
        },
        complete: function (e) {
            if ($('#dragdrop-error').val() === '0') {
                document.location.href = 'rtevprocess.asp?greybox=0';
            }
        },
        error: function (e) {
            kendo.ui.progress($(document.body), false);

            var errorArray;
            var response = e.XMLHttpRequest.response;

            if (response.indexOf('CLASSIC') > -1) {
                errorArray = response.split('||');
                $('#dragdrop-error').val('1');
                displayErrorDialog(errorArray[2], errorArray[3]);
            } else if (response.indexOf('ASPX||') > -1) {
                errorArray = response.split('||');
                $('#dragdrop-error').val('1');
                displayErrorDialog(errorArray[1], errorArray[2]);
            } else if (response.indexOf('SIGN IN') > -1) {
                displayTimeoutDialog('Session Timeout', 'Sorry your session has timed out');
                $('#dragdrop-error').val('1');
            } else if (response === '') {
                var files = e.files;
                for (var i = 0; i < files.length; i++) {
                    let fileName = files[i].name.replace("'", "\'");
                    let errorText = 'A problem occurred trying to upload one or more files. This could be caused by the files being open in another program, or some other unknown error. If any of the files are open in another program, you can close them and try again.<br/><br/>Filename: \'' + fileName + '\'';
                    displayErrorDialog('General Error', errorText);
                }
                $('#dragdrop-error').val('1');
            }
        },
        showFileList: false,
        dropZone: '.doc-drop'
    });

    /* CLOSE KENDO TOOLTIP ON MOUSEOVER */
    $('body').on('mouseover', '.k-tooltip-content', function () {
        $('.k-animation-container, .k-tooltip').hide();
    });
});

function fileSizeCheck(e) {
    let maxFileSize = 2147483647;
    let goodFileCount = 0;
    let fileName = '';

    let megaBytes = 1 / Math.pow(2, 20) * maxFileSize;
    megaBytes = megaBytes.toFixed(0);

    $.each(e.files, function (index, value) {
        fileName = value.name;
        if (Number(value.size) < maxFileSize) {
            goodFileCount++;
        }
    });

    if (goodFileCount === 0) {
        let errorText = 'An error has occurred while uploading the file to the highlighted document tab:<br/><br/>Filename: \'' + fileName.replace("'", "\'") + '\'<br/>Details: The file selected exceeds ' + megaBytes + 'Mb, please select a smaller file size.';
        displayErrorDialog('File Size Exception', errorText);
        e.preventDefault();
        return;
    }
}

function multiFileCheck(e) {
    if (e.files.length > 1) {
        let errorText = 'An error has occurred while uploading the file to the highlighted document tab:<br/><br/>Filename: Multiple files<br/>Details: The system cannot process multiple files at a time.';
        displayErrorDialog('Multiple File Upload', errorText);
        e.preventDefault();
        return;
    }
}

function dragDropNoPermission(ev) {
    ev.preventDefault();
    let errorText = 'An error has occurred while uploading the file to the highlighted document tab:<br/><br/>Details: You don\'t have the necessary permissions to complete this action.';
    displayErrorDialog('Permission Error', errorText);
    clearDropZone(ev);
}

function displayErrorDialog(errSource, errDescription) {
    let errorHtml = '<div class="aa-error-dialog">' +
                    '    <div>' +
                    '        <i class="fas fa-exclamation-triangle" aria-hidden="true"></i>' +
                    '    </div>' +
                    '    <div>' +
                    '        <h4>' + errSource + '</h4>' +
                    '        <p>' + errDescription + '</p>' +
                    '    </div>';
                    '</div>';
    kendo.alert(errorHtml);
}

function displayTimeoutDialog(errSource, errDescription) {
    let errorHtml = '<div class="aa-error-dialog">' +
                    '    <div>' +
                    '        <i class="fas fa-exclamation-triangle" aria-hidden="true"></i>' +
                    '    </div>' +
                    '    <div>' +
                    '        <h4>' + errSource + '</h4>' +
                    '        <p>' + errDescription + '</p>' +
                    '    </div>';
                    '</div>';

    $('#dd-dialog').kendoDialog({
        width: '450px',
        title: 'Error',
        closable: false,
        modal: true,
        content: errorHtml,
        actions: [
            { text: 'OK' }
        ],
        close: function () {
            document.location.reload();
        }
    });
}

function allowDrop(ev) {
    $(ev.target).closest('tr.aa-row').children('td').css('background-color', '#CBFFBB');
    ev.dataTransfer.effectAllowed = 'copy';
    ev.dataTransfer.dropEffect = 'copy';
}

function disallowDrop(ev) {
    $(ev.target).closest('tr.aa-row').children('td').css('background-color', '#FFBBBB');
    ev.preventDefault();
    ev.dataTransfer.effectAllowed = 'copy';
    ev.dataTransfer.dropEffect = 'copy';
}

function clearDropZone(ev) {
    $(ev.target).closest('tr.aa-row').children('td').css('background-color', '');
}

function dragDropCopyData(loanId, documentDefId, documentId, documentTabId, ev) {
    $('#dragdrop-loan-id').val(loanId);
    $('#dragdrop-document-def-id').val(documentDefId);
    $('#dragdrop-document-id').val(documentId);
    $('#dragdrop-document-tab-id').val(documentTabId);
    $(ev.target).closest('tr.aa-row').children('td').css('background-color', '');
}
// DRAG AND DROP UPLOAD <- END

function resizeGrid() {
    let wrapperWidth = $('.aa-tab-content-wrapper').width();
    if (wrapperWidth < 895) {
        $('.k-grid.k-widget.k-display-block').css('max-width', wrapperWidth - 5);
    } else {
        $('.k-grid.k-widget.k-display-block').css('max-width', '100%');
    }
}

function initializeKendoComponents() {
    $('#view-preferences-link').show();

    $('#panelbar').kendoPanelBar({
        expandMode: 'single'
    });

    $('#customer-dropdown').kendoMenu();
    $('#credit-dropdown').kendoMenu();
    $('#account-dropdown').kendoMenu();
    $('#collateral-dropdown').kendoMenu();

    showPageContent();
}

function showPageContent() {
    let i;
    let idArray = ['aa-quick-search-title', 'aa-customer-debug-title'];
    let idArray2 = ['aa-search-panel', 'aa-customer-debug-panel'];

    $('#customer-dropdown-wrapper').show();
    $('#aa-main-content').show();

    for (i = 0; i < idArray.length; i += 1) {
        $('#' + idArray[i]).css('display', 'table');
    }

    for (i = 0; i < idArray2.length; i += 1) {
        $('#' + idArray2[i]).css('display', 'inline-table');
    }

    $('footer').show();

    $('body').kendoTooltip({ filter: "i.fa[title], i.fad[title], span.expiring-date[title]", position: 'top' });

    $('body').kendoTooltip({ filter: "i.fas.fa-comments[title]", position: 'top' });

    /* DOCUMENT TAB INSTRUCTIONS */
    $("body").kendoTooltip({
        filter: "i.fas.fa-folder-open[title], i.fas.fa-folder[title]",
        position: "right",
        content: kendo.template($("#document-tab-tooltip-template").html())
    });

    kendo.ui.progress($(document.body), false);
}

$(function () {
    $('div[id^=form_]').hide();
    $('a[class^=img_]').click(function () {
        var id = $(this).attr('class').replace('img_', '');
        $('#text_' + id).hide();
        $('#form_' + id).show();
    });
    $('a[class^=btnClear_]').click(function () {
        var id = $(this).attr('class').replace('btnClear_', '');
        var myText = $(this).prevAll('input');
        $(myText).val($('#text_' + id).text());
        $('#text_' + id).show();
        $('#form_' + id).hide();
    });
    $('a[class^=btnSubmit_]').click(function () {
        var id = $(this).attr('class').replace('btnSubmit_', '');
        var myText = $(this).prevAll('input');
        $.post('updateComments.asp', { commentID: id, newText: $(myText).val(), table: 'customerComments', key: 'commentID' }, function (data) {
            if (!data.length == 0) {
                $('#text_' + id).show();
                $('#text_' + id).empty().append(data);
                $(myText).val(data);
                $('#form_' + id).hide();
            }
            else {
                alert('Sorry, comment was not updated at this time, please try again');
            }
        });
    });
    $('a[class^=btnSubmit2_]').click(function () {
        var id = $(this).attr('class').replace('btnSubmit2_', '');
        var myText = $(this).prevAll('input');
        $.post('updateComments.asp', { commentID: id, newText: $(myText).val(), table: 'loanComments', key: 'loanCommentID' }, function (data) {
            if (!data.length == 0) {
                $('#text_' + id).show();
                $('#text_' + id).empty().append(data);
                $(myText).val(data);
                $('#form_' + id).hide();
            }
            else {
                alert('Sorry, comment was not updated at this time, please try again');
            }
        });
    });
});

function Start(page) {
    var rndValue = Math.round(Math.random() * 10000);
    window.open(page, "CtrlWindow_" + rndValue, "toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes");
}

function openPopup(page, w, h) {
    window.open(page, "popupWindow", "width=" + w + ",height=" + h + ",toolbar=no,menubar=no,location=no,scrollbars=yes,resizable=yes,status=yes");
}

/* Launches the Scan Module */
function launchApp(scanPath, arg, scanurl) {
    var obj = new ActiveXObject("LaunchinIE.Launch");
    cmdLine = '"' + scanPath + '" ' + arg;
    obj.LaunchApplication(scanPath + ' ' + arg);
    location = scanurl;
}

function initPage(frm, bookLoan, selectedCustomerId, selectedLoanId, applicationIdToBook) {
    if ($('#loanSelectGrid').length) {
        let accountClassCode = $('#selected-account-class').html();

        // Initialize loan grid if it exists in document
        $(document).ready(function () {
            $('#loanSelectGrid').kendoGrid({
                sortable: true,
                reorderable: true,
                resizable: true,
                scrollable: true
            }).data('kendoGrid');
        });
    }
    BuildSearchForm(frm);

    // open convert application to booked loan wizard
    if (bookLoan === "true") {
        var wizardUrl = "convertapplicationselect.asp?customerId=" + selectedCustomerId + "&loanId=" + selectedLoanId + "&applicationId=" + applicationIdToBook;
        openKendoDialog("Convert Application to Booked Loan", wizardUrl, 500, 700);
    }
}

function downloadFile(fileURL, fileName) {
    if (!window.ActiveXObject) {
        var save = document.createElement('a');
        save.href = fileURL;
        save.target = '_blank';

        var filename = fileURL.substring(fileURL.lastIndexOf('/') + 1);
        save.download = fileName || filename;

        if (navigator.userAgent.toLowerCase().match(/(ipad|iphone|safari)/) && navigator.userAgent.search("Chrome") < 0) {

            document.location = save.href;

        } else {
            evt = document.createEvent("MouseEvent");
            evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);

            save.dispatchEvent(evt);
            (window.URL || window.webkitURL).revokeObjectURL(save.href);
        }
    }
    else if (!!window.ActiveXObject && document.execCommand) {
        var _window = window.open(fileURL, '_blank');
        _window.document.close();
        _window.document.execCommand('SaveAs', true, fileName || fileURL);
        _window.close();
    }
}