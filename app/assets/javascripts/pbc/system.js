//= require can.jquery-all
//= require models/cacheable
//= require pbc/document
//= require pbc/person

can.Model.Cacheable("CMS.Models.System", {
    root_object : "system"
    , findAll : "GET /systems.json?responseid={id}" 
    , findOne : "GET /systems/{id}.json" 
    , search : function(request, response) {
        return $.ajax({
            type : "get"
            , url : "/systems.json"
            , dataType : "json"
            , data : {s : request.term}
            , success : function(data) {
                response($.map( data, function( item ) {
                  return {
                    label: item.system.slug + ' ' + item.system.title,
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
            var sys = that.findInCacheById(obj_person.personable_id); //"this" is Cacheable.  WTF?
            if(sys) {
                sys.addElementToChildList("object_people", obj_person);
                sys.addElementToChildList("people", obj_person.person);
            }
        });
        CMS.Models.ObjectDocument.bind("created", function(ev, obj_doc) {
            var sys = that.findInCacheById(obj_doc.documentable_id); //"this" is Cacheable.  WTF?
            if(sys) {
                sys.addElementToChildList("object_documents", obj_doc);
                sys.addElementToChildList("documents", obj_doc.document);
            }
        });
    }

}, {

    init : function() {
        this._super && this._super();
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
});
