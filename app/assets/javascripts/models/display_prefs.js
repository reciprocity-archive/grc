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

  , getSorts : function(page_id, column_id) {
    var sorts = can.getObject("sorts", this);
    if(!sorts) {
      sorts = new can.Observe();
      this.attr("sorts", sorts);
    }

    var page_sorts = sorts.attr(page_id);
    if(!page_sorts) {
      page_sorts = new can.Observe();
      sorts.attr(page_id, page_sorts);
    }

    return column_id ? page_sorts.attr(widget_id) : page_sorts;
  }

  , setSorts : function(page_id, widget_id, sorts) {
    if(typeof sorts === "undefined" && typeof widget_id === "object") {
      sorts = widget_id;
      widget_id = undefined;
    }
    var all_sorts = can.getObject("sorts", this);
    if(!all_sorts) {
      all_sorts = new can.Observe();
      this.attr("sorts", all_sorts);
    }

    var page_sorts = all_sorts.attr(page_id);
    if(!page_sorts) {
      page_sorts = widget_id ? new can.Observe().attr(widget_id, sorts) : new can.Observe(sorts);
      all_sorts.attr(page_id, page_sorts);
    } else {
      page_sorts.attr(widget_id ? widget_id : sorts, widget_id ? sorts : undefined);
    }

    this.autoupdate && this.save();
    return this;    
  }

});

})(this.can, this.can.$);