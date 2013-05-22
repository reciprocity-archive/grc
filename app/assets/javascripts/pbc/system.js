//= require can.jquery-all
//= require models/cacheable
//= require pbc/document
//= require pbc/person

can.Model.Cacheable("CMS.Models.System", {
    root_object : "system"
    , xable_type : "System"
    , findAll : "GET /systems.json?responseid={id}" 
    , findOne : "GET /systems/{id}.json" 
    , update : function(id, params) {
      return $.ajax({
        url : "/systems/" + id + ".json"
        , data : this.process_args(
          params
          , ["notes"
            , "description"
            , "infrastructure"
            , "is_biz_process"
            , "network_zone_id"
            , "slug"
            , "start_date"
            , "stop_date"
            , "title"
            , "type_id"
            , "url"
            , "version"])
        , type : "put"
      });
    }
    , search : function(request, response) {
        return $.ajax({
            type : "get"
            , url : "/systems.json"
            , dataType : "json"
            , data : {s : request.term}
            , success : function(data) {
                response($.map( data, function( item ) {
                  var system_or_process = item.system.is_biz_process ? 'Process' : 'System';
                  return {
                    label: item.system.slug + ' ' + item.system.title + ' (' + system_or_process + ')',
                    value: item.system.id
                  }
                }));
            }
        });
    }
    , init : function() {
        this._super && this._super();
        var that = this;

        CMS.Models.ObjectPerson.bind("created", function(ev, obj_person) {
            var sys = that.findInCacheById(obj_person.xable_id); //"this" is Cacheable.  WTF?
            if(sys && obj_person.personable_type === that.xable_type) {
                sys.addElementToChildList("object_people", obj_person);
                sys.addElementToChildList("people", obj_person.person);
            }
        });
        CMS.Models.ObjectPerson.bind("destroyed", function(ev, obj_person) {
            var sys = that.findInCacheById(obj_person.xable_id); //"this" is Cacheable.  WTF?
            if(sys && obj_person.personable_type === that.xable_type) {
                sys.removeElementFromChildList("object_people", obj_person);
                sys.removeElementFromChildList("people", obj_person.person);
            }
        });
        CMS.Models.ObjectDocument.bind("created", function(ev, obj_doc) {
            var sys = that.findInCacheById(obj_doc.xable_id); //"this" is Cacheable.  WTF?
            if(sys && obj_doc.documentable_type === that.xable_type) {
                sys.addElementToChildList("object_documents", obj_doc);
                sys.addElementToChildList("documents", obj_doc.document);
            }
        });
        CMS.Models.ObjectDocument.bind("destroyed", function(ev, obj_doc) {
            var sys = that.findInCacheById(obj_doc.xable_id); //"this" is Cacheable.  WTF?
            if(sys && obj_doc.documentable_type === that.xable_type) {
                sys.removeElementFromChildList("object_documents", obj_doc);
                sys.removeElementFromChildList("documents", obj_doc.document);
            }
        });
        this.tree_view_options.child_options[1].model = CMS.Models.System;
    }
    , tree_view_options : {
      list_view : "/assets/systems/tree.mustache"
      , child_options : [{
        model : CMS.Models.Control
        , list_view : "/assets/controls/tree.mustache"
        , parent_find_param : "system_id"
      },{
        model : null ///filled in after init.
        , list_view : "/assets/systems/tree.mustache"
        , parent_find_param : "parent_id"
				, link_buttons: true
      }]
    }
}, {

    init : function() {
      var that = this;
      this._super && this._super();
      this.bind("created updated", can.proxy(this, 'reinit'))
      this.reinit();
      //careful to only do this on init.  Once live binding is set up, some live binding
      //  stops happening when doing removeAttr instead of attr(..., null)
      this.each(function(value, name) {
        if (value === null)
          that.removeAttr(name);
      });
    }
    , reinit : function() {
        var that = this;
        can.each({
            "Person" : "people"
            , "Document" : "documents"
            , "ObjectPerson" : "object_people"
            , "ObjectDocument" : "object_documents"}
        , function(collection, model) {
            var list = new can.Model.List();

            can.each(that[collection], function(obj) {
                list.push(new CMS.Models[model](obj.serialize()));
            });
            that.attr(collection, list);
        });

    }
    , system_or_process: function() {
      if (this.attr('is_biz_process'))
        return 'process';
      else
        return 'system';
    }
    , system_or_process_capitalized: function() {
      var str = this.system_or_process();
      return str.charAt(0).toUpperCase() + str.slice(1);
    }
});

CMS.Models.System("CMS.Models.StrictSystem", {
  findAll : "GET /systems.json?is_biz_process=false"
  , cache : can.getObject("cache", CMS.Models.System, true)
  , init : function() { } //don't rebind the ObjectDocument/ObjectPerson events.
}, {});

CMS.Models.System("CMS.Models.Process", {
  findAll : "GET /systems.json?is_biz_process=true"
  , cache : can.getObject("cache", CMS.Models.System, true)
  , init : function() { } //don't rebind the ObjectDocument/ObjectPerson events.
}, {})
