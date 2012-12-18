//= require can.jquery-all
//= require models/cacheable

(function(ns, can) {

can.Model.Cacheable("CMS.Models.Person", {
    root_object : "person"
    , findAll : "GET /people.json"
    , create : "POST /people.json"
}, {
    init : function () {
        this._super && this._super();
        // this.bind("change", function(ev, attr, how, newVal, oldVal) {
        //     var obj;
        //     if(obj = CMS.Models.ObjectPerson.findInCacheById(this.id) && attr !== "id") {
        //         obj.attr(attr, newVal);
        //     }
        // });
    }
});


can.Model.Cacheable("CMS.Models.ObjectPerson", {
    root_object : "object_person"
}, {
    init : function() {
        this._super && this._super();
        this.attr("person", CMS.Models.Person.findInCacheById(this.person_id)); 
    }
});

})(this, can);