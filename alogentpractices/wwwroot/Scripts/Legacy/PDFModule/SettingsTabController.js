var SettingsTabController = (function(service) {
    var publicApi =
    {
        isLoaded: false
    };

    var dto = null;

    function initializeSettings() {
        service.getSettings(function (settings) {
            dto = settings;

            var startTime = parseTime(settings.StartTime);
            var endTime = parseTime(settings.EndTime);

            $('select[name=start_hh]').val(startTime.hh);
            $('select[name=start_mm]').val(startTime.mm);
            $('select[name=start_tt]').val(startTime.tt);
            $('select[name=end_hh]').val(endTime.hh);
            $('select[name=end_mm]').val(endTime.mm);
            $('select[name=end_tt]').val(endTime.tt);
            $('input[name=backupDirectory').val(settings.BackupDirectory);

            $.each(settings.ServiceDays, function (k, v) {
                $("input[name$='serviceDay" + v + "']").attr('checked', 'checked');
            });

            $("input[name$='isActive']").prop('checked', settings.IsActive);

            $('input[name=runOnTimeframe]').filter('[value="' + settings.RunOnTimeframe + '"]').prop('checked', true);
            $('input[name=runOnTimeframe]').filter('[value="' + settings.RunOnTimeframe + '"]').change();

            $("input[name=isBackupEnabled]").filter('[value="' + settings.IsBackupEnabled + '"]').prop('checked', true);
            $("input[name=isBackupEnabled]").filter('[value="' + settings.IsBackupEnabled + '"]').change();

            $('input[name=isConversionEnabled]').prop('checked', settings.IsConversionEnabled);
            $('input[name=isAutomaticPageRecognitionEnabled').prop('checked', settings.IsAutomaticPageRecognitionEnabled);
            $('input[name=isSearchableTextEnabled').prop('checked', settings.IsSearchableTextEnabled);
        });
    };

    function onSaveButtonClick() {
        dto.IsActive = $('input[name=isActive]').is(':checked');
        dto.IsBackupEnabled = $('input[id=isBackupEnabledYes]').is(':checked');
        dto.IsConversionEnabled = $('input[name=isConversionEnabled]').is(':checked');
        dto.IsAutomaticPageRecognitionEnabled = $('input[name=isAutomaticPageRecognitionEnabled]').is(':checked');
        dto.IsSearchableTextEnabled = $('input[name=isSearchableTextEnabled]').is(':checked');
        dto.RunOnTimeframe = $('input[id=runOnTimeframeYes]').is(':checked');
        dto.StartTime = $('select[name=start_hh]').val() + ':' + $('select[name=start_mm]').val() + ' ' + $('select[name=start_tt]').val();
        dto.EndTime = $('select[name=end_hh]').val() + ':' + $('select[name=end_mm]').val() + ' ' + $('select[name=end_tt]').val();
        dto.BackupDirectory = $('input[name=backupDirectory]').val();
        dto.ServiceDays = getServiceDaysArray();

        service.saveSettings(dto, function () {
            $('#saveModal').text('Your settings have been saved and will take effect immediately.');
            $('#saveModal').dialog({
                modal: true,
                title: 'AccuAccount',
                width: 640,
                buttons: [
                {
                    text: 'OK',
                    click: function () { $(this).dialog('close'); }
                }]
            });
        });
    };

    function onBackupDirectoryChanged(selector) {
        var value = selector.val();

        if (value == '')
            selector.css('background-color', 'rgb(255, 208, 202)');
        else
            selector.css('background-color', 'inherit');
    };

    function onIsBackupEnabledChanged(selector) {
        var value = selector.val();

        if (value == "true") {
            $('#backupDirectory').show();
        }
        else {
            $('#backupDirectory').hide();
        }
    };

    function onRunOnTimeframeChanged(selector) {
        var value = selector.val();

        if (value == "true") {
            $('#starttime').show();
            $('#endtime').show();
        }
        else {
            $('#starttime').hide();
            $('#endtime').hide();
        }
    };

    function parseTime(time) {
        var hh = time.substring(0, time.indexOf(':'));
        var mm = time.substring(time.indexOf(':') + 1, time.indexOf(' '));
        var tt = time.substring(time.indexOf(' ') + 1);

        return { 'hh': hh, 'mm': mm, 'tt': tt };
    };

    function getServiceDaysArray() {
        var serviceDays = [];

        if ($('input[name=serviceDaySunday]').prop('checked'))
            serviceDays.push('Sunday');

        if ($('input[name=serviceDayMonday]').prop('checked'))
            serviceDays.push('Monday');

        if ($('input[name=serviceDayTuesday]').prop('checked'))
            serviceDays.push('Tuesday');

        if ($('input[name=serviceDayWednesday]').prop('checked'))
            serviceDays.push('Wednesday');

        if ($('input[name=serviceDayThursday]').prop('checked'))
            serviceDays.push('Thursday');

        if ($('input[name=serviceDayFriday]').prop('checked'))
            serviceDays.push('Friday');

        if ($('input[name=serviceDaySaturday]').prop('checked'))
            serviceDays.push('Saturday');

        return serviceDays;
    };

    publicApi.load = function() {
        initializeSettings();

        $("input[name=isBackupEnabled]").on('change', function () { onIsBackupEnabledChanged($(this)); });
        $('input[name=backupDirectory').on('input propertychange paste', function () { onBackupDirectoryChanged($(this)); });
        $('input[name=runOnTimeframe]').on('change', function () { onRunOnTimeframeChanged($(this)); });
        $('#save-button').click(function () { onSaveButtonClick(); });

        publicApi.isLoaded = true;
    };

    return publicApi;
});