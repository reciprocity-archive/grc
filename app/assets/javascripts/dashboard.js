/*
 *= require application
 *= require jquery
 *= require jquery-migrate
 *= require fastfix
 *= require jquery-ui
 *= require bootstrap
 *= require related_selector
 *= require single_selector
 *= require spin.min
 *= require tmpl
 *= require can.jquery-all
 *= require mustache_helper
 *= require_tree ./models
 *= require_tree ./controllers
 *= require_tree ./apps
 *= require sections/notes_controller.js
 *= require_self
 *= require jquery.remotipart-patched
 *= require d3.v2
 *= require related
 *= require related_graph
 */

  window.cms_singularize = function(type) {
    type = type.trim();
    var _type = type.toLowerCase();
    switch(_type) {
      case "facilities":
      type = type[0] + "acility"; break;
      case "people":
      type = type[0] + "erson"; break;
      case "processes":
      type = type[0] + "rocess"; break;
      case "systems_processes":
      type = type[0] + "ystem_" + type[8] + "rocess";
      break;
      case "policies":
      type = type[0] + "olicy"; break;
      default:
      type = type.replace(/e?s$/, "");
    }

    return type;
  }

// Initialize delegated event handlers
jQuery(function($) {

  window.calculate_spinner_z_index = function() {
      var zindex = 0;
      $(this).parents().each(function() {
        var z;
        if(z = parseInt($(this).css("z-index"))) {
          zindex = z;
          return false;
        }
      });
      return zindex + 10;
    } 


  window.natural_comparator = function(a, b) {
    a = a.slug.toString();
    b = b.slug.toString();
    if(a===b) return 0;

    a = a.replace(/(?=\D\d)(.)|(?=\d\D)(.)/g, "$1$2|").split("|");
    b = b.replace(/(?=\D\d)(.)|(?=\d\D)(.)/g, "$1$2|").split("|")

    for(var i = 0; i < Math.max(a.length, b.length); i++) {
      if(+a[i] === +a[i] && +b[i] === +b[i]) {
        if(+a[i] < +b[i]) return -1;
        if(+b[i] < +a[i]) return 1;
      } else { 
        if(a[i] < b[i]) return -1;
        if(b[i] < a[i]) return 1;
      }
    }
    return 0;
  }

  // put the related widget on the related element.
  $("#related").cms_controllers_related({});

  // Display spinners included in initial page load
  $('.spinner').each(function() {
    var spinner = new Spinner({ }).spin();
    $(this).html(spinner.el);
    // Scroll up so spinner doesn't get pushed out of visibility
    $(this).scrollTop(0);
    $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px', zIndex : calculate_spinner_z_index});
  });

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
  // Setup directive-select inputs to prefill slug field
  $('body').on('change', 'select[name$="[directive_id]"]', function(e) {
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
  $('body').on('click', 'a.expandAll', function(e) {
    var $tabs = $(this).closest('.tabbable');
    if($tabs.length) {
      $tabs.find('.tab-pane.active .openclose').openclose("open");
      //$tabs.find('.tab-pane.active .tree-structure .oneline').oneline("view");
    } else {
      var $section = $(this).closest("section");
      $section.find('.openclose').openclose("open");
      //$section.find('.tree-structure .oneline').oneline("view");
    }
    e.preventDefault();
  });
  $('body').on('click', 'a.shrinkAll', function(e) {
    var $tabs = $(this).closest('.tabbable');
    if($tabs.length) {
      $tabs.find('.tab-pane.active .openclose.active').openclose('close');
      //$tabs.find('.tab-pane.active .tree-structure .oneline').oneline("hide");
    } else {
      var $section = $(this).closest("section");
      $section.find('.openclose.active').openclose("close");
      //$section.find('.tree-structure .oneline').oneline("hide");
    }
    e.preventDefault();
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
        $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px', zIndex : calculate_spinner_z_index });
      }

      $(pane).load(href, function(data, status, xhr) {
        $tab.data('tab-loaded', true);
        var $data = $(data);
        $(e.target).find(".item-count").html($data.find("li").length);
        $(this).html($data).trigger("loaded", xhr, data);
      });
    }
  });

  // // Clear the .widgetsearch box when tab is changed
  // $('body').on('show', '.tabbable ul.nav-tabs > li > a', function(e) {
  //   if (e.relatedTarget) {
  //     $input = $(this).closest('.widget').find('.widgetsearch');
  //     if ($input.val()) {
  //       $input.val("");
  //       $(e.relatedTarget).trigger('show', 'reset');
  //     }
  //   }
  // });

  //After the modal template has loaded from the server, but before the
  //  data has loaded to populate into the body, show a spinner
  $("body").on("loaded", ".modal.modal-slim, .modal.modal-wide", function(e) {

    var spin = function() {
      $(this).html(
        $(new Spinner().spin().el)
          .css({
            width: '100px', height: '100px',
            left: '50%', top: '50%',
            zIndex : calculate_spinner_z_index
          })
      ).one("loaded", function() {
        $(this).find(".source").each(spin);
      });
    }

    $(e.target).find(".modal-body .source").each(spin);
  });

  function with_params(href, params) {
    if (href.charAt(href.length - 1) === '?')
      return href + params;
    else if (href.indexOf('?') > 0)
      return href + '&' + params;
    else
      return href + '?' + params;
  }

  // Handle search on related_selectors
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
          $list.closest('.modal').trigger('sync-lists');
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
  $('body').on('keypress', '.widget .widgetsearch', function (e) {
    if (e.which == 13) {
      var $this = $(this)
        , $tab = $this.closest('.widget').find('ul.nav-tabs > li.active > a')
        , href = with_params($tab.data('tab-href'), $.param({ s: $this.val() }));
      $tab.trigger('show', href);
      $tab.trigger('kill-all-popovers');
    }
  });
  $('body').on('keypress', 'nav > .widgetsearch-tocontent', function (e) {
    if (e.which == 13) {
      var $this = $(this)
        , $box = $this.closest('.widget').find('.content')
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
    $($tab.find('> a').attr("href")).one("loaded", function() {
      if($tab.not(".quick-search-results .tabbable > ul > li").length) { //don't load the quickfind
        setTimeout(function() {
          $tab.siblings().find("> a").trigger("show"); //load all the others for counts after this one is showing
        }, 100);
      }
    })
  });
  //$('.tabbable > ul > li:first-child > a').tab('show');
});

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
 function refresh_page() {
    setTimeout(can.proxy(window.location.reload, window.location), 10);
  }

  $('body').on('ajax:complete', '[data-ajax-complete="refresh"]', refresh_page);
});

