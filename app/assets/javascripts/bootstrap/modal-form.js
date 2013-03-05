!function($) {

  "use strict"; // jshint ;_;

  /* MODAL_FORM PUBLIC CLASS DEFINITION
   * =============================== */

  var ModalForm = function ( element, options, trigger ) {

    this.options = options;
    this.$element = $(element);
    this.$trigger = $(trigger);

    this.init();
  }

  /* NOTE: MODAL_FORM EXTENDS BOOTSTRAP-MODAL.js
   * ========================================== */

  ModalForm.prototype = new $.fn.modal.Constructor(); 

  $.extend(ModalForm.prototype, {

    init: function() {
      var that = this;
      var $form;
      this.$element
        .on('keypress', 'form', $.proxy(this.keypress_submit, this))
        .on('keyup', 'form', $.proxy(this.keyup_escape, this))
        .on('click.modal-form.close', '[data-dismiss="modal"]', $.proxy(this.hide, this))
        .on('click.modal-form.reset', 'input[type=reset], [data-dismiss="modal-reset"]', $.proxy(this.reset, this))
        .on('click.modal-form.submit', 'input[type=submit], [data-toggle="modal-submit"]', $.proxy(this.submit, this))
        .on('shown.modal-form', $.proxy(this.focus_first_input, this))
        .on('loaded.modal-form', $.proxy(this.focus_first_input, this))
        .on('loaded.modal-form', function(ev) { 
          $("a[data-wysihtml5-command], a[data-wysihtml5-action]", ev.target).attr('tabindex', "-1"); 
          $form = that.$form();
          $(this).trigger("shown"); //this will reposition the modal stack
        })
        .on('delete-object', $.proxy(this.delete_object, this))
        .draggable({ handle: '.modal-header' });
        ;


    }

  , doNothing: function(e) {
    e.stopImmediatePropagation();
    e.stopPropagation();
    e.preventDefault();
  }

  , delete_object: function(e, data, xhr) {
      // If this modal is contained within another modal, pass the event onward
      var $trigger_modal = this.$trigger.closest('.modal')
        , delete_target
        ;

      if ($trigger_modal.length > 0) {
        $trigger_modal.trigger('delete-object', [data, xhr]);
      } else {
        delete_target = this.$trigger.data('delete-target');
        if (delete_target == 'refresh') {
          // Refresh the page
          window.location.assign(window.location.href.replace(/#.*/, ''));
        } else if (xhr && xhr.getResponseHeader('location')) {
          // Otherwise redirect if possible
          window.location.assign(xhr.getResponseHeader('location'));
        } else {
          // Otherwise refresh the page
          window.location.assign(window.location.href.replace(/#.*/, ''));
        }
      }
    }

  , $form: function() {
      return this.$element.find('form').first();
    }

  , submit: function(e) {
      var $form = this.$form()
      , that = this;
      
      if(!$form.data("submitpending")) {
        $("[data-toggle=modal-submit]", $form)
          .each(function() { $(this).data("origText", $(this).text()); })
          .addClass("disabled pending-ajax")
          .attr("disabled", true);

        $form.data("submitpending", true)
        .one("ajax:beforeSend", function(ev, _xhr){
          that.xhr = _xhr;
        })
        .submit();
      }
      if (e.type == 'click')
        e.preventDefault();
    }

  , keypress_submit: function(e) {
      if (e.which == 13 && !$(e.target).is('textarea')) {
        if (!e.isDefaultPrevented()) {
          e.preventDefault();
          this.$form().submit();
        }
      }
    }

  , keyup_escape : function(e) {
     if($(document.activeElement).is("select, [data-toggle=datepicker]") && e.which === 27) {
        
        this.$element.attr("tabindex", -1).focus();
        e.stopPropagation();

      }
    }

  , reset: function(e) {
      var form = this.$form()[0];
      form && form.reset();
      this.hide(e);
    }

  , hide: function(e) {
      $.fn.modal.Constructor.prototype.hide.apply(this, [e]);
      this.$element.off('modal_form');
    }

  , focus_first_input: function(ev) {
      var $first_input = this.$element
        .find('input[type="text"], input[type="checkbox"], select, textarea')
        .not('[placeholder*=autofill], label:contains(autofill) + *, [disabled]')
        .first();
      if ($first_input.length > 0 && (!ev || this.$element.is(ev.target)))
        setTimeout(function() { $first_input.get(0).focus(); }, 100);
    }
  });

  $.fn.modal_form = function(option, trigger) {
    return this.each(function() {
      var $this = $(this)
        , data = $this.data('modal_form')
        , options = $.extend({}, $.fn.modal_form.defaults, $this.data(), typeof option == 'object' && option);
      if (!data) $this.data('modal_form', (data = new ModalForm(this, options, trigger)));
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
      var data = null, data_k;
      try {
        data = JSON.parse(xhr.responseText);
      } catch (exc) {
        //console.debug('exc', exc);
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
        else {
          var modal_form = $(".modal:visible:last").data("modal_form");
          if(modal_form && xhr === modal_form.xhr) {
            delete modal_form.xhr;
            $("[data-toggle=modal-submit]", modal_form.$element)
            .removeAttr("disabled")
            .removeClass("disabled pending-ajax")
            .each(function() {  
              $(this).text($(this).data("origText")); 
            });
            $("form", modal_form.$element).data("submitpending", false);
          }
        }
      }

      if (data) {
        // Parse and dispatch JSON object
        $(e.target).trigger('ajax:json', [data, xhr]);
      } else if(xhr.responseText) {
        // Dispatch as html, if there is html to dispatch.  (no result should not blank out forms)
        $(e.target).trigger('ajax:html', [xhr.responseText, xhr]);
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
      var sel = "script[type='text/javascript'], script[language='javascript'], script:not([type])";
      var $frag = $(html);
      $frag.filter(sel).add($frag.find(sel)).each(function() {
        $(this).remove();
        setTimeout($(this).html(), 10);
      }); 
      $(this).find('.modal-body').html($frag);
    });

    //$('body').on('ajax:json', function(e, data, xhr) {
    //});
  });
}(window.jQuery);
