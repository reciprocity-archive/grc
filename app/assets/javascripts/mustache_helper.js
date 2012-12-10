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

	var quickHash = function(str, seed) {
		var bitval = seed || 1;
		for(var i = 0; i < str.length; i++)
		{
			bitval *= str.charCodeAt(i);
			bitval = Math.pow(bitval, 7);
			bitval %= Math.pow(7, 37);
		}
		return bitval;
	}

	/**
	* helper withclass
	* puts a class string on the element, includes live binding:
	* usage:
	* {{#withclass 'class strings' bindingattr...}}<element>...</element>{{/withclass}}
	* Tokens usable in class strings:
	*  =attribute : add the value of the attribute as a class
	*  attribute:value : if attribute is truthy, return value
	*  plainstring : use this class literally
    *  
	*/
	Mustache.registerHelper("withclass", function() {
		var options = arguments[arguments.length - 1]
		, exprs = arguments[0].split(" ")
		, hash = quickHash(arguments[0], quickHash(this._cid)).toString(36)
		, content = options.fn(this).trim()
		, index = content.indexOf("<") + 1;

		while(content[index] != " ") {
			index++;
		}

		var classarr = [];
		for(var i = 0; i < exprs.length; i ++) {
			var expr = exprs[i];
			if(expr.trim().charAt(0) === "=") {
				var attrname = expr.substr(1).trim();
				classarr.push(can.getObject(attrname, this));

				this.bind(attrname + "." + hash, function(ev, newVal, oldVal) {
					var $existing = can.$("[data-class-hash=" + hash + "]");
					if($existing.length < 1) {
						this.unbind(attrname + "." + hash);
					} else {
						$existing.removeClass(oldVal);
						$existing.addClass(newVal);
					}
				});
			} else if(expr.indexOf(":") > -1) {
				var spl = expr.split(":");
				if(can.getObject(spl[0].trim(), this)) {
					classarr.push(spl[1].trim());
				}

				this.bind(spl[0].trim() + "." + hash, function(ev, newVal, oldVal) {
					var $existing = can.$("[data-class-hash=" + hash + "]");

					if($existing.length < 1) {
						this.unbind(spl[0].trim() + "." + hash);
					} else {
						if(newVal) {
							$existing.addClass(spl[1]);
						} else {
							$existing.removeClass(spl[1]);
						}
					}
				});

			} else {
				classarr.push(expr);
			}
		}

		return content.substr(0, index)
			+ ' class="'
			+ classarr.join(" ")
			+ '" data-class-hash="'
			+ hash
			+ '" '
			+ content.substr(index + 1);
	});


})(this, jQuery, can);