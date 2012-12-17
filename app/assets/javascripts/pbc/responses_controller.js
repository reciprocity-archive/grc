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
        this.options.model.findAll({ request_id : this.options.id }, this.proxy("draw_list"));
    }
    , draw_list : function(list) {
        if(list) {
            this.list = list;
        }
        this.element.html(can.view(this.options.list, this.options.observer = new can.Observe({list : this.list})));
    }
    , "{model} created" : function(Model, ev, response) {
        if(response.request_id === this.options.id) {  
            this.options.observer.attr("list", this.list = this.list.concat([response]));
        }
    }
});

})(this, can.$);