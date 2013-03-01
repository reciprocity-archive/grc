//= require can.jquery-all

can.Control("CMS.Controllers.AddWidget", {
  defaults : {
    widget_descriptors : null
    , minimum_widget_height : 100
  }
}, {
  
  ".dropdown-menu > * click" : function(el, ev) {
    var descriptor = this.options.widget_descriptors[el.attr("class")];
    this.addWidgetByDescriptor(descriptor);
  }

  , ".dropdown-toggle click" : function() {
      setTimeout(this.proxy("repositionMenu"), 10);
    }
  , "{window} resize" : "repositionMenu"
  , "{window} scroll" : "repositionMenu"

  , repositionMenu : function(el, ev) {
    var $dropdown = this.element.find(".dropdown-menu:visible")
    if(!$dropdown.length) 
      return;

    $dropdown.css({"position" : "", "top" : "", "bottom" : "" });
    if($dropdown.offset().top < window.scrollY) {
      $dropdown.css({
        "position" : "absolute"
        , "top" : window.scrollY - this.element.find(".dropdown-toggle").offset().top
        , "bottom" : $(".dropdown-menu:visible").css("bottom", -window.scrollY - 443 + this.element.find(".dropdown-toggle").offset().top - this.element.find(".dropdown-toggle").height() ) 
      })
    }
  }

  , addWidgetByDescriptor : function(descriptor) {
    var that = this;
    if(descriptor && !$("#" + descriptor.object_type + "_list_widget").length) {
      $("<section class='widget'>").insertBefore(that.element).cms_controllers_dashboard_widgets(descriptor).trigger("sortreceive");
    }
  }

  , addWidgetByName : function(widget_name) {
    this.addWidgetByDescriptor(this.options.widget_descriptors[widget_name]);
  }
})