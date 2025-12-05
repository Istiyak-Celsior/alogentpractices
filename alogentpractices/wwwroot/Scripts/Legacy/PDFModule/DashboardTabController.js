var DashboardTabController = (function(service) {
    var publicApi =
    {
        isLoaded : false    
    };

    function getChartColor(fileType) {
        var colorTable = [['.csv', 'green'],
                          ['.doc', 'blue'],
                          ['.docx', 'blue'],
                          ['.jpg', '#f7b518'],
                          ['.jepg', '#f7b518'],
                          ['.tif', '#00aea4'],
                          ['.tiff', '#00aea4'],
                          ['.pdf', '#dc5a5a'],
                          ['.xls', '#6ba34a'],
                          ['.xlsx', '#6ba34a']];

        var retVal = 'grey';

        $.each(colorTable, function (index, value) {
            var x = value[0].toLowerCase();
            var y = fileType.toLowerCase();

            if (x == y) {
                retVal = value[1];
                return false;
            }
        });

        return retVal;
    };



    function initializeDocumentCountByCustomerTypeChart(items) {
        var _labels = [];
        var _data = [];

        $.each(items, function (k, v) {
            _labels.push(v.GroupName);
            _data.push(v.Count);
        });
        var dataSet = {
            labels: _labels,
            datasets: [
            {
                label: 'Customer Type',
                fillColor: 'rgba(121,199,91,0.5)',
                strokeColor: 'rgba(121,199,91,0.8)',
                highlightFill: 'rgba(121,199,91,0.75)',
                highlightStroke: 'rgba(121,199,91,1)',
                data: _data
            }]
        };
        var ctx = document.getElementById('customerTypeChart').getContext('2d');
        var chart = new Chart(ctx).Bar(dataSet, {
            scaleFontSize: 9
        });
    };

    function initializeDocumentCountByAccountTypeChart(items) {
        var _labels = [];
        var _data = [];

        $.each(items, function (k, v) {
            _labels.push(v.GroupName);
            _data.push(v.Count);
        });
        var dataSet = {
            labels: _labels,
            datasets: [
            {
                label: 'Account Type',
                fillColor: 'rgba(107,187,222,0.5)',
                strokeColor: 'rgba(107,187,222,0.8)',
                highlightFill: 'rgba(107,187,222,0.75)',
                highlightStroke: 'rgba(107,187,222,1)',
                data: _data
            }]
        };
        var ctx = document.getElementById('accountTypeChart').getContext('2d');
        var chart = new Chart(ctx).Bar(dataSet, {
            scaleFontSize: 9
        });
    };

    function initializeDocumentCountByFileTypeChart(data) {
        var ctx = document.getElementById('typeCountChart').getContext('2d');
        var chartData = [];
        var legend = '';
        var light = .8;
        var lightIncrement = 1 / data.length;

        $.each(data, function (index, value) {
            legend += '<span class="bullet" style="background-color:' + getChartColor(value.GroupName) + '"></span> <span>' + value.GroupName + ' (' + value.Count + ')</span>&nbsp;&nbsp;';
            chartData.push({
                value: value.Count,
                color: getChartColor(value.GroupName),
                highlight: 'slategrey',
                label: value.GroupName
            });
            light -= lightIncrement;
        });

        $('#filetypes-card .card-legend').html(legend);

        var pieChart = new Chart(ctx).Doughnut(chartData, {
            segmentShowStroke: false
        });
    };

    function initializeWorkCompletedChart(data) {
        var pdfCount = 0;
        var tifCount = 0;

        $.each(data, function (index, value) {
            var ext = value.GroupName.toLowerCase();

            if (ext == '.tif' || ext == '.tiff')
                tifCount += value.Count;

            if (ext == '.pdf')
                pdfCount += value.Count;
        });

        var progress = Math.round((pdfCount / (tifCount + pdfCount) * 100));

        $('#workCount').text(progress + '%');

        if (progress >= 80)
            $('#workCount').css('color', 'rgb(73, 177, 73)');

        if (progress < 80 && progress >= 40)
            $('#workCount').css('color', 'gold');

        if (progress < 40)
            $('#workCount').css('color', 'grey');

        $('#workProgress').progressbar({
            value: progress
        });
        $('#workValue').text(pdfCount);
        $('#workMax').text(tifCount + pdfCount);
    };

    function initializeEstimatedCompletionDateChart(completionDate, average, daysLeft) {
        if (completionDate == null) {
            $('#estimatedCompletionDate').text('-');
        }
        else {
            $('#estimatedCompletionDate').text(completionDate);
        }

        $('#daysOfWorkLeft').text(average);
        $('#averageWorkPerDay').text(daysLeft);
    };

    function initializeHistoryChart(convertedData, errorData) {
        var ctx = document.getElementById("historyChart").getContext("2d");

        var labels = [];
        var series1Data = [];
        var errors = 0;
        var converted = 0;

        $.each(convertedData, function (index, value) {
            labels.push(value.GroupName);
            series1Data.push(value.Count);
            converted += value.Count;
        });

        var series2Data = [];

        $.each(errorData, function (index, value) {
            series2Data.push(value.Count);
            errors += value.Count;
        });

        $('#history-card-converted').text('# converted (' + converted + ')');
        $('#history-card-errors').text('# errors (' + errors + ')');

        var chartData = {
            labels: labels,
            datasets: [
                {
                    label: "# converted",
                    fillColor: "rgba(148,210,124,.5)",
                    strokeColor: "rgba(148,210,124,.75)",
                    pointColor: "rgba(148,210,124,1)",
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(220,220,220,1)",
                    data: series1Data
                },
                {
                    label: "# errors",
                    fillColor: "rgba(192,46,46,.5)",
                    strokeColor: "rgba(192,46,46,.5)",
                    pointColor: "rgba(192,46,46,.85)",
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(220,220,220,1)",
                    data: series2Data
                }
            ]
        };

        var chart = new Chart(ctx).Line(chartData, {
            scaleBeginAtZero: true,
            scaleFontSize: 9,
            tooltipFontSize: 11,
            datasetFill: false,
            pointDotStrokeWidth: 2
        });
    };

    function initializeEstimatedCompletionDateCard() {
        service.getEstimatedCompletionTimeframe(function (data) {
            $('#estimations-card').fadeIn(750);
            initializeEstimatedCompletionDateChart(data.EstimatedCompletionDate, data.DaysOfWorkLeft, data.AverageWorkPerDay);
            $('#dashboard-spinner').hide();
        });
    };

    function initializeWorkCompletedCard() {
        service.getDocumentCountByFileType(function (data) {
            $('#workcompleted-card').delay(1500).fadeIn(750);
            initializeWorkCompletedChart(data);
        });
    };

    function initializeDocumentCountByFileTypeCard() {
        service.getDocumentCountByFileType(function (data) {
            $('#filetypes-card').delay(500).fadeIn(750);
            initializeDocumentCountByFileTypeChart(data);
        });
    };

    function initializeDocumentCountByCustomerTypeCard() {
        service.getDocumentCountByCustomerType(function (data) {
            $('#workbycustomertype-card').delay(2000).fadeIn(750);
            initializeDocumentCountByCustomerTypeChart(data);
        });
    };

    function initializeDocumentCountByAccountTypeCard() {
        service.getDocumentCountByAccountType(function (data) {
            $('#workbyaccounttype-card').delay(2500).fadeIn(750);
            initializeDocumentCountByAccountTypeChart(data);
        });
    };

    function initializeHistoryCard() {
        service.getDocumentCountHistory(true, function (convertedData) {
            service.getDocumentCountHistory(false, function (errorData) {
                $('#history-card').delay(1000).fadeIn(750);
                initializeHistoryChart(convertedData, errorData);
            });
        });

        $('.documentGroup').click(function () {
            var id = $(this).id;

            $('.documentRow-{id}').show();
        });
    };

    function initializeDashboardCards() {
        $('.card-container').sortable({
            helper: 'clone'
        });

        $('.card-container').disableSelection();

        initializeEstimatedCompletionDateCard();
        initializeWorkCompletedCard();
        initializeDocumentCountByFileTypeCard();
        initializeDocumentCountByCustomerTypeCard();
        initializeDocumentCountByAccountTypeCard();
        initializeHistoryCard();
    };

    publicApi.load = function() {
        initializeDashboardCards();
        publicApi.isLoaded = true;
    };

    return publicApi;
});