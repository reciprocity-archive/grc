//= require can.jquery-all

can.Model("can.Model.Cacheable", {
	findInCacheById : function(id) {
		return can.getObject("cache", this, true)[id];
	}	

}, {
	init : function() {
		can.getObject("cache", this.constructor, true)[this.id] = this;
	}
});