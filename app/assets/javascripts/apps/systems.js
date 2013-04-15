//= require can.jquery-all

(function(can, $) {

if(!/^\/systems\/\d+/.test(window.location.pathname))
 return;

var system_id = /^\/systems\/(\d+)/.exec(window.location.pathname)[1];

$(function() {
  
  var $top_tree = $("#system_sub_systems_widget .tree-structure").cms_controllers_tree_view({
    model : CMS.Models.System
    , single_object : true
    , find_params : { id : system_id }
  });

  $(document.body).on("modal:success", ".link-objects", function(ev, data) {
    $top_tree.trigger("linkObject", $.extend($(this).data(), {
      parentId : system_id
      , data : data
    }));

  });


});

})(window.can, window.can.$);