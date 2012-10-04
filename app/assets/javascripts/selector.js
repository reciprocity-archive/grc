/*
 * Requires:
 *   .modal > .form { ul.optionslist, ul.currentlist }
 */

!function($) {

  var ModalSelector = function(element, options) {
    this.options = options;
    this.$element = $(element);

    $.fn.modal_form.Constructor.prototype.init.apply(this);
    this.init();
  };

  ModalSelector.prototype = $.extend({}, $.fn.modal_form.Constructor.prototype, {

    constructor: ModalSelector

  , init: function() {

      this.current_objects = [];
      this.options_objects = [];

      // Register event listeners
      this.$element
        .on('click', '.source li [data-toggle="selector-list-select"]', $.proxy(this.handle_select, this))
        .on('click', '.target li [data-toggle="selector-list-remove"]', $.proxy(this.handle_remove, this))
        .on('loaded', $.proxy(this.load_lists, this))
        .on('ajax:json', $.proxy(this.handle_response, this))
    }

  , handle_response: function(e, data, xhr) {
      var $target = this.$target();

      if (data.errors) {
        //e.stopImmediatePropagation();
        //e.stopPropagation();
        // Walk error object and insert error messages
        $.each(data.errors, function(id, errors) {
          var $added_item = $target.find('[data-id="' + id + '"]');
          $added_item.addClass('member-failure');
          $.each(errors, function(key, error) {
            var $input = $added_item.find('[name="items[' + id + '][' + key + ']"]');
            // Find nearest sibling .help-inline
            var $help_inline = $input.siblings('.help-inline');
            if ($help_inline.length == 0) {
              $help_inline = $input.parent().siblings('.help-inline');
            }
            $help_inline.text(error);
          });
        });
      }

      //if (data.errors) {
        var $els = this.$element.find('.removed').find('input, select, textarea');
        $els.each(function(i, el) {
          var $el = $(el)
            , name = $el.attr('data-name');
          if (name) {
            $el.attr('name', name);
            $el.attr('data-name', null);
          }
        });
      //}
    }

  , $source: function() { return this.$element.find('.source'); }
  , $target: function() { return this.$element.find('.target'); }

  , load_lists: function(e) {
      var $source = this.$source()
        , $target = this.$target()
        , source_url = $source.data('list-data-href')
        , target_url = $target.data('list-data-href');

      $.getJSON(source_url, function(data, status, xhr) {
        $source.tmpl_setitems(data);
        $source.find('[data-id]').each(function(i, el) {
          var $el = $(el)
            , $added_item = $target.find('[data-id="' + $el.data('id') + '"]');
          if ($added_item.length > 0) {
            $el.find('i.grcicon-chevron-right').
              removeClass('grcicon-chevron-right').
              addClass('grcicon-check-green');
          }
        });
      });

      $.getJSON(target_url, function(data, status, xhr) {
        var items = $.map(data, function(item, i) { return item.object_person });
        $target.tmpl_setitems(items);
        $target.find('[data-id]').each(function(i, el) {
          var $el = $(el)
            , $added_item = $source.find('[data-id="' + $el.data('id') + '"]');
          if ($added_item.length > 0) {
            $added_item.find('i.grcicon-chevron-right').
              removeClass('grcicon-chevron-right').
              addClass('grcicon-check-green');
          }
        });
      });
    }

  , submit: function(e) {
      var $els = this.$element.find('.removed').find('input, select, textarea');
      $els.each(function(i, el) {
        var $el = $(el)
          , name = $el.attr('name');
        if (name) {
          $el.attr('data-name', name);
          $el.attr('name', null);
        }
      });

      this.$target().find('.member-failure').removeClass('member-failure');
      $.fn.modal_form.Constructor.prototype.submit.apply(this, [e]);
    }

  , handle_select: function(e) {
      e.preventDefault();
      var $item = $(e.currentTarget).closest('li')
        , data = $item.data()
        , $target = this.$target()
        , $added_item
        ;
      $target.tmpl_mergeitems([{ id: data.id, person: data }]);

      $item.find('i').
        removeClass('grcicon-chevron-right').
        addClass('grcicon-check-green');

      $added_item = $target.find('[data-id="' + data.id + '"]');
      if ($added_item.is('.removed')) {
        $added_item.removeClass('removed');
      } else {
        $added_item.addClass('added');
      }
    }

  , handle_remove: function(e) {
      e.preventDefault();
      var $item = $(e.currentTarget).closest('li');

      // Add/remove class to highlight removed items
      if ($item.is('.added')) {
        $item.remove();
      } else if ($item.is('.changed')) {
        $item.removeClass('changed');
        $item.addClass('removed');
      } else {
        $item.addClass('removed');
      }

      // Reset 'add' icon in source list
      this.$source().
        find('[data-id="' + $item.data('id') + '"]').
        find('i').
          removeClass('grcicon-check-green').
          addClass('grcicon-chevron-right');
    }
  });

  $.fn.modal_selector = function(option) {
    return this.each(function() {
      var $this = $(this)
        , data = $this.data('modal_form')
        , options = $.extend({}, $.fn.modal_selector.defaults, $this.data(), typeof option == 'object' && option);
      if (!data) $this.data('modal_form', (data = new ModalSelector(this, options)));
      if (typeof option == 'string') data[option]();
      else if (options.show) data.show();
    });
  };

  $.fn.modal_selector.Constructor = ModalSelector;

  $.fn.modal_selector.defaults = $.extend({}, $.fn.modal_form.defaults, {

  });

  $(function() {
    $('body').on('click.modal-selector.data-api', '[data-toggle="modal-selector"]', function(e) {
      var $this = $(this)
        , $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
        , option = $target.data('modal-form') ? 'toggle' : $.extend({}, $target.data(), $this.data());

      e.preventDefault();
      $target.modal_selector(option);
    });
  });
}(window.jQuery);
