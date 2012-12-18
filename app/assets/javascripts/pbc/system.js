//= require can.jquery-all
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
