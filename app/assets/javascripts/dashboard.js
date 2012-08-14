/*
 *= require application
 *= require jquery
 *= require jquery-ui
 *= require bootstrap
 *= require spin.min
 *= require tmpl
 *= require_self
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
      $(this).datepicker({changeMonth: true, changeYear: true, dateFormat: 'yy-mm-dd'});
  });

  // Setup program-select inputs to prefill slug field
  $('body').on('change', 'select[name$="[program_id]"]', function(e) {
    var $this = $(this)
      , $form = $(this).closest('form')
      , $option = $(this).find('option[value="' + $(this).val() + '"]')
      , $slugfield = $form.find('input[name$="[slug]"]').first()
      , slugsteps = $slugfield.val().split(/-/);

    $slugfield.val([$option.text()].concat(slugsteps.slice(1)).join("-"));
  });

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

      if ($dialog.is(':visible')) {
        $dialog.load($(this).closest('.row-fluid').find('a.controllist').data('href'));
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

  var $dialog = $('<div class="modal hide fade"></div>').appendTo('body');
  $dialog.draggable({ handle: '.modal-header' });
  $('#section_list').on('click', 'a.controllist', function() {
    // Save the current href for reloadability
    $dialog.data('href', $(this).data('href'));
    $dialog.load($(this).data('href'), function() {
      $dialog.modal_form({ backdrop: false }).modal_form('show');
    });
  });

  //$('body')
  //  .on('ajax:beforeSend', '[disabled="disabled"]', function(evt) {
  //    return false;
  //  });
  $('#rmap, #cmap')
    // Prevent disabled buttons from triggering AJAX requests
    .on('ajax:beforeSend', function(evt, xhr, request) {
      if ($(this).is('[disabled="disabled"]'))
        return false;
    })
    .on('ajax:success', function(evt, data, status, xhr) {
      if ($dialog.is(':visible'))
        $dialog.load($dialog.data('href'));
    });
}

jQuery(function($) {
  var $dialog = $('<div class="modal hide fade"></div>').appendTo('body');
  $dialog.draggable({ handle: '.modal-header' });
  $('#regulations, #controls').on('click', 'a.controllist', function(e) {
    e.preventDefault();
    $dialog.load($(this).attr('href'), function() {
      $dialog.modal_form({ backdrop: false }).modal_form('show');
    });
  });
});

function update_map_buttons_with_path(path) {
  var section_id = $("#selected_sections").attr('oid') || "";
  var rcontrol_id = $("#selected_rcontrol").attr('oid') || "";
  var ccontrol_id = $("#selected_ccontrol").attr('oid') || "";
  var qstr = '?' + $.param({section: section_id, rcontrol: rcontrol_id, ccontrol: ccontrol_id});

  var rmap = $('#rmap');
  var cmap = $('#cmap');

  rmap.attr('disabled', !(section_id && (rcontrol_id || ccontrol_id)));
  if (!(section_id && (rcontrol_id || ccontrol_id))) {
    rmap.children().eq(0).text('Map section to control');
  }
  cmap.attr('disabled', !(rcontrol_id && ccontrol_id));
  if (!(rcontrol_id && ccontrol_id)) {
    cmap.children().eq(0).text('Map control to control');
  }

  if ((section_id && (rcontrol_id || ccontrol_id)) || (rcontrol_id && ccontrol_id)) {
    $.getJSON(path + qstr,
      function(data){
        var rmap_text = $(rmap.children()[0]);
        var cmap_text = $(cmap.children()[0]);
        rmap_text.text(data[0] ? 'Unmap' : 'Map section to control')
        rmap.attr('href', rmap.attr('href').split('?')[0] + qstr + (data[0] ? '&u=1' : ""));
        cmap_text.text(data[1] ? 'Unmap' : 'Map control to control')
        cmap.attr('href', cmap.attr('href').split('?')[0] + qstr + (data[1] ? '&u=1' : ""));
      });
  }
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

  description_el = $(el).closest('.WidgetBox').parent().next().find('.WidgetBoxContent .description .content')
  $(description_el).replaceWith('Nothing selected.');
  $box.parent().next().find('.WidgetBoxContent .description').attr('oid', '');

  update_map_buttons();
}
