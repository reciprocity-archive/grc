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
  //    .on('click.modal-form.submit', 'input[type=submit], [data-dismiss="modal-submit"]', $.proxy(this.submit, this));
      .on('ajax:success',  'form', $.proxy(this.on_success, this))
      .on('ajax:error',    'form', $.proxy(this.on_error, this))
      .on('flash:add',     $.proxy(this.on_flash, this))
      //.on('ajax:complete', 'form', $.proxy(this.on_complete, this))
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

  , submit: function(e) {
      var $form = $(e.target);
      console.debug($form);
      e && e.preventDefault();
    }

  , on_success: function(ev, data, status, xhr) {
      // Hide, then display flash messages globally
      this.hide();
      console.debug('flash: ', arguments);
      this.$element.trigger('flash', status);
    }

  , on_error: function(xhr, status, error) {
      // Display flash messages
      console.debug('err: ', arguments);
      this.$element.trigger('flash', error);
    }

  , on_flash: function(e, messages) {
      e.stopPropagation();
      console.debug('on_flash', arguments);
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
}(window.jQuery);
