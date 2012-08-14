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

  $.tmpl.render_items = function($list, list) {
    var $tmpl = $list.siblings('script[type="text/html"]').add($list.find('> script[type="text/html"]'))
      , defaults = $.extend({}, $tmpl.data('context'), $tmpl.data(), $list.data('context'), $list.data())
      , output = [];
    $.each(list, function(i, data) {
      output.push($tmpl.tmpl($.extend(defaults, data)));
    });
    return output.join('');
  };

  $.fn.tmpl_additem = function(data) {
    return this.tmpl_additems([data]);
  };

  $.fn.tmpl_additems = function(list) {
    return this.each(function() {
      var $this = $(this)
        , $output = $($.tmpl.render_items($this, list));
      ($this.is('ul') ? $this : $this.find('> ul')).append($output);
    });
  };

  $.fn.tmpl_mergeitems = function(list) {
    return this.each(function() {
      var $this = $(this)
        , $el;

      $.each(list, function(i, data) {
        if (data.id)
          $el = $this.find('> [data-id="' + data.id + '"]');
        if (!$el.length) {
          $el = $($.tmpl.render_items($this, [data]));
          $this.append($el);
        }

        $el.removeClass('flare').addClass('flaretemp');
        setTimeout(function() {
          $el.removeClass('flaretemp').addClass('flare');
        }, 100);
      });
    });
  };

  $.fn.tmpl_setitems = function(list) {
    return this.each(function() {
      var $this = $(this)
        , output = $.tmpl.render_items($this, list);
      ($this.is('ul') ? $this : $this.find('> ul')).html(output);
    });
  };
}(jQuery);
