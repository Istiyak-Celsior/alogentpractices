var QuickSearchDashboardWidgetViewModel = DashboardWidgetViewModel.extend({
    init: function (dashboard, widget, x, y, width, height, id) {
        DashboardWidgetViewModel.fn.init.call(this, dashboard, widget, x, y, width, height, id);
    },
    customerNames: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=customer&key=customerName&val=customerName',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: "string" }
                }
            }
        }
    }),
    customerNumbers: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=customer&key=customerNumber&val=customerNumber',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: 'string' }
                }
            }
        }
    }),
    taxIds: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=customer&key=taxid&val=taxid',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: 'string' }
                }
            }
        }
    }),
    accountNumbers: new kendo.data.DataSource({
        serverFiltering: true,
        transport: {
            read: {
                url: 'kendoQuickSearch.asp?table=loan&key=loanNumber&val=loanNumber',
                type: 'get',
                dataType: 'json',
                contentType: 'application/json',
                cache: false
            }
        },
        schema: {
            data: 'results',
            model: {
                fields: {
                    Value1: { type: 'string' }
                }
            }
        }
    })
});