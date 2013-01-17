/*
 *= require application
 *= require jquery
 *= require fastfix
 *= require jquery-ui
 *= require bootstrap
 *= require related_selector
 *= require single_selector
 *= require spin.min
 *= require tmpl
 *= require can.jquery-all
 *= require mustache_helper
 *= require_tree ./apps
 *= require_self
 *= require jquery.remotipart
 *= require d3.v2
 *= require related
 *= require related_graph
 */

// Initialize delegated event handlers
jQuery(function($) {

  // Before submitting, remove any disabled form elements
  $('body').on('submit', 'form[data-remote]', function(e, xhr, req) {
    $(this)
      .find('.disabled input, .disabled select, .disabled textarea')
      .each(function(i, el) {
        $(el).attr('name', '');
      });
  });

  // On-demand creation of datepicker() objects
  $('body').on('focus', '[data-toggle="datepicker"]', function(e) {
    var $this = $(this);

    if (!$this.data('datepicker'))
      $(this).datepicker({changeMonth: true, changeYear: true, dateFormat: 'mm/dd/yy'});
  });

  /* FIXME: This was removed because it's inconsistent with the new slug
       object-name-prefix paradigm.  (E.g. controls having slug of CONTROL-X).
  // Setup program-select inputs to prefill slug field
  $('body').on('change', 'select[name$="[program_id]"]', function(e) {
    var $this = $(this)
      , $form = $(this).closest('form')
      , $option = $(this).find('option[value="' + $(this).val() + '"]')
      , $slugfield = $form.find('input[name$="[slug]"]').first()
      , slugsteps = $slugfield.val().split(/-/);

    $slugfield.val([$option.text()].concat(slugsteps.slice(1)).join("-"));
  });
  */

  // Turn the arrow when tree node content is shown
  $('body').on('click', '[data-toggle="collapse"]', function(e) {
    var $this = $(this)
      , $expander_container = $this.closest(':has(.expander, .enddot)')
      , $expander = $expander_container.find('.expander').eq(0)
      , $target = $($this.data('target'))
      ;

    setTimeout(function() {
      if ($target.hasClass('in'))
        $expander.addClass('in');
      else
        $expander.removeClass('in');
    }, 100);
  });

  // When clicking a slot-link, don't toggle collapse
  // FIXME: We should avoid hacks like this
  $('body').on('click', '.slot > a', function(e) {
    e.stopPropagation();
  });

  // expandAll and shrinkAll buttons
  $('body').on('click', '.tabbable a.expandAll', function(e) {
    $(this).closest('.tabbable').find('.tab-pane:visible').find('.collapse').collapse({ toggle: false }).collapse('show');
  });
  $('body').on('click', '.tabbable a.shrinkAll', function(e) {
    $(this).closest('.tabbable').find('.tab-pane:visible').find('.collapse').collapse({ toggle: false }).collapse('hide');
  });

  // Tabs via AJAX on 'Quick Find'
  $('body').on('show', '.tabbable ul.nav-tabs > li > a', function(e, href) {
    var $tab = $(e.target)
      , loaded = $tab.data('tab-loaded')
      , pane = ($tab.data('tab-target') || $tab.attr('href'))
      , template = "<div></div>";

    if (href)
      loaded = false;
    else
      href = $tab.data('tab-href');

    if (!href) return;
    if (href === 'reset') {
      $tab.data('tab-loaded', false);
      return;
    }

    if (!loaded) {
      if (template) {
        var spinner = new Spinner({ }).spin();
        $(pane).html(spinner.el);
        // Scroll up so spinner doesn't get pushed out of visibility
        $(pane).scrollTop(0);
        $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px' });
      }

      $(pane).load(href, function(data, status, xhr) {
        $tab.data('tab-loaded', true);
        $(this).html(data);
      });
    }
  });

  // Clear the .widgetsearch box when tab is changed
  $('body').on('show', '.tabbable ul.nav-tabs > li > a', function(e) {
    if (e.relatedTarget) {
      $input = $(this).closest('.WidgetBox').find('.widgetsearch');
      if ($input.val()) {
        $input.val("");
        $(e.relatedTarget).trigger('show', 'reset');
      }
    }
  });

  //After the modal template has loaded from the server, but before the
  //  data has loaded to populate into the body, show a spinner
  $("body").on("loaded", ".modal.modal-slim", function(e) {
    $(e.target).find(".modal-body .source").html(
          $(new Spinner().spin().el)
            .css({
              width: '100px', height: '100px',
              left: '50px', top: '50px'
            })
      )
  });

  function with_params(href, params) {
    if (href.charAt(href.length - 1) === '?')
      return href + params;
    else if (href.indexOf('?') > 0)
      return href + '&' + params;
    else
      return href + '?' + params;
  }

  $('body').on('focus', '.modal .widgetsearch', function(e) {
    $(this).bind('keypress', function(e) {
      if (e.which == 13) {
        // If this input is within a form, don't submit the form
        e.preventDefault();

        var $this = $(this)
          , $list = $this.closest('.modal').find('ul.source[data-list-data-href]')
          , href = with_params($list.data('list-data-href'), $.param({ s: $this.val() }));
        $.get(href, function(data) {
          $list.tmpl_setitems(data);
        });
      }
    });
  });

  // Initialize Quick Search handlers
  $('body').on('keypress', '.modal nav > .widgetsearch', function (e) {
    if (e.which == 13) {
      // If this input is within a form, don't submit the form
      e.preventDefault();

      var $this = $(this)
        , $list = $this.closest('.modal').find('.modal-body ul[data-list-href]')
        , href = with_params($list.data('list-href'), $.param({ s: $this.val() }));
      $.get(href, function(data) {
        $list.tmpl_setitems(data);
      });
    }
  });
  $('body').on('keypress', '.WidgetBox nav > .widgetsearch', function (e) {
    if (e.which == 13) {
      var $this = $(this)
        , $tab = $this.closest('.WidgetBox').find('ul.nav-tabs > li.active > a')
        , href = with_params($tab.data('tab-href'), $.param({ s: $this.val() }));
      $tab.trigger('show', href);
      $tab.trigger('kill-all-popovers');
    }
  });
  $('body').on('keypress', 'nav > .widgetsearch-tocontent', function (e) {
    if (e.which == 13) {
      var $this = $(this)
        , $box = $this.closest('.WidgetBox').find('.WidgetBoxContent')
        , $child = $($box.children()[0])
        , href = with_params($child.data('href'), $.param({ s: $this.val() }));
      $box.load(href, function() { clear_selection($this[0], true); });
    }
  });

  $('body').on('click', '[data-toggle="list-remove"]', function(e) {
    e.preventDefault();
    $(this).closest('li').remove();
  });

  $('body').on('click', '[data-toggle="list-select"]', function(e) {
    e.preventDefault();

    var $this = $(this)
      , $li = $this.closest('li')
      , target = $li.closest('ul').data('list-target')
      , data;

    if (target) {
      data = $.extend({}, $this.data('context') || {}, $this.data());
      $(target).tmpl_mergeitems([data]);
    }
  });

  $('body').on('click', '[data-toggle="dropdown-select-list"] > li > a', function(e) {
    var $this = $(this)
      , value = $(this).data('value')
      ;
    $this.closest('ul').siblings('input').val(value);
    $this.closest('ul').siblings('a').text(value[0].toUpperCase() + value.substr(1));
    $this.trigger('change');
    e.preventDefault();
  });

  $('body').on('click', '[data-toggle="collapse-additional"]', function(e) {
    if (!e.isDefaultPrevented()) {
      $(this).siblings('.additional').slideToggle();
    }
  });
});

