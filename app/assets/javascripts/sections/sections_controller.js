//= require sections/section
//= require can.jquery-all

(function($) {

    can.Control("CMS.Controllers.Sections", {
	    //Static
	    defaults: {
		    list : "/sections/slug_tree.mustache"
		    , model : CMS.Models.SectionSlug
		    , id : ""
		    //, list_model : CMS.Models.Control.List
	    }
	    , properties : []
	}, {
	    init : function() {
			    this.fetch_list(this.options.id);
	    }
	    , fetch_list : function(parent_id) {
			this.options.model.findAll({ id : parent_id }, this.proxy("draw_list"));
	    }
	    , draw_list : function(list) {
	    	if(this.list) {

	    	} else {
	    		this.list = list;
	    		var x = can.view(this.options.list, {children : list , "id" : this.options.id });
		        this.element.html(x);
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