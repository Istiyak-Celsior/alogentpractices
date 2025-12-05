    $(document).ready(function () {
        // #### CUSTOMER NAME AUTOCOMPLETE #### //
        $('#combo_zone_cname').kendoAutoComplete({
            dataTextField: 'mask',
            filter: 'contains',
            placeholder: "Enter Customer Name...",
            template: '<span class="customer-name-autocomplete">#:data.Value1#</span>',
            filtering: function (e) {
                if (e.filter.value.length < 3) {
                    e.preventDefault();
                    e.sender.dataSource.data([]);
                }
            },
            dataSource: {
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
                            Value1: { type: 'string' }
                        }
                    }
                }
            },
            select: function (e) {
                var dataItem = this.dataItem(e.item.index());
                $('#combo_zone_cname').val(dataItem.Value1);
            }
        });

        // #### CUSTOMER NUMBER AUTOCOMPLETE #### //
        $('#combo_zone_cnumber').kendoAutoComplete({
            dataTextField: 'mask',
            filter: 'contains',
            placeholder: "Enter Customer Number...",
            template: '<span class="customer-number-autocomplete">#:data.Value1#</span>',
            filtering: function (e) {
                if (e.filter.value.length < 3) {
                    e.preventDefault();
                    e.sender.dataSource.data([]);
                }
            },
            dataSource: {
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
            },
            select: function (e) {
                var dataItem = this.dataItem(e.item.index());
                $('#combo_zone_cnumber').val(dataItem.Value1);
            }
        });

        // #### CUSTOMER TAX ID AUTOCOMPLETE #### //
        $('#combo_zone_taxid').kendoAutoComplete({
            dataTextField: 'mask',
            filter: 'contains',
            placeholder: "Enter Customer Tax Id...",
            template: '<span class="customer-taxid-autocomplete">#:data.Value1#</span>',
            filtering: function (e) {
                if (e.filter.value.length < 3) {
                    e.preventDefault();
                    e.sender.dataSource.data([]);
                }
            },
            dataSource: {
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
            },
            select: function (e) {
                var dataItem = this.dataItem(e.item.index());
                $('#combo_zone_taxid').val(dataItem.Value1);
            }
        });

        // #### ACCOUNT NUMBER AUTOCOMPLETE #### //
        $('#combo_zone_lnumber').kendoAutoComplete({
            dataTextField: 'mask',
            filter: 'contains',
            placeholder: "Enter Account Number...",
            template: '<span class="account-number-autocomplete">#:data.Value1#</span>',
            filtering: function (e) {
                if (e.filter.value.length < 3) {
                    e.preventDefault();
                    e.sender.dataSource.data([]);
                }
            },
            dataSource: {
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
            },
            select: function (e) {
                var dataItem = this.dataItem(e.item.index());
                $('#combo_zone_lnumber').val(dataItem.Value1);
            }
        });

        $('#combo_zone_cname').focus();
    });
