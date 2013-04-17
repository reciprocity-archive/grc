//= require can.jquery-all
//= require controllers/tree_view_controller
//= require controls/control
// TODO require controls/category

(function(can, $) {

if(!/^\/programs\/\d+/.test(window.location.pathname))
 return;

var program_id = /^\/programs\/(\d+)/.exec(window.location.pathname)[1];

$(function() {
  
  // var $controls_tree = $("#controls .tree-structure").cms_controllers_tree_view({
  //   model : CMS.Models.Category

  //   , child_options : [{      
  //     model : CMS.Models.Control
  //     , find_params : { program_id : program_id }
  //     , list_view : "/assets/controls/categories_tree.mustache"
  //   }]
  // });

  var directives_by_type = {
    regulation : []
    , contract : []
    , policy : []
  }

  can.each(directives_by_type, function(v, k) {
    can.ajax({url : "/program_directives.json", data : { directive_meta_kind : k , program_id : program_id }})
    .done(function(d) {
      directives_by_type[k] = d;
    });
  });

  var $sections_tree;
  $.when(
    CMS.Models.SectionSlug.findAll()
    , CMS.Models.Directive.findAll({ program_id : program_id })
  ).done(function(s, d) {
    
    d.each(function(dir) {
      dir.attr("sections", new can.Observe.List());
    })
    s.each(function(sec) {
      CMS.Models.Directive.findInCacheById(sec.directive_id).sections.push(sec);
    });

    $sections_tree = $("#directives .tree-structure").cms_controllers_tree_view({
      model : CMS.Models.Directive
      , list : d
      , list_view : "/assets/directives/tree.mustache"
      , child_options : [{
        model : CMS.Models.SectionSlug
        , property : "sections"
      }]
    });
  });

  $(document.body).on("modal:success", "a[href^='/controls/new']", function(ev, data) {
    $controls_tree.control().options.list.push(new CMS.Models.Control(data));
  });

  $(document.body).on("modal:success", "a[href^='/program_directives/list_edit']", function(ev, data) {
    directives_by_type[$(this).data("child-meta-type")] = data;
    $sections_tree.trigger("linkObject", $.extend($(this).data(), {
      data : directives_by_type.regulation.concat(directives_by_type.contract).concat(directives_by_type.policy)
    }))
  });

});

})(window.can, window.can.$);