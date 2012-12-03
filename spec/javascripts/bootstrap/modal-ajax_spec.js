//= require bootstrap/modal-ajax

describe("AJAXy Modals", function() {

  var $modal1, $modal2;
  beforeEach(function() {
      $modal1 = affix("#m1.modal");
      $modal1.affix(".modal-header, .modal-body, .modal-buttons");
      $modal2 = affix("#m2.modal");
      $modal2.affix(".modal-header, .modal-body, .modal-buttons");
      $modal1.add($modal2).find(".modal-header").text("foo");
      $modal1.add($modal2).find(".modal-body").text("bar");

      $modal1.modal({show : true, backdrop : true});
      $modal2.modal({show : true, backdrop : true});
  });

  afterEach(function() {
    $(".modal-backdrop").remove();
  });

  describe("#show aspect", function() {
    it("reorders the z-index of the modals and modal backdrops", function() {

      expect($(".modal-backdrop").length).toBe(2);
      expect($(".modal-backdrop:first").css("z-index")).toBe("1040");
      expect($(".modal-backdrop:eq(1)").css("z-index")).toBe("1060");
      expect($modal1.css("z-index")).toBe("1050");
      expect($modal2.css("z-index")).toBe("1070");
    });
    it("shrinks the height of the first modal to be just over the height of its header", function(){
      expect($modal1.height()).toBe($modal1.find(".modal-header").height() + 4);
    });
  });

  describe("#hide aspect", function() {
    it("re-shows the first modal fully", function() {
      $modal2.data("modal").hide();
      expect($(".modal-backdrop").length).toBe(1);
      expect($modal1.height()).toBeGreaterThan($modal1.find(".modal-header").height() + $modal1.find(".modal-body").height());
    });
  });

});