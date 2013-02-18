//= require can.jquery-all
//= require controls/control
//= require models/cacheable

can.Model.Cacheable("CMS.Models.Section", {
  root_object : "section"
  , findAll : "GET /sections.json"
  , update : function(id, section) {
    var param = {};
    can.each(section, function(val, key) {
      param["section[" + key + "]"] = val;
    });
    return $.ajax({
      type : "PUT"
      , url : "/mapping/update/" + id + ".json"
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
          }
          section.updated();
        }
      }
    });
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
  }

  , map_rcontrol : function(params) {
    return this.constructor.map_rcontrol(can.extend({}, params, {section : this.id}), this);
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
    this.attr("linked_controls", lcs);
  }

});

CMS.Models.Section("CMS.Models.SectionSlug", {
  findAll : function(params) {
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

    return can.ajax({ 
      url : "/directives/" + (params.id || false) + "/sections.json"
      , type : "get"
      , dataType : "json"
      , data : params
      }).then(
        function(list, xhr) {
          can.$(list).each(function(i, s) {
            can.extend(s, s.section);
            delete s.section;
          });
          var roots = treeify(list); //empties the list
          for(var i = 0; i < roots.length; i++)
            list.push(roots[i]);
        });
  }
}, {});
