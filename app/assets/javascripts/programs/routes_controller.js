//= require can.jquery-all

(function(can, $){


can.Control("CMS.Controllers.ProgramRoutes", {
  //Static

}, {
  //Prototype

  "{can.route} change" : function(el, ev, param, how, newval, oldval) {
    //regulations, category_controls, combo are the possible values.  Each is a tab ID.
    if(param === "tab")
      $("a[href=#" + newval + "]").click();
  }

  , ".tab-pane loaded" : function() {
    var that = this;

    if(this.show) {
      if(!isNaN(parseInt(this.show))) {
        $("[data-id=" + this.show + "]").collapse().collapse("show");
      } else if(this.show === "new") {
        var $categories = $("[data-object-type=category]").filter(function() {
          return can.inArray($(this).data("id").toString(), that.lastCreatedCategories) > -1 ;
        }).collapse().collapse("show");
        var widget = $categories.find("[data-id=" + this.lastCreatedId + "]").collapse().collapse("show");
        var box = widget.closest(".WidgetBoxContent");
        $(document.body).scrollTop(box.offset().top);
        setTimeout(function() {
          box.scrollTop(widget.offset().top);
        }, 300);
      }
    }


  }

  , "a[data-toggle=tab] click" : function(el, ev) {
    can.route.attr("tab", el.attr("href").substr(el.attr("href").indexOf("#") + 1));
  }

  , " ajax:beforeSend" : function(el, ev, xhr, settings) {
    var that = this,
      data = can.deparam(settings.data);
    if(settings.type === "POST" && data.control) {
      this.show = "new";
      this.lastCreatedCategories = data.control.category_ids || ["0"];
      xhr.done(function(d) {
        that.lastCreatedId = d.id;
      })
   }
  }

  , " routeparam" : function(el, ev, data) {
    function makehash (str) {
      var h = {};
      if(str.length) {
        var elements = str.split("&");
        can.each(elements, function(el) {
          var s = el.split("=");
          h[s[0]] = s[1];
        });
      }
      return h;
    }

    var d = typeof data === "string" ? makehash(data) : data;
    can.route.attr(d);
  }
});

})(window.can, window.can.$);