jQuery(function($) {
  $('body').on('change', 'form.import input#upload', function(e) {
    var $this = $(this)
      , value = $this.val()
      ;

    if ($this.data('last-value') != value) {
      $this.closest('form').find('#results-container').empty();
      $this.data('last-value', value);
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
    var $modal = $(this).closest('.modal');
    $modal.find('.modal-header h1').html(data.help.title);
    $modal.find('.modal-body .help-content').html(data.help.content);
    $modal.find('.modal-body #helpedit').collapse('hide');
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
    if($(ev.target).parents().is(".status")) {
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

  if($.fn.pbc_autocomplete_people) {
    $(".pbc-request-assignee").pbc_autocomplete_people({
      select : function(event, ui) {
        $(event.target).trigger("personSelected", ui.item);
        can.Control.prototype.bindXHRToButton(
        $.ajax({
          type : "put"
          , url : "/requests/" + $(event.target).closest("[data-filter-id]").data("filter-id") + ".json"
          , data : { request : { company_responsible : ui.item.email }}
        }).done(function() {
            $(event.target).parent().removeClass("field-failure");
            $(event.target).blur().data("pbcAutocomplete_people")._value(ui.item.email);
            var oldvalues = $(event.target).closest("[data-filter-person]").data("filter-person").split(",");
            $(event.target).closest("[data-filter-person]").attr("data-filter-person", ui.item.email).data("filter-person", ui.item.email);

            can.each(oldvalues, function(oldvalue) {
              if(!$("[data-filter-person*='" + oldvalue + "']").length) {
                $("select[data-filter-attribute=person] option").each(function() {
                  if($(this).val() === oldvalue) {
                    var $sel = $(this).closest("select");
                    $sel.find("option:first").prop("selected", true);
                    $(this).remove();
                    $sel.change();
                  }
                })
              }
            });
            if(!~can.inArray(ui.item.email, $("select[data-filter-attribute=person] option").map(function() { return $(this).val()}))) {
              $("<option>").text(ui.item.email).appendTo("select[data-filter-attribute=person]");
            } 
        }).fail(function() {
          $(event.target).parent().addClass("field-failure");
        })
        , $(event.target)
        );
        return false;
      }
    });
  }
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

    $span.text("("+(data.length || 0)+")");

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

  $("body").on("list-add-item", '[id^=ajax-modal-controls-list_select]', function(e, data) {
    $(this).find("[data-id=" + data.id + "]").click();
  });



});

//make buttons non-clickable when saving
jQuery(function($) {
  can.extend(can.Control.prototype, {
    bindXHRToButton : function(xhr, el) {
      // binding of an ajax to a click is something we do manually
      $(el).addClass("disabled pending-ajax").attr("disabled", true);
      xhr.always(function() {
        $(el).removeAttr("disabled").removeClass("disabled pending-ajax");
      });
    }
  });
});

jQuery(function($) {
  $('body').on('change', '.modal select[name="system[is_biz_process]"]', function(e) {
    var $this = $(this)
      , $modal = $this.closest('.modal')
      , $header_elem = $modal.find('.modal-header h2')
      ;

    if ($this.val() == '0') {
      $header_elem.text($header_elem.text().replace(/process/i, 'system'));
    } else {
      $header_elem.text($header_elem.text().replace(/system/i, 'process'));
    }
  });
});

jQuery(function($) {

  $('body').on('click', '.clear-display-settings', function(e) {
    CMS.Models.DisplayPrefs.findAll().done(function(data) {
      var destroys = [];
      can.each(data, function(d) {
        d.unbind("change"); //forget about listening to changes.  we're going to refresh the page
        destroys.push(d.resetPagePrefs());
      });
      $.when.apply($, destroys).done($.proxy(window.location, 'reload'));
    });
  })
  .on('click', '.set-display-settings-default', function(e) {
    var page_token = getPageToken();
    CMS.Models.DisplayPrefs.findAll().done(function(data) {
      var destroys = [];
      can.each(data, function(d) {
        d.unbind("change"); //forget about listening to changes.  we're going to refresh the page
        destroys.push(d.setPageAsDefault(page_token));
      });
      $.when.apply($, destroys).done(function() {
        $('body').trigger(
          'ajax:flash', 
          { "success" : "Saved page layout as default for " + (page_token === "programs_dash" ? "dahsboard" : page_token) }
        );
      });
    });
  });
});

//Make all external links open in new window.
jQuery(function($) {
  $("body").on("click", "a[href]:not([target])", function(e) {
    if (!e.isDefaultPrevented()) {
      if(/^http/.test(this.protocol) && this.hostname !== window.location.hostname) {
        e.preventDefault();
        window.open(this.href);
      }
    }
  });
});

//Handler for changing the new object text in dashboard widgets
jQuery(function($){
  $(document.body).on("click", "[id^=quick_find] .nav-tabs li", function(ev) {
    var plural = $(this).find(".text-business, .text-governance, .text-risk").text();
    var singular = can.map(window.cms_singularize(plural).split("_"), can.capitalize).join(" ");
    $(this).closest(".widget").find(".object-type").text(singular).closest("a").attr("href", $(this).find("a").data("new-href"));
  });
});
