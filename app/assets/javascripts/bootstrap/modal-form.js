!function($) {

  "use strict"; // jshint ;_;

  /* MODAL_FORM PUBLIC CLASS DEFINITION
   * =============================== */

  var ModalForm = function ( element, options ) {

    this.options = options;
    this.$element = $(element);

    this.$element
      .on('keypress', 'form', $.proxy(this.keypress_submit, this))
      .on('click.modal-form.close', '[data-dismiss="modal"]', $.proxy(this.hide, this))
      .on('click.modal-form.reset', 'input[type=reset], [data-dismiss="modal-reset"]', $.proxy(this.reset, this))
      .on('click.modal-form.submit', 'input[type=submit], [data-toggle="modal-submit"]', $.proxy(this.submit, this))
      .on('click.modal-form.destroy', '[data-toggle="form-destroy"]', $.proxy(this.destroy, this))
      .on('shown.modal-form', $.proxy(this.focus_first_input, this))
      .on('loaded.modal-form', $.proxy(this.focus_first_input, this))
  }

  /* NOTE: MODAL_FORM EXTENDS BOOTSTRAP-MODAL.js
   * ========================================== */

  ModalForm.prototype = $.extend({}, $.fn.modal.Constructor.prototype, {

    constructor: ModalForm

  , $form: function() {
      return this.$element.find('form').first();
    }

  , submit: function(e) {
      this.$form().submit();
    }

  , keypress_submit: function(e) {
      if (e.which == 13 && !$(e.target).is('textarea')) {
        if (!e.isDefaultPrevented()) {
          e.preventDefault();
          this.$form().submit();
        }
      }
    }

  , reset: function(e) {
      this.$form()[0].reset();
      //$(e.target).closest('form')[0].reset();
      this.hide(e);
    }

  , hide: function(e) {
      $.fn.modal.Constructor.prototype.hide.apply(this, [e]);
      this.$element.off('modal_form');
    }

  , focus_first_input: function() {
      var $first_input = this.$element
        .find('input[type="text"], input[type="checkbox"], select, textarea')
        .first();
      if ($first_input.length > 0)
        setTimeout(function() { $first_input.get(0).focus(); }, 100);
    }

  , destroy: function(e) {
    }
  });

  $.fn.modal_form = function(option) {
    return this.each(function() {
      var $this = $(this)
        , data = $this.data('modal_form')
        , options = $.extend({}, $.fn.modal_form.defaults, $this.data(), typeof option == 'object' && option);
      if (!data) $this.data('modal_form', (data = new ModalForm(this, options)));
      if (typeof option == 'string') data[option]();
      else if (options.show) data.show();
    });
  }

  $.fn.modal_form.Constructor = ModalForm;

  $.fn.modal_form.defaults = $.extend({}, $.fn.modal.defaults, {

  });

  /* MODAL-FORM DATA-API
   * =================== */

  $(function () {
    $('body').on('click.modal-form.data-api', '[data-toggle="modal-form"]', function ( e ) {
      var $this = $(this), href
        , $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
        , option = $target.data('modal-form') ? 'toggle' : $.extend({}, $target.data(), $this.data());

      e.preventDefault();
      $target.modal_form(option);
    });
  });

  // Default flash handler
  $(function() {
    // Default form complete handler
    $('body').on('ajax:complete', function(e, xhr, status) {
      var data, data_k;
      try {
        // Parse and dispatch JSON object
        data = JSON.parse(xhr.responseText);
        $(e.target).trigger('ajax:json', [data, xhr]);
      } catch (exc) {
        // Dispatch as html
        $(e.target).trigger('ajax:html', [xhr.responseText, xhr]);
      }

      if (!e.stopRedirect) {
        // Maybe handle AJAX/JSON redirect or refresh
        if (xhr.status == 278) {
          // Handle 278 redirect (AJAX redirect)
          window.location.assign(xhr.getResponseHeader('location'));
        } else if (xhr.status == 279) {
          // Handle 279 page refresh
          window.location.assign(window.location.href.replace(/#.*/, ''));
        }
      }

      if (!e.stopFlash) {
        // Maybe handle AJAX flash messages
        var flash_types = ["error", "alert", "notice", "warning"]
          , type_i, message
          , flash;

        for (type_i in flash_types) {
          message = xhr.getResponseHeader('x-flash-' + flash_types[type_i]);
          message = JSON.parse(message);
          if (message) {
            if (!flash)
              flash = {};
            flash[flash_types[type_i]] = message;
          }
        }

        if (flash) {
          $(e.target).trigger('ajax:flash', flash);
        }
      }
    });

    $('body').on('ajax:flash', function(e, flash) {
      var $target, $flash_holder// = this.$element.find('.flash')
        , type, ucase_type
        , messages, message, message_i
        , flash_class
        , flash_class_mappings = { notice: "success" }
        , html;

      // Find or create the flash-message holder
      $target = e.target ? $(e.target) : $('body');
      $flash_holder = $target.find('.flash');

      if ($flash_holder.length == 0) {
        $flash_holder = $('<div class="flash"></div>');
        $target.find('.modal-body').prepend($flash_holder);
      } else {
        $flash_holder.empty();
      }

      for (type in flash) {
        if (flash[type]) {
          if (typeof(flash[type]) == "string")
            flash[type] = [flash[type]];

          flash_class = flash_class_mappings[type] || type

          html =
            [ '<div class="alert alert-' + flash_class + '">'
            ,   '<a href="#" class="close" data-dismiss="alert">x</a>'
            ]
          for (message_i in flash[type]) {
            html.push('<span>' + flash[type][message_i] + '</span>');
          }
          html.push('</div>');
          $flash_holder.append(html.join(''));
        }
      }
      //e.stopPropagation();
    });

    $('body').on('ajax:html', '.modal > form', function(e, html, xhr) {
      $(this).find('.modal-body').html(html);
    });

    $('body').on('ajax:json', function(e, data, xhr) {
    });
  });
}(window.jQuery);
