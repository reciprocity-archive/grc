//= require can.jquery-all

can.Control("CMS.Controllers.Related", {

  defaults : {
    template : "/assets/related.mustache"
  }
}, {
  // Finds all of the tabs within the container and sets them up.
  init : function() {
    $tabs = $(this.element).find('li')

    if ($tabs.length) {
      var $active_tab = $tabs.filter('.active')
      if (!$active_tab.length) {
        $active_tab = $tabs.first()
      }

      // Need to remove the active class because otherwise the
      // tab code thinks it's already loaded.
      $active_tab.removeClass('active')
      $active_tab.find('a').tab('show')
    }
  }

  , ".tab-pane redraw" : function(el, ev) {
    var id = el.attr('id')
      , $tab = $('#related a[href="#' + id + '"]');
    $tab.closest('ul').find('li').removeClass('active');
    $tab.tab('show');
    this.ajax_load_tab($tab);
  }

  , "li.tab-btn a show" : function(el, ev, href) {
    var $pane = $(el.attr('href'))
      // $dest defaults to the pane if we don't specify an explicit data destination
      , $dest = $(el.data('dest') || $pane)
      , source = el.data('source')
      , template = el.data('template')
      , last_loaded = el.data('last-loaded')
      , refresh_time = el.data('refresh-time')

    if (!source) {
      // Bail if we haven't specified any data to fetch
      return
    }

    if (!refresh_time && last_loaded) {
      // We don't have a refresh timeout
      return
    } else {
      if (last_loaded && (Date.now() - last_loaded) < refresh_time*1000) {
        return
      }
    }

    this.ajax_load_tab($(el), $dest, source);
  }

  , ajax_load_tab : function($tab) {
    var $pane = $($tab.attr('href'))
      // $dest defaults to the pane if we don't specify an explicit data destination
      , $dest = $($tab.data('dest') || $pane)
      , source = $tab.data('source')
      , template = $tab.data('template') || this.options.template
      ;
    // Show a spinner in our destination while we're loading
    var spinner = new Spinner({ }).spin();
    $dest.html(spinner.el);
    // Scroll up so spinner doesn't get pushed out of visibility
    $dest.scrollTop(0);
    $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px', zIndex : calculate_spinner_z_index });


    $.ajax({
      url: source,
      dataType: 'json',
      data: undefined,
    }).then(function(data) {
      // Empty and add data to the result node
      $dest.empty()
      $dest.append(can.view(template, data))
      $tab.data('last-loaded', Date.now())
    },
    function(xhr, status, error) {
      // Server error, display some debugging information.
      $dest.empty()
      $dest.append("Error: " + xhr.status + ":" + error)
      $tab.data('last-loaded', Date.now())
    });

  }


});
