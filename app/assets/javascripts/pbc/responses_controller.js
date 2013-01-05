//= require can.jquery-all
//= require pbc/response

(function(namespace, $) {

function object_person_event(el, ev, data) {
    var that = this;
    this.create_object_relation(
        "person"
        , el.closest("[data-system-id]").data("system-id")
        , can.extend(data, {role : "responsible"})
        )
    .then(function() {
        el.find("form")[0].reset();
        that.restore_add_link(el, ev);        
    });
}

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
    , ".cancel-add-document click" : function(el, ev) {
        this.restore_add_link.call(this, el, ev);
    }
    , restore_add_link : function(el) {
        var $li = el.closest(".inline-add-person, .inline-add-document");

        $li.next(".toggle-add-person, .toggle-add-document").removeClass("hide");
        $li.addClass("hide");        
    }
    , ".inline-add-person personSelected" : object_person_event
    , ".inline-add-person modal:success" : object_person_event
    , create_object_relation : function(type, system_id, params) {
        var that = this
        , dfd;

        if(!params.id) {
            //need to create a new thing to relate to first
            var model = this.options[type + "_model"];
            dfd = new model(params).save();
        } else {
            //otherwise just use the existing one.
            dfd = new $.Deferred().resolve(params);
        }
        return dfd.pipe(function(pp){
            //second step is to create the relation.
            //This is a "pipe" callback so that the deferred waits for this
            //  deferred operation before resolving the other done callbacks.
            var object_model = that.options["object_" + type + "_model"];
            var obj = new object_model({
                system_id : system_id
                , role : params.role
            });
            obj.attr(type + "_id", pp.id);
            return obj.save()
        });
    }

    , ".add-document:not(.disabled) click" : function(el, ev) {
        var $form = el.closest("form")
        , $inputs = can.makeArray($form.get(0).elements)
        , params = {}
        , that = this;
        
        can.each($inputs, function(input){
            params[$(input).attr("name")] = $(input).val();
        });

        this.create_object_relation(
            "document"
            , el.closest("[data-system-id]").data("system-id")
            , params
            )
        .then(function(){
            $form[0].reset();
            $form.find(".cancel-add-document").click();
        });
    } 

    , ".inline-add-person keydown" : function(el, ev) {
        if(ev.which === $.ui.keyCode.ESCAPE) {
            this.restore_add_link(el);
        }
    }
    , ".edit-person-role change" : function(el, ev) {
        var role = el.val()
        , model = el.closest("[data-model]").data("model");

        model.attr("role", role);
        model.save();
    }

    , ".inline-add-document keydown" : function(el, ev) {
        if(el.find(".input-title").val() === ""
            || el.find(".input-role").val() === "") {
            el.find(".add-document").addClass("disabled").removeClass("btn-primary");
        } else {
            el.find(".add-document").removeClass("disabled").addClass("btn-primary");
        }
    }
    , ".inline-add-document change" : function(el, ev) {
        if(el.find(".input-title").val() === ""
            || el.find(".input-role").val() === "") {
            el.find(".add-document").addClass("disabled").removeClass("btn-primary");
        } else {
            el.find(".add-document").removeClass("disabled").addClass("btn-primary");
        }
    }
});

})(this, can.$);