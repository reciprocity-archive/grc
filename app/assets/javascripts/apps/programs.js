//= require can.jquery-all
//= require controllers/tree_view_controller
//= require controls/control
//= require controls/category

(function(can, $) {

if(!/^\/programs\/\d+/.test(window.location.pathname))
 return;

var program_id = /^\/programs\/(\d+)/.exec(window.location.pathname)[1];
var spin_opts = { position : "absolute", top : 100, left : 100, height : 50, width : 50 };

$(function() {
  
  var $controls_tree = $("#controls .tree-structure").append($(new Spinner().spin().el).css(spin_opts));
  $.when(
    CMS.Models.Category.findAll()
    , CMS.Models.Control.findAll({ program_id : program_id })
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

  var $sections_tree = $("#directives .tree-structure").append($(new Spinner().spin().el).css(spin_opts));
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

    $sections_tree.cms_controllers_tree_view({
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
    var c = new CMS.Models.Control(data);
    $("a[href='#controls']").click();
      can.each(c.category_ids.length ? c.category_ids : [-1], function(catid) {
        $controls_tree.find("[data-object-id=" + catid + "] > .item-content > ul[data-object-type=control]").trigger("newChild", c);
      });
  });

  $(document.body).on("modal:success", "a[href^='/program_directives/list_edit']", function(ev, data) {
    $("a[href='#directives']").click();
    directives_by_type[$(this).data("child-meta-type")] = data;
    $sections_tree.trigger("linkObject", $.extend($(this).data(), {
      data : directives_by_type.regulation.concat(directives_by_type.contract).concat(directives_by_type.policy)
    }))
  });

});

})(window.can, window.can.$);