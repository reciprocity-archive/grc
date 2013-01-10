//= require can.jquery-all
//= require models/cacheable

(function(ns, can) {

can.Model.Cacheable("CMS.Models.Person", {
    root_object : "person"
    , findAll : "GET /people.json"
    , create : function(params) {
        var _params = {
            person : {
                name : params.name
                , email : params.ldap
                , company_id : params.company_id
            }
        };
        return $.ajax({
            type : "POST"
            , "url" : "/people.json"
            , dataType : "json"
            , data : _params
        });
    }
    , search : function(request, response) {
        return $.ajax({
            type : "get"
            , url : "/people.json"
            , dataType : "json"
            , data : {s : request.term}
            , success : function(data) {
                response($.map( data, function( item ) {
                  return can.extend({}, item.person, {
                    label: item.person.email
                    , value: item.person.id
                  });
                }));
            }
        });
    }
}, {
    init : function () {
        this._super && this._super();
        // this.bind("change", function(ev, attr, how, newVal, oldVal) {
        //     var obj;
        //     if(obj = CMS.Models.ObjectPerson.findInCacheById(this.id) && attr !== "id") {
        //         obj.attr(attr, newVal);
        //     }
        // });

        var that = this;

        this.each(function(value, name) {
          if (value === null)
            that.removeAttr(name);
        });
    }
});


can.Model.Cacheable("CMS.Models.ObjectPerson", {
    root_object : "object_person"
    , create : function(params) {
        var _params = {
            object_person : {
                personable_id : params.xable_id
                , person_id : params.person_id
                , role : params.role
                , personable_type : params.xable_type
            }
        };
        return $.ajax({
            type : "POST"
            , "url" : "/object_people.json"
            , dataType : "json"
            , data : _params
        });
    }
    , update : function(id, object) {
        var _params = {
            object_person : {
                personable_id : object.personable_id
                , person_id : object.person_id
                , role : object.role
                , personable_type : object.personable_type
            }
        };
        return $.ajax({
            type : "PUT"
            , "url" : "/object_people/" + id + ".json"
            , dataType : "json"
            , data : _params
        });
    }
    , destroy : "DELETE /object_people/{id}.json"
}, {
    init : function() {
        var _super = this._super;
        function reinit() {
            var that = this;

            typeof _super === "function" && _super.call(this);
            this.attr(
                "person"
                , CMS.Models.Person.findInCacheById(this.person_id) 
                || new CMS.Models.Person(this.person && this.person.serialize ? this.person.serialize() : this.person)); 

            this.each(function(value, name) {
              if (value === null)
              that.removeAttr(name);
            });
        }

        this.bind("created", can.proxy(reinit, this));

        reinit.call(this);
    }
});

})(this, can);
