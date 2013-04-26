//= require can.jquery-all
//= require pbc/response

(function(namespace, $) {

function object_event(type) {
    return function(el, ev, data) {
        var that = this;

        this.bindXHRToButton(
          this.create_object_relation(
              type
              , el.closest("[data-model]").data("model")
              , can.extend(data, { role : type==="person" ? "responsible" : "general" } )
              )
          .then(function() {
              el.find("form")[0].reset();
              that.restore_add_link(el, ev);        
          })
          , el);
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
        , list : "/assets/pbc/responses_list.mustache"
        , id : null //The ID of the parent request
        , type_id : null // type_id from request
        , type_name : null // type_name from request
        , display_prefs : null
        , page_id : null
    }
    , one_created : can.compute(false)
}, {
    init : function() {
        this.fetch_list();
        var that = this;
        if(!this.options.display_prefs) {
          CMS.Models.DisplayPrefs.findAll().done(function(prefs) {
            that.options.display_prefs = prefs[0];
          })
        }
    }
    , fetch_list : function() {
        this.options.model.findAll({ request_id : this.options.id, r : Math.random() }, this.proxy("draw_list"));
    }
    , draw_list : function(list) {
        var that = this;
        if(list) {
            this.list = list;
        }

        //Here we start by adding a dummy system while rendering the initial responses.
        //  this is because CanJS is buggy and won't live-bind against a null value, but only 
        //  when it happens during the initial viewing.  If we went back and live-added another response
        //  with a null value for system, it would work.  --BM 3/4/2013
        can.each(this.list, function(resp) {
          if(!resp.system) {
            resp.attr("system", {});
          }
        });
        can.view(
            this.options.list
            , this.options.observer = new can.Observe({
                list : this.list
                , request_id : this.options.id
                , type_id : this.options.type_id
                , type_name : this.options.type_name
                , one_created : this.constructor.one_created})
            , function(frag) {
                that.element.html(frag);
                //Here we unset that dummy value, so the lack of system displays correctly. --BM
                can.each(that.list, function(resp) {
                  if(can.isEmptyObject(resp.system.serialize())) {
                    resp.attr("system", null);
                  }
                  if(that.options.display_prefs.getPbcResponseOpen(that.options.page_id, resp.id) === false) {
                    that.element.find(".item[data-id=" + resp.id + "] > .item-main > .openclose").openclose("close");
                  }

                });
            });
    }
    , "{model} created" : function(Model, ev, response) {
        if(response.request_id === this.options.id) {  
            this.options.observer.list.unshift(response);
            this.element.closest(".main-item").find(".pbc-request-count").html(this.list.length + " " + (this.list.length - 1 ? "Responses" : "Response"));
            $(".pbc-responses > .item[data-id=" + response.id + "] .openclose").openclose("open").height();
            setTimeout(function() {
              var $body = $(document.body)
              , $item = $(".pbc-responses > .item[data-id=" + response.id + "]")
              if(-$body.scrollTop() + $item.height() + $item.offset().top > $(window).height()) {
                $body.scrollTop($item.offset().top - $(window).height() + $item.height());
              }
            }, 200);
            this.constructor.one_created(true);
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
      var $alert = $(el).closest(".items").find(".alert");
      if(!$alert.length)
        return;
      $alert.show().addClass("in");
      setTimeout(function() {
        $alert.removeClass("in");
        setTimeout(function() {
          $alert.hide();
        }, 500);
      }, 3000);
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
    // don't submit forms on enter from inline search boxes
    , "form keydown" : function(el, ev) {
      if(ev.which === 13) {
        ev.preventDefault();
      }
    }
    , ".inline-add-person personSelected" : function(el, ev, data) {
      if(!data.id) {
        el.find(".add-person").click();
        $(".modal:visible").one("loaded", function() {
          can.each(Object.keys(data), function(key) {
            $("#person_" + key).val(data[key]);
          });
        });
      } else {
        object_event("person").apply(this, arguments);
      }
    }
    , ".inline-add-person modal:success" : object_event("person")
    , ".inline-add-document documentSelected" : function(el, ev, data) {

      if(!data.id && !/^http[:s]|^file:/i.test(data.link_url)) {
        data.title = data.link_url;
        data.link_url = null;
        // Person gave a new title.  Have to open the modal to supply a URL.
        el.find(".add-document").click();
        $(".modal:visible").one("loaded", function() {
          can.each(Object.keys(data), function(key) {
            $("#document_" + key).val(data[key]);
          });
        });
      } else {
        object_event("document").apply(this, arguments);
      }
    }
    , ".inline-add-document modal:success" : object_event("document")
    , ".inline-edit-population-doc .input-title documentSelected" : function(el, ev, data) {
      var model = el.closest("[data-model]").data("model")
      var that = this;
      var dfd = new can.Deferred();

      if(!data.id) {
        if(!/^http[:s]|^file:/i.test(data.link_url)) {
          data.title = data.link_url;
          data.link_url = null;

          el.closest(".inline-edit-population-doc")
          .find(".add-document")
          .click()
          .one("modal:success", function(ev, data) {
            dfd.resolve(data);
          });
          $(".modal:visible").one("loaded", function() {
            can.each(Object.keys(data), function(key) {
              $("#document_" + key).val(data[key]);
            });

          });
        }
        else {
          //need to create a new thing to relate to first
          dfd = new this.options.document_model(data).save();
          that.bindXHRToButton(
            dfd
           , el);
        }
      } else {
        dfd.resolve({id : data.id})
      }

      dfd.done(function(data) {
        model.attr(el.closest("[data-doc-type]").data("doc-type") + "_document_id", data.id)
        that.bindXHRToButton(
          model.save()
          , el);
      });
    }
    , immediate_reference_link : function(el, ev, data) {
      var $input = el.find(".input-title");
      var that = this;
      setTimeout(function() {
        $input.prop("disabled", true);
        that.options.document_model.search({ term : $input.val() }, function(d) {
          var params = { link_url : $input.val() };
          if(d.length) {
            params = d[0];
          }
          el.is(".inline-add-document")
          ? that.proxy(object_event("document"))(el, ev, params)
          : $input.trigger("documentSelected", params);
        })
        .always(function(){
          $input.prop("disabled", false);
        })
      }, 100);
    }
    , ".inline-add-document, .inline-edit-population-doc paste" : "immediate_reference_link"
    , ".inline-add-document, .inline-edit-population-doc drop" : "immediate_reference_link"

    , ".inline-edit-population-doc .input-title keydown" : function(el, ev) {
        if(ev.which === $.ui.keyCode.ESCAPE) {
            el.val('').blur();
        }
    }
    // population samples events
    , ".toggle-edit-population-doc click" : function(el, ev) {
        el.closest(".pbc-item").next(".inline-edit-population-doc").removeClass("hide").find(".input-title").focus();
        el.closest(".pbc-item").addClass("hide");
    }
    , ".inline-edit-population-doc modal:success" : function(el, ev, data) {
      var model = el.closest("[data-model]").data("model")

      model.attr(el.data("doc-type") + "_document_id", data.id)
      this.bindXHRToButton(
        model.save()
        , el);
    }
    , ".save-population, .save-samples click" : function(el, ev) {
      ev.preventDefault();
    }    
    , "input[name=population], input[name=samples] keyup" : function(el, ev) {
    //, ".save-population:not(.disabled), .save-samples:not(.disabled) click" : function(el, ev) {
      var model = el.closest("[data-model]").data("model")
      , that = this;
      model.attr(el.attr("name"), el.val());
      if(that.samples_timeout) {
        clearTimeout(that.samples_timeout);
      }
      that.samples_timeout = setTimeout(function() {
        that.bindXHRToButton(
          model.save().then(function() { 
            //success condition
            el.next(".success").text("Saved").addClass("in");
            el.parent().removeClass("field-failure");
            setTimeout(function() {
              el.next(".success").removeClass("in");
            }, 3000);
          }, function(xhr) {
            //error condition
            var t = "Error", r = JSON.parse(xhr.responseText);
            if(~can.inArray("is not a number", r.errors[el.attr("name")])) {
              t = "Error: Numbers only";
            }
            el.next(".success").html("<span class='error'>" + t + "</span>").addClass("in");
            el.parent().addClass("field-failure");
            setTimeout(function() {
              el.next(".success").removeClass("in");
            }, 3000);
          })
          , el);
      }, 1000);
    }
    , ".evidence .remove-population-doc click" : function(el, ev) {
      var model = el.closest("[data-model]").data("model")
      , type = el.closest("[data-doc-type]").data("doc-type")
      , that = this;
      model.attr(type + "_document_id", null);
      this.bindXHRToButton(
        model.save()
        , el);

    }
    //meeting events
    , ".add-meeting modal:success" : function(el, ev, data) {
      el.closest("[data-model]").data("model").addElementToChildList("meetings", new CMS.Models.Meeting(data));
    } 
    , ".edit_document modal:success" : function(el, ev, data) {
      CMS.Models.Document.findInCacheById(data.id).attr(data);
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
    , restore_add_link : function(el) {
        var $li = el.closest(".inline-add-person, .inline-add-document");

        $li.next(".toggle-add-person, .toggle-add-document").removeClass("hide");
        $li.prev(".pbc-item").removeClass("hide");
        $li.addClass("hide");        
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
        this.bindXHRToButton(model.save(), ev);
    }
    , '.response-title-bar > a click' : function(el, e) {
      var $this = $(el)
        , $input = $this.closest('.pbc-add-response').find('.pbc-system-search')
        , resp = new CMS.Models.Response()
        ;
      resp.attr({
        request_id: $(e.target).closest("[data-filter-id]").data("filter-id")
        //, system_id: data.id
      });
      resp.save()
      .done(function(r) {
        //after create, go straight to the first form field
        setTimeout(function() {
          var $newitem = $this.closest("[data-filter-id]").find("[data-id=" + r.id + "]");
          
          if($newitem.find(".inline-edit-population-doc").length) {
            $newitem.find(".inline-edit-population-doc input:visible:first").focus();
          } else {
            $newitem.find(".btn-add:first").click();
          }
        }, 200);
      });

      //$input.val('');
      //$this.closest('.collapse').collapse('hide');
    }
    , ".pbc-responses > .item > .item-main > .openclose click" : function(el, ev) {
      this.constructor.one_created(true);

      //openclose is animated so use opposite of active class
      this.options.display_prefs.setPbcResponseOpen(this.options.page_id, el.closest(".item").data("id"), !el.is(".active"));
    }
    , ".remove-system click" : function(el, ev) {
      var $system = el.closest("[data-model]");
      var $resp = $system.parent().closest("[data-model]");
      var m = this.options.model.findInCacheById($resp.data("model").id);
      m.attr("system_id", null).attr("system", null).save();
    }

    , ".system-add modal:success" : "update_system"
    , ".pbc-system-search systemOrProcessSelected" : "update_system"
    , update_system : function(el, ev, data) {
      var $this = $(this)
      , resp = new CMS.Models.Response({ id : el.closest("[data-id]").data("id") });
      resp.attr({
          request_id : el.closest("[data-filter-id]").data("filter-id")
          , system_id : data.value || data.id
          , system : CMS.Models.System.findInCacheById(data.value || data.id)
      });
      resp.save()
    }
});

})(this, can.$);
