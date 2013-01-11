//= require can.jquery-all
//= require pbc/response

(function(namespace, $) {

function object_event(type) {
    return function(el, ev, data) {
        var that = this;
        this.create_object_relation(
            type
            , el.closest("[data-model]").data("model")
            , can.extend(data, { role : type==="person" ? "responsible" : "general" } )
            )
        .then(function() {
            el.find("form")[0].reset();
            that.restore_add_link(el, ev);        
        });
    }
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
        var that = this;
        if(list) {
            this.list = list;
        }

        can.view(
            this.options.list
            , this.options.observer = new can.Observe({
                list : this.list
                , type_id : this.options.type_id
                , type_name : this.options.type_name})
            , function(frag) {
                that.element.html(frag);
            });
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
    , ".toggle-add-person:not(.disabled) click" : function(el, ev) {
        el.prev(".inline-add-person").removeClass("hide").find(".input-ldap").focus();
        el.addClass("hide");
    }
    , ".toggle-add-document:not(.disabled) click" : function(el, ev) {
        el.prev(".inline-add-document").removeClass("hide").find(".input-title").focus();
        el.addClass("hide");
    }
    , ".toggle-add-meeting:not(.disabled) click" : function(el, ev) {
        el.prev(".inline-add-meeting").removeClass("hide");
        el.addClass("hide");
    }
    , ".toggle-edit-population-doc click" : function(el, ev) {
        el.closest(".pbc-item").next(".inline-edit-population-doc").removeClass("hide").find(".input-title").focus();
        el.closest(".pbc-item").addClass("hide");
    }
    , restore_add_link : function(el) {
        var $li = el.closest(".inline-add-person, .inline-add-document, .inline-edit-population-doc");

        $li.next(".toggle-add-person, .toggle-add-document").removeClass("hide");
        $li.prev(".pbc-item").removeClass("hide");
        $li.addClass("hide");        
    }
    , ".inline-add-person personSelected" : object_event("person")
    , ".inline-add-person modal:success" : object_event("person")
    , ".inline-add-document documentSelected" : object_event("document")
    , ".inline-add-document modal:success" : object_event("document")
    , ".inline-edit-population-doc documentSelected" : function(el, ev, data) {
      var model = el.closest("[data-model]").data("model")

      model.attr(el.data("doc-type") + "_document_id", data.id)
      model.attr(el.data("doc-type") + "_document").attr(data);
      model.save().then(this.proxy('restore_add_link', el)).then(function() { el.find('form')[0].reset(); });
    }
    , ".inline-edit-population-doc modal:success" : function(el, ev, data) {
      var model = el.closest("[data-model]").data("model")

      model.attr(el.data("doc-type") + "_document_id", data.id)
      model.attr(el.data("doc-type") + "_document").attr(data);
      model.save().then(this.proxy('restore_add_link', el)).then(function() { el.find('form')[0].reset(); });
    }
    , ".save-population, .save-samples click" : function(el, ev) {
      ev.preventDefault();
    }    
    , ".save-population:not(.disabled), .save-samples:not(.disabled) click" : function(el, ev) {
      var model = el.closest("[data-model]").data("model")
      model.attr(el.closest(".sample-widget").find("input").attr("name"), el.closest(".sample-widget").find("input").val());
      model.save().then(function() { el.text("Saved").addClass("disabled"); });      
    }
    , "input[name=population], input[name=samples] keydown" : function(el, ev) {
      el.closest(".sample-widget").find(".save-population, .save-samples").text("Save").removeClass("disabled");
    }
    , ".add-meeting modal:success" : function(el, ev, data) {
      el.closest("[data-model]").data("model").addElementToChildList("meetings", new can.Observe(data));
    } 
    , create_object_relation : function(type, xable, params) {
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
                xable_id : xable.id
                , xable_type : xable instanceof CMS.Models.Response ? "Response" : "System"
                , role : params.role
            });
            obj.attr(type + "_id", pp.id);
            return obj.save()
        });
    }

    , ".inline-add-person, .inline-add-document keydown" : function(el, ev) {
        if(ev.which === $.ui.keyCode.ESCAPE) {
            this.restore_add_link(el);
        }
    }
    , ".edit-person-role, .edit-document-role change" : function(el, ev) {
        var role = el.val()
        , model = el.closest("[data-model]").data("model");

        model.attr("role", role);
        model.save();
    }
});

})(this, can.$);