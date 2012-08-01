!function($) {

  "use strict"; // jshint ;_;

  function preload_content() {
    var template =
      [ '<div class="modal-header">'
      , '  <nav>'
      , '    <a class="widgetbtn" href="#" data-dismiss="modal">'
      , '      <i class="gcmsicon-x-grey"></i>'
      , '    </a>'
      , '  </nav>'
      , '  <h1>Loading...</h1>'
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

  function refresh_page() {
    window.location.assign(window.location.href.replace(/#.*/, ''));
  }

  var handlers = {
    'modal': function($target, $trigger, option) {
      $target.modal(option);
    },

    'listform': function($target, $trigger, option) {
      var list_target = $trigger.data('list-target');
      $target.modal_form(option);

      // Close the modal and rewrite the target list
      $target.on('ajax:json', function(e, data, xhr) {
        if (list_target == 'refresh') {
          refresh_page();
        } else if (list_target) {
          $(list_target).tmpl_setitems(data);
          $target.modal_form('hide');
        }
      });
    },

    'listnewform': function($target, $trigger, option) {
      $target.modal_form(option);
      var list_target = $trigger.data('list-target');

      // Close the modal and append to the target list
      $target.on('ajax:json', function(e, data, xhr) {
        if (list_target) {
          $(list_target).tmpl_additem(data);
          $target.modal_form('hide');
        }
      });
    },

    'form': function($target, $trigger, option) {
      var form_target = $trigger.data('form-target');
      $target.modal_form(option);

      $target.on('ajax:json', function(e, data, xhr) {
        if (form_target == 'refresh') {
          refresh_page();
        }
      });
    }
  };

  $(function() {
    $('body').on('click.modal-ajax.data-api', '[data-toggle="modal-ajax"], [data-toggle="modal-ajax-form"], [data-toggle="modal-ajax-listform"], [data-toggle="modal-ajax-listnewform"]', function(e) {
      var $this = $(this)
        , toggle_type = $(this).data('toggle')
        , modal_id, target, $target, option, href, new_target, modal_type;

      href = $this.attr('data-href') || $this.attr('href');
      modal_id = 'ajax-modal-' + href.replace(/\//g, '-').replace(/^-/, '');
      target = $this.attr('data-target') || $('#' + modal_id);

      //if ($this.data('modal-reset') == 'reset')
      //  $(target).remove();

      $target = $(target);
      new_target = $target.length == 0

      if (new_target) {
        $target = $('<div id="' + modal_id + '" class="modal hide"></div>');
        $this.attr('data-target', '#' + modal_id);
      }

      $target.on('hidden', function() {
        $target.remove();
      });

      if (new_target || $this.data('modal-reset') == 'reset') {
        $target.html(preload_content());
        $target.load(href, emit_loaded);
      }

      option = $target.data('modal-help') ? 'toggle' : $.extend({}, $target.data(), $this.data());

      e.preventDefault();

      modal_type = $this.data('modal-type');
      if (!modal_type) {
        if (toggle_type == 'modal-ajax-form') modal_type = 'form';
        if (toggle_type == 'modal-ajax-listform') modal_type = 'listform';
        if (toggle_type == 'modal-ajax-listnewform') modal_type = 'listnewform';
        if (toggle_type == 'modal-ajax') modal_type = 'modal';
        if (!modal_type) modal_type = 'modal';
      }

      handlers[modal_type].apply($target, [$target, $this, option]);
    });
  });
}(window.jQuery);
