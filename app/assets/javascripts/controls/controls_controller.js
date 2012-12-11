//= require controls/control
//= require can.jquery-all

(function($) {

    can.Control("CMS.Controllers.Controls", {
	    //Static
	    defaults: {
		    arity: 2
		    , list : "/controls/list.mustache"
		    , show : "/controls/show.mustache"
		    , model : CMS.Models.Control
		    , id : null
		    //, list_model : CMS.Models.Control.List
	    }
	    , properties : []
	}, {
	    init : function() {
			if(this.options.arity > 1) {
			    this.fetch_list(this.options.id);
			} else {
				var el = this.element;
				this.options.observer = new can.Observe();

				//this should be in the controller def as "{observer} model"
				// but CanJS is throwing errors when I try to do that.  --BM
			    this.options.observer.bind("model", function(ev, newVal, oldVal) {
	    			el.attr("oid", newVal ? newVal.id : "");
	    		});


				if(this.options.id) {
				    this.fetch_one(this.options.id);
				} else {
					this.draw_one(null)
				}
			}
	    }
	    , update : function(opt) {
	    	this._super(opt);
	    	if(this.options.arity === 1 && this.options.instance !== this.options.observer.model) {
	    		this.draw_one(this.options.instance);
	    		this.element.attr("oid", can.getObject("id", this.options.instance) || "");
	    	}
	    }
	    , fetch_list : function() {
			this.options.model.findAll({ id : this.options.id }, this.proxy("draw_list"));
	    }
	    , draw_list : function(list) {
	    	if(this.list) {

	    	} else {
	    		this.list = list;
	    		var x = can.view(this.options.list, $.extend(this.list, { show : this.options.show }));
		        this.element.html(x);
	    	}
	    }
	    , fetch_one : function(id) {
			this.options.model.findOne({ id : (id || this.options.id) }, this.proxy("draw_one"));
	    }
	    , draw_one : function(control) {
	    	if(typeof this.options.observer.model !== "undefined") {
	    		this.options.observer.attr("model", control);
	    	} else {
	    		this.options.observer.attr("model", control);
				var v = can.view(this.options.show, this.options.observer);
				this.element.html(v);
			}
	    }
	    , ". update" : function(el, ev, data) {
	    	this.update(data);
	    }
	    , setSelected : function(obj) {
	    	if(this.options.arity > 1) {
	    		if(!obj instanceof this.options.model) {
	    			obj = $(this.list).filter(function() {
	    				var id = obj.id || obj;
	    				return id && this.id === id;
	    			}).first();
	    		}

	    		$(this.list).each(function() {
	    			this.attr("selected", $(obj)[0] === this );
	    		});
	    	}
	    }
	    , ".selector click" : function(el, ev) {
	    	this.setSelected(el.closest("[data-model]").data("model"));
	    }

    });

})(can.$);