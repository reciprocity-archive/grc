//= require can.jquery-all
//= require pbc/system

//Response isn't technically a System, but subclassing makes it much easier to do the binding of 
// created/destroeyd listeners on ObjectDocuments and ObjectPeople, which both classes use.
CMS.Models.System("CMS.Models.Response", {

    root_object : "response"
    , xable_type : "Response"
    , create : function(params) {
        var _params = { response : {
            system_id : params.system_id
            , request_id : params.request_id
        }}
        return $.ajax({
                type : "POST"
                , url : "/responses.json"
                , dataType : "json"
                , data : _params
            })
    }

    , findAll : "GET /responses.json"
    , destroy : "DELETE /responses/{id}.json"
}, {

    init : function() {
        this._super();

        function reinit() {
            this.attr("system", new CMS.Models.System(this.system ? this.system.serialize() : {}));
        }

        this.bind("created", can.proxy(reinit, this));

        reinit.call(this);
    }

});