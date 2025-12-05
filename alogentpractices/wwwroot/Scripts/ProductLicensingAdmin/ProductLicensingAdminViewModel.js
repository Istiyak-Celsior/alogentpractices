var ProductLicensingAdminViewModel = function ($, licenseService, offlineErrorHandler, errorHandler, uiElements) {
    (function () {
        if (!uiElements) {
            throw "Argument 'uiElements' is null or undefined.";
        }
    })();

    var public = kendo.observable({
        customerName: "",
        customerId: "",
        key: "",
        offlineErrorHandler: offlineErrorHandler,
        errorHandler: errorHandler,
        errorMessage: "",
        hasErrors: false,
        isLicensed: false,
        isOnline: false,
        licenseData: new kendo.data.DataSource({
            transport: {
                read: {
                    url: "LicenseAdmin/Licenses",
                    dataType: "json",
                    cache: false
                }
            },
            schema: {
                data: function (data) {
                    $.each(data,
                        function (index, item) {
                            item["Key"] = item.Key.toUpperCase();
                        });

                    return data;
                },
                model: {
                    id: "Id",
                    fields: {
                        Id: { editable: false, nullable: false },
                        Key: { editable: true, type: "string" },
                        Product: { editable: false },
                        Type: { editable: false },
                        Limit: { editable: false },
                        InUse: { editable: false },
                        DateCreated: { editable: false, type: "date" },
                        DateLastOnline: {editable:false, type: "date"},
                        DaysOffline: { editable: false, type: "number" },
                        DaysOfflineAllowed: { editable: false, type: "number" },
                        Status:  { editable: false }
                    }
                }
            },
            error: function (e) {
                public.errorHandler.clear();
	            public.errorHandler.error(e.xhr.responseJSON.ErrorMessage);
            }
        }),
        licenseService: licenseService,
        load: undefined,
        onError: undefined,
        updateUri: ""
    });

    public.load = function () {
	    var request = licenseService.init();

        request.done(function (e) {
	        public.set("customerName", e.CustomerName);
	        public.set("customerNumber", e.CustomerNumber !== "" ? e.CustomerNumber : "-");
            public.set("key", e.Key !== "" ? e.Key : "-");
            public.set("isLicensed", e.IsLicenseAvailable);
            public.set("isOnline", e.IsOnline);
            public.set("updateUri", e.UpdateUri);

            if (!e.IsOnline) {
	            public.offlineErrorHandler.warning("Restore connectivity to " + public.get("updateUri") + " to prevent your license information from being at risk of expiring. If you believe you are seeing this message in error, or you believe there might be a service outage, please contact Alogent.");
            }
        });
     
        return $.when(request);
    };

    return public;
};