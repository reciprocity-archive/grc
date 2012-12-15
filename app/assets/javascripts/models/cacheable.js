//= require can.jquery-all

can.Model("can.Model.Cacheable", {
	findInCacheById : function(id) {
		return can.getObject("cache", this, true)[id];
	}	

  , newInstance : function(args) {
    var cache = can.getObject("cache", this, true);
    if(cache[args.id]) {
      cache[args.id].attr(args);
      return cache[args.id]
    } else {
      return can.Model.Cacheable.prototype.__proto__.constructor.newInstance.apply(this, arguments);
    }
  }

}, {
	init : function() {
		var cache = can.getObject("cache", this.constructor, true);
    cache[this.id] = this;
	}
});