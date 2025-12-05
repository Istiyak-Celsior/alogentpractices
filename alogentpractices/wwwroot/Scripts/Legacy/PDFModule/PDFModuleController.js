var PDFModuleController = (function (service, $, undefined) {
    var publicApi =
    {
        isLoaded: false,
        historyTab : undefined
    };

    var dashboardTabController;
    var automaticPageRecognitionTabController;
    var conversionHistoryTabController;
    var conversionFailuresTabController;
    var settingsTabController;
    
    publicApi.load = function () {
        dashboardTabController                = new DashboardTabController(service);
        settingsTabController                 = new SettingsTabController(service);
        automaticPageRecognitionTabController = new AutomaticPageRecognitionTabController(service);
        conversionFailuresTabController       = new ConversionFailuresTabController(service);
        conversionHistoryTabController        = new ConversionHistoryTabController(service);
        
        dashboardTabController.load();

        $('.tab').click(function() {
             onTabClick($(this));
        });

        publicApi.historyTab = conversionHistoryTabController;
        publicApi.isLoaded = true;
    };

    function deselectTab(tab) {
        tab.removeClass('active');

        var tabPanel = getSelectedTabPanel();
        
        tabPanel.removeClass('active');
    };

    function getSelectedTab() {
        return $('.tab.active');
    };

    function getSelectedTabPanel() {
        return $('.tabpanel.active');
    };

    function getTabName(tab) {
        return tab.attr('name');
    };

    function getTabPanel(tab) {
        return $('.tabpanel[name=' + tab.attr('name') + 'Panel]');
    };

    function isTabSelected(tab) {
        return tab.hasClass('active');
    };

    function selectTab(tab) {
        if (tab.hasClass('active'))
            return;

        var tabPanel = getTabPanel(tab);

        tab.addClass('active');
        tabPanel.addClass('active');
    };

    function onTabClick(element) {
        if (isTabSelected(element))
            return;

        var selectedTab = getSelectedTab();

        deselectTab(selectedTab);
        selectTab(element);

        loadTab(getTabName(element));
    };

    function loadTab(tabName) {
        switch (tabName) {
            case 'settingsTab':
                if (!settingsTabController.isLoaded)
                    settingsTabController.load();
                break;
            case 'aprTab':
                if (!automaticPageRecognitionTabController.isLoaded)
                    automaticPageRecognitionTabController.load();
                break;
            case 'failureTab':
                if (!conversionFailuresTabController.isLoaded)
                    conversionFailuresTabController.load();
                break;
            case 'historyTab':
                if (!conversionHistoryTabController.isLoaded)
                    conversionHistoryTabController.load();
                $('#searchQuery').focus();
                break;
        }
    };

    return publicApi;
});