/**
 * Adapted from:
 *   http://www.west-wind.com/weblog/posts/2008/Oct/13/Client-Templating-with-jQuery
 *   http://ejohn.org/blog/javascript-micro-templating/
 */

!function($) {

  "use strict"; // jshint ;_;

  $.tmpl = function(str, data) {
    var err, func, strFunc;

    try {
      func = $.tmpl.cache[str]
      if (!func) {
        func = $.tmpl.parse(str);
        $.tmpl.cache[str] = func;
      }

      if (data)
        return func(data);
      else
        return func;
    } catch (e) {
      err = e.message;
      return "< % ERROR: " + err + " % >";
    }
  }

  $.tmpl.cache = {};
  $.tmpl.parse = function(str) {
    var strFunc =
      "var p=[],print=function(){p.push.apply(p,arguments);};" +
      "with(obj){p.push('" +
      str.replace(/[\r\t\n]/g, " ")
         .replace(/'(?=[^%]*%>)/g, "\t")
         .split("'").join("\\'")
         .split("\t").join("'")
         .replace(/<%=(.+?)%>/g, "',$1,'")
         .replace(/&lt;%=(.+?)%&gt;/g, "',$1,'")
         .split("<%").join("');")
         .split("%>").join("p.push('")
      + "');}return p.join('');";
    return new Function("obj", strFunc);
  }

  $.fn.tmpl = function(data) {
    if (this.is('[type="text/html"]')) {
      // Parse and render this element as a template
      return $.tmpl(this.html(), data);
    } else {
      return this.html($.tmpl.apply(this, arguments));
    }
  };

  $.fn.tmpl_additem = function(data) {
    return this.each(function() {
      var $this = $(this)
        , $tmpl = $this.siblings('script[type="text/html"]').add($this.find('> script[type="text/html"]'))
        , locals = $.extend($tmpl.data(), data)
        , output = $tmpl.tmpl(locals);
      ($this.is('ul') ? $this : $this.find('> ul')).append(output);
    });
  };

}(jQuery);
