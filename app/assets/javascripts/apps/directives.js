//= require directives/routes_controller
(function(namespace, $) {

// Explicitly short circuit until handling of implemented/implementing controls
// is complete.

if (!/\/directives\b/.test(window.location.pathname))
  return;

$(function() {
    CMS.Controllers.DirectiveRoutes.Instances = {
      Control : $(document.body).cms_controllers_directive_routes({}).control(CMS.Controllers.DirectiveRoutes)};
});

})(this, jQuery);
