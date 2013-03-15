//= require models/cacheable

describe("Cacheable super-model", function() {
   
    describe("#init", function() {

        var source = {
            foo : {
                id : 1
                , bar : "baz"
            }
        };

        beforeEach(function() {
            can.Model.Cacheable.root_object = "foo";
        });
        afterEach(function() {
            can.Model.Cacheable.root_object = null;
            delete can.Model.Cacheable.cache;
        });
        it("unpacks the root object when defined", function() {
            expect(new can.Model.Cacheable(source).attr()).toEqual(source.foo);
        });
        it("adds the object to the cache", function() {
            new can.Model.Cacheable(source);
            expect(can.Model.Cacheable.findInCacheById(source.foo.id)).toBeDefined();
        });
        it("returns the cached object instead of a new object when instantiating a new model with the same ID", function() {
            var s = new can.Model.Cacheable(source);

            expect(new can.Model.Cacheable({ id : source.foo.id })).toBe(s);
        });


    });

    describe("::findInCacheById", function() {
        it("only returns cached instance for model class", function() {
            var model = can.Model.Cacheable({});

            var m = new model({id : 2});

            expect(model.findInCacheById(2)).toBe(m);
            expect(can.Model.Cacheable.findInCacheById(2)).not.toBeDefined();
        });
    });

    describe("event handlers", function() {
        it("removes from cache on destroyed", function() {
            spyOn(can, "ajax").andCallFake(function() {
                return new $.Deferred().resolve();
            });
            var m = new can.Model.Cacheable({ id : 1 });
            m.destroy();
            expect(can.Model.Cacheable.findInCacheById(1)).not.toBeDefined();
        });

        it("updates id of object on created", function() {
            spyOn(can, "ajax").andCallFake(function() {
                return new $.Deferred().resolve({id : 1});  //args to "resolve" mimic data coming back from server
            });
            var m = new can.Model.Cacheable({});
            m.save();
            expect(can.Model.Cacheable.findInCacheById(1)).toBe(m);
        });
    });

    describe("::process_args", function() {
      var orig = { bar : "baz", quux : "thud"};
      beforeEach(function() {
          can.Model.Cacheable.root_object = "foo";
      });
      afterEach(function() {
          can.Model.Cacheable.root_object = null;
          delete can.Model.Cacheable.cache;
      });
      it("boxes all params into the root object", function() {
        expect(can.Model.Cacheable.process_args(orig)).toEqual({foo : { bar : "baz", quux : "thud"}});
      });
      it("filters all params to just matching names", function() {
        expect(can.Model.Cacheable.process_args(orig, ["bar"])).toEqual({foo : { bar : "baz"}});
      });
      it("filters out params if names is {not : [...]}", function() {
        expect(can.Model.Cacheable.process_args(orig, {not : ["bar"]})).toEqual({foo : {quux : "thud"}});
      });

    });

});