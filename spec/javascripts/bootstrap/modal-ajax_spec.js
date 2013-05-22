//= require bootstrap/modal-ajax

describe("AJAXy Modals", function() {

  var $modal1, $modal2, m1shown, m2shown;
  beforeEach(function() {
      m1shown = false;
      m2shown = false;
      $modal1 = $("<div id='m1' class='modal fade'>").appendTo(document.body).bind("shown", function() { m1shown = true; });
      $modal1.affix(".modal-header, .modal-body, .modal-buttons");
      $modal2 = $("<div id='m2' class='modal fade'>").appendTo(document.body).bind("shown", function() { m2shown = true; });
      $modal2.affix(".modal-header, .modal-body, .modal-buttons");
      $modal1.add($modal2).find(".modal-header").text("foo");
      $modal1.add($modal2).find(".modal-body").text("bar");

      $modal1.modal({show : true, backdrop : true});
      waitsFor(function() {
        return m1shown;
      }, 1000);
      runs(function() {
          $modal2.modal({show : true, backdrop : true});    
      });
  });

  afterEach(function() {
    $(".modal-backdrop, #m1, #m2").remove();
  });

  describe("#show aspect", function() {
    it("reorders the z-index of the modals and modal backdrops", function() {

      waitsFor(function() {
        return m2shown;
      }, 1000);

      runs(function() {
          expect($(".modal-backdrop").length).toBe(2);
          expect($(".modal-backdrop:first").css("z-index")).toBe("1040");
          expect($(".modal-backdrop:eq(1)").css("z-index")).toBeGreaterThan($modal1.css("z-index"));
          expect($modal1.css("z-index")).toBeGreaterThan($(".modal-backdrop:first").css("z-index"));
          expect($modal2.css("z-index")).toBeGreaterThan($(".modal-backdrop:eq(1)").css("z-index"));
      });
    });
    xit("shrinks the height of the first modal to be just over the height of its header", function(){
      //this no longer happens --BM
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