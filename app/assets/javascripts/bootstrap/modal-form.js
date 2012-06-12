!function($) {
  
  "use strict"; // jshint ;_;

  /* MODAL_FORM PUBLIC CLASS DEFINITION
   * =============================== */

  var ModalForm = function ( element, options ) {
    
    this.options = options;
    this.$element = $(element);

    this.$element
      .on('click.modal-form.close', '[data-dismiss="modal"]', $.proxy(this.hide, this))
      .on('click.modal-form.reset', 'input[type=reset], [data-dismiss="modal-reset"]', $.proxy(this.reset, this))
      .on('ajax:complete', 'form', $.proxy(this.on_complete, this))
      .on('ajax:flash',    'form', $.proxy(this.on_flash, this))
  }

  /* NOTE: MODAL_FORM EXTENDS BOOTSTRAP-MODAL.js
   * ========================================== */

  ModalForm.prototype = $.extend({}, $.fn.modal.Constructor.prototype, {

    constructor: ModalForm

  , reset: function(e) {
      $(e.target).closest('form')[0].reset();
      this.hide(e);
    }

  , hide: function(e) {
      $.fn.modal.Constructor.prototype.hide.apply(this, [e]);
      this.$element.off('modal_form');
    }

  , on_complete: function(ev, xhr, status) {
      // Replace form body
      this.$element.find('.modal-body').html(xhr.responseText);

      // Maybe handle AJAX/JSON redirect or refresh
      if (xhr.status == 278) {
        // Handle 278 redirect (AJAX redirect)
        window.location.assign(xhr.getResponseHeader('location'));
      } else if (xhr.status == 279) {
        window.location.assign(window.location.href);
      }

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

      if (flash)
        this.$element.find('form').trigger('ajax:flash', flash);
    }

  , on_flash: function(e, flash) {
      // Find or create the flash-message holder
      var $flash_holder = this.$element.find('.flash')
        , type, ucase_type
        , messages, message, message_i;

      if ($flash_holder.length == 0) {
        $flash_holder = $('<ul class="flash"></ul>');
        this.$element.find('.modal-body').prepend($flash_holder);
      } else {
        $flash_holder.empty();
      }

      for (type in flash) {
        if (flash[type]) {
          if (typeof(flash[type]) == "string")
            flash[type] = [flash[type]];

          for (message_i in flash[type]) {
            $flash_holder.append('<li class="' + type + '">' + flash[type][message_i] + '</li>');
          }
        }
      }
      e.stopPropagation();
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
}(window.jQuery);
