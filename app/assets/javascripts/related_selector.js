/*
 * Requires:
 *   .modal > .form { ul.optionslist, ul.currentlist }
 */

!function($) {

  var ModalRelationshipSelector = function(element, options) {
    this.options = options;
    this.$element = $(element);
    $.fn.modal_form.Constructor.prototype.init.apply(this);
    this.init();
  };

  ModalRelationshipSelector.prototype = $.extend({}, $.fn.modal_form.Constructor.prototype, {

    constructor: ModalRelationshipSelector

  , mappers: {
      relationships: {
        options_load_item: function(o) { return o; }
      , options_add_item: function(o) { return o; }
      , current_load_item: function(o) { return o; }
      , current_add_item: function(o, id) { return { id: id, object: o } }
      }
  }

  , init: function() {
      this.mapper = 'relationships';

      this.current_objects = [];
      this.options_objects = [];

      // Register interface event listeners
      this.$element
        .on('click', '.source li [data-toggle="selector-list-select"]', $.proxy(this.handle_select, this))
        .on('click', '.target li [data-toggle="selector-list-remove"]', $.proxy(this.handle_remove, this));

      // Register internal listeners
      this.$element
        .on('ajax:json', $.proxy(this.handle_response, this))
        .on('list-load-item', '.source', $.proxy(this.load_option, this))
        .on('list-add-item',  '.source', $.proxy(this.add_option, this))
        .on('list-update-item', '.source', $.proxy(this.update_option, this))
        .on('list-delete-item', '.source', $.proxy(this.delete_option, this))
        .on('list-load-item', '.target', $.proxy(this.load_selected_option, this))
        .on('list-add-item',  '.target', $.proxy(this.add_selected_option, this))
        .on('list-update-item', '.target', $.proxy(this.update_selected_option, this))
        .on('list-delete-item', '.target', $.proxy(this.delete_selected_option, this))
        .on('change', '.target', $.proxy(this.change_selected_fields, this))
        .on('delete-object', $.proxy(this.delete_object, this))
        .on('sync-lists', $.proxy(this.sync_lists, this))

      // Wait for initial modal 'loaded' event
      this.$element
        .on('loaded', $.proxy(this.load_lists, this));
    }

  , change_selected_fields: function(e) {
      // FIXME: Mark items as 'pending'
    }

  , delete_object: function(e, data, xhr) {
      this.$source().trigger('list-delete-item', data);
      this.$target().trigger('list-delete-item', data);
    }

  , handle_response: function(e, data, xhr) {
      var $target = this.$target();
      if (data.errors) {
        // Walk error object and insert error messages
        $.each(data.errors, function(id, errors) {
          var $added_item = $target.find('[data-id="' + id + '"]');
          $added_item.addClass('member-failure');
          $.each(errors, function(key, error) {
            var $input = $added_item.find('[name="items[' + id + '][' + key + ']"]');

            // Handle special case for "base" error messages
            if ($input.length == 0 && key == "base")
              $input = $added_item.find('[name]').first();

            // Find nearest sibling .help-inline
            var $help_inline = $input.siblings('.help-inline');
            if ($help_inline.length == 0)
              $help_inline = $input.parent().siblings('.help-inline');
            if ($help_inline.length == 0)
              $help_inline = $input.parent().parent().siblings('.help-inline');
            if ($help_inline.length == 0)
              $help_inline = $input.parent().parent().parent().siblings('.help-inline');

            $help_inline.text(error);
          });
        });
      } else {
        $(this.options.tabTarget).trigger('redraw');
        this.$element.modal_relationship_selector('hide');
      }
    }

  , $source: function() { return this.$element.find('.source'); }
  , $target: function() { return this.$element.find('.target'); }

  , mark_item_selected: function($el) {
      $el.
        find('[data-toggle="selector-list-select"]').
          removeClass('widgetbtn').
          addClass('widgetbtnoff').
          find('i').
            removeClass('grcicon-chevron-right').
            addClass('grcicon-check-green');
    }

  , mark_item_unselected: function($el) {
      $el.
        find('[data-toggle="selector-list-select"]').
          removeClass('widgetbtnoff').
          addClass('widgetbtn').
          find('i').
            removeClass('grcicon-check-green').
            addClass('grcicon-chevron-right');
    }

  , load_lists: function(e) {
      var self = this
        , $source = this.$source()
        , $target = this.$target()
        , source_url = $source.data('list-data-href')
        , target_url = $target.data('list-data-href');

      $.getJSON(source_url, function(data, status, xhr) {
        $source.empty();
        $.each(data, function(i, item) {
          $source.trigger('list-load-item', item);
        });
        self.$element.trigger('sync-lists');
      });

      $.getJSON(target_url, function(data, status, xhr) {
        $target.empty();
        $.each(data, function(i, item) {
          $target.trigger('list-load-item', item);
        });
        self.$element.trigger('sync-lists');
      });
    }

  , sync_lists: function(e) {
      var self = this
        , $source = this.$source()
        , $target = this.$target();

      $source.find('[data-id]').each(function(i, el) {
        var $el = $(el)
          , $added_item = $target.find('[data-object-id="' + $el.data('id') + '"]');
        if ($added_item.length > 0 && !$added_item.hasClass('removed')) {
          self.mark_item_selected($el);
        }
      });

      $target.find('[data-object-id]').each(function(i, el) {
        var $el = $(el)
          , $added_item = $source.find('[data-id="' + $el.data('object-id') + '"]');
        if ($added_item.length > 0 && !$el.hasClass('removed')) {
          self.mark_item_selected($added_item);
        }
      });
    }

  , load_option: function(e, item) {
      this.$source().tmpl_additem(item);
    }

  , load_selected_option: function(e, item) {
      var $target = this.$target();

      $target.tmpl_additem(
        this.mappers[this.mapper].current_load_item(item));
    }

  , next_random_id: function() {
      this._next_random_id = (this._next_random_id || 0) + 1;
      return "new-" + this._next_random_id;
    }

  , add_option: function(e, item) {
      var $added_item
        , $source = this.$source()
        , data = this.mappers[this.mapper].options_add_item(item)
        ;

      $added_item = $source.find('[data-id="' + data.id + '"]');
      $source.tmpl_additem(data);
    }

  , add_selected_option: function(e, item) {
      var $added_item
        , $target = this.$target()
        , data = this.mappers[this.mapper].current_add_item(item, this.next_random_id())
        ;

      $added_item = $target.find('[data-object-id="' + item.id + '"]');
      if ($added_item.is('.removed')) {
        $added_item.removeClass('removed');
        $added_item.find('._destroy').val('');
        $added_item.find('.state').text('');
      } else if ($added_item.length == 0) {
        $target.tmpl_additem(data);
        $added_item = $target.find('[data-object-id="' + data.object.id + '"]');
        $added_item.addClass('added');
        $added_item.find('.state').text('added').addClass('statustextgreen');
      }
      this.$element.trigger('sync-lists');
    }

  , update_option: function(e, item) {
      var $updated_item
        , $source = this.$source()
        , data = this.mappers[this.mapper].options_add_item(item)
        ;

      $updated_item = $source.find('[data-id="' + data.id + '"]');
      if ($updated_item.length > 0) {
        $updated_item.replaceWith($.tmpl.render_items($source, [item]));

        this.$element.trigger('sync-lists');
      }
    }

  , update_selected_option: function(e, item) {
      var $updated_item
        , $new_item
        , $target = this.$target()
        , data, join_id
        , added, removed
        ;

      $updated_item = $target.find('[data-object-id="' + item.id + '"]');
      if ($updated_item.length > 0) {
        join_id = $updated_item.attr('data-id');
        data = this.mappers[this.mapper].current_add_item(item, join_id);
        $new_item = $.tmpl.render_items($updated_item.find('.object_info'), [data]);
        $updated_item.find('.object_info').html($new_item);
      }
      return
    }

  , delete_option: function(e, item) {
      var $item
        , $source = this.$source()
        ;

      $item = $source.find('[data-id="' + item.id + '"]');
      $item.remove();
    }

  , delete_selected_option: function(e, item) {
      var $item
        , $target = this.$target()
        ;

      $item = $target.find('[data-object-id="' + item.id + '"]');
      $item.remove();
    }

  , submit: function(e) {
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

      $target.trigger('list-add-item', data);
      this.mark_item_selected($item);
    }

  , handle_remove: function(e) {
      e.preventDefault();
      var $item = $(e.currentTarget).closest('li')
        , $option_item = this.$source().find('[data-id="' + $item.attr('data-object-id') + '"]')
        ;

      // Add/remove class to highlight removed items
      if ($item.is('.removed')) {
        // Undo the remove operation
        $item.removeClass('removed');
        $item.find('.state').text('').removeClass('statustextred');
        $item.find('._destroy').val('');

        this.mark_item_selected($option_item);
      } else {
        if ($item.is('.added')) {
          $item.remove();
        } else if ($item.is('.changed')) {
          $item.addClass('removed');
          $item.find('.state').text('removed').addClass('statustextred');
          $item.find('._destroy').val('destroy');
        } else {
          $item.find('.state').text('removed').addClass('statustextred');
          $item.find('._destroy').val('destroy');
          $item.addClass('removed');
        }

        // Reset 'add' icon in source list
        this.mark_item_unselected($option_item);
      }
    }
  });

  $.fn.modal_relationship_selector = function(option) {
    return this.each(function() {
      var $this = $(this)
        , data = $this.data('modal_form')
        , options = $.extend({}, $.fn.modal_relationship_selector.defaults, $this.data(), typeof option == 'object' && option);
      if (!data) $this.data('modal_form', (data = new ModalRelationshipSelector(this, options)));
      if (typeof option == 'string') data[option]();
      else if (options.show) data.show();
    });
  };

  $.fn.modal_relationship_selector.Constructor = ModalRelationshipSelector;

  $.fn.modal_relationship_selector.defaults = $.extend({}, $.fn.modal_form.defaults, {

  });

  /*$(function() {
    $('body').on('click.modal-relationship-selector.data-api', '[data-toggle="modal-relationship-selector"]', function(e) {
      var $this = $(this)
        , $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
        , option = $target.data('modal-form') ? 'toggle' : $.extend({}, $target.data(), $this.data());

      e.preventDefault();
      $target.modal_relationship_selector(option);
    });
  });*/
}(window.jQuery);