jQuery(function($) {
  // Onload trigger tab with 'active' class or default to first tab
  $('.tabbable > ul').each(function(i, el) {
    var $tab = $(this).find('> li.active');
    if (!$tab.length)
      $tab = $(this).find('> li:first-child');
    $tab
      .removeClass('active')
      .find('> a')
      .tab('show');
  });
  //$('.tabbable > ul > li:first-child > a').tab('show');
});


// Regulation mapping
function init_mapping() {
  $('#section_list')
    .on("ajax:success", '.selector', function(evt, data, status, xhr){
      $('#selected_sections').replaceWith(xhr.responseText);

      // Resize textareas to avoid scrollable-inside-scrollable
      $('#selected_sections textarea').each(function() {
        var $this = $(this);
        $this.height(10).height($this[0].scrollHeight - 8);
      });

      $('#section_list .selector').closest('.regulationslot').removeClass('selected');
      $(this).closest('.row-fluid').find('.regulationslot').addClass('selected');

      var $dialog = $('#mapping_dialog');
      if ($dialog.length > 0 && $dialog.is(':visible')) {
        $dialog.load($(this).closest('.row-fluid').find('a.controllist, a.controllistRM').data('href'));
      }
    });
  $('#rcontrol_list')
    .on("ajax:success", '.selector', function(evt, data, status, xhr){
      $('#selected_rcontrol').replaceWith(xhr.responseText);
      $('#rcontrol_list .selector').closest('.item').removeClass('selected');
      $(this).closest('.item').addClass('selected');
    });
  $('#ccontrol_list')
    .on("ajax:success", '.selector', function(evt, data, status, xhr){
      $('#selected_ccontrol').replaceWith(xhr.responseText);
      $('#ccontrol_list .selector').closest('.item').removeClass('selected');
      $(this).closest('.item').addClass('selected');
    });

  $('#rmap, #cmap')
    // Prevent disabled buttons from triggering AJAX requests
    .on('ajax:beforeSend', function(evt, xhr, request) {
      if ($(this).is('[disabled="disabled"]'))
        return false;
    })
    .on('ajax:success', function(evt, data, status, xhr) {
      var $dialog = $('#mapping_dialog');
      update_map_buttons();
      if ($dialog.length > 0 && $dialog.is(':visible'))
        $dialog.load($dialog.data('href'));
    });
}


