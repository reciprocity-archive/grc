//= require can.jquery-all
//= require models/cacheable

(function(ns, can) {

can.Model.Cacheable("CMS.Models.Document", {
    root_object : "document"
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
}, {
    init : function() {
        this._super && this._super();
        this.attr("document", CMS.Models.Document.findInCacheById(this.document_id)); 
    }
});

})(this, can);