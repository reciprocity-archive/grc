//= require can.jquery-all
//= require models/cacheable

(function(ns, can) {

can.Model.Cacheable("CMS.Models.Document", {
    root_object : "document"
    , findAll : "GET /documents.json"
    , create : "POST /documents.json"
}, {
    init : function () {
        this._super && this._super();
        // this.bind("change", function(ev, attr, how, newVal, oldVal) {
        //     var obj;
        //     if(obj = CMS.Models.ObjectDocument.findInCacheById(this.id) && attr !== "id") {
        //         obj.attr(attr, newVal);
        //     }
        // });
    }

});


can.Model.Cacheable("CMS.Models.ObjectDocument", {
    root_object : "object_document"
    , create : function(params) {
        var _params = {
            object_document : {
                documentable_id : params.system_id
                , document_id : params.document_id
                , role : params.role
                , documentable_type : "System"
            }
        };
        return $.ajax({
            type : "POST"
            , "url" : "/object_documents.json"
            , dataType : "json"
            , data : _params
        });
    }
    , destroy : "DELETE /object_documents.json"
}, {
    init : function() {
        var _super = this._super;
        function reinit() {
            typeof _super === "function" && _super.call(this);
            this.attr(
                "document"
                , CMS.Models.Document.findInCacheById(this.document_id) 
                || new CMS.Models.Document(this.document && this.document.serialize ? this.document.serialize() : this.document)); 
        }

        this.bind("created", can.proxy(reinit, this));

        reinit.call(this);
    }

});

})(this, can);