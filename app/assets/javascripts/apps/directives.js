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

    (CMS.Models.SectionSlug.findInCacheById(id) 
      ? $.when(CMS.Models.SectionSlug.findInCacheById(id)) 
      : CMS.Models.SectionSlug.findAll())
    .done(function(section) {
      $dialog.cms_controllers_control_mapping_popup({
        section : $(section).filter(function(i, d) { return d.id == id })[0]
        , parent_model : getPageModel()
        , parent_id : directive_id
      });
      $(ev.target).trigger('kill-all-popovers');
    });
  });

  CMS.Controllers.DirectiveRoutes.Instances = {
    Control : $(document.body).cms_controllers_directive_routes({}).control(CMS.Controllers.DirectiveRoutes)};
});


if (!/\/directives\b/.test(window.location.pathname))
  return;

$(function() {
  var spin_opts = { position : "absolute", top : 100, left : 100, height : 50, width : 50};


  var $controls_tree = $("#controls .tree-structure").append($(new Spinner().spin().el).css(spin_opts));
  $.when(
    CMS.Models.Category.findAll()
    , CMS.Models.Control.findAll({ directive_id : directive_id })
  ).done(function(cats, ctls) {
    var uncategorized = cats[cats.length - 1];
    can.each(ctls, function(c) {
      if(c.category_ids.length < 1) {
        uncategorized.linked_controls.push(c);
      }
      can.each(c.category_ids, function(id) {
        CMS.Models.Category.findInCacheById(id).linked_controls.push(c);
      });
    })

    $controls_tree.cms_controllers_tree_view({
      model : CMS.Models.Category
      , list : cats
    });
  });

  var $sections_tree = $("#sections .tree-structure").append($(new Spinner().spin().el).css(spin_opts));

  CMS.Models.SectionSlug.findAll({ directive_id : directive_id })
  .done(function(s) {
    
    $sections_tree.cms_controllers_tree_view({
      model : CMS.Models.SectionSlug
      , edit_sections : true
      , list : s
      , list_view : "/assets/sections/tree.mustache"
    });
  });

  $(document.body).on("modal:success", "a[href^='/controls/new']", function(ev, data) {
    var c = new CMS.Models.Control(data);
    $("a[href='#controls']").click();
      can.each(c.category_ids.length ? c.category_ids : [-1], function(catid) {
        $controls_tree.find("[data-object-id=" + catid + "] > .item-content > ul[data-object-type=control]").trigger("newChild", c);
      });
  });

  $(document.body).on("modal:success", "a[href^='/sections'][href$='/edit']", function(ev, data) {
    CMS.Models.SectionSlug.model(data);
  });

  $(document.body).on("modal:success", "a[href^='/sections/new']", function(ev, data) {
    var c = new CMS.Models.SectionSlug(data)
    , p;
    $("a[href='#sections']").click();

    if(c.parent_id && (p = CMS.Models.SectionSlug.findInCacheById(c.parent_id))) {
      $sections_tree.control().add_child_lists([c]);
      p.children.push(c);
    } else {
      $sections_tree.trigger("newChild", c);
    }

  });

});

})(this, jQuery);
