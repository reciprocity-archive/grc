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
        this._super();

        var people = new can.Model.List();
        var docs = new can.Model.List();

        can.each(this.people, function(person) {
            people.push(new CMS.Models.Person(person.serialize()));
        });
        can.each(this.documents, function(doc) {
            docs.push(new CMS.Models.Document(doc.serialize()));
        });

        this.attr("people", people);
        this.attr("documents", docs);
    }
});
