//= require can.jquery-all
//= require pbc/response

(function(namespace, $) {

can.Control("CMS.Controllers.Responses", {
    defaults : {
        model : namespace.CMS.Models.Response
        , system_model : namespace.CMS.Models.System
        , object_person_model : namespace.CMS.Models.ObjectPerson
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
            can.Model.Cacheable.prototype.addElementToChildList.call(this.options.observer, "list", response);
        }
    }

});

})(this, can.$);