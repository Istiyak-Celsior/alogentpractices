var ConversionHistoryTabController = (function(service) {
    var publicApi =
    {
        isLoaded : false
    };

    var isSearching = false;

    publicApi.getHistoryLog = function (historyId) {
        service.getHistoryLog(historyId, function (log) {
            $('#logText').val(log);
            $('#logModal').kendoWindow({
                width: '640px',
                title: 'Log',
                visible: false,
                actions: [
                    'Close'
                ]
            }).data('kendoWindow').center().open();
        });
    };

    publicApi.load = function () {
        performSearch();

        $('#searchQuery').keydown(function (e) {
            onSearchQueryKeyDown(e);
        });

        $('#searchLink').click(function (e) {
            onSearchLinkClick(e);
        });

        $('#clear-search').click(function () {
            $('#searchQuery').val('');
            $('#searchLimit').data('kendoDropDownList').value('1000');
            $('#searchConvertedFilter').data('kendoDropDownList').value('2');
            performSearch();
        });

        $('#searchLimit').kendoDropDownList();
        $('#searchConvertedFilter').kendoDropDownList();

        publicApi.isLoaded = true;
    };

    function performSearch() {
        if (isSearching)
            return;

        isSearching = true;

        $('#searchingImage').show();

        let searchQuery = $('#searchQuery').val();
        let limit = $('#searchLimit').val();
        let convertedFilter = $('#searchConvertedFilter').val();

        service.getHistory(searchQuery, limit, convertedFilter, function (results) {
            isSearching = false;

            $('#searchingImage').hide();

            initializeHistoryGrid(results);
        });
    }

    function onSearchLinkClick() {
        performSearch();
    }

    function onSearchQueryKeyDown(e) {
        if (e.which === 13) {
            performSearch();
        }
    }

    function getHistoryDhtmlXJsonTree(data) {
        var tree = {
            rows: []
        };

        var rowId = 0;

        $.each(data, function (index, value) {
            var row = {
                id: ++rowId,
                Converted: value.Converted,
                Date: value.Date,
                CustomerNumber: value.CustomerNumber,
                AccountNumber: value.AccountNumber,
                DocumentTypeName: value.DocumentTypeName,
                DocumentSubTypeName: value.DocumentSubTypeName,
                OldFileName: value.OldFileName,
                HistoryId: value.HistoryId
            };

            tree.rows.push(row);
        });

        return tree;
    }

    function initializeHistoryGrid(data) {
        $('#gridbox').html('');

        let gridData = getHistoryDhtmlXJsonTree(data);

        $('#gridbox').kendoGrid({
            dataSource: {
                data: gridData.rows,
                schema: {
                    model: {
                        id: 'id',
                        fields: {
                            Converted: { type: 'boolean' },
                            Date: { type: 'date' },
                            CustomerNumber: { type: 'string' },
                            AccountNumber: { type: 'string' },
                            DocumentTypeName: { type: 'string' },
                            DocumentSubTypeName: { type: 'string' },
                            OldFileName: { type: 'string' },
                            HistoryId: { type: 'string' }
                        }
                    }
                }
            },
            rowTemplate: kendo.template($('#grid-row-template').html()),
            height: 600,
            filterable: true,
            sortable: true,
            pageable: {
                pageSize: 25
            },
            columns: [
                { title: 'Converted', width: '80px' },
                {
                    title: 'Date',
                    field: 'Date',
                    filterable: {
                        multi: true,
                        search: true,
                        itemTemplate: function (e) {
                            return '<ul class="k-reset k-multicheck-wrap"><li class="k-item"><label class="k-label"><input type="checkbox" name="' + e.field + '" value="#= data.Date#" /><span>#= kendo.toString(kendo.parseDate(' + e.field + ', "yyyy-MM-dd"), "MM/dd/yyyy") || data.all #</span></label></li></ul>'
                        }
                    },
                    width: '100px'
                },
                { title: 'Customer', field: 'CustomerNumber', filterable: { multi: true, search: true } },
                { title: 'Account', field: 'AccountNumber', filterable: { multi: true, search: true } },
                { title: 'Group', field: 'DocumentTypeName', filterable: { multi: true, search: true } },
                { title: 'Tab', field: 'DocumentSubTypeName', filterable: { multi: true, search: true } },
                { title: 'File Name', field: 'OldFileName', filterable: { search: true }, width: '300px' },
                { title: 'Log', width: '80px' }
            ]
        }).data('kendoGrid');
    }

    return publicApi;
});