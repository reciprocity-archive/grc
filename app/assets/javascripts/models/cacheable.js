//= require can.jquery-all

can.Model("can.Model.Cacheable", {

  init : function() {
    this.bind("created", function(ev, new_obj) {
      if(new_obj.id) {
        can.getObject("cache", this, true)[new_obj.id] = new_obj;
      }
    });
  }

	, findInCacheById : function(id) {
		return can.getObject("cache", this, true)[id];
	}	

  , newInstance : function(args) {
    var cache = can.getObject("cache", this, true);
    if(args && args.id && cache[args.id]) {
      //cache[args.id].attr(args, false); //CanJS has bugs in recursive merging 
                                          // (merging -- adding properties from an object without removing existing ones 
                                          //  -- doesn't work in nested objects).  So we're just going to not merge properties.
      return cache[args.id];
    } else {
      return can.Model.Cacheable.prototype.__proto__.constructor.newInstance.apply(this, arguments);
    }
  }

}, {
	init : function() {
    var obj_name = this.constructor.root_object;
    if(typeof obj_name !== "undefined" && this[obj_name]) {
        for(var i in this[obj_name].serialize()) {
          if(this[obj_name].hasOwnProperty(i)) {
            this.attr(i, this[obj_name][i]);
          }
        }
        this.removeAttr(obj_name);
    }

		var cache = can.getObject("cache", this.constructor, true);
    cache[this.id] = this;
	}
});