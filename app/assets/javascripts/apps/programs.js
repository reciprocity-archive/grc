//= require programs/routes_controller
(function(namespace, $) {

// Explicitly short circuit until handling of implemented/implementing controls
// is complete.

if (!/\/programs/.test(window.location.pathname))
  return;

$(function() {
    CMS.Controllers.ProgramRoutes.Instances = { 
      Control : $(document.body).cms_controllers_program_routes({}).control(CMS.Controllers.ProgramRoutes)};
});

})(this, jQuery);
