(function(namespace, $, can) {

//chrome likes to cache AJAX requests for Mustaches.
$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
  if ( /\.mustache$/.test(options.url) ) {
    options.url += "?r=" + Math.random();
  }
});

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

  var controlslugs = function() {
    var slugs = [];
    slugs.push(this.slug);
    can.each(this.implementing_controls, function(val) {
      slugs.push.apply(slugs, controlslugs.call(this));
    });
    return slugs;
  }

  var countcontrols = function() {
    var slugs = [];
    can.each(this.linked_controls, function() {
      slugs.push.apply(slugs, controlslugs.apply(this)); 
    });
    return slugs.length;
  }

  Mustache.registerHelper("controlscount", countcontrols);

  Mustache.registerHelper("controlslugs", function() {
    var slugs = [];
    can.each(this.linked_controls, function() {
      slugs.push.apply(slugs, controlslugs.apply(this)); 
    });
    return slugs.join(" ");
  });

$.each({
	"rcontrols" : "RegControl"
	, "ccontrols" : "Control"
}, function(key, val) {
  Mustache.registerHelper(key, function(obj, options) {
    var implementing_control_ids = []
    , ctls_list = obj.linked_controls;

    can.each(ctls_list, function(ctl) {
      var ctl_model = namespace.CMS.Models[val].findInCacheById(ctl.id);
      if(ctl_model && ctl_model.implementing_controls && ctl_model.implementing_controls.length) {
        implementing_control_ids = implementing_control_ids.concat(
          can.map(ctl_model.implementing_controls, function(ictl) { return ictl.id })
        );
      }
    });

    return can.map(
      $(ctls_list).filter( 
        function() {
          return $.inArray(this.id, implementing_control_ids) < 0;
        })
      , function(ctl) { return options.fn({ foo_controls : namespace.CMS.Models[val].findInCacheById(ctl.id) }); }
    )
    .join("\n");
  });
});

Mustache.registerHelper("if_equals", function(val1, val2, options) {

    if(val1 == val2) return options.fn(this);
    else return options.inverse(this);

});

})(this, jQuery, can);