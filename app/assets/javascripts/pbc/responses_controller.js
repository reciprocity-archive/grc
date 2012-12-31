//= require can.jquery-all
//= require pbc/response

(function(namespace, $) {

can.Control("CMS.Controllers.Responses", {
    defaults : {
        model : namespace.CMS.Models.Response
        , system_model : namespace.CMS.Models.System
        , object_person_model : namespace.CMS.Models.ObjectPerson
        , person_model : namespace.CMS.Models.Person
        , object_document_model : namespace.CMS.Models.ObjectDocument
        , document_model : namespace.CMS.Models.Document
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
            this.element.closest(".main-item").find(".pbc-request-count").html(this.list.length + " " + (this.list.length - 1 ? "Responses" : "Response"));
        }
    }
    , "{model} destroyed" : function(Model, ev, response) {
        if(response.request_id === this.options.id) {  
            can.Model.Cacheable.prototype.removeElementFromChildList.call(this.options.observer, "list", response);
            this.element.closest(".main-item").find(".pbc-request-count").html(this.list.length + " " + (this.list.length - 1 ? "Responses" : "Response"));
        }
    }
    , ".remove_person, .remove_document click" : function(el, ev) {
        el.closest("[data-model]").data("model").destroy();
    }
    , ".toggle-add-person click" : function(el, ev) {
        el.prev(".inline-add-person").removeClass("hide").find(".input-ldap").focus();
        el.addClass("hide");
    }
    , ".toggle-add-document click" : function(el, ev) {
        el.prev(".inline-add-document").removeClass("hide").find(".input-title").focus();
        el.addClass("hide");
    }
    , ".cancel-add-person, .cancel-add-document click" : function(el, ev) {
        var $li = el.closest(".inline-add-person, .inline-add-document");

        $li.next(".toggle-add-person, .toggle-add-document").removeClass("hide");
        $li.addClass("hide");
    }
    , ".add-person:not(.disabled), .add-document:not(.disabled) click" : function(el, ev) {
        var $form = el.closest("form")
        , $inputs = can.makeArray($form.get(0).elements)
        , params = {}
        , that = this;
        
        can.each($inputs, function(input){
            params[$(input).attr("name")] = $(input).val();
        });

        var dfd;
        if(!params.id) {
            var model = el.is(".add-document") ? this.options.document_model : this.options.person_model;
            dfd = new model(params).save();
        } else {
            dfd = new $.Deferred().resolve(params);
        }
        dfd.then(function(pp){
            var object_model = el.is(".add-document") ? that.options.object_document_model : that.options.object_person_model;
            var obj = new object_model({
                system_id : el.closest("[data-system-id]").data("system-id")
                , role : params.role
            });
            obj.attr(el.is(".add-document") ? "document_id" : "person_id", pp.id);
            obj.save()
            .then(function(){
                $form[0].reset();
                $form.find(".cancel-add-person, .cancel-add-document").click();
            });
        });
    } 
    //validations -- lets replace this with a plugin later.
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
    , ".inline-add-document keydown" : function(el, ev) {
        if(el.find(".input-title").val() === ""
            || el.find(".input-role").val() === "") {
            el.find(".add-document").addClass("disabled");
        } else {
            el.find(".add-document").removeClass("disabled");
        }
    }
    , ".inline-add-document change" : function(el, ev) {
        if(el.find(".input-title").val() === ""
            || el.find(".input-role").val() === "") {
            el.find(".add-document").addClass("disabled");
        } else {
            el.find(".add-document").removeClass("disabled");
        }
    }
});

})(this, can.$);