//= require can.jquery-all

can.Control("CMS.Controllers.AddWidget", {
  defaults : {
    widget_descriptors : null
  }
}, {
  
  ".dropdown-menu > * click" : function(el, ev) {
    var descriptor = this.options.widget_descriptors[el.attr("class")];
    if(descriptor && !$("#" + descriptor.object_type + "_list_widget").length) {
      $("<section class='widget'>").insertBefore(this.element).cms_controllers_dashboard_widgets(descriptor);
    }
  }

})