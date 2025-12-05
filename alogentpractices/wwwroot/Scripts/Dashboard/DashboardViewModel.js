var DashboardViewModel = ViewModel.extend({
    init: function(name, id) {      
        ViewModel.fn.init.call(this);  
        this.setName(name);

        if (id) {
            this.set("id", id);
        }
    },
    id: null,
    name: null,
    currentName: null,
    _isNew: false,
    setName: function(name) {
        this.set("name", name);
        this.set("currentName", name);
    }
});