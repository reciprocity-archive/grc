//= require can.jquery-all
//= require models/display_prefs

(function(can, $) {
can.Control("CMS.Controllers.SortableWidgets", {
  defaults : {
    sortable_token : "sorts"
    , page_token : null
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
    this.options.page_token = window.getPageToken();

    var page_sorts = this.options.model.getSorts(this.options.page_token);

    var this_sort = page_sorts.attr($(this.element).attr("id"));
    if(!this_sort || !(this_sort instanceof can.Observe.List)) {
      this_sort = new can.Observe.List();
      page_sorts.attr($(this.element).attr("id"), this_sort);
    }
    this.options.sort = this_sort;

    var that = this;
    var firstchild = null;
    can.each(this_sort, function(id) {
      firstchild || (firstchild = $("#" + id));
      var $widget = $("#" + id).detach();
      if(!$widget.length) {
        var ctl = that.element.find(".cms_controllers_add_widget").control(CMS.Controllers.AddWidget);
        if(ctl) {
          ctl.addWidgetByName(id.substr(0, id.indexOf("_list_widget")));
          $widget = $("#" + id).detach();
        }
      }
      $widget.appendTo(that.element);
    });
    if(firstchild) {
      firstchild.prevAll().detach().appendTo(this.element); //do the shuffle
    }

    this.element.sortable().sortable("refresh");
    this.is_initialized = true;
    this.force_add_widget_bottom();
  }

  , " sortremove" : "update_event"

  , " sortupdate" : "force_add_widget_bottom"
  , " sortreceive" : "force_add_widget_bottom"
  , force_add_widget_bottom : function(el, ev, data) {
    if(this.is_initialized) {
      var $add_box = this.element.find(".cms_controllers_add_widget")
      , $parent = $add_box.parent();
      if($add_box.is(":not(:last-child)")) {
        $add_box.detach().appendTo($parent);
      }
    }
    this.element.sortable().sortable("refresh");
    this.update_event(el, ev, data);
  }

  , update_event : function(el, ev, data) {
    if(this.is_initialized) {
      this.options.sort.replace(this.element.sortable("toArray"));
      this.options.model.save();
    }
  }

});

})(this.can, this.can.$);