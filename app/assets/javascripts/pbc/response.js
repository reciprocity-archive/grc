//= require can.jquery-all
//= require pbc/system

can.Model.Cacheable("CMS.Models.Response", {

    root_object : "response"

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

}, {

    init : function() {
        this._super();

        this.attr("system", new CMS.Models.System(this.system ? this.system.serialize() : {}));
    }

});