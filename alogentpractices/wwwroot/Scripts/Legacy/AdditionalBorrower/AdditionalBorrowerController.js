var AdditionalBorrowerController = (function (service, $, undefined) {
    var publicApi =
    {
        isLoaded: false
    };

    // kendo objects
    var changePrimaryBorrowerDialog         = null;
    var borrowerTypeDropDownList            = null;
    var borrowerDropDownList                = null;
    var confirmButton                       = null;
    var cancelButton                        = null;

    // data sources
    var borrowerTypeSelectDataSource        = [];
    var additionalBorrowerSelectDataSource  = [];

    function initializeSettings() {
        var selectedAccountClassId = $('#uxSelectedAccountClassId').html();
        service.getBorrowerTypes(selectedAccountClassId, function (data) {
            populateBorrowerTypeSelect(data);
            enableBorrowerTypeSelect();
        });

        var selectedLoanId = $('#uxSelectedLoanId').html();
        service.getAdditionalBorrowers(selectedLoanId, function (data) {
            populateAdditionalBorrowerSelect(data);
            enableAdditionalBorrowerSelect();
        });
    }

    function enableBorrowerTypeSelect() {
        $("#borrowerTypeListLoading").hide();
    }

    function enableAdditionalBorrowerSelect() {
        $("#newBorrowerListLoading").hide();
    }

    function onBorrowerTypeSelected() {
        toggleUpdateButton();
    }

    function onNewPrimaryBorrowerSelected() {
        toggleUpdateButton();
    }

    function populateAdditionalBorrowerSelect(data) {
        additionalBorrowerSelectDataSource = [];
        additionalBorrowerSelectDataSource.push({
            "name": "-- Select borrower ---",
            "id": ""
        });

        $.each(data, function( index, value){
            additionalBorrowerSelectDataSource.push({
                "name": value.CustomerName + ' (' + value.CustomerNumber + ")",
                "id": value.CustomerId
            });
        });

        // Initialize the additional borrower type dropdown list
        $("#newPrimaryBorrowerId").kendoDropDownList({
            autoWidth: true,
            dataSource: additionalBorrowerSelectDataSource,
            dataTextField: "name",
            dataValueField: "id",
            valueTemplate: "<span class=\"aa-dialog-select\">#: name #</span>",
            template: "<span class=\"aa-dialog-select\">#: name #</span>",
            change: onNewPrimaryBorrowerSelected
        });

        borrowerDropDownList = $("#newPrimaryBorrowerId").data("kendoDropDownList");
        borrowerDropDownList.select(0);
    }

    function populateBorrowerTypeSelect(data) {
        borrowerTypeSelectDataSource = [];
        borrowerTypeSelectDataSource.push({
            "name": "-- Select borrower type ---",
            "id": ""
        });

        $.each(data, function( index, value){
            borrowerTypeSelectDataSource.push({
                "name": value.BorrowerTypeName,
                "id": value.BorrowerTypeId
            });
        });
      
        // Initialize the additional borrower dropdown list
        $("#borrowerTypeIdToChangeTo").kendoDropDownList({
            autoWidth: true,
            dataSource: borrowerTypeSelectDataSource,
            dataTextField: "name",
            dataValueField: "id",
            valueTemplate: "<span class=\"aa-dialog-select\">#: name #</span>",
            template: "<span class=\"aa-dialog-select\">#: name #</span>",
            change: onBorrowerTypeSelected
        });

        borrowerTypeDropDownList = $("#borrowerTypeIdToChangeTo").data("kendoDropDownList");
        borrowerTypeDropDownList.select(0);
    }

    function showChangePrimaryBorrowerDialog() {
        initializeSettings();

        if (changePrimaryBorrowerDialog == null) {
            $('body').append('<div id="changePrimaryBorrowerDialog"><div>');
            changePrimaryBorrowerDialog = $("#changePrimaryBorrowerDialog").kendoDialog({
                modal: true,
                width: "400px",
                title: "Change Primary Borrower",
                content: kendo.template($("#changePrimaryBorrowerContent").html()),
                close: onCloseDialog
            }).data("kendoDialog");

            // initialize buttons and events
            confirmButton = $("#aa-change-borrower-confirm").kendoButton({ enable: false }).data("kendoButton");
            confirmButton.bind("click", onChangeBorrowerDialogCommitted);

            cancelButton = $("#aa-change-borrower-cancel").kendoButton().data("kendoButton");
            cancelButton.bind("click", onChangeBorrowerCancelDialog);
        }

        changePrimaryBorrowerDialog.open();

        $('#changePrimaryBorrowerDialog span.validation-error').parent().hide();
    };

    function refreshGuarantorsDisplay(data) {
        updateNewPrimaryBorrowerRow(data);
        updateOldPrimaryBorrowerRow(data);
        updateAccountHeader(data);

        // update the hidden primaryBorrowerId field
        $('#uxPrimaryBorrowerId').html(data.CustomerId);
        changePrimaryBorrowerDialog.close();
    }

    function resetGuarantorsDisplay(data) {
        var changeOfBorrowerErrorDisplay = $('#changeOfBorrowerErrorDisplay');
        var changeOfBorrowerErrorMessage = $('#changeOfBorrowerErrorMessage');
        changeOfBorrowerErrorMessage.empty();
        changeOfBorrowerErrorMessage.text(data.responseText);
        changeOfBorrowerErrorDisplay.show();


        var selectedCustomerId = $('#uxPrimaryBorrowerId').html();

        var actionCell = $('#uxBorrowerActionCell_' + selectedCustomerId);
        actionCell.empty();
        actionCell.append('<i class="fas fa-circle aa-status-yes fa-fw" title="Primary Borrower" aria-hidden="true"></i>&nbsp;&nbsp;')
        actionCell.append($('<a></a>')
            .attr('id', 'changePrimaryBorrower')
            .attr('href', 'javascript:void(0)')
            .append('<i class="aa-icon fas fa-cog fa-fw" title="Change Primary Borrower" aria-hidden="true"></i>')
        );

        // re-register event to the new change primary borrower icon-link
        borrowerDropDownList.bind("change", onChangePrimaryBorrowerClick);
        changePrimaryBorrowerDialog.close();
    }

    function updateOldPrimaryBorrowerRow(data) {
        var selectedCustomerId = $('#uxSelectedCustomerId').html();
        var selectedLoanId = data.LoanId;
        var oldPrimaryBorrowerId = $('#uxPrimaryBorrowerId').html();

        // Clear out the action cell of the current primary borrower
        $('#uxBorrowerActionCell_' + oldPrimaryBorrowerId).empty();

        // Update the old primary borrower's type
        var typeCell = $('#uxBorrowerTypeCell_' + oldPrimaryBorrowerId);
        typeCell.html($('#borrowerTypeIdToChangeTo').find(':selected').text());

        var editBorrowerUrl = 'borrowerMaintenance.asp?customerId={' + oldPrimaryBorrowerId + '}&loanId={' + selectedLoanId + '}&borrowerTypeId={' + $('#borrowerTypeIdToChangeTo').find(':selected').val() + '}';
        typeCell.append('&nbsp;<a href="javascript:void(0);" onclick="openKendoDialog(\'Change Borrower Type\', \'' + editBorrowerUrl + '\', 315, 500);" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a>');
    }

    function updateNewPrimaryBorrowerRow(data) {
        var selectedCustomerId = $('#uxSelectedCustomerId').html();
        var newPrimaryBorrowerId = data.CustomerId;

        var actionCell = $('#uxBorrowerActionCell_' + newPrimaryBorrowerId);
        actionCell.empty();
        actionCell.append('<i class="fas fa-circle aa-status-yes fa-fw" title="Primary Borrower" aria-hidden="true"></i>&nbsp;&nbsp;')

        actionCell.append($('<a></a>')
            .attr('id', 'changePrimaryBorrower')
            .attr('href', 'javascript:void(0)')
            .append('<i class="aa-icon fas fa-cog fa-fw" title="Change Primary Borrower" aria-hidden="true"></i>')
        );

        // re-register event to the new change primary borrower icon-link
        $('#changePrimaryBorrower').on('click', onChangePrimaryBorrowerClick);

        // if the currently selected customer is the new borrower then disable navigation element
        if (selectedCustomerId == data.CustomerId) {
            // change name cell so it displays the new primary borrower name with no link
            $('#uxBorrowerNameCell_' + newPrimaryBorrowerId).html(data.CustomerName);
        }

        // update the borrower type cell to reflect new borrower type
        $('#uxBorrowerTypeCell_' + newPrimaryBorrowerId).html(data.BorrowerType);
    }

    function updateAccountHeader(data) {
        var borrowerTypeCell = $('#displayedBorrowerTypeDescription');
        var selectedCustomerId = $('#uxSelectedCustomerId').html();
        var primaryBorrowerId = $('#uxPrimaryBorrowerId').html();

        if (selectedCustomerId == data.CustomerId) {
            borrowerTypeCell.html(data.BorrowerType);
        } else {
            var innerText = $('#borrowerTypeIdToChangeTo').find(':selected').text()
            borrowerTypeCell.html(innerText);
        }
    }

    function startProgressIndicator() {
        var currentPrimaryBorrowerId = $('#uxPrimaryBorrowerId').html();
        var borrowerActionCell = $('#uxBorrowerActionCell_' + currentPrimaryBorrowerId);

        // remove the change of primary borrower anchor and image
        $('#changePrimaryBorrower').remove();

        // add progress icon to action cell
        borrowerActionCell.append('<i class="aa-icon fas fa-cog fa-spin fa-3x fa-fw" title="Change of borrower in progress..." aria-hidden="true"></i>');
    }

    function toggleUpdateButton() {
        var newPrimaryBorrowerId = borrowerDropDownList.value();
        var selectedBorrowerTypeId = borrowerTypeDropDownList.value();

        if (newPrimaryBorrowerId != '' && selectedBorrowerTypeId != '') {
            confirmButton.enable(true);
        }
        else {
           confirmButton.enable(false);
        }
    }


    function onCloseDialog(){
        if (changePrimaryBorrowerDialog != null){
            confirmButton.destroy();
            cancelButton.destroy();
            borrowerTypeDropDownList.destroy();
            borrowerDropDownList.destroy();
            changePrimaryBorrowerDialog.destroy();

            confirmButton = null;
            cancelButton = null;
            borrowerTypeDropDownList = null;
            borrowerDropDownList = null;
            changePrimaryBorrowerDialog = null;
        }
    }

    // dialog event handling functions
    function onChangeBorrowerCancelDialog(){
        changePrimaryBorrowerDialog.close();
    }

    function onChangeBorrowerDialogCommitted() {
        confirmButton.enable(false);

        var selectedLoanId = $('#uxSelectedLoanId').html();
        var newPrimaryBorrowerId = borrowerDropDownList.value();
        var selectedBorrowerTypeId = borrowerTypeDropDownList.value();

        startProgressIndicator();
        service.changePrimaryBorrower(
            newPrimaryBorrowerId,
            selectedLoanId,
            selectedBorrowerTypeId,
            function (data) { refreshGuarantorsDisplay(data); },
            function (data) { resetGuarantorsDisplay(data); }
        );
    }

    function onChangePrimaryBorrowerClick() {
        showChangePrimaryBorrowerDialog();
    }


    publicApi.load = function () {
        $('#changePrimaryBorrower').on('click', onChangePrimaryBorrowerClick);

        publicApi.isLoaded = true;
    };

    return publicApi;
});