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

  function emit_loaded() {
    $(this).trigger('loaded');
  }

  function setup_event_relay($source, $target, events, options) {
    var events = events;
    if (options.namespace) {
      events = events.split(' ').join('.' + options.namespace + ' ')
             + '.' + options.namespace;
      $source.off(events);
    }
    $source.on(events, function(e) {
      var relay_type  = options.prefix ? options.prefix + e.type : e.type
        , relay_opts  = $.extend({}, e, { type: relay_type, relayTarget: $target[0] })
        , relay_event =  $.Event(relay_type, relay_opts);
      $target.trigger(relay_event);
    });
  }

  $(function() {
    $('body').on('click.modal-ajax.data-api', '[data-toggle="modal-ajax"], [data-toggle="modal-ajax-form"], [data-toggle="modal-ajax-list"], [data-toggle="modal-ajax-listform"]', function(e) {
      var $this = $(this), modal_id, target, $target, option, href, new_target;

      href = $this.attr('data-href') || $this.attr('href');
      modal_id = 'ajax-modal-' + href.replace(/\//g, '-').replace(/^-/, '');
      target = $this.data('modal-reset') != "reset" && ($this.attr('data-target') || $('#' + modal_id));

      $target = $(target);
      new_target = $target.length == 0

      if (new_target) {
        $target = $('<div id="' + modal_id + '" class="modal hide"></div>');
        $this.attr('data-target', '#' + modal_id);
      }

      /*setup_event_relay($target, $this, 'show shown hide hidden loaded',
        { namespace: 'modal-trigger-relay'
        , prefix: 'target-'
        });*/

      if (new_target || $this.data('modal-reset') == 'reset') {
        $target.html(preload_content());
        $target.load(href, emit_loaded);
      }

      option = $target.data('modal-help') ? 'toggle' : $.extend({}, $target.data(), $this.data());

      e.preventDefault();

      if ($this.data('toggle') == 'modal-ajax-form') {
        /*setup_event_relay(
          $target, $this,
          'ajax:beforeSend ajax:success ajax:error ajax:complete ajax:flash',
          { namespace: 'modal-form-trigger-relay'
          , prefix: 'target-'
          });*/
        $target.modal_form(option);
      } else if ($this.data('toggle') == 'modal-ajax-list') {
        $target.modal(option);
        $target.on('loaded', function(e) {
          $(this).on('click', 'ul.itemlist > li > a', function(e) {
            var target = $this.data('list-target');
            if (target) {
              $(target).tmpl_additem($(this).data());
            }
          });
        });
      } else if ($this.data('toggle') == 'modal-ajax-listform') {
        $target.modal_form(option);
        $target.on('ajax:json', function(e, data, xhr) {
          if ($this.data('list-target')) {
            $($this.data('list-target')).tmpl_additem(data);
            $target.modal_form('hide');
          }
        });
      } else
        $target.modal(option);
    });
  });
}(window.jQuery);
