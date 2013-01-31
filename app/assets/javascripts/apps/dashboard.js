//= require resize_widgets_controller
(function(namespace, $) {

// Explicitly short circuit until handling of implemented/implementing controls
// is complete.

if (!/\/programs_dash\b/.test(window.location.pathname))
  return;

$(function() {
    CMS.Controllers.ResizeWidgets.Instances = { 
      Body : $(document.body)
              .cms_controllers_resize_widgets({
                containers : [$("#columns")]
              }).control(CMS.Controllers.ResizeWidgets)};
});

})(this, jQuery);