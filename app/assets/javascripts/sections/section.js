//= require can.jquery-all
//= require controls/control
//= require models/cacheable

can.Model.Cacheable("CMS.Models.Section", {
  root_object : "section"
  , findAll : "GET " + (/^\/[^\/]+\/[^\/]+/.exec(window.location.pathname) || [])[0] + "/sections.json"
  , update : function(id, section) {
    var param = {};
    can.each(section, function(val, key) {
      if(can.inArray(key, ["parent_id", "created_at", "id", "kind", "modified_by_id", "updated_at", "linked_controls", "description_inline"]) < 0)
        param["section[" + key + "]"] = val;
    });
    return $.ajax({
      type : "PUT"
      , url : "/sections/" + id + ".json"
      , dataType : "json"
      , data : param
    });
  }
  , map_rcontrol : function(params, section) {
    return can.ajax({
      url : "/mapping/map_rcontrol"
      , data : params
      , type : "post"
      , dataType : "json"
      , success : function() {
        if(section) {
          var flatctls = [];
          var linkedctl =
            (params.rcontrol ? 
              CMS.Models.RegControl.findInCacheById(params.rcontrol) 
              : CMS.Models.Control.findInCacheById(params.ccontrol))
            ;
          var addctls = function(ctl) {
            flatctls.push(ctl);
            can.each(ctl.implementing_controls, addctls);
          }
          addctls(linkedctl);
          var ctlids = can.map(flatctls, function(ctl) { return ctl.id });

          if(params.u) {
            //unmap
            var ctlindex;
            for(var i = section.linked_controls.length - 1; i >= 0; i--) {
              //if(!section.linked_controls[i] instanceof CMS.Models.Control)
              if((ctlindex = can.inArray(section.linked_controls[i].id, ctlids)) >= 0)
              {
                section.linked_controls[i].unbind_section(section);
                section.linked_controls.splice(i, 1);
                ctlids.splice(ctlindex, 1);
              }
            }
            var section_idx = can.inArray(section.id, linkedctl.mapped_section_ids);
            if(~section_idx) linkedctl.mapped_section_ids.splice(section_idx, 1);
          } else {
            //map
            // can.each(section.linked_controls, function() {
            //   var i = can.inArray(this.id, ctlids);
            //   if(i >= 0) {
            //     flatctls.splice(i, 1);
            //     ctlids.splice(i, 1);
            //   }
            // });
            section.linked_controls.push.apply(section.linked_controls, flatctls);
            params.rcontrol && linkedctl.bind_section(section);
            ~can.inArray(section.id, linkedctl.mapped_section_ids) || linkedctl.mapped_section_ids.push(section.id);
          }
          section.updated();
        }
      }
    });
  }

  , map_control : function(params, section) {
    return can.ajax({
      url : "/mapping/map_rcontrol"
      , data : params
      , type : "post"
      , dataType : "json"
      , success : function() {
        if(section) {
          var flatctls = [];
          var linkedctl = CMS.Models.Control.findInCacheById(params.ccontrol);
          var addctls = function(ctl) {
            flatctls.push(ctl);
            can.each(ctl.implementing_controls, addctls);
          }
          addctls(linkedctl);
          var ctlids = can.map(flatctls, function(ctl) { return ctl.id });

          if(params.u) {
            //unmap
            var ctlindex;
            for(var i = section.linked_controls.length - 1; i >= 0; i--) {
              //if(!section.linked_controls[i] instanceof CMS.Models.Control)
              if((ctlindex = can.inArray(section.linked_controls[i].id, ctlids)) >= 0)
              {
                section.linked_controls[i].unbind_section(section);
                section.linked_controls.splice(i, 1);
                ctlids.splice(ctlindex, 1);
              }
            var section_idx = can.inArray(section.id, linkedctl.mapped_section_ids);
            if(~section_idx) linkedctl.mapped_section_ids.splice(section_idx, 1);
            }
          } else {
            section.linked_controls.push.apply(section.linked_controls, flatctls);
            linkedctl.bind_section(section);
            ~can.inArray(section.id, linkedctl.mapped_section_ids) || linkedctl.mapped_section_ids.push(section.id);
            
          }
          section.updated();
        }
      }
    });
  }

  , model : function(attrs) {
    var id;
    if((id = attrs.id || (attrs[this.root_object] && attrs[this.root_object].id)) && this.findInCacheById(id)) {
      var cached = this.findInCacheById(id);
      if($(this.linked_controls).filter(function() { return this instanceof CMS.Models.RegControl }).length)
        cached.update_linked_controls();
      else
        cached.update_linked_controls_ccontrol_only();
      return cached;
    } else {
      return this._super.apply(this, arguments);
    }
  }
}, {

  init : function() {

    this._super();

    var cs = new can.Model.List();
    if(this.children) {
      for(var i = 0; i < this.children.length ; i ++) {
        cs.push(new this.constructor(this.children[i].serialize()));
      }
    }
    this.attr("children", cs);

    var that = this;
    this.each(function(value, name) {
      if (value === null)
        that.removeAttr(name);
    });

    this.attr("descendant_sections", can.compute(function() {
      return that.attr("children").concat(can.reduce(that.children, function(a, b) {
        return a.concat(can.makeArray(b.descendant_sections()));
      }, []));
    }));
    this.attr("descendant_sections_count", can.compute(function() {
      return that.attr("descendant_sections")().length;
    }));
  }

  , map_rcontrol : function(params) {
    return this.constructor.map_rcontrol(can.extend({}, params, {section : this.id}), this);
  }

  , map_control : function(params) {
    return this.constructor.map_control(can.extend({}, params, {section : this.id}), this);
  }

  , update_linked_controls_ccontrol_only : function() {
    this.linked_controls && this.linked_controls.replace(can.map(this.linked_controls, function(lc) {
      return new CMS.Models.Control(lc.serialize ? lc.serialize() : lc);
    }));
  }

  , update_linked_controls : function() {
    var lcs = new can.Model.List();
    var oldlinked = this.linked_controls.slice(0);
    while(oldlinked.length > 0) {
      //nasty hack -- assuming that RegControls are always listed before their respective implementing controls
      var oldrctl = oldlinked.shift();
      var rctl = null;
      if(oldrctl instanceof CMS.Models.RegControl || !(oldrctl instanceof CMS.Models.Control) ) 
        rctl = CMS.Models.RegControl.findInCacheById(oldrctl.id || oldrctl.control.id);
      if(rctl) {
        lcs.push(rctl);
        rctl.bind_section(this);
        can.each(rctl.implementing_controls, function(ctl) {
          var firstfound = false;
          lcs.push(CMS.Models.Control.findInCacheById(ctl.id || ctl.control.id));
          oldlinked = can.filter(can.makeArray(oldlinked), function(lctl) {
            if(firstfound) return true;
            firstfound = (lctl.id || lctl.control.id) === (ctl.id || ctl.control.id)
            return !firstfound
          })
        });
      }
    }    
    this.attr("linked_controls").replace(lcs);
  }

});

