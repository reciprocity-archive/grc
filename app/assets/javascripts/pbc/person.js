//= require can.jquery-all
//= require models/cacheable

(function(ns, can) {

can.Model.Cacheable("CMS.Models.Person", {
    findAll : function(params) {
        var dfd = new $.Deferred();
        dfd.resolve([{
            id : 1
            , email : "brad@reciprocitylabs.com"
            , name : "Brad"
            , company : "Reciprocity, Inc."
            , language : "en-US"
        }]);
        return dfd;
    }
    , create : function(params) {
        return new $.Deferred().resolve(
            new this(can.extend({id : this.cache.length}, params))
        );
    }
}, {
    
});

})(this, can);