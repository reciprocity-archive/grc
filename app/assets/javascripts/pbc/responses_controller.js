//= require can.jquery-all
//= require pbc/response

(function(namespace, $) {

can.Control("CMS.Controllers.Responses", {
    defaults : {
        model : namespace.CMS.Models.Response
        , list : "/pbc/responses_list.mustache"
        , id : null //The ID of the parent request
    }
}, {
    init : function() {
        this.fetch_list();
    }
    , fetch_list : function() {
        this.options.model.findAll({ id : this.options.id }, this.proxy("draw_list"));
    }
    , draw_list : function(list) {
        if(list) {
            this.list = list;
        }
        this.element.html(can.view(this.options.list, new can.Observe({list : this.list})));
    }
});

})(this, can.$);