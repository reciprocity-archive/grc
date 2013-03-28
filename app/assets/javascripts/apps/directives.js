//= require directives/routes_controller
//= require mapping/mapping_controller
//= require models/simple_models
(function(namespace, $) {

var directive_id = namespace.location.pathname.substr(window.location.pathname.lastIndexOf("/") + 1);

function getPageModel() {
  if($(document.body).attr("data-page-type") === "directives") { 
    switch($(document.body).attr("data-page-subtype")) {
      case "regulations" :
        return CMS.Models.Regulation;
      case "policies" :
        return CMS.Models.Policy;
      case "contracts" :
        return CMS.Models.Contract;
      default :
        return CMS.Models.Directive;
    }
  } else { 
    return CMS.Models.Program;
  }
}

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
    $dialog.html($(new Spinner().spin().el).css({"position" : "relative", "left" : 50, "top" : 50, "height": 150, "width": 150}));
    $dialog.modal("show");

    (CMS.Models.Section.findInCacheById(id) 
      ? $.when(CMS.Models.Section.findInCacheById(id)) 
      : CMS.Models.Section.findAll())
    .done(function(section) {
      $dialog.cms_controllers_control_mapping_popup({
        section : $(section).filter(function(i, d) { return d.id == id })[0]
        , parent_model : getPageModel()
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
