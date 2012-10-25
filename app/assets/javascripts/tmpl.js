/**
 * Adapted from:
 *   http://www.west-wind.com/weblog/posts/2008/Oct/13/Client-Templating-with-jQuery
 *   http://ejohn.org/blog/javascript-micro-templating/
 */

!function($) {

  "use strict"; // jshint ;_;

  $.tmpl = function(str, data, context) {
    var err, func, strFunc;

    try {
      func = $.tmpl.cache[str]
      if (!func) {
        func = $.tmpl.parse(str);
        $.tmpl.cache[str] = func;
      }

      if (data) {
        return func.apply(context, [data]);
        //return func(data);
      } else {
        return func;
      }
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
         .replace(/%3C%=(.+?)%%3E/g, "',$1,'")
         .split("<%").join("');")
         .split("%>").join("p.push('")
      + "');}return p.join('');";
    return new Function("obj", strFunc);
  }

  $.tmpl.context = {
    format_date: function(date_string) {
      var date;
      if (date_string && date_string.length > 0) {
        date = new Date(date_string);
        return [
          (date.getMonth() + 1), '/',
          date.getDate(), '/',
          date.getFullYear()].join("");
      } else {
        return '';
      }
    }
  }

  $.fn.tmpl = function(data, context) {
    context = $.extend({}, context || {}, $.tmpl.context);
    if (this.is('[type="text/html"]')) {
      // Parse and render this element as a template
      return $.tmpl(this.html(), data, context);
    } else {
      return this.html($.tmpl.apply(this, [data, context]));
    }
  };

  $.tmpl.render_items = function($list, list) {
    var $tmpl = null
      , defaults = {}
      , output = []
      , prefix = null
      , mappings = null
      , member = null
      ;

    if ($list.data('template-id')) {
      $tmpl = $('#' + $list.data('template-id'));
    } else {
      $tmpl = $list.siblings('script[type="text/html"]').add($list.find('> script[type="text/html"]'))
    }

    prefix = $tmpl.data('prefix');
    mappings = $tmpl.data('mappings');
    member = $tmpl.data('member');

    defaults = $.extend(defaults, $tmpl.data('context'), $tmpl.data(), $list.data('context'), $list.data());

    $.each(list, function(i, data) {
      var new_data = {}
        , i
        , split_mappings, from_key, to_key
        , split_member, member_key
        ;

      if (member) {
        split_member = member.split(',');
        for (i in split_member) {
          member_key = split_member[i];
          if (data.hasOwnProperty(member_key)) {
            new_data = data[member_key];
            data = new_data;
            break;
          }
        }
      }
      if (mappings) {
        split_mappings = mappings.split(',');
        for (i in split_mappings) {
          from_key = split_mappings[i].split(':')[0];
          to_key = split_mappings[i].split(':')[1];
          if (data.hasOwnProperty(from_key)) {
            data[to_key] = data[from_key];
          }
        }
      }
      if (prefix && !data[prefix]) {
        new_data[prefix] = data
        data = new_data
      }
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
