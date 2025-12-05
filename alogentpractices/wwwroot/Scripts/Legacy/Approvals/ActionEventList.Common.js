var service = new ActionEventService(new ApiService(jQuery));
var controller = new ActionEventController(service, jQuery, undefined);
controller.load();

$(document).ready(function () {
    /* SHOW LOADING ANIMATION */
    kendo.ui.progress($(document.body), true);

    /* INITIALIZE TAB STRIP */
    setTimeout(function () {
        initializeTabStrip();
    }, 1000);

    /* WHEN USER CLICKS MORE OR LESS HYPERLINK IN ROW */
    $('a[id^="more-less-"]').click(function () {
        showHideDescription(this, '');
    });

    /* WHEN THE USER CLICK EXPAND/COLLAPSE ALL DESCRIPTIONS BUTTON */
    $('#descriptions-toggle').click(function () {
        if ($(this).html() === 'Show All Descriptions') {
            $(this).html('Hide All Descriptions');
            $('a[id^="more-less-"]').each(function (i, obj) {
                showHideDescription(this, 'show');
            });
        } else {
            $(this).html('Show All Descriptions');
            $('a[id^="more-less-"]').each(function (i, obj) {
                showHideDescription(this, 'hide');
            });
        }
    });
});

function enableCloneableWorkflowTypeSelect() {
    $('#aa-type-list-loading').hide();
}

function displayAlertMessage(msg, status) {
    setTimeout(function () {
        $('#error-panel').html('<div class="aa-alert aa-color-' + status + ' aa-background-' + status + '">' + msg + '</div>').slideDown('slow');
    }, 1000);

    setTimeout(function () {
        $('#error-panel').slideUp('slow');
    }, 5000);
}

function initializeTabStrip() {
    $('#tabstrip').kendoTabStrip({
        animation: {
            open: {
                effects: 'fadeIn'
            }
        }
    });

    kendo.ui.progress($(document.body), false);
    $('#tabstrip, div.top, footer').show();

    getColumnWidth();
}

$(window).resize(function () {
    getColumnWidth();
});

function getColumnWidth() {
    /* LOGIC SHOULD WORK FOR MOST MODERN BROWSERS */
    var tableWidth = $('#action-grid').width();

    /* ADDITION LOGIC NECESSARY FOR IE */
    if (tableWidth !== 0) {
        tableWidth = $('#action-grid').css('width');
        tableWidth = Number(tableWidth.replace('px', '')).toFixed(0);
    }

    if (tableWidth !== 0) {
        var columnWidth = tableWidth * 0.17;
        columnWidth = columnWidth.toFixed(0) - 8;
        $('.action span.event').css('width', columnWidth + 'px');
    }
}

function showHideDescription(element, action) {
    var id = $(element).attr('id').replace('more-less-', '');
    if (action === '') {
        if ($(element).html() === 'more...') {
            $(element).closest('div.action').css('height', 'auto');
            $(element).html('less...');
            $('tr#desc-' + id).show();
        } else {
            $(element).closest('div.action').css('height', '39px');
            $(element).html('more...');
            $('tr#desc-' + id).hide();
        }
    } else {
        if (action === 'show') {
            $(element).closest('div.action').css('height', 'auto');
            $(element).html('less...');
            $('tr#desc-' + id).show();
        } else {
            $(element).closest('div.action').css('height', '39px');
            $(element).html('more...');
            $('tr#desc-' + id).hide();
        }
    }
}

function setButton(btnObj, imgPath) {
    btnObj.src = imgPath;
    return true;
}
