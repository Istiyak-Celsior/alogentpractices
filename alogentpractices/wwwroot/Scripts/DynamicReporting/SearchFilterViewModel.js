var SearchFilterViewModel = (function ($, undefined) {
    return ViewModel.extend({
        init: function (name, field, type) {
            ViewModel.fn.init.call(this);

            this.field     = field;
            this.fieldType = type;
            this.name      = name;

            this.value     = this.getDefaultValue(type);
            this.operators = this.getOperators(type);
            this.operator  = this.getDefaultOperator(type);
        },
        field: undefined,
        fieldType: undefined,
        getDefaultOperator: function (fieldType) {
            switch (fieldType) {
                case "Text":
                    return "Contains";
                default:
                    return "=";
            }
        },
        getDefaultValue: function (fieldType) {
            switch (fieldType) {
                case "True/False":
                    return "True";
                default:
                    return null;
            }
        },
        getOperators: function (fieldType) {
            switch (fieldType) {
                case "True/False":
                    return ["="];
                case "Text":
                    return ["Starts With", "Contains", "Ends With", "="];
                default:
                    return ["<", "<=", "=", ">", ">="];
            }
        },
        name: undefined,
        operator: undefined,
        operators: undefined,
        type: "Search",
        value: undefined
    });
})(window.kendo.jQuery);