//= require can.jquery-all
//= require models/cacheable
(function(namespace, $){
can.Model.Cacheable("CMS.Models.Control", {
  // static properties
    root_object : "control"
  , findAll : "GET /controls.json"
  , findOne : "GET /controls/{id}.json"
  , update : function(id, params) {
    return $.ajax({
      url : "/controls/" + id + ".json"
      , type : "put"
      , data : this.process_args(params, ["notes", "title", "description"])
    })
  }
  // , model : function(attrs) {
  //   var id;
  //   if((id = attrs.id || (attrs[this.root_object] && attrs[this.root_object].id)) && this.findInCacheById(id)) {
  //     return this.findInCacheById(id);
  //   } else {
  //     return this._super.apply(this, arguments);
  //   }
  // }
}
, {
// prototype properties
  init : function() {
        // This block now covered in the Cacheable model
    // if(this.control) {
    //  var attrs = this.control._attrs();
    //  for(var i in attrs) {
    //    if(attrs.hasOwnProperty(i)) {
    //      this.attr(i, this.control[i]);
    //    }
    //  }
    //  this.removeAttr("control");
    // }
    this.attr({
      "content_id" : Math.floor(Math.random() * 10000000)
      , "type" : "company"
      , "selected" : false
    });
    this._super();
  }

  , bind_section : function(section) {
    var that = this;
    this.bind("change.section" + section.id, function(ev, attr, how, newVal, oldVal) {
      if(attr !== 'implementing_controls')
        return;

      var oldValIds = can.map(can.makeArray(oldVal), function(val) { return val.id; });

      if(how === "add" || (how === "set" && newVal.length > oldVal.length)) {
        can.each(newVal, function(el) {
          if($.inArray(el.id, oldValIds) < 0) {
            section.addElementToChildList("linked_controls", CMS.Models.Control.findInCacheById(el.id));
          }
        });
      } else {
        var lcs = section.linked_controls.slice(0);
        can.each(oldVal, function(el) {
          if($.inArray(el, newVal) < 0) {
            lcs.splice($.inArray(el, lcs), 1);
          }
        });
        section.attr(
          "linked_controls"
          , lcs
        );
      }
    });
  }
  , unbind_section : function(section) {
    this.unbind("change.section" + section.id);
  }
});

// This creates a subclass of the Control model
CMS.Models.Control("CMS.Models.ImplementedControl", {
	findAll : "GET /controls/{id}/implemented_controls.json"
}, {
	init : function() {
		if(this.control) {
			var attrs = this.control._attrs();
			for(var i in attrs) {
				if(attrs.hasOwnProperty(i)) {
					this.attr(i, this.control[i]);
				}
			}
			this.removeAttr("control");
		}
		this._super();
	}
});

/*
	Note: This is kind of a hack.  I would like to revisit the structure of the control models later
	in order to just pull the linked ones out of cache, but it takes some clever finagling with
	$.Deferred and it's too much work to think through at the moment.  In the meantime, implementing
	controls as a separate model from Regulation or Company controls works for my needs (comparing IDs)
	--BM 12/10/2012
*/
CMS.Models.ImplementedControl("CMS.Models.ImplementingControl", {
	findAll : "GET /controls/{id}/implementing_controls.json"
}, {});


// This creates a subclass of the Control model
CMS.Models.Control("CMS.Models.RegControl", {
	findAll : "GET /programs/{id}/controls.json"
	, map_ccontrol : function(params, control) {
		return can.ajax({
			url : "/mapping/map_ccontrol"
			, data : params
			, type : "post"
			, dataType : "json"
			, success : function() {
				if(control) {
					var ics;
					if(params.u) {
						//unmap
						ics = new can.Model.List();
						can.each(control.implementing_controls, function(ctl) {
                            //TODO : Put removal functionality into the Cacheable, in the vein of addElementToChildList,
                            //  and update this code to simply remove the unmap code.
                            //We are needing to manually trigger changes in Model.List due to CanJS being unable to
                            //  trigger template changes for lists automatically.
							if(ctl.id !== params.ccontrol)
							{
								ics.push(ctl);
							}
        					control.attr("implementing_controls", ics);
        					control.updated();
                        });
                    } else {
                        //map
                        control.addElementToChildList("implementing_controls", CMS.Models.Control.findInCacheById(params.ccontrol));
                    }
				}
			}
		});
	}
}, {
	init : function() {
		this._super();
		this.attr((this.control ? "control." : "") + "type", "regulation");
		var impls = new can.Model.List();
		can.each(this.implementing_controls, function(val, i) {
			impls.push(new CMS.Models.ImplementingControl(val.serialize()));
		});
		this.attr("implementing_controls", impls);
	}
	, map_ccontrol : function(params) {
		return this.constructor.map_ccontrol(can.extend({}, params, {rcontrol : this.id}), this);
	}

});

})(this, can.$)
