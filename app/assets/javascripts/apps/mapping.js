//= require controls/control
//= require controls/controls_controller
//= require sections/sections_controller
(function(namespace, $) {

can.Control("CMS.Controllers.Mapping", {
	//static
	cache : {}
}, {
	"#rmap, #cmap ajax:beforeSend" : function(el, evt, xhr, settings) {

  	var lcs = mapper.attr("linked_controls")
  	, data = $.deparam(settings.url.substr(settings.url.indexOf("?")))
    , mapper = $(el).is("#rmap") ? this.class["selected_s_model"].attr("section") : this["selected_r_model"]
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

  , "#rcontrol_list .regulationslot click" : function(el, ev) {
    CMS.Controllers.Controls.Instances.SelectedRegControl.update({ instance : el.closest("[data-model]").data("model") });
    this.updateButtons();
    ev.preventDefault();
  }

  , "#ccontrol_list .regulationslot click" : function(el, ev) {
    CMS.Controllers.Controls.Instances.SelectedCompanyControl.update({ instance : el.closest("[data-model]").data("model") });
    this.updateButtons();
    ev.preventDefault();
  }

  , "#section_list .regulationslot click" : function(el, ev) {
    CMS.Controllers.Sections.Instances.SelectedSection.update({ instance : el.closest("[data-model]").data("model") });
    this.updateButtons();
    ev.preventDefault();
  }

  , updateButtons : function(ev, oldVal, newVal) {
    var section = $("#selected_sections").control(CMS.Controllers.Sections).options.instance;
    var rcontrol = $("#selected_rcontrol").control(CMS.Controllers.Controls).options.instance;
    var ccontrol = $("#selected_ccontrol").control(CMS.Controllers.Controls).options.instance;
    var qstr = '?' + $.param({section: can.getObject("id", section), rcontrol: can.getObject("id", rcontrol), ccontrol: can.getObject("id", ccontrol)});

    var rmap = $('#rmap');
    var cmap = $('#cmap');

    rmap.attr('disabled', !(section && (rcontrol || ccontrol)));
    if (!(section && (rcontrol || ccontrol))) {
      rmap.children(':first').text('Map section to control');
    }
    cmap.attr('disabled', !(rcontrol && ccontrol));
    if (!(rcontrol && ccontrol)) {
      cmap.children(':first').text('Map control to control');
    }

    if ((section && (rcontrol || ccontrol)) || (rcontrol && ccontrol)) {
          var rmap_text = $(rmap.children()[0]);
          var cmap_text = $(cmap.children()[0]);
          var runmap = section && rcontrol ? $(section.linked_controls).filter(function() { return this.id  === rcontrol.id}).length : false;
              runmap || (runmap = section && ccontrol ? $(section.linked_controls).filter(function() { return this.id === ccontrol.id}).length : false);
          var cunmap = rcontrol && ccontrol ? $(rcontrol.implemented_controls).filter(function() { return this.id === ccontrol.id}).length : false;

          rmap_text.text(runmap ? 'Unmap' : 'Map section to control')
          rmap.attr('href', rmap.attr('href').split('?')[0] + qstr + (runmap ? '&u=1' : ""));
          cmap_text.text(cunmap ? 'Unmap' : 'Map control to control')
          cmap.attr('href', cmap.attr('href').split('?')[0] + qstr + (cunmap ? '&u=1' : ""));
    }
  }
    , ".clearselection click" : function(el, ev) {
      this.updateButtons();
    }

});

can.Control("CMS.Controllers.MappingWidgets", {}, {

  ".clearselection click" : function(el, ev) {
    var controllers = this.element.find(".cms_controllers_controls, .cms_controllers_sections").controls(CMS.Controllers.Controls);
    $(controllers).each(function() {
      if(this.options.arity === 1) {
        this.update({instance : null});
      } else {
        this.setSelected(null);
      }
    });
  }

});


	var programId = namespace.location.pathname.substr(window.location.pathname.lastIndexOf("/") + 1);

	// The following uncommented line is equivalent to doing its preceding commented line, but we have a jQuery CanJS helpers option added:
    //CMS.Controllers.Controls.Instances = { Control : new CMS.Controllers.Controls('#controls', { arity : 2 })};
    $(function() {
      //control lists aren't ready yet.
      can.extend(
      	can.getObject("CMS.Controllers.Controls.Instances", namespace, true)
      	, { 
      		RegControls : $("#rcontrol_list .WidgetBoxContent").cms_controllers_controls({ 
      			arity : 2 
      			, list: "/controls/list_mapping.mustache"
      			, model : CMS.Models.RegControl
      			, id : programId }).control()
      		, CompanyControls : $("#ccontrol_list .WidgetBoxContent").cms_controllers_controls({ 
      			arity : 2
      			, list: "/controls/list_mapping.mustache"
      			, model : CMS.Models.CompanyControl }).control()
          , SelectedRegControl : $("#selected_rcontrol").cms_controllers_controls({ 
            arity : 1 
            , show: "/controls/show_selected.mustache"
            , model : CMS.Models.RegControl }).control()
          , SelectedCompanyControl : $("#selected_ccontrol").cms_controllers_controls({ 
            arity : 1 
            , show: "/controls/show_selected.mustache"
            , model : CMS.Models.CompanyControl }).control()
      	});

        CMS.Controllers.MappingWidgets.Instances = {
          RegControls : $("#rcontrol_list").parent().cms_controllers_mapping_widgets({}).control()
          , CompanyControls : $("#ccontrol_list").parent().cms_controllers_mapping_widgets({}).control()
          , Sections : $("#section_list").parent().cms_controllers_mapping_widgets({}).control()
        };

        can.extend(
          can.getObject("CMS.Controllers.Sections.Instances", namespace, true)
          , {
            Section : $("#section_list .WidgetBoxContent").cms_controllers_sections({
			 	      id : programId
				      }).control()
            , SelectedSection : $("#selected_sections").cms_controllers_sections({
              arity : 1
              , show : "/sections/show_selected.mustache"
              }).control()
          });

      can.getObject("CMS.Controllers.Mapping.Instances", namespace, true).Mapping = $(document.body).cms_controllers_mapping({}).control();
    });

})(this, jQuery);