//= require mapping/mapping_controller

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
        spyOn(CMS.Controllers.Controls.prototype, "filter").andCallThrough();

        var ev = new $.Event("keydown");
        ev.which = 79;
        $("#mapping .widgetsearch-tocontent").trigger(ev);

        waitsFor(function() {
            return $("#mapping .cms_controllers_controls").control().options.filter;
        }, 1000, "waiting for filter to be set");
        runs(function() {
            expect(CMS.Controllers.Controls.prototype.filter).toHaveBeenCalledWith("foo");
        });
    });
});