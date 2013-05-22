//= require can.jquery-all

(function(can, $){


can.Control("CMS.Controllers.DirectiveRoutes", {
  //Static
  init : function() {
    can.route.attr({}); //make sure the route is set up
  }

}, {
  //Prototype

  "{can.route} tab" : function(el, ev, value, oldval) {
    //regulations, category_controls, combo are the possible values.  Each is a tab ID.
    if(value !== oldval) {
      can.each(value.serialize ? value.serialize() : value, function(val, section) {
        $("#" + section + " a[href=#" + val + "]:not(.active, li.active *)").click();
      });
    }
  }

  , ".tab-pane loaded" : function(el, ev) {
    var that = this;

    if(this.show) {
      if(!isNaN(parseInt(this.show))) {
        $("[data-id=" + this.show + "]").collapse().collapse("show");
      } else if(this.show === "new") {
        var widget;
        if(el.is("#category_controls")) {
          var $categories = $("[data-object-type=category]").filter(function() {
            return can.inArray($(this).data("id").toString(), that.lastCreatedCategories) > -1 ;
          }).collapse().collapse("show");
          $categories.each(function() {
            $("[data-target=#" + this.id + "]").find(".expander").addClass("in");
          });
          widget = $categories.find("[data-id=" + this.lastCreatedId + "]");
        } else {
          widget = el.find("[data-id=" + this.lastCreatedId + "]");
        }
        widget.collapse().collapse("show");
        $("[data-target=#" + widget.attr("id") + "]").find(".expander").addClass("in");
        var box = widget.closest(".WidgetBoxContent");
        box.offset() && $(document.body).scrollTop(box.offset().top);
        setTimeout(function() {
          box.scrollTop(widget.offset().top);
        }, 300);
      }
    }


  }

  , "a[data-toggle=tab] click" : function(el, ev) {
    var params= {};
    params[el.closest(".widget").attr("id")] = el.attr("href").substr(el.attr("href").indexOf("#") + 1)
    can.route.attr("tab", can.extend(can.route.attr().tab, params));
  }

  , " ajax:beforeSend" : function(el, ev, xhr, settings) {
    var that = this,
      data = can.deparam(settings.data);
    if(settings.type === "POST") {
      if(data.control || data.section) {
        this.show = "new";
        this.lastCreatedCategories = data.control ? (data.control.category_ids || ["0"]) : [];
        xhr.done(function(d) {
          that.lastCreatedId = d.id;
        });
      }
    }
  }

  , " routeparam" : function(el, ev, data) {
    function makehash (str) {
      var h = {};
      if(str.length) {
        var elements = str.split("&");
        can.each(elements, function(el) {
          var k = h, parent;
          var s = el.split("=");
          var parts = s[0].split(".");
          can.each(parts, function(part) {
            parent = k;
            k[part] = k[part] || {};
            k = k[part];
          })
          parent[parts[parts.length - 1]] = s[1];
        });
      }
      return h;
    }

    var d = typeof data === "string" ? makehash(data) : data;
    can.route.attr(can.extend(can.route.attr(), d));
  }
});

})(window.can, window.can.$);
