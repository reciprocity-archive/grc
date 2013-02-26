//= require can.jquery-all
//= require controllers/quick_search_controller
(function(namespace, $) {

$(function() {

  function bindQuickSearch(ev) {

    var $qs = $(this).uniqueId();
    var obs = new can.Observe();
    $qs.bind("keypress", "input.widgetsearch", function(ev) {
      if(ev.which === 13)
        obs.attr("value", $(ev.target).val());
    });
    can.getObject("Instances", CMS.Controllers.QuickSearch, true)[$qs.attr("id")] = 
     $qs.find(".quick-search-results, section.content")
      .cms_controllers_quick_search({
        observer : obs
      }).control(CMS.Controllers.QuickSearch);

  }
  $(".quick-search, section.widget-tabs").each(bindQuickSearch);//get anything that exists on the page already.

  //Then listen for new ones
  $(document.body).on("click", ".quick-search:not(:has(.cms_controllers_quick_search)), section.widget-tabs:not(:has(.cms_controllers_quick_search))", bindQuickSearch);

});

})(this, jQuery);