//= require can.jquery-all

can.Model.Cacheable("CMS.Models.System", {
   findAll : "GET /pbc/systems?responseid={id}" 
   , search : function(request, response) {
    return $.ajax({
        type : "get"
        , url : "/pbc/systems?search=" + request.term
        , dataType : "json"
        , success : function(list) {
            response(list);
        }
    });
   }
}, {});