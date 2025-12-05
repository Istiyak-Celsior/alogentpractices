var CoreLinkAdminViewModel = function ($, api, errorHandler, user, uiElements) {
    (function () {
        if (!uiElements) {
            throw "Argument 'uiElements' is null or undefined.";
        }
    })();

    var public = kendo.observable({
        errorHandler: errorHandler,
        errorMessage: "",
        hasErrors: false,
        load: undefined,
        onError: undefined,
        regularExpressions: new kendo.data.DataSource({ 
            sort: [
                { field: "IsDefault", dir: "desc" },
                { field: "IsEnabled", dir: "desc" }
            ],
            schema: {
                data: "Patterns",
                model: {
                    id: "Id",
                    fields: {
                        Id: {
                             type: "string"
                        },
                        Description: {
                            type: "string",
                            validation: {
                                required: false,
                                maxlength: function(input) {
                                    if (input.is("[name='Description']") && input.val().length > 128) {
                                        input.attr("data-maxlength-msg", "Description cannot exceed 64 characters.");
                                        return false;
                                    }
                                    return true;
                                }
                            }
                        },
                        Pattern: {
                            type: "string",
                            validation: {
                                required: true,
                                maxlength: function(input) {
                                    if (input.is("[name='Pattern']") && input.val().length > 256) {
                                        input.attr("data-maxlength-msg", "Pattern length cannot exceed 256 characters.");
                                        return false;
                                    }
                                    return true;
                                },
                                regularexpressionvalidation: function (input) {
                                    if (input.is("[name='Pattern']") && input.val() !== "") {
                                        var isValid = true;

                                        try {
                                            new RegExp(input.val());
                                        } catch (e) {
                                            isValid = false;
                                        }

                                        input.attr("data-regularexpressionvalidation-msg", "Pattern is not a valid regular expression.");

                                        return isValid;
                                    }
                                    return true;
                                }
                            }
                        },
                        Blacklist: {
                            type: "string",
                            maxlength: function(input) {
                                if (input.is("[name='Blacklist']") && input.val().length > 128) {
                                    input.attr("data-maxlength-msg", "Max # of exclusions cannot exceed 128 characters.");
                                    return false;
                                }
                                return true;
                            }
                        },
                        IsEnabled: { type: "boolean" },
                        IsDefault: { type: "boolean", editable: false }
                    }
                }
            },
            transport: {
                read: {
                    type: "GET",
                    datatype: "json",
                    contentType: "application/json",
                    url: "corelink/patterns"
                },
                update: {
                    type: "PUT",
                    datatype: "json",
                    contentType: "application/json",
                    url: "corelink/pattern"
                },
                create: {
                    type: "POST",
                    datatype: "json",
                    contentType: "application/json",
                    url: "corelink/pattern"
                },
                destroy: {
                    type: "DELETE",
                    url: function(item) {
                        return kendo.format("corelink/pattern?id={0}", item.Id);
                    }
                },
                parameterMap: function (data, type) {
                    if (type !== "read") {
                        return JSON.stringify(data);
                    }
                }
            },
            error: function (e) {
                public.errorHandler.error(e.xhr.responseJSON.ErrorMessage);                               
            },
            requestStart: function () {
                public.errorHandler.clear();
            }
        })
    });

    public.load = function () {
        api.error = public.onError;

        return $.Deferred().resolve().promise();
    };

    public.onCancel = function (e) {
        public.errorHandler.clear();
    };

    public.onEdit = function (e) {
        var that = this;

        public.errorHandler.clear();

        if (e.model.IsDefault) {
            that.trigger("editField", { container: e.container });
        }
    };

    public.onError = function (e) {
        public.errorHandler.error(e.errorMessage);
    };

    return public;
};