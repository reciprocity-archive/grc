//= require directives/routes_controller
(function(namespace, $) {

var directive_id = namespace.location.pathname.substr(window.location.pathname.lastIndexOf("/") + 1);

//Note that this also applies to programs
jQuery(function($) { 
  $("body").on("click", "a.controllist", function(ev) {
    var $dialog = $("#mapping_dialog");
    var id = $(ev.target).closest("[data-id]").data("id")
    if(!$dialog.length) {
      $dialog = $('<div id="mapping_dialog" class="modal modal-selector hide"></div>')
        .appendTo(document.body)
        .draggable({ handle: '.modal-header' });
    }
    $dialog.modal("show");

    (CMS.Models.Section.findInCacheById(id) 
      ? $.when(CMS.Models.Section.findInCacheById(id)) 
      : CMS.Models.Section.findAll())
    .done(function(section) {
      $dialog.cms_controllers_control_mapping_popup({
        section : $(section).filter(function(i, d) { return d.id == id })[0]
        , parent_model : $(document.body).attr("data-page-type") === "directives" ? CMS.Models.Directive : CMS.Models.Program
        , parent_id : directive_id
      });
      $(ev.target).trigger('kill-all-popovers');
    });
  });
});


if (!/\/directives\b/.test(window.location.pathname))
  return;

$(function() {
    CMS.Controllers.DirectiveRoutes.Instances = {
      Control : $(document.body).cms_controllers_directive_routes({}).control(CMS.Controllers.DirectiveRoutes)};
});

})(this, jQuery);
