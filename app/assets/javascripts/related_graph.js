$(document).ready(function() {
  function setup_graph(pane) {
    $pane = $(pane)
    console.log('Setting up graph')
    source = $pane.data('source')
    // Show a spinner in our destination while we're loading
    var spinner = new Spinner({ }).spin();
    $pane.html(spinner.el);
    // Scroll up so spinner doesn't get pushed out of visibility
    $pane.scrollTop(0);
    $(spinner.el).css({ width: '100px', height: '100px', left: '50px', top: '50px' });

    var successCallback = function(json) {
      // Empty and add data to the result node
      // Use D3 to render the graph
      console.log(json)
      $pane.empty()

      var width = 500,
          height = 500

      var color = d3.scale.category20()

      var force = d3.layout.force()
        .charge(-120)
        .linkDistance(50)
        .size([width, height])

      var svg = d3.select(pane).append("svg")

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
      console.log('Got error')
      // Server error, display some debugging information.
      $pane.empty()
      $pane.append("Error: " + xhr.status + ":" + error)
    }

    $.ajax({
      url: source,
      dataType: 'json',
      data: undefined,
      success: successCallback,
      error: errorCallback
    })
  }

  // Set up tab handlers and load the default tab(programs)
  setup_graph('#related_graph')
})
