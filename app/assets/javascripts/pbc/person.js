//= require can.jquery-all
//= require models/cacheable

(function(ns, can) {

can.Model.Cacheable("CMS.Models.Person", {
    root_object : "person"
    , findAll : "GET /people.json"
    , create : "POST /people.json"
}, {
    
});

})(this, can);