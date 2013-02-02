//= require resize_widgets_controller
(function(namespace, $) {

$(function() {

  function bindResizer(ev) {

      can.getObject("Instances", CMS.Controllers.ResizeWidgets, true)[this.id] = 
       $(this)
        .cms_controllers_resize_widgets({}).control(CMS.Controllers.ResizeWidgets);

  }
  $(".row-fluid[id][data-resize]").each(bindResizer);//get anything that exists on the page already.

  //Then listen for new ones
  $(document.body).on("mouseover", ".row-fluid[id][data-resize]:not(.cms_controllers_resize_widgets)", bindResizer);

});

})(this, jQuery);