function clear_selection(el, keep_search) {
  var $box = $(el).closest('.WidgetBox');

  $box.find('.selected').removeClass('selected');

  if (!keep_search) {
    var $searchbox = $box.find('.widgetsearch-tocontent');
    if ($searchbox.val().length > 0) {
      $searchbox.val("");
      $searchbox.trigger({type: 'keypress', 'which': 13});
    }
  }

  //description_el = $(el).closest('.WidgetBox').parent().next().find('.WidgetBoxContent .description .content')
  //$(description_el).replaceWith('Nothing selected.');
  $box.parent().next().find('.WidgetBoxContent .description').attr('oid', '');

  update_map_buttons();
}

// This is only used by import to redirect on successful import
// - this cannot use other response headers because it is proxied through
//   an iframe to achieve AJAX file upload (using remoteipart)
jQuery(function($) {
  $('body').on('ajax:success', 'form.import', function(e, data, status, xhr) {
    if (xhr.getResponseHeader('Content-Type') == 'application/json') {
      window.location.assign($.parseJSON(data).location);
    }
  });
});

jQuery(function($) {
  $('body').on('ajax:success', 'form[data-remote][data-update-target]', function(e, data, status, xhr) {
    if (xhr.getResponseHeader('Content-Type') == 'text/html') {
      $($(this).data('update-target')).html(data);
    }
  });
});


jQuery(function($) {
  $('body').on('ajax:success', '#helpedit form', function(e, data, status, xhr) {
    $(this).closest('.modal')
      .find('.modal-header h1').html(data.help.title);
    $(this).closest('.modal')
      .find('.modal-body p').html(data.help.content);
  });
});

jQuery(function($) {
  $('body').on('change', 'select[name="category[scope_id]"]', function(e) {
    var $this = $(this)
      , scope_id = $this.val()
      , $cats = $this.closest('form').find('select[name="category[parent_id]"]')
      ;
    $cats.empty();
    $.get('/categories', { scope_id: scope_id, root: 1 }, function(data) {
      $cats.append("<option value=''>&lt;New root object&gt;</option>");
      $.map(data, function(cat, i) {
        $cats.append('<option value="' + cat.category.id + '">' + cat.category.name + '</option>');
      });
    });
  });
});

// Filters on PBC List
jQuery(function($) {
  $('body').on('change', '[data-toggle="filter-requests"]', function(e) {
    var $this = $(this)
      , filter_target = '.pbc-requests > li'
      , filter_func = function() { return true; }
      , target_container = '.pbc-control-assessments > li'
      ;

    $('[data-toggle="filter-requests"]').each(function(i, elem) {
      var $elem = $(elem)
        , filter_attr = $elem.data('filter-attribute')
        , filter_value = $elem.val()
        , old_filter_func = filter_func
        ;

      if ($elem.val() == 'any' || $elem.val() == '')
        return;

      if (filter_attr == 'type-name' || filter_attr == 'status') {
        filter_func = function($el) {
          return (
            ($el.data('filter-' + filter_attr) == filter_value) &&
            old_filter_func($el));
        }
      } else if (filter_attr == 'date-requested') {
        filter_func = function($el) {
          return (
            ($el.data('filter-' + filter_attr) &&
             // We use "+ ' UTC'" to avoid strange timezone conversions
             // due to differing date formats
             (Date.parse($el.data('filter-' + filter_attr) + ' UTC') >= Date.parse($elem.val() + ' UTC'))) &&
            old_filter_func($el));
        }
      } else if (filter_attr == 'person') {
        filter_func = function($el) {
          return (
            (new RegExp('(^|,)' + $elem.val() + '(,|$)').test($el.data('filter-' + filter_attr))) &&
            old_filter_func($el));
        }
      }
    });

    // For each container element, hide it if it contains no unfiltered elements
    $(target_container).each(function(i, container) {
      var $container = $(container)
        , has_visible_item = false
        ;

      $container.find(filter_target).each(function(i, elem) {
        var $elem = $(elem)
          ;

        if (!filter_func($elem)) {
          $elem.slideUp('fast');
        } else {
          has_visible_item = true;
          $elem.slideDown('fast');
        }
      });

      if (!has_visible_item) {
        $container.slideUp('fast');
      } else {
        $container.slideDown('fast');
      }
    });
  });
});

