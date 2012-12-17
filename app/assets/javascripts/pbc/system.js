//= require can.jquery-all

can.Model.Cacheable("CMS.Models.System", {
   findAll : "GET /pbc/systems?responseid={id}" 
   , search : function(request, response) {
    return $.ajax({
        type : "get"
        , url : "/quick/systems.json"
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
}, {});