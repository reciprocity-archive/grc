//= require can.jquery-all
//= require models/cacheable

can.Model.Cacheable("CMS.Models.Category", {
  root_object : "category"
  ,  findAll : function(params) {
    var root_object = this.root_object;

    function filter_out(original, predicate) {
      var target = [];
      for(var i = original.length - 1; i >= 0; i--) {
        if(predicate(original[i])) {
          target.unshift(original.splice(i, 1)[0]);
        }
      }
      return target;
    }

    function treeify(list, pid) {
      var ret = filter_out(list, function(s) { return s.parent_id == pid });
      can.$(ret).each(function() {
        this.children = treeify(list, this.id);
      });
      return ret;
    }

    return can.ajax(
      can.extend({ url : "/categories.json"}, params)
    ).then(
      function(list, xhr) {
        can.$(list).each(function(i, s) {
          can.extend(s, s[root_object]);
          delete s[root_object];
        });
        var roots = treeify(list); //empties the list
        // for(var i = 0; i < roots.length; i++)
        //   list.push(roots[i]);
        roots.push({ id : -1, name : "Uncategorized Controls" });
        return roots;
      });
  }
  , model : function(params) {
    var m = this._super(params);
    m.attr("children", this.models(m.children));
    return m;
  }
  , tree_view_options : {
    list_view : "/assets/controls/categories_tree.mustache"
    , start_expanded : false
    , child_options : [{
      model : null
      , property : "children"
    }, {
      model : CMS.Models.Control
      , property : "linked_controls"
      , list_view : "/assets/controls/tree_with_section_mappings.mustache"
    }]

  }
  , init : function() { 
    this._super && this._super.apply(this, arguments);
    this.tree_view_options.child_options[0].model = this;
  }
}, {
  init : function() {
    var that = this
    this._super && this._super.apply(this, arguments);
    this.attr("linked_controls", new can.Model.List());

    var cs = new can.Model.List();
    if(this.children) {
      for(var i = 0; i < this.children.length ; i ++) {
        cs.push(new this.constructor(this.children[i].serialize()));
      }
    }
    this.attr("children", cs);

    this.attr("descendant_controls", can.compute(function() {
      return that.attr("linked_controls").concat(can.reduce(that.attr("children"), function(a, b) {
        return a.concat(can.makeArray(b.descendant_controls()));
      }, []));
    }));
  }
});