//= require controls/control
//= require controls/controls_controller
//= require sections/sections_controller
(function(namespace, $) {

can.Control("CMS.Controllers.Mapping", {
	//static
	cache : {}
}, {
	"#rmap, #cmap ajax:beforeSend" : function(el, evt, xhr, settings) {


	var lcs = mapper.attr("linked_controls");
	var data = $.deparam(settings.url.substr(settings.url.indexOf("?")));
   	var mapper = $(el).is("#rmap") ? this.class["selected_s_model"].attr("section") : this["selected_r_model"]
   	, mappee = this[$(el).is("#rmap") ? "selected_r_model" : "selected_c_model"];

       if(data) {
       		//unmap
       		var lcs = mapper.attr("linked_controls");
       		for(var i = 0; i < lcs.length; i++) {
       			if(lcs[i].control.id === mappee.id) {
       				lcs.splice(i, 1);
       				break;
       			}
       		}
       } else {
       		//map
       		lcs.push(new can.Observe({"control" : mappee}));
       }
       return true;
    }

});


$(function() {
	var mapcache = { init : function() {
			this._super();
			var cache = CMS.Controllers.Mapping.cache
			,   c = can.getObject(this.constructor.cache, cache, true);

			if(!c[this.id])
				c[this.id] = this;
			else
				c[this.id].updated(this);
		}
	};

	CMS.Models.RegControl("CMS.Models.RegControlWithCache", {cache : "Control"}, mapcache);
	CMS.Models.Control("CMS.Models.CompanyControlWithCache", {cache : "Control"}, mapcache);
	CMS.Models.SectionSlug("CMS.Models.SectionWithCache", {cache : "Section"}, mapcache);

	var programId = namespace.location.pathname.substr(window.location.pathname.lastIndexOf("/") + 1);

	// The following uncommented line is equivalent to doing its preceding commented line, but we have a jQuery CanJS helpers option added:
    //CMS.Controllers.Controls.Instances = { Control : new CMS.Controllers.Controls('#controls', { arity : 2 })};
    can.extend(
    	can.getObject("CMS.Controllers.Controls.Instances", namespace, true)
    	, { 
    		Control : $("#rcontrol_list .WidgetBoxContent").cms_controllers_controls({ 
    			arity : 2 
    			, list: "/controls/list_mapping.mustache"
    			, model : CMS.Models.RegControlWithCache
    			, id : programId }).control()
    		, CompanyControl : $("#ccontrol_list .WidgetBoxContent").cms_controllers_controls({ 
    			arity : 2
    			, list: "/controls/list_mapping.mustache"
    			, model : CMS.Models.CompanyControlWithCache }).control()
    	});

    can.getObject("CMS.Controllers.Sections.Instances", namespace, true).Section 
    	= $("#section_list .WidgetBoxContent").cms_controllers_sections({
				id : programId
				, model : CMS.Models.SectionWithCache
    		}).control();

    can.getObject("CMS.Controllers.Mapping.Instances", namespace, true).Mapping = $(".graphpaper").cms_controllers_mapping({}).control();
});


})(this, jQuery);