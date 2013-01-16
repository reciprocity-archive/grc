can.Control("CMS.Controllers.ProgramRoutes", {
  //Static

}, {
  //Prototype

  "show=:show route" : function(data) {
    //regulations, category_controls, combo are the possible values.  Each is a tab ID.
    $("a[href=#" + data.show + "]").click();
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