var CopyCreditDocumentsController = (function (service, $, undefined) {
    var publicApi =
    {
        isLoaded: false,
        custNameCombo: null,
        custNumberCombo: null
    };

    publicApi.load = function () {
        initializeSettings();

        publicApi.isLoaded = true;
    };

    function initializeSettings() {
        // Setup events in select customer panel
        $('#searchCustomer').hover(
            function () { $(this).css('cursor', 'pointer'); },
            function () { $(this).css('cursor', 'auto'); });

        $('#searchCustomer').click(function () {
            var error = CheckForIdenticalCustomers();
            if (!error) {
                getCustomerInfo();
                error = CheckForDifferentCustomerTypes();

                if (!error) {
                    $('#selectCustomerPanel').addClass('aa-hidden');
                    $('#confirmationPanel').removeClass('aa-hidden');
                }
            }
        });

        $('#clearForm').hover(
            function () {
                $(this).css('cursor', 'pointer');
            },
            function () {
                $(this).css('cursor', 'auto');
            }
        );

        $('#clearForm').click(function () {
            $('#dstCustomerId').val('');
            $('#combo_zone_cname').val('');
            $('#combo_zone_cnumber').val('');
            $('#selectErrorMessage').addClass('aa-hidden');
        });

        // Setup events in the confirmation panel
        $('#confirmContinue').hover(
            function () { $(this).css('cursor', 'pointer'); },
            function () { $(this).css('cursor', 'auto'); });

        $('#confirmContinue').click(function () {
            submitCopyRequest();
        });

        // setup events in the results panel
        $('#closeButton').hover(
            function () { $(this).css('cursor', 'pointer'); },
            function () { $(this).css('cursor', 'auto'); });

        $('#closeButton').click(function () {
            refreshPageToDestinationCustomer();
        });
    }

    function getCustomerInfo () {
        var srcCustomerId = $('#srcCustomerId').val();
        var dstCustomerId = $('#dstCustomerId').val();

        service.getCustomerInfo(srcCustomerId, function (data) {
            $('#srcCustomerTypeId').val(data.CustomerTypeId);
            $('#srcCustomerName').val(data.CustomerName);
            $('#srcCustomerNumber').val(data.CustomerNumber);

            $('#sourceCustomerInfo').text(data.CustomerName + ' (' + data.CustomerNumber + ')');

        });

        service.getCustomerInfo(dstCustomerId, function (data) {
            $('#dstCustomerTypeId').val(data.CustomerTypeId);
            $('#dstCustomerName').val(data.CustomerName);
            $('#dstCustomerNumber').val(data.CustomerNumber);

            $('#targetCustomerInfo').text(data.CustomerName + ' (' + data.CustomerNumber + ')');
        });
    }

    function submitCopyRequest() {
        $('#confirmationPanel').addClass('aa-hidden');
        $('#copyResultsPanel').removeClass('aa-hidden');

        service.copyCreditDocuments(
            $('#srcCustomerId').val(),
            $('#dstCustomerId').val(),
            $('#userLogin').val(),
            function (data) {
                displayResults(data);
            }
        );
    }

    function removeCurlyBraces(str) {
        return str.replace(/[{}]/g, '');
    }

    function CheckForIdenticalCustomers() {
        var errorFound = false;

        var srcId = removeCurlyBraces($('#srcCustomerId').val());
        srcId = '{' + srcId + '}';
        var dstId = removeCurlyBraces($('#dstCustomerId').val());
        dstId = '{' + dstId + '}';

        if (srcId === dstId) {
            $('#selectErrorMessage').html('<b>Origination and destination customer cannot be the same</b>').removeClass('aa-hidden');
            errorFound = true;
        }

        return errorFound;
    }

    function CheckForDifferentCustomerTypes() {
        var errorFound = false;
        var srcTypeId = $('#srcCustomerTypeId').val();
        var dstTypeId = $('#dstCustomerTypeId').val();

        if (srcTypeId != dstTypeId) {
            $('#selectErrorMessage').html('<b>Selected customer is a different customer ' +
                                          'type.</b><br/><span class="fc-black">This feature only allows copying credit documents between ' +
                                          'customers of the same type.</span>').removeClass('aa-hidden');
            errorFound = true;
        }

        return errorFound;
    }

    function displayResults(data) {
        $('#documentsCopiedCount').text(data.DocumentsCopied);
        $('#documentsNotCopiedCount').text(data.DocumentsNotCopied);

        if (data.DocumentsNotCopied > 0) {
            $('#processingResults').addClass('aa-hidden');
            $('#copyResults').removeClass('aa-hidden');

            $('#resultWarningMessage').html('One or more files did not get copied. See below for details.').removeClass('aa-hidden');

            var div;
            var detailsPanel = $('#errorDetails');

            for (var i = 0; i < data.FailedDocumentCopyDetails.length; i++) {
                if (i === 0) {
                    div = $('<div/>',
                    {
                        'html': data.FailedDocumentCopyDetails[i]
                    });
                    detailsPanel.append(div);
                } else {
                    div = $('<div/>',
                        {
                            'html': '<br/>' + data.FailedDocumentCopyDetails[i]
                        });
                    detailsPanel.append(div);
                }
            }
        }
        else {
            refreshPageToDestinationCustomer();
        }
    }

    function refreshPageToDestinationCustomer() {
        parent.location.href = 'customer.asp?customerId=' + $('#dstCustomerId').val();
    }

    return publicApi;
});