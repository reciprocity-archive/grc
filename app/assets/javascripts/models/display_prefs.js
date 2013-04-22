//= require can.jquery-all
//= require models/local_storage

(function(can, $){

var COLLAPSE = "collapse"
, SORTS = "sorts"
, HEIGHTS = "heights"
, COLUMNS = "columns"
, PBC_LISTS = "pbc_lists"
, path = window.location.pathname

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

  , getObject : function() {
    return can.getObject(can.makeArray(arguments).join("."), this);
  }

  // collapsed state
  // widgets on a page may be collapsed such that only the title bar is visible.
  , setCollapsed : function(page_id, widget_id, is_collapsed) {

    this.makeObject(path, COLLAPSE).attr(widget_id, is_collapsed);

    this.autoupdate && this.save();
    return this;
  }

  , getCollapsed : function(page_id, widget_id) {
    var collapsed = this.getObject(path, COLLAPSE);
    if(!collapsed) {
      collapsed = this.makeObject(path, COLLAPSE).attr(this.makeObject(COLLAPSE, page_id).serialize());
    }

    return widget_id ? collapsed.attr(widget_id) : collapsed;
  }

  // sorts = position of widgets in each column on a page
  // This is also use at page load to determine which widgets need to be 
  // generated client-side.
  , getSorts : function(page_id, column_id) {
    var sorts = this.getObject(path, SORTS);
    if(!sorts) {
      sorts = this.makeObject(path, SORTS).attr(this.makeObject(SORTS, page_id).serialize());
      this.autoupdate && this.save();
    }

    return column_id ? sorts.attr(column_id) : sorts;
  }

  , setSorts : function(page_id, widget_id, sorts) {
    if(typeof sorts === "undefined" && typeof widget_id === "object") {
      sorts = widget_id;
      widget_id = undefined;
    }
    var page_sorts = this.makeObject(path, SORTS);

    page_sorts.attr(widget_id ? widget_id : sorts, widget_id ? sorts : undefined);

    this.autoupdate && this.save();
    return this;    
  }

  // heights : height of widgets to restore on page start.
  // Is set by jQuery-UI resize functions in ResizeWidgetsController
  , getWidgetHeights : function(page_id) {
    var heights = this.getObject(path, HEIGHTS);
    if(!heights) {
      heights = this.makeObject(path, HEIGHTS).attr(this.makeObject(HEIGHTS, page_id).serialize());
      this.autoupdate && this.save();
    }
    return heights;
  }

  , getWidgetHeight : function(page_id, widget_id) {
    return this.getWidgetHeights(page_id)[widget_id];
  }

  , setWidgetHeight : function(page_id, widget_id, height) {
    var page_heights = this.makeObject(path, HEIGHTS);

    page_heights.attr(widget_id, height);

    this.autoupdate && this.save();
    return this;    
  }

  // columns : the relative width of columns on each page.
  //  should add up to 12 since we're using row-fluid from Bootstrap
  , getColumnWidths : function(page_id, content_id) {
    var widths = this.getObject(path, COLUMNS);
    if(!widths) {
      widths = this.makeObject(path, COLUMNS).attr(this.makeObject(COLUMNS, page_id).serialize());
      this.autoupdate && this.save();
    }
    return widths[content_id];
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
  , resetPagePrefs : function() {
    this.removeAttr(path);
    return this.save();
  }

  , setPageAsDefault : function(page_id) {
    var that = this;
    can.each([COLLAPSE, SORTS, HEIGHTS, COLUMNS], function(key) {
      that.makeObject(key).attr(page_id, that.makeObject(path, key));
    });
    this.save();
    return this;
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