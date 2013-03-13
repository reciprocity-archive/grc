//= require sections/section
//= require can.jquery-all

(function($) {
	//Sections listing and showing is pretty much the same as that of controls,
	// so subclass it with different defaults
    CMS.Controllers.Controls("CMS.Controllers.Sections", {
	    //Static
	    defaults: {
		    list : "/assets/sections/slug_tree.mustache"
		    , model : CMS.Models.SectionSlug
		    , id : ""
	    }
	    , properties : []
	}, {
	    draw_list : function(list) {
	    	if(list) {
	    		this.list = list;
          list.sort(window.natural_comparator);
	    	}
    		var x = can.view(this.options.list, {children : this.list , "id" : this.options.id });
	        this.element.html(x);

	    }
	    , setSelected : function(obj) {
	    	if(this.options.arity > 1) {
	    		if(!obj instanceof this.options.model) {
	    			obj = $(this.list).filter(function() {
	    				var id = obj.id || obj;
	    				return id && this.id === id;
	    			}).first();
	    		}

	    		function treetraverse() {
	    			$(this.children).each(function() {
	    				this.attr("selected", $(obj)[0] === this );
	    				treetraverse.apply(this);
	    			})
	    		}

	    		$(this.list).each(function() {
	    			this.attr("selected", $(obj)[0] === this );
		    		treetraverse.apply(this);
	    		});
	    	}
	    }
    });

})(jQuery)
