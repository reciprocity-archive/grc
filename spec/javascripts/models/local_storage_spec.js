//= require models/local_storage

describe("can.Model.LocalStorage", function() {
  
  //run-once setup
  can.Model.LocalStorage("SpecModel");

  var model1 = { "id" : 1, "foo" : "bar" };
  var model2 = { "id" : 2, "foo" : "baz" };

  beforeEach(function() {
    window.localStorage.setItem("spec_model:ids", "[1, 2]");
    window.localStorage.setItem("spec_model:1", JSON.stringify(model1));
    window.localStorage.setItem("spec_model:2", JSON.stringify(model2));
  });

  afterEach(function() {
    window.localStorage.removeItem("spec_model:ids");
    window.localStorage.removeItem("spec_model:1");
    window.localStorage.removeItem("spec_model:2");
  });
  describe("::findAll", function() {


    it("returns all model instnances with no arguments", function() {
      var success = false;
      SpecModel.findAll().done(function(list) {
        expect(list.length).toBe(2);
        expect(list instanceof can.Model.List).toBeTruthy();
        expect(list[0] instanceof SpecModel).toBeTruthy();
        expect(list[0].serialize()).toEqual(model1);
        expect(list[1].serialize()).toEqual(model2);
        success = true;
      });
      expect(success).toBe(true);
    });

    it("filters by id parameter", function() {
      var success = false;
      SpecModel.findAll({id : 1}).done(function(list) {
        expect(list.length).toBe(1);
        expect(list[0].serialize()).toEqual(model1);
        success = true;
      });
      expect(success).toBe(true);
    });

    it("filters by other parameters", function() {
      var success = false;
      SpecModel.findAll({foo : "bar"}).done(function(list) {
        expect(list.length).toBe(1);
        expect(list[0].serialize()).toEqual(model1);
        success = true;
      });
      expect(success).toBe(true);
    });

    it("returns an empty list with no matches", function() {
      var success = false;
      SpecModel.findAll({quux : "thud"}).done(function(list) {
        expect(list instanceof can.Model.List).toBeTruthy();
        expect(list.length).toBe(0);
        success = true;
      });
      expect(success).toBe(true);
    });

  });

  describe("::findOne", function() {

    it("returns a single model instance by id", function() {
      var success = false;
      SpecModel.findOne({id : 1}).done(function(item) {
        expect(item instanceof SpecModel).toBeTruthy();
        expect(item.serialize()).toEqual(model1);
        success = true;
      });
      expect(success).toBe(true);
    });

    it("fails with status 404 when the id is not found", function() {
      var failure = false;
      SpecModel.findOne({id : 3}).fail(function(xhr) {
        expect(xhr.status).toBe(404);
        failure = true;
      });
      expect(failure).toBe(true);      
    });
  });

  describe("::create", function() {
    beforeEach(function() {
      window.localStorage.removeItem("spec_model:ids");
      window.localStorage.removeItem("spec_model:1");
      window.localStorage.removeItem("spec_model:2");
    });

    it("creates and registers a model", function() {
      var success = false;
      new SpecModel({ foo : model1.foo }).save().done(function(item) {
        expect(item.id).toBeDefined();
        expect(item.foo).toEqual(model1.foo);

        var ids = JSON.parse(window.localStorage.getItem("spec_model:ids"));
        expect(ids.length).toEqual(1);
        expect(window.localStorage.getItem("spec_model:" + ids[0])).toBeDefined();
        success = true;
      });
      expect(success).toBe(true);
    });

  });

  describe("::update", function() {

    it("updates model instance by id", function() {
      var success = false;
      var m = new SpecModel(model1);
      m.attr("quux", "thud").save().done(function(item) {
        expect(item instanceof SpecModel).toBeTruthy();
        expect(JSON.parse(window.localStorage.getItem("spec_model:1"))).toEqual(can.extend({quux : "thud"}, model1));
        success = true;
      });
      expect(success).toBe(true);
    });

    it("fails with status 404 when the id is not found", function() {
      var failure = false;
      new SpecModel().attr({id : 3}).save().fail(function(xhr) {
        expect(xhr.status).toBe(404);
        failure = true;
      });
      expect(failure).toBe(true);      
    });
  });


  describe("::destroy", function() {

    it("deletes model instance by id", function() {
      var success = false;
      new SpecModel(model1).destroy().done(function(item) {
        expect(item.serialize()).toEqual(model1);
        expect(JSON.parse(window.localStorage.getItem("spec_model:1"))).toBeNull();
        var ids = JSON.parse(window.localStorage.getItem("spec_model:ids"));
        expect(ids.length).toBe(1);
        expect(ids[0]).not.toEqual(item.id);
        success = true;
      });
      expect(success).toBe(true);
    });

    it("fails with status 404 when the id is not found", function() {
      var failure = false;
      new SpecModel().attr({id : 3}).destroy().fail(function(xhr) {
        expect(xhr.status).toBe(404);
        failure = true;
      });
      expect(failure).toBe(true);      
    });

  });

});