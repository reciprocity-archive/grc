$(document).ready(function() {
  function ajax_show_handler(e, href) {
    var $tab = $(e.target);
    ajax_show_helper($tab, href);
  }

  function ajax_redraw_handler(e) {
    var id = $(e.target).closest('.tab-pane').attr('id')
      , $tab = $('#related a[href="#' + id + '"]');
    $tab.closest('ul').find('li').removeClass('active');
    $tab.tab('show');
    ajax_load_tab($tab);
  }

  function ajax_show_helper($tab, href) {
    var $pane = $($tab.attr('href'))
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

    ajax_load_tab($tab, $dest, source);
  }

  function ajax_load_tab($tab) {
    var $pane = $($tab.attr('href'))
      // $dest defaults to the pane if we don't specify an explicit data destination
      , $dest = $($tab.data('dest') || $pane)
      , source = $tab.data('source')
      , template = $tab.data('template')
      ;
    // Show a spinner in our destination while we're loading
    var spinner = new Spinner({ }).spin();
    $dest.html(spinner.el);
    // Scroll up so spinner doesn't get pushed out of visibility
    $dest.scrollTop(0);
    $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px' });


    var successCallback = function(json) {
      // Empty and add data to the result node
      // Use D3 to render the graph
      console.log(json)
      $dest.empty()

      var width = 500,
          height = 500

      var color = d3.scale.category20()

      var force = d3.layout.force()
        .charge(-120)
        .linkDistance(50)
        .size([width, height])

      console.log(d3.select($dest[0]))
      var svg = d3.select($dest[0]).append("svg")

      console.log('svg', svg)

      svg.append('text').attr('id', 'graph-tooltip')

      force
        .nodes(json.nodes)
        .links(json.links)
        .start()

      var setupNodeTooltip = function(d, i) {
        var data = d.node[d.type]
        var dname = data.slug || data.name || data.email
        $(this).popover({
          'title' : dname,
          'trigger' : 'hover',
          'content' : d.type + '<br/>' + (data.description || '')
        })
      }

      var setupLinkTooltip = function(d, i) {
        $(this).popover({
          'title' : 'Link',
          'trigger' : 'hover',
          'content' : d.edge.type
        })
      }

      var mouseClick = function() {
        var $this = $(this)
        var node = json.nodes[$this.data('node')]
        window.location.href = node.link
      }


      svg.append("svg:defs").selectAll("marker")
          .data(["directional", "symmetrical"])
        .enter().append("svg:marker")
          .attr("id", String)
          .attr("viewBox", "0 -5 10 10")
          .attr("refX", 15)
          .attr("refY", 0)
          .attr("markerWidth", 4)
          .attr("markerHeight", 4)
          .attr("orient", "auto")
        .append("svg:path")
          .attr("d", "M0,-5L10,0L0,5");


      var link = svg.selectAll("line.link")
          .data(json.links)
        .enter().append("line")
          .attr("class", "link")
          .each(setupLinkTooltip)

      var node = svg.selectAll("g.node")
          .data(json.nodes)
        .enter().append("g")
          .attr("class", "node")
          .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
          .attr("data-node", function(d) { return d.index })
          //.on("mousemove", mouseOver)
          .on("click", mouseClick)
          .call(force.drag)

      node.append('circle')
          .attr("r", function(d) {
              if (d.index == 0) {
                return 10
              } else {
                return 5
              }
            })
          .attr("class", function(d) {
              if (d.index == 0) {
                return "root"
              } else {
                return ""
              }
            })
          .each(setupNodeTooltip)
      node.append('text')
          .text(function(d) {
            return d.node[d.type].slug
              || d.node[d.type].name
              || d.node[d.type].email
            })
            .attr('x', 7)
            .attr('y', 5)

      force.on("tick", function() {
        link.attr("x1", function(d) { return d.source.x; })
            .attr("y1", function(d) { return d.source.y; })
            .attr("x2", function(d) { return d.target.x; })
            .attr("y2", function(d) { return d.target.y; });

        node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
;
      })
    }

    var errorCallback = function(xhr, status, error) {
      // Server error, display some debugging information.
      $dest.empty()
      $dest.append("Error: " + xhr.status + ":" + error)
      $tab.data('last-loaded', Date.now())
    }

    $.ajax({
      url: source,
      dataType: 'json',
      data: undefined,
      success: successCallback,
      error: errorCallback
    })
  }

  // Finds all of the tabs within the container and sets them up.
  function setup_ajax_tab(container) {
    $tabs = $(container).find('li')

    console.log($tabs)

    if ($tabs.length) {
      console.log('Tabs!')
      $tabs.find('a').on('show', ajax_show_handler)
      $(container).find('.tab-pane').on('redraw', ajax_redraw_handler);
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
  
  // Set up tab handlers and load the default tab(programs)
  setup_ajax_tab('#related-graph')
})
