var ActionEventController = (function (service, $) {
    var publicApi = {
        isLoaded: false
    };

    publicApi.load = function () {
        initializeWorkflowSortContent();
        $('#clone-toggle').click(showCloneWorkflowTypeDialog);
        publicApi.isLoaded = true;
    };

    /* Sortable workflow action behaviors */
    function initializeWorkflowSortContent() {
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
    }

    function initializeKendoSortableDefinitions() {
        $('div[id^="actions-"]').kendoSortable({
            handler: '.handler',
            cursor: 'move',
            change: enableSaveButton,
            hint: function (element) {
                return $('<span></span>').text(element.find('.event-name').text()).addClass('hint');
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
        var ids = []; var accountTypeId; var actionEventId;
        var actionType; var oldActionType;
        var sortOrderIds = 0;

        $('.action').each(function () {
            sortOrderIds++;
            actionEventId = $(this).prop('id');
            accountTypeId = $(this).data('account-type');
            actionType = $(this).data('action-type');
            if (oldActionType !== actionType) {
                sortOrderIds = 1;
            }
            oldActionType = $(this).data('action-type');

            ids.push({
                'ActionEventId': actionEventId,
                'SortOrder': sortOrderIds,
                'AccountTypeId': accountTypeId,
                'ActionType': actionType
            });
        });
        service.updateEventActionOrder(ids, function () {
            disableSaveButton();
        }, function (response) {
            if (response.statusCode !== 200) {
                showErrorDialog();
            }
        });
    }

    /* CLONE WORKFLOW TYPE SELECTOR BEHAVIORS */
    var cloneWorkflow = {
        dialog: null,
        loanTypeDropdown: null,
        cancelButton: null,
        confirmButton: null
    };

    function showCloneWorkflowTypeDialog() {
        service.getCloneableWorkflowTypes(function (data) {
            populateCloneableWorkflowTypes(data);
            enableCloneableWorkflowTypeSelect();
        });

        if (cloneWorkflow.dialog === null) {
            $('body').append('<div id="cloneWorkflowDialog"><div>');
            cloneWorkflow.dialog = $('#cloneWorkflowDialog').kendoDialog({
                modal: true,
                width: '640px',
                title: 'Clone Workflow Actions',
                content: kendo.template($('#aa-clone-workflow-dialog').html())
            }).data('kendoDialog');

            /* INITIALIZE CLONE DIALOG BUTTONS AND EVENTS */
            cloneWorkflow.confirmButton = $('#aa-clone-confirm').kendoButton({
                enable: false
            }).data('kendoButton');
            cloneWorkflow.confirmButton.bind('click', onCloneWorkflowCommitted);

            cloneWorkflow.cancelButton = $('#aa-clone-cancel').kendoButton().data('kendoButton');
            cloneWorkflow.cancelButton.bind('click', onCloneWorkflowCancelled);
        }

        cloneWorkflow.dialog.open();
    }

    function populateCloneableWorkflowTypes(data) {
        if (data.length > 0) {
            var typeSelectDataSource = [];
            typeSelectDataSource.push({
                'name': '-- Select ---',
                'id': ''
            });

            $.each(data, function (index, value) {
                typeSelectDataSource.push({
                    'name': value.LoanTypeDescription,
                    'id': value.LoanTypeId
                });
            });

            // Initialize the cloneable loan type dropdown list
            $('#targetLoanTypeId').kendoDropDownList({
                autoWidth: true,
                dataSource: typeSelectDataSource,
                dataTextField: 'name',
                dataValueField: 'id',
                valueTemplate: '<span class="aa-dialog-select">#: name #</span>',
                template: '<span class="aa-dialog-select">#: name #</span>',
                change: onWorkflowTypeSelected
            });

            cloneWorkflow.loanTypeDropdown = $('#targetLoanTypeId').data('kendoDropDownList');
            cloneWorkflow.loanTypeDropdown.select(0);
        }
        else {
            $('#aa-empty-list-message').show();
        }
    }

    /* EXECUTE THE CLONING FUNCTIONALITY */
    function onCloneWorkflowCommitted() {
        var sourceLoanTypeId = $('#tabstrip > ul > li.k-state-active').data('loantypeid');
        var targetLoanTypeId = cloneWorkflow.loanTypeDropdown.value();

        kendo.ui.progress($('#aa-clone-workflow-content'), true);

        setTimeout(function () {
            cloneWorkflow.confirmButton.enable(false);

            service.cloneWorkflow(sourceLoanTypeId, targetLoanTypeId, onCloneSuccess, onCloneFailure);
        }, 500);
    }

    function onCloneWorkflowCancelled() {
        cloneWorkflow.dialog.close();
    }

    function onWorkflowTypeSelected() {
        toggleWorkflowTypeConfirmButton();
    }

    function toggleWorkflowTypeConfirmButton() {
        var newLoanTypeId = cloneWorkflow.loanTypeDropdown.value();
        var showButton = newLoanTypeId === '' ? false : true;
        cloneWorkflow.confirmButton.enable(showButton);
    }

    function onCloneSuccess(url) {
        document.location.href = url + '&msg=1';
    }

    function onCloneFailure(response) {
        cloneWorkflow.dialog.close();
        console.log(response);
        displayAlertMessage('<i class="fas fa-ban" aria-hidden="true"></i>&nbsp;&nbsp;An error occured during the cloning process. Please contact administrators.', 'danger');
    }

    return publicApi;
});