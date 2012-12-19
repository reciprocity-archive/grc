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
        , type_id : null // type_id from request
        , type_name : null // type_name from request
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
        this.element.html(can.view(this.options.list, this.options.observer = new can.Observe({list : this.list, type_id : this.options.type_id, type_name : this.options.type_name})));
    }
    , "{model} created" : function(Model, ev, response) {
        if(response.request_id === this.options.id) {  
            can.Model.Cacheable.prototype.addElementToChildList.call(this.options.observer, "list", response);
        }
    }
    , ".remove_person click" : function(el, ev) {
        el.closest("[data-model]").data("model").destroy();
    }
    , ".remove_document click" : function(el, ev) {
        el.closest("[data-model]").data("model").destroy();
    }
    , ".toggle-add-person click" : function(el, ev) {
        el.prev(".inline-add-person").removeClass("hide").find(".input-ldap").focus();
        el.addClass("hide");
    }
    , ".cancel-add-person click" : function(el, ev) {
        var $li = el.closest(".inline-add-person");

        $li.next(".toggle-add-person").removeClass("hide");
        $li.addClass("hide");
    }
    , ".add-person:not(.disabled) click" : function(el, ev) {
        var $form = el.closest("form")
        , $inputs = can.makeArray($form.get(0).elements)
        , params = {};
        
        can.each($inputs, function(input){
            params[$(input).attr("name")] = $(input).val();
        });

        var dfd;
        if(!params.id) {
            dfd = new CMS.Models.Person(params).save();
        } else {
            dfd = new $.Deferred().resolve(params);
        }
        dfd.then(function(pp){
            new CMS.Models.ObjectPerson({
                person_id : pp.id
                , system_id : el.closest("[data-system-id]").data("system-id")
                , role : params.role
            })
            .save()
            .then(function(){
                $form[0].reset();
                $form.find(".cancel-add-person").click();
            });
        });
    } 
    , ".inline-add-person keydown" : function(el, ev) {
        if(el.find(".input-ldap").val() === ""
            || el.find(".input-role").val() === "") {
            el.find(".add-person").addClass("disabled");
        } else {
            el.find(".add-person").removeClass("disabled");
        }
    }
    , ".inline-add-person change" : function(el, ev) {
        if(el.find(".input-ldap").val() === ""
            || el.find(".input-role").val() === "") {
            el.find(".add-person").addClass("disabled");
        } else {
            el.find(".add-person").removeClass("disabled");
        }
    }
});

})(this, can.$);