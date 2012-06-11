/*
 *= require application
 *= require jquery
 *= require jquery-ui
 *= require bootstrap
 *= require spin.min
 *= require_self
 */

// Expand node content when '+' clicked in tree
jQuery(function($) {
  $('ul.slugtree .expander').bind('click', function(e) {
    $(this).closest('li').find('> .content').toggle();
  });
});

// Tabs via AJAX on 'Quick Find'
jQuery(function($) {
  $('.tabbable').on('show', 'ul.nav-tabs > li > a', function(e, href) {
    var $tab = $(e.target)
      , loaded = $tab.data('tab-loaded')
      , pane = ($tab.data('tab-target') || $tab.attr('href'))
      , template = "<div></div>";

    if (href)
      loaded = false;
    else
      href = $tab.data('tab-href');

    if (!href) return;

    if (!loaded) {
      if (template) {
        var spinner = new Spinner({ }).spin();
        $(pane).append(spinner.el);
        $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px' });
      }

      $(pane).load(href, function(data, status, xhr) {
        $tab.data('tab-loaded', true);
        $tab.tab('show');
        $(this).html(data);
      });
    }
  });

  // Trigger first tab immediately
  $('.tabbable > ul > li:first-child > a').tab('show');
});

// Quick Search
jQuery(function($) {
  $('nav > .widgetsearch').keypress(function (e) {
    var $tab = $(this).closest('.WidgetBox').find('ul.nav-tabs > li.active > a')
      , href = $tab.data('tab-href') + '?' + $.param({ s: $(this).val() });
    if (e.which == 13)
      $tab.trigger('show', href);
  });
  $('.nav-box > .widgetsearch').keypress(function (e) {
    if (e.which == 13) {
      var $this = $(this);
      var $box = $($this.closest('.WidgetBox').find('.WidgetBoxContent').children()[0])
        , href = $box.data('href') + '?' + $.param({ s: $(this).val() });
      $box.load(href);
    }
  });
});

// Regulation mapping
function init_mapping() {
  $('#section_list')
    .on("ajax:success", '.selector', function(evt, data, status, xhr){
      $('#selected_sections').replaceWith(xhr.responseText);
      $('#section_list .selector').closest('.item').removeClass('selected');
      $(this).closest('.item').addClass('selected');
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

  $('#controls-dialog').dialog({autoOpen : false, width: 400, height:300});
  $('#section_list').on('click', 'a.controls', function() {
    $('#controls-dialog > :first-child').load($(this).data('href'), function() {
      $('#controls-dialog').dialog('open');
    });
  });
  $('#cmap, #rmap').on('click', function() {
    $('#controls-dialog').dialog('close');
  });
}

function update_map_buttons_with_path(path) {
  var section_id = $("#selected_sections").attr('oid') || "";
  var rcontrol_id = $("#selected_rcontrol").attr('oid') || "";
  var ccontrol_id = $("#selected_ccontrol").attr('oid') || "";
  var qstr = '?' + $.param({section: section_id, rcontrol: rcontrol_id, ccontrol: ccontrol_id});
  $.getJSON(path + qstr,
    function(data){
      var rmap = $('#rmap');
      var rmap_text = $(rmap.children()[0]);
      var cmap = $('#cmap');
      var cmap_text = $(cmap.children()[0]);
      rmap_text.text(data[0] ? 'Unmap section from control' : 'Map section to control')
      rmap.attr('disabled', !(section_id && (rcontrol_id || ccontrol_id)));
      rmap.attr('href', rmap.attr('href').split('?')[0] + qstr + (data[0] ? '&u=1' : ""));
      cmap_text.text(data[1] ? 'Unmap control from control' : 'Map control to control')
      cmap.attr('disabled', !(rcontrol_id && ccontrol_id));
      cmap.attr('href', cmap.attr('href').split('?')[0] + qstr + (data[1] ? '&u=1' : ""));
    });
}

function clear_selection(el) {
  $(el).closest('.WidgetBox').prev().find('.selected').removeClass('selected');
  description_el = $(el).closest('.WidgetBox').find('.WidgetBoxContent .description .content')
  $(description_el).replaceWith('Nothing selected.');
  $(el).closest('.WidgetBox').find('.WidgetBoxContent .description').attr('oid', '');
  update_map_buttons();
}
