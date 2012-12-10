/*
 *= require application
 *= require jquery
 *= require jquery-ui
 *= require bootstrap
 *= require related_selector
 *= require spin.min
 *= require tmpl
 *= require can.jquery-all
 *= require mustache_helper
 *= require apps/controls
 *= require apps/mapping
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
    $(this).find('.expander').eq(0).toggleClass('in');
  });

  // When clicking a slot-link, don't toggle collapse
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

  $('body').on('focus', '.modal .widgetsearch', function(e) {
    $(this).bind('keypress', function(e) {
      if (e.which == 13) {
        // If this input is within a form, don't submit the form
        e.preventDefault();

        var $this = $(this)
          , $list = $this.closest('.modal').find('ul.source[data-list-data-href]')
          , href = $list.data('list-data-href') + '?' + $.param({ s: $this.val() });
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
        , href = $list.data('list-href') + '?' + $.param({ s: $this.val() });
      $.get(href, function(data) {
        $list.tmpl_setitems(data);
      });
    }
  });
  $('body').on('keypress', '.WidgetBox nav > .widgetsearch', function (e) {
    if (e.which == 13) {
      var $this = $(this)
        , $tab = $this.closest('.WidgetBox').find('ul.nav-tabs > li.active > a')
        , href = $tab.data('tab-href') + '?' + $.param({ s: $this.val() });
      $tab.trigger('show', href);
    }
  });
  $('body').on('keypress', 'nav > .widgetsearch-tocontent', function (e) {
    if (e.which == 13) {
      var $this = $(this)
        , $box = $this.closest('.WidgetBox').find('.WidgetBoxContent')
        , $child = $($box.children()[0])
        , href = $child.data('href') + '?' + $.param({ s: $this.val() });
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
