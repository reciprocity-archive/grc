//= require can.jquery-all
//= require mapping/mapping_controller
//= require controls/control
//= require controls/controls_controller
//= require sections/sections_controller
(function(namespace, $) {



	var programId = namespace.location.pathname.substr(window.location.pathname.lastIndexOf("/") + 1);

  if(!/\/mapping/.test(window.location.pathname))
    return;

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

})(this, can.$);