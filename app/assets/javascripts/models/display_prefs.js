//= require can.jquery-all
//= require models/local_storage

(function(can, $){

var COLLAPSE = "collapse"
, SORTS = "sorts"
, HEIGHTS = "heights"
, COLUMNS = "columns"
, PBC_LISTS = "pbc_lists"

can.Model.LocalStorage("CMS.Models.DisplayPrefs", {
  autoupdate : true
}, {
  init : function() {
    this.autoupdate = this.constructor.autoupdate;
  }

  , makeObject : function() {
    var retval = this;
    var args = can.makeArray(arguments);
    can.each(args, function(arg) {
      var tval = can.getObject(arg, retval);
      if(!tval || !(tval instanceof can.Observe)) {
        tval = new can.Observe(tval);
        retval.attr(arg, tval);
      }
      retval = tval;
    });
    return retval;
  }

  // collapsed state
  // widgets on a page may be collapsed such that only the title bar is visible.
  , setCollapsed : function(page_id, widget_id, is_collapsed) {
    this.makeObject(COLLAPSE, page_id).attr(widget_id, is_collapsed);
    this.autoupdate && this.save();
    return this;
  }

  , getCollapsed : function(page_id, widget_id) {
    return this.makeObject(COLLAPSE, page_id)[widget_id];
  }

  // sorts = position of widgets in each column on a page
  // This is also use at page load to determine which widgets need to be 
  // generated client-side.
  , getSorts : function(page_id, column_id) {
    var sorts = can.getObject(SORTS, this);
    if(!sorts) {
      sorts = new can.Observe();
      this.attr(SORTS, sorts);
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
    var page_sorts = this.makeObject(SORTS, page_id);
    if(!page_sorts) {
      page_sorts = widget_id ? new can.Observe().attr(widget_id, sorts) : new can.Observe(sorts);
      all_sorts.attr(page_id, page_sorts);
    } else {
      page_sorts.attr(widget_id ? widget_id : sorts, widget_id ? sorts : undefined);
    }

    this.autoupdate && this.save();
    return this;    
  }

  // heights : height of widgets to restore on page start.
  // Is set by jQuery-UI resize functions in ResizeWidgetsController
  , getWidgetHeight : function(page_id, widget_id) {
    return this.makeObject(HEIGHTS, page_id)[widget_id];
  }

  // columns : the relative width of columns on each page.
  //  should add up to 12 since we're using row-fluid from Bootstrap
  , getColumnWidths : function(page_id, content_id) {
    return this.makeObject(COLUMNS, page_id, content_id);
  }

  , getColumnWidthsForSelector : function(page_id, sel) {
    return this.getColumnWidths(page_id, $(sel).attr("id"));
  }

  , setColumnWidths : function(page_id, widget_id, widths) {
    var csp = this.makeObject(COLUMNS, page_id)
    csp.attr(widget_id, widths);
    this.autoupdate && this.save();
    return this;
  }

  // reset function currently resets all layout for a page type (first element in URL path)
  , resetPagePrefs : function(page_id) {
    var that = this;
    can.each([COLLAPSE, COLUMNS, SORTS, HEIGHTS], function(category) {
      var cs = can.getObject(category, that);
      if(cs) {
        cs.removeAttr(page_id);
      }
    });
    return that.save();
  }

  , getPbcListPrefs : function(pbc_id) {
    return this.makeObject(PBC_LISTS, pbc_id);
  }

  , setPbcListPrefs : function(pbc_id, prefs) {
    this.makeObject(PBC_LISTS).attr(pbc_id, prefs instanceof can.Observe ? prefs : new can.Observe(prefs));
    this.autoupdate && this.save();
  }

  , getPbcResponseOpen : function(pbc_id, response_id) {
    return this.makeObject(PBC_LISTS, pbc_id, "responses").attr(response_id);
  }

  , getPbcRequestOpen : function(pbc_id, request_id) {
    return this.makeObject(PBC_LISTS, pbc_id, "requests").attr(request_id);
  }

  , setPbcResponseOpen : function(pbc_id, response_id, is_open) {
    var prefs = this.makeObject(PBC_LISTS, pbc_id, "responses").attr(response_id, is_open);

    this.autoupdate && this.save();
    return this;
  }

  , setPbcRequestOpen : function(pbc_id, request_id, is_open) {
    var prefs = this.makeObject(PBC_LISTS, pbc_id, "requests").attr(request_id, is_open);

    this.autoupdate && this.save();  
    return this;  
  }

});

})(this.can, this.can.$);