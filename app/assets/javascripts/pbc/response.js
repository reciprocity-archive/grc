//= require can.jquery-all
//= require pbc/system

can.Model.Cacheable("CMS.Models.Response", {

    root_object : "response"

    , create : function(params) {
        var _params = { response : {
            system_id : params.system_id
            , request_id : params.request_id
        }}
        return $.when(
            $.ajax({
                type : "POST"
                , url : "/responses.json"
                , dataType : "json"
                , data : _params
            }),
            CMS.Models.System.findOne({ id : params.system_id })
        ).then(function(response, system) {
            response.system = system;
        });
    }

    , findAll : "GET /responses.json"

}, {

    init : function() {
        this._super();

        this.attr("system", new CMS.Models.System(this.system ? this.system.serialize() : {}));
    }

});