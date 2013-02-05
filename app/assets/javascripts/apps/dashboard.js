//= require controllers/resize_widgets_controller
//= require controllers/sortable_widgets_controller

(function(namespace, $) {

$(function() {

  CMS.Models.DisplayPrefs.findAll().done(function(data) {

    function bindResizer(ev) {

        can.getObject("Instances", CMS.Controllers.ResizeWidgets, true)[this.id] = 
         $(this)
          .cms_controllers_resize_widgets({
            model : data[0]
          }).control(CMS.Controllers.ResizeWidgets);

    }
    $(".row-fluid[id][data-resize]").each(bindResizer);//get anything that exists on the page already.

    //Then listen for new ones
    $(document.body).on("mouseover", ".row-fluid[id][data-resize]:not(.cms_controllers_resize_widgets)", bindResizer);


    function bindSortable(ev) {
        can.getObject("Instances", CMS.Controllers.SortableWidgets, true)[this.id] = 
         $(this)
          .cms_controllers_sortable_widgets({
            model : data[0]
          }).control(CMS.Controllers.SortableWidgets);    
    }
    $(".widget-area").each(bindSortable);//get anything that exists on the page already.
    //we will need to consider whether to look for late-added ones later.
  });

});

})(this, jQuery);