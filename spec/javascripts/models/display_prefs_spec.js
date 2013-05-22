describe("display prefs model", function() {
  
  var display_prefs, exp;
  beforeEach(function() {
    display_prefs || (display_prefs = new CMS.Models.DisplayPrefs());
    exp = CMS.Models.DisplayPrefs.exports;
  });

  afterEach(function() {
    display_prefs.removeAttr(window.location.pathName);
  });

  describe("#init", function( ){

    it("sets autoupdate to true by default", function() {
      expect(display_prefs.autoupdate).toBe(true);
    });

  });

  runs(function() {
    display_prefs.autoupdate = false;
  })

  describe("low level accessors", function() {
    beforeEach(function() {
      display_prefs.attr("foo", "bar");
    });
    
    afterEach(function() {
      display_prefs.removeAttr("foo");
      display_prefs.removeAttr("baz");
    });

    describe("#makeObject", function() {

      it("returns the model itself with no args", function() {
        expect(display_prefs.makeObject()).toBe(display_prefs);
      });

      it("returns an empty can.Observe when the key does not resolve to an Observable", function() {
        expect(display_prefs.makeObject("foo")).not.toBe("bar");
        var newval = display_prefs.makeObject("baz");
        expect(newval instanceof can.Observe).toBeTruthy();
        expect(newval.serialize()).toEqual({});
      });

      it("makes a nested path of can.Observes when the key has multiple levels", function() {
        var newval = display_prefs.makeObject("baz", "quux");
        expect(display_prefs.baz.quux instanceof can.Observe).toBeTruthy();
      });

    });

    describe("#getObject", function() {
      it("returns a set value whether or not the value is an Observe", function() {
        expect(display_prefs.getObject("foo")).toBe("bar");
        display_prefs.makeObject("baz", "quux");
        expect(display_prefs.getObject("baz").serialize()).toEqual({ "quux" : {}});
      });

      it("returns undefined when the key is not found", function(){
        expect(display_prefs.getObject("xyzzy")).not.toBeDefined();
      })
    });
  });

  describe("#setCollapsed", function() {
    afterEach(function() {
      display_prefs.removeAttr(exp.COLLAPSE);
      display_prefs.removeAttr(exp.path);
    });

    it("sets the collapse value for a widget", function() {
      display_prefs.setCollapsed("this arg is ignored", "foo", true);

      expect(display_prefs.attr([exp.path, exp.COLLAPSE, "foo"].join("."))).toBe(true);
    });

    xit("sets all collapse values as a collection", function() {
      //TODO: this feature isn't currently supported for collapse
    });
  });

  function getSpecs (func, token, fooValue, barValue) {
    var fooMatcher = typeof fooValue === "object" ? "toEqual" : "toBe";
    var barMatcher = typeof barValue === "object" ? "toEqual" : "toBe";

    return function() {
      function getTest() {
          var fooActual = display_prefs[func]("unit_test", "foo");
          var barActual = display_prefs[func]("unit_test", "bar");
          expect(fooActual.serialize ? fooActual.serialize() : fooActual)[fooMatcher](fooValue);
          expect(barActual.serialize ? barActual.serialize() : barActual)[barMatcher](barValue);
      }

      var exp_token;
      beforeEach(function() {
        exp_token = exp[token]; //late binding b/c not available when describe block is created
      });

      describe("when set for a page", function() {
        beforeEach(function() {
          display_prefs.makeObject(exp.path, exp_token).attr("foo", fooValue);
          display_prefs.makeObject(exp.path, exp_token).attr("bar", barValue);
        });
        afterEach(function() {
          display_prefs.removeAttr(exp.path);
        });

        it("returns the value set for the page", getTest);
      });

      describe("when not set for a page", function() {
        beforeEach(function() {
          display_prefs.makeObject(exp_token, "unit_test").attr("foo", fooValue);
          display_prefs.makeObject(exp_token, "unit_test").attr("bar", barValue);
        });
        afterEach(function() {
          display_prefs.removeAttr(exp.path);
          display_prefs.removeAttr(exp_token);
        });

        it("returns the value set for the page type default", getTest);

        it("sets the default value as the page value", function() {
          display_prefs[func]("unit_test", "foo");
          var fooActual = display_prefs.attr([exp.path, exp_token, "foo"].join("."))
          expect(fooActual.serialize ? fooActual.serialize() : fooActual)[fooMatcher](fooValue);
        });
      });
    }
  }

  describe("#getCollapsed", getSpecs("getCollapsed", "COLLAPSE", true, false));

  describe("#getSorts", getSpecs("getSorts", "SORTS", ["baz, quux"], ["thud", "jeek"]));


  function setSpecs(func, token, fooValue, barValue) {
    return function() {
      var exp_token;
      beforeEach(function() {
        exp_token = exp[token];
      })
      afterEach(function() {
        display_prefs.removeAttr(exp_token);
        display_prefs.removeAttr(exp.path);
      });

      it("sets the value for a widget", function() {
        display_prefs[func]("this arg is ignored", "foo", fooValue);
        var fooActual = display_prefs.attr([exp.path, exp_token, "foo"].join("."));
        expect(fooActual.serialize ? fooActual.serialize() : fooActual).toEqual(fooValue);
      });

      it("sets all values as a collection", function() {
        display_prefs[func]("this arg is ignored", {"foo" : fooValue, "bar" : barValue});
        var fooActual = display_prefs.attr([exp.path, exp_token, "foo"].join("."));
        var barActual = display_prefs.attr([exp.path, exp_token, "bar"].join("."));
        expect(fooActual.serialize ? fooActual.serialize() : fooActual).toEqual(fooValue);
        expect(barActual.serialize ? barActual.serialize() : barActual).toEqual(barValue);
      });
    }
  }

  describe("#setSorts", setSpecs("setSorts", "SORTS", ["bar", "baz"], ["thud", "jeek"]));

  describe("#getWidgetHeights", function() {});

  describe("#getWidgetHeight", getSpecs("getWidgetHeight", "HEIGHTS", 100, 200));

  describe("#setWidgetHeight", setSpecs("setWidgetHeight", "HEIGHTS", 100, 200));

  describe("#getColumnWidths", getSpecs("getColumnWidths", "COLUMNS", [6, 6], [8, 4]));

  describe("#getColumnWidthsForSelector", function() {
    it("calls getColumnWidths with the ID of the supplied element", function() {
      var $foo = affix("#foo");
      var $bar = affix("#bar");

      spyOn(display_prefs, "getColumnWidths");

      display_prefs.getColumnWidthsForSelector("unit_test", $foo);
      expect(display_prefs.getColumnWidths).toHaveBeenCalledWith("unit_test", "foo");
    });
  });

  describe("#setColumnWidths", setSpecs("setColumnWidths", "COLUMNS", [6,6], [4,8]));

  describe("Set/Reset functions", function() {

    describe("#resetPagePrefs", function() {

      beforeEach(function() {
        can.each([exp.COLUMNS, exp.HEIGHTS, exp.SORTS, exp.COLLAPSE], function(exp_token) {
          display_prefs.makeObject(exp_token, "unit_test").attr("foo", "bar"); //page type defaults
          display_prefs.makeObject(exp.path, exp_token).attr("foo", "baz"); //page custom settings
        });
      });
      afterEach(function() {
        display_prefs.removeAttr(exp.path);
        can.each([exp.COLUMNS, exp.HEIGHTS, exp.SORTS, exp.COLLAPSE], function(exp_token) {
          display_prefs.removeAttr(exp_token);
        });
      });

      it("sets the page layout to the default for the page type", function() {
        display_prefs.resetPagePrefs();
        can.each(["getSorts", "getCollapsed", "getWidgetHeight", "getColumnWidths"], function(func) {
          expect(display_prefs[func]("unit_test", "foo")).toBe("bar");
        })
      });

    });

    describe("#setPageAsDefault", function() {
      beforeEach(function() {
        can.each([exp.COLUMNS, exp.HEIGHTS, exp.SORTS, exp.COLLAPSE], function(exp_token) {
          display_prefs.makeObject(exp_token, "unit_test").attr("foo", "bar"); //page type defaults
          display_prefs.makeObject(exp.path, exp_token).attr("foo", "baz"); //page custom settings
        });
      });
      afterEach(function() {
        display_prefs.removeAttr(exp.path);
        can.each([exp.COLUMNS, exp.HEIGHTS, exp.SORTS, exp.COLLAPSE], function(exp_token) {
          display_prefs.removeAttr(exp_token);
        });
      });

      it("sets the page layout to the default for the page type", function() {
        display_prefs.setPageAsDefault("unit_test");
        can.each([exp.COLUMNS, exp.HEIGHTS, exp.SORTS, exp.COLLAPSE], function(exp_token) {
          expect(display_prefs.attr([exp_token, "unit_test", "foo"].join("."))).toBe("baz");
        })
      });

      it("keeps the page and the defaults separated", function() {
        display_prefs.setPageAsDefault("unit_test");
        can.each(["setColumnWidths", "setCollapsed", "setWidgetHeight", "setSorts"], function(func) {
          display_prefs[func]("unit_test", "foo", "quux");
        });
        can.each([exp.COLUMNS, exp.HEIGHTS, exp.SORTS, exp.COLLAPSE], function(exp_token) {
          expect(display_prefs.attr([exp_token, "unit_test", "foo"].join("."))).toBe("baz");
        });
      });

    });

  });

  describe("PBC-only functions", function() {

    describe("#getPbcListPrefs", function() {

    });

    describe("#setPbcListPrefs", function() {

    });

    describe("#getPbcResponseOpen", function() {

    });

    describe("#getPbcRequestOpen", function() {

    });

    describe("#setPbcResponseOpen", function() {

    });

    describe("#setPbcRequestOpen", function() {

    });

  });

});