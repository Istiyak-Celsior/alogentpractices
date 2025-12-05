var DocumentController = (function (service, $) {
    var publicApi =
    {
        isLoaded: false
    };

    publicApi.load = function () {
        initializeKendoSortableGroups();
        initializeKendoSortableTabs();

        publicApi.saveFailDialog = $('#save-order-fail-dialog').kendoDialog({
            width: '640px',
            modal: true,
            visible: false,
            closable: true
        }).data('kendoDialog');

        $('#save-sort-button').on('click', function () {
            saveOrder();
        });

        publicApi.isLoaded = true;
    };

    function initializeKendoSortableGroups() {
        $('#sortable-handlers-groups').kendoSortable({
            handler: '.handler',
            cursor: 'move',
            change: enableSaveButton,
            hint: function (element) {
                return element.clone().addClass('group-hint');
            },
            placeholder: function (element) {
                return element.clone().addClass('placeholder').html('&nbsp;&nbsp;&nbsp;&nbsp;Drop here');
            }
        });
    }

    function initializeKendoSortableTabs() {
        $('#sortable-handlers-tabs').kendoSortable({
            handler: '.handler-tab',
            cursor: 'move',
            change: enableSaveButton,
            hint: function (element) {
                return element.clone().addClass('tab-hint');
            },
            placeholder: function (element) {
                return element.clone().addClass('placeholder').html('&nbsp;&nbsp;&nbsp;&nbsp;Drop here');
            }
        });
    }

    function showErrorDialog() {
        publicApi.saveFailDialog.title('Problem Detected Whilst Saving..');
        publicApi.saveFailDialog.open();
    }

    function enableSaveButton() {
        $('#save-sort-button').css({
            'opacity': '1.0',
            'pointer-events': 'inherit'
        });
    }

    function disableSaveButton() {
        $('#save-sort-button').css({
            'opacity': '0.20',
            'pointer-events': 'none'
        });
    }

    function saveOrder() {
        var groups = [];
        var tabs = [];
        var sortOrderGroups = 0;
        var sortOrderTabs = 0;

        $('.group').each(function () {
            sortOrderGroups++;
            groups.push({ 'DocumentTypeId': $(this).prop('id'), 'SortOrder': sortOrderGroups });
        });
        service.updateGroupOrder(groups, function() {
            disableSaveButton();
        }, function (response) {
            if (response.statusCode !== 200) {
                showErrorDialog();
            }
        });

        $('.tab').each(function () {
            sortOrderTabs++;
            tabs.push({'DocumentSubTypeId': $(this).prop('id'), 'SortOrder': sortOrderTabs });
        });
        service.updateTabOrder(tabs, function () {
            disableSaveButton();
        }, function (response) {
            if (response.statusCode !== 200) {
                showErrorDialog();
            }
        });
    }

    return publicApi;
});

var DocumentDefinitionController = (function (service, $) {
    var publicApi =
    {
        isLoaded: false
    };

    publicApi.load = function () {
        initializeKendoSortableDefinitions();

        publicApi.saveFailDialog = $('#save-order-fail-dialog').kendoDialog({
            width: '640px',
            modal: true,
            visible: false,
            closable: true
        }).data('kendoDialog');

        $('#save-sort-button').on('click', function () {
            saveOrder();
        });

        publicApi.isLoaded = true;
    };

    function initializeKendoSortableDefinitions() {
        $('#definitions').kendoSortable({
            handler: '.handler',
            cursor: 'move',
            change: enableSaveButton,
            hint: function (element) {
                return $('<span></span>').text(element.find('.desc').text()).addClass('hint');
            },
            placeholder: function (element) {
                return element.clone().addClass('placeholder').html('&nbsp;&nbsp;&nbsp;&nbsp;Drop here');
            }
        });
    }

    function showErrorDialog() {
        publicApi.saveFailDialog.title('Problem Detected Whilst Saving..');
        publicApi.saveFailDialog.open();
    }

    function enableSaveButton() {
        $('#save-sort-button').css({
            'opacity': '1.0',
            'pointer-events': 'inherit'
        });
    }

    function disableSaveButton() {
        $('#save-sort-button').css({
            'opacity': '0.20',
            'pointer-events': 'none'
        });
    }

    function saveOrder() {
        var defs = [];
        var sortOrderDefs = 0;

        $('.definition').each(function () {
            sortOrderDefs++;
            defs.push({ 'DocumentDefinitionId': $(this).prop('id'), 'SortOrder': sortOrderDefs });
        });
        service.updateDefinitionOrder(defs, function () {
            disableSaveButton();
        }, function (response) {
            if (response.statusCode !== 200) {
                showErrorDialog();
            }
        });
    }

    return publicApi;
});