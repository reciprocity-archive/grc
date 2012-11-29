//= require control
//= require can.custom

(function($) {

    can.Control("CMS.Controllers.Controls", {
	    //Static
	    defaults: {
		    arity: 2
		    , list : "list.mustache"
		    , show : "show.mustache"
		    , model : CMS.Models.Control
		    //, list_model : CMS.Models.Control.List
	    }
	    , properties : []
	}, {
	    init : function() {
			if(this.options.arity > 1) {
			    this.fetch_list();
			} else {
			    this.fetch_one(this.options.id);
			}
	    }
	    , fetch_list : function() {
			this.options.model.findAll({}, this.proxy("draw_list"));
	    }
	    , draw_list : function(list) {
	    	if(this.list) {

	    	} else {
	    		this.list = list;
	    		var x = can.view(this.options.list, $.extend(list, { show : this.options.show }));
		        this.element.html(x);
	    	}
	    }
	    , fetch_one : function(id) {
			this.options.model.findOne({ id : id }, this.proxy("draw_one", this.element));
	    }
	    , draw_one : function(control, el) {
	    	if(this.list) {
	    		this.update_item(control);
	    	} else {
				var v = can.view(this.options.show, control);
				el.length ? el.html(v) : this.element.append(v);
			}
	    }
	    , update_item : function(item) {
	    	var that = this;
	    	for(var i = 0; i < this.list.length; i++) {
	    		if(this.list[i].id === item.id) {
	    			$(this.Class.properties).each(function(index, prop) {
		    			that.list[i].attr(prop, item.attr(prop));
	    			});
	    		}
	    	}
	    }


    });

})(jQuery)