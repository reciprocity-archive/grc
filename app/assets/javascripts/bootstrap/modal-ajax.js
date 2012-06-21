!function($) {

  "use strict"; // jshint ;_;

  function preload_content() {
    var template =
      [ '<div class="modal-header">'
      , '  <a class="close" href="#" data-dismiss="modal">x</a>'
      , '  Loading...'
      , '</div>'
      , '<div class="modal-body"></div>'
      , '<div class="modal-footer">'
      , '  <a class="close" href="#" data-dismiss="modal">Close</a>'
      , '</div>'
      ];
    return $(template.join('\n'))
      .filter('.modal-body')
        .html(
          $(new Spinner().spin().el)
            .css({
              width: '100px', height: '100px',
              left: '50px', top: '50px'
            })
        ).end();
  }

  $(function() {
    $('body').on('click.modal-ajax.data-api', '[data-toggle="modal-ajax"]', function(e) {
      var $this = $(this), modal_id, target, $target, option, href;

      href = $this.attr('data-href') || $this.attr('href');
      modal_id = 'ajax-modal-' + href.replace(/\//g, '-').replace(/^-/, '');
      target = $this.attr('data-target') || $('#' + modal_id);

      $target = $(target);

      if ($target.length == 0) {
        $target = $('<div id="' + modal_id + '" class="modal hide"></div>').append(preload_content());
        $this.attr('data-target', '#' + modal_id);
        $target.load(href);
      }

      option = $target.data('modal-help') ? 'toggle' : $.extend({}, $target.data(), $this.data());

      e.preventDefault();
      $target.modal(option);
    });
  });
}(window.jQuery);