jQuery(function($) {
  $("body").on("change", ".pbc-requests .main-item", function(ev) {
    if($(ev.target).parents().is(".pbc-status")) {
      var status = $(ev.target).val();
      $.ajax({
        url : "/requests/" + $(ev.currentTarget).data("filter-id") + ".json"
        , type : "put"
        , dataType : "json"
        , data : {
          request : {
            status : status
          }
        }
      })
      .then(function() {
        $(ev.currentTarget).attr("data-filter-status", status).data("filter-status", status);
      });
    }
  });
});

jQuery(function($) {
  $('body').on('click', 'button[data-toggle="filter-reset"]', function(e) {
    var $this = $(this)
      , filter_reset_target = '[data-toggle="filter-requests"]'
      ;

    $(filter_reset_target).each(function(i, elem) {
      var $elem = $(elem)
        ;

      $elem.val('any');
      $elem.change();
    });
  });
});

jQuery(function($) {
  // Used in object_list sidebars (References, People, Categories)
  $('body').on('modal:success', '.js-list-container-title a', function(e, data) {
    var $this = $(this)
      , $title = $this.closest('.js-list-container-title')
      , $span = $title.find('span')
      , $expander = $title.find('.expander').eq(0)
      ;

    $span.text(data.length);
    if (data.length > 0)
      $span.removeClass('no-object');
    else
      $span.addClass('no-object');

    if (!$expander.hasClass('in')) {
      $expander.click();
    }
  });
});

// Sorting on PBC List
jQuery(function($) {
  var sort_elements, compare_values
    , extract_control_code, sort_by_control_code
    , extract_request_date, sort_by_request_date
    , trigger_sort
    ;

  // Compare arrays specially
  compare_values = function(a, b) {
    var i;
    if ($.isArray(a) && $.isArray(b)) {
      for (i=0; i<a.length; i++) {
        result = compare_values(a[i], b[i]);
        if (result != 0)
          return result;
      }
      return (a.length == b.length ? 0 : (a.length < b.length ? -1 : 1));
    } else {
      return (a == b ? 0 : (a < b) ? -1 : 1)
    }
  }

  // Not a pretty sort function
  sort_elements = function($els, key_func, reversed) {
    comparison_func = function(a, b) {
      return compare_values(key_func(a), key_func(b));
    }
    var els = $els.toArray().sort(comparison_func);
    if (reversed)
      els = els.reverse();
    return $(els);
  }

  extract_control_code = function(li) {
    var code_string = $(li).data('sort-control-code');
    if (!code_string)
      return [];
    else
      // Split around numbers so CTL5 < CTL10
      return $.map(
        code_string.split(/(\d+)/),
        function(x) { return isNaN(parseInt(x)) ? x : parseInt(x) })
  }

  sort_by_control_code = function(reversed) {
    var $ul = $('ul.pbc-control-assessments');
    $ul.html(sort_elements($ul.find('> li'), extract_control_code, reversed));
  }

  extract_request_date = function(li) {
    var date_string = $(li).data('filter-date-requested') || '0';
    // We use "+ ' UTC'" to avoid strange timezone conversions
    // due to differing date formats
    return Date.parse(date_string + ' UTC');
  }

  sort_by_request_date = function(reversed) {
    $('ul.pbc-control-assessments > li').each(function(i) {
      var $ul = $(this).find('ul.pbc-requests:last');
      $ul.html(sort_elements($ul.find('> li'), extract_request_date, reversed));
    });
  }

  trigger_sort = function() {
    var sort_type, reversed;
    sort_type = $('#sortTypeSelect').val();
    reversed = $('#sortDirectionReverse').hasClass('active');

    if (sort_type == 'Control Code')
      sort_by_control_code(reversed);
    else if (sort_type == 'Request Date')
      sort_by_request_date(reversed);
  };

  $('body').on('click', '#sortDirectionForward, #sortDirectionReverse', function(e) {
    $('#sortDirectionForward, #sortDirectionReverse').removeClass('active');
    $(this).addClass('active');
    trigger_sort();
  });

  $('body').on('change', '#sortTypeSelect', function(e) {
    trigger_sort();
  });
});

if(!/\/mapping/.test(window.location.href)) {
  jQuery(function($) {
    var $dialog = $('<div id="mapping_dialog" class="modal hide"></div>').appendTo('body');
    $dialog.draggable({ handle: '.modal-header' });
    $('#regulations, #controls, #section_list').on('click', 'a.controllist, a.controllistRM', function(e) {
      e.preventDefault();
      $dialog.data('href', $(this).attr('href'));
      $dialog.load($(this).attr('href'), function() {
        $dialog.modal_form({ backdrop: false }).modal_form('show');
      });
    });

    $dialog.on('ajax:success', '.unmapbtn', function(evt, data, status, xhr) {
      $dialog.load($dialog.data('href'));
    });
  });
}

