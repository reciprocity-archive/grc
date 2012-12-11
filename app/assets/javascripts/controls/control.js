//= require can.jquery-all
//= require models/cacheable
(function(namespace, $){
can.Model.Cacheable("CMS.Models.Control", {
	// static properties
	findAll : "GET /controls.json"
	, findOne : "GET /controls/{id}.json"
}
, {
// prototype properties
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
		this.attr({
			"content_id" : Math.floor(Math.random() * 10000000)
			, "type" : "company"
			, "selected" : false
		});
		this._super();
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
					if(params.u) {
						//unmap
						can.each(control.implementing_controls, function(val, i) {
							if(params.ccontrol === val.id) {
								control.implementing_controls.splice(i, 1);
							}
						});
					} else {
						//map
						control.implementing_controls.push(
							new CMS.Models.ImplementingControl(
								CMS.Models.Control.findInCacheById(params.ccontrol).serialize()
								));
					}
					control.updated();
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