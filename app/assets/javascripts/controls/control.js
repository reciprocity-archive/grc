//= require can.jquery-all
can.Model("CMS.Models.Control", {
	// static properties
	findAll : "GET /controls.json"
	, findOne : "GET /controls/{id}.json"
    }
    , {
	// prototype properties
		init : function() {
			this.attr((this.control ? "control." : "") + "content_id", Math.floor(Math.random() * 10000000));
			this.attr((this.control ? "control." : "") + "type", "company");
			if(this.control) {
				var attrs = this.control._attrs();
				for(var i in attrs) {
					if(attrs.hasOwnProperty(i)) {
						this.attr(i, this.control[i]);
					}
				}
				this.removeAttr("control");
			}
			this.attr("selected", false);
		}
    });

// This creates a subclass of the Control model
CMS.Models.Control("CMS.Models.ImplementedControl", {
	findAll : "GET /controls/{id}/implemented_controls.json"
}, {
	init : function() {
		this._super();
		if(!this.children) this.children = this.implemented_controls;
	}
});

// This creates a subclass of the Control model
CMS.Models.Control("CMS.Models.RegControl", {
	findAll : "GET /programs/{id}/controls.json"
}, {
	init : function() {
		this._super();
		this.attr((this.control ? "control." : "") + "type", "regulation");
	}
});