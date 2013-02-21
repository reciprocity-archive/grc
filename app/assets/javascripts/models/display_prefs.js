//= require can.jquery-all
//= require models/local_storage

(function(can, $){

can.Model.LocalStorage("CMS.Models.DisplayPrefs", {
  autoupdate : true
}, {
  init : function() {
    this.autoupdate = this.constructor.autoupdate;
  }

  , setCollapsed : function(page_id, widget_id, is_collapsed) {
    var cs = this.attr("collapse");
    if(!cs) {
      cs = new can.Observe(); 
      this.attr("collapse", cs);
    }
    var csp = cs.attr(page_id);
    if(!csp) {
      csp = new can.Observe(); 
      cs.attr(page_id, csp);
    }
    csp.attr(widget_id, is_collapsed);
    this.autoupdate && this.save();
    return this;
  }

  , getCollapsed : function(page_id, widget_id) {
    return can.getObject("collapse." + page_id, this, true)[widget_id];
  }

});

})(this.can, this.can.$);