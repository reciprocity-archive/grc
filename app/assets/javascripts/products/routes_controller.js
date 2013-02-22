//= require can.jquery-all

(function(can, $){


can.Control("CMS.Controllers.ProductRoutes", {
  //Static

}, {
  //Prototype

  "show=:show&parent=:parent route" : function(data) {
    //regulations, category_controls, combo are the possible values.  Each is a tab ID.
    var ids = data.show.split(",");
    $("[data-object-id=" + can.route.attr("parent") + "]")
    .parents("[data-object-id]")
    .addBack()
    .each(function() {
      //walking up the chain to make sure that each one is visible.
      var $el = $(this).closest("[data-object-id]");
      $el.find("[id$='-" + $(this).data("object-id") + "-objects']").collapse().collapse("show");
      $el.find(".expander").eq(0).addClass("in");
    })

    can.each(ids, function(id) {
      $("[data-object-id=" + can.route.attr("parent") + "] [id$='-" + id + "-summary']").collapse().collapse("show");
    })
  }

  , "a[href*='relationship_type=product_relies_upon_product'] modal:success" : function(el, ev, data) {
    var parent = el.closest("[data-object-id]")
    , parentid = parent.data("object-id")
    , list = parent.find(".slotlist:eq(1)")
    , existing = list.find("[data-object-id]")
      .filter(function() { return $(this).closest(".slotlist").is(list); })
      .map(function() { return $(this).data("object-id")})
    , s = can.map(can.makeArray(data), function(v) {
      return $(v.relationship.destination_id).is(existing) ? undefined : v.relationship.destination_id;
    });

    can.route.attr("show", s.join(","));
    can.route.attr("parent", parentid);
  }
});

})(window.can, window.can.$);
