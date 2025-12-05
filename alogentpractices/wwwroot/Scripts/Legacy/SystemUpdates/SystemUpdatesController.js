var SystemUpdatesController = (function (service, $, undefined) {
    var publicApi =
    {
        isLoaded : false
    };

    publicApi.load = function () {
        kendo.ui.progress($(document.body), true);

        setTimeout(function () {
            initializeGrid('#historyGrid');
        }, 700);

        publicApi.isLoaded = true;
    };

    publicApi.getLog = function (updateHistoryId) {
        service.getLog(updateHistoryId, function (log) {
            $('#logText').text(log);
            $('#logModal').dialog({
                modal: true,
                title: 'Log',
                width: 640
            });
        });
    };

    function getHistoryDhtmlXJsonTree(data) {
        var tree = {
            rows: []
        };

        var rowId = 0;

        $.each(data, function (index, value) {
            var row = {
                id: ++rowId,
                HasErrors: value.HasErrors,
                HasWarnings: value.HasWarnings,
                Date: value.Date,
                Time: value.Time,
                User: value.User,
                FromVersion: value.FromVersion,
                ToVersion: value.ToVersion,
                UpdateHistoryId: value.UpdateHistoryId
            };

            tree.rows.push(row);
        });

        return tree;
    }

    function stopAnimation() {
        kendo.ui.progress($(document.body), false);
    }

    function initializeGrid(element) {
        service.getHistory(function (data) {
            console.log(data);

            var gridData = getHistoryDhtmlXJsonTree(data);
            console.log(gridData.rows);

            $(element).kendoGrid({
                dataSource: {
                    data: gridData.rows,
                    schema: {
                        model: {
                            id: 'id',
                            fields: {
                                HasErrors: { type: 'boolean' },
                                HasWarnings: { type: 'boolean' },
                                Date: { type: 'date' },
                                Time: { type: 'string' },
                                User: { type: 'string' },
                                FromVersion: { type: 'string' },
                                ToVersion: { type: 'string' },
                                UpdateHistoryId: { type: 'string' }
                            }
                        }
                    }
                },
                dataBound: function (e) {
                    stopAnimation();
                },
                rowTemplate: kendo.template($('#grid-row-template').html()),
                height: 600,
                filterable: true,
                sortable: true,
                columns: [
                    { title: ' ', width: '80px' },
                    { title: ' ', width: '80px' },
                    {
                        title: 'Date',
                        field: 'Date',
                        filterable: {
                            multi: true,
                            search: true,
                            itemTemplate: function (e) {
                                return '<ul class="k-reset k-multicheck-wrap"><li class="k-item"><label class="k-label"><input type="checkbox" name="' + e.field + '" value="#= data.Date#" /><span>#= kendo.toString(kendo.parseDate(' + e.field + ', "yyyy-MM-dd"), "MM/dd/yyyy") || data.all #</span></label></li></ul>'
                            }
                        }
                    },
                    { title: 'Time' },
                    { title: 'User', field: 'User', filterable: { multi: true, search: true } },
                    { title: 'From Version', field: 'FromVersion', filterable: { multi: true, search: true } },
                    { title: 'To Version', field: 'ToVersion', filterable: { multi: true, search: true } },
                    { title: 'Log', width: '80px' }
                ]
            }).data('kendoGrid');
        });
    }

    return publicApi;
});