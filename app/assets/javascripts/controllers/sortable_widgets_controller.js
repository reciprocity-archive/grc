//= require can.jquery-all
//= require models/display_prefs

(function(can, $) {
can.Control("CMS.Controllers.SortableWidgets", {
  defaults : {
    sortable_token : "sorts"
    , page_token : window.location.pathname.substring(1, (window.location.pathname + "/").indexOf("/", 1))
  }

  , init : function(el, opts) {
    this._super && this._super.apply(this, arguments)
    var that = this;
    CMS.Models.DisplayPrefs.findAll().done(function(data) {
      var m = data[0] || new CMS.Models.DisplayPrefs();
      m.save();
      that.defaults.model = m;
    });
  }
}, {
  
  init : function() {
    var sorts = can.getObject(this.options.sortable_token, this.options.model);
    if(!sorts) {
      sorts = new can.Observe();
      this.options.model.attr(this.options.sortable_token, sorts);
    }

    var page_sorts = sorts.attr(this.options.page_token);
    if(!page_sorts) {
      page_sorts = new can.Observe();
      sorts.attr(this.options.page_token, page_sorts);
    }

    var this_sort = page_sorts.attr($(this.element).attr("id"));
    if(!this_sort){
      this_sort = new can.Observe.List();
      page_sorts.attr($(this.element).attr("id"), this_sort);
    }
    this.options.sort = this_sort;

    var that = this;
    var firstchild = null;
    can.each(this_sort, function(id) {
      firstchild || (firstchild = $("#" + id));
      $("#" + id).detach().appendTo(that.element);
    });
    if(firstchild) {
      firstchild.prevAll().detach().appendTo(this.element); //do the shuffle
    }

    this.element.sortable().sortable("refresh");
    this.update_event();
  }

  , " sortupdate" : "update_event"
  , " sortreceive" : "update_event"
  , " sortremove" : "update_event"

  , update_event : function(el, ev, data) {
    this.options.sort.replace(this.element.sortable("toArray"));
    this.options.model.save();
  }

});

})(this.can, this.can.$);