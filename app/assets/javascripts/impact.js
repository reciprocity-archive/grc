$(document).ready(function() {
  function ajax_show_handler(e, href) {
    var $tab = $(e.target)
      , $pane = $($tab.attr('href'))
      // $dest defaults to the pane if we don't specify an explicit data destination
      , $dest = $($tab.data('dest') || $pane)
      , source = $tab.data('source')
      , template = $tab.data('template')
      , last_loaded = $tab.data('last-loaded')
      , refresh_time = $tab.data('refresh-time')

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

    // Show a spinner in our destination while we're loading
    var spinner = new Spinner({ }).spin();
    $dest.html(spinner.el);
    // Scroll up so spinner doesn't get pushed out of visibility
    $dest.scrollTop(0);
    $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px' });

    // FIXME: Handle data retrieval failure cleanly
    $.getJSON(source, function(data) {
      // Empty and add data to the result node
      $dest.empty()
      $dest.append(can.view(template, data))
      $tab.data('last-loaded', Date.now())
    })
  }

  // Finds all of the tabs within the container and sets them up.
  function setup_ajax_tab(container) {
    $tabs = $(container).find('li')

    if ($tabs.length) {
      $tabs.find('a').on('show', ajax_show_handler)
      var $active_tab = $tabs.filter('.active')
      if (!$active_tab.length) {
        $active_tab = $tabs.first()
      }

      console.log($active_tab)

      // Need to remove the active class because otherwise the
      // tab code thinks it's already loaded.
      $active_tab.removeClass('active')
      $active_tab.find('a').tab('show')
    }
  }

  // Set up tab handlers and load the default tab(programs)
  setup_ajax_tab('#impact')
})
