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
    , create : function(params) {
        var _params = {
            object_person : {
                personable_id : params.system_id
                , person_id : params.person_id
                , role : params.role
                , personable_type : "System"
            }
        };
        return $.ajax({
            type : "POST"
            , "url" : "/object_people.json"
            , dataType : "json"
            , data : _params
        });
    }
    , destroy : "DELETE /object_people.json"
}, {
    init : function() {
        var _super = this._super;
        function reinit() {
            typeof _super === "function" && _super.call(this);
            this.attr(
                "person"
                , CMS.Models.Person.findInCacheById(this.person_id) 
                || new CMS.Models.Person(this.person && this.person.serialize ? this.person.serialize() : this.person)); 
        }

        this.bind("created", can.proxy(reinit, this));

        reinit.call(this);
    }
});

})(this, can);