//= require mapping/mapping_controller
//= require controls/control
//= require sections/section
//= require sections/sections_controller
//= require controls/controls_controller

describe("CMS.Controllers.MappingWidgets", function() {

    beforeEach(function() {
        spyOn(CMS.Controllers.Controls.prototype, "fetch_list");
        spyOn(CMS.Controllers.Controls.prototype, "fetch_one"); //spy out this to prevent errors
        spyOn(CMS.Controllers.Controls.prototype, "draw_list");
        spyOn(CMS.Controllers.Controls.prototype, "draw_one"); //spy out this to prevent errors
        affix("#mapping").cms_controllers_mapping_widgets();
    });

    describe(".clearselection click", function() {
        it("unselects controls from list", function() {
            $("#mapping").affix(".clearselection").affix("div").cms_controllers_controls({ arity : 2 });

            spyOn(CMS.Controllers.Controls.prototype, "setSelected");

            $("#mapping .clearselection").click();

            expect(CMS.Controllers.Controls.prototype.setSelected).toHaveBeenCalledWith(null);
        });

        it("unsets instance from selected widget", function() {
            spyOn(CMS.Controllers.Controls.prototype, "update");

            $("#mapping").affix(".clearselection").affix("div").cms_controllers_controls({ arity : 1 });

            $("#mapping .clearselection").click();

            expect(CMS.Controllers.Controls.prototype.update).toHaveBeenCalledWith({instance : null});
        });
    });

    it(".widgetsearch-tocontent keydown [triggers filter]", function() {
        $("#mapping").affix("input.widgetsearch-tocontent[type=text]").val("foo");
        $("#mapping").affix("div").cms_controllers_controls({ arity : 2 });
        spyOn(CMS.Controllers.Controls.prototype, "filter");

        var ev = new $.Event("keydown");
        ev.which = 79;
        $("#mapping .widgetsearch-tocontent").trigger(ev);

        waitsFor(function() {
            return $("#mapping .cms_controllers_controls").control().filter.callCount > 0;
        }, 1000, "waiting for filter to be set");
        runs(function() {
            expect(CMS.Controllers.Controls.prototype.filter).toHaveBeenCalledWith("foo");
        });
    });
});

$(document).ajaxError(function(ev, xhr) {
  var mesg = "An unknown error occurred calling the REST services.";
  if(xhr.status === 401) {
    mesg = "You are not logged in";
  } 
  if(jasmine.currentEnv_.currentSpec) {
    jasmine.currentEnv_.currentSpec.fail(new Error(mesg));
  }
})
describe("Mapping perf test", function() {

  it("Loads all in a reasonable amount of time, 5000ms or less", function() {

    var sections = affix("#sections")
    , rcontrols = affix("#rcontrols")
    , ccontrols = affix("#ccontrols")
    , stime = Date.now();
    spyOn(CMS.Controllers.Controls.prototype, "draw_list").andCallThrough();
    spyOn(CMS.Controllers.Sections.prototype, "draw_list").andCallThrough();
    var sparams = can.deparam(window.location.search.substr(1));

    sections.cms_controllers_controls({ id : sparams.mapping_id || 1 });
    rcontrols.cms_controllers_controls({ id : sparams.mapping_id || 1, model : CMS.Models.RegControl });
    ccontrols.cms_controllers_sections({ id : sparams.mapping_id || 1, model : CMS.Models.SectionSlug });

    waitsFor(function() {
      return CMS.Controllers.Controls.prototype.draw_list.callCount >= 2 && CMS.Controllers.Sections.prototype.draw_list.callCount >= 1;
    }, 5000);

    runs(function(){
      var elapsed = Date.now() - stime;
      expect(elapsed).toBeLessThan(5000);
      jasmine.log("Actual time:", elapsed, "ms");
    });
  });

});