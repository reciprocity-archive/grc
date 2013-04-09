//= require can.jquery-all

can.Control("CMS.Controllers.TreeView", {
  //static properties
  defaults : {
    model : null
    , list_view : "/assets/controls/tree.mustache"
    , show_view : "/assets/controls/show.mustache"
    , parent_id : null
    , list : null
    , single_object : false
    , find_params : {}
    , start_expanded : true
    , draw_children : true
    , child_options : [] //this is how we can make nested configs. if you want to use an existing 
    //example child option :
    // { property : "controls", model : CMS.Models.Control, }
    // { parent_find_param : "system_id" ... }
  }
}, {
  //prototype properties
  setup : function() {
    typeof this._super === "function" && this._super.apply(this, arguments);
    this.options = new can.Observe(this.options);
  }

  , init : function(el, opts) {
    this.options.attr(this.options.model.tree_view_options).attr(opts);
    this.options.list ? this.draw_list() : this.fetch_list(this.options.parent_id);
    this.element.attr("data-object-type", can.underscore(this.options.model.shortName)).data("object-type", can.underscore(this.options.model.shortName));
  }
  , fetch_list : function() {
    if(can.isEmptyObject(this.options.find_params.serialize())) {
      this.options.find_params.attr("id", this.options.parent_id);
    }
    this.find_all_deferred = this.options.model[this.options.single_object ? "findOne" : "findAll"](
      this.options.find_params.serialize()
      , this.proxy("draw_list")
    );
  }
  , draw_list : function(list) {
    var that = this;
    if(list) {
      this.options.attr("list", list.length == null ? [list] : list);
    }
    that.add_child_lists(that.options.attr("list")); //since the view is handling adding new controllers now, configure before rendering.
    can.view(this.options.list_view, this.options, function(frag) {;
      that.element && that.element.html(frag);
    });
  }

  , add_child_lists : function(list) {
    var that = this;
    if(that.options.draw_children) {
      //Recursively define tree views anywhere we have subtree configs.
      can.each(list, function(item) {
        item.attr("child_options", that.options.child_options.serialize());
        can.each(item.child_options.length != null ? item.child_options : [item.child_options], function(data) {
          that.add_child_list(item, data);
        });
      });
    }
  }

  // data is an entry from child options.  if child options is an array, run once for each.
  , add_child_list : function(item, data) {  
    //var $subtree = $("<ul class='tree-structure'>").appendTo(el);
    //var model = $(el).closest("[data-model]").data("model");
    data.attr({ start_expanded : false });
    var find_params;
    if(data.property) {
     data.attr("list", item[data.property]);
    } else {
      find_params = data.attr("find_params");
      if(!find_params) {
        data.attr("find_params", {});
      }
       if(data.parent_find_param){
        data.attr("find_params." + data.parent_find_param, item.id);
      } else {
        data.attr("find_params.parent_id", item.id);
      }
    }
    // $subtree.cms_controllers_tree_view(opts);
  } 

  , " newChild" : function(el, ev, data) {
    if(this.options.parent_id === this.data.parent_id) {
      this.options.list.push(new this.options.model(data));
      this.element.find()
    }
  }
  , ".edit-object modal:success" : function(el, ev, data) {
    el.closest("[data-model]").data("model").attr(data);
    ev.stopPropagation();
  }

  , ".link-object modal:success" : function(el, ev, data) {
    ev.stopPropagation();
    this.link_objects(
      el.data("child-type")
      , el.data("child-property")
      , el.closest("[data-object-id]")
      , data
    );
  }

  , " linkObject" : function(el, ev, data) {
    this.link_objects(
      data["childType"]
      , data["childProperty"]
      , this.element.children("[data-object-id=" + data["parentId"] + "]")
      , data.data
    );
  }

  , link_objects : function(child_object_type, child_property, $parent, data) {
    var that = this
    , parentid = $parent.data("object-id")
    , parent_object_type = $parent.data("object-type")
    , $list = $parent.find(".item-content:first").children(".tree-structure[data-object-type=" + child_object_type + "]")
    , existing = $list.children("[data-object-id]")
                 .map(function() { return $(this).data("object-id")})
    , id_list = can.map(can.makeArray(data), function(v) {
      return v[parent_object_type + "_" + child_object_type][child_property];
    })
    , child_options = $list.control(CMS.Controllers.TreeView).options
    , find_dfds = [];

    can.each(id_list, function(v) {
      //adds
      if(!~can.inArray(v, existing)) {
        find_dfds.push(child_options.model.findOne({id : v}));
      }
    })
    can.each(can.makeArray(existing), function(v) {
      //removes
      if(!~can.inArray(v, id_list)) {
        can.each(child_options.list, function(item, i) {
          if(item.id === v) {
            child_options.list.splice(i, 1);
            return false;
          }
        }) 
      }
    });

    if(find_dfds.length) {
      $.when.apply($, find_dfds).done(function() {
        var new_objs = can.makeArray(arguments);
        can.each(new_objs, function(obj) { 
          child_options.list.push(obj);
          //$list.control(CMS.Controllers.TreeView).add_child_lists($list.find("[data-object-id=" + obj.id + "]"));
        });
      });
    }

    $list.parents(".item-content").siblings(".item-main").openclose("open");
    var $box = $parent.closest(".content");
    setTimeout(function() {
      $box.scrollTop($list.offset().top + $list.height() - $box.height() / 2);
    }, 300);
  }

});