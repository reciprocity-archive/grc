$(document).ready(function() {
  // Load impact results.
  $('#impactScopeInfo').each(function(index, pane) {
    // FIXME: Need to do error handling.
    $.getJSON('/programs?relevant_to=' + window.location.pathname.split('/').pop(), function(data) {
      $(pane).append(can.view('/assets/programs.ejs', data))
    })
  })
})
