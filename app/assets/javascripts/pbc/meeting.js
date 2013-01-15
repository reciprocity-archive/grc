//= require can.jquery-all
//= require models/cacheable

can.Model.Cacheable("CMS.Models.Meeting", {
  destroy : "DELETE /meetings/{id}.json"
}, {
  init : function () {
      this._super && this._super();
      // this.bind("change", function(ev, attr, how, newVal, oldVal) {
      //     var obj;
      //     if(obj = CMS.Models.ObjectDocument.findInCacheById(this.id) && attr !== "id") {
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