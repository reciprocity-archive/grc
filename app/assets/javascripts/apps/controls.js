//= require controls/control
//= require controls/controls_controller
(function(namespace, $) {

$(function() {
	// The following uncommented line is equivalent to doing its preceding commented line, but we have a jQuery CanJS helpers option added:
    //CMS.Controllers.Controls.Instances = { Control : new CMS.Controllers.Controls('#controls', { arity : 2 })};
    CMS.Controllers.Controls.Instances = { Control : $("#controls").cms_controllers_controls({ arity : 2 })};
});

})(this, jQuery);