CMS.Models.Section("CMS.Models.SectionSlug", {
  update : function(id, section) {
    var param = this.process_args(
      section, 
      {not : [
        "parent_id"
        , "created_at"
        , "id"
        , "kind"
        , "modified_by_id"
        , "updated_at"
        , "linked_controls"
        , "description_inline"
        , "children"
        , "child_options"
      ]});
    return $.ajax({
      type : "PUT"
      , url : "/mapping/update/" + id + ".json"
      , dataType : "json"
      , data : param
    });
  }
  ,  findAll : function(params) {
    function filter_out(original, predicate) {
      var target = [];
      for(var i = original.length - 1; i >= 0; i--) {
        if(predicate(original[i])) {
          target.unshift(original.splice(i, 1)[0]);
        }
      }
      return target;
    }

    function treeify(list, directive_id, pid) {
      var ret = filter_out(list, function(s) { 
        return s.parent_id == pid && (!directive_id || s.directive_id === directive_id) 
      });
      can.$(ret).each(function() {
        this.children = treeify(list, this.directive_id, this.id);
      });
      return ret;
    }

    return this._super(params).pipe(
        function(list, xhr) {
          var current;
          can.$(list).each(function(i, s) {
            can.extend(s, s.section);
            delete s.section;
          });
          var roots = treeify(list); //empties the list if all roots (no parent in list) are actually roots (null parent id)
          // for(var i = 0; i < roots.length; i++)
          //   list.push(roots[i]);
          while(list.length > 0) {
            can.$(list).each(function(i, v) {
              // find a pseudo-root whose parent wasn't in the returned sections
              if(can.$(list).filter(function(j, c) { return c !== v && c.id === v.parent_id && c.directive_id === v.directive_id }).length < 1) {
                current = v;
                list.splice(i, 1); //remove current from list
                return false;
              }
            });
            current.attr ? current.attr("children", treeify(list, current.id)) : (children = treeify(list, current.id));
            roots.push(current);
          }
          return roots;
        });
  }
  , model : function(params) {
    var m = this._super(params);
    m.attr("children", this.models(m.children));
    return m;
  }
  , tree_view_options : {
    list_view : "/assets/sections/tree.mustache"
    , child_options : [{
      model : CMS.Models.Control
      , property : "linked_controls"
      , list_view : "/assets/controls/tree.mustache"
    }, {
      model : CMS.Models.SectionSlug
      , property : "children"
    }]
  }
  , init : function() {
    this._super.apply(this, arguments);
    this.tree_view_options.child_options[1].model = this;
  }
}, {});
