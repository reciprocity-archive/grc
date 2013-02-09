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


  var getParentNode = function (el, defaultParentNode) {
    return defaultParentNode && el.parentNode.nodeType === 11 ? defaultParentNode : el.parentNode;
  }


    function isExtendedFalsy(obj) {
      return !obj 
        || (typeof obj === "object" && can.isEmptyObject(obj))
        || (obj.length != null && obj.length == 0) 
        || (obj.serialize && can.isEmptyObject(obj.serialize()));
    }

    function preprocessClassString(str) {
      var ret = []
      , src = str.split(" ");

      for(var i = 0; i < src.length; i++) {
        var expr = src[i].trim();
        if(expr.charAt(0) === "=") {
          ret.push({ attr : src[i].trim().substr(1) });
        } else if(expr.indexOf(":") > -1) {
          var spl = expr.split(":");
          var arr = [];
          for(var j = 0; j < spl.length - 1; j ++) {
            var inverse = spl[j].trim()[0] === "!"
            , attr_name = spl[j].trim().substr(inverse ? 1 : 0)
            
            arr.push({attr : attr_name, inverse : inverse});
          }
          arr.value = spl[spl.length - 1];
          ret.push(arr);
        } else {
          ret.push(expr);
        }
      }
      return ret;
    }

    function buildClassString(arr, context) {
      var ret = [];
      for(var i = 0; i < arr.length; i++) {
        if(typeof arr[i] === "string") {
          ret.push(arr[i]);
        } else if(typeof arr[i] === "object" && arr[i].attr) {
          ret.push(can.getObject(arr[i].attr, context));
        } else if(can.isArray(arr[i]) && arr[i].value) {
          var p = true;
          for(var j = 0; j < arr[i].length; j ++) {
            var attr = can.getObject(arr[i][j].attr, context);
            if(arr[i][j].inverse ? !isExtendedFalsy(attr) : isExtendedFalsy(attr)) {
              p = false;
              break;
            }
          }
          if(p) {
            ret.push(arr[i].value);
          }
        } else {
          throw "Unsupported class building expression: " + JSON.stringify(arr[i]);
        }
      }

      return ret.join(" ");
    }

  /**
  * helper withclass
  * puts a class string on the element, includes live binding:
  * usage:
  * {{#withclass 'class strings' bindingattr...}}<element>...</element>{{/withclass}}
  * Tokens usable in class strings:
  *  =attribute : add the value of the attribute as a class
  *  attribute:value : if attribute is truthy, return value
  *  !attribute:value : if attribute is falsy, return value
  *  attr1:!attr2:value : if attr1 is truthy and attr2 is falsy, return value
  *  plainstring : use this class literally
    *  
  */
  Mustache.registerHelper("withclass", function() {
    var options = arguments[arguments.length - 1]
    , exprs = preprocessClassString(arguments[0])
    , hash = quickHash(arguments[0], quickHash(this._cid)).toString(36)
    , content = options.fn(this)
    //, content = options.fn(this).trim()
    //, index = content.indexOf("<") + 1
    , that = this;

    // while(content[index] != " ") {
    //   index++;
    // }
    function classbinding(el, ev, newVal, oldVal) {
      $(el).attr("class", buildClassString(exprs, this));
    }


    function hookupfunc(el, parent, view_id) {
      var frag = can.view.frag(content, parent);
      var $newel = $(frag.querySelector("*"));

      el.parentNode ? el.parentNode.replaceChild($newel[0], el) : $(parent).append($newel);
      el = $newel[0];
      for(var i = 0; i < exprs.length; i ++) {
        var expr = exprs[i];
        if(typeof expr === "object" && expr.attr) {
          that.bind(expr.attr + "." + hash, $.proxy(classbinding, that, el));
        } else if(can.isArray(expr) && expr.value) {
          can.each(expr, function(attr_expr) {
            var attr_token = attr_expr.attr;
            that.bind(attr_token + "." + hash, $.proxy(classbinding, that, el));
          });
        }
      }
      classbinding.call(that, el);
      
    }
    return "<div" 
    + can.view.hook(hookupfunc)
    + " data-replace='true'/>";
  });


  Mustache.registerHelper("withattr", function() {
    var args = can.makeArray(arguments).slice(0, arguments.length - 1)
    , options = arguments[arguments.length - 1]
    , attribs = []
    , that = this
    , hash = quickHash(args.join("-"), quickHash(this._cid)).toString(36)
    , content = options.fn(that)
    , hook = can.view.hook(function(el, parent, view_id) {

      if(content) {
        var frag = can.view.frag(content, parent);
        var $newel = $(frag.querySelector("*"));
        var newel = $newel[0];

        el.parentNode ? el.parentNode.replaceChild(newel, el) : $(parent).append($newel);
        el = newel;
      }

      function sub_all(el, ev, newVal, oldVal) {
        var $el = $(el);
        can.each(attribs, function(attrib) {
          $el.attr(attrib.name, can.sub(attrib.value, that));
        })
      }

      for(var i = 0; i < args.length - 1; i += 2) {
        var attr_name = args[i];
        var attr_tmpl = args[i + 1];
        //set up bindings where appropriate
        attr_tmpl = attr_tmpl.replace(/\{\{[^\{]*\}\}/g, function(match, offset, string) {
          
          that.bind(attr_name + "." + hash, $.proxy(sub_all, that, el));

          return match.substring(1, match.length - 1);
        });
        attribs.push({name : attr_name, value : attr_tmpl});
      }

      sub_all(el);

    });

    return "<div"
    + hook
    + " data-replace='true'/>";
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
    if(typeof val1 === "function") val1 = val1.call(this);
    if(typeof val2 === "function") val2 = val2.call(this);
    if(val1 == val2) return options.fn(this);
    else return options.inverse(this);

});

Mustache.registerHelper("if_null", function(val1, options) {

    if(typeof val1 === "function") val1 = val1.call(this);
    if(val1 == null) return options.fn(this);
    else return options.inverse(this);

});

can.each(["firstexist", "firstnonempty"], function(fname) {
  Mustache.registerHelper(fname, function() {
    var args = can.makeArray(arguments).slice(0, arguments.length - 1);
    for(var i = 0; i < args.length; i++) {
      if(typeof v === "function") v = v.call(this);
      var v = args[i];
      if(v != null && (fname === "firstexist" || !!(v.toString().trim()))) return v;
    }
    return "";
  });
});

/*
Thought I was being clever but this doesn't work as expected. --BM
Mustache.registerHelper("pack", function() {
  var options = arguments[arguments.length - 1];
  var objects = can.makeArray(arguments).slice(0, arguments.length - 1);
  var pack = new can.Observe();
  can.each(objects, function(obj, i) {
    if(obj instanceof can.Observe) {
      obj.bind("change", function(attr, how, newVal, oldVal) {
        pack.attr(attr, newVal);
      });
      objects[i] = obj.serialize();
    }
  });
  pack.packed = pack; //CanJS bug workaround
  objects.unshift(pack);
  options.hash && objects.push(options.hash);
  can.extend.apply(can, objects);
  var retval = options.fn(pack);
  return retval;
});
*/

Mustache.registerHelper("is_beta", function(){
  var options = arguments[arguments.length - 1];
  if($(document.body).hasClass('BETA')) return options.fn(this);
  else return options.inverse(this);
});


Mustache.registerHelper("render", function(template, context, options) {
  if(!options) {
    options = context;
    context = this;
  }

  return can.view.render(template, context.serialize ? context.serialize() : context);
});

})(this, jQuery, can);