//= require bootstrap-modal

!function($) {

  "use strict"; // jshint ;_;

  function preload_content() {
    var template =
      [ '<div class="modal-header">'
      , '  <nav>'
      , '    <a class="widgetbtn" href="#" data-dismiss="modal">'
      , '      <i class="grcicon-x-grey"></i>'
      , '    </a>'
      , '  </nav>'
      , '  <h1>Loading...</h1>'
      , '</div>'
      , '<div class="modal-body"></div>'
      , '<div class="modal-footer">'
      , '  <div class="row-fluid">'
      , '    <nav class="fltlft txtlft span3">'
      , '      <a class="btn btn-large btn-info" data-dismiss="modal">Cancel</a>'
      , '    </nav>'
      , '    <div class="span6"></div>'
      , '    <nav class="fltrt txtrt span3">'
      , '      <a class="btn btn-large btn-warning" data-dismiss="modal">Close</a>'
      , '    </nav>'
      , '  </div>'
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

  function emit_loaded(responseText, textStatus, xhr) {
    if (xhr.status == 403) {
      // For now, only inject the response HTML in the case
      // of an authorization error
      $(this).html(responseText)
    }
    $(this).trigger('loaded');
  }

  function refresh_page() {
    window.location.assign(window.location.href.replace(/#.*/, ''));
  }

  var handlers = {
    'modal': function($target, $trigger, option) {
      $target.modal(option);
    },

    'listselect': function($target, $trigger, option) {
      var list_target = $trigger.data('list-target');
      $target.modal_single_selector(option, $trigger);

      // Close the modal and rewrite the target list
      $target.on('modal:select', function(e, data) {
        $target.modal_single_selector('hide');
        $trigger.trigger('modal:select', data);
      });
    },

    'relationshipsform': function($target, $trigger, option) {
      var list_target = $trigger.data('list-target');
      $target.modal_relationship_selector(option, $trigger);

      // Close the modal and rewrite the target list
      $target.on('ajax:json', function(e, data, xhr) {
        if (data.errors) {
        } else if (list_target == 'refresh') {
          refresh_page();

        } else if (list_target) {
          $(list_target).tmpl_setitems(data);
          $target.modal_relationship_selector('hide');
        }

      });
    },

    'listform': function($target, $trigger, option) {
      var list_target = $trigger.data('list-target');
      $target.modal_relationship_selector(option, $trigger);

      // Close the modal and rewrite the target list
      $target.on('ajax:json', function(e, data, xhr) {
        if (data.errors) {
        } else if (list_target == 'refresh') {
          refresh_page();
        } else if (list_target) {
          $(list_target).tmpl_setitems(data);
          $target.modal_relationship_selector('hide');
        }
      });
    },

    'listnewform': function($target, $trigger, option) {
      $target.modal_form(option, $trigger);
      var list_target = $trigger.data('list-target')
        , selector_target = $trigger.data('selector-target')
        ;

      // Close the modal and append to the target list
      $target.on('ajax:json', function(e, data, xhr) {
        if (data.errors) {
        } else {
          if (list_target) {
            $(list_target).tmpl_additem(data)
          }
          if (selector_target) {
            $(selector_target).trigger('list-add-item', data);
          }
          //$(tablist_target).trigger('list-add-item', data);
          $target.modal_form('hide');
        }
      });
    },

    'listeditform': function($target, $trigger, option) {
      $target.modal_form(option, $trigger);
      var list_target = $trigger.data('list-target')
        , selector_target = $trigger.data('selector-target')
        ;

      // Close the modal and append to the target list
      $target.on('ajax:json', function(e, data, xhr) {
        if (data.errors) {
        } else {
          if (list_target) {
            $(list_target).tmpl_mergeitems([data]);
          }
          if (selector_target) {
            $(selector_target).trigger('list-update-item', data);
          }
          $target.modal_form('hide');
        }
      });
    },

    'deleteform': function($target, $trigger, option) {
      var $proxy_target = $trigger.closest('.modal');
      $target.modal_form(option, $trigger);

      $target.on('ajax:json', function(e, data, xhr) {
        if (data.errors) {
        } else {
          $target.modal_form('hide');
          if ($proxy_target.length > 0) {
            $proxy_target.trigger('delete-object', [data, xhr]);
            $proxy_target.modal_form('hide');
          } else {
            window.location.assign(xhr.getResponseHeader('location'));
          }
        }
      });
    },

    'form': function($target, $trigger, option) {
      var form_target = $trigger.data('form-target');
      $target.modal_form(option, $trigger);

      $target.on('ajax:json', function(e, data, xhr) {
        if (data.errors) {
        } else if (form_target == 'refresh') {
          refresh_page();
        } else if (form_target == 'redirect') {
          window.location.assign(xhr.getResponseHeader('location'));
        } else {
          $target.modal_form('hide');
          $trigger.trigger('modal:success', data);
        }
      });
    }
  };


  var arrangeBackgroundModals = function(modals, referenceModal) {
    modals = $(modals).not(referenceModal);
    if(modals.length < 1) return;

    var _top = parseInt($(referenceModal)[0].offsetTop);
    modals.css({
        "height" : function() {
          return parseInt($(this).find(".modal-header").height()) + 4;
        }
      , "overflow" : "hidden"
      , "top" : function(i) {
        return _top - (modals.length - i) * (parseInt($(this).find(".modal-header").height()) + 4);
      }
      , "margin-top" : 0
    });

  }

  var arrangeTopModal = function(modals, modal) {
    modal.css("top", (50 + (modals.length - 1) * 5) + "%");    
  }

  var _modal_show = $.fn.modal.Constructor.prototype.show;
  $.fn.modal.Constructor.prototype.show = function() {

    _modal_show.apply(this, arguments);

    $(".modal-backdrop").css("z-index", function(i) {
      return 1040 + i * 20;
    });
    
    var modals = $(".modal:visible");
    modals.css("z-index", function(i) {return 1050 + i * 20;});

    arrangeTopModal(modals, this.$element);
    arrangeBackgroundModals(modals, this.$element);
  };

  var _modal_hide = $.fn.modal.Constructor.prototype.hide;
  $.fn.modal.Constructor.prototype.hide = function() {
    _modal_hide.apply(this, arguments);
    var modals = $(".modal:visible");
    var lastModal = modals.last();
    lastModal.css({"height" : "", "overflow" : "", top : "", "margin-top" : ""});
    arrangeTopModal(modals, lastModal);
    arrangeBackgroundModals(modals, lastModal);
  };

  $(function() {
    $('body').on('click.modal-ajax.data-api', '[data-toggle="modal-ajax"], [data-toggle="modal-ajax-form"], [data-toggle="modal-ajax-listform"], [data-toggle="modal-ajax-listnewform"], [data-toggle="modal-ajax-relationship-selector"], [data-toggle="modal-ajax-single-selector"], [data-toggle="modal-ajax-listeditform"], [data-toggle="modal-ajax-deleteform"]', function(e) {

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
        $target.addClass($this.attr('data-modal-class'));
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
      e.stopPropagation();

      modal_type = $this.data('modal-type');
      if (!modal_type) {
        if (toggle_type == 'modal-ajax-form') modal_type = 'form';
        if (toggle_type == 'modal-ajax-listform') modal_type = 'listform';
        if (toggle_type == 'modal-ajax-listnewform') modal_type = 'listnewform';
        if (toggle_type == 'modal-ajax-listeditform') modal_type = 'listeditform';
        if (toggle_type == 'modal-ajax') modal_type = 'modal';
        if (toggle_type == 'modal-ajax-relationship-selector') modal_type = 'relationshipsform';
        if (toggle_type == 'modal-ajax-single-selector') modal_type = 'listselect';
        if (toggle_type == 'modal-ajax-deleteform') modal_type = 'deleteform';
        if (!modal_type) modal_type = 'modal';
      }

      handlers[modal_type].apply($target, [$target, $this, option]);
    });
  });
}(window.jQuery);
