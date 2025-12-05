var ErrorHandler = kendo.Class.extend({
    init: function () {},
    error: function (error) {
        console.log(error.errorMessage);
    },
    success: function () {
    },
    warning: function () {
    }
});