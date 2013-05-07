//= require can.jquery-all
//= require controllers/filterable_controller

CMS.Controllers.Filterable("CMS.Controllers.DashboardWidgets", {
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
        this.options.parent_type = window.cms_singularize($(document.body).attr("data-page-subtype") || $(document.body).attr("data-page-type") || path_tokens[0]);
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
    .css("height", this.options.minimum_widget_height)
    .html($(new Spinner().spin().el).css({
        width: '100px',
        height: '100px',
        left: '50px',
        top: '50px'
        }))
    .trigger("section_created");

    if(this.options.is_related) {
      if(this.options.object_type !== "system_process") {
        this.options.object_display = this.options.object_route.split("_").map(can.capitalize).join(" ");
      }
      this.options.object_type = this.options.object_type.split("_").map(can.capitalize).join("");
      this.options.parent_display = this.options.parent_type.split("_").map(can.capitalize).join(" ");
      this.options.parent_type = this.options.parent_display.replace(" " , "");
    }
    this.fetch_list(params);
  }

  , fetch_list : function(params) {
    if(this.options.is_related) {

      if(~can.inArray(this.options.object_type, ["Control", "Directive", "Regulation", "Policy", "Contract", "Section", "Clause"])
         || this.options.parent_type === "Control") {
        var params = {
          list : true
          , tree : true
        };
        var url;
        switch(this.options.object_type) {
          case "Section" :
          url = (this.options.parent_type === "Control" ? "/controls/" : "/directives/") + this.options.parent_id + "/" + this.options.object_route;
          break;
          case "SystemProcess" :
          url = "/controls/" + this.options.parent_id + "/" + this.options.object_route;
          break;
          case "Risk" :
          url = "/controls/" + this.options.parent_id + "/" + this.options.object_route;
          break;
          default:
          url = "/" + this.options.object_route;
          break;
        }

        params[can.underscore(this.options.parent_type) + "_id"] = this.options.parent_id;
        $.ajax({
          url : url
          , dataType : "html"
          , type : "get"
          , data : params
        })
        .done(this.proxy('draw_list'));
      } else {
        this.options.model.findRelated({
          id : this.options.parent_id
          , otype : this.options.parent_type
          , related_model : this.options.object_type
        }).done(this.proxy('draw_list'));
      }
    } else {
      this.options.model.findAll(params).done(this.proxy('draw_list')).fail(this.proxy('draw_error'));
    }
  }

  , do_draw : function(frag) {
    var that = this;
     this.element.html(frag);
   
    if(~can.inArray(this.options.object_type, ["Control", "Directive", "Section"])) {
      this.element.find(".object_count").html(this.element.find("li." + can.underscore(this.options.object_type)).length);
    }
    if(this.options.object_type === "SystemProcess") {
      this.element.find(".object_count").html(that.element.find("li.system, li.process").length);
    }

    CMS.Models.DisplayPrefs.findAll().done(function(d) {
      var content = that.element;
      if(d[0].getCollapsed(window.getPageToken(), that.element.attr("id"))) {

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
    this.element
    .find('.wysihtml5')
    .cms_wysihtml5();
  }

  , draw_error : function(xhr) {

    if(xhr.status === 403 || xhr.status === 401) {
      can.view.mustache(this.element.attr("id") + "_tmpl", "<h3><span class='error'>Error:  You are not authorized to view this resource.</span></h3>");
    } else {
      can.view.mustache(this.element.attr("id") + "_tmpl", "<h3><span class='error'>Error: Unknown error.</span></h3>");      
    }
    this.options.list_view = "#" + this.element.attr("id") + "_tmpl";
    can.view(this.options.widget_view, this.options, this.proxy('do_draw'));
  }

  , draw_list : function(list, xhr) {
    var that = this;


    if(typeof list === "string") {
      can.view.mustache(this.element.attr("id") + "_tmpl", list);
      this.options.list_view = "#" + this.element.attr("id") + "_tmpl";
    } else {
      this.options.list = list;
    }
    can.view(this.options.widget_view, this.options, this.proxy('do_draw'));
  }

  , ".remove-widget click" : function() {
    var parent = this.element.parent();
    this.element.remove();
    parent.trigger("sortremove");
  }

  , ".widgetsearch-tocontent keydown" : function(el, ev) {
    if(ev.which === 13) {
      this.filter(el.val());
    }
    ev.stopPropagation();
    ev.originalEvent && ev.originalEvent.stopPropagation();
  }

});
