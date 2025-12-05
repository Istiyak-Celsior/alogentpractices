var ConversionFailuresTabController = (function(service) {
    var publicApi = {
        isLoaded : false
    };

    var isLoading = false;

    publicApi.load = function () {
        initializeGrid();

        getGridData();

        $('#unblock-button').on('click', function () {
            onUnblockButtonClick();
        });

        $('#unblockall-button').on('click', function () {
            onUnblockAllButtonClick();
        });

        publicApi.isLoaded = true;
    };

    function getGridData() {
        if (isLoading)
            return;

        isLoading = true;

        service.getBlockedDocuments(function (results) {
            isLoading = false;

            initializeGrid(results);
        });
    }

    function getGridJson(data) {
        var tree = {
            rows: []
        };

        var rowId = 0;

        $.each(data, function (index, value) {
            var row = {
                id: ++rowId,
                DocumentId: value.DocumentId,
                CustomerNumber: value.CustomerNumber,
                AccountNumber: value.AccountNumber,
                GroupName: value.GroupName,
                TabName: value.TabName,
                FileName: value.FileName
            };

            tree.rows.push(row);
        });

        return tree;
    }

    function initializeGrid(data) {
        $('#blockedDocumentsGrid').html('');

        let gridData = getGridJson(data);

        $('#blockedDocumentsGrid').kendoGrid({
            dataSource: {
                data: gridData.rows,
                batch: true,
                schema: {
                    model: {
                        id: 'id',
                        fields: {
                            DocumentId: { type: 'string' },
                            CustomerNumber: { type: 'string' },
                            AccountNumber: { type: 'string' },
                            GroupName: { type: 'string' },
                            TabName: { type: 'string' },
                            FileName: { type: 'string' }
                        }
                    }
                }
            },
            height: 600,
            filterable: true,
            sortable: true,
            pageable: {
                pageSize: 25
            },
            columns: [
                { title: '', headerTemplate: '<input type="checkbox" class="k-checkbox" id="check-all" onclick="checkAll(this);"/><label class="k-checkbox-label" for="check-all">&nbsp;</label>', width: '50px', template: '<input id="docid-#:DocumentId#" class="k-checkbox" type="checkbox"/><label class="k-checkbox-label" for="docid-#:DocumentId#">&nbsp;</label>' },
                { title: 'Customer', field: 'CustomerNumber', filterable: { multi: true, search: true } },
                { title: 'Account', field: 'AccountNumber', filterable: { multi: true, search: true } },
                { title: 'Group', field: 'GroupName', filterable: { multi: true, search: true } },
                { title: 'Tab', field: 'TabName', filterable: { multi: true, search: true } },
                { title: 'File Name', field: 'FileName', filterable: { search: true } }
            ]
        }).data('kendoGrid');
    }

    function unblockAllDocuments() {
        $('#unblock-button').hide();
        $('#unblockall-button').hide();
        $('#unblock-progress').show();

        service.unblockAllDocuments(function () {
            var grid = $('#blockedDocumentsGrid').data('kendoGrid');
            grid.dataSource.data([]);

            $('#unblock-progress').hide();
            $('#unblock-button').show();
            $('#unblockall-button').show();
        });
    }

    function getCheckedRows() {
        let elements = [];

        $('input[id^="docid-"]:checked').each(function (i, obj) {
            let thisId = $(this).attr('id').replace('docid-', '');
            elements.push(thisId);
        });
        return elements;
    }

    function unblockCheckedDocuments() {
        var checkedRows = getCheckedRows();

        if (checkedRows == '')
            return;

        $('#unblock-button').hide();
        $('#unblockall-button').hide();
        $('#unblock-progress').show();

        service.unblockDocuments(checkedRows, function () {
            checkedRows.reverse();

            removeUnblockedDocuments(checkedRows);

            $('#unblock-progress').hide();
            $('#unblock-button').show();
            $('#unblockall-button').show();
        });
    }

    function removeUnblockedDocuments(documents) {
        for (var i = 0; i < documents.length; i++) {
            let dataItem = $('#docid-' + documents[i]).closest('tr');
            dataItem.remove();
        }

        $('input[id="check-all"]').prop('checked', false);
    }

    function onUnblockButtonClick() {
        $('#unblockModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [
            {
                text: 'OK',
                click: function () {
                    $(this).dialog('close');
                    unblockCheckedDocuments();
                }
            },
            {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });
    }

    function onUnblockAllButtonClick() {
        $('#unblockAllModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [
            {
                text: 'OK',
                click: function () {
                    $(this).dialog('close');
                    unblockAllDocuments();
                }
            },
            {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });
    }

    return publicApi;
});

function checkAll() {
    let isChecked = $('input[id="check-all"]').is(':checked');
    $('input[id^="docid-"]').prop('checked', isChecked);
}
