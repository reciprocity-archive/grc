//= requre can.jquery-all

can.Control("CMS.Controllers.DashboardWidgets", {
  defaults : {
    model : null
    , list_view : "/assets/programs_dash/object_list.mustache"
    //, show_view : "/assets/controls/tree.mustache"
    , tooltip_view : "/assets/programs_dash/object_tooltip.mustache"
    , widget_view : "/assets/programs_dash/object_widget.mustache"
    , object_type : null
    , object_category : null //e.g. "governance"
    , object_route : null //e.g. "systems"
    , object_display : null
    , content_selector : ".content"
    , minimum_widget_height : 100
  }
}, {
  
  init : function() {
    this.fetch_list();
    this.element
    .addClass("widget")
    .addClass(this.options.object_category)
    .attr("id", this.options.object_type + "_list_widget")
    .trigger("section_created");
  }

  , fetch_list : function(params) {
    this.options.model.findAll(params, this.proxy('draw_list'));
  }

  , draw_list : function(list) {
    var that = this;
    this.options.list = list;

    can.view(this.options.widget_view, this.options, function(frag) {
      that.element.html(frag);
      CMS.Models.DisplayPrefs.findAll().done(function(d) {
        var content = that.element.find(that.options.content_selector).first();
        if(d[0].getCollapsed("programs_dash", that.element.attr("id"))) {

          that.element
          .find(".widget-showhide > a")
          .showhide("hide");
          
          content.add(that.element).css("height", "");
          if(content.is(".ui-resizable")) {
            content.resizable("destroy")
          }
        } else {
          content
          .removeClass("ui-resizable")
          .resizable({
            handles : "s"
            , minHeight : that.options.minimum_widget_height
            , alsoResize : that.element
            , autoHide : false
          })
        }
      });
      that.element
      .find('.wysihtml5')
      .cms_wysihtml5();
    });
  }

  , ".remove-widget click" : function() {
    var parent = this.element.parent();
    this.element.remove();
    parent.trigger("sortremove");
  }

});