(function(namespace, $, can) {

//chrome likes to cache AJAX requests for Mustaches.
var mustache_urls = {};
$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
  if ( /\.mustache$/.test(options.url) ) {
    if(mustache_urls[options.url]) {
      options.url = mustache_urls[options.url];
    } else {
      mustache_urls[options.url] = options.url += "?r=" + Math.random();
    }
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
    str = str || "";
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
  * {{#withclass 'class strings'}}<element>...</element>{{/withclass}}
  * {{{withclass 'class strings'}}} to apply to the parent element a la XSLT <xsl:attribute>. Note the triple braces!
  * Tokens usable in class strings:
  *  =attribute : add the value of the attribute as a class
  *  attribute:value : if attribute is truthy, add value to the classes
  *  !attribute:value : if attribute is falsy, add value
  *  attr1:!attr2:value : if attr1 is truthy and attr2 is falsy, add value
  *  plainstring : use this class literally
    *  
  */
  Mustache.registerHelper("withclass", function() {
    var options = arguments[arguments.length - 1]
    , exprs = preprocessClassString(arguments[0])
    , that = this.___st4ck ? this[this.length-1] : this
    , hash = quickHash(arguments[0], quickHash(that._cid)).toString(36)
    //, content = options.fn(this).trim()
    //, index = content.indexOf("<") + 1

    // while(content[index] != " ") {
    //   index++;
    // }
    function classbinding(el, ev, newVal, oldVal) {
      $(el).attr("class", buildClassString(exprs, this));
    }


    function hookupfunc(el, parent, view_id) {
      var content = options.fn(that);

      if(content) {
        var frag = can.view.frag(content, parent);
        var $newel = $(frag.querySelector("*"));
        el.parentNode ? el.parentNode.replaceChild($newel[0], el) : $(parent).append($newel);
        el = $newel[0];
      } else {
        //we are inside the element we want to add attrs to.
        var p = el.parentNode
        p.removeChild(el)
        el = p;
      }
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

  /**
    Add a live bound attribute to an element, avoiding buggy CanJS attribute interpolations.
    Usage:
    {{#withattr attrname attrvalue attrname attrvalue...}}<element/>{{/withattr}} to apply to the child element
    {{{withattr attrname attrvalue attrname attrvalue...}}} to apply to the parent element a la XSLT <xsl:attribute>. Note the triple braces!
    attrvalue can take mustache tokens, but they should be backslash escaped.
  */
  Mustache.registerHelper("withattr", function() {
    var args = can.makeArray(arguments).slice(0, arguments.length - 1)
    , options = arguments[arguments.length - 1]
    , attribs = []
    , that = this.___st4ck ? this[this.length-1] : this
    , data = can.extend({}, that)
    , hash = quickHash(args.join("-"), quickHash(that._cid)).toString(36)
    , attr_count = 0;

    var hook = can.view.hook(function(el, parent, view_id) {
      var content = options.fn(that);

      if(content) {
        var frag = can.view.frag(content, parent);
        var $newel = $(frag.querySelector("*"));
        var newel = $newel[0];

        el.parentNode ? el.parentNode.replaceChild(newel, el) : $(parent).append($newel);
        el = newel;
      } else {
        //we are inside the element we want to add attrs to.
        var p = el.parentNode
        p.removeChild(el)
        el = p;
      }

      function sub_all(el, ev, newVal, oldVal) {
        var $el = $(el);
        can.each(attribs, function(attrib) {
          $el.attr(attrib.name, $("<div>").html(can.view.render(attrib.value, data.serialize ? data.serialize() : data)).html());
        })
      }

      for(var i = 0; i < args.length - 1; i += 2) {
        var attr_name = args[i];
        var attr_tmpl = args[i + 1];
        //set up bindings where appropriate
        attr_tmpl = attr_tmpl.replace(/\{[^\}]*\}/g, function(match, offset, string) {
          var token = match.substring(1, match.length - 1);
          if(typeof data[token] === "function") {
            data[token].bind && data[token].bind("change." + hash, $.proxy(sub_all, that, el));
            data[token] = data[token].call(that);
          }

          that.bind && that.bind(token + "." + hash, $.proxy(sub_all, that, el));

          return "{" + match + "}";
        });
        can.view.mustache("withattr_" + hash + "_" + (++attr_count), attr_tmpl);
        attribs.push({name : attr_name, value : "withattr_" + hash + "_" + attr_count });
      }

      sub_all(el);

    });

    return "<div"
    + hook
    + " data-replace='true'/>";
  });


  var controlslugs = function() {
    var slugs = [];
    slugs.push((this.title && this.title.length > 15 )? this.title.substr(0, 15) + "..." : this.title);
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
    return slugs.join(arguments.length > 1 ? arguments[0] : " ");
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
  var that = this, _val1, _val2;
  function exec() {
    if(_val1 == _val2) return options.fn(that);
    else return options.inverse(that);
  }
    if(typeof val1 === "function") { 
      if(val1.isComputed) {
        val1.bind("change", function(ev, newVal, oldVal) {
          _val1 = newVal;
          return exec();
        });
      }
      _val1 = val1.call(this);
    } else {
      _val1 = val1;
    }
    if(typeof val2 === "function") { 
      if(val2.isComputed) {
        val2.bind("change", function(ev, newVal, oldVal) {
          _val2 = newVal;
          exec();
        });
      }
      _val2 = val2.call(this);
    } else {
      _val2 = val2;
    }

  return exec();
});

Mustache.registerHelper("if_null", function(val1, options) {
  var that = this, _val1;
  function exec() {
    if(_val1 == null) return options.fn(that);
    else return options.inverse(that);
  }
    if(typeof val1 === "function") { 
      if(val1.isComputed) {
        val1.bind("change", function(ev, newVal, oldVal) {
          _val1 = newVal;
          return exec();
        });
      }
      _val1 = val1.call(this);
    } else {
      _val1 = val1;
    }
  return exec();
});

can.each(["firstexist", "firstnonempty"], function(fname) {
  Mustache.registerHelper(fname, function() {
    var args = can.makeArray(arguments).slice(0, arguments.length - 1);
    for(var i = 0; i < args.length; i++) {
      var v = args[i];
      if(typeof v === "function") v = v.call(this);
      if(v != null && (fname === "firstexist" || !!(v.toString().trim().replace(/&nbsp;|\s|<br *\/?>/g, "")))) return v.toString();
    }
    return "";
  });
});

Mustache.registerHelper("pack", function() {
  var options = arguments[arguments.length - 1];
  var objects = can.makeArray(arguments).slice(0, arguments.length - 1);
  var pack = new can.Observe();
  can.each(objects, function(obj, i) {
      if(typeof obj === "function") {
          objects[i] = obj = obj();
      }
    if(obj instanceof can.Observe) {
      obj.bind("change", function(ev, attr, how, newVal, oldVal) {
        var tokens, idx, subobj;
        switch(how) {
        case "remove":
        case "add":
        tokens = attr.split(".");
        idx = tokens.pop();
        subobj = can.getObject(tokens.join("."), pack);
        subobj && (subobj instanceof can.Observe.List 
          ? subobj.splice.apply(subobj, how === "remove" ? [+idx, 1] : [+idx, 0, newVal])
          : pack.attr(attr, newVal));
        break;
        default:          
        pack.attr(attr, newVal);
        }
      });
    } 
    pack.attr(typeof obj === "object" && obj.serialize ? obj.serialize() : obj);
  });
  if(options.hash) {
    can.each(Object.keys(options.hash), function(key) {
      if(typeof options.hash[key] === "function") {
        options.hash[key] = options.hash[key]();
      }
    });
    pack.attr(options.hash);
  }
  pack.attr("packed", pack.serialize()); //account for Can 1.1.3 not constructing context stack properly
  var retval = options.fn(pack);
  return retval;
});


Mustache.registerHelper("is_beta", function(){
  var options = arguments[arguments.length - 1];
  if($(document.body).hasClass('BETA')) return options.fn(this);
  else return options.inverse(this);
});

Mustache.registerHelper("if_page_type", function(page_type, options) {
  var options = arguments[arguments.length - 1];
  if (window.location.pathname.split('/')[1] == page_type)
    return options.fn(this);
  else
    return options.inverse(this);
});

Mustache.registerHelper("render", function(template, context, options) {
  if(!options) {
    options = context;
    context = this;
  }

  if(typeof context === "function") {
    context = context();
  }

  if(typeof template === "function") {
    template = template();
  }

  return can.view.render(template, context.serialize ? context.serialize() : context);
});

Mustache.registerHelper("pbc_is_read_only", function() {
  var options = arguments[arguments.length - 1];
  if (window.location.pathname.split('/')[1] == 'pbc_lists')
    return options.inverse(this);
  else
    return options.fn(this);
});

Mustache.registerHelper("with_line_breaks", function(content) { 
  var value = typeof content === "function" ? content() : content;
  if (value && value.search(/<\w+[^>]*>/) < 0)
    return value.replace(/\n/g, "<br />");
  else
    return value;
});

Mustache.registerHelper("related_count", function() {
  var objects = 0;
  can.each(this.list, function(item) {
    objects += item.related_objects.length;
  });
  return objects.toString();
});

Mustache.registerHelper("show_expander", function() {
  var options = arguments[arguments.length - 1]
  , args = can.makeArray(arguments).slice(0, arguments.length - 1)
  , disjunctions = [[]];
  for(var i = 0; i < args.length; i++) {
    if(args[i] === "||") {
      disjunctions.push([]);
    } else {
      disjunctions[disjunctions.length - 1].push(args[i]);
    }
  }

  return can.reduce(disjunctions, function(a, b) {
    return a || can.reduce(b, function(c, d) {
      typeof d === "function" && (d = d());
      return c && (d && (d.length == null || d.length > 0));
    }, true);
  }, false) ? options.fn(this) : options.inverse(this); 
});

})(this, jQuery, can);
