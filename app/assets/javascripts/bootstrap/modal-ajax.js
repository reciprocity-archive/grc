//= require bootstrap-modal
//= require can.jquery-all
//= require jquery-migrate
//= require jquery-ui

!function($) {

  "use strict"; // jshint ;_;

  function preload_content() {
    var template =
      [ '<div class="modal-header">'
      , '  <a class="btn btn-mini pull-right" href="#" data-dismiss="modal">'
      , '    <i class="grcicon-x-grey"></i>'
      , '  </a>'
      , '  <h2>Loading...</h2>'
      , '</div>'
      , '<div class="modal-body" style="padding-top:150px;"></div>'
      , '<div class="modal-footer">'
      , '</div>'
      ];
    return $(template.join('\n'))
      .filter('.modal-body')
        .html(
          $(new Spinner().spin().el)
            .css({
              width: '100px', height: '100px',
              left: '50%', top: '50%',
              zIndex : calculate_spinner_z_index
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
    setTimeout(can.proxy(window.location.reload, window.location), 10);
  }

  var handlers = {
    'modal': function($target, $trigger, option) {
      $target.modal(option).draggable({ handle: '.modal-header' });
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
        } else {
          $trigger.trigger('modal:success', [data]);
          if (list_target == 'refresh') {
            refresh_page();
          } else if (list_target) {
            $(list_target).tmpl_setitems(data);
            $target.modal_relationship_selector('hide');
          }
          $trigger.data("route") && $trigger.trigger("routeparam", "tab." + $trigger.closest(".widget").attr("id") + "=" + $trigger.data("route"));
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
          $trigger.trigger('modal:success', data);
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
          var dirty;
          $target.modal_form('hide');
          if($trigger.data("dirty")) {
            var dirty = $($trigger.data("dirty").split(",")).map(function(i, val) {
              return '[href="' + val.trim() + '"]';
            }).get().join(",");
            $(dirty).data('tab-loaded', false);
          }
          if(dirty) {
            var $active = $(dirty).filter(".active [href]");
            $active.closest(".active").removeClass("active");
            $active.click();
          }
          $trigger.data("route") && $trigger.trigger("routeparam", "tab." + $trigger.closest(".widget").attr("id") + "=" + $trigger.data("route"));
          $trigger.trigger('modal:success', data);
        }
      });
    }
  };


  var arrangeBackgroundModals = function(modals, referenceModal) {
    modals = $(modals).not(referenceModal);
    if(modals.length < 1) return;

    var $header = referenceModal.find(".modal-header");
    var header_height = $header.height() + parseInt($header.css("padding-top")) + parseInt($header.css("padding-bottom"));
    var _top = parseInt($(referenceModal).offset().top);

    modals.css({
        "overflow" : "hidden"
      , "height" : function() {
          return header_height;
        }
      , "top" : function(i) {
        return _top - (modals.length - i) * (header_height);
      }
      , "margin-top" : 0
      , 'position' : "absolute"
    })
    modals.off("scroll.modalajax");
    modals.on("scroll.modalajax", function() { 
        $(this).scrollTop(0); //fix for Chrome rendering bug when resizing block elements containing CSS sprites.
    });
  }

  var arrangeTopModal = function(modals, modal) {
    if(!modal || !modal.length)
      return;

    var $header = modal.find(".modal-header:first");
    var header_height = $header.height() + parseInt($header.css("padding-top")) + parseInt($header.css("padding-bottom"));

    var offsetParent = modal.offsetParent();
    var _scrollY = 0;
    var _top = 0;    
    var _left = modal.position().left;
    if(!offsetParent.length || offsetParent.is("html, body")) {
      offsetParent = $(window);
      _scrollY = window.scrollY;
      _top = _scrollY 
        + (offsetParent.height() 
          - modal.height()) / 2 
        + header_height / 2

        window.scrollY + ($(window).height() - modal.height()) / 2 + (modals.length - 1) * parseInt(modal.find(".modal-header").height()) 
    } else {
      _top = offsetParent.closest(".modal").offset().top - offsetParent.offset().top + header_height;
      _left = offsetParent.closest(".modal").offset().left + offsetParent.closest(".modal").width() / 2 - offsetParent.offset().left;
    }
    modal
    .css("top", _top + "px")
    .css({"position" : "absolute", "margin-top" : 0, "left" : _left});
  }

  var _modal_show = $.fn.modal.Constructor.prototype.show;
  $.fn.modal.Constructor.prototype.show = function() {
    var that = this;
    var $el = this.$element;
    var shownevents, keyevents;
    if(!(shownevents = $el.data("events").shown)
        || $(shownevents).filter(function() { 
            return $.inArray("arrange", this.namespace.split(".")) > -1; 
        }).length < 1) {
          $el.on("shown.arrange", function(ev) {
            if(ev.target === ev.currentTarget)
                reconfigureModals.call(that);
          });
    }

    if($el.is("body > * *")) {
      this.$cloneEl = $("<div>").appendTo($el.parent());
      can.each($el[0].attributes, function(attr) {
        that.$cloneEl.attr(attr.name, attr.value);
      });
      $el.find("*").uniqueId();
      this.$cloneEl.html($el.html());
      $el.detach().appendTo(document.body);
      this.$cloneEl.removeAttr("id").find("*").attr("data-original-id", function() {
        return this.id;
      }).removeAttr("id");

      $el.on(["click", "mouseup", "keypress", "keydown", "keyup", "show", "shown", "hide", "hidden"].join(".clone ") + ".clone", function(e) {
        that.$cloneEl 
        ? that.$cloneEl.find("[data-original-id=" + e.target.id + "]").trigger(new $.Event(e))
        : $el.off(".clone");
      }); 
    }


    // prevent form submissions when descendant elements are also modals.
    if(!(keyevents = $el.data("events").keypress)
        || $(keyevents).filter(function() { 
            return $.inArray("preventdoublesubmit", this.namespace.split(".")) > -1; 
          }).length < 1) {    
      $el.on('keypress.preventdoublesubmit', function(ev) {
        if(ev.which === 13) {
          ev.preventDefault();
          if(ev.originalEvent) {
            ev.originalEvent.preventDefault();
          }
          return false;
        }
      });
    }
    if(!(keyevents = $el.data("events").keyup)
        || $(keyevents).filter(function() { 
            return $.inArray("preventdoubleescape", this.namespace.split(".")) > -1; 
          }).length < 1) {  
      $el.on('keyup.preventdoubleescape', function(ev) {
       if(ev.which === 27 && $(ev.target).closest(".modal").length) {
          $(ev.target).closest(".modal").attr("tabindex", -1).focus();
          ev.stopPropagation();
          ev.originalEvent && ev.originalEvent.stopPropagation();
          that.hide();
        }
      });
      $el.attr("tabindex") || $el.attr("tabindex", -1);
      setTimeout(function() { $el.focus(); }, 1);
    }

    _modal_show.apply(this, arguments);
    //reconfigureModals.call(this);   //handled by modal shown event firing.
  };

  var reconfigureModals = function() {

    var modal_backdrops = $(".modal-backdrop").css("z-index", function(i) {
      return 1040 + i * 20;
    });

    var modals = $(".modal:visible");
    modals.each(function(i) {
        var parent = this.parentNode;
        if(parent !== document.body)
        { 
            modal_backdrops
            .eq(i)
            .detach()
            .appendTo(parent);
        }
    });
    modal_backdrops.slice(modals.length).remove();

    modals.not(this.$element).css("z-index", function(i) {return 1050 + i * 20;});
    this.$element.css("z-index", 1050 + (modals.length - 1) * 20)

    arrangeTopModal(modals, this.$element);
    arrangeBackgroundModals(modals, this.$element);
  }

  var _modal_hide = $.fn.modal.Constructor.prototype.hide;
  $.fn.modal.Constructor.prototype.hide = function(ev) {
    if(ev && (ev.modalHidden))
        return;  //We already hid one

    if(this.$cloneEl) {
      this.$element.detach().appendTo(this.$cloneEl.parent());
      this.$cloneEl.remove();
      this.$cloneEl = null;
      this.$element.off(".clone")
    }

    _modal_hide.apply(this, arguments);

    var animated =
        $(".modal").filter(":animated");
    if(animated.length) {
        animated.stop(true, true);
    }

    var modals = $(".modal:visible");
    var lastModal = modals.last();
    lastModal.css({"height" : "", "overflow" : "", top : "", "margin-top" : ""});
    arrangeTopModal(modals, lastModal);
    arrangeBackgroundModals(modals, lastModal);
    if(ev) ev.modal_hidden = true; //mark that we've hidden one
  };

  $(function() {
    $('body').on('click.modal-ajax.data-api', '[data-toggle="modal-ajax"], [data-toggle="modal-ajax-form"], [data-toggle="modal-ajax-listform"], [data-toggle="modal-ajax-listnewform"], [data-toggle="modal-ajax-relationship-selector"], [data-toggle="modal-ajax-single-selector"], [data-toggle="modal-ajax-listeditform"], [data-toggle="modal-ajax-deleteform"]', function(e) {

      var $this = $(this)
        , toggle_type = $(this).data('toggle')
        , modal_id, target, $target, option, href, new_target, modal_type;

      href = $this.attr('data-href') || $this.attr('href');
      modal_id = 'ajax-modal-' + href.replace(/[\/\?=\&#%]/g, '-').replace(/^-/, '');
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

      $target.on('hidden', function(ev) {
        if(ev.target === ev.currentTarget)
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
