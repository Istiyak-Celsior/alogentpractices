var LicenseService = (function(api) {
    var public = {
        init: undefined,
        updateCustomerNumber: undefined
    };

    public.init = function() {
        return api.get({
            area: "",
		    controller: "LicenseAdmin",
		    action: "Init"
	    });
    };

	return public;
});