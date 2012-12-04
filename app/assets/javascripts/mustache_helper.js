(function(namespace, $, can) {

	Mustache.registerHelper("join", function() {
		var prop, context = this, ret, options = arguments[arguments.length - 1];

		switch(arguments.length) {
			case 1:
				break;
			case 2:
				typeof arguments[0] === 'string' ? prop = arguments[0] : context = arguments[0];
				break;
			default:
				prop = arguments[0];
				context = arguments[1];
		}
		if(!context) {
			ret =  "";
		} else if(context.length) {
			ret = $(context).map(function() { return prop ? (can.getObject(prop, this) || "").toString() : this.toString(); }).get().join(", ");
		} else {
			ret = prop ? (can.getObject(prop, context) || "").toString() : context.toString();
		}
		return ret;
	});
})(this, jQuery, can);