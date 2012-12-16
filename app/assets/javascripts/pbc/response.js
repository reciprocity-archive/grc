//= require can.jquery-all
//= require pbc/system

can.Model("CMS.Models.Response", {

    create : function(params) {
        var _params = { response : {
            system_id : params.system_id
            , request_id : params.request_id
        }}
        return $.ajax({
            type : "POST"
            , url : "/responses"
            , dataType : "json"
            , data : _params
        });
    }

    , makeFindAll : function(findOne) {
        return function(params, success, error) {
            success(
                new can.Model.List([
                new CMS.Models.Response(
                {"created_at":"2012-12-14T19:15:24-08:00"
                , "id": 1
                , "modified_by_id": 1
                , "request_id": 2
                , "status": null
                , "system_id": 1
                , "updated_at": "2012-12-14T19:15:24-08:00"
                , "system": new CMS.Models.System({
                    "created_at": "2012-11-20T15:06:33-08:00"
                    , "description": "x"
                    , "id": 1
                    , "infrastructure": true
                    , "is_biz_process": false
                    , "modified_by_id": null
                    , "network_zone_id": null
                    , "notes": ""
                    , "owner_id": null
                    , "slug": "SYS1"
                    , "start_date": null
                    , "stop_date": null
                    , "title" : "System 1"
                    , "type_id": null
                    , "updated_at": "2012-11-20T15:06:33-08:00"
                    , "url": null
                    , "version": null
                })})]
            ));
            return new $.Deferred().resolve();
        };
    }
}, {});