//= requre can.jquery-all

can.Control("CMS.Controllers.DashboardWidgets", {
  defaults : {
    model : null
    , list_view : "/assets/programs_dash/object_list.mustache"
    , related_list_view : "/assets/programs_dash/related_list.mustache"
    //, show_view : "/assets/controls/tree.mustache"
    , tooltip_view : "/assets/programs_dash/object_tooltip.mustache"
    , widget_view : "/assets/programs_dash/object_widget.mustache"
    , object_type : null
    , object_category : null //e.g. "governance"
    , object_route : null //e.g. "systems"
    , object_display : null
    , content_selector : ".content"  //This is somewhat deprecated since we are no longer trying to make the section resizable --BM 3/2/2013
    , minimum_widget_height : 100
    , is_related : false
    , parent_type : null
    , parent_id : null
  }
}, {
  
  init : function() {
    var params = {};
    if(this.options.is_related) {
      this.options.list_view = this.options.related_list_view;
      var path_tokens = window.location.pathname.split("/");
      if(path_tokens[0] === "")
        path_tokens.shift();

      if(this.options.parent_type == null) {
        this.options.parent_type = window.cms_singularize(path_tokens[0]);
      }

      if(this.options.parent_id == null) {
        this.options.parent_id = path_tokens[1];
      }
      params[this.options.parent_type + "_id"] = this.options.parent_id;
    }

    this.element
    .addClass("widget")
    .addClass(this.options.object_category)
    .attr("id", this.options.object_type + "_list_widget")
    .trigger("section_created");

    if(this.options.is_related) {
      this.options.parent_type = this.options.parent_type.split("_").map(can.capitalize).join("");
      this.options.object_type = this.options.object_type.split("_").map(can.capitalize).join("");
    }
    this.fetch_list(params);
  }

  , fetch_list : function(params) {
    if(this.options.is_related) {

      if(this.options.object_type === "Control" || this.options.object_type === "Directive") {
        $.get("/relationships/related_objects.html", { 
          oid : this.options.parent_id
          , otype : this.options.parent_type
          , related_model : this.options.object_type
        }).done(this.proxy('draw_list'));
      } else {
        this.options.model.findRelated({
          id : this.options.parent_id
          , otype : this.options.parent_type
          , related_model : this.options.object_type
        }).done(this.proxy('draw_list'));
      }
    } else {
      this.options.model.findAll(params, this.proxy('draw_list'));
    }
  }

  , draw_list : function(list) {
    var that = this;
    this.options.list = list;

    function do_draw(frag) {
      that.element.html(frag);
      CMS.Models.DisplayPrefs.findAll().done(function(d) {
        var content = that.element;
        if(d[0].getCollapsed("programs_dash", that.element.attr("id"))) {

          that.element
          .find(".widget-showhide > a")
          .showhide("hide");
          
          content.add(that.element).css("height", "");
          if(content.is(".ui-resizable")) {
            content.resizable("destroy")
          }
        } else {
          content.trigger("min_size")
        }
      });
      that.element
      .find('.wysihtml5')
      .cms_wysihtml5();
    }

    if(typeof list === "string") {
      do_draw(list);
    } else {
      can.view(this.options.widget_view, this.options, do_draw);
    }
  }

  , ".remove-widget click" : function() {
    var parent = this.element.parent();
    this.element.remove();
    parent.trigger("sortremove");
  }

});