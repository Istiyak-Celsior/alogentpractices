var AutomaticPageRecognitionTabController = (function (service) {
    var publicApi =
    {
        isLoaded : false
    };

    publicApi.load = function () {
        /// <summary>Loads the controller by instantiating user interface events and loading data.</summary>

        service.getPageRecognitionDefinitions(function (data) {
            $.each(data, function (i, v) {
                appendDefinitionElement(createDefinitionElement(v));
            });
        });

        $('#editDefinitionThreshold').spinner({
            step: 5,
            spin: function(event, ui) {
                      if (ui.value > 100) {
                          return false;
                      }
                      else if (ui.value < 5) {
                          return false;
                      }
                  }
        });
        $('#pageDefinitionList').on('click', '.definition', function (e) { onDefinitionClick($(e.target)); });
        $('#pagePatternList').on('click', '.edit', function (e) { onEditPatternClick($(e.target).parent().parent()); });
        $('#pagePatternList').on('click', '.delete', function (e) { onDeletePatternClick($(e.target).parent().parent()); });
        $('#addDefinition').on('click', onAddDefinitionClick);
        $('#testDefinitions').on('click', onTestDefinitionsClick);
        $('#editDefinition').on('click', onEditDefinitionClick);
        $('#deleteDefinition').on('click', onDeleteDefinitionClick);
        $('#addPattern').on('click', onAddPatternClick);

        publicApi.isLoaded = true;
    };

    function appendDefinition(definition) {
        /// <summary>Creates a new HTML element that represents the specified definition and appends it to the definition list.</summary>
        /// <param name="definition">The JSON object containing the definition data.</param>

        var definitionElement = createDefinitionElement(definition);
    
        definitionElement.addClass('.selected');
    
        $('#pageDefinitionList').prepend(definitionElement);
    
        sortDefinitionList();
    
        definitionElement.click();
    
        $('#definitionName').text(definition.name);

        if (definition.Enabled)
            enableDefinitionElement(definitionElement);
    };

    function appendDefinitionElement(element) {
        $('#pageDefinitionList').append(element);
    };

    function disablejQueryDialogButton(buttonName) {
        $(':button:contains("'+ buttonName + '")').attr('disabled', true).addClass('ui-state-disabled');
    };

    function enablejQueryDialogButton(buttonName) {
        $(':button:contains("' + buttonName + '")').attr('disabled', false).removeClass('ui-state-disabled');
    };
    
    function getDefinitionFormValues() {
        return {
            name : $('#editDefinitionName').val(),
            threshold: $('#editDefinitionThreshold').val(),
            enabled: $('#enableDefinition').prop('checked')
        };
    };

    function getSelectedDefinitionElement() {
        return $('.definition.selected').first();
    };

    function setDefinitionFormValues(name, threshold, enabled) {
        $('#editDefinitionName').val(name);
        $('#editDefinitionThreshold').val(threshold);
        $('#enableDefinition').prop('checked', enabled);
    };

    function sortDefinitionList() {
        var list = $('.definition');

        list.sort(function (x, y) {
            return $(x).text().localeCompare($(y).text());
        }).appendTo('#pageDefinitionList');
    };

    function onAddDefinitionDialogCommitted() {
        disablejQueryDialogButton('Add');

        var dialogRef = $(this);
        var newValues = getDefinitionFormValues();
        var dto = { Id: null, Name: newValues.name, Threshold: newValues.threshold, Enabled: newValues.enabled };

        service.addPageRecognitionDefinition(dto,
            function (definitionId) {
                dto.Id = definitionId;
                dto.Patterns = [];
            
                appendDefinition(dto);
            
                dialogRef.dialog('close');
            },
            function (exception) {
                $('#definitionModal span.validation-error').text(exception.ErrorMessage);
                $('#definitionModal span.validation-error').parent().show();
                $('#editDefinitionName').select();

                enablejQueryDialogButton('Add');
            });
    };

    function onEditDefinitionDialogCommitted() {
        disablejQueryDialogButton('Update');
    
        var dialogRef = $(this);
        var element   = getSelectedDefinitionElement();
        var newValues = getDefinitionFormValues();
        var dto       = { Id: element.data('id'), Name: newValues.name, Threshold: newValues.threshold, Enabled: newValues.enabled };
    
        service.updatePageRecognitionDefinition(dto,
            function () {
                setDefinitionData(element, { name: newValues.name, threshold: newValues.threshold, enabled: newValues.enabled });
            
                if (newValues.enabled)
                    enableDefinitionElement(element);
                else
                    disableDefinitionElement(element);
            
                updateSelectedDefinitionDisplayValues();
                sortDefinitionList();
            
                dialogRef.dialog('close');
            },
            function (exception) {
                $('#definitionModal span.validation-error').text(exception.ErrorMessage);
                $('#definitionModal span.validation-error').parent().show();
                $('#editDefinitionName').select();

                enablejQueryDialogButton('Update');
            });
    };

    function getDefinitionData(definition) {
        return {
            id : definition.data('id'),
            name : definition.data('name'),
            threshold : definition.data('threshold'),
            patterns: definition.data('patterns'),
            enabled: definition.data('enabled')
        };
    };

    function setDefinitionData(definition, data) {
        if (data.id !== undefined) definition.data('id', data.id);
        if (data.name !== undefined) definition.data('name', data.name);
        if (data.threshold !== undefined) definition.data('threshold', data.threshold);
        if (data.patterns !== undefined) definition.data('patterns', data.patterns);
        if (data.enabled !== undefined) definition.data('enabled', data.enabled);
    };

    function showAddDefinitionDialog() {
        setDefinitionFormValues('New Page', 0, false);

        $('#definitionModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [{
                text : 'Add',
                click : onAddDefinitionDialogCommitted
            }, {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });

        $('#definitionModal span.validation-error').parent().hide();
        $('#editDefinitionName').focus();
        $('#editDefinitionName').select();
    };

    function showEditDefinitionDialog() {
        var element = getSelectedDefinitionElement();
        var data    = getDefinitionData(element);

        setDefinitionFormValues(data.name, data.threshold, data.enabled);
    
        $('#definitionModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [
            {
                text: 'Update',
                click: onEditDefinitionDialogCommitted
            },
            {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });

        $('#definitionModal span.validation-error').parent().hide();
        $('#editDefinitionName').focus();
        $('#editDefinitionName').select();
    };

    function updateSelectedDefinitionDisplayValues() {
        var selectedDefinition = getSelectedDefinitionElement();
        var data = getDefinitionData(selectedDefinition);

        selectedDefinition.text(data.name);
        $('#definitionName').text(data.name);
    };

    function onAddDefinitionClick() {
        showAddDefinitionDialog();
    };

    function onEditDefinitionClick() {
        showEditDefinitionDialog();
    };

    function onDeleteDefinitionClick() {
        showDeleteDefinitionDialog();
    };

    function onDeleteDefinitionDialogCommitted() {
        disablejQueryDialogButton('Delete');

        var dialogRef = $(this);
        var definition = getSelectedDefinitionElement();
        var data = getDefinitionData(definition);

        service.deletePageRecognitionDefinition(data.id, function () {
            dialogRef.dialog('close');

            removeDefinitionElement(definition);

            $('#pageDefinitionContainer').fadeOut();
        });
    };

    function showDeleteDefinitionDialog() {
        $('#deleteModal span').text('Are you sure you want to delete the selected page definition and all of its patterns?');

        $('#deleteModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [
            {
                text: 'Delete',
                click: onDeleteDefinitionDialogCommitted
            },
            {
                text: 'Cancel',
                click: function() { $(this).dialog('close'); }
            }]
        });
    };

    function removeDefinitionElement(definitionElement) {
        definitionElement.remove();
    };

    function getPattern(patterns, patternId) {
        return $.grep(patterns, function (item) {
            return item.id === patternId;
        })[0];
    };

    function getPatternElementData(patternElement) {
        return {
            id: patternElement.data('id'),
            patternType: patternElement.data('patternType'),
            pattern: patternElement.data('pattern')
        };
    };

    function setPatternElementData(patternElement, data) {
        if (data.id !== undefined) patternElement.data('id', data.id);
        if (data.patternType !== undefined) patternElement.data('patternType', data.patternType);
        if (data.pattern !== undefined) patternElement.data('pattern', data.pattern);
    };

    function removePatternElement(patternId, element) {
        element.fadeOut(function () {
            element.remove();

            var definition = $('.definition.selected');
            var patterns = definition.data('patterns');

            var filteredPatterns = patterns.filter(function (item) {
                var x = item.Id;
                var y = patternId;

                return x !== y;
            });

            definition.data('patterns', filteredPatterns);
        });
    };

    function onDeletePatternClick(pattern) {
        showDeletePatternDialog(pattern);
    };

    function onDeletePatternDialogCommitted(dialogReference, patternElement) {
        disablejQueryDialogButton('Delete');

        var data = getPatternElementData(patternElement);

        service.deletePageRecognitionPattern(data.id, function () {
            dialogReference.dialog('close');
            removePatternElement(data.id, patternElement);
            removePattern(getSelectedDefinitionElement(), data.id);
        });
    };

    function removePattern(definitionElement, patternId) {
        var patterns = getDefinitionData(definitionElement).patterns;

        for (var i = 0; i < patterns.length; i++) {
            if (patterns[i].id === patternId) {
                patterns.splice(i, 1);
            }
        }
    };

    function showDeletePatternDialog(pattern) {
        $('#deleteModal span').text('Are you sure you want to delete the selected pattern?');

        $('#deleteModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [{
                text: 'Delete',
                click: function () { onDeletePatternDialogCommitted($(this), pattern); }
            },
            {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });
    };

    function onEditPatternClick(pattern) {
        showEditPatternDialog(pattern);
    };

    function getPatternDialogFormValues() {
        return {
            pattern: $('#pattern').val(),
            patternType : $('#patternType').val()
        };
    };

    function setPatternDialogFormValues(data) {
        $('#pattern').val(data.pattern);
        $('#patternType').val(data.patternType);
    };

    function showEditPatternDialog(patternElement) {
        var data = getPatternElementData(patternElement);

        setPatternDialogFormValues(data);

        $('#editPatternModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [
            {
                text: 'Update',
                click: function () { onEditPatternDialogCommitted($(this), patternElement); }
            },
            {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });

        $('#editPatternModal span.validation-error').parent().hide();
        $('#pattern').select();
    };

    function updateSelectedDefinitionElementPatternData(patternId, values) {
        var definition      = getSelectedDefinitionElement();
        var definitionData  = getDefinitionData(definition);
        var pattern         = getPattern(definitionData.patterns, patternId);

        pattern.pattern     = values.pattern;
        pattern.patternType = values.patternType;
    };

    function updatePatternDisplayValues(pattern) {
        var data = getPatternElementData(pattern);

        pattern.find('.pattern-type').text(data.patternType);
        pattern.find('.pattern-value').text(data.pattern);
    };

    function onEditPatternDialogCommitted(dialogReference, patternElement) {
        disablejQueryDialogButton('Update');

        var oldValues = getPatternElementData(patternElement);
        var newValues = getPatternDialogFormValues();
        var dto       = { Id: oldValues.id, PatternType: newValues.patternType, Pattern: newValues.pattern };

        service.updatePageRecognitionPattern(dto, 
            function () {
                setPatternElementData(patternElement, { patternType: newValues.patternType, pattern: newValues.pattern });
            
                updateSelectedDefinitionElementPatternData(oldValues.id, { patternType: newValues.patternType, pattern: newValues.pattern });
            
                updatePatternDisplayValues(patternElement);
            
                dialogReference.dialog('close');
            },
            function (exception) {
                $('#editPatternModal span.validation-error').text(exception.ErrorMessage);
                $('#editPatternModal span.validation-error').parent().show();
                $('#pattern').select();
            
                enablejQueryDialogButton('Update');
            });
    };

    function onAddPatternClick() {
        showAddPatternDialog();
    };

    function showAddPatternDialog() {
        $('#patternType').val('Required');
        $('#pattern').val('');

        $('#editPatternModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 640,
            buttons: [
            {
                text: 'Add',
                click: onAddPatternDialogCommitted
            },
            {
                text: 'Cancel',
                click: function () { $(this).dialog('close'); }
            }]
        });

        $('#editPatternModal span.validation-error').parent().hide();
        $('#pattern').select();
    };

    function onAddPatternDialogCommitted() {
        disablejQueryDialogButton('Add');
    
        var definition = getSelectedDefinitionElement();
        var definitionData = getDefinitionData(definition);
        var patternType = $('#patternType').val();
        var patternValue = $('#pattern').val();
        var dialogRef = $(this);
        var dto = { Id: null, DefinitionId: definitionData.id, PatternType: patternType, Pattern: patternValue };
    
        service.addPageRecognitionPattern(dto,
            function (patternId) {
                var patterns       = getDefinitionData(definition).patterns;
                var pattern        = { id: patternId, definitionId: definitionData.id, patternType: patternType, pattern: patternValue };
                var patternElement = createPatternElement(pattern);
            
                patterns.push(pattern);
            
                appendPatternElement(patternElement);
            
                dialogRef.dialog('close');
            },
            function (exception) {
                $('#editPatternModal span.validation-error').text(exception.ErrorMessage);
                $('#editPatternModal span.validation-error').parent().show();
                $('#pattern').select();
            
                enablejQueryDialogButton('Add');
            });
    };

    function appendPatternElement(patternElement) {
        patternElement.hide();
    
        $('#pagePatternList').append(patternElement);
    
        patternElement.fadeIn();
    };

    function onDefinitionClick(definition) {
        $('#definitionName').text(definition.data('name'));
        $('#definitionThreshold').text(definition.data('threshold'));
        $('#pagePatternList').html('');

        $('#pageDefinitionList span').removeClass('selected');
        definition.addClass('selected');

        $.each(definition.data('patterns'), function (i, v) {
            appendPatternElement(createPatternElement(v));
        });

        $('#pageDefinitionContainer').fadeIn();
    };

    function disableDefinitionElement(definitionElement) {
        if (definitionElement.hasClass('disabled'))
            return;

        definitionElement.addClass('disabled');
    };

    function enableDefinitionElement(definitionElement) {
        if (definitionElement.hasClass('disabled')) {
            definitionElement.removeClass('disabled');
        }
    };

    function createDefinitionElement(definition) {
        var definitionElement = $('<span/>',
                                 {
                                     'class': 'definition',
                                     'text' : definition.Name
                                 });

        if (!definition.Enabled) {
            disableDefinitionElement(definitionElement);
        }

        definitionElement.data('id', definition.Id);
        definitionElement.data('name', definition.Name);
        definitionElement.data('threshold', definition.Threshold);
        definitionElement.data('enabled', definition.Enabled);

        var patterns = [];

        $.each(definition.Patterns,
            function(i, v) {
                patterns.push({ id: v.Id, definitionId : v.DefinitionId, patternType: v.PatternType, pattern: v.Pattern });
            });

        definitionElement.data('patterns', patterns);

        return definitionElement;
    };

    function createPatternElement(pattern) {
        var patternElement = $('<div/>',
                              {
                                  'class': 'pattern'
                              });

        patternElement.html('<a class="delete" href="#"><img src="./Content/Images/Icons/trash-can-icon.png"/></a>' +
                            '<a class="edit" href="#"><img src="./Content/Images/Icons/actions-document-edit-icon.png"/></a>&nbsp;' +
                            '<span class="pattern-type">' + pattern.patternType + '</span>&nbsp;' +
                            '<span class="pattern-value">' + pattern.pattern + '</span>');

        patternElement.data('id', pattern.id);
        patternElement.data('definitionId', pattern.definitionId);
        patternElement.data('patternType', pattern.patternType);
        patternElement.data('pattern', pattern.pattern);

        return patternElement;
    };

    function onTestDefinitionsDialogCommitted() {
        disablejQueryDialogButton('Test');

        $('.adrtest.step1').hide();
        $('.adrtest.step2').show();

        $('#testFileProgress').progressbar({
            value: false
        });

        $('#testFileProgress').fadeIn();

        var data      = new FormData();
        var files     = $('#testFile').get(0).files;
        var file      = files[0];

        data.append("Test File", file);

        service.testPageRecognitionDefinitions(data, function (results) {
            $('#testFileProgress').hide();
            $('.adrtest.step2').hide();

            displayTestResults(results);
        },
        function (exception) {
            $('#testFileProgress').hide();
            $('.adrtest.step2').hide();

            displayTestException(exception);
        });
    };

    function displayTestException(exception) {
        var html = '<span class="validation-error">';

        if (exception === undefined || exception === null) {
            html += 'An unexpected error occurred when running the test. Check your web server and web application configuration and ensure you are not exceeding the maximum allowed file size.';
        }
        else {
            html += exception.ErrorMessage;
        }

        html += '</span>';

        $('.adrtest.step3').html(html).show();
    };

    function displayTestResults(d) {
        var html = '';

        if (d.length === 0) {
            html += 'There were no pages found that matched any patterns you have defined.';
        }
        else {
            html += '<div style="font-size:9pt" id="testResults">';

            $.each(d, function (i, v) {
                html += '<p>';
                
                if (v.IsMatch){
                    html += '<img style="height:9pt; display:inline-block; vertical-align:middle" src="./Content/Images/Icons/accept.png"/>';
                    html += '&nbsp;<span>Page ' + v.PageNumber + ' matched ' + v.Name + '"</span></p>';
                }
                else {
                    html += '<img style="height:9pt; display:inline-block; vertical-align:middle" src="./Content/Images/Icons/blocked.png"/>';
                    html += '&nbsp;<span>Page ' + v.PageNumber + ' did not match ' + v.Name + '"</span></p>';
                }

                html += '<div>';

                $.each(v.Patterns, function (ci, cv) {
                    html += '<div>';

                    if (cv.IsMatch)
                        html += '<img style="height:9pt; display:inline-block; vertical-align:middle" src="./Content/Images/Icons/accept.png"/>&nbsp;';
                    else
                        html += '<img style="height:9pt; display:inline-block; vertical-align:middle" src="./Content/Images/Icons/blocked.png"/>&nbsp;';

                    html += '<span class="pattern-type">' + cv.PatternType + '</span> pattern <span class="pattern-value">"' + cv.Pattern + '"</span>';
                    html += cv.IsMatch ? ' matched <span class="pattern-value">"' + cv.Match + '"</span>'
                                       : ' did not match anything';
                    html += '</div>';
                });

                html += '<br />';
                html += v.OptionalMatchPercentage + '% of optional patterns were matched';
                html += '</div>';
            });

            html += "</div>";
        }

        $('.adrtest.step3').html(html).show();
        $('#testResults').accordion({
            collapsible : true,
            header      : 'p',
            heightStyle : 'content'
        });
    };

    function onTestDefinitionsClick() {
        showTestDefinitionsDialog();
    };

    function showTestDefinitionsDialog() {
        $('#testFile').wrap('<form>').closest('form').get(0).reset();
        $('#testFile').unwrap();

        $('.adrtest.step3').hide();
        $('.adrtest.step2').hide();
        $('.adrtest.step1').show();

        $('#testDefinitionsModal').dialog({
            modal: true,
            title: 'AccuAccount',
            width: 720,
            height: 400,
            buttons: [
                {
                    text: 'Test',
                    click: onTestDefinitionsDialogCommitted
                },
                {
                    text: 'Cancel',
                    click: function () { $(this).dialog('close'); }
                }
            ]
        });
    };

    return publicApi;
});